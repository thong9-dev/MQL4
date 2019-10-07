//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define NHM_GateName       "Gateway.php" 
#define NHM_SaverHost    "http://www.fxhanuman.com/web/eafx/"
//#define NHM_SaverHost      "http://127.0.0.1/HNM/"
#define NHM_Product        "EA0001"
#define NHM_Name        "MA-Martingal"
#define NHM_Encode         true
#property description NHM_Product
//---
#include <Hanuman_API.mqh>
CHanuman Hanuman;
//---
#property copyright "Copyright 05-2019, www.FxHanuman.com"
#property link      "https://www.fxhanuman.com"
#property version   "1.12"
#property strict


input string TradeSetting="----------------------------------------------------------------------";
input double Lots=0.01;
input double LotExpo=2;
input int TP=100;
input int PipStep=100;
input double TP_MartingelPercent_Order2=35; //TP Martingel% (Order2)
input double TP_MartingelPercent=30; //TP Martingel%
input int MaxOrders=2;
input bool Use_Cutloss=false;
input double Cutloss=-10; //Cutloss$
input bool Use_ReverseOrder=false;
input int ReverseOrder_AtOrder=3;
input string MA_Setting="----------------------------------------------------------------------";
input int MA_Period=21;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input int EnterPips=300;

int getlasterror;
datetime last_error_time;
string last_error_input;

int ticket_last_take_tp=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Hanuman._Init(NHM_SaverHost,NHM_GateName,NHM_Product,NHM_Name,NHM_Encode);

   ticket_last_take_tp=TicketLastTakeTP();
   OnTick();
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Hanuman._Deinit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsTesting() && !IsExpertEnabled())
     {
      Comment("Auto Trading is disble.");
      return;
     }
   if(!IsTesting() && !IsTradeAllowed())
     {
      Comment("Allow live trading is not check.");
      return;
     }
   if(!IsTesting() && !IsConnected())
     {
      Comment("MT4 is not connect.");
      return;
     }

   int stop_level=(int)MarketInfo(Symbol(),MODE_STOPLEVEL);
   int spread=(int)MarketInfo(Symbol(),MODE_SPREAD);

   if(TP<stop_level)
     {
      Comment("TP is too small. (min "+(string)stop_level+")");

      if(last_error_input!="TP" || TimeCurrent()-last_error_time>=5)
        {
         Alert(Symbol()+" - TP is too small. (min "+(string)stop_level+")");
         last_error_input="TP";
         last_error_time=TimeCurrent();
        }

      return;
     }

   last_error_input="";

   Comment("Opening profit: "+DoubleToStr(TotalOpeningProfit(),2)+" "+AccountCurrency());

   if(TicketLastTakeTP()!=ticket_last_take_tp)
     {
      CloseAll();
      ticket_last_take_tp=TicketLastTakeTP();
     }

   double ma=iMA(Symbol(),0,MA_Period,0,MA_Method,0,0);

   if(OrdersNormallTotal()==0)
     {
      if(ma-Close[0]>=EnterPips*Point)
        {
         if(Hanuman._Check())
            _OrderSend(Symbol(),OP_BUY,Lots,Ask,0,Ask+(TP*Point),"MA Martingel");
        }
      else if(Close[0]-ma>=EnterPips*Point)
        {
         if(Hanuman._Check())
            _OrderSend(Symbol(),OP_SELL,Lots,Bid,0,Bid-(TP*Point),"MA Martingel");
        }
     }

   int total_opening_orders=OrdersNormallTotal();
   double first_lots=FirstLotsNormallOpening();

   if(OrdersNormallTotal()<MaxOrders && TicketLastNormallOpening()!=-1)
     {
      if(OrderType()==OP_BUY && OrderOpenPrice()-Ask>=PipStep*Point)
        {
         _OrderSend(Symbol(),OP_BUY,NormalizeDouble(first_lots*MathPow(LotExpo,total_opening_orders),LotsDigits()),Ask,0,0,"MA Martingel");

         if(Use_ReverseOrder && total_opening_orders>=ReverseOrder_AtOrder)
           {
            _OrderSend(Symbol(),OP_SELL,first_lots,Bid,0,Bid-(TP*Point),"MA Martingel (Reverse)",9999);
           }
         Hanuman._Scout();
        }
      else if(OrderType()==OP_SELL && Bid-OrderOpenPrice()>=PipStep*Point)
        {
         _OrderSend(Symbol(),OP_SELL,NormalizeDouble(first_lots*MathPow(LotExpo,total_opening_orders),LotsDigits()),Bid,0,0,"MA Martingel");

         if(Use_ReverseOrder && total_opening_orders>=ReverseOrder_AtOrder)
           {
            _OrderSend(Symbol(),OP_BUY,first_lots,Ask,0,Ask+(TP*Point),"MA Martingel (Reverse)",9999);
           }
         Hanuman._Scout();
        }
     }

   total_opening_orders=OrdersNormallTotal();

   if(total_opening_orders>=2 && TicketLastNormallOpening()!=-1)
     {
      int order_type=OrderType();

      double highest_price=GetHighestOpenPriceOrderByType(order_type);
      double lowest_price=GetLowestOpenPriceOrderByType(order_type);
      double use_tp_martingel_percent=TP_MartingelPercent_Order2;

      if(total_opening_orders>=3)
         use_tp_martingel_percent=TP_MartingelPercent;

      double range_tp=(highest_price-lowest_price)*(use_tp_martingel_percent/100);

      if(TicketLastNormallOpening()!=-1)
        {
         if(OrderType()==OP_BUY)
           {
            ModifyAllTP(OrderOpenPrice()+range_tp);
           }
         else if(OrderType()==OP_SELL)
           {
            ModifyAllTP(OrderOpenPrice()-range_tp);
           }
        }
     }

   double opening_profit=TotalOpeningProfit();

   if(Use_Cutloss && opening_profit<0 && MathAbs(opening_profit)>=MathAbs(Cutloss))
     {
      CloseAll();
      Alert(Symbol()+" - Close all by Cutloss$");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   Hanuman._ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TicketLastTakeTP()
  {
   for(int func_i=OrdersHistoryTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol()==Symbol() && StringFind(OrderComment(),"[tp]")!=-1)
         return OrderTicket();
     }

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CloseAll()
  {
   double func_total_profit=0;

   while(OrdersNormallTotal_NoCheckMagic()>0)
     {
      for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
        {
         if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1)
           {
            _OrderClose(OrderTicket());

            if(OrderSelect(OrderTicket(),SELECT_BY_TICKET,MODE_HISTORY))
               func_total_profit+=OrderProfit()+OrderCommission()+OrderSwap();
           }
        }

      if(IsStopped())
         break;
     }

   return func_total_profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyAllTP(double input_tp)
  {
   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(input_tp,Digits)
         && OrderType()<=1 && OrderMagicNumber()==0)
         _OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),input_tp);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLowestOpenPriceOrderByType(int input_type)
  {
   double func_lowest_price=99999;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()==input_type && OrderOpenPrice()<func_lowest_price && OrderMagicNumber()==0)
         func_lowest_price=OrderOpenPrice();
     }

   return func_lowest_price;
  }
