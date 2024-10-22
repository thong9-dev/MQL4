//+------------------------------------------------------------------+
//|                                                      Nubtung.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Method_MQL4.mqh";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int cntM1,xcntM1;
int cntM5,xcntM5;
int cntM15,xcntM15;
int cntM30,xcntM30;
int cntH1,xcntH1;
int cntH4,xcntH4;
int cntD1,xcntD1;

int OrderTicketClose_SellNeg[1];
int OrderTicketClose__BuyNeg[1];

int cntOrder;
double sumOrder;
int cntOrderBuy,cntOrderSell;
double sumOrderBuy,sumOrderSell;
double _PriceMax_Sell,_PriceMin_Sell;
double _PriceMax__Buy,_PriceMin__Buy;
int cntOrderFollowBuy,cntOrderFollowSell;
double sumOrderFollowBuy,sumOrderFollowSell;
double _PriceMax_FollowSell,_PriceMin_FollowSell;
double _PriceMax__FollowBuy,_PriceMin__FollowBuy;
double vSpread=100/MathPow(10,Digits);
double _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);

string EAVer="1.5";
string EAName="EA-Nubtung",SymbolShortName;

extern double Lots=0.01;
double lotsMsx=Lots*2;
extern double Fund=100;
extern int Pip=300;
extern int Magicnumber=8;//Magicnumber
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   _setTemplate();
   CreateBackground("BgroundGG","gg",110,0,2,20);

   SymbolShortName=_SymbolShortName();

