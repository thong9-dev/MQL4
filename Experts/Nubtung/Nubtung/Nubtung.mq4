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
#include "Method_Tools.mqh";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int cntM0,xcntM0;
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
double sumConfirm;

int cntOrderBuy,cntOrderSell;
double sumOrderBuy,sumOrderSell;
double _PriceMax_Sell,_PriceMin_Sell;
double _PriceMax__Buy,_PriceMin__Buy;

int cntOrderFollowBuy,cntOrderFollowSell;
double sumOrderFollowBuy,sumOrderFollowSell;
double _PriceMax_FollowSell,_PriceMin_FollowSell;
double _PriceMax__FollowBuy,_PriceMin__FollowBuy;

double ConfirmBuy,ConfirmSell;
double ConfirmBuyFollow,ConfirmSellFollow;

//DiffZeroPriceBuy
double DZP_Buy,DZP_Sell;
double DZP_BuyFollow,DZP_SellFollow;

double vSpread=100/MathPow(10,Digits);
double _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);
string _ActCurrency=" "+AccountCurrency();

string EAVer="1.5";
string EAName="Nubtung "+EAVer,SymbolShortName;

extern double Lots=0.01;
double lotsMsx=Lots*2;
extern double Fund=100;
//extern int Pip=300;
extern int Magicnumber=8;//Magicnumber
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   _StayFriday();
   setTemplate();
   setBackgroundPanel("BgroundGG","gg",110,0,2,20);

   SymbolShortName=strSymbolShortName();

//cntH1=iBars(Symbol(),PERIOD_H1);