//----------------------------------------------------------------------------------------------------------------
double GetHighestOpenPriceOrderByType(int input_type)
  {
   double func_highest_price=-99999;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()==input_type && OrderOpenPrice()>func_highest_price && OrderMagicNumber()==0)
         func_highest_price=OrderOpenPrice();
     }

   return func_highest_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FirstLotsNormallOpening()
  {
   for(int func_i=0;func_i<OrdersTotal();func_i++)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1 && OrderMagicNumber()==0)
         return OrderLots();
     }

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HaveOrdersHistoryInShiftByType(int input_type,int input_shift)
  {
   for(int func_i=OrdersHistoryTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol()==Symbol() && OrderType()==input_type && OrderMagicNumber()==0)
        {
         if(iBarShift(Symbol(),0,OrderOpenTime(),false)<=input_shift)
            return true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LotsDigits()
  {
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)
      return 2;
   else if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1)
      return 1;
   else if(MarketInfo(Symbol(),MODE_LOTSTEP)>=1)
                                              return 0;

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalOpeningProfit()
  {
   double func_total_profit_opening=0;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1)
         func_total_profit_opening+=OrderProfit()+OrderCommission()+OrderSwap();
     }

   return func_total_profit_opening;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AllowDateTime(string input_start,string input_end)
  {
   datetime func_start_time=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+input_start);

   if(input_start=="24:00")
      func_start_time=StringToTime(TimeToString(TimeCurrent(),TIME_DATE))+(1440*60);
   else if(input_start=="")
      func_start_time=0;

   datetime func_end_time=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+input_end);

   if(input_end=="24:00")
      func_end_time=StringToTime(TimeToString(TimeCurrent(),TIME_DATE))+(1440*60);
   else if(input_end=="")
      func_end_time=0;

   if(func_start_time==0 && func_end_time==0)
      return false;

   if((func_start_time<func_end_time && TimeCurrent()>=func_start_time && TimeCurrent()<func_end_time)
      || (func_start_time>func_end_time && (TimeCurrent()>=func_start_time || TimeCurrent()<func_end_time)))
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TicketLastNormallOpening()
  {
   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1 && OrderMagicNumber()==0)
         return OrderTicket();
     }

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrdersNormallTotal_NoCheckMagic()
  {
   int func_total_orders=0;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1)
         func_total_orders++;
     }

   return func_total_orders;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrdersNormallTotal()
  {
   int func_total_orders=0;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1 && OrderMagicNumber()==0)
         func_total_orders++;
     }

   return func_total_orders;
  }
//----------------------------------------------------------------------------------------------------------------
double SetStoploss(int input_type,double input_price,int input_pips)
  {
   if(input_pips==0)
      return 0;
   else
     {
      if(input_type==OP_BUY)return input_price-(input_pips*Point);
      if(input_type==OP_SELL)return input_price+(input_pips*Point);
     }

   return -1;
  }
//----------------------------------------------------------------------------------------------------------------
double SetTakeprofit(int input_type,double input_price,int input_pips)
  {
   if(input_pips==0)
      return 0;
   else
     {
      if(input_type==OP_BUY)return input_price+(input_pips*Point);
      if(input_type==OP_SELL)return input_price-(input_pips*Point);
     }

   return -1;
  }
