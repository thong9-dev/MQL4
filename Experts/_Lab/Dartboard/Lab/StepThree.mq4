//+------------------------------------------------------------------+
//|                                                    StepThree.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "https://www.facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict

#include "PanelDialog2Original.mqh"

CControlsDialog ExtExpert;
//--- input parameters
input bool     InpMail=false;          // Notify by email
input bool     InpPush=false;          // Notify by push
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//EventSetTimer(60);
/*ExtMail=InpMail;
   ExtPush=InpPush;
   ExtAlert=InpAlert;

   ExtLots=InpLots;
   ExtTakeProfit=InpTakeProfit;
   ExtTrailingStop=InpTrailingStop;
   ExtMACDOpenLevel=InpMACDOpenLevel;
   ExtMACDCloseLevel=InpMACDCloseLevel;
   ExtMATrendPeriod=InpMATrendPeriod;*/
//--- create all necessary objects
//if(!ExtExpert.Init())
//return(INIT_FAILED);
//--- create application dialog
   if(!ExtExpert.Create(0,"Notification",0,100,100,360,380)){}
//return(INIT_FAILED);
//--- run application
   //if(!ExtExpert.Run()){}
//return(INIT_FAILED);
//--- succeed
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
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
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
   ExtExpert.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
