//|                                             Xt-Line-Sniper_2.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |

#property copyright "https://www.facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict



#include "In.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_Price
  {
   MODE_Price0=0,//C
   MODE_Price1=1,//O
   MODE_Price2=2,//H
   MODE_Price3=3,//L
   MODE_Price4=4,//HL/2
   MODE_Price5=5,//HLC/3
   MODE_Price6=6,//(HL+2)*(C/4)
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_TERND
  {
   MODE_TERND_Primary=0,//Primary
   MODE_TERND_Minor=1,//Minor
  };
int               nBar=-1;
int               DATA_TICKET_CLOSE[];

extern double     Lots_=0.1;//Lots
extern int        Period1=10;
extern int        Period2=100;
extern int        BarCount1=8;
extern int        BarCount2=4;
extern double     OrderNearby=100;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   ChartSetInteger(0,CHART_SHOW_GRID,false);
   HA(Period1,0);
   HA(Period2,1);
   OnTick();

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
void OnTick()
  {
//---

   string CMM="";
   CMM+="\n"+DoubleToStr(AccountInfoDouble(ACCOUNT_PROFIT),2);
//CMM+="\n"+TCCI_Get(0,20,Digits,0,1);
   CMM+="\n----------";
//---

   string Buffer="";
   for(int i=1+BarCount1-1;i>=1;i--)
     {
      //Buffer+=DirToStr(Ext_Daren_1[i]);
      Buffer+=DirToStr(iCustom(Symbol(),Period(),"_Employ/Line_MrNit/Xtreme Line - Connect",Period(),0,13,1,i));
     }
   CMM+="\n"+Buffer;

   string Buffer2="";
   for(int i=1+BarCount2-1;i>=1;i--)
     {
      Buffer2+=DirToStr(Ext_Daren_2[i]);
     }
   CMM+="\n"+Buffer2;
//---

   if(nBar!=Bars)
     {
      nBar=Bars;

      ObjectsDeleteAll_();
      HA(Period1,0);
      HA(Period2,1);

     }
   Comment(CMM);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

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
double TCCI_Get(int pMode,int period,int digit,int index,int bar)
  {
   double _iCustom_TCCI=iCustom(Symbol(),Period(),"_Employ/Line_MrNit/TCCI with Alert - Copy",pMode,period,index,bar);

   if(_iCustom_TCCI==EMPTY_VALUE) _iCustom_TCCI=0;

   return NormalizeDouble(_iCustom_TCCI,digit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TCCI_Translate(double v)
  {
   int r=-1;
   if(v>0)  r=OP_BUY;
   if(v<0)  r=OP_SELL;
   return r;
  }

double            Ext_Heiken[];

int               Ext_Daren_1[];
int               Ext_Daren_2[];

int               Bar_Current=-1;
//double ExtLowHighBuffer[];
//double ExtHighLowBuffer[];
double            ExtOpenBuffer[];
double            ExtCloseBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HA(int Period_,int MODE)
  {
     {

      double maOpen=0,maClose=0,maLow=0,maHigh=0;
      double haOpen=0,haHigh=0,haLow=0,haClose=0;
      int _Bars=iBars(Symbol(),Period());
      ArrayResize(ExtOpenBuffer,_Bars);
      ArrayResize(ExtCloseBuffer,_Bars);

      ArrayResize(Ext_Heiken,_Bars);
      if(MODE==0) ArrayResize(Ext_Daren_1,_Bars);
      else           ArrayResize(Ext_Daren_2,_Bars);

      int pos=_Bars-2;
      while(pos>=0)
        {
         maOpen=iMA(Symbol(),Period(),Period_,0,MODE_SMMA,int(MODE_OPEN),pos);
         maClose=iMA(Symbol(),Period(),Period_,0,MODE_SMMA,int(MODE_CLOSE),pos);
         maLow=iMA(Symbol(),Period(),Period_,0,MODE_SMMA,int(MODE_LOW),pos);
         maHigh=iMA(Symbol(),Period(),Period_,0,MODE_SMMA,int(MODE_HIGH),pos);
         //----
         haOpen=(ExtOpenBuffer[pos+1]+ExtCloseBuffer[pos+1])/2;
         haClose=(maOpen+maHigh+maLow+maClose)/4;
         haHigh=MathMax(maHigh,MathMax(haOpen,haClose));
         haLow=MathMin(maLow,MathMin(haOpen,haClose));

         if(haOpen<haClose)
           {
            //ExtLowHighBuffer[pos]=haLow;
            //ExtHighLowBuffer[pos]=haHigh;

            //ExtHeiken[pos]=haHigh;
            Ext_Heiken[pos]=pos;
           }
         else
           {
            //ExtLowHighBuffer[pos]=haHigh;
            //ExtHighLowBuffer[pos]=haLow;

            //ExtHeiken[pos]=haLow;
            Ext_Heiken[pos]=-pos;
           }

         ExtOpenBuffer[pos]=haOpen;
         ExtCloseBuffer[pos]=haClose;

         //printf(haClose);

         pos--;
        }
     }
   for(int i=0,j=0;i<Bars;i++,j++)

     {
      double _TCCI=TCCI_Get(0,Period_,Digits,3,i);

      if(_TCCI!=EMPTY_VALUE && Ext_Heiken[i]!=EMPTY_VALUE)
        {
         if(_TCCI>0 && Ext_Heiken[j]>0)
           {
            if(MODE==0) Ext_Daren_1[j]=OP_BUY;
            else        Ext_Daren_2[j]=OP_BUY;
           }
         //        
         if(_TCCI<0 && Ext_Heiken[j]<0)
           {
            if(MODE==0) Ext_Daren_1[j]=OP_SELL;
            else        Ext_Daren_2[j]=OP_SELL;
           }
         //        
         if((_TCCI>0 && Ext_Heiken[j]<0) || 
            (_TCCI<0 && Ext_Heiken[j]>0))
           {
            if(MODE==0) Ext_Daren_1[j]=-1;
            else        Ext_Daren_2[j]=-1;
           }
         else
           {

/*if(j==0)
              {
               if(Bar_Current!=Bars)
                 {
                  Bar_Current=Bars;
                  //
                  Tick_UP=0;
                  Tick_DW=0;
                 }
               //---
               if((Ext_TCCI[j]<0 && Ext_Heiken[j]==0) && Ext_Lime2[j]>0)
                 {

                 }

               if((Ext_TCCI[j]>0 && Ext_Heiken[j]==0) && Ext_Red2[j]>0)
                 {
                  Ext_Lime2[j]=Arr_Main[i];
                  Ext_Red2[j]=EMPTY_VALUE;

                  Ext_Lime2[j+1]=EMPTY_VALUE;
                  Ext_Red2[j+1]=EMPTY_VALUE;
                 }
              }*/
           }
         //---

        }
      else
        {
         break;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectsDeleteAll_()
  {
   ObjectsDeleteAll(0,OBJ_ARROW);
//ObjectsDeleteAll(0,OBJ_TREND);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DirToStr(int statement)
  {
   switch(statement)
     {
      case  OP_BUY:
         return "U";
      case  OP_SELL:
         return "D";
      default:
         return "H";
     }
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalGet(string v,int BarN,string &Arr[])
  {
   bool r=false;
   for(int i=0;i<ArraySize(Arr);i++)
     {
      if(v==StringSubstr(Arr[i],8-BarN,BarN))
        {
         r=true;
         break;
        }
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderGetNearby(double v,int OP_DIR)
  {
   bool r=true;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderType()==OP_DIR)
        {
         if(MathAbs(v-OrderOpenPrice())<=(OrderNearby*Point))
           {
            r=false;
            break;
           }
        }
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Ontick_Ver1(string Buffer,string Buffer2)
  {
     {
        {
         for(int i=0;i<OrdersTotal();i++)
           {
            if(OrderSelect(i,SELECT_BY_POS)==false) continue;
            if(OrderProfit()>0)
              {
               if(SignalGet(Buffer,BarCount1,InDW) && OrderType()==OP_BUY)
                 {
                  bool res=OrderClose(OrderTicket(),OrderLots(),Bid,10);
                 }
               if(SignalGet(Buffer,BarCount1,InUP) && OrderType()==OP_SELL)
                 {
                  bool res=OrderClose(OrderTicket(),OrderLots(),Ask,10);
                 }
              }
           }
        }
      if(AccountInfoDouble(ACCOUNT_PROFIT)>=OrdersTotal() && OrdersTotal()>=5)
        {
         ArrayResize(DATA_TICKET_CLOSE,OrdersTotal());

         for(int pos=0;pos<OrdersTotal();pos++)
           {
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
            DATA_TICKET_CLOSE[pos]=OrderTicket();
           }
         //+---------------------------------------------------------------------+
         for(int i=0;i<ArraySize(DATA_TICKET_CLOSE);i++)
           {
            if(DATA_TICKET_CLOSE[i]>0)
              {
               if(OrderSelect(DATA_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
                 {
                  //bool z=OrderDelete(OrderTicketClose[i]);
                  bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
                  if(GetLastError()==0){DATA_TICKET_CLOSE[i]=0;}
                 }
              }
           }
         ArrayResize(DATA_TICKET_CLOSE,1);
        }
     }
     {
      double OP=Ask;
      if(/*SignalGet(Buffer2,BarCount2,InUP) &&*/ SignalGet(Buffer,BarCount1,InUP) && OrderGetNearby(OP,OP_BUY))
        {

         double TP=NormalizeDouble(OP+(300*Point),Digits);
         double SL=NormalizeDouble(OP-(300*Point),Digits);
         //TP=0;
         SL=0;
         bool res=OrderSend(Symbol(),OP_BUY,Lots_,OP,10,SL,TP,"",0);
        }
      //---
      OP=Bid;
      if(/*SignalGet(Buffer2,BarCount2,InDW) && */SignalGet(Buffer,BarCount1,InDW) && OrderGetNearby(OP,OP_SELL))
        {
         double TP=NormalizeDouble(OP-(300*Point),Digits);
         double SL=NormalizeDouble(OP+(300*Point),Digits);
         //TP=0;
         SL=0;
         bool res=OrderSend(Symbol(),OP_SELL,Lots_,OP,10,SL,TP,"",0);
        }
     }
  }
//+------------------------------------------------------------------+
