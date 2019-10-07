//+------------------------------------------------------------------+
//|                                                        Gride.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Driraction
  {
   Driraction_0=OP_BUY,//BUY
   Driraction_1=OP_SELL,//SELL
   Driraction_3=-1//BUY+SELL
  };
extern double PriceStart=0;
extern double cnt=8;
extern double diff=500;
extern Driraction OP_dir=Driraction_0;
extern color clrBuy=clrRoyalBlue;
extern color clrSel=clrTomato;

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   double d=diff*Point;

   double p=PriceStart;
   HLineCreate_(0,"LINE_RP","LINE_RP "+cD(p,Digits),0,p,clrYellow,0,1,true,false,false,0);

   if(OP_dir==OP_BUY || OP_dir==-1)
     {
      for(int i=1;i<=cnt;i++)
        {
         p+=d;
         HLineCreate_(0,"LINE_Buy"+cFillZero(i),"LINE_Buy"+cFillZero(i)+"|"+cD(p,Digits),0,p,clrBuy,3,1,true,false,false,0);

        }
     }
   p=PriceStart;
   if(OP_dir==OP_SELL || OP_dir==-1)
     {
      for(int i=1;i<=cnt;i++)
        {
         p-=d;
         HLineCreate_(0,"LINE_Sel"+cFillZero(i),"LINE_Sel"+cFillZero(i)+"|"+cD(p,Digits),0,p,clrSel,3,1,true,false,false,0);

        }
     }

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
