//+------------------------------------------------------------------+
//|                                                  url_USD_THB.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict

//#include "include/internetlib.mqh"
//MqlNet iMqlNet;
//#include "include/Wininet.mqh"

#include "include/NewFile.mqh"
sHide iHide;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- create timer
   EventSetTimer(1);
//+------------------------------------------------------------------+
   printf("+------------------------------------------------------------------+");
//printf("THB : "+THB(2));

//printf("THB : "+Url());

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
   iHide.TEST_COPY();
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
string Url()
  {
   string cookie=NULL,headers;
   char post[],result[];
   int res;
//--- to enable access to the server, you should add URL "https://www.google.com/finance" 
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"): 
//string google_url="https://www.google.com/finance";
   string google_url="https://drive.google.com/file/d/1E6zVxtT6_9vSq7ufmilwW-z8I4mSsqAm/view";

//--- Reset the last error code 
   ResetLastError();
//--- Loading a html page from Google Finance 
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection 
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
//--- Checking errors 
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",string(GetLastError())+" ["+string(res)+"]");
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
      // MessageBox("Add the address '"+google_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      //--- Load successfully 
      PrintFormat("The file has been successfully loaded, File size =%d bytes.",ArraySize(result));
      //--- Save the data to a file 
      int filehandle=FileOpen("GoogleFinance.htm",FILE_WRITE|FILE_BIN);
      //--- Checking errors 
      if(filehandle!=INVALID_HANDLE)
        {
         //--- Save the contents of the result[] array to a file 
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- Close the file 
         FileClose(filehandle);
        }
      else Print("Error in FileOpen. Error code=",GetLastError());
     }
   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  THB(int digit)
  {
//+------------------------------------------------------------------+
   string Url="https://themoneyconverter.com/USD/THB.aspx";
   string getOpenURL="thai/url_USD_THB.html";

//iMqlNet.Open(Url,3124);
//iMqlNet.OpenURL(Url,getOpenURL,true);

//+------------------------------------------------------------------+
   string strStart="<td id=\"THB\">",strEnd="</td>";
   int iStart=StringFind(getOpenURL,strStart);
   string THB=StringSubstr(getOpenURL,iStart+StringLen(strStart));
   int iEnd=StringFind(THB,strEnd);
   THB=(iEnd!=0)?StringSubstr(THB,0,iEnd):"";

   string result[];
   int k=StringSplit(THB,StringGetCharacter(".",0),result);

   if(k>=2)
     {
      THB=(digit==0)?
          THB=result[0]:
          THB=result[0]+"."+StringSubstr(result[1],0,digit);
     }
   else
     {
      THB=result[0];
     }
   return string(THB);

  }
//+------------------------------------------------------------------+
