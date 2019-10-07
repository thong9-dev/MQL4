//+------------------------------------------------------------------+
//|                                           CS_ZoneTrading.mq4.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <../Experts/KZM/CS_ZoneTrading[CSZT]/CS_eZoneTrading.mq4>

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
string l(int v)
  {
   return "#"+string(v)+" ";
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
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      BTN_A_Hide(sparam,"BTN_A_Hide");
      BTN_A_AddZone(sparam,"BTN_A_AddZone");
      BTN_A_AddZone_Submit(sparam,"BTN_A_AddZone_Submit");
      BTN_A_Lock(sparam,"BTN_A_Lock");

      BTN_B_Hide(sparam,"BTN_B_Hide");
      BTN_B_Select(sparam,"BTN_B_Select");
      BTN_Price_Hide(sparam,"BTN_Price_Hide");
      BTN_B_clrUP(sparam,"BTN_B_clrUP");
      BTN_B_clrDW(sparam,"BTN_B_clrDW");

      BTN_Hide_Commt(sparam,"Head_1");
      BTN_Full_Commt(sparam,"Head_2");

      BTN_CS_AdjustTP(sparam,"BTN_CS_AdjustTP");

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_A_Hide(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
        {
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);

         //ObjectSetString(0,NameBTN,OBJPROP_TEXT,"Show");
         //---
         ObjectDelete(0,ExtName_OBJ+"BTN_A_AddZone");
         ObjectDelete(0,ExtName_OBJ+"BTN_A_AddZone_Submit");

         ObjectDelete(0,ExtName_OBJ+"BTN_A_Lock");
         //---
         Management_ZoneA_Save(false);
        }
      else
        {
         int Size_Wide=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XSIZE);
         int Size_High=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YSIZE);

         int XStep=Size_Wide+5;
         int YStep=Size_High+5;

         int PostX=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XDISTANCE);
         int PostY=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YDISTANCE);PostY+=Size_High+5;
         //---
         _setBUTTON(ExtName_OBJ+"BTN_A_Lock",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_Lock(ObjGet_SELECTABLE("LINE_ZONE_A")),"Lock");PostY+=YStep;
         _setBUTTON(ExtName_OBJ+"BTN_A_AddZone",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRoyalBlue,"+Zone");

         //---
         boolZoneA_Show=true;
         Management_ZoneA_init();
         //---

         //ObjectSetString(0,NameBTN,OBJPROP_TEXT,"Hide");
         ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool stateBTN_A_AddZone=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_A_AddZone(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
        {
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);
         ObjectSetString(0,NameBTN,OBJPROP_TEXT,"Delete");
         //---
         int Size_Wide=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XSIZE);
         int Size_High=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YSIZE);

         int PostX=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XDISTANCE);
         int PostY=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YDISTANCE);PostY+=Size_High+5;

         _setBUTTON(ExtName_OBJ+"BTN_A_AddZone_Submit",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRoyalBlue,"Submit");
         //---
         if(ObjectFind(ExtName_OBJ+"AddLine"))
           {
            HLineCreate_(0,ExtName_OBJ+"LINE_DraftLineA","",0,Bid,clrBlue,1,0,0,true,false,0);
           }
         //---

         stateBTN_A_AddZone=true;
         _File_Read(__LINE__);
        }
      else
        {
         ObjectDelete(0,ExtName_OBJ+"BTN_A_AddZone_Submit");

         ObjectDelete(0,ExtName_OBJ+"LINE_DraftLineA");

         //---
         ObjectSetString(0,NameBTN,OBJPROP_TEXT,"+Zone");
         ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRoyalBlue);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRoyalBlue);
         //---
         stateBTN_A_AddZone=false;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_A_AddZone_Submit(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(!ObjectFind(ExtName_OBJ+"LINE_DraftLineA"))
        {
         double obj_DraftPrice=ObjectGetDouble(0,ExtName_OBJ+"LINE_DraftLineA",OBJPROP_PRICE);
         NormalizeDouble(obj_DraftPrice,Digits);
         //---
         int obj_cnt=0;
         bool chk_status=true;
         for(int i=0;i<ObjectsTotal();i++)
           {
            string name=ObjectName(i);
            if(StringFind(name,"LINE_ZONE_A",0)>=0)
              {
               double obj_SamplePrice=ObjectGetDouble(0,name,OBJPROP_PRICE);
               if(MathAbs(obj_DraftPrice-obj_SamplePrice)>=(iATR("",0,14,1)*0.5))
                 {
                  obj_cnt++;
                 }
               else
                 {
                  chk_status=false;
                  break;
                 }
              }
           }
         if(chk_status)
           {
            stateBTN_A_AddZone=false;

            string Tooltips=getSymbolShortName()+": ZONE_A00";
            HLineCreate_(0,ExtName_OBJ+"LINE_ZONE_A"+c(obj_cnt+1),Tooltips,0,obj_DraftPrice,clrRed,2,0,false,false,false,0);
            //---
            ObjectDelete(0,ExtName_OBJ+"LINE_DraftLineA");
            ObjectDelete(0,ExtName_OBJ+"BTN_A_AddZone_Submit");

            ObjectsDeleteAll(0,ExtName_OBJ+"DRAFT_ZONE_B");
            //---
            ObjectSetString(0,ExtName_OBJ+"BTN_A_AddZone",OBJPROP_TEXT,"+Zone");
            ObjectSetInteger(0,ExtName_OBJ+"BTN_A_AddZone",OBJPROP_BGCOLOR,clrRoyalBlue);
            ObjectSetInteger(0,ExtName_OBJ+"BTN_A_AddZone",OBJPROP_BORDER_COLOR,clrRoyalBlue);
            ObjectSetInteger(0,ExtName_OBJ+"BTN_A_AddZone",OBJPROP_STATE,true);
            //---
            Management_ZoneA_Save(true);
           }
         //---
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_A_Lock(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      bool unLock=ObjGet_SELECTABLE("LINE_ZONE_A");

      printf(l(__LINE__)+select+" "+ObjGet_SELECTABLE_N);

      if(unLock)
        {
         if(ObjGet_SELECTABLE_N>=1)
           {

           }
        }
/*if(ObjGet_SELECTABLE("LINE_ZONE_A"))
        {//Unlock
         if(Management_ZoneA_Save(true)<=1)
            ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_B");
         ObjSet_SELECTABLE("LINE_ZONE_A",false,NameBTN,clrLime);
        }
      else
        {//Lock
         if(ObjGet_Count("LINE_ZONE_A")<=0)
           {
            Management_ZoneA_Save(true);
            ObjSet_SELECTABLE("LINE_ZONE_A",false,NameBTN,clrLime);
           }
         else
           {
            ObjSet_SELECTABLE("LINE_ZONE_A",true,NameBTN,clrRed);
           }
        }*/
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_B_Hide(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(boolZoneB_Show)
        {
         ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_B");
         boolZoneB_Show=false;
         //---
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);
         //---
         ObjectDelete(0,ExtName_OBJ+"BTN_B_Select");
         ObjectDelete(0,ExtName_OBJ+"BTN_B_clrUP");
         ObjectDelete(0,ExtName_OBJ+"BTN_B_clrDW");
        }
      else
        {
         boolZoneB_Show=true;
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);
         //---
         int Size_Wide=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XSIZE);
         int Size_High=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YSIZE);

         int XStep=Size_Wide+5;
         int YStep=Size_High+5;

         int PostX=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XDISTANCE);
         int PostY=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YDISTANCE);PostY+=Size_High+5;
         //---
         _setBUTTON(ExtName_OBJ+"BTN_B_Select",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRed,"Select");PostY+=YStep;

         _setBUTTON(ExtName_OBJ+"BTN_B_clrDW",windex,CORNER_LEFT_UPPER,int(Size_Wide*0.45),Size_High,PostX,PostY,false,10,clrBlack,clrRed,"-");
         _setBUTTON(ExtName_OBJ+"BTN_B_clrUP",windex,CORNER_LEFT_UPPER,int(Size_Wide*0.45),Size_High,int(PostX+(Size_Wide*0.55)),PostY,false,10,clrBlack,clrLime,"+");PostY+=YStep;
        }
      Management_ZoneB(__LINE__);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_B_Select(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(ObjGet_SELECTABLE("LINE_ZONE_B"))
        {
         Management_ZoneB(__LINE__);
         ObjSet_SELECTABLE("LINE_ZONE_B",false,NameBTN,clrRed);
        }
      else
        {
         ObjSet_SELECTABLE("LINE_ZONE_B",true,NameBTN,clrLime);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_Price_Hide(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(ChartGetInteger(0,CHART_SHOW_TRADE_LEVELS,0))
        {
         ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,false);

         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);

        }
      else
        {
         ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,true);

         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);

        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_B_clrUP(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      clr_LineZoneB("UP");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_B_clrDW(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      clr_LineZoneB("DW");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_Hide_Commt(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(strCMMResult_bool)
         strCMMResult_bool=false;
      else
         strCMMResult_bool=true;
      OnTimer();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_Full_Commt(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(infoFull)
         infoFull=false;
      else
         infoFull=true;
      OnTimer();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_CS_AdjustTP(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      printf(l(__LINE__)+"-------------------PingAdjustTP");

      int cntFileRead=_File_Read(__LINE__);
      double PointArray[1];
      if(cntFileRead>=2)
        {

         Zone_B_cnt=int(1/getConstantZoneB());

         ArrayResize(PointArray,((cntFileRead-1)*Zone_B_cnt)+1,0);

         printf(l(__LINE__)+ArraySize(PointArray)+"|"+Zone_B_cnt);
         int k=0;

         for(int i=0;i<ArraySize(TroopA)-1;i++)
           {
            for(int j=0;j<Zone_B_cnt;j++)
              {
               double v=TroopB[i][j];
               //HLineCreate_(0,ExtName_OBJ+"LINE_ZONE_Z"+c(k),"",0,v,clrMagenta,3,0,false,false,false,0);
               //printf(l(__LINE__)+c(v,Digits));
               PointArray[k]=NormalizeDouble(v,Digits);
               k++;
              }
            if(i==ArraySize(TroopA)-2)
              {
               double v=TroopB[i][Zone_B_cnt];
               //printf(l(__LINE__)+c(v,Digits)+"   ****");
               PointArray[k]=NormalizeDouble(v,Digits);
              }
           }
        }
      //
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if((OrderSymbol()==Symbol())==false) continue;

         printf(l(__LINE__)+OrderTicket());
         double _OrderOpenPrice=OrderOpenPrice();

         for(int i=0;i<ArraySize(PointArray)-1;i++)
           {
            if(/*(PointArray[i]<_OrderOpenPrice) && */
               (PointArray[i]<=_OrderOpenPrice && PointArray[i+1]>_OrderOpenPrice))
              {
               HLineCreate_(0,ExtName_OBJ+"TP"+c(i),"",0,PointArray[i+1],clrMagenta,3,0,false,false,false,0);
               bool  r;
               int err;
               if(OrderType()<=1)
                 {
                  r=OrderModify(OrderTicket(),OrderOpenPrice(),0,PointArray[i+1],0);
                  //err=GetLastError();
                  //printf(l(__LINE__)+"|"+OrderTicket()+"|"+r+" | "+err);
                 }
               else
                 {
                  switch(OrderType())
                    {
                     case  OP_BUYSTOP:
                        r=OrderModify(OrderTicket(),PointArray[i],0,PointArray[i+1],0);
                        err=GetLastError();
                        printf(l(__LINE__)+"|"+OrderTicket()+"|"+r+" | "+err);
                        if(err==ERR_INVALID_STOPS)
                          {
/*if(condition)
                            {
                             
                            }*/
                           r=OrderModify(OrderTicket(),OrderOpenPrice(),0,PointArray[i+1],0);
                           err=GetLastError();
                           printf(l(__LINE__)+"|"+OrderTicket()+"|"+r+" | "+ERR_INVALID_STOPS+"|"+err);
                          }

                        break;
                     case  OP_BUYLIMIT:
                        r=OrderModify(OrderTicket(),PointArray[i],0,PointArray[i+1],0);
                        break;
                     default:
                        break;
                    }
                 }

/*switch(err)
                 {
                  case    ERR_NO_ERROR   ://	0	No error returned	break;
                     break;
                  case    ERR_NO_RESULT   ://	Is already
                     break;
                  case    ERR_INVALID_STOPS   ://130	Is already
                     r=OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0);
                     //err=GetLastError();
                     break;

                  default:
                     break;
                 }*/
              }
            else
              {

              }
           }
        }
     }
  }
//+-------------------------------------------------------------------------------------------------+
//|       ColorModule                                                                                          |
//+-------------------------------------------------------------------------------------------------+
long BG_Step=C'51,51,51';
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void clr_LineZoneB(string Case)
  {
   if(boolZoneB_Show)
     {

      _clrLineZoneB=ObjectGetInteger(0,"ZoneTrade LINE_ZONE_B1-1",OBJPROP_COLOR,0);
      long _clrLineGraph=0;
      if(Case=="UP")
        {
         _clrLineZoneB+=BG_Step;

         int step=int(_clrLineZoneB/BG_Step);
         _clrLineGraph=(C'0,51,0'*step);

         if(_clrLineZoneB>=C'255,255,255')
           {
            _clrLineZoneB=C'255,255,255';
            _clrLineGraph=C'0,255,0';
           }
        }
      else if(Case=="DW")
        {
         _clrLineZoneB-=BG_Step;

         int step=int(_clrLineZoneB/BG_Step);
         _clrLineGraph=(C'0,51,0'*step);

         if(_clrLineZoneB<=C'0,0,0')
           {
            _clrLineZoneB=C'0,0,0';
            _clrLineGraph=C'51,51,51';
           }
        }

      ObjectSetInteger(0,"ZoneTrade LINE_ZONE_B1-0",OBJPROP_BGCOLOR,_clrLineZoneB);
      //ChartSetInteger(0,CHART_COLOR_CHART_LINE,_clrLineGraph);

      Management_ZoneB_Draw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clr_BTN_Lock(bool v)
  {
   if(v)
      return clrRed;
   else
      return clrLime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clr_BTN_ShowZoneB()
  {
   if(ObjGet_Count("LINE_ZONE_B")>0)
     {
      boolZoneB_Show=true;
      return clrLime;
     }
   else
     {
      boolZoneB_Show=false;
      return clrRed;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clr_BTN_Price_Hide()
  {
   long v=ChartGetInteger(0,CHART_SHOW_TRADE_LEVELS,0);
   if(v)
      return clrLime;
   else
      return clrRed;
  }
//+------------------------------------------------------------------+
void BTN_init()
  {
   int Size_Wide=70;
   int Size_High=17;

   int PostX=10,XStep=Size_Wide+5;
   int PostY=20,YStep=Size_High+5;
//-----Down To Right-----//
   ObjectCreText(ExtName_OBJ+"Head_1",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_1","Zone A",10,"Arial",clrWhite);
//---
   ObjectSetString(0,ExtName_OBJ+"Head_1",OBJPROP_TOOLTIP,"Clik for HideComment");
//ObjectSetString(0,ExtName_OBJ+"Head_1",OBJPROP_TEXT,getSymbolShortName());
//---
   _setBUTTON(ExtName_OBJ+"BTN_A_Hide",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrLime,"Show");PostY+=YStep;
   _setBUTTON(ExtName_OBJ+"BTN_A_Lock",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_Lock(ObjGet_SELECTABLE("LINE_ZONE_A")),"Lock");PostY+=YStep;
   _setBUTTON(ExtName_OBJ+"BTN_A_AddZone",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRoyalBlue,"+Zone");PostY+=YStep;
//---
   PostX=10+Size_Wide+5;PostY=20;
   ObjectCreText(ExtName_OBJ+"Head_2",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_2","Zone B",10,"Arial",clrWhite);

   _setBUTTON(ExtName_OBJ+"BTN_B_Hide",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_ShowZoneB(),"Show");PostY+=YStep;
   if(boolZoneB_Show)
     {
      _setBUTTON(ExtName_OBJ+"BTN_B_Select",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRed,"Select");PostY+=YStep;
      _setBUTTON(ExtName_OBJ+"BTN_B_clrDW",windex,CORNER_LEFT_UPPER,int(Size_Wide*0.45),Size_High,PostX,PostY,false,10,clrBlack,clrRed,"-");
      _setBUTTON(ExtName_OBJ+"BTN_B_clrUP",windex,CORNER_LEFT_UPPER,int(Size_Wide*0.45),Size_High,int(PostX+(Size_Wide*0.55)),PostY,false,10,clrBlack,clrLime,"+");PostY+=YStep;

     }

//---
   PostX=10+(Size_Wide+5)*2;PostY=20;
   ObjectCreText(ExtName_OBJ+"Head_3",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_3","Daed",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_Daed_Hide",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrMagenta,"Show");PostY+=YStep;
   _setBUTTON(ExtName_OBJ+"BTN_Daed_Lock",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrMagenta,"Lock");PostY+=YStep;
//---
   PostX=10+(Size_Wide+5)*3;PostY=20;
   ObjectCreText(ExtName_OBJ+"Head_4",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_4","Price",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_Price_Hide",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_Price_Hide(),"Show");PostY+=YStep;

   PostX=10+(Size_Wide+5)*4;PostY=20;
   ObjectCreText(ExtName_OBJ+"Head_5",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_5","CS",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_CS_AdjustTP",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_Price_Hide(),"AdjustTP");PostY+=YStep;

  }
//---}
