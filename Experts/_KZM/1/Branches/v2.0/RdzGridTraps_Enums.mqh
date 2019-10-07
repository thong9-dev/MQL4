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
   CTProfitMinOrders = 5, //Target Based OR Min Profit Open Orders
   CTThresholdAllOrdersExtd = 6 //Target Based OR Threshold OR All Orders Opened
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
enum enDynamicProfitBase
{
   DPBBalance = 0, //Balance
   DPBEquity = 1, //Equity
   DPBLotSize = 2 //Lot Size
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
enum enTimeExecutionCodeStatus
{
   TECSIdle = 0, //Idle
   TECSOutOfTimeRangeWaitEx = 1, //Out of Time Range Waiting for Execution
   TECSOutOfTimeRangeExtd = 2, //Out of Time Range Executed
   TECSInTimeRangeWaitEx = 3, //In Time Range Waiting for Execution
   TECSInTimeRangeExtd = 4, //In Time Range Executed
   TECSOutOfTimeRangeInactiveWaitEx = 5 //Out of Time Range and First Inactive Waiting for Execution
};
enum enCloseOrdersMode
{
   COMDefault = 0,
   COMPendingBuy = 1,
   COMPendingSell = 2,
   COMAllBuy = 3,
   COMAllSell = 4
};

enum enOrderSide
{
   OSUnidentified = 0, //Unidentified
   OSUpperSide = 1, //Upper Side
   OSLowerSide = 2 //Lower Side
};
enum enOrderStatus
{
   ORDSTOrdered = -1,
   ORDSTPending = 0,
   ORDSTOpen = 1,
   ORDSTDeleted = 2,
   ORDSTClosed = 3,
   ORDSTOpenAbandoned = 4
};