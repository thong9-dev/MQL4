//+------------------------------------------------------------------+
//|                                                     PipValue.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(1000);

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
   OnTimer();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   string mms="";

   string _ACCOUNT_CURRENCY=AccountInfoString(ACCOUNT_CURRENCY);
   string _SYMBOL_CURRENCY=StringSubstr(Symbol(),0,3);

   mms+="_ACCOUNT_CUR: "+_ACCOUNT_CURRENCY+"\n";
   mms+="_SYMBOL_CUR: "+_SYMBOL_CURRENCY+"\n";
//-------------------------------------

   double obj_DraftPrice=ObjectGetDouble(0,"DraftPrice",OBJPROP_PRICE);

   double Traget_1=obj_DraftPrice;
   double Traget_2=Bid;

   double Lot=0.1;
   double ContractSize=MarketInfo(Symbol(),MODE_LOTSIZE);
//-------------------------------------

   double D=(Traget_2-Traget_1);
   double _Result=0,_Result_2=0;
   string _Result_CURRENCY="",_Result_2_CURRENCY="";

   double Rate_1=0,Rate_2=0,Rate_3=0,Rate_4=0;
   double Rate_Use=0;
   string Rate_CurrencyPair="";


   if(_ACCOUNT_CURRENCY==_SYMBOL_CURRENCY)
     {
      //---
      _Result=(D/Bid)*(Lot*ContractSize);
      //---
      _Result_CURRENCY=_SYMBOL_CURRENCY;
     }
   else
     {
        {
         Rate_1=MarketInfo(_SYMBOL_CURRENCY+_ACCOUNT_CURRENCY,MODE_BID);
         Rate_2=MarketInfo(_ACCOUNT_CURRENCY+_SYMBOL_CURRENCY,MODE_BID);
         if(Rate_1>0)
           {
            _Result_2=_Result*Rate_1;
            Rate_CurrencyPair=_SYMBOL_CURRENCY+_ACCOUNT_CURRENCY+" [*]1";
           }
         if(Rate_2>0)
           {
            _Result_2=_Result/Rate_2;
            Rate_CurrencyPair=_ACCOUNT_CURRENCY+_SYMBOL_CURRENCY+" [/]2";
           }
           {
            _Result_CURRENCY=_SYMBOL_CURRENCY;
            _Result_2_CURRENCY=_ACCOUNT_CURRENCY;
           }
        }
     }
//---
   mms+="-------\n";
   mms+="_Result_1: "+c(_Result,2)+" "+_Result_CURRENCY+"\n";
   mms+="-------\n";
   mms+="_Result_2: "+c(_Result_2,2)+" "+_Result_2_CURRENCY+"\n";
   mms+="CurPair: "+Rate_CurrencyPair+"\n";
   Comment(mms);
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
string c(double v,int Digit)
  {
   if(v==0)
      return "0";
   else
      return DoubleToString(v,Digit);

  }
//+------------------------------------------------------------------+
