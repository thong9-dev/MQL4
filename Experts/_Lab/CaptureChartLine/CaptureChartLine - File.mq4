//+------------------------------------------------------------------+
//|                                             CaptureChartLine.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import

//--- input parameters
string LineToken="G7RrAe1f7G6l4GRRBpnZsC94ymkZJD0qFA0ixvQFyPk";
//G7RrAe1f7G6l4GRRBpnZsC94ymkZJD0qFA0ixvQFyPk   Hide
//P0EUrFcg21mlYTtZCKRzrxP1tc4fag66Os2qo5nZWin   gSwapTest

string LineBody,LineMSG;

static int BARS;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
string folder="CaptureLine";
string Src_path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+folder+"\\";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
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

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetFileName()
  {

   string T=TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES);
   string Str=Symbol()+"-"+StringSetChar(T,StringFind(T,":"),'.')+".png";
   return (Str);
  }
//+------------------------------------------------------------------+
void Hide_0()
  {
   string ha[6]=
     {
      "1WuxeSzM0JvNNXHChPGwps0QF7an3hZT7",
      "1NPSGBcJnikBBnfQbqwrzNoIqpkel-pWQ",
      "184Vr4y9NSJW9BkKYhe9IltxU_9hgCqb7",
      "1WuxeSzM0JvNNXHChPGwps0QF7an3hZT7",
      "1NPSGBcJnikBBnfQbqwrzNoIqpkel-pWQ",
      "184Vr4y9NSJW9BkKYhe9IltxU_9hgCqb7",
     };
   string na[6]=
     {
      "curl\\bin32\\curl-ca-bundle.crt",
      "curl\\bin32\\curl.exe",
      "curl\\bin32\\libcurl.dll",
      "curl\\bin64\\curl-ca-bundle.crt",
      "curl\\bin64\\curl.exe",
      "curl\\bin64\\libcurl-x64.dll",
     };
   int chk32=FileOpen("curl\\bin32\\t",FILE_READ|FILE_CSV); FileClose(chk32);
   int chk64=FileOpen("curl\\bin64\\t",FILE_READ|FILE_CSV); FileClose(chk64);
   if(chk32==-1 || chk64==-1)
     {
      //string PathCommon=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
      int filehandle;
      filehandle=FileOpen("curl\\bin32\\t",FILE_WRITE|FILE_CSV); FileClose(filehandle);
      filehandle=FileOpen("curl\\bin64\\t",FILE_WRITE|FILE_CSV); FileClose(filehandle);

      for(int i=0;i<6;i++)
        {
         string id=ha[i];
         string name=na[i];
         string sUrl="https://drive.google.com/uc?authuser=0&id="+id+"&export=download";
         string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Files\\",name);
         int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
         //printf(FileGet);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Hide(string LineMSG)
  {
   string iLineToken="G7RrAe1f7G6l4GRRBpnZsC94ymkZJD0qFA0ixvQFyPk";

   string FilePath32=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Files\\curl\\bin32\\curl.exe");
   string FilePath64=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Files\\curl\\bin64\\curl.exe");
//---
   LineMSG="CaptureChartLine32";
//      
   LineBody=" -X POST -H \"Authorization: Bearer "+iLineToken+"\"";
   LineBody+=" -F \"message="+LineMSG+"\"";
   LineBody+=" https://notify-api.line.me/api/notify";
   printf(string(ShellExecuteW(NULL,"Open",FilePath32,LineBody,NULL,NULL)));
//---
   LineMSG="CaptureChartLine64";
//      
   LineBody=" -X POST -H \"Authorization: Bearer "+iLineToken+"\"";
   LineBody+=" -F \"message="+LineMSG+"\"";
   LineBody+=" https://notify-api.line.me/api/notify";
   printf(string(ShellExecuteW(NULL,"Open",FilePath64,LineBody,NULL,NULL)));
  }
//+------------------------------------------------------------------+
