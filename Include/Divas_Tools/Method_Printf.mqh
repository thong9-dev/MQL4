//+------------------------------------------------------------------+
//|                                                  Magicnumber.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,string Var)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+Var+"s");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,int Var)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cI(Var)+"i");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,int d)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,d)+"d");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,2)+"d");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,bool Var)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+BoolToStr(Var));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,string Var,string VarName2,string Var2)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+Var+" "+VarName2+" : "+Var2);
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,int Var,string VarName2,int Var2)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cI(Var)+"i "+VarName2+" : "+cI(Var2)+"i");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,string VarName2,double Var2)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,2)+"d "+VarName2+" : "+cD(Var2,2)+"d");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,string VarName2,double Var2,int d)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,d)+"d "+VarName2+" : "+cD(Var2,d)+"d");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,string Var,string VarName2,string Var2,string VarName3,string Var3)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+Var+" "+VarName2+" : "+Var2+" "+VarName3+" : "+Var3);
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,int Var,string VarName2,int Var2,string VarName3,int Var3)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cI(Var)+"i "+VarName2+" : "+cI(Var2)+"i "+VarName3+" : "+cI(Var3)+"i");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,string VarName2,double Var2,string VarName3,double Var3)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,2)+"d "+VarName2+" : "+cD(Var2,2)+"d "+VarName3+" : "+cD(Var3,2)+"d");
  }
//+------------------------------------------------------------------+

void P(int Line,string FunName,string VarName,double Var,string VarName2,double Var2,string VarName3,double Var3,int d)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,d)+"d "+VarName2+" : "+cD(Var2,d)+"d "+VarName3+" : "+cD(Var3,d)+"d");
  }
