//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "../CS_eZoneTrading.mq4"
#include "internetlib.mqh"
MqlNet iMqlNet;
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
      Print("CHARTEVENT_OBJECT_CLICK '"+sparam+"'");
      BTN_Hide_Commt(sparam,"Head_1");
      BTN_Full_Commt(sparam,"Head_2");

      BTN_A_Hide(sparam,"BTN_A_Hide");
      BTN_A_AddZone(sparam,"BTN_A_AddZone");BTN_A_AddZoneDrawB(sparam,"LINE_DraftLineA");
      BTN_A_AddZone_Submit(sparam,"BTN_A_AddZone_Submit");
      BTN_A_Lock(sparam,"BTN_A_Lock");

      BTN_B_Hide(sparam,"BTN_B_Hide");
      BTN_B_Select(sparam,"BTN_B_Select");
      BTN_Price_Hide(sparam,"BTN_Price_Hide");
      BTN_B_clrUP(sparam,"BTN_B_clrUP");
      BTN_B_clrDW(sparam,"BTN_B_clrDW");

      BTN_Daed_Add(sparam,"BTN_Daed_Add");
      BTN_Breath_CallFill(sparam,"BTN_Breath_CallFill");LINE_DraftBreathFill(sparam,"LINE_DraftBreathFill");

      BTN_CS_AdjustTP(sparam,"BTN_CS_AdjustTP");

      BTN_CS_Auto_RSI(sparam,"BTN_CS_Auto_RSI");

      BTN_CS_Buy_B(sparam,"BTN_CS_Buy_B");

      BTN_AutoEA(sparam,"BTN_AutoEA");

      BTN_DeleteAllPen(sparam,"BTN_DeleteAllPen");

      BTN_Report(sparam,"BTN_Report");
     }
//+------------------------------------------------------------------+
   if(id==CHARTEVENT_KEYDOWN)
     {
      Print("The "+c(lparam)+" has been pressed");
      switch(int(lparam))
        {
         case 81:
            BTN_A_Hide(ExtName_OBJ+"BTN_A_Hide","BTN_A_Hide");
            break;
         case 87:
            BTN_B_Hide(ExtName_OBJ+"BTN_B_Hide","BTN_B_Hide");
            break;
         case 83:
            BTN_B_clrUP(ExtName_OBJ+"BTN_B_clrUP","BTN_B_clrUP");
            break;
         case 88:
            BTN_B_clrDW(ExtName_OBJ+"BTN_B_clrDW","BTN_B_clrDW");
            break;
         case 69:
            BTN_Price_Hide(ExtName_OBJ+"BTN_Price_Hide","BTN_Price_Hide");
            break;
         case 82:
            BTN_Hide_Commt(ExtName_OBJ+"BTN_Hide_Commt","BTN_Hide_Commt");
            break;
         default:
            break;
        }
     }
