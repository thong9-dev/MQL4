//+------------------------------------------------------------------+
//|                                                           SN.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//#include "SN_Generate.mq4";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _SetBool
  {
   A=False,    // No
   B=True,     // Yes
  };

extern string _flag="DIVAS";//EA_NameFlag
extern string EA0="Master";//------------------------------------------------------------------
//--- Master ---
extern string MasterKey="PUKDEE";
string List_ACCOUNTAllow[]={"32153992","1234567","6154321"};
extern string EA1="----------------------------------------------------------------";//------------ Lifetime SerialNumber ------------
extern _SetBool boolUnlimited=A;//Lifetime Unlimited
extern int Lifetime_Y=0;//Lifetime Add Years
extern int Lifetime_M=3;//Lifetime Add Months
extern int Lifetime_D=0;//Lifetime Add Day

extern _SetBool boolAlert=A;
extern string EA2="Client";//------------------------------------------------------------------
//--- Client ---
string Key="XXXSSS";
string List_ACCOUNTAllowSplit[1];

extern string _SN;//SerialNumber

//--- System ---
datetime _TimeCurrent,_TimeExp;
MqlDateTime _TimeMqlExp;

bool Result_Pass=false;
string Result_SN;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//Key=MasterKey;
   _printf(__FUNCTION__,__LINE__,"+------------------------------------------------------------------+");
   string sms;

   _TimeCurrent=TimeCurrent();

//---Step1 Encode
   Result_SN=SerialNumber_Generate(SerialNumber_CreateExpire());
//Alert(string(Result));
//---Step2 Decode
//+------------------------------------------------------------------+

//Result_Pass=SerialNumber_Check(_SN);
   Result_Pass=SerialNumber_Check(Result_SN);
//+------------------------------------------------------------------+
   printf("---");
   string RP=string(Result_Pass);
   StringToUpper(RP);
   _printf(__FUNCTION__,__LINE__,"SerialNumberStatus ***"+RP+"***");

   sms+="\n1# Test: "+string(IsTesting())+" Demo: "+string(IsDemo());
   sms+="\n1# CurrentSV: "+TimeToString(_TimeCurrent,TIME_DATE|TIME_MINUTES);
   sms+="\n2#      Expire.: "+TimeToString(_TimeExp,TIME_DATE|TIME_MINUTES);
   sms+="\n\nSerialNumberStatus ***"+RP+"***";
   Comment(sms);
//--- create timer
   EventSetTimer(60);

//---
   _printf(__FUNCTION__,__LINE__,"+------------------------------------------------------------------+");
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
//+------------------------------------------------------------------+
//| Encrypt client information and return the password
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
//|                                                                  |
//+------------------------------------------------------------------+
bool SerialNumber_Check(string client)
  {
   _printf(__FUNCTION__,__LINE__,"---");
   _printf(__FUNCTION__,__LINE__,"_ Get: ["+client+"] "+string(StringLen(client)));
   bool chk_LOGIN;
   bool chk_Expire;
//+------------------------------------------------------------------+
   Key="PUKDEE"+"";
   string Expire=SerialNumber_Decode(Key,client);
//_printf(__FUNCTION__,__LINE__,Expire);
//---
   StringSplit(Expire,StringGetCharacter("#",0),List_ACCOUNTAllowSplit);
   if(List_ACCOUNTAllowSplit[0]!=_flag)
     {
      _printf(__FUNCTION__,__LINE__,"SN is Wrong product !!!");
      return false;
     }
//---

   if(ArraySize(List_ACCOUNTAllowSplit)!=2)
      _printf(__FUNCTION__,__LINE__,"Login has use.");
   for(int i=2;i<ArraySize(List_ACCOUNTAllowSplit);i++)
     {
      _printf(__FUNCTION__,__LINE__,"["+string(i-1)+"] "+List_ACCOUNTAllowSplit[i]);
     }
   Expire=List_ACCOUNTAllowSplit[0];
//+------------------------------------------------------------------+

   if(Expire=="Unlimited")
     {

      if(ArraySize(List_ACCOUNTAllowSplit)==2)
        {
         _printf(__FUNCTION__,__LINE__," Type*: Full-Unlimited");
         return true;
        }
      else
        {
         chk_LOGIN=SerialNumber_chkLogin(List_ACCOUNTAllowSplit);
         _printf(__FUNCTION__,__LINE__," Type*: Fix-Unlimited *"+string(chk_LOGIN)+"*");
         return chk_LOGIN;
        }
     }
   else
     {
      if((IsTesting() || IsDemo()) && false)
        {
         _printf(__FUNCTION__,__LINE__," Type*: Testing or Demo");
         return true;
        }
      else
        {
         //+-----------------------------------------------------------------+
         chk_Expire=SerialNumber_chkExpire(Expire);
         if(chk_Expire)
           {
            if(ArraySize(List_ACCOUNTAllowSplit)==2)
              {
               _printf(__FUNCTION__,__LINE__," Type*: Full-Expire");
               return true;
              }
            else
              {
               chk_LOGIN=SerialNumber_chkLogin(List_ACCOUNTAllowSplit);
               _printf(__FUNCTION__,__LINE__," Type*: Fix-Expire *"+string(chk_LOGIN)+"*");
               return chk_LOGIN;
              }
           }
         else
           {
            _printf(__FUNCTION__,__LINE__,"SN-Key Expire.!! : "+Expire);
            return false;
           }
        }
     }
   return 0;
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
string SerialNumber_Decode(string _Key,string client)
  {
   uchar arrKey[],arr1[],arr2[];

   StringToCharArray(_Key,arrKey);

   StringToCharArray(client,arr1,0,StringLen(client),0);
//_printf(__FUNCTION__,__LINE__,"_ Get: ["+CharArrayToString(arr1)+"] "+string(ArraySize(arr1)));

   CryptDecode(CRYPT_BASE64,arr1,arrKey,arr2);
   CryptDecode(CRYPT_DES,arr2,arrKey,arr1);

//_printf(__FUNCTION__,__LINE__,"_ Set: ["+CharArrayToString(arr1)+"] "+string(ArraySize(arr1)));

   return CharArrayToString(arr1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SerialNumber_chkLogin(string &var[])
  {
   string _LOGIN=string(AccountInfoInteger(ACCOUNT_LOGIN));
   _printf(__FUNCTION__,__LINE__,"Login by. "+_LOGIN);
   bool chk_LOGIN=false;

   for(int i=1;i<ArraySize(var);i++)
     {
      if(var[i]==_LOGIN)
        {
         chk_LOGIN=true;
         break;
        }
     }

   return chk_LOGIN;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SerialNumber_chkExpire(string Decode)
  {
   datetime date_Decode=datetime(Decode);
   bool chk_Expire=TimeCurrent()<=date_Decode;

   if(!chk_Expire)
     {
      MqlDateTime diff;
      TimeToStruct(TimeCurrent()-date_Decode,diff);
     }
   return chk_Expire;
  }
//+------------------------------------------------------------------+
string SerialNumber_CreateExpire()
  {
//---Step0
   TimeToStruct(_TimeCurrent,_TimeMqlExp);//Time saver can not hack.

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
