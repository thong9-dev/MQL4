//+------------------------------------------------------------------+
//|                                               Open_Something.mq4 |
//|                      Copyright © 2008, www.marketprogramming.com |
//|                                 http://www.marketprogramming.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, www.marketprogramming.com"
#property link      "http://www.marketprogramming.com"



//CHANGE BELOW!!!!!!!!!!!!!!
extern string What_To_Open="http://www.forexfactory.com";
//CHANGE ABOVE!!!!!!!!!!!!!!


#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10
#define SW_FORCEMINIMIZE    11
#define SW_MAX              11
#import "shell32.dll"
int ShellExecuteA(int hWnd,int lpVerb,string lpFile,int lpParameters,int lpDirectory,int nCmdShow);
#import
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- 
   int r=ShellExecuteA(0,0,What_To_Open,0,0,SW_SHOW);
   Comment("Copyright © 2008, www.marketprogramming.com : "+string(r));
//----
   return(0);
  }
//+------------------------------------------------------------------+