//--- create timer
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strEA_Name(string v)
  {
   return SymbolShortName+v+""+EAName;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   printf(__FUNCTION__);
   printf("//+---------------------------------------------------------------------------------------------+");

   printf("MaxDrawDown: "+cD(MaxDrawDown,2)+_ActCurrency+" at [ "+string(DateDD)+" ]");
   printf("MaxProfit: "+cD(MaxProfit,2)+_ActCurrency);
   printf("RunDay: "+cD(cntRunDay,0)+" | Fund: "+cD(Fund,2)+_ActCurrency+" | Profit: "+cD(Profit,2)+_ActCurrency+" [ "+cD(ProfitPercen,2)+"% ] Avg: "+cD(ProfitAVG,2)+"/Day");
   printf("//+---------------------------------------------------------------------------------------------+");
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
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
   setBackgroundPanel("BgroundGG","gg",110,0,2,20);

   xcntD1=iBars(Symbol(),PERIOD_D1);
   if(cntD1!=xcntD1)
     {
      cntD1=xcntD1;
      cntRunDay++;
      //---
     }
   xcntH1=iBars(Symbol(),PERIOD_H1);
   if(cntH1!=xcntH1)
     {
      cntH1=xcntH1;
      _StayFriday();
      //---
     }
//---
   xcntM0=iBars(Symbol(),0);
   if(cntM0!=xcntM0)
     {
      //Print("Turning bars");
      cntM0=xcntM0;
/*int DiffForHege=-750;
      //---
      if(DZP_Sell<=DiffForHege && _OrderLookup("Buy",1,Ask,0) && _OrderLookup("Buy",4,Ask,0))
        {
         sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_GroupH(2),Ask,100,0,0,strEA_Name("H[B1|"+cFillZero(cntOrderBuy)+"]"),_MagicEncrypt(1),0);
        }
      if(DZP_SellFollow<=DiffForHege && _OrderLookup("Buy",1,Ask,0) && _OrderLookup("Buy",4,Ask,0))
        {
         sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_GroupH(5),Ask,100,0,0,strEA_Name("H[B2|"+cFillZero(cntOrderBuy)+"]"),_MagicEncrypt(4),0);
        }
      //---
      //---
      if(DZP_Buy<=DiffForHege && _OrderLookup("Sell",2,Bid,0) && _OrderLookup("Sell",5,Bid,0))
        {
         sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_Group(1),Bid,100,0,0,strEA_Name("H[S1|"+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(2),0);
        }
      if(DZP_BuyFollow<=DiffForHege && _OrderLookup("Sell",2,Bid,0) && _OrderLookup("Sell",5,Bid,0))
        {
         sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_Group(4),Bid,100,0,0,strEA_Name("H[S2|"+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(5),0);
        }*/
      //---
      //---
      bool Test_CCI_1=_iCCI(Symbol(),60,14,6,1,80);
      bool Test_CCI=_iCCI(Symbol(),60,14,6,1,90);

      //Test_CCI_1=true;
      //Test_CCI=true;
      //---

      //---
      bool Chk_OnBuy=true,Chk_OnSell=true;
      bool Chk_OnArea;
      double vSarUse=0.01;

      _getOrderCNT_AtiveHub();
      _getOrderPriceMaxMinHub();
      //---
      if(cntOrderBuy==0 && Workday)
        {
         //    Price/Yellow                 Magenta/Green
         if(getMA(0,1,200,1,"=")==0 && getMA(0,100,400,1,"-")==1 && Test_CCI_1) //Out 100,700
           {
            //PriceEntry=iHigh(NULL,0,1)+(50/MathPow(10,Digits));
            PriceEntry=Ask;
            sz=OrderSend(Symbol(),0,Lots,PriceEntry,100,0,0,strEA_Name("-[B1|"+cFillZero(cntOrderBuy)+"]"),_MagicEncrypt(1),0);
            Chk_OnBuy=false;
           }
        }
      else if(cntOrderBuy>=1 && _isSarInAdj(vSarUse,1)==0 && sumOrderBuy<0)
        {
         if((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread)))
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_Group(1),Ask,100,0,0,strEA_Name("-[B1|"+cFillZero(cntOrderBuy)+"]"),_MagicEncrypt(1),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
        }
      //---
      if(cntOrderSell==0 && Workday)
        {
         if(getMA(0,1,200,1,"=")==1 && getMA(0,100,400,1,"-")==0 && Test_CCI_1)
           {
            //PriceEntry=iLow(NULL,0,1)-(50/MathPow(10,Digits));
            PriceEntry=Bid;
            sz=OrderSend(Symbol(),1,Lots,PriceEntry,100,0,0,strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]"),_MagicEncrypt(2),0);
            Chk_OnSell=false;

           }
        }
      else if(cntOrderSell>=1 && _isSarInAdj(vSarUse,1)==1 && sumOrderSell<0)
        {
         if((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread)))
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_Group(2),Bid,100,0,0,strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]"),_MagicEncrypt(2),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }
        }
      //---
      vSarUse=0.021;
      //+------------------------------------------------------------------+
      if(cntOrderFollowBuy==0 /*&& cntOrderBuy==0*/ && Workday && Chk_OnBuy)
        {
         bool LongEntryCondition=(iStochastic(NULL,0,9,3,3,MODE_SMA,0,MODE_SIGNAL,1)>iStochastic(NULL,0,14,3,3,MODE_SMA,0,MODE_SIGNAL,1));
         //LongEntryCondition=true;

         if(/*getMA(0,100,600,1,"=")==0 && (getMAprevious(1,100,5,12)==1 && getMAprevious(1,100,0,4)==0)/*&& getMA(0,1,75,1,"=")==1  */ LongEntryCondition && _isSarInAdj(0.01,1)==0 && Test_CCI)
           {
            //PriceEntry=iHigh(NULL,0,1)+(50/MathPow(10,Digits));
            PriceEntry=Ask;
            sz=OrderSend(Symbol(),0,Lots,PriceEntry,100,0,0,strEA_Name("-[B2|"+cFillZero(cntOrderFollowBuy)+"]"),_MagicEncrypt(4),0);
           }
        }
      else
        {
         if(((Ask<_PriceMax__FollowBuy) && (Ask<(_PriceMin__FollowBuy-vSpread))) && _isSarInAdj(vSarUse,1)==0)
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_Group(4),Ask,100,0,0,strEA_Name("-[B2|"+cFillZero(cntOrderFollowBuy)+"]"),_MagicEncrypt(4),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
         DZP_BuyFollow=DZP_BuyFollow*MathPow(10,Digits);
         Chk_OnArea=((Ask<_PriceMax__FollowBuy) && (Ask>_PriceMin__FollowBuy)) && (DZP_BuyFollow>(-500) && DZP_BuyFollow<=0) && cntOrderFollowBuy>=2 && _OrderLookup("Buy",4,Ask,OrderPointFollowBuy);
         if(/*(getMAprevious(1,100,5,12)==1 && getMAprevious(1,100,0,4)==0) && */_isSarInAdj(vSarUse,1)==0 && sumOrderFollowBuy<0 && Chk_OnArea)
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_Group(4),Ask,100,0,0,strEA_Name("*[B2|"+cFillZero(cntOrderFollowBuy)+"]"),_MagicEncrypt(4),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
        }
      //---
      if(cntOrderFollowSell==0 /*&& cntOrderSell==0*/ && Workday && Chk_OnSell)
        {
         bool ShortEntryCondition=(iStochastic(NULL,0,9,3,3,MODE_SMA,0,MODE_SIGNAL,1)<iStochastic(NULL,0,14,3,3,MODE_SMA,0,MODE_SIGNAL,1));
         //ShortEntryCondition=true;

         if(/*getMA(0,100,600,1,"=")==1 && (getMAprevious(1,100,5,12)==0 && getMAprevious(1,100,0,4)==1)/*&& getMA(0,1,75,1,"=")==0  */ ShortEntryCondition && _isSarInAdj(0.01,1)==1 && Test_CCI)
           {
            //PriceEntry=iLow(NULL,0,1)-(50/MathPow(10,Digits));
            PriceEntry=Bid;
            sz=OrderSend(Symbol(),1,Lots,PriceEntry,100,0,0,strEA_Name("-[S2|"+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(5),0);
            printf(__FUNCTION__+" "+string(_MagicEncrypt(5)));
           }
        }
      else
        {
         //Print(__FUNCTION__+" "+cntOrderFollowSell);
         if((Bid>_PriceMin_FollowSell) && (Bid>(_PriceMax_FollowSell+vSpread)) && _isSarInAdj(vSarUse,1)==1)
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_Group(5),Bid,100,0,0,strEA_Name("-[S2|"+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(5),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }

         DZP_SellFollow=DZP_SellFollow*MathPow(10,Digits);
         Chk_OnArea=((Bid>_PriceMin_FollowSell) && (Bid<_PriceMax_FollowSell+vSpread)) && (DZP_SellFollow>(-500) && DZP_SellFollow<=0) && cntOrderFollowSell>=2 && _OrderLookup("Sell",5,Bid,OrderPointFollowSell);
         if(/*(getMAprevious(1,100,5,12)==0 && getMAprevious(1,100,0,4)==1) && */_isSarInAdj(vSarUse,1)==1 && sumOrderFollowSell<0 && Chk_OnArea)
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_Group(5),Bid,100,0,0,strEA_Name("*[S2|"+cFillZero(cntOrderFollowSell)+"]"),_MagicEncrypt(5),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }
        }
      //+------------------------------------------------------------------+
     }
   Profit=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE)-Fund,2);

   if(Fund==0)Fund=1;

   ProfitPercen=NormalizeDouble((Profit/Fund)*100,2);

   int save=cntRunDay;
   if(cntRunDay==0)cntRunDay=1;

   ProfitAVG=(Profit)/cntRunDay;
