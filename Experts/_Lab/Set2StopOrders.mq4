//+------------------------------------------------------------------+
//|                                               Set2StopOrders.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  10.01.2006 Скрипт выставляет 2 противоположных стоповых ордера. |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
#property show_inputs

//------- Внешние параметры скрипта ----------------------------------
extern string _P_Trade = "---------- Параметры торговли";
extern double Lots        = 1;     // Размер торгуемого лота
extern int    StopLoss    = 100;      // Размер фиксированного стопа
extern int    TakeProfit  = 0;       // Размер фиксированного тэйка
extern int    DistanceSet = 100;      // Расстояние от рынка
extern int    Slippage    = 3;       // Проскальзывание цены

//------- Глобальные переменные скрипта ------------------------------
string Name_Expert   = "Set2StopOrders";
bool   UseSound      = True;         // Использовать звуковой сигнал
string NameFileSound = "expert.wav"; // Наименование звукового файла
color  clOpenBuy     = LightBlue;    // Цвет ордера BuyStop
color  clOpenSell    = LightCoral;   // Цвет ордера SellStop

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
  double ldStop=0, ldTake=0;
  double pAsk=Ask+DistanceSet*Point;
  double pBid=Bid-DistanceSet*Point;

  if (StopLoss!=0) ldStop=pAsk-StopLoss*Point;
  if (TakeProfit!=0) ldTake=pAsk+TakeProfit*Point;
  SetOrder(OP_BUYSTOP, pAsk, ldStop, ldTake);

  if (StopLoss!=0) ldStop=pBid+StopLoss*Point;
  if (TakeProfit!=0) ldTake=pBid-TakeProfit*Point;
  SetOrder(OP_SELLSTOP, pBid, ldStop, ldTake);
}

//+------------------------------------------------------------------+
//| Установка ордера                                                 |
//| Параметры:                                                       |
//|   op     - операция                                              |
//|   pp     - цена                                                  |
//|   ldStop - уровень стоп                                          |
//|   ldTake - уровень тейк                                          |
//+------------------------------------------------------------------+
void SetOrder(int op, double pp, double ldStop, double ldTake) {
  color  clOpen;
  string lsComm=GetCommentForOrder();

  if (op==OP_BUYSTOP) clOpen=clOpenBuy;
  else clOpen=clOpenSell;
  OrderSend(Symbol(),op,Lots,pp,Slippage,ldStop,ldTake,lsComm,0,0,clOpen);
  if (UseSound) PlaySound(NameFileSound);
}

//+------------------------------------------------------------------+
//| Генерирует и возвращает строку коментария для ордера или позиции |
//+------------------------------------------------------------------+
string GetCommentForOrder() {
  return(Name_Expert+" "+GetNameTF(Period()));
}

//+------------------------------------------------------------------+
//| Возвращает наименование таймфрейма                               |
//+------------------------------------------------------------------+
string GetNameTF(int TimeFrame) {
	switch (TimeFrame) {
		case PERIOD_MN1: return("Monthly");
		case PERIOD_W1:  return("Weekly");
		case PERIOD_D1:  return("Daily");
		case PERIOD_H4:  return("H4");
		case PERIOD_H1:  return("H1");
		case PERIOD_M30: return("M30");
		case PERIOD_M15: return("M15");
		case PERIOD_M5:  return("M5");
		case PERIOD_M1:  return("M1");
		default:		     return("UnknownPeriod");
	}
}
//+------------------------------------------------------------------+

