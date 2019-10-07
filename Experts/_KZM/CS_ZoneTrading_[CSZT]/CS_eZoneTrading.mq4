//+------------------------------------------------------------------+
//|                                                   CS_ZoneTrading |
//|                                         Copyright 2012, lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict "s"
#property description "- The basis developed from the concept of the Mudleygroup" 

#include <Tools/Method_Tools.mqh>
//#include <../Experts/KZM/CS_ZoneTrading_[CSZT]/>
#include "include/CSZT_OnChartEvent.mqh"
#include "include/NavagateLine.mqh"
#include "include/Auto_Manager.mqh"
#include "include/Tools.mqh"

//--- Daran0
string ExtName_Full="CS_ZoneTrading";
string ExtName_OBJ="ZoneTrade ";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum intervals  // Enumeration of named constants 
  {
   P005=5,//  5%__= 20 ZoneB
   P010=10,// 10%_= 10 ZoneB
   P020=20,// 20%_= 5 ZoneB
   P025=25,// 25%_= 4 ZoneB
   P050=50,// 50%_= 2 ZoneB
   P100=100//100% = 1 ZoneB
  };
extern double     Capital           =0.5;          //Capital : Order
extern bool       Calculate_Margin  =false;        //Calculate margin
extern string     extline="________ Auto_Pending ______";//---
extern bool       Auto_PendingA     =true;         //Pending Adams
extern bool       Auto_PendingB     =true;         //Pending Boston
extern intervals  ENUM_ConstantZone =P020;         //Dividing zone A using
extern bool       Auto_RSI          =true;         //#Pending Chicago
extern int        Auto_RSI_period=24;              //#Chicago RSI Period
extern string     extline2="________ TakeProfits Gimmicks ________";//---
extern bool       TP_UseATR         =false;        //ATR tTP
extern bool       TP_UseSPREAD      =false;        //ATR tTP-SPREAD
extern int        Slippage          =5;            //Slippage (Point)
extern double     Guide_YN          =1.5;          //Guide Year
extern color      clrZone_A         =clrDarkOrange;//Color Line Zone-A

int windex=-1;

string strCMMResult="A";
bool strCMMResult_bool=true;
bool infoFull=false;

double DeadLine=-1;
int Zone_A_cnt=-1,Zone_B_cnt=-1;
int Zone_A_Ask=-1,Zone_B_Ask=-1;
int Obj_A_cnt=-1;
double TroopA[1];
double TroopB[1][20];
double TroopB_PTP[1];
bool boolZoneA_Show=true;
bool boolZoneB_Show=true;
long _clrLineZoneB=C'51,51,51';
double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL)/MathPow(10,Digits);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   printf("//+-------------------------------------------------------------------------------------------------------------------+");
   Comment("");
//--- indicator buffers mapping
   EventSetMillisecondTimer(1000);

//IndicatorShortName(ExtName_Full);
   windex=WindowFind(ExtName_Full);

   printf(ExtName_Full+" windex :"+string(windex));
//---
   DeadLine=-1;
   ObjectsDeleteAll(ChartID(),ExtName_OBJ,windex,OBJ_BUTTON);
//---
   Management_ZoneA_init();
//clr_LineZoneB("UP");
//---
   BTN_init();

   OnTimer();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   printf("//+-------------------------------------------------------------------------------------------------------------------+ 2OnDeinit");

