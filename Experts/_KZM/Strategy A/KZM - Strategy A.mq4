//+------------------------------------------------------------------+
//|            
//|  CAccountInfo
//|            Class for working with trade account properties
//|  CSymbolInfo
//|            Class for working with trade instrument properties
//|  COrderInfo
//|            Class for working with pending order properties
//|  CHistoryOrderInfo
//|            Class for working with history order properties
//|  CPositionInfo
//|            Class for working with open position properties
//|  CDealInfo
//|            Class for working with history deal properties
//|  CTrade
//|            Class for trade operations execution
//|  CTerminalInfo
//|            Class for getting the properties of the terminal environment
//|            
//+------------------------------------------------------------------+
#property copyright   "Copyright 2018"
#property link        "https://fb:RoadtoTrader"
#property description "email: trisith.k@gmail.com"
#property version     "1.0"

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>

//--- Include a class of the Standard Library
#include <Trade/Trade.mqh>
#include <Trade/AccountInfo.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh>

#include <Custom/VaribleDefine.mqh>
#include <Custom/Events.mqh>
#include <Custom/User_Define_ENUM.mqh>
//--- Loading class

//--- object for performing trade operations
//COrderInfo order; // Pending Order
CTrade  trade; // Match Order
               // Pending Order 
COrderInfo order; // select by Symbol, Index
CPositionInfo position; // select by Symbol, Index, Magic, Ticket

                        //position.Profit;
//deal.Profit;

#define EXPERT_MAGIC 123456   // MagicNumber of the expert

input double GridSize =1000; // Grid Size
input double LotSize  =0.01; // Lots size
input int    MaxOrders=30;   // Max Order (Both Limit, Stop orders)
int accMaxOrders=200;

// Define Simple Trend from Moving
input bool  UseTrendFilter=false;
int   MovingPeriod=20;

bool   ShowHistoryLabel=false;
ENUM_SIDE   Side_HistoryText=Long;

bool __Print=false;
int RoundDigit=0;
int deviation=100;

bool TradeAllow=false;
bool PendingGrid=false;
int    digits; // number of decimal places
double point; // point
int MagicNumber;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _MaxOrders()
  {
   if(MaxOrders==0 || MaxOrders>=accMaxOrders)
      return accMaxOrders;
   return MaxOrders;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   CheckTradeAllow();

   CheckEvents(EXPERT_MAGIC);

   if(eventBuyClosed_SL>0)
      Print(Symbol(),": Buy position was closed by StopLoss!");
//Alert( Symbol(), ": Buy position was closed by StopLoss!" );

   if(eventBuyClosed_TP>0)
     {
      Print(Symbol(),": Buy position was closed by TakeProfit!");
      if(ShowHistoryLabel==true)
         ShowHistory();
      ReOrder();
     }

   if(eventSellClosed_TP>0)
     {
      Print(Symbol(),": Sell position was closed by TakeProfit!");
      if(ShowHistoryLabel==true)
        {
         if(Side_HistoryText==Short || Side_HistoryText==Both)
           {
            ShowHistory();
           }
        }
     }

   if(eventBuyLimitOpened>0 || eventBuyStopOpened>0 || 
      eventSellLimitOpened>0 || eventSellStopOpened>0)
      Print(Symbol()," pending order triggered!");

   if(UseTrendFilter==true)
     {
      if(TradeAllow==false)
        {
         Print("Delete Pending Order");
         DeletePendingOrders();
         PendingGrid=false;
           }else{
         if(PendingGrid==false)
           {
            Print("Perform Pending Order");
            PendingLimitOrders();
            PendingStopOrders();
            PendingGrid=true;
           }
        }
     }

   DisplayInfo();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayInfo()
  {
   string strTradeAllow;
   strTradeAllow=TradeAllow==true?"Yes":"No";
   Comment("Trade Allow=",strTradeAllow);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _Print(string v)
  {
   if(__Print)
      Print(string(v));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   setTemplate();

   RoundDigit=StringLen(string(GridSize))-1;
   _Print("Round Digit:"+IntegerToString(RoundDigit));

   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS); // number of decimal places
   point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);         // point

//--- set MagicNumber for your orders identification
   trade.SetExpertMagicNumber(EXPERT_MAGIC);
//--- set available slippage in points when buying/selling
   trade.SetDeviationInPoints(deviation);
//--- order filling mode, the mode allowed by the server should be used
   trade.SetTypeFilling(GetFilling(Symbol())); //ORDER_FILLING_RETURN
//--- logging mode: it would be better not to declare this method at all, the class will set the best mode on its own
   trade.LogLevel(1);
//--- what function is to be used for trading: true - OrderSendAsync(), false - OrderSend()
   trade.SetAsyncMode(true);
//---

   _Print(" ");
   _Print("====================  Check Order mode =======================================");
   Check_SYMBOL_ORDER_MODE(_Symbol);

   _Print(" ");
   _Print("======================= Account Info ====================================");
   AccInfo();

   if(UseTrendFilter==false)
     {
      PendingLimitOrders();
      PendingStopOrders();
     }

  }
