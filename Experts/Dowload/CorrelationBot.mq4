//+------------------------------------------------------------------+
#define SIGNAL_NONE 0
#define SIGNAL_BUY   1
#define SIGNAL_SELL  2
#define SIGNAL_CLOSEBUY 3
#define SIGNAL_CLOSESELL 4

#property copyright "Big Pippin"

extern string Remark1="== Main Settings ==";
extern int MagicNumber=0;
extern bool SignalsOnly=False;
extern bool Alerts=False;
extern bool SignalMail = False;
extern bool PlaySounds = False;
extern bool EachTickMode=True;
extern bool CloseOnOppositeSignal=True;
extern double Lots=0.01;
extern bool MoneyManagement=False;
extern int Risk=20;
extern int Slippage=5;
extern  bool UseStopLoss=True;
extern int StopLoss=150;
extern bool UseTakeProfit=True;
extern int TakeProfit=60;
extern bool UseTrailingStop=False;
extern int TrailingStop=30;
extern bool MoveStopOnce=False;
extern int MoveStopWhenPrice=50;
extern int MoveStopTo = 1;
extern string Remark2 = "";
extern string Remark3 = "== MA Fast Settings ==";
extern int MA1Period= 15;
extern int MA1Shift = 0;
extern int MA1Method= 0;
extern int MA1Price = 0;
extern string Remark4 = "";
extern string Remark5 = "== MA Slow Settings ==";
extern int MA2Period=30;
extern int MA2Shift = 0;
extern int MA2Method= 0;
extern int MA2Price = 0;
extern double Use_ATR_Pct= 1;
extern bool Use_ATR_Stop = true;

//Version 2.01

int BarCount;
int Current;
bool TickCheck=False;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   EventSetMillisecondTimer(500);

   BarCount=Bars;

   if(EachTickMode) //True
      Current=0;
   else
      Current=1;

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getATR()
  {
   return iATR(NULL,0,24,1)*Use_ATR_Pct;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getATRBuy_TP(double price)
  {
   return NormalizeDouble(price+getATR(),Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getATRBuy_SL(double price)
  {
   return NormalizeDouble(price-(3*(getATR())),Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getATRSell_TP(double price)
  {
   return NormalizeDouble(price-getATR(),Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getATRSell_SL(double price)
  {
   return NormalizeDouble(price+(3*(getATR())),Digits);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void OnTick()

  {
   int Order=SIGNAL_NONE;
   int Total,Ticket;
   double StopLossLevel,TakeProfitLevel;

   if(EachTickMode && Bars!=BarCount)
      TickCheck=False;
   Total = OrdersTotal();
   Order = SIGNAL_NONE;

//Money Management sequence
   if(MoneyManagement)//False
     {
      if(Risk<1 || Risk>100)
        {
         Comment("Invalid Risk Value.");
        }
      else
        {
         Lots=MathFloor((AccountFreeMargin()*AccountLeverage()*Risk*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);
        }
     }

//+------------------------------------------------------------------+
//| Variable Begin                                                   |
//+------------------------------------------------------------------+
//                                       15        0           0          0         0
   double EURUSD_MA1_A = iMA("EURUSD", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);//0
   double EURUSD_MA1_B = iMA("EURUSD", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);//1
                                                                                                 //                                       30        0           0           0
   double EURUSD_MA2_A = iMA("EURUSD", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
   double EURUSD_MA2_B = iMA("EURUSD", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);
//--------------------------
   double USDCHF_MA1A = iMA("USDCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);
   double USDCHF_MA1B = iMA("USDCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);
   double USDCHF_MA2A = iMA("USDCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
   double USDCHF_MA2B = iMA("USDCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);
//--------------------------
   double EURCHF_MA1A = iMA("EURCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);
   double EURCHF_MA1B = iMA("EURCHF", 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);

   double EURCHF_MA2A = iMA("EURCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
   double EURCHF_MA2B = iMA("EURCHF", 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);
//--------------------------

//double MA_1A = iMA(NULL, 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 0);
//double MA_1B = iMA(NULL, 0, MA1Period, MA1Shift, MA1Method, MA1Price, Current + 1);

//double MA_2A = iMA(NULL, 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 0);
//double MA_2B = iMA(NULL, 0, MA2Period, MA2Shift, MA2Method, MA2Price, Current + 1);




//+------------------------------------------------------------------+
//| Variable End                                                     |
//+------------------------------------------------------------------+

//Check position
   bool IsTrade=False;

   for(int i=0; i<Total; i++)
     {
      bool sel=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         IsTrade=True;
         if(OrderType()==OP_BUY)
           {
            //Close
            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Buy)                                           |
            //+------------------------------------------------------------------+

            if(CloseOnOppositeSignal && 
               EURUSD_MA1_A<EURUSD_MA2_A && EURUSD_MA1_B>=EURUSD_MA2_B && 
               EURCHF_MA1A<EURCHF_MA2A && EURCHF_MA1B>=EURCHF_MA2B &&
               USDCHF_MA1A>USDCHF_MA2A && USDCHF_MA1B<=USDCHF_MA2B)
               Order=SIGNAL_CLOSEBUY;

            //+------------------------------------------------------------------+
            //| Signal End(Exit Buy)                                             |
            //+------------------------------------------------------------------+

            if(Order==SIGNAL_CLOSEBUY && 
               ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars!=BarCount))))
              {
               bool cl=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,MediumSeaGreen);
               if(SignalMail) SendMail("[Signal Alert]","["+Symbol()+"] "+DoubleToStr(Bid,Digits)+" Close Buy");
               if(!EachTickMode) BarCount=Bars;
               IsTrade=False;
               continue;
              }
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice>0)
              {
               if(Bid-OrderOpenPrice()>=Point*MoveStopWhenPrice)
                 {
                  if(OrderStopLoss()<OrderOpenPrice()+Point*MoveStopTo)
                    {
                     bool mo=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Point*MoveStopTo,OrderTakeProfit(),0,Red);
                     if(!EachTickMode) BarCount=Bars;
                     continue;
                    }
                 }
              }
            //Trailing stop
            if(UseTrailingStop && TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     mo=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,MediumSeaGreen);
                     if(!EachTickMode) BarCount=Bars;
                     continue;
                    }
                 }
              }
           }
         else
           {
            //Close
            //+------------------------------------------------------------------+
            //| Signal Begin(Exit Sell)                                          |
            //+------------------------------------------------------------------+

            if(CloseOnOppositeSignal && 
               EURUSD_MA1_A>EURUSD_MA2_A && EURUSD_MA1_B<=EURUSD_MA2_B && 
               EURCHF_MA1A>EURCHF_MA2A && EURCHF_MA1B<=EURCHF_MA2B &&
               USDCHF_MA1A<USDCHF_MA2A && USDCHF_MA1B>=USDCHF_MA2B)
               Order=SIGNAL_CLOSESELL;

            //+------------------------------------------------------------------+
            //| Signal End(Exit Sell)                                            |
            //+------------------------------------------------------------------+

            if(Order==SIGNAL_CLOSESELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars!=BarCount))))
              {
               cl=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,DarkOrange);
               if(SignalMail) SendMail("[Signal Alert]","["+Symbol()+"] "+DoubleToStr(Ask,Digits)+" Close Sell");
               if(!EachTickMode) BarCount=Bars;
               IsTrade=False;
               continue;
              }
            //MoveOnce
            if(MoveStopOnce && MoveStopWhenPrice>0)
              {
               if(OrderOpenPrice()-Ask>=Point*MoveStopWhenPrice)
                 {
                  if(OrderStopLoss()>OrderOpenPrice()-Point*MoveStopTo)
                    {
                     mo=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Point*MoveStopTo,OrderTakeProfit(),0,Red);
                     if(!EachTickMode) BarCount=Bars;
                     continue;
                    }
                 }
              }
            //Trailing stop
            if(UseTrailingStop && TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     mo=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,DarkOrange);
                     if(!EachTickMode) BarCount=Bars;
                     continue;
                    }
                 }
              }
           }
        }
     }

