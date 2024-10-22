//|                                                    iExposure.mq4 |
//|                   Copyright 2007-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |

#property copyright "2007-2014, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#include <Tools/Method_Tools.mqh>
//---for ExtSymbols
#define symbolname     0
#define comment       1
//---for ExtSymbolsSummaries
#define SYMBOLS_MAX 1024
#define DEALS          0
#define BUY_LOTS       1
#define BUY_PRICE      2
#define SELL_LOTS      3
#define SELL_PRICE     4
#define NET_LOTS       5
#define PROFIT         6

#define BUY_PROFIT     7
#define SELL_PROFIT    8

#define BUY_DEALS      9
#define SELL_DEALS     10

#define BUY_HavePositive  11
#define SEL_HavePositive  12
#define BUY_HaveNegative  13
#define SEL_HaveNegative  14

#define BUY_HavePositive_Point  15
#define SEL_HavePositive_Point  16
#define BUY_HaveNegative_Point  17
#define SEL_HaveNegative_Point  18
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _enum_setTemplate
  {
   A=0,// Normal
   B=1,// Bridge
   C=2,// None
  };
input bool ShowWatchList=true;
input bool PriceAlert=true;
input _enum_setTemplate setTemplate_Mode=A;
extern int PeriodATR=14;
extern int PeriodRSI=14;

bool boolTemplate=true;
bool boolShowNews=true;

string ExtNameFull="Exposure-Divas ";
string ExtName="Ex-Divas ";
string ExtSymbols[SYMBOLS_MAX][2];
string ExtSymbolsP[SYMBOLS_MAX][2];
string ExtSymbolsN[SYMBOLS_MAX][2];
int    ExtSymbolsTotal=0;
int    ExtSymbolsTotalCntInfo=19;
double ExtSymbolsSummaries[SYMBOLS_MAX][19];
double ExtSymbolsSummaries_Temp[19];
double ExtSymbolsSummaries_TempP[SYMBOLS_MAX][19];
double ExtSymbolsSummaries_TempN[SYMBOLS_MAX][19];
int    ExtLines=-1;
string ExtCols[]=
  {
   "               Symbol",
   " "," ",
   "|","Buy","Lots","n","+/-",
   "|","Sell","Lots","n","+/-",
   "|","n","Net lots"," ","   NAV."," ","Comment"
  };
string ExtColsEnd[]=
  {
   "               Symbol",
   ".",".",
   "|","Buy","Lots","N","+/-",
   "|","Sell","Lots","N","+/-",
   "|","N","Net lots",".","   Profit"," ","Comment"
  };
int ExtShifts[]=
  {
   10,95,110,
   160,165,240,280,350,//240
   405,410,485,525,595,
   650,660,680,695,730,745,815
  };
int    ExtVertShift=17;
double ExtMapBuffer[];

int windex;
int cntM0,xcntM0;
double Market_mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE); //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
double Market_l=MarketInfo(Symbol(),MODE_LOTSIZE);
double _MODE_POINT=MarketInfo(Symbol(),MODE_POINT);
double Market_t=MarketInfo(Symbol(),MODE_TICKSIZE);
double _MODE_TICKVALUE=MarketInfo(Symbol(),MODE_TICKVALUE);
string _ActCurrency=" "+AccountCurrency();

double getLots=7;
//| Custom indicator initialization function                         |

void OnInit()
  {
   EventSetMillisecondTimer(1000);

   switch(setTemplate_Mode)
     {
      case  0:
        {
         setTemplate();
         boolTemplate=true;
         break;
        }
      case  1:
        {
         setTemplate_ToBridge();
         boolTemplate=false;
         break;
        }
      case  2:
        {
         //setTemplate_ToBridge();
         boolTemplate=false;
         break;
        }
      default:
         break;
     }

//ExtName="*";
   IndicatorShortName(ExtNameFull);
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexStyle(0,DRAW_NONE);
   IndicatorDigits(0);
   SetIndexEmptyValue(0,0.0);

   windex=WindowFind(ExtNameFull);
   printf("windex :"+string(windex));

   if(OrdersTotal()>0 || true)
     {
      _setBUTTON_StateHUB(windex,false);
     }

   cntM0=iBars(Symbol(),0);

   if(ShowWatchList)
     {
      //string buffSymbol[]={"GOLDmicro","AUDJPYmicro","GBPUSDmicro","USDJPYmicro","AUDCHFmicro"};
      string buffSymbol[]={"GOLD","EURUSD","USDJPY","GBPUSD","USDCHF","NZDUSD","CADJPY","USDCAD","AUDUSD"};

      ExtSymbolsTotal=ArraySize(buffSymbol);
      for(int i=0;i<ExtSymbolsTotal;i++)
        {
         for(int j=0;j<SymbolsTotal(true);j++)
           {
            if(StringFind(SymbolName(j,true),buffSymbol[i],0)>=0)
               buffSymbol[i]=SymbolName(j,true);
           }
        }

/*string buffSymbol[];
      ArrayResize(buffSymbol,SymbolsTotal(true),SymbolsTotal(true));
      for(int i=0;i<SymbolsTotal(true);i++)
        {
         buffSymbol[i]=SymbolName(i,true);
        }
*/
      int ExtSymbolsSub=0;
      ExtSymbolsTotal=ArraySize(buffSymbol);
      for(int i=0;i<ExtSymbolsTotal;i++)
        {
         if(StringLen(buffSymbol[i])>6)
            ExtSymbols[i][symbolname]=buffSymbol[i];
         else
            ExtSymbolsSub++;
        }
      ExtSymbolsTotal-=ExtSymbolsSub;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(),ExtName,0,OBJ_HLINE);

   windex=WindowFind(ExtNameFull);
   if(windex>0)
      ObjectsDeleteAll(windex);
   _setBUTTON_StateDelete(windex);

//--- destroy timer
   EventKillTimer();
  }
