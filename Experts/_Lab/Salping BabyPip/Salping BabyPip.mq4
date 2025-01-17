//+------------------------------------------------------------------+
//|                                              Salping BabyPip.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sChart
  {
private:
   int               cBar;
public:
   bool NewBars(int tf)
     {
      int Bar_=iBars(Symbol(),tf);
      if(cBar!=Bar_)
        {
         cBar=Bar_;
         return true;
        }
      return false;
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sPort
  {

   double            Capital;
   double            Bal;
   double            LotsStart;

   void setCapital(double lotstart)
     {
      Capital=AccountInfoDouble(ACCOUNT_BALANCE);
      LotsStart=lotstart;
     };
   double Lots()
     {
      Bal=AccountInfoDouble(ACCOUNT_BALANCE);
      return NormalizeDouble((LotsStart/Capital)*Bal,2);
      //return LotsStart;
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
sChart iChart;
sPort iPort;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
enum eOP
  {
   Dir_Buy=0,
   Dir_Sell=1,
   Dir_BuySell=2
  };

extern eOP eOP_=Dir_BuySell;
extern double LotStart=0.01;
extern double Buy_TP=90;
extern double Buy_SL=600;

extern double Sel_TP=90;
extern double Sel_SL=525;

extern double OrderNearbyArea=100;
extern double OrderNearbyFriend=1;

extern int Period_MA=388;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SCALEFIX,0,true);
   iPort.setCapital(LotStart);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string Cmm="",Cmm2="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   Cmm="";
   if(iChart.NewBars(Period()))
     {
      ObjectsDeleteAll(0,OBJ_ARROW);
      Cmm2="";
      double MACD_0=iMACD(Symbol(),Period(),3,48,12,PRICE_CLOSE,0,1);
      double MACD_1=iMACD(Symbol(),Period(),3,48,12,PRICE_CLOSE,1,1);

      Cmm2+="\n MACD: "+DoubleToStr(MACD_0,6)+" | "+DoubleToStr(MACD_1,6);
      double MA=iMA(Symbol(),Period(),Period_MA,0,0,0,1);
      bool bMA=false;
      if(Bid>MA)
        {
         bMA=true;
        }

        {//Sell High
         //double Sto_0_test,Sto_1_test;
         //string Sto_BufferBuy,Sto_BufferSell;
/*for(int i=0;i<3;i++)
           {
            Sto_0_test=iStochastic(Symbol(),Period(),5,3,3,MODE_SMA,0,0,i);
            Sto_1_test=iStochastic(Symbol(),Period(),5,3,3,MODE_SMA,0,1,i);
            if((Sto_0_test<=20) && (Sto_1_test<=20))
               Sto_BufferBuy+="0";
            else
               Sto_BufferBuy+="1";
            //               
            if((Sto_0_test>=80) && (Sto_1_test>=80))
               Sto_BufferSell+="0";
            else
               Sto_BufferSell+="1";

           }*/
         //Cmm2+="\n Sto_BufferBuy: "+Sto_BufferBuy;
         //Cmm2+="\n Sto_BufferSel: "+Sto_BufferSell;

         //  
         // if(false)
           {
/*bool bSto_Buy=false;
            if(Sto_BufferBuy=="001")
              {
               bSto_Buy=true;
              }*/
            bool bMACD_Buy=(MACD_0>0) && (MACD_1>0) && (MACD_1<MACD_0);

            if((eOP_==0 || eOP_==2) && bMACD_Buy/* && bSto_Buy */ && bMA && OrderGetNearby(OP_BUY))
              {
               OrderSend_(OP_BUY,iPort.Lots(),Buy_TP,Buy_SL,0,"Buy High");
              }
           }
         //    
         //if(false)
           {
/*bool bSto_Sel=false;
            if(Sto_BufferSell=="001")
              {
               bSto_Sel=true;
              }*/
            bool bMACD_Sel=(MACD_0<0) && (MACD_1<0) && (MACD_1>MACD_0);

            if((eOP_==1 || eOP_==2) && bMACD_Sel/* && bSto_Sel*/ && !bMA && OrderGetNearby(OP_SELL))
              {
               OrderSend_(OP_SELL,iPort.Lots(),Sel_TP,Sel_SL,0,"Sell High");
              }

           }
        }
     }
//---
//for(int i=0;i<1000;i++)
     {

     }
//---
   string CmmBuddy="";
/* for(int i=0;i<ArraySize(Order_Buddy)/2;i++)
     {
      CmmBuddy+="\n"+Order_Buddy[i][0]+"|"+Order_Buddy[i][1];
     }*/
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderProfit()>0 && OrderOpenPrice()!=OrderStopLoss())
        {
         bool mof=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
         if(mof)
           {
            for(int i=0;i<ArraySize(Order_Buddy)/2;i++)
              {
               if(Order_Buddy[i][0]==OrderTicket())
                 {
                  bool del=OrderDelete(Order_Buddy[i][1]);
                  Order_Buddy[i][0]=0;
                  Order_Buddy[i][1]=0;
                 }
              }
           }
        }
     }

//     
   bool OrderFound=false,Def=false;
   for(int i=0;i<ArraySize(Order_Buddy)/2;i++)
     {
      OrderFound=false;
      if(Order_Buddy[i][0]!=0)
        {
         for(int pos=0;pos<OrdersTotal();pos++)
           {
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
            if(OrderSymbol()!=Symbol()) continue;
            if(Order_Buddy[i][0]==OrderTicket())
              {
               OrderFound=true;
               break;
              }
           }
         if(!OrderFound)
           {
            bool del=OrderDelete(Order_Buddy[i][1]);
            if(!del)
              {
               Order_Buddy[i][0]=0;
               Order_Buddy[i][1]=0;
               Def=true;
              }
            else
              {
               //ลูกกำพร้า
              }

           }
         else
           {

           }
        }
     }
   if(Def)
     {
      int Dump[1][2],j=0;
      for(int i=0;i<ArraySize(Order_Buddy)/2;i++)
        {
         if(Order_Buddy[i][0]!=0)
           {
            Dump[j][0]=Order_Buddy[i][0];
            Dump[j][1]=Order_Buddy[i][1];
            j++;
            ArrayCopy(Dump,Dump,ArraySize(Dump),0,0);
           }
        }
      ArrayResize(Order_Buddy,0,0);
      ArrayCopy(Order_Buddy,Dump,0,0,0);
     }

   Comment(Cmm+Cmm2+CmmBuddy);
  }
