//+------------------------------------------------------------------+
//|                                                     Divas-V2.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property description "Divas is PendingOrderStop Long&Short" 
#property description "BaseOn - ATR,RP,MarketDecide,BothPoint" 

#define EA_NAME "Divas V2"
double Trend;
#define TrendUP 1
#define TrendDW 2
#define TrendSW -1

#define Pin_Buy 1
#define Pin_Sel 2

#include <Tools/Method_Tools.mqh>

extern int Magicnumber=12;
extern double StopTrade=0;
extern ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//ATR_TimeFrame
extern lNumber WorstPont_ATRPeriod=lNumber_2;//ATR_Period

double cntOrderBuy_Act=0,cntOrderBuy_Pen=0;
double navOrderBuy=0;
double RP_OrderBuy=0;

double cntOrderSel_Act=0,cntOrderSel_Pen=0;
double navOrderSel=0;
double RP_OrderSel=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   setTemplate();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   _OrderDelete(Pin_Buy,cntOrderBuy_Pen,0);
   _OrderDelete(Pin_Sel,cntOrderSel_Pen,0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double ASK=Ask,BID=Bid,ATR;
bool boolRP_Buy=false,boolRP_Sel=false;
double OpenPrice_Buy,OpenPrice_Sel;

bool boolStopTrade=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ASK=Ask;
   BID=Bid;
   ATR=getART();

   HubNavigator();

   getOrderInformation(Magicnumber);
//---
   if(StopTrade==0 || (StopTrade>0 && AccountInfoDouble(ACCOUNT_BALANCE)<=StopTrade))
     {
      //setOpenPrice();
      double RP_Quality=ATR*0.25;
      boolRP_Buy=(
                  RP_OrderBuy==0 || 
                  (RP_OrderBuy>0 && (ASK<=RP_OrderBuy || (((ASK-RP_OrderBuy)>=RP_Quality) && (Trend==TrendUP))))
                  );

      boolRP_Sel=(
                  RP_OrderSel==0 || 
                  (RP_OrderSel>0 && (BID>=RP_OrderSel || (((BID-OpenPrice_Sel)>=RP_Quality) && (Trend==TrendDW))))
                  );

      //-------------
      if(Trend==TrendUP)
        {
         //_OrderSell();
         _Order_Buy();
        }
      else if(Trend==TrendDW)
        {
         _Order_Sell();
         //_OrderBuy();

        }
      else if(Trend==TrendSW)
        {
         _OrderDelete(1,cntOrderBuy_Pen,0);
         _OrderDelete(2,cntOrderSel_Pen,0);
        }
      //-----------
      if(cntOrderBuy_Act==0)
        {
         HLineDelete(0,"LINE__MindPending_Buy");
         if(RP_OrderBuy>0) HLineCreate_(0,"LINE__RP_Buy","",0,RP_OrderBuy,clrDarkGray,STYLE_DASHDOT,1,false,true,false,0);

        }
      if(cntOrderSel_Act==0)
        {
         HLineDelete(0,"LINE__MindPending_Sel");
         if(RP_OrderSel>0) HLineCreate_(0,"LINE__RP_Sel","",0,RP_OrderSel,clrDarkGray,STYLE_DASHDOT,1,false,true,false,0);
        }

     }
   else
     {
      boolStopTrade=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BetCoin_,BetCoin_Cal,BetCoin_Use,BetCoin_Start;
int HoldOrder_Buy=-1,HoldOrder_Sel=-1;
extern int HoldOrderCut_Time=4;
extern double HoldOrderCut_Per=0.1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __ChkOrderRiskParameter(int Direction,double cnt,int pin)
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
      _MagicDecode(Magicnumber,OrderMagicNumber());
      if(OrderMagic_Key==Magicnumber &&
         OrderMagic_Pin==pin &&
         OrderSymbol()==Symbol() && 
         OrderType()==Direction)
        {
         SumProduct+=OrderLots()*OrderOpenPrice();
         SumLot+=OrderLots();
         n++;
        }
     }
   double navCut=BetCoin_Use*HoldOrderCut_Per;

   if(SumLot!=0)
     {
      A=SumProduct/SumLot;
      if(_iNewBar(PERIOD_H4))
        {
         if(Direction==OP_BUY)
            HoldOrder_Buy++;
         if(Direction==OP_SELL)
            HoldOrder_Sel++;
         _LabelSet("Test_HoldOrder",CORNER_LEFT_LOWER,100,50,clrWhite,"Arial Black",10,c(__LINE__)+"# HoldOrder: "+cI(HoldOrder_Buy)+"|"+cI(HoldOrder_Sel)+"*"+cI(HoldOrderCut_Time)+"|"+cD(navCut,2)+"*","");
        }
     }
   else
     {
      A=1;
     }
   if((pin==Pin_Buy && navOrderBuy>=navCut) && 
      ((HoldOrder_Buy>=HoldOrderCut_Time && HoldOrderCut_Time>0)
      // || (Trend=TrendSW && cntOrderBuy_Act+cntOrderSel_Act==1)
      ))
     {
      _OrderX(Pin_Buy,n,100);
     }
   if((pin==Pin_Sel && navOrderSel>=navCut) && 
      ((HoldOrder_Sel>=HoldOrderCut_Time && HoldOrderCut_Time>0)
      //|| (Trend=TrendSW && cntOrderBuy_Act+cntOrderSel_Act==1)
      ))
     {
      _OrderX(Pin_Sel,n,100);
     }
   if(Direction==OP_BUY)
     {
      RP_OrderBuy=A;
      HLineCreate_(0,"LINE__RP_Buy","",0,A,clrRoyalBlue,STYLE_DASHDOT,1,false,true,false,0);
     }
   if(Direction==OP_SELL)
     {
      RP_OrderSel=A;
      HLineCreate_(0,"LINE__RP_Sel","",0,A,clrTomato,STYLE_DASHDOT,1,false,true,false,0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getOrderInformation(int _Key)
  {
   cntOrderBuy_Act=0;
   cntOrderBuy_Pen=0;

   cntOrderSel_Act=0;
   cntOrderSel_Pen=0;

   navOrderBuy=0;
   navOrderSel=0;
//---
   double _mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE); //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   double l=MarketInfo(Symbol(),MODE_LOTSIZE);
   double p=MarketInfo(Symbol(),MODE_POINT);
   double t=MarketInfo(Symbol(),MODE_TICKSIZE);
   double v=MarketInfo(Symbol(),MODE_TICKVALUE);
//---
   int sub=-1;
   int Carry_Sub=sub;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(_Key,OrderMagicNumber());

      if(sub<0)Carry_Sub=OrderMagic_Sub;

      if(OrderSymbol()==Symbol() && (OrderMagic_Key==_Key && OrderMagic_Sub==Carry_Sub))
        {
         if(OrderType()<=1)
           {
            if(OrderType()==OP_BUY && OrderMagic_Pin==Pin_Buy)
              {
               if(_mode==0) navOrderBuy+=(Bid-OrderOpenPrice())/p*v*OrderLots();

               if(_mode==1) navOrderBuy+=(Bid-OrderOpenPrice())/p*v/t/l*OrderLots();
               if(_mode==2) navOrderBuy+=(Bid-OrderOpenPrice())/p*v*OrderLots();
               navOrderBuy+=OrderCommission()+OrderSwap();
               cntOrderBuy_Act++;
              }
            if(OrderType()==OP_SELL && OrderMagic_Pin==Pin_Sel)
              {
               if(_mode==0) navOrderSel+=(OrderOpenPrice()-Ask)/p*v*OrderLots();

               if(_mode==1) navOrderSel+=(OrderOpenPrice()-Ask)/p*v/t/l*OrderLots();
               if(_mode==2) navOrderSel+=(OrderOpenPrice()-Ask)/p*v*OrderLots();
               navOrderSel+=OrderCommission()+OrderSwap();
               cntOrderSel_Act++;
              }
           }
         if(OrderType()>1)
           {
            if(OrderMagic_Pin==Pin_Buy)
               cntOrderBuy_Pen++;
            if(OrderMagic_Pin==Pin_Sel)
               cntOrderSel_Pen++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderDelete(int v,double cnt,int set)
  {
   int OrderTicketDelete[1];
   if(cnt>set)
     {
      ArrayResize(OrderTicketDelete,OrdersTotal());

      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         _MagicDecode(Magicnumber,OrderMagicNumber());
         if(OrderMagic_Key==Magicnumber && OrderMagic_Pin==v &&
            (OrderSymbol()==Symbol()) && (OrderType()>1))
           {
            OrderTicketDelete[pos]=OrderTicket();
            break;
           }
        }
      //---

      for(int i=0;i<ArraySize(OrderTicketDelete);i++)

        {
         if(OrderTicketDelete[i]>0)
           {
            if(OrderSelect(OrderTicketDelete[i],SELECT_BY_TICKET)==true)
              {
               bool z=OrderDelete(OrderTicketDelete[i]);
               if(GetLastError()==0){OrderTicketDelete[i]=0;}
              }
           }
        }
      ArrayResize(OrderTicketDelete,1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderX(int v,double cnt,double Size)
  {
   int OrderTicketX[1];
   ArrayResize(OrderTicketX,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(Magicnumber,OrderMagicNumber());
      if(OrderMagic_Key==Magicnumber && OrderMagic_Pin==v &&
         (OrderSymbol()==Symbol()) && (OrderType()<=1))
        {
         OrderTicketX[pos]=OrderTicket();
        }
     }
//---

   for(int i=0;i<ArraySize(OrderTicketX);i++)
     {
      if(OrderTicketX[i]>0)
        {
         if(OrderSelect(OrderTicketX[i],SELECT_BY_TICKET)==true)
           {
            P(__LINE__,__FUNCTION__,"OrderTicketX[i]",OrderTicketX[i]);
            _LabelSet("Text_Order1",CORNER_LEFT_LOWER,100,60,clrRed,"Arial Black",10,cI(__LINE__)+"# "+cD(OrderProfit(),2),"");
            bool z=OrderClose(OrderTicketX[i],NormalizeDouble(OrderLots()*(Size/100),2),Bid,100);
            if(GetLastError()==0){OrderTicketX[i]=0;}
           }
        }
     }
   ArrayResize(OrderTicketX,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getART()
  {
   if(iATR(Symbol(),TimeFrame,WorstPont_ATRPeriod,0)<350*Point)
     {
      //return 0;
     }
   return (
           (iATR(Symbol(),TimeFrame,WorstPont_ATRPeriod,2)*2.5)+
           (iATR(Symbol(),TimeFrame,WorstPont_ATRPeriod,1)*2.5)+
           (iATR(Symbol(),TimeFrame,WorstPont_ATRPeriod,0)*10)
           )/15;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HubNavigator()
  {
   double v1,v2;
   v1=getMA(PERIOD_H4,30);
   v2=Degrees_iRSI(PERIOD_H1,25);

   double DegreesCut=30;
   Trend=TrendSW;
   if(v1==1)
     {
      if(v2>DegreesCut)Trend=TrendUP;
      //else if(v2<DegreesCut*-1)TN="DW";
     }
   else if(v1==2)
     {
      if(v2<DegreesCut*-1)Trend=TrendDW;
     }

//Sms+="\n\n"+v1+" | "+v2+" #"+TN;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMA(ENUM_TIMEFRAMES TF,int MaxScan)
  {
//---
   double MA_Quality;
   double MA_Main,MA_Curs,MA_C;
//---
   bool Month_UP=true,Month_DW=true;
   int Mark_Buy=-1,Mark_Sel=-1;
   double MarkATR_Buy=-1,MarkATR_Sel=-1;
//---
//MA_Quality=getART();
   MA_Quality=0;
   for(int i=0;i<=MaxScan;i++)
     {
      MA_Main=iMA(Symbol(),TF,300,1,MODE_SMA,PRICE_WEIGHTED,i);
      MA_Curs=iMA(Symbol(),TF,150,1,MODE_SMA,PRICE_WEIGHTED,i);
      MA_C=iMA(Symbol(),TF,1,1,MODE_SMA,PRICE_WEIGHTED,i);

      if((MA_Curs-MA_Main>MA_Quality) && MA_C>MA_Main && Month_UP)
        {
         Month_UP=true;
        }
      else
        {
         Month_UP=false;
         Mark_Buy=i;
         MarkATR_Buy=MA_Quality;
        }
      //---
      if((MA_Main-MA_Curs>MA_Quality) && MA_C<MA_Main && Month_DW)
        {
         Month_DW=true;
        }
      else
        {
         Month_DW=false;
         Mark_Sel=i;
         MarkATR_Sel=MA_Quality;
        }
     }

/*Sms+="MaxScanMA: "+c(MaxScan)+"\n";
   Sms+="Buy: "+c(Month_UP)+" | "+c(Mark_Buy)+" | "+c(MarkATR_Buy,Digits)+"\n";
   Sms+="Sell: "+c(Month_DW)+" | "+c(Mark_Sel)+" | "+c(MarkATR_Sel,Digits)+"\n";*/

   if(Month_UP && !Month_DW)
     {
      return 1;
     }
   else if(!Month_UP && Month_DW)
     {
      return 2;
     }
   else
     {
      return 0;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Degrees_iRSI(ENUM_TIMEFRAMES TF,double x1)
  {
   double Degrees;
   double _n=5;
   double _Slope=0,_Step=x1/_n;
//---
   double _Strat=x1,_End;
   double y1,y2;
//---
   for(int i=0;i<_n;i++)
     {
      _End=_Strat-_Step;
      y1=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(_Strat));
      y2=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(_End));
      //---
      _Slope+=(y2-y1)/(_Strat-_End);
      //---
      _Strat=_End;
     }
//---
   y1=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(x1));
   y2=iRSI(Symbol(),TF,14,PRICE_CLOSE,int(0));
   _Slope+=(y2-y1)/x1;
//   
   _Slope/=_n+1;
//---
   double _Degrees=0;
   Degrees=NormalizeDouble((_Slope*180)/M_PI,2);

   if(Degrees<0) _Degrees=360+Degrees;
   else _Degrees=Degrees;

/*Sms+="\nRSI "+c(x1,0)+"n #";
   Sms+=c(Degrees,2)+"° | "+c(_Degrees,2)+"°";*/
//---
   return Degrees;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _Order_Buy()
  {
   if((cntOrderBuy_Act+cntOrderBuy_Pen)==0 && boolRP_Buy)
     {
      //HoldOrder_Buy=-1;
      CreatePending_Buy(OP_BUYSTOP,OpenPrice_Buy);
     }
   else
     {
      if((MindPending_Buy>ASK || MindPending_Buy==0) && cntOrderBuy_Pen==1)
        {
         CreatePending_Buy(OP_BUYSTOP,OpenPrice_Buy);
        }
      if(cntOrderBuy_Act>=1)
        {
         __ChkOrderRiskParameter(OP_BUY,cntOrderBuy_Act,Pin_Buy);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _Order_Sell()
  {
   if((cntOrderSel_Act+cntOrderSel_Pen)==0 && boolRP_Sel)
     {
      HoldOrder_Sel=-1;
      CreatePending_Sel(OP_SELLSTOP,OpenPrice_Sel);
     }
   else
     {
      if((MindPending_Sel<BID || MindPending_Sel==0) && cntOrderSel_Pen==1)
        {
         CreatePending_Sel(OP_SELLSTOP,OpenPrice_Sel);
        }
      if(cntOrderSel_Act>=1)
        {
         __ChkOrderRiskParameter(OP_SELL,cntOrderSel_Act,Pin_Sel);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePending_Buy(int OP,double OpenPrice_)
  {
   _MindPending_Buy(ASK);

   _OrderDelete(Pin_Buy,cntOrderBuy_Pen,0);

   int MGN_=_MagicEncrypt(Magicnumber,Pin_Buy,int(cntOrderBuy_Act));
   string COMM=EA_NAME+"["+cI(MGN_)+"]";

   double lot=NormalizeDouble(getLots(OP_BUY,cntOrderBuy_Act),2);

   double TakeTP=NormalizeDouble(OpenPrice_+(ATRUse),Digits);
   double TakeSL=NormalizeDouble(OpenPrice_-(ATRUse),Digits);
   TakeSL=0;
//---
   if(lot>0)
     {
      zx=OrderSend(Symbol(),OP,lot,OpenPrice_,168,TakeSL,TakeTP,COMM,MGN_,0);
      if(Test_RP_BeforeAfter)
        {
         RP_OrderBuy=OpenPrice_;
         HLineCreate_(0,"LINE__RP_Buy","",0,RP_OrderBuy,clrDarkGray,STYLE_DASHDOT,1,false,true,false,0);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePending_Sel(int OP,double OpenPrice_)
  {
   _MindPending_Sel(BID);

   _OrderDelete(Pin_Sel,cntOrderSel_Pen,0);

   int MGN_=_MagicEncrypt(Magicnumber,Pin_Sel,int(cntOrderSel_Act));
   string COMM=EA_NAME+"["+cI(MGN_)+"]";

   double lot=NormalizeDouble(getLots(OP_SELL,cntOrderSel_Act),2);

   double TakeTP=NormalizeDouble(OpenPrice_-(ATRUse),Digits);
   double TakeSL=NormalizeDouble(OpenPrice_+(ATRUse),Digits);
//---
   TakeSL=0;
   if(lot>0)
     {
      zx=OrderSend(Symbol(),OP,lot,OpenPrice_,168,TakeSL,TakeTP,COMM,MGN_,0);
      if(Test_RP_BeforeAfter)
        {
         RP_OrderSel=OpenPrice_;
         HLineCreate_(0,"LINE__RP_Sel","",0,RP_OrderSel,clrDarkGray,STYLE_DASHDOT,1,false,true,false,0);
        }
     }
  }
double MindPending_Buy=0,MindPending_Sel=0;
double MindPending_Mind=MarketInfo(Symbol(),MODE_STOPLEVEL);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MindPending_Buy(double Price)
  {
   MindPending_Buy=NormalizeDouble(Price-(MindPending_Mind*Point),Digits);
   HLineCreate_(0,"LINE__MindPending_Buy","MindPending_Buy "+cD(MindPending_Buy,Digits),0,MindPending_Buy,clrYellow,0,1,true,false,false,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MindPending_Sel(double Price)
  {
   MindPending_Sel=NormalizeDouble(Price+(MindPending_Mind*Point),Digits);
   HLineCreate_(0,"LINE__MindPending_Sel","MindPending_Sel "+cD(MindPending_Sel,Digits),0,MindPending_Sel,clrYellow,0,1,true,false,false,0);
  }
//+------------------------------------------------------------------+
