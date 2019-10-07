//|                                                    B_IKH_ATR.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |

#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include "Method_MQL4.mqh";
#include "Method_Tools.mqh";

extern int Magicnumber=81;
extern double Fund=120;
extern int ValueIKH_1=9,ValueIKH_2=26,ValueIKH_3=104;
extern double Blood_n=20;

int cntM0,xcntM0;
int cntM1,xcntM1;
int cntM5,xcntM5;
int cntM15,xcntM15;
int cntM30,xcntM30;
int cntH1,xcntH1;
int cntH4,xcntH4;
int cntD1,xcntD1;

string _ActCurrency=" "+AccountCurrency();
double ProfitAVGPC_Fund,ProfitAVG_Runday;
double cntRunDay;
double vSpread=100/MathPow(10,Digits);

double _PriceMax_Sell,_PriceMin_Sell;
double _PriceMax__Buy,_PriceMin__Buy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   printf("//+---------------------------------------------------------------+");
//--- create timer
   EventSetTimer(60);
   setTemplate();
   setBackgroundPanel("BgroundGG","gg",110,0,2,20);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
bool sz;
int MajorTrend=1;
double sumConfirm;

double IKH_Chikou,IKH_Tenkan,IKH_Kijun_;
double IKH_CloudUP,IKH_CloudDW;
double SMA_1;

bool IKH_StatusDIR1,IKH_StatusDIR2,IKH_StatusDIR3;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnTick()
  {
   xcntD1=iBars(Symbol(),PERIOD_D1);
   if(cntD1!=xcntD1)
     {
      cntD1=xcntD1;
      cntRunDay++;
      //---
     }
//---
   int IKH_PERIOD_1=0,IKH_PERIOD_2=0;
   IKH_Chikou/*Yelow*/=iIchimoku(NULL,IKH_PERIOD_1,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_CHIKOUSPAN,26);
   IKH_Tenkan/*Red__*/=iIchimoku(NULL,IKH_PERIOD_1,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_TENKANSEN,0);
   IKH_Kijun_/*Blue_*/=iIchimoku(NULL,IKH_PERIOD_1,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_KIJUNSEN,0);

   IKH_CloudUP/*Blue_*/=iIchimoku(NULL,IKH_PERIOD_2,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_SENKOUSPANA,-26);
   IKH_CloudDW/*Red__*/=iIchimoku(NULL,IKH_PERIOD_2,ValueIKH_1,ValueIKH_2,ValueIKH_3,MODE_SENKOUSPANB,-26);

   SMA_1=iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,1);

   string SMS;
   _getOrderCNT_AtiveHub();
   __OrderChkTP_MMea();
//---
   double Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);

   double Profit=NormalizeDouble(Current_BALANCE-Fund,2);

   if(Fund==0)Fund=1;
   double ProfitPC_Fund=NormalizeDouble((Profit/Fund)*100,2);

   if(cntRunDay==0)cntRunDay=1;
   ProfitAVG_Runday=(Profit)/cntRunDay;
   if(ProfitAVG_Runday>0)
      ProfitAVGPC_Fund=(ProfitAVG_Runday/Fund)*100;

//ProfitAVG=NormalizeDouble(ProfitAVG*35,2);

   double Current_Hold=AccountInfoDouble(ACCOUNT_PROFIT);
   _getDrawDown(Current_Hold,Current_BALANCE);

   SMS+=SMS_Workday+"\n";
   SMS+="\nProfit : "+Comma(Current_Hold,2," ")+_ActCurrency;
   SMS+="\nBalace : "+Comma(Current_BALANCE,2," ")+" | "+cD(ProfitPC_Fund,2)+"% PerDay : [ "+cD(ProfitAVGPC_Fund,4)+"% | "+cD(ProfitAVG_Runday,2)+_ActCurrency+" ]";
   SMS+="\n\nDD : "+cD(MaxDrawDown,2)+_ActCurrency+" DD/F:"+cD(MaxDrawDownPCFund,2)+"%|DD/P:"+cD(MaxDrawDownPCPort,2)+"% ["+string(DateMaxDrawDown)+"]";
   SMS+="\nPT : "+cD(MaxProfit,2)+_ActCurrency;
