// Time Frame 15M TP 5, pip step 5
#property strict
enum ENUM_LOT_MODE {
    LOT_MODE_FIXED = 1, // Fixed Lot
    LOT_MODE_PERCENT = 2, // Percent Lot
};
//--- input parameters
extern string               Version__ = "----------------------------------------------------------------";
extern string               Version1__ = "--------------------xBest  v2.2---------------------------------";
extern string               Version2__ = "----------------------------------------------------------------";
extern string               InpChartDisplay__ = "------------------------Display Info--------------------";
extern bool                 InpChartDisplay = TRUE;              // Display Info
extern bool                 InpDisplayInpBackgroundColor = TRUE;   // Display background color
extern color                InpBackgroundColor = Teal;            // background color

extern string Magic = "--------Magic Number---------";
input int                   InpMagic= 888888;    

extern int     bar1size          = 200;

extern string Config__ = "---------------------------Config--------------------------------------";
input int                  InpGridSize= 20;                // Step Size in Pips
input int                  InpTakeProfit= 20;              // Take Profit in Pips
input ENUM_LOT_MODE          InpLotMode= LOT_MODE_FIXED;    // Lot Mode
input double               InpFixedLot= 0.01;             // Fixed Lot
input double               InpPercentLot= 0.03;           // Percent Lot
input double               InpGridFactor= 1.6;            // Grid Increment Factor
input int                  InpHedge= 0;                  // Hedge After Level
input int                  InpDailyTarget= 0;    
input int                  TimeFrame=60;         // Khung Time H1 hoac H4


extern string FilterOpenOneCandle__ = "--------------------Filter One Order by Candle--------------";
input bool                 InpOpenOneCandle = true;          // Open one order by candle
input ENUM_TIMEFRAMES        InpTimeframeBarOpen = PERIOD_CURRENT; // Timeframe OpenOneCandle


extern string FilterSpread__ = "----------------------------Filter Max Spread--------------------";
input int                  InpMaxSpread = 20;               // Max Spread 

extern string EquityCaution__ = "------------------------Filter Caution of Equity ---------------";
extern bool                 InpUseEquityCaution = TRUE;            //  EquityCaution?
extern double               InpTotalEquityRiskCaution = 20;        // Total % Risk to EquityCaution
extern ENUM_TIMEFRAMES        InpTimeframeEquityCaution = PERIOD_D1; // Timeframe as EquityCaution

/////////////////////////////////////////////////////
extern string FFCall__ = "----------------------------Filter News FFCall------------------------";

extern int                  InpMinsBeforeNews = 60; // mins before an event to stay out of trading
extern int                  InpMinsAfterNews  = 20; // mins after  an event to stay out of trading
extern bool                 InpUseFFCall = false;
extern bool                 InpIncludeHigh = true;


///////////////////////////////////////////////
extern string TimeFilter__ = "-------------------------Filter DateTime---------------------------";
extern bool InpUtilizeTimeFilter = true;
extern bool InpTrade_in_Monday  = true;
extern bool InpTrade_in_Tuesday = true;
extern bool InpTrade_in_Wednesday= true;
extern bool InpTrade_in_Thursday= true;
extern bool InpTrade_in_Friday  = true;

extern string InpStartHour = "00:00"; //phiên Âu Mỹ từ 8h -> 21h
extern string InpEndHour   = "23:00"; //GMT+2 từ 10h -> 23h
bool               FractalsUp=false;
bool               FractalsDown=false;
double             FractalsUpPrice=0;
double             FractalsDownPrice=0;
int                FractalsLimit=200;
double   open1,//first candle Open price
open2,    //second candle Open price
close1,   //first candle Close price
close2,   //second candle Close price
low1,     //first candle Low price
low2,     //second candle Low price
high1,    //first candle High price
high2;    //second candle High price
//LOT_MODE_FIXED
//---
int SlipPage= 3;
int Spread= 2.0;
//---

