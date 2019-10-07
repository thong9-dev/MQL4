//+------------------------------------------------------------------+
//|                                                       ZigZag.mq4 |
//|                   Copyright 2006-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, www.fxhanuman.com : Review Forex Broker "
#property link      "http://www.fxhanuman.com/"
#property strict

#property indicator_chart_window
#property indicator_buffers 14

#property indicator_color1  clrYellow

#property indicator_color3  clrRed
#property indicator_color5  clrNONE
#property indicator_color7  clrNONE

#property indicator_color2  clrDodgerBlue
#property indicator_color4  clrNONE
#property indicator_color6  clrNONE

#property indicator_color7  clrNONE
#property indicator_color8  clrNONE
#property indicator_color9  clrNONE
#property indicator_color10  clrNONE
#property indicator_color11  clrNONE
#property indicator_color12  clrNONE
#property indicator_color13  clrNONE
#property indicator_color14  clrNONE
//#property indicator_color8  clrRed
//#property indicator_color9  clrLime
//#property indicator_color10  clrBlue
//#property indicator_color11 clrRed
//#property indicator_color12  clrLime

//#property indicator_width2  1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eStautLine
  {
   Main=0,
   Sec=1
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eMODE_CALLCANDLE
  {
   M_CALLCANDLE_OC=0,//Open,Close
   M_CALLCANDLE_HL=1//High,Low
  };
//---- indicator parameters
input int               InpDepthPrime=12;                   // Depth
double            InpBackstepRate=85;                 // MarkRate
input eStautLine        StautLine       =Main;
input eMODE_CALLCANDLE  MODE_CALLCANDLE =M_CALLCANDLE_OC;   //Applied Price
input bool              ShowTrendline=false;                //Show Trendline
input string            S="---------------------------------------------";
input bool              ShowZone=false;                     //Show Zone
input int               ZoneLess=500;
input color             clrZone=clrGray;
input ENUM_LINE_STYLE   styZone=STYLE_DOT;

int            InpDepth=InpDepthPrime/2;
int            InpBackstep=3;   // Backstep

int      InpDeviation=10;  // Deviation

//---- indicator buffers
double ExtZigzag_Prime[];//0

double ExtUPSgnal_Prime[];//1
double ExtDWSgnal_Prime[];//2

double ExtDWSgnal_Sec[];//3
double ExtUPSgnal_Sec[];//4

double ExtDWSgnal_Rest[];//5
double ExtUPSgnal_Rest[];//6

double Universe[];
double Earth[];
double High_Slope[];
double High_Price[];
double High_Date[];

double Low_Slope[];
double Low_Price[];
double Low_Date[];
//---
double ExtDWdump_Prime2[];
double ExtUPdump_Prime2[];
//---
double ExtZigzag_Sec[];
double ExtDWdump_Sec2[];
double ExtUPdump_Sec2[];
//--- globals
int    ExtLevel=3; // recounting's depth of extremums
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ChartRedraw(0);
   InpBackstep=int(double(InpDepthPrime)*((100-InpBackstepRate)/100));
   if(InpBackstep>=InpDepthPrime)
     {
      //Print("Backstep cannot be greater or equal to Depth");
      //return(INIT_FAILED);
      InpBackstep=InpDepthPrime-1;
     }
//--- 2 additional buffers
   IndicatorBuffers(20);
//---- indicator buffers
   SetIndexBuffer(0,ExtZigzag_Prime);
//---
   SetIndexBuffer(1,ExtUPSgnal_Prime);
   SetIndexBuffer(2,ExtDWSgnal_Prime);

   SetIndexBuffer(3,ExtUPSgnal_Sec);
   SetIndexBuffer(4,ExtDWSgnal_Sec);

   SetIndexBuffer(5,ExtUPSgnal_Rest);
   SetIndexBuffer(6,ExtDWSgnal_Rest);
//---Ver2

   SetIndexBuffer(7,Universe);
   SetIndexBuffer(8,Earth);

   SetIndexBuffer(9,High_Slope);
   SetIndexBuffer(10,High_Price);
   SetIndexBuffer(11,High_Date);

   SetIndexBuffer(12,Low_Slope);
   SetIndexBuffer(13,Low_Price);
   SetIndexBuffer(14,Low_Date);
//---#ver2
   SetIndexBuffer(15,ExtDWdump_Prime2);
   SetIndexBuffer(16,ExtUPdump_Prime2);
//---
   SetIndexBuffer(17,ExtZigzag_Sec);
//   
   SetIndexBuffer(18,ExtDWdump_Sec2);
   SetIndexBuffer(19,ExtUPdump_Sec2);
//---
   SetIndexEmptyValue(0,0.0);
//---- indicator short name
   IndicatorShortName("ZigZag("+string(InpDepthPrime)+","+string(int((MODE_CALLCANDLE)))+","+string(InpBackstepRate)+"%)");
//---- drawing settings
   string name="Z-("+string(InpDepthPrime)+")";

   SetIndexLabel(1,name+"1PrimeUP");
   SetIndexLabel(2,name+"2PrimeDW");
   SetIndexLabel(3,name+"3SecUP");
   SetIndexLabel(4,name+"4SecDW");
   SetIndexLabel(5,name+"5RestUP");
   SetIndexLabel(6,name+"6RestDW");
//---
   SetIndexLabel(7,name+"7Universe");
   SetIndexLabel(8,name+"8Earth");
   SetIndexLabel(9,name+"9High_Slope");
   SetIndexLabel(10,name+"10High_Price");
   SetIndexLabel(11,name+"11High_Date");
   SetIndexLabel(12,name+"12Low_Slope");
   SetIndexLabel(13,name+"13Low_Price");
   SetIndexLabel(14,name+"14Low_Date");
//---
   SetIndexLabel(15,name+"15ExtDWdump_Prime2");
   SetIndexLabel(16,name+"16ExtUPdump_Prime2");

   name="Z-("+string(InpDepthPrime/2)+")";
   SetIndexLabel(17,name+"17ExtZigzag_Sec");

   SetIndexLabel(18,name+"18ExtDWdump_Sec2");
   SetIndexLabel(19,name+"19ExtUPdump_Sec2");

   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexStyle(4,DRAW_ARROW);

   SetIndexStyle(5,DRAW_ARROW);
   SetIndexStyle(6,DRAW_ARROW);

   SetIndexStyle(7,DRAW_ARROW);
   SetIndexStyle(8,DRAW_ARROW);
   SetIndexStyle(10,DRAW_ARROW);
   SetIndexStyle(11,DRAW_ARROW);

   switch(StautLine)
     {
      case  Main:
         SetIndexStyle(0,DRAW_SECTION);

         SetIndexArrow(1,233);
         SetIndexArrow(2,234);
         SetIndexArrow(3,228);
         SetIndexArrow(4,230);
         SetIndexArrow(5,159);
         SetIndexArrow(6,159);

         SetIndexArrow(7,159);
         SetIndexArrow(8,159);
         SetIndexStyle(9,DRAW_SECTION,EMPTY,EMPTY,clrNONE);
         SetIndexArrow(10,159);
         SetIndexArrow(11,159);
         break;
      case  Sec:
         SetIndexStyle(0,DRAW_SECTION,EMPTY,EMPTY,clrNONE);
         SetIndexArrow(1,159);
         SetIndexArrow(2,159);
         SetIndexArrow(3,159);
         SetIndexArrow(4,159);
         SetIndexArrow(5,159);
         SetIndexArrow(6,159);

         SetIndexArrow(7,159);
         SetIndexArrow(8,159);
         SetIndexStyle(9,DRAW_SECTION,EMPTY,EMPTY,clrNONE);
         SetIndexArrow(10,159);
         SetIndexArrow(11,159);
         break;
      default:
         break;
     }

//---- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CMM="";
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
   CMM="";
//---

   Skyfalls_Prime(rates_total,prev_calculated,open,high,low,close);
   Skyfalls_Sec(rates_total,prev_calculated,open,high,low,close);
     {

      for(int i=1;i<Bars;i++)
        {
           {
            if(ExtUPdump_Prime2[i]>0)
              {
               if(ExtZigzag_Prime[i]>0)
                 {
                  ExtUPSgnal_Prime[i]=ExtUPdump_Prime2[i];
                 }
               else
                 {
                  ExtUPSgnal_Sec[i]=ExtUPdump_Prime2[i];
                 }
              }
            else
              {
               if(ExtUPdump_Sec2[i]>0)
                 {
                  if(ExtZigzag_Sec[i]>0)
                     ExtUPSgnal_Sec[i]=ExtUPdump_Sec2[i];
                  else  ExtUPSgnal_Rest[i]=ExtUPdump_Sec2[i];
                 }
              }
           }
           {
            if(ExtDWdump_Prime2[i]>0)
              {
               if(ExtZigzag_Prime[i]>0)
                  ExtDWSgnal_Prime[i]=ExtDWdump_Prime2[i];
               else  ExtDWSgnal_Sec[i]=ExtDWdump_Prime2[i];
              }
            else
              {
               if(ExtDWdump_Sec2[i]>0)
                 {
                  if(ExtZigzag_Sec[i]>0)
                     ExtDWSgnal_Sec[i]=ExtDWdump_Sec2[i];
                  else
                     ExtDWSgnal_Rest[i]=ExtDWdump_Sec2[i];
                 }
              }
           }

        }
     }
//---
     {
      int High_=0,_Set=4;
      int Low_=0;
      int StarEarth=0;
      for(int i=0;i<Bars;i++)
        {
         double StarVar=e(ExtZigzag_Prime[i]);
         if(StarVar>0)
           {
            double UP=e(ExtDWSgnal_Prime[i]);
            double DW=e(ExtUPSgnal_Prime[i]);

            if(StarEarth<1)
              {
               CMM+="\n"+"UP 0: "+e(UP,Digits);
               CMM+="\n"+"DW 0: "+e(DW,Digits);

               if(UP>0) Earth[0]=OP_SELL;
               else if(DW>0) Earth[0]=OP_BUY;
               else Earth[0]=-1;
               CMM+="\n"+"Earth: "+string(Earth[0]);
               StarEarth++;
              }
            //              
            if(UP>0 && High_<_Set)
              {
               High_Price[High_]=UP;
               High_Date[High_]=i;//double(iTime(Symbol(),Period(),i));
/* HLineCreate(0,"PolarisH"+High_,"",0,UP,
                           clrRed,2,1,false,true,false,false,0);
               VLineCreate(0,"PolarisV"+High_,0,iTime(Symbol(),Period(),i),
                           clrRed,2,1,false,false,false,false,0);*/
               High_++;
              }
            if(DW>0 && Low_<_Set)
              {
               Low_Price[Low_]=DW;
               Low_Date[Low_]=i;//double(iTime(Symbol(),Period(),i));
/* HLineCreate(0,"LionH"+StarLion,"",0,DW,
                           clrDodgerBlue,2,1,false,true,false,false,0);
               VLineCreate(0,"LionV"+Low_,0,iTime(Symbol(),Period(),i),
                           clrDodgerBlue,2,1,false,false,false,false,0);*/
               Low_++;
              }
            if(High_==_Set && Low_==_Set)
              {
               break;
              }
            //              
           }
        }
      //---
      double x=1;
      if(High_Price[0]-High_Price[1]<0)
         x=-1;
      High_Price[_Set]=MathMax(High_Price[0],High_Price[1])*x;
      x=1;
      if(Low_Price[0]-Low_Price[1]<0)
         x=-1;
      Low_Price[_Set]=MathMax(Low_Price[0],Low_Price[1])*x;
      //---
      for(int i=0;i<_Set-1;i++)
        {
         int X1,Y1,X2,Y2;
         ChartTimePriceToXY(0,0,iTime(Symbol(),Period(),int(High_Date[i+1])),High_Price[i+1],X1,Y1);
         ChartTimePriceToXY(0,0,iTime(Symbol(),Period(),int(High_Date[i])),High_Price[i],X2,Y2);
         double X=X2-X1,Y=Y1-Y2;
         double ceta=0;
         if(X>0)
           {
            ceta=Y/X;
           }

/*if(X!=0)
            ceta=NormalizeDouble(MathArctan(Y/X)*(180/M_PI),2);
         else
           {
            ceta=90; if(Y<0) ceta=-90;
           }*/
         High_Slope[i]=ceta;
         //---
         ChartTimePriceToXY(0,0,iTime(Symbol(),Period(),int(Low_Date[i+1])),Low_Price[i+1],X1,Y1);
         ChartTimePriceToXY(0,0,iTime(Symbol(),Period(),int(Low_Date[i])),Low_Price[i],X2,Y2);
         X=X2-X1;
         Y=Y1-Y2;
         if(X>0)
           {
            ceta=Y/X;
           }
/*ceta=0;
         if(X!=0)
            ceta=NormalizeDouble(MathArctan(Y/X)*(180/M_PI),2);
         else
           {
            ceta=90; if(Y<0) ceta=-90;
           }*/
         Low_Slope[i]=ceta;
         //---
        }
      if(High_Price[_Set]>0 && Low_Price[_Set]>0)       Universe[0]=OP_BUY;
      else  if(High_Price[_Set]<0 && Low_Price[_Set]<0) Universe[0]=OP_SELL;
      else  Universe[0]=-1;
      //---
      //+------------------------------------------------------------------+
      //|---- GUI                                                                  |
      //+------------------------------------------------------------------+
      if(ShowTrendline)
        {
         for(int i=0;i<_Set-1;i++)
           {
            TrendCreate(0,"TrendUP"+string(i),0,
                        iTime(Symbol(),Period(),int(High_Date[i])),High_Price[i],
                        iTime(Symbol(),Period(),int(High_Date[i+1])),High_Price[i+1],
                        clrRed,0,1,false,false,false,true,0);
           }
         for(int i=0;i<_Set-1;i++)
           {
            TrendCreate(0,"TrendDW"+string(i),0,
                        iTime(Symbol(),Period(),int(Low_Date[i])),Low_Price[i],
                        iTime(Symbol(),Period(),int(Low_Date[i+1])),Low_Price[i+1],
                        clrDodgerBlue,0,1,false,false,false,true,0);
           }
        }
      else
        {
         ObjectsDeleteAll(0,"TrendDW",0,OBJ_TREND);
         ObjectsDeleteAll(0,"TrendUP",0,OBJ_TREND);
        }
     }
     {
      ObjectsDeleteAll(0,"ZZZ",0,OBJ_HLINE);
      if(ShowZone)
        {
         getZone();
         for(int i=0;i<MarkCNT;i++)
           {

            HLineCreate(0,"ZZZ"+string(i),"",0,DUMP_Mark[i],clrZone,styZone,1,true,false,false,true,0);
           }
        }
     }
   if(ShowTrendline && false)
     {

      CMM+="\n"+"Zigzag 0: "+e(ExtZigzag_Prime[0],Digits);
      CMM+="\n"+"UP Pr 1: "+e(ExtUPSgnal_Prime[0],Digits);
      CMM+="\n"+"DW Pr 2: "+e(ExtDWSgnal_Prime[0],Digits);
      CMM+="\n"+"UP Se 3: "+e(ExtUPSgnal_Sec[0],Digits);
      CMM+="\n"+"UP Se 4: "+e(ExtDWSgnal_Sec[0],Digits);
      CMM+="\n"+"UP Re 5: "+e(ExtUPSgnal_Rest[0],Digits);
      CMM+="\n"+"UP Re 6: "+e(ExtDWSgnal_Rest[0],Digits);
      CMM+="\n";
      CMM+="\n"+"7: "+e(ExtDWdump_Prime2[0],Digits);
      CMM+="\n"+"8: "+e(ExtUPdump_Prime2[0],Digits);
      CMM+="\n"+"9: "+e(ExtZigzag_Sec[0],Digits);
      CMM+="\n"+"10: "+e(ExtDWdump_Sec2[0],Digits);
      CMM+="\n"+"11: "+e(ExtUPdump_Sec2[0],Digits);
      //   
      Comment(CMM);
     }
//---

//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll_Prime()
  {
   ArrayInitialize(ExtZigzag_Prime,0.0);
   ArrayInitialize(ExtDWdump_Prime2,0.0);
   ArrayInitialize(ExtUPdump_Prime2,0.0);
//--- first counting position
   return(Bars-InpDepthPrime);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Skyfalls_Prime(const int rates_total,
                   const int prev_calculated,
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[])
  {

   int    i,limit,counterZ,whatlookfor=0;
   int    back,pos,lasthighpos=0,lastlowpos=0;
   double extremum=EMPTY_VALUE;
   double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;
//--- check for history and inputs
   if(rates_total<InpDepthPrime || InpBackstep>=InpDepthPrime)
      return(0);
//--- first calculations
   if(prev_calculated==0)
      limit=InitializeAll_Prime();
   else
     {
      //--- find first extremum in the depth ExtLevel or 100 last bars
      i=counterZ=0;
      while(counterZ<ExtLevel && i<100)
        {
         if(ExtZigzag_Prime[i]!=0.0)
            counterZ++;
         i++;
        }
      //--- no extremum found - recounting all from begin
      if(counterZ==0)
         limit=InitializeAll_Prime();
      else
        {
         //--- set start position to found extremum position
         limit=i-1;
         //--- what kind of extremum?
         if(ExtUPdump_Prime2[i]!=0.0)
           {
            //--- low extremum
            curlow=ExtUPdump_Prime2[i];
            //--- will look for the next high extremum
            whatlookfor=1;
           }
         else
           {
            //--- high extremum
            curhigh=ExtDWdump_Prime2[i];
            //--- will look for the next low extremum
            whatlookfor=-1;
           }
         //--- clear the rest data
         for(i=limit-1; i>=0; i--)
           {
            ExtZigzag_Prime[i]=0.0;
            ExtUPdump_Prime2[i]=0.0;
            ExtDWdump_Prime2[i]=0.0;
           }
        }
     }
//+------------------------------------------------------------------+
//--- main loop      
//+------------------------------------------------------------------+
   for(i=limit; i>=0; i--)
     {
      //--- find lowest low in depth of bars
      if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
         extremum=low[iLowest(NULL,0,MODE_LOW,InpDepthPrime,i)];
      if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
         extremum=low[iLowest(NULL,0,MODE_CLOSE,InpDepthPrime,i)];
      //--- this lowest has been found previously
      if(extremum==lastlow)
         extremum=0.0;
      else
        {
         //--- new last low
         lastlow=extremum;
         //--- discard extremum if current low is too high
         if(low[i]-extremum>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtUPdump_Prime2[pos]!=0 && ExtUPdump_Prime2[pos]>extremum)
                  ExtUPdump_Prime2[pos]=0.0;
              }
           }
        }
      //--- found extremum is current low
      if(low[i]==extremum)
         ExtUPdump_Prime2[i]=extremum;
      else
         ExtUPdump_Prime2[i]=0.0;
      //--- find highest high in depth of bars
      if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
         extremum=high[iHighest(NULL,0,MODE_HIGH,InpDepthPrime,i)];
      if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
         extremum=high[iHighest(NULL,0,MODE_CLOSE,InpDepthPrime,i)];
      //--- this highest has been found previously
      if(extremum==lasthigh)
         extremum=0.0;
      else
        {
         //--- new last high
         lasthigh=extremum;
         //--- discard extremum if current high is too low
         if(extremum-high[i]>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtDWdump_Prime2[pos]!=0 && ExtDWdump_Prime2[pos]<extremum)
                  ExtDWdump_Prime2[pos]=0.0;
              }
           }
        }
      //--- found extremum is current high
      if(high[i]==extremum)
         ExtDWdump_Prime2[i]=extremum;
      else
         ExtDWdump_Prime2[i]=0.0;
     }
