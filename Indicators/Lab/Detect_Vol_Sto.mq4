//+------------------------------------------------------------------+
//|                                               Detect_Vol_Sto.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <MQLMySQL.mqh>
#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetMillisecondTimer(6000);
   OnTimer();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   OnTimer();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   string CommentStr="";

   double sto_Main=iStochastic("",0,5,3,3,MODE_SMA,0,0,0);
   double sto_Signal=iStochastic("",0,5,3,3,MODE_SMA,0,1,0);

   sto_Main=NormalizeDouble(sto_Main,4);
   sto_Signal=NormalizeDouble(sto_Signal,4);

   CommentStr+="sto_Main: "+c(sto_Main,4)+"\n";
   CommentStr+="sto_Sign : "+c(sto_Signal,4)+"\n";

   Comment(CommentStr);
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
