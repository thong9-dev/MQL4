//|                                                Hedging_Remon.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |

#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Method_MQL4.mqh";

extern double Lots=0.01;
double lotsMsx=Lots*3;
extern double SarVar=0.001;
int FTP_=300;
double FTP=FTP_/MathPow(10,Digits);

int cntM15,xcntM15;
int cntH1,xcntH1;
int cntD1,xcntD1,cntRunDay=0;

int cntOrderBuy,cntOrderSell;
double _PriceMax_Sell,_PriceMin_Sell;
double _PriceMax__Buy,_PriceMin__Buy;
double SumGroupH_Sell=0,SumGroupL_Sell=0;
double SumGroupH__Buy=0,SumGroupL__Buy=0;

double vSpread=100/MathPow(10,Digits);
int OrderTicketClose_Sell[1];
int OrderTicketClose_SellNeg[1];
int OrderTicketClose__Buy[1];
int OrderTicketClose__BuyNeg[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//---

   _setTemplate();
   CreateBackground("BgroundGG","gg",100,0,2,20);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
int s=0;
string strTicketX_Sell,strTicketX_Buy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   xcntH1=iBars(Symbol(),60);
   if(cntH1!=xcntH1)
     {
      cntH1=xcntH1;
      //---
      _StayFriday();
     }
   xcntD1=iBars(Symbol(),PERIOD_D1);
   if(cntD1!=xcntD1)
     {
      cntD1=xcntD1;
      cntRunDay++;
      //---

     }
   xcntM15=iBars(Symbol(),0);
   if(cntM15!=xcntM15)
     {
      cntM15=xcntM15;
      //--
      _getPriceMaxMin();
      //--
      if(!_getOrderInfo(369) && Workday)
        {
         s=OrderSend(Symbol(),OP_SELL,Lots,Bid,100,0,0,"",369,0);
        }
      else
        {
         if((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread)) && _DirSarInAdj(1)==1)
           {
            s=OrderSend(Symbol(),OP_SELL,_getOrderLots_(369),Bid,100,0,0,"",369,0);
           }
        }
      cntOrderSell=_getOrderCNT_(369);

      //---------------

      if(!_getOrderInfo(285) && Workday)
        {
         s=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,0,0,"",285,0);
        }
      else
        {
         if((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread)) && _DirSarInAdj(1)==0)
           {
            s=OrderSend(Symbol(),OP_BUY,_getOrderLots_(285),Ask,100,0,0,"",285,0);
            cntOrderBuy=_getOrderCNT_(285);

           }

        }
      //--
      _getPriceMaxMin();
     }
//+----------------------- Sell
   if(cntOrderSell>=2)
     {
      SumGroupH_Sell=0;SumGroupL_Sell=0;
      ArrayResize(OrderTicketClose_Sell,OrdersTotal());
      for(int i=0;i<OrdersTotal();i++)
         OrderTicketClose_Sell[i]=0;
      _getPriceMaxMin();
      strTicketX_Sell="";
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==369 && (OrderSymbol()==Symbol()) && OrderProfit()>0)
           {
            SumGroupH_Sell+=OrderProfit();
            OrderTicketClose_Sell[pos]=OrderTicket();
            strTicketX_Sell+="/"+c(OrderTicket());
           }
         if(_PriceMin_Sell==OrderOpenPrice())
           {
            SumGroupL_Sell=OrderProfit();
            OrderTicketClose_SellNeg[0]=OrderTicket();
           }
        }
     }
   else
     {
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==369 && (OrderSymbol()==Symbol()) && OrderProfit()>0 && _PriceMin_Sell==OrderOpenPrice())
           {
            double Diff=(OrderOpenPrice()-Ask)*MathPow(10,Digits);
            if(Diff>=100)
              {
               TrailingStop_(OrderTicket(),50);
/*bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
               Print("TicketX_Sell*"+c(OrderTicket()));
               cntOrderSell=_getOrderCNT_(369);*/
              }
            else if(Diff<=(FTP_*(-1)) && _DirSarInAdj(1)==1)
              {
               int z=OrderSend(Symbol(),OP_BUY,OrderLots(),Ask,100,0,0,"",285,0);
              }
           }
        }
     }
