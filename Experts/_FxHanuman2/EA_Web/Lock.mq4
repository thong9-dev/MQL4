//+------------------------------------------------------------------+
//|                                                         Lock.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#define NHM_GateName       "Gateway.php" 
//#define NHM_SaverHost     "http://www.fxhanuman.com/web/eafx/"
#define NHM_SaverHost      "http://127.0.0.1/HNM/"
#define NHM_Product        "EA0001"
#define NHM_Name        "lock"
#define NHM_Encode         true
//---
#include <Hanuman_API.mqh>
CHanuman Hanuman;
//---
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

   Hanuman._Init(NHM_SaverHost,NHM_GateName,NHM_Name,NHM_Product,NHM_Encode);

   Print("@--------------------------");
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

   Hanuman._Deinit();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int _Bar=iBars("",0);
bool Tick=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Test()
  {
   Tick=!Tick;

   return (Tick)?" ++++++++++ ":" ---------- ";
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   int Bar=Bars("",0);
   if(_Bar!=Bar && false)
     {
      _Bar=Bar;

      if(Hanuman._Check())
        {
         Comment(Test());
        }
     }
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
   Hanuman._ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
