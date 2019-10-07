//+------------------------------------------------------------------+
//|                                                Test_Colordim.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <Tools/Method_Tools.mqh>
string ExtName_OBJ="Colordim ";
long BG=1315860;
long BG_Step=657930;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(ChartID(),ExtName_OBJ,0,OBJ_BUTTON);

   int Size_Wide=70;
   int Size_High=17;

   int PostX=10,XStep=Size_Wide+5;
   int PostY=20,YStep=Size_High+5;
   _setBUTTON(ExtName_OBJ+"DW",0,CORNER_LEFT_LOWER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRed,"DW");PostY+=YStep;
   _setBUTTON(ExtName_OBJ+"UP",0,CORNER_LEFT_LOWER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrLime,"UP");PostY+=YStep;

   string CMM;
//--- indicator buffers mapping
   long  _COLOR_BACKGROUND=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   CMM+=_COLOR_BACKGROUND;
//---
   Comment(CMM);
   printf(CMM+" | "+ColorToString(_COLOR_BACKGROUND));
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

//--- return value of prev_calculated for next call
   return(rates_total);
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
   string NameBTN;
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      NameBTN=ExtName_OBJ+"UP";
      if(sparam==NameBTN)
        {
         long  _BG=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
         _BG+=BG_Step;
         if(_BG>=16777215)
           {
            _BG=16777215;
           }
         ChartSetInteger(0,CHART_COLOR_BACKGROUND,0,_BG);
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      NameBTN=ExtName_OBJ+"DW";
      if(sparam==NameBTN)
        {
         long  _BG=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
         _BG-=BG_Step;
         if(_BG<=0)
           {
            _BG=0;
           }

         ChartSetInteger(0,CHART_COLOR_BACKGROUND,0,_BG);
        }
     }
  }
//+------------------------------------------------------------------+
