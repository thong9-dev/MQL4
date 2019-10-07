//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Golden Master TH."
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.5"
#property strict
//#property description "Exp : 2019.09.08 23:59"
//############################################################################
int      EA_Account=-1;                             //-1 = UsedAllUser
//---
//datetime EA_Expire=D'2019.09.29 23:59';            //D'2019.09.07 23:59' | -1 = UsedAllTime
datetime EA_Expire=-1;            //D'2019.09.07 23:59' | -1 = UsedAllTime
int      EA_DayAlert=1;
//---
bool     EA_TestingAllow=true;
//+--#########################################################################
int EA_AccountDev=51659093;
//+--#########################################################################
enum ENUM_MODE_MagicMN
  {
   MN_FIX   =1,   // Fix Number on Symbol
   MN_ALL   =2    // All Number on Symbol
  };
//+------------------------------------------------------------------+
enum ENUM_MODE_LOT
  {
   LOT_Static  =1,   // Static
   LOT_Dynamic =2    // Dynamic
  };
//+------------------------------------------------------------------+
string objEA="MB2@";
bool ExtHide_OBJ=AccountNumber()!=EA_AccountDev;

string EA_HaderName  ="Follower :: Fully AutoTrade";
//---
extern int                    exMagicnumber     =  6666;          //Magicnumber
extern ENUM_MODE_MagicMN      exMagic_Mode      =  MN_FIX;         //Calculate mode
extern string                 exLine00=" ------------------------------------- ";// ----------

extern double                 exLotStart        =  0.01;        //LotStart
extern double                 exPointPending    =  150;        //PointPending
double eaPointPending=NormalizeDouble(exPointPending/MathPow(10,Digits),Digits);

extern string                  exLine1=" ------------------------------------- ";// ----------
int                    exSlipepage       =  100;            //Slipepage
extern string                 exLine2=" ------------------------------------- ";// ----------
extern int                    exProfitsPoint    =  100;          //ProfitsPoint (Point)

extern double                 exTimeClose       =  2.00;         //Profits Time (Minute)
int    eaTimeClose =-1;
extern int                    exMaxOrders       =  33;      //MaxOrders
extern string                 exLine3=" ------------------------------------- ";// ----------

extern string                 exComments        ="";                //Comments Order
extern string              exLine4=" ------------------------------ ";   // # ---------- Bollinger Bands ----------
extern ENUM_TIMEFRAMES     BB_TF       =PERIOD_CURRENT;
extern int                 BB_Period   =4;
extern double              BB_Deviatio =2;
extern ENUM_APPLIED_PRICE  BB_AP       =PRICE_CLOSE;
//---
double mkSTOPLEVEL=NormalizeDouble(MarketInfo(Symbol(),MODE_STOPLEVEL)/MathPow(10,Digits),Digits);
//---

int ticket;
static int BARS;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

//---
   EA_ExpiredAlert(false);
//---
   eaTimeClose=MinuteToSec(exTimeClose);
//---
//double _Active_Lot=0.01;
//double ProfitsFromula=(MathAbs(_Active_Lot)*100*MarketInfo(Symbol(),MODE_SPREAD))+;
//printf("MODE_SPREAD::"+MarketInfo(Symbol(),MODE_SPREAD));
//printf("ProfitsFromula::"+ProfitsFromula);
//---

   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);

   ObjectsDeleteAll();
