//+------------------------------------------------------------------+
//|                                                        Basic.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>
//---
extern int MGN=98;
extern int MN=6;
extern bool ShowDisplay=true;
extern double STEP=200;
bool op;
double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
double CNT_Atctive=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   P(__LINE__,__FUNCTION__,"+----------------------------------------","---------------------------------------------------+");
   setTemplate();
//--- create timer
   EventSetTimer(60);

//---
   Display();
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
   CNT_Atctive=_getOrderCNT_Ative(MGN,1,-1,"Cnt");
   Display();
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
void Display()
  {
   if(ShowDisplay)
     {
      string s="";
      getWorstPoint(MN,10000);
      s+="WorstPrice: "+cD(WorstPrice,Digits)+"["+cI(WorstBar)+"] | "+Comma(WorstPoint*MathPow(10,Digits),0," ");
      s+="\n"+"N active : "+cD(CNT_Atctive,3);

      Comment(s);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double WorstPrice,WorstPoint,WorstBar;
//+------------------------------------------------------------------+
void getWorstPoint(int n,double minp)
  {
   double min=9999999999,c=0;
   for(int i=0;i<n;i++)
     {
      c=iLow(NULL,PERIOD_MN1,i);
      if(c<=min)
        {
         min=c;
         WorstBar=i;
        }
     }
//---
   bool Modify=false;
   if(WorstPrice!=min)
     {
      WorstPrice=min;
      HLineCreate_(0,"LINE_WorstPoint","WorstPoint",0,WorstPrice,clrLime,0,1,0,true,false,0);
      Modify=true;
     }
//---
   bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   WorstPoint=NormalizeDouble((bid-min),Digits);

   setTrap(Modify,WorstPoint);
//---
  }
//+------------------------------------------------------------------+
double Coin;
bool lock=true;
int LowCase;
double LastTrap=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setTrap(bool Modify,double _WorstPoint)
  {
   double Trap=WorstPrice,TP;
   double step=(STEP/MathPow(10,Digits));

   if((CNT_Atctive==0 && lock) || Modify || (Bid-LastTrap>step*2))
     {
      LowCase=int((_WorstPoint/step)+0);
      Coin=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE)/LowCase,2);
      orderDeletePending_(1);
      lock=false;
     }
   if(CNT_Atctive>0)
     {
      lock=true;
     }

//P(__LINE__,"setTrap","_WorstPoint",_WorstPoint*MathPow(10,Digits),"step",step,"LowCase",LowCase,Digits);

   for(int i=0;i<LowCase*20;i++)
     {
      //HLineDelete(0,"LINE_Trap"+cI(i));
     }
//---
   int MGN_=0,OP_Trap=0;
   for(int i=0;i<LowCase;i++)
     {
      Trap+=step;
      Trap=NormalizeDouble(Trap,Digits);
      LastTrap=Trap;
      TP=NormalizeDouble(Trap+step,Digits);
      OP_Trap=getOP(Trap);
      //---

      //---
      //HLineCreate_(0,"LINE_Trap"+cI(i),"",0,Trap,clrYellow,3,1,0,false,false,0);
      //---
      MGN_=_MagicEncrypt(MGN,1,i);
      //---
      bool Find=_OrderFind(1,i);
      if(Find)
        {
         if(!getActive(Order_Type))
           {
            //Pending
            if(Order_Type==OP_Trap)
              {
               if(Order_OpenPrice!=Trap)
                 {
                  //op=OrderModify(Order_Ticket,Trap,0,TP,0);
                 }
              }
            else
              {
               op=OrderDelete(Order_Ticket);
               op=OrderSend(Symbol(),OP_Trap,getLots(Trap),Trap,100,0,TP,"",MGN_,0);
              }
           }
         else
           {
            //Active
            if(Modify)
              {
               double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL)/MathPow(10,Digits);
               //op=OrderModify(Order_Ticket,Trap,0,Trap+STOPLEVEL,0);
              }
           }
        }
      else
        {
         //if(getActive(Order_Type))

         op=OrderSend(Symbol(),OP_Trap,getLots(Trap),Trap,100,0,TP,"",MGN_,0);

        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLots(double price)
  {
   double CONTRACT_SIZE=100000/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE);
   double CALIBER=NormalizeDouble(Coin/((price-WorstPrice)*MathPow(10,Digits)),5);
   return NormalizeDouble(CALIBER*CONTRACT_SIZE,2);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getOP(double p)
  {
   if(p>SymbolInfoDouble(Symbol(),SYMBOL_BID))
      return OP_BUYSTOP;
   return OP_BUYLIMIT;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool getActive(int Type)
  {
   if(Type>=2)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_Ticket=0,Order_Type=0;
double Order_OpenPrice=0,Order_Lots=0;
//+------------------------------------------------------------------+
bool _OrderFind(int pin,int sub)
  {
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)
         continue;
      _MagicDecode(MGN,OrderMagicNumber());
      if(OrderMagic_Key==MGN &&
         OrderMagic_Pin==pin &&
         OrderMagic_Sub==sub &&
         OrderSymbol()==Symbol())
        {
         Order_OpenPrice=OrderOpenPrice();
         Order_Ticket=OrderTicket();
         Order_Type=OrderType();
         Order_Lots=OrderLots();
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderLookAround(int pin,int sub,double Price,int Range)
  {
   bool specify=false;
   if(sub<0)
      specify=true;

   double _Range=NormalizeDouble(Range/MathPow(10,Digits),Digits);

   double High_= NormalizeDouble(Price+_Range,Digits);
   double Low__= NormalizeDouble(Price-_Range,Digits);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)
         continue;
      _MagicDecode(MGN,OrderMagicNumber());
      //_LabelSet("Text_Order5",370,95,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# Decode "+OrderMagic_Pin+" Sub:"+OrderMagic_Sub,"");
      if(OrderMagic_Key==MGN &&
         OrderMagic_Pin==pin &&
         (OrderMagic_Sub==sub || specify) && 
         OrderSymbol()==Symbol())
        {
         if(Low__<=OrderOpenPrice() && High_>=OrderOpenPrice())
           {
            //_LabelSet("Text_Order4",370,80,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# LookAround--False p "+pin+" s "+sub,"");
            return false;
           }
        }
     }
//_LabelSet("Text_Order3",370,65,clrWhite,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# LookAround End--True p "+pin+" s "+sub,"");
   return true;

  }

int OrderTicketClose[1];
int OrderTicketDelete[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void orderDeletePending_(int v)
  {
   ArrayResize(OrderTicketDelete,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(MGN,OrderMagicNumber());

      if(OrderMagic_Key==MGN && OrderMagic_Pin==v && (OrderSymbol()==Symbol()) /*&& (OrderType()<=1)*/)
        {
         OrderTicketDelete[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
/*  for(int i=0;i<ArraySize(OrderTicketClose);i++)
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
*/
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
//+------------------------------------------------------------------+
