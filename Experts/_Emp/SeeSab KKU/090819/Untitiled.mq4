//+------------------------------------------------------------------+
//|                                                    Untitiled.mq4 |
//|                                 Copyright 2019,Golden Master TH. |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Golden Master TH."
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
#property description "Exp : 2019.08.30 23:59" 
//####################################################################
datetime Exp_Set=D'2019.08.31 23:59';     //D'2019.07.01 23:59'
//+--#################################################################
//---
string eaName_Obj="Untitiled";
bool eaHidenObj=false;
bool eaDevelopMode=true;

extern int exMagicNumber=951;
extern double exEquity=10000;    //Equity
extern double exRisk=5;          //Risk (%)
extern double exTarget=1.5;      //Target
//---
double PN_Equity=-1;
double PN_Riskt=-1;
double PN_Target=-1;
//---
string REG_BTN_Group[]=
  {
   "Fibo_BuyPen|PN@BUY@00|OP_BUYLIMIT|message BUY_LIMIT",
   "Fibo_SelPen|PN@SELL@00|OP_SELLLIMIT|message SELL_LIMIT",

   "Fibo_BuyAct|PN@BUY_ACT@00|OP_BUY|message BUY",
   "Fibo_SelAct|PN@SELL_ACT@00|OP_SELL|message SELL"
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);

   PN_Equity=exEquity;
   PN_Riskt=exRisk;
   PN_Target=exTarget;

   DrawPanel();
//---

   for(int i=0;i<ArraySize(REG_BTN_Group);i++)
     {
      DrawFibo(REG_BTN_Group[i],-1,false,true);
     }

