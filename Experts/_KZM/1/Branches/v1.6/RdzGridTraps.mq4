//+------------------------------------------------------------------+
//|                                                 RdzGridTraps.mq4 |
//|                                 Copyright 2015, Rdz Technologies |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Rdz Technologies"
#property link      "https://sites.google.com/site/RdzCharitywareLicenseAgreement/"
#property version   "1.6"
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
   CTAllOrdersExecuted = 1, //All Orders Opened or Target Based
   CTMiddlePoint = 2 //Right in Start Point or Target Based
};
enum enOpenType
{
   OTFixedOrder = 0, //Fixed
   OTDynamicRecreationAll = 1, //Dynamic Recreation (All Orders)
   OTDynamicRecreationThreshold = 2 //Dynamic Recreation by Threshold
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
   FewLimitOrders = 2, //A few LIMIT orders
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
   PTMWithCommAndSwap = 0, //With Commission and Swap
   PTMWithoutCommAndSwap = 1 //Without Commission and Swap
};
enum enDynamicBase
{
   DBBalance = 0, //Balance
   DBEquity = 1 //Equity
};
enum enStopTimeMode
{
   STMNothing = 0, //Nothing to do
   STMForceCloseNoOpenOrder = 1, //Close when no open order
   STMForceCloseAll = 2 //Force close all orders
};
enum enCloseDirection
{
   CDOutsideIn = 0, //Outside-In
   CDInsideOut = 1 //Inside-Out
};


input          enDateTimeType          DateTimeType               = DTTLocalTime; //Date and Time base
input          string                  DailyStartTime             = "01:00:00"; //Start Time (HH:mm:ss)
input          string                  DailyStopTime              = "23:00:00"; //Stop Time (HH:mm:ss)
input          enStopTimeMode          StopTimeMode               = STMNothing; //Stop Time Mode
input          enOpenType              OpenType                   = OTDynamicRecreationAll; //Open Type
input          enOrderOperation        OrderOperation             = StopOrders; //Order Operation
input          int                     OrderCountPerSide          = 2; //Order Count (each side)
input          bool                    LimitMaxOrderCount         = false; //Enable Max Order Count Limiter
input          int                     MaxOrderCount              = 0; //Maximum Order Count (total)
input          int                     RecreationCountPerSide     = 1; //Recreation Count (each side)
input          int                     LimitOrdersCount           = 3; //Limit Orders Count (for Few Limit Orders)
input          int                     RecreationThreshold        = 50; //Recreation Threshold (in Points)
input          int                     GridStepPoints             = 50; //Grid Step (in Points)
input          int                     CurrentPriceInterval       = 50; //Current Price Interval
input          int                     MagicNumber                = 8888; //Unique ID
input          enInitialLotsType       InitialLotsType            = ILTDynamic; //Initial Lots Type
input          double                  InitialLots                = 0.01; //Initial Lots
input          double                  InitialLotsMult            = 0.0001;//Initial Lots Multiplier
input          string                  CommentInfo                = ""; //Comment Info
input          enProfitTakingMode      ProfitTakingMode           = PTMWithCommAndSwap; //Profit Taking Mode
input          enDynamicBase           TargetProfitDynamicBase    = DBBalance; //Target Profit Dynamic Base
input          enTargetType            TargetType                 = TTDynamic; //Target Type
input          double                  TargetProfit               = 0.2; //Target Profit
input          double                  TargetProfitMult           = 0.004;//Target Profit Multiplier
input          enDynamicBase           StopLossDynamicBase        = DBBalance; //Stop Loss Dynamic Base
input          enLossType              LossType                   = LTNone; //Loss Type
input          double                  StopLoss                   = -100; //Stop Loss
input          double                  StopLossMult               = -0.0001; //Stop Loss Multiplier
input          enCloseType             CloseType                  = CTStandard; //Close Type
input          enCloseDirection        CloseDirection             = CDInsideOut; //Order Closure Direction
input          bool                    EnableMaxCycle             = false; //Enable Max Cycle
input          int                     MaxCycle                   = 0; //Max Cycle
input          enCloseMode             CloseMode                  = CMInternal; //Close Mode
input          int                     CountRunningCloseEA        = 0; //Count of Running EA
input          bool                    CheckIsCorrupted           = false; //Check Corrupted
input          bool                    EnableNotification         = false; // Enable Notification

               int                     BuyCount                   = 0;
               int                     SellCount                  = 0;
               int                     PendingBuyCount            = 0;
               int                     PendingSellCount           = 0;
               int                     HighestBuyCount            = 0;
               int                     HighestSellCount           = 0;
               int                     AllOrdersCount             = 0;
               int                     CycleCount                 = 0;
               
               bool                    NoCorruptedCheck           = false;
               bool                    AllPositiveProfit          = false;
               datetime                CurrentTime                = 0;
               datetime                DailyStartDateTime         = 0;
               datetime                DailyStopDateTime          = 0;
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
               double                  CurrentProfit              = 0;
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

