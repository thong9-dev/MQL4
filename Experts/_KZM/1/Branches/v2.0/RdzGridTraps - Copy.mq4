//+------------------------------------------------------------------+
//|                                                 RdzGridTraps.mq4 |
//|                                 Copyright 2015, Rdz Technologies |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Rdz Technologies"
#property link      "http://tunas-bangsa-camp.blogspot.com/"
#property version   "2.0"
#property strict
#property description "Developed by: Rdz (Radityo Ardi)"
#property description "NOTE:"
#property description "DYNAMIC GRID TRAP IS FREE AND LICENSED UNDER CHARITYWARE LICENSE STATED ON THE LINK ABOVE. ALL RIGHTS RESERVED."
#property description "ALTHOUGH IT'S FREE, I DEDICATE MY EFFORTS TO ALL PEOPLE IN THE WORLD, SUFFERING FOR HUNGER AND POOR."
#property description "AND FOR KIDS ALL OVER THE WORLD, STRUGGLING FOR EDUCATIONS."
#property description ""
#property description "PLEASE TAKE TIME TOR READ THIS LICENSE AGREEMENT."
#property description "https://sites.google.com/site/RdzCharitywareLicenseAgreement/"
#property icon "StocksiPhone.ico"

#include <stdlib.mqh>
#include "RdzGridTraps_Properties.mqh"
#include "RdzGridTraps_Enums.mqh"

input          enDateTimeType          DateTimeType               = DTTLocalTime; //Date and Time base
input          string                  DailyStartTime             = "01:00:00"; //Start Time (HH:mm:ss)
input          string                  DailyStopTime              = "23:00:00"; //Stop Time (HH:mm:ss)
input          enDayOfWeek             WeeklyStartDay             = DOWSunday; //Weekly Start Day
input          string                  WeeklyStartTime            = "00:00:00"; //Weekly Start Time (HH:mm:ss)
input          enDayOfWeek             WeeklyStopDay              = DOWSaturday; //Weekly Stop Day
input          string                  WeeklyStopTime             = "00:00:00"; //Weekly Stop Time (HH:mm:ss)
input          bool                    UseLineStartStop           = false; //Use Stop-Start from Vertical Line
input          string                  LineStartStopKeyword       = "GT"; //Stop-Start Line Keyword
input          enStopTimeMode          StopTimeMode               = STMNothing; //Stop Time Action
input          enOpenType              OpenType                   = OTDynamicRecreationAll; //Placing Order Type
input          enOrderOperation        OrderOperation             = StopOrders; //Order Operation
input          int                     OrderCountPerSide          = 2; //Grid Order Count (each side)
input          bool                    LimitMaxOrderCount         = false; //Enable Max Order
input          int                     MaxOrderCount              = 0; //Max Order Count (total)
input          int                     RecreationCountPerSide     = 1; //Grid Auto-Expand Count (each side)
input          int                     LimitOrdersCount           = 3; //Limit Grid Orders Count
input          int                     RecreationThreshold        = 50; //Auto-Expand Threshold (Points)
input          int                     GridStepPoints             = 50; //Grid Step (Points)
input          int                     CurrentPriceInterval       = 50; //Current Price Interval (Points)
input          int                     MagicNumber                = 8888; //Unique ID (Magic Number)
input          enClCalculationMode     RecalculationMode          = ClNoRecalculate; //Recalculation Mode
input          enDynamicBase           InitialLotsDynamicBase     = DBBalance; //Initial Lots Calculation Source
input          enInitialLotsType       InitialLotsType            = ILTDynamic; //Initial Lots Type
input          double                  InitialLots                = 0.01; //Initial Lots
input          double                  InitialLotsMult            = 0.0001;//Initial Lots Multiplier
input          string                  CommentInfo                = ""; //Comment Info
input          enProfitTakingMode      ProfitTakingMode           = PTMWithCommAndSwap; //Profit Taking Mode
input          enDynamicProfitBase     TargetProfitDynamicBase    = DPBBalance; //Target Profit Calculation Source
input          enTargetType            TargetType                 = TTDynamic; //Target Type
input          double                  TargetProfit               = 0.2; //Target Profit
input          double                  TargetProfitMult           = 0.004;//Target Profit Multiplier
input          enDynamicBase           StopLossDynamicBase        = DBBalance; //Stop Loss Calculation Source
input          enLossType              LossType                   = LTNone; //Loss Type
input          double                  StopLoss                   = -100; //Stop Loss
input          double                  StopLossMult               = -0.0001; //Stop Loss Multiplier
input          enCloseType             CloseType                  = CTStandard; //Close Type
input          int                     MiddlePointRange           = 5; // Middle Point Range (Points)
input          int                     CloseMiddlePointAftOrders  = 0; //Middle Point Activation (Order Count)
input          int                     MinProfitOrders            = 2; //Min Open Profit Orders
input          int                     CloseThreshold             = 50; //Close Threshold
input          enCloseDirection        CloseDirection             = CDInsideOut; //Order Closure Direction
input          bool                    EnableMaxCycle             = false; //Enable Max Cycle
input          int                     MaxCycle                   = 0; //Max Cycle
input          enCloseMode             CloseMode                  = CMInternal; //Close Mode
input          int                     CountRunningCloseEA        = 0; //Count of Running EA
input          bool                    CheckIsCorrupted           = false; //Check Corrupted
input          bool                    StopNextCycleOnLoss        = false; //Stop Next on Stop Loss
input          bool                    EnableNotification         = true; // Enable Notification


gtProperties                           Properties;

/*
               int                     BuyCount                   = 0;
               int                     SellCount                  = 0;
               int                     PendingBuyCount            = 0;
               int                     PendingSellCount           = 0;
               int                     AllOrdersCount             = 0;
               int                     HighestBuyCount            = 0;
               int                     HighestSellCount           = 0;
               int                     CycleCount                 = 0;
               bool                    AllPositiveProfit          = false;
               datetime                CurrentTime                = 0;
               datetime                DailyStartDateTime         = 0;
               datetime                DailyStopDateTime          = 0;
               datetime                WeeklyStartDateTime        = 0;
               datetime                WeeklyEndDateTime          = 0;
               double                  LastUpperPrice             = 0;
               double                  LastLowerPrice             = 0;
               double                  DyTargetProfit             = 0;
               int                     DyOrderCountPerSide        = 0;
               double                  DyStopLoss                 = 0;
               double                  DyStartingLots             = 0;
*/
               int                     btnLeftAxis                = 15;
               int                     btnTopAxis                 = 250;
               int                     btnInterval                = 25;
               int                     btnWidth                   = 90;
               int                     btnHeight                  = 20;
               color                   btnColor                   = clrCornflowerBlue;
               color                   btnPressedColor            = clrGray;
               
               color                   clrEnableTrading           = clrGreen;
               color                   clrDisableTrading          = clrRed;
               
               bool                    NoCorruptedCheck           = false;
               
               double                  TotalProfit                = 0;
               bool                    ActiveOrders               = false;
               string                  CrLf                       = "\n";
               string                  Space                      = " ";
               string                  CommentFormat              = "";
               double                  BiggestProfit              = 0;
               double                  LastProfit                 = 0;
               double                  LowestProfit               = 1.7976931348623158e+308;
               double                  LowestMarginAvailable      = 1.7976931348623158e+308;
               double                  LowestEquityAvailable      = 1.7976931348623158e+308;
               
               string                  GVStopNext                 = "";
               string                  GVFastCloseOrders          = "";
               string                  GVFastCloseProfit          = "";
               string                  ConstGVStopNext            = "GTSTOP";
               string                  ConstGVFastCloseOrders     = "GTFASTCLOSE";
               string                  ConstGVFastCloseProfit     = "GTPROFIT";
               string                  ConstGVFinished            = "GTExtClosed";
               string                  btnEnableTrading           = "btnEnableTrading";
               string                  btnForceCloseAll           = "btnForceCloseAll";
               string                  btnStartTrading            = "btnStartTrading";
               string                  lnMidUpperRange            = "lnMidUpperRange";
               string                  lnMidLowerRange            = "lnMidLowerRange";
               string                  lnBID                      = "lnBID";
               string                  lnASK                      = "lnASK";
               string                  lnUPPERPRICE               = "lnUPPERPRICE";
               string                  lnLOWERPRICE               = "lnLOWERPRICE";
               string                  lnUPPERTH                  = "lnUPPERTH";
               string                  lnLOWERTH                  = "lnLOWERTH";
               string                  btnStartManuallyText       = "Start Manually";
               string                  btnKeepGoingText           = "Continue";
               string                  btnStopNextCycleText       = "Stop Next Cycle";
               string                  btnForceCloseAllText       = "Force Close All";
               color                   DefaultButtonTextColor     = clrWhite;
               color                   DefaultButtonBgColor       = clrBlueViolet;
               enTimeExecutionCodeStatus TimeExCodeStatus         = TECSIdle;
               color                   clrPlaceBuy                = clrOrange;
               color                   clrPlaceSell               = clrBlue;
               color                   clrCloseProfit             = clrGreen;
               color                   clrCloseLoss               = clrRed;