string m_symbol;
bool m_news_time;
bool m_hedging1, m_target_filter1;
int m_direction1, m_current_day1, m_previous_day1;
double m_level1, m_buyer1, m_seller1, m_target1, m_profit1;
double m_pip1, m_size1, m_take1, m_spread1;
datetime   m_datetime_ultcandleopen1 ;
int m_spread;
bool m_initpainel;
string m_filters_on ;
datetime m_time_equityrisk ;
datetime timeBUOVB_BEOVB; 
double _bar1size; 


int Crossed1 (double line1 , double line2)

  
  {
    static int last_direction = 0;
    static int current_direction = 0;
    //Don't work in the first load, wait for the first cross!
    static bool first_time = true;
    if(first_time == true)
      {
        first_time = false;
        return (0);
      }
//----
    if(line1 > line2)
        current_direction = 1;  //up
    if(line1 < line2)
        current_direction = -1;  //down
        
//----
    if(current_direction != last_direction)  //changed 
      {
        last_direction = current_direction;
        return(last_direction);
      }
    else
      {
        return (0);  //not changed
      }
  }

// Function to check if it is news time
void NewsHandling()
{
     static int PrevMinute = -1;

    if (Minute() != PrevMinute) {
        PrevMinute = Minute();

        // Use this call to get ONLY impact of previous event
        int impactOfPrevEvent =
            iCustom(NULL, 0, "FFCal", true, true, false, true, true, 2, 0);

        // Use this call to get ONLY impact of nexy event
        int impactOfNextEvent =
            iCustom(NULL, 0, "FFCal", true, true, false, true, true, 2, 1);

        int minutesSincePrevEvent =
            iCustom(NULL, 0, "FFCal", true, true, false, true, false, 1, 0);

        int minutesUntilNextEvent =
            iCustom(NULL, 0, "FFCal", true, true, false, true, false, 1, 1);

        m_news_time = false;
        if ((minutesUntilNextEvent <= InpMinsBeforeNews) ||
            (minutesSincePrevEvent <= InpMinsAfterNews)) {
            m_news_time = true;
        }
    }
}//newshandling


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    //---
    m_symbol = Symbol();
    m_pip1 = 1.0 / MathPow(10, Digits - 1);
    m_size1 = InpGridSize * m_pip1;
    m_take1 = InpTakeProfit * m_pip1;
    m_hedging1 = false;
    m_target_filter1 = false;
    m_direction1 = 0;
    m_spread1 = 0.0;
    m_datetime_ultcandleopen1 = -1;
	m_time_equityrisk = -1;
	m_filters_on = "";
	m_initpainel = true;
	
  
    //---
    printf("xBest v2.2 - Grid Hedging Expert Advisor");
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    //---
}


