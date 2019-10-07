//+------------------------------------------------------------------+
//|                                                  PriceAction.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                   https://M2P_Design@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://M2P_Design@hotmail.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_minimum 1
#property indicator_maximum 5
#property indicator_buffers 6
#property indicator_color1 clrLime
#property indicator_color2 clrRed
#property indicator_color3 clrLime
#property indicator_color4 clrRed
#property indicator_color5 clrLime
#property indicator_color6 clrRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2

double PinBarU[];
double PinBarD[];
double InBarU[];
double InBarD[];
double EnBarU[];
double EnBarD[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,PinBarU);
   SetIndexBuffer(1,PinBarD);
   SetIndexBuffer(2,InBarU);
   SetIndexBuffer(3,InBarD);
   SetIndexBuffer(4,EnBarU);
   SetIndexBuffer(5,EnBarD);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexLabel(0,"PinBar UP");
   SetIndexLabel(1,"PinBar Down");
   SetIndexLabel(2,"Inside Bar UP");
   SetIndexLabel(3,"Inside Bar Down");
   SetIndexLabel(4,"Engulfing Bar UP");
   SetIndexLabel(5,"Engulfing Bar Down");
   IndicatorShortName("BOLA-PriceAction");

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
//---- main loop
   for(int i=0; i<limit; i++)
     {
      switch(PinBar(i))
        {
         case 2:PinBarU[i]= 1; PinBarD[i]=0;continue;
         case 4:PinBarU[i]= 2; PinBarD[i]=0;continue;
         case 6:PinBarU[i]= 3; PinBarD[i]=0;continue;
         case 8:PinBarU[i]= 4; PinBarD[i]=0;continue;

         case 1:PinBarD[i]= 1; PinBarU[i]= 0;continue;
         case 3:PinBarD[i]= 2; PinBarU[i]= 0;continue;
         case 5:PinBarD[i]= 3; PinBarU[i]= 0;continue;
         case 7:PinBarD[i]= 4; PinBarU[i]= 0;continue;
         default:
           {
            PinBarU[i]=0;
            PinBarD[i]=0;
           }
        }

      switch(InBar(i))
        {
         case 2:InBarU[i]= 1;InBarD[i]= 0;continue;
         case 4:InBarU[i]= 2;InBarD[i]= 0;continue;
         case 6:InBarU[i]= 3;InBarD[i]= 0;continue;
         case 8:InBarU[i]= 4;InBarD[i]= 0;continue;

         case 1:InBarD[i]= 1;InBarU[i]= 0;continue;
         case 3:InBarD[i]= 2;InBarU[i]= 0;continue;
         case 5:InBarD[i]= 3;InBarU[i]= 0;continue;
         case 7:InBarD[i]= 4;InBarU[i]= 0;continue;
         default:
           {
            InBarU[i]=0;
            InBarD[i]=0;
           }
        }

      switch(EnBar(i))
        {
         case 2:EnBarU[i]= 1;EnBarD[i]= 0;continue;
         case 4:EnBarU[i]= 2;EnBarD[i]= 0;continue;
         case 6:EnBarU[i]= 3;EnBarD[i]= 0;continue;
         case 8:EnBarU[i]= 4;EnBarD[i]= 0;continue;

         case 1:EnBarD[i]= 1;EnBarU[i]= 0;continue;
         case 3:EnBarD[i]= 2;EnBarU[i]= 0;continue;
         case 5:EnBarD[i]= 3;EnBarU[i]= 0;continue;
         case 7:EnBarD[i]= 4;EnBarU[i]= 0;continue;
         default:
           {
            EnBarU[i]=0;
            EnBarD[i]=0;
           }
        }
      //---
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| PinBar function                                                  |
//+------------------------------------------------------------------+
int PinBar(int i)
  {
   double Nose,Body,Wick;

   double Open0=iOpen(NULL,0,i);
   double Close0=iClose(NULL,0,i);

   double High0=iHigh(NULL,0,i);
   double High1=iHigh(NULL,0,i+1);
   double High2=iHigh(NULL,0,i+2);
   double High3=iHigh(NULL,0,i+3);
   double High4=iHigh(NULL,0,i+4);

   double Low0=iLow(NULL,0,i);
   double Low1=iLow(NULL,0,i+1);
   double Low2=iLow(NULL,0,i+2);
   double Low3=iLow(NULL,0,i+3);
   double Low4=iLow(NULL,0,i+4);

//-------------
// UpCandle
//-------------
   if((High0-Open0)>(High0-Close0))
     {
      Nose = High0-Close0;
      Body = Close0-Open0;
      Wick = Open0-Low0;

      // HangMan
      if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3 && High0>High4)
         return(8);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3)
         return(6);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2)
         return(4);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1)
         return(2);


      // Hammer
      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3 && Low0<Low4)
         return(8);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3)
         return(6);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2)
         return(4);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1)
         return(2);

      else
         return(-1);
     }

