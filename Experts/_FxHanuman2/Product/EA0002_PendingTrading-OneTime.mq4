//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define NHM_GateName       "Gateway.php" 
#define NHM_SaverHost      "http://www.fxhanuman.com/web/eafx/"
//#define NHM_SaverHost    "http://127.0.0.1/HNM/"
#define NHM_Product        "EA0002"
#define NHM_Name           "PendingTrading"
#define NHM_Encode         true
#property description      NHM_Product
//---
#include <Hanuman_API.mqh>
CHanuman Hanuman;
//---
#property copyright "Copyright 05-2019, www.FxHanuman.com"
#property link      "https://www.fxhanuman.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enum_OrderType
  {
   Buy=0
   ,Sell=1
  };

input int MagicNumber=2344;
input bool Count_AllOrders=false;
input bool OneTimeTrade=false;
input string TradeSetting="----------------------------------------------------------------------";
input enum_OrderType First_OrderType=Buy;
input double FirstLots=0.01;
input double LotsMultiply=2;
input int _DistancePoint=100;
int DistancePoint=100;
input int _TP=120;//TP
int TP=-1;
input int MaxOrders=5;
input double CutLoss_Percent=-20; //Cutloss %

bool OrderV;
int getlasterror;
datetime start_time,end_time;
int last_opening;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Hanuman._Init(NHM_SaverHost,NHM_GateName,NHM_Product,NHM_Name,NHM_Encode);

   last_opening=OrdersTotalInSymbol();
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
   int stop_level=int(MarketInfo(Symbol(),MODE_STOPLEVEL));

   if(_TP<stop_level)
     {
      TP=stop_level*2;
      Comment("TP is too small.(min "+IntegerToString(stop_level)+")");
      ////Alert("TP is too small.(min "+IntegerToString(stop_level)+")");
      return;
     }
   else
     {
      TP=_TP;
     }

   if(DistancePoint<stop_level)
     {
      DistancePoint=stop_level*2;
      Comment("DistancePoint is too small.(min "+IntegerToString(stop_level)+")");
      ////Alert("DistancePoint is too small.(min "+IntegerToString(stop_level)+")");
      return;
     }
   else
     {
      DistancePoint=_DistancePoint;
     }

   if(OrdersNormallTotal()>0 && CutLoss_Percent!=0 && TotalOpeningProfit()<0 && MathAbs(TotalOpeningProfit())>=MathAbs(CutLoss_Percent))
     {
      CloseAndDeleteAll();
      //Alert(Symbol()+"- Close all by Cutloss%");
     }

   if(OrdersNormallTotal()==0 && OrdersPendingTotal()>0)
      DeletePendingAll();

   string CMM="";

   if(AccountBalance()!=0)
     {
      CMM+="Opening profit: "+DoubleToStr(TotalOpeningProfit(),2)+" "+AccountCurrency()+" ("+DoubleToStr((100*TotalOpeningProfit())/AccountBalance(),2)+"%)";
      CMM+="\n";
      CMM+="Order ["+string(MagicNumber)+"] "+string(OrdersNormallTotal()) +" | "+ string(OrdersPendingTotal());

      Comment(CMM);
     }

   if(OneTimeTrade && last_opening>0 && OrdersTotalInSymbol()==0)
     {
      //Alert("OneTimeTrade! EA is removed.");
      CMM+="\n";
      CMM+="OneTimeTrade! EA is Stop.";
      //ExpertRemove();

      Comment(CMM);
      return;
     }

   bool Check=true;

   if(OrdersNormallTotal()==0 && OrdersPendingTotal()==0)
     {
      Check=Hanuman._Check();
      //---
      if(false)
        {
         if(First_OrderType==Buy)
            _OrderSend(Symbol(),OP_BUY,FirstLots,Ask,0,Ask+(TP*Point),"PendingTrading",MagicNumber);
         if(First_OrderType==Sell)
            _OrderSend(Symbol(),OP_SELL,FirstLots,Bid,0,Bid-(TP*Point),"PendingTrading",MagicNumber);

        }
     }

   if(
      (OrdersNormallTotal()<MaxOrders) && (OrdersPendingTotal()==0) && 
      OrderSelect(TicketLastNormallOpening(),SELECT_BY_TICKET,MODE_TRADES) && Check
      )
     {
      int rOrderSend=-1;
      if(OrderType()==OP_BUY)
        {
         rOrderSend=_OrderSend(Symbol(),OP_SELLSTOP,NormalizeDouble(OrderLots()*LotsMultiply,LotsDigits()),OrderOpenPrice()-(DistancePoint*Point),0,0,"PendingTrading",MagicNumber);
         if(rOrderSend>0) Hanuman._Scout();
        }
      if(OrderType()==OP_SELL)
        {
         rOrderSend=_OrderSend(Symbol(),OP_BUYSTOP,NormalizeDouble(OrderLots()*LotsMultiply,LotsDigits()),OrderOpenPrice()+(DistancePoint*Point),0,0,"PendingTrading",MagicNumber);
         if(rOrderSend>0) Hanuman._Scout();
        }

     }

   int total_normall_opening=OrdersNormallTotal();
   last_opening=OrdersTotalInSymbol();

   if(total_normall_opening>=2)
     {
      DeleteTPAll();
      OrderV=OrderSelect(TicketLastNormallOpening(),SELECT_BY_TICKET,MODE_TRADES);

      if(OrderType()==OP_BUY)
        {
         _CreateHline("TP all",OrderOpenPrice()+(TP*Point),clrBlue,2);

         if(NormalizeDouble(Bid,Digits)>=NormalizeDouble(OrderOpenPrice()+(TP*Point),Digits))
           {
            CloseAndDeleteAll();
            ObjectDelete(0,"TP all");
           }
        }
      else if(OrderType()==OP_SELL)
        {
         _CreateHline("TP all",OrderOpenPrice()-(TP*Point),clrBlue,2);

         if(NormalizeDouble(Ask,Digits)<=NormalizeDouble(OrderOpenPrice()-(TP*Point),Digits))
           {
            CloseAndDeleteAll();
            ObjectDelete(0,"TP all");
           }
        }
     }

   if(OrdersNormallTotal()<=1 && ObjectFind(0,"TP all")!=-1)
      ObjectDelete(0,"TP all");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   Hanuman._ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrdersTotalInSymbol()
  {
   int func_total_orders=0;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         func_total_orders++;
     }

   return func_total_orders;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalOpeningProfit()
  {
   double func_total_profit_opening=0;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1 && OrderMagicNumber()==MagicNumber)
         func_total_profit_opening+=OrderProfit()+OrderCommission()+OrderSwap();
     }

   return func_total_profit_opening;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAndDeleteAll()
  {
   int func_getlasterror;

   while(OrdersNormallTotal()>0 || OrdersPendingTotal()>0)
     {
      for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
        {
         if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol())
           {
            if(OrderType()==OP_BUY)
              {
               func_getlasterror=-1;
               while(func_getlasterror==-1 || (!IsTesting() && (func_getlasterror==129 || func_getlasterror==138 || func_getlasterror==136)))
                 {
                  RefreshRates();
                  OrderV=OrderClose(OrderTicket(),OrderLots(),Bid,0,clrNONE);
                  func_getlasterror=GetLastError();
                 }
              }
            else if(OrderType()==OP_SELL)
              {
               func_getlasterror=-1;
               while(func_getlasterror==-1 || (!IsTesting() && (func_getlasterror==129 || func_getlasterror==138 || func_getlasterror==136)))
                 {
                  RefreshRates();
                  OrderV=OrderClose(OrderTicket(),OrderLots(),Ask,0,clrNONE);
                  func_getlasterror=GetLastError();
                 }
              }
            else if(OrderType()>=2)
              {
               OrderV=OrderDelete(OrderTicket());
              }
           }

         if(IsStopped())
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteTPAll()
  {
   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && (Count_AllOrders || (!Count_AllOrders && OrderMagicNumber()==MagicNumber))
         && OrderTakeProfit()!=0)
        {
         OrderV=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),0,OrderExpiration(),clrNONE);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _CreateHline(string input_name,double input_price,int input_color=clrRed,int input_width=1)
  {
   ObjectCreate(0,input_name,OBJ_HLINE,0,0,0);
   ObjectSetDouble(0,input_name,OBJPROP_PRICE1,input_price);
   ObjectSetInteger(0,input_name,OBJPROP_COLOR,input_color);
   ObjectSetInteger(0,input_name,OBJPROP_WIDTH,input_width);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeletePendingAll()
  {
   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()>=2
         && (Count_AllOrders || (!Count_AllOrders && OrderMagicNumber()==MagicNumber)))
        {
         OrderV=OrderDelete(OrderTicket());
        }
     }
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

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TicketLastNormallOpening()
  {
   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol()  &&  OrderType()<=1
         &&(Count_AllOrders ||(!Count_AllOrders  &&  OrderMagicNumber()==MagicNumber)))
         return OrderTicket();
     }

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrdersNormallTotal()
  {
   int func_total_orders=0;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderType()<=1
         && (Count_AllOrders || (!Count_AllOrders && OrderMagicNumber()==MagicNumber)))
        {
         func_total_orders++;
        }
     }

   return func_total_orders;
  }
