//+------------------------------------------------------------------+
//|                                                     Drop Ellipse |
//|                                      Copyright 2015 Forex Taurus |
//|                                              All Rights Reserved |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015 Forex Taurus"
#property link      "http://forextaurus.blogspot.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {

   return(0);
  }
//+------------------------------------------------------------------+

void DrawEllipse(string objName,
                 datetime dtTime1,double dblPrice1,
                 datetime dtTime2,double dblPrice2,
                 color Color,double Scale)
  {

//if(ObjectFind(objName)<0)
   bool r=ObjectCreate(NULL,objName,OBJ_ELLIPSE,0,dtTime1,dblPrice1,dtTime2,dblPrice2);
   ObjectSet(objName,OBJPROP_SCALE,Scale);
   ObjectSet(objName,OBJPROP_COLOR,Color);
   ObjectSet(objName,OBJPROP_FILL,1);
   ObjectSet(objName,OBJPROP_BACK,False);
  }
//+------------------------------------------------------------------+
int init()
  {

   EventSetMillisecondTimer(500);
   OnTimer();
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   double Height;
   int Width;
   double Scale;
   switch(Period())
     {
      //---- codes returned from trade server
      case PERIOD_M1: Height=30;Width=Period()*3; Scale = 0.12; break;
      case PERIOD_M5: Height=75; Width=Period()*3; Scale = 0.08; break;
      case PERIOD_M15:Height=100; Width=Period()*3; Scale = 0.08; break;
      case PERIOD_M30:Height=200; Width=Period()*3; Scale = 0.04; break;
      case PERIOD_H1: Height=250; Width=Period()*3; Scale = 0.04; break;
      case PERIOD_H4: Height=350; Width=Period()*3; Scale = 0.02; break;
      case PERIOD_D1: Height=500; Width=Period()*3; Scale = 0.01; break;
      case PERIOD_W1: Height=1000; Width=Period()*7; Scale = 0.002; break;
      case PERIOD_MN1:Height=3000; Width=Period()*10; Scale = 0.002; break;
      default:   Height=250;
     }
   DrawEllipse("Ellipse_"+WindowTimeOnDropped(),
               WindowTimeOnDropped()-Width,WindowPriceOnDropped()-Height*Point,
               WindowTimeOnDropped()+Width,WindowPriceOnDropped()+Height*Point,
               clrSilver,
               Scale);

  }
//+------------------------------------------------------------------+
