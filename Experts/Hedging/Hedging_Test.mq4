//+------------------------------------------------------------------+
//|                                                 Hedging_Test.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Method_MQL4.mqh";

extern double Risk=1;
extern double Reward=2;
extern double Bet=5;
int TP_B=500;
int TP_S=500;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- create timer
   EventSetTimer(60);
   iFuntion();
   _setBUTTON("BTN_SELLp","SELL_Pending",0,120,30,240,140,10,clrBlack,clrRed);
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
   _setBUTTON_State();
   iFuntion();
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
double input_TP;
double input_SL;
double input_PR;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BTNs_SELLp=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      if(sparam=="BTN_BUY")
        {
         ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);

         bool z=OrderSend(Symbol(),2,0.01,input_PR,100,input_SL,input_TP,"Rosegold["+c(1)+"]",1);
        }
      if(sparam=="BTN_SELLp")
        {
         if(BTNs_SELLp==0)
           {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrYellow);
            BTNs_SELLp=1;
            //---

            ArrowRightPriceCreate(0,"SelectPriceSL_SellPending",0,0,Bid-(500/MathPow(10,Digits)),clrRed,0,2,false,true,false);
            ArrowRightPriceCreate(0,"SelectPrice_SellPending",0,0,Bid-(600/MathPow(10,Digits)),clrYellow,0,2,false,true,false);
            ArrowRightPriceCreate(0,"SelectPriceTP_SellPending",0,0,Bid-(700/MathPow(10,Digits)),clrLime,0,2,false,true,false);

            ArrowRightPriceMove2(0,"SelectPrice_SellPending",0,100,100);
           }
         else if(BTNs_SELLp==1)
           {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            BTNs_SELLp=0;
            //---
            double Price=NormalizeDouble(ObjectGetDouble(0,"SelectPrice_SellPending",OBJPROP_PRICE1),Digits);
            double TP=NormalizeDouble(ObjectGetDouble(0,"SelectPriceTP_SellPending",OBJPROP_PRICE1),Digits);
            double SL=NormalizeDouble(ObjectGetDouble(0,"SelectPriceSL_SellPending",OBJPROP_PRICE1),Digits);

            double Diff_TP=(Price-TP)*MathPow(10,Digits);   if(Diff_TP<0)Diff_TP=Diff_TP*(-1);
            double Diff_SL=(SL-Price)*MathPow(10,Digits);   if(Diff_SL<0)Diff_SL=Diff_SL*(-1);

            double BetVar=Bet*(AccountInfoDouble(ACCOUNT_FREEMARGIN)/100);
            double lots=100/Diff_SL;

            _LabelSet("Text_BTN1",300,60,clrMagenta,"Franklin Gothic Medium Cond",15,c(Diff_SL,Digits));

            int OP_Order;
            if(Bid>Price)
               OP_Order=5;
            else
               OP_Order=3;

            bool z=OrderSend(Symbol(),OP_Order,lots,Price,100,SL,TP,"Rosegold["+c(1)+"]",1);
            //---
            ArrowRightPriceDelete(0,"SelectPrice_SellPending");
            ArrowRightPriceDelete(0,"SelectPriceSL_SellPending");
            ArrowRightPriceDelete(0,"SelectPriceTP_SellPending");
           }

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void iFuntion()
  {
   _getOrderFind_();
   string s;
   s+="\nPoint_BUY: "+_Comma(Point_BUY,2,"")+" | Point_SELL: "+_Comma(Point_SELL,2,"")+" = "+_Comma(Point_Sum,2,"");
   s+="\nLots_BUY: "+_Comma(Lots_BUY,2,"")+" | Lots_SELL: "+_Comma(Lots_SELL,2,"")+" = "+_Comma(Lots_Sum,2,"");
   s+="\n"+DIR+"  "+_Comma(AccountInfoDouble(ACCOUNT_PROFIT),2,"");
   s+="\n\n\n\n\n";
   s+=SMS;


   Comment(s);
  }
