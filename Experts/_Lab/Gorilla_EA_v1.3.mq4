//+------------------------------------------------------------------+
//|                                                  Gorilla_EA_v1.3 |
//|                                                    by EZcurrency |
//+------------------------------------------------------------------+
//
// Changes: 111
// v1.1 - added EMAdistance which will verify that the distance from the EMA4 to EMA15 and EMA15 to EMA30 
//        is at least x pips.  This will prevent entries when prices are flat and little to no distance between EMAs
//      - added prevEMA4 and prevEMA15.  This is the previous value of the EMA's 1 hr back.  EMA4 must be > prevEMA4
//        and EMA15 must be > prevEMA15 for longs.  Opposite for shorts.
//      - added AutoPipsFromEMA.  If this is set to true, then pipsFromEMA = 30 for larger moving pairs, and 20 for normal pairs
//      - added NLD filter so 5 min NLD and 15 min NLD (shorter term trends) must align to everything else for buys/sells
//      - added if beyond daily R2, then exit on 5 min NLD change. 
//      - notification of reason for exiting after trade closed in upper right part of the screen.
//      - move SL to b/e once R1/S1 hit
//
//      - added option to only trade if price above/below weekly pivot (weeklyPivotFilter).  if weeklyPivotFilter = true:
//          - price > weekly pivot
//          - 4hr EMA4 > EMA15
//          - 4 hr EMA4 > prev. EMA4 (same for EMA15)
//
//  v1.1a - removed currency signal calculations to free up memory usage
//  v1.3 - modified v1.1a to include a trailing SL when pipsToTrailSL is hit and when 15 min NLD changes trend
//
//
// -------------------------------------------------------------------
// EA to be run on 1 hr charts.
// required indicator files:
// - nonlagdot.mq4
// required include files:
// - currencySignals.mqh
// 
// TRADING RULES:
// BUYS:
// - ENTRIES
// - today daily pivot point(PP) > yesterday daily PP (disregard weekends)
// - EMA(30), EMA(15), EMA(4) above pivot
// - EMA(4) > EMA(15) > EMA(30) 
// - price > EMA(4) 
// - entry when price returns to at/near EMA(30)
//    - entry price set +/- set # of pips withing EMA(30)
// - ** filter option for Non Lag Dot (NLD) on 5 & 15 minute timeframes to align long (both blue on indicator)
//       this will eliminate bad trade if price is going down through EMA's, but also lag in getting into trades
//       In the future consider adding NLD for 30 min

// - EMA(4) crosses EMA(15) down
// - daily R3
// - Close at EMA(30)
// - longTarget (manually set)
// - SL at 30 pips 
//   ** evaluate for larger moving pairs such as GBPAUD - may be need to be set at 70 pips 
//   or a percentage (TBD) of hourly true range (HTR) or daily true trange (ATR)
// - manual setting for exit
//    - normally beyond recent swing highs exist stop loss (SL) orders.  This is a good place to take profit (TP).
// - exit at weekly R2
//
// SELLS:
// - opposite of above
//-------------------------------------------------------------------------------------------

#property strict
#include <stdlib.mqh>
#include <stderror.mqh>

//---- input parameters
extern string    Comments="Gorilla_EA_v1.3";
extern double    longTarget=0.0;  // longTarget
extern double    shortTarget=0.0;  // shortTarget
extern bool      weeklyPivotFilter=true;
extern bool      EnableTrading=true;
extern bool      wantLongs=true;
extern bool      wantShorts=true;
extern bool      AutoPipsFromEMA=true;
extern int       pipsFromEMA=20;
extern int       pipsToTrailSL=5;
extern int       EMAdistance=5;
extern int       ydist=2; // yoffset for data display
extern int        GMT_Offset=0;
extern string    Trade_Lot_Settings="Money Management Settings";
extern double    start_lot=0.1;
extern bool      AutoMagicNumber=true;
extern int       magicInput=33;                  // magic # if autoMagic = false 
extern bool      use_sl_and_tp=true;
extern double    sl=30;                            // SL in pips
extern double    tp=150;                            // TP in pips
extern int       trailStop_std = 0;               // trail SL: 0 to deactivate
extern double    MaxSpread = 50;                  // max sprd: check if 4 or 5 digit

                                                  // signal variables for 1 bar back
int signal5,signal15,signal30,signal60,signal240,signal5d,signal15d,signal30d,signal60d,signal240d;

// variables for delta calculations 
int delta5,delta15,delta30,delta60,delta240;

