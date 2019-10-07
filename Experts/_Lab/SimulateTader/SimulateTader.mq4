//|                                                SimulateTader.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |

#property strict

//| Expert initialization function                                   |

#include <Tools/Method_Tools.mqh>
string ExtName_OBJ="SimulateTader";
int windex=0;
//---
#import "user32.dll"
int RegisterWindowMessageW(string MessageName);
int PostMessageW(int hwnd,int msg,int wparam,string Name);
#import
//---

#include <Controls/Button.mqh>
CButton Button_Buy;
#include <Controls/Panel.mqh>
CPanel Panel,Pane2,Pane3;

int Size_Wide=70;
int Size_High=17;
int PostX_Default=10,XStep=Size_Wide+5;
int PostY_Default=15,YStep=Size_High+5;
int PostX_DefDashboard=10,XStepDashboard=Size_Wide+5;
int PostY_DefDashboard=88,YStepDashboard=Size_High+5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color Chart_BG=C'25,25,25';//Chart_BG=C'31,31,31';

int Speed=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(500);
   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,Chart_BG);

   //ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,false);
   //ChartSetInteger(0,CHART_SHOW_DATE_SCALE,false);
   
   windex=WindowFind("CS_ZoneTrading");
//ChartApplyTemplate(0,"Sim2");
   Panel.Create(0,"PN",windex,5,105,int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,windex)-5),105);
   Panel.ColorBackground(C'100,100,100');
//Pane2.Create(0,"PN2",windex,5,105,ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,windex)-5,105);
   Pane2.Create(0,"PN2",windex,467,5,467,int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,windex)-5));
   Pane2.ColorBackground(C'100,100,100');

   Pane3.Create(0,"PN3",windex,940,5,940,105);
   Pane3.ColorBackground(C'100,100,100');

//---
   int PostX=PostX_Default;
   int PostY=PostY_Default;
//-----Down To Right-----//
   PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX01_0","TP","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX02_0","SL","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX03_0","Lots","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX04_0","Order","",clrWhite,PostX,PostY); PostX+=XStep;

