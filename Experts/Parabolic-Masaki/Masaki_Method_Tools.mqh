//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |

#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "Masaki.mq4";
//---
#include "Masaki_Value.mqh";
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _SymbolShortName()
  {
   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getEnum(double v,double t)
  {
   return NormalizeDouble(v/t,4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _DirSarBack(int a,int b,int v)
  {
//a=2,b=4
   for(int i=a;i<b;i++)
     {
      if((_DirSarIn(a)==v) && (_DirSarIn(i)!=_DirSarIn(i+1)))
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getEnumSar(double v,double t)
  {
   return NormalizeDouble(double(v)/t,4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _DirSarIn(int x)
  {
   double v=NormalizeDouble(iSAR(Symbol(),0,_iSarStep,0.2,x),Digits);

   if(v>iClose(Symbol(),0,x))
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
int _DirSarOut(int x)
  {
//printf(__FUNCTION__+" "+string(_iSarStep));
   double v=NormalizeDouble(iSAR(Symbol(),PERIOD_H1,_iSarOut,0.2,x),Digits);

   if(v>iClose(Symbol(),PERIOD_H4,x))
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
void _setFiboBox()
  {
   double GridSizeSum=0;
   int _cntGrid=2;
   double Size=_getEnum(OptionFiBo,1000);

   _Rang=iHigh(Symbol(),PERIOD_D1,1)-iLow(Symbol(),PERIOD_D1,1);
   _Rang=NormalizeDouble(_Rang*BaseDigits,0);

   if(_Rang>=2000)
     {
      _Rang=2000;
     }

//_LabelSet("Move2",300,110,clrWhite,"Franklin Gothic Medium Cond",15,Size);
//---
//printf(Size+" / "+_cntGrid);
   ArrayResize(Fibo_BX,_cntGrid);
   for(int i=1,j=0;i<ArraySize(Fibo_BX);i++,j++)
     {
      GridSizeSum+=Size;
      Fibo_BX[i]=NormalizeDouble((GridSizeSum*_Rang)/BaseDigits,Digits);
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
   if((DayOfWeek()<=1 && H<=7) || (DayOfWeek()>=5 && H>=22))
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

   SMS_Workday="Day : "+string(DayOfWeek())+":"+_FillZero(H)+" | Workday ["+string(cntRunDay)+"] : "+_strBoolYN(Workday);
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
string c(bool v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(int v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(double v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
void PrintPic()
  {
  }
//+------------------------------------------------------------------+