int OnInit()
{
   if (!Properties.IsInitialized)
   {
      Properties.SymbolProperties.MaxLots = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), 2);
      Properties.SymbolProperties.MinLots = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), 2);
      Properties.SymbolProperties.LotsStep = NormalizeDouble(MarketInfo(Symbol(),MODE_LOTSTEP), 2);
   }
   Properties.SymbolProperties.Reset();
   
   GVStopNext = ConstGVStopNext + IntegerToString(MagicNumber);
   GVFastCloseOrders = ConstGVFastCloseOrders + IntegerToString(MagicNumber);
   GVFastCloseProfit = ConstGVFastCloseProfit + IntegerToString(MagicNumber);
   
   if (IsStopOnNextCycle())
   {
      DrawButton(btnEnableTrading, btnKeepGoingText, btnLeftAxis, btnTopAxis, -1, -1, true, clrDisableTrading);
   }
   else
   {
      DrawButton(btnEnableTrading, btnStopNextCycleText, btnLeftAxis, btnTopAxis, -1, -1, false, clrEnableTrading);
   }
   DrawButton(btnForceCloseAll, btnForceCloseAllText, btnLeftAxis, btnTopAxis + btnInterval);
   
   CalculateStartingLots();
   CalculateTargetProfit();
   CalculateStopLoss();

   //OnInitDetection(); //detect previous trading sessions in the case of shutting down EA

   EventSetMillisecondTimer(100); //setting timer for time recording
   Properties.IsInitialized = true;
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   DeleteButton(btnEnableTrading);
   DeleteButton(btnForceCloseAll);
   DeleteButton(btnStartTrading);
   EventKillTimer();
   
   PrintFormat("Deinit Reason: %s - %s", IntegerToString(reason), GetUninitReasonText(reason));
}
double OnTester()
{
   PrintFormat("BIGGEST PROFIT: %s", DoubleToString(BiggestProfit, 2));
   PrintFormat("LOWEST PROFIT: %s", DoubleToString(LowestProfit, 2));
   PrintFormat("LOWEST EQUITY: %s", DoubleToString(LowestEquityAvailable, 2));
   PrintFormat("LOWEST FREE MARGIN: %s", DoubleToString(LowestMarginAvailable, 2));
   PrintFormat("BUY: %s, SELL: %s", IntegerToString(Properties.Counter.OpenedBuys), IntegerToString(Properties.Counter.OpenedSells));
   PrintFormat("HIGHEST OPENED: %s", IntegerToString(Properties.Counter.HighestOpened));
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
      string clickedObject = sparam;
      if (clickedObject == btnEnableTrading) //Stop Next Cycle
      {
         bool selected = ObjectGetInteger(ChartID(), btnEnableTrading, OBJPROP_STATE);
         if (selected)
         {
            SetButtonColor(btnEnableTrading, clrDisableTrading);
         }
         if (IsStopOnNextCycle())
         {
            SetButtonText(btnEnableTrading, btnStopNextCycleText);
            SetButtonColor(btnEnableTrading, clrEnableTrading, DefaultButtonTextColor);
            SetStopNext(false);
            SetComments();
         }
         else
         {
            SetButtonText(btnEnableTrading, btnKeepGoingText);
            SetButtonColor(btnEnableTrading, clrDisableTrading);
            SetStopNext(true);
            SetComments();
         }
      }
      else if (clickedObject == btnForceCloseAll) //Force Close All
      {
         bool selected = ObjectGetInteger(ChartID(), btnForceCloseAll, OBJPROP_STATE);
         if (selected)
         {
            SetButtonColor(btnEnableTrading, clrGray);
            if (CloseMode == CMInternal)
            {
               CloseOrders();
            }
            else if (CloseMode == CMExtended)
            {
               CloseOrdersFast();
            }
            ResetOnClose();
            SetComments();
            SetButtonColor(btnEnableTrading, DefaultButtonBgColor, DefaultButtonTextColor);
            PressButton(btnForceCloseAll); //to return the press
         }
      }
      else if (clickedObject == btnStartTrading)
      {
         CreateOrders();
      }
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   bool InTimeRange = false;
   CountStartEndTime();
   CalculateWeeklyStartEndTime(Properties.DateTimeInfo.Current);
   CheckOrders();

   InTimeRange = Properties.DateTimeInfo.IsInTimeWindow();
   if (TimeExCodeStatus == TECSIdle && InTimeRange)
   {
      TimeExCodeStatus = TECSInTimeRangeExtd;
   } else if (TimeExCodeStatus == TECSIdle && !InTimeRange)
   {
      TimeExCodeStatus = TECSOutOfTimeRangeExtd;
   } else if (TimeExCodeStatus == TECSInTimeRangeExtd && !InTimeRange)
   {
      TimeExCodeStatus = TECSOutOfTimeRangeWaitEx;
   } else if (TimeExCodeStatus == TECSOutOfTimeRangeExtd && InTimeRange)
   {
      BeforeOnInsideTimeRange();
      TimeExCodeStatus = TECSInTimeRangeWaitEx;
   } else if (TimeExCodeStatus == TECSOutOfTimeRangeExtd && !InTimeRange && ActiveOrders)
   {
      TimeExCodeStatus = TECSOutOfTimeRangeInactiveWaitEx;
   }
   
   
   if (IsTimeToRecreate() && (OpenType == OTDynamicRecreationAll || OpenType == OTDynamicRecreationThreshold))
   {
      CreateOrders();
   }
   
   SetComments();
   
   if (
         (
            (IsTimeToClose()) ||
            (StopTimeMode == STMForceCloseAll && TimeExCodeStatus == TECSOutOfTimeRangeWaitEx) ||
            (StopTimeMode == STMForceCloseNoOpenOrder && (Properties.Counter.OpenedOrders()) == 0 && TimeExCodeStatus == TECSOutOfTimeRangeWaitEx) ||
            (StopTimeMode == STMForceCloseProfit && TotalProfit > 0 && TimeExCodeStatus == TECSOutOfTimeRangeWaitEx)
         )
      && (!CheckIsCorrupted || (CheckIsCorrupted && IsCorrupted()))) //if (IsTimeToClose() && (!CheckIsCorrupted || (CheckIsCorrupted && IsCorrupted())))
   {
      if (CloseMode == CMInternal)
      {
         CloseOrders();
      }
      else if (CloseMode == CMExtended)
      {
         CloseOrdersFast();
      }
      ResetOnClose();
      
   }
   
   if (!ActiveOrders && !IsStopOnNextCycle() && InTimeRange && (!EnableMaxCycle || (EnableMaxCycle && Properties.Counter.CurrentCycle < MaxCycle)))
   {
      CreateOrders();
   }
   
   
   if (!ActiveOrders)
   {
      DrawButton(btnStartTrading, btnStartManuallyText, btnLeftAxis, btnTopAxis + (btnInterval * 2));
   }
   else
   {
      DeleteButton(btnStartTrading);
   }
   
   if (TimeExCodeStatus == TECSInTimeRangeWaitEx && InTimeRange)
   {
      OnInsideTimeRange();
      TimeExCodeStatus = TECSInTimeRangeExtd;
   }
   else if (TimeExCodeStatus == TECSOutOfTimeRangeWaitEx && !InTimeRange)
   {
      OnOutsideTimeRange();
      TimeExCodeStatus = TECSOutOfTimeRangeExtd;
      if (!ActiveOrders)
      {
         OnOutsideTimeRangeInactive();
      }
   } else if (TimeExCodeStatus == TECSOutOfTimeRangeInactiveWaitEx && !InTimeRange)
   {
      if (!ActiveOrders)
      {
         OnOutsideTimeRangeInactive();
      }
      TimeExCodeStatus = TECSOutOfTimeRangeExtd;
   }
   
   SetComments();
}
//+------------------------------------------------------------------+
void BeforeOnInsideTimeRange()
{
   Properties.Counter.CurrentCycle = 0; //resetting the Cycle before OnInsideTimeRange executed.
}
void OnInsideTimeRange()
{
}
void OnOutsideTimeRange()
{
}
void OnOutsideTimeRangeInactive()
{
}

