//+------------------------------------------------------------------+
//|                                              20180717-Master.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define SOCKET_LIBRARY_USE_EVENTS
#define TIMER_FREQUENCY_MS          1
#include <socket-library.mqh>

enum E_OPERATION {
   BUY=OP_BUY,
   SELL=OP_SELL
};

//--- input parameters
input string      category_server = "______Server Configuration______";
input ushort      server_port = 3000;
input string      category_trading = "______Trading Configuration______";
input E_OPERATION cmd = BUY;
input int         magic_number = 20180717;
input double      lots_size = 0.01;
input int         open_diff_points = 0;
input int         close_diff_points = 0;
input string      datetime_trading = "______Date Time Configuration______";
input string      stop_mon = "";  // Stop On Monday
input string      stop_tue = "";  // Stop On Tuesday
input string      stop_wed = "";  // Stop On Wednesday
input string      stop_thu = "";  // Stop On Thursday
input string      stop_fri = "";  // Stop On Friday

// --------------------------------------------------------------------
// Global variables and constants
// --------------------------------------------------------------------
ServerSocket * glbServerSocket;
ClientSocket * glbClients[];
bool glbCreatedTimer = false;
bool open_btn, close_btn;
int slippage = 3;
int tickets[];
double bid, ask;
string comment = IntegerToString(magic_number);

bool CheckStopTime(string stop_day) {
   string _trim = StringTrimLeft(StringTrimRight(stop_day));
   string _split[];
   StringSplit(_trim, ';', _split);
   
   for (int i = 0; i < ArraySize(_split); i++) {
      string time_trim = StringTrimLeft(StringTrimRight(_split[i]));
      string time_split[];
      StringSplit(time_trim, '-', time_split);
      if (ArraySize(time_split) == 2) {
         if (TimeCurrent() >= StringToTime(time_split[0]) && TimeCurrent() <= StringToTime(time_split[1])) {
            return true;
         }
      }
   }
   
   return false;
}

bool StopNow() {
   switch (DayOfWeek()) {
      case (MONDAY): return CheckStopTime(stop_mon);
      case (TUESDAY): return CheckStopTime(stop_tue);
      case (WEDNESDAY): return CheckStopTime(stop_wed);
      case (THURSDAY): return CheckStopTime(stop_thu);
      case (FRIDAY): return CheckStopTime(stop_fri);
   }
   
   return false;
}

void CreateObj() {
   
   RectLabelCreate(0, "AREA_REC", 0, 200, 30, 200, 160, clrWhiteSmoke, 2, CORNER_RIGHT_UPPER);
   LabelCreate(0, "TITLE_LABEL", 0, 180, 60, CORNER_RIGHT_UPPER, "Price Difference", "Arial", 14);
   LabelCreate(0, "OPEN_DIFF_LABEL", 0, 170, 120, CORNER_RIGHT_UPPER, "Open Diff = ", "Arial", 10, clrBlack);
   LabelCreate(0, "CLOSE_DIFF_LABEL", 0, 170, 145, CORNER_RIGHT_UPPER, "Close Diff = ", "Arial", 10, clrBlack);
   
   LabelCreate(0, "OPEN_DIFF_VALUE_LABEL", 0, 70, 120, CORNER_RIGHT_UPPER, PadLeft("0", 5, "0"));
   LabelCreate(0, "CLOSE_DIFF_VALUE_LABEL", 0, 70, 145, CORNER_RIGHT_UPPER, PadLeft("0", 5, "0"));
   
   ButtonCreate(0, "OPEN_BTN", 0, 200, 62, 200, 30, CORNER_RIGHT_LOWER, "Auto Open Order", "Arial", 10, clrBlack, clrCrimson);
   ButtonCreate(0, "CLOSE_BTN", 0, 200, 30, 200, 30, CORNER_RIGHT_LOWER, "Auto Close Order", "Arial", 10, clrBlack, clrCrimson);
}

