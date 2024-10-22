//+------------------------------------------------------------------+
//|                                            NumChok_Valentine.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>

string EAVer="0.50a";
string EAName="NC-"+EAVer+" "+strSymbolShortName();

extern double Fund=300;//Fund
extern double BetPer=10;//PercentBet/N
extern int MGN=6;//MagicNumber

double Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
double Current_BALANCE_Test=Current_BALANCE;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double Span=200/MathPow(10,Digits);
double End_=200/MathPow(10,Digits);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   setTemplate();
   _PriceEnd=Bid-End_;
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
double _Price,_PriceEnd,TP;
int s;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(_iNewBar(0))
     {
      _Price=_PriceEnd;
      for(int i=0;i<10;i++)
        {
         _Price+=Span;
         TP=_Price+Span;
         s=_getOrderType(MGN,1,i);
         if(s<0)
           {
            OrderSends(MGN,EAName,OP_BUYSTOP,1,i,_Price,0,TP,0.5);
           }
         else if(s>1)
           {
            _OrderModify(1,i,_Price,TP);
           }
        }
     }
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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
int cntOrder;
double sumOrder;
double sumConfirm;

int cntOrderBuy,cntOrderSell;
double sumOrderBuy,sumOrderSell;

double _PriceMax_Sell,_PriceMin_Sell;
double _PriceMax__Buy,_PriceMin__Buy;

int cntOrderFollowBuy,cntOrderFollowSell;
double sumOrderFollowBuy,sumOrderFollowSell;

double _PriceMax_FollowSell,_PriceMin_FollowSell;
double _PriceMax__FollowBuy,_PriceMin__FollowBuy;

int cntOrderBuyMax,cntOrderSellMax;
int cntOrderFollowBuyMax,cntOrderFollowSellMax;
extern double Nav=0.35;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __Hub_Order_CNTSum()
  {
   cntOrderBuy=int(_getOrderCNT_Ative(MGN,1,"Cnt"));
   cntOrderSell=int(_getOrderCNT_Ative(MGN,2,"Cnt"));

   cntOrderFollowBuy=int(_getOrderCNT_Ative(MGN,4,"Cnt"));
   cntOrderFollowSell=int(_getOrderCNT_Ative(MGN,5,"Cnt"));
//---
   if(cntOrderBuy>cntOrderBuyMax)cntOrderBuyMax=cntOrderBuy;
   if(cntOrderSell>cntOrderSellMax)cntOrderSellMax=cntOrderSell;

   if(cntOrderFollowBuy>cntOrderFollowBuyMax)cntOrderFollowBuyMax=cntOrderFollowBuy;
   if(cntOrderFollowSell>cntOrderFollowSellMax)cntOrderFollowSellMax=cntOrderFollowSell;
//---
   sumOrderBuy=_getOrderCNT_Ative(MGN,1,"Sum");
   sumOrderSell=_getOrderCNT_Ative(MGN,2,"Sum");

   sumOrderFollowBuy=_getOrderCNT_Ative(MGN,4,"Sum");
   sumOrderFollowSell=_getOrderCNT_Ative(MGN,5,"Sum");
//---
   cntOrder=cntOrderBuy+cntOrderSell;
   cntOrder+=cntOrderFollowBuy+cntOrderFollowSell;
//---
   sumOrder=sumOrderBuy+sumOrderSell;
   sumOrder+=sumOrderFollowBuy+sumOrderFollowSell;

   sumOrder=NormalizeDouble(sumOrder,2);
//---
   Current_BALANCE=_Account_Balance();
   if(Current_BALANCE<=0)Current_BALANCE=1;
//+------------------------------------------------------------------+
//if(((sumOrder/Current_BALANCE)*100)>=BetPer*3)

/*if(sumOrder>(BetCoin_*(BetCnt__*Nav)))
     {
      _orderCloseActive(1);
      _orderCloseActive(2);
      _orderCloseActive(4);
      _orderCloseActive(5);
     }*/
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _Account_Balance()
  {
   return AccountInfoDouble(ACCOUNT_BALANCE);
   if(IsTesting())
     {
      return Current_BALANCE_Test;
     }
   else
     {
      return AccountInfoDouble(ACCOUNT_BALANCE);
     }
   return NULL;
  }
//+------------------------------------------------------------------+
bool _OrderModify(int Pin,int Sub,double OpenPrice,double _TP,)
  {
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)
         continue;
      //---
      _MagicDecode(MGN,OrderMagicNumber());
      if(OrderMagic_Key==MGN &&
         OrderMagic_Pin==Pin &&
         OrderMagic_Sub==Sub &&
         OrderSymbol()==Symbol())
        {
         OpenPrice=NormalizeDouble(OpenPrice,Digits);
         _TP=NormalizeDouble(_TP,Digits);
         if(OpenPrice!=OrderOpenPrice() && _TP!=OrderTakeProfit())
           {
            return OrderModify(OrderTicket(),OpenPrice,0,_TP,0);//TP
           }

        }
     }
   return false;
  }
//+------------------------------------------------------------------+
