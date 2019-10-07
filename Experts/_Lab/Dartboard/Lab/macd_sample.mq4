//+------------------------------------------------------------------+
//|                                                  MACD Sample.mq5 |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2009-2013, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property version     "5.20"
#property description "It is important to make sure that the expert works with a normal"
#property description "chart and the user did not make any mistakes setting input"
#property description "variables (Lots, TakeProfit, TrailingStop) in our case,"
#property description "we check TakeProfit on a chart of more than 2*trend_period bars"
//---
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include "PanelDialog2.mqh"
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;
//--- input parameters
input bool     InpMail=false;          // Notify by email
input bool     InpPush=false;          // Notify by push
input bool     InpAlert=true;          // Notify by alert
//---
input double   InpLots          =0.1;  // Lots
input int      InpTakeProfit    =50;   // Take Profit (in pips)
input int      InpTrailingStop  =30;   // Trailing Stop Level (in pips)
input int      InpMACDOpenLevel =3;    // MACD open level (in pips)
input int      InpMACDCloseLevel=2;    // MACD close level (in pips)
input int      InpMATrendPeriod =26;   // MA trend period
//--- ext variables
bool           ExtMail;
bool           ExtPush;
bool           ExtAlert;

double         ExtLots;
int            ExtTakeProfit;
int            ExtTrailingStop;
int            ExtMACDOpenLevel;
int            ExtMACDCloseLevel;
int            ExtMATrendPeriod;
//---
int            ExtTimeOut=10; // time out in seconds between trade operations
bool           bool_tester=false;      // true - mode tester
//+------------------------------------------------------------------+
//| MACD Sample expert class                                         |
//+------------------------------------------------------------------+
class CSampleExpert
  {
protected:
   double            m_adjusted_point;             // point value adjusted for 3 or 5 points
   CTrade            m_trade;                      // trading object
   CSymbolInfo       m_symbol;                     // symbol info object
   CPositionInfo     m_position;                   // trade position object
   CAccountInfo      m_account;                    // account info wrapper
   //--- indicators
   int               m_handle_macd;                // MACD indicator handle
   int               m_handle_ema;                 // moving average indicator handle
   //--- indicator buffers
   double            m_buff_MACD_main[];           // MACD indicator main buffer
   double            m_buff_MACD_signal[];         // MACD indicator signal buffer
   double            m_buff_EMA[];                 // EMA indicator buffer
   //--- indicator data for processing
   double            m_macd_current;
   double            m_macd_previous;
   double            m_signal_current;
   double            m_signal_previous;
   double            m_ema_current;
   double            m_ema_previous;
   //---
   double            m_macd_open_level;
   double            m_macd_close_level;
   double            m_traling_stop;
   double            m_take_profit;

public:
                     CSampleExpert(void);
                    ~CSampleExpert(void);
   bool              Init(void);
   void              Deinit(void);
   bool              Processing(void);

protected:
   bool              InitCheckParameters(const int digits_adjust);
   bool              InitIndicators(void);
   bool              LongClosed(void);
   bool              ShortClosed(void);
   bool              LongModified(void);
   bool              ShortModified(void);
   bool              LongOpened(void);
   bool              ShortOpened(void);
  };
