//+------------------------------------------------------------------+
//|                                                    Alligator.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Bill Williams' Aligator"
#property strict

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 3

#property indicator_color1  clrYellow
#property indicator_color2  clrRed
#property indicator_color3  clrMagenta

#property indicator_color4  clrRed
#property indicator_color5  clrMagenta

#property indicator_color6  clrRed
#property indicator_color7  clrMagenta

//---- input parameters
input int _xPeriod=0; // Period
extern int PP=1;//CNT_AVG

//---- indicator buffers
double iLow_Buffer[];
double iHigh_Buffer[];
double iPivot_Buffer[];

double iHigh_1[];
double iHigh_2[];
double iHigh_3[];

double iLow_1[];
double iLow_2[];
double iLow_3[];
//---
double _iPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
   IndicatorDigits(Digits);
   if(_xPeriod<1)
     {
      _iPeriod=1;

      SetIndexBuffer(0,iPivot_Buffer);

      SetIndexBuffer(1,iHigh_1);
      SetIndexBuffer(2,iHigh_2);
      SetIndexBuffer(3,iHigh_3);

      SetIndexBuffer(4,iLow_1);
      SetIndexBuffer(5,iLow_2);
      SetIndexBuffer(6,iLow_3);
     }

//---- drawing settings
   SetIndexStyle(0,DRAW_LINE,0,4,clrYellow);

   SetIndexStyle(1,DRAW_LINE,0,1,clrRoyalBlue);
   SetIndexStyle(2,DRAW_LINE,0,1,clrTomato);
   SetIndexStyle(3,DRAW_LINE,0,1,clrWhite);

   SetIndexStyle(4,DRAW_LINE,0,1,clrRoyalBlue);
   SetIndexStyle(5,DRAW_LINE,0,1,clrTomato);
   SetIndexStyle(6,DRAW_LINE,0,1,clrWhite);

//SetIndexStyle(3,DRAW_LINE);
//SetIndexStyle(4,DRAW_LINE);
//SetIndexStyle(5,DRAW_LINE);
//---- index labels
//SetIndexLabel(0,"iHigh");
//SetIndexLabel(1,"iLow");
//SetIndexLabel(2,"iClose");
  }
//+------------------------------------------------------------------+
//| Bill Williams' Alligator|
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
   int limit=rates_total-prev_calculated;
//---- main loop
//   HLineCreate_(0,"LINE_H0",0,iHigh(Symbol(),PERIOD_D1,0),clrLime,0,1,false,true,false,0);
//   HLineCreate_(0,"LINE_L0",0,iLow(Symbol(),PERIOD_D1,0),clrRed,0,1,false,true,false,0);
//
//   HLineCreate_(0,"LINE_H1",0,iHigh(Symbol(),PERIOD_D1,1),clrSpringGreen,0,1,false,true,false,0);
//   HLineCreate_(0,"LINE_L1",0,iLow(Symbol(),PERIOD_D1,1),clrGold,0,1,false,true,false,0);
//---
   int CNT_Day=7;
   int n=Hour()/4;

   double H,L,R;

   int Next=0;
   int prevc_calculated=iBars(Symbol(),PERIOD_D1)-1;
   double _Range=0;

   double Fibo_TB[]={0.4,0.9,1.5};

   if(_iPeriod==1)
     {
      //Print("limit "+limit+" | rates_total "+rates_total+" | prev_calculated "+prev_calculated);
      for(int i=0;i<=n;i++)
        {
         //iHigh_Buffer[i]=iHigh(Symbol(),PERIOD_D1,1);
         //iLow_Buffer[i]=iLow(Symbol(),PERIOD_D1,1);
         //
         //iPivot_Buffer[i]=(iHigh_Buffer[i]+iLow_Buffer[i]+iClose(Symbol(),PERIOD_D1,1))/3;
         //---
         H=iHigh(Symbol(),PERIOD_D1,1);
         L=iLow(Symbol(),PERIOD_D1,1);
         iPivot_Buffer[i]=(H+L+iClose(Symbol(),PERIOD_D1,1))/3;

         R=H-L;
         iHigh_1[i]=iPivot_Buffer[i]+R*Fibo_TB[0];
         iLow_1[i]=iPivot_Buffer[i]-R*Fibo_TB[0];

         iHigh_2[i]=iPivot_Buffer[i]+R*Fibo_TB[1];
         iLow_2[i]=iPivot_Buffer[i]-R*Fibo_TB[1];

         iHigh_3[i]=iPivot_Buffer[i]+R*Fibo_TB[2];
         iLow_3[i]=iPivot_Buffer[i]-R*Fibo_TB[2];

         //---
         Next++;
        }
      for(int day=2;day<iBars(Symbol(),PERIOD_D1);day++)
        {
         for(int j=Next,i=0;i<6;i++,j++)
           {
            //iHigh_Buffer[j]=iHigh(Symbol(),PERIOD_D1,day);
            //iLow_Buffer[j]=iLow(Symbol(),PERIOD_D1,day);
            //
            //iPivot_Buffer[j]=(iHigh_Buffer[j]+iLow_Buffer[j]+iClose(Symbol(),PERIOD_D1,day))/3;
            //---
            //
            H=iHigh(Symbol(),PERIOD_D1,day);
            L=iLow(Symbol(),PERIOD_D1,day);
            iPivot_Buffer[j]=(H+L+iClose(Symbol(),PERIOD_D1,day))/3;

            R=H-L;
            iHigh_1[j]=iPivot_Buffer[j]+R*Fibo_TB[0];
            iLow_1[j]=iPivot_Buffer[j]-R*Fibo_TB[0];

            iHigh_2[j]=iPivot_Buffer[j]+R*Fibo_TB[1];
            iLow_2[j]=iPivot_Buffer[j]-R*Fibo_TB[1];

            iHigh_3[j]=iPivot_Buffer[j]+R*Fibo_TB[2];
            iLow_3[j]=iPivot_Buffer[j]-R*Fibo_TB[2];

            //---
            Next++;
           }
        }

      for(int i=0; i<prev_calculated; i++)
        {
         //+------------------------------------------------------------------+
         //         RedwBuffer[i]=_getH(i,PP);//Red
         //         MagentaBuffer[i]=_getL(i,PP);//Yellow
         //
         //                                      //_Range=(_getH(i,PP)-_getL(i,PP));
         //
         //         YellowBuffer[i]=(_getH(i,PP)+_getL(i,PP)+_getC(i,PP))/3;
         //+------------------------------------------------------------------+
        }
      //for(int i=prev_calculated; i>=0; i--)
      //  {
      //   _Range=iHigh(Symbol(),PERIOD_D1,i)-iLow(Symbol(),PERIOD_D1,i);
      //   _Range=_getH(i,PP)-_getL(i,PP);
      //  }
     }
   else
     {

     }
