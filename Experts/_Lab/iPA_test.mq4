//+------------------------------------------------------------------+
//|                                                     iPA_test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   int c=18;
   double PinBar_UP=_iCustom(NULL,0,"My/PriceAction",0,c);
   double PinBar_DW=_iCustom(NULL,0,"My/PriceAction",1,c);

   double Inside_UP=_iCustom(NULL,0,"My/PriceAction",2,c);
   double Inside_DW=_iCustom(NULL,0,"My/PriceAction",3,c);

   double Eng_UP=_iCustom(NULL,0,"My/PriceAction",4,c);
   double Eng_DW=_iCustom(NULL,0,"My/PriceAction",5,c);

   _LabelSet("Text_PA",CORNER_LEFT_LOWER,10,35,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+
             "# PV PinBar "+PinBar_UP+" Inside "+Inside_UP+" Eng "+Eng_UP+"","");
   _LabelSet("Text_PA2",CORNER_LEFT_LOWER,10,20,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+
             "# PV PinBar "+PinBar_DW+" Inside "+Inside_DW+" Eng "+Eng_DW+"","");

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _iCustom(string Symbol_,ENUM_TIMEFRAMES TF,string path,int index,int c)
  {
   double v=iCustom(Symbol_,TF,path,index,c);
   if(v>=2147483647)
     {
      return 0;
     }
   return v;
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
