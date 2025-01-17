//+------------------------------------------------------------------+
//|                                              ScanSymbol_Info.mq4 |
//|                          Copyright 02-2019, Daren Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 02-2019, Daren Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
bool MarketWatch=false;
int MarketMax=SymbolsTotal(MarketWatch),CNT=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern int Refresh=1;//Refresh second
extern int FONTSIZE=9;//
extern int Spread=50;//Spread_Limt
extern bool SymbolHighlight=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ExtName_OBJ="ScanCS@";
bool ExtHide_OBJ=false;
//
int CarryIndex=10;
int Index[]= {10,120,150,190,230,270,325,370};
string SymBuy[1][9],SymSell[1][9];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(Refresh);
   Debug();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Debug()
  {

//ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_LABEL);
//ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_EDIT);

   ArrayResize(SymBuy,MarketMax*2,0);
   ArrayResize(SymSell,MarketMax,0);

//
   string CMM="",CMM_Temp;
   string CMM_Buy="",CMM_Sell="";
   int Cnt_Buy=NULL,Cnt_Sell=NULL;

   CMM+="\n MarketMax: "+string(MarketMax);
   CMM+="\n ---------";

#define Sym_Name1 0
#define Sym_Name2 1
#define Sym_Spraed 2
#define Sym_SwapBuy 3
#define Sym_SwapSell 4
#define Sym_MarketMode 5
#define Sym_SLv 6
#define Sym_SpraedAvg 7
#define Sym_NameFull 8

   for(int i=0; i<MarketMax; i++)
     {
      string Symbol_=SymbolName(i,MarketWatch);
      if(MarketInfo(Symbol_,MODE_TRADEALLOWED)==1)
        {
         //
         double ModeForex=MarketInfo(Symbol_,MODE_PROFITCALCMODE);
         //
         string MainSymbol=StringSubstr(Symbol_,0,3);
         string SecondSymbol=StringSubstr(Symbol_,3,3);
         if(ModeForex!=0)
           {
            MainSymbol=Symbol_;
            SecondSymbol="";
           }
         //
         double Swap_Buy   =  SymbolInfoDouble(Symbol_,SYMBOL_SWAP_LONG);
         double Swap_Sell  =  SymbolInfoDouble(Symbol_,SYMBOL_SWAP_SHORT);
         double Swap_Ratio =  0;//=(Swap_Buy>=0)?Swap_Buy/Swap_Sell:Swap_Sell/Swap_Buy;

         long  STOPS_LEVEL  = SymbolInfoInteger(Symbol_,SYMBOL_TRADE_STOPS_LEVEL);

         double   Spread_  =  MarketInfo(Symbol_,MODE_SPREAD);
         int      digit    =  int(MarketInfo(Symbol_,MODE_DIGITS));
         double   Base     =  MathPow(10,double(digit));

         //---
         bool Forex_Only=true;
         double Spread_Set=Spread;
         //---
         string sATR=DoubleToStr(iATR(Symbol_,0,14,1),digit);
         //---

         if((ModeForex==0 || !Forex_Only) && Spread_<=Spread_Set)
           {

            CMM_Temp="\n "+string(ModeForex)+" "+string(Symbol_)+" | "+string(Spread_)+" [ "+SwapToStr(Swap_Buy)+" , "+SwapToStr(Swap_Sell)+" ]"+SwapToStr(Swap_Ratio);

            if(Swap_Buy>=0)
              {
               SymBuy[Cnt_Buy][Sym_NameFull]       =  Symbol_;

               SymBuy[Cnt_Buy][Sym_Name1]       =  MainSymbol;
               SymBuy[Cnt_Buy][Sym_Name2]       =  SecondSymbol;
               SymBuy[Cnt_Buy][Sym_Spraed]      =  string(Spread_);
               SymBuy[Cnt_Buy][Sym_SwapBuy]     =  SwapToStr(Swap_Buy);
               SymBuy[Cnt_Buy][Sym_SwapSell]    =  SwapToStr(Swap_Sell);
               SymBuy[Cnt_Buy][Sym_MarketMode]  =  SwapToStr(ModeForex);
               SymBuy[Cnt_Buy][Sym_SLv]         =  string(STOPS_LEVEL);
               SymBuy[Cnt_Buy][Sym_SpraedAvg]   =  sATR;
               //---

               CMM_Buy+=CMM_Temp;
               Cnt_Buy++;
              }
            if(Swap_Sell>=0)
              {
               SymSell[Cnt_Sell][Sym_NameFull]       =  Symbol_;

               SymSell[Cnt_Sell][Sym_Name1]     =  MainSymbol;
               SymSell[Cnt_Sell][Sym_Name2]     =  SecondSymbol;
               SymSell[Cnt_Sell][Sym_Spraed]    =  string(Spread_);
               SymSell[Cnt_Sell][Sym_SwapBuy]   =  SwapToStr(Swap_Buy);
               SymSell[Cnt_Sell][Sym_SwapSell]  =  SwapToStr(Swap_Sell);
               SymSell[Cnt_Sell][Sym_MarketMode]=  SwapToStr(ModeForex);
               SymSell[Cnt_Sell][Sym_SLv]       =  string(STOPS_LEVEL);
               SymSell[Cnt_Sell][Sym_SpraedAvg] =  sATR;
               //---

               CMM_Sell+=CMM_Temp;
               Cnt_Sell++;
              }
           }

        }
     }
//
   for(int i=0; i<MarketMax; i++)
     {
      string Symbol_=SymbolName(i,MarketWatch);
      if(MarketInfo(Symbol_,MODE_TRADEALLOWED)==1)
        {
         //
         double ModeForex=MarketInfo(Symbol_,MODE_PROFITCALCMODE);
         //
         string MainSymbol=StringSubstr(Symbol_,0,3);
         string SecondSymbol=StringSubstr(Symbol_,3,3);
         if(ModeForex!=0)
           {
            MainSymbol=Symbol_;
            SecondSymbol="";
           }
         //
         double Swap_Buy   =  SymbolInfoDouble(Symbol_,SYMBOL_SWAP_LONG);
         double Swap_Sell  =  SymbolInfoDouble(Symbol_,SYMBOL_SWAP_SHORT);
         double Swap_Ratio =  0;//=(Swap_Buy>=0)?Swap_Buy/Swap_Sell:Swap_Sell/Swap_Buy;

         long STOPS_LEVEL  =  SymbolInfoInteger(Symbol_,SYMBOL_TRADE_STOPS_LEVEL);

         double Spread_ =  MarketInfo(Symbol_,MODE_SPREAD);
         int   digit    =  int(MarketInfo(Symbol_,MODE_DIGITS));
         double Base    =  MathPow(10,double(digit));

         //---
         bool Forex_Only   =  true;
         double Spread_Set =  Spread;
         //---
         string sATR=DoubleToStr(iATR(Symbol_,0,14,1),digit);
         //---

         if((ModeForex==1 || !Forex_Only) && Spread_<=Spread_Set)
           {

            CMM_Temp="\n "+string(ModeForex)+" "+string(Symbol_)+" | "+string(Spread_)+" [ "+SwapToStr(Swap_Buy)+" , "+SwapToStr(Swap_Sell)+" ]"+SwapToStr(Swap_Ratio);

            if(Swap_Buy>=0)
              {

               SymBuy[Cnt_Buy][Sym_NameFull]    =  Symbol_;
               SymBuy[Cnt_Buy][Sym_Name1]       =  MainSymbol;
               SymBuy[Cnt_Buy][Sym_Name2]       =  SecondSymbol;
               SymBuy[Cnt_Buy][Sym_Spraed]      =  string(Spread_);
               SymBuy[Cnt_Buy][Sym_SwapBuy]     =  SwapToStr(Swap_Buy);
               SymBuy[Cnt_Buy][Sym_SwapSell]    =  SwapToStr(Swap_Sell);
               SymBuy[Cnt_Buy][Sym_MarketMode]  =  SwapToStr(ModeForex);
               SymBuy[Cnt_Buy][Sym_SLv]         =  string(STOPS_LEVEL);
               SymBuy[Cnt_Buy][Sym_SpraedAvg]   =  sATR;

               CMM_Buy+=CMM_Temp;
               Cnt_Buy++;
              }
            if(Swap_Sell>=0)
              {
               SymSell[Cnt_Sell][Sym_NameFull]  =  Symbol_;
               SymSell[Cnt_Sell][Sym_Name1]=MainSymbol;
               SymSell[Cnt_Sell][Sym_Name2]=SecondSymbol;
               SymSell[Cnt_Sell][Sym_Spraed]=string(Spread_);
               SymSell[Cnt_Sell][Sym_SwapBuy]=SwapToStr(Swap_Buy);
               SymSell[Cnt_Sell][Sym_SwapSell]=SwapToStr(Swap_Sell);
               SymSell[Cnt_Sell][Sym_MarketMode]=SwapToStr(ModeForex);
               SymSell[Cnt_Sell][Sym_SLv]=string(STOPS_LEVEL);
               SymSell[Cnt_Sell][Sym_SpraedAvg]=sATR;

               CMM_Sell+=CMM_Temp;
               Cnt_Sell++;
              }
           }

        }
     }
   CMM+="\n Swap+ : Buy["+string(Cnt_Buy)+"]";
   CMM+=CMM_Buy;
   CMM+="\n";
   CMM+="\n Swap+ : Sell["+string(Cnt_Sell)+"]";
   CMM+=CMM_Sell;
//Comment(CMM);
//---
//---

   int Ld=20,Sy=int(FONTSIZE*1.5);
   int Ly=Ld,Lx=Index[ArraySize(Index)-1]+120;

   LabelCreate("Hade_0",CarryIndex+Index[0],Ly,"Symbol: "+string(Cnt_Buy),clrWhite,false,false);
   LabelCreate("Hade_1",CarryIndex+Index[1],Ly,"Sp"      ,clrWhite,false,false);
   LabelCreate("Hade_2",CarryIndex+Index[2],Ly,"Buy"     ,clrWhite,false,false);
   LabelCreate("Hade_3",CarryIndex+Index[3],Ly,"Sell"    ,clrWhite,false,false);
   LabelCreate("Hade_4",CarryIndex+Index[4],Ly,"Ratio"   ,clrWhite,false,false);
   LabelCreate("Hade_5",CarryIndex+Index[5],Ly,"S.LV(p)" ,clrWhite,false,false);
   LabelCreate("Hade_6",CarryIndex+Index[6],Ly,"ATR"     ,clrWhite,false,false);
   LabelCreate("Hade_6",CarryIndex+Index[7],Ly,"Full"    ,clrWhite,false,false);

   Ly+=Sy+5;
   for(int i=0; i<Cnt_Buy; i++)
     {
      //LabelCreate("Buy"+string(i)+"0",CarryIndex+Index[0],Ly,SymBuy[i,0],clrForexCFD(SymBuy[i,4]),false,false);
      LabelCreate("Buy"+string(i)+"01",CarryIndex+Index[0],Ly,SymBuy[i,0],clrSymbol(SymBuy[i,0],SymBuy[i,Sym_MarketMode]),false,false);
      LabelCreate("Buy"+string(i)+"02",CarryIndex+Index[0]+30,Ly,SymBuy[i,1],clrSymbol(SymBuy[i,1],SymBuy[i,Sym_MarketMode]),false,false);

      //Spread
      LabelCreate("Buy"+string(i)+"1",CarryIndex+Index[1],Ly,SymBuy[i,2],clrWhite,false,false);
      //Swap
      setEditCreate("Buy"+string(i)+"2",0,SymBuy[i,3]
                    ,false,true,CarryIndex+Index[2],Ly,45,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrSwap(SymBuy[i,3]),clrNONE,clrBlack,false,false,false,0);

      setEditCreate("Buy"+string(i)+"3",0,SymBuy[i,4]
                    ,false,true,CarryIndex+Index[3],Ly,45,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrSwap(SymBuy[i,4]),clrNONE,clrBlack,false,false,false,0);

      setEditCreate("Buy"+string(i)+"4",0,SymBuy[i,5]
                    ,false,true,CarryIndex+Index[4],Ly,45,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrWhite,clrNONE,clrBlack,false,false,false,0);
      setEditCreate("Buy"+string(i)+"5",0,SymBuy[i,6]
                    ,false,true,CarryIndex+Index[5],Ly,40,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrWhite,clrNONE,clrBlack,false,false,false,0);
      setEditCreate("Buy"+string(i)+"6",0,SymBuy[i,7]
                    ,false,true,CarryIndex+Index[6],Ly,60,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrWhite,clrNONE,clrBlack,false,false,false,0);

      LabelCreate("Buy"+string(i)+"7",CarryIndex+Index[7]+30,Ly,SymBuy[i,8],clrWhite,clrWhite,false,false);
      Ly+=Sy;
     }
   Ly=Ld;
   LabelCreate("Hade2_0",CarryIndex+Lx+Index[0],Ly,"Symbol: "+string(Cnt_Sell),clrWhite,false,false);
   LabelCreate("Hade2_1",CarryIndex+Lx+Index[1],Ly,"Sp"     ,clrWhite,false,false);
   LabelCreate("Hade2_2",CarryIndex+Lx+Index[2],Ly,"Buy"    ,clrWhite,false,false);
   LabelCreate("Hade2_3",CarryIndex+Lx+Index[3],Ly,"Sell"   ,clrWhite,false,false);
   LabelCreate("Hade2_4",CarryIndex+Lx+Index[4],Ly,"Ratio"  ,clrWhite,false,false);
   LabelCreate("Hade2_5",CarryIndex+Lx+Index[5],Ly,"S.LV(p)",clrWhite,false,false);
   LabelCreate("Hade2_6",CarryIndex+Lx+Index[6],Ly,"ATR"    ,clrWhite,false,false);
   LabelCreate("Hade2_7",CarryIndex+Lx+Index[7],Ly,"Full"   ,clrWhite,false,false);

   Ly+=Sy+5;

   for(int i=0; i<Cnt_Sell; i++)
     {
      //LabelCreate("Sell"+string(i)+"0",CarryIndex+Lx+Index[0],Ly,SymSell[i,0],clrForexCFD(SymSell[i,4]),false,false);

      LabelCreate("Sell"+string(i)+"01",CarryIndex+Lx+Index[0],Ly,SymSell[i,0],clrSymbol(SymSell[i,0],SymSell[i,Sym_MarketMode]),false,false);
      LabelCreate("Sell"+string(i)+"02",CarryIndex+Lx+Index[0]+30,Ly,SymSell[i,1],clrSymbol(SymSell[i,1],SymSell[i,Sym_MarketMode]),false,false);

      //Spread
      LabelCreate("Sell"+string(i)+"1",CarryIndex+Lx+Index[1],Ly,SymSell[i,2],clrWhite,false,false);
      //Swap
      setEditCreate("Sell"+string(i)+"2",0,SymSell[i,3]
                    ,false,true,CarryIndex+Lx+Index[2],Ly,45,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrSwap(SymSell[i,3]),clrNONE,clrBlack,false,false,false,0);
      setEditCreate("Sell"+string(i)+"3",0,SymSell[i,4]
                    ,false,true,CarryIndex+Lx+Index[3],Ly,45,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrSwap(SymSell[i,4]),clrNONE,clrBlack,false,false,false,0);

      setEditCreate("Sell"+string(i)+"4",0,SymSell[i,5]
                    ,false,true,CarryIndex+Lx+Index[4],Ly,45,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrWhite,clrNONE,clrBlack,false,false,false,0);
      setEditCreate("Sell"+string(i)+"5",0,SymSell[i,6]
                    ,false,true,CarryIndex+Lx+Index[5],Ly,40,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrWhite,clrNONE,clrBlack,false,false,false,0);
      setEditCreate("Sell"+string(i)+"6",0,SymSell[i,7]
                    ,false,true,CarryIndex+Lx+Index[6],Ly,64,FONTSIZE+3,"Arial",7,ALIGN_RIGHT,CORNER_LEFT_UPPER
                    ,clrWhite,clrNONE,clrBlack,false,false,false,0);
                    
      LabelCreate("Sell"+string(i)+"7",CarryIndex+Lx+Index[7]+30,Ly,SymSell[i,8],clrWhite,clrWhite,false,false);

      Ly+=Sy;
     }
//---
//AllowElement
   AllowElement("Buy",Cnt_Buy,MarketMax);
   AllowElement("Sell",Cnt_Sell,MarketMax);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrSymbol(string v,string m)
  {
   if(!SymbolHighlight)
     {
      return(StringToDouble(m)==0)?clrLime:clrYellow;
     }
   color r=clrWhite;

   if(v=="USD")
      r=clrRoyalBlue;
   if(v=="EUR")
      r=clrTomato;
   if(v=="GBP")
      r=clrMagenta;
   if(v=="NZD")
      r=clrDarkGray;
   if(v=="JPY")
      r=clrGold;
   if(v=="AUD")
      r=clrLime;
   if(v=="CHF")
      r=clrOrange;
   if(v=="CAD")
      r=clrHotPink;
   if(v=="CNY")
      r=clrAquamarine;

   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrForexCFD(string v)
  {
   return(StringToDouble(v)==0)?clrLime:clrYellow;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AllowElement(string type,int cnt,int max)
  {
   string Obj_name=NULL;
   for(int i=cnt; i<max; i++)
     {
      for(int j=0; j<ArraySize(Index); j++)
        {
         Obj_name=ExtName_OBJ+type+string(i)+string(j);
         if(ObjectFind(0,Obj_name))
           {
            ObjectsDeleteAll(0,Obj_name,0,OBJ_LABEL);
            ObjectsDeleteAll(0,Obj_name,0,OBJ_EDIT);
           }
         else
           {
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SwapToStr(double Swap)
  {
   if(Swap>=0)
     {
      return ""+DoubleToStr(Swap,2);
     }
   return DoubleToStr(Swap,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clrSwap(string v)
  {
   return (double(v)>=0)?clrDeepSkyBlue:clrRed;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

   ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_LABEL);
   ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_EDIT);

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
   Debug();
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
      Print("CHARTEVENT_OBJECT_CLICK '"+sparam+"'");
      string Sym=ObjectGetString(0,sparam,OBJPROP_TEXT,0);
      //ChartSetSymbolPeriod(0,Sym,0);
      long idChar=ChartOpen(Sym,0);
      printf("ChartOpen: "+Sym+" | id: "+string(idChar));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(string            name="Label",// label name
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const string            text="Label",             // text
                 const color             clr=clrRed,               // color
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true) // hidden in the object list
  {
//--- reset the error value
   ResetLastError();
   int chart_ID=0;
   name=ExtName_OBJ+name;

//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,0,0,0))
     {
      //Print(__FUNCTION__,
      //      ": failed to create text label! Error code = ",GetLastError());
      //return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,FONTSIZE);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,0);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,0);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,ExtHide_OBJ);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setEditCreate(string           name="Edit",// object name
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
   name=ExtName_OBJ+name;
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
//if()
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
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,FONTSIZE);
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
