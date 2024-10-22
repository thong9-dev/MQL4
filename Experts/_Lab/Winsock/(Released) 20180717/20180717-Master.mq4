//+------------------------------------------------------------------+
//|                                                     Diff Price M |
//|                                         Copyright 2019, HNM Dev. |
//|                                        https://www.fxhanuman.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2019, HNM Dev."
#property link      "https://www.fxhanuman.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//https://www.mql5.com/en/code/9296
//+------------------------------------------------------------------+


#define SOCKET_LIBRARY_USE_EVENTS
#define TIMER_FREQUENCY_MS          1
#include <Winsock/socket_ibrary.mqh>

enum E_OPERATION
  {
   BUY = OP_BUY,
   SELL = OP_SELL
  };

//--- input parameters
input string      category_server = "______Server Configuration______";    //-
input ushort      server_port = 5000;
ushort _port = server_port - 1;

input string      category_trading = "______Trading Configuration______";  //-
input E_OPERATION OP_CMD = BUY;
input int         magic_number = 20180717;
input double      exLots_Size = 0.01;

input int         exOpen_diff_points = 0;
input int         exClose_diff_points = 0;

input string      datetime_trading = "______Date Time Configuration______";   //-

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
//---

bool glbCreatedTimer = false;
bool State_Open_btn, State_Close_btn;
int slippage = 3;
int arrTickets[];
double Bid_Slave;
double Ask_Slave;
//+------------------------------------------------------------------+
double OpenD = (Bid_Slave != 0) ? (Ask - Bid_Slave) * MathPow(10, Digits) : 0;
double ClosD = (Ask_Slave != 0) ? (Ask_Slave - Bid) * MathPow(10, Digits) : 0;

