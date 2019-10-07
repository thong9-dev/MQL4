//+------------------------------------------------------------------+
//|                                                    Hit_Order.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/DrawHistogram.mqh>

extern double Parameter1_PercentIn=90;
extern double Parameter2_Point=175;

string indy_name="EA-TB#";

int Arr_VolH_Now[24];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   setTemplate();

   _ArraySetData(Arr_VolH_Now);
   _DrawHistogram(Arr_VolH_Now,"Vol-H",clrMagenta,__LINE__);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

   ObjectsDeleteAll(ChartID(),indy_name,0,OBJ_TREND);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool chkOpened=false;
int NowHour=0,NowHour_=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string strComment="";
   if(!IsOptimization())
     {
      double ACCOUNT_PROFIT_=AccountInfoDouble(ACCOUNT_PROFIT);
      double ACCOUNT_BALANCE_=AccountInfoDouble(ACCOUNT_BALANCE);
      double ACCOUNT_PerDrawdown=(ACCOUNT_PROFIT_/ACCOUNT_BALANCE_)*100;

      double MM_Capital=500;
      double MM_Profit=ACCOUNT_BALANCE_-MM_Capital;
      double MM_ProfitPer=(MM_Profit/MM_Capital)*100;

      strComment+="\n MM_Profit: "+c(MM_ProfitPer,2)+"%";
      strComment+="\n _BALANCE: "+c(ACCOUNT_BALANCE_,2);

      strComment+="\n";

      strComment+="\n _PROFIT: "+c(ACCOUNT_PROFIT_,2);
      strComment+="\n _PerDrawdown: "+c(ACCOUNT_PerDrawdown,2)+"%";
      Comment(strComment);
     }

//---
   if(_iNewBar(PERIOD_M30))
     {
      _ArraySetData(Arr_VolH_Now);

      NowHour=TimeHour(iTime(Symbol(),PERIOD_M30,0));

      if(NowHour!=NowHour_)
        {
         NowHour_=NowHour;
         chkOpened=true;
        }
      //strComment+="\n "+NowHour_+"|"+NowHour;
      //Comment(strComment);
      if(
         (Draw_Max>0 && ((Arr_VolH_Now[NowHour]/Draw_Max)*100)>Parameter1_PercentIn)
         )
        {

         if(
            iOpen(Symbol(),PERIOD_M30,1)>iClose(Symbol(),PERIOD_M30,1) && 
            Bid>iMA(Symbol(),PERIOD_M30,24,1,MODE_SMMA,PRICE_CLOSE,1) && 
            chkOpened
            )
           {
            double TP=NormalizeDouble(Ask+(Parameter2_Point*Point*1.5),Digits);
            int Ticket1=OrderSend(Symbol(),OP_BUY,0.1,Ask,168,0,TP,"",1,0);
            chkOpened=false;
           }
        }
     }
   _DrawHistogram(Arr_VolH_Now,"Vol-H",clrMagenta,__LINE__);

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
   if((id==CHARTEVENT_CHART_CHANGE) || (id==CHARTEVENT_CLICK))
     {
      _DrawHistogram(Arr_VolH_Now,"Vol-H",clrMagenta,__LINE__);
     }
  }
extern int FocusTime=80;
extern int FocusDay=120;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ArraySetData(int &Array[])
  {
//int Bar=iBars(Symbol(),FocusTime)-1;
   int Bar=((24*FocusDay*60)/FocusTime)-1;
   for(int i=0;i<Bar;i++)
     {
      double B0=iClose(Symbol(),FocusTime,i);
      double B1=iClose(Symbol(),FocusTime,i+1);

      //Print(NormalizeDouble((((B0/B1)-1)*10000),2));
      //if(B1>0 && (((B0/B1)-1)*10000)>3)
      if(B0>B1 && B0-B1>=Parameter2_Point/MathPow(10,Digits))
        {
         int X1=int(StringSubstr(TimeToString(iTime(Symbol(),FocusTime,i),TIME_MINUTES),0,2));
         Arr_VolH_Now[X1]++;
        }
     }
   Draw_Max=MathPow(10,Digits)*(-1);
   for(int i=0;i<=23;i++)
     {
      if(Draw_Max<Arr_VolH_Now[i])
         Draw_Max=Arr_VolH_Now[i];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input double DarwScal=30;
double Draw_Max;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _DrawHistogram(int &Array[],string strHisto,color clr,int line)
  {
//ObjectsDeleteAll(ChartID(),indy_name,0,OBJ_TREND);
   if(IsOptimization()) return -1;
   double Chart_PRICE_MAX=ChartGetDouble(ChartID(),CHART_PRICE_MAX,0);
   double Chart_PRICE_MIN=ChartGetDouble(ChartID(),CHART_PRICE_MIN,0);

   double Chart_PRICE_Full=(Chart_PRICE_MAX-Chart_PRICE_MIN)*(DarwScal/100);

   double Draw_Bar=0;
   datetime date=0;

//---

   datetime NowBar_Date=iTime(Symbol(),PERIOD_H1,0);
   int NowBar=int(StringSubstr(TimeToString(NowBar_Date,TIME_MINUTES),0,2));

   color clrBar=clr;
   int width=1,style=1;
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
         if(PerDarw>=(Parameter1_PercentIn/100))style=0;
         else style=2;
         DrawTLineH(ChartID(),0,indy_name+strHisto+c(i),date,Chart_PRICE_MIN,Chart_PRICE_MIN+Draw_Bar,clrBar,style,1,false,cFillZero(i,2)+" | "+c(Array[i])+"n "+c(PerDarw*100,2)+"%");
        }
     }
//---
   datetime Day1=PERIOD_D1*60;

//Comment(NowBar_Date+"\n"+Test1Day+"\n"+TimeToString(NowBar_Date-Test1Day,TIME_DATE));
   clrBar=clrBlue;
   for(int i=0;i<=23;i++)
     {
      if(Array[i]>0)
        {
         PerDarw=(Array[i]/Draw_Max);
         //Comment(PerDarw);
         Draw_Bar=Chart_PRICE_Full*PerDarw;
         //---
         date=StringToTime(TimeToString(NowBar_Date-Day1,TIME_DATE)+" "+cFillZero(i,2)+":00:00");
         //---
         if((i<23 && Array[i+1]>0 && Array[i]<Array[i+1]) || 
            (i==23 && Array[0]>0 && Array[i]<Array[0]))
           {
            if(i==NowBar)
               clrBar=clrLime;
            else
               clrBar=clrYellow;
           }
         else
           {
            if(i==NowBar)
               clrBar=clrWhite;
            else
               clrBar=clrBlue;
           }
         if(PerDarw>=(Parameter1_PercentIn/100))style=0;
         else style=2;

         DrawTLineH(ChartID(),0,indy_name+strHisto+c(i)+"P",date,Chart_PRICE_MIN,Chart_PRICE_MIN+Draw_Bar,clrBar,style,1,false,cFillZero(i,2)+" | "+c(Array[i])+"n "+c(PerDarw*100,2)+"%");
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