//| Custom indicator iteration function                              |
int total=0;
bool Timer=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTickTimer()
  {
   if(HealTick<=0)
      return "U";
//---
   if(Timer) Timer=false;
   else Timer=true;
//---
   if(Timer) return "Q";
   else return "R";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getHealTick()
  {

   if(HealTick>0)
     {
      HealTick--;
      return c(HealTick);
     }
   else return c(HealTick)+"X";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   DrawTextEnd(ExtName+"End_1",1,55);
   ObjectSetText(ExtName+"End_1","       "+getHealTick(),10,"Arial",clrDimGray);
   DrawTextEnd(ExtName+"End_2",2,55);
   ObjectSetText(ExtName+"End_2","   "+getTickTimer(),10,"Wingdings 3",clrDimGray);

//---
   if(HealTick>=0)
     {

      ChartRedraw();
      windex=WindowFind(ExtNameFull);
      //---
      if(PriceAlert)
        {
         if(NormalizeDouble(ObjectGetDouble(0,"Arrowa",OBJPROP_PRICE),Digits)==Bid)
           {
            SendNotification("PriceAlert : "+Symbol()+" Bid:"+cD(Bid,Digits));
           }
        }
      //---
      Calculator_Hege();
      Calculator_RulerBuySell();
      //---
      if(_iNewBar(0))
        {
         bool  _PlaySound=PlaySound("tick_01.wav");
        }
      //---

      string name;
      int    col,line;
      //----
      SymbolInfo();
      //---

      //if(windex<0)
      //return(rates_total);

      //----
      double SumCnt=0,SumProfit=0;
      int y_dist=70;
      bool boolSymbolCurrent=false;
      //---

      //ArrayInitialize(ExtSymbols,EMPTY_VALUE);

      total=Analyze();

      if(total>0 && windex>=0)
        {
         //---- header line
         if(ExtLines<0)
           {
            for(col=0; col<ArraySize(ExtShifts); col++)
              {
               name=ExtName+"Head_"+string(col);
               if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
                 {
                  ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
                  ObjectSet(name,OBJPROP_YDISTANCE,y_dist);
                  ObjectSetText(name,ExtCols[col],10,"Arial",clrWhite);

                  ObjectSetString(ChartID(),name,OBJPROP_TOOLTIP,name);
                  ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,false);
                  ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
                  //ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,true);
                 }
              }
            ExtLines=0;
           }
         line=0;
         boolSymbolCurrent=false;

         double buy_price=0,buy_DZP=0,buy_DZP_avg=0,buy_DZP_avgN=0;
         double sell_price=0,sell_DZP=0,sell_DZP_avg=0,sell_DZP_avgN=0;
         double NetLots=0;
         //---
         if(windex>0)
            ObjectsDeleteAll(ChartID(),ExtName+"Line_",0,OBJ_LABEL);
         //ObjectsDeleteAll(windex);

         //---

         for(int i=0; i<ExtSymbolsTotal; i++)
           {
            if(ExtSymbolsSummaries[i][DEALS]<0) continue;
            line++;
            //---- add line
            if(line>ExtLines)
              {
               y_dist+=ExtVertShift;
               for(col=0; col<ArraySize(ExtShifts); col++)
                 {
                  name=ExtName+"Line_"+string(line)+"_"+string(col);
                  if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
                    {
                     ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
                     ObjectSet(name,OBJPROP_YDISTANCE,y_dist);

                     ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,false);
                     ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
                     ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,true);
                    }
                 }
               ExtLines++;
              }
            //---- set line
            int LineC=-1;
            int digits=(int)MarketInfo(ExtSymbols[i][symbolname],MODE_DIGITS);
            double bid=MarketInfo(ExtSymbols[i][symbolname],MODE_BID);
            double ask=MarketInfo(ExtSymbols[i][symbolname],MODE_ASK);

            double buy_lots=ExtSymbolsSummaries[i][BUY_LOTS];
            double sell_lots=ExtSymbolsSummaries[i][SELL_LOTS];

            buy_price=0;buy_DZP=0;
            sell_price=0;sell_DZP=0;
            NetLots=0;

            if(buy_lots!=0)
              {
               buy_price=ExtSymbolsSummaries[i][BUY_PRICE]/buy_lots;
               buy_DZP=NormalizeDouble((bid-buy_price)*MathPow(10,digits),0);
               //Avg
               buy_DZP_avg+=(buy_DZP*buy_lots);
               buy_DZP_avgN+=buy_lots;
              }
            if(sell_lots!=0)
              {
               sell_price=ExtSymbolsSummaries[i][SELL_PRICE]/sell_lots;
               sell_DZP=NormalizeDouble((sell_price-ask)*MathPow(10,digits),0);
               //Avg
               sell_DZP_avg+=(sell_DZP*sell_lots);
               sell_DZP_avgN+=sell_lots;
              }
            //---
            double DayClose=iClose(ExtSymbols[i][symbolname],PERIOD_D1,1);
            double DayOpen=iOpen(ExtSymbols[i][symbolname],PERIOD_D1,1);
            double DayBarBody=DayClose-DayOpen;
            double symbolPoint=MathPow(10,MarketInfo(ExtSymbols[i][symbolname],MODE_DIGITS));

            double Strength=0;
            if(DayClose>0)
              {
               Strength=(MarketInfo(ExtSymbols[i][symbolname],MODE_BID)-DayClose)*symbolPoint;
              }

            string Arrow="q";
            color clrArrow=clrRed;
            if(Strength>0){ Arrow="p";clrArrow=clrLime;}

            double CurClose=iClose(ExtSymbols[i][symbolname],0,1);
            double CurStrength=0;
            if(CurClose>0)CurStrength=((MarketInfo(ExtSymbols[i][symbolname],MODE_BID)-CurClose)/CurClose)*10000;

            string ArrowCur="q";
            color clrArrowCur=clrRed;
            if(CurStrength>0){ ArrowCur="p";clrArrowCur=clrLime;}

            //---      
            double Profit=ExtSymbolsSummaries[i][PROFIT];
            SumProfit+=Profit;
            //---
            double comp_d=_CommaDecode(ObjectGetString(0,getNameObjet(line,18),OBJPROP_TEXT,0),2,"_");
            string Arrow2="q";
            color clrArrow2=clrRed;
            if(comp_d<Profit){Arrow2="p";clrArrow2=clrLime;}
            if(comp_d==Profit){Arrow2="1";clrArrow2=clrDimGray;}

            //---
            bool HaveLots=buy_lots>0 || sell_lots>0;
            double _DEALS=ExtSymbolsSummaries[i][DEALS];
            //---

            //***SymbolName
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,c(i+1)+"."+getSymbol(ExtSymbols[i][symbolname]),9,"Arial",getStrClrSymbolName(ExtSymbolsSummaries[i][PROFIT],HaveLots));

            ObjectSetString(ChartID(),name,OBJPROP_TOOLTIP,ExtSymbols[i][symbolname]);
            //***Arrow+Grow
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,Arrow,9,"Wingdings 3",clrArrow);
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,_CommaZero(Strength,0," ")+"p",9,"Arial",clrArrow);

            //***Buy Segment
            bool isbuy_lots=buy_lots>0;
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,"|",9,"Arial",clrWhite);
            LineC++;name=getNameObjet(line,LineC);
            string strHavePoint=getHavePoint(buy_DZP,ExtSymbolsSummaries[i][15],ExtSymbolsSummaries[i][17],buy_lots);
            ObjectSetText(name,/*DoubleToStr(buy_price,digits)+"|"+*/cD(buy_DZP,0)+"["+strHavePoint+"]",9,"Arial",getStrClrDZP(buy_DZP,isbuy_lots,Symbol()+" Buy"));
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,c(buy_lots,2),9,"Arial",getStrClrZero(buy_lots));

            LineC++;name=getNameObjet(line,LineC);
            double _HavePositive=ExtSymbolsSummaries[i][BUY_HavePositive];
            double _HaveNegative=ExtSymbolsSummaries[i][BUY_HaveNegative];
            ObjectSetText(name,c(ExtSymbolsSummaries[i][BUY_DEALS],0)+" ["+c(_HavePositive,0)+"|"+c(_HaveNegative,0)+"]",9,"Arial",getStrClrZero2(ExtSymbolsSummaries[i][BUY_DEALS],_HavePositive,_HaveNegative));

            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,c(ExtSymbolsSummaries[i][BUY_PROFIT],2),9,"Arial",getStrClr(ExtSymbolsSummaries[i][BUY_PROFIT],isbuy_lots,_DEALS));

            //***Sell Segment
            bool issell_lots=sell_lots>0;
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,"|",9,"Arial",clrWhite);
            LineC++;name=getNameObjet(line,LineC);
            strHavePoint=getHavePoint(sell_DZP,ExtSymbolsSummaries[i][SEL_HavePositive_Point],ExtSymbolsSummaries[i][SEL_HaveNegative_Point],sell_lots);
            ObjectSetText(name,/*DoubleToStr(sell_price,digits)+"|"+*/cD(sell_DZP,0)+"["+strHavePoint+"]",9,"Arial",getStrClrDZP(sell_DZP,issell_lots,Symbol()+" Sell"));
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,c(sell_lots,2),9,"Arial",getStrClrZero(sell_lots));

            LineC++;name=getNameObjet(line,LineC);
            _HavePositive=ExtSymbolsSummaries[i][SEL_HavePositive];
            _HaveNegative=ExtSymbolsSummaries[i][SEL_HaveNegative];
            ObjectSetText(name,c(ExtSymbolsSummaries[i][SELL_DEALS],0)+" ["+c(_HavePositive,0)+"|"+c(_HaveNegative,0)+"]",9,"Arial",getStrClrZero2(ExtSymbolsSummaries[i][SELL_DEALS],_HavePositive,_HaveNegative));

            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,c(ExtSymbolsSummaries[i][SELL_PROFIT],2),9,"Arial",getStrClr(ExtSymbolsSummaries[i][SELL_PROFIT],issell_lots,_DEALS));
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,"|",9,"Arial",clrWhite);

            //***Summary Segment
            //---N
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,DoubleToStr(_DEALS,0),9,"Arial",getStrClrZero2(_DEALS,_HavePositive,_HaveNegative));

            //--- Lots
            SumCnt+=ExtSymbolsSummaries[i][DEALS];
            LineC++;name=getNameObjet(line,LineC);
            if(_DEALS>0)
               ObjectSetText(name,ArrowCur,9,"Wingdings 3",clrArrowCur);
            else
               ObjectSetText(name,"",9,"Wingdings 3",clrDimGray);

            NetLots=NormalizeDouble(buy_lots-sell_lots,2);
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,c(NetLots,2),9,"Arial",getStrClrLots(NetLots,_DEALS));

            //--- Profits
            LineC++;name=getNameObjet(line,LineC);
            if(_DEALS>0)
               ObjectSetText(name,Arrow2,9,"Wingdings 3",clrArrow2);
            else
               ObjectSetText(name,"",9,"Wingdings 3",clrDimGray);

            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,_Comma(Profit,2,"_"),9,"Arial",getStrClr(ExtSymbolsSummaries[i][PROFIT],HaveLots,_DEALS));

            //---Comment
            LineC++;name=getNameObjet(line,LineC);
            ObjectSetText(name,ExtSymbols[line][comment],9,"Arial",getStrClr(ExtSymbolsSummaries[i][PROFIT],HaveLots,_DEALS));

            if(ExtSymbols[i][symbolname]==Symbol() && !boolSymbolCurrent)
              {
               boolSymbolCurrent=true;
               DrawText("ASymbol : ProfitArrow",Arrow2,9,"Wingdings 3",clrArrow2,CORNER_LEFT_LOWER,0,105,25,"");
               DrawText("ASymbol : Profit",_Comma(Profit,2,"_"),15,"Calibri",getStrClr(ExtSymbolsSummaries[i][PROFIT],HaveLots,_DEALS),CORNER_LEFT_LOWER,0,120,30,"");
               //---
              }
           }
         if(!boolSymbolCurrent)
           {
            ObjectDelete(ChartID(),": ASymbol : ProfitArrow");
            ObjectDelete(ChartID(),": ASymbol : Profit");
           }
         //---
         y_dist+=ExtVertShift*(ExtSymbolsTotal+1);
         int e;double AvgDZP=0;
         y_dist=55;

         e=0;
         name=ExtName+"End_"+string(e);
         DrawTextEnd(name,e,y_dist);
         ObjectSetText(name,AccountInfoString(ACCOUNT_NAME),10,"Arial",clrMagenta);

         if(buy_DZP_avgN>0)
           {
            e=3;
            name=ExtName+"End_"+string(e);
            DrawTextEnd(name,e,y_dist);
            ObjectSetText(name,"~",10,"Arial",clrWhite);
            e=4;
            name=ExtName+"End_"+string(e);
            DrawTextEnd(name,e,y_dist);
            AvgDZP=buy_DZP_avg/buy_DZP_avgN;
            ObjectSetText(name,c(AvgDZP,0),10,"Arial",getStrClrDZP(AvgDZP,total,""));
           }
         else
           {
            ObjectsDeleteAll(ChartID(),ExtName+"End_3",windex,OBJ_LABEL);
            ObjectsDeleteAll(ChartID(),ExtName+"End_4",windex,OBJ_LABEL);
           }

         if(sell_DZP_avgN>0)
           {
            e=8;
            name=ExtName+"End_"+string(e);
            DrawTextEnd(name,e,y_dist);
            ObjectSetText(name,"~",10,"Arial",clrWhite);
            e=9;
            name=ExtName+"End_"+string(e);
            DrawTextEnd(name,e,y_dist);
            AvgDZP=sell_DZP_avg/sell_DZP_avgN;
            ObjectSetText(name,c(AvgDZP,0),10,"Arial",getStrClrDZP(AvgDZP,total,""));
           }
         else
           {
            ObjectsDeleteAll(ChartID(),ExtName+"End_8",windex,OBJ_LABEL);
            ObjectsDeleteAll(ChartID(),ExtName+"End_9",windex,OBJ_LABEL);
           }

         e=13;
         name=ExtName+"End_"+string(e);
         DrawTextEnd(name,e,y_dist);
         ObjectSetText(name,"#",10,"Arial",clrWhite);
         //---
         e=14;
         name=ExtName+"End_"+string(e);
         DrawTextEnd(name,e,y_dist);
         ObjectSetText(name,string(SumCnt),10,"Arial",clrWhite);
         //---

         double comp_d=_CommaDecode(ObjectGetString(0,"End_18",OBJPROP_TEXT,0),2,"_");
         string Arrow2="q";
         color clrArrow2=clrRed;
         if(comp_d<SumProfit){ Arrow2="p";clrArrow2=clrLime;}
         if(comp_d==SumProfit){ Arrow2="1";clrArrow2=clrDimGray;}

         e=17;name=ExtName+"End_"+string(e);
         DrawTextEnd(name,e,y_dist);
         ObjectSetText(name,Arrow2,9,"Wingdings 3",clrArrow2);

         //ObjectSetText(name,comp_d,10,"Arial",getStrClr(SumProfit));
         //---
         e=18;name=ExtName+"End_"+string(e);
         DrawTextEnd(name,e,y_dist);
         ObjectSetText(name,_Comma(SumProfit,2,"_"),10,"Arial",getStrClr(SumProfit,true,SumCnt));

         double HP=(SumProfit/AccountInfoDouble(ACCOUNT_BALANCE))*100;
         e=19;name=ExtName+"End_"+string(e);
         DrawTextEnd(name,e,y_dist);
         ObjectSetText(name,_Comma(HP,2,"_")+"%",10,"Arial",getStrClr(SumProfit,true,SumCnt));
        }
      DrawLinePrice();
      //---
      DrawTradelevel();
      //---
      DrawBidAsk();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HealTick=900;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(HealTick<=0)
      HealTick=0;
   HealTick+=60;
