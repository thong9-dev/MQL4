//+------------------------------------------------------------------+
//|                                                  HTTP POST 1.mq4 |
//|                                  Copyright © 2011, Ronald Raygun |
//|                         http://www.RonaldRaygunForex.com/Support |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Ronald Raygun"
#property link      "http://www.RonaldRaygunForex.com/Support"

#import "wininet.dll"
int InternetOpenA(
                  string lpszAgent,
                  int dwAccessType,
                  string lpszProxyName,
                  string lpszProxyBypass,
                  int dwFlags

                  );

int InternetConnectA(
                     int hInternet,
                     string lpszServerName,
                     int nServerPort,
                     string lpszUsername,
                     string lpszPassword,
                     int dwService,
                     int dwFlags,
                     int dwContext
                     );

int HttpOpenRequestA(
                     int hConnect,
                     string lpszVerb,
                     string lpszObjectName,
                     string lpszVersion,
                     string lpszReferer,
                     string lplpszAcceptTypes,
                     int dwFlags,
                     int dwContext
                     );

bool HttpSendRequestA(
                      int hRequest,
                      string lpszHeaders,
                      int dwHeadersLength,
                      int lpOptional,
                      int dwOptionalLength
                      );

bool InternetReadFile(
                      int hFile,
                      string lpBuffer,
                      int dwNumberOfBytesToRead,
                      int &lpdwNumberOfBytesRead[]
                      );

bool InternetCloseHandle(
                         int hInternet
                         );

#import

//#include <stdfunctions.mqh>
/*
InternetOpen 
 
dwAccessType
INTERNET_OPEN_TYPE_DIRECT
INTERNET_OPEN_TYPE_PRECONFIG
INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY
INTERNET_OPEN_TYPE_PROXY
 
dwFlags
INTERNET_FLAG_ASYNC
INTERNET_FLAG_FROM_CACHE
INTERNET_FLAG_OFFLINE
 
*/

//InternetConnect - nServerPort
#define INTERNET_DEFAULT_FTP_PORT      21
#define INTERNET_DEFAULT_GOPHER_PORT   70
#define INTERNET_DEFAULT_HTTP_PORT     80
#define INTERNET_DEFAULT_HTTPS_PORT    443
#define INTERNET_DEFAULT_SOCKS_PORT    1080
#define INTERNET_INVALID_PORT_NUMBER   0

//InternetConnect - dwService
#define INTERNET_SERVICE_FTP     1
#define INTERNET_SERVICE_GOPHER  2
#define INTERNET_SERVICE_HTTP    3

//HttpOpenRequest - dwFlags
/*#define INTERNET_FLAG_CACHE_IF_NET_FAIL
#define INTERNET_FLAG_HYPERLINK
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS
#define INTERNET_FLAG_KEEP_CONNECTION
#define INTERNET_FLAG_NEED_FILE
#define INTERNET_FLAG_NO_AUTH
#define INTERNET_FLAG_NO_AUTO_REDIRECT*/
#define INTERNET_FLAG_NO_CACHE_WRITE            0x04000000
/*#define INTERNET_FLAG_NO_COOKIES
#define INTERNET_FLAG_NO_UI*/
#define INTERNET_FLAG_PRAGMA_NOCACHE            0x00000100
#define INTERNET_FLAG_RELOAD                    0x80000000
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*#define INTERNET_FLAG_RESYNCHRONIZE
#define INTERNET_FLAG_SECURE*/

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----

   string URL="http://www.ronaldraygunforex.com/cloud/test.php";
   string POSTFields="Input=test";

   string ServerResponse=LoadURL(URL,POSTFields);
//string ServerResponse = wget(URL);
   int SRLength=StringLen(ServerResponse);

   int Handle=FileOpen(WindowExpertName(),FILE_CSV|FILE_WRITE,';');
   if(Handle>0)
     {
      FileWrite(Handle,ServerResponse);
      FileFlush(Handle);
      FileClose(Handle);
     }

   if(StringLen(ServerResponse)>200)
     {
      //Start with the last block of 100 characters and insert \n inbetween each.
      for(int SR=StringLen(ServerResponse)-200; SR>=0; SR=SR-200)
        {
         string StringA = StringSubstr(ServerResponse, 0, SR);
         string StringB = StringSubstr(ServerResponse, SR, StringLen(ServerResponse) - SR);

         ServerResponse=StringConcatenate(StringA,"\n",StringB);
        }
     }

   Print("ServerResponse: ",ServerResponse);

   Comment(SRLength,"|",StringLen(ServerResponse)," "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+" URL: ",URL,"\n",
           "ServerResponse: ",ServerResponse);

//----
   return(0);
  }
//+------------------------------------------------------------------+

string LoadURL(string URLUsed,string PostFields)
  {
   string lsReadBuffer="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";//128

   string lsServer=fsGetServer(URLUsed);
   string lsPath=fsGetPath(URLUsed);

   PostFields=UrlEncode(PostFields);

   int hInternetOpen=InternetOpenA("mql4",1,"","",0);
   int liInternetConnectHandle=InternetConnectA(hInternetOpen,lsServer,INTERNET_DEFAULT_HTTP_PORT,"","",INTERNET_SERVICE_HTTP,0,0);
   int liInternetFileHandle=HttpOpenRequestA(liInternetConnectHandle,"POST",lsPath,"","",0,INTERNET_FLAG_NO_CACHE_WRITE|INTERNET_FLAG_PRAGMA_NOCACHE|INTERNET_FLAG_RELOAD,0);

   bool lbRetVal=fbHttpSendRequest(liInternetFileHandle,PostFields);

   string mContent="";
   int lpdwNumberOfBytesRead[1];
   string sResult;

   while(InternetReadFile(liInternetFileHandle,lsReadBuffer,255,lpdwNumberOfBytesRead)!=FALSE)
     {
      if(lpdwNumberOfBytesRead[0]==0) break;
      sResult=StringConcatenate(sResult,StringSubstr(lsReadBuffer,0,lpdwNumberOfBytesRead[0]));
     }
   bool bRes=InternetCloseHandle(hInternetOpen);
   return(sResult);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool fbHttpSendRequest(int piInternetFileHandle,string psPostParameters)
  {
   return(HttpSendRequestA(piInternetFileHandle,"",0,psPostParameters,StringLen(psPostParameters)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fsGetServer(string psURL)
  {
   int liServerStart=StringFind(psURL,"//",0)+2;
   return( StringSubstr(psURL,liServerStart,StringFind(psURL,"/",liServerStart)-liServerStart));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fsGetPath(string psURL)
  {
   return(StringSubstr(psURL,StringFind(psURL,"/",StringFind(psURL,"//",0)+2)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string UrlEncode(string URLLoad)
  {
   int Position=StringFind(URLLoad," ");
   while(Position!=-1)
     {
      string InitialURLA = StringTrimLeft(StringTrimRight(StringSubstr(URLLoad, 0, StringFind(URLLoad, " ", 0))));
      string InitialURLB = StringTrimLeft(StringTrimRight(StringSubstr(URLLoad, StringFind(URLLoad, " ", 0))));
      URLLoad=InitialURLA+"%20"+InitialURLB;
      Position=StringFind(URLLoad," ");
     }
   return (URLLoad);
  }
//+------------------------------------------------------------------+
