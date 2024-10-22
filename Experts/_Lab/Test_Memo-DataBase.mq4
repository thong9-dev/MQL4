//+------------------------------------------------------------------+
//|                                           Test_Memo-DataBase.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>

//--- parameters for receiving data from the terminal
input string             InpSymbolName="EURUSD";      // Сurrency pair
input ENUM_TIMEFRAMES    InpSymbolPeriod=PERIOD_H1;   // Time frame
input int                InpFastEMAPeriod=12;         // Fast EMA period
input int                InpSlowEMAPeriod=26;         // Slow EMA period
input int                InpSignalPeriod=9;           // Difference averaging period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Price type
//--- parameters for writing data to file
input string             InpFileName="MACD";      // File name
input string             InpDirectoryName="Data";     // Folder name
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("");
//--- create timer
   EventSetTimer(60);
//---
   bool     sign_buff[]; // signal array (true - buy, false - sell)
   datetime time_buff[]; // array of signals' appear time
   int      sign_size=0; // signal array size
   double   macd_buff[]; // array of indicator values
   datetime date_buff[]; // array of indicator dates
   int      macd_size=0; // size of indicator arrays
//--- set indexing as time series
   ArraySetAsSeries(sign_buff,true);
   ArraySetAsSeries(time_buff,true);
   ArraySetAsSeries(macd_buff,true);
   ArraySetAsSeries(date_buff,true);
//--- reset last error code
   ResetLastError();
//--- copying the time from last 1000 bars
   int copied=CopyTime(NULL,0,0,1000,date_buff);
   if(copied<=0)
     {
      PrintFormat("Failed to copy time values. Error code = %d",GetLastError());
      //return;
     }
//--- prepare macd_buff array
   ArrayResize(macd_buff,copied);
//--- copy the values of main line of the iMACD indicator
   for(int i=0;i<copied;i++)
     {
      macd_buff[i]=iMACD(InpSymbolName,InpSymbolPeriod,InpFastEMAPeriod,InpSlowEMAPeriod,InpSignalPeriod,InpAppliedPrice,MODE_MAIN,i);
     }
//--- get size
   macd_size=ArraySize(macd_buff);
//--- analyze the data and save the indicator signals to the arrays
   ArrayResize(sign_buff,macd_size-1);
   ArrayResize(time_buff,macd_size-1);
   for(int i=1;i<macd_size;i++)
     {
      //--- buy signal
      if(macd_buff[i-1]<0 && macd_buff[i]>=0)
        {
         sign_buff[sign_size]=true;
         time_buff[sign_size]=date_buff[i];
         sign_size++;
        }
      //--- sell signal
      if(macd_buff[i-1]>0 && macd_buff[i]<=0)
        {
         sign_buff[sign_size]=false;
         time_buff[sign_size]=date_buff[i];
         sign_size++;
        }
     }
//--- open the file for writing the indicator values (if the file is absent, it will be created automatically)
//ResetLastError();
   Print("---------------------------------");
//   
   string FileName_Time=TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS);
   StringReplace(FileName_Time,".","-");
   StringReplace(FileName_Time,":","-");
   string FileName;
//FileName=InpFileName+" "+FileName_Time+".csv";
   FileName=InpFileName+".csv";
//   
   int file_handle=FileOpen(InpDirectoryName+"//"+FileName,FILE_READ|FILE_WRITE|FILE_BIN|FILE_CSV,",");

   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for writing",FileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //--- first, write the number of signals
      FileWrite(file_handle,sign_size);
      FileWrite(file_handle,FileName_Time);
      FileWrite(file_handle,"No,time_buff,sign_buff,end");
      //--- write the time and values of signals to the file
      for(int i=0;i<2;i++)
        {
         FileWrite(file_handle,(i+1)+","+time_buff[i]+","+sign_buff[i]+","+"end");
         //FileWriteString(file_handle,TimeToString(time_buff[i])+"\t"+c(sign_buff[i])+"\t"+"end"+"\n"); 
        }
      FileWrite(file_handle,",");
      //--- close the file
      FileClose(file_handle);
      PrintFormat("Data is written, %s file is closed",FileName);
     }
   else
     {
      PrintFormat(c(__LINE__)+"Failed to open %s file, Error code = %d",FileName,GetLastError());
     }
   Print("---------------------------------");

   file_handle=FileOpen(InpDirectoryName+"//"+"MACD.csv",FILE_READ|FILE_CSV,",");
//file_handle=FileOpen(InpDirectoryName+"//"+FileName,FILE_READ|FILE_WRITE|FILE_BIN|FILE_CSV,",");

   string s[100][100]; //assign array of string that will store 10 columns 100 rows of csv data
   int row=1,col=1; //column and row pointer for the array

   if(file_handle>0)
     {
      while(True) //loop through each cell
        {
         string temp=FileReadString(file_handle); //read csv cell
         Comment(GetLastError());
         if(FileIsEnding(file_handle))
            break; //FileIsEnding = End of File
         s[row][col]=temp; //save reading result to array
         Print("s[ "+row+" ][ "+col+" ] "+s[row][col]);
         if(FileIsLineEnding(file_handle)) //FileIsLineEnding = End of Line
           {
            col=1; //reset col = 0 for the next row
            row++; //next row
           }
         else
           {
            col++; //next col of the same row
           }
        }
      FileClose(file_handle);
     }
   else
     {
      Comment("File "+FileName+" not found, the last error is ",GetLastError());
     }
   Print("-----");
//Print(s[2][4]);

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
string fnReadFileValue(string filename,int line=-1,int column=-1)
  {
   string str= "";
   int count = 1;
   string sep= ";";
   ushort u_sep=StringGetCharacter(sep,0);

   int fp = FileOpen(filename,FILE_READ);
   if(fp != INVALID_HANDLE )
     {
      FileSeek(fp,0,SEEK_SET);
      while(!FileIsEnding(fp))
        {
         str=FileReadString(fp,0);
         if((line>0) && (line==count++))
            break;
        }
      FileClose(fp);
     }

   if(column>=0)
     {
      string values[];
      StringSplit(str,u_sep,values);

      if(column<ArraySize(values))
         str=values[column];
     }
   return str;
  }
//+------------------------------------------------------------------+
