//+------------------------------------------------------------------+
//|                                                     X_System.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Portgas D Lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.20"
#property strict 
//#property icon "icon/icon.ico"
#property description "A\nB\nC"

//---
#include "Masaki_Value.mqh";
#include "Masaki_Method_MQL4.mqh";
#include "Masaki_Method_Tools.mqh";
#include "Masaki_Method_Order.mqh";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   VLineCreate_(0,"Strart",0,0,clrRed,0,0,false,false,false,0);
   EventSetTimer(60);
   _showInfomation();
   PrintPic();
   printf("+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+");
   _setupEA();
//+------------------------------------------------------------------+
   _setBUTTON("BTN_X__BUY",0,120,25,5,130,10,clrBlack,clrGreen);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   _orderDelete();
//---
   _getWinLoes();
   string Deinit1="TP : "+string(Rate_Win)+" | SL : "+string(Rate_Lose)+" |  Rate :"+_Comma(Rate,2,"");
   string Deinit2="Balace : "+_Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ");

   PrintPic();
   printf(Deinit1);
   printf(Deinit2);
   Comment("");

//---

   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

//+------------------------------------------------------------------+
   xcntM1=iBars(Symbol(),1);
   if(cntM1!=xcntM1)
     {
      cntM1=xcntM1;
      _showInfomation();//**********************************
     }
//+------------------------------------------------------------------+
   xcntM5=iBars(Symbol(),5);
   if(cntM5!=xcntM5)
     {
      cntM5=xcntM5;
      //---
      __orderCHKHub();
      _getWinLoes();
     }
//+------------------------------------------------------------------+
   xcntM15=iBars(Symbol(),15);
   if(cntM15!=xcntM15)
     {
      cntM15=xcntM15;
      //**********************************
     }
/*xcntM30=iBars(Symbol(),30);
   if(cntM30!=xcntM30)
     {
      cntM30=xcntM30;
      //---

     }*/
//+------------------------------------------------------------------+
   xcntH1=iBars(Symbol(),60);
   if(cntH1!=xcntH1)
     {
      cntH1=xcntH1;
      //---
      _StayFriday();
     }
//+------------------------------------------------------------------+
   xcntH4=iBars(Symbol(),PERIOD_H4);
   if(cntH4!=xcntH4)
     {
      cntH4=xcntH4;
      //---
      __orderPinHub();

     }
//+------------------------------------------------------------------+
/*xcntD1=iBars(Symbol(),PERIOD_D1);
   if(cntD1!=xcntD1)
     {
      cntD1=xcntD1;
      cntRunDay++;
      //---

      _setFiboBox();
     }*/

//+------------------------------------------------------------------+
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      if(sparam=="BTN_X__BUY")
        {
         ObjectSetInteger(0,"BTN_X__BUY",OBJPROP_BGCOLOR,clrWhite);
         //---
         _orderDelete();
         //---
        }
     }
  }
//+------------------------------------------------------------------+
void _setupEA()
  {
   iMA_Line(4);
//---

   _setTemplate();
   _StayFriday();
   _getWinLoes();
   _setFiboBox();

   _iSarStep=getEnumSar(OptionSar,10000);
   _iSarOut=getEnumSar(OptionSarOut,10000);

   __orderPinHub();
//---
   cntM1=iBars(Symbol(),1);
   cntM5=iBars(Symbol(),5);
   cntM30=iBars(Symbol(),30);
   cntM15=iBars(Symbol(),15);
   cntH1=iBars(Symbol(),60);
//
   cntH4=iBars(Symbol(),PERIOD_H4);
   cntD1=iBars(Symbol(),PERIOD_D1);

  }
//+------------------------------------------------------------------+
void _showInfomation()
  {

//_setFiboBox();
   string SMS;
   SMS+="\n    "+SMS_Workday;
//SMS+="\n    Rang : "+_Comma(_Rang,0," ")+" | RangBX : "+_Comma(Fibo_BX[1],Digits,"");
   Comment(SMS);

//+------------------------------------------------------------------+
   color clrMM4=clrYellow;
   string MM0,MM1,MM2;
//---
   MM2="SarIn "+string(OptionSar)+" : "+_Comma(_iSarStep,4,"")+" | Period_BB : "+_Comma(Period_BB,0,"")+" | Lots : "+_Comma(LotsCurrent,4,"");
   MM1="TP : "+string(Rate_Win)+" | SL : "+string(Rate_Lose)+" |  Rate : "+_Comma(Rate,2,"");
   MM0="Balace : "+_Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" | Profit : "+_Comma(AccountInfoDouble(ACCOUNT_PROFIT),2," ");
//---
//Arial
/*if(AccountInfoDouble(ACCOUNT_PROFIT)<0)
      clrMM4=clrRed;
   else if(AccountInfoDouble(ACCOUNT_PROFIT)>0)
      clrMM4=clrLime;
   else
      clrMM4=clrYellow;*/

   _LabelSet("Text_MM2",10,80,clrYellow,"Franklin Gothic Medium Cond",15,MM2);
   _LabelSet("Text_MM1",10,60,clrYellow,"Franklin Gothic Medium Cond",15,MM1);
   _LabelSet("Text_Balace",10,40,clrMM4,"Franklin Gothic Medium Cond",20,MM0);
  }
//+------------------------------------------------------------------+
