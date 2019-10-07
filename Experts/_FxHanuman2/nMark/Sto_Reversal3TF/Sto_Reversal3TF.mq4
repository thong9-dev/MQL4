//+------------------------------------------------------------------+
//|                                              Sto_Reversal3TF.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
string eaName_TageOrder="Amata_M@";
bool eaHidenObj=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
string symbol=Symbol();
int digit=int(MarketInfo(symbol,MODE_DIGITS));
int eaMagicNumber=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern double Lot_Start=0.01;
extern double Lot_Lv=1.5;
extern double Order_Distance=30;
extern double STO_Set=5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//---
   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,C'10,10,10');

   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);

   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);

//---

   Main();

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
   Main();
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
int OS;
int Bar_M5_Save=iBars(symbol,PERIOD_M5);
int Bar_M15_Save=iBars(symbol,PERIOD_M15);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main()
  {
//---
   int Active=-1,ActiveBuy=-1,ActiveSell=-1;
   int Pending=-1,PendingBuy=-1,PendingSell=-1;
   double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
// 
   int cntAll=getCntOrder(0,Symbol(),
                          Active,ActiveBuy,ActiveSell,
                          Pending,PendingBuy,PendingSell,
                          Active_Hold,ActiveBuy_Hold,ActiveSell_Hold);

   Active_Hold=NormalizeDouble(Active_Hold,2);
   ActiveBuy_Hold=NormalizeDouble(ActiveBuy_Hold,2);
   ActiveSell_Hold=NormalizeDouble(ActiveSell_Hold,2);

//+------------------------------------------------------------------+
   double Balance=AccountBalance()+AccountCredit();
//---
//H4

   double iSTO_H4_M=iStochastic(symbol,PERIOD_H4,5,3,3,MODE_SMA,0,0,0);

  
   bool STO_UP=iSTO_H4_M>=(100-STO_Set);
   bool STO_DW=iSTO_H4_M<=STO_Set;
//---
//M15
   double Price_Distance=-1;
   int Signal_M15_OP=Signal_M15(Price_Distance);
//---
//M5
   double iMA_M5_1=iMA(symbol,PERIOD_M5,50,0,MODE_SMA,PRICE_CLOSE,1);
   HLineCreate(0,eaName_TageOrder+"iMA_M5",0,iMA_M5_1,clrDimGray,3,0,false,false,0);

   double iMA_M5_2=iMA(symbol,PERIOD_M5,100,0,MODE_SMA,PRICE_CLOSE,1);
   HLineCreate(0,eaName_TageOrder+"iMA_M5_2",0,iMA_M5_2,clrDarkBlue,3,0,false,false,0);

   double TP_OnM5=iMA_M5_2;
//---
//Main
   int Bar_M15=iBars(symbol,PERIOD_M15);
   if(Bar_M15_Save!=Bar_M15)
     {
      Bar_M15_Save=Bar_M15;
      //---
      string Order_CMM="";
      double Order_Lots=-1;
      if(STO_UP || STO_DW)
        {
         if(STO_UP)
           {
            if(Signal_M15_OP==OP_SELL && Order_Area(OP_SELL,Bid,Order_Distance,Order_Lots))
              {
               Order_Lots=(ActiveSell==0)?Lot_Start:Order_Lots*Lot_Lv;
               OS=OrderSend(Symbol(),OP_SELL,Order_Lots,Bid,100,0,TP_OnM5,Order_CMM,eaMagicNumber,0);
              }
           }
         //--------------
         if(STO_DW)
           {
            if(Signal_M15_OP==OP_BUY && Order_Area(OP_BUY,Ask,Order_Distance,Order_Lots))
              {
               Order_Lots=(ActiveBuy==0)?Lot_Start:Order_Lots*Lot_Lv;
               OS=OrderSend(Symbol(),OP_BUY,Order_Lots,Ask,100,0,TP_OnM5,Order_CMM,eaMagicNumber,0);
              }
           }
        }
     }
//---
   int Bar_M5=iBars(symbol,PERIOD_M5);
   if(Bar_M5_Save!=Bar_M5)
     {
      Bar_M5_Save=Bar_M5;
      //      
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if((OrderSelect(pos,SELECT_BY_POS)==false))
            continue;
         if((OrderSymbol()==Symbol()) && 
            //(OrderType()==OP_BUY) && 
            (OrderMagicNumber()==eaMagicNumber))
           {
            double Price_TP=-1;

            if(OrderType()==OP_BUY)
              {
               if(OrderOpenPrice())
                 {

                 }
              }

            bool z=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP_OnM5,0,clrNONE);
           }
        }
     }