//+------------------------------------------------------------------+
//| Signal Begin(Entry)                                              |
//+------------------------------------------------------------------+

// BUY MA1A > MA2A && MA1B <= MA2B
   if(EURUSD_MA1_A>EURUSD_MA2_A && EURUSD_MA1_B<=EURUSD_MA2_B &&  //CutUP
      EURCHF_MA1A>EURCHF_MA2A && EURCHF_MA1B<=EURCHF_MA2B &&      //CutUP
      USDCHF_MA1A<USDCHF_MA2A && USDCHF_MA1B>=USDCHF_MA2B)        //CutDW
      Order=SIGNAL_BUY;

// SELL MA1A < MA2A && MA1B >= MA2B
   if(EURUSD_MA1_A<EURUSD_MA2_A && EURUSD_MA1_B>=EURUSD_MA2_B &&  //CutDW
      EURCHF_MA1A<EURCHF_MA2A && EURCHF_MA1B>=EURCHF_MA2B &&      //CutDW
      USDCHF_MA1A>USDCHF_MA2A && USDCHF_MA1B<=USDCHF_MA2B)        //CutUP
      Order=SIGNAL_SELL;

//+------------------------------------------------------------------+
//| Signal End                                                       |
//+------------------------------------------------------------------+
   string CMM="";
/*CMM+=DoubleToStr(EURUSD_MA1_A,Digits)+" | "+DoubleToStr(EURUSD_MA2_A,Digits)+"\n";
   CMM+=BoolToStr(EURUSD_MA1_A>EURUSD_MA2_A)+" | "+BoolToStr(EURUSD_MA1_B<=EURUSD_MA2_B)+"\n";
   CMM+=BoolToStr(EURCHF_MA1A>EURCHF_MA2A )+" | "+BoolToStr(EURCHF_MA1B<=EURCHF_MA2B)+"\n";
   CMM+=BoolToStr(USDCHF_MA1A<USDCHF_MA2A)+" | "+BoolToStr(USDCHF_MA1B>=USDCHF_MA2B)+"\n";
   CMM+=BoolToStr(Order)+"\n";*/

   CMM+=DoubleToStr(getATR(),Digits)+"\n";
   CMM+="SIGNAL "+SgnalToStr(Order)+"\n";
   CMM+="!IsTrade "+BoolToStr(!IsTrade)+" | !SignalsOnly "+BoolToStr(!SignalsOnly)+"\n";
   CMM+="EachTickMode && !TickCheck "+BoolToStr(EachTickMode && !TickCheck)+" | !EachTickMode && (Bars!=BarCount) "+BoolToStr(!EachTickMode && (Bars!=BarCount))+"\n";

   Comment(CMM);
