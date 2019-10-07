//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
void EA_ExpiredAlert()
  {

   if((EA_Expire!=-1) && (TimeLocal()>=EA_TimeAlertNext || EA_TimeAlertNext==-1))
     {
      int DayUnit=46400;
      int DayAlert=DayUnit*10;         //Alert Ramian
      int DayAlertFer=DayUnit*1;       //Alert Frequency

      int Diff=int(EA_Expire-TimeLocal());

      if(Diff<DayAlert)
        {
         if(SendNotification(
            EA_HaderName+
            "\n Account: "+string(EA_Account)+
            "\n Expire: "+TimeToString(EA_Expire,TIME_DATE|TIME_MINUTES)
            ))
           {
            EA_TimeAlertNext=TimeLocal()+DayAlertFer;
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderInfo_OP(int Type,double &var,double &cnt)
  {
   var=0;
   cnt=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()==Type && 
         ((_Magic2==exLot_Mode && OrderMagicNumber()==_Magic2)||
         (_Magic2!=exLot_Mode))
         )
        {
         var+=(OrderProfit()+OrderSwap()+OrderCommission());
         cnt++;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderInfo_All(double &var,double &cnt,double &Swap,double &Comm)
  {
   var=0;
   cnt=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      ticket=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && 
         ((_Magic2==exLot_Mode && OrderMagicNumber()==_Magic2)||
         (_Magic2!=exLot_Mode)))
        {
         var+=OrderProfit();
         Swap+=OrderSwap();
         Comm+=OrderCommission();
         cnt++;
        }
     }

   var+=(Swap+Comm);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FIX_Magicnumber()
  {
   printf("s");
   string str=exMagic_Mode+" : "+_Magic;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)
         && OrderSymbol()==Symbol()
         //&& OrderMagicNumber()==_Magic
         && ((_Magic==Magicnumber && OrderMagicNumber()==_Magic) || 
         (_Magic!=Magicnumber))
         )
        {
         str+="\n"+OrderTicket()+"t |  "+OrderMagicNumber()+"mn ";
        }
     }

   Comment(str);
  }
//+------------------------------------------------------------------+
