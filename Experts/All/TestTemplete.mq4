//+------------------------------------------------------------------+
//|                                                 TestTemplete.mq4 |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //string v;
   //v=TerminalInfoString(TERMINAL_DATA_PATH)+"\\templates\\A_NumChok 2-15.tpl";
   //v=TerminalInfoString(TERMINAL_DATA_PATH)+"\\A_NumChok 2-15.tpl";
   //Comment(ChartID());
   //ChartApplyTemplate(0,v);
   //Print("2["+GetLastError()+"]"+v);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//int OnCalculate(const int rates_total,
//                const int prev_calculated,
//                const datetime &time[],
//                const double &open[],
//                const double &high[],
//                const double &low[],
//                const double &close[],
//                const long &tick_volume[],
//                const long &volume[],
//                const int &spread[])
//  {
////---
//
////--- return value of prev_calculated for next call
//   return(rates_total);
//  }
//+------------------------------------------------------------------+
