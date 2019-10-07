//+------------------------------------------------------------------+
//|                                                        RSI01.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.40"
#property strict
#property description "Exp : 2019.08.30 23:59" 
//####################################################################
datetime Exp_Set=0;     //D'2019.07.01 23:59'
//+--#################################################################
//---
extern double Lots=0.01;
extern string exs0=" --------------------------------- ";// ---------------------------------
extern int RSI_Digits=4;
extern string exs10=" ----------- ";// -----------
extern int RSI_Period=14;
extern ENUM_TIMEFRAMES RSI_TF=PERIOD_H1;
//extern string exs11=" ------------------ ";// ------------------
//extern int RSI_Period_2=14;
//extern ENUM_TIMEFRAMES RSI_TF_2=PERIOD_CURRENT;    //RSI_TF_2 #(current=off)
//extern string exs12=" ------------------ ";// ------------------
//extern int RSI_Period_3=14;   
//extern ENUM_TIMEFRAMES RSI_TF_3=PERIOD_CURRENT;    //RSI_TF_3 #(current=off)
extern string exs1=" --------------------------------- ";// ---------------------------------
extern double setOpen_Buy=10.0001;
extern double setClose_Buy=10.0001;
extern double setOpen_Sell=10.0001;
extern double setClose_Sell=10.0001;
extern string exs2=" --------------------------------- ";// ---------------------------------
extern int TP_Point=500;//TP (Point)
extern int SL_Point=300;//SL (Point)
extern string exs3=" --------------------------------- ";// ---------------------------------
extern int MagicNumber=552;
//---
double _TP_Point=-1,_SL_Point=-1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   OnTick();
   ChartSetInteger(0,CHART_SHOW_GRID,false);

   _TP_Point=TP_Point/MathPow(10,Digits);
   _SL_Point=SL_Point/MathPow(10,Digits);
//---
   NormalizeDouble(setOpen_Buy,RSI_Digits);
   NormalizeDouble(setClose_Buy,RSI_Digits);
   NormalizeDouble(setOpen_Sell,RSI_Digits);
   NormalizeDouble(setClose_Sell,RSI_Digits);
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
   int cntAll=getCntOrder(MagicNumber,Symbol(),
                          Active,ActiveBuy,ActiveSell,
                          Pending,PendingBuy,PendingSell,
                          Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                          Active_Lot,ActiveBuy_Lot,ActiveSell_Lot);

   Active_Hold=NormalizeDouble(Active_Hold,2);
   ActiveBuy_Hold=NormalizeDouble(ActiveBuy_Hold,2);
   ActiveSell_Hold=NormalizeDouble(ActiveSell_Hold,2);
//---
   double Dis_Inn,Dis_OutBuy=OP_BUY,Dis_OutSell=OP_SELL;
   int OP_Dir_Inn=Signal_RSI("Open",RSI_Period,Dis_Inn);

   int OP_Dir_Out_Buy=Signal_RSI("Close",RSI_Period,Dis_OutBuy);
   int OP_Dir_Out_Sell=Signal_RSI("Close",RSI_Period,Dis_OutSell);

//

   if(Active==0)
     {
      if(OP_Dir_Inn!=-1)
        {
         if(Exp_Date)
           {
            double TP=0,SL=0;
            OrderSLTP(OP_Dir_Inn,TP,SL);
            int ticket=OrderSend(Symbol(),OP_Dir_Inn,Lots,OrderPrice(OP_Dir_Inn),3,SL,TP,"My order ["+string(MagicNumber)+"]",MagicNumber,0);
            Print("Signal_RSI #IN : "+OrderStr(OP_Dir_Inn)+" | ticket : "+string(ticket));

           }
         else
           {
            Print("Exp_Date : "+string(Exp_Date)+" | EXP : "+string(Exp_Set)+" | Now : "+string(TimeCurrent()));
           }
        }
     }
   else
     {
      if(ActiveSell==1)
        {
         if(OP_Dir_Out_Sell==OP_BUY)
           {
            Print("Order_CloseAll #OUT : "+OrderStr(OP_SELL));
            Order_CloseAll(MagicNumber);
           }
        }
      if(ActiveBuy==1)
        {
         if(OP_Dir_Out_Buy==OP_SELL)
           {
            Print("Order_CloseAll #OUT : "+OrderStr(OP_BUY));
            Order_CloseAll(MagicNumber);
           }
        }
     }
//---
   string CMS="";

   CMS+="\n"+"RSI_0"+" : "+DoubleToStr(RSI_0,RSI_Digits);
   CMS+="\n"+"RSI_1"+" : "+DoubleToStr(RSI_1,RSI_Digits);

   CMS+="\n"+"----";
   CMS+="\n"+"Distand"+" : "+DoubleToStr(Dis_Inn,RSI_Digits);
//CMS+="\n"+"Setp"+" : "+Setp;

   CMS+="\n"+"----";
   CMS+="\n"+"OP_Dir_Inn"+" : "+OrderStr(OP_Dir_Inn);
   CMS+="\n"+"OP_Dir_Out_Buy"+" : "+OrderStr(OP_Dir_Out_Buy);
   CMS+="\n"+"OP_Dir_Out_Sell"+" : "+OrderStr(OP_Dir_Out_Sell);
   Comment(CMS);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
double RSI_0,RSI_1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_RSI(string Mode,int Period_,double &RSI_X)
  {
   int Close_Dir=int(RSI_X);
//---

   RSI_0=NormalizeDouble(iRSI(Symbol(),RSI_TF,Period_,PRICE_CLOSE,0),RSI_Digits);
   RSI_1=NormalizeDouble(iRSI(Symbol(),RSI_TF,Period_,PRICE_CLOSE,1),RSI_Digits);

   RSI_X=(RSI_0-RSI_1);
   RSI_X=NormalizeDouble(RSI_X,RSI_Digits);

//double RSI_Xp=RSI_X*MathPow(10,RSI_Digits);
   int OP_Dir=-1;
   if(Mode=="Open")
     {
      if(RSI_X>0)
        {
         if(RSI_X>=setOpen_Buy)
           {
            OP_Dir=OP_BUY;
           }
        }
      if(RSI_X<0)
        {
         if(RSI_X<=(setOpen_Sell*(-1)))
           {
            OP_Dir=OP_SELL;
           }
        }
     }
//---
   if(Mode=="Close")
     {
      if(Close_Dir==OP_BUY)
        {
         if(RSI_X<=(setClose_Buy*(-1)))
           {
            OP_Dir=OP_SELL;
           }
        }
      //---
      if(Close_Dir==OP_SELL)
        {
         if(RSI_X>=setClose_Sell)
           {
            OP_Dir=OP_BUY;
           }
        }
     }
//---
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
void OrderSLTP(int OP,double &TP,double &SL)
  {
   double POINT=OrderPrice(OP);

   if(_TP_Point!=0)
      TP=(OP==OP_BUY)?(POINT+_TP_Point):(POINT-_TP_Point);
   if(_SL_Point!=0)
      SL=(OP==OP_BUY)?(POINT-_SL_Point):(POINT+_SL_Point);

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
      if(OrderSymbol()==iOrderSymbol && OrderMagicNumber()==iMN)
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