//---

   string iCMM=symbol;

   iCMM+="\n *** H4";
   iCMM+="\n iSTO_H4_M: "+DoubleToStr(iSTO_H4_M,4)+"| STO +-: "+string(STO_Set);
   iCMM+="\n iSTO_H4_M: "+string(STO_UP)+" | "+string(STO_DW);

   iCMM+="\n *** M15";
//iCMM+="\n *** PeriodBar: "+PeriodBar+" "+OnMain;

   iCMM+="\n Bar_M15: "+string(Bar_M15_Save)+" | "+string(Bar_M15);
   iCMM+="\n Price_Distance: "+DoubleToStr(Price_Distance,digit)+" [ "+OpToStr(Signal_M15_OP)+" ]";
   iCMM+="\n *** M5";
   iCMM+="\n iMA_M5: "+DoubleToStr(iMA_M5_1,digit);
/*
   iCMM+="\n ----- CMD_";
   for(int i=0;i<ArraySize(Console);i++)
     {
      iCMM+="\n "+string(i)+":"+Console[i];
     }
*/
   Comment(iCMM);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Order_Area(int OP_DIR,double Price,double Distance,double &lot)
  {
   bool R=false;
   int LineR=-1;
//---

   Distance=Distance/MathPow(10,Digits);
   int get=getLastOrder(OP_DIR,1);

   if(get!=-1)
     {

      double OPP=OrderOpenPrice();
      lot=OrderLots();

      double UP=NormalizeDouble(Price+Distance,Digits);
      double DW=NormalizeDouble(Price-Distance,Digits);


      bool DIR=(OP_DIR==OP_BUY)?Price<OPP:Price>OPP;

      if(DIR && (UP<=OPP || OPP>=DW))
        {
         R=true;
         LineR=__LINE__;
        }

     }
//     
   if(get==-1)
     {
      R=true;
      LineR=__LINE__;
     }
//     
   ConsoleWrite(OpToStr(OP_DIR)+" | Tic: "+string(get)+" | R"+string(LineR)+": "+string(R));

   return R;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getLastOrder(int OP_DIR,int rank)
  {
   bool find=false;
   int Count_Rank=0;
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      OS=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==eaMagicNumber) && 
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
int Signal_M15(double &Price_Distance)
  {

   double Price_Close=iClose(symbol,PERIOD_M15,1);
   double Price_Open=iOpen(symbol,PERIOD_M15,1);

   Price_Distance=NormalizeDouble(Price_Close-Price_Open,digit);

   if(Price_Distance>0)
      return OP_BUY;
   if(Price_Distance<0)
      return OP_SELL;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OpToStr(int OP)
  {
   return (OP==OP_BUY)?"BUY":"SELL";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Console[10];
string Console_Duplicate[10];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ConsoleWrite(string w)
  {
   for(int i=0;i<(ArraySize(Console)-1);i++)
      Console_Duplicate[i]=Console[i];
   for(int i=1;i<(ArraySize(Console));i++)
      Console[i]=Console_Duplicate[i-1];
   Console[0]="["+string(TimeCurrent())+"] "+w;
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getCntOrder(int iMN,string iOrderSymbol,
                int &Active,int &ActiveBuy,int &ActiveSell,
                int &Pending,int &PendingBuy,int &PendingSell,
                double &Active_Hold,double &ActiveBuy_Hold,double &ActiveSell_Hold)

  {
   Active=0;
   ActiveBuy=0;
   ActiveSell=0;

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
            Active++;
         else
            Pending++;
         //
         double Hold=OrderProfit()+OrderSwap()+OrderCommission();

         if(Type==OP_BUY){        cntOP_BUY++;ActiveBuy_Hold+=Hold;}
         if(Type==OP_SELL){       cntOP_SELL++;ActiveSell_Hold+=Hold;}
         if(Type==OP_BUYLIMIT)   cntOP_BUYLIMIT++;
         if(Type==OP_SELLLIMIT)  cntOP_SELLLIMIT++;
         if(Type==OP_BUYSTOP)    cntOP_BUYSTOP++;
         if(Type==OP_SELLSTOP)   cntOP_SELLSTOP++;
        }
     }
//---
   Active_Hold=ActiveBuy_Hold+ActiveSell_Hold;

   ActiveBuy=cntOP_BUY;
   ActiveSell=cntOP_SELL;
   PendingBuy=cntOP_BUYLIMIT+cntOP_BUYSTOP;
   PendingSell=cntOP_SELLLIMIT+cntOP_SELLSTOP;
//
   return Active+Pending;
  }
//+------------------------------------------------------------------+