//--- global expert
CSampleExpert ExtExpert;
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSampleExpert::CSampleExpert(void) : m_adjusted_point(0),
                                     m_handle_macd(INVALID_HANDLE),
                                     m_handle_ema(INVALID_HANDLE),
                                     m_macd_current(0),
                                     m_macd_previous(0),
                                     m_signal_current(0),
                                     m_signal_previous(0),
                                     m_ema_current(0),
                                     m_ema_previous(0),
                                     m_macd_open_level(0),
                                     m_macd_close_level(0),
                                     m_traling_stop(0),
                                     m_take_profit(0)
  {
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);
   ArraySetAsSeries(m_buff_EMA,true);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSampleExpert::~CSampleExpert(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization and checking for input parameters                 |
//+------------------------------------------------------------------+
bool CSampleExpert::Init(void)
  {
//--- initialize common information
   m_symbol.Name(Symbol());              // symbol
   m_trade.SetExpertMagicNumber(12345);  // magic
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- set default deviation for trading in adjusted points
   m_macd_open_level =ExtMACDOpenLevel*m_adjusted_point;
   m_macd_close_level=ExtMACDCloseLevel*m_adjusted_point;
   m_traling_stop    =ExtTrailingStop*m_adjusted_point;
   m_take_profit     =ExtTakeProfit*m_adjusted_point;
//--- set default deviation for trading in adjusted points
   m_trade.SetDeviationInPoints(3*digits_adjust);
//---
   if(!InitCheckParameters(digits_adjust))
      return(false);
   if(!InitIndicators())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking for input parameters                                    |
//+------------------------------------------------------------------+
bool CSampleExpert::InitCheckParameters(const int digits_adjust)
  {
//--- initial data checks
   if(ExtTakeProfit*digits_adjust<m_symbol.StopsLevel())
     {
      printf("Take Profit must be greater than %d",m_symbol.StopsLevel());
      return(false);
     }
   if(ExtTrailingStop*digits_adjust<m_symbol.StopsLevel())
     {
      printf("Trailing Stop must be greater than %d",m_symbol.StopsLevel());
      return(false);
     }
//--- check for right lots amount
   if(ExtLots<m_symbol.LotsMin() || ExtLots>m_symbol.LotsMax())
     {
      printf("Lots amount must be in the range from %f to %f",m_symbol.LotsMin(),m_symbol.LotsMax());
      return(false);
     }
   if(MathAbs(ExtLots/m_symbol.LotsStep()-MathRound(ExtLots/m_symbol.LotsStep()))>1.0E-10)
     {
      printf("Lots amount is not corresponding with lot step %f",m_symbol.LotsStep());
      return(false);
     }
//--- warning
   if(ExtTakeProfit<=ExtTrailingStop)
      printf("Warning: Trailing Stop must be less than Take Profit");
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the indicators                                 |
//+------------------------------------------------------------------+
bool CSampleExpert::InitIndicators(void)
  {
//--- create MACD indicator
   if(m_handle_macd==INVALID_HANDLE)
      if((m_handle_macd=iMACD(NULL,0,12,26,9,PRICE_CLOSE))==INVALID_HANDLE)
        {
         printf("Error creating MACD indicator");
         return(false);
        }
//--- create EMA indicator and add it to collection
   if(m_handle_ema==INVALID_HANDLE)
      if((m_handle_ema=iMA(NULL,0,ExtMATrendPeriod,0,MODE_EMA,PRICE_CLOSE))==INVALID_HANDLE)
        {
         printf("Error creating EMA indicator");
         return(false);
        }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Check for long position closing                                  |
//+------------------------------------------------------------------+
bool CSampleExpert::LongClosed(void)
  {
   bool res=false;
//--- should it be closed?
   if(m_macd_current>0)
      if(m_macd_current<m_signal_current && m_macd_previous>m_signal_previous)
         if(m_macd_current>m_macd_close_level)
           {
            //--- close position
            string text="";
            if(m_trade.PositionClose(Symbol()))
              {
               text="Long position by "+Symbol()+" to be closed";
               Notifications(text);
               printf("Long position by %s to be closed",Symbol());
              }
            else
              {
               text="Error closing position by "+Symbol()+" : '"+m_trade.ResultComment()+"'";
               Notifications(text);
               printf("Error closing position by %s : '%s'",Symbol(),m_trade.ResultComment());
              }
            //--- processed and cannot be modified
            res=true;
           }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for short position closing                                 |
//+------------------------------------------------------------------+
bool CSampleExpert::ShortClosed(void)
  {
   bool res=false;
//--- should it be closed?
   if(m_macd_current<0)
      if(m_macd_current>m_signal_current && m_macd_previous<m_signal_previous)
         if(MathAbs(m_macd_current)>m_macd_close_level)
           {
            //--- close position
            string text="";
            if(m_trade.PositionClose(Symbol()))
              {
               text="Short position by "+Symbol()+" to be closed";
               Notifications(text);
               printf("Short position by %s to be closed",Symbol());
              }
            else
              {
               text="Error closing position by "+Symbol()+" : '"+m_trade.ResultComment()+"'";
               Notifications(text);
               printf("Error closing position by %s : '%s'",Symbol(),m_trade.ResultComment());
              }
            //--- processed and cannot be modified
            res=true;
           }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for long position modifying                                |
//+------------------------------------------------------------------+
bool CSampleExpert::LongModified(void)
  {
   bool res=false;
//--- check for trailing stop
   if(InpTrailingStop>0)
     {
      if(m_symbol.Bid()-m_position.PriceOpen()>m_adjusted_point*InpTrailingStop)
        {
         double sl=NormalizeDouble(m_symbol.Bid()-m_traling_stop,m_symbol.Digits());
         double tp=m_position.TakeProfit();
         if(m_position.StopLoss()<sl || m_position.StopLoss()==0.0)
           {
            //--- modify position
            string text="";
            if(m_trade.PositionModify(Symbol(),sl,tp))
              {
               text="Long position by "+Symbol()+" to be modified";
               Notifications(text);
               printf("Long position by %s to be modified",Symbol());
              }
            else
              {
               text="Error modifying position by "+Symbol()+" : '"+m_trade.ResultComment()+"'";
               Notifications(text);
               printf("Error modifying position by %s : '%s'",Symbol(),m_trade.ResultComment());

               text="Modify parameters : SL="+DoubleToString(sl,Digits())+",TP="+DoubleToString(tp,Digits());
               Notifications(text);
               printf("Modify parameters : SL=%f,TP=%f",sl,tp);
              }
            //--- modified and must exit from expert
            res=true;
           }
        }
     }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for short position modifying                               |
//+------------------------------------------------------------------+
bool CSampleExpert::ShortModified(void)
  {
   bool   res=false;
//--- check for trailing stop
   if(InpTrailingStop>0)
     {
      if((m_position.PriceOpen()-m_symbol.Ask())>(m_adjusted_point*InpTrailingStop))
        {
         double sl=NormalizeDouble(m_symbol.Ask()+m_traling_stop,m_symbol.Digits());
         double tp=m_position.TakeProfit();
         if(m_position.StopLoss()>sl || m_position.StopLoss()==0.0)
           {
            //--- modify position
            string text="";
            if(m_trade.PositionModify(Symbol(),sl,tp))
              {
               text="Short position by "+Symbol()+" to be modified";
               Notifications(text);
               printf("Short position by %s to be modified",Symbol());
              }
            else
              {
               text="Error modifying position by "+Symbol()+" : '"+m_trade.ResultComment()+"'";
               Notifications(text);
               printf("Error modifying position by %s : '%s'",Symbol(),m_trade.ResultComment());

               text="Modify parameters : SL="+DoubleToString(sl,Digits())+",TP="+DoubleToString(tp,Digits());
               Notifications(text);
               printf("Modify parameters : SL=%f,TP=%f",sl,tp);
              }
            //--- modified and must exit from expert
            res=true;
           }
        }
     }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for long position opening                                  |
//+------------------------------------------------------------------+
bool CSampleExpert::LongOpened(void)
  {
   bool res=false;
//--- check for long position (BUY) possibility
   if(m_macd_current<0)
      if(m_macd_current>m_signal_current && m_macd_previous<m_signal_previous)
         if(MathAbs(m_macd_current)>(m_macd_open_level) && m_ema_current>m_ema_previous)
           {
            double price=m_symbol.Ask();
            double tp   =m_symbol.Bid()+m_take_profit;
            //--- check for free money
            if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_BUY,InpLots,price)<0.0)
               printf("We have no money. Free Margin = %f",m_account.FreeMargin());
            else
              {
               //--- open position
               string text="";
               if(m_trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,InpLots,price,0.0,tp))
                 {
                  text="Position by "+Symbol()+" to be opened";
                  Notifications(text);
                  printf("Position by %s to be opened",Symbol());
                 }
               else
                 {
                  text="Error opening BUY position by "+Symbol()+" : '"+m_trade.ResultComment()+"'";
                  Notifications(text);
                  printf("Error opening BUY position by %s : '%s'",Symbol(),m_trade.ResultComment());

                  text="Open parameters : price="+DoubleToString(price,Digits())+",TP="+DoubleToString(tp,Digits());
                  Notifications(text);
                  printf("Open parameters : price=%f,TP=%f",price,tp);
                 }
              }
            //--- in any case we must exit from expert
            res=true;
           }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Check for short position opening                                 |
//+------------------------------------------------------------------+
bool CSampleExpert::ShortOpened(void)
  {
   bool res=false;
//--- check for short position (SELL) possibility
   if(m_macd_current>0)
      if(m_macd_current<m_signal_current && m_macd_previous>m_signal_previous)
         if(m_macd_current>(m_macd_open_level) && m_ema_current<m_ema_previous)
           {
            double price=m_symbol.Bid();
            double tp   =m_symbol.Ask()-m_take_profit;
            //--- check for free money
            if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_SELL,InpLots,price)<0.0)
               printf("We have no money. Free Margin = %f",m_account.FreeMargin());
            else
              {
               //--- open position
               string text="";
               if(m_trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,InpLots,price,0.0,tp))
                 {
                  text="Position by "+Symbol()+" to be opened";
                  Notifications(text);
                  printf("Position by %s to be opened",Symbol());
                 }
               else
                 {
                  text="Error opening SELL position by "+Symbol()+" : '"+m_trade.ResultComment()+"'";
                  Notifications(text);
                  printf("Error opening SELL position by %s : '%s'",Symbol(),m_trade.ResultComment());

                  text="Open parameters : price="+DoubleToString(price,Digits())+",TP="+DoubleToString(tp,Digits());
                  Notifications(text);
                  printf("Open parameters : price=%f,TP=%f",price,tp);
                 }
              }
            //--- in any case we must exit from expert
            res=true;
           }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| main function returns true if any position processed             |
//+------------------------------------------------------------------+
bool CSampleExpert::Processing(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- refresh indicators
   if(BarsCalculated(m_handle_macd)<2 || BarsCalculated(m_handle_ema)<2)
      return(false);
   if(CopyBuffer(m_handle_macd,0,0,2,m_buff_MACD_main)  !=2 ||
      CopyBuffer(m_handle_macd,1,0,2,m_buff_MACD_signal)!=2 ||
      CopyBuffer(m_handle_ema,0,0,2,m_buff_EMA)         !=2)
      return(false);
//   m_indicators.Refresh();
//--- to simplify the coding and speed up access
//--- data are put into internal variables
   m_macd_current   =m_buff_MACD_main[0];
   m_macd_previous  =m_buff_MACD_main[1];
   m_signal_current =m_buff_MACD_signal[0];
   m_signal_previous=m_buff_MACD_signal[1];
   m_ema_current    =m_buff_EMA[0];
   m_ema_previous   =m_buff_EMA[1];
//--- it is important to enter the market correctly, 
//--- but it is more important to exit it correctly...   
//--- first check if position exists - try to select it
   if(m_position.Select(Symbol()))
     {
      if(m_position.PositionType()==POSITION_TYPE_BUY)
        {
         //--- try to close or modify long position
         if(LongClosed())
            return(true);
         if(LongModified())
            return(true);
        }
      else
        {
         //--- try to close or modify short position
         if(ShortClosed())
            return(true);
         if(ShortModified())
            return(true);
        }
     }
//--- no opened position identified
   else
     {
      //--- check for long position (BUY) possibility
      if(LongOpened())
         return(true);
      //--- check for short position (SELL) possibility
      if(ShortOpened())
         return(true);
     }
//--- exit without position processing
   return(false);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   ExtMail=InpMail;
   ExtPush=InpPush;
   ExtAlert=InpAlert;

   ExtLots=InpLots;
   ExtTakeProfit=InpTakeProfit;
   ExtTrailingStop=InpTrailingStop;
   ExtMACDOpenLevel=InpMACDOpenLevel;
   ExtMACDCloseLevel=InpMACDCloseLevel;
   ExtMATrendPeriod=InpMATrendPeriod;
//--- create all necessary objects
   if(!ExtExpert.Init())
      return(INIT_FAILED);
//--- 
   if(!MQLInfoInteger(MQL_TESTER))
     {
      bool_tester=false;
      //---
      ExtDialog.Initialization(ExtMail,ExtPush,ExtAlert,
                               ExtLots,ExtTakeProfit,ExtTrailingStop,
                               ExtMACDOpenLevel,ExtMACDCloseLevel,ExtMATrendPeriod);
      //--- create application dialog
      if(!ExtDialog.Create(0,"Notification",0,100,100,360,380))
         return(INIT_FAILED);
      //--- run application
      if(!ExtDialog.Run())
         return(INIT_FAILED);
     }
   else
      bool_tester=true;
//--- secceed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
   Comment("");
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert new tick handling function                                |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   static datetime limit_time=0; // last trade processing time + timeout
//--- don't process if timeout
   if(TimeCurrent()>=limit_time)
     {
      //--- check for data
      if(Bars(Symbol(),Period())>2*InpMATrendPeriod)
        {
         //--- change limit time by timeout in seconds if processed
         if(ExtExpert.Processing())
            limit_time=TimeCurrent()+ExtTimeOut;
        }
     }
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
// Ask the bool variable in the panel if the parameters were changed
// If yes, ask the panel parameters and call
// CSampleExpert::Init(void)
   if(ExtDialog.Modification())
     {
      ExtDialog.GetValues(ExtMail,ExtPush,ExtAlert,
                          ExtLots,ExtTakeProfit,ExtTrailingStop,
                          ExtMACDOpenLevel,ExtMACDCloseLevel,ExtMATrendPeriod);
      if(ExtExpert.Init())
        {
         ExtDialog.Modification(false);
         Print("Parameters changed, ",ExtLots,", ",ExtTakeProfit,", ",ExtTrailingStop,", ",
               ExtMACDOpenLevel,", ",ExtMACDCloseLevel,", ",ExtMATrendPeriod);
        }
      else
        {
         ExtDialog.Modification(false);
         Print("Parameter change error");
        }
     }
  }
//+------------------------------------------------------------------+
//|  Send notifications                                              |
//+------------------------------------------------------------------+
void Notifications(const string text)
  {
   if(bool_tester)
     {
      if(InpMail)
         SendMail(" ",text);
      if(InpPush)
         SendNotification(text);
      if(InpAlert)
         Alert(text);
     }
   else
     {
      ExtDialog.Notifications(text);
     }
  }
//+------------------------------------------------------------------+