// misc int variables
int BarCount,Current,Starttime,EndTime,RunTime,Current_Time,magic,fontSize,nextSave;
int trendM5,trendM15,TotalBuyOrder,TotalSellOrder,i,ticket,b_cnt,s_cnt,TradesOpen;

// misc double variables
double pt,minlot,stoplevel,prec,priceToEMA,EMA4to15,EMA15to30,TradesOpenProfit;
double red_signalM5,blue_signalM5,red_signalM15,blue_signalM15,b_lot,s_lot;
double wHI,wLO, wCL, wOP, wPP, wS1, wS2, wS3, wR1, wR2, wR3;  // weekly data and pivots
double dHI, dLO, dCL, dOP, dPP, dS1, dS2, dS3, dR1, dR2, dR3; // previous day data and pivots
double d2HI,d2LO,d2CL,d2OP,d2PP,d2S1,d2S2,d2S3,d2R1,d2R2,d2R3; // 2 days ago data and pivots
double EMA30,EMA15,EMA4,prevEMA15,prevEMA4,EMA4hr30,EMA4hr15,EMA4hr4,prev4hrEMA15,prev4hrEMA4;;

// misc string variables
string TradingPairs=Symbol();
string pair,numer,denom;
string _fnSetFileValue3,LineValue,TextValue;

// misc boolean variables
bool inTrade,paused,beyondR2S2,is_formed;

// font color
color col=White;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   nextSave = Minute();
   fontSize = 10;
   beyondR2S2=false;
// AutoMagicNumber
   if(AutoMagicNumber==true) 
     {
      if(TradingPairs=="AUDCAD") 
        {
         magic=11;
        }
      else if(TradingPairs=="AUDCHF") 
        {
         magic=21;
        }
      else if(TradingPairs=="AUDJPY") 
        {
         magic=31;
        }
      else if(TradingPairs=="AUDNZD") 
        {
         magic=41;
        }
      else if(TradingPairs=="AUDUSD") 
        {
         magic=51;
        }
      else if(TradingPairs=="CADCHF") 
        {
         magic=61;
        }
      else if(TradingPairs=="CADJPY") 
        {
         magic=71;
        }
      else if(TradingPairs=="CHFJPY")
        {
         magic=81;
        }
      else if(TradingPairs=="EURAUD") 
        {
         magic=91;
        }
      else if(TradingPairs=="EURCAD") 
        {
         magic=101;
        }
      else if(TradingPairs=="EURCHF") 
        {
         magic=111;
        }
      else if(TradingPairs=="EURGBP") 
        {
         magic=121;
        }
      else if(TradingPairs=="EURJPY") 
        {
         magic=131;
        }
      else if(TradingPairs=="EURNZD") 
        {
         magic=141;
        }
      else if(TradingPairs=="EURUSD") 
        {
         magic=151;
        }
      else if(TradingPairs=="GBPAUD") 
        {
         magic=161;
        }
      else if(TradingPairs=="GBPCAD") 
        {
         magic=171;
        }
      else if(TradingPairs=="GBPCHF") 
        {
         magic=181;
        }
      else if(TradingPairs=="GBPJPY") 
        {
         magic=191;
        }
      else if(TradingPairs=="GBPNZD") 
        {
         magic=196;
        }
      else if(TradingPairs=="GBPUSD") 
        {
         magic=201;
        }
      else if(TradingPairs=="NZDCAD") 
        {
         magic=210;
        }
      else if(TradingPairs=="NZDCHF") 
        {
         magic=221;
        }
      else if(TradingPairs=="NZDJPY") 
        {
         magic=231;
        }
      else if(TradingPairs=="NZDUSD") 
        {
         magic=241;
        }
      else if(TradingPairs=="USDCAD") 
        {
         magic=251;
        }
      else if(TradingPairs=="USDCHF") 
        {
         magic=261;
        }
      else if(TradingPairs=="USDJPY") 
        {
         magic=271;
        }
        }  else {
      magic=magicInput;
     }

// AutoPipsFromEMA
   if(AutoPipsFromEMA==true) 
     {
      if(TradingPairs=="AUDCAD") 
        {
         pipsFromEMA = 20;
        }
      else if(TradingPairs=="AUDCHF") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="AUDJPY") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="AUDNZD") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="AUDUSD") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="CADCHF") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="CADJPY") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="CHFJPY")
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="EURAUD") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="EURCAD") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="EURCHF") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="EURGBP") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="EURJPY") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="EURNZD") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="EURUSD") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="GBPAUD") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="GBPCAD") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="GBPCHF") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="GBPJPY") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="GBPNZD") 
        {
         pipsFromEMA=30;
        }
      else if(TradingPairs=="GBPUSD") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="NZDCAD") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="NZDCHF") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="NZDJPY") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="NZDUSD") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="USDCAD") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="USDCHF") 
        {
         pipsFromEMA=20;
        }
      else if(TradingPairs=="USDJPY") 
        {
         pipsFromEMA=20;
        }
     }

