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

extern int MGN=7;//MagicNumber

extern double Fund=600;//Fund
extern double BetCnt__=100;
extern double Cnt__solveA=25;
extern double Cnt__solveB=15;
extern int _OrderLookAroundFirst=150;//LookAround 100-500
extern int _OrderLookAroundFirst2=75;//LookAround 100-500
extern double WorstPont=0;

extern double LimitBetCoin=10;
extern ENUM_TIMEFRAMES PERIOD_BetTime=PERIOD_H1;//BetTime
extern ENUM_TIMEFRAMES PERIOD_BetPredict=PERIOD_H4;//BetPredict

extern int _MaxBarsToScanForPatterns=1;                  //  0: display visible patterns only
                                                         //  1: display pattern of bar 1 only

extern int TraiRateStart=0;//Trail_RateStart*
extern int iATR_Period=2;//Trail_iATR_Period*
extern ENUM_TIMEFRAMES PERIOD_ATR=PERIOD_H1;

double Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
double Current_BALANCE_Test=Current_BALANCE;

string _ActCurrency=" "+AccountCurrency();
double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
double BetUse;

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

int cntOrderScap_Buy,cntOrderScap_Sell,cntOrderScap;

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
//+------------------------------------------------------------------+
   getSwap();
   ppinit();

   setTemplate();
   _StayFriday(cntRunDay,Sunday,6,0,Friday,21,0);

   CalculateLots_(0,0,0,0);

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iPV=0;
//+------------------------------------------------------------------+
void OnTick()
  {
   __OrderChkTP("Buy",cntOrderBuy,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BetOrder()
  {

//double PV=PVSum_Hub(pPower(50));

   _LabelSet("Text_MPV",CORNER_LEFT_LOWER,300,65,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# PV "+cD(iPV,5)+" BetUse"+cD(BetUse,2),"");

   if(Bet_Cashflow>ProfitAVG_Runday)
     {
      if(iPV>0 && pPower(50)>0
         && _OrderLookAround("Buy",4,1,Ask,_OrderLookAroundFirst2)
         && (!RateAll_4 || RateAll_1))
        {
         if(OrderSends_Scaping(OP_BUY,4,1,Ask,ProfitAVG_Runday))
           {
            _LabelSet("Text_MPV2",CORNER_LEFT_LOWER,300,100,clrLime,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# OP_BUY "+cD(sz,5),"");
           }
        }
      if(iPV<0 && pPower(50)<0
         && _OrderLookAround("Sell",5,1,Bid,_OrderLookAroundFirst2)
         && (!RateAll_5 || RateAll_2))
        {
         if(OrderSends_Scaping(OP_SELL,5,1,Bid,ProfitAVG_Runday))
           {
            _LabelSet("Text_MPV2",CORNER_LEFT_LOWER,300,100,clrRed,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# OP_SELL "+cD(sz,5),"");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pPower(double PV)
  {
   double UP_Power=(iBullsPower(NULL,30,13,PRICE_CLOSE,0)+iBullsPower(NULL,15,13,PRICE_CLOSE,0))/2;
   double DW_Power=(iBearsPower(NULL,30,13,PRICE_CLOSE,0)+iBearsPower(NULL,15,13,PRICE_CLOSE,0))/2;
   double XX_Power=(UP_Power+DW_Power);

   XX_Power=NormalizeDouble(XX_Power*MathPow(10,Digits)*1.382,0);

   UP_Power=NormalizeDouble(UP_Power*MathPow(10,Digits)*1.382,0);
   DW_Power=NormalizeDouble(DW_Power*MathPow(10,Digits)*1.382,0);


   bool UPEntryCondition_Power=(DW_Power>0) && (XX_Power>100) && (UP_Power>50);
   bool DWEntryCondition_Power=(UP_Power<0) && (XX_Power<-100) && (DW_Power<-50);

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
   double Point_=CalculatePrice_Group_(v,pin);//is Price
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
   else if(v=="Sell")
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
            _LabelSet("Text_MM1",CORNER_LEFT_LOWER,10,65,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineBuy)+"|"+cI(cntOrderBuyMax)+" Buy ["+cD(DZP_Buy,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+cD(OrderPointBuy,Digits)+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM2",CORNER_LEFT_LOWER,10,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineBuyF)+"|"+cI(cntOrderFollowBuyMax)+" BuyF ["+cD(DZP_BuyFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+cD(OrderPointFollowBuy,Digits)+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

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
            _LabelSet("Text_MM3",CORNER_LEFT_LOWER,10,35,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineSell)+"|"+cI(cntOrderSellMax)+" Sell ["+cD(DZP_Sell,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+cD(OrderPointSell,Digits)+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM4",CORNER_LEFT_LOWER,10,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineSellF)+"|"+cI(cntOrderFollowSellMax)+" SellF ["+cD(DZP_SellFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+cD(OrderPointFollowSell,Digits)+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//OrderScap
/* if(BetUse>0)
     {*/
   cntOrderScap_Buy=int(_getOrderCNT_Ative(MGN,4,1,"Cnt"));
   cntOrderScap_Sell=int(_getOrderCNT_Ative(MGN,5,1,"Cnt"));

   cntOrderScap=cntOrderScap_Buy+cntOrderScap_Sell;
/*}*/

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
bool RateAll_1,RateAll_2,RateAll_4,RateAll_5;
bool FlagSet0_1,FlagSet0_2,FlagSet0_4,FlagSet0_5;
//+------------------------------------------------------------------+
//|                                                                  |
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

   double Carry,CarryMax=100;
//Carry=(n*_SPREAD)*1.236;
   Carry=(n*20);
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
        {
         OrderPointBuy=s;
         break;
        }
      case  2:
        {
         OrderPointSell=s;
         break;
        }
      case  4:
        {
         OrderPointFollowBuy=s;
         break;
        }
      case  5:
        {
         OrderPointFollowSell=s;
         break;
        }
      default:
        {
         break;
        }
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

   double ATR_CU=NormalizeDouble((iATR(Symbol(),PERIOD_ATR,iATR_Period,1)+iATR(Symbol(),PERIOD_ATR,iATR_Period,0))/2,Digits);
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
   Trailing=200;
   return NormalizeDouble(Trailing/MathPow(10,Digits),Digits);;

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
            (_OrderType==3) ||
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
int OrderSends_0(int OP_Trade,int Case,int Cnt,double Price,double Price_SL,double Price_TP,double LotsRate)
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

   Lot=NormalizeDouble(CalculateLots_(Dir,Price,Case,Cnt)*LotsRate,2);

   if(Lot)
     {
      int MGN_=_MagicEncrypt(MGN,Case,Cnt);
      return OrderSend(Symbol(),OP_Trade,Lot,Price,100,Price_SL,Price_TP,strEA_Name(Dirs,MGN_),MGN_,0);
     }
//---
   return -1;
  }
//+------------------------------------------------------------------+
double BetCoin_,BetMagin;
double Bet_Cashflow;
int isLoan;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//---
double CalculateLots_(int OP_Dir,double PV,int nCase,int Cnt)
  {
//if(cntOrder==0)
   if(/*OP_Dir==0 &&*/ cntOrder==0)
     {
      isLoan=0;
      Current_BALANCE=Account_Balance_();
      if(BetMagin<=Fund*2)
        {
         BetMagin=Current_BALANCE;
         BetCoin_=NormalizeDouble(BetMagin/BetCnt__,2);
        }
     }
//---
   if(nCase>0)
     {
      double CONTRACT_SIZE=100000/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE);
      double CALIBER=NormalizeDouble(BetCoin_/CalculateLots_WorstPont_(OP_Dir,PV,nCase,Cnt),5);
      double l=NormalizeDouble(CALIBER*CONTRACT_SIZE,2);
      //   P(__LINE__,"CalculateLots","CALIBER",CALIBER,"Lots",l,5);

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateLots_WorstPont_(int OP_Dir,double PV,int nCase,int Cnt)
  {
   double Points=1;
   double Mark=0;
//---
   if(Cnt==0 || CalculateLots_getATRCase_(nCase)==0)
     {
      if(WorstPont==0)
        {
         ATR=(iATR(Symbol(),PERIOD_MN1,3,1)+iATR(Symbol(),PERIOD_MN1,3,0))/2;
         ATR=ATR*2;
        }
      else
        {
         ATR=WorstPont/MathPow(10,Digits);
        }

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
//|                                                                  |
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
   SMS+="\nCF: "+Comma(Bet_Cashflow,2," ")+" | "+cD(BetUse,2);
   SMS+="\nScaping: "+cI(cntOrderScap_Buy)+" | "+cI(cntOrderScap_Sell);
   SMS+="\nSwap: "+cB(_SWAPLONG)+" | "+cB(_SWAPSHORT);

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int OrderSends_Scaping(int OP_Trade,int Case,int Cnt,double Price,double Cash)
  {
   int Dir=-1;
   string Dirs="";

   double Price_SL=0,Price_TP=0;
   double Rang_SL=_OrderLookAroundFirst2,Rang_TP=STOPLEVEL;

   if(OP_Trade==0 || OP_Trade==2 || OP_Trade==4)
     {
      Dir=OP_BUY;
      Dirs="B";
      //_OrderLookAroundFirst2
      Price_TP=NormalizeDouble(Ask+(Rang_TP/MathPow(10,Digits)),Digits);
      Price_SL=NormalizeDouble(Ask-(Rang_TP/MathPow(10,Digits)),Digits);
     }
   if(OP_Trade==1 || OP_Trade==3 || OP_Trade==5)
     {
      Dir=OP_SELL;
      Dirs="S";

      Price_TP=NormalizeDouble(Bid-(Rang_TP/MathPow(10,Digits)),Digits);
      Price_SL=NormalizeDouble(Bid+(Rang_TP/MathPow(10,Digits)),Digits);
     }
//---
   if(Cash>LimitBetCoin)Cash=LimitBetCoin;

   double Lot;
   Lot=NormalizeDouble((Cash/Rang_TP)*100,2);
//P(__LINE__,"Scap","Lot",cD(Lot,5));

   if(Lot)
     {
      int MGN_=_MagicEncrypt(MGN,Case,Cnt);
      int z=OrderSend(Symbol(),OP_Trade,Lot,Price,100,Price_SL,Price_TP,strEA_Name(Dirs,MGN_),MGN_,0);
      if(z>0)
         BetUse+=(Cash);
      return z;
     }
//---
   return -1;
  }
bool _SWAPLONG,_SWAPSHORT;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void getSwap()
  {
   double _MODE__SWAPLONG=MarketInfo(Symbol(),MODE_SWAPLONG);
   double _MODE_SWAPSHORT=MarketInfo(Symbol(),MODE_SWAPSHORT);

   if(_MODE__SWAPLONG>0)
      _SWAPLONG=true;
   else
      _SWAPLONG=false;

   if(_MODE_SWAPSHORT>0)
      _SWAPSHORT=true;
   else
      _SWAPSHORT=false;

  }
//+------------------------------------------------------------------+
