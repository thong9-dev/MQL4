//+------------------------------------------------------------------+
//|                                         Test_Outline_receive.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict

#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import
string INAME="Test_Outline_receive";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);

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
string Order[200][9];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string ID="1Q6SdyU2QsBb1ERT4jv9xJAFqe_VtlkCt";
   string sUrl="https://drive.google.com/uc?authuser=0&id="+ID+"&export=download";
   string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\","GetGG");
   int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);

   xmlRead("GetGG");
//---
   string Tags[9]={"Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};

   int next=-1;
   int BoOrder=0,begin=0,end=0;
   string MyOrder="";
   int index=0;
//---
   while(true)
     {
      BoOrder=StringFind(sData,"<Order>",BoOrder);
      if(BoOrder==-1) break;
      BoOrder+=9;
      next=StringFind(sData,"</Order>",BoOrder);
      if(next == -1) break;
      MyOrder = StringSubstr(sData,BoOrder,next-BoOrder);
      BoOrder = next;
      begin=0;

      for(int i=0; i<9; i++)
        {
         Order[index][i]="";
         next=StringFind(MyOrder,sTags(Tags[i]),begin);
         //--- Within this event, if tag not found, then it must be missing; skip it
         if(next==-1) continue;
         else
           {
            //--- We must have found the sTag okay...
            //--- Advance past the start tag
            begin=next+StringLen(sTags(Tags[i]));
            end=StringFind(MyOrder,eTags(Tags[i]),begin);
            //---Find start of end tag and Get data between start and end tag
            if(end>begin && end!=-1)
               Order[index][i]=StringSubstr(MyOrder,begin,end-begin);
           }
        }

      printf(string(index)+"#"+
             Order[index][0]+" | "+
             Order[index][1]+" | "+
             Order[index][2]+" | "+
             Order[index][3]+" | "+
             Order[index][4]+" | "+
             Order[index][5]+" | "+
             Order[index][6]+" | "+
             Order[index][7]+" | "+
             Order[index][8]+" | ");
      index++;
     }

   int slippage=10;
   for(int i=0;i<index;i++)
     {
      //                   0       1      2        3        4     5   6       7        8
      //string Tags[9]={"Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};

      bool copy=false;
      int  cTicket=int(Order[i][eTicket]);
      string cSymbol=Order[i][eSymbol];
      int cOP_DIR=int(Order[i][eType]);
      double cLOTS=double(Order[i][eLots]);
      double cOP=double(Order[i][ePrice]);
      double cSL=double(Order[i][eSL]);
      double cTP=double(Order[i][eTP]);

      string cComment=Order[i][eComment];
      int cMagic=int(Order[i][eMagic]);

      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderSymbol()!=cSymbol) continue;
         if(OrderType()!=cOP_DIR)continue;
         if(OrderComment()==string(cTicket))
           {
            copy=true;
           }
        }
      if(!copy)
        {
         int r=OrderSend(cSymbol,cOP_DIR,cLOTS,cOP,slippage,cSL,cTP,string(cTicket),0,0);
         printf(string(GetLastError()));

        }
     }
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      bool found=false;
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      for(int i=0;i<index;i++)
        {
         string  cTicket=Order[i][eTicket];
         if(OrderComment()==cTicket)
           {
            found=true;
            break;
           }
        }
      if(!found)
        {
         bool c=OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),slippage);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum cORDER
  {
   eTicket=0,
   eType=1,
   eLots=2,
   eSymbol=3,
   ePrice=4,
   eSL=5,
   eTP=6,
   eComment=7,
   eMagic=8
  };
//+------------------------------------------------------------------+
//|                                                                  |
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   OnTick();
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
      //printf("xmlRead: "+SerialNumber_Decode(PrivateKey,sData));
     }
//--- check for errors   
   else PrintFormat(INAME+": failed to open %s file, Error code = %d",FileName,GetLastError());
//---
  }
//+------------------------------------------------------------------+
