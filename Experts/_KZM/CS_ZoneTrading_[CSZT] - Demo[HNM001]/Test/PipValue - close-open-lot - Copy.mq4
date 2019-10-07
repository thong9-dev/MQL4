//+------------------------------------------------------------------+
//|                                                     PipValue.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>

double Cap=10;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(1000);

   ObjectsDeleteAll(ChartID(),"BTN",0,OBJ_BUTTON);

   _setBUTTON("BTN_A",0,CORNER_LEFT_LOWER,100,20,10,30,false,10,clrBlack,clrLime,"Show");
   _setBUTTON("BTN_B",0,CORNER_LEFT_LOWER,100,20,120,30,false,10,clrBlack,clrBlue,"Pending");

   ObjectSetDouble(0,"A",OBJPROP_PRICE,Ask);
   ObjectSetDouble(0,"B",OBJPROP_PRICE,Bid);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
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
   OnTimer();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//ObjectSetDouble(0,"A",OBJPROP_PRICE,Bid);
   double obj_DraftPrice_1=ObjectGetDouble(0,"A",OBJPROP_PRICE);//Blue
   double obj_DraftPrice_2=ObjectGetDouble(0,"B",OBJPROP_PRICE);//Red
                                                                //getLot(Cap,obj_DraftPrice_1,obj_DraftPrice_2);
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
      BTN_A(sparam,"BTN_A");
      BTN_B(sparam,"BTN_B");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_A(string sparam,string NameBTN)
  {
   if(sparam==NameBTN)
     {
      int PlaceTrade=MessageBox(NameBTN+"\n"+"\n","Place Order?",MB_OK|MB_OKCANCEL);
      if(PlaceTrade==6){ Print("MB: YES Button Pressed");}  // -------------- Message BOX returns YES
      if(PlaceTrade==7){ Print("MB: NO Button Pressed");}  // -------------- Message BOX returns NO
      if(PlaceTrade==IDOK){ Print("MB: OK Button Pressed");}  // -------------- Message BOX returns OK
      if(PlaceTrade==2){ Print("MB: Cancel Button Pressed");}  // -------------- Message BOX returns Cancel

      double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL)/MathPow(10,Digits);
      printf(STOPLEVEL);

      double SL=Bid-STOPLEVEL;
      double TP=Ask+MathAbs(Ask-SL);

      TP=NormalizeDouble(TP,Digits);
      SL=NormalizeDouble(SL,Digits);

      ObjectSetDouble(0,"SL",OBJPROP_PRICE,SL);
      ObjectSetDouble(0,"TP",OBJPROP_PRICE,TP);
      if(PlaceTrade==IDOK)
         int ticket=OrderSend(Symbol(),OP_BUY,NormalizeDouble(getLot(Cap,Ask,SL),2),Ask,3,SL,TP,"Test SL "+c(Cap,2)+" | "+c(STOPLEVEL,Digits),0,0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_B(string sparam,string NameBTN)
  {
   if(sparam==NameBTN)
     {
      HLineCreate_(0,"LINE_DraftLine","",0,Bid,clrBlue,1,0,0,true,false,0);
      ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
      ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);

      int PlaceTrade=MessageBox("Draw a horizontal line and press OK.",NameBTN,MB_OK|MB_OKCANCEL|MB_ICONQUESTION);
      if(PlaceTrade==IDOK)
        {

         Print(NameBTN+"MB: OK Button Pressed");

         double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL)/MathPow(10,Digits);
         printf(STOPLEVEL);

         double obj_DraftPrice=ObjectGetDouble(0,"LINE_DraftLine",OBJPROP_PRICE);
         obj_DraftPrice=NormalizeDouble(obj_DraftPrice,Digits);

         double TP=obj_DraftPrice+STOPLEVEL;
         double SL=obj_DraftPrice-STOPLEVEL;

         TP=NormalizeDouble(TP,Digits);
         SL=NormalizeDouble(SL,Digits);

         ObjectSetDouble(0,"SL",OBJPROP_PRICE,SL);
         ObjectSetDouble(0,"TP",OBJPROP_PRICE,TP);

         TP=0;
         //SL=0;

         int ticket=1;
         if(obj_DraftPrice>Ask)
           {
            Print(NameBTN+"OP_BUYSTOP");
            ticket=OrderSend(Symbol(),OP_BUYSTOP,NormalizeDouble(getLot(Cap,obj_DraftPrice,SL),2),obj_DraftPrice,3,SL,TP,"Test SL "+c(Cap,2)+" | "+c(STOPLEVEL,Digits),0,0);

           }
         if(obj_DraftPrice<Ask)
           {
            Print(NameBTN+"OP_BUYLIMIT");
            ticket=OrderSend(Symbol(),OP_BUYLIMIT,NormalizeDouble(getLot(Cap,obj_DraftPrice,SL),2),obj_DraftPrice,3,SL,TP,"Test SL "+c(Cap,2)+" | "+c(STOPLEVEL,Digits),0,0);
           }
         Print(NameBTN+" ticket: "+ticket);
         if(ticket>=0)
           {
            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);
            ObjectDelete(0,"LINE_DraftLine");
           }
         else
           {
            PlaceTrade=MessageBox("Place Pendig Order is "+ticket,NameBTN,MB_OK|MB_ICONWARNING);
            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);
            ObjectDelete(0,"LINE_DraftLine");
           }
        }
      if(PlaceTrade==IDCANCEL)
        {
         Print(NameBTN+" MB: Cancel Button Pressed");
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);
         ObjectDelete(0,"LINE_DraftLine");
        }
     }
  }
