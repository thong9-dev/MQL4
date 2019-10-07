//+------------------------------------------------------------------+
//|                                        Heiken Ashi ZoneTrade.mq4 |
//|                                                           Duke3D |
//|                                             duke3datomic@mail.ru |
//|                                            Modify by Walter Choy |
//+------------------------------------------------------------------+
#property copyright "Duke3D (Modify by Walter Choy)"
#property link      "duke3datomic@mail.ru"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 RoyalBlue
#property indicator_color2 Red
#property indicator_color3 Gray
#property indicator_color4 Gray
#property indicator_color5 RoyalBlue
#property indicator_color6 Red
#property indicator_color7 Gray
#property indicator_color8 Gray

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1

extern color BlueZone=RoyalBlue;          // ???? ???????? ????
extern color RedZone          = Red;            // ???? ??????? ????
extern color GreyZone         = Gray;           // ???? ????? ????

double AC_0;
double AC_1;
double AO_0;
double AO_1;

string name;

extern int BodyWidth          = 3;              // ?????? ???? ?????
extern int ShadowWidth        = 1;              // ?????? ???? ?????

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//----

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,0,BodyWidth,BlueZone);
   SetIndexBuffer(0,ExtMapBuffer1);

   SetIndexStyle(1,DRAW_HISTOGRAM,0,BodyWidth,RedZone);
   SetIndexBuffer(1,ExtMapBuffer2);

   SetIndexStyle(2,DRAW_HISTOGRAM,0,BodyWidth,GreyZone);
   SetIndexBuffer(2,ExtMapBuffer3);

   SetIndexStyle(3,DRAW_HISTOGRAM,0,BodyWidth,GreyZone);
   SetIndexBuffer(3,ExtMapBuffer4);

   SetIndexStyle(4,DRAW_HISTOGRAM,0,ShadowWidth,BlueZone);
   SetIndexStyle(4,DRAW_HISTOGRAM);

   SetIndexBuffer(4,ExtMapBuffer5);

   SetIndexStyle(5,DRAW_HISTOGRAM,0,ShadowWidth,RedZone);
   SetIndexBuffer(5,ExtMapBuffer6);

   SetIndexStyle(6,DRAW_HISTOGRAM,0,ShadowWidth,GreyZone);
   SetIndexBuffer(6,ExtMapBuffer7);

   SetIndexStyle(7,DRAW_HISTOGRAM,0,ShadowWidth,GreyZone);
   SetIndexBuffer(7,ExtMapBuffer8);

   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexEmptyValue(3, 0.0);
   SetIndexEmptyValue(4, 0.0);
   SetIndexEmptyValue(5, 0.0);
   SetIndexEmptyValue(6, 0.0);
   SetIndexEmptyValue(7, 0.0);

   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
   SetIndexDrawBegin(4,10);
   SetIndexDrawBegin(5,10);
   SetIndexDrawBegin(6,10);
   SetIndexDrawBegin(7,10);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int i,limit;
   double ZTOpen,ZTHigh,ZTLow,ZTClose;

   if(counted_bars>0) counted_bars--;
   i=Bars-counted_bars-1;

   while(i>=0)
     {
      ZTOpen=(ExtMapBuffer1[i+1]+ExtMapBuffer2[i+1]+ExtMapBuffer3[i+1]+ExtMapBuffer4[i+1])/2;
      ZTClose=(Open[i]+High[i]+Low[i]+Close[i])/4;
      ZTHigh=MathMax(High[i],MathMax(ZTOpen,ZTClose));
      ZTLow=MathMin(Low[i],MathMin(ZTOpen,ZTClose));
      //===================================================================================================================      
      if(IndAC(i)==1 && IndAO(i)==1) // ??????? ???? 
        {
         if(ZTOpen>ZTClose) // bear
           {
            ExtMapBuffer1[i] = ZTOpen;
            ExtMapBuffer2[i] = ZTClose;
           }
         if(ZTOpen<ZTClose) // bull
           {
            ExtMapBuffer1[i] = ZTClose;
            ExtMapBuffer2[i] = ZTOpen;
           }

         ExtMapBuffer5[i] = ZTHigh;
         ExtMapBuffer6[i] = ZTLow;

         ExtMapBuffer3[i] = 0.0;
         ExtMapBuffer4[i] = 0.0;
         ExtMapBuffer7[i] = 0.0;
         ExtMapBuffer8[i] = 0.0;
        }
      //===================================================================================================================  
      if(IndAC(i)==2 && IndAO(i)==2) // ??????? ???? 
        {
         if(ZTOpen>ZTClose) // bear
           {
            ExtMapBuffer1[i] = ZTClose;
            ExtMapBuffer2[i] = ZTOpen;
           }
         if(ZTOpen<ZTClose) // bull
           {
            ExtMapBuffer1[i] = ZTOpen;
            ExtMapBuffer2[i] = ZTClose;
           }
         ExtMapBuffer5[i] = ZTLow;
         ExtMapBuffer6[i] = ZTHigh;

         ExtMapBuffer3[i] = 0.0;
         ExtMapBuffer4[i] = 0.0;
         ExtMapBuffer7[i] = 0.0;
         ExtMapBuffer8[i] = 0.0;
        }
      //===================================================================================================================
      if(IndAC(i)==1 && IndAO(i)==2) // ????? ????
        {
         if(ZTOpen>ZTClose) // bear
           {
            ExtMapBuffer3[i] = ZTOpen;
            ExtMapBuffer4[i] = ZTClose;
           }
         if(ZTOpen<ZTClose) // bull
           {
            ExtMapBuffer3[i] = ZTClose;
            ExtMapBuffer4[i] = ZTOpen;
           }
         ExtMapBuffer7[i] = ZTHigh;
         ExtMapBuffer8[i] = ZTLow;

         ExtMapBuffer1[i] = 0.0;
         ExtMapBuffer2[i] = 0.0;
         ExtMapBuffer5[i] = 0.0;
         ExtMapBuffer6[i] = 0.0;
        }
      //===================================================================================================================
      if(IndAC(i)==2 && IndAO(i)==1) // ????? ????
        {
         if(ZTOpen>ZTClose) // bear
           {
            ExtMapBuffer3[i] = ZTClose;
            ExtMapBuffer4[i] = ZTOpen;
           }
         if(ZTOpen<ZTClose) // bull
           {
            ExtMapBuffer3[i] = ZTOpen;
            ExtMapBuffer4[i] = ZTClose;
           }
         ExtMapBuffer7[i] = ZTLow;
         ExtMapBuffer8[i] = ZTHigh;

         ExtMapBuffer1[i] = 0.0;
         ExtMapBuffer2[i] = 0.0;
         ExtMapBuffer5[i] = 0.0;
         ExtMapBuffer6[i] = 0.0;
        }
      i--;
     }
//===================================================================================================================     
   return(0);
  }
//===================================================================================================================     
int IndAC(int Shift)
  {
   int DirectionAC=1;
   AC_0 = iAC(Symbol(),0,Shift);
   AC_1 = iAC(Symbol(),0,Shift+1);
   if(AC_0>AC_1) {DirectionAC = 1;}               // ??????? ???
   if(AC_0<AC_1) {DirectionAC = 2;}               // ??????? ???
   return(DirectionAC);
  }
//===================================================================================================================     
int IndAO(int Shift)
  {
   int DirectionAO=1;
   AO_0 = iAO(Symbol(),0,Shift);
   AO_1 = iAO(Symbol(),0,Shift+1);
   if(AO_0>AO_1) {DirectionAO = 1;}               // ??????? ???
   if(AO_0<AO_1) {DirectionAO = 2;}               // ??????? ???
   return(DirectionAO);
  }
//===================================================================================================================