//+------------------------------------------------------------------+
void P(int Line,string FunName,int err)
  {
   printf("#"+cI(Line)+"["+FunName+"] GetLastError"+cI(err)+" : "+GetLastError_toStr(err));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetLastError_toStr(int v)
  {
   switch(v)
     {
      case   0   : return "	No error returned	";
      case   1   : return "	No error returned, but the result is unknown	";
      case   2   : return "	Common error	";
      case   3   : return "	Invalid trade parameters	";
      case   4   : return "	Trade server is busy	";
      case   5   : return "	Old version of the client terminal	";
      case   6   : return "	No connection with trade server	";
      case   7   : return "	Not enough rights	";
      case   8   : return "	Too frequent requests	";
      case   9   : return "	Malfunctional trade operation	";
      case   64   : return "	Account disabled	";
      case   65   : return "	Invalid account	";
      case   128   : return "	Trade timeout	";
      case   129   : return "	Invalid price	";
      case   130   : return "	Invalid stops	";
      case   131   : return "	Invalid trade volume	";
      case   132   : return "	Market is closed	";
      case   133   : return "	Trade is disabled	";
      case   134   : return "	Not enough money	";
      case   135   : return "	Price changed	";
      case   136   : return "	Off quotes	";
      case   137   : return "	Broker is busy	";
      case   138   : return "	Requote	";
      case   139   : return "	Order is locked	";
      case   140   : return "	Buy orders only allowed	";
      case   141   : return "	Too many requests	";
      case   145   : return "	Modification denied because order is too close to market	";
      case   146   : return "	Trade context is busy	";
      case   147   : return "	Expirations are denied by broker	";
      case   148   : return "	The amount of open and pending orders has reached the limit set by the broker	";
      case   149   : return "	An attempt to open an order opposite to the existing one when hedging is disabled	";
      case   150   : return "	An attempt to close an order contravening the FIFO rule	";
      case   4000   : return "	No error returned	";
      case   4001   : return "	Wrong function pointer	";
      case   4002   : return "	Array index is out of range	";
      case   4003   : return "	No memory for function call stack	";
      case   4004   : return "	Recursive stack overflow	";
      case   4005   : return "	Not enough stack for parameter	";
      case   4006   : return "	No memory for parameter string	";
      case   4007   : return "	No memory for temp string	";
      case   4008   : return "	Not initialized string	";
      case   4009   : return "	Not initialized string in array	";
      case   4010   : return "	No memory for array string	";
      case   4011   : return "	Too long string	";
      case   4012   : return "	Remainder from zero divide	";
      case   4013   : return "	Zero divide	";
      case   4014   : return "	Unknown command	";
      case   4015   : return "	Wrong jump (never generated error)	";
      case   4016   : return "	Not initialized array	";
      case   4017   : return "	DLL calls are not allowed	";
      case   4018   : return "	Cannot load library	";
      case   4019   : return "	Cannot call function	";
      case   4020   : return "	Expert function calls are not allowed	";
      case   4021   : return "	Not enough memory for temp string returned from function	";
      case   4022   : return "	System is busy (never generated error)	";
      case   4023   : return "	DLL-function call critical error	";
      case   4024   : return "	Internal error	";
      case   4025   : return "	Out of memory	";
      case   4026   : return "	Invalid pointer	";
      case   4027   : return "	Too many formatters in the format function	";
      case   4028   : return "	Parameters count exceeds formatters count	";
      case   4029   : return "	Invalid array	";
      case   4030   : return "	No reply from chart	";
      case   4050   : return "	Invalid function parameters count	";
      case   4051   : return "	Invalid function parameter value	";
      case   4052   : return "	String function internal error	";
      case   4053   : return "	Some array error	";
      case   4054   : return "	Incorrect series array using	";
      case   4055   : return "	Custom indicator error	";
      case   4056   : return "	Arrays are incompatible	";
      case   4057   : return "	Global variables processing error	";
      case   4058   : return "	Global variable not found	";
      case   4059   : return "	Function is not allowed in testing mode	";
      case   4060   : return "	Function is not allowed for call	";
      case   4061   : return "	Send mail error	";
      case   4062   : return "	String parameter expected	";
      case   4063   : return "	Integer parameter expected	";
      case   4064   : return "	Double parameter expected	";
      case   4065   : return "	Array as parameter expected	";
      case   4066   : return "	Requested history data is in updating state	";
      case   4067   : return "	Internal trade error	";
      case   4068   : return "	Resource not found	";
      case   4069   : return "	Resource not supported	";
      case   4070   : return "	Duplicate resource	";
      case   4071   : return "	Custom indicator cannot initialize	";
      case   4072   : return "	Cannot load custom indicator	";
      case   4073   : return "	No history data	";
      case   4074   : return "	No memory for history data	";
      case   4075   : return "	Not enough memory for indicator calculation	";
      case   4099   : return "	End of file	";
      case   4100   : return "	Some file error	";
      case   4101   : return "	Wrong file name	";
      case   4102   : return "	Too many opened files	";
      case   4103   : return "	Cannot open file	";
      case   4104   : return "	Incompatible access to a file	";
      case   4105   : return "	No order selected	";
      case   4106   : return "	Unknown symbol	";
      case   4107   : return "	Invalid price	";
      case   4108   : return "	Invalid ticket	";
      case   4109   : return "	Trade is not allowed. Enable checkbox Allow live trading in the Expert Advisor properties	";
      case   4110   : return "	Longs are not allowed. Check the Expert Advisor properties	";
      case   4111   : return "	Shorts are not allowed. Check the Expert Advisor properties	";
      case   4112   : return "	Automated trading by Expert Advisors/Scripts disabled by trade server	";
      case   4200   : return "	Object already exists	";
      case   4201   : return "	Unknown object property	";
      case   4202   : return "	Object does not exist	";
      case   4203   : return "	Unknown object type	";
      case   4204   : return "	No object name	";
      case   4205   : return "	Object coordinates error	";
      case   4206   : return "	No specified subwindow	";
      case   4207   : return "	Graphical object error	";
      case   4210   : return "	Unknown chart property	";
      case   4211   : return "	Chart not found	";
      case   4212   : return "	Chart subwindow not found	";
      case   4213   : return "	Chart indicator not found	";
      case   4220   : return "	Symbol select error	";
      case   4250   : return "	Notification error	";
      case   4251   : return "	Notification parameter error	";
      case   4252   : return "	Notifications disabled	";
      case   4253   : return "	Notification send too frequent	";
      case   4260   : return "	FTP server is not specified	";
      case   4261   : return "	FTP login is not specified	";
      case   4262   : return "	FTP connection failed	";
      case   4263   : return "	FTP connection closed	";
      case   4264   : return "	FTP path not found on server	";
      case   4265   : return "	File not found in the MQL4 Files directory to send on FTP server	";
      case   4266   : return "	Common error during FTP data transmission	";
      case   5001   : return "	Too many opened files	";
      case   5002   : return "	Wrong file name	";
      case   5003   : return "	Too long file name	";
      case   5004   : return "	Cannot open file	";
      case   5005   : return "	Text file buffer allocation error	";
      case   5006   : return "	Cannot delete file	";
      case   5007   : return "	Invalid file handle (file closed or was not opened)	";
      case   5008   : return "	Wrong file handle (handle index is out of handle table)	";
      case   5009   : return "	File must be opened with FILE_WRITE flag	";
      case   5010   : return "	File must be opened with FILE_READ flag	";
      case   5011   : return "	File must be opened with FILE_BIN flag	";
      case   5012   : return "	File must be opened with FILE_TXT flag	";
      case   5013   : return "	File must be opened with FILE_TXT or FILE_CSV flag	";
      case   5014   : return "	File must be opened with FILE_CSV flag	";
      case   5015   : return "	File read error	";
      case   5016   : return "	File write error	";
      case   5017   : return "	String size must be specified for binary file	";
      case   5018   : return "	Incompatible file (for string arrays-TXT, for others-BIN)	";
      case   5019   : return "	File is directory not file	";
      case   5020   : return "	File does not exist	";
      case   5021   : return "	File cannot be rewritten	";
      case   5022   : return "	Wrong directory name	";
      case   5023   : return "	Directory does not exist	";
      case   5024   : return "	Specified file is not directory	";
      case   5025   : return "	Cannot delete directory	";
      case   5026   : return "	Cannot clean directory	";
      case   5027   : return "	Array resize error	";
      case   5028   : return "	String resize error	";
      case   5029   : return "	Structure contains strings or dynamic arrays	";
      case   5200   : return "	Invalid URL	";
      case   5201   : return "	Failed to connect to specified URL	";
      case   5202   : return "	Timeout exceeded	";
      case   5203   : return "	HTTP request failed	";
      default:  return "-";
     }
   return "-";
  }
//+------------------------------------------------------------------+
