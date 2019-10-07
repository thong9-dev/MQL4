//+------------------------------------------------------------------+
//|                                                         Main.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "SuperIndicatorParser.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   Main();

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
//|                                                                  |
//+------------------------------------------------------------------+
void Main()
  {
   SuperIndicatorParser parser;
   
   if(parser.parse())
     {
      for(int i=parser.Total()-1; i>=0; i--)
        {
         Signal *s=parser[i];
         int ticket=OrderSend(
                              s.symbol, s.order_type, 0.1,
                              s.price_entry, 0, s.price_sl, s.price_tp
                              );
         if(ticket<0)
           {
            Print(_LastError);
           }
        }
     }
  }
//+------------------------------------------------------------------+
