//+------------------------------------------------------------------+
//|                                                           BB.mq4 |
//|                                     Copyright 2019,Fxhanuman TH. |
//|                         https://fxhanuman.com/web/eafx/index.php |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Fxhanuman TH."
#property link      "https://fxhanuman.com/web/eafx/index.php"
#property version   "1.3"
#property strict
//---
enum ENUM_ONOFF
  {
   ENUM_ON=1,     //ON
   ENUM_OFF=0     //OFF
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_CALLTP
  {
   ENUM_MODE_CALLTP_FIX=0,
   ENUM_MODE_CALLTP_WG=1,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_CALLTP_From
  {
   ENUM_MODE_CALLTPF_Fix=1,
   ENUM_MODE_CALLTPF_Div=0,
  };
//---
extern int exMagic=159;
extern string              exLine1=" ---------- ";   // --
//---
extern int exBB_SignalDefen_Point=50;
extern int exDistance_Next=400;
extern int exDistance_TP1=440;
extern int exDistance_TP=40;
double Distance_Next =NormalizeDouble(exDistance_Next/MathPow(10,Digits),Digits);
double Distance_TP1  =NormalizeDouble(exDistance_TP1/MathPow(10,Digits),Digits);
double Distance_TP   =NormalizeDouble(exDistance_TP/MathPow(10,Digits),Digits);
//---
extern string              exLine12=" ------------------------------ ";   // # Lot -----
extern double  LotStart=1;
double  LotMulti=1.5;
extern string              exLine13=" ------------------------------ ";   // # Order -----
extern int                 exMaxOrder     =7;                     //MaxOrder
extern double              exMarginSet    =1000;                  //Margin Level
ENUM_MODE_CALLTP        exModeCallTP      =ENUM_MODE_CALLTP_FIX;
ENUM_MODE_CALLTP_From   exMODE_CALLTP_From=ENUM_MODE_CALLTPF_Fix;
//---
extern string              exLine2=" ------------------------------ ";   // # ---------- RSI ----------
extern ENUM_ONOFF                 RSIS_H01=ENUM_ON;
extern ENUM_ONOFF                 RSIS_M30=ENUM_ON;
extern ENUM_ONOFF                 RSIS_M15=ENUM_ON;
extern ENUM_ONOFF                 RSIS_M01=ENUM_ON;

extern ENUM_APPLIED_PRICE  RSI_MT         =PRICE_CLOSE;     // RSI AppliedPrice
extern int                 RSI_Period     =14;              // RSI Period
extern string              exLine21       =" # ";           // -
extern double              RSI_OverBuy    =70;
extern double              RSI_OverSell   =30;
//---
extern string              exLine3=" ------------------------------ ";   // # ---------- Moving Averrages ----------
extern ENUM_MA_METHOD      MA_METHOD_1   =MODE_EMA;
extern int                 MA_Period_1   =14;
extern ENUM_APPLIED_PRICE  MA_AP_1       =PRICE_CLOSE;
extern ENUM_TIMEFRAMES     MA_TF_1       =PERIOD_CURRENT;
extern string              exLine31=" # ";                             // # MA 2 -----
extern ENUM_MA_METHOD      MA_METHOD_2   =MODE_EMA;
extern int                 MA_Period_2   =25;
extern ENUM_APPLIED_PRICE  MA_AP_2       =PRICE_CLOSE;
extern ENUM_TIMEFRAMES     MA_TF_2       =PERIOD_CURRENT;
//extern string              exLine32=" # ";                              // # MA 3 -----
//extern ENUM_MA_METHOD      MA_METHOD_3   =MODE_EMA;
//extern int                 MA_Period_3   =75;
//extern ENUM_APPLIED_PRICE  MA_AP_3       =PRICE_CLOSE;
//extern ENUM_TIMEFRAMES     MA_TF_3       =PERIOD_CURRENT;
//---
extern string              exLine4=" ------------------------------ ";   // # ---------- Bollinger Bands ----------
extern ENUM_TIMEFRAMES     BB_TF       =PERIOD_CURRENT;
extern int                 BB_Period   =25;
extern double              BB_Deviatio =2;
extern ENUM_APPLIED_PRICE  BB_AP       =PRICE_CLOSE;
//

//---
//---
int Active=-1,ActiveBuy=-1,ActiveSell=-1;
double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
double Active_Lot=0,ActiveBuy_Lot=0,ActiveSell_Lot=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//---
   ChartSetInteger(0,CHART_SHOW_GRID,false);
//---

   OnTick();
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
void OnTick()
  {
//--- RSI
   int signal_RSI=Signal_RSI();
//Signal_RSI();

//--- MA
   double varMA1=-1,varMA2=-1;
   int signal_MA_Sel=Signal_MA(OP_SELLLIMIT,varMA1,varMA2);
   int signal_MA_Buy=Signal_MA(OP_BUYLIMIT,varMA1,varMA2);

//--- BB
   double varBands_UP,varBands_MM,varBands_DW;
   double PriceIndex_UP,PriceIndex_diff_UP;
   double PriceIndex_DW,PriceIndex_diff_DW;
//
   double Bands_DIFFMM=-1;
//
   int signal_BB_UP=Signal_BB(OP_SELLLIMIT,
                              varBands_UP,varBands_MM,varBands_DW,Bands_DIFFMM,
                              PriceIndex_UP,PriceIndex_diff_UP);
   int signal_BB_DW=Signal_BB(OP_BUYLIMIT,
                              varBands_UP,varBands_MM,varBands_DW,Bands_DIFFMM,
                              PriceIndex_DW,PriceIndex_diff_DW);

//--- Signal Hub
   int Signal_Result_Sel=Signal_Hub(signal_RSI,signal_MA_Sel,signal_BB_UP);
   int Signal_Result_Buy=Signal_Hub(signal_RSI,signal_MA_Buy,signal_BB_DW);

//--- Count Order
   int Pending=-1,PendingBuy=-1,PendingSell=-1;
//
   int cntAll=OrderCountHub(exMagic,Symbol(),
                            Active,ActiveBuy,ActiveSell,
                            Pending,PendingBuy,PendingSell,
                            Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                            Active_Lot,ActiveBuy_Lot,ActiveSell_Lot);
//--- %Magin
   double Magin_lv=NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),2);
   bool chkMagin=true;
   if(Active>0)
     {
      chkMagin=Magin_lv>=exMarginSet;
     }
//---
//ADD Test
//Distance_TP1=Bands_DIFFMM;
//Distance_Next=Bands_DIFFMM;
//---

//--- Orgainzer Order
//+------------------------------------------------------------------+
   if(ActiveSell==0)
     {
      if(Signal_Result_Sel==OP_SELLLIMIT && chkMagin)
        {
         I_SELL=Bid;

         I_SELL_TP=(exModeCallTP==ENUM_MODE_CALLTP_WG)?
                   OrderCalculator_PriceWg(OP_SELL,Distance_TP1):
                   NormalizeDouble(I_SELL-Distance_TP,Digits);

         I_SELL_New=NormalizeDouble(I_SELL+Distance_Next,Digits);

         double   TP=NormalizeDouble(I_SELL-Distance_TP1,Digits);
         printf("Lot(ActiveSell):: "+Lot(ActiveSell)+"| I_SELL:: "+I_SELL+"| TP::"+TP);

         bool     OS=OrderSend(Symbol(),OP_SELL,Lot(ActiveSell),I_SELL,30,0,TP,"",exMagic,0);
         //---
         HLineCreate(0,"SELL__TP",0,TP,clrTomato,STYLE_SOLID,1,true,false,0);
        }
      else
        {
         ObjectDelete(0,"SELL_New_");
         ObjectDelete(0,"SELL__TP");
        }
     }
   else
     {
      if(I_SELL_New==-1)
        {
         Order_getLast(OP_SELL,1);
         I_SELL_New=NormalizeDouble(OrderOpenPrice()+Distance_Next,Digits);
        }
      else
        {
         HLineCreate(0,"SELL_New_",0,I_SELL_New,clrTomato,STYLE_DASHDOT,1,false,false,0);
        }
      //---

      if(Bid>=I_SELL_New && ActiveSell<exMaxOrder && chkMagin)
        {

         I_SELL=Bid;
         I_SELL_New=NormalizeDouble(I_SELL+Distance_Next,Digits);

         bool OS=OrderSend(Symbol(),OP_SELL,Lot(ActiveSell),I_SELL,100,0,0,"",exMagic,0);

         //---
         if(exModeCallTP==ENUM_MODE_CALLTP_WG)
           {
            I_SELL_TP=OrderCalculator_PriceWg(OP_SELL,Distance_TP);
           }
         if(exModeCallTP==ENUM_MODE_CALLTP_FIX)
           {
            Order_getLast(OP_SELL,2);
            I_SELL_TP=NormalizeDouble(OrderOpenPrice()-Distance_TP,Digits);
           }
         HLineCreate(0,"SELL__TP",0,I_SELL_TP,clrTomato,STYLE_SOLID,1,true,false,0);
         //---

         for(int pos=0; pos<OrdersTotal(); pos++)
           {
            if((OrderSelect(pos,SELECT_BY_POS)==true) &&
               (OrderSymbol()==Symbol()) &&
               (OrderType()==OP_SELL) &&
               (OrderMagicNumber()==exMagic))
              {
               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),0,I_SELL_TP,0);
              }
           }
        }
      /*
      #  Modify TP
      if :: TP == -1 get NowBB
      for if :: TP != OrderTP --> Modify
      */

     }