string comment = IntegerToString(magic_number);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool StopNow()
  {
   switch(DayOfWeek())
     {
      case(MONDAY):
         return CheckStopTime(stop_mon);
      case(TUESDAY):
         return CheckStopTime(stop_tue);
      case(WEDNESDAY):
         return CheckStopTime(stop_wed);
      case(THURSDAY):
         return CheckStopTime(stop_thu);
      case(FRIDAY):
         return CheckStopTime(stop_fri);
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Obj_Create()
  {

   objRectLabelCreate(0, "AREA_REC", 0, 200, 30, 190, 130, clrWhiteSmoke, 2, CORNER_RIGHT_UPPER);
   objLabelCreate(0, "TITLE_LABEL", 0, 190, 40, CORNER_RIGHT_UPPER, "Price Difference M", "Arial", 14);
//---
   objLabelCreate(0, "TITLE_LABEL_Symbol", 0, 190, 70, CORNER_RIGHT_UPPER, "Symbol :: " + Symbol(), "Arial", 10, clrBlack);
   objLabelCreate(0, "TITLE_LABEL_chanel", 0, 190, 90, CORNER_RIGHT_UPPER, "Serverv Port :: " + string(_port), "Arial", 10, clrBlack);

//---

   objLabelCreate(0, "OPEN_DIFF_LABEL", 0, 190, 110, CORNER_RIGHT_UPPER, "Open Diff = ", "Arial", 10, clrBlack);
   objLabelCreate(0, "CLOSE_DIFF_LABEL", 0, 190, 130, CORNER_RIGHT_UPPER, "Close Diff = ", "Arial", 10, clrBlack);


   objLabelCreate(0, "OPEN_DIFF_VALUE_LABEL", 0, 120, 110, CORNER_RIGHT_UPPER, "Ask - [Bid_Slave]");
   objLabelCreate(0, "CLOSE_DIFF_VALUE_LABEL", 0, 120, 130, CORNER_RIGHT_UPPER, "[Ask_Slave] - Bid");
//---

   objButton_Create(0, "OPEN_BTN", 0, 200, 62, 200, 30, CORNER_RIGHT_LOWER, "Auto Open Order", "Arial", 10, clrBlack, clrCrimson);
   objButton_Create(0, "CLOSE_BTN", 0, 200, 30, 200, 30, CORNER_RIGHT_LOWER, "Auto Close Order", "Arial", 10, clrBlack, clrCrimson);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Obj_UpdatePanel()
  {
//ObjectSetString(0, "OPEN_DIFF_VALUE_LABEL", OBJPROP_TEXT, PadLeft(IntegerToString(((int)((Ask-bid)/Point)), 0), 5, "0"));
//ObjectSetString(0, "CLOSE_DIFF_VALUE_LABEL", OBJPROP_TEXT, PadLeft(IntegerToString(((int)((ask-Bid)/Point)), 0), 5, "0"));


//ObjectSetString(0, "OPEN_DIFF_VALUE_LABEL", OBJPROP_TEXT, DoubleToStr(OpenD, 0));
//ObjectSetString(0, "CLOSE_DIFF_VALUE_LABEL", OBJPROP_TEXT, DoubleToStr(ClosD, 0));

//ObjectSetInteger(0, "OPEN_DIFF_VALUE_LABEL", OBJPROP_COLOR, Obj_clrNum(OpenD));
//ObjectSetInteger(0, "CLOSE_DIFF_VALUE_LABEL", OBJPROP_COLOR, Obj_clrNum(ClosD));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color Obj_clrNum(double v)
  {
   if(v == 0)
      return clrBlack;
   return (v > 0) ? clrBlue : clrRed;
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   ObjectsDeleteAll();

   if(IsTesting())
     {
      Print("This ea is not available for back-testing.");
      ExpertRemove();
     }

   ArrayResize(glbClients, 0);

   if(1 == 1)
     {

      do
        {
         _port++;
         delete glbServerSocket;
         glbServerSocket = new ServerSocket(_port, false);
        }
      while(!glbServerSocket.Created());

      Print("Server socket created :: " + string(_port));
      glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);

     }
   else
     {

      glbServerSocket = new ServerSocket(server_port, false);
      if(glbServerSocket.Created())
        {
         Print("Server socket created");
         glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
        }
      else
        {
         Print("Server socket FAILED - is the port already in use?");
         //return(INIT_PARAMETERS_INCORRECT);
        }

     }

   arrTickets_Restore();
   Obj_Create();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   ObjectsDeleteAll();
//---

   glbCreatedTimer = false;

   for(int i = 0; i < ArraySize(glbClients); i++)
     {
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
void OnTick()
  {
   if(!glbCreatedTimer)
      glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
int Index_CMD = 5;
int Index_ACCOUNT = 4;
int Index_Symbol = 3;
int Index_Bid = 2;
int Index_Ask = 1;
int Index_Broker = 0;
//---
int DATA_ACCOUNT = 0;
int DATA_Broker = 5;
int DATA_Bid = 1;
int DATA_Ask = 2;
int DATA_Open = 3;
int DATA_Clos = 4;

string arrDATA[1, 6];
int arrDimCnt = 6;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void arrDATA_Show()
  {
   int n = (ArraySize(arrDATA) / arrDimCnt) - 1;
   string s = "#" + string(n) + "\n";
   s += "N | ID | Bid | Ask | D1 | D2 | Broker" + "\n-\n";
   for(int i = 0; i < n; i++)
     {
      s += string(i) + " :: ";
      for(int j = 0; j < arrDimCnt; j++)
        {
         s += arrDATA[i, j] + " | ";
        }
      s += "\n";
     }

   Comment(s);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   if(IsTradeAllowed())
     {

      AcceptNewConnections();

      for(int i = ArraySize(glbClients) - 1; i >= 0; i--)
        {
         ClientSocket * pClient = glbClients[i];
         string response = pClient.Receive("\r\n");

         if(stringRemoveWhitespace(response) != "")
           {

            //FromSlave :: Symbol;Bid;Ask;
            Print(string(__LINE__) + "@ Stream[response] = [" + response + "]");
            pClient.Send("PING\r\n");
            //return;

            string receive[];
            int s = StringSplit(response, ';', receive);

            if(s != 0)
              {
               s -= 2;
               if(SymbolFormat6(receive[s - Index_Symbol]) == SymbolFormat6(Symbol()))
                 {
                  if((Bid_Slave != StringToDouble(receive[s - Index_Bid]) && StringToDouble(receive[s - Index_Bid]) != 0) ||
                     (Ask_Slave != StringToDouble(receive[s - Index_Ask]) && StringToDouble(receive[s - Index_Ask]) != 0))
                    {

                     Bid_Slave = StringToDouble(receive[s - Index_Bid]);
                     Ask_Slave = StringToDouble(receive[s - Index_Ask]);

                     OpenD = (Bid_Slave != 0) ? (Ask - Bid_Slave) * MathPow(10, Digits) : 0;
                     ClosD = (Ask_Slave != 0) ? (Ask_Slave - Bid) * MathPow(10, Digits) : 0;
                     //---
                     bool f = false;
                     for(int j = 0; j < (ArraySize(arrDATA) / arrDimCnt); j++)
                       {
                        if(arrDATA[j, DATA_ACCOUNT] == receive[s - Index_ACCOUNT])
                          {
                           arrDATA[j, DATA_Broker] = receive[s - Index_Broker];
                           arrDATA[j, DATA_Bid] = DoubleToStr(Bid_Slave, Digits);
                           arrDATA[j, DATA_Ask] = DoubleToStr(Ask_Slave, Digits);

                           arrDATA[j, DATA_Open] = DoubleToStr(OpenD, 0);
                           arrDATA[j, DATA_Clos] = DoubleToStr(ClosD, 0);
                           //---
                           f = true;
                          }
                       }

                     if(!f)
                       {

                        int count = ArrayResize(arrDATA, (ArraySize(arrDATA) / arrDimCnt) + 1);
                        int h = (ArraySize(arrDATA) / arrDimCnt) - 2;
                        arrDATA[h, DATA_ACCOUNT] = receive[s - Index_ACCOUNT];
                        arrDATA[h, DATA_Broker] = receive[s - Index_Broker];
                        arrDATA[h, DATA_Bid] = DoubleToStr(Bid_Slave, Digits);
                        arrDATA[h, DATA_Ask] = DoubleToStr(Ask_Slave, Digits);

                        arrDATA[h, DATA_Open] = DoubleToStr(OpenD, 0);
                        arrDATA[h, DATA_Clos] = DoubleToStr(ClosD, 0);
                       }
                     //---

                    }
                  break;
                 }
              }
           }
        }



      //Obj_UpdatePanel();

      // 1.1
      if(State_Open_btn && !StopNow())
        {
         if(Bid_Slave <=  exOpen_diff_points)
           {

            double entry_price = (OP_CMD == OP_BUY) ? Ask : Bid;

            double OP_Lot = NormalizeDouble(exLots_Size, 2);
            double OP_Price = NormalizeDouble(entry_price, Digits);

            int t = OrderSend(NULL, OP_CMD, OP_Lot, OP_Price, slippage, 0, 0, comment, magic_number);

            if(t == -1)
              {
               Print("OrderSend Error");
              }
            else
              {

               ArrayResize(arrTickets, ArraySize(arrTickets) + 1);
               arrTickets[ArraySize(arrTickets) - 1] = t;

               State_Open_btn = !State_Open_btn;
               if(State_Open_btn)
                  objButton_ChangeClrBG(0, "OPEN_BTN", clrLightGreen);
               else
                  objButton_ChangeClrBG(0, "OPEN_BTN", clrCrimson);
              }
           }
        }

      // 1.2
      if(State_Close_btn && !StopNow())
        {
         if(Ask_Slave - Bid <= Point * exClose_diff_points)
           {

            for(int i = ArraySize(arrTickets) - 1; i >= 0; i--)
              {
               if(OrderSelect(arrTickets[i], SELECT_BY_TICKET))
                 {

                  double close_price = (OP_CMD == OP_BUY) ? Bid : Ask;
                  if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(close_price, Digits), slippage))
                    {
                     Print("OrderClose Error");
                    }
                  else
                    {
                     ArrayResize(arrTickets, ArraySize(arrTickets) - 1);
                    }
                 }
              }
           }
        }

      arrDATA_Show();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AcceptNewConnections()
  {
   ClientSocket * pNewClient = NULL;
   do
     {
      pNewClient = glbServerSocket.Accept();
      if(pNewClient != NULL)
        {
         int sz = ArraySize(glbClients);
         ArrayResize(glbClients, sz + 1);
         glbClients[sz] = pNewClient;
         Print("New client connection");

         pNewClient.Send("OK\r\n");
        }

     }
   while(pNewClient != NULL);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void arrTickets_Restore()
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == magic_number)
           {
            ArrayResize(arrTickets, ArraySize(arrTickets) + 1);
            arrTickets[ArraySize(arrTickets) - 1] = OrderTicket();
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Button_OnEvent()
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      //if(ObjectGetInteger(0, "OPEN_BTN", OBJPROP_STATE))       // Auto Open Order - Pressed
      if(sparam == "OPEN_BTN")
        {
         //ObjectSetInteger(0, "OPEN_BTN", OBJPROP_STATE, false);
         State_Open_btn = !State_Open_btn;

         if(State_Open_btn)
            objButton_ChangeClrBG(0, "OPEN_BTN", clrLightGreen);
         else
            objButton_ChangeClrBG(0, "OPEN_BTN", clrCrimson);
        }

      if(sparam == "CLOSE_BTN")    // Auto Close Order - Pressed
        {
         //ObjectSetInteger(0, "CLOSE_BTN", OBJPROP_STATE, false);
         State_Close_btn = !State_Close_btn;

         if(State_Close_btn)
            objButton_ChangeClrBG(0, "CLOSE_BTN", clrLightGreen);
         else
            objButton_ChangeClrBG(0, "CLOSE_BTN", clrCrimson);
        }
     }

//---

   if(id == CHARTEVENT_KEYDOWN)
     {
      //printf("CHARTEVENT_KEYDOWN: "+string(lparam));
      if(!IsTesting())
        {
         //ConsoleWrite(string(lparam));
         if(lparam == 9) //Tab
           {
            //DrawComment_ShowMN=(DrawComment_ShowMN)?false:true;
            //FIX_Magicnumber(DrawComment_ShowMN);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SymbolFormat6(string _symbol)
  {
   if(StringLen(_symbol) > 6)
     {
      string result = StringSubstr(_symbol, 0, 6);
      StringToUpper(result);
      return result;
     }
   else
      return _symbol;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string stringRemoveWhitespace(string str)
  {
   string result = str;
   StringReplace(result, " ", "");
   return result;
  }
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool objButton_Create(const long              chart_ID = 0,             // chart's ID
                      const string            name = "Button",          // button name
                      const int               sub_window = 0,           // subwindow index
                      const int               x = 0,                    // X coordinate
                      const int               y = 0,                    // Y coordinate
                      const int               width = 50,               // button width
                      const int               height = 18,              // button height
                      const ENUM_BASE_CORNER  corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                      const string            text = "Button",          // text
                      const string            font = "Arial",           // font
                      const int               font_size = 10,           // font size
                      const color             clr = clrBlack,           // text color
                      const color             back_clr = C'236,233,216', // background color
                      const color             border_clr = clrNONE,     // border color
                      const bool              state = false,            // pressed/released
                      const bool              back = false,             // in the background
                      const bool              selection = false,        // highlight to move
                      const bool              hidden = true,            // hidden in the object list
                      const long              z_order = 0)              // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ", GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set button size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set text color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border color
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- set button state
   ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Change background color the button                                                |
//+------------------------------------------------------------------+
bool objButton_ChangeClrBG(const long   chart_ID = 0,             // chart's ID
                           const string name = "Button",          // button name
                           const color  back_clr = C'236,233,216') // background color
  {
//--- reset the error value
   ResetLastError();
//--- change background color the button
   if(!ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr))
     {
      Print(__FUNCTION__,
            ": failed to change background color the button! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool objLabelCreate(const long              chart_ID = 0,             // chart's ID
                    const string            name = "Label",           // label name
                    const int               sub_window = 0,           // subwindow index
                    const int               x = 0,                    // X coordinate
                    const int               y = 0,                    // Y coordinate
                    const ENUM_BASE_CORNER  corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                    const string            text = "Label",           // text
                    const string            font = "Arial",           // font
                    const int               font_size = 10,           // font size
                    const color             clr = clrRed,             // color
                    const double            angle = 0.0,              // text slope
                    const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, // anchor type
                    const bool              back = false,             // in the background
                    const bool              selection = false,        // highlight to move
                    const bool              hidden = true,            // hidden in the object list
                    const long              z_order = 0)              // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID, name, OBJ_LABEL, sub_window, 0, 0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ", GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the text
   ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
   ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
   ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID, name, OBJPROP_ANGLE, angle);
//--- set anchor type
   ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Delete a text label                                              |
//+------------------------------------------------------------------+
/*bool objLabelDelete(const long   chart_ID=0,   // chart's ID
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
*/
//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool objRectLabelCreate(const long             chart_ID = 0,             // chart's ID
                        const string           name = "RectLabel",       // label name
                        const int              sub_window = 0,           // subwindow index
                        const int              x = 0,                    // X coordinate
                        const int              y = 0,                    // Y coordinate
                        const int              width = 50,               // width
                        const int              height = 18,              // height
                        const color            back_clr = C'236,233,216', // background color
                        const ENUM_BORDER_TYPE border = BORDER_SUNKEN,   // border type
                        const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                        const color            clr = clrRed,             // flat border color (Flat)
                        const ENUM_LINE_STYLE  style = STYLE_SOLID,      // flat border style
                        const int              line_width = 1,           // flat border width
                        const bool             back = false,             // in the background
                        const bool             selection = false,        // highlight to move
                        const bool             hidden = true,            // hidden in the object list
                        const long             z_order = 0)              // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a rectangle label
   if(!ObjectCreate(chart_ID, name, OBJ_RECTANGLE_LABEL, sub_window, 0, 0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle label! Error code = ", GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set label size
   ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set background color
   ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border type
   ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_TYPE, border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set flat border line style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set flat border width
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
//| Delete the rectangle label                                       |
//+------------------------------------------------------------------+
/*bool objRectLabelDelete(const long   chart_ID=0,       // chart's ID
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
  }*/
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckStopTime(string stop_day)
  {
   string _trim = StringTrimLeft(StringTrimRight(stop_day));
   string _split[];
   StringSplit(_trim, ';', _split);

   for(int i = 0; i < ArraySize(_split); i++)
     {
      string time_trim = StringTrimLeft(StringTrimRight(_split[i]));
      string time_split[];
      StringSplit(time_trim, '-', time_split);
      if(ArraySize(time_split) == 2)
        {
         if(TimeCurrent() >= StringToTime(time_split[0]) &&
            TimeCurrent() <= StringToTime(time_split[1]))
           {
            return true;
           }
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
