//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright IdealTrader, MetaQuotes Software Corp."
#property link      "www.IdealTrader_EA.com"
#property version   "1.57"
#property strict
#property description "Account : ALL for Develoer"
#property description "Exp : 2019.09.08 23:59"
//############################################################################
int      EA_Account=-1;                             //-1 = UsedAllUser
//---
datetime EA_Expire=-1;            //D'2019.09.07 23:59' | -1 = UsedAllTime
int      EA_DayAlert=10;
//---
bool     EA_TestingAllow=true;
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
bool ExtHide_OBJ=false;

string EA_HaderName="MB II :: Fully AutoTrade";
//---
extern int                     exMagicnumber=5555;
extern ENUM_MODE_MagicMN       exMagic_Mode=MN_FIX;   //Calculate mode
int _Magic=-1;
extern string                  exLine0=" ------------------------------------- ";// ----------

extern ENUM_MODE_LOT           exLot_Mode    =LOT_Static;   //Calculate mode
extern double                  exLotStart    = 0.01;        //LotStart
extern double                  Multiply      = 1.08;        //Use for Static : Multiply
extern double                  exLot_C       = 0.33;        //Use for Dynamic : C [-1 to 1 Only]
double ex2Lot_C=-1;

extern string                  exLine1=" ------------------------------------- ";// ----------

extern int                     exSlipepage   =5;
extern int                     exSpreadLimit =33;
extern string                  exLine2=" ------------------------------------- ";// ----------

extern double                  exProfit=0.01;
extern int                     exMaxOrders    = 33;
extern int                     exSteps        = 333;
extern string                  exLine3=" ------------------------------------- ";// ----------

extern int                     exPeriodMAFast=3;
extern ENUM_APPLIED_PRICE      exPriceFast   =PRICE_CLOSE;
extern ENUM_MA_METHOD          exMethodFast  =MODE_EMA;
extern string                  exLine4=" ------------------------------------- ";// ----------

extern int                     exPeriodMASlow   =15;
extern ENUM_APPLIED_PRICE      exPriceSlow      =PRICE_CLOSE;
extern ENUM_MA_METHOD          exMethodSlow     =MODE_EMA;
extern string                  exLine5=" ------------------------------------- ";// ----------

extern string                  _Comments="p-value < 0.05";

//---
bool UseMartingale=true;
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

   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);

   ObjectsDeleteAll();

   if(exMagic_Mode==MN_ALL)
      _Magic=exMagicnumber*-1;
   else
      _Magic=exMagicnumber;

//---

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
   ObjectsDeleteAll();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double vMA_Fast_1,vMA_Fast_2;