//+------------------------------------------------------------------+
//--- final cutting 
//+------------------------------------------------------------------+
   if(whatlookfor==0)
     {
      lastlow=0.0;
      lasthigh=0.0;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
//---
   for(i=limit; i>=0; i--)
     {
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if(lastlow==0.0 && lasthigh==0.0)
              {
               if(ExtDWdump_Prime2[i]!=0.0)
                 {
                  //---
                  if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
                     lasthigh=High[i];
                  if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
                    {
                     if(Open[i]>Close[i])
                        lastlow=Open[i];
                     else
                        lastlow=Close[i];
                    }
                  //---
                  lasthighpos=i;
                  whatlookfor=-1;
                  ExtZigzag_Prime[i]=lasthigh;
                 }
               if(ExtUPdump_Prime2[i]!=0.0)
                 {
                  //---
                  if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
                     lastlow=Low[i];
                  if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
                    {
                     if(Open[i]>Close[i])
                        lastlow=Close[i];
                     else
                        lastlow=Open[i];
                    }
                  //---
                  lastlowpos=i;
                  whatlookfor=1;
                  ExtZigzag_Prime[i]=lastlow;
                 }
              }
            break;
         case 1: // look for peak
            if(ExtUPdump_Prime2[i]!=0.0 && ExtUPdump_Prime2[i]<lastlow && ExtDWdump_Prime2[i]==0.0)
              {
               ExtZigzag_Prime[lastlowpos]=0.0;
               lastlowpos=i;
               lastlow=ExtUPdump_Prime2[i];
               ExtZigzag_Prime[i]=lastlow;
              }
            if(ExtDWdump_Prime2[i]!=0.0 && ExtUPdump_Prime2[i]==0.0)
              {
               lasthigh=ExtDWdump_Prime2[i];
               lasthighpos=i;
               ExtZigzag_Prime[i]=lasthigh;
               whatlookfor=-1;
              }
            break;
         case -1: // look for lawn
            if(ExtDWdump_Prime2[i]!=0.0 && ExtDWdump_Prime2[i]>lasthigh && ExtUPdump_Prime2[i]==0.0)
              {
               ExtZigzag_Prime[lasthighpos]=0.0;
               lasthighpos=i;
               lasthigh=ExtDWdump_Prime2[i];
               ExtZigzag_Prime[i]=lasthigh;
              }
            if(ExtUPdump_Prime2[i]!=0.0 && ExtDWdump_Prime2[i]==0.0)
              {
               lastlow=ExtUPdump_Prime2[i];
               lastlowpos=i;
               ExtZigzag_Prime[i]=lastlow;
               whatlookfor=1;
              }
            break;
        }
     }
