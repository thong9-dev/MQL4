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
extern string extoken="P0EUrFcg21mlYTtZCKRzrxP1tc4fag66Os2qo5nZWin";//TokenLine
//sWyKPFRBeHSky0dCucuHpPIjxd93gn10QTl4731UgD5   Daren
//P0EUrFcg21mlYTtZCKRzrxP1tc4fag66Os2qo5nZWin   gTest

extern bool Mode2=true;//Both values are positive. @Mode2
extern ENUM_TIMEFRAMES TF=PERIOD_M30;//Update every
bool DevMode=false;
extern string exSpec=" ------------------------------- ";// -----------------------
extern color clrNumberPost=clrDodgerBlue;//NumberPost
extern color clrNumberNegt=clrTomato;//NumberNegt

extern color clrCFD=clrPlum;//CFD
extern color clrForex=clrLightGreen;//Forex
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
   ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,false);
   ChartSetInteger(0,CHART_DRAG_TRADE_LEVELS,false);
   ChartSetInteger(0,CHART_SHOW_OHLC,false);

   ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrWhite);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,Chart_BG);
   ChartSetInteger(0,CHART_COLOR_GRID,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrNONE);
   ChartSetInteger(0,CHART_COLOR_VOLUME,clrNONE);
   ChartSetInteger(0,CHART_COLOR_BID,clrNONE);
   ChartSetInteger(0,CHART_COLOR_ASK,clrNONE);
   ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,clrNONE);

//OnTick();
//Main();
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
int Size_High=13;
int PostX_Default=10,XStep=Size_Wide+2;
int PostY_Default=15,YStep=Size_High-1;

int PostX_DefaultTBL=0;
int PostY_DefaultTBL=0;

int iSymbolsTotal=-1;

