//+------------------------------------------------------------------+
//|                                         SuperIndicatorParser.mqh |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#include "LogParser.mqh"
//+------------------------------------------------------------------+
class SuperIndicatorParser : public LogSignalParser
  {
public:
                     SuperIndicatorParser():LogSignalParser("SuperIndicator"){}
   virtual bool      parse() override;
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool SuperIndicatorParser::parse() override
  {
   if(!this._parse_rows())
      return false;
   m_signals.Clear();
   MqlDateTime local;
   TimeLocal(local);
   for(int i=m_rows.Total()-1; i>=0; i--)
     {
      string row=m_rows[i];
      MqlDateTime log_time;
      TimeToStruct(StringToTime(StringSubstr(row,2,12)),log_time);
      log_time.year= local.year;
      log_time.mon = local.mon;
      log_time.day = local.day;
      datetime time= StructToTime(log_time);
      row=StringSubstr(row,StringFind(row,m_ind_name)+StringLen(m_ind_name)+1);
      StringReplace(row,","," ");
      string parts[];
      StringSplit(row,' ',parts);
      int len=ArraySize(parts);
      string debug="";
      for(int k=0;k<len;k++)
         debug+= "|" + parts[k];
      if(len!=17)
         continue;
      Signal *s      = new Signal();
      s.signal_time  = time;
      s.symbol       = parts[0];
      s.order_type   = parts[8] == "BUY" ? OP_BUYLIMIT : OP_SELLLIMIT;
      s.price_entry  = double(parts[10]);
      s.price_tp     = double(parts[13]);
      s.price_sl     = double(parts[16]);
      m_signals.Add(s);
     }
   m_signals.Sort();
   return true;
  }
//+------------------------------------------------------------------+