int OnInit()
{
   GVStopNext = ConstGVStopNext + IntegerToString(MagicNumber);
   GVFastCloseOrders = ConstGVFastCloseOrders + IntegerToString(MagicNumber);
   GVFastCloseProfit = ConstGVFastCloseProfit + IntegerToString(MagicNumber);
   
   if (IsStopOnNextCycle())
   {
      DrawButton(btnEnableTrading, "Keep Going", 30, 200, -1, -1, true);
   }
   else
   {
      DrawButton(btnEnableTrading, "Stop Next Cycle", 30, 200);
   }
   DrawButton(btnForceCloseAll, "Force Close All", 30, 235);
   
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
      if (clickedObject == btnEnableTrading)
      {
         bool selected = ObjectGetInteger(ChartID(), btnEnableTrading, OBJPROP_STATE);
         if (IsStopOnNextCycle())
         {
            SetButtonText(btnEnableTrading, "Stop Next Cycle");
            SetStopNext(false);
            SetComments();
         }
         else
         {
            SetButtonText(btnEnableTrading, "Keep Going");
            SetStopNext(true);
            SetComments();
         }
      }
      else if (clickedObject == btnForceCloseAll)
      {
         bool selected = ObjectGetInteger(ChartID(), btnForceCloseAll, OBJPROP_STATE);
         if (selected)
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
            SetComments();
            PressButton(btnForceCloseAll);
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
   CheckOrders();
   if (IsTimeToRecreate() && (OpenType == OTDynamicRecreationAll || OpenType == OTDynamicRecreationThreshold))
   {
      CreateOrders();
   }
   
   SetComments();
   
   if (((IsTimeToClose()) || (StopTimeMode == STMForceCloseAll && IsInTimeRange(DailyStopTime)) || (StopTimeMode == STMForceCloseNoOpenOrder && (BuyCount + SellCount) == 0 && IsInTimeRange(DailyStopTime)))
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
      DrawButton(btnStartTrading, "Start Manually", 30, 270);
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

void CreateOrders()
{
   NoCorruptedCheck = true;
   bool InitialCreation = false;
   double CurrentUpperPrice = 0;
   double CurrentLowerPrice = 0;
   double MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLots = MarketInfo(Symbol(), MODE_MINLOT);
   int CreationCount = 0;
   
   if (LastLowerPrice == 0 && LastUpperPrice == 0) //First Cycle creation
   {
      InitialCreation = true;
      RefreshRates();
      CurrentUpperPrice = Ask;
      CurrentLowerPrice = Bid;
      
      DrawLine("lnASK", Ask, clrRed, 1, STYLE_DOT);
      DrawLine("lnBID", Bid, clrGray, 1, STYLE_DOT);
      
      CurrentUpperPrice = AddPoints(CurrentUpperPrice, CurrentPriceInterval);
      CurrentLowerPrice = AddPoints(CurrentLowerPrice, 0 - CurrentPriceInterval);
      
      DyOrderCountPerSide = OrderCountPerSide;
      CreationCount = OrderCountPerSide;
      
      if (TargetType == TTDynamic)
      {
         if (TargetProfitDynamicBase == DBBalance)
         {
            DyTargetProfit = AccountBalance() * TargetProfitMult;
         }
         else if (TargetProfitDynamicBase == DBEquity)
         {
            DyTargetProfit = AccountEquity() * TargetProfitMult;
         }
      }
      if (LossType == LTDynamic)
      {
         if (StopLossDynamicBase == DBEquity)
         {
            DyStopLoss = AccountBalance() * StopLossMult;
         }
         else if (StopLossDynamicBase == DBEquity)
         {
            DyStopLoss = AccountEquity() * StopLossMult;
         }
      }
      if (InitialLotsType == ILTDynamic)
      {
         DyStartingLots = NormalizeDouble(AccountBalance() * InitialLotsMult, 2);
      }
      else
      {
         DyStartingLots = InitialLots;
      }
      
      if (DyStartingLots < MinLots) DyStartingLots = MinLots;
      if (DyStartingLots > MaxLots) DyStartingLots = MaxLots;
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
      
      int Chk = 0;
      if (OrderOperation == StopOrders || (OrderOperation == FewLimitOrders && AllOrdersCount >= LimitOrdersCount))
      {
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_BUYSTOP, DyStartingLots, CurrentUpperPrice, 0, 0, 0, CommentInfo, MagicNumber);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(DyStartingLots, 2), DoubleToString(CurrentUpperPrice, Digits)));
         else
         {
            PendingBuyCount += 1; AllOrdersCount += 1;
         }
         
         Chk = 0;
         Chk = OrderSend(Symbol(), OP_SELLSTOP, DyStartingLots, CurrentLowerPrice, 0, 0, 0, CommentInfo, MagicNumber);
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
         Chk = OrderSend(Symbol(), OP_SELLLIMIT, DyStartingLots, CurrentUpperPrice, 0, 0, 0, CommentInfo, MagicNumber);
         if (Chk == -1)
            Alert(StringFormat("ERROR: %s, Lots: %s on Price: %s", GetErrorMessages("CreateOrders"), DoubleToString(DyStartingLots, 2), DoubleToString(CurrentUpperPrice, Digits)));
         else
         {
            PendingSellCount += 1; AllOrdersCount += 1;
         }

         Chk = 0;
         Chk = OrderSend(Symbol(), OP_BUYLIMIT, DyStartingLots, CurrentLowerPrice, 0, 0, 0, CommentInfo, MagicNumber);
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
   
   DrawLine("lnUPPERPRICE", LastUpperPrice, clrYellow, 1, STYLE_DOT);
   DrawLine("lnLOWERPRICE", LastLowerPrice, clrYellow, 1, STYLE_DOT);
   
   NoCorruptedCheck = false;
}

bool IsTimeToClose()
{
   bool IsTime = false;
   RefreshRates();
   double AskTH = AddPoints(Ask, (int)NormalizeDouble((CurrentPriceInterval / 5), 0));
   double BidTH = AddPoints(Bid, (int)(0 - NormalizeDouble((CurrentPriceInterval / 5), 0)));

   AskTH = Ask;
   BidTH = Bid;
   if (ActiveOrders)
   {
      if (
         (CloseType == CTMiddlePoint && (
            (TotalProfit >= TargetProfit && TargetType == TTFixed) || (LossType == LTFixed && TotalProfit <= StopLoss) || (TotalProfit >= DyTargetProfit && TargetType == TTDynamic) || (LossType == LTDynamic && TotalProfit <= DyStopLoss) || (AllPositiveProfit && Ask <= AskTH && Bid >= BidTH)))
         ||
         (CloseType == CTStandard && (
            (TotalProfit >= TargetProfit && TargetType == TTFixed) || (LossType == LTFixed && TotalProfit <= StopLoss) || (TotalProfit >= DyTargetProfit && TargetType == TTDynamic) || (LossType == LTDynamic && TotalProfit <= DyStopLoss)))
         ||
         (CloseType == CTAllOrdersExecuted && (
            (BuyCount == SellCount && BuyCount > 0 && BuyCount == DyOrderCountPerSide) || (TotalProfit >= TargetProfit && TargetType == TTFixed) || (LossType == LTFixed && TotalProfit <= StopLoss) || (TotalProfit >= DyTargetProfit && TargetType == TTDynamic) || (LossType == LTDynamic && TotalProfit <= DyStopLoss)))
      )
      {
         IsTime = true;
         Print("Istime");
      }
   }
   return IsTime;
}
bool IsInStartTimeRange()
{
   bool IsTime = false;
   CountStartEndTime();
   if (CurrentTime >= DailyStartDateTime && CurrentTime <= DailyStopDateTime)
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
      if (BuyCount == SellCount && BuyCount > 0 && BuyCount == DyOrderCountPerSide && OpenType == OTDynamicRecreationAll)
      {
         IsTime = true;
      }
      else if (OpenType == OTDynamicRecreationThreshold
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
   
   tUpperPrice = GetLinePrice("lnUPPERPRICE");
   tLowerPrice = GetLinePrice("lnLOWERPRICE");
   
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
         
         CurrentProfit = TotalProfit;
      }
   }
   
   if (ActiveOrders)
   {
      if (tUpperPrice > 0) LastUpperPrice = tUpperPrice;
      if (tLowerPrice > 0) LastLowerPrice = tLowerPrice;
   }
   
   if (BuyCount == SellCount && BuyCount == 0)
      AllPositiveProfit = false;
   
   if (AccountFreeMargin() < LowestMarginAvailable) LowestMarginAvailable = AccountFreeMargin();
   if (AccountEquity() < LowestEquityAvailable) LowestEquityAvailable = AccountEquity();
   
   if (TargetType == TTDynamic)
   {
      if (TargetProfitDynamicBase == DBBalance)
      {
         DyTargetProfit = AccountBalance() * TargetProfitMult;
      }
      else if (TargetProfitDynamicBase == DBEquity)
      {
         DyTargetProfit = AccountEquity() * TargetProfitMult;
      }
   }
   if (LossType == LTDynamic)
   {
      if (StopLossDynamicBase == DBEquity)
      {
         DyStopLoss = AccountEquity() * StopLossMult;
      }
   }
   
   if (ActiveOrders && OpenType == OTDynamicRecreationThreshold)
   {
      double UpperTHPrice = 0;
      double LowerTHPrice = 0;
      
      UpperTHPrice = AddPoints(LastUpperPrice, 0 - GridStepPoints - RecreationThreshold);
      LowerTHPrice = AddPoints(LastLowerPrice, GridStepPoints + RecreationThreshold);
      
      if (UpperTHPrice > 0)
         DrawLine("lnUPPERTH", UpperTHPrice, clrYellow, 1, STYLE_DASH);
      if (LowerTHPrice > 0)
         DrawLine("lnLOWERTH", LowerTHPrice, clrYellow, 1, STYLE_DASH);
   }
   else   
   {
      DeleteLine("lnUPPERTH");
      DeleteLine("lnLOWERTH");
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
   DeleteLine("lnBID");
   DeleteLine("lnASK");
   DeleteLine("lnUPPERPRICE");
   DeleteLine("lnLOWERPRICE");
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
   //Close Open Orders First
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
         
         if (Chk > 0)
            TotalProfit += GetProfit();
            
         if (IsTesting()) Sleep(500);
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

         if (IsTesting()) Sleep(500);
      }
   }
}