//+------------------------------------------------------------------+
//--- Confrime 
//+------------------------------------------------------------------+
/*for(i=limit; i>=0; i--)
     {
      if(ExtZigzag_Prime[i]>0)
        {
         if(ExtDWdump_Prime2[i]>0)
            ExtDWdump_Prime[i]=ExtZigzag_Prime[i];
         if(ExtUPdump_Prime2[i]>0)
            ExtUPdump_Prime[i]=ExtZigzag_Prime[i];
        }
     }*/
//+------------------------------------------------------------------+
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll_Sec()
  {
   ArrayInitialize(ExtZigzag_Sec,0.0);
   ArrayInitialize(ExtDWdump_Sec2,0.0);
   ArrayInitialize(ExtUPdump_Sec2,0.0);
//--- first counting position
   return(Bars-InpDepth);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Skyfalls_Sec(const int rates_total,
                 const int prev_calculated,
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[])
  {

   int    i,limit,counterZ,whatlookfor=0;
   int    back,pos,lasthighpos=0,lastlowpos=0;
   double extremum=EMPTY_VALUE;
   double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;
//--- check for history and inputs
   if(rates_total<InpDepth || InpBackstep>=InpDepth)
      return(0);
//--- first calculations
   if(prev_calculated==0)
      limit=InitializeAll_Sec();
   else
     {
      //--- find first extremum in the depth ExtLevel or 100 last bars
      i=counterZ=0;
      while(counterZ<ExtLevel && i<100)
        {
         if(ExtZigzag_Sec[i]!=0.0)
            counterZ++;
         i++;
        }
      //--- no extremum found - recounting all from begin
      if(counterZ==0)
         limit=InitializeAll_Sec();
      else
        {
         //--- set start position to found extremum position
         limit=i-1;
         //--- what kind of extremum?
         if(ExtUPdump_Sec2[i]!=0.0)
           {
            //--- low extremum
            curlow=ExtUPdump_Sec2[i];
            //--- will look for the next high extremum
            whatlookfor=1;
           }
         else
           {
            //--- high extremum
            curhigh=ExtDWdump_Sec2[i];
            //--- will look for the next low extremum
            whatlookfor=-1;
           }
         //--- clear the rest data
         for(i=limit-1; i>=0; i--)
           {
            ExtZigzag_Sec[i]=0.0;
            ExtUPdump_Sec2[i]=0.0;
            ExtDWdump_Sec2[i]=0.0;
           }
        }
     }
//+------------------------------------------------------------------+
//--- main loop      
//+------------------------------------------------------------------+
   for(i=limit; i>=0; i--)
     {
      //--- find lowest low in depth of bars
      if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
         extremum=low[iLowest(NULL,0,MODE_LOW,InpDepth,i)];
      if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
         extremum=low[iLowest(NULL,0,MODE_CLOSE,InpDepth,i)];
      //--- this lowest has been found previously
      if(extremum==lastlow)
         extremum=0.0;
      else
        {
         //--- new last low
         lastlow=extremum;
         //--- discard extremum if current low is too high
         if(low[i]-extremum>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtUPdump_Sec2[pos]!=0 && ExtUPdump_Sec2[pos]>extremum)
                  ExtUPdump_Sec2[pos]=0.0;
              }
           }
        }
      //--- found extremum is current low
      if(low[i]==extremum)
         ExtUPdump_Sec2[i]=extremum;
      else
         ExtUPdump_Sec2[i]=0.0;
      //--- find highest high in depth of bars
      if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
         extremum=high[iHighest(NULL,0,MODE_HIGH,InpDepth,i)];
      if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
         extremum=high[iHighest(NULL,0,MODE_CLOSE,InpDepth,i)];
      //--- this highest has been found previously
      if(extremum==lasthigh)
         extremum=0.0;
      else
        {
         //--- new last high
         lasthigh=extremum;
         //--- discard extremum if current high is too low
         if(extremum-high[i]>InpDeviation*Point)
            extremum=0.0;
         else
           {
            //--- clear previous extremums in backstep bars
            for(back=1; back<=InpBackstep; back++)
              {
               pos=i+back;
               if(ExtDWdump_Sec2[pos]!=0 && ExtDWdump_Sec2[pos]<extremum)
                  ExtDWdump_Sec2[pos]=0.0;
              }
           }
        }
      //--- found extremum is current high
      if(high[i]==extremum)
         ExtDWdump_Sec2[i]=extremum;
      else
         ExtDWdump_Sec2[i]=0.0;
     }
