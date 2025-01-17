//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
   Generated by EX4-TO-MQ4 decompiler V4.0.224.1 []
   Website: http://purebeam.biz
   E-mail : purebeam@gmail.com
*/
#property copyright "Copyright © 2008, 2hrfx.com"
#property link      "http://www.2hrfx.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrNONE
#property indicator_color2 clrNONE
#property indicator_color3 clrNONE
#property indicator_color4 clrNONE

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_Price
  {
   MODE_Price0=0,
   MODE_Price1=1,
   MODE_Price2=2,
   MODE_Price3=3,
   MODE_Price4=4,
   MODE_Price5=5,
   MODE_Price6=6,
  };
extern ENUM_MODE_Price  MODE_Price     = MODE_Price0;
extern int              Period_Length  = 20;
extern int              Displace       = 0;
extern int              Filter         = 0;
extern bool             Color          = true;
extern int              ColorBarBack   = 1;
extern double           Deviation      = 0.0;
extern string  Spector="------------------Daren----------------------";//----------------------------------------
extern color            InpMA_clr_UP   = clrLime;
extern color            InpMA_clr_DW   = clrRed;
input int              InpMA_Weight=2;
extern string  Spector2="------------------Daren----------------------";//----------------------------------------

double Arr_Main[];
double Arr_UP[];
double Arr_DW[];

double Ext_TCCI_Result[];
double Arr_1[];

int Length_C=4;
int g_index_128_T;
int IN_i_1;
int IN_i_2;
//
double _Pi3=3.0*M_PI;

double IN_d_1;
double IN_d_2;
double IN_d_3;

double gd_152;

double gd_184;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//IndicatorBuffers(7);

   SetIndexStyle(0,DRAW_LINE,0,InpMA_Weight,clrMagenta);
   SetIndexBuffer(0,Arr_Main);

   SetIndexStyle(1,DRAW_LINE,0,InpMA_Weight,InpMA_clr_UP);
   SetIndexBuffer(1,Arr_UP);

   SetIndexStyle(2,DRAW_LINE,0,InpMA_Weight,InpMA_clr_DW);
   SetIndexBuffer(2,Arr_DW);

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Ext_TCCI_Result);

   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   string ShortName="SaneFX("+Period_Length+")";
   IndicatorShortName(ShortName);

   SetIndexLabel(0,"SaneFX");
   SetIndexLabel(1,"Up");
   SetIndexLabel(2,"Dn");
   SetIndexLabel(3,"R-TCCI");

//Displace=0;
   SetIndexShift(0,Displace);
   SetIndexShift(1,Displace);
   SetIndexShift(2,Displace);

   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   SetIndexEmptyValue(2,EMPTY_VALUE);

//Period_Length=20;gi_140=4;==100
   SetIndexDrawBegin(0,(Period_Length*Length_C)+Period_Length);
   SetIndexDrawBegin(1,(Period_Length*Length_C)+Period_Length);
   SetIndexDrawBegin(2,(Period_Length*Length_C)+Period_Length);

   IN_i_1 = Period_Length - 1;
   IN_i_2 = Period_Length * Length_C + IN_i_1;

   ArrayResize(Arr_1,IN_i_2);
   IN_d_2=0;

   for(int i=0; i<IN_i_2-1; i++)
     {
      if(i<=IN_i_1-1)
         IN_d_3=1.0*i/(IN_i_1-1);
      else
         IN_d_3=(i-IN_i_1+1) *(2.0*Length_C-1.0)/(Length_C*Period_Length-1.0)+1.0;

      gd_152 = MathCos(M_PI * IN_d_3);
      gd_184 = 1.0 / (_Pi3 * IN_d_3 + 1.0);

      if(IN_d_3<=0.5)
         gd_184=1;

      Arr_1[i]=gd_184*gd_152;
      IN_d_2+=Arr_1[i];
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _start()
  {
   int li_12;
   double ld_16;
   int l_ind_counted_8=IndicatorCounted();

   if(l_ind_counted_8>0)
      li_12=Bars-l_ind_counted_8;

   if(l_ind_counted_8<0)
      return (0);

   if(l_ind_counted_8==0)
      li_12=Bars-IN_i_2-1;
//+------------------------------------------------------------------+

   if(l_ind_counted_8<1)
     {
      for(int i=1; i<(Period_Length*Length_C+Period_Length); i++)
        {
         Arr_Main[Bars-i] = 0;
         Arr_UP[Bars - i] = 0;
         Arr_DW[Bars - i] = 0;
        }
     }
//+------------------------------------------------------------------+
   for(int j=li_12; j>=0; j--)
     {
      IN_d_1=0;
      for(int k=0; k<=IN_i_2-1; k++)
        {
         if(MODE_Price==0)
            ld_16=Close[j+k];
         else
           {
            if(MODE_Price==1)
               ld_16=Open[j+k];
            else
              {
               if(MODE_Price==2)
                  ld_16=High[j+k];
               else
                 {
                  if(MODE_Price==3)
                     ld_16=Low[j+k];
                  else
                    {
                     if(MODE_Price==4)
                        ld_16=(High[j+k]+(Low[j+k]))/2.0;
                     else
                       {
                        if(MODE_Price==5)
                           ld_16=(High[j+k]+(Low[j+k])+(Close[j+k]))/3.0;
                        else
                        if(MODE_Price==6)
                           ld_16=(High[j+k]+(Low[j+k])+2.0 *(Close[j+k]))/4.0;
                       }
                    }
                 }
              }
           }
         IN_d_1+=Arr_1[k]*ld_16;
        }
      //+------------------------------------------------------------------+
      if(IN_d_2>0.0)
        {
         Arr_Main[j]=(Deviation/100.0+1.0)*IN_d_1/IN_d_2;
        }
      if(Filter>0)
        {
         if(MathAbs(Arr_Main[j]-(Arr_Main[j+1]))<Filter*Point)
            Arr_Main[j]=Arr_Main[j+1];
        }
      if(Color)
        {
         Ext_TCCI_Result[j]=Ext_TCCI_Result[j+1];

         if(Arr_Main[j]-(Arr_Main[j+1])>Filter*Point)
            Ext_TCCI_Result[j]=1;

         if(Arr_Main[j+1]-Arr_Main[j]>Filter*Point)
            Ext_TCCI_Result[j]=-1;

         if(Ext_TCCI_Result[j]>0.0)
           {//UP
            Arr_UP[j]=Arr_Main[j];
            //---
            if(Ext_TCCI_Result[j+ColorBarBack]<0.0)
               Arr_UP[j+ColorBarBack]=Arr_Main[j+ColorBarBack];
            //---
            Arr_DW[j]=EMPTY_VALUE;
           }
         if(Ext_TCCI_Result[j]<0.0)
           {//DW
            Arr_DW[j]=Arr_Main[j];
            //---
            if(Ext_TCCI_Result[j+ColorBarBack]>0.0)
               Arr_DW[j+ColorBarBack]=Arr_Main[j+ColorBarBack];
            //---
            Arr_UP[j]=EMPTY_VALUE;
           }
        }
        {
         //Ext_TCCI_Result
        }
     }
//+------------------------------------------------------------------+
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   _start();
//---

//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
