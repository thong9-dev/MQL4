//+------------------------------------------------------------------+
//|                                                Test_DLL_Line.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
#import  "Wininet.dll"
int InternetOpenW(string,int,string,string,int);
int InternetConnectW(int,string,int,string,string,int,int,int);
int InternetOpenUrlW(int,string,string,int,int,int);
int InternetReadFile(int,string,int,int &OneInt[]);
int InternetCloseHandle(int);
int HttpOpenRequestW(int,string,string,string,string,string &AcceptTypes[],int,int);
bool HttpSendRequestW(int,string,int,string,int);
#import
#import "kernel32.dll"
int GetLastError(void);
#import
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//+------------------------------------------------------------------+
   string extoken="G7RrAe1f7G6l4GRRBpnZsC94ymkZJD0qFA0ixvQFyPk";
//----
   string headers="Content-Type: application/x-www-form-urlencoded \r\n";
   headers+="Authorization: Bearer "+extoken+"\r\n";

   string data="message=Test";
   string acceptTypes[1]={"*/*"};

   int HttpOpen=InternetOpenW("HTTP_Client_Sample",1,"","",0);
   printf("HttpOpen:"+HttpOpen);
   
   int HttpConnect=InternetConnectW(HttpOpen,"https://notify-api.line.me/api/notify",7777,"","",3,0,1);
   printf("HttpConnect:"+HttpConnect);

   int HttpRequest=HttpOpenRequestW(HttpConnect,"POST","/notify","HTTP/1.1","",acceptTypes,0,1);
   printf("HttpRequest:"+HttpRequest);

   bool result=HttpSendRequestW(HttpRequest,headers,StringLen(headers),data,StringLen(data));
   printf("Last MSDN Error =: ",kernel32::GetLastError());

   int read[1]; // not used
   Print("This is the POST result: ",result);
   if(HttpOpen>0)
      InternetCloseHandle(HttpOpen);
   if(HttpRequest>0)
      InternetCloseHandle(HttpRequest);
//+------------------------------------------------------------------+

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
