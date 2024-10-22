//+------------------------------------------------------------------+
//|                                                    Valentine.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, TP-Member"
#property link      "https://goo.gl/T9myHV"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>

#include <Tools/Technique_Candle Patterns.mqh>;

string EAVer="0.50a";
string EAName="Valentine "+EAVer+" "+strSymbolShortName();

extern double Fund=300;//Fund
extern double BetPer=10;//PercentBet/N
extern int MGN=7;//MagicNumber

int RSI_Period=17;//Open_RSI_Period*
double RSI_UP=66;//Open_RSI_UP*
double RSI_DW=34;//Open_RSI_DW*

extern int ADX_Period=4;//Open_ADX_Period*

extern int TraiRateStart=0;//Trail_RateStart*
extern int iATR_Period=2;//Trail_iATR_Period*

extern int CureSpreadRate=3;//CureSpreadRate 0-8
extern int _OrderLookAroundFirst=200;//LookAround 100-500
extern ENUM_TIMEFRAMES PERIOD_Major=PERIOD_H1;

extern bool isCase=false;//4 Case
extern bool BetweenOrder=false;//BetweenOrder

double Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
double Current_BALANCE_Test=Current_BALANCE;

string _ActCurrency=" "+AccountCurrency();

int sz;

double cntRunDay;

int cntOrder;
double sumOrder;
double sumConfirm;

int cntOrderBuy,cntOrderSell;
double sumOrderBuy,sumOrderSell;
double _PriceMax_Sell,_PriceMin_Sell;
double _PriceMax__Buy,_PriceMin__Buy;

int cntOrderFollowBuy,cntOrderFollowSell;
double sumOrderFollowBuy,sumOrderFollowSell;
double _PriceMax_FollowSell,_PriceMin_FollowSell;
double _PriceMax__FollowBuy,_PriceMin__FollowBuy;

double ConfirmBuy,ConfirmSell;
double ConfirmBuyFollow,ConfirmSellFollow;

double Stat_FocusTime=20;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   ppinit();

   setTemplate();
   _StayFriday(cntRunDay,Sunday,6,0,Friday,21,0);
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
extern double PV_Market=25;//PV_Market 0-100
extern double PV_MarketCure=25;//PV_MarketCure 0-100
//---
double PV_1=20;//PV_iBar 0-16.5 
double PV_2=35;//PV_iADX 0-16.5 
double PV_3=10;//PV_iRSI 0-16.5 
double PV_4=35;//PV_iPower 0-16.5 
double PV_5=25;//PV_iwonders 0-16.5 
double PV_6=10;//PV_iIKH_Chikou 0-16.5 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
/*if(IsTesting())
     {
      double t=AccountInfoDouble(ACCOUNT_BALANCE)-Current_BALANCE_Test-ProfitCollect_MN;
      Current_BALANCE_Test+=t;
     }
   else
     {
      Current_BALANCE=_Account_Balance();
      if(Current_BALANCE<BetMagin)
        {
         BetMagin=Current_BALANCE;
         BetCnt__=NormalizeDouble(100/BetPer,0);
         BetCoin_=NormalizeDouble((BetMagin/100)*BetPer,2);

         //SumSupporter=NormalizeDouble((BetCoin_/100)*(BetPer*10),2);
         SumSupporter=NormalizeDouble(BetCoin_*,2);

        }
     }*/
   if(_iNewBar(PERIOD_D1,1))
     {
      cntRunDay++;
      if(cntRunDay>0 && MathMod(cntRunDay,Stat_FocusTime)==0)
        {
         Current_BALANCE=Account_Balance_();
         double Profit_Now;
         if(IsTesting() && false)
           {
            if(cntOrder==0)
              {
               Profit_Now=Current_BALANCE_Test-Fund-ProfitCollect_MN;

               double Profit_Nets=Profit_Now*0.9;
               double Profit_Etcs=Profit_Now*0.1;
               double Profit_Fund=Profit_Now*0.1;

               Current_BALANCE_Test=(Current_BALANCE_Test-Profit_Now)+Profit_Fund;

               Profit_Now=Profit_Nets;
              }
            else
              {
               Profit_Now=0;
              }
           }
         else
           {
            Profit_Now=Current_BALANCE-Fund-ProfitCollect_MN;
           }

         ProfitCollect_MN+=Profit_Now;

         //---String
         History_ProfitDay+=cD((Profit_Now/Fund)*100,2)+"/";
         History_ProfitCollect_MN+=cD(Profit_Now*32,2)+"/";
        }
     }
//---

   __Hub_Order_CNTSum();
//---

//PV_1=0;
//PV_2=25;
//PV_3=0;
//PV_4=0;
//PV_5=0;
//PV_6=0;