void OnTimer()
{
   //this method will not be called on backtesting
   SetComments();
}
void CalculateStartingLots()
{
   if (InitialLotsType == ILTDynamic)
   {
      double BaseCalc = 0;
      if (InitialLotsDynamicBase == DBBalance)
      {
         BaseCalc = AccountBalance();
      }
      else if (InitialLotsDynamicBase == DBEquity)
      {
         BaseCalc = AccountEquity();
      }
      
      if (BaseCalc > 0)
      {
         if (Properties.SymbolProperties.LotsStep == 0.01) //standard Lot size increment
         {
            Properties.InitialLots = NormalizeDouble(BaseCalc * InitialLotsMult, 2);
         }
         else
         {
            double _dyStLots = NormalizeDouble(BaseCalc * InitialLotsMult, 2);
            Properties.InitialLots = NormalizeDouble(_dyStLots - MathMod(_dyStLots, Properties.SymbolProperties.LotsStep), 2);
         }
      }
      else
      {
         Properties.InitialLots = Properties.SymbolProperties.MinLots;
      }
   }
   else
   {
      Properties.InitialLots = NormalizeDouble(InitialLots, 2);
   }
   
   if (Properties.InitialLots < Properties.SymbolProperties.MinLots) Properties.InitialLots = Properties.SymbolProperties.MinLots;
   if (Properties.InitialLots > Properties.SymbolProperties.MaxLots) Properties.InitialLots = Properties.SymbolProperties.MaxLots;
}

void CalculateTargetProfit()
{
   if (TargetType == TTDynamic)
   {
      double BaseCalc = 0;
      if (TargetProfitDynamicBase == DPBBalance)
      {
         BaseCalc = AccountBalance();
      }
      else if (TargetProfitDynamicBase == DPBEquity)
      {
         BaseCalc = AccountEquity();
      }
      else if (TargetProfitDynamicBase == DPBLotSize)
      {
         BaseCalc = Properties.InitialLots;
      }
      
      if (BaseCalc > 0)
      {
         Properties.TargetProfit = BaseCalc * TargetProfitMult;
      }
   }
}
void RecalculateTargetProfit()
{
   if (RecalculationMode == ClAllRecalculate)
   {
      CalculateTargetProfit();
   }
}

void CalculateStopLoss()
{
   if (LossType == LTDynamic)
   {
      double BaseCalc = 0;
      if (StopLossDynamicBase == DBBalance)
      {
         BaseCalc = AccountBalance();
      }
      else if (StopLossDynamicBase == DBEquity)
      {
         BaseCalc = AccountEquity();
      }

      if (BaseCalc > 0)
      {
         Properties.StopLoss = BaseCalc * StopLossMult;
      }
   }
}
void RecalculateStopLoss()
{
   if (RecalculationMode == ClAllRecalculate)
   {
      CalculateStopLoss();
   }
}

void CreateOrders()
{
   NoCorruptedCheck = true;
   bool InitialCreation = false;
   double CurrentUpperPrice = 0;
   double CurrentLowerPrice = 0;
   double AskTH = 0, BidTH = 0;
   int CreationCount = 0;
   
   if (IsStartOfCycle()) //First Cycle creation
   {
      InitialCreation = true;
      RefreshRates();
      CurrentUpperPrice = Ask;
      CurrentLowerPrice = Bid;
      
      DrawLine(lnASK, Ask, clrRed, 1, STYLE_DOT);
      DrawLine(lnBID, Bid, clrGray, 1, STYLE_DOT);

      AskTH = AddPoints(Ask, MiddlePointRange);
      BidTH = AddPoints(Bid, 0 - MiddlePointRange);

      DrawLine(lnMidUpperRange, AskTH, clrBlue, 1, STYLE_DOT);
      DrawLine(lnMidLowerRange, BidTH, clrBlue, 1, STYLE_DOT);
      
      CurrentUpperPrice = AddPoints(CurrentUpperPrice, CurrentPriceInterval);
      CurrentLowerPrice = AddPoints(CurrentLowerPrice, 0 - CurrentPriceInterval);
      
      Properties.OrderCountPerSide = OrderCountPerSide;
      CreationCount = OrderCountPerSide;
      
      CalculateTargetProfit();
      CalculateStopLoss();
      
      CalculateStartingLots();
   }
   else if (Properties.Prices.Last.LowerPrice > 0 && Properties.Prices.Last.UpperPrice > 0 && OpenType != OTFixedOrder) //subsequent recreation
   {
      CurrentUpperPrice = Properties.Prices.Last.UpperPrice;
      CurrentLowerPrice = Properties.Prices.Last.LowerPrice;
      
      Properties.OrderCountPerSide += RecreationCountPerSide;
      CreationCount = RecreationCountPerSide;
   }
   
   for(int i = 0; i < CreationCount; i++)
   {
      if (LimitMaxOrderCount && Properties.Counter.AllOrders() >= MaxOrderCount) break;
      if (i == 0) ActiveOrders = true;
      
      double PriceTP = 0; double PriceSL = 0; int slp = 0;
      
      int Chk = 0;
      if (OrderOperation == StopOrders || (OrderOperation == FewLimitOrders && Properties.Counter.AllOrders() >= LimitOrdersCount))
      {
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_BUYSTOP, Properties.InitialLots, CurrentUpperPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber, 0, clrPlaceBuy);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(Properties.InitialLots, 2), DoubleToString(CurrentUpperPrice, Digits)));
         else
         {
            Properties.Counter.PendingBuys += 1;
         }
         
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_SELLSTOP, Properties.InitialLots, CurrentLowerPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber, 0, clrPlaceSell);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(Properties.InitialLots, 2), DoubleToString(CurrentLowerPrice, Digits)));
         else
         {
            Properties.Counter.PendingSells += 1;
         }
      }
      else if (OrderOperation == LimitOrders || (OrderOperation == FewLimitOrders && i < LimitOrdersCount))
      {
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_SELLLIMIT, Properties.InitialLots, CurrentUpperPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber, 0, clrPlaceSell);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(Properties.InitialLots, 2), DoubleToString(CurrentUpperPrice, Digits)));
         else
         {
            Properties.Counter.PendingSells += 1;
         }

         Chk = 0;
         Chk = OrderSend(Symbol(), OP_BUYLIMIT, Properties.InitialLots, CurrentLowerPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber, 0, clrPlaceBuy);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(Properties.InitialLots, 2), DoubleToString(CurrentLowerPrice, Digits)));
         else
         {
            Properties.Counter.PendingBuys += 1;
         }
      }
      
      
      CurrentUpperPrice = AddPoints(CurrentUpperPrice, GridStepPoints);
      CurrentLowerPrice = AddPoints(CurrentLowerPrice, 0 - GridStepPoints);
      
      Properties.Prices.Last.UpperPrice = CurrentUpperPrice;
      Properties.Prices.Last.LowerPrice = CurrentLowerPrice;
   }
   
   DrawLine(lnUPPERPRICE, Properties.Prices.Last.UpperPrice, clrYellow, 1, STYLE_DOT);
   DrawLine(lnLOWERPRICE, Properties.Prices.Last.LowerPrice, clrYellow, 1, STYLE_DOT);
   
   NoCorruptedCheck = false;
   
   if (InitialCreation)
   {
      Properties.Counter.CurrentCycle += 1;
   }
}

