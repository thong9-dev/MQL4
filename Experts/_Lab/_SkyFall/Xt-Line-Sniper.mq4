//+------------------------------------------------------------------+
//|                                               Xt-Line-Sniper.mq4 |
//|                                https://www.facebook.com/lapukdee |
//|                                https://www.facebook.com/lapukdee |
//+------------------------------------------------------------------+
#property copyright "https://www.facebook.com/lapukdee"
#property link      "https://www.facebook.com/lapukdee"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum MODE_DEVLOP
  {
   MODE_DEVLOP_0=0,
   MODE_DEVLOP_1=1,
   MODE_DEVLOP_2=2,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MODE_Price
  {
   MODE_Price0=0,//0
   MODE_Price1=1,//1
   MODE_Price2=2,//2
   MODE_Price3=3,//3
   MODE_Price4=4,//4
   MODE_Price5=5,//5
   MODE_Price6=6,//6
  };
MODE_DEVLOP                _MODE_DEVLOP=MODE_DEVLOP_0;
extern ENUM_MODE_Price     MODE_Price=MODE_Price0;
extern int        Period_Length=20;//TCCI Period
extern int        Displace=0;
extern int        Filter= 0;
extern bool       Color = true;
extern int        ColorBarBack=1;
extern double     Deviation=0.0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double            Arr_Main[];
double            Arr_UP[];
double            Arr_DW[];

double            Ext_TCCI[];
double            Arr_1[];

int               Length_C=4;
int               g_index_128_T;
int               IN_i_1;
int               IN_i_2;
//
double            _Pi3=3.0*M_PI;

double            IN_d_1;
double            IN_d_2;
double            IN_d_3;

double            gd_152;

double            gd_184;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
//TCCI_Init();
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
int nBar=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//TCCI_Start();
//   
   if(nBar!=Bars)
     {
      nBar=Bars;

      int BarStart=0;
      int BarCount=4;
      //BarStart++;
      //---
      CMM=nBar;
      //CMM+="\n"+iCustom(Symbol(),Period(),"ATR",14,0,0);
      int Mode_=0;
      int Period_=20;
      double Deviation_=0;

      string SignalBuffer="";
      string SignalBufferN="";

      for(int i=0;i<BarCount;i++)
        {
         //SignalBuffer+=DirectionsToStr(DirectionsFind(true,Mode_,Period_,Deviation_,BarStart+i));
        }
      CMM+="\n"+SignalBuffer;
      CMM+="\n----\n";
      SignalBuffer="";
      SignalBufferN="";
/*for(int i=BarStart+BarCount-1;i>=BarStart;i--)
        {
         SignalBufferN+=string(i)+",";
         //Print(i);
         SignalBuffer+=DirectionsToOXI(DirectionsFind(true,Mode_,20,Deviation_,i));
        }*/
      BarStart=2;
      SignalBuffer+="\n"+iCustom(Symbol(),Period(),"_Employ/Line_MrNit/Xtreme Line - Copy",20,6,1);
      SignalBuffer+="\n"+iCustom(Symbol(),Period(),"_Employ/Line_MrNit/Xtreme Line - Copy",20,7,1);
      SignalBuffer+="\n"+iCustom(Symbol(),Period(),"_Employ/Line_MrNit/Xtreme Line - Copy",20,8,1);

      //printf(SignalBuffer);
      if(SignalBuffer=="XO" || SignalBuffer=="HO")
        {
         double OP=Ask;
         double TP=NormalizeDouble(OP+300/Point,Digits);
         double SL=NormalizeDouble(OP-100/Point,Digits);
         bool res=OrderSend(Symbol(),OP_BUY,1,OP,10,SL,TP,"",0);
        }
      if(SignalBuffer=="OX" || SignalBuffer=="HX")
        {
         double OP=Bid;
         double TP=NormalizeDouble(OP-300/Point,Digits);
         double SL=NormalizeDouble(OP+100/Point,Digits);
         bool res=OrderSend(Symbol(),OP_SELL,1,OP,10,SL,TP,"",0);
        }
      CMM+="\n"+SignalBuffer;SignalBuffer="";
      for(int i=BarStart+BarCount-1;i>=BarStart;i--)
        {
         SignalBufferN+=string(i)+",";
         //Print(i);
         //SignalBuffer+=DirectionsToOXI(DirectionsFind(false,Mode_,100,Deviation_,i));
        }
      //printf(SignalBuffer);
      //CMM+="\n"+SignalBufferN;
      CMM+="\n"+SignalBuffer;

     }
   Comment(CMM);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_KEYDOWN)
     {
      Print("The "+string(lparam)+" has been pressed");
      switch(int(lparam))
        {
         case 68://|
           {
            ObjectsDeleteAll(0,OBJ_HLINE);
            ObjectsDeleteAll(0,OBJ_VLINE);
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
string CMM="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DirectionsFind(bool strShow,int pMode,int period,double deviation,int bar)
  {
   double UP=DirectionsGet(pMode,period,deviation,6,bar,Digits);
   double DW=DirectionsGet(pMode,period,deviation,7,bar,Digits);
   double YY=DirectionsGet(pMode,period,deviation,8,bar,Digits);
   int r=-1;
   if(UP>0)
      r=OP_BUY;
   if(DW>0)
      r=OP_SELL;
   if(YY>0)
      r=-1;
//---
   if(strShow)
     {
      if(_MODE_DEVLOP==0) CMM+="**"+string(bar)+"* O:[ "+DoubleToStr(UP,Digits)+" ] | X:[ "+DoubleToStr(DW,Digits)+" ] | I:[ "+DoubleToStr(YY,Digits)+" ] == "+DirectionsToStr(r)+"\n";
      if(_MODE_DEVLOP==1) CMM+=string(bar)+" : "+DirectionsToStr(r)+"\n";
     }
   return r;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DirectionsGet(int pMode,int period,double deviation,int index,int bar,int digit)
  {
//double _iCustom_TCCI=iCustom(Symbol(),Period(),"_Employ/Line_MrNit/Xtreme Line - Copy",Symbol(),Period(),pMode,period,0,0,true,1,deviation,"",clrNONE,clrNONE,clrNONE,clrNONE,1,1,1,"",index,bar);
   double _iCustom_TCCI=iCustom(Symbol(),Period(),"_Employ/Line_MrNit/Xtreme Line - Copy",Symbol(),Period(),0,period,index,bar);

   //if(_iCustom_TCCI==EMPTY_VALUE) _iCustom_TCCI=0;

   return NormalizeDouble(_iCustom_TCCI,digit);
  }
//+------------------------------------------------------------------+
string DirectionsToStr(int statement)
  {
   switch(statement)
     {
      case  OP_BUY:
         return "U";
      case  OP_SELL:
         return "D";
      default:
         return "H";
     }
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string DirectionsToOXI(int statement)
  {
   switch(statement)
     {
      case  OP_BUY:
         return "O";
      case  OP_SELL:
         return "X";
      default:
         return "H";
     }
   return "-";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TCCI_Init()
  {

   IN_i_1 = Period_Length - 1;
   IN_i_2 = Period_Length * Length_C + IN_i_1;

   ArrayResize(Arr_1,IN_i_2);
   IN_d_2=0;

   for(int i=0; i<IN_i_2-1; i++)
     {
      if(i<=IN_i_1-1)
         IN_d_3=1.0*i/(IN_i_1-1);
      else
         IN_d_3=(i-IN_i_1+1) *(2.0*Length_C-1.0)/(Length_C*Period_Length-1.0)+1.0;

      gd_152 = MathCos(M_PI * IN_d_3);
      gd_184 = 1.0 / (_Pi3 * IN_d_3 + 1.0);

      if(IN_d_3<=0.5)
         gd_184=1;

      Arr_1[i]=gd_184*gd_152;
      IN_d_2+=Arr_1[i];
     }
  }
//+------------------------------------------------------------------+
int TCCI_Start()
  {

   int nBars=Bars;
   double getVar=0;

   ArrayResize(Arr_UP,ArraySize(Arr_Main));
   ArrayResize(Arr_DW,ArraySize(Arr_Main));

//+------------------------------------------------------------------+
   for(int j=nBars; j>=0; j--)
     {
      IN_d_1=0;
      for(int k=0; k<=IN_i_2-1; k++)
        {
         printf(j+","+k);
         switch(MODE_Price)
           {
            case  0:
               getVar=Close[j+k];
               break;
            case  1:
               getVar=Open[j+k];
               break;
            case  2:
               getVar=High[j+k];
               break;
            case  3:
               getVar=Low[j+k];
               break;
            case  4:
               getVar=(High[j+k]+(Low[j+k]))/2.0;
               break;
            case  5:
               getVar=(High[j+k]+(Low[j+k])+(Close[j+k]))/3.0;
               break;
            case  6:
               getVar=(High[j+k]+(Low[j+k])+2.0 *(Close[j+k]))/4.0;
               break;
            default:
               break;
           }
         IN_d_1+=Arr_1[k]*getVar;
        }
      //+------------------------------------------------------------------+
      if(IN_d_2>0.0)
        {
         Arr_Main[j]=(Deviation/100.0+1.0)*IN_d_1/IN_d_2;
        }
      if(Filter>0)
        {
         if(MathAbs(Arr_Main[j]-(Arr_Main[j+1]))<Filter*Point)
            Arr_Main[j]=Arr_Main[j+1];
        }

      Ext_TCCI[j]=Ext_TCCI[j+1];

      if(Arr_Main[j]-(Arr_Main[j+1])>Filter*Point)
         Ext_TCCI[j]=1;

      if(Arr_Main[j+1]-Arr_Main[j]>Filter*Point)
         Ext_TCCI[j]=-1;

      if(Ext_TCCI[j]>0.0)
        {//UP
         Arr_UP[j]=Arr_Main[j];
         //---
         if(Ext_TCCI[j+ColorBarBack]<0.0)
            Arr_UP[j+ColorBarBack]=Arr_Main[j+ColorBarBack];
         //---
         Arr_DW[j]=EMPTY_VALUE;
        }
      if(Ext_TCCI[j]<0.0)
        {//DW
         Arr_DW[j]=Arr_Main[j];
         //---
         if(Ext_TCCI[j+ColorBarBack]>0.0)
            Arr_DW[j+ColorBarBack]=Arr_Main[j+ColorBarBack];
         //---
         Arr_UP[j]=EMPTY_VALUE;
        }

     }
//+------------------------------------------------------------------+
   return (0);
  }
//+------------------------------------------------------------------+
