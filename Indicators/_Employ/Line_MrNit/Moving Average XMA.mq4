//+------------------------------------------------------------------+
//|                                 Moving Average Mix and Trend.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "https://www.facebook.com/lapukdee"
//#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4

input string            Spector="------------------ MA_1 ----------------------";//----------------------------------------
input int               InpMA_Period_1=5;            // MA_Period
input int               InpMA_Shift_1=0;              // MA_Shift
input ENUM_MA_METHOD    InpMA_Method_1=MODE_LWMA;      // MA_Method
input ENUM_TIMEFRAMES   InpMA_TF_1=PERIOD_CURRENT;    // MA_TF
input color             InpMA_clr_1=clrWhite;
input ENUM_LINE_STYLE   InpMA_Style_1=STYLE_DOT;
input string            Spector2="------------------ MA_2 ----------------------";//----------------------------------------
input int               InpMA_Period_2=10;            // MA_Period
input int               InpMA_Shift_2=0;              // MA_Shift
input ENUM_MA_METHOD    InpMA_Method_2=MODE_SMA;      // MA_Method
input ENUM_TIMEFRAMES   InpMA_TF_2=PERIOD_CURRENT;    // MA_TF
input color             InpMA_clr_2=clrDodgerBlue;
input ENUM_LINE_STYLE   InpMA_Style_2=STYLE_DOT;
input string            Spector3="------------------ XMA ----------------------";//----------------------------------------
input color             InpMA_clr_UP=clrLime;
input color             InpMA_clr_DW=clrRed;
input int               InpMA_Weight=0;
//---
double       Ext_Buffer_MA_1[];
double       Ext_Buffer_MA_2[];
double       Ext_Buffer_MA_Mix[];
double       Ext_Buffer_UP[];
double       Ext_Buffer_DW[];
double       Ext_Buffer_BR[];
//double       Ext_Buffer_TestC[];
//double       Ext_Buffer_TestB[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorDigits(Digits);

   SetIndexBuffer(0,Ext_Buffer_MA_1);
   SetIndexBuffer(1,Ext_Buffer_MA_2);
//SetIndexBuffer(2,Ext_Buffer_MA_Mix);

   SetIndexBuffer(2,Ext_Buffer_UP);
   SetIndexBuffer(3,Ext_Buffer_DW);
//SetIndexBuffer(5,Ext_Buffer_BR);

   SetIndexStyle(0,DRAW_LINE,InpMA_Style_1,0,InpMA_clr_1);
   SetIndexStyle(1,DRAW_LINE,InpMA_Style_2,0,InpMA_clr_2);
//SetIndexStyle(2,DRAW_LINE,0,0,clrWhite);

   SetIndexStyle(2,DRAW_LINE,0,InpMA_Weight,clrLime);
   SetIndexStyle(3,DRAW_LINE,0,InpMA_Weight,clrRed);
//SetIndexStyle(5,DRAW_LINE,0,0,clrWhite);
//---

/*SetIndexBuffer(6,Ext_Buffer_TestC);
   SetIndexStyle(6,DRAW_ARROW,EMPTY,0,clrDimGray);
   SetIndexArrow(6,108);

   SetIndexBuffer(7,Ext_Buffer_TestB);
   SetIndexStyle(7,DRAW_ARROW,EMPTY,0,clrYellow);
   SetIndexArrow(7,108);*/
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int    i;
//--- check for minimum rates count
   if(rates_total<3)
      return(0);
//--- counting from 0 to rates_total
//ArraySetAsSeries(ExtSARBuffer,false);
//--- detect current position for calculations 
   i=prev_calculated-1;
//--- calculations from start?
   double iMA_1=0;
   double iMA_2=0;
   double iMA_X=0;
   double iMA_T=0;
//ArrayInitialize(Ext_Buffer_UP,0);
//ArrayInitialize(Ext_Buffer_DW,0);
//ArrayInitialize(Ext_Buffer_BR,0);
//---
   if(i<1)
     {
      i=0;
      while(i<rates_total-1)
        {
         iMA_1=iMA(Symbol(),InpMA_TF_1,InpMA_Period_1,InpMA_Shift_1,InpMA_Method_1,0,i);
         iMA_2=iMA(Symbol(),InpMA_TF_2,InpMA_Period_2,InpMA_Shift_2,InpMA_Method_2,0,i);

         Ext_Buffer_MA_1[i]=iMA_1;
         Ext_Buffer_MA_2[i]=iMA_2;

         iMA_X=NormalizeDouble((iMA_1+iMA_2)/2,Digits);
         //Ext_Buffer_MA_Mix[i]=iMA_X;
         //---

         //---

         if(iMA_X<close[i])
           {
            Ext_Buffer_UP[i]=iMA_X;
            if(i>1) Ext_Buffer_UP[i-1]=Mix(i-1);
            //            
            //Ext_Buffer_TestC[i]=close[i];
           }
         else if(iMA_X>close[i])
           {
            Ext_Buffer_DW[i]=iMA_X;
            if(i>1) Ext_Buffer_DW[i-1]=Mix(i-1);
            //            
            //Ext_Buffer_TestC[i]=close[i];
           }
         else
           {
            //Ext_Buffer_TestB[i]=close[i];
            if(i>1)
              {
               if(Ext_Buffer_UP[i-1]>0)   Ext_Buffer_DW[i]=iMA_X;
               if(Ext_Buffer_DW[i-1]>0)   Ext_Buffer_UP[i]=iMA_X;
              }
           }
         i++;
        }
      //--- initialize with zero
      //ArrayInitialize(ExtSARBuffer,0.0);
      //--- go check
      //i++;
     }
   else
     {

     }
//--- return value of prev_calculated for next call
   return(rates_total);
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
double Mix(int n)
  {
   double _iMA_1=iMA(Symbol(),InpMA_TF_1,InpMA_Period_1,InpMA_Shift_1,InpMA_Method_1,0,n);
   double _iMA_2=iMA(Symbol(),InpMA_TF_2,InpMA_Period_2,InpMA_Shift_2,InpMA_Method_2,0,n);
   return NormalizeDouble((_iMA_1+_iMA_2)/2,Digits);
  }
//+------------------------------------------------------------------+
