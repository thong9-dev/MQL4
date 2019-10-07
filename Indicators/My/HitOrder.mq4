//+------------------------------------------------------------------+
//|                                                     HitOrder.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 1
#property indicator_maximum 100

#include <Tools/Method_Tools.mqh>

int windex;
string ExtName="HitOrder#";
string ExtNameFull="HitOrder";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorShortName(ExtNameFull);
   windex=WindowFind(ExtNameFull);

//--- indicator buffers mapping
   int SizeX=195;
   int SizeY=20;
   int ScalX=160,XStep=SizeX+5;
   int ScalY=5,YStep=SizeY+5;

   _setBUTTON(ExtName+"BTN_H_BuyRuler",windex,CORNER_LEFT_UPPER,SizeX,SizeY,ScalX,ScalY,false,10,clrBlack,clrRoyalBlue,"Buy");ScalX+=XStep;

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

//--- return value of prev_calculated for next call
   return(rates_total);
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
