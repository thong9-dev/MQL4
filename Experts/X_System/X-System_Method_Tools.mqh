//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |

#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "X-System.mq4";
//---
#include "X-System_Method_Value.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setTemplate()
  {

   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);

   ChartSetInteger(0,CHART_COLOR_GRID,clrWhite);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
  }

double High_x,Low__x,Close__x;
string SMS2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getHL_AVG(int v)
  {
   double h=0,l=0,c=0;
   for(int i=1;i<=v;i++)
     {
      h+=iHigh(Symbol(),PERIOD_D1,i);
      l+=iLow(Symbol(),PERIOD_D1,i);
      c+=iClose(Symbol(),PERIOD_D1,i);
     }
   High_x =NormalizeDouble(h/v,Digits);
   Low__x =NormalizeDouble(l/v,Digits);
   Close__x=NormalizeDouble(c/v,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getRangPivot()
  {
   double High_=iHigh(Symbol(),PERIOD_D1,1);
   double Low__=iLow(Symbol(),PERIOD_D1,1);
   double Close_=iClose(Symbol(),PERIOD_D1,1);

   _getHL_AVG(2);

   _Rang=High_-Low__;
   _Pivot=(High_+Low__+Close_)/3;

//_Rang=High_x-Low__x;
//_Pivot=(High_x+Low__x+Close__x)/3;

//---
   if((_Rang*BaseDigits)<=500 || (_Rang*BaseDigits)>=2000)
     {
      //_Rang=500/BaseDigits;
      WorkFreeze=false;
     }
   else
     {
      WorkFreeze=true;
     }

//---
   _Rang=NormalizeDouble(_Rang,Digits);
   _Pivot=NormalizeDouble(_Pivot,Digits);

   _Rangp=int(_Rang*BaseDigits);
//+----------------
   _setFiboLine();
//+----------------
//HLineCreate_(0,"LINE_High",0,High_,clrMagenta,0,1,false,true,false,0);
//HLineCreate_(0,"LINE_Low",0,Low__,clrMagenta,0,1,false,true,false,0);
   HLineCreate_(0,"LINE_PIVOT",0,_Pivot,clrYellow,0,1,false,true,false,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setFiboLine0()
  {
   int cnt=ArraySize(Fibo_TB);
   cnt++;
   ArrayResize(Fibo_BX,cnt);
   for(int i=1,j=0;i<ArraySize(Fibo_BX);i++,j++)
     {
      Fibo_BX[i]=Fibo_TB[j]*_Rang;
     }

   _pinLine(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setFiboLine()
  {
   double GridSizeSum=0;
   int _cntGrid=cntGrid+1;
   double Size=getEnumSar(OptionGrid);

//---
   printf(Size+" / "+_cntGrid);
   ArrayResize(Fibo_BX,_cntGrid);
   for(int i=1,j=0;i<ArraySize(Fibo_BX);i++,j++)
     {
      GridSizeSum+=Size;
      Fibo_BX[i]=GridSizeSum*_Rang;
     }

   _pinLine(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Symbol_()
  {
   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getEnumSar(double v)
  {
   return NormalizeDouble(double(v)/1000,4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _directSar_warning()
  {
   _iSarStep=getEnumSar(OptionSar);
   double v=NormalizeDouble(iSAR(Symbol(),PERIOD_H4,_iSarStep,0.2,0),Digits);

   double xv;

   double zv=Fibo_BX[0]*BaseDigits*.5;

//---
   if(Bid<v)
     {//---1
      xv=(v-Bid)*BaseDigits;
      cacuRateTP(xv);
      _LabelSet("Text_RR1",100,150,clrWhite,"Arial",12,_Comma(xv,0," ")+" | "+_Comma(zv,0,"")+" | "+_Comma(rateTP,2,""));
      if(xv>zv)
        {//---A
         return 5;//Sell
        }
      else
        {//---B
         return 4;//Buy
        }
     }
   if(Bid>v)
     {//---2
      xv=(Bid-v)*BaseDigits;
      cacuRateTP(xv);
      _LabelSet("Text_RR1",100,150,clrWhite,"Arial",12,_Comma(xv,0," ")+" | "+_Comma(zv,0,"")+" | "+_Comma(rateTP,2,""));
      if(xv>zv)
        {//---D
         return 4;//Buy
        }
      else
        {//---C
         return 5;//Sell
        }
     }
//---
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void cacuRateTP(double xv)
  {
   rateTP=_Rangp/xv;
   rateTP=MathMod(rateTP,0.61);
   if(rateTP<0.3)
     {
      rateTP=0.3;
     }
   rateTP=NormalizeDouble(rateTP,4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _directSar()
  {
   _iSarStep=getEnumSar(OptionSar);
   double v=NormalizeDouble(iSAR(Symbol(),PERIOD_H4,_iSarStep,0.2,0),Digits);

   if(v>Bid)
     {
      return 5;//Sell
     }
   else
     {
      return 4;//Buy
     }

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _directSarStr(int v)
  {
   if(v==5)
     {
      return "Sell";
     }
   else if(v==4)
     {
      return "Buy";
     }
   else
     {
      return "Wait";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= z;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }
   return temp3;
  }

bool Workday,Workdayx;
string SMS_Workday;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _StayFriday()
  {
   int H=TimeHour(TimeLocal());

   SMS_Workday="Day : "+string(DayOfWeek())+":"+_FillZero(H)+" | Workday ["+string(cntRunDay)+"] : "+_strBoolYN(Workday);
//_LabelSet("TextTime",10,50,clrYellow,"Arial",10,SMS_Workday);
//---
   if((DayOfWeek()<=1 && H<=8) || (DayOfWeek()>=5 && H>=20))
     {
      Workday=false;//OFF-Rest
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" DayOff");
        }
     }
   else
     {
      Workday=True;//ON
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" Workday");
        }

     }
   if(Workdayx!=Workday)
      Print(__FUNCTION__+" "+string(Workday));
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _strBoolYN(int v)
  {
   if(v)
      return "Yes";
   else
      return "No";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _FillZero(int v)
  {
   string temp;
   if(v<10)
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;

  }
//+------------------------------------------------------------------+