bool IsTimeToClose()
{
   bool IsTime = false;
   
   if (ActiveOrders)
   {
      RefreshRates();
      double MUpperRange = 0;
      double MLowerRange = 0;
      MUpperRange = GetLinePrice(lnMidUpperRange);
      MLowerRange = GetLinePrice(lnMidLowerRange);
      
      bool IsTargetReached = ((TotalProfit >= TargetProfit && TargetType == TTFixed) || (TotalProfit >= Properties.TargetProfit && TargetType == TTDynamic));
      bool IsLossAccepted = ((LossType == LTFixed && TotalProfit <= StopLoss && StopLoss < 0) || (LossType == LTDynamic && TotalProfit <= Properties.StopLoss && Properties.StopLoss < 0));
      bool IsInMiddlePoint = (Ask <= MUpperRange && Bid >= MLowerRange);
      bool IsMidPointActivated = ((Properties.Counter.OpenedOrders() >= CloseMiddlePointAftOrders && CloseMiddlePointAftOrders > 0) || CloseMiddlePointAftOrders <= 0);
      bool IsProfitMaxOrderActivated = ((Properties.Counter.OpenedOrders() >= MinProfitOrders && MinProfitOrders > 0) || MinProfitOrders <= 0);
      bool IsReachingThreshold = (AddPoints(Properties.Prices.Last.UpperPrice, 0 - GridStepPoints - CloseThreshold) <= Ask || AddPoints(Properties.Prices.Last.LowerPrice, GridStepPoints + CloseThreshold) > Bid);
      
      if (
         (CloseType == CTMiddlePoint && (
            IsTargetReached || IsLossAccepted || (IsInMiddlePoint && IsMidPointActivated && Properties.Checker.InProfit)))
         ||
         (CloseType == CTThresholdMiddlePoint && (
            IsTargetReached || IsLossAccepted || IsReachingThreshold || (IsInMiddlePoint && IsMidPointActivated && Properties.Checker.InProfit)))
         ||
         (CloseType == CTProfitMinOrders && (
            IsTargetReached || IsLossAccepted || (IsProfitMaxOrderActivated && Properties.Checker.InProfit)))
         ||
         (CloseType == CTStandard && (
            IsTargetReached || IsLossAccepted))
         ||
         (CloseType == CTAllOrdersExecuted && (
            IsTargetReached || IsLossAccepted || (Properties.Counter.SameOpened() && Properties.Counter.OpenedBuys > 0 && Properties.Counter.OpenedBuys == Properties.OrderCountPerSide)))
         ||
         (CloseType == CTThreshold && (
            IsTargetReached || IsLossAccepted || IsReachingThreshold))
         ||
         (CloseType == CTThresholdAllOrdersExtd && (
            IsTargetReached || IsLossAccepted || IsReachingThreshold || (Properties.Counter.SameOpened() && Properties.Counter.OpenedBuys > 0 && Properties.Counter.OpenedBuys == Properties.OrderCountPerSide)))
      )
      {
         IsTime = true;
      }
      
      if (StopNextCycleOnLoss && IsLossAccepted && IsTime)
      {
         SetStopNext(true);
      }
   }
   
   return IsTime;
}

bool IsStartOfCycle()
{
   return Properties.Prices.Last.IsEmpty();
}

/*
bool IsInTimeRange(string TimeInformation, int AddRange = -1) //obsolete
{
   datetime Current = 0;
   if (DateTimeType == DTTLocalTime)
   {
      Current = TimeLocal();
   }
   else if (DateTimeType == DTTServerTime)
   {
      Current = TimeCurrent();
   }
   else if (DateTimeType == DTTGMTTime)
   {
      Current = TimeGMT();
   }
   if (AddRange == -1) AddRange = 30;
   
   datetime ConfiguredTimeA = 0;
   datetime ConfiguredTimeB = 0;
   ConfiguredTimeA = StringToTime(IntegerToString(TimeYear(Current)) + "." + IntegerToString(TimeMonth(Current)) + "." + IntegerToString(TimeDay(Current)) + " " + TimeInformation);
   ConfiguredTimeB = ConfiguredTimeA + AddRange;
   return (ConfiguredTimeA <= CurrentTime && CurrentTime <= ConfiguredTimeB);
}
*/

bool IsTimeToRecreate()
{
   bool IsTime = false;
   RefreshRates();

   if (ActiveOrders)
   {
      if (Properties.Counter.SameOpened() && Properties.Counter.OpenedBuys > 0 && Properties.Counter.OpenedBuys == Properties.OrderCountPerSide && OpenType == OTDynamicRecreationAll) //dynamic recreation all
      {
         IsTime = true;
      }
      else if (OpenType == OTDynamicRecreationThreshold && CloseType != CTThreshold
         && ((AddPoints(Properties.Prices.Last.UpperPrice, 0 - GridStepPoints - RecreationThreshold)) <= Ask || AddPoints(Properties.Prices.Last.LowerPrice, GridStepPoints + RecreationThreshold) > Bid))
      {
         IsTime = true;
      }
   }
   return IsTime;
}

