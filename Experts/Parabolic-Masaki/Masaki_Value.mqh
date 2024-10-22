//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "Masaki.mq4";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _EnumBool
  {
   F=False,    // No
   T=True,     // Yes
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _EnumAccountType
  {
   STD=1,// STD
   Mricro=100// Mricro
  };
//+------------------------------------------------------------------+
enum EnumOptionSar
  {
   //isSet V*10000
   Option0=100,//0.01
   Option1=14,//0.014
   Option3=0,//0.0
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EnumOptionFiBo
  {
   //isSet V*1000
   OptionFibo0=250,//	0.250
   OptionFibo1=382,//	0.382
   OptionFibo2=441,//	0.441
   OptionFibo3=500,//	0.500
   OptionFibo4=618,//	0.618
   OptionFibo5=786,//	0.786
   OptionFibo6=1000//	1.000


  };
//+------------------------------------------------------------------+
extern int Magicnumber=9;//Magicnumber
extern _EnumAccountType AccountType=STD;
extern double Lots=0.01;//LotsPer100USD
double LotsCurrent=0;
extern double Investment=100;//Investment
extern double Risky=5;//FundPer
extern EnumOptionFiBo OptionFiBo=OptionFibo0;//FiBo
extern string s;//---------------------------------------------------------
extern EnumOptionSar OptionSar=Option0;//SarStep
extern EnumOptionSar OptionSarOut=0;//SarStepOut
double _iSarStep,_iSarOut;
extern int Period_BB=40;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BaseDigits=MathPow(10,Digits);
double cntRunDay;
double Fibo_BX[1],_Rang;

//---
int cntM1,xcntM1;
int cntM5,xcntM5;
int cntM15,xcntM15;
int cntM30,xcntM30;
int cntH1,xcntH1;
int cntH4,xcntH4;
int cntD1,xcntD1;
//+------------------------------------------------------------------+

int __orderPin(int v)
  {
   int z=-1;
   double PriceEntry=-1,SL=-1,TP=-1,R;
   int CurrentMagic=-1,OP_Direct=-1;
   string OrderName;
   int CurrentDir=_DirSarIn(1);
   int v2=-1;

//---
   if(v==4)
      v2=5;
   if(v==5)
      v2=4;
//---
   if(!_getOrderInfo(v))
     {//+---------------------NewOrder---------------------+
      if(_DirSarBack(2,3,v2) && (_DirSarIn(2)!=_DirSarIn(1)) && (_DirSarIn(1)==_DirSarIn(0)))
        {
         if(_DirSarIn(1)==4 && v==4 && iMA_Line(4))//------------------ Buy
           {
            FirstCall_TP_Buy=true;
            iLine_TP_Buy=0;

            printf(__FUNCTION__+"----------------------------------- "+string(v)+"newBuy");

            PriceEntry=iHigh(Symbol(),0,1);

            TP=_calculate_BandsNew2(PriceEntry,0,3);
            //---
            R=iLow(Symbol(),0,1)-iSAR(Symbol(),0,_iSarStep,0.2,1);
            SL=iLow(Symbol(),0,1)-(R*0.5);
            //---
            TP=NormalizeDouble(TP,Digits);
            SL=NormalizeDouble(SL,Digits);
            //------------------
            if(Bid>PriceEntry)
              {
               //OP_Direct=2;
               printf(__FUNCTION__+" | "+c(__LINE__));
              }
            else
              {
               OP_Direct=4;//<<
               printf(__FUNCTION__+" | "+c(__LINE__));
              }
           }
         else if(_DirSarIn(1)==5 && v==5 && iMA_Line(5))//------------------ Sell
           {
            FirstCall_TP_Sell=true;
            iLine_TP_Sell=0;

            printf(__FUNCTION__+"+----------------------------------- "+string(v)+"newSell");

            PriceEntry=iLow(Symbol(),0,1);

            TP=_calculate_BandsNew2(PriceEntry,1,3);
            //---
            R=iSAR(Symbol(),0,_iSarStep,0.2,1)-iHigh(Symbol(),0,1);
            SL=iHigh(Symbol(),0,1)+(R*0.5);
            //---
            TP=NormalizeDouble(TP,Digits);
            SL=NormalizeDouble(SL,Digits);
            //------------------
            if(Bid>PriceEntry)
              {
               OP_Direct=5;//<<
              }
            else
              {
               //OP_Direct=3;
              }
           }
         else
           {
            return z;
           }
         //--------------------------------------------------------------------------
         if(OP_Direct>0)
           {
            OrderName=_SymbolShortName()+" | "+string(CurrentMagic)+"]";
            //z=OrderSend(Symbol(),v,Lots,PriceEntry,100,0,0,OrderName,_MagicEncrypt(v),0,clrGreen);
            z=OrderSend(Symbol(),OP_Direct,_calculateLots(PriceEntry,SL),PriceEntry,100,SL,TP,"",_MagicEncrypt(v),0);
            _getWinLoes();
            printf(__FUNCTION__+" | "+c(__LINE__)+"|"+c(z));
/*if(z<0)
              {
               printf(__FUNCTION__+" | "+c(__LINE__));
               OP_Direct=OP_Direct-4;
               if(OP_Direct==0)
                  PriceEntry=Ask;
               else
                  PriceEntry=Bid;
               z=OrderSend(Symbol(),OP_Direct,_calculateLots(PriceEntry,SL),PriceEntry,100,SL,TP,"",_MagicEncrypt(v),0);
              }*/
            return z;
           }
         //--------------------------------------------------------------------------
        }
     }
   return z;
  }
//+------------------------------------------------------------------+
