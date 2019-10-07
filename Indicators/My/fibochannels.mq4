//+------------------------------------------------------------------+
//|                                                 FiboChannels.mq4 |
//|                                     Copyright 2016, Bola ButBut. |
//|                                   https://M2P_Design@Hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Bola ButBut."
#property link      "https://M2P_Design@Hotmail.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6

input   int period=162;
input   int indShift=0;
input   int LineWidth=1;
input color TextColor=clrBlack;
input color Fibonacci000=clrBlue;
input color Fibonacci236=clrMediumOrchid;
input color Fibonacci382=clrSeaGreen;
input color Fibonacci500=clrBlack;
input color Fibonacci618=clrRed;
input color Fibonacci100=clrSienna;

double Fibo53[]; //Fibonacci 0.0
double Fibo52[]; //Fibonacci 23.6
double Fibo51[]; //Fibonacci 38.2
double Fibo50[]; //Fibonacci 50.0
double Fibo49[]; //Fibonacci 61.8
double Fibo48[]; //Fibonacci 100.0

int MHB,MLS;
double body;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0,DRAW_LINE,0,LineWidth,Fibonacci000);
   SetIndexBuffer(0,Fibo53);
   SetIndexShift(0,indShift);
   SetIndexStyle(1,DRAW_LINE,0,LineWidth,Fibonacci236);
   SetIndexBuffer(1,Fibo52);
   SetIndexShift(1,indShift);
   SetIndexStyle(2,DRAW_LINE,0,LineWidth,Fibonacci382);
   SetIndexBuffer(2,Fibo51);
   SetIndexShift(2,indShift);
   SetIndexStyle(3,DRAW_LINE,0,LineWidth,Fibonacci500);
   SetIndexBuffer(3,Fibo50);
   SetIndexShift(3,indShift);
   SetIndexStyle(4,DRAW_LINE,0,LineWidth,Fibonacci618);
   SetIndexBuffer(4,Fibo49);
   SetIndexShift(4,indShift);
   SetIndexStyle(5,DRAW_LINE,0,LineWidth,Fibonacci100);
   SetIndexBuffer(5,Fibo48);
   SetIndexShift(5,indShift);

   fiboCret();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int r)
  {
   ObjectDelete("Fibonacci00.0");
   ObjectDelete("Fibonacci23.6");
   ObjectDelete("Fibonacci38.2");
   ObjectDelete("Fibonacci50.0");
   ObjectDelete("Fibonacci61.8");
   ObjectDelete("Fibonacci100");

   ObjectDelete("Fibo00.0");
   ObjectDelete("Fibo23.6");
   ObjectDelete("Fibo38.2");
   ObjectDelete("Fibo50.0");
   ObjectDelete("Fibo61.8");
   ObjectDelete("Fibo100.0");
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
   int limit=rates_total-prev_calculated;
//---- main loop
   for(int i=0; i<limit; i++)
     {
      MHB=iHighest(Symbol(),0,MODE_HIGH,period,i);
      MLS=iLowest(Symbol(),0,MODE_LOW,period,i);
      body=MathAbs(High[MHB]-Low[MLS]);
      if(Time[MHB]>Time[MLS])
        {
         Fibo53[i]=High[MHB];
         Fibo52[i]=High[MHB]-(body*23.6/100);
         Fibo51[i]=High[MHB]-(body*38.2/100);
         Fibo50[i]=High[MHB]-(body*50.0/100);
         Fibo49[i]=High[MHB]-(body*61.8/100);
         Fibo48[i]=Low[MLS];
        }
      else
        {
         Fibo53[i]=Low[MLS];
         Fibo52[i]=Low[MLS]+(body*23.6/100);
         Fibo51[i]=Low[MLS]+(body*38.2/100);
         Fibo50[i]=Low[MLS]+(body*50.0/100);
         Fibo49[i]=Low[MLS]+(body*61.8/100);
         Fibo48[i]=High[MHB];
        }
     }
   datetime timeS=TimeCurrent()+(Period()*60*indShift);
   fibolevels(timeS,Fibo53[0],Fibo52[0],Fibo51[0],Fibo50[0],Fibo49[0],Fibo48[0]);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Object Creation function                                         |
//+------------------------------------------------------------------+
void fiboCret()
  {
   ObjectCreate("Fibonacci00.0",OBJ_ARROW_RIGHT_PRICE,0,0,0);
   ObjectCreate("Fibonacci23.6",OBJ_ARROW_RIGHT_PRICE,0,0,0);
   ObjectCreate("Fibonacci38.2",OBJ_ARROW_RIGHT_PRICE,0,0,0);
   ObjectCreate("Fibonacci50.0",OBJ_ARROW_RIGHT_PRICE,0,0,0);
   ObjectCreate("Fibonacci61.8",OBJ_ARROW_RIGHT_PRICE,0,0,0);
   ObjectCreate("Fibonacci100",OBJ_ARROW_RIGHT_PRICE,0,0,0);

   ObjectCreate("Fibo00.0",OBJ_TEXT,0,0,0);
   ObjectSetText("Fibo00.0","Fibo00.0",10,"Arial",TextColor);
   ObjectCreate("Fibo23.6",OBJ_TEXT,0,0,0);
   ObjectSetText("Fibo23.6","Fibo23.6",10,"Arial",TextColor);
   ObjectCreate("Fibo38.2",OBJ_TEXT,0,0,0);
   ObjectSetText("Fibo38.2","Fibo38.2",10,"Arial",TextColor);
   ObjectCreate("Fibo50.0",OBJ_TEXT,0,0,0);
   ObjectSetText("Fibo50.0","Fibo50.0",10,"Arial",TextColor);
   ObjectCreate("Fibo61.8",OBJ_TEXT,0,0,0);
   ObjectSetText("Fibo61.8","Fibo61.8",10,"Arial",TextColor);
   ObjectCreate("Fibo100.0",OBJ_TEXT,0,0,0);
   ObjectSetText("Fibo100.0","Fibo100.0",10,"Arial",TextColor);
  }
//+------------------------------------------------------------------+
//| Object Modification function                                     |
//+------------------------------------------------------------------+
void fibolevels(datetime Fibot,double F53,double F52,double F51,double F50,double F49,double F48)
  {
   ObjectSet("Fibonacci00.0",OBJPROP_TIME1,Fibot);
   ObjectSet("Fibonacci00.0",OBJPROP_PRICE1,F53);
   ObjectSet("Fibonacci00.0",OBJPROP_COLOR,Fibonacci000);
   ObjectSet("Fibonacci23.6",OBJPROP_TIME1,Fibot);
   ObjectSet("Fibonacci23.6",OBJPROP_PRICE1,F52);
   ObjectSet("Fibonacci23.6",OBJPROP_COLOR,Fibonacci236);
   ObjectSet("Fibonacci38.2",OBJPROP_TIME1,Fibot);
   ObjectSet("Fibonacci38.2",OBJPROP_PRICE1,F51);
   ObjectSet("Fibonacci38.2",OBJPROP_COLOR,Fibonacci382);
   ObjectSet("Fibonacci50.0",OBJPROP_TIME1,Fibot);
   ObjectSet("Fibonacci50.0",OBJPROP_PRICE1,F50);
   ObjectSet("Fibonacci50.0",OBJPROP_COLOR,Fibonacci500);
   ObjectSet("Fibonacci61.8",OBJPROP_TIME1,Fibot);
   ObjectSet("Fibonacci61.8",OBJPROP_PRICE1,F49);
   ObjectSet("Fibonacci61.8",OBJPROP_COLOR,Fibonacci618);
   ObjectSet("Fibonacci100",OBJPROP_TIME1,Fibot);
   ObjectSet("Fibonacci100",OBJPROP_PRICE1,F48);
   ObjectSet("Fibonacci100",OBJPROP_COLOR,Fibonacci100);

   ObjectSet("Fibo00.0",OBJPROP_TIME1,Fibot+(Period()*2500));
   ObjectSet("Fibo00.0",OBJPROP_PRICE1,F53);
   ObjectSet("Fibo23.6",OBJPROP_TIME1,Fibot+(Period()*2500));
   ObjectSet("Fibo23.6",OBJPROP_PRICE1,F52);
   ObjectSet("Fibo38.2",OBJPROP_TIME1,Fibot+(Period()*2500));
   ObjectSet("Fibo38.2",OBJPROP_PRICE1,F51);
   ObjectSet("Fibo50.0",OBJPROP_TIME1,Fibot+(Period()*2500));
   ObjectSet("Fibo50.0",OBJPROP_PRICE1,F50);
   ObjectSet("Fibo61.8",OBJPROP_TIME1,Fibot+(Period()*2500));
   ObjectSet("Fibo61.8",OBJPROP_PRICE1,F49);
   ObjectSet("Fibo100.0",OBJPROP_TIME1,Fibot+(Period()*2500));
   ObjectSet("Fibo100.0",OBJPROP_PRICE1,F48);
  }
//+------------------------------------------------------------------+