//---
   OnTick();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(!(IsTesting()||AccountNumber()==EA_AccountDev))
     {
      ObjectsDeleteAll();
     }

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double Price_Origin=-1;
double Price_Buy=-1;
double Price_Sel=-1;
double ProfitsFromula=-1;
//---
int Active=-1,ActiveBuy=-1,ActiveSell=-1;
int Pending=-1,PendingBuy=-1,PendingSell=-1;
double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
double Active_Lot=0,ActiveBuy_Lot=0,ActiveSell_Lot=0;
double Active_LotMax=0,ActiveBuy_LotMax=0,ActiveSell_LotMax=0;
double Active_Swap=0,_ActiveComm=0;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool Status_Defen=false;
void OnTick()
  {
   if(EA_Expired())
     {
      if(Active_Lot!=0)
        {
         ProfitsFromula=(MathAbs(Active_Lot/Active)*exProfitsPoint*MarketInfo(Symbol(),MODE_SPREAD))+(MathAbs(Active_Swap)+MathAbs(_ActiveComm));
         ProfitsFromula=ProfitsFromula/Active;

         bool A=Active_Hold>=ProfitsFromula;
         bool Z=A;

         if(Z)
           {
            int MODE=(Active_Lot>0)?OP_BUY:OP_SELL;

            if(LastOrderTimeHold_Limit(MODE)!=Active_Lot!=0)
              {
               //Print("Order_CloseAll_Active ["+DoubleToStr(exProfit,2)+"] "+DoubleToStr(ActiveBuy_Hold,2)+"Buy | "+DoubleToStr(ActiveSell_Hold,2)+"Sell ");
               Order_CloseAll_Active();
               Order_CloseAll_Pending();
               Price_Origin=-1;
              }

           }
        }
      //---
      int cntAll=getOrderInfo(Active,ActiveBuy,ActiveSell,
                              Pending,PendingBuy,PendingSell,
                              Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                              Active_Lot,ActiveBuy_Lot,ActiveSell_Lot,
                              Active_LotMax,ActiveBuy_LotMax,ActiveSell_LotMax,
                              Active_Swap,_ActiveComm);
      //---
      ShowDataPanel();
      //---
      if(Active==0)
        {
         //PRINT(__LINE__,"On_IsNewBar","");
         // if(/*MarketInfo(Symbol(),MODE_SPREAD)<=exSpreadLimit &&*/ ActiveBuy==0 && ActiveSell==0)
           {
            if(Price_Origin==-1)
              {
/*
               double _Origin=-1;
               //double Index=(Ask+Bid)/2;
               Signal_BB(Price_Buy,_Origin,Price_Sel);

               double UP =Price_Buy-mkSTOPLEVEL;
               double DW =Price_Sel+mkSTOPLEVEL;
               double XX = NormalizeDouble((UP-DW)*0.25,Digits);
               UP-=XX;
               DW+=XX;

               if(UP>Ask&&Bid>DW)
                 {
                  Price_Origin=_Origin;
                 }
               //---
*/
               Price_Origin=(Ask+Bid)/2;
               Price_Buy=NormalizeDouble(Price_Origin+eaPointPending,Digits);
               Price_Sel=NormalizeDouble(Price_Origin-eaPointPending,Digits);
               //---
               Price_Origin=NormalizeDouble(Price_Origin,Digits);
               Price_Buy=NormalizeDouble(Price_Buy,Digits);
               Price_Sel=NormalizeDouble(Price_Sel,Digits);

               HLineCreate(0,"D_Origin",0,Price_Origin,clrYellow,STYLE_SOLID,1,true,false,0);
               HLineCreate(0,"D_Buy",0,Price_Buy,clrRoyalBlue,STYLE_SOLID,1,false,false,0);
               HLineCreate(0,"D_Sell",0,Price_Sel,clrTomato,STYLE_SOLID,1,false,false,0);
              }
           }
        }
      //---
      if(Price_Origin!=-1)
        {
         if(Pending==0)
           {
            if(Active==0)
              {
               ticket=OrderSend(Symbol(),OP_BUYSTOP,exLotStart,Price_Buy,exSlipepage,0,0,exComments,exMagicnumber,0);
               if(ticket>0)
                 {
                  ticket=OrderSend(Symbol(),OP_SELLSTOP,exLotStart,Price_Sel,exSlipepage,0,0,exComments,exMagicnumber,0);
                 }
               if(ticket>0)
                 {
                  Status_Defen=true;
                 }

              }
            else
              {
               Order_Reserve();
              }
           }
         else
           {
            //Pending!=0
            //---
            if(Status_Defen)
              {
               if(Active==1)
                 {
                  Status_Defen=false;
                  //---
                  Order_CloseAll_Pending();
                  Order_Reserve();
                 }
              }
           }
        }
      //---

     }
   else
     {
      string objEA_=objEA+"EAname";

      ObjectCreate(objEA_,OBJ_LABEL,0,0,0);
      ObjectSetText(objEA_,"Please Contact :: IdealTrader_EA@outlook.com",20,"Verdana Bold",clrWhiteSmoke);
      ObjectSet(objEA_,OBJPROP_CORNER,0);
      ObjectSet(objEA_,OBJPROP_XDISTANCE,(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)/2)-225);
      ObjectSet(objEA_,OBJPROP_YDISTANCE,(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0)/2)-50);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTick();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_Reserve()
  {
   if(ActiveBuy_Lot>ActiveSell_Lot)
     {
      ticket=OrderSend(Symbol(),OP_SELLSTOP,Order_Lots(Active),Price_Sel,exSlipepage,0,0,exComments,exMagicnumber,0,clrBlue);

     }
   if(ActiveBuy_Lot<ActiveSell_Lot)
     {
      ticket=OrderSend(Symbol(),OP_BUYSTOP,Order_Lots(Active),Price_Buy,exSlipepage,0,0,exComments,exMagicnumber,0,clrBlue);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DrawComment_ShowMN=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam==objEA+"CloseAll")
        {
         Print(objEA+"Close All!");

         int  MSG=MessageBox("Order_CloseAll : MagicNumber "+MagicmodeToString(exMagicnumber),"CloseAll @ "+EA_HaderName,MB_YESNO|MB_ICONQUESTION);
         if(MSG==IDYES)
           {
            Order_CloseAll_Active();
           }
        }
     }

