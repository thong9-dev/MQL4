//+------------------------------------------------------------------+
//|                                                     IdealTrader  |
//|                  Copyright IdealTrader MetaQuotes Software Corp. |
//|                                       IdealTrader_EA@outlook.com |
//+------------------------------------------------------------------+
#property copyright "Copyright IdealTrader, MetaQuotes Software Corp."
#property link      "www.IdealTrader_EA.com"
#property version   "1.02"

int     _account =426719;
int     _expire=1598356625; //https://www.epochconverter.com/

input int    Magicnumber  = 5555;
input double Lots         = 0.01;
input double Multiply     = 1.50;
input double Profit       = 1.00;
input int    MaxOrders    = 33;
input int    Steps        = 500;
input string _a           = "-------------------------------------";
input int PeriodMAFast=3;
input ENUM_APPLIED_PRICE PriceFast=0;
input ENUM_MA_METHOD MethodFast=1;
input string _b="-------------------------------------";
input int PeriodMASlow=15;
input ENUM_APPLIED_PRICE PriceSlow=0;
input ENUM_MA_METHOD MethodSlow=1;
input string _c="-------------------------------------";
input int   SpreadLimit=30;
input string _Comments="p-value < 0.05";

bool UseMartingale=true;
int magic=Magicnumber;
int i,j,k,ticket;
string _des;
double _fma1,_fma2,_sma1,_sma2;

