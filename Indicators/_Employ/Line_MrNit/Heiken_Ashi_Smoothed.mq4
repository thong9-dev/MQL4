//+------------------------------------------------------------------+
//|                                         Heiken Ashi Smoothed.mq4 |
//|                                                                  |
//|                                                      mod by Raff |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrYellow
#property indicator_color2 clrDodgerBlue
#property indicator_color3 clrRed
#property indicator_color4 clrLime
//---- parameters
extern ENUM_MA_METHOD MaMetod=MODE_SMMA;
extern int MaPeriod=6;
extern ENUM_MA_METHOD MaMetod2=MODE_LWMA;
extern int MaPeriod2=2;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1,clrMagenta);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1,clrYellow);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,clrMagenta);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,clrYellow);
   SetIndexBuffer(3,ExtMapBuffer4);
//----
   SetIndexDrawBegin(0,5);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);

   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);

   SetIndexLabel(0,"Low : ");
   SetIndexLabel(1,"High : ");
   SetIndexLabel(2,"Open : ");
   SetIndexLabel(3,"Close : ");

//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double maOpen=0,maClose=0,maLow=0,maHigh=0;
   double haOpen=0,haHigh=0,haLow=0,haClose=0;
   if(Bars<=10) return(0);

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+MathMax(1,MathMax(MaPeriod,MaPeriod2));

   int pos=limit;
   while(pos>=0)
     {
      maOpen=iMA(NULL,0,MaPeriod,0,MaMetod,int(MODE_OPEN),pos);
      maClose=iMA(NULL,0,MaPeriod,0,MaMetod,int(MODE_CLOSE),pos);
      maLow=iMA(NULL,0,MaPeriod,0,MaMetod,int(MODE_LOW),pos);
      maHigh=iMA(NULL,0,MaPeriod,0,MaMetod,int(MODE_HIGH),pos);
      //----
      haOpen=(ExtMapBuffer5[pos+1]+ExtMapBuffer6[pos+1])/2;
      haClose=(maOpen+maHigh+maLow+maClose)/4;
      haHigh=MathMax(maHigh,MathMax(haOpen,haClose));
      haLow=MathMin(maLow,MathMin(haOpen,haClose));
      if(haOpen<haClose)
        {
         ExtMapBuffer7[pos]=haLow;
         ExtMapBuffer8[pos]=haHigh;
        }
      else
        {
         ExtMapBuffer7[pos]=haHigh;
         ExtMapBuffer8[pos]=haLow;
        }
      ExtMapBuffer5[pos]=haOpen;
      ExtMapBuffer6[pos]=haClose;
      pos--;
     }
   int i;
//for(i=0; i<limit; i++) ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer7,0,MaPeriod2,0,MaMetod2,i);//haLow
//for(i=0; i<limit; i++) ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer8,0,MaPeriod2,0,MaMetod2,i);//haHigh
//for(i=0; i<limit; i++) ExtMapBuffer3[i]=iMAOnArray(ExtMapBuffer5,0,MaPeriod2,0,MaMetod2,i);//haOpen;
//for(i=0; i<limit; i++) ExtMapBuffer4[i]=iMAOnArray(ExtMapBuffer6,0,MaPeriod2,0,MaMetod2,i);//haClose

   for(i=0; i<limit; i++) ExtMapBuffer1[i]=ExtMapBuffer7[i];
   for(i=0; i<limit; i++) ExtMapBuffer2[i]=ExtMapBuffer8[i];
   for(i=0; i<limit; i++) ExtMapBuffer3[i]=ExtMapBuffer5[i];
   for(i=0; i<limit; i++) ExtMapBuffer4[i]=ExtMapBuffer6[i];

//----
   return(0);
  }
//+------------------------------------------------------------------+
