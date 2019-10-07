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
void _orderPinHub()
  {
   if(Workday)
     {
      if(OpenNormal)
        {
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
      _orderDelete();
     }

   if(ShowLine)
     {
      HLineCreate_(0,"LINE_Rim1",0,_Pivot+Fibo_BX[3],clrHotPink,0,1,false,true,false,0);
      HLineCreate_(0,"LINE_Rim2",0,_Pivot-Fibo_BX[3],clrHotPink,0,1,false,true,false,0);
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
   if(v==0)
     {
      LineName="UpperSell"+string(v);

      Price=_Pivot+Fibo_BX[1];
      TP=_Pivot+((Price-_Pivot)*0.15);
      SL=_Pivot+Fibo_BX[2];

      LineClr=clrRoyalBlue;

      //---
      if(Price>Bid)
         OP_Direct=3;
      else
         OP_Direct=5;
     }
   else if(v==1)
     {
      LineName="LowerBuy"+string(v);

      Price=_Pivot-Fibo_BX[1];
      TP=_Pivot-((_Pivot-Price)*0.15);
      SL=_Pivot-Fibo_BX[2];

      LineClr=clrRoyalBlue;
      //---
      if(Price<Bid)
         OP_Direct=2;
      else
         OP_Direct=4;
     }
//+------------------------------------------------------------------+
   else if(v==2)
     {
      Trend=2;
      LineName="Follow Buy";
      Price=_Pivot+Fibo_BX[2];
      TP=_Pivot+Fibo_BX[3]-(Spread/BaseDigits);
      SL=_Pivot+Fibo_BX[1];

      LineClr=clrTomato;
      //---
      if(Price<Bid)
         OP_Direct=-1;//2;
      else
         OP_Direct=4;
     }
   else if(v==3)
     {
      Trend=3;
      LineName="Follow Sell";
      Price=_Pivot-(Fibo_BX[2]);
      TP=_Pivot-Fibo_BX[3]+(Spread/BaseDigits);
      SL=_Pivot-Fibo_BX[1];

      LineClr=clrTomato;
      //---
      if(Price>Bid)
         OP_Direct=-1;//3;
      else
         OP_Direct=5;
     }
   else
     {
     }
//+-------------------
   OrderName=Symbol_()+" | "+LineName+" ["+string(CurrentMagic)+"]";
   Price=NormalizeDouble(Price,Digits);
   TP=NormalizeDouble(TP,Digits);
   SL=NormalizeDouble(SL,Digits);
//+-------------------
   if(ShowLine)
      HLineCreate_(0,"LINE_"+LineName,0,Price,LineClr,0,1,false,true,false,0);

//---
   bool Find=false;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         Find=true;
         //---
         if(OrderType()<=1)
           {
            //---
            HLineCreate_(0,"LINE_"+LineName,0,OrderOpenPrice(),clrLime,0,1,false,true,false,0);
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
            if(!ShowLine)
              {
               HLineDelete(0,"LINE_"+LineName);
               //printf(__FUNCSIG__+" | line"+string(__LINE__)+" | e"+string(GetLastError())+" HLineDelete ["+string(v)+"]");
              }
            //---

            if(OrderOpenPrice()!=Price)// || OrderStopLoss()!=SL || OrderTakeProfit()!=TP)
              {
               res=OrderModify(OrderTicket(),Price,0,0,0);
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
        {
         _OpenAll=true;
        }
     }
//+-------------------
   if(!Find)
     {
      if(OP_Direct>=0 && _OpenAll)
        {
         z=OrderSend(Symbol(),OP_Direct,Lots,Price,100,SL,TP,OrderName,CurrentMagic);
         if(z<0)
           {
            printf(__FUNCSIG__+" | line"+string(__LINE__)+" | e"+string(GetLastError())+" OrderSend ["+string(v)+"]");
           }
        }

      //---
      if(!ShowLine)
        {
         HLineDelete(0,"LINE_"+LineName);
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