static int BARS;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   if(BARS!=Bars(_Symbol,_Period))
     {
      BARS=Bars(_Symbol,_Period);
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int _exp=StringFormat("%i",TimeLocal());

   if(AccountNumber()==_account && _exp<_expire)
     {
      if(IsNewBar()==true)
        {
         int _smt = MethodSlow;
         int _fmt = MethodFast;
         int _fp = PriceFast;
         int _sp = PriceFast;

         _fma1   = iMA(Symbol(),0,PeriodMAFast,0,_fmt,_fp,1);
         _fma2   = iMA(Symbol(),0,PeriodMAFast,0,_fmt,_fp,2);
         _sma1   = iMA(Symbol(),0,PeriodMASlow,0,_smt,_sp,1);
         _sma2   = iMA(Symbol(),0,PeriodMASlow,0,_smt,_sp,2);


         if(_fma1>=_sma1 && _fma2<_sma2)
           {
            if(checkBuy(Magicnumber)==false && MarketInfo(Symbol(),MODE_SPREAD)<=SpreadLimit)
              {
               ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,_Comments,Magicnumber,0,clrBlue);
              }
            if(checkSell(Magicnumber)==false && MarketInfo(Symbol(),MODE_SPREAD)<=SpreadLimit)
              {
               ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,_Comments,Magicnumber,0,clrRed);
              }
           }//1st order

         if(_fma1<= _sma1 && _fma2>_sma2)
           {
            if(checkBuy(Magicnumber)==false)
              {
               ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,_Comments,Magicnumber,0,clrBlue);
              }
            if(checkSell(Magicnumber)==false)
              {
               ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,_Comments,Magicnumber,0,clrRed);
              }
           }//1st order
        }//new bar

      if(UseMartingale==true)
        {
         if(checkBuy(magic)==true && _OrderTotal(0,magic)<MaxOrders && Ask<LastOrderPrice(0,magic,Symbol())-Steps*Point && _fma1>=_sma1 && _fma2<_sma2)
           {
            ticket=OrderSend(Symbol(),OP_BUY,_LotsM(0,magic),Ask,3,0,0,_Comments,magic,0,clrBlue);
           }
         //--------------------------------------------------------------------------------

         if(checkSell(magic)==true && _OrderTotal(1,magic)<MaxOrders && Bid>LastOrderPrice(1,magic,Symbol())+Steps*Point && _fma1<=_sma1 && _fma2>_sma2)
           {
            ticket=OrderSend(Symbol(),OP_SELL,_LotsM(1,magic),Bid,3,0,0,_Comments,magic,0,clrRed);
           }
        }

      CheckProfit(Profit,magic);
      ShowData();
     }
   else
     {
      long x_distance;
      long y_distance;

      if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
        {
         Print("Failed to get the chart width! Error code = ",GetLastError());
         return;
        }
      if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
        {
         Print("Failed to get the chart height! Error code = ",GetLastError());
         return;
        }

      ObjectCreate("EAname",OBJ_LABEL,0,0,0);
      ObjectSetText("EAname","Please Contact :: IdealTrader_EA@outlook.com",20,"Verdana Bold",clrWhiteSmoke);
      ObjectSet("EAname",OBJPROP_CORNER,0);
      ObjectSet("EAname",OBJPROP_XDISTANCE,(x_distance/2)-225);
      ObjectSet("EAname",OBJPROP_YDISTANCE,(y_distance/2)-50);
     }
  }//tick
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckProfit(double _tp,int _m)
  {
   double __pfb = 0;
   double __pfs = 0;

   for(i=0; i<=OrdersTotal(); i++)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==_m && OrderType()==OP_BUY)
        {
         __pfb=__pfb+OrderProfit()+OrderSwap()+OrderCommission();
        }
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==_m && OrderType()==OP_SELL)
        {
         __pfs=__pfs+OrderProfit()+OrderSwap()+OrderCommission();
        }
     }

   if(__pfb>=_tp && __pfs>=_tp)
     {
      CloseAll(0,_m);
      CloseAll(1,_m);
     }

  }//profit
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll(int t,int _m)
  {

   do
     {
      bool HaveOrders=false;
      for(i=0; i<=OrdersTotal(); i++)
        {
         if(t==0)
           {
            ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==_m && OrderType()==OP_BUY)
              {
               HaveOrders=true;
               ticket=OrderClose(OrderTicket(),OrderLots(),Bid,3,clrNONE);
              }
           }

         if(t==1)
           {
            ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==_m && OrderType()==OP_SELL)
              {
               HaveOrders=true;
               ticket=OrderClose(OrderTicket(),OrderLots(),Ask,3,clrNONE);
              }
           }
        }
     }
   while(HaveOrders==true);
  }//close all
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkBuy(int m)
  {
   bool b=false;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==m && OrderType()==OP_BUY)
        {
         b=true;
         break;
        }
     }
   return(b);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkSell(int m)
  {
   bool s=false;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==m && OrderType()==OP_SELL)
        {
         s=true;
         break;
        }
     }
   return(s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _LotsM(int type,int _m)
  {
//
//input double Lots         = 0.01;
//input double Multiply     = 1.50;

   double _lot=Lots;//0.01

   if(type==0)
     {
      for(i=0; i<=OrdersTotal(); i++)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==_m && OrderType()==OP_BUY)
           {
            _lot=_lot*Multiply;
           }
        }
     }
   if(type==1)
     {
      for(i=0; i<=OrdersTotal(); i++)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==_m && OrderType()==OP_SELL)
           {
            _lot=_lot*Multiply;
           }
        }
     }
   return(_lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _OrderTotal(int type,int m)
  {
   int _orders=0;
   if(type==0)
     {
      _orders=0;
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==m && OrderType()==OP_BUY)
           {
            _orders=_orders+1;
           }
        }
     }
   if(type==1)
     {
      _orders=0;
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==m && OrderType()==OP_SELL)
           {
            _orders=_orders+1;
           }
        }
     }
   return(_orders);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastOrderPrice(int _type,int _magic,string _pair)
  {
   double _price;
   if(_type==0)
     {
      _price=9999999;
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==_pair && OrderMagicNumber()==_magic && OrderType()==OP_BUY)
           {
            if(OrderOpenPrice()<_price)
              {
               _price=OrderOpenPrice();
              }
           }
        }
     }
   if(_type==1)
     {
      _price=0;
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==_pair && OrderMagicNumber()==_magic && OrderType()==OP_SELL)
           {
            if(OrderOpenPrice()>_price)
              {
               _price=OrderOpenPrice();
              }
           }
        }
     }
   return(_price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _ob()
  {
   double ob=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY)
        {
         ob=ob+OrderProfit();
        }
     }
   return(ob);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _oob()
  {
   int oob=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_BUY)
        {
         oob=oob+1;
        }
     }
   return(oob);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _os()
  {
   double os=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL)
        {
         os=os+OrderProfit();
        }
     }
   return(os);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _oos()
  {
   int oos=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==OP_SELL)
        {
         oos=oos+1;
        }
     }
   return(oos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _sw()
  {
   double sw=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         sw=sw+OrderSwap();
        }
     }
   return(sw);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _cm()
  {
   double cm=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         cm=cm+OrderCommission();
        }
     }
   return(cm);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _pf()
  {
   double pf=0;
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         pf=pf+OrderProfit();
        }
     }
   return(pf);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowData()
  {

   long x_distance;
   long y_distance;
   int xx=1,yy=1;

   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return;
     }
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
     {
      Print("Failed to get the chart height! Error code = ",GetLastError());
      return;
     }

   xx=200;
   yy=(int)x_distance-185;
   ObjectCreate(0,"object",OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(0,"object",OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,"object",OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,"object",OBJPROP_YDISTANCE,25);
   ObjectSetInteger(0,"object",OBJPROP_XSIZE,182);
   ObjectSetInteger(0,"object",OBJPROP_ZORDER,0);
   ObjectSetInteger(0,"object",OBJPROP_YSIZE,255);
   ObjectSetInteger(0,"object",OBJPROP_CORNER,1);


   ObjectCreate("EAname",OBJ_LABEL,0,0,0);
   ObjectSetText("EAname","MB II :: Fully AutoTrade",8,"Verdana Bold",clrWhiteSmoke);
   ObjectSet("EAname",OBJPROP_CORNER,0);
   ObjectSet("EAname",OBJPROP_XDISTANCE,yy);
   ObjectSet("EAname",OBJPROP_YDISTANCE,35);

//----------------------------------------------------------------------------------------------
   ObjectCreate("klc34",OBJ_LABEL,0,0,0);
   ObjectSetText("klc34",AccountServer(),7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc34",OBJPROP_CORNER,0);
   ObjectSet("klc34",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc34",OBJPROP_YDISTANCE,55);
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------

   ObjectCreate("klc21",OBJ_LABEL,0,0,0);
   ObjectSetText("klc21","Magic :: "+IntegerToString(magic,0)+" | Steps :: "+IntegerToString(Steps),7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc21",OBJPROP_CORNER,0);
   ObjectSet("klc21",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc21",OBJPROP_YDISTANCE,70);
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
   ObjectCreate("klc20",OBJ_LABEL,0,0,0);
   ObjectSetText("klc20","Lots :: "+DoubleToString(Lots,2)+" | Profit :: "+DoubleToStr(Profit,2),7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc20",OBJPROP_CORNER,0);
   ObjectSet("klc20",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc20",OBJPROP_YDISTANCE,85);
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
   ObjectCreate("klc201211200",OBJ_LABEL,0,0,0);
   ObjectSetText("klc201211200","Equity :: "+DoubleToStr(AccountEquity(),2)+" | "+DoubleToStr(AccountEquity()/AccountBalance(),2)+"%",7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc201211200",OBJPROP_CORNER,0);
   ObjectSet("klc201211200",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc201211200",OBJPROP_YDISTANCE,100);
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
   ObjectCreate("12klc20",OBJ_LABEL,0,0,0);
   ObjectSetText("12klc20","Free Margin :: "+DoubleToStr(AccountFreeMargin(),2),7,"Verdana",clrWhiteSmoke);
   ObjectSet("12klc20",OBJPROP_CORNER,0);
   ObjectSet("12klc20",OBJPROP_XDISTANCE,yy);
   ObjectSet("12klc20",OBJPROP_YDISTANCE,115);
//----------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------
   ObjectCreate("klc20111",OBJ_LABEL,0,0,0);
   ObjectSetText("klc20111","------------------------------",7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc20111",OBJPROP_CORNER,0);
   ObjectSet("klc20111",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc20111",OBJPROP_YDISTANCE,130);
//----------------------------------------------------------------------------------------------

   color _pfb=16119285;
   if(_ob()==0)
     {
      _pfb=clrWhiteSmoke;
     }
   else
      if(_ob()>0)
        {
         _pfb=clrAqua;
        }
      else
        {
         _pfb=clrRed;
        }
//----------------------------------------------------------------------------------------------
   ObjectCreate("klc2ee0121",OBJ_LABEL,0,0,0);
   ObjectSetText("klc2ee0121","Sum Profit Buy("+_oob()+")   :: ",7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc2ee0121",OBJPROP_CORNER,0);
   ObjectSet("klc2ee0121",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc2ee0121",OBJPROP_YDISTANCE,145);
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
   ObjectCreate("plc2ee0121",OBJ_LABEL,0,0,0);
   ObjectSetText("plc2ee0121",DoubleToStr(_ob(),2),7,"Verdana",_pfb);
   ObjectSet("plc2ee0121",OBJPROP_CORNER,0);
   ObjectSet("plc2ee0121",OBJPROP_XDISTANCE,yy+110);
   ObjectSet("plc2ee0121",OBJPROP_YDISTANCE,145);
//----------------------------------------------------------------------------------------------



   color _pfs=16119285;
   if(_os()==0)
     {
      _pfs=clrWhiteSmoke;
     }
   else
      if(_os()>0)
        {
         _pfs=clrAqua;
        }
      else
        {
         _pfs=clrRed;
        }
//----------------------------------------------------------------------------------------------
   ObjectCreate("klc01211",OBJ_LABEL,0,0,0);
   ObjectSetText("klc01211","Sum Profit Sell("+_oos()+")   :: ",7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc01211",OBJPROP_CORNER,0);
   ObjectSet("klc01211",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc01211",OBJPROP_YDISTANCE,160);
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
   ObjectCreate("plc01211",OBJ_LABEL,0,0,0);
   ObjectSetText("plc01211",DoubleToStr(_os(),2),7,"Verdana",_pfs);
   ObjectSet("plc01211",OBJPROP_CORNER,0);
   ObjectSet("plc01211",OBJPROP_XDISTANCE,yy+110);
   ObjectSet("plc01211",OBJPROP_YDISTANCE,160);
//----------------------------------------------------------------------------------------------


   color _pfc=16119285;
   if(_pf()==0)
     {
      _pfc=clrWhiteSmoke;
     }
   else
      if(_pf()>0)
        {
         _pfc=clrAqua;
        }
      else
        {
         _pfc=clrRed;
        }
//----------------------------------------------------------------------------------------------
   ObjectCreate("klc30321",OBJ_LABEL,0,0,0);
   ObjectSetText("klc30321","Sum Profit               :: ",7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc30321",OBJPROP_CORNER,0);
   ObjectSet("klc30321",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc30321",OBJPROP_YDISTANCE,175);
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
   ObjectCreate("plc30321",OBJ_LABEL,0,0,0);
   ObjectSetText("plc30321",DoubleToStr(_pf(),2),7,"Verdana",_pfc);
   ObjectSet("plc30321",OBJPROP_CORNER,0);
   ObjectSet("plc30321",OBJPROP_XDISTANCE,yy+110);
   ObjectSet("plc30321",OBJPROP_YDISTANCE,175);
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
   ObjectCreate("klc01711",OBJ_LABEL,0,0,0);
   ObjectSetText("klc01711","Sum Swap                :: "+DoubleToStr(_sw(),2),7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc01711",OBJPROP_CORNER,0);
   ObjectSet("klc01711",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc01711",OBJPROP_YDISTANCE,190);
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
   ObjectCreate("klc30121",OBJ_LABEL,0,0,0);
   ObjectSetText("klc30121","Sum Commission    :: "+DoubleToStr(_cm(),2),7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc30121",OBJPROP_CORNER,0);
   ObjectSet("klc30121",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc30121",OBJPROP_YDISTANCE,205);
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
   ObjectCreate("klc201",OBJ_LABEL,0,0,0);
   ObjectSetText("klc201","------------------------------",7,"Verdana",clrWhiteSmoke);
   ObjectSet("klc201",OBJPROP_CORNER,0);
   ObjectSet("klc201",OBJPROP_XDISTANCE,yy);
   ObjectSet("klc201",OBJPROP_YDISTANCE,220);
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
   ObjectCreate("Activated1",OBJ_LABEL,0,0,0);
   ObjectSetText("Activated1","------------------------------",7,"Verdana",clrWhiteSmoke);
   ObjectSet("Activated1",OBJPROP_CORNER,0);
   ObjectSet("Activated1",OBJPROP_XDISTANCE,yy);
   ObjectSet("Activated1",OBJPROP_YDISTANCE,265);
//----------------------------------------------------------------------------------------------

   ObjectCreate(0,"CloseAll",OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,"CloseAll",OBJPROP_CORNER,0);
   ObjectSetInteger(0,"CloseAll",OBJPROP_XDISTANCE,yy);
   ObjectSetInteger(0,"CloseAll",OBJPROP_YDISTANCE,235);
   ObjectSetInteger(0,"CloseAll",OBJPROP_XSIZE,150);
   ObjectSetInteger(0,"CloseAll",OBJPROP_YSIZE,30);
   ObjectSetString(0,"CloseAll",OBJPROP_TEXT," Close All ! ");

   ObjectSetInteger(0,"CloseAll",OBJPROP_COLOR,White);
   ObjectSetInteger(0,"CloseAll",OBJPROP_BGCOLOR,Red);
   ObjectSetInteger(0,"CloseAll",OBJPROP_BORDER_COLOR,Red);

   ObjectSetInteger(0,"CloseAll",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"CloseAll",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"CloseAll",OBJPROP_STATE,false);
   ObjectSetInteger(0,"CloseAll",OBJPROP_FONTSIZE,10);

   ChartRedraw();
   WindowRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="CloseAll")
        {
         Print("Close All!");
         CloseAll(0,magic);
         CloseAll(1,magic);
        }
     }
  }
//+------------------------------------------------------------------+
