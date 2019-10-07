//+------------------------------------------------------------------+
//|                                               20180717-Slave.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#define SERVER_IP             "localhost"

#include <socket-library.mqh>

//--- input parameters
input ushort      server_port = 3000;

// --------------------------------------------------------------------
// Global variables and constants
// --------------------------------------------------------------------
ClientSocket * glbClientSocket = NULL;
string symbol;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   if (glbClientSocket) {
      delete glbClientSocket;
      glbClientSocket = NULL;
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if (!glbClientSocket) {
      glbClientSocket = new ClientSocket(SERVER_IP, server_port);
      if (glbClientSocket.IsSocketConnected()) {
         Print("Client connection succeeded");
      } else {
         Print("Client connection failed");
      }
  }
   
   if (glbClientSocket.IsSocketConnected()) {
      string strMsg = StringFormat("%s;%f;%f;", SymbolFormat(Symbol()), Bid, Ask);
      glbClientSocket.Send(strMsg);
   }
   
   if (!glbClientSocket.IsSocketConnected()) {
      Print("Client disconnected. Will retry.");
      delete glbClientSocket;
      glbClientSocket = NULL;
   }
}

string SymbolFormat(string _symbol) {
   string result = StringSubstr(_symbol, 0, 6);
   StringToUpper(result);
   return result;
}