//----------------------------------------------------------------------------------------------------------------
bool _OrderModify(int input_ticket,double input_open_price,double input_sl,double input_tp,bool show_error=true)
  {
   bool func_success=false;
   color func_clr=clrNONE;
   int func_getlasterror;

   if(OrderSelect(input_ticket,SELECT_BY_TICKET,MODE_TRADES) && (NormalizeDouble(OrderStopLoss(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS))!=NormalizeDouble(input_sl,(int)MarketInfo(OrderSymbol(),MODE_DIGITS))
      || NormalizeDouble(OrderTakeProfit(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS))!=NormalizeDouble(input_tp,(int)MarketInfo(OrderSymbol(),MODE_DIGITS))
      ||  NormalizeDouble(OrderOpenPrice(),(int)MarketInfo(OrderSymbol(),MODE_DIGITS))!=NormalizeDouble(input_open_price,(int)MarketInfo(OrderSymbol(),MODE_DIGITS))))
     {
      int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);

      if(NormalizeDouble(OrderOpenPrice(),digits)!=NormalizeDouble(input_open_price,digits))
        {
         if(OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT)
            func_clr=clrBlue;
         else if(OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT)
            func_clr=clrRed;
        }

      if(!IsTesting())
         func_clr=clrNONE;

      func_success=OrderModify(OrderTicket(),input_open_price,input_sl,input_tp,0,func_clr);
      func_getlasterror=GetLastError();

      if(func_success)
         error_last_error_code=0;

      if(show_error && func_getlasterror!=129 && func_getlasterror!=138 && func_getlasterror!=136 && func_getlasterror!=146
         && func_getlasterror!=6 && func_getlasterror!=132 && func_getlasterror!=133 && func_getlasterror!=4000
         && IsTradeAllowed() && IsConnected() && !IsTradeContextBusy())
        {
         if(NormalizeDouble(OrderOpenPrice(),digits)==NormalizeDouble(input_open_price,digits)
            && NormalizeDouble(OrderStopLoss(),digits)==NormalizeDouble(input_sl,digits)
            && NormalizeDouble(OrderTakeProfit(),digits)!=NormalizeDouble(input_tp,digits))
            ShowError_ModifyTP_Only(func_getlasterror,OrderSymbol(),OrderTicket(),OrderType(),input_open_price,input_tp);
         else if(NormalizeDouble(OrderOpenPrice(),digits)==NormalizeDouble(input_open_price,digits)
            && NormalizeDouble(OrderStopLoss(),digits)!=NormalizeDouble(input_sl,digits)
                                                        && NormalizeDouble(OrderTakeProfit(),digits)==NormalizeDouble(input_tp,digits))
                                                        ShowError_ModifySL_Only(func_getlasterror,OrderSymbol(),OrderTicket(),OrderType(),input_open_price,input_sl);
         else
            ShowError_Modify(func_getlasterror,OrderSymbol(),OrderTicket(),OrderType(),input_open_price,input_sl,input_tp);
        }
     }

   return func_success;
  }
