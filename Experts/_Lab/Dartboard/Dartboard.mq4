//+------------------------------------------------------------------+
//|                                                    Dartboard.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Tools/Method_Tools.mqh>
#include <Controls/Button.mqh>

#include "OnChartEvent.mq4"
#include "MQL_Tools.mq4"
#include "Dartboard_Enum.mq4"
//#include "NavagateLine.mqh"
//---
extern bool SHOW_TRADE=true;

extern double Budget=5;

extern double Rate_TP=1;
extern double Rate_SL=3;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ExtName_OBJ="Dartboard";
bool Show_LN_COMMAN=true;
string CUR_unit=" "+AccountInfoString(ACCOUNT_CURRENCY);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetMillisecondTimer(1000);
//---

   OnTick();
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
   OnTimer();
   Element_Draw(false);

   double  MeshSL=ObjectGetDouble(0,ObjCMD(CMD_LINE_MeshSL,0),OBJPROP_PRICE);

   if(MeshSL>0)
     {
      double  Mesh=ObjectGetDouble(0,ObjCMD(CMD_LINE_Mesh,0),OBJPROP_PRICE);
      double  MeshTP=0;//ObjectGetDouble(0,ObjCMD(CMD_LINE_MeshTP,0),OBJPROP_PRICE);

      double d=MathAbs(NormalizeDouble(MeshSL-Mesh,Digits));
      double v=(d/Rate_SL)*Rate_TP;

      int clrMesh=-1;
      if(MeshSL<Bid)
        {
         Mesh=Ask;
         MeshTP=Mesh+v;
         MeshSL=Mesh-d;

         clrMesh=OP_BUY;
        }
      else if(MeshSL>Bid)
        {
         Mesh=Bid;
         MeshTP=Mesh-v;
         MeshSL=Mesh+d;

         clrMesh=OP_SELL;
        }

      HLineCreate(0,ObjCMD(CMD_LINE_Mesh,0),"",0,Mesh,clrLineOrder(clrMesh),0,2,false,false,false,false,0);
      HLineCreate(0,ObjCMD(CMD_LINE_MeshTP,0),"",0,MeshTP,clrLime,2,0,false,true,true,false,0);
      HLineCreate(0,ObjCMD(CMD_LINE_MeshSL,0),"",0,MeshSL,clrRed,2,0,false,true,true,false,0);
     }
//---

//---

//---

