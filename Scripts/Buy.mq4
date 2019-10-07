//+------------------------------------------------------------------+
//|                                                          Buy.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int MG=0;
   double SL=0;
   double TP=0;
   string CM="ScriptMake";
   bool res=OrderSend(Symbol(),OP_BUY,0.01,Ask,10,SL,TP,CM,MG);
  }
//+------------------------------------------------------------------+