//+------------------------------------------------------------------+
   if(ActiveBuy==0)
     {
      if(Signal_Result_Buy==OP_BUYLIMIT && chkMagin)
        {
         I__BUY=Ask;

         I_BUY__TP=(exModeCallTP==ENUM_MODE_CALLTP_WG)?
                   OrderCalculator_PriceWg(OP_BUY,Distance_TP):
                   NormalizeDouble(I__BUY+Distance_TP,Digits);

         I_BUY__New=NormalizeDouble(I__BUY-Distance_Next,Digits);

         double TP=NormalizeDouble(I__BUY+Distance_TP1,Digits);
         printf("Lot(ActiveBuy):: "+Lot(ActiveBuy)+"| I__BUY:: "+I__BUY+"| TP::"+TP);

         bool OS=OrderSend(Symbol(),OP_BUY,Lot(ActiveBuy),I__BUY,30,0,TP,"",exMagic,0);
         //---
         HLineCreate(0,"BUY__TP",0,TP,clrRoyalBlue,STYLE_SOLID,1,true,false,0);
        }
      else
        {
         ObjectDelete(0,"BUY__New");
         ObjectDelete(0,"BUY__TP");
        }
     }
   else
     {
      if(I_BUY__New==-1)
        {
         Order_getLast(OP_BUY,1);
         I_BUY__New=NormalizeDouble(OrderOpenPrice()-Distance_Next,Digits);
        }
      else
        {
         HLineCreate(0,"BUY__New",0,I_BUY__New,clrRoyalBlue,STYLE_DASHDOT,1,false,false,0);
        }
      //---

      if(Ask<=I_BUY__New && ActiveBuy<exMaxOrder && chkMagin)
        {
         I__BUY=Ask;
         I_BUY__New=NormalizeDouble(I__BUY-Distance_Next,Digits);

         bool OS=OrderSend(Symbol(),OP_BUY,Lot(ActiveBuy),I__BUY,30,0,0,"",exMagic,0);

         //---
         if(exModeCallTP==ENUM_MODE_CALLTP_WG)
           {
            I_BUY__TP=OrderCalculator_PriceWg(OP_BUY,Distance_TP);
           }
         if(exModeCallTP==ENUM_MODE_CALLTP_FIX)
           {
            Order_getLast(OP_BUY,2);
            I_BUY__TP=NormalizeDouble(OrderOpenPrice()+Distance_TP,Digits);
           }
         HLineCreate(0,"BUY__TP",0,I_BUY__TP,clrRoyalBlue,STYLE_SOLID,1,true,false,0);
         //---

         for(int pos=0; pos<OrdersTotal(); pos++)
           {
            if((OrderSelect(pos,SELECT_BY_POS)==true) &&
               (OrderSymbol()==Symbol()) &&
               (OrderType()==OP_BUY) &&
               (OrderMagicNumber()==exMagic))
              {
               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),0,I_BUY__TP,0);
              }
           }
        }
      /*
      #  Modify TP
      if :: TP == -1 get NowBB
      for if :: TP != OrderTP --> Modify
      */
     }


