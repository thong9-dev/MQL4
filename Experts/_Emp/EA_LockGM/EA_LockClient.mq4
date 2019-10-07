//+------------------------------------------------------------------+
//|                                                EA_LockClient.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import


string Identity="1VmDuqo4MiYr5RSsbCy0_PIT6ozVrR6t5";//GooldleDrive #Identity

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   Permissions();
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
bool Permissions()
  {
   bool Active=false;

   string _ACCOUNT_LOGIN=string(AccountInfoInteger(ACCOUNT_LOGIN));
   string _ACCOUNT_NAME=AccountInfoString(ACCOUNT_NAME);

   string PathMT4="LockClient\\";
   string ListName="ListName.xml";

   int ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);
   FileClose(ListName_Hand);
   FileDelete(PathMT4+ListName);

   string sUrl="https://drive.google.com/uc?authuser=0&id="+Identity+"&export=download";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\"+PathMT4,ListName);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);

//---
   ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);

   int Find=-1;
   string result[];
   string str;
   while(!FileIsEnding(ListName_Hand))
     {
      str=FileReadString(ListName_Hand);
      PrintFormat("String ["+str+"]");
      if(str!="<List>" && str!="</List>" && str!="")
        {
         StringReplace(str,"<User>","");
         StringReplace(str,"</User>","");

         int k=StringSplit(str,StringGetCharacter(",",0),result);

         if(result[0]==_ACCOUNT_LOGIN)
           {
            if(StringFind(_ACCOUNT_NAME,result[1],0)>=0 &&
               StringFind(_ACCOUNT_NAME,result[2],0)>=0)
              {
               Find=0;
               if(result[3]=="1")
                 {
                  Active=true;
                 }
              }
            break;
           }
        }
     }
   FileClose(ListName_Hand);
   FileDelete(PathMT4+ListName);

   string CMM="";
   CMM+="\n _ACCOUNT_LOGIN: "+_ACCOUNT_LOGIN;
   CMM+="\n _ACCOUNT_NAME: "+_ACCOUNT_NAME;
   CMM+="\n";
   CMM+="\n Find: "+string(Find);
   CMM+="\n Active: "+string(Active);
   Comment(CMM);

   return Active;
  }
//+------------------------------------------------------------------+
