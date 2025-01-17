//|                                                 Amata_Mirror.mq4 |
//|                          Copyright 04-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |

#property copyright "Copyright 04-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.91"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_HoldingCut_MODE
  {
   ENUM_HoldingCut_MODE1=1,//MODE 1 : Close Totals and yourself.
   ENUM_HoldingCut_MODE2=2//MODE 2 : Close only the total.
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_OrderDIR_MODE
  {
   ENUM_OrderDIR_SELL=1,//MODE 1 : SELL Only.
   ENUM_OrderDIR_BUYY=2,//MODE 2 : BUY Only.
   ENUM_OrderDIR_2WAY=3//MODE 3 : 2 Way.
  };
string eaName_Hader     ="N&P Tron";
string eaName_TageOrder ="NP@";
string eaName_Ver="1.91e v";
bool eaHidenObj=true;
bool eaDevelop =true;

//bool LockSentOrder=false;
extern int eaMagicNumber=0;

extern string Ext1="-------- Strategy --------";//*********************
extern ENUM_OrderDIR_MODE AllowDIR=ENUM_OrderDIR_2WAY;
extern bool exLastloop=true;    //Lastloop
extern int  exLimitSPREAD=10;    //LimitSPREAD (where strat loop)

extern string  Ext2="-------- Sell Series Control --------";//*********************
extern double  LotS_Sell=0.01;//Lot Start
extern double  LotsLv_Sell       =1.5;//Lot Level
extern int     PointStep_Sell    =250;//Point Start
extern double  PointStepLv_Sell=1.35;//Point Level
//---
extern string  Ext3="-------- Buy Series Control --------";//*********************
extern double  LotS_Buy=0.01;//Lot Start
extern double  LotsLv_Buy        =1.5;//Lot Level
extern int     PointStep_Buy     =250;//Point Start
extern double  PointStepLv_Buy=1.35;//Point Level
//---
extern string  Ext4="-------- TakeProfit Control --------";//*********************
extern ENUM_HoldingCut_MODE HoldingCut_MODE=ENUM_HoldingCut_MODE1;
extern double CapitalProfit_Percent_Sell  =1.35;//TP Sell (%)
extern double CapitalProfit_Percent_Buy   =1.35;//TP Buy (%)
extern double CapitalProfit_Percent       =1.35;//TP All (%)
extern double CapitalProfit_Percent_Hege=50;//TP Hege(%) Calculated from all Holding( 0==Off )

double CapitalProfit_AmountBYHege=0;
double CapitalProfit_Amount=0;
double CapitalProfit_Amount_Buy=0;
double CapitalProfit_Amount_Sell=0;
//---
//Lots Maneger
double Ratio=-1;
double LotB_Sell=LotS_Sell,LotB_Buy=LotS_Buy;

string Console[20];
string Console_Duplicate[1];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Symbol_SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);

   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);

   ArrayResize(Console_Duplicate,ArraySize(Console)-1);
   LockEA();
//---
   Balance=AccountBalance()+AccountCredit();
//Ratio=NormalizeDouble(Balance/Capital,4);
   OnTick();
//---

   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_BUY)+"_O",0,0,clrDimGray,3,0,true,false,0);
   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_BUY)+"_X",0,0,clrDimGray,3,0,false,false,0);

   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_SELL)+"_O",0,0,clrDimGray,3,0,true,false,0);
   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_SELL)+"_X",0,0,clrDimGray,3,0,false,false,0);
   DrawPanel();
//---
   return(INIT_SUCCEEDED);
  }
//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

   ObjectsDeleteAll(0,eaName_TageOrder,0,OBJ_BUTTON);
   ObjectsDeleteAll(0,eaName_TageOrder,0,OBJ_EDIT);
   ObjectsDeleteAll(0,eaName_TageOrder,0,OBJ_RECTANGLE_LABEL);
   ObjectsDeleteAll(0,eaName_TageOrder,0,OBJ_LABEL);

   ObjectsDeleteAll(0,eaName_TageOrder,0,OBJ_HLINE);
  }

