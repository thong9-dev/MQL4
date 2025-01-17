//+------------------------------------------------------------------+
//|                                                      NumChok.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Weepukdee-2.25"
#property link      "https://www.mql5.com"
#property version   "2.25"
#property strict    "NumChok"

//+------------------------------------------------------------------+
#include "NumChok_Value.mqh";
#include "NumChok_Method.mqh";
#include "NumChok_Method_Tools.mqh";
#include "NumChok_Method_MQL4.mqh";
//+------------------------------------------------------------------+

bool MASTER_OK;

string _isMA;
string _isRSI;
string _isVolumes;
string _isHihgLow;
string _isStochastic;
string _isSAR;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string _isDirectionHub()
  {
//+------------------------------------------------------------------+
   _CutProfit=1;
   _Cut__Loss=0;
//---
   _ConfirmsignalMA=0;
   _iStochastic=0;
   _iHihgLow=1;
   _iVolumes=1;
   _iSAR=1;
   _iRSI=0;
//+------------------------------------------------------------------+

   string v="Wait";
   _isMA=_isMA((string)PERIOD_CURRENT);
   _isRSI=_isRSI(RSI_Period,RSI_Shift);
   _isVolumes=_isVolumes(Vol_N,Vol_Min,Vol_Max);
   _isHihgLow=_isSupportResistance(Pip,7);
   _isStochastic=_isStochastic(5,3,3);
   _isSAR=_isSAR(0.001,200);
//---
   if((_isVolumes=="OK") && (_isStochastic=="OK") && (_isHihgLow=="OK"))//
     {
      MASTER_OK=true;
     }
   else
     {
      MASTER_OK=false;
     }
//---
   if((_isMA=="Green") && (MASTER_OK))
     {
      if(((_isSAR=="Green") || (_isSAR=="None")) &&
         ((_isRSI=="Green") || (_isRSI=="None")))
        {
         v="Green";
         _clrText0=clrLime;
        }
     }
   else if((_isMA=="Red") && (MASTER_OK))
     {
      if(((_isSAR=="Red") || (_isSAR=="None")) && 
         ((_isRSI=="Red") || (_isRSI=="None")))
        {
         v="Red";
         _clrText0=clrRed;
        }
     }
   else
     {
      v="Wait";
      _clrText0=clrYellow;
     }

   _eaText0="[MA :"+_isMA+"]";
   if(_iSAR)
      _eaText0+="[SA :"+_isSAR+"]";
   if(_iRSI)
      _eaText0+="[RSI :"+_isRSI+"]";
   if(_iVolumes)
      _eaText0+="[Vol :"+_isVolumes+"]";
   if(_iHihgLow)
      _eaText0+="[HL :"+_isHihgLow+"]";
   if(_iStochastic)
      _eaText0+="[STO :"+_isStochastic+"]";
//---
   _eaText0+=" **|"+v+"|**";

//+------------------------------------------------------------------+
   if(WindowEA)
     {
      _LabelSet("_eaText0",60,2,_clrText0,"Arial",FontSize,_eaText0);
     }
   else
     {
      Comment(_eaText0);
     }

//+------------------------------------------------------------------+

   return v;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _DisplayNumChok(string str)
  {
//+------------------------------------------------------------------+
   int panel=WindowFind(str);
   if(panel>0)
     {
      WindowEA=true;
      string _Text;
      for(int i=0;i<=_eaText;i++)
        {
         _Text="_eaText"+(string)(i);
         _LabelCreate(_Text,panel);
        }
     }
   else
     {
      WindowEA=false;
     }
//+------------------------------------------------------------------+
   if(cMax__Buy<CNT_Buy)
     {
      cMax__Buy=CNT_Buy;
     }
   if(cMax_Sell<CNT_Sell)
     {
      cMax_Sell=CNT_Sell;
     }
   string strCNT_Buy="["+(string)CNT_Buy+"/"+(string)cMax__Buy+"]";
   string strCNT_Sell="["+(string)CNT_Sell+"/"+(string)cMax_Sell+"]";

//RIM Buy ----------------------------------------------------------
   if(aTP_All__Buy>1)
     {
      sTP_B=(aTP_All__Buy-Bid) *(MathPow(10,myDigit));
      if(sTP_B>sTPmax_B){sTPmax_B=sTP_B;}
     }

   Border_B=_PriceMin__Buy;
   Rim_B=Border_B-vSpread;
   RimP_B=(Ask-Rim_B)*MathPow(10,myDigit);

   if(( Ask<_PriceMax__Buy && Ask<Border_B) || CNT_Buy==0)
     {
      if(Ask<Rim_B)
         _clrText4=clrRed;
      else
         _clrText4=clrKhaki;
        }else{
      _clrText4=clrMidnightBlue;
     }
//RimBuy
   if(Border_B>0)
     {
      _eaText4="Br : "+(string)Border_B+" / "+(string)NormalizeDouble(Rim_B,myDigit)+" ["+_Comma(RimP_B,0," ")+"P]";
        }else{
      _eaText4="Br : -----------";
     }
//-- Case cntOrder = 0
   if(CNT_Buy==0)
     {
      _eaText4="Br : -----------";
      _clrText4=clrMidnightBlue;
     }
   HLineMove(0,"RimLine_B",NormalizeDouble(Rim_B,myDigit),_clrText4);
//RIM Sell------------------------------------------------------------
   if(aTP_All_Sell>1)
     {
      sTP_S=(Ask-aTP_All_Sell)*(MathPow(10,myDigit));
      if(sTP_S>sTPmax_S){sTPmax_S=sTP_S;}
     }

   Border_S=_PriceMax_Sell;
   Rim_S=Border_S+vSpread;
   RimP_S=(Rim_S-Bid)*MathPow(10,myDigit);

   if(( Bid>_PriceMin_Sell && Bid>Border_S) || CNT_Sell==0)
     {
      if(Bid>Rim_S)
         _clrText9=clrRed;
      else
         _clrText9=clrKhaki;
        }else{
      _clrText9=clrMidnightBlue;
     }
//---
   if(Border_S>0)
     {
      _eaText9="Br : "+(string)Border_S+" / "+(string)NormalizeDouble(Rim_S,myDigit)+" ["+_Comma(RimP_S,0," ")+"P]";
        }else{
      _eaText9="Br : -----------";
     }
//-- Case cntOrder = 0
   if(CNT_ALL==0)
     {
      _eaText9="Br : -----------";
      _clrText9=clrMidnightBlue;
     }
   HLineMove(0,"RimLine_S",NormalizeDouble(Rim_S,myDigit),_clrText9);
//------------------------------------------------------------------------------
//---_Text4   STP
   if(sTP_B<100)
     {
      _clrText3=clrLime;
      Signal_DDClick_BUY++;
      Signal_DDClick_BUY0=Signal_DDClick_BUY/500;
     }
   else{_clrText3=clrYellow;}
//---
   if(sTP_S<100)
     {
      _clrText8=clrLime;
      Signal_DDClick_SELL++;
      Signal_DDClick_SELL0=Signal_DDClick_SELL/500;
     }
   else{_clrText8=clrYellow;}
//+------------------------------------------------------------------+
   if(_CutProfit)
     {
      _OrderCutProfit(_DAD__Buy,_HHD__Buy,DD_B,sTP_B,(string)OP_BUY,MagicNumber__Buy);
      _OrderCutProfit(_DAD_Sell,_HHD_Sell,DD_S,sTP_S,(string)OP_SELL,MagicNumber_Sell);
     }

//+------------------------------------------------------------------+
   if(aTP_All__Buy!=1)
     {
      _eaText3="TP[ "+(string)Signal_DDClick_BUY0+" ] : "+(string)NormalizeDouble(aTP_All__Buy,myDigit)+" [ "+_Comma(NormalizeDouble(sTP_B,myDigit),0," ")+"P ][ "+_Comma(sTPmax_B,0," ")+"P ]";
        }else{
      _eaText3="TP : _ [ "+_Comma(sTPmax_B,0," ")+"P ]";
     }
   if(aTP_All_Sell!=1)
     {
      _eaText8="TP[ "+(string)Signal_DDClick_SELL0+" ] : "+(string)NormalizeDouble(aTP_All_Sell,myDigit)+" [ "+_Comma(NormalizeDouble(sTP_S,myDigit),0," ")+"P ][ "+_Comma(sTPmax_S,0," ")+"P ]";
        }else{
      _eaText8="TP : _ [ "+_Comma(sTPmax_S,0," ")+"P ]";
     }
//+------------------------------------------------------------------+
   TimeToStruct(TimeStart,MqlDate_Start);
   TimeToStruct(TimeLocal()-TimeStart,MqlDate_Work);

   _eaText11="Strat : "+_FillZero(MqlDate_Start.day)+"."+_FillZero(MqlDate_Start.mon)+"."+_FillZero(MqlDate_Start.year);
   _eaText11+=" "+_FillZero(MqlDate_Start.hour)+":"+_FillZero(MqlDate_Start.min)+":"+_FillZero(MqlDate_Start.sec);
//+------------------------------------------------------------------+
   if(_DayOfWeek!=DayOfWeek())
     {
      _DayOfWeek=DayOfWeek();
      if(_DayOfWeek>=1 && _DayOfWeek<=5)
        {
         _Day++;
         _Day_Of_RunEA++;
         if(_Day%20==0 && _Day>0)
           {
            _ChartScreenShot("Month");
           }
         else
           {
            _ChartScreenShot("Day");
           }
        }
     }
//---
   _HH=MqlDate_Work.hour;
   _MM  = MqlDate_Work.min;
   _SS  = MqlDate_Work.sec;
//--Cal Negative value
   if(_HH < 0){_HH = 24 + _HH;}
   if(_MM < 0){_MM = 60 + _MM;}
   if(_SS < 0){_SS = 60 + _SS;}
//--CalMonth
   if(_Day>30)
     {
      _Month=_Day/30;
      _Day=_Day%30;
     }
//+------------------------------------------------------------------+
//SetText

   _eaText12="Worked : ";
   if(_Month>0){_eaText12+=(string)_Month+"M ";}
   if(_Day>0){_eaText12+=(string)_Day+"D ";}

   if(_Day==Test_Day)
     {
      _LatsTime_B = True;
      _LatsTime_S = True;
      Comment("Day Test : "+(string)_Day+"/"+(string)_LatsTime_B+"/"+(string)_LatsTime_S);
     }
   if(IsTesting())
     {
      _StayFriday(_HH);
     }
   _eaText12+=_FillZero(_HH)+":"+_FillZero(_MM)+":"+_FillZero(_SS);

//-----
   if(CNT_Buy!=0)
     {
      DDTime_Buy=TimeCurrent()-TimeFirstOrder__Buy;
      TimeToStruct(DDTime_Buy,MqlDate_1Order_Buy);

      _DAD__Buy = MqlDate_1Order_Buy.day_of_year;
      _HHD__Buy = MqlDate_1Order_Buy.hour;
      _MMD__Buy = MqlDate_1Order_Buy.min;
      _SSD__Buy = MqlDate_1Order_Buy.sec;
        }else{
      _DAD__Buy=_HHD__Buy=_MMD__Buy=_SSD__Buy=0;
     }

//--Cal Negative value
   if(_HHD__Buy < 0){_HHD__Buy = 24 + _HHD__Buy;}
   if(_MMD__Buy < 0){_MMD__Buy = 60 + _MMD__Buy;}
   if(_SSD__Buy < 0){_SSD__Buy = 60 + _SSD__Buy;}

//--CalMonth

   if(_DAD__Buy>30)
     {
      _MonthD__Buy = _DAD__Buy / 30;
      _DAD__Buy    = _DAD__Buy % 30;
     }

   if(TimeFirstOrder__Buy!=0)
     {
      _eaText1="BUY : ";

      if(_MonthD__Buy>0){_eaText1+=(string)_MonthD__Buy+"M ";}
      if(_DAD__Buy>0){_eaText1+=(string)_DAD__Buy+"D ";}

      _eaText1+=_FillZero(_HHD__Buy)+":"+_FillZero(_MMD__Buy)+":"+_FillZero(_SSD__Buy)+" ";

      //--CompareMaxDD
      if(DDTime_Buy>DDTimeMax_Buy)
        {
         DDTimeMax_Buy=DDTime_Buy;

         TimeToStruct(DDTimeMax_Buy,MqlDate_DDMax__Buy);
         _DayDMax__Buy= MqlDate_DDMax__Buy.day_of_year;
         _HHDMax__Buy = MqlDate_DDMax__Buy.hour;
         _MMDMax__Buy = MqlDate_DDMax__Buy.min;
         _SSDMax__Buy = MqlDate_DDMax__Buy.sec;

         //--CalMonth
         if(_DayDMax__Buy>30)
           {
            _MonthDMax__Buy = _DayDMax__Buy / 30;
            _DayDMax__Buy   = _DayDMax__Buy % 30;
           }
        }
        }else{
      _eaText1="BUY:_ ";
     }

   if(_DayDMax__Buy>0)
     {
      _eaText1+="[ ";
      if(_MonthDMax__Buy>0){_eaText1+=(string)_MonthDMax__Buy+"M ";}
      if(_DayDMax__Buy>0){_eaText1+=(string)_DayDMax__Buy+"D ";}
      _eaText1+=_FillZero(_HHDMax__Buy)+":"+_FillZero(_MMDMax__Buy)+":"+_FillZero(_SSDMax__Buy)+" ]";
        }else{
      _eaText1+=" [ "+_FillZero(_HHDMax__Buy)+":"+_FillZero(_MMDMax__Buy)+":"+_FillZero(_SSDMax__Buy)+" ]";
     }
//-------------------------------------------------------------------------------------------------
   if(CNT_Sell!=0)
     {
      DDTime_Sell=TimeCurrent()-TimeFirstOrder_Sell;
      TimeToStruct(DDTime_Sell,MqlDate_1Order_Sell);

      _DAD_Sell = MqlDate_1Order_Sell.day_of_year;
      _HHD_Sell = MqlDate_1Order_Sell.hour;
      _MMD_Sell = MqlDate_1Order_Sell.min;
      _SSD_Sell = MqlDate_1Order_Sell.sec;
        }else{
      _DAD_Sell=_HHD_Sell=_MMD_Sell=_SSD_Sell=0;
     }

//--Cal Negative value
   if(_HHD_Sell < 0){_HHD_Sell = 24 + _HHD_Sell;}
   if(_MMD_Sell < 0){_MMD_Sell = 60 + _MMD_Sell;}
   if(_SSD_Sell < 0){_SSD_Sell = 60 + _SSD_Sell;}
//--CalMonth

   if(_DAD_Sell>30)
     {
      _MonthD_Sell = _DAD_Sell / 30;
      _DAD_Sell    = _DAD_Sell % 30;
     }
   if(TimeFirstOrder_Sell!=0)
     {
      _eaText6="SELL : ";

      if(_MonthD_Sell>0){_eaText6+=(string)_MonthD_Sell+"M ";}
      if(_DAD_Sell>0){_eaText6+=(string)_DAD_Sell+"D ";}

      _eaText6+=_FillZero(_HHD_Sell)+":"+_FillZero(_MMD_Sell)+":"+_FillZero(_SSD_Sell)+" ";

      //--CompareMaxDD
      if(DDTime_Sell>DDTimeMax_Sell)
        {
         DDTimeMax_Sell=DDTime_Sell;

         TimeToStruct(DDTimeMax_Sell,MqlDate_DDMax_Sell);
         _DayDMax_Sell= MqlDate_DDMax_Sell.day_of_year;
         _HHDMax_Sell = MqlDate_DDMax_Sell.hour;
         _MMDMax_Sell = MqlDate_DDMax_Sell.min;
         _SSDMax_Sell = MqlDate_DDMax_Sell.sec;

         //--CalMonth
         if(_DayDMax_Sell>30)
           {
            _MonthDMax_Sell = _DayDMax_Sell / 30;
            _DayDMax_Sell   = _DayDMax_Sell % 30;
           }
        }
        }else{
      _eaText6="SELL : _ ";
     }

   if(_DayDMax_Sell>0)
     {
      _eaText6+="[ ";
      if(_MonthDMax_Sell>0){_eaText6+=(string)_MonthDMax_Sell+"M ";}
      if(_DayDMax_Sell>0){_eaText6+=(string)_DayDMax_Sell+"D ";}
      _eaText6+=_FillZero(_HHDMax_Sell)+":"+_FillZero(_MMDMax_Sell)+":"+_FillZero(_SSDMax_Sell)+" ]";
        }else{
      _eaText6+=" [ "+_FillZero(_HHDMax_Sell)+":"+_FillZero(_MMDMax_Sell)+":"+_FillZero(_SSDMax_Sell)+" ]";
     }

//------------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
   accProfit=NormalizeDouble(AccountInfoDouble(ACCOUNT_PROFIT),2);
   if(accProfit==0){accProfit=1;}
//---
   accBalance=NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2);
//+------------------------------------------------------------------+
   myProfit_Buy=_OrderChkMyDrawdown(MagicNumber__Buy);
   myProfit_Sell=_OrderChkMyDrawdown(MagicNumber_Sell);
   myProfit=myProfit_Buy+myProfit_Sell;
//---
   myProfitTotal=accBalance-Fund;
   perProfit=(myProfitTotal/Fund)*100;
//---
   DD_B=(myProfit_Buy/Fund) *(-100);
   if(DD_B>DDMax_B){DDMax_B=DD_B;}
//---
   DD_S=(myProfit_Sell/Fund) *(-100);
   if(DD_S>DDMax_S){DDMax_S=DD_S;}
//---
   DD_All=(accProfit/(accBalance+AccountInfoDouble(ACCOUNT_CREDIT))) *(-100);
   if(DD_All>DDMax_All){DDMax_All=DD_All;}
//+------------------------------------------------------------------+
   if(CNT_ALL>cMax)
     {
      cMax=CNT_ALL;
      _LogfileMAX("CNT_X     ");
     }
   _eaText2="DD/Fund "+strCNT_Buy+": "+_Comma(DD_B,2," ")+"% [ "+_Comma(DDMax_B,2,"")+"% ]";
   _eaText7="DD/Fund "+strCNT_Sell+": "+_Comma(DD_S,2," ")+"% [ "+_Comma(DDMax_S,2,"")+"% ]";

   _eaText13="[ "+(string)CNT_Buy+"/"+(string)CNT_Sell+"/"+(string)CNT_ALL+"/"+(string)cMax+" ] : ";
   _eaText13+=_Comma(myProfit,2," ")+" USD [ "+_Comma((myProfit/accProfit)*100,2,"")+"% ]";
//---
   _eaText14="OverAll : "+(string)_CntAllOrder()+" : "+_Comma(accProfit,2," ")+" USD";
//---
   _eaText15="DD-All    : "+_Comma(DD_All,2," ")+"% [ "+_Comma(DDMax_All,2,"")+"% ]";
//---
   _eaText17 = "Balance : "+ _Comma(accBalance,2," ")+" USD";
   _eaText17+= " [ "+ _Comma(Fund,2," ")+" USD]";
//---
   _eaText18="Balance+: "+_Comma(accBalance+AccountInfoDouble(ACCOUNT_CREDIT),2," ")+" USD";
   string FundStatus;
   if(perProfit>0)
     {
      FundStatus=" (Inbound revenue...)";
     }
   if(perProfit>100)
     {
      perProfit=perProfit-100;
      myProfitTotal=myProfitTotal-Fund;
      FundStatus=" (Payback get profit...)";
     }
//---
   _eaText19="Profit : "+_Comma(myProfitTotal,2," ")+" USD [ "+_Comma(perProfit,2," ")+"% ]"+FundStatus;

   if(_Day_Of_RunEA>0)
     {
      ProfitPerDay=myProfitTotal/_Day_Of_RunEA;
      double PercentOFFun=((ProfitPerDay*35*20)/(Fund*35))*100;
      _eaText20="PerDay["+(string)_Day_Of_RunEA+"] : "+_Comma(ProfitPerDay,2," ")+" [ "+_Comma(ProfitPerDay*35,0," ")+" / "+_Comma(ProfitPerDay*35*20,0," ")+" / "+_Comma(PercentOFFun,0," ")+"% ]";
     }
//+------------------------------------------------------------------+

   if(CNT_Round_B>0)
     {
      RateWin_BUY=100-((CNT_CutLoss_Buy/CNT_Round_B)*100);
     }
//---
   if(CNT_Round_S>0)
     {
      RateWin_SEL=100-((CNT_CutLoss_Sell/CNT_Round_S)*100);
     }
//---Round & WinRate
   _eaText16="[";
   _eaText16+="Open : "+string(CNT_Round_B)+"/"+string(CNT_Round_S)+" | ";
   _eaText16+="Loss : "+(string)CNT_CutLoss_Buy+"/"+(string)CNT_CutLoss_Sell+" | ";
   _eaText16+="Win* : "+_Comma(RateWin_BUY,2,"")+"/"+_Comma(RateWin_SEL,2,"")+" ] ";
//+------------------------------------------------------------------+
   _TEMP_DISPLAY(WindowEA);
//+------------------------------------------------------------------+

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//
   Print(StrTabs+" OnInitStrat");
//+------------------------------------------------------------------+
   _isDirectionHub();
   _StayFriday(0);

//+------------------------------------------------------------------+

   _Stat_cMax=0;
   _Stat_CNT_Round=0;
   _Stat_DDMax=0;
   _Stat_DDMax2=0;
   _Stat_DDMax_All = 0;
   _Stat_MonthDMax = 0;
   _Stat_DayDMax= 0;
   _Stat_HHDMax = 0;
   _Stat_MMDMax = 0;
   _Stat_SSDMax = 0;
   _Stat_TPPoint= 0;

   _cStat_cMax=0;
   _cStat_CNT_Round=0;
   _cStat_DDMax=0;
   _cStat_DDMax2=0;
   _cStat_DDMax_All = 0;
   _cStat_MonthDMax = 0;
   _cStat_DayDMax= 0;
   _cStat_HHDMax = 0;
   _cStat_MMDMax = 0;
   _cStat_SSDMax = 0;
   _cStat_TPPoint= 0;
   _cStat_PriceActive=0;
   _cStat_PriceActive_N=0;
   _cStat_PriceActiveCHK=0;

// ObjectCreate("ARROW_OrderF",OBJ_ARROW_RIGHT_PRICE,0,0,0);
//---Main part
   TimeStart=TimeLocal();

   _LogfileHandle("","");
   _LogfileHandle_HeadEnd(0);
//--
//_setTemplate();
   _getSpread();
   _CntBars=Bars;
   _OrdersTotal=OrdersTotal();
   _DayOfWeek=DayOfWeek();
//---
   HLineCreate(0,"RimLine_B",0,1,clrBlack,3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
   HLineCreate(0,"RimLine_S",0,1,clrBlack,3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
//--
//VLineCreate(0,"OrderF",  0,0,C'40,40,40',InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
//--
   HLineCreate(0,"HighLine",0,1,clrBlack,3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
   HLineCreate(0,"Low-Line",0,1,clrBlack,3,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);

   HLineCreate(0,"High_preLine",0,1,clrBlack,4,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
   HLineCreate(0,"Low_preLine",0,1,clrBlack,4,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
//ObjectCreate(0,"TestFiBo",OBJ_FIBO,0,TimeCurrent(),_iLow,TimeCurrent(),_iHigh);
//---

//---

   _CntMyOrder();

   if(_CntBars==Bars)
     {
      Same="Equal";
     }
   else
     {
      Same="Not Equal";
     }
   Print("[OnInit()]# _CntBars : "+_Comma(_CntBars,0,",")+"/"+_Comma(Bars,0,",")+Same);
   Print("[OnInit()]#   _Order : "+_Comma(CNT_Buy,0,",")+"/"+_Comma(CNT_Sell,0," ")+"/"+(string)CNT_ALL);

   _OrderContinue();
   _getPriceMaxMin();

//+------------------------------------------------------------------+
   _setBUTTON("BTN_BUY",0,100,25,10,30,10,clrBlack,clrLime);
   _setBUTTON("BTN_SELL",0,100,25,10,60,10,clrBlack,clrRed);
//+------------------------------------------------------------------+

//----
   Print(StrTabs+" OnInitEnd");
//---

   return(INIT_SUCCEEDED);
  }//EndOnInit
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnTick()
  {
   SendNotification("TestNotificatio");
//ObjectCreate(0,"TestFiBo",OBJ_FIBO,0,TimeCurrent(),_iLow,TimeCurrent(),_iHigh);
//+------------------------------------------------------------------+
   _DisplayNumChok(_NameEa0);
   _getPriceMaxMin();
   _isDirectionHub();
//+------------------------------------------------------------------+

//Comment(_PriceMax__Buy+"/"+_PriceMin__Buy+"|"+_PriceMax_Sell+"/"+_PriceMin_Sell+");

   if((_Minute!=_MM) && (_MM%5==0))
     {
      _Minute=_MM;
      _LogfileMAX("_Minute      ");
     }

   _cStat_PriceActive++;
   if((_cStat_PriceActiveCHK!=_MM) && (_MM%1==0))
     {
      _cStat_PriceActiveCHK=_MM;

      _Stat_PriceActive+=_cStat_PriceActive;
      _cStat_PriceActive_N++;
      _cStat_PriceActive=0;

     }

//--
//+------------------------------------------------------------------+
   if(_ChkMagicNumber())
     {
      _CntMyOrder();
      if(CNT_Buy==0)
        {
         TimeFirstOrder__Buy=0;
         aTP_All__Buy=1;
         Signal_DDClick_BUY=0;

         avg_dd_TP=0;sum_dd_TP=0;n_dd_TP=0;
        }
      else
        {
         _OrderChkTP("Buy",MagicNumber__Buy);
        }
      if(CNT_Sell==0)
        {
         TimeFirstOrder_Sell=0;
         aTP_All_Sell=1;
         Signal_DDClick_SELL=0;
         //avg_dd_TP = 0;sum_dd_TP = 0;n_dd_TP = 0;
        }
      else
        {
         _OrderChkTP("Sell",MagicNumber_Sell);
        }
      //+------------------------------------------------------------------+

      //-  

      if(_CntBars!=Bars)
        {
         _CntBars=Bars;
         _CntMyOrder();

           {
            //+------------------------------------------------------------------+
            if(CNT_Buy==0)
              {
               if(!_LatsTime_B)
                 {
                  if(_isDirectionHub()=="Green")
                    {
                     if(!_LatsTime_StayFriday)
                       {
                        Print(StrTabs+"OnTick(Buy-1)");
                        _OrderOpen("Green","1");
                       }
                    }
                 }
               else
                 {
                  Comment("LastOrder is .....BUY");
                 }
              }
            else
              {
               Print(StrTabs+"OnTick(Buy-2)");
               _OrderOpen("Green","2");
              }
            //+------------------------------------------------------------------+
            if(CNT_Sell==0)
              {
               if(!_LatsTime_S)
                 {
                  if(_isDirectionHub()=="Red")
                    {
                     if(!_LatsTime_StayFriday)
                       {
                        Print(StrTabs+"OnTick(Sell-1)");
                        _OrderOpen("Red","1");
                       }
                    }
                 }
               else
                 {
                  Comment("LastOrder is .....SELL");
                 }
              }
            else
              {
               Print(StrTabs+"OnTick(Sell-2)");
               _OrderOpen("Red","2");
              }

           }
         //+------------------------------------------------------------------+
         if(OrdersTotal()!=_OrdersTotal)
           {
            _OrdersTotal=OrdersTotal();
           }

        }
      //+------------------------------------------------------------------+
      _DisplayNumChok(_NameEa0);
      //------------------------------------
      _OrderCutLoss();              //----CutLossArea
      //------------------------------------
      _setBUTTON_State();
      //+------------------------------------------------------------------+
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                  )
  {
   if((id==CHARTEVENT_OBJECT_CLICK))
     {
      if(sparam=="BTN_BUY")
        {
         ObjectSetInteger(0,"BTN_BUY",OBJPROP_BGCOLOR,clrWhite);
         //---
         //bool z=OrderSend(Symbol(),OP_BUY,_CalculateLot(CNT_Buy),Ask,3,0,0,_NameEaLabel+(string)(CNT_Buy+1)+"/3 ["+(string)MagicNumber__Buy+"] ",MagicNumber__Buy,0);
         //aTP_All__Buy=_CalculateTP("Buy",MagicNumber__Buy,1);
         //_CntMyOrder();
         //printf(_OrderCutProfitRate(50));
         //---

        }
      if(sparam=="BTN_SELL")
        {
         ObjectSetInteger(0,"BTN_SELL",OBJPROP_BGCOLOR,clrWhite);
         //---
         //bool z=OrderSend(Symbol(),OP_SELL,_CalculateLot(CNT_Sell),Bid,3,0,0,_NameEaLabel+(string)(CNT_Sell+1)+"/3 ["+(string)MagicNumber_Sell+"] ",MagicNumber_Sell,0);
         //aTP_All_Sell=_CalculateTP("Sell",MagicNumber_Sell,1);
         //_CntMyOrder();
         //Printf(_OrderCutProfitRate(100));
         //---

        }
     }
  }

//+------------------------------------------------------------------+