void CheckOrders()
{
   Properties.Counter.ResetOrderCounter();

   TotalProfit = 0;
   
   double tUpperPrice = 0;
   double tLowerPrice = 0;
   double tAsk = 0;
   double tBid = 0;
   bool IsUpperLowerUndefined = false;
   
   tUpperPrice = GetLinePrice(lnUPPERPRICE);
   tLowerPrice = GetLinePrice(lnLOWERPRICE);
   
   IsUpperLowerUndefined = (tUpperPrice <= 0 && tLowerPrice <= 0);
   
   ActiveOrders = false;
   Properties.Checker.InProfit = true;
   
   for (int i = OrdersTotal(); i >= 0; i--)
   {
      int Chk = 0;
      Chk = OrderSelect(i, SELECT_BY_POS);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         ActiveOrders = true;

         double Profit = GetProfit();
         TotalProfit += Profit;
         
         
         int OrdType = OrderType();
         if (OrdType == OP_BUY)
         {
            Properties.Counter.OpenedBuys += 1;
            if (Profit <= 0) Properties.Checker.InProfit = false;
         }
         else if (OrdType == OP_SELL)
         {
            Properties.Counter.OpenedSells += 1;
            if (Profit <= 0) Properties.Checker.InProfit = false;
         }
         else if (OrdType == OP_BUYLIMIT || OrdType == OP_BUYSTOP)
         {
            Properties.Counter.PendingBuys += 1;
         }
         else if (OrdType == OP_SELLLIMIT || OrdType == OP_SELLSTOP)
         {
            Properties.Counter.PendingSells += 1;
         }
         
         if (Properties.Counter.HighestOpened < Properties.Counter.OpenedOrders())
         {
            Properties.Counter.HighestOpened = Properties.Counter.OpenedOrders();
         }
         
         if (IsUpperLowerUndefined)
         {
            //below is the detection of upper and lower price
            if (tUpperPrice <= 0 || (tUpperPrice > 0 && tUpperPrice <= OrderOpenPrice()))
               tUpperPrice = AddPoints(OrderOpenPrice(), GridStepPoints);
            if (tLowerPrice <= 0 || (tLowerPrice > 0 && tLowerPrice >= OrderOpenPrice()))
               tLowerPrice = AddPoints(OrderOpenPrice(), 0 - GridStepPoints);
         }
      }
   }
   
   if (ActiveOrders)
   {
      if (tUpperPrice > 0) Properties.Prices.Last.UpperPrice = tUpperPrice;
      if (tLowerPrice > 0) Properties.Prices.Last.LowerPrice = tLowerPrice;
   }
   
   if (IsUpperLowerUndefined)
   {
      DrawLine(lnUPPERPRICE, Properties.Prices.Last.UpperPrice, clrYellow, 1, STYLE_DOT);
      DrawLine(lnLOWERPRICE, Properties.Prices.Last.LowerPrice, clrYellow, 1, STYLE_DOT);
      
      int Buys = 0;
      int Sells = 0;
      Buys = Properties.Counter.AllBuyOrders();
      Sells = Properties.Counter.AllSellOrders();
      
      if ((Buys == Sells) || (Buys != Sells && Buys > Sells))
      {
         Properties.OrderCountPerSide = Buys;
      }
      else if (Buys != Sells && Sells > Buys)
      {
         Properties.OrderCountPerSide = Sells;
      }
   }
   
   if (Properties.Counter.SameOpened() && Properties.Counter.OpenedBuys == 0)
      Properties.Checker.InProfit = false;
   
   if (AccountFreeMargin() < LowestMarginAvailable) LowestMarginAvailable = AccountFreeMargin();
   if (AccountEquity() < LowestEquityAvailable) LowestEquityAvailable = AccountEquity();

   RecalculateTargetProfit();
   RecalculateStopLoss();   
   
   if (ActiveOrders && OpenType == OTDynamicRecreationThreshold && CloseType != CTThreshold)
   {
      double UpperTHPrice = 0;
      double LowerTHPrice = 0;
      UpperTHPrice = AddPoints(Properties.Prices.Last.UpperPrice, 0 - GridStepPoints - RecreationThreshold);
      LowerTHPrice = AddPoints(Properties.Prices.Last.LowerPrice, GridStepPoints + RecreationThreshold);
      
      if (UpperTHPrice > 0)
         DrawLine(lnUPPERTH, UpperTHPrice, clrYellow, 1, STYLE_DASH);
      if (LowerTHPrice > 0)
         DrawLine(lnLOWERTH, LowerTHPrice, clrYellow, 1, STYLE_DASH);
   }
   else if (ActiveOrders && OpenType != OTDynamicRecreationThreshold && OpenType != OTDynamicRecreationAll && (CloseType == CTThreshold || CloseType == CTThresholdMiddlePoint || CloseType == CTThresholdAllOrdersExtd))
   {
      double UpperTHPrice = 0;
      double LowerTHPrice = 0;
      
      UpperTHPrice = AddPoints(Properties.Prices.Last.UpperPrice, 0 - GridStepPoints - CloseThreshold);
      LowerTHPrice = AddPoints(Properties.Prices.Last.LowerPrice, GridStepPoints + CloseThreshold);
      
      if (UpperTHPrice > 0)
         DrawLine(lnUPPERTH, UpperTHPrice, clrDarkGreen, 1, STYLE_DASH);
      if (LowerTHPrice > 0)
         DrawLine(lnLOWERTH, LowerTHPrice, clrDarkGreen, 1, STYLE_DASH);
   }
   else   
   {
      DeleteLine(lnUPPERTH);
      DeleteLine(lnLOWERTH);
   }
}

bool IsStopOnNextCycle()
{
   bool IsStop = false;
   if (GlobalVariableCheck(GVStopNext))
   {
      if (GlobalVariableGet(GVStopNext) > 0)
         IsStop = true;
   }
   return IsStop;
}

void SetStopNext(bool Enable)
{
   if (Enable)
      GlobalVariableSet(GVStopNext, 1);
   else if (!Enable)
      GlobalVariableSet(GVStopNext, 0);
}

bool IsCorrupted()
{
   bool IsCor = true;
   if (!NoCorruptedCheck)
   {
      if (Properties.Counter.AllSellOrders() == Properties.Counter.AllBuyOrders())
      {
         IsCor = false;
      }
   }
   
   return IsCor;
}
void ResetCycle()
{
   Properties.Counter.CurrentCycle = 0;
}
void ResetOnClose()
{
   Properties.Counter.ResetOrderCounter();
   
   Properties.Prices.Last.Reset();
   
   Properties.OrderCountPerSide = 0;
   Properties.TargetProfit = 0;
   ActiveOrders = false;
   Properties.Checker.InProfit = false;
   DeleteLine(lnBID);
   DeleteLine(lnASK);
   DeleteLine(lnUPPERPRICE);
   DeleteLine(lnLOWERPRICE);
   DeleteLine(lnMidLowerRange);
   DeleteLine(lnMidUpperRange);
}

void CloseOrdersFast()
{
   GlobalVariableSet(GVFastCloseOrders, 1);
   GlobalVariableSet(GVFastCloseProfit, 0);
   /*
   enStatusExtendedClose Status = STNotStarted;
   Status = AllExtCloseFinished();
   
   while(Status != STError || Status != STClosed)
   {
      Status = AllExtCloseFinished();
   }
   */
}

enStatusExtendedClose AllExtCloseFinished()
{
   enStatusExtendedClose MainStatus = STNotStarted;
   enStatusExtendedClose EAStatus[];
   ArrayResize(EAStatus, CountRunningCloseEA, CountRunningCloseEA);
   
   for(int i = 0; i < CountRunningCloseEA; i++)
   {
      string GVFinishedName = ConstGVFinished + IntegerToString(i + 1);
      
      if (GlobalVariableCheck(GVFinishedName))
      {
         EAStatus[i] = (enStatusExtendedClose)GlobalVariableGet(GVFinishedName);
      }
      if (EAStatus[i] == STError) MainStatus = EAStatus[i];
   }
   return MainStatus;
}

