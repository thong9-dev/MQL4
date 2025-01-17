//+------------------------------------------------------------------+
//|                                                        Divas.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee"
#property link      "https://www.mql5.com"
#property version   "1.05"
#property strict    "NumChok"
//+------------------------------------------------------------------+
//| Expert Self-define function                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
    string _Comma(double v,int Digit,string z){

        string temp =DoubleToString(v,Digit);
        string temp2="",temp3="";
        int Buff=0;
        int n=StringLen(temp);

        for(int i=n;i>0;i--)
        {
            if(Buff%3 == 0 && i < n)
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
     
    string _isBars(int n) {
      	if(iOpen(Symbol(),0,n) > iClose(Symbol(),0,n)) {
      	    printf("[_isLastBas()]# Red");
           	return ("Red");
        }
        if(iOpen(Symbol(),0,n) < iClose(Symbol(),0,n)) {
        	printf("[_isLastBas()]# Green");
           	return ("Green");
        }
        return ("0");
    }//EndisLastBas
    
    double _isPrice(string v){
        double MinPrice = 99999,MaxPrice=-99999;
        
        for(int pos=0;pos<OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
                if(OrderMagicNumber() == MagicNumber){
                    if(OrderOpenPrice() > MaxPrice){
                        MaxPrice = OrderOpenPrice();
                    }
                    if(OrderOpenPrice() < MinPrice){
                        MinPrice = OrderOpenPrice();
                }
             }
        }
        printf("[_isLastBas()]# Max : "+ MaxPrice +" Min : "+ MinPrice);
        if("Max" == v){
            return  MaxPrice;
        }else if("Min" == v){
            return  MinPrice;
        }
        return 0;
    }
    
    string _OrderProperties(int v){
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
    }//OrderProperties
    void _getSpread(){
        if(PipSteps == 0){
            vSpread = MarketInfo(Symbol(),MODE_SPREAD) / MathPow(10,(int)MarketInfo(Symbol(),MODE_DIGITS));
         }else{
            vSpread = PipSteps / MathPow(10,(int)MarketInfo(Symbol(),MODE_DIGITS));
         }
    }
    
    datetime TimeStart,TimeFirstOrder,TimeWorked,DDTime,DDTimeMax=0;
    
    bool _OpenOrder(string Direction,int n,string v){

         int ticket;
         int c = _CntMyOrder();
         //--
         _PriceMax = _isPrice("Max");
         _PriceMin = _isPrice("Min");
         _iMA();
         //----------------------------------------------
         if(c < MaxTrad){
            if(Direction == "Red"){
               if(( Bid >  _PriceMin && Bid > (_PriceMax + vSpread)) || n == 0){
                    if(_DirectionEMA == Direction){
                        ticket = OrderSend(Symbol(),OP_SELL,_CalculateLot(c),Bid,3,0,0,_NameEa + (n+1) + "/" + v + " ["+ MagicNumber +"] ",MagicNumber,0);
                    }else{
                        printf("[_OpenOrder(R0)]# Not open is Conflicting values..");  
                    }
                    
                    if(n == 0){
                        TimeFirstOrder = TimeCurrent();
                    }
               }else{
                   printf("[_OpenOrder(R1)]# Not open in the area. # Max : "+ (_PriceMax + vSpread) +" Min : "+ _PriceMin + "  Bid : "+ Bid);return false;
               }
            }else{
               if(( Ask < _PriceMax && Ask < (_PriceMin - vSpread)) || n == 0){
                    if(_DirectionEMA == Direction){
                        ticket = OrderSend(Symbol(),OP_BUY,_CalculateLot(c),Ask,3,0,0,_NameEa+ (n+1) + "/" + v + " ["+ MagicNumber +"] ",MagicNumber,0);
                    }else{
                        printf("[_OpenOrder(G0)]# Not open is Conflicting values..");  
                    }
                    if(n == 0){
                        TimeFirstOrder = TimeCurrent();
                    }
               }else{
                    printf("[_OpenOrder(G1)]# Not open in the area. # Max : "+ (_PriceMin - vSpread) +" Min : "+ _PriceMin+ " Ask : "+ Ask);return false;
               }
            }
            //--
            aTP_All = _CalculateTP(_Direction,1);
            c = _CntMyOrder();
            //--
            printf("[_OpenOrder(3)]# OrderOpen : ["+ _Comma(ticket,0," ") +"] "+ Direction +" Error : "+ GetLastError());
            return true;
         }
         else{
            printf("[_OpenOrder(4)]# Order is MaxTrad");
         }
         
         return false;
    }//_OpenOrder
    
    int _CntAllOrder(){
         string str1 = "",str2 ="#";
         int x = 0;
         for(int pos=0;pos<OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
                  x++;
         }
         return x;
    }//_CntAllOrder
    
    int _CntMyOrder(){
         string str1 = "",str2 ="#";
         int x = 0;
         for(int pos=0;pos<OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
            
               if(OrderMagicNumber() == MagicNumber){
                  x++;
                  //str1 += OrderMagicNumber()+"/";
                  str1 = x+"/";
               }
               else{
                  str2 += OrderMagicNumber()+"/";
               }
         }
         //Print("[_CntMyOrder()]# "+ x +" / "+ OrdersTotal()+" --- [" + str1 + str2 + "]");
         //Print("[_CntMyOrder(2)]# cntMyOrder : [" + x +"]---[" + str1 + str2 + "]");
         return x;
    }//_CntMyOrder
    
    double _CalculateLot(int c){
        double Temp = Lots;
        
            for(int i= 0 ;i < c; i++){
                Temp = Temp *((Rate + 100)/100);
            }
            Temp = NormalizeDouble(Temp,2);
            Print("[_CalculateLot()]# TB " + (c+1) +" is "+ Temp);
            
        return Temp;
    }
    
    double _CalculatePip(int c){
        double Temp = Pip;
        string Str;
            for(int i= 0 ;i < c; i++){
                Temp = Temp+(Temp/100)*1;
                
                Temp = NormalizeDouble(Temp,2);
                
                Str += "/" + Temp;
            }
            Print("[_CalculatePip()]# TB " + c +" is "+ Str);
        return Temp;
    }
    double _CalculateTP(string Direction,int f){
    
         CNT = _CntMyOrder();
         
         double SumProduct = 0,
                SumLot = 0,
                MinLot = 99999,
                Result = 0,A = 0,B = 0,
                Temp   = 0;

         /*datetime OrderOpenTime();
         int      OrderTicket();
         int      OrderMagicNumber();
         string   OrderSymbol();
         int      OrderType();
         double   OrderLots();
         double   OrderOpenPrice();
         double   OrderTakeProfit();  */
         
         //xLots[0] = 1;
         
         for(int pos=0;pos<OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
              if(OrderMagicNumber() == MagicNumber){
                  SumProduct += OrderLots() * OrderOpenPrice();
                  SumLot += OrderLots();
                  
                  if(OrderLots() < MinLot){
                     MinLot = OrderLots();
                  }
                 
              }
         }
         
         if(SumLot != 0){
            A = SumProduct / SumLot;
         }else{
            return 1;
            Print("Out calTp");
         }
         
         B = SumLot/MinLot;
         if(B != 0){
            B = _CalculatePip(CNT)/B;
         }
         
         B = B / MathPow(10,myDigit);
         
         if(Direction == "Green"){
            Result = A + B;
         }else{
            Result = A - B;   
         }
         if(f!=0){
            Print("[_CalculateTP()]# get " + Direction);
            Print("[_CalculateTP()]# : "+ DoubleToString(Result,myDigit));
         }
         
         
         //_OrderModify(StrToDouble(Result));
         
         return NormalizeDouble(Result,myDigit);
    }//_CalculateTP
    void _OrderChkTP(){
        bool CHK;
        
        for(int pos=0;pos<OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
              if(OrderMagicNumber() == MagicNumber){
                  if(OrderTakeProfit() == aTP_All)
                    CHK = true;
                  else
                    CHK = false;
              }
        }
        
        if(!CHK){
            aTP_All = _CalculateTP(_Direction,0);
            _OrderModify(aTP_All);
        }
    }
    double _OrderChkMyDrawdown(){
        double Temp;
        if(CNT > 0){
            for(int pos=0;pos<OrdersTotal();pos++){
                if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
                    if(OrderMagicNumber() == MagicNumber && (OrderSymbol() == Symbol())){
                        Temp += OrderProfit();
                    }
           }
        }
        
        return Temp;
         
    }
    void _OrderContinue(){
         if(CNT > 0){
           for(int pos=0;pos<OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
               if(OrderMagicNumber() == MagicNumber && (OrderSymbol() == Symbol())){
                  if(OrderType()==0)
                    _Direction = "Green";
                  else
                    _Direction = "Red";
               }
           }
           aTP_All = _CalculateTP(_Direction,1);
           TimeFirstOrder = TimeCurrent();
           //Print("[OnInit()]#  isContinuce  >> Direction : " + _Direction + " / " + CNT +" TP : "+aTP_All);
           Print("[OnInit()]#  isContinuce  >> "+Symbol()+" Direction : " + _Direction + "" + CNT +"/"+_CntAllOrder()+" Magic : "+ MagicNumber);
       }else{
           Print("[OnInit()]#  Run the first time, good luck, wait for the new bar.");
       }
    }
    bool _OrderModify(double _TP){  
        int c = 0;
        for(int pos=0;pos < OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
               if(OrderMagicNumber() == MagicNumber){
                  //Print("[_OrderModify()]# "+ DoubleToString(_TP,Digit));
                  if(!(OrderModify(OrderTicket(),OrderOpenPrice(),0,_TP,0))){
                        if(_Direction == "Green"){
                           aTP_All = aTP_All + 0.00001;
                        }else{
                           aTP_All = aTP_All - 0.00001;
                        }
                  }
                  else{
                     c++;
                  }
               }
         }
         Print("[_OrderModify()]# ModifileComplete : " +  c +" / " + _CntMyOrder());
         
         _PriceMax = _isPrice("Max");
         _PriceMin = _isPrice("Min");
         
         return true;
    }//_CntMyOrder
    bool _LabelCreate(string name,int panel){
        if(!ObjectCreate(name,OBJ_LABEL,panel,0,0)) { 
            //Print(__FUNCTION__,":1 failed SetText = ",GetLastError()); 
            return(false); 
        }
        return true;
    }
    bool _LabelSet(string name,int x,int y,color clr,string front,int Size,string text){
         if(!ObjectSet(name,OBJPROP_XDISTANCE,LineSX+x)) { 
            Print(__FUNCTION__,":2 failed SetText = ",GetLastError());  
            return(false); 
        }
         if(!ObjectSet(name,OBJPROP_YDISTANCE,LineSY+y)) { 
            Print(__FUNCTION__,":3 failed SetText = ",GetLastError());  
            return(false); 
        }
         if(!ObjectSetText(name,text,Size,front,clr)) { 
            Print(__FUNCTION__,":4 failed SetText = ",GetLastError()); 
            return(false); 
        }
        ObjectSet(name, OBJPROP_BACK, false);
        return true;
    }//_LabelSet
//+------------------------------------------------------------------+ WaitOrganize    
    //--- input parameters of the script 
    
input string          InpName="HLine";     // Line name 
input int             InpPrice=25;         // Line price, % 
input color           InpColor=clrRed;     // Line color 
input ENUM_LINE_STYLE InpStyle=STYLE_DASH; // Line style 
input int             InpWidth=1;          // Line width 
input bool            InpBack=false;       // Background line 
input bool            InpSelection=true;   // Highlight to move 
input bool            InpHidden=true;      // Hidden in the object list 
input long            InpZOrder=0;         // Priority for mouse click 

//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
    bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrYellow,        // line color 
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
        if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) { 
            Print(__FUNCTION__, 
            ": failed to create a horizontal line! Error code = ",GetLastError()); 
            return(false); 
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
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
    bool HLineMove(const long   chart_ID = 0,   // chart's ID 
                   const string name="HLine", // line name 
                   double       price = 0,
                   const color  clr=clrYellow,)      // line price 
    { 
        //--- if the line price is not set, move it to the current Bid price level 
        if(!price) 
            price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
            ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
            //--- reset the error value 
            ResetLastError(); 
        //--- move a horizontal line 
        if(!ObjectMove(chart_ID,name,0,0,price)) { 
            //Print(__FUNCTION__,": failed to move the horizontal line! Error code = ",GetLastError()); 
            return(false); 
     } 
     //--- successful execution 
     return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
    bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
    { 
        //--- reset the error value 
        ResetLastError(); 
        //--- delete a horizontal line 
        if(!ObjectDelete(chart_ID,name)) { 
            Print(__FUNCTION__,": failed to delete a horizontal line! Error code = ",GetLastError()); 
            return(false); 
        } 
   //--- successful execution 
        return(true); 
    } 
//+------------------------------------------------------------------+ endWaitOrganize
    string _FillZero(int v){
        string temp;
        if(v < 10)
          {
           return temp = "0"+v;
          }
        return ""+v;
         
    }
    void _iMA(){
        _iMA_BLUE = iMA(Symbol(),0,35,0,MODE_EMA,0,0);
        _iMA__RED = iMA(Symbol(),0,13,0,MODE_EMA,0,0);
        
        if(_iMA__RED < _iMA_BLUE){
            _DirectionEMA = "Red";
        }else if(_iMA__RED > _iMA_BLUE){
            _DirectionEMA = "Green";      
        }
    }
    void _Display(){
        //string str = "RSI(14)";
        string str = "RustyWins2";
        int MyPanel = WindowFind(str);
        //Comment(MyPanel+" "+WindowsTotal());
        if(MyPanel>0){
            _Display(MyPanel); 
        }
        _iMA();
        
    }
    
    string _Text,_Text1,_Text2,_Text3,_Text4,_Text5,_Text6,_Text7,_Text8,_Text9,_Text10,
           _Text11,_Text12,_Text13,_Text14;
    color  _cText,_cText1,_cText2,_cText3,_cText4,_cText5,_cText6,_cText7,_cText8,_cText9,_cText10,
           _cText11,_cText12,_cText13,_cText14;
           
    double 	Border,Rim,RimP,
            myProfit,accProfit,accBalance,myProfitTotal,perProfit,
            DD,DDMax = -999999999,DD2,DDMax2 = -999999999,DD_All,DDMax_All = -999999999,
            sTP,sTPmax = -999999999;
           
    int _Month,_Day,_HH,_MM,_SS,
        _MonthD,_DayD,_HHD,_MMD,_SSD,      
        _MonthDMax,_DayDMax,_HHDMax,_MMDMax,_SSDMax;
        
    MqlDateTime MqlDate_Start,MqlDate_Current,
                MqlDate_FOrder,MqlDate_DDM;
                        
        
    bool _Display(int panel){
    
        //***********if c=0 >> Welcome
        
        for(int i=1;i<=14;i++){
           _Text = "_Text"+ i;
           _LabelCreate(_Text,panel);
        }
        //---------------------
        if(_Direction == "Green"){
            if(aTP_All>1){
                sTP = (aTP_All - Bid)*(MathPow(10,myDigit));
                if(sTP > sTPmax){sTPmax = sTP;}
            }
            
            Border = _PriceMin;
            Rim = Border - vSpread;
            RimP = (Ask - Rim) * MathPow(10,myDigit);
            
            if(( Ask < _PriceMax && Ask < Border) || CNT == 0){
                if(Ask < Rim)
                    _cText5 = clrRed;
                else
                    _cText5 = clrKhaki;
            }else{
                _cText5 = clrMidnightBlue;
            }
            
        }else{
           if(aTP_All>1){
                sTP = (Ask - aTP_All)*(MathPow(10,myDigit));
                if(sTP > sTPmax){sTPmax = sTP;}
           }
            
           Border = _PriceMax;
           Rim = Border + vSpread;
           RimP = (Rim - Bid) * MathPow(10,myDigit);
                
           if(( Bid >  _PriceMin && Bid > Border) || CNT == 0){
               if(Bid > Rim)
                   _cText5 = clrRed;
               else
                   _cText5 = clrKhaki;
           }else{
               _cText5 = clrMidnightBlue;
           }
        }
        if(Border > 0){
            _Text5 = "Br : "+ Border +" / "+ NormalizeDouble(Rim,myDigit) +" ["+ _Comma(RimP,0," ") +"P]";
        }else{
            _Text5 = "Br : -----------";
        }
        //-- Case cntOrder = 0
        if(CNT == 0){
            _Text5 = "Br : -----------";
            _cText5 = clrMidnightBlue;
        }
        HLineMove(0,"RimLine",NormalizeDouble(Rim,myDigit),_cText5);
        //---_Text4
        
        if(sTP < 100){ _cText4 = clrLime;}
        else{_cText4 = clrYellow;}
        
        if(aTP_All != 1){
           _Text4 = "TP : "+ aTP_All +" [ "+ _Comma(sTP,0," ") +"P ][ "+ _Comma(sTPmax,0," ") +"P ]";
        }else{
           _Text4 = "TP : isMax [ "+ _Comma(sTPmax,0," ") +"P ]";
        }
        //--
        //--TimeFirstOrder
        //TimeToStruct(TimeCurrent(),MqlDate_Current);
        TimeToStruct(TimeLocal(),MqlDate_Current);
        TimeToStruct(TimeStart,MqlDate_Start);

        _Text10 = "Strat : "+MqlDate_Start.day+"."+MqlDate_Start.mon+"."+MqlDate_Start.year+" "+MqlDate_Start.hour+":"+MqlDate_Start.min+":"+MqlDate_Start.sec;
       
        _Day = (MqlDate_Current.day_of_year)-(MqlDate_Start.day_of_year);
        _HH = (MqlDate_Current.hour)-(MqlDate_Start.hour);
        _MM = (MqlDate_Current.min)-(MqlDate_Start.min);
        _SS = (MqlDate_Current.sec)-(MqlDate_Start.sec);  
        
        //--Cal Negative value
        if(_HH < 0){_HH = 24 + _HH;}
        if(_MM < 0){_MM = 60 + _MM;}
        if(_SS < 0){_SS = 60 + _SS;}
        
        //--CalMonth
        if(_Day > 30){
           _Month = _Day / 30;
           _Day = _Day % 30;
        }
        //SetText
        _Text1 = "Worked : ";
        if(_Month>0){_Text1 += _Month+"M ";}
        if(_Day>0){_Text1 += _Day+"D ";}
        
        _Text1 += _FillZero(_HH)+":"+_FillZero(_MM)+":"+_FillZero(_SS);
        //--
        //แปลงไทย์ผลต่างของเดย์ออฟเยีย ได้วันแท้จริง
        //Use local or Current ?
        //TimeToStruct(TimeCurrent(),MqlDate_test);
        //Comment(MqlDate_test.day_of_year);
        
        DDTime = TimeCurrent()-TimeFirstOrder;
        TimeToStruct(DDTime,MqlDate_FOrder);
        
        _DayD= MqlDate_FOrder.day_of_year - MqlDate_Current.day_of_year;
        _HHD = MqlDate_FOrder.hour;
        _MMD = MqlDate_FOrder.min;
        _SSD = MqlDate_FOrder.sec;
        
        //_MonthD,_DayD,_HHD,_MMD,_SSD,        
        
        //--Cal Negative value
        if(_HHD < 0){_HHD = 24 + _HHD;}
        if(_MMD < 0){_MMD = 60 + _MMD;}
        if(_SSD < 0){_SSD = 60 + _SSD;}
        //--CalMonth
        if(_DayD > 30){
           _MonthD = _DayD / 30;
           _DayD = _DayD % 30;
        }
        
        if(TimeFirstOrder != 0){
            _Text9 = "DDT : ";
            
            if(_MonthD>0){_Text9 += _MonthD+"M ";}
            if(_DayD>0){_Text9 += _DayD+"D ";}
            
           _Text9 +=_FillZero(_HHD)+":"+_FillZero(_MMD)+":"+_FillZero(_SSD)+" ";
           
           //--CompareMaxDD
           if(DDTime > DDTimeMax){
                DDTimeMax = DDTime;
           }
           TimeToStruct(DDTimeMax,MqlDate_DDM);
            //_MonthDMax,_DayDMax,_HHDMax,_MMDMax,_SSDMax;
           _DayDMax= MqlDate_DDM.day_of_year;
           _HHDMax = MqlDate_DDM.hour;
           _MMDMax = MqlDate_DDM.min;
           _SSDMax = MqlDate_DDM.sec;
           
            //--CalMonth
            if(_DayDMax > 30){
                _MonthDMax = _DayDMax / 30;
                _DayDMax = _DayDMax % 30;
            }
           
        }else{
           _Text9 = "WaitOrder.. : isMax";
        }
        
        if(_DayDMax > 0){
                _Text9 += "[ ";
                if(_MonthDMax>0){_Text9 += _MonthDMax+"M ";}
                if(_DayDMax>0){_Text9 += _DayDMax+"D ";}
                _Text9 += _FillZero(_HHDMax)+":"+_FillZero(_MMDMax)+":"+_FillZero(_SSDMax)+" ]";
           }else{
                _Text9 += " [ "+_FillZero(_HHDMax)+":"+_FillZero(_MMDMax)+":"+_FillZero(_SSDMax)+" ]";
           }
        
        myProfit  = _OrderChkMyDrawdown();
        accProfit  = NormalizeDouble(AccountInfoDouble(ACCOUNT_PROFIT),2);
        if(accProfit == 0){accProfit = 1;}
        accBalance = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2);
        //accBalance = accBalance-4900;
        myProfitTotal = accBalance - Fund;
        perProfit  = (myProfitTotal / Fund) * 100;
        
        
        DD = (myProfit / Fund) * (-100);
        if(DD > DDMax){DDMax = DD;}
        
        DD2 = (myProfit / accBalance) * (-100);
        if(DD2 > DDMax2){DDMax2 = DD2;}
        
        DD_All = (accProfit / accBalance) * (-100);
        if(DD_All > DDMax_All){DDMax_All = DD_All;}

        //MaxCNT
        if(CNT>cMax){cMax=CNT;}
        //                                                                                      *** var is Over100%
        _Text2  = _Direction +"[ "+ CNT +"/"+ cMax +" ] : "+ _Comma(myProfit,2," ")+" ["+_Comma((myProfit/accProfit)*100,2,"")+"%] USD ";
        _Text12 = "OverAll : "+ _CntAllOrder() +" : "+ _Comma(accProfit,2," ")+" USD";
        
        
        _Text3 = "DD-This  : "+_Comma(DD,2," ") +"% [ "+ _Comma(DDMax,2,"") +"% ]";
        _Text8 = "DD-ACC : "  + _Comma(DD2,2," ") +"% [ "+ _Comma(DDMax2,2,"") +"% ]";
        _Text13 ="DD-All    : "  + _Comma(DD_All,2," ") +"% [ "+ _Comma(DDMax_All,2,"") +"% ]";
        
        _Text6 = "Balance : "+ _Comma(accBalance,2," ")+" USD";
        _Text6 += " [ "+ _Comma(Fund,2," ")+" USD]";
        
        string FundStatus;
        if(perProfit > 0){
            FundStatus = " (Inbound revenue...)";
        }
        if(perProfit > 100){
            perProfit = perProfit - 100;
            myProfitTotal = myProfitTotal - Fund;
            FundStatus = " (Payback get profit...)";     
        }
        //
        _Text7 = "Profit : "+ _Comma(myProfitTotal,2," ") +" USD [ "+ _Comma(perProfit,2," ") +"% ]" + FundStatus;
        
        
        double ProfitPerDay;
        if(_Day > 0){
            ProfitPerDay = myProfitTotal/_Day;
            _Text11 = "PerDay["+_Day+"] : "+_Comma(ProfitPerDay,2," ")+" [ "+_Comma(ProfitPerDay*35,2," ")+" / "+_Comma(ProfitPerDay*35*20,2," ")+" ]";
        }
        //-----
        double _RSI_AVG = 
        iRSI(Symbol(),PERIOD_H1,14,PRICE_CLOSE,0)+
        iRSI(Symbol(),PERIOD_H4,14,PRICE_CLOSE,0)+
        iRSI(Symbol(),PERIOD_D1,14,PRICE_CLOSE,0)+
        iRSI(Symbol(),PERIOD_W1,14,PRICE_CLOSE,0);
        
        _RSI_AVG = _RSI_AVG / 4;
        //---
       
        //---
        _Text14 = _DirectionEMA+"#EMA : R" + NormalizeDouble(_iMA__RED,myDigit) +" / B"+ NormalizeDouble(_iMA_BLUE,myDigit);
        //-----------------------------------------------------------------------------********
        int Shif = 0;
        //1
        _LabelSet("_Text10",Shif,10,clrGold,"Arial",FontSize,_Text10);
        _LabelSet("_Text1", Shif,30,clrYellow,"Arial",FontSize,_Text1);
        _LabelSet("_Text2", Shif,50,clrGold,"Arial",FontSize,_Text2);
        _LabelSet("_Text12",Shif,70,clrGold,"Arial",FontSize,_Text12);
        //2
        Shif = 220;
        _LabelSet("_Text9", Shif,10,clrYellow,"Arial",FontSize,_Text9);
        _LabelSet("_Text3", Shif,30,clrRed,"Arial",FontSize,_Text3);    
        _LabelSet("_Text8", Shif,50,clrRed,"Arial",FontSize,_Text8);
        _LabelSet("_Text13",Shif,70,clrRed,"Arial",FontSize,_Text13);
        //3
        Shif = 440;
        _LabelSet("_Text4", Shif,10,_cText4 ,"Arial",FontSize,_Text4);
        _LabelSet("_Text5", Shif,30,_cText5 ,"Arial",FontSize,_Text5);
        _LabelSet("_Text14",Shif,50,clrRed,"Arial",FontSize,_Text14);
        
        //4
        Shif = 640;
        _LabelSet("_Text6", Shif,10,clrYellow,"Arial",FontSize,_Text6);
        _LabelSet("_Text7", Shif,30,clrGold,"Arial",FontSize,_Text7);
        _LabelSet("_Text11",Shif,50,clrGold,"Arial",FontSize,_Text11);
        
        return true;
    }
    void _setTemplate(){
       /*
       ChartSetInteger(0,CHART_SHOW_ASK_LINE,0,true);
       ChartSetInteger(0,CHART_SHOW_GRID,0,false);
       ChartSetInteger(0,CHART_COLOR_GRID,clrBlue);
       
       ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrLime);
       ChartSetInteger(0,CHART_COLOR_CHART_UP,clrLime);
       ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrRed);
       ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrLime);
       ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrRed);
       ChartSetInteger(0,CHART_SHIFT,true);
       
       ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
       */
       
        string terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH);
        terminal_data_path += "\\"+"temp-my.tpl";
      
       FileOpen(terminal_data_path,FILE_WRITE|FILE_CSV); 
       ChartApplyTemplate(0,terminal_data_path);
       FileIsExist(terminal_data_path,FILE_WRITE|FILE_CSV);
       
       Print("Failed to apply "+terminal_data_path+" Template, error code ",GetLastError()); 
    }
    bool _ChkMagicNumber(){
        for(int pos=0;pos<OrdersTotal();pos++){
            if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
               if(OrderMagicNumber() == MagicNumber && !(OrderSymbol() == Symbol())){
                    Comment("Program does not work duplicate MagicNumber....");
                    return false;
            }
       }
       return true;
    }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern int MagicNumber = 1234;

extern double Fund = 100;
extern double Lots = 0.01;
extern double Rate = 3;
extern int Pip = 100;
extern int PipSteps = 50;
extern int MaxTrad = 20;
//+------------------------------------------------------------------+
extern string Head2 = "Var For DisPaly";
extern int FontSize = 10;
extern int LineSX = 30;
extern int LineSY = 10;
    
enum _SetBool 
  {
   A=False,    // No
   B=True,     // Yes
  };
input _SetBool _LatsTime = A;
//------------------------------------------------------------------
int myDigit = (int)MarketInfo(Symbol(),MODE_DIGITS);
int CNT = _CntMyOrder(),cMax= -9;
double aTP_All = 1;
string _NameEa = "NumChokEA-2017 : ";
string _Direction,_DirectionEMA;

string StrTabs = "-------------------------------------------------------------------------------";
//+------------------------------------------------------------------+
 double _iMA_BLUE = iMA(Symbol(),0,50,0,1,6,0),
        _iMA__RED = iMA(Symbol(),0,13,0,1,6,0);
//+------------------------------------------------------------------+
int OnInit(){
       //---Main part
       //TimeStart = TimeCurrent();
       TimeStart = TimeLocal();
       
       _setTemplate();
       
       Print(StrTabs);
       
       _getSpread();
       _CntBars = Bars;
       _OrdersTotal = OrdersTotal();
       //---
       HLineCreate(0,"RimLine",0,1,clrBlack,3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
       //---
       CNT = _CntMyOrder();
       Print("[OnInit()]# _CntBars : "+ _Comma(_CntBars,0,",") +"/"+_Comma(Bars,0,","));

       _OrderContinue();
       
       //----
       Print(StrTabs);
 //---
 
      
  return(INIT_SUCCEEDED);
  }//EndOnInit
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   HLineDelete(0,"RustyTest");
  }//EndOnDeinit
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int _OrdersTotal,
    _CntBars;
    
    double _PriceMax = _isPrice("Max"),
           _PriceMin = _isPrice("Min");
    double vSpread;            

    MqlDateTime MqlDate_test;            
//+------------------------------------------------------------------+
void OnTick(){
//---

        
//--
  if(_ChkMagicNumber()){
     //--
    CNT = _CntMyOrder();
    if(CNT == 0){
        TimeFirstOrder = 0;
        _Direction = "";
        aTP_All = 1;
    }else{
        _OrderChkTP();
    }
  //-  
    if(_CntBars != Bars){    //if_1
  
        _CntBars = Bars;
        Print(StrTabs + "OnTick(1)");
     
        if(CNT == 0){  //if_2        **Define Funtion for Check Null MagicNumber
            
            _Direction = "";
         
            if(!_LatsTime){   //if_3         **fo set
                _Direction = _DirectionEMA;
                //_Direction = _isBars(1);;
                Print("[OnTick(1)]# " + DoubleToString(_CntBars,0)+"/"+DoubleToString(Bars,0)+" _Direction : " + _Direction);
            
                _OpenOrder(_Direction,CNT,"1");

            }else{
            
            }
        }else{
            Print(StrTabs + "OnTick(2-1)");
            _OpenOrder(_Direction,CNT,"2");
            Print("[OnTick(2-2)]#  Chk2 : " + _Direction);
        }
     
    }

        if(OrdersTotal()!=_OrdersTotal){
        _OrdersTotal = OrdersTotal();
     
        Print("[OnTick(2)]# CntOrder : "+_CntMyOrder()+" / "+ _OrdersTotal);
        }
  
        //--Main
        _Display(); 
        //--
  
  }//End _ChkMagicNumber()
  
  }//EndOnTick()
  
//+------------------------------------------------------------------+