int Order_Buddy[1][2];
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
double _STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderSend_(int OP_DIR,double lot,double TP,double SL,int Magic,string OP_CM)
  {
   double OP=-1;

   TP=(TP*Point);
   SL=(SL*Point);

   int Mother,Baby;
   double Stoplevel=_STOPLEVEL*Point;
   if(OP_DIR==OP_BUY)
     {
      OP=Ask;
      if(TP>0) TP=NormalizeDouble(OP+TP,Digits);
      if(SL>0) SL=NormalizeDouble(OP-SL,Digits);

      double d=MathAbs(OP-SL);
      double Rate=Stoplevel/d;

      double Lv=(1/Rate)+1;

      double OP_Fix=NormalizeDouble(SL+Stoplevel,Digits);

      Mother=OrderSend(Symbol(),OP_DIR,lot,OP,10,SL,TP,"BabyPip:"+OP_CM,Magic);
      Baby=OrderSend(Symbol(),OP_SELLSTOP,NormalizeDouble(lot*(Lv*1.1),2),OP_Fix,10,0,SL,"BabyPip:"+OP_CM,Magic);

      int Dump[1][2];
      Dump[0][0]=Mother;
      Dump[0][1]=Baby;
      ArrayCopy(Order_Buddy,Dump,ArraySize(Order_Buddy),0,0);

     }
   if(OP_DIR==OP_SELL)
     {
      OP=Bid;
      if(TP>0) TP=NormalizeDouble(OP-TP,Digits);
      if(SL>0) SL=NormalizeDouble(OP+SL,Digits);

      double d=MathAbs(OP-SL);
      double Rate=Stoplevel/d;

      double Lv=(1/Rate)+1;

      double OP_Fix=NormalizeDouble(SL-Stoplevel,Digits);

      Mother=OrderSend(Symbol(),OP_DIR,lot,OP,10,SL,TP,"BabyPip:"+OP_CM,Magic);
      Baby=OrderSend(Symbol(),OP_BUYSTOP,NormalizeDouble(lot*(Lv*1.1),2),OP_Fix,10,0,SL,"BabyPip:"+OP_CM,Magic);

      int Dump[1][2];
      Dump[0][0]=Mother;
      Dump[0][1]=Baby;
      ArrayCopy(Order_Buddy,Dump,ArraySize(Order_Buddy),0,0);
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderGetNearby(int OP_DIR)
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
   if(
      ((CountFamily>=1 && CountFriend<OrderNearbyFriend)) || 
      (CountFamily<1)
      )
      r=true;
   return r;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
