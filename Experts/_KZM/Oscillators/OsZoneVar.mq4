//+------------------------------------------------------------------+
//|                                                    OsZoneVar.mq4 |
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
   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);
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
double OsZone=5;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   string CMM="";
//---

   double RSI=iRSI(Symbol(),PERIOD_CURRENT,14,PRICE_CLOSE,0);

   int OP=-1;

   double Mod=MathMod(RSI,OsZone);

   if(Mod<=OsZone/10)
     {

      OP=OP_BUY;
      int Zone=CommZone(RSI);
      //---
      ChkOrderInZone_Close(Zone);
      //---

      if(ChkOrderInZone(Zone))
        {
         int ticket=OrderSend(Symbol(),OP_BUY,1,Ask,3,0,0,string(Zone),258,0);
        }

     }
   else
     {

     }


   CMM+="\n"+"RSI : "+DoubleToStr(RSI,4);
   CMM+="\n"+"Mod : "+DoubleToStr(Mod,Digits);
   CMM+="\n"+"OP : "+string(OP);

   CMM+="\n"+"CommZone : "+string(CommZone(RSI));

   Comment(CMM);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChkOrderInZone(int CMM)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)&&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==258)
        {
         if(CMM==int(OrderComment()))
           {
            return false;
           }
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChkOrderInZone_Close(int CMM)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)&&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==258)
        {
         if(CMM>int(OrderComment()))
           {
            double OrderHold=OrderProfit()+OrderSwap()+OrderCommission();
            if(OrderHold>=0)
              {
               int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
               int ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),3,clrNONE);
              }
           }
        }
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CommZone(double RSI)
  {
   return int(int(RSI/OsZone)*OsZone);
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