void UpdateObj() {
   ObjectSetString(0, "OPEN_DIFF_VALUE_LABEL", OBJPROP_TEXT, PadLeft(IntegerToString(((int)((Ask-bid)/Point)), 0), 5, "0"));
   ObjectSetString(0, "CLOSE_DIFF_VALUE_LABEL", OBJPROP_TEXT, PadLeft(IntegerToString(((int)((ask-Bid)/Point)), 0), 5, "0"));
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

   ObjectsDeleteAll();

   if (IsTesting()) {
      Print("This ea is not available for back-testing.");
      ExpertRemove();
   }
   
   ArrayResize(glbClients, 0);
   
   glbServerSocket = new ServerSocket(server_port, false);
   if (glbServerSocket.Created()) {
      Print("Server socket created");
      glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
   } else {
      Print("Server socket FAILED - is the port already in use?");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   RestoreTickets();
   CreateObj();

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   
   ObjectsDeleteAll();
   
   glbCreatedTimer = false;
   
   for (int i = 0; i < ArraySize(glbClients); i++) {
      delete glbClients[i];
   }
   
   delete glbServerSocket;
   Print("Server socket terminated");
   
   //--- destroy timer
   EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if (!glbCreatedTimer) glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {

   ButtonEvent();
   
   AcceptNewConnections();
   
   for (int i = ArraySize(glbClients) - 1; i >= 0; i--) {
      ClientSocket * pClient = glbClients[i];
      string response = pClient.Receive();
      
      if (stringRemoveWhitespace(response) != "") {
      
         Print("stream = ", response);
      
         string receive[];
         StringSplit(response, ';', receive);
         
         if (ArraySize(receive) >= 4) {
            int symbolIndex = ArraySize(receive) - 4;
            int bidIndex = ArraySize(receive) - 3;
            int askIndex = ArraySize(receive) - 2;
            
            if (SymbolFormat(receive[symbolIndex]) == SymbolFormat(Symbol())) {
               if ((bid != StringToDouble(receive[bidIndex]) && StringToDouble(receive[bidIndex]) != 0) || (ask != StringToDouble(receive[askIndex]) && StringToDouble(receive[askIndex]) != 0)) {
                  bid = StringToDouble(receive[bidIndex]);
                  ask = StringToDouble(receive[askIndex]);
               }
               break;
            }
         }   
      }
   }
   
   UpdateObj();
   
   // 1.1
   if (open_btn && !StopNow()) {
      if (Ask-bid <= Point * open_diff_points) {
      
         double entry_price = (cmd == OP_BUY) ? Ask : Bid;
         
         ArrayResize(tickets, ArraySize(tickets) + 1);
         tickets[ArraySize(tickets) - 1] = OrderSend(NULL, cmd, NormalizeDouble(lots_size, 2), NormalizeDouble(entry_price, Digits), slippage, 0, 0, comment, magic_number);
         if (tickets[ArraySize(tickets) - 1] == -1) {
            ArrayResize(tickets, ArraySize(tickets) - 1);
            Print("OrderSend Error");
         } else {
         
            open_btn = !open_btn;
            if (open_btn) ButtonChangeBackgroundColor(0, "OPEN_BTN", clrLightGreen);
            else ButtonChangeBackgroundColor(0, "OPEN_BTN", clrCrimson);
         }
      }
   }   
   
   // 1.2
   if (close_btn && !StopNow()) {
      if (ask-Bid <= Point * close_diff_points) {
         
         for (int i = ArraySize(tickets) - 1; i >= 0; i--) {
            if (OrderSelect(tickets[i], SELECT_BY_TICKET)) {
            
               double close_price = (cmd == OP_BUY) ? Bid : Ask;
               if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(close_price, Digits), slippage)) {
                  Print("OrderClose Error");
               } else {
                  ArrayResize(tickets, ArraySize(tickets) - 1);
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+

void AcceptNewConnections()
{
   ClientSocket * pNewClient = NULL;
   do {
      pNewClient = glbServerSocket.Accept();
      if (pNewClient != NULL) {
         int sz = ArraySize(glbClients);
         ArrayResize(glbClients, sz + 1);
         glbClients[sz] = pNewClient;
         Print("New client connection");
         
         pNewClient.Send("OK\r\n");
      }
      
   } while (pNewClient != NULL);
}

void RestoreTickets() {
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == magic_number) {
            ArrayResize(tickets, ArraySize(tickets) + 1);
            tickets[ArraySize(tickets) - 1] = OrderTicket();
         }
      }
   }
}

void ButtonEvent() {
   if (ObjectGetInteger(0, "OPEN_BTN", OBJPROP_STATE)) { // Auto Open Order - Pressed
   
      ObjectSetInteger(0, "OPEN_BTN", OBJPROP_STATE, false);
      open_btn = !open_btn;
      
      if (open_btn) ButtonChangeBackgroundColor(0, "OPEN_BTN", clrLightGreen);
      else ButtonChangeBackgroundColor(0, "OPEN_BTN", clrCrimson);
   }
   
   if (ObjectGetInteger(0, "CLOSE_BTN", OBJPROP_STATE)) { // Auto Close Order - Pressed
      
      ObjectSetInteger(0, "CLOSE_BTN", OBJPROP_STATE, false);
      close_btn = !close_btn;
      
      if (close_btn) ButtonChangeBackgroundColor(0, "CLOSE_BTN", clrLightGreen);
      else ButtonChangeBackgroundColor(0, "CLOSE_BTN", clrCrimson);
   }
}

string PadLeft(string str, int total_width, string padding) {
   int prefix_width = total_width - StringLen(str);
   
   string result;
   long number = StringToInteger(str);
   if (number < 0) {
      result += "- ";
      prefix_width++;
   } else if (number > 0) {
      result += "+";
   }
   
   for (int i = 0; i < prefix_width; i++) {
      result += padding;
   }
   
   return result + DoubleToString(MathAbs(number), 0);
}

string SymbolFormat(string _symbol) {
   if (StringLen(_symbol) > 6) {
      string result = StringSubstr(_symbol, 0, 6);
      StringToUpper(result);
      return result;
   } else return _symbol;   
}

string stringRemoveWhitespace(string str) {
   string result = str;
   StringReplace(result, " ", "");
   return result;
}
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
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
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
{
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Change background color the button                                                |
//+------------------------------------------------------------------+
bool ButtonChangeBackgroundColor(const long   chart_ID=0,               // chart's ID
                                 const string name="Button",            // button name
                                 const color  back_clr=C'236,233,216')  // background color
{
//--- reset the error value
   ResetLastError();
//--- change background color the button
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr))
     {
      Print(__FUNCTION__,
            ": failed to change background color the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
{
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
bool LabelDelete(const long   chart_ID=0,   // chart's ID
                 const string name="Label") // label name
{
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                     const string           name="RectLabel",         // label name
                     const int              sub_window=0,             // subwindow index
                     const int              x=0,                      // X coordinate
                     const int              y=0,                      // Y coordinate
                     const int              width=50,                 // width
                     const int              height=18,                // height
                     const color            back_clr=C'236,233,216',  // background color
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr=clrRed,               // flat border color (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                     const int              line_width=1,             // flat border width
                     const bool             back=false,               // in the background
                     const bool             selection=false,          // highlight to move
                     const bool             hidden=true,              // hidden in the object list
                     const long             z_order=0)                // priority for mouse click
{
//--- reset the error value
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Delete the rectangle label                                       |
//+------------------------------------------------------------------+
bool RectLabelDelete(const long   chart_ID=0,       // chart's ID
                     const string name="RectLabel") // label name
{
//--- reset the error value
   ResetLastError();
//--- delete the label
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a rectangle label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
}