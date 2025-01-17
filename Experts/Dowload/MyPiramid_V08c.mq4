//+------------------------------------------------------------------+
//|                                                 MyPyramid08c.mq4 |
//|                                          Copyright © 2009, (EK). |
//| code by awangk                                                   |
//| version 0.8c                                                     |
//| system by denicrut                                               |
//| system by harry                                                  |
//+------------------------------------------------------------------+
extern string Info_Close="Untuk menutup semua OP";
extern bool ForceCloseAll=false;

extern string Info_Time = "Setting untuk waktu trading";
extern string StartTime = "00:00";
extern string StopTime="23:59";

extern bool   OPFriday=true;  //buka posisi hari jumat

extern string Info_OP="Setting parameter OP";
extern double TakeProfit=60;
extern double StopLoss=120;
extern double HedgingDistance=100;

extern string Info_Lot="Setting Lot masing-masing OP";
extern double OP1Lot=0.1; //bila 0 maka nggak akan dibuka
extern double OP2Lot = 0.3;
extern double OP3Lot = 0.9;
extern double OP4Lot = 1.8;
extern double OP5Lot = 3.6;
extern double OP6Lot = 7.2;
extern double OP7Lot = 14.4;
extern double OP8Lot = 28.8;
extern double OP9Lot = 57.6;
extern double OP10Lot = 115.2;
extern double OP11Lot = 230.4;
extern double OP12Lot = 0.0;
extern double OP13Lot = 0.0;
extern double OP14Lot = 0.0;
extern double OP15Lot = 0.0;

extern string Info_SecureOP="Bila Total OP = SecureOP dan Profit = SecureProfit -> CLOSE ALL";
extern int    SecureOP=4;        //banyaknya OP untuk mengaktifkan SecureProfit 
extern double SecureProfit=25.0;     //bila menyentuh ini maka close all

extern int    MaxTime= 5;              //maximal waktu untuk mengaktifkan  
extern double MaxTimeProfit = 5;       //bila menyentuh ini maka close all

extern double MinimalProfitActivate = 45.0;
extern double MinimalProfit         = 30.0;

extern int MagicNumber=23572;
extern int Slippage=3;

//filter
extern int Bands_Period    = 16;
extern int Bands_Deviation = 2;
extern int Power_Period    = 14;

extern bool Debug=false;

string ExpertName="@AW";
double Spread=0;
int OPSelanjutnya=OP_BUY;
double PriceSell_SL,PriceSell_OP,PriceSell_TP;
double PriceBuy_TP,PriceBuy_OP,PriceBuy_SL;
double profit;
bool StopTrading=false;
bool bMaxTime=false;
bool bMinimalProfit=false;

double  LastEquity;
color   ColorBlink;
color   Color1     = White;
color   Color2     = Gold;
color   Color3     = Yellow;
//
double MyPoint;
double LuckyPoint;
double StopLevel;

int OPLast=99;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----

   Comment("Init...");

//supaya nggak problem dengan digit berapa saja..
   MyPoint=MarketInfo(Symbol(),MODE_POINT);
   StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(MyPoint==0.00001)
     {
      StopLevel=StopLevel*0.1;
     }
   if(MyPoint<=0.0001)
     {
      MyPoint=0.0001;
      LuckyPoint=10000;
     }
   else if(MyPoint==0.001)
     {
      LuckyPoint=1000;
     }
   else if(MyPoint==0.01)
     {
      LuckyPoint=100;
     }
   else if(MyPoint==0.1)
     {
      LuckyPoint=10;
     }
   else if(MyPoint==1)
     {
      LuckyPoint=1;
     }

//Ambil spread
   Spread=Ask-Bid;

   if(ForceCloseAll==true) StopTrading=true;