//ProfitAVG=NormalizeDouble(ProfitAVG*35,2);

   double Current_PT=AccountInfoDouble(ACCOUNT_PROFIT);
   getDrawDown(Current_PT);
   string SMS;
//SMS+="\n"+c(previousMA(5))+" "+c(getMA(0,MA_1,MA_2,MA_3,1));
//SMS+="\n"+SymbolShortName+" Day : "+cI(cntRunDay);
   SMS+=SMS_Workday+"\n";
   SMS+="\nProfit : "+Comma(Current_PT,2," ")+_ActCurrency;
   SMS+="\nBalace : "+Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" [ "+cD(ProfitPercen,2)+"% / "+cD(ProfitAVG,2)+" ]";
   SMS+="\nDD : "+cD(MaxDrawDown,2)+_ActCurrency+" [ "+string(DateDD)+" ]";
   SMS+="\nPT : "+cD(MaxProfit,2)+_ActCurrency;

   _getOrderPriceMaxMinHub();
   _getOrderCNT_AtiveHub();

   if(cntOrderBuy==0)
     {
      OrderStopLossBuy=0;
      ConfirmBuy=0;
      HLineDelete(0,"LINE_Point1");
      HLineDelete(0,"LINE_Save1");
      HLineDelete(0,"LINE_SL1");

      HLineDelete(0,"Text_MM1");
     }
   if(cntOrderSell==0)
     {
      OrderStopLossSell=0;
      ConfirmSell=0;
      HLineDelete(0,"LINE_Point2");
      HLineDelete(0,"LINE_Save2");
      HLineDelete(0,"LINE_SL2");

      HLineDelete(0,"Text_MM3");
     }
   if(cntOrderFollowBuy==0)
     {
      OrderStopLossFollowBuy=0;
      ConfirmBuyFollow=0;
      HLineDelete(0,"LINE_Point4");
      HLineDelete(0,"LINE_Save4");
      HLineDelete(0,"LINE_SL2");

      HLineDelete(0,"Text_MM2");
     }
   if(cntOrderFollowSell==0)
     {
      OrderStopLossFollowSell=0;
      ConfirmSellFollow=0;
      HLineDelete(0,"LINE_Point5");
      HLineDelete(0,"LINE_Save5");
      HLineDelete(0,"LINE_SL5");

      HLineDelete(0,"Text_MM4");
     }
   if(cntOrderBuy==0 && cntOrderFollowBuy==0)
     {
      HLineDelete(0,"LINE_SaveLink_Buy");
     }
   if(cntOrderSell==0 && cntOrderFollowSell==0)
     {
      HLineDelete(0,"LINE_SaveLink_SEll");
     }

   if(cntOrderFollowBuy>=1)
     {
      //printf(c(__LINE__));
      __OrderChkTP("Buy",cntOrderFollowBuy,4);
     }
   if(cntOrderFollowSell>=1)
     {
      //printf(c(__LINE__));
      __OrderChkTP("Sell",cntOrderFollowSell,5);
     }
   if(cntOrderBuy>=1)
     {
      //printf(c(__LINE__));
      __OrderChkTP("Buy",cntOrderBuy,1);
     }
   if(cntOrderSell>=1)
     {
      //printf(c(__LINE__));
      __OrderChkTP("Sell",cntOrderSell,2);
     }

/*sumOrderBuy=0;
   cntOrderBuy=sumOrderBuy;
   DepositBuy=cntOrderBuy;

   sumOrderSell=0;
   DepositSell=sumOrderSell;
   cntOrderSell=sumOrderSell;*/

   sumConfirm=ConfirmBuy+ConfirmSell+ConfirmBuyFollow+ConfirmSellFollow;

   SMS+="\n------";
   SMS+="\nNubtung: "+cI(cntOrder)+" : "+Comma(sumOrder,2," ");
   if(sumConfirm>0)
     {
      SMS+="*"+Comma(sumConfirm,2,"")+"*";
     }
   SMS+="\n";
//+------------------------------------------------------------------+
   if(cntOrderBuy>0 || cntOrderSell>0)
      SMS+="\nNormal-";

   SMS+=strZeroKey(" Buy [ "+cI(cntOrderBuy)+" ] : "+Comma(sumOrderBuy,2," "),cntOrderBuy)+strZero(ConfirmBuy,"*","*");

   if(cntOrderBuy>0 && cntOrderSell>0)
      SMS+=" |";

   SMS+=strZeroKey(" Sell [ "+cI(cntOrderSell)+" ] : "+Comma(sumOrderSell,2," "),cntOrderSell)+strZero(ConfirmSell,"*","*");