//--- create timer
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string EA_Name(string v)
  {
   return SymbolShortName+v+" "+EAName;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   printf("//+---------------------------------------------------------------------------------------------+");

   printf("MaxDrawDown: "+C(MaxDrawDown,2)+" [ "+string(DateDD)+" ]");
   printf("MaxProfit: "+C(MaxProfit,2));
   printf("RunDay: "+C(cntRunDay,0)+" | Fund: "+C(Fund,2)+" | Profit: "+C(Profit,2)+" [ "+C(ProfitPercen,2)+"% ] Avg: "+C(ProfitAVG,2));
   printf("//+---------------------------------------------------------------------------------------------+");
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
string on,on2;
int sz;
double PriceEntry;
int MA_1=1,MA_2=1,MA_3=200;
int previousMA=1;

int cntRunDay=0;

double Profit,ProfitPercen,ProfitAVG;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   xcntD1=iBars(Symbol(),PERIOD_D1);
   if(cntD1!=xcntD1)
     {
      cntD1=xcntD1;
      cntRunDay++;
      //---
     }
//---
   xcntH1=iBars(Symbol(),0);
   if(cntH1!=xcntH1)
     {
      cntH1=xcntH1;
      on2="H1-On";
      _getOrderCNT_AtiveHub();
      _getPriceMaxMin();
      //---
      if(cntOrderBuy==0)
        {
         //    Price/Yellow                 Magenta/Green
         if(getMA(0,1,200,1,"=")==0 && getMA(0,100,400,1,"-")==1) //Out 100,700
           {
            on="Buy";
            //PriceEntry=iHigh(NULL,0,1)+(50/MathPow(10,Digits));
            PriceEntry=Ask;
            //sz=OrderSend(Symbol(),0,Lots,PriceEntry,100,0,0,EA_Name("-BUY [1 | "+cFillZero(cntOrderBuy)+"]") ,_MagicEncrypt(1),0);
           }

        }
      else if(cntOrderBuy>=1 && _isSarInAdj(1)==0 && sumOrderBuy<0)
        {
         if((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread)))
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_(1),Ask,100,0,0,EA_Name("-BUY [1 | "+cFillZero(cntOrderBuy)+"]"),_MagicEncrypt(1),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }

        }

      if(cntOrderSell==0)
        {

         if(getMA(0,1,200,1,"=")==1 && getMA(0,100,400,1,"-")==0)
           {
            on="Sell";
            //PriceEntry=iLow(NULL,0,1)-(50/MathPow(10,Digits));
            PriceEntry=Bid;
            //sz=OrderSend(Symbol(),1,Lots,PriceEntry,100,0,0,EA_Name("-SELL [1 | "+cFillZero(cntOrderSell)+"]"),_MagicEncrypt(2),0);
           }
        }
      else if(cntOrderSell>=1 && _isSarInAdj(1)==1 && sumOrderSell<0)
        {
         if((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread)))
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_(2),Bid,100,0,0,EA_Name("-SELL [1 | "+cFillZero(cntOrderSell)+"]"),_MagicEncrypt(2),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }
        }

      //+------------------------------------------------------------------+
      if(cntOrderFollowBuy==0 /*&& cntOrderBuy==0*/)
        {
         bool LongEntryCondition=(iStochastic(NULL,0,9,3,3,MODE_SMA,0,MODE_SIGNAL,1)>iStochastic(NULL,0,14,3,3,MODE_SMA,0,MODE_SIGNAL,1));

         if(/*getMA(0,100,600,1,"=")==0 && (getMAprevious(1,100,5,12)==1 && getMAprevious(1,100,0,4)==0)/*&& getMA(0,1,75,1,"=")==1  */ LongEntryCondition && _isSarInAdj(1)==0)
           {
            on="Buy";
            //PriceEntry=iHigh(NULL,0,1)+(50/MathPow(10,Digits));
            PriceEntry=Ask;
            sz=OrderSend(Symbol(),0,Lots,PriceEntry,100,0,0,EA_Name("-BUY [2 | "+cFillZero(cntOrderFollowBuy)+"]"),_MagicEncrypt(4),0);
           }
        }
      else if(cntOrderFollowBuy>=1)
        {
         if(((Ask<_PriceMax__FollowBuy) && (Ask<(_PriceMin__FollowBuy-vSpread))) && _isSarInAdj(1)==0)
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_(4),Ask,100,0,0,EA_Name("-BUY [2 | "+cFillZero(cntOrderFollowBuy)+"]"),_MagicEncrypt(4),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
         if((getMAprevious(1,100,5,12)==1 && getMAprevious(1,100,0,4)==0) && _isSarInAdj(1)==0 && sumOrderFollowBuy<0)
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_(4),Ask,100,0,0,EA_Name("-BUY [2 | "+cFillZero(cntOrderFollowBuy)+"]"),_MagicEncrypt(4),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
        }
      if(cntOrderFollowSell==0 /*&& cntOrderSell==0*/)
        {
         bool ShortEntryCondition=(iStochastic(NULL,0,9,3,3,MODE_SMA,0,MODE_SIGNAL,1)<iStochastic(NULL,0,14,3,3,MODE_SMA,0,MODE_SIGNAL,1));
         if(/*getMA(0,100,600,1,"=")==1 && (getMAprevious(1,100,5,12)==0 && getMAprevious(1,100,0,4)==1)/*&& getMA(0,1,75,1,"=")==0  */ ShortEntryCondition && _isSarInAdj(1)==1)
           {
            on="Sell";
            //PriceEntry=iLow(NULL,0,1)-(50/MathPow(10,Digits));
            PriceEntry=Bid;
            sz=OrderSend(Symbol(),1,Lots,PriceEntry,100,0,0,EA_Name("-Sell [2 | "+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(5),0);
            printf(__FUNCTION__+" "+string(_MagicEncrypt(5)));
           }
        }
      else if(cntOrderFollowSell>=1)
        {
         //Print(__FUNCTION__+" "+cntOrderFollowSell);
         if((Bid>_PriceMin_FollowSell) && (Bid>(_PriceMax_FollowSell+vSpread)) && _isSarInAdj(1)==1)
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_(5),Bid,100,0,0,EA_Name("-Sell [2 | "+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(5),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }
         if((getMAprevious(1,100,5,12)==0 && getMAprevious(1,100,0,4)==1) && _isSarInAdj(1)==1 && sumOrderFollowSell<0)
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_(5),Bid,100,0,0,EA_Name("-Sell [2 | "+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(5),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }
        }
      //+------------------------------------------------------------------+
     }
   Profit=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE)-Fund,2);
   ProfitPercen=NormalizeDouble((Profit/Fund)*100,2);

   ProfitAVG=(Profit)/cntRunDay;
   ProfitAVG=NormalizeDouble(ProfitAVG*35,2);

   double Current_PT=AccountInfoDouble(ACCOUNT_PROFIT);
   getDrawDown(Current_PT);
   string SMS;