void CloseOrdersInsideOut()
{
   int ordticket[];
   ArrayResize(ordticket, OrdersTotal(), 1000);
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
      
   //Close Open Orders First
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
         
         if (Chk > 0)
            TotalProfit += GetProfit();
            
         if (IsTesting()) Sleep(500);
      }
   }
   //Delete Pending Orders
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

         if (IsTesting()) Sleep(500);
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
   if (DailyStopDateTime <= DailyStartDateTime)
      DailyStopDateTime += 86400; //adds 1 day.
}


void SetComments()
{
   string Cmt = "";
   string Spacer = StringAddMultiple(Space, 40);
   double Balance = AccountBalance();
   string Currency = AccountCurrency();
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
   Cmt += Spacer + StringFormat("CP: %s %s", DoubleToString(CurrentProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LastP: %s %s", DoubleToString(LastProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("BP: %s %s", DoubleToString(BiggestProfit, 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowP: %s %s", DoubleToString((LowestProfit > Balance ? 0 : LowestProfit), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowEq: %s %s", DoubleToString((LowestEquityAvailable > Balance ? 0 : LowestEquityAvailable), 2), Currency) + CrLf;
   Cmt += Spacer + StringFormat("LowMg: %s", DoubleToString((LowestMarginAvailable > Balance ? 0 : LowestMarginAvailable), 2)) + CrLf;
   Cmt += Spacer + StringFormat("Up and Low: %s --- %s", DoubleToString(LastUpperPrice, Digits), DoubleToString(LastLowerPrice, Digits)) + CrLf;
   Cmt += Spacer + StringFormat("Eq: %s %s, Bal: %s %s", DoubleToString(AccountEquity(), 2), Currency, DoubleToString(AccountBalance(), 2), Currency) + CrLf;
   
   if (StringLen(CommentInfo) > 0)
   {
      Cmt += Spacer + StringFormat("INFO: %s", CommentInfo) + CrLf;
   }
   
   if (TargetType == TTDynamic)
   {
      Cmt += Spacer + StringFormat("DyTgt: %s %s", DoubleToString(DyTargetProfit, 2), Currency) + CrLf;
   }
   else if (TargetType == TTFixed)
   {
      Cmt += Spacer + StringFormat("FxTgt: %s %s", DoubleToString(TargetProfit, 2), Currency) + CrLf;
   }
   if (InitialLotsType == ILTDynamic)
   {
      Cmt += Spacer + StringFormat("DyLot: %s", DoubleToString(DyStartingLots, 2)) + CrLf;
   }
   else if (InitialLotsType == ILTFixed)
   {
      Cmt += Spacer + StringFormat("FxLot: %s", DoubleToString(DyStartingLots, 2)) + CrLf;
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
   
   if (EnableMaxCycle)
   {
      Cmt += Spacer + StringFormat("Cyc: %s, Max: %s", IntegerToString(CycleCount), IntegerToString(MaxCycle)) + CrLf;
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
   color DefaultTextColor = clrWhite;
   color DefaultBgColor = clrBlueViolet;
   int DefaultX = 30;
   int DefaultY = 200;
   int DefaultWidth = 100;
   int DefaultHeight = 30;
   
   if ((ObjectFind(ChartID(), ctlName) > -1))
   {
      if (Operation == LODraw)
      {
         if (TextColor == clrNONE) TextColor = DefaultTextColor;
         if (BgColor == clrNONE) BgColor = DefaultBgColor;
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
      if (TextColor == clrNONE) TextColor = DefaultTextColor;
      if (BgColor == clrNONE) BgColor = DefaultBgColor;
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