//+------------------------------------------------------------------+
//|                                                 Test_HighLow.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
string Draft="Draft";
double TroopA[1];
double TroopB[1][2];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

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
   ENUM_TIMEFRAMES TF=PERIOD_H4;
   if(_iNewBar(TF))
     {
      ObjectsDeleteAll(ChartID(),Draft,0,OBJ_HLINE);
      string SMM;
      
      double Day_=5;
      double Period_=(Day_*PERIOD_D1)/TF;

      double Period_ALL=(250*PERIOD_D1)/TF;
      SMM+=l(__LINE__)+"Period_: "+c(Period_,2)+"\n";

      for(int i=0;i<Period_ALL;i++)
        {
         //Chk(string type,int strat,int count)
         Chk(c(i),TF,i,int(Period_));
        }
      printf(l(__LINE__,"Day_")+Day_+" | "+TF);
      printf(l(__LINE__,"Period_")+Period_);

      printf(l(__LINE__,"Period_ALL")+Period_ALL);
      datetime DrawiTime=iTime(Symbol(),TF,int(Period_ALL));
      printf(l(__LINE__,"DrawiTime")+DrawiTime);

      //VLineCreate(0,"V_iLow_Open",0,DrawiTime,clrWhite,0,1,true,false,false,0);
      //---
        {
         int Obj=ObjGet_Count(Draft);
         SMM+=l(__LINE__)+"Obj: "+c(Obj)+"\n";
         //---
         ArrayResize(TroopA,Obj,0);
         ArrayResize(TroopB,Obj,0);
         ArrayInitialize(TroopB,0.00);
         for(int i=0;i<ObjectsTotal();i++)
           {
            string name=ObjectName(i);
            if(StringFind(name,"Draft",0)>=0)
              {
               TroopA[i]=NormalizeDouble(ObjectGetDouble(0,name,OBJPROP_PRICE),Digits);
              }
           }
         //---
         if(ArraySize(TroopA)>0)
            ArraySort(TroopA,WHOLE_ARRAY,0,MODE_ASCEND);
         SMM+=l(__LINE__)+"TroopA[0]: "+c(TroopA[0],Digits)+"\n";
         double Current=TroopA[0];
         for(int i=0,j=0;i<ArraySize(TroopA);i++)
           {
            if(TroopA[i]==Current)
              {
               TroopB[j][0]++;
              }
            else
              {
               Current=TroopA[i];
               TroopB[j][1]=TroopA[i];
               TroopB[j][0]++;
               j++;
              }
           }
         ArraySort(TroopB,WHOLE_ARRAY,0,MODE_DESCEND);
         double Weight_Max=TroopB[0][0];
         double Weight_Avg=0;
           {
            double CountCur=TroopB[0][0];
            int j=0,Rank=10;
            if(Obj<10)Rank=Obj;
            for(int i=0;i<Obj;i++)
              {
               if(TroopB[i][0]!=Current && TroopB[i][1]!=0)
                 {
                  Current=TroopB[i][0];
                  Weight_Avg+=TroopB[i][0];
                  j++;
                  //SMM+=l(__LINE__)+c(j)+": "+c(TroopB[i][0],0)+"|"+c(TroopB[i][1],Digits)+"\n";
                  if(j==Rank)break;
                 }
              }
            Weight_Avg=Weight_Avg/j;
            SMM+=l(__LINE__,"Avg["+c(j,0)+"]")+c(Weight_Avg,4)+"\n";
            SMM+=l(__LINE__,"Weight_Max")+c(Weight_Max,0)+"\n";
           }
           {
            ObjectsDeleteAll(ChartID(),Draft,0,OBJ_HLINE);
            int Draftcnt=0;
            for(int i=0;i<Obj;i++)
              {
               if(TroopB[i][1]>0 && TroopB[i][0]>=20)
                 {
                  int boder=0;
                  color clrDraft=clrRoyalBlue;
                  ENUM_LINE_STYLE STYLE=3;
                  if(TroopB[i][0]>=Weight_Avg)
                    {
                     //boder=3;
                     clrDraft=clrRed;
                     STYLE=0;
                     _HLineCreate(0,Draft+c(i),c(TroopB[i][0],0)+"|"+c(TroopB[i][1],Digits),0,TroopB[i][1],clrDraft,STYLE,boder,1,false,true,false,0);
                     Draftcnt++;
                    }
                  //_HLineCreate(0,Draft+c(i),c(TroopB[i][0],0)+"|"+c(TroopB[i][1],Digits),0,TroopB[i][1],clrDraft,STYLE,boder,1,false,true,false,0);
                  //Draftcnt++;
                 }
              }
            SMM+=l(__LINE__)+"Draftcnt: "+c(Draftcnt,0)+"\n";
           }
        }
      Comment(SMM);
     }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

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
void Chk(string type,ENUM_TIMEFRAMES tf,int strat,int count)
  {
   double val_1=0,val_2=0,val_3=0,val_4=0;
   double val_5=0,val_6=0;

   int _iHigh_High=iHighest(NULL,tf,MODE_HIGH,count,strat);
   int _iHigh_Open=iHighest(NULL,tf,MODE_OPEN,count,strat);
   int _iHigh_Close=iHighest(NULL,tf,MODE_OPEN,count,strat);

   int _iLow_Open=iLowest(NULL,tf,MODE_CLOSE,count,strat);
   int _iLow_Close=iLowest(NULL,tf,MODE_CLOSE,count,strat);
   int _iLow_LOW=iLowest(NULL,tf,MODE_LOW,count,strat);

//---
   if(_iHigh_Open!=0) val_1=iOpen(Symbol(),tf,_iHigh_Open);
   if(_iHigh_Close!=0) val_2=iClose(Symbol(),tf,_iHigh_Close);

//printf(l(__LINE__)+_iLow_Open);
   if(_iLow_Open!=0) val_3=iOpen(Symbol(),tf,_iLow_Open);
   if(_iLow_Close!=0) val_4=iClose(Symbol(),tf,_iLow_Close);

   if(_iHigh_High!=0) val_5=iHigh(Symbol(),tf,_iHigh_High);
   if(_iLow_LOW!=0) val_6=iLow(Symbol(),tf,_iLow_LOW);

//VLineCreate(0,"BarStart",0,Time[BarStart],clrWhite,0,1,true,false,false,0);
//VLineCreate(0,"BarFocus",0,Time[BarFocus],clrWhite,0,1,true,false,false,0);

//VLineCreate(0,"V_iHigh_Open",0,Time[_iHigh_Open],clrMagenta,0,1,true,false,false,0);

//VLineCreate(0,"V_iHigh_Close",0,Time[_iHigh_Close],clrMagenta,0,1,true,false,false,0);

   _HLineCreate(0,Draft+type+"H_iHigh_Open",c(val_1,Digits),0,val_1,clrRed,0,0,1,false,true,false,0);
   _HLineCreate(0,Draft+type+"H_iHigh_Close",c(val_2,Digits),0,val_2,clrRoyalBlue,2,0,1,false,true,false,0);

//VLineCreate(0,"V_iLow_Open",0,Time[_iLow_Open],clrRed,0,1,true,false,false,0);

//VLineCreate(0,"V_iLow_Close",0,Time[_iLow_Close],clrRed,0,1,true,false,false,0);
   _HLineCreate(0,Draft+type+"H_iLow_Open",c(val_3,Digits),0,val_3,clrRed,2,0,1,false,true,false,0);
   _HLineCreate(0,Draft+type+"H_iLow_Close",c(val_4,Digits),0,val_4,clrRoyalBlue,0,0,1,false,true,false,0);

   _HLineCreate(0,Draft+type+"H_iHigh_High","",0,val_5,clrDimGray,2,0,1,false,true,false,0);
   _HLineCreate(0,Draft+type+"H_iLow_LOW","",0,val_6,clrDimGray,2,0,1,false,true,false,0);
/*
   RectangleDelete(0,type+"H");
   RectangleDelete(0,type+"L");
   RectangleCreate(0,type+"H",0,Time[strat],val_1,Time[count],val_2,clrDimGray,1,1,true,true,false,false,0);
   RectangleCreate(0,type+"L",0,Time[strat],val_3,Time[count],val_4,clrDimGray,1,1,true,true,false,false,0);
*/
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjGet_Count(string Searched)
  {
   int cnt=0;
   for(int i=0;i<ObjectsTotal();i++)
     {
      if(StringFind(ObjectName(i),Searched,0)>=0)
        {
         cnt++;
        }
     }
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _HLineCreate(long              chart_ID,// chart's ID 
                  string            name,// line name 
                  string            str,
                  int               sub_window,// subwindow index 
                  double            price,// line price 
                  color             clr,// line color 
                  ENUM_LINE_STYLE   style,// line style 
                  int               width,// line width 
                  bool              back,// in the background 
                  bool              selection,     // highlight to move 
                  bool              lock,          // highlight to move 
                  bool              hidden,// hidden in the object list 
                  long              z_order) // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      if(str!="")
        {
         ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,str);
         ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
        }
      //Print(__FUNCTION__,": failed to create a horizontal line! Error code = ",GetLastError());
      //return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,lock);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   if(str!="")
     {
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
     }

   return(true);
  }
//+------------------------------------------------------------------+
