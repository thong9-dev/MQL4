//+------------------------------------------------------------------+
//|                                                    Histogram.mqh |
//|                                           Copyright 2016, DC2008 |
//|                              http://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, DC2008"
#property link      "http://www.mql5.com/ru/users/dc2008"
#property version   "1.00"
//--- Макросы
#define  R        43    // значения префикса (+) для гистограмм справа
#define  L        45    // значения префикса (-) для гистограмм слева
#define  WP       108   // символ шрифта Wingdings
#define  FS       10    // Размер шрифта Wingdings

#define  ObjSet1  ObjectSetInteger(0,name,OBJPROP_WIDTH,m_width)
#define  ObjSet2  ObjectSetDouble(0,name,OBJPROP_PRICE,0,price)
#define  ObjSet3  ObjectSetInteger(0,name,OBJPROP_TIME,0,time)
#define  ObjSet4  ObjectSetDouble(0,name,OBJPROP_PRICE,1,price)
#define  ObjSet5  ObjectSetInteger(0,name,OBJPROP_BACK,true)
#define  ObjSet   ObjSet1;ObjSet2;ObjSet3;ObjSet4;ObjSet5

#define  ObjL1    ObjectSetInteger(0,name,OBJPROP_WIDTH,1)
#define  ObjL2    ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DASHDOT)
#define  ObjLine  ObjL1;ObjL2

#define  ObjF1    ObjectSetString(0,name,OBJPROP_FONT,"Wingdings")
#define  ObjF2    ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_CENTER)
#define  ObjF3    ObjectSetString(0,name,OBJPROP_TEXT,CharToString(WP))
#define  ObjF4    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FS)
#define  ObjFont  ObjF1;ObjF2;ObjF3;ObjF4
//+------------------------------------------------------------------+
//| Структура variational series                                     |
//+------------------------------------------------------------------+
struct sVseries
  {
   long              N;    // общее число наблюдений
   double            Na;   // среднее значение частот
   double            Vmax; // максимальное значение варианты
   double            Vmin; // минимальное значение варианты
   double            A;    // амплитуда ряда
   double            Mean; // взвешенная средняя арифметическая
   double            D;    // дисперсия
   double            SD;   // среднеквадратическое отклонение
  };
//+------------------------------------------------------------------+
//| Структура цены                                                   |
//+------------------------------------------------------------------+
struct sPrice
  {
   double            max;  // максимальное значение цены
   double            min;  // минимальное значение цены
  };
//+------------------------------------------------------------------+
//| Class CHistogram                                                 |
//+------------------------------------------------------------------+
class CHistogram
  {
private:
   string            m_symbol;         // символ гистограммы
   int               m_hsize;          // масштаб диаграммы
   int               m_width;          // толщина линий
   color             m_color_active;   // цвет активных линий
   color             m_color_passive;  // цвет пассивных линий
   int               m_digits;         // разрядность переменной
   int               m_sub_win;        // индекс окна
   bool              m_Left_Right;     // left=false or right=true
   int               k_time;           // коэффициент смены знака
   int               m_prefix;         // префикс код
   string            m_name;           // префикс имени
   double            m_Point;          // интервал гистограммы
   sPrice            m_price;          // границы диапазона гистограммы
   datetime          m_prevTimeBar;    // время открытия предыдущего бара
   long              m_max_frequency;  // максимальное значение частоты
   bool              m_relative_frequency;// относительные или абсолютные значения частоты
   int               m_time_size;      // вспомогательная переменная
   datetime          m_time;           // время открытия текущего бара
   double            m_average;        // простая средняя арифметическая гистограммы
   long              m_N;              // количество столбцов гистограммы
   //--- методы
   sPrice            MaxMin(double price);         // поиск максимума и минимума цены
   void              ShiftHistogram(datetime time);// сдвиг гистограммы на текущий бар
   long              Get(string name);             // частота варианты
public:
   void              CHistogram(string name,       // уникальный префикс имени
                                int hsize,         // масштаб диаграммы
                                int width,         // толщина линий столбцов гистограммы
                                color active,      // цвет активных линий
                                color passive,     // цвет пассивных линий
                                bool Left_Right=true,          //left=false or right=true
                                bool relative_frequency=false, //
                                int sub_win=0);    // индекс окна построения гистограммы
                    ~CHistogram();
   void              DrawHistogram(double price,// отображение гистограммы
                                   datetime time);
   void              SetHistogram(int hsize,
                                  int width,
                                  color active,
                                  color passive);
   void              SetDigits(int digits);
   sVseries          HistogramCharacteristics();   // расчёт характеристик гистограммы
   void              DrawMean(double coord,        // визуализация средней
                              datetime time,
                              bool marker=false,
                              bool save=false);
   void              DrawSD(sVseries &coord,// визуализация среднеквадратического отклонения
                            datetime time,
                            double deviation=1.0,
                            color clr=clrYellow);
  };
