//+------------------------------------------------------------------+
//|                                                  LineNoti_EQ.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.1"
#property strict

//Token_Divas ::  ip5RPk5Cso9iLruE1O6dxJ1uLCa3rnIrBqV8oMtfFv5
extern string exTokenLine="";      //TokenLine
extern double EQUITY_Warning=0;                                               //Equity Warning
extern int   TimeNoti_Warning=60;                                             //Time Warning (Second)
extern double TimeNoti_Summarize=60;                                           //Time Summarize (Minute)
int TimeNoti_Summarize_=-1;
extern string ex1="____________________";                                     //____________________
extern string COMPANY_Nickname="";
//---

bool TestToken=false;
double ShortClock=0;
string  COMPANY;
long LOGIN=AccountInfoInteger(ACCOUNT_LOGIN);
string  CURRENCY=AccountInfoString(ACCOUNT_CURRENCY);
//---

int Active_Mem=-1;
int Active=-1,ActiveBuy=-1,ActiveSell=-1;
double Active_Hold=0,ActiveBuy_Hold=0,ActiveSell_Hold=0;
double Active_Lot=0,ActiveBuy_Lot=0,ActiveSell_Lot=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
//---
   ShortClock=10000;
   setTimeNoti_Summarize();

   COMPANY=(COMPANY_Nickname=="")?AccountInfoString(ACCOUNT_COMPANY):COMPANY_Nickname;

   int  r=ArrayResize(ORDER,(OrdersTotal()==0)?1:OrdersTotal(),0);

   for(int icnt=0;icnt<OrdersTotal();icnt++)
     {
      int Select=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      ORDER[icnt]=OrderTicket();
     }
//---

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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+

