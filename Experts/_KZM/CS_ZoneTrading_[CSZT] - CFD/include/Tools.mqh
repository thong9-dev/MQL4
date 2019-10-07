//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "../CS_eZoneTrading.mq4"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVLine(long chartID,int _windex,string name,datetime d1,datetime d2,double var,color clr,ENUM_LINE_STYLE style,string str)
  {
   if(ObjectFind(chartID,name))
     {
      ObjectCreate(chartID,name,OBJ_TREND,_windex,d1,var,d1,var);
     }
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_STYLE,style);
   ObjectMove(chartID,name,0,d1,var);
   ObjectMove(chartID,name,1,d2,var);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);

   if(str!="")
     {
      ObjectSetString(chartID,name,OBJPROP_TOOLTIP,str);
      ObjectSetString(chartID,name,OBJPROP_TEXT,str);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawBidAsk()
  {
   DrawVLine(ChartID(),0,"Bid",Time[0]/*+(Period()*100)*/,Time[0]*4,Bid,clrMagenta,STYLE_SOLID,"");
   if(Period()<=PERIOD_H1)
      DrawVLine(ChartID(),0,"Ask",Time[0]/*+(Period()*100)*/,Time[0]*4,Ask,clrMagenta,STYLE_SOLID,"");
   else
      ObjectDelete(ChartID(),"Ask");

//HLineCreate_(0,"Ask2","",0,Ask,C'60,60,60',0,0,false,false,false,false);

//---
   double _STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
//HLineCreate_(0,"LVStop_UP","Stop-LV: "+c(_STOPLEVEL,0)+"p",0,Ask+(Point*_STOPLEVEL),C'60,60,60',0,0,true,false,false,false);
//HLineCreate_(0,"LVStop_DW","Stop-LV: "+c(_STOPLEVEL,0)+"p",0,Bid-(Point*_STOPLEVEL),C'60,60,60',0,0,true,false,false,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawObj_Timer(bool Timer_here)
  {
   color clr=(Timer_here)?clrRed:clrDimGray;

   ObjectCreText(ExtName_OBJ+"Head_Timer",75,3);
   
   string Tick=(ObjectGetString(0,ExtName_OBJ+"Head_Timer",OBJPROP_TEXT,0)=="X")?"O":"X";
   ObjectSetText(ExtName_OBJ+"Head_Timer",Tick,10,"Arial",clr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getSymbolShortName()
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
double NormalizeDoubleCut(double v,int Digit)
  {
   return double(StringSubstr(DoubleToString(v),0,Digit+2));
  }
//+------------------------------------------------------------------+
