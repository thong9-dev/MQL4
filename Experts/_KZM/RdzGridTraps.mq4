//+------------------------------------------------------------------+
//|                                                 RdzGridTraps.mq4 |
//|                                 Copyright 2015, Rdz Technologies |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Rdz Technologies"
#property link      "http://tunas-bangsa-camp.blogspot.com/"
#property version   "1.8"
#property strict
#property description "Developed by: Rdz (Radityo Ardi)"
#property description "NOTE:"
#property description "DYNAMIC GRID TRAP IS FREE AND LICENSED UNDER CHARITYWARE LICENSE STATED ON THE LINK ABOVE. ALL RIGHTS RESERVED."
#property description "ALTHOUGH IT'S FREE, I DEDICATE MY EFFORTS TO ALL PEOPLE IN THE WORLD, SUFFERING FOR HUNGER AND POOR."
#property description "AND FOR KIDS ALL OVER THE WORLD, STRUGGLING FOR EDUCATIONS."
#property description ""
#property description "PLEASE TAKE TIME TOR READ THIS LICENSE AGREEMENT."
#property description "https://sites.google.com/site/RdzCharitywareLicenseAgreement/"


#include <stdlib.mqh>
struct OrderInfo
{
   int OrderID;
   int Gaps;
   bool Closed;
};
enum enSlippageMode
{
   SMBoth = 0, //Both
   SMOpenOnly = 1, //Open Only
   SMCloseOnly = 2 //Close Only
};
enum enTargetType
{
   TTFixed = 0, //Fixed
   TTDynamic = 1 //Dynamic
};
enum enLossType
{
   LTNone = 0, //No Stop Loss
   LTFixed = 1, //Fixed
   LTDynamic = 2 //Dynamic
};
enum enContinuousMode
{
   COMContinuous = 0, //Continuous
   COMStopPendingOrders = 1, //Stop Only Pending Orders and outside timeframe
   COMForceStopAll = 2 //Force Stop All Orders when outside Timeframe
};
enum enCloseType
{
   CTStandard = 0, //Target Based (Standard)
   CTAllOrdersExecuted = 1, //Target Based OR All Orders Opened
   CTMiddlePoint = 2, //Target Based OR Middle Point
   CTThreshold = 3, //Target Based OR Threshold
   CTThresholdMiddlePoint = 4, //Target Based OR Threshold OR Middle Point
   CTProfitMinOrders = 5 //Target Based OR Min Profit Open Orders
};
enum enOpenType
{
   OTFixedOrder = 0, //Fixed
   OTDynamicRecreationAll = 1, //Dynamic Auto-Expand (All Orders)
   OTDynamicRecreationThreshold = 2 //Dynamic Auto-Expand by Threshold
};
enum enInitialLotsType
{
   ILTFixed = 0, //Fixed
   ILTDynamic = 1 //Dynamic
};
enum enDateTimeType
{
   DTTLocalTime = 0, //Local time
   DTTServerTime = 1, //Server (broker) time
   DTTGMTTime = 2 //GMT (UTC) time
};
enum enObjectOperation
{
   LODraw = 0,
   LODelete = 1
};
enum enOrderOperation
{
   StopOrders = 0, //STOP orders
   LimitOrders = 1, //LIMIT orders
   FewLimitOrders = 2, //LIMIT orders then STOP orders
};
enum enCloseMode
{
   CMInternal = 0, //Internal
   CMExtended = 1 //Extended
};
enum enStatusExtendedClose
{
   STNotStarted = 0,
   STInProgress = 1,
   STClosed = 2,
   STError = 3
};
enum enProfitTakingMode
{
   PTMWithCommAndSwap = 0, //Include Commission and Swap
   PTMWithoutCommAndSwap = 1 //Exclude Commission and Swap
};
enum enDynamicBase
{
   DBBalance = 0, //Balance
   DBEquity = 1 //Equity
};
enum enStopTimeMode
{
   STMNothing = 0, //Nothing to do
   STMForceCloseNoOpenOrder = 1, //Force close orders if not opened
   STMForceCloseAll = 2, //Force close all orders
   STMForceCloseProfit = 3 //Force close all orders if in profit
};
enum enCloseDirection
{
   CDOutsideIn = 0, //Outside-In
   CDInsideOut = 1 //Inside-Out
};
enum enDayOfWeek
{
   DOWSunday = 0, //Sunday
   DOWMonday = 1, //Monday
   DOWTuesday = 2, //Tuesday
   DOWWednesday = 3, //Wednesday
   DOWThursday = 4, //Thursday
   DOWFriday = 5, //Friday
   DOWSaturday = 6 //Saturday
};
enum enClCalculationMode
{
   ClNoRecalculate = 0, //No Recalculation
   ClAllRecalculate = 1 //Recalculate Balance & Equity on tick
};


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
input          enDynamicBase           TargetProfitDynamicBase    = DBBalance; //Target Profit Calculation Source
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
input          bool                    EnableNotification         = false; // Enable Notification

               int                     BuyCount                   = 0;
               int                     SellCount                  = 0;
               int                     PendingBuyCount            = 0;
               int                     PendingSellCount           = 0;
               int                     HighestBuyCount            = 0;
               int                     HighestSellCount           = 0;
               int                     AllOrdersCount             = 0;
               int                     CycleCount                 = 0;
               int                     btnLeftAxis                = 30;
               int                     btnTopAxis                 = 250;
               int                     btnInterval                = 35;
               int                     btnWidth                   = 100;
               int                     btnHeight                  = 30;
               color                   btnColor                   = clrCornflowerBlue;
               color                   btnPressedColor            = clrGray;
               
               bool                    NoCorruptedCheck           = false;
               bool                    AllPositiveProfit          = false;
               datetime                CurrentTime                = 0;
               datetime                DailyStartDateTime         = 0;
               datetime                DailyStopDateTime          = 0;
               datetime                WeeklyStartDateTime        = 0;
               datetime                WeeklyEndDateTime          = 0;
               double                  TotalProfit                = 0;
               bool                    ActiveOrders               = false;
               double                  LastUpperPrice             = 0;
               double                  LastLowerPrice             = 0;
               int                     DyOrderCountPerSide        = 0;
               double                  DyTargetProfit             = 0;
               double                  DyStopLoss                 = 0;
               double                  DyStartingLots             = 0;
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


