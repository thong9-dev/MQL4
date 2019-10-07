//+------------------------------------------------------------------+
//|                                                          _F0.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//if(false)
     {
      string name="panel";
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,-100);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,-100);
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
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

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
double Cont=1000;//MarketInfo(Symbol(),MODE_LOTSIZE);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

   if(id==CHARTEVENT_OBJECT_CLICK || id==CHARTEVENT_CLICK || id==CHARTEVENT_CHART_CHANGE)
     {
      string CMM="";
      for(int i=0;i<20;i++)
        {
         CMM+="\n";
        }
      Print("CHARTEVENT_OBJECT_CLICK '"+sparam+"'");

      double Obj_Bid=-1,Obj_Hege=-1;
      int Obj_Buy=0,Obj_Sell=0;
      double Product_Buy=0,Ratio_Buy=0;
      double Product_Sell=0,Ratio_Sell=0;
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      color ObjClr=-1;
      int Obj_STYLE=-1;
      double Obj_Lot=0,Obj_Price=0;
      //---
      int Obj_Total=ObjectsTotal(0,0,OBJ_HLINE);
      CMM+="\n Obj_Total: "+string(Obj_Total);
      for(int i=0;i<Obj_Total;i++)
        {
         string name=ObjectName(i);

         Obj_STYLE=int(ObjectGetInteger(0,name,OBJPROP_STYLE));
         Obj_Lot=double(ObjectGetString(0,name,OBJPROP_TEXT,0));
         if(Obj_STYLE==2 && Obj_Lot>0)
           {
            ObjClr=color(ObjectGetInteger(0,name,OBJPROP_COLOR));
            Obj_Price=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
            Obj_Lot=double(ObjectGetString(0,name,OBJPROP_TEXT,0));
            //            
            ObjectSetString(0,name,OBJPROP_TOOLTIP,DoubleToStr(Obj_Lot,2));
            if(ObjClr==clrRed)
              {
               Obj_Sell++;

               Product_Sell+=Obj_Price*Obj_Lot;
               Ratio_Sell+=Obj_Lot;
               //

              }
            if(ObjClr==clrLime)
              {
               Obj_Buy++;

               Product_Buy+=Obj_Price*Obj_Lot;
               Ratio_Buy+=Obj_Lot;
              }
            if(ObjClr==clrYellow)
              {
               Obj_Bid=Obj_Price;
              }
            if(ObjClr==clrDeepSkyBlue)
              {
               Obj_Hege=Obj_Price;
              }
           }

        }
      //+------------------------------------------------------------------+
      double Nav_Buy=-1,Nav_Sell=-1;
      double d=-1;
      //---

      if(Ratio_Buy>0)
        {
         Product_Buy=Product_Buy/Ratio_Buy;

         d=NormalizeDouble(Obj_Bid-Product_Buy,Digits);
         Nav_Buy=NormalizeDouble((Ratio_Buy/Product_Buy)*(d*Cont),2);

         HLineCreate(0,"Product_Buy",Ratio_Buy,Ratio_Buy,0,Product_Buy,
                     clrLime,0,2,false,false,false,false,0);

        }
      else
        {
         ObjectDelete(0,"Product_Buy");
        }
      //
      if(Ratio_Sell>0)
        {
         Product_Sell=Product_Sell/Ratio_Sell;

         d=NormalizeDouble(Product_Sell-Obj_Bid,Digits);
         Nav_Sell=NormalizeDouble((Ratio_Sell/Product_Sell)*(d*Cont),2);

         HLineCreate(0,"Product_Sell",Ratio_Sell,Ratio_Sell,0,Product_Sell,
                     clrRed,0,2,false,false,false,false,0);
        }
      else
        {
         ObjectDelete(0,"Product_Sell");
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+

      double Space=MathAbs(Product_Buy-Product_Sell);
      double Product_Cover=-1,Ratio_Cover=-1;
      if(Ratio_Buy>Ratio_Sell)
        {

         Ratio_Cover=NormalizeDouble(Ratio_Sell/(Ratio_Buy-Ratio_Sell),4);
         Product_Cover=NormalizeDouble(Space*Ratio_Cover,Digits);

         Product_Cover=Product_Buy+Product_Cover;
        }
      if(Ratio_Buy<Ratio_Sell)
        {
         Ratio_Cover=NormalizeDouble(Ratio_Buy/(Ratio_Buy-Ratio_Sell),4);
         Product_Cover=NormalizeDouble(Space*Ratio_Cover,Digits);

         Product_Cover=Product_Sell+Product_Cover;
        }

      HLineCreate(0,"Product_Cover","","",0,Product_Cover,
                  clrMagenta,0,2,false,false,false,false,0);

/*HLineCreate(0,"Bid","","",0,Product_Cover,
                  clrYellow,2,1,false,true,true,false,0);*/
      double D=Product_Buy-Obj_Bid;
      //+------------------------------------------------------------------+
      double SumPort=CoverCurrency(Nav_Buy+Nav_Sell,StringSubstr(Symbol(),0,3),AccountInfoString(ACCOUNT_CURRENCY));
      //+------------------------------------------------------------------+
      CMM+="\n Obj_Bid: "+DoubleToStr(Obj_Bid,Digits);
      CMM+="\n Obj_Buy: "+string(Obj_Buy)+"|"+DoubleToStr(Ratio_Buy,2)+" | "+DoubleToStr(Product_Buy,Digits)+" | "+DoubleToStr(Nav_Buy,Digits);
      CMM+="\n Obj_Sell: "+string(Obj_Sell)+"|"+DoubleToStr(Ratio_Sell,2)+" | "+DoubleToStr(Product_Sell,Digits)+" | "+DoubleToStr(Nav_Sell,Digits);
      CMM+="\n Sum: "+DoubleToStr(SumPort,2);
      CMM+="\n ----";
      CMM+="\n Product_Cover: "+DoubleToStr(Product_Cover,Digits);
      CMM+="\n ----";
      CMM+="\n Buy-Sell: "+DoubleToStr(Product_Buy-Product_Sell,Digits);
      CMM+="\n Buy: "+DoubleToStr(Product_Buy-Obj_Bid,Digits);
      CMM+="\n Sell: "+DoubleToStr(Product_Sell-Obj_Bid,Digits);
      Comment(CMM);
     }

  }
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="HLine",// line name 
                 const string          str="Text",
                 const string          TOOLTIP="Text",
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrYellow,// line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            SELECTABLE=true,// move 
                 const bool            selection=true,// highlight to move 
                 const bool            hidden=false,// hidden in the object list 
                 const long            z_order=0) // priority for mouse click 
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
      HLineMove(chart_ID,name,price,clr);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,SELECTABLE);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   if(str!="")
     {
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,TOOLTIP);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
     }

   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sOrderGetHege
  {
   double            Product_Buy;
   double            Product_Sell;
   double            Product_Hege;

   double            Ratio_Buy;
   double            Ratio_Sell;

   void OrderHege(string symbol)
     {
      Empty();

      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderSymbol()!=symbol) continue;

         if(OrderType()==OP_BUY)
           {
            Product_Buy+=OrderOpenPrice()*OrderLots();
            Ratio_Buy+=OrderLots();
           }
         if(OrderType()==OP_SELL)
           {
            Product_Sell+=OrderOpenPrice()*OrderLots();
            Ratio_Sell+=OrderLots();
           }
        }
      if(Ratio_Buy>0)
        {
         Product_Buy=Product_Buy/Ratio_Buy;
        }
      if(Ratio_Sell>0)
        {
         Product_Sell=Product_Sell/Ratio_Sell;
        }
      if(Ratio_Buy>0 && Ratio_Sell>0)
        {
         double Space=MathAbs(Product_Buy-Product_Sell);
         double Product_Cover=-1,Ratio_Cover=-1;

         if(Ratio_Buy>Ratio_Sell)
           {
            Ratio_Cover=NormalizeDouble(Ratio_Sell/(Ratio_Buy-Ratio_Sell),4);
            Product_Cover=NormalizeDouble(Space*Ratio_Cover,Digits);

            Product_Hege=Product_Buy+Product_Cover;
           }
         if(Ratio_Buy<Ratio_Sell)
           {
            Ratio_Cover=NormalizeDouble(Ratio_Buy/(Ratio_Buy-Ratio_Sell),4);
            Product_Cover=NormalizeDouble(Space*Ratio_Cover,Digits);

            Product_Hege=Product_Sell+Product_Cover;
           }
        }
     }