//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  EXP_()
  {
   bool Exp_Date=true;
   if(Exp_Set>0)
     {
      Exp_Date=(Exp_Set-TimeCurrent())>=0;
     }

   if(Exp_Date)
      return true;
   else
     {
      int  MSG=MessageBox(TimeToStr(Exp_Set,TIME_DATE|TIME_MINUTES),"EXP",MB_OK);
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Str_TO_OP(string str)
  {
   if(str=="OP_BUY")       return OP_BUY;
   if(str=="OP_SELL")      return OP_SELL;
   if(str=="OP_BUYLIMIT")  return OP_BUYLIMIT;
   if(str=="OP_SELLLIMIT") return OP_SELLLIMIT;
   if(str=="OP_BUYSTOP")   return OP_BUYSTOP;
   if(str=="OP_SELLSTOP")  return OP_SELLSTOP;
   return -1;
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
//Comment(strTick());
//ChartRedraw();
   DrawPanel();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//DrawPanel();
//ChartRedraw();
  }
bool boolTick=true;
bool boolTime=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strTick()
  {
   boolTick=!boolTick;
   return (boolTick)?"O":"X";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strTime()
  {
   boolTime=!boolTime;
   return (boolTime)?"O":"X";

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void Fibo_Effect(string REG_BTN,bool recall)
  {
   string result[];
   int k=StringSplit(REG_BTN,StringGetCharacter("|",0),result);

   int OP_Open=Str_TO_OP(result[2]);
//---
   DrawFibo(result[0],OP_Open,true,recall);
   OnChartEvent_FixDoubleClick(result[1],0,0);

   int  MSG=-1;
   MSG=MessageBox(result[3]+"\n"+"recall : ","OpenOrder",MB_OKCANCEL|MB_ICONINFORMATION);
   if(MSG==IDOK || MSG==IDCANCEL)
     {
      bool Response=false;
      if(MSG==IDOK)
        {
         printf("Ok");

         bool chk=Fibo_Get(result[0],
                           FiboPrice_Open,FiboPrice_TP,FiboPrice_SL,
                           FiboLot,FiboCoin,FiboPrice_Diff);
         //---
         if(eaDevelopMode)
           {
            HLineCreate(0,"TEST_OP",0,FiboPrice_Open
                        ,clrYellow,STYLE_SOLID,1,false,false,false,0);
            HLineCreate(0,"TEST_TP",0,FiboPrice_TP
                        ,clrLime,STYLE_SOLID,1,false,false,false,0);
            HLineCreate(0,"TEST_SL",0,FiboPrice_SL
                        ,clrRed,STYLE_SOLID,1,false,false,false,0);
           }
         printf("FIBO :"+DoubleToStr(OP_Open,Digits)+"  | OP :"+DoubleToStr(FiboPrice_Open,Digits)+" | TP :"+DoubleToStr(FiboPrice_TP,Digits)+" | SL :"+DoubleToStr(FiboPrice_SL,Digits));
         //---
         int Err=-1;
         if(chk)
           {

            int ticket=OrderSend(Symbol(),OP_Open,FiboLot,FiboPrice_Open,3,FiboPrice_SL,FiboPrice_TP,eaName_Obj+" ["+string(exMagicNumber)+"] SL:"+string(FiboPrice_Diff)+"p | $"+string(FiboCoin),exMagicNumber,0);
            Err=GetLastError();
            printf("OrderSend ERR "+string(Err));

            if(Err==0)
              {
               Response=true;
              }
           }
         //---
         if(Err!=0 || !chk)
           {
            //Recall Round
            Fibo_Effect(REG_BTN,true);
           }
         //---

        }
      if(MSG==IDCANCEL)
        {
         printf("Cancel");
         Response=true;
        }

      //---
      if(Response) DrawFibo(result[0],-1,false,true);
      OnChartEvent_FixDoubleClick(result[1],BTN_W_default,BTN_H_default);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Fibo_Effect_Active(string REG_BTN,bool recall)
  {
   string result[];
   int k=StringSplit(REG_BTN,StringGetCharacter("|",0),result);

   int OP_Open=Str_TO_OP(result[2]);
//---
   DrawFibo(result[0],OP_Open,true,recall);
   OnChartEvent_FixDoubleClick(result[1],0,0);

   int  MSG=MessageBox(result[3],"OpenOrder",MB_OKCANCEL|MB_ICONINFORMATION);
   if(MSG==IDOK || MSG==IDCANCEL)
     {
      bool Response=false;
      if(MSG==IDOK)
        {
         printf("Ok");

         bool chk=Fibo_Get(result[0],
                           FiboPrice_Open,FiboPrice_TP,FiboPrice_SL,
                           FiboLot,FiboCoin,FiboPrice_Diff);
         //---

         if(eaDevelopMode)
           {
            HLineCreate(0,"TEST_OP",0,FiboPrice_Open
                        ,clrYellow,STYLE_SOLID,1,false,false,false,0);
            HLineCreate(0,"TEST_TP",0,FiboPrice_TP
                        ,clrLime,STYLE_SOLID,1,false,false,false,0);
            HLineCreate(0,"TEST_SL",0,FiboPrice_SL
                        ,clrRed,STYLE_SOLID,1,false,false,false,0);
           }

         printf("FIBO :"+DoubleToStr(OP_Open,Digits)+"  | OP :"+DoubleToStr(FiboPrice_Open,Digits)+" | TP :"+DoubleToStr(FiboPrice_TP,Digits)+" | SL :"+DoubleToStr(FiboPrice_SL,Digits));
         //---
         int Err=-1;
         if(chk)
           {
            int ticket=OrderSend(Symbol(),OP_Open,FiboLot,FiboPrice_Open,3,FiboPrice_SL,FiboPrice_TP,eaName_Obj+" ["+string(exMagicNumber)+"] SL:"+string(FiboPrice_Diff)+"p | $"+string(FiboCoin),exMagicNumber,0);
            Err=GetLastError();
            printf("OrderSend ERR "+string(Err));

            if(Err==0)
              {
               Response=true;
              }
           }
         //---
         if(Err!=0 || !chk)
           {
            //Recall Round
            Fibo_Effect(REG_BTN,true);
           }
         //---

        }
      if(MSG==IDCANCEL)
        {
         printf("Cancel");
         Response=true;
        }

      //---
      if(Response) DrawFibo(result[0],-1,false,true);
      OnChartEvent_FixDoubleClick(result[1],int(BTN_W_default*0.45),BTN_H_default);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      Print("CHARTEVENT_OBJECT_ENDEDIT sparam: '"+sparam+"'");
      //---
      if(sparam==eaName_Obj+"@PN@TB@01")
        {
         printf("Balance");
         getEdit_Number("@PN@TB@01",PN_Equity,PN_Equity,0,AccountInfoDouble(ACCOUNT_EQUITY));
        }
      //---
      if(sparam==eaName_Obj+"@PN@TB@02")
        {
         printf("Risk");
         getEdit_Number("@PN@TB@02",PN_Riskt,PN_Riskt,0,100);
        }
      //---
      if(sparam==eaName_Obj+"@PN@TB@03")
        {
         printf("Target");
         getEdit_Number("@PN@TB@03",PN_Target,PN_Target,1,10);
        }
     }
//---

   if(id==CHARTEVENT_OBJECT_CLICK)
     {

      //---
      Print("CHARTEVENT_OBJECT_CLICK: '"+sparam+"'");
      //---
      if(sparam==eaName_Obj+"@HD@00@00")
        {
         if(ObjectGetInteger(0,eaName_Obj+"@HD@00@00",OBJPROP_SELECTED))
            DrawPanel();
         else
            DrawPanel_HideShow();
        }
      //---
      if(sparam==eaName_Obj+"@PN@BUY@00")
        {
         if(EXP_())
           {
            Fibo_Effect(REG_BTN_Group[0],false);
           }
        }
      //---
      if(sparam==eaName_Obj+"@PN@SELL@00")
        {
         if(EXP_())
            Fibo_Effect(REG_BTN_Group[1],false);
        }//---

      if(sparam==eaName_Obj+"@PN@BUY_ACT@00")
        {
         if(EXP_())
            Fibo_Effect_Active(REG_BTN_Group[2],false);
        }
      //---
      if(sparam==eaName_Obj+"@PN@SELL_ACT@00")
        {
         if(EXP_())
            Fibo_Effect_Active(REG_BTN_Group[3],false);
        }
      //---
      if(sparam==eaName_Obj+"@PN@CLOSE_ALL@00")
        {
         int  MSG=MessageBox("Order_CloseAll : MagicNumber "+string(exMagicNumber),"CloseAll",MB_YESNO|MB_ICONQUESTION);
         if(MSG==IDYES)
           {
            Order_CloseAll(exMagicNumber);
           }

        }
      //---
      if(sparam==eaName_Obj+"@PN@DEL_PENDING@00")
        {
         int  MSG=MessageBox("Order_PendingDelete : MagicNumber "+string(exMagicNumber),"PendingDelete",MB_YESNO|MB_ICONQUESTION);
         if(MSG==IDYES)
           {
            Order_PendingDelete(exMagicNumber);
           }
        }

      //ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent_FixDoubleClick(string name,int W,int H)
  {
   ObjectSetInteger(0,eaName_Obj+"@"+name,OBJPROP_XSIZE,W);
   ObjectSetInteger(0,eaName_Obj+"@"+name,OBJPROP_YSIZE,H);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderSend(int Mode)
  {
   double OP_Price=(Mode==OP_BUY)?Ask:Bid;
   double OP_PriceDis=0;

   double TP=0;
   double SL=0;

   int ticket=OrderSend(Symbol(),OP_BUY,1,OP_Price,100,SL,TP,"My order",exMagicNumber,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BTN_W_default=-1,BTN_H_default=-1;

int PostX_Move=200,PostY_Move=20;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPanel()
  {
   int BTN_W=200,BTN_H=20;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ObjectFind(0,eaName_Obj+"@HD@00@00")==0)
     {
      PostX_Move=int(ObjectGetInteger(0,eaName_Obj+"@HD@00@00",OBJPROP_XDISTANCE));
      PostY_Move=int(ObjectGetInteger(0,eaName_Obj+"@HD@00@00",OBJPROP_YDISTANCE));
     }

   int PostX_default=PostX_Move;
   int PostY_default=PostY_Move;

   int PostX_step=30,PostY_step=23;
   int PN_MarginTop=10;
   int PN_MarginLR=10;
//
   int PostX=PostX_default,PostY=PostY_default;
   BTN_W-=(PN_MarginLR*2);
   PostX_default+=PN_MarginLR;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(BTN_W_default==-1)
     {
      BTN_W_default=BTN_W;
      BTN_H_default=BTN_H;

     }

//---clrLightYellow

   setButtonCreate(0,"HD@00@00",0,
                   PostX,PostY,BTN_W+(PN_MarginLR*2),BTN_H+5,CORNER_LEFT_UPPER,
                   "Untitiled ","Arial",14,clrWhite,clrMediumBlue,clrGray,
                   false,false,true,true);
//+strTime()

   if(DrawPanel_Show)
     {
      PostY+=PostY_step+10;
      PostX=PostX_default;

      //clrLightYellow
      setRectLabelCreate("PN@BG",PostX-PN_MarginLR,PostY,clrNONE,clrLightYellow,clrLime,BTN_W+(PN_MarginLR*2),270,false);
      //------------------------+
      PostY+=PN_MarginTop;
      PostX=PostX_default;
      //
      setEditCreate("PN@LB@01","Balance :",true,true,PostX,PostY,int(BTN_W*0.45),BTN_H,10,ALIGN_LEFT,CORNER_LEFT_UPPER,clrBlack,clrLightYellow,clrLightYellow,false,false);
      PostX+=int(BTN_W*0.50);
      setEditCreate("PN@TB@01",string(PN_Equity),true,false,PostX,PostY,int(BTN_W*0.5),BTN_H,10,ALIGN_CENTER,CORNER_LEFT_UPPER,clrBlack,clrWhite,clrBlack,false,false);
      //---
      PostY+=PostY_step;
      PostX=PostX_default;
      //
      setEditCreate("PN@LB@02","Risk(%) :",true,true,PostX,PostY,int(BTN_W*0.45),BTN_H,10,ALIGN_LEFT,CORNER_LEFT_UPPER,clrBlack,clrLightYellow,clrLightYellow,false,false);
      PostX+=int(BTN_W*0.50);
      setEditCreate("PN@TB@02",string(PN_Riskt),true,false,PostX,PostY,int(BTN_W*0.5),BTN_H,10,ALIGN_CENTER,CORNER_LEFT_UPPER,clrBlack,clrWhite,clrBlack,false,false);
      //---
      PostY+=PostY_step;
      PostX=PostX_default;
      //
      setEditCreate("PN@LB@03","Target :",true,true,PostX,PostY,int(BTN_W*0.45),BTN_H,10,ALIGN_LEFT,CORNER_LEFT_UPPER,clrBlack,clrLightYellow,clrLightYellow,false,false);
      PostX+=int(BTN_W*0.50);
      setEditCreate("PN@TB@03",string(PN_Target),true,false,PostX,PostY,int(BTN_W*0.5),BTN_H,10,ALIGN_CENTER,CORNER_LEFT_UPPER,clrBlack,clrWhite,clrBlack,false,false);
      //---
      PostY+=PostY_step;
      PostX=PostX_default;
      LabelCreate("PN@LB@L01",PostX,PostY," ----------------------------------- ",11,clrBlack,false);
      //---
      //PostY+=PostY_step-10;
      //PostX=PostX_default;
      ////
      //setEditCreate("PN@LB@04","Lots Size :",true,true,PostX,PostY,int(BTN_W*0.45),BTN_H,10,ALIGN_LEFT,CORNER_LEFT_UPPER,clrBlack,clrLightYellow,clrLightYellow,false,false);
      //PostX+=int(BTN_W*0.50);
      //setEditCreate("PN@TB@04","0.01",true,true,PostX,PostY,int(BTN_W*0.5),BTN_H,10,ALIGN_CENTER,CORNER_LEFT_UPPER,clrBlack,clrLightYellow,clrLightYellow,false,false);

      //+++++++++++++++++++++++++++++++++++++++++++++++++++++++
      PostX=PostX_default;
      //
      PostY+=PostY_step;
      setButtonCreate(0,"PN@BUY@88",0,
                      PostX,PostY,BTN_W,BTN_H,CORNER_LEFT_UPPER,
                      "Buy Limit","Arial",12,clrWhite,clrBlue,clrRoyalBlue,
                      false,false,false);
      setButtonCreate(0,"PN@BUY@00",0,
                      PostX,PostY,BTN_W,BTN_H,CORNER_LEFT_UPPER,
                      "Buy Limit","Arial",12,clrWhite,clrRoyalBlue,clrRoyalBlue,
                      false,false,false);

      PostY+=PostY_step;
      setButtonCreate(0,"PN@SELL@88",0,
                      PostX,PostY,BTN_W,BTN_H,CORNER_LEFT_UPPER,
                      "Sell Limit","Arial",12,clrWhite,clrRed,clrTomato,
                      false,false,false);
      setButtonCreate(0,"PN@SELL@00",0,
                      PostX,PostY,BTN_W,BTN_H,CORNER_LEFT_UPPER,
                      "Sell Limit","Arial",12,clrWhite,clrTomato,clrTomato,
                      false,false,false);

      PostY+=PostY_step;
      PostX=PostX_default;
      LabelCreate("PN@LB@L02",PostX,PostY," ----------------------------------- ",11,clrBlack,false);
      //---

      //      PostY+=PostY_step-10;
      //      PostX=PostX_default;
      //      
      //      setEditCreate("PN@LB@05","Lots Size :",true,true,PostX,PostY,int(BTN_W*0.45),BTN_H,10,ALIGN_LEFT,CORNER_LEFT_UPPER,clrBlack,clrLightYellow,clrLightYellow,false,false);
      //      PostX+=int(BTN_W*0.50);
      //      setEditCreate("PN@TB@05","0.01",true,true,PostX,PostY,int(BTN_W*0.5),BTN_H,10,ALIGN_CENTER,CORNER_LEFT_UPPER,clrBlack,clrLightYellow,clrLightYellow,false,false);
      //---
      PostY+=PostY_step;
      PostX=PostX_default;

      setButtonCreate(0,"PN@BUY_ACT@88",0,
                      PostX,PostY,int(BTN_W*0.49),BTN_H,CORNER_LEFT_UPPER,
                      "Buy","Arial",12,clrWhite,clrRoyalBlue,clrRoyalBlue,
                      false,false,false);
      setButtonCreate(0,"PN@BUY_ACT@00",0,
                      PostX,PostY,int(BTN_W*0.49),BTN_H,CORNER_LEFT_UPPER,
                      "Buy","Arial",12,clrWhite,clrRoyalBlue,clrRoyalBlue,
                      false,false,false);

      setButtonCreate(0,"PN@SELL_ACT@88",0,
                      int(PostX+(BTN_W*0.52)),PostY,int(BTN_W*0.49),BTN_H,CORNER_LEFT_UPPER,
                      "Sell","Arial",12,clrWhite,clrTomato,clrTomato,
                      false,false,false);
      setButtonCreate(0,"PN@SELL_ACT@00",0,
                      int(PostX+(BTN_W*0.52)),PostY,int(BTN_W*0.49),BTN_H,CORNER_LEFT_UPPER,
                      "Sell","Arial",12,clrWhite,clrTomato,clrTomato,
                      false,false,false);

      //---
      PostY+=PostY_step;
      PostX=PostX_default;
      LabelCreate("PN@LB@L03",PostX,PostY," ----------------------------------- ",11,clrBlack,false);
      //---
      PostY+=PostY_step;
      PostX=PostX_default;
      setButtonCreate(0,"PN@CLOSE_ALL@00",0,
                      PostX,PostY,BTN_W,BTN_H,CORNER_LEFT_UPPER,
                      "Close All","Arial",12,clrWhite,clrLightSlateGray,clrLightSlateGray,
                      false,false,false);

      PostY+=PostY_step;
      setButtonCreate(0,"PN@DEL_PENDING@00",0,
                      PostX,PostY,BTN_W,BTN_H,CORNER_LEFT_UPPER,
                      "Delete Pending","Arial",12,clrWhite,clrGray,clrGray,
                      false,false,false);
     }
  }
bool DrawPanel_Show=true;
bool DrawComment_Show=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPanel_HideShow()
  {

   DrawPanel_Show=(DrawPanel_Show)?false:true;
   printf("DrawPanel_Show: "+string(DrawPanel_Show));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!DrawPanel_Show)
     {
      PN_Target=double(_ObjectGetEditor(eaName_Obj+"@PN@TB@03"));
      printf("PN_Target "+string(PN_Target));
      //---

      ObjectsDeleteAll(0,eaName_Obj+"@PN",0,OBJ_BUTTON);
      ObjectsDeleteAll(0,eaName_Obj+"@PN",0,OBJ_EDIT);
      ObjectsDeleteAll(0,eaName_Obj+"@PN",0,OBJ_RECTANGLE_LABEL);
      ObjectsDeleteAll(0,eaName_Obj+"@PN",0,OBJ_LABEL);
      ObjectsDeleteAll(0,eaName_Obj+"@PN",0,OBJ_LABEL);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      DrawPanel();
     }
//LockEA();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _ObjectGetEditor(string NAME)
  {
   return ObjectGetString(0,NAME,OBJPROP_TEXT,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setButtonCreate(const long              chart_ID=0,// chart's ID 
                     string                  name="Button",// button name 
                     const int               sub_window=0,             // subwindow index 
                     const int               x=0,                      // X coordinate 
                     const int               y=0,                      // Y coordinate 
                     const int               width=50,                 // button width 
                     const int               height=18,                // button height 
                     const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                     const string            text="Button",            // text 
                     const string            font="Arial",             // font 
                     const int               font_size=10,             // font size 
                     const color             clr=clrBlack,             // text color 
                     const color             back_clr=C'236,233,216',  // background color 
                     const color             border_clr=clrNONE,       // border color 
                     const bool              state=false,              // pressed/released 
                     const bool              back=false,               // in the background 
                     const bool              selection=false,
                     const bool              selectioned=false) // highlight to move 
  {

   name=eaName_Obj+"@"+name;
//--- reset the error value 
   ResetLastError();
//--- create the button 
//int Find=ObjectFind(chart_ID,name);
//printf(name+" "+Find);

   if(ObjectFind(chart_ID,name)!=0)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
        {
         //Print(__FUNCTION__,
         //      ": failed to create the button! Error code = ",GetLastError());
         //return(false);

        }

      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selectioned);

      //--- set button size 
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
     }
//--- set button coordinates 
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
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse 

//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setEditCreate(string           name="Edit",// object name 
                   const string           text="Text",// text 
                   const bool             reDraw=false,// ability to edit 
                   const bool             read_only=false,          // ability to edit 
                   const int              x=0,                      // X coordinate 
                   const int              y=0,                      // Y coordinate 
                   const int              width=50,                 // width 
                   const int              height=18,                // height 
                   const int              font_size=10,             // font size 
                   const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type 
                   const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                   const color            clr=clrBlack,             // text color 
                   const color            back_clr=clrWhite,        // background color 
                   const color            border_clr=clrNONE,       // border color 
                   const bool             back=false,               // in the background 
                   const bool             selection=false)          // highlight to move 
  {
   long  chart_ID=0;
   name=eaName_Obj+"@"+name;

//--- reset the error value 
   ResetLastError();
//--- create edit field 
   if(ObjectCreate(chart_ID,name,OBJ_EDIT,0,0,0))
     {
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setRectLabelCreate(string name,int x,int y,color clr,color back_clr,color border_clr,int width,int height,bool selection)
  {
   int chart_ID=0;
//---
   name=eaName_Obj+"@"+name;

   int sub_window=0;
   int corner=CORNER_LEFT_UPPER;
   string font="Arial";

   bool back=false;
   bool state=true;
   int z_order=0;

   ENUM_BORDER_TYPE border=BORDER_FLAT;
   ENUM_LINE_STYLE style=STYLE_SOLID;
   int line_width=4;
//--- reset the error value 
   ResetLastError();
//--- create a rectangle label 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      //Print(__FUNCTION__,": failed to create a rectangle label! Error code = ",GetLastError());
      //return;
     }
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border type 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode) 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set flat border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(string            name="Label",// label name 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const string            text="Label",             // text 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const bool              back=false)               // in the background 

  {
   long              chart_ID=0;// chart's ID 
   int               sub_window=0;// subwindow index 
   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER;// chart corner for anchoring 
   string            font="Arial";// font 
   double            angle=0;                // text slope 
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER; // anchor type 
   long              z_order=0;                // priority for mouse click 
   bool              selection=false; // highlight to move 
   name=eaName_Obj+"@"+name;

//--- reset the error value 
   ResetLastError();
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
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
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,eaHidenObj);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FiboPrice_Open,FiboPrice_TP,FiboPrice_SL;
double FiboLot,FiboPrice_Diff;
double FiboCoin;
color clrFibo_Disble=clrNONE;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fibo_Get(string name,
              double &Price_Open,double &Price_TP,double &Price_SL,
              double &Lot,double &Coin,double &Price_Diff)
  {
   double carry=-1;
   bool chk_r=false;
   Price_Diff=-1;
//---

   Price_Open=0;
   Price_TP=0;
   Price_SL=0;

   Price_Open=ObjectGet(name,OBJPROP_PRICE1);
   Price_SL=ObjectGet(name,OBJPROP_PRICE2);

//---

   carry=double(_ObjectGetEditor(eaName_Obj+"@PN@TB@03"));
   printf("carry "+string(carry));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(carry!=0 && MathIsValidNumber(carry))
     {
      Print("Object Text Is Numeric");
      //---
      for(int i=0;i<ArraySize(FIBO_Rate);i++)
        {
         if(FIBO_Rate[i]==(carry+1))
           {
            chk_r=true;
            break;
           }
        }
      //---
      PN_Target=carry;
      //---
      double Price_Diff_0=MathAbs(NormalizeDouble(Price_Open-Price_SL,Digits));
      double Price_Diff_TP=NormalizeDouble(Price_Diff_0,Digits);

      Price_Diff=NormalizeDouble(Price_Diff_0*MathPow(10,MarketInfo(Symbol(),MODE_DIGITS)),0);
      Lot=Order_LotCaculator(Price_Diff,Coin);

      Price_TP=(Price_Open>Price_SL)?Price_Open+Price_Diff_TP:Price_Open-Price_Diff_TP;
      //Price_SL=(Price_Open>Price_SL)?Price_Open-Price_Diff:Price_Open+Price_Diff;

      //---
      //Open Pending And Retrun reusul+t main
      //---

     }
   else
     {
      Print("Object Text NO! Numeric");

      ObjectSetString(0,eaName_Obj+"@PN@TB@03",OBJPROP_TEXT,0,string(PN_Target));
     }
//---

   Price_Open=NormalizeDouble(Price_Open,Digits);
   Price_TP=NormalizeDouble(Price_TP,Digits);
   Price_SL=NormalizeDouble(Price_SL,Digits);

   Print("chk_r "+string(chk_r));

   return chk_r;
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FIBO_Rate[]={2.0,2.5,3.0,3.5,4.0,4.5};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibo(string name,int OP_DIR,bool show,bool edit)
  {
//Effect Hideen/Show
   clrFibo_Disble=(eaDevelopMode)?clrFibo_Disble:clrHotPink;

   color clrLine=(show)?clrRed:clrFibo_Disble;
   color clrLevel=(show)?clrWhite:clrFibo_Disble;
//---
   int BarBack_1=24;
   int BarBack_2=48;
//---
   double FIBO_0=0;
   double FIBO_1=0;
   int FIBO_Time_0=0;
   int FIBO_Time_1=0;
//+------------------------------------------------------------------+
   if(show)
     {
      double FIBO_ValueH_1=ChartGetDouble(0,CHART_PRICE_MIN,0);
      double FIBO_ValueH_0=ChartGetDouble(0,CHART_PRICE_MIN,0);

      double FIBO_ValueL_0=ChartGetDouble(0,CHART_PRICE_MAX,0);
      double FIBO_ValueL_1=ChartGetDouble(0,CHART_PRICE_MAX,0);

      int FIBO_TimeH_1=0;
      int FIBO_TimeL_1=0;
      //---
      double High_[],Low_[];

      CopyHigh(Symbol(),Period(),0,int(BarBack_1+BarBack_2),High_);
      CopyLow(Symbol(),Period(),0,int(BarBack_1+BarBack_2),Low_);

      for(int i=0;i<ArraySize(High_);i++)
        {
         if(FIBO_ValueH_1<High_[i])
           {
            FIBO_ValueH_1=High_[i];
            FIBO_TimeH_1=(BarBack_1+BarBack_2)-i-1;
           }
         if(FIBO_ValueL_1>Low_[i])
           {
            FIBO_ValueL_1=Low_[i];
            FIBO_TimeL_1=(BarBack_1+BarBack_2)-i-1;
           }
        }

      for(int i=BarBack_1;i<ArraySize(High_);i++)
        {
         if(FIBO_ValueH_0<High_[i])
            FIBO_ValueH_0=High_[i];

         if(FIBO_ValueL_0>Low_[i])
            FIBO_ValueL_0=Low_[i];
        }
      double Distand_Min=NormalizeDouble(350/MathPow(10,Digits),Digits);

      FIBO_ValueL_1=(MathAbs(FIBO_ValueL_0-FIBO_ValueL_1)<Distand_Min)?FIBO_ValueL_0-Distand_Min:FIBO_ValueL_1;
      FIBO_ValueH_1=(MathAbs(FIBO_ValueH_0-FIBO_ValueH_1)<Distand_Min)?FIBO_ValueH_0+Distand_Min:FIBO_ValueH_1;

      if(eaDevelopMode)
        {
         HLineCreate(0,"MARK_H0",0,FIBO_ValueH_0
                     ,clrMagenta,STYLE_SOLID,1,false,false,false,0);
         HLineCreate(0,"MARK_H1",0,FIBO_ValueH_1
                     ,clrMagenta,STYLE_DOT,1,false,false,false,0);

         HLineCreate(0,"MARK_L0",0,FIBO_ValueL_0
                     ,clrMagenta,STYLE_SOLID,1,false,false,false,0);
         HLineCreate(0,"MARK_L1",0,FIBO_ValueL_1
                     ,clrMagenta,STYLE_DOT,1,false,false,false,0);
        }
      //--- ---
      if(OP_DIR<=OP_SELL)
        {
         FIBO_0=(OP_DIR==OP_BUY)?Ask:Bid;
         FIBO_1=(OP_DIR==OP_BUY)?FIBO_ValueL_1:FIBO_ValueH_1;
         FIBO_Time_0=(OP_DIR==OP_BUY)?FIBO_TimeL_1:FIBO_TimeH_1;

        }
      else
        {
         FIBO_0=(OP_DIR==OP_BUYLIMIT)?FIBO_ValueL_0:FIBO_ValueH_0;
         FIBO_1=(OP_DIR==OP_BUYLIMIT)?FIBO_ValueL_1:FIBO_ValueH_1;
         FIBO_Time_0=(OP_DIR==OP_BUYLIMIT)?FIBO_TimeL_1:FIBO_TimeH_1;
        }

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      FIBO_0=ChartGetDouble(0,CHART_PRICE_MAX,0);
      FIBO_1=ChartGetDouble(0,CHART_PRICE_MAX,0);
      FIBO_Time_0=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
      FIBO_Time_1=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
     }
//---
   FiboLevelsCreate(0,name,FIBO_Time_1,FIBO_0,FIBO_Time_0,FIBO_1,
                    clrLine,clrLevel,STYLE_DOT,1,false,true,false,false,0,edit);
//---

   double FIBO_Rate_LimitBreak=1.30;
//StratGroup
   ObjectSetFiboDescription(name,0,"SL ( "+DoubleToStr(FIBO_1,Digits)+" )");
   ObjectSet(name,OBJPROP_FIRSTLEVEL+(0),0);
   ObjectSetFiboDescription(name,1,"Entry ( "+DoubleToStr(FIBO_0,Digits)+" )");
   ObjectSet(name,OBJPROP_FIRSTLEVEL+(1),1);
   ObjectSetFiboDescription(name,2,"Limit Break ( "+DoubleToStr(FIBO_Rate_LimitBreak,Digits)+" )");   //Calculator
   ObjectSet(name,OBJPROP_FIRSTLEVEL+(2),FIBO_Rate_LimitBreak);

//FIBO_TP_Group
   for(int i=0;i<ArraySize(FIBO_Rate);i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      bool objSetFBD=ObjectSetFiboDescription(name,3+i,"TP "+DoubleToStr(FIBO_Rate[i]-1,2)+" ( "+DoubleToStr(FIBO_Rate[i],Digits)+" )");
      //printf(string(1+i)+" : "+string(objSetFBD));
      ObjectSet(name,OBJPROP_FIRSTLEVEL+(3+i),FIBO_Rate[i]);
     }
//Return

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fibo_State(string name)
  {
   return (ObjectGetInteger(0,name,OBJPROP_COLOR)==clrFibo_Disble)?false:true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiboLevelsCreate(const long            chart_ID=0,        // chart's ID 
                      const string          name="FiboLevels", // object name   
                      int                    timen1=0,// first point time 
                      double                price1=0,// first point price 
                      int                    timen2=0,// second point time 
                      double                price2=0,          // second point price 
                      const color           clr=clrRed,        // object color 
                      const color           clrLV=clrYellow,// object color 
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // object line style 
                      const int             width=1,           // object line width 
                      const bool            back=false,        // in the background 
                      const bool            selection=true,    // highlight to move 
                      const bool            ray_right=false,   // object's continuation to the right 
                      const bool            hidden=true,       // hidden in the object list 
                      const long            z_order=0,
                      const long            editLV=true) // priority for mouse click 
  {
   bool r=true;
//--- set anchor points' coordinates if they are not set 
   datetime time1=iTime(NULL,NULL,timen1);
   datetime time2=iTime(NULL,NULL,timen2);

   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2);
//--- reset the error value 
   ResetLastError();
//--- Create Fibonacci Retracement by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,0,time1,price1,time2,price2))
     {
      if(
         (!Fibo_State(name) && clrLV!=clrFibo_Disble) || 
         (Fibo_State(name) && clrLV!=clrFibo_Disble && !editLV) || 
         (Fibo_State(name) && clrLV==clrFibo_Disble)
         )
         //if()
        {
         FiboLevelsPointChange(0,name,0,time1,price1);
         FiboLevelsPointChange(0,name,1,time2,price2);
        }
      r=false;
     }
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,clrLV);
//--- set line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the object's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeFiboLevelsEmptyPoints(datetime &time1,double &price1,
                                 datetime &time2,double &price2)
  {
//--- if the second point's time is not set, it will be on the current bar 
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value 
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first point's time is not set, it is located 9 bars left from the second one 
   if(!time1)
     {
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one 
      time1=temp[0];
     }
//--- if the first point's price is not set, move it 200 points below the second one 
   if(!price1)
      price1=price2-200*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FiboLevelsPointChange(const long   chart_ID=0,        // chart's ID 
                           const string name="FiboLevels", // object name 
                           const int    point_index=0,     // anchor point index 
                           datetime     time=0,            // anchor point time coordinate 
                           double       price=0)           // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      ObjectMove(chart_ID,name,0,0,price);
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
void Order_CloseAll(int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if((OrderSelect(pos,SELECT_BY_POS)==true) && 
         (OrderSymbol()==Symbol()) && 
         (OrderType()<=OP_SELL) && 
         (OrderMagicNumber()==Magic))
        {
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(ORDER_TICKET_CLOSE);i++)
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
           {
            //bool z=OrderDelete(OrderTicketClose[i]);
            int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),100);
            if(GetLastError()==0){ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;}
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Order_PendingDelete(int Magic)
  {
   int   ORDER_TICKET_CLOSE[];
   ArrayResize(ORDER_TICKET_CLOSE,OrdersTotal());
   ArrayInitialize(ORDER_TICKET_CLOSE,EMPTY_VALUE);

   for(int pos=0;pos<OrdersTotal();pos++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if((OrderSelect(pos,SELECT_BY_POS)==true) && 
         (OrderSymbol()==Symbol()) && 
         (OrderType()>OP_SELL) && 
         (OrderMagicNumber()==Magic))
        {
         ORDER_TICKET_CLOSE[pos]=OrderTicket();
        }
     }
//+---------------------------------------------------------------------+
   for(int i=0;i<ArraySize(ORDER_TICKET_CLOSE);i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(ORDER_TICKET_CLOSE[i]!=EMPTY_VALUE)
        {
         if(OrderSelect(ORDER_TICKET_CLOSE[i],SELECT_BY_TICKET)==true)
           {
            bool z=OrderDelete(ORDER_TICKET_CLOSE[i]);
            //int MODE=(OrderType()==OP_BUY)?MODE_BID:MODE_ASK;
            //bool z=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE),100);
            if(GetLastError()==0){ORDER_TICKET_CLOSE[i]=EMPTY_VALUE;}
           }
        }
     }
   ArrayResize(ORDER_TICKET_CLOSE,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Order_LotCaculator(double POINT,double &COIN)
  {

   double Equity=1000;
   double Percent=5;
   Percent=NormalizeDouble(Percent/100,2);

   double contract=MarketInfo(Symbol(),MODE_LOTSIZE);
   printf("contract : "+string(contract));

   double DIGITS=1/MathPow(10,MarketInfo(Symbol(),MODE_DIGITS));
   double BID=MarketInfo(Symbol(),MODE_BID);

   double LOT_A=NormalizeDouble(Equity*Percent,2);
   double LOT_B=NormalizeDouble((DIGITS/BID)*contract*POINT,2);
   double LOT=NormalizeDouble(LOT_A/LOT_B,2);

   printf("LOT_B :"+string(LOT_B));
   printf("LOT_A :"+string(LOT_A));

   printf("LOT :"+string(LOT));

   COIN=LOT_A;
   return LOT;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool getEdit_Number(string nameObj,double before,double &after,
                    double Min,double Max)
  {
   bool r=false;
   double TEMP=StrToDouble(_ObjectGetEditor(eaName_Obj+nameObj));
   printf("TEMP "+string(TEMP));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(TEMP!=0 && MathIsValidNumber(TEMP))
     {
      Print("Object Text Is Numeric");
      //---
      if(TEMP>=Min && TEMP<=Max)
        {
         after=TEMP;
         r=true;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!r)
     {
      Print("Object Text NO! Numeric");

      ObjectSetString(0,eaName_Obj+nameObj,OBJPROP_TEXT,0,string(before));
     }
   return r;
  }
//+------------------------------------------------------------------+
