//+------------------------------------------------------------------+
//|                                              Breakeven EA v1.mq4 |
//|                                        Copyright © 2011, tigpips |
//|                                                tigpips@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, tigpips"
#property link      "tigpips@gmail.com"

extern int Break_Even_After_X_Pips = 15;
extern bool useMagicNumber = false;
extern int Magic = 1234567;

int init()
{
   if(Digits == 5)
   {
      Break_Even_After_X_Pips = Break_Even_After_X_Pips * 10;
   }

   return(0);
}

int deinit()
{

   return(0);
}

int start()
{
   AdjustStopLoss();
   return(0);
}
//+------------------------------------------------------------------+

void AdjustStopLoss()
{
   for(int cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(useMagicNumber == true)
      {
         if (OrderMagicNumber()==Magic && OrderStopLoss() != OrderOpenPrice())
         {
            if(( OrderProfit() - OrderCommission() ) / OrderLots() / MarketInfo( OrderSymbol(), MODE_TICKVALUE ) >= Break_Even_After_X_Pips)
            {
               if(OrderType()==OP_SELL){
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);
               }
               if(OrderType()==OP_BUY){
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue);
               }  
            }        
         }
      }
      else if(useMagicNumber == false)
      {
         if(OrderStopLoss() != OrderOpenPrice())
         {         
            if(( OrderProfit() - OrderCommission() ) / OrderLots() / MarketInfo( OrderSymbol(), MODE_TICKVALUE ) >= Break_Even_After_X_Pips)
            {
               if(OrderType()==OP_SELL){
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);
               }
               if(OrderType()==OP_BUY){
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue);
               }  
            }                       
         }
      }
   }
}