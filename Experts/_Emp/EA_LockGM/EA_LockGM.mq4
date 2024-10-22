//+------------------------------------------------------------------+
//|                                                    EA_LockGM.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import
#import "shell32.dll"
int ShellExecuteA(int hWnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

string ExtName_OBJ="EALock@";
bool ExtHide_OBJ=false;

extern string Identity="1VmDuqo4MiYr5RSsbCy0_PIT6ozVrR6t5";//GooldleDrive #Identity
                                                           //1VmDuqo4MiYr5RSsbCy0_PIT6ozVrR6t5       TestPer.txt

extern string dst_path="";//LocalGooldleDrive #Path
extern string LocalGoogle_FileName="";//LocalGooldleDrive #FileName

extern color COLOR_BACKGROUND=clrBlack;
extern color COLOR_FOREGROUND=clrWhite;

string PathMT4="Lock\\";
string ListName=LocalGoogle_FileName;
//string ListName="ListName.xml";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);

   ObjDelete_New();
   set_InterfaceDraw(true);
   setTemplate();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Space=0.5;
double Column1=0.4;
int Size_Wide=200;
int Size_High=22;
int PostX_Default=10,XStep=int(Size_Wide+10);
int PostY_Default=50,YStep=Size_High+5;

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

   setLabelCreate(0,ExtName_OBJ+"ID_Label",0,PostX,PostY,CORNER_LEFT_UPPER,"ID : ","Arial",10,
                  int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);

   PostX+=int(XStep*Column1);

   setEditCreate(ExtName_OBJ+"ID_Edit",0,""
                 ,true,false,PostX,PostY,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_UPPER
                 ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),false,false,false,0
                 ,"");

   PostX+=int(XStep);

   setBUTTON(ExtName_OBJ+"BTN_Search",0,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,10,
             int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),"Search","");

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setTemplate()
  {
   ChartSetInteger(0,CHART_SHOW_GRID,false);
   ChartSetInteger(0,CHART_SHOW_OHLC,false);

   ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,false);
   ChartSetInteger(0,CHART_SHOW_DATE_SCALE,false);
   ChartSetInteger(0,CHART_DRAG_TRADE_LEVELS,false);
   ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,false);

   ChartSetInteger(0,CHART_MODE,CHART_LINE);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,COLOR_BACKGROUND);
   ChartSetInteger(0,CHART_COLOR_GRID,COLOR_BACKGROUND);

   ChartSetInteger(0,CHART_COLOR_BACKGROUND,COLOR_BACKGROUND);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,COLOR_FOREGROUND);

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
string Current_ID,Current_FName,Current_LName,Current_Trpe;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Print("CHARTEVENT_OBJECT_CLICK '"+sparam+"'");

      int objPost_X,objPost_Y;

      int objPost_X0=int(ObjectGetInteger(0,ExtName_OBJ+"ID_Label",OBJPROP_XDISTANCE));
      int objPost_Y0=int(ObjectGetInteger(0,ExtName_OBJ+"ID_Label",OBJPROP_YDISTANCE));
      //------------------------------------------------------------------------
      if(sparam==ExtName_OBJ+"BTN_Search")
        {

         ObjectDelete(0,ExtName_OBJ+"Result");

         //---
         Print("------------------------------------------------------------------------");
         string getID_Edit=ObjectGetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT);
         Print(ExtName_OBJ+"BTN_Search : ["+getID_Edit+"]");
         //---
         if(getID_Edit!="")
           {
            string result[];
            //---
            DownloadPage(ListName);
            //---
            int ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);

            int Find=-1;

            string str;
            while(!FileIsEnding(ListName_Hand))
              {
               str=FileReadString(ListName_Hand);
               //PrintFormat("FileRead ["+str+"]");
               if(str!="<List>" && str!="</List>" && str!="")
                 {
                  StringReplace(str,"<User>","");
                  StringReplace(str,"</User>","");

                  int k=StringSplit(str,StringGetCharacter(",",0),result);

                  if(result[0]==getID_Edit)
                    {
                     Find=0;
                     break;
                    }
                 }
              }
            FileClose(ListName_Hand);
            //FileDelete(PathMT4+ListName);

            //---
            Print("//------");
            Print("#"+string(__LINE__)+" Find ["+string(Find)+"] ["+str+"]");

            if(Find>=0)
              {
               Current_ID=result[0];
               Current_FName=result[1];
               Current_LName=result[2];
               Current_Trpe=result[3];

               PrintFormat("ID ["+result[0]+"]");
               PrintFormat("Name ["+result[1]+"]");
               PrintFormat("Lame ["+result[2]+"]");

               objPost_X=objPost_X0;
               objPost_Y=objPost_Y0+YStep;

               setLabelCreate(0,ExtName_OBJ+"FristName_Label",0,objPost_X,objPost_Y,CORNER_LEFT_UPPER,"First name : ","Arial",10,
                              int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);
               objPost_X+=int(XStep*Column1);

               setEditCreate(ExtName_OBJ+"Name_Edit",0,result[1]
                             ,true,false,objPost_X,objPost_Y,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_UPPER
                             ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),false,false,false,0
                             ,"");
               objPost_X+=XStep;
               setBUTTON(ExtName_OBJ+"BTN_Edit",0,CORNER_LEFT_UPPER,Size_Wide,Size_High,objPost_X,objPost_Y,10,
                         int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),"Edit","");
               //---
               objPost_X=objPost_X0;
               objPost_Y+=YStep;

               setLabelCreate(0,ExtName_OBJ+"LastName_Label",0,objPost_X,objPost_Y,CORNER_LEFT_UPPER,"Last name : ","Arial",10,
                              int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);
               objPost_X+=int(XStep*Column1);

               setEditCreate(ExtName_OBJ+"NameL_Edit",0,result[2]
                             ,true,false,objPost_X,objPost_Y,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_UPPER
                             ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),false,false,false,0
                             ,"");
               objPost_X+=XStep;

               setBUTTON(ExtName_OBJ+"BTN_Delete",0,CORNER_LEFT_UPPER,Size_Wide,Size_High,objPost_X,objPost_Y,10,
                         int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),"Delete","");
               //---
               objPost_X=objPost_X0;
               objPost_Y+=YStep;

               setLabelCreate(0,ExtName_OBJ+"Type_Label",0,objPost_X,objPost_Y,CORNER_LEFT_UPPER,"Status : ","Arial",10,
                              int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);
               objPost_X+=int(XStep*Column1);

               setEditCreate(ExtName_OBJ+"Type_Edit",0,result[3]
                             ,true,false,objPost_X,objPost_Y,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_UPPER
                             ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),false,false,false,0
                             ,"");
               objPost_X+=XStep;

               setBUTTON(ExtName_OBJ+"BTN_New",0,CORNER_LEFT_UPPER,Size_Wide,Size_High,objPost_X,objPost_Y,10,
                         int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),"New","");

              }
            else
              {
               PrintFormat("#"+string(__LINE__)+" Not found");

               ObjDelete_New();

               objPost_X=objPost_X0;
               objPost_Y=objPost_Y0+YStep;

               objPost_X+=int(XStep*Column1);

               setLabelCreate(0,ExtName_OBJ+"Result",0,objPost_X,objPost_Y,CORNER_LEFT_UPPER,"Not found","Arial",10,
                              int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);

               objPost_X+=XStep;

               setBUTTON(ExtName_OBJ+"BTN_Register",0,CORNER_LEFT_UPPER,Size_Wide,Size_High,objPost_X,objPost_Y,10,
                         int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),"Register","");
               //---

               objPost_Y+=YStep;
               objPost_X=objPost_X0;

               objPost_X+=int(XStep*Column1);
               objPost_X+=XStep;

               setBUTTON(ExtName_OBJ+"BTN_New",0,CORNER_LEFT_UPPER,Size_Wide,Size_High,objPost_X,objPost_Y,10,
                         int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),"New","");

              }
           }
        }
      //------------------------------------------------------------------------
      if(sparam==ExtName_OBJ+"ID_Edit")
        {

         //---

         //bool S=ObjectSetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT,"S");

        }
      //------------------------------------------------------------------------
      if(sparam==ExtName_OBJ+"BTN_New")
        {
         ObjDelete_New();
         bool S=ObjectSetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT,"");
        }
      //------------------------------------------------------------------------
      if(sparam==ExtName_OBJ+"BTN_Register")
        {
         objPost_X=objPost_X0;
         objPost_Y=objPost_Y0+YStep;

         setLabelCreate(0,ExtName_OBJ+"FristName_Label",0,objPost_X,objPost_Y,CORNER_LEFT_UPPER,"First name : ","Arial",10,
                        int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);
         objPost_X+=int(XStep*Column1);

         setEditCreate(ExtName_OBJ+"Name_Edit",0,""
                       ,true,false,objPost_X,objPost_Y,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_UPPER
                       ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),false,false,false,0
                       ,"");

         objPost_X+=XStep;
         setBUTTON(ExtName_OBJ+"BTN_Submit",0,CORNER_LEFT_UPPER,Size_Wide,Size_High,objPost_X,objPost_Y,10,
                   int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),"Submit","");

         objPost_X=objPost_X0;
         objPost_Y+=YStep;

         setLabelCreate(0,ExtName_OBJ+"LastName_Label",0,objPost_X,objPost_Y,CORNER_LEFT_UPPER,"Last name : ","Arial",10,
                        int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);
         objPost_X+=int(XStep*Column1);

         setEditCreate(ExtName_OBJ+"NameL_Edit",0,""
                       ,true,false,objPost_X,objPost_Y,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_UPPER
                       ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),false,false,false,0
                       ,"");

         objPost_X=objPost_X0;
         objPost_Y+=YStep;

         setLabelCreate(0,ExtName_OBJ+"Type_Label",0,objPost_X,objPost_Y,CORNER_LEFT_UPPER,"Status : ","Arial",10,
                        int(GetClr_FOREGROUND),0,ANCHOR_LEFT_UPPER);
         objPost_X+=int(XStep*Column1);

         setEditCreate(ExtName_OBJ+"Type_Edit",0,""
                       ,true,false,objPost_X,objPost_Y,Size_Wide,Size_High,"Arial",10,ALIGN_LEFT,CORNER_LEFT_UPPER
                       ,int(GetClr_BACKGROUND),int(GetClr_FOREGROUND),int(GetClr_FOREGROUND),false,false,false,0
                       ,"");

         ObjectDelete(0,ExtName_OBJ+"BTN_Register");
        }
      //------------------------------------------------------------------------
      if(sparam==ExtName_OBJ+"BTN_Submit")
        {

         DownloadPage(ListName);
         //---
         int ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);

         string temp="",str="";
         while(!FileIsEnding(ListName_Hand))
           {
            temp=FileReadString(ListName_Hand);
            if(temp!="<List>" && temp!="")
              {
               str+="\n";
              }
            if(temp!="")
              {
               str+=temp;
              }
           }
         FileClose(ListName_Hand);

         if(str=="")
           {
            str="<List>\n</List>";
            printf("str null");
           }

         string getID_Edit=ObjectGetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT);
         string getName_Edit=ObjectGetString(0,ExtName_OBJ+"Name_Edit",OBJPROP_TEXT);
         string getNameL_Edit=ObjectGetString(0,ExtName_OBJ+"NameL_Edit",OBJPROP_TEXT);
         string getType_Edit=ObjectGetString(0,ExtName_OBJ+"Type_Edit",OBJPROP_TEXT);

         string Message="\n ID : "+getID_Edit+
                        "\n FirstName : "+getName_Edit+
                        "\n Last Name : "+getNameL_Edit+
                        "\n Type : "+getType_Edit;

         int  MessageBoxResult=MessageBox(Message,"Add customers",MB_YESNOCANCEL|MB_ICONQUESTION);
         if(MessageBoxResult==IDYES)
           {

            string New_str="<User>"+getID_Edit+","+getName_Edit+","+getNameL_Edit+","+getType_Edit+"</User>\n</List>";

            StringReplace(str,"</List>",New_str);

            FileDelete(PathMT4+ListName);

            ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);
            FileWriteString(ListName_Hand,str);
            FileClose(ListName_Hand);

            Print("BTN_Register : "+str);

            //
            CMD_MoveFileToGD();
            //Shell();
            //---
            //New
            ObjDelete_New();
            bool S=ObjectSetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT,"");

           }
         if(MessageBoxResult==IDNO)
           {
            ObjDelete_New();
            bool S=ObjectSetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT,"");

           }
        }
      //------------------------------------------------------------------------
      if(sparam==ExtName_OBJ+"BTN_Edit")
        {
         DownloadPage(ListName);
         int ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);

         string temp="",str="";
         while(!FileIsEnding(ListName_Hand))
           {
            temp=FileReadString(ListName_Hand);
            if(temp!="<List>" && temp!="")
              {
               str+="\n";
              }
            if(temp!="")
              {
               str+=temp;
              }
           }
         FileClose(ListName_Hand);
         FileDelete(PathMT4+ListName);

         //string Current_ID,Current_FName,Current_LName,Current_Trpe;
         string Current_str="<User>"+Current_ID+","+Current_FName+","+Current_LName+","+Current_Trpe+"</User>";

         string getID_Edit=ObjectGetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT);
         string getName_Edit=ObjectGetString(0,ExtName_OBJ+"Name_Edit",OBJPROP_TEXT);
         string getNameL_Edit=ObjectGetString(0,ExtName_OBJ+"NameL_Edit",OBJPROP_TEXT);
         string getType_Edit=ObjectGetString(0,ExtName_OBJ+"Type_Edit",OBJPROP_TEXT);

         string New_str="<User>"+getID_Edit+","+getName_Edit+","+getNameL_Edit+","+getType_Edit+"</User>";
         //---
         string Message="\n ID : "+Current_ID+" --> "+getID_Edit+
                        "\n FirstName : "+Current_FName+" --> "+getName_Edit+
                        "\n Last Name : "+Current_LName+" --> "+getNameL_Edit+
                        "\n Type : "+Current_Trpe+" --> "+getType_Edit;

         int  MessageBoxResult=MessageBox(Message,"Add customers",MB_YESNOCANCEL|MB_ICONQUESTION);
         if(MessageBoxResult==IDYES)
           {

            StringReplace(str,Current_str,New_str);

            ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);
            FileWriteString(ListName_Hand,str);
            FileClose(ListName_Hand);

            CMD_MoveFileToGD();
            //Shell();

            ObjDelete_New();
           }
         if(MessageBoxResult==IDNO)
           {
            ObjDelete_New();
           }
        }
      //------------------------------------------------------------------------
      if(sparam==ExtName_OBJ+"BTN_Delete")
        {
         DownloadPage(ListName);
         int ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);

         string temp="",str="";
         while(!FileIsEnding(ListName_Hand))
           {
            temp=FileReadString(ListName_Hand);
            if(temp!="<List>" && temp!="")
              {
               str+="\n";
              }
            if(temp!="")
              {
               str+=temp;
              }
           }
         FileClose(ListName_Hand);
         FileDelete(PathMT4+ListName);

         //string Current_ID,Current_FName,Current_LName,Current_Trpe;
         string Current_str="<User>"+Current_ID+","+Current_FName+","+Current_LName+","+Current_Trpe+"</User>";

         string getID_Edit=ObjectGetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT);
         string getName_Edit=ObjectGetString(0,ExtName_OBJ+"Name_Edit",OBJPROP_TEXT);
         string getNameL_Edit=ObjectGetString(0,ExtName_OBJ+"NameL_Edit",OBJPROP_TEXT);
         string getType_Edit=ObjectGetString(0,ExtName_OBJ+"Type_Edit",OBJPROP_TEXT);

         string New_str="";

         StringReplace(str,Current_str,New_str);

         ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);
         FileWriteString(ListName_Hand,str);
         FileClose(ListName_Hand);

         ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);
         temp="";
         str="";
         while(!FileIsEnding(ListName_Hand))
           {
            temp=FileReadString(ListName_Hand);
            if(temp!="<List>" && temp!="")
              {
               str+="\n";
              }
            if(temp!="")
              {
               str+=temp;
              }
           }
         FileClose(ListName_Hand);

         FileDelete(PathMT4+ListName);

         ListName_Hand=FileOpen(PathMT4+ListName,FILE_WRITE|FILE_READ|FILE_TXT);
         FileWriteString(ListName_Hand,str);
         FileClose(ListName_Hand);

         //
         CMD_MoveFileToGD();
         //Shell();
         //            
         ObjDelete_New();

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DownloadPage(string FileName)
  {
   if(Identity!="")
     {

      int ListName_Hand=FileOpen(PathMT4+FileName,FILE_WRITE|FILE_READ|FILE_TXT);
      FileClose(ListName_Hand);
      FileDelete(PathMT4+ListName);

      //string sUrl="https://drive.google.com/uc?id="+Identity+"&export=download";
      //string sUrl="https://drive.google.com/uc?authuser=0&id="+Identity+"&export=download";


      string sUrl="https://drive.google.com/uc?id="+Identity+"&authuser=0&export=download";

      string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\"+PathMT4,FileName);
      int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);

      printf("#"+string(__LINE__)+" DownloadPage "+string(FileGet));
     }
   else
     {
      printf("#"+string(__LINE__)+" Identity is NULL");
      bool S=ObjectSetString(0,ExtName_OBJ+"ID_Edit",OBJPROP_TEXT,"Identity is NULL");

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjDelete_New()
  {
   ObjectDelete(0,ExtName_OBJ+"FristName_Label");
   ObjectDelete(0,ExtName_OBJ+"LastName_Label");
   ObjectDelete(0,ExtName_OBJ+"Type_Label");

   ObjectDelete(0,ExtName_OBJ+"Name_Edit");
   ObjectDelete(0,ExtName_OBJ+"NameL_Edit");
   ObjectDelete(0,ExtName_OBJ+"Type_Edit");

   ObjectDelete(0,ExtName_OBJ+"BTN_Edit");
   ObjectDelete(0,ExtName_OBJ+"BTN_Delete");
   ObjectDelete(0,ExtName_OBJ+"BTN_New");
   ObjectDelete(0,ExtName_OBJ+"BTN_Register");
   ObjectDelete(0,ExtName_OBJ+"BTN_Submit");

   ObjectDelete(0,ExtName_OBJ+"Result");

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
bool setLabelCreate(const long              chart_ID=0,// chart's ID 
                    const string            name="Label",             // label name 
                    const int               sub_window=0,             // subwindow index 
                    const int               x=0,                      // X coordinate 
                    const int               y=0,                      // Y coordinate 
                    const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                    const string            text="Label",             // text 
                    const string            font="Arial",             // font 
                    const int               font_size=10,             // font size 
                    const color             clr=clrRed,               // color 
                    const double            angle=0.0,                // text slope 
                    const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER) // anchor type 
  {
//--- reset the error value 
   ResetLastError();
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      //Print(__FUNCTION__,": failed to create text label! Error code = ",GetLastError());
      //return(false);
     }
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true) 
//ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
//ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
//ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,ExtHide_OBJ);
//--- set the priority for receiving the event of a mouse click in the chart 
//ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
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
void CMD_MoveFileToGD()
  {
   string LocalMT4_FileName=PathMT4+ListName;
   string src_path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+LocalMT4_FileName;
//
   string dst_dir=dst_path+"\\"+LocalGoogle_FileName;
/*
            ShellExecuteW( int hwnd,
                           string Operation,
                           string File,
                           string Parameters,
                           string Directory,
                           int ShowCmd);
*/
   int hwnd=NULL;
   string Directory=NULL;
   int ShowCmd=NULL;
//            
   int r=ShellExecuteW(hwnd,
                       "open",
                       "cmd.exe",
                       "/c copy /Y "+src_path+" "+dst_dir,
                       Directory,
                       ShowCmd);
   int Err=GetLastError();
//---
   int Scan_dst=StringFind(dst_dir," ",0);
   int Scan_src=StringFind(src_path," ",0);

   Print("# "+string(__LINE__)+"___Dest["+string(Scan_dst)+"] : ["+dst_dir+"]");
   Print("# "+string(__LINE__)+" Source["+string(Scan_src)+"] : ["+src_path+"]");
   Print("# "+string(__LINE__)+" ShellExecuteW : "+string(r)+" | Err : "+string(Err));
   Print("# "+string(__LINE__)+" hwnd: ["+string(hwnd)+"] | Directory: ["+string(Directory)+"] | ShowCmd: ["+string(ShowCmd)+"]");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _Shell()
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
//---
   string LocalMT4_FileName=PathMT4+ListName;
   string src_path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+LocalMT4_FileName;
//
   string dst_dir=dst_path+"\\"+LocalGoogle_FileName;

   string file="cmd.exe";
   string parameters="/c copy /Y "+src_path+" "+dst_dir;

//---

   int r=ShellExecuteA(NULL,OPERATION,file,parameters,NULL,NULL);

   if(r<=32)
     {
      Alert("Shell failed: ",r); return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