//----------------------------------------------------------------------------------------------------------------
bool _OrderClose(int input_ticket,bool show_error=true)
  {
   bool func_success=false;
   int func_getlasterror;
   color func_clr=clrBlack;

   if(IsTesting())
      func_clr=clrNONE;

   if(OrderSelect(input_ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      double func_close_price=0;
      RefreshRates();

      if(OrderType()<=1)
        {
         if(OrderType()==OP_BUY)
            func_close_price=MarketInfo(OrderSymbol(),MODE_BID);
         else if(OrderType()==OP_SELL)
            func_close_price=MarketInfo(OrderSymbol(),MODE_ASK);

         func_getlasterror=-1;
         func_success=false;
         while(!func_success && (func_getlasterror==-1 || (!IsTesting() && (func_getlasterror==129 || func_getlasterror==138 || func_getlasterror==136 || func_getlasterror==146))))
           {
            RefreshRates();
            func_success=OrderClose(OrderTicket(),OrderLots(),func_close_price,0,func_clr);
            func_getlasterror=GetLastError();

            if(func_success)
               error_last_error_code=0;

            if(show_error && func_getlasterror!=129 && func_getlasterror!=138 && func_getlasterror!=136 && func_getlasterror!=146
               && func_getlasterror!=6 && func_getlasterror!=132 && func_getlasterror!=133 && func_getlasterror!=4000
               && IsTradeAllowed() && IsConnected() && !IsTradeContextBusy())
               ShowError_Close(func_getlasterror,OrderSymbol(),OrderTicket(),OrderType(),OrderLots());
           }
        }
      else
        {
         func_success=OrderDelete(OrderTicket());
         func_getlasterror=GetLastError();

         if(show_error && func_getlasterror!=129 && func_getlasterror!=138 && func_getlasterror!=136 && func_getlasterror!=146
            && func_getlasterror!=6 && func_getlasterror!=132 && func_getlasterror!=133 && func_getlasterror!=4000
            && IsTradeAllowed() && IsConnected() && !IsTradeContextBusy())
            ShowError_Close(func_getlasterror,OrderSymbol(),OrderTicket(),OrderType(),OrderLots());
        }
     }

   return func_success;
  }
//----------------------------------------------------------------------------------------------------------------
int _OrderSend(string input_symbol,int input_cmd,double input_lots,double input_open_price,double input_sl=0,double input_tp=0
               ,string input_comment=NULL,int input_magic=0,bool show_error=true)
  {
   int func_ticket=-1,func_getlasterror=0;
   color func_clr=clrNONE;

   if(input_cmd==OP_BUY || input_cmd==OP_BUYSTOP || input_cmd==OP_BUYLIMIT)
      func_clr=clrBlue;
   else if(input_cmd==OP_SELL || input_cmd==OP_SELLSTOP || input_cmd==OP_SELLLIMIT)
      func_clr=clrRed;

   if(!IsTesting())
      func_clr=clrNONE;

   if(input_cmd<=1)
     {
      func_getlasterror=-1;
      func_ticket=-1;

      while(func_ticket==-1 && (func_getlasterror==-1 || (!IsTesting() && (func_getlasterror==129 || func_getlasterror==138 || func_getlasterror==136 || func_getlasterror==146))))
        {
         RefreshRates();
         func_ticket=OrderSend(input_symbol,input_cmd,input_lots,input_open_price,0,input_sl,input_tp,input_comment,input_magic);
         func_getlasterror=GetLastError();

         if(func_ticket!=-1)
            error_last_error_code=0;

         if(show_error && func_getlasterror!=129 && func_getlasterror!=138 && func_getlasterror!=136 && func_getlasterror!=146
            && func_getlasterror!=6 && func_getlasterror!=132 && func_getlasterror!=133 && func_getlasterror!=4000
            && IsTradeAllowed() && IsConnected() && !IsTradeContextBusy())
            ShowError_Open(func_getlasterror,input_symbol,input_cmd,input_lots,input_open_price,input_sl,input_tp);
        }
     }
   else
     {
      func_ticket=OrderSend(input_symbol,input_cmd,input_lots,input_open_price,0,input_sl,input_tp,input_comment,input_magic,0,func_clr);

      if(func_ticket!=-1)
         error_last_error_code=0;

      if(show_error && func_getlasterror!=129 && func_getlasterror!=138 && func_getlasterror!=136 && func_getlasterror!=146
         && func_getlasterror!=6 && func_getlasterror!=132 && func_getlasterror!=133 && func_getlasterror!=4000
         && IsTradeAllowed() && IsConnected() && !IsTradeContextBusy())
         ShowError_Open(GetLastError(),input_symbol,input_cmd,input_lots,input_open_price,input_sl,input_tp);
     }

   return func_ticket;
  }
//----------------------------------------------------------------------------------------------------------------
int error_last_error_code=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError_Open(int input_errorcode,string input_symbol
                    ,int input_type,double input_lots,double input_open_price,double input_sl,double input_tp)
  {
   if(input_errorcode==0 || input_errorcode==138)
      return;

   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   int func_digits=(int)MarketInfo(input_symbol,MODE_DIGITS);
   double func_stop_level=MarketInfo(input_symbol,MODE_STOPLEVEL);

   if(input_type==OP_BUY)
      op_string="Buy";
   else if(input_type==OP_SELL)
      op_string="Sell";
   else if(input_type==OP_BUYSTOP)
      op_string="BuyStop";
   else if(input_type==OP_BUYLIMIT)
      op_string="BuyLimit";
   else if(input_type==OP_SELLSTOP)
      op_string="SellStop";
   else if(input_type==OP_SELLLIMIT)
      op_string="SellLimit";

   string func_order_data=input_symbol+" "+op_string+" "+DoubleToStr(input_lots,2)+" at "
                          +DoubleToStr(input_open_price,func_digits)+" SL "+DoubleToStr(input_sl,func_digits)+" TP "+DoubleToStr(input_tp,func_digits);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && input_errorcode!=error_last_error_code)))
     {
      error_last_error_code=input_errorcode;

      if(input_errorcode==130)
        {
         double func_sl_point=0,func_tp_point=0;

         if(input_type==OP_BUY || input_type==OP_BUYSTOP || input_type==OP_BUYLIMIT)
           {
            func_sl_point=NormalizeDouble((input_open_price-input_sl)/func_point,0);
            func_tp_point=NormalizeDouble((input_tp-input_open_price)/func_point,0);
           }
         else if(input_type==OP_SELL || input_type==OP_SELLSTOP || input_type==OP_SELLLIMIT)
           {
            func_sl_point=NormalizeDouble((input_sl-input_open_price)/func_point,0);
            func_tp_point=NormalizeDouble((input_open_price-input_tp)/func_point,0);
           }

         if(input_sl!=0 && func_sl_point<func_stop_level)
           {
            func_error_message="SL is too small. (Your SL is "+(string)func_sl_point+" point)";
            Alert(input_symbol+" - SL minimum is "+(string)func_stop_level+" point");
           }
         else if(input_tp!=0 && func_tp_point<func_stop_level)
           {
            func_error_message="TP is too small. (Your TP is "+(string)func_tp_point+" point)";
            Alert(input_symbol+" - TP minimum is "+(string)func_stop_level+" point");
           }
         else if(input_type>=2)
           {
            if(input_type==OP_BUYSTOP && NormalizeDouble(input_open_price-MarketInfo(input_symbol,MODE_ASK),func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((input_open_price-MarketInfo(input_symbol,MODE_ASK))/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
            else if(input_type==OP_BUYLIMIT && NormalizeDouble(MarketInfo(input_symbol,MODE_ASK)-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((MarketInfo(input_symbol,MODE_ASK)-input_open_price)/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
            else if(input_type==OP_SELLSTOP && NormalizeDouble(MarketInfo(input_symbol,MODE_BID)-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((MarketInfo(input_symbol,MODE_BID)-input_open_price)/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
            else if(input_type==OP_SELLLIMIT && NormalizeDouble(input_open_price-MarketInfo(input_symbol,MODE_BID),func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((input_open_price-MarketInfo(input_symbol,MODE_BID))/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
           }
        }
      else if(input_errorcode==131)
        {
         func_order_data=input_symbol+" "+op_string+" "+DoubleToStr(input_lots,2);
         func_error_message=ErrorDescription(input_errorcode);
         Alert(input_symbol+" - Lots range is "+DoubleToStr(MarketInfo(input_symbol,MODE_MINLOT),2)+" to "
               +DoubleToStr(MarketInfo(input_symbol,MODE_MAXLOT),2)+"");
        }
      else if(input_errorcode==134)
        {
         func_order_data=input_symbol+" "+op_string+" "+DoubleToStr(input_lots,2);
         func_error_message=ErrorDescription(input_errorcode);
         Alert(input_symbol+" - Margin need "+DoubleToStr(input_lots*MarketInfo(Symbol(),MODE_MARGINREQUIRED),2)+" "+AccountCurrency()
               +" but you have margin "+DoubleToStr(AccountFreeMargin(),2)+" "+AccountCurrency());
        }
      else
         func_error_message=ErrorDescription(input_errorcode);

      Alert(input_symbol+" - Open "+func_order_data+" | Error > "+func_error_message);

      if(IsTesting())
        {
         ObjectCreate(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJ_ARROW,0,0,0);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_ARROWCODE,108);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TIME1,TimeCurrent());
         ObjectSetDouble(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_PRICE1,Close[0]);
         ObjectSetString(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TEXT,"Error > "+func_error_message);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError_Close(int input_errorcode,string input_symbol,int input_ticket,int input_type,double input_lots)
  {
   if(input_errorcode==0 || input_errorcode==138)
      return;

   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   double func_digits=MarketInfo(input_symbol,MODE_DIGITS);

   if(input_type==OP_BUY)
      op_string="Buy";
   else if(input_type==OP_SELL)
      op_string="Sell";
   else if(input_type==OP_BUYSTOP)
      op_string="BuyStop";
   else if(input_type==OP_BUYLIMIT)
      op_string="BuyLimit";
   else if(input_type==OP_SELLSTOP)
      op_string="SellStop";
   else if(input_type==OP_SELLLIMIT)
      op_string="SellLimit";

   int func_stop_level=(int)MarketInfo(input_symbol,MODE_STOPLEVEL);
   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" "+DoubleToStr(input_lots,2);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && input_errorcode!=error_last_error_code)))
     {
      error_last_error_code=input_errorcode;
      func_error_message=ErrorDescription(input_errorcode)+".";
      Alert(input_symbol+" - Close "+func_order_data+" | Error > "+func_error_message);

      if(IsTesting())
        {
         ObjectCreate(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJ_ARROW,0,0,0);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_ARROWCODE,108);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TIME1,TimeCurrent());
         ObjectSetDouble(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_PRICE1,Close[0]);
         ObjectSetString(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TEXT,func_error_message);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError_Modify(int input_errorcode,string input_symbol,int input_ticket
                      ,int input_type,double input_open_price,double input_sl,double input_tp)
  {
   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   int func_digits=(int)MarketInfo(input_symbol,MODE_DIGITS);
   int func_stop_level=(int)MarketInfo(input_symbol,MODE_STOPLEVEL);

   if(input_type==OP_BUY)
      op_string="Buy";
   else if(input_type==OP_SELL)
      op_string="Sell";
   else if(input_type==OP_BUYSTOP)
      op_string="BuyStop";
   else if(input_type==OP_BUYLIMIT)
      op_string="BuyLimit";
   else if(input_type==OP_SELLSTOP)
      op_string="SellStop";
   else if(input_type==OP_SELLLIMIT)
      op_string="SellLimit";

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" at "
                          +DoubleToStr(input_open_price,func_digits)+" SL "+DoubleToStr(input_sl,func_digits)+" TP "+DoubleToStr(input_tp,func_digits);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && input_errorcode!=error_last_error_code)))
     {
      error_last_error_code=input_errorcode;

      if(input_errorcode==130)
        {
         double func_sl_point=0,func_tp_point=0;

         if(input_type==OP_BUY)
           {
            func_sl_point=NormalizeDouble((MarketInfo(input_symbol,MODE_BID)-input_sl)/func_point,0);
            func_tp_point=NormalizeDouble((input_tp-MarketInfo(input_symbol,MODE_BID))/func_point,0);
           }
         else if(input_type==OP_SELL)
           {
            func_sl_point=NormalizeDouble((input_sl-MarketInfo(input_symbol,MODE_ASK))/func_point,0);
            func_tp_point=NormalizeDouble((MarketInfo(input_symbol,MODE_ASK)-input_tp)/func_point,0);
           }
         else if(input_type==OP_BUYSTOP || input_type==OP_BUYLIMIT)
           {
            func_sl_point=NormalizeDouble((input_open_price-input_sl)/func_point,0);
            func_tp_point=NormalizeDouble((input_tp-input_open_price)/func_point,0);
           }
         else if(input_type==OP_SELLSTOP || input_type==OP_SELLLIMIT)
           {
            func_sl_point=NormalizeDouble((input_sl-input_open_price)/func_point,0);
            func_tp_point=NormalizeDouble((input_open_price-input_tp)/func_point,0);
           }

         if(input_sl!=0 && func_sl_point<func_stop_level)
           {
            func_error_message="SL is too small. (Your SL is "+(string)func_sl_point+" point)";
            Alert(input_symbol+" - SL minimum is "+(string)func_stop_level+" point");
           }
         else if(input_tp!=0 && func_tp_point<func_stop_level)
           {
            func_error_message="TP is too small. (Your TP is "+(string)func_sl_point+" point)";
            Alert(input_symbol+" - TP minimum is "+(string)func_stop_level+" point");
           }
         else if(input_type>=2)
           {
            if(input_type==OP_BUYSTOP && NormalizeDouble(input_open_price-MarketInfo(input_symbol,MODE_ASK),func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((input_open_price-MarketInfo(input_symbol,MODE_ASK))/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
            else if(input_type==OP_BUYLIMIT && NormalizeDouble(MarketInfo(input_symbol,MODE_ASK)-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((MarketInfo(input_symbol,MODE_ASK)-input_open_price)/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
            else if(input_type==OP_SELLSTOP && NormalizeDouble(MarketInfo(input_symbol,MODE_BID)-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((MarketInfo(input_symbol,MODE_BID)-input_open_price)/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
            else if(input_type==OP_SELLLIMIT && NormalizeDouble(input_open_price-MarketInfo(input_symbol,MODE_BID),func_digits)<func_stop_level*func_point)
              {
               func_error_message="Pending distance is too small. (Your distance is "+DoubleToStr((input_open_price-MarketInfo(input_symbol,MODE_BID))/func_point,0)+" point)";
               Alert(input_symbol+" - Pending distance minimum is "+(string)func_stop_level+" point");
              }
           }
        }
      else if(input_errorcode==1)
         func_error_message="Modify SL/TP/Order price is same old SL/TP/order price";
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      Alert(input_symbol+" - Modify "+func_order_data+" | Error > "+func_error_message);

      if(IsTesting())
        {
         ObjectCreate(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJ_ARROW,0,0,0);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_ARROWCODE,108);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TIME1,TimeCurrent());
         ObjectSetDouble(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_PRICE1,Close[0]);
         ObjectSetString(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TEXT,"Error > "+func_error_message);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError_ModifyTP_Only(int input_errorcode,string input_symbol,int input_ticket
                             ,int input_type,double input_open_price,double input_tp)
  {
   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   int func_digits=(int)MarketInfo(input_symbol,MODE_DIGITS);
   int func_stop_level=(int)MarketInfo(input_symbol,MODE_STOPLEVEL);

   if(input_type==OP_BUY)
      op_string="Buy";
   else if(input_type==OP_SELL)
      op_string="Sell";
   else if(input_type==OP_BUYSTOP)
      op_string="BuyStop";
   else if(input_type==OP_BUYLIMIT)
      op_string="BuyLimit";
   else if(input_type==OP_SELLSTOP)
      op_string="SellStop";
   else if(input_type==OP_SELLLIMIT)
      op_string="SellLimit";

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" to TP "+DoubleToStr(input_tp,func_digits);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && input_errorcode!=error_last_error_code)))
     {
      error_last_error_code=input_errorcode;

      if(input_errorcode==130)
        {
         double func_sl_point=0,func_tp_point=0;

         if(input_type==OP_BUY)
            func_tp_point=NormalizeDouble((input_tp-MarketInfo(input_symbol,MODE_BID))/func_point,0);
         else if(input_type==OP_SELL)
            func_tp_point=NormalizeDouble((MarketInfo(input_symbol,MODE_ASK)-input_tp)/func_point,0);
         else if(input_type==OP_BUYSTOP || input_type==OP_BUYLIMIT)
            func_tp_point=NormalizeDouble((input_tp-input_open_price)/func_point,0);
         else if(input_type==OP_SELLSTOP || input_type==OP_SELLLIMIT)
            func_tp_point=NormalizeDouble((input_open_price-input_tp)/func_point,0);

         if(input_tp!=0 && func_tp_point<func_stop_level)
           {
            func_error_message="TP is too small. (Your TP is "+DoubleToStr(func_tp_point,0)+" point)";
            Alert(input_symbol+" - TP minimum is "+(string)func_stop_level+" point");
           }
        }
      else if(input_errorcode==1)
         func_error_message="Modify TP same old TP";
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      Alert(input_symbol+" - Modify TP "+func_order_data+" | Error > "+func_error_message);

      if(IsTesting())
        {
         ObjectCreate(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJ_ARROW,0,0,0);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_ARROWCODE,108);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TIME1,TimeCurrent());
         ObjectSetDouble(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_PRICE1,Close[0]);
         ObjectSetString(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TEXT,"Error > "+func_error_message);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError_ModifySL_Only(int input_errorcode,string input_symbol,int input_ticket
                             ,int input_type,double input_open_price,double input_sl)
  {
   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   int func_digits=(int)MarketInfo(input_symbol,MODE_DIGITS);
   int func_stop_level=(int)MarketInfo(input_symbol,MODE_STOPLEVEL);

   if(input_type==OP_BUY)
      op_string="Buy";
   else if(input_type==OP_SELL)
      op_string="Sell";
   else if(input_type==OP_BUYSTOP)
      op_string="BuyStop";
   else if(input_type==OP_BUYLIMIT)
      op_string="BuyLimit";
   else if(input_type==OP_SELLSTOP)
      op_string="SellStop";
   else if(input_type==OP_SELLLIMIT)
      op_string="SellLimit";

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" to SL "+DoubleToStr(input_sl,func_digits);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && input_errorcode!=error_last_error_code)))
     {
      error_last_error_code=input_errorcode;

      if(input_errorcode==130)
        {
         double func_sl_point=0,func_tp_point=0;

         if(input_type==OP_BUY)
            func_sl_point=NormalizeDouble((MarketInfo(input_symbol,MODE_BID)-input_sl)/func_point,0);
         else if(input_type==OP_SELL)
            func_sl_point=NormalizeDouble((input_sl-MarketInfo(input_symbol,MODE_ASK))/func_point,0);
         else if(input_type==OP_BUYSTOP || input_type==OP_BUYLIMIT)
            func_sl_point=NormalizeDouble((input_open_price-input_sl)/func_point,0);
         else if(input_type==OP_SELLSTOP || input_type==OP_SELLLIMIT)
            func_sl_point=NormalizeDouble((input_sl-input_open_price)/func_point,0);

         if(input_sl!=0 && func_sl_point<func_stop_level)
           {
            func_error_message="SL is too small. (Your SL is "+(string)func_sl_point+" point)";
            Alert(input_symbol+" - SL minimum is "+(string)func_stop_level+" point");
           }
        }
      else if(input_errorcode==1)
         func_error_message="Modify SL same old SL";
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      Alert(input_symbol+" - Modify SL "+func_order_data+" | Error > "+func_error_message);

      if(IsTesting())
        {
         ObjectCreate(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJ_ARROW,0,0,0);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_ARROWCODE,108);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TIME1,TimeCurrent());
         ObjectSetDouble(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_PRICE1,Close[0]);
         ObjectSetString(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TEXT,"Error > "+func_error_message);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError_TrailingStop(int input_errorcode,string input_symbol,int input_ticket
                            ,int input_type,double input_sl)
  {
   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   int func_digits=(int)MarketInfo(input_symbol,MODE_DIGITS);
   int func_stop_level=(int)MarketInfo(input_symbol,MODE_STOPLEVEL);

   if(input_type==OP_BUY)
      op_string="Buy";
   else if(input_type==OP_SELL)
      op_string="Sell";
   else if(input_type==OP_BUYSTOP)
      op_string="BuyStop";
   else if(input_type==OP_BUYLIMIT)
      op_string="BuyLimit";
   else if(input_type==OP_SELLSTOP)
      op_string="SellStop";
   else if(input_type==OP_SELLLIMIT)
      op_string="SellLimit";

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" to SL "+DoubleToStr(input_sl,func_digits);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && input_errorcode!=error_last_error_code)))
     {
      error_last_error_code=input_errorcode;

      if(input_errorcode==130)
        {
         double func_sl_point=0;

         if(input_type==OP_BUY)
            func_sl_point=NormalizeDouble((MarketInfo(input_symbol,MODE_BID)-input_sl)/func_point,0);
         else if(input_type==OP_SELL)
            func_sl_point=NormalizeDouble((input_sl-MarketInfo(input_symbol,MODE_ASK))/func_point,0);

         if(func_sl_point<func_stop_level)
           {
            func_error_message="SL is too small. (Your SL is "+(string)func_sl_point+" point)";
            Alert(input_symbol+" - SL minimum is "+(string)func_stop_level+" point");
           }
        }
      else if(input_errorcode==1)
        {
         Alert(input_symbol+" - TrailingStop "+" "+func_order_data+" | Error > Modify SL same old SL");
        }
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      Alert(input_symbol+" - TrailingStop "+" "+func_order_data+" | Error > "+func_error_message);

      if(IsTesting())
        {
         ObjectCreate(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJ_ARROW,0,0,0);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_COLOR,clrRed);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_ARROWCODE,108);
         ObjectSetInteger(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TIME1,TimeCurrent());
         ObjectSetDouble(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_PRICE1,Close[0]);
         ObjectSetString(0,"Error Obj-"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),OBJPROP_TEXT,"Error > "+func_error_message);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ErrorDescription(int input_errorcode)
  {
   string error_string;

   switch(input_errorcode)
     {
      case 0:   error_string="not found error";                                            break;
      case 1:   error_string="no error, trade conditions not changed";                     break;
      case 2:   error_string="common error";                                               break;
      case 3:   error_string="invalid trade parameters";                                   break;
      case 4:   error_string="Trade server is over load";                                  break;
      case 5:   error_string="Your MT4 version is too old";                                break;
      case 6:   error_string="No connection";                                              break;
      case 7:   error_string="not enough rights";                                          break;
      case 8:   error_string="Too many requestion";                                             break;
      case 9:   error_string="malfunctional trade operation (never returned error)";       break;
      case 64:  error_string="This account is closed";                                     break;
      case 65:  error_string="Account invalid";                                            break;
      case 128: error_string="Time out";                                                   break;
      case 129: error_string="Invalid price";                                              break;
      case 130: error_string="SL or TP or Pending distance is too small";                  break;
      case 131: error_string="Lots is invalid";                                            break;
      case 132: error_string="Market is closed";                                           break;
      case 133: error_string="AutoTrading button is off or not check Allow live trading ,EA is not trading";      break;
      case 134: error_string="Free margin is too small";                                   break;
      case 135: error_string="price changed";                                              break;
      case 136: error_string="off quotes";                                                 break;
      case 137: error_string="broker is busy (never returned error)";                      break;
      case 138: error_string="requote";                                                    break;
      case 139: error_string="order is locked";                                            break;
      case 140: error_string="Allow for Buy only";                                         break;
      case 141: error_string="Too many requestions";                                       break;
      case 145: error_string="modification denied because order is too close to market";   break;
      case 146: error_string="trade context is busy";                                      break;
      case 147: error_string="expirations are denied by broker";                           break;
      case 148: error_string="amount of open and pending orders has reached the limit";    break;
      case 149: error_string="hedging is prohibited";                                      break;
      case 150: error_string="prohibited by FIFO rules";                                   break;

      case 4000: error_string="no error (never generated code)";                           break;
      case 4001: error_string="wrong function pointer";                                    break;
      case 4002: error_string="array index is out of range";                               break;
      case 4003: error_string="no memory for function call stack";                         break;
      case 4004: error_string="recursive stack overflow";                                  break;
      case 4005: error_string="not enough stack for parameter";                            break;
      case 4006: error_string="no memory for parameter string";                            break;
      case 4007: error_string="no memory for temp string";                                 break;
      case 4008: error_string="non-initialized string";                                    break;
      case 4009: error_string="non-initialized string in array";                           break;
      case 4010: error_string="no memory for array\' string";                              break;
      case 4011: error_string="too long string";                                           break;
      case 4012: error_string="remainder from zero divide";                                break;
      case 4013: error_string="zero divide";                                               break;
      case 4014: error_string="unknown command";                                           break;
      case 4015: error_string="wrong jump (never generated error)";                        break;
      case 4016: error_string="non-initialized array";                                     break;
      case 4017: error_string="dll calls are not allowed";                                 break;
      case 4018: error_string="cannot load library";                                       break;
      case 4019: error_string="cannot call function";                                      break;
      case 4020: error_string="expert function calls are not allowed";                     break;
      case 4021: error_string="not enough memory for temp string returned from function";  break;
      case 4022: error_string="system is busy (never generated error)";                    break;
      case 4023: error_string="dll-function call critical error";                          break;
      case 4024: error_string="internal error";                                            break;
      case 4025: error_string="out of memory";                                             break;
      case 4026: error_string="invalid pointer";                                           break;
      case 4027: error_string="too many formatters in the format function";                break;
      case 4028: error_string="parameters count is more than formatters count";            break;
      case 4029: error_string="invalid array";                                             break;
      case 4030: error_string="no reply from chart";                                       break;
      case 4050: error_string="invalid function parameters count";                         break;
      case 4051: error_string="invalid function parameter value";                          break;
      case 4052: error_string="string function internal error";                            break;
      case 4053: error_string="some array error";                                          break;
      case 4054: error_string="incorrect series array usage";                              break;
      case 4055: error_string="custom indicator error";                                    break;
      case 4056: error_string="arrays are incompatible";                                   break;
      case 4057: error_string="global variables processing error";                         break;
      case 4058: error_string="global variable not found";                                 break;
      case 4059: error_string="function is not allowed in testing mode";                   break;
      case 4060: error_string="function is not confirmed";                                 break;
      case 4061: error_string="send mail error";                                           break;
      case 4062: error_string="string parameter expected";                                 break;
      case 4063: error_string="integer parameter expected";                                break;
      case 4064: error_string="double parameter expected";                                 break;
      case 4065: error_string="array as parameter expected";                               break;
      case 4066: error_string="requested history data is in update state";                 break;
      case 4067: error_string="internal trade error";                                      break;
      case 4068: error_string="resource not found";                                        break;
      case 4069: error_string="resource not supported";                                    break;
      case 4070: error_string="duplicate resource";                                        break;
      case 4071: error_string="custom indicator cannot initialize";                        break;
      case 4099: error_string="end of file";                                               break;
      case 4100: error_string="some file error";                                           break;
      case 4101: error_string="wrong file name";                                           break;
      case 4102: error_string="too many opened files";                                     break;
      case 4103: error_string="cannot open file";                                          break;
      case 4104: error_string="incompatible access to a file";                             break;
      case 4105: error_string="no order selected";                                         break;
      case 4106: error_string="unknown symbol";                                            break;
      case 4107: error_string="invalid price parameter for trade function";                break;
      case 4108: error_string="invalid ticket";                                            break;
      case 4109: error_string="trade is not allowed in the expert properties";             break;
      case 4110: error_string="longs are not allowed in the expert properties";            break;
      case 4111: error_string="shorts are not allowed in the expert properties";           break;
      case 4200: error_string="object already exists";                                     break;
      case 4201: error_string="unknown object property";                                   break;
      case 4202: error_string="object does not exist";                                     break;
      case 4203: error_string="unknown object type";                                       break;
      case 4204: error_string="no object name";                                            break;
      case 4205: error_string="object coordinates error";                                  break;
      case 4206: error_string="no specified subwindow";                                    break;
      case 4207: error_string="graphical object error";                                    break;
      case 4210: error_string="unknown chart property";                                    break;
      case 4211: error_string="chart not found";                                           break;
      case 4212: error_string="chart subwindow not found";                                 break;
      case 4213: error_string="chart indicator not found";                                 break;
      case 4220: error_string="symbol select error";                                       break;
      case 4250: error_string="notification error";                                        break;
      case 4251: error_string="notification parameter error";                              break;
      case 4252: error_string="notifications disabled";                                    break;
      case 4253: error_string="notification send too frequent";                            break;
      case 5001: error_string="too many opened files";                                     break;
      case 5002: error_string="wrong file name";                                           break;
      case 5003: error_string="too long file name";                                        break;
      case 5004: error_string="cannot open file";                                          break;
      case 5005: error_string="text file buffer allocation error";                         break;
      case 5006: error_string="cannot delete file";                                        break;
      case 5007: error_string="invalid file handle (file closed or was not opened)";       break;
      case 5008: error_string="wrong file handle (handle index is out of handle table)";   break;
      case 5009: error_string="file must be opened with FILE_WRITE flag";                  break;
      case 5010: error_string="file must be opened with FILE_READ flag";                   break;
      case 5011: error_string="file must be opened with FILE_BIN flag";                    break;
      case 5012: error_string="file must be opened with FILE_TXT flag";                    break;
      case 5013: error_string="file must be opened with FILE_TXT or FILE_CSV flag";        break;
      case 5014: error_string="file must be opened with FILE_CSV flag";                    break;
      case 5015: error_string="file read error";                                           break;
      case 5016: error_string="file write error";                                          break;
      case 5017: error_string="string size must be specified for binary file";             break;
      case 5018: error_string="incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: error_string="file is directory, not file";                               break;
      case 5020: error_string="file does not exist";                                       break;
      case 5021: error_string="file cannot be rewritten";                                  break;
      case 5022: error_string="wrong directory name";                                      break;
      case 5023: error_string="directory does not exist";                                  break;
      case 5024: error_string="specified file is not directory";                           break;
      case 5025: error_string="cannot delete directory";                                   break;
      case 5026: error_string="cannot clean directory";                                    break;
      case 5027: error_string="array resize error";                                        break;
      case 5028: error_string="string resize error";                                       break;
      case 5029: error_string="structure contains strings or dynamic arrays";              break;
      default:   error_string="unknown error";
     }

   return error_string;
  }
//+------------------------------------------------------------------+
