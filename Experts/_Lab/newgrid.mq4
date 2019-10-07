//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Expert for tests"

extern double Lots=0.1;
extern int max_trades = 10;
extern int grid_lines = 30;
extern double RangeMid= 1.5465;
extern double grid_separation=0.0100;
extern double TP=50;

int BarCount;
int Current;
bool TickCheck=False;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() 
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() 
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() 
  {

   int Entertradebuy=0;
   int Entertradesell=0;
   double level;

   if(OrdersTotal()<max_trades)
     {
      for(int i=1; i<grid_lines; i++)

        {
         level=GlobalVariableGet("level");
         if(Ask==RangeMid-grid_separation*i && level!=RangeMid-grid_separation*i)
           {
            GlobalVariableSet("level",RangeMid-grid_separation*i);
            Entertradebuy=1;
            Print(level," and ",RangeMid-grid_separation*i);
           }
         if(Bid==RangeMid+grid_separation*i && level!=RangeMid+grid_separation*i)
           {
            GlobalVariableSet("level",RangeMid+grid_separation*i);
            Entertradesell=1;
            Print(level," and ",RangeMid+grid_separation*i);
           }
        }
     }


   if(Entertradebuy==1)
     {
      double Ticket1=OrderSend(Symbol(),OP_BUY,Lots,Ask,5,0,Ask+TP*Point,"Buy(#"+1+")",1,0,DodgerBlue);
     }

   if(Entertradesell==1)
     {
      double Ticket2=OrderSend(Symbol(),OP_SELL,Lots,Bid,5,0,Bid-TP*Point,"Sell(#"+1+")",1,0,DeepPink);
     }

   return(0);
  }
//+------------------------------------------------------------------+
