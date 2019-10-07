//+------------------------------------------------------------------+
//|                                                    Learn_OOP.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtTestOOP
  {
   double            A;
   double            B;
   double            Arr[1];

   void Reset()
     {
      A = 0;
      B = 0;
      ArrayInitialize(Arr,0);
     };
   int Resize(int size)
     {
      return ArrayResize(Arr,size,0);
     };
   int Size()
     {
      return ArraySize(Arr);
     };
  };
gtTestOOP _TestOOP_Buy;
gtTestOOP _TestOOP_Sel;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//---
   _TestOOP_Buy.A=123;
   _TestOOP_Sel.B=321;

   _TestOOP_Buy.Reset();

   Print(_TestOOP_Buy.A);
   Print(_TestOOP_Buy.B);
   Print(_TestOOP_Sel.A);
   Print(_TestOOP_Sel.B);


   _TestOOP_Buy.Arr[0]=168;
   Print(_TestOOP_Buy.Arr[0]);
   
  
   Print( _TestOOP_Buy.Resize(5));
   Print("Size: "+_TestOOP_Buy.Size());

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

  }
//+------------------------------------------------------------------+
