//+------------------------------------------------------------------+
//|                                               NumChok_Method.mqh |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "NumChok.mq4";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrowRightPriceCreate(const long            chart_ID=0,        // chart's ID 
                           const string          name="RightPrice", // price label name 
                           const int             sub_window=0,      // subwindow index 
                           datetime              time=0,            // anchor point time 
                           double                price=0,           // anchor point price 
                           const color           clr=clrRed,        // price label color 
                           const ENUM_LINE_STYLE style=STYLE_SOLID, // border line style 
                           const int             width=1,           // price label size 
                           const bool            back=false,        // in the background 
                           const bool            selection=true,    // highlight to move 
                           const bool            hidden=true,       // hidden in the object list 
                           const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor point coordinates if they are not set 
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value 
   ResetLastError();
//--- create a price label 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create the right price label! Error code = ",GetLastError());
      return(false);
     }
//--- set the label color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the label size 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
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
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrowRightPriceDelete(const long   chart_ID=0,        // chart's ID 
                           const string name="RightPrice") // label name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the label 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the right price label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrowRightPriceMove(const long   chart_ID=0,// chart's ID 
                         const string name="RightPrice", // label name 
                         datetime     time=0,            // anchor point time coordinate 
                         double       price=0)           // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar 
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeFiboLevelsEmptyPoints(datetime &time1,double &price1,
                                 datetime &time2,double &price2)
  {
//--- if the second point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value 
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];

     }
//--- if the first point's price is not set, move it 200 points below the second one 
   if(!price1)
      price1=price2-200*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
bool FiboLevelsCreate(const long            chart_ID=0,// chart's ID 
                      const string          name="FiboLevels", // object name 
                      const int             sub_window=0,      // subwindow index  
                      datetime              time1=0,           // first point time 
                      double                price1=0,          // first point price 
                      datetime              time2=0,           // second point time 
                      double                price2=0,          // second point price 
                      const color           clr=clrRed,        // object color 
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // object line style 
                      const int             width=1,           // object line width 
                      const bool            back=false,        // in the background 
                      const bool            selection=true,    // highlight to move 
                      const bool            ray_right=false,   // object's continuation to the right 
                      const bool            hidden=true,       // hidden in the object list 
                      const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor points' coordinates if they are not set 
   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- Create Fibonacci Retracement by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create \"Fibonacci Retracement\"! Error code = ",GetLastError());
      return(false);
     }
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the object's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiboLevelsSet(int             levels,            // number of level lines 
                   double          &values[],         // values of level lines 
                   color           &colors[],         // color of level lines 
                   ENUM_LINE_STYLE &styles[],         // style of level lines 
                   int             &widths[],         // width of level lines 
                   const long      chart_ID=0,        // chart's ID 
                   const string    name="FiboLevels") // object name 
  {
//--- check array sizes 
   if(levels!=ArraySize(colors) || levels!=ArraySize(styles) ||
      levels!=ArraySize(widths) || levels!=ArraySize(widths))
     {
      Print(__FUNCTION__,": array length does not correspond to the number of levels, error!");
      return(false);
     }
//--- set the number of levels 
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,levels);
//--- set the properties of levels in the loop 
   for(int i=0;i<levels;i++)
     {
      //--- level value 
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,i,values[i]);
      //--- level color 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,i,colors[i]);
      //--- level style 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,i,styles[i]);
      //--- level width 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,i,widths[i]);
      //--- level description 
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*values[i],1));
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiboLevelsPointChange(const long   chart_ID=0,        // chart's ID 
                           const string name="FiboLevels", // object name 
                           const int    point_index=0,     // anchor point index 
                           datetime     time=0,            // anchor point time coordinate 
                           double       price=0)           // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move the anchor point 
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
bool FiboLevelsDelete(const long   chart_ID=0,        // chart's ID 
                      const string name="FiboLevels") // object name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the object 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete \"Fibonacci Retracement\"! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ WaitOrganize    
//--- input parameters of the script 

