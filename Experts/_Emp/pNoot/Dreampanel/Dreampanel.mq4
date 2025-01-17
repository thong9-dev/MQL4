//+------------------------------------------------------------------+
//|                                                   Dreampanel.mq4 |
//|                                        Copyright 2019, ThongEak. |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict

#include "KeyAndDraw_Key.mqh"
string eaName  = "DM";

extern ENUM_FIX_RANG    exFibo_FixRang = ENUM_FIX_RANG_200;       //FOBO | Fix rang Point
extern string  exLine1 = "-"; //-
extern ENUM_FIX_RANG    exTang_FixRang = ENUM_FIX_RANG_200;       //Rectangle | Fix rang Point
extern bool             exTang_FillColor = false;                 //Rectangle | Fill Color
string  exLine2 = "-"; //-
bool             exVline_ShowDate = true;                 //V Line | Show label Datetime
extern string  exLine3 = "-"; //-
bool             exHline_ShowDate = true;                 //H Line | Show label Price
string  exLine4 = "-"; //-
extern int              exWIDTH        = 1;                  //Width line item
extern string  exLine5 = "-"; //-
extern bool             exRay          = false;                //use Ray line (Trend,Fobo)
extern bool             exDeleteOnExit = false;       //Delete all item where exit program



//---

int      State_Cmd = -1;
int      State_Obj = -1;
int      mCnt = 0;
datetime mTime[3];
double   mPrice[3];
color clrStack[] = {clrRed, clrOrange, clrYellow, clrLime, clrAqua, clrBlue, clrMagenta};
int clrStack_index = 0;
//---
color clrChart_FG = color(ChartGetInteger(0, CHART_COLOR_FOREGROUND, 0));
//---
datetime Icon_Time[3];
double   Icon_Price[3];
//
bool Dev_Test = false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Comment("");
//--- indicator buffers mapping

   arrayPush(clrStack, clrChart_FG);
   ArraySort(clrStack, WHOLE_ARRAY, 0, MODE_ASCEND);
//---

//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  ChartXY_To_TimePrice(int Post_W, int Post_H,
                           int Size_W, int Size_H,
                           datetime &mTime_[], double &mPrice_[])
  {
   int win_ = -1;

   int H = int(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0));
//
   ChartXYToTimePrice(0, Post_W, H - Post_H, win_, mTime_[0], mPrice_[0]);
   ChartXYToTimePrice(0, Size_W, H - Size_H, win_, mTime_[1], mPrice_[1]);

   mTime_[2] = mTime_[0];
   mPrice_[2] = mPrice_[1] + MathAbs(mPrice_[0] - mPrice_[1]);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(exDeleteOnExit)
     {
      ObjectsDeleteAll(0, eaName, 0, -1);
     }
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
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
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      //printf("CHARTEVENT_CHART_CHANGE: " + string(lparam));
      //---

      //ObjectsDeleteAll(0,0,-1);
      State_Cmd = -1;
      State_Obj = -1;
      //printf("#" + string(__LINE__));

      mCnt = 0;
      ObjectsDeleteAll(0, eaName + "_Draft", 0, OBJ_ARROW);
      ObjectsDeleteAll(0, eaName + "X", 0, -1);
     }
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
         ObjectsDeleteAll(0, eaName + "X", 0, -1);
        }
      //---

      if(lparam == KEY_END)   //End
        {
         State_Cmd = KEY_END;
         State_Obj = -1;
         //printf("#" + string(__LINE__));

         mCnt = 0;
         ObjectsDeleteAll(0, eaName + "_Draft", 0, OBJ_ARROW);
         ObjectsDeleteAll(0, eaName + "X", 0, -1);
         strCMD = "Key ' Y ' to ObjectsDelete All";
         setHeadText(objToStr(State_Obj) + strCMD, clrChart_FG);
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
            if(true)
              {
               clrStack_index++;
               clrStack_index = int(MathMod(clrStack_index, ArraySize(clrStack)));
              }
            else
              {
               clrStack_index = 0;
               clrStack[clrStack_index] = clrNext(clrStack[clrStack_index]);
              }
           }
        }
      //---
      //Update Chart
      //---
      color clrHead = (strCMD != "") ? clrChart_FG : clrStack[clrStack_index];
      if(Dev_Test)
         setHeadText(objToStr(State_Obj) + strCMD, clrHead);
      setHeadIcon(State_Obj, clrHead);
      if(State_Obj == -1)
         ObjectDelete(ObjTag_Head);
      //ObjectsDeleteAll(0, eaName + "X", 0, -1);
      //---
     }
