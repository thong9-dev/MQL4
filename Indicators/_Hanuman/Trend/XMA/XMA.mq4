//+------------------------------------------------------------------+
//|                                                          XMA.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
#property copyright   "FxHanuman.com"
#property version     "1.30"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrMagenta
#property indicator_color2 clrWhite
#property indicator_color3 clrRed

#property indicator_width1 2
#property indicator_width2 1
#property indicator_width3 1

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT

#property description "# Applied Price _______________________ # Methods "
#property description "0 : Close price ________________________ 0 : Simple averaging "
#property description "1 : Open price ________________________ 1 : Exponential averaging "
#property description "2 : The Maximum price for the period ______  2 : Smoothed averaging "
#property description "3 : The Minimum price for the period _______ 3 : Linear averaging  "
#property description "4 : Median price, (H + L)/2"
#property description "5 : Typical price, (H + L + C)/3"
#property description "6 : Weighted close price, (H + L + C + C)/4"


extern string Period_Series="50/100";
extern string Method_Series="0/0";
extern string Apply_Series="0/0";
extern string Shift_Series="0/0";
extern string  Line0="========== Show line ==========";//====================
extern bool LineFast=true;
extern bool LineSlow=true;
int Period_Fast=0;
int Index_Fast=0;
int Period_Slow=0;
int Index_Slow=0;

double Ext_Main[];
double Ext_Fast[];
double Ext_Slow[];

string sep="/";
int Period_Serie_[];
string Method_Serie_[];
string Apply_Serie_[];
string Shift_Serie_[];
ushort  u_sep=StringGetCharacter(sep,0);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
/*Period_Serie="9,7,15,10";
   Method_Serie="0,3,1,2";
   Apply_Serie="6,6,6,6";
   Shift_Serie="0,0,0,0";*/

//--- indicator buffers mapping
   IndicatorDigits(Digits);
   IndicatorBuffers(3);

   SetIndexBuffer(0,Ext_Main);
   SetIndexBuffer(1,Ext_Fast);
   SetIndexBuffer(2,Ext_Slow);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);

   int k;
   string sTEMP[];

   k=StringSplit(Period_Series,u_sep,sTEMP);
   ArrayResize(Period_Serie_,ArraySize(sTEMP));
   for(int i=0;i<ArraySize(sTEMP);i++)
      Period_Serie_[i]=int(sTEMP[i]);

   k=StringSplit(Method_Series,u_sep,Method_Serie_);
   k=StringSplit(Apply_Series,u_sep,Apply_Serie_);
   k=StringSplit(Shift_Series,u_sep,Shift_Serie_);



   int iTEMP[];
   ArrayCopy(iTEMP,Period_Serie_,0,0,0);
   bool Sort=ArraySort(iTEMP,WHOLE_ARRAY,0,MODE_ASCEND);
   if(LineFast)
      Period_Fast=(Sort)?iTEMP[0]:-1;

   Sort=ArraySort(iTEMP,WHOLE_ARRAY,0,MODE_DESCEND);
   if(LineSlow)
      Period_Slow=(Sort)?iTEMP[0]:-1;

   for(int i=0;i<ArraySize(iTEMP);i++)
     {
      if(Period_Serie_[i]==Period_Fast)
        {
         Index_Fast=i;
         break;
        }
     }

   for(int i=0;i<ArraySize(iTEMP);i++)
     {
      if(Period_Serie_[i]==Period_Slow)
        {
         Index_Slow=i;
         break;
        }
     }

//---
   string short_name="XMA-X("+Period_Series+")";
   IndicatorShortName("XMA");
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"XMA-F("+string(Period_Fast)+")");
   SetIndexLabel(2,"XMA-S("+string(Period_Slow)+")");
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
   if(ArraySize(Period_Serie_)==ArraySize(Method_Serie_) &&
      ArraySize(Method_Serie_)==ArraySize(Apply_Serie_)&&
      ArraySize(Apply_Serie_)==ArraySize(Shift_Serie_))
     {
      double temp=0,Wage=Wage();
      for(int i=0;i<rates_total-1;i++)
        {
         temp=0;
         for(int j=0;j<ArraySize(Period_Serie_);j++)
           {
            temp+=iMA(Symbol(),Period(),Period_Serie_[j],int(Shift_Serie_[j]),int(Method_Serie_[j]),int(Apply_Serie_[j]),i)
                  *
                  double(Period_Serie_[j]);
           }
         Ext_Main[i]=temp/Wage;

         Ext_Fast[i]=iMA(Symbol(),Period(),Period_Fast,int(Shift_Serie_[Index_Fast]),int(Method_Serie_[Index_Fast]),int(Apply_Serie_[Index_Fast]),i);
         Ext_Slow[i]=iMA(Symbol(),Period(),Period_Slow,int(Shift_Serie_[Index_Slow]),int(Method_Serie_[Index_Slow]),int(Apply_Serie_[Index_Slow]),i);

        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Wage()
  {
   double r=0;
   for(int i=0;i<ArraySize(Period_Serie_);i++)
      r+=double(Period_Serie_[i]);
   return r;
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

  }
//+------------------------------------------------------------------+
