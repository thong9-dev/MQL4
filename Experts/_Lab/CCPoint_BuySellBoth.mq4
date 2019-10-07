//+------------------------------------------------------------------+
//|                                          CCPoint_BuySellBoth.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
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
   double SumPro_Buy=0,SumPro_Sel=0;
   double SumLot_Buy=0,SumLot_Sel=0;
   double Cnt_Buy=0,Cnt_Sel=0;

   double Price_Buy=0,Price_Sel=0;
   double Price_Both=0;
   double SumLot_Both=0;
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            SumPro_Buy+=OrderLots()*OrderOpenPrice();
            SumLot_Buy+=OrderLots();
            Cnt_Buy++;
           }
         if(OrderType()==OP_SELL)
           {
            SumPro_Sel+=OrderLots()*OrderOpenPrice();
            SumLot_Sel+=OrderLots();
            Cnt_Sel++;
           }

        }
     }
   Price_Buy=NormalizeDouble(SumPro_Buy/SumLot_Buy,Digits);
   Price_Sel=NormalizeDouble(SumPro_Sel/SumLot_Sel,Digits);

//-----

   Price_Both=(SumPro_Buy+SumPro_Sel)/(SumLot_Buy+SumLot_Sel);
//---

   SumLot_Both=SumLot_Buy-SumLot_SelW;
//-----

   string MSN="";
   MSN+="Buy: "+c(Price_Buy,Digits)+" ["+c(SumLot_Buy,2)+"]\n";
   MSN+="Sell : "+c(Price_Sel,Digits)+" ["+c(SumLot_Sel,2)+"]\n";
   MSN+="---\n";
   MSN+="Sell : "+c(Price_Sel,Digits)+" ["+c(SumLot_Both,2)+"]\n";

   Comment(MSN);
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
