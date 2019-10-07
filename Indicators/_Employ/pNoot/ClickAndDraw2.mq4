//+------------------------------------------------------------------+
//|                                              mn ClickAndDraw.mq4 |
//+------------------------------------------------------------------+
#property copyright "mn"
#property strict
#property indicator_chart_window
#property strict

string eaName="mn";

extern int   exWIDTH = 1;
extern color   exColor_1 = clrRed;
extern color   exColor_2 = clrWhite;

extern bool  exRay = false,
             mDeleteOnExit = false;

int mCnt = 0;
datetime mTime[3];
double mPrice[3];
string ObjTag_Head=eaName+"X_Head";

//+------------------------------------------------------------------+
int init()
  {
   setHeadText("-",clrMagenta);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setHeadText(string text,color clr)
  {
   ObjectCreate(0,ObjTag_Head,OBJ_LABEL,0,5,5);
//
   ObjectSetString(0,ObjTag_Head,OBJPROP_TEXT,text);
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_COLOR,clr);
//
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_XDISTANCE,25);
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_YDISTANCE,25);
   ObjectSetString(0,ObjTag_Head,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_BACK,false);
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,ObjTag_Head,OBJPROP_SELECTED,false);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   if(mDeleteOnExit)
     {
      ObjectsDeleteAll(0,eaName,0,-1);
     }
   return(0);
  }

//+------------------------------------------------------------------+
int start()
  {

   return(0);
  }


int State_Obj=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam)  // Parameter of type string events
  {
   if(id==CHARTEVENT_KEYDOWN)
     {
      printf("CHARTEVENT_KEYDOWN: "+string(lparam));

      if(lparam==9)//Tab
        {
         ObjectsDeleteAll(0,0,-1);
         State_Obj=-1;
         mCnt=0;
        }

      if(lparam==81)//Q
        {
         State_Obj=OBJ_TREND;
         mCnt=0;
        }

      if(lparam==87)//W
        {
         State_Obj=OBJ_RECTANGLE;
         mCnt=0;
        }
      if(lparam==69)//E
        {
         State_Obj=OBJ_FIBOCHANNEL;
         mCnt=0;
        }
      //---
      setHeadText(objToStr(State_Obj),exColor_1);
      //Comment(State_Obj);
     }
//---
   if(State_Obj>-1)
     {
      if(id == CHARTEVENT_CLICK)
        {
         int   mX = int(lparam);
         int   mP = int(dparam);
         //
         int win = 0;
         //---
         bool r=ChartXYToTimePrice(win, mX, mP, win, mTime[mCnt], mPrice[mCnt]);
         if(r)
           {
            //---
            string ObjTag=eaName+"_Draft_"+string(mCnt);
            ObjectCreate(win,ObjTag,OBJ_ARROW,0,mTime[mCnt],mPrice[mCnt]);
            ObjectSetInteger(win,ObjTag,OBJPROP_ARROWCODE,159);
            ObjectSet(ObjTag, OBJPROP_COLOR, exColor_1);
            //---
            mCnt++;
            if(mCnt==3)
              {
               mCnt = 0;
              }
           }
         //---

         //if(mPrice[0] > 0 && mPrice[1] > 0&& mPrice[2] > 0)
           {
            bool cre=false;
            //
            string ObjTag=eaName+"_"+string(State_Obj)+"_"+IntegerToString(TimeLocal());
            //---

            if(State_Obj==OBJ_TREND && chkData_Price(2))
              {
               cre=ObjectCreate(ObjTag, OBJ_TREND,       win, mTime[0], mPrice[0], mTime[1], mPrice[1]);
               ObjectSet(ObjTag, OBJPROP_COLOR, exColor_1);
               ObjectSet(ObjTag, OBJPROP_WIDTH, exWIDTH);
               ObjectSet(ObjTag, OBJPROP_RAY,   exRay);
              }
            if(State_Obj==OBJ_RECTANGLE && chkData_Price(2))
              {
               cre=ObjectCreate(ObjTag, OBJ_RECTANGLE,   win, mTime[0], mPrice[0], mTime[1], mPrice[1]);
               ObjectSet(ObjTag, OBJPROP_COLOR, exColor_1);
               ObjectSet(ObjTag, OBJPROP_BACK, true);
              }
            if(State_Obj==OBJ_FIBOCHANNEL && chkData_Price(3))
              {
               cre=ObjectCreate(ObjTag, OBJ_FIBOCHANNEL, win, mTime[0], mPrice[0], mTime[1], mPrice[1],mTime[2],mPrice[2]);
               ObjectSet(ObjTag, OBJPROP_COLOR, exColor_1);
               ObjectSet(ObjTag, OBJPROP_BACK, true);
               ObjectSet(ObjTag,OBJPROP_RAY_RIGHT,exRay);

               //double            values[]= {-0.5};
               //color             colors[]= {clrWhite};
               //ENUM_LINE_STYLE   styles[]= {STYLE_DOT};
               //int               widths[]= {1};

               double            values=-0.5;
               color             colors=exColor_2;
               ENUM_LINE_STYLE   styles=STYLE_DOT;
               int               widths=exWIDTH;

               FiboChannelLevelsSet(1,values,colors,styles,widths,0,ObjTag);
              }

            //---
            if(cre)
              {
               State_Obj   =-1;
               setHeadText(objToStr(State_Obj),exColor_1);
               mPrice[0]   = 0;
               mPrice[1]   = 0;
               mPrice[2]   = 0;

               ObjectsDeleteAll(0,eaName+"_Draft",0,OBJ_ARROW);
              }

           }

        }
     }
//---

//return;
  }
bool chkData_Price(int v)
  {
   bool r=false;
   for(int i=0; i<v; i++)
     {
      if(mPrice[i]>0)
         r=true;
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
   if(obj==-1)
      return "";
   if(obj==-2)
      return "Delete All";
//
   if(obj==OBJ_TREND)
      return "OBJ_TREND";
   if(obj==OBJ_RECTANGLE)
      return "OBJ_RECTANGLE";
   if(obj==OBJ_FIBOCHANNEL)
      return "OBJ_FIBOCHANNEL";
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
                                const long      chart_ID=0,         // chart's ID
                                const string    name="FiboChannel") // object name
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
   for(int i=0; i<levels; i++)
     {
      //--- level value
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,1,values[i]);
      //--- level color
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,1,colors[i]);
      //--- level style
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,1,styles[i]);
      //--- level width
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,1,widths[i]);
      //--- level description
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
                          const long      chart_ID=0,         // chart's ID
                          const string    name="FiboChannel") // object name
  {
//--- check array sizes
//if(levels!=ArraySize(colors) || levels!=ArraySize(styles) ||
//   levels!=ArraySize(widths) || levels!=ArraySize(widths))
     {
      //Print(__FUNCTION__,": array length does not correspond to the number of levels, error!");
      //return(false);
     }
//--- set the number of levels
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,levels);
//--- set the properties of levels in the loop
//for(int i=0; i<levels; i++)
     {
      //--- level value
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,0,values);
      //--- level color
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,0,colors);
      //--- level style
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,0,styles);
      //--- level width
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,0,widths);
      //--- level description
      //ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*values[i],1));
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
