//+------------------------------------------------------------------+
//|                                               Static_MaBrige.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <Tools/Method_Tools.mqh>
//extern int CNT_Bar=10;
string indy_name="Stat_MA#";
extern int StepD=10;
input int Period_=1;//Period
extern ENUM_APPLIED_PRICE APPLIED_PRICE=PRICE_CLOSE;//APPLIED_PRICE 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double iMA_=0;
double Point_=MathPow(10,-1*Digits);
string sms="";
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
//---
   sms="";
//---
   Mode_Med(PERIOD_H4,36," H4-36",clrDimGray,C'40,40,40');
   //Mode_Med(PERIOD_H4,18," H4-18",clrDarkSlateGray,clrDarkSlateGray);

//---
   //Mode_Med(PERIOD_H1,36," H1-36",clrDarkSlateGray,clrBlack);
   //Mode_Med(PERIOD_H1,24," H1-24",clrDimGray,clrKhaki);
   Mode_Med(PERIOD_H1,12," H1-12",clrSlateGray,C'40,40,40');

//Mode_Med(PERIOD_H4,10," H1-10",clrSlateGray,clrKhaki);
//Mode_Med(PERIOD_H4,6," H1-6",clrNavy,clrKhaki);
//---
   string strA;
   for(int i=6;i<=36;i*=2)
     {
      //Mode_Med(PERIOD_H1,i," H1-"+c(i),clrNavy,clrYellow);
      strA+=c(i)+"|";
     }
//Mode_Med(PERIOD_H1,36," H1-X",clrNavy,clrYellow);

//Comment(strA);
//------
   int CNT_Bar=24;

   double Stat_AVG=0,Stat_Variance=0;
   for(int i=1;i<=CNT_Bar;i++)
     {
      iMA_=NormalizeDouble(iMA(Symbol(),0,1,0,MODE_SMA,PRICE_CLOSE,i),Digits);
      Stat_AVG+=iMA_;
     }
   Stat_AVG/=(CNT_Bar);
//HLineCreate_(0,"Stat_AVG","",0,Stat_AVG,clrSteelBlue,4,0,false,false,false,0);

   for(int i=0;i<CNT_Bar;i++)
      Stat_Variance+=NormalizeDouble(MathPow(iMA(Symbol(),0,1,0,MODE_SMA,PRICE_CLOSE,i)-Stat_AVG,2),Digits);
   Stat_Variance=NormalizeDouble(MathSqrt(Stat_Variance/(CNT_Bar)),Digits);
   sms+="\n\nVariance: "+c(Stat_Variance/Point_,Digits);

   DrawTLine(ChartID(),0,"Avg-0",Time[CNT_Bar],Time[0],Stat_AVG,clrKhaki,STYLE_SOLID,1,true,"");

   DrawTLine(ChartID(),0,"Avg-1",Time[CNT_Bar+1],Time[0],Stat_AVG+Stat_Variance,C'100,100,100',STYLE_DOT,1,true,"");
   DrawTLine(ChartID(),0,"Avg-2",Time[CNT_Bar+1],Time[0],Stat_AVG-Stat_Variance,C'100,100,100',STYLE_DOT,1,true,"");

//DrawTLine(ChartID(),0,"Max-0",Time[CNT_Bar+1],Time[0],iMA_Max,clrLime,STYLE_DOT,true,"");
//DrawTLine(ChartID(),0,"Max-1",Time[CNT_Bar+1],Time[0],iMA_Max+Stat_Variance,clrLime,STYLE_DOT,true,"");
//DrawTLine(ChartID(),0,"Max-2",Time[CNT_Bar+1],Time[0],iMA_Max-Stat_Variance,clrLime,STYLE_DOT,true,"");
//DrawRECTANGLE(ChartID(),0,"Max",Time[CNT_Bar],Time[0]+TimeBar,iMA_Max+Stat_Variance,iMA_Max,clrMidnightBlue,"");

//DrawTLine(ChartID(),0,"Min-0",Time[CNT_Bar+1],Time[0],iMA_Min,clrRed,STYLE_DOT,true,"");
//DrawTLine(ChartID(),0,"Min-1",Time[CNT_Bar+1],Time[0],iMA_Min+Stat_Variance,clrRed,STYLE_DOT,true,"");
//DrawTLine(ChartID(),0,"Min-2",Time[CNT_Bar+1],Time[0],iMA_Min-Stat_Variance,clrRed,STYLE_DOT,true,"");
//DrawRECTANGLE(ChartID(),0,"Min",Time[CNT_Bar],Time[0]+TimeBar,iMA_Min-Stat_Variance,iMA_Min,clrMidnightBlue,"");