//---

   if(id==CHARTEVENT_KEYDOWN)
     {
      printf("CHARTEVENT_KEYDOWN: "+string(lparam));
      if(!IsTesting())
        {
         //ConsoleWrite(string(lparam));
         if(lparam==9)
           {
            DrawComment_ShowMN=(DrawComment_ShowMN)?false:true;
            FIX_Magicnumber(DrawComment_ShowMN);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   if(BARS!=Bars(_Symbol,_Period))
     {
      BARS=Bars(_Symbol,_Period);
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll_Active2()
  {
   bool HaveOrders=false;
   do
     {
      HaveOrders=false;
      for(int i=0; i<=OrdersTotal(); i++)
        {
         if(
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES) &&
            OrderSymbol()==Symbol() &&
            OrderType()<=OP_SELL &&
            ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
             (exMagic_Mode==MN_ALL))
         )
           {
            HaveOrders=true;
            int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),3,clrNONE);
           }
        }
     }
   while(HaveOrders==true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll_Active()
  {
   int ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)) &&
         (OrderSymbol()==Symbol()) &&
         OrderType()<=OP_SELL &&
         ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
          (exMagic_Mode==MN_ALL)))
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
     }
//+---------------------------------------------------------------------+
   for(int i=0; i<ArraySize(ORDER_TICKET_CLOSE); i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET))
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),100);
            if(GetLastError()==0)
              {
               ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;
              }
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll_Pending()
  {
   int ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)) &&
         (OrderSymbol()==Symbol()) &&
         OrderType()>OP_SELL &&
         ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
          (exMagic_Mode==MN_ALL)))
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
     }
