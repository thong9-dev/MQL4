//+------------------------------------------------------------------+
//|                                                        FBS50.mq4 |
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
//|                                                                  |
//+------------------------------------------------------------------+
enum _enum_Trade
  {
   _enum_TradeA=2,// Both
   _enum_TradeB=0, // Long
   _enum_TradeC=1, // Short
  };
//+------------------------------------------------------------------+
enum _enum_TrueFalse
  {
   t=True,// True
   f=False,// False
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _enum_ModeStrategy
  {
   _enum_ModeStrategyA=0,// Normal
   _enum_ModeStrategyB=1,// Scalping
  };
//---
extern _enum_Trade OP_Trade=_enum_TradeA;
extern _enum_ModeStrategy Mode_Strategy=_enum_ModeStrategyA;

extern _enum_TrueFalse Now=f;

extern int CntAtive=2;
extern double TP=50;

double Current_BALANCE;
int cntOrder;
double sumOrder;
int cntOrderBuy,cntOrderSell;
double sumOrderBuy,sumOrderSell;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   __Hub_Order_CNTSum();
   Comment("CNT Buy"+cI(cntOrderBuy)+"\n"+
           "CNT Sell"+cI(cntOrderSell)+"\n"+
           "Ative"+cI(CntAtive)+"\n"+
           cB(OP_Trade));

   if(_iNewBar(1) || Now)
     {
      if(cntOrderBuy>=CntAtive && EnableTrade(OP_BUY))
        {
         _OrderModify(OP_BUY,cntOrderBuy);
        }
      if(cntOrderSell>=CntAtive && EnableTrade(OP_SELL))
        {
         _OrderModify(OP_SELL,cntOrderSell);
        }
     }

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
//|                                                                  |
//+------------------------------------------------------------------+
bool EnableTrade(int OP)
  {
   if(OP_Trade==2)
      return true;
   if(OP_Trade==0 && OP==OP_BUY)
      return true;
   if(OP_Trade==1 && OP==OP_SELL)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
void __Hub_Order_CNTSum()
  {
   cntOrderBuy=int(_getOrderCNT_Ative(OP_BUY,-1,"Cnt"));
   cntOrderSell=int(_getOrderCNT_Ative(OP_SELL,-1,"Cnt"));

//---
//if(cntOrderBuy>cntOrderBuyMax)cntOrderBuyMax=cntOrderBuy;
//if(cntOrderSell>cntOrderSellMax)cntOrderSellMax=cntOrderSell;

//if(cntOrderFollowBuy>cntOrderFollowBuyMax)cntOrderFollowBuyMax=cntOrderFollowBuy;
//if(cntOrderFollowSell>cntOrderFollowSellMax)cntOrderFollowSellMax=cntOrderFollowSell;
//---
//sumOrderBuy=_getOrderCNT_Ative(OP_BUY,-1,"Sum");
//sumOrderSell=_getOrderCNT_Ative(OP_SELL,-1,"Sum");

//sumOrderFollowBuy=_getOrderCNT_Ative(MGN,4,"Sum");
//sumOrderFollowSell=_getOrderCNT_Ative(MGN,5,"Sum");
//---
   cntOrder=cntOrderBuy+cntOrderSell;
//cntOrder+=cntOrderFollowBuy+cntOrderFollowSell;
//---
   sumOrder=sumOrderBuy+sumOrderSell;
//sumOrder+=sumOrderFollowBuy+sumOrderFollowSell;

   sumOrder=NormalizeDouble(sumOrder,2);
//---
   Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
   if(Current_BALANCE<=0)Current_BALANCE=1;
//+------------------------------------------------------------------+
/*if(sumOrder>(BetCoin_*(BetCnt__*Nav)))
     {
      _orderCloseActive(OP_BUY);
      _orderCloseActive(OP_SELL);
     }*/
//---

  }
//+------------------------------------------------------------------+
bool _OrderModify(int Type,int cnt)
  {
   bool z;
   double _TPp=_Price_Group(Type,cnt);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)continue;
      if(OrderSymbol()==Symbol() && 
         OrderType()==Type && OrderType()<=1)
        {
         if(!OrderModify(OrderTicket(),OrderOpenPrice(),_TPp,0,0))//SL
           {
            z=OrderModify(OrderTicket(),OrderOpenPrice(),0,_TPp,0);//TP
           }
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
double setTPSL(int OP,string Mode,double a,double b)
  {
   if((OP==OP_BUY && Mode=="TP") || (OP==OP_SELL && Mode=="SL"))
      return NormalizeDouble(a+b,Digits);
   else if((OP==OP_SELL && Mode=="TP") || (OP==OP_BUY && Mode=="SL"))
      return NormalizeDouble(a-b,Digits);;
   return -1;
  }
//+------------------------------------------------------------------+
double _Price_Group(int Type,double cnt)
  {

   double
   SumProduct=0,
   SumLot=0,
   Result=0,
   A=0,B=0;

   int n=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()==Symbol() && 
         OrderType()==Type && OrderType()<=1)
        {
         //+------------------------------------------------------------------+
         //SumDeposit+=_ConfirmProfitCalculate(OrderType(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderCommission(),OrderSwap());
         //+------------------------------------------------------------------+
         SumProduct+=OrderLots()*OrderOpenPrice();
         SumLot+=OrderLots();
         n++;
        }
     }
//+------------------------------------------------------------------+     
//_ConfirmProfitSet(pin,SumDeposit);
//+------------------------------------------------------------------+

   if(SumLot!=0)
      A=SumProduct/SumLot;
   else
      return 1;
//---
   double
   range=TP/MathPow(10,Digits),
   Carry=cnt/MathPow(10,Digits);

   if(Mode_Strategy==1)
     {
      range=range/cnt;
     }
//---

   if(Type==OP_BUY)
      Result=A+Carry+range;
   else
      Result=A-Carry-range;

   return NormalizeDouble(Result,Digits);
  }
//+------------------------------------------------------------------+