private:
   void Empty()
     {
      Product_Buy=0;
      Product_Sell=0;
      Product_Hege=0;

      Ratio_Buy=0;
      Ratio_Sell=0;
     }
  };
//+------------------------------------------------------------------+
double CoverCurrency(double cap,string c1,string c2)
  {
   double r=0;
   if(c1==c2)
     {
      r=cap;
      printf(l(__LINE__,"Is already "+c1));
     }
   else
     {
      string Pair_1=c1+c2;
      string Pair_2=c2+c1;
      double Rate_1=MarketInfo(Pair_1,MODE_BID);
      double Rate_2=MarketInfo(Pair_2,MODE_BID);

      printf(l(__LINE__,"Rate_1:"+Pair_1)+c(Rate_1,int(MarketInfo(Pair_1,MODE_DIGITS))));
      printf(l(__LINE__,"Rate_2:"+Pair_2)+c(Rate_2,int(MarketInfo(Pair_2,MODE_DIGITS))));
      if(Rate_1>0)
        {
         int digit=int(MarketInfo(Pair_1,MODE_DIGITS));
         printf(l(__LINE__,"Rate_1:[*]"+Pair_1)+c(Rate_1,digit));

         r=cap*Rate_1;
         r=NormalizeDouble(r,digit);
        }
      else if(Rate_2>0)
        {
         int digit=int(MarketInfo(Pair_2,MODE_DIGITS));
         printf(l(__LINE__,"Rate_2:[/]"+Pair_2)+c(Rate_2,digit));

         r=cap/Rate_2;
         r=NormalizeDouble(r,digit);
        }
     }

   return NormalizeDouble(r,2);
  }
//+------------------------------------------------------------------+
