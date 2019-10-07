//+------------------------------------------------------------------+
//|                                           File_search_handle.mq4 |
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
string l(int v)
  {
   return "#"+string(v)+" ";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   printf(l(__LINE__)+"//+------------------------------------------------------------------+");
   FileSearch("ZoneTrade2","CJ_ZoneA.csv");
   printf(l(__LINE__)+"//+------------------------------------------------------------------+");

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
bool FileSearch(string path,string FileSearch)
  {
   bool FileSearch_chk=false;
   string InpFilter=path+"\\"+FileSearch;

   string fileNameTemp;
   long search_handle=FileFindFirst(InpFilter,fileNameTemp);
//--- check if the FileFindFirst() is executed successfully
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         if(StringFind(fileNameTemp,FileSearch,0)>=0)
            FileSearch_chk=true;
         //printf(l(__LINE__)+fileNameTemp);
        }
      while(FileFindNext(search_handle,fileNameTemp));
      FileFindClose(search_handle);
     }
   else
      Print("Files not found! \""+InpFilter+"\"");

   return FileSearch_chk;
  }
//+------------------------------------------------------------------+