//---- remove lines
/*int LineC=-1;
   if(total<ExtLines)
     {
      for(line=ExtLines; line>total; line--)
        {
         LineC++;name=getNameObjet(line,LineC);
         ObjectSetText(name,"");
        }
     }*/
//---

//---- to avoid minimum==maximum
   ExtMapBuffer[Bars-1]=-1;
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculator_Hege()
  {
   double _ObjectGet_HegeTraget=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_ifTragetHege",OBJPROP_PRICE),Digits);
   double _ObjectGet_HegeTragetPrice=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_ifTragetHegePrice",OBJPROP_PRICE),Digits);

   double _ObjectGet_Hege=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_Hege",OBJPROP_PRICE),Digits);

   double _ObjectGet_BuyH=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_Buy",OBJPROP_PRICE),Digits);
   double _ObjectGet_SellH=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_Sell",OBJPROP_PRICE),Digits);

   double BuyH_lots=StringToDouble(ObjectGetString(0,ExtName+"H_Buy",OBJPROP_TEXT));
   double SellH_lots=StringToDouble(ObjectGetString(0,ExtName+"H_Sell",OBJPROP_TEXT));
//   

   double Hege_DistantTotal,Distant;
   double Hege_Per2;
   if(_ObjectGet_HegeTraget>0 && _ObjectGet_Hege==0)
     {
      if(_ObjectGet_SellH>0 && _ObjectGet_HegeTraget!=_ObjectGet_SellH)
        {
         Hege_DistantTotal=MathAbs(_ObjectGet_HegeTraget-_ObjectGet_SellH);
         Distant=MathAbs(_ObjectGet_HegeTraget-_ObjectGet_HegeTragetPrice);
         Hege_Per2=NormalizeDouble(Distant/Hege_DistantTotal,2);

         ObjectSetString(0,ExtName+"BTN_H_ifTragetHege",OBJPROP_TEXT,c(__LINE__)+"# "+c(SellH_lots/Hege_Per2,2)+" : "+c(Distant/Point,0)+"p");
        }
      else if(_ObjectGet_BuyH>0 && _ObjectGet_HegeTraget!=_ObjectGet_BuyH)
        {
         Hege_DistantTotal=MathAbs(_ObjectGet_HegeTraget-_ObjectGet_BuyH);
         Distant=MathAbs(_ObjectGet_HegeTraget-_ObjectGet_HegeTragetPrice);
         Hege_Per2=NormalizeDouble(Distant/Hege_DistantTotal,2);

         ObjectSetString(0,ExtName+"BTN_H_ifTragetHege",OBJPROP_TEXT,c(__LINE__)+"# "+c(BuyH_lots/Hege_Per2,2)+" : "+c(Distant/Point,0)+"p");
        }
     }
   else
     {
      // _ObjectGet_HegeTraget
      // _ObjectGet_HegeTragetPrice

      // _ObjectGet_Hege

      // _ObjectGet_BuyH
      // _ObjectGet_SellH
      if(_ObjectGet_Hege>0 && _ObjectGet_HegeTraget>0)
        {
         if(true && _ObjectGet_BuyH>0)
           {
            Hege_DistantTotal=MathAbs(_ObjectGet_HegeTraget-_ObjectGet_BuyH);
            Distant=MathAbs(_ObjectGet_HegeTraget-Bid);
            Hege_Per2=NormalizeDouble(Distant/Hege_DistantTotal,2);

            double DeltaLot=(BuyH_lots/Hege_Per2)-SellH_lots;

            ObjectSetString(0,ExtName+"BTN_H_ifTragetHege",OBJPROP_TEXT,c(__LINE__)+"# "+c(DeltaLot,2));
           }
         else
           {
            ObjectSetString(0,ExtName+"BTN_H_ifTragetHege",OBJPROP_TEXT,c(__LINE__)+"# FillLots Err");
           }

        }
      else
        {
         ObjectSetString(0,ExtName+"BTN_H_ifTragetHege",OBJPROP_TEXT,c(__LINE__)+"# TragetHege");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calculator_RulerBuySell()
  {

//---
   setColorBTNActive("H_Buy","BTN_H_BuyRuler","BTN_H_BuyAddRuler","EDI_BuyAddLot","BTN_H_ifTragetBuy","BTN_H_ApproachBuy",clrRoyalBlue,clrMagenta);
   setColorBTNActive("H_Sell","BTN_H_SellRuler","BTN_H_SellAddRuler","EDI_SellAddLot","BTN_H_ifTragetSell","BTN_H_ApproachSel",clrTomato,clrYellow);
//---
   double _ObjectGetDoubleBuy=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_Buy_Ruler",OBJPROP_PRICE),Digits);
   double _ObjectGetDoubleSell=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_Sell_Ruler",OBJPROP_PRICE),Digits);

   double _ObjectGetDoubleBoth=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_Both_Ruler",OBJPROP_PRICE),Digits);
   double sumbuy=0,sumsell=0,sumboth=0;
/*Market_mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE); //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   Market_l=MarketInfo(Symbol(),MODE_LOTSIZE);
   _MODE_POINT=MarketInfo(Symbol(),MODE_POINT);
   Market_t=MarketInfo(Symbol(),MODE_TICKSIZE);*/
   _MODE_TICKVALUE=MarketInfo(Symbol(),MODE_TICKVALUE);

//---
   string TestPointValue="";

   if(_ObjectGetDoubleBuy>0 || _ObjectGetDoubleSell>0 || _ObjectGetDoubleBoth>0)
     {

      for(int pos=0;pos<OrdersTotal() && _ObjectGetDoubleBuy>0;pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderSymbol()==Symbol() /*&& OrderMagicNumber()==CurrentMagic*/ && OrderType()<=1)
           {
            if(OrderType()==OP_BUY /*&& _ObjectGetDoubleBuy>0*/)
              {
               TestPointValue="OP_BUY_Market_mode "+Market_mode;;
               //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
               if(Market_mode==0)
                 {
                  double buy=(_ObjectGetDoubleBuy-OrderOpenPrice())/_MODE_POINT*_MODE_TICKVALUE*OrderLots();
                  double buy2=(_ObjectGetDoubleBuy-OrderOpenPrice())*(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)/MarketInfo(Symbol(),MODE_BID))*OrderLots();

                  sumbuy+=buy;

                  TestPointValue+="\n"+c(_ObjectGetDoubleBuy-OrderOpenPrice(),Digits);
                  TestPointValue+="\n_POINT "+c(_MODE_POINT,Digits);
                  TestPointValue+="\n_TICKVALUE "+c(_MODE_TICKVALUE,5);

                  TestPointValue+="\n_TICKVALUE "+c((_MODE_POINT/MarketInfo(Symbol(),MODE_BID))*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE),5);

                  TestPointValue+="\nOrderLots() "+OrderLots();
                  TestPointValue+="\nbuy "+buy;
                  TestPointValue+="\nbuy "+buy2;

                 }

               if(Market_mode==1)
                 {
                  sumbuy+=((_ObjectGetDoubleBuy-OrderOpenPrice())/_MODE_POINT*_MODE_TICKVALUE/Market_t/Market_l*OrderLots())/100;

                 }
               if(Market_mode==2) sumbuy+=(_ObjectGetDoubleBuy-OrderOpenPrice())/_MODE_POINT*_MODE_TICKVALUE*OrderLots();
               sumbuy+=OrderCommission()+OrderSwap();
               Comment(TestPointValue);
              }
           }
        }
      for(int pos=0;pos<OrdersTotal() && _ObjectGetDoubleSell>0;pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderSymbol()==Symbol() /*&& OrderMagicNumber()==CurrentMagic*/ && OrderType()<=1)
           {
            if(OrderType()==OP_SELL /*&& _ObjectGetDoubleSell>0*/)
              {
               //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
               TestPointValue="OP_SELL_Market_mode "+Market_mode;;
               if(Market_mode==0)
                 {
                  double buy=(OrderOpenPrice()-_ObjectGetDoubleSell)/_MODE_POINT*_MODE_TICKVALUE*OrderLots();
                  double buy2=(OrderOpenPrice()-_ObjectGetDoubleSell)*(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)/MarketInfo(Symbol(),MODE_BID))*OrderLots();

                  sumsell+=buy;
                  TestPointValue+="\n"+c(OrderOpenPrice()-_ObjectGetDoubleSell,Digits);
                  TestPointValue+="\n_POINT "+c(_MODE_POINT,Digits);
                  TestPointValue+="\n_TICKVALUE "+c(_MODE_TICKVALUE,5);

                  TestPointValue+="\n_TICKVALUE "+c((_MODE_POINT/MarketInfo(Symbol(),MODE_BID))*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE),5);

                  TestPointValue+="\nOrderLots() "+OrderLots();
                  TestPointValue+="\nSell "+buy;
                  TestPointValue+="\nSell "+buy2;
                 }
               if(Market_mode==1) sumsell+=((OrderOpenPrice()-_ObjectGetDoubleSell)/_MODE_POINT*_MODE_TICKVALUE/Market_t/Market_l*OrderLots())/100;
               if(Market_mode==2) sumsell+=(OrderOpenPrice()-_ObjectGetDoubleSell)/_MODE_POINT*_MODE_TICKVALUE*OrderLots();
               sumsell+=OrderCommission()+OrderSwap();
               Comment(TestPointValue);
              }
            //---
           }
        }
      double Lot_Buy=0,Lot_Sell=0;
      for(int pos=0;pos<OrdersTotal() && _ObjectGetDoubleBoth>0;pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderSymbol()==Symbol() /*&& OrderMagicNumber()==CurrentMagic*/ && OrderType()<=1)
           {
            if(OrderType()==OP_BUY /*&& _ObjectGetDoubleBuy>0*/)
              {
               //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
               if(Market_mode==0) sumboth+=(_ObjectGetDoubleBoth-OrderOpenPrice())/_MODE_POINT*_MODE_TICKVALUE*OrderLots();

               if(Market_mode==1) sumboth+=((_ObjectGetDoubleBoth-OrderOpenPrice())/_MODE_POINT*_MODE_TICKVALUE/Market_t/Market_l*OrderLots())/100;
               if(Market_mode==2) sumboth+=(_ObjectGetDoubleBoth-OrderOpenPrice())/_MODE_POINT*_MODE_TICKVALUE*OrderLots();
               sumboth+=OrderCommission()+OrderSwap();
               Lot_Buy+=OrderLots();
              }
            if(OrderType()==OP_SELL /*&& _ObjectGetDoubleSell>0*/)
              {
               //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
               if(Market_mode==0) sumboth+=(OrderOpenPrice()-_ObjectGetDoubleBoth)/_MODE_POINT*_MODE_TICKVALUE*OrderLots();

               if(Market_mode==1) sumboth+=((OrderOpenPrice()-_ObjectGetDoubleBoth)/_MODE_POINT*_MODE_TICKVALUE/Market_t/Market_l*OrderLots())/100;
               if(Market_mode==2) sumboth+=(OrderOpenPrice()-_ObjectGetDoubleBoth)/_MODE_POINT*_MODE_TICKVALUE*OrderLots();
               sumboth+=OrderCommission()+OrderSwap();
               Lot_Sell+=OrderLots();
              }
            //---
           }
        }
      sumbuy=NormalizeDouble(sumbuy,2);
      sumsell=NormalizeDouble(sumsell,2);
      sumboth=NormalizeDouble(sumboth,2);

      string BTN_str;
      color BTN_clr;

      if(sumbuy!=0)
        {
         BTN_str=cD(_ObjectGetDoubleBuy,Digits)+" = "+cD(sumbuy,2)+_ActCurrency+"["+cD((Bid-_ObjectGetDoubleBuy)/Point,0)+"]";

         BTN_clr=clrBlack;
         if(sumbuy<0)BTN_clr=clrRed;

         ObjectSetInteger(0,ExtName+"BTN_H_BuyRuler",OBJPROP_COLOR,BTN_clr);
         ObjectSetString(0,ExtName+"BTN_H_BuyRuler",OBJPROP_TEXT,BTN_str);

        }
      if(sumsell!=0)
        {
         BTN_str=cD(_ObjectGetDoubleSell,Digits)+" = "+cD(sumsell,2)+_ActCurrency+"["+cD((_ObjectGetDoubleSell-Ask)/Point,0)+"]";

         BTN_clr=clrBlack;if(sumsell<0)BTN_clr=clrRed;

         ObjectSetInteger(0,ExtName+"BTN_H_SellRuler",OBJPROP_COLOR,BTN_clr);
         ObjectSetString(0,ExtName+"BTN_H_SellRuler",OBJPROP_TEXT,BTN_str);
        }
      if(sumboth!=0)
        {
         double DiffPoint=0;
         if(Lot_Buy<Lot_Sell)
           {
            DiffPoint=(_ObjectGetDoubleBoth-Bid)/Point;
           }
         else
           {
            DiffPoint=(Ask-_ObjectGetDoubleBoth)/Point;
           }

         BTN_str=cD(_ObjectGetDoubleBoth,Digits)+" = "+cD(sumboth,2)+_ActCurrency+"["+cD(DiffPoint,0)+"]";

         BTN_clr=clrBlack;if(sumboth<0)BTN_clr=clrRed;

         ObjectSetInteger(0,ExtName+"BTN_H_BothRuler",OBJPROP_COLOR,BTN_clr);
         ObjectSetString(0,ExtName+"BTN_H_BothRuler",OBJPROP_TEXT,BTN_str);
        }
      //_LabelSet("Text_R",windex,CORNER_RIGHT_UPPER,500,100,clrMagenta,"Arial",10,string(sumbuy+sumsell),"tooltip");