//+------------------------------------------------------------------+
string c(bool v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(int v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(double v,int d)
  {
   return string(NormalizeDouble(v,d));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(double v)
  {
   return string(v);
  }
double BasePoint=MathPow(10,Digits);
//+------------------------------------------------------------------+
double Point_BUY=0,Point_SELL=0,Point_Sum=0;
double Lots_BUY=0,Lots_SELL=0,Lots_Sum=0;
string DIR,SMS;

double SumLP_B=0,SumLP_S=0;
double MinLots_B=9999,MinLots_S=9999;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _getOrderFind_()
  {
//int CurrentMagic=_MagicEncrypt(v);
   double c=0;
   Point_BUY=0;Point_SELL=0;
   Lots_BUY=0;Lots_SELL=0;
//---
   SumLP_B=0;SumLP_S=0;
//---

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(/*OrderMagicNumber()==CurrentMagic && */(OrderSymbol()==Symbol()))
        {
         switch(OrderType())
           {
            case  0:
              {
               Point_BUY+=((Bid-OrderOpenPrice())*BasePoint)*OrderLots();
               Lots_BUY+=OrderLots();

               if(MinLots_B>OrderLots())
                 {
                  MinLots_B=OrderLots();
                 }
               SumLP_B+=OrderOpenPrice()*OrderLots();
              }
            break;
            case  1:
              {
               Point_SELL+=((OrderOpenPrice()-Ask)*BasePoint)*OrderLots();
               Lots_SELL+=OrderLots();

               if(MinLots_S>OrderLots())
                 {
                  MinLots_S=OrderLots();
                 }
               SumLP_S+=OrderOpenPrice()*OrderLots();
              }
            break;
            default:
               break;
           }
        }
     }
//---

   if(Lots_BUY==0)
      Lots_BUY=1;
   if(Lots_SELL==0)
      Lots_SELL=1;

   double SetA_B=SumLP_B/Lots_BUY;
   double SetB_B=(TP_B/(Lots_BUY/MinLots_B))/MathPow(10,Digits);
   double PriceBuy=SetA_B+SetB_B;

   double SetA_S=SumLP_S/Lots_SELL;
   double SetB_S=(TP_S/(Lots_SELL/MinLots_S))/MathPow(10,Digits);
   double PriceSell=SetA_S-SetB_S;
//+------------------------------------------------------------------+
   double PipBuy=0,PipSell=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
/*if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))*/
        {
         switch(OrderType())
           {
            case  0:
              {
               PipBuy+=PriceBuy-OrderOpenPrice();
              }
            break;
            case  1:
              {
               PipSell+=OrderOpenPrice()-PriceSell;
              }
            break;
            default:
               break;
           }
        }
     }
//+------------------------------------------------------------------+
   PipBuy=PipBuy*BasePoint;
   PipSell=PipSell*BasePoint;

   double VarBuy=PipBuy*Lots_BUY;
   double VarSell=PipSell*Lots_SELL;

   double VarSum=VarBuy+VarSell;

   HLineCreate_(0,"A",0,NormalizeDouble(SetA_B+SetB_B,Digits),clrLime,0,0,false,true,false,0);
   HLineCreate_(0,"B",0,NormalizeDouble(SetA_S-SetB_S,Digits),clrRed,0,0,false,true,false,0);

   SMS="UP : Base"+c(SetA_B,Digits)+" | P"+c(SetB_B,Digits)+" | L"+c(MinLots_B)+" | "+c(PipBuy,2)+" | "+c(VarBuy,2);
   SMS+="\n";
   SMS+="DW : Base"+c(SetA_S,Digits)+" | P"+c(SetB_S,Digits)+" | L"+c(MinLots_S)+" | "+c(PipSell,2)+" | "+c(VarSell,2);
   SMS+="\n";
   SMS+=c(VarSum,2);
   SMS+="\n\n\n\n";

//+------------------------------------------------------------------+
   double BetVar=Bet*(AccountInfoDouble(ACCOUNT_FREEMARGIN)/100);
   BetVar=BetVar/100;

   _setBUTTON("BTN_BUY","BUY ["+c(BetVar,2)+"]",0,120,30,240,100,10,clrBlack,clrGreen);

//+------------------------------------------------------------------+

//---

   Point_Sum=Point_BUY+Point_SELL;

   Lots_BUY=NormalizeDouble(Lots_BUY,2);
   Lots_SELL=NormalizeDouble(Lots_SELL,2);

   Lots_Sum=Lots_BUY-Lots_SELL;
   if(Lots_Sum>0)
     {
      DIR="Buy";
     }
   else if(Lots_Sum<0)
     {
      DIR="Sell";
     }
   else if(Lots_Sum==0)
     {
      DIR="Hold";
     }

   return false;
  }
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= z;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }
   return temp3;
  }
//+------------------------------------------------------------------+
