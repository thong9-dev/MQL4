//+------------------------------------------------------------------+
//|                                                  GG-TrendBar.mq4 |
//|                                                           GGekko |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "GGekko"
#property link      ""

#property indicator_chart_window

int tframe[]={1,5,15,30,60,240,1440,10080,43200};
string tf[]={"M1","M5","M15","M30","H1","H4","D1","W1","MN1"};
int tfnumber=9;

extern string ___IndicatorSetup___=">>> Indicator Setup:<<<";
extern int ADX_Period=14;
extern int ADX_Price=PRICE_CLOSE;
extern double Step_Psar=0.02;
extern double Max_Psar=0.2;
extern string ___DisplaySetup___=">>> Display Setup:<<<";
extern color UpColor=Lime;
extern color DownColor=Red;
extern color FlatColor=Yellow;
extern color TextColor=Aqua;
extern int Corner=0;

double Psar;
double PADX,NADX;
string TimeFrameStr;
double IndVal[9];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   for(int w=1;w<tfnumber+1;w++)
     {
      ObjectCreate(tf[w-1],OBJ_LABEL,0,0,0,0,0);
      ObjectSet(tf[w-1],OBJPROP_CORNER,Corner);
      ObjectSet(tf[w-1],OBJPROP_XDISTANCE,(w-1)*23+15);
      ObjectSet(tf[w-1],OBJPROP_YDISTANCE,20);
      ObjectSetText(tf[w-1],tf[w-1],8,"Tahoma",TextColor);
     }


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

   for(int k=1;k<tfnumber+1;k++)
      ObjectDelete("Ind"+k);
   for(k=1;k<tfnumber+1;k++)
      ObjectDelete(tf[k-1]);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

//----

   for(int a=1;a<tfnumber+1;a++)
      ObjectDelete("Ind"+a);


   for(int j=1;j<tfnumber+1;j++)
     {
      ObjectCreate("Ind"+j,OBJ_LABEL,0,0,0,0,0);
      ObjectSet("Ind"+j,OBJPROP_CORNER,Corner);
      ObjectSet("Ind"+j,OBJPROP_XDISTANCE,(j-1)*23+15);
      ObjectSet("Ind"+j,OBJPROP_YDISTANCE,30);
      ObjectSetText("Ind"+j,CharToStr(110),12,"Wingdings",White);
     }

   for(int x=1;x<tfnumber+1;x++)
     {

      PADX=iADX(NULL,tframe[x-1],ADX_Period ,ADX_Price,1,0);
      NADX=iADX(NULL,tframe[x-1],ADX_Period ,ADX_Price,2,0);
      Psar=iSAR(NULL,tframe[x-1],Step_Psar,Max_Psar,0);
      if(Psar<iClose(NULL,tframe[x-1],0) && PADX>NADX)
        {
         IndVal[x-1]=1;
        }
      else if(Psar>iClose(NULL,tframe[x-1],0) && NADX>PADX)
        {
         IndVal[x-1]=-1;
        }
      else IndVal[x-1]=0;
     }


   for(int y=1;y<tfnumber+1;y++)
     {
      if(IndVal[y-1]==-1) ObjectSetText("Ind"+y,CharToStr(110),12,"Wingdings",DownColor);
      if(IndVal[y-1]==0) ObjectSetText("Ind"+y,CharToStr(110),12,"Wingdings",FlatColor);
      if(IndVal[y-1]==1) ObjectSetText("Ind"+y,CharToStr(110),12,"Wingdings",UpColor);
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+
