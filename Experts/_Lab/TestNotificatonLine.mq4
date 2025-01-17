//+------------------------------------------------------------------+
//|                                          TestNotificatonLine.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://notify-bot.line.me/my/"
#property version   "1.00"
#property strict

#include <Tools/Method_Tools.mqh>
#include <Tools/Method_MQL4.mqh>

extern string exToken="TyZ3YphZeGAOipkVMNFKYe3lFAqlTxE0WzaCag8nm46";
extern string exMMS="\nHello Divas.\n2\nLove";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("#-------------------------------------------------------#");

//---
//LineNotify(exToken,exMMS);
   //LineNotify(exToken,"stickerPackageId=1");
//TakePicture();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
void LineNotify(string _Token,string _Massage)
  {
   string headers;
   char _post[],_result[];

   headers="Authorization: Bearer "+_Token+"\r\n";
   headers+="Content-Type: application/x-www-form-urlencoded\r\n";
   headers+="message: test\r\n";
   headers+="stickerPackageId: 1\r\n";
   headers+="stickerId: 113\r\n";
//---

//ArrayResize(_post,StringToCharArray("message="+_Massage,_post,0,WHOLE_ARRAY,CP_UTF8)-1);
//ArrayResize(_post,StringToCharArray({"-F 'stickerPackageId=1' -F 'stickerId=113'",_post,0,WHOLE_ARRAY,CP_UTF8)-1);
//char _postStr[]={"message=test","stickerPackageId=2","stickerId=34"};
//ArrayResize(_post,-1);
   StringToCharArray("message=1",_post,0,0,CP_UTF8);
//StringToCharArray("stickerPackageId=2",_post,1,0,CP_UTF8);
//StringToCharArray("stickerId=34",_post,2,0,CP_UTF8);
   string str=cI(ArraySize(_post))+"#";
   for(int i=0;i<ArraySize(_post);i++)
     {
      str+=_post[i]+"|";
     }
   Print(str);
//---
   int res=WebRequest("POST","https://notify-api.line.me/api/notify",headers,10000,_post,_result,headers);

   int _Err=GetLastError();
   string _ErrStr=cI(_Err);
   if(_Err==4000)
      _ErrStr="ok";

   Print(cI(__LINE__)+"#Status code: [",res,"] error: [",_ErrStr,"]");
   Print(cI(__LINE__)+"#Server response: [",CharArrayToString(_result),"]");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TakePicture()
//+------------------------------------------------------------------+
  {
   string filename= "ScreenShot\\"+IntegerToString(TimeYear(TimeCurrent()))+"\\"+Symbol()+"\\"+IntegerToString(TimeMonth(TimeCurrent()))+"\\"+IntegerToString(TimeDay(TimeCurrent()))+"\\"+IntegerToString(TimeHour(TimeCurrent()))+"_"+IntegerToString(TimeMinute(TimeCurrent()))+".png";
   int ChartWidth =1366;
   int ChartHeight=768;

   bool TakeScreenShot=ChartScreenShot(0,filename,ChartWidth,ChartHeight,ALIGN_RIGHT);
  }
//+------------------------------------------------------------------+
