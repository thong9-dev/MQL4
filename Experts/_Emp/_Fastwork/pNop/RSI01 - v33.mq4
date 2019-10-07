//+------------------------------------------------------------------+
//|                                                        RSI01.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "3.50"
#property strict
//#property description "Exp : 2019.08.31 23:59" 
//####################################################################
datetime Exp_Set=0;     //D'2019.07.01 23:59'
//+--#################################################################
//---
extern double           Lots=0.01;
extern string           exs_1=" --------------------------------- ";// ---------------------------------
extern int              RSI_Digits=4;
extern double           Tolerance=0.0000;             //RSI Tolerance (+/-)#(current=off)
extern string           exs_2=" ----------- ";        // --------------------- RSI Main
extern int              RSI_Period_1=14;
extern ENUM_TIMEFRAMES  RSI_TF_1=PERIOD_H1;
extern double           set_1=1.0001;
double           setOpen_Buy_1=1.0001;
double           setOpen_Sel_1=1.0001;
extern string           exs_3=" - ";// -
double           setClose_Buy_1=0.0001;
double           setClose_Sel_1=0.0001;        //setClose_Sell_1
extern string           exs_4=" ------------------ "; // ---------------------------- RSI 2
extern int              RSI_Period_2=14;
extern ENUM_TIMEFRAMES  RSI_TF_2=PERIOD_CURRENT;      //RSI_TF_2 #(current=off)
extern double           set_2=1.0001;
double           setOpen_Buy_2=0.0001;
double           setOpen_Sel_2=0.0001;         //setOpen_Sel_3
extern string           exs_5=" ------------------ "; // ---------------------------- RSI 3
extern int              RSI_Period_3=14;
extern ENUM_TIMEFRAMES  RSI_TF_3=PERIOD_CURRENT;      //RSI_TF_3 #(current=off)
extern double           set_3=1.0001;
double           setOpen_Buy_3=0.0001;
double           setOpen_Sel_3=0.0001;         //setOpen_Sell_3
extern string           exs_6=" --------------------------------- ";// ---------------------------------
extern int              TP_Point=500;                 //TP (Point)
extern int              SL_Point=300;                 //SL (Point)
extern string           exs_7=" --------------------------------- ";// ---------------------------------
extern int              MagicNumber=553;
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

   setOpen_Buy_1=NormalizeDouble(set_1,Digits);
   setClose_Buy_1=NormalizeDouble(set_1,Digits);
   setOpen_Sel_1=NormalizeDouble(set_1,Digits);
   setClose_Sel_1=NormalizeDouble(set_1,Digits);

   setOpen_Buy_2=NormalizeDouble(set_2,Digits);
   setOpen_Sel_2=NormalizeDouble(set_2,Digits);

   setOpen_Buy_3=NormalizeDouble(set_3,Digits);
   setOpen_Sel_3=NormalizeDouble(set_3,Digits);
//---

