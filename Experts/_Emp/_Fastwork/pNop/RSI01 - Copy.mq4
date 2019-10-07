//+------------------------------------------------------------------+
//|                                                        RSI01.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//####################################################################
datetime Exp_Set=0;     //D'2019.07.01 23:59'
//+--#################################################################
//---

extern int RSI_Digits=4;
extern int RSI_Period=14;
extern ENUM_TIMEFRAMES RSI_TF=PERIOD_H1;
extern double RSI_Set=10;
double Setp=RSI_Set/MathPow(10,RSI_Digits);

extern int MagicNumber=55;
//---

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   OnTick();
   ChartSetInteger(0,CHART_SHOW_GRID,false);

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
int Active=-1,ActiveBuy=-1,ActiveSell=-1;
double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
double Active_Lot=0,ActiveBuy_Lot=0,ActiveSell_Lot=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Bar_Mem=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   bool Exp_Date=true;
   if(Exp_Set>0)
     {
      Exp_Date=(Exp_Set-TimeCurrent())>=0;
     }
//---

//---
   int Pending=-1,PendingBuy=-1,PendingSell=-1;
// 
   int cntAll=getCntOrder(0,Symbol(),
                          Active,ActiveBuy,ActiveSell,
                          Pending,PendingBuy,PendingSell,
                          Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                          Active_Lot,ActiveBuy_Lot,ActiveSell_Lot);

   Active_Hold=NormalizeDouble(Active_Hold,2);
   ActiveBuy_Hold=NormalizeDouble(ActiveBuy_Hold,2);
   ActiveSell_Hold=NormalizeDouble(ActiveSell_Hold,2);
//---
   double Dis_Inn,Dis_Out;
   int OP_Dir_Inn=Signal_RSI(6,10,Dis_Inn);
   int OP_Dir_Out=Signal_RSI_Out(6,70,30);
//
//if(Bar_Mem!=Bars)
     {
      //Bar_Mem=Bars;

      if(Active==0)
        {
         if(OP_Dir_Inn!=-1 && OP_Dir_Out==-1 && Exp_Date)
           {
            int ticket=OrderSend(Symbol(),OP_Dir_Inn,0.1,OrderPrice(OP_Dir_Inn),3,0,0,"My order",MagicNumber,0);
           }
        }
      else
        {
         if(ActiveSell>=1)
           {
            if(OP_Dir_Out==OP_BUY)
              {
               Order_CloseAll(MagicNumber);
              }
            if(OP_Dir_Inn==OP_SELL && ActiveSell<2 && Active_Hold<=0)
              {
               int ticket=OrderSend(Symbol(),OP_SELL,0.1,OrderPrice(OP_SELL),3,0,0,"My order",MagicNumber,0);
              }
           }
         if(ActiveBuy>=1)
           {
            if(OP_Dir_Out==OP_SELL)
              {
               Order_CloseAll(MagicNumber);
              }
            if(OP_Dir_Inn==OP_BUY && ActiveBuy<2 && Active_Hold<=0)
              {
               int ticket=OrderSend(Symbol(),OP_BUY,0.1,OrderPrice(OP_BUY),3,0,0,"My order",MagicNumber,0);
              }
           }
        }
     }
//---
   string CMS="";

   CMS+="\n"+"RSI_0"+" : "+DoubleToStr(RSI_0,RSI_Digits);
   CMS+="\n"+"RSI_1"+" : "+DoubleToStr(RSI_1,RSI_Digits);

   CMS+="\n"+"----";
   CMS+="\n"+"Dis_Inn"+" : "+DoubleToStr(Dis_Inn,RSI_Digits);
   CMS+="\n"+"Dis_Out"+" : "+DoubleToStr(Dis_Out,RSI_Digits);
//CMS+="\n"+"Setp"+" : "+Setp;

   CMS+="\n"+"----";
   CMS+="\n"+"OP_Dir_Inn"+" : "+OrderStr(OP_Dir_Inn);
   CMS+="\n"+"OP_Dir_Out"+" : "+OrderStr(OP_Dir_Out);
   Comment(CMS);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
