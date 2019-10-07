//+------------------------------------------------------------------+
//|                                                   Skyfallz_4.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "lapukdee @2019"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ORDER_MAGICNUMBER
  {
   ORDER_ADAMS=0,
   ORDER_BOSTON=1,

   ORDER_UniFOLLOW_TF=11,
   ORDER_UniCROSS_TF=12
  };
double _MODE_SWAPLONG=MarketInfo(Symbol(),MODE_SWAPLONG);
double _MODE_SWAPSHORT=MarketInfo(Symbol(),MODE_SWAPSHORT);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TAGORDER_NAME="Skyfalls";

string PathFile="My/ZigZag";
string PathFile2="_Employ/Line_MrNit/Xtreme_Line_Connect";
#include "SkyFallz_Struct.mqh"
sACCOUNT D;

extern double     lots=0.01;    // Depth 1%;200
extern int        Depth=24;    // Depth
extern double     BackstepRate=80;  // BackstepRate
extern double     OrderNearbyArea=50;
extern double     OrderNearbyFriend=1;

double MarkUP[4];
double MarkDW[4];
datetime MarkUP_Date[4];
datetime MarkDW_Date[4];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);

   ChartSetInteger(0,CHART_SHOW_GRID,false);

   OnTick();

//if(false)
     {
      string name="panel";
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,-75);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,-87);
      ObjectSetString(0,name,OBJPROP_TEXT,"n");
      ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrMidnightBlue);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,300);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
     }
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
int nBar=-1;
string CMM1="",CMM2="";
string CMM_="\n                     ";
//+------------------------------------------------------------------+
double TCCI=-1;
double Universe_Dir=-1;
double Universe_Gear=-1;
double Universe_Origin=-1;
//+------------------------------------------------------------------+
bool Lightning_Chk=true;
int Lightning_High,Lightning_Low;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RR_Price=0,RR_Price2=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   CMM1="";
//---  
   CMM1+="\n                     Balance: "+D.iBalance();
   CMM1+="\n                     Holding: "+DoubleToStr(D.Holding,2)+" | "+DoubleToStr(D.getHoldingP(),2)+"%";
   D.iPort();
   CMM1+="\n                     Lot_ [ "+D.iOrdersTotals()+" ]: "+D.iLots();
   CMM1+="\n                     LotB [ "+D.iOrdersTotalBuy()+" ]: "+D.iLotsBuy();
   CMM1+="\n                     LotS [ "+D.iOrdersTotalSell()+" ]: "+D.iLotsSell();
   CMM1+="\n                     --- Stat ---";
   CMM1+="\n                     MaxDD: "+DoubleToStr(D.getMaxDD(),2);
   CMM1+="\n                     -------------------------------------";



   if(D.getHoldingP()>0)
     {
      if(//Single
         (D.LotsBuy>0 && D.LotsSell==0) || 
         (D.LotsBuy==0 && D.LotsSell>0))
        {
         //---OddsCall
         double Target_Single=D.OrdersTotals;
         if(D.OrdersTotals<=1)
           {
            Target_Single=3;
            if(Universe_Dir==-1)
              {
               Target_Single=1;
              }

           }
         //
         if(D.getHoldingP()>=Target_Single)
           {
            if(D.LotsBuy>0)
               Order_CloseAll(OP_BUY,ORDER_ADAMS);
            if(D.LotsSell>0)
               Order_CloseAll(OP_SELL,ORDER_ADAMS);
           }
        }
      //----------------------------------------------
      if(//Draw
         (D.LotsBuy>0 && D.LotsSell>0)
         )
        {
         //---OddsCall
         double Target_Single=D.OrdersTotals/3;
         if(D.OrdersTotals<=1) Target_Single=3;
         //
         if(D.getHoldingP()>=Target_Single)
           {
            Order_CloseAll(OP_BUY,ORDER_ADAMS);
            Order_CloseAll(OP_SELL,ORDER_ADAMS);
           }
        }
     }
//---
   D.iPort();
//+------------------------------------------------------------------+