//SMS+="\n"+c(previousMA(5))+" "+c(getMA(0,MA_1,MA_2,MA_3,1));
   SMS+="\n"+SymbolShortName+" Day : "+c(cntRunDay);
   SMS+="\nBalace : "+Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" [ "+C(ProfitPercen,2)+"% / "+C(ProfitAVG,2)+" ]";
   SMS+="\nProfit : "+Comma(Current_PT,2," ");
   SMS+="\nDD : "+C(MaxDrawDown,2)+" [ "+string(DateDD)+" ] PT : "+C(MaxProfit,2);

   SMS+="\n\nBefore: "+c(getMAprevious(1,50,2,5))+" After: "+c(getMAprevious(1,50,0,1));

   _getPriceMaxMin();
   _getOrderCNT_AtiveHub();

   if(cntOrderBuy==0)
     {
      OrderStopLossBuy=0;
      DepositBuy=0;
      HLineDelete(0,"LINE_Point1");
      HLineDelete(0,"LINE_Save1");
      HLineDelete(0,"LINE_SL1");
     }
   if(cntOrderSell==0)
     {
      OrderStopLossSell=0;
      DepositSell=0;
      HLineDelete(0,"LINE_Point2");
      HLineDelete(0,"LINE_Save2");
      HLineDelete(0,"LINE_SL2");
     }
   if(cntOrderFollowBuy==0)
     {
      OrderStopLossFollowBuy=0;
      DepositBuyFollow=0;
      HLineDelete(0,"LINE_Point4");
      HLineDelete(0,"LINE_Save4");
      HLineDelete(0,"LINE_SL4");
     }
   if(cntOrderFollowSell==0)
     {
      OrderStopLossFollowSell=0;
      DepositSellFollow=0;
      HLineDelete(0,"LINE_Point5");
      HLineDelete(0,"LINE_Save5");
      HLineDelete(0,"LINE_SL5");
     }
   if(cntOrderFollowBuy>=1)
     {
      //printf(c(__LINE__));
      _OrderChkTP("Buy",cntOrderFollowBuy,4);
     }
   if(cntOrderFollowSell>=1)
     {
      //printf(c(__LINE__));
      _OrderChkTP("Sell",cntOrderFollowSell,5);
     }
   if(cntOrderBuy>=1)
     {
      //printf(c(__LINE__));
      _OrderChkTP("Buy",cntOrderBuy,1);
     }
   if(cntOrderSell>=1)
     {
      //printf(c(__LINE__));
      _OrderChkTP("Sell",cntOrderSell,2);
     }

/*sumOrderBuy=0;
   cntOrderBuy=sumOrderBuy;
   DepositBuy=cntOrderBuy;

   sumOrderSell=0;
   DepositSell=sumOrderSell;
   cntOrderSell=sumOrderSell;*/
   SMS+="\n------";
//+------------------------------------------------------------------+
   if(cntOrderBuy>0 || cntOrderSell>0)
      SMS+="\nNormal-";
   SMS+=strZeroT(" Buy [ "+c(cntOrderBuy)+" ] : "+C(sumOrderBuy,2),cntOrderBuy)+strZero(DepositBuy,"*","*");
   if(cntOrderBuy>0 && cntOrderSell>0)
      SMS+=" |";
   SMS+=strZeroT(" Sell [ "+c(cntOrderSell)+" ] : "+C(sumOrderSell,2),cntOrderSell)+strZero(DepositSell,"*","*");
//+------------------------------------------------------------------+
   if(cntOrderFollowBuy>0 || cntOrderFollowSell>0)
      SMS+="\nFollow--";
   SMS+=strZeroT(" Buy [ "+c(cntOrderFollowBuy)+" ] : "+C(sumOrderFollowBuy,2),cntOrderFollowBuy)+strZero(DepositBuyFollow,"*","*");
   if(cntOrderFollowBuy>0 && cntOrderFollowSell>0)
      SMS+=" |";
   SMS+=strZeroT(" Sell [ "+c(cntOrderFollowSell)+" ] : "+C(sumOrderFollowSell,2),cntOrderFollowSell)+strZero(DepositSellFollow,"*","*");
