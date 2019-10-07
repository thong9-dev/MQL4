//+------------------------------------------------------------------+
//|                                                CurrencyChart.mq4 |
//|                                                          Strator |
//|                                                  k-v-p@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Strator"
#property link      "k-v-p@yandex.ru"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green
//---- input parameters
extern string symbol = "EURUSD";
//---- buffers
double buffer_close[];
//---- variables
bool exit = false;
//+------------------------------------------------------------------+
//| Перевод строки в верхний регистр                                 |
//+------------------------------------------------------------------+
string StringUCase(string str)
  {
   for(int i = 0; i < StringLen(str); i++)
     {
       int character = StringGetChar(str, i);
       if((character>= 97 && character<= 122) || (character>= 224 && character<= 255))
           character= character- 32;
       str = StringSetChar(str, i, character);
     }
   return(str);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   symbol = StringUCase(symbol);
   MarketInfo(symbol, MODE_TIME);
   int last_error = GetLastError();
   if(last_error == 4106) //ERR_UNKNOWN_SYMBOL
     {
       string msg = "Неизвестный символ:" + symbol;
       IndicatorShortName(msg);
       Print(msg);
       exit = true;
     }
   else
     {
       IndicatorShortName(symbol + ",M" + Period());
       SetIndexBuffer(0, buffer_close);
       SetIndexStyle(0, DRAW_LINE);
       IndicatorDigits(MarketInfo(symbol, MODE_DIGITS));
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(exit) 
       return(0);
   int counted_bars = Bars - IndicatorCounted() - 1;
   for(int i = 0; i < counted_bars; i++)
     {
       datetime time_bar = Time[i];
       int bar_no = iBarShift(symbol, Period(), time_bar, false);
       buffer_close[i] = iClose(symbol, Period(), bar_no);
     }
   SetLevelStyle(DRAW_LINE, 1, DarkGray);
   SetLevelValue(0, MarketInfo(symbol, MODE_BID));
   return(0);
  }
//+------------------------------------------------------------------+