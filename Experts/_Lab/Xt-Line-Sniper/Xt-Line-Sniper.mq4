//+------------------------------------------------------------------+
//|                                               Xt-Line-Sniper.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "https://www.facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum MODE_DEVLOP
  {
   MODE_DEVLOP_0=0,
   MODE_DEVLOP_1=1,
   MODE_DEVLOP_2=2,
  };
MODE_DEVLOP _MODE_DEVLOP=MODE_DEVLOP_0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   OnTick();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   int BarStart=1;
   int BarCount=4;
   BarStart++;
//---
   CMM="";
   int Mode_=0;
   int Period_=20;
   double Deviation_=0;

   string SignalBuffer="";
   string SignalBufferN="";

   for(int i=0;i<BarCount;i++)
     {
      //SignalBuffer+=DirectionsToStr(DirectionsFind(true,Mode_,Period_,Deviation_,BarStart+i));
     }
   CMM+="\n"+SignalBuffer;
   CMM+="\n----\n";
   SignalBuffer="";
   SignalBufferN="";
   for(int i=BarStart+BarCount-1;i>=BarStart;i--)
     {
      SignalBufferN+=string(i)+",";
      //Print(i);
      SignalBuffer+=DirectionsToOXI(DirectionsFind(true,Mode_,20,Deviation_,i));
     }
//printf(SignalBuffer);
   if(SignalBuffer=="XO" || SignalBuffer=="HO")
     {
      double OP=Ask;
      double TP=NormalizeDouble(OP+300/Point,Digits);
      double SL=NormalizeDouble(OP-100/Point,Digits);
      bool res=OrderSend(Symbol(),OP_BUY,1,OP,10,SL,TP,"",0);
     }
   if(SignalBuffer=="OX" || SignalBuffer=="HX")
     {
      double OP=Bid;
      double TP=NormalizeDouble(OP-300/Point,Digits);
      double SL=NormalizeDouble(OP+100/Point,Digits);
      bool res=OrderSend(Symbol(),OP_SELL,1,OP,10,SL,TP,"",0);
     }
   CMM+="\n"+SignalBuffer;SignalBuffer="";
   for(int i=BarStart+BarCount-1;i>=BarStart;i--)
     {
      SignalBufferN+=string(i)+",";
      //Print(i);
      SignalBuffer+=DirectionsToOXI(DirectionsFind(false,Mode_,100,Deviation_,i));
     }
//printf(SignalBuffer);
//CMM+="\n"+SignalBufferN;
   CMM+="\n"+SignalBuffer;
   Comment(CMM);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_KEYDOWN)
     {
      Print("The "+string(lparam)+" has been pressed");
      switch(int(lparam))
        {
         case 68://|
           {
            ObjectsDeleteAll(0,OBJ_HLINE);
            ObjectsDeleteAll(0,OBJ_VLINE);
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
string CMM="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DirectionsFind(bool strShow,int pMode,int period,double deviation,int bar)
  {
   double UP=DirectionsGet(pMode,period,deviation,6,bar,Digits);
   double DW=DirectionsGet(pMode,period,deviation,7,bar,Digits);
   double YY=DirectionsGet(pMode,period,deviation,8,bar,Digits);
   int r=-1;
   if(UP>0)
      r=OP_BUY;
   if(DW>0)
      r=OP_SELL;
   if(YY>0)
      r=-1;
//---
   if(strShow)
     {
      if(_MODE_DEVLOP==0) CMM+="**"+string(bar)+"* O:[ "+DoubleToStr(UP,Digits)+" ] | X:[ "+DoubleToStr(DW,Digits)+" ] | I:[ "+DoubleToStr(YY,Digits)+" ] == "+DirectionsToStr(r)+"\n";
      if(_MODE_DEVLOP==1) CMM+=string(bar)+" : "+DirectionsToStr(r)+"\n";
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DirectionsGet(int pMode,int period,double deviation,int index,int bar,int digit)
  {
   double _iCustom_TCCI=iCustom(Symbol(),Period(),"_Employ/Line_MrNit/Xtreme Line - Copy",pMode,period,0,0,true,1,deviation,"",clrNONE,clrNONE,clrNONE,clrNONE,1,1,1,"",index,bar);

   if(_iCustom_TCCI==EMPTY_VALUE) _iCustom_TCCI=0;

   return NormalizeDouble(_iCustom_TCCI,digit);
  }
//+------------------------------------------------------------------+
string DirectionsToStr(int statement)
  {
   switch(statement)
     {
      case  OP_BUY:
         return "U";
      case  OP_SELL:
         return "D";
      default:
         return "X";
     }
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DirectionsToOXI(int statement)
  {
   switch(statement)
     {
      case  OP_BUY:
         return "O";
      case  OP_SELL:
         return "X";
      default:
         return "H";
     }
   return "-";
  }
//+------------------------------------------------------------------+
