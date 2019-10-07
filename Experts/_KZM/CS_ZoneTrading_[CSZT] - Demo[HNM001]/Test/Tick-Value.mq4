//+------------------------------------------------------------------+
//|                                                   Tick-Value.mq4 |
//|                                          Copyright © 2007, Willf |
//|                                                   willf@willf.net|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Willf"
#property link      "willf@willf.net"

#property indicator_chart_window


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   //----

   string   Text="";
   


   Text =   "Tick Value = " + DoubleToStr(MarketInfo(Symbol(), MODE_TICKVALUE), 4) +
    	      "\n"+
 	         "Spread = " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0);

   Comment(Text);

   return(0);
  }
//+------------------------------------------------------------------+