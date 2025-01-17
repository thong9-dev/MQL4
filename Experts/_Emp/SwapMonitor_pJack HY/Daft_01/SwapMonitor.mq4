//+------------------------------------------------------------------+
//|                                                  SwapMonitor.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sChart
  {
   //private:
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
extern bool Mode2=true;//Both values are positive.
extern string extoken="";
extern ENUM_TIMEFRAMES TF=PERIOD_M30;
//sWyKPFRBeHSky0dCucuHpPIjxd93gn10QTl4731UgD5   Daren
//P0EUrFcg21mlYTtZCKRzrxP1tc4fag66Os2qo5nZWin   gTest
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(1000);
   ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,false);
   ChartSetInteger(0,CHART_SHOW_DATE_SCALE,false);

   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,Chart_BG);

   OnTick();
   Main();
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
color Chart_BG=C'31,31,31';//Chart_BG=C'31,31,31';

string ExtName_OBJ="SwapMonitor";
bool ExtHide_OBJ=false;

int Size_Wide=70;
int Size_High=17;
int PostX_Default=10,XStep=Size_Wide+5;
int PostY_Default=20,YStep=Size_High+5;

int PostX_DefaultTBL=0;
int PostY_DefaultTBL=0;

int iSymbolsTotal_=-1;

sChart iChart;