//+------------------------------------------------------------------+
//| Account Info                                            |
//+------------------------------------------------------------------+
int AccInfo()
  {

//--- object for working with the account
   CAccountInfo account;
//--- receiving the account number, the Expert Advisor is launched at
   long login=account.Login();
   _Print("Login="+string(login));
//--- clarifying account type
   ENUM_ACCOUNT_TRADE_MODE account_type=account.TradeMode();
//--- if the account is real, the Expert Advisor is stopped immediately!
   if(account_type==ACCOUNT_TRADE_MODE_REAL)
     {
      MessageBox("Trading on a real account is forbidden, disabling","The Expert Advisor has been launched on a real account!");
      return(-1);
     }
//--- displaying the account type    
   Print("Account type: ",EnumToString(account_type));
//--- clarifying if we can trade on this account
   if(account.TradeAllowed())
      _Print("Trading on this account is allowed");
   else
      _Print("Trading on this account is forbidden: you may have entered using the Investor password");
//--- clarifying if we can use an Expert Advisor on this account
   if(account.TradeExpert())
      _Print("Automated trading on this account is allowed");
   else
      _Print("Automated trading using Expert Advisors and scripts on this account is forbidden");
//--- clarifying if the permissible number of orders has been set
   int orders_limit=account.LimitOrders();
   if(orders_limit!=0)Print("Maximum permissible amount of active pending orders: ",orders_limit);
//--- displaying company and server names
   _Print(account.Company()+": server "+account.Server());
//--- displaying balance and current profit on the account in the end
   _Print("Balance="+string(account.Balance())+"  Profit="+string(account.Profit())+"   Equity="+string(account.Equity()));
   _Print(__FUNCTION__+"  completed"); //---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetFilling(const string Symb,const uint Type=ORDER_FILLING_FOK)
  {
   const ENUM_SYMBOL_TRADE_EXECUTION ExeMode=(ENUM_SYMBOL_TRADE_EXECUTION)::SymbolInfoInteger(Symb,SYMBOL_TRADE_EXEMODE);
   const int FillingMode=(int)::SymbolInfoInteger(Symb,SYMBOL_FILLING_MODE);

   return((FillingMode == 0 || (Type >= ORDER_FILLING_RETURN) || ((FillingMode & (Type + 1)) != Type + 1)) ?
          (((ExeMode==SYMBOL_TRADE_EXECUTION_EXCHANGE) || (ExeMode==SYMBOL_TRADE_EXECUTION_INSTANT)) ?
          ORDER_FILLING_RETURN :((FillingMode==SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) :
          (ENUM_ORDER_TYPE_FILLING)Type);
  }
//+------------------------------------------------------------------+
//| Modification of pending orders                                   |
//+------------------------------------------------------------------+
void ModifySLTP()
  {
//--- this is a sample order ticket, it should be received
   ulong ticket=2; // 123456
//--- this is a sample symbol, it should be received
   string symbol="EURUSD";
//--- receiving a buy price
   double price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
//--- calculate and normalize SL and TP levels
//--- they should be calculated based on the order type
   double SL=NormalizeDouble(price-1000*point,digits);
   double TP=NormalizeDouble(price+1000*point,digits);
//--- setting one day as a lifetime
   datetime expiration=TimeCurrent()+PeriodSeconds(PERIOD_D1);
//--- everything is ready, trying to modify the order 
   if(!trade.OrderModify(ticket,price,SL,TP,ORDER_TIME_GTC,expiration))
     {
      //--- failure message
      _Print("OrderModify() method failed. Return code="+string(trade.ResultRetcode())+
             ". Code description: "+string(trade.ResultRetcodeDescription()));
     }
   else
     {
      _Print("OrderModify() method executed successfully. Return code="+string(trade.ResultRetcode())+
             " ("+string(trade.ResultRetcodeDescription())+")");
     }
  }
//+------------------------------------------------------------------+
//| Opens a position with specified parameters            |
//+------------------------------------------------------------------+
void OpenPosition()
  {
//--- number of decimal places
   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
//--- point value
   point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
//--- receiving a buy price
   double price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
//--- calculate and normalize SL and TP levels
   double SL=NormalizeDouble(price-1000*point,digits);
   double TP=NormalizeDouble(price+1000*point,digits);
//--- filling comments
   string comment="Buy "+Symbol()+" 0.1 at "+DoubleToString(price,digits);
//--- everything is ready, trying to open a buy position
   if(!trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,0.1,price,0,0,comment))
     {
      //--- failure message
      _Print("PositionOpen() method failed. Return code="+string(trade.ResultRetcode())+
             ". Code description: "+string(trade.ResultRetcodeDescription()));
     }
   else
     {
      _Print("PositionOpen() method executed successfully. Return code="+string(trade.ResultRetcode())+
             " ("+string(trade.ResultRetcodeDescription())+")");
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Modifies position parameters by the specified symbol or position ticket |
//+------------------------------------------------------------------+
void ModifyPosition()
  {
//--- number of decimal places
   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
//--- point value
   point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
//--- receiving the current Bid price
   double price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- calculate and normalize SL and TP levels
   double SL=NormalizeDouble(price-1000*point,digits);
   double TP=NormalizeDouble(price+1000*point,digits);
//--- everything is ready, trying to modify the buy position
   if(!trade.PositionModify(Symbol(),SL,TP))
     {
      //--- failure message
      Print("failure PositionModify() method failed. Return code="+string(trade.ResultRetcode())+
            ". Code description: "+string(trade.ResultRetcodeDescription()));
     }
   else
     {
      Print("PositionModify() method executed successfully. Return code="+string(trade.ResultRetcode())+
            " ("+string(trade.ResultRetcodeDescription())+")");
     }

  }
//+------------------------------------------------------------------+
//| Modification of pending order                                    |
//+------------------------------------------------------------------+
void ModifyPendingOrder()
  {
//--- this is a sample order ticket, it should be received
   ulong ticket=3;
//--- this is a sample symbol, it should be received
   string symbol=Symbol();
//--- number of decimal places
   digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
//--- point value
   point=SymbolInfoDouble(symbol,SYMBOL_POINT);
//--- receiving a buy price
   double price=SymbolInfoDouble(symbol,SYMBOL_ASK);
//--- calculate and normalize SL and TP levels
//--- they should be calculated based on the order type
   double SL=NormalizeDouble(price-1000*point,digits);
   double TP=NormalizeDouble(price+1000*point,digits);
//--- setting one day as a lifetime
   datetime expiration=TimeCurrent()+PeriodSeconds(PERIOD_D1);
//--- everything is ready, trying to modify the order 
   if(!trade.OrderModify(ticket,price,SL,TP,ORDER_TIME_GTC,expiration))
     {
      //--- failure message
      _Print("OrderModify() method failed. Return code="+string(trade.ResultRetcode())+
             ". Code description: "+string(trade.ResultRetcodeDescription()));
     }
   else
     {
      _Print("OrderModify() method executed successfully. Return code="+string(trade.ResultRetcode())+
             " ("+string(trade.ResultRetcodeDescription())+")");
     }
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+ 
//| The function prints out order types allowed for a symbol         | 
//+------------------------------------------------------------------+ 
void Check_SYMBOL_ORDER_MODE(string symbol)
  {
//--- receive the value of the property describing allowed order types 
   int symbol_order_mode=(int)SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE);
//--- check for market orders (Market Execution) 
   if((SYMBOL_ORDER_MARKET&symbol_order_mode)==SYMBOL_ORDER_MARKET)
      _Print(symbol+": Market orders are allowed (Buy and Sell)");
//--- check for Limit orders 
   if((SYMBOL_ORDER_LIMIT&symbol_order_mode)==SYMBOL_ORDER_LIMIT)
      _Print(symbol+": Buy Limit and Sell Limit orders are allowed");
//--- check for Stop orders 
   if((SYMBOL_ORDER_STOP&symbol_order_mode)==SYMBOL_ORDER_STOP)
      _Print(symbol+": Buy Stop and Sell Stop orders are allowed");
//--- check for Stop Limit orders 
   if((SYMBOL_ORDER_STOP_LIMIT&symbol_order_mode)==SYMBOL_ORDER_STOP_LIMIT)
      _Print(symbol+": Buy Stop Limit and Sell Stop Limit orders are allowed");
//--- check if placing a Stop Loss orders is allowed 
   if((SYMBOL_ORDER_SL&symbol_order_mode)==SYMBOL_ORDER_SL)
      _Print(symbol+": Stop Loss orders are allowed");
//--- check if placing a Take Profit orders is allowed 
   if((SYMBOL_ORDER_TP&symbol_order_mode)==SYMBOL_ORDER_TP)
      _Print(symbol+": Take Profit orders are allowed");
//--- 
  }
//+------------------------------------------------------------------+
//| Placing pending Limit orders                                           |
//+------------------------------------------------------------------+
void PendingLimitOrders()
  {

//--- 2. example of placing a Buy Limit pending order with all parameters
   string symbol=Symbol();    // specify the symbol, at which the order is placed
   digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);             // current buy price
   ask=NormalizeDouble(ask,Digits()-RoundDigit);

//   datetime expiration=TimeCurrent()+PeriodSeconds(PERIOD_D1);
   datetime expiration=0;

   double price,SL,TP;
   double SL_pips,TP_pips;

   SL_pips=300;                                         // Stop Loss in points
   TP_pips=GridSize;                                         // Take Profit in points

   int count=_MaxOrders()/2;
   for(int i=0; i<count; i++)
     {
      price=ask-i*GridSize*point;                                 // unnormalized open price
      price=NormalizeDouble(price,digits);                      // normalizing open price

      SL=price-SL_pips*point;                           // unnormalized SL value
      SL=NormalizeDouble(SL,digits);                            // normalizing Stop Loss
      TP=price+TP_pips*point;                           // unnormalized TP value
      TP=NormalizeDouble(TP,digits);                            // normalizing Take Profit
      SL=0;
      //TP=0;

      string comment=StringFormat("Buy Limit %s %G lots at %s, SL=%s TP=%s",
                                  symbol,LotSize,
                                  DoubleToString(price,digits),
                                  DoubleToString(SL,digits),
                                  DoubleToString(TP,digits));
      //--- everything is ready, sending a Buy Limit pending order to the server
      if(!trade.BuyLimit(LotSize,price,symbol,SL,TP,ORDER_TIME_GTC,expiration,comment))
        {
         //--- failure message
         _Print("BuyLimit() method failed. Return code="+string(trade.ResultRetcode())+
                ". Code description: "+string(trade.ResultRetcodeDescription()));
        }
      else
        {
         _Print("BuyLimit() method executed successfully. Return code="+string(trade.ResultRetcode())+
                " ("+string(trade.ResultRetcodeDescription())+")");
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Placing pending Stop orders                                           |
//+------------------------------------------------------------------+
void PendingStopOrders()
  {

//--- 2. example of placing a Buy Limit pending order with all parameters
   string symbol=Symbol();    // specify the symbol, at which the order is placed
   digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);             // current buy price
   bid=NormalizeDouble(bid,Digits()-RoundDigit);

//   datetime expiration=TimeCurrent()+PeriodSeconds(PERIOD_D1);
   datetime expiration=0;

   double price,SL,TP;
   double SL_pips,TP_pips;

   SL_pips=300;                                         // Stop Loss in points
   TP_pips=GridSize;                                         // Take Profit in points

   int count=_MaxOrders()/2;
   for(int i=0; i<count; i++)
     {
      price=bid+i*GridSize*point;                                 // unnormalized open price
      price=NormalizeDouble(price,digits);                      // normalizing open price

      SL=price-SL_pips*point;                           // unnormalized SL value
      SL=NormalizeDouble(SL,digits);                            // normalizing Stop Loss
      TP=price+TP_pips*point;                           // unnormalized TP value
      TP=NormalizeDouble(TP,digits);                            // normalizing Take Profit
      SL=0;
      //TP=0;

      string comment=StringFormat("Buy Stop %s %G lots at %s, SL=%s TP=%s",
                                  symbol,LotSize,
                                  DoubleToString(price,digits),
                                  DoubleToString(SL,digits),
                                  DoubleToString(TP,digits));
      //--- everything is ready, sending a Buy Limit pending order to the server
      if(!trade.BuyStop(LotSize,price,symbol,SL,TP,ORDER_TIME_GTC,expiration,comment))
        {
         //--- failure message
         _Print("BuyLimit() method failed. Return code="+string(trade.ResultRetcode())+
                ". Code description: "+string(trade.ResultRetcodeDescription()));
        }
      else
        {
         _Print("BuyLimit() method executed successfully. Return code="+string(trade.ResultRetcode())+
                " ("+string(trade.ResultRetcodeDescription())+")");
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Deleting pending orders                                          |
//+------------------------------------------------------------------+
void DeletePendingOrders()
  {
//--- this is a sample order ticket, it should be received
//--- obtain the total number of orders
   int orders=OrdersTotal();
   bool ret=false;
//--- scan the list of orders
   for(int i=orders;i>0;i--)
     {
      ResetLastError();
      //--- copy into the cache, the order by its number in the list
      //ulong ticket=OrderGetTicket(i);
      ret=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(ret!=false)// if the order was successfully copied into the cache, work with it
        {
         int ticket=OrderTicket();
         double price_open  =OrderOpenPrice();
         datetime time_setup=OrderOpenTime();
         string symbol      =OrderSymbol();
         long magic_number  =OrderMagicNumber();

         if(magic_number==EXPERT_MAGIC)

           {
            //  process the order with the specified ORDER_MAGIC
            //--- everyrging is ready, trying to modify a buy position
            if(OrderDelete(ticket,clrLightGray))//!trade.OrderDelete(ticket))
              {
               //--- failure message
               //Print("OrderDelete() method failed. Return code=",trade.ResultRetcode(),
               //      ". Code description: ",trade.ResultRetcodeDescription());
              }
            else
              {
               //Print("OrderDelete() method executed successfully. Return code=",trade.ResultRetcode(),
               //      " (",trade.ResultRetcodeDescription(),")");
              }

           }
         PrintFormat("Order #%d for %s was set out %s, ORDER_MAGIC=%d",ticket,symbol,TimeToString(time_setup),magic_number);
        }
      else         // call OrderGetTicket() was completed unsuccessfully
        {
         PrintFormat("Error when obtaining an order from the list to the cache. Error code: %d",GetLastError());
        }
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Closing all positions                                            |
//+------------------------------------------------------------------+
void ClosePosition()
  {
//--- closing a position at the current symbol
   if(!trade.PositionClose(Symbol()))
     {
      //--- failure message
      _Print("PositionClose() method failed. Return code="+string(trade.ResultRetcode())+
             ". Code description: "+string(trade.ResultRetcodeDescription()));
     }
   else
     {
      _Print("PositionClose() method executed successfully. Return code="+string(trade.ResultRetcode())+
             " ("+string(trade.ResultRetcodeDescription())+")");
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Placing pending Limit orders                                           |
//+------------------------------------------------------------------+
void PendingBuyLimitOrdersAtPrice(string symbol,double price)
  {

//--- 2. example of placing a Buy Limit pending order with all parameters
//string symbol= Symbol();    // specify the symbol, at which the order is placed
   digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   double _point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);             // current buy price
   ask=NormalizeDouble(ask,2);

//datetime expiration=TimeCurrent()+PeriodSeconds(PERIOD_D1);
   datetime expiration=0;

   double  SL,TP;
   int SL_pips;//TP_pips;

   SL_pips=300;                                         // Stop Loss in points

                                                        //price=ask - i*GridSize*point;                                 // unnormalized open price
//price=NormalizeDouble(price,digits);                      // normalizing open price

   SL=price-SL_pips*_point;                           // unnormalized SL value
   SL=NormalizeDouble(SL,digits);                            // normalizing Stop Loss
   TP=price+GridSize*_point;                           // unnormalized TP value
   TP=NormalizeDouble(TP,digits);                            // normalizing Take Profit
   SL=0;

   string comment=StringFormat("Buy Limit %s %G lots at %s, SL=%s TP=%s",
                               symbol,LotSize,
                               DoubleToString(price,digits),
                               DoubleToString(SL,digits),
                               DoubleToString(TP,digits));
//--- everything is ready, sending a Buy Limit pending order to the server
   if(!trade.BuyLimit(LotSize,price,symbol,SL,TP,ORDER_TIME_GTC,expiration,comment))
     {
      //--- failure message
      _Print("BuyLimit() method failed. Return code="+string(trade.ResultRetcode())+
             ". Code description: "+string(trade.ResultRetcodeDescription()));
     }
   else
     {
      _Print("BuyLimit() method executed successfully. Return code="+string(trade.ResultRetcode())+
             " ("+string(trade.ResultRetcodeDescription())+")");
     }
  }
//+------------------------------------------------------------------+

void ShowHistory()
  {
   color BuyColor =clrYellow;
   color SellColor=clrOrange;
//--- request trade history 
//HistorySelect(0,TimeCurrent()); 
//--- create objects 
   long magic_number;
   string   name;
   uint     total=OrdersHistoryTotal();
   ulong    ticket=0;
   double   price;
   double NetProfit;
   double   profit;
   double   swap;
   double   commission;
   datetime time;
   string   symbol;
   long     type;
//long     entry;
   long state=0;              // Order state   
   int _GetLastError=0;       // Error code   
   bool ret=false;
//--- for all deals 
//state = HistoryOrderGetInteger(ticket, ORDER_STATE);

   for(uint i=total-1;i<total;i++)
     {
      //--- try to get deals ticket 
      ret=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(ret!=false)// if the order was successfully copied into the cache, work with it
        {
         ticket= OrderTicket();
         price =OrderClosePrice();
         time=OrderCloseTime();
         symbol=OrderSymbol();
         magic_number=OrderMagicNumber();
         profit=OrderProfit();
         swap=OrderSwap();
         commission=OrderCommission();
         NetProfit=profit+swap+commission;
         type=OrderType();

         //--- only for current symbol 
         //--- create price object 
         name="TradeHistory_Deal_"+string(ticket);
         //if(entry) ObjectCreate(0,name,OBJ_ARROW_RIGHT_PRICE,0,time,price,0,0); 
         //else
         //ObjectCreate(0,name,OBJ_ARROW_LEFT_PRICE,0,time,price,0,0); 
         ObjectCreate(0,name,OBJ_TEXT,0,time,price,0,0);
         //--- set object properties 
         ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
         ObjectSetInteger(0,name,OBJPROP_BACK,0);
         ObjectSetInteger(0,name,OBJPROP_COLOR,type?BuyColor:SellColor);
         //if(profit!=0) 
         ObjectSetString(0,name,OBJPROP_TEXT,"#"+string(ticket)+":["+string(profit)+"]+ ("+string(swap)+")");

        }
     }
//--- apply on chart 
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ReOrder()
  {
   color BuyColor =clrYellow;
   color SellColor=clrOrange;
//--- request trade history 
//HistorySelect(0,TimeCurrent()); 
//--- create objects 
   long magic_number;
//string   name;
   uint     total=OrdersHistoryTotal();
   ulong    ticket=0;
   double   price;
   double   profit;
   datetime time;
   string   symbol;
   long     type;
//long     entry;
   long state=0;              // Order state   
   int _GetLastError=0;       // Error code   
   bool ret=false;
//--- for all deals 
//state = HistoryOrderGetInteger(ticket, ORDER_STATE);

//--- try to get deals ticket 
   ret=OrderSelect(total-1,SELECT_BY_POS,MODE_HISTORY);
   if(ret!=false)// if the order was successfully copied into the cache, work with it
     {
      ticket= OrderTicket();
      price =OrderOpenPrice();
      time=OrderOpenTime();
      symbol=OrderSymbol();
      magic_number=OrderMagicNumber();
      profit=OrderProfit();
      type=OrderType()==OP_BUY?1:0;

      PendingBuyLimitOrdersAtPrice(symbol,price);

     }
//--- apply on chart 
//   ChartRedraw(); 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTradeAllow()
  {
   double ma;
//int    res;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get Moving Average 
   ma=iMA(NULL,0,MovingPeriod,0,MODE_SMA,PRICE_CLOSE,0);
//--- sell conditions
   if(Close[1]<ma && Close[0]<ma)
     {
      TradeAllow=false;
      return;
     }
//--- buy conditions
   if(Close[1]>ma && Close[0]>ma)
     {
      TradeAllow=true;
      return;
     }
//---
  }
//+------------------------------------------------------------------+