//| Expert tick function                                             |

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Balance=AccountBalance()+AccountCredit();
//---
int Active=-1,ActiveBuy=-1,ActiveSell=-1;
double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
double Active_Lot=0,ActiveBuy_Lot=0,ActiveSell_Lot=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int Pending=-1,PendingBuy=-1,PendingSell=-1;
//
   int cntAll=getCntOrder(eaMagicNumber,Symbol(),
                          Active,ActiveBuy,ActiveSell,
                          Pending,PendingBuy,PendingSell,
                          Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                          Active_Lot,ActiveBuy_Lot,ActiveSell_Lot);

   Active_Hold=NormalizeDouble(Active_Hold,2);
   ActiveBuy_Hold=NormalizeDouble(ActiveBuy_Hold,2);
   ActiveSell_Hold=NormalizeDouble(ActiveSell_Hold,2);

   Balance=AccountBalance()+AccountCredit();

   if(cntAll==0 ||
      CapitalProfit_Amount==0 ||
      CapitalProfit_Amount_Buy==0 ||
      CapitalProfit_Amount_Sell==0
     )
     {
      //Ratio=NormalizeDouble(Balance/Capital,4);
      Ratio=1;
      //---
      LotB_Sell=NormalizeDouble(LotS_Sell*Ratio,2);
      LotB_Buy=NormalizeDouble(LotS_Buy*Ratio,2);
      //---
      CapitalProfit_Amount=Balance*(CapitalProfit_Percent/100);
      CapitalProfit_Amount_Buy=Balance*(CapitalProfit_Percent_Buy/100);
      CapitalProfit_Amount_Sell=Balance*(CapitalProfit_Percent_Sell/100);
      CapitalProfit_AmountBYHege=CapitalProfit_Amount*(CapitalProfit_Percent_Hege/100);

      CapitalProfit_Amount=NormalizeDouble(CapitalProfit_Amount,2);
      CapitalProfit_Amount_Buy=NormalizeDouble(CapitalProfit_Amount_Buy,2);
      CapitalProfit_Amount_Sell=NormalizeDouble(CapitalProfit_Amount_Sell,2);
      CapitalProfit_AmountBYHege=NormalizeDouble(CapitalProfit_AmountBYHege,2);

     }

   bool freeze=false;