//+------------------------------------------------------------------+
//--- final cutting 
//+------------------------------------------------------------------+
   if(whatlookfor==0)
     {
      lastlow=0.0;
      lasthigh=0.0;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
//---
   for(i=limit; i>=0; i--)
     {
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if(lastlow==0.0 && lasthigh==0.0)
              {
               if(ExtDWdump_Sec2[i]!=0.0)
                 {
                  //---
                  if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
                     lasthigh=High[i];
                  if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
                    {
                     if(Open[i]>Close[i])
                        lastlow=Open[i];
                     else
                        lastlow=Close[i];
                    }
                  //---
                  lasthighpos=i;
                  whatlookfor=-1;
                  ExtZigzag_Sec[i]=lasthigh;
                 }
               if(ExtUPdump_Sec2[i]!=0.0)
                 {
                  //---
                  if(MODE_CALLCANDLE==M_CALLCANDLE_HL)
                     lastlow=Low[i];
                  if(MODE_CALLCANDLE==M_CALLCANDLE_OC)
                    {
                     if(Open[i]>Close[i])
                        lastlow=Close[i];
                     else
                        lastlow=Open[i];
                    }
                  //---
                  lastlowpos=i;
                  whatlookfor=1;
                  ExtZigzag_Sec[i]=lastlow;
                 }
              }
            break;
         case 1: // look for peak
            if(ExtUPdump_Sec2[i]!=0.0 && ExtUPdump_Sec2[i]<lastlow && ExtDWdump_Sec2[i]==0.0)
              {
               ExtZigzag_Sec[lastlowpos]=0.0;
               lastlowpos=i;
               lastlow=ExtUPdump_Sec2[i];
               ExtZigzag_Sec[i]=lastlow;
              }
            if(ExtDWdump_Sec2[i]!=0.0 && ExtUPdump_Sec2[i]==0.0)
              {
               lasthigh=ExtDWdump_Sec2[i];
               lasthighpos=i;
               ExtZigzag_Sec[i]=lasthigh;
               whatlookfor=-1;
              }
            break;
         case -1: // look for lawn
            if(ExtDWdump_Sec2[i]!=0.0 && ExtDWdump_Sec2[i]>lasthigh && ExtUPdump_Sec2[i]==0.0)
              {
               ExtZigzag_Sec[lasthighpos]=0.0;
               lasthighpos=i;
               lasthigh=ExtDWdump_Sec2[i];
               ExtZigzag_Sec[i]=lasthigh;
              }
            if(ExtUPdump_Sec2[i]!=0.0 && ExtDWdump_Sec2[i]==0.0)
              {
               lastlow=ExtUPdump_Sec2[i];
               lastlowpos=i;
               ExtZigzag_Sec[i]=lastlow;
               whatlookfor=1;
              }
            break;
        }
     }
