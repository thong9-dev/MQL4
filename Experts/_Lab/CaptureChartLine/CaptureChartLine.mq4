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

//--- input parameters
string LineToken="G7RrAe1f7G6l4GRRBpnZsC94ymkZJD0qFA0ixvQFyPk";
//G7RrAe1f7G6l4GRRBpnZsC94ymkZJD0qFA0ixvQFyPk   Hide
//P0EUrFcg21mlYTtZCKRzrxP1tc4fag66Os2qo5nZWin   gSwapTest
extern bool SendToLineNotify=true;

string folder="CaptureLine";
string Src_path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+folder+"\\";

string LineBody,LineMSG;

static int BARS;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   string FileName=GetFileName();
   string FullPath=Src_path+FileName;
   Print(FullPath);

//Print (FileName);
   int ScreenShotWidth=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)+50);
   int ScreenShotHeight=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)+50);
   ChartScreenShot(0,folder+"/"+FileName,ScreenShotWidth,ScreenShotHeight,0); // Capture หน้าจอเพื่อส่ง Line

   if(SendToLineNotify)
     {
      //ส่ง Line 
      LineMSG="CaptureChartLine";
      //      
      LineBody=" -X POST -H \"Authorization: Bearer "+LineToken+"\"";
      LineBody +=" -F \"message=" + LineMSG + "\"";
      LineBody +=" -F \"imageFile=@"+FullPath + "\"";
      LineBody +=" https://notify-api.line.me/api/notify";
      Print(LineBody);

      string PathCommon=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
      string Path_cURL=PathCommon+"\\curl\\bin\\curl.exe";
      //Print("Check Path of Common = ",PathCommon);

      ShellExecuteW(NULL,"Open",Path_cURL,LineBody,NULL,NULL);
     }
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
//double Uptrend=//???????????????????????????? 
//double Dntrend=//????????????????????????????
//if(Uptrend>Dntrend) //เปรียบเทียบเงื่อนไขการทำงาน
     {
      if(IsNewBar()) //ขึ้น Bar ใหม่
        {

        }
     }

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
bool IsNewBar()
  {
   if(BARS!=Bars(Symbol(),Period()))
     {
      BARS=Bars(Symbol(),Period());
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
string GetFileName()
  {
   string T=TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES);
   string Str=Symbol()+"-"+StringSetChar(T,StringFind(T,":"),'.')+".png";
   return (Str);
  }
//+------------------------------------------------------------------+
