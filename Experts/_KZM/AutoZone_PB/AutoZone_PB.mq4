//+------------------------------------------------------------------+
//|                                                  AutoZone_PB.mq4 |
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
sChart iChart_D1;
extern int Slippage=5;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   ChartSetInteger(0,CHART_SHOW_GRID,false);

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
string CMM1,CMM2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DUMP_Mark[];
int MarkCNT=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   CMM1="";
//---
   if(iChart_D1.NewBars(PERIOD_D1))
     {
      ObjectsDeleteAll(0,OBJ_ARROW);
      //---
      CMM2="";
      //---
      getZone();

      CMM2+="\n"+string(ArraySize(DUMP_Mark));
      ObjectsDeleteAll(0,OBJ_HLINE);
      for(int i=0;i<MarkCNT;i++)
        {
         HLineCreate(0,"A"+string(i),"",0,DUMP_Mark[i],clrYellow,2,1,false,false,false,false,0);
        }
      //---
     }
   AutoPending_Boston();
   Comment(CMM1+"\n"+CMM2);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//OnTick();
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
bool HLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="HLine",// line name 
                 const string          str="Text",
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
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,str);
     }

   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID = 0,// chart's ID 
               const string name="HLine",// line name 
               double       price=0,
               const color  clr=clrYellow) // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      //Print(__FUNCTION__,": failed to move the horizontal line! Error code = ",GetLastError()); 
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
void getZone()
  {

   int Bars15=20*96;
   ArrayResize(DUMP_Mark,Bars15,0);

   double iCustomVAr=0;
   MarkCNT=0;
   for(int i=0;i<Bars15;i++)
     {
      iCustomVAr=iCustom(Symbol(),PERIOD_M15,"My/ZigZag",12,80,0,0,false,0,i);
      //printf(iCustomVAr);

      if(iCustomVAr>0)
        {
         DUMP_Mark[MarkCNT]=iCustomVAr;
         MarkCNT++;
        }
     }
   int ConntNew=0;
   for(int r=0;r<Bars15/2;r++)
     {
      ArraySort(DUMP_Mark,0,0,MODE_DESCEND);
      ConntNew=0;
      for(int i=0;i<MarkCNT;i++)
        {
         if(DUMP_Mark[i]>0)
           {
            ConntNew++;
            if(MathAbs(DUMP_Mark[i]-DUMP_Mark[i+1])<50*Point)
              {
               DUMP_Mark[i+1]=0;
              }
           }
        }
      MarkCNT=ConntNew;
     }
   ArrayResize(DUMP_Mark,MarkCNT,0);
   ArraySort(DUMP_Mark,0,0,MODE_ASCEND);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoPending_Boston()
  {
   int OrderMagic=2;
//---
   int Send_=1;
   bool Found=false,Chk_Del=false;
   double Pin=-1,TP=0,lot=-1;
   string Spector="",OP_Cm="";;
   int OP_HaveInDock=0;
   int checkError=-1;

   for(int i=0;i<ArraySize(DUMP_Mark)-1;i++)
     {
      Found=false;
      OP_HaveInDock=0;
      Spector="";if(MathMod(i,MarkCNT)==0) Spector="*";

      //---
      Pin=DUMP_Mark[i];
      TP=DUMP_Mark[i+1];
      NormalizeDouble(TP,Digits);
      //---
/* if(Calculate_Margin)
         lot=LotGet_Magin(Capital,Pin,DeadLine);
      else
         lot=LotGet(Capital,Pin,DeadLine);
      lot=StringToDouble(c(lot,2));*/
      lot=0.1;

      double Pin_Capital=10;
      //double Pin_Magin=_Pin_Magin;

      for(int pos=0;pos<OrdersTotal() && lot>0;pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if((OrderSymbol()==Symbol())==false) continue;
         if((OrderMagicNumber()==OrderMagic)==false) continue;

         // printf(l(__LINE__)+OrderTicket());
         double _OrderOpenPrice=OrderOpenPrice();
         double Slippagep=(Slippage+1)/MathPow(10,Digits);

         if(((DUMP_Mark[i]-Slippagep)<=(_OrderOpenPrice)) && ((_OrderOpenPrice)<(DUMP_Mark[i+1]-Slippagep)))
           {
            Found=true;

            if(OrderType()>=2)
              {
               if(OrderLots()!=lot || (DUMP_Mark[i]!=OrderOpenPrice()))
                 {
                  Chk_Del=OrderDelete(OrderTicket(),0);
                  //---
                  if(DUMP_Mark[i]>Ask && OP_HaveInDock==0)
                    {
                     //OP_Cm=Spector+c(i)+"_P1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+DoubleToStr(DUMP_Mark[i],Digits),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (DUMP_Mark[i]<=Ask && Ask<DUMP_Mark[i+1]))
                       {
                        //OP_Cm=Spector+c(i)+"_A1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__)+DoubleToStr(DUMP_Mark[i],Digits),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                  else if(DUMP_Mark[i]<Ask && OP_HaveInDock==0)
                    {
                     //OP_Cm=Spector+c(i)+"_P1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYLIMIT,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+DoubleToStr(DUMP_Mark[i],Digits),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (DUMP_Mark[i]<=Ask && Ask<DUMP_Mark[i+1]))
                       {
                        //OP_Cm=Spector+c(i)+"_A1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__)+DoubleToStr(DUMP_Mark[i],Digits),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                 }
               else
                 {
                  if(OrderTakeProfit()!=TP)
                    {//Slippage
                     if(OrderOpenPrice()<TP && TP!=DUMP_Mark[i])
                       {
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,TP,0,clrGold);
                       }
                     else
                       {
                        double d=MathAbs(DUMP_Mark[i]-DUMP_Mark[i+1]);
                        d=NormalizeDouble(OrderOpenPrice()+d,Digits);
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,d,0,clrYellow);
                       }
                    }
                 }
               if(OP_HaveInDock>1 || DUMP_Mark[i]!=OrderOpenPrice())
                 {
                  Chk_Del=OrderDelete(OrderTicket(),0);
                 }
              }
            else
              {
               OP_HaveInDock++;
               if(OrderTakeProfit()!=TP)
                 {
                  if(OrderOpenPrice()<TP)
                    {
                     Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP,0,clrGold);
                    }
                  else
                    {
                     double d=MathAbs(DUMP_Mark[i]-DUMP_Mark[i+1]);
                     d=NormalizeDouble(OrderOpenPrice()+(d*0.75),Digits);
                     //Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),d,0,clrYellow);
                    }
                 }
              }
           }
        }
      //
      //---
      if(Found==false && lot>0)
        {
         if(DUMP_Mark[i]>Ask && OP_HaveInDock==0)
           {
            //OP_Cm=Spector+c(i)+"_P2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+DoubleToStr(DUMP_Mark[i],Digits),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (DUMP_Mark[i]<=Ask && Ask<DUMP_Mark[i+1]))
              {
               //OP_Cm=Spector+c(i)+"_A2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
               ResetLastError();
               //Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
         else if(DUMP_Mark[i]<Ask && OP_HaveInDock==0)
           {
            //OP_Cm=Spector+c(i)+"_P2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_BUYLIMIT,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+DoubleToStr(DUMP_Mark[i],Digits),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (DUMP_Mark[i]<=Ask && Ask<DUMP_Mark[i+1]))
              {
               //OP_Cm=Spector+c(i)+"_A2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
               ResetLastError();
               //Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,Spector+c(i)+"_AC_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
        }
     }
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderSymbol()==Symbol())==false) continue;
      if((OrderMagicNumber()==OrderMagic)==false) continue;
      if(OrderType()<=1) continue;

      if(OrderOpenPrice()<DUMP_Mark[0] || OrderOpenPrice()>DUMP_Mark[ArraySize(DUMP_Mark)-1])
        {
         bool  z=OrderDelete(OrderTicket(),0);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string l(int Line)
  {
   return "#"+string(Line)+" ";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string l(int Line,string VarName)
  {
   return "#"+string(Line)+" "+" | "+VarName+" : ";
  }
//+------------------------------------------------------------------+
