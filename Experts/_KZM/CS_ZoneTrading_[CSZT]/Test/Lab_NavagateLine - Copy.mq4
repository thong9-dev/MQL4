//+------------------------------------------------------------------+
//|                                             Lab_NavagateLine.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OrderMagicNumber_Fix=0;
bool _WostCase=true;
//

//---
string Tooltip="";

double ACC_Have=0;
//+------------------------------------------------------------------+
double Now_Array[1][3];
double Wost_Array[1][3];
int NowOrder_Cnt=0,WostOrder_Cnt=0;
double NowPrice_WAvg=0,NowPrice_Sigh=0,NowLot_sum=0,NowSwap_sum=0;
double WostPrice_WAvg=0,WostPrice_Sigh=0,WostLot_sum=0,WostSwap_sum=0;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int OnInit()
  {
   printf(l(__LINE__)+"--------------------------------------------------------");
//--- create timer
   EventSetTimer(60);

   OrderArray(true,2);
   OrderArray(false,2);

   string SMM;
   SMM+=l(__LINE__,"NowOrder_Cnt")+c(NowOrder_Cnt)+"\n";
   SMM+=l(__LINE__,"WostOrder_Cnt")+c(WostOrder_Cnt)+"\n";

   SMM+=l(__LINE__,"Now_Array")+c(ArraySize(Now_Array))+"\n";
   SMM+=l(__LINE__,"Wost_Array")+c(ArraySize(Wost_Array))+"\n";

   SMM+=l(__LINE__,"NowPrice_WAvg")+c(NowPrice_WAvg,Digits)+"\n";
   SMM+=l(__LINE__,"WostPrice_WAvg")+c(WostPrice_WAvg,Digits)+"\n";

   Comment(SMM);
     {
      HLineCreate_(0,"Price_WAvg-Now","",0,NowPrice_WAvg,clrRoyalBlue,0,0,false,false,false,0);
      HLineCreate_(0,"Price_High-Now","",0,Now_Array[NowOrder_Cnt-1][0],clrRoyalBlue,0,0,true,false,false,0);
      HLineCreate_(0,"Price_Low-Now","",0,Now_Array[0][0],clrRoyalBlue,0,0,true,false,false,0);

      HLineCreate_(0,"Price_Sigh-Now","",0,NowPrice_Sigh,clrRed,0,0,false,false,false,0);

     }
     {
      HLineCreate_(0,"Price_WAvg-Wost","",0,WostPrice_WAvg,clrRoyalBlue,3,0,true,false,false,0);
      HLineCreate_(0,"Price_Low-Wost","",0,Wost_Array[0][0],clrRoyalBlue,3,0,true,false,false,0);

      HLineCreate_(0,"Price_Sigh-Wost","",0,WostPrice_Sigh,clrRed,3,0,true,false,false,0);

     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderArray(bool WostCase,int MagicNumber)
  {
   int Temp_Order_Cnt=0;
     {//---Counting
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(!OrderSelect(pos,SELECT_BY_POS)) continue;
         if((OrderSymbol()==Symbol())==false) continue;
         if(OrderMagicNumber()!=MagicNumber) continue;
         //---
         if((WostCase && (OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT/* || OrderType()==OP_BUYSTOP*/)) ||
            (!WostCase && OrderType()==OP_BUY))
           {
            Temp_Order_Cnt++;
           }
        }
     }
   double TempArray[1][3];
   TempArray[0][0]=0;
   TempArray[0][1]=0;
   TempArray[0][2]=0;
   if(Temp_Order_Cnt>0)
     {//---getData
      ArrayResize(TempArray,Temp_Order_Cnt,0);
      for(int pos=0,i=0;pos<OrdersTotal();pos++)
        {
         if(!OrderSelect(pos,SELECT_BY_POS)) continue;
         if((OrderSymbol()==Symbol())==false) continue;
         if(OrderMagicNumber()!=MagicNumber) continue;
         //---
         if((WostCase && (OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT/* || OrderType()==OP_BUYSTOP*/)) ||
            (!WostCase && OrderType()==OP_BUY))
           {
            TempArray[i][0]=OrderOpenPrice();
            TempArray[i][1]=OrderLots();
            TempArray[i][2]=OrderSwap();
            i++;
           }
        }
      ArraySort(TempArray,WHOLE_ARRAY,0,MODE_ASCEND);
     }
   double Temp_Price_WAvg=0,Temp_Price_Sigh=0;
   double Temp_Lot_sum=0,Temp_Swap_sum=0;
   if(Temp_Order_Cnt>0)
     {//---Calculator AvgPrice
      for(int i=0;i<Temp_Order_Cnt;i++)
        {
         Temp_Price_WAvg+=TempArray[i][1]*TempArray[i][0];
         Temp_Lot_sum+=TempArray[i][1];
         Temp_Swap_sum+=TempArray[i][2];
        }
      //---       Price_WAvg
      Temp_Price_WAvg=NormalizeDouble(Temp_Price_WAvg,Digits);
      Temp_Lot_sum=NormalizeDouble(Temp_Lot_sum,2);
      Temp_Price_WAvg=NormalizeDouble((Temp_Price_WAvg/Temp_Lot_sum),Digits);
      //---       PointValue
      _PointValue(Temp_Price_WAvg,Temp_Lot_sum,5);
      //---       Price_WAvgSwap
      double Price_Swap=NormalizeDouble((Temp_Swap_sum*MODE_POINT_)/PointValue,Digits);
      Temp_Price_WAvg=NormalizeDouble(Temp_Price_WAvg-Price_Swap,Digits);
      //---       Price_Sigh
      double ACC_BALANCE=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2);
      double ACC_CREDIT=NormalizeDouble(AccountInfoDouble(ACCOUNT_CREDIT),2);
      double ACC_MARGIN=NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN),2);
      ACC_Have=NormalizeDouble((ACC_BALANCE+ACC_CREDIT)-ACC_MARGIN,2);

      Temp_Price_Sigh=NormalizeDouble((ACC_Have/PointValue)*MODE_POINT_,Digits);
      Temp_Price_Sigh=NormalizeDouble((Temp_Price_WAvg-Temp_Price_Sigh),Digits);
      //HLineCreate_(0,"Price_Sigh",Tooltip,0,Temp_Price_Sigh,clrWhite,1,0,0,true,false,0);
     }
     {
      if(WostCase)
        {
         WostOrder_Cnt=Temp_Order_Cnt;
         ArrayCopy(Wost_Array,TempArray,0,0,WHOLE_ARRAY);
         WostPrice_WAvg=Temp_Price_WAvg;
         WostPrice_Sigh=Temp_Price_Sigh;
         WostLot_sum=Temp_Lot_sum;
         WostSwap_sum=Temp_Swap_sum;
        }
      else
        {
         NowOrder_Cnt=Temp_Order_Cnt;
         ArrayCopy(Now_Array,TempArray,0,0,WHOLE_ARRAY);
         NowPrice_WAvg=Temp_Price_WAvg;
         NowPrice_Sigh=Temp_Price_Sigh;
         NowLot_sum=Temp_Lot_sum;
         NowSwap_sum=Temp_Swap_sum;
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
double PointValue;
double ContractSize=MarketInfo(Symbol(),MODE_LOTSIZE);
double MODE_POINT_=MarketInfo(Symbol(),MODE_POINT);
//+------------------------------------------------------------------+
void _PointValue(double Traget_1,double lot,int digit)
  {
   string _ACCOUNT_CURRENCY=AccountInfoString(ACCOUNT_CURRENCY);
   string _SYMBOL_CURRENCY=StringSubstr(Symbol(),0,3);
//+------------------------------
   printf(l(__LINE__,"_PointValue()--------------"));
   printf(l(__LINE__,"Traget_1(W-Price)")+c(Traget_1,Digits));
   printf(l(__LINE__,"lot")+c(lot,2));

   PointValue=NormalizeDouble(((MODE_POINT_/Traget_1))*(ContractSize*lot),digit);//_SYMBOL_CURRENCY
   printf(l(__LINE__,"_PointValue")+c(PointValue,Digits));
   printf(l(__LINE__,"_PointValue()--------------#"));
//+------------------------------
   if(_ACCOUNT_CURRENCY!=_SYMBOL_CURRENCY)
     {
      string CurrencyPair_1=_SYMBOL_CURRENCY+_ACCOUNT_CURRENCY;
      string CurrencyPair_2=_ACCOUNT_CURRENCY+_SYMBOL_CURRENCY;
      double Rate_1=MarketInfo(CurrencyPair_1,MODE_BID);
      double Rate_2=MarketInfo(CurrencyPair_2,MODE_BID);

      if(Rate_1>0)
        {
         PointValue=PointValue*Rate_1;
         //Rate_CurrencyPair=CurrencyPair_1+" [*]1";
        }
      else if(Rate_2>0)
        {
         PointValue=PointValue/Rate_2;
         //Rate_CurrencyPair=CurrencyPair_2+" [/]2";
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
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
   if(id==CHARTEVENT_OBJECT_CLICK || id==CHARTEVENT_OBJECT_CHANGE || id==CHARTEVENT_CLICK)
     {
      //BTN_A_AddZoneDrawB(sparam,"Price_Sigh2");

      BTN_A_AddZoneDrawB("Price_Sigh2","Price_Sigh2");
     }
  }
//+------------------------------------------------------------------+
void BTN_A_AddZoneDrawB(string sparam,string NameBTN)
  {
   NameBTN=NameBTN;
   if(sparam==NameBTN)
     {/*
double obj_DraftPrice=ObjectGetDouble(0,"Price_Sigh2",OBJPROP_PRICE);
      NormalizeDouble(obj_DraftPrice,Digits);

      //_PointValue(Price_WAvg,Lot_sum,5);
      double dWAvg=MathAbs(Price_WAvg-obj_DraftPrice);
      double dLow=MathAbs(Array_Order[0][0]-obj_DraftPrice);

      double Have=NormalizeDouble((dWAvg/Price_WAvg)*ContractSize*Lot_sum,2);

      double ACC_MARGIN=NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN),2);
      double Require=NormalizeDouble(ACC_Have-Have,2);

      //double ContractSize=MarketInfo(Symbol(),MODE_LOTSIZE);
      //double MODE_POINT_=MarketInfo(Symbol(),MODE_POINT);

      string SMM;
      SMM+=l(__LINE__,"ACC_Have")+c(ACC_Have,2)+"\n";
      SMM+=l(__LINE__,"D-WAvg")+cm(dWAvg*MathPow(10,Digits),0," ")+"p\n";
      SMM+=l(__LINE__,"D-Low")+cm(dLow*MathPow(10,Digits),0," ")+"p\n";

      SMM+=l(__LINE__,"Require-Eq")+c(Have,2)+"\n";
      SMM+=l(__LINE__,"Require-Fill")+c(Require,2)+"\n";
      Comment(SMM);*/
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Master(bool WostCase)
  {
/* 
{//---Counting
      OrderActive_Cnt=0;
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(!OrderSelect(pos,SELECT_BY_POS)) continue;
         if(OrderSymbol()==Symbol()==false) continue;
         //---
         if((WostCase && (OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)) || OrderType()==OP_BUY)
           {
            OrderActive_Cnt++;
           }
        }
     }
     {//---getData
      printf(l(__LINE__,"OrderActive_Cnt")+c(OrderActive_Cnt));
      ArrayResize(Array_Order,OrderActive_Cnt,0);
      for(int pos=0,i=0;pos<OrdersTotal();pos++)
        {
         if(!OrderSelect(pos,SELECT_BY_POS)) continue;
         //if(!OrderType()==OP_BUY) continue;
         if(OrderSymbol()==Symbol()==false) continue;
         //if((OrderMagicNumber_Fix==0)==false || (OrderMagicNumber()==OrderMagicNumber_Fix)==false)continue;
         //---
         if((WostCase && (OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)) || OrderType()==OP_BUY)
           {
            Array_Order[i][0]=OrderOpenPrice();
            Array_Order[i][1]=OrderLots();
            Array_Order[i][2]=OrderSwap();
            i++;
           }
        }
     }
   ArraySort(Array_Order,WHOLE_ARRAY,0,MODE_ASCEND);
     {//---Calculator AvgPrice

      for(int i=0;i<OrderActive_Cnt;i++)
        {
         Price_WAvg+=Array_Order[i][1]*Array_Order[i][0];
         Lot_sum+=Array_Order[i][1];
         Swap_sum+=Array_Order[i][2];
        }
      //---       Price_WAvg
      Price_WAvg=NormalizeDouble(Price_WAvg,Digits);
      Lot_sum=NormalizeDouble(Lot_sum,2);
      Price_WAvg=NormalizeDouble((Price_WAvg/Lot_sum),Digits);
      HLineCreate_(0,"Price_WAvg",Tooltip,0,Price_WAvg,clrBlue,1,0,0,true,false,0);

      //---       PointValue
      _PointValue(Price_WAvg,Lot_sum,5);

      //---       Price_WAvgSwap
      double Price_Swap=NormalizeDouble((Swap_sum*MODE_POINT_)/PointValue,Digits);
      Price_Swap=NormalizeDouble(Price_WAvg-Price_Swap,Digits);
      if(Price_Swap!=Price_Swap)
        {
         HLineCreate_(0,"Price_WAvgSwap",Tooltip,0,Price_Swap,clrRoyalBlue,1,0,0,true,false,0);
        }

      //---       Price_Sigh
      double ACC_BALANCE=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2);
      double ACC_CREDIT=NormalizeDouble(AccountInfoDouble(ACCOUNT_CREDIT),2);
      double ACC_MARGIN=NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN),2);
      ACC_Have=NormalizeDouble((ACC_BALANCE+ACC_CREDIT)-ACC_MARGIN,2);

      double Price_Sigh=NormalizeDouble((ACC_Have/PointValue)*MODE_POINT_,Digits);
      Price_Sigh=NormalizeDouble((Price_WAvg-Price_Sigh),Digits);
      HLineCreate_(0,"Price_Sigh",Tooltip,0,Price_Sigh,clrWhite,1,0,0,true,false,0);

      //+------------------------------------------------------------------+
      if(Array_Order[0][0]<Price_Sigh)
        {
         int PlaceTrade=MessageBox("The zone is now very dangerous.","Price_Sigh and LowerZone",MB_OK|MB_OKCANCEL|MB_ICONWARNING);
        }
      //+------------------------------------------------------------------+

      //---      
      if(OrderActive_Cnt>=2)
        {
         HLineCreate_(0,"Price_Start","",0,Array_Order[0][0],clrMagenta,1,0,0,true,false,0);
         HLineCreate_(0,"Price_End","",0,Array_Order[OrderActive_Cnt-1][0],clrYellow,1,0,0,true,false,0);
        }
     }
     */
  }
//+------------------------------------------------------------------+
