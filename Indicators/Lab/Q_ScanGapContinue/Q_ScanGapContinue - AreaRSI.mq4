//+------------------------------------------------------------------+
//|                                            Q_ScanGapContinue.mq4 |
//|                Copyright 2018, MetaQuotes Software Corp. byDivas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp. byDivas"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window

#include <Tools/Method_Tools.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
#remark
find date of gap
darw Vline there date
Analysis in which direction? #Continue or #back
How long #Continue and #back

and case 4
*/
string EA_NAME="Q_ScanGap";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetMillisecondTimer(1000);
   ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,false);
   ObjectsDeleteAll(0,OBJ_VLINE);
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

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
extern double FocusDay=600;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TextComment="";
//---
int UP_Trust,UP_unTrust;
int DW_Trust,DW_unTrust;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   TextComment="";
   UP_Trust=0;UP_unTrust=0;
   DW_Trust=0;DW_unTrust=0;
//---
   int Found=0;
   int Found_UP=0;
   int Found_DW=0;

   int Bar=int(FocusDay*60*24)/ChartPeriod(0);
   TextComment+="Bar : "+c(Bar)+"\n";

   for(int i=0;i<Bar;i++)
     {
      int Gap=0;
      color clrVline=clrWhite;

      double c0=iClose("",0,i+1);
      double c1=iOpen("",0,i);

      double diff=(c1-c0)*MathPow(10,Digits);
      if(MathAbs(diff)>=100)
        {
         Found++;

         if(diff>0)
           {
            Found_UP++;
            clrVline=clrLime;
           }
         else  if(diff<0)
           {
            Found_DW++;
            clrVline=clrRed;
           }

         Draw_VLine_Bar("Found"+c(Found),i+1,clrVline,2,"Bar: "+c(i+1)+"\nGap: "+c(Found));

        }
     }
   TextComment+="GP : "+c(Found);
   TextComment+="\nUP : "+c(Found_UP);
   TextComment+="\nDW : "+c(Found_DW);

   TextComment+="\n\n #Trust";
   TextComment+="\nUP *** "+c(UP_Trust)+" | "+c(UP_unTrust);
   TextComment+="\nDW *** "+c(DW_Trust)+" | "+c(DW_unTrust);

   getSlopeRSI(164,-1,Found);

//---
   Comment(TextComment);
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
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_VLine_Bar(string name,int Bar,color clr,int style,string tooltip)
  {
//---
   datetime time=iTime("",0,Bar);
   name=EA_NAME+": "+name;

   ObjectDelete(name);
   ObjectCreate(name,OBJ_VLINE,0,time,0);
   ObjectSet(name,OBJPROP_COLOR,clr);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSet(name,OBJPROP_WIDTH,0);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern int RSI_PERIOD=14;
//+------------------------------------------------------------------+
double getSlopeRSI(int placs,int gap,int Found)
  {
   int Look=50;
   double up=0,dw=0;
   for(int i=0;i<Look;i++)
     {
      double _iRSI=iRSI("",0,RSI_PERIOD,PRICE_CLOSE,placs+i);
      double Area=_iRSI-50;
      if(Area>0)
        {
         up+=Area;
        }
      else
        {
         dw+=Area;
        }
     }
//---
   double RateArea=0;
   if(gap==1)
     {
      RateArea=up/dw;
      if(dw==0)
         RateArea=up;
     }
   else
     {
      RateArea=dw/up;
      if(up==0)
         RateArea=dw;
     }
//---
   int PlacsAfter2=placs-Look;
   if(PlacsAfter2<0)
      PlacsAfter2=0;
   double up2=0,dw2=0;
   for(int i=0;i<Look;i++)
     {
      double _iRSI=iRSI("",0,RSI_PERIOD,PRICE_CLOSE,PlacsAfter2+i);
      double Area=_iRSI-50;
      if(Area>0)
        {
         up2+=Area;
        }
      else
        {
         dw2+=Area;
        }
     }
//---
   double RateArea2=0;
   if(gap==1)
     {
      RateArea2=up2/dw2;
      if(dw2==0)
         RateArea2=up2;
     }
   else
     {
      RateArea2=dw2/up2;
      if(up2==0)
         RateArea2=dw2;
     }

//---

   Draw_VLine_Bar("RIS_area0",placs+Look,clrYellow,0,"");
   Draw_VLine_Bar("RIS_area1",placs,clrWhite,2,"");
   Draw_VLine_Bar("RIS_area2",PlacsAfter2,clrYellow,0,"");

   TextComment+="\n\n #Area ["+c(gap)+"]";
   TextComment+="\nUP *** "+c(up/dw,4);
   TextComment+="\nDW *** "+c(dw/up,4);
   TextComment+="\nRate *** "+c(MathAbs(RateArea),4);
   TextComment+="\n";
   TextComment+="\nUP *** "+c(up2/dw2,4);
   TextComment+="\nDW *** "+c(dw2/up2,4);
   TextComment+="\nRate *** "+c(MathAbs(RateArea2),4);


   return 0;
  }
//+------------------------------------------------------------------+
