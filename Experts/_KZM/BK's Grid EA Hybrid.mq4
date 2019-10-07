//+------------------------------------------------------------------+
//|                                          BK's Grid EA Hybrid.mq4 |
//+------------------------------------------------------------------+
string   version="Hybrid v2009.09.11";

extern   string   EAName="BK\'s Grid EA";

extern   string   _comment0="Trade Settings";
extern   double   BaseLot=0.01;
extern   double   MaxDrawdown=0.01;
extern   double   StopAtDrawdown= true;
extern   bool   EnableAutoBuy   = true;
extern   bool   EnableAutoSell=true;

extern   string   _comment1="0 = Use Default Settings";
extern   int   MaxTotalLot   = 0;
extern   int   MinGridSize   = 8;
extern   int   MaxGridSize   = 10;
extern   double   GridFactor= 1;
extern   int   TakeProfit   = 0;
extern   int   MaxSpread=0;

extern   string   _comment2="Control Settings";
extern   int   Slippage   = 1;
extern   int   Magic      = 98765;

extern   string   _comment3   = "Miscellaneous Settings";
extern   bool   EnableSound   = true;
extern   bool   EnableArrow   = true;
extern   bool   EnableWatchDog= false;
extern   color   BuyColor=C'0x00,0xF8,0x00';
extern   color   SellColor=C'0xF8,0x00,0x00';

int   LotDigits;
string   TextDisplay;
double   UpTrend=0,DownTrend=0;
bool   BuyReady=false,SellReady=false;

bool   _EnableAutoBuy=true;
bool   _EnableAutoSell=true;
double   StopLevel;
//+------------------------------------------------------------------+
//| Email Alert                                                      |
//+------------------------------------------------------------------+
void EmailAlerts()
  {
   return(0);

   static   int Time_AlertLoss = 0;
   static   int Time_AlertLot  = 0;
   string   text="";
   double   TotalVolume=0,TotalProfit=0;

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==Magic)
        {
         TotalVolume   = TotalVolume+OrderLots();
         TotalProfit   = TotalProfit+OrderProfit()+OrderSwap();
        }
     }

   if(TimeLocal()>Time_AlertLot)
     {
      text=text+"\nAccount is currently loaded with "+DoubleToStr(TotalVolume,2)+" lots";
     }
   if(TimeLocal()>Time_AlertLoss && -0.25*AccountBalance()>TotalProfit)
     {
      text=text+"\nAccount is currently under "+MoneyToStr(TotalProfit);
     }

   if(text!="")
     {
      SendMail(EAName,text);
      text="";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WatchDog()
  {
   static   int   timer=0;
   if(IsTradeContextBusy() || GlobalVariableCheck("InTrade"))
     {
        } else if(TimeLocal()>timer) {
      GlobalVariableSet("InTrade",TimeLocal()+300);
      timer=TimeLocal()+5;
      int ticket=0;
      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderComment()=="WatchDog" && OrderType()==OP_BUYLIMIT)
           {
            ticket=OrderTicket();
            if(OrderOpenPrice()!=TimeMinute(TimeCurrent())*Punto(OrderSymbol()))
              {
               OrderModify(ticket,TimeMinute(TimeCurrent())*Punto(OrderSymbol()),0,0,0,CLR_NONE);
               timer=TimeLocal()+30;
              }
           }
        }
      if(ticket==0)
        {
         OrderSend(Symbol(),OP_BUYLIMIT,MarketInfo(Symbol(),MODE_MINLOT),TimeMinute(TimeCurrent())*Punto(OrderSymbol()),0,0,0,"WatchDog",0,0,CLR_NONE);
         timer=TimeLocal()+30;
        }
      GlobalVariableDel("InTrade");
     }
  }
