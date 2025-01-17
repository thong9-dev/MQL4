//+------------------------------------------------------------------+
//|                                               Martingal_Trap.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//double vdigits=MarketInfo(Symbol(),MODE_STOPLEVEL);
//printf("MODE_STOPLEVEL"+vdigits);
//---
   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);

   dpanCenter=NormalizeDouble(SpanCenter/MathPow(10,Digits),Digits);
   dpanTP=NormalizeDouble(SpanTP/MathPow(10,Digits),Digits);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
extern int exMA_Fast=25;//MA_Fast
extern int exMA_Slow=50;//MA_Slow
extern ENUM_MA_METHOD      exMA_Mode=MODE_EMA;//MA_METHOD
extern ENUM_APPLIED_PRICE  exMA_Mode2=PRICE_CLOSE;//MA_APPLIED

extern double exLost=0.01;
extern int _Magicnumber=0;
int OP_STRAT=OP_SELL;
int SpanCenter=90;
int SpanTP=135;
double dpanCenter=-1;
double dpanTP=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PIN_Price_Buy=-1,PIN_PriceTP_Buy=-1;
double PIN_Price_Sell=-1,PIN_PriceTP_Sell=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double STAT_MAXDD=999999999;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int rActive=0;int rcntOP_BUY=0;int rcntOP_SELL=0;
   int rPending=0;int rPending_Buy=0;int rPending_Sell=0;
   int rcntOP_SELLLIMIT=0;int rcntOP_BUYSTOP=0;
   int rcntOP_BUYLIMIT=0;int rcntOP_SELLSTOP=0;
   double rActive_Hold=0;double rActiveBuy_Hold=0;double rActiveSell_Hold=0;
   double rActive_Lot=0;double rActiveBuy_Lot=0;double rActiveSell_Lot=0;

   getCntOrder(_Magicnumber,Symbol(),
               rActive,rcntOP_BUY,rcntOP_SELL,
               rPending,rPending_Buy,rPending_Sell,
               rcntOP_SELLLIMIT,rcntOP_BUYSTOP,
               rcntOP_BUYLIMIT,rcntOP_SELLSTOP,
               rActive_Hold,rActiveBuy_Hold,rActiveSell_Hold,
               rActive_Lot,rActiveBuy_Lot,rActiveSell_Lot);

//---
     {
      if(STAT_MAXDD>rActive_Hold)
        {
         STAT_MAXDD=rActive_Hold;
        }
     }
