//+------------------------------------------------------------------+
//|                                                     Lap_Time.mq4 |
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
   OnTick();
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
   double Set="1.00";


//---
   string CMM="\n";

   CMM+="Set :: "+Set+" | "+MinuteToSec(Set)+"\n";

   CMM+="\n";

   int Limit=MinuteToSec(Set);

   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)&&(OrderSymbol()==Symbol()))
        {
         datetime d=TimeCurrent()-OrderOpenTime();
         bool boo=d>Limit;
         CMM+=OrderTicket()+"# "+OrderOpenTime()+" | "+int(d)+" | boo: "+boo+"\n";
        }
     }

   Comment(CMM);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MinuteToSec(double Set)
  {
   string result[];
   double Raw=0;
   if(StringSplit(DoubleToStr(Set,2),StringGetCharacter(".",0),result)>1)
      Raw=double(result[1])/60;
   return int((double(result[0])+Raw)*60);
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