//HLineCreate_(0,"iMA_Max","",0,iMA_Max,clrLime,4,0,false,false,false,0);
//HLineCreate_(0,"iMA_Min","",0,iMA_Min,clrRed,4,0,false,false,false,0);

//Comment(sms);
//Comment("");
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTLine(long chartID,int windex,string name,datetime d1,datetime d2,double var,color clr,ENUM_LINE_STYLE style,int width,bool ray_right,string str)
  {
   name=indy_name+name;
   if(ObjectFind(chartID,name))
     {
      ObjectCreate(chartID,name,OBJ_TREND,windex,d1,var,d1,var);
     }
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chartID,name,OBJPROP_WIDTH,width);
   ObjectMove(chartID,name,0,d1,var);
   ObjectMove(chartID,name,1,d2,var);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);

   ObjectSetInteger(chartID,name,OBJPROP_RAY_RIGHT,ray_right);

   if(str!="")
     {
      ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chartID,name,OBJPROP_TEXT,str);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRECTANGLE(long chartID,int windex,string name,datetime d1,datetime d2,double var,double var2,color clr,string str)
  {
   name=indy_name+name;
   if(var==var2)
     {
      ObjectDelete(chartID,name);
      DrawTLine(chartID,windex,name,d1,d2,var,clr,STYLE_SOLID,2,false,"");
     }
   else
     {
      ObjectDelete(chartID,name);
      ObjectCreate(chartID,name,OBJ_RECTANGLE,0,d1,var,d2,var2);
      ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
      ObjectMove(chartID,name,0,d1,var);
      ObjectMove(chartID,name,1,d2,var2);

      if(str!="")
        {
         ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
         ObjectSetString(chartID,name,OBJPROP_TEXT,str);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTooltip(string mode,double var,double var2)
  {
   if(var>var2)
     {
      return mode+": "+c(var2,Digits)+" - "+c(var,Digits);
     }
   else if(var<var2)
     {
      return mode+": "+c(var,Digits)+" - "+c(var2,Digits);
     }
   else
     {
      return mode+": "+c(var,Digits);
     }

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Mode_Med_var1=0,Mode_Med_var2=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Mode_Med(ENUM_TIMEFRAMES TF,int CNT_Bar,string Text,color clr1,color clr2)
  {
   double iMA_Max=-99999,iMA_Min=99999,iMA_D=-1;
//---
   for(int i=1;i<=CNT_Bar;i++)
     {
      iMA_=NormalizeDouble(iMA(Symbol(),TF,1,0,MODE_SMA,PRICE_CLOSE,i),Digits);
      if(iMA_Max<iMA_)iMA_Max=iMA_;
      if(iMA_Min>iMA_)iMA_Min=iMA_;
     }
//DrawTLine(ChartID(),0,"Max-0",Time[CNT_Bar+1],Time[0],iMA_Max,clrLime,STYLE_DOT,true,"");
//DrawTLine(ChartID(),0,"Min-0",Time[CNT_Bar+1],Time[0],iMA_Min,clrRed,STYLE_DOT,true,"");

   sms+="\nMax: "+c(iMA_Max,Digits)+" Min: "+c(iMA_Min,Digits);

   iMA_D=NormalizeDouble(iMA_Max-iMA_Min,Digits);
   sms+="\niMA_D: "+c(iMA_D/Point_,0)+"p";
   sms+="\n---------------------------------";

   double D[10][2]; ArrayFill(D,0,20,0);

   double Start=iMA_Max,End=-1,Step=NormalizeDouble(iMA_D/StepD,Digits);
   for(int i=1;i<10;i++)
     {
      End=Start-Step;
      D[i][0]=NormalizeDouble(Start,Digits);
      D[i][1]=NormalizeDouble(End,Digits);
      Start=End-Point_;
      //HLineCreate_(0,"iMA_D"+c(i),"",0,End,clrIndigo,4,0,false,false,false,0);
      //sms+="\n"+cFillZero(i+1,2)+"# "+c(D[i][0],Digits)+" - "+c(D[i][1],Digits);
     }
//---
   double F[10]; ArrayFill(F,0,10,0);

   double Max=-99;
   int index_Max=0;

   for(int i=1;i<CNT_Bar;i++)
     {
      iMA_=NormalizeDouble(iMA(Symbol(),TF,2,0,MODE_SMA,PRICE_WEIGHTED,i),Digits);
      for(int j=0;j<10;j++)
        {
         if(iMA_<=D[j][0] && iMA_>=D[j][1])
           {
            F[j]++;
           }
         //---
         if(F[j]>Max)
           {
            Max=F[j]; index_Max=j;
           }
        }
     }

   for(int i=0;i<10;i++)
     {
      if(F[i]>=0)
         sms+="\n"+cFillZero(i+1,2)+"# "+c(D[i][0],Digits)+" - "+c(D[i][1],Digits)+" : "+c(F[i],0);
      if(i==index_Max)
         sms+=" <---";

     }
   sms+="\n---------------------------------";

//---Calculator Mode
   double limeUp=D[index_Max][1];
   double DL,DU;
   if(index_Max==0)
     {
      DU=F[index_Max]-F[index_Max];
      DL=F[index_Max]-F[index_Max+1];
     }
   else if(index_Max==9)
     {
      DU=F[index_Max]-F[index_Max-1];
      DL=F[index_Max]-F[index_Max];
     }
   else
     {
      DU=F[index_Max]-F[index_Max-1];
      DL=F[index_Max]-F[index_Max+1];
     }

//sms+="\nlimeUp: "+c(limeUp,Digits);
   double DLDU=DL+DU;
   if(DLDU==0)DLDU=1;

   double Mode=NormalizeDouble(limeUp-(Step*(DL/(DLDU))),Digits);

   double Mode2=NormalizeDouble(limeUp+(Step*(DL/(DLDU))),Digits);

   sms+="\nMode ["+c(CNT_Bar)+"]: "+c(Mode,Digits);

//DrawTLine(ChartID(),0,indy_name+"nMode-01",Time[CNT_Bar],Time[0],Mode,clrYellow,STYLE_SOLID,"");
//DrawTLine(ChartID(),0,indy_name+"nMode-02",Time[CNT_Bar],Time[0],Mode2,clrYellow,STYLE_SOLID,"");

//---Calculator Med
   double n_Mode=(CNT_Bar+1)/2;
   if(MathMod(CNT_Bar,2)==0)
      n_Mode=CNT_Bar/2;

   double FL=0;
   for(int i=index_Max;i<10;i++)
      FL+=F[i];
//sms+="FL: "+c(FL,2)+"\n";

   double Med=limeUp-(Step*((n_Mode-FL)/F[index_Max]));
   Med=NormalizeDouble(Med,Digits);

   double Med2=limeUp+(Step*((n_Mode-FL)/F[index_Max]));
   Med2=NormalizeDouble(Med2,Digits);

   sms+="\nMed ["+c(CNT_Bar)+"]: "+c(Med,Digits);

   string tooltip="\n";
//tooltip="\nAvg: "+c(Stat_AVG,Digits)+"\n";
   tooltip+=getTooltip("Mode",Mode,Mode2)+"\n";
   tooltip+=getTooltip("Med",Med,Med2);

   double ModeMax=MathMax(Mode,Mode2);
   double MedMax=MathMax(Med,Med2);

   datetime TimeBar=time(0,0)-time(0,1);

   if(ModeMax>Med && ModeMax>Med2)
     {
      //Comment("A"+tooltip);
      DrawRECTANGLE(ChartID(),0,"Mode"+Text,time(TF,CNT_Bar),time(0,0)+TimeBar,Mode,Mode2,clr1,"");

      DrawRECTANGLE(ChartID(),0,"Med"+Text,time(TF,CNT_Bar),time(0,0)+TimeBar*2,Med,Med2,clr2,"");

      Mode_Med_var1=Mode;
      Mode_Med_var2=Mode2;
     }
   else if(MedMax>Mode && MedMax>Mode2)
     {
      //Comment("B"+tooltip);
      DrawRECTANGLE(ChartID(),0,"Med"+Text,time(TF,CNT_Bar),time(0,0)+TimeBar,Med,Med2,clr1,"");

      DrawRECTANGLE(ChartID(),0,"Mode"+Text,time(TF,CNT_Bar),time(0,0)+TimeBar*2,Mode,Mode2,clr2,"");

      Mode_Med_var1=Med;
      Mode_Med_var2=Med2;
     }
   else
     {
      //Comment("C"+tooltip);

      DrawRECTANGLE(ChartID(),0,"Mode"+Text,time(TF,CNT_Bar),time(0,0)+TimeBar,Mode,Mode2,clr1,"");
      DrawRECTANGLE(ChartID(),0,"Med"+Text,time(TF,CNT_Bar),time(0,0)+TimeBar,Med,Med2,clr2,"");

      Mode_Med_var1=Mode;
      Mode_Med_var2=Mode2;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime time(ENUM_TIMEFRAMES TF,int n)
  {
   return iTime(Symbol(),TF,n);
  }
//+------------------------------------------------------------------+
