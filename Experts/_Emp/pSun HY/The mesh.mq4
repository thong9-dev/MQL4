//+------------------------------------------------------------------+
//|                                                Grid_AtiveFix.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.3"
#property strict
//####################################################################
string List_ID[]={};
//####################################################################
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//string EA_NAME="The mesh[1.25]";
string EA_NAME="The Mesh";
bool Authentication=false;
string strAuthentication="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eOP_Dir
  {
   BUY=OP_BUY,
   SELL=OP_SELL
  };
//+------------------------------------------------------------------+
extern int iMagicNumber=1111;       //MagicNumber
extern double iLot=0.01;            //Lot
extern eOP_Dir iOP_Dir=BUY;         //Order
extern int Different_Take=300;      //Different(Point)
double _Different_Take=Different_Take/MathPow(10,Digits);
extern string xstr="---------------------";//---------------------------------
extern bool LastRun=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ChartSetInteger(0,CHART_SHOW_GRID,false);
//ChartSetInteger(0,CHART_SHOW_ASK_LINE,true);
//ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrDimGray);

   LockEA();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int _OrderCount=-1;
int OS=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   string cmm=EA_NAME;
//---

   cmm+="\n "+srtDir();
   cmm+="\n LastRun : "+string(LastRun);

   _OrderCount=OrderCount(Symbol(),iMagicNumber,iOP_Dir);
   cmm+="\n OrderCount "+Symbol()+" : "+string(_OrderCount);

   if(_OrderCount==0)
     {
      if(!LastRun && Authentication)
        {
         OS=_OrderSend(_OrderCount,"");
        }
      else
        {
         ObjectDelete(ChartID(),EA_NAME+"#"+"_PriceTack");
        }
     }
   else
     {
      double _getPrice=getOpenPrice(Symbol(),iOP_Dir);
      double _Last_OpenPrice=OrderLast_OpenPrice(Symbol(),iMagicNumber,iOP_Dir);

      double _PriceTack=(iOP_Dir==OP_BUY)?_Last_OpenPrice-_Different_Take:_Last_OpenPrice+_Different_Take;
      HLineCreate(ChartID(),EA_NAME+"#"+"_PriceTack",0,_PriceTack,clrGray,3,1,false,false,false,0);

      cmm+="\n Different_Take : "+IntegerToString(Different_Take)+" Point";
      cmm+="\n";
      cmm+="\n "+srtDirPrice()+" : "+DoubleToStr(_getPrice,Digits);
      cmm+="\n LastPrice : "+DoubleToStr(_Last_OpenPrice,Digits);
      cmm+="\n PriceExtern : "+DoubleToStr(_PriceTack,Digits);

      double Different=(iOP_Dir==OP_BUY)?_Last_OpenPrice-_getPrice:_getPrice-_Last_OpenPrice;
      cmm+="\n";
      cmm+="\n Different : "+DoubleToStr(Different*MathPow(10,Digits),0)+" Point";

      if(Different>=_Different_Take)
        {
         OS=_OrderSend(_OrderCount,"");
        }
     }

//---
//string List_ID[]={"123"};
//string List_Name[]={""};

//---
   Comment(cmm+strAuthentication);
//---

   ButtonCreate(ChartID(),EA_NAME+"#BTN#OrderSent",0,
                20,30,100,20,CORNER_LEFT_LOWER,
                "OrderSent","Arial",10,
                clrWhite,clrGray,clrWhite,
                true,false,false,false,0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Print("CHARTEVENT_OBJECT_CLICK: '"+sparam+"'");
      if(sparam==EA_NAME+"#BTN#OrderSent")
        {
         ObjectSetInteger(0,EA_NAME+"#BTN#OrderSent",OBJPROP_BGCOLOR,clrRed);

         string Mgg="Do you want to open more orders?";
         Mgg+="\n\n"+Symbol()+"•"+srtDir()+" : "+DoubleToStr(getOpenPrice(Symbol(),iOP_Dir),Digits)+" | Lot : "+DoubleToStr(iLot,2);

         int M_Box=MessageBox(Mgg,EA_NAME+"#BTN_ACT_ORDER",MB_YESNO);
         if(M_Box==IDYES)
           {
            _OrderCount=OrderCount(Symbol(),iMagicNumber,iOP_Dir);
            OS=_OrderSend(_OrderCount,"*");
           }

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string srtDir()
  {
   return (iOP_Dir==OP_BUY)?"Buy":"Sell";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string srtDirPrice()
  {
   return (iOP_Dir==OP_BUY)?"Ask":"Bid";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _OrderSend(int xOrderCount,string Mark)
  {
   double OpenPrice=getOpenPrice(Symbol(),iOP_Dir);
   double TakePrice=(iOP_Dir==OP_BUY)?OpenPrice+_Different_Take:OpenPrice-_Different_Take;

   NormalizeDouble(OpenPrice,Digits);
   NormalizeDouble(TakePrice,Digits);

   return OrderSend(Symbol(),iOP_Dir,iLot,OpenPrice,10,0,TakePrice,
                    EA_NAME+" "+string(xOrderCount+1)+Mark+" | "+string(Different_Take)+"p | "+string(iMagicNumber)+"mn",
                    iMagicNumber,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SymbolShot()
  {

   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getOpenPrice(string _OrderSymbol,int _dir)
  {
   return (_dir==OP_BUY)?MarketInfo(_OrderSymbol,MODE_ASK):MarketInfo(_OrderSymbol,MODE_BID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderCount(string _OrderSymbol,int _MagicNumber,int _OrderType)
  {
   int cnt=0;
   for(int i=0;i<OrdersTotal();i++) // for loop
     {
      int r=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==_OrderSymbol && 
         OrderMagicNumber()==_MagicNumber && 
         OrderType()==_OrderType)
        {
         cnt++;
        }
     }

   return cnt;
  }
//+------------------------------------------------------------------+
double OrderLast_OpenPrice(string _OrderSymbol,int _MagicNumber,int _OrderType)
  {
   double Key=getKey();

   int Key_OrderTicket=-1;
   bool Statement=false;

   for(int i=0;i<OrdersTotal();i++) // for loop
     {
      int r=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      // check for opened position, symbol & MagicNumber
      if(OrderSymbol()==_OrderSymbol && 
         OrderMagicNumber()==_MagicNumber && 
         OrderType()==_OrderType)
        {

         Statement=(_OrderType==OP_BUY)?OrderOpenPrice()<Key:OrderOpenPrice()>Key;

         if(Statement)
           {
            Key=OrderOpenPrice();
            Key_OrderTicket=OrderTicket();
           }
        }
     }

   return Key;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getKey()
  {
   string sX=DoubleToStr(getOpenPrice(Symbol(),iOP_Dir),Digits);
   double r=MathPow(10,StringLen(sX));

   return (iOP_Dir==OP_BUY)?r:r*(-1);
  }
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
      //Print(__FUNCTION__, ": failed to create a horizontal line! Error code = ",GetLastError());
      //return(false);
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
bool ButtonCreate(const long              chart_ID=0,               // chart's ID 
                  const string            name="Button",            // button name 
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
                  const bool              selection=false,          // highlight to move 
                  const bool              hidden=true,              // hidden in the object list 
                  const long              z_order=0)                // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create the button 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      //Print(__FUNCTION__,": failed to create the button! Error code = ",GetLastError());
      //return(false);
     }
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
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
   bool Result=(Chk_ID && Chk_Name)?true:false;
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

   strAuthentication="\n";
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