double vMA_Slow_1,vMA_Slow_2;
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
void OnTick()
  {
   if(EA_Expired())
     {
      if((ex2Lot_C!=-2 && exLot_Mode==LOT_Dynamic) || (exLot_Mode==LOT_Static))
        {

         int cntAll=getOrderInfo(_Magic,Symbol(),
                                 Active,ActiveBuy,ActiveSell,
                                 Pending,PendingBuy,PendingSell,
                                 Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                                 Active_Lot,ActiveBuy_Lot,ActiveSell_Lot,
                                 Active_LotMax,ActiveBuy_LotMax,ActiveSell_LotMax,
                                 Active_Swap,_ActiveComm);
         //---
         if(ActiveBuy_Hold>=exProfit && ActiveSell_Hold>=exProfit)
           {
            Print("Order_CloseAll_Active ["+DoubleToStr(exProfit,2)+"] "+DoubleToStr(ActiveBuy_Hold,2)+"Buy | "+DoubleToStr(ActiveSell_Hold,2)+"Sell ");
            Order_CloseAll_Active();

           }
         //---

         if(IsNewBar()&&(ActiveBuy==0&&ActiveSell==0))
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
                  ticket=OrderSend(Symbol(),OP_BUY,exLotStart,Ask,exSlipepage,0,0,_Comments,exMagicnumber,0,clrBlue);
                  ticket=OrderSend(Symbol(),OP_SELL,exLotStart,Bid,exSlipepage,0,0,_Comments,exMagicnumber,0,clrRed);
                 }

               if(vMA_Fast_1<=vMA_Slow_1 && vMA_Fast_2>vMA_Slow_2) //Fast cross down
                 {
                  ticket=OrderSend(Symbol(),OP_BUY,exLotStart,Ask,exSlipepage,0,0,_Comments,exMagicnumber,0,clrBlue);
                  ticket=OrderSend(Symbol(),OP_SELL,exLotStart,Bid,exSlipepage,0,0,_Comments,exMagicnumber,0,clrRed);
                 }
              }

           }

         //--- Cnt > 0
         if(UseMartingale==true)
           {
            double LastOrderPrice_Buy=LastOrderPrice(OP_BUY,_Magic);

            if(ActiveBuy>=1 && ActiveBuy<exMaxOrders &&
               Ask<(LastOrderPrice_Buy-(exSteps*Point)) &&
               vMA_Fast_1>=vMA_Slow_1 && vMA_Fast_2<vMA_Slow_2) //Fast cross up
              {
               ticket=OrderSend(Symbol(),OP_BUY,Order_LotsMultiply(ActiveBuy,LastOrderPrice_Buy,Ask),Ask,exSlipepage,0,0,_Comments,exMagicnumber,0,clrBlue);
              }
            //--------------------------------------------------------------------------------
            double LastOrderPrice_Sell=LastOrderPrice(OP_SELL,_Magic);

            if(ActiveSell>=1 && ActiveSell<exMaxOrders &&
               Bid>(LastOrderPrice_Sell+(exSteps*Point)) &&
               vMA_Fast_1<=vMA_Slow_1 && vMA_Fast_2>vMA_Slow_2)//Fast cross down
              {
               ticket=OrderSend(Symbol(),OP_SELL,Order_LotsMultiply(ActiveSell,LastOrderPrice_Sell,Bid),Bid,exSlipepage,0,0,_Comments,exMagicnumber,0,clrRed);
              }
           }
         //---

         //---


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

         int  MSG=MessageBox("Order_CloseAll : MagicNumber "+MagicmodeToString(_Magic),"CloseAll @ "+EA_HaderName,MB_YESNO|MB_ICONQUESTION);
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
void Order_CloseAll_Active()
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
double Order_LotsMultiply(int CNT,
                          double Dy_Last,double Dy_Now)
  {
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
            ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
             (exMagic_Mode==MN_ALL))
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
            ((exMagic_Mode==MN_FIX && OrderMagicNumber()==exMagicnumber) ||
             (exMagic_Mode==MN_ALL))
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
string LotmodeToString()
  {
   if(exLot_Mode==LOT_Static)
      return "Static";
   if(exLot_Mode==LOT_Dynamic)
      return "Dynamic";
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MagicmodeToString(int nm)
  {
   if(exMagic_Mode==MN_FIX)
      return "Fix Number ["+string(nm)+"]";
   if(exMagic_Mode==MN_ALL)
      return "All Number";
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
            "Magic :: "+MagicmodeToString(_Magic));

   objLabel("Info@3",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Lots :: "+DoubleToString(exLotStart,2)+" | Mode :: "+LotmodeToString());

   objLabel("Info@32",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Multiply :: "+DoubleToString(Multiply,2)+" | C :: "+DoubleToStr(exLot_C,2));

   objLabel("Info@41",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Steps :: "+IntegerToString(exSteps)+" | LotMax :: "+DoubleToStr(Active_LotMax,2));

   objLabel("Info@4",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
            "Equity :: "+DoubleToStr(AccountEquity(),2)+" | "+DoubleToStr(AccountEquity()/AccountBalance(),2)+"%");

   objLabel("Info@5",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Free Margin :: "+DoubleToStr(AccountFreeMargin(),2));

   objLabel("Line@1",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "--------------------------------");
//----------------------------------------------------------------------------------------------
   objLabel("Finance@11",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Profit Buy("+string(ActiveBuy)+") ::");
//
//objLabel("Finance@12",yy+110,xx,"Verdana",7,clrNumberValue(ActiveBuy_Hold),
//         DoubleToStr(ActiveBuy_Hold,2));

   objEdit("Finance@E12",0,DoubleToStr(ActiveBuy_Hold,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(ActiveBuy_Hold),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
//OrderInfo_OP(OP_SELL,varNum,cnt);
   objLabel("Finance@21",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Profit Sell("+string(ActiveSell)+") ::");

   objEdit("Finance@E22",0,DoubleToStr(ActiveSell_Hold,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(ActiveSell_Hold),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("Finance@31",yy,xx+=xx_step,"Verdana",7,clrWhiteSmoke,
            "Sum Profit ("+string(Active)+")       ::");

   objEdit("Finance@E32",0,DoubleToStr(Active_Hold,2)
           ,false,true,95,xx-3,70,15,"Verdana",7,ALIGN_RIGHT,CORNER_RIGHT_UPPER
           ,clrNumberValue(Active_Hold),clrBlack,clrBlack,false,false,false,0);
//----------------------------------------------------------------------------------------------
   objLabel("Finance@41",yy,xx+=xx_step+5,"Verdana",7,clrWhiteSmoke,
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
int getOrderInfo(int iMN,string iOrderSymbol,
                 int &aActive,int &aActiveBuy,int &aActiveSell,
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(r &&
         OrderSymbol()==iOrderSymbol &&
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

   aActive_LotMax=(cntOP_BUY>cntOP_SELL)?aActiveBuy_LotMax:aActiveSell_LotMax;
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
   return clrTomato;
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