void CloseOrders(enCloseOrdersMode CloseOrdersMode = COMDefault)
{
   NoCorruptedCheck = true;

   if (CloseDirection == CDOutsideIn)
   {
      do
      {
         CloseOrdersOutsideIn(CloseOrdersMode);
         UpdateActiveOrders();
      } while (ActiveOrders);
   }
   else if (CloseDirection == CDInsideOut)
   {
      do
      {
         CloseOrdersInsideOut(CloseOrdersMode);
         UpdateActiveOrders();
      } while (ActiveOrders);
   }
   
   //CycleCount += 1; //cycle count will always adding regardless of its condition. The event will reset it once it goes inside the timerange for the first time.
   /*
   if ((IsInTimeRange(DailyStopTime) && ActiveOrders) || !IsInStartTimeRange())
   {
      CycleCount = 0;
   }
   else
   {
      CycleCount += 1;
   }
   */
   
   LastProfit = TotalProfit;
   if (TotalProfit > BiggestProfit || BiggestProfit == 0) BiggestProfit = TotalProfit;
   if (TotalProfit < LowestProfit || LowestProfit > AccountBalance()) LowestProfit = TotalProfit;
   if (EnableNotification)
   {
      string NotificationMsg = StringFormat("[RdzGridTraps] %s: %s%s (%s - %s)",
         (TotalProfit >= 0 ? "PROFIT" : "LOSS"),
         AccountCurrency(),
         DoubleToString(TotalProfit, 2),
         AccountCompany(),
         IntegerToString(AccountNumber())
      );
      Print(NotificationMsg);
      SendNotification(NotificationMsg);
   }
   TotalProfit = 0;
   NoCorruptedCheck = false;
}

void UpdateActiveOrders()
{
   ActiveOrders = false;
   for (int i = OrdersTotal(); i >= 0; i--)
   {
      int Chk = 0;
      RefreshRates();
      Chk = OrderSelect(i, SELECT_BY_POS);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         ActiveOrders = true;
      }
   }
}
void CloseOrdersOutsideIn(enCloseOrdersMode CloseOrdersMode = COMDefault)
{
   //Close Open Orders First, positive ones
   for (int i = OrdersTotal(); i >= 0; i--)
   {
      int Chk = 0;
      RefreshRates();
      Chk = OrderSelect(i, SELECT_BY_POS);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         double _TotalProfit = GetProfit();
         if (_TotalProfit > 0)
         {
            if (OrderType() == OP_BUY)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrCloseProfit);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrCloseProfit);
            }
            
            if (Chk > 0)
               TotalProfit += _TotalProfit;
               
         }
      }
   }

   //Close Open Orders First, negative ones
   for (int i = OrdersTotal(); i >= 0; i--)
   {
      int Chk = 0;
      RefreshRates();
      Chk = OrderSelect(i, SELECT_BY_POS);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         double _TotalProfit = GetProfit();
         if (_TotalProfit <= 0)
         {
            if (OrderType() == OP_BUY)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrCloseLoss);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrCloseLoss);
            }
            
            if (Chk > 0)
               TotalProfit += _TotalProfit;
               
         }
      }
   }
      
   //Delete Pending Orders
   for (int i = OrdersTotal(); i >= 0; i--)
   {
      int Chk = 0;
      RefreshRates();
      Chk = OrderSelect(i, SELECT_BY_POS);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         double _TotalProfit = GetProfit();
         if (OrderType() == OP_BUY)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0, (_TotalProfit > 0 ? clrCloseProfit : clrCloseLoss));
         }
         else if (OrderType() == OP_SELL)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0, (_TotalProfit > 0 ? clrCloseProfit : clrCloseLoss));
         }
         else if (OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)
         {
            Chk = OrderDelete(OrderTicket());
         }
         
         if (Chk > 0)
            TotalProfit += GetProfit();

      }
   }
}

void CloseOrdersInsideOut(enCloseOrdersMode CloseOrdersMode = COMDefault)
{
   int ordticket[];
   int oTotal = OrdersTotal();
   if (oTotal > 0)
   {
      ArrayResize(ordticket, oTotal, 1000);
      for (int i = 0; i < OrdersTotal(); i++)
      {
         int Chk = 0;
         RefreshRates();
         Chk = OrderSelect(i, SELECT_BY_POS);
         if (Chk > 0 && OrderMagicNumber() == MagicNumber)
         {
            ordticket[i] = OrderTicket();
         }
      }
      
      ArraySort(ordticket);
   }
      
   //Close Open Orders First, positive position
   for (int i = 0; i < ArraySize(ordticket); i++)
   {
      int Chk = 0;
      RefreshRates();
      Chk = OrderSelect(ordticket[i], SELECT_BY_TICKET);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         double _TotalProfit = GetProfit();
         if (_TotalProfit > 0)
         {
            if (OrderType() == OP_BUY)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrCloseProfit);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrCloseProfit);
            }
            
            if (Chk > 0)
               TotalProfit += _TotalProfit;
               
         }
      }
   }
   //Close Open Orders First, negative position
   for (int i = 0; i < ArraySize(ordticket); i++)
   {
      int Chk = 0;
      RefreshRates();
      Chk = OrderSelect(ordticket[i], SELECT_BY_TICKET);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         double _TotalProfit = GetProfit();
         if (_TotalProfit <= 0)
         {
            if (OrderType() == OP_BUY)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrCloseLoss);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrCloseLoss);
            }
            
            if (Chk > 0)
               TotalProfit += _TotalProfit;
               
         }
      }
   }
   //Delete All Remaining Orders
   for (int i = 0; i < ArraySize(ordticket); i++)
   {
      int Chk = 0;
      RefreshRates();
      Chk = OrderSelect(ordticket[i], SELECT_BY_TICKET);
      if (Chk > 0 && OrderMagicNumber() == MagicNumber)
      {
         double _TotalProfit = GetProfit();
         
         if (OrderType() == OP_BUY)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0, (_TotalProfit > 0 ? clrCloseProfit : clrCloseLoss));
         }
         else if (OrderType() == OP_SELL)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0, (_TotalProfit > 0 ? clrCloseProfit : clrCloseLoss));
         }
         else if (OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT)
         {
            Chk = OrderDelete(OrderTicket());
         }
         
         if (Chk > 0)
            TotalProfit += GetProfit();

      }
   }
}

double AddPoints(double Price, int PointsAdded)
{
   double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   return Price + (TickSize * PointsAdded);
}

string StringAddMultiple(string Str, int Multiplication)
{
   string FinalString = "";
   for(int i = 0; i < Multiplication; i++)
   {
      FinalString += Str;
   }
   return FinalString;
}

void CountStartEndTime()
{
   datetime AnchorTime = 0;
   int OneDay = 86400;
   if (DateTimeType == DTTLocalTime)
   {
      Properties.DateTimeInfo.Current = TimeLocal();
   }
   else if (DateTimeType == DTTServerTime)
   {
      Properties.DateTimeInfo.Current = TimeCurrent();
   }
   else if (DateTimeType == DTTGMTTime)
   {
      Properties.DateTimeInfo.Current = TimeGMT();
   }
   AnchorTime = Properties.DateTimeInfo.Current;
   Properties.DateTimeInfo.DailyStart = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + DailyStartTime);
   
   Properties.DateTimeInfo.DailyStop = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + DailyStopTime);
   if (Properties.DateTimeInfo.DailyStop <= Properties.DateTimeInfo.DailyStart && Properties.DateTimeInfo.DailyStop <= Properties.DateTimeInfo.Current)
      Properties.DateTimeInfo.DailyStop += OneDay; //adds 1 day.
}

