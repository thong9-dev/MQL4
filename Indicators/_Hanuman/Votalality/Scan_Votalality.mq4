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

string indy_name="SVol#";
input double DarwScal=25;
input int Pip=3;
#include <Tools/Method_Tools.mqh>
#include <Tools/DrawHistogram.mqh>

int Arr_Price_Past1[1];
int Arr_Price_Now[1];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
string SMS="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _High_Max=MathPow(10,Digits)*(-1);//_Low_Min=MathPow(10,Digits);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime DateStart=0,DateObservec=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   _ArrayInitialize(Arr_Price_Past1);
   _ArrayInitialize(Arr_Price_Now);

   _ArraySetData(Arr_Price_Past1,PERIOD_M1);
//_ArraySetData(Arr_Price_Now,PERIOD_M1);

   _DrawHistogram(Arr_Price_Past1,DarwScal,"Past",clrDimGray);
   _DrawHistogram(Arr_Price_Now,DarwScal/2,"Now",clrYellow);

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
//---
   int X1=int(Bid*MathPow(10,Digits-Pip));
   Arr_Price_Now[X1]++;

   _DrawHistogram(Arr_Price_Past1,DarwScal,"Past",clrDimGray);
   _DrawHistogram(Arr_Price_Now,DarwScal/2,"Now",clrYellow);

   TimeObserve();
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
      _DrawHistogram(Arr_Price_Past1,DarwScal,"Past",clrDimGray);
      _DrawHistogram(Arr_Price_Now,DarwScal/2,"Now",clrYellow);

      TimeObserve();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ArrayInitialize(int &Array[])
  {
   _High_Max=MathPow(10,Digits)*(-1);//,_Low_Min=MathPow(10,Digits);

   for(int i=0;i<iBars(Symbol(),PERIOD_MN1);i++)
     {
      double _High=iHigh(Symbol(),PERIOD_MN1,i);
      double _Low=iLow(Symbol(),PERIOD_MN1,i);
      if(_High_Max<_High)
        {
         _High_Max=_High;
        }
     }
   HLineCreate_(0,"_High_Max","",0,_High_Max,clrYellowGreen,0,1,0,false,false,0);

   int CountArr=int(_High_Max*MathPow(10,Digits-Pip));

   ArrayResize(Array,CountArr,CountArr);
   ArrayInitialize(Array,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ArraySetData(int &Array[],ENUM_TIMEFRAMES TF)
  {
   for(int i=0;i<iBars(Symbol(),TF);i++)
     {
      double X0=iClose(Symbol(),TF,i);
      int X1=int(X0*MathPow(10,Digits-Pip));
      Array[X1]++;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Vol_Temp()
  {

   string strTest="";

//int Arr_Price[1];
   _High_Max=MathPow(10,Digits)*(-1);
//_Low_Min=MathPow(10,Digits);

   for(int i=0;i<iBars(Symbol(),PERIOD_MN1);i++)
     {
      double _High=iHigh(Symbol(),PERIOD_MN1,i);
      double _Low=iLow(Symbol(),PERIOD_MN1,i);
      if(_High_Max<_High)
        {
         _High_Max=_High;
        }
/*if(_Low_Min>_Low)
        {
         _Low_Min=_Low;
        }*/
     }
   HLineCreate_(0,"_High_Max","",0,_High_Max,clrYellowGreen,0,1,0,false,false,0);
//HLineCreate_(0,"_Low_Min","",0,_Low_Min,clrYellowGreen,0,1,0,false,false,0);

   int CountArr=int((_High_Max/*-_Low_Min*/)*MathPow(10,Digits-1));
   strTest+="\n ArraySize: "+c(ArraySize(Arr_Price_Past1));

   ArrayResize(Arr_Price_Past1,CountArr,CountArr);

//ArrayFill(Arr_Price,0,CountArr,1); 
   ArrayInitialize(Arr_Price_Past1,0);

   strTest+="\n CountArr: "+c(CountArr);
   strTest+="\n ArraySize: "+c(ArraySize(Arr_Price_Past1));

   strTest+="\n";

   int X1=int(Bid*MathPow(10,Digits-1));
   strTest+="\n X1: "+c(X1);

   for(int i=0;i<iBars(Symbol(),PERIOD_M1);i++)
     {
      double X0=iClose(Symbol(),PERIOD_M1,i);
      X1=int(X0*MathPow(10,Digits-1));
      Arr_Price_Past1[X1]++;
     }

//--- indicator buffers mapping
   double Full_D=75;

   int FIRST_B=int(ChartGetInteger(ChartID(),CHART_FIRST_VISIBLE_BAR,0));
   int VISIBLE_B=int(ChartGetInteger(ChartID(),CHART_VISIBLE_BARS,0));
   int WIDTH_B=int(ChartGetInteger(ChartID(),CHART_WIDTH_IN_BARS,0));

   string strHisto="Histo#";

   ObjectsDeleteAll(ChartID(),strHisto,0,OBJ_TREND);

   int PRICE_MAX =int(ChartGetDouble(ChartID(),CHART_PRICE_MAX,0)*MathPow(10,Digits-1));
   int PRICE_MIN =int(ChartGetDouble(ChartID(),CHART_PRICE_MIN,0)*MathPow(10,Digits-1));

   int PRICE_MAX2=int(_High_Max*MathPow(10,Digits-1));

   if(PRICE_MAX>PRICE_MAX2)
     {
      PRICE_MAX=PRICE_MAX2;
     }

   strTest+="\n PRICE_MAX: "+c(PRICE_MAX);
   strTest+="\n PRICE_MIN: "+c(PRICE_MIN);

   _MaxPer=int(MathPow(10,Digits)*(-1));
   int _MaxPerTemp=-1;

   for(int i=PRICE_MIN;i<PRICE_MAX;i++)
     {
      //double _i=(i*10)/MathPow(10,Digits);
      if(_MaxPer<Arr_Price_Past1[i])
        {
         _MaxPer=Arr_Price_Past1[i];
         _MaxPerTemp=i;
        }
     }

   strTest+="\n _MaxPer: "+c(_MaxPer);
   strTest+="\n _MaxPerTemp: "+c(_MaxPerTemp);

//DrawHistogram(Symbol(),Period(),FIRST_B,VISIBLE_B,WIDTH_B,Full_D,Darw,strHisto+"H"+c(PRICE_MIN),_i,clrLime,Darw);
   if(_MaxPer>0)
     {
      for(int i=PRICE_MIN;i<PRICE_MAX;i++)
        {
         double _i=(i*10)/MathPow(10,Digits);
         double Darw=NormalizeDouble((double(Arr_Price_Past1[i])/double(_MaxPer))*100,2);
         if(Darw>0)
           {
            DrawHistogramV(Symbol(),Period(),FIRST_B,VISIBLE_B,WIDTH_B,Full_D,Darw,strHisto+"H"+c(i),_i,clrDimGray,c(Arr_Price_Past1[i])+"n | "+c(Darw,2)+"%");
           }
        }
     }
   else
     {

     }

   Comment(strTest);
  }
int _MaxPer=int(MathPow(10,Digits)*(-1));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _DrawHistogram(int &Array[],double Full_D,string strHisto,color clr)
  {

   int FIRST_B=int(ChartGetInteger(ChartID(),CHART_FIRST_VISIBLE_BAR,0));
   int VISIBLE_B=int(ChartGetInteger(ChartID(),CHART_VISIBLE_BARS,0));
   int WIDTH_B=int(ChartGetInteger(ChartID(),CHART_WIDTH_IN_BARS,0));

   ObjectsDeleteAll(ChartID(),strHisto,0,OBJ_TREND);

   int PRICE_MAX =int(ChartGetDouble(ChartID(),CHART_PRICE_MAX,0)*MathPow(10,Digits-Pip));
   int PRICE_MIN =int(ChartGetDouble(ChartID(),CHART_PRICE_MIN,0)*MathPow(10,Digits-Pip));

   int PRICE_MAX2=int(_High_Max*MathPow(10,Digits-1));

   if(PRICE_MAX>PRICE_MAX2)
      PRICE_MAX=PRICE_MAX2;

   _MaxPer=int(MathPow(10,Digits)*(-1));
   int _MaxPerTemp=-1;

   for(int i=PRICE_MIN;i<PRICE_MAX;i++)
     {
      if(_MaxPer<Array[i])
        {
         _MaxPer=Array[i];
         _MaxPerTemp=i;
        }
     }

   if(_MaxPer>0)
     {
      for(int i=PRICE_MIN;i<PRICE_MAX;i++)
        {
         double _i=(i*MathPow(10,Pip))/MathPow(10,Digits);
         double Darw=NormalizeDouble((double(Array[i])/double(_MaxPer))*100,2);
         if(Darw>0)
           {
            DrawHistogramV(Symbol(),Period(),FIRST_B,VISIBLE_B,WIDTH_B,Full_D,Darw,indy_name+strHisto+"-"+c(i),_i,clr,c(Array[i])+"n | "+c(Darw,2)+"%");
           }
        }
     }
   else
     {

     }
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

   Comment(SMS);
  }
//+------------------------------------------------------------------+
