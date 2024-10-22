//+------------------------------------------------------------------+
//|                               histogram_bid_ask_2_indicators.mq5 |
//|                                           Copyright 2016, DC2008 |
//|                              http://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2016, DC2008"
#property link          "http://www.mql5.com/ru/users/dc2008"
#property version       "1.00"
#property description   "Histogram bid and ask prices."
#property description   "The statistical characteristics of the histogram."
//---
input int   period_ATR=14;             // Averaging period of iATR 
input int   period_fast=12;            // Averaging period fast of iMACD 
input int   period_slow=26;            // Averaging period of slow iMACD 
//---- indicator buffers
double      ATR[];
double      MAIN[];
double      SIGNAL[];
//---- handles for indicators
int         iATR_handle;
int         iMACD_handle;
//---
#property indicator_chart_window
//--- Количество буферов для расчета индикатора
#property indicator_buffers 2
//--- Количество графических серий в индикаторе
#property indicator_plots   2
//--- plot 1
#property indicator_label1  "ask"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot 2
#property indicator_label2  "bid"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//---
double      Buffer1[];
double      Buffer2[];
//---
#include <Histogram.mqh>
//---
CHistogram h_Ask("ask",3000,2,clrRed,clrLightCoral,true,true);
CHistogram h_Bid("bid",3000,2,clrBlue,clrSkyBlue,false,true);
CHistogram h_iATR("iATR",3000,2,clrRed,clrLightCoral,true,true,1);
CHistogram h_iMACD_SIGNAL("iMACD.SIGNAL",3000,2,clrRed,clrLightCoral,true,true,2);
CHistogram h_iMACD_MAIN("iMACD.MAIN",3000,2,clrBlue,clrSkyBlue,false,true,2);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   iATR_handle=iATR(_Symbol,0,_Period,period_ATR);
   iMACD_handle=iMACD(_Symbol,0,period_fast,period_slow,_Period,PRICE_CLOSE);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(MAIN,true);
   ArraySetAsSeries(SIGNAL,true);
   h_iATR.SetDigits(6);
   h_iMACD_SIGNAL.SetDigits(6);
   h_iMACD_MAIN.SetDigits(6);
//---
   ArraySetAsSeries(Buffer1,true);
   ArraySetAsSeries(Buffer2,true);
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   ObjectsDeleteAll(0,-1,-1);
   ChartRedraw();
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
   ArraySetAsSeries(time,true);

   MqlTick price;
   SymbolInfoTick(_Symbol,price);
   
   CopyBuffer(iATR_handle,0,0,1,ATR);
   CopyBuffer(iMACD_handle,0,0,1,MAIN);
   CopyBuffer(iMACD_handle,1,0,1,SIGNAL);

//--- Histogram Ask
   h_Ask.DrawHistogram(price.ask,time[0]);
   sVseries vs_Ask=h_Ask.HistogramCharacteristics();
   Buffer1[0]=vs_Ask.Mean;
   h_Ask.DrawMean(vs_Ask.Mean,time[0],true);
   h_Ask.DrawSD(vs_Ask,time[0],5);

//--- Histogram Bid
   h_Bid.DrawHistogram(price.bid,time[0]);
   sVseries vs_Bid=h_Bid.HistogramCharacteristics();
   Buffer2[0]=vs_Bid.Mean;
   h_Bid.DrawMean(vs_Bid.Mean,time[0],true);
   h_Bid.DrawSD(vs_Bid,time[0],5);

//--- Histogram indicator iATR
   h_iATR.DrawHistogram(ATR[0],time[0]);
   sVseries vs_ATR=h_iATR.HistogramCharacteristics();
   h_iATR.DrawMean(vs_ATR.Mean,time[0],true,true);
//   h_iATR.DrawSD(vs_ATR,time[0],10,clrBlue);

//--- Histogram indicator iMACD line SIGNAL
   h_iMACD_SIGNAL.DrawHistogram(SIGNAL[0],time[0]);

//--- Histogram indicator iMACD line MAIN
   h_iMACD_MAIN.DrawHistogram(MAIN[0],time[0]);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,-1,-1);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