//+------------------------------------------------------------------+
   if((id==CHARTEVENT_CHART_CHANGE))
     {
      CostTableTag();
      LINE_DraftBreathFill(ExtName_OBJ+"LINE_DraftBreathFill","LINE_DraftBreathFill");
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CostTableTag()
  {
   if(ArraySize(TroopB_PTP)>2 && strCMMResult_bool)
     {
      double CONSIZE=MarketInfo(Symbol(),MODE_LOTSIZE);
      double TICKSIZE=MarketInfo(Symbol(),MODE_TICKSIZE);
      double MINLOT=MarketInfo(Symbol(),MODE_MINLOT);

      double obj_DraftPrice=ObjectGetDouble(0,ExtName_OBJ+"LINE_DeadLine",OBJPROP_PRICE);
      //CONSIZE=1000;
      //printf(l(__LINE__,"ArraySize(TroopB_PTP)")+ArraySize(TroopB_PTP));
      double T1=TroopB_PTP[ArraySize(TroopB_PTP)-2];
      double D=(T1-obj_DraftPrice);
      //---
      double Q_Cap=(MINLOT*D*CONSIZE)/T1;
      double Q_Lot=(Q_Cap*T1)/(D*CONSIZE);
      double Q_D=(T1*0.01)/(Q_Lot*CONSIZE);
      Q_D=NormalizeDouble(Q_D,Digits);
      //---
      double Magin=MaginGet(T1,Q_Lot);
      //-------------------------------------------------------------
      int bar=int(ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0));
      //printf(l(__LINE__,"bar")+bar);
      int x,y,fontSize=7;
      ChartTimePriceToXY(0,0,Time[bar],obj_DraftPrice,x,y);

      string Text="** Put money Table **";
      LabelCreate(0,ExtName_OBJ+"PutTageTBl",0,x+10,y,0,Text,"",fontSize,clrTomato,0,false,false,false,0);

      Q_Cap=NormalizeDouble(Q_Cap,2);
      Q_Lot=NormalizeDoubleCut(Q_Lot,2);

      Text=c(Q_D,Digits)+"Point ~ "+c(Q_Lot,2)+"Lot | "+c(Q_Cap+Magin,2)+"Cap | "+c(Magin,2)+"Magin All";

      y+=10;LabelCreate(0,ExtName_OBJ+"PutTage",0,x+10,y,0,Text,"",fontSize,clrGold,0,false,false,false,0);
      //---
      int TroopA_Size=ArraySize(TroopA)-1;
      int TroopB_Size=ArraySize(TroopB_PTP)-1;
      double TroopAll=TroopA_Size+TroopB_Size;

      double Test_Tick=0.001,Test_Cap=0,Test_Lot=0,Q_Cap_Per=0;
      string star;
      double Arr_Cap[1];
      ArrayResize(Arr_Cap,Digits);
      for(int i=Digits;i>=1;i--)
        {
         Test_Tick=1/MathPow(10,i);
         //---
         Test_Cap=0;
         Test_Lot=0;
         do
           {
            Test_Lot+=MINLOT;
            Test_Lot=NormalizeDouble(Test_Lot,2);

            Test_Cap=(Test_Lot*Test_Tick*CONSIZE)/T1;
            Test_Cap=NormalizeDouble(Test_Cap,2);
           }
         while(Test_Cap<0.01);
         //---
         Test_Cap=(Test_Lot*D*CONSIZE)/T1;
         Test_Cap=NormalizeDoubleCut(Test_Cap,2);

         Arr_Cap[i-1]=Test_Cap;
         Q_Cap_Per=(Test_Cap/Arr_Cap[Digits-1])*100;
         Q_Cap_Per=NormalizeDouble(Q_Cap_Per,2);

         Magin=MaginGet(T1,Test_Lot);

         Text=star+c(Test_Tick,i)+"P ~ "+c(Test_Lot,2)+"L | "+c(Test_Cap+Magin,2)+"C "+c(Magin,2)+"m | "+c(Q_Cap_Per,2)+"% "+c(TroopAll*Test_Cap,2);
         star+="_";
         y+=10;LabelCreate(0,ExtName_OBJ+"PutTageTBl"+c(i),0,x+10,y,0,Text,"",fontSize,clrWhite,0,false,false,false,0);
        }

      //---
      double U_Lot=(Capital*T1)/(D*CONSIZE),U_D=0;
      U_Lot=NormalizeDouble(U_Lot,2);
      if(U_Lot>0)
        {
         U_D=(T1*0.01)/(U_Lot*CONSIZE);
         U_D=NormalizeDouble(U_D,Digits);
        }

      Q_Cap_Per=(Capital/Arr_Cap[Digits-1])*100;
      Q_Cap_Per=NormalizeDouble(Q_Cap_Per,2);

      Text="** Put money now **";
      y+=10;LabelCreate(0,ExtName_OBJ+"PutTageUse1",0,x+10,y,0,Text,"",fontSize,clrTomato,0,false,false,false,0);

      Text=c(U_D,Digits)+"P ~ "+c(U_Lot,2)+"L | "+c(Capital,2)+"C | "+c(Q_Cap_Per,2)+"% "+c((ArraySize(TroopB_PTP)-1)*Capital,2);
      y+=10;LabelCreate(0,ExtName_OBJ+"PutTageUse2",0,x+10,y,0,Text,"",fontSize,clrWhite,0,false,false,false,0);
      //---
     }
   else
     {
      ObjectsDeleteAll(0,ExtName_OBJ+"PutTage",0,OBJ_LABEL);
/*long           chart_id,   // chart ID 
                            const string     prefix,   // prefix in object name 
                            int    sub_window=EMPTY,   // window index 
                            int    object_type=EMPTY   // object type 
                            );*/
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
      printf(l(__LINE__)+"BTN_A_Hide ---------------------------------");
      //if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
      if(boolZoneA_Show)
        {
         //printf(l(__LINE__)+"BTN_A_Hide (1)--");
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
         //printf(l(__LINE__)+"BTN_A_Hide (2)--");

         //int Size_Wide=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XSIZE);
         //int Size_High=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YSIZE);

         //int XStep=Size_Wide+5;
         //int YStep=Size_High+5;

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
      printf(l(__LINE__)+"BTN_A_Hide --------------------------------- End");
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
         //int Size_Wide=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XSIZE);
         //int Size_High=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YSIZE);

         int PostX=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XDISTANCE);
         int PostY=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YDISTANCE);PostY+=Size_High+5;

         _setBUTTON(ExtName_OBJ+"BTN_A_AddZone_Submit",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRoyalBlue,"Submit");
         //---
         if(ObjectFind(ExtName_OBJ+"AddLine"))
           {
            HLineCreate(0,ExtName_OBJ+"LINE_DraftLineA","",0,Bid,clrBlue,1,0,0,true,true,false,0);
           }
         //---

         int Period_=int((PERIOD_MN1*12*Guide_YN)/PERIOD_MN1);
         double val_H=-1,val_L=-1,val_L2=-1,val_L3=-1;
         //
         int _iLow_LOW3=-1,_iLow_LOW2=-1,_iLow_LOW=-1;
         //---
         int n_BB=iBars(Symbol(),PERIOD_MN1);
         int _iLow_BB=iLowest(Symbol(),PERIOD_MN1,MODE_LOW,n_BB,0);
         double val_BB=iLow(Symbol(),PERIOD_MN1,_iLow_BB);
         HLineCreate(0,ExtName_OBJ+"GuideBB","GuideBB ["+c(_iLow_BB,Digits)+"] "+c(val_BB,Digits),0,val_BB,clrMagenta,2,0,false,false,false,false,0);

         //
         int _iHigh_High=iHighest(Symbol(),PERIOD_MN1,MODE_HIGH,Period_,0);
         if(_iHigh_High>=0) val_H=iHigh(Symbol(),PERIOD_MN1,_iHigh_High);
         //
         bool Interrupt=false;
         double Carry=0;
         double Multi=1;
         do
           {
            _iLow_LOW=iLowest(Symbol(),PERIOD_MN1,MODE_LOW,int(Period_*Multi),1);
            if(_iLow_LOW>=0) val_L=iLow(Symbol(),PERIOD_MN1,_iLow_LOW);
            if(val_BB>=val_L)
              {
               Interrupt=true;
               break;
              }
            Multi++;
            Carry=val_H-val_L;
           }
         while(((Bid-val_L)<(Carry*0.263)));
         //
         if(Interrupt)
           {
            Carry=val_H-val_L;
            val_L2=val_L-Carry*0.236;
            val_L3=val_L-Carry*0.618;
           }
         else
           {
            Interrupt=false;
            Carry=val_H-val_L;
            Multi=1;
            do
              {
               _iLow_LOW2=iLowest(Symbol(),PERIOD_MN1,MODE_LOW,int(Period_*Multi),0);
               if(_iLow_LOW2>=0) val_L2=iLow(Symbol(),PERIOD_MN1,_iLow_LOW2);
               Multi++;
               if(val_BB>=val_L2)
                 {
                  Interrupt=true;
                  break;
                 }
              }
            while(((val_L-val_L2)<(Carry*0.263)));
            if(Interrupt)
              {
               Carry=val_H-val_L;
               val_L2=val_L-Carry*0.236;
               val_L3=val_L-Carry*0.618;
              }
            else
              {
               Interrupt=false;
               Carry=val_H-val_L;
               Multi=1;
               do
                 {
                  _iLow_LOW3=iLowest(Symbol(),PERIOD_MN1,MODE_LOW,int(Period_*Multi),0);
                  if(_iLow_LOW3>=0) val_L3=iLow(Symbol(),PERIOD_MN1,_iLow_LOW3);
                  Multi++;
                  if(val_BB>val_L3)
                    {
                     Interrupt=true;
                     break;
                    }
                 }
               while(((val_L2-val_L3)<(Carry*0.263)));
               if(Interrupt)
                 {
                  val_L3=val_L-Carry*0.618;
                 }
               else
                 {
                 }
              }
           }
         //+------------------------------------------------------------------+
         //+------------------------------------------------------------------+       
         HLineCreate(0,ExtName_OBJ+"GuideHigh","GuideHigh ["+c(_iHigh_High,Digits)+"] "+c(val_H,Digits),0,val_H,clrRed,2,0,false,false,false,false,0);
         HLineCreate(0,ExtName_OBJ+"GuideLow","GuideLow ["+c(_iLow_LOW,Digits)+"] "+c(val_L,Digits),0,val_L,clrRed,2,0,false,false,false,false,0);

         HLineCreate(0,ExtName_OBJ+"GuideLow1","GuideLow1 ["+c(_iLow_LOW2,Digits)+"] "+c(val_L2,Digits),0,val_L2,clrYellow,2,0,true,false,false,false,0);
         HLineCreate(0,ExtName_OBJ+"GuideLow2","GuideLow2 ["+c(_iLow_LOW3,Digits)+"] "+c(val_L3,Digits),0,val_L3,clrYellow,2,0,true,false,false,false,0);

         //---
         stateBTN_A_AddZone=true;
         _File_Read(__LINE__);
        }
      else
        {
         ObjectDelete(0,ExtName_OBJ+"BTN_A_AddZone_Submit");

         ObjectDelete(0,ExtName_OBJ+"GuideHigh");
         ObjectDelete(0,ExtName_OBJ+"GuideLow");
         ObjectDelete(0,ExtName_OBJ+"GuideLow1");
         ObjectDelete(0,ExtName_OBJ+"GuideLow2");
         ObjectDelete(0,ExtName_OBJ+"GuideBB");

         ObjectDelete(0,ExtName_OBJ+"LINE_DraftLineA");
         ObjectsDeleteAll(0,ExtName_OBJ+"DRAFT_ZONE_B");
         //---
         ObjectSetString(0,NameBTN,OBJPROP_TEXT,"+Zone");
         ObjectSetInteger(0,NameBTN,OBJPROP_STATE,false);
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRoyalBlue);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRoyalBlue);
         //---
         stateBTN_A_AddZone=false;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_A_AddZoneDrawB(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      strCMMResult+=l(__LINE__)+"------- stateBTN_A_AddZone\n";
      strCMMResult+=l(__LINE__)+c(stateBTN_A_AddZone)+"\n";
      int TroopA_Size=ArraySize(TroopA);
      if(stateBTN_A_AddZone && TroopA_Size>=1)
        {

         double obj_DraftPrice=ObjectGetDouble(0,ExtName_OBJ+"LINE_DraftLineA",OBJPROP_PRICE);
         NormalizeDouble(obj_DraftPrice,Digits);
         //
         int chkZone=-1;
         for(int i=TroopA_Size-1;i>=0;i--)
           {
            if(i<TroopA_Size-1)
               if(TroopA[i+1]>obj_DraftPrice && TroopA[i]<obj_DraftPrice)
                  chkZone=i;
           }

         if(chkZone<0)
           {
            //printf("TroopA_Size"+TroopA_Size);
            if(TroopA[TroopA_Size-1]<obj_DraftPrice)
              {
               Print(l(__LINE__)+"Upper");
               double D_Full=MathAbs(TroopA[TroopA_Size-1]-obj_DraftPrice);
               double D=NormalizeDouble(D_Full*Management_ZoneB_getConstant(),Digits);

               double P_Mark=TroopA[TroopA_Size-1];
               for(int j=0;j<int(1/Management_ZoneB_getConstant());j++)
                 {
                  P_Mark+=D;
                  NormalizeDouble(P_Mark,Digits);
                  //color(_clrLineZoneB)
                  HLineCreate_(0,ExtName_OBJ+"DRAFT_ZONE_B"+c(j),"",0,P_Mark,C'160,170,0',3,0,true,false,false,0);
                 }
              }
            else if(TroopA[0]>obj_DraftPrice)
              {

               double D_Full=MathAbs(TroopA[0]-obj_DraftPrice);
               double D=NormalizeDouble(D_Full*Management_ZoneB_getConstant(),Digits);

               double P_Mark=TroopA[0];
               for(int j=0;j<int(1/Management_ZoneB_getConstant());j++)
                 {
                  P_Mark-=D;
                  NormalizeDouble(P_Mark,Digits);
                  HLineCreate_(0,ExtName_OBJ+"DRAFT_ZONE_B"+c(j),"",0,P_Mark,C'160,170,0',3,0,true,false,false,0);
                 }
              }
           }
         else
           {
            //ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_B");
           }
         //
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
            ObjectDelete(0,ExtName_OBJ+"GuideHigh");
            ObjectDelete(0,ExtName_OBJ+"GuideLow");
            ObjectDelete(0,ExtName_OBJ+"GuideLow1");
            ObjectDelete(0,ExtName_OBJ+"GuideLow2");
            ObjectDelete(0,ExtName_OBJ+"GuideBB");
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
      if(ObjGet_SELECTABLE("LINE_ZONE_A"))
        {//Lock
         if(Management_ZoneA_Save(true)<=1)
           {
            ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_B");
           }
         Delete_Pending(OP_BUYLIMIT,1);
         Delete_Pending(OP_BUYSTOP,1);
         Delete_Pending(OP_BUYLIMIT,2);
         Delete_Pending(OP_BUYSTOP,2);
         ObjSet_SELECTABLE("LINE_ZONE_A",false,NameBTN,clrLime);
        }
      else
        {//Lock
         if(ObjGet_Count("LINE_ZONE_A")<=0)
           {
            if(Management_ZoneA_Save(true)<=0)
              {
               ObjectsDeleteAll(0,ExtName_OBJ+"LINE_ZONE_B");
              }

            Delete_Pending(OP_BUYLIMIT,1);
            Delete_Pending(OP_BUYSTOP,1);
            Delete_Pending(OP_BUYLIMIT,2);
            Delete_Pending(OP_BUYSTOP,2);
            ObjSet_SELECTABLE("LINE_ZONE_A",false,NameBTN,clrLime);
           }
         else
           {//unLock
            ObjSet_SELECTABLE("LINE_ZONE_A",true,NameBTN,clrRed);
           }
        }
     }
   return;
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
         // int Size_Wide=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XSIZE);
         // int Size_High=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YSIZE);

         //int XStep=Size_Wide+5;
         // int YStep=Size_High+5;

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
void BTN_Daed_Add(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      double obj_DraftPrice=ObjectGetDouble(0,ExtName_OBJ+"LINE_DeadLine",OBJPROP_PRICE);
      DeadLine=NormalizeDouble(obj_DraftPrice,Digits);
      if(DeadLine==0)
         DeadLine=Bid;
      HLineCreate(0,"LINE_DraftDeadLine","",0,DeadLine,clrMagenta,1,0,0,true,true,false,0);
      //---
      int PlaceTrade=MessageBox("Draw a horizontal line and press OK.","LINE_DraftDeadLine"+l(__LINE__),MB_OKCANCEL|MB_ICONQUESTION);
      if(PlaceTrade==IDOK)
        {
         obj_DraftPrice=ObjectGetDouble(0,"LINE_DraftDeadLine",OBJPROP_PRICE);
         //---
         if(obj_DraftPrice>0)
           {
            if(obj_DraftPrice<TroopA[0])
              {
               HLineCreate_(0,ExtName_OBJ+"LINE_DeadLine","",0,obj_DraftPrice,clrWhite,2,0,false,false,false,0);
               DeadLine=NormalizeDouble(obj_DraftPrice,Digits);
               ObjectDelete(0,"LINE_DraftDeadLine");
               _File_Write();
              }
            else
              {
               PlaceTrade=MessageBox("The line should be outside the price zone.","LINE_DraftDeadLine"+l(__LINE__),MB_OKCANCEL|MB_ICONWARNING);
               ObjectDelete(0,"LINE_DraftDeadLine");
              }
           }
         else
           {
            DeadLine=-1;
            ObjectDelete(0,ExtName_OBJ+"LINE_DeadLine");
            _File_Write();
           }

         //Management_ZoneA_Save(true);
        }
      if(PlaceTrade==IDCANCEL)
        {
         ObjectDelete(0,"LINE_DraftDeadLine");
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
void BTN_DeleteAllPen(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      int PlaceTrade=MessageBox("Want to remove all pending ?",NameBTN,MB_OK|MB_OKCANCEL|MB_ICONQUESTION);
      if(PlaceTrade==IDOK)
        {
         Delete_Pending(OP_BUYLIMIT,1);
         Delete_Pending(OP_BUYSTOP,1);

         Delete_Pending(OP_BUYLIMIT,2);
         Delete_Pending(OP_BUYSTOP,2);
        }
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
void BTN_Report(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      double SumPoint=0,Nav=0;
      //---
      int i,hstTotal=OrdersHistoryTotal();
      for(i=0;i<hstTotal;i++)
        {
         //---- check selection result 
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) continue;
         //if(OrderType()!=OP_BUY) continue;
         //Print(OrderTicket()+" "+OrderType()+" "+OrderProfit());

         Nav+=OrderProfit()+OrderSwap();
         SumPoint+=OrderClosePrice()-OrderOpenPrice();
        }
      SumPoint=NormalizeDouble(SumPoint,Digits);
      SumPoint=SumPoint*MathPow(10,Digits);
      double THB=THB(2);
      //---
      string name,Text=" Harvest Point : "+Comma(SumPoint,0,"_")+"p ~ "+Comma(Nav,2,"_")+" / "+Comma(Nav*THB*100,2,"_")+" USD/THB "+string(THB);
      Print(l(__LINE__)+Text);
      // some work with order 

      int PostX=(int)ObjectGetInteger(0,NameBTN,OBJPROP_XDISTANCE);
      int PostY=(int)ObjectGetInteger(0,NameBTN,OBJPROP_YDISTANCE);
      PostX+=XStep;

      name=ExtName_OBJ+"Text_Report_1";
      ObjectCreText(name,PostX,PostY); PostY+=YStep;
      ObjectSetText(name,Text,10,"Arial",crNumber(SumPoint));
      ObjectSetInteger(ChartID(),name,OBJPROP_HIDDEN,false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_Full_Commt(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
void BTN_AutoEA(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      string btn="On";
      if(boolAutoPending)
         btn="Off";

      //printf(l(__LINE__)+" "+NameBTN);
      if(IsDemo())
        {

         int PlaceTrade=MessageBox("Assigned to automate : "+btn,NameBTN,MB_OK|MB_OKCANCEL|MB_ICONQUESTION);
         if(PlaceTrade==IDOK)
           {
            if(!boolAutoPending)
              {
               if(DeadLine>0)
                 {
                  if(DeadLine<TroopA[0])
                    {
                     boolAutoPending=true;
                     OnTick();

                     ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
                     ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);

                     // IsTradeAllowed()

                    }
                  else
                    {
                     PlaceTrade=MessageBox("DeadLine : "+c(DeadLine,Digits)+"\nBreath line is not available.",NameBTN+l(__LINE__),MB_OK|MB_ICONWARNING);
                    }
                 }
               else
                 {
                  PlaceTrade=MessageBox("DeadLine : "+c(DeadLine,Digits)+"\nDeadLine Not done",NameBTN+l(__LINE__),MB_OK|MB_ICONWARNING);
                 }
              }
            else
              {
               boolAutoPending=false;
               ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
               ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);

               ObjectsDeleteAll(0,ExtName_OBJ+"LINE_Auto");
              }
           }
         if(PlaceTrade==IDCANCEL)
           {
           }
        }
      else
        {
        int PlaceTrade=MessageBox("The program does not work. Contact the developer\nDemo ver.",NameBTN+l(__LINE__),MB_OK|MB_ICONWARNING);
        }
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
      printf(l(__LINE__)+"------------------------------------------ PingAdjustTP");

      int cntFileRead=_File_Read(__LINE__);
      if(cntFileRead>=2)
        {

         Zone_B_cnt=int(1/Management_ZoneB_getConstant());

         ArrayResize(TroopB_PTP,((cntFileRead-1)*Zone_B_cnt)+1,0);

         //printf(l(__LINE__)+ArraySize(PointArray)+"|"+Zone_B_cnt);
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
      //
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if((OrderSymbol()==Symbol())==false) continue;
         if((OrderMagicNumber()==0)==false) continue;

         // printf(l(__LINE__)+OrderTicket());
         double _OrderOpenPrice=OrderOpenPrice();

         for(int i=0;i<ArraySize(TroopB_PTP)-1;i++)
           {
            if(/*(PointArray[i]<_OrderOpenPrice) && */
               (TroopB_PTP[i]<=_OrderOpenPrice && TroopB_PTP[i+1]>_OrderOpenPrice))
              {
               //HLineCreate_(0,ExtName_OBJ+"TP"+c(i),"",0,PointArray[i+1],clrMagenta,3,0,false,false,false,0);
               bool  r;
               int err;
               if(OrderType()<=1)
                 {
                  r=OrderModify(OrderTicket(),OrderOpenPrice(),0,TroopB_PTP[i+1],0);
                  //err=GetLastError();
                  //printf(l(__LINE__)+"|"+OrderTicket()+"|"+r+" | "+err);
                 }
               else
                 {
                  switch(OrderType())
                    {
                     case  OP_BUYSTOP:
                        r=OrderModify(OrderTicket(),TroopB_PTP[i],0,TroopB_PTP[i+1],0);
                        err=GetLastError();
                        //printf(l(__LINE__)+"|"+OrderTicket()+"|"+r+" | "+err);
                        if(err==ERR_INVALID_STOPS)
                          {
                           r=OrderModify(OrderTicket(),OrderOpenPrice(),0,TroopB_PTP[i+1],0);
                           err=GetLastError();
                           //printf(l(__LINE__)+"|"+OrderTicket()+"|"+r+" | "+ERR_INVALID_STOPS+"|"+err);
                          }

                        break;
                     case  OP_BUYLIMIT:
                        r=OrderModify(OrderTicket(),TroopB_PTP[i],0,TroopB_PTP[i+1],0);
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
      printf(l(__LINE__)+"------------------------------------------ PingAdjustTP end");
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_CS_Auto_RSI(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      int _iRSI_windex=WindowFind("RSI("+c(Auto_RSI_period)+")");
      printf(l(__LINE__,"_iRSI_windex")+_iRSI_windex);
      HLineCreate(0,ExtName_OBJ+"LINE__iRSI_Base","",_iRSI_windex,Detect_Trend_RSI,clrRed,2,0,false,true,true,false,0);
      //---
      int PlaceTrade=MessageBox("Draw a horizontal line and press OK.","LINE_DraftDeadLine"+l(__LINE__),MB_OKCANCEL|MB_ICONQUESTION);
      if(PlaceTrade==IDOK)
        {
         Detect_Trend_RSI=ObjectGetDouble(0,ExtName_OBJ+"LINE__iRSI_Base",OBJPROP_PRICE);
         Detect_Trend_RSI=NormalizeDouble(Detect_Trend_RSI,4);
         Detect_Trend_TimeFrame=Period();

         ObjectSetInteger(0,ExtName_OBJ+"LINE__iRSI_Base",OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,ExtName_OBJ+"LINE__iRSI_Base",OBJPROP_SELECTED,false);
        }
      if(PlaceTrade==IDCANCEL)
        {
         ObjectSetInteger(0,ExtName_OBJ+"LINE__iRSI_Base",OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,ExtName_OBJ+"LINE__iRSI_Base",OBJPROP_SELECTED,false);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_CS_Buy_B(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {

      int PlaceTrade=MessageBox("Want to open an order by yourself?","BTN_CS_Buy_B"+l(__LINE__),MB_OKCANCEL|MB_ICONQUESTION);
      if(PlaceTrade==IDOK)
        {
         double lot=NormalizeDoubleCut(LotGet(Capital,Ask,DeadLine),2);
         if(lot>0)
           {
            bool Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,0,"H_"+c(Capital,2)+l(__LINE__),2,0);
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

      Management_ZoneB_Draw(__LINE__);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color crNumber(double v)
  {
   return (v>=0)?clrLime:clrRed;
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
color clr_BTN_AutoEA(bool v)
  {
   if(!v)
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
//|                                                                  |
//+------------------------------------------------------------------+
int Size_Wide=70;
int Size_High=17;
int PostX_Default=10,XStep=Size_Wide+5;
int PostY_Default=15,YStep=Size_High+5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_init()
  {
   ObjectDelete(0,ExtName_OBJ+"LINE_DraftLineA");
   ObjectsDeleteAll(0,ExtName_OBJ+"DRAFT_ZONE_B");

   int PostX=PostX_Default;
   int PostY=PostY_Default;



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
   PostX=10+Size_Wide+5;PostY=PostY_Default;
   ObjectCreText(ExtName_OBJ+"Head_2",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_2","Zone B",10,"Arial",clrWhite);

   _setBUTTON(ExtName_OBJ+"BTN_B_Hide",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_ShowZoneB(),"Show");PostY+=YStep;
//+------------------------------------------------------------------+
   if(boolZoneB_Show)
     {
      //_setBUTTON(ExtName_OBJ+"BTN_B_Select",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRed,"Select");PostY+=YStep;
      _setBUTTON(ExtName_OBJ+"BTN_B_clrDW",windex,CORNER_LEFT_UPPER,int(Size_Wide*0.45),Size_High,PostX,PostY,false,10,clrBlack,clrRed,"-");
      _setBUTTON(ExtName_OBJ+"BTN_B_clrUP",windex,CORNER_LEFT_UPPER,int(Size_Wide*0.45),Size_High,int(PostX+(Size_Wide*0.55)),PostY,false,10,clrBlack,clrLime,"+");PostY+=YStep;

     }
//---
   PostX=PostX_Default+(Size_Wide+5)*2;PostY=PostY_Default;
   ObjectCreText(ExtName_OBJ+"Head_3",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_3","Breath",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_Daed_Add",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrMagenta,"Add&Edit");PostY+=YStep;
//_setBUTTON(ExtName_OBJ+"BTN_Breath_CallFill",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrLime,"Will top-up");PostY+=YStep;

//---
   PostX=PostX_Default+(Size_Wide+5)*3;PostY=PostY_Default;
   ObjectCreText(ExtName_OBJ+"Head_4",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_4","Price Order",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_Price_Hide",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_Price_Hide(),"Show");PostY+=YStep;
//---
/*
   PostX=PostX_Default+(Size_Wide+5)*4;PostY=PostY_Default;
   ObjectCreText(ExtName_OBJ+"Head_5",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_5","CS",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_CS_AdjustTP",windex,CORNER_LEFT_UPPER,Size_Wide*2+5,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_Price_Hide(),"AdjustTP");PostY+=YStep;
   _setBUTTON(ExtName_OBJ+"BTN_CS_Auto_RSI",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,9,clrBlack,clr_BTN_AutoEA(Auto_RSI),"setRSI("+c(Auto_RSI_period)+")");PostY+=YStep;
*/
//---
/*
   PostX=PostX_Default+(Size_Wide+5)*5;PostY=PostY_Default;
   ObjectCreText(ExtName_OBJ+"Head_6",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_6","CS2",10,"Arial",clrWhite);PostY+=YStep;
*/
//---
   PostX=PostX_Default+(Size_Wide+5)*5;PostY=PostY_Default;
   ObjectCreText(ExtName_OBJ+"Head_7",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_7","Auto Mate",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_AutoEA",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clr_BTN_AutoEA(boolAutoPending),"EA");PostY+=YStep;
   _setBUTTON(ExtName_OBJ+"BTN_DeleteAllPen",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRoyalBlue,"Del-AllPen");PostY+=YStep;
//_setBUTTON(ExtName_OBJ+"BTN_CS_Buy_B",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrRoyalBlue,"Buy B");PostY+=YStep;

/*
   PostX=PostX_Default+(Size_Wide+5)*6;PostY=PostY_Default;
   ObjectCreText(ExtName_OBJ+"Head_8",PostX,PostY);PostY+=YStep;
   ObjectSetText(ExtName_OBJ+"Head_8","Report",10,"Arial",clrWhite);
   _setBUTTON(ExtName_OBJ+"BTN_Report",windex,CORNER_LEFT_UPPER,Size_Wide,Size_High,PostX,PostY,false,10,clrBlack,clrYellow,"Report");PostY+=YStep;
*/
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BTN_Breath_CallFill(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {
      if(ObjectGetInteger(0,NameBTN,OBJPROP_STATE))
        {
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrRed);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrRed);

         NavagateLine();
         HLineCreate_(0,ExtName_OBJ+"LINE_DraftBreathFill","",0,WostPrice_Sigh,clrRed,1,0,0,true,false,0);
        }
      else
        {
         ObjectSetInteger(0,NameBTN,OBJPROP_BGCOLOR,clrLime);
         ObjectSetInteger(0,NameBTN,OBJPROP_BORDER_COLOR,clrLime);
         ObjectSetString(0,NameBTN,OBJPROP_TEXT,"Will top-up");

         ObjectDelete(0,ExtName_OBJ+"LINE_DraftBreathFill");
         ObjectDelete(0,"Label_DraftBreathFill");

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LINE_DraftBreathFill(string sparam,string NameBTN)
  {
   NameBTN=ExtName_OBJ+NameBTN;
   if(sparam==NameBTN)
     {

      double obj_Draft=ObjectGetDouble(0,ExtName_OBJ+"LINE_DraftBreathFill",OBJPROP_PRICE);
      NormalizeDouble(obj_Draft,Digits);
      if(obj_Draft>0)
        {
         NavagateLine();
         double dWAvg=MathAbs(WostPrice_WAvg-obj_Draft);
         //---
         double ACC_BALANCE=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2);
         double ACC_CREDIT=NormalizeDouble(AccountInfoDouble(ACCOUNT_CREDIT),2);
         double ACC_MARGIN=NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN),2);
         double ACC_Have=NormalizeDouble((ACC_BALANCE+ACC_CREDIT)-ACC_MARGIN,2);
         //---
         double Have=NormalizeDouble((dWAvg/WostPrice_WAvg)*ContractSize*WostLot_sum,2);
         //---
         double Require=NormalizeDouble(ACC_Have-Have,2);
         //---
         color clrTag=clrWhite;
         if(Require<0)clrTag=clrTomato;

         string _ACCOUNT_CURRENCY=AccountInfoString(ACCOUNT_CURRENCY);
         string Text="** Should top-up: "+c(Require,2)+" "+_ACCOUNT_CURRENCY;
         //---
         int bar=int(ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0));
         int x,y,fontSize=8;
         ChartTimePriceToXY(0,0,Time[bar],obj_Draft,x,y);
         LabelCreate(0,"Label_DraftBreathFill",0,x+10,y,0,Text,"",fontSize,clrTag,0,false,false,false,0);
         //---
         Text=c(Require,2)+" "+_ACCOUNT_CURRENCY;
         string NameBTN2=ExtName_OBJ+"BTN_Breath_CallFill";
         ObjectSetString(0,NameBTN2,OBJPROP_TEXT,Text);
         ObjectSetInteger(0,NameBTN2,OBJPROP_FONTSIZE,fontSize);
         ObjectSetInteger(0,NameBTN2,OBJPROP_BGCOLOR,clrTag);
         ObjectSetInteger(0,NameBTN2,OBJPROP_BORDER_COLOR,clrTag);

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID 
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
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0)                // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create a text label 
   ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0);

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
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  THB(int digit)
  {
//+------------------------------------------------------------------+
   string Url="https://themoneyconverter.com/USD/THB.aspx";
   string getOpenURL="thai/url_USD_THB.html";
   iMqlNet.Open(Url,8080);
   iMqlNet.OpenURL(Url,getOpenURL,false);
//+------------------------------------------------------------------+
   string strStart="<td id=\"THB\">",strEnd="</td>";
   int iStart=StringFind(getOpenURL,strStart);
   string THB=StringSubstr(getOpenURL,iStart+StringLen(strStart));
   int iEnd=StringFind(THB,strEnd);
   THB=(iEnd!=0)?StringSubstr(THB,0,iEnd):"";

   string result[];
   int k=StringSplit(THB,StringGetCharacter(".",0),result);

   if(k>=2)
     {
      THB=(digit==0)?
          THB=result[0]:
          THB=result[0]+"."+StringSubstr(result[1],0,digit);
     }
   else
     {
      THB=result[0];
     }
   return double(THB);
  }
//+------------------------------------------------------------------+
