//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "X-System.mq4";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _EnumBool
  {
   F=False,    // No
   T=True,     // Yes
  };
//+------------------------------------------------------------------+
enum EnumOptionSar
  {
   //isSet V*1000
   Option1=1,//0.001
   Option2=3,//0.003
   Option3=5,//0.005
   Option4=7,//0.007
   Option5=9,//0.009
   Option6=15,//0.015
   Option7=19,//0.019
   Option8=25,//0.025
   Option9=29,//0.029
   Option10=35,//0.035
   Option11=39,//0.039
   Option12=45,//0.045
   Option13=49,//0.049
   Option14=100//1.000
  };
//+------------------------------------------------------------------+
enum EnumOptionGrid
  {
   //isSet V*1000
   OptionGridSize1=250,//0.250
   OptionGridSize2=382,//0.382
   OptionGridSize3=441,//0.441
   OptionGridSize4=500,//0.500
   OptionGridSize5=618,//0.618
   OptionGridSize6=786,//0.786
   OptionGridSize7=1000 //1.000

  };
//+------------------------------------------------------------------+
enum EnumOptioncntGrid
  {
   //isSet V*1000
   OptionCntGrid1=1,//1
   OptionCntGrid2=2,//2
   OptionCntGrid3=3,//3
   OptionCntGrid4=4,//4
   OptionCntGrid5=5,//5
   OptionCntGrid6=6,//6
   OptionCntGrid7=7,//7
   OptionCntGrid8=8//8
  };
//+------------------------------------------------------------------+
extern int Magicnumber=8;//Magicnumber
extern double Lots=0.05;//LotsPer100USD
extern double Investment=50;//FundPer
extern EnumOptionSar OptionSar=Option3;//SarStep
extern EnumOptionGrid OptionGrid=OptionGridSize3;//GridSize
extern EnumOptioncntGrid cntGrid=OptionCntGrid2;
extern _EnumBool OpenAll=F;//OpenOrderAll
extern _EnumBool OpenNormal=T;//OpenOrderNormal
extern _EnumBool OpenFallow=F;//OpenOrderFallow
extern _EnumBool ShowLine=F;//ShowLine
bool _ShowLine=ShowLine;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BaseDigits=MathPow(10,Digits);
double cntRunDay=0;
double _Rang,_Pivot;
int _Rangp;
bool WorkFreeze;
bool WorkStopIsPayback=true;
int _directSar=0,_xdirectSar;
double _iSarStep;
//double Fibo_TB[]={0.35,0.5,1.4,1.7};//0
//double Fibo_TB[]={0.1,0.35,0.6,1,1.35};//1
double Fibo_TB[]=
  {
//0.359,0.718,1.077,1.436,1.795,2.154,2.513,2.872,3.231,3.590
   0.441,0.882,1.323,1.764,2.205,2.646,3.087,3.528,3.969,4.410
  };//2
