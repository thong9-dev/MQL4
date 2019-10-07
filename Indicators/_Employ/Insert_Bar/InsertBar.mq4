//+------------------------------------------------------------------+
//|                                                    InsertBar.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1  clrRed

//---- buffers
double       ExtData1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//--- drawing settings
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
//---- indicator buffers
   SetIndexBuffer(0,ExtData1);
//--- set short name
   IndicatorShortName("InsertBar()");

   ObjectsDeleteAll(ChartID(),0,OBJ_RECTANGLE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int stop=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(rates_total<3)
      return(0);
//--- detect current position for calculations 
   int i=rates_total-2;

   printf(i);

   while(i>prev_calculated)
     {
     //ExtData1[i-1]=i-1;
     
      color clrRECTANGLE=clrWhite;
      int Inside_n=1;
      double Mother_higth=high[i];
      double Mother_low=low[i];

      //---
      for(int b=1;b<iBar_LookBack(rates_total,i);b++)
        {
         double Inside_higth=high[i-b];
         double Inside_low=low[i-b];

         if(
            Mother_higth>=Inside_higth &&
            Mother_higth>=Inside_low &&
            Mother_low<=Inside_higth &&
            Mother_low<=Inside_low
            )
           {
            Inside_n++;
           }
         else
           {
            if(Mother_higth<Inside_higth && Mother_low<Inside_low)
              {
               clrRECTANGLE=clrBlue;
              }
            if(Mother_low>Inside_low && Mother_higth>Inside_higth)
              {
               clrRECTANGLE=clrRed;
              }
            break;
           }
        }
      //---

      //printf(Inside_n);

      if(Inside_n>=2)
        {
         RectangleCreate(ChartID(),"Test"+string(i),0,
                         time[i-Inside_n],Mother_higth,
                         time[i],Mother_low,
                         clrRECTANGLE,STYLE_SOLID,1,
                         false,false,false,true,false,0);
         stop++;
         //i-=(Inside_n+1);
         i++;
        }
      else
        {
         i--;
        }

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iBar_LookBack(int max,int i)
  {
   if(i<=max)
      return i;
   return max;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID 
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
                     const bool            selectiond=true,// have to move 
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

      RectanglePointChange(chart_ID,name,0,
                           time1,price1);
      RectanglePointChange(chart_ID,name,1,
                           time2,price2);

      //Print(__FUNCTION__,": failed to create a rectangle! Error code = ",GetLastError());
      //return(false);
     }
//--- set rectangle color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle 
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selectiond);
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
bool RectanglePointChange(const long   chart_ID=0,       // chart's ID 
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
      //Print(__FUNCTION__,": failed to move the anchor point! Error code = ",GetLastError());
      //return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
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
/*
void method1()
  {
   if(rates_total<3)
      return(0);
//--- detect current position for calculations 
   int i=prev_calculated;

   while(i<rates_total)
     {
      color clrRECTANGLE=clrWhite;
      int Inside_n=1;
      double Mother_higth=high[i];
      double Mother_low=low[i];

      //---
      for(int b=1;b<iBar_LookBack(rates_total,i);b++)
        {
         double Inside_higth=high[i-b];
         double Inside_low=low[i-b];

         if(
            Mother_higth>=Inside_higth &&
            Mother_higth>=Inside_low &&
            Mother_low<=Inside_higth &&
            Mother_low<=Inside_low
            )
           {
            Inside_n++;
           }
         else
           {
            if(Mother_higth<Inside_higth && Mother_low<Inside_low)
              {
               clrRECTANGLE=clrBlue;
              }
            if(Mother_low>Inside_low && Mother_higth>Inside_higth)
              {
               clrRECTANGLE=clrRed;
              }
            break;
           }
        }
      //---

      //printf(Inside_n);

      if(Inside_n>=2)
        {
         RectangleCreate(ChartID(),"Test"+string(i),0,
                         time[i-Inside_n],Mother_higth,
                         time[i],Mother_low,
                         clrRECTANGLE,STYLE_SOLID,1,
                         false,false,false,true,false,0);
         stop++;

        }
      else
        {

        }
      i++;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
  */
//+------------------------------------------------------------------+
