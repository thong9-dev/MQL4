//+------------------------------------------------------------------+
//|                                  clusterbox_dayhistogramm_ad.mq4 |
//|                                        Copyright 2015, Scriptong |
//|                                          http://advancetools.net |
//+------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property description "English: Displays the ticks volume by days in the form histogram of clusters.\nRussian: Îòîáðàæåíèå òèêîâûõ îáúåìîâ ïî äíÿì â âèäå ãèñòîãðàììû êëàñòåðîâ."
#property strict

#property indicator_chart_window
#property indicator_buffers 1

#define MAX_VOLUMES_SHOW      5                                                                    // Êîëè÷åñòâî óðîâíåé ìàêñèìàëüíîãî îáúåìà, êîòîðûå ñëåäóåò îòîáðàæàòü
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct LevelVolumeColor                                                                            // Ñòðóêòóðà ñîîòâåòñòâèÿ óðîâíåé îáúåìà, äîñòèæåíèå êîòîðûõ íà öåíîâîì óðîâíå îòîáðàæàåòñÿ.. 
  {                                                                                                // ..ñîîòâåòñòâóþùèì öâåòîì
   color             levelColor;
   int               levelMinVolume;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TickStruct                                                                                  // Ñòðóêòóðà äëÿ çàïèñè äàííûõ îá îäíîì òèêå
  {
   datetime          time;
   double            bid;
   double            ask;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ViewRange                                                                                   // Ñòðóêòóðà äëÿ çàïèñè ãðàíèö èíòåðâàëà îòîáðàæåíèÿ ãèñòîãðàììû
  {
   datetime          leftTime;
   datetime          rightTime;
   int               rightIndex;
   int               rangeDuration;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct LevelsData                                                                                  // Ñòðóêòóðà äëÿ çàïèñè öåíîâîãî óðîâíÿ, êîëè÷åñòâà åãî ïîâòîðåíèé, ðîñòà è ïàäåíèÿ öåíû íà èíòåðâàëå îòîáðàæåíèÿ ãèñòîãðàììû
  {
   double            price;
   int               repeatCnt;
   int               bullsCnt;
   int               bearsCnt;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_YESNO
  {
   YES,                                                                                           // Yes / Äà
   NO                                                                                             // No / Íåò
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_LINEWIDTH                                                                                // Òîëùèíà ëèíèé ãèñòîãðàììû
  {
   LINEWIDTH_NULL,                                                                                 // Most thin / Íàèáîëåå òîíêàÿ
   LINEWIDTH_ONE,                                                                                  // Thin / Òîíêàÿ
   LINEWIDTH_TWO,                                                                                  // Median / Ñðåäíÿÿ
   LINEWIDTH_THREE,                                                                                // Thick / Òîëñòàÿ
   LINEWIDTH_FOUR                                                                                  // Most thick / Íàèáîëåå òîëñòàÿ
  };

// Íàñòðîå÷íûå ïàðàìåòðû èíäèêàòîðà
input int      i_pointsInBox           = 50;                                                       // Points in one cluster / Êîëè÷åñòâî ïóíêòîâ â îäíîì êëàñòåðå
input string   i_string1               = "Min volumes and colors / Ìèí. îáúåìû è öâåòà";           // ==============================================
input int      i_minVolumeLevel1       = 1;                                                        // Minimal volume. Level 1 / Ìèíèìàëüíûé îáúåì. Óðîâåíü 1
input color    i_colorLevel1           = clrSkyBlue;                                               // Color of level 1 / Öâåò óðîâíÿ 1
input int      i_minVolumeLevel2       = 50;                                                       // Minimal volume. Level 2 / Ìèíèìàëüíûé îáúåì. Óðîâåíü 2
input color    i_colorLevel2           = clrTurquoise;                                             // Color of level 2 / Öâåò óðîâíÿ 2
input int      i_minVolumeLevel3       = 75;                                                       // Minimal volume. Level 3 / Ìèíèìàëüíûé îáúåì. Óðîâåíü 3
input color    i_colorLevel3           = clrRoyalBlue;                                             // Color of level 3 / Öâåò óðîâíÿ 3
input int      i_minVolumeLevel4       = 100;                                                      // Minimal volume. Level 4 / Ìèíèìàëüíûé îáúåì. Óðîâåíü 4
input color    i_colorLevel4           = clrBlue;                                                  // Color of level 4 / Öâåò óðîâíÿ 4
input int      i_minVolumeLevel5       = 150;                                                      // Minimal volume. Level 5 / Ìèíèìàëüíûé îáúåì. Óðîâåíü 5
input color    i_colorLevel5           = clrMagenta;                                               // Color of level 5 / Öâåò óðîâíÿ 5
input string   i_string2               = "Delta of volumes / Äåëüòû îáúåìîâ";                      // ==============================================
input ENUM_YESNO i_isShowDelta         = YES;                                                      // Show the delta of volumes? / Îòîáðàæàòü äåëüòó îáúåìîâ?
input color    i_bullDeltaColor        = clrLime;                                                  // Color of line price growth / Öâåò ëèíèè ðîñòà öåíû
input color    i_bearDeltaColor        = clrRed;                                                   // Color of line fall in prices / Öâåò ëèíèè ïàäåíèÿ öåíû
input string   i_string3               = "Ïàðàìåòðû ãðàôèêà";                                      // ==============================================
input ENUM_LINEWIDTH i_lineWidth       = LINEWIDTH_THREE;                                          // Histogram thickness / Òîëùèíà ëèíèè ãèñòîãðàììû
input ENUM_YESNO i_point5Digits        = YES;                                                      // Use 5-digits in prices? / Èñïîëüçîâàòü 5-çíà÷íîå ïðåäñòàâëåíèå êîòèðîâîê?
input int      i_indBarsCount=10000;                                                               // Number of bars to display / Êîë-âî áàðîâ îòîáðàæåíèÿ

                                                                                                   // Ïðî÷èå ãëîáàëüíûå ïåðåìåííûå èíäèêàòîðà
bool              g_activate;                                                                      // Ïðèçíàê óñïåøíîé èíèöèàëèçàöèè èíäèêàòîðà

int               g_curDayNumber,// Íîìåð â ãîäó äëÿ òåêóùåãî îáðàáàòûâàåìîãî äíÿ
g_pointMultiply;                                                                 // Ìíîæèòåëü âåëè÷èíû ïóíêòà, èñïîëüçóþùèéñÿ ïðè ðàáîòå íà 5-çíà÷íûõ êîòèðîâêàõ

double            g_point;

datetime          g_curDayStart;                                                                   // Âðåìÿ îòêðûòèÿ äíÿ, äëÿ êîòîðîãî ñîáèðàþòñÿ òèêîâûå äàííûå

TickStruct        g_ticks[];                                                                       // Ìàññèâ äëÿ õðàíåíèÿ òèêîâ, ïîñòóïèâøèõ ïîñëå íà÷àëà ðàáîòû èíäèêàòîðà                    
LevelVolumeColor  g_volumeLevelsColor[MAX_VOLUMES_SHOW];                                           // Ìàññèâ îáúåìîâ è, ñîîòâåòñòâóþùèõ èì, öâåòîâ óðîâíåé
LevelsData        g_levelsData[];                                                                  // Ðàáî÷èé ìàññèâ óðîâíåé, â êîòîðûé çàïèñûâàåòñÿ êîëè÷åñòâî òèêîâ, ïîïàâøèõ íà ñîîòâåòñòâóþùóþ öåíó

#define PREFIX "CLSTRBXDH_"                                                                        // Ïðåôèêñ èìåíè ãðàôè÷åñêèõ îáúåêòîâ, îòîáðàæàåìûõ èíäèêàòîðîì 
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   g_activate=false;                                                                             // Èíäèêàòîð íå èíèöèàëèçèðîâàí

   if(!IsTuningParametersCorrect()) // Íåâåðíî óêàçàííûå çíà÷åíèÿ íàñòðîå÷íûõ ïàðàìåòðîâ - ïðè÷èíà íåóäà÷íîé èíèöèàëèçàöèè
      return INIT_FAILED;

   if(!IsLoadTempTicks()) // Çàãðóçêà äàííûõ î òèêàõ, ñîõðàíåííûõ çà ïðåäûäóùèé ïåðèîä ðàáîòû èíäèêàòîðà   
      return INIT_FAILED;

   CreateVolumeColorsArray();                                                                      // Êîïèðîâàíèå äàííûõ î öâåòå è âåëè÷èíå óðîâíåé â ìàññèâ

   if(Period()>=PERIOD_D1)
      Print(WindowExpertName(),": èíäèêàòîð íå îòîáðàæàåò äàííûå íà òàéìôðåéìàõ D1 è ñòàðøå.");
   else
      g_activate=true;                                                                           // Èíäèêàòîð óñïåøíî èíèöèàëèçèðîâàí
//---
//if(!g_activate) // Åñëè â ïðîöåññå ðàáîòû èíäèêàòîðà âîçíèêëà îøèáêà, òî ðàáîòàòü ïðîãðàììà íå äîëæíà
//   return rates_total;

   int total;
//int limit=GetRecalcIndex(total,rates_total,prev_calculated);                                // Ñ êàêîãî áàðà íà÷èíàòü îáíîâëåíèå?

   ShowIndicatorData(1000,total);                                                                // Îòîáðàæåíèå äàííûõ èíäèêàòîðà
   WindowRedraw();
//---

   return INIT_SUCCEEDED;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ïðîâåðêà êîððåêòíîñòè íàñòðîå÷íûõ ïàðàìåòðîâ                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
  {
   string name=WindowExpertName();

   int period= Period();
   if(period == 0)
     {
      Alert(name,": ôàòàëüíàÿ îøèáêà òåðìèíàëà - ïåðèîä 0 ìèíóò. Èíäèêàòîð îòêëþ÷åí.");
      return (false);
     }

   g_point=Point;
   if(g_point==0)
     {
      Alert(name,": ôàòàëüíàÿ îøèáêà òåðìèíàëà - âåëè÷èíà ïóíêòà ðàâíà íóëþ. Èíäèêàòîð îòêëþ÷åí.");
      return (false);
     }

   g_pointMultiply=1;
   if(i_point5Digits==YES)
      g_pointMultiply=10;

   if(i_pointsInBox<3*g_pointMultiply && i_isShowDelta==YES)
     {
      Alert(name,": êîëè÷åñòâî ïóíêòîâ â êëàñòåðå äîëæíî áûòü íå ìåíåå ",3*g_pointMultiply,". Èíäèêàòîð îòêëþ÷åí.");
      return (false);
     }

   if(i_pointsInBox<1)
     {
      Alert(name,": êîëè÷åñòâî ïóíêòîâ â êëàñòåðå äîëæíî áûòü íå ìåíåå 1. Èíäèêàòîð îòêëþ÷åí.");
      return (false);
     }

   g_curDayStart=0;

   return (true);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ×òåíèå äàííûõ î òèêàõ, íàêîïëåííûõ â òå÷åíèå ïðåäûäóùåé ðàáî÷åé ñåññèè ïðîãðàììû                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsLoadTempTicks()
  {
// Îòêðûòèå ôàéëà òèêîâîé èñòîðèè
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return true;

// Ðàñïðåäåëåíèå ïàìÿòè äëÿ ìàññèâà g_ticks
   int recSize=(int)(FileSize(hTicksFile)/sizeof(TickStruct));
   if(ArrayResize(g_ticks,recSize,1000)<0)
     {
      Alert(WindowExpertName(),": íå óäàëîñü ðàñïðåäåëèòü ïàìÿòü äëÿ ïîäêà÷êè äàííûõ èç âðåìåííîãî ôàéëà òèêîâ. Èíäèêàòîð îòêëþ÷åí.");
      FileClose(hTicksFile);
      return false;
     }

// ×òåíèå ôàéëà
   int i=0;
   while(i<recSize)
     {
      if(FileReadStruct(hTicksFile,g_ticks[i])==0)
        {
         Alert(WindowExpertName(),": îøèáêà ÷òåíèÿ äàííûõ èç âðåìåííîãî ôàéëà. Èíäèêàòîð îòêëþ÷åí.");
         return false;
        }
      i++;
     }

   FileClose(hTicksFile);
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ôîðìèðîâàíèå ìàññèâà çíà÷åíèé îáúåìîâ è ñîîòâåòñòâóþùèõ èì öâåòàì óðîâíåé                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CreateVolumeColorsArray()
  {
   g_volumeLevelsColor[0].levelMinVolume = i_minVolumeLevel1;
   g_volumeLevelsColor[1].levelMinVolume = i_minVolumeLevel2;
   g_volumeLevelsColor[2].levelMinVolume = i_minVolumeLevel3;
   g_volumeLevelsColor[3].levelMinVolume = i_minVolumeLevel4;
   g_volumeLevelsColor[4].levelMinVolume = i_minVolumeLevel5;

   g_volumeLevelsColor[0].levelColor = i_colorLevel1;
   g_volumeLevelsColor[1].levelColor = i_colorLevel2;
   g_volumeLevelsColor[2].levelColor = i_colorLevel3;
   g_volumeLevelsColor[3].levelColor = i_colorLevel4;
   g_volumeLevelsColor[4].levelColor = i_colorLevel5;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!IsSavedFile()) // Åñëè íè îäèí èç ïîäêëþ÷åííûõ èíäèêàòîðîâ íå ñîõðàíèë äàííûå, òî èõ ñîõðàíèò òåêóùèé èíäèêàòîð
      SaveTempTicks();                                                                             // Ñîõðàíåíèå äàííûõ î òèêàõ, íàêîïëåííûõ çà òåêóùèé ïåðèîä ðàáîòû èíäèêàòîðà   
   DeleteAllObjects();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ïðîâåðêà íàëè÷èÿ çàïèñàííûõ äàííûõ äðóãèì èíäèêàòîðîì                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSavedFile()
  {
// Ïîëó÷åíèå âðåìåíè ïîñòóïëåíèÿ ïîñëåäíåãî çàïèñàííîãî òèêà
   int lastTickIndex=ArraySize(g_ticks)-1;
   if(lastTickIndex<0) // Íè îäèí òèê íå áûë ïîëó÷åí. Çàïèñü äàííûõ íå òðåáóåòñÿ
      return true;

// Îòêðûòèå ôàéëà òèêîâîé èñòîðèè
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return false;

// Ïåðåìåùåíèå ê ïîñëåäíåé çàïèñè â ôàéëå
   if(!FileSeek(hTicksFile,-sizeof(TickStruct),SEEK_END))
     {
      FileClose(hTicksFile);
      return false;
     }

// ×òåíèå ïîñëåäíåé çàïèñè è çàêðûòèå ôàéëà
   TickStruct tick;
   uint readBytes=FileReadStruct(hTicksFile,tick);
   FileClose(hTicksFile);
   if(readBytes==0)
      return false;

// Ñðàâíåíèå äàòû òèêà, çàïèñàííîãî â ôàéëå, è äàòû ïîñëåäíåãî ïîñòóïèâøåãî òèêà
   return tick.time >= g_ticks[lastTickIndex].time;                                                // Äàòà/âðåìÿ ïîñëåäíåãî çàïèñàííîãî â ôàéëå òèêà áîëüøå èëè ðàâíà äàòå/âðåìåíè..
                                                                                                   // ..çàðåãèñòðèðîâàííîãî òèêà. Çíà÷èò, ôàéë óæå çàïèñàí, è ïîâòîðíàÿ çàïèñü íå òðåáóåòñÿ
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ñîõðàíåíèå äàííûõ î òèêàõ, íàêîïëåííûõ çà òåêóùóþ ðàáî÷óþ ñåññèþ ïðîãðàììû                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SaveTempTicks()
  {
// Ñîçäàíèå ôàéëà òèêîâîé èñòîðèè
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return;

// Çàïèñü ôàéëà
   int total=ArraySize(g_ticks),i=0;
   while(i<total)
     {
      if(FileWriteStruct(hTicksFile,g_ticks[i])==0)
        {
         Print("Îøèáêà ñîõðàíåíèÿ äàííûõ âî âðåìåííûé ôàéë...");
         return;
        }
      i++;
     }

   FileClose(hTicksFile);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Óäàëåíèå âñåõ îáúåêòîâ, ñîçäàííûõ ïðîãðàììîé                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DeleteAllObjects()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
      if(StringSubstr(ObjectName(i),0,StringLen(PREFIX))==PREFIX)
         ObjectDelete(ObjectName(i));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îòîáðàæåíèå òðåíäîâîé ëèíèè                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowTrendLine(datetime time1,double price1,datetime time2,double price2,string toolTip,color clr)
  {
   string name=PREFIX+"LINE_"+IntegerToString((int)MathRound(price1/g_point))+IntegerToString(time1);

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TREND,0,time1,price1,time2,price2);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)i_lineWidth);
      ObjectSetInteger(0,name,OBJPROP_RAY,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,toolTip);
      return;
     }

   ObjectMove(0,name,0,time1,price1);
   ObjectMove(0,name,1,time2,price2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,toolTip);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îïðåäåëåíèå èíäåêñà áàðà, ñ êîòîðîãî íåîáõîäèìî ïðîèçâîäèòü ïåðåðàñ÷åò                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int &total,const int ratesTotal,const int prevCalculated)
  {
// Îïðåäåëåíèå ïåðâîãî áàðà èñòîðèè, íà êîòîðîì áóäóò äîñòóïíû àäåêâàòíûå çíà÷åíèÿ èíäèêàòîðà
   total=ratesTotal-1;

// À ìîæåò çíà÷åíèÿ èíäèêàòîðà íå íóæíî îòîáðàæàòü íà âñåé èñòîðèè?
   if(i_indBarsCount>0 && i_indBarsCount<total)
      total=MathMin(i_indBarsCount,total);

// Ïåðâîå îòîáðàæåíèå èíäèêàòîðà èëè ïðîèçîøëà ïîäêà÷êà äàííûõ, ò. å. íà ïðåäûäóùåì òèêå áàðîâ áûëî íå íà îäèí áàð ìåíüøå, êàê ïðè íîðìàëüíîì ðàçâèòèè èñòîðèè, à íà äâà èëè áîëåå áàðîâ ìåíüøå
   if(prevCalculated<ratesTotal-1)
     {
      DeleteAllObjects();
      return (total);
     }

// Íîðìàëüíîå ðàçâèòèå èñòîðèè. Êîëè÷åñòâî áàðîâ òåêóùåãî òèêà îòëè÷àåòñÿ îò êîëè÷åñòâà áàðîâ ïðåäûäóùåãî òèêà íå áîëüøå, ÷åì íà îäèí áàð
   return (MathMin(ratesTotal - prevCalculated, total));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ðàâíû ëè ÷èñëà?                                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsValuesEquals(double first,double second)
  {
   return (MathAbs(first - second) < Point / 10);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Çàïèñü äàííûõ î òèêå â ìàññèâ g_ticks                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsUpdateTicksArray(TickStruct &tick)
  {
   int total=ArraySize(g_ticks);
   if(ArrayResize(g_ticks,total+1,100)<0)
     {
      Alert(WindowExpertName(),": èíäèêàòîðó íå õâàòàåò ïàìÿòè äëÿ ñîõðàíåíèÿ äàííûõ îá î÷åðåäíîì òèêå.");
      return false;
     }

   g_ticks[total]=tick;
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ïðîâåðêà íåîáõîäèìîñòè îòêðûòèÿ íîâîãî äíÿ                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CheckForNewDayOpen(TickStruct &curTick)
  {
   int curTickDayNumber=TimeDayOfYear(curTick.time);
   if(g_curDayNumber==curTickDayNumber) // Íîâûé òèê ïðèíàäëåæèò òåêóùåìó äíþ
      return;

// Íîâûé òèê ïðèíàäëåæèò äðóãîìó äíþ
   ShowHistogramm();
   string dayOpen= TimeToString(curTick.time,TIME_DATE);
   g_curDayStart = StringToTime(dayOpen);
   g_curDayNumber= TimeDayOfYear(g_curDayStart);

// Îáíóëåíèå òåêóùåé èñòîðèè
   ArrayResize(g_levelsData,0,1000);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Çàïèñü äàííûõ î òèêå â ìàññèâ g_levelsData                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSaveTickData(TickStruct &curTick,TickStruct &prevTick)
  {
// Ïðîâåðêà íåîáõîäèìîñòè îòêðûòèÿ íîâîãî äíÿ
   CheckForNewDayOpen(curTick);

// Ïðåîáðàçîâàíèå öåíû ê áëèæàéøåìó êëàñòåðó
   double clusterPrice=CastPriceToCluster(curTick.bid);

// Ïîèñê òàêîé æå öåíû â ìàññèâå g_levelsData
   int i=0;
   int total=ArraySize(g_levelsData);
   for(; i<total; i++)
      if(IsValuesEquals(g_levelsData[i].price,clusterPrice))
         break;

// Ïîõîæàÿ öåíà íàéäåíà
   if(i<total)
     {
      g_levelsData[i].repeatCnt++;
      SaveDeltaData(i,curTick.bid,prevTick.bid);
      return true;
     }

// Óêàçàííàÿ öåíà ÿâëÿåòñÿ íîâîé - ðàñøèðåíèå ìàññèâà
   if(ArrayResize(g_levelsData,total+1,1000)!=total+1)
     {
      Alert(WindowExpertName(),": èíäèêàòîðó íå õâàòàåò ïàìÿòè äëÿ êîððåêòíîé ðàáîòû.");
      return false;
     }

   g_levelsData[total].price=clusterPrice;
   g_levelsData[total].repeatCnt=1;
   g_levelsData[i].bullsCnt = 0;
   g_levelsData[i].bearsCnt = 0;
   SaveDeltaData(i,curTick.bid,prevTick.bid);
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ïðèâåäåíèå ðûíî÷íîé öåíû ê öåíå êëàñòåðà ñ ó÷åòîì åãî âûñîòû                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double CastPriceToCluster(double price)
  {
   int priceInPoints=(int)MathRound(price/Point);
   int clusterPrice =(int)MathRound(priceInPoints/1.0/i_pointsInBox);
   return NormalizeDouble(clusterPrice * Point * i_pointsInBox, Digits);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Çàïèñü äàííûõ î ðîñòå èëè ïàäåíèè öåíû â ïðåäåëàõ êëàñòåðà                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SaveDeltaData(int index,double curBid,double prevBid)
  {
   if(curBid>prevBid)
      g_levelsData[index].bullsCnt++;
   if(curBid<prevBid)
      g_levelsData[index].bearsCnt++;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ×òåíèå îäíîãî òèêà èç ôàéëà                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadTimeAndBidAskOfTick(int hTicksFile,TickStruct &tick)
  {
   if(FileIsEnding(hTicksFile))
      return false;

   uint bytesCnt=FileReadStruct(hTicksFile,tick);
   return bytesCnt == sizeof(TickStruct);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Ñ÷èòûâàíèå òèêîâ, ïðèíàäëåæàùèõ äåéñòâóþùåìó èíòåðâàëó îòîáðàæåíèÿ ãèñòîãðàììû                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadTicksFromFile(datetime &lastTime,int total)
  {
// Îáíóëåíèå òåêóùåé èñòîðèè
   ArrayResize(g_levelsData,0);

// Îòêðûòèå ôàéëà òèêîâîé èñòîðèè
   int hTicksFile=FileOpen(Symbol()+".tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return true;

// ×òåíèå ôàéëà
   TickStruct tick={0,0,0};
   TickStruct prevTick;
   bool result=true;
   datetime viewStartTime=Time[total];
   while(!IsStopped())
     {
      prevTick=tick;
      bool fileClose=!IsReadTimeAndBidAskOfTick(hTicksFile,tick);
      if(fileClose || tick.time==0)
         break;

      if(tick.time<viewStartTime)
         continue;

      if(!IsSaveTickData(tick,prevTick))
        {
         result=false;
         break;
        }
     }

   FileClose(hTicksFile);
   lastTime = tick.time;                                                                           // Óêàçûâàåì ïîñëåäíþþ ïðî÷èòàííóþ äàòó, ÷òîáû äîïîëíèòü ïîëó÷åííûå äàííûå èç ëîêàëüíîãî áóôåðà..
                                                                                                   // ..ïðè íåîáõîäèìîñòè
   return result;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ×òåíèå äàííûõ î òèêàõ èç ëîêàëüíîãî áóôåðà, ÷òîáû íå ïîòåðÿòü òèêè, ïðèøåäøèå ïîñëå íà÷àëà ðàáîòû èíäèêàòîðà, íî íå ïîïàâøèå â ôàéë                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ReadTicksFromBuffer(datetime lastTime,int total)
  {
// Âîçìîæíî, äàííûå èç ãëàâíîãî òèêîâîãî ôàéëà çàêàí÷èâàþòñÿ äî ìîìåíòà íà÷àëà èíòåðâàëà îòîáðàæåíèÿ äàííûõ èíäèêàòîðà
   lastTime=(datetime)MathMax(lastTime,Time[total]);

// Ïîèñê èíäåêñà äëÿ g_ticks, ñ êîòîðîãî íåîáõîäèìî ïðîäîëæèòü ÷òåíèå äàííûõ
   int totalTicks=ArraySize(g_ticks);
   int i=0;
   while(i<totalTicks && lastTime>=g_ticks[i].time)
      i++;

// Îñóùåñòâëåíèå äîïîëíåíèÿ
   datetime timeTotal=Time[0]+PeriodSeconds();
   TickStruct prevTick={0,0,0};
   if(i>0)
      prevTick=g_ticks[i-1];
   while(i<totalTicks && g_ticks[i].time<timeTotal)
     {
      if(!IsSaveTickData(g_ticks[i],prevTick))
         return false;

      prevTick=g_ticks[i];
      i++;
     }

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îïðåäåëåíèå ìàêñèìàëüíîãî çíà÷åíèÿ òèêîâîãî îáúåìà â ñðåäè íàéäåííûõ êëàñòåðîâ                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetMaxTickVolume()
  {
   int max=0;
   int total = ArraySize(g_levelsData);
   for(int i = 0; i < total; i++)
      if(g_levelsData[i].repeatCnt>max)
         max=g_levelsData[i].repeatCnt;

   return max;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îòîáðàæåíèå ãèñòîãðàììû                                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowHistogramm()
  {
   int maxVolume= GetMaxTickVolume();
   if(maxVolume == 0)
      return;

   int total=ArraySize(g_levelsData);
   int curDayStartBarIndex=0,dayDuration=0;
   datetime curDayLastBarTime=GetCurDayLastBarTime(curDayStartBarIndex,dayDuration);
   for(int i=0; i<total; i++)
     {
      int volumeLevel=GetVolumeLevel(g_levelsData[i].repeatCnt);
      if(volumeLevel<0)
         continue;

      // Îòîáðàæåíèå ãèñòîãðàììû îáúåìà
      string price="Êëàñòåð: "+DoubleToString(g_levelsData[i].price,Digits);
      datetime histRightTime=GetHistRightTime(curDayLastBarTime,curDayStartBarIndex,dayDuration,g_levelsData[i].repeatCnt,maxVolume);
      ShowTrendLine(g_curDayStart,g_levelsData[i].price,histRightTime,g_levelsData[i].price,price+". Îáúåì: "+IntegerToString(g_levelsData[i].repeatCnt),
                    g_volumeLevelsColor[volumeLevel].levelColor);

      // Îòîáðàæåíèå ãèñòîãðàìì ðîñòà è ïàäåíèÿ öåíû
      if(i_isShowDelta==NO)
         continue;
      histRightTime=GetHistRightTime(curDayLastBarTime,curDayStartBarIndex,dayDuration,g_levelsData[i].bearsCnt,maxVolume);
      ShowTrendLine(g_curDayStart,g_levelsData[i].price+g_pointMultiply*Point,histRightTime,g_levelsData[i].price+g_pointMultiply*Point,
                    price+". Îáúåì ïàäåíèÿ: "+IntegerToString(g_levelsData[i].bearsCnt),i_bearDeltaColor);
      histRightTime=GetHistRightTime(curDayLastBarTime,curDayStartBarIndex,dayDuration,g_levelsData[i].bullsCnt,maxVolume);
      ShowTrendLine(g_curDayStart,g_levelsData[i].price+2*g_pointMultiply*Point,histRightTime,g_levelsData[i].price+2*g_pointMultiply*Point,
                    price+". Îáúåì ðîñòà: "+IntegerToString(g_levelsData[i].bullsCnt),i_bullDeltaColor);
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îïðåäåëåíèå âðåìåíè îòêðûòèÿ ïîñëåäíåãî áàðà òåêóùåãî äíÿ (èñõîäÿ èç çíà÷åíèÿ g_curDayOpen), à òàêæå èíäåêñîâ íà÷àëüíîãî è êîíå÷íîãî áàðîâ äíÿ                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
datetime GetCurDayLastBarTime(int &curDayStartBarIndex,int &dayDuration)
  {
// Èíäåêñ íà÷àëüíîãî áàðà äíÿ
   curDayStartBarIndex=iBarShift(NULL,0,g_curDayStart);
   while(Time[curDayStartBarIndex]<g_curDayStart && curDayStartBarIndex>0)
      curDayStartBarIndex--;

// Èíäåêñ êîíå÷íîãî áàðà äíÿ
   datetime absoluteDayEnd=g_curDayStart+PERIOD_D1*60-1;
   int curDayEndBarIndex=iBarShift(NULL,0,absoluteDayEnd);
   while(Time[curDayEndBarIndex]>absoluteDayEnd && curDayEndBarIndex<Bars)
      curDayEndBarIndex++;

// Âðåìÿ îêîí÷àíèÿ äíÿ â ñîîòâåòñòâèè ñ èíäåêñîì êîíå÷íîãî áàðà
   dayDuration=curDayStartBarIndex-curDayEndBarIndex;
   return Time[curDayEndBarIndex] + PeriodSeconds() - 1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îïðåäåëåíèå, êàêîìó èç óêàçàííûõ îáúåìîâ ñîîòâåòñòâóåò ðàññìàòðèâàåìàÿ âåëè÷èíà îáúåìà                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetVolumeLevel(int ticksVolume)
  {
   for(int i=0; i<MAX_VOLUMES_SHOW; i++)
      if(g_volumeLevelsColor[i].levelMinVolume>ticksVolume)
         return i - 1;

   return MAX_VOLUMES_SHOW - 1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Âû÷èñëåíèå âðåìåíè áàðà, íà êîòîðîì äîëæíà çàêàí÷èâàòüñÿ ëèíèÿ ãèñòîãðàììû ñ óêàçàííûì òèêîâûì îáúåìîì                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
datetime GetHistRightTime(datetime curDayLastBarTime,int curDayStartBarIndex,int dayDuration,int tickVolume,int maxVolume)
  {
   int barsIndex=curDayStartBarIndex -(int)(dayDuration*tickVolume/1.0/maxVolume);
   if(barsIndex<0 || barsIndex>=Bars)
      return curDayLastBarTime;

   return Time[barsIndex];
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îñóùåñòâëåíèå ÷òåíèÿ äàííûõ èç ôàéëà è ïîëíîå îòîáðàæåíèå ãèñòîãðàììû                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowNewData(int total)
  {
// ×òåíèå äàííûõ èç ôàéëà
   datetime lastTime=0;
   if(!IsReadTicksFromFile(lastTime,total))
     {
      g_activate=false;
      return;
     }

// Äîïîëíåíèå äàííûõ èç ëîêàëüíîãî áóôåðà
   if(!ReadTicksFromBuffer(lastTime,total))
     {
      g_activate=false;
      return;
     }

   ShowHistogramm();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îáíîâëåíèå äàííûõ ïî êëàñòåðàì                                                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void UpdateData()
  {
   TickStruct tick;
   tick.time= TimeCurrent();
   tick.ask = Ask;
   tick.bid = Bid;

// Äîáàâëåíèå îäíîãî òèêà â ìàññèâ õðàíåíèÿ òèêîâ   
   if(!IsUpdateTicksArray(tick))
     {
      g_activate=false;
      return;
     }

// Äîáàâëåíèå òèêà â ìàññèâ êëàñòåðîâ
   TickStruct prevTick={0,0,0};
   int lastTickIndex=ArraySize(g_ticks)-1;
   if(lastTickIndex>0)
      prevTick=g_ticks[lastTickIndex-1];
   if(!IsSaveTickData(tick,prevTick))
     {
      g_activate=false;
      return;
     }

   ShowHistogramm();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Îòîáðàæåíèå äàííûõ èíäèêàòîðà                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit,int total)
  {
   if(limit>0)
     {
      ShowNewData(total);
      return;
     }

   UpdateData();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
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
   if(!g_activate) // Åñëè â ïðîöåññå ðàáîòû èíäèêàòîðà âîçíèêëà îøèáêà, òî ðàáîòàòü ïðîãðàììà íå äîëæíà
      return rates_total;

   int total;
   int limit=GetRecalcIndex(total,rates_total,prev_calculated);                                // Ñ êàêîãî áàðà íà÷èíàòü îáíîâëåíèå?

   ShowIndicatorData(limit,total);                                                                // Îòîáðàæåíèå äàííûõ èíäèêàòîðà
   WindowRedraw();

   return rates_total;
  }
//+------------------------------------------------------------------+
