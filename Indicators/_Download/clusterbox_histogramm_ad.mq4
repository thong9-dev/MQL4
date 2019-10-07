//+------------------------------------------------------------------+
//|                                     clusterbox_histogramm_ad.mq4 |
//|                                        Copyright 2015, Scriptong |
//|                                          http://advancetools.net |
//+------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property description "English: Displays the ticks volume of specified interval in the form of cluster histogram.\nRussian: ����������� ������� ������� ��������� ��������� � ���� ����������� ���������."
#property strict

#property indicator_chart_window
#property indicator_buffers 1

#define MAX_VOLUMES_SHOW      5                                                                    // ���������� ������� ������������� ������, ������� ������� ����������
#define VIEWRANGE_STARTBAR    10                                                                   // ������ ����, �� ������� ���������� ������� ����������� �����������
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct LevelVolumeColor                                                                            // ��������� ������������ ������� ������, ���������� ������� �� ������� ������ ������������.. 
  {                                                                                                // ..��������������� ������
   color             levelColor;
   int               levelMinVolume;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TickStruct                                                                                  // ��������� ��� ������ ������ �� ����� ����
  {
   datetime          time;
   double            bid;
   double            ask;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ViewRange                                                                                   // ��������� ��� ������ ������ ��������� ����������� �����������
  {
   datetime          leftTime;
   datetime          rightTime;
   int               rightIndex;
   int               rangeDuration;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct LevelsData                                                                                  // ��������� ��� ������ �������� ������, ���������� ��� ����������, ����� � ������� ���� �� ��������� ����������� �����������
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
   YES,                                                                                           // Yes / ��
   NO                                                                                             // No / ���
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_LINEWIDTH                                                                                // ������� ����� �����������
  {
   LINEWIDTH_NULL,                                                                                 // Most thin / �������� ������
   LINEWIDTH_ONE,                                                                                  // Thin / ������
   LINEWIDTH_TWO,                                                                                  // Median / �������
   LINEWIDTH_THREE,                                                                                // Thick / �������
   LINEWIDTH_FOUR                                                                                  // Most thick / �������� �������
  };

// ����������� ��������� ����������
input int      i_pointsInBox           = 50;                                                       // Points in one cluster / ���������� ������� � ����� ��������
input string   i_string1               = "Min volumes and colors / ���. ������ � �����";           // ==============================================
input int      i_minVolumeLevel1       = 1;                                                        // Minimal volume. Level 1 / ����������� �����. ������� 1
input color    i_colorLevel1           = clrSkyBlue;                                               // Color of level 1 / ���� ������ 1
input int      i_minVolumeLevel2       = 50;                                                       // Minimal volume. Level 2 / ����������� �����. ������� 2
input color    i_colorLevel2           = clrTurquoise;                                             // Color of level 2 / ���� ������ 2
input int      i_minVolumeLevel3       = 75;                                                       // Minimal volume. Level 3 / ����������� �����. ������� 3
input color    i_colorLevel3           = clrRoyalBlue;                                             // Color of level 3 / ���� ������ 3
input int      i_minVolumeLevel4       = 100;                                                      // Minimal volume. Level 4 / ����������� �����. ������� 4
input color    i_colorLevel4           = clrBlue;                                                  // Color of level 4 / ���� ������ 4
input int      i_minVolumeLevel5       = 150;                                                      // Minimal volume. Level 5 / ����������� �����. ������� 5
input color    i_colorLevel5           = clrMagenta;                                               // Color of level 5 / ���� ������ 5
input string   i_string2               = "Delta of volumes / ������ �������";                      // ==============================================
input ENUM_YESNO i_isShowDelta         = YES;                                                      // Show the delta of volumes? / ���������� ������ �������?
input color    i_bullDeltaColor        = clrLime;                                                  // Color of line price growth / ���� ����� ����� ����
input color    i_bearDeltaColor        = clrRed;                                                   // Color of line fall in prices / ���� ����� ������� ����
input string   i_string3               = "��������� �������";                                      // ==============================================
input ENUM_LINEWIDTH i_lineWidth       = LINEWIDTH_THREE;                                          // Histogram thickness / ������� ����� �����������
input color    i_viewRangeColor        = clrGoldenrod;                                             // Rectangle color / ���� ��������������
input ENUM_YESNO i_point5Digits        = YES;                                                      // Use 5-digits in prices? / ������������ 5-������� ������������� ���������?

input int      i_indBarsCount=10000;                                                               // Number of bars to display / ���-�� ����� �����������

// ������ ���������� ���������� ����������
bool g_chartForeground,                                                                            // ������� ���������� ������ �� �������� �����
     g_activate;                                                                                   // ������� �������� ������������� ����������

int g_pointMultiply;                                                                               // ��������� �������� ������, �������������� ��� ������ �� 5-������� ����������

double g_point,
       g_tickSize;

TickStruct        g_ticks[];                                                                       // ������ ��� �������� �����, ����������� ����� ������ ������ ����������                    
LevelVolumeColor  g_volumeLevelsColor[MAX_VOLUMES_SHOW];                                           // ������ ������� �, ��������������� ��, ������ �������
ViewRange         g_viewRange;                                                                     // ������� ��������� ������� ����������� �����������
LevelsData        g_levelsData[];                                                                  // ������� ������ �������, � ������� ������������ ���������� �����, �������� �� ��������������� ����

#define PREFIX "CLSTRBXH_"                                                                         // ������� ����������� ��������, ������������ ����������� 
#define VIEW_RANGE "VIEWRANGE"                                                                     // ������ ����� ������������ ������� "��������� ����", ������������ �������� �����������..
                                                                                                   // ..����������� ���������� �������
#define FONT_NAME "MS Sans Serif"
#define FONT_SIZE 8
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   g_activate=false;                                                                             // ��������� �� ���������������

   if(!IsTuningParametersCorrect()) // ������� ��������� �������� ����������� ���������� - ������� ��������� �������������
      return INIT_FAILED;

   if(!IsLoadTempTicks()) // �������� ������ � �����, ����������� �� ���������� ������ ������ ����������   
      return INIT_FAILED;

   InitViewRange();                                                                                // ������������� ������ ��������� ����������� �����������   
   CreateVolumeColorsArray();                                                                      // ����������� ������ � ����� � �������� ������� � ������

   g_activate=true;                                                                              // ��������� ������� ���������������

   return INIT_SUCCEEDED;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ������������ ����������� ����������                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
  {
   string name=WindowExpertName();

   int period= Period();
   if(period == 0)
     {
      Alert(name,": ��������� ������ ��������� - ������ 0 �����. ��������� ��������.");
      return (false);
     }

   g_point=Point;
   if(g_point==0)
     {
      Alert(name,": ��������� ������ ��������� - �������� ������ ����� ����. ��������� ��������.");
      return (false);
     }

   g_tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(g_tickSize==0)
     {
      Alert(name,": ��������� ������ ��������� - �������� ���� ������ ���� ����� ����. ��������� ��������.");
      return (false);
     }

   g_pointMultiply=1;
   if(i_point5Digits==YES)
      g_pointMultiply=10;

   if(i_pointsInBox<3*g_pointMultiply)
     {
      Alert(name,": ���������� ������� � �������� ������ ���� �� ����� ",3*g_pointMultiply,". ��������� ��������.");
      return (false);
     }

   if(VIEWRANGE_STARTBAR>=Bars)
     {
      Alert(name,": ������� ���������� ����� ������� ������� ����. ��������� ��������.");
      return (false);
     }

   return (true);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � �����, ����������� � ������� ���������� ������� ������ ���������                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsLoadTempTicks()
  {
// �������� ����� ������� �������
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return true;

// ������������� ������ ��� ������� g_ticks
   int recSize=(int)(FileSize(hTicksFile)/sizeof(TickStruct));
   if(ArrayResize(g_ticks,recSize,1000)<0)
     {
      Alert(WindowExpertName(),": �� ������� ������������ ������ ��� �������� ������ �� ���������� ����� �����. ��������� ��������.");
      FileClose(hTicksFile);
      return false;
     }

// ������ �����
   int i=0;
   while(i<recSize)
     {
      if(FileReadStruct(hTicksFile,g_ticks[i])==0)
        {
         Alert(WindowExpertName(),": ������ ������ ������ �� ���������� �����. ��������� ��������.");
         return false;
        }

      i++;
     }

   FileClose(hTicksFile);
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������������� ������ ��������� ����������� �����������                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void InitViewRange()
  {
   g_viewRange.rightTime= Time[0]+PeriodSeconds();
   g_viewRange.leftTime = Time[VIEWRANGE_STARTBAR];
   g_viewRange.rightIndex=-1;
   g_viewRange.rangeDuration=VIEWRANGE_STARTBAR+2;

  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������������ ������� �������� ������� � ��������������� �� ������ �������                                                                                                                         |
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
   if(!IsSavedFile()) // ���� �� ���� �� ������������ ����������� �� �������� ������, �� �� �������� ������� ���������
      SaveTempTicks();                                                                             // ���������� ������ � �����, ����������� �� ������� ������ ������ ����������   
   DeleteAllObjects();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ������� ���������� ������ ������ �����������                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSavedFile()
  {
// ��������� ������� ����������� ���������� ����������� ����
   int lastTickIndex=ArraySize(g_ticks)-1;
   if(lastTickIndex<0) // �� ���� ��� �� ��� �������. ������ ������ �� ���������
      return true;

// �������� ����� ������� �������
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return false;

// ����������� � ��������� ������ � �����
   if(!FileSeek(hTicksFile,-sizeof(TickStruct),SEEK_END))
     {
      FileClose(hTicksFile);
      return false;
     }

// ������ ��������� ������ � �������� �����
   TickStruct tick;
   uint readBytes=FileReadStruct(hTicksFile,tick);
   FileClose(hTicksFile);
   if(readBytes==0)
      return false;

// ��������� ���� ����, ����������� � �����, � ���� ���������� ������������ ����
   return tick.time >= g_ticks[lastTickIndex].time;                                                // ����/����� ���������� ����������� � ����� ���� ������ ��� ����� ����/�������..
                                                                                                   // ..������������������� ����. ������, ���� ��� �������, � ��������� ������ �� ���������
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������ � �����, ����������� �� ������� ������� ������ ���������                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SaveTempTicks()
  {
// �������� ����� ������� �������
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return;

// ������ �����
   int total=ArraySize(g_ticks),i=0;
   while(i<total)
     {
      if(FileWriteStruct(hTicksFile,g_ticks[i])==0)
        {
         Print("������ ���������� ������ �� ��������� ����...");
         return;
        }

      i++;
     }

   FileClose(hTicksFile);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ���� ��������, ��������� ����������                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DeleteAllObjects()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
      if(StringSubstr(ObjectName(i),0,StringLen(PREFIX))==PREFIX)
         ObjectDelete(ObjectName(i));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ��������������                                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowTrendLine(datetime time1,double price1,datetime time2,double price2,string toolTip,color clr)
  {
   string name=PREFIX+"LINE_"+IntegerToString((int)MathRound(price1/g_point));

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TREND,0,time1,price1,time2,price2);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)i_lineWidth);
      ObjectSetInteger(0,name,OBJPROP_RAY,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,toolTip);
      return;
     }

   ObjectMove(0,name,0,time1,price1);
   ObjectMove(0,name,0,time2,price2);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������� "�����"                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowText(datetime time,double price,string text,color clr)
  {
   string name=PREFIX+"TEXT_"+IntegerToString((int)(price/g_point));
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TEXT,0,time,price);
      ObjectSetString(0,name,OBJPROP_FONT,FONT_NAME);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONT_SIZE);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,DoubleToString(price,Digits));
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      return;
     }

   ObjectMove(0,name,0,time,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������� "�������������"                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowRectangle(datetime time1,double price1,datetime time2,double price2)
  {
   string name=PREFIX+VIEW_RANGE;
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE,0,time1,price1,time2,price2);
      ObjectSetInteger(0,name,OBJPROP_COLOR,i_viewRangeColor);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      return;
     }

   ObjectMove(0,name,0,time1,price1);
   ObjectMove(0,name,1,time2,price2);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������� ����, � �������� ���������� ����������� ����������                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int &total,const int ratesTotal,const int prevCalculated)
  {
// ����������� ������� ���� �������, �� ������� ����� �������� ���������� �������� ����������
   total=ratesTotal-1;

// � ����� �������� ���������� �� ����� ���������� �� ���� �������?
   if(i_indBarsCount>0 && i_indBarsCount<total)
      total=MathMin(i_indBarsCount,total);

// ������ ����������� ���������� ��� ��������� �������� ������, �. �. �� ���������� ���� ����� ���� �� �� ���� ��� ������, ��� ��� ���������� �������� �������, � �� ��� ��� ����� ����� ������
   if(prevCalculated<ratesTotal-1)
     {
      DeleteAllObjects();
      return (total);
     }

// ���������� �������� �������. ���������� ����� �������� ���� ���������� �� ���������� ����� ����������� ���� �� ������, ��� �� ���� ���
   return (MathMin(ratesTotal - prevCalculated, total));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����� �� �����?                                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsValuesEquals(double first,double second)
  {
   return (MathAbs(first - second) < Point / 10);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � ���� � ������ g_ticks                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsUpdateTicksArray(TickStruct &tick)
  {
   int total=ArraySize(g_ticks);
   if(ArrayResize(g_ticks,total+1,100)<0)
     {
      Alert(WindowExpertName(),": ���������� �� ������� ������ ��� ���������� ������ �� ��������� ����.");
      return false;
     }

   g_ticks[total]=tick;
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � ���� � ������ g_levelsData                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSaveTickData(TickStruct &curTick,TickStruct &prevTick)
  {
// �������������� ���� � ���������� ��������
   double clusterPrice=CastPriceToCluster(curTick.bid);

// ����� ����� �� ���� � ������� g_levelsData
   int i=0;
   int total=ArraySize(g_levelsData);
   for(; i<total; i++)
      if(IsValuesEquals(g_levelsData[i].price,clusterPrice))
         break;

// ������� ���� �������
   if(i<total)
     {
      g_levelsData[i].repeatCnt++;
      SaveDeltaData(i,curTick.bid,prevTick.bid);
      return true;
     }

// ��������� ���� �������� ����� - ���������� �������
   if(ArrayResize(g_levelsData,total+1)!=total+1)
     {
      Alert(WindowExpertName(),": ���������� �� ������� ������ ��� ���������� ������.");
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
//| ���������� �������� ���� � ���� �������� � ������ ��� ������                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double CastPriceToCluster(double price)
  {
   int priceInPoints=(int)MathRound(price/Point);
   int clusterPrice =(int)MathRound(priceInPoints/1.0/i_pointsInBox);
   return NormalizeDouble(clusterPrice * Point * i_pointsInBox, Digits);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � ����� ��� ������� ���� � �������� ��������                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SaveDeltaData(int index,double curBid,double prevBid)
  {
   if(curBid>prevBid)
      g_levelsData[index].bullsCnt++;
   if(curBid<prevBid)
      g_levelsData[index].bearsCnt++;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ ���� �� �����                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadTimeAndBidAskOfTick(int hTicksFile,TickStruct &tick)
  {
   if(FileIsEnding(hTicksFile))
      return false;

   uint bytesCnt=FileReadStruct(hTicksFile,tick);
   return bytesCnt == sizeof(TickStruct);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� �����, ������������� ������������ ��������� ����������� �����������                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadTicksFromFile(datetime &lastTime)
  {
// ��������� ������� �������
   ArrayResize(g_levelsData,0);

// �������� ����� ������� �������
   int hTicksFile=FileOpen(Symbol()+".tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return true;

// ������ �����
   TickStruct tick={0,0,0};
   TickStruct prevTick;
   bool result=true;
   while(!IsStopped())
     {
      prevTick=tick;
      bool fileClose=!IsReadTimeAndBidAskOfTick(hTicksFile,tick);
      if(fileClose || tick.time==0)
         break;

      if(tick.time<g_viewRange.leftTime)
         continue;

      if(tick.time>g_viewRange.rightTime+PeriodSeconds())
         break;

      if(!IsSaveTickData(tick,prevTick))
        {
         result=false;
         break;
        }
     }

   FileClose(hTicksFile);
   lastTime = tick.time;                                                                           // ��������� ��������� ����������� ����, ����� ��������� ���������� ������ �� ���������� ������..
                                                                                                   // ..��� �������������
   return result;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � ����� �� ���������� ������, ����� �� �������� ����, ��������� ����� ������ ������ ����������, �� �� �������� � ����                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ReadTicksFromBuffer(datetime lastTime)
  {
// ���������� �� ��������� - ��������� ��� ����
   if(lastTime>g_viewRange.rightTime)
      return true;

// ��������, ������ �� �������� �������� ����� ������������� �� ������� ������ ��������� ����������� �����������
   lastTime=(int)MathMax(lastTime,g_viewRange.leftTime);

// ����� ������� ��� g_ticks, � �������� ���������� ���������� ������ ������
   int total=ArraySize(g_ticks);
   int i=0;
   while(i<total && lastTime>=g_ticks[i].time)
      i++;

// ������������� ����������
   datetime timeTotal=g_viewRange.rightTime+PeriodSeconds();
   TickStruct prevTick={0,0,0};
   if(i>0)
      prevTick=g_ticks[i-1];
   while(i<total && g_ticks[i].time<timeTotal)
     {
      if(!IsSaveTickData(g_ticks[i],prevTick))
         return false;

      prevTick=g_ticks[i];
      i++;
     }

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������������� �������� �������� ������ � ����� ��������� ���������                                                                                                                    |
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
//| ����������� �����������                                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowHistogramm()
  {
   DeleteHistogramm();
   int maxVolume= GetMaxTickVolume();
   if(maxVolume == 0)
      return;

   int total = ArraySize(g_levelsData);
   for(int i = 0; i < total; i++)
     {
      int volumeLevel=GetVolumeLevel(g_levelsData[i].repeatCnt);
      if(volumeLevel<0)
         continue;

      // ����������� ����������� ������
      string price="�������: "+DoubleToString(g_levelsData[i].price,Digits);
      datetime histRightTime=GetHistRightTime(g_levelsData[i].repeatCnt,maxVolume);
      ShowTrendLine(g_viewRange.leftTime,g_levelsData[i].price,histRightTime,g_levelsData[i].price,price+". ����� ������",g_volumeLevelsColor[volumeLevel].levelColor);
      ShowText(g_viewRange.rightTime,g_levelsData[i].price," "+IntegerToString(g_levelsData[i].repeatCnt),g_volumeLevelsColor[volumeLevel].levelColor);

      // ����������� ���������� ����� � ������� ����
      if(i_isShowDelta==NO)
         continue;
      histRightTime=GetHistRightTime(g_levelsData[i].bearsCnt,maxVolume);
      ShowTrendLine(g_viewRange.leftTime,g_levelsData[i].price+g_pointMultiply*Point,histRightTime,g_levelsData[i].price+g_pointMultiply*Point,
                    price+". ����� �������: "+IntegerToString(g_levelsData[i].bearsCnt),i_bearDeltaColor);
      histRightTime=GetHistRightTime(g_levelsData[i].bullsCnt,maxVolume);
      ShowTrendLine(g_viewRange.leftTime,g_levelsData[i].price+2*g_pointMultiply*Point,histRightTime,g_levelsData[i].price+2*g_pointMultiply*Point,
                    price+". ����� �����: "+IntegerToString(g_levelsData[i].bullsCnt),i_bullDeltaColor);
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ���� ��������, ������������ �����������                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DeleteHistogramm()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string name=ObjectName(i);
      if(StringSubstr(name,0,StringLen(PREFIX+"LINE_"))==PREFIX+"LINE_" ||
         StringSubstr(name,0,StringLen(PREFIX+"TEXT_"))==PREFIX+"TEXT_")
         ObjectDelete(name);
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �����������, ������ �� ��������� ������� ������������� ��������������� �������� ������                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetVolumeLevel(int ticksVolume)
  {
   for(int i=0; i<MAX_VOLUMES_SHOW; i++)
      if(g_volumeLevelsColor[i].levelMinVolume>ticksVolume)
         return i - 1;

   return MAX_VOLUMES_SHOW - 1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������� ����, �� ������� ������ ������������� ����� ����������� � ��������� ������� �������                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
datetime GetHistRightTime(int tickVolume,int maxVolume)
  {
   int barsIndex=(int)(g_viewRange.rightIndex+(g_viewRange.rangeDuration-1) *(1-tickVolume/1.0/maxVolume));
   if(barsIndex<0 || barsIndex>=Bars)
      return g_viewRange.rightTime;

   return Time[barsIndex];
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ��������� ��������� ����������� ����������� �������                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowViewRange(int limit)
  {
// ���� ��������� ������� � ������ ����, �� �������� ��������������� �� ����� 0 � ����
   if(limit>0 && g_viewRange.rightIndex>=0)
     {
      if(g_viewRange.rightTime != Time[g_viewRange.rightIndex])
         g_viewRange.rightIndex = iBarShift(NULL, 0, g_viewRange.rightTime);
     }
   else
// ��������, ��������� ������� � ���������� ���� ��� ���������������� ��������� �� ������� ����
   if(g_viewRange.rightIndex==-1 && g_viewRange.rightTime!=Time[0]+PeriodSeconds())
                                                           MoveRangeToNullBar();

   DefineCoordsAndShowViewRange();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ��������� ����������� ����������� �� ����� "�������" ���                                                                                                                              |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void MoveRangeToNullBar()
  {
   g_viewRange.rightTime=Time[0]+PeriodSeconds();
   int leftIndex=iBarShift(NULL,0,g_viewRange.leftTime);
   g_viewRange.rangeDuration=leftIndex+2;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ��������� ����������� ��������� �����������                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DefineCoordsAndShowViewRange()
  {
// ����������� ��������� ���������
   double rightPrice=0,leftPrice=0;
   g_viewRange.rightIndex=(int)MathMin(MathMax(g_viewRange.rightIndex,-1),Bars-1);
   g_viewRange.rangeDuration = (int)MathMax(MathMin(g_viewRange.rangeDuration, Bars - g_viewRange.rightIndex - 2), 1);
   if(g_viewRange.rightIndex == -1)
     {
      g_viewRange.rangeDuration=(int)MathMax(g_viewRange.rangeDuration,2);
      rightPrice= CastPriceToCluster(High[iHighest(NULL,0,MODE_HIGH,g_viewRange.rangeDuration-1)])+2 * g_pointMultiply * Point;
      leftPrice = CastPriceToCluster(Low[iLowest(NULL,0,MODE_LOW,g_viewRange.rangeDuration-1)]);
     }
   else
     {
      rightPrice= CastPriceToCluster(High[iHighest(NULL,0,MODE_HIGH,g_viewRange.rangeDuration,g_viewRange.rightIndex)])+2 * g_pointMultiply * Point;
      leftPrice = CastPriceToCluster(Low[iLowest(NULL,0,MODE_LOW,g_viewRange.rangeDuration,g_viewRange.rightIndex)]);
     }

// ����������� ���������
   ShowRectangle(g_viewRange.rightTime,rightPrice,g_viewRange.leftTime,leftPrice);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������������� ������ ������ �� ����� � ������ ����������� �����������                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowNewData()
  {
// ������ ������ �� �����
   datetime lastTime=0;
   if(!IsReadTicksFromFile(lastTime))
     {
      g_activate=false;
      return;
     }

// ���������� ������ �� ���������� ������
   if(!ReadTicksFromBuffer(lastTime))
     {
      g_activate=false;
      return;
     }

   ShowHistogramm();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������ �� ���������                                                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void UpdateData()
  {
   TickStruct tick;
   tick.time= TimeCurrent();
   tick.ask = Ask;
   tick.bid = Bid;

// ���������� ������ ���� � ������ �������� �����   
   if(!IsUpdateTicksArray(tick))
     {
      g_activate=false;
      return;
     }

// ������ � ������ ��������� �� �����������, ���� ������ ������� �������������� ��������� �� ������ ���� ��� �����
   if(g_viewRange.rightIndex>0)
      return;

// ���������� ���� � ������ ���������
   TickStruct prevTick={0,0,0};
   int lastTickIndex=ArraySize(g_ticks)-1;
   if(lastTickIndex>0)
      prevTick=g_ticks[lastTickIndex-1];
   if(!IsSaveTickData(tick,prevTick))
     {
      g_activate=false;
      return;
     }

   DefineCoordsAndShowViewRange();
   ShowHistogramm();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������ ����������                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit,int total)
  {
   if(limit>0)
     {
      ShowNewData();
      return;
     }

   UpdateData();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ������������ ������ �� ����������� ������� � ��������� ����� ������ ���������                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ValidateDataAndSetRange()
  {
// ��������� ��������� �������
   datetime rightTime=(datetime)ObjectGetInteger(0,PREFIX+VIEW_RANGE,OBJPROP_TIME1);
   datetime leftTime =(datetime)ObjectGetInteger(0,PREFIX+VIEW_RANGE,OBJPROP_TIME2);
   if(rightTime<leftTime)
     {
      leftTime=rightTime;
      rightTime=(datetime)ObjectGetInteger(0,PREFIX+VIEW_RANGE,OBJPROP_TIME2);
     }

// �������� ������������ ��������� �������
   if(rightTime>Time[0]+PeriodSeconds())
     {
      rightTime=Time[0]+PeriodSeconds();

      if(leftTime>Time[0])
         leftTime=Time[VIEWRANGE_STARTBAR];
     }

// ��������� ����� ���������
   g_viewRange.rightTime= rightTime;
   g_viewRange.leftTime = leftTime;
   if(g_viewRange.rightTime <= Time[0])
      g_viewRange.rightIndex = iBarShift(NULL, 0, rightTime);
   else
      g_viewRange.rightIndex=-1;
   int leftIndex=iBarShift(NULL,0,leftTime);
   g_viewRange.rangeDuration=leftIndex-g_viewRange.rightIndex+1;

// ����������� ���������
   DefineCoordsAndShowViewRange();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ��������� ������� ����������� �������                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_DRAG)
      return;

   if(sparam!=PREFIX+VIEW_RANGE)
      return;

// ��������� ������, ����������� ������� ��������� ����������� �����������
   ValidateDataAndSetRange();
   ShowNewData();

   WindowRedraw();
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
   if(!g_activate) // ���� ��������� �� ������ �������������, �� �������� �� �� ������
      return rates_total;

   int total;
   int limit=GetRecalcIndex(total,rates_total,prev_calculated);                                // � ������ ���� �������� ����������?

   ShowViewRange(limit);                                                                           // ��������� ����������� � ��������� ����������� ����������� ������� ������ �����������
   ShowIndicatorData(limit, total);                                                                // ����������� ������ ����������
   WindowRedraw();

   return rates_total;
  }
//+------------------------------------------------------------------+
