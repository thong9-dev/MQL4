//+------------------------------------------------------------------+
//|                                            myLib_NumChok_var.mqh |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict    "NumChok"

#include "NumChok_Method.mqh";
#include "NumChok_Method_MQL4.mqh";
#include "NumChok.mq4";

int Test_Day=-1;

//+------------------------------------------------------------------+
extern string Control="------ Control -----";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _SetBool
  {
   A=False,    // No
   B=True,     // Yes
  };
extern _SetBool _LatsTime_B = A;
extern _SetBool _LatsTime_S = A;
bool _LatsTime_StayFriday=false;
extern string _Control="------ Setup -----";
extern int MagicNumber=1234;
extern double Fund=300;
double FundCurrent=Fund;
extern double Lots=0.1;
extern double LotsRate = 1;
extern string Technique= "------Technique -----";
extern int DoubleClick = 1;
extern int Signal_DDClick=10;
extern int Pip=300;
extern int PipSteps= 300;
extern int MaxTrad = 40;
extern string Indicator_EMA="------EMA -----";
extern int COLSE_GREEc=100;
extern int GREE_REDc = 20;
extern int RED_BLUEc = 10;
extern string Indicator_RSI="------RSI -----";
extern int RSI_Period= 28;
extern int RSI_Shift =  20;
extern string Indicator_Vol="------Volume -----";
extern int Vol_N=10;
extern int Vol_Min=500;
extern int Vol_Max=3500;
extern string MM="------ Money Management -----";
extern double CutLoss_Buy_ = 13;
extern double CutLoss_Sell = 13;
//+------------------------------------------------------------------+
extern string Display="------ Display -----";
extern int FontSize=10;
//+------------------------------------------------------------------+
string _NameEa0="NumChok";
string _NameEaLabel=_NameEa0+" ";
int MagicNumber__Buy=MagicNumber,MagicNumber_Sell=MagicNumber+11;

int myDigit=(int)MarketInfo(Symbol(),MODE_DIGITS);

double CNT_Round_B=0,CNT_Round_S=0;
int CNT_Buy,cMax__Buy=MaxTrad *(-1);
int CNT_Sell,cMax_Sell=MaxTrad *(-1);
int CNT_ALL,cMax=MaxTrad *(-1);

double aTP_All__Buy=1,aTP_All_Sell=1,aTP_All;

double    Border_B,Rim_B,RimP_B,
Border_S,Rim_S,RimP_S,
accProfit,accBalance,myProfitTotal,perProfit,
sTP_B,sTPmax_B = -9,
sTP_S,sTPmax_S = -9;
double myProfit,myProfit_Buy,myProfit_Sell;
double DD_B,DDMax_B=-999999999,DD2_B,DDMax2_B=-999999999,DD_All_B,DDMax_All_B=-999999999,
DD_S,DDMax_S=-999999999,DD2_S,DDMax2_S=-999999999,DD_All_S,DDMax_All_S=-999999999;
double DD_All,DDMax_All=-999999999;
double ProfitPerDay;

datetime TimeStart,TimeWorked;
datetime DDTimeMax_Buy=0,DDTimeMax_Sell=0;
datetime DDTime_Buy,DDTime_Sell;
datetime TimeFirstOrder__Buy,TimeFirstOrder_Sell;
double   avg_dd_TP=0,sum_dd_TP=0,n_dd_TP=0;

string _Direction;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int _OrdersTotal,
_CntBars,
_Minute;

double _PriceMax__Buy,_PriceMin__Buy,
_PriceMax_Sell,_PriceMin_Sell;
double vSpread;
string Same="";
string StrTabs="-------------------------------------------------------------------------------";
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double _iHigh,_iLow;
string TrendWeek;
//+------------------------------------------------------------------+
//|                   Signal                                         |
//+------------------------------------------------------------------+
double _iMA_BLUE,_iMA__RED,_iMA_GREE;

int COLSE_GREE,GREE_RED,RED_BLUE;
string _COLSE_GREE,_GREE_RED,_RED_BLUE;

string STR_isMA;
//+-----------------------+
//RSI
//+-----------------------+
bool Reform;
//+------------------------------------------------------------------+
//CNT_X / CNT_R / DDTIME / DD_FUN / DD_ACC / DD__ALL /  TP_Point
double _Stat_cMax,
_Stat_CNT_Round,
_Stat_DDMax,
_Stat_DDMax2,
_Stat_DDMax_All,
_Stat_MonthDMax,
_Stat_DayDMax,
_Stat_HHDMax,
_Stat_MMDMax,
_Stat_SSDMax,
_Stat_TPPoint,
_Stat_PriceActive;
int _cStat_cMax,
_cStat_CNT_Round,
_cStat_DDMax,
_cStat_DDMax2,
_cStat_DDMax_All,
_cStat_MonthDMax,
_cStat_DayDMax,
_cStat_HHDMax,
_cStat_MMDMax,
_cStat_SSDMax,
_cStat_TPPoint,
_cStat_PriceActive,
_cStat_PriceActive_N,
_cStat_PriceActiveCHK;

