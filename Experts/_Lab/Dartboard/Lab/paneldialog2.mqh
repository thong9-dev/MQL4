//+------------------------------------------------------------------+
//|                                                 PanelDialog2.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\CheckGroup.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Button.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (53)      // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_WIDTH                          (30)      // size by X coordinate
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (230)     // size by X coordinate
#define GROUP_HEIGHT                        (57)      // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   CCheckGroup       m_check_group;                   // the CheckGroup object

   CLabel            m_label1;                        // the label object
   CEdit             m_edit1;                         // the display field object

   CLabel            m_label2;                        // the label object
   CEdit             m_edit2;                         // the display field object

   CEdit             m_edit3;                         // the display field object
   CLabel            m_label3;                        // the label object

   CEdit             m_edit4;                         // the display field object
   CLabel            m_label4;                        // the label object

   CEdit             m_edit5;                         // the display field object
   CLabel            m_label5;                        // the label object

   CEdit             m_edit6;                         // the display field object
   CLabel            m_label6;                        // the label object

   CButton           m_button_ok;                     // the button "OK" object

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- initialization
   virtual bool      Initialization(const bool Mail,const bool Push,const bool Alert_,
                                    const double Lots,const int TakeProfit,
                                    const int  TrailingStop,const int MACDOpenLevel,
                                    const int  MACDCloseLevel,const int MATrendPeriod);
   //--- get values
   virtual void      GetValues(bool &Mail,bool &Push,bool &Alert_,
                               double &Lots,int &TakeProfit,
                               int &TrailingStop,int &MACDOpenLevel,
                               int &MACDCloseLevel,int &MATrendPeriod);
   //--- send notifications
   virtual void      Notifications(const string text);
   //---
   virtual bool      Modification(void) const { return(mModification);          }
   virtual void      Modification(bool value) { mModification=value;            }

protected:
   //--- create dependent controls
   bool              CreateCheckGroup(void);

   bool              CreateLabel1(void);
   bool              CreateEdit1(void);

   bool              CreateLabel2(void);
   bool              CreateEdit2(void);

   bool              CreateLabel3(void);
   bool              CreateEdit3(void);

   bool              CreateLabel4(void);
   bool              CreateEdit4(void);

   bool              CreateLabel5(void);
   bool              CreateEdit5(void);

   bool              CreateLabel6(void);
   bool              CreateEdit6(void);

   bool              CreateButtonOK(void);

   //--- set check for element
   bool              SetCheck(const int idx,const bool check);

   //--- handlers of the dependent controls events
   void              OnChangeCheckGroup(void);
   void              OnChangeEdit1(void);
   void              OnChangeEdit2(void);
   void              OnChangeEdit3(void);
   void              OnChangeEdit4(void);
   void              OnChangeEdit5(void);
   void              OnChangeEdit6(void);
   void              OnClickButtonOK(void);

