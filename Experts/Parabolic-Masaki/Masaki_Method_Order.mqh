//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |

#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "Masaki.mq4";
#include "Masaki_Value.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __orderPinHub()
  {
   __orderPin(4);
   __orderPin(5);
   if(Workday)
     {

     }
   else
     {
      //_orderDelete();
      //_orderCloseActive();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __orderCHKHub()
  {

   if(Workday)
     {
      //-----------
      __orderCHK(4);
      __orderCHK(5);
      //-----------
     }
   else
     {
      //--
      //_orderDelete();
      _orderCloseActive();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void __orderCHK(int v)
  {
   int CurrentMagic=-1,OP_Direct=-1;
   int v2=-1;

//---
   if(v==4)
      v2=5;
   if(v==5)
      v2=4;
//---

   _LabelSet("Move",380,80,clrWhite,"Franklin Gothic Medium Cond",15,string(_DirSarBack(2,4,v2))+" | "+string(_DirSarIn(2))+" | "+string(_DirSarIn(1))+" | "+string(_DirSarIn(0)));
   _LabelSet("_DirSarOut",380,60,clrWhite,"Franklin Gothic Medium Cond",15,string(_DirSarOut(2))+" | "+string(_DirSarOut(1))+" | "+string(_DirSarOut(0)));
   if(_getOrderInfo(v))
     {
      if(iOrderType<=1) //---Active
        {
/*if((_DirSarOut(2)==v) && (_DirSarOut(2)!=_DirSarOut(1)) && (_DirSarOut(1)==_DirSarOut(0)))
           {
            _orderCloseActive(v);
            --SentOrderReverse
            printf("-----------------------------------------------CloseActive_Sar["+string(__LINE__)+"]---");
           }*/
/*if(_calculateClose_Bands(_getOrderOpenPrice(v),v,0))
           {
            printf("-----------------------------------------------CloseActive_BB["+string(__LINE__)+"]---");
            _orderCloseActive(v);
            //--SentOrderReverse}*/

         double TP=_calculate_BandsNew2(iOrderOpenPrice,iOrderType,3);
         _myOrderModify(v,-1,iOrderStopLoss,TP);

        }
      else//----PendingOrder
        {
         //HLineDelete(0,"Line_TP");
         if(_DirSarIn(0)!=v)
           {
            _orderDelete(v);
           }
        }
     }
   else//+---------------------NewOrder---------------------+
     {
      //HLineDelete(0,"Line_TP");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _MagicEncrypt(int Type)
  {
   string v=string(Magicnumber)+string(Type);
   return int(v);
  }

int OrderTicketClose[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderCloseActive()
  {
   ArrayResize(OrderTicketClose,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());
      _getOrderInfo(OrderPin_);
      if((OrderMagic_==Magicnumber) && (OrderSymbol()==Symbol()) && (OrderType()<=1) && (iOrderProfit>0))
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
void _orderCloseActive(int v)
  {
   ArrayResize(OrderTicketClose,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());

      if(OrderMagic_==Magicnumber && OrderPin_==v && (OrderSymbol()==Symbol()) && (OrderType()<=1))
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

/*void _orderCloseX()
  {
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
  }*/

int OrderTicketDelete[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderDelete()
  {
   ArrayResize(OrderTicketDelete,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());

      if((OrderMagic_==Magicnumber) && (OrderSymbol()==Symbol()) && (OrderType()>1))
        {
         OrderTicketDelete[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderDelete(int v)
  {
   ArrayResize(OrderTicketDelete,OrdersTotal());

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      _MagicDecode(OrderMagicNumber());

      if(OrderMagic_==Magicnumber && OrderPin_==v && (OrderSymbol()==Symbol()) && (OrderType()>1))
        {
         OrderTicketDelete[pos]=OrderTicket();
         break;
        }
     }
//+---------------------------------------------------------------------+

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

/*void _orderDeleteX()
  {
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
  }*/

int OrderMagic_,OrderPin_;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MagicDecode(int v)
  {
   string z=string(v);
   string m=StringSubstr(z,0,StringLen(string(Magicnumber)));
   string o=StringSubstr(z,StringLen(string(Magicnumber)),1);
   OrderMagic_=int(m);
   OrderPin_=int(o);
  }

double Rate_Win=0,Rate_Lose=0,Rate=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _getWinLoes()
  {
   Rate_Win=0;Rate_Lose=0;Rate=0;
   for(int i=0;i<OrdersHistoryTotal();i++)

     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true)
        {
         if(OrderProfit()==0)
            continue;
         _MagicDecode(OrderMagicNumber());
         if((OrderMagic_==Magicnumber) && (OrderSymbol()==Symbol()))
            //if(OrderMagic_==1)
           {
            if(OrderProfit()>0)
               Rate_Win++;
            else
               Rate_Lose++;
           }
        }
     }

   if(Rate_Win>0)
     {
      Rate=(Rate_Win/(Rate_Win+Rate_Lose))*100;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _getOrderFind_(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         return true;
        }
     }
   return false;
  }

int iOrderTicket,iOrderType,iOrderMagicNumber;
double iOrderOpenPrice,iOrderTakeProfit,iOrderStopLoss,iOrderProfit;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _getOrderInfo(int v)
  {
   int CurrentMagic=_MagicEncrypt(v);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         iOrderTicket=OrderTicket();
         iOrderType=OrderType();

         iOrderOpenPrice=OrderOpenPrice();
         iOrderTakeProfit=OrderTakeProfit();
         iOrderStopLoss=OrderStopLoss();

         iOrderMagicNumber=OrderMagicNumber();

         iOrderProfit=OrderProfit();

         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _myOrderModify(int v,double PR,double SL,double TP)
  {
   int CurrentMagic=_MagicEncrypt(v);
   bool z=-1;

   TP=NormalizeDouble(TP,Digits);
   SL=NormalizeDouble(SL,Digits);

   for(int pos=0;pos<OrdersTotal();pos++)

     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderMagicNumber()==CurrentMagic && (OrderSymbol()==Symbol()))
        {
         if(PR<0)
           {
            PR=OrderOpenPrice();
           }
         if(OrderStopLoss()!=SL || OrderTakeProfit()!=TP)
           {
            z=OrderModify(OrderTicket(),PR,SL,TP,0);
            return z;
           }
        }
     }
   return z;
  }

bool FirstCall_TP_Buy=true,FirstCall_TP_Sell=true;
int iLine_TP_Buy,iLine_TP_Sell;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _calculate_BandsNew2(double Price,int Dir_OP,double GridTP)
  {
   int period=Period_BB,Shift=1;
   double TP=-1;
   double iRank=iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,1,Shift)-iBands(Symbol(),0,period,0,0,PRICE_TYPICAL,1,Shift);

   if(Dir_OP==0)//Buy
     {
      TP=Price+(iRank*GridTP);
     }
   else//Sell
     {
      TP=Price-(iRank*GridTP);
     }

   return NormalizeDouble(TP,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _calculate_BandsNew(double Price,int Dir_OP,int GridTP)
  {
   int period=Period_BB,Shift=1;
   int a=6;
   int z=a*(-1);

   double iBands_UP=0,iBands_DW=0,iBands_TP=0;
   int iLine_UP=0,iLine_DW=0,iLine_TP=0;

   if(FirstCall_TP_Buy)
     {
      for(int i=a;i>z;i--)
        {
         iBands_UP=iBands(Symbol(),0,period,i,0,PRICE_TYPICAL,1,Shift);
         iBands_DW=iBands(Symbol(),0,period,i-1,0,PRICE_TYPICAL,1,Shift);
         //---------------------------------------------------------------
         if(iBands_UP>Price && Price>iBands_DW)
           {
            iLine_UP=i;
            iLine_DW=i-1;
            break;
           }
        }
     }

   if(Dir_OP==0)//Buy
     {
      if(FirstCall_TP_Buy)
        {
         iLine_TP=iLine_UP+GridTP;
         iLine_TP_Buy=iLine_TP;

         FirstCall_TP_Buy=false;
        }
      else
        {
         iLine_TP=iLine_TP_Buy;
        }
     }
   else//Sell
     {
      if(FirstCall_TP_Sell)
        {
         iLine_TP=iLine_DW-GridTP;
         iLine_TP_Sell=iLine_TP;

         FirstCall_TP_Sell=false;
        }
      else
        {
         iLine_TP=iLine_TP_Sell;
        }
     }
   iBands_TP=iBands(Symbol(),0,period,iLine_TP,0,PRICE_TYPICAL,1,Shift);

   string SMS,SMS2;
   SMS+="TP : "+_Comma(iBands_TP,Digits,"")+" | ";

   SMS2+="SaveBUY"+c(FirstCall_TP_Buy)+" | "+c(iLine_TP_Buy)+" | "+c(iLine_TP);
   SMS2+=" ----- ";
   SMS2+="SaveSell"+c(FirstCall_TP_Sell)+" | "+c(iLine_TP_Sell)+" | "+c(iLine_TP);

   _LabelSet("TextBBNew1",500,30,clrGold,"Arial",15,SMS);
   _LabelSet("TextBBNew2",500,50,clrGold,"Arial",15,SMS2);

//HLineCreate_(0,"Line_UP",0,iBands_UP,clrYellow,0,0,false,true,false,0);
//HLineCreate_(0,"Line_DW",0,iBands_DW,clrLime,0,0,false,true,false,0);

   HLineCreate_(0,"Line_TP",0,iBands_TP,clrMagenta,0,0,false,true,false,0);

   return iBands_TP;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*double _calculateClose_Bands(double _PriceEntry,int OP_Dir,int TPGrid)
  {

/*0 - MODE_MAIN 1 - MODE_UPPER, 2 - MODE_LOWER*/
/*  bool ANS=false;
   int BW=-1,BTP=0;
   string Dir;
   int area=-1;
   double iBands_UP=-1,iBands_DW=-1,iBands_TP;
//---
   int period=45,Shift=1;
   double deviation=2;
   double Price=_PriceEntry;
   int c=20;
//---

   if(Price>iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,0,Shift))
     {//----------UP
      if(CntCallBB_Buy)
        {
         for(int i=0;i<c;i++)
           {
            iBands_UP=iBands(Symbol(),0,period,i+1,0,PRICE_TYPICAL,1,Shift);
            iBands_DW=iBands(Symbol(),0,period,i,0,PRICE_TYPICAL,1,Shift);
            if(i==0)
               iBands_DW=iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,0,Shift);
            //---------------------------------------------------------------
            if(iBands_UP>=Price && Price>=iBands_DW)
              {
               BW=i+1;
               Dir="UP";
               area=1;
               break;
              }
           }
        }
     }



   else
     {//----------DW
      if(CntCallBB_Sell)
        {
         for(int i=0;i<c;i++)
           {
            iBands_UP=iBands(Symbol(),0,period,i,0,PRICE_TYPICAL,2,Shift);
            iBands_DW=iBands(Symbol(),0,period,i+1,0,PRICE_TYPICAL,2,Shift);
            if(i==0)
               iBands_UP=iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,0,Shift);
            //---------------------------------------------------------------
            if(iBands_UP>=Price && Price>=iBands_DW)
              {
               BW=i+1;
               Dir="DW";
               area=2;
               break;
              }
           }
        }
     }
//-------
   string TestBB="BeforGate : "+c(OP_Dir)+":"+c(area)+" | "+c(BW)+":"+c(TPGrid)+"-[";



   if(OP_Dir==4)
     {//----------Buy
      if(CntCallBB_Buy)
        {
         if(area==1)
           {
            BTP=BW+TPGrid;
            TestBB+=c(BTP)+"]*"+c(__LINE__);
              }else{
            BTP=BW-TPGrid-1;
            TestBB+=c(BTP)+"]*"+c(__LINE__);
           }
        }
      if(CntCallBB_Buy)
        {
         MarkBBTP_Buy=BTP;
         MarkBBArea_Buy=area;
         CntCallBB_Buy=false;
        }
      else
        {
         BTP=MarkBBTP_Buy;
         area=MarkBBArea_Buy;
         TestBB+=c(BTP)+"]@"+c(__LINE__);
        }
     }



   else
     {//----------Sell
      if(CntCallBB_Sell)
        {
         if(area==1)
           {
            BTP=BW-TPGrid;
            TestBB+=c(BTP)+"]*"+c(__LINE__);
              }else{
            BTP=BW+TPGrid;
            TestBB+=c(BTP)+"]*"+c(__LINE__);
           }
        }
      if(CntCallBB_Sell)
        {
         MarkBBTP_Sell=BTP;
         MarkBBArea_Sell=area;
         CntCallBB_Sell=false;
        }
      else
        {
         BTP=MarkBBTP_Sell;
         area=MarkBBArea_Sell;
         TestBB+=c(BTP)+"]@"+c(__LINE__);
        }
     }
   iBands_TP=iBands(Symbol(),0,period,BTP,0,PRICE_TYPICAL,area,Shift);

   if(((Bid<iBands_TP) && (OP_Dir==5)) || ((Bid>=iBands_TP) && (OP_Dir==4)))
     {ANS=true;}

   double ProfitPoint;
   if(iBands_TP>Price)
      ProfitPoint=iBands_TP-Price;
   else
      ProfitPoint=Price-iBands_TP;
//-------

   string SMS;
   SMS+="H: "+_Comma(iBands_UP,Digits,"")+" | ";
   SMS+="L: "+_Comma(iBands_DW,Digits,"")+" | ";
   SMS+=string(BW)+Dir+" | ";
   SMS+=string(BTP)+"TP: "+_Comma(iBands_TP,Digits,"")+"["+_Comma(ProfitPoint*(MathPow(10,Digits)),0,"")+"]";

   _LabelSet("Text2",10,100,clrWhite,"Arial",15,SMS);

//HLineCreate_(0,"A",0,iBands_UP,clrWhite,0,0,false,true,false,0);
//HLineCreate_(0,"B",0,iBands_DW,clrWhite,0,0,false,true,false,0);

   HLineCreate_(0,"Line_Price",0,Price,clrMagenta,0,0,false,true,false,0);
   HLineCreate_(0,"Line_TP",0,iBands_TP,clrLime,0,0,false,true,false,0);

   return iBands_TP;
  }
  */

double _calculateLots1(double Price,double SL)
  {

   double Point_=(Price-SL)*BaseDigits;

   if(Point_<0)
     {
      Point_=Point_*(-1);
     }

   double _BALANC=AccountInfoDouble(ACCOUNT_BALANCE);
   _BALANC+=AccountInfoDouble(ACCOUNT_CREDIT);

   double Risky_=(_BALANC/100)*Risky;

   LotsCurrent=(Risky_/Point_)*AccountType;
   LotsCurrent=NormalizeDouble(LotsCurrent,3);
//---
   _LabelSet("Text_RR3",50,190,clrWhite,"Arial",12,"Risky : "+string(Risky)+"% = "+_Comma(_BALANC,2," ")+" | Lots:"+_Comma(LotsCurrent,4,"")+" | "+_Comma(Point_,0," "));

   return LotsCurrent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _calculateLots(double Price,double SL)
  {
   double _BALANC=AccountInfoDouble(ACCOUNT_BALANCE);
//_BALANC+=AccountInfoDouble(ACCOUNT_CREDIT);

   double _FundPer=_BALANC*(Investment/100);

   if(_FundPer<=0)
     {
      _FundPer=100;
     }

   double v=(_FundPer/100)*Lots;
   v=v*AccountType;

   v=NormalizeDouble(v,2);
//---
   _LabelSet("Text_RR3",50,190,clrWhite,"Arial",12,"Investment : "+string(Investment)+"% = "+_Comma(_BALANC,2," ")+" | Lots:"+_Comma(v,4,""));
   LotsCurrent=v;
   return v;
  }
//Risky
bool iMA_Line(int c)
  {
   bool v=true;
   double Reds=iMA(Symbol(),0,100,0,MODE_SMA,PRICE_CLOSE,1);
   double Greens=iMA(Symbol(),0,1,0,MODE_SMA,PRICE_CLOSE,1);
   if(Greens<Reds && c==5)
     {
      v=true;
     }
   if(Greens>Reds && c==4)
     {
      v=true;
     }

   _LabelSet("Text_RR3",50,210,clrWhite,"Arial",12,"Test "+c(v));
   return v;
  }
//+------------------------------------------------------------------+
