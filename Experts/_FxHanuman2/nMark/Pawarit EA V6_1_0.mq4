//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
string lockaccount="";

#property copyright "Copyright 3-2019, FxHanuman.com"
#property link      "http://www.FxHanuman.com"
#property version   "1.00"
#property description "2 Way Grid - Forward Pending Bet non-MM"
#property strict

#include <stdlib.mqh>

#define MAGICMA  20150309
//--- Inputs

input double Lots=0.01;
input double Budget=500;
double BudgetRate=-1;

input double Profit=5.0; // Profit (%)
input double CutLossMultiple=3; // CutLossMultiple

input int   Range=300; // Next order range (point)
input double LotsM=1.5; // Next Lots Multiply
input int   Magic_Number=888; // Magic Number

bool Reverse=false;
input bool NextRound=true;
bool Freeze=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BudgetStep_Con=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
//----
   BudgetRate=NormalizeDouble(Budget*(Profit/100),2);
   ConditionCutAll(0);

   iComment();

//for(int i=0,j=500;i<10;i++,j+=100)
//  {
//   printf(j+"|"+BudgetStep(j));
//  }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int bs=0;
int total;
int Cnt_Active=0,Cnt_Pending=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   static int BarsCount=0;

   if(lockaccount!="")
     {
      if((lockaccount!=string(AccountNumber())))
        {
         Alert("Invalid account! Please contact admin!");
         return(0);
        }
      else
        {
        }
     }
   else
     {
     }

//double max;
//double min;

   double lot=Lots;
//int    spread = int(MarketInfo(Symbol(),MODE_SPREAD));
   double profit=0;
   double stoploss= 0;
   double sprofit = 0;
   double sstoploss=0;
   int TS=0;
//---
   int zz = 0;
   int l3 = 0;
//int ticket;
//int total1;
//---

   if(0.01==MarketInfo(NULL,MODE_MINLOT))
     {
      lot=NormalizeDouble(lot,2);

      if(lot<0.01)
        {
         lot=0.01;
        }
     }
   else if(0.1==MarketInfo(NULL,MODE_MINLOT))
     {
      lot=NormalizeDouble(lot,1);

      if(lot<0.1)
        {
         lot=0.1;
        }
     }
   else if(1.0==MarketInfo(NULL,MODE_MINLOT))
     {
      lot=NormalizeDouble(lot,0);

      if(lot<1.0)
        {
         lot=1.0;
        }
     }

   Cnt_Active=0;
   Cnt_Pending=0;

   OpenTradesForMNandPairType(Magic_Number,Symbol(),Cnt_Active,Cnt_Pending);

   total=Cnt_Active+Cnt_Pending;

   iComment();

   if(Cnt_Active>0)
     {
      if(ConditionCutAll(total))
        {
         CloseTrade(Magic_Number);
         CloseTrade1(Magic_Number);
         CloseTrade2(Magic_Number);
         CloseTrade3(Magic_Number);
        }
      else
        {
        }
     }

//double bal=AccountBalance();
//double bal2 = AccountEquity();
//double bal3 = AccountMargin();

