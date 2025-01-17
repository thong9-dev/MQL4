//+------------------------------------------------------------------+
//|                                  [EACARR001] CarryTrade_Sync.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum cORDER
  {
   eOpenTime=0,
   eTicket=1,
   eType=2,
   eLots=3,
   eSymbol=4,
   ePrice=5,
   eSL=6,
   eTP=7,
   eComment=8,
   eMagic=9
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eTimeZone
  {
   eTimeZone0=-12,//	-12: International Date Line West
   eTimeZone1=-11,//	-11: Midway Island, Samoa
   eTimeZone2=-10,//	-10: Hawaii
   eTimeZone3=-9,//	-09: Alaska
   eTimeZone4=-8,//	-08: Pacific Time (US and Canada); Tijuana
   eTimeZoneA=-7,//	-07: Mountain Time (US and Canada)
   eTimeZone14=-6,//	-06: Central Time (US and Canada)
   eTimeZone23=-5,//	-05: Eastern Time (US and Canada)
   eTimeZone32=-4,//	-04: Atlantic Time (Canada)
   eTimeZone3C=-3,//	-03: Newfoundland
   eTimeZone4B=-2,//	-02: Mid-Atlantic
   eTimeZone50=-1,//	-01: Azores
   eTimeZone55=0,//	000: Greenwich Mean Time: London
   eTimeZone5F=1,//	+01: Belgrade, Bratislava, Budapest, Ljubljana, Prague
   eTimeZone73=2,//	+02: Minsk
   eTimeZone7D=2,//	+02: Helsinki, Kiev, Riga, Sofia, Tallinn, Vilnius
   eTimeZone91=3,//	+03: Moscow, St. Petersburg, Volgograd
   eTimeZoneA5=4,//	+04: Abu Dhabi, Muscat
   eTimeZoneB4=5,//	+05: Ekaterinburg
   eTimeZoneC3=6,//	+06: Astana, Dhaka
   eTimeZoneCD=7,//	+07: Bangkok, Hanoi, Jakarta
   eTimeZoneD2=8,//	+08: Beijing, Chongqing, Hong Kong, Urumqi
   eTimeZoneEB=9,//	+09: Osaka, Sapporo, Tokyo
   eTimeZoneFF=10,//	+10: Canberra, Melbourne, Sydney
   eTimeZone118=11,//	+11: Magadan, Solomon Islands, New Caledonia
   eTimeZone11D=12,//	+12: Fiji, Kamchatka, Marshall Is.
   eTimeZone12C=13,//	+13: Nuku'alofa
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TEST_Equity=0,TEST_Equity_Set=10,TEST_Equity_Step=1;
double TEST_Margin=0,TEST_Margin_Set=10,TEST_Margin_Step=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string ExtName_OBJ="Carry@";
bool ExtHide_OBJ=false;
bool CMD_XML_Show=false;

//extern string separators1="---------------------------"; // -------------- Method to copy --------------
extern string IP="http://127.0.0.1/MyCopyTrade/";//IP Saver
extern string FileName_Pair="";//Buddy
extern eTimeZone TimeZone=eTimeZone55;
extern string separators2="---------------------------"; // -------------- Method to copy --------------
extern bool InvertOrder=false;//Invert Order
extern double LotsFollower=100;//LotsFollower (set in the percentage %)
extern string separators3="---------------------------"; // -------------- Line Notify --------------
extern string Token="sWyKPFRBeHSky0dCucuHpPIjxd93gn10QTl4731UgD5";
extern ENUM_TIMEFRAMES CheckPeriod=PERIOD_H1;

string IP_Default=IP;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
bool OnOff_Conn=false;
bool OnOff_Sync=false;
//My Info
string FileName_MY;
string _LOGIN_MY=string(AccountInfoInteger(ACCOUNT_LOGIN));
string _COMPANY_MY=AccountInfoString(ACCOUNT_COMPANY);
//Buddy info
string _LOGIN_Pair,_COMPANY_Pair;
bool BuddyAvailability=false;
//Host
string URL,HOST,HOST_Path="/MyCopyTrade/";
bool IPAvailability=false;
//My Data
string PathXmlGet="Carry\\XML_GET.xml";
string PathXmlPush="Carry\\XML_PUSH.xml";

string PathCopied="Carry\\Copied.txt";
string PathSync="Carry\\Sync.txt";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(500);


   int chk_buddy=StringFind(FileName_Pair,"@",0);
   printf("chk_buddy: "+string(chk_buddy));
   if(FileName_Pair!=NULL && chk_buddy>=0)
     {
      string result[];
      int k=StringSplit(FileName_Pair,StringGetCharacter("@",0),result);
      _LOGIN_Pair=result[0];
      _COMPANY_Pair=result[1];

      BuddyAvailability=true;
     }
   if(!BuddyAvailability)
     {
      OnOff_Conn=false;
      OnOff_Sync=false;
     }
   printf("BuddyAvailability: "+string(BuddyAvailability));

   StringReplace(_COMPANY_MY," ","_");
   StringReplace(_COMPANY_MY,".","");
   FileName_MY=_LOGIN_MY+"@"+_COMPANY_MY;
//

   if(IP=="http://127.0.0.1/MyCopyTrade" || IP=="")
     {
      URL="Please set the IP";
     }
   else
     {
      IPAvailability=true;
     }
//
   if(IPAvailability)
     {
      URL=IP;
      HOST=IP+HOST_Path;
     }
   else
     {
      OnOff_Conn=false;
      OnOff_Sync=false;
     }
     
   LineNotifyPHP("SS");

//   
   set_InterfaceDraw(true);
//---
   ArrayResize(Tagsdump,ArraySize(Tags),0);
   ArrayResize(BuddyInfoSet,ArraySize(TagsInfo),0);
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

   string GetFindFirst="";

   if(FileFindFirst("Carry\\*.txt",GetFindFirst)!=INVALID_HANDLE && GetFindFirst=="Sync.txt")
     {
      FileDelete(PathSync);
     }

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
int ERR_GET=0,ERR_Snyc=0,ERR_PUSH=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TagsInfo[5]={"COMPANY","AccountProfit","AccountCurrency","TimeUpdate","OnOff_Sync"};
string BuddyInfoSet[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Notify_A=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

//---
   bool Availability=IPAvailability && BuddyAvailability;

//if(Availability)
     {
      ERR_GET=Order_Get(PathXmlGet);
      string XML=XML_Read(PathXmlGet,false,__LINE__);

      //if(OnOff_Sync)
         Order_Copy(XML);

      Buddy_Information(XML);
      //SplitString --> Filter(RawString)
      ERR_Snyc=0;
      //if(OrdersTotal()!=index)
      if(OnOff_Sync)
        {
         ERR_Snyc=Order_Snyc();
        }
      if(OnOff_Conn)
        {
         ERR_PUSH=Order_Push();
        }
     }
//---
   datetime TimeDiff=MyTime(TimeCurrent())-datetime(BuddyInfoSet[3]);
//---
     {
      //--XML Chk err Connected

      color clrSaverSatus=clrWhite;
      string strSaverSatus="";
      int CodeErr=-1;

      if(Availability && OnOff_Conn)
        {
         if(ERR_GET!=4000)
           {
            clrSaverSatus=clrRed;
            strSaverSatus+="ERR_GET : ["+string(ERR_GET)+"]";
            CodeErr=ERR_GET;
           }
         if(ERR_GET==4000 && ERR_PUSH!=4000 && ERR_PUSH!=0)
           {
            clrSaverSatus=clrRed;
            strSaverSatus+="ERR_PUSH : ["+string(ERR_PUSH)+"]";
            CodeErr=ERR_PUSH;
           }
         //        
         if(ERR_GET==4000 && (ERR_PUSH==4000 || ERR_PUSH==0))
           {

            if(ERR_Snyc==0 && (OrdersTotal()==index))
              {
               clrSaverSatus=clrLime;
               strSaverSatus+="Connected";
              }
            else
              {
               clrSaverSatus=clrYellow;
               strSaverSatus+="Synchronizing [ "+string(OrdersTotal()-index)+" ]";
              }

           }
        }
      else if(FileName_Pair=="")
        {
         clrSaverSatus=clrRed;
         strSaverSatus="Buddy is Empty";
        }
      else if(!OnOff_Conn)
        {

         clrSaverSatus=clrRed;
         strSaverSatus="Disconnect";
        }

      strSaverSatus+=" "+TimerTickSignal(TickSignal);

      setBUTTON_Text_Clr("Label_SaverSatus",strSaverSatus,int(GetClr_BACKGROUND),clrSaverSatus,clrSaverSatus,
                         WebRequest_ErrStr(CodeErr));

     }
     {
      //--- Allow resource [ Copied.txt,Sync.txt ]
      if(OrdersTotal()==0 && index==0)
        {
         string GetFindFirst;
         if(FileFindFirst("Carry\\*.txt",GetFindFirst)!=INVALID_HANDLE && GetFindFirst=="Sync.txt")
           {
            FileDelete(PathSync);
           }
         if(FileFindFirst("Carry\\*.txt",GetFindFirst)!=INVALID_HANDLE && GetFindFirst=="Copied.txt")
           {
            FileDelete(PathCopied);
           }

        }
     }
//---
   string bntText,btnTooltip;
   color btnClr;
   datetimeA(TimeDiff,bntText,btnTooltip,btnClr);

   setBUTTON_Text_Clr("Label_Buddy",bntText,clrBlack,btnClr,btnClr,btnTooltip);

//---

   string   CCM="",CCS="\n     ";

   CCM+=CCS+"------ Time ------";
   CCM+=CCS+"MarketTime : "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS);
   CCM+=CCS+"     MyTime : "+TimeToStr(MyTime(TimeCurrent()),TIME_DATE|TIME_SECONDS);
   CCM+=CCS+"     TimeDiff : "+btnTooltip;

   CCM+=CCS+"------ Information ------";
   CCM+=CCS+"LOGIN : "+_LOGIN_MY;
   CCM+=CCS+"COMPANY : "+_COMPANY_MY;
   CCM+=CCS+"------ Setting ------";
   CCM+=CCS+"Saver IP : [ "+IP+" ]";
   CCM+=CCS+"Buddy Name : [ "+FileName_Pair+" ]";
   CCM+=CCS+"InvertOrder : [ "+string(InvertOrder)+" ]";
   CCM+=CCS+"LotsFollower : [ "+string(LotsFollower)+"% ]";
   CCM+=CCS+"------ Synchronize Buddy ------";
   CCM+=CCS+"OrdersTotal : "+string(OrdersTotal())+" | "+string(index);
//CCM+=CCS+BuddyInfo;
   CCM+=CCS+"Buddy_AccountProfit : "+DoubleToString(double(BuddyInfoSet[1]),2)+" "+string(BuddyInfoSet[2]);

   CCM+=CCS+"Time : "+BuddyInfoSet[3];
   CCM+=CCS+"Rady : "+BuddyInfoSet[4];
//---
   CCM+=CCS+"------ Dev LINE Notify ------";
   CCM+=CCS+"TEST_Equity_Step : "+TEST_Equity+"|"+TEST_Equity_Set;
   CCM+=CCS+"Noti Cnt : "+Notify_A;

   Comment(CCM);

     {
      double EQUITY=AccountInfoDouble(ACCOUNT_EQUITY);
      double MARGIN=AccountInfoDouble(ACCOUNT_MARGIN_FREE);

      ObjectSetString(0,ExtName_OBJ+"Equity@Now",OBJPROP_TEXT,DoubleToStr(EQUITY,2));
      ObjectSetString(0,ExtName_OBJ+"Margin@Now",OBJPROP_TEXT,DoubleToStr(MARGIN,2));

      string ObjStr;
      //---
      ObjStr=ObjectGetString(0,ExtName_OBJ+"Equity@Set",OBJPROP_TEXT,0);

      if(Notify_A>=25)
         Notify_A=-1;
      else
         Notify_A++;

      if(!(StringCompare(ObjStr,"",true)==0) && StrChkNumber(ObjStr) && Notify_A<0)
        {
         if(ObjectGetInteger(0,ExtName_OBJ+"Equity@Option1",OBJPROP_STATE))
           {
            if(EQUITY<=double(ObjStr))
              {
               printf("Equity <");
               LineNotifyPHP("Equity <");

              }
           }
         if(ObjectGetInteger(0,ExtName_OBJ+"Equity@Option2",OBJPROP_STATE))
           {
            if(EQUITY>=double(ObjStr))
              {
               printf("Equity >");
               LineNotifyPHP("Equity >");

              }
           }
        }
      //---
      ObjStr=ObjectGetString(0,ExtName_OBJ+"Margin@Set",OBJPROP_TEXT,0);
      if(!(StringCompare(ObjStr,"",true)==0) && StrChkNumber(ObjStr))
        {
         if(ObjectGetInteger(0,ExtName_OBJ+"Margin@Option1",OBJPROP_STATE))
           {
            if(MARGIN<=double(ObjStr))
              {
               printf("Margin <");
              }
           }
         if(ObjectGetInteger(0,ExtName_OBJ+"Margin@Option2",OBJPROP_STATE))
           {
            if(MARGIN>=double(ObjStr))
              {
               printf("Margin >");
              }
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool StrChkNumber(string ObjStr)
  {
   double chkNumber=double(ObjStr);
   if(StringLen(ObjStr)==StringLen(string(chkNumber)) && (chkNumber<0 || chkNumber>0))
      return true;
   else if(chkNumber==0 && StringCompare(ObjStr,"0",true)==0)
      return true;
   return false;
  }
//datetimeA(TimeDiff,bntText,btnTooltip,btnClr);
datetime MyTime(datetime time)
  {
   return time+(3600*TimeZone);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool datetimeA(datetime TimeDiff,string &Text,string &Tooltip,color &btnClr)
  {

   string time=TimeToString(TimeDiff,TIME_SECONDS);
   StringReplace(time,"00:","");

   Tooltip=TimeToStr(TimeDiff,TIME_DATE|TIME_SECONDS);
//return true;
   if(TimeDiff<=1 && FileName_Pair!="")
     {
      string Ready=BuddyInfoSet[4];
      btnClr=(!OnOff_Sync)?clrYellow:clrLime;

      Text=(Ready==NULL)?"Please set the Buddy"
           :(!BuddyAvailability)?"Wrong buddy"
           :"E";

      //Text=(!OnOff_Sync)?
      //     ((Ready=="true")?"Buddy Online":"Buddy Ready")
      //     :"Synchronized";

      Tooltip=(!OnOff_Sync)?"Online Click to start synchronizing.":"Synchronized";
      //btnClr=clrLime;
      return true;
     }
   if(TimeDiff<86400)
     {

      Text="Offline ["+time+"]";
      Tooltip="Offline ["+time+"]";
      btnClr=clrRed;
      return true;
     }

   return false;
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
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Print("CHARTEVENT_OBJECT_CLICK ["+sparam+"]");
      if(sparam==ExtName_OBJ+"Label_Buddy")
        {
         int Message=MessageBox((OnOff_Sync)?"Close synchronization, right?":"Start synchronizing, right?",
                                "Synchronize",
                                MB_YESNO|MB_ICONQUESTION);
         if(Message==IDYES)
           {
            OnOff_Sync=!OnOff_Sync;
           }

        }
      //---
      if(sparam==ExtName_OBJ+"Label_SaverSatus")
        {
         int Message=MessageBox((OnOff_Conn)?"Disconnected, right?":"Connected, right?",
                                "Connected Host",
                                MB_YESNO|MB_ICONQUESTION);
         if(Message==IDYES)
           {
            OnOff_Conn=!OnOff_Conn;
           }

        }
      //---
      string sep="@",result[];
      ushort  u_sep=StringGetCharacter(sep,0);
      int k=StringSplit(sparam,u_sep,result);
      if(result[1]=="Margin" || result[1]=="Equity")
        {
         //---  Option
         if(result[2]=="Option1" || result[2]=="Option2")
           {
            string Sec=(result[2]=="Option1")?"Option2":"Option1";
            string NameBTNSec=result[0]+"@"+result[1]+"@"+Sec;
            //---
            if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
              {
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrLime);
               ObjectSetInteger(0,sparam,OBJPROP_COLOR,clrBlack);

               ObjectSetInteger(0,NameBTNSec,OBJPROP_BGCOLOR,clrBlack);
               ObjectSetInteger(0,NameBTNSec,OBJPROP_COLOR,clrGray);
               ObjectSetInteger(0,NameBTNSec,OBJPROP_STATE,false);
              }
            else
              {
               ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrBlack);
               ObjectSetInteger(0,sparam,OBJPROP_COLOR,clrGray);
              }
           }
         //--- SetNowValue
         if(result[2]=="Now")
           {
            string ObjStr=ObjectGetString(0,sparam,OBJPROP_TEXT,0);
            ObjectSetString(0,ExtName_OBJ+result[1]+"@Set",OBJPROP_TEXT,ObjStr);
           }
         //--- SetNULL
         if(result[2]=="label")
           {
            //string ObjStr=ObjectGetString(0,sparam,OBJPROP_TEXT,0);
            ObjectSetString(0,ExtName_OBJ+result[1]+"@Set",OBJPROP_TEXT,"");
           }
        }
     }

   if(CHARTEVENT_CLICK)
     {
      //Print("CHARTEVENT_OBJECT_CLICK ["+sparam+"]");
      set_InterfaceDraw(false);
     }
//---
   if(id==CHARTEVENT_KEYDOWN)
     {
      Print("CHARTEVENT_KEYDOWN '"+string(lparam)+"' "+KeydownToString(lparam));

      switch(int(lparam))
        {
         case 105:
            TEST_Equity+=TEST_Equity_Step;
            break;
         case 102:
            TEST_Equity-=TEST_Equity_Step;
            break;
         default:
            Print("Some not listed key has been pressed");
        }
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string KeydownToString(long k)
  {
   switch(int(k))
     {
      case  105 : return "9";
      case  102 : return "6";
      case  99 :  return "3";
      default:
         break;
     }
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TickSignal=true;
//+------------------------------------------------------------------+
string TimerTickSignal(bool Sig)
  {
   TickSignal=(Sig)?false:true;
   return (Sig)?"H":"U";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_Get(string file)
  {
//---
   string str="MQL4_Call=GET"+
              "&MQL4_FileName="+FileName_Pair+
              "&MQL4_Mode=XML";
//---
   string Header=NULL;
   string ResultHeader;
   char   SentData[];  // Data array to send POST requests 
   char   ResultData[];
//---
   ArrayResize(SentData,StringToCharArray(str,SentData,0,WHOLE_ARRAY,CP_UTF8)-1);
//---
   int res=0,err=6000;
   if(IP!="")
     {
      ResetLastError();
      res=WebRequest("POST",HOST,Header,5000,SentData,ResultData,ResultHeader);
      err=GetLastError();
     }
   else
     {
      err=6001;
     }
//
   string  PAGE=CharArrayToString(ResultData,0,ArraySize(ResultData),CP_ACP);
   if(CMD_XML_Show)
     {
      printf("Res : "+string(res));
      printf("err : "+string(err));
      printf("ResultHeader : "+string(ResultHeader));
      printf("PAGE : "+string(PAGE));
     }

   if(err!=4000)
     {
      //Print("#"+string(__LINE__)+" WebRequest. Code =",WebRequest_ErrStr(err));
     }
   else if(res==200)
     {
      int filehandle=FileOpen(file,FILE_WRITE|FILE_BIN);
      if(filehandle!=INVALID_HANDLE)
        {
         FileWriteArray(filehandle,ResultData,0,ArraySize(ResultData));
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error code=",GetLastError());

     }
//printf("XML Get["+err+"]: "+HOST);
   return err;
  }
int index=0;
string Order[200][10];
int slippage=10;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Order_Copy(string sData)
  {

   int next=-1;
   int BoOrder=0,begin=0,end=0;
   string MyOrder="";
   index=0;
//---
//printf("sData :"+sData);
   while(true)
     {
      BoOrder=StringFind(sData,"<Order>",BoOrder);
      if(BoOrder==-1)
         break;
      BoOrder+=7;
      next=StringFind(sData,"</Order>",BoOrder);
      if(next==-1)
         break;

      MyOrder = StringSubstr(sData,BoOrder,next-BoOrder);
      BoOrder = next;
      begin=0;

      //printf("MyOrder :"+MyOrder);
      for(int i=0; i<ArraySize(Tags); i++)
        {
         //Order[index][i]="-";
         next=StringFind(MyOrder,XML_Tag(true,Tags[i]),begin);
         //printf("next :"+next);
         //--- Within this event, if tag not found, then it must be missing; skip it
         if(next==-1)
            continue;
         else
           {
            //--- We must have found the sTag okay...
            //--- Advance past the start tag
            begin=next+StringLen(XML_Tag(true,Tags[i]));
            end=StringFind(MyOrder,XML_Tag(false,Tags[i]),begin);
            //---Find start of end tag and Get data between start and end tag
            if(end>begin && end!=-1)
               Order[index][i]=StringSubstr(MyOrder,begin,end-begin);
           }
        }

/*
      printf(string(index+1)+"#["+
             Order[index][0]+" | "+
             Order[index][1]+" | "+
             Order[index][2]+" | "+
             Order[index][3]+" | "+
             Order[index][4]+" | "+
             Order[index][5]+" | "+
             Order[index][6]+" | "+
             Order[index][7]+" | "+
             Order[index][8]+" ] ");
             */

      index++;
     }

//--- --- --- ---
//---  Filter
//--- --- --- ---
   for(int i=0;i<index;i++)
     {

      int copy=-1;

      int  cTicket=int(Order[i][eTicket]);
      string cSymbol=Order[i][eSymbol];
      int cOP_DIR=int(Order[i][eType]);
      double cLOTS=double(Order[i][eLots]);
      double cOP=double(Order[i][ePrice]);
      double cSL=double(Order[i][eSL]);
      double cTP=double(Order[i][eTP]);

      int cMagic=int(Order[i][eMagic]);
      string cComment=Order[i][eComment];
      //---

      if(cMagic==0)
        {
         //--- Check that copied

         string Copied=XML_Read(PathCopied,false,__LINE__);
         copy=StringFind(Copied,string(cTicket),0);
         //printf("copy : "+copy);

         if(copy==-1)
           {
            int Ticket=-1;

            if(IsExpertEnabled())
              {
               ResetLastError();
               Ticket=OrderSend(cSymbol,
                                Order_CopyInvertDir(cOP_DIR),
                                Order_CopyLotsFollower(cLOTS),
                                Order_CopyOpenPrice(cSymbol,Order_CopyInvertDir(cOP_DIR)),
                                slippage,cSL,cTP,
                                string(cTicket),cTicket,
                                0);
               printf("OrderSend : GetLastError["+string(GetLastError())+"] Ticket["+string(Ticket)+"]");
              }
            if(Ticket>0)
              {
               printf("Copied ["+FileName_Pair+"]: "+string(cTicket)+" -> "+string(Ticket));

               Copied+=","+string(cTicket);
               int filehandle=FileOpen(PathCopied,FILE_WRITE|FILE_BIN|FILE_READ);

               FileWriteString(filehandle,Copied);
               FileClose(filehandle);
              }
            else
              {
               //Area to Modifile
              }
           }
        }
      else
        {
         string Sync=XML_Read(PathSync,false,__LINE__);
         if(StringFind(Sync,string(cMagic),0)==-1)
           {
            Sync+=","+string(cMagic);

            int filehandle=FileOpen(PathSync,FILE_WRITE|FILE_BIN|FILE_READ);

            FileWriteString(filehandle,Sync);
            FileClose(filehandle);
           }
        }
     }
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_CopyInvertDir(int OP)
  {
   if(InvertOrder)
     {
      if(OP==OP_BUY)
        {
         return OP_SELL;
        }
      else if(OP==OP_SELL)
        {
         return OP_BUY;
        }
     }
   else
     {
      return OP;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order_CopyOpenPrice(string symbol,int DIR)
  {
   int Type=(DIR==OP_BUY)?MODE_ASK:((DIR==OP_SELL)?MODE_BID:-1);
   if(Type>=0)
     {
      return MarketInfo(symbol,Type);
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order_CopyLotsFollower(double LotsMaster)
  {
   return NormalizeDouble(LotsMaster*(LotsFollower/100),2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_Snyc()
  {
   int cnt=0;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;

      if(OrderMagicNumber()==0)
        {
         //--- Master chk Parent to colose

         string Sync=XML_Read(PathSync,false,__LINE__);

         int Synced=StringFind(Sync,string(OrderTicket()),0);
         //printf(string(__LINE__)+" Synced ["+Synced+"]");

         if(Synced>=0)
           {
            bool found=false;
            for(int i=0;i<index;i++)
              {
               int  cMagic=int(Order[i][eMagic]);
               if(int(OrderTicket())==cMagic)
                 {
                  found=true;
                  break;
                 }
              }

            if(!found)
              {
               bool c=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage);
               int  err=GetLastError();
               printf("#"+string(__LINE__)+" OrderClose A | GetLastError["+string(err)+"]");

              }
           }
         else
           {
            cnt++;
           }

        }
      else if(OrderMagicNumber()!=int(_LOGIN_Pair))
        {
         //--- Parent chk Master to colose
         bool found=false;
         for(int i=0;i<index;i++)
           {
            int  cTicket=int(Order[i][eTicket]);
            if(OrderMagicNumber()==cTicket)
              {
               found=true;
               break;
              }
           }
         if(!found)
           {

            bool c=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage);
            int  err=GetLastError();
            printf("#"+string(__LINE__)+" OrderClose Parent | GetLastError["+string(err)+"]");
           }

        }
      //---
     }
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Tags[10]={"OpenTime","Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};
string Tagsdump[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_Push()
  {
   string OrderFamily;
   OrderFamily+="<Info>";
   OrderFamily+=XML_Tag(true,TagsInfo[0])+_COMPANY_MY+XML_Tag(false,TagsInfo[0]);
   OrderFamily+=XML_Tag(true,TagsInfo[1])+string(AccountProfit())+XML_Tag(false,TagsInfo[1]);
   OrderFamily+=XML_Tag(true,TagsInfo[2])+AccountCurrency()+XML_Tag(false,TagsInfo[2]);
   OrderFamily+=XML_Tag(true,TagsInfo[3])+TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS)+XML_Tag(false,TagsInfo[3]);
   OrderFamily+=XML_Tag(true,TagsInfo[4])+string(OnOff_Sync)+XML_Tag(false,TagsInfo[4]);
   OrderFamily+="</Info>";
   OrderFamily+="<Port>";
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      //if(OrderMagicNumber()!=0) continue;
      //---
      Tagsdump[0]=string(MyTime(OrderOpenTime()));
      Tagsdump[1]=string(OrderTicket());
      Tagsdump[2]=string(OrderType());
      Tagsdump[3]=string(OrderLots());
      Tagsdump[4]=string(OrderSymbol());
      Tagsdump[5]=string(OrderOpenPrice());
      Tagsdump[6]=string(OrderStopLoss());
      Tagsdump[7]=string(OrderTakeProfit());
      Tagsdump[8]=string(OrderComment());
      Tagsdump[9]=string(OrderMagicNumber());
      //---
      OrderFamily+="<Order>";
      for(int i=0;i<ArraySize(Tags);i++)
        {
         OrderFamily+="\t"+XML_Tag(true,Tags[i])+Tagsdump[i]+XML_Tag(false,Tags[i]);
        }
      OrderFamily+="</Order>";
     }
   OrderFamily+="</Port>";
//---
   string str="MQL4_Call=PUSH"+
              "&MQL4_FileName="+FileName_MY+
              "&MQL4_OrderData="+OrderFamily;
//---
   string Header=NULL;
   string ResultHeader;
   char   SentData[];  // Data array to send POST requests 
   char   ResultData[];
//---
   ArrayResize(SentData,StringToCharArray(str,SentData,0,WHOLE_ARRAY,CP_UTF8)-1);

   int res=0,err=6000;
   if(IP!="")
     {
      ResetLastError();
      res=WebRequest("POST",HOST,Header,5000,SentData,ResultData,ResultHeader);
      err=GetLastError();
     }
   else
     {
      err=6001;
     }
//
   string  PAGE=CharArrayToString(ResultData,0,ArraySize(ResultData),CP_ACP);
   if(CMD_XML_Show)
     {
      printf("Res : "+string(res));
      printf("err : "+string(err));
      printf("ResultHeader : "+string(ResultHeader));
      printf("PAGE : "+string(PAGE));
     }
//---

   string strSaverSatus="Connected";
   color clrSaverSatus=clrLime;

   if(err!=4000)
     {
      //Print("#"+string(__LINE__)+" WebRequest. Code =",WebRequest_ErrStr(err));

      clrSaverSatus=clrRed;
      strSaverSatus="WebRequest : ["+string(err)+"]";
     }
   else
     {
      int filehandle=FileOpen(PathXmlPush,FILE_WRITE|FILE_BIN);
      if(filehandle!=INVALID_HANDLE)
        {
         FileWriteArray(filehandle,ResultData,0,ArraySize(ResultData));
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error code=",GetLastError());
     }
   return err;
//---   
//int(GetClr_FOREGROUND),int(GetClr_BACKGROUND)
//setBUTTON_Text_Clr("Label_SaverSatus",strSaverSatus,int(GetClr_BACKGROUND),clrSaverSatus,clrSaverSatus);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Buddy_Information(string sDATA)
  {
   int next=-1;
   int BoOrder=0,begin=0,end=0;

   string MyBuddy="";
     {
      BoOrder=StringFind(sDATA,"<Info>",BoOrder);
      //if(BoOrder==-1)
      //break;
      BoOrder+=6;
      next=StringFind(sDATA,"</Info>",BoOrder);
      //if(next==-1)
      //break;

      MyBuddy = StringSubstr(sDATA,BoOrder,next-BoOrder);
      BoOrder = next;
      begin=0;

      //printf("MyBuddy :"+MyBuddy);

      for(int i=0; i<ArraySize(TagsInfo); i++)
        {
         //Order[index][i]="-";
         next=StringFind(MyBuddy,XML_Tag(true,TagsInfo[i]),begin);
         //printf("next :"+next);
         //--- Within this event, if tag not found, then it must be missing; skip it
         if(next==-1)
            continue;
         else
           {
            //--- We must have found the sTag okay...
            //--- Advance past the start tag
            begin=next+StringLen(XML_Tag(true,TagsInfo[i]));
            end=StringFind(MyBuddy,XML_Tag(false,TagsInfo[i]),begin);
            //---Find start of end tag and Get data between start and end tag
            if(end>begin && end!=-1)
               BuddyInfoSet[i]=StringSubstr(MyBuddy,begin,end-begin);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string WebRequest_ErrStr(int err)
  {
   string str="-";
   switch(err)
     {
      case  4000: str="OK.";break;
      case  4060: str="Not Allowed URLs [Main Menu-> Tools-> Options-> tab(Expert Advisors)-> WebRequest]";break;
      case  6001: str="IP is empty [Expert Advisors-> tab(Input)-> Variable(IP)]";break;

      default: break;
     }
   return string(err)+" "+str;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string XML_Read(string FileName,bool print,int line)
  {
   string sData;
//---
   ResetLastError();
   int FileHandle=FileOpen(FileName,FILE_WRITE|FILE_BIN|FILE_READ);

   if(FileHandle!=INVALID_HANDLE)
     {
      //--- receive the file size 
      ulong size=FileSize(FileHandle);
      //--- read data from the file
      while(!FileIsEnding(FileHandle))
         sData=FileReadString(FileHandle,(int)size);
      //--- close
      FileClose(FileHandle);
      if(print)
        {
         printf("#"+string(line)+" xmlRead: ["+FileName+"] "+sData);
        }
      //printf("xmlRead: "+SerialNumber_Decode(PrivateKey,sData));
     }
//--- check for errors   
//else PrintFormat(INAME+": failed to open %s file, Error code = %d",FileName,GetLastError());
//---
   return sData;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string XML_Tag(bool type,string v)
  {
   return (type)?"<"+v+">":"</"+v+">";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Space=0.5;
int Size_Wide=400;
int Size_High=22;
int PostX_Default=10,XStep=int(Size_Wide*Space);
int PostY_Default=Size_High+5,YStep=Size_High;

long GetClr_FOREGROUND,GetClr_BACKGROUND;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_InterfaceDraw(bool Init)
  {

   GetClr_FOREGROUND=ChartGetInteger(0,CHART_COLOR_FOREGROUND,0);
   GetClr_BACKGROUND=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);

   int PostX=PostX_Default;
   int PostY=PostY_Default;

   if(Init)
      setBUTTON(ExtName_OBJ+"Label_Buddy",0,CORNER_LEFT_LOWER,int(XStep-10),Size_High-2,PostX,PostY,10,clrBlack,clrWhite,clrWhite,"Buddy Satus","Tooltip");

   setEditCreate(ExtName_OBJ+"Set_Buddy",0,FileName_Pair
                 ,true,true,PostX+XStep-5,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_LOWER
                 ,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),int(GetClr_BACKGROUND),false,false,false,0
                 ,"Buddy account to pair account.");

   PostY+=YStep;
   PostX=PostX_Default;

   setBUTTON(ExtName_OBJ+"Label_ID",0,CORNER_LEFT_LOWER,int(XStep-10),Size_High,PostX,PostY,10,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),int(GetClr_BACKGROUND),"My Account","");

   PostX+=XStep;
   setEditCreate(ExtName_OBJ+"ID",0,FileName_MY
                 ,true,false,PostX-5,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_LOWER
                 ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),false,false,false,0
                 ,"My account is copied to pair account.");

   PostY+=YStep;
//---
   PostX=PostX_Default;
   if(Init)
      setBUTTON(ExtName_OBJ+"Label_SaverSatus",0,CORNER_LEFT_LOWER,int(XStep-10),Size_High,PostX,PostY,10,clrBlack,clrWhite,clrWhite,"Saver Satus","Tooltip");
   PostX+=XStep;

   setEditCreate(ExtName_OBJ+"IP",0,URL
                 ,true,true,PostX-5,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_LOWER
                 ,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),int(GetClr_BACKGROUND),false,false,false,0
                 ,"IP host that is used. Must be set to match both.");

   if(!IPAvailability)
     {
      ObjectSetInteger(0,ExtName_OBJ+"IP",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,ExtName_OBJ+"IP",OBJPROP_BORDER_COLOR,clrRed);
     }

   if(!BuddyAvailability)
     {
      ObjectSetInteger(0,ExtName_OBJ+"Set_Buddy",OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,ExtName_OBJ+"Set_Buddy",OBJPROP_BORDER_COLOR,clrRed);
     }
   PostY+=YStep+15;
   PostX=PostX_Default;

   setLabel(ExtName_OBJ+"Equity@label","  Equity : ","",int(GetClr_FOREGROUND),PostX,PostY);
   PostX+=50;
   setEditCreate(ExtName_OBJ+"Equity@Now",0,""
                 ,false,true,PostX,PostY,105,Size_High,"Arial",10,ALIGN_RIGHT,CORNER_LEFT_LOWER
                 ,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),C'30,30,30',false,false,false,0
                 ,"IP host that is used. Must be set to match both.");
   PostX+=105+5;

   if(Init)
      setBUTTON(ExtName_OBJ+"Equity@Option1",0,CORNER_LEFT_LOWER,15,Size_High,PostX,PostY,10,
                clrGray,clrBlack,clrGray,"<","Option1");
   PostX+=14;
   if(Init)
      setBUTTON(ExtName_OBJ+"Equity@Option2",0,CORNER_LEFT_LOWER,15,Size_High,PostX,PostY,10,
                clrGray,clrBlack,clrGray,">","Option2");
   PostX+=15+5;

   setEditCreate(ExtName_OBJ+"Equity@Set",0,""
                 ,false,false,PostX,PostY,105,Size_High,"Arial",10,ALIGN_RIGHT,CORNER_LEFT_LOWER
                 ,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),false,false,false,0
                 ,"IP host that is used. Must be set to match both.");

   PostY+=YStep+2;
   PostX=PostX_Default;

   setLabel(ExtName_OBJ+"Margin@label","Margin  : ","",int(GetClr_FOREGROUND),PostX,PostY);
   PostX+=50;
   setEditCreate(ExtName_OBJ+"Margin@Now",0,""
                 ,false,true,PostX,PostY,105,Size_High,"Arial",10,ALIGN_RIGHT,CORNER_LEFT_LOWER
                 ,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),C'30,30,30',false,false,false,0
                 ,"IP host that is used. Must be set to match both.");
   PostX+=105+5;
   if(Init)
      setBUTTON(ExtName_OBJ+"Margin@Option1",0,CORNER_LEFT_LOWER,15,Size_High,PostX,PostY,10,
                clrGray,clrBlack,clrGray,"<","Option1");
   PostX+=14;
   if(Init)
      setBUTTON(ExtName_OBJ+"Margin@Option2",0,CORNER_LEFT_LOWER,15,Size_High,PostX,PostY,10,
                clrGray,clrBlack,clrGray,">","Option2");

   PostX+=15+5;
   setEditCreate(ExtName_OBJ+"Margin@Set",0,""
                 ,false,false,PostX,PostY,105,Size_High,"Arial",10,ALIGN_RIGHT,CORNER_LEFT_LOWER
                 ,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),false,false,false,0
                 ,"IP host that is used. Must be set to match both.");

   PostY+=YStep;
   PostX=PostX_Default;
   setLabel(ExtName_OBJ+"Line@Head","Notification via Line","",int(GetClr_FOREGROUND),PostX,PostY);

//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBUTTON(string name,
               int panel,
               ENUM_BASE_CORNER CORNER,
               int XSIZE,int YSIZE,
               int XDIS,int YDIS,
               int FONTSIZE,color COLOR,color BG,color BO,
               string TextStr,
               string Tooltip)
  {
//---
   if(ObjectFind(name)!=0)
     {
      ObjectCreate(0,name,OBJ_BUTTON,panel,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDIS);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDIS);
     }

   ObjectSetInteger(0,name,OBJPROP_CORNER,0);
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDIS);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDIS);
     }
//---
   ObjectSetInteger(0,name,OBJPROP_XSIZE,XSIZE);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,YSIZE);

   ObjectSetString(0,name,OBJPROP_TEXT,TextStr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);

   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,BO);

   ObjectSetInteger(0,name,OBJPROP_COLOR,COLOR);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,ExtHide_OBJ);

   ObjectSetString(0,name,OBJPROP_TOOLTIP,Tooltip);

//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBUTTON_Text_Clr(string Name,string Text,color FG,color BG,color BO,const string Tooltip)
  {
   ObjectSetString(0,ExtName_OBJ+Name,OBJPROP_TEXT,Text);

   ObjectSetInteger(0,ExtName_OBJ+Name,OBJPROP_COLOR,FG);

   ObjectSetInteger(0,ExtName_OBJ+Name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,ExtName_OBJ+Name,OBJPROP_BORDER_COLOR,BO);

   ObjectSetString(0,ExtName_OBJ+Name,OBJPROP_TOOLTIP,Tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setEditCreate(const string           name="Edit",// object name 
                   const int              sub_window=0,             // subwindow index 
                   const string           text="Text",              // text 
                   const bool             reDraw=false,// ability to edit 
                   const bool             read_only=false,          // ability to edit 
                   const int              x=0,                      // X coordinate 
                   const int              y=0,                      // Y coordinate 
                   const int              width=50,                 // width 
                   const int              height=18,                // height 
                   const string           font="Arial",             // font 
                   const int              font_size=10,             // font size 
                   const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type 
                   const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                   const color            clr=clrBlack,             // text color 
                   const color            back_clr=clrWhite,        // background color 
                   const color            border_clr=clrNONE,       // border color 
                   const bool             back=false,               // in the background 
                   const bool             selection=false,          // highlight to move 
                   const bool             hidden=true,              // hidden in the object list 
                   const long             z_order=0,
                   const string           Tooltip="") // priority for mouse click 
  {
   long  chart_ID=0;
//--- reset the error value 
   ResetLastError();
//--- create edit field 
   if(ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0))
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
   else
     {
     }
   if(reDraw)
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,Tooltip);
//--- set object coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text 

//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode 
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,ExtHide_OBJ);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setLabel(string Name,string Text,string Tooltip,color clr,int PostX,int PostY)
  {
//ExtName_OBJ+"Head_1",
   ObjectCreate(Name,OBJ_LABEL,0,0,0);
   ObjectSetText(Name,Text,9,"Arial",clr);
   if(Tooltip!="")
     {
      ObjectSetString(0,Name,OBJPROP_TOOLTIP,Tooltip);
     }

   ObjectSet(Name,OBJPROP_XDISTANCE,PostX);
   ObjectSet(Name,OBJPROP_YDISTANCE,PostY);

   ObjectSetInteger(0,Name,OBJPROP_BACK,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTED,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_HIDDEN,ExtHide_OBJ);

   ObjectSetInteger(ChartID(),Name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//ObjectSetInteger(ChartID(),Name,OBJPROP_ALIGN,ALIGN_LEFT);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LineNotifyPHP(string Message)
  {
   Print("LineNotifyPHP");
   string HOST_LineNoti=HOST+"LineNotify.php";
   string str="MQL4_Token="+Token+
              "&MQL4_Message="+Message;

   string Header=NULL;
   string ResultHeader;
   char   SentData[];  // Data array to send POST requests 
   char   ResultData[];

   ArrayResize(SentData,StringToCharArray(str,SentData,0,WHOLE_ARRAY,CP_UTF8)-1);

   ResetLastError();
   int res=WebRequest("POST",HOST_LineNoti,Header,5000,SentData,ResultData,ResultHeader);
   int err=GetLastError();

   Print("#"+string(__LINE__)+" ["+HOST_LineNoti+"] LineNotifyPHP* res: "+string(res)+" | err: "+string(err));
  }
//+------------------------------------------------------------------+