void CalculateWeeklyStartEndTime(datetime AnchorTime)
{
   int OneDay = 86400;
   Properties.DateTimeInfo.WeeklyStart = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + WeeklyStartTime);
   Properties.DateTimeInfo.WeeklyEnd = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + WeeklyStopTime);
   while (TimeDayOfWeek(Properties.DateTimeInfo.WeeklyStart) != WeeklyStartDay)
   {
      Properties.DateTimeInfo.WeeklyStart += OneDay;
      
      //your statement here
   }
   while (TimeDayOfWeek(Properties.DateTimeInfo.WeeklyEnd) != WeeklyStopDay)
   {
      Properties.DateTimeInfo.WeeklyEnd += OneDay;
      
      //your statement here
   }
}


void SetComments()
{
   string Cmt = "";
   string Spacer = StringAddMultiple(Space, 40);
   double Balance = AccountBalance();
   string Currency = AccountCurrency();
   double MaxLots = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), 2);
   double MinLots = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), 2);
   double LotsStep = NormalizeDouble(MarketInfo(Symbol(),MODE_LOTSTEP), 2);
   if (!ActiveOrders) Spacer = "";
   
   if (StringLen(CommentInfo) > 0)
   {
      Cmt += Spacer + StringFormat("INFO: %s", CommentInfo) + CrLf;
   }
   Cmt += Spacer + StringFormat("%s%s%s%s",
      IntegerToString(MagicNumber) + " - ",
      (ActiveOrders ? "ACTIVE" : "INACTIVE"),
      (IsStopOnNextCycle() ? " - STOP NEXT" : ""),
      (Properties.DateTimeInfo.IsInTimeWindow() ? " - IN TIMERANGE" : "")
      ) + CrLf;
      
   Cmt += Spacer + StringFormat("[PENDING SELL: %s, BUY: %s] [OPEN SELL: %s, BUY: %s]",
      IntegerToString(Properties.Counter.PendingSells),
      IntegerToString(Properties.Counter.PendingBuys),
      IntegerToString(Properties.Counter.OpenedSells),
      IntegerToString(Properties.Counter.OpenedBuys)
      ) + CrLf;
      
   Cmt += Spacer + StringFormat("CP: %s %s", DoubleToString(TotalProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LastP: %s %s", DoubleToString(LastProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("BP: %s %s", DoubleToString(BiggestProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowP: %s %s", DoubleToString((LowestProfit > Balance ? 0 : LowestProfit), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowEq: %s %s", DoubleToString((LowestEquityAvailable > Balance ? 0 : LowestEquityAvailable), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowMg: %s %s", DoubleToString((LowestMarginAvailable > Balance ? 0 : LowestMarginAvailable), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("Up and Low: %s --- %s", DoubleToString(Properties.Prices.Last.UpperPrice, Digits), DoubleToString(Properties.Prices.Last.LowerPrice, Digits)) + CrLf;
   Cmt += Spacer + StringFormat("Eq: %s %s, Bal: %s %s", DoubleToString(AccountEquity(), 2), Currency, DoubleToString(AccountBalance(), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("MinLot: %s, MaxLot: %s, Step: %s", DoubleToString(MinLots, 2), DoubleToString(MaxLots, 2), DoubleToString(LotsStep, 2)) + CrLf;
   
   if (TargetType == TTDynamic)
   {
      Cmt += Spacer + StringFormat("DyTP: %s %s", DoubleToString(Properties.TargetProfit, 2), Currency) + CrLf;
   }
   else if (TargetType == TTFixed)
   {
      Cmt += Spacer + StringFormat("FxTP: %s %s", DoubleToString(TargetProfit, 2), Currency) + CrLf;
   }
   if (InitialLotsType == ILTDynamic)
   {
      Cmt += Spacer + StringFormat("DyLot: %s", DoubleToString(Properties.InitialLots, 2)) + CrLf;
   }
   else if (InitialLotsType == ILTFixed)
   {
      Cmt += Spacer + StringFormat("FxLot: %s", DoubleToString(Properties.InitialLots, 2)) + CrLf;
   }
   if (LossType == LTDynamic)
   {
      Cmt += Spacer + StringFormat("DySL: %s %s", DoubleToString(Properties.StopLoss, 2), Currency) + CrLf;
   }
   else if (LossType == LTFixed)
   {
      Cmt += Spacer + StringFormat("FxSL: %s %s", DoubleToString(StopLoss, 2), Currency) + CrLf;
   }
   if (OpenType == OTDynamicRecreationThreshold)
   {
      if (Properties.Prices.Last.UpperPrice > 0 && Properties.Prices.Last.LowerPrice > 0)
      {
         Cmt += Spacer + StringFormat("UpTH: %s, LowTH: %s, ASK: %s, BID: %s", DoubleToString(AddPoints(Properties.Prices.Last.UpperPrice, 0 - GridStepPoints - RecreationThreshold), Digits), DoubleToString(AddPoints(Properties.Prices.Last.LowerPrice, GridStepPoints + RecreationThreshold), Digits), DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
      else
      {
         Cmt += Spacer + StringFormat("ASK: %s, BID: %s", DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
   }

   if (CloseType == CTThreshold)
   {
      if (Properties.Prices.Last.UpperPrice > 0 && Properties.Prices.Last.LowerPrice > 0)
      {
         Cmt += Spacer + StringFormat("UpTH: %s, LowTH: %s, ASK: %s, BID: %s", DoubleToString(AddPoints(Properties.Prices.Last.UpperPrice, 0 - GridStepPoints - CloseThreshold), Digits), DoubleToString(AddPoints(Properties.Prices.Last.LowerPrice, GridStepPoints + CloseThreshold), Digits), DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
      else
      {
         Cmt += Spacer + StringFormat("ASK: %s, BID: %s", DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
   }
   
   if (EnableMaxCycle)
   {
      Cmt += Spacer + StringFormat("CYCLE: %s OF %s", IntegerToString(Properties.Counter.CurrentCycle), IntegerToString(MaxCycle)) + CrLf;
   }
   
   Cmt += CrLf;
   Cmt += Spacer + StringFormat("CURRENT: %s", TimeToString(Properties.DateTimeInfo.Current, TIME_DATE | TIME_SECONDS)) + CrLf;
   Cmt += Spacer + StringFormat("DAY-START: %s, DAY-END: %s", TimeToString(Properties.DateTimeInfo.DailyStart, TIME_DATE | TIME_SECONDS), TimeToString(Properties.DateTimeInfo.DailyStop, TIME_DATE | TIME_SECONDS)) + CrLf;
   Cmt += Spacer + StringFormat("WEEK-START: %s, WEEK-END: %s", TimeToString(Properties.DateTimeInfo.WeeklyStart, TIME_DATE | TIME_SECONDS), TimeToString(Properties.DateTimeInfo.WeeklyEnd, TIME_DATE | TIME_SECONDS)) + CrLf;

   Comment(Cmt);
}

void DeleteLine(string ctlName)
{
   DrawLine(ctlName, LODelete);
}
void DrawLine(string ctlName, double Price = 0, color LineColor = clrGold, int LineWidth = 1, ENUM_LINE_STYLE LineStyle = STYLE_SOLID)
{
   DrawLine(ctlName, LODraw, Price, LineColor, LineWidth, LineStyle);
}
void DrawLine(string ctlName, enObjectOperation LineOperation = LODraw, double Price = 0, color LineColor = clrGold, int LineWidth = 1, ENUM_LINE_STYLE LineStyle = STYLE_SOLID)
{
   string FullCtlName = ctlName;
   
   if (ObjectFind(ChartID(), FullCtlName) > -1)
   {
      if (LineOperation == LODraw)
      {
         ObjectMove(FullCtlName, 0, Time[0], Price);
         ObjectSet(FullCtlName, OBJPROP_STYLE, LineStyle);
         ObjectSet(FullCtlName, OBJPROP_WIDTH, LineWidth);
         ObjectSet(FullCtlName, OBJPROP_COLOR, LineColor);
      }
      else
      {
         ObjectDelete(ChartID(), FullCtlName);
      }
   }
   else if (LineOperation == LODraw)
   {
      ObjectCreate(ChartID(), FullCtlName, OBJ_HLINE, 0, Time[0], Price);
      ObjectSet(FullCtlName, OBJPROP_STYLE, LineStyle);
      ObjectSet(FullCtlName, OBJPROP_WIDTH, LineWidth);
      ObjectSet(FullCtlName, OBJPROP_COLOR, LineColor);
   }
}
void DeleteButton(string ctlName)
{
   ObjectButton(ctlName, LODelete);
}
void SetButtonText(string ctlName, string Text)
{
   if ((ObjectFind(ChartID(), ctlName) > -1))
   {
      ObjectSetString(ChartID(), ctlName, OBJPROP_TEXT, Text);
   }
}
void SetButtonColor(string ctlName, color buttonColor = clrNONE, color textColor = clrNONE)
{
   if ((ObjectFind(ChartID(), ctlName) > -1))
   {
      if (buttonColor != clrNONE)
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_BGCOLOR, buttonColor);
      if (textColor != clrNONE)
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_COLOR, textColor);
   }
}
void PressButton(string ctlName)
{
   bool selected = ObjectGetInteger(ChartID(), ctlName, OBJPROP_STATE);
   if (selected)
   {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, false);
   }
   else
   {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, true);
   }
}
void DrawButton(string ctlName, string Text = "", int X = -1, int Y = -1, int Width = -1, int Height = -1, bool Selected = false, color BgColor = clrNONE, color TextColor = clrNONE)
{
   ObjectButton(ctlName, LODraw, Text, X, Y, Width, Height, Selected, BgColor, TextColor);
}
void ObjectButton(string ctlName, enObjectOperation Operation, string Text = "", int X = -1, int Y = -1, int Width = -1, int Height = -1, bool Selected = false, color BgColor = clrNONE, color TextColor = clrNONE)
{
   int DefaultX = btnLeftAxis;
   int DefaultY = btnTopAxis;
   int DefaultWidth = btnWidth;
   int DefaultHeight = btnHeight;
   
   if ((ObjectFind(ChartID(), ctlName) > -1))
   {
      if (Operation == LODraw)
      {
         if (TextColor == clrNONE) TextColor = DefaultButtonTextColor;
         if (BgColor == clrNONE) BgColor = DefaultButtonBgColor;
         if (X == -1) X = DefaultX;
         if (Y == -1) Y = DefaultY;
         if (Width == -1) Width = DefaultWidth;
         if (Height == -1) Height = DefaultHeight;
         
         
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_COLOR, TextColor);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_BGCOLOR, BgColor);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_XDISTANCE, X);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_YDISTANCE, Y);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_XSIZE, Width);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_YSIZE, Height);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, Selected);
         ObjectSetString(ChartID(), ctlName, OBJPROP_FONT, "Arial");
         ObjectSetString(ChartID(), ctlName, OBJPROP_TEXT, Text);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_FONTSIZE, 7);
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_SELECTABLE, 0);
         
      }
      else if (Operation == LODelete)
      {
         ObjectDelete(ChartID(), ctlName);
      }
   }
   else if (Operation == LODraw)
   {
      if (TextColor == clrNONE) TextColor = DefaultButtonTextColor;
      if (BgColor == clrNONE) BgColor = DefaultButtonBgColor;
      if (X == -1) X = DefaultX;
      if (Y == -1) Y = DefaultY;
      if (Width == -1) Width = DefaultWidth;
      if (Height == -1) Height = DefaultHeight;

      ObjectCreate(ChartID(), ctlName, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_COLOR, TextColor);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_BGCOLOR, BgColor);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_XDISTANCE, X);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_YDISTANCE, Y);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_XSIZE, Width);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_YSIZE, Height);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, Selected);
      ObjectSetString(ChartID(), ctlName, OBJPROP_FONT, "Arial");
      ObjectSetString(ChartID(), ctlName, OBJPROP_TEXT, Text);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_SELECTABLE, 0);
   }
}
double GetLinePrice(string ctlName)
{
   double Price = 0;
   string FullCtlName = ctlName;
   if (ObjectFind(ChartID(), FullCtlName) > -1)
   {
      Price = ObjectGetDouble(ChartID(), FullCtlName, OBJPROP_PRICE);
   }
   return Price;
}
double MiddlePrice(double PriceA, double PriceB)
{
   double TopPrice = 0;
   double BottomPrice = 0;
   
   if (PriceA > PriceB)
   {
      TopPrice = PriceA;
      BottomPrice = PriceB;
   }
   else
   {
      TopPrice = PriceB;
      BottomPrice = PriceA;
   }
   return NormalizeDouble(BottomPrice + ((TopPrice - BottomPrice) / 2), Digits);
}
double GetProfit()
{
   double TP = 0;
   if (ProfitTakingMode == PTMWithCommAndSwap)
   {
      TP = OrderProfit() + OrderCommission() + OrderSwap();
   }
   else if (ProfitTakingMode == PTMWithoutCommAndSwap)
   {
      TP = OrderProfit();
   }
   return TP;
}

