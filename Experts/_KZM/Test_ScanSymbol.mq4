//+------------------------------------------------------------------+
//|                                              Test_ScanSymbol.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketWatch=false;
int MarketMax=SymbolsTotal(MarketWatch),CNT=0;
string _str_List="",_str_Temp1,_str_Temp2,_str_Temp;
string MarketName[200],MarketTemp_Name;
double MarketSwap[200],Temp_Swap;

string MarketToText_Buy,MarketToText_Sell;
int iPeriod=120;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   _setTemplate();
//setText();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   setText(MarketToText_Buy);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   CNT=0;_str_List="\nName/Swap/Spread/HL/Range/Discount";
//printf("_____");
   _str_Temp1="";
   _str_Temp2="";
//---
   int find_Spread=1000;
//---
   MarketToText_Buy="";
   for(int i=0;i<MarketMax;i++)
     {
      string Symbol_=SymbolName(i,MarketWatch);
      if(MarketInfo(Symbol_,MODE_TRADEALLOWED)==1)
        {
         string MainSymbol=StringSubstr(Symbol_,0,3);
         string SecondSymbol=StringSubstr(Symbol_,3,3);

         double Swap_Buy=SymbolInfoDouble(Symbol_,SYMBOL_SWAP_LONG);
         double Swap_Sell=SymbolInfoDouble(Symbol_,SYMBOL_SWAP_SHORT);

         double Spread_=MarketInfo(Symbol_,MODE_SPREAD);
         int digit=int(MarketInfo(Symbol_,MODE_DIGITS));
         double Base=MathPow(10,double(digit));

         if(Swap_Buy>0 && 
            Spread_<=find_Spread)
           {

            Symbol_iHL(Symbol_,iPeriod,digit);

            //---
            MarketToText_Buy+=Symbol_+"\n";
            _str_Temp="\n"+Symbol_
                      +" | "+string(Swap_Buy)
                      +"/"+string(Spread_)
                      +" | "+DoubleToString(SymHigh,digit)+"v/"+DoubleToString(SymLow,digit)+"v["+DoubleToString(SymPeriodAVG,1)+"y]"
                      +" | "+Comma((MarketInfo(Symbol_,MODE_BID)-SymLow)*Base,0,",")+"p/"+Symbol_Discount(Symbol_,SymHigh,SymLow)+"%";
            _str_Temp1+=_str_Temp;
            //printf(_str_Temp);
            //---
            MarketName[CNT]=SymbolName(i,MarketWatch);
            MarketSwap[CNT]=Swap_Buy;
            CNT++;
           }
         //---
         _str_Temp="";
         if(Swap_Sell>0 && 
            Spread_<=find_Spread)
           {

            Symbol_iHL(Symbol_,iPeriod,digit);

            //---
            _str_Temp="\n"+Symbol_
                      +" | "+string(Swap_Sell)
                      +"/"+string(Spread_)
                      +" | "+DoubleToString(SymHigh,digit)+"v/"+DoubleToString(SymLow,digit)+"v["+DoubleToString(SymPeriodAVG,1)+"y]"
                      +" | "+Comma((MarketInfo(Symbol_,MODE_BID)-SymLow)*Base,0,",")+"p/"+Symbol_Discount(Symbol_,SymHigh,SymLow)+"%";
            _str_Temp2+=_str_Temp;
            //printf(_str_Temp);
            //---
            //Name[CNT]=SymbolName(i,MarketWatch);
            //Swap[CNT]=Swap_Sell;
            //CNT++;
           }
        }
     }
   _str_List+="\nBuy"+_str_Temp1+"\n--- Sell"+_str_Temp2;

//---
/*for(int i=0;i<CNT;i++)
     {
      for(int j=0;j<CNT;j++)
        {
         if(Swap[j]<Swap[j+1])
           {
            Temp_Swap=Swap[j];
            Temp_Name=Name[j];

            Swap[j]=Swap[j+1];
            Name[j]=Name[j+1];

            Swap[j+1]=Temp_Swap;
            Name[j+1]=Temp_Name;
           }
        }
     }*/
   for(int i=0;i<CNT;i++)
     {
      //n_str+="\n"+Name[i]+" "+Swap[i];
      //n_str+="\n"+string(Swap[i]);
     }

   Comment("CNT : "+string(CNT)+"/"+string(MarketMax)+" | Period : "+string(iPeriod)+
           "\n"+_str_List);
   Comment("Test");
   _LabelSet("Text_MPV",CORNER_LEFT_LOWER,10,40,clrYellow,"Franklin Gothic Medium Cond",10,MarketToText_Buy,"");
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
/*string Comma(double v,int Digit,string zz)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= zz;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }
   return temp3;
  }*/
