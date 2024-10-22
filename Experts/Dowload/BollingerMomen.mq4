///++--------------------------------------------------------
input double TakeProfit      = 400;
input double Stoploss        = 10000;
input double Lots            = 0.01;
input double TrailingStop    = 0;
input int    TrendPeriod  =15; 
input bool Martingale = true;
input double Multiple = 2;
input int Maxorder = 100;
input int Distance = 1250;
double total,ticket;
double askPrice;
//----------------------------------+

double OpenBuy;
void OpenBuy()
{
 ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-Stoploss*Point,Ask+TakeProfit*Point,"MomentumT2",16785,0,Green);
 askPrice=Ask;
}

double GetBB,BandsMid,BandsMidPrev,BandsUp2,BandsMid2;
void GetBB()
{
 BandsMidPrev=iBands(Symbol(),0,TrendPeriod,3,0,PRICE_CLOSE,MODE_MAIN,1);
 BandsMid=iBands(Symbol(),0,TrendPeriod,3,0,PRICE_CLOSE,MODE_MAIN,0);
 BandsMid2 = iBands(Symbol(),0,TrendPeriod,4,0,PRICE_CLOSE,MODE_MAIN,0);
 BandsUp2 = iBands(Symbol(),0,TrendPeriod,4,0,PRICE_CLOSE,MODE_UPPER,1);
}

double EntryOrder;
void EntryOrder()
{
 if(OrdersTotal()==0)
 {
  if(Close[0] > BandsMidPrev 
  && Close[0] > BandsMid
  && Close[0] > BandsMid2
  && Close[0] > BandsUp2
  )OpenBuy();
  }
}
//++-------------------------------------------------------------------------------
double Martin;
void Martin()
{
  if(Martingale)
  {
  if(CntBuy()>0 && askPrice-Ask > Distance*Point && CntBuy() < Maxorder) OpenBuy();}
}

int CntBuy()
{
 int cnt=0;
 for(int i =OrdersTotal()-1;i>=0;i--)
 {
  bool res = OrderSelect(i,SELECT_BY_POS);
  if(OrderType()==OP_BUY)
  {
   cnt++;
  }
 }
 return cnt;
}

void CloseTP()
{
if(AccountProfit() >= TakeProfit)
{
 for(int i = OrdersTotal()-1;i>=0;i--)
 {
 bool res = OrderSelect(i,SELECT_BY_POS);
 ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrBlack);
 }
}
}

void CloseForSafe()
{
 bool res;
  if(CntBuy()==Maxorder && askPrice - Ask > Distance * Point)
  {
   for(int i = OrdersTotal()-1;i>=0;i--)
   {
    res = OrderSelect(i,SELECT_BY_POS);
    if(i> Maxorder-1) continue;
    ticket = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrBlack);
   }
  }
}
double Trailing;
void Trailing()
{
 if(TrailingStop>0)
    {
     if(Bid-OrderOpenPrice()>Point*TrailingStop)
     {
      if(OrderStopLoss()<Bid-Point*TrailingStop)
      {
       //ตั้งค่าออเดอร์แล้วปิด
       if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
          Print("OrderModify Error",GetLastError());
       return;
      } 
     }
}
}
void OnTick()
{
  // Start search signal and trading
  Comment("Orders Symbol is = ",OrderSymbol()+"\n"+"Open Trade is = ",OrdersTotal()+"\n"+"Orders Profits =",AccountProfit()); 
  GetBB();
  EntryOrder();
  Martin();
  Trailing();
  CloseTP();
  CloseForSafe();
  return;
}
//+---------------------------------------------------