//+------------------------------------------------------------------+
//|                                                      Nubtung.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, TP-Member"
#property link      "https://www.mql5.com"
#property version   "1.75"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int cntM0,xcntM0;
int cntM1,xcntM1;
int cntM5,xcntM5;
int cntM15,xcntM15;
int cntM30,xcntM30;
int cntH1,xcntH1;
int cntH4,xcntH4;
int cntD1,xcntD1;

int OrderTicketClose_SellNeg[1];
int OrderTicketClose__BuyNeg[1];

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

//DiffZeroPriceBuy
double DZP_Buy,DZP_Sell;
double DZP_BuyFollow,DZP_SellFollow;

double TPp=200/MathPow(10,Digits);
double vSpread=175/MathPow(10,Digits);

double _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);
string _ActCurrency=" "+AccountCurrency();

string EAVer="2.00a";
string EAName="Nubtung "+EAVer,SymbolShortName;

extern double Fund=100;
extern int CntPerCase=8;//MaxBulletPerCase
extern int Magicnumber=8;//Magicnumber

//---ForMoneyManagement
int Case=4;
int MaxBullet=CntPerCase*Case;
double FundPerBullet=NormalizeDouble(Fund/MaxBullet,2);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   _StayNonfarm();
//_LabelSet("Text_Order3",370,80,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# ","");
//_LabelSet("Text_Order4",370,65,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# ","");

//---
   _StayFriday();
   setTemplate();
   setBackgroundPanel(Magicnumber,"BgroundGG","gg",160,0,-130,15);

   SymbolShortName=strSymbolShortName();
//---ForMoneyManagement
//FundPerBullet=Fund/MaxBullet;
//CntPerCase=MaxBullet/Case;
//---

//cntH1=iBars(Symbol(),PERIOD_H1);

//--- create timer
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strEA_Name(string v,int mn)
  {
   return SymbolShortName+v+""+cI(mn);
   return SymbolShortName+v+""+EAName;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   printf(__FUNCTION__);
   printf("//+---------------------------------------------------------------------------------------------+");
   printf("MaxDrawDown: "+cD(MaxDrawDown,2)+_ActCurrency+" at [ "+string(DateMaxDrawDown)+" ]");
   printf("MaxProfit: "+cD(MaxProfit,2)+_ActCurrency);
   printf("RunDay: "+cD(cntRunDay,0)+" | Fund: "+cD(Fund,2)+_ActCurrency+" | Profit: "+cD(Profit,2)+_ActCurrency+" [ "+cD(ProfitPC_Fund,2)+"% ] Avg: "+cD(ProfitAVG_Runday,2)+"/Day");
   printf("//+---------------------------------------------------------------------------------------------+");
   printf(History_ProfitDay);
   printf(History_ProfitCollect_MN);
   printf("//+---------------------------------------------------------------------------------------------+");

//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int sz;
string SMS;
double PriceEntry;
int MA_1=1,MA_2=1,MA_3=200;
int previousMA=1;

double cntRunDay=0;

double Profit,ProfitPC_Fund,ProfitAVG_Runday,ProfitAVGPC_Fund,ProfitAVGPC_FundMN;
double ProfitCollect_MN;
string History_ProfitDay="ProfitM% ",History_ProfitCollect_MN="ProfitMN ";
double Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);

int _OrderLookAroundFirst=200;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   setBackgroundPanel(Magicnumber,"BgroundGG","gg",160,0,-130,15);
//_StayFriday();
   xcntD1=iBars(Symbol(),PERIOD_D1);
   if(cntD1!=xcntD1)
     {
      cntD1=xcntD1;
      cntRunDay++;

      if(cntRunDay>0 && MathMod(cntRunDay,20)==0)
        {

         Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
         double Profit_Now=Current_BALANCE-Fund-ProfitCollect_MN;
         ProfitCollect_MN+=Profit_Now;

         History_ProfitDay+=cD((Profit_Now/Fund)*100,2)+"/";
         History_ProfitCollect_MN+=cD(Profit_Now,2)+"/";

        }
      //---
     }

   xcntH1=iBars(Symbol(),PERIOD_H1);
   if(cntH1!=xcntH1)
     {
      cntH1=xcntH1;
      _StayFriday();
      _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);
      //---
     }
//---
//---
   int ValueIKH_1=9,ValueIKH_2=26,ValueIKH_3=104;

   int IKH_PERIOD_1=60,IKH_PERIOD_2=60;
   double IKH_Chikou/*Yelow*/=iIchimoku(NULL,IKH_PERIOD_1,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_CHIKOUSPAN,26);
   double IKH_Tenkan/*Red__*/=iIchimoku(NULL,IKH_PERIOD_1,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_TENKANSEN,0);
   double IKH_Kijun_/*Blue_*/=iIchimoku(NULL,IKH_PERIOD_1,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_KIJUNSEN,0);

   double IKH_CloudUP/*Blue_*/=iIchimoku(NULL,IKH_PERIOD_2,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_SENKOUSPANA,-26);
   double IKH_CloudDW/*Red__*/=iIchimoku(NULL,IKH_PERIOD_2,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_SENKOUSPANB,-26);

   bool IKH_StatusDIR1=_iIKH_getChikouStatus(IKH_Chikou);

   bool IKH_StatusDIR2=true;
   if(IKH_Tenkan<IKH_Kijun_)IKH_StatusDIR2=false;

   bool IKH_StatusDIR3=true;
   if(IKH_CloudUP<IKH_CloudDW)IKH_StatusDIR3=false;
//---
   double UP_Power=(iBullsPower(NULL,30,13,PRICE_CLOSE,0)+iBullsPower(NULL,30,13,PRICE_CLOSE,1))/2;
   double DW_Power=(iBearsPower(NULL,30,13,PRICE_CLOSE,0)+iBearsPower(NULL,30,13,PRICE_CLOSE,1))/2;
   double UD_Power=(UP_Power+DW_Power);
   UD_Power=NormalizeDouble(UD_Power*MathPow(10,Digits)*1.236,0);
   UP_Power=NormalizeDouble(UP_Power*MathPow(10,Digits)*1.236,0);
   DW_Power=NormalizeDouble(DW_Power*MathPow(10,Digits)*1.236,0);

   color clrText_Order2=clrLime;
   if(UD_Power<0)
     {
      clrText_Order2=clrRed;
     }

