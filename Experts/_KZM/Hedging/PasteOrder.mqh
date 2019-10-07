//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include "Hedging_Remon - A1.mq4";
#include "Method_MQL4.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderCheckModule()
  {
//+----------------------- Sell
   if(cntOrderSell>=2)
     {
      Sum__SellGR=0;Sum__SellUP=0;Sum__SellDW=0;

      ArrayResize(OrderTicketClose__SellGR,OrdersTotal());
      for(int i=0;i<OrdersTotal();i++)
         OrderTicketClose__SellGR[i]=0;

      _getPriceMaxMin();
      strTicketX_Sell="";
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==369 && (OrderSymbol()==Symbol()) && OrderProfit()>0)
           {
            Sum__SellGR+=OrderProfit();
            OrderTicketClose__SellGR[pos]=OrderTicket();
            strTicketX_Sell+="/"+c(OrderTicket());
           }

         if(_PriceMax_Sell==OrderOpenPrice())
           {
            Sum__SellUP=OrderProfit();
            OrderTicketClose__SellUP[0]=OrderTicket();
           }
         if(_PriceMin_Sell==OrderOpenPrice())
           {
            Sum__SellDW=OrderProfit();
            OrderTicketClose__SellDW[0]=OrderTicket();
           }

         if(_PriceMax2_Sell==OrderOpenPrice())
           {
            Sum__SellUP2=OrderProfit();
            OrderTicketClose__SellUP2[0]=OrderTicket();
           }
         if(_PriceMin2_Sell==OrderOpenPrice())
           {
            Sum__SellDW2=OrderProfit();
            OrderTicketClose__SellDW2[0]=OrderTicket();
           }
        }
     }

//+----------------------- Buy
   if(cntOrderBuy>=2)
     {
      Sum__BuyGR=0;Sum__BuyUP=0;Sum__BuyDW=0;

      ArrayResize(OrderTicketClose__BuyGR,OrdersTotal());
      for(int i=0;i<OrdersTotal();i++)
         OrderTicketClose__BuyGR[i]=0;

      _getPriceMaxMin();
      strTicketX_Buy="";
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==true)
           {
            if(OrderMagicNumber()==285 && (OrderSymbol()==Symbol()) && OrderProfit()>0)
              {
               Sum__BuyGR+=OrderProfit();
               OrderTicketClose__BuyGR[pos]=OrderTicket();
               strTicketX_Buy+="/"+c(OrderTicket());
              }

            if(_PriceMax__Buy==OrderOpenPrice())
              {
               Sum__BuyUP=OrderProfit();
               OrderTicketClose__BuyUP[0]=OrderTicket();
              }
            if(_PriceMin__Buy==OrderOpenPrice())
              {
               Sum__BuyDW=OrderProfit();
               OrderTicketClose__BuyDW[0]=OrderTicket();
              }
            if(_PriceMax2__Buy==OrderOpenPrice())
              {
               Sum__BuyUP2=OrderProfit();
               OrderTicketClose__BuyUP2[0]=OrderTicket();
              }
            if(_PriceMin2__Buy==OrderOpenPrice())
              {
               Sum__BuyDW2=OrderProfit();
               OrderTicketClose__BuyDW2[0]=OrderTicket();
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
