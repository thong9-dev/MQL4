//+------------------------------------------------------------------+
//|                                              Hidden StopLoss.mq4 |
//|                                Copyright 2016, M2P Designing Co. |
//|                                      https://LPeter_Sc@yahoo.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2016, M2P Designing Co."
#property link      "https://LPeter_Sc@yahoo.com"
#property version   "1.00"
#property strict


input    int     StopLoss=7;
input    int   TakeProfit=4;
input    int     Slippage=2;
input    int        Magic=280456;

double TP=0,SL=0,TR;
//+------------------------------------------------------------------+
//| Hidden StopLoss Calculations                                     |
//+------------------------------------------------------------------+
void StpLoss()
  {
   double MyPoint=Point;
   if(Digits==3 || Digits==5) MyPoint=Point*10;
   TP=TakeProfit*MyPoint;
   SL=StopLoss*MyPoint;

   double OrdP=0,OrdTP=0,OrdSL=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==Magic && Symbol()==OrderSymbol())
           {
            OrdP=OrderProfit()-MathAbs(OrderSwap())-MathAbs(OrderCommission());
            OrdSL=(-1)*SL*OrderLots()*MarketInfo(OrderSymbol(),MODE_TICKVALUE)/Point;
            OrdTP=TP*OrderLots()*MarketInfo(OrderSymbol(),MODE_TICKVALUE)/Point;

            if(OrdP>OrdTP || OrdP<OrdSL)
              {
               if(OrderType()==OP_BUY)
                  bool OrdClP=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,clrGreen);
               if(OrderType()==OP_SELL)
                  bool OrdClL=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,clrYellow);
              }
           }
     }
  }
//+------------------------------------------------------------------+
