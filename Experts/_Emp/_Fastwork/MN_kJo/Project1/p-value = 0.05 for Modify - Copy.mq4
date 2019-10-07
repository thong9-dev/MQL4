//+------------------------------------------------------------------+
//|                                                     IdealTrader  |
//|                  Copyright IdealTrader MetaQuotes Software Corp. |
//|                                       IdealTrader_EA@outlook.com |
//+------------------------------------------------------------------+
//---
//01/09/2019      01-08
//02/09/2019      03.5
//---
#property copyright "Copyright IdealTrader, MetaQuotes Software Corp."
#property link      "www.IdealTrader_EA.com"
#property version   "1.1"
#property strict
#property description "Account : 2019.09.07 23:59" 
#property description "Exp : 2019.09.07 23:59" 
//############################################################################
int      EA_Account  =-1;                             //-1 = UsedAllUser
datetime EA_Expire   =D'2019.09.07 23:59';            //D'2019.09.07 23:59' | -1 = UsedAllTime
int      EA_DayAlert =10;
//+--#########################################################################
enum ENUM_MODE_MagicMN
  {
   MN_FIX   =1,   // Fix Number on Symbol
   MN_ALL   =2    // All Number on Symbol
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_LOT
  {
   LOT_Static  =1,   // Static
   LOT_Dynamic =2    // Dynamic
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string objEA="MB2@";
//#include "MN.mqh"
string EA_HaderName="MB II :: Fully AutoTrade";
//---
extern int                     Magicnumber=5555;
extern ENUM_MODE_MagicMN       exMagic_Mode=MN_FIX;   //Calculate mode
int _Magic2=-1;
extern string                  exLine0=" ------------------------------------- ";// ----------

extern ENUM_MODE_LOT           exLot_Mode    =LOT_Static;   //Calculate mode
extern double                  exLotStart    = 0.01;        //LotStart
extern double                  Multiply      = 1.50;        //Use for Static : Multiply
extern double                  exLot_C       = 0.33;        //Use for Dynamic : C [-1 to 1 Only]
double ex2Lot_C=-1;

extern string                  exLine1=" ------------------------------------- ";// ----------

extern int                     exSlipepage   =5;
extern int                     exSpreadLimit =30;
extern string                  exLine2=" ------------------------------------- ";// ----------

extern double                  exProfit=1.00;
extern int                     exMaxOrders    = 33;
extern int                     exSteps        = 500;
extern string                  exLine3=" ------------------------------------- ";// ----------

extern int                     exPeriodMAFast=3;
extern ENUM_APPLIED_PRICE      exPriceFast   =0;
extern ENUM_MA_METHOD          exMethodFast  =1;
extern string                  exLine4=" ------------------------------------- ";// ----------

extern int                     exPeriodMASlow   =15;
extern ENUM_APPLIED_PRICE      exPriceSlow      =0;
extern ENUM_MA_METHOD          exMethodSlow     =1;
extern string                  exLine5=" ------------------------------------- ";// ----------

extern string                  _Comments="p-value < 0.05";

//---
bool UseMartingale=true;
int ticket;
static int BARS;
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
int OnInit()
  {
   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);

   ObjectsDeleteAll();

   if(exMagic_Mode==MN_ALL)
      _Magic2=Magicnumber*-1;
   else
      _Magic2=Magicnumber;
//---
   if((exLot_C<-1 || exLot_C>1) && (exLot_Mode==LOT_Dynamic))
     {
      int  MSG=MessageBox("Static C is -1.00 Between 1.00 and 2 Digits\n "+DoubleToStr(exLot_C,2),"Static C Error @ "+EA_HaderName,MB_OK);
      ex2Lot_C=-2;
     }
   else
     {
      ex2Lot_C=NormalizeDouble(exLot_C,2);
     }

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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double vMA_Fast_1,vMA_Fast_2;
double vMA_Slow_1,vMA_Slow_2;
//---
int Active=-1,ActiveBuy=-1,ActiveSell=-1;
double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
double Active_Lot=0,ActiveBuy_Lot=0,ActiveSell_Lot=0;
double Active_Swap,_ActiveComm;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(EA_Expired())
     {
      if((ex2Lot_C!=-2 && exLot_Mode==LOT_Dynamic) || (exLot_Mode==LOT_Static))
        {
         int Pending=-1,PendingBuy=-1,PendingSell=-1;
         // 
         int cntAll=getCntOrder(_Magic2,Symbol(),
                                Active,ActiveBuy,ActiveSell,
                                Pending,PendingBuy,PendingSell,
                                Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                                Active_Lot,ActiveBuy_Lot,ActiveSell_Lot,
                                Active_Swap,_ActiveComm);
         //---

         if(IsNewBar())
           {

            vMA_Fast_1   = iMA(Symbol(),0,exPeriodMAFast,0,exMethodFast,exPriceFast,1);
            vMA_Fast_2   = iMA(Symbol(),0,exPeriodMAFast,0,exMethodFast,exPriceFast,2);

            vMA_Slow_1   = iMA(Symbol(),0,exPeriodMASlow,0,exMethodSlow,exPriceSlow,1);
            vMA_Slow_2   = iMA(Symbol(),0,exPeriodMASlow,0,exMethodSlow,exPriceSlow,2);

            if(MarketInfo(Symbol(),MODE_SPREAD)<=exSpreadLimit)
              {
               //--- Start cycle
               if(vMA_Fast_1>=vMA_Slow_1 && vMA_Fast_2<vMA_Slow_2) //Fast cross up
                 {
                  if(ActiveBuy==0)
                     ticket=OrderSend(Symbol(),OP_BUY,exLotStart,Ask,exSlipepage,0,0,_Comments,_Magic2,0,clrBlue);
                  if(ActiveSell==0)
                     ticket=OrderSend(Symbol(),OP_SELL,exLotStart,Bid,exSlipepage,0,0,_Comments,_Magic2,0,clrRed);
                 }

               if(vMA_Fast_1<=vMA_Slow_1 && vMA_Fast_2>vMA_Slow_2) //Fast cross down
                 {
                  if(ActiveBuy==0)
                     ticket=OrderSend(Symbol(),OP_BUY,exLotStart,Ask,exSlipepage,0,0,_Comments,_Magic2,0,clrBlue);
                  if(ActiveSell==0)
                     ticket=OrderSend(Symbol(),OP_SELL,exLotStart,Bid,exSlipepage,0,0,_Comments,_Magic2,0,clrRed);
                 }

               //--- Cnt > 0
               if(UseMartingale==true)
                 {
                  double LastOrderPrice_Buy=LastOrderPrice(OP_BUY,_Magic2);

                  if(ActiveBuy>=1 && ActiveBuy<exMaxOrders && 
                     Ask<(LastOrderPrice_Buy-(exSteps*Point)) && 
                     vMA_Fast_1>=vMA_Slow_1 && vMA_Fast_2<vMA_Slow_2) //Fast cross up
                    {
                     ticket=OrderSend(Symbol(),OP_BUY,Order_LotsMultiply(ActiveBuy,LastOrderPrice_Buy,Ask),Ask,exSlipepage,0,0,_Comments,_Magic2,0,clrBlue);
                    }
                  //--------------------------------------------------------------------------------
                  double LastOrderPrice_Sell=LastOrderPrice(OP_SELL,_Magic2);

                  if(ActiveSell>=1 && ActiveSell<exMaxOrders && 
                     Bid>(LastOrderPrice_Sell+(exSteps*Point)) && 
                     vMA_Fast_1<=vMA_Slow_1 && vMA_Fast_2>vMA_Slow_2)//Fast cross down
                    {
                     ticket=OrderSend(Symbol(),OP_SELL,Order_LotsMultiply(ActiveSell,LastOrderPrice_Sell,Bid),Bid,exSlipepage,0,0,_Comments,_Magic2,0,clrRed);
                    }
                 }
               //---
              }
           }

         if(ActiveBuy_Hold>=exProfit && ActiveSell_Hold>=exProfit)
           {
            Order_CloseAll_Active();
           }
         ShowDataPanel();
        }
      else
        {
         string objEA_=objEA+"EAname";

         ObjectCreate(objEA_,OBJ_LABEL,0,0,0);
         ObjectSetText(objEA_,"Static C is -1.00 Between 1.00 and 2 Digits "+DoubleToStr(exLot_C,2),20,"Verdana Bold",clrWhiteSmoke);
         ObjectSet(objEA_,OBJPROP_CORNER,0);
         ObjectSet(objEA_,OBJPROP_XDISTANCE,(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)/2)-225);
         ObjectSet(objEA_,OBJPROP_YDISTANCE,(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0)/2)-50);
        }
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

         int  MSG=MessageBox("Order_CloseAll : MagicNumber "+MagicmodeToString(_Magic2),"CloseAll @ "+EA_HaderName,MB_YESNO|MB_ICONQUESTION);
         if(MSG==IDYES)
           {
            Order_CloseAll_Active();
           }

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll_Active()
  {
   bool HaveOrders=false;
   do
     {
      HaveOrders=false;
      for(int i=0;i<=OrdersTotal();i++)
        {
         if(
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && 
            OrderSymbol()==Symbol() && 
            OrderType()<=OP_SELL && 
            ((_Magic2==exLot_Mode && OrderMagicNumber()==_Magic2)||
            (_Magic2!=exLot_Mode))
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
double Order_LotsMultiply(int CNT,
                          double Dy_Last,double Dy_Now)
  {
//int exMode=1;
   double lot=-1;
   if(exLot_Mode==LOT_Static)
     {
      lot=NormalizeDouble(exLotStart*MathPow(Multiply,CNT),2);
     }
   if(exLot_Mode==LOT_Dynamic)
     {
      lot=NormalizeDouble(MathAbs(Dy_Last-Dy_Now),Digits);
      lot=((lot/(exSteps*Point))+ex2Lot_C)*exLotStart;
      lot=NormalizeDouble(lot,2);
     }
   Print(__FUNCTION__+"|"+LotmodeToString()+"|"+DoubleToStr(lot,2));
   return lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastOrderPrice(int _type,int iMN)
  {
   double _price=-1;

   if(_type==OP_BUY)
     {
      _price=9999999;
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && 
            ((iMN==exLot_Mode && OrderMagicNumber()==iMN)||
            (iMN!=exLot_Mode))
            )
           {
            if(OrderOpenPrice()<_price)
              {
               _price=OrderOpenPrice();
              }
           }
        }
     }

   if(_type==OP_SELL)
     {
      _price=0;
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && 
            ((iMN==exLot_Mode && OrderMagicNumber()==iMN)||
            (iMN!=exLot_Mode))
            )
           {
            if(OrderOpenPrice()>_price)
              {
               _price=OrderOpenPrice();
              }
           }
        }
     }

   return NormalizeDouble(_price,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string LotmodeToString()
  {
   if(exLot_Mode==LOT_Static)    return "Static";
   if(exLot_Mode==LOT_Dynamic)   return "Dynamic";
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MagicmodeToString(int nm)
  {
   if(exMagic_Mode==MN_FIX)  return "Fix Number ["+string(nm)+"]";
   if(exMagic_Mode==MN_ALL)  return "All Number";
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowDataPanel()
  {

   int xx=210;
   int yy=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)-195;
   int xx_step=15;

   string objEA_=objEA+"BG";
   ObjectCreate(0,objEA_,OBJ_RECTANGLE_LABEL,0,0,0,0);
   ObjectSetInteger(0,objEA_,OBJPROP_BGCOLOR,clrBlack);
   ObjectSetInteger(0,objEA_,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,objEA_,OBJPROP_YDISTANCE,25);
   ObjectSetInteger(0,objEA_,OBJPROP_XSIZE,192);
   ObjectSetInteger(0,objEA_,OBJPROP_ZORDER,0);
   ObjectSetInteger(0,objEA_,OBJPROP_YSIZE,300);
   ObjectSetInteger(0,objEA_,OBJPROP_CORNER,1);
//----------------------------------------------------------------------------------------------
   xx=35;
//---
   objLabel("EAname",yy,xx,"Verdana Bold",8,clrWhiteSmoke,EA_HaderName);
//----------------------------------------------------------------------------------------------

   objLabel("Info@1",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            AccountServer());

   objLabel("Info@2",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            "Magic :: "+MagicmodeToString(_Magic2));

   objLabel("Info@3",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Lots :: "+DoubleToString(exLotStart,2)+" | Mode :: "+LotmodeToString());

   objLabel("Info@32",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Multiply :: "+DoubleToString(Multiply,2)+" | C :: "+DoubleToStr(exLot_C,2));

   objLabel("Info@41",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Steps :: "+IntegerToString(exSteps)+" | MaxOrders :: "+string(exMaxOrders));

   objLabel("Info@4",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            "Equity :: "+DoubleToStr(AccountEquity(),2)+" | "+DoubleToStr(AccountEquity()/AccountBalance(),2)+"%");

   objLabel("Info@5",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Free Margin :: "+DoubleToStr(AccountFreeMargin(),2));

   objLabel("Line@1",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "--------------------------------");
//----------------------------------------------------------------------------------------------
//double varNum,cnt,Swap,Comm;
//---
//OrderInfo_OP(OP_BUY,varNum,cnt);
   objLabel("Finance@11",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Profit Buy("+string(ActiveBuy)+")   :: ");
//
   objLabel("Finance@12",yy+110,xx,"Verdana",7,clrNumberValue(ActiveBuy_Hold),
            DoubleToStr(ActiveBuy_Hold,2));
//----------------------------------------------------------------------------------------------
//OrderInfo_OP(OP_SELL,varNum,cnt);
   objLabel("Finance@21",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Profit Sell("+string(ActiveSell)+")   :: ");
//
   objLabel("Finance@22",yy+110,xx,"Verdana",7,clrNumberValue(ActiveSell_Hold),
            DoubleToStr(ActiveSell_Hold,2));
//----------------------------------------------------------------------------------------------
//OrderInfo_All(varNum,cnt,Swap,Comm);
//---
   objLabel("Finance@31",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Profit ("+string(Active)+")         :: ");
//
   objLabel("Finance@32",yy+110,xx,"Verdana",7,clrNumberValue(Active_Hold),
            DoubleToStr(Active_Hold,2));
//----------------------------------------------------------------------------------------------
   objLabel("Finance@41",yy,xx+=xx_step,"Verdana",7,clrNumberValue(Active_Swap),
            "Sum Swap                :: "+DoubleToStr(Active_Swap,2));
//----------------------------------------------------------------------------------------------
   objLabel("Finance@51",yy,xx+=xx_step,"Verdana",7,clrNumberValue(_ActiveComm),
            "Sum Commission    :: "+DoubleToStr(_ActiveComm,2));
//----------------------------------------------------------------------------------------------
   objLabel("Line@02",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "--------------------------------");
//----------------------------------------------------------------------------------------------
   objEA_=objEA+"CloseAll";
   ObjectCreate(0,objEA_,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,objEA_,OBJPROP_CORNER,0);
   ObjectSetInteger(0,objEA_,OBJPROP_XDISTANCE,yy);
   ObjectSetInteger(0,objEA_,OBJPROP_YDISTANCE,xx+=xx_step);
   ObjectSetInteger(0,objEA_,OBJPROP_XSIZE,160);
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
            "--------------------------------");
//----------------------------------------------------------------------------------------------

   ChartRedraw();
   WindowRedraw();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EA_Expired()
  {
   bool chkEXP=false;
   bool chkAcc=true,chkTime=true;

   if(EA_Account!=-1)
      chkAcc=(EA_Account==AccountNumber());
   if(EA_Expire!=-1)
      chkTime=(EA_Expire>=TimeLocal());

//chkEXP=(EA_Account==AccountNumber()) && (EA_Expire>=TimeLocal());

   EA_ExpiredAlert();
   return (chkAcc && chkTime)?true:false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  EA_TimeAlertNext=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EA_ExpiredAlert()
  {

   if(EA_Expire!=-1)
     {
      int DayUnit=46400;
      int DayAlert=DayUnit*EA_DayAlert;         //Alert Ramian

      int Diff=int(EA_Expire-TimeLocal());

      if(Diff<DayAlert && !EA_TimeAlertNext)
        {
         if(SendNotification(
            EA_HaderName+
            "\n Account: "+string(EA_Account)+
            "\n Expire: "+TimeToString(EA_Expire,TIME_DATE|TIME_MINUTES)
            ))
           {
            EA_TimeAlertNext=true;
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getCntOrder(int iMN,string iOrderSymbol,
                int &aActive,int &aActiveBuy,int &aActiveSell,
                int &Pending,int &PendingBuy,int &PendingSell,
                double &aActive_Hold,double &aActiveBuy_Hold,double &aActiveSell_Hold,
                double &aActive_Lot,double &aActiveBuy_Lot,double &aActiveSell_Lot,
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

   Pending=0;
   PendingBuy=0;
   PendingSell=0;

   aSwap=0;
   aComm=0;
//
   int cntOP_BUY=0;
   int cntOP_SELL=0;
   int cntOP_BUYLIMIT=0;
   int cntOP_SELLLIMIT=0;
   int cntOP_BUYSTOP=0;
   int cntOP_SELLSTOP=0;
//
   for(int icnt=0;icnt<OrdersTotal();icnt++) // for loop
     {
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(r && 
         OrderSymbol()==iOrderSymbol && 
         ((iMN==exLot_Mode && OrderMagicNumber()==iMN)||
         (iMN!=exLot_Mode))
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

         if(Type==OP_BUY){          cntOP_BUY++;   aActiveBuy_Hold+=Hold;  aActiveBuy_Lot+=Lot;}
         if(Type==OP_SELL){         cntOP_SELL++;  aActiveSell_Hold+=Hold; aActiveSell_Lot+=Lot;}
         //if(Type==OP_BUYLIMIT)      cntOP_BUYLIMIT++;
         //if(Type==OP_SELLLIMIT)     cntOP_SELLLIMIT++;
         //if(Type==OP_BUYSTOP)       cntOP_BUYSTOP++;
         //if(Type==OP_SELLSTOP)      cntOP_SELLSTOP++;

         aComm+=OrderCommission();
         aSwap+=OrderSwap();
        }
     }
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
   return clrRed;
  }
//+------------------------------------------------------------------+