//---

   int ticket=-1;
   if(rActive==0)
     {
      OP_STRAT=Chk_MA();

      if(OP_STRAT!=-1)
        {
         PIN_Price_Buy=(OP_STRAT==OP_BUY)?Ask:NormalizeDouble(Bid+dpanCenter,Digits);
         PIN_Price_Sell=(OP_STRAT==OP_SELL)?Bid:NormalizeDouble(Ask-dpanCenter,Digits);

         PIN_PriceTP_Buy=NormalizeDouble(PIN_Price_Buy+dpanTP,Digits);
         PIN_PriceTP_Sell=NormalizeDouble(PIN_Price_Sell-dpanTP,Digits);

         double Act_Open=(OP_STRAT==OP_BUY)?PIN_Price_Buy:PIN_Price_Sell;
         double Pen_Open=(OP_STRAT==OP_BUY)?PIN_Price_Sell:PIN_Price_Buy;

         ticket=OrderSend(Symbol(),OP_STRAT,OP_Lots(0),Act_Open,3,0,0,"My order",_Magicnumber,0);

         ticket=OrderSend(Symbol(),OP_SECOND_PEN(OP_STRAT),OP_Lots(1),Pen_Open,3,0,0,"My order",_Magicnumber,0);

         HLineCreate(0,"PIN_Price_Buy",0,
                     PIN_Price_Buy,
                     clrRoyalBlue,STYLE_SOLID,1,
                     false,false,true,false,0);
         HLineCreate(0,"PIN_Price_Sell",0,
                     PIN_Price_Sell,
                     clrTomato,STYLE_SOLID,1,
                     false,false,true,false,0);

         HLineCreate(0,"PIN_PriceTP_Buy",0,
                     PIN_PriceTP_Buy,
                     clrRoyalBlue,STYLE_DOT,1,
                     false,false,true,false,0);
         HLineCreate(0,"PIN_PriceTP_Sell",0,
                     PIN_PriceTP_Sell,
                     clrTomato,STYLE_DOT,1,
                     false,false,true,false,0);
        }

     }
   else
     {
      //ADD_Order
      if(rPending==0)
        {
         bool Even=EvenNumber(rActive);
         int OP_Master=-1;
         int OP=OP_ADD(Even,OP_Master);
         //Print(string(__LINE__)+" OP_Master : "+OP_Master);
         if(Even)
           {
            ticket=OrderSend(Symbol(),OP,OP_Lots(rActive),OP_PinPrice(OP_Master),3,0,0,"My order",_Magicnumber,0);
           }
         else
           {
            ticket=OrderSend(Symbol(),OP,OP_Lots(rActive),OP_PinPrice(OP_Master),3,0,0,"My order",_Magicnumber,0);
           }
        }
      //
      //PIN_PriceTP_Buy=NormalizeDouble(PIN_Price_Buy+dpanTP,Digits);
      //PIN_PriceTP_Sell=NormalizeDouble(PIN_Price_Sell-dpanTP,Digits);

      if(rActive_Hold>0)
        {
         if(Bid>PIN_PriceTP_Buy || Ask<PIN_PriceTP_Sell)
           {
            Order_ClearBoard(_Magicnumber);
           }
        }

     }
   string CMM="";
   CMM+="\n rActive_Hold : "+DoubleToStr(rActive_Hold,2);
   CMM+="\n STAT_MAXDD : "+DoubleToStr(STAT_MAXDD,2);
   CMM+="\n rActive : "+string(rActive);
   CMM+="\n rPending : "+string(rPending);
   CMM+="\n";
   CMM+="\n OP_STRAT : "+string(OP_STRAT);

   Comment(CMM);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EvenNumber(int v)
  {
   if(MathMod(v,2)==0)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OP_ADD(bool mode,int &DIR)
  {
   int r=-1;
   if(mode)
      DIR=OP_STRAT;
   else
      DIR=(OP_STRAT==OP_BUY)?OP_SELL:OP_BUY;
//---
   if(DIR==OP_BUY)
      r=OP_BUYSTOP;
   else
      r=OP_SELLSTOP;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OP_SECOND_ACT(int OP_DIR)
  {
   if(OP_DIR==OP_BUY)      return OP_SELL;
   if(OP_DIR==OP_SELL)     return OP_BUY;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OP_SECOND_PEN(int OP_DIR)
  {
   if(OP_DIR==OP_BUY)      return OP_SELLSTOP;
   if(OP_DIR==OP_SELL)     return OP_BUYSTOP;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OP_PinPrice(int OP_DIR)
  {
   if(OP_DIR==OP_BUY)      return PIN_Price_Buy;
   if(OP_DIR==OP_SELL)     return PIN_Price_Sell;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OP_PinPriceTP(int OP_DIR)
  {
   if(OP_DIR==OP_BUY)      return PIN_PriceTP_Buy;
   if(OP_DIR==OP_SELL)     return PIN_PriceTP_Sell;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OP_Lots(int n)
  {
   return NormalizeDouble(exLost*MathPow(2,n),2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getCntOrder(int mMagicnumber,string mSymbol,
                 int &rActive,int &rcntOP_BUY,int &rcntOP_SELL,
                 int &rPending,int &rPending_Buy,int &rPending_Sell,
                 int &rcntOP_SELLLIMIT,int &rcntOP_BUYSTOP,
                 int &rcntOP_BUYLIMIT,int &rcntOP_SELLSTOP,
                 double &rActive_Hold,double &rActiveBuy_Hold,double &rActiveSell_Hold,
                 double &rActive_Lot,double &rActiveBuy_Lot,double &rActiveSell_Lot)

  {

   for(int icnt=0;icnt<OrdersTotal();icnt++) // for loop
     {
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==mSymbol && 
         OrderMagicNumber()==mMagicnumber)
        {
         int Type=OrderType();
         if(Type<=1)
            rActive++;
         else
            rPending++;
         //
         double Hold=OrderProfit()+OrderSwap()+OrderCommission();
         double Lot=OrderLots();

         if(Type==OP_SELLLIMIT)  rcntOP_SELLLIMIT++;
         if(Type==OP_BUYSTOP)    rcntOP_BUYSTOP++;

         if(Type==OP_BUY){       rcntOP_BUY++;   rActiveBuy_Hold+=Hold;     rActiveBuy_Lot+=Lot;    }
         if(Type==OP_SELL){      rcntOP_SELL++;  rActiveSell_Hold+=Hold;    rActiveSell_Lot+=Lot;   }

         if(Type==OP_SELLSTOP)   rcntOP_SELLSTOP++;
         if(Type==OP_BUYLIMIT)   rcntOP_BUYLIMIT++;
        }
     }
//---

   rActive_Hold=rActiveBuy_Hold+rActiveSell_Hold;

   rActive_Lot=rActiveBuy_Lot-rActiveSell_Lot;
//
   rPending_Buy=rcntOP_BUYLIMIT+rcntOP_BUYSTOP;
   rPending_Sell=rcntOP_SELLLIMIT+rcntOP_SELLSTOP;
//
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selectionH=true,// highlight to move 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ResetLastError();

   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      if(!ObjectMove(chart_ID,name,0,0,price))
        {
        }
     }

   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selectionH);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_ClearBoard(int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)==false) && 
         (OrderSymbol()!=Symbol()) && 
         //(OrderType()!=OP_DIR) && 
         (OrderMagicNumber()!=Magic))
         continue;
      ORDER_TICKET_CLOSE[pos]=OrderTicket();
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(ORDER_TICKET_CLOSE);i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),100);
               if(GetLastError()==0){ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;}
              }
            else
              {
               if(OrderDelete(OrderTicket()))
                 {
                  ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;
                 }
              }
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Chk_MA()
  {
   string sym=Symbol();
   int tf=0;

//sym=Symbol();

//int    vdigits=(int)MarketInfo(sym,MODE_DIGITS);

   double iMA_Fast=iMA(sym,tf,exMA_Fast,0,exMA_Mode,exMA_Mode2,1);
   double iMA_Slow=iMA(sym,tf,exMA_Slow,0,exMA_Mode,exMA_Mode2,1);

   if(iMA_Fast==0 && iMA_Slow==0)
     {
      //clr=clrGray;
      //return sym+" | "+strTF(tf);
     }

   double r=iMA_Fast-iMA_Slow;
   int ans=-1;

   if(r>=0)
     {
      //clr=clrCornflowerBlue;
      ans=OP_BUY;
     }
   else if(r<0)
     {
      //clr=clrSalmon;
      ans=OP_SELL;
     }
   return ans;
  }
//+------------------------------------------------------------------+