//+----------------------- Buy
   if(cntOrderBuy>=2)
     {
      SumGroupH__Buy=0;SumGroupL__Buy=0;
      ArrayResize(OrderTicketClose__Buy,OrdersTotal());
      for(int i=0;i<OrdersTotal();i++)
         OrderTicketClose__Buy[i]=0;
      _getPriceMaxMin();
      strTicketX_Buy="";
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==285 && (OrderSymbol()==Symbol()) && OrderProfit()>0)
           {
            SumGroupL__Buy+=OrderProfit();
            OrderTicketClose__Buy[pos]=OrderTicket();
            strTicketX_Buy+="/"+c(OrderTicket());
           }
         if(_PriceMax__Buy==OrderOpenPrice())
           {
            SumGroupH__Buy=OrderProfit();
            OrderTicketClose__BuyNeg[0]=OrderTicket();
           }
        }

     }
   else
     {
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==285 && (OrderSymbol()==Symbol()) && OrderProfit()>0 && _PriceMax__Buy==OrderOpenPrice())
           {
            double Diff=(Bid-OrderOpenPrice())*MathPow(10,Digits);
            if(Diff>=100)
              {
               TrailingStop_(OrderTicket(),50);
/*bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
               cntOrderBuy=_getOrderCNT_(285);
               Print("TicketX_Buy*"+c(OrderTicket()));*/
              }
            else if(Diff<=(FTP_*(-1)) && _DirSarInAdj(1)==0)
              {
               int z=OrderSend(Symbol(),OP_SELL,OrderLots(),Bid,100,0,0,"",369,0);
              }
           }
        }
     }

   _OrderCloseGroup();

   string SMS;
   SMS+="\nSumBuy-H : "+_Comma(SumGroupH__Buy,3,"")+" | SumBuy-L : "+_Comma(SumGroupL__Buy,3,"")+" | "+_Comma(SumGroup__Buy,2,"")+" |ProfitB: "+_C(SumProifit_Buy_H,2);
   SMS+="\nPriceMax_Buy : "+c(_PriceMax__Buy,Digits)+" | PriceMin_Buy"+c(_PriceMin__Buy,Digits)+" | cntBuy : "+c(cntOrderBuy);
   SMS+="\n";
   SMS+="\nSumSell-H : "+_Comma(SumGroupH_Sell,3,"")+" | SumSell-L : "+_Comma(SumGroupL_Sell,3,"")+" | "+_Comma(SumGroup_Sell,2,"")+" |ProfitS: "+_C(SumProifit_Sell_H,2);
   SMS+="\nPriceMax_Sell : "+c(_PriceMax_Sell,Digits)+" | PriceMin_Sell"+c(_PriceMin_Sell,Digits)+" | cntSell : "+c(cntOrderSell);

   SMS+="\n\n"+SMS_Workday;
   SMS+="\nBalace : "+_Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" | Profit : "+_Comma(AccountInfoDouble(ACCOUNT_PROFIT),2," ");

   SMS+="\n\n\n"+c(_DirSarInAdj(1));

   Comment(SMS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
bool _getOrderFind_(int v)
  {
   int CurrentMagic=v;

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _getOrderCNT_(int v)
  {
   int CurrentMagic=v;
   int c=0;
   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         c++;
        }
     }
   return c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_(int v)
  {
   int CurrentMagic=v;
   double c=0;
   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         c+=OrderLots();
        }
     }
   c=c/2;
   if(c>lotsMsx)
     {
      c=lotsMsx;
     }
   return NormalizeDouble(c,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getPriceMaxMin()
  {
   _PriceMax_Sell=_getPriceMaxMin("Max",369);
   _PriceMin_Sell= _getPriceMaxMin("Min",369);

   _PriceMax__Buy= _getPriceMaxMin("Max",285);
   _PriceMin__Buy= _getPriceMaxMin("Min",285);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getPriceMaxMin(string v,int _MagicNumber)
  {
   double MinPrice=99999,MaxPrice=-99999;

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber)
        {
         if(OrderOpenPrice()>MaxPrice)
           {
            MaxPrice=OrderOpenPrice();
           }
         if(OrderOpenPrice()<MinPrice)
           {
            MinPrice=OrderOpenPrice();
           }
        }
     }
//printf("[_isLastBas()]# Max : "+MaxPrice+" Min : "+MinPrice);
   if("Max"==v)
     {
      return  MaxPrice;
     }

   else if("Min"==v)
     {
      return  MinPrice;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
void _setTemplate()
  {

   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);
   ChartSetInteger(0,CHART_COLOR_GRID,clrBlue);

   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
string _C(double v,int Digit)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
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
//|                                                                  |
//+------------------------------------------------------------------+
int _DirSarInAdj(int x)
  {
   double v=NormalizeDouble(iSAR(Symbol(),0,0.009,0.2,x),Digits);
   if(v>iClose(Symbol(),0,x))
     {
      return 1;//Sell
     }
   else
     {
      return 0;//Buy
     }

   return -1;
  }
//+------------------------------------------------------------------+
bool Workday,Workdayx;
string SMS_Workday;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _StayFriday()
  {
   int H=TimeHour(TimeLocal());
   if((DayOfWeek()<=1 && H<=8) || (DayOfWeek()>=5 && H>=8))
     {
      Workday=false;//OFF-Rest
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" DayOff");
        }
     }
   else
     {
      Workday=True;//ON
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" Workday");
        }

     }
   if(Workdayx!=Workday)
      Print(__FUNCTION__+" "+string(Workday));

   SMS_Workday="Day : "+string(DayOfWeek())+":"+_FillZero(H)+" | Workday ["+string(cntRunDay)+"] : "+_strBoolYN(Workday);
   return true;
  }
