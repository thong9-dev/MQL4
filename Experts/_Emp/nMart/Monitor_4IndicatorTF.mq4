//+------------------------------------------------------------------+
//|                                                  SwapMonitor.mq4 |
//|                                                   lapukdee @2019 |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property   strict
#property   version  "2.45"
//####################################################################
string aList_ID[]={};
datetime Exp_Set=0;     //D'2019.07.01 23:59'
//+--#################################################################
bool Authentication=false;
string strAuthentication="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sChart
  {
private:
   int               cBar;
   int               cTF;

   int               cANS_1;
   int               cANS_2;

   int               cANS_3;
   int               cANS_3_OT;
   bool              cANS_3_Noti;

   bool              cFrist_1;
   bool              cFrist_2;
   bool              cFrist_3;

public:
   void sChart(int v)
     {
      cTF=v;

      bool Frist=true;

      cFrist_1=Frist;
      cFrist_2=Frist;
      cFrist_3=Frist;

      cANS_3_OT=-2;
      cANS_3_Noti=false;
     }
   bool NewBars()
     {
      int Bar_=iBars(Symbol(),cTF);
      if(cBar!=Bar_)
        {
         cBar=Bar_;
         return true;
        }
      return false;
     };
   bool Ans_1(int trend,int &old)
     {
      bool r=false;

      if(!cFrist_1)
         if(cANS_1!=trend) r=true;

      cFrist_1=false;
      old=cANS_1;
      cANS_1=trend;

      return r;
     }
   bool Ans_2(int trend,int &old)
     {
      bool r=false;

      if(!cFrist_2)
         if(cANS_2!=trend) r=true;

      cFrist_2=false;
      old=cANS_2;
      cANS_2=trend;

      return r;
     }
   bool Ans_3(int trend,int &old)
     {
      bool r=false;

      if(!cFrist_3)
         if(cANS_3!=trend) r=true;

      cFrist_3=false;
      old=cANS_3;
      cANS_3=trend;

      return r;
     }

   int MA_OldTrend(int MA,int OS,int &Ans)
     {

      if(cANS_3_OT==-2)
        {
         cANS_3_OT=MA;
        }

      if(MA==cANS_3_OT)
        {
         if(cANS_3_Noti && (MA==OS))
           {
            Ans=MA;
            return 2;         //Arrow
           }
        }
      else
        {
         cANS_3_Noti=false;
         cANS_3_OT=MA;
        }
      //---
      if(!cANS_3_Noti)
        {
         if(MA==OS)
           {
            Ans=MA;
            cANS_3_Noti=true;
            return 1;         //Line
           }
        }
      return -1;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern bool exMT4=true;    //Notification MT4
extern bool exLine=true;    //Notification Line
extern string extoken="";    //TokenLine
//---
//extern string extoken="ip5RPk5Cso9iLruE1O6dxJ1uLCa3rnIrBqV8oMtfFv5";    //TokenLine
//ip5RPk5Cso9iLruE1O6dxJ1uLCa3rnIrBqV8oMtfFv5   Daren

extern string exSpec="---------------------------------------------------------------------";// # Use---------------------------------------------------------------------
bool exMACross_Use=false;    //MA Cross
bool exMAClose_Use=false;    //MA Close&Slow

                             //extern string exSpec0="---------------------------------------------------------------------";// # ---------------------------------------------------------------------
bool exMA_Use=true;    //MA
extern bool exMACD_Use=true;  //MACD
extern bool exADX_Use=true;   //ADX 
extern bool exRSI_Use=true;   //RSI
extern string exSpec1="---------------------------------------------------------------------";// # DarwArrow---------------------------------------------------------------------
extern bool exDarwArrow=true;   //DarwArrow
extern bool exDarwArrowOscillators=false;   //DarwArrow_Oscillators

extern string exSpec2="---------------------------------------------------------------------";// # MA---------------------------------------------------------------------
extern int exMA_Fast=25;//MA_Fast
extern int exMA_Slow=50;//MA_Slow
extern ENUM_MA_METHOD      exMA_Mode=MODE_EMA;//MA_METHOD
extern ENUM_APPLIED_PRICE  exMA_Mode2=PRICE_CLOSE;//MA_APPLIED

extern string exSpec3="---------------------------------------------------------------------";// # MACD---------------------------------------------------------------------
extern int exMACD_FastEMA=10;//MACD_FastEMA
extern int exMACD_SlowEMA=50;//MACD_SlowEMA
extern int exMACD_SlowSMA=9;//MACD_SlowSMA
extern ENUM_APPLIED_PRICE exMACD_Mode=PRICE_CLOSE;//MACD_Mode

extern string exSpec4="---------------------------------------------------------------------";// # ADX---------------------------------------------------------------------
extern int exADX_Period=14;//MACD_FastEMA
extern ENUM_APPLIED_PRICE exADX_Mode=PRICE_CLOSE;//ADX_Mode
extern double exADX_Set=20;//ADX_Set

extern string exSpec5="---------------------------------------------------------------------";// # RSI---------------------------------------------------------------------
extern int exRSI_Period=25;//RSI_Period
extern ENUM_APPLIED_PRICE exRSI_Mode=PRICE_CLOSE;//RSI_Mode
extern double exRSI_SetUP=55;//RSI_SetUP
extern double exRSI_SetDW=45;//RSI_SetDW

extern string exSpec6=" --------------------------------------------------------------------- ";// ---------------------------------------------------------------------
color clrCFD=clrPlum;        //CFD
color clrForex=clrLightGreen;//Forex
extern bool exEmoji=true;          //EmojiTrend
bool exShowBody=false;       //exShowBody
bool exShowEnd=false;        //exShowEnd

//+------------------------------------------------------------------+
color Chart_BG=clrBlack;//C'31,31,31';//Chart_BG=C'31,31,31';

string ExtName_OBJ="MAMonitor";
bool ExtHide_OBJ=false;

int Size_Wide=70;
int Size_High=13;
int PostX_Default=10,XStep=Size_Wide+2;
int PostY_Default=15,YStep=Size_High-1;

int PostX_DefaultTBL=0;
int PostY_DefaultTBL=0;

int iSymbolsTotal=-1;
sChart iChart_M1(PERIOD_M1);
sChart iChart_M5(PERIOD_M5);
sChart iChart_M15(PERIOD_M15);
sChart iChart_M30(PERIOD_M30);
sChart iChart_H1(PERIOD_H1);
sChart iChart_H4(PERIOD_H4);
sChart iChart_D1(PERIOD_D1);
sChart iChart_W1(PERIOD_W1);
sChart iChart_MN1(PERIOD_MN1);

bool FristRun=true;

string ACC_SERVER=AccountInfoString(ACCOUNT_SERVER);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum sPERIOD_M1
  {
   syPERIOD_M1=PERIOD_M1,  //Yes
   snPERIOD_M1=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_M5
  {
   syPERIOD_M5=PERIOD_M5,  //Yes
   snPERIOD_M5=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_M15
  {
   syPERIOD_M15=PERIOD_M15,//Yes
   snPERIOD_M15=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_M30
  {
   syPERIOD_M30=PERIOD_M30,//Yes
   snPERIOD_M30=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_H1
  {
   syPERIOD_H1=PERIOD_H1,  //Yes
   snPERIOD_H1=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_H4
  {
   syPERIOD_H4=PERIOD_H4,  //Yes
   snPERIOD_H4=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_D1
  {
   syPERIOD_D1=PERIOD_D1,  //Yes
   snPERIOD_D1=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_W1
  {
   syPERIOD_W1=PERIOD_W1,  //Yes
   snPERIOD_W1=-1          //No
  };
//+------------------------------------------------------------------+
enum sPERIOD_MN1
  {
   syPERIOD_MN1=PERIOD_MN1,   //Yes
   snPERIOD_MN1=-1            //No
  };
extern string exSpec7=" --------------------------------------------------------------------- ";// ---------------------------------------------------------------------
extern sPERIOD_M1    Show_M1  =snPERIOD_M1;
extern sPERIOD_M5    Show_M5  =snPERIOD_M5;
extern sPERIOD_M15   Show_M15 =snPERIOD_M15;
extern sPERIOD_M30   Show_M30 =snPERIOD_M30;
extern sPERIOD_H1    Show_H1  =syPERIOD_H1;
extern sPERIOD_H4    Show_H4  =syPERIOD_H4;
extern sPERIOD_D1    Show_D1  =syPERIOD_D1;
extern sPERIOD_W1    Show_W1  =syPERIOD_W1;
extern sPERIOD_MN1   Show_MN1 =snPERIOD_MN1;

int TIME_TF[]={15,30,60,240,1440,10080};
int TIME_TF_Chart[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
bool onInit=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//printf("Date Divas"+Exp_Set+" "+int(Exp_Set));
   LockEA();

   onInit=true;

   setTimeframe();

   ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_EDIT);
//ObjectsDeleteAll(0,ExtName_OBJ+"@Arrow@",0,OBJ_ARROW);
//ObjectsDeleteAll(0,ExtName_OBJ+"@VLine@",0,OBJ_VLINE);

//color clr;
//int ans;
//Chk_MA_Close(Symbol(),PERIOD_D1,clr,ans);

   ArrayResize(TIME_TF_Chart,ArraySize(TIME_TF),0);

//--- create timer
   EventSetMillisecondTimer(1000);

//ChartSetInteger(0,CHART_SHOW_PRICE_SCALE,false);
//ChartSetInteger(0,CHART_SHOW_DATE_SCALE,false);

   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,false);
//ChartSetInteger(0,CHART_DRAG_TRADE_LEVELS,false);
//ChartSetInteger(0,CHART_SHOW_OHLC,false);

   ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrWhite);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,Chart_BG);
//ChartSetInteger(0,CHART_COLOR_GRID,clrNONE);

//ChartSetInteger(0,CHART_COLOR_CHART_UP,clrNONE);
//ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrNONE);

//ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrNONE);

//ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrNONE);
//ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrNONE);

//ChartSetInteger(0,CHART0_1COLOR_VOLUME,clrNONE);
//ChartSetInteger(0,CHART_COLOR_BID,clrNONE);
//ChartSetInteger(0,CHART_COLOR_ASK,clrNONE);
//ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,clrNONE);

//OnTick();
//Main();
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
   Main("Tick");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int XStepTF=80;
int Box_wide=XStepTF-1;

color clrBox=Chart_BG;
string strBox="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main_DrawElement(bool Mode,int PostX,int PostY)
  {
   PostX=PostX_Default;
   PostY=PostY_Default;
//+------------------------------------------------------------------+
//---
//setLabel(ExtName_OBJ+"@Head@0@0",TICK()+" #Symbol : "+string(iSymbolsTotal)+" "+string(FristRun),"",clrGold,PostX,PostY);
   PostX+=int(XStepTF*3);
//ObjectSetInteger(0,ExtName_OBJ+"@Head@0@0",OBJPROP_FONTSIZE,12);

   for(int i=0;i<ArraySize(TIME_TF);i++)
     {
      int TF_=TIME_TF[i];
      if(TIME_TF[i]>=0)
        {
         setEditCreate(ExtName_OBJ+"@Head@2@"+strTF(TF_),0,strTF(TF_)
                       ,true,false,PostX,PostY,Box_wide,15,
                       "Arial",9,ALIGN_CENTER,CORNER_LEFT_UPPER
                       ,clrGold,Chart_BG,Chart_BG,false,false,false,0);    PostX+=int(XStepTF);
        }
     }

   PostX=PostX_Default;
   PostY+=YStep+5;

   PostX_DefaultTBL=PostX;
   PostY_DefaultTBL=PostY;

   int H=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
//   
   int Column=PostX_Default;
   int ColumnV=0;

   int digits=StringLen(string(iSymbolsTotal));
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//if(iChart_15.NewBars() || FristRun)
     {

      //for(int i=0;i<iSymbolsTotal;i++)
        {

         //string iSymbolName=SymbolName(i,true);
         string iSymbolName=Symbol();

         //---

         //---

         //if(MarketInfo(iSymbolName,MODE_TRADEALLOWED)==1)
           {
            //--------------------
            long SWAP_MODE=SymbolInfoInteger(iSymbolName,SYMBOL_SWAP_MODE);
            color clrSymbolName=(SWAP_MODE==0)?clrForex:clrCFD;
/*
            setLabel(ExtName_OBJ+"@"+"Symbol"+"@0@0",
                     CommaZero(0+1,digits," ")+" "+iSymbolName_Shor(iSymbolName,SWAP_MODE),
                     "",clrSymbolName,PostX,PostY);
*/
            setEditCreate("H"+ExtName_OBJ+"@"+"Symbol"+"@0@0",0
                          ,TICK()+" "+iSymbolName
                          ,true,false,
                          PostX,PostY,int(Box_wide),15,
                          "Arial",9,ALIGN_LEFT,CORNER_LEFT_UPPER
                          ,clrGold,Chart_BG,clrDimGray,false,false,false,0);

            PostX+=int(XStepTF);
            //--------------------
            BOX("MA",iSymbolName,PostX,PostY);
            //---
            PostX=Column;
            PostY+=YStep+7;

            //
/*
            setLabel(ExtName_OBJ+"@"+"Head"+"@1@1",
                     string(chk_data(iSymbolName)),
                     "",clrSymbolName,PostX,PostY);
*/
            bool chkData=chk_data(iSymbolName);

            setEditCreate(ExtName_OBJ+"@"+"Head"+"@Data@1",0
                          ,"Data : "+string(chkData)
                          ,true,false,
                          PostX,PostY,int(Box_wide),15,
                          "Arial",9,ALIGN_LEFT,CORNER_LEFT_UPPER
                          ,clrGold,Chart_BG,clrDimGray,false,false,false,0);

            //

            PostX+=int(XStepTF);
            BOX("MACD",iSymbolName,PostX,PostY);
            //---
            PostY+=YStep+7;
            PostX=Column;

            setEditCreate(ExtName_OBJ+"@"+"Head"+"@TestToken@1",0
                          ,"Line Token"
                          ,true,false,
                          PostX,PostY,int(Box_wide),15,
                          "Arial",9,ALIGN_LEFT,CORNER_LEFT_UPPER
                          ,clrGold,Chart_BG,clrDimGray,false,false,false,0);
            PostX=Column+int(XStepTF);

            BOX("ADX",iSymbolName,PostX,PostY);
            //---
            PostY+=YStep+7;
            PostX=Column;

            setEditCreate(ExtName_OBJ+"@"+"Head"+"@ObjClear@1",0
                          ,"ObjClear"
                          ,true,false,
                          PostX,PostY,int(Box_wide),15,
                          "Arial",9,ALIGN_LEFT,CORNER_LEFT_UPPER
                          ,clrGold,Chart_BG,clrDimGray,false,false,false,0);
            PostX=Column+int(XStepTF);

            BOX("RSI",iSymbolName,PostX,PostY);
           }
/*
      if(PostY>(H-Size_High*2))
        {
         PostY=PostY_Default-Size_High;
         Column+=540;

         ChartXYToTimePrice(0,Column-15,PostY,window,dt,price);
         VLineCreate(0,ExtName_OBJ+"@V@0@"+string(ColumnV),0,dt,C'75,75,75',0,5,true,false,false,ExtHide_OBJ,0);
         ColumnV++;
         ChartXYToTimePrice(0,Column+int(XStep*1.75)-1,PostY,window,dt,price);
         VLineCreate(0,ExtName_OBJ+"@V@0@"+string(ColumnV),0,dt,C'75,75,75',2,1,true,false,false,ExtHide_OBJ,0);
         ColumnV++;
         ChartXYToTimePrice(0,Column+int(XStep*4.5)-1,PostY,window,dt,price);
         VLineCreate(0,ExtName_OBJ+"@V@0@"+string(ColumnV),0,dt,C'75,75,75',2,1,true,false,false,ExtHide_OBJ,0);
         ColumnV++;
        }
*/
         PostX=Column;
         PostY+=YStep+7;

         FristRun=false;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool chk_data(string sym)
  {
   bool chk=true;
   for(int i=0;i<ArraySize(TIME_TF);i++)
     {
      int TF_=TIME_TF[i];
      double iMA_Fast=iMA(sym,TF_,exMA_Fast,0,exMA_Mode,exMA_Mode2,0);
      double iMA_Slow=iMA(sym,TF_,exMA_Slow,0,exMA_Mode,exMA_Mode2,0);

      if(iMA_Fast==0 && iMA_Slow==0)
        {

         //bool  ChartClose(chart_id);

         chk=false;
         break;
        }
     }

   if(!chk && FristRun)
     {
      chk_data_Load(sym);
     }

   if(chk)
     {

     }

   return chk;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void chk_data_Load(string sym)
  {
   ArrayResize(TIME_TF_Chart,ArraySize(TIME_TF),0);

   for(int i=0;i<ArraySize(TIME_TF);i++)
     {
      int TF_=TIME_TF[i];
      TIME_TF_Chart[i]=int(ChartOpen(sym,TF_));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BOX(string MODE,string iSymbolName,int PostX,int PostY)
  {
   int ans;

   color clrHead=clrRed;

   string str=MODE;
   if(MODE=="MA")
     {
      str+="("+string(exMA_Fast)+","+string(exMA_Slow)+")";
      if(exMA_Use) clrHead=clrGold;
     }
   else if(MODE=="MACD")
     {
      str+="("+string(exMACD_FastEMA)+","+string(exMACD_SlowEMA)+","+string(exMACD_SlowSMA)+")";
      if(exMACD_Use) clrHead=clrGold;
     }
   else if(MODE=="ADX")
     {
      str+="("+string(exADX_Period)+","+string(exADX_Set)+"*)";
      if(exADX_Use) clrHead=clrGold;
     }
   else if(MODE=="RSI")
     {
      str+="("+string(exRSI_Period)+","+string(exRSI_SetUP)+"*,"+string(exRSI_SetDW)+"*)";
      if(exRSI_Use) clrHead=clrGold;
     }
//----
   setEditCreate(ExtName_OBJ+"@"+iSymbolName+"@BOX@"+MODE,0,str+"  |  "
                 ,true,false,
                 PostX,PostY,int(Box_wide*2),15,
                 "Arial",9,ALIGN_RIGHT,CORNER_LEFT_UPPER
                 ,clrHead,Chart_BG,Chart_BG,false,false,false,0);
   PostX+=int(XStepTF*2);

     {
      for(int i=0;i<ArraySize(TIME_TF);i++)
        {
         int TF_=TIME_TF[i];
         if(TIME_TF[i]>=0)
           {
            if(MODE=="MA")
               strBox=Chk_MA(iSymbolName,TF_,0,clrBox,ans);
            else if(MODE=="MACD")
               strBox=Chk_MACD(iSymbolName,TF_,0,clrBox,ans);
            else if(MODE=="ADX")
               strBox=Chk_ADX(iSymbolName,TF_,0,clrBox,ans);
            else if(MODE=="RSI")
               strBox=Chk_RSI(iSymbolName,TF_,0,clrBox,ans);

            setEditCreate(ExtName_OBJ+"@"+iSymbolName+"@BOX@"+MODE+"@"+strTF(TF_),0,strBox
                          ,true,false,
                          PostX,PostY,Box_wide,15,
                          "Arial",9,ALIGN_RIGHT,CORNER_LEFT_UPPER
                          ,clrWhite,clrBox,clrBox,false,false,false,0);
            PostX+=XStepTF;
           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Chk_MA_Cross(string sym,int tf,int bar,color &clr,int &ans,double &ScenePrice)
  {

//sym=Symbol();
   string barcode="",Barcode="";

   int    vdigits=(int)MarketInfo(sym,MODE_DIGITS);

   int  SceneStart=bar;
//ScenePrice=NormalizeDouble(iMA(sym,tf,exMA_Slow,0,exMA_Mode,exMA_Mode2,SceneStart),vdigits);

   for(int i=0,b=SceneStart;i<3;i++,b++)
     {
      double iMA_Fast=iMA(sym,tf,exMA_Fast,0,exMA_Mode,exMA_Mode2,b);
      double iMA_Slow=iMA(sym,tf,exMA_Slow,0,exMA_Mode,exMA_Mode2,b);

      if(iMA_Fast>iMA_Slow)
         barcode+="0";
      if(iMA_Fast<iMA_Slow)
         barcode+="1";
      if(iMA_Fast==iMA_Slow)
         barcode+="2";
     }

   for(int i=StringLen(barcode)-1;i>=0;i--)
      Barcode+=StringSubstr(barcode,i,1);

//---
   string r="None";
   clr=clrGray;
   ans=-1;

   if(Barcode=="001" || Barcode=="021")
     {
      clr=clrSalmon;
      ans=OP_SELL;
      r="Cross Down";

      ScenePrice=Chk_MA_Cross_ScenePrice(ans);
     }
   if(Barcode=="110" || Barcode=="120")
     {
      clr=clrCornflowerBlue;
      ans=OP_BUY;
      r="Cross Up";

      ScenePrice=Chk_MA_Cross_ScenePrice(ans);
     }

/*
   if(ans==-1)
     {
      ans=StrToInteger(Barcode);
     }
*/

//printf(strTF(tf)+"# "+barcode+" | "+Barcode+" = "+ans);

   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Chk_MA_Cross_ScenePrice(int OP_DIR)
  {
   double sar=iSAR(Symbol(),PERIOD_CURRENT,0.02,0.2,1);
   double h=iHigh(Symbol(),PERIOD_CURRENT,1);
   double l=iLow(Symbol(),PERIOD_CURRENT,1);

   double r=-1;

   if(h<sar)
     {
      r=sar-h;
     }
   if(h>sar)
     {
      r=l-sar;
     }

   if(OP_DIR==OP_BUY)
     {
      r=l-r;
     }
   if(OP_DIR==OP_SELL)
     {
      r=h+r;
     }
   return NormalizeDouble(r,Digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Chk_MA_Close(string sym,int tf,color &clr,int &ans,double &ScenePrice)
  {

//sym=Symbol();
   string barcode="",Barcode="";

   int    vdigits=(int)MarketInfo(sym,MODE_DIGITS);

   int  SceneStart=1;
//ScenePrice=NormalizeDouble(iMA(sym,tf,exMA_Slow,0,exMA_Mode,exMA_Mode2,SceneStart),vdigits);

   for(int i=0,b=SceneStart;i<3;i++,b++)
     {
      double iMA_Fast=iMA(sym,tf,1,0,MODE_SMA,PRICE_CLOSE,b);
      double iMA_Slow=iMA(sym,tf,exMA_Slow,0,exMA_Mode,exMA_Mode2,b);

      if(iMA_Fast>iMA_Slow)
         barcode+="0";
      if(iMA_Fast<iMA_Slow)
         barcode+="1";
      if(iMA_Fast==iMA_Slow)
         barcode+="2";
     }

   for(int i=StringLen(barcode)-1;i>=0;i--)
      Barcode+=StringSubstr(barcode,i,1);

//---
   string r="None";
   clr=clrGray;
   ans=-1;


   if(Barcode=="001" || Barcode=="021")
     {
      clr=clrSalmon;
      ans=OP_SELL;
      r="Cross Down";

      ScenePrice=Chk_MA_Cross_ScenePrice(ans);
     }
   if(Barcode=="110" || Barcode=="120")
     {
      clr=clrCornflowerBlue;
      ans=OP_BUY;
      r="Cross Up";

      ScenePrice=Chk_MA_Cross_ScenePrice(ans);
     }

/*
   if(ans==-1)
     {
      ans=StrToInteger(Barcode);
     }
*/

//printf(barcode+" | "+Barcode+" = "+ans);

   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Chk_MA(string sym,int tf,int bar,color &clr,int &ans)
  {

//sym=Symbol();

   int    vdigits=(int)MarketInfo(sym,MODE_DIGITS);

   double iMA_Fast=iMA(sym,tf,exMA_Fast,0,exMA_Mode,exMA_Mode2,bar);
   double iMA_Slow=iMA(sym,tf,exMA_Slow,0,exMA_Mode,exMA_Mode2,bar);

   if(iMA_Fast==0 && iMA_Slow==0)
     {
      clr=clrGray;
      return sym+" | "+strTF(tf);
     }

   double r=iMA_Fast-iMA_Slow;
   ans=-1;

   if(r>0)
     {
      clr=clrCornflowerBlue;
      ans=OP_BUY;
     }
   if(r<0)
     {
      clr=clrSalmon;
      ans=OP_SELL;
     }
   return DoubleToStr(r,vdigits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Chk_MACD(string sym,int tf,int bar,color &clr,int &ans)
  {
   int    vdigits=(int)MarketInfo(sym,MODE_DIGITS);

   double iMACD_MAAIN=iMACD(sym,tf,exMACD_FastEMA,exMACD_SlowEMA,exMACD_SlowSMA,exMACD_Mode,MODE_MAIN,bar);
   double iMACD_SIGNA=iMACD(sym,tf,exMACD_FastEMA,exMACD_SlowEMA,exMACD_SlowSMA,exMACD_Mode,MODE_SIGNAL,bar);

   ans=-1;
   if(iMACD_MAAIN>0)
     {
      clr=clrCornflowerBlue;
      ans=OP_BUY;
     }
   if(iMACD_MAAIN<0)
     {
      clr=clrSalmon;
      ans=OP_SELL;
     }
   return DoubleToStr(iMACD_MAAIN,vdigits+1)/*+"|"+DoubleToStr(iMACD_SIGNA,vdigits+1)*/;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Chk_ADX(string sym,int tf,int bar,color &clr,int &ans)
  {
//int    vdigits=(int)MarketInfo(sym,MODE_DIGITS);

   double iADX_MAIN=iADX(sym,tf,exADX_Period,exADX_Mode,MODE_MAIN,bar);
   double iADX_PLUS=iADX(sym,tf,exADX_Period,exADX_Mode,MODE_PLUSDI,bar);
   double iADX_MINU=iADX(sym,tf,exADX_Period,exADX_Mode,MODE_MINUSDI,bar);

   double r=0;
   clr=clrGray;
   ans=-1;

   if(iADX_MAIN>exADX_Set)
     {
      if(iADX_PLUS>exADX_Set && iADX_MINU>exADX_Set)
        {
         if(iADX_PLUS>iADX_MINU)
           {
            clr=clrCornflowerBlue;
            r=iADX_PLUS;
            ans=OP_BUY;
           }
         if(iADX_PLUS<iADX_MINU)
           {
            clr=clrSalmon;
            r=iADX_MINU;
            ans=OP_SELL;
           }
        }
      else
        {
         if(iADX_PLUS>exADX_Set)
           {
            clr=clrCornflowerBlue;
            r=iADX_PLUS;
            ans=OP_BUY;
           }
         if(iADX_MINU>exADX_Set)
           {
            clr=clrSalmon;
            r=iADX_MINU;
            ans=OP_SELL;
           }
        }
     }

//---

   return DoubleToStr(r,4);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Chk_RSI(string sym,int tf,int bar,color &clr,int &ans)
  {
//int    vdigits=(int)MarketInfo(sym,MODE_DIGITS);

   double iRSI_MAAIN=iRSI(sym,tf,exRSI_Period,exRSI_Mode,bar);

   clr=clrGray;
   ans=-1;
   if(iRSI_MAAIN>exRSI_SetUP)
     {
      clr=clrCornflowerBlue;
      ans=OP_BUY;
     }
   if(iRSI_MAAIN<exRSI_SetDW)
     {
      clr=clrSalmon;
      ans=OP_SELL;
     }

   return DoubleToStr(iRSI_MAAIN,4);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
int Resolution(int v1,int v2,int v3,int v4)
  {
   int r=-1;

   if(v1==v2 && v1==v3 && v1==v4)
      r=v1;

   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Resolution2(int v1,int v2)
  {
   if(v1==-3)
     {
      return -1;
     }
   if(v1==-2)
     {
      return v2;
     }
//---
   if(v1==v2)
     {
      return v1;
     }
   else
     {
      return -3;
     }

   return -5;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShowBox=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//Main("Timer");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Main(string where)
  {
//---
//string CMM=ChartGetString(0,CHART_COMMENT);
   if(Authentication)
     {
      LineNotifyHub(where);

      if(ShowBox)
        {
         Main_DrawElement(false,PostX_DefaultTBL,PostY_DefaultTBL);
        }
     }
   else
     {
      ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_EDIT);
      Comment(strAuthentication);
     }

//---

//---
/*
//string CMM="\n\n\n\n\n\n\n\n";
   for(int i=0;i<ArraySize(TIME_TF);i++)
     {
      long ttf=TIME_TF_Chart[i];
      //CMM+=string(ttf)+"\n";

      if(ttf>0)
        {
         ChartClose(ttf);
        }

     }
     */
//Comment(CMM);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LineNotifyHub_0(string where)
  {

   bool boolLineNotify=false;

   string msgLine_HeadeMode1="";
   string msgLine_HeadeMode2="";
   string msgLine_HeadeMode3="";

//string msgLine_BodyMode1="";
//string msgLine_BodyMode2="";
   string msgLine_BodyMode3="";

   int ans_MA_Cross,ans_MA_Close;
   int ans_MA,ans_MACD,ans_RSI,ans_ADX;

   string vans_MA_Cross,vans_MA_Close;
   string vans_MA,vans_MACD,vans_RSI,vans_ADX;

   for(int i=0;i<ArraySize(TIME_TF);i++)
     {
      if(TIME_TF[i]>=0)
        {
         int ans_1=-2,ans2_1;
         int ans_2=-1,ans2_2;
         int ans_3=-2,ans2_3;

         if(HubNewBar(TIME_TF[i]) || onInit==true)
           {
            //Main_CompareSymbol(eCALL_Normal);
            if(exMACross_Use)
              {
               double ScenePrice;
               vans_MA_Cross=Chk_MA_Cross(Symbol(),TIME_TF[i],1,clrBox,ans_MA_Cross,ScenePrice);

               bool v=HubAns_1(TIME_TF[i],ans_MA_Cross,ans2_1);
               //---
               if(ans_MA_Cross==-1) v=false;
               //---
               if(v)
                 {
                  //---
                  if(exDarwArrow)
                     MarkArrow(i,ans_MA_Cross,"Cross",ScenePrice);
                  //---
                  boolLineNotify=v;
                  //msgLine_HeadeMode1+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_MA_Cross);
                  msgLine_HeadeMode1+="\n@"+strTF(TIME_TF[i])+"| "+strTrend(ans2_1)+" --> "+strTrend(ans_MA_Cross);

                 }
              }
            //---

            if(exMAClose_Use)
              {
               double ScenePrice;
               vans_MA_Close=Chk_MA_Close(Symbol(),TIME_TF[i],clrBox,ans_MA_Close,ScenePrice);

               bool v=HubAns_2(TIME_TF[i],ans_MA_Close,ans2_2);
               //---
               if(ans_MA_Close==-1) v=false;
               //---
               if(v)
                 {
                  //---
                  if(exDarwArrow)
                     MarkArrow(i,ans_MA_Close,"Close",ScenePrice);
                  //---
                  boolLineNotify=v;
                  //msgLine_HeadeMode2+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_MA_Close);
                  msgLine_HeadeMode2+="\n@"+strTF(TIME_TF[i])+"| "+strTrend(ans2_2)+" --> "+strTrend(ans_MA_Close);

                 }
              }
            //---
            if(exMA_Use || exMACD_Use || exADX_Use || exRSI_Use)
              {
               if(exMA_Use)
                 {
                  ans_MA=-1;
                  double ScenePrice;
                  vans_MA=Chk_MA_Cross(Symbol(),TIME_TF[i],1,clrBox,ans_MA,ScenePrice);

                  if(ans_MA==-1)
                    {
                     vans_MA=Chk_MA(Symbol(),TIME_TF[i],1,clrBox,ans_MA);
                    }

                  ans_3=Resolution2(ans_3,ans_MA);
                 }
               if(exMACD_Use)
                 {
                  vans_MACD=Chk_MACD(Symbol(),TIME_TF[i],1,clrBox,ans_MACD);
                  ans_3=Resolution2(ans_3,ans_MACD);
                 }

               if(exADX_Use)
                 {
                  vans_RSI=Chk_ADX(Symbol(),TIME_TF[i],1,clrBox,ans_ADX);
                  ans_3=Resolution2(ans_3,ans_ADX);
                 }

               if(exRSI_Use)
                 {
                  vans_ADX=Chk_RSI(Symbol(),TIME_TF[i],1,clrBox,ans_RSI);
                  ans_3=Resolution2(ans_3,ans_RSI);
                 }

               ans_3=Resolution2(ans_3,ans_3);

               bool v=HubAns_3(TIME_TF[i],ans_3,ans2_3);
               //---
               if(ans_3==-1) v=false;
               //---
               if(v)
                 {
                  if(exDarwArrow)
                     MarkVLine(i,where,ans_3);

                  boolLineNotify=v;
                  //---
                  //msgLine_HeadeMode3+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_3);
                  msgLine_HeadeMode3+="\n@"+strTF(TIME_TF[i])+"| "+strTrend(ans2_3)+" --> "+strTrend(ans_3);

                  msgLine_BodyMode3+="\n@"+strTF(TIME_TF[i])+"| "+strTrend(ans2_3)+" --> "+strTrend(ans_3);
                  if(exMA_Use)      msgLine_BodyMode3+="\n MA | "+vans_MA;
                  if(exMACD_Use)    msgLine_BodyMode3+="\n MACD | "+vans_MACD;
                  if(exADX_Use)     msgLine_BodyMode3+="\n ADX | "+vans_RSI;
                  if(exRSI_Use)     msgLine_BodyMode3+="\n RSI | "+vans_ADX;
                  msgLine_BodyMode3+="\n --- ";

                 }

              }
           }
        }
     }

//---
   if(boolLineNotify)
     {
      string Head="#"+Symbol();
      string End="\n#Set";
      if(exMACross_Use) End+="\n 2MA-Cross";
      if(exMAClose_Use) End+="\n MA-"+string(exMACD_SlowEMA);
      if(exMA_Use)      End+="\n MA ("+string(exMA_Fast)+","+string(exMA_Slow)+")";
      if(exMACD_Use)    End+="\n MACD ("+string(exMACD_FastEMA)+","+string(exMACD_SlowEMA)+","+string(exMACD_SlowSMA)+")";
      if(exADX_Use)     End+="\n ADX ("+string(exADX_Period)+","+string(exADX_Set)+"*)";
      if(exRSI_Use)     End+="\n RSI ("+string(exRSI_Period)+","+string(exRSI_SetUP)+"*,"+string(exRSI_SetDW)+"*)";
      End+="\n ================== ";

      if(msgLine_HeadeMode1!="")
         msgLine_HeadeMode1="\n#2MA-Cross"+msgLine_HeadeMode1+"\n ===============";
      if(msgLine_HeadeMode2!="")
         msgLine_HeadeMode2="\n#MA-"+string(exMACD_SlowEMA)+msgLine_HeadeMode2+"\n ===============";
      if(msgLine_HeadeMode3!="")
         msgLine_HeadeMode3="\n#4-Indicator"+msgLine_HeadeMode3+"\n ===============";
      if(msgLine_BodyMode3!="")
         msgLine_BodyMode3=msgLine_BodyMode3+"\n ===============";

      string ALL=Head;
      ALL+=msgLine_HeadeMode1;
      ALL+=msgLine_HeadeMode2;
      ALL+=msgLine_HeadeMode3;

      string ALL_MT4=ALL;
      StringReplace(ALL_MT4,"-->","");
      StringReplace(ALL_MT4,"Up","UP");
      StringReplace(ALL_MT4,"Down","DW");
      StringReplace(ALL_MT4,"None","-");

      if(exShowBody) ALL+=msgLine_BodyMode3;
      if(exShowEnd)  ALL+=End;

      if(exEmoji)
        {
         StringReplace(ALL,"#","⭕️");
         StringReplace(ALL,"Up","💚");
         StringReplace(ALL,"Down","❤️");
         StringReplace(ALL,"None","🖤");
        }

      //---

      if(exLine)
         LineNotify(ALL);
      if(exMT4)
         SendNotification(ALL_MT4);

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LineNotifyHub(string where)
  {

   bool boolLineNotify=false;

   string msgLine_HeadeMode1="";
   string msgLine_HeadeMode2="";
   string msgLine_HeadeMode3="";

//string msgLine_BodyMode1="";
//string msgLine_BodyMode2="";
   string msgLine_BodyMode3="";

   int ans_MA_Cross,ans_MA_Close;
   int ans_MACD,ans_RSI,ans_ADX;

   string vans_MA_Cross,vans_MA_Close;
   string vans_MA,vans_MACD,vans_RSI,vans_ADX;

   for(int i=0;i<ArraySize(TIME_TF);i++)
     {
      if(TIME_TF[i]>=0)
        {
         int ans_1=-2,ans2_1;
         int ans_2=-1,ans2_2;

         if(HubNewBar(TIME_TF[i]) || onInit==true)
           {
            //Main_CompareSymbol(eCALL_Normal);
            if(exMACross_Use)
              {
               double ScenePrice;
               vans_MA_Cross=Chk_MA_Cross(Symbol(),TIME_TF[i],1,clrBox,ans_MA_Cross,ScenePrice);

               bool v=HubAns_1(TIME_TF[i],ans_MA_Cross,ans2_1);
               //---
               if(ans_MA_Cross==-1) v=false;
               //---
               if(v)
                 {
                  //---
                  if(exDarwArrow)
                     MarkArrow(i,ans_MA_Cross,where+"Cross",ScenePrice);
                  //---
                  boolLineNotify=v;
                  //msgLine_HeadeMode1+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_MA_Cross);
                  msgLine_HeadeMode1+="\n@"+strTF(TIME_TF[i])+"| "+strTrend(ans2_1)+" --> "+strTrend(ans_MA_Cross);

                 }
              }
            //---

            if(exMAClose_Use)
              {
               double ScenePrice;
               vans_MA_Close=Chk_MA_Close(Symbol(),TIME_TF[i],clrBox,ans_MA_Close,ScenePrice);

               bool v=HubAns_2(TIME_TF[i],ans_MA_Close,ans2_2);
               //---
               if(ans_MA_Close==-1) v=false;
               //---
               if(v)
                 {
                  //---
                  if(exDarwArrow)
                     MarkArrow(i,ans_MA_Close,where+"Close",ScenePrice);
                  //---
                  boolLineNotify=v;
                  //msgLine_HeadeMode2+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_MA_Close);
                  msgLine_HeadeMode2+="\n@"+strTF(TIME_TF[i])+"| "+strTrend(ans2_2)+" --> "+strTrend(ans_MA_Close);

                 }
              }
            //---
            int ans_3=-2;

            int Ans_Ma=-2;
            int Ans_Oscillators=-2;
            //
            if(exMA_Use || exMACD_Use || exADX_Use || exRSI_Use)
              {
               if(exMA_Use)
                 {
                  vans_MA=Chk_MA(Symbol(),TIME_TF[i],1,clrBox,Ans_Ma);
                 }
               //---
               if(exMACD_Use)
                 {
                  vans_MACD=Chk_MACD(Symbol(),TIME_TF[i],1,clrBox,ans_MACD);
                  Ans_Oscillators=Resolution2(Ans_Oscillators,ans_MACD);
                 }

               if(exADX_Use)
                 {
                  vans_RSI=Chk_ADX(Symbol(),TIME_TF[i],1,clrBox,ans_ADX);
                  Ans_Oscillators=Resolution2(Ans_Oscillators,ans_ADX);
                 }

               if(exRSI_Use)
                 {
                  vans_ADX=Chk_RSI(Symbol(),TIME_TF[i],1,clrBox,ans_RSI);
                  Ans_Oscillators=Resolution2(Ans_Oscillators,ans_RSI);
                 }

               Ans_Oscillators=Resolution2(Ans_Oscillators,Ans_Oscillators);
               //---

               //MA_OldTrend(Ans_Ma,Ans_Oscillators)

               int Noti=HubAns_3_2(TIME_TF[i],Ans_Ma,Ans_Oscillators,ans_3);
               //---
               if(ans_3==-1) Noti=false;
               //---
               if(Noti==1)//Line
                 {
                  if(exDarwArrow)
                     MarkVLine(i,where,ans_3);

                  boolLineNotify=true;
                  //---
                  //msgLine_HeadeMode3+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_3);
                  msgLine_HeadeMode3+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_3);

                  msgLine_BodyMode3+="\n@"+strTF(TIME_TF[i])+" --> "+strTrend(ans_3);
                  if(exMA_Use)      msgLine_BodyMode3+="\n MA | "+vans_MA;
                  if(exMACD_Use)    msgLine_BodyMode3+="\n MACD | "+vans_MACD;
                  if(exADX_Use)     msgLine_BodyMode3+="\n ADX | "+vans_RSI;
                  if(exRSI_Use)     msgLine_BodyMode3+="\n RSI | "+vans_ADX;
                  msgLine_BodyMode3+="\n --- ";

                 }
               if(Noti==2)//Arrow
                 {
                  if(exDarwArrowOscillators)
                     MarkArrow(i,ans_3,where+"Cross",Chk_MA_Cross_ScenePrice(ans_3));
                 }

              }
           }
        }
     }

//---
   if(boolLineNotify)
     {
      //string Head="#"+Symbol();
      string Head="💎 "+Symbol()+"."+string(AccountInfoInteger(ACCOUNT_LOGIN));

      string End="\n#Set";
      if(exMACross_Use) End+="\n 2MA-Cross";
      if(exMAClose_Use) End+="\n MA-"+string(exMACD_SlowEMA);
      if(exMA_Use)      End+="\n MA ("+string(exMA_Fast)+","+string(exMA_Slow)+")";
      if(exMACD_Use)    End+="\n MACD ("+string(exMACD_FastEMA)+","+string(exMACD_SlowEMA)+","+string(exMACD_SlowSMA)+")";
      if(exADX_Use)     End+="\n ADX ("+string(exADX_Period)+","+string(exADX_Set)+"*)";
      if(exRSI_Use)     End+="\n RSI ("+string(exRSI_Period)+","+string(exRSI_SetUP)+"*,"+string(exRSI_SetDW)+"*)";
      End+="\n ================== ";

      if(msgLine_HeadeMode1!="")
         msgLine_HeadeMode1="\n#2MA-Cross"+msgLine_HeadeMode1+"\n ===============";
      if(msgLine_HeadeMode2!="")
         msgLine_HeadeMode2="\n#MA-"+string(exMACD_SlowEMA)+msgLine_HeadeMode2+"\n ===============";
      if(msgLine_HeadeMode3!="")
         msgLine_HeadeMode3="\n#4-Indicator"+msgLine_HeadeMode3+"\n ===============";
      if(msgLine_BodyMode3!="")
         msgLine_BodyMode3=msgLine_BodyMode3+"\n ===============";

      string ALL=Head;
      ALL+=msgLine_HeadeMode1;
      ALL+=msgLine_HeadeMode2;
      ALL+=msgLine_HeadeMode3;

      string ALL_MT4=ALL;
      StringReplace(ALL_MT4,"-->","");
      StringReplace(ALL_MT4,"Up","UP");
      StringReplace(ALL_MT4,"Down","DW");
      StringReplace(ALL_MT4,"None","-");

      if(exShowBody) ALL+=msgLine_BodyMode3;
      if(exShowEnd)  ALL+=End;

      if(exEmoji)
        {
         StringReplace(ALL,"#","⭕️");
         StringReplace(ALL,"Up","💚");
         StringReplace(ALL,"Down","❤️");
         StringReplace(ALL,"None","🖤");
        }

      //---

      if(exLine)
         LineNotify(ALL);
      if(exMT4)
         SendNotification(ALL_MT4);

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HubNewBar(int statement)
  {
   switch(statement)
     {
      case  PERIOD_M1: return iChart_M1.NewBars();
      case  PERIOD_M5: return iChart_M5.NewBars();
      case  PERIOD_M15: return iChart_M15.NewBars();
      case  PERIOD_M30: return iChart_M30.NewBars();
      case  PERIOD_H1:  return iChart_H1.NewBars();
      case  PERIOD_H4:  return iChart_H4.NewBars();
      case  PERIOD_D1:  return iChart_D1.NewBars();
      case  PERIOD_W1:  return iChart_W1.NewBars();
      case  PERIOD_MN1: return iChart_MN1.NewBars();
      default: return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HubAns_1(int statement,int trend,int &old)
  {
   switch(statement)
     {
      case  PERIOD_M1: return iChart_M1.Ans_1(trend,old);
      case  PERIOD_M5: return iChart_M5.Ans_1(trend,old);
      case  PERIOD_M15: return iChart_M15.Ans_1(trend,old);
      case  PERIOD_M30: return iChart_M30.Ans_1(trend,old);
      case  PERIOD_H1:  return iChart_H1.Ans_1(trend,old);
      case  PERIOD_H4:  return iChart_H4.Ans_1(trend,old);
      case  PERIOD_D1:  return iChart_D1.Ans_1(trend,old);
      case  PERIOD_W1:  return iChart_W1.Ans_1(trend,old);
      case  PERIOD_MN1:  return iChart_MN1.Ans_1(trend,old);
      default: return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HubAns_2(int statement,int trend,int &old)
  {
   switch(statement)
     {
      case  PERIOD_M1: return iChart_M1.Ans_2(trend,old);
      case  PERIOD_M5: return iChart_M5.Ans_2(trend,old);
      case  PERIOD_M15: return iChart_M15.Ans_2(trend,old);
      case  PERIOD_M30: return iChart_M30.Ans_2(trend,old);
      case  PERIOD_H1:  return iChart_H1.Ans_2(trend,old);
      case  PERIOD_H4:  return iChart_H4.Ans_2(trend,old);
      case  PERIOD_D1:  return iChart_D1.Ans_2(trend,old);
      case  PERIOD_W1:  return iChart_W1.Ans_2(trend,old);
      case  PERIOD_MN1:  return iChart_MN1.Ans_2(trend,old);
      default: return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HubAns_3(int statement,int trend,int &old)
  {
   switch(statement)
     {
      case  PERIOD_M1: return iChart_M1.Ans_3(trend,old);
      case  PERIOD_M5: return iChart_M5.Ans_3(trend,old);
      case  PERIOD_M15: return iChart_M15.Ans_3(trend,old);
      case  PERIOD_M30: return iChart_M30.Ans_3(trend,old);
      case  PERIOD_H1:  return iChart_H1.Ans_3(trend,old);
      case  PERIOD_H4:  return iChart_H4.Ans_3(trend,old);
      case  PERIOD_D1:  return iChart_D1.Ans_3(trend,old);
      case  PERIOD_W1:  return iChart_W1.Ans_3(trend,old);
      case  PERIOD_MN1:  return iChart_MN1.Ans_3(trend,old);

      default: return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int HubAns_3_2(int tf,int Ans_Ma,int Ans_Oscillators,int &Ans)
  {
   switch(tf)
     {
      case  PERIOD_M1: return iChart_M1.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_M5: return iChart_M5.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_M15: return iChart_M15.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_M30: return iChart_M30.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_H1:  return iChart_H1.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_H4:  return iChart_H4.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_D1:  return iChart_D1.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_W1:  return iChart_W1.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);
      case  PERIOD_MN1:  return iChart_MN1.MA_OldTrend(Ans_Ma,Ans_Oscillators,Ans);

      default: return -2;
     }
   return -2;
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
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
   if(Authentication)
     {
      if((id==CHARTEVENT_OBJECT_CLICK))
        {
         Print("CHARTEVENT_OBJECT_CLICK ["+sparam+"]");
         //---
         if(StringFind(sparam,ExtName_OBJ,0)>=0)
           {
            string sep="@",result[];
            ushort  u_sep=StringGetCharacter(sep,0);
            int k=StringSplit(sparam,u_sep,result);

            if(result[2]=="Data")
              {
               int rMessageBox=MessageBox("Load data ?","Data",MB_OKCANCEL);
               if(rMessageBox==IDOK)
                 {
                  chk_data_Load(Symbol());
                 }
              }
            //---

            if(result[1]=="Symbol")
              {
               ShowBox=!ShowBox;
               if(!ShowBox)
                 {
                  ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_EDIT);
                 }
               else
                 {
                  Main_DrawElement(false,PostX_DefaultTBL,PostY_DefaultTBL);
                 }
              }
            //---
            if(result[2]=="TestToken")
              {
               int rMessageBox=MessageBox("Send Test Token ?","Line",MB_OKCANCEL);
               if(rMessageBox==IDOK)
                 {
                  string TestSignalLine="\n";
                  TestSignalLine+="⭕"+Symbol()+"⭕\n";
                  TestSignalLine+="Test Line Token";
                  LineNotify(TestSignalLine);
                 }

              }
            if(result[2]=="ObjClear")
              {
               int rMessageBox=MessageBox("ObjClear ?","ObjClear",MB_OKCANCEL);
               if(rMessageBox==IDOK)
                 {
                  string obj=ExtName_OBJ+"@VLine@"+strTF(Period());
                  printf(obj);
                  ObjectsDeleteAll(0,obj,0,OBJ_VLINE);
                 }
              }

            //+------------------------------------------------------------------+           
           }//#ExtName_OBJ
        }//#CHARTEVENT_OBJECT_CLICK
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarkArrow(int i,int ans,string Mode,double ScenePrice)
  {
   if(TIME_TF[i]==Period())
     {
      if(ans!=-1)
        {
         //---
         uchar _uchar=(Mode=="Cross")?241:225;

         ENUM_ARROW_ANCHOR _ANCHOR=ANCHOR_TOP;
         color _clrARROW=clrCornflowerBlue;
         if(ans==OP_SELL)
           {
            _uchar=(Mode=="Cross")?242:226;

            _ANCHOR=ANCHOR_BOTTOM;
            _clrARROW=clrSalmon;
           }

         //printf(strTF(TIME_TF[i])+"# "+ScenePrice);

         datetime dt=iTime(Symbol(),TIME_TF[i],1);

         ArrowCreate(0,ExtName_OBJ+"@Arrow@"+strTF(TIME_TF[i])+"@"+Mode+string(dt),0,
                     dt,ScenePrice,
                     _uchar,_ANCHOR,_clrARROW,
                     STYLE_SOLID,1,
                     false,false,false,0);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarkVLine(int i,string where,int ans)
  {
   if(TIME_TF[i]==Period())
     {
      if(ans!=-1)
        {
         //---
         color _clrLine=clrCornflowerBlue;
         if(ans==OP_SELL)
           {
            _clrLine=clrSalmon;
           }

         //printf(strTF(TIME_TF[i])+"# "+ScenePrice);

         datetime dt=iTime(Symbol(),TIME_TF[i],1);

         VLineCreate(0,ExtName_OBJ+"@VLine@"+strTF(TIME_TF[i])+"@"+string(dt),0,
                     dt,_clrLine,STYLE_DOT,1,
                     true,false,false,0);
        }
     }
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

//ObjectSetInteger(ChartID(),Name,OBJPROP_ALIGN,ALIGN_LEFT);
//---
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
   long  chart_ID=ChartID();
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
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,true);
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
      return false;
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
//|                                                                  |
//+------------------------------------------------------------------+
void Main_RemoveElement(int v)
  {

   string name;
   string sep="@",result[];
   ushort  u_sep=StringGetCharacter(sep,0);

   int ObjTotal=ObjectsTotal();

   for(int i=0;i<ObjTotal;i++)
     {
      name=ObjectName(i);
      if(ObjectGetInteger(0,name,OBJPROP_TYPE,0)==OBJ_LABEL)
        {
         int k=StringSplit(name,u_sep,result);
         if(result[2]=="S0" && result[1]!="Head")
           {
            string iSymbolName_Obj=result[1];
            //---
            if(!SymbolInfoInteger(iSymbolName_Obj,SYMBOL_SELECT))
              {
               ObjectsDeleteAll(0,ExtName_OBJ+"@"+iSymbolName_Obj);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string z_BoolToSrt(bool v)
  {
   return (v)?"True":"False";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//---
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
bool VLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="VLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time=0,            // line time 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            lock=true,// 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the line time is not set, draw it via the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      VLineMove(chart_ID,name,time,clr);
      //Print(__FUNCTION__,": failed to create a vertical line! Error code = ",GetLastError());
      //return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,lock);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool VLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="VLine", // line name 
               datetime     time=0,// line time 
               const color  clr=clrRed)// line color
  {
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- if line time is not set, move the line to the last bar 
   if(!time)
      time=TimeCurrent();
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      VLineMove(chart_ID,name,time);
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CommaZero(int v,int Digit,string z)
  {
   string temp=string(v);
   int n=StringLen(temp);

   string r="";
   for(int i=0;i<Digit-n;i++)
     {
      r+=" ";
     }
   r+=temp;
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string iSymbolName_Shor(string iSymbolName,long SWAP_MODE)
  {
   if(SWAP_MODE==0)
     {
      if(StringLen(iSymbolName)>=6)
        {
         string r1=StringSubstr(iSymbolName,0,3);
         string r2=StringSubstr(iSymbolName,3,3);
         string r3=StringSubstr(iSymbolName,6,StringLen(iSymbolName)-6);
         return r1+" "+r2+" "+r3;
        }
     }
   return iSymbolName;
  }
//+------------------------------------------------------------------+
string strTF(int v)
  {
   switch(v)
     {
      case  PERIOD_CURRENT:   return "CURRENT";
      case  PERIOD_M1:        return "M1_";
      case  PERIOD_M5:        return "M5_";
      case  PERIOD_M15:       return "M15";
      case  PERIOD_M30:       return "M30";
      case  PERIOD_H1:        return "H1_";
      case  PERIOD_H4:        return "H4_";
      case  PERIOD_D1:        return "D1_";
      case  PERIOD_W1:        return "W1";
      case  PERIOD_MN1:       return "MN1";
      default:return "--";
     }
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strTrend(int v)
  {

   if(v==OP_BUY)
      return "Up";
   if(v==OP_SELL)
      return "Down";
   return "None";

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bTICK=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TICK()
  {
   bTICK=!bTICK;
   string r=(bTICK)?"[":"]";
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrowCreate(const long              chart_ID=0,           // chart's ID 
                 const string            name="Arrow",         // arrow name 
                 const int               sub_window=0,         // subwindow index 
                 datetime                time=0,               // anchor point time 
                 double                  price=0,              // anchor point price 
                 const uchar             arrow_code=252,       // arrow code 
                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position 
                 const color             clr=clrRed,           // arrow color 
                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style 
                 const int               width=3,              // arrow size 
                 const bool              back=false,           // in the background 
                 const bool              selection=true,       // highlight to move 
                 const bool              hidden=true,          // hidden in the object list 
                 const long              z_order=0)            // priority for mouse click 
  {
//--- set anchor point coordinates if they are not set 
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value 
   ResetLastError();
//--- create an arrow 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
     {
      ObjectMove(chart_ID,name,0,time,price);
      //Print(__FUNCTION__,": failed to create an arrow! Error code = ",GetLastError());
      //return(false);
     }
//--- set the arrow code 
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the arrow color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the arrow's size 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the arrow by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar 
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
void setTimeframe()
  {

   string TFTF="";
   TFTF+=string(Show_M1)+",";
   TFTF+=string(Show_M5)+",";
   TFTF+=string(Show_M15)+",";
   TFTF+=string(Show_M30)+",";
   TFTF+=string(Show_H1)+",";
   TFTF+=string(Show_H4)+",";
   TFTF+=string(Show_D1)+",";
   TFTF+=string(Show_W1)+",";
   TFTF+=string(Show_MN1)+",";

   string result[];
   int k=StringSplit(TFTF,StringGetCharacter(",",0),result);

   ArrayResize(TIME_TF,k-1,0);
   for(int i=0;i<ArraySize(result)-1;i++)
     {
      TIME_TF[i]=int(result[i]);
      //printf(result[i]);
     }
//printf("---");
   for(int i=0;i<ArraySize(TIME_TF)-1;i++)
     {
      //printf(TIME_TF[i]);
     }
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
string List_Name[]={};
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool LockEA()
  {

//
   string Test_ID="",Test_Name="";
//
//Test_ID="9999";
//Test_Name="A_A";
//
   Test_ID=string(AccountInfoInteger(ACCOUNT_LOGIN));
   Test_Name=AccountInfoString(ACCOUNT_NAME);
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---
   bool Chk_ID=(ArraySize(List_ID)==0)?true:false;
   for(int i=0;i<ArraySize(List_ID);i++)
     {
      if(i==0 && (List_ID[0]=="" || List_ID[0]==Test_ID))
        {
         Chk_ID=true;
         break;
        }
      //---
      if(List_ID[i]==Test_ID)
        {
         Chk_ID=true;
         break;
        }
     }
//---
   bool Chk_Name=(ArraySize(List_Name)==0)?true:false;
   for(int i=0;i<ArraySize(List_Name);i++)
     {
      if(i==0 && (List_Name[0]=="" || StringFind(List_Name[0],Test_Name,0)>=0))
        {
         Chk_Name=true;
         break;
        }
      //---
      if(List_Name[i]==Test_Name)
        {
         Chk_Name=true;
         break;
        }
     }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
   Print("----------------------------------------------");
   Print("["+Test_ID+"] # "+string(Chk_ID));
   for(int i=0;i<ArraySize(List_ID);i++)
     {
      if(List_ID[i]!="")
        {
         Print("["+string(List_ID[i])+"]");
        }
     }
   Print("--------");
   Print("["+Test_Name+"] # "+string(Chk_Name));
   for(int i=0;i<ArraySize(List_Name);i++)
     {
      if(List_Name[i]!="")
        {
         string str=List_Name[i];
         StringReplace(str," ","_");
         Print("["+str+"]");
        }
     }
   Print("----------------------------------------------");
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
//---
   StringReplace(Test_Name," ","_");
//---
   bool Exp_Date=true;
   if(Exp_Set>0)
     {
      Exp_Date=(Exp_Set-TimeCurrent())>=0;
     }
//---
   bool Result=(Chk_ID && Chk_Name && Exp_Date)?true:false;
   printf("#"+string(__LINE__)+" #EALock Get  | ID : "+string(Test_ID)+" | Name: "+string(Test_Name));
   printf("#"+string(__LINE__)+" #EALock Chk | ID : "+string(Chk_ID)+" | Name: "+string(Chk_Name));

   printf("#"+string(__LINE__)+" #EALock Result: "+string(Result));

   if(IsDemo() || IsTesting())
     {
      Result=true;
      printf("#"+string(__LINE__)+" #EALock IsDemo()");
     }
   Print("----------------------------------------------");

   Authentication=Result;

   strAuthentication="\n\n\n\n\n";
   if(!Result)
     {
      if(ArraySize(List_ID)>0) strAuthentication+="#Lock_ID"+"\n";
      for(int i=0;i<ArraySize(List_ID);i++)
        {
         strAuthentication+=string(List_ID[i])+"\n";
        }

      if(ArraySize(List_Name)>0) strAuthentication+="#Lock_NAME"+"\n";
      for(int i=0;i<ArraySize(List_Name);i++)
        {
         strAuthentication+=string(List_Name[i])+"\n";
        }
     }

   return Result;
  }
//+------------------------------------------------------------------+