//+------------------------------------------------------------------+

//---

//--- Comment

   string CMM="";
//CMM+="\n"+"varRSI : "+DoubleToStr(varRSI,4);
   CMM+="\n"+"signal_RSI : "+Signal_IntegerToString(signal_RSI);
   CMM+="\n ---";
   CMM+="\n"+"varRSI1 : ["+string(MA_Period_1)+"] : "+DoubleToStr(varMA1,Digits);
   CMM+="\n"+"varRSI2 : ["+string(MA_Period_2)+"] : "+DoubleToStr(varMA2,Digits);
   CMM+="\n"+"signal_MA : "+Signal_IntegerToString(signal_MA_Sel);
   CMM+="\n"+"signal_MA : "+Signal_IntegerToString(signal_MA_Buy);
   CMM+="\n ---";
   CMM+="\n"+"varBands_UP : ["+string(BB_Period)+"] : "+DoubleToStr(varBands_UP,Digits);
   CMM+="\n"+"varBands_MM : ["+string(BB_Period)+"] : "+DoubleToStr(varBands_MM,Digits);
   CMM+="\n"+"varBands_DW : ["+string(BB_Period)+"] : "+DoubleToStr(varBands_DW,Digits);
   CMM+="\n -";
   CMM+="\n"+"BB_SignalDefen_Point : "+DoubleToStr(BB_SignalDefen_Point,Digits);
   CMM+="\n"+"signal_BUP : "+DoubleToStr(PriceIndex_diff_UP,Digits)+" : "+Signal_IntegerToString(signal_BB_UP);
   CMM+="\n"+"signal_BDW : "+DoubleToStr(PriceIndex_diff_DW,Digits)+" : "+Signal_IntegerToString(signal_BB_DW);
   CMM+="\n ---";
   CMM+="\n"+"Signal_Result_Sel : "+Signal_IntegerToString(Signal_Result_Sel);
   CMM+="\n"+"Signal_Result_Buy : "+Signal_IntegerToString(Signal_Result_Buy);
   CMM+="\n ---";
   CMM+="\n"+"Sel : "+string(ActiveSell)+" | "+string(PendingSell);
   CMM+="\n"+"Buy : "+string(ActiveBuy)+" | "+string(PendingBuy);

   CMM+="\n ---";
   CMM+="\n"+"Magin_lv : "+DoubleToStr(Magin_lv,2);
   CMM+="\n"+"chkMagin : "+string(chkMagin);


   CMM+="\n ---";
   CMM+="\n"+"Distance_TP1 : "+DoubleToStr(Distance_TP1,Digits);


   Comment(CMM);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double I_SELL=-1,I_SELL_New=-1,I_SELL_TP=-1;
