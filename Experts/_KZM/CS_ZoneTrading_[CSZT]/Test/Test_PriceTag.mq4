//+------------------------------------------------------------------+
//|                                                Test_PriceTag.mq4 |
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
//--- create timer
   EventSetTimer(60);
   ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,false);
   PriceTag();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PriceTag()
  {

   int bar=int(ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0));
   int x,y,fontSize=7;
   ENUM_LINE_STYLE style=3;
   string Text;
   color clr=LimeGreen;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderSymbol()==Symbol())==false) continue;

      Text=PriceTag_getText(OrderType(),OrderLots());
      ChartTimePriceToXY(0,0,Time[bar],OrderOpenPrice(),x,y);
      LabelCreate(0,"Label PriceTag-"+c(OrderTicket()),0,x+5,y-14,0,Text,"",fontSize,clrWhite,0,false,false,false,0);
      HLineCreate_(0,"LINE_PriceTag-"+c(OrderTicket()),"",0,OrderOpenPrice(),PriceTag_getColorLine(OrderType()),style,1,true,false,false,0);

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PriceTag_getText(int statement,double lot)
  {
   switch(statement)
     {
      case  OP_BUY:
         return "Buy "+c(lot,2);
      case  OP_SELL:
         return "Sell "+c(lot,2);
      case  OP_BUYLIMIT:
         return "Buy limit "+c(lot,2);
      case  OP_SELLLIMIT:
         return "Sell limit "+c(lot,2);
      case  OP_BUYSTOP:
         return "Buy stop "+c(lot,2);
      case  OP_SELLSTOP:
         return "Sell stop "+c(lot,2);
      default:
         break;
     }
   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color PriceTag_getColorLine(int statement)
  {
   switch(statement)
     {
      case  OP_BUY:
         return clrDodgerBlue;
      case  OP_SELL:
         return clrSalmon;
      case  OP_BUYLIMIT:
         return clrSilver;
      case  OP_SELLLIMIT:
         return clrSilver;
      case  OP_BUYSTOP:
         return clrSilver;
      case  OP_SELLSTOP:
         return clrSilver;
      default:
         break;
     }
   return clrWhite;
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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_CLICK || id==CHARTEVENT_CHART_CHANGE)
     {
      PriceTag();
     }
  }
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID 
                 const string            name="Label",             // label name 
                 const int               sub_window=0,             // subwindow index 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const string            text="Label",             // text 
                 const string            font="Arial",             // font 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const double            angle=0.0,                // text slope 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0)                // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create a text label 
   ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0);

//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
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
