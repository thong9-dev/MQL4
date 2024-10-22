//+------------------------------------------------------------------+
//|                                                     Rosegold.mq4 |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include "Rosegold_Method.mqh";

//+------------------------------------------------------------------+
//| INPUT PARAMETERS                                                 |
//+------------------------------------------------------------------+

input int      Input1;
int OrderinAR;
int MagicNumber=1234;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string Name;

/*for(int i=0;i<2;i++)
     {
      Name="Text"+i;
      _LabelCreate(Name,0);
     }*/

   _setTemplate();
   //BT_PriceBB();
//+------------------------------------------------------------------+
   _setBUTTON("BTN_X__BUY",0,120,30,100,100,10,clrBlack,clrGreen);
   _setBUTTON("BTN_X_SELL",0,120,30,100,140,10,clrBlack,clrRed);
   _setBUTTON("BTN_X__ALL",0,120,30,100,180,10,clrBlack,clrGold);
   _setBUTTON("BTN_X_PROFIT",0,120,30,100,220,10,clrBlack,clrGold);

   _setBUTTON("BTN_BUY",0,120,30,240,100,10,clrBlack,clrGreen);
   _setBUTTON("BTN_SELL",0,120,30,240,140,10,clrBlack,clrRed);

   _setBUTTON("SCLR",0,120,30,240,180,10,clrBlack,clrMagenta);

//---
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int CNT_BUYY,CNT_SELL;

string inar;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bx[6];
double Base=MathPow(10,Digits);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   CNT_BUYY=_Order_CNT(OP_BUY,0);
   CNT_SELL=_Order_CNT(OP_SELL,0);

//_LabelSet("Text0",10,20,clrYellow,"Arial",10,CNT_BUYY+"/"+CNT_SELL+"/"+OrderinAR+"test");
   BT_PriceBB();
   Comment(C1,C2,C3,C4," ",t1,t2);
   _setBUTTON_State();
//---
   int period=150,Shift=0;
   double iBands_6=iBands(Symbol(),0,period,6,0,PRICE_TYPICAL,1,Shift);
   double iBands_5=iBands(Symbol(),0,period,5,0,PRICE_TYPICAL,1,Shift);
   double iBands_4=iBands(Symbol(),0,period,4,0,PRICE_TYPICAL,1,Shift);
   double iBands_3=iBands(Symbol(),0,period,3,0,PRICE_TYPICAL,1,Shift);
   double iBands_2=iBands(Symbol(),0,period,2,0,PRICE_TYPICAL,1,Shift);
   double iBands_1=iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,1,Shift);
   double iBands_0=iBands(Symbol(),0,period,0,0,PRICE_TYPICAL,1,Shift);

   string SMS;
   Base=MathPow(10,Digits);
   SMS+=_Comma((iBands_6-iBands_5)*Base,0,"")+"|";
   SMS+=_Comma((iBands_5-iBands_4)*Base,0,"")+"|";
   SMS+=_Comma((iBands_4-iBands_3)*Base,0,"")+"|";
   SMS+=_Comma((iBands_3-iBands_2)*Base,0,"")+"|";
   SMS+=_Comma((iBands_2-iBands_1)*Base,0,"")+"|";
   SMS+=_Comma((iBands_1-iBands_0)*Base,0,"")+"*";

   _LabelSet("Text1",10,30,clrWhite,"Arial",15,SMS);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

//---  
  }
