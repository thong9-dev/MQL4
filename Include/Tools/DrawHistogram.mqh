//+------------------------------------------------------------------+
//|                                                DrawHistogram.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
void DrawHistogramV(string Symbol_,int TF,int FIRST_B,int VISIBLE_B,int WIDTH_B,double DrawFull,double Draw,string name,double Price,color clr,string tooltip)
  {
   string strTest="";
   ENUM_LINE_STYLE style=DRAW_LINE;
   int width=1;

   int Full=int(WIDTH_B*(DrawFull/100));
   int Percent=int(Full*(Draw/100));

   int Space_Bars=WIDTH_B-VISIBLE_B;
   int x_Darw=Space_Bars-Percent;

   strTest+="\n FIRST_B: "+c(FIRST_B);
   strTest+="\n VISIBLE_B: "+c(VISIBLE_B);
   strTest+="\n WIDTH_B: "+c(WIDTH_B);

   strTest+="\n ----------------";

   strTest+="\n Full: "+c(Full);
   strTest+="\n Percent: "+c(Percent);
   strTest+="\n Space_Bars: "+c(Space_Bars);

   strTest+="\n\n x_Darw: "+c(x_Darw);

   Price=NormalizeDouble(Price,Digits);

   if(x_Darw>=0)
     {
      strTest+="\nA";
      datetime d1=Time[0]+((Period()*60)*x_Darw),d2=d1+(Period()*60);
      DrawTLine(ChartID(),0,name,d1,d2,Price,clr,style,width,true,tooltip);
     }
   else if(x_Darw>Percent*-1)
     {
      strTest+="\nB";
      x_Darw=MathAbs(x_Darw)+1;
      DrawTLine(ChartID(),0,name,Time[x_Darw],Time[0],Price,clr,style,width,true,tooltip);
     }
   else
     {
      strTest+="\nC";
      int  x2=FIRST_B-(VISIBLE_B-Percent);
      DrawTLine(ChartID(),0,name,Time[x2],Time[0],Price,clr,style,width,true,tooltip);
     }
//Comment(strTest);
//Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTLine(long chartID,int windex,string name,datetime d1,datetime d2,double var,color clr,ENUM_LINE_STYLE style,int width,bool ray_right,string str)
  {
//name=indy_name+name;
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

   ObjectSetInteger(chartID,name,OBJPROP_BACK,true);

   ObjectSetInteger(chartID,name,OBJPROP_RAY_RIGHT,ray_right);

   if(str!="")
     {
      ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chartID,name,OBJPROP_TEXT,str);
     }
  }
//+------------------------------------------------------------------+
void DrawHistogramH(string Symbol_,int TF,int FIRST_B,int VISIBLE_B,int WIDTH_B,double DrawFull,double Draw,string name,double Price,color clr,string tooltip)
  {
   string strTest="";
   ENUM_LINE_STYLE style=DRAW_LINE;
   int width=1;

   int Full=int(WIDTH_B*(DrawFull/100));
   int Percent=int(Full*(Draw/100));

   int Space_Bars=WIDTH_B-VISIBLE_B;
   int x_Darw=Space_Bars-Percent;

   strTest+="\n FIRST_B: "+c(FIRST_B);
   strTest+="\n VISIBLE_B: "+c(VISIBLE_B);
   strTest+="\n WIDTH_B: "+c(WIDTH_B);

   strTest+="\n ----------------";

   strTest+="\n Full: "+c(Full);
   strTest+="\n Percent: "+c(Percent);
   strTest+="\n Space_Bars: "+c(Space_Bars);

   strTest+="\n\n x_Darw: "+c(x_Darw);

   Price=NormalizeDouble(Price,Digits);

   if(x_Darw>=0)
     {
      strTest+="\nA";
      datetime d1=Time[0]+((Period()*60)*x_Darw),d2=d1+(Period()*60);
      DrawTLineH(ChartID(),0,name,d1,d2,Price,clr,style,width,true,tooltip);
     }
   else if(x_Darw>Percent*-1)
     {
      strTest+="\nB";
      x_Darw=MathAbs(x_Darw)+1;
      DrawTLineH(ChartID(),0,name,Time[x_Darw],Time[0],Price,clr,style,width,true,tooltip);
     }
   else
     {
      strTest+="\nC";
      int  x2=FIRST_B-(VISIBLE_B-Percent);
      DrawTLineH(ChartID(),0,name,Time[x2],Time[0],Price,clr,style,width,true,tooltip);
     }
//Comment(strTest);
//Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTLineH(long chartID,int windex,string name,datetime d,double var1,double var2,color clr,int style,int width,bool ray_right,string str)
  {
//name=indy_name+name;
   if(ObjectFind(chartID,name))
     {
      ObjectCreate(chartID,name,OBJ_TREND,windex,d,var1,d,var2);
     }
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chartID,name,OBJPROP_WIDTH,width);
   ObjectMove(chartID,name,0,d,var1);
   ObjectMove(chartID,name,1,d,var2);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);

   ObjectSetInteger(chartID,name,OBJPROP_BACK,true);

   ObjectSetInteger(chartID,name,OBJPROP_RAY_RIGHT,ray_right);

   if(str!="")
     {
      ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chartID,name,OBJPROP_TEXT,str);
     }
  }
//+------------------------------------------------------------------+
