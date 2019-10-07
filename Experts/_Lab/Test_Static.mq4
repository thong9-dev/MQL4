//+------------------------------------------------------------------+
//|                                                  Test_Static.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
extern int CNT=24;
extern double StepD=10;
extern int Period_=14;//Period_RSI
extern ENUM_APPLIED_PRICE APPLIED_PRICE=PRICE_WEIGHTED;//APPLIED_PRICE 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   OnTick();
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
double iRSI_=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string sms="";
//---
   double Start=100,Step=StepD;
   int CNT_D=int(Start/Step);
   double D[1];
   ArrayResize(D,CNT_D+1,CNT_D+1);
//ArrayFill(D,0,CNT_D,0);
//Comment(ArraySize(D));
   for(int i=0;i<=CNT_D;i++)
     {
      D[i]=NormalizeDouble(Start,0);
      Start-=Step;
     }
//---
   double F[1];
   double Sum=0;
   ArrayResize(F,CNT_D,CNT_D);
//Print("---------------------------------");
   for(int i=0;i<CNT;i++)
     {
      iRSI_=iRSI(Symbol(),0,Period_,APPLIED_PRICE,i);
      Sum+=iRSI_;
      for(int j=0;j<CNT_D;j++)
        {
         if(iRSI_<=D[j] && iRSI_>=D[j]-(Step))
           {
            F[j]++;
            break;
           }
        }
     }
//---
   double Max=-99;
   int index_Max=-1;

   for(int i=0;i<CNT_D;i++)
     {
      if(F[i]>Max)
        {
         Max=F[i];
         index_Max=i;
        }
     }

   for(int i=0;i<CNT_D;i++)
     {
      if(F[i]>0)
         sms+="\n"+cFillZero(i+1,2)+"# "+cFillZero(D[i],2)+"-"+cFillZero(D[i]-(Step-1),2)+" : "+c(F[i],2);
      if(i==index_Max)
         sms+=" **";
     }

   sms+="\n\nindex_Max : "+c(index_Max+1)+" | "+c(D[index_Max],0)+" | "+c(F[index_Max],0)+"\n\n";

//---Calculator
   double limeUp=D[index_Max]-0.5;
//sms+="#LimeUp : "+c(limeUp,2)+"\n";
//sms+="#I : "+c(StepD,2)+"\n";
   double DL=F[index_Max]-F[index_Max+1];
//sms+="#DL : "+c(DL,2)+"\n";
   double DU=F[index_Max]-F[index_Max-1];
//sms+="#DU : "+c(DU,2)+"\n";
   double Mode=limeUp-(StepD*(DL/(DL+DU)));
   Mode=NormalizeDouble(Mode,2);
   sms+="Mode ["+c(CNT)+"]: "+c(Mode,2)+"\n";
//HLineCreate_(0,"Mode","",1,Mode,clrRed,0,0,true,false,false,0);

   double Mode2=limeUp+(StepD*(DL/(DL+DU)));
   Mode2=NormalizeDouble(Mode2,2);

//DrawTLine(ChartID(),1,"Mode",Time[CNT],Time[0],Mode,clrRed,STYLE_SOLID,"");
//DrawTLine(ChartID(),1,"Mode2",Time[CNT],Time[0],Mode2,clrRed,STYLE_DOT,"");


   sms+="-------------\n";

   double n_Mode=(CNT+1)/2;
   if(MathMod(CNT,2)==0)
      n_Mode=CNT/2;

   double FL=0;
   for(int i=index_Max+1;i<CNT_D;i++)
      FL+=F[i];
//sms+="FL: "+c(FL,2)+"\n";

   double Med=limeUp-(StepD*((n_Mode-FL)/F[index_Max]));
   Med=NormalizeDouble(Med,2);

   double Med2=limeUp+(StepD*((n_Mode-FL)/F[index_Max]));
   Med2=NormalizeDouble(Med2,2);

   sms+="Med: "+c(Med,2)+"\n";

