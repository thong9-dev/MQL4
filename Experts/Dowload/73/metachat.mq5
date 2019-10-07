//+------------------------------------------------------------------+
//|                                                     MetaChat.mq5 |
//|                                 Copyright © 2010 www.fxmaster.de |
//|                                         Coding by Sergeev Alexey |
//+------------------------------------------------------------------+
#property copyright    "www.fxmaster.de  © 2010"
#property link         "www.fxmaster.de"
#property version		  "1.00"
#property description  "Simple chat in MT5"

#include <InternetLib.mqh>

input string Host="www.fxmaster.de";
input string Channel="chat";
input string Name="YourName";
input color Clr=AntiqueWhite;

string inf="",Out;
MqlNet INet; // global variable
//------------------------------------------------------------------ OnInit
int OnInit()
  {
   // edit field
   CreateEdit(ChartID(),"Text","",10,30,310,20,SkyBlue,9,"Arial");
   // send button
   CreateButton(ChartID(),"Send","!",325,30,20,20,SkyBlue,false,"Wingdings");
   // clear button
   CreateButton(ChartID(),"Clear",CharToString(251),350,30,20,20,OrangeRed,false,"Wingdings");
   ModifyChart();
   ChartRedraw(ChartID());
   // open session
   INet.Open(Host,80);
   // set timer
   EventSetTimer(2); 
   return(0);
  }
//------------------------------------------------------------------ OnDeinit
void OnDeinit(const int reason)
  {
   ObjectDelete(ChartID(),"Text");
   ObjectDelete(ChartID(),"Clear");
   ObjectDelete(ChartID(),"Send");
   EventKillTimer(); Comment("");
   INet.Close();
  }
//------------------------------------------------------------------ OnTimer
void OnTimer()
  {
   // current time on the chart
   inf="\n"+Host+" :: "+TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS); 
   
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      inf=inf+"\n - system stopped";
      Comment(inf);
      return;
     } 
   // show name and channel
   inf=inf+"\n"+Name+" -> "+Channel; 
   if(INet.Request("GET","/metachat.php?channel="+Channel,Out))
      Comment(inf+"\n\n"+Out);
   return;
  }
//------------------------------------------------------------------ OnChartEvent
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   string text=ObjectGetString(ChartID(),"Text",OBJPROP_TEXT);
   string request="";
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="Clear")
         request="/metachat.php?channel="+Channel+"&clear=1";
      if(sparam=="Send" && text!="")
         request="/metachat.php?channel="+Channel+"&txt="+Name+" :  "+text+"&send=1";
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="Text" && text!="")
      request="/metachat.php?channel="+Channel+"&txt="+Name+" :  "+text+"&send=1";
   if(request!="")
     {
      INet.Request("GET",request,Out);
      ObjectSetString(ChartID(),"Text",OBJPROP_TEXT,"");
      ObjectSetInteger(ChartID(),"Clear",OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),"Send",OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),"Text",OBJPROP_SELECTED,true);
      ChartRedraw(ChartID());
     }
  }
//------------------------------------------------------------------ CreateButton
void CreateButton(long chart,string name,string txt,int x,int y,int dx,int dy,color clr,bool state,string font)
  {
   ObjectCreate(chart,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(chart,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(chart,name,OBJPROP_STATE,state);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,!clr);
   ObjectSetInteger(chart,name,OBJPROP_BGCOLOR,clr);
   ObjectSetInteger(chart,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart,name,OBJPROP_XSIZE,dx);
   ObjectSetInteger(chart,name,OBJPROP_YSIZE,dy);
   ObjectSetString(chart,name,OBJPROP_TEXT,txt);
   ObjectSetString(chart,name,OBJPROP_FONT,font);
  }
//------------------------------------------------------------------ CreateButton
void CreateEdit(long chart,string name,string txt,int x,int y,int dx,int dy,color clr,int fontsize,string font)
  {
   ObjectCreate(chart,name,OBJ_EDIT,0,0,0);
   ObjectSetInteger(chart,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,!clr);
   ObjectSetInteger(chart,name,OBJPROP_BGCOLOR,clr);
   ObjectSetInteger(chart,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart,name,OBJPROP_XSIZE,dx);
   ObjectSetInteger(chart,name,OBJPROP_YSIZE,dy);
   ObjectSetInteger(chart,name,OBJPROP_READONLY,false);
   ObjectSetString(chart,name,OBJPROP_TEXT,txt);
   ObjectSetString(chart,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart,name,OBJPROP_FONTSIZE,fontsize);
  }
//------------------------------------------------------------------ ModifyChart
void ModifyChart()
  {
   ChartSetInteger(ChartID(),CHART_SHOW_BID_LINE,false);
   ChartSetInteger(ChartID(),CHART_SHOW_ASK_LINE,false);
   ChartSetInteger(ChartID(),CHART_SHOW_OHLC,false);
   ChartSetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,false);
   ChartSetInteger(ChartID(),CHART_SHOW_GRID,false);
   ChartSetInteger(ChartID(),CHART_SHOW_OBJECT_DESCR,false);
   ChartSetInteger(ChartID(),CHART_SHOW_LAST_LINE,false);
   ChartSetInteger(ChartID(),CHART_COLOR_LAST,AntiqueWhite);
   ChartSetInteger(ChartID(),CHART_MODE,CHART_LINE);
   ChartSetInteger(ChartID(),CHART_SHOW_VOLUMES,CHART_VOLUME_HIDE);
   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,Clr);
   ChartSetInteger(ChartID(),CHART_COLOR_FOREGROUND,!Clr);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,Clr);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_LINE,Clr);
  }
//+------------------------------------------------------------------+