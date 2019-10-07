//+------------------------------------------------------------------+
//|                                                     Scap1Min.mq4 |
//|                                 Copyright 2019,Golden Master TH. |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
string eaNameOP_Tag="Scap1Min@";
extern int exMagic=357;

//---

extern int exBB_SignalDefen_Point=1;
double eaBB_SignalDefen_Point =NormalizeDouble(exBB_SignalDefen_Point/MathPow(10,Digits),Digits);
extern int exTail=100;
double eaTail =NormalizeDouble(exTail/MathPow(10,Digits),Digits);
extern int exStoploss=100;
double eaStoploss =NormalizeDouble(exStoploss/MathPow(10,Digits),Digits);


extern string              exLine4=" ------------------------------ ";   // # ---------- Bollinger Bands ----------
extern ENUM_TIMEFRAMES     BB_TF       =PERIOD_CURRENT;
extern int                 BB_Period   =30;
extern double              BB_Deviatio =1.5;
extern ENUM_APPLIED_PRICE  BB_AP       =PRICE_CLOSE;
//---
double varBar_BodyAvg=-1;
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

   OnTick();

   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);
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
int ticket=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double tDiff=-1;
double tUP=-1,tDW=-1;
bool tStatus=-1;
//---
int      ticketSell=-9;
double   Tail_Sell=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {



//---


   double STOPLEVEL =MarketInfo(Symbol(),MODE_STOPLEVEL)/MathPow(10,Digits);
   //STOPLEVEL=1/MathPow(10,Digits);
   STOPLEVEL=NormalizeDouble(STOPLEVEL,Digits);

   eaBB_SignalDefen_Point=STOPLEVEL;
//---

   int Pending=-1,PendingBuy=-1,PendingSell=-1;
//
   int cntAll=OrderCountHub(exMagic,Symbol(),
                            Active,ActiveBuy,ActiveSell,
                            Pending,PendingBuy,PendingSell,
                            Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                            Active_Lot,ActiveBuy_Lot,ActiveSell_Lot);
//Bar
   if(IsNewBar())
     {
      int n=5;
      Bar_BodyAvg(n);

      Bar_Frame(n,
                tUP,tDW,tDiff,
                tStatus);
     }
//---
   int RR=-9;
//if(tStatus)
     {
      if(PendingSell==0&&ActiveSell==0)
        {
         if((Bid-tDW)>=STOPLEVEL&&tStatus)
           {
            double OP_OPEN=NormalizeDouble(Bid-STOPLEVEL,Digits);
            ticket=OrderSend(Symbol(),OP_SELLSTOP,1,OP_OPEN,3,0,0,eaNameOP_Tag,exMagic,0);
            ticketSell=ticket;


            Tail_Sell=NormalizeDouble(tUP+eaTail,Digits);
            HLineCreate(0,"Tail_Sell",0,Tail_Sell,clrGray,STYLE_SOLID,1,false,false,0);

           }
        }
      if(PendingSell==1)
        {
         if(ticket<0)
           {
            Order_getLast(OP_SELLSTOP,1);
            ticketSell=OrderTicket();
           }

         if(Bid>Tail_Sell)
           {
            Tail_Sell=Bid;

            double OP=Tail_Sell-eaTail;

            if(OrderSelect(ticketSell,SELECT_BY_TICKET))
              {
               bool res=OrderModify(OrderTicket(),OP,0,0,0);
              }
           }
        }
      if(ActiveSell==1)
        {
         if(OrderSelect(ticketSell,SELECT_BY_TICKET))
           {
            double OP_OP=OrderOpenPrice();
            double OP_SL=OrderStopLoss();
            if(OP_SL==0)
              {
               double SL=NormalizeDouble(OP_OP+eaStoploss,Digits);
               bool res=OrderModify(ticketSell,OP_OP,SL,0,0);

               Tail_Sell=OP_OP;
              }
            else
              {
                 {
                  if(Ask<Tail_Sell)
                    {
                     Tail_Sell=Ask;
                     //---
                     double OP_SLnew=Tail_Sell+eaStoploss;
                     
                     if(Ask<=OP_OP)
                       {
                        //OP_SLnew=OP_OP;
                       }
               


                     if(OrderSelect(ticketSell,SELECT_BY_TICKET))
                       {
                        bool res=OrderModify(ticketSell,OP_OP,OP_SLnew,0,0);
                       }

                    }
                 }

              }
           }
        }
      //---
      if(PendingBuy==0)
        {
         if((tDW-Ask)>=STOPLEVEL)
           {
            double OP_OPEN=NormalizeDouble(tDW,Digits);
            //ticket=OrderSend(Symbol(),OP_BUYSTOP,1,OP_OPEN,3,0,0,eaNameOP_Tag,exMagic,0);
           }
        }
      if(PendingBuy==1)
        {

        }
     }
//---

//---

//
   string CMM="";

   CMM+="\n"+"STOPLEVEL : "+DoubleToStr(STOPLEVEL,Digits);
   CMM+="\n"+"varBar_BodyAvg : "+DoubleToStr(varBar_BodyAvg,Digits);

//CMM+="\n"+"varBar_BodyAvg : "+Bar_Body(tDiff);

   CMM+="\n"+"tUP : "+tUP;
   CMM+="\n"+"tDW : "+tDW;
   CMM+="\n"+"tDiff : "+DoubleToStr(tDiff,Digits);


   CMM+="\n ---";
   CMM+="\n"+"tStatus : "+tStatus;
   CMM+="\n"+"tRR : "+RR;

//CMM+="\n"+"BB_Deviatio : "+string(BB_Deviatio);
//CMM+="\n"+"varBands_UP : ["+string(BB_Period)+"] : "+DoubleToStr(varBands_UP,Digits);
//CMM+="\n"+"varBands_MM : ["+string(BB_Period)+"] : "+DoubleToStr(varBands_MM,Digits);
//CMM+="\n"+"varBands_DW : ["+string(BB_Period)+"] : "+DoubleToStr(varBands_DW,Digits);
//CMM+="\n -";
//CMM+="\n"+"BB_SignalDefen_Point : "+DoubleToStr(eaBB_SignalDefen_Point,Digits);
//CMM+="\n"+"signal_BUP : "+DoubleToStr(PriceIndex_diff_UP,Digits)+" : "+Signal_IntegerToString(signal_BB_UP);
//CMM+="\n"+"signal_BDW : "+DoubleToStr(PriceIndex_diff_DW,Digits)+" : "+Signal_IntegerToString(signal_BB_DW);
   CMM+="\n ---";
   Comment(CMM);
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
int BARS=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   if(BARS!=Bars(Symbol(),PERIOD_CURRENT)||BARS==-1)
     {
      BARS=Bars(Symbol(),PERIOD_CURRENT);
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ___Signal_BB(int MODE,
                 double &varBands_UP,double &varBands_MM,double &varBands_DW,double &varBands_DIFFMM,
                 double &PriceIndex,double &PriceIndex_diff)
  {
   PriceIndex=(MODE==OP_SELLLIMIT)?Ask:Bid;
//---
//eaBB_SignalDefen_Point=NormalizeDouble(exBB_SignalDefen_Point/MathPow(10,Digits),Digits);

   varBands_UP=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_UPPER,0);
   varBands_MM=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_MAIN,0);
   varBands_DW=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_LOWER,0);