//----------------------------------------------------------------------------------------------------------------
int OrdersPendingTotal()
  {
   int func_total_orders=0;

   for(int func_i=OrdersTotal()-1;func_i>=0;func_i--)
     {
      if(OrderSelect(func_i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol()  &&  OrderType()>=2
         &&(Count_AllOrders ||(!Count_AllOrders  &&  OrderMagicNumber()==MagicNumber)))
         func_total_orders++;
     }

   return func_total_orders;
  }
//----------------------------------------------------------------------------------------------------------------
double SetStoploss(int input_type,double input_price,int input_pips)
  {
   if(input_pips==0)return 0;
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
   if(input_pips==0)return 0;
   else
     {
      if(input_type==OP_BUY)return input_price+(input_pips*Point);
      if(input_type==OP_SELL)return input_price-(input_pips*Point);
     }

   return -1;
  }
//----------------------------------------------------------------------------------------------------------------
bool _OrderModify(int input_ticket,double input_open_price,double input_sl,double input_tp)
  {
   bool func_success=false;

   if(OrderSelect(input_ticket,SELECT_BY_TICKET,MODE_TRADES) && (NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(input_sl,Digits)
      || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(input_tp,Digits)
      ||  NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(input_open_price,Digits)))
     {
      func_success=OrderModify(OrderTicket(),input_open_price,input_sl,input_tp,0);

      if((NormalizeDouble(OrderOpenPrice(),Digits)==NormalizeDouble(input_open_price,Digits))
         && (NormalizeDouble(OrderStopLoss(),Digits)==NormalizeDouble(input_sl,Digits)) && (NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(input_tp,Digits)))
        {
         ShowError_ModifyTP_Only(GetLastError(),OrderSymbol(),OrderTicket(),OrderType(),input_open_price,input_tp);
        }
      else if((NormalizeDouble(OrderOpenPrice(),Digits)==NormalizeDouble(input_open_price,Digits))
         && (NormalizeDouble(OrderStopLoss(),Digits)!=NormalizeDouble(input_sl,Digits)) && (NormalizeDouble(OrderTakeProfit(),Digits)==NormalizeDouble(input_tp,Digits)))
           {
            if(
               (
               (OrderType()==OP_BUY && (OrderStopLoss()==0 && NormalizeDouble(input_sl,Digits)>=NormalizeDouble(OrderOpenPrice(),Digits)))
               || (OrderStopLoss()!=0 && NormalizeDouble(input_sl,Digits)>NormalizeDouble(OrderStopLoss(),Digits))
               )
               || 
               (
               (OrderType()==OP_SELL && (OrderStopLoss()==0 && NormalizeDouble(input_sl,Digits)<=NormalizeDouble(OrderOpenPrice(),Digits)))
               || (OrderStopLoss()!=0 && NormalizeDouble(input_sl,Digits)<NormalizeDouble(OrderStopLoss(),Digits))
               )
               )
              {
               ShowError_TrailingStop(GetLastError(),OrderSymbol(),OrderTicket(),OrderType(),input_sl);
              }
            else
              {
               ShowError_ModifySL_Only(GetLastError(),OrderSymbol(),OrderTicket(),OrderType(),input_open_price,input_sl);
              }
           }
         else
           {
            ShowError_Modify(GetLastError(),OrderSymbol(),OrderTicket(),OrderType(),input_open_price,input_sl,input_tp);
           }
     }

   return func_success;
  }
//----------------------------------------------------------------------------------------------------------------
bool _OrderClose(int input_ticket)
  {
   bool func_success=false;

   if(OrderSelect(input_ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      double func_close_price=-1;

      if(OrderType()==OP_BUY)
         func_close_price=Bid;
      else if(OrderType()==OP_SELL)
         func_close_price=Ask;

      getlasterror=-1;
      while(getlasterror==-1 || (!IsTesting() && (getlasterror==129 || getlasterror==138 || getlasterror==136 || getlasterror==146)))
        {
         RefreshRates();
         func_success=OrderClose(OrderTicket(),OrderLots(),func_close_price,0);
         getlasterror=GetLastError();
         ShowError_Close(getlasterror,OrderSymbol(),OrderTicket(),OrderType(),OrderLots());
        }
     }

   return func_success;
  }
//----------------------------------------------------------------------------------------------------------------
int _OrderSend(string input_symbol,int input_cmd,double input_lots,double input_open_price,double input_sl=0,double input_tp=0
               ,string input_comment=NULL,int input_magic=0)
  {
   int func_ticket=-1;

   if(input_cmd<=1)
     {
      getlasterror=-1;
      while(getlasterror==-1 || (!IsTesting() && (getlasterror==129 || getlasterror==138 || getlasterror==136 || getlasterror==146)))
        {
         RefreshRates();
         func_ticket=OrderSend(input_symbol,input_cmd,input_lots,input_open_price,0,input_sl,input_tp,input_comment,input_magic);
         getlasterror=GetLastError();
         ShowError_Open(getlasterror,input_symbol,input_cmd,input_lots,input_open_price,input_sl,input_tp);
        }
     }
   else
     {
      func_ticket=OrderSend(input_symbol,input_cmd,input_lots,input_open_price,0,input_sl,input_tp,input_comment,input_magic);
      ShowError_Open(GetLastError(),input_symbol,input_cmd,input_lots,input_open_price,input_sl,input_tp);
     }

   return func_ticket;
  }
//----------------------------------------------------------------------------------------------------------------
int error_last_error_code,error_last_ticket;
double error_last_type,error_last_lots,error_last_open_price,error_last_sl,error_last_tp;
string error_last_symbol;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowError_Open(int input_errorcode,string input_symbol
                    ,int input_type,double input_lots,double input_open_price,double input_sl,double input_tp)
  {
   string func_error_message;
   string op_string;
   string tf_string="";
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   int func_digits=int(MarketInfo(input_symbol,MODE_DIGITS));
   int func_stop_level=int(MarketInfo(input_symbol,MODE_STOPLEVEL));

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

   string func_order_data=input_symbol+" "+op_string+" "+DoubleToStr(input_lots,2)+" ·ÕèÃÒ¤Ò "
                          +DoubleToStr(input_open_price,func_digits)+" SL "+DoubleToStr(input_sl,func_digits)+" TP "+DoubleToStr(input_tp,func_digits);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && (input_errorcode!=error_last_error_code || error_last_symbol!=input_symbol || error_last_type!=input_type
      || error_last_lots!=input_lots || (input_type>=2 && error_last_open_price!=input_open_price) || error_last_sl!=input_sl
      || error_last_tp!=input_tp))))
     {
      error_last_error_code=input_errorcode;
      error_last_symbol=input_symbol;
      error_last_type=input_type;
      error_last_lots=input_lots;
      error_last_open_price=input_open_price;
      error_last_sl=input_sl;
      error_last_tp=input_tp;

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
            func_error_message="ÃÐÂÐ SL ¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+string(func_sl_point)+" point)";
            ////Alert(input_symbol+" ÃÐÂÐ SL ¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
           }
         else if(input_tp!=0 && func_tp_point<func_stop_level)
           {
            func_error_message="ÃÐÂÐ TP ¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+string(func_tp_point)+" point)";
            ////Alert(input_symbol+" ÃÐÂÐ TP ¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
           }
         else if(input_type>=2)
           {
            if(input_type==OP_BUYSTOP && NormalizeDouble(input_open_price-Ask,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐËèÒ§à¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+IntegerToString(int(NormalizeDouble((input_open_price-Ask)/func_point,0)))+" point)";
               ////Alert(input_symbol+" ÃÐÂÐËèÒ§à¾¹´Ôé§¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
            else if(input_type==OP_BUYLIMIT && NormalizeDouble(Ask-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐËèÒ§à¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³¤×Í "+IntegerToString(int(NormalizeDouble((Ask-input_open_price)/func_point,0)))+" point)";
               ////Alert(input_symbol+" ÃÐÂÐËèÒ§à¾¹´Ôé§¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
            else if(input_type==OP_SELLSTOP && NormalizeDouble(Bid-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐËèÒ§à¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+IntegerToString(int(NormalizeDouble((Bid-input_open_price)/func_point,0)))+" point)";
               ////Alert(input_symbol+" ÃÐÂÐËèÒ§à¾¹´Ôé§¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
            else if(input_type==OP_SELLLIMIT && NormalizeDouble(input_open_price-Bid,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐËèÒ§à¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+IntegerToString(int(NormalizeDouble((input_open_price-Bid)/func_point,0)))+" point)";
               ////Alert(input_symbol+" ÃÐÂÐËèÒ§à¾¹´Ôé§¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
           }
        }
      else if(input_errorcode==131)
        {
         func_error_message=ErrorDescription(input_errorcode);
         //Alert(input_symbol+" Lots ·ÕèÍ¹Ø­ÒµÔ¤×ÍµÑé§áµè "+DoubleToStr(MarketInfo(input_symbol,MODE_MINLOT),2)+" ¶Ö§ "+DoubleToStr(MarketInfo(input_symbol,MODE_MAXLOT),2)+"");
        }
      else
         func_error_message=ErrorDescription(input_errorcode);

      //Alert("Open "+func_order_data+" | Error > "+func_error_message);

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
void ShowError_Close(int input_errorcode,string input_symbol,int input_ticket,int input_type,double input_lots)
  {
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

   int func_stop_level=int(MarketInfo(input_symbol,MODE_STOPLEVEL));
   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" "+DoubleToStr(input_lots,2);

   if(input_errorcode!=0 &&(IsTesting() || (!IsTesting() &&(input_errorcode!=error_last_error_code || error_last_symbol!=input_symbol
      || error_last_ticket!=input_ticket ||                                                                             error_last_type!=input_type ||                                                                             error_last_lots!=input_lots))))
     {
      error_last_error_code=input_errorcode;
      error_last_symbol=input_symbol;
      error_last_ticket=input_ticket;
      error_last_type=input_type;
      error_last_lots=input_lots;
      func_error_message=ErrorDescription(input_errorcode)+".";
      //Alert("Close "+func_order_data+" | Error > "+func_error_message);

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
   int func_point=int(MarketInfo(input_symbol,MODE_POINT));
   int func_digits=int(MarketInfo(input_symbol,MODE_DIGITS));
   int func_stop_level=int(MarketInfo(input_symbol,MODE_STOPLEVEL));

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

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" ä»ÂÑ§ÃÒ¤Ò "
                          +DoubleToStr(input_open_price,func_digits)+" SL "+DoubleToStr(input_sl,func_digits)+" TP "+DoubleToStr(input_tp,func_digits);

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && (input_errorcode!=error_last_error_code || error_last_symbol!=input_symbol || error_last_ticket!=input_ticket
      || error_last_type!=input_type || error_last_open_price!=input_open_price || error_last_sl!=input_sl || error_last_tp!=input_tp))))
     {
      error_last_error_code=input_errorcode;
      error_last_symbol=input_symbol;
      error_last_ticket=input_ticket;
      error_last_type=input_type;
      error_last_open_price=input_open_price;
      error_last_sl=input_sl;
      error_last_tp=input_tp;

      if(input_errorcode==130)
        {
         double func_sl_point=0,func_tp_point=0;

         if(input_type==OP_BUY)
           {
            func_sl_point=NormalizeDouble((Bid-input_sl)/func_point,0);
            func_tp_point=NormalizeDouble((input_tp-Bid)/func_point,0);
           }
         else if(input_type==OP_SELL)
           {
            func_sl_point=NormalizeDouble((input_sl-Ask)/func_point,0);
            func_tp_point=NormalizeDouble((Ask-input_tp)/func_point,0);
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
            func_error_message="ÃÐÂÐ SL ¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+string(func_sl_point)+" point)";
            //Alert(input_symbol+" ÃÐÂÐ SL ¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
           }
         else if(input_tp!=0 && func_tp_point<func_stop_level)
           {
            func_error_message="ÃÐÂÐ TP ¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+string(func_tp_point)+" point)";
            //Alert(input_symbol+" ÃÐÂÐ TP ¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
           }
         else if(input_type>=2)
           {
            if(input_type==OP_BUYSTOP && NormalizeDouble(input_open_price-Ask,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐà¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+string(NormalizeDouble((input_open_price-Ask)/func_point,0))+" point)";
               //Alert(input_symbol+" ÃÐÂÐà¾¹´Ôé§¢Öé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
            else if(input_type==OP_BUYLIMIT && NormalizeDouble(Ask-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐà¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³"+string(NormalizeDouble((Ask-input_open_price)/func_point,0))+" point)";
               //Alert(input_symbol+" ÃÐÂÐà¾¹´Ôé§¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
            else if(input_type==OP_SELLSTOP && NormalizeDouble(Bid-input_open_price,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐà¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³ "+string(NormalizeDouble((Bid-input_open_price)/func_point,0))+" point)";
               //Alert(input_symbol+" ÃÐÂÐà¾¹Ôé§¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
            else if(input_type==OP_SELLLIMIT && NormalizeDouble(input_open_price-Bid,func_digits)<func_stop_level*func_point)
              {
               func_error_message="ÃÐÂÐà¾¹´Ôé§¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³"+string(NormalizeDouble((input_open_price-Bid)/func_point,0))+" point)";
               //Alert(input_symbol+" ÃÐÂÐà¾¹´Ôé§¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
              }
           }
        }
      else if(input_errorcode==1)
         func_error_message="Modify SL/TP/ÃÒ¤Òà»Ô´ ¤èÒà´ÕÂÇ¡Ñ¹¡Ñº SL/TP/ÃÒ¤Òà»Ô´ à´ÔÁ";
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      //Alert("Modify "+func_order_data+" | Error > "+func_error_message);

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
void ShowError_ModifyTP_Only(int input_errorcode,string input_symbol,int input_ticket
                             ,int input_type,double input_open_price,double input_tp)
  {
   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   double func_digits=MarketInfo(input_symbol,MODE_DIGITS);
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

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" ä»ÂÑ§ TP "+DoubleToStr(input_tp,int(func_digits));

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && (input_errorcode!=error_last_error_code || error_last_symbol!=input_symbol || error_last_ticket!=input_ticket
      || error_last_type!=input_type || error_last_open_price!=input_open_price || error_last_tp!=input_tp))))
     {
      error_last_error_code=input_errorcode;
      error_last_symbol=input_symbol;
      error_last_ticket=input_ticket;
      error_last_type=input_type;
      error_last_open_price=input_open_price;
      error_last_tp=input_tp;

      if(input_errorcode==130)
        {
         double func_sl_point=0,func_tp_point=0;

         if(input_type==OP_BUY)
            func_tp_point=NormalizeDouble((input_tp-Bid)/func_point,0);
         else if(input_type==OP_SELL)
            func_tp_point=NormalizeDouble((Ask-input_tp)/func_point,0);
         else if(input_type==OP_BUYSTOP || input_type==OP_BUYLIMIT)
            func_tp_point=NormalizeDouble((input_tp-input_open_price)/func_point,0);
         else if(input_type==OP_SELLSTOP || input_type==OP_SELLLIMIT)
            func_tp_point=NormalizeDouble((input_open_price-input_tp)/func_point,0);

         if(input_tp!=0 && func_tp_point<func_stop_level)
           {
            func_error_message="ÃÐÂÐ TP ¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³"+string(func_tp_point)+" point)";
            //Alert(input_symbol+" ÃÐÂÐ TP ¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
           }
        }
      else if(input_errorcode==1)
         func_error_message="Modify TP ¤èÒà´ÕÂÇ¡Ñ¹¡Ñº TP à´ÔÁ";
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      //Alert("Modify TP "+func_order_data+" | Error > "+func_error_message);

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
void ShowError_ModifySL_Only(int input_errorcode,string input_symbol,int input_ticket
                             ,int input_type,double input_open_price,double input_sl)
  {
   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   double func_digits=MarketInfo(input_symbol,MODE_DIGITS);
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

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" ä»ÂÑ§ SL "+DoubleToStr(input_sl,int(func_digits));

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && (input_errorcode!=error_last_error_code || error_last_symbol!=input_symbol || error_last_ticket!=input_ticket
      || error_last_type!=input_type || error_last_open_price!=input_open_price || error_last_sl!=input_sl))))
     {
      error_last_error_code=input_errorcode;
      error_last_symbol=input_symbol;
      error_last_ticket=input_ticket;
      error_last_type=input_type;
      error_last_open_price=input_open_price;
      error_last_sl=input_sl;

      if(input_errorcode==130)
        {
         double func_sl_point=0,func_tp_point=0;

         if(input_type==OP_BUY)
            func_sl_point=NormalizeDouble((Bid-input_sl)/func_point,0);
         else if(input_type==OP_SELL)
            func_sl_point=NormalizeDouble((input_sl-Ask)/func_point,0);
         else if(input_type==OP_BUYSTOP || input_type==OP_BUYLIMIT)
            func_sl_point=NormalizeDouble((input_open_price-input_sl)/func_point,0);
         else if(input_type==OP_SELLSTOP || input_type==OP_SELLLIMIT)
            func_sl_point=NormalizeDouble((input_sl-input_open_price)/func_point,0);

         if(input_sl!=0 && func_sl_point<func_stop_level)
           {
            func_error_message="ÃÐÂÐ SL ¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³"+string(func_sl_point)+" point)";
            //Alert(input_symbol+" ÃÐÂÐ SL ¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
           }
        }
      else if(input_errorcode==1)
         func_error_message="Modify SL ¤èÒà´ÕÂÇ¡Ñ¹¡Ñº SL à´ÔÁ";
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      //Alert("Modify SL "+func_order_data+" | Error > "+func_error_message);

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
void ShowError_TrailingStop(int input_errorcode,string input_symbol,int input_ticket
                            ,int input_type,double input_sl)
  {
   string func_error_message;
   string op_string;
   double func_point=MarketInfo(input_symbol,MODE_POINT);
   double func_digits=MarketInfo(input_symbol,MODE_DIGITS);
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

   string func_order_data=IntegerToString(input_ticket)+" "+input_symbol+" "+op_string+" ä»ÂÑ§ SL "+DoubleToStr(input_sl,int(func_digits));

   if(input_errorcode!=0 && (IsTesting() || (!IsTesting() && (input_errorcode!=error_last_error_code || error_last_symbol!=input_symbol || error_last_ticket!=input_ticket
      || error_last_type!=input_type || error_last_sl!=input_sl))))
     {
      error_last_error_code=input_errorcode;
      error_last_symbol=input_symbol;
      error_last_ticket=input_ticket;
      error_last_type=input_type;
      error_last_sl=input_sl;

      if(input_errorcode==130)
        {
         double func_sl_point=0;

         if(input_type==OP_BUY)
            func_sl_point=NormalizeDouble((Bid-input_sl)/func_point,0);
         else if(input_type==OP_SELL)
            func_sl_point=NormalizeDouble((input_sl-Ask)/func_point,0);

         if(func_sl_point<func_stop_level)
           {
            func_order_data="ÃÐÂÐ SL ¹éÍÂà¡Ô¹ä» (ÃÐÂÐ¢Í§¤Ø³"+string(func_sl_point)+" point)";
            //Alert(input_symbol+" ÃÐÂÐ SL ¢Ñé¹µèÓ¤×Í "+IntegerToString(func_stop_level)+" point");
           }
        }
      else if(input_errorcode==1)
        {
         //Alert("TrailingStop "+" "+func_order_data+" | Error > Modify SL ¤èÒà´ÕÂÇ¡Ñ¹¡Ñº SL à´ÔÁ");
        }
      else
         func_error_message=ErrorDescription(input_errorcode)+".";

      //Alert("TrailingStop "+" "+func_order_data+" | Error > "+func_error_message);

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
string ErrorDescription(int input_errorcode)
  {
   string error_string;

   switch(input_errorcode)
     {
      case 0:   error_string="äÁè¾º¢éÍ¼Ô´¾ÅÒ´";                                                   break;
      case 1:   error_string="no error, trade conditions not changed";                     break;
      case 2:   error_string="common error";                                               break;
      case 3:   error_string="invalid trade parameters";                                   break;
      case 4:   error_string="à«Ô¿àÇÍÃìà·Ã´¡ÓÅÑ§·Ó§Ò¹Ë¹Ñ¡";                                       break;
      case 5:   error_string="àÇÍÃìªè¹¢Í§ MT4 ·Õè¤Ø³ãªéà¡èÒà¡Ô¹ä»";                         break;
      case 6:   error_string="äÁèÁÕ¡ÒÃàª×èÍÁµèÍ¡Ñºà«Ô¿àÇÍÃìà·Ã´";                            break;
      case 7:   error_string="not enough rights";                                          break;
      case 8:   error_string="Êè§¤ÓÊÑè§¶Õèà¡Ô¹ä»";                                      break;
      case 9:   error_string="malfunctional trade operation (never returned error)";       break;
      case 64:  error_string="áÍ¤à¤Ò·ì¹Õé¶Ù¡»Ô´¡ÒÃãªé§Ò¹áÅéÇ";                                           break;
      case 65:  error_string="áÍ¤à¤Ò·ì¼Ô´¾ÅÒ´";                                            break;
      case 128: error_string="ËÁ´àÇÅÒà·Ã´";                                              break;
      case 129: error_string="ÃÒ¤ÒäÁè¶Ù¡µéÍ§";                                              break;
      case 130: error_string="SL ËÃ×Í TP ËÃ×Í ÃÐÂÐËèÒ§¢Í§à¾¹´Ôé§¹éÍÂà¡Ô¹ä»";                   break;
      case 131: error_string="Lots äÁè¶Ù¡µéÍ§";                                            break;
      case 132: error_string="µÅÒ´»Ô´áÅéÇ";                                           break;
      case 133: error_string="»ØèÁ AutoTrading äÁèä´é¡´ ËÃ×ÍäÁèä´éµÔê¡ Allow live trading"; break;
      case 134: error_string="ÁÒÃì¨Ôé¹äÁè¾Íà»Ô´ÍÍà´ÍÃì";                                           break;
      case 135: error_string="price changed";                                              break;
      case 136: error_string="off quotes";                                                 break;
      case 137: error_string="broker is busy (never returned error)";                      break;
      case 138: error_string="requote";                                                    break;
      case 139: error_string="order is locked";                                            break;
      case 140: error_string="Í¹Ø­ÒµÔãËé Buy à·èÒ¹Ñé¹";                                break;
      case 141: error_string="Êè§¤ÓÊÑè§ÁÒ¡à¡Ô¹ä»";                                          break;
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
