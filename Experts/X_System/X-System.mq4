//+------------------------------------------------------------------+
//|                                                     X_System.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Portgas D Lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.20"
#property strict 
#property icon "icon/icon.ico"
#property description "A\nB\nC"

//---
#include "X-System_Method_Value.mqh";
#include "X-System_Method_MQL4.mqh";
#include "X-System_Method_Tools.mqh";
#include "X-System_Method_Order.mqh";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   _showInfomation();
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
   string MM3="TP : "+string(Rate_Win)+" | SL : "+string(Rate_Lose)+" |  Rate :"+_Comma(Rate,2,"");
   printf(MM3);
//---

   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   _showInfomation();
//+------------------------------------------------------------------+
   xcntM1=iBars(Symbol(),1);
   if(cntM1!=xcntM1)
     {
      cntM1=xcntM1;
      //---

     }
//+------------------------------------------------------------------+
   xcntM5=iBars(Symbol(),5);
   if(cntM5!=xcntM5)
     {
      cntM5=xcntM5;
      //---

      SpreadSum+=MarketInfo(Symbol(),MODE_SPREAD);
      SpreadCNT++;
     }
//+------------------------------------------------------------------+
   xcntM15=iBars(Symbol(),15);
   if(cntM15!=xcntM15)
     {
      cntM15=xcntM15;
      //------------------------------
      Spread=Spread/SpreadCNT;
      SpreadSum=0;
      SpreadCNT=0;
      //---
      _orderPinHub();
      //------------------------------

     }
   xcntM30=iBars(Symbol(),30);
   if(cntM30!=xcntM30)
     {
      cntM30=xcntM30;
      //---

     }
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
      _xdirectSar=_directSar();
      if(_directSar!=_xdirectSar)
        {
         _directSar=_xdirectSar;
         //------------
         _orderDelete();
         //orderDelete(0);
         //orderDelete(1);
         //------------
        }
     }
//+------------------------------------------------------------------+
   xcntD1=iBars(Symbol(),PERIOD_D1);
   if(cntD1!=xcntD1)
     {
      cntD1=xcntD1;
      //---
      cntRunDay++;
      _getRangPivot();
      //orderDelete();
     }

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
   _setTemplate();
   _getRangPivot();
   _pinLine(1);
   _StayFriday();
   getBALANC_Start();
   _directSar=_directSar();
   _getWinLoes();

   Spread=MarketInfo(Symbol(),MODE_SPREAD);
   _orderPinHub();
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
   color clrMM1,clrMM4;
   string SMS,MM1,MM2,MM3,MM4;

//---
   SMS+="\nRang : "+string(_Rangp)+" ["+_strBoolYN(WorkFreeze)+"] | Pivot : "+string(NormalizeDouble(_Pivot,Digits))+" Allow : "+string(IsDllsAllowed());
//SMS+="\n\nOpenAll : "+_strBoolYN(OpenAll)+" | ShowLine : "+_strBoolYN(ShowLine)+" | Lots : "+string(Lots);
   SMS+="\n"+SMS_Workday;

//SMS+="\n\n";
//SMS+="\nBalace : "+_Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" | Profit : "+ _Comma(AccountInfoDouble(ACCOUNT_PROFIT),2," ");
//SMS+="\n"+_directSarStr(_directSar)+" ("+_Comma(_iSarStep,4,"")+")";
   Comment(SMS);

//+------------------------------------------------------------------+
//_directSar=_directSar();
   if(_directSar==5)
      clrMM1=clrRed;
   else if(_directSar==4)
      clrMM1=clrLime;
   else
      clrMM1=clrGold;
//---
   MM1=_directSarStr(_directSar)+" ("+_Comma(_iSarStep,4,"")+")"+"Swite : "+string(IsTradeAllowed());
   MM2="OpenAll : "+_strBoolYN(OpenAll)+" | ShowLine : "+_strBoolYN(ShowLine)+" | Lots : "+_Comma(calculateLots(),4,"");
   MM3="TP : "+string(Rate_Win)+" | SL : "+string(Rate_Lose)+" |  Rate :"+_Comma(Rate,2,"");
   MM4="Balace : "+_Comma(AccountInfoDouble(ACCOUNT_BALANCE),2," ")+" | Profit : "+_Comma(AccountInfoDouble(ACCOUNT_PROFIT),2," ");
//---
//Arial
   if(AccountInfoDouble(ACCOUNT_PROFIT)<0)
      clrMM4=clrRed;
   else if(AccountInfoDouble(ACCOUNT_PROFIT)>0)
      clrMM4=clrLime;
//123
   else
      clrMM4=clrYellow;

   int teststorage2=0;
   int teststorage=0;

   _LabelSet("Text_MM1",10,100,clrMM1,"Franklin Gothic Medium Cond",10,MM1);
   _LabelSet("Text_MM2",10,80,clrYellow,"Franklin Gothic Medium Cond",10,MM2);
   _LabelSet("Text_MM3",10,60,clrYellow,"Franklin Gothic Medium Cond",15,MM3);
   _LabelSet("Text_Balace",10,40,clrMM4,"Franklin Gothic Medium Cond",20,MM4);
  }
//+------------------------------------------------------------------+
