//+------------------------------------------------------------------+
//|                                                           MSR    |
//|                                      Copyright 2015, MSR corp    |
//|                                        http://www.msrcorp.net    |
//+------------------------------------------------------------------+
#property copyright "MSR Calc Profit Loss on LinePrice"
#property link      "http://ruforum.mt5.com/threads/71794-sovetnik-msr-3.0-multi-v-poiskah-tretey-volni?p=11799234&viewfull=1#post11799234"
#property version     "1.0"      
#property description "MSR Calc Profit Loss on LinePrice"
#property description "ฯ๎ โ๎๏๐๎๑เ์ ไ๎๐เแ๎๒๊่ ่ ๑๎๒๐๓ไํ่๗ๅ๑๒โเ ๎แ๐เ๙เ้๒ๅ๑:"
#property description "e-mail: complus@inbox.ru"
#property strict; 
//---- ยํๅ๘ํ่ๅ ๏เ๐เ์ๅ๒๐๛ ๑๎โๅ๒ํ่๊เ
extern string _Parameters_Trade="-------------"; // ฯเ๐เ์ๅ๒๐๛
extern int MAGIC=7;   // MagicNumber for calculate, -1 any Magic
extern string NL="LP";   // Name of Line
extern int fs=16;        // FontSize
extern color cm=clrRed;  // Color prof/loss
//---- ร๋๎แเ๋ํ๛ๅ ๏ๅ๐ๅ์ๅํํ๛ๅ ๑๎โๅ๒ํ่๊เ
double dt,ss;
string pl="";
//+------------------------------------------------------------------+
//| Expert start function                                            |
//+------------------------------------------------------------------+
void start()
  {
   Comment(ObjectsTotal()-1);
   for(int cnt=ObjectsTotal()-1; cnt>=0; cnt--)
     {
      string name=ObjectName(cnt);
      if(ObjectType(name)==OBJ_HLINE)
        {
         if(name==NL)
           {
            dt=ObjectGet(name,OBJPROP_PRICE1);
           }
        }
     }

//---
   if(dt>0)
     {
      ss=ProfitIFTakeInCurrency(1);
      if(ss>0){pl="+";}
      else{pl="";}
      string LM="Profit/Loss = "+pl+DoubleToStr(ss,2)+" "+AccountCurrency()+"----"+AccountProfit();
      Title(LM);
     }
//---

  }
//+------------------------------------------------------------------+
//|   Show Profit/Loss                                               |
//+------------------------------------------------------------------+
void Title(string Show)
  {
   string name_0="L_1";
   if(ObjectFind(name_0)==-1)
     {
      ObjectCreate(name_0,OBJ_LABEL,0,0,0);
      ObjectSet(name_0,OBJPROP_CORNER,0);
      ObjectSet(name_0,OBJPROP_XDISTANCE,390);
      ObjectSet(name_0,OBJPROP_YDISTANCE,50);
     }
   ObjectSetText(name_0,Show,fs,"Arial",cm);
  }
//+----------------------------------------------------------------------------+
//| ภโ๒๎๐: ส่์ ศใ๎๐ ย. aka KimIV,  http://www.kimiv.ru                        |
//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//| Calculation:                                                               |
//| mn - MagicNumber                ( -1  - ๋แ๎้ ์เใ่๊)                       |
//+----------------------------------------------------------------------------+
double ProfitIFTakeInCurrency(int mn)
  {
   mn=_MagicEncrypt(mn);
   //mn=-1;

   int    i, k=OrdersTotal(); // ฯ๎ไ๑๗ๅ๒ ๎๒๊๐๛๒๛๕ ๏๎็่๖่้
   double sum=0;                // ฯ๎ไ๑๗ๅ๒ ๑๒๎๏เ โ โเ๋๒ๅ ไๅ๏๎็่๒เ
//---
   double l=MarketInfo(Symbol(), MODE_LOTSIZE);
   double m=MarketInfo(Symbol(), MODE_PROFITCALCMODE);
   double p=MarketInfo(Symbol(), MODE_POINT);
   double t=MarketInfo(Symbol(),MODE_TICKSIZE);
   double v=MarketInfo(Symbol(),MODE_TICKVALUE);
//---
   for(i=0; i<k; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (mn<0 || OrderMagicNumber()==mn))
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               if(OrderType()==OP_BUY)
                 {
                  if(m==0) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();
                  if(m==1) sum+=(Bid-OrderOpenPrice())/p*v/t/l*OrderLots();
                  if(m==2) sum+=(Bid-OrderOpenPrice())/p*v*OrderLots();
                  sum+=OrderCommission()+OrderSwap();
                 }
               if(OrderType()==OP_SELL)
                 {
                  if(m==0) sum+=(OrderOpenPrice()-Ask)/p*v*OrderLots();
                  if(m==1) sum+=(OrderOpenPrice()-Ask)/p*v/t/l*OrderLots();
                  if(m==2) sum+=(OrderOpenPrice()-Ask)/p*v*OrderLots();
                  sum+=OrderCommission()+OrderSwap();
                 }
              }
           }
        }
     }
   return(sum);
  }
//+----------------------------------------------------------------------------+
int _MagicEncrypt(int Type)
  {
   string v=string(MAGIC)+string(Type);
   return int(v);
  }
//+------------------------------------------------------------------+
