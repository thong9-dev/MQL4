//+------------------------------------------------------------------+
//|                                                    Parabolic.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property description "X-MA : Breakout Moving average system"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum setMODE_BREAKTREND
  {
   MODE_BT_OC=0,//Open,Close
   MODE_BT_OHLC=1,//Open,Close,High,Low
  };
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
//#property indicator_color1  clrRoyalBlue
//#property indicator_color2  clrRed
//#property indicator_color3  clrMagenta
//--- input parameters
input setMODE_BREAKTREND  Break=MODE_BT_OC;    // Price used to break the trend
input string            Spector="----------------------------------------";//----------------------------------------
input int               InpMAPeriod=13;        // MA_Period
input int               InpMAShift=0;          // MA_Shift
input ENUM_MA_METHOD    InpMAMethod=MODE_SMA;  // MA_Method
input string            Spector2="----------------------------------------";//----------------------------------------
input bool              HilightSwapDir_bool=true;   //Focus the lines that Swaps
input int               HilightSwapDir_weight=2;    //Weight to highlight line
input string            Spector3="----------------------------------------";//----------------------------------------
input color             clrUP=clrDodgerBlue;
input color             clrDW=clrRed;
input color             clrBR=clrMagenta;
input int               BreakSymbol=108;
input int               BreakSymbol_weight=0;
//---- buffers
double       ExtUppperBuffer[];
double       ExtLowerBuffer[];
double       ExtBreakBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   string short_name="X-";
   int    draw_begin=InpMAPeriod-1;
//--- indicator short name
   switch(InpMAMethod)
     {
      case MODE_SMA  : short_name+="SMA";                break;
      case MODE_EMA  : short_name+="EMA";  draw_begin=0; break;
      case MODE_SMMA : short_name+="SMMA";               break;
      case MODE_LWMA : short_name+="LWMA";               break;
      default :        return(INIT_FAILED);
     }
   IndicatorShortName(short_name+"("+string(InpMAPeriod)+")");
   IndicatorDigits(Digits);
//--- check for input
   if(InpMAPeriod<2)
      return(INIT_FAILED);
//---
   double _SWAP_LONG=MarketInfo(Symbol(),MODE_SWAPLONG);
   double _SWAP_SHORT=MarketInfo(Symbol(),MODE_SWAPSHORT);
   int _Width_LONG=0,_Width_SHORT=0;
   if(_SWAP_LONG>0) _Width_LONG=HilightSwapDir_weight;
   if(_SWAP_SHORT>0) _Width_SHORT=HilightSwapDir_weight;

   SetIndexBuffer(0,ExtUppperBuffer);
   SetIndexBuffer(1,ExtLowerBuffer);
   SetIndexBuffer(2,ExtBreakBuffer);
//---- drawing parameters setting 

   SetIndexStyle(0,DRAW_LINE,0,_Width_LONG,clrUP);
   SetIndexStyle(1,DRAW_LINE,0,_Width_SHORT,clrDW);

   SetIndexStyle(2,DRAW_ARROW,EMPTY,BreakSymbol_weight,clrBR);
   SetIndexArrow(2,BreakSymbol);
//---- displaying in the DataWindow 
//SetIndexLabel(0,short_name+" Up");
//SetIndexLabel(1,short_name+" Down");
//SetIndexLabel(2,short_name+" Break");
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Parabolic SAR                                                    |
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
//printf(rates_total+"|"+prev_calculated);
   int    i;
//--- check for minimum rates count
   if(rates_total<3)
      return(0);
   i=prev_calculated-1;
   if(i<1)
     {
      i=0;
      double ma;
      double _close=0,_open=0,_high=0,_low=0;
      while(i<rates_total-1)
        {
         ma=iMA(Symbol(),Period(),InpMAPeriod,InpMAShift,InpMAMethod,0,i);
         //---
         _close=iClose(Symbol(),Period(),i);
         _open=iOpen(Symbol(),Period(),i);
         if(Break==MODE_BT_OHLC)
           {
            _high=iHigh(Symbol(),Period(),i);
            _low=iLow(Symbol(),Period(),i);

            if(_close>ma  &&  _open>ma  &&  _high>ma && _low>ma) ExtUppperBuffer[i]=ma;
            else if(_close<ma && _open<ma && _high<ma && _low<ma) ExtLowerBuffer[i]=ma;
            else                                                  ExtBreakBuffer[i]=ma;
           }
         else
           {
            if(_close>ma && _open>ma) ExtUppperBuffer[i]=ma;
            else if(_close<ma && _open<ma)   ExtLowerBuffer[i]=ma;
            else                             ExtBreakBuffer[i]=ma;
           }
         i++;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
