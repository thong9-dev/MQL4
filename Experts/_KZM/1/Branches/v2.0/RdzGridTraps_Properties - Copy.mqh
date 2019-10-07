//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "RdzGridTraps_Enums.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtPriceLevel
  {
   double            UpperPrice;
   double            LowerPrice;

   bool IsEmpty()
     {
      return (LowerPrice <= 0 && UpperPrice <= 0);
     };
   void Reset()
     {
      UpperPrice = 0;
      LowerPrice = 0;
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtGridOrder
  {
   int               MagicNumber;
   int               Ticket;
   double            Profit;
   double            ActualOpenPrice;
   double            OpenPrice;
   double            LotSize;
   double            TakeProfitPrice;
   double            StopLossPrice;
   int               Slippage;
   string            Comments;
   enOrderSide       Side;
   enOrderStatus     Status;
   int               Type;
   bool              IsContainInfo;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtGridLevel
  {
   gtGridOrder       Upper;
   gtGridOrder       Lower;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtDateTimes
  {
   datetime          Current;
   datetime          DailyStart;
   datetime          DailyStop;
   datetime          WeeklyStart;
   datetime          WeeklyEnd;

   bool IsInTimeWindow()
     {
      bool IsTime=false;
      if(
         ((Current>=DailyStart && Current<=DailyStop) || (DailyStart>DailyStop && DailyStop>Current))
         && 
         ((Current>=WeeklyStart && Current<=WeeklyEnd) || (WeeklyStart>WeeklyEnd && WeeklyEnd>Current))
         )
        {
         IsTime=true;
        }
      return IsTime;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtPrices
  {
   gtPriceLevel      Last;
   gtPriceLevel      Initial;
   gtPriceLevel      MiddlePointRange;
   gtPriceLevel      AutoExpandThreshold;
   gtPriceLevel      CloseThreshold;

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtCounter
  {
   int               OpenedBuys;
   int               OpenedSells;
   int               PendingBuys;
   int               PendingSells;
   int               CurrentCycle;
   int               HighestOpened;//combination of highest buys or highest sells
   int               AutoExpand; //?

   int AllBuyOrders()
     {
      return (OpenedBuys + PendingBuys);
     };
   int AllSellOrders()
     {
      return (OpenedSells + PendingSells);
     };
   int OpenedOrders()
     {
      return (OpenedBuys + OpenedSells);
     };
   int PendingOrders()
     {
      return (PendingBuys + PendingSells);
     };
   int AllOrders()
     {
      return (OpenedBuys + OpenedSells + PendingBuys + PendingSells);
     };

   bool SameOpened()
     {
      return (OpenedBuys == OpenedSells);
     };

   void ResetOrderCounter()
     {
      OpenedBuys=0;
      OpenedSells = 0;
      PendingBuys = 0;
      PendingSells= 0;
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtSymbolProp
  {
   double            MaxLots;
   double            MinLots;
   double            LotsStep;

   void Reset()
     {
      MaxLots = 0;
      MinLots = 0;
      LotsStep= 0;
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtChecker
  {
   bool              InProfit; //replacement for AllPositiveProfit
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct gtProperties
  {
   bool              IsInitialized; //to identify whether the EA is running or first time run

   gtDateTimes       DateTimeInfo;
   gtGridLevel       GridLevels[];
   gtPrices          Prices;
   gtSymbolProp      SymbolProperties;
   gtCounter         Counter;
   gtChecker         Checker;

   int               OrderCountPerSide; //DyOrderCountPerSide
   double            TargetProfit; //DyTargetProfit
   double            StopLoss; //DyStopLoss
   double            InitialLots; //DyStartingLots
  };
//+------------------------------------------------------------------+
