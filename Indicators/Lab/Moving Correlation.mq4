//+------------------------------------------------------------------+
//|                                       Custom Moving Averages.mq4 |
//|                   Copyright 2005-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2015, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Moving Average"
#property strict

#include <Tools/Method_Tools.mqh>

#property indicator_chart_window
#property indicator_buffers 1
//#property indicator_color1 clrNONE
//--- indicator parameters
input string Sym="GBPUSD";//Symbol
input color clrSym=clrMagenta;//SymbolColor
input ENUM_LINE_STYLE clrSTYLE=STYLE_SOLID;
//--- indicator buffer
double ExtLineBuffer[];
int Rates_total=0;
bool FristRun=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- indicator short name
   IndicatorShortName(Sym);
   IndicatorDigits(Digits);
//SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(0,DRAW_LINE,clrSTYLE,1,clrSym);
   SetIndexShift(0,0);
   SetIndexDrawBegin(0,0);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLineBuffer);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
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
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtLineBuffer,false);
   ArraySetAsSeries(close,false);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
      ArrayInitialize(ExtLineBuffer,0);
//--- calculation
   Rates_total=rates_total;
   DrawSymLine();
//Comment(Rates_total+"|"+rates_total);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DrawSymLine()
  {

   for(int i=0; i<Rates_total; i++)
      ExtLineBuffer[i]=iClose(Sym,Period(),Rates_total-i-1);
//Comment(Sym+": "+NormalizeDouble(ExtLineBuffer[Rates_total-1],(int)MarketInfo(Sym,MODE_DIGITS))+"|"+Rates_total);

   double DataMax=MathPow(10,Digits+1)*(-1);
   double DataMin=MathPow(10,Digits+1);
   double Buffer=0;

   for(int i=0; i<Rates_total; i++)
     {
      Buffer=ExtLineBuffer[i];
      if(DataMax<Buffer)
         DataMax=Buffer;
      if(DataMin>Buffer)
         DataMin=Buffer;
     }

   double DataFullp=(DataMax-DataMin)*MathPow(10,(int)MarketInfo(Sym,MODE_DIGITS));

   double ChartPRICE_MAX =ChartGetDouble(ChartID(),CHART_PRICE_MAX,0);
   double ChartPRICE_MIN =ChartGetDouble(ChartID(),CHART_PRICE_MIN,0);
   double ChartPRICE_Fullp=ChartPRICE_MAX-ChartPRICE_MIN;

   ChartPRICE_MAX=ChartPRICE_MAX-(ChartPRICE_Fullp*0.1);
   ChartPRICE_MIN=ChartPRICE_MIN+(ChartPRICE_Fullp*0.1);
   ChartPRICE_Fullp=ChartPRICE_MAX-ChartPRICE_MIN;

   double Data_Xmin=0,Data_Per=0;
   double DataChart_X=0;
   for(int i=0; i<Rates_total; i++)
     {
      Data_Xmin=ExtLineBuffer[i]-DataMin;
      Data_Xmin=Data_Xmin*MathPow(10,(int)MarketInfo(Sym,MODE_DIGITS));
      Data_Per=Data_Xmin/DataFullp;

      DataChart_X=Data_Per*ChartPRICE_Fullp;
      ExtLineBuffer[i]=ChartPRICE_MIN+DataChart_X;
     }

   if(FristRun)
     {
      ObjectCreate(0,Sym,OBJ_TEXT,0,Time[0],ExtLineBuffer[ArraySize(ExtLineBuffer)-1]);
      ObjectSetString(0,Sym,OBJPROP_TEXT,Sym);
      ObjectMove(0,Sym,0,Time[0]+((Period()*60)*10),ExtLineBuffer[ArraySize(ExtLineBuffer)-1]);
      ObjectSetInteger(0,Sym,OBJPROP_COLOR,clrSym);
     }
   FristRun=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if((id==CHARTEVENT_CHART_CHANGE) || (id==CHARTEVENT_CLICK))
     {
      DrawSymLine();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(),Sym,0,OBJ_TEXT);
  }
//+------------------------------------------------------------------+