//
   varBands_DIFFMM=MathAbs(varBands_MM-varBands_UP);
//

   PriceIndex_diff=(MODE==OP_SELL)?
                   NormalizeDouble(PriceIndex-varBands_MM,Digits):
                   NormalizeDouble(varBands_MM-PriceIndex,Digits);


   if(((MODE==OP_SELL)&&(PriceIndex_diff>=eaBB_SignalDefen_Point))||
      ((MODE==OP_BUY)&&(PriceIndex_diff>=eaBB_SignalDefen_Point)))
     {
      return MODE;
     }

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ___Signal_IntegerToString(int v)
  {
   if(v==OP_SELL)
      return "SELL";
   if(v==OP_BUY)
      return "BUY";
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
         //if(Type==OP_BUYLIMIT)
         //   cntOP_BUYLIMIT++;
         //if(Type==OP_SELLLIMIT)
         //   cntOP_SELLLIMIT++;
         if(Type==OP_BUYSTOP)
            cntOP_BUYSTOP++;
         if(Type==OP_SELLSTOP)
            cntOP_SELLSTOP++;
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
void Bar_Frame(int n,
               double &UP,double &DW,double &Diff_Defen,
               bool &Status)
  {
   Status=true;
//---
   string result[];
   int k=StringSplit(string(Bid),StringGetCharacter(".",0),result);

   DW=MathPow(10,StringLen(result[0])+1);
   UP=-1;
//---

   for(int i=1; i<n; i++)
     {
      double C=iClose(Symbol(),PERIOD_CURRENT,i);
      double O=iOpen(Symbol(),PERIOD_CURRENT,i);

      double _Hig=(C>O)?C:O;
      double _Low=(C>O)?O:C;

      if(UP<_Hig)
         UP=_Hig;
      if(DW>_Low)
         DW=_Low;
     }

//---
   color clrUp=clrTomato,clrDW=clrRoyalBlue;
//---

   Diff_Defen=MathAbs(UP-DW);
//20/MathPow(10,Digits)
   if(Diff_Defen>varBar_BodyAvg*2&&false)
     {
      clrUp=clrWhiteSmoke;
      clrDW=clrWhiteSmoke;
      Status=false;
     }
//---

   HLineCreate(0,"UP",0,UP,clrUp,STYLE_SOLID,1,false,false,0);
   HLineCreate(0,"DW",0,DW,clrDW,STYLE_SOLID,1,false,false,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bar_BodyAvg(int n)
  {

   double Sum=0;
   for(int i=1; i<n; i++)
     {
      double _Open=iHigh(Symbol(),PERIOD_CURRENT,i);
      double _Clos=iLow(Symbol(),PERIOD_CURRENT,i);
      Sum+=MathAbs(_Open-_Clos);
     }
   if(n!=0)
     {
      varBar_BodyAvg=NormalizeDouble(Sum/n,Digits);
      return varBar_BodyAvg;
     }
   return -1;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int __Bar_Body(double &_Diff)
  {
   double _Open=iOpen(Symbol(),PERIOD_CURRENT,0);
   double _Clos=iClose(Symbol(),PERIOD_CURRENT,0);
   _Diff=NormalizeDouble(_Clos-_Open,Digits);
   if(MathAbs(_Diff)>varBar_BodyAvg)
     {
      if(_Diff==0)
        {
         return -1;
        }
      else
        {
         if(_Diff>0)
           {
            return OP_SELL;
           }
         else
           {
            return OP_BUY;
           }
        }
     }
   return -2;
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
   bool find=false;
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
