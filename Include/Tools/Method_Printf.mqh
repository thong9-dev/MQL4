//|                                                  Magicnumber.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |

#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <Tools/Method_Tools.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string l(int Line)
  {
   return "#"+string(Line)+" ";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string l(int Line,string VarName)
  {
   return "#"+string(Line)+" "+" | "+VarName+" : ";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,string Var)
  {
   printf("#"+c(Line)+"["+FunName+"] "+VarName+" : "+Var+"s");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,int Var)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cI(Var)+"i");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,int d)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,d)+"d");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,2)+"d");
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,int Var,string VarName2,int Var2)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cI(Var)+"i "+VarName2+" : "+cI(Var2)+"i");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,string VarName2,double Var2)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,2)+"d "+VarName2+" : "+cD(Var2,2)+"d");
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,int Var,string VarName2,int Var2,string VarName3,int Var3)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cI(Var)+"i "+VarName2+" : "+cI(Var2)+"i "+VarName3+" : "+cI(Var3)+"i");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,string VarName2,double Var2,string VarName3,double Var3)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,2)+"d "+VarName2+" : "+cD(Var2,2)+"d "+VarName3+" : "+cD(Var3,2)+"d");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void P(int Line,string FunName,string VarName,double Var,string VarName2,double Var2,string VarName3,double Var3,int d)
  {
   printf("#"+cI(Line)+"["+FunName+"] "+VarName+" : "+cD(Var,d)+"d "+VarName2+" : "+cD(Var2,d)+"d "+VarName3+" : "+cD(Var3,d)+"d");
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+
int Statement_Err=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetLastErrorStr(int statement)
  {
   Statement_Err=statement;
   printf(GetLastErrorStr());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetLastErrorStr()
  {
   string v="";
   switch(Statement_Err)
     {
      case    ERR_NO_ERROR:v="0	No error returned";  break;
      case    ERR_NO_RESULT:v="1	No error returned, but the result is unknown";  break;
      case    ERR_COMMON_ERROR:v="2	Common erro";  break;
      case    ERR_INVALID_TRADE_PARAMETERS:v="3	Invalid trade parameters";  break;
      case    ERR_SERVER_BUSY:v="4	Trade server is bus";  break;
      case    ERR_OLD_VERSION:v="5	Old version of the client terminal";  break;
      case    ERR_NO_CONNECTION:v="6	No connection with trade serve";  break;
      case    ERR_NOT_ENOUGH_RIGHTS:v="7	Not enough rights";  break;
      case    ERR_TOO_FREQUENT_REQUESTS:v="8	Too frequent request";  break;
      case    ERR_MALFUNCTIONAL_TRADE:v="9	Malfunctional trade operation";  break;
      case    ERR_ACCOUNT_DISABLED:v="64	Account disable";  break;
      case    ERR_INVALID_ACCOUNT:v="65	Invalid account";  break;
      case    ERR_TRADE_TIMEOUT:v="128	Trade timeou";  break;
      case    ERR_INVALID_PRICE:v="129	Invalid price";  break;
      case    ERR_INVALID_STOPS:v="130	Invalid stop";  break;
      case    ERR_INVALID_TRADE_VOLUME:v="131	Invalid trade volume";  break;
      case    ERR_MARKET_CLOSED:v="132	Market is close";  break;
      case    ERR_TRADE_DISABLED:v="133	Trade is disabled";  break;
      case    ERR_NOT_ENOUGH_MONEY:v="134	Not enough mone";  break;
      case    ERR_PRICE_CHANGED:v="135	Price changed";  break;
      case    ERR_OFF_QUOTES:v="136	Off quote";  break;
      case    ERR_BROKER_BUSY:v="137	Broker is busy";  break;
      case    ERR_REQUOTE:v="138	Requot";  break;
      case    ERR_ORDER_LOCKED:v="139	Order is locked";  break;
      case    ERR_LONG_POSITIONS_ONLY_ALLOWED:v="140	Buy orders only allowe";  break;
      case    ERR_TOO_MANY_REQUESTS:v="141	Too many requests";  break;
      case    ERR_TRADE_MODIFY_DENIED:v="145	Modification denied because order is too close to marke";  break;
      case    ERR_TRADE_CONTEXT_BUSY:v="146	Trade context is busy";  break;
      case    ERR_TRADE_EXPIRATION_DENIED:v="147	Expirations are denied by broke";  break;
      case    ERR_TRADE_TOO_MANY_ORDERS:v="148	The amount of open and pending orders has reached the limit set by the broker";  break;
      case    ERR_TRADE_HEDGE_PROHIBITED:v="149	An attempt to open an order opposite to the existing one when hedging is disable";  break;
      case    ERR_TRADE_PROHIBITED_BY_FIFO:v="150	An attempt to close an order contravening the FIFO rule";  break;
      case    ERR_NO_MQLERROR:v="4000	No error returne";  break;
      case    ERR_WRONG_FUNCTION_POINTER:v="4001	Wrong function pointer";  break;
      case    ERR_ARRAY_INDEX_OUT_OF_RANGE:v="4002	Array index is out of rang";  break;
      case    ERR_NO_MEMORY_FOR_CALL_STACK:v="4003	No memory for function call stack";  break;
      case    ERR_RECURSIVE_STACK_OVERFLOW:v="4004	Recursive stack overflo";  break;
      case    ERR_NOT_ENOUGH_STACK_FOR_PARAM:v="4005	Not enough stack for parameter";  break;
      case    ERR_NO_MEMORY_FOR_PARAM_STRING:v="4006	No memory for parameter strin";  break;
      case    ERR_NO_MEMORY_FOR_TEMP_STRING:v="4007	No memory for temp string";  break;
      case    ERR_NOT_INITIALIZED_STRING:v="4008	Not initialized strin";  break;
      case    ERR_NOT_INITIALIZED_ARRAYSTRING:v="4009	Not initialized string in array";  break;
      case    ERR_NO_MEMORY_FOR_ARRAYSTRING:v="4010	No memory for array strin";  break;
      case    ERR_TOO_LONG_STRING:v="4011	Too long string";  break;
      case    ERR_REMAINDER_FROM_ZERO_DIVIDE:v="4012	Remainder from zero divid";  break;
      case    ERR_ZERO_DIVIDE:v="4013	Zero divide";  break;
      case    ERR_UNKNOWN_COMMAND:v="4014	Unknown comman";  break;
      case    ERR_WRONG_JUMP:v="4015	Wrong jump (never generated error)";  break;
      case    ERR_NOT_INITIALIZED_ARRAY:v="4016	Not initialized arra";  break;
      case    ERR_DLL_CALLS_NOT_ALLOWED:v="4017	DLL calls are not allowed";  break;
      case    ERR_CANNOT_LOAD_LIBRARY:v="4018	Cannot load librar";  break;
      case    ERR_CANNOT_CALL_FUNCTION:v="4019	Cannot call function";  break;
      case    ERR_EXTERNAL_CALLS_NOT_ALLOWED:v="4020	Expert function calls are not allowe";  break;
      case    ERR_NO_MEMORY_FOR_RETURNED_STR:v="4021	Not enough memory for temp string returned from function";  break;
      case    ERR_SYSTEM_BUSY:v="4022	System is busy (never generated error";  break;
      case    ERR_DLLFUNC_CRITICALERROR:v="4023	DLL-function call critical error";  break;
      case    ERR_INTERNAL_ERROR:v="4024	Internal erro";  break;
      case    ERR_OUT_OF_MEMORY:v="4025	Out of memory";  break;
      case    ERR_INVALID_POINTER:v="4026	Invalid pointe";  break;
      case    ERR_FORMAT_TOO_MANY_FORMATTERS:v="4027	Too many formatters in the format function";  break;
      case    ERR_FORMAT_TOO_MANY_PARAMETERS:v="4028	Parameters count exceeds formatters coun";  break;
      case    ERR_ARRAY_INVALID:v="4029	Invalid array";  break;
      case    ERR_CHART_NOREPLY:v="4030	No reply from char";  break;
      case    ERR_INVALID_FUNCTION_PARAMSCNT:v="4050	Invalid function parameters count";  break;
      case    ERR_INVALID_FUNCTION_PARAMVALUE:v="4051	Invalid function parameter valu";  break;
      case    ERR_STRING_FUNCTION_INTERNAL:v="4052	String function internal error";  break;
      case    ERR_SOME_ARRAY_ERROR:v="4053	Some array erro";  break;
      case    ERR_INCORRECT_SERIESARRAY_USING:v="4054	Incorrect series array using";  break;
      case    ERR_CUSTOM_INDICATOR_ERROR:v="4055	Custom indicator erro";  break;
      case    ERR_INCOMPATIBLE_ARRAYS:v="4056	Arrays are incompatible";  break;
      case    ERR_GLOBAL_VARIABLES_PROCESSING:v="4057	Global variables processing erro";  break;
      case    ERR_GLOBAL_VARIABLE_NOT_FOUND:v="4058	Global variable not found";  break;
      case    ERR_FUNC_NOT_ALLOWED_IN_TESTING:v="4059	Function is not allowed in testing mod";  break;
      case    ERR_FUNCTION_NOT_CONFIRMED:v="4060	Function is not allowed for call";  break;
      case    ERR_SEND_MAIL_ERROR:v="4061	Send mail erro";  break;
      case    ERR_STRING_PARAMETER_EXPECTED:v="4062	String parameter expected";  break;
      case    ERR_INTEGER_PARAMETER_EXPECTED:v="4063	Integer parameter expecte";  break;
      case    ERR_DOUBLE_PARAMETER_EXPECTED:v="4064	Double parameter expected";  break;
      case    ERR_ARRAY_AS_PARAMETER_EXPECTED:v="4065	Array as parameter expecte";  break;
      case    ERR_HISTORY_WILL_UPDATED:v="4066	Requested history data is in updating state";  break;
      case    ERR_TRADE_ERROR:v="4067	Internal trade erro";  break;
      case    ERR_RESOURCE_NOT_FOUND:v="4068	Resource not found";  break;
      case    ERR_RESOURCE_NOT_SUPPORTED:v="4069	Resource not supporte";  break;
      case    ERR_RESOURCE_DUPLICATED:v="4070	Duplicate resource";  break;
      case    ERR_INDICATOR_CANNOT_INIT:v="4071	Custom indicator cannot initializ";  break;
      case    ERR_INDICATOR_CANNOT_LOAD:v="4072	Cannot load custom indicator";  break;
      case    ERR_NO_HISTORY_DATA:v="4073	No history dat";  break;
      case    ERR_NO_MEMORY_FOR_HISTORY:v="4074	No memory for history data";  break;
      case    ERR_NO_MEMORY_FOR_INDICATOR:v="4075	Not enough memory for indicator calculatio";  break;
      case    ERR_END_OF_FILE:v="4099	End of file";  break;
      case    ERR_SOME_FILE_ERROR:v="4100	Some file erro";  break;
      case    ERR_WRONG_FILE_NAME:v="4101	Wrong file name";  break;
      case    ERR_TOO_MANY_OPENED_FILES:v="4102	Too many opened file";  break;
      case    ERR_CANNOT_OPEN_FILE:v="4103	Cannot open file";  break;
      case    ERR_INCOMPATIBLE_FILEACCESS:v="4104	Incompatible access to a fil";  break;
      case    ERR_NO_ORDER_SELECTED:v="4105	No order selected";  break;
      case    ERR_UNKNOWN_SYMBOL:v="4106	Unknown symbo";  break;
      case    ERR_INVALID_PRICE_PARAM:v="4107	Invalid price";  break;
      case    ERR_INVALID_TICKET:v="4108	Invalid ticke";  break;
      case    ERR_TRADE_NOT_ALLOWED:v="4109	Trade is not allowed. Enable checkbox \"Allow live trading\" in the Expert Advisor properties";  break;
      case    ERR_LONGS_NOT_ALLOWED:v="4110	Longs are not allowed. Check the Expert Advisor propertie";  break;
      case    ERR_SHORTS_NOT_ALLOWED:v="4111	Shorts are not allowed. Check the Expert Advisor properties";  break;
      case    ERR_TRADE_EXPERT_DISABLED_BY_SERVER :v="4112	Automated trading by Expert Advisors/Scripts disabled by trade serve";  break;
      case    ERR_OBJECT_ALREADY_EXISTS:v="4200	Object already exists";  break;
      case    ERR_UNKNOWN_OBJECT_PROPERTY:v="4201	Unknown object propert";  break;
      case    ERR_OBJECT_DOES_NOT_EXIST:v="4202	Object does not exist";  break;
      case    ERR_UNKNOWN_OBJECT_TYPE:v="4203	Unknown object typ";  break;
      case    ERR_NO_OBJECT_NAME:v="4204	No object name";  break;
      case    ERR_OBJECT_COORDINATES_ERROR:v="4205	Object coordinates erro";  break;
      case    ERR_NO_SPECIFIED_SUBWINDOW:v="4206	No specified subwindow";  break;
      case    ERR_SOME_OBJECT_ERROR:v="4207	Graphical object erro";  break;
      case    ERR_CHART_PROP_INVALID:v="4210	Unknown chart property";  break;
      case    ERR_CHART_NOT_FOUND:v="4211	Chart not foun";  break;
      case    ERR_CHARTWINDOW_NOT_FOUND:v="4212	Chart subwindow not found";  break;
      case    ERR_CHARTINDICATOR_NOT_FOUND:v="4213	Chart indicator not foun";  break;
      case    ERR_SYMBOL_SELECT:v="4220	Symbol select error";  break;
      case    ERR_NOTIFICATION_ERROR:v="4250	Notification erro";  break;
      case    ERR_NOTIFICATION_PARAMETER:v="4251	Notification parameter error";  break;
      case    ERR_NOTIFICATION_SETTINGS:v="4252	Notifications disable";  break;
      case    ERR_NOTIFICATION_TOO_FREQUENT:v="4253	Notification send too frequent";  break;
      case    ERR_FTP_NOSERVER:v="4260	FTP server is not specifie";  break;
      case    ERR_FTP_NOLOGIN :v="4261	FTP login is not specified";  break;
      case    ERR_FTP_CONNECT_FAILED :v="4262	FTP connection faile";  break;
      case    ERR_FTP_CLOSED:v="4263	FTP connection closed";  break;
      case    ERR_FTP_CHANGEDIR:v="4264	FTP path not found on serve";  break;
      case    ERR_FTP_FILE_ERROR:v="4265	File not found in the MQL4 Files directory to send on FTP server";  break;
      case    ERR_FTP_ERROR:v="4266	Common error during FTP data transmissio";  break;
      case    ERR_FILE_TOO_MANY_OPENED:v="5001	Too many opened files";  break;
      case    ERR_FILE_WRONG_FILENAME:v="5002	Wrong file nam";  break;
      case    ERR_FILE_TOO_LONG_FILENAME:v="5003	Too long file name";  break;
      case    ERR_FILE_CANNOT_OPEN:v="5004	Cannot open fil";  break;
      case    ERR_FILE_BUFFER_ALLOCATION_ERROR:v="5005	Text file buffer allocation error";  break;
      case    ERR_FILE_CANNOT_DELETE:v="5006	Cannot delete fil";  break;
      case    ERR_FILE_INVALID_HANDLE:v="5007	Invalid file handle (file closed or was not opened)";  break;
      case    ERR_FILE_WRONG_HANDLE:v="5008	Wrong file handle (handle index is out of handle table";  break;
      case    ERR_FILE_NOT_TOWRITE:v="5009	File must be opened with FILE_WRITE flag";  break;
      case    ERR_FILE_NOT_TOREAD:v="5010	File must be opened with FILE_READ fla";  break;
      case    ERR_FILE_NOT_BIN:v="5011	File must be opened with FILE_BIN flag";  break;
      case    ERR_FILE_NOT_TXT:v="5012	File must be opened with FILE_TXT fla";  break;
      case    ERR_FILE_NOT_TXTORCSV:v="5013	File must be opened with FILE_TXT or FILE_CSV flag";  break;
      case    ERR_FILE_NOT_CSV:v="5014	File must be opened with FILE_CSV fla";  break;
      case    ERR_FILE_READ_ERROR:v="5015	File read error";  break;
      case    ERR_FILE_WRITE_ERROR:v="5016	File write erro";  break;
      case    ERR_FILE_BIN_STRINGSIZE:v="5017	String size must be specified for binary file";  break;
      case    ERR_FILE_INCOMPATIBLE:v="5018	Incompatible file (for string arrays-TXT, for others-BIN";  break;
      case    ERR_FILE_IS_DIRECTORY:v="5019	File is directory not file";  break;
      case    ERR_FILE_NOT_EXIST:v="5020	File does not exis";  break;
      case    ERR_FILE_CANNOT_REWRITE:v="5021	File cannot be rewritten";  break;
      case    ERR_FILE_WRONG_DIRECTORYNAME:v="5022	Wrong directory nam";  break;
      case    ERR_FILE_DIRECTORY_NOT_EXIST:v="5023	Directory does not exist";  break;
      case    ERR_FILE_NOT_DIRECTORY:v="5024	Specified file is not director";  break;
      case    ERR_FILE_CANNOT_DELETE_DIRECTORY:v="5025	Cannot delete directory";  break;
      case    ERR_FILE_CANNOT_CLEAN_DIRECTORY:v="5026	Cannot clean director";  break;
      case    ERR_FILE_ARRAYRESIZE_ERROR:v="5027	Array resize error";  break;
      case    ERR_FILE_STRINGRESIZE_ERROR:v="5028	String resize erro";  break;
     }
   return v;
  }
//+------------------------------------------------------------------+
string PeriodToStr(int statement)
  {
   switch(statement)
     {
      case  PERIOD_M1:  return "M1";
      case  PERIOD_M5:  return "M5";
      case  PERIOD_M15: return "M15";
      case  PERIOD_M30: return "M30";
      case  PERIOD_H1:  return "H1";
      case  PERIOD_H4:  return "H4";
      case  PERIOD_D1:  return "D1";
      case  PERIOD_W1:  return "W1";
      case  PERIOD_MN1: return "MN1";

      default:return "- ";
     }
   return "- ";
  }
//+------------------------------------------------------------------+
