//+------------------------------------------------------------------+
//|                                                       TestMa.mq4 |
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
   string HOST="https://mail.google.com/mail/feed/atom";
//---
   string user="lapukdee@gmail.com";
   string password="wdasqwe123";

   string str="Login="+user+"&Password="+password;
   //str="";
//---

   string Header=NULL;
   string ResultHeader;
   char   data[];  // Data array to send POST requests 
   char   ResultData[];

   ArrayResize(data,StringToCharArray(str,data,0,WHOLE_ARRAY,CP_UTF8)-1);

   ResetLastError();
   int res=WebRequest("POST",HOST,NULL,0,data,data,str);
   int err=GetLastError();

   printf("res: "+string(res)+" | err: "+string(err));

   string  PAGE=CharArrayToString(data,0,ArraySize(data),CP_ACP);

   int filehandle=FileOpen("PathXmlPush.xml",FILE_WRITE|FILE_BIN);
   if(filehandle!=INVALID_HANDLE)
     {
      FileWriteArray(filehandle,ResultData,0,ArraySize(ResultData));
      FileClose(filehandle);
     }
   else
      Print("Error in FileOpen. Error code=",GetLastError());

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