//+------------------------------------------------------------------+
double SymHigh;
double SymLow;
double SymPeriodAVG;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Symbol_iHL(string sym,int n,int digit)
  {

   double Max_=-99999999,Min_=99999999;
//---
   if(n>=0)
     {
      for(int i=0;i<=n;i++)
        {
         SymHigh=iHigh(sym,PERIOD_MN1,i);
         SymLow=iLow(sym,PERIOD_MN1,i);

         if(SymHigh>Max_)
            Max_=SymHigh;

         if(SymLow<Min_)
            Min_=SymLow;
        }
     }
   else
     {
      n=iBars(sym,PERIOD_MN1);
      for(int i=0;i<=n;i++)
        {
         SymHigh=iHigh(sym,PERIOD_MN1,i);
         if(SymHigh>Max_)
            Max_=SymHigh;
        }
      Min_=0;
     }

   SymPeriodAVG=n/12;
   SymHigh=NormalizeDouble(Max_,digit);
   SymLow=NormalizeDouble(Min_,digit);
  }
//+------------------------------------------------------------------+
string Symbol_Discount(string sym,double high,double low)
  {
   double A=MarketInfo(sym,MODE_BID)-low;
   double B=high-low;

   if(B==0)
     {
      B=1;
     }

   return DoubleToString((A/B)*100,3);
  }
//+------------------------------------------------------------------+
double _getOrderCNT_Ative(string sym,int n,string mode)
  {
   double sum=0;
//---
   double _mode=MarketInfo(sym,MODE_PROFITCALCMODE); //Profit calculation mode. 0 - Forex; 1 - CFD; 2 - Futures
   double l=MarketInfo(sym,MODE_LOTSIZE);
   double p=MarketInfo(sym,MODE_POINT);
   double t=MarketInfo(sym,MODE_TICKSIZE);
   double v=MarketInfo(sym,MODE_TICKVALUE);
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(_mode==0) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();//Forex

      if(_mode==1) sum+=(Bid-OrderOpenPrice())/p*v/t/l*OrderLots();//CFD
      if(_mode==2) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();//Futures
      sum+=OrderCommission()+OrderSwap();
     }
   return -1;
  }
//+------------------------------------------------------------------+
void _setTemplate()
  {
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,false);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);

   ChartSetInteger(0,CHART_COLOR_GRID,clrBlack);

   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);

   ChartSetInteger(0,CHART_COLOR_ASK,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrBlack);
   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
  }
//+------------------------------------------------------------------+
void setText(string Text)
  {
//--- incorrect file opening method 
   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
//string filename=terminal_data_path+"\\MQL4\\Files\\"+"fractals.csv";
/* int filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV);
   if(filehandle<0)
     {
      Print(cI(__LINE__)+" Failed to open the file by the absolute path ");
      Print(cI(__LINE__)+" Error code ",GetLastError());
     }

//--- correct way of working in the "file sandbox" 
   ResetLastError();
/*filehandle=FileOpen("fractals.csv",FILE_WRITE|FILE_CSV);
   if(filehandle!=INVALID_HANDLE)
     {
      FileWrite(filehandle,TimeCurrent(),Symbol(),EnumToString(ENUM_TIMEFRAMES(_Period)));
      FileClose(filehandle);
      Print("FileOpen OK");
     }
   else Print("Operation FileOpen failed, error ",GetLastError());*/

//--- another example with the creation of an enclosed directory in MQL4\Files\ 
   string subfolder="Research"+"\\fractals2.set";
   int filehandle=FileOpen(subfolder,FILE_WRITE|FILE_CSV);
   if(filehandle!=INVALID_HANDLE)
     {
      FileWrite(filehandle,Text);
      FileClose(filehandle);
      Print(cI(__LINE__)+" created "+terminal_data_path+"\\"+subfolder);
     }
   else
      Print(cI(__LINE__)+" File open failed, error ",GetLastError());

  }
//+------------------------------------------------------------------+
