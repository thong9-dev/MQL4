//+------------------------------------------------------------------+
//|                                                     Rosegold.mq4 |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "Rosegold.mq4";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setBUTTON(string name,int panel,
                int XSIZE,int YSIZE,
                int XDIS,int YDIS,
                int FONTSIZE,color COLOR,color BG)
  {
//---
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(0,name,OBJ_BUTTON,panel,0,0);
     }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDIS);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDIS);
//---
   ObjectSetInteger(0,name,OBJPROP_XSIZE,XSIZE);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,YSIZE);

   ObjectSetString(0,name,OBJPROP_TEXT,name);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,name,OBJPROP_COLOR,COLOR);
//---

  }
//+------------------------------------------------------------------+
void _setBUTTON_State()
  {

   _setBUTTON_State("BTN_X__BUY",clrGreen);
   _setBUTTON_State("BTN_X_SELL",clrRed);
   _setBUTTON_State("BTN_X__ALL",clrGold);
   _setBUTTON_State("BTN_X_PROFIT",clrGold);

   _setBUTTON_State("BTN_BUY",clrGreen);
   _setBUTTON_State("BTN_SELL",clrRed);

   _setBUTTON_State("SCLR",clrMagenta);

  }
//+------------------------------------------------------------------+
void _setBUTTON_State(string name,color BG)
  {
   if(ObjectGetInteger(0,name,OBJPROP_STATE))
     {
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BG);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _LabelCreate(string name,int panel)
  {
   if(!ObjectCreate(name,OBJ_LABEL,panel,0,0))
     {
      //Print(__FUNCTION__,":1 failed SetText = ",GetLastError()); 
      return(false);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _LabelSet(string name,int x,int y,color clr,string front,int Size,string text)
  {
   if(ObjectFind(0,name)<0)
     {
      _LabelCreate(name,0);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!ObjectSet(name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,":2 failed SetText = ",(string)GetLastError()+"["+name+"]");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!ObjectSet(name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,":3 failed SetText = ",(string)GetLastError()+"["+name+"]");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!ObjectSetText(name,text,Size,front,clr))
     {
      Print(__FUNCTION__,":4 failed SetText = ",(string)GetLastError()+"["+name+"]");
      return(false);
     }
//ObjectSet(name, OBJPROP_BACK, false);
/*
CORNER_LEFT_UPPER
CORNER_LEFT_LOWER
CORNER_RIGHT_LOWER
CORNER_RIGHT_UPPER
*/
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _Order_CNT(string _OrderType,int _MagicNumber)
  {
   int CNT=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()) && OrderType()==_OrderType)
        {
         CNT++;
        }
     }
   return CNT;
  }
//+------------------------------------------------------------------+
int List_BUYY[30];
int List_SELL[30];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _setBlacklistOrder(string _OrderType,int _MagicNumber)
  {

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()) && OrderType()==_OrderType)
        {
         if(_OrderType==OP_BUY){List_BUYY[pos]=OrderTicket();}
         if(_OrderType==OP_SELL){List_SELL[pos]=OrderTicket();}
        }
     }

   _chkBlacklistOrder(_OrderType);

  }
//+------------------------------------------------------------------+
void _chkBlacklistOrder(string _OrderType)
  {
   if(_OrderType==OP_BUY)
     {
      for(int i=0;i<ArraySize(List_BUYY);i++)
        {
         if(List_BUYY[i]>0)
           {
            for(int pos=0;pos<OrdersTotal();pos++)
              {
               if(OrderSelect(List_BUYY[i],SELECT_BY_TICKET)==true);
               OrderClose(List_BUYY[i],OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100);
               if(GetLastError()==0){List_BUYY[i]=0;}
              }
           }
        }
     }
   else
     {
      for(int i=0;i<ArraySize(List_SELL);i++)
        {
         if(List_SELL[i]>0)
           {
            for(int pos=0;pos<OrdersTotal();pos++)
              {
               if(OrderSelect(List_SELL[i],SELECT_BY_TICKET)==true);
               OrderClose(List_SELL[i],OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100);
               if(GetLastError()==0){List_SELL[i]=0;}
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
string _FillZero(int v)
  {
   string temp;
   if(v<10)
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;

  }
//+------------------------------------------------------------------+
void _ChartScreenShot(string logic)
  {
   ChartNavigate(0,CHART_END,0);
   MqlDateTime MqlDate_Start;
   TimeToStruct(TimeLocal(),MqlDate_Start);
   string EA_Name="ABCDEFGHIJK";
   string FileName=(string)"ChartScreenShot "+MqlDate_Start.year+"/"+
                   _FillZero(MqlDate_Start.mon)+" M/"+
                   _FillZero(MqlDate_Start.day)+" D/";
   FileName+=StringSubstr(EA_Name,0,5)+"["+StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1)+
             _FillZero(MqlDate_Start.hour)+""+
             _FillZero(MqlDate_Start.min)+""+
             _FillZero(MqlDate_Start.sec)+"]";

   FileName+="["+logic+"].png";

//+------------------------------------------------------------------+
//--- Save the chart screenshot in a file in the terminal_directory\MQL4\Files\
   ChartScreenShot(0,FileName,1280,720,ALIGN_RIGHT);

  }
//+------------------------------------------------------------------+
void _setTemplate()
  {

   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);

   ChartSetInteger(0,CHART_COLOR_GRID,clrWhite);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
  }
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {

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
void HLineCreate_(const long            chart_ID=0,// chart's ID 
                  const string          name="HLine",      // line name 
                  const int             sub_window=0,      // subwindow index 
                  double                price=0,           // line price 
                  const color           clr=clrYellow,// line color 
                  const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                  const int             width=1,           // line width 
                  const bool            back=false,        // in the background 
                  const bool            selection=true,    // highlight to move 
                  const bool            hidden=false,// hidden in the object list 
                  const long            z_order=0) // priority for mouse click 
  {

   bool z=HLineCreate(chart_ID,name,sub_window,price,clr,style,width,back,selection,hidden,z_order);
   if(!z)
     {
      HLineMove(chart_ID,name,price,clr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,// chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrYellow,// line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
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
      //Print(__FUNCTION__,": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 

   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID = 0,// chart's ID 
               const string name="HLine",// line name 
               double       price=0,
               const color  clr=clrYellow,) // line price 
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
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,// chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(ObjectFind(chart_ID,name)>=0)
     {
      if(!ObjectDelete(chart_ID,name))
        {
         Print(__FUNCTION__,": failed to delete a horizontal line! Error code = ",GetLastError());
         return(false);
        }
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
