//+------------------------------------------------------------------+
//|                                                 TestDataSave.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double Data_1[]={0,10,20,30,40};
double Data_2[]={0,10,20,30,40};
#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//#property script_show_inputs
//--- parameters for receiving data from the terminal
input string             InpSymbolName="EURUSD";      // Сurrency pair
input ENUM_TIMEFRAMES    InpSymbolPeriod=PERIOD_H1;   // Time frame
input int                InpFastEMAPeriod=12;         // Fast EMA period
input int                InpSlowEMAPeriod=26;         // Slow EMA period
input int                InpSignalPeriod=9;           // Difference averaging period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Price type
//--- parameters for writing data to file
input string             InpFileName="Data.csv";      // File name
input string             InpDirectoryName="Data";     // Folder name
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   _File_Write();
   _File_Read();
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
//|                                                                  |
//+------------------------------------------------------------------+
int iFileOpen(string _FileName)
  {
   int v=FileOpen(InpDirectoryName+"//"+_FileName,FILE_READ|FILE_WRITE|FILE_CSV,',');
   PrintFormat("Open file_handle chk Error = %d",GetLastError());
//PrintFormat(c(__LINE__)+"# %s file is available for writing",InpFileName);
//PrintFormat(c(__LINE__)+"# File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _File_Write()
  {
   PrintFormat(c(__LINE__)+"# ------------------------------");
   bool     sign_buff[]; // *signal array (true - buy, false - sell)
   datetime time_buff[]; // *array of signals' appear time
   int      sign_size=0; // signal array size
   double   macd_buff[]; // *array of indicator values
   datetime date_buff[]; // *array of indicator dates
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
//------------------
//--- open the file for writing the indicator values (if the file is absent, it will be created automatically)
//------------------
   ResetLastError();
   int file_handle=iFileOpen(InpFileName);
   if(file_handle!=INVALID_HANDLE)
     {

      //--- first, write the number of signals
      FileWrite(file_handle,sign_size);
      //--- write the time and values of signals to the file
      for(int i=0;i<sign_size;i++)
         FileWrite(file_handle,time_buff[i],sign_buff[i]);
      //---
      FileWrite(file_handle,"Davas");
      //---

      //--- close the file
      FileClose(file_handle);
      PrintFormat(c(__LINE__)+"# Data is written, %s file is closed, Error code = %d",InpFileName,GetLastError());
     }
   else
     {
      PrintFormat(c(__LINE__)+"# Failed to open %s file, Error code = %d",InpFileName,GetLastError());
     }
   PrintFormat(c(__LINE__)+"# ------------------------------");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ARR_Read[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _File_Read()
  {
//--- open the file 
   ResetLastError();
//int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_BIN|FILE_ANSI);
   int file_handle=iFileOpen(InpFileName);
   if(file_handle!=INVALID_HANDLE)
     {
      //--- additional variables 
      string str,C1,C2;
      PrintFormat(c(__LINE__)+"# ==============================");
      //str_size=FileReadInteger(file_handle,INT_VALUE);
      str=FileReadString(file_handle,0);
      PrintFormat(str);
      ArrayResize(ARR_Read,int(str),0);
      for(int i=0;i<ArraySize(ARR_Read);i++)
        {
         C1=FileReadString(file_handle,0);
         C2=FileReadString(file_handle,0);
         PrintFormat(C1+" | "+C2);
        }
      PrintFormat(c(__LINE__)+"# ==============================");
      //--- close the file 
      FileClose(file_handle);
      PrintFormat("Data is read, %s file is closed, Error code = %d",InpFileName,GetLastError());
     }
   else
     {
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
     }
   PrintFormat(c(__LINE__)+"# ------------------------------");
  }
//+------------------------------------------------------------------+