double I__BUY=-1,I_BUY__New=-1,I_BUY__TP=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndexPrice(int mode,double Nextold)
  {
   if(mode==OP_SELLLIMIT)
     {
      I_SELL_New=NormalizeDouble(Nextold+Distance_Next,Digits);
     }

   if(mode==OP_BUYLIMIT)
     {
      I_BUY__New=NormalizeDouble(Nextold-Distance_Next,Digits);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lot(int cnt)
  {
//double v=NormalizeDouble(LotStart*MathPow(LotMulti,double(cnt)),2);
   double v=NormalizeDouble(LotStart*MathPow(2,double(cnt)),2);
   printf(string(cnt)+" | "+DoubleToStr(v,4));
   return v;
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
int Signal_Hub(int RSI,int MA,int BB)
  {
   if(RSI!=-1)
     {
      return (RSI== MA&&MA== BB)?RSI:-1;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_RSI()
  {
   int Result=-2;
   double RSI=-1;

   if(RSIS_H01==ENUM_ON)
      Result=Signal_Party(Result,Signal_RSIvar(PERIOD_H1,RSI));
   if(RSIS_M30==ENUM_ON)
      Result=Signal_Party(Result,Signal_RSIvar(PERIOD_M30,RSI));
   if(RSIS_M15==ENUM_ON)
      Result=Signal_Party(Result,Signal_RSIvar(PERIOD_M15,RSI));
   if(RSIS_M01==ENUM_ON)
      Result=Signal_Party(Result,Signal_RSIvar(PERIOD_M1,RSI));

   return Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_RSIvar(int _RSI_TF,double &varRSI)
  {
   varRSI=iRSI(NULL,_RSI_TF,RSI_Period,PRICE_CLOSE,0);

   if(varRSI>=RSI_OverBuy)
      return OP_SELLLIMIT;
   if(varRSI<=RSI_OverSell)
      return OP_BUYLIMIT;

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_Party(int Old,int New)
  {
   if(Old==-2)
      return New;
   if(Old==-1)
      return -1;
   if(Old==OP_SELLLIMIT && New==OP_SELLLIMIT)
      return OP_SELLLIMIT;
   if(Old==OP_BUYLIMIT && New==OP_BUYLIMIT)
      return OP_BUYLIMIT;
   return -3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_MA(int MODE,double &varMA1,double &varMA2)
  {
   double PriceIndex=(MODE==OP_SELLLIMIT)?Bid:Ask;

   varMA1=iMA(NULL,MA_TF_1,MA_Period_1,0,MA_METHOD_1,MA_AP_1,0);
   varMA2=iMA(NULL,MA_TF_2,MA_Period_2,0,MA_METHOD_2,MA_AP_2,0);

   if(varMA2<varMA1 && varMA1<PriceIndex && MODE==OP_SELLLIMIT)
      return OP_SELLLIMIT;
   if(varMA2>varMA1 && varMA1>PriceIndex && MODE==OP_BUYLIMIT)
      return OP_BUYLIMIT;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BB_SignalDefen_Point=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Signal_BB(int MODE,
              double &varBands_UP,double &varBands_MM,double &varBands_DW,double &varBands_DIFFMM,
              double &PriceIndex,double &PriceIndex_diff)
  {
   PriceIndex=(MODE==OP_SELLLIMIT)?Ask:Bid;
//---
   BB_SignalDefen_Point=NormalizeDouble(exBB_SignalDefen_Point/MathPow(10,Digits),Digits);

   varBands_UP=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_UPPER,0);
   varBands_MM=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_MAIN,0);
   varBands_DW=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_LOWER,0);
//
   varBands_DIFFMM=MathAbs(varBands_MM-varBands_UP);
//
   if(MODE==OP_SELLLIMIT)
     {
      PriceIndex_diff=NormalizeDouble(PriceIndex-varBands_UP,Digits);
      if(PriceIndex_diff>=BB_SignalDefen_Point)
        {
         PriceIndex=NormalizeDouble(varBands_UP+Distance_Next+BB_SignalDefen_Point,Digits);
         return MODE;
        }
     }

   if(MODE==OP_BUYLIMIT)
     {
      PriceIndex_diff=NormalizeDouble(varBands_DW-PriceIndex,Digits);
      if(PriceIndex_diff>=BB_SignalDefen_Point)
        {
         PriceIndex=NormalizeDouble(varBands_DW-Distance_Next-BB_SignalDefen_Point,Digits);
         return MODE;
        }
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Signal_IntegerToString(int v)
  {
   if(v==OP_SELLLIMIT)
      return "OP_SELLLIMIT";
   if(v==OP_BUYLIMIT)
      return "OP_BUYLIMIT";
   return "-1";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderCountHub(int iMN,string iOrderSymbol,
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
   for(int icnt=0; icnt<OrdersTotal(); icnt++) // for loop
     {
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==iOrderSymbol &&
         OrderMagicNumber()==iMN)
        {
         int Type=OrderType();
         if(Type<=1)
            aActive++;
         else
            Pending++;
         //
         double Hold=OrderProfit()+OrderSwap()+OrderCommission();
         double Lot=OrderLots();

         if(Type==OP_BUY)
           {
            cntOP_BUY++;
            aActiveBuy_Hold+=Hold;
            aActiveBuy_Lot+=Lot;
           }
         if(Type==OP_SELL)
           {
            cntOP_SELL++;
            aActiveSell_Hold+=Hold;
            aActiveSell_Lot+=Lot;
           }
         if(Type==OP_BUYLIMIT)
            cntOP_BUYLIMIT++;
         if(Type==OP_SELLLIMIT)
            cntOP_SELLLIMIT++;
         //if(Type==OP_BUYSTOP)       cntOP_BUYSTOP++;
         //if(Type==OP_SELLSTOP)      cntOP_SELLSTOP++;
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
   Active_Hold=NormalizeDouble(Active_Hold,2);
   ActiveBuy_Hold=NormalizeDouble(ActiveBuy_Hold,2);
   ActiveSell_Hold=NormalizeDouble(ActiveSell_Hold,2);
//
   return Active+Pending;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_PendingDelete(int SpecType)
  {

   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)==true) &&
         (OrderSymbol()==Symbol()) &&
         ((SpecType==-1 && OrderType()>OP_SELL) || (SpecType!=-1 && OrderType()==SpecType)) &&
         (OrderMagicNumber()==exMagic))
        {
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0; i<ArraySize(ORDER_TICKET_CLOSE); i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
           {
            bool z=OrderDelete(ORDER_TICKET_CLOSE[i]);
            //int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            //bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),100);
            if(GetLastError()==0)
              {
               ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;
              }
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
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
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      ObjectMove(chart_ID,name,0,0,price);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_getLast(int OP_DIR,int rank)
  {
   //bool find=false;
   int Count_Rank=0;
   for(int i=(OrdersTotal()-1); i>=0; i --)

     {
      bool OS=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==exMagic) &&
         (OrderSymbol()==Symbol()) &&
         (OrderType()==OP_DIR)
        )
        {
         Count_Rank++;
         if(Count_Rank==rank)
           {
             return OrderTicket();
           }
        }
     }
//
   //if(find)
      //return OrderTicket();
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_getStart(int OP_DIR,int rank)
  {
   bool find=false;
   int Count_Rank=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      bool OS=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==exMagic) &&
         (OrderSymbol()==Symbol()) &&
         (OrderType()==OP_DIR)
        )
        {
         Count_Rank++;
         if(Count_Rank==rank)
           {
            find=true;
            break;
           }
        }
     }
//
   if(find)
      return OrderTicket();
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderCalculator_PriceWg(int OP_DIR,double TP)
  {

   double SumPrd=0;
   double SumLot=0;
   double Cnt=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(
         (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) &&
         (OrderMagicNumber()==exMagic) &&
         (OrderSymbol()==Symbol()) &&
         (OrderType()==OP_DIR)
      )
        {
         SumPrd+=OrderOpenPrice()*OrderLots();
         SumLot+=OrderLots();
         Cnt++;
        }
     }
   if(SumLot!=0)
     {
      //---
      if(exMODE_CALLTP_From==ENUM_MODE_CALLTPF_Div)
        {
         double C=1;
         TP=(Distance_TP1/Cnt)*C;
        }
      //---

      if(OP_DIR==OP_BUY)
        {
         double r=NormalizeDouble((SumPrd/SumLot)+TP,Digits);
         HLineCreate(0,"Draft_TP"+string(OP_SELL),0,r,clrRoyalBlue,3,0,true,false,0);
         return r;

        }
      if(OP_DIR==OP_SELL)
        {
         double r=NormalizeDouble((SumPrd/SumLot)-TP,Digits);
         HLineCreate(0,"Draft_TP"+string(OP_SELL),0,r,clrTomato,3,0,true,false,0);
         return r;

        }
     }
   Print("PriceWG Err");
   return -1;
  }
//+------------------------------------------------------------------+
