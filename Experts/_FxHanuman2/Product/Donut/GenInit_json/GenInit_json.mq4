//+------------------------------------------------------------------+
//|                                                 GenInit_json.mq4 |
//|                                 Copyright 2019,Golden Master TH. |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
string path_Name="";
string file_Name=string(AccountInfoInteger(ACCOUNT_LOGIN))+".json";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   if(_File_Handle(__LINE__,"Find")==-1)
     {
      _File_Write(JSON_Format());
      
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
int _File_Handle(int FromLine,string mode)
  {
   int hand=-2,r=-1;
   int err=GetLastError();
   ulong _FileSize=-1;
//---
   string path=path_Name+file_Name;
//---
   if(mode=="Find")
     {
      ResetLastError();
      hand=FileOpen(path,FILE_READ,',');
      err=GetLastError();
      _FileSize=FileSize(hand);
      //PrintFormat(string(__LINE__)+_FileSize);
      FileClose(hand);
      r=hand;
     }
//---
   if(mode=="Write")
     {
      ResetLastError();
      hand=FileOpen(path,FILE_READ|FILE_WRITE,',');
      err=GetLastError();
      _FileSize=FileSize(hand);
      r=hand;
     }
//---
   printf(string(__LINE__)+"Mode: "+mode+","+string(FromLine)+" file: \""+file_Name+"\"");
   printf(string(__LINE__)+"Hand: ["+string(hand)+","+_File_HandleErr(err)+"] [Retrun:**"+string(r)+"**Z:"+string(_FileSize)+"]");
   return r;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _File_HandleErr(int code)
  {
   string v="";
   switch(code)
     {
      case  5002:
         v="Wrong file name";
         break;
      case  5004:
         v="Cannot open file";
         break;
      case  5008:
         v=".csv open now";
         break;
      default:
         break;
     }
   return "["+string(code)+" "+v+"]";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _File_Write(string text)
  {
   PrintFormat(string(__LINE__)+"# ------------------------------ _File_Write");
   ResetLastError();
   int file_handle=_File_Handle(__LINE__,"Write");

   if(file_handle!=INVALID_HANDLE)
     {
      //FileWrite(file_handle,text);

      FileWriteString(file_handle,text+"s");

      FileClose(file_handle);

      PrintFormat(string(__LINE__)+"# Data is written, file is closed, Error code = %d",GetLastError());
     }
   else
     {
      PrintFormat(string(__LINE__)+"# Failed to open file, Error code = %d",GetLastError());
     }
   PrintFormat(string(__LINE__)+"# ------------------------------");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string JSON_Format()
  {
   string s="";
   s+="{\n";
   s+="\"serialNumber\": {\n";
   s+="        \"COPY_TRADE\": \"xxx\",\n";
   s+="        \"REBALANCE\": \"xxx\"\n";
   s+="    },\n";
   s+="    \"input\": {\n";
   s+="        \"lineToken\": \"xxx\"\n";
   s+="    },\n";
   s+="    \"username\": \"xxxx\",\n";
   s+="    \"password\": \"xxxx\",\n";
   s+="    \"l3Metric\": {\n";
   s+="        \"a1\": \"9999\",\n";
   s+="        \"a2\": \"9999\",\n";
   s+="        \"a3\": \"9999\",\n";
   s+="        \"a4\": \"9999\",\n";
   s+="        \"a5\": \"9999\",\n";
   s+="        \"a6\": \"9999\",\n";
   s+="        \"a7\": \"9999\",\n";
   s+="        \"a8\": \"9999\",\n";
   s+="        \"a9\": \"9999\",\n";
   s+="        \"a10\": \"9999\",\n";
   s+="        \"b1\": \"9999\",\n";
   s+="        \"b2\": \"9999\",\n";
   s+="        \"b3\": \"9999\",\n";
   s+="        \"b4\": \"9999\",\n";
   s+="        \"b5\": \"9999\",\n";
   s+="        \"b6\": \"9999\",\n";
   s+="        \"b7\": \"9999\",\n";
   s+="        \"b8\": \"9999\",\n";
   s+="        \"b9\": \"9999\",\n";
   s+="        \"b10\": \"9999\",\n";
   s+="        \"c1\": \"9999\",\n";
   s+="        \"c2\": \"9999\",\n";
   s+="        \"c3\": \"9999\",\n";
   s+="        \"c4\": \"9999\",\n";
   s+="        \"c5\": \"9999\",\n";
   s+="        \"c6\": \"9999\",\n";
   s+="        \"c7\": \"9999\",\n";
   s+="        \"c8\": \"9999\",\n";
   s+="        \"c9\": \"9999\",\n";
   s+="        \"c10\": \"9999\",\n";
   s+="        \"d1\": \"9999\",\n";
   s+="        \"d2\": \"9999\",\n";
   s+="        \"d3\": \"9999\",\n";
   s+="        \"d4\": \"9999\",\n";
   s+="        \"d5\": \"9999\",\n";
   s+="        \"d6\": \"9999\",\n";
   s+="        \"d7\": \"9999\",\n";
   s+="        \"d8\": \"9999\",\n";
   s+="        \"d9\": \"9999\",\n";
   s+="        \"d10\": \"9999\",\n";
   s+="        \"e1\": \"9999\",\n";
   s+="        \"e2\": \"9999\",\n";
   s+="        \"e3\": \"9999\",\n";
   s+="        \"e4\": \"9999\",\n";
   s+="        \"e5\": \"9999\",\n";
   s+="        \"e6\": \"9999\",\n";
   s+="        \"e7\": \"9999\",\n";
   s+="        \"e8\": \"9999\",\n";
   s+="        \"e9\": \"9999\",\n";
   s+="        \"e10\": \"9999\",\n";
   s+="        \"f1\": \"9999\",\n";
   s+="        \"f2\": \"9999\",\n";
   s+="        \"f3\": \"9999\",\n";
   s+="        \"f4\": \"9999\",\n";
   s+="        \"f5\": \"9999\",\n";
   s+="        \"f6\": \"9999\",\n";
   s+="        \"f7\": \"9999\",\n";
   s+="        \"f8\": \"9999\",\n";
   s+="        \"f9\": \"9999\",\n";
   s+="        \"f10\": \"9999\",\n";
   s+="        \"g1\": \"9999\",\n";
   s+="        \"g2\": \"9999\",\n";
   s+="        \"g3\": \"9999\",\n";
   s+="        \"g4\": \"9999\",\n";
   s+="        \"g5\": \"9999\",\n";
   s+="        \"g6\": \"9999\",\n";
   s+="        \"g7\": \"9999\",\n";
   s+="        \"g8\": \"9999\",\n";
   s+="        \"g9\": \"9999\",\n";
   s+="        \"g10\": \"9999\",\n";
   s+="        \"h1\": \"9999\",\n";
   s+="        \"h2\": \"9999\",\n";
   s+="        \"h3\": \"9999\",\n";
   s+="        \"h4\": \"9999\",\n";
   s+="        \"h5\": \"9999\",\n";
   s+="        \"h6\": \"9999\",\n";
   s+="        \"h7\": \"9999\",\n";
   s+="        \"h8\": \"9999\",\n";
   s+="        \"h9\": \"9999\",\n";
   s+="        \"h10\": \"9999\",\n";
   s+="        \"i1\": \"9999\",\n";
   s+="        \"i2\": \"9999\",\n";
   s+="        \"i3\": \"9999\",\n";
   s+="        \"i4\": \"9999\",\n";
   s+="        \"i5\": \"9999\",\n";
   s+="        \"i6\": \"9999\",\n";
   s+="        \"i7\": \"9999\",\n";
   s+="        \"i8\": \"9999\",\n";
   s+="        \"i9\": \"9999\",\n";
   s+="        \"i10\": \"9999\",\n";
   s+="        \"j1\": \"9999\",\n";
   s+="        \"j2\": \"9999\",\n";
   s+="        \"j3\": \"9999\",\n";
   s+="        \"j4\": \"9999\",\n";
   s+="        \"j5\": \"9999\",\n";
   s+="        \"j6\": \"9999\",\n";
   s+="        \"j7\": \"9999\",\n";
   s+="        \"j8\": \"9999\",\n";
   s+="        \"j9\": \"9999\",\n";
   s+="        \"j10\": \"9999\"\n";
   s+="    },\n";
   s+="    \"from\": 123456789,\n";
   s+="    \"toIBAN\": \"CH000781000093400000\",\n";
   s+="    \"toName\": \"Abcd Cdef\",\n";
   s+="    \"amount\": \"%s\"\n";
   s+="}\n";
   return s;
  }
//+------------------------------------------------------------------+
