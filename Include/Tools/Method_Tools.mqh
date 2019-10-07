//+------------------------------------------------------------------+
//|                                               NumChok_Method.mqh |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include <Tools/Method_MQL4.mqh>
#include <Tools/Method_Magicnumber.mqh>
#include <Tools/Method_Printf.mqh>
#include <Tools/Method_String.mqh>

#define Sunday	0
#define Monday	1
#define Tuesday 2
#define Wednesday 3
#define Thursday 4
#define Friday	5
#define Saturday 6
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strSymbolShortName()
  {
   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setTemplate()
  {
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,true);

   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,false);

   ChartSetInteger(0,CHART_COLOR_GRID,C'15,15,15');
   //ChartSetInteger(0,CHART_COLOR_VOLUME,C'49,83,45');

   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);

   ChartSetInteger(0,CHART_COLOR_ASK,clrDimGray);

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
void setTemplate_ToBridge()
  {
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,true);

   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,false);

   ChartSetInteger(0,CHART_COLOR_GRID,C'15,15,15');
   //ChartSetInteger(0,CHART_COLOR_VOLUME,C'49,83,45');
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrRed);

   ChartSetInteger(0,CHART_COLOR_ASK,clrDimGray);

   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);

   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_BARS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBackgroundPanel(int _Magicnumber,string Name,string text,int Fontsize,int LabelCorner,int x,int y)
  {
   if(ObjectFind(0,Name)<0)
      _LabelCreate(Name,0);

   ObjectSetText(Name,text,Fontsize,"Webdings");
   ObjectSet(Name,OBJPROP_CORNER,LabelCorner);
   ObjectSet(Name,OBJPROP_BACK,false);
   ObjectSet(Name,OBJPROP_XDISTANCE,x);
   ObjectSet(Name,OBJPROP_YDISTANCE,y);
   ObjectSet(Name,OBJPROP_COLOR,C'25,25,25');

   ObjectSetString(0,Name,OBJPROP_TOOLTIP,"Magicnumber: ["+string(_Magicnumber)+"]");

  }