//+------------------------------------------------------------------+

   SMS+="\n"+SMS_Workday;
   Comment(SMS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strZeroT(string var,int Key)
  {
   string v="";
   if(Key>0)
     {
      v=var;
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strZero(double var,string z1,string z2)
  {
   string v="";
   if(var>0)
     {
      v=z1+C(var,2)+z2;
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderX(int v)
  {
   OrderTicketClose_SellNeg[0]=v;
   if(OrderSelect(OrderTicketClose_SellNeg[0],SELECT_BY_TICKET)==true)
     {
      sz=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
      printf(string(OrderTicket())+" X "+string(sz));
      OrderTicketClose_SellNeg[0]=0;
     }
   return sz;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
int getBarUpDw(int n)
  {
   int v=-1;
   double _Open=iOpen(NULL,0,n);
   double _Close=iClose(NULL,0,n);

   if(_Open>_Close)
     {
      v=0;
     }
   else if(_Open<_Close)
     {
      v=1;
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getMA(int TF,int vFast,int vSlow,int shift,string Mode)
  {
   int v=-1;

   double Fast=iMA(NULL,TF,vFast,0,MODE_SMA,PRICE_MEDIAN,shift);
   double Slow=iMA(NULL,TF,vSlow,0,MODE_SMA,PRICE_MEDIAN,shift);
   if(Mode=="=")
     {
      if(Bid>=Slow)
        {
         v=0;
        }
      else  if(Bid<=Slow)
        {
         v=1;
        }
     }
   if(Mode=="-")
     {
      if(Fast>Slow)
        {
         v=0;
        }
      else  if(Fast<Slow)
        {
         v=1;
        }
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getMA(int TF,int vFast,int vMid,int vSlow,int shift)
  {
   int v;

   double Fast=iMA(NULL,TF,vFast,0,MODE_SMA,PRICE_MEDIAN,shift);
   double Mid=iMA(NULL,TF,vMid,0,MODE_SMA,PRICE_MEDIAN,shift);
   double Slow=iMA(NULL,TF,vSlow,0,MODE_SMA,PRICE_MEDIAN,shift);

   if(Fast>Mid && Mid>Slow && Fast>Slow)
     {
      v=0;
     }
   else  if(Fast<Mid && Mid<Slow && Fast<Slow)
     {
      v=1;
     }
   else
     {
      v=-1;
     }

   return v;
  }
//+------------------------------------------------------------------+
string testgetMAprevious;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getMAprevious(int MA1,int MA2,int Start,int End)
  {
   bool chk=true;
   for(int i=Start;i<End;i++)
     {
      if(getMA(0,MA1,MA2,i,"-")!=getMA(0,MA1,MA2,i+1,"-"))
        {
         chk=false;
         break;
        }
     }
   int v=-1;
   if(chk)
     {
      v=getMA(0,MA1,MA2,Start,"-");
     }
   else
     {
      v=-1;
     }

   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(bool v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(int v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setTemplate()
  {

   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);
   ChartSetInteger(0,CHART_COLOR_GRID,clrBlue);

   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Comma(double v,int Digit,string zz)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= zz;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }
   return temp3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string C(double v,int Digit)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }
   return temp3;
  }
//+------------------------------------------------------------------+
void _OrderTrailingStop_(int Ticket,double Trailing)
  {
//printf(Ticket+" | "+Trailing);
   double SL=-1;
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==true)
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            if(Bid-OrderOpenPrice()>Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
              {
               if(OrderStopLoss()<Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT) || (OrderStopLoss()==0))
                 {
                  //z=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),Red);
                  SL=Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT);

                 }
              }
           }
         else if(OrderType()==OP_SELL)
           {
            if(OrderOpenPrice()-Ask>Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
              {
               if((OrderStopLoss()>Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT)) || (OrderStopLoss()==0))
                 {
                  //z=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),Red);
                  SL=Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT);
                 }
              }
           }
         if(SL>0)
           {
            sz=OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
           }

        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getOrderCNT_AtiveHub()
  {
   cntOrderBuy=int(_getOrderCNT_Ative(1,"Cnt"));
   cntOrderSell=int(_getOrderCNT_Ative(2,"Cnt"));

   cntOrderFollowBuy=int(_getOrderCNT_Ative(4,"Cnt"));
   cntOrderFollowSell=int(_getOrderCNT_Ative(5,"Cnt"));

   sumOrderBuy=_getOrderCNT_Ative(1,"Sum");
   sumOrderSell=_getOrderCNT_Ative(2,"Sum");

   sumOrderFollowBuy=_getOrderCNT_Ative(4,"Sum");
   sumOrderFollowSell=_getOrderCNT_Ative(5,"Sum");

   cntOrder=cntOrderBuy+cntOrderSell;
   cntOrder=cntOrderFollowBuy+cntOrderFollowSell;

   sumOrder=sumOrderBuy+sumOrderSell;
   sumOrder=sumOrderFollowBuy+sumOrderFollowSell;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderCNT_Ative(int v,string mode)
  {
   int CurrentMagic=_MagicEncrypt(v);
   double c=0;
   double sum=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && OrderSymbol()==Symbol() && OrderType()<=1)
        {
         sum+=OrderProfit();
         c++;

        }
     }
   if(mode=="Sum")
     {
      return sum;
     }
   if(mode=="Cnt")
     {
      return c;
     }
   return -1;
  }
//+------------------------------------------------------------------+
double MaxDrawDown=99999;
double MaxProfit=-99999;
datetime DateDD;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getDrawDown(double v)
  {
   if(v>MaxProfit)
     {
      MaxProfit=v;

     }
   if(v<MaxDrawDown)
     {
      MaxDrawDown=v;
      DateDD=TimeLocal();
     }
  }
//+------------------------------------------------------------------+
int _isSarInAdj(int Shift)
  {
   double v=NormalizeDouble(iSAR(Symbol(),0,0.009,0.2,Shift),Digits);
   if(v>iClose(Symbol(),0,Shift))
     {
      return 1;//Sell
     }
   else
     {
      return 0;//Buy
     }

   return -1;
  }
//+------------------------------------------------------------------+
void _getPriceMaxMin()
  {
   _PriceMax__Buy= _getPriceMaxMin("Max",1);
   _PriceMin__Buy= _getPriceMaxMin("Min",1);

   _PriceMax_Sell=_getPriceMaxMin("Max",2);
   _PriceMin_Sell= _getPriceMaxMin("Min",2);

   _PriceMax__FollowBuy= _getPriceMaxMin("Max",4);
   _PriceMin__FollowBuy= _getPriceMaxMin("Min",4);

   _PriceMax_FollowSell=_getPriceMaxMin("Max",5);
   _PriceMin_FollowSell= _getPriceMaxMin("Min",5);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getPriceMaxMin(string v,int nm)
  {
   int _MagicNumber=_MagicEncrypt(nm);

   double MinPrice=99999,MaxPrice=-99999;

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber)
        {
         if(OrderOpenPrice()>MaxPrice)
           {
            MaxPrice=OrderOpenPrice();
           }
         if(OrderOpenPrice()<MinPrice)
           {
            MinPrice=OrderOpenPrice();
           }
        }
     }
/*if(MinPrice==99999)
      MinPrice=0;
   if(MaxPrice==-99999)
      MaxPrice=0;*/

//printf("[_isLastBas()]# Max : "+MaxPrice+" Min : "+MinPrice);
   if("Max"==v)
     {
      return  MaxPrice;
     }

   else if("Min"==v)
     {
      return  MinPrice;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalTrailing(int cnt,double Diff)
  {
   double Trailing=-1;

   Diff=Diff*MathPow(10,Digits);
   double MinTrai=MarketInfo(Symbol(),14);

   if(cnt==1)
     {
      if(Diff<=300)
        {Trailing=300;}
      else if(Diff<=400)
        {Trailing=300;}
      else if(Diff<=500)
        {Trailing=250;}
      else if(Diff<=600)
        {Trailing=200;}
      else if(Diff<=700)
        {Trailing=150;}
      else if(Diff<=800)
        {Trailing=100;}
      else
        {
         Trailing=MarketInfo(Symbol(),14);
         //Trailing=100;
        }
     }
   else
     {
      double W=50;
      Trailing=(200/cnt)*(1+(W/100));
      if(Trailing<MinTrai)
        {

         Trailing=MinTrai;
        }

     }
// }
   return NormalizeDouble(Trailing/MathPow(10,Digits),Digits);
//if(Diff>=Trailing)
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderStopLossBuy=0,OrderStopLossSell=0;
double OrderStopLossFollowBuy=0,OrderStopLossFollowSell=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderChkTP(string v,int cnt,int mn)
  {
   int _MagicNumber=_MagicEncrypt(mn);
//printf(__FUNCTION__+" "+string(_MagicNumber));
   string Direct="";

   double Point_=_CalculateTP(v,_MagicNumber);
//_OrderChkTP("Buy",cntOrderFollowBuy,4);

   HLineCreate_(0,"LINE_Point"+c(mn),0,Point_,clrLime,0,1,true,true,false,0);
   double Trailing=-1;
/*if(cnt>=5)
     {
      Trailing=MarketInfo(Symbol(),14);
     }*/
   double TrailingStart=Trailing;
   Trailing=Trailing/MathPow(10,Digits);
   TrailingStart=TrailingStart/MathPow(10,Digits);
   double SL=-1,SL2=-1,Diff;

   int _MagicNumber2=-1;
   string Direct2;

   _getOrderCNT_AtiveHub();
   string TestLoop;
   if("Buy"==v)
     {
      Direct=(string)OP_BUY;
      Diff=Bid-Point_;
      Trailing=_CalTrailing(cnt,Diff);
      TestLoop="";
      if(Diff>=Trailing)
        {
         TestLoop="*";
         if((OrderStopLossBuy<Bid-Trailing || OrderStopLossBuy==0) && _MagicNumber==_MagicEncrypt(1))
           {
            HLineCreate_(0,"LINE_Save"+c(mn),0,OrderStopLossBuy,clrMagenta,0,1,true,true,false,0);

            OrderStopLossBuy=High[1]-Trailing;
            SL=OrderStopLossBuy;

            if(cntOrderBuy>0 && cntOrderFollowSell>0 && sumOrderBuy+sumOrderFollowSell>0.5)
              {
               _MagicNumber2=5;
               Direct2=(string)OP_SELL;

               SL2=SL+_SPREAD;
              }
            if(cntOrderBuy>0 && cntOrderSell>0 && sumOrderBuy+sumOrderSell>0.5)
              {
               _MagicNumber2=2;
               Direct2=(string)OP_SELL;

               SL2=SL+_SPREAD;
              }
           }

         if((OrderStopLossFollowBuy<Bid-Trailing || OrderStopLossFollowBuy==0) && _MagicNumber==_MagicEncrypt(4))
           {
            HLineCreate_(0,"LINE_Save"+c(mn),0,OrderStopLossFollowBuy,clrMagenta,0,1,true,true,false,0);

            OrderStopLossFollowBuy=Bid-Trailing;
            SL=OrderStopLossFollowBuy;

            if(cntOrderFollowBuy>0 && cntOrderSell>0 && sumOrderFollowBuy>sumOrderSell>=0.5)
              {
               //+------------------------------------------------------------------+
               double Point_1=_CalculateTP(v,_MagicNumber);
               double Point_2=_CalculateTP(v,_MagicNumber);
               //+------------------------------------------------------------------+
               _MagicNumber2=2;
               Direct2=(string)OP_SELL;

               SL2=SL+_SPREAD;
              }
            if(cntOrderFollowBuy>0 && cntOrderFollowSell>0 && sumOrderFollowBuy+sumOrderFollowSell>=0.5)
              {
               _MagicNumber2=5;
               Direct2=(string)OP_SELL;

               SL2=SL+_SPREAD;
              }
           }
         HLineCreate_(0,"LINE_SL"+c(mn),0,SL,clrRed,0,1,true,true,false,0);
        }
      _LabelSet("Text_MM1",10,50,clrYellow,"Franklin Gothic Medium Cond",15,c(__LINE__)+"# "+C(cnt,0)+"Buy "+C(Diff*MathPow(10,Digits),0)+"/"+TestLoop+C(Trailing*MathPow(10,Digits),0));
     }
   else if("Sell"==v)
     {
      Direct=(string)OP_SELL;
      Diff=(Point_-Ask);
      Trailing=_CalTrailing(cnt,Diff);
      TestLoop="";
      if(Diff>=Trailing)
        {
         TestLoop="*";
         if((OrderStopLossSell>Ask+Trailing || OrderStopLossSell==0) && _MagicNumber==_MagicEncrypt(2))
           {
            HLineCreate_(0,"LINE_Save"+c(mn),0,OrderStopLossSell,clrYellow,0,1,true,true,false,0);

            OrderStopLossSell=Ask+Trailing;
            SL=OrderStopLossSell;

            if(cntOrderFollowBuy>0 && cntOrderSell>0 && sumOrderFollowBuy+sumOrderSell>0.5)
              {
               _MagicNumber2=4;
               Direct2=(string)OP_BUY;

               SL2=SL-_SPREAD;
              }
            if(cntOrderBuy>0 && cntOrderSell>0 && sumOrderBuy+sumOrderSell>0.5)
              {
               _MagicNumber2=1;
               Direct2=(string)OP_BUY;

               SL2=SL-_SPREAD;
              }
           }
         if((OrderStopLossFollowSell>Ask+Trailing || OrderStopLossFollowSell==0) && _MagicNumber==_MagicEncrypt(5))
           {
            HLineCreate_(0,"LINE_Save"+c(mn),0,OrderStopLossFollowSell,clrYellow,0,1,true,true,false,0);

            OrderStopLossFollowSell=Ask+Trailing;
            SL=OrderStopLossFollowSell;

            if(cntOrderBuy>0 && cntOrderFollowSell>0 && sumOrderBuy+sumOrderFollowSell>0.5)
              {
               _MagicNumber2=1;
               Direct2=(string)OP_BUY;

               SL2=SL-_SPREAD;
              }
            if(cntOrderFollowBuy>0 && cntOrderFollowSell>0 && sumOrderFollowBuy+sumOrderFollowSell>0.5)
              {
               _MagicNumber2=4;
               Direct2=(string)OP_BUY;

               SL2=SL-_SPREAD;
              }
           }
         HLineCreate_(0,"LINE_SL"+c(mn),0,SL,clrRed,0,1,true,true,false,0);
        }
      _LabelSet("Text_MM2",10,30,clrYellow,"Franklin Gothic Medium Cond",15,c(__LINE__)+"# "+C(cnt,0)+"Sell "+C(Diff*MathPow(10,Digits),0)+"/"+TestLoop+C(Trailing*MathPow(10,Digits),0));
     }

   bool CHK=false;
   if(SL>0)
     {
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==_MagicNumber)
           {
            if(OrderStopLoss()==SL)
               CHK=true;
            else
               CHK=false;
           }
        }

      if(!CHK)
        {
         _OrderModify(SL,_MagicNumber,Direct);
         if(SL2>0)
           {
            SL2=NormalizeDouble(SL2,Digits);
            //OrderModify(v,SL2,_MagicEncrypt(_MagicNumber2),Direct2);
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculateTP(string Direction,int _MagicNumber)
  {
   _getOrderCNT_AtiveHub();
   
   int CNT;
   if(Direction=="Buy")
     {CNT=cntOrderBuy;}
   else
     {CNT=cntOrderSell;}
     
   double SumDeposit=0;
   double SumProduct=0,
   
   SumLot = 0,
   MinLot = 99999,
   Result = 0,
   Temp   = 0;

   SumDeposit=0;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderMagicNumber()==_MagicNumber) && (OrderSymbol()==Symbol()))
        {
         //+------------------------------------------------------------------+
         SumDeposit+=_DepositCal(OrderType(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
         //+------------------------------------------------------------------+

         SumProduct+=OrderLots()*OrderOpenPrice();
         SumLot+=OrderLots();

         if(OrderLots()<MinLot)
           {
            MinLot=OrderLots();
           }
        }
     }
//+------------------------------------------------------------------+     
   _DepositSet(_MagicNumber,SumDeposit);
//+------------------------------------------------------------------+

   if(SumLot!=0)
     {
      Result=SumProduct/SumLot;
     }
   else
     {
      return 1;
     }

   return NormalizeDouble(Result,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculatePip(int c)
  {
   double Temp=200;
   string Str;
   for(int i=0;i<c; i++)
     {
      Temp=Temp+(Temp/100)*1;

      Temp=NormalizeDouble(Temp,2);

      Str+="/"+(string)Temp;
     }
//Print("[_Calculate Pip()]# CNT "+(string)c+" is "+Str);
   return Temp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DepositBuy,DepositSell;
double DepositBuyFollow,DepositSellFollow;
//+------------------------------------------------------------------+
bool _OrderModify(double _TP,int _MagicNumber,string _OrderType)
  {
   double SumDeposit=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()) && ((string)OrderType()==_OrderType))
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),_TP,0,0))//SL
           {
            sz=OrderModify(OrderTicket(),OrderOpenPrice(),0,_TP,0);//TP
           }
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _DepositCal(int _OrderType,double Lot,double OpenPrice,double SL,double TP)
  {
   double c=-1,Tragrt;

   if(SL>0)
     {
      Tragrt=SL;
     }
   else if(TP>0)
     {
      Tragrt=TP;
     }
   else
     {
      Tragrt=OpenPrice;
     }

   if(_OrderType==0)
     {
      c=((Tragrt-OpenPrice)*MathPow(10,Digits))*Lot;
     }
   if(_OrderType==1)
     {
      c=((OpenPrice-Tragrt)*MathPow(10,Digits))*Lot;
     }
   return c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _DepositSet(int nm,double var)
  {
   _MagicDecode(nm);
//Print(__FUNCTION__+" "+nm+" "+OrderPin);
   switch(OrderPin)
     {
      case  1:
         DepositBuy=var;
         break;
      case  2:
         DepositSell=var;
         break;
      case  4:
         DepositBuyFollow=var;
         break;
      case  5:
         DepositSellFollow=var;
         break;
      default:
         Print(__FUNCTION__+" error is default");
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);
   double c=0;
   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         c+=OrderLots();
        }
     }
//c=c/2;
   if(c>lotsMsx)
     {
      c=lotsMsx;
     }
   return NormalizeDouble(c,2);
  }
//+------------------------------------------------------------------+
bool Workday,Workdayx;
string SMS_Workday;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _StayFriday()
  {
   int H=TimeHour(TimeLocal());
   if((DayOfWeek()<=1 && H<=8) || (DayOfWeek()>=5 && H>=12))
     {
      Workday=false;//OFF-Rest
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" Holidays");
        }
     }
   else
     {
      Workday=True;//ON
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" Workday");
        }

     }
   if(Workdayx!=Workday)
      Print(__FUNCTION__+" "+string(Workday));

   SMS_Workday="Day : "+string(DayOfWeek())+":"+cFillZero(H)+" | Running ["+string(cntRunDay)+"] is a "+_strBoolYN(Workday);
  }
//+------------------------------------------------------------------+
string _strBoolYN(int v)
  {
   if(v)
      return "Workday";
   else
      return "Holidays";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cFillZero(int v)
  {
   string temp;
   if(v<10)
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;

  }
//+------------------------------------------------------------------+
int _MagicEncrypt(int Type)
  {
   string v=string(Magicnumber)+string(Type);
   return int(v);
  }
int OrderMagic_,OrderPin;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MagicDecode(int v)
  {
   string z=string(v);
   string m=StringSubstr(z,0,StringLen(string(Magicnumber)));
   string o=StringSubstr(z,StringLen(string(Magicnumber)),1);
   OrderMagic_=int(m);
   OrderPin=int(o);
  }
//+------------------------------------------------------------------+
void CreateBackground(string Name,string text,int Fontsize,int LabelCorner,int x,int y)
  {
   if(ObjectFind(Name)==-1)
     {
      ObjectCreate(Name,OBJ_LABEL,0,0,0,0,0);
     }
   ObjectSetText(Name,text,Fontsize,"Webdings");
   ObjectSet(Name,OBJPROP_CORNER,LabelCorner);
   ObjectSet(Name,OBJPROP_BACK,false);
   ObjectSet(Name,OBJPROP_XDISTANCE,x);
   ObjectSet(Name,OBJPROP_YDISTANCE,y);
   ObjectSet(Name,OBJPROP_COLOR,C'25,25,25');
  }
//+------------------------------------------------------------------+
string _SymbolShortName()
  {
   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);
  }
//+------------------------------------------------------------------+