void Informacoes() {
    double Ld_0;
    double Ld_8;
    double Ld_16;
    double Ld_24;
    double Ld_32;
    double Ld_40;
    double Ld_48;
    double Ld_56;
    string Ls_64;
    string Ls_72;
    int Li_84;

    if (!IsOptimization()) {

        Ls_64 = "==========================\n";
        Ls_64 = Ls_64 + " " + "xBest v2.2 2018-02-15 " + "\n";
        Ls_64 = Ls_64 + "==========================\n";
        Ls_64 = Ls_64 + "  Broker:  " + AccountCompany() + "\n";
        Ls_64 = Ls_64 + "  Time of Broker:" + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\n";
        Ls_64 = Ls_64 + "  Currenci: " + AccountCurrency() + "\n";
        Ls_64 = Ls_64 + "==========================\n";
        Ls_64 = Ls_64 + "  Grid Size : " + InpGridSize + " Pips \n";
        Ls_64 = Ls_64 + "  TakeProfit: " + InpTakeProfit + " Pips \n";
        Ls_64 = Ls_64 + "  Lot Mode : " + InpLotMode + "  \n";
        Ls_64 = Ls_64 + "  Exponent Factor: " + InpGridFactor + " pips\n";
        Ls_64 = Ls_64 + "  Daily Target: " + InpDailyTarget + "\n";
        Ls_64 = Ls_64 + "  Hedge After Level: " + InpHedge + " \n";
        Ls_64 = Ls_64 + "  InpMaxSpread: " + InpMaxSpread + " pips\n";
        Ls_64 = Ls_64 + "==========================\n";
        Ls_64 = Ls_64 + "  Orders Opens :   " + string(CountTrades()) + " \n";
        Ls_64 = Ls_64 + "  Spread: " + MarketInfo(Symbol(), MODE_SPREAD) + " \n";
        Ls_64 = Ls_64 + "  Profit/Loss: " + DoubleToStr(CalculateProfit(), 2) + " \n";
        Ls_64 = Ls_64 + "  Equity:      " + DoubleToStr(AccountEquity(), 2) + " \n";
        Ls_64 = Ls_64 + " ==========================\n";
        Ls_64 = Ls_64 + " EquityStopFilter : " + InpUseEquityCaution + " \n";
        Ls_64 = Ls_64 + " InpTotalEquityRiskCaution : " + DoubleToStr(InpTotalEquityRiskCaution, 2) + " \n";
        Ls_64 = Ls_64 + " NewsFilter : " + InpUseFFCall + " \n";
        Ls_64 = Ls_64 + " TimeFilter : " + InpUtilizeTimeFilter + " \n";
        Ls_64 = Ls_64 + " ==========================\n";
        Ls_64 = Ls_64 + m_filters_on;



        Comment(Ls_64);
        Li_84 = 14;
        if (InpDisplayInpBackgroundColor) {
            if (m_initpainel || Seconds() % 5 == 0) {
                m_initpainel = FALSE;
                for (int count_88 = 0; count_88 < 9; count_88++) {
                    for (int count_92 = 0; count_92 < Li_84; count_92++) {
                        ObjectDelete("background" + count_88 + count_92);
                        ObjectDelete("background" + count_88 + ((count_92 + 1)));
                        ObjectDelete("background" + count_88 + ((count_92 + 2)));
                        ObjectCreate("background" + count_88 + count_92, OBJ_LABEL, 0, 0, 0);
                        ObjectSetText("background" + count_88 + count_92, "n", 30, "Wingdings", InpBackgroundColor);
                        ObjectSet("background" + count_88 + count_92, OBJPROP_XDISTANCE, 20 * count_88);
                        ObjectSet("background" + count_88 + count_92, OBJPROP_YDISTANCE, 23 * count_92 + 9);
                    }
                }
            }
        } else {
            if (m_initpainel || Seconds() % 5 == 0) {
                m_initpainel = FALSE;
                for (int count_88 = 0; count_88 < 9; count_88++) {
                    for (int count_92 = 0; count_92 < Li_84; count_92++) {
                        ObjectDelete("background" + count_88 + count_92);
                        ObjectDelete("background" + count_88 + ((count_92 + 1)));
                        ObjectDelete("background" + count_88 + ((count_92 + 2)));

                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {


   
    if (InpChartDisplay)
        Informacoes();

    RefreshRates();

    m_filters_on = "";

    //FILTER SPREAD
    m_spread = MarketInfo(Symbol(), MODE_SPREAD);
    if (m_spread > InpMaxSpread) {
        m_filters_on += "Filter InpMaxSpread ON \n";
        return;

    }

    //FILTER NEWS
    if (InpUseFFCall)
        NewsHandling();

    if (m_news_time && InpUseFFCall) {
        m_filters_on += "Filter News ON \n";
        return;

    }

	//FILTER DATETIME
    if (InpUtilizeTimeFilter && !TimeFilter()) 
    {
        m_filters_on += "Filter TimeFilter ON \n";
    }
    
	//FILTER EquityCaution
    if (CountTrades(InpMagic) == 0) m_time_equityrisk = -1;

    if (m_time_equityrisk == iTime(NULL, InpTimeframeEquityCaution, 0)) 
    {
        m_filters_on += "Filter EquityCaution  ON \n";
		
		//SEND ALERT?
		
		 return;
    }  
    
    xBest(0, InpMagic, m_hedging1, m_target_filter1, m_direction1, m_current_day1, m_previous_day1, m_level1, m_buyer1, m_seller1, m_target1, m_profit1, m_pip1, m_size1, m_take1, m_spread1, m_datetime_ultcandleopen1);

}


void xBest(int Id, int vInpMagic, bool& m_hedging, bool& m_target_filter,
    int& m_direction, int& m_current_day, int& m_previous_day,
    double& m_level, double& m_buyer, double& m_seller, double& m_target, double& m_profit ,
    double& m_pip, double& m_size, double& m_take, double& m_spread,  datetime&   vDatetimeUltCandleOpen 
){


    //--- Variable Declaration
    int T,index, orders_total, order_ticket, order_type, ticket, hour;
    double volume_min, volume_max, volume_step, lots;
    double account_balance, margin_required, risk_balance;
    double order_open_price, order_lots;

    //--- Variable Initialization
    int buy_ticket= 0, sell_ticket = 0;
    int buyer_counter= 0, seller_counter = 0, orders_count = 0;
    bool was_trade= false, close_filter = false;
    bool long_condition= false, short_condition = false;
    double orders_profit= 0.0, level = 0.0;
    double buyer_lots= 0.0, seller_lots = 0.0;
    double buyer_sum= 0.0, seller_sum = 0.0;
    double buy_price= 0.0, sell_price = 0.0;
    double bid_price= Bid, ask_price = Ask;
    double close_price_1= iClose(NULL, 0, 1);
    double close_price_2= iClose(NULL, 0, 2);
    double open_price_01= iOpen(NULL, 0, 1);
    double open_price_02= iOpen(NULL, 0, 2);
	 datetime time_current= TimeCurrent();
	 double   _point   = MarketInfo(Symbol(), MODE_POINT);
	 double  EMA3=iMA(NULL,0,3,0,MODE_EMA,PRICE_CLOSE,2);
	 double  EMA30=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,2);
	 double  Stoc  =iStochastic(NULL,0,9,3,5,MODE_SMA,0,MODE_MAIN,2);
    open1        = NormalizeDouble(iOpen(Symbol(), Period(), 1), Digits);
   open2        = NormalizeDouble(iOpen(Symbol(), Period(), 2), Digits);
   close1       = NormalizeDouble(iClose(Symbol(), Period(), 1), Digits);
   close2       = NormalizeDouble(iClose(Symbol(), Period(), 2), Digits);
   low1         = NormalizeDouble(iLow(Symbol(), Period(), 1), Digits);
   low2         = NormalizeDouble(iLow(Symbol(), Period(), 2), Digits);
   high1        = NormalizeDouble(iHigh(Symbol(), Period(), 1), Digits);
   high2        = NormalizeDouble(iHigh(Symbol(), Period(), 2), Digits);
    _bar1size=NormalizeDouble(((high1-low1)/_point),0);
   double TENKAN_SEN=iIchimoku(NULL,0,9,26,52,MODE_TENKANSEN,1);       //RED LINE
   double KIJUN_SEN=iIchimoku(NULL,0,9,26,52,MODE_KIJUNSEN,1);         //BLUE LINE
   double SENKOU_SPANA=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,1);   //ORANGE DOT CLOUD LINE
   double SENKOU_SPANB=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,1);   //PINK DOT CLOUD LINE
    
        //--- Base Lot Size
    account_balance = AccountBalance();
    volume_min = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
    volume_max = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
    volume_step = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
    lots = volume_min;
    
 
    if (InpLotMode == LOT_MODE_FIXED) lots = InpFixedLot;
    else if (InpLotMode == LOT_MODE_PERCENT) {
        risk_balance = InpPercentLot * AccountBalance() / 100.0;
        margin_required = MarketInfo(m_symbol, MODE_MARGINREQUIRED);
        lots = MathRound(risk_balance / margin_required, volume_step);
        if (lots < volume_min) lots = volume_min;
        if (lots > volume_max) lots = volume_max;
    }

    //--- Daily Calc
    m_current_day = TimeDayOfWeek(time_current);
    if (m_current_day != m_previous_day) {
        m_target_filter = false;
        m_target = 0.0;
    }
    m_previous_day = m_current_day;

    //--- Calculation Loop
    orders_total = OrdersTotal();
    for (index = orders_total - 1; index >= 0; index--) {
        if (!OrderSelect(index, SELECT_BY_POS, MODE_TRADES)) continue;
        if (OrderMagicNumber() != vInpMagic || OrderSymbol() != m_symbol) continue;
        order_open_price = OrderOpenPrice(); order_ticket = OrderTicket();
        order_type = OrderType(); order_lots = OrderLots();
        //---
        
        if (order_type == OP_BUY  ) 
            {
            //--- Set Last Buy Order
            if (order_ticket > buy_ticket) {
                buy_price = order_open_price;
                buy_ticket = order_ticket;
            }
            buyer_sum += (order_open_price + m_spread) * order_lots;
            buyer_lots += order_lots;
            buyer_counter++;
            
            } 
        
       
        //---
       
       
        if (order_type == OP_SELL ) 
            {
            //--- Set Last Sell Order
            if (order_ticket > sell_ticket) {
                sell_price = order_open_price;
                sell_ticket = order_ticket;
            }
            seller_sum += (order_open_price - m_spread) * order_lots;
            seller_lots += order_lots;
            seller_counter++;
            } 
               //---
        orders_profit += OrderProfit();
        orders_count++;
        } 
        
    
    m_profit = orders_profit;

    //--- Calc
    if (orders_count == 0) {
        m_target += m_profit;
        m_hedging = false;
    }

    //--- Close Conditions
    if (InpDailyTarget > 0 && m_target + orders_profit >= InpDailyTarget) m_target_filter = true;
    //--- This ensure that buy and sell positions close at the same time when hedging is enabled
    if (m_hedging && ((m_direction > 0 && bid_price >= m_level) || (m_direction < 0 && ask_price <= m_level))) close_filter = true;

    //--- Close All Orders on Conditions
    if (m_target_filter || close_filter ) {
        orders_total = OrdersTotal();
        for (index = orders_total - 1; index >= 0; index--) {
            if (!OrderSelect(index, SELECT_BY_POS, MODE_TRADES)) continue;
            if (OrderMagicNumber() != vInpMagic || OrderSymbol() != m_symbol) continue;
            order_type = OrderType();
            if (order_type == OP_BUY ) OrderClose(OrderTicket(), OrderLots(), bid_price, SlipPage);
            if (order_type == OP_SELL ) OrderClose(OrderTicket(), OrderLots(), ask_price, SlipPage);
        }
        m_spread = 0.0;
        return;
    }
      
    //--- Open Trade Conditions
    if (!m_hedging) {
        if (orders_count > 0) {
            if (buyer_counter > 0 && buy_price - ask_price >= m_size) long_condition = true;
            if (seller_counter > 0 && bid_price - sell_price >= m_size) short_condition = true;
        } else {
            hour = TimeHour(time_current);
            if (!InpUtilizeTimeFilter || (InpUtilizeTimeFilter && TimeFilter())) 
            {
      //      if (EMA3<EMA30)
      //      if((iHigh(Symbol(),0,1)>=TENKAN_SEN && iOpen(Symbol(),0,0)<TENKAN_SEN)
      //      ||(iHigh(Symbol(),0,1)>=KIJUN_SEN && iOpen(Symbol(),0,0)<KIJUN_SEN)
      //      ||(iHigh(Symbol(),0,1)>=SENKOU_SPANA && iOpen(Symbol(),0,0)<SENKOU_SPANA)
      //      ||(iHigh(Symbol(),0,1)>=SENKOU_SPANB && iOpen(Symbol(),0,0)<SENKOU_SPANB))
               if(timeBUOVB_BEOVB!=iTime(Symbol(),Period(),1) && // orders are not yet opened for this pattern 
      _bar1size>bar1size && //first bar is big enough not to consider a flat market
      low1 < low2 &&        //First bar's Low is below second bar's Low
      high1 > high2 &&      //First bar's High is above second bar's High
      close1 < open2 &&     //First bar's Close price is lower than second bar's Open price
      open1 > close1 &&     //First bar is a bearish bar
      open2 < close2)       //Second bar is a bullish bar
                   { short_condition = true;
                    timeBUOVB_BEOVB=iTime(Symbol(),Period(),1);
                    }
       //    if (EMA3>EMA30)         
       //    if((iLow(Symbol(),0,1)<=TENKAN_SEN && iOpen(Symbol(),0,0)>TENKAN_SEN)
       //     ||(iLow(Symbol(),0,1)<=KIJUN_SEN&& iOpen(Symbol(),0,0)>KIJUN_SEN)
       //     ||(iLow(Symbol(),0,1)<=SENKOU_SPANA&& iOpen(Symbol(),0,0)>SENKOU_SPANA)
       //     ||(iLow(Symbol(),0,1)<=SENKOU_SPANB&& iOpen(Symbol(),0,0)>SENKOU_SPANB))
               if(timeBUOVB_BEOVB!=iTime(Symbol(),Period(),1) && // orders are not yet opened for this pattern 
      _bar1size>bar1size && //first bar is big enough not to consider a flat market
      low1 < low2 &&      //First bar's Low is below second bar's Low
      high1 > high2 &&    //First bar's High is above second bar's High
      close1 > open2 &&   //First bar's Close price is higher than second bar's Open price
      open1 < close1 &&   //First bar is a bullish bar
      open2 > close2)     //Second bar is a bearish bar
                  {  long_condition = true;
                    timeBUOVB_BEOVB=iTime(Symbol(),Period(),1);
                    }
               

            }


        }
    } else {
        if (m_direction > 0 && bid_price <= m_seller) short_condition = true;
        if (m_direction < 0 && ask_price >= m_buyer) long_condition = true;
    }


     // CONTROL DRAWDOWN
     double vProfit = CalculateProfit(vInpMagic);

     if (vProfit < 0.0 && MathAbs(vProfit) > InpTotalEquityRiskCaution / 100.0 * AccountEquity()) {
            m_time_equityrisk = iTime(NULL, InpTimeframeEquityCaution, 0);
     } else { 
	        m_time_equityrisk = -1; 
	 }
    
    //--- Hedging
    if (InpHedge > 0 && !m_hedging) {
        if (long_condition && buyer_counter == InpHedge) {
            m_spread = Spread * m_pip;
            m_seller = bid_price;
            m_hedging = true;
            return;
        }
        if (short_condition && seller_counter == InpHedge) {
            m_spread = Spread * m_pip;
            m_buyer = ask_price;
            m_hedging = true;
            return;
        }
    }

    //--- Lot Size
    lots = MathRound(lots * MathPow(InpGridFactor, orders_count), volume_step);
    if (m_hedging) {
        if (long_condition) lots = MathRound(seller_lots * InpGridFactor, volume_step) - buyer_lots;
        if (short_condition) lots = MathRound(buyer_lots * InpGridFactor, volume_step) - seller_lots;
    }
    if (lots < volume_min) lots = volume_min;
    if (lots > volume_max) lots = volume_max;

    //--- Open Trades Based on Conditions
    if (!InpOpenOneCandle || (InpOpenOneCandle && vDatetimeUltCandleOpen != iTime(NULL, InpTimeframeBarOpen, 0))) {
        vDatetimeUltCandleOpen = iTime(NULL, InpTimeframeBarOpen, 0);
        if (long_condition) {
            if (buyer_lots + lots == seller_lots) lots = seller_lots + volume_min;
            ticket = OpenTrade(OP_BUY, lots, ask_price, vInpMagic);
            if (ticket > 0) {
                OrderSelect(ticket, SELECT_BY_TICKET);
                order_open_price = OrderOpenPrice(); buyer_sum += order_open_price * lots; buyer_lots += lots;
                m_level = NormalizeDouble((buyer_sum - seller_sum) / (buyer_lots - seller_lots), Digits) + m_take;
                if (!m_hedging) level = m_level; else level = m_level + m_take;
                if (buyer_counter == 0) m_buyer = order_open_price;
                m_direction = 1; was_trade = true;
            }
        }
		
        if (short_condition) {
            if (seller_lots + lots == buyer_lots) lots = buyer_lots + volume_min;
            ticket = OpenTrade(OP_SELL, lots, bid_price, vInpMagic);
            if (ticket > 0) {
                OrderSelect(ticket, SELECT_BY_TICKET);
                order_open_price = OrderOpenPrice(); seller_sum += order_open_price * lots; seller_lots += lots;
                m_level = NormalizeDouble((seller_sum - buyer_sum) / (seller_lots - buyer_lots), Digits) - m_take;
                if (!m_hedging) level = m_level; else level = m_level - m_take;
                if (seller_counter == 0) m_seller = order_open_price;
                m_direction = -1; was_trade = true;
            }
        }
       
    }

    //--- Setup Global Take Profit
    if (was_trade) {
        orders_total = OrdersTotal();
        for (index = orders_total - 1; index >= 0; index--) {
            if (!OrderSelect(index, SELECT_BY_POS, MODE_TRADES)) continue;
            if (OrderMagicNumber() != vInpMagic || OrderSymbol() != m_symbol) continue;
            order_type = OrderType();
            if (m_direction > 0) {
                if (order_type == OP_BUY) OrderModify(OrderTicket(), OrderOpenPrice(), 0.0, level, 0);
                if (order_type == OP_SELL) OrderModify(OrderTicket(), OrderOpenPrice(), level, 0.0, 0);
            }
            if (m_direction < 0) {
                if (order_type == OP_BUY) OrderModify(OrderTicket(), OrderOpenPrice(), level, 0.0, 0);
                if (order_type == OP_SELL) OrderModify(OrderTicket(), OrderOpenPrice(), 0.0, level, 0);
            }
        }
    }


}

//+------------------------------------------------------------------+
int OpenTrade(int cmd, double volume, double price, int vInpMagic , double stop= 0.0, double take= 0.0) {
    return OrderSend(m_symbol, cmd, volume, price, SlipPage, stop, take, NULL, vInpMagic, 0);
}
double MathRound(double x, double m) { return m * MathRound(x / m); }
double MathFloor(double x, double m) { return m * MathFloor(x / m); }
double MathCeil (double x, double m) { return m * MathCeil(x / m); }


int CountTrades() {
    int l_count_0 = 0;
    for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
        if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != InpMagic )) continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == InpMagic ))
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
    }
    return (l_count_0);
}


