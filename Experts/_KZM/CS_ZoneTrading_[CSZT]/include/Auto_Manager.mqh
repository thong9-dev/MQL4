//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "../CS_eZoneTrading.mq4"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AutoPending_AdamsLock=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoPending_Adams()
  {
   int OrderMagic=1;
//---
   int Send_=1;
   bool Found=false,Chk_Del=false;
   double TP=-1,lot=-1;
   string Spector="#";
   int OP_HaveInDock=0;
//---
   if(!AutoPending_AdamsLock)
     {
      for(int i=0;i<ArraySize(TroopA)-1;i++)
         printf("["+c(i)+"]"+c(TroopA[i],Digits));
      AutoPending_AdamsLock=true;
     }

   for(int i=0;i<ArraySize(TroopA)-1;i++)
     {
      Found=false;
      OP_HaveInDock=0;
      //---

      //
/*if((TP_UseATR && TP_UseATR)==false)
        {
         if(ATR<STOPLEVEL)
            ATR=STOPLEVEL;
         if(TP_UseATR)TP=TroopA[i]+ATR;
         //
       
         if(TP_UseSPREAD && ATR<200/MathPow(10,Digits))
            TP=TP-(SPREADavg/MathPow(10,Digits));
        }*/
      NormalizeDouble(TP,Digits);
      //---

      lot=LotGet(Capital,TroopA[i],DeadLine);
      lot=StringToDouble(c(lot,2));
      TP=TroopA[i+1];
      for(int pos=0;pos<OrdersTotal()/* && lot>0*/;pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if((OrderSymbol()==Symbol())==false) continue;
         if((OrderMagicNumber()==OrderMagic)==false) continue;

         // printf(l(__LINE__)+OrderTicket());
         double _OrderOpenPrice=OrderOpenPrice();
         double Slippagep=(Slippage+1)/MathPow(10,Digits);
         //---

         if(((TroopA[i]-Slippagep)<=(_OrderOpenPrice)) && ((_OrderOpenPrice)<(TroopA[i+1]-Slippagep)))
           {
            Found=true;
            if(OrderType()>=2)
              {
               double OrderLots_=StringToDouble(c(OrderLots(),2));
               bool OrderLots_b=(OrderLots_!=lot);
               bool BASE_b=TroopA[i]!=OrderOpenPrice();

               if(OrderLots_b || BASE_b)
                 {
                  //printf("["+OrderLots_b+"]:"+OrderLots_+"|"+lot+" # ["+BASE_b+"]"+TroopA[i]+"|"+OrderOpenPrice());
                  Chk_Del=OrderDelete(OrderTicket(),0);
                  //---
                  if(TroopA[i]>Ask && OP_HaveInDock<=1)
                    {
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,TroopA[i],Slippage,0,TP,Spector+c(i)+"_PN_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (TroopA[i]<=Ask && Ask<TroopA[i+1]))
                       {
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,Spector+c(i)+"_AC_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                  else if(TroopA[i]<Ask && OP_HaveInDock<=1)
                    {
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYLIMIT,lot,TroopA[i],Slippage,0,TP,Spector+c(i)+"_PN_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (TroopA[i]<=Ask && Ask<TroopA[i+1]))
                       {
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,Spector+c(i)+"_AC_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                 }
               else
                 {
                  if(OrderTakeProfit()!=TP)
                    {
                     if(OrderOpenPrice()<TP)
                       {
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,TP,0,clrGold);
                       }
                     else
                       {
                        double d=MathAbs(TroopA[i]-TroopA[i+1]);
                        d=NormalizeDouble(OrderOpenPrice()+(d*0.75),Digits);
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,d,0,clrYellow);
                       }
                    }
                 }
              }
            else
              {
               if(OrderTakeProfit()!=TP)
                 {
                  if(OrderOpenPrice()<TP)
                    {
                     Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP,0,clrGold);
                    }
                  else
                    {
                     double d=MathAbs(TroopA[i]-TroopA[i+1]);
                     d=NormalizeDouble(OrderOpenPrice()+(d*0.75),Digits);
                     Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),d,0,clrYellow);
                    }
                 }
               if(TroopA[i]==_OrderOpenPrice)
                 {
                  OP_HaveInDock++;
                 }
              }
           }
        }
      //
      //---
      if(Found==false && lot>0)
        {
         if(TroopA[i]>Ask && OP_HaveInDock<=1)
           {
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,TroopA[i],Slippage,0,TP,Spector+c(i)+"_PN_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (TroopA[i]<=Ask && Ask<TroopA[i+1]))
              {
               ResetLastError();
               Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,Spector+c(i)+"_AC_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
         else if(TroopA[i]<Ask && OP_HaveInDock<=1)
           {
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_BUYLIMIT,lot,TroopA[i],Slippage,0,TP,Spector+c(i)+"_PN_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (TroopA[i]<=Ask && Ask<TroopA[i+1]))
              {
               ResetLastError();
               Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,Spector+c(i)+"_AC_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
        }
     }
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderSymbol()==Symbol())==false) continue;
      if((OrderMagicNumber()==OrderMagic)==false) continue;
      if(OrderType()<=1) continue;

      if(OrderOpenPrice()<TroopA[0] || OrderOpenPrice()>TroopA[ArraySize(TroopA)-1])
        {
         bool  z=OrderDelete(OrderTicket(),0);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoPending_Boston()
  {
   int OrderMagic=2;
//---
   int Send_=1;
   bool Found=false,Chk_Del=false;
   double Pin=-1,TP=-1,lot=-1;
   string Spector="",OP_Cm="";;
   int OP_HaveInDock=0;

   for(int i=0;i<ArraySize(TroopB_PTP)-1;i++)
     {
      Found=false;
      OP_HaveInDock=0;
      Spector="";if(MathMod(i,Zone_B_cnt)==0) Spector="*";

      //---
      Pin=TroopB_PTP[i]/*+(1/MathPow(10,Digits))*/;
      TP=TroopB_PTP[i+1];
      //
      if((TP_UseATR && TP_UseATR)==false)
        {
         if(ATR<STOPLEVEL)
            ATR=STOPLEVEL;
         if(TP_UseATR)TP=Pin+ATR;
         //
         double d=MathAbs(Pin-TP);
         if(TP_UseSPREAD && ATR<d)
            TP=TP-(SPREADavg/MathPow(10,Digits))*1.123;
        }
      NormalizeDouble(TP,Digits);

      //---
      if(Calculate_Margin)
         lot=LotGet_Magin(Capital,Pin,DeadLine);
      else
         lot=LotGet(Capital,Pin,DeadLine);
      lot=StringToDouble(c(lot,2));

      double Pin_Capital=_Pin_Capital;
      double Pin_Magin=_Pin_Magin;

      for(int pos=0;pos<OrdersTotal() && lot>0;pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if((OrderSymbol()==Symbol())==false) continue;
         if((OrderMagicNumber()==OrderMagic)==false) continue;

         // printf(l(__LINE__)+OrderTicket());
         double _OrderOpenPrice=OrderOpenPrice();
         double Slippagep=(Slippage+1)/MathPow(10,Digits);

         if(((TroopB_PTP[i]-Slippagep)<=(_OrderOpenPrice)) && ((_OrderOpenPrice)<(TroopB_PTP[i+1]-Slippagep)))
           {
            Found=true;

            if(OrderType()>=2)
              {
               double OrderLots_=StringToDouble(c(OrderLots(),2));
               bool OrderLots_b=(OrderLots_!=lot);
               if(OrderLots_b || (TroopB_PTP[i]!=OrderOpenPrice()))
                 {
                  Chk_Del=OrderDelete(OrderTicket(),0);
                  //---
                  if(TroopB_PTP[i]>Ask && OP_HaveInDock==0)
                    {
                     OP_Cm=Spector+c(i)+"_P1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
                       {
                        OP_Cm=Spector+c(i)+"_A1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                  else if(TroopB_PTP[i]<Ask && OP_HaveInDock==0)
                    {
                     OP_Cm=Spector+c(i)+"_P1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYLIMIT,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
                       {
                        OP_Cm=Spector+c(i)+"_A1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                 }
               else
                 {

                  if(OrderTakeProfit()!=TP)
                    {//Slippage
                     if(OrderOpenPrice()<TP && TP!=TroopB_PTP[i])
                       {
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,TP,0,clrGold);
                       }
                     else
                       {
                        double d=MathAbs(TroopB_PTP[i]-TroopB_PTP[i+1]);
                        d=NormalizeDouble(OrderOpenPrice()+d,Digits);
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,d,0,clrYellow);
                       }
                    }
                 }
               if(OP_HaveInDock>1 || TroopB_PTP[i]!=OrderOpenPrice())
                 {
                  Chk_Del=OrderDelete(OrderTicket(),0);
                 }
              }
            else
              {
               OP_HaveInDock++;
               if(OrderTakeProfit()!=TP)
                 {
                  if(OrderOpenPrice()<TP)
                    {
                     Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP,0,clrGold);
                    }
                  else
                    {
                     double d=MathAbs(TroopB_PTP[i]-TroopB_PTP[i+1]);
                     d=NormalizeDouble(OrderOpenPrice()+(d*0.75),Digits);
                     //Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),d,0,clrYellow);
                    }
                 }
              }
           }
        }
      //
      //---
      if(Found==false && lot>0)
        {
         if(TroopB_PTP[i]>Ask && OP_HaveInDock==0)
           {
            OP_Cm=Spector+c(i)+"_P2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
              {
               OP_Cm=Spector+c(i)+"_A2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
               ResetLastError();
               //Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
         else if(TroopB_PTP[i]<Ask && OP_HaveInDock==0)
           {
            OP_Cm=Spector+c(i)+"_P2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_BUYLIMIT,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
              {
               OP_Cm=Spector+c(i)+"_A2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
               ResetLastError();
               //Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,Spector+c(i)+"_AC_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
        }
     }
//---
   for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderSymbol()==Symbol())==false) continue;
      if((OrderMagicNumber()==OrderMagic)==false) continue;
      if(OrderType()<=1) continue;

      if(OrderOpenPrice()<TroopB_PTP[0] || OrderOpenPrice()>TroopB_PTP[ArraySize(TroopB_PTP)-1])
        {
         bool  z=OrderDelete(OrderTicket(),0);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AutoPending_Sell()
  {
   int Period_=int(((PERIOD_MN1*12*Guide_YN)/PERIOD_MN1)*2);
   double val_H=-1;
//
   int _iHigh_High=iHighest(Symbol(),PERIOD_MN1,MODE_HIGH,Period_,0);
   if(_iHigh_High!=0) val_H=iHigh(Symbol(),PERIOD_MN1,_iHigh_High);

   HLineCreate(0,ExtName_OBJ+"LINE_DeadLine_Sell(Auto)","DeadLine_Sell(Auto) "+c(Period_)+"MN",0,val_H,clrRed,2,0,false,true,false,false,0);
//+------------------------------
   int OrderMagic=3;
//---
   int Send_=1;
   bool Found=false,Chk_Del=false;
   double Pin=-1,TP=-1,lot=-1;
   string Spector="",OP_Cm="";;
   int OP_HaveInDock=0;

   lot=0.01;

   for(int i=1;i<ArraySize(TroopB_PTP)-1;i++)
     {
      //---
      Pin=TroopB_PTP[i]/*+(1/MathPow(10,Digits))*/;
      TP=TroopB_PTP[i-1];
      //
      if(Pin>Bid) continue;
      Found=false;
      OP_HaveInDock=0;
      Spector="";if(MathMod(i,Zone_B_cnt)==0) Spector="*";

/* if((TP_UseATR && TP_UseATR)==false)
        {
         if(ATR<STOPLEVEL)
            ATR=STOPLEVEL;
         if(TP_UseATR)TP=Pin+ATR;
         //
         double d=MathAbs(Pin-TP);
         if(TP_UseSPREAD && ATR<d)
            TP=TP-(SPREADavg/MathPow(10,Digits))*1.123;
        }
      NormalizeDouble(TP,Digits);

      //---
      if(Calculate_Margin)
         lot=LotGet_Magin(Capital,Pin,DeadLine);
      else
         lot=LotGet(Capital,Pin,DeadLine);
      lot=StringToDouble(c(lot,2));
*/
      double Pin_Capital=_Pin_Capital;
      double Pin_Magin=_Pin_Magin;

      for(int pos=0;pos<OrdersTotal();pos++)
        {
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         if((OrderSymbol()==Symbol())==false) continue;
         if((OrderMagicNumber()==OrderMagic)==false) continue;

         // printf(l(__LINE__)+OrderTicket());
         double _OrderOpenPrice=OrderOpenPrice();
         //             3
         bool Base=MathAbs(TroopB_PTP[i]-_OrderOpenPrice)<=Slippage/MathPow(10,Digits);
         if(Base && _OrderOpenPrice<TroopB_PTP[i+1])
           {
            Found=true;
            if(OrderType()>=2)
              {

               double OrderLots_=StringToDouble(c(OrderLots(),2));
               bool OrderLots_b=(OrderLots_!=lot);
               if(OrderLots_b || (TroopB_PTP[i]!=OrderOpenPrice()))
                 {
                  Chk_Del=OrderDelete(OrderTicket(),0);
                  //---
                  if(TroopB_PTP[i]>Ask && OP_HaveInDock==0)
                    {
                     OP_Cm=Spector+c(i)+"_P1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
                       {
                        OP_Cm=Spector+c(i)+"_A1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                  else if(TroopB_PTP[i]<Ask && OP_HaveInDock==0)
                    {
                     OP_Cm=Spector+c(i)+"_P1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                     ResetLastError();
                     Send_=OrderSend(Symbol(),OP_BUYLIMIT,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                     checkError=GetLastError();
                     if(checkError==ERR_NO_ERROR)
                        OP_HaveInDock++;
                     else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
                       {
                        OP_Cm=Spector+c(i)+"_A1_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
                        ResetLastError();
                        Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
                        checkError=GetLastError();
                        if(checkError==ERR_NO_ERROR)
                           OP_HaveInDock++;
                       }
                    }
                 }
               else
                 {

                  if(OrderTakeProfit()!=TP)
                    {
                     if(OrderOpenPrice()<TP)
                       {
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,TP,0,clrGold);
                       }
                     else
                       {
                        double d=MathAbs(TroopB_PTP[i]-TroopB_PTP[i+1]);
                        d=NormalizeDouble(OrderOpenPrice()+(d*0.75),Digits);
                        Send_=OrderModify(OrderTicket(),OrderOpenPrice(),0,d,0,clrYellow);
                       }
                    }
                 }
              }
            else
              {
               OP_HaveInDock++;
               if(OrderTakeProfit()!=TP)
                 {
                  if(OrderOpenPrice()<TP)
                    {
                     Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP,0,clrGold);
                    }
                  else
                    {
                     double d=MathAbs(TroopB_PTP[i]-TroopB_PTP[i+1]);
                     d=NormalizeDouble(OrderOpenPrice()+(d*0.75),Digits);
                     Send_=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),d,0,clrYellow);
                    }
                 }
/*if(MathAbs(TroopB_PTP[i]-_OrderOpenPrice)<=10/MathPow(10,Digits))
                 {
                  OP_HaveInDock++;
                 }*/
              }
           }
        }
      //
      //---
      if(Found==false)
        {
/* if(TroopB_PTP[i]>Ask && OP_HaveInDock==0)
           {
            OP_Cm=Spector+c(i)+"_P2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_BUYSTOP,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
              {
               OP_Cm=Spector+c(i)+"_A2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
               ResetLastError();
               //Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,OP_Cm+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
         else */if(TroopB_PTP[i]<Ask && OP_HaveInDock==0)
           {
            OP_Cm=Spector+c(i)+"_P2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
            ResetLastError();
            Send_=OrderSend(Symbol(),OP_SELLSTOP,lot,Pin,Slippage,0,TP,OP_Cm+l(__LINE__)+c(TroopB_PTP[i],Digits),OrderMagic,0);
            checkError=GetLastError();
            if(checkError==ERR_NO_ERROR)
               OP_HaveInDock++;
            else if(checkError!=ERR_NO_ERROR && (TroopB_PTP[i]<=Ask && Ask<TroopB_PTP[i+1]))
              {
               OP_Cm=Spector+c(i)+"_A2_"+c(Pin_Capital,2)+":"+c(Pin_Magin,2);
               ResetLastError();
               //Send_=OrderSend(Symbol(),OP_BUY,lot,Ask,Slippage,0,TP,Spector+c(i)+"_AC_"+c(Capital,2)+l(__LINE__),OrderMagic,0);
               checkError=GetLastError();
               if(checkError==ERR_NO_ERROR)
                  OP_HaveInDock++;
              }
           }
        }
     }
//---
/*for(int pos=0;pos<OrdersTotal();pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderSymbol()==Symbol())==false) continue;
      if((OrderMagicNumber()==OrderMagic)==false) continue;
      if(OrderType()<=1) continue;

      if(OrderOpenPrice()<TroopB_PTP[0] || OrderOpenPrice()>TroopB_PTP[ArraySize(TroopB_PTP)-1])
        {
         bool  z=OrderDelete(OrderTicket(),0);
        }
     }*/
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Delete_Pending(int Order_Type,int Order_Magic)
  {
   int Ticket_Delete[];
   ArrayResize(Ticket_Delete,OrdersTotal(),0);
   for(int pos=0,i=0;pos<OrdersTotal();pos++,i++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if((OrderSymbol()==Symbol())==false) continue;
      if((OrderMagicNumber()==Order_Magic)==false) continue;
      if((OrderType()==Order_Type)==false) continue;
      //---
      Ticket_Delete[i]=OrderTicket();
     }
//---
   for(int i=0;i<ArraySize(Ticket_Delete);i++)
     {
      if(Ticket_Delete[i]>0)
         bool  z=OrderDelete(Ticket_Delete[i],0);
     }
  }
double ContractSize=MarketInfo(Symbol(),MODE_LOTSIZE);
double MODE_POINT_=MarketInfo(Symbol(),MODE_POINT);
//+------------------------------------------------------------------+
double _Pin_Capital=0;
double _Pin_Magin=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  LotGet_Magin(double cap,double Traget_1,double Traget_2)
  {
   double Temp_cap=cap;
//---
   double Magin;
   double D=MathAbs(Traget_2-Traget_1);
   double Lot;
//Lot=MathAbs(Lot);
//Lot=NormalizeDouble(Lot,2);
//---
   double Test_do=-1;
   do
     {
      Temp_cap-=0.01;
      Lot=(Temp_cap*Traget_1)/(D*ContractSize);
      Magin=MaginGet(Traget_1,Lot);

      Temp_cap=NormalizeDouble(Temp_cap,2);
      Magin=NormalizeDouble(Magin,2);

      Test_do=Temp_cap+Magin;
     }
   while(!(Test_do==cap));
   _Pin_Capital=NormalizeDouble(Temp_cap,2);
   _Pin_Magin=NormalizeDouble(Magin,2);

//printf(l(__LINE__,Test_do)+"C: "+c(Temp_cap,2)+" M: "+Magin+" L: "+Lot);
   return Lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  LotGet(double cap,double Traget_1,double Traget_2)
  {
   double cap_=CoverCurrency(cap,AccountInfoString(ACCOUNT_CURRENCY),StringSubstr(Symbol(),0,3));

//double Magin=getMagin(double bid,double lots);
   double D=(Traget_2-Traget_1);
   double Lot=(cap_*Traget_1)/(D*ContractSize);
   Lot=MathAbs(Lot);
   Lot=NormalizeDouble(Lot,2);

   _Pin_Capital=cap;
   return Lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MaginGet(double bid,double lots)
  {
   long LEVERAGE=AccountInfoInteger(ACCOUNT_LEVERAGE);
   return NormalizeDoubleCut(((lots*ContractSize*bid)/LEVERAGE)/bid,3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void debug_SPREAD_DeleteAll()
  {
   for(int i=0;i<GlobalVariablesTotal();i++)
     {
      string name=GlobalVariableName(i);
      GlobalVariablesDeleteAll(name,0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void debug_SPREAD()
  {
   string mscm;
/*double _rand=double(MathRand());
   double _per=NormalizeDouble(_rand/32767,2);
   mscm+=l(__LINE__,"_per")+_per+"\n";*/

   int sp=int(MarketInfo(Symbol(),MODE_SPREAD));
//mscm+=l(__LINE__,"sp")+sp+"\n";

   datetime  _GlobalVariableSet;
//if(_per>=0.5)
     {
      _GlobalVariableSet=GlobalVariableSet(Symbol(),GlobalVariableGet(Symbol())+sp);
      _GlobalVariableSet=GlobalVariableSet(Symbol()+"n",GlobalVariableGet(Symbol()+"n")+1);
     }
/*mscm+=l(__LINE__)+"*************************************\n";
   mscm+=l(__LINE__,"GlobalVariablesTotal()")+GlobalVariablesTotal()+"\n";
   mscm+=l(__LINE__)+"------------------------------\n";*/
   double sum=GlobalVariableGet(Symbol());
   double cnt=GlobalVariableGet(Symbol()+"n");
   int avg=int(sum/cnt);
/*mscm+=l(__LINE__,"Avg")+avg+"\n";
   mscm+=l(__LINE__)+"------------------------------\n";*/
   for(int i=0;i<GlobalVariablesTotal();i++)
     {
      string name=GlobalVariableName(i);
      //mscm+=l(__LINE__,name)+GlobalVariableGet(name);
      if(name==Symbol())
         mscm+=" <----";
      mscm+="\n";
     }
   mscm+=l(__LINE__)+"------------------------------\n";
//---
   SPREADsum=GlobalVariableGet(Symbol());
   SPREADcnt=GlobalVariableGet(Symbol()+"n");
   SPREADavg=int(SPREADsum/SPREADcnt);
//Comment(mscm);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CoverCurrency(double cap,string c1,string c2)
  {
   double r=0;
   if(c1==c2)
     {
      r=cap;
      //printf(l(__LINE__,"Is already "+c1));
     }
   else
     {
      string Pair_1=c1+c2;
      string Pair_2=c2+c1;
      double Rate_1=MarketInfo(Pair_1,MODE_BID);
      double Rate_2=MarketInfo(Pair_2,MODE_BID);

      printf(l(__LINE__,"Rate_1:"+Pair_1)+c(Rate_1,int(MarketInfo(Pair_1,MODE_DIGITS))));
      printf(l(__LINE__,"Rate_2:"+Pair_2)+c(Rate_2,int(MarketInfo(Pair_2,MODE_DIGITS))));
      if(Rate_1>0)
        {
         int digit=int(MarketInfo(Pair_1,MODE_DIGITS));
         printf(l(__LINE__,"Rate_1:[*]"+Pair_1)+c(Rate_1,digit));

         r=cap*Rate_1;
         r=NormalizeDouble(r,digit);
        }
      else if(Rate_2>0)
        {
         int digit=int(MarketInfo(Pair_2,MODE_DIGITS));
         printf(l(__LINE__,"Rate_2:[/]"+Pair_2)+c(Rate_2,digit));

         r=cap/Rate_2;
         r=NormalizeDouble(r,digit);
        }
     }

   return NormalizeDoubleCut(r,2);
  }
//+------------------------------------------------------------------+