sChart iChart;
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
   iSymbolsTotal=SymbolsTotal(true);

   Main_RemoveElement(iSymbolsTotal);
   Main_DrawElement(false,PostX_DefaultTBL,PostY_DefaultTBL);
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
      setEditCreate(ExtName_OBJ+"_Test_L_E",0,""
                    ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_CENTER,CORNER_LEFT_UPPER
                    ,clrWhite,Chart_BG,clrDodgerBlue,false,false,false,0);PostX+=XStep;
      PostX+=int(XStep*2.25);
      setEditCreate(ExtName_OBJ+"_Test_S_E",0,""
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
//int W=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0));
//int H=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
//---

   setLabel(ExtName_OBJ+"_Head_0_0","Symbol : "+string(iSymbolsTotal),"",clrGold,PostX,PostY);PostX+=int(XStep*2.75);
   setLabel(ExtName_OBJ+"_Head_2_0","SWAP LONG","",clrGold,PostX,PostY);PostX+=int(XStep*2.75);
   setLabel(ExtName_OBJ+"_Head_3_0","SWAP SHORT","",clrGold,PostX,PostY);PostX+=XStep;

   PostX=PostX_Default;
   PostY+=YStep+3;

   PostX_DefaultTBL=PostX;
   PostY_DefaultTBL=PostY;

//---
//Main_RemoveElement(iSymbolsTotal);
//---
//Main_DrawElement(true,PostX,PostY);
//---
   Main_CompareSymbol();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FristRun=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main_DrawElement(bool Mode,int PostX,int PostY)
  {
   ObjectSetString(0,ExtName_OBJ+"_Head_0_0",OBJPROP_TEXT,"Symbol : "+string(iSymbolsTotal));

   int H=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
//   
   int Column=PostX_Default;
   int ColumnV=0;

   int digits=StringLen(string(iSymbolsTotal));
//+------------------------------------------------------------------+

   datetime dt    =0;
   double   price =0;
   int      window=0;
//--- Convert the X and Y coordinates in terms of date/time 
   ChartXYToTimePrice(0,PostX+int(XStep*1.75)-1,PostY,window,dt,price);
   VLineCreate(0,"V"+string(ColumnV),0,dt,C'75,75,75',2,1,true,false,false,ExtHide_OBJ,0);
   ColumnV++;
   ChartXYToTimePrice(0,PostX+int(XStep*4.5)-1,PostY,window,dt,price);
   VLineCreate(0,"V"+string(ColumnV),0,dt,C'75,75,75',2,1,true,false,false,ExtHide_OBJ,0);
   ColumnV++;
//+------------------------------------------------------------------+
   for(int i=0;i<iSymbolsTotal;i++)
     {
      string iSymbolName=SymbolName(i,true);
      //if(MarketInfo(iSymbolName,MODE_TRADEALLOWED)==1)
        {
         //double iSYMBOL_BID=SymbolInfoDouble(iSymbolName,SYMBOL_BID);

         double iSYMBOL_SWAP_LONG=(!DevMode)?SymbolInfoDouble(iSymbolName,SYMBOL_SWAP_LONG):0;
         double iSYMBOL_SWAP_SHORT=(!DevMode)?SymbolInfoDouble(iSymbolName,SYMBOL_SWAP_SHORT):0;

         //CMM+=iSymbolName+" : "+DoubleToStr(iSYMBOL_SWAP_LONG,2)+" | "+DoubleToStr(iSYMBOL_SWAP_SHORT,2)+"\n";
         //--------------------
         long SWAP_MODE=SymbolInfoInteger(iSymbolName,SYMBOL_SWAP_MODE);
         color clrSymbolName=(SWAP_MODE==0)?clrForex:clrCFD;

         setLabel(ExtName_OBJ+"_"+iSymbolName+"_S0_0",CommaZero(i+1,digits,"")+" "+iSymbolName_Shor(iSymbolName,SWAP_MODE),"",clrSymbolName,PostX,PostY);PostX+=int(XStep*1.75);
         //--------------------

         if(!DevMode)
           {
            setEditCreate(ExtName_OBJ+"_"+iSymbolName+"_L_0",0,DoubleToStr(iSYMBOL_SWAP_LONG,2)
                          ,false,true,PostX,PostY,Size_Wide,Size_High,"Arial",9,ALIGN_RIGHT,CORNER_LEFT_UPPER
                          ,z_clrNumber(iSYMBOL_SWAP_LONG),Chart_BG,Chart_BG,false,false,false,0);
           }
         else
           {
            ObjectDelete(0,ExtName_OBJ+"_"+iSymbolName+"_L_0");
           }
         PostX+=XStep;
         //         
         double e=double(ObjectGetString(0,ExtName_OBJ+"_"+iSymbolName+"_L_E",OBJPROP_TEXT,0));

         setEditCreate(ExtName_OBJ+"_"+iSymbolName+"_L_E",0,DoubleToStr(iSYMBOL_SWAP_LONG,2)
                       ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",9,ALIGN_RIGHT,CORNER_LEFT_UPPER
                       ,z_clrNumber(e),Chart_BG,clrGray,false,false,false,0);
         PostX+=XStep+3;
         //
         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_L_<",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrGray,clrBlack,clrDimGray,"<");
         PostX+=int(Size_Wide*0.2);
         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_L_>",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrGray,clrBlack,clrDimGray,">");
         PostX+=int(XStep*0.5);
         //--------------------

         if(!DevMode)
           {
            setEditCreate(ExtName_OBJ+"_"+iSymbolName+"_S_0",0,DoubleToStr(iSYMBOL_SWAP_SHORT,2)
                          ,false,true,PostX,PostY,Size_Wide,Size_High,"Arial",9,ALIGN_RIGHT,CORNER_LEFT_UPPER
                          ,z_clrNumber(iSYMBOL_SWAP_SHORT),Chart_BG,Chart_BG,false,false,false,0);
           }
         else
           {
            ObjectDelete(0,ExtName_OBJ+"_"+iSymbolName+"_S_0");
           }
         PostX+=XStep;
         //         
         e=double(ObjectGetString(0,ExtName_OBJ+"_"+iSymbolName+"_S_E",OBJPROP_TEXT,0));

         setEditCreate(ExtName_OBJ+"_"+iSymbolName+"_S_E",0,DoubleToStr(iSYMBOL_SWAP_SHORT,2)
                       ,false,false,PostX,PostY,Size_Wide,Size_High,"Arial",9,ALIGN_RIGHT,CORNER_LEFT_UPPER
                       ,z_clrNumber(e),Chart_BG,C'100,100,100',false,false,false,0);
         PostX+=XStep+3;
         //
         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_S_<",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrGray,clrBlack,clrDimGray,"<");
         PostX+=int(Size_Wide*0.2);
         setBUTTON(ExtName_OBJ+"_"+iSymbolName+"_S_>",0,CORNER_LEFT_UPPER,
                   int(Size_Wide*0.25),Size_High,PostX,PostY,true,9,clrGray,clrBlack,clrDimGray,">");
         PostX+=XStep;
        }

      if(PostY>(H-Size_High*2))
        {
         PostY=PostY_Default-Size_High;
         Column+=540;

         ChartXYToTimePrice(0,Column-15,PostY,window,dt,price);
         VLineCreate(0,"V"+string(ColumnV),0,dt,C'75,75,75',0,5,true,false,false,ExtHide_OBJ,0);
         ColumnV++;
         ChartXYToTimePrice(0,Column+int(XStep*1.75)-1,PostY,window,dt,price);
         VLineCreate(0,"V"+string(ColumnV),0,dt,C'75,75,75',2,1,true,false,false,ExtHide_OBJ,0);
         ColumnV++;
         ChartXYToTimePrice(0,Column+int(XStep*4.5)-1,PostY,window,dt,price);
         VLineCreate(0,"V"+string(ColumnV),0,dt,C'75,75,75',2,1,true,false,false,ExtHide_OBJ,0);
         ColumnV++;
        }

      PostX=Column;
      PostY+=YStep;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main_CompareSymbol()
  {
   if(!FristRun)
      LineNotify(TimeToString(TimeLocal()));

   string name;
   string sep="_",result[];
   ushort  u_sep=StringGetCharacter(sep,0);
//---
   string strLine_Mode2_Post="#(+) Positive value.\n";
   string strLine_Mode2_Neg="#(-) Negative value.\n";
   int Mode2_PostCnt=0,Mode2_NegCnt=0;
   string Mode2_StrLineDump_Post[1];
   string Mode2_StrLineDump_Neg[1];
//---

   int ObjTotal=ObjectsTotal();

   for(int i=0;i<ObjTotal;i++)
     {
      name=ObjectName(i);
      if(ObjectGetInteger(0,name,OBJPROP_TYPE,0)==OBJ_BUTTON)
        {
         int k=StringSplit(name,u_sep,result);
         if(result[1]!="Head")
           {
            printf(name);

            if((result[3]==">" || result[3]=="<") && ObjectGetInteger(0,name,OBJPROP_STATE))
              {
               double SWAP=0;
               if(!DevMode)
                 {
                  SWAP=(result[2]=="L")?
                       SymbolInfoDouble(result[1],SYMBOL_SWAP_LONG):
                       SymbolInfoDouble(result[1],SYMBOL_SWAP_SHORT);
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
                  strLine+="Set : "+DoubleToStr(e,2)+"\n";
                  strLine+="Now : "+DoubleToStr(SWAP,2);

                  LineNotify(strLine);
                 }
               if(result[3]=="<" && SWAP<e)
                 {
                  //printf(result[1]+result[3]+" : "+e+" Under");

                  string strLine="\n";
                  strLine+="#"+result[1]+" : Swap Under.\n";
                  strLine+="Set : "+DoubleToStr(e,2)+"\n";
                  strLine+="Now : "+DoubleToStr(SWAP,2);

                  LineNotify(strLine);
                 }
              }
           }
        }
      //+------------------------------------------------------------------+
      if(Mode2)
        {
         if(ObjectGetInteger(0,name,OBJPROP_TYPE,0)==OBJ_LABEL)
           {
            int k=StringSplit(name,u_sep,result);
            if(result[1]!="Head")
              {
               double iSYMBOL_SWAP_LONG=(!DevMode)?
                                        SymbolInfoDouble(result[1],SYMBOL_SWAP_LONG):
                                        double(ObjectGetString(0,result[0]+"_"+result[1]+"_L_E",OBJPROP_TEXT,0));
               double iSYMBOL_SWAP_SHORT=(!DevMode)?
                                         SymbolInfoDouble(result[1],SYMBOL_SWAP_SHORT):
                                         double(ObjectGetString(0,result[0]+"_"+result[1]+"_S_E",OBJPROP_TEXT,0));

               if(iSYMBOL_SWAP_LONG>=0 && iSYMBOL_SWAP_SHORT>=0)
                 {
                  Mode2_PostCnt++;
                  if(!FristRun && Mode2_PostCnt>1 && MathMod(Mode2_PostCnt,30)==1)
                    {
                     string Dump[1];
                     Dump[0]=strLine_Mode2_Post;
                     ArrayCopy(Mode2_StrLineDump_Post,Dump,ArraySize(Mode2_StrLineDump_Post),0,WHOLE_ARRAY);
                     //                     
                     strLine_Mode2_Post="#(+) Positive value.\n";
                    }
                  strLine_Mode2_Post+=string(Mode2_NegCnt)+"# "+result[1]+"\n";
                  strLine_Mode2_Post+=DoubleToStr(iSYMBOL_SWAP_LONG,2)+"|"+DoubleToStr(iSYMBOL_SWAP_SHORT,2)+"\n";
                 }
               //
               if(iSYMBOL_SWAP_LONG<0 && iSYMBOL_SWAP_SHORT<0)
                 {
                  Mode2_NegCnt++;
                  if(!FristRun && Mode2_NegCnt>1 && MathMod(Mode2_NegCnt,30)==1)
                    {
                     string Dump[1];
                     Dump[0]=strLine_Mode2_Neg;
                     ArrayCopy(Mode2_StrLineDump_Neg,Dump,ArraySize(Mode2_StrLineDump_Neg),0,WHOLE_ARRAY);
                     //                     
                     strLine_Mode2_Neg="#(-) Negative value.\n";
                    }
                  strLine_Mode2_Neg+=string(Mode2_NegCnt)+"# "+result[1]+"\n";
                  strLine_Mode2_Neg+=DoubleToStr(iSYMBOL_SWAP_LONG,2)+"|"+DoubleToStr(iSYMBOL_SWAP_SHORT,2)+"\n";
                 }
              }
           }

        }//#Mode2
      //+------------------------------------------------------------------+
     }//#Loop

   if(!FristRun)
     {
     
      //+----------------------------
      //--- Mode2
      for(int i=1;i<ArraySize(Mode2_StrLineDump_Post);i++)
        {
         LineNotify(string(i)+"*"+Mode2_StrLineDump_Post[i]);
        }
      if(strLine_Mode2_Post!="#(+) Positive value.\n")
         LineNotify(string(ArraySize(Mode2_StrLineDump_Post))+"*"+strLine_Mode2_Post);
      //---
      for(int i=1;i<ArraySize(Mode2_StrLineDump_Neg);i++)
        {
         LineNotify(string(i)+"*"+Mode2_StrLineDump_Neg[i]);
        }
      if(strLine_Mode2_Neg!="#(-) Negative value.\n")
         LineNotify(string(ArraySize(Mode2_StrLineDump_Neg))+"*"+strLine_Mode2_Neg);
      //+----------------------------
     }

   FristRun=false;
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

            //clrGray,clrBlack,clrDimGray
            if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
              {
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrChartreuse);
               ObjectSetInteger(0,sparam,OBJPROP_COLOR,clrBlack);

               ObjectSetInteger(0,NameBTNSec,OBJPROP_BGCOLOR,clrBlack);
               ObjectSetInteger(0,NameBTNSec,OBJPROP_COLOR,clrGray);
               ObjectSetInteger(0,NameBTNSec,OBJPROP_STATE,false);
              }
            else
              {
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrBlack);
               ObjectSetInteger(0,sparam,OBJPROP_COLOR,clrGray);

              }
           }
         //---
         if(result[3]=="0")
           {
            double SWAP=(result[2]=="L")?
                        SymbolInfoDouble(result[1],SYMBOL_SWAP_LONG):
                        SymbolInfoDouble(result[1],SYMBOL_SWAP_SHORT);

            string NameBTNSec=result[0]+"_"+result[1]+"_"+result[2]+"_E";
            ObjectSetString(0,NameBTNSec,OBJPROP_TEXT,DoubleToStr(SWAP,2));
           }
         //---
         //---
         if(result[1]=="Test" || (result[1]=="Head" && result[2]=="0"))
           {
            //Print("On");
            Main_CompareSymbol();

/*if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
              {
               Main();
               ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
              }*/
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setLabel(string Name,string Text,string Tooltip,color clr,int PostX,int PostY)
  {
//ExtName_OBJ+"Head_1",
   ObjectCreate(Name,OBJ_LABEL,0,0,0);
   ObjectSetText(Name,Text,9,"Arial",clr);
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

//ObjectSetInteger(ChartID(),Name,OBJPROP_ALIGN,ALIGN_LEFT);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setEditCreate(const string           name="Edit",// object name 
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
color z_clrNumber(double v)
  {
   if(v>0)
      return clrNumberPost;
   if(v<0)
      return clrNumberNegt;
   return clrGray;
  }
//+------------------------------------------------------------------+
void Main_RemoveElement(int v)
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
         if(result[2]=="S0" && result[1]!="Head")
           {
            string iSymbolName_Obj=result[1];

            //---
/*bool found=false;
            for(int j=0;j<v;j++)
              {
               string iSymbolName_Watch=SymbolName(j,true);
               if(iSymbolName_Watch==iSymbolName_Obj)
                 {
                  found=true;
                  break;
                 }
              }*/
            //---
            //if(!found)
            if(!SymbolInfoInteger(iSymbolName_Obj,SYMBOL_SELECT))
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
string z_BoolToSrt(bool v)
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
//Print("Server response: ",CharArrayToString(result));
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
//|                                                                  |
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
string CommaZero(int v,int Digit,string z)
  {
   string temp=string(v);
   int n=StringLen(temp);

   string r="";
   for(int i=0;i<Digit-n;i++)
     {
      r+=" ";
     }
   r+=temp;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string iSymbolName_Shor(string iSymbolName,long SWAP_MODE)
  {
   if(SWAP_MODE==0)
     {
      if(StringLen(iSymbolName)>=6)
        {
         string r1=StringSubstr(iSymbolName,0,3);
         string r2=StringSubstr(iSymbolName,3,3);
         string r3=StringSubstr(iSymbolName,7,StringLen(iSymbolName)-7);
         return r1+" "+r2+" "+r3;
        }
     }
   return iSymbolName;
  }
//+------------------------------------------------------------------+
