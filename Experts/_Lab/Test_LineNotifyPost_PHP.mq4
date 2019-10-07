//+------------------------------------------------------------------+
//|                                               Test_LineNoti2.mq4 |
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

//+------------------------------------------------------------------+
//|                                                                  |
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
void LineNotifyPHP(string Message)
  {
   string HOST="http://127.0.0.1/MyCopyTrade/LineNotify.php";
   string Token="sWyKPFRBeHSky0dCucuHpPIjxd93gn10QTl4731UgD5";

   string str="MQL4_Token="+Token+
              "&MQL4_Message="+Message;

   string Header=NULL;
   string ResultHeader;
   char   SentData[];  // Data array to send POST requests 
   char   ResultData[];

   ArrayResize(SentData,StringToCharArray(str,SentData,0,WHOLE_ARRAY,CP_UTF8)-1);

   ResetLastError();
   int res=WebRequest("POST",HOST,Header,5000,SentData,ResultData,ResultHeader);
   int err=GetLastError();
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