//if(true)
   if(_iNewBar(0,1))
     {
      _StayFriday(cntRunDay,Sunday,6,0,Friday,21,0);
      if(cntOrder<=BetCnt__)
        {
         Current_BALANCE=Account_Balance_();
         Bet_Cashflow=Current_BALANCE-BetMagin;
        }
      //+------------------------------------------------------------------+
      //PV_Market=0;
/*double PV=__Hub_SumPV(_iBar_getStatus(PV_1,PERIOD_H1,1),
                            _iADX(PV_2),
                            _iRSI_getStatus(PV_3),
                            _iPower(PV_4),
                            _iCustom_tampc_wonders(PV_5),
                            _iIKH_Chikou(PV_6));
      //PV_MarketCure=25;
      double PV_C=__Hub_SumPV(_iBar_getStatus(PV_1,PERIOD_H1,1),
                              _iADX(PV_2),
                              _iRSI_getStatus(PV_3),
                              _iPower(PV_4),
                              _iCustom_tampc_wonders(PV_5),
                              _iIKH_Chikou(PV_6));*/
      //---

      //---

      //double PV=PVSum_Hub(pPriceAction_Hub(25,3),pPower(25));
      //double PV_C=PVSum_Hub(pPriceAction_Hub(25,3));

      double PV=PVSum_Hub(pp_start(50,1));
      double PV_2=PVSum_Hub(pIKH_Chikou(25),pCustom_tampc_wonders(25));

      double PV_C=PVSum_Hub(pp_start(25,1),pCustom_tampc_wonders(25));

      //---

      _LabelSet("Text_PV",CORNER_LEFT_LOWER,400,65,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# PV ["+cD(PV,2)+"]     PV2 ["+cD(PV_C,2)+"]","");

      //+------------------------------------------------------------------+

      bool Chk_OnArea;
      Chk_OnArea=(!_getOrderPriceCure(MGN,"Buy",1,CureSpreadRate))
                 && (DZP_Buy>(-500) && DZP_Buy<=(_OrderLookAroundFirst*(-1)))
                 && (cntOrderBuy>=2 && cntOrderBuy<=BetCnt__)
                 && _OrderLookAround("Buy",1,-1,Ask,_OrderLookAroundFirst);
      if(sumOrderBuy<0 && Chk_OnArea && PVMarket_(OP_BUY,PV,PV_MarketCure) && BetweenOrder)
        {
         sz=OrderSends_PV(OP_BUY,1,cntOrderBuy,Ask,0,0,PV);
         //_LabelSet("Text_Order1",CORNER_LEFT_LOWER,200,65,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# Price"+cD(Ask,Digits)+"|"+cI(DZP_Buy)+"|"+cD(ll,5),"");
         HLineCreate_(0,"LINE__Order",cI(DZP_Buy),0,Ask,clrMagenta,0,1,0,true,false,0);

        }
      //---
      Chk_OnArea=(!_getOrderPriceCure(MGN,"Sell",2,CureSpreadRate))
                 && (DZP_Sell>(-500) && DZP_Sell<=(_OrderLookAroundFirst*(-1)))
                 && (cntOrderSell>=2 && cntOrderSell<=BetCnt__)
                 && _OrderLookAround("Sell",2,-1,Bid,_OrderLookAroundFirst);
      if(sumOrderSell<0 && Chk_OnArea && PVMarket_(OP_SELL,PV,PV_MarketCure) && BetweenOrder)
        {
         sz=OrderSends_PV(OP_SELL,2,cntOrderSell,Bid,0,0,PV);

         //_LabelSet("Text_Order2",CORNER_LEFT_LOWER,200,50,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# Price"+cD(Bid,Digits)+"|"+cI(DZP_Sell)+"|"+cD(ll,5),"");
         HLineCreate_(0,"LINE__Order",cI(DZP_Sell),0,Bid,clrMagenta,0,1,0,true,false,0);
        }
      //---     //+------------------------------------------------------------------+

      if(cntOrderBuy==0)
        {
         if(Workday)
           {
            if(PVMarket_(OP_BUY,PV,PV_Market)/* && _iStochastic(10)>0*/)
              {
               sz=OrderSends_PV(OP_BUY,1,cntOrderBuy,Ask,0,Ask+(300/MathPow(10,Digits)),PV);

               if(cntOrderSell==0 && pCustom_tampc_wonders(10)>0)
                 {
                  //sz=OrderSends_PV(OP_SELL,2,cntOrderSell,Bid,0,0,PV);
                 }
              }

           }
        }
      else if(_getOrderPriceCure(MGN,"Buy",1,CureSpreadRate))
        {
         if(PVMarket_(OP_BUY,PV_C,PV_MarketCure))
           {
            sz=OrderSends_PV(OP_BUY,1,cntOrderBuy,Ask,0,0,PV_C);
           }
        }

      if(cntOrderSell==0)
        {
         if(Workday)
           {
            if(PVMarket_(OP_SELL,PV,PV_Market)/* && _iStochastic(10)<0*/)
              {
               sz=OrderSends_PV(OP_SELL,2,cntOrderSell,Bid,0,Bid-(300/MathPow(10,Digits)),PV);
               if(cntOrderBuy==0 && pCustom_tampc_wonders(10)<0)
                 {
                  //sz=OrderSends_PV(OP_BUY,1,cntOrderBuy,Ask,0,0,PV);
                 }
              }
           }
        }
      else if(_getOrderPriceCure(MGN,"Sell",2,CureSpreadRate))
        {
         if(PVMarket_(OP_SELL,PV_C,PV_MarketCure))
           {
            sz=OrderSends_PV(OP_SELL,2,cntOrderSell,Bid,0,0,PV_C);
           }
        }
      //+------------------------------------------------------------------+
      if(cntOrderFollowBuy==0)
        {
         if(Workday && isCase)
            if(PVMarket_(OP_BUY,PV_2,PV_Market*0.618)
               && _OrderLookAround("Buy",1,0,Ask,350))
              {
               sz=OrderSends_PV(OP_BUY,4,cntOrderFollowBuy,Ask,0,0,PV_2);
              }
        }
      else if(_getOrderPriceCure(MGN,"Buy",4,CureSpreadRate))
        {
         if(PVMarket_(OP_BUY,PV_C,PV_MarketCure))
           {
            sz=OrderSends_PV(OP_BUY,4,cntOrderFollowBuy,Ask,0,0,PV_C);
           }
        }

      if(cntOrderFollowSell==0)
        {
         if(Workday && isCase)
            if(PVMarket_(OP_SELL,PV_2,PV_Market*0.618)
               && _OrderLookAround("Sell",2,0,Bid,350))
              {
               sz=OrderSends_PV(OP_SELL,5,cntOrderFollowSell,Bid,0,0,PV_2);
              }
        }
      else if(_getOrderPriceCure(MGN,"Sell",5,CureSpreadRate))
        {
         if(PVMarket_(OP_SELL,PV_C,PV_MarketCure))
           {
            sz=OrderSends_PV(OP_SELL,5,cntOrderFollowSell,Bid,0,0,PV_C);
           }
        }
     }
   __DashBorad();
   __Hub_OrderTP();
   setBackgroundPanel(MGN,"BgroundGG","gg",160,0,-130,15);
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
//|                                                                  |
//+------------------------------------------------------------------+
double PVSum_Hub(double pv1,double pv2,double pv3,double pv4,double pv5,double pv6)
  {
   double v=pv1+pv2+pv3+pv4+pv5+pv6;

   if(v>100)
      return 100;
   if(v<(-100))
      return -100;

   return NormalizeDouble(v,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PVSum_Hub(double pv1,double pv2,double pv3)
  {
   double v=pv1+pv2+pv3;

   if(v>100)
      return 100;
   if(v<(-100))
      return -100;

   return NormalizeDouble(v,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PVSum_Hub(double pv1,double pv2)
  {
   double v=pv1+pv2;

   if(v>100)
      return 100;
   if(v<(-100))
      return -100;

   return NormalizeDouble(v,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PVSum_Hub(double pv1)
  {
   double v=pv1;

   if(v>100)
      return 100;
   if(v<(-100))
      return -100;

   return NormalizeDouble(v,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PVMarket_(int OP,double PV,double Market)
  {

   if(OP==OP_BUY && PV>=Market)
     {
      return true;
     }
   if(OP==OP_SELL && PV<=Market*(-1))
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strEA_Name(string Dir,int MGN_)
  {
   return EAName+" "+Dir+cI(MGN_);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pBar_getStatus_(double PV,ENUM_TIMEFRAMES TF,int v)
  {
   double vOpen=iOpen(NULL,TF,v);
   double vClose=iClose(NULL,TF,v);
   if(vOpen<vClose)//Lime
     {
      //return PV*(-1);
      return PV;
     }
   else if(vOpen>vClose)//Red
     {
      return PV*(-1);
      //return PV;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pADX_(double PV)
  {
   double XX=iADX(NULL,PERIOD_Major,ADX_Period,PRICE_CLOSE,0,0);

   double UP=iADX(NULL,PERIOD_Major,ADX_Period,PRICE_CLOSE,1,0);
   double DW=iADX(NULL,PERIOD_Major,ADX_Period,PRICE_CLOSE,2,0);

   bool XX_=XX>UP && XX>DW;
//bool UP_=(UP>DW) && XX_;
//bool DW_=(UP<DW) && XX_;

   bool UP_=(UP>DW);
   bool DW_=(UP<DW);

   if(UP_ && pCCI_(10)>0)
     {
      return PV;
     }
   else if(DW_ && pCCI_(10)<0)
     {
      return PV*(-1);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pRSI(double PV)
  {
   double var=iRSI(NULL,PERIOD_Major,RSI_Period,PRICE_CLOSE,0);
   if(var<RSI_UP && var>RSI_DW)
     {
      if(var>45)
        {
         return PV;
        }
      else if(var<55)
        {
         return PV*(-1);
        }
      else
        {
         return 0;
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pPower(double PV)
  {
   double UP_Power=(iBullsPower(NULL,30,13,PRICE_CLOSE,0)+iBullsPower(NULL,15,13,PRICE_CLOSE,0))/2;
   double DW_Power=(iBearsPower(NULL,30,13,PRICE_CLOSE,0)+iBearsPower(NULL,15,13,PRICE_CLOSE,0))/2;
   double UD_Power=(UP_Power+DW_Power);

   UD_Power=NormalizeDouble(UD_Power*MathPow(10,Digits)*1.236,0);
   UP_Power=NormalizeDouble(UP_Power*MathPow(10,Digits)*1.236,0);
   DW_Power=NormalizeDouble(DW_Power*MathPow(10,Digits)*1.236,0);


   bool UPEntryCondition_Power=DW_Power>50 && DW_Power<1000 && UP_Power>50;
   bool DWEntryCondition_Power=UP_Power<-50 && UP_Power>-1000 && DW_Power<-50;

   if(UPEntryCondition_Power)
     {
      return PV;
     }
   else if(DWEntryCondition_Power)
     {
      return PV*(-1);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pCustom_tampc_wonders(double PV)
  {
   double UP=iCustom(NULL,PERIOD_Major,"indicator-FormFB/tampc_wonders",1,0);
   double DW=iCustom(NULL,PERIOD_Major,"indicator-FormFB/tampc_wonders",0,0);

   bool UP_=UP<2147483647;
   bool DW_=DW<2147483647;
   if(UP_)
     {
      return PV;
     }
   else if(DW_)
     {
      return PV*(-1);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pPriceAction_Hub(double PV,double c)
  {
   int i=1;

   double PinBarU=0,PinBarD=0;
   double InBarU=0,InBarD=0;
   double EnBarU=0,EnBarD=0;
   double UP=0,DW=0;

/* switch(pPriceAction_PinBar(i))
     {
      case 2:PinBarU= 1; PinBarD=0;break;
      case 4:PinBarU= 2; PinBarD=0;break;
      case 6:PinBarU= 3; PinBarD=0;break;
      case 8:PinBarU= 4; PinBarD=0;break;

      case 1:PinBarD= 1; PinBarU= 0;break;
      case 3:PinBarD= 2; PinBarU= 0;break;
      case 5:PinBarD= 3; PinBarU= 0;break;
      case 7:PinBarD= 4; PinBarU= 0;break;
      case -1:
        {
         PinBarU=0;
         PinBarD=0;
        }
     }*/

   switch(pPriceAction_InBar(i))
     {
      case 2:InBarU= 1;InBarD= 0;break;
      case 4:InBarU= 2;InBarD= 0;break;
      case 6:InBarU= 3;InBarD= 0;break;
      case 8:InBarU= 4;InBarD= 0;break;

      case 1:InBarD= 1;InBarU= 0;break;
      case 3:InBarD= 2;InBarU= 0;break;
      case 5:InBarD= 3;InBarU= 0;break;
      case 7:InBarD= 4;InBarU= 0;break;
      case -1:
        {
         InBarU=0;
         InBarD=0;
        }
     }

   switch(pPriceAction_EnBar(i))
     {
      case 2:EnBarU= 1;EnBarD= 0;break;
      case 4:EnBarU= 2;EnBarD= 0;break;
      case 6:EnBarU= 3;EnBarD= 0;break;
      case 8:EnBarU= 4;EnBarD= 0;break;

      case 1:EnBarD= 1;EnBarU= 0;break;
      case 3:EnBarD= 2;EnBarU= 0;break;
      case 5:EnBarD= 3;EnBarU= 0;break;
      case 7:EnBarD= 4;EnBarU= 0;break;
      case -1:
        {
         EnBarU=0;
         EnBarD=0;
        }
     }
//---
   UP=PinBarU+InBarU+EnBarU;
   DW=PinBarD+InBarD+EnBarD;
//---
/*_LabelSet("Text_PA",CORNER_LEFT_LOWER,400,35,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+
             "# PV PinBar "+PinBarU+" Inside "+InBarU+" Eng "+EnBarU+"","");
   _LabelSet("Text_PA2",CORNER_LEFT_LOWER,400,20,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+
             "# PV PinBar "+PinBarD+" Inside "+InBarD+" Eng "+EnBarD+"","");*/
//---

   if(UP>=c)
     {
      return PV*UP;
     }
   else if(DW>=c)
     {
      return PV*(-1)*DW;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int pPriceAction_PinBar(int i)
  {
   double Nose,Body,Wick;

   double Open0=iOpen(NULL,0,i);
   double Close0=iClose(NULL,0,i);

   double High0=iHigh(NULL,0,i);
   double High1=iHigh(NULL,0,i+1);
   double High2=iHigh(NULL,0,i+2);
   double High3=iHigh(NULL,0,i+3);
   double High4=iHigh(NULL,0,i+4);

   double Low0=iLow(NULL,0,i);
   double Low1=iLow(NULL,0,i+1);
   double Low2=iLow(NULL,0,i+2);
   double Low3=iLow(NULL,0,i+3);
   double Low4=iLow(NULL,0,i+4);

//-------------
// UpCandle
//-------------
   if((High0-Open0)>(High0-Close0))
     {
      Nose = High0-Close0;
      Body = Close0-Open0;
      Wick = Open0-Low0;

      // HangMan
      if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3 && High0>High4)
         return(8);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3)
         return(6);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2)
         return(4);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1)
         return(2);


      // Hammer
      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3 && Low0<Low4)
         return(8);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3)
         return(6);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2)
         return(4);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1)
         return(2);

      else
         return(-1);
     }

//-------------
// DownCandle
//-------------
   else if((High0-Open0)<(High0-Close0))
     {
      Nose = High0-Open0;
      Body = Open0-Close0;
      Wick = Close0-Low0;

      // HangMan
      if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3 && High0>High4)
         return(7);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2
         && High0>High3)
         return(5);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1 && High0>High2)
         return(3);

      else if(Nose>(Wick*2) && Nose>(Body*2)
         && High0>High1)
         return(1);


      // Hammer
      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3 && Low0<Low4)
         return(7);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2
         && Low0<Low3)
         return(5);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1 && Low0<Low2)
         return(3);

      else if(Wick>(Nose*2) && Wick>(Body*2)
         && Low0<Low1)
         return(1);

      else
         return(-1);
     }
   else
      return(-1);
  }
//+------------------------------------------------------------------+
//| Inside Bar function                                              |
//+------------------------------------------------------------------+
int pPriceAction_InBar(int i)
  {
   double Open0=iOpen(NULL,0,i);
   double Close0=iClose(NULL,0,i);

   double High0=iHigh(NULL,0,i);
   double High1=iHigh(NULL,0,i+1);
   double High2=iHigh(NULL,0,i+2);
   double High3=iHigh(NULL,0,i+3);
   double High4=iHigh(NULL,0,i+4);

   double Low0=iLow(NULL,0,i);
   double Low1=iLow(NULL,0,i+1);
   double Low2=iLow(NULL,0,i+2);
   double Low3=iLow(NULL,0,i+3);
   double Low4=iLow(NULL,0,i+4);

//-------------
// UpCandle
//-------------
   if((High0-Open0)>(High0-Close0))
     {
      if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2
         && High0<=High3 && Low0>=Low3
         && High0<=High4 && Low0>=Low4)
         return(8);

      else if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2
                   && High0<=High3  &&  Low0>=Low3)
                   return(6);

      else if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2)
         return(4);

      else if(High0<=High1 && Low0>=Low1)
                     return(2);

      else
         return(-1);
     }

//-------------
// DownCandle
//-------------
   else if((High0-Open0)<(High0-Close0))
     {
      if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2
         && High0<=High3 && Low0>=Low3
         && High0<=High4 && Low0>=Low4) return(7);

      else if(High0<=High1  &&  Low0>=Low1
         &&  High0<=High2 && Low0>=Low2
                    && High0<=High3 && Low0>=Low3) return(5);

      else if(High0<=High1 && Low0>=Low1
         && High0<=High2 && Low0>=Low2) return(3);

      else if(High0<=High1 && Low0>=Low1) return(1);

      else return(-1);
     }

   else return(-1);
  }
//+------------------------------------------------------------------+
//| Engulfing Bar function                                           |
//+------------------------------------------------------------------+
int pPriceAction_EnBar(int i)
  {
   double Open0=iOpen(NULL,0,i);
   double Close0=iClose(NULL,0,i);

   double High0=iHigh(NULL,0,i);
   double High1=iHigh(NULL,0,i+1);
   double High2=iHigh(NULL,0,i+2);
   double High3=iHigh(NULL,0,i+3);
   double High4=iHigh(NULL,0,i+4);

   double Low0=iLow(NULL,0,i);
   double Low1=iLow(NULL,0,i+1);
   double Low2=iLow(NULL,0,i+2);
   double Low3=iLow(NULL,0,i+3);
   double Low4=iLow(NULL,0,i+4);

//-------------
// UpCandle
//-------------
   if((High0-Open0)>(High0-Close0))
     {
      if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2
         && High0>=High3 && Low0<=Low3
         && High0>=High4 && Low0<=Low4) return(8);

      else if(High0>=High1  &&  Low0<=Low1
         &&  High0>=High2 && Low0<=Low2
                    && High0>=High3 && Low0<=Low3) return(6);

      else if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2) return(4);

      else if(High0>=High1 && Low0<=Low1) return(2);

      else return(-1);
     }

//-------------
// DownCandle
//-------------
   else if((High0-Open0)<(High0-Close0))
     {
      if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2
         && High0>=High3 && Low0<=Low3
         && High0>=High4 && Low0<=Low4) return(7);

      else if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2
                   && High0>=High3 && Low0<=Low3) return(5);

      else if(High0>=High1 && Low0<=Low1
         && High0>=High2 && Low0<=Low2) return(3);

      else if(High0>=High1 && Low0<=Low1) return(1);

      else return(-1);
     }

   else return(-1);
  }
int Open_ValIKH_1=5;//Open_ValIKH_1 0-9
int Open_ValIKH_2=25;//Open_ValIKH_2 0-26
int Open_ValIKH_3=50;//Open_ValIKH_3 50-104
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pIKH_Chikou(double PV)
  {

   int IKH_PERIOD_1=PERIOD_Major,IKH_PERIOD_2=PERIOD_Major;
   double IKH_Chikou/*Yelow*/=iIchimoku(NULL,IKH_PERIOD_1,Open_ValIKH_1,Open_ValIKH_2,Open_ValIKH_3,MODE_CHIKOUSPAN,26);
   double IKH_Tenkan/*Red__*/=iIchimoku(NULL,IKH_PERIOD_1,Open_ValIKH_1,Open_ValIKH_2,Open_ValIKH_3,MODE_TENKANSEN,0);
   double IKH_Kijun_/*Blue_*/=iIchimoku(NULL,IKH_PERIOD_1,Open_ValIKH_1,Open_ValIKH_2,Open_ValIKH_3,MODE_KIJUNSEN,0);

   double IKH_CloudUP/*Blue_*/=iIchimoku(NULL,IKH_PERIOD_2,Open_ValIKH_1,Open_ValIKH_2,Open_ValIKH_3,MODE_SENKOUSPANA,-26);
   double IKH_CloudDW/*Red__*/=iIchimoku(NULL,IKH_PERIOD_2,Open_ValIKH_1,Open_ValIKH_2,Open_ValIKH_3,MODE_SENKOUSPANB,-26);

   bool IKH_StatusDIR1=pIKH_getChikouStatus(IKH_Chikou);

   bool IKH_StatusDIR2=true;
   if(IKH_Tenkan<IKH_Kijun_)IKH_StatusDIR2=false;

   bool IKH_StatusDIR3=true;
   if(IKH_CloudUP<IKH_CloudDW)IKH_StatusDIR3=false;

   if(IKH_StatusDIR2 && IKH_StatusDIR3)
     {
      return PV;
     }
   else if(!IKH_StatusDIR2 && !IKH_StatusDIR3)
     {
      return PV*(-1);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int pIKH_getChikouStatus(double _IKH_Chikou)
  {
   int r=0;
   double vOpen=iOpen(NULL,PERIOD_Major,26);
   double vClose=iClose(NULL,PERIOD_Major,26);
   if(_IKH_Chikou<vOpen && 
      _IKH_Chikou<vClose && //Stand
      vOpen<vClose//is barUP
      )
     {
      r=1;
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pMomentum(double PV)
  {
   double v=iMomentum(NULL,PERIOD_Major,7,PRICE_WEIGHTED,0);
   double c=0.3;
   if(v<(100-c))
     {
      return PV;
     }
   else if(v>(100+c))
     {
      return PV*(-1);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iStochastic_(double PV)
  {
   double v=iStochastic(NULL,PERIOD_Major,5,3,3,MODE_EMA,0,MODE_MAIN,0);
   double c=15;
   if(v<(80-c))
     {
      return PV;
     }
   else if(v>(20+c))
     {
      return PV*(-1);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pCCI_(double PV)
  {
   double v=iCCI(Symbol(),PERIOD_Major,14,PRICE_TYPICAL,0);
   double c=55;
   if(v<(0+c) && v>0)
     {
      return PV;
     }
   else if(v>(0-c) && v<0)
     {
      return PV*(-1);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Account_Balance_()
  {
   return AccountInfoDouble(ACCOUNT_BALANCE);
   if(IsTesting())
     {
      return Current_BALANCE_Test;
     }
   else
     {
      return AccountInfoDouble(ACCOUNT_BALANCE);
     }
   return NULL;
  }
double SumSupporter;
//DiffZeroPriceBuy
double DZP_Buy,DZP_Sell;
double DZP_BuyFollow,DZP_SellFollow;

double OrderStopLossBuy=0,OrderStopLossSell=0;
double OrderStopLossFollowBuy=0,OrderStopLossFollowSell=0;

double OrderStopLossBuy_Merge=0,OrderStopLossSell_Merge=0;

double OrderPointBuy=0,OrderPointSell=0;
double OrderPointFollowBuy=0,OrderPointFollowSell=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __OrderChkTP(string v,int cnt,int pin)
  {
//_getOrderCNT_Sum_AtiveHub();
//   _LabelSet("Text_MM0",10,100,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(iSAR(Symbol(),0,0.009,0.2,0)-Bid,Digits),"CNT[DiffPrice/DiffSL | UseTrailing]");

   int _MagicNumber=pin;
   double _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);

   int Direct=-1;
   string TestLoop;
   double Point_=CalculatePrice_Group_(v,pin);
   setOrderPoint(pin,Point_);

//---
   string Tooltip=v;
   if(pin==4 || pin==5)
      Tooltip+="Follow";
//---

   color _clrPoint=clrWhite,_clrSL=clrWhite;
   if(v=="Buy")
     {
      _clrPoint=clrRoyalBlue;
      _clrSL=clrLightSkyBlue;
     }
   else
     {
      _clrPoint=clrTomato;
      _clrSL=clrLightPink;
     }
   double DZP=0;
   double Trailing=-1,TrailingFollow=-1;;
   double SL=-1,SL2=-1,Diff=0,DiffSL=0;

   int _MagicNumber2=-1;
   int Direct2=-1;

//+------------------------------------------------------------------+
   bool CHK__Merge=false;

/*   double Point_Buy,Point_Sell;
   double LotBuy,LotSell;
   double Point_Merge=-1;

   
if(cntOrderFollowBuy>0 && cntOrderFollowSell>0)
     {
      //+------------------------------------------------------------------+
      Point_Buy=_CalculatePrice_Group("Buy",_MagicEncrypt(4));
      LotBuy=SumLot;

      Point_Sell=_CalculatePrice_Group("Sell",_MagicEncrypt(5));
      LotSell=SumLot;
      //+------------------------------------------------------------------+
      Point_Merge=_CalculatePrice_Merge(Point_Buy,LotBuy,Point_Sell,LotSell);
      //SL=Point_Merge;
      //SL2=SL-_SPREAD;

      _LabelSet("Text_SumLot_1",10,120,clrRed,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#P1-B: "+cD(Point_Buy,Digits)+" Lot: "+cD(LotBuy,2),"");
      _LabelSet("Text_SumLot_2",10,100,clrRed,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#P2-S: "+cD(Point_Sell,Digits)+" Lot: "+cD(LotSell,2),"");
      //merge

      _LabelSet("Text_SumLot_3",10,80,clrMagenta,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#"+cD(Point_Merge,Digits),"");
      HLineCreate_(0,"Point_Merge",0,Point_Merge,clrMagenta,0,1,false,true,false,0);
      //---

      Trailing=200/MathPow(10,Digits);

      if(LotBuy==LotSell && Point_Buy<Point_Sell)
        {
        Trailing=MarketInfo(Symbol(),14)/MathPow(10,Digits);
         double Ref=Bid+((Ask-Bid)/2);
         Diff=Ref-Point_Merge;
         TestLoop="== B: "+Point_Buy+" S: "+Point_Sell;
         if(Diff>=Trailing)//Point_Buy   Point_Sell
           {
            CHK__Merge=true;
            if((OrderStopLossBuy_Merge<Ref-Trailing || OrderStopLossBuy_Merge==0))
              {
               OrderStopLossBuy_Merge=Ref-Trailing;
               SL=OrderStopLossBuy_Merge;
               SL2=SL+_SPREAD;

               TestLoop+="=Buy";
              }

           }
         if(Diff<=(Trailing*(-1)))
           {
            CHK__Merge=true;
            if((OrderStopLossSell_Merge>Ref+Trailing || OrderStopLossSell_Merge==0))
              {
               OrderStopLossSell_Merge=Ref+Trailing;
               SL=OrderStopLossSell_Merge;
               SL2=SL-_SPREAD;

               TestLoop+="=Sell";
              }

           }
        }
      else
        {
         if(_PriceMin__FollowBuy<_PriceMin_FollowSell)
           {
            Diff=Bid-Point_Merge;
            TestLoop="*Buy";
            if(Diff>=Trailing)
              {
               CHK__Merge=true;
               if((OrderStopLossBuy_Merge<Bid-Trailing || OrderStopLossBuy_Merge==0))
                 {
                  OrderStopLossBuy_Merge=Bid-Trailing;
                  SL=OrderStopLossBuy_Merge;
                  SL2=SL+_SPREAD;

                 }

              }
           }
         else if(_PriceMax_FollowSell>_PriceMax__FollowBuy)
           {
            Diff=Point_Merge-Ask;
            TestLoop="*Sell";
            if(Diff>=Trailing)
              {
               CHK__Merge=true;
               if((OrderStopLossSell_Merge>Ask+Trailing || OrderStopLossSell_Merge==0))
                 {

                  OrderStopLossSell_Merge=Ask+Trailing;
                  SL=OrderStopLossSell_Merge;
                  SL2=SL-_SPREAD;

                 }

              }
           }
        }
     }
   _LabelSet("Text_Diff_Merge",500,50,clrRed,"Franklin Gothic Medium Cond",15,cI(__LINE__)+"#D_Merge: "+cD(Diff*MathPow(10,Digits),0)+" : "+cD(OrderStopLossBuy_Merge,Digits)+TestLoop+"  "+CHK__Merge,"");
*/
//+------------------------------------------------------------------+
   if(!CHK__Merge)
     {

      //HLineDelete(0,"Point_Merge");
      if("Buy"==v)
        {
         Direct=OP_BUY;
         Diff=Bid-Point_;
         //---
         if(pin==1)
           {
            DZP_Buy=Diff*MathPow(10,Digits);
            DZP=DZP_Buy;
           }
         else
           {
            DZP_BuyFollow=Diff*MathPow(10,Digits);
            DZP=DZP_BuyFollow;
           }

         Trailing=Calculate_Trailing_(cnt,Diff);
         // TrailingFollow=_CalculateTrailing(cnt,Diff);
         TestLoop="";
         //TrailingStart=Trailing;
         //if((Diff>=TrailingStart && cnt==1) || (Diff>=Trailing && cnt>1))
         if(Diff>=Trailing)
           {
            TestLoop="*";
            if((OrderStopLossBuy<Bid-Trailing || OrderStopLossBuy==0) && pin==1)
              {
               OrderStopLossBuy=Bid-Trailing;
               SL=OrderStopLossBuy;

               HLineCreate_(0,"LINE_Save"+cI(pin),"SL"+Tooltip+" \n"+cD(SL,Digits),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderBuy>0 && cntOrderFollowSell>0 && sumOrderBuy+sumOrderFollowSell>SumSupporter)
                 {
                  _MagicNumber2=5;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
               else if(cntOrderBuy>0 && cntOrderSell>0 && sumOrderBuy+sumOrderSell>SumSupporter)
                 {
                  _MagicNumber2=2;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
              }
            if((OrderStopLossFollowBuy<Bid-Trailing || OrderStopLossFollowBuy==0) && pin==4)
              {
               OrderStopLossFollowBuy=Bid-Trailing;
               SL=OrderStopLossFollowBuy;

               HLineCreate_(0,"LINE_Save"+cI(pin),"SL"+Tooltip+" \n"+cD(SL,Digits),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderFollowBuy>0 && cntOrderSell>0 && sumOrderFollowBuy>sumOrderSell>=SumSupporter)
                 {
                  _MagicNumber2=2;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
               else if(cntOrderFollowBuy>0 && cntOrderFollowSell>0 && sumOrderFollowBuy+sumOrderFollowSell>=SumSupporter)
                 {

                  _MagicNumber2=5;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
              }
            //HLineCreate_(0,"LINE_SL"+c(mn),0,SL,clrPaleGreen,0,1,true,true,false,0);
           }
         if(OrderStopLossBuy>0)
            DiffSL=(Bid-OrderStopLossBuy)*MathPow(10,Digits);
         if(OrderStopLossFollowBuy>0)
            DiffSL=(Bid-OrderStopLossFollowBuy)*MathPow(10,Digits);

         if(pin==1)
            _LabelSet("Text_MM1",CORNER_LEFT_LOWER,10,65,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineBuy)+"|"+cI(cntOrderBuyMax)+" Buy ["+cD(DZP_Buy,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM2",CORNER_LEFT_LOWER,10,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineBuyF)+"|"+cI(cntOrderFollowBuyMax)+" BuyF ["+cD(DZP_BuyFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

         //---
         string chk_Text_MSL="Off";
         if(
            (OrderStopLossBuy>0 && OrderStopLossFollowBuy>0) && 
            (OrderStopLossBuy>OrderPointBuy && OrderStopLossBuy>OrderPointFollowBuy) && 
            (OrderStopLossFollowBuy>OrderPointBuy && OrderStopLossFollowBuy>OrderPointFollowBuy)
            )
           {
            chk_Text_MSL="On";
            if(OrderStopLossBuy>=OrderStopLossFollowBuy)
              {
               OrderStopLossFollowBuy=OrderStopLossBuy;
               SL=OrderStopLossFollowBuy;

               HLineCreate_(0,"LINE_SaveLink_Buy","SL BuyLink \n"+cD(SL,Digits),0,SL,clrLime,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=1;
               _MagicNumber2=4;
               Direct=OP_BUY;
               Direct2=OP_BUY;
              }
            if(OrderStopLossFollowBuy>=OrderStopLossBuy)
              {
               OrderStopLossBuy=OrderStopLossFollowBuy;
               SL=OrderStopLossBuy;

               HLineCreate_(0,"LINE_SaveLink_Buy","SL SellLink \n"+cD(SL,Digits),0,SL,clrLime,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=1;
               _MagicNumber2=4;
               Direct=OP_BUY;
               Direct2=OP_BUY;
              }

           }
         //_LabelSet("Text_MSL_B",200,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# SL Buy : "+cD(OrderStopLossBuy,Digits)+" | "+cD(OrderStopLossFollowBuy,Digits)+"   "+chk_Text_MSL,"");
         //---
        }
      else if("Sell"==v)
        {
         Direct=OP_SELL;
         Diff=(Point_-Ask);
         //---
         if(pin==2)
           {
            DZP_Sell=Diff*MathPow(10,Digits);
            DZP=DZP_Sell;
           }
         else
           {
            DZP_SellFollow=Diff*MathPow(10,Digits);
            DZP=DZP_SellFollow;
           }

         Trailing=Calculate_Trailing_(cnt,Diff);
         //TrailingFollow=_CalculateTrailing(cnt,Diff);
         TestLoop="";
         //TrailingStart=Trailing;
         //if((Diff>=TrailingStart && cnt==1) || (Diff>=Trailing && cnt>1))
         if(Diff>=Trailing)
           {
            TestLoop="*";
            if((OrderStopLossSell>Ask+Trailing || OrderStopLossSell==0) && pin==2)
              {

               OrderStopLossSell=Ask+Trailing;
               SL=OrderStopLossSell;

               HLineCreate_(0,"LINE_Save"+cI(pin),"LINE_Save"+cI(pin),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderFollowBuy>0 && cntOrderSell>0 && sumOrderFollowBuy+sumOrderSell>SumSupporter)
                 {
                  _MagicNumber2=4;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
               else if(cntOrderBuy>0 && cntOrderSell>0 && sumOrderBuy+sumOrderSell>SumSupporter)
                 {
                  _MagicNumber2=1;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
              }
            if((OrderStopLossFollowSell>Ask+Trailing || OrderStopLossFollowSell==0) && pin==5)
              {

               OrderStopLossFollowSell=Ask+Trailing;
               SL=OrderStopLossFollowSell;

               HLineCreate_(0,"LINE_Save"+cI(pin),"LINE_Save"+cI(pin),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderBuy>0 && cntOrderFollowSell>0 && sumOrderBuy+sumOrderFollowSell>SumSupporter)
                 {
                  _MagicNumber2=1;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
               else if(cntOrderFollowBuy>0 && cntOrderFollowSell>0 && sumOrderFollowBuy+sumOrderFollowSell>SumSupporter)
                 {
                  _MagicNumber2=4;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }

              }
            //HLineCreate_(0,"LINE_SL"+c(mn),0,SL,clrTomato,0,1,true,true,false,0);
           }

         if(OrderStopLossSell>0)
            DiffSL=(OrderStopLossSell-Ask)*MathPow(10,Digits);
         if(OrderStopLossFollowSell>0)
            DiffSL=(OrderStopLossFollowSell-Ask)*MathPow(10,Digits);

         if(pin==2)
            _LabelSet("Text_MM3",CORNER_LEFT_LOWER,10,35,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineSell)+"|"+cI(cntOrderSellMax)+" Sell ["+cD(DZP_Sell,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM4",CORNER_LEFT_LOWER,10,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineSellF)+"|"+cI(cntOrderFollowSellMax)+" SellF ["+cD(DZP_SellFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

         string chk_Text_MSL="Off";
         if(
            (OrderStopLossSell>0 && OrderStopLossFollowSell>0) && 
            (OrderStopLossSell<OrderPointSell && OrderStopLossSell<OrderPointFollowSell) && 
            (OrderStopLossFollowSell<OrderPointSell && OrderStopLossFollowSell<OrderPointFollowSell)
            )
           {
            chk_Text_MSL="On";
            if(OrderStopLossSell<=OrderStopLossFollowSell)
              {
               OrderStopLossFollowSell=OrderStopLossSell;
               SL=OrderStopLossFollowSell;

               HLineCreate_(0,"LINE_SaveLink_SEll","LINE_SaveLink_SEll1",0,SL,clrMagenta,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=2;
               _MagicNumber2=5;
               Direct=OP_SELL;
               Direct2=OP_SELL;
              }
            if(OrderStopLossFollowSell<=OrderStopLossSell)
              {
               OrderStopLossSell=OrderStopLossFollowSell;
               SL=OrderStopLossSell;

               HLineCreate_(0,"LINE_SaveLink_SEll","LINE_SaveLink_SEll2",0,SL,clrMagenta,0,1,0,true,false,0);
               SL2=SL;
               _MagicNumber=2;
               _MagicNumber2=5;
               Direct=OP_SELL;
               Direct2=OP_SELL;
              }
           }
         //_LabelSet("Text_MSL",200,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# SL Sell : "+string(OrderStopLossSell)+" | "+string(OrderStopLossFollowSell)+"   "+chk_Text_MSL,"");

         //---
        }
      //---
      HLineCreate_(0,"LINE_Point"+cI(pin),Tooltip+" | "+cD(DZP,0)+"p \n"+cD(Point_,Digits),0,Point_,_clrPoint,0,1,0,true,false,0);
      //---
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      _MagicNumber=4;
      Direct=OP_BUY;
      _MagicNumber2=5;
      Direct2=OP_SELL;
     }

   bool CHK=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(SL>0)
     {
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         _MagicDecode(MGN,OrderMagicNumber());
         if(OrderMagic_Key==MGN &&
            OrderMagic_Pin==pin &&
            OrderSymbol()==Symbol())
           {
            if(OrderStopLoss()==SL)
               CHK=true;
            else
               CHK=false;
           }
        }

      if(!CHK)
        {
         _OrderModifyForTrailing(SL,_MagicNumber,int(Direct));
         if(SL2>0)
           {
            SL2=NormalizeDouble(SL2,Digits);
            _OrderModifyForTrailing(SL2,_MagicNumber2,int(Direct2));
           }
        }
     }
  }
//+------------------------------------------------------------------+
int cntOrderBuyMax,cntOrderSellMax;
int cntOrderFollowBuyMax,cntOrderFollowSellMax;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __Hub_Order_CNTSum()
  {
   cntOrderBuy=int(_getOrderCNT_Ative(MGN,1,-1,"Cnt"));
   cntOrderSell=int(_getOrderCNT_Ative(MGN,2,-1,"Cnt"));

   cntOrderFollowBuy=int(_getOrderCNT_Ative(MGN,4,-1,"Cnt"));
   cntOrderFollowSell=int(_getOrderCNT_Ative(MGN,5,-1,"Cnt"));
//---
   if(cntOrderBuy>cntOrderBuyMax)cntOrderBuyMax=cntOrderBuy;
   if(cntOrderSell>cntOrderSellMax)cntOrderSellMax=cntOrderSell;

   if(cntOrderFollowBuy>cntOrderFollowBuyMax)cntOrderFollowBuyMax=cntOrderFollowBuy;
   if(cntOrderFollowSell>cntOrderFollowSellMax)cntOrderFollowSellMax=cntOrderFollowSell;
//---
   sumOrderBuy=_getOrderCNT_Ative(MGN,1,-1,"Sum");
   sumOrderSell=_getOrderCNT_Ative(MGN,2,-1,"Sum");

   sumOrderFollowBuy=_getOrderCNT_Ative(MGN,4,-1,"Sum");
   sumOrderFollowSell=_getOrderCNT_Ative(MGN,5,-1,"Sum");
//---
   cntOrder=cntOrderBuy+cntOrderSell;
   cntOrder+=cntOrderFollowBuy+cntOrderFollowSell;
//---
   sumOrder=sumOrderBuy+sumOrderSell;
   sumOrder+=sumOrderFollowBuy+sumOrderFollowSell;

   sumOrder=NormalizeDouble(sumOrder,2);
//---
   Current_BALANCE=Account_Balance_();
   if(Current_BALANCE<=0)Current_BALANCE=1;
//+------------------------------------------------------------------+
//if(((sumOrder/Current_BALANCE)*100)>=BetPer*3)

   SumSupporter=NormalizeDouble((BetCoin_*cntOrder)/2,2);
   if(sumOrder>SumSupporter || (cntOrder>=BetCnt__*0.45 && sumOrder>=1))
     {
      orderCloseActive_(1);
      orderCloseActive_(2);
      orderCloseActive_(4);
      orderCloseActive_(5);
     }
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __Hub_OrderTP()
  {
   if(cntOrderBuy==0)
     {
      OrderStopLossBuy=0;
      ConfirmBuy=0;
      ATR_Buy=0;

      //MagazineBuyF=CntPerCase;

      HLineDelete(0,"LINE_Point1");
      HLineDelete(0,"LINE_Save1");
      HLineDelete(0,"LINE_SL1");

      HLineDelete(0,"LINE_ATR1");

      HLineDelete(0,"Text_MM1");
     }
   if(cntOrderSell==0)
     {
      OrderStopLossSell=0;
      ConfirmSell=0;
      ATR_Sell=0;

      //MagazineSellF=CntPerCase;

      HLineDelete(0,"LINE_Point2");
      HLineDelete(0,"LINE_Save2");
      HLineDelete(0,"LINE_SL2");

      HLineDelete(0,"LINE_ATR2");

      HLineDelete(0,"Text_MM3");
     }
   if(cntOrderFollowBuy==0)
     {
      OrderStopLossFollowBuy=0;
      ConfirmBuyFollow=0;
      ATR_BuyF=0;

      //MagazineBuy=CntPerCase;

      HLineDelete(0,"LINE_Point4");
      HLineDelete(0,"LINE_Save4");
      HLineDelete(0,"LINE_SL4");

      HLineDelete(0,"LINE_ATR4");

      HLineDelete(0,"Text_MM2");
     }
   if(cntOrderFollowSell==0)
     {
      OrderStopLossFollowSell=0;
      ConfirmSellFollow=0;
      ATR_SellF=0;

      //MagazineSell=CntPerCase;

      HLineDelete(0,"LINE_Point5");
      HLineDelete(0,"LINE_Save5");
      HLineDelete(0,"LINE_SL5");

      HLineDelete(0,"LINE_ATR5");

      HLineDelete(0,"Text_MM4");
     }
//+------------------------------------------------------------------+
   if(cntOrderBuy==0 && cntOrderFollowBuy==0)
     {
      HLineDelete(0,"LINE_SaveLink_Buy");
     }
   if(cntOrderSell==0 && cntOrderFollowSell==0)
     {
      HLineDelete(0,"LINE_SaveLink_SEll");
     }
   if(cntOrderBuy>=1)
     {
      __OrderChkTP("Buy",cntOrderBuy,1);
     }

   if(cntOrderSell>=1)
     {
      __OrderChkTP("Sell",cntOrderSell,2);
     }

   if(cntOrderFollowBuy>=1)
     {
      __OrderChkTP("Buy",cntOrderFollowBuy,4);
     }
   if(cntOrderFollowSell>=1)
     {
      __OrderChkTP("Sell",cntOrderFollowSell,5);
     }
  }
//+------------------------------------------------------------------+
double CalculatePrice_Group_(string Direction,int pin)
  {

   double
   SumProduct=0,
   SumLot=0,
   Result=0,
   A=0;

   int n=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(MGN,OrderMagicNumber());
      if(OrderMagic_Key==MGN &&
         OrderMagic_Pin==pin &&
         OrderSymbol()==Symbol())
        {
         //+------------------------------------------------------------------+
         //SumDeposit+=_ConfirmProfitCalculate(OrderType(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderCommission(),OrderSwap());
         //+------------------------------------------------------------------+
         SumProduct+=OrderLots()*OrderOpenPrice();
         SumLot+=OrderLots();
         n++;
        }
     }
//+------------------------------------------------------------------+     
//_ConfirmProfitSet(pin,SumDeposit);
//+------------------------------------------------------------------+

   if(SumLot!=0)
      A=SumProduct/SumLot;
   else
      return 1;

   double Carry,CarryMax=750;
//Carry=(n*_SPREAD)*1.236;
   Carry=(n*100);
   if(Carry>CarryMax)
     {
      Carry=CarryMax;
     }
   Carry/=MathPow(10,Digits);
//Carry=50/MathPow(10,Digits);

   if(Direction=="Buy")
      Result=A+Carry;
   else
      Result=A-Carry;

   return NormalizeDouble(Result,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setOrderPoint(int v,double s)
  {
   switch(v)
     {
      case  1:
         OrderPointBuy=s;
      case  2:
         OrderPointSell=s;
      case  4:
         OrderPointFollowBuy=s;
      case  5:
         OrderPointFollowSell=s;
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Calculate_Trailing_(int cnt,double Diff)
  {
   double Trailing=-1;

   Diff=NormalizeDouble(Diff*MathPow(10,Digits),0);

   double FiboRate[]={0,1.000,1.236,1.382,/**/1.500,1.618,1.809,2.000};
   double TraiRate[]={1,0.809,0.618,0.500,/**/0.382,0.236,0.118,0,0,0,0,0,0};

   double ATR_CU=NormalizeDouble((iATR(Symbol(),PERIOD_Major,iATR_Period,1)+iATR(Symbol(),PERIOD_Major,iATR_Period,0))/2,Digits);
   double ATR_CU_=NormalizeDouble(ATR_CU*FiboRate[4]*MathPow(10,Digits),0);

   double LevelFibo=0;
   for(int i=TraiRateStart,j=4;i<=7;i++,j++)
     {
      LevelFibo=NormalizeDouble(ATR_CU_*TraiRate[i],0);
      if(Diff<=LevelFibo)
        {
         Trailing=NormalizeDouble(LevelFibo*TraiRate[j],0);
         break;
        }
     }
//---
/*if(cnt>=3)
      Trailing=(Trailing/(cnt/2));*/

   double MinTrai_STOPLEVEL=(MarketInfo(Symbol(),MODE_STOPLEVEL)+(cnt*2))*1.5;
   if(Trailing<=MinTrai_STOPLEVEL /*&& Trailing>=0*/)
      Trailing=MinTrai_STOPLEVEL;

//P(__LINE__,__FUNCTION__,"R",Trailing);
//Trailing/=2;
   return NormalizeDouble(Trailing/MathPow(10,Digits),Digits);;

  }
//+------------------------------------------------------------------+
int MagazineBuy,MagazineSell;
int MagazineBuyF,MagazineSellF;
//+------------------------------------------------------------------+
bool _OrderModifyForTrailing(double _TP,int pin,int _OrderType)
  {
//double SumDeposit=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)
         continue;
      _MagicDecode(MGN,OrderMagicNumber());
      if(OrderMagic_Key==MGN &&
         OrderMagic_Pin==pin &&
         OrderSymbol()==Symbol())
        {
         if((_OrderType==OP_BUY && OrderStopLoss()<_TP) ||
            (_OrderType==OP_SELL && OrderStopLoss()>_TP) ||
            OrderStopLoss()==0)
           {

            if(!OrderModify(OrderTicket(),OrderOpenPrice(),_TP,0,0))//SL
              {
               sz=OrderModify(OrderTicket(),OrderOpenPrice(),0,_TP,0);//TP
              }
           }
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderSends_PV(int OP_Trade,int Case,int Cnt,double Price,double Price_SL,double Price_TP,double PV)
  {
   int Dir=-1;
   string Dirs="";
   if(OP_Trade==0 || OP_Trade==2 || OP_Trade==4)
     {
      Dir=0;
      Dirs="B";
     }
   if(OP_Trade==1 || OP_Trade==3 || OP_Trade==5)
     {
      Dir=1;
      Dirs="S";
     }
//---
   double Lot;

   Lot=CalculateLots_(Dir,PV,Case,Cnt);

   if(Lot)
     {
      int MGN_=_MagicEncrypt(MGN,Case,Cnt);
      return OrderSend(Symbol(),OP_Trade,Lot,Price,100,Price_SL,Price_TP,strEA_Name(Dirs,MGN_),MGN_,0);
     }
//---
   return -1;
  }
//+------------------------------------------------------------------+
double BetCoin_,BetCnt__,BetMagin;
double Bet_Cashflow;
int isLoan;
//---
double CalculateLots_(int OP_Dir,double PV,int nCase,int Cnt)
  {
   if(cntOrder==0)
     {
      isLoan=0;
      Current_BALANCE=Account_Balance_();

      BetMagin=Current_BALANCE;
      BetCnt__=NormalizeDouble(100/BetPer,0);
      BetCoin_=NormalizeDouble((BetMagin/100)*BetPer,2);
     }
//---
   double CONTRACT_SIZE=100000/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE);
   double CALIBER=NormalizeDouble(BetCoin_/CalculateLots_WorstPont_(OP_Dir,PV,nCase,Cnt),5);
   double l=NormalizeDouble(CALIBER*CONTRACT_SIZE,2);
   P(__LINE__,"CalculateLots","CALIBER",CALIBER,"Lots",l,5);

   if(cntOrder<BetCnt__)
     {
      return l;
     }
   double loan=NormalizeDouble(Bet_Cashflow/BetCoin_,0);
//P(__LINE__,"LotsLoan","BetWith",Bet_Cashflow,"Coin",BetCoin_,"loan",loan);
   if(loan>=1 && Bet_Cashflow>BetCoin_)
     {
      isLoan++;
      Bet_Cashflow=Bet_Cashflow-BetCoin_;

      return l;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string isLoan()
  {
   if(isLoan>0)
      return cI(isLoan);
   return "";
  }
//+------------------------------------------------------------------+
double ATR=0;
double ATR_Buy,ATR_BuyF;
double ATR_Sell,ATR_SellF;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern int WorstPont_FiboRate=0;//WorstPont_FiboRate 0-7
extern int WorstPont_ATRPeriod=3;//WorstPont_ATRPeriod 0-4

extern int WorstPont_MinATR=6;//WorstPont_MinATR 0-8
int MinATRRate[]={5000,5500,6000,6500,7000,7500,8000,8500,9000};

extern int TimeFrameVarIndex=8;//WorstPont_TimeFrameVar 0-9
int TimeFrameVar[]={0,1,5,15,30,60,240,1440,10080,43200};//9
//+---------------------------------------------------------------+
double CalculateLots_WorstPont_(int OP_Dir,double PV,int nCase,int Cnt)
  {
   double Points=0;
   double Mark=0;
//---
   if(Cnt==0 || CalculateLots_getATRCase_(nCase)==0)
     {

      ATR=(iATR(Symbol(),TimeFrameVar[TimeFrameVarIndex],WorstPont_ATRPeriod,1)+
           iATR(Symbol(),TimeFrameVar[TimeFrameVarIndex],WorstPont_ATRPeriod,0))/2;

      ATR=ATR*getFiboRate(WorstPont_FiboRate);

      double MinATR=MinATRRate[WorstPont_MinATR]/MathPow(10,Digits);
      if(ATR<MinATR)ATR=MinATR;

      if(nCase>2 || true)
        {
         if(PV<0)
            PV=PV*(-1);
         ATR=NormalizeDouble(ATR/(1+(PV/100)),Digits);
        }
      //---
      //MinATR=MinATRRate[1]/MathPow(10,Digits);
      //if(ATR<MinATR)ATR=MinATR;
      //---

      //+---------------------------------------------------------------+
      if(OP_Dir==0)
        {
         if(nCase==1)
            Mark=ATR_Buy=Ask-ATR;
         else if(nCase==4)
            Mark=ATR_BuyF=Ask-ATR;
         HLineCreate_(0,"LINE_ATR"+cI(nCase),"LINE_ATR"+cI(nCase)+" "+cD(ATR*MathPow(10,Digits),0),0,Mark,clrPurple,0,1,0,true,false,0);
        }
      else if(OP_Dir==1)
        {
         if(nCase==2)
            Mark=ATR_Sell=Bid+ATR;
         else if(nCase==5)
            Mark=ATR_SellF=Bid+ATR;
         HLineCreate_(0,"LINE_ATR"+cI(nCase),"LINE_ATR"+cI(nCase)+" "+cD(ATR*MathPow(10,Digits),0),0,Mark,clrMaroon,0,1,0,true,false,0);
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(OP_Dir==0)
     {
      if(nCase==1)
        {
         Points=Ask-ATR_Buy;

/*if(ATR_Buy>ATR_BuyF)
           {
            ATR_BuyF=ATR_Buy;
            HLineCreate_(0,"LINE_ATR"+cI(4),"LINE_ATR"+cI(4),0,ATR_BuyF,clrRed,0,1,0,true,false,0);
           }*/
        }
      else if(nCase==4)
        {
         Points=Ask-ATR_BuyF;

/* if(ATR_BuyF>ATR_Buy)
           {
            ATR_Buy=ATR_BuyF;
            HLineCreate_(0,"LINE_ATR"+cI(1),"LINE_ATR"+cI(1),0,ATR_Buy,clrRed,0,1,0,true,false,0);
           }*/
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(OP_Dir==1)
     {
      if(nCase==2)
        {
         Points=ATR_Sell-Bid;

/*if(ATR_SeLL<ATR_SeLLF)
           {
            ATR_SeLLF=ATR_SeLL;
            HLineCreate_(0,"LINE_ATR"+cI(5),"LINE_ATR"+cI(5),0,ATR_SeLLF,clrRed,0,1,0,true,false,0);
           }*/
        }
      else if(nCase==5)
        {
         Points=ATR_SellF-Bid;

/* if(ATR_SeLLF<ATR_SeLL)
           {
            ATR_SeLL=ATR_SeLLF;
            HLineCreate_(0,"LINE_ATR"+cI(2),"LINE_ATR"+cI(2),0,ATR_SeLL,clrRed,0,1,0,true,false,0);
           }*/
        }
     }

   return NormalizeDouble(Points*MathPow(10,Digits),0);
  }
//+------------------------------------------------------------------+
double CalculateLots_getATRCase_(int nCase)
  {
   double v=0;

   if(nCase==1)
      v=ATR_Buy;
   else if(nCase==4)
      v=ATR_BuyF;
   else if(nCase==2)
      v=ATR_Sell;
   else if(nCase==5)
      v=ATR_SellF;

   return v;
  }
//+------------------------------------------------------------------+
double Profit,ProfitPC_Fund,ProfitAVG_Runday,ProfitAVGPC_Fund,ProfitAVGPC_FundMN;
double ProfitCollect_MN;
string History_ProfitDay="ProfitM% ",History_ProfitCollect_MN="ProfitMN ";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __DashBorad()
  {

   Current_BALANCE=Account_Balance_();

   if(Current_BALANCE<=0) Current_BALANCE=1;

   Profit=NormalizeDouble(Current_BALANCE-Fund,2);

   if(Fund==0)Fund=1;
   ProfitPC_Fund=NormalizeDouble((Profit/Fund)*100,2);

   if(cntRunDay==0)cntRunDay=1;
   ProfitAVG_Runday=((Profit)/cntRunDay);
   if(ProfitAVG_Runday>0)
      ProfitAVGPC_Fund=(ProfitAVG_Runday/Fund)*100;
   ProfitAVGPC_FundMN=ProfitAVGPC_Fund*Stat_FocusTime;
//ProfitAVG=NormalizeDouble(ProfitAVG*35,2);

   double Current_Hold=AccountInfoDouble(ACCOUNT_PROFIT);

   getDrawDown(Current_Hold,Current_BALANCE);
   string SMS="";
   SMS+=SMS_Workday+"\n";
   SMS+="\n"+History_ProfitDay+"\n";
   SMS+=History_ProfitCollect_MN+"\n";
   SMS+="CollectProfit: "+cD(ProfitCollect_MN,2)+"\n";

   SMS+="------";
   SMS+="\nPort: "+Comma(Current_Hold,2," ")+_ActCurrency+"| "+Comma((Current_Hold/Current_BALANCE)*100,2," ")+"%";
//if(IsTesting())
//SMS+="\nBalace: "+Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ");
   SMS+="\nBalace: "+Comma(Current_BALANCE,2," ")+" | "+cD(ProfitPC_Fund,2)+"% PerDay: [ "+cD(ProfitAVGPC_Fund,4)+"%"+cD(ProfitAVGPC_FundMN,1)+" | "+cD(ProfitAVG_Runday,2)+_ActCurrency+" ]";
   SMS+="\nBetCnt: "+cI(cntOrder)+"/"+cD(BetCnt__,0)+" N"+isLoan()+" | BetMargin: "+cD(BetMagin,2)+"/"+cD(BetCoin_,2)+_ActCurrency;
   SMS+="\nCF: "+Comma(Bet_Cashflow,2," ");
   SMS+="\n";
   SMS+="\nDD: "+cD(MaxDrawDown,2)+_ActCurrency+" "+cD(MaxDrawDownPCFund,2)+"%|"+cD(MaxDrawDownPCPort,2)+"% ["+string(DateMaxDrawDown)+"]";
   SMS+="\nPT: "+cD(MaxProfit,2)+_ActCurrency;

   SMS+="\n";
   SMS+="\nATR: "+cD(ATR*MathPow(10,Digits),0);
   SMS+="\nSupporter: "+cD(SumSupporter,4);

//cnt_M0,cnt_M1,cnt_M5,cnt_M15,cnt_M30,cnt_H1,cnt_H4,cnt_D1,cnt_W1,cnt_MN;

//---
   Comment(SMS);
  }
//+------------------------------------------------------------------+
double MaxDrawDown=99999,MaxDrawDownPCFund,MaxDrawDownPCPort;
datetime DateMaxDrawDown;
double MaxProfit=-99999;
datetime DateMaxProfit;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getDrawDown(double hold,double balance)
  {
   if(hold>MaxProfit)
     {
      MaxProfit=hold;
     }
   if(hold<MaxDrawDown)
     {
      MaxDrawDown=hold;
      MaxDrawDownPCFund=NormalizeDouble((MaxDrawDown/Fund)*100,2);
      if(balance<=0)balance=1;
      MaxDrawDownPCPort=NormalizeDouble((MaxDrawDown/balance)*100,2);
      DateMaxDrawDown=TimeLocal();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderTicketClose[1];
//+------------------------------------------------------------------+

void orderCloseActive_(int v)
  {
   ArrayResize(OrderTicketClose,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(MGN,OrderMagicNumber());

      if(OrderMagic_Key==MGN && OrderMagic_Pin==v && (OrderSymbol()==Symbol()) && (OrderType()<=1))
        {
         OrderTicketClose[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(OrderTicketClose);i++)
     {
      if(OrderTicketClose[i]>0)
        {
         if(OrderSelect(OrderTicketClose[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            if(GetLastError()==0){OrderTicketClose[i]=0;}
           }
        }
     }
   ArrayResize(OrderTicketClose,1);
  }
//+------------------------------------------------------------------+
bool _OrderLookAround(string OP,int pin,int sub,double Price,int Range)
  {
//int CurrentMagic=_MagicEncrypt(v);
//_LabelSet("Text_Lookup",300,80,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(Mark2,Digits),OP);
   bool specify=false;
   if(sub<0)
      specify=true;

   double _Range=NormalizeDouble(Range/MathPow(10,Digits),Digits);

   double High_= NormalizeDouble(Price+_Range,Digits);
   double Low__= NormalizeDouble(Price-_Range,Digits);

   _LabelSet("Text_Order3",CORNER_LEFT_LOWER,370,65,clrBlack,"Franklin Gothic Medium Cond",10,"","");
   _LabelSet("Text_Order4",CORNER_LEFT_LOWER,370,80,clrBlack,"Franklin Gothic Medium Cond",10,"","");
   _LabelSet("Text_Order5",CORNER_LEFT_LOWER,370,95,clrBlack,"Franklin Gothic Medium Cond",10,"","");

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)
         continue;
      _MagicDecode(MGN,OrderMagicNumber());
      //_LabelSet("Text_Order5",370,95,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# Decode "+OrderMagic_Pin+" Sub:"+OrderMagic_Sub,"");
      if(OrderMagic_Key==MGN &&
         OrderMagic_Pin==pin &&
         (OrderMagic_Sub==sub || specify) && 
         OrderSymbol()==Symbol())
        {
         if(Low__<OrderOpenPrice() && High_>OrderOpenPrice())
           {
            //_LabelSet("Text_Order4",370,80,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# LookAround--False p "+pin+" s "+sub,"");
            return false;
           }
        }
     }
//_LabelSet("Text_Order3",370,65,clrWhite,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# LookAround End--True p "+pin+" s "+sub,"");
   return true;

  }
//+------------------------------------------------------------------+
