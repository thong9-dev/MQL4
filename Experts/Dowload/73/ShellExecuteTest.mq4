//+------------------------------------------------------------------+
//|                                             ShellExecuteTest.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

/* ShellExecute defined in MSDN as
HINSTANCE ShellExecute(HWND hwnd, LPCTSTR lpVerb,LPCTSTR lpFile, LPCTSTR lpParameters, LPCTSTR lpDirectory,INT nShowCmd);

Look http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/shell/reference/functions/shellexecute.asp
for detailed information.*/

//---- let's define nShowCmd values
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

//---- we need to define import of SHELL32 DLL
#import "shell32.dll"
//---- defining ShellExecute
/* Normally we should define ShellExecute like this:
int ShellExecuteA(int hWnd,string lpVerb,string lpFile,string lpParameters,string lpDirectory,int nCmdShow);

But, we need to keep lpVerb,lpParameters and lpDirectory as NULL pointer to this function*/
//---- So we need to define it as (look: "string" parameters defined as "int" to keep them NULL):
int ShellExecuteA(int hWnd,int lpVerb,string lpFile,int lpParameters,int lpDirectory,int nCmdShow);
//---- we need to close import definition here
#import
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//---- let's do it!
   ShellExecuteA(0,0,"notepad.exe",0,0,SW_SHOW);
//----
   return(0);
  }
//+------------------------------------------------------------------+