//-------------
// DownCandle
//-------------
   else if((High0-Open0)<(High0-Close0))
     {
      Nose = High0-Open0;
      Body = Open0-Close0;
      Wick = Close0-Low0;

      // HangMan
      if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3 && High0>High4)
         return(7);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3)
         return(5);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2)
         return(3);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1)
         return(1);


      // Hammer
      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3 && Low0<Low4)
         return(7);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3)
         return(5);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2)
         return(3);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1)
         return(1);

      else
         return(-1);
     }
   else
      return(-1);
  }
//+------------------------------------------------------------------+
//| Inside Bar function                                              |
//+------------------------------------------------------------------+
int InBar(int i)
  {
   double Open0=iOpen(NULL,0,i);
   double Close0=iClose(NULL,0,i);

   double High0=iHigh(NULL,0,i);
   double High1=iHigh(NULL,0,i+1);
   double High2=iHigh(NULL,0,i+2);
   double High3=iHigh(NULL,0,i+3);
   double High4=iHigh(NULL,0,i+4);

   double Low0=iLow(NULL,0,i);
   double Low1=iLow(NULL,0,i+1);
   double Low2=iLow(NULL,0,i+2);
   double Low3=iLow(NULL,0,i+3);
   double Low4=iLow(NULL,0,i+4);

//-------------
// UpCandle
//-------------
   if((High0-Open0)>(High0-Close0))
     {
      if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2
         && High0<=High3 && Low0>=Low3
         && High0<=High4 && Low0>=Low4)
         return(8);

      else if(High0<=High1  &&  Low0>=Low1
         &&  High0<=High2 && Low0>=Low2
                    && High0<=High3 && Low0>=Low3)
                    return(6);

      else if(High0<=High1  &&  Low0>=Low1
         &&  High0<=High2 && Low0>=Low2)
         return(4);

      else if(High0<=High1 && Low0>=Low1)
                     return(2);

      else
         return(-1);
     }

//-------------
// DownCandle
//-------------
   else if((High0-Open0)<(High0-Close0))
     {
      if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2
         && High0<=High3 && Low0>=Low3
         && High0<=High4 && Low0>=Low4) return(7);

      else if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2
                   && High0<=High3 && Low0>=Low3) return(5);

      else if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2) return(3);

      else if(High0<=High1 && Low0>=Low1) return(1);

      else return(-1);
     }

   else return(-1);
  }
//+------------------------------------------------------------------+
//| Engulfing Bar function                                           |
//+------------------------------------------------------------------+
int EnBar(int i)
  {
   double Open0=iOpen(NULL,0,i);
   double Close0=iClose(NULL,0,i);

   double High0=iHigh(NULL,0,i);
   double High1=iHigh(NULL,0,i+1);
   double High2=iHigh(NULL,0,i+2);
   double High3=iHigh(NULL,0,i+3);
   double High4=iHigh(NULL,0,i+4);

   double Low0=iLow(NULL,0,i);
   double Low1=iLow(NULL,0,i+1);
   double Low2=iLow(NULL,0,i+2);
   double Low3=iLow(NULL,0,i+3);
   double Low4=iLow(NULL,0,i+4);

//-------------
// UpCandle
//-------------
   if((High0-Open0)>(High0-Close0))
     {
      if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2
         && High0>=High3 && Low0<=Low3
         && High0>=High4 && Low0<=Low4) return(8);

      else if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2
                   && High0>=High3 && Low0<=Low3) return(6);

      else if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2) return(4);

      else if(High0>=High1 && Low0<=Low1) return(2);

      else return(-1);
     }

//-------------
// DownCandle
//-------------
   else if((High0-Open0)<(High0-Close0))
     {
      if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2
         && High0>=High3 && Low0<=Low3
         && High0>=High4 && Low0<=Low4) return(7);

      else if(High0>=High1  &&  Low0<=Low1
         &&  High0>=High2 && Low0<=Low2
                    && High0>=High3 && Low0<=Low3) return(5);

      else if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2) return(3);

      else if(High0>=High1 && Low0<=Low1) return(1);

      else return(-1);
     }

   else return(-1);
  }
//+------------------------------------------------------------------+
