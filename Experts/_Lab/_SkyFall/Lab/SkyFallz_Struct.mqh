//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
enum eMODE_CALLCANDLE
  {
   M_CALLCANDLE_OC=0,
   M_CALLCANDLE_HL=1
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sACCOUNT
  {
   double            Capital;
   double            Profit;
   double            Holding;
   double            Balance;

   double            Drawdawn;

   double            Lots;
   double            LotsBuy;
   double            LotsSell;

   double            OrdersTotals;
   double            OrdersTotalBuy;
   double            OrdersTotalSell;

   void sACCOUNT()
     {
      Capital=AccountInfoDouble(ACCOUNT_BALANCE);
     };
   double getHolding()
     {
      Holding=AccountInfoDouble(ACCOUNT_PROFIT);
      return Holding;
      //ACCOUNT_BALANCE
     };
   double getHoldingP()
     {
      Capital=AccountInfoDouble(ACCOUNT_BALANCE);
      return NormalizeDouble((getHolding()/Capital)*100,2);
     };
   double getProfit()
     {
      Balance=AccountInfoDouble(ACCOUNT_BALANCE);
      Profit=Balance-Capital;
      return Profit;
     };
   double getMaxDD()
     {
      double h=getHolding();
      if(Drawdawn>h) Drawdawn=h;
      return Drawdawn;
     };
   void iPort()
     {
      Lots=0;
      LotsBuy=0;
      LotsSell=0;

      OrdersTotalBuy=0;
      OrdersTotalSell=0;

      Balance=AccountInfoDouble(ACCOUNT_BALANCE);
      Profit=getProfit();

      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderType()==OP_BUY)
           {
            LotsBuy+=OrderLots();
            OrdersTotalBuy++;
           }
         if(OrderType()==OP_SELL)
           {
            LotsSell+=OrderLots();
            OrdersTotalSell++;
           }
        }
      Lots=LotsBuy-LotsSell;
      OrdersTotals=OrdersTotalBuy+OrdersTotalSell;
     }
   string iBalance(){return DoubleToStr(Balance,2);};

   string iLots(){return DoubleToStr(Lots,2);};
   string iLotsBuy(){return DoubleToStr(LotsBuy,2);};
   string iLotsSell(){return DoubleToStr(LotsSell,2);};

   string iOrdersTotals(){return DoubleToStr(OrdersTotals,0);};
   string iOrdersTotalBuy(){return DoubleToStr(OrdersTotalBuy,0);};
   string iOrdersTotalSell(){return DoubleToStr(OrdersTotalSell,0);};

  };
//+------------------------------------------------------------------+
struct sHLINE
  {
   long              chart_ID;
   int               sub_window;

   string            name;
   string            str;
   double            price;

   color             clr;
   ENUM_LINE_STYLE   style;
   int               width;

   bool              SELECTABLE;
   bool              selection;

   bool              back;
   bool              hidden;

   long              z_order;
  };
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
bool VLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="VLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time=0,            // line time 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            lock=true,// 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the line time is not set, draw it via the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      VLineMove(chart_ID,name,time,clr);
      //Print(__FUNCTION__,": failed to create a vertical line! Error code = ",GetLastError());
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
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the vertical line                                           | 
//+------------------------------------------------------------------+ 
bool VLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="VLine", // line name 
               datetime     time=0,// line time 
               const color  clr=clrRed)// line color
  {
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- if line time is not set, move the line to the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      VLineMove(chart_ID,name,time);
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="TrendLine",  // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time1=0,           // first point time 
                 double                price1=0,          // first point price 
                 datetime              time2=0,           // second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            ray_right=false,   // line's continuation to the right 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- create a trend line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      ObjectMove(chart_ID,name,0,time1,price1);
      ObjectMove(chart_ID,name,1,time2,price2);
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
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move trend line anchor point                                     | 
//+------------------------------------------------------------------+ 
bool TrendPointChange(const long   chart_ID=0,       // chart's ID 
                      const string name="TrendLine", // line name 
                      const int    point_index=0,    // anchor point index 
                      datetime     time=0,           // anchor point time coordinate 
                      double       price=0)          // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move trend line's anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one 
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one 
   if(!price2)
      price2=price1;
  }
//+------------------------------------------------------------------+
bool ChannelCreate(const long            chart_ID=0,        // chart's ID 
                   const string          name="Channel",    // channel name 
                   const int             sub_window=0,      // subwindow index  
                   datetime              time1=0,           // first point time 
                   double                price1=0,          // first point price 
                   datetime              time2=0,           // second point time 
                   double                price2=0,          // second point price 
                   datetime              time3=0,           // third point time 
                   double                price3=0,          // third point price 
                   const color           clr=clrRed,        // channel color 
                   const ENUM_LINE_STYLE style=STYLE_SOLID, // style of channel lines 
                   const int             width=1,           // width of channel lines 
                   const bool            fill=false,        // filling the channel with color 
                   const bool            back=false,        // in the background 
                   const bool            selection=true,    // highlight to move 
                   const bool            ray_right=false,   // channel's continuation to the right 
                   const bool            hidden=true,       // hidden in the object list 
                   const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeChannelEmptyPoints(time1,price1,time2,price2,time3,price3);
//--- reset the error value 
   ResetLastError();
//--- create a channel by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_CHANNEL,sub_window,time1,price1,time2,price2,time3,price3))
     {
      ObjectMove(chart_ID,name,0,time1,price1);
      ObjectMove(chart_ID,name,1,time2,price2);
      ObjectMove(chart_ID,name,2,time3,price3);
     }
//--- set channel color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set style of the channel lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the channel lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
void ChangeChannelEmptyPoints(datetime &time1,double &price1,datetime &time2,
                              double &price2,datetime &time3,double &price3)
  {
//--- if the second (right) point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value 
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first (left) point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
//--- if the first point's price is not set, move it 300 points higher than the second one 
   if(!price1)
      price1=price2+300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
//--- if the third point's time is not set, it coincides with the first point's one 
   if(!time3)
      time3=time1;
//--- if the third point's price is not set, it is equal to the second point's one 
   if(!price3)
      price3=price2;
  } 
//+------------------------------------------------------------------+
