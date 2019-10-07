//+------------------------------------------------------------------+
//|                                          NumChok_MethodTools.mqh |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict    "NumChok"
//+------------------------------------------------------------------+
#include "NumChok_Method.mqh";
#include "NumChok_Method_MQL4.mqh";
#include "NumChok_Value.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _LabelCreate(string name,int panel)
  {
   if(!ObjectCreate(name,OBJ_LABEL,panel,0,0))
     {
      //Print(__FUNCTION__,":1 failed SetText = ",GetLastError()); 
      return(false);
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _LabelSet(string name,int x,int y,color clr,string front,int Size,string text)
  {
   if(!ObjectSet(name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,":2 failed SetText = ",(string)GetLastError()+"["+name+"]");
      return(false);
     }
   if(!ObjectSet(name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,":3 failed SetText = ",(string)GetLastError()+"["+name+"]");
      return(false);
     }
   if(!ObjectSetText(name,text,Size,front,clr))
     {
      Print(__FUNCTION__,":4 failed SetText = ",(string)GetLastError()+"["+name+"]");
      return(false);
     }
//ObjectSet(name, OBJPROP_BACK, false);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _FillZero(int v)
  {
   string temp;
   if(v<10)
     {
      return temp = "0"+(string)v;
     }
   return ""+(string)v;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _Comma(double v,int Digit,string z)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3== 0 && i<n)
         temp2+= z;
      temp2+=StringSubstr(temp,i-1,1);
      Buff++;
     }
   for(int i=StringLen(temp2);i>0;i--)
     {
      temp3+=StringSubstr(temp2,i-1,1);
     }
   return temp3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string _tbENUM_TIMEFRAMES(int v)
  {
   switch(v)
     {
      case  1:
         return "TF_M1";
      case  5:
         return "TF_M5";
      case  15:
         return "TF_M15";
      case 30:
         return "TF_M30";
      case 60:
         return "TF_H1";
      case 240:
         return "TF_H4";
      case 1440:
         return "TF_D1";
      case 10080:
         return "TF_W1";
      case 43200:
         return "TF_MN1";
      default:
         return "0";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string _OrderProperties(int v)
  {
   switch(v)
     {
      case  0:
         return ("BUY");
         break;
      case  1:
         return ("SELL");
         break;
      case  2:
         return ("BUYLIMIT");
         break;
      case  3:
         return ("SELLLIMIT");
         break;
      case  4:
         return ("BUYSTOP");
         break;
      case  5:
         return ("SELLSTOP");
         break;
      default:
         return ("ERROR");
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void _getSpread()
  {
   if(PipSteps==0)
     {
      vSpread=MarketInfo(Symbol(),MODE_SPREAD)/MathPow(10,(int)MarketInfo(Symbol(),MODE_DIGITS));
        }else{
      vSpread=PipSteps/MathPow(10,myDigit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int _CntAllOrder()
  {
   string str1="",str2="#";
   int x=0;
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      x++;
     }
   return x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _CntMyOrder()
  {
   int _CNT_Buy=0,_CNT_Sell=0;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderMagicNumber()==MagicNumber__Buy) && (OrderSymbol()==Symbol()))
        {
         _CNT_Buy++;
        }
      if((OrderMagicNumber()==MagicNumber_Sell) && (OrderSymbol()==Symbol()))
        {
         _CNT_Sell++;
        }
     }
//+------------------------------------------------------------------+
   if(CNT_Buy!=_CNT_Buy)
     {
      CNT_Buy=_CNT_Buy;
     }
//+------------------------------------------------------------------+
   if(CNT_Sell!=_CNT_Sell)
     {
      CNT_Sell=_CNT_Sell;
     }
   CNT_ALL=CNT_Buy+CNT_Sell;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculateLot(int c)
  {
   double Temp=Lots;

   for(int i=0;i<c; i++)
     {
      Temp=Temp *((LotsRate+100)/100);
     }
   Temp=NormalizeDouble(Temp,2);
   Print("[_CalculateLot()]# TB "+(string)(c+1)+" is "+(string)Temp);

   return Temp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _CalculatePip(int c)
  {
   double Temp=300;
   string Str;
   for(int i=0;i<c; i++)
     {
      Temp=Temp+(Temp/100)*1;

      Temp=NormalizeDouble(Temp,2);

      Str+="/"+(string)Temp;
     }
   Print("[_Calculate Pip()]# CNT "+(string)c+" is "+Str);
   return Temp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double _CalculateTP(string Direction,int _MagicNumber,int f)
  {
   _CntMyOrder();
   int CNT;
   if(Direction=="Buy")
     {
      CNT=CNT_Buy;
        }else{
      CNT=CNT_Sell;
     }
   double SumProduct=0,
   SumLot = 0,
   MinLot = 99999,
   Result = 0,A = 0,B = 0,
   Temp   = 0;

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderMagicNumber()==_MagicNumber) && (OrderSymbol()==Symbol()))
        {
         SumProduct+=OrderLots()*OrderOpenPrice();
         SumLot+=OrderLots();

         if(OrderLots()<MinLot)
           {
            MinLot=OrderLots();
           }
        }
     }

   if(SumLot!=0)
      A=SumProduct/SumLot;
   else
      return 1;

//---
   B=SumLot/MinLot;
   if(B!=0)
      B=_CalculatePip(CNT)/B;

   B=B/MathPow(10,myDigit);

   if(Direction=="Buy")
      Result=A+B;
   else
      Result=A-B;

   if(f!=0)
     {
      Print("[_CalculateTP()]# get "+Direction);
      Print("[_CalculateTP()]# : "+DoubleToString(Result,myDigit));
     }

   return NormalizeDouble(Result,myDigit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _OrderChkMyDrawdown(int _MagicNumber)
  {
   double Temp=0;;
   if(CNT_ALL>0)
     {
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()))
           {
            Temp+=OrderProfit();
           }
        }
     }

   return Temp;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _ChkMagicNumber()
  {
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==MagicNumber && !(OrderSymbol()==Symbol()))
        {
         Comment("Program does not work duplicate MagicNumber....");
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderContinue()
  {
   if(CNT_ALL>0)
     {
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==MagicNumber__Buy && (OrderSymbol()==Symbol()))
           {
            if(OrderType()==OP_BUY)
              {
               aTP_All__Buy=_CalculateTP("Green",MagicNumber__Buy,1);
               TimeFirstOrder__Buy=TimeCurrent();
               Print("[OnInit()]#  isContinuce  >> "+Symbol()+" Green : "+(string)aTP_All__Buy+"/"+(string)_CntAllOrder()+" Magic : "+(string)MagicNumber__Buy);
               _LogfileHandle("Start","#isContinuce  >> "+Symbol()+" Green : "+(string)aTP_All__Buy+"/"+(string)_CntAllOrder()+" Magic : "+(string)MagicNumber__Buy);
              }
           }
        }
      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if(OrderMagicNumber()==MagicNumber_Sell && (OrderSymbol()==Symbol()))
           {
            if(OrderType()==OP_SELL)
              {
               aTP_All_Sell=_CalculateTP("Red",MagicNumber_Sell,1);
               TimeFirstOrder_Sell=TimeCurrent();
               Print("[OnInit()]#  isContinuce  >> "+Symbol()+" Red : "+(string)aTP_All_Sell+"/"+(string)_CntAllOrder()+" Magic : "+(string)MagicNumber_Sell);
               _LogfileHandle("Start","#isContinuce  >> "+Symbol()+" Red : "+(string)aTP_All_Sell+"/"+(string)_CntAllOrder()+" Magic : "+(string)MagicNumber_Sell);
              }
           }
        }
        }else{
      Print("[OnInit()]#  Run the first time, good luck, wait for the new bar.");
      _LogfileHandle("Start","#  Run the first time, good luck,");
     }
   _LogfileHandle("--------------","--------------");
   _LogfileHandle("--------------","Tips\tCNT_X\tCNT_R\tDDTIME\t\t\tDD_FUN\tDD_ACC\tDD__ALL\tTP_Point");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void _OrderChkTP(string v,int _MagicNumber)
  {
   bool CHK=false;
   double TP;
   string Direct="";
   if(v=="Buy")
     {
      TP=aTP_All__Buy;
      Direct=(string)OP_BUY;
     }
   else
     {
      TP=aTP_All_Sell;
      Direct=(string)OP_SELL;
     }

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber)
        {
         if(OrderTakeProfit()==TP)
            CHK=true;
         else
            CHK=false;
        }
     }

   if(!CHK)
     {
      _OrderModify(v,_CalculateTP(v,_MagicNumber,0),_MagicNumber,Direct);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _OrderModify(string v,double _TP,int _MagicNumber,string _OrderType)
  {
   int c=0,n=0;
   double pip=1/MathPow(10,myDigit);
   _CntMyOrder();

   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderMagicNumber()==_MagicNumber && (OrderSymbol()==Symbol()) && ((string)OrderType()==_OrderType))
        {
         if(!(OrderModify(OrderTicket(),OrderOpenPrice(),0,_TP,0)))
           {
            if(v=="Buy")
              {
               aTP_All__Buy=_TP+pip;
               n=CNT_Buy;
                 }else{
               aTP_All_Sell=_TP-pip;
               n=CNT_Sell;
              }
           }
         else
           {
            c++;
           }
        }
     }

   if(v=="Buy"){n=CNT_Buy;}else{n=CNT_Sell;}

   Print("[_OrderModify()]# ModifileComplete : "+(string)c+" / "+(string)n);
   return true;
  }
//+------------------------------------------------------------------+
void _ChartScreenShot(string logic)
  {
   ChartNavigate(0,CHART_END,0);
   MqlDateTime MqlDate_SCL;
   TimeToStruct(TimeLocal(),MqlDate_SCL);

   string FileName=(string)"ChartScreenShot "+string(MqlDate_SCL.year)+"/"+
                   _FillZero(MqlDate_SCL.mon)+" M/"+
                   _FillZero(MqlDate_SCL.day)+" D/";
   FileName+=StringSubstr(_NameEaLabel,0,5)+"["+StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1)+
             _FillZero(MqlDate_SCL.hour)+""+
             _FillZero(MqlDate_SCL.min)+""+
             _FillZero(MqlDate_SCL.sec)+"]";

   FileName+="["+logic+"].png";

//+------------------------------------------------------------------+
//--- Save the chart screenshot in a file in the terminal_directory\MQL4\Files\
   if(!ChartScreenShot(0,FileName,1280,720,ALIGN_RIGHT))
     {
      Print(__FUNCTION__,__FILE__,string(__LINE__)+"YES");
     }
   else
     {
      Print(__FUNCTION__,__FILE__,string(__LINE__)+"NO");
     }
  }
//+------------------------------------------------------------------+
