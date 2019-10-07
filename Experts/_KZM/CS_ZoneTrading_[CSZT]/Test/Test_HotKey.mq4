//+------------------------------------------------------------------+
//|                                                  Test_HotKey.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#define KEY_NUMPAD_5       12 
#define KEY_LEFT           37 
#define KEY_UP             38 
#define KEY_RIGHT          39 
#define KEY_DOWN           40 
#define KEY_NUMLOCK_DOWN   98 
#define KEY_NUMLOCK_LEFT  100 
#define KEY_NUMLOCK_5     101 
#define KEY_NUMLOCK_RIGHT 102 
#define KEY_NUMLOCK_UP    104 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//--- enable object create events 
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);
//--- enable object delete events 
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_DELETE,true);
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
void OnTick()
  {
//---

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
//--- the left mouse button has been pressed on the chart 
   if(id==CHARTEVENT_CLICK)
     {
      //Print("The coordinates of the mouse click on the chart are: x = ",lparam,"  y = ",dparam);
     }
//--- the mouse has been clicked on the graphic object 
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //Print("The mouse has been clicked on the object with name '"+sparam+"'");
     }
//--- the key has been pressed 
   if(id==CHARTEVENT_KEYDOWN)
     {
      switch(int(lparam))
        {
         case KEY_NUMLOCK_LEFT:  Print("The KEY_NUMLOCK_LEFT has been pressed");   break;
         case KEY_LEFT:          Print("The KEY_LEFT has been pressed");           break;
         case KEY_NUMLOCK_UP:    Print("The KEY_NUMLOCK_UP has been pressed");     break;
         case KEY_UP:            Print("The KEY_UP has been pressed");             break;
         case KEY_NUMLOCK_RIGHT: Print("The KEY_NUMLOCK_RIGHT has been pressed");  break;
         case KEY_RIGHT:         Print("The KEY_RIGHT has been pressed");          break;
         case KEY_NUMLOCK_DOWN:  Print("The KEY_NUMLOCK_DOWN has been pressed");   break;
         case KEY_DOWN:          Print("The KEY_DOWN has been pressed");           break;
         case KEY_NUMPAD_5:      Print("The KEY_NUMPAD_5 has been pressed");       break;
         case KEY_NUMLOCK_5:     Print("The KEY_NUMLOCK_5 has been pressed");      break;
         default:                Print("Some not listed key has been pressed"+lparam);
        }
      ChartRedraw();
     }
//--- the object has been deleted 
   if(id==CHARTEVENT_OBJECT_DELETE)
     {
      Print("The object with name [",sparam,"] has been deleted");
     }
//--- the object has been created 
   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      Print("The object with name [",sparam,"] has been created");
     }
//--- the object has been moved or its anchor point coordinates has been changed 
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      Print("The anchor point coordinates of the object with name ",sparam," has been changed");
     }
//--- the text in the Edit of object has been changed 
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      Print("The text in the Edit field of the object with name ",sparam," has been changed");
     }
  }
//+------------------------------------------------------------------+
