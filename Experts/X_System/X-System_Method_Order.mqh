//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |

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
   setWorkStopIsPayback();
   if(Workday && WorkFreeze && WorkStopIsPayback)
     {
      _pinLine(1);
      _ShowLine=ShowLine;
      if(OpenNormal)
        {
         _orderPin();
        }
      if(OpenFallow)
        {
/*_orderPin(2);
         _orderPin(3);*/
        }
     }
   else
     {
      HLineDelete(0,"A");
      HLineDelete(0,"B");
      _pinLine(0);
      _ShowLine=false;
      _orderDelete();
      _orderCloseActive();
     }

   if(_ShowLine)
     {
      HLineCreate_(0,"LINE_Rim1",0,_Pivot+Fibo_BX[ArraySize(Fibo_TB)],clrSilver,1,1,false,true,false,0);
      HLineCreate_(0,"LINE_Rim2",0,_Pivot-Fibo_BX[ArraySize(Fibo_TB)],clrSilver,1,1,false,true,false,0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _pinLine(int v)
  {
   int x=0;
   if(x==0)
     {
      if(v==1)
        {
         for(int i=0;i<ArraySize(Fibo_BX);i++)
           {
            HLineCreate_(0,"LINE_UP"+string(i),0,_Pivot+Fibo_BX[i],clrDarkSlateGray,2,1,false,true,false,0);
            HLineCreate_(0,"LINE_DW"+string(i),0,_Pivot-Fibo_BX[i],clrDarkSlateGray,2,1,false,true,false,0);
           }
        }
      else
        {
         for(int i=0;i<ArraySize(Fibo_BX);i++)
           {
            HLineDelete(0,"LINE_UP"+string(i));
            HLineDelete(0,"LINE_DW"+string(i));
           }
        }
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
      LineName="LINE_"+string(v);
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
      LineName="LINE_"+string(v);
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
//---
   double Price_X_Bid;
   if(Price>Bid)
      Price_X_Bid=NormalizeDouble((Price-Bid)*MathPow(10,Digits),0);
   else
      Price_X_Bid=NormalizeDouble((Bid-Price)*MathPow(10,Digits),0);

   if(Price_X_Bid<=(Fibo_BX[0]/2))
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
   if(!Find)
     {
      if(OP_Direct>=0)
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
int OrderTicketClose[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderCloseActive()
  {
   ArrayResize(OrderTicketClose,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if((OrderMagic_==Magicnumber) && (OrderSymbol()==Symbol()) && (OrderType()>1))
        {
         OrderTicketClose[pos]=OrderTicket();
         //if(OrderProfit()>=0)
         //  {
         //   bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
         //  }
        }
     }
   _orderCloseX();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderCloseX()
  {
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
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
bool chkOrder(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int chkOrderType(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         return OrderType();
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double chkOrderPrice(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         return OrderOpenPrice();
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool orderModify(int v,double PR,double SL,double TP)
  {
   int CurrentMagic=_MagicEncrypt(v);
   bool z=-1;

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         if(PR<0)
           {
            PR=OrderOpenPrice();
           }
         if(OrderStopLoss()!=SL || OrderTakeProfit()!=TP)
           {
            z=OrderModify(OrderTicket(),PR,SL,TP,0);
            return z;
           }
        }
     }
   return z;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateLots()
  {
   double _BALANC=AccountInfoDouble(ACCOUNT_BALANCE);
   double _FundPer=_BALANC*(Investment/100);
   if(_FundPer<=0)
     {
      _FundPer=100;
     }
   double v=(_FundPer/100)*Lots;
   v=NormalizeDouble(v,2);
   _LabelSet("Text_RR3",50,190,clrWhite,"Arial",12,"Investment : "+string(Investment)+"% = "+_Comma(_FundPer,2," ")+" | L:"+_Comma(v,4,""));
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getBALANC_Start()
  {
   double _BALANC=AccountInfoDouble(ACCOUNT_BALANCE);
   double _FundPer=_BALANC*(Investment/100);

   if(_BALANC>0)
     {
      _BALANC_Sart=_FundPer;
     }
   _BALANC_Goal=_BALANC_Sart*2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setWorkStopIsPayback()
  {
   double _BALANC=AccountInfoDouble(ACCOUNT_BALANCE);
//---
   double x=_BALANC-_BALANC_Sart;
   double _BALANC_Stop=_BALANC_Sart*0.75;
//---
   if(_BALANC_Sart<0)
     {
      _BALANC_Sart=1;
     }
   double ProfitPercent=(x/_BALANC_Sart)*100;

   _LabelSet("Text_RR2",20,170,clrWhite,"Arial",12,"Payback["+string(WorkStopIsPayback)+"]["+_Comma(x,2," ")+"] "+_Comma(ProfitPercent,1,"")+"| "+_Comma(_BALANC_Stop,2," "));

//if(x>=_BALANC_Stop)
//  {
//   WorkStopIsPayback=false;
//  }
//else
//  {
//   WorkStopIsPayback=true;
//  }
  }
//---