//+------------------------------------------------------------------+
//| Fractional Pip Fixes                                             |
//+------------------------------------------------------------------+
double Punto(string symbol)
  {
   if(StringFind(symbol,"JPY")>=0)
     {
      return(0.01);
        } else {
      return(0.0001);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   SPREAD()
  {
   double _this=(Ask-Bid)/Punto(Symbol());
   return(_this);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   SLIPPAGE()
  {
   int _this=Slippage *(Punto(Symbol())/Point);
   return(_this);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   MAXLOT()
  {
   return(MarketInfo(Symbol(),MODE_MAXLOT));
  }
//+------------------------------------------------------------------+
//| BK's Grid Functions                                              |
//+------------------------------------------------------------------+
double NextStep(double TotalVolume)
  {
   if(GridFactor>0)
     {
      return( MathMin(MaxGridSize, GridFactor*(MaxGridSize-MinGridSize)*(1+TotalVolume/BaseLot)) );
        } else if(TotalVolume>0) {
      return(MaxGridSize);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NextLot(double PriceDistance,double TotalVolume)
  {
   double _this=TotalVolume*(PriceDistance-MinGridSize)/MinGridSize;
   if(GridFactor>0)
     {
      return(MathMax(_this, BaseLot));
        } else {
      return(_this);
     }
  }
//+------------------------------------------------------------------+
//| BK's Special Library                                             |
//+------------------------------------------------------------------+
string MoneyToStr(double x)
  {
   string sign="";
   if(x<0) { sign="-"; }
   return( sign + "$" + DoubleToStr(MathAbs(x),2) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SWITCH(bool value)
  {
   if(value) return("(ON)");
   return("(OFF)");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CheckReport()
  {
   static string   ProfitReport="";
   static int   TimeToReport = 0;
   static int   TradeCounter = 0;
#define Daily      0
#define Weekly      1
#define   Monthly      2
#define   All      3

   if(TradeCounter!=HistoryTotal())
     {
      TradeCounter = HistoryTotal();
      TimeToReport = 0;
     }

   if(TimeLocal()>TimeToReport)
     {
      TimeToReport=TimeLocal()+300;
      double   Profit[10],Lots[10],Count[10];
      ArrayInitialize(Profit,0);
      ArrayInitialize(Lots,0.000001);
      ArrayInitialize(Count,0.000001);

      int Today     = TimeCurrent() - (TimeCurrent() % 86400);
      int ThisWeek  = Today - TimeDayOfWeek(Today)*86400;
      int ThisMonth = TimeMonth(TimeCurrent());
      for(int i=0; i<HistoryTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderCloseTime()>0)
           {
            Count[All]+=1;
            Profit[All]+=OrderProfit()+OrderSwap();
            Lots[All]+=OrderLots();
            if(OrderCloseTime()>=Today)
              {
               Count[Daily]+=1;
               Profit[Daily]+=OrderProfit()+OrderSwap();
               Lots[Daily]+=OrderLots();
              }
            if(OrderCloseTime()>=ThisWeek)
              {
               Count[Weekly]+=1;
               Profit[Weekly]+=OrderProfit()+OrderSwap();
               Lots[Weekly]+=OrderLots();
              }
            if(TimeMonth(OrderCloseTime())==ThisMonth)
              {
               Count[Monthly]+=1;
               Profit[Monthly]+=OrderProfit()+OrderSwap();
               Lots[Monthly]+=OrderLots();
              }
           }
        }
      ProfitReport="\n\nPROFIT REPORT"+
                   "\nToday: $"+DoubleToStr(Profit[Daily],2)+
                   "\nThis Week: $"+DoubleToStr(Profit[Weekly],2)+
                   "\nThis Month: $"+DoubleToStr(Profit[Monthly],2)+
                   "\nAll Profits: $"+DoubleToStr(Profit[All],2)+
                   "\nAll Trades: "+DoubleToStr(Count[All],0)+"  (Average $"+DoubleToStr(Profit[All]/Count[All],2)+" per trade)"+
                   "\nAll Lots: "+DoubleToStr(Lots[All],2)+"  (Average $"+DoubleToStr(Profit[All]/Lots[All],2)+" per lot)";
     }
   return (ProfitReport);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string ObjName,int T1,double P1,int T2,double P2,color ObjColor,int width)
  {
   ObjectDelete(ObjName);
   ObjectCreate(ObjName,OBJ_TREND,0,T1,P1,T2,P2);
   ObjectSet(ObjName,OBJPROP_COLOR,ObjColor);
   ObjectSet(ObjName,OBJPROP_WIDTH,width);
   ObjectSet(ObjName,OBJPROP_RAY,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBox(string ObjName,datetime T1,datetime T2,double P1,double P2,color ObjColor)
  {
   ObjectCreate(ObjName,OBJ_RECTANGLE,0,0,0,0,0);
   ObjectSet(ObjName,OBJPROP_TIME1,T1);
   ObjectSet(ObjName,OBJPROP_TIME2,T2);
   ObjectSet(ObjName,OBJPROP_PRICE1,P1);
   ObjectSet(ObjName,OBJPROP_PRICE2,P2);
   ObjectSet(ObjName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(ObjName,OBJPROP_COLOR,ObjColor);
   ObjectSet(ObjName,OBJPROP_BACK,1);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   ObjectDelete("BuyBox");
   ObjectDelete("BuyAverage");
   ObjectDelete("BuyTP");
   ObjectDelete("SellBox");
   ObjectDelete("SellAverage");
   ObjectDelete("SellTP");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Comment("");
   if(Magic==0) {Magic=AccountNumber();}

   if(MaxTotalLot==0)
     {
      MaxTotalLot=(50*AccountBalance())/(10000*MarketInfo(Symbol(),MODE_TICKVALUE));
     }
   if(MinGridSize==0 || MaxGridSize==0)
     {
      if(StringFind(Symbol(),"EURUSD")>=0)
        {
         MinGridSize   =  40;
         MaxGridSize   =  50;
           } else if(StringFind(Symbol(),"USDJPY")>=0) {
         MinGridSize   =  40;
         MaxGridSize   =  50;
           } else if(StringFind(Symbol(),"GBPUSD")>=0) {
         MinGridSize   =  50;
         MaxGridSize   =  70;
           } else if(StringFind(Symbol(),"EURJPY")>=0) {
         MinGridSize   =  50;
         MaxGridSize   =  70;
           } else if(StringFind(Symbol(),"GBPJPY")>=0) {
         MinGridSize   =  60;
         MaxGridSize   =  80;
           } else {
         EnableAutoBuy=false;
         EnableAutoSell=false;
        }
     }
   if(TakeProfit==0)
     {
      if(StringFind(Symbol(),"EURUSD")>=0)
        {
         TakeProfit=10;
           } else if(StringFind(Symbol(),"USDJPY")>=0) {
         TakeProfit=10;
           } else if(StringFind(Symbol(),"GBPUSD")>=0) {
         TakeProfit=15;
           } else if(StringFind(Symbol(),"EURJPY")>=0) {
         TakeProfit=15;
           } else if(StringFind(Symbol(),"GBPJPY")>=0) {
         TakeProfit=20;
           } else {
         TakeProfit=10;
        }
     }
   if(MaxSpread==0)
     {
      if(StringFind(Symbol(),"EURUSD")>=0)
        {
         MaxSpread=5;
           } else if(StringFind(Symbol(),"USDJPY")>=0) {
         MaxSpread=5;
           } else if(StringFind(Symbol(),"GBPUSD")>=0) {
         MaxSpread=8;
           } else if(StringFind(Symbol(),"EURJPY")>=0) {
         MaxSpread=8;
           } else if(StringFind(Symbol(),"GBPJPY")>=0) {
         MaxSpread=12;
           } else {
         MaxSpread=5;
        }
     }
//	if (EntryLevel==0) {
//		EntryLevel = TakeProfit + MaxGridSize + 2*(MaxGridSize-MinGridSize);
//	}

   if(MarketInfo(Symbol(),MODE_LOTSTEP)== 0.001) {LotDigits = 3;} else
   if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01) {LotDigits = 2;} else
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1) {LotDigits=1;} else {LotDigits=0;}
   BaseLot=NormalizeDouble(MathMax(BaseLot,MarketInfo(Symbol(),MODE_MINLOT)),LotDigits);

   return(0);
  }
//+------------------------------------------------------------------+
//| ManageBuy                                                        |
//+------------------------------------------------------------------+
int ManageBuy()
  {
   int   count=0;
   double   AveragePrice=Ask;
   double   TotalVolume   = 0;
   double   TotalProfit   = 0;
   double   ThisVolume=0;
   double   TP      = Ask;
   double   SL      = 0;
   int   FirstOrder=TimeCurrent();

   RefreshRates();
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==OP_BUY)
        {
         //Count the Average Price - will be used to set TP later
         if(OrderStopLoss()>0 && OrderStopLoss()>=Bid)
           {
            _EnableAutoBuy=false;
           }
         AveragePrice=(AveragePrice*TotalVolume+OrderOpenPrice()*OrderLots())/(TotalVolume+OrderLots());
         TP      = (TP*TotalVolume + OrderTakeProfit()*OrderLots()) / (TotalVolume+OrderLots());
         SL      = (SL*TotalVolume + OrderStopLoss()*OrderLots()) / (TotalVolume+OrderLots());
         TotalVolume   = TotalVolume+OrderLots();
         TotalProfit   = TotalProfit+OrderProfit();
         if(EnableArrow) DrawLine("BUY_"+count,OrderOpenTime(),OrderOpenPrice(),OrderOpenTime(),OrderOpenPrice(),BuyColor,3);
         FirstOrder=MathMin(FirstOrder,OrderOpenTime());
         count++;
        }
     }

   TextDisplay=TextDisplay+"\nB"+SWITCH(_EnableAutoBuy)+": "+count+"   V: "+DoubleToStr(TotalVolume,LotDigits)+"/"+DoubleToStr(MaxTotalLot,LotDigits)+"   @ "+DoubleToStr(AveragePrice,Digits)+"   TP: "+DoubleToStr(TP,Digits)+"   SL: "+DoubleToStr(SL,Digits)+"   G:"+DoubleToStr((Ask-AveragePrice)/Punto(Symbol()),1)+"/"+DoubleToStr(NextStep(TotalVolume),1)+"   ("+MoneyToStr(TotalProfit)+"/"+MoneyToStr(TotalVolume*(TP-AveragePrice)*MarketInfo(Symbol(),MODE_TICKVALUE)/Point)+")";
   DrawBox("BuyBox",FirstOrder-Period()*120,TimeCurrent()+Period()*120,AveragePrice,TP,BuyColor>>3);
   DrawLine("BuyAverage",FirstOrder-Period()*120,AveragePrice,TimeCurrent()+Period()*120,AveragePrice,BuyColor,1);
   DrawLine("BuyTP",FirstOrder-Period()*120,TP,TimeCurrent()+Period()*120,TP,BuyColor,10*TotalVolume/MaxTotalLot);

   RefreshRates();
   if(MaxSpread>SPREAD() && TotalVolume<MaxTotalLot)
     {   //a MaxTotalLot = 0 means dont start
      double PriceDistance=(AveragePrice-Ask)/Punto(Symbol());   //normalize distance in pip value
      if(TotalVolume==0 && _EnableAutoBuy)
        {
         ThisVolume=BaseLot;
           } else if(TotalVolume>0) {
         if(PriceDistance>=NextStep(TotalVolume))
           {
            ThisVolume=NextLot(PriceDistance,TotalVolume);
           }
        }
      ThisVolume=NormalizeDouble(ThisVolume,LotDigits);
      if(ThisVolume>0 && MaxDrawdown>0)
        {
         //			Print("We have a BUY: ",ThisVolume,"lots, but we need to check further");
         double AvgPrice=(AveragePrice*TotalVolume+Ask*ThisVolume)/(TotalVolume+ThisVolume);
         SL   = MathMin( 1000, MaxDrawdown*AccountBalance()/((TotalVolume+ThisVolume)*MarketInfo(Symbol(),MODE_TICKVALUE)) );
         SL   = MathMax(0, NormalizeDouble( AvgPrice - SL*Punto(Symbol()), Digits));
         //Additional Volume should bring the StopLoss higher and maybe too near the current price
         if(SL>=Bid-StopLevel)
           {   //New StopLoss would be too high and will get stopped out immediately
            ThisVolume=0;   //therefore, do not add
           }
         //			Print("After checking we ended with ",ThisVolume,"lots because AvgPrice would be:",AvgPrice, " SL:",SL," Highest Allowed SL:",Bid - StopLevel);
        }
     }

   RefreshRates();
   if(IsTradeContextBusy() || GlobalVariableCheck("InTrade"))
     {
      //Trades are not allowed while this Global Variable is in place
        } else if(ThisVolume>0) {
      GlobalVariableSet("InTrade",TimeLocal());      // set lock indicator
      i=3;                     // Try placing a BUY 10 times
      while(ThisVolume>0 && i>0)
        {
         double ThisLot=MathMin(ThisVolume,MAXLOT());
         RefreshRates();
         Print("Sending request to Buy ",DoubleToStr(ThisLot,2),"lots @",DoubleToStr(Ask,Digits));
         int Ticket=OrderSend(Symbol(),OP_BUY,ThisLot,Ask,SLIPPAGE(),0,0,EAName,Magic,0,CLR_NONE);
         if(Ticket>0)
           {
            ThisVolume=ThisVolume-ThisLot;
            if(EnableSound) { PlaySound("expert.wav"); }
              } else {            // ERROR!
            i--;
           }
        }
      GlobalVariableDel("InTrade");
        } else if(TotalVolume>0) {
      TP=NormalizeDouble(AveragePrice+TakeProfit*Punto(Symbol()),Digits);
      if(MaxDrawdown>0)
        {
         SL   = MathMin( 1000, MaxDrawdown*AccountBalance()/(TotalVolume*MarketInfo(Symbol(),MODE_TICKVALUE)) );
         SL   = NormalizeDouble( AveragePrice - SL*Punto(Symbol()), Digits);
           } else {SL=0;
        }
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==OP_BUY)
           {
            double _SL=SL;
            if(_SL>0 && _SL>=Bid-StopLevel)
              {
               _SL=OrderStopLoss();
              }
            if(Bid>TP)
              {
               GlobalVariableSet("InTrade",TimeLocal());   // set lock indicator
               Print("Sending request to CLOSE BUY ",OrderTicket());
               if(OrderClose(OrderTicket(),OrderLots(),Bid,SLIPPAGE(),CLR_NONE)>0 && EnableSound) {PlaySound("tick.wav");}
               GlobalVariableDel("InTrade");
                 } else if(OrderTakeProfit()!=TP || OrderStopLoss()!=_SL) {
               GlobalVariableSet("InTrade",TimeLocal());   // set lock indicator
               Print("Sending request to Modify BUY ",OrderTicket()," SL to ",DoubleToStr(_SL,Digits)," TP to ",DoubleToStr(TP,Digits));
               if(OrderModify(OrderTicket(),OrderOpenPrice(),_SL,TP,0,CLR_NONE)>0 && EnableSound) {PlaySound("tick.wav");}
               GlobalVariableDel("InTrade");
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| ManageSell                                                       |
//+------------------------------------------------------------------+
int ManageSell()
  {
   int   count=0;
   double   AveragePrice=Bid;
   double   TotalVolume   = 0;
   double   TotalProfit   = 0;
   double   ThisVolume=0;
   double   TP      = Bid;
   double   SL      = 0;
   int   FirstOrder=TimeCurrent();

   RefreshRates();
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==OP_SELL)
        {
         //Count the Average Price - will be used to set TP later
         if(OrderStopLoss()>0 && OrderStopLoss()<=Ask)
           {
            _EnableAutoSell=false;
           }
         AveragePrice=(AveragePrice*TotalVolume+OrderOpenPrice()*OrderLots())/(TotalVolume+OrderLots());
         TP      = (TP*TotalVolume + OrderTakeProfit()*OrderLots()) / (TotalVolume+OrderLots());
         SL      = (SL*TotalVolume + OrderStopLoss()*OrderLots()) / (TotalVolume+OrderLots());
         TotalVolume   = TotalVolume+OrderLots();
         TotalProfit   = TotalProfit+OrderProfit();
         if(EnableArrow) DrawLine("SELL_"+count,OrderOpenTime(),OrderOpenPrice(),OrderOpenTime(),OrderOpenPrice(),SellColor,3);
         FirstOrder=MathMin(FirstOrder,OrderOpenTime());
         count++;
        }
     }

   TextDisplay=TextDisplay+"\nS"+SWITCH(_EnableAutoSell)+": "+count+"   V: "+DoubleToStr(TotalVolume,LotDigits)+"/"+DoubleToStr(MaxTotalLot,LotDigits)+"   @ "+DoubleToStr(AveragePrice,Digits)+"   TP: "+DoubleToStr(TP,Digits)+"   SL: "+DoubleToStr(SL,Digits)+"   G:"+DoubleToStr((AveragePrice-Bid)/Punto(Symbol()),1)+"/"+DoubleToStr(NextStep(TotalVolume),1)+"   ("+MoneyToStr(TotalProfit)+"/"+MoneyToStr(TotalVolume*(AveragePrice-TP)*MarketInfo(Symbol(),MODE_TICKVALUE)/Point)+")";
   DrawBox("SellBox",FirstOrder-Period()*120,TimeCurrent()+Period()*120,AveragePrice,TP,SellColor>>3);
   DrawLine("SellAverage",FirstOrder-Period()*120,AveragePrice,TimeCurrent()+Period()*120,AveragePrice,SellColor,1);
   DrawLine("SellTP",FirstOrder-Period()*120,TP,TimeCurrent()+Period()*120,TP,SellColor,10*TotalVolume/MaxTotalLot);

   RefreshRates();
   if(MaxSpread>SPREAD() && TotalVolume<MaxTotalLot)
     {   //a MaxTotalLot = 0 means dont start
      double PriceDistance=(Bid-AveragePrice)/Punto(Symbol());   //normalize distance in pip value
      if(TotalVolume==0 && _EnableAutoBuy)
        {
         ThisVolume=BaseLot;
           } else if(TotalVolume>0) {
         if(PriceDistance>=NextStep(TotalVolume))
           {
            ThisVolume=NextLot(PriceDistance,TotalVolume);
           }
        }
      ThisVolume=NormalizeDouble(ThisVolume,LotDigits);
      if(ThisVolume>0 && MaxDrawdown>0)
        {
         double AvgPrice=(AveragePrice*TotalVolume+Bid*ThisVolume)/(TotalVolume+ThisVolume);
         SL   = MathMin( 1000, MaxDrawdown*AccountBalance()/((TotalVolume+ThisVolume)*MarketInfo(Symbol(),MODE_TICKVALUE)) );
         SL   = NormalizeDouble( AvgPrice + SL*Punto(Symbol()), Digits);
         //Additional Volume should bring the StopLoss lower and maybe too near the current price
         if(SL<Ask+StopLevel)
           {   //New StopLoss would be too low and will get stopped out immediately
            ThisVolume=0;   //therefore, do not add
           }
        }
     }

   RefreshRates();
   if(IsTradeContextBusy() || GlobalVariableCheck("InTrade"))
     {
      //Trades are not allowed while this Global Variable is in place
        } else if(ThisVolume>0) {
      GlobalVariableSet("InTrade",TimeLocal());      // set lock indicator
      i=3;                     // Try placing a SELL 10 times
      while(ThisVolume>0 && i>0)
        {
         double ThisLot=MathMin(ThisVolume,MAXLOT());
         RefreshRates();
         Print("Sending request to Sell ",DoubleToStr(ThisLot,2),"lots @",DoubleToStr(Bid,Digits));
         int Ticket=OrderSend(Symbol(),OP_SELL,ThisLot,Bid,SLIPPAGE(),0,0,EAName,Magic,0,CLR_NONE);
         if(Ticket>0)
           {
            ThisVolume=ThisVolume-ThisLot;
            if(EnableSound) { PlaySound("expert.wav"); }
              } else {
            i--;
           }
        }
      GlobalVariableDel("InTrade");
        } else if(TotalVolume>0) {
      TP=NormalizeDouble(AveragePrice-TakeProfit*Punto(Symbol()),Digits);
      if(MaxDrawdown>0)
        {
         SL   = MathMin( 1000, MaxDrawdown*AccountBalance()/(TotalVolume*MarketInfo(Symbol(),MODE_TICKVALUE)) );
         SL   = NormalizeDouble( AveragePrice + SL*Punto(Symbol()), Digits);
           } else {SL=0;
        }
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==OP_SELL)
           {
            double _SL=SL;
            if(_SL>0 && _SL<=Ask+StopLevel)
              {
               _SL=OrderStopLoss();
              }
            if(Ask<TP)
              {
               GlobalVariableSet("InTrade",TimeLocal());   // set lock indicator
               Print("Sending request to CLOSE SELL ",OrderTicket());
               if(OrderClose(OrderTicket(),OrderLots(),Ask,SLIPPAGE(),CLR_NONE)>0 && EnableSound) {PlaySound("tick.wav");}
               GlobalVariableDel("InTrade");
                 } else if(OrderTakeProfit()!=TP || OrderStopLoss()!=SL) {
               GlobalVariableSet("InTrade",TimeLocal());   // set lock indicator
               Print("Sending request to Modify SELL ",OrderTicket()," SL to ",DoubleToStr(_SL,Digits)," TP to ",DoubleToStr(TP,Digits));
               if(OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,CLR_NONE)>0 && EnableSound) {PlaySound("tick.wav");}
               GlobalVariableDel("InTrade");
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
/*while(IsExpertEnabled()) 
     {*/
   if(GlobalVariableCheck("InTrade") && TimeLocal()>GlobalVariableGet("InTrade"))
     {
      GlobalVariableDel("InTrade");
     }
   for(int i=0; i<ObjectsTotal();i++)
     {
      ObjectDelete("BUY_"+i);
      ObjectDelete("SELL_"+i);
     }

   StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)*Punto(Symbol());
   TextDisplay=EAName+" ("+version+")"+
               "\nServer"+"   Time:"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"   Spread:"+DoubleToStr(SPREAD(),1)+"   WatchDog:"+SWITCH(EnableWatchDog)+
               "\nMagic: "+Magic+"   BaseLot:"+DoubleToStr(BaseLot,LotDigits)+"   Grid:"+MinGridSize+"/"+MaxGridSize+" (Model:"+DoubleToStr(GridFactor,2)+")   TakeProfit:"+TakeProfit+"   MaxSpread:"+MaxSpread;

   if(MaxDrawdown>0)
     {
      TextDisplay=TextDisplay+"   MaxDrawdown:"+DoubleToStr(MaxDrawdown*100,2)+"% ("+MoneyToStr(MaxDrawdown*AccountBalance())+")";
        } else {
      TextDisplay=TextDisplay+"   MaxDrawdown:(OFF)";
     }

//		TrendStrength(MaxGridSize);
//		TextDisplay = TextDisplay + "\nEntryLevel:" + EntryLevel + "   UpTrend:"+SWITCH(SellReady)+" "+DoubleToStr(UpTrend,1) + "   DownTrend:"+SWITCH(BuyReady)+" "+DoubleToStr(DownTrend,1);
   ManageBuy();
   ManageSell();
   TextDisplay=TextDisplay+CheckReport();
   Comment(TextDisplay);
   if(EnableWatchDog) { WatchDog(); }
   EmailAlerts();
   Sleep(100);
// }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