extern bool DevMode=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   if(iChart.NewBars(TF))
     {
      Main();
     }
   int iSymbolsTotal=SymbolsTotal(true);
   if(iSymbolsTotal_!=iSymbolsTotal)
     {
      iSymbolsTotal_=iSymbolsTotal;
      ObjManager(iSymbolsTotal_);
      Draw(false,iSymbolsTotal_,PostX_DefaultTBL,PostY_DefaultTBL);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main()
  {
   int PostX=PostX_Default;
   int PostY=PostY_Default;
//+------------------------------------------------------------------+
   if(DevMode)
     {
      setBUTTON(ExtName_OBJ+"_Test_0_0",0,CORNER_LEFT_UPPER,
                Size_Wide,Size_High,PostX,PostY,true,9,clrRed,clrBlack,clrDimGray,"Test");

      PostX+=int(XStep*1.5);
      _EditCreate(ExtName_OBJ+"_Test_L_E",0,""
                  ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                  ,clrWhite,Chart_BG,clrDodgerBlue,false,false,false,0);PostX+=XStep;
      PostX+=int(XStep*2.25);
      _EditCreate(ExtName_OBJ+"_Test_S_E",0,""
                  ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                  ,clrWhite,Chart_BG,clrRed,false,false,false,0);PostX+=XStep;
      PostX=PostX_Default;
      PostY+=YStep;
     }
   else
     {
      ObjectsDeleteAll(0,ExtName_OBJ+"_Test");
     }
//+------------------------------------------------------------------+

   setLabel(ExtName_OBJ+"_Head_0","Symbol","",clrWhite,PostX,PostY);PostX+=int(XStep*1.5);
   setLabel(ExtName_OBJ+"_Head_2","SWAP LONG","",clrDodgerBlue,PostX,PostY);PostX+=int(XStep*3.25);
   setLabel(ExtName_OBJ+"_Head_3","SWAP SHORT","",clrRed,PostX,PostY);PostX+=XStep;

   PostX=PostX_Default;
   PostY+=YStep;

   PostX_DefaultTBL=PostX;
   PostY_DefaultTBL=PostY;

//---
   ObjManager(iSymbolsTotal_);

//---
   Draw(true,iSymbolsTotal_,PostX,PostY);

//---
   Compare();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw(bool Mode,int iSymbolsTotal,int PostX,int PostY)
  {
   for(int i=0;i<iSymbolsTotal;i++)
     {
      string iSymbolName=SymbolName(i,true);
      //if(MarketInfo(iSymbolName,MODE_TRADEALLOWED)==1)
        {
         //double iSYMBOL_BID=SymbolInfoDouble(iSymbolName,SYMBOL_BID);

         double iSYMBOL_SWAP_LONG=(!DevMode)?SymbolInfoDouble(iSymbolName,SYMBOL_SWAP_LONG):0;
         double iSYMBOL_SWAP_SHORT=(!DevMode)?SymbolInfoDouble(iSymbolName,SYMBOL_SWAP_SHORT):0;

         if(Mode && Mode2 && iSYMBOL_SWAP_LONG>=0 && iSYMBOL_SWAP_SHORT>=0)
           {
            string strLine="\n";
            strLine+="#"+iSymbolName+" : Both Swap are positive.\n";
            strLine+="Long : "+iSYMBOL_SWAP_LONG+"\n";
            strLine+="Short : "+iSYMBOL_SWAP_SHORT;

            LineNotify(strLine);
           }

         //CMM+=iSymbolName+" : "+DoubleToStr(iSYMBOL_SWAP_LONG,2)+" | "+DoubleToStr(iSYMBOL_SWAP_SHORT,2)+"\n";
         //--------------------
         setLabel(ExtName_OBJ+"_"+iSymbolName+"_0",iSymbolName,"",clrWhite,PostX,PostY);PostX+=int(XStep*1.5);
         //--------------------

         if(!DevMode)
           {
            setLabel(ExtName_OBJ+"_"+iSymbolName+"_L_0",iSYMBOL_SWAP_LONG,"",clrNumber(iSYMBOL_SWAP_LONG),PostX,PostY);
           }
         else
           {
            ObjectDelete(0,ExtName_OBJ+"_"+iSymbolName+"_L_0");
           }
         PostX+=XStep;

         _EditCreate(ExtName_OBJ+"_"+iSymbolName+"_L_E",0,iSYMBOL_SWAP_LONG
                     ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                     ,clrWhite,Chart_BG,clrDodgerBlue,false,false,false,0);PostX+=XStep;

         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_L_<",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrRed,clrBlack,clrDimGray,"<");PostX+=int(Size_Wide*0.25);
         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_L_>",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrRed,clrBlack,clrDimGray,">");PostX+=XStep;
         //--------------------

         if(!DevMode)
           {
            setLabel(ExtName_OBJ+"_"+iSymbolName+"_S_0",iSYMBOL_SWAP_SHORT,"",clrNumber(iSYMBOL_SWAP_SHORT),PostX,PostY);
           }
         else
           {
            ObjectDelete(0,ExtName_OBJ+"_"+iSymbolName+"_S_0");
           }
         PostX+=XStep;

         _EditCreate(ExtName_OBJ+"_"+iSymbolName+"_S_E",0,iSYMBOL_SWAP_SHORT
                     ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                     ,clrWhite,Chart_BG,clrRed,false,false,false,0);PostX+=XStep;

         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_S_<",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrRed,clrBlack,clrDimGray,"<");PostX+=int(Size_Wide*0.25);
         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_S_>",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrRed,clrBlack,clrDimGray,">");PostX+=XStep;

        }
      PostX=PostX_Default;
      PostY+=YStep;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Compare()
  {
     {//Compare
      string name;
      string sep="_",result[];
      ushort  u_sep=StringGetCharacter(sep,0);

      int ObjTotal=ObjectsTotal();

      for(int i=0;i<ObjTotal;i++)
        {
         name=ObjectName(i);
         if(ObjectGetInteger(0,name,OBJPROP_TYPE,0)==OBJ_BUTTON)
           {
            //printf(name);
            int k=StringSplit(name,u_sep,result);
            if((result[3]==">" || result[3]=="<") && ObjectGetInteger(0,name,OBJPROP_STATE))
              {
               double SWAP=0;
               if(!DevMode)
                 {
                  SWAP=(result[2]=="L")?
                       SymbolInfoDouble(result[1],SYMBOL_BID):
                       SymbolInfoDouble(result[1],SYMBOL_ASK);
                 }
               else
                 {
                  SWAP=(result[2]=="L")?
                       double(ObjectGetString(0,result[0]+"_Test_"+result[2]+"_E",OBJPROP_TEXT,0)):
                       double(ObjectGetString(0,result[0]+"_Test_"+result[2]+"_E",OBJPROP_TEXT,0));
                 }

               double e=double(ObjectGetString(0,result[0]+"_"+result[1]+"_"+result[2]+"_E",OBJPROP_TEXT,0));

               if(result[3]==">" && SWAP>e)
                 {

                  //printf(result[1]+result[3]+" : "+e+" Over");

                  string strLine="\n";
                  strLine+="#"+result[1]+" : Swap Over.\n";
                  strLine+="Set : "+e+"\n";
                  strLine+="Now : "+SWAP;

                  LineNotify(strLine);
                 }
               if(result[3]=="<" && SWAP<e)
                 {
                  //printf(result[1]+result[3]+" : "+e+" Under");

                  string strLine="\n";
                  strLine+="#"+result[1]+" : Swap Under.\n";
                  strLine+="Set : "+e+"\n";
                  strLine+="Now : "+SWAP;

                  LineNotify(strLine);
                 }
              }
           }
        }
     }//#Compare
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   OnTick();
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
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      Print("CHARTEVENT_OBJECT_CLICK ["+sparam+"]");
      //---
      if(StringFind(sparam,ExtName_OBJ,0)>=0)
        {
         string sep="_",result[];
         ushort  u_sep=StringGetCharacter(sep,0);
         int k=StringSplit(sparam,u_sep,result);

         if(result[3]==">" || result[3]=="<")
           {
            string Sec=(result[3]==">")?"<":">";
            string NameBTNSec=result[0]+"_"+result[1]+"_"+result[2]+"_"+Sec;

            if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
              {
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);

               ObjectSetInteger(0,NameBTNSec,OBJPROP_BGCOLOR,clrBlack);
               ObjectSetInteger(0,NameBTNSec,OBJPROP_STATE,false);
              }
            else
              {
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrBlack);
              }
           }
         //---
         if(result[3]=="0")
           {
            double SWAP=(result[2]=="L")?
                        SymbolInfoDouble(result[1],SYMBOL_SWAP_LONG):
                        SymbolInfoDouble(result[1],SYMBOL_SWAP_SHORT);

            string NameBTNSec=result[0]+"_"+result[1]+"_"+result[2]+"_E";
            ObjectSetString(0,NameBTNSec,OBJPROP_TEXT,SWAP);
           }
         //---
         //---
         if(result[1]=="Test")
           {
            if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
              {
               Main();
               ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
              }
/* string strLine="\n";
            strLine+="#Test : Ping.\n";
            //strLine+="Long : "+iSYMBOL_SWAP_LONG+"\n";
            //strLine+="Short : "+iSYMBOL_SWAP_SHORT;

            LineNotify(strLine);*/
           }
        }
     }
  }
//+------------------------------------------------------------------+
void setLabel(string Name,string Text,string Tooltip,color clr,int PostX,int PostY)
  {
//ExtName_OBJ+"Head_1",
   ObjectCreate(Name,OBJ_LABEL,0,0,0);
   ObjectSetText(Name,Text,10,"Arial",clr);
   if(Tooltip!="")
     {
      ObjectSetString(0,Name,OBJPROP_TOOLTIP,Tooltip);
     }

   ObjectSet(Name,OBJPROP_XDISTANCE,PostX);
   ObjectSet(Name,OBJPROP_YDISTANCE,PostY);

   ObjectSetInteger(0,Name,OBJPROP_BACK,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTED,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_HIDDEN,ExtHide_OBJ);

//---
  }
//+------------------------------------------------------------------+
bool _EditCreate(const string           name="Edit",// object name 
                 const int              sub_window=0,             // subwindow index 
                 const string           text="Text",              // text 
                 const bool             reDraw=false,// ability to edit 
                 const bool             read_only=false,          // ability to edit 
                 const int              x=0,                      // X coordinate 
                 const int              y=0,                      // Y coordinate 
                 const int              width=50,                 // width 
                 const int              height=18,                // height 
                 const string           font="Arial",             // font 
                 const int              font_size=10,             // font size 
                 const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type 
                 const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                 const color            clr=clrBlack,             // text color 
                 const color            back_clr=clrWhite,        // background color 
                 const color            border_clr=clrNONE,       // border color 
                 const bool             back=false,               // in the background 
                 const bool             selection=false,          // highlight to move 
                 const bool             hidden=true,              // hidden in the object list 
                 const long             z_order=0)                // priority for mouse click 
  {
   long  chart_ID=0;
//--- reset the error value 
   ResetLastError();
//--- create edit field 
   if(ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
   else
     {

     }
   if(reDraw)
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
//--- set object coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text 

//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode 
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,ExtHide_OBJ);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _EditMove(const long   chart_ID=0,// chart's ID 
               const string name="Edit", // object name 
               const int    x=0,         // X coordinate 
               const int    y=0)         // Y coordinate 
  {
//--- reset the error value 
   ResetLastError();
//--- move the object 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the object! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the object! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
bool setBUTTON(string name,
               int panel,
               ENUM_BASE_CORNER CORNER,
               int XSIZE,int YSIZE,
               int XDIS,int YDIS,
               bool Bold,int FONTSIZE,color COLOR,color BG,color BBG,
               string TextStr
               )
  {
//---
   if(!ObjectCreate(0,name,OBJ_BUTTON,panel,0,0))
     {
      ObjectSet(name,OBJPROP_XDISTANCE,XDIS);
      ObjectSet(name,OBJPROP_YDISTANCE,YDIS);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,ExtHide_OBJ);
      return false;
     }
//---
   ObjectSetInteger(0,name,OBJPROP_XSIZE,XSIZE);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,YSIZE);

   ObjectSet(name,OBJPROP_XDISTANCE,XDIS);
   ObjectSet(name,OBJPROP_YDISTANCE,YDIS);

   ObjectSetString(0,name,OBJPROP_FONT,(Bold)?"Arial Black":"Arial");

   ObjectSetString(0,name,OBJPROP_TEXT,TextStr);
   ObjectSetInteger(0,name,OBJPROP_COLOR,COLOR);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,BBG);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER);

   return true;
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrNumber(double v)
  {
   if(v>0)
      return clrDodgerBlue;
   if(v<0)
      return clrRed;
   return clrGray;
  }