// Get the currency pair, and split it into the two countries
   pair=Symbol();
   numer = StringSubstr(pair, 0, 3);
   denom = StringSubstr(pair, 3, 3);

   BarCount=Bars;

   if(Digits==3 || Digits==5) pt=10*Point;
   else                          pt=Point;
   minlot   =   MarketInfo(Symbol(),MODE_MINLOT);
   stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(start_lot<minlot) Print("lotsize is to small.");
   if(sl<stoplevel) Print("stoploss is to tight.");
   if(tp<stoplevel) Print("takeprofit is to tight.");
   if(minlot==0.01) prec=2;
   if(minlot==0.1)  prec=1;

// previous week O, H, L, C   
   wOP=iOpen(NULL,PERIOD_W1,1);
   wCL=iClose(NULL,PERIOD_W1,1);
   wHI=iHigh(NULL, PERIOD_W1,1);
   wLO=iLow(NULL, PERIOD_W1,1);


// weekly pivot point price levels
   wPP = (wHI+wLO+wCL)/3.0;
   wS1 = NormalizeDouble(2*wPP - wHI,Digits);
   wS2 = NormalizeDouble(wPP-(wHI-wLO),Digits);
   wS3 = NormalizeDouble(wPP-2*(wHI-wLO),Digits);
   wR1 = NormalizeDouble(2*wPP - wLO,Digits);
   wR2 = NormalizeDouble(wPP+(wHI-wLO),Digits);
   wR3 = NormalizeDouble(wPP+2*(wHI-wLO),Digits);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,OBJ_LABEL);
   ObjectsDeleteAll(0,OBJ_HLINE);
   ObjectsDeleteAll(0,OBJ_TEXT);
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert start/tick function                                       |
//+------------------------------------------------------------------+
//void OnTick() 222
int start()
  {
// if beyondR2S2 then stop EA and do not enter trades
   if(beyondR2S2==true) 
     {
      ObjectsDeleteAll(0,OBJ_LABEL);
      ObjectsDeleteAll(0,OBJ_HLINE);
      ObjectsDeleteAll(0,OBJ_TEXT);
      Comment("");
      beyondWeeklyR2S2();
      drawLabel("wR2","wR2:   "+DoubleToStr(wR2,5),fontSize,"Times New Roman",White,1,20,120);
      drawLabel("wS2","wS2:   "+DoubleToStr(wS2,5),fontSize,"Times New Roman",White,1,20,140);
      return(0);
     }

   Sleep(1000);
   RefreshRates();
// ShowStatus();
   ScreenComments();
   OrdersTotalInfo();
   paused=false;
   if(total()>0) 
     {
      inTrade=true;
        } else {
      inTrade=false;
     }

// previous week O, H, L, C   
   wOP=iOpen(NULL,PERIOD_W1,1);
   wCL=iClose(NULL,PERIOD_W1,1);
   wHI=iHigh(NULL, PERIOD_W1,1);
   wLO=iLow(NULL, PERIOD_W1,1);

// previous day O, H, L, C   
   dOP=iOpen(NULL,PERIOD_D1,1);
   dCL=iClose(NULL,PERIOD_D1,1);
   dHI=iHigh(NULL, PERIOD_D1,1);
   dLO=iLow(NULL, PERIOD_D1,1);

// 2 days ago O, H, L, C   
   d2OP=iOpen(NULL,PERIOD_D1,2);
   d2CL=iClose(NULL,PERIOD_D1,2);
   d2HI=iHigh(NULL, PERIOD_D1,2);
   d2LO=iLow(NULL, PERIOD_D1,2);
// 2 days ago pivot
   d2PP=(d2HI+d2LO+d2CL)/3.0;

// weekly pivot point price levels
   wPP = (wHI+wLO+wCL)/3.0;
   wS1 = NormalizeDouble(2*wPP - wHI,Digits);
   wS2 = NormalizeDouble(wPP-(wHI-wLO),Digits);
   wS3 = NormalizeDouble(wPP-2*(wHI-wLO),Digits);
   wR1 = NormalizeDouble(2*wPP - wLO,Digits);
   wR2 = NormalizeDouble(wPP+(wHI-wLO),Digits);
   wR3 = NormalizeDouble(wPP+2*(wHI-wLO),Digits);

// daily pivot point price levels
   dPP = (dHI+dLO+dCL)/3.0;
   dS1 = NormalizeDouble(2*dPP - dHI,Digits);
   dS2 = NormalizeDouble(dPP-(dHI-dLO),Digits);
   dS3 = NormalizeDouble(dPP-2*(dHI-dLO),Digits);
   dR1 = NormalizeDouble(2*dPP - dLO,Digits);
   dR2 = NormalizeDouble(dPP+(dHI-dLO),Digits);
   dR3 = NormalizeDouble(dPP+2*(dHI-dLO),Digits);

// EMA
   EMA30 = iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,0);
   EMA15 = iMA(NULL,0,15,0,MODE_EMA,PRICE_CLOSE,0);
   EMA4=iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,0);

