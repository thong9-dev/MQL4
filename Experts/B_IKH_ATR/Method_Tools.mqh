//+------------------------------------------------------------------+
//|                                               NumChok_Method.mqh |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property strict

#include "Method_MQL4.mqh";
#include "B_IKH_ATR.mq4";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cB(bool v)
  {
   return string(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cI(int v)
  {
   return IntegerToString(v);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cD(double v,int Digit)
  {
   if(v==0)
      return "0";
   else
     {
      if(Digit<0)
         Digit=Digits;
      return DoubleToString(v,Digit);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string cFillZero(int v)
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
string Comma(double v,int Digit,string zz)
  {

   string temp =DoubleToString(v,Digit);
   string temp2="",temp3="";
   int Buff=0;
   int n=StringLen(temp);

   for(int i=n;i>0;i--)
     {
      if(Buff%3==0 && i<n)
         temp2+= zz;
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
string strSymbolShortName()
  {
   return StringSubstr(Symbol(),0,1)+StringSubstr(Symbol(),3,1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setTemplate()
  {
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,false);
   ChartSetInteger(0,CHART_SHOW_GRID,0,false);

   ChartSetInteger(0,CHART_COLOR_GRID,clrWhite);

   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);

   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(0,CHART_SHIFT,true);

   ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setBackgroundPanel(string Name,string text,int Fontsize,int LabelCorner,int x,int y)
  {
   if(ObjectFind(0,Name)<0)
     {
      _LabelCreate(Name,0);
     }

   ObjectSetText(Name,text,Fontsize,"Webdings");
   ObjectSet(Name,OBJPROP_CORNER,LabelCorner);
   ObjectSet(Name,OBJPROP_BACK,false);
   ObjectSet(Name,OBJPROP_XDISTANCE,x);
   ObjectSet(Name,OBJPROP_YDISTANCE,y);
   ObjectSet(Name,OBJPROP_COLOR,C'25,25,25');

   ObjectSetString(0,Name,OBJPROP_TOOLTIP,"Magicnumber: ["+string(Magicnumber)+"]");

  }
//+------------------------------------------------------------------+
string strZero(double var,string z1,string z2)
  {
   string v="";
   if(var>0)
     {
      v=z1+Comma(var,2," ")+z2;
     }
   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string strZeroKey(string var,int Key)
  {
   string v="";
   if(Key>0)
     {
      v=var;
     }
   return v;
  }
//+------------------------------------------------------------------+
double _CalculatePrice_Merge(double Point_Buy,double LotBuy,double Point_Sell,double LotSell)
  {
   double SumProduct=0;
   double SumLot_Merge=0;
   double Result=0;
/*//+---------------------------------------------+   
   if(Point_Sell>0 && Point_Buy>0)
     {
      if(Point_Sell>Point_Buy)
        {
         if(LotBuy==LotSell)
           {
            
           }
         else
           {
           }
        }
      else if(Point_Sell<Point_Buy)
        {
         if(LotBuy==LotSell)
           {
           }
         else
           {
           }
        }
      else
        {

        }
     }
   else
      Result=-3;
*/
   SumProduct=(Point_Buy*LotBuy)+(Point_Sell*LotSell);
   SumLot_Merge=LotBuy+LotSell;
   Result=SumProduct/SumLot_Merge;

   string s=cI(__LINE__)+"#SumProduct: "+cD(SumProduct,Digits)+" SumLot: "+cD(SumLot_Merge,Digits);
   _LabelSet("Text_SumLot_4",500,100,clrWhite,"Franklin Gothic Medium Cond",15,s,"");
   string s2=cI(__LINE__)+"#Result: "+cD(Result,Digits)+getError_PriceMerge(Result);
   _LabelSet("Text_SumLot_5",500,80,clrWhite,"Franklin Gothic Medium Cond",15,s2,"");
   return NormalizeDouble(Result,Digits);
  }
//+------------------------------------------------------------------+
string getError_PriceMerge(double var)
  {
   if(var>=0)
     {
      return " Has hedged.";
     }
   int _var=int(var*(-1));
   string str="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(_var)
     {
      case  1:
         str="SumLot_Merge=0";
         break;
      case  2:
         str="Price is not hedging.";
         break;
      case  3:
         str="Price is Invalid. [Has some value 0]";
         break;
      case  4:
         str="Price is Test.";
         break;
      default:
         str="default";
         break;
     }
   return " "+str;
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,string Var)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+Var);
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,string Var,string VarName2,string Var2)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+Var+" "+VarName2+" : "+Var2);
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,string Var,string VarName2,string Var2,string VarName3,string Var3)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+Var+" "+VarName2+" : "+Var2+" "+VarName3+" : "+Var3);
  }
//+------------------------------------------------------------------+
