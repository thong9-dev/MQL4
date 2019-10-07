//+------------------------------------------------------------------+
//|                                                     Maiyarap.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.2"
#property strict

//####################################################################
datetime Exp_Set=D'2019.08.30 23:59';     //D'2019.07.01 23:59'
//+--#################################################################

string eaName_Hader="Rap";
string eaName_TageOrder="Rap@";
string eaName_Ver="1.2v";
bool eaHidenObj=true;
bool eaDevelop=true;
//---

extern int eaMagicNumber=0;
extern string exStr="----------";//----------
extern double LotsStart=0.1;
extern double LotsMain=1.3;
extern double LotsSec=1.5;
extern string exStr1="----------";//----------
extern int Distance_Open=100;//Distance Open (Point)
extern int Distance_TP=130;//Distance TP (Point)
extern string exStr2="----------";//----------
extern double exSaveProfit=0.01;
//---

int Active=-1,ActiveBuy=-1,ActiveSell=-1;
double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
double Active_Lot=0,ActiveBuy_Lot=0,ActiveSell_Lot=0;
//---
double Balance=AccountBalance()+AccountCredit();
double Equity=AccountEquity();
long _ACCOUNT_LEVERAGE=AccountInfoInteger(ACCOUNT_LEVERAGE);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- create timer
   EventSetTimer(60);

   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);

   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_BUY)+"_O",0,0,clrDimGray,3,0,true,false,0);
   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_BUY)+"_X",0,0,clrDimGray,3,0,false,false,0);
   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_SELL)+"_O",0,0,clrDimGray,3,0,true,false,0);
   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_SELL)+"_X",0,0,clrDimGray,3,0,false,false,0);
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
   bool Exp_Date=true;
   if(Exp_Set>0)
     {
      Exp_Date=(Exp_Set-TimeCurrent())>=0;
     }
//---

   if(Exp_Date)
     {
      //if(AllowBuy) 
      Order_Open(OP_BUY,Ask,ActiveBuy,Active_Hold);
      //if(AllowSell) 
      Order_Open(OP_SELL,Bid,ActiveSell,Active_Hold);
     }