double Fibo_BX[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double rateTP;
double _BALANC_Sart=1,_BALANC_Goal=1;
double Spread,SpreadSum,SpreadCNT;
//---
int cntM1,xcntM1;
int cntM5,xcntM5;
int cntM15,xcntM15;
int cntM30,xcntM30;
int cntH1,xcntH1;
int cntH4,xcntH4;
int cntD1,xcntD1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _orderPin()
  {

   int z=0;
   int OP_Direct=-1;
   string OrderName;
   int CurrentMagic;
//---
   double A=0,B=0;
   double PriceA=0,PriceB=0;
   if(Bid>_Pivot)
     {
      //printf(__FUNCTION__+" "+__LINE__);

      for(int i=0;i<ArraySize(Fibo_BX)-1;i++)
        {
         A=_Pivot+Fibo_BX[i+1];
         B=_Pivot+Fibo_BX[i];
         if(Bid<=A && Bid>=B)
           {
            PriceA=NormalizeDouble(A,Digits);
            PriceB=NormalizeDouble(B,Digits);
            break;
           }
        }

     }

   if(Bid<_Pivot)
     {
      //printf(__FUNCTION__+" "+__LINE__);
      for(int i=0;i<ArraySize(Fibo_BX)-1;i++)
        {
         A=_Pivot-Fibo_BX[i];
         B=_Pivot-Fibo_BX[i+1];
         if(Bid<A && Bid>B)
           {
            PriceA=NormalizeDouble(A,Digits);
            PriceB=NormalizeDouble(B,Digits);
            break;
           }
        }
     }
//---
   double PTP=Fibo_BX[1]*rateTP;
   double SLP=PTP*2;
//---

   double TP_A=NormalizeDouble(PriceA+PTP,Digits);
   double SL_A=NormalizeDouble(PriceA-SLP,Digits);
//SL_A=0;

   double TP_B=NormalizeDouble(PriceB-PTP,Digits);
   double SL_B=NormalizeDouble(PriceB+SLP,Digits);
//SL_B=0;
   bool c=_directSar_warning();
   _getWinLoes();
//---
   double Price_X_Bid=NormalizeDouble((PriceA-Bid)*BaseDigits,0);
   double Price_Set_Bid=Fibo_BX[1]*(1-rateTP);
//double Price_Set_Bid=200;
//---
   if(chkOrder(0))
     {
      OP_Direct=4;
      HLineDelete(0,"A");

      CurrentMagic=_MagicEncrypt(0);
      OrderName=Symbol_()+" | Uper["+string(CurrentMagic)+"]";

      //---

      if(Price_X_Bid>=Price_Set_Bid /*&& 5==_directSar() */ && OP_Direct==_directSar_warning())
        {

         //if(PriceA!=_Pivot)
         //  {
         //z=OrderSend(Symbol(),OP_Direct,calculateLots(),PriceA,100,SL_A,TP_A,OrderName,CurrentMagic);
         z=OrderSend(Symbol(),OP_Direct,Lots,PriceA,100,SL_A,TP_A,OrderName,CurrentMagic);
         _getWinLoes();
         //}

        }
      //---
     }

   else
     {
      if(chkOrderType(0)<=1)
        {
         //orderModify(0,-1,SL_A,TP_A);
         HLineCreate_(0,"A",0,chkOrderPrice(0),clrLime,0,0,false,true,false,0);
        }
      else
        {

         if(4==_directSar_warning())
           {
            if(Price_X_Bid>=Price_Set_Bid)
              {
               orderModify(0,PriceA,SL_A,TP_A);
              }
           }
         else
           {
            _orderDelete(0);
           }

        }
     }

//------------
   Price_X_Bid=NormalizeDouble((Bid-PriceB)*BaseDigits,0);
   if(chkOrder(1))
     {
      OP_Direct=5;
      HLineDelete(0,"B");

      CurrentMagic=_MagicEncrypt(1);
      OrderName=Symbol_()+" | Lower["+string(CurrentMagic)+"]";
      //---

      if(Price_X_Bid>=Price_Set_Bid /*&& 4==_directSar()*/ && OP_Direct==_directSar_warning())
        {
         //if(PriceB!=_Pivot)
         //  {
         //calculateLots()
         z=OrderSend(Symbol(),OP_Direct,Lots,PriceB,100,SL_B,TP_B,OrderName,CurrentMagic);
         _getWinLoes();
         //}
        }
      //---
     }

   else
     {
      if(chkOrderType(1)<=1)
        {
         //orderModify(1,OrderOpenPrice(),SL_B,TP_B);
         HLineCreate_(0,"B",0,chkOrderPrice(1),clrRed,0,0,false,true,false,0);
        }
      else
        {
         if(5==_directSar_warning())
           {
            if(Price_X_Bid>=Price_Set_Bid)
              {
               orderModify(1,PriceB,SL_B,TP_B);
              }
           }
         else
           {
            _orderDelete(1);
           }
        }
     }
//---

  }
//+------------------------------------------------------------------+
