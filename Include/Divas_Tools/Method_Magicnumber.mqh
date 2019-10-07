//+------------------------------------------------------------------+
//|                                                  Magicnumber.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Tools/Method_Tools.mqh>

int OrderMagic_Key,OrderMagic_Pin,OrderMagic_Sub;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _MagicDecode(int _Magicnumber,int _OrderMagicNumber)
  {
   string z=string(_OrderMagicNumber);
//   P(__LINE__,"_MagicDecode","v",cI(v),"z",z);
   string d1=StringSubstr(z,0,StringLen(string(_Magicnumber)));
   string d2=StringSubstr(z,StringLen(string(_Magicnumber)),1);
   string d3=StringSubstr(z,StringLen(string(_Magicnumber))+1,2);

   OrderMagic_Key=int(d1);
   OrderMagic_Pin=int(d2);
   OrderMagic_Sub=int(d3);

//P(__LINE__,"_MagicDecode","Key",OrderMagic_Key,"Pin",OrderMagic_Pin,"Sub",OrderMagic_Sub);
//P(__LINE__,"_MagicDecode","Key",d1,"Pin",d2,"Sub",d3);
  }
//+------------------------------------------------------------------+
int _MagicEncrypt(int _Magicnumber_Key,int Pin,int Sub)
  {
   string v=string(_Magicnumber_Key)+string(Pin)+cFillZero(Sub);
//      P(__LINE__,"_MagicEncrypt","v",v);
   return int(v);
  }
//+------------------------------------------------------------------+