int OnInit()
{
   GVStopNext = ConstGVStopNext + IntegerToString(MagicNumber);
   GVFastCloseOrders = ConstGVFastCloseOrders + IntegerToString(MagicNumber);
   GVFastCloseProfit = ConstGVFastCloseProfit + IntegerToString(MagicNumber);
   
   if (IsStopOnNextCycle())
   {
      DrawButton(btnEnableTrading, btnKeepGoingText, btnLeftAxis, btnTopAxis, -1, -1, true);
   }
   else
   {
      DrawButton(btnEnableTrading, btnStopNextCycleText, btnLeftAxis, btnTopAxis);
   }
   DrawButton(btnForceCloseAll, btnForceCloseAllText, btnLeftAxis, btnTopAxis + btnInterval);
   
   CalculateStartingLots();
   CalculateTargetProfit();
   CalculateStopLoss();

   //OnInitDetection(); //detect previous trading sessions in the case of shutting down EA

   EventSetMillisecondTimer(100); //setting timer for time recording
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
   PrintFormat("BUY: %s, SELL: %s", IntegerToString(BuyCount), IntegerToString(SellCount));
   PrintFormat("HIGHEST BUY: %s, SELL: %s", IntegerToString(HighestBuyCount), IntegerToString(HighestSellCount));
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
            SetButtonColor(btnEnableTrading, btnPressedColor);
         }
         if (IsStopOnNextCycle())
         {
            SetButtonText(btnEnableTrading, btnStopNextCycleText);
            SetButtonColor(btnEnableTrading, DefaultButtonBgColor, DefaultButtonTextColor);
            SetStopNext(false);
            SetComments();
         }
         else
         {
            SetButtonText(btnEnableTrading, btnKeepGoingText);
            SetButtonColor(btnEnableTrading, btnPressedColor);
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
   CountStartEndTime();
   CalculateWeeklyStartEndTime(CurrentTime);
   CheckOrders();
   if (IsTimeToRecreate() && (OpenType == OTDynamicRecreationAll || OpenType == OTDynamicRecreationThreshold))
   {
      CreateOrders();
   }
   
   SetComments();
   
   if (
         (
            (IsTimeToClose()) ||
            (StopTimeMode == STMForceCloseAll && IsInTimeRange(DailyStopTime)) ||
            (StopTimeMode == STMForceCloseNoOpenOrder && (BuyCount + SellCount) == 0 && IsInTimeRange(DailyStopTime)) ||
            (StopTimeMode == STMForceCloseProfit && TotalProfit > 0 && IsInTimeRange(DailyStopTime))
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
   
   if (!ActiveOrders && !IsStopOnNextCycle() && IsInStartTimeRange() && (!EnableMaxCycle || (EnableMaxCycle && CycleCount < MaxCycle)))
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

   SetComments();
}
//+------------------------------------------------------------------+

void OnTimer()
{
   //this method will not be called on backtesting
   SetComments();
}
void CalculateStartingLots()
{
   double MaxLots = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), 2);
   double MinLots = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), 2);
   double LotsStep = NormalizeDouble(MarketInfo(Symbol(),MODE_LOTSTEP), 2);
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
         if (LotsStep == 0.01) //standard Lot size increment
         {
            DyStartingLots = NormalizeDouble(BaseCalc * InitialLotsMult, 2);
         }
         else
         {
            double _dyStLots = NormalizeDouble(BaseCalc * InitialLotsMult, 2);
            DyStartingLots = NormalizeDouble(_dyStLots - MathMod(_dyStLots, LotsStep), 2);
         }
      }
      else
      {
         DyStartingLots = MinLots;
      }
   }
   else
   {
      DyStartingLots = NormalizeDouble(InitialLots, 2);
   }
   
   if (DyStartingLots < MinLots) DyStartingLots = MinLots;
   if (DyStartingLots > MaxLots) DyStartingLots = MaxLots;
}

