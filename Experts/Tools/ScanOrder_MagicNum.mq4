//+------------------------------------------------------------------+
//|                                           ScanOrder_MagicNum.mq4 |
//|                                 Copyright 2019,Golden Master TH. |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Golden Master TH."
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   int MN=-1;

   string str="";

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && 
         OrderSymbol()==Symbol() && 
         OrderMagicNumber()==MN
         )
        {
         str+="\n"+OrderTicket()+"t |  "+OrderMagicNumber()+"mn ";
        }
     }

   Comment(str);

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
