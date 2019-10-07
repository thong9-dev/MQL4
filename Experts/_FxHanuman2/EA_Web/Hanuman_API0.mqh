//+------------------------------------------------------------------+
//|                                                      hanuman.mqh |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 05-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property strict

#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import

#import "Wininet.dll"
int InternetOpenW(string,int,string,string,int);
int InternetConnectW(int,string,int,string,string,int,int,int);
int HttpOpenRequestW(int,string,string,int,string,int,string,int);
int InternetOpenUrlW(int,string,string,int,int,int);
int InternetReadFile(int,uchar  &arr[],int,int &OneInt[]);
int InternetCloseHandle(int);
int HttpQueryInfoW(int,int,uchar &lpvBuffer[],int &lpdwBufferLength,int &lpdwIndex);
#import

#define READURL_BUFFER_SIZEX   100
#define HTTP_QUERY_STATUS_CODE  19
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHanuman
  {
   string            SaverHost;
   int               SaverStatus;
   string            Token;

   string            _GET;
   string            Package;

   bool              DevelopMode;

   int               Day_Temporary;
   int               Day_Extend;
public:
   string            i_ID;
   string            i_Name,i_NameS;
   string            i_COMPANY;

   int               i_Balance;
   bool              i_Type;

   //------
   bool              Status;
   int               TimeSaver;

   string            CrackName;
   void  CHanuman(void)
     {
      Print("#--------------------------");
      Print("#"+__FUNCTION__);
      DevelopMode=getDevelopMode();
      Print(".DevelopMode: ["+string(DevelopMode)+"]");
      Print(string(__LINE__)+".Name: ["+AccountInfoString(ACCOUNT_NAME)+"]");

      Day_Temporary=15;
      Day_Extend=7;
      //IsDllsAllowed();
      //+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      //IsDllsAllowed();

      Status=false;

      string Gate="xml.php";

      //SaverHost="http://www.fxhanuman.com/web/eafx/"+Gate;
      SaverHost="http://127.0.0.1/HNM/"+Gate;

      i_ID=string(AccountInfoInteger(ACCOUNT_LOGIN));

      i_Name=AccountInfoString(ACCOUNT_NAME);
      Printd(string(__LINE__)+".i_Name: ["+i_Name+"]");
      i_NameS=StringSubstr(i_Name,0,2);
      StringToUpper(i_NameS);
      Printd(string(__LINE__)+".i_NameS: ["+i_NameS+"]");

      i_COMPANY=AccountInfoString(ACCOUNT_COMPANY);

      i_Balance=int(AccountInfoDouble(ACCOUNT_BALANCE));

      //---

      CrackName="Hanuman//"+i_ID+"_"+i_COMPANY+".txt";

      Check();
      Print("#--------------------------");
     }

   bool  Check(void)
     {
      Status=Check_1();
      Print("#"+__FUNCTION__+" : "+string(Status));

      return Status;
     }
   bool  Deinit(void)
     {
      _GET="?TYPE=REAL";
      _GET+="&CMD=OnDeinit&Token="+i_NameS;
      _GET+="&ID="+i_ID;

      if(ReadUrl(_GET,Package)==0)
        {
         return true;
        }
      return false;

     }
   //+----------------------------------------------------------------------------------------------------------------------+
private:
   //+----------------------------------------------------------------------------------------------------------------------+
   bool  Check_1()
     {
      Print("#--------------------------");
      Print("#"+__FUNCTION__);
      Print(string(__LINE__)+".DemoTesting: ["+string(DemoTesting())+"]");
      if(!DemoTesting())
        {
         int CrackHand=CrackFind();
         Print(string(__LINE__)+".CrackHand: ["+string(CrackHand)+"]");

         if(CrackHand>0)
           {
           }
         else
           {

           }
        }
      else
        {
         return true;
        }
      return false;
     }
   bool _Case()
     {
     
      switch(statement)
        {
         case  :

            break;
         default:
            break;
        }
     }
     int StrungTOint(){
     
     
     }
   bool  Check_()
     {
      Print("#--------------------------");
      Print("#"+__FUNCTION__);
      Print(string(__LINE__)+".DemoTesting: ["+string(DemoTesting())+"]");
      if(!DemoTesting())
        {

         int CrackHand=CrackFind();
         Print(string(__LINE__)+".CrackHand: ["+string(CrackHand)+"]");

         if(CrackHand>0)
           {
            string Package2="";
            Crack_Read(CrackHand,Package2);
            Printd(string(__LINE__)+".Crack_Read: ["+string(Package2)+"]");
            FileClose(CrackHand);

            string _Active=ReadTag(Package2,"Active");
            string _Time=ReadTag(Package2,"Time");
            string _Time_Exp=ReadTag(Package2,"Time_Exp");
            string _Deinit=ReadTag(Package2,"Deinit");

            Print("#--------------------------");
            Print(string(__LINE__)+".Deinit: ["+string(_Deinit)+"]");
            Print(string(__LINE__)+".Time_Exp: ["+string(_Time_Exp)+"]");
            Print(string(__LINE__)+".Time: ["+string(_Time)+"]");
            Print(string(__LINE__)+".Active: ["+string(_Active)+"]");
            Print("#--------------------------");

            //----------------------------------------------------------------------------------
            if(_Active=="Temporary")
              {
               Print(string(__LINE__)+".");
               if(EXP_Temporary(_Time_Exp))
                 {
                  Printd(string(__LINE__)+".Yes");

                  _GET="?TYPE=REAL";
                  _GET+="&CMD=GetXML&Token="+i_NameS;
                  _GET+="&ID="+i_ID;

                  int s=ReadUrl(_GET,Package);
                  Printd(string(__LINE__)+".Ping: ["+string(s)+"]");

                  if(s==0)
                    {
                     Printd(string(__LINE__)+".Package: ["+string(Package)+"]");
                     Crack_Write(Package);
                     Check_();

                     Deinit(ReadTag(Package,"Deinit"));
                    }
                  else if(s==1)
                    {
                     return false;
                    }
                  else
                    {

                    }
                 }
               else
                 {
                  Printd(string(__LINE__)+".NO:");

                  _GET="?TYPE=REAL";
                  _GET+="&CMD=GetXML&Token="+i_NameS;
                  _GET+="&ID="+i_ID;

                  int s=ReadUrl(_GET,Package);
                  Printd(string(__LINE__)+".Ping: ["+string(s)+"]");

                  if(s==0)
                    {
                     Printd(string(__LINE__)+".Package: ["+string(Package)+"]");
                     Crack_Write(Package);
                     Check_();

                     Deinit(ReadTag(Package,"Deinit"));
                    }
                  else if(s==1)
                    {
                     return true;
                    }
                  else
                    {

                    }
                 }
              }
            else
              {
               //Print(string(__LINE__)+"."+_Active);
               if(_Active=="Active")
                 {
                  return true;
                 }
               else
                 {

                  if(_Active=="Progress")
                    {
                     _GET="?TYPE=REAL";
                     _GET+="&CMD=GetXML&Token="+i_NameS;
                     _GET+="&ID="+i_ID;

                     int s=ReadUrl(_GET,Package);
                     Printd(string(__LINE__)+".Ping: ["+string(s)+"]");

                     if(s==0)
                       {
                        Printd(string(__LINE__)+".Package: ["+string(Package)+"]");
                        Crack_Write(Package);
                        Check_();
                        Printd(string(__LINE__)+".Active: ["+ReadTag(Package,"Active")+"]");

                        Deinit(ReadTag(Package,"Deinit"));
                       }
                     else if(s==1)
                       {
                        return true;
                       }
                     else
                       {

                       }
                    }
                  else
                    {
                     if(_Active=="inActive")
                       {
                        return false;
                       }
                     else
                       {
                        if(_Active=="Promotion")
                          {
                           Printd(string(__LINE__)+".Promotion0");

                           _GET="?TYPE=REAL";
                           _GET+="&CMD=GetXML&Token="+i_NameS;
                           _GET+="&ID="+i_ID;

                           int s=ReadUrl(_GET,Package);
                           Printd(string(__LINE__)+".Ping: ["+string(s)+"]");

                           if(s==0)
                             {
                              Printd(string(__LINE__)+".Package: ["+string(Package)+"]");

                              _Time=ReadTag(Package,"Time");
                              Printd(string(__LINE__)+"._Time: ["+string(_Time)+"]");
                             }
                           else if(s==1)
                             {
                              Crack_Write(XML_EXP_Temporary(Day_Extend));
                             }
                           else
                             {

                             }
                           //+++++++++++++++++++++++++++
                           if(EXP_Promotion(_Time,_Time_Exp))
                             {
                              Printd(string(__LINE__)+".Promotion1");
                              Crack_Write(Package);
                              Check_();
                              Deinit(ReadTag(Package,"Deinit"));
                             }
                           else
                             {
                              Printd(string(__LINE__)+".Promotion2");
                              return true;
                             }
                          }
                       }
                    }
                 }
              }
           }
         else
           {
            FileClose(CrackHand);

            _GET="?TYPE=REAL";
            _GET+="&CMD=GetXML&Token="+i_NameS;
            _GET+="&ID="+i_ID;

            int s=ReadUrl(_GET,Package);
            Printd(string(__LINE__)+".Ping: ["+string(s)+"]");

            if(s==0)
              {
               Printd(string(__LINE__)+".Package: ["+string(Package)+"]");

               Crack_Write(Package);

               Check_();

               Deinit(ReadTag(Package,"Deinit"));
              }
            else if(s==1)
              {

               Crack_Write(XML_EXP_Temporary(Day_Temporary));

               return true;
              }
            else
              {

              }

           }

        }
      else
        {
         return true;
        }
      Printd(string(__LINE__)+".");
      return false;

     }

   bool Deinit(string c)
     {

      if(StringToInteger(c))
        {
         _GET="?TYPE=REAL";
         _GET+="&CMD=OnDeinit&Token="+i_NameS;
         _GET+="&ID="+i_ID;

         if(ReadUrl(_GET,Package)==0)
            return true;
        }
      return false;
     }

   string XML_EXP_Temporary(int v)
     {
      datetime Date0=TimeCurrent();
      datetime DateC=D'1970.01.02 00:00:00'*v;
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

   bool EXP_Temporary(string d)
     {

      if(TimeCurrent()>=StringToTime(d))
         return true;
      return false;
     }

   bool EXP_Promotion(string d1,string d2)
     {

      if(StringToTime(d1)>=StringToTime(d2))
         return true;
      return false;
     }

   void Crack_Write(string Package_)
     {
      int handle=FileOpen(CrackName,FILE_WRITE,';');
      if(handle>0)
        {
         FileWrite(handle,Package_);
         FileClose(handle);
        }
     }

   void Crack_Read(int hand,string &str)
     {
      int    str_size;;
      while(!FileIsEnding(hand))
        {
         str_size=FileReadInteger(hand,INT_VALUE);
         str+=FileReadString(hand,str_size);
         //PrintFormat("@@@@"+str);
        }
     }

   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool DemoTesting()
     {
      return (isDemoState() || IsTesting() || IsOptimization())?true:false;
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   int CrackFind()
     {
      return FileOpen(CrackName,FILE_READ,';');
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
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
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void Printd(string v)
     {
      if(DevelopMode) Print(v);
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+

   void hanuman2(string cmd)
     {
      string Trade_ID=string(AccountInfoInteger(ACCOUNT_LOGIN));
      string Trade_Balance=string(AccountInfoDouble(ACCOUNT_BALANCE));
      //string s=ProductCode;
      //++++++++++++++++++++++++++
      Print("BODY["+Trade_ID+"]");
      //---
      string data="";
      ReadUrl("http://127.0.0.1/HNM/xml.php?from="+Trade_ID,data);
      Print("data: "+data);

      //Cut Body
      Print("data["+ReadTag(data,"data")+"]");
      Print("Trade_Status["+ReadTag(data,"Trade_Status")+"]");

      //+++++++++++++++++++
/*
      if(Read>0)
        {
         Print("Read: "+string(Read));
        }
      else
        {
         Print("Read: "+string(Read));
         _GET="?CMD=void";
         _GET+="&ID="+i_ID;

         ReadUrl(Saver+_GET,Data);
         Print("data:["+Data+"]");
         //++

         int handle=FileOpen(CrackName,FILE_WRITE,';');
         if(handle>0)
           {
            FileWrite(handle,Data);
            FileClose(handle);
           }
         //++
        }
      FileClose(Read);

      datetime  TimeL=TimeLocal();
      Print("TimeL: "+TimeL);

      return false;
      */
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
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
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   int ReadUrl(string url,string &data)
     {

      if(!IsConnected())
         return -1;
      int r=-1;

      url=SaverHost+url;
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
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   bool isDemoState()
     {
      string strName=AccountInfoString(ACCOUNT_SERVER);
      StringToLower(strName);
      //printf(strName);
      bool r=(StringFind(strName,"demo",0)>=0)?true:false;
      //printf(r);
      r=IsDemo() || r;
      return r;

     }

  };
//+------------------------------------------------------------------+
