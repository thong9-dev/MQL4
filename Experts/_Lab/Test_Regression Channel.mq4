//+------------------------------------------------------------------+
//|                                      Test_Regression Channel.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   int bars=iBars(Symbol(),0);

   datetime date[];
   ArrayResize(date,bars);
   if(CopyTime(Symbol(),Period(),0,bars,date)==-1)
     {
      Print("Failed to copy time values! Error code = ",GetLastError());
     }

   int step=18;

   int A=bars-1,B=0;
   int X=A,Y=0;
   for(int i=0;i<2;i++)
     {
      B=A-step;
      RegressionCreate(0,"A"+cI(i),0,date[B],date[A],getClrLine(i),STYLE_SOLID,_InpWidth,_InpFill,false,false,_InpRayRight,false,10);
      A=B;
     }
   Y=A;
//---
   //GannFanCreate(0,"Test2",0,date[d1],price[p1],date[d2],InpScale,InpDirection,InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);

   RegressionCreate(0,"Main",0,date[Y],date[X],_InpColor,STYLE_SOLID,_InpWidth,_InpFill,false,false,_InpRayRight,false,10);

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
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getClrLine(int c)
  {
   if(MathMod(c,2)==0)
      return clrWhite;
   return clrYellow;
  }
input string          _InpName="Regression"; // Channel name 
input int             _InpDate1=10;          // 1 st point's date, % 
input int             _InpDate2=40;          // 2 nd point's date, % 
input color           _InpColor=clrRed;      // Channel color 
input ENUM_LINE_STYLE _InpStyle=STYLE_SOLID;  // Style of channel lines 
input int             _InpWidth=1;           // Width of channel lines 
input bool            _InpFill=false;        // Filling the channel with color 
input bool            _InpBack=false;        // Background channel 
input bool            _InpSelection=true;    // Highlight to move 
input bool            _InpRayRight=false;    // Channel's continuation to the right 
input bool            _InpHidden=true;       // Hidden in the object list 
input long            _InpZOrder=0;          // Priority for mouse click 
//+------------------------------------------------------------------+ 
//| Create Linear Regression Channel by the given coordinates        | 
//+------------------------------------------------------------------+ 
bool RegressionCreate(const long            chart_ID=0,        // chart's ID 
                      const string          name="Regression", // channel name 
                      const int             sub_window=0,      // subwindow index  
                      datetime              time1=0,           // first point time 
                      datetime              time2=0,           // second point time 
                      const color           clr=clrRed,        // channel color 
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // style of channel lines 
                      const int             width=1,           // width of channel lines 
                      const bool            fill=false,        // filling the channel with color 
                      const bool            back=false,        // in the background 
                      const bool            selection=true,    // highlight to move 
                      const bool            ray_right=false,   // channel's continuation to the right 
                      const bool            hidden=true,       // hidden in the object list 
                      const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeRegressionEmptyPoints(time1,time2);
//--- reset the error value 
   ResetLastError();
//--- create a channel by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_REGRESSION,sub_window,time1,0,time2,0))
     {
      RegressionPointChange(chart_ID,name,0,time1);
      RegressionPointChange(chart_ID,name,1,time2);
     }
//--- set channel color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set style of the channel lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the channel lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the channel's anchor point                                  | 
//+------------------------------------------------------------------+ 
bool RegressionPointChange(const long   chart_ID=0,     // chart's ID 
                           const string name="Channel", // channel name 
                           const int    point_index=0,  // anchor point index 
                           datetime     time=0)         // anchor point time coordinate 
  {
//--- if point time is not set, move the point to the current bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,0))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the channel                                               | 
//+------------------------------------------------------------------+ 
bool RegressionDelete(const long   chart_ID=0,     // chart's ID 
                      const string name="Channel") // channel name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the channel 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the channel! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
void ChangeRegressionEmptyPoints(datetime &time1,datetime &time2)
  {
//--- if the second point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the first point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
  }
//+------------------------------------------------------------------+
bool GannFanCreate(const long            chart_ID=0,        // chart's ID 
                   const string          name="GannFan",    // fan name 
                   const int             sub_window=0,      // subwindow index 
                   datetime              time1=0,           // first point time 
                   double                price1=0,          // first point price 
                   datetime              time2=0,           // second point time 
                   const double          scale=1.0,         // scale 
                   const bool            direction=true,    // trend direction 
                   const color           clr=clrRed,        // fan color 
                   const ENUM_LINE_STYLE style=STYLE_SOLID, // style of fan lines 
                   const int             width=1,           // width of fan lines 
                   const bool            back=false,        // in the background 
                   const bool            selection=true,    // highlight to move 
                   const bool            hidden=true,       // hidden in the object list 
                   const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeGannFanEmptyPoints(time1,price1,time2);
//--- reset the error value 
   ResetLastError();
//--- create Gann Fan by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_GANNFAN,sub_window,time1,price1,time2,0))
     {
      Print(__FUNCTION__,
            ": failed to create \"Gann Fan\"! Error code = ",GetLastError());
      return(false);
     }
//--- change the scale (number of pips per bar) 
   ObjectSetDouble(chart_ID,name,OBJPROP_SCALE,scale);
//--- change Gann Fan's trend direction (true - descending, false - ascending) 
   ObjectSetInteger(chart_ID,name,OBJPROP_DIRECTION,direction);
//--- set fan color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set display style of the fan lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the fan lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the fan for moving 
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
void ChangeGannFanEmptyPoints(datetime &time1,double &price1,datetime &time2)
  {
//--- if the second point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the first point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
//--- if the first point's price is not set, it will have Bid value 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
