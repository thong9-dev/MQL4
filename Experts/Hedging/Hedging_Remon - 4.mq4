//|                                                Hedging_Remon.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |

#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Method_MQL4.mqh";
//#include "PasteOrder.mqh";

extern double Lots=0.01;
double lotsMsx=Lots*2;
extern double SarVar=0.001;
extern double Fund=200;
int FTP_=300;
double FTP=FTP_/MathPow(10,Digits);

int cntM15,xcntM15;
int cntH1,xcntH1;
int cntH4,xcntH4;
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
   printf("+------------------------------------------------------------------+");
   _setTemplate();
   CreateBackground("BgroundGG","gg",110,0,2,20);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   printf("//+---------------------------------------------------------------------------------------------+");

   printf("MaxDrawDown: "+C(MaxDrawDown,2)+" [ "+string(DateDD)+" ]");
   printf("MaxProfit: "+C(MaxProfit,2));
   printf("RunDay: "+C(cntRunDay,0)+" | Fund: "+C(Fund,2)+" | Profit: "+C(Profit,2)+" [ "+C(ProfitPercen,2)+"% ] Avg: "+C(ProfitAVG,2));
   printf("//+---------------------------------------------------------------------------------------------+");

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
      OpenOrderFrom_1();
     }
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
int _getOrderCNT_Ative(int v)
  {
   int CurrentMagic=v;
   int c=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && OrderSymbol()==Symbol() && OrderType()<=1)
        {
         c++;
        }
     }
   return c;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _getOrderCNT_Pending(int v)
  {
   int CurrentMagic=v;
   int c=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && OrderSymbol()==Symbol() && OrderType()>=2)
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
//c=c/2;
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
/*if(MinPrice==99999)
      MinPrice=0;
   if(MaxPrice==-99999)
      MaxPrice=0;*/

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
string Comma(double v,int Digit,string z)
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
string C(double v,int Digit)
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
int _isSarInAdj(int Shift)
  {
   double v=NormalizeDouble(iSAR(Symbol(),0,0.009,0.2,Shift),Digits);
   if(v>iClose(Symbol(),0,Shift))
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
//|                                                                  |
//+------------------------------------------------------------------+
bool Workday,Workdayx;
string SMS_Workday;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _StayFriday()
  {
   int H=TimeHour(TimeLocal());
   if((DayOfWeek()<=1 && H<=8) || (DayOfWeek()>=5 && H>=12))
     {
      Workday=false;//OFF-Rest
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" Holidays");
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

   SMS_Workday="Day : "+string(DayOfWeek())+":"+cFillZero(H)+" | Running ["+string(cntRunDay)+"] is a "+_strBoolYN(Workday);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _strBoolYN(int v)
  {
   if(v)
      return "Workday";
   else
      return "Holidays";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cFillZero(int v)
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
void CreateBackground(string Name,string text,int Fontsize,int LabelCorner,int x,int y)
  {
   if(ObjectFind(Name)==-1)
     {
      ObjectCreate(Name,OBJ_LABEL,0,0,0,0,0);
     }
   ObjectSetText(Name,text,Fontsize,"Webdings");
   ObjectSet(Name,OBJPROP_CORNER,LabelCorner);
   ObjectSet(Name,OBJPROP_BACK,false);
   ObjectSet(Name,OBJPROP_XDISTANCE,x);
   ObjectSet(Name,OBJPROP_YDISTANCE,y);
   ObjectSet(Name,OBJPROP_COLOR,C'25,25,25');
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderCheckModule()
  {
   int TailStrat=150,TailDis=100;
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
            if(Diff>=TailStrat)
              {
               _OrderTrailingStop_(OrderTicket(),TailDis);
/*bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
               Print("TicketX_Sell*"+c(OrderTicket()));
               cntOrderSell=_getOrderCNT_(369);*/
              }
            else if(Diff<=(-200) && _isSarInAdj(1)==1)
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
            if(Diff>=TailStrat)
              {
               _OrderTrailingStop_(OrderTicket(),TailDis);
/*bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
               cntOrderBuy=_getOrderCNT_(285);
               Print("TicketX_Buy*"+c(OrderTicket()));*/
              }
            else if(Diff<=(-200) && _isSarInAdj(1)==0)
              {
               int z=OrderSend(Symbol(),OP_SELL,OrderLots(),Bid,100,0,0,"",369,0);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SumGroup__Buy,SumGroup_Sell;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderCloseModule()
  {
   if(AccountInfoDouble(ACCOUNT_PROFIT)>=1)
     {
      _orderCloseActive(369);
      _orderCloseActive(285);
     }
//+------------------------------------------------------------------+----------+
//+------------------------------------------------------------------+----------+
   SumGroup_Sell=SumGroupH_Sell+SumGroupL_Sell;
//---
   string label_sell="Sum_Sell : "+C(SumGroup_Sell,2)+" |H_Sell : "+C(SumGroupH_Sell,2)+" |L_Sell : "+C(SumGroupL_Sell,2);
//_LabelSet("Text_Sum_Sell",10,60,clrYellow,"Franklin Gothic Medium Cond",10,label_sell);
//---
   string strTicketX_Sellc="";
   if(cntOrderSell>=1 && SumGroup_Sell>=1)
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
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            OrderTicketClose_SellNeg[0]=0;
           }
        }
      //---
      Print("*****RealX-Sell : "+strTicketX_Sellc+"****");
      cntOrderSell=_getOrderCNT_Ative(369);
      ArrayResize(OrderTicketClose_Sell,1);
      OrderTicketClose_Sell[0]=0;
     }
//+------------------------------------------------------------------+----------+
//+------------------------------------------------------------------+----------+
   SumGroup__Buy=SumGroupH__Buy+SumGroupL__Buy;
//---
   string label_Buy="Sum_Buy : "+C(SumGroup__Buy,2)+" |H_Buy : "+C(SumGroupH__Buy,2)+" |L_Buy : "+C(SumGroupL__Buy,2);
//_LabelSet("Text_label_Buy",10,80,clrYellow,"Franklin Gothic Medium Cond",10,label_Buy);
//---
   string strTicketX_Buyc="";
   if(cntOrderBuy>=1 && SumGroup__Buy>=1)
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
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            OrderTicketClose__BuyNeg[0]=0;
           }
        }
      //---
      Print("*****RealX-Buy : "+strTicketX_Buyc+"*****");
      cntOrderBuy=_getOrderCNT_Ative(285);
      ArrayResize(OrderTicketClose__Buy,1);
      OrderTicketClose__Buy[0]=0;
     }
//+------------------------------------------------------------------+----------+
//+------------------------------------------------------------------+----------+
   _getPriceMaxMin();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderTrailingStop_(int Ticket,double Trailing)
  {
//printf(Ticket+" | "+Trailing);
   bool z;
   double SL=-1;
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==true)
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            if(Bid-OrderOpenPrice()>Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
              {
               if(OrderStopLoss()<Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT) || (OrderStopLoss()==0))
                 {
                  //z=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),Red);
                  SL=Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT);

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
                  SL=Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT);
                 }
              }
           }
         if(SL>0)
           {
            z=OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
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
      if(OrderSelect(pos,SELECT_BY_TICKET)==false) continue;
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
//|                                                                  |
//+------------------------------------------------------------------+
string _SymbolShortName()
  {
   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);
  }

