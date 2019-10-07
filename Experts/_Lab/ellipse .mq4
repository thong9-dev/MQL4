//+------------------------------------------------------------------+
//|                                                     ellipse .mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input string          InpName="Ellipse";         // Ellipse name 
input int             InpDate1=30;               // 1 st point's date, % 
input int             InpPrice1=20;              // 1 st point's price, % 
input int             InpDate2=70;               // 2 nd point's date, % 
input int             InpPrice2=80;              // 2 nd point's price, % 
input double          InpEllipseScale=0.2;       // Ellipse scale ratio 
input color           InpColor=clrRed;           // Ellipse color 
input ENUM_LINE_STYLE InpStyle=STYLE_DASHDOTDOT; // Style of ellipse lines 
input int             InpWidth=1;                // Width of ellipse lines 
input bool            InpFill=false;             // Filling ellipse with color 
input bool            InpBack=false;             // Background ellipse 
input bool            InpSelection=true;         // Highlight to move 
input bool            InpHidden=false;            // Hidden in the object list 
input long            InpZOrder=0;               // Priority for mouse click 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer

   EventSetTimer(60);
//---
//--- number of visible bars in the chart window 
   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
//--- price array size 
   int accuracy=1000;
//--- arrays for storing the date and price values to be used 
//--- for setting and changing ellipse anchor points' coordinates 
   datetime date[];
   double   price[];
//--- memory allocation 
   ArrayResize(date,bars);
   ArrayResize(price,accuracy);
//--- set as series 
   ArraySetAsSeries(date,true);
   ArraySetAsSeries(price,true);
//--- fill the array of dates 
   ResetLastError();
   if(CopyTime(Symbol(),Period(),0,bars,date)==-1)
     {
      Print("Failed to copy time values! Error code = ",GetLastError());
     }
//--- fill the array of prices 
//--- find the highest and lowest values of the chart 
   double max_price=ChartGetDouble(0,CHART_PRICE_MAX);
   double min_price=ChartGetDouble(0,CHART_PRICE_MIN);
//--- define a change step of a price and fill the array 
   double step=(max_price-min_price)/accuracy;
   for(int i=0;i<accuracy;i++)
      price[i]=min_price+i*step;
//--- define points for drawing the ellipse 
   int d1=InpDate1*(bars-1)/100;
   int d2=InpDate2*(bars-1)/100;
   int p1=InpPrice1*(accuracy-1)/100;
   int p2=InpPrice2*(accuracy-1)/100;
//--- create an ellipse 
   if(!EllipseCreate(0,InpName,0,date[d1],price[p1],date[d2],price[p2],Scale(),
      InpColor,InpStyle,InpWidth,InpFill,InpBack,InpSelection,InpHidden,InpZOrder))
     {
     }
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

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
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
bool EllipseCreate(const long            chart_ID=0,        // chart's ID 
                   const string          name="Ellipse",    // ellipse name 
                   const int             sub_window=0,      // subwindow index  
                   datetime              time1=0,           // first point time 
                   double                price1=0,          // first point price 
                   datetime              time2=0,           // second point time 
                   double                price2=0,          // second point price 
                   double                ellipse_scale=0,   // ellipse scale ratio  
                   const color           clr=clrRed,        // ellipse color 
                   const ENUM_LINE_STYLE style=STYLE_SOLID, // style of ellipse lines 
                   const int             width=1,           // width of ellipse lines 
                   const bool            fill=false,        // filling ellipse with color 
                   const bool            back=false,        // in the background 
                   const bool            selection=true,    // highlight to move 
                   const bool            hidden=true,       // hidden in the object list 
                   const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeEllipseEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- create an ellipse by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_ELLIPSE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create an ellipse! Error code = ",GetLastError());
      //return(false);
     }
//--- set ellipse scale ratio  
   ObjectSetDouble(chart_ID,name,OBJPROP_SCALE,ellipse_scale);
//--- set an ellipse color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set style of ellipse lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of ellipse lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the ellipse for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,InpHidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
bool EllipsePointChange(const long   chart_ID=0,     // chart's ID 
                        const string name="Ellipse", // ellipse name 
                        const int    point_index=0,  // anchor point index 
                        datetime     time=0,         // anchor point time coordinate 
                        double       price=0)        // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeEllipseEmptyPoints(datetime &time1,double &price1,
                              datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one 
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one 
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
double Scale()
  {
   double Scale=0;
   switch(Period())
     {
      //---- codes returned from trade server
      case PERIOD_M1:   Scale =  0.12; break;
      case PERIOD_M5:   Scale =  0.08; break;
      case PERIOD_M15:  Scale =  0.08; break;
      case PERIOD_M30:  Scale =  0.04; break;
      case PERIOD_H1:   Scale =  0.04; break;
      case PERIOD_H4:   Scale =  0.02; break;
      case PERIOD_D1:   Scale =  0.01; break;
      case PERIOD_W1:   Scale =  0.002; break;
      case PERIOD_MN1:  Scale =  0.002; break;
      default: break;
     }
   return Scale;
  }
//+------------------------------------------------------------------+
