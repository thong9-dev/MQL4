//+------------------------------------------------------------------+
//|                                              SN_Generate.ex4.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _SetBool
  {
   A=False,    // No
   B=True,     // Yes
  };
extern string EA0="Master";//------------------------------------------------------------------
//--- Master ---
extern string _flag="DIVAS";//EA_NameFlag
extern string MasterKey="PUKDEE";
string List_ACCOUNTAllow[]={"8950367","1234567","6154321"};
extern string EA1="----------------------------------------------------------------";//------------ Lifetime SerialNumber ------------
extern _SetBool boolUnlimited=A;//Lifetime Unlimited
extern int Lifetime_Y=0;//Lifetime Add Years
extern int Lifetime_M=3;//Lifetime Add Months
extern int Lifetime_D=0;//Lifetime Add Day

extern _SetBool boolAlert=B;
datetime _TimeExp;
MqlDateTime _TimeMqlExp;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   _printf(__FUNCTION__,__LINE__,"+------------------------------------------------------------------+");
   SerialNumber_Generate(SerialNumber_CreateExpire());
   _printf(__FUNCTION__,__LINE__,"+------------------------------------------------------------------+");

//--- create timer
   EventSetTimer(60);

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
void _printf(string fun,int line,string var)
  {
   printf(fun+"["+string(line)+"]# "+var);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SerialNumber_CreateExpire0()
  {
//---Step0
   TimeToStruct(TimeCurrent(),_TimeMqlExp);//Time saver can not hack.

   int h=(_TimeMqlExp.hour);
   int m=(_TimeMqlExp.min);
   int d=(_TimeMqlExp.day)+Lifetime_D+1;
   int M=(_TimeMqlExp.mon)+Lifetime_M;
   int y=(_TimeMqlExp.year)+Lifetime_Y;

   _TimeExp=StrToTime(string(y)+"."+string(M)+"."+string(d));//+" "+string(h)+":"+string(m));
   _printf(__FUNCTION__,__LINE__," _______________. Expire: ["+TimeToString(_TimeExp,TIME_DATE|TIME_MINUTES)+"]");
//+------------------------------+
   string LongCode=_flag+"#";
   if(boolUnlimited)
      LongCode+="Unlimited";
   else
      LongCode+=string(_TimeExp);

   for(int i=0;i<ArraySize(List_ACCOUNTAllow);i++)
     {
      LongCode+="#"+List_ACCOUNTAllow[i];
     }
   _printf(__FUNCTION__,__LINE__,"Code: ["+LongCode+"] "+string(StringLen(LongCode)));
//+------------------------------------------------------------------+
   return LongCode;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SerialNumber_Generate(string  client)
  {
   _printf(__FUNCTION__,__LINE__,"---");
   _printf(__FUNCTION__,__LINE__,"Get: ["+client+"] "+string(StringLen(client)));
   uchar dst[],src[],arrKey[];

   StringToCharArray(MasterKey,arrKey);

   StringToCharArray(client,src);
   CryptEncode(CRYPT_DES,src,arrKey,dst);

   ArrayInitialize(arrKey,0x00);
   CryptEncode(CRYPT_BASE64,dst,arrKey,src);

   string var=CharArrayToString(src);
   
   if(boolAlert)
     {
      Alert(var);
     }

   _printf(__FUNCTION__,__LINE__,"Set: ["+var+"] "+string(StringLen(var)));
   return var;
  }
//+------------------------------------------------------------------+