/*Comment("Buy : "+cD(_ObjectGetDoubleBuy,Digits)+" | "+cD(sumbuy,2)
              +"\n"+
              "Sell : "+cD(_ObjectGetDoubleSell,Digits)+" | "+cD(sumsell,2)
              +"\n"+
              "Both : "+cD(_ObjectGetDoubleBoth,Digits)+" | "+cD(sumboth,2));*/

     }
   else
     {
      if(_ObjectGetDoubleBuy==0)
        {
         ObjectSetString(0,ExtName+"BTN_H_BuyRuler",OBJPROP_TEXT,"Ruler Buy");
         ObjectSetInteger(0,ExtName+"BTN_H_BuyRuler",OBJPROP_COLOR,clrBlack);
        }
      if(_ObjectGetDoubleSell==0)
        {
         ObjectSetString(0,ExtName+"BTN_H_SellRuler",OBJPROP_TEXT,"Ruler Sell");
         ObjectSetInteger(0,ExtName+"BTN_H_SellRuler",OBJPROP_COLOR,clrBlack);
        }
      if(_ObjectGetDoubleBoth==0)
        {
         ObjectSetString(0,ExtName+"BTN_H_BothRuler",OBJPROP_TEXT,"Ruler Both");
         ObjectSetInteger(0,ExtName+"BTN_H_BothRuler",OBJPROP_COLOR,clrBlack);
        }
     }
  }
double priceHege=0;
double _GetBuyTX,_GetBuyTX2;
double _GetSellTX,_GetSellTX2;
double Price_Test=0;
double _LotStep=0,_BuyLotTraget=0,_SellLotTraget=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getNameObjet(int line,int LineC)
  {
   return ExtName+"Line_"+string(line)+"_"+string(LineC);
  }