//+------------------------------------------------------------------+
   if(cntOrderFollowBuy>0 || cntOrderFollowSell>0)
      SMS+="\nFollow--";

   SMS+=strZeroKey(" Buy [ "+cI(cntOrderFollowBuy)+" ] : "+Comma(sumOrderFollowBuy,2," "),cntOrderFollowBuy)+strZero(ConfirmBuyFollow,"*","*");

   if(cntOrderFollowBuy>0 && cntOrderFollowSell>0)
      SMS+=" |";

   SMS+=strZeroKey(" Sell [ "+cI(cntOrderFollowSell)+" ] : "+Comma(sumOrderFollowSell,2," "),cntOrderFollowSell)+strZero(ConfirmSellFollow,"*","*");
//+------------------------------------------------------------------+
   SMS+="\n------";
   SMS+="\nBefore: "+cI(getMAprevious(1,50,2,5))+" After: "+cI(getMAprevious(1,50,0,1));
   Comment(SMS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderX_SelectOne(int v)
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
void OrderTrailingStopOriginal(int Ticket,double Trailing)
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
//---
   cntOrder=cntOrderBuy+cntOrderSell;
   cntOrder+=cntOrderFollowBuy+cntOrderFollowSell;
//---
   sumOrder=sumOrderBuy+sumOrderSell;
   sumOrder+=sumOrderFollowBuy+sumOrderFollowSell;
   sumOrder=NormalizeDouble(sumOrder,2);

//---
   if(sumOrder>=5)
     {
      _orderCloseActive(1);
      _orderCloseActive(2);
      _orderCloseActive(4);
      _orderCloseActive(5);
     }
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderCNT_Ative(int mn,string mode)
  {
   int CurrentMagic=_MagicEncrypt(mn);
   double c=0;
   double sum=0;
//---
   double _mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE); //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   double l=MarketInfo(Symbol(),MODE_LOTSIZE);
   double p=MarketInfo(Symbol(),MODE_POINT);
   double t=MarketInfo(Symbol(),MODE_TICKSIZE);
   double v=MarketInfo(Symbol(),MODE_TICKVALUE);
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==CurrentMagic && OrderType()<=1)
        {
         c++;
         //---
         if(OrderType()==OP_BUY)
           {
            if(_mode==0) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();

            if(_mode==1) sum+=(Bid-OrderOpenPrice())/p*v/t/l*OrderLots();
            if(_mode==2) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();
            sum+=OrderCommission()+OrderSwap();
           }
         if(OrderType()==OP_SELL)
           {
            if(_mode==0) sum+=(OrderOpenPrice()-Ask)/p*v*OrderLots();

            if(_mode==1) sum+=(OrderOpenPrice()-Ask)/p*v/t/l*OrderLots();
            if(_mode==2) sum+=(OrderOpenPrice()-Ask)/p*v*OrderLots();
            sum+=OrderCommission()+OrderSwap();
           }
         //---
        }
     }
//---
   if(mode=="Sum")
     {
      return sum;
     }
   if(mode=="Cnt")
     {
      return c;
     }
