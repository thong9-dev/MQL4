//+------------------------------------------------------------------+
//|                                              Scan_Votalality.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/DrawHistogram.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

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

   double Full_D=25;

   int FIRST_B=int(ChartGetInteger(ChartID(),CHART_FIRST_VISIBLE_BAR,0));
   int VISIBLE_B=int(ChartGetInteger(ChartID(),CHART_VISIBLE_BARS,0));
   int WIDTH_B=int(ChartGetInteger(ChartID(),CHART_WIDTH_IN_BARS,0));

   double Test_P=500/MathPow(10,Digits);
   string strHisto="Histo#";

   ObjectsDeleteAll(ChartID(),strHisto,0,OBJ_TREND);

//DrawHistogram(FIRST_B,VISIBLE_B,WIDTH_B,Full_D,100,strHisto+"Full",Bid,clrWhite);
//DrawHistogram(FIRST_B,VISIBLE_B,WIDTH_B,Full_D,50,strHisto+"Per",Bid+Test_P,clrLime);

   double Price_MIN=ChartGetDouble(ChartID(),CHART_PRICE_MIN,0);
   double Price_MAX=ChartGetDouble(ChartID(),CHART_PRICE_MAX,0);

   for(int i=0;Price_MIN<Price_MAX;i++)
     {
      double d=10*i;
      if(d>=100)
         d=100;

      DrawHistogram(FIRST_B,VISIBLE_B,WIDTH_B,Full_D,d,strHisto+"H"+c(i),Price_MIN,clrLime);
      Price_MIN+=Test_P;
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