//cek kalo masih ada Open Order
//dan setting price
   if(OrdersTotal()>0)
     {
      if(Debug==true) Print("Init Hitung Price");

      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
           {
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderCloseTime()==0)
              {
               //proses cari price
               if(OrderType()==OP_SELL)
                 {
                  PriceSell_OP = OrderOpenPrice();
                  PriceSell_TP = PriceSell_OP  - (TakeProfit * MyPoint);
                  PriceSell_SL = PriceSell_OP  + (StopLoss * MyPoint);

                  PriceBuy_OP = PriceSell_OP - Spread + (HedgingDistance * MyPoint);
                  PriceBuy_TP = PriceSell_SL - Spread;
                  PriceBuy_SL = PriceSell_TP - Spread;
                 }
               else
               if(OrderType()==OP_BUY)
                 {
                  PriceBuy_OP = OrderOpenPrice();
                  PriceBuy_TP = PriceBuy_OP  + (TakeProfit * MyPoint);
                  PriceBuy_SL = PriceBuy_OP  - (StopLoss * MyPoint);

                  PriceSell_OP = PriceBuy_OP + Spread - (HedgingDistance * MyPoint);
                  PriceSell_TP = PriceBuy_SL + Spread;
                  PriceSell_SL = PriceBuy_TP + Spread;
                 }
               break;
              }
           }
        }
     }

   DisplayText("t1","MyPyramid v.0.8c -- by Awangk",12,Gold,0,5,20,"Arial");
   DisplayText("g1","------------------------------------------------",12,White,0,5,32,"Arial");
   DisplayText("m1","PERSIAPAN...",10,White,0,5,45,"Arial Bold");
   ColorBlink=Color3;
   Comment("");

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----

   if(IsOptimization()==true)
     {
      if(StopLoss < TakeProfit) return(0);
      if(StopLoss < HedgingDistance) return(0);
      if(StopLoss - TakeProfit <= 10) return(0);
      if(StopLoss - HedgingDistance <= 10) return(0);
      if(SecureOP <= 3 && SecureProfit >= 100) return(0);
     }
   else
     {
      //--blink color
      if(ColorBlink==Color1) ColorBlink=Color2;
      else if(ColorBlink==Color2) ColorBlink=Color3;
      else ColorBlink=Color1;

      SetText("t1",StringConcatenate("MyPyramid v.0.8c -- by Awangk (",Seconds(),")"),12,ColorBlink,"Arial");
     }

//harus tutup semua
//dijamin nggak ada yg ketinggalan.. 
   if(ForceCloseAll==true)
     {
      SetText("m1","Close All Open Position....",10,White,"Arial Bold");
      CloseAll();
      if(CheckPair(MagicNumber)==false)
        {
         //Comment("MyPyramid V.0.8c", "\nClose All....");
         //ForceCloseAll = false;
         ForceCloseAll=StopTrading;

        }
      bMinimalProfit=false;
      return(0);
     }

   int i,OPSell=0,OPBuy=0,OPSellStop=0,OPBuyStop=0;
   int Ticket,OPtotal=0;
   double LotSelanjutnya=0;
   OPLast=99;
//hitung OP 
   if(Debug==true) Print("Logic#1 Hitung yg OP");

   profit=0;
   bMaxTime=false;
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderCloseTime()==0)
           {
            OPLast = OrderType();
            Ticket = OrderTicket();
            profit+= OrderProfit();
            if(OrderType() == OP_BUY)  OPBuy++;
            if(OrderType() == OP_SELL) OPSell++;
            if(OrderType() == OP_SELLSTOP) OPSellStop++;
            if(OrderType() == OP_BUYSTOP) OPBuyStop++;
            OPtotal++;
            if(TimeCurrent()-OrderOpenTime()>=MaxTime*60*60) bMaxTime=true;
           }
        }
     }

   if(OPtotal==0) LotSelanjutnya=OP1Lot;
   else if(OPtotal == 1) LotSelanjutnya = OP2Lot;
   else if(OPtotal == 2) LotSelanjutnya = OP3Lot;
   else if(OPtotal == 3) LotSelanjutnya = OP4Lot;
   else if(OPtotal == 4) LotSelanjutnya = OP5Lot;
   else if(OPtotal == 5) LotSelanjutnya = OP6Lot;
   else if(OPtotal == 6) LotSelanjutnya = OP7Lot;
   else if(OPtotal == 7) LotSelanjutnya = OP8Lot;
   else if(OPtotal == 8) LotSelanjutnya = OP9Lot;
   else if(OPtotal == 9) LotSelanjutnya = OP10Lot;
   else if(OPtotal == 10) LotSelanjutnya = OP11Lot;
   else if(OPtotal == 11) LotSelanjutnya = OP12Lot;
   else if(OPtotal == 12) LotSelanjutnya = OP13Lot;
   else if(OPtotal == 13) LotSelanjutnya = OP14Lot;
   else if(OPtotal == 14) LotSelanjutnya = OP15Lot;
   else LotSelanjutnya=0;

   OPtotal=OPBuy+OPSell;

//untuk mengamankan profit
   if(SecureOP>0 && SecureOP<=OPtotal && SecureProfit>0 && profit>=SecureProfit)
     {
      ForceCloseAll=true;
      return(0);
     }

//untuk mengamankan profit
   if(bMaxTime==true && profit>=MaxTimeProfit)
     {
      ForceCloseAll=true;
      return(0);
     }

   if(profit>=MinimalProfitActivate) bMinimalProfit=true;

   if(bMinimalProfit==true && profit<=MinimalProfit && profit>0)
     {
      ForceCloseAll=true;
      return(0);
     }

