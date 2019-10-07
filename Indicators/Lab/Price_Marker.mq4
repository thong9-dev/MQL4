//+------------------------------------------------------------------+
//|                                                 Price_Marker.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "https://www.facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2

#property indicator_color1  clrYellow
#property indicator_color2  clrNONE

#property indicator_width1  1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum selectCandle
  {
   candleHigh=0,  //High
   candleOpen=1,  //Open
   candleClose=2,//Close
   candleLow=3   //Low
  };
extern selectCandle ExselectCandle=candleClose; //Candle Price
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double Ext_Temp[];
double Ext_nBar[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Ext_Temp);
   SetIndexBuffer(1,Ext_nBar);
//SetIndexStyle(0,DRAW_ARROW,0,3,clrWhite);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   
   SetIndexArrow(0,158);
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
//---
//candleHigh=0,  //High
//candleOpen=1,  //Open
//candleClose=2,//Close
//candleLow=3   //Low

   for(int i=0;i<ArraySize(Ext_Temp);i++)
     {
      switch(ExselectCandle)
        {
         case  0:    Ext_Temp[i]=high[i];    break;
         case  1:    Ext_Temp[i]=open[i];    break;
         case  2:    Ext_Temp[i]=close[i];   break;
         case  3:    Ext_Temp[i]=low[i];     break;
         default:    break;
        }

      Ext_nBar[i]=i;
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