int CountTrades(int vInpMagic) {
    int l_count_0 = 0;
    for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
        if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic)) continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
    }
    return (l_count_0);
}


int CountTradesSell(int vInpMagic) {
    int l_count_0 = 0;
    for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
        if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic)) continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
            if (OrderType() == OP_SELL) l_count_0++;
    }
    return (l_count_0);
}

int CountTradesBuy(int vInpMagic) {
    int l_count_0 = 0;
    for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
        if (!OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic)) continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
            if (OrderType() == OP_BUY) l_count_0++;
    }
    return (l_count_0);
}

double CalculateProfit() {
    double ld_ret_0 = 0;
    for (int g_pos_344 = OrdersTotal() - 1; g_pos_344 >= 0; g_pos_344--) {
        if (!OrderSelect(g_pos_344, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != InpMagic )) continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == InpMagic ))
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
    }
    return (ld_ret_0);
}


double CalculateProfit(int vInpMagic) {
    double ld_ret_0 = 0;
    for (int g_pos_344 = OrdersTotal() - 1; g_pos_344 >= 0; g_pos_344--) {
        if (!OrderSelect(g_pos_344, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != vInpMagic)) continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == vInpMagic))
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
    }
    return (ld_ret_0);
}
bool TimeFilter(){

    bool _res = false;
    datetime _time_curent = TimeCurrent();
    datetime _time_start = StrToTime(DoubleToStr(Year(), 0) + "." + DoubleToStr(Month(), 0) + "." + DoubleToStr(Day(), 0) + " " + InpStartHour);
    datetime _time_stop = StrToTime(DoubleToStr(Year(), 0) + "." + DoubleToStr(Month(), 0) + "." + DoubleToStr(Day(), 0) + " " + InpEndHour);
    if (((InpTrade_in_Monday == true) && (TimeDayOfWeek(Time[0]) == 1)) ||
        ((InpTrade_in_Tuesday == true) && (TimeDayOfWeek(Time[0]) == 2)) ||
        ((InpTrade_in_Wednesday == true) && (TimeDayOfWeek(Time[0]) == 3)) ||
        ((InpTrade_in_Thursday == true) && (TimeDayOfWeek(Time[0]) == 4)) ||
        ((InpTrade_in_Friday == true) && (TimeDayOfWeek(Time[0]) == 5)))


        if (_time_start > _time_stop) {
            if (_time_curent >= _time_start || _time_curent <= _time_stop) _res = true;
        } else
            if (_time_curent >= _time_start && _time_curent <= _time_stop) _res = true;

    return (_res);

}