// _LabelSet("Text_Order2",370,50,clrText_Order2,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# |"+cD(UP_Power,0)+"|"+cD(DW_Power,0)+"|"+cD(UD_Power,0),"32");
//---
   double iCustomUP=iCustom(NULL,30,"indicator-FormFB/tampc_wonders",1,0);
   double iCustomDW=iCustom(NULL,30,"indicator-FormFB/tampc_wonders",0,0);
   _LabelSet("Text_Order2",370,50,clrWhite,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# UP : "+iCustomUP+" -- DW : "+iCustomDW,"");

   bool DW_=iCustomUP<2147483647;
   bool UP_=iCustomDW<2147483647;

   double ATR_TP=NormalizeDouble((iATR(Symbol(),0,3,1)+iATR(Symbol(),0,3,0))/2,Digits);
   if(ATR_TP<NormalizeDouble(175/MathPow(10,Digits),Digits))
      ATR_TP=NormalizeDouble(175/MathPow(10,Digits),Digits);

   vSpread=ATR_TP;

   if(Workday)
     {
      bool LongEntryCondition_Power=DW_Power>50 && DW_Power<1000 && UP_Power>50;
      
      if(!_iBar_getStatus(0) && UP_ && cntOrderBuy==0 && cntOrderSell==0
         && _OrderLookAround("Buy",4,0,Ask,_OrderLookAroundFirst))
        {
         sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderBuy,MagazineBuy,1),Ask,100,0,0/*NormalizeDouble(Ask+(ATR_TP*1.059),Digits)*/,strEA_Name("-[B1|"+cFillZero(cntOrderBuy)+"]",_MagicEncrypt(1,cntOrderBuy)),_MagicEncrypt(1,cntOrderBuy),0);
         if(cntOrderSell==0)
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderSell,MagazineSell,2),Bid,100,0,0/*NormalizeDouble(Bid-(ATR_TP*1.059),Digits)*/,strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]",_MagicEncrypt(2,cntOrderSell)),_MagicEncrypt(2,cntOrderSell),0);

        }
      else if((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread)) && LongEntryCondition_Power)
        {
         //sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderBuy,MagazineBuy,1),Ask,100,0,0,strEA_Name("-[B1|"+cFillZero(cntOrderBuy)+"]",_MagicEncrypt(1,cntOrderBuy)),_MagicEncrypt(1,cntOrderBuy),0);
        }
      //---
      bool ShortEntryCondition_Power=UP_Power<-50 && UP_Power>-1000 && DW_Power<-50;
      if(_iBar_getStatus(0) && DW_ && cntOrderSell==0
         && _OrderLookAround("Sell",5,0,Bid,_OrderLookAroundFirst))
        {
         sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderSell,MagazineSell,2),Bid,100,0,0/*NormalizeDouble(Bid-(ATR_TP*1.059),Digits)*/,strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]",_MagicEncrypt(2,cntOrderSell)),_MagicEncrypt(2,cntOrderSell),0);
         if(cntOrderBuy==0)
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderBuy,MagazineBuy,1),Ask,100,0,0/*NormalizeDouble(Ask+(ATR_TP*1.059),Digits)*/,strEA_Name("-[B1|"+cFillZero(cntOrderBuy)+"]",_MagicEncrypt(1,cntOrderBuy)),_MagicEncrypt(1,cntOrderBuy),0);

        }
      else if((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread)) && ShortEntryCondition_Power)
        {
         //sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderSell,MagazineSell,2),Bid,100,0,0,strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]",_MagicEncrypt(2,cntOrderSell)),_MagicEncrypt(2,cntOrderSell),0);
        }
     }

//---

   if(cntOrderFollowBuy==0 && Workday)
     {
      bool LongEntryCondition_Power=UP_Power>100 && UP_Power<1000 && DW_Power>50;
      if(LongEntryCondition_Power
         && _OrderLookAround("Buy",1,0,Ask,_OrderLookAroundFirst))
        {
         //sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderFollowBuy,MagazineBuyF,4),Ask,100,0,0,strEA_Name("-[B2|"+cFillZero(cntOrderFollowBuy)+"]",_MagicEncrypt(4,cntOrderFollowBuy)),_MagicEncrypt(4,cntOrderFollowBuy),0);
        }
     }
   if(cntOrderFollowSell==0 && Workday)
     {
      bool ShortEntryCondition_Power=DW_Power<(50*-1) && DW_Power>(1000*-1) && UP_Power<(50*-1);
      if(ShortEntryCondition_Power
         && _OrderLookAround("Sell",2,0,Bid,_OrderLookAroundFirst))
        {
         //sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderFollowSell,MagazineSellF,5),Bid,100,0,0,strEA_Name("-[S2|"+cFillZero(cntOrderFollowSell)+"]",_MagicEncrypt(5,cntOrderFollowSell)),_MagicEncrypt(5,cntOrderFollowSell),0);
        }
     }
//---

   xcntM0=iBars(Symbol(),0);
   if(cntM0!=xcntM0)
     {
      cntM0=xcntM0;
      //Print("Turning bars");

      _StayFriday();

      _getOrderCNT_Sum_AtiveHub();
      _getOrderPriceMaxMinHub();
      //---
      string Text_Order1="";
      //---

      bool Chk_OnArea;
      Chk_OnArea=((Ask<_PriceMax__FollowBuy) && (Ask>_PriceMin__FollowBuy))
                 && (DZP_BuyFollow>(-500) && DZP_BuyFollow<=0)
                 && (cntOrderFollowBuy>=2 && cntOrderFollowBuy<=10)
                 && _OrderLookAround("Buy",4,-1,Ask,_OrderLookAroundFirst);
      if(/*IKH_StatusDIR2==true  &&*/ sumOrderFollowBuy<0 && Chk_OnArea && UD_Power>200)
        {
         sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderFollowBuy,MagazineBuyF,4),Ask,100,0,0,strEA_Name("*[B2|"+cFillZero(cntOrderFollowBuy)+"]",_MagicEncrypt(4,cntOrderFollowBuy)),_MagicEncrypt(4,cntOrderFollowBuy),0);
         Text_Order1+="/"+"xBUY";
        }
      //---
      Chk_OnArea=((Bid>_PriceMin_FollowSell) && (Bid<_PriceMax_FollowSell+vSpread))
                 && (DZP_SellFollow>(-500) && DZP_SellFollow<=0)
                 && (cntOrderFollowSell>=2 && cntOrderFollowSell<=10)
                 && _OrderLookAround("Sell",5,-1,Bid,_OrderLookAroundFirst);
      if(/*IKH_StatusDIR2==false && */sumOrderFollowSell<0 && Chk_OnArea && UD_Power<-200)
        {
         sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderFollowSell,MagazineSellF,5),Bid,100,0,0,strEA_Name("*[S2|"+cFillZero(cntOrderFollowSell)+"]",_MagicEncrypt(5,cntOrderFollowSell)),_MagicEncrypt(5,cntOrderFollowSell),0);
         Text_Order1+="/"+"xSell";
        }
      //---
      bool Chk_OnBuy=true,Chk_OnSell=true;
      Chk_OnArea=true;
      double vSarUse=0.01;
      //---
      if(cntOrderBuy==0 && Workday)
        {
         bool LongEntryCondition=(iStochastic(NULL,15,9,3,3,MODE_SMA,0,MODE_SIGNAL,1)>iStochastic(NULL,15,14,3,3,MODE_SMA,0,MODE_SIGNAL,1));
         bool LongEntryCondition_Power=DW_Power>50 && DW_Power<1000 && UP_Power>50;
         bool LongEntryCondition_iCustom=iCustomUP<2147483647;
         if(//LongEntryCondition
            //IKH_StatusDIR3
            _OrderLookAround("Buy",4,0,Ask,_OrderLookAroundFirst) && 
            LongEntryCondition_Power
            //&& LongEntryCondition_iCustom
            /*&& getMA(0,1,200,1,"=")==0 && getMA(0,100,400,1,"-")==1*/) //Out 100,700
           {
            //sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderBuy,MagazineBuy,1),Ask,100,0,0,strEA_Name("-[B1|"+cFillZero(cntOrderBuy)+"]",_MagicEncrypt(1,cntOrderBuy)),_MagicEncrypt(1,cntOrderBuy),0);
            Chk_OnBuy=false;
            Text_Order1+="/"+"B0";
           }
        }
      else if((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread)))
