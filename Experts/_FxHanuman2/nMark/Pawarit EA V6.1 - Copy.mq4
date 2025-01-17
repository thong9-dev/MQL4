//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
string lockaccount = "";

#property copyright "Copyright 2018, ThaiEa.com"
#property link      "http://www.thaiea.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

#define MAGICMA  20150309
//--- Inputs

input double Lots =0.1;
input int   Range=300; // Next order range (point)
input double LotsM=1.5; // Next Lots Multiply
input double Profit=5.0; // Profit (%)
input int   Magic_Number=888; // Magic Number
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   Comment("");
   if(ObjectFind("BG")>=0) ObjectDelete("BG");
   if(ObjectFind("BG1") >= 0) ObjectDelete("BG1");
   if(ObjectFind("BG2") >= 0) ObjectDelete("BG2");
   if(ObjectFind("BG3") >= 0) ObjectDelete("BG3");
   if(ObjectFind("BG4") >= 0) ObjectDelete("BG4");
   if(ObjectFind("BG5") >= 0) ObjectDelete("BG5");
   if(ObjectFind("NAME")>= 0) ObjectDelete("NAME");

//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenTradesForMNandPairType(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==sOrderSymbol)
        {
         if(OrderMagicNumber()==iMN)
           {
            retval++;
           }
        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalTradesForMNandPairType(string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==sOrderSymbol)
        {
         retval++;

        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseTradesForMNandPairType(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersHistoryTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_HISTORY);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==sOrderSymbol)
        {
         if(OrderMagicNumber()==iMN)
           {
            retval++;
           }
        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAll(double iMN)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();


   for(icnt=0;icnt<itotal;icnt++) // for loop
     {

      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_BUY)
        {
         Print(OrderMagicNumber());
         if(OrderMagicNumber()==iMN)
           {

            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
           }

        }
      else{}
     } // for loop

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseTrade(double iMN)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=itotal-1; icnt>=0; icnt--)
      //for(icnt=0;icnt<itotal;icnt++) // for loop
     {

      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_BUY)
        {
         //Print(OrderMagicNumber());
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {

            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
           }

        }
      else{}

     } // for loop

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseTrade1(double iMN)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=itotal-1; icnt>=0; icnt--)
      //for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_SELL)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
           }

        }
      else{}
     } // for loop
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseTrade2(double iMN)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_BUYLIMIT)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            OrderDelete(OrderTicket());
           }

        }
      else{}
     } // for loop

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseTrade3(double iMN)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_SELLLIMIT)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            OrderDelete(OrderTicket());
           }
        }
      else{}
     } // for loop
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalBuy(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if((OrderType()==OP_BUY)) 
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            retval++;
           }

        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalSell(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if((OrderType()==OP_SELL)) 
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            retval++;
           }

        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalBuyLimit(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if((OrderType()==OP_BUYLIMIT)) 
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            retval++;
           }

        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalSellLimit(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if((OrderType()==OP_SELLLIMIT)) 
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            retval++;
           }

        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalBuyStop(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if((OrderType()==OP_BUYSTOP)) 
        {
         if(OrderMagicNumber()==iMN)
           {
            retval++;
           }

        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalSellStop(double iMN,string sOrderSymbol)
  {
   int icnt,itotal,retval;
   retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if((OrderType()==OP_SELLSTOP)) 
        {
         if(OrderMagicNumber()==iMN)
           {
            retval++;
           }

        } // sOrderSymbol
     } // for loop

   return(retval);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int bs=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   static int BarsCount=0;

   if(lockaccount!="")
     {
      if((lockaccount!=AccountNumber()))
        {
         Alert("Invalid account! Please contact admin!");
         return(0);
        }
      else{}
     }
   else{}

   double max;
   double min;

   double lot=Lots;
   int    spread = MarketInfo(Symbol(),MODE_SPREAD);
   double profit = 0;
   double stoploss= 0;
   double sprofit = 0;
   double sstoploss=0;
   int TS=0;

   int zz = 0;
   int l3 = 0;
   int ticket;
   int total,total1;

   if(0.01==MarketInfo(0,MODE_MINLOT))
     {
      lot=NormalizeDouble(lot,2);

      if(lot<0.01){lot=0.01;}
      else{}
     }
   else if(0.1==MarketInfo(0,MODE_MINLOT))
     {
      lot=NormalizeDouble(lot,1);

      if(lot<0.1){lot=0.1;}
      else{}
     }
   else if(1.0==MarketInfo(0,MODE_MINLOT))
     {
      lot=NormalizeDouble(lot,0);

      if(lot<1.0){lot=1.0;}
      else{}
     }
   else{}

   dshow();

   if(TotalProfit()/AccountBalance()*100.0>=Profit)
     {
      CloseTrade(Magic_Number);
      CloseTrade1(Magic_Number);
      CloseTrade2(Magic_Number);
      CloseTrade3(Magic_Number);
     }
   else{}

   double bal=AccountBalance();
   double bal2 = AccountEquity();
   double bal3 = AccountMargin();

   total=OpenTradesForMNandPairType(Magic_Number,Symbol());

//---

   if((total<1))
     {
      OrderSend(Symbol(),OP_BUYLIMIT,lot,Bid - Point*Range*0.5,3,stoploss,profit,"",Magic_Number,0,Green);
      OrderSend(Symbol(),OP_SELLLIMIT,lot,Bid+ Point*Range*0.5,3,sstoploss,sprofit,"",Magic_Number,0,Red);
     }
   else
     {
      if(TotalBuyLimit(Magic_Number,Symbol())==0)
        {
         getlastorderbuy(Symbol());

         if((OrderType()==OP_BUY) && OrderSymbol()==Symbol() && (OrderMagicNumber()==Magic_Number))
           {
            OrderSend(Symbol(),OP_BUYLIMIT,OrderLots()*LotsM,OrderOpenPrice()-Point*Range,3,stoploss,profit,"",Magic_Number,0,Green);
           }
        }

      if(TotalSellLimit(Magic_Number,Symbol())==0)
        {
         getlastordersell(Symbol());

         if((OrderType()==OP_SELL) && OrderSymbol()==Symbol() && (OrderMagicNumber()==Magic_Number))
           {
            OrderSend(Symbol(),OP_SELLLIMIT,OrderLots()*LotsM,OrderOpenPrice()+Point*Range,3,sstoploss,sprofit,"",Magic_Number,0,Red);
           }
        }
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+

void dshow() 
  {

   Comment(""
           +"Pawarit EA"
           +"\n"
           +"======================="
           +"\n"
           +"ACCOUNT INFORMATION"
           +"\n"
           +"-----------------------------------------------------"
           +"\n"
           +"Account Number:             "+AccountNumber()
           +"\n"
           +"Account Leverage:           1:"+DoubleToStr(AccountLeverage(),0)
           +"\n"
           +"Account Balance:             "+DoubleToStr(AccountBalance(),2)
           +"\n"
           +"Account Equity:               "+DoubleToStr(AccountEquity(),2)
           +"\n"
           +"Server Time:                   "+TimeToStr(TimeCurrent(),TIME_SECONDS)
           +"\n"
           +"======================="+"\n"
           +"Successfully"
           );

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getlastorderbuy(string sym)
  {
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym)) 
        {
         if((OrderType()==OP_BUY))
           {
            break;
           }
         else{}
        }
      else{}
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getlastordersell(string sym)
  {
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym)) 
        {
         if((OrderType()==OP_SELL))
           {
            break;
           }
         else{}
        }
      else{}
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void modifybuyorder(double tp,string sym)
  {
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym)) 
        {
         if((OrderType()==OP_BUY) && (tp!=OrderTakeProfit()))
           {
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0);
           }
         else{}
        }
      else{}
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void modifysellorder(double tp,string sym)
  {
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym)) 
        {
         if((OrderType()==OP_SELL) && (tp!=OrderTakeProfit()))
           {
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0);
           }
         else{}
        }
      else{}
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalProfit()
  {
   int icnt,itotal;
   double pf=0.0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(((OrderType()==OP_BUY) || (OrderType()==OP_SELL))) 
        {
         if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==Symbol()))
           {
            pf+=OrderProfit();

           }
        } // sOrderSymbol
     } // for loop
//  Print(sym+"//"+profit);
   return(NormalizeDouble(pf,2));
  }  
//+------------------------------------------------------------------+