private:
   //--- get check for element
   virtual int       GetCheck(const int idx);
   //---
   bool              mMail;
   bool              mPush;
   bool              mAlert_;
   double            mLots;               // Lots
   int               mTakeProfit;         // Take Profit (in pips)
   int               mTrailingStop;       // Trailing Stop Level (in pips)
   int               mMACDOpenLevel;      // MACD open level (in pips)
   int               mMACDCloseLevel;     // MACD close level (in pips)
   int               mMATrendPeriod;      // MA trend period
   //---
   bool              mModification;       // Values have changed
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CHANGE,m_check_group,OnChangeCheckGroup)
ON_EVENT(ON_END_EDIT,m_edit1,OnChangeEdit1)
ON_EVENT(ON_END_EDIT,m_edit2,OnChangeEdit2)
ON_EVENT(ON_END_EDIT,m_edit3,OnChangeEdit3)
ON_EVENT(ON_END_EDIT,m_edit4,OnChangeEdit4)
ON_EVENT(ON_END_EDIT,m_edit5,OnChangeEdit5)
ON_EVENT(ON_END_EDIT,m_edit6,OnChangeEdit6)
ON_EVENT(ON_CLICK,m_button_ok,OnClickButtonOK)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void) : mMail(false),
                                         mPush(false),
                                         mAlert_(true),
                                         mLots(0.1),
                                         mTakeProfit(50),
                                         mTrailingStop(30),
                                         mMACDOpenLevel(3),
                                         mMACDCloseLevel(2),
                                         mMATrendPeriod(26),
                                         mModification(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls
   if(!CreateCheckGroup())
      return(false);

   if(!CreateLabel1())
      return(false);
   if(!CreateEdit1())
      return(false);

   if(!CreateLabel2())
      return(false);
   if(!CreateEdit2())
      return(false);

   if(!CreateLabel3())
      return(false);
   if(!CreateEdit3())
      return(false);

   if(!CreateLabel4())
      return(false);
   if(!CreateEdit4())
      return(false);

   if(!CreateLabel5())
      return(false);
   if(!CreateEdit5())
      return(false);

   if(!CreateLabel6())
      return(false);
   if(!CreateEdit6())
      return(false);

   if(!CreateButtonOK())
      return(false);

//---
   SetCheck(0,mMail);
   SetCheck(1,mPush);
   SetCheck(2,mAlert_);

//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup" element                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCheckGroup(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+GROUP_WIDTH;
   int y2=y1+GROUP_HEIGHT;
//--- create
   if(!m_check_group.Create(m_chart_id,m_name+"CheckGroup",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group))
      return(false);
//--- fill out with strings
   if(!m_check_group.AddItem("Mail if Trade event",1<<0))
      return(false);
   if(!m_check_group.AddItem("Push if Trade event",1<<1))
      return(false);
   if(!m_check_group.AddItem("Alert if Trade event",1<<2))
      return(false);
   Comment("Value="+IntegerToString(m_check_group.Value())+
           "\nElement 0 has a state: "+IntegerToString(m_check_group.Check(0))+
           "\nElement 1 has a state: ",IntegerToString(m_check_group.Check(1))+
           "\nElement 2 has a state: ",IntegerToString(m_check_group.Check(2)));
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label1"                                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+100;
   int y2=y1+20;
//--- create
   if(!m_label1.Create(m_chart_id,m_name+"Label1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label1.Text("Lots"))
      return(false);
   if(!Add(m_label1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the display field "Edit1"                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit1(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-INDENT_RIGHT-BUTTON_WIDTH;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit1.Create(m_chart_id,m_name+"Edit1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_edit1.Text(DoubleToString(mLots,2)))
      return(false);
   if(!m_edit1.ReadOnly(false))
      return(false);
   if(!Add(m_edit1))
      return(false);
   m_edit1.Alignment(WND_ALIGN_RIGHT,0,0,INDENT_RIGHT,0);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label2"                                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel2(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+100;
   int y2=y1+20;
//--- create
   if(!m_label2.Create(m_chart_id,m_name+"Label2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label2.Text("Take Profit (in pips)"))
      return(false);
   if(!Add(m_label2))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the display field "Edit2"                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit2(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-INDENT_RIGHT-BUTTON_WIDTH;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit2.Create(m_chart_id,m_name+"Edit2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_edit2.Text(IntegerToString(mTakeProfit)))
      return(false);
   if(!m_edit2.ReadOnly(false))
      return(false);
   if(!Add(m_edit2))
      return(false);
   m_edit2.Alignment(WND_ALIGN_RIGHT,0,0,INDENT_RIGHT,0);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label3"                                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel3(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+100;
   int y2=y1+20;
//--- create
   if(!m_label3.Create(m_chart_id,m_name+"Label3",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label3.Text("Trailing Stop Level (in pips)"))
      return(false);
   if(!Add(m_label3))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the display field "Edit3"                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit3(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-INDENT_RIGHT-BUTTON_WIDTH;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit3.Create(m_chart_id,m_name+"Edit3",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_edit3.Text(IntegerToString(mTrailingStop)))
      return(false);
   if(!m_edit3.ReadOnly(false))
      return(false);
   if(!Add(m_edit3))
      return(false);
   m_edit3.Alignment(WND_ALIGN_RIGHT,0,0,INDENT_RIGHT,0);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label4"                                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel4(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+100;
   int y2=y1+20;
//--- create
   if(!m_label4.Create(m_chart_id,m_name+"Label4",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label4.Text("MACD open level (in pips)"))
      return(false);
   if(!Add(m_label4))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the display field "Edit4"                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit4(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-INDENT_RIGHT-BUTTON_WIDTH;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit4.Create(m_chart_id,m_name+"Edit4",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_edit4.Text(IntegerToString(mMACDOpenLevel)))
      return(false);
   if(!m_edit4.ReadOnly(false))
      return(false);
   if(!Add(m_edit4))
      return(false);
   m_edit4.Alignment(WND_ALIGN_RIGHT,0,0,INDENT_RIGHT,0);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label5"                                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel5(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+100;
   int y2=y1+20;
//--- create
   if(!m_label5.Create(m_chart_id,m_name+"Label5",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label5.Text("MACD close level (in pips)"))
      return(false);
   if(!Add(m_label5))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the display field "Edit5"                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit5(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-INDENT_RIGHT-BUTTON_WIDTH;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit5.Create(m_chart_id,m_name+"Edit5",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_edit5.Text(IntegerToString(mMACDCloseLevel)))
      return(false);
   if(!m_edit5.ReadOnly(false))
      return(false);
   if(!Add(m_edit5))
      return(false);
   m_edit5.Alignment(WND_ALIGN_RIGHT,0,0,INDENT_RIGHT,0);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label6"                                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel6(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+100;
   int y2=y1+20;
//--- create
   if(!m_label6.Create(m_chart_id,m_name+"Label6",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label6.Text("MA trend period"))
      return(false);
   if(!Add(m_label6))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the display field "Edit6"                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateEdit6(void)
  {
//--- coordinates
   int x1=ClientAreaWidth()-INDENT_RIGHT-BUTTON_WIDTH;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_edit6.Create(m_chart_id,m_name+"Edit6",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_edit6.Text(IntegerToString(mMATrendPeriod)))
      return(false);
   if(!m_edit6.ReadOnly(false))
      return(false);
   if(!Add(m_edit6))
      return(false);
   m_edit6.Alignment(WND_ALIGN_RIGHT,0,0,INDENT_RIGHT,0);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "ButtonOK" button                                     |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonOK(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+GROUP_HEIGHT+CONTROLS_GAP_Y+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH*3;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_ok.Create(m_chart_id,m_name+"ButtonOK",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_ok.Text("Apply changes"))
      return(false);
   if(!Add(m_button_ok))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeCheckGroup(void)
  {
   Comment("Value="+IntegerToString(m_check_group.Value())+
           "\nElement 0 has a state: "+IntegerToString(m_check_group.Check(0))+
           "\nElement 1 has a state: ",IntegerToString(m_check_group.Check(1))+
           "\nElement 2 has a state: ",IntegerToString(m_check_group.Check(2)));
   mMail=m_check_group.Check(0);
   mPush=m_check_group.Check(1);
   mAlert_=m_check_group.Check(2);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeEdit1(void)
  {
   double temp=StringToDouble(m_edit1.Text());
   if(temp==0.0)
     {
      MessageBox("In the input field \"Lots\" not a number","Input error",0);
      m_edit1.Text(DoubleToString(mLots,2));
     }
   else
     {
      m_edit1.Text(DoubleToString(temp,2));
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeEdit2(void)
  {
   int temp=(int)StringToInteger(m_edit2.Text());
   if(temp==0)
     {
      MessageBox("In the input field \"Take Profit (in pips)\" not a number","Input error",0);
      m_edit2.Text(IntegerToString(mTakeProfit));
     }
   else
     {
      m_edit2.Text(IntegerToString(temp,2));
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeEdit3(void)
  {
   int temp=(int)StringToInteger(m_edit3.Text());
   if(temp==0)
     {
      MessageBox("In the input field \"Trailing Stop Level (in pips)\" not a number","Input error",0);
      m_edit3.Text(IntegerToString(mTrailingStop));
     }
   else
     {
      m_edit3.Text(IntegerToString(temp,2));
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeEdit4(void)
  {
   int temp=(int)StringToInteger(m_edit4.Text());
   if(temp==0)
     {
      MessageBox("In the input field \"MACD open level (in pips)\" not a number","Input error",0);
      m_edit4.Text(IntegerToString(mMACDOpenLevel));
     }
   else
     {
      m_edit4.Text(IntegerToString(temp,2));
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeEdit5(void)
  {
   int temp=(int)StringToInteger(m_edit5.Text());
   if(temp==0)
     {
      MessageBox("In the input field \"MACD close level (in pips)\" not a number","Input error",0);
      m_edit5.Text(IntegerToString(mMACDCloseLevel));
     }
   else
     {
      m_edit5.Text(IntegerToString(temp,2));
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeEdit6(void)
  {
   int temp=(int)StringToInteger(m_edit6.Text());
   if(temp==0)
     {
      MessageBox("In the input field \"MA trend period\" not a number","Input error",0);
      m_edit6.Text(IntegerToString(mMATrendPeriod));
     }
   else
     {
      m_edit6.Text(IntegerToString(temp,2));
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonOK(void)
  {
//--- verifying changes
   if(m_check_group.Check(0)!=mMail)
      mModification=true;
   if(m_check_group.Check(1)!=mPush)
      mModification=true;
   if(m_check_group.Check(2)!=mAlert_)
      mModification=true;

   if(StringToDouble(m_edit1.Text())!=mLots)
     {
      mLots=StringToDouble(m_edit1.Text());
      mModification=true;
     }
   if(StringToInteger(m_edit2.Text())!=mTakeProfit)
     {
      mTakeProfit=(int)StringToDouble(m_edit2.Text());
      mModification=true;
     }
   if(StringToInteger(m_edit3.Text())!=mTrailingStop)
     {
      mTrailingStop=(int)StringToDouble(m_edit3.Text());
      mModification=true;
     }
   if(StringToInteger(m_edit4.Text())!=mMACDOpenLevel)
     {
      mMACDOpenLevel=(int)StringToDouble(m_edit4.Text());
      mModification=true;
     }
   if(StringToInteger(m_edit5.Text())!=mMACDCloseLevel)
     {
      mMACDCloseLevel=(int)StringToDouble(m_edit5.Text());
      mModification=true;
     }
   if(StringToInteger(m_edit6.Text())!=mMATrendPeriod)
     {
      mMATrendPeriod=(int)StringToDouble(m_edit6.Text());
      mModification=true;
     }
  }
//+------------------------------------------------------------------+
//| Set check for element                                            |
//+------------------------------------------------------------------+
bool CControlsDialog::SetCheck(const int idx,const bool check)
  {
   bool rezult=m_check_group.Check(idx,check);
   Comment("Value="+IntegerToString(m_check_group.Value())+
           "\nElement 0 has a state: "+IntegerToString(m_check_group.Check(0))+
           "\nElement 1 has a state: ",IntegerToString(m_check_group.Check(1))+
           "\nElement 2 has a state: ",IntegerToString(m_check_group.Check(2)));
   return(rezult);
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::Initialization(const bool Mail,const bool Push,const bool Alert_,
                                     const double Lots,const int TakeProfit,
                                     const int  TrailingStop,const int MACDOpenLevel,
                                     const int  MACDCloseLevel,const int MATrendPeriod)
  {
   mMail=Mail;
   mPush=Push;
   mAlert_=Alert_;

   mLots=Lots;
   mTakeProfit=TakeProfit;
   mTrailingStop=TrailingStop;
   mMACDOpenLevel=MACDOpenLevel;
   mMACDCloseLevel=MACDCloseLevel;
   mMATrendPeriod=MATrendPeriod;
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get values                                                       |
//+------------------------------------------------------------------+
void CControlsDialog::GetValues(bool &Mail,bool &Push,bool &Alert_,
                                double &Lots,int &TakeProfit,
                                int &TrailingStop,int &MACDOpenLevel,
                                int &MACDCloseLevel,int &MATrendPeriod)
  {
   Mail=mMail;
   Push=mPush;
   Alert_=mAlert_;

   Lots=mLots;
   TakeProfit=mTakeProfit;
   TrailingStop=mTrailingStop;
   MACDOpenLevel=mMACDOpenLevel;
   MACDCloseLevel=mMACDCloseLevel;
   MATrendPeriod=mMATrendPeriod;
  }
//+------------------------------------------------------------------+
//|  Send notifications                                              |
//+------------------------------------------------------------------+
void CControlsDialog::Notifications(const string text)
  {
   int i=m_check_group.ControlsTotal();
   if(GetCheck(0))
      SendMail(" ",text);
   if(GetCheck(1))
      SendNotification(text);
   if(GetCheck(2))
      Alert(text);
  }
//+------------------------------------------------------------------+
//| Get check for element                                            |
//+------------------------------------------------------------------+
int CControlsDialog::GetCheck(const int idx)
  {
   return(m_check_group.Check(idx));
  }
//+------------------------------------------------------------------+
