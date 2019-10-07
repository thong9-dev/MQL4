//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "SkyFall_Enum.mqh"
//#include "SkyFall [Scap ShortTerm][3].mq4"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sPATTERNS
  {
   int               TF;
   int               CAll;
   int               PERRIOD;
   string            PATTERN;
   //---
   void sPATTERNS(int statement)
     {
      switch(statement)
        {
         case  PATTERNS_MinorUPin:  MinorUPin(int(Minor_Time),Minor_CAll,Minor_Period); break;
         case  PATTERNS_MajorUPin:  MajorUPin(int(Major_Time),Major_CAll,Major_Period); break;
         case  PATTERNS_PrimeUPin:  PrimeUPin(int(Prime_Time),Prime_CAll,Prime_Period); break;

         case  PATTERNS_MinorDWin:  MinorDWin(int(Minor_Time),Minor_CAll,Minor_Period); break;
         case  PATTERNS_MajorDWin:  MajorDWin(int(Major_Time),Major_CAll,Major_Period); break;
         case  PATTERNS_PrimeDWin:  PrimeDWin(int(Prime_Time),Prime_CAll,Prime_Period); break;
         default:
            break;
        }
     };
   void MinorUPin(int tf,int call,int period)
     {
      TF=tf;
      CAll=call;
      PERRIOD=period;
      PATTERN+="___UUUU"+"#";
      PATTERN+="__H__H_"+"#";
      PATTERN+="DDDD___";
     };
   void MajorUPin(int tf,int call,int period)
     {
      TF=tf;
      CAll=call;
      PERRIOD=period;
      PATTERN+="_"+"#";
      PATTERN+="H"+"#";
      PATTERN+="D";
     };
   void PrimeUPin(int tf,int call,int period)
     {
      TF=tf;
      CAll=call;
      PERRIOD=period;
      PATTERN+="U"+"#";
      PATTERN+="H"+"#";
      PATTERN+="_";
     };
   void MinorDWin(int tf,int call,int period)
     {
      TF=tf;
      CAll=call;
      PERRIOD=period;
      PATTERN+="UUUU___"+"#";
      PATTERN+="__H__H_"+"#";
      PATTERN+="___DDDD";
     };
   void MajorDWin(int tf,int call,int period)
     {
      TF=tf;
      CAll=call;
      PERRIOD=period;
      PATTERN+="U"+"#";
      PATTERN+="H"+"#";
      PATTERN+="_";
     };
   void PrimeDWin(int tf,int call,int period)
     {
      TF=tf;
      CAll=call;
      PERRIOD=period;
      PATTERN+="_"+"#";
      PATTERN+="H"+"#";
      PATTERN+="D";
     };
  };
//+------------------------------------------------------------------+
struct sACCOUNT
  {
   double            Capital;
   double            Profit;
   double            Holding;
   double            Balance;

   double            Drawdawn;
   void sACCOUNT()
     {
      Capital=AccountInfoDouble(ACCOUNT_BALANCE);
     };
   double getHolding()
     {
      Holding=AccountInfoDouble(ACCOUNT_PROFIT);
      return Holding;
      //ACCOUNT_BALANCE
     };
   double getProfit()
     {
      Balance=AccountInfoDouble(ACCOUNT_BALANCE);
      Profit=Balance-Capital;
      return Profit;
     };
   double getMaxDD()
     {
      double h=getHolding();
      if(Drawdawn>h) Drawdawn=h;
      return Drawdawn;
     };
   double getHoldingDD_P()
     {
      double h=getHolding();

      return Drawdawn;
     };
  };
//+------------------------------------------------------------------+