void CalculateTargetProfit()
{
   if (TargetType == TTDynamic)
   {
      double BaseCalc = 0;
      if (TargetProfitDynamicBase == DBBalance)
      {
         BaseCalc = AccountBalance();
      }
      else if (TargetProfitDynamicBase == DBEquity)
      {
         BaseCalc = AccountEquity();
      }
      
      if (BaseCalc > 0)
      {
         DyTargetProfit = BaseCalc * TargetProfitMult;
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
         DyStopLoss = BaseCalc * StopLossMult;
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
      
      DyOrderCountPerSide = OrderCountPerSide;
      CreationCount = OrderCountPerSide;
      
      CalculateTargetProfit();
      CalculateStopLoss();
      
      CalculateStartingLots();
   }
   else if (LastLowerPrice > 0 && LastUpperPrice > 0 && OpenType != OTFixedOrder) //subsequent recreation
   {
      CurrentUpperPrice = LastUpperPrice;
      CurrentLowerPrice = LastLowerPrice;
      
      DyOrderCountPerSide += RecreationCountPerSide;
      CreationCount = RecreationCountPerSide;
   }
   
   for(int i = 0; i < CreationCount; i++)
   {
      if (LimitMaxOrderCount && AllOrdersCount >= MaxOrderCount) break;
      if (i == 0) ActiveOrders = true;
      
      double PriceTP = 0; double PriceSL = 0; int slp = 0;
      
      int Chk = 0;
      if (OrderOperation == StopOrders || (OrderOperation == FewLimitOrders && AllOrdersCount >= LimitOrdersCount))
      {
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_BUYSTOP, DyStartingLots, CurrentUpperPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(DyStartingLots, 2), DoubleToString(CurrentUpperPrice, Digits)));
         else
         {
            PendingBuyCount += 1; AllOrdersCount += 1;
         }
         
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_SELLSTOP, DyStartingLots, CurrentLowerPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(DyStartingLots, 2), DoubleToString(CurrentLowerPrice, Digits)));
         else
         {
            PendingSellCount += 1; AllOrdersCount += 1;
         }
      }
      else if (OrderOperation == LimitOrders || (OrderOperation == FewLimitOrders && i < LimitOrdersCount))
      {
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_SELLLIMIT, DyStartingLots, CurrentUpperPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(DyStartingLots, 2), DoubleToString(CurrentUpperPrice, Digits)));
         else
         {
            PendingSellCount += 1; AllOrdersCount += 1;
         }

         Chk = 0;
         Chk = OrderSend(Symbol(), OP_BUYLIMIT, DyStartingLots, CurrentLowerPrice, slp, PriceSL, PriceTP, CommentInfo, MagicNumber);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(DyStartingLots, 2), DoubleToString(CurrentLowerPrice, Digits)));
         else
         {
            PendingBuyCount += 1; AllOrdersCount += 1;
         }
      }
      
      
      CurrentUpperPrice = AddPoints(CurrentUpperPrice, GridStepPoints);
      CurrentLowerPrice = AddPoints(CurrentLowerPrice, 0 - GridStepPoints);
      
      LastUpperPrice = CurrentUpperPrice;
      LastLowerPrice = CurrentLowerPrice;
   }
   
   DrawLine(lnUPPERPRICE, LastUpperPrice, clrYellow, 1, STYLE_DOT);
   DrawLine(lnLOWERPRICE, LastLowerPrice, clrYellow, 1, STYLE_DOT);
   
   NoCorruptedCheck = false;
}