//DrawTLine(ChartID(),1,"Med",Time[CNT],Time[CNT]*4,Med,clrYellow,STYLE_SOLID,"");
//DrawTLine(ChartID(),1,"Med2",Time[CNT],Time[CNT]*4,Med2,C'255,247,89',STYLE_DOT,"");
//---
   ObjectCreate(ChartID(),"Mode44",OBJ_RECTANGLE,1,Time[CNT],Mode,Time[0],Mode2);
   ObjectSetInteger(ChartID(),"Mode44",OBJPROP_COLOR,clrDarkSlateGray);
   ObjectMove(ChartID(),"Mode44",0,Time[CNT],Mode);
   ObjectMove(ChartID(),"Mode44",1,Time[0],Mode2);

   ObjectCreate(ChartID(),"Med44",OBJ_RECTANGLE,1,Time[CNT],Med,Time[0],Med2);
   ObjectSetInteger(ChartID(),"Med44",OBJPROP_COLOR,clrDarkGreen);
   ObjectMove(ChartID(),"Med44",0,Time[CNT],Med);
   ObjectMove(ChartID(),"Med44",1,Time[0],Med2);
//---
   Sum=0;
   for(int i=0;i<CNT/2;i++)
     {
      Sum+=iRSI(Symbol(),0,14,PRICE_CLOSE,i);
     }
   double Avg=Sum/(CNT/2);
   DrawTLine(ChartID(),1,"Avg",Time[CNT],Time[0],Avg,clrSteelBlue,STYLE_SOLID,"");

//-------
   double SumVariance=0;
   int Period_Start=-1;
   if(Period()>=PERIOD_H4)
     {

     }
   else
     {

     }

   for(int i=0;i<CNT;i++)
      SumVariance+=NormalizeDouble(MathPow(iRSI(Symbol(),0,Period_,APPLIED_PRICE,i)-Avg,2),2);
   SumVariance=NormalizeDouble(MathSqrt(SumVariance/(CNT-1)),2);
   //Comment("SD: "+c((SumVariance),2));
   DrawTLine(ChartID(),1,"AvgUP",Time[CNT+1],Time[0],Avg+SumVariance,clrSteelBlue,STYLE_DOT,"");
   DrawTLine(ChartID(),1,"AvgDW",Time[CNT+1],Time[0],Avg-SumVariance,clrSteelBlue,STYLE_DOT,"");

//-------

   iRSI_=iRSI(Symbol(),0,Period_,0,0);

   string tooltip="RIS("+c(Period_)+") "+c(iRSI_,2)+"\n";
   tooltip+="Avg: "+c(Avg,2)+"\n";
   tooltip+=getTooltip("Mode",Mode,Mode2)+"\n";
   tooltip+=getTooltip("Med",Med,Med2);

   HLineCreate_(0,"iRSI2",tooltip,1,iRSI_,clrGray,4,0,false,false,false,0);
   DrawTLine(ChartID(),1,"iRSI",Time[0],Time[CNT]*4,iRSI_,clrDodgerBlue,STYLE_SOLID,tooltip);

//---

//Comment(sms);

//Comment("");
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTooltip(string mode,double var,double var2)
  {
   if(var>var2)
     {
      return mode+": "+c(var2,2)+" - "+c(var,2);
     }
   else if(var<var2)
     {
      return mode+": "+c(var,2)+" - "+c(var2,2);
     }
   else
     {
      return mode+": "+c(var,2);
     }

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTLine(long chartID,int windex,string name,datetime d1,datetime d2,double var,color clr,ENUM_LINE_STYLE style,string str)
  {
   if(ObjectFind(chartID,name))
     {
      ObjectCreate(chartID,name,OBJ_TREND,windex,d1,var,d1,var);
     }
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_STYLE,style);
   ObjectMove(chartID,name,0,d1,var);
   ObjectMove(chartID,name,1,d2,var);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);

   if(str!="")
     {
      ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chartID,name,OBJPROP_TEXT,str);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTLine2(long chartID,int windex,string name,datetime d1,datetime d2,double var,color clr,ENUM_LINE_STYLE style,string str)
  {
   if(ObjectFind(chartID,name))
     {
      ObjectCreate(chartID,name,OBJ_TREND,windex,d1,var,d1,var);
     }
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_STYLE,style);
   ObjectMove(chartID,name,0,d1,var);
   ObjectMove(chartID,name,1,d2,var);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);

   if(str!="")
     {
      ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chartID,name,OBJPROP_TEXT,str);
     }
  }
//+------------------------------------------------------------------+