//------------------------------------------------
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
               int F_pNoot = 1;
               //
               if(F_pNoot == 1 && chkData_Price(2))
                 {

                  double d = exFibo_FixRang / MathPow(10, Digits);

                  double _Price_1 = mPrice[0];
                  double _Price_2 = (mPrice[0] < mPrice[1]) ? mPrice[0] + d : mPrice[0] - d;

                  cre = ObjectCreate(ObjTag, OBJ_RECTANGLE,   win, mTime[0], mPrice[0], mTime[1], _Price_2);


                 }

               if(F_pNoot == 2 && chkData_Price(2))
                 {
                  cre = ObjectCreate(ObjTag, OBJ_RECTANGLE,   win, mTime[0], mPrice[0], mTime[1], mPrice[1]);
                 }
               if(cre)
                 {
                  ObjectSetInteger(0, ObjTag, OBJPROP_FILL, exTang_FillColor);
                  ObjectSet(ObjTag, OBJPROP_BACK, exTang_FillColor);
                 }
              }
            if(State_Obj == OBJ_FIBOCHANNEL)
              {
               int F_pNoot = 1;
               //
               if(F_pNoot == 1 && chkData_Price(2))
                 {
                  double d = exFibo_FixRang / MathPow(10, Digits);

                  double _Price_1 = mPrice[0];
                  double _Price_2 = mPrice[1];
                  double _Price_3 = (_Price_1 < _Price_2) ? _Price_1 + d : _Price_1 - d;
                  _Price_3 = NormalizeDouble(_Price_3, Digits);

                  cre = ObjectCreate(ObjTag, OBJ_FIBOCHANNEL, win, mTime[0], mPrice[0], mTime[1], mPrice[1], mTime[0], _Price_3);

                 }
               if(F_pNoot == 2 &&  chkData_Price(3))
                 {
                  cre = ObjectCreate(ObjTag, OBJ_FIBOCHANNEL, win, mTime[0], mPrice[0], mTime[1], mPrice[1], mTime[2], mPrice[2]);

                 }
               //
               if(cre)
                 {

                  ObjectSet(ObjTag, OBJPROP_WIDTH, exWIDTH);

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
               //
              }
            if(State_Obj == OBJ_VLINE && chkData_Price(1))
              {
               cre = ObjectCreate(ObjTag, OBJ_VLINE, win, mTime[0], mPrice[0], mTime[1], mPrice[1]);
               ObjectSet(ObjTag, OBJPROP_BACK, !exVline_ShowDate);
              }
            if(State_Obj == OBJ_HLINE && chkData_Price(1))
              {
               cre = ObjectCreate(ObjTag, OBJ_HLINE, win, mTime[0], mPrice[0], mTime[1], mPrice[1]);
               ObjectSet(ObjTag, OBJPROP_BACK, !exHline_ShowDate);
              }
            //---
            if(cre)
              {
               //Clear Chart
               //---

               ObjectSet(ObjTag, OBJPROP_COLOR, clrStack[clrStack_index]);
               //
               State_Obj   = -1;
               setHeadText(objToStr(State_Obj), clrNONE);
               ArrayFill(mPrice, 0, ArraySize(mPrice), 0);
               ObjectsDeleteAll(0, eaName + "_Draft", 0, OBJ_ARROW);
               ObjectsDeleteAll(0, eaName + "X", 0, -1);
              }
           }
        }
     }
   string cmm = "";
   cmm += "\n State_Cmd :: " + string(State_Cmd);
   cmm += "\n State_Obj :: " + string(State_Obj);
   cmm += "\n clrStack_index :: " + string(clrStack_index);
   cmm += "\n clrStack :: " + ColorToString(clrStack[clrStack_index]);

//Comment(cmm);
//---

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Rout_KeyObj(long lparam)
  {
   switch(int(lparam))
     {
      case  KEY_1:
         return OBJ_FIBOCHANNEL;
      case  KEY_2:
         return OBJ_RECTANGLE;
         /*
         case  KEY_3:
         return OBJ_TREND;
         case  KEY_4:
         return OBJ_VLINE;
         case  KEY_5:
         return OBJ_HLINE;
         */
     }
   return -1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ObjTag_Head = eaName + "X_Head";
string ObjTag_ICON = eaName + "X_Icon";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setHeadText(string text, color clr)
  {
   ObjectDelete(ObjTag_Head);

   ObjectCreate(0, ObjTag_Head, OBJ_LABEL, 0, 5, 5);
//
   ObjectSetString(0, ObjTag_Head, OBJPROP_TEXT, text);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_COLOR, clr);
//
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_XDISTANCE, 80);
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
void setHeadText_2(string text, color clr)
  {
   ObjectDelete(ObjTag_Head);
   if(text != "")
     {
      ObjectCreate(0, ObjTag_Head, OBJ_LABEL, 0, 5, 5);
     }
//
   ObjectSetString(0, ObjTag_Head, OBJPROP_TEXT, text);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_COLOR, clr);