//---

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
int _isSarInAdj(double vSarUse,int Shift)
  {
   double v=NormalizeDouble(iSAR(Symbol(),0,vSarUse,0.2,Shift),Digits);
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
void _getOrderPriceMaxMinHub()
  {
//---Normal
   _PriceMax__Buy= _getOrderPriceMaxMin("Max",1);
   _PriceMin__Buy= _getOrderPriceMaxMin("Min",1);

   _PriceMax_Sell=_getOrderPriceMaxMin("Max",2);
   _PriceMin_Sell= _getOrderPriceMaxMin("Min",2);
//---Follow
   _PriceMax__FollowBuy= _getOrderPriceMaxMin("Max",4);
   _PriceMin__FollowBuy= _getOrderPriceMaxMin("Min",4);

   _PriceMax_FollowSell=_getOrderPriceMaxMin("Max",5);
   _PriceMin_FollowSell= _getOrderPriceMaxMin("Min",5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderPriceMaxMin(string v,int nm)
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
double _CalculateTrailing(int cnt,double Diff)
  {
   double Trailing=-1;

   Diff=Diff*MathPow(10,Digits);
   double MinTrai=MarketInfo(Symbol(),14);

/*if(cnt==1)
     {*/
   if(Diff<=200)
     {Trailing=150;}
   else if(Diff<=300)
     {Trailing=200;}
   else if(Diff<=400)
     {Trailing=150;}
/*else if(Diff<=500)
        {Trailing=100;}
      else if(Diff<=600)
        {Trailing=100;}
      else if(Diff<=700)
        {Trailing=100;}*/
   else if(Diff<=800)
     {Trailing=100;}
   else
     {
      Trailing=100;
/*Trailing=MarketInfo(Symbol(),14);
         double W=50;
         Trailing=Trailing*(2+(W/100));*/
     }
/*}
   else
     {*/
   if(cnt>1)
     {
      double W=50;
      Trailing=(Trailing/cnt)*(1+(W/100));
      if(Trailing<MinTrai)
        {
         Trailing=MinTrai;
        }
     }
// }
// }
   return NormalizeDouble(Trailing/MathPow(10,Digits),Digits);
//if(Diff>=Trailing)
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderStopLossBuy=0,OrderStopLossSell=0;
double OrderStopLossFollowBuy=0,OrderStopLossFollowSell=0;

double OrderStopLossBuy_Merge=0,OrderStopLossSell_Merge=0;

double OrderPointBuy=0,OrderPointSell=0;
double OrderPointFollowBuy=0,OrderPointFollowSell=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setOrderPoint(int v,double s)
  {
   switch(v)
     {
      case  1:
         OrderPointBuy=s;
      case  2:
         OrderPointSell=s;
      case  4:
         OrderPointFollowBuy=s;
      case  5:
         OrderPointFollowSell=s;
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __OrderChkTP(string v,int cnt,int mn)
  {
//   _LabelSet("Text_MM0",10,100,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(iSAR(Symbol(),0,0.009,0.2,0)-Bid,Digits),"CNT[DiffPrice/DiffSL | UseTrailing]");

   int _MagicNumber=_MagicEncrypt(mn);
   _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);

//printf(__FUNCTION__+" "+string(_MagicNumber));
   int Direct=-1;
   string TestLoop;
   double Point_=_CalculatePrice_Group(v,_MagicNumber);
   setOrderPoint(mn,Point_);

//---
   string Tooltip=v;
   if(mn==4 || mn==5)
      Tooltip+="Follow";
//---

   color _clrPoint=clrWhite,_clrSL=clrWhite;
   if(v=="Buy")
     {
      _clrPoint=clrRoyalBlue;
      _clrSL=clrLightSkyBlue;
     }
   else
     {
      _clrPoint=clrTomato;
      _clrSL=clrLightPink;
     }
   double DZP=0;
   double Trailing=-1;
   double TrailingStart=200;
   Trailing=Trailing/MathPow(10,Digits);
   TrailingStart=TrailingStart/MathPow(10,Digits);
   double SL=-1,SL2=-1,Diff=0,DiffSL=0;

   int _MagicNumber2=-1;
   int Direct2=-1;

   _getOrderCNT_AtiveHub();
//+------------------------------------------------------------------+
   bool CHK__Merge=false;

/*   double Point_Buy,Point_Sell;
   double LotBuy,LotSell;
   double Point_Merge=-1;

   
if(cntOrderFollowBuy>0 && cntOrderFollowSell>0)
     {
      //+------------------------------------------------------------------+
      Point_Buy=_CalculatePrice_Group("Buy",_MagicEncrypt(4));
      LotBuy=SumLot;

      Point_Sell=_CalculatePrice_Group("Sell",_MagicEncrypt(5));
      LotSell=SumLot;
      //+------------------------------------------------------------------+
      Point_Merge=_CalculatePrice_Merge(Point_Buy,LotBuy,Point_Sell,LotSell);
      //SL=Point_Merge;
      //SL2=SL-_SPREAD;

      _LabelSet("Text_SumLot_1",10,120,clrRed,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#P1-B: "+cD(Point_Buy,Digits)+" Lot: "+cD(LotBuy,2),"");
      _LabelSet("Text_SumLot_2",10,100,clrRed,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#P2-S: "+cD(Point_Sell,Digits)+" Lot: "+cD(LotSell,2),"");
      //merge

      _LabelSet("Text_SumLot_3",10,80,clrMagenta,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#"+cD(Point_Merge,Digits),"");
      HLineCreate_(0,"Point_Merge",0,Point_Merge,clrMagenta,0,1,false,true,false,0);
      //---

      Trailing=200/MathPow(10,Digits);

      if(LotBuy==LotSell && Point_Buy<Point_Sell)
        {
        Trailing=MarketInfo(Symbol(),14)/MathPow(10,Digits);
         double Ref=Bid+((Ask-Bid)/2);
         Diff=Ref-Point_Merge;
         TestLoop="== B: "+Point_Buy+" S: "+Point_Sell;
         if(Diff>=Trailing)//Point_Buy   Point_Sell
           {
            CHK__Merge=true;
            if((OrderStopLossBuy_Merge<Ref-Trailing || OrderStopLossBuy_Merge==0))
              {
               OrderStopLossBuy_Merge=Ref-Trailing;
               SL=OrderStopLossBuy_Merge;
               SL2=SL+_SPREAD;

               TestLoop+="=Buy";
              }

           }
         if(Diff<=(Trailing*(-1)))
           {
            CHK__Merge=true;
            if((OrderStopLossSell_Merge>Ref+Trailing || OrderStopLossSell_Merge==0))
              {
               OrderStopLossSell_Merge=Ref+Trailing;
               SL=OrderStopLossSell_Merge;
               SL2=SL-_SPREAD;

               TestLoop+="=Sell";
              }

           }
        }
      else
        {
         if(_PriceMin__FollowBuy<_PriceMin_FollowSell)
           {
            Diff=Bid-Point_Merge;
            TestLoop="*Buy";
            if(Diff>=Trailing)
              {
               CHK__Merge=true;
               if((OrderStopLossBuy_Merge<Bid-Trailing || OrderStopLossBuy_Merge==0))
                 {
                  OrderStopLossBuy_Merge=Bid-Trailing;
                  SL=OrderStopLossBuy_Merge;
                  SL2=SL+_SPREAD;

                 }

              }
           }
         else if(_PriceMax_FollowSell>_PriceMax__FollowBuy)
           {
            Diff=Point_Merge-Ask;
            TestLoop="*Sell";
            if(Diff>=Trailing)
              {
               CHK__Merge=true;
               if((OrderStopLossSell_Merge>Ask+Trailing || OrderStopLossSell_Merge==0))
                 {

                  OrderStopLossSell_Merge=Ask+Trailing;
                  SL=OrderStopLossSell_Merge;
                  SL2=SL-_SPREAD;

                 }

              }
           }
        }
     }
   _LabelSet("Text_Diff_Merge",500,50,clrRed,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#D_Merge: "+cD(Diff*MathPow(10,Digits),0)+" : "+cD(OrderStopLossBuy_Merge,Digits)+TestLoop+"  "+CHK__Merge,"");
*/
//+------------------------------------------------------------------+
   double SumSupporter=1.5;
   if(!CHK__Merge)
     {
      //HLineDelete(0,"Point_Merge");
      if("Buy"==v)
        {
         Direct=OP_BUY;
         Diff=Bid-Point_;
         //---
         if(mn==1)
           {
            DZP_Buy=Diff*MathPow(10,Digits);
            DZP=DZP_Buy;
           }
         else
           {
            DZP_BuyFollow=Diff*MathPow(10,Digits);
            DZP=DZP_BuyFollow;
           }

         Trailing=_CalculateTrailing(cnt,Diff);
         TestLoop="";
         //TrailingStart=Trailing;
         //if((Diff>=TrailingStart && cnt==1) || (Diff>=Trailing && cnt>1))
         if(Diff>=Trailing)
           {
            TestLoop="*";
            if((OrderStopLossBuy<Bid-Trailing || OrderStopLossBuy==0) && _MagicNumber==_MagicEncrypt(1))
              {
               OrderStopLossBuy=Bid-Trailing;
               SL=OrderStopLossBuy;

               HLineCreate_(0,"LINE_Save"+cI(mn),"SL"+Tooltip+" \n"+cD(SL,Digits),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderBuy>0 && cntOrderFollowSell>0 && sumOrderBuy+sumOrderFollowSell>SumSupporter)
                 {
                  _MagicNumber2=5;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
               else if(cntOrderBuy>0 && cntOrderSell>0 && sumOrderBuy+sumOrderSell>SumSupporter)
                 {
                  _MagicNumber2=2;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
              }

            if((OrderStopLossFollowBuy<Bid-Trailing || OrderStopLossFollowBuy==0) && _MagicNumber==_MagicEncrypt(4))
              {
               OrderStopLossFollowBuy=Bid-Trailing;
               SL=OrderStopLossFollowBuy;

               HLineCreate_(0,"LINE_Save"+cI(mn),"SL"+Tooltip+" \n"+cD(SL,Digits),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderFollowBuy>0 && cntOrderSell>0 && sumOrderFollowBuy>sumOrderSell>=SumSupporter)
                 {
                  _MagicNumber2=2;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
               else if(cntOrderFollowBuy>0 && cntOrderFollowSell>0 && sumOrderFollowBuy+sumOrderFollowSell>=SumSupporter)
                 {

                  _MagicNumber2=5;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
              }
            //HLineCreate_(0,"LINE_SL"+c(mn),0,SL,clrPaleGreen,0,1,true,true,false,0);
           }
         if(OrderStopLossBuy>0)
            DiffSL=(Bid-OrderStopLossBuy)*MathPow(10,Digits);
         if(OrderStopLossFollowBuy>0)
            DiffSL=(Bid-OrderStopLossFollowBuy)*MathPow(10,Digits);

         if(mn==1)
            _LabelSet("Text_MM1",10,65,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n Buy ["+cD(DZP_Buy,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM2",10,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n BuyF ["+cD(DZP_BuyFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

         //---
         string chk_Text_MSL="Off";
         if(
            (OrderStopLossBuy>0 && OrderStopLossFollowBuy>0) && 
            (OrderStopLossBuy>OrderPointBuy && OrderStopLossBuy>OrderPointFollowBuy) && 
            (OrderStopLossFollowBuy>OrderPointBuy && OrderStopLossFollowBuy>OrderPointFollowBuy)
            )
           {
            chk_Text_MSL="On";
            if(OrderStopLossBuy>=OrderStopLossFollowBuy)
              {
               OrderStopLossFollowBuy=OrderStopLossBuy;
               SL=OrderStopLossFollowBuy;

               HLineCreate_(0,"LINE_SaveLink_Buy","SL BuyLink \n"+cD(SL,Digits),0,SL,clrLime,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=_MagicEncrypt(1);
               _MagicNumber2=4;
               Direct=OP_BUY;
               Direct2=OP_BUY;
              }
            if(OrderStopLossFollowBuy>=OrderStopLossBuy)
              {
               OrderStopLossBuy=OrderStopLossFollowBuy;
               SL=OrderStopLossBuy;

               HLineCreate_(0,"LINE_SaveLink_Buy","SL SellLink \n"+cD(SL,Digits),0,SL,clrLime,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=_MagicEncrypt(1);
               _MagicNumber2=4;
               Direct=OP_BUY;
               Direct2=OP_BUY;
              }

           }
         _LabelSet("Text_MSL_B",200,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# SL Buy : "+cD(OrderStopLossBuy,Digits)+" | "+cD(OrderStopLossFollowBuy,Digits)+"   "+chk_Text_MSL,"");
         //---
        }
      else if("Sell"==v)
        {
         Direct=OP_SELL;
         Diff=(Point_-Ask);
         //---
         if(mn==2)
           {
            DZP_Sell=Diff*MathPow(10,Digits);
            DZP=DZP_Sell;
           }
         else
           {
            DZP_SellFollow=Diff*MathPow(10,Digits);
            DZP=DZP_SellFollow;
           }

         Trailing=_CalculateTrailing(cnt,Diff);
         TestLoop="";
         //TrailingStart=Trailing;
         //if((Diff>=TrailingStart && cnt==1) || (Diff>=Trailing && cnt>1))
         if(Diff>=Trailing)
           {
            TestLoop="*";
            if((OrderStopLossSell>Ask+Trailing || OrderStopLossSell==0) && _MagicNumber==_MagicEncrypt(2))
              {

               OrderStopLossSell=Ask+Trailing;
               SL=OrderStopLossSell;

               HLineCreate_(0,"LINE_Save"+cI(mn),"LINE_Save"+cI(mn),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderFollowBuy>0 && cntOrderSell>0 && sumOrderFollowBuy+sumOrderSell>SumSupporter)
                 {
                  _MagicNumber2=4;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
               else if(cntOrderBuy>0 && cntOrderSell>0 && sumOrderBuy+sumOrderSell>SumSupporter)
                 {
                  _MagicNumber2=1;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
              }
            if((OrderStopLossFollowSell>Ask+Trailing || OrderStopLossFollowSell==0) && _MagicNumber==_MagicEncrypt(5))
              {

               OrderStopLossFollowSell=Ask+Trailing;
               SL=OrderStopLossFollowSell;

               HLineCreate_(0,"LINE_Save"+cI(mn),"LINE_Save"+cI(mn),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderBuy>0 && cntOrderFollowSell>0 && sumOrderBuy+sumOrderFollowSell>SumSupporter)
                 {
                  _MagicNumber2=1;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
               else if(cntOrderFollowBuy>0 && cntOrderFollowSell>0 && sumOrderFollowBuy+sumOrderFollowSell>SumSupporter)
                 {
                  _MagicNumber2=4;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }

              }
            //HLineCreate_(0,"LINE_SL"+c(mn),0,SL,clrTomato,0,1,true,true,false,0);
           }

         if(OrderStopLossSell>0)
            DiffSL=(OrderStopLossSell-Ask)*MathPow(10,Digits);
         if(OrderStopLossFollowSell>0)
            DiffSL=(OrderStopLossFollowSell-Ask)*MathPow(10,Digits);

         if(mn==2)
            _LabelSet("Text_MM3",10,35,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n Sell ["+cD(DZP_Sell,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM4",10,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n SellF ["+cD(DZP_SellFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

         string chk_Text_MSL="Off";
         if(
            (OrderStopLossSell>0 && OrderStopLossFollowSell>0) && 
            (OrderStopLossSell<OrderPointSell && OrderStopLossSell<OrderPointFollowSell) && 
            (OrderStopLossFollowSell<OrderPointSell && OrderStopLossFollowSell<OrderPointFollowSell)
            )
           {
            chk_Text_MSL="On";
            if(OrderStopLossSell<=OrderStopLossFollowSell)
              {
               OrderStopLossFollowSell=OrderStopLossSell;
               SL=OrderStopLossFollowSell;

               HLineCreate_(0,"LINE_SaveLink_SEll","LINE_SaveLink_SEll1",0,SL,clrMagenta,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=_MagicEncrypt(2);
               _MagicNumber2=5;
               Direct=OP_SELL;
               Direct2=OP_SELL;
              }
            if(OrderStopLossFollowSell<=OrderStopLossSell)
              {
               OrderStopLossSell=OrderStopLossFollowSell;
               SL=OrderStopLossSell;

               HLineCreate_(0,"LINE_SaveLink_SEll","LINE_SaveLink_SEll2",0,SL,clrMagenta,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=_MagicEncrypt(2);
               _MagicNumber2=5;
               Direct=OP_SELL;
               Direct2=OP_SELL;
              }
           }
         _LabelSet("Text_MSL",200,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# SL Sell : "+string(OrderStopLossSell)+" | "+string(OrderStopLossFollowSell)+"   "+chk_Text_MSL,"");

         //---
        }
      //---
      HLineCreate_(0,"LINE_Point"+cI(mn),Tooltip+" | "+cD(DZP,0)+"p \n"+cD(Point_,Digits),0,Point_,_clrPoint,0,1,0,true,false,0);
      //---
     }
   else
     {
      _MagicNumber=_MagicEncrypt(4);
      Direct=OP_BUY;
      _MagicNumber2=5;
      Direct2=OP_SELL;
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
         _OrderModifyForTrailing(SL,_MagicNumber,int(Direct));
         if(SL2>0)
           {
            SL2=NormalizeDouble(SL2,Digits);
            _OrderModifyForTrailing(SL2,_MagicEncrypt(_MagicNumber2),int(Direct2));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderModifyForTrailing(double _TP,int _MagicNumber,int _OrderType)
  {
//double SumDeposit=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()) && ((int)OrderType()==_OrderType))
        {

         if((_OrderType==OP_BUY && OrderStopLoss()<_TP) ||
            (_OrderType==OP_SELL && OrderStopLoss()>_TP)||
            OrderStopLoss()==0)
           {

            if(!OrderModify(OrderTicket(),OrderOpenPrice(),_TP,0,0))//SL
              {
               sz=OrderModify(OrderTicket(),OrderOpenPrice(),0,_TP,0);//TP
              }
           }
        }
     }
   return true;
  }

double SumLot;
//+------------------------------------------------------------------+
double _CalculatePrice_Group(string Direction,int _MagicNumber)
  {
   _getOrderCNT_AtiveHub();
//---
   int CNT;
   if(Direction=="Buy")
     {CNT=cntOrderBuy;}
   else
     {CNT=cntOrderSell;}
//---
   double SumDeposit=0;
   double SumProduct=0,
   MinLot = 99999,
   Result = 0,
   Temp   = 0;

   SumLot=0;
   SumDeposit=0;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderMagicNumber()==_MagicNumber) && (OrderSymbol()==Symbol()))
        {
         //+------------------------------------------------------------------+
         SumDeposit+=_ConfirmProfitCalculate(OrderType(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderCommission(),OrderSwap());
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
   _ConfirmProfitSet(_MagicNumber,SumDeposit);
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
double _ConfirmProfitCalculate(int _OrderType,double Lot,double OpenPrice,double SL,double TP,double Com,double Swap)
  {
   double sum=-1,Tragrt;
//---
   double _mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE);   //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   double l=MarketInfo(Symbol(), MODE_LOTSIZE);
   double p=MarketInfo(Symbol(), MODE_POINT);
   double t=MarketInfo(Symbol(),MODE_TICKSIZE);
   double v=MarketInfo(Symbol(),MODE_TICKVALUE);

//---
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
      //sum=((Tragrt-OpenPrice)*MathPow(10,Digits))*Lot;

      if(_mode==0) sum=(Tragrt-OpenPrice)/p*v*Lot;

      if(_mode==1) sum=(Tragrt-OpenPrice)/p*v/t/l*Lot;
      if(_mode==2) sum=(Tragrt-OpenPrice)/p*v*Lot;

      sum+=Com+Swap;
     }
   else if(_OrderType==1)
     {
      //sum=((OpenPrice-Tragrt)*MathPow(10,Digits))*Lot;

      if(_mode==0) sum=(OpenPrice-Tragrt)/p*v*Lot;

      if(_mode==1) sum=(OpenPrice-Tragrt)/p*v/t/l*Lot;
      if(_mode==2) sum=(OpenPrice-Tragrt)/p*v*Lot;

      sum+=Com+Swap;
     }
   return sum;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ConfirmProfitSet(int nm,double var)
  {
   _MagicDecode(nm);
//Print(__FUNCTION__+" "+nm+" "+OrderPin);
   switch(OrderPin)
     {
      case  1:
         ConfirmBuy=var;
         break;
      case  2:
         ConfirmSell=var;
         break;
      case  4:
         ConfirmBuyFollow=var;
         break;
      case  5:
         ConfirmSellFollow=var;
         break;
      default:
         Print(__FUNCTION__+" error is default");
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_Group(int v)
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
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_GroupH(int v)
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
/*if(c>lotsMsx)
     {
      c=lotsMsx;
     }*/
   return NormalizeDouble(c/4,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Workday,Workdayx;
string SMS_Workday;
//+------------------------------------------------------------------+
void _StayFriday()
  {
   int H=TimeHour(TimeLocal());
   int M=TimeMinute(TimeLocal());
   int _DayOfWeek=TimeDayOfWeek(TimeLocal());
//Print(__FUNCTION__+_DayOfWeek);
   if((_DayOfWeek<=0 && H<=7 /*&& M<=00*/) || (_DayOfWeek>=5 && H>=16/* && M<=00*/))
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

//---
   string _strBoolYN;
   if(Workday)
      _strBoolYN="Workday";
   else
      _strBoolYN="Holidays";
//---

   SMS_Workday=_StayFriday(_DayOfWeek)+":"+string(_DayOfWeek)+" "+cFillZero(H)+"h:"+cFillZero(M)+"m | Running "+string(cntRunDay)+" day is a "+_strBoolYN;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _StayFriday(int var)
  {
   switch(var)
     {
      case 0:
         return "SUN";
      case 1:
         return "MON";
      case 2:
         return "TUE";
      case 3:
         return "WED";
      case 4:
         return "THU";
      case 5:
         return "FRI";
      case 6:
         return "SAT";
     }
   return "default.";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _MagicEncrypt(int Type)
  {
   string v=string(Magicnumber)+string(Type);
   return int(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderMagic_,OrderPin;
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
bool _OrderLookup(string OP,int v,double Mark,double Mark2)
  {
   int CurrentMagic=_MagicEncrypt(v);

//_LabelSet("Text_Lookup",300,80,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(Mark2,Digits),OP);

   double Range=NormalizeDouble(100/MathPow(10,Digits),Digits);
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         //if(((Mark+Range)>OrderOpenPrice()) && ((Mark-Range)<OrderOpenPrice()))
         if(((Mark-Range)<OrderOpenPrice()) && (Mark+Range)>OrderOpenPrice() && OP=="Buy")
           {
            return false;
           }
         else if(((Mark+Range)>OrderOpenPrice()) && (Mark-Range)<OrderOpenPrice() && OP=="Sell")
           {
            return false;
           }
        }
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  _iCCI(
            string       symbol,           // symbol 
            int          timeframe,        // timeframe 
            int          period,           // averaging period 
            int          applied_price,    // applied price 
            int          shift,            // shift 
            double       set               // seting 
            )
  {

   double constant=iCCI(symbol,timeframe,period,applied_price,shift);

   if(constant>set || constant<(set*(-1)))
     {
      return false;
     }
   else
     {
      return true;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderTicketClose[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderCloseActive(int v)
  {
   ArrayResize(OrderTicketClose,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());

      if(OrderMagic_==Magicnumber && OrderPin==v && (OrderSymbol()==Symbol()) && (OrderType()<=1))
        {
         OrderTicketClose[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(OrderTicketClose);i++)

     {
      if(OrderTicketClose[i]>0)
        {
         if(OrderSelect(OrderTicketClose[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            if(GetLastError()==0){OrderTicketClose[i]=0;}
           }
        }
     }
   ArrayResize(OrderTicketClose,1);
  }
//+------------------------------------------------------------------+
