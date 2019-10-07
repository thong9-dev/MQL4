//+------------------------------------------------------------------+
//|                                                 Test_Channel.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);

   datetime date[];
   double   price[];

   int accuracy=1000;

   ArrayResize(date,bars);
   ArrayResize(price,accuracy);

   if(CopyTime(Symbol(),Period(),0,bars,date)==-1)
     {
      Print("Failed to copy time values! Error code = ",GetLastError());
     }
   int x=100;
   int d1=bars-x;
   int d2=bars-1;
   int d3=bars-x;

   int p1=0;
   int p2=0;
   int p3=0;

//--- create the equidistant channel 
   if(!ChannelCreate(0,_InpName,0,date[d1],price[p1],date[d2],price[p2],date[d3],price[p3],_InpColor,
      STYLE_SOLID,_InpWidth,_InpFill,false,_InpSelection,_InpRayRight,false,_InpZOrder))
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
input string          _InpName="Channel";   // Channel name 
input int             _InpDate1=25;         // 1 st point's date, % 
input int             _InpPrice1=60;        // 1 st point's price, % 
input int             _InpDate2=65;         // 2 nd point's date, % 
input int             _InpPrice2=80;        // 2 nd point's price, % 
input int             _InpDate3=30;         // 3 rd point's date, % 
input int             _InpPrice3=40;        // 3 rd point's date, % 
input color           _InpColor=clrRed;     // Channel color 
input ENUM_LINE_STYLE _InpStyle=STYLE_DASH; // Style of channel lines 
input int             _InpWidth=1;          // Channel line width 
input bool            _InpBack=false;       // Background channel 
input bool            _InpFill=false;       // Filling the channel with color 
input bool            _InpSelection=true;   // Highlight to move 
input bool            _InpRayRight=false;   // Channel's continuation to the right 
input bool            _InpHidden=true;      // Hidden in the object list 
input long            _InpZOrder=0;         // Priority for mouse click 
//+------------------------------------------------------------------+ 
//| Create an equidistant channel by the given coordinates           | 
//+------------------------------------------------------------------+ 
bool ChannelCreate(const long            chart_ID=0,        // chart's ID 
                   const string          name="Channel",    // channel name 
                   const int             sub_window=0,      // subwindow index  
                   datetime              time1=0,           // first point time 
                   double                price1=0,          // first point price 
                   datetime              time2=0,           // second point time 
                   double                price2=0,          // second point price 
                   datetime              time3=0,           // third point time 
                   double                price3=0,          // third point price 
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
   ChangeChannelEmptyPoints(time1,price1,time2,price2,time3,price3);
//--- reset the error value 
   ResetLastError();
//--- create a channel by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_CHANNEL,sub_window,time1,price1,time2,price2,time3,price3))
     {
      Print(__FUNCTION__,
            ": failed to create an equidistant channel! Error code = ",GetLastError());
      return(false);
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
bool ChannelPointChange(const long   chart_ID=0,     // chart's ID 
                        const string name="Channel", // channel name 
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
//| Delete the channel                                               | 
//+------------------------------------------------------------------+ 
bool ChannelDelete(const long   chart_ID=0,     // chart's ID 
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
//+-------------------------------------------------------------------------+ 
//| Check the values of the channel's anchor points and set default values  | 
//| for empty ones                                                          | 
//+-------------------------------------------------------------------------+ 
void ChangeChannelEmptyPoints(datetime &time1,double &price1,datetime &time2,
                              double &price2,datetime &time3,double &price3)
  {
//--- if the second (right) point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value 
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first (left) point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
//--- if the first point's price is not set, move it 300 points higher than the second one 
   if(!price1)
      price1=price2+300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
//--- if the third point's time is not set, it coincides with the first point's one 
   if(!time3)
      time3=time1;
//--- if the third point's price is not set, it is equal to the second point's one 
   if(!price3)
      price3=price2;
  }
//+------------------------------------------------------------------+
