//+------------------------------------------------------------------+
//|                                       OandaX_OrderBook_Chart.mq4 |
//+------------------------------------------------------------------+
#property link "http://www.trend-lab.ru"
#property copyright "TheXpert (www.trend-lab.ru)"
#property version   "1.4"
#property strict

#property description "OandaX_OrderBook_Chart indicator displays the most"
#property description "recent market book from Oanda available locally."
#property description "It uses chart price scale to draw the histogram."
#property description "It requires OandaX_DataManager to download data"

#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename t>
void ArrayReverse(t &a[])
  {
   uint size=ArraySize(a);
   for(uint i=0; i<size/2;++i)
     {
      t value=a[i];
      a[i]=a[size-i-1];
      a[size-i-1]=value;
     }
  }

#ifdef __MQL5__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)
  {
   datetime lastBar;
   SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE,lastBar);
   return(Bars(symbol, timeframe, time, lastBar) - 1);
  }
#endif

#ifdef __MQL5__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(int bar)
  {
   datetime t[];
   CopyTime(_Symbol,_Period,bar,1,t);
   return t[0];
  }
#endif
#ifdef __MQL4__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(int bar)
  {
   return Time[bar];
  }
#endif

#ifdef __MQL5__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(int bar)
  {
   double c[];
   CopyClose(_Symbol,_Period,bar,1,c);
   return c[0];
  }
#endif
#ifdef __MQL4__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(int bar)
  {
   return Close[bar];
  }
#endif
// ======================================================================
//  debug.mqh
// ======================================================================
#ifdef _DEBUG
bool _impl_is_debug_mode_on=true;
#else 
bool _impl_is_debug_mode_on=false;
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetDebugMode(bool on=true)
  {
   _impl_is_debug_mode_on=on;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDebug()
  {
   return _impl_is_debug_mode_on;
  }

#define LOG(text) Print(__FILE__,"(",__LINE__,") : ",text)

#define ERROR_CODE(A) A
#define ERROR(text, ERROR_CODE) if (IsDebug()) Print("Error: ", __FUNCTION__,"(", __LINE__, ") ", text, " ", ERROR_CODE, " : ", ErrorDescription(ERROR_CODE))

#define DCHECK(A) if (IsDebug() && !(A)) Alert(__FUNCTION__ + "(" + (string)__LINE__ + ")")
#define DCHECK_EQ(A, B) if (IsDebug()) DCHECK(A == B)
#define DEBUG_LOG(text) if (IsDebug()) Print(__FILE__,"(",__LINE__,") : ",text)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string;
//---
   switch(error_code)
     {
      //--- codes returned from trade server
      case 0:   error_string="no error";                                                   break;
      case 1:   error_string="no error, trade conditions not changed";                     break;
      case 2:   error_string="common error";                                               break;
      case 3:   error_string="invalid trade parameters";                                   break;
      case 4:   error_string="trade server is busy";                                       break;
      case 5:   error_string="old version of the client terminal";                         break;
      case 6:   error_string="no connection with trade server";                            break;
      case 7:   error_string="not enough rights";                                          break;
      case 8:   error_string="too frequent requests";                                      break;
      case 9:   error_string="malfunctional trade operation (never returned error)";       break;
      case 64:  error_string="account disabled";                                           break;
      case 65:  error_string="invalid account";                                            break;
      case 128: error_string="trade timeout";                                              break;
      case 129: error_string="invalid price";                                              break;
      case 130: error_string="invalid stops";                                              break;
      case 131: error_string="invalid trade volume";                                       break;
      case 132: error_string="market is closed";                                           break;
      case 133: error_string="trade is disabled";                                          break;
      case 134: error_string="not enough money";                                           break;
      case 135: error_string="price changed";                                              break;
      case 136: error_string="off quotes";                                                 break;
      case 137: error_string="broker is busy (never returned error)";                      break;
      case 138: error_string="requote";                                                    break;
      case 139: error_string="order is locked";                                            break;
      case 140: error_string="long positions only allowed";                                break;
      case 141: error_string="too many requests";                                          break;
      case 145: error_string="modification denied because order is too close to market";   break;
      case 146: error_string="trade context is busy";                                      break;
      case 147: error_string="expirations are denied by broker";                           break;
      case 148: error_string="amount of open and pending orders has reached the limit";    break;
      case 149: error_string="hedging is prohibited";                                      break;
      case 150: error_string="prohibited by FIFO rules";                                   break;

      //--- mql4 errors
      case 4000: error_string="no error (never generated code)";                           break;
      case 4001: error_string="wrong function pointer";                                    break;
      case 4002: error_string="array index is out of range";                               break;
      case 4003: error_string="no memory for function call stack";                         break;
      case 4004: error_string="recursive stack overflow";                                  break;
      case 4005: error_string="not enough stack for parameter";                            break;
      case 4006: error_string="no memory for parameter string";                            break;
      case 4007: error_string="no memory for temp string";                                 break;
      case 4008: error_string="non-initialized string";                                    break;
      case 4009: error_string="non-initialized string in array";                           break;
      case 4010: error_string="no memory for array\' string";                              break;
      case 4011: error_string="too long string";                                           break;
      case 4012: error_string="remainder from zero divide";                                break;
      case 4013: error_string="zero divide";                                               break;
      case 4014: error_string="unknown command";                                           break;
      case 4015: error_string="wrong jump (never generated error)";                        break;
      case 4016: error_string="non-initialized array";                                     break;
      case 4017: error_string="dll calls are not allowed";                                 break;
      case 4018: error_string="cannot load library";                                       break;
      case 4019: error_string="cannot call function";                                      break;
      case 4020: error_string="expert function calls are not allowed";                     break;
      case 4021: error_string="not enough memory for temp string returned from function";  break;
      case 4022: error_string="system is busy (never generated error)";                    break;
      case 4023: error_string="dll-function call critical error";                          break;
      case 4024: error_string="internal error";                                            break;
      case 4025: error_string="out of memory";                                             break;
      case 4026: error_string="invalid pointer";                                           break;
      case 4027: error_string="too many formatters in the format function";                break;
      case 4028: error_string="parameters count is more than formatters count";            break;
      case 4029: error_string="invalid array";                                             break;
      case 4030: error_string="no reply from chart";                                       break;
      case 4050: error_string="invalid function parameters count";                         break;
      case 4051: error_string="invalid function parameter value";                          break;
      case 4052: error_string="string function internal error";                            break;
      case 4053: error_string="some array error";                                          break;
      case 4054: error_string="incorrect series array usage";                              break;
      case 4055: error_string="custom indicator error";                                    break;
      case 4056: error_string="arrays are incompatible";                                   break;
      case 4057: error_string="global variables processing error";                         break;
      case 4058: error_string="global variable not found";                                 break;
      case 4059: error_string="function is not allowed in testing mode";                   break;
      case 4060: error_string="function is not confirmed";                                 break;
      case 4061: error_string="send mail error";                                           break;
      case 4062: error_string="string parameter expected";                                 break;
      case 4063: error_string="integer parameter expected";                                break;
      case 4064: error_string="double parameter expected";                                 break;
      case 4065: error_string="array as parameter expected";                               break;
      case 4066: error_string="requested history data is in update state";                 break;
      case 4067: error_string="internal trade error";                                      break;
      case 4068: error_string="resource not found";                                        break;
      case 4069: error_string="resource not supported";                                    break;
      case 4070: error_string="duplicate resource";                                        break;
      case 4071: error_string="cannot initialize custom indicator";                        break;
      case 4072: error_string="cannot load custom indicator";                              break;
      case 4073: error_string="no history data";                                           break;
      case 4074: error_string="not enough memory for history data";                        break;
      case 4075: error_string="not enough memory for indicator";                           break;
      case 4099: error_string="end of file";                                               break;
      case 4100: error_string="some file error";                                           break;
      case 4101: error_string="wrong file name";                                           break;
      case 4102: error_string="too many opened files";                                     break;
      case 4103: error_string="cannot open file";                                          break;
      case 4104: error_string="incompatible access to a file";                             break;
      case 4105: error_string="no order selected";                                         break;
      case 4106: error_string="unknown symbol";                                            break;
      case 4107: error_string="invalid price parameter for trade function";                break;
      case 4108: error_string="invalid ticket";                                            break;
      case 4109: error_string="trade is not allowed in the expert properties";             break;
      case 4110: error_string="longs are not allowed in the expert properties";            break;
      case 4111: error_string="shorts are not allowed in the expert properties";           break;
      case 4200: error_string="object already exists";                                     break;
      case 4201: error_string="unknown object property";                                   break;
      case 4202: error_string="object does not exist";                                     break;
      case 4203: error_string="unknown object type";                                       break;
      case 4204: error_string="no object name";                                            break;
      case 4205: error_string="object coordinates error";                                  break;
      case 4206: error_string="no specified subwindow";                                    break;
      case 4207: error_string="graphical object error";                                    break;
      case 4210: error_string="unknown chart property";                                    break;
      case 4211: error_string="chart not found";                                           break;
      case 4212: error_string="chart subwindow not found";                                 break;
      case 4213: error_string="chart indicator not found";                                 break;
      case 4220: error_string="symbol select error";                                       break;
      case 4250: error_string="notification error";                                        break;
      case 4251: error_string="notification parameter error";                              break;
      case 4252: error_string="notifications disabled";                                    break;
      case 4253: error_string="notification send too frequent";                            break;
      case 4260: error_string="ftp server is not specified";                               break;
      case 4261: error_string="ftp login is not specified";                                break;
      case 4262: error_string="ftp connect failed";                                        break;
      case 4263: error_string="ftp connect closed";                                        break;
      case 4264: error_string="ftp change path error";                                     break;
      case 4265: error_string="ftp file error";                                            break;
      case 4266: error_string="ftp error";                                                 break;
      case 5001: error_string="too many opened files";                                     break;
      case 5002: error_string="wrong file name";                                           break;
      case 5003: error_string="too long file name";                                        break;
      case 5004: error_string="cannot open file";                                          break;
      case 5005: error_string="text file buffer allocation error";                         break;
      case 5006: error_string="cannot delete file";                                        break;
      case 5007: error_string="invalid file handle (file closed or was not opened)";       break;
      case 5008: error_string="wrong file handle (handle index is out of handle table)";   break;
      case 5009: error_string="file must be opened with FILE_WRITE flag";                  break;
      case 5010: error_string="file must be opened with FILE_READ flag";                   break;
      case 5011: error_string="file must be opened with FILE_BIN flag";                    break;
      case 5012: error_string="file must be opened with FILE_TXT flag";                    break;
      case 5013: error_string="file must be opened with FILE_TXT or FILE_CSV flag";        break;
      case 5014: error_string="file must be opened with FILE_CSV flag";                    break;
      case 5015: error_string="file read error";                                           break;
      case 5016: error_string="file write error";                                          break;
      case 5017: error_string="string size must be specified for binary file";             break;
      case 5018: error_string="incompatible file (for string arrays-TXT, for others-BIN)"; break;
      case 5019: error_string="file is directory, not file";                               break;
      case 5020: error_string="file does not exist";                                       break;
      case 5021: error_string="file cannot be rewritten";                                  break;
      case 5022: error_string="wrong directory name";                                      break;
      case 5023: error_string="directory does not exist";                                  break;
      case 5024: error_string="specified file is not directory";                           break;
      case 5025: error_string="cannot delete directory";                                   break;
      case 5026: error_string="cannot clean directory";                                    break;
      case 5027: error_string="array resize error";                                        break;
      case 5028: error_string="string resize error";                                       break;
      case 5029: error_string="structure contains strings or dynamic arrays";              break;

      default:   error_string="unknown error";
     }
//---
   return(error_string);
  }