//---
   if(nBar!=Bars)
     {
      CMM2="";
      nBar=Bars;
      //---
      //---
      Universe_Gear=Depth;
      if(!Univese_AgreeChk(Depth))
        {
         int Level=5;
         int Leve_Temp=0;
         for(int i=0;i<Level;i++)
           {
            Universe_Gear-=2;
            Universe_Gear=int(Universe_Gear);
            if(Univese_AgreeChk(int(Universe_Gear)))
              {
               Leve_Temp++;
               if(Leve_Temp==1)
                 {
                  //UniverseGear2=Depth_Temp;
                  break;
                 }
              }
           }
        }
      //---
      //TCCI=z(iCustom(Symbol(),Period(),PathFile2,Period(),0,Universe_Gear,0,1));
      //
      Universe_Dir=int(z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,7,0)));
      Universe_Origin=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,8,0));
      //---
      double d=-1;
      for(int i=0;i<3;i++)
        {
         MarkUP[i]=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,10,i));
         d=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,11,i));
         MarkUP_Date[i]=iTime(Symbol(),Period(),int(d));

         MarkDW[i]=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,13,i));
         d=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,14,i));
         MarkDW_Date[i]=iTime(Symbol(),Period(),int(d));
        }

      //---
      CMM2+=CMM_+"Universe_Gear: "+Universe_Gear;
      CMM2+=CMM_+"Univere_Dir: "+Universe_Dir;
      CMM2+=CMM_+"Univere_Origin: "+Universe_Origin;
      CMM2+=CMM_;
      CMM2+=CMM_+"M_High: "+DoubleToStr(M_High,5);
      CMM2+=CMM_+"M_Low: "+DoubleToStr(M_Low,5);
      CMM2+=CMM_+"M_Agree: "+Univese_Agree;
      //---

      TrendCreate(0,"TrendUP_0",0,MarkUP_Date[0],MarkUP[0],MarkUP_Date[1],MarkUP[1],clrRed,0,1,false,false,false,false,0);
      TrendCreate(0,"TrendDW_0",0,MarkDW_Date[0],MarkDW[0],MarkDW_Date[1],MarkDW[1],clrDodgerBlue,0,1,false,false,false,false,0);

      TrendCreate(0,"TrendUP_1",0,MarkUP_Date[1],MarkUP[1],MarkUP_Date[2],MarkUP[2],clrRed,2,1,false,false,false,false,0);
      TrendCreate(0,"TrendDW_1",0,MarkDW_Date[1],MarkDW[1],MarkDW_Date[2],MarkDW[2],clrDodgerBlue,2,1,false,false,false,false,0);

      //---

      double MarkArea=-1;
      //         
      datetime TimeCurentBar=iTime(Symbol(),Period(),0);
      double MarkStart=0;
      datetime MarkStart_Date=0;
      //---

      ObjectDelete(0,"Predict");
      ObjectDelete(0,"Predict2");

      //---

      if(Universe_Dir==OP_BUY)
        {
         MarkStart=MarkDW[0];
         MarkStart_Date=MarkDW_Date[0];

         MarkArea=MarkUP[0];

         if(Universe_Origin==OP_BUY)
           {
            double   m=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(Universe_Origin),0));
            RR_Price=Trend_getBreakPrice(m,MarkStart_Date,MarkStart,TimeCurentBar);
            TrendCreate(0,"Predict",0,MarkStart_Date,MarkStart,TimeCurentBar,RR_Price,clrYellow,0,1,false,false,false,false,0);
            //---
           }
         if(Universe_Origin==OP_SELL)
           {
            double   m=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(Universe_Origin),0));
            RR_Price=Trend_getBreakPrice(m,MarkStart_Date,MarkStart,TimeCurentBar);
            TrendCreate(0,"Predict",0,MarkStart_Date,MarkStart,TimeCurentBar,RR_Price,
                        clrYellow,0,1,false,false,false,false,0);
            //---
            double   m2=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(OP_BUY),0));
            RR_Price2=Trend_getBreakPrice(m2,MarkStart_Date,MarkStart,TimeCurentBar);
            TrendCreate(0,"Predict2",0,MarkStart_Date,MarkStart,TimeCurentBar,RR_Price2,
                        clrMagenta,0,1,false,false,false,false,0);

           }
         if(Universe_Origin==-1)
           {
            RR_Price=0;
           }
        }
      if(Universe_Dir==OP_SELL)
        {

         MarkArea=MarkDW[0];

         if(Universe_Origin==OP_BUY)
           {
            MarkStart=MarkUP[0];
            MarkStart_Date=MarkUP_Date[0];

            double   m=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(OP_BUY),0));
            RR_Price=Trend_getBreakPrice(m,MarkStart_Date,MarkStart,TimeCurentBar);
            TrendCreate(0,"Predict",0,MarkStart_Date,MarkStart,TimeCurentBar,RR_Price,
                        clrYellow,0,1,false,false,false,false,0);
            //---
            RR_Price2=Trend_getBreakPrice(m*(-1),MarkDW_Date[0],MarkDW[0],TimeCurentBar);
            TrendCreate(0,"Predict2",0,MarkDW_Date[0],MarkDW[0],TimeCurentBar,RR_Price2,
                        clrMagenta,0,1,false,false,false,false,0);

           }
         if(Universe_Origin==OP_SELL)
           {
            MarkStart=MarkUP[1];
            MarkStart_Date=MarkUP_Date[1];

            double   m=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(OP_BUY),0));
            RR_Price=Trend_getBreakPrice(m,MarkStart_Date,MarkStart,TimeCurentBar);
            TrendCreate(0,"Predict",0,MarkStart_Date,MarkStart,TimeCurentBar,RR_Price,
                        clrYellow,0,1,false,false,false,false,0);
            //---
            RR_Price2=Trend_getBreakPrice(m*(-1),MarkDW_Date[0],MarkDW[0],TimeCurentBar);
            TrendCreate(0,"Predict2",0,MarkDW_Date[0],MarkDW[0],TimeCurentBar,RR_Price2,
                        clrMagenta,0,1,false,false,false,false,0);
           }
         if(Universe_Origin==-1)//Almost
           {
            RR_Price=0;
           }
        }
      if(Universe_Dir==-1)
        {

         double   mH,mL;

         mH=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(OP_SELL),0));
         mL=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(OP_BUY),0));

         RR_Price=Trend_getBreakPrice(mL,MarkUP_Date[0],MarkUP[0],TimeCurentBar);
         TrendCreate(0,"Predict",0,MarkUP_Date[0],MarkUP[0],TimeCurentBar,RR_Price,
                     clrYellow,0,1,false,false,false,false,0);
         //---
         RR_Price2=Trend_getBreakPrice(mH,MarkDW_Date[0],MarkDW[0],TimeCurentBar);
         TrendCreate(0,"Predict2",0,MarkDW_Date[0],MarkDW[0],TimeCurentBar,RR_Price2,
                     clrMagenta,0,1,false,false,false,false,0);

        }
