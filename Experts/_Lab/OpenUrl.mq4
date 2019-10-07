//+------------------------------------------------------------------+
//|                                                      OpenUrl.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   openURL("https://www.google.com/");
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

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openURL(string url)
  {
   int APPEND=FILE_CSV|FILE_WRITE;
   string  file = WindowExpertName() + ".URL";
   int handle   = FileOpen(file, APPEND, '~');
   if(handle<1)
     {
      int GLE=GetLastError();
     }
   FileWrite(handle,"[InternetShortcut]");
   FileWrite(handle,"URL="+url);
   FileClose(handle);
   return ( Shell(TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+file) );
  }
#import "shell32.dll"
int ShellExecuteA(int hWnd,string Verb,string File,string Parameter,string Path,int ShowCmd);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Shell(string file,string parameters="")
  {
#define DEFDIRECTORY NULL
#define OPERATION "open"    // or print
#define SW_SHOWNORMAL 1
   int r=ShellExecuteA(0,OPERATION,file,parameters,DEFDIRECTORY,SW_SHOWNORMAL);
   if(r > 32) return(true);
   Alert("Shell failed: ",r);
   return(false);
  }
//+------------------------------------------------------------------+
