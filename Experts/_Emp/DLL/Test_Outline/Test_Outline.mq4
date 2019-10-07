//+------------------------------------------------------------------+
//|                                                 Test_Outline.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict

//--- to download the xml
#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import
//---
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import


string InpLogin="Lapukdee";             //Your MQL5.com account 
string InpPassword="Wdasqwe123";             //Your account password 
string InpFileName="EURUSDM5.png"; //An image in folder MQL5/Files/ 
string InpFileType="image/png";    //Correct mime type of the image
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
//--- Post a message on mql5.com, including an image, the path to which is taken from the InpFileName parameter 
   if(false)
     {
      PostToNewsFeed(InpLogin,InpPassword,"Checking the expanded version of WebRequest\r\n"
                     "(This message has been posted by the WebRequest.mq5 script)",InpFileName,InpFileType);
     }

/*string str="Set-Cookie: auth=1234567890";
   int res=StringFind(str,"Set-Cookie: auth=");
   printf(res);
   StringSubstr(str,res+12);
   string auth;
   auth=StringSubstr(str,res+12);
   auth="Cookie: "+StringSubstr(auth,0,StringFind(auth,";")+1)+"\r\n";
   printf(auth);*/

//Test2();

//GG();
//xmlDownload();

   CMD();
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
   CMD();
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
//| Posting a message with an image on the wall at mql5.com          | 
//+------------------------------------------------------------------+ 
bool PostToNewsFeed(string login,string password,string text,string filename,string filetype)
  {
   int    res;     // To receive the operation execution result 
   char   data[];  // Data array to send POST requests 
   char   file[];  // Read the image here 
                   //string str="login_user="+login+"&login_pass="+password;
   string str="Login=Lapukdee"+
              "&Password=Wdasqwe123";
   str+="&RedirectAfterLoginUrl=https://www.mql5.com/en";
//str+="&RegistrationUrl=";
   str+="&ShowOpenId=True";
   str+="&ViewType=0";
   string auth;
   string sep="-------Jyecslin9mp8RdKV"; // multipart data separator 
   sep="";
//--- A file is available, try to read it 
   if(filename!=NULL && filename!="")
     {
      res=FileOpen(filename,FILE_READ|FILE_BIN);
      if(res<0)
        {
         Print("Error opening the file \""+filename+"\"");
         return(false);
        }
      //--- Read file data 
      if(FileReadArray(res,file)!=FileSize(res))
        {
         FileClose(res);
         Print("Error reading the file \""+filename+"\"");
         return(false);
        }
      //--- 
      FileClose(res);
     }
//--- Create the body of the POST request for authorization 
   ArrayResize(data,StringToCharArray(str,data,0,WHOLE_ARRAY,CP_UTF8)-1);
//--- Resetting error code 
   ResetLastError();
//--- Authorization request 
//str="Login="+login+"&Password="+password;
//res=WebRequest("POST","https://my.xm.com/th/member/login",NULL,0,data,data,str);
   res=WebRequest("POST","https://www.mql5.com/en/auth_login",NULL,0,data,data,str);
//--- If authorization failed 
   if(res!=200)
     {
      Print(__LINE__+" Authorization error #"+(string)res+", LastError="+(string)GetLastError());
      //return(false);
     }
//--- Read the authorization cookie from the server response header 
   res=StringFind(str,"Set-Cookie: auth=");
//--- If cookie not found, return an error 
   if(res<0)
     {
      Print(__LINE__+" Error, authorization data not found in the server response (check login/password)");
      //return(false);
     }
//--- Remember the authorization data and form the header for further requests 
   auth=StringSubstr(str,res+12);
   auth="Cookie: "+StringSubstr(auth,0,StringFind(auth,";")+1)+"\r\n";
//--- If there is a data file, send it to the server 
   if(ArraySize(file)!=0)
     {
      //--- Form the request body 
      str="--"+sep+"\r\n";
      str+="Content-Disposition: form-data; name=\"attachedFile_imagesLoader\"; filename=\""+filename+"\"\r\n";
      str+="Content-Type: "+filetype+"\r\n\r\n";
      res =StringToCharArray(str,data);
      res+=ArrayCopy(data,file,res-1,0);
      res+=StringToCharArray("\r\n--"+sep+"--\r\n",data,res-1);
      ArrayResize(data,ArraySize(data)-1);
      //--- Form the request header 
      str=auth+"Content-Type: multipart/form-data; boundary="+sep+"\r\n";
      //--- Reset error code 
      ResetLastError();
      //--- Request to send an image file to the server 
      res=WebRequest("POST","https://www.mql5.com/upload_file",str,0,data,data,str);
      //--- check the request result 
      if(res!=200)
        {
         Print(__LINE__+" Error sending a file to the server #"+(string)res+", LastError="+(string)GetLastError());
         //return(false);
        }
      //--- Receive a link to the image uploaded to the server 
      str=CharArrayToString(data);
      if(StringFind(str,"{\"Url\":\"")==0)
        {
         res     =StringFind(str,"\"",8);
         filename=StringSubstr(str,8,res-8);
         //--- If file uploading fails, an empty link will be returned 
         if(filename=="")
           {
            Print("File sending to server failed");
            return(false);
           }
        }
     }

//--- Create the body of a request to post an image on the server 
   str ="--"+sep+"\r\n";
   str+="Content-Disposition: form-data; name=\"content\"\r\n\r\n";
   str+=text+"\r\n";
//--- The languages in which the post will be available on mql5.com  
   str+="--"+sep+"\r\n";
   str+="Content-Disposition: form-data; name=\"AllLanguages\"\r\n\r\n";
   str+="on\r\n";
//--- If the picture has been uploaded on the server, pass its link 
   if(ArraySize(file)!=0)
     {
      str+="--"+sep+"\r\n";
      str+="Content-Disposition: form-data; name=\"attachedImage_0\"\r\n\r\n";
      str+=filename+"\r\n";
     }
//--- The final string of the multipart request 
   str+="--"+sep+"--\r\n";
//--- Out the body of the POST request together in one string 
   StringToCharArray(str,data,0,WHOLE_ARRAY,CP_UTF8);
   ArrayResize(data,ArraySize(data)-1);
//--- Prepare the request header   
   str=auth+"Content-Type: multipart/form-data; boundary="+sep+"\r\n";
//--- Request to post a message on the user wall at mql5.com 
   res=WebRequest("POST","https://www.mql5.com/ru/users/"+login+"/wall",str,0,data,data,str);
//--- Return true for successful execution 
   return(res==200);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Authorization()
  {
//if(IsTesting())return(true);
   string   Login="Lapukdee";                //Your account
   string   Password="Wdasqwe123";           //Your account password
   int    res;     // To receive the operation execution result
   char   data[];  // Data array to send POST requests

                   //string authurl="https://www.mql5.com/en/auth_login";
//string str="Login="+Login+"&Password="+Password;

   string authurl="https://my.xm.com/th/member/login:8080/";
   string str="login_user="+Login+"&login_pass="+Password;

   ArrayResize(data,StringToCharArray(str,data,0,WHOLE_ARRAY,CP_UTF8)-1);
   ResetLastError();
   res=WebRequest("POST",authurl,NULL,0,data,data,str);
   if(GetLastError()==4060)
     {
      Alert("You have not added ",authurl," to URL permition list in the ( Tools > Options > Expert Advisors tab )");
     }
   if(res!=200)
     {
      Print("Authorization failed!, LastError="+(string)res);
      return(false);
     }
   Print(string(__LINE__)+"# "+res);
   Alert(string(__LINE__)+"# "+str);

   res=StringFind(str,"Set-Cookie: auth=");
   if(res<0)
     {
      Alert(string(__LINE__)+"# Login/Password failed!");
      return(false);
     }
   else Print(string(__LINE__)+"# Authorized");

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Test2()
  {

   printf("-----------------------------------");
   string headers;
   char post[],result[];

   int res=WebRequest("GET","https://my.xm.com/th/member/auth","",NULL,10000,post,0,result,headers);
   Print("Status code:",res,", error:",GetLastError());
   Print("Server response: ",CharArrayToString(result));

//
   int filehandle=FileOpen("auth/XM- Element.htm",FILE_WRITE|FILE_BIN);
   if(filehandle!=INVALID_HANDLE)
     {
      FileWriteArray(filehandle,result,0,ArraySize(result));
      FileClose(filehandle);
     }
   else
     {
      Print("Error in FileOpen. Error code=",GetLastError());
     }
//
   string str=CharArrayToString(result,0,0,CP_ACP);
//
   string ts,et,ga_client_id,gclid;

   res=StringFind(str,"name=\"ts\" value=\"");
   ts=StringSubstr(str,res+17);
   int El_0=StringFind(ts,"\"");
   ts=(El_0!=0)?StringSubstr(ts,0,El_0):"";
   printf(res);

   res=StringFind(str,"name=\"et\" value=\"");
   et=StringSubstr(str,res+17);
   El_0=StringFind(et,"\"");
   et=(El_0!=0)?StringSubstr(et,0,El_0):"";

   res=StringFind(str,"name=\"ga_client_id\" value=\"");
   ga_client_id=StringSubstr(str,res+27);
   El_0=StringFind(ga_client_id,"\"");
   ga_client_id=(El_0!=0)?StringSubstr(ga_client_id,0,El_0):"";

   res=StringFind(str,"name=\"gclid\" value=\"");
   gclid=StringSubstr(str,res+20);
   El_0=StringFind(gclid,"\"");
   gclid=(El_0!=0)?StringSubstr(gclid,0,El_0):"";

   printf("ts : ["+ts+"]");
   printf("et : ["+et+"]");
   printf("ga_client_id : ["+ga_client_id+"]");
   printf("gclid : ["+gclid+"]");
//---
   if(false)
     {
      string headers2;
      char post2[],result2[];
      string DUMP2="";

      ts="1549223694";
      et="54748699e5d294a24463ae36c03f9b699366d87e";

      DUMP2="login_user=32153992&login_pass=Wdasqwe123";
      DUMP2+="&ts="+ts;
      DUMP2+="&et="+et;
      DUMP2+="&ga_client_id=7459540.1542920827";
      DUMP2+="&gclid="+gclid;
      StringToCharArray(DUMP2,post2);

      // Must specify string length; otherwise array has terminating null character in it
      int res2=WebRequest("POST","https://my.xm.com/th/member/auth","",NULL,10000,post2,ArraySize(post2),result2,headers2);

      Print("Status code:",res2,", error:",GetLastError());
      Print("Server response:",CharArrayToString(result2));

      res2=StringFind(headers2,"Set-Cookie: bm_mi=");
      if(res2<0)
        {
         Alert(string(__LINE__)+"# Login/Password failed!");
         //return(false);
        }
      else
        {
         Print(string(__LINE__)+"# Authorized");
        }

      _FILE_TXT("XM headers",headers2);
      Print("headers :",headers2);
      //--- Remember the authorization data and form the header for further requests 
      string auth;
      auth=StringSubstr(headers2,res2+12);
      auth="Cookie: "+StringSubstr(auth,0,StringFind(auth,";")+1)+"\r\n";
      Print(auth);

      _FILE_TXT("XM auth",headers2+"\n****\n"+auth);

      //---
      int filehandle2=FileOpen("XM - Dashboard.htm",FILE_WRITE|FILE_BIN);
      if(filehandle2!=INVALID_HANDLE)
        {
         FileWriteArray(filehandle2,result2,0,ArraySize(result2));
         FileClose(filehandle2);
        }
      else
        {
         Print("Error in FileOpen. Error code=",GetLastError());
        }
      //---
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _FILE_TXT(string FileName,string write)
  {
   int file_handle=FileOpen(FileName,FILE_WRITE|FILE_TXT|FILE_ANSI);
   FileWriteString(file_handle,write);
   FileClose(file_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GG()
  {
//https://drive.google.com/open?id=1Q5WDVUeXZShrggCl_MzOMXK10e3qDIz9

/*Headers="Host: drive.google.com\r\n";
   Headers+="Referer: https://drive.google.com/\r\n";*/

/* Content="id=1Q5WDVUeXZShrggCl_MzOMXK10e3qDIz9";
   Content+="&foreignService=texmex";
   Content+="&gaiaService=wise";
   Content+="&shareService=texmex";
   Content+="&subapp=10";
   Content+="&popupWindowsEnabled=true";
   Content+="&shareUiType=default";
   Content+="&hl=th&authuser=0";
   Content+="&rand=1549542872052";*/

//int size=StringToCharArray(Content,post,0,WHOLE_ARRAY,CP_UTF8)-1;
//ArrayResize(post,size);
//int res=WebRequest("GET","https://my.xm.com/th/member/auth","",NULL,10000,post,0,result,headers);
   string Headers,Content,cookie=NULL;
   char post[],result[];
   int res=WebRequest("GET","https://drive.google.com/uc?authuser=0&id=1Q5WDVUeXZShrggCl_MzOMXK10e3qDIz9&export=download"
                      ,"",cookie,10000,post,0,result,Headers);
   Print("Status code:",res,", error:",GetLastError());
   Print("Server response: ",CharArrayToString(result));

//
   Print(Headers);

   int filehandle=FileOpen("GG/Get.htm",FILE_WRITE|FILE_BIN);
   if(filehandle!=INVALID_HANDLE)
     {
      FileWriteArray(filehandle,result,0,ArraySize(result));
      FileClose(filehandle);
     }
   else
     {
      Print("Error in FileOpen. Error code=",GetLastError());
     }
  }
string INAME="OuntLine";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void xmlDownload()
  {
   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);

   string filename=terminal_data_path+"\\MQL4\\Files\\"+"fractals.PNG";
   int filehandle=FileOpen("OuntLine.PNG",1|2);

   printf(filename);
   printf(filehandle);

   string Post=SerialNumber_Generate("Write form mql4");
   string Dec=SerialNumber_Decode(PrivateKey,Post);
   printf("Dec : "+Dec);
   FileWriteString(filehandle,Post);
   FileClose(filehandle);

//---
   ResetLastError();

   string sUrl="https://drive.google.com/uc?authuser=0&id=13_VICzwAlIgD5TQ7EP1bnnDnAbisHYti&export=download";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\","GetGG");
//string PP=TerminalInfoString(TERMINAL_DATA_PATH);
//printf(PP);
/* string sep="/",result[];
   ushort  u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(PP,u_sep,result);*/
//         
//string FilePath=StringConcatenate(PP,"\\",xmlFileName);

//int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);

   xmlRead("GetGG");
/*if(FileGet==0)
      PrintFormat(INAME+": %s file downloaded successfully!",FilePath);
//--- check for errors   
   else
      PrintFormat(INAME+": failed to download %s file, Error code = %d",FilePath,GetLastError());*/
//---
//xmlRead();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string sData;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void xmlRead(string FileName)
  {
//---
   ResetLastError();
   int FileHandle=FileOpen(FileName,FILE_BIN|FILE_READ);

   if(FileHandle!=INVALID_HANDLE)
     {
      //--- receive the file size 
      ulong size=FileSize(FileHandle);
      //--- read data from the file
      while(!FileIsEnding(FileHandle))
         sData=FileReadString(FileHandle,(int)size);
      //--- close
      FileClose(FileHandle);

      printf("xmlRead: "+sData);
      printf("xmlRead: "+SerialNumber_Decode(PrivateKey,sData));
     }
//--- check for errors   
   else PrintFormat(INAME+": failed to open %s file, Error code = %d",FileName,GetLastError());
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PrivateKey="PrivateKey";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SerialNumber_Generate(string  client)
  {
   _printf(__FUNCTION__,__LINE__,"-----------------------------------------");
   _printf(__FUNCTION__,__LINE__,"Get: ["+client+"] "+string(StringLen(client)));
   uchar dst[],src[],arrKey[];

   StringToCharArray(PrivateKey,arrKey);

   StringToCharArray(client,src);
   CryptEncode(CRYPT_DES,src,arrKey,dst);

   ArrayInitialize(arrKey,0x00);
   CryptEncode(CRYPT_BASE64,dst,arrKey,src);

   string var=CharArrayToString(src);

   _printf(__FUNCTION__,__LINE__,"Set: ["+var+"] "+string(StringLen(var)));
   return var;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _printf(string fun,int line,string var)
  {
   printf(fun+"["+string(line)+"]# "+var);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SerialNumber_Decode(string _Key,string client)
  {
   uchar arrKey[],arr1[],arr2[];

   StringToCharArray(_Key,arrKey);

   StringToCharArray(client,arr1,0,StringLen(client),0);
//_printf(__FUNCTION__,__LINE__,"_ Get: ["+CharArrayToString(arr1)+"] "+string(ArraySize(arr1)));

   CryptDecode(CRYPT_BASE64,arr1,arrKey,arr2);
   CryptDecode(CRYPT_DES,arr2,arrKey,arr1);

//_printf(__FUNCTION__,__LINE__,"_ Decode: ["+CharArrayToString(arr1)+"] "+string(ArraySize(arr1)));

   return CharArrayToString(arr1);
  }
//+------------------------------------------------------------------+
void CMD()
  {

   string Name_file=AccountInfoInteger(ACCOUNT_LOGIN)+"_"+AccountInfoString(ACCOUNT_COMPANY)+".xml";

   int  s=StringReplace(Name_file," ","_");

   string src_path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\";

   string dst_path="D:\\Google_Drive\\ForexSaver\\";
   string dst_dir=dst_path+Name_file;

   printf("dst_dir: "+dst_dir);

   int file_hndl=FileOpen(Name_file,FILE_WRITE);
   printf(file_hndl);
//+------------------------------------------------------------------+

  // FileWrite(file_hndl,"<?xml version=\"1.0\" encoding=\"windows-1252\"?>");
   FileWrite(file_hndl,"<Port>");
   if(file_hndl!=INVALID_HANDLE)
     {
      string Tags[1]={"Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};
      string dump[1];
      ArrayResize(dump,ArraySize(Tags),0);

      for(int pos=0;pos<OrdersTotal();pos++)
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
         FileWrite(file_hndl,"<Order>");
         for(int i=0;i<ArraySize(Tags);i++)
           {
            FileWrite(file_hndl,"\t"+sTags(Tags[i])+dump[i]+eTags(Tags[i]));
           }
         FileWrite(file_hndl,"</Order>");
        }
     }
   FileWrite(file_hndl,"</Port>");

//+------------------------------------------------------------------+

   FileClose(file_hndl);

   int r=ShellExecuteW(NULL,"open","cmd","/c copy /Y "+src_path+Name_file+" "+dst_dir,NULL,NULL);
   printf(r);
  }
//+------------------------------------------------------------------+
string sTags(string v)
  {
   return "<"+v+">";
  }
//+------------------------------------------------------------------+
string eTags(string v)
  {
   return "</"+v+">";
  }
//+------------------------------------------------------------------+
