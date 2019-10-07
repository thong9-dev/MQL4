//+------------------------------------------------------------------+
//|                                                        Dusty.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.02"
#property strict    

//ทำตารางการถอนเงินแยกตามความเสี่ยง จาก 2 เท่าของโดนลาก หักจาก เงินจรองและฟรี
string testCString(string v,string c){
   string temp = "";
   int n=StringLen(v)-StringLen(c);
      for(int i =0;i<n;i++){
         temp+="_";
      }
return temp+c;
}
color ColorToNumber(double v){
   color temp =clrWhite;
   if(v<0)
      temp=clrRed;
   else
      temp=clrLime;
return temp;
}
color ColorToNumber2(double v){
   color temp =clrWhite;
   v=v*-1;
   
    if ((v >= 75) && (v <= 100))
         temp=clrRed;
    else if ((v >=50) && (v < 75))
         temp=clrOrange;
    else if ((v >= 35) && (v < 50))
         temp=clrGold;
    else if ((v >= 25) && (v < 35))
         temp=clrYellow;
    else if ((v >= 0) && (v < 25))
         temp=clrMediumSpringGreen;
    else
         temp=clrLime;
         
return temp;
}
string Comma(double v){

string temp =DoubleToString(v,0);
string temp2="",temp3="";
int Buff=0;
int n=StringLen(temp);

        for(int i=n;i>0;i--)
        {
            if(Buff%3==0&&i<n)
               temp2+=" ";
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
int FontSize=10;
int LineSX=10,LineSY=20;
extern double   THB=35;
extern double   Fund=0;
double   Balance;
double   FMargin;
double   Profit;
double   x;


void OnTick()
  {
//---
    Balance = AccountBalance();
    FMargin= AccountFreeMargin();
    Profit=AccountProfit();
    x=(AccountProfit()/AccountBalance())*100;
    
    string x2="";
      
    string _Text1 = "Total : "+Comma(Balance)+" CEN | "+Comma(Balance*(THB/100))+" THB";
    ObjectCreate("Text1",OBJ_LABEL,0,0,0);
    ObjectSet("Text1",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text1",OBJPROP_YDISTANCE,LineSY+0);
    ObjectSetText("Text1",_Text1,FontSize,"Arial",ColorToNumber(Balance));
    
    string _Text20;
    if(Fund==0){
         _Text20="#no cost...";}
    else{
         _Text20="Fund : "+ testCString(Comma(Balance),Comma((Fund/THB)*100))+" CEN | "+testCString(Comma(Balance*(THB/100)),Comma(Fund))+" THB";}
    
    ObjectCreate("Text20",OBJ_LABEL,0,0,0);
    ObjectSet("Text20",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text20",OBJPROP_YDISTANCE,LineSY+15);
    ObjectSetText("Text20",_Text20,FontSize,"Arial",ColorToNumber(FMargin));

    string _Text2=" Free : "+Comma(FMargin)+" CEN | "+Comma(FMargin*(THB/100))+" THB";
    ObjectCreate("Text2",OBJ_LABEL,0,0,0);
    ObjectSet("Text2",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text2",OBJPROP_YDISTANCE,LineSY+35);
    ObjectSetText("Text2",_Text2,FontSize,"Arial",ColorToNumber(FMargin));
    
    string _Text24=" Real : "+testCString(Comma(FMargin),Comma(FMargin-((Fund/THB)*100)))+" CEN | "+testCString(Comma(FMargin*(THB/100)),Comma(FMargin*(THB/100)-Fund))+" THB";
    
    ObjectCreate("Text24",OBJ_LABEL,0,0,0);
    ObjectSet("Text24",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text24",OBJPROP_YDISTANCE,LineSY+50);
    ObjectSetText("Text24",_Text24,FontSize,"Arial",ColorToNumber(FMargin));
    
    string _Text3="Profit : "+Comma(Profit)+" CEN  |  "+Comma(Profit*(THB/100))+" THB";
    ObjectCreate("Text3",OBJ_LABEL,0,0,0);
    ObjectSet("Text3",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text3",OBJPROP_YDISTANCE,LineSY+70);
    ObjectSetText("Text3",_Text3,FontSize,"Arial",ColorToNumber(Profit));
    
    
    string _Text_1="  _______________________";
    ObjectCreate("Text_1",OBJ_LABEL,0,0,0);
    ObjectSet("Text_1",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text_1",OBJPROP_YDISTANCE,LineSY+80);
    ObjectSetText("Text_1",_Text_1,FontSize,"Arial",ColorToNumber2(x));
    
    string _Text4 ="     Percent : "+DoubleToString(x,2)+"%";
    ObjectCreate("Text4",OBJ_LABEL,0,0,0);
    ObjectSet("Text4",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text4",OBJPROP_YDISTANCE,LineSY+100);
    ObjectSetText("Text4",_Text4,FontSize+3,"Arial",ColorToNumber2(x));
    
    if(x<0)
         x2=" ";
    
    string _Text5="       Suffer : "+x2+DoubleToString(100+x,2)+"%";
    ObjectCreate("Text5",OBJ_LABEL,0,0,0);
    ObjectSet("Text5",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text5",OBJPROP_YDISTANCE,LineSY+115);
    ObjectSetText("Text5",_Text5,FontSize+3,"Arial",ColorToNumber2(x));
    
    string _Text_2="  _______________________";
    ObjectCreate("Text_2",OBJ_LABEL,0,0,0);
    ObjectSet("Text_2",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text_2",OBJPROP_YDISTANCE,LineSY+120);
    ObjectSetText("Text_2",_Text_2,FontSize,"Arial",ColorToNumber2(x));
    
    //---------------------
    

    ObjectCreate("Text_Ask",OBJ_LABEL,0,0,0);
    ObjectSet("Text_Ask",OBJPROP_XDISTANCE,LineSX+0);ObjectSet("Text_Ask",OBJPROP_YDISTANCE,LineSY+140);
    ObjectSetText("Text_Ask","",FontSize,"Arial",ColorToNumber2(x));
    
    
   
    
    
    //

  }
//+------------------------------------------------------------------+