/*&& _isSarInAdj(vSarUse,1)==0   && IKH_StatusDIR2==true */
        {
         if(UP_Power>300 || DW_)
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderBuy,MagazineBuy,1),Ask,100,0,0,strEA_Name("-[B1|"+cFillZero(cntOrderBuy)+"]",_MagicEncrypt(1,cntOrderBuy)),_MagicEncrypt(1,cntOrderBuy),0);
            Text_Order1+="/"+"B0-";
           }

        }
      //---
      if(cntOrderSell==0 && Workday)
        {
         bool ShortEntryCondition=iStochastic(NULL,15,9,3,3,MODE_SMA,0,MODE_SIGNAL,1)<iStochastic(NULL,15,14,3,3,MODE_SMA,0,MODE_SIGNAL,1);
         bool ShortEntryCondition_Power=UP_Power<-100 && UP_Power>-1000 && DW_Power<-50;
         bool ShortEntryCondition_iCustom=iCustomDW<2147483647;
         if(//ShortEntryCondition
            //!IKH_StatusDIR3
            _OrderLookAround("Sell",5,0,Bid,_OrderLookAroundFirst) && 
            ShortEntryCondition_Power
            //&& ShortEntryCondition_iCustom
            /*&& getMA(0,1,200,1,"=")==1 && getMA(0,100,400,1,"-")==0*/)
           {
            //sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderSell,MagazineSell,2),Bid,100,0,0,strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]",_MagicEncrypt(2,cntOrderSell)),_MagicEncrypt(2,cntOrderSell),0);
            Chk_OnSell=false;
            Text_Order1+="/"+"S0";
           }
        }
      else if((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread)))
/*&& _isSarInAdj(vSarUse,1)==1  && IKH_StatusDIR2==false */
        {
         if(DW_Power<-300 || UP_)
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderSell,MagazineSell,2),Bid,100,0,0,strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]",_MagicEncrypt(2,cntOrderSell)),_MagicEncrypt(2,cntOrderSell),0);
            Text_Order1+="/"+"S0-";
           }
        }
      //---
      vSarUse=0.021;
      //+------------------------------------------------------------------+
      if(cntOrderFollowBuy==0/*&& cntOrderBuy==0 */ && Workday /*&& Chk_OnBuy*/)
        {
         bool LongEntryCondition_Power=UP_Power>100 && UP_Power<1000 && DW_Power>50;
         if(/* _isSarInAdj(0.01,1)==0  && IKH_StatusDIR2==true    && */
            !_iBar_getStatus(1) && 
            //LongEntryCondition_Power && 
            _OrderLookAround("Buy",1,0,Ask,_OrderLookAroundFirst))//&& IKH_StatusDIR3)*/
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderFollowBuy,MagazineBuyF,4),Ask,100,0,0/*NormalizeDouble(Ask+(ATR_TP*1.059),Digits)*/,strEA_Name("-[B2|"+cFillZero(cntOrderFollowBuy)+"]",_MagicEncrypt(4,cntOrderFollowBuy)),_MagicEncrypt(4,cntOrderFollowBuy),0);
            Text_Order1+="/"+"B1";
           }
        }
      else
        {
         if(((Ask<_PriceMax__FollowBuy) && (Ask<(_PriceMin__FollowBuy-vSpread))) /*&& _isSarInAdj(vSarUse,1)==0  && IKH_StatusDIR2==true && UD_Power>100*/)
           {
            if(IKH_StatusDIR3==true && UD_Power>150)
              {
               sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderFollowBuy,MagazineBuyF,4),Ask,100,0,0,strEA_Name("-[B2|"+cFillZero(cntOrderFollowBuy)+"]",_MagicEncrypt(4,cntOrderFollowBuy)),_MagicEncrypt(4,cntOrderFollowBuy),0);
               Text_Order1+="/"+"B1-1";
              }
            if(UP_Power>300)
              {
               //sz=OrderSend(Symbol(),OP_BUY,_getOrderLots_byMM(OP_BUY,cntOrderFollowBuy,MagazineBuyF,4),Ask,100,0,0,strEA_Name("-[B22|"+cFillZero(cntOrderFollowBuy)+"]",_MagicEncrypt(4,cntOrderFollowBuy)),_MagicEncrypt(4,cntOrderFollowBuy),0);
               Text_Order1+="/"+"B1-2";
              }
           }
        }
      //---

      if(cntOrderFollowSell==0/*&& cntOrderSell==0 */
         && Workday /*&& Chk_OnSell*/)
        {
         bool ShortEntryCondition_Power=DW_Power<(50*-1) && DW_Power>(1000*-1) && UP_Power<(50*-1);
         if(/*_isSarInAdj(0.01,1)==1   && IKH_StatusDIR2==false  &&*/
            _iBar_getStatus(1) && 
            //ShortEntryCondition_Power && 
            _OrderLookAround("Sell",2,0,Bid,_OrderLookAroundFirst))
            //&& !IKH_StatusDIR3)
           {
            //sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderSell,MagazineSell,2)       ,Bid,100,0,NormalizeDouble(Bid-ATR_TP,Digits),strEA_Name("-[S1|"+cFillZero(cntOrderSell)+"]"      ,_MagicEncrypt(2,cntOrderSell))      ,_MagicEncrypt(2,cntOrderSell),0);
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderFollowSell,MagazineSellF,5),Bid,100,0,0/*NormalizeDouble(Bid-(ATR_TP*1.059),Digits)*/,strEA_Name("-[S2|"+cFillZero(cntOrderFollowSell)+"]",_MagicEncrypt(5,cntOrderFollowSell)),_MagicEncrypt(5,cntOrderFollowSell),0);
            _LabelSet("Text_Order4",370,65,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cntOrderFollowSell,"");

            Text_Order1+="/"+"S1";
           }
        }
      else
        {
         //Print(__FUNCTION__+" "+cntOrderFollowSell);
         if((Bid>_PriceMin_FollowSell) && (Bid>(_PriceMax_FollowSell+vSpread)) /*&& _isSarInAdj(vSarUse,1)==1  && IKH_StatusDIR2==false&& UD_Power<-100*/)
           {
            if(IKH_StatusDIR3==false && UD_Power<-150)
              {
               sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderFollowSell,MagazineSellF,5),Bid,100,0,0,strEA_Name("-[S2|"+cFillZero(cntOrderFollowSell)+"]",_MagicEncrypt(5,cntOrderFollowSell)),_MagicEncrypt(5,cntOrderFollowSell),0);
               Text_Order1+="/"+"S1-1";
              }
            if(UD_Power<-300)
              {
               //sz=OrderSend(Symbol(),OP_SELL,_getOrderLots_byMM(OP_SELL,cntOrderFollowSell,MagazineSellF,5),Bid,100,0,0,strEA_Name("-[S22|"+cFillZero(cntOrderFollowSell)+"]",_MagicEncrypt(5,cntOrderFollowSell)),_MagicEncrypt(5,cntOrderFollowSell),0);
               Text_Order1+="/"+"S1-2";
              }
           }
        }

      //---Group3
      // _LabelSet("Text_Order1",370,35,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+Text_Order1+"|"+UP_Power+"|"+DW_Power+"|"+UD_Power,"31");

      //+------------------------------------------------------------------+
     }
   Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
   if(Current_BALANCE<=0)
     {
      Current_BALANCE=1;
     }
   Profit=NormalizeDouble(Current_BALANCE-Fund,2);

   if(Fund==0)Fund=1;
   ProfitPC_Fund=NormalizeDouble((Profit/Fund)*100,2);

   if(cntRunDay==0)cntRunDay=1;
   ProfitAVG_Runday=(Profit)/cntRunDay;
   if(ProfitAVG_Runday>0)
      ProfitAVGPC_Fund=(ProfitAVG_Runday/Fund)*100;
   ProfitAVGPC_FundMN=ProfitAVGPC_Fund*20;
