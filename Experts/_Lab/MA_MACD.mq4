//+------------------------------------------------------------------+
//|                                                      MA_MACD.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//double Macd=iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double Macd=0;
   int n=0;
   string CMM="";

   for(int i=0; i<14; i++)
     {

      //CMM+=DoubleToStr(iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,i),Digits+1)+"\n";

      Macd+=iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
      n++;
     }

//double MAofRSIBuffer=iMAOnArray(Macd,0,14,0,MODE_SMA,0);

//double Macd_Get=iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   CMM+="Sum : "+Macd+"\n";
   CMM+="MA : "+DoubleToStr(Macd/n,Digits+1)+"\n";

   Comment(CMM);


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
