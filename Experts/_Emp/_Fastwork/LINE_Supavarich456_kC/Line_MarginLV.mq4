//+------------------------------------------------------------------+
//|                                                Line_MarginLV.mq4 |
//|                                 Copyright 2019,Golden Master TH. |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Golden Master TH."
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.10"
#property strict

//####################################################################
datetime Exp_Set=0;     //D'2019.07.01 23:59'
//+--#################################################################

//input string         extoken="ip5RPk5Cso9iLruE1O6dxJ1uLCa3rnIrBqV8oMtfFv5";    //TokenLine

extern string                    extoken="";    //TokenLine
extern string exS1=" ------------------------------ ";         //------------------------------
extern int Time_Check            =60;                 //Time Check Every (second)
int Time_Remin                   =Time_Check*2;

extern double Alert_MarginLV     =0;                  //MarginLV Alert

extern string exS2=" ------------------------------ ";         //------------------------------
extern bool exShowAcc_Name       =true;   //Name
extern bool exShowAcc_Number     =true;   //Number
extern bool exShowAcc_COMPANY    =false;  //COMPANY
extern bool exShowAcc_LEVERAGE   =false;  //LEVERAGE

extern string exS3=" ------------------------------ ";         //------------------------------
extern bool exShowAcc_MarginFree =true;   //Margin Free
extern bool exShowAcc_MarginLV   =true;   //Margin LV

extern bool exShowAcc_Margin     =false;  //Margin
extern bool exShowAcc_Holding    =false;  //Holding

extern bool exShow_Time          =true;   //Time

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int Clock_=1;
int Remine=1;
int MarketLife=3600;
string CMM="";
bool ExtHide_OBJ=false;
bool bTick=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);

   CMM+=str("Token",extoken,true);
   CMM+=str("Alert_MarginLV",DoubleToStr(Alert_MarginLV,2),true);
//---
   setBUTTON("LineMagin@TestToken",
             0,
             CORNER_RIGHT_UPPER,
             100,25,
             115,25,
             true,10,clrWhite,clrBlue,clrGray,
             "Test"
             );
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

   ObjectsDeleteAll(0,"LineMagin@",0,OBJ_BUTTON);
   Comment("");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MarketLife+=30;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
string rSTR;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   bool EXP_=EXP();
//---

   int LINE=-1;
//---
   int add=1;
   Clock_+=add;
   Remine+=add;
   MarketLife-=add;
//---
   bool _Clock_=TIME_MM(Clock_,Time_Check,true);
   bool _Remine=TIME_MM(Remine,Time_Remin,false);

