//+------------------------------------------------------------------+
//|                                               Price_Patterns.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern int Magicnumber=168;//Magicnumber
extern double Lots=0.05;//Lots
int cntM15=0,xcntM15;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   _setTemplate();
   showInfo();
   cntM15=iBars(Symbol(),0);
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
//---
   xcntM15=iBars(Symbol(),0);
   if(cntM15!=xcntM15)
     {
      cntM15=xcntM15;
      //------------------------------
      _StayFriday();
      chkPP_Pin();
      //printf("R");
      //---

      //------------------------------

     }
   showInfo();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

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

  }
//+------------------------------------------------------------------+
void showInfo()
  {
   string sms;
   sms+="\n"+SMS_Workday;
   if(Bid<Sar)
     {
      sms+="\nSELL";
     }
   else
     {
      sms+="\nBUY";
     }

//sms+="\n"+string(chkPercentPP(High[0],Low[0],Open[0]));
//sms+="\n"+string(chkPercentPP(High[0],Low[0],Close[0]));
//sms+="\n"+RSI;

   sms+="\n\nBalace : "+_Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" | Profit : "+_Comma(AccountInfoDouble(ACCOUNT_PROFIT),2," ");
   Comment(sms);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int chkPercentPP(double high,double low,double v)
  {
   int Mark=0;
//---
   double A,B,Scale=high-low,Step=Scale/100;

   Scale=NormalizeDouble(Scale,Digits);
   Step=NormalizeDouble(Step,Digits+1);

   for(int i=1;i<=100;i++)
     {
      A=high-(Step*i);
      B=high-(Step*(i+1));

      if(A>=v && v>=B)
        {
         Mark=i;
         //Print(__FUNCTION__+" Get :[ "+string(v)+" ][ "+string(Mark)+" ]");
         break;
        }
     }
   return Mark;
  }
//+------------------------------------------------------------------+
double RSI;
double Sar;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int chkPP_Pin()
  {
   int Sticks=1;
   int z=0;

   int _Open=chkPercentPP(High[Sticks],Low[Sticks],Open[Sticks]);
   int _Close=chkPercentPP(High[Sticks],Low[Sticks],Close[Sticks]);

   double R0=NormalizeDouble((High[Sticks]-Low[Sticks])*MathPow(10,Digits),0);

   double SL,TP;

   double HH=iHigh(Symbol(),0,1);
   double LL=iLow(Symbol(),0,1);

   double R=HH-LL;
//double R=High[Sticks]-Low[Sticks];

//SL=R*(1.2);
//---
//double x=NormalizeDouble(500/MathPow(10,Digits),Digits);
//if(SL>=x)
//   SL=x;
//TP=SL*(1.2);

//--
//SL=NormalizeDouble(300/MathPow(10,Digits),Digits);
//TP=NormalizeDouble(150/MathPow(10,Digits),Digits);
//--
   int ShiftRange=40;
   int UP_1=0;//0-15
   int UP_2=5;//10-30

   int DW_1=100-UP_1;
   int DW_2=100-UP_2;

//double Sto=iStochastic(Symbol(),0,5,3,3,MODE_EMA,1,MODE_SIGNAL,1);
//Sar=iSAR(Symbol(),PERIOD_H4,0.019,0.2,0);
   Sar=iSAR(Symbol(),0,0.0015,0.2,0);
//----------   
//---OP_BUY
   double Fibo[]={1,1.2,0.718};
   if(R0>=200 && R0<=400)
     {
      if(_Open>_Close && chkPP_Range(_Open,UP_1,ShiftRange) && chkPP_Range(_Close,UP_2,ShiftRange))
         //|| (_Open<_Close && chkPP_Range(_Open,UP_2,ShiftRange) && chkPP_Range(_Close,UP_1,ShiftRange)))
        {
         if(chkOrder(0) && Workday)
           {
            //if(Ask>Sar)
            //  {
            //HH=High[Sticks];
            //LL=Low[Sticks];
            R=Close[Sticks]-Low[Sticks];
            //---
            SL=NormalizeDouble(Bid-(R*Fibo[0]),Digits);
            TP=NormalizeDouble(Bid+(R*Fibo[1]),Digits);
            //---
            z=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,SL,TP,"",_MagicEncrypt(0));
            //z=OrderSend(Symbol(),OP_BUY,Lots,Ask,100,Bid-SL,Bid+TP,"",_MagicEncrypt(0));
            return z;
            //}
           }
        }
      if(_Open<_Close && chkPP_Range(_Open,DW_2,ShiftRange) && chkPP_Range(_Close,DW_1,ShiftRange))
         //|| (_Open>_Close && chkPP_Range(_Open,DW_1,ShiftRange) && chkPP_Range(_Close,DW_2,ShiftRange)))
        {
         if(chkOrder(1) && Workday)
           {
            //if(Bid<Sar)
            //  {
            //HH=Low[Sticks];
            //LL=Close[Sticks];
            R=High[Sticks]-Close[Sticks];
            //---
            SL=NormalizeDouble(Ask+(R*Fibo[0]),Digits);
            TP=NormalizeDouble(Ask-(R*Fibo[1]),Digits);
            //---
            z=OrderSend(Symbol(),OP_SELL,Lots,Bid,100,SL,TP,"",_MagicEncrypt(1));
            //z=OrderSend(Symbol(),OP_SELL,Lots,Bid,100,Ask+SL,Ask-TP,"",_MagicEncrypt(0));
            return z;
            //}
           }
        }
     }
//orderModify(0,SL,TP);
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool chkPP_Range(int x,int Center,int Plus)
  {
   int Min=Center-Plus,Max=Center+Plus;
   if(Min<=0)
     {Min=0;}
   if(Max>=100)
     {Max=99;}
//---

//printf(Min+" | "+Max);

   if(Max>=x && x>=Min)
      return true;
   else
      return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setTemplate()
  {

   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);

   ChartSetInteger(0,CHART_COLOR_GRID,clrWhite);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= z;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }
   return temp3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool chkOrder(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);
   bool Find=true;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         Find=false;
        }
     }
   return Find;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool orderModify(int v,double SL,double TP)
  {
   int CurrentMagic=_MagicEncrypt(v);
   int z=-1;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         if(OrderType()==0)
           {
            SL=NormalizeDouble(OrderOpenPrice()-SL,Digits);
            TP=NormalizeDouble(OrderOpenPrice()+TP,Digits);
           }
         else if(OrderType()==1)
           {
            SL=NormalizeDouble(OrderOpenPrice()+SL,Digits);
            TP=NormalizeDouble(OrderOpenPrice()-TP,Digits);
           }

         if(SL!=OrderStopLoss() || TP!=OrderTakeProfit())
           {
            //z=OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,0);
            return z;
           }
        }
     }
   return z;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _MagicEncrypt(int Type)
  {
   string v=string(Magicnumber)+string(Type);
   return int(v);
  }
int OrderMagic_,OrderPin;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MagicDecode(int v)
  {
   string z=string(v);
   string m=StringSubstr(z,0,StringLen(string(Magicnumber)));
   string o=StringSubstr(z,StringLen(string(Magicnumber)),1);
   OrderMagic_=int(m);
   OrderPin=int(o);
  }
//+------------------------------------------------------------------+
bool Workday;
string SMS_Workday;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _StayFriday()
  {
   int H=TimeHour(TimeLocal());

   SMS_Workday="Day : "+string(DayOfWeek())+"/"+_FillZero(H)+" Workday : "+_strBoolYN(Workday);
//_LabelSet("TextTime",10,50,clrYellow,"Arial",10,SMS_Workday);
//---
   if((DayOfWeek()<=1 && H<7) || (DayOfWeek()>=5 && H>=20))
     {
      Workday=false;//OFF-Rest
     }
   else
     {
      Workday=True;//ON
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _FillZero(int v)
  {
   string temp;
   if(v<10)
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _strBoolYN(int v)
  {
   if(v)
      return "Yes";
   else
      return "No";
  }
//+------------------------------------------------------------------+