// ======================================================================
//  end of debug.mqh
// ======================================================================

// ======================================================================
//  graphics.mqh
// ======================================================================
void DrawLine(string name,int wnd,datetime t1,double p1,datetime t2,double p2,color clr,int style=STYLE_SOLID)
  {
   ObjectCreate(0,name,OBJ_TREND,wnd,t1,p1,t2,p2);
#ifdef __MQL4__
   ObjectSetInteger(0,name,OBJPROP_TIME1,t1);
   ObjectSetInteger(0,name,OBJPROP_TIME2,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE1,p1);
   ObjectSetDouble(0,name,OBJPROP_PRICE2,p2);
#endif
#ifdef __MQL5__
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t1);
   ObjectSetInteger(0,name,OBJPROP_TIME,2,t2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,p1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,2,p2);
#endif
   ObjectSetInteger(0,name,OBJPROP_WIDTH,style==STYLE_SOLID ? 3 : 1);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRect(string name,int wnd,datetime x1,double y1,datetime x2,double y2,color clr,bool back)
  {
   ObjectCreate(0,name,OBJ_RECTANGLE,wnd,0,x1,y1,x2,y2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
#ifdef __MQL4__
   ObjectSetDouble(0,name,OBJPROP_PRICE1,y1);
   ObjectSetDouble(0,name,OBJPROP_PRICE2,y2);
   ObjectSetInteger(0,name,OBJPROP_TIME1,x1);
   ObjectSetInteger(0,name,OBJPROP_TIME2,x2);
#endif
#ifdef __MQL5__
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,y1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,2,y2);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,x1);
   ObjectSetInteger(0,name,OBJPROP_TIME,2,x2);