double RSI_0,RSI_1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_RSI(int Period_,double set,double &RSI_X)
  {

   RSI_0=NormalizeDouble(iRSI(Symbol(),RSI_TF,Period_,PRICE_CLOSE,1),RSI_Digits);
   RSI_1=NormalizeDouble(iRSI(Symbol(),RSI_TF,Period_,PRICE_CLOSE,0),RSI_Digits);

   RSI_X=(RSI_0-RSI_1);
   RSI_X=NormalizeDouble(RSI_X,RSI_Digits);

//double RSI_Xp=RSI_X*MathPow(10,RSI_Digits);

   int OP_Dir=-1;
   if(RSI_X>=set)
     {
      OP_Dir=OP_BUY;
     }
   else if(RSI_X<=(set*-1))
     {
      OP_Dir=OP_SELL;
     }
   return OP_Dir;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_RSI_Out(int Period_,double setUP,double setDW)
  {
   double RSI=NormalizeDouble(iRSI(Symbol(),RSI_TF,Period_,PRICE_CLOSE,1),RSI_Digits);

   int OP_Dir=-1;
   if(RSI>=setUP)
     {
      OP_Dir=OP_SELL;
     }
   if(RSI<=setDW)
     {
      OP_Dir=OP_BUY;
     }
   return OP_Dir;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderPrice(int OP)
  {
   if(OP==OP_BUY)    return Ask;
   if(OP==OP_SELL)   return Bid;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderStr(int OP)
  {
   if(OP==OP_BUY)    return "BUY";
   if(OP==OP_SELL)   return "SELL";
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
int getCntOrder(int iMN,string iOrderSymbol,
                int &aActive,int &aActiveBuy,int &aActiveSell,
                int &Pending,int &PendingBuy,int &PendingSell,
                double &aActive_Hold,double &aActiveBuy_Hold,double &aActiveSell_Hold,
                double &aActive_Lot,double &aActiveBuy_Lot,double &aActiveSell_Lot)

  {
   aActive_Hold=0;
   aActiveBuy_Hold=0;
   aActiveSell_Hold=0;

   aActive_Lot=0;
   aActiveBuy_Lot=0;
   aActiveSell_Lot=0;

   aActive=0;
   aActiveBuy=0;
   aActiveSell=0;

   Pending=0;
   PendingBuy=0;
   PendingSell=0;
//
   int cntOP_BUY=0;
   int cntOP_SELL=0;
   int cntOP_BUYLIMIT=0;
   int cntOP_SELLLIMIT=0;
   int cntOP_BUYSTOP=0;
   int cntOP_SELLSTOP=0;
//
   for(int icnt=0;icnt<OrdersTotal();icnt++) // for loop
     {
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      //if(OrderSymbol()==iOrderSymbol && OrderMagicNumber()==iMN)
        {
         int Type=OrderType();
         if(Type<=1)
            aActive++;
         else
            Pending++;
         //
         double Hold=OrderProfit()+OrderSwap()+OrderCommission();
         double Lot=OrderLots();

         if(Type==OP_BUY){        cntOP_BUY++;aActiveBuy_Hold+=Hold;aActiveBuy_Lot+=Lot;}
         if(Type==OP_SELL){       cntOP_SELL++;aActiveSell_Hold+=Hold;aActiveSell_Lot+=Lot;}
         if(Type==OP_BUYLIMIT)   cntOP_BUYLIMIT++;
         if(Type==OP_SELLLIMIT)  cntOP_SELLLIMIT++;
         if(Type==OP_BUYSTOP)    cntOP_BUYSTOP++;
         if(Type==OP_SELLSTOP)   cntOP_SELLSTOP++;
        }
     }
//---

   aActive_Hold=aActiveBuy_Hold+aActiveSell_Hold;

   aActive_Lot=aActiveBuy_Lot-aActiveSell_Lot;
//
   aActiveBuy=cntOP_BUY;
   aActiveSell=cntOP_SELL;
   PendingBuy=cntOP_BUYLIMIT+cntOP_BUYSTOP;
   PendingSell=cntOP_SELLLIMIT+cntOP_SELLSTOP;
//
   return Active+Pending;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll(int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)==true) && 
         (OrderSymbol()==Symbol()) && 
         (OrderMagicNumber()==Magic))
         //(OrderType()==OP_DIR) && )
        {
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }
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
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),100);
            if(GetLastError()==0){ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;}
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }
//+------------------------------------------------------------------+