//---
   if(_Clock_ && _Remine && OrdersTotal()>0 && MarketLife>0)
     {

      if(Alert_MarginLV>=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL))
        {

         LINE=LINE_Hub(rSTR,true);
         printf(LINE);
         if(LINE==200)
           {
            Remine=1;
           }
        }

     }

   LINE=LINE_Hub(rSTR,false);
   string cmm=" "+Tick();

   cmm+=str("EXP_EA Not Working !! 088-659-3174",string(Exp_Set),!EXP_);

   cmm+="\n --------------------------------- ";
   cmm+="\n --- Seting ";
   cmm+="\n --------------------------------- ";
   cmm+=CMM;
   cmm+="\n --------------------------------- ";
   cmm+="\n --- Exsample Line ";
   cmm+="\n --------------------------------- ";
   cmm+=rSTR;
   cmm+="\n --------------------------------- ";
   Comment(cmm);

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TIME_MM(int &Counting,int Set,bool S)
  {
   bool b=Counting>=Set;
   if(b && S) Counting=1;
   return b;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LINE_Hub(string &_str,bool _Alert)
  {
   string strInfo="",strLINE="";

   strInfo+=str("Name",       string(AccountName()),exShowAcc_Name);
   strInfo+=str("Number",     string(AccountNumber()),exShowAcc_Number);
   strInfo+=str("COMPANY",    string(AccountInfoString(ACCOUNT_COMPANY)),exShowAcc_COMPANY);
   strInfo+=str("LEVERAGE",   string(AccountInfoInteger(ACCOUNT_LEVERAGE)),exShowAcc_LEVERAGE);
   strLINE+="---";
   strLINE+=str("Margin Free",DoubleToStr(AccountFreeMargin(),2),exShowAcc_MarginFree);
   strLINE+=str("Margin LV",  DoubleToStr(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),2),exShowAcc_MarginLV);

   strLINE+=str("Margin",     DoubleToStr(AccountMargin(),2),exShowAcc_Margin);
   strLINE+=str("Holding",    DoubleToStr(AccountInfoDouble(ACCOUNT_PROFIT),2),exShowAcc_Holding);

   strLINE+=str("Time",TimeToStr(TimeCurrent(),TIME_SECONDS)+" "+TimeToStr(TimeCurrent(),TIME_DATE),exShow_Time);

   _str=strInfo+"\n"+strLINE;
   if(_Alert)
      return LineNotify(_str);
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string str(string Para,string var,bool flag)
  {
   return (!flag)?"":("\n "+Para+" :: "+var);
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
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      Print("CHARTEVENT_OBJECT_CLICK ["+sparam+"]");
      if(sparam=="LineMagin@TestToken")
        {

         int rMessageBox=MessageBox("You want to test the signal ?","TestToken",MB_ICONQUESTION|MB_OKCANCEL);
         if(rMessageBox==IDOK)
           {
            LINE_Hub(rSTR,true);
           }

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SecToMins(int v)
  {
   return NormalizeDouble(double(v)/60,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LineNotify(string Massage)
  {
   int res=-1;
   if(extoken!="")
     {
      string Headers,Content;
      char post[],result[];

      Headers="Authorization: Bearer "+extoken+"\r\n";
      Headers+="Content-Type: application/x-www-form-urlencoded\r\n";

      Content="message="+Massage;

      int size=StringToCharArray(Content,post,0,WHOLE_ARRAY,CP_UTF8)-1;
      ArrayResize(post,size);

      res=WebRequest("POST","https://notify-api.line.me/api/notify",Headers,10000,post,result,Headers);

      //Print("Status code: ",res,",error: ",GetLastError());
      Print("Server response: ",string(res),CharArrayToString(result));
      if(res==-1)
        {
         string Mressage="#Not Allow WebRequest() !!\n";
         Mressage+="Tools-->Expert Advisors-->Allow Web\n";
         Mressage+="\" https://notify-api.line.me/api/notify \"";
         Alert(Mressage);
        }
     }
   else
     {
      int rMessageBox=MessageBox("The token value is not set.","Token",MB_ICONQUESTION);
     }
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setBUTTON(string name,
               int panel,
               ENUM_BASE_CORNER CORNER,
               int XSIZE,int YSIZE,
               int XDIS,int YDIS,
               bool Bold,int FONTSIZE,color COLOR,color BG,color BBG,
               string TextStr
               )
  {
//---
   if(!ObjectCreate(0,name,OBJ_BUTTON,panel,0,0))
     {
      ObjectSet(name,OBJPROP_XDISTANCE,XDIS);
      ObjectSet(name,OBJPROP_YDISTANCE,YDIS);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,ExtHide_OBJ);
      // return false;
     }
//---
   ObjectSetInteger(0,name,OBJPROP_XSIZE,XSIZE);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,YSIZE);

   ObjectSet(name,OBJPROP_XDISTANCE,XDIS);
   ObjectSet(name,OBJPROP_YDISTANCE,YDIS);

   ObjectSetString(0,name,OBJPROP_FONT,(Bold)?"Arial Black":"Arial");

   ObjectSetString(0,name,OBJPROP_TEXT,TextStr);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,TextStr);

   ObjectSetInteger(0,name,OBJPROP_COLOR,COLOR);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BG);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,BBG);

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER);

   return true;
//---
  }
//+------------------------------------------------------------------+
string Tick()
  {
   bTick=(bTick)?false:true;
   return (bTick)?"X":"O";
  }
//+------------------------------------------------------------------+
bool EXP()
  {
   if(Exp_Set>0)
      return (Exp_Set-TimeCurrent())>=0;
   return true;
  }
//+------------------------------------------------------------------+
