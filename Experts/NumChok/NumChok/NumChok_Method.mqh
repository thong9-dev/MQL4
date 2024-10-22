//+------------------------------------------------------------------+
//|                                                        myLib.mqh |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "NumChok.mq4";
#include "NumChok_Value.mqh";
#include "NumChok_Method_Tools.mqh";
#include "NumChok_Method_MQL4.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderOpen(string Direction,string v)
  {

   int ticket=-1;
//--
   _CntMyOrder();
   _getPriceMaxMin();
//----------------------------------------------
   if(CNT_ALL<MaxTrad)
     {
      //--
      if(Direction=="Green")
        {
         //if(((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread))) || CNT_Buy<DoubleClick) && _isRSI=="Green")
         if(((Ask<_PriceMax__Buy) && (Ask<(_PriceMin__Buy-vSpread))) || CNT_Buy<DoubleClick || Signal_DDClick_BUY0>Signal_DDClick)
           {

            ticket=OrderSend(Symbol(),OP_BUY,_CalculateLot(CNT_Buy),Ask,3,0,0,_NameEaLabel+(string)(CNT_Buy+1)+"/"+v+" ["+(string)MagicNumber+"] ",MagicNumber__Buy,0);
            if(GetLastError()==0)
              {
               Signal_DDClick_BUY=0;
               Print("[OpenOrder(1)]# "+DoubleToString(_CntBars,0)+"/"+DoubleToString(Bars,0)+" _Direction : Buy");
               if(CNT_Buy==0 && v=="1")
                 {
                  CNT_Round_B++;
                  TimeFirstOrder__Buy=TimeCurrent();
                 }
               _CntMyOrder();
               _getPriceMaxMin();
                 }else{
               Print(GetLastError());
              }

            _LogfileMAX("OpenOrder Green");

            aTP_All__Buy=_CalculateTP("Buy",MagicNumber__Buy,1);
            _CntMyOrder();

           }
         else
           {
            printf("[_OpenOrder(G1)]# Not open in the area. # Max : "+ (string)(_PriceMin__Buy - vSpread) +" Min : "+ (string)_PriceMin__Buy + " Ask : "+ (string)Ask);return false;
           }
        }
      //--
      if(Direction=="Red")// && (_isRSI=="Red"))
        {
         if(((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread))) || CNT_Sell<DoubleClick || Signal_DDClick_SELL0>Signal_DDClick)
            //if(((Bid>_PriceMin_Sell) && (Bid>(_PriceMax_Sell+vSpread))) || CNT_Sell<DoubleClick)
           {

            ticket=OrderSend(Symbol(),OP_SELL,_CalculateLot(CNT_Sell),Bid,3,0,0,_NameEaLabel+(string)(CNT_Sell+1)+"/"+v+" ["+(string)MagicNumber+"] ",MagicNumber_Sell,0);
            if(GetLastError()==0)
              {
               Signal_DDClick_SELL=0;
               Print("[OpenOrder(2)]# "+DoubleToString(_CntBars,0)+"/"+DoubleToString(Bars,0)+" _Direction : Sell");
               if(CNT_Sell==0 && v=="1")
                 {
                  CNT_Round_S++;
                  TimeFirstOrder_Sell=TimeCurrent();
                 }
               _CntMyOrder();
               _getPriceMaxMin();
                 }else{
               Print(GetLastError());
              }
            _LogfileMAX("OpenOrder Red");

            aTP_All_Sell=_CalculateTP("Sell",MagicNumber_Sell,1);
            _CntMyOrder();

           }
         else
           {
            printf("[_OpenOrder(R1)]# Not open in the area. # Max : "+(string) (_PriceMax_Sell + vSpread) +" Min : "+ (string)_PriceMin_Sell + "  Bid : "+ (string)Bid);return false;
           }
        }
      //--
      if(Direction=="Wait")
        {
         printf("[_OpenOrder(G1)]# Not open in SideWay");return false;
        }
      //--

      //--
      printf("[_OpenOrder(3)]# OrderOpen : ["+_Comma(ticket,0," ")+"] "+Direction+" Error : "+(string)GetLastError());
      return true;
     }
   else
     {
      printf("[_OpenOrder(4)]# Order is MaxTrad");
     }