// prevoius EMA on 1 hr charts
   prevEMA15= iMA(NULL,0,15,0,MODE_EMA,PRICE_CLOSE,1);
   prevEMA4 = iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,1);

// EMA on 4 hr charts
   EMA4hr30 = iMA(NULL,240,30,0,MODE_EMA,PRICE_CLOSE,0);
   EMA4hr15 = iMA(NULL,240,15,0,MODE_EMA,PRICE_CLOSE,0);
   EMA4hr4=iMA(NULL,240,4,0,MODE_EMA,PRICE_CLOSE,0);

// prevoius EMA on 4 hr charts
   prev4hrEMA15= iMA(NULL,240,15,0,MODE_EMA,PRICE_CLOSE,1);
   prev4hrEMA4 = iMA(NULL,240,4,0,MODE_EMA,PRICE_CLOSE,1);



//NLD 15 min
   blue_signalM15= iCustom(NULL,PERIOD_M15,"nonlagdot",0,20,0,0,1,0,1);
   red_signalM15 = iCustom(NULL,PERIOD_M15,"nonlagdot",0,20,0,0,1,0,2);
   if(blue_signalM15>red_signalM15)
     {trendM15=1; }
   else { trendM15=-1;}

//NLD 5 min
   blue_signalM5= iCustom(NULL,PERIOD_M5,"nonlagdot",0,20,0,0,1,0,1);
   red_signalM5 = iCustom(NULL,PERIOD_M5,"nonlagdot",0,20,0,0,1,0,2);
   if(blue_signalM5>red_signalM5)
     {trendM5=1; }
   else { trendM5=-1;}

// pips to EMA
   priceToEMA=MathAbs((MarketInfo(Symbol(),MODE_BID)-EMA30)/(10*Point));

// pips between 4/15 EMAs and 15/30 EMAs
   EMA4to15=MathAbs((EMA4-EMA15)/(10*Point));
   EMA15to30=MathAbs((EMA15-EMA30)/(10*Point));

// number of buy and sell orders  
   TotalBuyOrder=CheckTotalOrder(Symbol(),magic,OP_BUY);
   TotalSellOrder=CheckTotalOrder(Symbol(),magic,OP_SELL);