bool IsTimeToClose()
{
   bool IsTime = false;
   
   if (ActiveOrders)
   {
      RefreshRates();
      double AskTH = 0;
      double BidTH = 0;
      AskTH = GetLinePrice(lnUPPERTH);
      BidTH = GetLinePrice(lnLOWERTH);
      
      bool IsTargetReached = ((TotalProfit >= TargetProfit && TargetType == TTFixed) || (TotalProfit >= DyTargetProfit && TargetType == TTDynamic));
      bool IsLossAccepted = ((LossType == LTFixed && TotalProfit <= StopLoss && StopLoss < 0) || (LossType == LTDynamic && TotalProfit <= DyStopLoss && DyStopLoss < 0));
      bool IsInMiddlePoint = (Ask <= AskTH && Bid >= BidTH);
      bool IsMidPointActivated = (((BuyCount + SellCount) >= CloseMiddlePointAftOrders && CloseMiddlePointAftOrders > 0) || CloseMiddlePointAftOrders <= 0);
      bool IsProfitMaxOrderActivated = (((BuyCount + SellCount) >= MinProfitOrders && MinProfitOrders > 0) || MinProfitOrders <= 0);
      bool IsReachingThreshold = (AddPoints(LastUpperPrice, 0 - GridStepPoints - CloseThreshold) <= Ask || AddPoints(LastLowerPrice, GridStepPoints + CloseThreshold) > Bid);
      
      if (
         (CloseType == CTMiddlePoint && (
            IsTargetReached || IsLossAccepted || (IsInMiddlePoint && IsMidPointActivated && AllPositiveProfit)))
         ||
         (CloseType == CTThresholdMiddlePoint && (
            IsTargetReached || IsLossAccepted || IsReachingThreshold || (IsInMiddlePoint && IsMidPointActivated && AllPositiveProfit)))
         ||
         (CloseType == CTProfitMinOrders && (
            IsTargetReached || IsLossAccepted || (IsProfitMaxOrderActivated && AllPositiveProfit)))
         ||
         (CloseType == CTStandard && (
            IsTargetReached || IsLossAccepted))
         ||
         (CloseType == CTAllOrdersExecuted && (
            IsTargetReached || IsLossAccepted || (BuyCount == SellCount && BuyCount > 0 && BuyCount == DyOrderCountPerSide)))
         ||
         (CloseType == CTThreshold && (
            IsTargetReached || IsLossAccepted || IsReachingThreshold))
      )
      {
         PrintFormat("Ask:%s AskTH:%s, %s %s %s %s %s", DoubleToString(Ask), DoubleToString(AskTH), (IsTargetReached ? "[Profit]" : ""), (IsLossAccepted ? "[Loss]" : ""), (IsInMiddlePoint ? "[MidPoint]" : ""), (IsMidPointActivated ? "[MidPointActive]" : ""), (AllPositiveProfit ? "[All Positive]" : ""));
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
   return (LastLowerPrice <= 0 && LastUpperPrice <= 0);
}

bool IsInStartTimeRange()
{
   bool IsTime = false;
   if (
      ((CurrentTime >= DailyStartDateTime && CurrentTime <= DailyStopDateTime) || (DailyStartDateTime > DailyStopDateTime && DailyStopDateTime > CurrentTime))
      &&
      ((CurrentTime >= WeeklyStartDateTime && CurrentTime <= WeeklyEndDateTime) || (WeeklyStartDateTime > WeeklyEndDateTime && WeeklyEndDateTime > CurrentTime))
      )
   {
      IsTime = true;
   }
   return IsTime;
}
bool IsInTimeRange(string TimeInformation, int AddRange = -1)
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
bool IsTimeToRecreate()
{
   bool IsTime = false;
   RefreshRates();

   if (ActiveOrders)
   {
      if (BuyCount == SellCount && BuyCount > 0 && BuyCount == DyOrderCountPerSide && OpenType == OTDynamicRecreationAll) //dynamic recreation all
      {
         IsTime = true;
      }
      else if (OpenType == OTDynamicRecreationThreshold && CloseType != CTThreshold
         && ((AddPoints(LastUpperPrice, 0 - GridStepPoints - RecreationThreshold)) <= Ask || AddPoints(LastLowerPrice, GridStepPoints + RecreationThreshold) > Bid))
      {
         IsTime = true;
      }
   }
   return IsTime;
}

void CheckOrders()
{
   BuyCount = 0;
   SellCount = 0;
   PendingBuyCount = 0;
   PendingSellCount = 0;
   AllOrdersCount = 0;
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
   AllPositiveProfit = true;
   
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
            BuyCount += 1;
            if (Profit <= 0) AllPositiveProfit = false;
         }
         else if (OrdType == OP_SELL)
         {
            SellCount += 1;
            if (Profit <= 0) AllPositiveProfit = false;
         }
         else if (OrdType == OP_BUYLIMIT || OrdType == OP_BUYSTOP)
         {
            PendingBuyCount += 1;
         }
         else if (OrdType == OP_SELLLIMIT || OrdType == OP_SELLSTOP)
         {
            PendingSellCount += 1;
         }
         AllOrdersCount += 1;
         
         if (HighestBuyCount < BuyCount)
         {
            HighestBuyCount = BuyCount;
         }
         if (HighestSellCount < SellCount)
         {
            HighestSellCount = SellCount;
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
      if (tUpperPrice > 0) LastUpperPrice = tUpperPrice;
      if (tLowerPrice > 0) LastLowerPrice = tLowerPrice;
   }
   
   if (IsUpperLowerUndefined)
   {
      DrawLine(lnUPPERPRICE, LastUpperPrice, clrYellow, 1, STYLE_DOT);
      DrawLine(lnLOWERPRICE, LastLowerPrice, clrYellow, 1, STYLE_DOT);
      
      int Buys = 0;
      int Sells = 0;
      Buys = (BuyCount + PendingBuyCount);
      Sells = (SellCount + PendingSellCount);
      
      if ((Buys == Sells) || (Buys != Sells && Buys > Sells))
      {
         DyOrderCountPerSide = Buys;
      }
      else if (Buys != Sells && Sells > Buys)
      {
         DyOrderCountPerSide = Sells;
      }
   }
   
   if (BuyCount == SellCount && BuyCount == 0)
      AllPositiveProfit = false;
   
   if (AccountFreeMargin() < LowestMarginAvailable) LowestMarginAvailable = AccountFreeMargin();
   if (AccountEquity() < LowestEquityAvailable) LowestEquityAvailable = AccountEquity();

   RecalculateTargetProfit();
   RecalculateStopLoss();   
   
   if (ActiveOrders && OpenType == OTDynamicRecreationThreshold && CloseType != CTThreshold)
   {
      double UpperTHPrice = 0;
      double LowerTHPrice = 0;
      UpperTHPrice = AddPoints(LastUpperPrice, 0 - GridStepPoints - RecreationThreshold);
      LowerTHPrice = AddPoints(LastLowerPrice, GridStepPoints + RecreationThreshold);
      
      if (UpperTHPrice > 0)
         DrawLine(lnUPPERTH, UpperTHPrice, clrYellow, 1, STYLE_DASH);
      if (LowerTHPrice > 0)
         DrawLine(lnLOWERTH, LowerTHPrice, clrYellow, 1, STYLE_DASH);
   }
   else if (ActiveOrders && OpenType != OTDynamicRecreationThreshold && OpenType != OTDynamicRecreationAll && CloseType == CTThreshold)
   {
      double UpperTHPrice = 0;
      double LowerTHPrice = 0;
      
      UpperTHPrice = AddPoints(LastUpperPrice, 0 - GridStepPoints - CloseThreshold);
      LowerTHPrice = AddPoints(LastLowerPrice, GridStepPoints + CloseThreshold);
      
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
      if ((PendingSellCount + SellCount) == (PendingBuyCount + BuyCount))
      {
         IsCor = false;
      }
   }
   
   return IsCor;
}
void ResetCycle()
{
   CycleCount = 0;
}
void ResetOnClose()
{
   BuyCount = 0;
   SellCount = 0;
   PendingBuyCount = 0;
   PendingSellCount = 0;
   AllOrdersCount = 0;
   LastLowerPrice = 0;
   LastUpperPrice = 0;
   DyOrderCountPerSide = 0;
   DyTargetProfit = 0;
   ActiveOrders = false;
   AllPositiveProfit = false;
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

void CloseOrders()
{
   NoCorruptedCheck = true;

   if (CloseDirection == CDOutsideIn)
   {
      do
      {
         CloseOrdersOutsideIn();
         UpdateActiveOrders();
      } while (ActiveOrders);
   }
   else if (CloseDirection == CDInsideOut)
   {
      do
      {
         CloseOrdersInsideOut();
         UpdateActiveOrders();
      } while (ActiveOrders);
   }
   
   if ((IsInTimeRange(DailyStopTime) && ActiveOrders) || !IsInStartTimeRange())
   {
      CycleCount = 0;
   }
   else
   {
      CycleCount += 1;
   }
   LastProfit = TotalProfit;
   if (TotalProfit > BiggestProfit) BiggestProfit = TotalProfit;
   if (TotalProfit < LowestProfit) LowestProfit = TotalProfit;
   if (EnableNotification)
      SendNotification(StringFormat("[RdzGridTraps] Profit:%s%s (%s - %s)", AccountCurrency(), DoubleToString(TotalProfit, 2), AccountCompany(), IntegerToString(AccountNumber())));
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
void CloseOrdersOutsideIn()
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
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
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
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
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
         if (OrderType() == OP_BUY)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
         }
         else if (OrderType() == OP_SELL)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
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

void CloseOrdersInsideOut()
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
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
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
               Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
            }
            else if (OrderType() == OP_SELL)
            {
               Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
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
         if (OrderType() == OP_BUY)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
         }
         else if (OrderType() == OP_SELL)
         {
            Chk = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
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
      CurrentTime = TimeLocal();
   }
   else if (DateTimeType == DTTServerTime)
   {
      CurrentTime = TimeCurrent();
   }
   else if (DateTimeType == DTTGMTTime)
   {
      CurrentTime = TimeGMT();
   }
   AnchorTime = CurrentTime;
   DailyStartDateTime = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + DailyStartTime);
   
   DailyStopDateTime = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + DailyStopTime);
   if (DailyStopDateTime <= DailyStartDateTime && DailyStopDateTime <= CurrentTime)
      DailyStopDateTime += OneDay; //adds 1 day.
}

