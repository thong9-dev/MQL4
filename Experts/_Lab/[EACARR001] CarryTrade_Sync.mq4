//+------------------------------------------------------------------+
//|                                  [EACARR001] CarryTrade_Sync.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
string ExtName_OBJ="Carry@";
bool ExtHide_OBJ=false;
bool CMD_XML_Show=false;

extern string IP="127.0.0.1";//IP Saver
extern string FileName_Pair="51530779@XM_Global_Limited";//Buddy
extern bool InvertOrder=false;
extern double LotsFollower=100;//LotsFollower (set in the percentage %)
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//My Info
string FileName_MY;
string _LOGIN_MY=string(AccountInfoInteger(ACCOUNT_LOGIN));
string _COMPANY_MY=AccountInfoString(ACCOUNT_COMPANY);
//Buddy info
string _LOGIN_Pair,_COMPANY_Pair;
//Host
string URL,HOST,HOST_Path="/_CopyTeade/";
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

   string result[];
   int k=StringSplit(FileName_Pair,StringGetCharacter("@",0),result);
   _LOGIN_Pair=result[0];
   _COMPANY_Pair=result[1];

   StringReplace(_COMPANY_MY," ","_");
   StringReplace(_COMPANY_MY,".","");
   FileName_MY=_LOGIN_MY+"@"+_COMPANY_MY;
//
   URL="http://"+IP;
   HOST=URL+HOST_Path;