//+------------------------------------------------------------------+
//| Get                                                              |
//+------------------------------------------------------------------+
long CHistogram::Get(string name)
  {
   string str=ObjectGetString(0,name,OBJPROP_TEXT);
   string strint=StringSubstr(str,1);
   return(StringToInteger(strint));
  }
//+------------------------------------------------------------------+
//| HistogramCharacteristics                                         |
//+------------------------------------------------------------------+
sVseries CHistogram::HistogramCharacteristics() // расчёт характеристик гистограммы
  {
   sVseries res={0,NULL,NULL,NULL,NULL,NULL,NULL};
   res.Vmax=m_price.max;         // максимальное значение варианты
   res.Vmin=m_price.min;         // минимальное значение варианты
   res.A=m_price.max-m_price.min;// амплитуда ряда
//---
   if(res.A>0)
     {
      double moment=0;
      for(double i=m_price.min;i<=m_price.max;i+=m_Point)
        {
         long n=Get(m_name+DoubleToString(i,m_digits));
         res.N+=n;               // общее число наблюдений
         moment+=n*i;
        }
      if(res.N>0)
         res.Mean=moment/res.N;  // взвешенная средняя арифметическая
      moment=0;
      long m=0;
      for(double i=m_price.min;i<=m_price.max;i+=m_Point)
        {
         long n=Get(m_name+DoubleToString(i,m_digits));
         moment=(res.Mean-i)*(res.Mean-i)*n;
         m++;                    // количество столбцов гистограммы
        }
      m_N=m;                     // количество столбцов гистограммы
      if(res.N>0)
         res.D=moment/res.N;     // дисперсия
      res.SD=MathSqrt(res.D);    // среднеквадратическое отклонение
      if(m>0)
         res.Na=(double)res.N/m; // среднее значение частот
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| DrawSD                                                           |
//+------------------------------------------------------------------+
void CHistogram::DrawSD(sVseries &coord,// визуализация среднеквадратического отклонения
                        datetime time,
                        double deviation=1.0,
                        color clr=clrYellow)
  {
   string name=m_name+"SD "+(string)deviation;
   ObjectCreate(0,name,OBJ_RECTANGLE,m_sub_win,0,0);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,coord.Mean+coord.SD*deviation);
   ObjectSetInteger(0,name,OBJPROP_TIME,0,time);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,coord.Mean-coord.SD*deviation);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,time+(int)coord.Na*m_time_size/m_max_frequency);
  }
//+------------------------------------------------------------------+
//| Draw Mean                                                        |
//+------------------------------------------------------------------+
void CHistogram::DrawMean(double coord,datetime time,bool marker=false,bool save=false)
  {
   string name;
   if(marker)
     {
      name=m_name+"average_Y_Point";
      if(save)
         name+=(string)time;
      ObjectCreate(0,name,OBJ_TEXT,m_sub_win,0,0);
      ObjFont;
      ObjectSetInteger(0,name,OBJPROP_COLOR,m_color_active);
      ObjectSetDouble(0,name,OBJPROP_PRICE,coord);
      ObjectSetInteger(0,name,OBJPROP_TIME,time);
      if(save)
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)FS/2);

      name=m_name+"average_Y";
      ObjectCreate(0,name,OBJ_HLINE,m_sub_win,0,0);
      ObjectSetInteger(0,name,OBJPROP_COLOR,m_color_active);
      ObjLine;
      ObjectSetDouble(0,name,OBJPROP_PRICE,0,coord);
     }
   if(!marker)
     {
      name=m_name+"average_Y";
      ObjectCreate(0,name,OBJ_HLINE,m_sub_win,0,0);
      ObjectSetInteger(0,name,OBJPROP_COLOR,m_color_active);
      ObjLine;
      ObjectSetDouble(0,name,OBJPROP_PRICE,0,coord);
     }
  }
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CHistogram::CHistogram(string name,
                            int hsize,
                            int width,
                            color active,
                            color passive,
                            bool Left_Right=true,
                            bool relative_frequency=false,
                            int sub_win=0)
  {
   m_symbol=_Symbol;
   m_hsize=hsize;
   m_width=width;
   m_color_active=active;
   m_color_passive=passive;
   m_digits=_Digits;
   m_Point=_Point;
   m_Left_Right=Left_Right;
   if(m_Left_Right)
     {
      k_time=1;
      m_prefix=R;
      m_name="+ "+name+"=";
     }
   else
     {
      k_time=-1;
      m_prefix=L;
      m_name="- "+name+"=";
     }
   m_sub_win=sub_win;
   m_price.max=0;
   m_price.min=DBL_MAX;
   m_prevTimeBar=0;
   m_max_frequency=1;
   m_relative_frequency=relative_frequency;
   m_time_size=k_time*m_hsize;
   m_average=0;
  }