//maintenance orderstop double
   if(OPSellStop>1 || OPBuyStop>1)
     {
      //tutup semua order, nanti di Logic#4 dibuka lagi 
      //kenapa ada ini: tadi ada request yg timeout tapi tiba-tiba saja ada double
      if(Debug==true) Print("Error: Orderstop lebih dari 1 -- DELETE");
      SetText("m1","Delete Double OP...",10,White,"Arial Bold");
      DeleteSatuOrderStop();

      return(0);
     }

   Comment("\n\n\n\n",
           "\n\n Total OP_BUY = ",OPBuy,
           "\n Total OP_SELL = ",OPSell,
           "\n Total OP_BUYSTOP = ",OPBuyStop,
           "\n Total OP_SELLSTOP = ",OPSellStop,
           "\n\n Spread = ",Spread,
           "\n StopLevel = ",StopLevel,
           "\n\n PriceSell_OP = ",PriceSell_OP,
           "\n PriceSell_TP = ",PriceSell_TP,
           "\n PriceSell_SL = ",PriceSell_SL,
           "\n\n PriceBuy_OP = ",PriceBuy_OP,
           "\n PriceBuy_TP = ",PriceBuy_TP,
           "\n PriceBuy_SL = ",PriceBuy_SL,
           "\n\n SecureOP = ",SecureOP,
           "\n SecureProfit = ",SecureProfit,
           "\n TotalOP = ",OPtotal,
           "\n Profit = ",profit,
           "\n\n Equity = ",AccountEquity(),
           "\n Balance = ",AccountBalance());

//cek ada OP nggak
   if(OPBuy==0 && OPSell==0)
     {
      if(Debug==true) Print("Logic#2 Open Posisi");

      //tentukan arah ---------------------------
      if(OPSellStop>0) OPSelanjutnya=OP_BUY;
      else if(OPBuyStop>0) OPSelanjutnya=OP_SELL;

      //cek masih ada nggak OPStop yang menggantung
      if(OPSellStop>0 || OPBuyStop>0)
        {
         //tutup semua order  
         if(Debug==true) Print("Logic#2 DeleteOrderStop");

         ForceCloseAll=true;
         return(0);
        }

      //Filter by Time
      if(TradeTime()==false)
        {
         SetText("m1","Time Filter...",10,White,"Arial Bold");
         return(0);
        }

      bMinimalProfit=false;
      //kalau mau pake indicator mulai disini ---
      // OPSelanjutnya = OP_BUY --> BUY yg pertama
      // OPSelanjutnya = OP_SELL --> SELL yg pertama
      //-----------------------------------------
      //         

      //if(OPLast == OP_BUY || OPLast == OP_SELL)
      //   OPSelanjutnya = OPLast;
      //else
      //   OPSelanjutnya = GetSignal();

      OPSelanjutnya=GetSignal();
      if(OPSelanjutnya == 99) return(0);

      //OP sudah kosong
      if(OPSelanjutnya==OP_SELL) //sell
        {
         if(Debug==true) Print("Logic#2 OP pertama SELL");

         RefreshRates();
         Ticket=OpenOrder(OP_SELL,OP1Lot,Bid,0,0,Red);
         if(Ticket < 0) return(0);
         else
           {
            OPSell = 1;
            OPLast = OP_SELL;
            LotSelanjutnya=OP2Lot;
            SetText("m1","Next OP = OP_SELL",10,White,"Arial Bold");
           }
        }
      else
        {
         if(Debug==true) Print("Logic#2 OP pertama BUY");

         RefreshRates();
         Ticket=OpenOrder(OP_BUY,OP1Lot,Ask,0,0,Blue);
         if(Ticket < 0) return(0);
         else
           {
            OPBuy=1;
            OPLast=OP_BUY;
            LotSelanjutnya=OP2Lot;
           }
        }

     }

   SetText("m1",proverb(Seconds()),8,White,"Arial Bold");