//   
   set_InterfaceDraw(true);
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
int ERR_GET=0,ERR_PUSH=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TagsInfo[2]={"AccountProfit","AccountCurrency"};
string BuddyInfoSet[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   ERR_GET=Order_Get(PathXmlGet);
   string XML=XML_Read(PathXmlGet,false,__LINE__);

   Order_Copy(XML);

   int next=-1;
   int BoOrder=0,begin=0,end=0;
   ArrayResize(BuddyInfoSet,ArraySize(TagsInfo),0);
   string MyBuddy="";
     {
      BoOrder=StringFind(XML,"<Info>",BoOrder);
      //if(BoOrder==-1)
      //break;
      BoOrder+=6;
      next=StringFind(XML,"</Info>",BoOrder);
      //if(next==-1)
      //break;

      MyBuddy = StringSubstr(XML,BoOrder,next-BoOrder);
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

//SplitString --> Filter(RawString)
   int ERR_Snyc=0;
//if(OrdersTotal()!=index)
     {
      ERR_Snyc=Order_Snyc();
      ERR_PUSH=Order_Push();
     }
     {
      //--XML Chk err Connected

      color clrSaverSatus=clrWhite;
      string strSaverSatus="";

      if(ERR_GET!=4000)
        {
         clrSaverSatus=clrRed;
         strSaverSatus+="ERR_GET : ["+string(ERR_GET)+"]";
        }
      if(ERR_GET==4000 && ERR_PUSH!=4000 && ERR_PUSH!=0)
        {
         clrSaverSatus=clrRed;
         strSaverSatus+="ERR_PUSH : ["+string(ERR_PUSH)+"]";
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
      strSaverSatus+=" "+TimerTickSignal(TickSignal);
      setBUTTON_Text_Clr("Label_SaverSatus",strSaverSatus,int(GetClr_BACKGROUND),clrSaverSatus,clrSaverSatus,
                         WebRequest_ErrStr(ERR_GET));

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
   string   CCM="",CCS="\n     ";
   CCM+=CCS+"------ Information ------";
   CCM+=CCS+"LOGIN : "+_LOGIN_MY;
   CCM+=CCS+"COMPANY : "+_COMPANY_MY;
   CCM+=CCS+"------ Setting ------";
   CCM+=CCS+"Saver IP : [ "+IP+" ]";
   CCM+=CCS+"Buddy Name : [ "+FileName_Pair+" ]";
   CCM+=CCS+"InvertOrder : [ "+string(InvertOrder)+" ]";
   CCM+=CCS+"LotsFollower : [ "+string(LotsFollower)+"% ]";
   CCM+=CCS+"------ Synchronize ------";
   CCM+=CCS+"OrdersTotal : "+string(OrdersTotal())+" | "+string(index);
//CCM+=CCS+BuddyInfo;
   CCM+=CCS+"Buddy_AccountProfit : "+DoubleToString(double(BuddyInfoSet[0]),2)+" "+string(BuddyInfoSet[1]);
   Comment(CCM);
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

   return err;
  }
int index=0;
string Order[200][9];
int slippage=10;
//+------------------------------------------------------------------+
enum cORDER
  {
   eTicket=0,
   eType=1,
   eLots=2,
   eSymbol=3,
   ePrice=4,
   eSL=5,
   eTP=6,
   eComment=7,
   eMagic=8
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  Order_Copy(string sData)
  {
//                   0       1      2        3        4     5   6       7        8
   string Tags[9]={"Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};

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
      for(int i=0; i<9; i++)
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

            ResetLastError();
            Ticket=OrderSend(cSymbol,
                             Order_CopyInvertDir(cOP_DIR),
                             Order_CopyLotsFollower(cLOTS),
                             cOP,slippage,cSL,cTP,
                             string(cTicket),cTicket,
                             0);
            printf("OrderSend : "+string(GetLastError())+" "+string(Ticket));

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
double Order_CopyLotsFollower(double LotsMaster)
  {
   return NormalizeDouble(LotsMaster*(LotsFollower/100),2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_Snyc()
  {
   int err=0;

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
               printf("OrderClose A");
               bool c=OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),slippage);
              }
           }
         else
           {
            err++;
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
            printf("OrderClose B");
            bool c=OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),slippage);
           }

        }
      //---
     }
   return err;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_Push()
  {
   string Tags[9]={"Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};
   string dump[1];
   ArrayResize(dump,ArraySize(Tags),0);

   string OrderFamily;
   OrderFamily+="<Info>";
   OrderFamily+=XML_Tag(true,"AccountProfit")+string(AccountProfit())+XML_Tag(false,"AccountProfit");
   OrderFamily+=XML_Tag(true,"AccountCurrency")+AccountCurrency()+XML_Tag(false,"AccountCurrency");

   OrderFamily+="</Info>";
   OrderFamily+="<Port>";
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      //if(OrderMagicNumber()!=0) continue;
      //---
      dump[0]=string(OrderTicket());
      dump[1]=string(OrderType());
      dump[2]=string(OrderLots());
      dump[3]=string(OrderSymbol());
      dump[4]=string(OrderOpenPrice());
      dump[5]=string(OrderStopLoss());
      dump[6]=string(OrderTakeProfit());
      dump[7]=string(OrderComment());
      dump[8]=string(OrderMagicNumber());
      //---
      OrderFamily+="<Order>";
      for(int i=0;i<ArraySize(Tags);i++)
        {
         OrderFamily+="\t"+XML_Tag(true,Tags[i])+dump[i]+XML_Tag(false,Tags[i]);
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

   setBUTTON(ExtName_OBJ+"Label_ID",0,CORNER_LEFT_LOWER,int(XStep-10),Size_High,PostX,PostY,10,int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),int(GetClr_BACKGROUND),"My Account","");

   PostX+=XStep;
   setEditCreate(ExtName_OBJ+"ID",0,FileName_MY
                 ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_LOWER
                 ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),false,false,false,0
                 ,"My account is copied to pair account.");

   PostY+=YStep;
//---
   PostX=PostX_Default;
   if(Init)
      setBUTTON(ExtName_OBJ+"Label_SaverSatus",0,CORNER_LEFT_LOWER,int(XStep-10),Size_High,PostX,PostY,10,clrBlack,clrWhite,clrWhite,"SaverSatus","Tooltip");
   PostX+=XStep;

   setEditCreate(ExtName_OBJ+"IP",0,URL
                 ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_LOWER
                 ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),false,false,false,0
                 ,"IP host that is used. Must be set to match both.");

   PostY+=YStep;
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
