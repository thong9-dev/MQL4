//+------------------------------------------------------------------+
//|                                                        dot_close.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_color1 White 

double dotNo[];

void OnDeinit(const int reason)
{
   
    for(int i= Bars;i>=0;i--)
    {
      if(ObjectFind(0,"pattern"+i) == 0){
            ObjectDelete("pattern"+i);
      }
    }
    
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    IndicatorBuffers(1);  
    SetIndexBuffer(0, dotNo); 
    SetIndexStyle(0,DRAW_ARROW,STYLE_DOT,1);
    SetIndexArrow(0, 159);
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
   
   int limit=rates_total-prev_calculated;
//---
 
//---

   for(int i=0; i<limit; i++)
   {
      dotNo[i] = iClose(NULL,0,i);
   }
      
      
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
