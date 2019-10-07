//+------------------------------------------------------------------+
//|                                                          XMA.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
#property copyright   "GoldenMaster"
#property version     "1.30"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 clrMagenta
#property indicator_color2 clrRed
#property indicator_color3 clrWhite
#property indicator_color4 clrWhite
#property indicator_color5 clrRed
#property indicator_color6 clrMagenta
#property indicator_color7 clrMagenta

#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 1
#property indicator_width5 1
//#property indicator_width6 1
//#property indicator_width7 1

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT

#property description "Mix MA vs Heiken Ashi"
#property description "# Applied Price _______________________ # Methods "
#property description "0 : Close price ________________________ 0 : Simple averaging "
#property description "1 : Open price ________________________ 1 : Exponential averaging "
#property description "2 : The Maximum price for the period ______  2 : Smoothed averaging "
#property description "3 : The Minimum price for the period _______ 3 : Linear averaging  "
#property description "4 : Median price, (H + L)/2"
#property description "5 : Typical price, (H + L + C)/3"
#property description "6 : Weighted close price, (H + L + C + C)/4"

extern string  Period_Series  =  "9/13/20/15";
extern string  Method_Series  =  "0/1/3/2";
extern string  Apply_Series   =  "0/0/0/0";
extern string  Shift_Series   =  "0/0/0/0";
extern string  Line0          =  "========== Show line ==========";  //====================
bool    LineFast       =  false;
bool    LineSlow       =  false;

int Period_Fast=0;
int Index_Fast=0;
int Period_Slow=0;
int Index_Slow=0;

double Ext_Main[];
double Ext_Main_UP[];
double Ext_Main_DW[];
double Ext_Main_Arr_UP[];
double Ext_Main_Arr_DW[];
double Ext_Fast[];
double Ext_Slow[];

string   sep               ="/";
ushort   u_sep             =StringGetCharacter(sep,0);
int      Period_Serie_[];
string   Method_Serie_[];
string   Apply_Serie_[];
string   Shift_Serie_[];
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
   IndicatorBuffers(7);
//---
   SetIndexBuffer(0,Ext_Main);
   SetIndexBuffer(1,Ext_Main_UP);
   SetIndexBuffer(2,Ext_Main_DW);
   SetIndexBuffer(3,Ext_Fast);
   SetIndexBuffer(4,Ext_Slow);
   SetIndexBuffer(5,Ext_Main_Arr_UP);
   SetIndexBuffer(6,Ext_Main_Arr_DW);
//---
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,233);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,234);
//---

   int k;
   string sTEMP[];

   k=StringSplit(Period_Series,u_sep,sTEMP);
   ArrayResize(Period_Serie_,ArraySize(sTEMP));
   for(int i=0; i<ArraySize(sTEMP); i++)
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

   for(int i=0; i<ArraySize(iTEMP); i++)
     {
      if(Period_Serie_[i]==Period_Fast)
        {
         Index_Fast=i;
         break;
        }
     }

   for(int i=0; i<ArraySize(iTEMP); i++)
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
   SetIndexLabel(1,"XMA-U");
   SetIndexLabel(2,"XMA-D");
   SetIndexLabel(3,"XMA-S("+string(Period_Fast)+")");
   SetIndexLabel(4,"XMA-F("+string(Period_Slow)+")");
   SetIndexLabel(5,"A");
   SetIndexLabel(6,"B");


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
      for(int i=rates_total-1; i>=0; i--)
        {
         temp=0;
         for(int j=0; j<ArraySize(Period_Serie_); j++)
           {
            temp+=iMA(Symbol(),Period(),Period_Serie_[j],int(Shift_Serie_[j]),int(Method_Serie_[j]),int(Apply_Serie_[j]),i)
                  *
                  double(Period_Serie_[j]);
           }
         double Main =temp/Wage;
         Ext_Main[i]=Main;

         //--- Heiken Ashi
         if(HA_Dir(i)==OP_BUY)
           {
            Ext_Main_UP[i]    = Ext_Main[i];
            if(i!=rates_total-1)
               Ext_Main_UP[i+1]  = Ext_Main[i+1];
           }
         if(HA_Dir(i)==OP_SELL)
           {
            Ext_Main_DW[i]    = Ext_Main[i];
            if(i!=rates_total-1)
               Ext_Main_DW[i+1]  = Ext_Main[i+1];
           }

         //--- Arrow
         //double varSAR=iSAR(Symbol(),Period(),0.02,0.2,i);
         if(i<=rates_total-3)
           {
            if(Ext_Main_DW[i+2]==NULL&&
               Ext_Main_DW[i+1]!=NULL&&
               Ext_Main_DW[i]!=NULL)
              {
               //Ext_Main_Arr_DW[i]=Ext_Main_DW[i];
              }
           }
         if(Ext_Main_DW[i]!=NULL)
           {
            //Ext_Main_Arr_DW[i]=Main;
           }

         //---

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
   for(int i=0; i<ArraySize(Period_Serie_); i++)
      r+=double(Period_Serie_[i]);
   return r;
  }
int HA_Dir(int n)
  {
   double HA_Open=iCustom(Symbol(),Period(),"Heiken Ashi",
                          clrNONE,clrNONE,clrNONE,clrNONE,
                          2,n);
   double HA_Clos=iCustom(Symbol(),Period(),"Heiken Ashi",
                          clrNONE,clrNONE,clrNONE,clrNONE,
                          3,n);
   if(HA_Open>HA_Clos)
      return OP_BUY;
   return OP_SELL;
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
