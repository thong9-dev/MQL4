//+------------------------------------------------------------------+
//|                                                    Parabolic.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Parabolic Stop-And-Reversal system"
#property strict

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color3    clrNONE
#property indicator_color1    clrDodgerBlue
#property indicator_color2    clrRed
//--- input parameters
double InpSARStep=0.02;    // Step
double InpSARMaximum=0.2;  // Maximum
input int InpCCIPeriod=100;      // CCI Period
input double set=0;              // CCI ValueCross

//---- buffers
double       ExtSARBuffer[];

double ExtArrowUP_Buffer[];
double ExtArrowDW_Buffer[];

//--- global variables
double       ExtSarStep;
double       ExtSarMaximum;
int          ExtLastReverse;
bool         ExtDirectionLong;
double       ExtLastStep,ExtLastEP,ExtLastSAR;
double       ExtLastHigh,ExtLastLow;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   IndicatorBuffers(2);
//--- checking input data
   if(InpSARStep<0.0)
     {
      ExtSarStep=0.02;
      Print("Input parametr InpSARStep has incorrect value. Indicator will use value ",
            ExtSarStep," for calculations.");
     }
   else
      ExtSarStep=InpSARStep;
   if(InpSARMaximum<0.0)
     {
      ExtSarMaximum=0.2;
      Print("Input parametr InpSARMaximum has incorrect value. Indicator will use value ",
            ExtSarMaximum," for calculations.");
     }
   else
      ExtSarMaximum=InpSARMaximum;
//--- drawing settings
   IndicatorDigits(Digits);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
//---- indicator buffers
   SetIndexBuffer(2,ExtSARBuffer);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,ExtArrowUP_Buffer);

   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,ExtArrowDW_Buffer);

//--- set short name
   IndicatorShortName("CCI Arrow("+IntegerToString(InpCCIPeriod)+","+DoubleToString(set,2)+"*)");
//--- set global variables
   ExtLastReverse=0;
   ExtDirectionLong=false;
   ExtLastStep=ExtLastEP=ExtLastSAR=0.0;
   ExtLastHigh=ExtLastLow=0.0;
//----
  }
//+------------------------------------------------------------------+
//| Parabolic SAR                                                    |
//+------------------------------------------------------------------+
int Bar=-1;
string Barcode="";
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
   bool   dir_long;
   double last_high,last_low,ep,sar,step;
   int    i;
//--- check for minimum rates count
   if(rates_total<3)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtSARBuffer,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
//--- detect current position for calculations 
   i=prev_calculated-1;
//--- calculations from start?
   if(i<1)
     {
      ExtLastReverse=0;
      dir_long=true;
      step=ExtSarStep;
      last_high=-10000000.0;
      last_low=10000000.0;
      sar=0;
      i=1;
      while(i<rates_total-1)
        {
         ExtLastReverse=i;
         if(last_low>low[i])
            last_low=low[i];
         if(last_high<high[i])
            last_high=high[i];
         if(high[i]>high[i-1] && low[i]>low[i-1])
            break;
         if(high[i]<high[i-1] && low[i]<low[i-1])
           {
            dir_long=false;
            break;
           }
         i++;
        }
      //--- initialize with zero
      ArrayInitialize(ExtSARBuffer,0.0);
      //--- go check
      if(dir_long)
        {
         ExtSARBuffer[i]=low[i-1];
         ep=high[i];
        }
      else
        {
         ExtSARBuffer[i]=high[i-1];
         ep=low[i];
        }
      i++;
     }
   else
     {
      //--- calculations to be continued. restore last values
      i=ExtLastReverse;
      step=ExtLastStep;
      dir_long=ExtDirectionLong;
      last_high=ExtLastHigh;
      last_low=ExtLastLow;
      ep=ExtLastEP;
      sar=ExtLastSAR;
     }
