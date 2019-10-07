//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "X-System.mq4";
//---
#include "X-System_Method_Value.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _ShowLine=ShowLine;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderPinHub()
  {
   if(IsDllsAllowed() || IsTesting())
     {
      if(Workday && WorkFreeze)
        {
         _ShowLine=ShowLine;
         if(OpenNormal)
           {
            //_orderPin(8);
            _orderPin(0);
            _orderPin(1);
           }
         if(OpenFallow)
           {
            _orderPin(2);
            _orderPin(3);
           }
        }
      else
        {
         _ShowLine=false;
         _orderDelete();
         _orderCloseActive();
        }
     }
   else
     {
      _ShowLine=false;
      _orderDelete();
      _orderCloseActive();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(_ShowLine)
     {
      HLineCreate_(0,"LINE_Rim1",0,_Pivot+Fibo_BX[ArraySize(Fibo_TB)],clrHotPink,0,1,false,true,false,0);
      HLineCreate_(0,"LINE_Rim2",0,_Pivot-Fibo_BX[ArraySize(Fibo_TB)],clrHotPink,0,1,false,true,false,0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderPin(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);
   int OP_Direct=-1;
   double Price=0,TP=0,SL=0;
   string LineName,OrderName;
   color LineClr=clrLime;
   int z=0;
   bool res;
//---
   int Trend=_directSar();
//---
   if(v==8)
     {
      LineName="LINE_PIVOT";
      LineClr=clrYellow;

      //---
      Price=_Pivot;

      if(Price<Bid)
        {
         OP_Direct=5;//SELL
         //---
         TP=_Pivot-Fibo_BX[1];
         SL=_Pivot+Fibo_BX[2];
        }
      else
        {
         OP_Direct=4;//BUY
         //---
         TP=_Pivot+Fibo_BX[1];
         SL=_Pivot-Fibo_BX[2];
        }
     }
   else if(v==0)
     {
      LineName="LINE_Upper"+string(v);
      LineClr=clrRoyalBlue;

      //---
      Price=_Pivot+Fibo_BX[2];
      if(Price<Bid)
        {
         OP_Direct=-1;//5;//SELL
         //---
         TP=_Pivot+Fibo_BX[1];
         SL=_Pivot+Fibo_BX[4];
        }
      else
        {
         OP_Direct=4;//BUY
         //---
         TP=_Pivot+Fibo_BX[3];
         SL=_Pivot;
        }
     }
   else if(v==1)
     {
      LineName="LINE_Lower"+string(v);
      LineClr=clrRoyalBlue;

      //---
      Price=_Pivot-Fibo_BX[2];
      if(Price<Bid)
        {
         OP_Direct=5;//SELL
         //---
         TP=_Pivot-Fibo_BX[3];
         SL=_Pivot;
        }
      else
        {
         OP_Direct=-1;//4;//BUY
         //---
         TP=_Pivot-Fibo_BX[1];
         SL=_Pivot-Fibo_BX[4];
        }
     }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
   else if(v==2)
     {
      Trend=2;
      LineName="Follow_Buy";
      LineClr=clrTomato;
      //---
      Price=_Pivot+Fibo_BX[4];
      if(Price>Bid)
        {
         OP_Direct=3;
         //---
         TP=_Pivot+Fibo_BX[2];
         SL=_Pivot+Fibo_BX[5];
        }
      else
        {
         OP_Direct=-1;//4;//BUY
         //---
         TP=_Pivot+Fibo_BX[5];
         SL=_Pivot+Fibo_BX[3];
        }
     }
   else if(v==3)
     {
      Trend=3;
      LineName="Follow_Sell";
      LineClr=clrTomato;
      //---
      Price=_Pivot-Fibo_BX[4];
      if(Price>Bid)
        {
         OP_Direct=-1;//5;//SELL
         //---
         TP=_Pivot-Fibo_BX[5];
         SL=_Pivot-Fibo_BX[3];
        }
      else
        {
         OP_Direct=2;
         //---
         TP=_Pivot-Fibo_BX[2];
         SL=_Pivot-Fibo_BX[5];
        }
     }
   else
     {
     }
//---
   double Price_X_Bid;
   if(Price>Bid)
      Price_X_Bid=NormalizeDouble((Price-Bid)*MathPow(10,Digits),0);
   else
      Price_X_Bid=NormalizeDouble((Bid-Price)*MathPow(10,Digits),0);

   if(Price_X_Bid<=Fibo_BX[1])
     {
      OP_Direct=-1;
     }
//+-------------------
   OrderName=Symbol_()+" | "+LineName+" ["+string(CurrentMagic)+"]";
   Price=NormalizeDouble(Price,Digits);
   TP=NormalizeDouble(TP,Digits);
   SL=NormalizeDouble(SL,Digits);
//+-------------------
   if(_ShowLine)
      HLineCreate_(0,LineName,0,Price,LineClr,0,1,false,true,false,0);

//---
   bool Find=false;
   for(int pos=0;pos<OrdersTotal();pos++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         Find=true;
         //---
         if(OrderType()<=1)
           {
            //---
            HLineCreate_(0,LineName,0,OrderOpenPrice(),clrLime,0,1,false,true,false,0);
            //---

            //if((OrderType()==0 && TP>=OrderOpenPrice()) || (OrderType()==1 && TP<=OrderOpenPrice()))
            //  {

            if(OrderStopLoss()!=SL || OrderTakeProfit()!=TP)
              {
               res=OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0);
               if(!res)
                 {
                  //res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderOpenPrice(),0);
                  printf(__FUNCSIG__+" | line"+string(__LINE__)+" | e"+string(GetLastError())+" Active ["+string(v)+"]");
                 }
              }

            //}

           }
         else
           {
            //---
            if(!_ShowLine)
              {
               HLineDelete(0,LineName);
               //printf(__FUNCSIG__+" | line"+string(__LINE__)+" | e"+string(GetLastError())+" HLineDelete ["+string(v)+"]");
              }
            //---
            if(Price>Bid)
               Price_X_Bid=NormalizeDouble((Price-Bid)*MathPow(10,Digits),0);
            else
               Price_X_Bid=NormalizeDouble((Bid-Price)*MathPow(10,Digits),0);

            if(OrderOpenPrice()!=Price)// && Price_X_Bid>=200)// || OrderStopLoss()!=SL || OrderTakeProfit()!=TP)
              {
               res=OrderModify(OrderTicket(),Price,SL,TP,0);
               if(!res)
                 {
                  res=OrderDelete(OrderTicket());
                  printf(__FUNCSIG__+" | line"+string(__LINE__)+" | e"+string(GetLastError())+" Pending ["+string(v)+"]");
                 }
              }
           }
         //---
         break;
        }
     }
//+-------------------
   bool _OpenAll=false;
   if(OpenAll)
     {
      _OpenAll=true;
     }
   else
     {
      if(Trend==v)
         //if(Trend==OP_Direct)
        {
         _OpenAll=true;
        }
     }
//+-------------------
   if(!Find)
     {
      if(OP_Direct>=0 && _OpenAll)
        {
         _getWinLoes();
         z=OrderSend(Symbol(),OP_Direct,Lots,Price,100,SL,TP,OrderName,CurrentMagic);
         if(z<0)
           {
            printf(__FUNCSIG__+" | line"+string(__LINE__)+" | e"+string(GetLastError())+" OrderSend ["+string(v)+"]");
           }
        }

      //---
      if(!_ShowLine)
        {
         HLineDelete(0,LineName);
         //printf(__FUNCSIG__+" | line"+string(__LINE__)+" | e"+string(GetLastError())+" HLineDelete ["+string(v)+"]");
        }
      //---
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _MagicEncrypt(int Type)
  {
   string v=string(Magicnumber)+string(Type);
   return int(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderCloseActive()
  {
   ArrayResize(OrderTicketDelete,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if((OrderMagic_==Magicnumber) && (OrderSymbol()==Symbol()) && (OrderType()>1))
        {
         if(OrderProfit()>=0)
           {
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
           }
        }
     }
  }
int OrderTicketDelete[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderDelete()
  {
   ArrayResize(OrderTicketDelete,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if((OrderMagic_==Magicnumber) && (OrderSymbol()==Symbol()) && (OrderType()>1))
        {
         OrderTicketDelete[pos]=OrderTicket();
        }
     }
//---
   _orderDeleteX();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderDelete(int v)
  {
   ArrayResize(OrderTicketDelete,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if(OrderMagic_==Magicnumber && OrderPin==v && (OrderSymbol()==Symbol()) && (OrderType()>1))
        {
         OrderTicketDelete[pos]=OrderTicket();
         break;
        }
     }
//---
   _orderDeleteX();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderDeleteX()
  {
   for(int i=0;i<ArraySize(OrderTicketDelete);i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderTicketDelete[i]>0)
        {
         if(OrderSelect(OrderTicketDelete[i],SELECT_BY_TICKET)==true)
           {
            bool z=OrderDelete(OrderTicketDelete[i]);
            if(GetLastError()==0){OrderTicketDelete[i]=0;}
           }
        }
     }
   ArrayResize(OrderTicketDelete,1);
  }

int OrderMagic_,OrderPin;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MagicDecode(int v)
  {
   string z=string(v);
   string m=StringSubstr(z,0,StringLen(string(Magicnumber)));
   string o=StringSubstr(z,StringLen(string(Magicnumber)),1);
   OrderMagic_=int(m);
   OrderPin=int(o);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceIsbetween(int type,double v)
  {
   _getRangPivot();
   double tp=0;
//---
   for(int i=0;i<ArraySize(Fibo_BX);i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(type==0 && _Pivot+Fibo_BX[i]<=v && v<=_Pivot+Fibo_BX[i+1])
        {
         tp=_Pivot+Fibo_BX[i+1];
         break;
        }
      else
        {
         tp=v+Fibo_BX[1];
        }
      if(type==1 && _Pivot-Fibo_BX[i]>=v && v>=_Pivot-Fibo_BX[i+1])
        {
         tp=_Pivot-Fibo_BX[i+1];
         break;
        }
      else
        {
         tp=v-Fibo_BX[1];
        }
     }
   return NormalizeDouble(tp,Digits);
  }
//+------------------------------------------------------------------+
double Rate_Win=0,Rate_Lose=0,Rate=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getWinLoes()
  {
   Rate_Win=0;Rate_Lose=0;Rate=0;
   for(int i=0;i<OrdersHistoryTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)
        {
         if(OrderProfit()==0)
            continue;
         _MagicDecode(OrderMagicNumber());
         if((OrderMagic_==Magicnumber) && (OrderSymbol()==Symbol()))
            //if(OrderMagic_==1)
           {
            if(OrderProfit()>0)
               Rate_Win++;
            else
               Rate_Lose++;
           }
        }
     }
   if(Rate_Win>0)
     {
      Rate=(Rate_Win/(Rate_Win+Rate_Lose))*100;
     }

//printf(string(Rate_Win)+" | "+string(Rate_Lose)+" Rate :"+string(Rate));
  }
//+------------------------------------------------------------------+
