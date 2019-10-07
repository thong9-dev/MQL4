//+------------------------------------------------------------------+
//|                                                      b-clock.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string ExtName="B-clock@";
bool ExtHidden=true;

//extern string FontName   = "Arial";
//extern int    FontSize   = 10;
extern color  FontColor=clrYellow;
//extern bool   ShowSpread = True;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetMillisecondTimer(1000);

//--- indicator buffers mapping
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
//SymbolInfo();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   SymbolInfo();
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
string cFillZero(int v)
  {
   string temp;
   if(v<10)
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;

  }
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {
   v=NormalizeDouble(v,Digit);
   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3== 0 && i<n)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SymbolInfo()
  {
//---
//string TimeLeft=TimeToStr(Time[0]+Period()*60-TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
   double Spread=MarketInfo(Symbol(),MODE_SPREAD);

   double Body1=MathAbs(iClose(NULL,PERIOD_D1,1)-iOpen(NULL,PERIOD_D1,1));
   double Body0=NormalizeDouble(iClose(NULL,PERIOD_D1,0)-iClose(NULL,PERIOD_D1,1),Digits);
   
   //printf("Body0 "+Body0);
   
   if(iClose(NULL,PERIOD_D1,1)!=0)
     {
      double Strength=(Body0/Body1)*100;
      string Label=" "+_Comma(Strength,2,"")+"%"+" | "+_getCountdownTime()+" | "+_Comma(Spread,0," ");

      int InfoFontSize=9;

      string Arrow="q";
      color clrArrow=clrRed;
      if(Strength>0){ Arrow="p";clrArrow=clrLime;}

      string tooltip="Strength | Candle Time | Spread";

      Draw("Arrow",Arrow,InfoFontSize-1,"Wingdings 3",clrArrow,CORNER_RIGHT_LOWER,200,18,tooltip);
      Draw("Time",Label,InfoFontSize,"Calibri",FontColor,CORNER_RIGHT_LOWER,190,20,tooltip);

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw(string name,string label,int size,string font,color clr,ENUM_BASE_CORNER c,int x,int y,string tooltip)
  {
//---
   name=ExtName+name;
   int windows=0;
//if(AllowSubwindow && WindowsTotal()>1) windows=1;
   ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,windows,0,0);
   ObjectSetText(name,label,size,font,clr);
   ObjectSet(name,OBJPROP_CORNER,c);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
//--- justify text
   ObjectSet(name,OBJPROP_ANCHOR,0);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSet(name,OBJPROP_SELECTABLE,0);
   ObjectSet(name,OBJPROP_SELECTABLE,0);
   ObjectSet(name,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,ExtHidden);
//---
  }
//+------------------------------------------------------------------+
string _getCountdownTime()
  {
   double i;
   int m,s,k,h,day=0;
   string str;
//---
   m = int(Time[0]+Period()*60-CurTime());
   i = m/60;
   s = m%60;
   m = (m-m%60)/60;
   h = int(i/60);
   k = m -(h*60);

//Comment(h);
//---
   if(h>24)
     {
      day=int(h/24);
      h=int(h%24);
     }
//---

   if(day>0)
      str+=cFillZero(day)+"d:";
   if(h>0)
      str+=cFillZero(h)+"h:";
   if(k>0)
      str+=cFillZero(k)+"m:";
   str+=cFillZero(s)+"s";

   return str;
  }
//+------------------------------------------------------------------+
