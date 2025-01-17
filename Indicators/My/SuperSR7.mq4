//+------------------------------------------------------------------+
//|                SuperSR 6.mq4                                     |
//|                Copyright ฉ 2006  Scorpion@fxfisherman.com        |
//+------------------------------------------------------------------+
#property copyright "FxFisherman.com"
#property link      "http://www.fxfisherman.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Contract_Step=150;
extern int Precision=10;
extern int Shift_Bars=1;
extern int Bars_Count= 1000;

//---- buffers
double UP[];
double DW[];
  
int init()
  {

   IndicatorBuffers(2);
  
   SetIndexArrow(0, 159);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1,Red);
   SetIndexDrawBegin(0,-1);
   SetIndexBuffer(0, UP);
   SetIndexLabel(0,"Resistance");
   
   SetIndexArrow(1, 159); 
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1,Blue);
   SetIndexDrawBegin(1,-1);
   SetIndexBuffer(1, DW);
   SetIndexLabel(1,"Support");
   
   watermark();
 
   return(0);
  }

int start()
 {
  double gap;
  double contract = (Contract_Step + Precision) * Point;
  int i;
  int shift; 
  bool fractal;
  double price;
  
  i = Bars_Count;
  
  while(i>=0)
   {
    shift = i + Shift_Bars;
    
    // Resistance
    price = High[shift+2];
    fractal = price >= High[shift+4] &&
              price >= High[shift+3] &&
              price > High[shift+1] &&
              price > High[shift];
              
    gap = UP[i+1] - price;
    if (fractal && (gap >= contract || gap < 0))
    {
      UP[i] = price + (Precision * Point);
    }else{
      UP[i] = UP[i+1];
    }

    // Support
    price = Low[shift+2];
    fractal = price <= Low[shift+4] &&
              price <= Low[shift+3] &&
              price < Low[shift+1] &&
              price < Low[shift];
              
    gap = price - DW[i+1];
    if (fractal && (gap >= contract || gap < 0))
    {
      DW[i] = price - (Precision * Point);
    }else{
      DW[i] = DW[i+1];
    }
    
    i--;
   }   
  return(0);
 }
 
//+------------------------------------------------------------------+

void watermark()
  {
   ObjectCreate("watermark", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("watermark", "Test", 11, "Lucida Handwriting", RoyalBlue);
   ObjectSet("watermark", OBJPROP_CORNER, 2);
   ObjectSet("watermark", OBJPROP_XDISTANCE, 5);
   ObjectSet("watermark", OBJPROP_YDISTANCE, 10);
  }