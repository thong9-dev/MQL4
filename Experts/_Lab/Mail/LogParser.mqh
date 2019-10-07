//+------------------------------------------------------------------+
//|                                                    LogParser.mqh |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#include <stdlib.mqh>
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayObj.mqh>
#import "kernel32.dll"
bool CopyFileW(string lpExistingFileName,
               string lpNewFileName,
               bool   bFailIfExists);
#import
//+------------------------------------------------------------------+
//|                                                              
//+------------------------------------------------------------------+
class Signal : public CObject
  {
public:
   string            symbol;
   datetime          signal_time;
   int               order_type;
   double            price_entry;
   double            price_sl;
   double            price_tp;
   virtual int Compare(const CObject *node,const int mode=0) const override
     {
      const Signal *other=node;
      if(this.signal_time>other.signal_time)
         return 1;
      if(this.signal_time<other.signal_time)
         return -1;
      return 0;
     }
   string to_string()
     {
      return StringFormat("%s - %s(%s) @ %.5f, SL=%.5f, TP=%.5f",
                          signal_time,
                          symbol,
                          order_type==OP_BUYLIMIT ? "BUY" : "SELL",
                          price_entry,
                          price_sl,
                          price_tp
                          );
     }
  };
//+------------------------------------------------------------------+
//|Vector-like collection                                                          
//+------------------------------------------------------------------+
class SignalList : public CArrayObj
  {
public: Signal *operator[](int i){return this.At(i);}
  };
//+------------------------------------------------------------------+
//|Abstract abse class: the parse method must be implemented in subclass                                                             
//+------------------------------------------------------------------+
class LogSignalParser : public CObject
  {
protected:
   CArrayString      m_rows;
   SignalList        m_signals;
   string            m_log_file_name;
   string            m_ind_name;
public:
                     LogSignalParser(string indicator_name);

   // parse method must be overridden!
   virtual bool      parse()=0;
   int               Total();
   Signal           *operator[](int i);
protected:
   bool              _copy_log();
   int               _open_log();
   bool              _parse_rows();
  };
//+------------------------------------------------------------------+
LogSignalParser::LogSignalParser(string indicator_name)
  {
   m_log_file_name="copy_log.log";
   m_ind_name=indicator_name;
  }
//+------------------------------------------------------------------+
bool LogSignalParser::_copy_log(void)
  {
   MqlDateTime t;
   TimeLocal(t);
   string data_path = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4";
   string logs_path = data_path + "\\Logs\\";
   string dest_file = data_path + "\\Files\\" + m_log_file_name;
   string log_file=logs_path+StringFormat("%d%02d%02d.log",
                                          t.year,t.mon,t.day);
   return CopyFileW(log_file, dest_file, false);
  }
//+------------------------------------------------------------------+
bool LogSignalParser::_parse_rows()
  {
   if(!this._copy_log())
      return false;
   int h= this._open_log();
   if(h == INVALID_HANDLE)
      return false;
   m_rows.Clear();
   while(!FileIsEnding(h))
     {
      string row=FileReadString(h);
      if(StringFind(row,"Alert:")>=0 && StringFind(row,m_ind_name)>=0)
         m_rows.Add(row);
     }
   m_rows.Sort();
   FileClose(h);
   return true;
  }
//+------------------------------------------------------------------+
int LogSignalParser::_open_log(void)
  {
   return FileOpen(m_log_file_name,
                   FILE_TXT|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
  }
//+------------------------------------------------------------------+
int LogSignalParser::Total(void)
  {
   return m_signals.Total();
  }
//+------------------------------------------------------------------+
Signal *LogSignalParser::operator[](int i)
  {
   return m_signals.At(i);
  }
//+------------------------------------------------------------------+