//if(false)
     {
      //---
      //Hege
      if(CapitalProfit_Percent_Hege>0 &&
         PortStatusHege() && Active_Hold>=CapitalProfit_AmountBYHege)
        {
         Order_CloseAll(eaMagicNumber);
         ObjectsDeleteAll(0,0,OBJ_ARROW);
         ConsoleWrite("#"+string(__LINE__)+" Order_CloseHage "+DoubleToStr(Active_Hold,2)+"|"+DoubleToStr(CapitalProfit_AmountBYHege,2));
        }
      //---
      if(HoldingCut_MODE==1 || HoldingCut_MODE==2)
        {
         if(CapitalProfit_Amount>0 && Active_Hold>=CapitalProfit_Amount)
           {
            Order_CloseAll(eaMagicNumber);
            //ConsoleWrite("#"+string(__LINE__)+" ---");
            ConsoleWrite("#"+string(__LINE__)+" Order_CloseAll "+DoubleToStr(Active_Hold,2)+"|"+DoubleToStr(CapitalProfit_Amount,2));

            ObjectsDeleteAll(0,0,OBJ_ARROW);
            freeze=true;
           }
        }
      if(HoldingCut_MODE==1)
        {
         if(CapitalProfit_Amount_Buy>0 && ActiveBuy_Hold>=CapitalProfit_Amount_Buy)
           {
            Order_Close(OP_BUY,eaMagicNumber);
            //ConsoleWrite("#"+string(__LINE__)+" OP_BUY*"+Active_Hold+"|"+CapitalProfit_Amount);
            ConsoleWrite("#"+string(__LINE__)+" OP_BUY "+DoubleToStr(ActiveBuy_Hold,2)+"|"+DoubleToStr(CapitalProfit_Amount_Buy,2));

            ObjectsDeleteAll(0,0,OBJ_ARROW);
            freeze=true;
           }
         if(CapitalProfit_Amount_Sell>0 && ActiveSell_Hold>=CapitalProfit_Amount_Sell)
           {
            Order_Close(OP_SELL,eaMagicNumber);
            //ConsoleWrite("#"+string(__LINE__)+" OP_SELL*"+Active_Hold+"|"+CapitalProfit_Amount);
            ConsoleWrite("#"+string(__LINE__)+" OP_SELL "+DoubleToStr(ActiveSell_Hold,2)+"|"+DoubleToStr(CapitalProfit_Amount_Sell,2));

            ObjectsDeleteAll(0,0,OBJ_ARROW);
            freeze=true;
           }
        }
     }

   if(!freeze)
     {

      if(AllowDIR==ENUM_OrderDIR_2WAY)
        {
         //PRINT(__LINE__,"AllowBuy && AllowSell","");

         bool b1=(Active==0 && (MarketInfo(Symbol(),MODE_SPREAD)<=exLimitSPREAD) && !exLastloop);
         bool b2=(Active!=0);


         //ConsoleWrite("#"+string(__LINE__)+" AllowBuy && AllowSell "+b1+" "+b2);

         if(b1 ||
            b2)
           {
            Order_Open(OP_BUY,Ask,ActiveBuy,PointStepLv_Buy,LotB_Buy,LotsLv_Buy);
            Order_Open(OP_SELL,Bid,ActiveSell,PointStepLv_Sell,LotB_Sell,LotsLv_Sell);
           }
        }
      else
        {
         if(AllowDIR==ENUM_OrderDIR_BUYY &&
            ((ActiveBuy==0 && !exLastloop) || (ActiveBuy!=0)))
           {
            Order_Open(OP_BUY,Ask,ActiveBuy,PointStepLv_Buy,LotB_Buy,LotsLv_Buy);
           }
         if(AllowDIR==ENUM_OrderDIR_SELL &&
            ((ActiveSell==0 && !exLastloop) || (ActiveSell!=0)))
           {
            Order_Open(OP_SELL,Bid,ActiveSell,PointStepLv_Sell,LotB_Sell,LotsLv_Sell);
           }
        }
     }

   string iCMM=eaName_Hader+" "+eaName_Ver+" "+strTickWork();

   if(DrawComment_Show)
     {
      iCMM+="\n -----";

      iCMM+="\n OrderCnt: "+string(Active)+" ["+string(ActiveBuy)+","+string(ActiveSell)+"]";
      //iCMM+="\n LastOrder_BU: "+string(getLastOrder(OP_BUY,0))+" ["+getLastOrder_DistanceInfo(OP_BUY,pNULL,pNULL)+"]";
      //iCMM+="\n LastOrder_SE: "+string(getLastOrder(OP_SELL,0))+" ["+getLastOrder_DistanceInfo(OP_SELL,pNULL,pNULL)+"]";
      iCMM+="\n Hold: "+DoubleToStr(Active_Hold,2)+" ["+DoubleToStr(ActiveBuy_Hold,2)+" | "+DoubleToStr(ActiveSell_Hold,2)+"]";
      iCMM+="\n -----";
      iCMM+="\n Cut-O["+string(CapitalProfit_Percent)+"%]: "+DoubleToStr(CapitalProfit_Amount,2);
      iCMM+="\n Cut-B["+string(CapitalProfit_Percent_Buy)+"%]: "+DoubleToStr(CapitalProfit_Amount_Buy,2);
      iCMM+="\n Cut-S["+string(CapitalProfit_Percent_Sell)+"%]: "+DoubleToStr(CapitalProfit_Amount_Sell,2);
      iCMM+="\n -----";
      iCMM+="\n AccountEquity: "+DoubleToStr(Balance,2);
      iCMM+="\n -----";
      iCMM+="\n Ratio: "+DoubleToStr(Ratio,2);

      if(eaDevelop)
        {
         iCMM+="\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
         iCMM+="\n -----";
         for(int i=0; i<ArraySize(Console); i++)
           {
            iCMM+="\n CMD_"+string(i)+":"+Console[i];
           }
        }
      //---
     }
   Comment(iCMM);
