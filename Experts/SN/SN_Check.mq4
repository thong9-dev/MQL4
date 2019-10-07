//+------------------------------------------------------------------+
//|                                                     SN_Check.mq4 |
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
//--- Client ---
string SerialNumber_Key="PUKDEE";
string SerialNumber_Flag="DIVAS";//EA_NameFlag
string List_ACCOUNTAllowSplit[1];
//---
bool SN_Pass=false;
//---
//extern string _SN="qJrt4yp/b6aYS4OfUrZYOTL18lv/oWVdm+9ciHcqRY4Oa/jbyfZ0R0rMNg0HfHmNWFMU5Mdb4tw=";//SerialNumber
extern string _SN="Enter the product number here.";//SerialNumber


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SN_Pass=SerialNumber_Check(_SN);
//+------------------------------------------------------------------+
   printf("---");
   string RP=string(SN_Pass);
   StringToUpper(RP);
   _printf(__FUNCTION__,__LINE__,"SerialNumberStatus ***"+RP+"***");
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
bool SerialNumber_Check(string client)
  {
   //_printf(__FUNCTION__,__LINE__,"---");
   _printf(__FUNCTION__,__LINE__,"_ Get: ["+client+"] "+string(StringLen(client)));
   bool chk_LOGIN;
   bool chk_Expire;
//+------------------------------------------------------------------+
   string Expire=SerialNumber_Decode(SerialNumber_Key,client);
//_printf(__FUNCTION__,__LINE__,Expire);
//---
   StringSplit(Expire,StringGetCharacter("#",0),List_ACCOUNTAllowSplit);
   if(List_ACCOUNTAllowSplit[0]!=SerialNumber_Flag)
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
