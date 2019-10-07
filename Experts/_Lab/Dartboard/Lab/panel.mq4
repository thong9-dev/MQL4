//+------------------------------------------------------------------+
//|                                                        panel.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "https://www.facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict

#include "PanelDialog.mqh"
CControlsDialog ExtDialog;
//--- input parameters
input bool     InpMail=false;          // Notify by email
input bool     InpPush=false;          // Notify by push
input bool     InpAlert=true;          // Notify by alert
//---
input double InpLots          =0.1; // Lots
input int    InpTakeProfit    =50;  // Take Profit (in pips)
input int    InpMACDCloseLevel=2;   // MACD close level (in pips)
input int    InpMATrendPeriod =26;  // MA trend period

//--- ext variables
bool           ExtMail;
bool           ExtPush;
bool           ExtAlert;

double         ExtLots;
int            ExtTakeProfit;
int            ExtTrailingStop;
int            ExtMACDOpenLevel;
int            ExtMACDCloseLevel;
int            ExtMATrendPeriod;
//---
int ExtTimeOut=10; // time out in seconds between trade operations
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!ExtDialog.Create(0,"Notification",0,50,50,180,160))
      return(INIT_FAILED);
//--- run application
   if(!ExtDialog.Run())
      return(INIT_FAILED);
//---
   ExtDialog.SetCheck(0,InpMail);
   ExtDialog.SetCheck(1,InpPush);
   ExtDialog.SetCheck(2,InpAlert);

//---
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
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