//ProfitAVG=NormalizeDouble(ProfitAVG*35,2);

   double Current_Hold=AccountInfoDouble(ACCOUNT_PROFIT);

   getDrawDown(Current_Hold,Current_BALANCE);
   SMS="";
//SMS+="\n"+c(previousMA(5))+" "+c(getMA(0,MA_1,MA_2,MA_3,1));
//SMS+="\n"+SymbolShortName+" Day : "+cI(cntRunDay);
   SMS+=SMS_Workday+"\n";
   SMS+="\n"+History_ProfitDay+"\n";
   SMS+=History_ProfitCollect_MN+"\n";
   SMS+="\n------"+cD(ProfitCollect_MN,2);
   SMS+="\nPort: "+Comma(Current_Hold,2," ")+_ActCurrency+"| "+Comma((Current_Hold/Current_BALANCE)*100,2," ")+"%";
   SMS+="\nBalace: "+Comma(Current_BALANCE,2," ")+" | "+cD(ProfitPC_Fund,2)+"% PerDay: [ "+cD(ProfitAVGPC_Fund,4)+"%"+cD(ProfitAVGPC_FundMN,1)+" | "+cD(ProfitAVG_Runday,2)+_ActCurrency+" ]";
   SMS+="\n\nDD: "+cD(MaxDrawDown,2)+_ActCurrency+" "+cD(MaxDrawDownPCFund,2)+"%|"+cD(MaxDrawDownPCPort,2)+"% ["+string(DateMaxDrawDown)+"]";
   SMS+="\nPT: "+cD(MaxProfit,2)+_ActCurrency;

   _getOrderPriceMaxMinHub();
   _getOrderCNT_Sum_AtiveHub();

   if(cntOrderBuy==0)
     {
      OrderStopLossBuy=0;
      ConfirmBuy=0;
      ATR_Buy=0;

      MagazineBuyF=CntPerCase;

      HLineDelete(0,"LINE_Point1");
      HLineDelete(0,"LINE_Save1");
      HLineDelete(0,"LINE_SL1");

      HLineDelete(0,"LINE_ATR_Buy1");

      HLineDelete(0,"Text_MM1");
     }
   if(cntOrderSell==0)
     {
      OrderStopLossSell=0;
      ConfirmSell=0;
      ATR_SeLL=0;

      MagazineSellF=CntPerCase;

      HLineDelete(0,"LINE_Point2");
      HLineDelete(0,"LINE_Save2");
      HLineDelete(0,"LINE_SL2");

      HLineDelete(0,"LINE_ATR_SeLL2");

      HLineDelete(0,"Text_MM3");
     }
   if(cntOrderFollowBuy==0)
     {
      OrderStopLossFollowBuy=0;
      ConfirmBuyFollow=0;
      ATR_BuyF=0;

      MagazineBuy=CntPerCase;

      HLineDelete(0,"LINE_Point4");
      HLineDelete(0,"LINE_Save4");
      HLineDelete(0,"LINE_SL4");

      HLineDelete(0,"LINE_ATR_Buy4");

      HLineDelete(0,"Text_MM2");
     }
   if(cntOrderFollowSell==0)
     {
      OrderStopLossFollowSell=0;
      ConfirmSellFollow=0;
      ATR_SeLLF=0;

      MagazineSell=CntPerCase;

      HLineDelete(0,"LINE_Point5");
      HLineDelete(0,"LINE_Save5");
      HLineDelete(0,"LINE_SL5");

      HLineDelete(0,"LINE_ATR_SeLL5");

      HLineDelete(0,"Text_MM4");
     }
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
      //printf(c(__LINE__));
      __OrderChkTP("Buy",cntOrderBuy,1);
     }
   if(cntOrderSell>=1)
     {
      //printf(c(__LINE__));
      __OrderChkTP("Sell",cntOrderSell,2);
     }
   if(cntOrderFollowBuy>=1)
     {
      //printf(c(__LINE__));
      __OrderChkTP("Buy",cntOrderFollowBuy,4);
     }
   if(cntOrderFollowSell>=1)
     {
      //printf(c(__LINE__));
      __OrderChkTP("Sell",cntOrderFollowSell,5);
     }

/*sumOrderBuy=0;
   cntOrderBuy=sumOrderBuy;
   DepositBuy=cntOrderBuy;

   sumOrderSell=0;
   DepositSell=sumOrderSell;
   cntOrderSell=sumOrderSell;*/

   sumConfirm=ConfirmBuy+ConfirmSell+ConfirmBuyFollow+ConfirmSellFollow;

   SMS+="\n------"+SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE);
   SMS+="\nNubtung: "+cI(cntOrder)+" : "+Comma(sumOrder,2," ");
   SMS+="|: "+Comma((sumOrder/Fund)*100,2," ")+"%";

   if(sumConfirm>0)
     {
      SMS+="*"+Comma(sumConfirm,2,"")+"*";
     }

   SMS+="\n";
//+------------------------------------------------------------------+
   if(cntOrderBuy>0 || cntOrderSell>0)
      SMS+="\nNormal-";

   SMS+=strZeroKey(" Buy [ "+cI(cntOrderBuy)+" ] : "+Comma(sumOrderBuy,2," "),cntOrderBuy)+strZero(ConfirmBuy,"*","*");

   if(cntOrderBuy>0 && cntOrderSell>0)
      SMS+=" |";

   SMS+=strZeroKey(" Sell [ "+cI(cntOrderSell)+" ] : "+Comma(sumOrderSell,2," "),cntOrderSell)+strZero(ConfirmSell,"*","*");
//+------------------------------------------------------------------+
   if(cntOrderFollowBuy>0 || cntOrderFollowSell>0)
      SMS+="\nFollow--";

   SMS+=strZeroKey(" Buy [ "+cI(cntOrderFollowBuy)+" ] : "+Comma(sumOrderFollowBuy,2," "),cntOrderFollowBuy)+strZero(ConfirmBuyFollow,"*","*");

   if(cntOrderFollowBuy>0 && cntOrderFollowSell>0)
      SMS+=" |";

   SMS+=strZeroKey(" Sell [ "+cI(cntOrderFollowSell)+" ] : "+Comma(sumOrderFollowSell,2," "),cntOrderFollowSell)+strZero(ConfirmSellFollow,"*","*");
//+------------------------------------------------------------------+
   SMS+="\n------";
