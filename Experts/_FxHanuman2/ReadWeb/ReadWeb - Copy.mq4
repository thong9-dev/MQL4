//+------------------------------------------------------------------+
//|                                                      ReadWeb.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ExtName_OBJ="Carry@";
bool ExtHide_OBJ=false;
bool CMD_XML_Show=false;

extern string IP="127.0.0.1";
string URL,HOST,HOST_Path="/_CopyTeade/";

extern string FileName_Pair="51496985@XM_Global_Limited";
string _LOGIN_Pair,_COMPANY_Pair;

extern bool InvertOrder=false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
string FileName_MY;
string _LOGIN_MY=string(AccountInfoInteger(ACCOUNT_LOGIN));
string _COMPANY_MY=AccountInfoString(ACCOUNT_COMPANY);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetMillisecondTimer(1000);

//_COMPANY="30212670@International_Capital_Markets_Pty_Ltd.";

   string result[];
   int k=StringSplit(FileName_Pair,StringGetCharacter("@",0),result);
   _LOGIN_Pair=result[0];
   _COMPANY_Pair=result[1];
//---

   StringReplace(_COMPANY_MY," ","_");
   StringReplace(_COMPANY_MY,".","");
   FileName_MY=_LOGIN_MY+"@"+_COMPANY_MY;
//---
   URL="http://"+IP;
   HOST=URL+HOST_Path;
//---

   set_InterfaceDraw(true);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Space=0.5;
int Size_Wide=400;
int Size_High=22;
int PostX_Default=10,XStep=int(Size_Wide*Space);
int PostY_Default=Size_High+5,YStep=Size_High;
//
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

//if(Init)
     {
      setBUTTON(ExtName_OBJ+"Label_ID",0,CORNER_LEFT_LOWER,int(XStep-10),Size_High,PostX,PostY,10,clrWhite,clrWhite,"");
      setBUTTON_Text_Clr("Label_ID","My Account",int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),int(GetClr_BACKGROUND));
     }
   PostX+=XStep;
   setEditCreate(ExtName_OBJ+"ID",0,FileName_MY
                 ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_LOWER
                 ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),false,false,false,0);

   PostY+=YStep;
//---
   PostX=PostX_Default;
   if(Init)
      setBUTTON(ExtName_OBJ+"Label_SaverSatus",0,CORNER_LEFT_LOWER,int(XStep-10),Size_High,PostX,PostY,10,clrBlack,clrWhite,"SaverSatus");
   PostX+=XStep;

   setEditCreate(ExtName_OBJ+"IP",0,URL
                 ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_LOWER
                 ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_BACKGROUND),false,false,false,0);
   PostY+=YStep;
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
   string   CCM="";
//CCM+="\n _LOGIN : "+_LOGIN;
//CCM+="\n _COMPANY : "+_COMPANY;
   CCM+="\n OrdersTotal() : "+string(OrdersTotal());
   Comment(CCM);