//---
   DrawPanel();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//OnTick();
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
   if(id==CHARTEVENT_KEYDOWN)
     {
      printf("CHARTEVENT_KEYDOWN: "+string(lparam));
      if(!IsTesting())
        {
         //ConsoleWrite(string(lparam));
         if(lparam==9)
           {
            DrawPanel_HideShow();
           }

         if(lparam==81) //Q
           {
            DrawComment_Show=(DrawComment_Show)?false:true;
           }
         if(lparam==87) //W
           {
            eaDevelop=(eaDevelop)?false:true;
           }
         OnTick();
        }
     }

   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Print("CHARTEVENT_OBJECT_CLICK: '"+sparam+"'");

      if(sparam==eaName_TageOrder+"HP@BTN_Head")
        {
         DrawPanel_HideShow();
        }
      //---
      if(sparam==eaName_TageOrder+"PN@BTN_ATC_SELL")
        {
         int M_Box=MessageBox("Do you want to close all Sell orders?","BTN_ATC_SELL",MB_YESNO);
         if(M_Box==IDYES)
            Order_Close(OP_SELL,eaMagicNumber);
        }
      if(sparam==eaName_TageOrder+"PN@BTN_ATC_BUY")
        {
         int M_Box=MessageBox("Do you want to close all Buy orders?","BTN_ATC_BUY",MB_YESNO);
         if(M_Box==IDYES)
            Order_Close(OP_BUY,eaMagicNumber);
        }
      if(sparam==eaName_TageOrder+"PN@BTN_ATC_ALL")
        {
         int M_Box=MessageBox("Do you want to close all orders?","BTN_ATC_ALL",MB_YESNO);
         if(M_Box==IDYES)
            Order_CloseAll(eaMagicNumber);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ConsoleWrite(string w)
  {
   for(int i=0; i<(ArraySize(Console)-1); i++)
      Console_Duplicate[i]=Console[i];
   for(int i=1; i<(ArraySize(Console)); i++)
      Console[i]=Console_Duplicate[i-1];
   Console[0]="["+string(TimeCurrent())+"] "+w;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_Open(int OP_DIR,
                double Price_Open,
                int CNT,
                double PriceLv,
                double LotsStart,
                double LostLv)
  {
//printf("On"+CNT);
//Element OrderForOrderSend
   int OS=-1;
   string CMM=eaName_TageOrder+OP_DIR_to_Str(OP_DIR)+"_"+string(CNT+1)+"|"+string(eaMagicNumber)+"nm";
//---
//Maneger
   double Price_Limit_O=0;
   double Price_Limit_X=0;

   double Order_Distance=-1;
   double LastOrder_OpenPrice=-1;
//---

   if(CNT==0)
     {
      if(Authentication)
        {
         OS=OrderSend(Symbol(),OP_DIR,LotsStart,Price_Open,100,0,0,CMM,eaMagicNumber,0);
        }
     }
   else
     {
      int Mark_Event=-1;
      //---
      if(CNT==1)
        {
         Mark_Event=1;
         //---
         getLastOrder(OP_DIR,1);
         LastOrder_OpenPrice=OrderOpenPrice();

         Order_Distance=(OP_DIR==OP_BUY)?PointStep_Buy:PointStep_Sell;
         Order_Distance=Order_Distance/MathPow(10,Digits);

         if(OP_DIR==OP_BUY)
            Order_Distance=Order_Distance*(-1);

         //Price_Limit_O=LastOrder_OpenPrice+Order_Distance;
         Price_Limit_X=LastOrder_OpenPrice+Order_Distance;
        }
      else
        {
         Mark_Event=2;
         //---
         Order_Distance=getLastOrder_DistanceInfo(OP_DIR,LastOrder_OpenPrice);

         double PointStepLv=(OP_DIR==OP_BUY)?PointStepLv_Buy:PointStepLv_Sell;
         if(OP_DIR==OP_BUY)
            Order_Distance=Order_Distance*(-1);

         if(Order_Distance!=-1)
           {
            Price_Limit_O=LastOrder_OpenPrice+Order_Distance;
            Price_Limit_X=LastOrder_OpenPrice+(Order_Distance*PointStepLv);
           }
        }
      //-----------------------------------------------
      //Element SendOrder

      bool Condition_Exe=(OP_DIR==OP_BUY)?
                         Price_Open<=Price_Limit_X:
                         Price_Open>=Price_Limit_X;

      if(Condition_Exe && Order_Distance!=-1)
        {
         NormalizeDouble(Order_Distance,Digits);
         //ConsoleWrite("Condition_Exe: "+string(Condition_Exe)+" | Event: "+string(Mark_Event)+" | Order_Distance "+DoubleToStr(Order_Distance,Digits));
         //---

         double _Lots=Order_getLot(OP_DIR,CNT+1);
         //ConsoleWrite("Order_Open2: "+OP_DIR_to_Str(OP_DIR)+" "+_Lots);
         OS=OrderSend(Symbol(),OP_DIR,_Lots,Price_Open,100,0,0,CMM,eaMagicNumber,0);
        }

     }
//+--------------------------
   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_DIR)+"_O",0,Price_Limit_O,clrDimGray,3,0,true,false,0);

   color clrLimit_X=(OP_DIR==OP_BUY)?clrDodgerBlue:clrRed;
   HLineCreate(0,eaName_TageOrder+"Draft_"+string(OP_DIR)+"_X",0,Price_Limit_X,clrLimit_X,3,0,false,false,0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OP_DIR_to_Str(int OP)
  {
   return (OP==OP_BUY)?"BUY":"SELL";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order_getLot(int OP_DIR,int CNT)
  {
   double Post=(OP_DIR==OP_BUY)?LotB_Buy:LotB_Sell;
   double Table=(OP_DIR==OP_BUY)?LotsLv_Buy:LotsLv_Sell;
   double Post2=Post;

//printf(OP_DIR+" | Post: "+Post+" | Table"+Table);
//printf("---");

   for(int i=0; i<CNT; i++)
     {
      //printf("#"+string(i+1)+" "+DoubleToStr(Post,4)+" | "+DoubleToStr(Post2,2));
      if(i<CNT-1)
        {
         Post*=Table;
         Post=NormalizeDouble(Post,4);
         Post2=NormalizeDouble(Post,2);
        }
     }
   return NormalizeDouble(Post,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll(int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)) &&
         (OrderSymbol()==Symbol()) &&
         //(OrderType()==OP_DIR) &&
         (OrderMagicNumber()==Magic))
        {
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0; i<ArraySize(ORDER_TICKET_CLOSE); i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
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
bool PortStatusHege()
  {
   return (ActiveBuy>=1 && ActiveSell>=1 && Active_Lot==0)?true:false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_Close(int OP_DIR,int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0; pos<OrdersTotal(); pos++)
     {
      if(
         (OrderSelect(pos,SELECT_BY_POS)) &&
         (OrderSymbol()==Symbol()) &&
         (OrderType()==OP_DIR) &&
         (OrderMagicNumber()==Magic)
      )
        {
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }

     }
//+---------------------------------------------------------------------+
   for(int i=0; i<ArraySize(ORDER_TICKET_CLOSE); i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),10);
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
int getCntOrder(int iMN,string iOrderSymbol,
                int &aActive,int &aActiveBuy,int &aActiveSell,
                int &Pending,int &PendingBuy,int &PendingSell,
                double &aActive_Hold,double &aActiveBuy_Hold,double &aActiveSell_Hold,
                double &aActive_Lot,double &aActiveBuy_Lot,double &aActiveSell_Lot)

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
      if(OrderSymbol()==iOrderSymbol &&
         OrderMagicNumber()==iMN)
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
           }
         if(Type==OP_SELL)
           {
            cntOP_SELL++;
            aActiveSell_Hold+=Hold;
            aActiveSell_Lot+=Lot;
           }
         if(Type==OP_BUYLIMIT)
            cntOP_BUYLIMIT++;
         if(Type==OP_SELLLIMIT)
            cntOP_SELLLIMIT++;
         if(Type==OP_BUYSTOP)
            cntOP_BUYSTOP++;
         if(Type==OP_SELLSTOP)
            cntOP_SELLSTOP++;
        }
     }
//---

   aActive_Hold=aActiveBuy_Hold+aActiveSell_Hold;

   aActive_Lot=aActiveBuy_Lot-aActiveSell_Lot;
//
   aActiveBuy=cntOP_BUY;
   aActiveSell=cntOP_SELL;
   PendingBuy=cntOP_BUYLIMIT+cntOP_BUYSTOP;
   PendingSell=cntOP_SELLLIMIT+cntOP_SELLSTOP;
//
   return Active+Pending;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getLastOrder(int OP_DIR,int rank)
  {
   bool find=false;
   int Count_Rank=0;
   for(int i=(OrdersTotal()-1); i>=0; i --)

     {
      bool OS=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==eaMagicNumber) &&
         (OrderSymbol()==Symbol()) &&
         (OrderType()==OP_DIR)
        )
        {
         Count_Rank++;
         if(Count_Rank==rank)
           {
            find=true;
            break;
           }
        }
     }
