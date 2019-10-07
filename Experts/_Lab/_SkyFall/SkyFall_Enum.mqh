//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
enum ENUM_MODE_Price
  {
   MODE_PriceC=0,//C
   MODE_PriceO=1,//O
   MODE_PriceH=2,//H
   MODE_PriceL=3,//L
   MODE_PriceHL2=4,//HL/2
   MODE_PriceHLC3=5,//HLC/3
   MODE_PriceHL2C4=6,//(HL+2)*(C/4)
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_PATTERNS
  {
   PATTERNS_MinorUPin=111,
   PATTERNS_MajorUPin=112,
   PATTERNS_PrimeUPin=113,
   //
   PATTERNS_MinorUPxx=121,
   PATTERNS_MajorUPxx=122,
   PATTERNS_PrimeUPxx=123,
   //--------------------
   PATTERNS_MinorDWin=211,
   PATTERNS_MajorDWin=212,
   PATTERNS_PrimeDWin=213,
   //
   PATTERNS_MinorDWxx=221,
   PATTERNS_MajorDWxx=222,
   PATTERNS_PrimeDWxx=223,
  };
//+------------------------------------------------------------------+
extern ENUM_TIMEFRAMES  Minor_Time=PERIOD_CURRENT;
extern ENUM_TIMEFRAMES  Major_Time=PERIOD_H1;
extern ENUM_TIMEFRAMES  Prime_Time=PERIOD_H4;

extern ENUM_MODE_Price  Minor_CAll=MODE_PriceC;
extern ENUM_MODE_Price  Major_CAll=MODE_PriceC;
extern ENUM_MODE_Price  Prime_CAll=MODE_PriceC;

extern int              Minor_Period=13;
extern int              Major_Period=48;
extern int              Prime_Period=98;

extern double           OrderDemandArea=350;
extern double           OrderNearbyArea=350;
extern double           OrderNearbyFriend=1;

extern string Sep="------------------ TCCI -------------------------";//--------------------------
extern int TCCI_Displace=0;
extern int TCCI_Filter= 0;
extern int TCCI_Color = 2;
extern int TCCI_ColorBarBack = 1;
extern double TCCI_Deviation = 0.0;
//+------------------------------------------------------------------+