//   setOpen_Buy_1=NormalizeDouble(setOpen_Buy_1,set_1_Open);
//   setClose_Buy_1=NormalizeDouble(setClose_Buy_1,set_1_Close);
//   setOpen_Sel_1=NormalizeDouble(setOpen_Sel_1,set_1_Open);
//   setClose_Sel_1=NormalizeDouble(setClose_Sel_1,set_1_Close);
//
//   setOpen_Buy_2=NormalizeDouble(setOpen_Buy_2,set_2);
//   setOpen_Sel_2=NormalizeDouble(setOpen_Sel_2,set_2);
//
//   setOpen_Buy_3=NormalizeDouble(setOpen_Buy_3,set_3);
//   setOpen_Sel_3=NormalizeDouble(setOpen_Sel_3,set_3);
   
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
void OnTick()
  {
//---
   bool Exp_Date=true;
   if(Exp_Set>0)
     {
      Exp_Date=(Exp_Set-TimeCurrent())>=0;
     }
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

//--- Var Signal
   double Dis_Inn_1,Dis_Inn_2,Dis_Inn_3;

   double Dis_OutBuy=OP_BUY,Dis_OutSell=OP_SELL;

//--- Signal_In

   int OP_Dir_Inn_1=Signal_RSI("Open",RSI_TF_1,RSI_Period_1,setOpen_Buy_1,setOpen_Sel_1,Dis_Inn_1);
   int OP_Dir_Inn_2=Signal_RSI("Open",RSI_TF_2,RSI_Period_2,setOpen_Buy_2,setOpen_Sel_2,Dis_Inn_2);
   int OP_Dir_Inn_3=Signal_RSI("Open",RSI_TF_3,RSI_Period_3,setOpen_Buy_3,setOpen_Sel_3,Dis_Inn_3);

// Signal Hub

   int OP_Dir_Inn=Signal_RSI_Hub(OP_Dir_Inn_1,OP_Dir_Inn_2,OP_Dir_Inn_3);
//--- Signal_Out
   int OP_Dir_Out_Buy=Signal_RSI("Close",RSI_TF_1,RSI_Period_1,setClose_Buy_1,setClose_Sel_1,Dis_OutBuy);
   int OP_Dir_Out_Sel=Signal_RSI("Close",RSI_TF_1,RSI_Period_1,setClose_Buy_1,setClose_Sel_1,Dis_OutSell);

//

   if(Active==0)
     {
      if(OP_Dir_Inn!=-1)
        {
         if(Exp_Date)
           {
            double TP=0,SL=0;
            OrderSLTP(OP_Dir_Inn,TP,SL);
            int ticket=OrderSend(Symbol(),OP_Dir_Inn,Lots,OrderPrice(OP_Dir_Inn),3,SL,TP,"RSI01 ["+string(MagicNumber)+"]",MagicNumber,0);
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
         if(OP_Dir_Out_Sel==OP_BUY)
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
   double RSI_0m=NormalizeDouble(iRSI(Symbol(),RSI_TF_1,RSI_Period_1,PRICE_CLOSE,0),RSI_Digits);
   double RSI_1m=NormalizeDouble(iRSI(Symbol(),RSI_TF_1,RSI_Period_1,PRICE_CLOSE,1),RSI_Digits);


   string CMS="";

   CMS+="\n"+"RSI_0"+" : "+DoubleToStr(RSI_0m,RSI_Digits);
   CMS+="\n"+"RSI_1"+" : "+DoubleToStr(RSI_1m,RSI_Digits);

   CMS+="\n"+"--";
   CMS+="\n"+"Distand_1"+" : "+DoubleToStr(Dis_Inn_1,RSI_Digits);
   CMS+="\n"+"Distand_2"+" : "+DoubleToStr(Dis_Inn_2,RSI_Digits);
   CMS+="\n"+"Distand_3"+" : "+DoubleToStr(Dis_Inn_3,RSI_Digits);

//CMS+="\n"+"Setp"+" : "+Setp;

   CMS+="\n"+"*----";
   CMS+="\n"+"OP_Dir_Inn_1 ["+string(RSI_Period_1)+"|"+TFtoStr(RSI_TF_1)+"]"+" : "+OrderStr(OP_Dir_Inn_1);
   CMS+="\n"+"OP_Dir_Inn_2 ["+string(RSI_Period_2)+"|"+TFtoStr(RSI_TF_2)+"]"+" : "+OrderStr(OP_Dir_Inn_2);
   CMS+="\n"+"OP_Dir_Inn_3 ["+string(RSI_Period_3)+"|"+TFtoStr(RSI_TF_3)+"]"+" : "+OrderStr(OP_Dir_Inn_3);
   CMS+="\n"+"*----";
   CMS+="\n"+"OP_Dir_Inn"+" : "+OrderStr(OP_Dir_Inn);

   CMS+="\n"+"*----";
   CMS+="\n"+"OP_Dir_Out_Buy"+" : "+OrderStr(OP_Dir_Out_Buy);
   CMS+="\n"+"OP_Dir_Out_Sel"+" : "+OrderStr(OP_Dir_Out_Sel);
   Comment(CMS);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
double RSI_0,RSI_1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_RSI(string Mode,int TF,int Period_,double setBuy,double setSel,double &RSI_X)
  {

   int OP_Dir=-1;
   int Close_Dir=int(RSI_X);

   double setBuy_T=setBuy+Tolerance;
   double setSel_T=setSel+Tolerance;

//---
   if(TF!=PERIOD_CURRENT)
     {

      RSI_0=NormalizeDouble(iRSI(Symbol(),TF,Period_,PRICE_CLOSE,0),RSI_Digits);
      RSI_1=NormalizeDouble(iRSI(Symbol(),TF,Period_,PRICE_CLOSE,1),RSI_Digits);

      RSI_X=NormalizeDouble((RSI_0-RSI_1),RSI_Digits);

      //double RSI_Xp=RSI_X*MathPow(10,RSI_Digits);

      if(Mode=="Open")
        {
         if(RSI_X>0)
           {
            if(
               ((RSI_X>=setBuy) && (RSI_X<=setBuy_T) && Tolerance!=0) || 
               (RSI_X>=setBuy && Tolerance==0)
               )
               OP_Dir=OP_BUY;
           }
         if(RSI_X<0)
           {
            if(
               ((RSI_X<=(setSel*(-1))) && (RSI_X>=(setSel_T*(-1))) && Tolerance!=0) || 
               (RSI_X<=(setSel*(-1)) && Tolerance==0)
               )
               OP_Dir=OP_SELL;
           }
        }
      //---
      if(Mode=="Close")
        {
         if(Close_Dir==OP_BUY)
           {
            if(
               ((RSI_X<=(setBuy*(-1))) && (RSI_X>=(setBuy_T*(-1))) && Tolerance!=0) || 
               (RSI_X<=(setBuy*(-1)) && Tolerance==0)
               )
               OP_Dir=OP_SELL;
           }
         //---
         if(Close_Dir==OP_SELL)
           {
            if(
               ((RSI_X>=setSel) && (RSI_X<=setSel_T) && Tolerance!=0) || 
               (RSI_X>=setSel && Tolerance==0)
               )
               OP_Dir=OP_BUY;
           }
        }
      //---
     }
   else
     {
      OP_Dir=-2;
     }
   return OP_Dir;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_RSI_Hub(int b1,int b2,int b3)
  {
   b2=(b2==-2)?b1:b2;
   b3=(b3==-2)?b1:b3;

   if(b1==b2 && b1==b3)
     {
      return b1;
     }

   return -1;
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
   return string(OP);
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
//|                                                                  |
//+------------------------------------------------------------------+
string TFtoStr(int tf)
  {
   switch(tf)
     {
      case  PERIOD_CURRENT:   return "off";
      case  PERIOD_M1:        return "1 M";
      case  PERIOD_M5:        return "5 M";
      case  PERIOD_M15:       return "15 M";
      case  PERIOD_M30:       return "30 M";
      case  PERIOD_H1:        return "1 H";
      case  PERIOD_H4:        return "4 H";
      case  PERIOD_D1:        return "1 D";
      case  PERIOD_W1:        return "1 W";
      case  PERIOD_MN1:       return "1 MN";
      default:                break;
     }
   return "-";
  }
//+------------------------------------------------------------------+