// ********************** EXITS ************************************** 777
// exit longs when pipsPL > pipsToTrailSL then exit on 15 min NLD change 
   if((pipsPL(magic)>=pipsToTrailSL) && (TotalBuyOrder>=1) && (trendM15==-1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
     }

// exit shorts when pipsPL > pipsToTrailSL then exit on 15 min NLD change 
   if((pipsPL(magic)>=pipsToTrailSL) && (TotalSellOrder>=1) && (trendM15==1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
     }

// move SL to b/e after longs pass R1 or shorts pass S1
   if((iClose(NULL,PERIOD_M1,1)>dR1) && (TotalBuyOrder>=1)) 
     {
      breakEvenStopLoss();
     }

   if((iClose(NULL,PERIOD_M1,1)<dS1) && (TotalSellOrder>=1)) 
     {
      breakEvenStopLoss();
     }

// check to exit longs and not execute trades above weekly R2 
   if((iClose(NULL,PERIOD_M1,1)>wR2)) 
     {
      paused=true;
      beyondR2S2=true;
      if(TotalBuyOrder>=1) 
        {
         FIFOCloseAll();
         beyondWeeklyR2S2();
         return(0);
         //Sleep(SleepAfterExit);  // sleep after exiting trades
        }
     }
// check to exit shorts and not execute trades below weekly S2 
   if((iClose(NULL,PERIOD_M1,1)<wS2)) 
     {
      paused=true;
      beyondR2S2=true;
      if(TotalSellOrder>=1) 
        {
         FIFOCloseAll();
         beyondWeeklyR2S2();
         return(0);

         //Sleep(SleepAfterExit);  // sleep after exiting trades
        }
     }

// check to exit longs and pause at price target 
   if((longTarget>0) && (iClose(NULL,PERIOD_M1,1)>longTarget) && (TotalBuyOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      priceTargetHit();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades      
     }
// check to exit shorts and pause at price target 
   if((shortTarget>0) && (iClose(NULL,PERIOD_M1,1)<shortTarget) && (TotalSellOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      priceTargetHit();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades    
     }

// exit on EMA(4) crosses EMA(15) down for longs     
   if((EMA4<EMA15) && (TotalBuyOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      EMA4crossEMA15();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades          
     }

// exit on EMA(4) crosses EMA(15) up for shorts     
   if((EMA4>EMA15) && (TotalSellOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      EMA4crossEMA15();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades         
     }

// exit longs when price crosses below EMA(30)
   if((iClose(NULL,PERIOD_M1,1)<EMA30) && (TotalBuyOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      price30EMA();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades       
     }

// exit shorts when price crosses over EMA(30)
   if((iClose(NULL,PERIOD_M1,1)>EMA30) && (TotalSellOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      price30EMA();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades        
     }

// exit longs when price crosses above daily R3
   if((iClose(NULL,PERIOD_M1,1)>dR3) && (TotalBuyOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      priceDS3R3();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades        
     }

// exit shorts when price crosses below daily S3
   if((iClose(NULL,PERIOD_M1,1)<dS3) && (TotalSellOrder>=1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      priceDS3R3();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades   
     }

// exit longs when if beyond daily R2, then exit on 5 min NLD change 
   if((iClose(NULL,PERIOD_M1,1)>dR2) && (TotalBuyOrder>=1) && (trendM5==-1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      dailyS2R2NLD();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades     
     }

// exit longs when if beyond daily S2, then exit on 5 min NLD change 
   if((iClose(NULL,PERIOD_M1,1)<dS2) && (TotalSellOrder>=1) && (trendM5==1)) 
     {
      paused=true;
      beyondR2S2=true;
      FIFOCloseAll();
      dailyS2R2NLD();
      return(0);
      //Sleep(SleepAfterExit);  // sleep after exiting trades          
     }

// ********************** ENTRIES ************************************   
// check for new buy order
   if(total()==0 && inTrade==false)
     {
      if(entryTradeSignal()==1 && (MarketInfo(Symbol(),MODE_SPREAD)<MaxSpread)) 
        {
         if(use_sl_and_tp)
           {
            s_lot=start_lot;
            ticket=OrderSend(Symbol(),0,s_lot,Ask,3,Ask-sl*pt,Ask+tp*pt,Comments,magic,0,Blue);
            inTrade=true;
            Sleep(2000);
              } else {
            s_lot=start_lot;
            ticket=OrderSend(Symbol(),0,s_lot,Ask,3,0,0,Comments,magic,0,Blue);
            inTrade=true;
            Sleep(2000);
           }
        }
     }

// check for new sell order
   if(total()==0 && inTrade==false)
     {
      if(entryTradeSignal()==-1 && MarketInfo(Symbol(),MODE_SPREAD)<MaxSpread) 
        {
         if(use_sl_and_tp)
           {
            s_lot=start_lot;
            ticket=OrderSend(Symbol(),1,s_lot,Bid,3,Bid+sl*pt,Bid-tp*pt,Comments,magic,0,Red);
            inTrade=true;
            Sleep(2000);
              } else {
            s_lot=start_lot;
            ticket=OrderSend(Symbol(),1,s_lot,Bid,3,0,0,Comments,magic,0,Red);
            inTrade=true;
            Sleep(2000);
           }
        }
     }
// *******************************************************************  

// trailing SL
   if(trailStop_std>0) TrailIt(trailStop_std,magic);

// number of positions
   for(int cnt=0; cnt<=OrdersTotal(); cnt++
       )
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()<2) 
           {
            if(OrderType()==0 && b_cnt==0)
              {
               b_cnt+=1;
              }
            if(OrderType()==1 && s_cnt==0)
              {
               s_cnt+=1;
              }
           }
        }
     }
   return(0);                                      // exit start()
  }
// ****************************************************************************************************    
// **************************************** END ******************************************************* 
// **************************************** MAIN ****************************************************** 
// ****************************************************************************************************   


// Functions below

//+------------------------------------------------------------------+

int total()
  {
   int total=0;
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         total++;
        }
     }
   return(total);
  }
//+------------------------------------------------------------------+

void FIFOCloseAll()
  {
   int lowestticket;
   bool repeat;
   repeat=true;
   while(repeat)
     {
      repeat=false;
      lowestticket=-1;
      i=OrdersTotal()-1;
      while(i>=0) 
        {
         bool b=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if((OrderSymbol()==Symbol()) && (OrderMagicNumber()==magic) && OrderType()<2)
           {
            repeat=true;
            if(lowestticket<0) lowestticket=OrderTicket();
            if(OrderTicket()<lowestticket) lowestticket=OrderTicket();
           }
         i--;
        }
      if(lowestticket>-1)
        {
         bool c=OrderSelect(lowestticket,SELECT_BY_TICKET,MODE_TRADES);
         bool d=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),10,clrNONE);
        }
     }
   inTrade=false;
  }
//+------------------------------------------------------------------+

int entryTradeSignal()
  {  //555  

// BUYS:
   if((trendM5==1) && (trendM15==1) && (wantLongs==true) && (priceToEMA<=pipsFromEMA) && 
      (weeklyPivotFilter==true) && (iClose(NULL,PERIOD_M1,1)>wPP) && 
      (EMA4hr4>prev4hrEMA4) && (EMA4hr15>prev4hrEMA15) && (EMA4hr4>EMA4hr15) && 
      (dPP>d2PP) && (EMA4>dPP) && (EMA15>dPP) && (EMA30>dPP) && 
      (EMA4to15>=EMAdistance) && (EMA15to30>=EMAdistance) && (EMA4>prevEMA4) && (EMA15>prevEMA15) && 
      (EMA4>EMA15) && (EMA15>EMA30) && (iClose(NULL,PERIOD_M1,1)>EMA4) && 
      (iClose(NULL,PERIOD_M1,1)<wR2) && (EnableTrading==true) && (paused==false))
     {
      return(1);
     }

   if((trendM5==1) && (trendM15==1) && (wantLongs==true) && (priceToEMA<=pipsFromEMA) && 
      (dPP>d2PP) && (EMA4>dPP) && (EMA15>dPP) && (EMA30>dPP) && (weeklyPivotFilter==false) && 
      (EMA4to15>=EMAdistance) && (EMA15to30>=EMAdistance) && (EMA4>prevEMA4) && (EMA15>prevEMA15) && 
      (EMA4>EMA15) && (EMA15>EMA30) && (iClose(NULL,PERIOD_M1,1)>EMA4) && 
      (iClose(NULL,PERIOD_M1,1)<wR2) && (EnableTrading==true) && (paused==false))
     {
      return(1);
     }

// SELL SIGNAL:
   if((trendM5==-1) && (trendM15==-1) && (wantShorts==true) && (priceToEMA<=pipsFromEMA) && 
      (dPP<d2PP) && (EMA4<dPP) && (EMA15<dPP) && (EMA30<dPP) && 
      (weeklyPivotFilter==true) && (iClose(NULL,PERIOD_M1,1)<wPP) && 
      (EMA4hr4<prev4hrEMA4) && (EMA4hr15<prev4hrEMA15) && (EMA4hr4<EMA4hr15) && 
      (EMA4to15>=EMAdistance) && (EMA15to30>=EMAdistance) && (EMA4<prevEMA4) && (EMA15<prevEMA15) && 
      (EMA4<EMA15) && (EMA15<EMA30) && (iClose(NULL,PERIOD_M1,1)<EMA4) && 
      (iClose(NULL,PERIOD_M1,1)>wS2) && (EnableTrading==true) && (paused==false))
     {
      return(-1);
     }

   if((trendM5==-1) && (trendM15==-1) && (wantShorts==true) && (priceToEMA<=pipsFromEMA) && 
      (dPP<d2PP) && (EMA4<dPP) && (EMA15<dPP) && (EMA30<dPP) && (weeklyPivotFilter==false) && 
      (EMA4to15>=EMAdistance) && (EMA15to30>=EMAdistance) && (EMA4<prevEMA4) && (EMA15<prevEMA15) && 
      (EMA4<EMA15) && (EMA15<EMA30) && (iClose(NULL,PERIOD_M1,1)<EMA4) && 
      (iClose(NULL,PERIOD_M1,1)>wS2) && (EnableTrading==true) && (paused==false))
     {
      return(-1);
     }

   return(0);
  }
//+------------------------------------------------------------------+
//| Trailing stop procedure                                          |
//+------------------------------------------------------------------+
void TrailIt(int byPips,int mg)
  {
   if(byPips>=5)
     {
      for(i=0; i<OrdersTotal(); i++) 
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) 
           {
            if(OrderSymbol()==Symbol() && ((OrderMagicNumber()==mg)))
              {
               if(OrderType()==OP_BUY) 
                 {
                  if(Bid-OrderOpenPrice()>byPips*pt) 
                    {
                     if(OrderStopLoss()<Bid-byPips*pt) 
                       {
                        if(OrderModify(OrderTicket(),OrderOpenPrice(),Bid-byPips*pt,OrderTakeProfit(),Red)){}
                       }
                    }
                    } else if(OrderType()==OP_SELL) {
                  if(OrderOpenPrice()-Ask>byPips*pt) 
                    {
                     if((OrderStopLoss()>Ask+byPips*pt) || (OrderStopLoss()==0)) 
                       {
                        if(OrderModify(OrderTicket(),OrderOpenPrice(),Ask+byPips*pt,OrderTakeProfit(),Red)){}
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+

int CheckTotalOrder(string a_symbol,int Magic,int a_type)
  {
   int count=0;
   for(i=0; i<=OrdersTotal(); i++)
     {
      int select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==a_symbol && OrderMagicNumber()==Magic && OrderType()==a_type)
         count=count+1;
     }
   return(count);
  }
//+------------------------------------------------------------------+

double profit(int mg)
  {
   double profitMoney=0;
   double highestProfit=0;
   for(i=OrdersTotal()-1; i>=0; i--) 
     {
      if(OrderSelect(i,SELECT_BY_POS)) 
        {
         if((OrderSymbol()==Symbol() && OrderMagicNumber()==mg)) 
           {
            profitMoney+=OrderProfit()+OrderCommission()+OrderSwap();
            // highest profit
            if(profitMoney>highestProfit) 
              {
               highestProfit=profitMoney;
              }
           }
        }
     }
   return(profitMoney);
  }
//+------------------------------------------------------------------+

int pipsPL(int mg)
  {
   int p;
   p=0;
   for(i=OrdersTotal()-1; i>=0; i--) 
     {
      if(OrderSelect(i,SELECT_BY_POS)) 
        {
         if((OrderSymbol()==Symbol() && OrderMagicNumber()==mg)) 
           {
            double point=MarketInfo(OrderSymbol(),MODE_POINT);
            if(OrderType()==OP_BUY)
               p=(int)(0.1*(MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice())/point);
            if(OrderType()==OP_SELL)
               p=(int)(0.1*(OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))/point);
           }
        }
     }
   return(p);
  }
//+------------------------------------------------------------------+

void drawLabel(string objName,string objText,int fontSize2,string fontType,color textColor,int corner,int xp,int yp)
  {
   ObjectCreate(objName,OBJ_LABEL,0,0,0);
   ObjectSetText(objName,objText,fontSize2,fontType,textColor);
   ObjectSet(objName,OBJPROP_CORNER,corner);
   ObjectSet(objName,OBJPROP_XDISTANCE,xp);
   ObjectSet(objName,OBJPROP_YDISTANCE,yp);
  }
// status shown on screen

//+------------------------------------------------------------------+

void ShowStatus(string status="")
  {
   string AccountType="Standard";
   if(MarketInfo(Symbol(),MODE_MINLOT)<0.1) AccountType="Mini";
   if(IsDemo()) AccountType=AccountType+"/Demo";

   Comment("====================="+
           "\n Time   =  ",TimeToStr(TimeCurrent(),TIME_MINUTES)+
           "\n Price:  "+DoubleToStr(MarketInfo(OrderSymbol(),MODE_BID),4)+
           "\n Long Target:  "+DoubleToStr(longTarget,4)+
           "\n Short Target:  "+DoubleToStr(shortTarget,4)+
           "\n EMA4:  "+DoubleToStr(EMA4,4)+"   Prev EMA4:  "+DoubleToStr(prevEMA4,4)+
           "\n EMA15:  "+DoubleToStr(EMA15,4)+"   Prev EMA15:  "+DoubleToStr(prevEMA15,4)+
           "\n EMA30:  "+DoubleToStr(EMA30,4)+
           "\n EMA4to15:  "+DoubleToStr(EMA4to15,4)+
           "\n EMA15to30:  "+DoubleToStr(EMA15to30,4)+
           "\n DS1:  "+DoubleToStr(dS1,4)+"   DR1:  "+DoubleToStr(dR1,4)+
           "\n DS2:  "+DoubleToStr(dS2,4)+"   DR2:  "+DoubleToStr(dR2,4)+
           "\n DS3:  "+DoubleToStr(dS3,4)+"   DR3:  "+DoubleToStr(dR3,4)+
           "\n Trades Open:  "+IntegerToString(TradesOpen)+
           "\n Open Profit:  "+DoubleToStr(TradesOpenProfit,2)

           );
  }
//+------------------------------------------------------------------+

void ScreenComments()
  {
   drawLabel("NLD5","NLD 5min:   "+IntegerToString(trendM5),fontSize,"Times New Roman",White,1,20,140*ydist);
   drawLabel("NLD15","NLD 15min:   "+IntegerToString(trendM15),fontSize,"Times New Roman",White,1,20,160*ydist);
   drawLabel("paused","Trade Paused:   "+(string)(paused),fontSize,"Times New Roman",White,1,20,200*ydist);
   drawLabel("inTrade","In Trade:   "+(string)inTrade,fontSize,"Times New Roman",White,1,20,220*ydist);
   drawLabel("beyondR2S2","Beyond Weekly R2S2:   "+(string)beyondR2S2,fontSize,"Times New Roman",White,1,20,240*ydist);
   drawLabel("longs","Longs:   "+(string)wantLongs,fontSize,"Times New Roman",White,1,20,260*ydist);
   drawLabel("shorts","Shorts:   "+(string)wantShorts,fontSize,"Times New Roman",White,1,20,280*ydist);
   drawLabel("PtoEMA","Pips to EMA:   "+DoubleToStr(priceToEMA,1),fontSize,"Times New Roman",White,1,20,340*ydist);
   drawLabel("pip","Pips P/L:   "+DoubleToStr(pipsPL(magic),0),fontSize,"Times New Roman",White,1,20,360*ydist);

  }
//+------------------------------------------------------------------+
// Notifications for exiting trades
//
void beyondWeeklyR2S2()
  {
   drawLabel("Beyond1","Beyond Weekly R2S2 - trade closed",fontSize,"Times New Roman",White,1,20,20);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void priceTargetHit()
  {
   drawLabel("priceTarget","Priace target hit - trade closed",fontSize,"Times New Roman",White,1,20,20);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EMA4crossEMA15()
  {
   drawLabel("EMA4and15cross","EMA4 crossed EMA15 - trade closed",fontSize,"Times New Roman",White,1,20,20);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void price30EMA()
  {
   drawLabel("price30","price crossed 30EMA - trade closed",fontSize,"Times New Roman",White,1,20,20);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void priceDS3R3()
  {
   drawLabel("DS3R3","price crossed daily S3 or R3 - trade closed",fontSize,"Times New Roman",White,1,20,20);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void dailyS2R2NLD()
  {
   drawLabel("DS2R2","price crossed daily S2 or R2 and 5 min NLD change - trade closed",fontSize,"Times New Roman",White,1,20,20);
  }
// ------------------------------------------------------------------------------

void OrdersTotalInfo() 
  {
   TradesOpen=0; TradesOpenProfit=0;
   for(int OrdersOpenTotal=OrdersTotal()-1; OrdersOpenTotal>=0; OrdersOpenTotal--) 
     {
      if(OrderSelect(OrdersOpenTotal,SELECT_BY_POS,MODE_TRADES)==true) 
        {
         TradesOpen++;
         TradesOpenProfit+=OrderProfit()+OrderCommission()+OrderSwap();
        }
     }
  }
// ------------------------------------------------------------------------------

void breakEvenStopLoss() 
  {
   for(int j=0; j<OrdersTotal(); j++)
     {
      int order=OrderSelect(j,SELECT_BY_POS);
      if(OrderMagicNumber()!=magic || OrderSymbol()!=Symbol()) continue;

      if(OrderSymbol()==Symbol())
        {
         if((OrderType()==OP_BUY) || (OrderType()==OP_SELL)) 
           {
            double stoploss=0;

            if((OrderType()==OP_BUY) && (OrderStopLoss()<OrderOpenPrice()))
              {
               stoploss=OrderOpenPrice();
              }

            if((OrderType()==OP_SELL) && (OrderStopLoss()>OrderOpenPrice()))
              {
               stoploss=OrderOpenPrice();
              }

            if(stoploss!=0)
              {
               if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0)){};
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
