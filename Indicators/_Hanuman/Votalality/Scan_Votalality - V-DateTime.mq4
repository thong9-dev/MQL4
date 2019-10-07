//+------------------------------------------------------------------+
//|                                              Scan_Votalality.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string indy_name="ScanVol-H#";
input double DarwScal=30;

#include <Tools/Method_Tools.mqh>
#include <Tools/DrawHistogram.mqh>

int Arr_VolH_UP[24];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
string SMS="";
datetime DateStart=0,DateObservec=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("");
   _ArraySetData(Arr_VolH_UP);
   _DrawHistogram(Arr_VolH_UP,"Vol-H",clrMagenta,__LINE__);

   DateStart=TimeLocal();
   TimeObserve();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(),indy_name,0,OBJ_TREND);

   return(0);
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
   _ArraySetData(Arr_VolH_UP);
   _DrawHistogram(Arr_VolH_UP,"Vol-H",clrMagenta,__LINE__);

//TimeObserve();

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
//if((id==CHARTEVENT_OBJECT_CLICK))
//  {
//   if(sparam==NameBTN)
//     {

//string SMSChartEvent="";
/*SMS+="\nid "+c(id);
   SMS+="\nlparam "+c(lparam);
   SMS+="\ndparam "+c(dparam,0);
   SMS+="\nsparam "+sparam;*/
   if((id==CHARTEVENT_CHART_CHANGE) || (id==CHARTEVENT_CLICK))
     {
      _DrawHistogram(Arr_VolH_UP,"Vol-H",clrMagenta,__LINE__);
      //TimeObserve();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FocusTime=15;
double FocusDay=2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ArraySetData(int &Array[])
  {
//int Bar=iBars(Symbol(),FocusTime)-1;
   int Bar=int(((24*FocusDay*60)/FocusTime)-1);
   for(int i=0;i<Bar;i++)
     {
      double B0=iClose(Symbol(),FocusTime,i);
      double B1=iClose(Symbol(),FocusTime,i+2);

      //Print(NormalizeDouble((((B0/B1)-1)*10000),2));
      //if(B1>0 && (((B0/B1)-1)*10000)>2)
      int X1=int(StringSubstr(TimeToString(iTime(Symbol(),FocusTime,i),TIME_MINUTES),0,2));

      if(B0>B1)
        {
         Arr_VolH_UP[X1]++;
        }
      else if(B0<B1)
        {
         //Arr_VolH_UP[X1]--;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _DrawHistogram(int &Array[],string strHisto,color clr,int line)
  {
   double Chart_PRICE_MAX=ChartGetDouble(ChartID(),CHART_PRICE_MAX,0);
   double Chart_PRICE_MIN=ChartGetDouble(ChartID(),CHART_PRICE_MIN,0);

   double Chart_PRICE_Full=(Chart_PRICE_MAX-Chart_PRICE_MIN)*(DarwScal/100);

   double Draw_Bar=0;
   datetime date=0;

   double Draw_Max=MathPow(10,Digits)*(-1);
   for(int i=0;i<=23;i++)
     {
      if(Draw_Max<Array[i])
         Draw_Max=Array[i];
     }
//---

   datetime NowBar_Date=iTime(Symbol(),PERIOD_H1,0);
   int NowBar=int(StringSubstr(TimeToString(NowBar_Date,TIME_MINUTES),0,2));

   color clrBar=clr;
   int width=1;
   double PerDarw=0;
   double Draw_Max_OnePer=NormalizeDouble(Draw_Max/100,2);
//---

   for(int i=0;i<=23;i++)
     {
      if(Array[i]>0)
        {
         PerDarw=(Array[i]/Draw_Max);
         Draw_Bar=Chart_PRICE_Full*PerDarw;
         //---
         date=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+cFillZero(i,2)+":00:00");
         //---
         if((i<23 && Array[i+1]>0 && Array[i]<Array[i+1]) || 
            (i==23 && Array[0]>0 && Array[i]<Array[0]))
           {
            if(i==NowBar)clrBar=clrLime;else clrBar=clrYellow;
           }
         else
           {
            if(i==NowBar)clrBar=clrWhite;else clrBar=clr;
           }
         DrawTLineH(ChartID(),0,indy_name+strHisto+c(i),date,Chart_PRICE_MIN,Chart_PRICE_MIN+Draw_Bar,clrBar,0,2,false,cFillZero(i,2)+" | "+c(Array[i])+"n "+c(PerDarw*100,2)+"%");
        }
     }
//---
   datetime Test1Day=PERIOD_D1*60;
   if(TimeDayOfWeek(date)==1)
     {
      Test1Day=PERIOD_D1*60*3;
     }

//Comment(NowBar_Date+"\n"+Test1Day+"\n"+TimeToString(NowBar_Date-Test1Day,TIME_DATE));

   clrBar=clrBlue;
   for(int i=0;i<=23;i++)
     {
      if(Array[i]>0)
        {
         PerDarw=(Array[i]/Draw_Max);
         Draw_Bar=Chart_PRICE_Full*PerDarw;
         //---
         date=StringToTime(TimeToString(NowBar_Date-Test1Day,TIME_DATE)+" "+cFillZero(i,2)+":00:00");
         //---
         if((i<23 && Array[i+1]>0 && Array[i]<Array[i+1]) || 
            (i==23 && Array[0]>0 && Array[i]<Array[0]))
           {
            if(i==NowBar)clrBar=clrLime;else clrBar=clrYellow;
           }
         else
           {
            if(i==NowBar)clrBar=clrWhite;else clrBar=clrBlue;
           }
         DrawTLineH(ChartID(),0,"P"+indy_name+strHisto+c(i),date,Chart_PRICE_MIN,Chart_PRICE_MIN+Draw_Bar,clrBar,0,2,false,cFillZero(i,2)+" | "+c(Array[i])+"n "+c(PerDarw*100,2)+"%");
        }
     }
//date+=StringToTime(TimeToString(0,TIME_DATE)+" "+cFillZero(1,2)+":00:00");
//DrawTLineH(ChartID(),0,indy_name+strHisto+"X",date,Chart_PRICE_MIN,Chart_PRICE_MIN+Chart_PRICE_Full,clrYellow,0,1,false,"");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimeObserve()
  {
   SMS="";
   DateObservec=TimeLocal()-DateStart;

   int _TimeDay=TimeDay(DateObservec)-1;
   int _TimeMonth=TimeMonth(DateObservec)-1;
   int _TimeYear=TimeYear(DateObservec)-1970;

   SMS+="\n"+TimeToString(DateObservec,TIME_SECONDS);

   if(_TimeDay>0 || _TimeMonth>0 || _TimeYear>0) SMS+=" | ";
   if(_TimeDay>0)    SMS+=c(_TimeDay)+" Day ";
   if(_TimeMonth>0)  SMS+=c(_TimeMonth)+" Month ";
   if(_TimeYear>0)   SMS+=c(_TimeYear)+" Year ";

//Comment(SMS);
  }
//+------------------------------------------------------------------+