//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool boolAutoPending=false;
int checkError=ERR_NO_ERROR;
//---
double SPREADsum,SPREADcnt;
int SPREADavg;
//---
bool Detect_Trend=false;
double Detect_Trend_RSI=5;
int Detect_Trend_TimeFrame=0;
//+------------------------------------------------------------------+
void OnTick()
  {
/*for(int i=0;i<ArraySize(TroopB_PTP);i++)
     {
      HLineCreate_(0,ExtName_OBJ+"LINE_"+c(i),"",0,TroopB_PTP[i],clrMagenta,1,0,0,true,false,0);
     }*/
//---
   DrawBidAsk();
//OnTimer();
   Timer_here=true;
   DrawObj_Timer();
//---
   checkError=ERR_NO_ERROR;
//---
   debug_SPREAD();

   if(boolAutoPending)
     {
      if(Auto_PendingA)
        {
         AutoPending_Adams();
        }
      else
        {
         Delete_Pending(OP_BUYLIMIT,1);
         Delete_Pending(OP_BUYSTOP,1);
        }
      //
      if(Auto_PendingB)
        {
         AutoPending_Boston();
        }
      else
        {
         Delete_Pending(OP_BUYLIMIT,2);
         Delete_Pending(OP_BUYSTOP,2);
        }

        {//---
         double _iRSI=iRSI(Symbol(),Detect_Trend_TimeFrame,Auto_RSI_period,PRICE_CLOSE,0);
         _iRSI=NormalizeDouble(_iRSI,4);

         string Detect_Mean="DW";
         Detect_Trend=false;
         if(_iRSI>Detect_Trend_RSI)
           {
            Detect_Trend=true;
            Detect_Mean="UP";
           }

         //+------------------------------------------------------------------+
         string name=ExtName_OBJ+"BTN_CS_Auto_RSI";
         int PostX=(int)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
         int PostY=(int)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
         //PostX+=XStep;
         PostY+=YStep;

         string Text=PeriodToStr(Detect_Trend_TimeFrame)+"# "+c(Detect_Trend_RSI,2)+" | "+c(_iRSI,2)+" | "+Detect_Mean;
         name=ExtName_OBJ+"Auto_RSI_1";
         ObjectCreText(name,PostX,PostY);
         ObjectSetText(name,Text,10,"Arial",clrWhite);
         ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,false);
         //+------------------------------------------------------------------+
         //---

         if(!Detect_Trend && Auto_RSI)
           {
            AutoPending_Sell();
           }
         else
           {
            Delete_Pending(OP_SELLSTOP,3);
            //---
            ObjectDelete(0,ExtName_OBJ+"LINE_DeadLine_Sell(Auto)");
           }
        }
     }
     {
      NavagateLine();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Timer=true;
bool Timer_here=true;
double ATR=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ATR=NormalizeDouble(iATR(Symbol(),PERIOD_H1,1,1)*0.5,Digits);
//---
   strCMMResult="";
   strCMMResult+="AutoPending: [ "+BoolToStr_OnOff(boolAutoPending)+" ]";
   strCMMResult+=" A["+BoolToStr_OnOff(Auto_PendingA)+"]";
   strCMMResult+=" B["+BoolToStr_OnOff(Auto_PendingB)+"]\n";
   strCMMResult+="TP_ATR [ "+BoolToStr_OnOff(TP_UseATR)+" ] : "+c(ATR,Digits)+"\n";
   strCMMResult+="TP_PREAD [ "+BoolToStr_OnOff(TP_UseSPREAD)+" ]\n";
     {
      Timer_here=false;
      DrawObj_Timer();
     }
     {
      Management_ZoneA_info();
      Management_ZoneB_info();

      Management_DeadLine();
     }
     {
/*strCMMResult+="-------\n";
      if(Zone_A_Ask>=0 || Zone_B_Ask>=0)
        {
         strCMMResult+="Price in Dock : "+c(Zone_A_Ask+1)+"|"+c(Zone_B_Ask+1)+"\n";
        }*/
     }
     {
      // printf(l(__LINE__,"NowOrder_Cnt")+Now_Array[NowOrder_Cnt-1][0]);
      // printf(l(__LINE__,"NowOrder_Cnt")+ArraySize(Now_Array));
     }
     {//DeadLine
      strCMMResult+=l(__LINE__)+" DeadLine: "+c(DeadLine,Digits)+"\n";
     }
     {
      if(strCMMResult_bool)
        {
         Comment(strCMMResult);
         CostTableTag();
        }
      else
        {
         Comment("");
         ObjectsDeleteAll(0,ExtName_OBJ+"PutTage",0,OBJ_LABEL);
        }
     }
   OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Management_ZoneB_getConstant()
  {
   return NormalizeDouble(double(ENUM_ConstantZone)/100,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _File_Handle(int FromLine,string mode)
  {
   int hand=-1,r=-1;
   int err=GetLastError();
   ulong _FileSize=-1;
   string path,folder,fileName;
   folder=StringTrimRight(ExtName_OBJ)+"2//";
//
   string _ACCOUNT_SERVER=AccountInfoString(ACCOUNT_SERVER);
//_ACCOUNT_SERVER=StringSubstr(_ACCOUNT_SERVER,0,)
//
   fileName="CSZT_"+_File_getName()+"_["+string(AccountInfoInteger(ACCOUNT_LOGIN))+"_"+_ACCOUNT_SERVER+"].csv";
   path=folder+fileName;

   if(mode=="Find")
     {
      //v=FileOpen(StringTrimRight(ExtName_OBJ)+"2//"+getStrNameFile()+".csv",FILE_READ|FILE_CSV,',');
      ResetLastError();
      hand=FileOpen(path,FILE_READ|FILE_CSV,',');
      err=GetLastError();
      _FileSize=FileSize(hand);
      PrintFormat(l(__LINE__)+_FileSize);
      FileClose(hand);
      r=int(_FileSize);
     }
   else if(mode=="Write")
     {
      //v=FileOpen(StringTrimRight(ExtName_OBJ)+"2//"+getStrNameFile()+".csv",FILE_READ|FILE_WRITE|FILE_CSV,',');
      ResetLastError();
      hand=FileOpen(path,FILE_READ|FILE_WRITE|FILE_CSV,',');
      err=GetLastError();
      _FileSize=FileSize(hand);
      r=hand;
     }
   printf(l(__LINE__)+"Mode: "+mode+","+c(FromLine)+" file: \""+fileName+"\"");
   printf(l(__LINE__)+"Hand: ["+c(hand)+","+_File_HandleErr(err)+"] [Retrun:**"+c(r)+"**Z:"+c(_FileSize)+"]");
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _File_HandleErr(int code)
  {
   string v="";
   switch(code)
     {
      case  5002:
         v="Wrong file name";
         break;
      case  5004:
         v="Cannot open file";
         break;
      case  5008:
         v=".csv open now";
         break;
      default:
         break;
     }
   return "["+c(code)+" "+v+"]";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _File_getName()
  {
   string v=Symbol();
   string Symbol_Main=StringSubstr(v,0,3);
   string Symbol_Second=StringSubstr(v,3,3);
   string Symbol_Type=StringSubstr(v,6,1);
//---
   if(!StringFind(v,"GOLD",0) || !StringFind(Symbol(),"XAU",0))
     {
      if(!StringFind(v,"micro",0)==0)
         Symbol_Type="m";
      return "GOLD"+Symbol_Type;
     }

   if(!StringFind(v,"SILVER",0) || !StringFind(v,"XAG",0))
     {
      if(!StringFind(v,"micro",0)==0)
         Symbol_Type="m";
      return "SILVER"+Symbol_Type;
     }

   return StringSubstr(Symbol_Main,0,1)+StringSubstr(Symbol_Second,0,1)+""+Symbol_Type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _File_Read(int LineCall)
  {
//printf(c(__LINE__)+"# ------------------------------------------------ _File_Read");
   ResetLastError();
   int file_handle=_File_Handle(__LINE__,"Write");
   string n;
   int N=0;
   if(file_handle!=INVALID_HANDLE)
     {
      n=FileReadString(file_handle,0);
      n=FileReadString(file_handle,0);
      N=int(n);
      ArrayResize(TroopA,N,0);
      //PrintFormat(c(__LINE__)+"# ==");
      for(int i=0;i<N && N>0;i++)
        {
         TroopA[i]=StringToDouble(FileReadString(file_handle,0));
        }
      n=FileReadString(file_handle,0);
      DeadLine=double(FileReadString(file_handle,0));

      //PrintFormat(c(__LINE__)+"# ==");
      //--- close the file 
      FileClose(file_handle);
      //Management_ZoneB(__LINE__);

      PrintFormat("Data is read ["+c(N)+"]#"+c(LineCall)+", file is closed, Error code = %d",GetLastError());
     }

   else
     {
      PrintFormat("Failed to open file, Error code = %d #"+c(LineCall),GetLastError());
     }
//printf(c(__LINE__)+"# ------------------------------------------------ end_File_Read");
   return N;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _File_Write()
  {
   PrintFormat(c(__LINE__)+"# ------------------------------ _File_Write");
   ResetLastError();
   int file_handle=_File_Handle(__LINE__,"Write");

   if(file_handle!=INVALID_HANDLE)
     {
      int c=ArraySize(TroopA);
      FileWrite(file_handle,"Zone A",c(c));
      if(c>=0)
        {
         for(int i=0;i<c;i++)
           {
            FileWrite(file_handle,TroopA[i]);
           }
        }
      //printf("#"+__LINE__+" _File_Write() : c "+c+" | DeadLine "+DeadLine);

/*if(c==0)
         DeadLine=-1;*/
      FileWrite(file_handle,"DeadLine",+DeadLine);
      FileWrite(file_handle,"# # # # # #");
      //---

      //---
      //--- close the file
      FileClose(file_handle);
      //_File_Read();
      PrintFormat(c(__LINE__)+"# Data is written, file is closed, Error code = %d",GetLastError());
      Management_ZoneB(__LINE__);
     }
   else
     {
      PrintFormat(c(__LINE__)+"# Failed to open file, Error code = %d",GetLastError());
     }
   PrintFormat(c(__LINE__)+"# ------------------------------");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectCreText(string name,int PostX,int PostY)
  {
//name=ExtName_OBJ+name;
   if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
     {
      ObjectSetInteger(ChartID(),name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(ChartID(),name,OBJPROP_SELECTED,false);
      ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,true);
     }
   ObjectSet(name,OBJPROP_XDISTANCE,PostX);
   ObjectSet(name,OBJPROP_YDISTANCE,PostY);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Management_ZoneA_init()
  {
   int Hand=_File_Handle(__LINE__,"Find");

   if(Hand>0)
     {
      printf(l(__LINE__)+" 1");
      Management_ZoneA_Darw(_File_Read(__LINE__));
      Management_ZoneB(__LINE__);

      if(DeadLine>0)
        {
         HLineCreate_(0,ExtName_OBJ+"LINE_DeadLine","",0,DeadLine,clrWhite,2,0,false,false,false,0);
        }
      else
        {
         ObjectDelete(0,ExtName_OBJ+"LINE_DeadLine");
        }

      //Management_ZoneA_info();
      //Management_ZoneB_info();

     }
   else
     {
      //printf("#"+__LINE__+" 2");
      Management_ZoneA_Save(true);
      //Management_ZoneB();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Management_ZoneA_Save(bool Drawline)
  {
   boolZoneA_Show=Drawline;
//---
   Obj_A_cnt=ObjGet_Count("LINE_ZONE_A");
   if(Obj_A_cnt>=0)
     {
      //printf("#"+__LINE__+" 3 : "+Obj_A_cnt);
      //---
      string Owner=getSymbolShortName();
      string DesStr="";
      bool chkOwner=false;
      for(int i=0;i<ObjectsTotal();i++)
        {
         if(StringFind(ObjectName(i),ExtName_OBJ+"LINE_ZONE_A",0)>=0)
           {
            DesStr=ObjectGetString(0,ObjectName(i),OBJPROP_TEXT,0);
            if(DesStr!="" && StringFind(DesStr,Owner,0)>=0)
              {
               chkOwner=true;
               break;
              }
           }
        }
      //---
      if(chkOwner || (!chkOwner && Obj_A_cnt==0))
        {
         printf(l(__LINE__)+" 3-1 : cnt "+c(Obj_A_cnt)+" | Owner "+c(chkOwner));
         //--- Load Obj to Array
         ArrayResize(TroopA,Obj_A_cnt,0);
         for(int i=0,j=0;i<ObjectsTotal();i++)
           {
            string name=ObjectName(i);
            if(StringFind(name,"LINE_ZONE_A",0)>=0)
              {
               TroopA[j]=NormalizeDouble(ObjectGetDouble(0,name,OBJPROP_PRICE),Digits);
               j++;
              }
           }
         //--- ArraySort
         if(ArraySize(TroopA)>0)
            ArraySort(TroopA,WHOLE_ARRAY,0,MODE_ASCEND);

         if(DeadLine<=0 && ArraySize(TroopA)>=2)
           {
            HLineCreate_(0,"LINE_DraftDeadLine","",0,Bid,clrMagenta,1,0,0,true,false,0);
            int PlaceTrade=MessageBox("Draw a horizontal line and press OK.","LINE_DraftDeadLine"+l(__LINE__),MB_OKCANCEL|MB_ICONQUESTION);
            if(PlaceTrade==IDOK)
              {
               double obj_DraftPrice=ObjectGetDouble(0,"LINE_DraftDeadLine",OBJPROP_PRICE);
               DeadLine=NormalizeDouble(obj_DraftPrice,Digits);
               HLineCreate_(0,ExtName_OBJ+"LINE_DeadLine","",0,DeadLine,clrWhite,2,0,false,false,false,0);
               ObjectDelete(0,"LINE_DraftDeadLine");
              }
            if(PlaceTrade==IDCANCEL)
              {
               ObjectDelete(0,"LINE_DraftDeadLine");
              }
           }

         //--- Write to Database
         _File_Write();
         Management_ZoneA_Darw(Obj_A_cnt);

        }
      else
        {
         //printf("#"+__LINE__+" 3-2 : "+Obj_A_cnt);
         ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_A");
         ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_B");
        }
     }

   else
     {
      //printf("#"+__LINE__+" 4");
/*int c=ArraySize(TroopA);
      if(c>0)
        {
         _File_Write();
         Management_ZoneA_Darw(c);
        }*/
     }
   Management_ZoneA_info();
   Management_ZoneB(__LINE__);
   return ArraySize(TroopA);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Management_ZoneA_info()
  {
//--- ShowData After ArraySort
   strCMMResult+="-------\n";
   int TroopA_Size=ArraySize(TroopA);
   strCMMResult+="Zone A : "+c(TroopA_Size-1)+"z | Array "+c(TroopA_Size)+"n\n";
   if(TroopA_Size>0)
      strCMMResult+="------- [Line | Price | Dock | Full | D]\n";

   for(int i=TroopA_Size-1;i>=0;i--)
     {
      strCMMResult+=c(i)+" | "+c(TroopA[i],Digits);
      if(i<TroopA_Size-1)
        {
         double D_Full,D;
         D_Full=MathAbs((TroopA[i+1]-TroopA[i]));
         D=NormalizeDouble(D_Full*Management_ZoneB_getConstant(),Digits);

         strCMMResult+=" | "+c(i+1)+" | "+Comma(D_Full*MathPow(10,Digits),0,",")+"|"+Comma(D*MathPow(10,Digits),0,",")+"p";
         //---Add Cursor
         if(TroopA[i+1]>Ask && TroopA[i]<=Ask)
           {
            Zone_A_Ask=i;

            double D_Ask=MathAbs(TroopA[i]-Ask);
            double Per=D_Ask/D_Full;

            strCMMResult+=" <-- "+c(Per*100,2)+"%";
           }

        }
      strCMMResult+="\n";
     }
//--- Out off Range ZoneA
   if(Zone_A_cnt>=0 && Zone_A_Ask<0 && Zone_A_Ask>Zone_A_cnt)
     {
      if(TroopA[Zone_A_cnt]<Ask)
        {
         strCMMResult+="Upper\n";
        }
      else if(TroopA[0]>Ask)
        {
         strCMMResult+="Lower\n";
        }
     }
   strCMMResult+="-------\n";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Management_ZoneA_Darw(int n)
  {
   ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_A");
   for(int i=0;i<n && boolZoneA_Show;i++)
     {
      string Tooltips=getSymbolShortName()+": ZONE_A"+c(i+1);
      HLineCreate_(0,ExtName_OBJ+"LINE_ZONE_A"+c(i+1),Tooltips,0,TroopA[i],clrZone_A,3,0,false,false,false,0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Management_ZoneB(int __LINE_)
  {
   printf("--------------------------------Management_ZoneB() #"+c(__LINE_));
   int cntFileRead=_File_Read(__LINE__);

   if(cntFileRead>=2)
     {
      Zone_B_cnt=int(1/Management_ZoneB_getConstant());     //4
      ArrayResize(TroopB,cntFileRead-1,0);

      //Print(l(__LINE__)+"D"+Zone_B_cnt+"Read:"+cntFileRead);
      for(int i=0;i<cntFileRead-1;i++)
        {
         double D_Full=(TroopA[i]-TroopA[i+1]);
         double D=NormalizeDouble(D_Full*Management_ZoneB_getConstant(),Digits);
         double P_Mark=TroopA[i];

         for(int j=0;j<=Zone_B_cnt;j++)
           {
            //---
            //Print(l(__LINE__)+i+"|"+j);
            TroopB[i][j]=P_Mark;
            //---
            P_Mark-=D;
            NormalizeDouble(P_Mark,Digits);
           }

        }
      Management_ZoneB_Draw(__LINE__);
        {
         ArrayResize(TroopB_PTP,((cntFileRead-1)*Zone_B_cnt)+1,0);
         int k=0;
         for(int i=0;i<ArraySize(TroopA)-1;i++)
           {
            for(int j=0;j<Zone_B_cnt;j++)
              {
               double v=TroopB[i][j];
               TroopB_PTP[k]=NormalizeDouble(v,Digits);
               k++;
              }
            if(i==ArraySize(TroopA)-2)
              {
               double v=TroopB[i][Zone_B_cnt];
               TroopB_PTP[k]=NormalizeDouble(v,Digits);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Management_ZoneB_Draw(int __LINE)
  {
   if(boolZoneB_Show)
     {

      //printf("Management_ZoneB_Draw #"+c(__LINE));
      //--- DrawLine
      ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_B");
      //printf("#"+__LINE__+" ZoneB_Draw : "+boolZoneB_Show);
      NavagateLine();
      int step=int(_clrLineZoneB/BG_Step);

      for(int i=0;(i<ArraySize(TroopA)-1);i++)
        {
         for(int j=0;j<=Zone_B_cnt;j++)
           {
            if(((j>0) || i==0))
              {
               string Name=ExtName_OBJ+"LINE_ZONE_B"+c(i+1)+"-"+c(j);
               string Tooltips="[B_"+c(i+1)+"-"+c(j)+"] : "+c(TroopB[i][j],Digits);

               long _clrLineB=_clrLineZoneB;
               if((j==0 || j==Zone_B_cnt))
                 {
                  _clrLineB=(C'51,51,0'*step);
                 }
               HLineCreate_(0,Name,Tooltips,0,TroopB[i][j],color(_clrLineB),3,1,true,false,false,0);
              }
           }
        }
        {//---NavegateLine
         if(NowOrder_Cnt>0)
           {
            long clrOrderHigh=C'0,51,0'*step;
            if(clrOrderHigh>=C'255,255,255')
               clrOrderHigh=C'0,255,0';
            HLineCreate_(0,ExtName_OBJ+"LINE_ZONE_B"+"OrderHigh","",0,Now_Array[NowOrder_Cnt-1][0],color(clrOrderHigh),3,1,false,false,false,0);
            HLineCreate_(0,ExtName_OBJ+"LINE_ZONE_B"+"OrderLow","",0,Now_Array[0][0],color(clrOrderHigh),3,1,false,false,false,0);

            long clrNowPrice_WAvg=C'0,0,51'*step;
            if(clrNowPrice_WAvg>=C'255,255,255')
               clrNowPrice_WAvg=C'0,0,255';
            HLineCreate_(0,ExtName_OBJ+"LINE_ZONE_B"+"NowPrice_WAvg","",0,NowPrice_WAvg,color(clrNowPrice_WAvg),3,1,false,false,false,0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Management_ZoneB_info()
  {
   int TroopA_Size=ArraySize(TroopA);

   strCMMResult+="Zone B : "+c(Zone_B_cnt)+"n | Array "+c(ArraySize(TroopB))+"n   ";
   strCMMResult+="clrStep: "+c((_clrLineZoneB/BG_Step))+"\n";

   if(TroopA_Size>=2)
     {
      if(infoFull) strCMMResult+="------- [Line | Price | Dock]\n";
      for(int i=Zone_B_cnt;i>-1 && Zone_A_Ask>=0;i--)
        {
         if(infoFull)strCMMResult+=c(i)+" | "+c(TroopB[Zone_A_Ask][i],Digits);
         if(i<Zone_B_cnt)
           {
            if(infoFull)strCMMResult+=" | "+c(i+1);
            //printf(l(__LINE__)+Zone_A_Ask);
            if(TroopB[Zone_A_Ask][i+1]>Ask && TroopB[Zone_A_Ask][i]<=Ask)
              {
               double D_Full=MathAbs(TroopB[Zone_A_Ask][i+1]-TroopB[Zone_A_Ask][i]);
               double D=MathAbs(TroopB[Zone_A_Ask][i]-Ask);
               double Per=D/D_Full;
                 {
                  if(!infoFull)strCMMResult+=c(TroopB[Zone_A_Ask][i],Digits)+" | Dock: "+c(i+1);
                  strCMMResult+=" <-- "+c(Per*100,2)+"%";
                 }
               Zone_B_Ask=i;
              }
           }
         if(infoFull)strCMMResult+="\n";
        }
      if(!infoFull)strCMMResult+="\n";
      else  strCMMResult+="-------\n";
     }
   else
     {
      strCMMResult+=" ** Out of range **\n";
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Management_DeadLine()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjGet_Count(string Searched)
  {
   int cnt=0;
   for(int i=0;i<ObjectsTotal();i++)

     {
      if(StringFind(ObjectName(i),ExtName_OBJ+Searched,0)>=0)
        {
         cnt++;
        }
     }
   return cnt;
  }

int ObjGet_SELECTABLE_N=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ObjGet_SELECTABLE(string Find)
  {
   ObjGet_SELECTABLE_N=0;
   for(int i=0;i<ObjectsTotal();i++)

     {
      string name=ObjectName(i);
      if(StringFind(name,ExtName_OBJ+Find,0)>=0)
        {
         ObjGet_SELECTABLE_N++;
         if(ObjectGetInteger(0,name,OBJPROP_SELECTABLE))
           {
            //ObjectSetInteger(0,ExtName_OBJ+"BTN_A_Lock",OBJPROP_STATE,0); 
            return true;
           }
        }
     }
//ObjectSetInteger(0,ExtName_OBJ+"BTN_A_Lock",OBJPROP_STATE,1);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjSet_SELECTABLE(string Find,bool Select,string NameBTN,color ClrBTN)
  {
   for(int i=0;i<ObjectsTotal();i++)

     {
      string name=ObjectName(i);
      if(StringFind(name,ExtName_OBJ+Find,0)>=0)
        {
         ObjectSetInteger(0,name,OBJPROP_SELECTABLE,Select);
        }
     }

   ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,ClrBTN);
   ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,ClrBTN);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _File_Search(string path,string FileSearch)
  {
//_File_Search("ZoneTrade2","CJ_ZoneA.csv");

   bool FileSearch_chk=false;
   string InpFilter=path+"\\"+FileSearch;

   string fileNameTemp;
   long search_handle=FileFindFirst(InpFilter,fileNameTemp);
//--- check if the FileFindFirst() is executed successfully
   if(search_handle!=INVALID_HANDLE)
     {
      do
        {
         if(StringFind(fileNameTemp,FileSearch,0)>=0)
            FileSearch_chk=true;
         //printf(l(__LINE__)+fileNameTemp);
        }
      while(FileFindNext(search_handle,fileNameTemp));
      FileFindClose(search_handle);
     }
   else
      Print("Files not found! \""+InpFilter+"\"");

   return FileSearch_chk;
  }
//+------------------------------------------------------------------+
