//+------------------------------------------------------------------+
//|                                  SkyFall [Scap ShortTerm][2].mq4 |
//|                                            facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_Price
  {
   MODE_PriceC=0,//C
   MODE_PriceO=1,//O
   MODE_PriceH=2,//H
   MODE_PriceL=3,//L
   MODE_PriceHL=4,//HL/2
   MODE_PriceHLC3=5,//HLC/3
   MODE_PriceHLC4=6,//(HL+2)*(C/4)
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_IndexConect
  {
   MODE_Line=0,
   MODE_Direct=1,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern double     Lots_=0.1;//Lots
extern ENUM_TIMEFRAMES Minor_Time=PERIOD_H1;
extern ENUM_TIMEFRAMES Major_Time=PERIOD_CURRENT;
extern ENUM_TIMEFRAMES Prime_Time=PERIOD_CURRENT;

extern int        Minor_Period=20;
extern int        Major_Period=8;
extern int        Prime_Period=4;

extern int        Minor_BarCount=8;
extern int        Major_BarCount=8;
extern int        Prime_BarCount=4;
extern double     OrderNearby=100;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   OnTick();
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   string CMM="";
//---
//CMM+="\n"+BufferGet(Minor_Time,MODE_PriceC,Minor_Period,MODE_Line,Minor_BarCount,0);
   string PathFile="_Employ/Line_MrNit/Xtreme_Line_Connect";
   double _iCustom;
   string Str="";
   for(int i=0;i<10;i++)
     {
      _iCustom=iCustom(Symbol(),Period(),PathFile,Period(),0,20,i,1);
      
      Str=DoubleToStr(_iCustom,Digits);
      
      if(_iCustom==EMPTY_VALUE)
         Str="_";
         
      CMM+="\n"+Str;
     }
//---
   Comment(CMM);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
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
string BufferGet(ENUM_TIMEFRAMES TF,int Mode_CALL,int Mode_Period,ENUM_MODE_IndexConect Index,int Bar,int Digits_)
  {
   string Buffer="";
   for(int i=1+Bar-1;i>=1;i--)
     {
      Buffer+=DirToStr(TCCI_Connect(TF,Mode_CALL,Mode_Period,Index,i,Digits_));
     }
   return Buffer;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TCCI_Connect(int TF,int Mode_CALL,int Mode_Period,int Index,int Bar,int Digits_)
  {
   string PathFile="_Employ/Line_MrNit/Xtreme Line - Connect";
   double _iCustom=iCustom(Symbol(),TF,PathFile,TF,Mode_CALL,Mode_Period,Index,Bar);

   if(_iCustom==EMPTY_VALUE) _iCustom=0;

   return NormalizeDouble(_iCustom,Digits_);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DirToStr(double statement)
  {
   return statement;
   switch(int(statement))
     {
      case  OP_BUY:
         return "U";
      case  OP_SELL:
         return "D";
      case  -1:
         return "H";
     }
   return "-";
  }
//+------------------------------------------------------------------+