/*HLineCreate(0,"MarkDW","",0,MarkDW[1],
                  clrRed,2,1,false,true,false,false,0);*/

      HLineCreate(0,"ScopeFollow","",0,MarkArea,
                  clrWhite,2,1,false,true,false,false,0);
                  
      HLineCreate(0,"RR_Price","",0,RR_Price,
                  clrYellow,2,1,false,true,false,false,0);

      HLineCreate(0,"RR_Price2","",0,RR_Price2,
                  clrMagenta,2,1,false,true,false,false,0);
/*VLineCreate(0,"MarkNew_Date",0,MarkNew_Date,
                  clrRed,2,1,false,false,false,false,0);*/
      //+------------------------------------------------------------------+
      if(OrderGetPriceWeight(OP_BUY,0,0))
        {
         HLineCreate(0,"RTP_BUY","",0,PriceWeight,clrRoyalBlue,0,1,false,true,false,false,0);
         //RP_Buy=PriceWeight;

        }
      else
         ObjectDelete(0,"RTP_BUY");
      if(OrderGetPriceWeight(OP_SELL,0,0))
        {
         HLineCreate(0,"RTP_SEL","",0,PriceWeight,clrTomato,0,1,false,true,false,false,0);
         // RP_Sell=PriceWeight;
        }
      else
         ObjectDelete(0,"RTP_SEL");
      //+------------------------------------------------------------------+

     }
