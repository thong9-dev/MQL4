//+------------------------------------------------------------------+
//|                                                  LineNoti_EQ.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string exTokenLine="2ti8ZA2rAtBuZPhdzDLUFC64FD1cpdfSikCWXBXFvX5";

int   TimeNoti_Warning=30;
double TimeNoti_Summarize=1.45;
int TimeNoti_Summarize_=-1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int ShortClock=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   EventSetTimer(1);
//---
   setTimeNoti_Summarize();
//---

   ShortClock=0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+

void OnTimer()
  {
//---
   ShortClock++;
//---

   if(RoundClock(TimeNoti_Warning))
     {
      LineNotify("Test");
     }

   string CMM="";

   CMM+="\n "+"ShortClock"+" : "+string(ShortClock);
   CMM+="\n "+"--";
   CMM+="\n "+"TimeNoti_Warning "+" : "+string(TimeNoti_Warning)+"s "+RoundClock(TimeNoti_Warning);
   CMM+="\n "+"TimeNoti_Summarize "+" : "+string(TimeNoti_Summarize)+"min | "+string(TimeNoti_Summarize_)+"s "+RoundClock(TimeNoti_Summarize_);

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

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setTimeNoti_Summarize()
  {
   string v=string(TimeNoti_Summarize);

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
