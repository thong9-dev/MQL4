//+------------------------------------------------------------------+
//|                                               ControlsDialog.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\ComboBox.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   //   CEdit             m_edit;                          // the display field object
   CComboBox         m_combo_box;                     // the dropdown list object

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   //   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   //   bool              CreateEdit(void);
   bool              CreateComboBox(void);
   //--- handlers of the dependent controls events
   void              OnChangeComboBox(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void)
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
//if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
//return(false);
//--- create dependent controls
//   if(!CreateEdit())
//      return(false);
   if(!CreateComboBox())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "ComboBox" element                                    |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateComboBox(void)
  {
   int x1=100, y1=100, xsize=150, ysize=20;
   int x2=x1+xsize;
   int y2=y1+ysize;
   long subWinID=ChartWindowFind();

   if(!m_combo_box.Create(0,"ComboBox",(int)subWinID,x1,y1,x2,y2))
      return(false);

   if(!m_combo_box.AddItem("PL: OPPPPPPPPPPPP",0)) return(false);
   if(!m_combo_box.AddItem("TL: Trend Line",1)) return(false);
   if(!m_combo_box.AddItem("MA: Moving Average",2)) return(false);
   if(!m_combo_box.AddItem("RSI: RSI Indicator",3)) return(false);
   if(!Add(m_combo_box)) return(false);
/* ATTENTION: the above call to CPanelDialog::Add(control) is definietely necessary.
      otherwise nothing will be popped out when the arrow of the combobox is clicked. */
//--- succeed
   Alert("the combobox is created ok!");
   return(true);
  }
//+------------------------------------------------------------------+