//cek baru 1 buy atau 1 sell tidak ada buystop atau sellstop
   if(((OPBuy==1 && OPSell==0) || (OPBuy==0 && OPSell==1)) && (OPBuyStop==0 && OPSellStop==0))
     {
      if(Debug==true) Print("Logic#3 Hitung Price");

      if(OPLast==OP_SELL)
        {
         //hitung price yg diperlukan
         if(OrderSelect(Ticket,SELECT_BY_TICKET)==true)
           {
            if(Debug==true) Print("Logic#3 Hitung Price - SELL");

            PriceSell_OP = OrderOpenPrice();
            PriceSell_TP = PriceSell_OP  - (TakeProfit * MyPoint);
            PriceSell_SL = PriceSell_OP  + (StopLoss * MyPoint);

            PriceBuy_OP = PriceSell_OP - Spread + (HedgingDistance * MyPoint);
            PriceBuy_TP = PriceSell_SL - Spread;
            PriceBuy_SL = PriceSell_TP - Spread;

            //Modify TP & SL
            if(OrderStopLoss()==0 && OrderTakeProfit()==0)
              {
               if(Debug==true) Print("Logic#3 Modify Order");
               if(OrderModify(OrderTicket(), OrderOpenPrice(), PriceSell_SL, PriceSell_TP, 0, Red) == false) return(0);
              }

            if(Debug==true) Print("Logic#3 Open BUYSTOP");
            Ticket=OpenOrder(OP_BUYSTOP,LotSelanjutnya,PriceBuy_OP,PriceBuy_SL,PriceBuy_TP,Blue);
            if(Ticket>0)
              {
               OPSelanjutnya=OP_SELL;
              }

            return(0);
           }
        }
      if(OPLast==OP_BUY)
        {
         //hitung price yg diperlukan
         if(OrderSelect(Ticket,SELECT_BY_TICKET)==true)
           {
            if(Debug==true) Print("Logic#3 Hitung Price - BUY");

            PriceBuy_OP = OrderOpenPrice();
            PriceBuy_TP = PriceBuy_OP  + (TakeProfit * MyPoint);
            PriceBuy_SL = PriceBuy_OP  - (StopLoss * MyPoint);

            PriceSell_OP = PriceBuy_OP + Spread - (HedgingDistance * MyPoint);
            PriceSell_TP = PriceBuy_SL + Spread;
            PriceSell_SL = PriceBuy_TP + Spread;

            //Modify TP & SL
            if(OrderStopLoss()==0 && OrderTakeProfit()==0)
              {
               if(Debug==true) Print("Logic#3 Modify Order");
               if(OrderModify(OrderTicket(), OrderOpenPrice(), PriceBuy_SL, PriceBuy_TP, 0, Blue) == false) return(0);
              }

            if(Debug==true) Print("Logic#3 Open SELLSTOP");
            Ticket=OpenOrder(OP_SELLSTOP,LotSelanjutnya,PriceSell_OP,PriceSell_SL,PriceSell_TP,Red);
            if(Ticket>0)
              {
               OPSelanjutnya=OP_BUY;
              }
            return(0);
           }
        }
     }