color clr_getHavePoint=clrRed;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getHavePoint(double x,double Positive,double Negative,double lots)
  {
   if(Positive>0)
     {
      if(x>=0)
         clr_getHavePoint=clrLime;
      else
         clr_getHavePoint=clrYellow;
      return c(Positive,0);
     }
   else
     {
      if(x>=0)
         clr_getHavePoint=clrYellow;
      else
         clr_getHavePoint=clrLime;
      return c(Negative,0);
     }
   clr_getHavePoint=clrWhite;
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Analyze()
  {
   ArrayInitialize(ExtSymbolsSummaries,0.0);
   double profit,point=0,v_Point;
   int    index,type;
//----
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;

      type=OrderType();
      if(type!=OP_BUY && type!=OP_SELL) continue;

      index=SymbolsIndex(OrderSymbol());
      if(index<0 || index>=SYMBOLS_MAX) continue;
      //---
      if(OrderComment()!="")
        {
         ExtSymbols[index+1][comment]=OrderComment();
        }
      //----
      ExtSymbolsSummaries[index][DEALS]++;
      profit=OrderProfit()+OrderCommission()+OrderSwap();
      ExtSymbolsSummaries[index][PROFIT]+=profit;

      if(type==OP_BUY)
        {
         ExtSymbolsSummaries[index][BUY_LOTS]+=NormalizeDouble(OrderLots(),2);
         ExtSymbolsSummaries[index][BUY_PRICE]+=NormalizeDouble(OrderOpenPrice()*OrderLots(),int(MarketInfo(OrderSymbol(),MODE_DIGITS)));

         ExtSymbolsSummaries[index][BUY_PROFIT]+=profit;
         ExtSymbolsSummaries[index][BUY_DEALS]++;

         point=getOrderPoint(OP_BUY,OrderSymbol(),OrderOpenPrice());
         if(profit>=0)
           {
            ExtSymbolsSummaries[index][BUY_HavePositive]++;
            //---
            v_Point=ExtSymbolsSummaries[index][BUY_HavePositive_Point];
            if((v_Point>0 && v_Point<point) || v_Point==0)
              {
               ExtSymbolsSummaries[index][BUY_HavePositive_Point]=point;
              }
           }
         else
           {
            ExtSymbolsSummaries[index][BUY_HaveNegative]++;
            //---
            v_Point=ExtSymbolsSummaries[index][BUY_HaveNegative_Point];
            if((v_Point<0 && v_Point<point) || v_Point==0)
              {
               ExtSymbolsSummaries[index][BUY_HaveNegative_Point]=point;
              }
           }
        }
      else
        {
         ExtSymbolsSummaries[index][SELL_LOTS]+=NormalizeDouble(OrderLots(),2);
         ExtSymbolsSummaries[index][SELL_PRICE]+=NormalizeDouble(OrderOpenPrice()*OrderLots(),int(MarketInfo(OrderSymbol(),MODE_DIGITS)));

         ExtSymbolsSummaries[index][SELL_PROFIT]+=profit;
         ExtSymbolsSummaries[index][SELL_DEALS]++;
         //---
         point=getOrderPoint(OP_SELL,OrderSymbol(),OrderOpenPrice());
         if(profit>=0)
           {
            ExtSymbolsSummaries[index][SEL_HavePositive]++;
            //---
            v_Point=ExtSymbolsSummaries[index][SEL_HavePositive_Point];
            if((v_Point<0 && v_Point<point) || v_Point==0)
              {
               ExtSymbolsSummaries[index][SEL_HavePositive_Point]=point;
              }
           }
         else
           {
            ExtSymbolsSummaries[index][SEL_HaveNegative]++;
            //---
            v_Point=ExtSymbolsSummaries[index][SEL_HaveNegative_Point];
            if((v_Point<0 && v_Point<point) || v_Point==0)
              {
               ExtSymbolsSummaries[index][SEL_HaveNegative_Point]=point;
              }
           }
        }
     }
//------
   string tempVar,tempVar2;
//---Split Post+Neg
   int Post=0,Neg=0;
   for(int i=0;i<ExtSymbolsTotal;i++)
     {
      if(ExtSymbolsSummaries[i][DEALS]>0)
        {
         ExtSymbolsP[Post][symbolname]=ExtSymbols[i][symbolname];
         ExtSymbolsP[Post][comment]=ExtSymbols[i][comment];
         for(int k=0;k<ExtSymbolsTotalCntInfo;k++)
           {
            ExtSymbolsSummaries_TempP[Post][k]=ExtSymbolsSummaries[i][k];
           }
         Post++;
        }
      else
        {
         ExtSymbolsN[Neg][symbolname]=ExtSymbols[i][symbolname];
         ExtSymbolsN[Neg][comment]=ExtSymbols[i][comment];
         for(int k=0;k<ExtSymbolsTotalCntInfo;k++)
           {
            ExtSymbolsSummaries_TempN[Neg][k]=ExtSymbolsSummaries[i][k];
           }
         Neg++;
        }
     }
   for(int i=0;i<Post;i++)
     {
      ExtSymbols[i][symbolname]=ExtSymbolsP[i][symbolname];
      ExtSymbols[i][comment]=ExtSymbolsP[i][comment];
      for(int k=0;k<ExtSymbolsTotalCntInfo;k++)
        {
         ExtSymbolsSummaries[i][k]=ExtSymbolsSummaries_TempP[i][k];
        }
     }
   for(int i=0;i<Neg;i++)
     {
      ExtSymbols[Post+i][symbolname]=ExtSymbolsN[i][symbolname];
      ExtSymbols[Post+i][comment]=ExtSymbolsN[i][comment];
      for(int k=0;k<ExtSymbolsTotalCntInfo;k++)
        {
         ExtSymbolsSummaries[Post+i][k]=ExtSymbolsSummaries_TempN[i][k];
        }
     }
//---CURRENT Symbols
   if(ExtSymbols[0][symbolname]!=Symbol())
     {
      for(int l=0;l<ExtSymbolsTotal;l++)
        {
         if(ExtSymbols[l][symbolname]==Symbol())
           {
            //--- Save Frist Block 
            tempVar=ExtSymbols[l][symbolname];
            tempVar2=ExtSymbols[l][comment];
            for(int k=0;k<ExtSymbolsTotalCntInfo;k++)
              {
               ExtSymbolsSummaries_Temp[k]=ExtSymbolsSummaries[l][k];
              }
            //--- Bubble Block
            for(int j=l;j>0;j--)
              {
               ExtSymbols[j][symbolname]=ExtSymbols[j-1][symbolname];
               ExtSymbols[j][comment]=ExtSymbols[j-1][comment];
               for(int k=0;k<ExtSymbolsTotalCntInfo;k++)
                 {
                  ExtSymbolsSummaries[j][k]=ExtSymbolsSummaries[j-1][k];
                 }
              }
            //--- Allow Frist Block
            ExtSymbols[0][symbolname]=tempVar;
            ExtSymbols[0][comment]=tempVar2;
            for(int k=0;k<ExtSymbolsTotalCntInfo;k++)
              {
               ExtSymbolsSummaries[0][k]=ExtSymbolsSummaries_Temp[k];
              }
           }
        }
     }
//---

   return(ExtSymbolsTotal);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getOrderPoint(int OP,string symbol,double OpenPrice)
  {
/*Market_mode=MarketInfo(Symbol(),MODE_PROFITCALCMODE); 
   Market_l=MarketInfo(Symbol(),MODE_LOTSIZE);
   _MODE_POINT=MarketInfo(Symbol(),MODE_POINT);
   Market_t=MarketInfo(Symbol(),MODE_TICKSIZE);
   _MODE_TICKVALUE=MarketInfo(Symbol(),MODE_TICKVALUE);*/

//Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures

   double point=-1;
   double MODE_POINT_=MathPow(10,int(MarketInfo(symbol,MODE_DIGITS))*-1);
   double Market_mode_=MarketInfo(symbol,MODE_PROFITCALCMODE);

   double _MODE_BID=MarketInfo(symbol,MODE_BID);
   double _MODE_ASK=MarketInfo(symbol,MODE_ASK);

   if(Market_mode_==0)//Forex
     {
      if(OP==OP_BUY)
         point=((_MODE_BID-OpenPrice)/MODE_POINT_);
      else if(OP==OP_SELL)
         point=((OpenPrice-_MODE_ASK)/MODE_POINT_);
     }
   else if(Market_mode_==1)//CFD
     {
      if(OP==OP_BUY)
         point=((_MODE_BID-OpenPrice)/MODE_POINT_);
      else if(OP==OP_SELL)
         point=((OpenPrice-_MODE_ASK)/MODE_POINT_);
     }

   return NormalizeDouble(point,int(MarketInfo(symbol,MODE_DIGITS)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SymbolsIndex(string _SymbolName)
  {
   bool found=false;
   int  found_index=-1;
//----
   for(int i=0; i<ExtSymbolsTotal; i++)
     {
      if(_SymbolName==ExtSymbols[i][symbolname])
        {
         found=true;
         found_index=i;
         break;
        }
     }
//----
   if(found)
      return(found_index);
   if(ExtSymbolsTotal>=SYMBOLS_MAX)
      return(-1);
//----
   found_index=ExtSymbolsTotal;

   ExtSymbolsTotal++;

   ExtSymbols[found_index][symbolname]=_SymbolName;
   ExtSymbols[found_index][comment]="";

   ExtSymbolsSummaries[found_index][DEALS]=0;

   ExtSymbolsSummaries[found_index][BUY_LOTS]=0;
   ExtSymbolsSummaries[found_index][BUY_PRICE]=0;

   ExtSymbolsSummaries[found_index][SELL_LOTS]=0;
   ExtSymbolsSummaries[found_index][SELL_PRICE]=0;

   ExtSymbolsSummaries[found_index][NET_LOTS]=0;
   ExtSymbolsSummaries[found_index][PROFIT]=0;

   ExtSymbolsSummaries[found_index][BUY_PROFIT]=0;
   ExtSymbolsSummaries[found_index][SELL_PROFIT]=0;

   ExtSymbolsSummaries[found_index][BUY_DEALS]=0;
   ExtSymbolsSummaries[found_index][SELL_DEALS]=0;

   ExtSymbolsSummaries[found_index][BUY_HavePositive_Point]=0;
   ExtSymbolsSummaries[found_index][SEL_HavePositive_Point]=0;
   ExtSymbolsSummaries[found_index][BUY_HaveNegative_Point]=0;
   ExtSymbolsSummaries[found_index][SEL_HaveNegative_Point]=0;

//----
   return(found_index);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getStrClr(double v,bool lots,double _DEALS)
  {
   if(_DEALS>0)
     {
      if(v==0)
        {
         if(lots)
           {
            return clrLime;
           }
         else
           {
            //return clrMagenta;
            return clrBlack;
           }
        }
      else if(v>0)
        {//clrLightSeaGreen
         return clrDodgerBlue;
        }
      else
        {
         return clrRed;
        }
     }
   return clrBlack;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getStrClrSymbolName(double v,bool lots)
  {
   if(v==0)
     {
      if(lots)
        {
         return clrLime;
        }
      else
        {
         return clrDimGray;
         //return clrBlack;
        }
     }
   else if(v>0)
     {//clrLightSeaGreen
      return clrDodgerBlue;
     }
   else
     {
      return clrRed;
     }
   return clrWhite;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getStrClrDZP(double v,bool lots,string OP)
  {
   if(v==0)
     {
      if(lots)
        {
         return clrLime;
        }
      else
        {
         return clrBlack;
        }
     }
   else if(v>0)
     {
      if(v<=100)
        {
         if(v==50)
           {
/*SendNotification(OP+
                             "\nDiff: "+c(v,0)+
                             "\nLots: "+c(lots,0));*/
           }
         return C'0,255,200';
        }
      if(v>350)
         return C'0,180,255';
      return C'0,150,255';
     }
   else
     {
      if(v>-100)
         return C'255,200,0';
      return C'255,0,0';
     }
   return clrWhite;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getStrClrLots(double v,double _DEALS)
  {
   if(_DEALS>0)
     {
      if(v==0)
        {
         return clrLime;
        }
      else if(v>0)
        {//clrLightSeaGreen
         return clrDodgerBlue;
        }
      else
        {
         return clrRed;
        }
     }
   return clrBlack;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getStrClrZero(double v)
  {
   if(v>0)
     {//clrLightSeaGreen
      return clrWhite;
     }
   else
     {
      return clrBlack;
     }
   return clrWhite;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getStrClrZero2(double v,double pos,double neg)
  {
   double per=pos/neg;
   if(v>0)
     {
      return clrWhite;
     }
   else
     {
      return clrBlack;
     }
   return clrWhite;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {
   v=NormalizeDouble(v,Digit);
   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= z;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }

   return temp3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _CommaZero(double v,int Digit,string z)
  {
   v=NormalizeDouble(v,Digit);
   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= z;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }

   return temp3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CommaDecode(string v,int Digit,string z)
  {
   string temp="",temp2="";

   for(int i=0;i<StringLen(v);i++)
     {
      temp=StringSubstr(v,i,1);
      if(temp!="_")
        {
         temp2+=temp;
        }
     }

   return NormalizeDouble(double(temp2),Digit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*bool _LabelCreate(string name,int panel)
  {
   if(!ObjectCreate(name,OBJ_LABEL,panel,0,0))
     {
      //Print(__FUNCTION__,":1 failed SetText = ",GetLastError()); 
      return(false);
     }
   return true;
  }*/

string _getCountdownTime()
  {
   double i;
   int m,s,k,h,day=0;
   string str;
//---
   m = int(Time[0]+Period()*60-CurTime());
   i = m/60;
   s = m%60;
   m = (m-m%60)/60;
   h = int(i/60);
   k = m -(h*60);
//Comment(h);
//---
   if(h>24)
     {
      day=int(h/24);
      h=int(h%24);
     }
//---

   if(day>0)
      str+=cFillZero(day,2)+"d:";
   if(h>0)
      str+=cFillZero(h,2)+"h:";
   if(k>0)
      str+=cFillZero(k,2)+"m:";

   str+=cFillZero(s,2)+"s";

   return str;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SymbolInfo()
  {
//---
//string TimeLeft=TimeToStr(Time[0]+Period()*60-TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
   double Spread=MarketInfo(Symbol(),MODE_SPREAD);
   double DayClose=iClose(Symbol(),PERIOD_D1,1);
   double CurClose=iClose(Symbol(),0,1);
//---

   double Swap_Long=MarketInfo(Symbol(),MODE_SWAPLONG);
   double Swap_Short=MarketInfo(Symbol(),MODE_SWAPSHORT);
   string Swap_SMS;
   if(Swap_Long>0)
      Swap_SMS+="L";
   if(Swap_Short>0)
      Swap_SMS+="S";
//---

   if(DayClose!=0)
     {
      double Strength=((Bid-DayClose)/DayClose)*100;
      double StrengthCur=(Bid-CurClose)*MathPow(10,Digits);

      string Label=" "+_Comma(Strength,5," ")+"% ["+_Comma(StrengthCur,0," ")+"] | "+_getCountdownTime()+" | "+_Comma(Spread,0," ")+Swap_SMS;

      int InfoFontSize=9;

      string Arrow="q";
      color clrArrow=clrRed;
      if(Strength>0){ Arrow="p";clrArrow=clrLime;}

      string tooltip="Strength | Candle Time | Spread";

      DrawText("Time"+": info arrow",Arrow,InfoFontSize-1,"Wingdings 3",clrArrow,CORNER_RIGHT_LOWER,0,220,18,tooltip);
      DrawText("Time"+": info",Label,InfoFontSize,"Calibri",clrYellow,CORNER_RIGHT_LOWER,0,210,20,tooltip);

     }
   DrawText("ASymbol"+": info",getSymbol(Symbol()),15,"Calibri",clrYellow,CORNER_LEFT_LOWER,0,10,30,"");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawText(string name,string label,int size,string font,color clr,ENUM_BASE_CORNER c,int windows,int x,int y,string tooltip)
  {
//---
   name=": "+name;
//if(AllowSubwindow && WindowsTotal()>1) windows=1;
   ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,windows,0,0);

   ObjectSetText(name,label,size,font,clr);
   ObjectSet(name,OBJPROP_CORNER,c);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
//--- justify text
   ObjectSet(name,OBJPROP_ANCHOR,0);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSet(name,OBJPROP_SELECTABLE,0);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setBUTTON_StateDelete(int _windex)
  {
   ObjectDelete(_windex,"EDI_SellAddRuler");
   ObjectDelete(_windex,"BTN_H_SellAddRuler");

   ObjectDelete(_windex,"BTN_H_BuyRuler");
   ObjectDelete(_windex,"BTN_H_SellRuler");
  }
extern ENUM_BASE_CORNER ControlHand=CORNER_RIGHT_UPPER;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setBUTTON_StateHUB(int _windex,bool ChangeDIS)
  {

   int SizeX=195;
   int SizeY=20;
   int ScalX=160,XStep=SizeX+5;
   int ScalY=5,YStep=SizeY+5;

   _setBUTTON(ExtName+"BTN_H_BuyRuler",_windex,CORNER_LEFT_UPPER,SizeX,SizeY,ScalX,ScalY,false,10,clrBlack,clrRoyalBlue,"Ruler Buy");ScalX+=XStep;
   _setBUTTON(ExtName+"BTN_H_SellRuler",_windex,CORNER_LEFT_UPPER,SizeX,SizeY,ScalX,ScalY,false,10,clrBlack,clrTomato,"Ruler Sell"); ScalX+=XStep;
   _setBUTTON(ExtName+"BTN_H_BothRuler",_windex,CORNER_LEFT_UPPER,SizeX,SizeY,ScalX,ScalY,false,10,clrBlack,clrYellow,"Ruler Both"); ScalX+=XStep;
   ScalY+=YStep;ScalX=160;
   _setBUTTON(ExtName+"BTN_H_ifTragetBuy",_windex,CORNER_LEFT_UPPER,SizeX,SizeY,ScalX,ScalY,false,10,clrBlack,clrRoyalBlue,"TragetBuy");ScalX+=XStep;
   _setBUTTON(ExtName+"BTN_H_ifTragetSell",_windex,CORNER_LEFT_UPPER,SizeX,SizeY,ScalX,ScalY,false,10,clrBlack,clrTomato,"TragetSell");ScalX+=XStep;
   _setBUTTON(ExtName+"BTN_H_ifTragetHege",_windex,CORNER_LEFT_UPPER,SizeX,SizeY,ScalX,ScalY,false,10,clrBlack,clrYellow,"TragetHege");ScalX+=XStep;
//---
   string strSHOW_BarChart="Candle";
   color BGCOLOR_SHOW_BarChart=clrLime;
   if(boolTemplate)
     {
      strSHOW_BarChart="BarCharts";
      BGCOLOR_SHOW_BarChart=clrRed;
     }
//CORNER_RIGHT_UPPER
   int ScalX_=0;
   if(ControlHand==CORNER_LEFT_UPPER)
     {
      SizeX=int(SizeX*0.33);
      ScalX_=ScalX=5;XStep=SizeX+5;
      ScalY=15;YStep=SizeY+5;
      SizeY-=5;
     }
   else if(ControlHand==CORNER_RIGHT_UPPER)
     {
      SizeX=int(SizeX*0.33);
      ScalX_=ScalX=SizeX+5;XStep=SizeX+5;
      ScalY=5;YStep=SizeY+5;
     }

   _setBUTTON(ExtName+"BTN_H_SHOW_TRADE_LEVELS",_windex,ControlHand,SizeX,SizeY,ScalX,ScalY,ChangeDIS,8,clrBlack,clrLime,"LEVELS");ScalX+=XStep;
   _setBUTTON(ExtName+"BTN_H_SHOW_News",_windex,ControlHand,SizeX,SizeY,ScalX,ScalY,ChangeDIS,8,clrBlack,clrLime,"NEWS");ScalX+=XStep;
   ScalY+=YStep;ScalX=ScalX_;
   _setBUTTON(ExtName+"BTN_H_objDelete",_windex,ControlHand,SizeX,SizeY,ScalX,ScalY,ChangeDIS,8,clrBlack,clrLime,"DeleteObj");ScalX+=XStep;
   _setBUTTON(ExtName+"BTN_H_SHOW_BarChart",_windex,ControlHand,SizeX,SizeY,ScalX,ScalY,ChangeDIS,8,clrBlack,BGCOLOR_SHOW_BarChart,strSHOW_BarChart);ScalX+=XStep;

//---
   ObjectDelete(0,"BTN_H_SHOW_News2");
   ObjectDelete(0,ExtName+"BTN_H_SHOW_News2");
   _setBUTTON("BTN_H_SHOW_News2",0,CORNER_LEFT_LOWER,SizeX,SizeY,10,50,false,8,clrBlack,clrLime,"NEWS");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setColorBTNActive(string Name,string Name2,string Name3,string Name4,string Name5,string Name6,color Primeclr,color Primeclr2)
  {
   if(!ObjectFind(0,ExtName+Name))
     {
      if(!ObjectGetInteger(0,ExtName+Name2,OBJPROP_STATE))
        {
         ObjectSetInteger(0,ExtName+Name2,OBJPROP_BGCOLOR,Primeclr);
         ObjectSetInteger(0,ExtName+Name2,OBJPROP_BORDER_COLOR,Primeclr);
        }

      ObjectSetInteger(0,ExtName+Name3,OBJPROP_BGCOLOR,Primeclr2);
      ObjectSetInteger(0,ExtName+Name3,OBJPROP_BORDER_COLOR,Primeclr2);

      ObjectSetInteger(0,ExtName+Name4,OBJPROP_BGCOLOR,clrWhite);
      ObjectSetInteger(0,ExtName+Name4,OBJPROP_BORDER_COLOR,Primeclr2);

      if(!ObjectGetInteger(0,ExtName+Name5,OBJPROP_STATE))
        {
         ObjectSetInteger(0,ExtName+Name5,OBJPROP_BGCOLOR,Primeclr);
         ObjectSetInteger(0,ExtName+Name5,OBJPROP_BORDER_COLOR,Primeclr);
        }
      else
        {
         ObjectSetInteger(0,ExtName+Name5,OBJPROP_BGCOLOR,clrWhite);
        }

      if(!ObjectGetInteger(0,ExtName+Name6,OBJPROP_STATE))
        {
         ObjectSetInteger(0,ExtName+Name6,OBJPROP_BGCOLOR,Primeclr);
         ObjectSetInteger(0,ExtName+Name6,OBJPROP_BORDER_COLOR,Primeclr);
        }
     }
   else
     {
      ObjectSetInteger(0,ExtName+Name2,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,ExtName+Name2,OBJPROP_BORDER_COLOR,clrBlack);

      ObjectSetInteger(0,ExtName+Name3,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,ExtName+Name3,OBJPROP_BORDER_COLOR,clrBlack);

      ObjectSetInteger(0,ExtName+Name4,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,ExtName+Name4,OBJPROP_BORDER_COLOR,clrBlack);

      ObjectSetInteger(0,ExtName+Name5,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,ExtName+Name5,OBJPROP_BORDER_COLOR,clrBlack);

      ObjectSetInteger(0,ExtName+Name6,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,ExtName+Name6,OBJPROP_BORDER_COLOR,clrBlack);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                  )
  {
   string NameBTN,NameBTN_Twin;
   string NAMERuler;
   color ClrBTN;

   double Diff_Mark=0;
   if(_Period<=150)
      Diff_Mark=175;
   else if(_Period<=1440)
                    Diff_Mark=500;
   else if(_Period<=10080)
                    Diff_Mark=1000;
   else if(_Period>=9000)
                    Diff_Mark=9000;
//printf(string(Diff_Mark));

   Diff_Mark=Diff_Mark*_MODE_POINT;

   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      NameBTN=ExtName+"BTN_H_BuyRuler";
      NAMERuler=ExtName+"H_Buy_Ruler";
      ClrBTN=clrRoyalBlue;
      if(sparam==NameBTN)
        {
         if(!ObjectFind(0,ExtName+"H_Buy"))
           {
            if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
              {
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrWhite);
               //---
               HLineCreate_(0,NAMERuler,"",0,ObjectGetDouble(0,ExtName+"H_Buy",OBJPROP_PRICE)+Diff_Mark,clrBlue,1,0,0,true,false,0);

              }
            else
              {
               HLineDelete(0,NAMERuler);
               ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
              }
           }
        }

      NameBTN=ExtName+"BTN_H_SellRuler";
      NAMERuler=ExtName+"H_Sell_Ruler";
      ClrBTN=clrTomato;
      if(sparam==NameBTN)
        {
         if(!ObjectFind(0,ExtName+"H_Sell"))
           {
            if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
              {
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrWhite);
               //---
               HLineCreate_(0,NAMERuler,"",0,ObjectGetDouble(0,ExtName+"H_Sell",OBJPROP_PRICE)-Diff_Mark,clrRed,1,0,0,true,false,0);

              }
            else
              {
               HLineDelete(0,NAMERuler);
               ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
              }
           }

        }

      NameBTN=ExtName+"BTN_H_BothRuler";
      NAMERuler=ExtName+"H_Both_Ruler";
      ClrBTN=clrYellow;
      if(sparam==NameBTN)
        {
         if(!ObjectFind(0,ExtName+"H_Buy") && !ObjectFind(0,ExtName+"H_Sell"))
           {
            if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
              {
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrWhite);
               //---                 {
               if(!ObjectFind(0,ExtName+"H_Buy"))
                  HLineCreate_(0,NAMERuler,"",0,ObjectGetDouble(0,ExtName+"H_Hege",OBJPROP_PRICE),clrYellow,1,0,0,true,false,0);
               if(!ObjectFind(0,ExtName+"H_Sell"))
                  HLineCreate_(0,NAMERuler,"",0,ObjectGetDouble(0,ExtName+"H_Hege",OBJPROP_PRICE),clrYellow,1,0,0,true,false,0);
              }
            else
              {
               HLineDelete(0,NAMERuler);
               ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
              }
           }

        }

      NameBTN=ExtName+"BTN_H_ifTragetBuy";
      NAMERuler=ExtName+"H_ifTragetBuy";
      ClrBTN=clrRoyalBlue;
      if(sparam==NameBTN)
        {
         if(!ObjectFind(0,ExtName+"H_Buy"))
           {
            double H_Buy=ObjectGetDouble(0,ExtName+"H_Buy",OBJPROP_PRICE);
            if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
              {
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrWhite);
               //---
               HLineCreate_(0,NAMERuler,"",0,Ask,clrLime,1,0,0,true,false,0);
               HLineCreate_(0,NAMERuler+"2","",0,Ask+Diff_Mark,clrMagenta,0,1,0,true,false,0);
              }
            else
              {
               HLineDelete(0,NAMERuler);
               HLineDelete(0,NAMERuler+"2");

               ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);

               //ObjectSetString(0,"Text_R",OBJPROP_TEXT,cI(__LINE__)+"Off");
              }
           }

        }

      NameBTN=ExtName+"BTN_H_ifTragetSell";
      NAMERuler=ExtName+"H_ifTragetSell";
      ClrBTN=clrTomato;
      if(sparam==NameBTN)
        {
         if(!ObjectFind(0,ExtName+"H_Sell"))
           {
            double H_Sell=ObjectGetDouble(0,ExtName+"H_Sell",OBJPROP_PRICE);
            if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
              {
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrWhite);
               //---
               HLineCreate_(0,NAMERuler,"",0,Bid,clrLime,1,0,0,true,false,0);
               HLineCreate_(0,NAMERuler+"2","",0,Bid-Diff_Mark,clrMagenta,0,1,0,true,false,0);
              }
            else
              {
               HLineDelete(0,NAMERuler);
               HLineDelete(0,NAMERuler+"2");

               ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
              }
           }

        }
      //---
      NameBTN=ExtName+"BTN_H_ifTragetHege";
      NAMERuler=ExtName+"H_ifTragetHege";
      string NAMERuler2=ExtName+"H_ifTragetHegePrice";
      ClrBTN=clrYellow;
      if(sparam==NameBTN)
        {
         if(!ObjectFind(0,ExtName+"H_Buy") || !ObjectFind(0,ExtName+"H_Sell"))
           {
            if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
              {
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrWhite);
               //---
               if(!ObjectFind(0,ExtName+"H_Buy"))
                 {
                  HLineCreate_(0,NAMERuler,"",0,ObjectGetDouble(0,ExtName+"H_Buy",OBJPROP_PRICE),clrYellow,1,0,0,true,false,0);
                  HLineCreate_(0,NAMERuler2,"",0,Bid,clrOrange,1,0,0,true,false,0);

                 }
               if(!ObjectFind(0,ExtName+"H_Sell"))
                 {
                  HLineCreate_(0,NAMERuler,"",0,ObjectGetDouble(0,ExtName+"H_Sell",OBJPROP_PRICE),clrYellow,1,0,0,true,false,0);
                  HLineCreate_(0,NAMERuler2,"",0,Bid,clrOrange,1,0,0,true,false,0);
                 }
               if(!ObjectFind(0,ExtName+"H_Hege"))
                 {
                  HLineCreate_(0,NAMERuler,"",0,ObjectGetDouble(0,ExtName+"H_Hege",OBJPROP_PRICE),clrYellow,1,0,0,true,false,0);
                  HLineCreate_(0,NAMERuler2,"",0,Bid,clrOrange,1,0,0,true,false,0);
                 }
              }
            else
              {
               HLineDelete(0,NAMERuler);
               HLineDelete(0,NAMERuler2);
               ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
              }
           }

        }
      //---

      NameBTN=ExtName+"BTN_H_SHOW_TRADE_LEVELS";
      ClrBTN=clrBlueViolet;
      if(sparam==NameBTN)
        {
         if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
           {
            ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,false);
           }
         else
           {
            ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,true);
           }

        }

      //---

      NameBTN=ExtName+"BTN_H_SHOW_News";
      NameBTN_Twin="BTN_H_SHOW_News2";
      ClrBTN=clrLime;
      if(sparam==NameBTN)
        {
         if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
           {
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_STATE,1);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BGCOLOR,clrRed);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BORDER_COLOR,clrRed);
            //---
            boolShowNews=false;
            ObjectsDeleteAll(ChartID(),"FFC: Event Line",0,OBJ_VLINE);

            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);

           }
         else
           {
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_STATE,0);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BGCOLOR,ClrBTN);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BORDER_COLOR,ClrBTN);
            //---
            boolShowNews=true;
            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,ClrBTN);
           }
        }
      NameBTN="BTN_H_SHOW_News2";
      NameBTN_Twin=ExtName+"BTN_H_SHOW_News";
      ClrBTN=clrLime;
      if(sparam==NameBTN)
        {
         if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
           {
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_STATE,1);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BGCOLOR,clrRed);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BORDER_COLOR,clrRed);
            //---
            boolShowNews=false;
            ObjectsDeleteAll(ChartID(),"FFC: Event Line",0,OBJ_VLINE);

            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);

           }
         else
           {
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_STATE,0);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BGCOLOR,ClrBTN);
            ObjectSetInteger(0,NameBTN_Twin,OBJPROP_BORDER_COLOR,ClrBTN);
            //---
            boolShowNews=true;
            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,ClrBTN);
           }
        }
      NameBTN=ExtName+"BTN_H_SHOW_BarChart";

      ClrBTN=clrLime;
      if(sparam==NameBTN)
        {
         if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
           {
            setTemplate();
            boolTemplate=true;

            ObjectSetString(0,NameBTN,OBJPROP_TEXT,"BarCharts");
            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);
           }
         else
           {
            setTemplate_ToBridge();
            boolTemplate=false;

            ObjectSetString(0,NameBTN,OBJPROP_TEXT,"Candle");
            ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
            ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,ClrBTN);
           }
        }
     }