//SMS+="\nBefore: "+cI(getMAprevious(1,50,2,5))+" After: "+cI(getMAprevious(1,50,0,1));
   SMS+="\nATR: "+Comma(ATR*MathPow(10,Digits),0,"");
   Comment(SMS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderX_SelectOne(int v)
  {
   OrderTicketClose_SellNeg[0]=v;
   if(OrderSelect(OrderTicketClose_SellNeg[0],SELECT_BY_TICKET)==true)
     {
      sz=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
      printf(string(OrderTicket())+" X "+string(sz));
      OrderTicketClose_SellNeg[0]=0;
     }
   return sz;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getBarUpDw(int n)
  {
   int v=-1;
   double _Open=iOpen(NULL,0,n);
   double _Close=iClose(NULL,0,n);

   if(_Open>_Close)
     {
      v=0;
     }
   else if(_Open<_Close)
     {
      v=1;
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getMA(int TF,int vFast,int vSlow,int shift,string Mode)
  {
   int v=-1;

   double Fast=iMA(NULL,TF,vFast,0,MODE_SMA,PRICE_MEDIAN,shift);
   double Slow=iMA(NULL,TF,vSlow,0,MODE_SMA,PRICE_MEDIAN,shift);
   if(Mode=="=")
     {
      if(Bid>=Slow)
        {
         v=0;
        }
      else  if(Bid<=Slow)
        {
         v=1;
        }
     }
   if(Mode=="-")
     {
      if(Fast>Slow)
        {
         v=0;
        }
      else  if(Fast<Slow)
        {
         v=1;
        }
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getMA(int TF,int vFast,int vMid,int vSlow,int shift)
  {
   int v;

   double Fast=iMA(NULL,TF,vFast,0,MODE_SMA,PRICE_MEDIAN,shift);
   double Mid=iMA(NULL,TF,vMid,0,MODE_SMA,PRICE_MEDIAN,shift);
   double Slow=iMA(NULL,TF,vSlow,0,MODE_SMA,PRICE_MEDIAN,shift);

   if(Fast>Mid && Mid>Slow && Fast>Slow)
     {
      v=0;
     }
   else  if(Fast<Mid && Mid<Slow && Fast<Slow)
     {
      v=1;
     }
   else
     {
      v=-1;
     }

   return v;
  }
string testgetMAprevious;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getMAprevious(int MA1,int MA2,int Start,int End)
  {
   bool chk=true;
   for(int i=Start;i<End;i++)
     {
      if(getMA(0,MA1,MA2,i,"-")!=getMA(0,MA1,MA2,i+1,"-"))
        {
         chk=false;
         break;
        }
     }
   int v=-1;
   if(chk)
     {
      v=getMA(0,MA1,MA2,Start,"-");
     }
   else
     {
      v=-1;
     }

   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderTrailingStopOriginal(int Ticket,double Trailing)
  {
//printf(Ticket+" | "+Trailing);
   double SL=-1;
   if(OrderSelect(Ticket,SELECT_BY_TICKET)==true)
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY)
           {
            if(Bid-OrderOpenPrice()>Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
              {
               if(OrderStopLoss()<Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT) || (OrderStopLoss()==0))
                 {
                  //z=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),Red);
                  SL=Bid-Trailing*MarketInfo(OrderSymbol(),MODE_POINT);

                 }
              }
           }
         else if(OrderType()==OP_SELL)
           {
            if(OrderOpenPrice()-Ask>Trailing*MarketInfo(OrderSymbol(),MODE_POINT))
              {
               if((OrderStopLoss()>Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT)) || (OrderStopLoss()==0))
                 {
                  //z=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT),OrderTakeProfit(),Red);
                  SL=Ask+Trailing*MarketInfo(OrderSymbol(),MODE_POINT);
                 }
              }
           }
         if(SL>0)
           {
            sz=OrderModify(OrderTicket(),OrderOpenPrice(),SL,0,0);
           }

        }
  }
int cntOrderBuyMax,cntOrderSellMax;
int cntOrderFollowBuyMax,cntOrderFollowSellMax;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getOrderCNT_Sum_AtiveHub()
  {
   cntOrderBuy=int(_getOrderCNT_Ative(1,"Cnt"));
   cntOrderSell=int(_getOrderCNT_Ative(2,"Cnt"));

   cntOrderFollowBuy=int(_getOrderCNT_Ative(4,"Cnt"));
   cntOrderFollowSell=int(_getOrderCNT_Ative(5,"Cnt"));
//---
   if(cntOrderBuy>cntOrderBuyMax)cntOrderBuyMax=cntOrderBuy;
   if(cntOrderSell>cntOrderSellMax)cntOrderSellMax=cntOrderSell;

   if(cntOrderFollowBuy>cntOrderFollowBuyMax)cntOrderFollowBuyMax=cntOrderFollowBuy;
   if(cntOrderFollowSell>cntOrderFollowSellMax)cntOrderFollowSellMax=cntOrderFollowSell;
//---
   sumOrderBuy=_getOrderCNT_Ative(1,"Sum");
   sumOrderSell=_getOrderCNT_Ative(2,"Sum");

   sumOrderFollowBuy=_getOrderCNT_Ative(4,"Sum");
   sumOrderFollowSell=_getOrderCNT_Ative(5,"Sum");
//---
   cntOrder=cntOrderBuy+cntOrderSell;
   cntOrder+=cntOrderFollowBuy+cntOrderFollowSell;
//---
   sumOrder=sumOrderBuy+sumOrderSell;
   sumOrder+=sumOrderFollowBuy+sumOrderFollowSell;

   sumOrder=NormalizeDouble(sumOrder,2);
//---
   Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
   if(Current_BALANCE<=0)Current_BALANCE=1;
   if(((sumOrder/Current_BALANCE)*100)>=15)
     {
      _orderCloseActive(1);
      _orderCloseActive(2);
      _orderCloseActive(4);
      _orderCloseActive(5);
     }
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderCNT_Ative(int pin,string mode)
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
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if(OrderSymbol()==Symbol() && 
         OrderMagic_Key==Magicnumber &&
         OrderMagic_Pin==pin &&
         OrderType()<=1)
        {
         c++;
         //---
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _isSarInAdj(double vSarUse,int Shift)
  {
   double v=NormalizeDouble(iSAR(Symbol(),0,vSarUse,0.2,Shift),Digits);
   if(v>iClose(Symbol(),0,Shift))
     {
      return 1;//Sell
     }
   else
     {
      return 0;//Buy
     }

   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getOrderPriceMaxMinHub()
  {
//---Normal
   _PriceMax__Buy= _getOrderPriceMaxMin("Max",1);
   _PriceMin__Buy= _getOrderPriceMaxMin("Min",1);

   _PriceMax_Sell=_getOrderPriceMaxMin("Max",2);
   _PriceMin_Sell= _getOrderPriceMaxMin("Min",2);
//---Follow
   _PriceMax__FollowBuy= _getOrderPriceMaxMin("Max",4);
   _PriceMin__FollowBuy= _getOrderPriceMaxMin("Min",4);

   _PriceMax_FollowSell=_getOrderPriceMaxMin("Max",5);
   _PriceMin_FollowSell= _getOrderPriceMaxMin("Min",5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderPriceMaxMin(string v,int pin)
  {
//int _MagicNumber=_MagicEncrypt(nm);

   double MinPrice=99999,MaxPrice=-99999;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if(OrderMagic_Key==Magicnumber &&
         OrderMagic_Pin==pin &&
         OrderSymbol()==Symbol())
        {
         if(OrderOpenPrice()>MaxPrice)
           {
            MaxPrice=OrderOpenPrice();
           }
         if(OrderOpenPrice()<MinPrice)
           {
            MinPrice=OrderOpenPrice();
           }
        }
     }
/*if(MinPrice==99999)
      MinPrice=0;
   if(MaxPrice==-99999)
      MaxPrice=0;*/

//printf("[_isLastBas()]# Max : "+MaxPrice+" Min : "+MinPrice);
   if("Max"==v)
     {
      return  MaxPrice;
     }

   else if("Min"==v)
     {
      return  MinPrice;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculateTrailing_ByOriginal(int cnt,double Diff)
  {
   double Trailing=-1;

   Diff=Diff*MathPow(10,Digits);
   double MinTrai=MarketInfo(Symbol(),14);

/*if(cnt==1)
     {*/
   if(Diff<=200)
     {Trailing=150;}
   else if(Diff<=300)
     {Trailing=200;}
   else if(Diff<=400)
     {Trailing=150;}
/*else if(Diff<=500)
        {Trailing=100;}
      else if(Diff<=600)
        {Trailing=100;}
      else if(Diff<=700)
        {Trailing=100;}*/
   else if(Diff<=800)
     {Trailing=100;}
   else
     {
      Trailing=100;
/*Trailing=MarketInfo(Symbol(),14);
         double W=50;
         Trailing=Trailing*(2+(W/100));*/
     }
/*}
   else
     {*/
   if(cnt>1)
     {
      double W=50;
      Trailing=(Trailing/cnt)*(1+(W/100));
      if(Trailing<MinTrai)
        {
         Trailing=MinTrai;
        }
     }
// }
// }
   return NormalizeDouble(Trailing/MathPow(10,Digits),Digits);
//if(Diff>=Trailing)
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _OrderTP(int OP,double OpenPrice)
  {

   double v=0,r=0;
   v=iATR(Symbol(),0,3,0);
   v=NormalizeDouble(v*1.236,Digits);

/*if(invert==0)
      v=v/3;*/

   if(OP==0)
     {
      r=OpenPrice+v;
      P(__LINE__,__FUNCTION__,"OpenPrice--BUY",cD(OpenPrice,Digits),"V",cD(v,Digits),"R",cD(r,Digits));
     }
   else if(OP==1)
     {
      r=OpenPrice-v;
      P(__LINE__,__FUNCTION__,"OpenPrice--SELL",cD(OpenPrice,Digits),"V",cD(v,Digits),"R",cD(r,Digits));
     }
   return NormalizeDouble(r,Digits);
  }

double _OrderSL_TP=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _OrderSL(int OP,double OpenPrice,int invert)
  {
   _OrderSL_TP=0;
   double v=0,r=0;
   v=(iATR(Symbol(),0,3,21)+iATR(Symbol(),0,3,1)+iATR(Symbol(),0,3,0))/3;
   v=NormalizeDouble(v*2,Digits);

   double MinSL=100/MathPow(10,Digits);
   if(v<MinSL)
     {
      v=MinSL;
     }

   if(invert==0)
      v=v/2;

   if(OP==0)
     {
      r=OpenPrice-v;
      _OrderSL_TP=NormalizeDouble(OpenPrice+(v),Digits);
      P(__LINE__,__FUNCTION__,"OpenPrice--BUY",cD(OpenPrice,Digits),"V",cD(v,Digits),"R",cD(r,Digits));
     }
   else if(OP==1)
     {
      r=OpenPrice+v;
      _OrderSL_TP=NormalizeDouble(OpenPrice-(v),Digits);
      P(__LINE__,__FUNCTION__,"OpenPrice--SELL",cD(OpenPrice,Digits),"V",cD(v,Digits),"R",cD(r,Digits));
     }
   return NormalizeDouble(r,Digits);
  }
double ATR_CU=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculateTrailing(int cnt,double Diff)
  {
   double Trailing=-1;

   Diff=NormalizeDouble(Diff*MathPow(10,Digits),0);

//printf("--------------");
   double FiboRate[]={0,1.000,1.236,1.382,/**/1.500,1.618,1.809,2.000};
   double TraiRate[]={1,0.809,0.618,0.500,/**/0.382,0.236,0.118,0,0,0,0};

//ATR_CU=(iATR(Symbol(),0,3,21)+iATR(Symbol(),0,3,1)+iATR(Symbol(),0,3,0))/3;
   ATR_CU=NormalizeDouble((iATR(Symbol(),0,3,1)+iATR(Symbol(),0,3,0))/2,Digits);
   double ATR_CU_=NormalizeDouble(ATR_CU*FiboRate[6]*MathPow(10,Digits),0);

//P(__LINE__,__FUNCTION__,"cnt",cI(cnt),"ATR",ATR);

   double LevelFibo=0,LevelFiboUse=0;
//P(__LINE__,__FUNCTION__,"Diff",Diff,"FiboRate[2]",NormalizeDouble(ATR*FiboRate[2],0));

   bool chkloop=false;
   for(int i=0,j=4;i<=7;i++,j++)
     {
      LevelFibo=NormalizeDouble(ATR_CU_*TraiRate[i],0);
      if(Diff<=LevelFibo)
        {
         chkloop=true;
         Trailing=NormalizeDouble(LevelFibo*TraiRate[j],0);
         LevelFiboUse=LevelFibo;
         break;
        }
     }
//---
   if(cnt>=3)
      Trailing=(Trailing/cnt);

/*double W=50;
   if(cnt>1)
      Trailing=Trailing*(1+(W/100));*/

   double MinTrai_STOPLEVEL=(MarketInfo(Symbol(),MODE_STOPLEVEL)+(cnt*2))*1.5;
   if(Trailing<=MinTrai_STOPLEVEL /*&& Trailing>=0*/)
      Trailing=MinTrai_STOPLEVEL;

   Trailing=NormalizeDouble(Trailing/MathPow(10,Digits),Digits);
//P(__LINE__,__FUNCTION__,"R",Trailing);
   return Trailing;

  }

double OrderStopLossBuy=0,OrderStopLossSell=0;
double OrderStopLossFollowBuy=0,OrderStopLossFollowSell=0;

double OrderStopLossBuy_Merge=0,OrderStopLossSell_Merge=0;

double OrderPointBuy=0,OrderPointSell=0;
double OrderPointFollowBuy=0,OrderPointFollowSell=0;
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
void __OrderChkTP(string v,int cnt,int pin)
  {
//_getOrderCNT_Sum_AtiveHub();
//   _LabelSet("Text_MM0",10,100,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(iSAR(Symbol(),0,0.009,0.2,0)-Bid,Digits),"CNT[DiffPrice/DiffSL | UseTrailing]");

   int _MagicNumber=pin;
   _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);

   int Direct=-1;
   string TestLoop;
   double Point_=_CalculatePrice_Group(v,pin);
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

   _getOrderCNT_Sum_AtiveHub();
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
   double SumSupporter=1.5;
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

         Trailing=_CalculateTrailing(cnt,Diff);
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
            _LabelSet("Text_MM1",10,65,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineBuy)+"|"+cI(cntOrderBuyMax)+" Buy ["+cD(DZP_Buy,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM2",10,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineBuyF)+"|"+cI(cntOrderFollowBuyMax)+" BuyF ["+cD(DZP_BuyFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

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

         Trailing=_CalculateTrailing(cnt,Diff);
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
            _LabelSet("Text_MM3",10,35,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineSell)+"|"+cI(cntOrderSellMax)+" Sell ["+cD(DZP_Sell,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM4",10,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"|"+cI(MagazineSellF)+"|"+cI(cntOrderFollowSellMax)+" SellF ["+cD(DZP_SellFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

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
   else
     {
      _MagicNumber=4;
      Direct=OP_BUY;
      _MagicNumber2=5;
      Direct2=OP_SELL;
     }

   bool CHK=false;
   if(SL>0)
     {
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         _MagicDecode(OrderMagicNumber());
         if(OrderMagic_Key==Magicnumber &&
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
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderModifyForTrailing(double _TP,int pin,int _OrderType)
  {
//double SumDeposit=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)
         continue;
      _MagicDecode(OrderMagicNumber());
      if(OrderMagic_Key==Magicnumber &&
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

double SumLot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculatePrice_Group(string Direction,int pin)
  {

   double SumDeposit=0;
   double SumProduct=0,
   MinLot = 99999,
   Result = 0,
   Temp   = 0,
   A=0,B=0;

   SumLot=0;
   SumDeposit=0;
   int n=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if(OrderMagic_Key==Magicnumber &&
         OrderMagic_Pin==pin &&
         OrderSymbol()==Symbol())
        {
         //+------------------------------------------------------------------+
         SumDeposit+=_ConfirmProfitCalculate(OrderType(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderCommission(),OrderSwap());
         //+------------------------------------------------------------------+

         SumProduct+=OrderLots()*OrderOpenPrice();
         SumLot+=OrderLots();
         n++;
         if(OrderLots()<MinLot)
           {
            MinLot=OrderLots();
           }
        }
     }
//+------------------------------------------------------------------+     
   _ConfirmProfitSet(pin,SumDeposit);
//+------------------------------------------------------------------+

   if(SumLot!=0)
      A=SumProduct/SumLot;
   else
      return 1;

   double Carry;
//Carry=(n*_SPREAD)*1.236;
//Carry=(n*3)/MathPow(10,Digits);
   Carry=50/MathPow(10,Digits);

   if(Direction=="Buy")
      Result=A+Carry;
   else
      Result=A-Carry;

   return NormalizeDouble(Result,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculatePip(int cnt)
  {
   double Temp=1;
   string Str;
   for(int i=0;i<cnt; i++)
     {
      Temp=Temp+(Temp/100)*1;

      Temp=NormalizeDouble(Temp,2);

      Str+="/"+(string)Temp;
     }
   Print("[_Calculate Pip()]# CNT "+(string)cnt+" is "+Str);
   return Temp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _ConfirmProfitCalculate(int _OrderType,double Lot,double OpenPrice,double SL,double TP,double Com,double Swap)
  {
   double sum=-1,Tragrt;
//---
   double _mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE);   //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   double l=MarketInfo(Symbol(), MODE_LOTSIZE);
   double p=MarketInfo(Symbol(),MODE_POINT);//**
   double t=MarketInfo(Symbol(),MODE_TICKSIZE);
   double v=MarketInfo(Symbol(),MODE_TICKVALUE);//**

//---
   if(SL>0)
     {
      Tragrt=SL;
     }
   else if(TP>0)
     {
      Tragrt=TP;
     }
   else
     {
      Tragrt=OpenPrice;
     }

   if(_OrderType==0)
     {
      //sum=((Tragrt-OpenPrice)*MathPow(10,Digits))*Lot;

      if(_mode==0) sum=(Tragrt-OpenPrice)/p*v*Lot;

      if(_mode==1) sum=(Tragrt-OpenPrice)/p*v/t/l*Lot;
      if(_mode==2) sum=(Tragrt-OpenPrice)/p*v*Lot;

      sum+=Com+Swap;
     }
   else if(_OrderType==1)
     {
      //sum=((OpenPrice-Tragrt)*MathPow(10,Digits))*Lot;

      if(_mode==0) sum=(OpenPrice-Tragrt)/p*v*Lot;

      if(_mode==1) sum=(OpenPrice-Tragrt)/p*v/t/l*Lot;
      if(_mode==2) sum=(OpenPrice-Tragrt)/p*v*Lot;

      sum+=Com+Swap;
     }
   return sum;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ConfirmProfitSet(int nm,double var)
  {
//Print(__FUNCTION__+" "+nm+" "+OrderPin);
   switch(nm)
     {
      case  1:
         ConfirmBuy=var;
         break;
      case  2:
         ConfirmSell=var;
         break;
      case  4:
         ConfirmBuyFollow=var;
         break;
      case  5:
         ConfirmSellFollow=var;
         break;
      default:
         Print(__FUNCTION__+" error is default");
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_Group_(int pin)
  {
//int CurrentMagic=_MagicEncrypt(v);
   double c=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      if(OrderMagic_Key==Magicnumber &&
         OrderMagic_Pin==pin &&
         OrderSymbol()==Symbol())
        {
         c+=OrderLots();
        }
     }
//c=c/2;
//if(c>lotsMsx)
//  {
//   c=lotsMsx;
//  }
   return NormalizeDouble(c,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _StayFriday0()
  {
   int H=TimeHour(TimeLocal());
   int M=TimeMinute(TimeLocal());
   int _DayOfWeek=TimeDayOfWeek(TimeLocal());
//Print(__FUNCTION__+_DayOfWeek);
   if((_DayOfWeek<=0 && H<=6 && M<=00) ||
      (_DayOfWeek>=5 && H>=21 && M>=00))
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

   SMS_Workday=_StayFriday_DayOfWeek(_DayOfWeek)+":"+string(_DayOfWeek)+" "+cFillZero(H)+"h:"+cFillZero(M)+"m | Running "+string(cntRunDay)+"day |"+cD(cntRunDay/20,2)+"mn  is a "+_strBoolYN;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _StayFriday_DayOfWeek(int var)
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
//|                                                                  |
//+------------------------------------------------------------------+
bool _StayNonfarm()
  {
   bool DayOn[]={false,true,true,true,true,true,false};
//int _DayOfWeek=TimeDayOfWeek(TimeLocal());
//int day=TimeDay(TimeLocal());

   int _DayOfWeek=0;
   int _Day=TimeDay(D'2018.02.3');

   P(__LINE__,"_StayNonfarm","_DayOfWeek",_DayOfWeek,"day",_DayOfWeek);
   P(__LINE__,"_StayNonfarm","day",_Day);

   bool r=true;
   for(int i=1;i<=_DayOfWeek+1;i++)
     {
      if(_Day==i)
        {
         r=false;
        }
     }
   P(__LINE__,"_StayNonfarm","r",r);
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _MagicEncrypt(int Type,int Sub)
  {
   string v=string(Magicnumber)+string(Type)+cFillZero(Sub);
//      P(__LINE__,"_MagicEncrypt","v",v);
   return int(v);
  }
//int OrderMagic_Key,OrderMagic_Pin,OrderMagic_Sub;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MagicDecode(int v)
  {
   string z=string(v);
//   P(__LINE__,"_MagicDecode","v",cI(v),"z",z);
   string d1=StringSubstr(z,0,StringLen(string(Magicnumber)));
   string d2=StringSubstr(z,StringLen(string(Magicnumber)),1);
   string d3=StringSubstr(z,StringLen(string(Magicnumber))+1,2);

   OrderMagic_Key=int(d1);
   OrderMagic_Pin=int(d2);
   OrderMagic_Sub=int(d3);

//P(__LINE__,"_MagicDecode","Key",OrderMagic_Key,"Pin",OrderMagic_Pin,"Sub",OrderMagic_Sub);
//P(__LINE__,"_MagicDecode","Key",d1,"Pin",d2,"Sub",d3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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

   _LabelSet("Text_Order3",370,65,clrBlack,"Franklin Gothic Medium Cond",10,"","");
   _LabelSet("Text_Order4",370,80,clrBlack,"Franklin Gothic Medium Cond",10,"","");
   _LabelSet("Text_Order5",370,95,clrBlack,"Franklin Gothic Medium Cond",10,"","");

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false)
         continue;
      _MagicDecode(OrderMagicNumber());
      _LabelSet("Text_Order5",370,95,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# Decode "+OrderMagic_Pin+" Sub:"+OrderMagic_Sub,"");
      if(OrderMagic_Key==Magicnumber &&
         OrderMagic_Pin==pin &&
         (OrderMagic_Sub==sub || specify) && 
         OrderSymbol()==Symbol())
        {
         if(Low__<OrderOpenPrice() && High_>OrderOpenPrice())
           {
            _LabelSet("Text_Order4",370,80,clrMagenta,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# LookAround--False p "+pin+" s "+sub,"");
            return false;
           }
        }
     }
   _LabelSet("Text_Order3",370,65,clrWhite,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# LookAround End--True p "+pin+" s "+sub,"");
   return true;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  _iCCI(
            string       symbol,           // symbol 
            int          timeframe,        // timeframe 
            int          period,           // averaging period 
            int          applied_price,    // applied price 
            int          shift,            // shift 
            double       set               // seting 
            )
  {

   double constant=iCCI(symbol,timeframe,period,applied_price,shift);

   if(constant>set || constant<(set*(-1)))
     {
      return false;
     }
   else
     {
      return true;
     }

  }
int OrderTicketClose[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderCloseActive(int v)
  {
   ArrayResize(OrderTicketClose,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());

      if(OrderMagic_Key==Magicnumber && OrderMagic_Pin==v && (OrderSymbol()==Symbol()) && (OrderType()<=1))
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
double ATR=0;
double ATR_Buy,ATR_BuyF;
double ATR_SeLL,ATR_SeLLF;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_byMM(int OP_Dir,int Cnt,int _Magazine,int nCase)
  {
   double Points=0;
//double Carry=5000/MathPow(10,Digits);
   double CONTRACT_SIZE=100000/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE);

   if(Cnt==0 || _getOrderLots_byMM_getCase(nCase)==0)
     {

      //ATR=iATR(Symbol(),PERIOD_MN1,3,2)+iATR(Symbol(),PERIOD_MN1,3,1)+iATR(Symbol(),PERIOD_MN1,3,0);
      //ATR=(ATR/3)*4;

      ATR=NormalizeDouble(500/MathPow(10,Digits),Digits);
      ATR=ATR+(iATR(Symbol(),PERIOD_MN1,3,0)+iATR(Symbol(),PERIOD_W1,3,0))/2;
      ATR=ATR*1.1;
      //ATR=ATR*MathPow(10,Digits);

      double MinATR=6000/MathPow(10,Digits);
      if(ATR<MinATR)
         ATR=MinATR;

      //ATR=6000/MathPow(10,Digits);

      if(OP_Dir==0)
        {
         if(nCase==1)
            ATR_Buy=Ask-ATR;
         else if(nCase==4)
            ATR_BuyF=Ask-ATR;
        }
      else if(OP_Dir==1)
        {
         if(nCase==2)
            ATR_SeLL=Bid+ATR;
         else if(nCase==5)
            ATR_SeLLF=Bid+ATR;
        }
     }

   double Mark=0;
   if(OP_Dir==0)
     {
      if(nCase==1)
        {
         Mark=ATR_Buy;
/*if(ATR_Buy>ATR_BuyF)
           {
            ATR_BuyF=ATR_Buy;
            HLineCreate_(0,"LINE_ATR"+cI(4),"LINE_ATR"+cI(4),0,ATR_BuyF,clrRed,0,1,0,true,false,0);
           }*/
        }
      else if(nCase==4)
        {
         Mark=ATR_BuyF;
/* if(ATR_BuyF>ATR_Buy)
           {
            ATR_Buy=ATR_BuyF;
            HLineCreate_(0,"LINE_ATR"+cI(1),"LINE_ATR"+cI(1),0,ATR_Buy,clrRed,0,1,0,true,false,0);
           }*/
        }

      HLineCreate_(0,"LINE_ATR"+cI(nCase),"LINE_ATR"+cI(nCase),0,Mark,clrPurple,0,1,0,true,false,0);
      Points=Ask-Mark;
     }
   else if(OP_Dir==1)
     {
      if(nCase==2)
        {
         Mark=ATR_SeLL;
/*if(ATR_SeLL<ATR_SeLLF)
           {
            ATR_SeLLF=ATR_SeLL;
            HLineCreate_(0,"LINE_ATR"+cI(5),"LINE_ATR"+cI(5),0,ATR_SeLLF,clrRed,0,1,0,true,false,0);
           }*/
        }
      else if(nCase==5)
        {
         Mark=ATR_SeLLF;
/* if(ATR_SeLLF<ATR_SeLL)
           {
            ATR_SeLL=ATR_SeLLF;
            HLineCreate_(0,"LINE_ATR"+cI(2),"LINE_ATR"+cI(2),0,ATR_SeLL,clrRed,0,1,0,true,false,0);
           }*/
        }

      HLineCreate_(0,"LINE_ATR"+cI(nCase),"LINE_ATR"+cI(nCase),0,Mark,clrMaroon,0,1,0,true,false,0);
      Points=Mark-Bid;
     }

   Points=NormalizeDouble(Points*MathPow(10,Digits),0);
//----------------------------------------------------------
//P(__LINE__,"Chk_TP","Point",Points,"Fund",FundPerBullet);
   double CALIBER=-1;
   bool Magazine=_MM_ChkMagazine(nCase,Cnt,_Magazine);
//Magazine=true;
   if(Points>0 && Magazine)
     {
      CALIBER=NormalizeDouble((FundPerBullet/Points)*1.618,5);
      if(OP_Dir==1)
        {
         //CALIBER=CALIBER*0.618;
        }

      CALIBER=NormalizeDouble(CALIBER*CONTRACT_SIZE,2);
     }
   return CALIBER;
  }
int MagazineBuy,MagazineSell;
int MagazineBuyF,MagazineSellF;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _MM_ChkMagazine(int nCase,int Cnt,int _Magazine)
  {
   _getOrderCNT_Sum_AtiveHub();
   if(Cnt>=_Magazine)
     {
      if(nCase==1 && MagazineBuyF-cntOrderFollowBuy>0)
        {
         //P(__LINE__,"MM","nCase",nCase,"MagazineBuyF",MagazineBuyF,"MagazineBuyF",MagazineBuyF);
         MagazineBuyF--;
         //MagazineBuy++;
         return true;
        }
      if(nCase==4 && MagazineBuy-cntOrderBuy>0)
        {
         //P(__LINE__,"MM","nCase",nCase,"MagazineBuy",MagazineBuy,"cntOrderBuy",cntOrderBuy);
         MagazineBuy--;
         //MagazineBuyF++;
         return true;
        }
      if(nCase==2 && MagazineSellF-cntOrderFollowSell>0)
        {
         //P(__LINE__,"MM","nCase",nCase,"MagazineSellF",MagazineSellF,"cntOrderFollowSell",cntOrderFollowSell);
         MagazineSellF--;
         //MagazineSell++;
         return true;
        }
      if(nCase==4 && MagazineSell-cntOrderSell>0)
        {
         //P(__LINE__,"MM","nCase",nCase,"MagazineSell",MagazineSell,"cntOrderSell",cntOrderSell);
         MagazineSell--;
         //MagazineSellF++;
         return true;
        }
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_byMM_getCase(int nCase)
  {
   double v=0;

   if(nCase==1)
      v=ATR_Buy;
   else if(nCase==4)
      v=ATR_BuyF;
   else if(nCase==2)
      v=ATR_SeLL;
   else if(nCase==5)
      v=ATR_SeLLF;

   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _iBar_getStatus(int v)
  {
   double vOpen=iOpen(NULL,0,v);
   double vClose=iClose(NULL,0,v);

   int r=true;
   if(vOpen>vClose)//is barDW
      r=false;

   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _iIKH_getChikouStatus(double _IKH_Chikou)
  {
   int r=0;
   double vOpen=iOpen(NULL,0,26);
   double vClose=iClose(NULL,0,26);
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