int GREE_REDc = 20;
int RED_BLUEc = 10;
//---
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isMA(int PERIOD)
  {
   string v;
   int COLSE_GREEc=0;

   double _iMA__RED = iMA(Symbol(),(int)PERIOD,10,MODE_SMA,MODE_EMA,PRICE_WEIGHTED,0);
   double _iMA_GREE = iMA(Symbol(),(int)PERIOD,1,MODE_SMA,MODE_EMA,PRICE_WEIGHTED,0);

//+------------------------------------------------------------------+
   int GREE_RED=(int)((_iMA_GREE-_iMA__RED)*MathPow(10,Digits));
//+------------------------------------------------------------------+
   if((COLSE_GREEc*(-1))<GREE_RED && GREE_RED<COLSE_GREEc)
     {
      v="Wait";
     }
   else
     {
      v=_isMA_Confirm((int)PERIOD,_iMA__RED,_iMA_GREE);
     }
//+------------------------------------------------------------------+
   return v;
  }
//+------------------------------------------------------------------+
string _isMA_Confirm(int Timeframe,double _RED,double GREE)
  {
   string v;

   double COLSE=iClose(Symbol(),Timeframe,1);
   double OPEN_=iOpen(Symbol(),Timeframe,1);
//+------------------------------------------------------------------+  
   int COLSE_GREE=(int)((COLSE-GREE)*MathPow(10,Digits));

   string _COLSE_GREE;

   if((COLSE_GREE>50) && (COLSE>GREE))
     {
      _COLSE_GREE="UP";
     }
   else if((COLSE_GREE<-50) && (COLSE<GREE))
     {
      _COLSE_GREE="DW";
     }

//+------------------------------------------------------------------+   
   if(/*(_COLSE_GREE=="UP")&&(OPEN_>GREE)&&*/(GREE>_RED) /*&& OPEN_<COLSE*/)
     {
      v="Green";
     }

   else if(/*(_COLSE_GREE=="DW") && (OPEN_<GREE) &&*/(GREE<_RED) /*&& OPEN_>COLSE*/)
     {
      v="Red";
     }
   return v;
  }
