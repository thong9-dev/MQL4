//+------------------------------------------------------------------+
//|                                                    Test_Ceta.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "lapukdee @2019"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   VLineCreate(0,"V",0,iTime(Symbol(),0,0),
               clrMagenta,0,1,false,true,true,false,0);
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
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Print("The mouse has been clicked on the object with name '"+sparam+"'");

      double p1=ObjectGet("T",OBJPROP_PRICE1);
      double p2=ObjectGet("T",OBJPROP_PRICE2);
      datetime  d1=ObjectGetTimeByValue(0,"T",p1,0);
      datetime  d2=ObjectGetTimeByValue(0,"T",p2,0);

      p1=NormalizeDouble(p1,Digits);
      p2=NormalizeDouble(p2,Digits);

      int x1,y1,x2,y2;
      ChartTimePriceToXY(0,0,d1,p1,x1,y1);
      ChartTimePriceToXY(0,0,d2,p2,x2,y2);
      double x=x2-x1,y=y1-y2;
      double M=0,ceta=0;
      if(x!=0)
        {
         ceta=NormalizeDouble(MathArctan(y/x)*(180/M_PI),2);
         M=y/x;
        }
      else
        {
         M=0;
         if(y<0) M=-0;

         ceta=90;
         if(y<0) ceta=-90;
        }
      //---
      int B_x,B_y;
      datetime B_d=ObjectGet("V",OBJPROP_TIME1);
      ChartTimePriceToXY(0,0,B_d,0,B_x,B_y);
      //---

      int R_Y1=M*(x1-B_x)+y1;
      //---
      datetime RR_Date;
      double RR_Price;
      int RR_Sub;
      ChartXYToTimePrice(0,B_x,R_Y1,RR_Sub,RR_Date,RR_Price);
      RR_Price=NormalizeDouble(RR_Price,Digits);

      HLineCreate(0,"H","",0,RR_Price,
                  clrRed,2,1,false,true,false,false,0);

      Comment(
              DoubleToStr(p1,Digits)+" : "+d1+" = "+x1+"x | "+y1+"y\n"+
              DoubleToStr(p2,Digits)+" : "+d2+" = "+x2+"x | "+y2+"y\n"+
              "Line : -- X: "+x+" | Y: "+y+"\n"+
              "M: "+M+
              "\nceta: "+ceta+
              "\n-----"+
              "\nB_x: "+B_x+
              "\nR_Y1: "+R_Y1+
              "\n-----"+
              "\nRR_Price: "+DoubleToStr(RR_Price,Digits)+
              "\nRR_Date: "+RR_Date
              );

     }
  }
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="HLine",// line name 
                 const string          str="Text",
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrYellow,// line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            SELECTABLE=true,// move 
                 const bool            selection=true,// highlight to move 
                 const bool            hidden=false,// hidden in the object list 
                 const long            z_order=0) // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      if(str!="")
        {
         ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,str);
         ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
        }
      HLineMove(chart_ID,name,price,clr);
      //Print(__FUNCTION__,": failed to create a horizontal line! Error code = ",GetLastError());
      //return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,SELECTABLE);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   if(str!="")
     {
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,// chart's ID 
               const string name="HLine",// line name 
               double       price=0,
               const color  clr=clrYellow) // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      //Print(__FUNCTION__,": failed to move the horizontal line! Error code = ",GetLastError()); 
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
bool VLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="VLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time=0,            // line time 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            lock=true,// 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the line time is not set, draw it via the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      VLineMove(chart_ID,name,time,clr);
      //Print(__FUNCTION__,": failed to create a vertical line! Error code = ",GetLastError());
      //return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,lock);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the vertical line                                           | 
//+------------------------------------------------------------------+ 
bool VLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="VLine", // line name 
               datetime     time=0,// line time 
               const color  clr=clrRed)// line color
  {
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- if line time is not set, move the line to the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      VLineMove(chart_ID,name,time);
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
