//+------------------------------------------------------------------+
//|                                                  MetaGrabber.mq5 |
//|                                 Copyright © 2010 www.fxmaster.de |
//|                                         Coding by Sergeev Alexey |
//+------------------------------------------------------------------+
#property copyright "www.fxmaster.de  © 2010"
#property link      "www.fxmaster.de"
#property version		"1.00"
#property description  "Download files from internet"

#property script_show_inputs

#include <InternetLib.mqh>

#import "Kernel32.dll"
bool MoveFileExW(string &lpExistingFileName,string &lpNewFileName,int dwFlags);
#import
#define MOVEFILE_REPLACE_EXISTING 0x1

enum _FolderType
  {
   Experts=0,
   Indicators=1,
   Scripts=2,
   Include=3,
   Libraries=4,
   Files=5,
   Templates=6,
   TesterSet=7
  };

input string URL="";
input _FolderType FolderType=0;
//------------------------------------------------------------------ OnStart
int OnStart()
  {
   MqlNet INet; // variable for work with internet
   string Host,Request,FileName="Recieve_"+TimeToString(TimeCurrent())+".mq5";

   // parse url
   ParseURL(URL,Host,Request,FileName);

   // open session
   if(!INet.Open(Host,80)) return(0);
   Print("+Copy "+FileName+" from  http://"+Host+" to "+GetFolder(FolderType));

   // get file
   if(!INet.Request("GET",Request,FileName,true))
     {
      Print("-Err download "+URL);
      return(0);
     }
   Print("+Ok download "+FileName);

   // remove to specified folder
   string to,from,dir;
   // if folder = "\Files"
   if(FolderType==Files) return(0);

   // from
   from=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+FileName;

   // to
   to=TerminalInfoString(TERMINAL_DATA_PATH)+"\\";
   if(FolderType!=Templates && FolderType!=TesterSet) to+="MQL5\\";
   to+=GetFolder(FolderType)+"\\"+FileName;

   // Moving file
   if(!MoveFileExW(from,to,MOVEFILE_REPLACE_EXISTING))
     {
      Print("-Err move to "+to);
      return(0);
     }
   Print("+Ok move "+FileName+" to "+GetFolder(FolderType));

   return(0);
  }
//------------------------------------------------------------------ GetFolder
string GetFolder(_FolderType foldertype)
  {
   if(foldertype==Experts) return("Experts");
   if(foldertype==Indicators) return("Indicators");
   if(foldertype==Scripts) return("Scripts");
   if(foldertype==Include) return("Include");
   if(foldertype==Libraries) return("Libraries");
   if(foldertype==Files) return("Files");
   if(foldertype==Templates) return("Profiles\\Templates");
   if(foldertype==TesterSet) return("Tester");
   return("");
  }
//------------------------------------------------------------------ ParseURL
void ParseURL(string path,string &host,string &request,string &filename)
  {
   host=StringSubstr(URL,7);
   // remove
   int i=StringFind(host,"/"); 
   request=StringSubstr(host,i);
   host=StringSubstr(host,0,i);
   string file="";
   for(i=StringLen(URL)-1; i>=0; i--)
      if(StringSubstr(URL,i,1)=="/")
        {
         file=StringSubstr(URL,i+1);
         break;
        }
   if(file!="") filename=file;
  }
//+------------------------------------------------------------------+