//+------------------------------------------------------------------+
//| Search Max and Min                                               |
//+------------------------------------------------------------------+
sPrice CHistogram::MaxMin(double price) // поиск максимума и минимума
  {
   sPrice res=m_price;
   if(price<m_price.min)
      res.min=NormalizeDouble(price,m_digits);
   if(price>m_price.max)
      res.max=NormalizeDouble(price,m_digits);
   return(res);
  }
//+------------------------------------------------------------------+
//| SetDigits                                                        |
//+------------------------------------------------------------------+
void CHistogram::SetDigits(int digits)
  {
   m_digits=digits;
   m_Point=MathPow(10,-m_digits);
   m_Point=NormalizeDouble(m_Point,m_digits);
  }
//+------------------------------------------------------------------+
//| Draw Histogram                                                   |
//+------------------------------------------------------------------+
void CHistogram::DrawHistogram(double price,
                               datetime time)
  {
   m_time=time;
   m_price=MaxMin(price);     // поиск максимума и минимума
   long n=1;
//---
   if(time>m_prevTimeBar) // определяем появление нового бара
     {
      m_prevTimeBar=time;
      ShiftHistogram(time);   // Смещение диаграммы на новый бар
     }

   string name=m_name+DoubleToString(price,m_digits);
   ObjectCreate(0,name,OBJ_TREND,m_sub_win,0,0);
   ObjectSetInteger(0,name,OBJPROP_COLOR,m_color_active);
   ObjSet;
   if(StringFind(ObjectGetString(0,name,OBJPROP_TEXT),"*",0)<0)
     {
      ObjectSetString(0,name,OBJPROP_TEXT,"*1");
      if(m_relative_frequency)
         ObjectSetInteger(0,name,OBJPROP_TIME,1,time+int(m_time_size/m_max_frequency));
      else
         ObjectSetInteger(0,name,OBJPROP_TIME,1,time+m_time_size);
     }
   else
     {
      string str=ObjectGetString(0,name,OBJPROP_TEXT);
      string strint=StringSubstr(str,1);
      n=StringToInteger(strint);
      n++;
      ObjectSetString(0,name,OBJPROP_TEXT,"*"+(string)n);
      if(m_relative_frequency)
         ObjectSetInteger(0,name,OBJPROP_TIME,1,time+int(m_time_size*n/m_max_frequency));
      else
         ObjectSetInteger(0,name,OBJPROP_TIME,1,time+m_time_size*n);
     }
   if(n>m_max_frequency) m_max_frequency=n;
  }
//+------------------------------------------------------------------+
//| Shift Histogram                                                  |
//+------------------------------------------------------------------+
void CHistogram::ShiftHistogram(datetime time)
  {
   for(int obj=ObjectsTotal(0,m_sub_win,OBJ_TREND)-1;obj>=0;obj--)
     {
      string obj_name=ObjectName(0,obj,m_sub_win,OBJ_TREND);
      if(obj_name[0]==m_prefix)                 // ищем префикс элемента гистограммы
         if(StringFind(obj_name,m_name,0)>=0)   // ищем имя элемента гистограммы
           {
            ObjectSetInteger(0,obj_name,OBJPROP_TIME,0,time);
            string str=ObjectGetString(0,obj_name,OBJPROP_TEXT);
            string strint=StringSubstr(str,1);
            long n=StringToInteger(strint);
            if(m_relative_frequency)
               ObjectSetInteger(0,obj_name,OBJPROP_TIME,1,time+int(m_time_size*n/m_max_frequency));
            else
               ObjectSetInteger(0,obj_name,OBJPROP_TIME,1,time+m_time_size*n);
            ObjectSetInteger(0,obj_name,OBJPROP_COLOR,m_color_passive);
           }
     }
  }
//+------------------------------------------------------------------+
//| Set Histogram                                                    |
//+------------------------------------------------------------------+
void CHistogram::SetHistogram(int hsize,int width,color active,color passive)
  {
   m_hsize=hsize;
   m_width=width;
   m_color_active=active;
   m_color_passive=passive;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CHistogram::~CHistogram()
  {
  }
//+------------------------------------------------------------------+