int ORDER[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   ShortClock++;
//---
//-----------------------------------------------------
   int Pending=-1,PendingBuy=-1,PendingSell=-1;
// 
   int cntAll=getCntOrder(0,Symbol(),
                          Active,ActiveBuy,ActiveSell,
                          Pending,PendingBuy,PendingSell,
                          Active_Hold,ActiveBuy_Hold,ActiveSell_Hold,
                          Active_Lot,ActiveBuy_Lot,ActiveSell_Lot);

   Active_Hold=NormalizeDouble(Active_Hold,2);
   ActiveBuy_Hold=NormalizeDouble(ActiveBuy_Hold,2);
   ActiveSell_Hold=NormalizeDouble(ActiveSell_Hold,2);

   if(Active_Mem!=Active)
     {
      printf("1 ---- ############################################ ");
      if(Active_Mem!=-1)
        {
         bool StateClose=Active_Mem>Active;
         printf("# StateClose : "+string(StateClose));

         //ORDER
         for(int i=0;i<OrdersTotal();i++)
           {
            int Select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            //
            for(int j=0;j<ArraySize(ORDER);j++)
              {
               if(ORDER[j]==OrderTicket())
                  ORDER[j]=0;
              }
           }

         //for(int j=0;j<ArraySize(ORDER);j++)
         //  {
         //   printf("A-"+j+" = "+ORDER[j]);
         //  }
         //printf("2----");
         if(OrdersTotal()>=2)
            ArraySort(ORDER);

         //for(int j=0;j<ArraySize(ORDER);j++)
         //  {
         //   printf("B-"+j+" = "+ORDER[j]);
         //  }
         //---
         if(StateClose)
           {
            //printf("3----");
            string LINE_OrderClose="⭕ OrderClose\n";
            LINE_OrderClose+="Broker : "+COMPANY+"\n";
            LINE_OrderClose+="Login : "+string(LOGIN)+"\n\n";

            for(int j=0;j<ArraySize(ORDER);j++)
              {
               if(ORDER[j]>0)
                 {
                  if(OrderSelect(ORDER[j],SELECT_BY_TICKET,MODE_HISTORY)==true)
                    {
                     printf("X "+string(OrderTicket()));
                     LINE_OrderClose+="Ticket : "+string(OrderTicket())+"\n";
                     LINE_OrderClose+="Symbol : "+OrderSymbol()+"\n";
                     LINE_OrderClose+="Order,Lot : "+OrderToStr(OrderType())+" "+DoubleToStr(OrderLots(),2)+"\n";
                     LINE_OrderClose+="Value : "+_Comma(OrderProfit(),2," ")+" "+CURRENCY+"\n.\n";
                    }
                  else
                    {
                     printf(" N ");
                    }
                 }
              }

            //---

            LineNotify(LINE_OrderClose);
           }
         //---

        }
      //printf("4----");
      //---
      //Modify

      int  r=ArrayResize(ORDER,(OrdersTotal()==0)?1:OrdersTotal(),0);
      //printf(r);

      for(int icnt=0;icnt<OrdersTotal();icnt++) // for loop
        {
         int Select=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
         ORDER[icnt]=OrderTicket();
         printf("ORDER-"+string(icnt)+" = "+string(ORDER[icnt]));

        }

      Active_Mem=Active;
      //---
     }

//-------- -------- -------- --------
   double _EQUITY=AccountInfoDouble(ACCOUNT_EQUITY);
   double _MARGIN_LEVEL=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
//---

   bool Warning=RoundClock(TimeNoti_Warning);
   bool Summari=RoundClock(TimeNoti_Summarize_);

//Summari=false;
//---

   bool exeEQUITY=_EQUITY<EQUITY_Warning;
//exeEQUITY=true;
//---

   if((Active>=1) && (Warning || Summari || TestToken))
     {
      if(exeEQUITY || Summari || TestToken)
        {
         string LINE="";
         LINE+=FlagEQ_LINE(exeEQUITY)+"\n";

         LINE+=(Summari)?"⭕ Summarize "+DoubleToStr(TimeNoti_Summarize,2)+" Minute":"⭕ "+IntegerToString(TimeNoti_Warning)+" Second";
         LINE+="\n";
         LINE+="Broker : "+COMPANY+"\n";
         LINE+="Login : "+_Comma(LOGIN,0," ")+"\n\n";


         //Comma(double v,int Digit,string zz)
         LINE+="Equity : "+_Comma(_EQUITY,2," ")+" "+CURRENCY+"\n";
         LINE+="MarginLV : "+_Comma(_MARGIN_LEVEL,2," ")+"\n";
         LINE+="\n";



         //---
         if(TestToken)
           {
            TestToken=false;
            LINE+="TestToken\n";
           }
         //---

         //printf(LINE);
         LineNotify(LINE);

        }

     }
   int Clock_H,Clock_M,Clock_S;

//---
   string CMM="";

   CMM+="\n "+"ShortClock"+" : "+string(ShortClock);
   CMM+="\n "+"--";
   CMM+="\n "+"TimeNoti_Warning"+" : "+string(TimeNoti_Warning)+"s "+string(Warning);
   CMM+="\n "+"TimeNoti_Summarize"+" : "+DoubleToStr(TimeNoti_Summarize,2)+"min | "+string(TimeNoti_Summarize_)+"s "+string(Summari);
   CMM+="\n "+"Quick money transfer"+" : "+string(exeEQUITY);
   CMM+="\n "+"--";
   CMM+="\n "+"CountOrder"+" : "+string(Active);
   Comment(CMM);
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
   if(id==CHARTEVENT_KEYDOWN)
     {
      printf("CHARTEVENT_KEYDOWN: "+string(lparam));
      if(!IsTesting())
        {
         //ConsoleWrite(string(lparam));
         if(lparam==9)
           {
            int  m=MessageBox(
                              "Want to test LineToken?",// message text 
                              "TestToken",  // box header 
                              MB_OKCANCEL   // defines set of buttons in the box 
                              );
            if(m==IDOK)
              {
               TestToken=true;
               OnTimer();
              }
           }
         OnTick();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setTimeNoti_Summarize()
  {
   string v=DoubleToStr(TimeNoti_Summarize,2);

   if(StringFind(v,".",0)>=1)
     {
      string result[];
      int k=StringSplit(v,StringGetCharacter(".",0),result);

      TimeNoti_Summarize_=(int(result[0])*60)+(int(result[1]));
     }
   else
     {
      TimeNoti_Summarize_=int(60*TimeNoti_Summarize);
     }

   printf("TimeNoti_Summarize_: "+string(TimeNoti_Summarize_));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RoundClock(int r)
  {
   return (MathMod(ShortClock,double(r))==0)?true:false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FlagEQ_LINE(bool b)
  {
   return (b)?
   "🔴🔴 Quick money transfer ❗❗":
   "✅ Equity";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderToStr(int OP)
  {
   switch(OP)
     {
      case  OP_BUY:        return "BUY";
      case  OP_SELL:       return "SELL";
      default:
         break;
     }
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LineNotify(string Massage)
  {
   int res=-1;
   if(exTokenLine!="")
     {
      string Headers,Content;
      char post[],result[];

      Headers="Authorization: Bearer "+exTokenLine+"\r\n";
      Headers+="Content-Type: application/x-www-form-urlencoded\r\n";

      Content="message="+Massage;

      int size=StringToCharArray(Content,post,0,WHOLE_ARRAY,CP_UTF8)-1;
      ArrayResize(post,size);

      res=WebRequest("POST","https://notify-api.line.me/api/notify",Headers,10000,post,result,Headers);

      //Print("Status code: ",res,",error: ",GetLastError());
      Print("Server response: ",string(res),CharArrayToString(result));
      if(res==-1)
        {
         string Mressage="#Not Allow WebRequest() !!\n";
         Mressage+="Tools-->Expert Advisors-->Allow Web\n";
         Mressage+="\" https://notify-api.line.me/api/notify \"";
         //Alert(Mressage);
        }
     }
   else
     {
      int rMessageBox=MessageBox("The token value is not set.","Token",MB_ICONQUESTION);
     }
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {
   v=NormalizeDouble(v,Digit);
   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= z;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }

   return temp3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getCntOrder(int iMN,string iOrderSymbol,
                int &aActive,int &aActiveBuy,int &aActiveSell,
                int &Pending,int &PendingBuy,int &PendingSell,
                double &aActive_Hold,double &aActiveBuy_Hold,double &aActiveSell_Hold,
                double &aActive_Lot,double &aActiveBuy_Lot,double &aActiveSell_Lot)

  {
   aActive_Hold=0;
   aActiveBuy_Hold=0;
   aActiveSell_Hold=0;

   aActive_Lot=0;
   aActiveBuy_Lot=0;
   aActiveSell_Lot=0;

   aActive=0;
   aActiveBuy=0;
   aActiveSell=0;

   Pending=0;
   PendingBuy=0;
   PendingSell=0;
//
   int cntOP_BUY=0;
   int cntOP_SELL=0;
   int cntOP_BUYLIMIT=0;
   int cntOP_SELLLIMIT=0;
   int cntOP_BUYSTOP=0;
   int cntOP_SELLSTOP=0;
//
   for(int icnt=0;icnt<OrdersTotal();icnt++) // for loop
     {
      int r=OrderSelect(icnt,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      //if(OrderSymbol()==iOrderSymbol && OrderMagicNumber()==iMN)
        {
         int Type=OrderType();
         if(Type<=1)
            aActive++;
         else
            Pending++;
         //
         double Hold=OrderProfit()+OrderSwap()+OrderCommission();
         double Lot=OrderLots();

         if(Type==OP_BUY){        cntOP_BUY++;aActiveBuy_Hold+=Hold;aActiveBuy_Lot+=Lot;}
         if(Type==OP_SELL){       cntOP_SELL++;aActiveSell_Hold+=Hold;aActiveSell_Lot+=Lot;}
         if(Type==OP_BUYLIMIT)   cntOP_BUYLIMIT++;
         if(Type==OP_SELLLIMIT)  cntOP_SELLLIMIT++;
         if(Type==OP_BUYSTOP)    cntOP_BUYSTOP++;
         if(Type==OP_SELLSTOP)   cntOP_SELLSTOP++;
        }
     }
//---

   aActive_Hold=aActiveBuy_Hold+aActiveSell_Hold;

   aActive_Lot=aActiveBuy_Lot-aActiveSell_Lot;
//
   aActiveBuy=cntOP_BUY;
   aActiveSell=cntOP_SELL;
   PendingBuy=cntOP_BUYLIMIT+cntOP_BUYSTOP;
   PendingSell=cntOP_SELLLIMIT+cntOP_SELLSTOP;
//
   return Active+Pending;
  }
//+------------------------------------------------------------------+
