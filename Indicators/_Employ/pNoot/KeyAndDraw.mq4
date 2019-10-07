//+------------------------------------------------------------------+
//|                                                   KeyAndDraw.mq4 |
//|                                        Copyright 2019, ThongEak. |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, ThongEak."
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.21"
#property strict
#property indicator_chart_window

#include "KeyAndDraw_Key.mqh"

string eaName  = "KD";

extern int     exWIDTH = 1;
extern bool  exRay = false,
             exDeleteOnExit = false;

int      State_Cmd = -1;
int      State_Obj = -1;
int      mCnt = 0;
datetime mTime[3];
double   mPrice[3];
color clrStack[] = {Red, Orange, Yellow, Lime, Aqua, Blue, Magenta};
int clrStack_index = 0;

//---
color clrChart_FG = color(ChartGetInteger(0, CHART_COLOR_FOREGROUND, 0));
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   setHeadText("-", clrMagenta);
   arrayPush(clrStack, clrChart_FG);
   ArraySort(clrStack, WHOLE_ARRAY, 0, MODE_ASCEND);
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   if(exDeleteOnExit)
     {
      ObjectsDeleteAll(0, eaName, 0, -1);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
//--- return value of prev_calculated for next call
   return(rates_total);
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
   if(id == CHARTEVENT_KEYDOWN)
     {

      printf("CHARTEVENT_KEYDOWN: " + string(lparam));
      string strCMD = "";

      if(lparam == KEY_ESC)   //Esc
        {
         //ObjectsDeleteAll(0,0,-1);
         State_Cmd = -1;
         State_Obj = -1;
         //printf("#" + string(__LINE__));

         mCnt = 0;
         ObjectsDeleteAll(0, eaName + "_Draft", 0, OBJ_ARROW);
        }
      //---

      if(lparam == KEY_END)   //End
        {
         State_Cmd = KEY_END;
         State_Obj = -1;
         //printf("#" + string(__LINE__));

         mCnt = 0;
         ObjectsDeleteAll(0, eaName + "_Draft", 0, OBJ_ARROW);
         strCMD = "Key ' Y ' to ObjectsDelete All";
        }
      if(State_Cmd == KEY_END && lparam != KEY_END)   //End
        {
         if(lparam == KEY_Y)
            ObjectsDeleteAll_My();
         State_Cmd = -1;
        }
      //---

      if(State_Cmd == -1)
        {
         if(lparam != KEY_TAB)
            State_Obj = Rout_KeyObj(lparam);

         //printf("#" + string(__LINE__));
         //---
         if(State_Obj != -1)
           {
            mCnt = 0;
            ObjectsDeleteAll(0, eaName + "_Draft", 0, OBJ_ARROW);
           }
        }
      if(State_Obj != -1)
        {
         if(lparam == KEY_TAB)   //Tab
           {
            clrStack_index++;
            clrStack_index = int(MathMod(clrStack_index, ArraySize(clrStack)));
           }
        }
      //---

      color clrHead = (strCMD != "") ? clrChart_FG : clrStack[clrStack_index];
      setHeadText(objToStr(State_Obj) + strCMD, clrHead);
      //---
     }
//---
   if(State_Obj > -1)
     {
      if(id == CHARTEVENT_CLICK)
        {
         int   mX = int(lparam);
         int   mP = int(dparam);
         //
         int win = 0;
         //---
         bool r = ChartXYToTimePrice(win, mX, mP, win, mTime[mCnt], mPrice[mCnt]);
         if(r)
           {
            //---
            string ObjTag = eaName + "_Draft_" + string(mCnt);
            ObjectCreate(win, ObjTag, OBJ_ARROW, 0, mTime[mCnt], mPrice[mCnt]);
            ObjectSetInteger(win, ObjTag, OBJPROP_ARROWCODE, 159);
            ObjectSet(ObjTag, OBJPROP_COLOR, clrStack[clrStack_index]);
            //---
            mCnt++;
            mCnt = int(MathMod(mCnt, ArraySize(mPrice)));
           }
         //---
           {
            bool cre = false;
            //
            string ObjTag = eaName + "_" + string(State_Obj) + "_" + IntegerToString(TimeLocal());
            //---
            if(State_Obj == OBJ_TREND && chkData_Price(2))
              {
               cre = ObjectCreate(ObjTag, OBJ_TREND,       win, mTime[0], mPrice[0], mTime[1], mPrice[1]);

               ObjectSet(ObjTag, OBJPROP_WIDTH, exWIDTH);
               ObjectSet(ObjTag, OBJPROP_RAY,   exRay);
              }
            if(State_Obj == OBJ_RECTANGLE && chkData_Price(2))
              {
               cre = ObjectCreate(ObjTag, OBJ_RECTANGLE,   win, mTime[0], mPrice[0], mTime[1], mPrice[1]);

               ObjectSet(ObjTag, OBJPROP_BACK, true);
              }
            if(State_Obj == OBJ_FIBOCHANNEL && chkData_Price(3))
              {
               cre = ObjectCreate(ObjTag, OBJ_FIBOCHANNEL, win, mTime[0], mPrice[0], mTime[1], mPrice[1], mTime[2], mPrice[2]);

               ObjectSet(ObjTag, OBJPROP_BACK, true);
               ObjectSet(ObjTag, OBJPROP_RAY_RIGHT, exRay);

               //double            values[]= {-0.5};
               //color             colors[]= {clrWhite};
               //ENUM_LINE_STYLE   styles[]= {STYLE_DOT};
               //int               widths[]= {1};

               double            values = -0.5;
               color             colors = color(clrChart_FG);
               ENUM_LINE_STYLE   styles = STYLE_DOT;
               int               widths = exWIDTH;

               FiboChannelLevelsSet(1, values, colors, styles, widths, 0, ObjTag);

              }
            if(State_Obj == OBJ_VLINE && chkData_Price(1))
              {
               cre = ObjectCreate(ObjTag, OBJ_VLINE, win, mTime[0], mPrice[0], mTime[1], mPrice[1]);
              }
            if(State_Obj == OBJ_HLINE && chkData_Price(1))
              {
               cre = ObjectCreate(ObjTag, OBJ_HLINE, win, mTime[0], mPrice[0], mTime[1], mPrice[1]);
              }
            //---
            if(cre)
              {
               ObjectSet(ObjTag, OBJPROP_COLOR, clrStack[clrStack_index]);
               //
               State_Obj   = -1;
               setHeadText(objToStr(State_Obj), clrNONE);
               ArrayFill(mPrice, 0, ArraySize(mPrice), 0);
               ObjectsDeleteAll(0, eaName + "_Draft", 0, OBJ_ARROW);
              }
           }
        }
     }
   string cmm = "";
   cmm += "\n State_Cmd :: " + string(State_Cmd);
   cmm += "\n State_Obj :: " + string(State_Obj);
   cmm += "\n clrStack_index :: " + string(clrStack_index);
   Comment(cmm);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Rout_KeyObj(long lparam)
  {
   switch(int(lparam))
     {
      case  KEY_1:
         return OBJ_TREND;
      case  KEY_2:
         return OBJ_RECTANGLE;
      case  KEY_3:
         return OBJ_FIBOCHANNEL;
      case  KEY_4:
         return OBJ_VLINE;
      case  KEY_5:
         return OBJ_HLINE;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ObjTag_Head = eaName + "X_Head";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setHeadText(string text, color clr)
  {
   ObjectCreate(0, ObjTag_Head, OBJ_LABEL, 0, 5, 5);
//
   ObjectSetString(0, ObjTag_Head, OBJPROP_TEXT, text);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_COLOR, clr);
//
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_XDISTANCE, 25);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_YDISTANCE, 25);
   ObjectSetString(0, ObjTag_Head, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_BACK, false);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_SELECTED, false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool chkData_Price(int v)
  {
   bool r = false;
   for(int i = 0; i < v; i++)
     {
      if(mPrice[i] > 0)
         r = true;
      else
         return false;
     }
   return r;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string   objToStr(int obj)
  {
   if(obj == -1)
      return "";
//
   if(obj == OBJ_TREND)
      return "OBJ_TREND";
   if(obj == OBJ_RECTANGLE)
      return "OBJ_RECTANGLE";
   if(obj == OBJ_FIBOCHANNEL)
      return "OBJ_FIBOCHANNEL";
   if(obj == OBJ_VLINE)
      return "OBJ_VLINE";
   if(obj == OBJ_HLINE)
      return "OBJ_HLINE";
   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiboChannelLevelsSet_Array(int             levels,             // number of level lines
                                double          &values[],          // values of level lines
                                color           &colors[],          // color of level lines
                                ENUM_LINE_STYLE &styles[],          // style of level lines
                                int             &widths[],          // width of level lines
                                const long      chart_ID = 0,       // chart's ID
                                const string    name = "FiboChannel")   // object name
  {

   if(levels != ArraySize(colors) || levels != ArraySize(styles) ||
      levels != ArraySize(widths) || levels != ArraySize(widths))
     {

      //Print(__FUNCTION__,": array length does not correspond to the number of levels, error!");
      return(false);
     }
   ObjectSetInteger(chart_ID, name, OBJPROP_LEVELS, levels);
   for(int i = 0; i < levels; i++)
     {
      ObjectSetDouble(chart_ID, name, OBJPROP_LEVELVALUE, 1, values[i]);
      ObjectSetInteger(chart_ID, name, OBJPROP_LEVELCOLOR, 1, colors[i]);
      ObjectSetInteger(chart_ID, name, OBJPROP_LEVELSTYLE, 1, styles[i]);
      ObjectSetInteger(chart_ID, name, OBJPROP_LEVELWIDTH, 1, widths[i]);
      //ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*values[i],1));
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiboChannelLevelsSet(int             levels,             // number of level lines
                          double          &values,          // values of level lines
                          color           &colors,          // color of level lines
                          ENUM_LINE_STYLE &styles,          // style of level lines
                          int             &widths,          // width of level lines
                          const long      chart_ID = 0,       // chart's ID
                          const string    name = "FiboChannel")   // object name
  {
   ObjectSetInteger(chart_ID, name, OBJPROP_LEVELS, levels);
     {
      ObjectSetDouble(chart_ID, name, OBJPROP_LEVELVALUE, 0, values);
      ObjectSetInteger(chart_ID, name, OBJPROP_LEVELCOLOR, 0, colors);
      ObjectSetInteger(chart_ID, name, OBJPROP_LEVELSTYLE, 0, styles);
      ObjectSetInteger(chart_ID, name, OBJPROP_LEVELWIDTH, 0, widths);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectsDeleteAll_My()
  {
   ObjectsDeleteAll(0, eaName, 0, -1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void arrayPush(int & array[], long dataToPush)
  {
   int count = ArrayResize(array, ArraySize(array) + 1);
   array[ArraySize(array) - 1] = color(dataToPush);
  }
//+------------------------------------------------------------------+