//---
   sumConfirm=ConfirmBuy+ConfirmSell+ConfirmBuyFollow+ConfirmSellFollow;

   SMS+="\n------";
   SMS+="\nIKH: "+cI(cntAll)+" : "+Comma(sumHoldAll,2," ");
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(sumConfirm>0)
     {
      SMS+="*"+Comma(sumConfirm,2,"")+"*";
     }
   SMS+="\n";

   if(cntOrderBuy>0 || cntOrderSell>0)
      SMS+="\nNormal-";
   SMS+=strZeroKey(" Buy [ "+cI(cntOrderBuy)+" ] : "+Comma(sumHoldBuy,2," "),cntOrderBuy)+strZero(ConfirmBuy,"*","*");

   if(cntOrderBuy>0 && cntOrderSell>0)
      SMS+=" |";
   SMS+=strZeroKey(" Sell [ "+cI(cntOrderSell)+" ] : "+Comma(sumHoldSell,2," "),cntOrderSell)+strZero(ConfirmSell,"*","*");

   if(cntOrderBuyF>0 || cntOrderSellF>0)
      SMS+="\nFollow--";
   SMS+=strZeroKey(" Buy [ "+cI(cntOrderBuyF)+" ] : "+Comma(sumHoldBuyF,2," "),cntOrderBuyF)+strZero(ConfirmBuyFollow,"*","*");

   if(cntOrderBuyF>0 && cntOrderSellF>0)
      SMS+=" |";
   SMS+=strZeroKey(" Sell [ "+cI(cntOrderSellF)+" ] : "+Comma(sumHoldBuyF,2," "),cntOrderSellF)+strZero(ConfirmSellFollow,"*","*");

   SMS+="\n";

   SMS+="\nATR : "+cD(ATR_MN,Digits);

   IKH_StatusDIR1=_iIKH_getChikouStatus(IKH_Chikou);
   SMS+="\nChikou : "+cD(IKH_Chikou,Digits)+"   |DIR1 : "+ConvertNumTOTrend(IKH_StatusDIR1);

   IKH_StatusDIR2=true;
   if(IKH_Tenkan<IKH_Kijun_)IKH_StatusDIR2=false;
   SMS+="\nTenkan : "+cD(IKH_Tenkan,Digits);
   SMS+="\nKijun_ : "+cD(IKH_Kijun_,Digits)+"   |DIR2 : "+ConvertNumTOTrend(IKH_StatusDIR2);
   SMS+="\n";
   IKH_StatusDIR3=true;
   if(IKH_CloudUP<IKH_CloudDW)IKH_StatusDIR3=false;
   SMS+="\nCloudUP: "+cD(IKH_CloudUP,Digits);
   SMS+="\nCloudDW: "+cD(IKH_CloudDW,Digits)+"   |DIR3 : "+ConvertNumTOTrend(IKH_StatusDIR3);
   SMS+="\n";
   SMS+="\nSMA_1: "+cD(SMA_1,Digits);
//---
   OrderOpen();
