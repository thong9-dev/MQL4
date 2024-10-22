//+------------------------------------------------------------------+
//|                                                     AvaPromt.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 05-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.30"
#property strict

extern int MagicNumber=654;

string eaName_TageObj="AvaPromt@";
bool eaHidenObj=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
double Symbol_SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
//---

int OnInit()
  {
//--- create timer//---
   EventSetTimer(60);
//--- 
   DrawPanel();
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
double  LotsSave=0.01;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   DrawPanel();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
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
//---
   if(id==CHARTEVENT_KEYDOWN)
     {
      printf("CHARTEVENT_KEYDOWN: "+string(lparam));
      if(!IsTesting())
        {
         if(lparam==9)
           {
            DrawPanel_HideShow();
           }
         OnTick();
        }
     }
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Print("CHARTEVENT_OBJECT_CLICK: '"+sparam+"'");

      if(sparam==eaName_TageObj+"HP@BTN_Head")
        {
         DrawPanel_HideShow();
        }
      //---
      if(sparam==eaName_TageObj+"PN@BTN_Hage")
        {

         int  _MessageBox=MessageBox(
                                     "Want to open an order?",       // message text 
                                     eaName_TageObj+"Open Order",    // box header 
                                     MB_YESNO|MB_ICONQUESTION        // defines set of buttons in the box 
                                     );
         if(_MessageBox==IDYES)
           {
            double  lots=StringToDouble(ObjectGetString(ChartID(),eaName_TageObj+"PN@Label_Lot_Set",OBJPROP_TEXT,0));

            printf("#"+string(__LINE__)+" Get-lots: ["+lots+"]");
            int ticket=-1,err=-1;
            ResetLastError();
            ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,100,0,0,eaName_TageObj+Symbol(),MagicNumber,0);
            err=GetLastError();
            if(err!=0)
              {
               printf("#"+string(__LINE__)+" OP_BUY ERROR code: ["+string(err)+"]");
              }
            else
              {
               ResetLastError();
               ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,100,0,0,eaName_TageObj+Symbol(),MagicNumber,0);
               err=GetLastError();
               if(err!=0)
                 {
                  printf("#"+string(__LINE__)+" OP_SELL ERROR code: ["+string(err)+"]");
                 }
              }

           }
        }
      //---
      if(sparam==eaName_TageObj+"PN@BTN_CloseAll")
        {
         int  _MessageBox=MessageBox(
                                     "Want to close all orders?",// message text 
                                     eaName_TageObj+"Close Order",// box header 
                                     MB_YESNO|MB_ICONQUESTION        // defines set of buttons in the box 
                                     );
         if(_MessageBox==IDYES)
           {
            Order_CloseAll(MagicNumber);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_CloseAll(int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)==false)) continue;

      if(OrderSymbol()==Symbol() && 
         OrderMagicNumber()==Magic)
        {
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(ORDER_TICKET_CLOSE);i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),100);
            if(GetLastError()==0)
              {
               ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;
              }
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DrawPanel_Show=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//---
void DrawPanel()
  {
   if(DrawPanel_Show)
     {
      Symbol_SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
      //---
      int Magin_Width=20;

      int BTN_Width=125;
      int BTN_Hight=25;

      int Magin=10;

      int Post_Y=25,Post_StepY=25+5;

      int Post_X_def=BTN_Width+Magin+Magin;
      int Post_X=25,Post_StepX=25+5;

      setRectLabelCreate("PN@BG",BTN_Width+Magin_Width+Magin,55,clrNONE,clrLightYellow,clrLime,BTN_Width+(Magin*2),175,false);

      setButtonCreate(0,"HP@BTN_Head",0,
                      Post_X_def+Magin,Post_Y,BTN_Width+(Magin*2),25,CORNER_RIGHT_UPPER,
                      "Ava.Promt 1.30","Arial",13,clrWhite,clrDarkGoldenrod,clrDarkGoldenrod,
                      false,false,false);

      Post_Y+=Post_StepY+10;
      Post_X=Post_X_def+10;
      //---
      Post_Y-=28;
      setEditCreate("PN@Label_SpreadVar",string(Symbol_SPREAD),true,true,int((BTN_Width+Magin_Width+Magin)-(BTN_Width*0.5)),Post_Y+20+10,80,25,20,0,1,clrBlack,clrLightYellow,clrLightYellow,false,false);
      Post_Y+=55;
      LabelCreate("PN@Label_SpreadHead",int((BTN_Width+Magin_Width+Magin)-(BTN_Width*0.68)),Post_Y,"Spread",11,clrBlack,false);
      Post_Y+=15;
      LabelCreate("PN@Label_Line",(BTN_Width+Magin_Width),Post_Y,"-------------------------",11,clrBlack,false);

      //---

      Post_Y+=Post_StepY-10;
      Post_X=Post_X_def;

      setEditCreate("PN@Label_Lot_Head","Lots:",true,true,Post_X,Post_Y,50,25,12,ALIGN_LEFT,1,clrBlack,clrLightYellow,clrLightYellow,false,false);
      Post_X-=50+15;
      setEditCreate("PN@Label_Lot_Set",string(LotsSave),false,false,Post_X,Post_Y,60,25,10,ALIGN_RIGHT,1,clrBlack,clrWhite,clrBlack,false,false);
      //---

      Post_Y+=Post_StepY+10;
      Post_X=Post_X_def;
      setButtonCreate(0,"PN@BTN_Hage",0,
                      Post_X_def,Post_Y,BTN_Width,25,CORNER_RIGHT_UPPER,
                      "Hage","Arial",13,clrWhite,clrLime,clrDarkGoldenrod,
                      false,false,false);
      Post_Y+=Post_StepY;
      Post_X=Post_X_def;
      setButtonCreate(0,"PN@BTN_CloseAll",0,
                      Post_X_def,Post_Y,BTN_Width,25,CORNER_RIGHT_UPPER,
                      "Close All","Arial",13,clrWhite,clrRed,clrDarkGoldenrod,
                      false,false,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPanel_HideShow()
  {
   if(DrawPanel_Show)
     {
      LotsSave=StringToDouble(ObjectGetString(ChartID(),eaName_TageObj+"PN@Label_Lot_Set",OBJPROP_TEXT,0));
     }

   printf("LotsSave: "+string(LotsSave));
   DrawPanel_Show=(DrawPanel_Show)?false:true;
   printf("DrawPanel_Show: "+string(DrawPanel_Show));
   if(!DrawPanel_Show)
     {
      ObjectsDeleteAll(0,eaName_TageObj+"PN",0,OBJ_BUTTON);
      ObjectsDeleteAll(0,eaName_TageObj+"PN",0,OBJ_EDIT);
      ObjectsDeleteAll(0,eaName_TageObj+"PN",0,OBJ_RECTANGLE_LABEL);
      ObjectsDeleteAll(0,eaName_TageObj+"PN",0,OBJ_LABEL);
     }
   else
     {
      DrawPanel();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setButtonCreate(const long              chart_ID=0,// chart's ID 
                     string            name="Button",// button name 
                     const int               sub_window=0,             // subwindow index 
                     const int               x=0,                      // X coordinate 
                     const int               y=0,                      // Y coordinate 
                     const int               width=50,                 // button width 
                     const int               height=18,                // button height 
                     const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                     const string            text="Button",            // text 
                     const string            font="Arial",             // font 
                     const int               font_size=10,             // font size 
                     const color             clr=clrBlack,             // text color 
                     const color             back_clr=C'236,233,216',  // background color 
                     const color             border_clr=clrNONE,       // border color 
                     const bool              state=false,              // pressed/released 
                     const bool              back=false,               // in the background 
                     const bool              selection=false)          // highlight to move 
  {

   name=eaName_TageObj+name;
//--- reset the error value 
   ResetLastError();
//--- create the button 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      //Print(__FUNCTION__,
      //      ": failed to create the button! Error code = ",GetLastError());
      //return(false);
     }
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool setEditCreate(string           name="Edit",// object name 
                   const string           text="Text",// text 
                   const bool             reDraw=false,// ability to edit 
                   const bool             read_only=false,          // ability to edit 
                   const int              x=0,                      // X coordinate 
                   const int              y=0,                      // Y coordinate 
                   const int              width=50,                 // width 
                   const int              height=18,                // height 
                   const int              font_size=10,             // font size 
                   const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type 
                   const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                   const color            clr=clrBlack,             // text color 
                   const color            back_clr=clrWhite,        // background color 
                   const color            border_clr=clrNONE,       // border color 
                   const bool             back=false,               // in the background 
                   const bool             selection=false)          // highlight to move 
  {
   long  chart_ID=0;
   name=eaName_TageObj+name;

//--- reset the error value 
   ResetLastError();
//--- create edit field 
   if(ObjectCreate(chart_ID,name,OBJ_EDIT,0,0,0))
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
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void setRectLabelCreate(string name,int x,int y,color clr,color back_clr,color border_clr,int width,int height,bool selection)
  {
   int chart_ID=0;
//---
   name=eaName_TageObj+name;

   int sub_window=0;
   int corner=CORNER_RIGHT_UPPER;
   string font="Arial";

   bool back=false;
   bool state=true;
   int z_order=0;

   ENUM_BORDER_TYPE border=BORDER_FLAT;
   ENUM_LINE_STYLE style=STYLE_SOLID;
   int line_width=4;
//--- reset the error value 
   ResetLastError();
//--- create a rectangle label 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      //Print(__FUNCTION__,": failed to create a rectangle label! Error code = ",GetLastError());
      //return;
     }
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode) 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool LabelCreate(string            name="Label",// label name 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const string            text="Label",             // text 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const bool              back=false)               // in the background 

  {
   long              chart_ID=0;// chart's ID 
   int               sub_window=0;// subwindow index 
   ENUM_BASE_CORNER  corner=CORNER_RIGHT_UPPER;// chart corner for anchoring 
   string            font="Arial";// font 
   double            angle=0;                // text slope 
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER; // anchor type 
   long              z_order=0;                // priority for mouse click 
   bool              selection=false; // highlight to move 
   name=eaName_TageObj+name;

//--- reset the error value 
   ResetLastError();
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
     }
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