double Lot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLot(double cap,double Traget_1,double Traget_2)
  {
   string mms="";

   string _ACCOUNT_CURRENCY=AccountInfoString(ACCOUNT_CURRENCY);
   string _SYMBOL_CURRENCY=StringSubstr(Symbol(),0,3);

   mms+="_ACCOUNT_CUR: "+_ACCOUNT_CURRENCY+"\n";
   mms+="_SYMBOL_CUR: "+_SYMBOL_CURRENCY+"\n";
//-------------------------------------

   double ContractSize=MarketInfo(Symbol(),MODE_LOTSIZE);

//-------------------------------------

   double D=(Traget_2-Traget_1);
   mms+="D: "+c(D,Digits)+"\n";

   double _Result=0,_Result_2=0;
   string _Result_CURRENCY="",_Result_2_CURRENCY="";

   double Rate_1=0,Rate_2=0,Rate_3=0,Rate_4=0;
   double Rate_Use=0;
   string Rate_CurrencyPair="";

   string CurrencyPair_1;
   string CurrencyPair_2;
   if(D!=0)
     {
      if(_ACCOUNT_CURRENCY==_SYMBOL_CURRENCY)
        {
         //---
         _Result=(D/Traget_1)*(Lot*ContractSize);

         Lot=(cap*Traget_1)/(D*ContractSize);

         //---
         _Result_CURRENCY=_SYMBOL_CURRENCY;
        }
      else
        {
           {
           CurrencyPair_1=_SYMBOL_CURRENCY+_ACCOUNT_CURRENCY;
           CurrencyPair_2=_ACCOUNT_CURRENCY+_SYMBOL_CURRENCY;
            Rate_1=MarketInfo(CurrencyPair_1,MODE_BID);
            Rate_2=MarketInfo(CurrencyPair_2,MODE_BID);
            if(Rate_1>0)
              {

               Lot=((cap*Traget_1)/(D*ContractSize))/Rate_1;

               _Result_2=(D/Traget_1)*(Lot*ContractSize)*Rate_1;

               Rate_CurrencyPair=_SYMBOL_CURRENCY+_ACCOUNT_CURRENCY+" [*]1";
              }
            if(Rate_2>0)
              {

               Lot=((cap*Traget_1)/(D*ContractSize))*Rate_2;

               _Result_2=(D/Traget_1)*(Lot*ContractSize)/Rate_2;

               Rate_CurrencyPair=_ACCOUNT_CURRENCY+_SYMBOL_CURRENCY+" [/]2";
              }
              {
               _Result_CURRENCY=_SYMBOL_CURRENCY;
               _Result_2_CURRENCY=_ACCOUNT_CURRENCY;
              }
           }
        }
     }
//---
   mms+="-------\n";
   mms+="_Result_1: "+c(_Result,2)+" "+_Result_CURRENCY+"\n";

   mms+="Lot: "+c(Lot,2)+"\n";

   mms+="-------\n";
   mms+="_Result_2: "+c(_Result_2,2)+" "+_Result_2_CURRENCY+"\n";

   mms+="Rate_1:"+CurrencyPair_1+" "+Rate_1+"\n";
   mms+="Rate_2:"+CurrencyPair_2+" "+Rate_2+"\n";

   mms+="CurPair: "+Rate_CurrencyPair+"\n";
   Comment(mms);

   double r=MathAbs(NormalizeDouble(Lot,2));
   printf("getLot: "+r);
   return r;
  }
//+------------------------------------------------------------------+
