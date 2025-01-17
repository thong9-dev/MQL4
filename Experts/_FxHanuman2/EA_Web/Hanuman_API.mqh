//+------------------------------------------------------------------+
//|                                                      hanuman.mqh |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 05-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property strict

#import "Wininet.dll"
int InternetOpenW(string,int,string,string,int);
int InternetConnectW(int,string,int,string,string,int,int,int);
//int HttpOpenRequestW(int,string,string,int,string,int,string,int);
int InternetOpenUrlW(int,string,string,int,int,int);
int InternetReadFile(int,uchar  &arr[],int,int &OneInt[]);
int InternetCloseHandle(int);
int HttpQueryInfoW(int,int,uchar &lpvBuffer[],int &lpdwBufferLength,int &lpdwIndex);
#import

#import "shell32.dll"
int ShellExecuteW(int hWnd,string Verb,string File,string Parameter,string Path,int ShowCommand);
#import

#define READURL_BUFFER_SIZEX   100
#define HTTP_QUERY_STATUS_CODE  19
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHanuman
  {
   bool              isEncode;
   bool              DevelopMode;
   bool              i_Type;

   string            Receiver;
   int               Day_Temporary_New;
   int               Day_Temporary_Promotion;
   int               Day_Temporary_Progress;

public:

   string            i_SaverHost;
   string            i_SaverGateName;
   string            i_Product;

   string            i_ID;
   string            i_Name,i_NameS;
   string            i_COMPANY;

   int               i_Balance;
   string            i_TypeStr;

   string            i_Time_Current;
   string            i_CrackName;

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+


   //---

   void _Init(string _SaverHost,
              string _GateName,
              string _Product,
              bool _Encode)
     {
      _setData(_SaverHost,_GateName,_Product,_Encode);

      bool result=_Main();
      Label_EXP(result);

      Print(string(__FUNCTION__)+" @Status: ["+string(result)+"]");
     }

   bool _Check()
     {

      bool result=_Main();
      Print(string(__FUNCTION__)+" @Status: ["+string(result)+"]");
      Label_EXP(result);
      return result;
     }

   bool  _Deinit(void)
     {
      Print(string(__LINE__)+".i_TypeStr: ["+string(i_TypeStr)+"]");

      string _GET="?TYPE="+i_TypeStr;
      _GET+="&CMD=OnDeinit&Token="+i_NameS;
      _GET+="&ID="+i_ID;
      _GET+="&PR="+i_Product;

      if(ReadUrl(_GET,_GET)==0)
        {
         return true;
        }
      return false;

     }

   void _ChartEvent(int id,
                    long lparam,
                    double dparam,
                    string sparam)
     {
      if(id==CHARTEVENT_OBJECT_CLICK)
        {
         Print("The mouse has been clicked on the object with name '"+sparam+"'");
         if(sparam=="FxHanuman")
           {

            string app[]=
              {
               "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
               "C:\\Program Files\\Mozilla Firefox\\firefox.exe",
               "C:\\Program Files\\internet explorer\\iexplore.exe"
              };

            for(int i=0;i<ArraySize(app);i++)
              {
               if(Shell(app[i],i_SaverHost))
                  break;
              }
           }
        }
     }
   //+------------------------------------------------------------------+
private:
   //+------------------------------------------------------------------+
   bool  _Main(void)
     {

      Print("#--------------------------");
      //Print("#"+__FUNCTION__);

      bool Demo_Testing=isDemo_Testing();
      Print(string(__LINE__)+".Demo or Backtesting: ["+BoolStr(Demo_Testing)+"]");

      if(!Demo_Testing)
        {

         int CrackHand=Crack_Find();
         Print(string(__LINE__)+".CrackHand: ["+BoolStr(CrackHand)+"]"+"["+string(CrackHand)+"]");

         if(CrackHand>0)
           {
            Crack_Read(CrackHand,Receiver);
            FileClose(CrackHand);

            Printd(string(__LINE__)+".Receiver Crack: ["+string(Receiver)+"]");

            bool result=CASE(ReadTag(Receiver,"Active"),ReadTag(Receiver,"Time_Exp"));
            //Print(string(__LINE__)+".Hanuman["+Product+"]: ["+string(result)+"]");
            return result;

           }
         else
           {
            int Ping=getXML(Receiver);
            FileClose(CrackHand);

            Print(string(__LINE__)+".Ping: ["+string(Ping)+"]");
            Printd(string(__LINE__)+".Receiver: ["+string(Receiver)+"]");

            if(Ping==0)
              {
               Crack_Write(i_CrackName,Receiver);

               string Active=ReadTag(Receiver,"Active");
               Printd(string(__LINE__)+".Active: ["+string(Active)+"]");

               bool result=CASE_New(Active);
               //Print(string(__LINE__)+".Hanuman["+Product+"]: ["+string(result)+"]");
               return result;

              }
            if(Ping==1)
              {
               Crack_Write(i_CrackName,Temporary_MakeText(Day_Temporary_New));
               //Print(string(__LINE__)+".Hanuman["+Product+"]: ["+string(true)+"]");
               return true;
              }
           }
        }
      else
        {
         if(i_Type)
           {
            int Ping=getXML(Receiver);
            //Print(string(__LINE__)+".Hanuman["+string(Ping)+"]: ["+string(true)+"]");
           }
         return true;
        }
      //Print(string(__LINE__)+".Hanuman["+Product+"]: ["+string(false)+"]");
      return false;
     }

   void  _setData(
                  string _SaverHost,
                  string _GateName,
                  string _Product,
                  bool _Encode
                  )
     {
      Print("#--------------------------");
      Print("#"+__FUNCTION__);

      //---Host
      i_SaverHost=_SaverHost;
      i_SaverGateName=_GateName;

      i_Product=_Product;
      isEncode=_Encode;

      //---Infomation
      i_ID=string(AccountInfoInteger(ACCOUNT_LOGIN));
      i_Name=AccountInfoString(ACCOUNT_NAME);
      i_COMPANY=AccountInfoString(ACCOUNT_COMPANY);
      //
      i_Balance=int(AccountInfoDouble(ACCOUNT_BALANCE));

      i_NameS=StringSubstr(i_Name,0,2);
      StringToUpper(i_NameS);

      isDemo();

      //---Crack
      i_CrackName="Hanuman//"+i_ID+"_"+i_COMPANY+"_"+_Product+".txt";

      //---Temporary Day
      Day_Temporary_New=15;
      Day_Temporary_Promotion=5;
      Day_Temporary_Progress=7;

      //---Print
      Print(string(__LINE__)+".i_Balance: ["+string(i_Balance)+"]");
      Print(string(__LINE__)+".i_COMPANY: ["+i_COMPANY+"]");
      Print(string(__LINE__)+".i_ID: ["+i_ID+"]["+i_TypeStr+"]");
      Print(string(__LINE__)+".i_Name: ["+i_Name+"]["+i_NameS+"]");
      Print(string(__LINE__)+".i_Product: ["+_Product+"]");

      DevelopMode=getDevelopMode();
     }

   int CASE_Number(string v)
     {
      string STR[]={"Temporary","Promotion","Progress","inActive","Active"};

      for(int i=0;i<ArraySize(STR);i++)
        {
         if(STR[i]==v)
           {
            Print(string(__LINE__)+"."+__FUNCTION__+": ["+v+":"+string(i)+"]");
            return i;
           }
        }
      return -1;
     }

   bool CASE(string v,string date_exp)
     {

      int Ping=-1;
      string Active,Time_,Time_Exp;

      switch(CASE_Number(v))
        {
         case  0://Temporary
            Ping=getXML(Receiver);

            if(Ping==0)
              {
               Crack_Write(i_CrackName,Receiver);

               Active=ReadTag(Receiver,"Active");

               if(Active=="Active" || Active=="Promotion" || Active=="Progress")
                  return true;
               else
                  return false;
              }
            if(Ping==1)
              {
               if(Time_EXP(Time_Borker(),date_exp))
                  return false;
               else
                  return true;
              }

            break;
         case  1://Promotion
            Ping=getXML(Receiver);

            if(Ping==0)
              {
               Active=ReadTag(Receiver,"Active");
               Time_=ReadTag(Receiver,"Time");

               if(Active=="Active")
                 {
                  Crack_Write(i_CrackName,Receiver);
                  return true;
                 }
               else
                 {
                  if(Time_EXP(Time_,date_exp))
                     return false;
                  else
                     return true;
                 }
              }

            if(Ping==1)
              {
               if(Time_EXP(Time_Borker(),date_exp))
                 {
                  Crack_Write(i_CrackName,Temporary_MakeText(Day_Temporary_Promotion));
                 }
               return true;
              }

            break;
         case  2://Progress
            Ping=getXML(Receiver);

            if(Ping==0)
              {
               Crack_Write(i_CrackName,Receiver);

               Active=ReadTag(Receiver,"Active");

               if(Active=="Active" || Active=="Promotion" || Active=="Progress")
                  return true;
               else
                  return false;

              }
            if(Ping==1)
              {
               if(Time_EXP(Time_Borker(),date_exp))
                 {
                  Crack_Write(i_CrackName,Temporary_MakeText(Day_Temporary_Progress));
                 }
               return true;
              }

            break;
         case  3://inActive
            return false;
         case  4://Active
            return true;
         default:
            return false;
        }

      return false;
     }

   bool CASE_New(string v)
     {
      //"Temporary","Promotion","Progress","inActive","Active"
      switch(CASE_Number(v))
        {
         case  0://Temporary
            return false;
         case  1://Promotion
            return true;
         case  2://Progress
            return true;
         case  3://inActive
            return false;
         case  4://Active
            return true;
         default:
            return false;
        }

      return false;
     }

   void Crack_Read(int hand,string &str)
     {
      int    str_size;
      while(!FileIsEnding(hand))
        {
         str_size=FileReadInteger(hand,INT_VALUE);
         str+=FileReadString(hand,str_size);

         if(isEncode)
            str=Str_Decode(str);

         //PrintFormat("@@@@"+str);
        }
      FileClose(hand);
     }

   void Crack_Write(string Name,string str)
     {
      int handle=FileOpen(Name,FILE_WRITE,';');
      if(handle>0)
        {
         if(isEncode)
            FileWrite(handle,Str_Generate(str));
         else
            FileWrite(handle,str);
         FileClose(handle);

        }
     }

   int getXML(string &PackReceiver)
     {
      string _GET="?TYPE="+i_TypeStr;
      _GET+="&CMD=GetXML&Token="+i_NameS;
      _GET+="&ID="+i_ID;
      _GET+="&PR="+i_Product;

      Printd(string(__LINE__)+"._GET: ["+string(_GET)+"]");

      return ReadUrl(_GET,PackReceiver);
     }

   string Time_Borker()
     {
      datetime Date0=TimeCurrent();
      datetime DateC=D'1970.01.02 00:00:00'*1;
      datetime DateE=Date0-DateC;

      return string(DateE);
     }

   bool Time_EXP(string d1,string d2)
     {

      if(StringToTime(d1)>=StringToTime(d2))
         return true;
      return false;
     }

   string Temporary_MakeText(int _Day)
     {
      datetime Date0=TimeCurrent();
      datetime DateC=D'1970.01.02 00:00:00'*_Day;
      datetime DateE=Date0+DateC;

      //Printd(string(__LINE__)+". TimeCurrent(): ["+string(Date0)+"]");
      //Printd(string(__LINE__)+". DateC: ["+string(DateC)+"]");
      //Printd(string(__LINE__)+". DateE: ["+string(DateE)+"]");

      string Temp="<?xml version=\"1.0\"?>";
      Temp+="<data>";
      Temp+="<Active>Temporary</Active>";
      Temp+="<Time>"+string(Date0)+"</Time>";
      Temp+="<Time_Exp>"+string(DateE)+"</Time_Exp>";
      Temp+="</data>";

      return Temp;
     }

   string ReadTag(string data,string tag)
     {

      string Start="<"+tag+">";
      string End="</"+tag+">";

      int iStart=StringFind(data,Start);
      int iEnd=StringFind(data,End);
      int iLengt=(iEnd-iStart+1)-StringLen(End);

      //Print("iStart: "+iStart);
      //Print("iEnd: "+iEnd);
      //Print("iLengt: "+iLengt);

      return StringSubstr(data,iStart+StringLen(Start),iLengt);

      //Print("cut: ["+cut+"]");
     }

   int ReadUrl(string url,string &data)
     {

      if(!IsConnected())
         return -1;
      int r=-1;

      url=i_SaverHost+i_SaverGateName+url;
      Printd(string(__LINE__)+".url: ["+string(url)+"]");

      int HttpOpen=InternetOpenW(" ",0," "," ",0);
      int HttpConnect = InternetConnectW(HttpOpen, "", 80, "", "", 3, 0, 1);
      int HttpRequest = InternetOpenUrlW(HttpOpen, url, NULL, 0, 0, 0);

      uchar cBuff[5];
      int cBuffLength=10;
      int cBuffIndex=0;
      int HttpQueryInfoW=HttpQueryInfoW(HttpRequest,HTTP_QUERY_STATUS_CODE,cBuff,cBuffLength,cBuffIndex);

      // HTTP Codes... Only the 1st character (4xx, 5xx, etc)
      int http_code=(int) CharArrayToString(cBuff,0,WHOLE_ARRAY,CP_UTF8);

      if(http_code==4 || http_code==5)
        { // 4XX || 5XX
         Print("HTTP Error: ",http_code,"XX");
         if(HttpRequest>0) InternetCloseHandle(HttpRequest);
         if(HttpConnect>0) InternetCloseHandle(HttpConnect);
         if(HttpOpen>0) InternetCloseHandle(HttpOpen);
         data="ERROR";
         r=1;
        }
      else
        {
         int read[1];
         uchar  Buffer[];
         ArrayResize(Buffer,READURL_BUFFER_SIZEX+1);
         data="";
         while(true)
           {
            InternetReadFile(HttpRequest,Buffer,READURL_BUFFER_SIZEX,read);
            string strThisRead=CharArrayToString(Buffer,0,read[0],CP_UTF8);
            if(read[0]>0)
               data=data+strThisRead;
            else
               break;
           }

         r=0;

        }

      if(HttpRequest>0)
         InternetCloseHandle(HttpRequest);
      if(HttpConnect>0)
         InternetCloseHandle(HttpConnect);
      if(HttpOpen>0)
         InternetCloseHandle(HttpOpen);

      return r;
     }

   int Crack_Find()
     {
      return FileOpen(i_CrackName,FILE_READ,';');
     }

   bool isDemo()
     {
      string strName=AccountInfoString(ACCOUNT_SERVER);
      StringToLower(strName);
      //printf(strName);
      bool r=(StringFind(strName,"demo",0)>=0)?true:false;
      //printf(r);
      r=IsDemo() || r;

      i_Type=r;
      i_TypeStr=(i_Type)?"DEMO":"REAL";
      return r;
     }

   bool isDemo_Testing()
     {
      return (isDemo() ||IsTesting() || IsOptimization())?true:false;
     }

   string BoolStr(bool v)
     {
      return (v)?"True":"False";
     }

   void Printd(string v)
     {
      if(DevelopMode) Print("$ "+v);
     }

   bool getDevelopMode()
     {
      //string DevList[]={"Werasiri Lapukdee","Weerasiri Lapukdee"};
      string DevList[]={""};

      bool fund=false;
      for(int i=0;i<ArraySize(DevList);i++)
        {
         if(DevList[i]==AccountInfoString(ACCOUNT_NAME))
           {
            fund=true;
            break;
           }

        }
      return fund;
     }

   string Str_Generate(string  client)
     {
      //Printd(__FUNCTION__+__LINE__+"---");
      //Printd(__FUNCTION__+__LINE__+"Get: ["+client+"] "+string(StringLen(client)));

      uchar dst[],src[],arrKey[];

      StringToCharArray(i_ID,arrKey);

      StringToCharArray(client,src);
      CryptEncode(CRYPT_DES,src,arrKey,dst);

      ArrayInitialize(arrKey,0x00);
      CryptEncode(CRYPT_BASE64,dst,arrKey,src);

      string var=CharArrayToString(src);

      //Printd(__FUNCTION__+__LINE__+"Set: ["+var+"] "+string(StringLen(var)));
      return var;
     }

   string Str_Decode(string client)
     {
      uchar arrKey[],arr1[],arr2[];

      StringToCharArray(i_ID,arrKey);

      StringToCharArray(client,arr1,0,StringLen(client),0);
      //_printf(__FUNCTION__,__LINE__,"_ Get: ["+CharArrayToString(arr1)+"] "+string(ArraySize(arr1)));

      CryptDecode(CRYPT_BASE64,arr1,arrKey,arr2);
      CryptDecode(CRYPT_DES,arr2,arrKey,arr1);

      //_printf(__FUNCTION__,__LINE__,"_ Set: ["+CharArrayToString(arr1)+"] "+string(ArraySize(arr1)));

      return CharArrayToString(arr1);
     }

   bool Shell(string file,string parameters="")
     {
#define DEFDIRECTORY NULL
#define OPERATION "open"
#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10
#define SW_FORCEMINIMIZE    11
#define SW_MAX              11

      int r=ShellExecuteW(0,OPERATION,file,parameters,DEFDIRECTORY,0);

      if(r<=32)
        {
         Print("Shell failed: ",r);
         return(false);
        }
      return(true);
     }

   void Label_EXP(bool v)
     {
      string LabelName="FxHanuman";
      if(v)
        {
         string  getTOOLTIP=ObjectGetString(ChartID(),LabelName,OBJPROP_TOOLTIP);
         //Print(string(__LINE__)+".getTOOLTIP: ["+string(getTOOLTIP)+"]");

         StringReplace(getTOOLTIP,"|"+i_Product,"");
         StringReplace(getTOOLTIP,i_Product+"|","");
         StringReplace(getTOOLTIP,i_Product,"");

         ObjectSetString(ChartID(),LabelName,OBJPROP_TOOLTIP,getTOOLTIP);
         if(getTOOLTIP=="")
           {
            ObjectDelete(ChartID(),LabelName);
           }
         //Print(string(__LINE__)+".getTOOLTIP: ["+string(getTOOLTIP)+"]");
        }
      else
        {
         LabelCreate(0,0,LabelName,10,20,CORNER_LEFT_LOWER,
                     "FxHanuman.com",i_Product,
                     9,C'255,200,0',
                     true,false,false,0);
        }

     }

   bool LabelCreate(const long              chart_ID=0,// chart's ID 
                    const int               sub_window=0,// subwindow index 
                    const string            name="Label",             // label name 
                    const int               x=0,                      // X coordinate 
                    const int               y=0,                      // Y coordinate 
                    const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                    const string            text="Label",             // text 
                    const string            TOOLTIP="TOOLTIP",// TOOLTIP 
                    const int               font_size=10,             // font size 
                    const color             clr=clrRed,               // color 

                    const bool              back=false,               // in the background 
                    const bool              selection=false,          // highlight to move 
                    const bool              hidden=true,              // hidden in the object list 
                    const long              z_order=0)                // priority for mouse click 
     {
      //--- reset the error value 
      ResetLastError();
      //--- create a text label 
      if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
        {
         string  getTOOLTIP=ObjectGetString(chart_ID,name,OBJPROP_TOOLTIP);
         if(StringFind(getTOOLTIP,TOOLTIP,0)!=0)
           {
            getTOOLTIP+="|"+TOOLTIP;
            ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,getTOOLTIP);
           }
        }
      else
        {
         ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,TOOLTIP);
        }
      //--- set label coordinates 
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //--- set the chart's corner, relative to which point coordinates are defined 
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      //--- set the text 
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);

      //--- set text font 
      ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
      //--- set font size 
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- set the slope angle of the text 
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,0);
      //--- set anchor type 
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      //--- set color 
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- display in the foreground (false) or background (true) 
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of moving the label by mouse 
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list 
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart 
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution 
      return(true);
     }

  };
//+------------------------------------------------------------------+