//NavagateLine();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ObjectsDeleteAll(0,ExtName_OBJ+"_"+string(CMD_LINE)+"_",0,OBJ_HLINE);
   for(int pos=0;pos<OrdersTotal() && Show_LN_COMMAN;pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()!=Symbol()) continue;
      HLineCreate(0,ObjCMD(CMD_LINE,OrderTicket()),"",0,OrderOpenPrice(),clrLineOrder(OrderType()),3,0,true,false,false,false,0);
     }
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
//|                                                                  |
//+------------------------------------------------------------------+
void Element_Draw(int dx,int dy,int TICKET,int OP_DIR,bool reDraw)
  {
   int   sub_window;datetime  time;double price; bool  res;
   res=ChartXYToTimePrice(0,dx,dy,sub_window,time,price);
   int x=0,y=0,X=0,Y=0;
   res=ChartTimePriceToXY(0,sub_window,time,OrderOpenPrice(),x,y);
   X=x;
   Y=y;
//---

//---
   string Text="";
//if(OrderSelect(TICKET,SELECT_BY_TICKET,MODE_TRADES)==true)
   if(OrderSelectFind(TICKET))
     {
      //---
      int StepX=14;
      int StepY=14;
      //---
      if(OP_DIR==OP_BUY || OP_DIR==OP_BUYLIMIT || OP_DIR==OP_BUYSTOP)
         y=y-2;
      if(OP_DIR==OP_SELL || OP_DIR==OP_SELLLIMIT || OP_DIR==OP_SELLSTOP)
         y=y-StepY-2;
      //---
      ObjectCreText(0,ObjCMD(CMD_MENU,TICKET),x,y,false);
      ObjectSetText(ObjCMD(CMD_MENU,TICKET),Text,0,"Arial",clrNONE);

      //---
      double _OrderSwap=OrderSwap();
      string _strOrderSwap="";
      if(_OrderSwap!=0)
         _strOrderSwap="["+c(_OrderSwap,2)+"] ";
      //
      double Distand=DistandPoint(OrderType(),OrderOpenPrice());
      Text=Comma(OrderProfit(),2," ")+_strOrderSwap+CUR_unit+" | "+Comma(Distand,0," ")+"p";
      //---
      _EditCreate(ObjCMD(CMD_INFO_Lot,TICKET),0,c(OrderLots(),2),reDraw,false,x,y,50,OBJ_SizeY,"Arial",8,ALIGN_CENTER,CORNER_LEFT_UPPER,clrLineOrder(OP_DIR),clrWhite,clrLineOrder(OP_DIR),false,false,false,0);x+=50;

      setBUTTON_(ObjCMD(CMD_INFOTEXT,TICKET),0,150,OBJ_SizeY,x,y,true,8,clrWhite,clrLineOrder(OP_DIR),false,Text);x+=150;
      setBUTTON_(ObjCMD(CMD_INFO,TICKET),0,OBJ_SizeY_ic,OBJ_SizeY_ic,x,y,true,7,clrBlack,clrWhite,false,"i");x+=StepX;
      setBUTTON_(ObjCMD(CMD_MENUClose,TICKET),0,OBJ_SizeY_ic,OBJ_SizeY_ic,x,y,true,7,clrBlack,clrRed,false,"x");x+=StepX;

      if(ObjectFind(0,ObjCMD(CMD_Order_CloseAndDelete,TICKET))>=0)
        {
         y+=OBJ_SizeX;
         //
         double Edito_Lot=StringToDouble(ObjectGetString(0,ObjCMD(CMD_INFO_Lot,TICKET),OBJPROP_TEXT,0));
         double P2=(OrderProfit()/OrderLots())*Edito_Lot;
         double Ratio=Edito_Lot/OrderLots()*100;

         Text=Comma(P2,2," ")+CUR_unit;
         setBUTTON_(ObjCMD(CMD_Order_CloseAndDelete,TICKET),0,150,OBJ_SizeX,X+50,y,true,8,clrLineOrder_Profit(P2),clrWhite,false,Comma(P2,2," ")+CUR_unit+" | "+Comma(Ratio,2,"")+"%");
        }
      //CMD_LINE_SL_FIBO= 92,
      if(ObjectFind(0,ObjCMD(CMD_LINE_TP_FIBO,TICKET))>=0)
        {

        }

      //ObjectCreText(0,ObjCMD(CMD_INFOTEXT,TICKET),x,y,false);
      //ObjectSetText(ObjCMD(CMD_INFOTEXT,TICKET),Text,8,"Arial",clrWhite);
     }
   else
     {
      Element_Delete(string(TICKET));
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Element_Delete(string TICKET)
  {
   ulong list[]=
     {
      CMD_MENU,
      CMD_INFO,CMD_INFO_Lot,CMD_MENUClose,
      CMD_LINE_TP,CMD_LINE_SL,
      CMD_LINE_TP_FIBO,CMD_LINE_SL_FIBO,
      CMD_INFOTEXT,
      CMD_Order_CloseAndDelete
     };
//---
   if(TICKET!="")
     {
      for(int i=0;i<ArraySize(list);i++)
         ObjectDelete(0,ObjCMD(list[i],int(TICKET)));
     }
   else
     {
      ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_BUTTON);
      ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_LABEL);
      ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_FIBO);
      ObjectsDeleteAll(0,ExtName_OBJ,0,OBJ_EDIT);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Element_Draw(bool reDraw)
  {
   for(int i=0;i<ObjectsTotal();i++)
     {
      string name=ObjectName(i);
      if(StringFind(name,ExtName_OBJ,0)>=0)
        {
         string sep="_",result[];
         ushort  u_sep=StringGetCharacter(sep,0);
         int k=StringSplit(name,u_sep,result);

         if(ObjectFind(0,ObjCMD(CMD_MENU,int(result[LN_TICKET])))==0)
           {
            int TICKET=StrToInteger(result[LN_TICKET]);
            //if(OrderSelect(TICKET,SELECT_BY_TICKET,MODE_TRADES)==true)
            if(OrderSelectFind(TICKET))
              {
               if(OrderSymbol()!=Symbol())
                  Element_Delete("");
               else
                 {
                  int PostX=(int)ObjectGetInteger(0,ObjCMD(CMD_MENU,TICKET),OBJPROP_XDISTANCE);
                  int PostY=(int)ObjectGetInteger(0,ObjCMD(CMD_MENU,TICKET),OBJPROP_YDISTANCE);
                  //---
                  Element_Draw(PostX,PostY,TICKET,OrderType(),reDraw);
                 }
              }
            else
              {
               Element_Delete(result[LN_TICKET]);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DistandPoint(int type,double OP)
  {
   double r=(Bid-OP)*MathPow(10,Digits);
   if(type==OP_SELL)
      r=(OP-Ask)*MathPow(10,Digits);
   return NormalizeDouble(r,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Element_DrawFiboTPSL(int TICKET,int Cm,int OP_DIR,double lots,double T1,double T2,color clr)
  {
   double   values[]={0,0.236,0.618,1};
//---
   int dx=(int)ObjectGetInteger(0,ObjCMD(CMD_MENU,TICKET),OBJPROP_XDISTANCE);
   int dy=(int)ObjectGetInteger(0,ObjCMD(CMD_MENU,TICKET),OBJPROP_YDISTANCE);
   int sub_window;datetime  time;double price; bool  res;
   res=ChartXYToTimePrice(0,dx,dy,sub_window,time,price);
   int x=0,y=0;
   res=ChartTimePriceToXY(0,sub_window,time,OrderOpenPrice(),x,y);
//  
   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS),fond=-1;
   datetime date[];
   CopyTime(Symbol(),Period(),0,bars,date);
   for(int i=0;i<ArraySize(date);i++)
      if(date[i]==time)
        {
         fond=i;  break;
        }
   datetime  time2=date[fond+2];
   if(fond==-1) time2=time+(date[0]-date[2]);
//
   _FiboLevelsCreate(0,ObjCMD(Cm,TICKET),0,time,T2,time2,T1
                     ,clrNONE,0,0,true,false,false,false,false,10);
//
   _FiboLevelsSet(0,Cm,ObjCMD(Cm,TICKET),values,clr,OP_DIR,lots,T1,T2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Element_DrawLineTPSL(int TICKET,int OP_DIR,double lots,double OP,double TP,double SL)
  {
   OP=NormalizeDouble(OP,Digits);
   TP=NormalizeDouble(TP,Digits);
   SL=NormalizeDouble(SL,Digits);
   if(OrderStopLoss()>0)
     {
      Element_DrawFiboTPSL(TICKET,CMD_LINE_SL_FIBO,OP_DIR,lots,OP,SL,clrRed);
      //HLineCreate(0,ObjCMD(CMD_LINE_SL,TICKET),"",0,SL,clrRed,2,0,true,false,false,false,0);
     }
   if(OrderTakeProfit()>0)
     {
      Element_DrawFiboTPSL(TICKET,CMD_LINE_TP_FIBO,OP_DIR,lots,OP,TP,clrLime);
      //HLineCreate(0,ObjCMD(CMD_LINE_TP,TICKET),"",0,TP,clrLime,2,0,true,false,false,false,0);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderSelectFind(int Ticket)
  {
   bool r=false;
   for(int pos=0;pos<OrdersTotal() && Show_LN_COMMAN;pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderTicket()==Ticket)
        {
         r=true;
         break;
        }
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _Pin_Capital=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  LotGet(double cap0,double Traget_1,double Traget_2)
  {
   string _ACCOUNT=AccountInfoString(ACCOUNT_CURRENCY);
   string _SYMBOL_1=StringSubstr(Symbol(),0,3);
   string _SYMBOL_2=StringSubstr(Symbol(),3,3);
   double cap=CoverCurrency(cap0,_ACCOUNT,_SYMBOL_1);
   printf(l(__LINE__)+cap0+" "+_ACCOUNT+" | "+cap+" "+_SYMBOL_1);
//---

//double Magin=getMagin(double bid,double lots);
   double D=NormalizeDouble(Traget_2-Traget_1,Digits);
   double Lot=(cap*Traget_1)/(D*ContractSize);
   Lot=MathAbs(Lot);

   Lot=NormalizeDouble(Lot,2);

   _Pin_Capital=(Lot/Traget_1)*(D*ContractSize);
   _Pin_Capital=MathAbs(_Pin_Capital);
   _Pin_Capital=CoverCurrency(_Pin_Capital,_SYMBOL_1,_ACCOUNT);

   printf("lots: "+c(Lot,2));

   return Lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CoverCurrency(double cap,string c1,string c2)
  {
   double r=0;
   if(c1==c2)
     {
      r=cap;
     }
   else
     {
      string Pair_1=c1+c2;
      string Pair_2=c2+c1;
      double Rate_1=MarketInfo(Pair_1,MODE_BID);
      double Rate_2=MarketInfo(Pair_2,MODE_BID);

      if(Rate_1>0)
        {
         r=cap*Rate_1;
         r=NormalizeDouble(r,MarketInfo(Rate_1,MODE_DIGITS));
        }
      else if(Rate_2>0)
        {
         r=cap/Rate_2;
         r=NormalizeDouble(r,MarketInfo(Pair_2,MODE_DIGITS));
        }
     }

   return NormalizeDoubleCut(r,2);
  }
//+------------------------------------------------------------------+
double NormalizeDoubleCut(double v,int Digit)
  {
   v=NormalizeDouble(v,Digit);
   string str=DoubleToString(v);
//printf(l(__LINE__)+str);

   string sep=".",resultDigit[];
   ushort  u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(str,u_sep,resultDigit);

//printf("ArraySize :"+ArraySize(resultDigit));
   if(ArraySize(resultDigit)>=2)
     {
      resultDigit[1]=StringSubstr(resultDigit[1],0,Digit);
     }
//return double("0."+resultDigit[1]);
   double r=double(resultDigit[0])+double("0."+resultDigit[1]);
   return r;

  }
//+------------------------------------------------------------------+