//---
   Balance=AccountBalance()+AccountCredit();
   Equity=AccountEquity();

   string iCMM=eaName_Hader+" "+eaName_Ver;
   if(true)
     {
      iCMM+="\n -----";

      iCMM+="\n OrderCnt: "+string(Active)+" [ "+string(ActiveBuy)+","+string(ActiveSell)+" ]";
      //iCMM+="\n LastOrder_BU: "+string(getLastOrder(OP_BUY,0))+" ["+getLastOrder_DistanceInfo(OP_BUY,pNULL,pNULL)+"]";
      //iCMM+="\n LastOrder_SE: "+string(getLastOrder(OP_SELL,0))+" ["+getLastOrder_DistanceInfo(OP_SELL,pNULL,pNULL)+"]";
      iCMM+="\n Lot: "+DoubleToStr(Active_Lot,2)+" [ "+DoubleToStr(ActiveBuy_Lot,2)+" | "+DoubleToStr(ActiveSell_Lot,2)+" ]";

      iCMM+="\n Hold: "+DoubleToStr(Active_Hold,2)+" [ "+DoubleToStr(ActiveBuy_Hold,2)+" | "+DoubleToStr(ActiveSell_Hold,2)+" ]";

      iCMM+="\n -----";
      //iCMM+="\n Cut-O["+string(CapitalProfit_Percent)+"%]: "+DoubleToStr(CapitalProfit_Amount,2);
      //iCMM+="\n Cut-B["+string(CapitalProfit_Percent_Buy)+"%]: "+DoubleToStr(CapitalProfit_Amount_Buy,2);
      //iCMM+="\n Cut-S["+string(CapitalProfit_Percent_Sell)+"%]: "+DoubleToStr(CapitalProfit_Amount_Sell,2);
      iCMM+="\n -----";
      iCMM+="\n AccountLeverage: "+string(_ACCOUNT_LEVERAGE);
      iCMM+="\n AccountEquity: "+DoubleToStr(Equity,2);
      iCMM+="\n AccountBalance: "+DoubleToStr(Balance,2);
      iCMM+="\n -----";
      iCMM+="\n "+string(TREND);

      //iCMM+="\n Ratio: "+DoubleToStr(Ratio,2);

      //if(eaDevelop)
      //  {
      //   iCMM+="\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
      //   iCMM+="\n -----";
      //   for(int i=0;i<ArraySize(Console);i++)
      //     {
      //      iCMM+="\n CMD_"+string(i)+":"+Console[i];
      //     }
      //  }
      //--- 
     }
   Comment(iCMM);
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
int TREND=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_Open(int OP_DIR,
                double Price_Open,
                int CNT,
                double Hold)
  {
//printf("On"+CNT);
//Element OrderForOrderSend
   int OS=-1;
   string OP_DIR_to_Str=(OP_DIR==OP_BUY)?"BUY":"SELL";
   string CMM=eaName_TageOrder+OP_DIR_to_Str+"_"+string(CNT+1);
//---
//Maneger
   double Price_Limit_O=0;
   double Price_Limit_X=0;

   double Order_Distance=-1;
   double Order_DistanceTP=-1;

   double LastOrder_OpenPrice=-1;

//---
   if(CNT==0)
     {
      //if(Authentication)
        {
         OS=OrderSend(Symbol(),OP_DIR,LotsStart,Price_Open,100,0,0,CMM,eaMagicNumber,0);
        }
     }
   else
     {

      //---      

      LastOrder_OpenPrice=getScopeOrder(OP_DIR);

      //Order_Distance=100;
      Order_Distance=Distance_Open/MathPow(10,Digits);
      if(OP_DIR==OP_BUY)
         Order_Distance=Order_Distance*(-1);

      Order_DistanceTP=Distance_TP/MathPow(10,Digits);
      if(OP_DIR==OP_SELL)
         Order_DistanceTP=Order_DistanceTP*(-1);

      Price_Limit_O=LastOrder_OpenPrice+Order_DistanceTP;
      Price_Limit_X=LastOrder_OpenPrice+Order_Distance;

      //-----------------------------------------------
      //Element Close

      bool NextRound=false;
      if(CNT>=2 && Hold>=exSaveProfit)
        {
         bool Condition_Close=(TREND==OP_BUY)?
                              Price_Open>=Price_Limit_O:
                              Price_Open<=Price_Limit_O;

         if(Condition_Close && Order_Distance!=-1)
           {
            NextRound=true;
            Order_CloseAll(eaMagicNumber);
           }
        }

      //-----------------------------------------------
      //Element SendOrder
      if(!NextRound)
        {
         bool Condition_Exe=(OP_DIR==OP_BUY)?
                            Price_Open<=Price_Limit_X:
                            Price_Open>=Price_Limit_X;

         if(Condition_Exe && Order_Distance!=-1)
           {
            TREND=OP_DIR;
            NormalizeDouble(Order_Distance,Digits);
            //ConsoleWrite("Condition_Exe: "+string(Condition_Exe)+" | Event: "+string(Mark_Event)+" | Order_Distance "+DoubleToStr(Order_Distance,Digits));
            //---

            double _Lots=Order_getLot(OP_DIR,CNT+1,"Main");
            //ConsoleWrite("Order_Open2: "+OP_DIR_to_Str(OP_DIR)+" "+_Lots);
            OS=OrderSend(Symbol(),OP_DIR,_Lots,Price_Open,100,0,0,CMM,eaMagicNumber,0);

            if(OS==0)
              {
               _Lots=Order_getLot(OP_DIR,CNT+1,"Sec");
               OrderNeg(OP_DIR,OP_DIR,Price_Open);
               OS=OrderSend(Symbol(),OP_DIR,_Lots,Price_Open,100,0,0,CMM,eaMagicNumber,0);
              }
           }

        }
     }
//+--------------------------
   color clrLimit_X=(OP_DIR==OP_BUY)?clrDodgerBlue:clrRed;

   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_DIR)+"_O",0,Price_Limit_O,clrLimit_X,3,0,true,false,0);

   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_DIR)+"_X",0,Price_Limit_X,clrLimit_X,3,0,false,false,0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderNeg(int _OP,int &OP,double &Price)
  {
   OP=(_OP==OP_BUY)?OP_SELL:OP_BUY;
   Price=(OP==OP_BUY)?Ask:Bid;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order_getLot(int OP_DIR,int CNT,string MODE)
  {
//double Post=(OP_DIR==OP_BUY)?LotB_Buy:LotB_Sell;
//double Table=(OP_DIR==OP_BUY)?LotsLv_Buy:LotsLv_Sell;

   double Post=LotsStart;
   double Table=(MODE=="Main")?LotsSec:LotsMain;

   double Post2=Post;

//printf(OP_DIR+" | Post: "+Post+" | Table"+Table);
//printf("---");

   for(int i=0;i<CNT+1;i++)
     {
      //printf("#"+string(i+1)+" "+DoubleToStr(Post,4)+" | "+DoubleToStr(Post2,2));
      if(i<CNT-1)
        {
         Post*=Table;
         Post=NormalizeDouble(Post,4);
         Post2=NormalizeDouble(Post,2);
        }
     }
   return NormalizeDouble(Post,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getScopeOrder(int OP_DIR)
  {
   double Place=(OP_DIR==OP_BUY)?9999999999.0:-9999999999.0;

   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      bool OS=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==eaMagicNumber) && 
         (OrderSymbol()==Symbol()) && 
         (OrderType()==OP_DIR)
         )
        {
         if(OP_DIR==OP_BUY && Place>OrderOpenPrice())
           {
            Place=OrderOpenPrice();
           }
         if(OP_DIR==OP_SELL && Place<OrderOpenPrice())
           {
            Place=OrderOpenPrice();
           }
        }
     }
//     
   return Place;
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
bool HLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   if(price==-1)
     {
      ObjectDelete(chart_ID,name);
      return false;
     }
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
