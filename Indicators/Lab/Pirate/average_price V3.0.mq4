//+------------------------------------------------------------------+
//|                                           Average Price v3.0.mq4 |
//|                                        Joca - nc32007a@gmail.com |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Joca"
#property indicator_chart_window
//---
extern color font_color=White;
extern int font_size=12;
//---
int PipAdjust,NrOfDigits;
double point;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   ObjectDelete("Average_Price_Line_"+Symbol());
   ObjectDelete("Information_"+Symbol());
//---
   NrOfDigits=Digits;
//---
   if(NrOfDigits==5 || NrOfDigits==3) PipAdjust=10;
   else
      if(NrOfDigits==4 || NrOfDigits==2) PipAdjust=1;
//---
   point=Point*PipAdjust;
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectDelete("Average_Price_Line_"+Symbol());
   ObjectDelete("Information_"+Symbol());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int Total_Buy_Trades;
   double Total_Buy_Size;
   double Total_Buy_Price;
   double Buy_Profit;
//---
   int Total_Sell_Trades;
   double Total_Sell_Size;
   double Total_Sell_Price;
   double Sell_Profit;
//---
   int Net_Trades;
   double Net_Lots;
   double Net_Result;
//---
   double Average_Price;
   double distance;
   double Pip_Value=MarketInfo(Symbol(),MODE_TICKVALUE)*PipAdjust;
   double Pip_Size=MarketInfo(Symbol(),MODE_TICKSIZE)*PipAdjust;
//---
   int total=OrdersTotal();
//---
   for(int i=0;i<total;i++)
     {
      int ord=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        {
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol())

           {
            Total_Buy_Trades++;
            Total_Buy_Price+= OrderOpenPrice()*OrderLots();
            Total_Buy_Size += OrderLots();
            Buy_Profit+=OrderProfit()+OrderSwap()+OrderCommission();
           }
         if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
           {
            Total_Sell_Trades++;
            Total_Sell_Size+=OrderLots();
            Total_Sell_Price+=OrderOpenPrice()*OrderLots();
            Sell_Profit+=OrderProfit()+OrderSwap()+OrderCommission();
           }
        }
     }
   if(Total_Buy_Price>0)
     {
      Total_Buy_Price/=Total_Buy_Size;
     }
   if(Total_Sell_Price>0)
     {
      Total_Sell_Price/=Total_Sell_Size;
     }
   Net_Trades=Total_Buy_Trades+Total_Sell_Trades;
   Net_Lots=Total_Buy_Size-Total_Sell_Size;
   Net_Result=Buy_Profit+Sell_Profit;
//---
   ObjectDelete("Average_Price_Line_"+Symbol());
   ObjectDelete("Information_"+Symbol());
//---
   if(Net_Trades>0 && Net_Lots!=0)
     {
      distance=(Net_Result/(MathAbs(Net_Lots*MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));
      if(Net_Lots>0)
        {
         Average_Price=Bid-distance;
        }
      if(Net_Lots<0)
        {
         Average_Price=Ask+distance;
        }
     }
   if(Net_Trades>0 && Net_Lots==0)
     {
      distance=(Net_Result/((MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));
      Average_Price=Bid-distance;
     }
   ObjectDelete("Average_Price_Line_"+Symbol());
   ObjectCreate("Average_Price_Line_"+Symbol(),OBJ_HLINE,0,0,Average_Price);
   ObjectSet("Average_Price_Line_"+Symbol(),OBJPROP_WIDTH,3);
//---
   color cl=Blue;
   if(Net_Lots<0) cl=Red;
   if(Net_Lots==0) cl=White;
//---
   ObjectSet("Average_Price_Line_"+Symbol(),OBJPROP_COLOR,cl);
   ObjectCreate("Information_"+Symbol(),OBJ_LABEL,0,0,0);
//---
   int x,y;
   ChartTimePriceToXY(0,0,Time[0],Average_Price,x,y);
//---
   ObjectSet("Information_"+Symbol(),OBJPROP_XDISTANCE,220);
   ObjectSet("Information_"+Symbol(),OBJPROP_YDISTANCE,y);
  //---
   return(0);
  }
//+------------------------------------------------------------------+
