//+------------------------------------------------------------------+
//|                                                 Test_File_RW.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- show the window of input parameters when launching the script 
#property script_show_inputs 
//--- parameters for receiving data from the terminal 
input string             InpSymbolName="EURUSD";      // ?urrency pair 
input ENUM_TIMEFRAMES    InpSymbolPeriod=PERIOD_H1;   // Time frame 
input int                InpFastEMAPeriod=12;         // Fast EMA period 
input int                InpSlowEMAPeriod=26;         // Slow EMA period 
input int                InpSignalPeriod=9;           // Difference averaging period 
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Price type 
//--- parameters for writing data to file 
input string             InpFileName="MACD.csv";      // File name 
input string             InpDirectoryName="Data";     // Folder name 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
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
   ResetLastError();
   //int FileOpen(string filename, int mode, int delimiter=';')
   string FileName=InpDirectoryName+"//"+InpFileName;
   int file_handle=FileOpen(FileName,FILE_READ|FILE_WRITE|FILE_CSV,";");
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for writing",InpFileName);
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //--- first, write the number of signals 
      FileWrite(file_handle,sign_size);
      //--- write the time and values of signals to the file 
      for(int i=0;i<sign_size;i++)
         FileWrite(file_handle,time_buff[i],sign_buff[i]);
      //--- close the file 
      FileClose(file_handle);
      PrintFormat("Data is written, %s file is closed",InpFileName);
     }
   else
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
//--- return value of prev_calculated for next call
   return(rates_total);
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
