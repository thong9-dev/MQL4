//+------------------------------------------------------------------+
//|                                                   BridgeScan.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>

extern double Delta=50;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll();

   int bars=iBars(Symbol(),0);

   datetime date[];
   ArrayResize(date,bars);
   if(CopyTime(Symbol(),Period(),0,bars,date)==-1)
     {
      Print("Failed to copy time values! Error code = ",GetLastError());
     }
//---

//--- create a rectangle 

//RectanglePointChange(0,InpName,0,date[d1],1255.42);
//RectanglePointChange(0,InpName,1,date[d2],1245.94);

//--- redraw the chart and wait for 1 second 
   ChartRedraw();
//---
   int Caldle_Range=366,Caldle_Focus=4;
   if(bars<Caldle_Range)
     {
      Caldle_Range=bars;
     }
   int d1=bars-1;
   int d2=bars-Caldle_Range;

   double _Open[],_Close[],_High[],_Low[];
   ArrayResize(_Open,Caldle_Focus+1);
   ArrayResize(_Close,Caldle_Focus+1);
   ArrayResize(_High,Caldle_Focus+1);
   ArrayResize(_Low,Caldle_Focus+1);
   double Max=-999999,Min=999999;
   bool chk=false;
   int Count=0;
//---
   for(int i=d1,n=0;i>=bars-Caldle_Range;i--,n++)
     {
      for(int j=i,k=0;j>=i-Caldle_Focus;j--,k++)
        {
         _Open[k]=iOpen(Symbol(),0,n+k);
         _Close[k]=iClose(Symbol(),0,n+k);

         _High[k]=iHigh(Symbol(),0,n+k);
         _Low[k]=iLow(Symbol(),0,n+k);

         //VLineCreate(0,InpName+cI(j),0,date[j],clrMagenta,2,InpWidth,InpBack,false,false,InpZOrder);
        }
      if(
         MathAbs(_Open[0]-_Open[1])<=(Delta*Point)
         && MathAbs(_Open[1]-_Open[2])<=(Delta*Point)
         && MathAbs(_Open[2]-_Open[3])<=(Delta*Point)
         && MathAbs(_Open[3]-_Open[4])<=(Delta*Point)
         && MathAbs(_Open[0]-_Open[4])<=(Delta*Point*1.618)
         )
        {
         chk=true;
         Count++;
         Max=-999999;Min=999999;
         for(int MaxLoop=0;MaxLoop<=Caldle_Focus;MaxLoop++)
           {
            if(Max<=_High[MaxLoop])
               Max=_High[MaxLoop];
            if(Min>=_Low[MaxLoop])
               Min=_Low[MaxLoop];
           }
         _RectangleCreate(0,"Rectangl"+cI(Count),0,date[d1],Max,date[i-Caldle_Focus],Min,getClrLine(Count),_InpStyle,_InpWidth,_InpFill,_InpBack,true,_InpHidden,_InpZOrder);

         VLineCreate(0,"RectanglA"+cI(Count),0,date[i],clrMagenta,2,InpWidth,InpBack,true,false,InpZOrder);
         VLineCreate(0,"RectanglB"+cI(Count),0,date[i-Caldle_Focus],clrMagenta,2,InpWidth,InpBack,true,false,InpZOrder);

         //HLineCreate_(0,"HLineCreate_","",0,_Open[0],clrBlue,2,0,0,true,false,0);

        }
      Comment(cI(n)+" | "+chk);
      //break;
      //VLineCreate(0,InpName+"1",0,date[i],clrMagenta,0,InpWidth,InpBack,false,false,InpZOrder);
     }
   VLineCreate(0,InpName,0,date[d2],clrYellow,3,InpWidth,InpBack,InpSelection,false,InpZOrder);
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
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
input string          _InpName="Rectangle"; // Rectangle name 
input int             _InpDate1=40;         // 1 st point's date, % 
input int             _InpPrice1=40;        // 1 st point's price, % 
input int             _InpDate2=60;         // 2 nd point's date, % 
input int             _InpPrice2=60;        // 2 nd point's price, % 
input color           _InpColor=clrRed;     // Rectangle color 
input ENUM_LINE_STYLE _InpStyle=STYLE_DASH; // Style of rectangle lines 
input int             _InpWidth=1;          // Width of rectangle lines 
input bool            _InpFill=true;        // Filling the rectangle with color 
input bool            _InpBack=true;       // Background rectangle 
input bool            _InpSelection=true;   // Highlight to move 
input bool            _InpHidden=false;      // Hidden in the object list 
input long            _InpZOrder=0;         // Priority for mouse click 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Create rectangle by the given coordinates                        | 
//+------------------------------------------------------------------+ 
bool _RectangleCreate(const long            chart_ID=0,// chart's ID 
                      const string          name="Rectangle",  // rectangle name 
                      const int             sub_window=0,      // subwindow index  
                      datetime              time1=0,           // first point time 
                      double                price1=0,          // first point price 
                      datetime              time2=0,           // second point time 
                      double                price2=0,          // second point price 
                      const color           clr=clrRed,        // rectangle color 
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines 
                      const int             width=1,           // width of rectangle lines 
                      const bool            fill=false,        // filling rectangle with color 
                      const bool            back=false,        // in the background 
                      const bool            selection=true,    // highlight to move 
                      const bool            hidden=true,       // hidden in the object list 
                      const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- create a rectangle by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      RectanglePointChange(0,name,0,time1,price1);
      RectanglePointChange(0,name,1,time2,price2);
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving 
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
//+------------------------------------------------------------------+ 
//| Move the rectangle anchor point                                  | 
//+------------------------------------------------------------------+ 
bool _RectanglePointChange(const long   chart_ID=0,// chart's ID 
                           const string name="Rectangle", // rectangle name 
                           const int    point_index=0,    // anchor point index 
                           datetime     time=0,           // anchor point time coordinate 
                           double       price=0)          // anchor point price coordinate 
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
//+------------------------------------------------------------------+
void _ChangeRectangleEmptyPoints(datetime &time1,double &price1,
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
