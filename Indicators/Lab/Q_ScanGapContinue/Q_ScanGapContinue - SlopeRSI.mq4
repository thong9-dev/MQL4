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
      double c0=iClose("",0,i+1);
      double c1=iOpen("",0,i);

      double diff=(c1-c0)*MathPow(10,Digits);
      if(MathAbs(diff)>=100)
        {
         Found++;
         if(diff>0)
           {
            Found_UP++;
            getSlopeRSI(i+1,1,Found);
           }
         else  if(diff<0)
           {
            Found_DW++;
            getSlopeRSI(i+1,-1,Found);
           }
        }
     }
   TextComment+="GP : "+c(Found);
   TextComment+="\nUP : "+c(Found_UP);
   TextComment+="\nDW : "+c(Found_DW);

   TextComment+="\n\n #Trust";

   TextComment+="\nUP *** "+c(UP_Trust)+" | "+c(UP_unTrust);
   TextComment+="\nDW *** "+c(DW_Trust)+" | "+c(DW_unTrust);

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
   int Look=30;
//---Calculator Phase1+2
   double After=iRSI("",0,RSI_PERIOD,PRICE_CLOSE,placs);
   double Before=iRSI("",0,RSI_PERIOD,PRICE_CLOSE,placs+Look);
   double Slope=(After-Before)/Look;
//
   int PlacsAfter2=placs-Look;
   if(PlacsAfter2<0)
      PlacsAfter2=0;
   double After2=iRSI("",0,RSI_PERIOD,PRICE_CLOSE,PlacsAfter2);
   double Before2=iRSI("",0,RSI_PERIOD,PRICE_CLOSE,placs);
   double Slope2=(After2-Before2)/Look;

   Slope=Degrees_ofTan(Slope);
   Slope2=Degrees_ofTan(Slope2);

//---Analysis and Output Phase1+2
  
   int Line_Style=0;
   if(NumberPositive(Slope) && NumberPositive(Slope2))
     {
      if(Slope>0)//ConUP
        {
         if(gap>0)
           {
            //OK
            UP_Trust++;
           }
         else
           {
            DW_unTrust++;
            Line_Style=2;
           }
        }
      else//ConDW
        {
         if(gap<0)
           {
            //OK
            DW_Trust++;
           }
         else
           {
            UP_unTrust++;
            Line_Style=2;
           }
        }
     }
   else//Reverse
     {
      if(Slope>0)//ReverseUP
        {
         if(gap<0)
           {
            //OK
            DW_Trust++;
           }
         else
           {
            UP_unTrust++;
            Line_Style=2;
           }
        }
      else//ReverseDW
        {
         if(gap>0)
           {
            //OK
            UP_Trust++;
           }
         else
           {
            DW_unTrust++;
            Line_Style=2;
           }
        }
     }

//---
 color clrVline=clrWhite;
   if(gap>0)
     {
      clrVline=clrLime;
     }
   else
     {
      clrVline=clrRed;
     }
   Draw_VLine_Bar(c(Found),placs,clrVline,Line_Style,"Bar: "+c(placs)+"\nGap: "+c(Found));

//---

//Draw_VLine_Bar("TestSlope0",Placs,clrYellow,c(Placs));
//Draw_VLine_Bar("PA-"+c(placs),placs+Look,clrMagenta,"");
//Draw_VLine_Bar("PB-"+c(placs),PlacsAfter2,clrMagenta,"");

   return Slope;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Degrees_ofTan(double _Slope)
  {
   double _Degrees=0;
   double Degrees=NormalizeDouble((_Slope*90)/M_PI,2);

   if(Degrees<0) _Degrees=360+Degrees;
   else _Degrees=Degrees;

   return Degrees;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NumberPositive(double v)
  {
   if(v>=0)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
