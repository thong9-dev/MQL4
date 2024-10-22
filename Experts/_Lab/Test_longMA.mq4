//+------------------------------------------------------------------+
//|                                                  Test_longMA.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>

double Trend;
#define TrendUP 1
#define TrendDW 2
#define TrendSW -1
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTick();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
string Sms;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   Sms="";
   
   HubNavigator();
   
   Comment(Sms);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HubNavigator()
  {
   double v1,v2;
   v1=getMA(PERIOD_H4,30);
   v2=Degrees_iRSI(PERIOD_H1,25);

   double DegreesCut=30;
   string TN="SW";
   if(v1==1)
     {
      if(v2>DegreesCut)TN="UP";
      //else if(v2<DegreesCut*-1)TN="DW";
     }
   else if(v1==2)
     {
      if(v2<DegreesCut*-1)TN="DW";
     }

   Sms+="\n\n"+v1+" | "+v2+" #"+TN;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getART()
  {
   if(iATR(Symbol(),PERIOD_H4,2,0)<350*Point)
     {
      //return 0;
     }
   return (
           (iATR(Symbol(),PERIOD_H4,2,2)*2.5)+
           (iATR(Symbol(),PERIOD_H4,2,1)*2.5)+
           (iATR(Symbol(),PERIOD_H4,2,0)*10)
           )/15;
  }
//+------------------------------------------------------------------+
double getMA(ENUM_TIMEFRAMES TF,int MaxScan)
  {
//---
   double MA_Quality;
   double MA_Main,MA_Curs,MA_C;
//---
   bool Month_UP=true,Month_DW=true;
   int Mark_Buy=-1,Mark_Sel=-1;
   double MarkATR_Buy=-1,MarkATR_Sel=-1;
//---
   MA_Quality=getART();
   for(int i=0;i<=MaxScan;i++)
     {
      MA_Main=iMA(Symbol(),TF,300,1,MODE_SMA,PRICE_WEIGHTED,i);
      MA_Curs=iMA(Symbol(),TF,150,1,MODE_SMA,PRICE_WEIGHTED,i);
      MA_C=iMA(Symbol(),TF,1,1,MODE_SMA,PRICE_WEIGHTED,i);

      if((MA_Curs-MA_Main>MA_Quality) && MA_C>MA_Main && Month_UP)
        {
         Month_UP=true;
        }
      else
        {
         Month_UP=false;
         Mark_Buy=i;
         MarkATR_Buy=MA_Quality;
        }
      //---
      if((MA_Main-MA_Curs>MA_Quality) && MA_C<MA_Main && Month_DW)
        {
         Month_DW=true;
        }
      else
        {
         Month_DW=false;
         Mark_Sel=i;
         MarkATR_Sel=MA_Quality;
        }
     }

   Sms+="MaxScanMA: "+c(MaxScan)+"\n";
   Sms+="Buy: "+c(Month_UP)+" | "+c(Mark_Buy)+" | "+c(MarkATR_Buy,Digits)+"\n";
   Sms+="Sell: "+c(Month_DW)+" | "+c(Mark_Sel)+" | "+c(MarkATR_Sel,Digits)+"\n";

   if(Month_UP && !Month_DW)
     {
      return 1;
     }
   else if(!Month_UP && Month_DW)
     {
      return 2;
     }
   else
     {
      return 0;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Degrees_iRSI(ENUM_TIMEFRAMES TF,double x1)
  {
   double Degrees;
   double _n=5;
   double _Slope=0,_Step=x1/_n;
//---
   double _Strat=x1,_End;
   double y1,y2;
//---
   for(int i=0;i<_n;i++)
     {
      _End=_Strat-_Step;
      y1=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(_Strat));
      y2=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(_End));
      //---
      _Slope+=(y2-y1)/(_Strat-_End);
      //---
      _Strat=_End;
     }
//---
   y1=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(x1));
   y2=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(0));
   _Slope+=(y2-y1)/x1;
//   
   _Slope/=_n+1;
//---
   double _Degrees=0;
   Degrees=NormalizeDouble((_Slope*180)/M_PI,2);

   if(Degrees<0) _Degrees=360+Degrees;
   else _Degrees=Degrees;

   Sms+="\nRSI "+c(x1,0)+"n #";
   Sms+=c(Degrees,2)+"° | "+c(_Degrees,2)+"°";
//---
   return Degrees;
//---
/*double x2=0;
   double y1=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(x1));
   double y2=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(x2));

   double r=MathArctan((y2-y1)/(x1-x2));
   return NormalizeDouble((r*180)/M_PI,2);*/
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Degrees_iMA(double x1)
  {
   x1=25;
   double Degrees;
   double _n=5;
   double _Slope=0,_Step=x1/_n;
//---
   double _Strat=x1,_End;
   double y1,y2;
//---
   for(int i=0;i<_n;i++)
     {
      _End=_Strat-_Step;
      y1=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(_Strat));
      y2=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(_End));
      //---
      _Slope+=(y2-y1)/(_Strat-_End);
      //---
      _Strat=_End;
     }
//---
   y1=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(x1));
   y2=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(0));
   _Slope+=(y2-y1)/x1;
//   
   _Slope/=_n+1;
//---
   double _Degrees=0;
   Degrees=NormalizeDouble((_Slope*180)/M_PI,2);
   if(Degrees<0)
     {
      _Degrees=360+Degrees;
     }
   Comment(c(Degrees,2)+" | "+c(_Degrees,2));
//---
   return Degrees;
//---
/*double x2=0;
   double y1=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(x1));
   double y2=iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,int(x2));

   double r=MathArctan((y2-y1)/(x1-x2));
   return NormalizeDouble((r*180)/M_PI,2);*/
  }
//+------------------------------------------------------------------+