//buystop & sellstop sudah tereksekusi maka buka lagi
   if((OPBuy>0 || OPSell>0) && (OPBuyStop==0 && OPSellStop==0))
     {
      if(Debug==true) Print("Logic#4 Open OrderStop");
      if(LotSelanjutnya>0)
        {
         if(OPLast==OP_SELL)
           {
            if(Debug==true) Print("Logic#4 Open OrderStop - BUYSTOP");
            //if(MaxLot < LotSelanjutnya) {Print("Lot=",LotSelanjutnya," MaxLot=",MaxLot); return(0);}

            Ticket=OpenOrder(OP_BUYSTOP,LotSelanjutnya,PriceBuy_OP,PriceBuy_SL,PriceBuy_TP,Blue);
            if(Ticket>0)
              {
               OPSelanjutnya=OP_SELL;
              }
           }
         else
         if(OPLast==OP_BUY)
           {
            if(Debug==true) Print("Logic#4 Open OrderStop - SELLSTOP");
            //if(MaxLot < LotSelanjutnya) {Print("Lot=",LotSelanjutnya," MaxLot=",MaxLot); return(0);}

            Ticket=OpenOrder(OP_SELLSTOP,LotSelanjutnya,PriceSell_OP,PriceSell_SL,PriceSell_TP,Red);
            if(Ticket>0)
              {
               OPSelanjutnya=OP_BUY;
              }
           }
        }
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+

void CloseAll()
  {
   bool res=false;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderCloseTime()==0)
           {
            if(OrderType() == OP_BUY)      res =OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Blue);
            if(OrderType() == OP_SELL)     res =OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, Red);
            if(OrderType() == OP_SELLSTOP) res =OrderDelete(OrderTicket());
            if(OrderType() == OP_BUYSTOP)  res =OrderDelete(OrderTicket());
            Sleep(1000);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteSatuOrderStop()
  {
   bool res=false;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderCloseTime()==0)
           {
            if(OrderType() == OP_SELLSTOP) { res=OrderDelete(OrderTicket()); break;}
            if(OrderType() == OP_BUYSTOP)  { res=OrderDelete(OrderTicket()); break;}
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrder(int OPtype,double Lot,double OPprice,double SL,double TP,color clr)
  {
   int Ticket=-1;
   int OPt=OPtype;

   if(OPtype==OP_SELLSTOP) OPt=OP_SELL;
   else if(OPtype==OP_BUYSTOP) OPt=OP_BUY;

   if(AccountFreeMarginCheck(Symbol(),OPt,Lot)<=0 || GetLastError()==134)
     {
      Print("Bro, udah nggak punya Margin lagi nih, nggak bisa OP...");
      SetText("m1","Margin tidak cukup untuk OP...",10,White,"Arial Bold");
     }
   else
     {
      Ticket=OrderSend(Symbol(),OPtype,Lot,OPprice,Slippage,SL,TP,StringConcatenate(ExpertName,"-",Symbol()),MagicNumber,0,clr);
     }
   return(Ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TradeTime()
  {
   bool ret=false;
   if(StrToTime(StartTime)<StrToTime(StopTime))
     {
      ret=(TimeCurrent()>=StrToTime(StartTime) && TimeCurrent()<=StrToTime(StopTime));
     }
   else
     {
      ret=(TimeCurrent()>=StrToTime(StartTime) || TimeCurrent()<=StrToTime(StopTime));
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckPair(int magic)
  {
   bool ret=false;
   for(int cnt=0; cnt<OrdersTotal(); cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderCloseTime()==0)
           {
            ret=true;
            break;
           }
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayText(string objname,string text,int fontsize,color clr,double C,double X,double Y,string font)
  {
   ObjectDelete(objname);
   ObjectCreate(objname,OBJ_LABEL,0,0,0);
   ObjectSetText(objname,text,fontsize,font,clr);
   ObjectSet(objname,OBJPROP_CORNER,C);
   ObjectSet(objname,OBJPROP_XDISTANCE,X);
   ObjectSet(objname,OBJPROP_YDISTANCE,Y);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetText(string objname,string text,int fontsize,color clr,string font)
  {
   ObjectSetText(objname,text,fontsize,font,clr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string proverb(int i)
  {
   if(i<=10) return("Each man must ride the road of his own fate.");
   else if(i<=20) return("Habit causes love.");
   else if(i<=30) return("To teach is to learn twice.");
   else if(i<=40) return("Force not favours on the unwilling.");
   else if(i<=50) return("Desperate cuts must have desperate cures.");
   else return("Ilmu adalah kebajikan yang dapat menebus dosa.");
  }
//silahkan signal diganti...
int GetSignal()
  {
   int signal=99;

//double H, L, O, C, P;

//H = iHigh(Symbol(), PERIOD_D1, 1);
//L = iLow(Symbol(), PERIOD_D1, 1);
//C = iClose(Symbol(), PERIOD_D1, 1);

//O = iClose(Symbol(), PERIOD_D1, 0);

//P = (H + L + C) / 3;

//if(O > P) signal = OP_BUY;
//else signal = OP_SELL;


//itrend
   double green0=iClose(Symbol(), 0, 0)-iBands(Symbol(), 0, Bands_Period, Bands_Deviation, 0, MODE_MAIN, PRICE_CLOSE, 0);
   double green1=iClose(Symbol(), 0, 1)-iBands(Symbol(), 0, Bands_Period, Bands_Deviation, 0, MODE_MAIN, PRICE_CLOSE, 1);
   double green2=iClose(Symbol(), 0, 2)-iBands(Symbol(), 0, Bands_Period, Bands_Deviation, 0, MODE_MAIN, PRICE_CLOSE, 2);

   double red0=-(iBearsPower(Symbol(), 0, Power_Period, PRICE_CLOSE, 0)+iBullsPower(Symbol(), 0, Power_Period, PRICE_CLOSE, 0));
   double red1=-(iBearsPower(Symbol(), 0, Power_Period, PRICE_CLOSE, 1)+iBullsPower(Symbol(), 0, Power_Period, PRICE_CLOSE, 1));
   double red2=-(iBearsPower(Symbol(), 0, Power_Period, PRICE_CLOSE, 2)+iBullsPower(Symbol(), 0, Power_Period, PRICE_CLOSE, 2));

//hijau menanjak keatas, merah turun
   if(green2<green1 && green1<green0 && red2>red1 && red1>red0) signal=OP_BUY;

//merah menanjak keatas, hijau turun
   if(red2<red1 && red1<red0 && green2>green1 && green1>green0) signal=OP_SELL;

   return(signal);
  }
//+------------------------------------------------------------------+