//+---------------------------------------------------------------------+
   for(int i=0; i<ArraySize(ORDER_TICKET_CLOSE); i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET))
           {
            bool z=OrderDelete(ORDER_TICKET_CLOSE[i]);
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order_Lots(int CNT)
  {
   double _lot=exLotStart*2;
//double _lot=exLotStart*MathPow(2,CNT);

   Print(__FUNCTION__+"|Raw :: "+string(_lot));

   string result[],R;
   StringSplit(string(_lot),StringGetCharacter(".",0),result);
   R=result[0]+"."+StringSubstr(result[1],0,2);
   double lot=double(R);

   return lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastOrderPrice(int _type)
  {
   double _price=(_type==OP_SELL)?9999999:0;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)&&
         OrderSymbol()==Symbol() &&
         OrderType()==_type &&
         ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
          (exMagic_Mode==MN_ALL))
        )
        {
         if((_type==OP_BUY &&OrderOpenPrice()>_price)||
            (_type==OP_SELL&&OrderOpenPrice()<_price))
           {
            _price=OrderOpenPrice();
           }
        }
     }

   return NormalizeDouble(_price,Digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LastOrder(int _type)
  {
   double _price=(_type==OP_SELL)?9999999:0;
   int T=-1;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)&&
         OrderSymbol()==Symbol() &&
         OrderType()==_type &&
         ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
          (exMagic_Mode==MN_ALL))
        )
        {
         if((_type==OP_BUY &&OrderOpenPrice()>_price)||
            (_type==OP_SELL&&OrderOpenPrice()<_price))
           {
            _price=OrderOpenPrice();
            T=OrderTicket();
           }
        }
     }

   return T;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MagicmodeToString(int nm)
  {
   if(exMagic_Mode==MN_FIX)
      return "Fix Number ["+string(nm)+"]";
   if(exMagic_Mode==MN_ALL)
      return "All Number in "+Symbol();
   return "-";
  }
