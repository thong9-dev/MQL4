//|                                                  Magicnumber.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |

#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cI(int v)
  {
   return IntegerToString(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(int v)
  {
   return IntegerToString(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(long v)
  {
   return IntegerToString(int(v));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(ulong v)
  {
   return IntegerToString(int(v));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cI(double v)
  {
   return DoubleToString(v,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string c(double v,int Digit)
  {
   if(v==0)
      return "0";
   else
      return DoubleToString(v,Digit);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cD(double v,int Digit)
  {
   if(v==0)
      return "0";
   else
      return DoubleToString(v,Digit);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cFillZero(int v,int digits)
  {
   string temp;
   if(v<MathPow(10,digits-1))
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cFillZero(double v,int digits)
  {
   string temp;

   if(v<MathPow(10,digits-1))
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Comma(double v,int Digit,string zz)
  {

   string temp=DoubleToString(v,Digit),r;

   if(StringFind(temp,",",0)>=0)
     {
      //---
      string result[];
      int k=StringSplit(temp,StringGetCharacter(".",0),result);
      temp=result[0];
      //---
      string temp2="",temp3="";
      int Buff=0;
      int _n=StringLen(temp);

      for(int i=_n;i>0;i--)
        {
         if(Buff%3==0 && i<_n)
            temp2+= zz;
         temp2+=StringSubstr(temp,i-1,1);
         Buff++;
        }
      for(int i=StringLen(temp2);i>0;i--)
        {
         temp3+=StringSubstr(temp2,i-1,1);
        }
      //     
      r=temp3;
      if(ArraySize(result)>1) r+="."+result[1];
     }
   else
     {
      r=temp;
     }
//---
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BoolToStr(bool v)
  {
   string r="Flase";
   if(v)
     {
      r="True";
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BoolToStr_OnOff(bool v)
  {
   string r="Off";
   if(v)
     {
      r="On";
     }
   return r;
  }
//+------------------------------------------------------------------+
string c(bool v=true,string mode="MODE_BOOL")
  {
   if(mode=="MODE_ONOFF")
     {
      string r="Off";
      if(v)
         r="On";
      return r;
     }
   if(mode=="MODE_BOOL")
     {
      string r="Flase";
      if(v)
         r="True";
      return r;
     }
   return "-";
  }
//+------------------------------------------------------------------+
