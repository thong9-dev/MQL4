//+------------------------------------------------------------------+
//|                                           Monitor_Ptrototype.mq4 |
//|                                                        Weepukdee |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
extern double   TP_Point;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _SetBool
  {
   A=0,// Buy
   B=1,// Sell
  };
extern _SetBool Direction=A;

string  Text01;
color   Tect01;
string test2,test3="/";

int FontSize=10;
double  Diff_of_TP;
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
   if(!ObjectSet(name,OBJPROP_CORNER,1))
     {
      Print(__FUNCTION__,":2 failed SetText = ",GetLastError());
      return(false);
     }
   if(!ObjectSet(name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,":2 failed SetText = ",GetLastError());
      return(false);
     }
   if(!ObjectSet(name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,":3 failed SetText = ",GetLastError());
      return(false);
     }
   if(!ObjectSetText(name,text,Size,front,clr))
     {
      Print(__FUNCTION__,":4 failed SetText = ",GetLastError());
      return(false);
     }
//ObjectSet(name, OBJPROP_BACK, false);
   return true;
  }//_LabelSet
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
  }//_Comma
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PopPoint()
  {

   double Pop,Traget=300,SumTraget=0,TempSum;
   int Step=100;
//---
   if(Direction==0)
      Pop=Bid;
   else
      Pop=Ask;
//---

   for(int i=Pop;SumTraget>=Traget;i++)
     {

     }
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      int Diff=(Pop-OrderOpenPrice())*(MathPow(10,Digits));

      SumTraget+=MathRound(OrderLots()*Diff);

     }

   SumTraget=SumTraget/100;

   test2=""+SumTraget;
   test3="3";
   return Pop;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string _Text;
   for(int i=1;i<=3;i++)
     {
      _Text="Test"+i;
      _LabelCreate(_Text,0);
     }

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
void OnTick()
  {
//---
   Tect01=clrWhite;
   if(Direction==0)
     {
      Diff_of_TP=(TP_Point-Bid)*(MathPow(10,Digits));
     }
   else
     {
      Diff_of_TP=(Ask-TP_Point)*(MathPow(10,Digits));
     }
//---
   if(Diff_of_TP<0)
     {
      Diff_of_TP=0;
     }

   if(Diff_of_TP<=100 && Diff_of_TP>0)
     {
      Tect01=clrLime;
      Alert(Symbol()+" OnTarget 100p");
     }
   else if(Diff_of_TP<=50 && Diff_of_TP>0)
     {
      FontSize=(int)(FontSize*1.5);
      Alert(Symbol()+" OnTarget 50p");
     }
   _LabelSet("Test1",10,20,Tect01,"Arial",FontSize,_Comma(Diff_of_TP,0," "));

//---
   PopPoint();
   _LabelSet("Test2",10,40,Tect01,"Arial",FontSize,test2);
   _LabelSet("Test3",10,60,Tect01,"Arial",FontSize,test3);

  }
//+------------------------------------------------------------------+