void ShowDataComm()
  {
   if(IsTesting()||AccountNumber()==EA_AccountDev)
     {
      string strDate;
      datetime Date;
      //---
      string CMM="";
      CMM+="\n"+"ACCOUNT_BALANCE : "+DoubleToStr(AccountInfoDouble(ACCOUNT_BALANCE),2);
      CMM+="\n"+"Price_Origin : "+Price_Origin;
      CMM+="\n"+"Status_Defen : "+Status_Defen;

      CMM+="\n ---";

      CMM+="\n"+"eaTimeClose : "+string(eaTimeClose)+"s";
      LastOrderTimeHold(OP_BUY,ticket,Date,strDate);
      CMM+="\n"+"LastOrderTimeHold B : ["+string(ticket)+"] "+string(Date)+" | "+strDate+"s | "+string(LastOrderTimeHold_Limit(OP_BUY));
      LastOrderTimeHold(OP_SELL,ticket,Date,strDate);
      CMM+="\n"+"LastOrderTimeHold S : ["+string(ticket)+"] "+string(Date)+" | "+strDate+"s | "+string(LastOrderTimeHold_Limit(OP_SELL));
      CMM+="\n ---";
      Comment(CMM);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowDataPanel()
  {
   ShowDataComm();

   int xx=250;
   int yy=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)-235;
   int xx_step=15;

   string objEA_=objEA+"BG";
   ObjectCreate(0,objEA_,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(0,objEA_,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,objEA_,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,objEA_,OBJPROP_YDISTANCE,20);
   ObjectSetInteger(0,objEA_,OBJPROP_XSIZE,230);
   ObjectSetInteger(0,objEA_,OBJPROP_YSIZE,355);
   ObjectSetInteger(0,objEA_,OBJPROP_ZORDER,0);

   ObjectSetInteger(0,objEA_,OBJPROP_CORNER,1);
//----------------------------------------------------------------------------------------------
   xx=35;
//---
   objLabel("EAname",yy,xx,"Verdana Bold",8,clrWhiteSmoke,EA_HaderName);
//----------------------------------------------------------------------------------------------   Info

   objLabel("Info@1",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            AccountServer()+" | Leverage :: 1:"+string(AccountLeverage()));

   objLabel("Info@2",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            "Magic :: "+MagicmodeToString(exMagicnumber));

   string strInfo32;
   objLabel("Info@3",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Lots ::  "+DoubleToString(exLotStart,2)+"  |  Mode :: XXXX");

   objLabel("Info@32",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            strInfo32);

   objLabel("Info@41",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "LotMax :: "+DoubleToStr(Active_LotMax,2));

   objLabel("Info@4",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            "Equity :: "+DoubleToStr(AccountEquity(),2)+"  |  "+DoubleToStr(AccountEquity()/AccountBalance(),2)+"%");

   objLabel("Info@5",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Free Margin :: "+DoubleToStr(AccountFreeMargin(),2));

   objLabel("Line@1",yy,xx+=xx_step-3,"Verdana",7,clrWhiteSmoke,
            "-----------------------------------------");

//----------------------------------------------------------------------------------------------   Time
   color clrOrderHoldTime=clrMagenta;
   string strOrderHoldTime;
//---

   objLabel("OrderHoldTime@10",yy,xx+=xx_step-3,"Verdana",7,clrWhiteSmoke,
            "Buy::");

   strOrderHoldTime=Panel_strOrderHoldTime(OP_BUY,clrOrderHoldTime);

   objEdit("OrderHoldTime@11",0,strOrderHoldTime
           ,false,true,205,xx-3,180,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrOrderHoldTime,clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("OrderHoldTime@20",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sell::");

   strOrderHoldTime=Panel_strOrderHoldTime(OP_SELL,clrOrderHoldTime);

   objEdit("OrderHoldTime@21",0,strOrderHoldTime
           ,false,true,205,xx-3,180,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrOrderHoldTime,clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------   Finance
   objLabel("Finance@11",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            "Sum Profit Buy("+string(ActiveBuy)+") ::");


   objEdit("Lot@11",0,DoubleToStr(ActiveBuy_Lot,2)
           ,false,true,145,xx-3,50,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrWhiteSmoke/*clrNumberValue(ActiveBuy_Lot,OP_BUY)*/,clrBlack,clrBlack,false,false,false,0);

   objEdit("Finance@E12",0,DoubleToStr(ActiveBuy_Hold,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(ActiveBuy_Hold),clrBlack,clrBlack,false,false,false,0);

//----------------------------------------------------------------------------------------------
   objLabel("Finance@21",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Profit Sell("+string(ActiveSell)+") ::");

   objEdit("Lot@21",0,DoubleToStr(ActiveSell_Lot,2)
           ,false,true,145,xx-3,50,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrWhiteSmoke/*clrNumberValue(ActiveSell_Lot,OP_SELL)*/,clrBlack,clrBlack,false,false,false,0);

   objEdit("Finance@E22",0,DoubleToStr(ActiveSell_Hold,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(ActiveSell_Hold),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("Finance@31",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            "Sum Profit ("+string(Active)+")       ::");

   objEdit("Lot@31",0,DoubleToStr(Active_Lot,2)
           ,false,true,145,xx-3,50,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(Active_Lot),clrBlack,clrBlack,false,false,false,0);
   double SumProfit=(ActiveBuy_Hold+ActiveSell_Hold)-(Active_Swap+_ActiveComm);
   objEdit("Finance@E32",0,DoubleToStr(SumProfit,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(SumProfit),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("Finance@41",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Swap             ::");

   objEdit("Finance@E42",0,DoubleToStr(Active_Swap,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(Active_Swap),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("Finance@51",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Commission ::");

   objEdit("Finance@E52",0,DoubleToStr(_ActiveComm,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(_ActiveComm),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("Finance@61",yy,xx+=xx_step+5,"Verdana",10,clrNumberValue_NetPrfits(Active_Hold),
            "Net Profit ["+ProfitsFromula+"]::");

   objEdit("Finance@E61",0,DoubleToStr(Active_Hold,2)
           ,false,true,95,xx-3,70,22,"Verdana",10,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(Active_Hold),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("Line@02",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "-----------------------------------------");
//----------------------------------------------------------------------------------------------
   objEA_=objEA+"CloseAll";
   ObjectCreate(0,objEA_,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,objEA_,OBJPROP_CORNER,0);
   ObjectSetInteger(0,objEA_,OBJPROP_XDISTANCE,yy);
   ObjectSetInteger(0,objEA_,OBJPROP_YDISTANCE,xx+=xx_step);
   ObjectSetInteger(0,objEA_,OBJPROP_XSIZE,205);
   ObjectSetInteger(0,objEA_,OBJPROP_YSIZE,30);
   ObjectSetString(0,objEA_,OBJPROP_TEXT," Close All ! ");

   ObjectSetInteger(0,objEA_,OBJPROP_COLOR,White);
   ObjectSetInteger(0,objEA_,OBJPROP_BGCOLOR,Red);
   ObjectSetInteger(0,objEA_,OBJPROP_BORDER_COLOR,clrWhiteSmoke);

   ObjectSetInteger(0,objEA_,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,objEA_,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,objEA_,OBJPROP_STATE,false);
   ObjectSetInteger(0,objEA_,OBJPROP_FONTSIZE,10);
//----------------------------------------------------------------------------------------------
   objLabel("Line@03",yy,xx+=30,"Verdana",7,clrWhiteSmoke,
            "-----------------------------------------");
//----------------------------------------------------------------------------------------------

   ChartRedraw();
   WindowRedraw();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EA_Expired()
  {
   if(IsOptimization() || IsTesting())
      return EA_TestingAllow;

//---
   bool chkAcc=true,chkTime=true;

   if(EA_Account!=-1)
      chkAcc=(EA_Account==AccountNumber());
   if(EA_Expire!=-1)
      chkTime=(EA_Expire>=TimeCurrent());

//---
   EA_ExpiredAlert(true);
   return (chkAcc && chkTime)?true:false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  EA_TimeAlertNext=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EA_ExpiredAlert(bool event)
  {

   if(EA_Expire!=-1)
     {
      //datetime DayUnit=datetime(D'2019.09.02 23:59')-datetime(D'2019.09.01 23:59');
      datetime DayAlert=86400*EA_DayAlert;         //Alert Ramian

      datetime Diff=datetime(EA_Expire)-TimeCurrent();

      if((Diff<DayAlert && !EA_TimeAlertNext) || !event)
        {

         string msg=EA_HaderName+
                    EA_AccountStr()+
                    "\n Expire: "+TimeToString(EA_Expire,TIME_DATE|TIME_MINUTES)+
                    "\n Remain: "+EA_Remain(Diff);
         printf("Remain: "+string(event)+" "+EA_Remain(Diff));

         if(SendNotification(msg) && event)
           {
            if(event)
               EA_TimeAlertNext=true;
           }
         if(!event)
           {
            //Alert(msg);
            int  MSG=MessageBox(msg,"RemianExp @ "+EA_HaderName,MB_OK);
           }

        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string EA_AccountStr()
  {
   if(EA_Account!=-1)
      return "\n Account: "+string(EA_Account);
   return "\n Account: All Trader";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string EA_Remain(datetime DIFF)
  {
   double N=double((DIFF)/86400);

   int _Year=int(N/365);
   double _Month=MathMod(N,365)/30.4167;
   int _Day=int(MathMod(_Month,1)*30.4167);
   _Month=int(_Month);

   string str="";
   if(_Year!=0)
      str+=string(_Year)+" Year ";
   if(_Month!=0)
      str+=string(_Month)+" Month ";
   if(_Day!=0)
      str+=string(_Day)+" Day ";
   str+=TimeToString(DIFF,TIME_MINUTES);

//   printf("N # "+string(N));
//   printf("_Year # "+(_Year));
//   printf("_Month # "+(_Month));
//   printf("_Day # "+(_Day));
//
//   printf("str # "+str);

   return str;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getOrderInfo(int &aActive,int &aActiveBuy,int &aActiveSell,
                 int &aPending,int &aPendingBuy,int &aPendingSell,
                 double &aActive_Hold,double &aActiveBuy_Hold,double &aActiveSell_Hold,
                 double &aActive_Lot,double &aActiveBuy_Lot,double &aActiveSell_Lot,
                 double &aActive_LotMax,double &aActiveBuy_LotMax,double &aActiveSell_LotMax,
                 double &aSwap,double &aComm)

  {
   aActive_Hold=0;
   aActiveBuy_Hold=0;
   aActiveSell_Hold=0;

   aActive_Lot=0;
   aActiveBuy_Lot=0;
   aActiveSell_Lot=0;

   aActive=0;
   aActiveBuy=0;
   aActiveSell=0;

   aPending=0;
   aPendingBuy=0;
   aPendingSell=0;

   aSwap=0;
   aComm=0;

   aActiveBuy_LotMax=0;
   aActiveSell_LotMax=0;
//
   int cntOP_BUY=0;
   int cntOP_SELL=0;
   int cntOP_BUYLIMIT=0;
   int cntOP_SELLLIMIT=0;
   int cntOP_BUYSTOP=0;
   int cntOP_SELLSTOP=0;
//
   for(int icnt=0; icnt<OrdersTotal(); icnt++) // for loop
     {
      bool r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(r &&
         OrderSymbol()==Symbol() &&
         ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
          (exMagic_Mode==MN_ALL))
        )
        {
         int Type=OrderType();
         if(Type<=1)
            aActive++;
         else
            Pending++;
         //
         double Hold=OrderProfit()+OrderSwap()+OrderCommission();
         double Lot=OrderLots();

         if(Type==OP_BUY)
           {
            cntOP_BUY++;
            aActiveBuy_Hold+=Hold;
            aActiveBuy_Lot+=Lot;
            if(aActiveBuy_LotMax<OrderLots())
              {
               aActiveBuy_LotMax=OrderLots();
              }
           }

         if(Type==OP_SELL)
           {
            cntOP_SELL++;
            aActiveSell_Hold+=Hold;
            aActiveSell_Lot+=Lot;

            if(aActiveSell_LotMax<OrderLots())
              {
               aActiveSell_LotMax=OrderLots();
              }
           }

         //if(Type==OP_BUYLIMIT)      cntOP_BUYLIMIT++;
         //if(Type==OP_SELLLIMIT)     cntOP_SELLLIMIT++;
         //if(Type==OP_BUYSTOP)       cntOP_BUYSTOP++;
         //if(Type==OP_SELLSTOP)      cntOP_SELLSTOP++;

         aComm+=OrderCommission();
         aSwap+=OrderSwap();
        }
     }
//---

   aActive_LotMax=(aActiveBuy_LotMax>aActiveSell_LotMax)?aActiveBuy_LotMax:aActiveSell_LotMax;
//---

   aActive_Hold=aActiveBuy_Hold+aActiveSell_Hold;

   aActive_Lot=aActiveBuy_Lot-aActiveSell_Lot;
//
   aActiveBuy=cntOP_BUY;
   aActiveSell=cntOP_SELL;
//PendingBuy=cntOP_BUYLIMIT+cntOP_BUYSTOP;
//PendingSell=cntOP_SELLLIMIT+cntOP_SELLSTOP;
//
   Active_Hold=NormalizeDouble(Active_Hold,2);
   ActiveBuy_Hold=NormalizeDouble(ActiveBuy_Hold,2);
   ActiveSell_Hold=NormalizeDouble(ActiveSell_Hold,2);
//
   return Active+Pending;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objLabel(string name,int _yy,int _xx,string font,int size,color clr,string Text)
  {
   name=objEA+name;

   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSetText(name,Text,size,font,clr);
   ObjectSet(name,OBJPROP_CORNER,0);
   ObjectSet(name,OBJPROP_XDISTANCE,_yy);
   ObjectSet(name,OBJPROP_YDISTANCE,_xx);
   ObjectSet(name,OBJPROP_HIDDEN,ExtHide_OBJ);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrNumberValue(double v)
  {

//color _pfb=16119285;
   if(v==0)
      return clrWhiteSmoke;
   if(v>0)
      return clrDodgerBlue;
   return clrTomato;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrNumberValue(double v,int mode)
  {

//color _pfb=16119285;
   if(v==0)
      return clrWhiteSmoke;
   if(v>0)
      return (mode==OP_BUY)?clrDodgerBlue:clrTomato;
   return clrMagenta;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrNumberValue_NetPrfits(double v)
  {

   if(v>=ProfitsFromula&&ProfitsFromula!=-1)
      return clrYellow;
   return clrWhiteSmoke;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool objEdit(string           name="Edit",// object name
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
   name=objEA+name;
//--- reset the error value
   ResetLastError();
//--- create edit field
   if(ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
   else
     {

     }
//if()
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,ExtHide_OBJ);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FIX_Magicnumber(bool s)
  {
   if(s)
     {
      printf("s");
      //string str=string(exMagicnumber)+" : "+string(_Magic);
      string str=MagicmodeToString(exMagicnumber);

      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS)
            && OrderSymbol()==Symbol() &&
            ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
             (exMagic_Mode==MN_ALL))
           )
           {
            str+="\n"+string(OrderTicket())+"t |  "+OP_OrderToString(OrderType())+" "+DoubleToStr(OrderLots(),2)+" | "+string(OrderMagicNumber())+"mn | "+OrderComment();
           }
        }

      Comment(str);
     }
   else
     {
      Comment("");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OP_OrderToString(int v)
  {
   if(v==OP_BUY)
      return "BUY";
   if(v==OP_SELL)
      return "SEL";
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void PRINT(int from,string header,string body)
//  {
//   printf("#"+string(from)+" | "+header+" :: "+body);
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MinuteToSec(double Set)
  {
   string result[];
   double Raw=0;
   if(StringSplit(DoubleToStr(Set,2),StringGetCharacter(".",0),result)>1)
      Raw=double(result[1])/60;
   return int((double(result[0])+Raw)*60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LastOrderTimeHold_Limit(int MODE)
  {

   string strDate;
   datetime Date;
   int _ticket=-1;

   if(LastOrderTimeHold(MODE,ticket,Date,strDate)>eaTimeClose)
      return true;
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LastOrderTimeHold(int MODE,int &_ticket,datetime &date,string &strDate)
  {
   _ticket=LastOrder(MODE);
   if(OrderSelect(_ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      date=OrderOpenTime();
      int i=int(TimeCurrent()-date);
      strDate="";
      if(i>3600)
         strDate+=NumberZeroSec(int(i/3600))+":";
      strDate+=NumberZeroSec(MathMod(int(i/60),60))+":"+NumberZeroSec(MathMod(i,60));

      return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Panel_strOrderHoldTime(int MODE,color &clrOrderHoldTime)
  {
   string strDate;
   datetime Date;
   int _ticket;
   int var=LastOrderTimeHold(MODE,_ticket,Date,strDate);

   if(var>eaTimeClose)
      clrOrderHoldTime=clrGold;
   else
      clrOrderHoldTime=clrWhiteSmoke;

   if(var==-1)
      return "-";
   return string(Date)+" | "+strDate+"s |";//+string(_ticket);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string NumberZeroSec(double v)
  {
   string r;
   if(v<=9)
      r+="0";
   return r+=string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      ObjectMove(chart_ID,name,0,0,price);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
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
void Signal_BB(double &varBands_UP,double &varBands_MM,double &varBands_DW)
  {
//---
   varBands_UP=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_UPPER,0);
   varBands_MM=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_MAIN,0);
   varBands_DW=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_LOWER,0);
//
//varBands_DIFFMM=MathAbs(varBands_MM-varBands_UP);
//
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Signal_BB_Rang()
  {
//---
   double varBands_UP=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_UPPER,0);
   double varBands_MM=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_MAIN,0);
//varBands_DW=iBands(NULL,BB_TF,BB_Period,BB_Deviatio,0,BB_AP,MODE_LOWER,0);
//
   return MathAbs(varBands_MM-varBands_UP)*MathPow(10,Digits);
//
  }
//+------------------------------------------------------------------+