//+------------------------------------------------------------------+
//--- Lightning
//+------------------------------------------------------------------+
   Lightning();
//+------------------------------------------------------------------+
//--- OrderCutProfits
//+------------------------------------------------------------------+
     {
      //_MODE_SWAPLONG
      //_MODE_SWAPSHORT

/* ForDayTrade
    if(Bid-TCCI>=350*Point)//Signal Buy
        {
         Order_CloseAll_byProfit(OP_SELL,0);
        }
      if(TCCI-Ask>=350*Point)//Signal Sell
        {
         Order_CloseAll_byProfit(OP_BUY,0);
        }
        */

      if(Universe_Dir==OP_BUY)
        {
         if(Universe_Origin==OP_BUY)
           {

           }
         if(Universe_Origin==OP_SELL)
           {
            if(Bid<RR_Price)
              {
               //Order_CloseAll_byProfit(OP_BUY,0);
              }
           }
         if(Universe_Origin==-1)
           {
           }
        }
      if(Universe_Dir==OP_SELL)
        {
         if(Universe_Origin==OP_BUY)
           {

           }
         if(Universe_Origin==OP_SELL)
           {

           }
         if(Universe_Origin==-1)
           {

           }
        }
     }
//---

   CMM1+=CMM_+"TTCI: "+TCCI;
   CMM1+=CMM_+"Lightning: "+Lightning_High+"h | "+Lightning_Low+"l "+Lightning_Chk;
   CMM1+=CMM_;
   Comment(CMM1+CMM2);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   OnTick();
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

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double z(double v)
  {
   if(v==EMPTY_VALUE)
      return 0;
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order_Lot(double n)
  {
   return NormalizeDouble(lots*(1+n),2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderSend_1(int OP_DIR,double lot,double SL,double TP,int Magic,string OP_CM)
  {
   double OP=-1;
   if(OP_DIR==OP_BUY)
     {
      OP=Ask;
      if(TP>0)    TP=NormalizeDouble(OP+TP*Point,Digits);
      if(SL>0)    SL=NormalizeDouble(OP-SL*Point,Digits);
     }
   if(OP_DIR==OP_SELL)
     {
      OP=Bid;
      if(TP>0) TP=NormalizeDouble(OP-TP*Point,Digits);
      if(SL>0) SL=NormalizeDouble(OP+SL*Point,Digits);
     }
   if(Univese_Agree)
     {
      int res=OrderSend(Symbol(),OP_DIR,lot,OP,10,SL,TP,TAGORDER_NAME+":"+OP_CM,Magic);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderGetNearby(int OP_DIR,int Magic)
  {
   double OpenPrice=-1;
   if(OP_DIR==OP_BUY) OpenPrice=Ask;
   if(OP_DIR==OP_SELL) OpenPrice=Bid;
//---
   bool r=false;
   int CountFriend=0;
   int CountFamily=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(/*OrderMagicNumber()!=Magic && */
         OrderSymbol()!=Symbol() && 
         OrderType()!=OP_DIR) continue;
      CountFamily++;
      if(MathAbs(OpenPrice-OrderOpenPrice())<=(OrderNearbyArea*Point))
        {
         CountFriend++;
        }
     }
//     
   bool RP=false;
   OrderGetPriceWeight(OP_DIR,0,0);
   if(OP_DIR==OP_BUY && PriceWeight>OpenPrice)     RP=true;
   if(OP_DIR==OP_SELL && PriceWeight<OpenPrice)    RP=true;
//   
   if(
      ((CountFamily>=1 && CountFriend<OrderNearbyFriend)) || 
      (CountFamily<1)
      )
      r=true;
   return r;
  }
double PriceWeight=0;
double PriceWeightTP=0;
double PriceWeightSL=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderGetPriceWeight(int OP_DIR,double TP,double SL)
  {
   int Count=0;
   double Product=0,Weight=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderType()==OP_DIR)
        {
         Count++;
         Product+=OrderOpenPrice()*OrderLots();
         Weight+=OrderLots();
        }
     }
//---
   if(Count>0)
     {
      PriceWeight=NormalizeDouble(Product/Weight,Digits);
      //---
      if(OP_DIR==OP_BUY)
        {
         if(TP>0) PriceWeightTP=NormalizeDouble(PriceWeight+((TP/Count)*Point),Digits);   else PriceWeightTP=0;
         if(SL>0) PriceWeightSL=NormalizeDouble(PriceWeight-(SL*Point),Digits);           else PriceWeightSL=0;
        }
      if(OP_DIR==OP_SELL)
        {
         if(TP>0) PriceWeightTP=NormalizeDouble(PriceWeight-((TP/Count)*Point),Digits);   else PriceWeightTP=0;
         if(SL>0) PriceWeightSL=NormalizeDouble(PriceWeight+(SL*Point),Digits);           else PriceWeightSL=0;
        }
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll_byProfit(int OP_DIR,int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)==false) && 
         (OrderSymbol()!=Symbol()) && 
         (OrderType()!=OP_DIR)
         /*(OrderMagicNumber()!=Magic)*/)
         continue;
      if(OrderProfit()>0)
        {
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
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll(int OP_DIR,int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)==false) && 
         (OrderSymbol()!=Symbol()) && 
         (OrderType()!=OP_DIR) && 
         (OrderMagicNumber()!=Magic))
         continue;
      ORDER_TICKET_CLOSE[pos]=OrderTicket();
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
int getIndex(double OP)
  {
   if(OP==OP_BUY)
     {
      return 12;
     }
   return 9;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Trend_getBreakPrice(double m,datetime StartDate,double StartPrice,datetime EndTime)
  {

   int x1,x2,y1,y2;

   ChartTimePriceToXY(0,0,StartDate,StartPrice,x1,y1);
   ChartTimePriceToXY(0,0,EndTime,0,x2,y2);

   y2=int(m*(x1-x2)+y1);
   printf(y1);
//---
   double RR_Price_R;
   int RR_Sub;
   ChartXYToTimePrice(0,x2,y2,RR_Sub,EndTime,RR_Price_R);
   RR_Price_R=NormalizeDouble(RR_Price_R,Digits);
//      
   return RR_Price_R;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Univese_Agree=false;
double   M_High,M_Low;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Univese_AgreeChk(int P)
  {
   M_High=z(iCustom(Symbol(),Period(),PathFile,P,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(OP_SELL),0));
   M_Low=z(iCustom(Symbol(),Period(),PathFile,P,BackstepRate,0,M_CALLCANDLE_OC,false,getIndex(OP_BUY),0));
   M_High=MathArctan(M_High)*(180/M_PI);
   M_Low=MathArctan(M_Low)*(180/M_PI);
   Univese_Agree=false;
   if(
      MathAbs(M_High-M_Low)<10 && 
      (M_High<=-15 || M_High>=15) && 
      (M_Low<=-15 || M_Low>=15)
      )
     {
      Univese_Agree=true;
     }
   return Univese_Agree;
  }
//+------------------------------------------------------------------+
void Lightning()
  {
   double Lightning=z(iCustom(Symbol(),Period(),PathFile,Universe_Gear,BackstepRate,0,M_CALLCANDLE_OC,false,0,0));
   if(Lightning>0)
     {
      if(Lightning_Chk)
        {
         if(Universe_Origin==OP_BUY)
           {
            Lightning_High++;
            Lightning_Low=0;
           }
         if(Universe_Origin==OP_SELL)
           {
            Lightning_High=0;
            Lightning_Low++;
           }
         Lightning_Chk=false;
        }
     }
   else
     {
      Lightning_Chk=true;
     }
  }
//+------------------------------------------------------------------+