//Buy                          True                        
   if(Order==SIGNAL_BUY && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars!=BarCount))))
     {
      Print(string(__LINE__));
      if(SignalsOnly)
        {
         if(SignalMail) SendMail("[Signal Alert]","["+Symbol()+"] "+DoubleToStr(Ask,Digits)+"Buy Signal");
         if(Alerts) Alert("["+Symbol()+"] "+DoubleToStr(Ask,Digits)+"Buy Signal");
         if(PlaySounds) PlaySound("alert.wav");

        }

      if(!IsTrade && !SignalsOnly)
        {

         //Check free margin
         if(AccountFreeMargin()<(1000*Lots))
           {
            Print("We have no money. Free Margin = ",AccountFreeMargin());
           }

         if(UseStopLoss)
            StopLossLevel=getATRBuy_SL(Ask);  //= Ask - StopLoss * Point; else StopLossLevel = 0.0;
         if(UseTakeProfit)
            TakeProfitLevel=getATRBuy_TP(Bid);  //= Ask + TakeProfit * Point; else TakeProfitLevel = 0.0;

         Print(string(__LINE__));
         Ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,"Buy(#"+MagicNumber+")",MagicNumber,0,DodgerBlue);
         if(Ticket>0)
           {
            if(OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES))
              {
               Print("BUY order opened : ",OrderOpenPrice());
               if(SignalMail) SendMail("[Signal Alert]","["+Symbol()+"] "+DoubleToStr(Ask,Digits)+"Buy Signal");
               if(Alerts) Alert("["+Symbol()+"] "+DoubleToStr(Ask,Digits)+"Buy Signal");
               if(PlaySounds) PlaySound("alert.wav");
              }
            else
              {
               Print("Error opening BUY order : ",GetLastError());
              }
           }
         if(EachTickMode) TickCheck = True;
         if(!EachTickMode) BarCount = Bars;
        }
     }

//Sell
   if(Order==SIGNAL_SELL && ((EachTickMode && !TickCheck) || (!EachTickMode && (Bars!=BarCount))))
     {
      if(SignalsOnly)
        {
         if(SignalMail) SendMail("[Signal Alert]","["+Symbol()+"] "+DoubleToStr(Bid,Digits)+"Sell Signal");
         if(Alerts) Alert("["+Symbol()+"] "+DoubleToStr(Bid,Digits)+"Sell Signal");
         if(PlaySounds) PlaySound("alert.wav");
        }
      if(!IsTrade && !SignalsOnly)
        {
         //Check free margin
         if(AccountFreeMargin()<(1000*Lots))
           {
            Print("We have no money. Free Margin = ",AccountFreeMargin());
           }

         if(UseStopLoss) StopLossLevel=getATRSell_SL(Ask); //StopLoss * Point; else StopLossLevel = 0.0;
         if(UseTakeProfit) TakeProfitLevel=getATRSell_TP(Bid);//Bid - TakeProfit * Point; else TakeProfitLevel = 0.0;

         Ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopLossLevel,TakeProfitLevel,"Sell(#"+MagicNumber+")",MagicNumber,0,DeepPink);
         if(Ticket>0)
           {
            if(OrderSelect(Ticket,SELECT_BY_TICKET,MODE_TRADES))
              {
               Print("SELL order opened : ",OrderOpenPrice());
               if(SignalMail) SendMail("[Signal Alert]","["+Symbol()+"] "+DoubleToStr(Bid,Digits)+"Sell Signal");
               if(Alerts) Alert("["+Symbol()+"] "+DoubleToStr(Bid,Digits)+"Sell Signal");
               if(PlaySounds) PlaySound("alert.wav");
                 } else {
               Print("Error opening SELL order : ",GetLastError());
              }
           }
         if(EachTickMode) TickCheck = True;
         if(!EachTickMode) BarCount = Bars;
        }
     }

   if(!EachTickMode)
      BarCount=Bars;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BoolToStr(bool b)
  {
   return (b)?"True":"False";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SgnalToStr(int v)
  {
   if(v==SIGNAL_NONE)         return   "SIGNAL_NONE";
   if(v==SIGNAL_BUY)          return   "SIGNAL_BUY";
   if(v==SIGNAL_SELL)         return   "SIGNAL_SELL";
   if(v==SIGNAL_CLOSEBUY)     return   "SIGNAL_CLOSEBUY";
   if(v==SIGNAL_CLOSESELL)    return   "SIGNAL_CLOSESELL";
   return "SIGNAL_-"+string(v);
  }
//+------------------------------------------------------------------+