//------------------------------------------------------------------
int _Month,_Day,_Day_Of_RunEA,_HH,_MM,_SS,
_MonthD__Buy,_DAD__Buy,_HHD__Buy,_MMD__Buy,_SSD__Buy,
_MonthD_Sell,_DAD_Sell,_HHD_Sell,_MMD_Sell,_SSD_Sell,
_MonthDMax__Buy,_DayDMax__Buy,_HHDMax__Buy,_MMDMax__Buy,_SSDMax__Buy,
_MonthDMax_Sell,_DayDMax_Sell,_HHDMax_Sell,_MMDMax_Sell,_SSDMax_Sell;
int _DayOfWeek;
MqlDateTime MqlDate_Current,MqlDate_Start,MqlDate_Work;

MqlDateTime MqlDate_1Order_Buy,MqlDate_1Order_Sell;
MqlDateTime MqlDate_DDMax__Buy,MqlDate_DDMax_Sell;
//+------------------------------------------------------------------+
//|         CutLoss                                                                  
//+------------------------------------------------------------------+
double CNT_CutLoss_Buy,CNT_CutLoss_Sell;
int Signal_CutLoss,Signal_CutLoss_Buy,Signal_CutLoss_Sell;
int Signal_CutLoss_Buy0,Signal_CutLoss_Sell0;
int List_BUYY[30];
int List_SELL[30];
int CNT_IconCuLoss;
//+------------------------------------------------------------------+
//|         DDClick                                                         
//+------------------------------------------------------------------+
int Signal_DDClick_BUY,Signal_DDClick_SELL;
int Signal_DDClick_BUY0,Signal_DDClick_SELL0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RateWin_BUY=0,RateWin_SEL=0;
bool _CutProfit=false;
bool _Cut__Loss=false;
bool _ConfirmsignalMA=false;
bool _iStochastic=false;
bool _iHihgLow=false;
bool _iVolumes=false;
bool _iSAR=false;
bool _iRSI=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int _eaText=20;
bool WindowEA=false;
string _eaText0,
_eaText1,_eaText2,_eaText3,_eaText4,_eaText5,_eaText6,_eaText7,_eaText8,_eaText9,_eaText10,
_eaText11,_eaText12,_eaText13,_eaText14,_eaText15,_eaText16,_eaText17,_eaText18,_eaText19,_eaText20,
_eaText21,_eaText22,_eaText23,_eaText24,_eaText25,_eaText26,_eaText27,_eaText28,_eaText29,_eaText30,
_eaText31;
color _clrText0,
_clrText1,_clrText2,_clrText3,_clrText4,_clrText5,_clrText6,_clrText7,_clrText8,_clrText9,_clrText10,
_clrText11,_clrText12,_clrText13,_clrText14,_clrText15,_clrText16,_clrText17,_clrText18,_clrText19,_clrText20,
_clrText21,_clrText22,_clrText23,_clrText24,_clrText25,_clrText26,_clrText27,_clrText28,_clrText29,_clrText30,
_clrText31;
//+------------------------------------------------------------------+
void _TEMP_DISPLAY(bool _WindowEA)
  {
   if(_WindowEA)
     {
      int Shif=30;
      _LabelSet("_eaText1",Shif,020,clrYellow,"Arial",FontSize,_eaText1+" "+(string)_LatsTime_B);
      _LabelSet("_eaText2",Shif,040,clrRed,"Arial",FontSize,_eaText2);
      _LabelSet("_eaText3",Shif,060,_clrText3,"Arial",FontSize,_eaText3);
      _LabelSet("_eaText4",Shif,080,_clrText4,"Arial",FontSize,_eaText4);
      _LabelSet("_eaText5",Shif,100,_clrText5,"Arial",FontSize,_eaText5);
      //2
      Shif=270;
      _LabelSet("_eaText6",Shif,020,clrYellow,"Arial",FontSize,_eaText6+" "+(string)_LatsTime_S);
      _LabelSet("_eaText7",Shif,040,clrRed,"Arial",FontSize,_eaText7);
      _LabelSet("_eaText8",Shif,060,_clrText8,"Arial",FontSize,_eaText8);
      _LabelSet("_eaText9",Shif,080,_clrText9,"Arial",FontSize,_eaText9);
      _LabelSet("_eaText10",Shif,100,_clrText10,"Arial",FontSize,_eaText10);
      //3
      Shif=500;
      _LabelSet("_eaText11",Shif,02,clrYellow,"Arial",FontSize,_eaText11);
      _LabelSet("_eaText12",Shif,20,clrYellow,"Arial",FontSize,_eaText12);
      _LabelSet("_eaText13",Shif,40,clrYellow,"Arial",FontSize,_eaText13);
      _LabelSet("_eaText14",Shif,60,clrYellow,"Arial",FontSize,_eaText14);
      _LabelSet("_eaText15",Shif,80,clrYellow,"Arial",FontSize,_eaText15);
      //4
      Shif=720;

      _LabelSet("_eaText16",Shif,02,clrYellow,"Arial",FontSize,_eaText16);
      _LabelSet("_eaText17",Shif,20,clrRed,"Arial",FontSize,_eaText17+_Comma(avg_dd_TP,0,"")+"/"+_Comma(sum_dd_TP,0,"")+"/"+(string)n_dd_TP);
      _LabelSet("_eaText18",Shif,40,clrYellow,"Arial",FontSize,_eaText18);
      _LabelSet("_eaText19",Shif,60,clrYellow,"Arial",FontSize,_eaText19);
      _LabelSet("_eaText20",Shif,80,clrYellow,"Arial",FontSize,_eaText20);
     }

  }
//+------------------------------------------------------------------+