//---
   Comment(SMS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
bool _iIKH_getTenkanMAStatus(double _IKH_Tenkan)
  {
   double _SMA_1=iMA(NULL,0,1,-12,MODE_EMA,PRICE_CLOSE,19);

   int r=true;
   if(_SMA_1>_IKH_Tenkan)//is barUP
     {
      r=false;
     }

   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool iSar_getStatus(double i,int v)
  {
   double vSar=iSAR(NULL,0,i,0.2,v);
   double vClose=iClose(NULL,0,v);

   bool r=true;
   if(vSar>vClose)
      r=false;

   return false;
  }

int cntAll;
int cntOrderBuy,cntOrderSell;
int cntOrderBuyF,cntOrderSellF;
double sumHoldAll;
double sumHoldBuy,sumHoldSell;
double sumHoldBuyF,sumHoldSellF;
//---
void _getOrderCNT_AtiveHub()
  {
   cntOrderBuy=int(_getOrderCNT_Ative(1,"Cnt"));
   cntOrderSell=int(_getOrderCNT_Ative(2,"Cnt"));

//cntOrderFollowBuy=int(_getOrderCNT_Ative(4,"Cnt"));
//cntOrderFollowSell=int(_getOrderCNT_Ative(5,"Cnt"));
//---
   sumHoldBuy=_getOrderCNT_Ative(1,"Sum");
   sumHoldSell=_getOrderCNT_Ative(2,"Sum");

//sumOrderFollowBuy=_getOrderCNT_Ative(4,"Sum");
//sumOrderFollowSell=_getOrderCNT_Ative(5,"Sum");
//---
   cntAll=cntOrderBuy+cntOrderSell;
//cntAll+=cntOrderFollowBuy+cntOrderFollowSell;
//---
   sumHoldAll=sumHoldBuy+sumHoldSell;
//sumOrder+=sumOrderFollowBuy+sumOrderFollowSell;

   sumHoldAll=NormalizeDouble(sumHoldAll,2);
//---
//if(((sumOrder/Fund)*100)>=4)
//{
//_orderCloseActive(1);
//_orderCloseActive(2);
//_orderCloseActive(4);
//_orderCloseActive(5);
//}
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderCNT_Ative(int mn,string mode)
  {
   int CurrentMagic=_MagicEncrypt(mn);
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==CurrentMagic && OrderType()<=1)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
double ATR_MN=0;
double ATR_Buy,ATR_BuyF;
double ATR_SeLL,ATR_SeLLF;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots_getCase(int nCase)
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
double _getOrderLots_WorstPoint(int OP_Dir,int Cnt,int nCase)
  {
   double Points=0;
   if(Cnt==0 || _getOrderLots_getCase(nCase)==0)
     {

      ATR_MN=iATR(Symbol(),PERIOD_MN1,3,26)+iATR(Symbol(),PERIOD_MN1,3,1)+iATR(Symbol(),PERIOD_MN1,3,0);
      ATR_MN=(ATR_MN/3)*1.5;

      if(nCase==1)
         ATR_Buy=Ask-ATR_MN;
      else if(nCase==4)
         ATR_BuyF=Ask-ATR_MN;
      else if(nCase==2)
         ATR_SeLL=Bid+ATR_MN;
      else if(nCase==5)
         ATR_SeLLF=Bid+ATR_MN;
     }

   double Mark=0;
   if(OP_Dir==0)
     {
      if(nCase==1)
         Mark=ATR_Buy;
      else if(nCase==4)
         Mark=ATR_BuyF;

      HLineCreate_(0,"LINE_ATR_Buy"+cI(nCase),"LINE_ATR_Buy"+cI(nCase),0,Mark,clrRed,0,1,0,true,false,0);
      Points=Ask-Mark;
     }
   else if(OP_Dir==1)
     {
      if(nCase==2)
         Mark=ATR_SeLL;
      else if(nCase==5)
         Mark=ATR_SeLLF;

      HLineCreate_(0,"LINE_ATR_SeLL"+cI(nCase),"LINE_ATR_SeLL"+cI(nCase),0,Mark,clrRed,0,1,0,true,false,0);
      Points=Mark-Bid;
     }

   Points=NormalizeDouble(Points*MathPow(10,Digits),0);
   printf("Points "+Points);
   return Points;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderLots(int _MajorTrend,int OP_Dir,int _Case,int Cnt)
  {

   double _Lots=0;
//---
   double Current_BALANCE=AccountInfoDouble(ACCOUNT_BALANCE);
   double r=Current_BALANCE-(sumHoldAll*5);

   r=((r/100)*Blood_n)/_getOrderLots_WorstPoint(OP_Dir,Cnt,_Case);
   r=NormalizeDouble(r,5);

   double CONTRACT_SIZE=100000/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE);
   _Lots=r*CONTRACT_SIZE;
//---
   if(_MajorTrend>=0)
     {
      if(_MajorTrend!=OP_Dir)
        {
         if(Cnt==0)
           {
            _Lots=_Lots*0.236;
           }
         else
           {
            //_Lots=_Lots*1.236;
           }
        }
      //GetSumLotsForCoverLoss
     }
   else
     {
      _Lots=-1;
     }
   _Lots=NormalizeDouble(_Lots,2);
   printf("Major: "+cI(_MajorTrend)+" | Case: "+cI(OP_Dir)+" | r: "+cD(_Lots,2));
   return _Lots;
  }
double MaxDrawDown=99999,MaxDrawDownPCFund,MaxDrawDownPCPort;
datetime DateMaxDrawDown;
double MaxProfit=-99999;
datetime DateMaxProfit;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getDrawDown(double hold,double balance)
  {
   if(hold>MaxProfit)
     {
      MaxProfit=hold;

     }
   if(hold<MaxDrawDown)
     {
      MaxDrawDown=hold;
      MaxDrawDownPCFund=NormalizeDouble((MaxDrawDown/Fund)*100,2);
      MaxDrawDownPCPort=0;
      if(balance>0)
         MaxDrawDownPCPort=NormalizeDouble((MaxDrawDown/balance)*100,2);
      DateMaxDrawDown=TimeLocal();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ConvertNumTOTrend(bool v)
  {
   string r="UP";
   if(v==false)
      r="DW";

   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _setMajorTrend(int DIR1,int DIR2,int DIR3)
  {
   int r;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(//DIR1==0 && 
      DIR2==0 &&
      DIR3==0)
     {
      r=0;
     }
   else if(
      //DIR1==1 && 
      DIR2==1 &&
      DIR3==1)
        {
         r=1;
        }
      else
        {
         r=-1;
        }
   return r;
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
//   _PriceMax__FollowBuy= _getOrderPriceMaxMin("Max",4);
//   _PriceMin__FollowBuy= _getOrderPriceMaxMin("Min",4);
//
//   _PriceMax_FollowSell=_getOrderPriceMaxMin("Max",5);
//   _PriceMin_FollowSell= _getOrderPriceMaxMin("Min",5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getOrderPriceMaxMin(string v,int nm)
  {
   int _MagicNumber=_MagicEncrypt(nm);

   double MinPrice=99999,MaxPrice=-99999;

   for(int pos=0;pos<OrdersTotal();pos++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*if(MinPrice==99999)
      MinPrice=0;
   if(MaxPrice==-99999)
      MaxPrice=0;*/

//printf("[_isLastBas()]# Max : "+MaxPrice+" Min : "+MinPrice);
   if("Max"==v)
     {
      return  MaxPrice;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if("Min"==v)
     {
      return  MinPrice;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __OrderChkTP_MMea()
  {
   if(cntOrderBuy==0)
     {
      OrderStopLossBuy=0;
      ConfirmBuy=0;
      HLineDelete(0,"LINE_Point1");
      HLineDelete(0,"LINE_Save1");
      HLineDelete(0,"LINE_SL1");

      //HLineDelete(0,"LINE_ATR_Buy1");

      HLineDelete(0,"Text_MM1");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(cntOrderSell==0)
     {
      OrderStopLossSell=0;
      ConfirmSell=0;
      HLineDelete(0,"LINE_Point2");
      HLineDelete(0,"LINE_Save2");
      HLineDelete(0,"LINE_SL2");

      //HLineDelete(0,"LINE_ATR_SeLL2");

      HLineDelete(0,"Text_MM3");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(cntOrderBuy>=1)
     {
      __OrderChkTP("Buy",cntOrderBuy,1);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(cntOrderSell>=1)
     {
      __OrderChkTP("Sell",cntOrderSell,2);
     }
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
         break;
      case  2:
         OrderPointSell=s;
         break;
      case  4:
         //OrderPointFollowBuy=s;
         break;
      case  5:
         //OrderPointFollowSell=s;
         break;
      default:
         break;
     }
  }
double SumLot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculatePrice_Group(string Direction,int _MagicNumber)
  {
   _getOrderCNT_AtiveHub();
//---
   int CNT;
   if(Direction=="Buy")
     {CNT=cntOrderBuy;}
   else
     {CNT=cntOrderSell;}
//---
   double SumDeposit=0;
   double SumProduct=0,
   MinLot = 99999,
   Result = 0,
   Temp   = 0;

   SumLot=0;
   SumDeposit=0;

   for(int pos=0;pos<OrdersTotal();pos++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderMagicNumber()==_MagicNumber) && (OrderSymbol()==Symbol()))
        {

         SumDeposit+=_ConfirmProfitCalculate(OrderType(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderCommission(),OrderSwap());

         SumProduct+=OrderLots()*OrderOpenPrice();
         SumLot+=OrderLots();

         if(OrderLots()<MinLot)
           {
            MinLot=OrderLots();
           }
        }
     }

   _ConfirmProfitSet(_MagicNumber,SumDeposit);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(SumLot!=0)
     {
      Result=SumProduct/SumLot;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      return 1;
     }

   return NormalizeDouble(Result,Digits);
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(TP>0)
     {
      Tragrt=TP;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Tragrt=OpenPrice;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(_OrderType==0)
     {
      //sum=((Tragrt-OpenPrice)*MathPow(10,Digits))*Lot;

      if(_mode==0) sum=(Tragrt-OpenPrice)/p*v*Lot;

      if(_mode==1) sum=(Tragrt-OpenPrice)/p*v/t/l*Lot;
      if(_mode==2) sum=(Tragrt-OpenPrice)/p*v*Lot;

      sum+=Com+Swap;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

double ConfirmBuy,ConfirmSell;
double ConfirmBuyFollow,ConfirmSellFollow;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _ConfirmProfitSet(int nm,double var)
  {
   _MagicDecode(nm);
//Print(__FUNCTION__+" "+nm+" "+OrderPin);
   switch(OrderPin)
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
double _SPREAD;
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
void __OrderChkTP(string v,int cnt,int mn)
  {
//   _LabelSet("Text_MM0",10,100,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(iSAR(Symbol(),0,0.009,0.2,0)-Bid,Digits),"CNT[DiffPrice/DiffSL | UseTrailing]");

   int _MagicNumber=_MagicEncrypt(mn);
   _SPREAD=MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits);

//printf(__FUNCTION__+" "+string(_MagicNumber));
   int Direct=-1;
   string TestLoop;
   double Point_=_CalculatePrice_Group(v,_MagicNumber);
   setOrderPoint(mn,Point_);

//---
   string Tooltip=v;
   if(mn==4 || mn==5)
      Tooltip+="Follow";
//---

   color _clrPoint=clrWhite,_clrSL=clrWhite;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(v=="Buy")
     {
      _clrPoint=clrRoyalBlue;
      _clrSL=clrLightSkyBlue;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      _clrPoint=clrTomato;
      _clrSL=clrLightPink;
     }
   double DZP=0;
   double Trailing=-1;
   double TrailingStart=200;
   Trailing=Trailing/MathPow(10,Digits);
   TrailingStart=TrailingStart/MathPow(10,Digits);
   double SL=-1,SL2=-1,Diff=0,DiffSL=0;

   int _MagicNumber2=-1;
   int Direct2=-1;

   _getOrderCNT_AtiveHub();

   bool CHK__Merge=false;

/*   double Point_Buy,Point_Sell;
   double LotBuy,LotSell;
   double Point_Merge=-1;

   
if(cntOrderFollowBuy>0 && cntOrderFollowSell>0)
     {

      Point_Buy=_CalculatePrice_Group("Buy",_MagicEncrypt(4));
      LotBuy=SumLot;

      Point_Sell=_CalculatePrice_Group("Sell",_MagicEncrypt(5));
      LotSell=SumLot;

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

   double SumSupporter=1.5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!CHK__Merge)
     {
      //HLineDelete(0,"Point_Merge");
      if("Buy"==v)
        {
         Direct=OP_BUY;
         Diff=Bid-Point_;
         //---
         if(mn==1)
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
         TestLoop="";
         //TrailingStart=Trailing;
         //if((Diff>=TrailingStart && cnt==1) || (Diff>=Trailing && cnt>1))
         if(Diff>=Trailing)
           {
            TestLoop="*";
            if((OrderStopLossBuy<Bid-Trailing || OrderStopLossBuy==0) && _MagicNumber==_MagicEncrypt(1))
              {
               OrderStopLossBuy=Bid-Trailing;
               SL=OrderStopLossBuy;

               HLineCreate_(0,"LINE_Save"+cI(mn),"SL"+Tooltip+" \n"+cD(SL,Digits),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderBuy>0 && cntOrderSellF>0 && sumHoldBuy+sumHoldSellF>SumSupporter)
                 {
                  _MagicNumber2=5;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
               else if(cntOrderBuy>0 && cntOrderSell>0 && sumHoldBuy+sumHoldSell>SumSupporter)
                 {
                  _MagicNumber2=2;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
              }

            if((OrderStopLossFollowBuy<Bid-Trailing || OrderStopLossFollowBuy==0) && _MagicNumber==_MagicEncrypt(4))
              {
               OrderStopLossFollowBuy=Bid-Trailing;
               SL=OrderStopLossFollowBuy;

               HLineCreate_(0,"LINE_Save"+cI(mn),"SL"+Tooltip+" \n"+cD(SL,Digits),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderBuy>0 && cntOrderSell>0 && sumHoldBuyF>sumHoldSell>=SumSupporter)
                 {
                  _MagicNumber2=2;
                  Direct2=OP_SELL;

                  SL2=SL+_SPREAD;
                 }
               else if(cntOrderBuy>0 && cntOrderSellF>0 && sumHoldBuyF+sumHoldSellF>=SumSupporter)
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

         if(mn==1)
            _LabelSet("Text_MM1",10,65,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n Buy ["+cD(DZP_Buy,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM2",10,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n BuyF ["+cD(DZP_BuyFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

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
               _MagicNumber=_MagicEncrypt(1);
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
               _MagicNumber=_MagicEncrypt(1);
               _MagicNumber2=4;
               Direct=OP_BUY;
               Direct2=OP_BUY;
              }

           }
         _LabelSet("Text_MSL_B",200,50,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# SL Buy : "+cD(OrderStopLossBuy,Digits)+" | "+cD(OrderStopLossFollowBuy,Digits)+"   "+chk_Text_MSL,"");
         //---
        }
      else if("Sell"==v)
        {
         Direct=OP_SELL;
         Diff=(Point_-Ask);
         //---
         if(mn==2)
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
         TestLoop="";
         //TrailingStart=Trailing;
         //if((Diff>=TrailingStart && cnt==1) || (Diff>=Trailing && cnt>1))
         if(Diff>=Trailing)
           {
            TestLoop="*";
            if((OrderStopLossSell>Ask+Trailing || OrderStopLossSell==0) && _MagicNumber==_MagicEncrypt(2))
              {

               OrderStopLossSell=Ask+Trailing;
               SL=OrderStopLossSell;

               HLineCreate_(0,"LINE_Save"+cI(mn),"LINE_Save"+cI(mn),0,SL,_clrSL,0,1,0,true,false,0);

               if(cntOrderBuyF>0 && cntOrderSell>0 && sumHoldBuyF+sumHoldSellF>SumSupporter)
                 {
                  _MagicNumber2=4;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
               else if(cntOrderBuy>0 && cntOrderSell>0 && sumHoldBuy+sumHoldSell>SumSupporter)
                 {
                  _MagicNumber2=1;
                  Direct2=OP_BUY;

                  SL2=SL-_SPREAD;
                 }
              }
/*if((OrderStopLossFollowSell>Ask+Trailing || OrderStopLossFollowSell==0) && _MagicNumber==_MagicEncrypt(5))
              {

               OrderStopLossFollowSell=Ask+Trailing;
               SL=OrderStopLossFollowSell;

               HLineCreate_(0,"LINE_Save"+cI(mn),"LINE_Save"+cI(mn),0,SL,_clrSL,0,1,0,true,false,0);

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

              }*/
            //HLineCreate_(0,"LINE_SL"+c(mn),0,SL,clrTomato,0,1,true,true,false,0);
           }

         if(OrderStopLossSell>0)
            DiffSL=(OrderStopLossSell-Ask)*MathPow(10,Digits);
         if(OrderStopLossFollowSell>0)
            DiffSL=(OrderStopLossFollowSell-Ask)*MathPow(10,Digits);

         if(mn==2)
            _LabelSet("Text_MM3",10,35,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n Sell ["+cD(DZP_Sell,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");
         else
            _LabelSet("Text_MM4",10,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# "+cD(cnt,0)+"n SellF ["+cD(DZP_SellFollow,0)+"/"+cD(DiffSL,0)+" | "+cD(Trailing*MathPow(10,Digits),0)+"]"+TestLoop,"CNT[DiffPrice/DiffSL | UseTrailing]");

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
               _MagicNumber=_MagicEncrypt(2);
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
               _MagicNumber=_MagicEncrypt(2);
               _MagicNumber2=5;
               Direct=OP_SELL;
               Direct2=OP_SELL;
              }
           }
         _LabelSet("Text_MSL",200,20,clrYellow,"Franklin Gothic Medium Cond",10,cI(__LINE__)+"# SL Sell : "+string(OrderStopLossSell)+" | "+string(OrderStopLossFollowSell)+"   "+chk_Text_MSL,"");

         //---
        }
      //---
      HLineCreate_(0,"LINE_Point"+cI(mn),Tooltip+" | "+cD(DZP,0)+"p \n"+cD(Point_,Digits),0,Point_,_clrPoint,0,1,0,true,false,0);
      //---
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      _MagicNumber=_MagicEncrypt(4);
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
         if(OrderMagicNumber()==_MagicNumber)
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
            _OrderModifyForTrailing(SL2,_MagicEncrypt(_MagicNumber2),int(Direct2));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderModifyForTrailing(double _TP,int _MagicNumber,int _OrderType)
  {
//double SumDeposit=0;
   for(int pos=0;pos<OrdersTotal();pos++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()) && ((int)OrderType()==_OrderType))
        {

         if((_OrderType==OP_BUY && OrderStopLoss()<_TP) ||
            (_OrderType==OP_SELL && OrderStopLoss()>_TP)||
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
double ATR_CU=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculateTrailing(int cnt,double Diff)
  {
   double Trailing=-1;

   Diff=NormalizeDouble(Diff*MathPow(10,Digits),0);

//printf("--------------");
   double FiboRate[]={0,1.000,1.236,1.382,1.500,1.618,1.809,2.000};
   double TraiRate[]={0,0.809,0.618,0.500,0.382,0.236,0.118,0};

   ATR_CU=(iATR(Symbol(),0,3,26)+iATR(Symbol(),0,3,1)+iATR(Symbol(),0,3,0))/3;
   if(ATR_CU>=1000)
     {
      ATR_CU=1000;
     }
   ATR_CU=NormalizeDouble(ATR_CU*FiboRate[5]*MathPow(10,Digits),0);

//P(__LINE__,__FUNCTION__,"cnt",cI(cnt),"ATR",ATR);

   double LevelFibo=0,LevelFiboUse=0;
//P(__LINE__,__FUNCTION__,"Diff",Diff,"FiboRate[2]",NormalizeDouble(ATR*FiboRate[2],0));

   bool chkloop=false;
   for(int i=4;i<=7;i++)
     {
      LevelFibo=NormalizeDouble(ATR_CU*FiboRate[i],0);
      //P(__LINE__,__FUNCTION__,"Diff",Diff,"Level",LevelFibo,"Diff",TraiRate[i]*Diff);

      if(Diff<=LevelFibo)
        {
         chkloop=true;
         Trailing=NormalizeDouble(TraiRate[i]*ATR_CU,0);
         LevelFiboUse=LevelFibo;
         break;
        }
     }

//P(__LINE__,__FUNCTION__,"chkloop",chkloop,"Trailing",Trailing,"LevelFiboUse",cD(LevelFiboUse,7));

//---
   Trailing=(Trailing/cnt);
/*double W=50;
   if(cnt>1)
      Trailing=Trailing*(1+(W/100));*/

   double MinTrai_STOPLEVEL=(MarketInfo(Symbol(),MODE_STOPLEVEL)+(cnt/1))*1.236;
   if(Trailing<MinTrai_STOPLEVEL)
      Trailing=MinTrai_STOPLEVEL;

   Trailing=NormalizeDouble(Trailing/MathPow(10,Digits),Digits);
//P(__LINE__,__FUNCTION__,"R",Trailing);
   return Trailing;

  }
bool Workday,Workdayx;
string SMS_Workday;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _StayFriday()
  {
   int H=TimeHour(TimeLocal());
   int M=TimeMinute(TimeLocal());
   int _DayOfWeek=TimeDayOfWeek(TimeLocal());
//Print(__FUNCTION__+_DayOfWeek);
   if((_DayOfWeek<=0 && H<=6 /*&& M<=00*/) || (_DayOfWeek>=5 && H>=22/* && M<=00*/))
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

   SMS_Workday=_StayFriday(_DayOfWeek)+":"+string(_DayOfWeek)+" "+cFillZero(H)+"h:"+cFillZero(M)+"m | Running "+string(cntRunDay)+"day |"+cD(cntRunDay/20,2)+"mn  is a "+_strBoolYN;
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
void OrderOpen()
  {
   xcntM0=iBars(Symbol(),0);
   if(cntM0!=xcntM0)
     {
      _getOrderPriceMaxMinHub();
      _StayFriday();
      //Print("Turning bars");
      cntM0=xcntM0;
      //---
      MajorTrend=_setMajorTrend(IKH_StatusDIR1,IKH_StatusDIR2,IKH_StatusDIR3);
      MajorTrend=IKH_StatusDIR1;
      //---

      if(cntOrderBuy==0
         && _iBar_getStatus(1)==false
         //&& _iIKH_getTenkanMAStatus(IKH_Tenkan)==true
         //&& SMA_1<IKH_Tenkan
         && IKH_StatusDIR1==false && IKH_StatusDIR2==true
         )
        {
         sz=OrderSend(Symbol(),OP_BUY,_getOrderLots(MajorTrend,0,1,cntOrderBuy),Ask,100,0,0,"Buy"+cI(cntOrderBuy),_MagicEncrypt(1),0);
        }
      else if(cntOrderBuy>=1 && sumHoldBuy<0 && IKH_StatusDIR2==true)
        {
         if((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread)))
           {
            sz=OrderSend(Symbol(),OP_BUY,_getOrderLots(MajorTrend,0,1,cntOrderBuy),Ask,100,0,0,"Buy"+cI(cntOrderBuy),_MagicEncrypt(1),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Buy-2");
           }
        }

      if(cntOrderSell==0
         && _iBar_getStatus(1)==true
         //&& _iIKH_getTenkanMAStatus(IKH_Tenkan)==false
         //&& SMA_1>IKH_Tenkan
         && IKH_StatusDIR1==true && IKH_StatusDIR2==false
         )
        {
         sz=OrderSend(Symbol(),OP_SELL,_getOrderLots(MajorTrend,1,2,cntOrderSell),Bid,100,0,0,"Sell "+cI(cntOrderSell),_MagicEncrypt(2),0);
        }
      else if(cntOrderSell>=1 && sumHoldSell<0 && IKH_StatusDIR2==false)
        {
         if((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread)))
           {
            sz=OrderSend(Symbol(),OP_SELL,_getOrderLots(MajorTrend,1,2,cntOrderSell),Bid,100,0,0,"Sell "+cI(cntOrderSell),_MagicEncrypt(2),0);
            //printf(__FUNCTION__+" | "+c(__LINE__)+" Sell-2");
           }
        }
     }
  }
//+------------------------------------------------------------------+
