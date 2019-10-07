//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Dartboard.mq4"
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   OnEvent_CLICK(id,lparam,dparam,sparam);
   OnEvent_OBJECT_CLICK(id,lparam,dparam,sparam);      //******
   OnEvent_CHART_CHANGE(id,lparam,dparam,sparam);
   OnEvent_KEYDOWN(id,lparam,dparam,sparam);           //******
   OnEvent_OBJECT_DRAG(id,lparam,dparam,sparam);       //******
   OnEvent_OBJECT_ENDEDIT(id,lparam,dparam,sparam);
//+------------------------------------------------------------------+
   ChartRedraw();
  }
//+------------------------------------------------------------------+
void OnEvent_CLICK(int id,long lparam,double dparam,string sparam)
  {
   if(id==CHARTEVENT_CLICK)
     {
      //Print("CHARTEVENT_CLICK : x = ",lparam,"  y = ",dparam);
      if(MeshWaiting)
        {
         int sub_window;datetime  time;double price; bool  res;
         res=ChartXYToTimePrice(0,int(lparam),int(dparam),sub_window,time,price);
         //---
         //double UnitPoint=150/MathPow(10,Digits);

         //
         double Price_TP=price;
         double Price_SL=price;
         //---

         HLineCreate(0,ObjCMD(CMD_LINE_Mesh,0),"",0,price,clrWhite,2,0,true,true,true,false,0);
         HLineCreate(0,ObjCMD(CMD_LINE_MeshTP,0),"",0,price,clrYellow,2,0,true,true,true,false,0);
         HLineCreate(0,ObjCMD(CMD_LINE_MeshSL,0),"",0,price,clrYellow,2,0,true,true,true,false,0);
         MeshWaiting=false;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnEvent_OBJECT_CLICK(int id,long lparam,double dparam,string sparam)
  {
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      Print("CHARTEVENT_OBJECT_CLICK["+sparam+"]");
      //---
      if(StringFind(sparam,ExtName_OBJ,0)>=0)
        {
         string sep="_",result[];
         ushort  u_sep=StringGetCharacter(sep,0);
         int k=StringSplit(sparam,u_sep,result);
         //for(int i=0;i<ArraySize(result);i++)
         //  {
         //   Print(l(__LINE__)+result[i]);
         //  }
         //---
         int TICKET=StrToInteger(result[LN_TICKET]);
         switch(int(result[LN_COMMAN]))
           {
            case CMD_LINE:
              {
               if(OrderSelect(TICKET,SELECT_BY_TICKET,MODE_TRADES)==true)
                 {
                  Element_Draw(int(lparam),int(dparam),TICKET,OrderType(),true);
                  //---
                  if(ObjectGetInteger(0,ObjCMD(CMD_INFO,TICKET),OBJPROP_STATE))
                     Element_DrawLineTPSL(TICKET,OrderType(),OrderLots(),OrderOpenPrice(),OrderTakeProfit(),OrderStopLoss());
                 }
               break;
              }
            case CMD_INFO://1
              {
               if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
                 {
                  if(OrderSelect(TICKET,SELECT_BY_TICKET,MODE_TRADES)==true)
                    {
                     Element_DrawLineTPSL(TICKET,OrderType(),OrderLots(),OrderOpenPrice(),OrderTakeProfit(),OrderStopLoss());
                    }
                 }
               else
                 {
                  ObjectDelete(0,ObjCMD(CMD_LINE_SL,int(result[LN_TICKET])));
                  ObjectDelete(0,ObjCMD(CMD_LINE_TP,int(result[LN_TICKET])));

                  ObjectDelete(0,ObjCMD(CMD_LINE_TP_FIBO,int(result[LN_TICKET])));
                  ObjectDelete(0,ObjCMD(CMD_LINE_SL_FIBO,int(result[LN_TICKET])));
                 }
               break;
              }
            case CMD_MENUClose:
              {
               Element_Delete(result[LN_TICKET]);
               break;
              }
            case CMD_INFOTEXT:
              {
               if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
                 {
                  int dx=(int)ObjectGetInteger(0,ObjCMD(CMD_MENU,TICKET),OBJPROP_XDISTANCE);
                  int dy=(int)ObjectGetInteger(0,ObjCMD(CMD_MENU,TICKET),OBJPROP_YDISTANCE);
                  dy+=OBJ_SizeX;
                  //---
                  double Edito_Lot=StringToDouble(ObjectGetString(0,ObjCMD(CMD_INFO_Lot,TICKET),OBJPROP_TEXT,0));
                  double P2=(OrderProfit()/OrderLots())*Edito_Lot;
                  double Ratio=Edito_Lot/OrderLots()*100;

                  setBUTTON_(ObjCMD(CMD_Order_CloseAndDelete,TICKET),0,150,OBJ_SizeX,dx+50,dy,true,8,clrLineOrder_Profit(P2),clrWhite,false,Comma(P2,2," ")+CUR_unit+" | "+Comma(Ratio,2,"")+"%");
                 }
               else
                 {
                  ObjectDelete(0,ObjCMD(CMD_Order_CloseAndDelete,TICKET));
                 }
               break;
              }
            case CMD_Order_CloseAndDelete://300
              {
               int PlaceTrade=MessageBox("Want to close orders?",EnumToString(CMD_Order_CloseAndDelete)+l(__LINE__),MB_OKCANCEL|MB_ICONQUESTION);
               if(PlaceTrade==IDOK)
                 {
                  if(OrderSelectFind(TICKET))
                    {
                     if(OrderSelect(TICKET,SELECT_BY_TICKET,MODE_TRADES)==true)
                       {
                        double xPrice=Ask;
                        if(OrderType()==OP_BUY) xPrice=Bid;
                        //---
                        double Edito_Lot=StringToDouble(ObjectGetString(0,ObjCMD(CMD_INFO_Lot,TICKET),OBJPROP_TEXT,0));
                        double Order_Lot=OrderLots();
                        //---
                        bool res=false;
                        if(Edito_Lot<=Order_Lot)
                          {
                           res=OrderClose(TICKET,Edito_Lot,xPrice,5);
                          }
                        if(res)
                          {
                           ObjectDelete(0,ObjCMD(CMD_Order_CloseAndDelete,TICKET));
                           //---
                           if(OrderSelect(TICKET,SELECT_BY_TICKET,MODE_TRADES)==true)
                             {
                              //---
                              string _OrderComment=OrderComment();
                              StringReplace(_OrderComment,"to #","");
                              int TICKET_2=int(_OrderComment);
                              printf("["+_OrderComment+"]");
                              //---
                              if(OrderSelect(TICKET_2,SELECT_BY_TICKET,MODE_TRADES)==true)
                                {
                                 Element_Draw(int(lparam),int(dparam),TICKET_2,OrderType(),true);
                                }
                             }
                           //---
                          }
                       }
                    }
                 }
               break;
              }
            default:
               break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnEvent_CHART_CHANGE(int id,long lparam,double dparam,string sparam)
  {
   if((id==CHARTEVENT_CHART_CHANGE))
     {
      Element_Draw(false);
     }
  }
//+------------------------------------------------------------------+
void OnEvent_KEYDOWN(int id,long lparam,double dparam,string sparam)
  {
   if(id==CHARTEVENT_KEYDOWN)
     {
      Print("The "+c(lparam)+" has been pressed");
      switch(int(lparam))
        {
         case 81://Q
           {
            if(Show_LN_COMMAN)
              {
               Show_LN_COMMAN=false;
               Element_Delete("");
              }
            else
               Show_LN_COMMAN=true;
            OnTimer();
            break;
           }
         case 87://W
           {
            if(ChartGetInteger(0,CHART_SHOW_TRADE_LEVELS,0))
               ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,false);
            else
               ChartSetInteger(0,CHART_SHOW_TRADE_LEVELS,0,true);
            ChartRedraw();
            break;
           }
         case 77://M
           {
            if(ObjectFind(0,ObjCMD(CMD_LINE_MeshTP,0))>=0)
              {
               ObjectDelete(0,ObjCMD(CMD_LINE_Mesh,0));
               ObjectDelete(0,ObjCMD(CMD_LINE_MeshTP,0));
               ObjectDelete(0,ObjCMD(CMD_LINE_MeshSL,0));
               ObjectDelete(0,ObjCMD(CMD_EDIT_MeshBudget,0));
              }
            else
              {
               _EditCreate(ObjCMD(CMD_EDIT_MeshBudget,0),0,c(Budget,2),true,false,80,OBJ_SizeY+20,70,OBJ_SizeY+10,"Arial",10,ALIGN_CENTER,CORNER_RIGHT_LOWER,clrBlack,clrWhite,clrBlack,false,false,false,0);
               HLineCreate(0,ObjCMD(CMD_LINE_MeshTP,0),"",0,Bid,clrLime,2,0,false,true,true,false,0);
              }
            break;
           }
         case 188://<
           {
            if(ObjectFind(0,ObjCMD(CMD_LINE_MeshTP,0))>=0)
              {
               int PlaceTrade=MessageBox("Want to open an order?","Press '<' "+l(__LINE__),MB_YESNO || MB_ICONQUESTION);
               if(PlaceTrade==IDOK)
                 {
                  int  OP_DIR=int(ObjectGetString(0,ObjCMD(CMD_LINE_Mesh,0),OBJPROP_TOOLTIP));

                  double  Mesh=ObjectGetDouble(0,ObjCMD(CMD_LINE_Mesh,0),OBJPROP_PRICE);
                  double  MeshTP=ObjectGetDouble(0,ObjCMD(CMD_LINE_MeshTP,0),OBJPROP_PRICE);
                  double  MeshSL=ObjectGetDouble(0,ObjCMD(CMD_LINE_MeshSL,0),OBJPROP_PRICE);
                  //---
                  double lots=LotGet(Budget,Mesh,MeshSL);
                  int res=-2;

                  if(lots>0.01)
                    {
                     //printf(Mesh+"|"+Ask);
                     res=OrderSend(Symbol(),OP_DIR,lots,Mesh,10,MeshSL,MeshTP,"",0);
                     GetLastErrorStr(GetLastError());
                    }
                  //printf(l(__LINE__,"res")+c(res));
                  if(res>0)
                    {
                     ObjectDelete(0,ObjCMD(CMD_LINE_Mesh,0));
                     ObjectDelete(0,ObjCMD(CMD_LINE_MeshTP,0));
                     ObjectDelete(0,ObjCMD(CMD_LINE_MeshSL,0));
                    }
                  OnTick();
                 }
              }
            break;
           }
         case 78://N
           {
            if(MeshWaiting)
              {
               MeshWaiting=false;
               Element_Delete("");
              }
            else
               MeshWaiting=true;
            printf(l(__LINE__,"MeshWaiting")+c(MeshWaiting));
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
void OnEvent_OBJECT_DRAG(int id,long lparam,double dparam,string sparam)
  {
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      Print("CHARTEVENT_OBJECT_DRAG["+sparam+"]");
      if(StringFind(sparam,ExtName_OBJ,0)>=0)
        {
         string sep="_",result[];
         ushort  u_sep=StringGetCharacter(sep,0);
         int k=StringSplit(sparam,u_sep,result);
         //---
         double  MeshTP=ObjectGetDouble(0,ObjCMD(CMD_LINE_MeshTP,0),OBJPROP_PRICE);
         double  MeshSL=ObjectGetDouble(0,ObjCMD(CMD_LINE_MeshSL,0),OBJPROP_PRICE);

/*     //
      double Price_TP=price;
      double Price_SL=price;*/
         //---

         switch(int(result[LN_COMMAN]))
           {
            case  CMD_LINE_MeshTP:
              {
               //printf(l(__LINE__,"CMD_LINE_MeshTP"));
               int clrMesh=-1;
               double d=-1,v=-1,Price_Mesh=-1,Price_Mesh2=-1;

               //---
               if(MeshTP>Bid)
                 {
                  Price_Mesh=Ask;

                  d=MathAbs(MeshTP-Price_Mesh);
                  v=(d/Rate_TP)*Rate_SL;
                  Price_Mesh2=Price_Mesh-v;

                  clrMesh=OP_BUY;
                 }
               else if(MeshTP<Bid)
                 {
                  Price_Mesh=Bid;

                  d=MathAbs(MeshTP-Price_Mesh);
                  v=(d/Rate_TP)*Rate_SL;
                  Price_Mesh2=Price_Mesh+v;

                  clrMesh=OP_SELL;
                 }
               //---
               HLineCreate(0,ObjCMD(CMD_LINE_Mesh,0),c(clrMesh),0,Price_Mesh,clrLineOrder(clrMesh),0,2,false,false,false,false,0);
               HLineCreate(0,ObjCMD(CMD_LINE_MeshSL,0),"",0,Price_Mesh2,clrRed,2,0,false,true,true,false,0);

               //double _Budget=StringToDouble(ObjectGetString(0,ObjCMD(CMD_EDIT_MeshBudget,0),OBJPROP_TEXT,0));
               double Lots=LotGet(Budget,Price_Mesh,Price_Mesh2);
               color clrBudget=clrBlack;
               if(_Pin_Capital>Budget) clrBudget=clrRed;
               
               _EditCreate(ObjCMD(CMD_EDIT_MeshBudget,0),0,c(_Pin_Capital,2),true,false,150+10,OBJ_SizeY+20,150,OBJ_SizeY+10,"Arial",10,ALIGN_CENTER,CORNER_RIGHT_LOWER,clrBudget,clrWhite,clrBudget,false,false,false,0);

               break;
              }
            case  CMD_LINE_MeshSL:
              {
               //printf(l(__LINE__,"CMD_LINE_MeshSL"));
               double d=-1,v=-1;
               d=(MathAbs(MeshSL-Bid)/Rate_SL)*Rate_TP;
               if(MeshSL>Bid)       v=Bid-d;
               else if(MeshSL<Bid)  v=Ask+d;
               //---
               HLineCreate(0,ObjCMD(CMD_LINE_MeshTP,0),"",0,v,clrLime,2,0,false,true,true,false,0);

               break;
              }
            default:
               break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
void OnEvent_OBJECT_ENDEDIT(int id,long lparam,double dparam,string sparam)
  {
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      Print("CHARTEVENT_OBJECT_ENDEDIT["+sparam+"]");
     }
  }
//+------------------------------------------------------------------+