//
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, ObjTag_Head, OBJPROP_XDISTANCE, 80);
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
void setHeadIcon(int _State_Obj, color _clrHead)
  {
   int Post_W = 15,  Post_H = 10;
   int Size_W = 50,  Size_H = 50;
//
   ChartXY_To_TimePrice(Post_W, Post_H, Size_W, Size_H, Icon_Time, Icon_Price);
//
   string ObjTag_Icon = eaName + "Test_Icon";
   ObjectDelete(0, ObjTag_Icon);
   if(Dev_Test)
     {
      ObjectCreate(ObjTag_Icon, OBJ_RECTANGLE,   0, Icon_Time[0], Icon_Price[0], Icon_Time[1], Icon_Price[1]);
      ObjectSetInteger(0, ObjTag_Icon, OBJPROP_COLOR, clrMidnightBlue);
     }
//+--------------------------------------------+
   string ICON = ObjTag_ICON;
   ObjectDelete(0, ICON);
   bool cre = false;
   string strDescript = "";
//---

   if(_State_Obj == OBJ_TREND)
     {
      cre = ObjectCreate(ICON, _State_Obj, 0, Icon_Time[0], Icon_Price[0], Icon_Time[1], Icon_Price[1], Icon_Time[2], Icon_Price[2]);

     }
   if(_State_Obj == OBJ_RECTANGLE)
     {
      cre = ObjectCreate(ICON, _State_Obj, 0, Icon_Time[0], Icon_Price[0], Icon_Time[1], Icon_Price[1], Icon_Time[2], Icon_Price[2]);

      ObjectSetInteger(0, ICON, OBJPROP_FILL, exTang_FillColor);
      ObjectSet(ICON, OBJPROP_BACK, exTang_FillColor);
      //
      strDescript = "Rectangle :: " + string(exTang_FixRang) + "point";
     }
   if(_State_Obj == OBJ_FIBOCHANNEL)
     {
      cre = ObjectCreate(ICON, _State_Obj, 0, Icon_Time[0], Icon_Price[0], Icon_Time[1], Icon_Price[1], Icon_Time[2], Icon_Price[1]);

      ObjectSet(ICON, OBJPROP_WIDTH, exWIDTH);
      ObjectSet(ICON, OBJPROP_BACK, true);


      //double            values[]= {-0.5};
      //color             colors[]= {clrWhite};
      //ENUM_LINE_STYLE   styles[]= {STYLE_DOT};
      //int               widths[]= {1};

      double            values = -0.5;
      color             colors = color(clrChart_FG);
      ENUM_LINE_STYLE   styles = STYLE_DOT;
      int               widths = exWIDTH;

      FiboChannelLevelsSet(1, values, colors, styles, widths, 0, ICON);
      //
      strDescript = "Fibo Chanel :: " + string(exFibo_FixRang) + "point";
     }
   if(_State_Obj == OBJ_VLINE)
     {
      double p = MathAbs(Icon_Price[1] - Icon_Price[0]) / 2;
      datetime d = MathAbs(Icon_Time[1] - Icon_Time[0]) / 2;

      cre = ObjectCreate(ICON, OBJ_TREND, 0, Icon_Time[0] + d, Icon_Price[0], Icon_Time[0] + d, Icon_Price[1], Icon_Time[2], Icon_Price[2]);
     }
   if(_State_Obj == OBJ_HLINE)
     {
      double d = MathAbs(Icon_Price[1] - Icon_Price[0]) / 2;
      cre = ObjectCreate(ICON, OBJ_TREND, 0, Icon_Time[0], Icon_Price[0] + d, Icon_Time[1], Icon_Price[0] + d, Icon_Time[2], Icon_Price[2]);
     }

//---

   if(cre)
     {

      setHeadText_2(strDescript, _clrHead);

      ObjectSet(ICON, OBJPROP_COLOR, _clrHead);
      ObjectSet(ICON, OBJPROP_WIDTH, exWIDTH + 1);
      ObjectSet(ICON, OBJPROP_RAY_RIGHT, false);

      ObjectSetInteger(0, ICON, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, ICON, OBJPROP_SELECTED, false);

     }
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
//|                                                                  |
//+------------------------------------------------------------------+
color  clrNext(color v)
  {
   int Step = 85;

   string clr = ColorToString(v);
//StringReplace(clr, "0", "0");
   Print("0 :: " + clr);

   string result[];
   int k = StringSplit(clr, StringGetCharacter(",", 0), result);
//Print(k);
//---

   int R = 0, G = 1, B = 2;
//
   if(int(result[R]) == 255 && int(result[G]) >= 0)
     {
      result[G] = int(result[G]) + Step;
     }
   if(int(result[R]) < 255 && int(result[G]) == 255 && int(result[B]) == 0)
     {
      result[R] = int(result[R]) - Step;
     }
   if(int(result[R]) == 0 && int(result[G]) == 255 && int(result[B]) >= 0)
     {
      result[B] = int(result[B]) + Step;
     }
//---

   string r =  clrNext_limit(result[R]) + "," +  clrNext_limit(result[G]) + "," +  clrNext_limit(result[B]);
   printf("1 :: " + r);
   return StringToColor(r);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string clrNext_limit(string v)
  {
   int c = int(v);
   return (c > 255) ? "255" : string(c);
  }
//+------------------------------------------------------------------+