//---main cycle
   while(i<rates_total)
     {
      //--- check for reverse
      if(dir_long && low[i]<ExtSARBuffer[i-1])
        {
         SaveLastReverse(i,true,step,low[i],last_high,ep,sar);
         step=ExtSarStep;
         dir_long=false;
         ep=low[i];
         last_low=low[i];
         ExtSARBuffer[i++]=last_high;
         continue;
        }
      if(!dir_long && high[i]>ExtSARBuffer[i-1])
        {
         SaveLastReverse(i,false,step,last_low,high[i],ep,sar);
         step=ExtSarStep;
         dir_long=true;
         ep=high[i];
         last_high=high[i];
         ExtSARBuffer[i++]=last_low;
         continue;
        }
      //---
      sar=ExtSARBuffer[i-1]+step*(ep-ExtSARBuffer[i-1]);
      //--- LONG?
      if(dir_long)
        {
         if(ep<high[i])
           {
            if((step+ExtSarStep)<=ExtSarMaximum)
               step+=ExtSarStep;
           }
         if(high[i]<high[i-1] && i==2)
            sar=ExtSARBuffer[i-1];
         if(sar>low[i-1])
            sar=low[i-1];
         if(sar>low[i-2])
            sar=low[i-2];
         if(sar>low[i])
           {
            SaveLastReverse(i,true,step,low[i],last_high,ep,sar);
            step=ExtSarStep; dir_long=false; ep=low[i];
            last_low=low[i];
            ExtSARBuffer[i++]=last_high;
            continue;
           }
         if(ep<high[i])
            ep=last_high=high[i];
        }
      else // SHORT
        {
         if(ep>low[i])
           {
            if((step+ExtSarStep)<=ExtSarMaximum)
               step+=ExtSarStep;
           }
         if(low[i]<low[i-1] && i==2)
            sar=ExtSARBuffer[i-1];
         if(sar<high[i-1])
            sar=high[i-1];
         if(sar<high[i-2])
            sar=high[i-2];
         if(sar<high[i])
           {
            SaveLastReverse(i,false,step,last_low,high[i],ep,sar);
            step=ExtSarStep;
            dir_long=true;
            ep=high[i];
            last_high=high[i];
            ExtSARBuffer[i++]=last_low;
            continue;
           }
         if(ep>low[i])
            ep=last_low=low[i];
        }
      //---
      ExtSARBuffer[i++]=sar;

     }

     {
      if(Bar!=rates_total)
        {
         Bar=rates_total;
         //---
         Barcode="";
         string barcode="";

         for(int x=0,b=1;x<3;x++,b++)
           {
            double var=iCCI(Symbol(),0,InpCCIPeriod,PRICE_TYPICAL,b);
            if(var>set)
              {
               barcode+="U";
              }
            if(var==set)
              {
               barcode+="X";
              }
            if(var<set)
              {
               barcode+="D";
              }
           }

         for(int x=StringLen(barcode)-1;i>=0;i--)
            Barcode+=StringSubstr(barcode,i,1);

         if(Barcode=="DDU" || Barcode=="DXU")
           {
            ExtArrowUP_Buffer[1]=difV(OP_BUY,high[rates_total-2],low[rates_total-2],ExtSARBuffer[rates_total-2]);
           }
         if(Barcode=="UUD" || Barcode=="UXD")
           {
            ExtArrowDW_Buffer[1]=difV(OP_SELL,high[rates_total-2],low[rates_total-2],ExtSARBuffer[rates_total-2]);
           }
         //printf(rates_total+" | "+DoubleToStr(ExtCCIBuffer[1],4));

        }
      //Comment(DoubleToStr(ExtSARBuffer[rates_total-2],Digits)+" "+DoubleToStr(sar,Digits)+"\n"+high[rates_total-2]);
     }
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  save last values to continue further calculations               |
//+------------------------------------------------------------------+
void SaveLastReverse(int reverse,bool dir,double step,double last_low,double last_high,double ep,double sar)
  {
   ExtLastReverse=reverse;
   if(ExtLastReverse<2)
      ExtLastReverse=2;
   ExtDirectionLong=dir;
   ExtLastStep=step;
   ExtLastLow=last_low;
   ExtLastHigh=last_high;
   ExtLastEP=ep;
   ExtLastSAR=sar;
  }
//+------------------------------------------------------------------+
double difV(int OP_DIR,double h,double l,double sar)
  {
   double r=-1;

   if(h<sar)
     {
      r=sar-h;
     }
   if(h>sar)
     {
      r=l-sar;
     }

   if(OP_DIR==OP_BUY)
     {
      r=l-r;
     }
   if(OP_DIR==OP_SELL)
     {
      r=h+r;
     }
   return NormalizeDouble(r,Digits);
  }
//+------------------------------------------------------------------+