//+------------------------------------------------------------------+
string _strBoolYN(int v)
  {
   if(v)
      return "Yes";
   else
      return "is Holidays";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _FillZero(int v)
  {
   string temp;
   if(v<10)
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;

  }
//+------------------------------------------------------------------+

// function
void CreateBackground(string backName,string text,int Bfontsize,int LabelCorner,int xB,int yB)
  {
   if(ObjectFind(backName)==-1)
     {
      ObjectCreate(backName,OBJ_LABEL,0,0,0,0,0);
     }
   ObjectSetText(backName,text,Bfontsize,"Webdings");
   ObjectSet(backName,OBJPROP_CORNER,LabelCorner);
   ObjectSet(backName,OBJPROP_BACK,false);
   ObjectSet(backName,OBJPROP_XDISTANCE,xB);
   ObjectSet(backName,OBJPROP_YDISTANCE,yB);
   ObjectSet(backName,OBJPROP_COLOR,C'25,25,25');
  }
//+------------------------------------------------------------------+
double SumGroup__Buy,SumGroup_Sell;
double SumProifit_Sell_H,SumProifit_Buy_H;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderCloseGroup()
  {
//+------------------------------------------------------------------+----------+
//+------------------------------------------------------------------+----------+
   double SumProifit_Sell_X=0;
   SumGroup_Sell=SumGroupH_Sell+SumGroupL_Sell;
//---
   string label_sell="Sum_Sell : "+_C(SumGroup_Sell,2)+" |H_Sell : "+_C(SumGroupH_Sell,2)+" |L_Sell : "+_C(SumGroupL_Sell,2);
//_LabelSet("Text_Sum_Sell",10,60,clrYellow,"Franklin Gothic Medium Cond",10,label_sell);
//---
   string strTicketX_Sellc="";
   if(cntOrderSell>=2 && SumGroup_Sell>=1)
     {
      Print("*****TicketX_Sell"+strTicketX_Sell+"["+c(OrderTicketClose_SellNeg[0])+"]*****");
      //---1
      for(int i=0;i<ArraySize(OrderTicketClose_Sell);i++)
        {
         if(OrderTicketClose_Sell[i]>0)
           {
            if(OrderSelect(OrderTicketClose_Sell[i],SELECT_BY_TICKET)==true)
              {
               strTicketX_Sellc+="/"+c(OrderTicket());
               SumProifit_Sell_X+=OrderProfit();

               bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
               OrderTicketClose_Sell[i]=0;
              }
           }
        }
      //---2
      if(OrderTicketClose_SellNeg[0]>0)
        {
         if(OrderSelect(OrderTicketClose_SellNeg[0],SELECT_BY_TICKET)==true)
           {
            strTicketX_Sellc+="["+c(OrderTicket())+"]";
            SumProifit_Sell_X+=OrderProfit();

            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            OrderTicketClose_SellNeg[0]=0;
           }
        }
      //---
      SumProifit_Sell_X=SumProifit_Sell_X/2;
      SumProifit_Sell_H+=SumProifit_Sell_X;
      SumProifit_Buy_H+=SumProifit_Sell_X;
      //---
      Print("*****RealX-Sell : "+strTicketX_Sellc+"****");
      cntOrderSell=_getOrderCNT_(369);
      ArrayResize(OrderTicketClose_Sell,1);
      OrderTicketClose_Sell[0]=0;
     }
//+------------------------------------------------------------------+----------+
//+------------------------------------------------------------------+----------+
   double SumProifit_Buy_X=0;
   SumGroup__Buy=SumGroupH__Buy+SumGroupL__Buy;
//---
   string label_Buy="Sum_Buy : "+_C(SumGroup__Buy,2)+" |H_Buy : "+_C(SumGroupH__Buy,2)+" |L_Buy : "+_C(SumGroupL__Buy,2);
//_LabelSet("Text_label_Buy",10,80,clrYellow,"Franklin Gothic Medium Cond",10,label_Buy);
//---
   string strTicketX_Buyc="";
   if(cntOrderBuy>=2 && SumGroup__Buy>=1)
     {
      Print("*****TicketX_Buy "+strTicketX_Buy+"["+c(OrderTicketClose__BuyNeg[0])+"]*****");
      //---1
      for(int i=0;i<ArraySize(OrderTicketClose__Buy);i++)
        {
         if(OrderTicketClose__Buy[i]>0)
           {
            if(OrderSelect(OrderTicketClose__Buy[i],SELECT_BY_TICKET)==true)
              {
               strTicketX_Buyc+="/"+c(OrderTicket());
               SumProifit_Buy_X+=OrderProfit();

               bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
               OrderTicketClose__Buy[i]=0;
              }
           }
        }
      //---2
      if(OrderTicketClose__BuyNeg[0]>0)
        {
         if(OrderSelect(OrderTicketClose__BuyNeg[0],SELECT_BY_TICKET)==true)
           {
            strTicketX_Buyc+="["+c(OrderTicket())+"]";
            SumProifit_Buy_X+=OrderProfit();

            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            OrderTicketClose__BuyNeg[0]=0;
           }
        }
      //---
      SumProifit_Buy_X=SumProifit_Buy_X/2;
      SumProifit_Sell_H+=SumProifit_Buy_X;
      SumProifit_Buy_H+=SumProifit_Buy_X;
      //---
      Print("*****RealX-Buy : "+strTicketX_Buyc+"*****");
      cntOrderBuy=_getOrderCNT_(285);
      ArrayResize(OrderTicketClose__Buy,1);
      OrderTicketClose__Buy[0]=0;
     }
//+------------------------------------------------------------------+----------+
//+------------------------------------------------------------------+----------+
   _getPriceMaxMin();
  }
//+------------------------------------------------------------------+
//place at the top
extern bool trail=False;
extern double TrailingStop=10;
//place before init, or after the code at the bottom
void TrailingStop_(int Ticket,double Trailing)
  {
//printf(Ticket+" | "+Trailing);
   bool z;
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==true)
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            if(Bid-OrderOpenPrice()>Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
              {
               if(OrderStopLoss()<Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
                 {
                  //z=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),Red);
                  z=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT),0,0);
                 }
              }
           }
         else if(OrderType()==OP_SELL)
           {
            if(OrderOpenPrice()-Ask>Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
              {
               if((OrderStopLoss()>Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT)) || (OrderStopLoss()==0))
                 {
                  //z=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),Red);
                  z=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT),0,0);
                 }
              }
           }
        }
  }
