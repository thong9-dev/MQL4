//+------------------------------------------------------------------+
//|                              average_price and Loss line 2.0.mq4 |
//+------------------------------------------------------------------+
#property copyright "King"
#property indicator_chart_window
//---
extern int Equity_Me = 20000 ;
extern color font_color_AV = Blue;
extern color font_color_BE = Red;
extern int font_size=12;
extern color AV_color= Blue ;
extern color BE_color= Red ;

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
      ObjectDelete("BE_Price_Line_"+Symbol());
   ObjectDelete("Information_BE"+Symbol());
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
    ObjectDelete("BE_Price_Line_"+Symbol());
   ObjectDelete("Information_BE"+Symbol());
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
   double BE_Price;
   double distance;
   double distance_BE;
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
    ObjectDelete("BE_Price_Line_"+Symbol());  
   ObjectDelete("Information_BE"+Symbol());
//---
   if(Net_Trades>0 && Net_Lots!=0)
     {
      distance=(Net_Result/(MathAbs(Net_Lots*MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));
      distance_BE= (Equity_Me/(MathAbs(Net_Lots*MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));      
      if(Net_Lots>0)
        {
         Average_Price=Bid-distance;
         BE_Price= Average_Price - distance_BE ;
        }
      if(Net_Lots<0)
        {
         Average_Price=Ask+distance;
          BE_Price= Average_Price + distance_BE ;        
        }
     }
   if(Net_Trades>0 && Net_Lots==0)
     {
      distance=(Net_Result/((MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));
      distance_BE=(Equity_Me/((MarketInfo(Symbol(),MODE_TICKVALUE)))*MarketInfo(Symbol(),MODE_TICKSIZE));      
      Average_Price = Bid- distance;
      BE_Price= Average_Price - distance_BE ;
     }
   ObjectDelete("Average_Price_Line_"+Symbol());
   ObjectCreate("Average_Price_Line_"+Symbol(),OBJ_HLINE,0,0,Average_Price);
   ObjectSet("Average_Price_Line_"+Symbol(),OBJPROP_WIDTH,3);
   ObjectDelete("BE_Price_Line_"+Symbol());
   ObjectCreate("BE_Price_Line_"+Symbol(),OBJ_HLINE,0,0,BE_Price);
   ObjectSet("BE_Price_Line_"+Symbol(),OBJPROP_WIDTH,3);
   
///---
   color cl=AV_color;
   color BEcl=BE_color;  
   if(Net_Lots<0) cl=Red;
   if(Net_Lots==0) cl=White;
//---
   ObjectSet("Average_Price_Line_"+Symbol(),OBJPROP_COLOR,cl);
   ObjectCreate("Information_"+Symbol(),OBJ_LABEL,0,0,0);
   ObjectSet("BE_Price_Line_"+Symbol(),OBJPROP_COLOR,BEcl);
   ObjectCreate("Information_BE"+Symbol(),OBJ_LABEL,0,0,0);
//---
   int x,y;
   ChartTimePriceToXY(0,0,Time[0],Average_Price,x,y);
   ChartTimePriceToXY(0,0,Time[0],BE_Price,x,y);
//---

   ObjectSet("Information_"+Symbol(),OBJPROP_XDISTANCE,10);
   ObjectSet("Information_"+Symbol(),OBJPROP_YDISTANCE,20);
   ObjectSetText("Information_"+Symbol(),"Avrg = "+DoubleToStr(Average_Price,NrOfDigits)+"   Lots= "+Net_Lots+"  Orders = "+ Net_Trades ,font_size,"Arial",font_color_AV) ;
   
   
   ObjectSet("Information_BE"+Symbol(),OBJPROP_XDISTANCE,10);
   ObjectSet("Information_BE"+Symbol(),OBJPROP_YDISTANCE,45);
   ObjectSetText("Information_BE"+Symbol(),"Knock Out = "+DoubleToStr(BE_Price,NrOfDigits)+" " ,font_size,"Arial",font_color_BE);

//---
   return(0);
  }
//+------------------------------------------------------------------+