//---
   PostX=PostX_Default;
   PostY+=YStep;
   PostX+=XStep;
   _EditCreate(ExtName_OBJ+"_BuyTP_0",windex,"100"
               ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
               ,clrWhite,Chart_BG,clrLime,false,false,false,0);
   PostX+=XStep;
   _EditCreate(ExtName_OBJ+"_BuySL_0",windex,"300"
               ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
               ,clrWhite,Chart_BG,clrRed,false,false,false,0);
   PostX+=XStep;
   _EditCreate(ExtName_OBJ+"_BuyLot_0",windex,"0.01"
               ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
               ,clrWhite,Chart_BG,clrSilver,false,false,false,0);
   PostX+=XStep;
   setBUTTON(ExtName_OBJ+"_Buy_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High,PostX,PostY,true,10,clrDodgerBlue,clrBlack,clrDimGray,"Buy");

//---
   PostX=PostX_Default;
   PostY+=YStep;
   PostX+=XStep;
   _EditCreate(ExtName_OBJ+"_SellTP_0",windex,"100"
               ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
               ,clrWhite,Chart_BG,clrLime,false,false,false,0);
   PostX+=XStep;
   _EditCreate(ExtName_OBJ+"_SellSL_0",windex,"300"
               ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
               ,clrWhite,Chart_BG,clrRed,false,false,false,0);
   PostX+=XStep;
   _EditCreate(ExtName_OBJ+"_SellLot_0",windex,"0.01"
               ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
               ,clrWhite,Chart_BG,clrSilver,false,false,false,0);
   PostX+=XStep;
   setBUTTON(ExtName_OBJ+"_Sell_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High,PostX,PostY,true,10,clrRed,clrBlack,clrDimGray,"Sell");
/*PostY=PostY_Default;
   setLabel(ExtName_OBJ+"_TXS01_0","Balance : ","",clrWhite,PostX,PostY);PostY+=YStep;
   setLabel(ExtName_OBJ+"_TXS02_0","Hold/DD : ","",clrWhite,PostX,PostY);PostY+=YStep;
   setLabel(ExtName_OBJ+"_TXS03_0","MaxDD : ","",clrWhite,PostX,PostY);PostY+=YStep;
   setLabel(ExtName_OBJ+"_TXS04_0","Profits/Cap : ","",clrWhite,PostX,PostY);PostY+=YStep;
   PostX+=XStep;*/

   PostY=PostY_Default;
   PostX+=XStep*2;
   int PostX_DefaultGroup2=(PostX)+20;
   PostX=PostX_DefaultGroup2;
   setLabel(ExtName_OBJ+"_TX11_0","Contol","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX12_0","Price","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX13_0","Lot","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX14_0","Point","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX15_0","Close+","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX16_0","CloseAll","",clrWhite,PostX,PostY); PostX+=XStep;
   PostX=PostX_DefaultGroup2;
   PostY+=YStep;
   setLabel(ExtName_OBJ+"_TX21_0","Buy","",clrDodgerBlue,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX22_0","Buy","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX23_0","Buy","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX24_0","Buy","",clrWhite,PostX,PostY); PostX+=XStep;

   setBUTTON(ExtName_OBJ+"_BuyX_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High+2,PostX,PostY,false,10,clrDodgerBlue,clrBlack,clrDimGray,"12,345.00");PostX+=XStep;
   setBUTTON(ExtName_OBJ+"_BuyX2_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High+2,PostX,PostY,false,10,clrRed,clrBlack,clrDimGray,"12,345.00");

   PostX=PostX_DefaultGroup2;
   PostY+=YStep;
   setLabel(ExtName_OBJ+"_TX31_0","Sell","",clrRed,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX32_0","Sell","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX33_0","Sell","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX34_0","Sell","",clrWhite,PostX,PostY); PostX+=XStep;

   setBUTTON(ExtName_OBJ+"_SellX_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High+2,PostX,PostY,false,10,clrDodgerBlue,clrBlack,clrDimGray,"12,345.00");PostX+=XStep;
   setBUTTON(ExtName_OBJ+"_SellX2_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High+2,PostX,PostY,false,10,clrRed,clrBlack,clrDimGray,"12,345.00");

   PostX=PostX_DefaultGroup2;
   PostY+=YStep;
   setLabel(ExtName_OBJ+"_TX41_0","Hege","",clrGold,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX42_0","Hege","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX43_0","Hege","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TX44_0","Hege","",clrWhite,PostX,PostY); PostX+=XStep;

   setBUTTON(ExtName_OBJ+"_HegeX_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High+2,PostX,PostY,false,9,clrDodgerBlue,clrBlack,clrDimGray,"12,345.00");PostX+=XStep;
   setBUTTON(ExtName_OBJ+"_HegeX2_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High+2,PostX,PostY,false,10,clrRed,clrBlack,clrDimGray,"12,345.00");PostX+=XStep;

   PostY=PostY_Default;
   PostX+=20;
   setLabel(ExtName_OBJ+"_Speed1_H","Speed","",clrWhite,PostX,PostY); PostY+=YStep;

   setBUTTON(ExtName_OBJ+"_Speed1_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High,PostX,PostY,true,10,clrYellow,clrBlack,clrDimGray,"1");PostY+=YStep;
   setBUTTON(ExtName_OBJ+"_Speed2_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High,PostX,PostY,true,10,clrOrangeRed,clrBlack,clrDimGray,"2");PostY+=YStep;
   setBUTTON(ExtName_OBJ+"_Speed3_0",windex,CORNER_LEFT_UPPER,
             Size_Wide,Size_High,PostX,PostY,true,10,clrRed,clrBlack,clrDimGray,"3");

//---
   return(INIT_SUCCEEDED);
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
//|                                                                  |
//+------------------------------------------------------------------+
bool Lock=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   ObjectsDeleteAll(0,"at",0,OBJ_ARROW);
//ObjectsDeleteAll(0,"->",0,OBJ_TREND);
   if(Lock)
     {
      windex=WindowFind("CS_ZoneTrading");
      if(windex>=0)
        {
         Lock=false;
         OnInit();
        }
     }

   Pane2.Create(0,"PN2",windex,445,5,445,int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,windex)-5));
//+------------------------------------------------------------------+
   if(ObjectGetInteger(0,ExtName_OBJ+"_Speed1_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_Speed1_0",OBJPROP_BGCOLOR,clrWhite);
      ObjectSetInteger(0,ExtName_OBJ+"_Speed1_0",OBJPROP_STATE,false);
      //      
      Speed-=10000000;
     }
   else
      ObjectSetInteger(0,ExtName_OBJ+"_Speed1_0",OBJPROP_BGCOLOR,clrBlack);

   if(ObjectGetInteger(0,ExtName_OBJ+"_Speed2_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_Speed2_0",OBJPROP_BGCOLOR,clrWhite);
      ObjectSetInteger(0,ExtName_OBJ+"_Speed2_0",OBJPROP_STATE,false);
      //      
      Speed+=10000000;
     }
   else
      ObjectSetInteger(0,ExtName_OBJ+"_Speed2_0",OBJPROP_BGCOLOR,clrBlack);
//---
   for(int i=0;i<Speed;i++)
     {

     }
   Comment(Speed);
//+------------------------------------------------------------------+

//---
   if(ObjectGetInteger(0,ExtName_OBJ+"_Buy_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_Buy_0",OBJPROP_BGCOLOR,clrWhite);

      double TP=double(ObjectGetString(0,ExtName_OBJ+"_BuyTP_0",OBJPROP_TEXT,0));

      double SL=double(ObjectGetString(0,ExtName_OBJ+"_BuySL_0",OBJPROP_TEXT,0));
      double LT=double(ObjectGetString(0,ExtName_OBJ+"_BuyLot_0",OBJPROP_TEXT,0));

      double OP=nd(Ask);
      TP=(TP==0)?0:nd(OP+(TP/MathPow(10,Digits)));
      SL=(SL==0)?0:nd(OP-(SL/MathPow(10,Digits)));

      bool res=OrderSend(Symbol(),OP_BUY,LT,OP,3,SL,TP);
      ObjectSetInteger(0,ExtName_OBJ+"_Buy_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_Buy_0",OBJPROP_BGCOLOR,clrBlack);

     }
   if(ObjectGetInteger(0,ExtName_OBJ+"_Sell_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_Sell_0",OBJPROP_BGCOLOR,clrWhite);

      double TP=double(ObjectGetString(0,ExtName_OBJ+"_SellTP_0",OBJPROP_TEXT,0));
      double SL=double(ObjectGetString(0,ExtName_OBJ+"_SellSL_0",OBJPROP_TEXT,0));
      double LT=double(ObjectGetString(0,ExtName_OBJ+"_SellLot_0",OBJPROP_TEXT,0));

      double OP=nd(Bid);
      TP=(TP==0)?0:nd(OP-(TP/MathPow(10,Digits)));
      SL=(SL==0)?0:nd(OP+(SL/MathPow(10,Digits)));

      bool res=OrderSend(Symbol(),OP_SELL,LT,OP,3,SL,TP);
      ObjectSetInteger(0,ExtName_OBJ+"_Sell_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_Sell_0",OBJPROP_BGCOLOR,clrBlack);

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ObjectGetInteger(0,ExtName_OBJ+"_BuyX_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_BuyX_0",OBJPROP_BGCOLOR,clrWhite);
      Order_CloseAll(OP_BUY,1,0);
      ObjectSetInteger(0,ExtName_OBJ+"_BuyX_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_BuyX_0",OBJPROP_BGCOLOR,clrBlack);
     }
//---

   if(ObjectGetInteger(0,ExtName_OBJ+"_SellX_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_SellX_0",OBJPROP_BGCOLOR,clrWhite);
      Order_CloseAll(OP_SELL,1,0);
      ObjectSetInteger(0,ExtName_OBJ+"_SellX_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_SellX_0",OBJPROP_BGCOLOR,clrBlack);
     }
//---
   if(ObjectGetInteger(0,ExtName_OBJ+"_HegeX_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_HegeX_0",OBJPROP_BGCOLOR,clrWhite);
      Order_CloseAll(-1,1,0);
      ObjectSetInteger(0,ExtName_OBJ+"_HegeX_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_HegeX_0",OBJPROP_BGCOLOR,clrBlack);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ObjectGetInteger(0,ExtName_OBJ+"_BuyX2_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_BuyX2_0",OBJPROP_BGCOLOR,clrWhite);
      Order_CloseAll(OP_BUY,0,0);
      ObjectSetInteger(0,ExtName_OBJ+"_BuyX2_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_BuyX2_0",OBJPROP_BGCOLOR,clrBlack);
     }
//---

   if(ObjectGetInteger(0,ExtName_OBJ+"_SellX2_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_SellX2_0",OBJPROP_BGCOLOR,clrWhite);
      Order_CloseAll(OP_SELL,0,0);
      ObjectSetInteger(0,ExtName_OBJ+"_SellX2_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_SellX2_0",OBJPROP_BGCOLOR,clrBlack);
     }
//---
   if(ObjectGetInteger(0,ExtName_OBJ+"_HegeX2_0",OBJPROP_STATE))
     {
      ObjectSetInteger(0,ExtName_OBJ+"_HegeX2_0",OBJPROP_BGCOLOR,clrWhite);
      Order_CloseAll(-1,0,0);
      ObjectSetInteger(0,ExtName_OBJ+"_HegeX2_0",OBJPROP_STATE,false);
     }
   else
     {
      ObjectSetInteger(0,ExtName_OBJ+"_HegeX2_0",OBJPROP_BGCOLOR,clrBlack);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   int PostX=PostX_DefDashboard;
   int PostY=PostY_DefDashboard;
   PostY+=YStep;

   setLabel(ExtName_OBJ+"_TXD11_0","Price","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD12_0","TP","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD13_0","SL","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD14_0","Lot","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD15_0","Point","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD16_0","NAV.","",clrWhite,PostX,PostY); PostX+=XStep+20;

   setLabel(ExtName_OBJ+"_TXD21_0","Price","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD22_0","TP","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD23_0","SL","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD24_0","Lot","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD25_0","Point","",clrWhite,PostX,PostY); PostX+=XStep;
   setLabel(ExtName_OBJ+"_TXD26_0","NAV.","",clrWhite,PostX,PostY); PostX+=XStep;
//ObjectsDeleteAll(0,ExtName_OBJ+"OP",0,OBJ_BUTTON);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   double Product_Buy=0,Weight_Buy=0,Nav_Buy=0,Nav_BuyALL=0,CNT_Buy=0;
   double Product_Sell=0,Weight_Sell=0,Nav_Sell=0,Nav_SellALL=0,CNT_Sell=0;
   double Product_Hege=0,Weight_Hege=0,Nav_Hege=0,Nav_HegeALL=0,CNT_Hege=0;

   int PostY_Buy=PostY,PostY_Sell=PostY;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      //if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()!=Symbol()) continue;

      color clrType=clrWhite;
      color clrTP=clrWhite,clrSL=clrWhite;
      double PriceCurrent=0;
      if(OrderType()==OP_SELL)
        {
         clrType=clrRed;
         PostX=PostX_Default+470;
         PostY_Buy+=YStep;
         PostY=PostY_Buy;

         PriceCurrent=(OrderOpenPrice()-Ask)/Point;

         clrTP=(MathAbs(Ask-OrderTakeProfit())<=(100*Point))?clrLime:clrWhite;
         clrSL=(MathAbs(Ask-OrderStopLoss())<=(100*Point))?clrRed:clrWhite;

         Product_Sell+=OrderOpenPrice()*OrderLots();
         Weight_Sell+=OrderLots();

         if(OrderProfit()>=0)
            Nav_Sell+=OrderProfit();
         Nav_SellALL+=OrderProfit();

         CNT_Sell++;
        }
      else if(OrderType()==OP_BUY)
        {
         clrType=clrDodgerBlue;
         PostX=PostX_Default;
         PostY_Sell+=YStep;
         PostY=PostY_Sell;

         PriceCurrent=(Bid-OrderOpenPrice())/Point;

         clrTP=(MathAbs(Bid-OrderTakeProfit())<=(100*Point))?clrLime:clrWhite;
         clrSL=(MathAbs(Bid-OrderStopLoss())<=(100*Point))?clrRed:clrWhite;

         Product_Buy+=OrderOpenPrice()*OrderLots();
         Weight_Buy+=OrderLots();

         if(OrderProfit()>=0)
            Nav_Buy+=OrderProfit();
         Nav_BuyALL+=OrderProfit();

         CNT_Buy++;
        }

      setLabel(ExtName_OBJ+"_OP_"+c(OrderTicket(),0),c(OrderOpenPrice(),Digits),c(OrderTicket(),0),clrType,PostX,PostY);

      PostX+=XStep;

      _EditCreate(ExtName_OBJ+"_TP_"+c(OrderTicket(),0),windex,c(OrderTakeProfit(),Digits)
                  ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                  ,clrTP,Chart_BG,clrLime,false,false,false,0);
      PostX+=XStep;
      _EditCreate(ExtName_OBJ+"_SL_"+c(OrderTicket(),0),windex,c(OrderStopLoss(),Digits)
                  ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                  ,clrSL,Chart_BG,clrRed,false,false,false,0);
      PostX+=XStep;
      _EditCreate(ExtName_OBJ+"_LOT_"+c(OrderTicket(),0),windex,c(OrderLots(),2)
                  ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                  ,clrWhite,Chart_BG,clrSilver,false,false,false,0);

      PostX+=XStep;
      setBUTTON(ExtName_OBJ+"_Point_"+c(OrderTicket(),0),windex,CORNER_LEFT_UPPER,
                Size_Wide,Size_High+2,PostX,PostY,false,11,clrNumber(PriceCurrent),clrBlack,clrDimGray,
                c(PriceCurrent,0));

      PostX+=XStep;
      setBUTTON(ExtName_OBJ+"_NAV_"+c(OrderTicket(),0),windex,CORNER_LEFT_UPPER,
                Size_Wide,Size_High+2,PostX,PostY,false,11,clrNumber(OrderProfit()),clrBlack,clrDimGray,
                c(OrderProfit(),2));
      PostX+=XStep;

      //---
      bool btnPoint=ObjectGetInteger(0,ExtName_OBJ+"_Point_"+c(OrderTicket(),0),OBJPROP_STATE);
      bool btnNAv=ObjectGetInteger(0,ExtName_OBJ+"_NAV_"+c(OrderTicket(),0),OBJPROP_STATE);

      if(btnPoint || btnNAv)
        {
         bool cx;
         string str=ObjectGetString(0,ExtName_OBJ+"_LOT_"+c(OrderTicket(),0),OBJPROP_TEXT,0);
         cx=OrderClose(OrderTicket(),double(str),Bid,10);

         if(cx)
           {
            ObjectDelete(0,ExtName_OBJ+"_OP_"+c(OrderTicket(),0));
            ObjectDelete(0,ExtName_OBJ+"_TP_"+c(OrderTicket(),0));
            ObjectDelete(0,ExtName_OBJ+"_SL_"+c(OrderTicket(),0));
            ObjectDelete(0,ExtName_OBJ+"_LOT_"+c(OrderTicket(),0));
            ObjectDelete(0,ExtName_OBJ+"_Point_"+c(OrderTicket(),0));
            ObjectDelete(0,ExtName_OBJ+"_NAV_"+c(OrderTicket(),0));
           }
        }
      string str=ObjectGetString(0,ExtName_OBJ+"_TP_"+c(OrderTicket(),0),OBJPROP_TEXT,0);
      if(double(str)!=OrderTakeProfit())
        {
         bool mo=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),double(str),0);
        }
      str=ObjectGetString(0,ExtName_OBJ+"_SL_"+c(OrderTicket(),0),OBJPROP_TEXT,0);
      if(double(str)!=OrderStopLoss())
        {
         bool mo=OrderModify(OrderTicket(),OrderOpenPrice(),double(str),OrderTakeProfit(),0);
        }
     }
//+------------------------------------------------------------------+
   if(Weight_Buy>0)
     {
      Product_Buy=Product_Buy/Weight_Buy;
     }
   if(Weight_Sell>0)
     {
      Product_Sell=Product_Sell/Weight_Sell;
     }
//---
   Product_Hege=CoverPrice(Product_Buy,Weight_Buy,Product_Sell,Weight_Sell);
   Weight_Hege=Weight_Buy-Weight_Sell;
   Nav_Hege=Nav_Buy+Nav_Sell;
   Nav_HegeALL=Nav_BuyALL+Nav_SellALL;
   CNT_Hege=CNT_Buy+CNT_Sell;
//
   double Point_Buy=(Product_Buy>0)?(Bid-Product_Buy)/Point:0;
   double Point_Sell=(Product_Sell>0)?(Product_Sell-Ask)/Point:0;
   double Point_Hege=(Product_Hege>0)?(Product_Hege-Bid)/Point:0;

//---
   string strcnt=(CNT_Buy>0)?"["+c(CNT_Buy,0)+"]":"";
   ObjectSetText(ExtName_OBJ+"_TX22_0",c(Product_Buy,Digits),10,"Arial",clrNumber(Nav_BuyALL));
   ObjectSetText(ExtName_OBJ+"_TX23_0",c(Weight_Buy,2)+strcnt,10,"Arial",clrNumber(Nav_BuyALL));
   ObjectSetText(ExtName_OBJ+"_TX24_0",c(Point_Buy,0),10,"Arial",clrNumber(Nav_BuyALL));
   ObjectSetString(0,ExtName_OBJ+"_BuyX_0",OBJPROP_TEXT,c(Nav_Buy,2));
   ObjectSetString(0,ExtName_OBJ+"_BuyX2_0",OBJPROP_TEXT,c(Nav_BuyALL,2));
   ObjectSetInteger(0,ExtName_OBJ+"_BuyX_0",OBJPROP_COLOR,clrNumber(Nav_Buy));
   ObjectSetInteger(0,ExtName_OBJ+"_BuyX2_0",OBJPROP_COLOR,clrNumber(Nav_BuyALL));

   strcnt=(CNT_Sell>0)?"["+c(CNT_Sell,0)+"]":"";
   ObjectSetText(ExtName_OBJ+"_TX32_0",c(Product_Sell,Digits),10,"Arial",clrNumber(Nav_SellALL));
   ObjectSetText(ExtName_OBJ+"_TX33_0",c(Weight_Sell,2)+strcnt,10,"Arial",clrNumber(Nav_SellALL));
   ObjectSetText(ExtName_OBJ+"_TX34_0",c(Point_Sell,0),10,"Arial",clrNumber(Nav_SellALL));
   ObjectSetString(0,ExtName_OBJ+"_SellX_0",OBJPROP_TEXT,c(Nav_Sell,2));
   ObjectSetString(0,ExtName_OBJ+"_SellX2_0",OBJPROP_TEXT,c(Nav_SellALL,2));
   ObjectSetInteger(0,ExtName_OBJ+"_SellX_0",OBJPROP_COLOR,clrNumber(Nav_Sell));
   ObjectSetInteger(0,ExtName_OBJ+"_SellX2_0",OBJPROP_COLOR,clrNumber(Nav_SellALL));

   strcnt=(CNT_Hege>0)?"["+c(CNT_Hege,0)+"]":"";
   ObjectSetText(ExtName_OBJ+"_TX42_0",c(Product_Hege,Digits),10,"Arial",clrNumber(Product_Hege));
   ObjectSetText(ExtName_OBJ+"_TX43_0",c(Weight_Hege,2)+strcnt,10,"Arial",clrLots(Weight_Hege));
   ObjectSetText(ExtName_OBJ+"_TX44_0",c(Point_Hege,0),10,"Arial",clrNumber(Point_Hege));
   ObjectSetString(0,ExtName_OBJ+"_HegeX_0",OBJPROP_TEXT,c(Nav_Hege,2));
   ObjectSetString(0,ExtName_OBJ+"_HegeX2_0",OBJPROP_TEXT,c(Nav_HegeALL,2));
   ObjectSetInteger(0,ExtName_OBJ+"_HegeX_0",OBJPROP_COLOR,clrNumber(Nav_Hege));
   ObjectSetInteger(0,ExtName_OBJ+"_HegeX2_0",OBJPROP_COLOR,clrNumber(Nav_HegeALL));

   if(Product_Buy>0)
     {
      HLineCreate(0,"Product_Buy","",0,Product_Buy,
                  clrRoyalBlue,0,1,false,true,false,false,0);
     }
   else
      ObjectDelete(0,"Product_Buy");

   if(Product_Sell>0)
     {
      HLineCreate(0,"Product_Sell","",0,Product_Sell,
                  clrRed,0,1,false,true,false,false,0);
     }
   else
      ObjectDelete(0,"Product_Sell");

   if(Product_Hege>0)
     {
      HLineCreate(0,"Product_Hege","",0,Product_Hege,
                  clrGold,0,1,false,true,false,false,0);
     }
   else
      ObjectDelete(0,"Product_Hege");

//+------------------------------------------------------------------+

   string name;
   string sep="_",result[];
   ushort  u_sep=StringGetCharacter(sep,0);

   int ObjTotal=ObjectsTotal();
   for(int i=0;i<ObjTotal;i++)
     {
      name=ObjectName(i);
      if(ObjectGetInteger(0,name,OBJPROP_TYPE,0)==OBJ_BUTTON)
        {
         int k=StringSplit(name,u_sep,result);
         //if(result[1]=="OP")
           {
            int iTICKET=StrToInteger(result[2]);
            string TICKET=string(iTICKET);
            bool z=OrderSelect(iTICKET,SELECT_BY_TICKET,MODE_TRADES);

            //printf(name+" | "+ArraySize(result)+"n | "+result[2]+" Select "+z);

            if(OrderCloseTime()>0 || !z)
              {
               ObjectDelete(0,ExtName_OBJ+"_OP_"+TICKET);
               ObjectDelete(0,ExtName_OBJ+"_TP_"+TICKET);
               ObjectDelete(0,ExtName_OBJ+"_SL_"+TICKET);
               ObjectDelete(0,ExtName_OBJ+"_LOT_"+TICKET);
               ObjectDelete(0,ExtName_OBJ+"_Point_"+TICKET);
               ObjectDelete(0,ExtName_OBJ+"_NAV_"+TICKET);
              }
           }
        }
     }

/*for(int pos=0;pos<ArraySize(DUMP_TICKET);pos++)
     {
      if(DUMP_TICKET[pos]>0)
        {
         _setBUTTON(ExtName_OBJ+"_OP_"+DUMP_TICKET[pos],windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrLime,OrderTicket()+" "+OrderProfit());PostY+=YStep;
        }
     }*/

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double nd(double in)
  {
   return(NormalizeDouble(in,Digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectCreText(string name,int PostX,int PostY)
  {
//name=ExtName_OBJ+name;
   if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
     {
      ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
      ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,true);
     }
   ObjectSet(name,OBJPROP_XDISTANCE,PostX);
   ObjectSet(name,OBJPROP_YDISTANCE,PostY);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBUTTON(string name,
               int panel,
               ENUM_BASE_CORNER CORNER,
               int XSIZE,int YSIZE,
               int XDIS,int YDIS,
               bool Bold,int FONTSIZE,color COLOR,color BG,color BBG,
               string TextStr
               )
  {
//---
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(0,name,OBJ_BUTTON,panel,0,0);

     }
//---
   ObjectSetInteger(0,name,OBJPROP_XSIZE,XSIZE);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,YSIZE);

   ObjectSet(name,OBJPROP_XDISTANCE,XDIS);
   ObjectSet(name,OBJPROP_YDISTANCE,YDIS);

   ObjectSetString(0,name,OBJPROP_FONT,(Bold)?"Arial Black":"Arial");

   ObjectSetString(0,name,OBJPROP_TEXT,TextStr);
   ObjectSetInteger(0,name,OBJPROP_COLOR,COLOR);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,BBG);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setLabel(string Name,string Text,string Tooltip,color clr,int PostX,int PostY)
  {
//ExtName_OBJ+"Head_1",
   ObjectCreText(Name,PostX,PostY);
   ObjectSetText(Name,Text,10,"Arial",clr);
   if(Tooltip!="")
     {
      ObjectSetString(0,Name,OBJPROP_TOOLTIP,Tooltip);
     }

   ObjectSet(Name,OBJPROP_XDISTANCE,PostX);
   ObjectSet(Name,OBJPROP_YDISTANCE,PostY);

   ObjectSetInteger(0,Name,OBJPROP_BACK,true);

//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _EditCreate(const string           name="Edit",// object name 
                 const int              sub_window=0,             // subwindow index 
                 const string           text="Text",              // text 
                 const bool             reDraw=false,// ability to edit 
                 const bool             read_only=false,          // ability to edit 
                 const int              x=0,                      // X coordinate 
                 const int              y=0,                      // Y coordinate 
                 const int              width=50,                 // width 
                 const int              height=18,                // height 
                 const string           font="Arial",             // font 
                 const int              font_size=10,             // font size 
                 const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type 
                 const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const color            clr=clrBlack,             // text color 
                 const color            back_clr=clrWhite,        // background color 
                 const color            border_clr=clrNONE,       // border color 
                 const bool             back=false,               // in the background 
                 const bool             selection=false,          // highlight to move 
                 const bool             hidden=true,              // hidden in the object list 
                 const long             z_order=0)                // priority for mouse click 
  {
   long  chart_ID=0;
//--- reset the error value 
   ResetLastError();
//--- create edit field 
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      //return(false);
     }
   else
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
   if(reDraw)
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
//--- set object coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text 

//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode 
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _EditMove(const long   chart_ID=0,// chart's ID 
               const string name="Edit", // object name 
               const int    x=0,         // X coordinate 
               const int    y=0)         // Y coordinate 
  {
//--- reset the error value 
   ResetLastError();
//--- move the object 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the object! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrNumber(double v)
  {
   if(v>0)
      return clrDodgerBlue;
   if(v<0)
      return clrRed;
   return clrGray;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrLots(double v)
  {
   if(v>0)
      return clrDodgerBlue;
   if(v<0)
      return clrRed;
   return clrGold;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CoverPrice(double RP_Buy,double Ratio_Buy,
                  double RP_Sell,double Ratio_Sell)
  {
   double Product_Cover=0,Ratio_Cover=-1;
   if(RP_Buy>0 && RP_Sell>0)
     {
      double Space=MathAbs(RP_Buy-RP_Sell);
      if(Ratio_Buy>Ratio_Sell)
        {

         Ratio_Cover=NormalizeDouble(Ratio_Sell/(Ratio_Buy-Ratio_Sell),4);
         Product_Cover=NormalizeDouble(Space*Ratio_Cover,Digits);

         Product_Cover=RP_Buy+Product_Cover;
        }
      if(Ratio_Buy<Ratio_Sell)
        {
         Ratio_Cover=NormalizeDouble(Ratio_Buy/(Ratio_Buy-Ratio_Sell),4);
         Product_Cover=NormalizeDouble(Space*Ratio_Cover,Digits);

         Product_Cover=RP_Sell+Product_Cover;
        }

     }
   return Product_Cover;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll(int OP_DIR,int mode,int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderMagicNumber()!=Magic) continue;
      //      
      if(((OP_DIR>=0) && OrderType()==OP_DIR) || (OP_DIR<0))
        {
         if(((mode==1) && OrderProfit()>=0) || (mode==0))
            ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(ORDER_TICKET_CLOSE);i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
            if(GetLastError()==0){ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;}
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }
//+------------------------------------------------------------------+