//+------------------------------------------------------------------+
int iOrderTicket,iOrderType,iOrderMagicNumber;
double iOrderOpenPrice,iOrderTakeProfit,iOrderStopLoss,iOrderProfit;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _getOrderInfo(int v)
  {
   int CurrentMagic=v;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         iOrderTicket=OrderTicket();
         iOrderType=OrderType();

         iOrderOpenPrice=OrderOpenPrice();
         iOrderTakeProfit=OrderTakeProfit();
         iOrderStopLoss=OrderStopLoss();

         iOrderMagicNumber=OrderMagicNumber();

         iOrderProfit=OrderProfit();

         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
/*int __orderPin(int v)
  {
   int z=-1;
   double PriceEntry=-1,SL=-1,TP=-1,R;
   int CurrentMagic=-1,OP_Direct=-1;
   string OrderName;
   int CurrentDir=_DirSarIn(1);
   int v2=-1;

//---
   if(v==4)
      v2=5;
   if(v==5)
      v2=4;
//---
   if(!_getOrderInfo(v))
     {//+---------------------NewOrder---------------------+
      if(_DirSarBack(2,3,v2) && (_DirSarIn(2)!=_DirSarIn(1)) && (_DirSarIn(1)==_DirSarIn(0)))
        {
         if(_DirSarIn(1)==4 && v==4 && iMA_Line(4))//------------------ Buy
           {
            FirstCall_TP_Buy=true;
            iLine_TP_Buy=0;

            printf(__FUNCTION__+"----------------------------------- "+string(v)+"newBuy");

            PriceEntry=iHigh(Symbol(),0,1);

            TP=_calculate_BandsNew2(PriceEntry,0,3);
            //---
            R=iLow(Symbol(),0,1)-iSAR(Symbol(),0,_iSarStep,0.2,1);
            SL=iLow(Symbol(),0,1)-(R*0.5);
            //---
            TP=NormalizeDouble(TP,Digits);
            SL=NormalizeDouble(SL,Digits);
            //------------------
            if(Bid>PriceEntry)
              {
               //OP_Direct=2;
               printf(__FUNCTION__+" | "+c(__LINE__));
              }
            else
              {
               OP_Direct=4;//<<
               printf(__FUNCTION__+" | "+c(__LINE__));
              }
           }
         else if(_DirSarIn(1)==5 && v==5 && iMA_Line(5))//------------------ Sell
           {
            FirstCall_TP_Sell=true;
            iLine_TP_Sell=0;

            printf(__FUNCTION__+"+----------------------------------- "+string(v)+"newSell");

            PriceEntry=iLow(Symbol(),0,1);

            TP=_calculate_BandsNew2(PriceEntry,1,3);
            //---
            R=iSAR(Symbol(),0,_iSarStep,0.2,1)-iHigh(Symbol(),0,1);
            SL=iHigh(Symbol(),0,1)+(R*0.5);
            //---
            TP=NormalizeDouble(TP,Digits);
            SL=NormalizeDouble(SL,Digits);
            //------------------
            if(Bid>PriceEntry)
              {
               OP_Direct=5;//<<
              }
            else
              {
               //OP_Direct=3;
              }
           }
         else
           {
            return z;
           }
         //--------------------------------------------------------------------------
         if(OP_Direct>0)
           {
            OrderName=_SymbolShortName()+" | "+string(CurrentMagic)+"]";
            //z=OrderSend(Symbol(),v,Lots,PriceEntry,100,0,0,OrderName,_MagicEncrypt(v),0,clrGreen);
            z=OrderSend(Symbol(),OP_Direct,_calculateLots(PriceEntry,SL),PriceEntry,100,SL,TP,"",_MagicEncrypt(v),0);
            _getWinLoes();
            printf(__FUNCTION__+" | "+c(__LINE__)+"|"+c(z));
/*if(z<0)
              {
               printf(__FUNCTION__+" | "+c(__LINE__));
               OP_Direct=OP_Direct-4;
               if(OP_Direct==0)
                  PriceEntry=Ask;
               else
                  PriceEntry=Bid;
               z=OrderSend(Symbol(),OP_Direct,_calculateLots(PriceEntry,SL),PriceEntry,100,SL,TP,"",_MagicEncrypt(v),0);
              }*/
/*return z;
           }
         //--------------------------------------------------------------------------
        }
     }
   return z;
  }*/
//+------------------------------------------------------------------+
string _SymbolShortName()
  {
   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);
  }
//+------------------------------------------------------------------+
