//+------------------------------------------------------------------+
//|                                              Test_MarketTime.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>


#define M_Stage 0
#define M_Start 1
#define M_End 2

int Market[4][3];
string Market_Name[]={"Sydney","Tokyo","London","NewYok"};
int Market_TimeWarn[]={6,12,};
int IndexSave=-1,Bar=-1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//---
   Market[0][M_Start]=4;Market[0][M_End]=13;
   Market[1][M_Start]=7;Market[1][M_End]=16;
   Market[2][M_Start]=14;Market[2][M_End]=23;
   Market[3][M_Start]=19;Market[3][M_End]=4;
//---
   OnTick();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool FirstRun=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(_iNewBar(0) || !FirstRun)
     {
      string Text=TimeHour(TimeLocal())+" | "+TimeDayOfWeek(TimeLocal())+"\n";
      Text+="------\n";
      int Index=0,Cnt=0;

      TestMarketTime(TimeLocal(),Market[0][M_Start],Market[0][M_End]);

      if(!DayOff)
        {
         for(int i=0;i<4;i++)
           {
            Market[i][M_Stage]=TestMarketTime(TimeLocal(),Market[i][M_Start],Market[i][M_End]);
            Text+=Market_Name[i]+" : "+IntegerToString(Market[i][M_Stage])+"\n";
            //---
            if(Market[i][M_Stage]==1)
              {
               Cnt++;
               Index=i;
              }
           }
         Text+=c(Index)+" "+c(Cnt)+"\n";
        }
      else
        {
         Index=-1;
         Text+="DayOff\n";
        }

      Text+="------\n";

      if(IndexSave!=Index && Index>=0)
        {
         IndexSave=Index;
         string strMarket=Market_Name[IndexSave];
         if(Cnt>1)strMarket=Market_Name[IndexSave-1]+","+Market_Name[IndexSave];

         if(!FirstRun)
           {
            SendNotification("MarketOpen : "+strMarket);
            PlaySound("email.wav");
           }
         FirstRun=false;
        }

      if(Index<3) Text+=Market_Name[Index+1]+"\n";
      else  Text+=Market_Name[0]+"\n";

      Comment(Text);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DayOff=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TestMarketTime(datetime v,int Start,int End)
  {
   int HH=TimeHour(v);
   if(TimeDayOfWeek(v)>0)
     {
      if(Start>End)
        {
         if(TimeDayOfWeek(v)==6 && HH<End)
           {
            return 1;
           }
         else
           {
            DayOff=true;
            return 0;
           }
         if(HH>=Start || HH<End) return 1;
        }
      else if(HH>=Start && HH<End)
        {
         DayOff=false;
         return 1;
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
