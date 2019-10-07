//+------------------------------------------------------------------+
//|                                  SkyFall [Scap ShortTerm][3].mq4 |
//|                                            facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict

string PathFileTCCI="_Employ/Line_MrNit/Master_TCCI Windows";
string PathFileHK="_Employ/Line_MrNit/Master_HK Bar";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_Price
  {
   MODE_PriceC=0,//C
   MODE_PriceO=1,//O
   MODE_PriceH=2,//H
   MODE_PriceL=3,//L
   MODE_PriceHL=4,//HL/2
   MODE_PriceHLC3=5,//HLC/3
   MODE_PriceHLC4=6,//(HL+2)*(C/4)
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES Minor_Time=PERIOD_CURRENT;
extern ENUM_TIMEFRAMES Major_Time=PERIOD_CURRENT;
extern ENUM_TIMEFRAMES Prime_Time=PERIOD_CURRENT;

extern int        Minor_Period=20;
extern int        Major_Period=8;
extern int        Prime_Period=4;

extern int        Minor_BarCount=8;
extern int        Major_BarCount=8;
extern int        Prime_BarCount=4;

extern double     OrderNearbyArea=200;
extern double     OrderNearbyFriend=1;

extern string Sep="------------------ TCCI -------------------------";//--------------------------
extern int TCCI_Displace=0;
extern int TCCI_Filter= 0;
extern int TCCI_Color = 2;
extern int TCCI_ColorBarBack = 1;
extern double TCCI_Deviation = 0.0;
//+------------------------------------------------------------------+
int nBar=-1;
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
string CMM="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   CMM="";
//---
/*double _iCustom;
   string Str;

   for(int i=0;i<2;i++)
     {
      _iCustom=iCustom(Symbol(),Period(),PathFileHK,0,i,6);

      Str=DoubleToStr(_iCustom,Digits);

      if(_iCustom==EMPTY_VALUE)
         Str="_";

      CMM+="\n"+Str;
     }*/
   if(nBar!=Bars)
     {
      nBar=Bars;
      //+------------------------------------------------------------------+
      double OP=Ask;
      if(BufferToResule() && OrderGetNearby(OP,OP_BUY))
        {
         double TP=NormalizeDouble(OP+(OrderNearbyArea*Point),Digits);
         double SL=NormalizeDouble(OP-(300*Point),Digits);
         //TP=0;
         SL=0;
         bool res=OrderSend(Symbol(),OP_BUY,1,OP,10,SL,TP,"",0);
        }
      //+------------------------------------------------------------------+
     }

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

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderGetNearby(double OpenPrice,int OP_DIR)
  {
   bool r=false;
   int CountFriend=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderType()==OP_DIR)
        {
         if(MathAbs(OpenPrice-OrderOpenPrice())<=(OrderNearbyArea*Point))
           {
            CountFriend++;
           }
        }
     }
   if(CountFriend<OrderNearbyFriend)
      r=true;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BufferToResule()
  {
   bool Result=false;
   string Buffer_Minor;
//+------------------------------------------------------------------+
   CMM+="\n--------------------";
   string Str="";
   Str+="____U"+"#";
   Str+="__HH_"+"#";
   Str+="DDDDU";

   string DATA_LV1[];
   string sep="#";
   ushort u_sep=StringGetCharacter(sep,0);
   StringSplit(Str,u_sep,DATA_LV1);

   int nChar=ArraySize(DATA_LV1);
   CMM+="\n nLV1 : "+nChar;

   if(nChar==3)
     {
      for(int i=0;i<3;i++)
         CMM+="\n"+DATA_LV1[i];
      //         
      int Bar=DATA_Chk(DATA_LV1);
      CMM+="\n nLV2 : "+Bar;
      if(Bar>=0)
        {
         Buffer_Minor=BufferGet(0,Minor_Time,Minor_Period,nChar+1);
         //---
         for(int i=0;i<Bar;i++)
           {
            if(
               (BufferSub(Buffer_Minor,i) == BufferSub(DATA_LV1[0],i))||
               (BufferSub(Buffer_Minor,i) == BufferSub(DATA_LV1[1],i))||
               (BufferSub(Buffer_Minor,i) == BufferSub(DATA_LV1[2],i))
               )
              {
               Result=true;
              }
           }
        }
      else
        {
         CMM+="\n Lv2noMath";
        }
     }
   else
     {
      CMM+="\n Lv1# noMath"+Str;
     }
//+------------------------------------------------------------------+
   CMM+="\n--------------------";
   CMM+="\n"+Buffer_Minor;
//+------------------------------------------------------------------+
   CMM+="\n--------------------";
   CMM+="\nResult: "+Result;
//+------------------------------------------------------------------+
   return Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DATA_Chk(string &v[])
  {
   for(int i=0;i<ArraySize(v)-1;i++)
     {
      if(StringLen(v[i])!=StringLen(v[i]))
         return -1;
     }
   return StringLen(v[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BufferSub(string v,int StartDigit)
  {
   return StringSubstr(v,StartDigit,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BufferGet(int Mode_Call,int Mode_TF,int Mode_Period,int Bar)
  {
   string BufferTCCI="",BufferHK="";
   for(int i=1+Bar-1;i>=1;i--)
     {
      BufferTCCI+=BufferGet_iTCCI(Mode_Call,Mode_TF,Mode_Period,i);
      BufferHK+=BufferGet_iHK(Mode_TF,i);
     }
//CMM+="\n"+BufferTCCI;
//CMM+="\n"+BufferHK;
   string Dump,Buffer_Main;
   int DirTCCI=-1,DirHK=-1;
   for(int i=0;i<Bar;i++)
     {
      DirTCCI=int(StringSubstr(BufferTCCI,i,1));
      DirHK=int(StringSubstr(BufferHK,i,1));
      if(DirTCCI==DirHK)
        {
         if(DirTCCI==OP_BUY)
            Dump="U";
         else if(DirTCCI==OP_SELL)
            Dump="D";
        }
      else
         Dump="H";

      Buffer_Main+=Dump;
     }
   return Buffer_Main;
  }
//+------------------------------------------------------------------+
string BufferGet_iTCCI(int Mode_Call,int Mode_TF,int Mode_Period,int Bar)
  {
   int r=-1;
   double _iSignal=iCustom(Symbol(),Mode_TF,PathFileTCCI,Mode_Call,Mode_Period,
                           TCCI_Displace,TCCI_Filter,TCCI_Color,TCCI_ColorBarBack,TCCI_Deviation,
                           3,Bar);
   if(_iSignal>0) r=OP_BUY;
   if(_iSignal<0) r=OP_SELL;
   return string(r);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BufferGet_iHK(int Mode_TF,int Bar)
  {
   int r=-1;
   double _iSignal=iCustom(Symbol(),Mode_TF,PathFileHK,0,4,Bar);
   if(_iSignal>0) r=OP_BUY;
   if(_iSignal<0) r=OP_SELL;
   return string(r);
  }
//+------------------------------------------------------------------+