void CalculateWeeklyStartEndTime(datetime AnchorTime)
{
   int OneDay = 86400;
   WeeklyStartDateTime = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + WeeklyStartTime);
   WeeklyEndDateTime = StringToTime(IntegerToString(TimeYear(AnchorTime)) + "." + IntegerToString(TimeMonth(AnchorTime)) + "." + IntegerToString(TimeDay(AnchorTime)) + " " + WeeklyStopTime);
   while (TimeDayOfWeek(WeeklyStartDateTime) != WeeklyStartDay)
   {
      WeeklyStartDateTime += OneDay;
      
      //your statement here
   }
   while (TimeDayOfWeek(WeeklyEndDateTime) != WeeklyStopDay)
   {
      WeeklyEndDateTime += OneDay;
      
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
   
   Cmt += Spacer + StringFormat("%s%s%s", (ActiveOrders ? "ACTIVE" : "INACTIVE"), (IsStopOnNextCycle() ? " - STOP NEXT" : ""), (IsInStartTimeRange() ? " - IN TIMERANGE" : "")) + CrLf;
   if (CloseType == CTMiddlePoint && AllPositiveProfit)
      Cmt += Spacer + "IN MIDPOINT" + CrLf;
   Cmt += Spacer + StringFormat("[PENDING SELL: %s, BUY: %s] [OPEN SELL: %s, BUY: %s]",
      IntegerToString(PendingSellCount),
      IntegerToString(PendingBuyCount),
      IntegerToString(SellCount),
      IntegerToString(BuyCount)
      ) + CrLf;
      
   Cmt += Spacer + StringFormat("CP: %s %s", DoubleToString(TotalProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LastP: %s %s", DoubleToString(LastProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("BP: %s %s", DoubleToString(BiggestProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowP: %s %s", DoubleToString((LowestProfit > Balance ? 0 : LowestProfit), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowEq: %s %s", DoubleToString((LowestEquityAvailable > Balance ? 0 : LowestEquityAvailable), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowMg: %s", DoubleToString((LowestMarginAvailable > Balance ? 0 : LowestMarginAvailable), 2)) + CrLf;
   Cmt += Spacer + StringFormat("Up and Low: %s --- %s", DoubleToString(LastUpperPrice, Digits), DoubleToString(LastLowerPrice, Digits)) + CrLf;
   Cmt += Spacer + StringFormat("Eq: %s %s, Bal: %s %s", DoubleToString(AccountEquity(), 2), Currency, DoubleToString(AccountBalance(), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("MinLot: %s, MaxLot: %s, Step: %s", DoubleToString(MinLots, 2), DoubleToString(MaxLots, 2), DoubleToString(LotsStep, 2)) + CrLf;
   
   if (TargetType == TTDynamic)
   {
      Cmt += Spacer + StringFormat("DyTP: %s %s", DoubleToString(DyTargetProfit, 2), Currency) + CrLf;
   }
   else if (TargetType == TTFixed)
   {
      Cmt += Spacer + StringFormat("FxTP: %s %s", DoubleToString(TargetProfit, 2), Currency) + CrLf;
   }
   if (InitialLotsType == ILTDynamic)
   {
      Cmt += Spacer + StringFormat("DyLot: %s", DoubleToString(DyStartingLots, 2)) + CrLf;
   }
   else if (InitialLotsType == ILTFixed)
   {
      Cmt += Spacer + StringFormat("FxLot: %s", DoubleToString(DyStartingLots, 2)) + CrLf;
   }
   if (LossType == LTDynamic)
   {
      Cmt += Spacer + StringFormat("DySL: %s %s", DoubleToString(DyStopLoss, 2), Currency) + CrLf;
   }
   else if (LossType == LTFixed)
   {
      Cmt += Spacer + StringFormat("FxSL: %s %s", DoubleToString(StopLoss, 2), Currency) + CrLf;
   }
   if (OpenType == OTDynamicRecreationThreshold)
   {
      if (LastUpperPrice > 0 && LastLowerPrice > 0)
      {
         Cmt += Spacer + StringFormat("UpTH: %s, LowTH: %s, ASK: %s, BID: %s", DoubleToString(AddPoints(LastUpperPrice, 0 - GridStepPoints - RecreationThreshold), Digits), DoubleToString(AddPoints(LastLowerPrice, GridStepPoints + RecreationThreshold), Digits), DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
      else
      {
         Cmt += Spacer + StringFormat("ASK: %s, BID: %s", DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
   }

   if (CloseType == CTThreshold)
   {
      if (LastUpperPrice > 0 && LastLowerPrice > 0)
      {
         Cmt += Spacer + StringFormat("UpTH: %s, LowTH: %s, ASK: %s, BID: %s", DoubleToString(AddPoints(LastUpperPrice, 0 - GridStepPoints - CloseThreshold), Digits), DoubleToString(AddPoints(LastLowerPrice, GridStepPoints + CloseThreshold), Digits), DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
      else
      {
         Cmt += Spacer + StringFormat("ASK: %s, BID: %s", DoubleToString(Ask, Digits), DoubleToString(Bid, Digits)) + CrLf;
      }
   }
   
   if (EnableMaxCycle)
   {
      Cmt += Spacer + StringFormat("CYCLE: %s OF %s", IntegerToString(CycleCount), IntegerToString(MaxCycle)) + CrLf;
   }
   
   if (IsTesting())
   {
      Cmt += CrLf;
      Cmt += Spacer + StringFormat("CURRENT: %s", TimeToString(CurrentTime, TIME_DATE | TIME_SECONDS)) + CrLf;
      Cmt += Spacer + StringFormat("D-START: %s, D-END: %s", TimeToString(DailyStartDateTime, TIME_DATE | TIME_SECONDS), TimeToString(DailyStopDateTime, TIME_DATE | TIME_SECONDS)) + CrLf;
      Cmt += Spacer + StringFormat("W-START: %s, W-END: %s", TimeToString(WeeklyStartDateTime, TIME_DATE | TIME_SECONDS), TimeToString(WeeklyEndDateTime, TIME_DATE | TIME_SECONDS)) + CrLf;
   }

   if (StringLen(CommentInfo) > 0)
   {
      Cmt += Spacer + StringFormat("INFO: %s", CommentInfo) + CrLf;
   }

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
         ObjectSetInteger(ChartID(), ctlName, OBJPROP_FONTSIZE, 8);
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