//+------------------------------------------------------------------+
double Profit,ProfitPercen,ProfitAVG;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenOrderFrom_1()
  {
   _getPriceMaxMin();
   cntOrderSell=_getOrderCNT_Ative(369);
   cntOrderBuy=_getOrderCNT_Ative(285);
//--
   string _isMA=_isMA(0);
   if(_isSarInAdj(1)==1)
     {
      //printf(__FUNCTION__+" | "+c(__LINE__)+c(!_getOrderInfo(369)));
      if(cntOrderSell==0 && Workday && _isMA=="Red" && cntOrderBuy<=7)
        {

         s=OrderSend(Symbol(),OP_SELL,Lots,Bid,100,0,0,"",369,0);
         //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-1");
        }
      else
        {
         if((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread)))
           {
            s=OrderSend(Symbol(),OP_SELL,_getOrderLots_(369),Bid,100,0,0,"",369,0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }
        }
     }
//---------------
   if(_isSarInAdj(1)==0)
     {
      //printf(__FUNCTION__+" | "+c(__LINE__)+c(!_getOrderInfo(285)));
      if(cntOrderBuy==0 && Workday && _isMA=="Green" && cntOrderSell<=7)
        {
         s=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,0,0,"",285,0);
         //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-1");
        }
      else
        {
         if((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread)))
           {
            s=OrderSend(Symbol(),OP_BUY,_getOrderLots_(285),Ask,100,0,0,"",285,0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
        }
     }
//--
   cntOrderSell=_getOrderCNT_Ative(369);
   cntOrderBuy=_getOrderCNT_Ative(285);
   _getPriceMaxMin();

   _OrderCheckModule();
   _OrderCloseModule();
//---
   Profit=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE)-Fund,2);
   ProfitPercen=NormalizeDouble((Profit/Fund)*100,2);

   ProfitAVG=(Profit)/cntRunDay;
   ProfitAVG=NormalizeDouble(ProfitAVG*35,2);
//---

   double Current_PT=AccountInfoDouble(ACCOUNT_PROFIT);
   getDrawDown(Current_PT);
//+------------------------------------------------------------------+
   string SMS;
   SMS+="\n--- Buy";
   SMS+="\nSum-H/L: "+Comma(SumGroupH__Buy,3,"")+" / "+Comma(SumGroupL__Buy,3,"")+" |= "+Comma(SumGroup__Buy,2,"");
   SMS+="\nPrice(Max/Min): "+C(_PriceMax__Buy,Digits)+" / "+C(_PriceMin__Buy,Digits)+" | cnt: "+c(cntOrderBuy);
   SMS+="\n--- Sell";
   SMS+="\nSum-H/L: "+Comma(SumGroupH_Sell,3,"")+" / "+Comma(SumGroupL_Sell,3,"")+" |= "+Comma(SumGroup_Sell,2,"");
   SMS+="\nPrice(Max/Min): "+C(_PriceMax_Sell,Digits)+" / "+C(_PriceMin_Sell,Digits)+" | cnt: "+c(cntOrderSell);

   SMS+="\n\n"+SMS_Workday;

   SMS+="\n\nBalace : "+Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" [ "+C(ProfitPercen,2)+"% / "+C(ProfitAVG,2)+" ]";
   SMS+="\nProfit : "+Comma(Current_PT,2," ")+" DD : "+C(MaxDrawDown,2)+" [ "+string(DateDD)+" ] PT : "+C(MaxProfit,2);

   string dirSar;
   if(_isSarInAdj(1)==0)
      dirSar="Green";
   else
      dirSar="Red";
   SMS+="\n\nSar: "+dirSar+" Confirm: "+_isMA(0);
   SMS+="\n";

   Comment(SMS);
  }
//+------------------------------------------------------------------+
void OpenOrderFrom_2()
  {
   _getPriceMaxMin();
   cntOrderSell=_getOrderCNT_Ative(369);
   cntOrderBuy=_getOrderCNT_Ative(285);
//--
   string _isMA=_isMA(0);
//if(_isSarInAdj(1)==1)
//  {
//printf(__FUNCTION__+" | "+c(__LINE__)+c(!_getOrderInfo(369)));
   if(cntOrderSell==0 && cntOrderBuy==0 && Workday/* && _isMA=="Red" && cntOrderBuy<=7*/)
     {
      s=OrderSend(Symbol(),OP_SELL,Lots,Bid,100,0,0,"",369,0);
      s=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,0,0,"",285,0);
      //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-1");
     }
   else
     {
      if(((Bid>(_PriceMin_Sell-vSpread)) && (Bid<(_PriceMax_Sell+vSpread))) || 
         ((Ask<(_PriceMax__Buy+vSpread)) && (Ask>(_PriceMin__Buy-vSpread))))
        {
         if(cntOrderSell==cntOrderBuy)
           {
            if(_isSarInAdj(1)==1)
               s=OrderSend(Symbol(),OP_SELL,Lots,Bid,100,0,0,"",369,0);
            if(_isSarInAdj(1)==0)
               s=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,0,0,"",285,0);
           }
        }
      else
        {
         //s=OrderSend(Symbol(),OP_SELL,_getOrderLots_(369),Bid,100,0,0,"",369,0);
         //s=OrderSend(Symbol(),OP_BUY,_getOrderLots_(285),Ask,100,0,0,"",285,0);

         s=OrderSend(Symbol(),OP_SELL,Lots,Bid,100,0,0,"",369,0);
         s=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,0,0,"",285,0);
         //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
        }
     }