//---
   int OS=-1;
   int Dir=-1;
   double OP=-1;

   if(total<1)
     {
      BudgetStep_Con=BudgetStep();
      
      if(NextRound)
        {
         double _Lot=NormalizeDouble(lot*BudgetStep_Con,2);
         //
         _Lot=(_Lot<MarketInfo(Symbol(),MODE_MINLOT))?0:_Lot;
         printf(_Lot);
         //
         if(_Lot>0)
           {
            OS=OrderSend(Symbol(),OP_BUYLIMIT,_Lot,Bid - Point*Range*0.5,3,stoploss,profit,"Pawarit EA 0",Magic_Number,0,Green);
            OS=OrderSend(Symbol(),OP_SELLLIMIT,_Lot,Bid+ Point*Range*0.5,3,sstoploss,sprofit,"Pawarit EA 0",Magic_Number,0,Red);
           }
        }
        
     }
   else
     {
      if(TotalBuyLimit(Magic_Number,Symbol())==0)
        {
         getLastOrderBuy(Symbol());

         if((OrderType()==OP_BUY) && OrderSymbol()==Symbol() && (OrderMagicNumber()==Magic_Number))
           {
            OS=OrderSend(Symbol(),OP_BUYLIMIT,OrderLots()*LotsM,OrderOpenPrice()-Point*Range,3,stoploss,profit,"Pawarit EA",Magic_Number,0,Green);
           }
        }

      if(TotalSellLimit(Magic_Number,Symbol())==0)
        {
         getLastOrderSell(Symbol());

         if((OrderType()==OP_SELL) && OrderSymbol()==Symbol() && (OrderMagicNumber()==Magic_Number))
           {
            OS=OrderSend(Symbol(),OP_SELLLIMIT,OrderLots()*LotsM,OrderOpenPrice()+Point*Range,3,sstoploss,sprofit,"Pawarit EA",Magic_Number,0,Red);
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void iComment()
  {
//if(false)
     {
      double NetProfits=AccountBalance()-Budget;
      double NetProfits_Percent=(NetProfits/Budget)*100;
      
      Comment(""
              +"Pawarit EA"
              //+"\n ======================="
              //+"\n Server Time:                   "+TimeToStr(TimeCurrent(),TIME_SECONDS)
              +"\n -----------------------------------------------------"
              +"\n Account Number:             "+string(AccountNumber())+" [1:"+DoubleToStr(AccountLeverage(),0)+"]"
              +"\n Account Balance:             "+DoubleToStr(AccountBalance(),2)+" [ "+string(BudgetStep_Con)+" ]"
              +"\n Account Equity:               "+DoubleToStr(AccountEquity(),2)
              +"\n Lots:                              "+DoubleToStr(Lots,2)+" ["+DoubleToStr(Lots*BudgetStep_Con,2)+"]"
              +"\n ======================="
              +"\n TotalOrder:                    "+string(total)+" ["+string(Cnt_Active)+","+string(Cnt_Pending)+"]"
              +"\n Holding:                        "+DoubleToStr(TotalProfit(),2)+" ["+string(BudgetStep_Con)+"]"
              +"\n CutAmount:                   "+DoubleToStr(CutTheAmount,2)
              +"\n                                    ="
              +"\n Net-Profit:                    "+DoubleToStr(NetProfits,2)+" [ "+DoubleToStr(NetProfits_Percent,2)+"% ]"
              +"\n ======================="
              );
     }
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
void OpenTradesForMNandPairType(double iMN,string sOrderSymbol,int &Active,int &Pending)
  {
   int icnt,itotal;
//retval=0;
   itotal=OrdersTotal();

   for(icnt=0;icnt<itotal;icnt++) // for loop
     {
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==sOrderSymbol)
        {
         if(OrderMagicNumber()==iMN)
           {
            if(OrderType()<1)
              {
               Active++;
              }
            else
              {
               Pending++;
              }
            //retval++;
           }
        } // sOrderSymbol
     } // for loop

//return(retval);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_HISTORY);
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

      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_BUY)
        {
         Print(OrderMagicNumber());
         if(OrderMagicNumber()==iMN)
           {

            bool r2=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
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

      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_BUY)
        {
         //Print(OrderMagicNumber());
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {

            int r2=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_SELL)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            int r2=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_BUYLIMIT)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            r=OrderDelete(OrderTicket());
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      int type=OrderType();
      if(type==OP_SELLLIMIT)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==iMN)
           {
            int r2=OrderDelete(OrderTicket());
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
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
//|                                                                  |
//+------------------------------------------------------------------+
void getLastOrderBuy(string sym)
  {
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      int r=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym))
        {
         if((OrderType()==OP_BUY))
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getLastOrderSell(string sym)
  {
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      int r=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym))
        {
         if((OrderType()==OP_SELL))
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void modifybuyorder(double tp,string sym)
  {
   for(int i=(OrdersTotal()-1); i>=0; i --)
     {
      int r=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym))
        {
         if((OrderType()==OP_BUY) && (tp!=OrderTakeProfit()))
           {
            r=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0);
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
      int r=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==sym))
        {
         if((OrderType()==OP_SELL) && (tp!=OrderTakeProfit()))
           {
            r=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0);
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
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(((OrderType()==OP_BUY) || (OrderType()==OP_SELL)))
        {
         if((OrderMagicNumber()==Magic_Number) && (OrderSymbol()==Symbol()))
           {
            pf+=OrderProfit()+OrderCommission()+OrderSwap();

           }
        } // sOrderSymbol
     } // for loop
//  Print(sym+"//"+profit);
   return(NormalizeDouble(pf,2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CutTheAmount=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ConditionCutAll(int totals)
  {
//if(TotalProfit()/AccountBalance()*100.0>=Profit)
   CutTheAmount=BudgetRate*BudgetStep_Con;
   if(totals>2 && CutTheAmount>0)
     {
      double Hoding=TotalProfit();
      if(Hoding>=CutTheAmount)
        {
         printf("ConditionCutAll A");
         return true;
        }
      if(Hoding<=CutTheAmount*(CutLossMultiple*-1))
        {
         printf("ConditionCutAll B");
         Freeze=true;
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double BudgetStep()
  {
   double rate=AccountBalance()/Budget;
   printf("BudgetStep: "+DoubleToStr(rate,2));
   if(rate<=0)
     {

      return NormalizeDouble(rate,2);
     }
   return double(int(rate));
  }
//+------------------------------------------------------------------+