//---
   Order_Get();
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
   if(CHARTEVENT_CLICK)
     {
      //Print("CHARTEVENT_OBJECT_CLICK ["+sparam+"]");
      set_InterfaceDraw(false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_Get()
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
   string strSaverSatus="Connected";
   color clrSaverSatus=clrLime;

   if(err!=4000)
     {
      Print("#"+string(__LINE__)+" WebRequest. Code =",WebRequest_ErrStr(err));

      clrSaverSatus=clrRed;
      strSaverSatus="WebRequest : ["+string(err)+"]";
     }
   else if(res==200)
     {
      int filehandle=FileOpen("CarryTradeXML_GET.xml",FILE_WRITE|FILE_BIN);
      if(filehandle!=INVALID_HANDLE)
        {
         FileWriteArray(filehandle,ResultData,0,ArraySize(ResultData));
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error code=",GetLastError());

      Order_Copy_XML(xmlRead("CarryTradeXML_GET.xml",false,__LINE__));
     }

   setBUTTON_Text_Clr("Label_SaverSatus",strSaverSatus,int(GetClr_BACKGROUND),clrSaverSatus,clrSaverSatus);

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
string Order[200][9];
//+------------------------------------------------------------------+
//|                                                                  |
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
void  Order_Copy_XML(string sData)
  {
//                   0       1      2        3        4     5   6       7        8
   string Tags[9]={"Ticket","Type","Lots","Symbol","Price","SL","TP","Comment","Magic"};

   int next=-1;
   int BoOrder=0,begin=0,end=0;
   string MyOrder="";
   int index=0;
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
         next=StringFind(MyOrder,TagS(Tags[i]),begin);
         //printf("next :"+next);
         //--- Within this event, if tag not found, then it must be missing; skip it
         if(next==-1)
            continue;
         else
           {
            //--- We must have found the sTag okay...
            //--- Advance past the start tag
            begin=next+StringLen(TagS(Tags[i]));
            end=StringFind(MyOrder,TagE(Tags[i]),begin);
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
   string PathCopied="Carry\\Copied.txt";
   int slippage=10;
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

      if(cComment!=_LOGIN_MY)
        {
         //--- Check that copied
         string Copied=xmlRead(PathCopied,true,__LINE__);
         copy=StringFind(Copied,string(cTicket),0);
         //printf("copy : "+copy);

         if(copy==-1)
           {
            int Ticket=-1;

            ResetLastError();
            Ticket=OrderSend(cSymbol,
                             Order_InvertDir(cOP_DIR),
                             cLOTS,
                             cOP,slippage,cSL,cTP,string(cTicket),0,0);
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
               //printf("Copied else "+copy);
              }
           }
        }
     }
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      bool found=false;
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      for(int i=0;i<index;i++)
        {
         string  cTicket=Order[i][eTicket];
         if(OrderComment()==cTicket)
           {
            found=true;
            break;
           }
        }
      if(!found)
        {
         bool c=OrderClose(OrderTicket(),OrderLots(),OrderOpenPrice(),slippage);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Order_InvertDir(int OP)
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
string TagS(string v)
  {
   return "<"+v+">";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TagE(string v)
  {
   return "</"+v+">";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string xmlRead(string FileName,bool print,int line)
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
                   const long             z_order=0)                // priority for mouse click 
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
void setLabel(string Name,string Text,string Tooltip,color clr,int corner,int PostX,int PostY)
  {
   ObjectCreate(Name,OBJ_LABEL,0,0,0);
   ObjectSetText(Name,Text,9,"Arial",clr);
   if(Tooltip!="")
     {
      ObjectSetString(0,Name,OBJPROP_TOOLTIP,Tooltip);
     }

   ObjectSet(Name,OBJPROP_XDISTANCE,PostX);
   ObjectSet(Name,OBJPROP_YDISTANCE,PostY);

   ObjectSetInteger(0,Name,OBJPROP_CORNER,corner);

   ObjectSetInteger(0,Name,OBJPROP_BACK,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_SELECTED,false);
   ObjectSetInteger(ChartID(),Name,OBJPROP_HIDDEN,ExtHide_OBJ);
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
               int FONTSIZE,color COLOR,color BG,
               string TextStr
               )
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
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,COLOR);

   ObjectSetInteger(0,name,OBJPROP_COLOR,COLOR);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,ExtHide_OBJ);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBUTTON_Text_Clr(string Name,string Text,color FG,color BG,color BO)
  {
   ObjectSetString(0,ExtName_OBJ+Name,OBJPROP_TEXT,Text);

   ObjectSetInteger(0,ExtName_OBJ+Name,OBJPROP_COLOR,FG);

   ObjectSetInteger(0,ExtName_OBJ+Name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,ExtName_OBJ+Name,OBJPROP_BORDER_COLOR,BO);

  }
//+------------------------------------------------------------------+