//---
   NameBTN=ExtName+"BTN_H_objDelete";
   ClrBTN=clrLime;
   if(sparam==NameBTN)
     {
      ObjectsDeleteAll(ChartID(),0,OBJ_RECTANGLE);
      ObjectsDeleteAll(ChartID(),"Horizontal Line",0,OBJ_HLINE);
      ObjectsDeleteAll(ChartID(),"Trend By Angle",0,OBJ_TRENDBYANGLE);
      ObjectsDeleteAll(ChartID(),"Trend By Angle",1,OBJ_TRENDBYANGLE);
      ObjectsDeleteAll(ChartID(),"Trend By Angle",2,OBJ_TRENDBYANGLE);

      ObjectsDeleteAll(ChartID(),0,OBJ_ARROW);
      ObjectsDeleteAll(ChartID(),"#",0,OBJ_TREND);
     }
//---
   for(int i=1;i<=total;i++)
     {
      NameBTN=ExtName+"Line_"+c(i)+"_0";
      if(sparam==NameBTN)
        {
         string Symbol_=ObjectGetString(ChartID(),NameBTN,OBJPROP_TOOLTIP);
         ChartSetSymbolPeriod(ChartID(),Symbol_,PERIOD_CURRENT);
        }
     }
//---
   NameBTN=ExtName+"Head_19";
   if(sparam==NameBTN)
     {
      //Comment(ControlHand);
      if(ControlHand==CORNER_LEFT_UPPER)
         ControlHand=CORNER_RIGHT_UPPER;
      else if(ControlHand==CORNER_RIGHT_UPPER)
         ControlHand=CORNER_LEFT_UPPER;
      _setBUTTON_StateHUB(windex,true);
     }
   ChartRedraw(ChartID());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getSymbol(string v)
  {
   string Symbol_Main=StringSubstr(v,0,3);
   string Symbol_Second=StringSubstr(v,3,3);
   string Symbol_Type=StringSubstr(v,6,1);
//---
   if(!StringFind(v,"GOLD",0) || !StringFind(Symbol(),"XAU",0))
     {
      if(!StringFind(v,"micro",0)==0)
         Symbol_Type="m";
      return "GOLD"+Symbol_Type;
     }
   if(!StringFind(v,"SILVER",0) || !StringFind(v,"XAG",0))
     {
      if(!StringFind(v,"micro",0)==0)
         Symbol_Type="m";
      return "SILVER"+Symbol_Type;
     }

   return Symbol_Main+" "+Symbol_Second+""+Symbol_Type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLinePrice()
  {
   total=Analyze();
   int r=-1;

   string testExtSymbols;
   for(int q=0;q<total;q++)
     {
      testExtSymbols+=ExtSymbols[q][symbolname]+"/";
      if(ExtSymbols[q][symbolname]==Symbol())
        {
         r=q;
         break;
        }
     }

   if(r>=0)
     {
      double buy_price=0.0;
      double sell_price=0.0;

      double buy_lots=ExtSymbolsSummaries[r][BUY_LOTS];
      double sell_lots=ExtSymbolsSummaries[r][SELL_LOTS];
      buy_lots=NormalizeDouble(buy_lots,2);
      sell_lots=NormalizeDouble(sell_lots,2);

      double buy_product=ExtSymbolsSummaries[r][BUY_PRICE];
      double sell_product=ExtSymbolsSummaries[r][SELL_PRICE];

      if(buy_lots!=0)
         buy_price=buy_product/buy_lots;
      if(sell_lots!=0)
         sell_price=sell_product/sell_lots;
      buy_price=NormalizeDouble(buy_price,Digits);
      sell_price=NormalizeDouble(sell_price,Digits);

      if((buy_price>0 && sell_price>0) && (buy_lots!=sell_lots))
        {
         double Rate=0,Rate2=0;
         double Distance=0,Distance2;
         Distance=MathAbs(buy_price-sell_price);

         if(buy_lots<sell_lots)
            Rate2=NormalizeDouble(buy_lots/sell_lots,Digits);
         else if(buy_lots>sell_lots)
            Rate2=NormalizeDouble(sell_lots/buy_lots,Digits);
         Rate=1-Rate2;

         Distance2=(Distance/Rate)*Rate2;
         Distance2+=(Point*MarketInfo(Symbol(),MODE_SPREAD));

         if(buy_lots<sell_lots)
            priceHege=sell_price-Distance2;
         else if(buy_lots>sell_lots)
            priceHege=buy_price+Distance2;
         priceHege=NormalizeDouble(priceHege,Digits);

         ObjectSetInteger(0,ExtName+"BTN_H_BothRuler",OBJPROP_BGCOLOR,clrYellow);
         ObjectSetInteger(0,ExtName+"BTN_H_BothRuler",OBJPROP_BORDER_COLOR,clrBlack);

         HLineCreate_(0,ExtName+"H_Hege","",0,priceHege,clrYellowGreen,0,1,0,false,false,0);
        }
      else
        {
         priceHege=0;
         HLineDelete(0,ExtName+"H_Hege");
         HLineDelete(0,"H_Both_Ruler");

         ObjectSetInteger(ChartID(),ExtName+"BTN_H_BothRuler",OBJPROP_BGCOLOR,clrBlack);
         ObjectSetInteger(ChartID(),ExtName+"BTN_H_BothRuler",OBJPROP_BORDER_COLOR,clrBlack);
        }

      if(buy_price>0)
        {
         HLineCreate_(0,ExtName+"H_Buy",c(buy_lots/2,2),0,buy_price,clrRoyalBlue,0,1,false,0,false,0);
         //---
         if(!ObjectFind(0,ExtName+"H_ifTragetBuy") && !ObjectFind(0,ExtName+"H_ifTragetBuy2") && true)
           {
            double _GetBuyT=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_ifTragetBuy",OBJPROP_PRICE),Digits);
            double _GetBuyT2=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_ifTragetBuy2",OBJPROP_PRICE),Digits);

            if((_GetBuyTX!=_GetBuyT || _GetBuyTX2!=_GetBuyT2) && _GetBuyT!=0)
              {
               _GetBuyTX=_GetBuyT;
               _GetBuyTX2=_GetBuyT2;
               _GetBuyT+=(MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits));

               if(_GetBuyTX>_GetBuyTX2)
                 {
                  ObjectSetString(0,ExtName+"BTN_H_ifTragetBuy",OBJPROP_TEXT,"TragetBuy Err");
                 }
               else
                 {
                  _BuyLotTraget=_LotStep=MarketInfo(NULL,MODE_LOTSTEP);
                  while(true)
                    {
                     Price_Test=(buy_product+(_GetBuyT*_BuyLotTraget))/(buy_lots+_BuyLotTraget);
                     _BuyLotTraget+=_LotStep;

                     if(Price_Test<=_GetBuyT2)
                       {
                        Price_Test=NormalizeDouble(Price_Test,Digits);
                        _BuyLotTraget=NormalizeDouble(_BuyLotTraget,2);
                        //---
                        ObjectSetString(0,ExtName+"BTN_H_ifTragetBuy",OBJPROP_TEXT,cD(Price_Test,Digits)+" Lot "+cD(_BuyLotTraget,2));
                        //---
                        //_LabelSet("Text_R2",CORNER_RIGHT_LOWER,500,50,clrYellow,"Arial",10,"Test "+Price_Test+" | L "+cD(_BuyLotTraget,2)+" | Step"+_LotStep,"Lot");
                        break;
                       }
                    }
                 }
              }
            //_LabelSet("Text_R",CORNER_RIGHT_LOWER,500,30,clrYellow,"Arial",10,"Lime "+_GetBuyT+" | Magen "+_GetBuyT2,"Lot");
           }
         else
           {
            ObjectSetString(0,ExtName+"BTN_H_ifTragetBuy",OBJPROP_TEXT,"TragetBuy");
           }
        }
      else
        {
         //HLineDelete(0,ExtName+"H_Buy");
        }
      if(sell_price>0)
        {
         HLineCreate_(0,ExtName+"H_Sell",c(sell_lots/2,2),0,sell_price,clrTomato,0,1,false,0,false,0);
         //---
         if(!ObjectFind(0,ExtName+"H_ifTragetSell") && !ObjectFind(0,ExtName+"H_ifTragetSell2") && true)
           {
            double _GetSellT=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_ifTragetSell",OBJPROP_PRICE),Digits);
            double _GetSellT2=NormalizeDouble(ObjectGetDouble(0,ExtName+"H_ifTragetSell2",OBJPROP_PRICE),Digits);

            if((_GetSellTX!=_GetSellT || _GetSellTX2!=_GetSellT2) && _GetSellT!=0)
              {
               _GetSellTX=_GetSellT;
               _GetSellTX2=_GetSellT2;
               //_GetSellT+=(MarketInfo(NULL,MODE_SPREAD)/MathPow(10,Digits));
               if(_GetSellTX<_GetSellTX2)
                 {
                  ObjectSetString(0,ExtName+"BTN_H_ifTragetSell",OBJPROP_TEXT,"TragetSell Err");
                 }
               else
                 {
                  _SellLotTraget=_LotStep=MarketInfo(NULL,MODE_LOTSTEP);
                  while(true)
                    {
                     Price_Test=(sell_product+(_GetSellT*_SellLotTraget))/(sell_lots+_SellLotTraget);
                     _SellLotTraget+=_LotStep;

                     if(Price_Test>=_GetSellT2)
                       {
                        Price_Test=NormalizeDouble(Price_Test,Digits);
                        _SellLotTraget=NormalizeDouble(_SellLotTraget,2);
                        //---
                        ObjectSetString(0,ExtName+"BTN_H_ifTragetSell",OBJPROP_TEXT,cD(Price_Test,Digits)+" Lot "+cD(_SellLotTraget,2));
                        //---
                        //_LabelSet("Text_R2",CORNER_RIGHT_LOWER,500,50,clrYellow,"Arial",10,"Sell:Test "+Price_Test+" | L "+cD(_SellLotTraget,2)+" | Step"+_LotStep,"Lot");
                        break;
                       }
                    }
                 }
              }

            //_LabelSet("Text_R",CORNER_RIGHT_LOWER,500,30,clrYellow,"Arial",10,"Lime "+_GetSellT+" | Magen "+_GetSellT2,"Lot");
           }
         else
           {
            ObjectSetString(0,ExtName+"BTN_H_ifTragetSell",OBJPROP_TEXT,"TragetSell");
           }
        }
      else
        {
         //HLineDelete(0,ExtName+"H_Sell");
        }
     }
   else
     {
      HLineDelete(0,ExtName+"H_Buy");
      HLineDelete(0,ExtName+"H_Sell");

      priceHege=0;
      HLineDelete(0,ExtName+"H_Hege");
      HLineDelete(0,ExtName+"H_Both_Ruler");

      ObjectSetInteger(ChartID(),ExtName+"BTN_H_BothRuler",OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(ChartID(),ExtName+"BTN_H_BothRuler",OBJPROP_BORDER_COLOR,clrBlack);

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTradelevel()
  {
   if(ChartGetInteger(0,CHART_SHOW_TRADE_LEVELS,0))
     {
      ObjectSetInteger(0,ExtName+"BTN_H_SHOW_TRADE_LEVELS",OBJPROP_STATE,false);
      ObjectSetInteger(0,ExtName+"BTN_H_SHOW_TRADE_LEVELS",OBJPROP_BGCOLOR,clrLime);
      ObjectSetInteger(0,ExtName+"BTN_H_SHOW_TRADE_LEVELS",OBJPROP_BORDER_COLOR,clrLime);
     }
   else
     {
      ObjectSetInteger(0,ExtName+"BTN_H_SHOW_TRADE_LEVELS",OBJPROP_STATE,true);
      ObjectSetInteger(0,ExtName+"BTN_H_SHOW_TRADE_LEVELS",OBJPROP_BGCOLOR,clrRed);
      ObjectSetInteger(0,ExtName+"BTN_H_SHOW_TRADE_LEVELS",OBJPROP_BORDER_COLOR,clrRed);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBidAsk()
  {
   DrawVLine(ChartID(),0,"Bid",Time[0]/*+(Period()*100)*/,Time[0]*4,Bid,clrMagenta,STYLE_SOLID,"");
   if(Period()<=PERIOD_H1)
      DrawVLine(ChartID(),0,"Ask",Time[0]/*+(Period()*100)*/,Time[0]*4,Ask,clrMagenta,STYLE_SOLID,"");
   else
      ObjectDelete(ChartID(),"Ask");

//HLineCreate_(0,"Ask2","",0,Ask,C'60,60,60',0,0,false,false,false,false);

//---
   double _STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
   HLineCreate_(0,"LVStop_UP","Stop-LV: "+c(_STOPLEVEL,0)+"p",0,Ask+(Point*_STOPLEVEL),C'60,60,60',0,0,true,false,false,false);
   HLineCreate_(0,"LVStop_DW","Stop-LV: "+c(_STOPLEVEL,0)+"p",0,Bid-(Point*_STOPLEVEL),C'60,60,60',0,0,true,false,false,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTextEnd(string name,int e,int y_dist)
  {
   ObjectCreate(name,OBJ_LABEL,windex,0,0);
   ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[e]);
   ObjectSet(name,OBJPROP_YDISTANCE,y_dist);

   ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
   ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVLine(long chartID,int _windex,string name,datetime d1,datetime d2,double var,color clr,ENUM_LINE_STYLE style,string str)
  {
   if(ObjectFind(chartID,name))
     {
      ObjectCreate(chartID,name,OBJ_TREND,_windex,d1,var,d1,var);
     }
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_STYLE,style);
   ObjectMove(chartID,name,0,d1,var);
   ObjectMove(chartID,name,1,d2,var);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);

   if(str!="")
     {
      ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chartID,name,OBJPROP_TEXT,str);
     }
  }
//+------------------------------------------------------------------+
