//+------------------------------------------------------------------+
//|                                                       NewBar.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "The indicator identifies a new bar"
#property indicator_chart_window
#property indicator_plots               0
#include "PanelDialog.mqh"
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;
//--- input parameters
input bool     bln_mail=false;      // Notify by email
input bool     bln_push=false;      // Notify by push
input bool     bln_alert=true;      // Notify by alert
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//--- create application dialog
   if(!ExtDialog.Create(0,"Notification",0,100,100,230,210))
      return(INIT_FAILED);
//--- run application
   if(!ExtDialog.Run())
      return(INIT_FAILED);
//---
   ExtDialog.SetCheck(0,bln_mail);
   ExtDialog.SetCheck(1,bln_push);
   ExtDialog.SetCheck(2,bln_alert);
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
   static datetime prev_time;
//--- revert access to array time[] - do it like in timeseries 
   ArraySetAsSeries(time,true);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      prev_time=time[0];
      return(rates_total);
     }
//---
   if(time[0]>prev_time)
      Print("New bar!");
//---
   prev_time=time[0];
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
