//+------------------------------------------------------------------+
//|                                                     TestHTTP.mq4 |
//|                                                          T-foREX |
//|                                               http://jobaweb.net |
//+------------------------------------------------------------------+

#property copyright "T-foREX"
#property link      "http://jobaweb.net"

#import  "Wininet.dll"
   int InternetOpenA(string, int, string, string, int);
   int InternetConnectA(int, string, int, string, string, int, int, int); 
   int HttpOpenRequestA(int, string, string, int, string, int, string, int); 
   int InternetOpenUrlA(int, string, string, int, int, int);
   int InternetReadFile(int, string, int, int& OneInt[]);
   int InternetCloseHandle(int); 
   int InternetCloseHandle(int); 
   int InternetCloseHandle(int); 
#import

int init()
{
   //----
   int HttpOpen = InternetOpenA("HTTP_Client_Sample", 0, "", "", 0); 
   int HttpConnect = InternetConnectA(HttpOpen, "", 80, "", "", 3, 0, 1); 
   int HttpRequest = InternetOpenUrlA(HttpOpen, "http://mql4.com", NULL, 0, 0, 0);
   
   int read[1];
   string Buffer = "          ";
   string page = "";

   while (true)
   {
      InternetReadFile(HttpRequest, Buffer, StringLen(Buffer), read);
      if (read[0] > 0) page = page + StringSubstr(Buffer, 0, read[0]);
      else             break;
   }
   
   MessageBox(page, "HTTP READ:", 0x00000030);
   
   if (HttpRequest > 0) InternetCloseHandle(HttpRequest); 
   if (HttpConnect > 0) InternetCloseHandle(HttpConnect); 
   if (HttpOpen > 0) InternetCloseHandle(HttpOpen); 

   //----
   return(0);
}

int start()
{
   //----

   //----
   return(0);
}

//+------------------------------------------------------------------+