bool isCloseLastOrderNotProfit(int MagicNumber) {
  datetime t;
  double   ocp, osl, otp;
  int      i, j=-1, k=OrdersHistoryTotal();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber()==MagicNumber) {
              if (t<OrderCloseTime()) {
                t=OrderCloseTime();
                j=i;
              }
            }
        }
    }
  }
  if (OrderSelect(j, SELECT_BY_POS, MODE_HISTORY)) {
    ocp=NormalizeDouble(OrderClosePrice(), Digits);
    osl=NormalizeDouble(OrderStopLoss(), Digits);
    otp=NormalizeDouble(OrderTakeProfit(), Digits);
    if (OrderProfit() < 0 ) return(True);
  }
  return(False);

}
void CloseAll()
  {
   for(int OrdersOT=OrdersTotal()-1; OrdersOT>=0; OrdersOT--)
     {
      if(!OrderSelect(OrdersOT,SELECT_BY_POS,MODE_TRADES) || OrderMagicNumber()!=1){continue;}
      OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Magic,clrNONE);
     }
  }
double PRICEACTON()
  {
 
//Initialization of the variables
   FractalsUp=false;
   FractalsDown=false;
   FractalsUpPrice=0;
   FractalsDownPrice=0;

//For loop to scan the last FractalsLimit candles starting from the oldest and finishing with the most recent
   for(int i=FractalsLimit; i>=0; i--)
     {
      //If there is a fractal on the candle the value will be greater than zero and equal to the highest or lowest price
      double fu=iFractals(NULL,TimeFrame,MODE_UPPER,i);
      double fd=iFractals(NULL,TimeFrame,MODE_LOWER,i);
      //If there is an upper fractal I store the value and set true the FractalsUp variable
      if(fu>0)
        {
       if(Low[4]<fu && Low[3]<fu && Low[2]>=fu &&Open[2]>Close[2]
           &&Close[1]<fu&&Open[1]>Close[1])
 
         Print("FractalsUpPrice",FractalsUpPrice);
         return(2);
        }
      //If there is an lower fractal I store the value and set true the FractalsDown variable
      if(fd>0)
        {
    if(Low[4]>fd && Low[3] >fd  && Low[2] <=fd  &&Open[2]>Close[2]
           &&Close[1]>fd&&Open[1]<Close[1])
         Print("FractalsDownPrice",FractalsDownPrice);
         return(1);
        }
      //if the candle has both upper and lower fractal the values are stored but we do not consider it as last fractal
      if(fu>0 && fd>0)
        {
         FractalsUp=false;
         FractalsDown=false;
         FractalsUpPrice=fu;
         FractalsDownPrice=fd;
         return(0);
        }
     }
   return(0);
  }