//+------------------------------------------------------------------+
void ObjManager(int v)
  {

   string name;
   string sep="_",result[];
   ushort  u_sep=StringGetCharacter(sep,0);

   int ObjTotal=ObjectsTotal();

   for(int i=0;i<ObjTotal;i++)
     {
      name=ObjectName(i);
      if(ObjectGetInteger(0,name,OBJPROP_TYPE,0)==OBJ_LABEL)
        {
         int k=StringSplit(name,u_sep,result);
         if(result[2]=="0" && result[1]!="Head")
           {
            string iSymbolName_Obj=result[1];

            //---
            bool found=false;
            for(int j=0;j<v;j++)
              {
               string iSymbolName_Watch=SymbolName(j,true);
               if(iSymbolName_Watch==iSymbolName_Obj)
                 {
                  found=true;
                  break;
                 }
              }
            //---
            if(!found)
              {
               ObjectsDeleteAll(0,ExtName_OBJ+"_"+iSymbolName_Obj);
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BoolToSrt(bool v)
  {
   return (v)?"True":"False";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LineNotify(string Massage)
  {
   string headers;
   char post[],result[];

   headers="Authorization: Bearer "+extoken+"\r\n";
   headers+="Content-Type: application/x-www-form-urlencoded\r\n";

   ArrayResize(post,StringToCharArray("message="+Massage,post,0,WHOLE_ARRAY,CP_UTF8)-1);

   int res=WebRequest("POST","https://notify-api.line.me/api/notify",headers,10000,post,result,headers);

//Print("Status code: ",res,",error: ",GetLastError());
   Print("Server response: ",CharArrayToString(result));
  }
//+------------------------------------------------------------------+
