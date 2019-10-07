//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Dartboard.mq4"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _HLineCreate(const long            chart_ID=0,// chart's ID 
                  const string          name="HLine",      // line name 
                  const int             sub_window=0,      // subwindow index 
                  double                price=0,           // line price 
                  const color           clr=clrRed,        // line color 
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                  const int             width=1,           // line width 
                  const bool            back=false,        // in the background 
                  const bool            selection=true,    // highlight to move 
                  const bool            selection2=true,// highlight to move 
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
      //Print(__FUNCTION__,": failed to create a horizontal line! Error code = ",GetLastError());
      _HLineMove(chart_ID,name,price);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection2);
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
bool _HLineMove(const long   chart_ID=0,// chart's ID 
                const string name="HLine", // line name 
                double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectCreText(int windex,string name,int PostX,int PostY,bool hide)
  {
//name=ExtName_OBJ+name;
   if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
     {
      ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
      ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,hide);
      ObjectSetInteger(ChartID(),name,OBJPROP_BACK,false);
     }
   ObjectSet(name,OBJPROP_XDISTANCE,PostX);
   ObjectSet(name,OBJPROP_YDISTANCE,PostY);

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
void setBUTTON_(string name,
                int panel,
                int XSIZE,int YSIZE,
                int XDIS,int YDIS,
                bool ChangeDIS,
                int FONTSIZE,color COLOR,color BG,
                bool HIDDEN,
                string TextStr
                )
  {
//---
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(0,name,OBJ_BUTTON,panel,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDIS);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDIS);
     }
   if(ChangeDIS)
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDIS);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDIS);
     }
//---
   ObjectSetInteger(0,name,OBJPROP_XSIZE,XSIZE);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,YSIZE);

   ObjectSetString(0,name,OBJPROP_TEXT,TextStr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,BG);

   ObjectSetInteger(0,name,OBJPROP_COLOR,COLOR);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,HIDDEN);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrLineOrder(int v)
  {
   color r=clrDarkGray;
   if(v==OP_BUY)
      r=clrRoyalBlue;
   if(v==OP_SELL)
      r=clrRed;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrLineOrder_Profit(double v)
  {
   color r=clrRed;
   if(v>=0)
      r=clrRoyalBlue;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _FiboLevelsCreate(const long            chart_ID=0,// chart's ID 
                       const string          name="FiboLevels", // object name 
                       const int             sub_window=0,      // subwindow index  
                       datetime              time1=0,           // first point time 
                       double                price1=0,          // first point price 
                       datetime              time2=0,           // second point time 
                       double                price2=0,          // second point price 
                       const color           clr=clrRed,        // object color 
                       const ENUM_LINE_STYLE style=STYLE_SOLID, // object line style 
                       const int             width=1,           // object line width 
                       const bool            back=false,        // in the background 
                       const bool            selection=true,    // highlight to move
                       const bool            selection2=true,// highlight to move  
                       const bool            ray_right=false,   // object's continuation to the right 
                       const bool            hidden=true,       // hidden in the object list 
                       const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   _ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- Create Fibonacci Retracement by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time1,price1,time2,price2))
     {
      _FiboLevelsPointChange(0,name,0,time1,price1);
      _FiboLevelsPointChange(0,name,1,time2,price2);
     }
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection2);
//--- enable (true) or disable (false) the mode of continuation of the object's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
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
bool _FiboLevelsSet(long         chart_ID,
                    int          Cm,string       name,
                    double       &values[],
                    color        colors,
                    int          OP_DIR,
                    double       lots,
                    double       T1,double       T2
                    )
  {
   ENUM_LINE_STYLE styles=STYLE_DASHDOT;
   int             widths=0;
   int levels=ArraySize(values);

   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,levels);

//string OP="";
//OP="TP";
//if(CMD_LINE_SL_FIBO==Cm) OP="SL";

   double d=NormalizeDouble((T2-T1),Digits);
   d=d*MathPow(10,Digits);
   if(OP_DIR==OP_SELL || OP_DIR==OP_SELLLIMIT || OP_DIR==OP_SELLLIMIT)     d*=(-1);
   
   double var=_PointValue(T1,lots,17);
   double sum=NormalizeDouble(var*d,2);

   string _ACCOUNT_CURRENCY=AccountInfoString(ACCOUNT_CURRENCY);

   for(int i=0;i<levels;i++)
     {
      //--- level value c(_PointValue(T1,lots,17),10)
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,i,values[i]);
      string Text=Comma(sum*values[i],2," ");     if(i==0) Text="";

      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,Text);
      //ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,OP+d*values[i]);

      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,i,colors);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,i,styles);
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,i,widths);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ChangeFiboLevelsEmptyPoints(datetime &time1,double &price1,
                                  datetime &time2,double &price2)
  {
//--- if the second point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value 
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
//--- if the first point's price is not set, move it 200 points below the second one 
   if(!price1)
      price1=price2-200*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _FiboLevelsPointChange(const long   chart_ID=0,// chart's ID 
                            const string name="FiboLevels", // object name 
                            const int    point_index=0,     // anchor point index 
                            datetime     time=0,            // anchor point time coordinate 
                            double       price=0)           // anchor point price coordinate 
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
bool _EditCreate(const string           name="Edit",// object name 
                 const int              sub_window=0,             // subwindow index 
                 const string           text="Text",              // text 
                 const bool             reDraw=false,// ability to edit 
                 const bool             read_only=false,          // ability to edit 
                 const int              x=0,                      // X coordinate 
                 const int              y=0,                      // Y coordinate 
                 const int              width=50,                 // width 
                 const int              height=18,                // height 
                 const string           font="Arial",             // font 
                 const int              font_size=10,             // font size 
                 const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type 
                 const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const color            clr=clrBlack,             // text color 
                 const color            back_clr=clrWhite,        // background color 
                 const color            border_clr=clrNONE,       // border color 
                 const bool             back=false,               // in the background 
                 const bool             selection=false,          // highlight to move 
                 const bool             hidden=true,              // hidden in the object list 
                 const long             z_order=0)                // priority for mouse click 
  {
   long  chart_ID=0;
//--- reset the error value 
   ResetLastError();
//--- create edit field 
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      //return(false);
     }
   if(reDraw)
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
//--- set object coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text 

//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode 
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
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
//|                                                                  |
//+------------------------------------------------------------------+
bool _EditMove(const long   chart_ID=0,// chart's ID 
               const string name="Edit", // object name 
               const int    x=0,         // X coordinate 
               const int    y=0)         // Y coordinate 
  {
//--- reset the error value 
   ResetLastError();
//--- move the object 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the object! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