//+------------------------------------------------------------------+
//--- Confrime 
//+------------------------------------------------------------------+
/*for(i=limit; i>=0; i--)
     {
      if(ExtZigzag_Sec[i]>0)
        {
         if(ExtDWdump_Sec2[i]>0)
            ExtDWdump_Sec[i]=ExtZigzag_Sec[i];
         if(ExtUPdump_Sec2[i]>0)
            ExtUPdump_Sec[i]=ExtZigzag_Sec[i];
        }
     }*/
//+------------------------------------------------------------------+
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string e(double v,int d)
  {
   if(v==EMPTY_VALUE || v==0)
     {
      return "0";
     }
   return DoubleToStr(v,d);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double e(double v)
  {
   if(v==EMPTY_VALUE)
     {
      return 0;
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="TrendLine",  // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time1=0,// first point time 
                 double                price1=0,// first point price 
                 datetime              time2=0,// second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            ray_right=false,   // line's continuation to the right 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- create a trend line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      ObjectMove(chart_ID,name,0,time1,price1);
      ObjectMove(chart_ID,name,1,time2,price2);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one 
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one 
   if(!price2)
      price2=price1;
  }
//+------------------------------------------------------------------+
bool VLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="VLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time=0,            // line time 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            lock=true,// 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the line time is not set, draw it via the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      VLineMove(chart_ID,name,time,clr);
      //Print(__FUNCTION__,": failed to create a vertical line! Error code = ",GetLastError());
      //return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,lock);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the vertical line                                           | 
//+------------------------------------------------------------------+ 
bool VLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="VLine", // line name 
               datetime     time=0,// line time 
               const color  clr=clrRed)// line color
  {
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- if line time is not set, move the line to the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      VLineMove(chart_ID,name,time);
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="HLine",// line name 
                 const string          str="Text",
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrYellow,// line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            SELECTABLE=true,// move 
                 const bool            selection=true,// highlight to move 
                 const bool            hidden=false,// hidden in the object list 
                 const long            z_order=0) // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      if(str!="")
        {
         ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,str);
         ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
        }
      HLineMove(chart_ID,name,price,clr);
      //Print(__FUNCTION__,": failed to create a horizontal line! Error code = ",GetLastError());
      //return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,SELECTABLE);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   if(str!="")
     {
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
     }

   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID = 0,// chart's ID 
               const string name="HLine",// line name 
               double       price=0,
               const color  clr=clrYellow) // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      //Print(__FUNCTION__,": failed to move the horizontal line! Error code = ",GetLastError()); 
      return(false);
     }