//**
   return false;
  }//_OpenOrder
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isVolumes(int n,int min,int max)
  {
   string v="";
   double Sum=0;
   double AVG=0,x;
   color _Text_Vol1c;
   for(int i=0;i<n;i++)
     {
      Sum+=(double)iVolume(Symbol(),0,i);
     }
//---
   AVG=(double)Sum/n;
//---
   x=(double)iVolume(Symbol(),0,1);
   if((AVG<=max) && (AVG>=min) && x>=(min))//
     {
      v="OK";
      _Text_Vol1c=clrLime;
     }
   else
     {
      v="Wait";
      _Text_Vol1c=clrYellow;
     }
//+------------------------------------------------------------------+
   if(!_iVolumes)
     {
      v="OK";
      _Text_Vol1c=clrLime;
     }
//+------------------------------------------------------------------+

   int panel=WindowFind("Volumes");
   if(panel<0)
     {
      Comment("NoWindows : "+"Volumes");
     }
   else
     {
      string _Text;
      for(int i=1;i<=1;i++)
        {
         _Text="_Text_Vol"+(string)i;
         _LabelCreate(_Text,panel);
        }
      //---

      _LabelSet("_Text_Vol1",75,1,_Text_Vol1c,"Arial",8," | "+_Comma(AVG,0," ")+" | "+v);
     }

//+------------------------------------------------------------------+

   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isSAR(double step,double x)
  {
   string v;
   double isar=NormalizeDouble(iSAR(Symbol(),0,step,0.2,0),Digits);
   double Diff=(Bid-isar)*MathPow(10,myDigit);
//---
   if(Bid>isar && Diff>x)
     {
      v="Green";
     }
   else if(Bid<isar && Diff<-x)
     {
      v="Red";
     }
   else
     {
      v="Wait";
     }

   if(!_iSAR)
     {
      v="None";
     }
//---
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isMA(string PERIOD)
  {
   string v;

//_iMA_BLUE = iMA(Symbol(),60,35,0,MODE_EMA,6,0);
//_iMA__RED = iMA(Symbol(),60,13,0,MODE_EMA,6,0);
//_iMA_GREE = iMA(Symbol(),30, 1,0,MODE_EMA,0,0);

   _iMA_BLUE = iMA(Symbol(),(int)PERIOD,50,MODE_SMA,MODE_EMA,PRICE_WEIGHTED,0);
   _iMA__RED = iMA(Symbol(),(int)PERIOD,25,MODE_SMA,MODE_EMA,PRICE_WEIGHTED,0);
   _iMA_GREE = iMA(Symbol(),(int)PERIOD,10,MODE_SMA,MODE_EMA,PRICE_WEIGHTED,0);
//+------------------------------------------------------------------+
   GREE_RED = (int)((_iMA_GREE - _iMA__RED) * MathPow(10,myDigit));
   RED_BLUE = (int)((_iMA__RED - _iMA_BLUE) * MathPow(10,myDigit));
//+------------------------------------------------------------------+
   if(RED_BLUE>RED_BLUEc)
     {
      _RED_BLUE="UP";
        }else if(RED_BLUE<(RED_BLUEc*-1)){
      _RED_BLUE="DW";
        }else{
      _RED_BLUE="OO";
     }
   STR_isMA="["+_RED_BLUE+" "+(string)RED_BLUE+"]";
//--
   if(GREE_RED>GREE_REDc)
     {
      _GREE_RED="UP";
        }else if(GREE_RED<(GREE_REDc*-1)){
      _GREE_RED="DW";
        }else{
      _GREE_RED="OO";
     }
   STR_isMA+="["+(string)_GREE_RED+" "+(string)GREE_RED+"]";
//+------------------------------------------------------------------+
   string Confirmsignal=_isMA_Confirm((int)PERIOD,_iMA_BLUE,_iMA__RED,_iMA_GREE);
//---
   if(((_GREE_RED=="DW") && (_RED_BLUE=="DW") && (_iMA_GREE<_iMA_BLUE)))
     {
      if((Confirmsignal=="None") || (Confirmsignal=="Red"))
        {
         v="Red";
        }

     }
   else if(((_GREE_RED=="UP") && (_RED_BLUE=="UP") && (_iMA_GREE>_iMA_BLUE)))
     {
      if((Confirmsignal=="None") || (Confirmsignal=="Green"))
        {
         v="Green";
        }
     }
   else
     {
      v="Wait";
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isMA_Confirm(int Timeframe,double BLUE,double _RED,double GREE)
  {

   string v;
   double COLSE=iClose(Symbol(),Timeframe,1);
   double OPEN_=iOpen(Symbol(),Timeframe,1);
//+------------------------------------------------------------------+  
   COLSE_GREE=(int)((COLSE-GREE)*MathPow(10,myDigit));

   if((COLSE_GREE>50) && (COLSE>GREE))
     {
      _COLSE_GREE="UP";
     }
   else if((COLSE_GREE<-50) && (COLSE<GREE))
     {
      _COLSE_GREE="DW";
     }
   else
     {
      _COLSE_GREE="OO";
     }

//+------------------------------------------------------------------+   
   if((_COLSE_GREE=="UP") && (OPEN_>_RED) && (GREE>_RED) && (_RED>BLUE) && (_isLastBas(Timeframe,1)=="Green"))
     {
      v="Green";
     }

   else if((_COLSE_GREE=="DW") && (OPEN_<_RED) && (GREE<_RED) && (_RED<BLUE) && (_isLastBas(Timeframe,1)=="Red"))
     {
      v="Red";
     }
   else
     {
      v="Wait";
     }
//+------------------------------------------------------------------+
   if(!_ConfirmsignalMA)
     {
      v="None";
     }
//+------------------------------------------------------------------+

   STR_isMA+="["+v+"]";
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isLastBas(int Timeframe,int n)
  {
   if(iOpen(Symbol(),Timeframe,n)>iClose(Symbol(),Timeframe,n))
     {
      //printf("[_isLastBas()]# Red");
      return ("Red");
     }
   if(iOpen(Symbol(),Timeframe,n)<iClose(Symbol(),Timeframe,n))
     {
      //printf("[_isLastBas()]# Green");
      return ("Green");
     }
   return ("0");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isLastBas(int Timeframe,int n,int m)
  {
   for(int i=n;i<m;i++)
     {
      if(iOpen(Symbol(),Timeframe,n)>iClose(Symbol(),Timeframe,n))
        {
         return ("Red");
        }
      if(iOpen(Symbol(),Timeframe,n)<iClose(Symbol(),Timeframe,n))
        {
         return ("Green");
        }
     }

   return ("0");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string WinRSI_Direct;
color  WinRSI_cDirect;
bool _OverRSI=true,_OverRSIAVG=true;
//+------------------------------------------------------------------+
string _isRSI(int period,int n)
  {
   string v;

//+------------------------------------------------------------------+
//---_OverBUY-SELL
   double _RSI=iRSI(Symbol(),PERIOD_H4,period,PRICE_WEIGHTED,0);

   if(_OverRSI)
     {
      if(!((_RSI<70) && (_RSI>30)))
        {
         _OverRSI=false;
        }
     }
   else
     {
      if((_RSI<=65) && (_RSI>=35))
        {
         _OverRSI=true;
        }

     }
//+------------------------------------------------------------------+
//---AVG-RSI
   double _SumRSI=0,_AvgRSI=0;
   n=(n/4);
   for(int i=0;i<n;i++)
     {
      _SumRSI+=iRSI(Symbol(),PERIOD_H4,period,PRICE_WEIGHTED,i);
     }
   _AvgRSI=(_SumRSI/n);
//---
   if(_OverRSIAVG)
     {
      if(!((_AvgRSI<70) && (_AvgRSI>30)))
        {
         _OverRSIAVG=false;
        }
     }
   else
     {
      if((_AvgRSI<=65) && (_AvgRSI>=35))
        {
         _OverRSIAVG=true;
        }

     }
//+------------------------------------------------------------------+

   if((_AvgRSI>50) && (_RSI>50 && _RSI<69) && _OverRSI && _OverRSIAVG)//
     {
      v="Green";
      WinRSI_cDirect=clrLime;
     }
   else if((_AvgRSI<50) && (_RSI<50 && _RSI>31) && _OverRSI && _OverRSIAVG)//
     {
      v="Red";
      WinRSI_cDirect=clrRed;
     }
   else
     {
      v="Wait";
      WinRSI_cDirect=clrWhite;
     }
   if(!_iRSI)
     {
      v="None";
     }
//+------------------------------------------------------------------+
   string str="RSI("+(string)period+")";
   int panel=WindowFind(str);

   if(panel>0)
     {
      //---
      string _Text;
      for(int i=1;i<=1;i++)
        {
         _Text="_Text_RSI"+(string)i;
         _LabelCreate(_Text,panel);
        }
      WinRSI_Direct="-- | "+_Comma(_RSI,2,"")+" "+(string)_OverRSI+" | "+_Comma(_AvgRSI,2,"")+" | "+v;
      //+------------------------------------------------------------------+
      _LabelSet("_Text_RSI1",75,1,WinRSI_cDirect,"Arial",8,WinRSI_Direct);
      //+------------------------------------------------------------------+
     }

   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string _isSupportResistance(double Traget,int n)
  {
   string v="";
//+------------------------------------------------------------------+
   double Max_H=-9999999,Max_L=9999999,O,C,X;
   int shift=(n+1)*24;
//---
   for(int i=6;i<shift;i++)
     {
      O=iOpen(Symbol(),PERIOD_H1,i);
      C=iClose(Symbol(),PERIOD_H1,i);

      if(C>O)
        {
         TrendWeek="Green";
         X=C;
         C=O;
         O=X;
        }
      else
        {
         TrendWeek="Red";
        }
      //---
      if(O>Max_H)
        {
         Max_H=O;
        }
      if(C<Max_L)
        {
         Max_L=C;
        }
     }
//+------------------------------------------------------------------+
   _iHigh=Max_H;
   _iLow=Max_L;

//+------------------------------------------------------------------+
   double HighLow=(_iHigh-_iLow)*MathPow(10,myDigit);
   Comment(_Comma(_iHigh,myDigit,"")+"|"+_Comma(_iLow,myDigit,"")+" ["+_Comma(HighLow,0,"")+"]");
//+------------------------------------------------------------------+
   Traget=_OrderCutProfitRate(50);
   double _Traget=(Traget)/MathPow(10,myDigit);
//---
   double _G =((_iHigh-_Traget)-Bid)*MathPow(10,myDigit);
   double _R =(Ask-(_iLow+_Traget))*MathPow(10,myDigit);


   if(_G>0 && _R>0)
     {
      v="OK";
     }
   else
     {
      v="Wait";
     }
//+------------------------------------------------------------------+
   if(!_iHihgLow)
     {
      v="OK";
      HLineMove(0,"HighLine",NormalizeDouble(_iHigh,myDigit),StringToColor("128,128,128"));
      HLineMove(0,"Low-Line",NormalizeDouble(_iLow,myDigit),StringToColor("128,128,128"));
      //---
      HLineMove(0,"High_preLine",NormalizeDouble(_iHigh-_Traget,myDigit),StringToColor("128,128,128"));
      HLineMove(0,"Low_preLine",NormalizeDouble(_iLow+_Traget,myDigit),StringToColor("128,128,128"));
     }
   else
     {
      HLineMove(0,"HighLine",NormalizeDouble(_iHigh,myDigit),clrMagenta);
      HLineMove(0,"Low-Line",NormalizeDouble(_iLow,myDigit),clrDodgerBlue);
      //---
      HLineMove(0,"High_preLine",NormalizeDouble(_iHigh-_Traget,myDigit),clrPurple);
      HLineMove(0,"Low_preLine",NormalizeDouble(_iLow+_Traget,myDigit),clrDarkBlue);
     }
//+------------------------------------------------------------------+
   return v;
//return _Comma(_iHigh,5,"")+"/"+_Comma(_iLow,5,"");
//return _Comma(_G,0,"")+"/"+_Comma(_R,0,"");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string STOFreeze="Unfreeze";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isStochastic(int K,int D,int S)
  {
   string v;
   color WinSTO_Directc;

//+------------------------------------------------------------------+
   double x=iStochastic(Symbol(),PERIOD_M15,K,D,S,MODE_EMA,0,MODE_MAIN,0);
//---
   if(STOFreeze=="Unfreeze")
     {
      if((x<=90) && (x>=10))
        {
         v="OK";
         WinSTO_Directc=clrLime;
        }
      else
        {
         STOFreeze="Freeze";
         v="Wait";
         WinSTO_Directc=clrYellow;
        }
     }
   else
     {
      if((x<=80) && (x>=20))
        {
         STOFreeze="Unfreeze";
        }
      WinSTO_Directc=clrYellow;
      v="Wait";
     }

//+------------------------------------------------------------------+
   string str="Stoch("+(string)K+","+(string)D+","+(string)S+")";

   int panel=WindowFind(str);

   if(panel>0)
     {
      //---
      string _Text;
      for(int i=1;i<=1;i++)
        {
         _Text="_Text_STO"+(string)i;
         _LabelCreate(_Text,panel);
        }
      //_OverRSI+" | "+_Comma(_AvgRSI,4,"")+" "+v;
      string WinSTO_Direct=_Comma(x,2,"")+" "+STOFreeze+" | "+v;
      //+------------------------------------------------------------------+
      _LabelSet("_Text_STO1",130,1,WinSTO_Directc,"Arial",8,WinSTO_Direct);
     }
//+------------------------------------------------------------------+
   if(!_iStochastic)
     {
      v="OK";
     }
//+------------------------------------------------------------------+
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _getPriceMaxMin(string v,int _MagicNumber)
  {
   double MinPrice=99999,MaxPrice=-99999;

   for(int pos=0;pos<OrdersTotal();pos++)
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
void _getPriceMaxMin()
  {
   _PriceMax__Buy=_getPriceMaxMin("Max",MagicNumber__Buy);
   _PriceMin__Buy = _getPriceMaxMin("Min",MagicNumber__Buy);
   _PriceMax_Sell = _getPriceMaxMin("Max",MagicNumber_Sell);
   _PriceMin_Sell=_getPriceMaxMin("Min",MagicNumber_Sell);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderCutProfit(int _DDDay,int _DDTime,double _DD,double DTP,string _OrderType,int _Number)
  {
   _DD=_DD*(-1);
//+------------------------------------------------------------------+
   if(
      ((_DDDay>=0) &&(_DDTime>=2) && (_DD>=5) && (DTP<=(Pip-_OrderCutProfitRate(75))))||
      ((_DDDay>=0) &&(_DDTime>=4) && (_DD>=3) && (DTP<=(Pip-_OrderCutProfitRate(50))))||
      ((_DDDay>=0) &&(_DDTime>=6) && (_DD>=1) && (DTP<=(Pip-_OrderCutProfitRate(25))))
      )
     {
      _OrderCutLoss(_OrderType,_Number,true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _OrderCutProfitRate(double rate)
  {
   double v=(Pip/100)*rate;
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderCutLoss()
  {
   if(_Cut__Loss)
     {

      double _Balance=accBalance+AccountInfoDouble(ACCOUNT_CREDIT);

      double   DD_B_cutLoss = NormalizeDouble((myProfit_Buy/FundCurrent) *(-100),2);
      double   DD_S_cutLoss = NormalizeDouble((myProfit_Sell/FundCurrent) *(-100),2);

      Signal_CutLoss=20;
      //+------------------------------------------------------------------+
      if(DD_B_cutLoss>=CutLoss_Buy_)
        {
         _clrText5=clrRed;
         Signal_CutLoss_Buy++;
         Signal_CutLoss_Buy0=Signal_CutLoss_Buy/500;
         //---
         if(Signal_CutLoss_Buy0>Signal_CutLoss)
           {
            _OrderCutLoss((string)OP_BUY,MagicNumber__Buy,false);
            FundCurrent=FundCurrent-DD_B_cutLoss;
            //---
            if(FundCurrent)
              {
               _LatsTime_StayFriday=True;
              }
            CNT_CutLoss_Buy++;

            //---
            _ChartScreenShot("CutLoss_Buy");
            //---

            Signal_CutLoss_Buy=0;
            Signal_CutLoss_Buy0=0;

            printf("[_OrderCloseALL()]# Red "+(string)CNT_CutLoss_Buy+"/"+_Comma(DD_B,2," ")+"% / "+_Comma(myProfit_Buy,2," ")+" USD");
           }
        }
      else
        {
         _clrText5=clrMidnightBlue;
        }
      //+------------------------------------------------------------------+
      if(DD_S_cutLoss>=CutLoss_Sell)
        {
         _clrText10=clrRed;
         Signal_CutLoss_Sell++;
         Signal_CutLoss_Sell0=Signal_CutLoss_Sell/500;
         //---
         if(Signal_CutLoss_Sell0>Signal_CutLoss)
           {
            _OrderCutLoss((string)OP_SELL,MagicNumber_Sell,false);
            CNT_CutLoss_Sell++;
            //---
            FundCurrent=FundCurrent-DD_S_cutLoss;
            if(FundCurrent)
              {
               _LatsTime_StayFriday=True;
              }
            //---
            _ChartScreenShot("CutLoss_Sell");
            //---
            Signal_CutLoss_Sell=0;
            Signal_CutLoss_Sell0=0;

            printf("[_OrderCloseALL()]# Green "+(string)CNT_CutLoss_Sell+"/"+_Comma(DD_S,2," ")+"% / "+_Comma(myProfit_Sell,2," ")+" USD");
           }
        }
      else
        {
         _clrText10=clrMidnightBlue;
        }

      _clrText5=clrMagenta;
      _clrText10=clrMagenta;

      _eaText5="F/FC : "+(string)CutLoss_Buy_+"] "+_Comma(DD_B_cutLoss,2,"")+"% ["+(string)Signal_CutLoss_Buy0+"/"+(string)CNT_CutLoss_Buy+"]";
      _eaText10="F/FC : "+(string)CutLoss_Sell+"] "+_Comma(DD_S_cutLoss,2,"")+"% ["+(string)Signal_CutLoss_Sell0+"/"+(string)CNT_CutLoss_Sell+"]";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderCutLoss(string _OrderType,int _MagicNumber,bool Profit)
  {

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()) && (string)OrderType()==_OrderType)
        {
         if(_OrderType==(string)OP_BUY){List_BUYY[pos]=OrderTicket();}
         if(_OrderType==(string)OP_SELL){List_SELL[pos]=OrderTicket();}
        }
     }
//+------------------------------------------------------------------+
   if(_OrderType==(string)OP_BUY)
     {
      if(!Profit)
        {
         VLineCreate(0,"TestIconCutLoss"+(string)CNT_IconCuLoss,0,0,clrLime,STYLE_SOLID,1,false,true,0);
         VLineMove(0,"TestIconCutLoss"+(string)CNT_IconCuLoss,0);
         CNT_IconCuLoss++;
        }
      for(int i=0;i<ArraySize(List_BUYY);i++)
        {
         if(List_BUYY[i]>0)
           {
            for(int pos=0;pos<OrdersTotal();pos++)
              {
               if(OrderSelect(List_BUYY[i],SELECT_BY_TICKET)==true)
                 {
                  bool z=OrderClose(List_BUYY[i],OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
                  if(GetLastError()==0){List_BUYY[i]=0;}
                 }
              }
           }
        }
     }
   else
     {
      //+------------------------------------------------------------------+
      if(!Profit)
        {
         VLineCreate(0,"TestIconCutLoss"+(string)CNT_IconCuLoss,0,0,clrRed,STYLE_SOLID,1,false,true,0);
         VLineMove(0,"TestIconCutLoss"+(string)CNT_IconCuLoss,0);
         CNT_IconCuLoss++;
        }
      //+------------------------------------------------------------------+
      for(int i=0;i<ArraySize(List_SELL);i++)
        {
         if(List_SELL[i]>0)
           {
            for(int pos=0;pos<OrdersTotal();pos++)
              {
               if(OrderSelect(List_SELL[i],SELECT_BY_TICKET)==true)
                 {
                  bool z=OrderClose(List_SELL[i],OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100);
                  if(GetLastError()==0){List_SELL[i]=0;}
                 }
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _StayFriday(int HH)
  {

   int x;
   TimeToStruct(TimeLocal(),MqlDate_Current);

   if(IsTesting())
     {x=HH;}
   else
     {x=MqlDate_Current.hour;}
   if((DayOfWeek()<=1 && x<8) || (DayOfWeek()>=5 && x>=18))
     {
      //OFF-Rest
      _LatsTime_StayFriday=True;
      //Print(StrTabs+"_StayFriday");
      Comment("StayFriday["+(string)DayOfWeek()+" | "+(string)x+"] : "+(string)_LatsTime_StayFriday);
     }
   else
     {
      //ON
      _LatsTime_StayFriday=false;
     }
  }
//+------------------------------------------------------------------+