string          InpName="HLine";     // Line name 
int             InpPrice=25;         // Line price, % 
color           InpColor=C'40,40,40';     // Line color 
ENUM_LINE_STYLE InpStyle=STYLE_DASH; // Line style 
int             InpWidth=1;          // Line width 
bool            InpBack=false;       // Background line 
bool            InpSelection=true;   // Highlight to move 
bool            InpHidden=true;      // Hidden in the object list 
long            InpZOrder=0;         // Priority for mouse click 
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
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
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,": failed to delete a horizontal line! Error code = ",GetLastError());
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
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
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
//| Move the vertical line                                           | 
//+------------------------------------------------------------------+ 
bool VLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="VLine", // line name 
               datetime     time=0)       // line time 
  {
//--- if line time is not set, move the line to the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the vertical line                                         | 
//+------------------------------------------------------------------+ 
bool VLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="VLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the vertical line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Handle;
//+------------------------------------------------------------------+
void _LogfileHandle(string v,string s)
  {
   if((v=="") && (s==""))
     {
      string _FileName=(string)MqlDate_Start.year+"/"+
                       _FillZero(MqlDate_Start.mon) +"/"+
                       _FillZero(MqlDate_Start.day)+"/"+
                       StringSubstr(_NameEaLabel,0,5)+"-["+Symbol()+"]["+
                       _FillZero(MqlDate_Start.hour)+" "+
                       _FillZero(MqlDate_Start.min)+"]";
      //--
      Handle=FileOpen(_FileName+".txt",FILE_WRITE|FILE_CSV,"\t");
     }
   else
     {
      string _xTime=TimeToStr(TimeLocal(),TIME_DATE)+"\t"+TimeToStr(TimeLocal(),TIME_SECONDS);
      FileWrite(Handle,_xTime+"\t\t"+v+"\t"+s);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _LogfileHandle_HeadEnd(int v)
  {
   if(v==0)
     {
      _LogfileHandle("--------------","--------------");
      _LogfileHandle("Start",_tbENUM_TIMEFRAMES(Period())+"      \t"+Symbol());
      _LogfileHandle("Start","BALANCE\t"+(string)NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2));
      _LogfileHandle("Start","Fund         \t"+(string)Fund);
      _LogfileHandle("Start","Lots           \t"+(string)Lots);
      _LogfileHandle("Start","Rate          \t"+(string)LotsRate);
      _LogfileHandle("Start","Pip             \t"+(string)Pip);
      _LogfileHandle("Start","PipSteps   \t"+(string)PipSteps);
      _LogfileHandle("Start","MaxTrad   \t"+(string)MaxTrad);
      _LogfileHandle("--------------","--------------");

        }else{
      double _xProfit=ProfitPerDay;

      _LogfileHandle("--------------","--------------");
      _LogfileMAX("END          ");
      _LogfileStat();
      _LogfileHandle("END",_eaText12);
      _LogfileHandle("END","BALANCE\t"+(string)NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2));
      _LogfileHandle("END","Profit          \t"+_Comma(myProfitTotal,2," ")+"\t"+_Comma(perProfit,2," "));
      _LogfileHandle("END","Profit / Day["+(string)_Day_Of_RunEA+"]\t"+_Comma(_xProfit,2," ")+"\t"+_Comma(_xProfit*35,2," ")+"\t"+_Comma(_xProfit*700,2," "));
      FileClose(Handle);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _LogfileMAX(string v)
  {

//string DDTIME = _MonthDMax+"\t"+_DayDMax+"\t"+_HHDMax+":"+_MMDMax+":"+_SSDMax;

//int _xcMax = cMax,_xsTPmax = sTPmax;
//double _xDDMax2 =  NormalizeDouble(DDMax2,2),_xDDMax_All =  NormalizeDouble(DDMax_All,2),_xDDMax =  NormalizeDouble(DDMax,2);

//if(_xDDMax < 0){_xDDMax = 0;}
//if(_xDDMax2 < 0){_xDDMax2 = 0;}
//if(_xDDMax_All < 0){_xDDMax_All = 0;}
//if(_xcMax < 0){_xcMax = 0;}
//if(_xsTPmax < 0){_xsTPmax = 0;}

//_LogfileHandle("isMax",v+"\t"+_xcMax+"\t"+CNT_Round+"\t"+DDTIME+"\t"+NormalizeDouble(_xDDMax,2)+"\t"+NormalizeDouble(_xDDMax2,2)+"\t"+NormalizeDouble(_xDDMax_All,2)+"\t"+NormalizeDouble(_xsTPmax,0));

//_Stat_cMax += _xcMax;_cStat_cMax++;
//_Stat_CNT_Round += CNT_Round;_cStat_CNT_Round++;
//_Stat_DDMax += _xDDMax;_cStat_DDMax++;
//_Stat_DDMax2 += _xDDMax2;_cStat_DDMax2++;
//_Stat_DDMax_All += _xDDMax_All;_cStat_DDMax_All++;
//_Stat_MonthDMax += _MonthDMax;_cStat_MonthDMax++;
//_Stat_DayDMax += _DayDMax;_cStat_DayDMax++;
//_Stat_HHDMax += _HHDMax;_cStat_HHDMax++;
//_Stat_MMDMax += _MMDMax;_cStat_MMDMax++;
//_Stat_SSDMax += _SSDMax;_cStat_SSDMax++;
//_Stat_TPPoint += _xsTPmax;_cStat_TPPoint++;

//Print("_LogfileMAX#"+v+"  ERR["+GetLastError()+"]");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void _LogfileStat()
  {

//   _Stat_cMax=_Stat_cMax/_cStat_cMax;
//   _Stat_CNT_Round=_Stat_CNT_Round/_cStat_CNT_Round;
//
//   _Stat_DDMax=_Stat_DDMax/_cStat_DDMax;
//   _Stat_DDMax2=_Stat_DDMax2/_cStat_DDMax2;
//   _Stat_DDMax_All=_Stat_DDMax_All/_cStat_DDMax_All;
//
//   _Stat_TPPoint=_Stat_TPPoint/_cStat_TPPoint;
//
//   _Stat_MonthDMax=_Stat_MonthDMax/_cStat_MonthDMax;
//   _Stat_DayDMax= _Stat_DayDMax/_cStat_DayDMax;
//   _Stat_HHDMax = _Stat_HHDMax/_cStat_HHDMax;
//   _Stat_MMDMax = _Stat_MMDMax/_cStat_MMDMax;
//   _Stat_SSDMax = _Stat_SSDMax/_cStat_SSDMax;
//
//   if(_cStat_PriceActive_N==0){_cStat_PriceActive_N=1;}
//   _Stat_PriceActive=_Stat_PriceActive/_cStat_PriceActive_N;
//
//   string DDTIME=NormalizeDouble(_Stat_MonthDMax,2)+"\t"+NormalizeDouble(_Stat_DayDMax,2)+"\t"+NormalizeDouble(_Stat_HHDMax,2)+":"+NormalizeDouble(_Stat_MMDMax,2)+":"+NormalizeDouble(_Stat_SSDMax,2);
//   _LogfileHandle("--------------","--------------");
//   _LogfileHandle("END","Stat            \t"+NormalizeDouble(_Stat_cMax,2)+"\t"+NormalizeDouble(_Stat_CNT_Round,2)+"\t"+DDTIME+"\t"+NormalizeDouble(_Stat_DDMax,2)+"\t"+NormalizeDouble(_Stat_DDMax2,2)+"\t"+NormalizeDouble(_Stat_DDMax_All,2)+"\t"+NormalizeDouble(_Stat_TPPoint,0));
//   _LogfileHandle("END","Stat_PriceAct\t"+_Stat_PriceActive);
//   _LogfileHandle("--------------","--------------");
  }
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

   ObjectSetInteger(0,name,OBJPROP_CORNER,0);
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
//|                                                                  |
//+------------------------------------------------------------------+
void _setBUTTON_State()
  {
   _setBUTTON_State("BTN_BUY",clrLime);
   _setBUTTON_State("BTN_SELL",clrRed);

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