//+------------------------------------------------------------------+
string strZero(double var,string z1,string z2)
  {
   string v="";
   if(var>0)
     {
      v=z1+Comma(var,2," ")+z2;
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strZeroKey(string var,int Key)
  {
   string v="";
   if(Key>0)
     {
      v=var;
     }
   return v;
  }
//+------------------------------------------------------------------+
double _CalculatePrice_Merge(double Point_Buy,double LotBuy,double Point_Sell,double LotSell)
  {
   double SumProduct=0;
   double SumLot_Merge=0;
   double Result=0;
/*//+---------------------------------------------+   
   if(Point_Sell>0 && Point_Buy>0)
     {
      if(Point_Sell>Point_Buy)
        {
         if(LotBuy==LotSell)
           {
            
           }
         else
           {
           }
        }
      else if(Point_Sell<Point_Buy)
        {
         if(LotBuy==LotSell)
           {
           }
         else
           {
           }
        }
      else
        {

        }
     }
   else
      Result=-3;
*/
   SumProduct=(Point_Buy*LotBuy)+(Point_Sell*LotSell);
   SumLot_Merge=LotBuy+LotSell;
   Result=SumProduct/SumLot_Merge;

   return NormalizeDouble(Result,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderCNT_Ative(int _Key,int pin,int sub,string mode)
  {
//int CurrentMagic=_MagicEncrypt(mn);
   double c=0;
   double sum=0;
//---
   double _mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE); //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   double l=MarketInfo(Symbol(),MODE_LOTSIZE);
   double p=MarketInfo(Symbol(),MODE_POINT);
   double t=MarketInfo(Symbol(),MODE_TICKSIZE);
   double v=MarketInfo(Symbol(),MODE_TICKVALUE);
//---
   int Carry_Sub=sub;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(_Key,OrderMagicNumber());

      if(sub<0)Carry_Sub=OrderMagic_Sub;

      if(OrderSymbol()==Symbol() &&
         ((pin<0 && OrderType()==_Key) ||(OrderMagic_Key==_Key && OrderMagic_Pin==pin && OrderMagic_Sub==Carry_Sub)) &&
         OrderType()<=1)
        {
         c++;
         //---
         if(mode=="Sum")
           {
            if(OrderType()==OP_BUY)
              {
               if(_mode==0) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();

               if(_mode==1) sum+=(Bid-OrderOpenPrice())/p*v/t/l*OrderLots();
               if(_mode==2) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();
               sum+=OrderCommission()+OrderSwap();
              }
            if(OrderType()==OP_SELL)
              {
               if(_mode==0) sum+=(OrderOpenPrice()-Ask)/p*v*OrderLots();

               if(_mode==1) sum+=(OrderOpenPrice()-Ask)/p*v/t/l*OrderLots();
               if(_mode==2) sum+=(OrderOpenPrice()-Ask)/p*v*OrderLots();
               sum+=OrderCommission()+OrderSwap();
              }
           }
         //---
        }
     }
//---
   if(mode=="Sum")
     {
      return sum;
     }
   if(mode=="Cnt")
     {
      return c;
     }
//---

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double __OrderPrice;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _getOrderType(int _Magicnumber,int Key,int Sub)
  {
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      //---
      _MagicDecode(_Magicnumber,OrderMagicNumber());
      if(OrderSymbol()==Symbol() && 
         OrderMagic_Key==_Magicnumber &&
         OrderMagic_Pin==Key&&
         OrderMagic_Sub==Sub)
        {
         __OrderPrice=OrderOpenPrice();
         return OrderType();
        }
     }
//---
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _getOrderPriceCure(int _Magicnumber,string Mode,int pin,int Spread)
  {
//int _MagicNumber=_MagicEncrypt(nm);

   double MinPrice=99999,MaxPrice=-99999;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(_Magicnumber,OrderMagicNumber());
      if(OrderMagic_Key==_Magicnumber &&
         OrderMagic_Pin==pin &&
         OrderSymbol()==Symbol())
        {
         if(OrderOpenPrice()>MaxPrice)
            MaxPrice=OrderOpenPrice();
         if(OrderOpenPrice()<MinPrice)
            MinPrice=OrderOpenPrice();
        }
     }

   if("Buy"==Mode && 
      (Ask<MaxPrice) && 
      (Ask<MinPrice-getSpreadCureRate(Spread)))
     {
      return true;
     }
   if("Sell"==Mode && 
      (Bid>MinPrice) && 
      (Bid>MaxPrice+getSpreadCureRate(Spread)))
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSpreadCureRate(int Max14)
  {
   double SpreadCureRate[]={150,175,200,225,250,275,300,325,350,375,400,425,450,475,500};
   return NormalizeDouble(SpreadCureRate[Max14]*Point,Digits);
  }
//+------------------------------------------------------------------+
double getSpreadCureRateATR()
  {
   double ATR_TP=NormalizeDouble((iATR(Symbol(),0,3,1)+iATR(Symbol(),0,3,0))/2,Digits);

   if(ATR_TP<NormalizeDouble(175/MathPow(10,Digits),Digits))
      ATR_TP=NormalizeDouble(175/MathPow(10,Digits),Digits);

   return ATR_TP;
  }
//+------------------------------------------------------------------+
enum FiboRate_
  {
   F_0=236,//0.236
   F_1=382,//0.382
   F_2=500,//0.500
   F_3=618,//0.618
   F_4=1000,//1.000
   F_5=1236,//1.236
   F_6=1382,//1.382
   F_7=1500,//1.500
   F_8=1618,//1.618
   F_9=1809,//1.809
   F_10=2000//2.000
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum lNumber
  {
   lNumber_0=0,//0
   lNumber_1=1,//1
   lNumber_2=2,//2
   lNumber_3=3,//3
   lNumber_4=4,//4
   lNumber_5=5,//5
   lNumber_6=6,//6
   lNumber_7=7,//7
   lNumber_8=8,//8
   lNumber_9=9,//9
   lNumber_10=10,//10
   lNumber_11=11,//11
   lNumber_12=12,//12
   lNumber_13=13,//13
   lNumber_14=14,//14
   lNumber_15=15,//15
   lNumber_16=16,//16
   lNumber_17=17,//17
   lNumber_18=18,//18
   lNumber_19=19,//19
   lNumber_20=20,//20

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum lNumber4
  {
   lNumber4_0=0,//0
   lNumber4_1=1,//1
   lNumber4_2=2,//2
   lNumber4_3=3,//3
   lNumber4_4=4,//4
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getFiboRate2(int v)
  {
   return v*0.001;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getFiboRate(int Max6)
  {
   double FiboRate[]={1.000,1.236,1.382,/**/1.500,1.618,1.809,2.000};
   return FiboRate[Max6];
  }
int cnt_M0,cnt_M1,cnt_M5,cnt_M15,cnt_M30,cnt_H1,cnt_H4,cnt_D1,cnt_W1,cnt_MN;
//+------------------------------------------------------------------+
bool _iNewBar(ENUM_TIMEFRAMES TF)
  {
   int get=getCntBar(TF);
   int set=iBars(Symbol(),TF);
//P(__LINE__,"_iNewBar"+TF,"set",set,"get",getCntBar(TF),"=",cnt_M30);
   if(get!=set)
     {
      setCntBar(TF,set);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _iNewBar(ENUM_TIMEFRAMES TF,double mod)
  {
   int set=iBars(Symbol(),TF);
//P(__LINE__,"_iNewBar"+TF,"set",set,"get",getCntBar(TF),"=",cnt_M30);
   if(MathMod(set,mod)==0)
     {
      setCntBar(TF,set);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
void setCntBar(ENUM_TIMEFRAMES TF,int set)
  {
   switch(TF)
     {
      case  PERIOD_CURRENT:
         cnt_M0=set; break;
      case  PERIOD_M1:
         cnt_M1=set; break;
      case  PERIOD_M5:
         cnt_M5=set; break;
      case  PERIOD_M15:
         cnt_M15=set; break;
      case  PERIOD_M30:
         cnt_M30=set; break;
      case  PERIOD_H1:
         cnt_H1=set; break;
      case  PERIOD_H4:
         cnt_H4=set; break;
      case  PERIOD_D1:
         cnt_D1=set; break;
      case  PERIOD_W1:
         cnt_W1=set; break;
      case  PERIOD_MN1:
         cnt_MN=set; break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getCntBar(ENUM_TIMEFRAMES TF)
  {
   switch(TF)
     {
      case  PERIOD_CURRENT:
         return cnt_M0;
      case  PERIOD_M1:
         return cnt_M1;
      case  PERIOD_M5:
         return cnt_M5;
      case  PERIOD_M15:
         return cnt_M15;
      case  PERIOD_M30:
         return cnt_M30;
      case  PERIOD_H1:
         return cnt_H1;
      case  PERIOD_H4:
         return cnt_H4;
      case  PERIOD_D1:
         return cnt_D1;
      case  PERIOD_W1:
         return cnt_W1;
      case  PERIOD_MN1:
         return cnt_MN;
     }
   return -1;
  }
//+------------------------------------------------------------------+
bool Workday=false,Workdayx=false;
string SMS_Workday;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _StayFriday(double Runday,int Start_Day,int Start_Hour,int Start_Min,int End_Day,int End_Hour,int End_Min)
  {
   int tH=TimeHour(TimeLocal());
   int M=TimeMinute(TimeLocal());
   int _DayOfWeek=TimeDayOfWeek(TimeLocal());
//Print(__FUNCTION__+_DayOfWeek);
   if((_DayOfWeek<=Start_Day && tH<=Start_Hour && M<=Start_Min) ||
      (_DayOfWeek>=End_Day   && tH>=End_Hour   && M>=End_Min))
     {
      Workday=false;//OFF-Rest
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" Holidays");
        }
     }
   else
     {
      Workday=True;//ON
      if(Workdayx!=Workday)
        {
         Workdayx=Workday;
         Print(__FUNCTION__+" Workday");
        }

     }
   if(Workdayx!=Workday)
      Print(__FUNCTION__+" "+string(Workday));

//---
   string _strBoolYN;
   if(Workday)
      _strBoolYN="Workday";
   else
      _strBoolYN="Holidays";
//---

   SMS_Workday=_StayFriday(_DayOfWeek)+":"+string(_DayOfWeek)+" "+cFillZero(tH,2)+"h:"+cFillZero(M,2)+"m | Running "+string(Runday)+"day |"+cD(Runday/20,2)+"mn  is a "+_strBoolYN;
  }
//+------------------------------------------------------------------+
string _StayFriday(int var)
  {
   switch(var)
     {
      case 0:
         return "SUN";
      case 1:
         return "MON";
      case 2:
         return "TUE";
      case 3:
         return "WED";
      case 4:
         return "THU";
      case 5:
         return "FRI";
      case 6:
         return "SAT";
     }
   return "default.";
  }
//+------------------------------------------------------------------+
int OrderSends(int _MGN,string _EAName,int _OP_Trade,int Case,int Cnt,double Price,double Price_SL,double Price_TP,double lot)
  {
   int Dir=-1;
   string Dirs="";
   if(_OP_Trade==0 || _OP_Trade==2 || _OP_Trade==4)
     {
      Dir=0;
      Dirs="B";
     }
   if(_OP_Trade==1 || _OP_Trade==3 || _OP_Trade==5)
     {
      Dir=1;
      Dirs="S";
     }
//---
//double Lot=_CalculateLots(Dir,PV,Case,Cnt);
   if(lot)
     {
      int MGN_=_MagicEncrypt(_MGN,Case,Cnt);
      return OrderSend(Symbol(),_OP_Trade,lot,Price,100,Price_SL,Price_TP,strEA_Name(_EAName,Dirs,MGN_),MGN_,0);
     }
//---
   return -1;
  }
//+------------------------------------------------------------------+
string strEA_Name(string _EAName,string Dir,int MGN_)
  {
   return _EAName+" "+Dir+cI(MGN_);
  }
//+------------------------------------------------------------------+
