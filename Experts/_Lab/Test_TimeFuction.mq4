//+------------------------------------------------------------------+
//|                                             Test_TimeFuction.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestOut(string in1,string &out,string &out2)
  {
   out="Out";
   out2="Out2";

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
   datetime _TimeCurrent=TimeCurrent();
   datetime _TimeGMT=TimeGMT();
   datetime _TimeLocal=TimeLocal();

   uint _start=GetTickCount();

//---
   string CMM="";
   CMM+="\n ACCOUNT_NAME | "+AccountInfoString(ACCOUNT_NAME);
   CMM+="\n _TimeCurrent | "+_TimeCurrent;
   CMM+="\n _TimeGMT | "+_TimeGMT;
   CMM+="\n _TimeLocal | "+_TimeLocal;
   CMM+="\n _start | "+_start;

   Comment(CMM);
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
//+------------------------------------------------------------------+