double GetArrayValue(string ArrayData, int Index)
{
   string splitter = ",";
   string result[];
   ushort us_splitter = StringGetCharacter(splitter, 0);
   int splitResult = StringSplit(ArrayData, us_splitter, result);
   
   if (splitResult <= 0)
   {
      return 1;
   }
   else if (Index > (splitResult - 1))
   {
      return StringToDouble(result[(splitResult - 1)]);
   }
   else
   {
      return StringToDouble(result[Index]);
   }
}

string GetErrorMessages(string Source)
{
   int Chk = GetLastError();
   string ErrorMessages = StringFormat("[RdzGridTraps] ERROR %s - %i: %s", Source, IntegerToString(Chk), ErrorDescription(Chk));
   ResetLastError();
   return ErrorMessages;
}

string GetUninitReasonText(int reasonCode)
{
   string text="";
   switch(reasonCode)
   {
      case REASON_ACCOUNT:
         text = "Account was changed"; break;
      case REASON_CHARTCHANGE:
         text = "Symbol or timeframe was changed"; break;
      case REASON_CHARTCLOSE:
         text = "Chart was closed"; break;
      case REASON_PARAMETERS:
         text = "Input-parameter was changed"; break;
      case REASON_RECOMPILE:
         text = "Program " + __FILE__ + " was recompiled"; break;
      case REASON_REMOVE:
         text = "Program " + __FILE__ + " was removed from chart"; break;
      case REASON_TEMPLATE:
         text = "New template was applied to chart"; break;
      default:
         text = "Another reason";
   }
   return text;
}

bool Validations()
{
   bool Block = false;
   if ((OpenType == OTDynamicRecreationAll || OpenType == OTDynamicRecreationThreshold) && CloseType == CTThreshold)
   {
      MessageBox("Any of the Threshold Open Type can't be used together with Threshold Close Type");
      Block = true;
   }
   
   return Block;
}