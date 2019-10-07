//+------------------------------------------------------------------+
//|                                                    TP_Bet369.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, TP-Member"
#property link      "https://goo.gl/T9myHV"
#property version   "1.00"
#property strict    "Inspired by the FBS50"

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>
#define _OP_BUY     10
#define _OP_SELL    50


extern int MGN=9;

extern double MinLots=0.1;
extern int ADX_Period=0;//Open_ADX_Period //0-4

double Current_BALANCE;
int cntOrder;
double sumOrder;
int cntOrderBuy,cntOrderSell;
double sumOrderBuy,sumOrderSell;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern double STL=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   setTemplate();

   if(cntOrder==0)
     {
      Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);

      BetCoin_=NormalizeDouble((Current_BALANCE/BetCnt__),2);

      double Rang=BetCoin_/MinLots;

      double RangMin=MarketInfo(Symbol(),MODE_STOPLEVEL)*10;
      if(Rang<RangMin) Rang=RangMin;

      Bet_RR=NormalizeDouble((Rang)/MathPow(10,Digits),Digits);

     }
   Comment(
           "BetCoin_:"+BetCoin_
           +"\nSTL: "+MarketInfo(Symbol(),MODE_STOPLEVEL)
           );
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(_iNewBar(0))
     {
      double PV=__Hub_SumPV(_iADX(50));
      //double PV=__Hub_SumPV(_iBar_getStatus(1,0,1));

      //---
      if(cntOrder==0)
        {
         if(_PVMarket(OP_BUY,PV,0))
           {
            OrderSends_Bet(MGN,"Bet",OP_BUY,_OP_BUY,cntOrderBuy,Ask,MinLots);
           }
         if(_PVMarket(OP_SELL,PV,0))
           {
            OrderSends_Bet(MGN,"Bet",OP_SELL,_OP_SELL,cntOrderSell,Bid,MinLots);
           }
        }
     }
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
double __Hub_SumPV(double pv1)
  {
   double v=pv1;

   if(v>100)
      return 100;
   if(v<(-100))
      return -100;

   return NormalizeDouble(v,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _PVMarket(int OP,double PV,double Market)
  {

   if(OP==OP_BUY && PV>=Market)
     {
      return true;
     }
   if(OP==OP_SELL && PV<=Market*(-1))
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _iBar_getStatus(double PV,ENUM_TIMEFRAMES TF,int v)
  {
   double vOpen=iOpen(NULL,TF,v);
   double vClose=iClose(NULL,TF,v);
   if(vOpen<vClose)//Lime
     {
      return PV*(-1);
      //return PV;
     }
   else if(vOpen>vClose)//Red
     {
      //return PV*(-1);
      return PV;
     }
   return 0;
  }
//+------------------------------------------------------------------+
double _iADX(double PV)
  {
   double XX=iADX(NULL,0,ADX_Period,PRICE_CLOSE,0,1);

   double UP=iADX(NULL,0,ADX_Period,PRICE_CLOSE,1,1);
   double DW=iADX(NULL,0,ADX_Period,PRICE_CLOSE,2,1);

   bool XX_=XX>UP && XX>DW;
   bool UP_=(UP>DW) && XX_;
   bool DW_=(UP<DW) && XX_;

   if(UP_)
     {
      return PV;
     }
   else if(DW_)
     {
      return PV*(-1);
     }
   return 0;
  }
int cntOrderBuyMax,cntOrderSellMax;
int cntOrderFollowBuyMax,cntOrderFollowSellMax;
extern double Nav=0.35;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __Hub_Order_CNTSum()
  {
   cntOrderBuy=int(_getOrderCNT_Ative(MGN,_OP_BUY,"Cnt"));
   cntOrderSell=int(_getOrderCNT_Ative(MGN,_OP_SELL,"Cnt"));

//---
   if(cntOrderBuy>cntOrderBuyMax)cntOrderBuyMax=cntOrderBuy;
   if(cntOrderSell>cntOrderSellMax)cntOrderSellMax=cntOrderSell;

//if(cntOrderFollowBuy>cntOrderFollowBuyMax)cntOrderFollowBuyMax=cntOrderFollowBuy;
//if(cntOrderFollowSell>cntOrderFollowSellMax)cntOrderFollowSellMax=cntOrderFollowSell;
//---
   sumOrderBuy=_getOrderCNT_Ative(MGN,_OP_BUY,"Sum");
   sumOrderSell=_getOrderCNT_Ative(MGN,_OP_SELL,"Sum");

//sumOrderFollowBuy=_getOrderCNT_Ative(MGN,4,"Sum");
//sumOrderFollowSell=_getOrderCNT_Ative(MGN,5,"Sum");
//---
   cntOrder=cntOrderBuy+cntOrderSell;
//cntOrder+=cntOrderFollowBuy+cntOrderFollowSell;
//---
   sumOrder=sumOrderBuy+sumOrderSell;
//sumOrder+=sumOrderFollowBuy+sumOrderFollowSell;

   sumOrder=NormalizeDouble(sumOrder,2);
//---
   Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
   if(Current_BALANCE<=0)Current_BALANCE=1;
//+------------------------------------------------------------------+
/*if(sumOrder>(BetCoin_*(BetCnt__*Nav)))
     {
      _orderCloseActive(OP_BUY);
      _orderCloseActive(OP_SELL);
     }*/
//---

  }
extern double BetCnt__=25;//BetCnt //0-50
extern double Rate_Win=1;
extern double Rate_Lose=1;

double BetCoin_,Bet_RR;
//---
double BetPrice_TP=0;
double BetPrice_SL=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _Calculate_TPSL_RR(int OP_Dir,double Pr,double Lot)
  {
   if(OP_Dir==OP_BUY)
     {
      BetPrice_TP=Pr+(Bet_RR*Rate_Win);
      BetPrice_SL=Pr-(Bet_RR*Rate_Lose);
     }
   else
     {
      BetPrice_TP=Pr-(Bet_RR*Rate_Win);
      BetPrice_SL=Pr+(Bet_RR*Rate_Lose);
     }

   BetPrice_TP=NormalizeDouble(BetPrice_TP,Digits);
   BetPrice_SL=NormalizeDouble(BetPrice_SL,Digits);

   P(__LINE__,"TS","RR",Bet_RR,Digits);

   P(__LINE__,"TS","TP",BetPrice_TP,"Pr",Pr,"SL",BetPrice_SL,Digits);
  }
//+------------------------------------------------------------------+
int OrderSends_Bet(int _MGN,string _EAName,int OP_Trade,int Case,int Cnt,double Price,double Lot)
  {
   int Dir=-1;
   string Dirs="";
   if(OP_Trade==0 || OP_Trade==2 || OP_Trade==4)
     {
      Dir=0;
      Dirs="B";
     }
   if(OP_Trade==1 || OP_Trade==3 || OP_Trade==5)
     {
      Dir=1;
      Dirs="S";
     }
//---
   _Calculate_TPSL_RR(OP_Trade,Price,Lot);

   P(__LINE__,"RR","TP",BetPrice_TP,"SL",BetPrice_SL,"RR",Bet_RR,Digits);

   int MGN_=_MagicEncrypt(_MGN,Case,0);
   return OrderSend(Symbol(),OP_Trade,Lot,Price,100,BetPrice_SL,BetPrice_TP,"",MGN_,0);

//---
   return -1;
  }
//+------------------------------------------------------------------+