//--- successful execution 
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DUMP_Mark[1];
int MarkCNT=0;

int Bars15=InpDepthPrime*Period(),Bars15_Count;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getZone()
  {

   ArrayResize(DUMP_Mark,Bars,0);

   double iCustomVAr=0;
   MarkCNT=0;
   for(int i=0;i<Bars;i++)
     {
      //iCustomVAr=iCustom(Symbol(),PERIOD_M15,"My/ZigZag",12,80,0,0,false,0,i);
      //printf(iCustomVAr);

      if(ExtZigzag_Prime[i]>0)
        {
         DUMP_Mark[MarkCNT]=ExtZigzag_Prime[i];
         MarkCNT++;
        }
     }
   int ConntNew=0;
   for(int r=0;r<Bars15/2;r++)
     {
      ArraySort(DUMP_Mark,0,0,MODE_DESCEND);
      ConntNew=0;
      for(int i=0;i<MarkCNT;i++)
        {
         if(DUMP_Mark[i]>0)
           {
            ConntNew++;
            if(MathAbs(DUMP_Mark[i]-DUMP_Mark[i+1])<(ZoneLess*Point))
              {
               DUMP_Mark[i+1]=0;
              }
           }
        }
      MarkCNT=ConntNew;
     }
   ArrayResize(DUMP_Mark,MarkCNT,0);
   ArraySort(DUMP_Mark,0,0,MODE_ASCEND);

   return MarkCNT;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
