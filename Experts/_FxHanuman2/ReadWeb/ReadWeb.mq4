//+------------------------------------------------------------------+
//|                                                      ReadWeb.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

//string HOST="http://149.28.147.254/_CopyTeade/";
string HOST="http://127.0.0.1/_CopyTeade/";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

string _LOGIN=string(AccountInfoInteger(ACCOUNT_LOGIN));
string _COMPANY=AccountInfoString(ACCOUNT_COMPANY);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   StringReplace(_COMPANY," ","");
//--- create timer
   ExsamplePut();

   string   CCM="";
   CCM+="\n _LOGIN : "+_LOGIN;
   CCM+="\n _COMPANY : "+_COMPANY;

   Comment(CCM);
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
   ExsamplePut();
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
void ExsampleGet()
  {
   string cookie=NULL,headers;
   char post[],result[];
   int res;

   bool GetXML=false;
   string Call="GetXML";

   string URL=HOST+
              "?MQL_Call="+Call+
              "&MQL_LOGIN="+_LOGIN+
              "&MQL_COMPANY="+_COMPANY+
              "&MQL_GetXML="+GetXML;

//--- Reset the last error code 
   ResetLastError();
//--- Loading a html page from Google Finance 
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection 
   res=WebRequest("POST",URL,cookie,NULL,timeout,post,0,result,headers);
//--- Checking errors 
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
      //MessageBox("Add the address '"+google_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      //--- Load successfully 
      //PrintFormat("The file has been successfully loaded, File size =%d bytes.",ArraySize(result));
      //--- Save the data to a file 
      int filehandle=FileOpen("php.xml",FILE_WRITE|FILE_BIN);
      //--- Checking errors 
      if(filehandle!=INVALID_HANDLE)
        {
         string  text=CharArrayToString(result,0,ArraySize(result),CP_ACP);
         printf("text ["+text+"]");

         //--- Save the contents of the result[] array to a file 
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- Close the file 
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error code=",GetLastError());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExsamplePut()
  {
   string cookie=NULL,headers;
   char post[],result[];
   int res;

   bool GetXML=false;
   string Call="PutXML";

//---
   string Tags[9]={"Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};
//string Tags[1]={"","","","","","","","",""};
   string dump[9];
   ArrayResize(dump,ArraySize(Tags),0);

   string DATA="";
   DATA+="<Port>";
//for(int pos=0;pos<OrdersTotal();pos++)
   for(int pos=0;pos<5;pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      //---
      dump[0]=OrderTicket();
      dump[1]=OrderType();
      dump[2]=OrderLots();
      dump[3]=OrderSymbol();
      dump[4]=OrderOpenPrice();
      dump[5]=OrderStopLoss();
      dump[6]=OrderTakeProfit();
      dump[7]=OrderComment();
      dump[8]=OrderMagicNumber();
      //---
      DATA+="<Order>";
      for(int i=0;i<ArraySize(Tags);i++)
        {
         DATA+=sTags(Tags[i])+dump[i]+eTags(Tags[i]);
        }
      DATA+="</Order>";
     }
   DATA+="</Port>";
//---

   string URL=HOST+
              "?MQL_Call="+Call+
              "&MQL_LOGIN="+_LOGIN+
              "&MQL_COMPANY="+_COMPANY+
              "&MQL_GetXML="+GetXML+
              "&DATA="+DATA;
//--- Reset the last error code 
   ResetLastError();
//--- Loading a html page from Google Finance 
   int timeout=5000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection 
   res=WebRequest("GET",URL,cookie,NULL,timeout,post,0,result,headers);
//--- Checking errors 
   if(res==-1)
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address 
      //MessageBox("Add the address '"+google_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      //--- Load successfully 
      //PrintFormat("The file has been successfully loaded, File size =%d bytes.",ArraySize(result));
      //--- Save the data to a file 
      int filehandle=FileOpen("PutPhp.xml",FILE_WRITE|FILE_BIN);
      //--- Checking errors 
      if(filehandle!=INVALID_HANDLE)
        {
         string  text=CharArrayToString(result,0,ArraySize(result),CP_ACP);
         printf("text ["+text+"]");

         //--- Save the contents of the result[] array to a file 
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- Close the file 
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error code=",GetLastError());
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string sTags(string v)
  {
   return "<"+v+">";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string eTags(string v)
  {
   return "</"+v+">";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void xmlRead(string FileName)
  {

//---
   ResetLastError();
   int FileHandle=FileOpen(FileName,FILE_BIN|FILE_READ);

   printf("FileName ["+FileName+"]");
   printf("FileHandle ["+FileHandle+"]");

   string text;
   if(FileHandle!=INVALID_HANDLE)
     {
      //--- receive the file size 
      ulong size=FileSize(FileHandle);
      //--- read data from the file
      //while(!FileIsEnding(FileHandle))
      text=FileReadString(FileHandle,(int)size);
      printf(text);
      //--- close
      FileClose(FileHandle);
      //printf("xmlRead: "+sData);
      //printf("xmlRead: "+SerialNumber_Decode(PrivateKey,sData));
     }
//--- check for errors   
//else PrintFormat(INAME+": failed to open %s file, Error code = %d",FileName,GetLastError());
//---
  }
//+------------------------------------------------------------------+