#endif
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawText(string name,int wnd,string text,datetime t1,double p1,color clr)
  {
   ObjectCreate(0,name,OBJ_TEXT,wnd,t1,p1);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
#ifdef __MQL4__
   ObjectSetInteger(0,name,OBJPROP_TIME1,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE1,p1);
   ObjectSetText(name,text,10,"Arial",clr);
#endif
#ifdef __MQL5__
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t1);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,p1);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
#endif
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVertLine(string name,int wnd,datetime t,color clr,int style=STYLE_SOLID)
  {
   ObjectCreate(0,name,OBJ_VLINE,wnd,t,0);

#ifdef __MQL4__
   ObjectSetInteger(0,name,OBJPROP_TIME1,t);
#endif
#ifdef __MQL5__
   ObjectSetInteger(0,name,OBJPROP_TIME,1,t);
#endif

   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,style==STYLE_SOLID ? 3 : 1);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,true);
  }
// ======================================================================
//  end of graphics.mqh
// ======================================================================

// ======================================================================
//  oanda.mqh
// ======================================================================
const string kProductPath="OandaX";

const string kOrderBookPath="Orderbook";
const string kRatioPath="Ratio";

const string kTasksPath="tasks";
const string kHistoryPath="history";
const string kLastUpdatePath="last";
const string kDirSeparator="\\";
const string kAllFilesFilter="\\*";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PricePoint 
  {
   float             price;
   float             ol;        // Percentage long orders
   float             os;        // Percentage short orders
   float             pl;        // Percentage long positions
   float             ps;        // Percentage short positions
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct OrderBookStruct 
  {
   int               timestamp; // The time returned as a unix timestamp   
   float             rate;      // Rate at that specific time

   PricePoint        price_points[];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTasksPath(const string &type_path)
  {
   return kProductPath + kDirSeparator + type_path + kDirSeparator + kTasksPath;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetHistoryPath(const string &type_path)
  {
   return kProductPath + kDirSeparator + type_path + kDirSeparator + kHistoryPath;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateInstrumentPathFromTimestamp(const string &instrument,datetime timestamp)
  {
   MqlDateTime date;
   TimeToStruct(timestamp,date);

   return instrument + kDirSeparator
   + (string)date.year + kDirSeparator
   + (string)date.mon + kDirSeparator
   + (string)date.day + kDirSeparator
   +(string)(long)timestamp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime LoadLastUpdateFile(const string &type_path,const string &instrument)
  {
   ResetLastError();
   const string last_path=GetHistoryPath(type_path)+kDirSeparator+instrument+kDirSeparator+kLastUpdatePath;

   if(FileIsExist(last_path))
     {
      int file_handle = FileOpen(last_path, FILE_READ|FILE_CSV);
      if(file_handle != INVALID_HANDLE)
        {
         datetime last_update=FileReadDatetime(file_handle);
         FileClose(file_handle);
         return last_update;
        }
      else
        {
         ERROR("Error in FileOpen, file: "+last_path,GetLastError());
        }
     }
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LoadOrderBookForTimestamp(const string &instrument,const datetime timestamp,OrderBookStruct &orderbook)
  {
   string file_path=GetHistoryPath(kOrderBookPath)+kDirSeparator+
                    GenerateInstrumentPathFromTimestamp(instrument,timestamp);
   bool result=false;

   if(FileIsExist(file_path))
     {
      int file_handle=FileOpen(file_path,FILE_READ|FILE_BIN);

      if(file_handle!=INVALID_HANDLE)
        {
         ResetLastError();
         orderbook.rate=FileReadFloat(file_handle);

         if(!GetLastError())
           {
            uint count=FileReadArray(file_handle,orderbook.price_points);

            if(count)
              {
               orderbook.timestamp=(int)timestamp;
               result=true;
              }
            else
              {
               // Error
              }
           }
         else
           {
            // Error      
           }
         FileClose(file_handle);
        }
      else
        {
         // ERROR("Error in FileOpen, file: " + file_path, GetLastError());
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateInstrumentName(string instrument,bool custom)
  {
   if(custom) return instrument;
   return StringSubstr(instrument, 0, 3) + "_" + StringSubstr(instrument, 3, 3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime AdjustTime(datetime t)
  {
   MqlDateTime ts={0};
   TimeToStruct(t,ts);
   ts.sec=0;
// 20 min adjustment
   ts.min-=ts.min%20;
   return StructToTime(ts);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HistoryFinder
  {
public:
   static datetime   MakeDateTime(int year,int month,int day);
   static datetime   GetLatest(int level,int year,int month,int day);
   static datetime   GetOldest(int level,int year,int month,int day);

   bool              FindLatestRecord(const string &path,datetime &timestamp,datetime from,datetime to,int level);
   bool              FindOldestRecord(const string &path,datetime &timestamp,datetime from,datetime to,int level);

private:
   int               year_;
   int               month_;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime HistoryFinder::MakeDateTime(int year,int month,int day)
  {
   MqlDateTime t={0};
   t.year= year;
   t.mon = month;
   t.day = day;

   return StructToTime(t);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime HistoryFinder::GetLatest(int level,int year,int month,int day)
  {
   DCHECK(level >= 0);
   DCHECK(level <= 2);
   DCHECK(year>0);
   DCHECK(month>0);
   DCHECK(month<=12);
   DCHECK(day>0);
   DCHECK(day<=31);

   if(level < 0) return 0;
   if(level > 2) return 0;
   if(year < 1) return 0;
   if(month < 1) return 0;
   if(month > 12) return 0;

   datetime res=0;

   if(level==0)
     { // only year available
      // latest time is 20 minutes before 1st day start of next year
      res=MakeDateTime(year+1,1,1)-20*60;
     }
   else if(level==1)
     {
      // latest day is the day before 1st day of next month
      if(month<12)
        {
         res=MakeDateTime(year,month+1,1)-20*60;
        }
      else
        {
         res=MakeDateTime(year+1,1,1)-20*60;
        }
     }
   else if(level==2)
     {
      res=MakeDateTime(year,month,day)+24*60*60-20*60;
     }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime HistoryFinder::GetOldest(int level,int year,int month,int day)
  {
   DCHECK(level >= 0);
   DCHECK(level <= 2);
   DCHECK(year>0);
   DCHECK(month>0);
   DCHECK(month<=12);
   DCHECK(day>0);
   DCHECK(day<=31);

   if(level < 0) return 0;
   if(level > 2) return 0;
   if(year < 1) return 0;
   if(month < 1) return 0;
   if(month > 12) return 0;

   datetime res=0;

   if(level==0)
     { // only year available
      res=MakeDateTime(year,1,1);
     }
   else if(level==1)
     {
      res=MakeDateTime(year,month,1);
     }
   else if(level==2)
     {
      res=MakeDateTime(year,month,day);
     }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HistoryFinder::FindLatestRecord(const string &path,datetime &timestamp,datetime from,datetime to,int level)
  {
   DCHECK(level>=0);
   if(level < 0 || level > 3) return false;

   if(level==0)
     {
      timestamp=0;
     }
   datetime current=0;

   string file_name;
   string file_path;

   int files[];
   int folders[];

   ArrayResize(files,0);
   ArrayResize(folders,0);

   long search_handle=FileFindFirst(path+kAllFilesFilter,file_name,false);

   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         file_path=path+kDirSeparator+file_name;

         bool res=FileIsExist(file_path);
         if(!res)
           {
            // if we meet folder after level 2, this directory does not contain data or base path is wrong
            if(GetLastError()==ERR_FILE_IS_DIRECTORY && level<3)
              {
               int v = (int)StringToInteger(file_name);
               if(v != 0)
                 {
                  int size=ArraySize(folders);
                  ArrayResize(folders,size+1);
                  folders[size]=v;
                 }
              }
           }
         else
           {
            // if we meet file before level 3, this file is not history, skip it
            if(level>=3)
              {
               int v = (int)StringToInteger(file_name);
               if(v != 0)
                 {
                  int size=ArraySize(files);
                  ArrayResize(files,size+1);
                  files[size]=v;
                 }
              }
           }
        }
      while(FileFindNext(search_handle,file_name));

      FileFindClose(search_handle);
     }
   else
     {
      return false;
     }

// final level. work with files
   if(level==3)
     {
      int size=ArraySize(files);
      for(int i=0; i<size;++i)
        {
         datetime t=files[i];
         if(t!=0 && t>=from && t<=to && t>current)
           {
            current=t;
           }
        }
     }
   else // level 0 or 1 or 2, folders
     {
      if(ArraySize(folders)==0)
        {
         return false;
        }

      ArraySort(folders);
      ArrayReverse(folders);

      int size=ArraySize(folders);
      for(int i=0; i<size;++i)
        {
         int value=folders[i];
         if(value<0) continue;

         datetime latest;
         if(level==0) latest=GetLatest(0,value,1,1);
         else if(level==1) latest=GetLatest(1,year_,value,1);
         else                  latest=GetLatest(2,year_,month_,value);

         if(latest==0) continue;
         if(latest<timestamp && timestamp!=0) continue;
         if(latest<from) continue;

         datetime oldest;
         if(level==0) oldest=GetOldest(0,value,1,1);
         else if(level==1) oldest=GetOldest(1,year_,value,1);
         else                  oldest=GetOldest(2,year_,month_,value);

         if(oldest>to) continue;

         // so we have a potential folder, go inside
         if(level == 0) year_ = value;
         if(level == 1) month_ = value;
         string next=path+kDirSeparator+(string)folders[i];
         FindLatestRecord(next,timestamp,from,to,level+1);
        }
     }

   if(current!=0 && current>timestamp)
     {
      timestamp=current;
     }

   if(timestamp==0 && level==0)
     {
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HistoryFinder::FindOldestRecord(const string &path,datetime &timestamp,datetime from,datetime to,int level)
  {
   DCHECK(level>=0);
   if(level < 0 || level > 3) return false;
   if(level==0)
     {
      timestamp=0;
     }

   datetime current=0;

   string file_name;
   string file_path;

   int files[];
   int folders[];

   ArrayResize(files,0);
   ArrayResize(folders,0);

   long search_handle=FileFindFirst(path+kAllFilesFilter,file_name,false);

   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         file_path=path+kDirSeparator+file_name;

         bool res=FileIsExist(file_path);
         if(!res)
           {
            // if we meet folder after level 2, this directory does not contain data or base path is wrong
            if(GetLastError()==ERR_FILE_IS_DIRECTORY && level<3)
              {
               int v = (int)StringToInteger(file_name);
               if(v != 0)
                 {
                  int size=ArraySize(folders);
                  ArrayResize(folders,size+1);
                  folders[size]=v;
                 }
              }
           }
         else
           {
            // if we meet file before level 3, this file is not history, skip it
            if(level>=3)
              {
               int v = (int)StringToInteger(file_name);
               if(v != 0)
                 {
                  int size=ArraySize(files);
                  ArrayResize(files,size+1);
                  files[size]=v;
                 }
              }
           }
        }
      while(FileFindNext(search_handle,file_name));

      FileFindClose(search_handle);
     }
   else
     {
      return false;
     }

// final level. work with files
   if(level==3)
     {
      int size=ArraySize(files);
      for(int i=0; i<size;++i)
        {
         datetime t=files[i];
         if(t!=0 && t>=from && t<=to && (t<current || current==0))
           {
            current=t;
           }
        }
     }
   else // level 0 or 1 or 2, folders
     {
      if(ArraySize(folders) == 0) return false;

      ArraySort(folders);

      int size=ArraySize(folders);
      for(int i=0; i<size;++i)
        {
         int value=folders[i];
         if(value<0) continue;

         datetime latest;
         if(level==0) latest=GetLatest(0,value,1,1);
         else if(level==1) latest=GetLatest(1,year_,value,1);
         else                  latest=GetLatest(2,year_,month_,value);

         if(latest==0) continue;
         if(latest<from) continue;

         datetime oldest;
         if(level==0) oldest=GetOldest(0,value,1,1);
         else if(level==1) oldest=GetOldest(1,year_,value,1);
         else                  oldest=GetOldest(2,year_,month_,value);

         if(oldest>to) continue;
         if(oldest>timestamp && timestamp!=0) continue;

         // so we have a potential folder, go inside
         if(level == 0) year_ = value;
         if(level == 1) month_ = value;
         string next=path+kDirSeparator+(string)folders[i];
         FindOldestRecord(next,timestamp,from,to,level+1);
        }
     }

   if(timestamp==0 && level==0)
     {
      return false;
     }

   if(current!=0 && (current<timestamp || timestamp==0))
     {
      timestamp=current;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FindLatestRecord(const string &dataPath,const string &instrument,datetime &timestamp,datetime from=0,datetime to=0)
  {
   if(to==0)
     {
      to=TimeCurrent()+30*24*60*60; // +month from now
     }

   string path=kProductPath+"\\"+dataPath+"\\"+kHistoryPath+"\\"+instrument;
   HistoryFinder finder;
   datetime t=0;
   bool res=finder.FindLatestRecord(path,t,from,to,0);

   if(res)
     {
      timestamp=t;
     }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FindOldestRecord(const string &dataPath,const string &instrument,datetime &timestamp,datetime from=0,datetime to=0)
  {
   if(to==0)
     {
      to=TimeCurrent()+30*24*60*60; // +month from now
     }

   string path=kProductPath+"\\"+dataPath+"\\"+kHistoryPath+"\\"+instrument;
   HistoryFinder finder;
   datetime t=0;
   bool res=finder.FindOldestRecord(path,t,from,to,0);

   if(res)
     {
      timestamp=t;
     }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FindNearestRecord(const string &dataPath,const string &instrument,datetime &timestamp,datetime time,datetime from=0,datetime to=0)
  {
   if(to==0)
     {
      to=TimeCurrent()+30*24*60*60; // +month from now
     }

   string path=kProductPath+"\\"+dataPath+"\\"+kHistoryPath+"\\"+instrument;
   HistoryFinder finder;
   datetime oldest=0,latest=0;

   bool oldestOk = finder.FindOldestRecord(path, oldest, time, to, 0);
   bool latestOk = finder.FindLatestRecord(path, latest, from, time, 0);

   if(!oldestOk && !latestOk) return false;

   if(!oldestOk)
     {
      timestamp=latest;
     }
   else if(!latestOk)
     {
      timestamp=oldest;
     }
   else
     {
      if(MathAbs(latest-time)<MathAbs(oldest-time))
        {
         timestamp=latest;
        }
      else
        {
         timestamp=oldest;
        }
     }

   return true;
  }

// ======================================================================
//  end of oanda.mqh
// ======================================================================

// ======================================================================
//  utils.mqh
// ======================================================================
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename t>
void Sort(t &a[],bool ascending=true)
  {
   if(ascending) SortShellUp(a);
   else           SortShellDn(a);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename t>
void SortShellUp(t &a[])
  {
   t tmp;
   int n[]={9,5,3,2,1};
   int i,j,k,g;
   int Len=ArraySize(a);
   for(k=0;k<5;k++)
     {
      g=n[k];
      for(i=g;i<Len;i++)
        {
         tmp=a[i];
         for(j=i-g;j>=0 && tmp<a[j];j-=g)
           {
            a[j+g]=a[j];
           }
         a[j+g]=tmp;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename t>
void SortShellDn(t &a[])
  {
   t tmp;
   int n[]={9,5,3,2,1};
   int i,j,k,g;
   int Len=ArraySize(a);
   for(k=0;k<5;k++)
     {
      g=n[k];
      for(i=g;i<Len;i++)
        {
         tmp=a[i];
         for(j=i-g;j>=0 && a[j]<tmp;j-=g)
           {
            a[j+g]=a[j];
           }
         a[j+g]=tmp;
        }
     }
  }
// ======================================================================
//  end of utils.mqh
// ======================================================================

// ======================================================================
//  UniqueId.mqh
// ======================================================================

#define RCIDGVNAME "idcommongvar"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetId()
  {
   double value=0;
   if(!GlobalVariableGet(RCIDGVNAME,value))
     {
      GlobalVariableSet(RCIDGVNAME,0.0);
     }

   int new_value = (int)value + 1;
   if(new_value >= 100000)
     {
      new_value=1;
     }

   while(!GlobalVariableSetOnCondition(RCIDGVNAME,(double)new_value,value))
     {
      value=GlobalVariableGet(RCIDGVNAME);
      new_value=(int)value+1;
      if(new_value>=100000)
        {
         new_value=1;
        }
     }

   return new_value;
  }

// ======================================================================
//  end of UniqueId.mqh
// ======================================================================

// ======================================================================
//  Histogram.mqh
// ======================================================================

const string COMMON_NAME="_oandaX_";
const color BG_COLOR = clrLightGray;
const color TP_COLOR = C'255,200,0';
const color SL_COLOR = C'0,104,139';
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct DrawData
  {
   float             price;
   float             percent;

   bool operator<(const DrawData &right) const
     {
      return price < right.price;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MaxPercent(const DrawData &a[])
  {
   int size= ArraySize(a);
   if(size == 0) return -1;

   int pos=0;
   float pos_value=a[0].percent;
   for(int i=1; i<size;++i)
     {
      if(a[i].percent>pos_value)
        {
         pos=i;
         pos_value=a[i].percent;
        }
     }
   return pos;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceBsearch(const DrawData &a[],double price)
  {
   int size=ArraySize(a);
   return
   (a[0]<a[size-1]) ?
   PriceBsearchAsc(a,price) :
   PriceBsearchDesc(a,price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceBsearchAsc(const DrawData &a[],double price)
  {
   int size=ArraySize(a);
   int begin=0,end=size-1;

   if(price < a[begin].price) return begin;
   if(price > a[end].price) return end;

   while(end-begin>1)
     {
      int i=(begin+end)/2;
      float p=a[i].price;

      if(price<p)
        {
         end=i;
        }
      else
        {
         begin=i;
        }
     }

   if(MathAbs(price-a[begin].price)<MathAbs(price-a[end].price))
     {
      return begin;
     }
   return end;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceBsearchDesc(const DrawData &a[],double price)
  {
   int size=ArraySize(a);
   int begin=0,end=size-1;

   if(price > a[begin].price) return begin;
   if(price < a[end].price) return end;

   while(end-begin>1)
     {
      int i=(begin+end)/2;
      float p=a[i].price;

      if(price>p)
        {
         end=i;
        }
      else
        {
         begin=i;
        }
     }

   if(MathAbs(price-a[begin].price)<MathAbs(price-a[end].price))
     {
      return begin;
     }
   return end;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetDigits(double v)
  {
   if(v == 0.0) return -1;
   if(v<0) v=-v;
   int res=0;

   while(v<1.0)
     {
      res++;
      v*=10.0;
     }
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetTime(int index)
  {
#ifdef __MQL4__
   datetime t=iTime(Symbol(),Period(),index);
   if(index<0)
     {
      t=Time[0]+PeriodSeconds()*(-index);
     }
   return t;
#endif
#ifdef __MQL5__
   datetime data[1]={0};
   if(CopyTime(Symbol(),Period(),index,1,data)==-1)
     {
      CopyTime(Symbol(),Period(),0,1,data);
     }
   return data[0];
#endif
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetScale(double max)
  {
   if(max < 2.5) return 1.0;
   if(max < 5.0) return 2.0;
   if(max < 7.5) return 3.0;
   if(max < 10.0) return 4.0;
   if(max < 12.5) return 5.0;
   if(max < 15.0) return 6.0;
   if(max < 17.5) return 7.0;
   if(max < 20.0) return 8.0;
   if(max < 22.5) return 9.0;
   if(max < 25.0) return 10.0;
   if(max < 37.5) return 15.0;
   if(max < 50.0) return 20.0;
   if(max < 62.5) return 25.0;
   if(max < 75.0) return 30.0;
   if(max < 87.5) return 35.0;
   return 40.0;
  }
// ============================================================================
// BaseHistogram class implementation
// ============================================================================

class BaseHistogram
  {
public:
                     BaseHistogram(float price,const PricePoint &histogram[],
                                                     bool cumulative,bool delta,bool show_orders,datetime base_time);

   // return true if the data was processed correctly and is actual
   bool              Ready() const;

   // oanda server time of current histogram
   datetime          BaseTime() const;

protected:
   // returns step if available or counts it from array if not
   float             GetStep(const DrawData &a[]);

private:
   // prepares all info needed to display histogram
   bool              ConstructData();

   // creates and separates incomplete structures from histogram array
   // and sorts them in the right way
   bool              PrepareData();
   // edits structures to contain cumulative data
   bool              MakeCumulative(DrawData &a[]);
   bool              MakeCumulative();
   // edits structures to contain delta
   bool              MakeDelta(DrawData &buys[],DrawData &sells[]);
   bool              MakeDelta();

   void              AddItem(DrawData &to[],float price,float percent);

   // find and add missing histogram levels
   bool              Normalize(DrawData &a[]);

   // find and add missing histogram levels
   bool              Sync(DrawData &b[],DrawData &s[]);

   // make numbers more round
   void              FixNumbers(DrawData &a[]);

protected:
   // histogram price
   float             price_;
   // histogram data
   PricePoint        histogram_[];
   // if true at exact level of histogram all orders(positions) are shown 
   // that are available from initial price to this level (including)
   bool              cumulative_;
   // if true the difference between buy and sell side is shown
   // if false both buy and sell orders (positions) are shown
   bool              delta_;
   // if true orders are shown
   // if false positions are shown
   bool              show_orders_;
   // minimum price step in the histogram
   float             step_;
   // if the data was processed correctly and all ok
   bool              ready_;
   // the time the histogram corresponds to
   datetime          base_time_;

   // draw data
   DrawData          high_sells_[];
   DrawData          high_buys_[];
   DrawData          low_sells_[];
   DrawData          low_buys_[];

   int               id_;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
BaseHistogram::BaseHistogram(float price,const PricePoint &histogram[],
                             bool cumulative,bool delta,bool show_orders,datetime base_time)
   : price_(price)
   ,cumulative_(cumulative)
   ,delta_(delta)
   ,show_orders_(show_orders)
   ,step_(0)
   ,ready_(false)
   ,base_time_(base_time)
   ,id_(GetId())
  {
   ArrayCopy(histogram_,histogram);
   ready_=ConstructData();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::ConstructData()
  {
   if(!PrepareData()) return false;
   if(cumulative_ && !MakeCumulative()) return false;
   if(delta_ && !MakeDelta()) return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::PrepareData()
  {
   ArrayResize(high_sells_,0);
   ArrayResize(high_buys_,0);
   ArrayResize(low_sells_,0);
   ArrayResize(low_buys_,0);

// separate data

   int size=ArraySize(histogram_);
   for(int i=0; i<size;++i)
     {
      if(histogram_[i].price>=price_)
        {
         if(show_orders_)
           {
            AddItem(high_sells_,histogram_[i].price, histogram_[i].os);
            AddItem(high_buys_, histogram_[i].price, histogram_[i].ol);
           }
         else
           {
            AddItem(high_sells_,histogram_[i].price, histogram_[i].ps);
            AddItem(high_buys_, histogram_[i].price, histogram_[i].pl);
           }
        }
      else
        {
         if(show_orders_)
           {
            AddItem(low_sells_,histogram_[i].price, histogram_[i].os);
            AddItem(low_buys_, histogram_[i].price, histogram_[i].ol);
           }
         else
           {
            AddItem(low_sells_,histogram_[i].price, histogram_[i].ps);
            AddItem(low_buys_, histogram_[i].price, histogram_[i].pl);
           }
        }
     }

// now we should find missing levels and fill them with zeros
   if(!Normalize(high_buys_)) return false;
   if(!Normalize(high_sells_)) return false;
   if(!Normalize(low_buys_)) return false;
   if(!Normalize(low_sells_)) return false;

   if(!Sync(high_buys_, high_sells_)) return false;
   if(!Sync(low_buys_, low_sells_)) return false;

// now all data should be without gaps and synced at all levels
// sort data

   Sort(high_buys_);
   Sort(high_sells_);

   Sort(low_buys_,false);
   Sort(low_sells_,false);

// make prices fine rounded
   FixNumbers(high_buys_);
   FixNumbers(high_sells_);
   FixNumbers(low_buys_);
   FixNumbers(low_sells_);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::MakeCumulative()
  {
   return
   MakeCumulative(high_buys_) && 
   MakeCumulative(high_sells_) && 
   MakeCumulative(low_buys_) && 
   MakeCumulative(low_sells_);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::MakeCumulative(DrawData &a[])
  {
   int size=ArraySize(a);
   float last=0;

   for(int i=0; i<size;++i)
     {
      a[i].percent+=last;
      last=a[i].percent;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::MakeDelta()
  {
   return
   MakeDelta(high_sells_,high_buys_) && 
   MakeDelta(low_sells_,low_buys_);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::MakeDelta(DrawData &left[],DrawData &right[])
  {
// data should be synchronized

   int size=ArraySize(left);
   int r_size=ArraySize(right);

   if(size != r_size) return false;

   for(int i=0; i<size;++i)
     {
      if(left[i].percent>right[i].percent)
        {
         left[i].percent=left[i].percent-right[i].percent;
         right[i].percent=0;
        }
      else
        {
         right[i].percent= right[i].percent-left[i].percent;
         left[i].percent = 0;
        }
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BaseHistogram::AddItem(DrawData &to[],float price,float percent)
  {
   int size=ArraySize(to);
   ArrayResize(to,size+1);

   to[size].price=price;
   to[size].percent=percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::Normalize(DrawData &a[])
  {
// find step
   Sort(a);

   double difference=GetStep(a);
   DCHECK(difference>0);
   if(difference<=0)
     {
      return false;
     }

// now find gaps
   int size= ArraySize(a);
   if(size == 0) return false;

   DrawData to_add[];
   ArrayResize(to_add,0);

   for(int i=1; i<size;++i)
     {
      double d=a[i].price-a[i-1].price;
      if(d>1000*difference)
        {
         return false;
        }

      if(d>1.5*difference)
        {
         double base= a[i-1].price+difference;
         double end = a[i].price;

         for(; base<end-0.5*difference; base+=difference)
           {
            AddItem(to_add,(float)base,0);
           }
        }
     }

   ArrayCopy(a,to_add,size);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::Sync(DrawData &b[],DrawData &s[])
  {
   Sort(b);
   Sort(s);

   double difference=GetStep(b);
   DCHECK(difference>0);
   if(difference<=0) difference=GetStep(s);
   DCHECK(difference>0);
   if(difference <= 0) return false;

   int b_pos=0;
   int b_size= ArraySize(b);
   int s_pos = 0;
   int s_size= ArraySize(s);

   DrawData b_add[],s_add[];
   ArrayResize(b_add,0);
   ArrayResize(s_add,0);

   while(b_pos<b_size && s_pos<s_size)
     {
      if(MathAbs(b[b_pos].price-s[s_pos].price)<0.5*difference)
        {
         b_pos++;
         s_pos++;
        }
      else
        {
         if(b[b_pos].price>s[s_pos].price)
           {
            AddItem(b_add,s[s_pos].price,0);
            s_pos++;
           }
         else
           {
            AddItem(s_add,b[b_pos].price,0);
            b_pos++;
           }
        }
     }

   if(b_pos<b_size)
     {
      for(int i=b_pos; i<b_size;++i)
        {
         AddItem(s_add,b[i].price,0);
        }
     }

   if(s_pos<s_size)
     {
      for(int i=s_pos; i<s_size;++i)
        {
         AddItem(b_add,s[i].price,0);
        }
     }

   ArrayCopy(b,b_add,b_size);
   ArrayCopy(s,s_add,s_size);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
float BaseHistogram::GetStep(const DrawData &a[])
  {
// should be sorted
   if(step_>0)
     {
      return step_;
     }

   int size=ArraySize(a);
   if(size<2)
     {
      return 0;
     }

   float difference=a[1].price-a[0].price;
   for(int i=2; i<size;++i)
     {
      float d=a[i].price-a[i-1].price;
      if(d<difference && d>0)
        {
         difference=d;
        }
     }

   step_=difference;
   return step_;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BaseHistogram::Ready() const
  {
   return ready_;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime BaseHistogram::BaseTime() const
  {
   return base_time_;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BaseHistogram::FixNumbers(DrawData &a[])
  {
   int size=ArraySize(a);
   for(int i=0; i<size;++i)
     {
      a[i].price=(float)NormalizeDouble(a[i].price,Digits()+1);
     }
  }
// ============================================================================
// End of BaseHistogram implementation
// ============================================================================

// ============================================================================
// HistogramUI class implementation
// ============================================================================

class HistogramUI
   : public BaseHistogram
  {
public:
                     HistogramUI(float price,const PricePoint &histogram[],
                                                   bool cumulative,bool delta,bool show_orders,datetime base_time);

                    ~HistogramUI();

   void              Draw(int wnd,datetime time,int width);
   void              Hide();

private:
   // remember the object we are going to draw. Needed to remove them automatically
   void              Remember(string obj);
   // use to draw non-data situation
   void              DrawEmpty(int wnd,datetime time,int width);

private:
   // last base timestamp where the histogram was drawn
   datetime          timestamp_;
   // objects names list that need to be deleted
   string            obj_names_[];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HistogramUI::HistogramUI(float price,const PricePoint &histogram[],
                         bool cumulative,bool delta,bool show_orders,datetime base_time)
   : BaseHistogram(price,histogram,cumulative,delta,show_orders,base_time)
   ,timestamp_(0)
  {
   ArrayResize(obj_names_,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HistogramUI::Remember(string obj)
  {
   int size=ArraySize(obj_names_);
   ArrayResize(obj_names_,size+1);
   obj_names_[size]=obj;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HistogramUI::DrawEmpty(int wnd,datetime time,int width)
  {
   Comment("OandaX OrderBook Chart:\nNo history data availble for this instrument.\nPlease provide history or run OandaX Download Manager");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HistogramUI::Draw(int wnd,datetime time,int width)
  {
   if(!Ready())
     {
      DrawEmpty(wnd,time,width);
      return;
     }

   Comment("OandaX OrderBook Chart:\nShowing orderbook for date:\n"+TimeToString(time));

   string common=COMMON_NAME+"_"+(string)id_+"_";

   if(time!=timestamp_) Hide();
   ArrayResize(obj_names_,0);

// draw background
   double p_high= high_buys_[ArraySize(high_buys_)-1].price;
   double p_low = low_buys_[ArraySize(low_buys_)-1].price;

// count vertical scales
   int x0=iBarShift(Symbol(),Period(),time);
   datetime w=2*width;

   double max=2.0;
   if(cumulative_)
     {
      max = high_buys_[MaxPercent(high_buys_)].percent;
      max = MathMax(high_sells_[MaxPercent(high_sells_)].percent, max);
      max = MathMax(low_buys_[MaxPercent(low_buys_)].percent, max);
      max = MathMax(low_sells_[MaxPercent(low_sells_)].percent, max);

      if(max<2.0) max=2.0;
     }

   double scale=GetScale(max);
   max=1.05*max;

   string name="0"+common+"_horscale_";
   DrawLine(name,wnd,GetTime(x0-width),price_,GetTime(x0+width),price_,clrMaroon,STYLE_DOT);
   Remember(name);

// draw scale
   double level=0;
   while(level<max)
     {
      datetime level_x=GetTime((int)(x0+w/2.0*level/max));
      name="0"+common+"_vertscale_"+DoubleToString(level,0);
      DrawLine(name,wnd,level_x,p_high,level_x,p_low,clrMaroon,STYLE_DOT);
      Remember(name);

      name="0"+common+"_vertscale_caption_"+DoubleToString(level,1);
      DrawText(name,wnd,DoubleToString(level,0)+"%",level_x,price_,clrYellow);
      Remember(name);

      level+=scale;
     }

   level=-scale;
   while(level>-max)
     {
      datetime level_x=GetTime((int)(x0+w/2.0*level/max));
      name="0"+common+"_vertscale_"+DoubleToString(level,0);
      DrawLine(name,wnd,level_x,p_high,level_x,p_low,clrMaroon,STYLE_DOT);
      Remember(name);

      name="0"+common+"_vertscale_caption_"+DoubleToString(level,1);
      DrawText(name,wnd,DoubleToString(-level,0)+"%",level_x,price_,clrYellow);
      Remember(name);

      level-=scale;
     }

// draw histogram

   double step=0.3*GetStep(low_buys_);

   int size=ArraySize(low_buys_);
   for(int i=0; i<size;++i)
     {
      double p=low_buys_[i].price;
      name="1"+common+"lb"+
           StringSubstr(DoubleToString(p),0,8)+IntegerToString(time);
      Remember(name);
      DrawRect(name,wnd,GetTime(x0-1),p+step,
               GetTime(x0-1-int(width*low_buys_[i].percent/max)),p-step,TP_COLOR,DrawSolid);
     }

   size=ArraySize(low_sells_);
   for(int i=0; i<size;++i)
     {
      double p=low_sells_[i].price;
      name="1"+common+"ls"+
           StringSubstr(DoubleToString(p),0,8)+IntegerToString(time);
      Remember(name);
      DrawRect(name,wnd,GetTime(x0+1),p+step,
               GetTime(x0+1+int(width*low_sells_[i].percent/max)),p-step,SL_COLOR,DrawSolid);
     }

   size=ArraySize(high_buys_);
   for(int i=0; i<size;++i)
     {
      double p=high_buys_[i].price;
      name="1"+common+"hb"+
           StringSubstr(DoubleToString(p),0,8)+IntegerToString(time);
      Remember(name);
      DrawRect(name,wnd,GetTime(x0-1),p+step,
               GetTime(x0-1-int(width*high_buys_[i].percent/max)),p-step,SL_COLOR,DrawSolid);
     }

   size=ArraySize(high_sells_);
   for(int i=0; i<size;++i)
     {
      double p=high_sells_[i].price;
      name="1"+common+"hs"+
           StringSubstr(DoubleToString(p),0,8)+IntegerToString(time);
      Remember(name);
      DrawRect(name,wnd,GetTime(x0+1),p+step,
               GetTime(x0+1+int(width*high_sells_[i].percent/max)),p-step,TP_COLOR,DrawSolid);
     }

   timestamp_=time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HistogramUI::Hide()
  {
   if(timestamp_ == 0) return;

   int size=ArraySize(obj_names_);
   for(int i=0; i<size;++i)
     {
      ObjectDelete(0,obj_names_[i]);
     }
   ArrayResize(obj_names_,0);

   timestamp_=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
HistogramUI::~HistogramUI()
  {
   Hide();
  }

// ============================================================================
// end of HistogramUI class implementation
// ============================================================================

// ======================================================================
//  end of Histogram.mqh
// ======================================================================

datetime LastLoaded;

input bool CustomInstrument=false; // Use Custom Instrument
input string CustomInstrumentName=""; // Custom Instrument Name
input string TimeOffset="AUTO"; // UTC Offset. Set like "3" or "-2" if custom

input bool Cumulative = false; // Show Histogram Cumulative
input bool Difference = false; // Show Histogram Difference
input bool ShowOrders = true; // Show Orders (Positions if False)
input bool ShowLatest = true; // Always show latest available information

input bool DrawSolid=false; // Draw solid levels at background

#property indicator_chart_window

bool Inited;
string Instrument;
int TaskHandle;

class HistogramUI;
HistogramUI *Histogram;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenTask()
  {
   if(TaskHandle != INVALID_HANDLE) return;
   TaskHandle=FileOpen(GetTasksPath(kOrderBookPath)+kDirSeparator+Instrument,FILE_WRITE|FILE_SHARE_READ);
  }

datetime LastBarTime=0;
datetime LastPos=0;
string PositionName;
int Id;

int OffsetUTC=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetTimeOffset(int &v)
  {
   bool ret=false;
   const string kOffsetFile="utc_offset";
   string path=kProductPath+kDirSeparator+kOffsetFile;

   int handle=FileOpen(path,FILE_READ);

   if(handle!=INVALID_HANDLE)
     {
      ResetLastError();
      int value=(int)FileReadNumber(handle);

      if(!GetLastError())
        {
         v=value;
         ret=true;
        }
      FileClose(handle);
     }

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(TimeOffset=="AUTO")
     {
      if(!GetTimeOffset(OffsetUTC))
        {
         Alert("Could not get UTC offset automatically. Please set up the offset manually or run Download Manager during the period when trading is available");
        }
     }
   else
     {
      OffsetUTC=(int)StringToInteger(TimeOffset);
     }
   Print("UTC offset is set to ",OffsetUTC);

   LastPos=0;
   LastBarTime= 0;
   TaskHandle = INVALID_HANDLE;
   Instrument = GenerateInstrumentName(
                                       CustomInstrument ? CustomInstrumentName : Symbol(),
                                       CustomInstrument);
   Histogram=NULL;

   OpenTask();

   Id=GetId();
   PositionName="OandaX_line_time_"+(string)Id;

   EventSetTimer(1);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OpenTask();

   if(LastPos==0)
     {
      LastPos=Time(0);
     }

   if(!ShowLatest)
     {
      int wnd = ObjectFind(0, PositionName);
      if(wnd >= 0)
        {
         long pos;
#ifdef __MQL5__
         if(ObjectGetInteger(0,PositionName,OBJPROP_TIME,1,pos))
#endif
#ifdef __MQL4__
            if(ObjectGetInteger(0,PositionName,OBJPROP_TIME1,0,pos))
#endif
                 {
                  LastPos=(datetime)pos;
                 }
               else
                 {
                  DrawVertLine(PositionName,0,LastPos,clrRed);
                 }
        }
      else
        {
         DrawVertLine(PositionName,0,LastPos,clrRed);
        }
     }

   DrawHistogram();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int total,
                const int prev,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(!Inited)
     {
      Inited=true;
      OnTimer();
     }

   if(LastBarTime!=Time(0))
     {
      LastBarTime=Time(0);
      OnNewBar();
     }

   return (total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnNewBar()
  {
   OnTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   FileClose(TaskHandle);
   EventKillTimer();
   delete Histogram;
   Histogram=NULL;

   ObjectDelete(0,PositionName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHistogram()
  {
   datetime nearest=0;
   bool res=false;
   if(ShowLatest)
      res=FindLatestRecord(kOrderBookPath,Instrument,nearest);
   else
      res=FindNearestRecord(kOrderBookPath,Instrument,nearest,LastPos-OffsetUTC*60*60);

   if(res)
     {
      if(CheckPointer(Histogram)!=POINTER_INVALID)
        {
         if(Histogram.BaseTime()!=nearest+OffsetUTC*60*60 && nearest!=0)
           {
            delete Histogram;
            Histogram=NULL;
           }
        }
      else
        {
         Histogram=NULL;
        }

      if(NULL==Histogram)
        {
         OrderBookStruct orderbook;
         bool loaded=LoadOrderBookForTimestamp(Instrument,nearest,orderbook);

         if(loaded)
           {
            orderbook.timestamp+=OffsetUTC*60*60;
            Histogram=new HistogramUI(
                                      orderbook.rate,orderbook.price_points,Cumulative,
                                      Difference,ShowOrders,orderbook.timestamp);
           }
        }
     }
   else
     {
      if(CheckPointer(Histogram)==POINTER_INVALID)
        {
         PricePoint price_points[];
         Histogram=new HistogramUI(
                                   (float)Close(0),price_points,Cumulative,Difference,ShowOrders,0);
        }
     }

   if(NULL!=Histogram)
     {
      Histogram.Draw(0,nearest+OffsetUTC*60*60,150);
     }
  }
//+------------------------------------------------------------------+
