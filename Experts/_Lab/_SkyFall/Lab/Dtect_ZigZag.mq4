//+------------------------------------------------------------------+
//|                                                 Dtect_ZigZag.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "lapukdee @2019"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
string TAGORDER_NAME="Skyfalls";
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern double     lots=0.02;    // Depth 1%;200
extern int        Depth=24;    // Depth
extern double     BackstepRate=90;  // BackstepRate

extern double     OrderNearbyArea=50;
extern double     OrderNearbyFriend=1;

extern bool       UseTP_RP=false;

string PathFile="My/ZigZag";
#include "SkyFallz_Struct.mqh"
sACCOUNT D;

int nBar=0;
string CMM="",CMM2="";
//---
double Polaris[4];
double Lion[4];
datetime Polaris_Date[4];
datetime Lion_Date[4];

datetime Polaris_DateSave;
datetime Lion_DateSave;

int Universe=-1;
int Universe2=-1;
double UniverseGear2=-1;
//double Elysium=0;
int Earth=-1;

double Star_of_Im=0;

double Angel=0;
double AngelPrice=-1;
bool AngelChk=true;
//---
double OP_Price=0;
double RP_Buy=-1;
double RP_Sell=-1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);

   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_SCALEFIX,0,IsVisualMode());
     {
/*string name="panel";
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,-140);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,-87);
      ObjectSetString(0,name,OBJPROP_TEXT,"n");
      ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrMidnightBlue);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,300);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);*/
     }
   OnTick();
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
void OnTimer()
  {
   CMM="";
//---  
   CMM+="\n                     Balance: "+D.iBalance();
   CMM+="\n                     Holding: "+DoubleToStr(D.Holding,2)+" | "+DoubleToStr(D.getHoldingP(),2)+"%";
   D.iPort();
   CMM+="\n                     Lot_ [ "+D.iOrdersTotals()+" ]: "+D.iLots();
   CMM+="\n                     LotB [ "+D.iOrdersTotalBuy()+" ]: "+D.iLotsBuy();
   CMM+="\n                     LotS [ "+D.iOrdersTotalSell()+" ]: "+D.iLotsSell();
   CMM+="\n                     --- Stat ---";
   CMM+="\n                     MaxDD: "+DoubleToStr(D.getMaxDD(),2);
   CMM+="\n                     -------------------------------------";

   if(OrderGetPriceWeight(OP_BUY,0,0))
     {
      HLineCreate(0,"RTP_BUY","",0,PriceWeight,clrRoyalBlue,0,1,false,true,false,false,0);
      RP_Buy=PriceWeight;

     }
   else
      ObjectDelete(0,"RTP_BUY");
   if(OrderGetPriceWeight(OP_SELL,0,0))
     {
      HLineCreate(0,"RTP_SEL","",0,PriceWeight,clrTomato,0,1,false,true,false,false,0);
      RP_Sell=PriceWeight;
     }
   else
      ObjectDelete(0,"RTP_SEL");

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
            if(Universe==-1)
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
   UniverseGear2=Depth;
   if(Universe==-1)
     {
      int Level=10;
      int Leve_Temp=0;
      for(int i=0;i<Level;i++)
        {
         UniverseGear2*=0.5;

         UniverseGear2=int(UniverseGear2);

         Universe2=int(z(iCustom(Symbol(),Period(),PathFile,UniverseGear2,BackstepRate,0,M_CALLCANDLE_OC,false,7,0)));

         if(Universe2>=0)
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
//---Angel
   double DUMP_Angel=Angel;//
   double DUMP_AngelPrice=z(iCustom(Symbol(),Period(),PathFile,UniverseGear2,BackstepRate,0,M_CALLCANDLE_OC,false,0,0));
   if(DUMP_AngelPrice>0)
     {
      if(AngelChk)
        {
         //AngelPrice=Bid;
         DUMP_Angel++;
         AngelChk=false;

         if(MathMin(Lion[0],Lion[1])>=DUMP_AngelPrice &&
            MathMax(Lion[0],Lion[1])<=DUMP_AngelPrice )
           {
            AngelPrice=OP_SELL;
           }

         if(MathMin(Polaris[0],Polaris[1])>=DUMP_AngelPrice &&
            MathMax(Polaris[0],Polaris[1])<=DUMP_AngelPrice)
           {
            AngelPrice=OP_BUY;
           }
         //HLineCreate(0,"AngelPrice","",0,AngelPrice,
         //            clrWhite,2,1,false,true,false,false,0);
        }
     }
   else
     {
      AngelChk=true;
     }
//---
   if(!AngelChk)
     {
      Angel=DUMP_Angel;
      //---
      if(Angel>=10)
        {
         if(Universe2==OP_SELL && OrderGetNearby(OP_SELL,ORDER_UniCROSS_TF))
           {
            //OrderSend_(OP_SELL,Order_GetLot(D.OrdersTotalSell),0,0,ORDER_UniCROSS_TF,"");
           }
         if(Universe2==OP_BUY && OrderGetNearby(OP_BUY,ORDER_UniFOLLOW_TF))
           {
            //OrderSend_(OP_BUY,Order_GetLot(D.OrdersTotalBuy),0,0,ORDER_UniFOLLOW_TF,"");
           }
        }
     }
   else
     {
      if(Universe2==OP_SELL && OrderGetNearby(Universe2,ORDER_UniCROSS_TF))
        {
         OrderSend_(Universe2,Order_GetLot(D.OrdersTotalBuy),0,0,ORDER_UniCROSS_TF,"");
        }
      if(Universe2==OP_BUY && OrderGetNearby(Universe2,ORDER_UniFOLLOW_TF))
        {
         OrderSend_(Universe2,Order_GetLot(D.OrdersTotalSell),0,0,ORDER_UniFOLLOW_TF,"");
        }
     }
   CMM+="\n                     Angel_1: "+Angel+" | "+AngelPrice+" | "+AngelChk;
   CMM+="\n                     *";
   CMM+="\n                     Star_of_Im: "+Star_of_Im;
//CMM+="\n                     Earth : "+DoubleToStr(Earth,Digits);
//---
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(nBar!=Bars)
     {
      CMM2="";
      nBar=Bars;
      //ObjectsDeleteAll_();
      //---
      double d=-1;
      for(int i=0;i<3;i++)
        {
         Polaris[i]=z(iCustom(Symbol(),Period(),PathFile,UniverseGear2,BackstepRate,0,M_CALLCANDLE_OC,false,10,i));
         d=z(iCustom(Symbol(),Period(),PathFile,UniverseGear2,BackstepRate,0,M_CALLCANDLE_OC,false,11,i));
         Polaris_Date[i]=iTime(Symbol(),Period(),int(d));

         Lion[i]=z(iCustom(Symbol(),Period(),PathFile,UniverseGear2,BackstepRate,0,M_CALLCANDLE_OC,false,13,i));
         d=z(iCustom(Symbol(),Period(),PathFile,UniverseGear2,BackstepRate,0,M_CALLCANDLE_OC,false,14,i));
         Lion_Date[i]=iTime(Symbol(),Period(),int(d));
        }
      Earth=int(z(iCustom(Symbol(),Period(),PathFile,Depth,BackstepRate,0,M_CALLCANDLE_OC,false,8,0)));
      //---
      if(Polaris_DateSave!=Polaris_Date[0] || 
         Lion_DateSave!=Lion_Date[0])
        {
         Polaris_DateSave=Polaris_Date[0];
         Lion_DateSave=Lion_Date[0];

         Angel=0;
         AngelPrice=-1;
         AngelChk=true;
        }

      double x=1;  if(Polaris[0]-Polaris[1]<0) x=-1;
      Polaris[3]=MathMax(Polaris[0],Polaris[1])*x;
      x=1;  if(Lion[0]-Lion[1]<0) x=-1;
      Lion[3]=MathMax(Lion[0],Lion[1])*x;

      //+-------------------------------+
      double New_Price;
      datetime New_Date;
      TrendCreate(0,"TrendUP",0,Polaris_Date[0],Polaris[0],Polaris_Date[1],Polaris[1],clrRed,0,1,false,false,false,false,0);
      TrendCreate(0,"TrendDW",0,Lion_Date[0],Lion[0],Lion_Date[1],Lion[1],clrDodgerBlue,0,1,false,false,false,false,0);

/* if(Earth==OP_BUY)
        {
         if(Universe2==OP_BUY)
           {
            TrendCreate(0,"TrendUP",0,Polaris_Date[0],Polaris[0],Polaris_Date[1],Polaris[1],clrRed,0,1,false,false,false,false,0);
            TrendCreate(0,"TrendDW",0,Lion_Date[0],Lion[0],Lion_Date[1],Lion[1],clrDodgerBlue,0,1,false,false,false,false,0);
            //
            datetime New_Date=Polaris_Date[1]+(Lion_Date[0]-Lion_Date[1]);
            double New_Price=Lion[0]+(Polaris[1]-Lion[1]);

            TrendCreate(0,"TrendDW2",0,Polaris_Date[1],Polaris[1],New_Date,New_Price,clrDodgerBlue,2,1,false,false,false,false,0);

            HLineCreate(0,"TTT","",0,New_Price,
                        clrRed,2,1,false,true,false,false,0);
            VLineCreate(0,"TTTT",0,New_Date,
                        clrRed,2,1,false,false,false,false,0);

           }
         else
           {
            TrendCreate(0,"TrendUP",0,Polaris_Date[0],Polaris[0],Polaris_Date[1],Polaris[1],clrRed,0,1,false,false,false,false,0);
            TrendCreate(0,"TrendDW",0,Lion_Date[0],Lion[0],Lion_Date[1],Lion[1],clrDodgerBlue,0,1,false,false,false,false,0);
            //
            datetime New_Date=Polaris_Date[0]+(Lion_Date[0]-Lion_Date[1]);
            double New_Price=Lion[0]+(Polaris[0]-Lion[1]);
            TrendCreate(0,"TrendDW2",0,Polaris_Date[0],Polaris[0],New_Date,New_Price,clrDodgerBlue,2,1,false,false,false,false,0);

            HLineCreate(0,"TTT","",0,New_Price,
                        clrRed,2,1,false,true,false,false,0);
            VLineCreate(0,"TTTT",0,New_Date,
                        clrRed,2,1,false,false,false,false,0);
           }
         //---
        }
      else
        {

        }
*/
      //+------------------------------------------------------------------+
      //---OrderSend
      //+------------------------------------------------------------------+
      Universe=int(z(iCustom(Symbol(),Period(),PathFile,UniverseGear2,BackstepRate,0,M_CALLCANDLE_OC,false,7,0)));
      if(Universe==OP_SELL)
        {
         //----------------------------
         if(Earth==OP_SELL && OrderGetNearby(Earth,ORDER_UniFOLLOW_TF) && OP_Price<MathAbs(Polaris[3]))
           {
            //OrderSend_(Earth,Order_GetLot(D.OrdersTotalSell),0,0,ORDER_UniFOLLOW_TF,"");
           }
         if(Earth==OP_BUY && OrderGetNearby(Earth,ORDER_UniCROSS_TF) && OP_Price>MathAbs(Lion[3]))
           {
            //OrderSend_(Earth,Order_GetLot(D.OrdersTotalBuy),0,0,ORDER_UniCROSS_TF,"");
           }
         //----------------------------

        }
      //        
      if(Universe==OP_BUY)
        {
         if(Earth==OP_BUY && OrderGetNearby(Earth,ORDER_UniFOLLOW_TF) && OP_Price>MathAbs(Lion[3]))
           {
            //OrderSend_(Earth,Order_GetLot(D.OrdersTotalBuy),0,0,ORDER_UniFOLLOW_TF,"");
           }
         if(Earth==OP_SELL && OrderGetNearby(Earth,ORDER_UniCROSS_TF) && OP_Price<MathAbs(Polaris[3]))
           {
            //OrderSend_(Earth,Order_GetLot(D.OrdersTotalSell),0,0,ORDER_UniCROSS_TF,"");
           }
        }
      //        
      if(Universe==-1)
        {

        }
      //+------------------------------------------------------------------+
      //---UseTP_RP
      //+------------------------------------------------------------------+
      if(UseTP_RP)
        {
         if(OrderGetPriceWeight(OP_BUY,OrderNearbyArea,0))
           {
            for(int pos=0;pos<OrdersTotal();pos++)
              {
               if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
               if(OrderType()==OP_BUY)
                 {
                  if(OrderTakeProfit()!=PriceWeightTP)
                    {
                     bool res=OrderModify(OrderTicket(),OrderOpenPrice(),PriceWeightSL,PriceWeightTP,0);
                    }
                 }
              }
           }
         //---
         if(OrderGetPriceWeight(OP_SELL,OrderNearbyArea,0))
           {
            for(int pos=0;pos<OrdersTotal();pos++)
              {
               if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
               if(OrderType()==OP_SELL)
                 {
                  if(OrderTakeProfit()!=PriceWeightTP)
                    {
                     bool res=OrderModify(OrderTicket(),OrderOpenPrice(),PriceWeightSL,PriceWeightTP,0);
                    }
                 }
              }
           }
        }//UseTP_RP
      //+------------------------------------------------------------------+

     }//bBar

   CMM+="\n                     Universe : "+Universe;
   CMM+="\n                     Universe2 : "+Universe2+" Gear: "+UniverseGear2;
   CMM+="\n                     Earth : "+Earth;
   CMM+="\n                     ---";
   CMM+="\n                     Polaris : "+DoubleToStr(Polaris[3],Digits);
   CMM+="\n                     Lion : "+DoubleToStr(Lion[3],Digits);

//---
   Comment(CMM+CMM2);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   OnTimer();
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
   if(id==CHARTEVENT_KEYDOWN)
     {
      Print("The "+string(lparam)+" has been pressed");
      switch(int(lparam))
        {
         case 220://|
           {
            ChartSetInteger(0,CHART_SCALEFIX,0,!ChartGetInteger(0,CHART_SCALEFIX,0));
            break;
           }
        }
     }
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
void ObjectsDeleteAll_()
  {
   ObjectsDeleteAll(0,OBJ_ARROW);
//ObjectsDeleteAll(0,OBJ_TREND);
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
   if(OP_DIR==OP_SELL && PriceWeight<OpenPrice)   RP=true;
//   
   if(
      ((CountFamily>=1 && CountFriend<OrderNearbyFriend) && RP) || 
      (CountFamily<1)
      )
      r=true;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
double Order_GetLot(double n)
  {

   return NormalizeDouble(lots,2);
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
//|                                                                  |
//+------------------------------------------------------------------+
void OrderSend_(int OP_DIR,double lot,double SL,double TP,int Magic,string OP_CM)
  {
   double OP=-1;
   if(OP_DIR==OP_BUY) OP=Ask;
   if(OP_DIR==OP_SELL) OP=Bid;
   int res=OrderSend(Symbol(),OP_DIR,lot,OP,10,SL,TP,TAGORDER_NAME+":"+OP_CM,Magic);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrLineSon(double v)
  {
   color r=clrRoyalBlue;
   if(v<0)
      r=clrTomato;
   return r;
  }
//+------------------------------------------------------------------+