//HLineCreate_(0,"LINE_PIVOT",0,iPivot_Buffer[0],clrYellow,0,1,false,true,false,0);
//Comment(string(NormalizeDouble(_Range*MathPow(10,Digits),0)));

//---- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
double _getH(int x,int v)
  {
//printf(__FUNCTION__+" X: "+x+" V: "+v);
   double z=0;

   if(v<1)
     {
      return iHigh(Symbol(),PERIOD_D1,x);
     }
   else
     {
      for(int i=1;i<=v;i++)
        {
         z+=iHigh(Symbol(),PERIOD_D1,x+i);
        }
      return NormalizeDouble(z/v,Digits);
     }

  }
//+------------------------------------------------------------------+
double _getL(int x,int v)
  {
   double z=0;

   if(v<1)
     {
      return iLow(Symbol(),PERIOD_D1,x);
     }
   else
     {
      for(int i=1;i<=v;i++)
        {
         z+=iLow(Symbol(),PERIOD_D1,x+i);
        }
      return NormalizeDouble(z/v,Digits);
     }

  }
//+------------------------------------------------------------------+
double _getC(int x,int v)
  {
   double z=0;
   if(v<1)
     {
      return iClose(Symbol(),PERIOD_D1,x);
     }
   else
     {
      for(int i=1;i<=v;i++)
        {
         z+=iClose(Symbol(),PERIOD_D1,x+i);
        }
      return NormalizeDouble(z/v,Digits);
     }
  }
//+------------------------------------------------------------------+
string          InpName="HLine";     // Line name 
int             InpPrice=25;         // Line price, % 
color           InpColor=C'40,40,40';     // Line color 
ENUM_LINE_STYLE InpStyle=STYLE_DASH; // Line style 
int             InpWidth=1;          // Line width 
bool            InpBack=false;       // Background line 
bool            InpSelection=true;   // Highlight to move 
bool            InpHidden=true;      // Hidden in the object list 
long            InpZOrder=0;         // Priority for mouse click 
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
void HLineCreate_(const long            chart_ID=0,// chart's ID 
                  const string          name="HLine",      // line name 
                  const int             sub_window=0,      // subwindow index 
                  double                price=0,           // line price 
                  const color           clr=clrYellow,// line color 
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                  const int             width=1,           // line width 
                  const bool            back=false,        // in the background 
                  const bool            selection=true,    // highlight to move 
                  const bool            hidden=false,// hidden in the object list 
                  const long            z_order=0) // priority for mouse click 
  {

   bool z=HLineCreate(chart_ID,name,sub_window,price,clr,style,width,back,selection,hidden,z_order);
   if(!z)
     {
      HLineMove(chart_ID,name,price,clr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrYellow,// line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
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
      //Print(__FUNCTION__,": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 

   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID = 0,// chart's ID 
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
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,// chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
