//+------------------------------------------------------------------+
//|                                         SimplePanelDialog_EA.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "https://www.facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (100)      // gap by X coordinate
#define CONTROLS_GAP_Y                      (10)      // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (150)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//+------------------------------------------------------------------+

#include "SimplePanelDialog.mqh"
#include "SimplePanelDialog - Copy.mqh"

CPanelDialog ExtDialog;
CPanelDialog ExtDialog2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//EventSetTimer(60);
//if(!ExtDialog.Create(0,"Notification",0,100,100,360,380))
   printf(ObjectFind(0,"1323Back"));
   if(ObjectFind(0,"Notification")<0)
     {
      if(!ExtDialog.Create(0,"Notification",0,50,50,150,100))
        {
         printf("A");      //return(INIT_FAILED);
        }
      if(!ExtDialog.Run())
        {
         printf("A");      //return(INIT_FAILED);
        }
     }
   if(ObjectFind(0,"Notification2")<0)
     {
if(!ExtDialog2.Create(0,"Notification2",0,50,150,150,100))
        {
         printf("B");      //return(INIT_FAILED);
        }
      if(!ExtDialog2.Run())
        {
         printf("B2");      //return(INIT_FAILED);
        }
     }
//return(INIT_FAILED);
//--- run application


   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   ExtDialog.Destroy(reason);
   ExtDialog2.Destroy(reason);
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
ExtDialog.ChartEvent(id,lparam,dparam,sparam);
ExtDialog2.ChartEvent(id,lparam,dparam,sparam);
//---
   if(id!=CHARTEVENT_CLICK && id!=10/*|| id==CHARTEVENT_OBJECT_CLICK*/)
     {
      printf("Event("+string(id)+"|"+string(lparam)+"|"+string(dparam)+"|"+sparam+")");
     }

//if(id==CHARTEVENT_MOUSE_MOVE)
// Comment("POINT: ",(int)lparam,",",(int)dparam,"\n",MouseState((uint)sparam));
  }
//+------------------------------------------------------------------+
string MouseState(uint state)
  {
   string res;
   res+="\nML: "   +(((state& 1)== 1)?"DN":"UP");   // mouse left 
   res+="\nMR: "   +(((state& 2)== 2)?"DN":"UP");   // mouse right  
   res+="\nMM: "   +(((state&16)==16)?"DN":"UP");   // mouse middle 
   res+="\nMX: "   +(((state&32)==32)?"DN":"UP");   // mouse first X key 
   res+="\nMY: "   +(((state&64)==64)?"DN":"UP");   // mouse second X key 
   res+="\nSHIFT: "+(((state& 4)== 4)?"DN":"UP");   // shift key 
   res+="\nCTRL: " +(((state& 8)== 8)?"DN":"UP");   // control key 
   return(res);
  }
//+------------------------------------------------------------------+