//}
//---------------
//if(_isSarInAdj(1)==0)
//  {
/*printf(__FUNCTION__+" | "+c(__LINE__)+c(!_getOrderInfo(285)));
      if(cntOrderBuy==0 && Workday/* && _isMA=="Green" && cntOrderSell<=7*//*)
        {
         s=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,0,0,"",285,0);
         printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-1");
        }
      else
        {
         if((Ask<(_PriceMax__Buy+vSpread)) && (Ask>(_PriceMin__Buy-vSpread)))
           {

           }
         else
           {
            //s=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,0,0,"",285,0);
            printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
        }*/
//}
//--
   cntOrderSell=_getOrderCNT_Ative(369);
   cntOrderBuy=_getOrderCNT_Ative(285);
   _getPriceMaxMin();

   _OrderCheckModule();
   _OrderCloseModule();
//---
   ProfitAVG=(AccountInfoDouble(ACCOUNT_BALANCE)-Fund)/cntRunDay;
   ProfitAVG=NormalizeDouble(ProfitAVG*35,2);
//+------------------------------------------------------------------+
   string SMS;
   SMS+="\n--- Buy";
//SMS+="\nSum-H/L: "+Comma(SumGroupH__Buy,3,"")+" / "+Comma(SumGroupL__Buy,3,"")+" |= "+Comma(SumGroup__Buy,2,"")+" | "+C(Dump__Buy,2);
//SMS+="\nSum-*G*[H/L]: *"+C(Sum__BuyGR,2)+"*[ "+C(Sum__BuyUP,2)+"/"+C(Sum__BuyDW,2)+" ] "+C(Dump__Buy,2);
   SMS+="\nPrice(Max/Min): "+C(_PriceMax__Buy,Digits)+" / "+C(_PriceMin__Buy,Digits)+" | cnt: "+c(cntOrderBuy);
   SMS+="\n--- Sell";
//SMS+="\nSum-H/L: "+Comma(SumGroupH_Sell,3,"")+" / "+Comma(SumGroupL_Sell,3,"")+" |= "+Comma(SumGroup_Sell,2,"")+" | "+C(Dump_Sell,2);
//SMS+="\nSum-*G*[H/L]: *"+C(Sum__SellGR,2)+"*[ "+C(Sum__SellUP,2)+"/"+C(Sum__SellDW,2)+" ] "+C(Dump_Sell,2);
   SMS+="\nPrice(Max/Min): "+C(_PriceMax_Sell,Digits)+" / "+C(_PriceMin_Sell,Digits)+" | cnt: "+c(cntOrderSell);

   SMS+="\n\n"+SMS_Workday;
   SMS+="\nBalace : "+Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" [ "+C(ProfitAVG,2)+" ] "+"           | Profit : "+Comma(AccountInfoDouble(ACCOUNT_PROFIT),2," ");

   string dirSar;
   if(_isSarInAdj(1)==0)
      dirSar="Green";
   else
      dirSar="Red";
   SMS+="\n\nSar: "+dirSar+" Confirm: "+_isMA(0);
   SMS+="\n";

   Comment(SMS);
  }
//+------------------------------------------------------------------+
double MaxDrawDown=99999;
double MaxProfit=-99999;
datetime DateDD;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getDrawDown(double v)
  {
   if(v>MaxProfit)
     {
      MaxProfit=v;

     }
   if(v<MaxDrawDown)
     {
      MaxDrawDown=v;
      DateDD=TimeLocal();
     }
  }
//+------------------------------------------------------------------+
void _orderCloseActive(int v)
  {
   int OrderTicketClose[1];
   ArrayResize(OrderTicketClose,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderMagicNumber()==v && (OrderSymbol()==Symbol()) && (OrderType()<=1))
        {
         OrderTicketClose[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(OrderTicketClose);i++)

     {
      if(OrderTicketClose[i]>0)
        {
         if(OrderSelect(OrderTicketClose[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            if(GetLastError()==0){OrderTicketClose[i]=0;}
           }
        }
     }
   ArrayResize(OrderTicketClose,1);
  }
//+------------------------------------------------------------------+