//
   if(find)
      return OrderTicket();
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLastOrder_DistanceInfo(int OP_DIR,double &PriceA)
  {
   bool find=false;
   int Count_Rank=0;
//
   PriceA=-1;
   double PriceB=-1;
//
   for(int i=(OrdersTotal()-1); i>=0; i --)

     {
      bool OS=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==eaMagicNumber) &&
         (OrderSymbol()==Symbol()) &&
         (OrderType()==OP_DIR)
        )
        {
         Count_Rank++;
         if(Count_Rank==1)
           {
            PriceA=OrderOpenPrice();
           }
         if(Count_Rank==2)
           {
            PriceB=OrderOpenPrice();
            //
            find=true;
            break;
           }
        }
     }
//
   if(find)
      return NormalizeDouble(MathAbs(PriceB-PriceA),Digits);
   return -1;
  }

bool TickWork=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strTickWork()
  {
   TickWork=(TickWork)?false:true;

   string Con=(IsConnected())?"":"Disconnection ";

   return (TickWork)?Con+"O":Con+"X";
  }

bool DrawPanel_Show=true;
bool DrawComment_Show=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPanel_HideShow()
  {

   DrawPanel_Show=(DrawPanel_Show)?false:true;
   printf("DrawPanel_Show: "+string(DrawPanel_Show));

   if(!DrawPanel_Show)
     {
      ObjectsDeleteAll(0,eaName_TageOrder+"PN",0,OBJ_BUTTON);
      ObjectsDeleteAll(0,eaName_TageOrder+"PN",0,OBJ_EDIT);
      ObjectsDeleteAll(0,eaName_TageOrder+"PN",0,OBJ_RECTANGLE_LABEL);
      ObjectsDeleteAll(0,eaName_TageOrder+"PN",0,OBJ_LABEL);
     }

   else
     {
      DrawPanel();
     }
   LockEA();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPanel()
  {
   if(DrawPanel_Show)
     {
      //int CHART_WIDTH=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0));
      //printf(CHART_WIDTH);
      Symbol_SPREAD=MarketInfo(Symbol(),MODE_SPREAD);

      int Magin_Width=20;
      int BTN_Width=200;
      int BTN_Hight=25;
      int Magin=10;

      int Post_Y=25,Post_Step=25+5;

      setRectLabelCreate("PN@BG",BTN_Width+Magin_Width,55,clrNONE,clrLightYellow,clrLime,BTN_Width,330,false);

      setButtonCreate(0,"HP@BTN_Head",0,
                      BTN_Width+Magin_Width,Post_Y,BTN_Width,25,CORNER_RIGHT_UPPER,
                      eaName_Hader+" "+eaName_Ver,"Arial",14,clrWhite,clrDarkGoldenrod,clrDarkGoldenrod,
                      false,false,false);
      //
      BTN_Width=BTN_Width-(Magin*2);
      //
      //--- Infomation
      Post_Y+=25;
      setEditCreate("PN@Label_LotSell_H","Sell:",true,true,int((BTN_Width+Magin_Width+Magin)),Post_Y+20,35,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);
      setEditCreate("PN@Label_LotSell",DoubleToStr(ActiveSell_Lot,2),true,true,int((BTN_Width+Magin_Width+Magin)-30),Post_Y+20,60,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);
      Post_Y+=14;
      setEditCreate("PN@Label_LotBuy_H","Buy:",true,true,int((BTN_Width+Magin_Width+Magin)),Post_Y+20,35,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);
      setEditCreate("PN@Label_LotBuy",DoubleToStr(ActiveBuy_Lot,2),true,true,int((BTN_Width+Magin_Width+Magin)-30),Post_Y+20,60,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);
      Post_Y+=14;
      setEditCreate("PN@Label_LotAll_H","All:",true,true,int((BTN_Width+Magin_Width+Magin)),Post_Y+20,35,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);
      string Hege_Status=(PortStatusHege())?"Hage":DoubleToStr(Active_Lot,2);
      setEditCreate("PN@Label_LotAll",Hege_Status,true,true,int((BTN_Width+Magin_Width+Magin)-30),Post_Y+20,60,15,10,0,1,clrNumberLot(Active_Lot),clrLightYellow,clrLightYellow,false,false);

      //
      Post_Y-=28;
      color clrSPREAD=(Symbol_SPREAD<=exLimitSPREAD)?clrBlack:clrRed;
      setEditCreate("PN@Label_SpreadVar1",string(Symbol_SPREAD),true,true,int((BTN_Width+Magin_Width+Magin)-(BTN_Width*0.5)),Post_Y+20,80,25,20,0,1,clrSPREAD,clrLightYellow,clrLightYellow,false,false);
      setEditCreate("PN@Label_SpreadVar2",string(exLimitSPREAD),true,true,int((BTN_Width+Magin_Width+Magin)-(BTN_Width*0.5)),Post_Y+6,90,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);

      Post_Y+=45;
      LabelCreate("PN@Label_SpreadHead",int((BTN_Width+Magin_Width+Magin)-(BTN_Width*0.68)),Post_Y,"Spread",11,clrBlack,false);
      Post_Y+=15;
      LabelCreate("PN@Label_Line",(BTN_Width+Magin_Width+Magin),Post_Y,"-----------------------------------",11,clrBlack,false);
      //--- ---
      Post_Y+=15;
      setEditCreate("PN@Label_NAV_Sell",DoubleToStr(ActiveSell_Hold,2)+((HoldingCut_MODE==1)?" | "+DoubleToStr(CapitalProfit_Amount_Sell,2):""),true,true,(BTN_Width+Magin_Width+Magin),Post_Y+10,BTN_Width,25,14,0,1,clrNumber(ActiveSell_Hold),clrLightYellow,clrLightYellow,false,false);
      setEditCreate("PN@Label_NAV_SellPer",((HoldingCut_MODE==1)?"Sell: "+string(CapitalProfit_Percent_Sell)+"%":""),true,true,(BTN_Width+Magin_Width+Magin),Post_Y,BTN_Width,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);

      Post_Y+=40;
      setButtonCreate(0,"PN@BTN_ATC_SELL",0,
                      BTN_Width+Magin_Width+Magin,Post_Y,BTN_Width,BTN_Hight,CORNER_RIGHT_UPPER,
                      "ATC:SELL : "+string(ActiveSell),"Arial",10,clrWhite,clrRed,clrRed,
                      true,false,false);
      //--- ---
      Post_Y+=30;
      setEditCreate("PN@Label_NAV_Buy",DoubleToStr(ActiveBuy_Hold,2)+((HoldingCut_MODE==1)?" | "+DoubleToStr(CapitalProfit_Amount_Buy,2):""),true,true,(BTN_Width+Magin_Width+Magin),Post_Y+10,BTN_Width,25,14,0,1,clrNumber(ActiveBuy_Hold),clrLightYellow,clrLightYellow,false,false);
      setEditCreate("PN@Label_NAV_BuyPer",((HoldingCut_MODE==1)?"Buy: "+string(CapitalProfit_Percent_Buy)+"%":""),true,true,(BTN_Width+Magin_Width+Magin),Post_Y,BTN_Width,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);

      Post_Y+=40;
      setButtonCreate(0,"PN@BTN_ATC_BUY",0,
                      BTN_Width+Magin_Width+Magin,Post_Y,BTN_Width,BTN_Hight,CORNER_RIGHT_UPPER,
                      "ATC:BUY : "+string(ActiveBuy),"Arial",10,clrWhite,clrDodgerBlue,clrDodgerBlue,
                      true,false,false);

      //--- ---
      Post_Y+=30;
      setEditCreate("PN@Label_NAV_ALL",DoubleToStr(Active_Hold,2)+" | "+DoubleToStr(CapitalProfit_Amount,2),true,true,(BTN_Width+Magin_Width+Magin),Post_Y+10,BTN_Width,25,14,0,1,clrNumber(Active_Hold),clrLightYellow,clrLightYellow,false,false);
      string Hege_Status_OX=(CapitalProfit_Percent_Hege==0)?"":"Hage: "+DoubleToStr(CapitalProfit_Percent_Hege,2)+"% | ";
      setEditCreate("PN@Label_NAV_ALLPer",Hege_Status_OX+"ALL: "+string(CapitalProfit_Percent)+"%",true,true,(BTN_Width+Magin_Width+Magin),Post_Y,BTN_Width,15,10,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);

      Post_Y+=40;
      setButtonCreate(0,"PN@BTN_ATC_ALL",0,
                      BTN_Width+Magin_Width+Magin,Post_Y,BTN_Width,BTN_Hight,CORNER_RIGHT_UPPER,
                      "ATC:ALL : "+string(Active),"Arial",10,clrWhite,clrForestGreen,clrForestGreen,
                      true,false,false);
      //--- ---
      Post_Y+=30;
      LabelCreate("PN@Label_Line2",(BTN_Width+Magin_Width+Magin),Post_Y," =================== ",11,clrBlack,false);
      Post_Y+=15;
      setEditCreate("PN@Label_Balance","$ "+DoubleToStr(Balance,2),true,true,(BTN_Width+Magin_Width+Magin),Post_Y,BTN_Width,25,17,0,1,clrNumber(Balance),clrLightYellow,clrLightYellow,false,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrNumber(double v)
  {
   return (v>=0)?clrForestGreen:clrRed;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrNumberLot(double v)
  {
   if(v==0)
      return clrForestGreen;
   return (v>0)?clrDodgerBlue:clrRed;
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
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);

   if(price==-1)
     {
      ObjectDelete(chart_ID,name);
      return false;
     }
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setButtonCreate(const long              chart_ID=0,// chart's ID
                     string                  name="Button",// button name
                     const int               sub_window=0,             // subwindow index
                     const int               x=0,                      // X coordinate
                     const int               y=0,                      // Y coordinate
                     const int               width=50,                 // button width
                     const int               height=18,                // button height
                     const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const string            text="Button",            // text
                     const string            font="Arial",             // font
                     const int               font_size=10,             // font size
                     const color             clr=clrBlack,             // text color
                     const color             back_clr=C'236,233,216',  // background color
                     const color             border_clr=clrNONE,       // border color
                     const bool              state=false,              // pressed/released
                     const bool              back=false,               // in the background
                     const bool              selection=false)          // highlight to move
  {

   name=eaName_TageOrder+name;
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      //Print(__FUNCTION__,
      //      ": failed to create the button! Error code = ",GetLastError());
      //return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setRectLabelCreate(string name,int x,int y,color clr,color back_clr,color border_clr,int width,int height,bool selection)
  {
   int chart_ID=0;
//---
   name=eaName_TageOrder+name;

   int sub_window=0;
   int corner=CORNER_RIGHT_UPPER;
   string font="Arial";

   bool back=false;
   bool state=true;
   int z_order=0;

   ENUM_BORDER_TYPE border=BORDER_FLAT;
   ENUM_LINE_STYLE style=STYLE_SOLID;
   int line_width=4;
//--- reset the error value
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      //Print(__FUNCTION__,": failed to create a rectangle label! Error code = ",GetLastError());
      //return;
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(string            name="Label",// label name
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const string            text="Label",             // text
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const bool              back=false)               // in the background

  {
   long              chart_ID=0;// chart's ID
   int               sub_window=0;// subwindow index
   ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER;// chart corner for anchoring
   string            font="Arial";// font
   double            angle=0;                // text slope
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER; // anchor type
   long              z_order=0;                // priority for mouse click
   bool              selection=false; // highlight to move
   name=eaName_TageOrder+name;

//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setEditCreate(string           name="Edit",// object name
                   const string           text="Text",// text
                   const bool             reDraw=false,// ability to edit
                   const bool             read_only=false,          // ability to edit
                   const int              x=0,                      // X coordinate
                   const int              y=0,                      // Y coordinate
                   const int              width=50,                 // width
                   const int              height=18,                // height
                   const int              font_size=10,             // font size
                   const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                   const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                   const color            clr=clrBlack,             // text color
                   const color            back_clr=clrWhite,        // background color
                   const color            border_clr=clrNONE,       // border color
                   const bool             back=false,               // in the background
                   const bool             selection=false)          // highlight to move
  {
   long  chart_ID=0;
   name=eaName_TageOrder+name;

//--- reset the error value
   ResetLastError();
//--- create edit field
   if(ObjectCreate(chart_ID,name,OBJ_EDIT,0,0,0))
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }

   else
     {

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
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution
   return(true);
  }

bool Authentication=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LockEA()
  {
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
   string List_ID[]= {""};
   string List_Name[]= {""};
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
   string Test_ID="",Test_Name="";
//
//Test_ID="9999";
//Test_Name="A_A";
//
   Test_ID=string(AccountInfoInteger(ACCOUNT_LOGIN));
   Test_Name=AccountInfoString(ACCOUNT_NAME);
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---
   bool Chk_ID=false;
   for(int i=0; i<ArraySize(List_ID); i++)

     {
      if(i==0 && (List_ID[0]=="" || List_ID[0]==Test_ID))
        {
         Chk_ID=true;
         break;
        }
      //---
      if(List_ID[i]==Test_ID)
        {
         Chk_ID=true;
         break;
        }
     }
//---
   bool Chk_Name=false;
   for(int i=0; i<ArraySize(List_Name); i++)

     {
      if(i==0 && (List_Name[0]=="" || StringFind(List_Name[0],Test_Name,0)>=0))
        {
         Chk_Name=true;
         break;
        }
      //---
      if(List_Name[i]==Test_Name)
        {
         Chk_Name=true;
         break;
        }
     }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Print("----------------------------------------------");
   Print("["+Test_ID+"] # "+string(Chk_ID));
   for(int i=0; i<ArraySize(List_ID); i++)

     {
      if(List_ID[i]!="")
        {
         Print("["+string(List_ID[i])+"]");
        }
     }
   Print("--------");
   Print("["+Test_Name+"] # "+string(Chk_Name));
   for(int i=0; i<ArraySize(List_Name); i++)

     {
      if(List_Name[i]!="")
        {
         string str=List_Name[i];
         StringReplace(str," ","_");
         Print("["+str+"]");
        }
     }
   Print("----------------------------------------------");
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---
   StringReplace(Test_Name," ","_");
   bool Result=(Chk_ID && Chk_Name)?true:false;
   printf("#"+string(__LINE__)+" #EALock Get  | ID : "+string(Test_ID)+" | Name: "+string(Test_Name));
   printf("#"+string(__LINE__)+" #EALock Chk | ID : "+string(Chk_ID)+" | Name: "+string(Chk_Name));

   printf("#"+string(__LINE__)+" #EALock Result: "+string(Result));

   if(IsDemo() || IsTesting())
     {
      Result=true;
      printf("#"+string(__LINE__)+" #EALock IsDemo()");
     }
   Print("----------------------------------------------");
   Authentication=Result;

   return Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PRINT(int from,string header,string body)
  {
   printf("#"+string(from)+" | "+header+" :: "+body);
  }
//+------------------------------------------------------------------+