//+------------------------------------------------------------------+
int C1,C2,C3,C4,C5,C6;
int t1,t2;
string v="0";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                  )
  {
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      if(sparam=="BTN_X_SELL")
        {
         ObjectSetInteger(0,"BTN_X_SELL",OBJPROP_BGCOLOR,clrWhite);
         C1++;
         //---
         _setBlacklistOrder(OP_SELL,MagicNumber);
         //---
        }
      if(sparam=="BTN_X__BUY")
        {
         ObjectSetInteger(0,"BTN_X__BUY",OBJPROP_BGCOLOR,clrWhite);
         C2++;
         //---
         _setBlacklistOrder(OP_BUY,MagicNumber);
         //---
        }
      if(sparam=="BTN_X__ALL")
        {
         ObjectSetInteger(0,"BTN_X__ALL",OBJPROP_BGCOLOR,clrWhite);
         C3++;

         //---
         _setBlacklistOrder(OP_BUY,MagicNumber);
         _setBlacklistOrder(OP_SELL,MagicNumber);
         //---

        }
      if(sparam=="BTN_X_PROFIT")
        {
         ObjectSetInteger(0,"BTN_X_PROFIT",OBJPROP_BGCOLOR,clrWhite);
         C4++;
         //---

         //---

        }
      if(sparam=="BTN_BUY")
        {
         ObjectSetInteger(0,"BTN_BUY",OBJPROP_BGCOLOR,clrWhite);
         C5++;
         //---
         OrderSend(Symbol(),OP_BUY,0.01,Ask,3,0,0,"Rosegold["+MagicNumber+"]",MagicNumber);
         //---

        }
      if(sparam=="BTN_SELL")
        {
         ObjectSetInteger(0,"BTN_SELL",OBJPROP_BGCOLOR,clrWhite);
         C6++;
         //---

         OrderSend(Symbol(),OP_SELL,0.01,Bid,3,0,0,"Rosegold["+MagicNumber+"]",MagicNumber);
         _ChartScreenShot("OP_SELL");
         //---

        }
      if(sparam=="SCLR")
        {
         ObjectSetInteger(0,"SCLR",OBJPROP_BGCOLOR,clrWhite);
         C6++;
         //+------------------------------------------------------------------+
         _ChartScreenShot("Profit");
         //+------------------------------------------------------------------+

        }
      //+------------------------------------------------------------------+

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BT_PriceBB()
  {
   int GridTP=1;
   int Dir_OP=1;
   double Price=Bid;
//---------------------------------------------------------------
   int period=45,Shift=0;
   int a=6;
   int z=a*(-1);

   double iBands_UP,iBands_DW,iBands_TP;
   double iLine_UP,iLine_DW,iLine_TP;

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
//+------------------------------------------------------------------+
   if(Dir_OP==0)//Buy
     {
      iLine_TP=iLine_UP+GridTP;
     }
   else//Sell
     {
      iLine_TP=iLine_DW-GridTP;
     }
   iBands_TP=iBands(Symbol(),0,period,iLine_TP,0,PRICE_TYPICAL,1,Shift);

//+------------------------------------------------------------------+

   string SMS;
   SMS+=_Comma(iBands_TP,Digits,"")+" | ";
//_LabelSet("Text1",10,30,clrWhite,"Arial",15,SMS);

   HLineCreate_(0,"Line_UP",0,iBands_UP,clrYellow,0,0,false,true,false,0);
   HLineCreate_(0,"Line_DW",0,iBands_DW,clrLime,0,0,false,true,false,0);

   HLineCreate_(0,"Line_TP",0,iBands_TP,clrMagenta,0,0,false,true,false,0);

   return iBands_TP;
  }
//+------------------------------------------------------------------+
double BT_PriceBB1(double _PriceEntry,string OP_Dir,int TPGrid=0)
  {
//int TPGrid=0;
//string OP_Dir="Sell1";
//+------------------------------------------------------------------+
/*0 - MODE_MAIN 1 - MODE_UPPER, 2 - MODE_LOWER*/
   bool on=false;
   int BW=-1,BTP=-1;
   string Dir;
   int Dir_;
   double iBands_UP,iBands_DW,iBands_TP;
//---
   int period=50,Shift=1;
   double deviation=2;
   double Price=_PriceEntry;
   int c=20;
//---

   if(Price>iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,0,Shift))
     {//----------UP
      for(int i=0;i<c;i++)
        {
         iBands_UP=iBands(Symbol(),0,period,i+1,0,PRICE_TYPICAL,1,Shift);
         iBands_DW=iBands(Symbol(),0,period,i,0,PRICE_TYPICAL,1,Shift);
         if(i==0)
            iBands_DW=iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,0,Shift);
         //---------------------------------------------------------------
         if(iBands_UP>Price && Price>iBands_DW)
           {
            BW=i+1;
            Dir="UP";
            Dir_=1;
            break;
           }
        }
     }
   else
     {//----------DW
      for(int i=0;i<c;i++)
        {
         iBands_UP=iBands(Symbol(),0,period,i,0,PRICE_TYPICAL,2,Shift);
         iBands_DW=iBands(Symbol(),0,period,i+1,0,PRICE_TYPICAL,2,Shift);
         if(i==0)
            iBands_UP=iBands(Symbol(),0,period,1,0,PRICE_TYPICAL,0,Shift);
         //---------------------------------------------------------------
         if(iBands_UP>Price && Price>iBands_DW)
           {
            BW=i+1;
            Dir="DW";
            Dir_=2;
            break;
           }
        }
     }
//-------
   if(OP_Dir=="Sell")
     {
      if(Dir_==1)
        {
         BTP=BW-(TPGrid+1);
        }
      else
        {
         BTP=BW+TPGrid;
        }
     }
   else
     {
      if(Dir_==1)
        {
         BTP=BW+TPGrid;
        }
      else
        {
         BTP=BW-(TPGrid+1);
        }
     }

   iBands_TP=iBands(Symbol(),0,period,BTP,0,PRICE_TYPICAL,Dir_,Shift);
//-------
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
   SMS+=BTP+"TP: "+_Comma(iBands_TP,Digits,"")+"["+_Comma(ProfitPoint*(MathPow(10,Digits)),0,"")+"]";

   _LabelSet("Text2",10,60,clrWhite,"Arial",15,SMS);

//HLineCreate_(0,"A",0,iBands_UP,clrWhite,0,0,false,true,false,0);
//HLineCreate_(0,"B",0,iBands_DW,clrWhite,0,0,false,true,false,0);

   HLineCreate_(0,"Price",0,Price,clrYellow,0,0,false,true,false,0);
   HLineCreate_(0,"TP",0,iBands_TP,clrLime,0,0,false,true,false,0);

   return NormalizeDouble(iBands_TP,Digits);
  }
//+------------------------------------------------------------------+
