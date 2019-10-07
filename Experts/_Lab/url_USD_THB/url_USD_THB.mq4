//+------------------------------------------------------------------+
//|                                                  url_USD_THB.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict

#include "include/internetlib.mqh"
MqlNet iMqlNet;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   printf("THB : "+THB(2));

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
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
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
double  THB(int digit)
  {
//+------------------------------------------------------------------+
   string Url="https://themoneyconverter.com/USD/THB.aspx";
   string getOpenURL="thai/url_USD_THB.html";
   iMqlNet.Open(Url,8080);
   iMqlNet.OpenURL(Url,getOpenURL,false);
//+------------------------------------------------------------------+
   string strStart="<td id=\"THB\">",strEnd="</td>";
   int iStart=StringFind(getOpenURL,strStart);
   string THB=StringSubstr(getOpenURL,iStart+StringLen(strStart));
   int iEnd=StringFind(THB,strEnd);
   THB=(iEnd!=0)?StringSubstr(THB,0,iEnd):"";
   
   string result[];
   int k=StringSplit(THB,StringGetCharacter(".",0),result);
   
   if(k>=2)
     {
      THB=(digit==0)?
          THB=result[0]:
          THB=result[0]+"."+StringSubstr(result[1],0,digit);
     }
   else
     {
      THB=result[0];
     }
   return double(THB);
  }
//+------------------------------------------------------------------+
