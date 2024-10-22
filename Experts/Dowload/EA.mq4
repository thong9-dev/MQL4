//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


extern int    MagicNumber=1;
extern double Lotsize = 0.01;
extern int    MaxOrder=1;
input int MA1=7;
input int MA2=14;
input int MA3=21;
input ENUM_MA_METHOD Method=1;
input ENUM_APPLIED_PRICE Price=0;
input int Sto1=5;
input int Sto2=3;
input int Sto3=3;

bool res=false;
int CountB,CountS,TT,TTT; double MoneyB,MoneyS;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Month()==9)
     {
      Alert("หมดเวลา");
      //return(0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   CountB=0;CountS=0;MoneyB=0;MoneyS=0;
   for(int i=0; i<OrdersTotal();i++)
     {
      res=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderType()==OP_BUY){CountB++;MoneyB=MoneyB+OrderProfit();}
         if(OrderType()==OP_SELL){CountS++;MoneyS=MoneyS+OrderProfit();}
        }
     }

   double A1=iMA(Symbol(),0,MA1,0,Method,Price,0); double A2=iMA(Symbol(),0,MA1,0,Method,Price,1);
   double B1=iMA(Symbol(),0,MA2,0,Method,Price,0); double B2=iMA(Symbol(),0,MA2,0,Method,Price,1);
   double C1=iMA(Symbol(),0,MA3,0,Method,Price,0); double C2=iMA(Symbol(),0,MA3,0,Method,Price,1);
   double E1=iStochastic(Symbol(),0,Sto1,Sto2,Sto3,0,0,0,0); double E2=iStochastic(Symbol(),0,Sto1,Sto2,Sto3,0,0,1,0);

   if(A1>A2 && B1>B2 && C1>C2 && E1>E2){TTT=1;}else if(A1<A2 && B1<B2 && C1<C2 && E1<E2){TTT=2;}else {TTT=3;}

   if(TTT==1 && CountB<MaxOrder){res=OrderSend(Symbol(),OP_BUY,Lotsize,Ask,3,0,0,"Kuy",MagicNumber,0,clrGreen);}

   if(TTT==2 && CountS<MaxOrder){res=OrderSend(Symbol(),OP_SELL,Lotsize,Bid,3,0,0,"Kuy",MagicNumber,0,clrRed);}

   if(TTT==3 && MoneyB>0){ CloseBuy();}if(TTT==3 && MoneyS>0){ CloseSell();} if(TTT==2 && CountB>0){ CloseBuy();}if(TTT==1 && CountS>0){ CloseSell();}

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseBuy()
  {
   for(int X3=OrdersTotal()-1;X3>=0;X3--)
     {
      res=OrderSelect(X3,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
        {
         res=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),9),3,clrNONE);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseSell()
  {
   for(int X3=OrdersTotal()-1;X3>=0;X3--)
     {
      res=OrderSelect(X3,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
        {
         res=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),3,clrNONE);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
