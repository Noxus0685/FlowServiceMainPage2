//---------------------------------------------------------------------------

#ifndef FormMeterValueH
#define FormMeterValueH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <FMX.Controls.hpp>
#include <FMX.Forms.hpp>
#include <FMX.Types.hpp>
#include <FMX.Controls.Presentation.hpp>
#include <FMX.StdCtrls.hpp>
#include <FMX.TabControl.hpp>
#include <FMX.Edit.hpp>
#include <FMX.Layouts.hpp>
#include <FMX.Objects.hpp>
#include <FMX.Grid.hpp>
#include <FMX.Grid.Style.hpp>
#include <FMX.ScrollBox.hpp>
#include <System.Rtti.hpp>

#include "TMeterValue.h"
#include "TFlowMeter.h"
#include <FMXTee.Chart.hpp>
#include <FMXTee.Engine.hpp>
#include <FMXTee.Procs.hpp>
//---------------------------------------------------------------------------
class TFormMeterValueSettings : public TForm
{
__published:	// IDE-managed Components
    TStyleBook *StyleBook1;
    TToolBar *ToolBar1;
    TButton *Button1;
    TTabControl *TabControlMeterValueSettings;
    TTabItem *TabItem1;
    TTabItem *TabItem2;
    TTabItem *TabItem3;
    TLayout *LayoutCommonSettings;
    TPanel *Panel4;
    TLayout *Layout56;
    TRectangle *Rectangle29;
    TEdit *EditName;
    TLabel *LabelName;
    TImage *Image28;
    TLayout *Layout66;
    TRectangle *Rectangle30;
    TEdit *EditShrtName;
    TLabel *LabelShrtName;
    TImage *Image29;
    TLayout *Layout67;
    TRectangle *Rectangle31;
    TEdit *EditDescription;
    TLabel *LabelStdDensity;
    TImage *Image30;
    TLabel *Label62;
    TLayout *LayoutValues;
    TPanel *Panel1;
    TLayout *Layout2;
    TRectangle *Rectangle1;
    TEdit *EditValue;
    TLabel *Label1;
    TImage *Image1;
    TLayout *Layout3;
    TRectangle *Rectangle2;
    TEdit *EditValueDim;
    TLabel *Label2;
    TImage *Image2;
    TLayout *Layout4;
    TRectangle *Rectangle3;
    TEdit *EditMin;
    TLabel *Label3;
    TImage *Image3;
    TLabel *Label4;
    TVertScrollBox *VertScrollBox1;
    TLayout *Layout5;
    TRectangle *Rectangle4;
    TEdit *EditMax;
    TLabel *Label5;
    TImage *Image4;
    TLayout *Layout8;
    TLayout *Layout9;
    TVertScrollBox *VertScrollBox2;
    TLayout *Layout10;
    TPanel *Panel2;
    TLayout *Layout14;
    TPanel *Panel3;
    TLayout *Layout15;
    TRectangle *Rectangle10;
    TEdit *Edit10;
    TLabel *Label12;
    TImage *Image10;
    TLabel *Label15;
    TLayout *Layout26;
    TStringGrid *StringGridCoefsData;
    TStringColumn *StringColumn1;
    TStringColumn *StringColumnValue;
    TStringColumn *StringColumnEtalon;
    TStringColumn *StringColumnQ1;
    TStringColumn *StringColumn5;
    TStringColumn *StringColumn6;
    TStringColumn *StringColumnCoefsDataHash;
    TLayout *Layout27;
    TButton *RefreshConfigButton;
    TButton *DeleteConfigButton;
    TButton *AddRowButton;
    TButton *DeleteRowButton;
    TButton *LoadConfigButton;
    TButton *SaveConfigButton;
    TLayout *Layout36;
    TLabel *Label29;
    TCheckBox *CheckBox2;
    TLayout *Layout1;
    TStringGrid *StringGridDimensions;
    TStringColumn *StringColumn8;
    TStringColumn *StringColumn9;
    TStringColumn *StringColumn10;
    TStringColumn *StringColumn11;
    TStringColumn *StringColumnRecip;
    TStringColumn *StringColumnHash;
    TLayout *Layout11;
    TButton *Button2;
    TButton *Button3;
    TButton *Button4;
    TButton *Button5;
    TButton *ButtonCoefsLoad;
    TButton *Button7;
    TLayout *Layout12;
    TLabel *Label8;
    TCheckBox *CheckBox1;
    TStringColumn *StringColumn12;
    TCheckColumn *CheckColumn1;
    TLayout *Layout13;
    TStringGrid *StringGridCoefs;
    TCheckColumn *CheckColumn2;
    TStringColumn *StringColumn4;
    TStringColumn *StringColumn13;
    TStringColumn *StringColumn14;
    TStringColumn *StringColumn15;
    TStringColumn *StringColumn16;
    TStringColumn *StringColumn17;
    TStringColumn *StringColumn18;
    TLayout *Layout16;
    TButton *Button8;
    TButton *Button9;
    TButton *Button10;
    TButton *Button11;
    TButton *Button12;
    TButton *Button13;
    TLayout *Layout17;
    TLabel *Label9;
    TCheckBox *CheckBox3;
    TLayout *Layout18;
    TLayout *Layout20;
    TLabel *Label10;
    TCheckBox *CheckBox4;
    TChart *Chart1;
    TStringColumn *StringColumn19;
    TLayout *Layout6;
    TRectangle *Rectangle5;
    TLabel *Label6;
    TImage *Image5;
    TCheckBox *CheckBoxIsToSave;
    TLayout *Layout7;
    TRectangle *Rectangle6;
    TLabel *Label7;
    TImage *Image6;
    TEdit *EditHash;
    TTabItem *TabItem4;
    TEdit *EditTestValueDim;
    TLabel *LabelValueDim;
    TLabel *LabelTestValueDim;
    TLabel *LabelValueRaw;
    TEdit *EditTestValueRaw;
    TLabel *LabelTestValue;
    TLayout *LayoutValue;
    TRectangle *Rectangle7;
    TEdit *EditValueFull;
    TLabel *LabelValueName;
    TImage *Image7;
    TLayout *Layout21;
    TRectangle *Rectangle8;
    TEdit *EditValueType;
    TLabel *Label11;
    TImage *Image8;
    TTabItem *TabItemListValues;
    TStringGrid *StringGridValuesList;
    TStringColumn *StringColumn7;
    TStringColumn *StringColumn20;
    TStringColumn *StringColumn21;
    TStringColumn *StringColumn22;
    TStringColumn *StringColumn23;
    TStringColumn *StringColumn24;
    TStringColumn *StringColumn25;
    TLayout *LayoutListValues;
    TLayout *Layout23;
    TLabel *Label13;
    TStringColumn *StringColumn26;
    TStringColumn *StringColumn27;
    TStringColumn *StringColumn28;
    TStringColumn *StringColumn29;
    TStringColumn *StringColumn30;
    TStringColumn *StringColumn31;
    TStringColumn *StringColumn32;
    TStringColumn *StringColumn33;
    TStringColumn *StringColumn34;
    TStringColumn *StringColumn35;
    TStringColumn *StringColumn36;
    TStringColumn *StringColumn37;
    TStringColumn *StringColumn38;
    TLayout *LayoutCoefs;
    TPanel *Panel5;
    TLayout *Layout24;
    TRectangle *Rectangle9;
    TEdit *EditNameValueMultiplier;
    TLabel *Label14;
    TImage *Image9;
    TLayout *Layout25;
    TRectangle *Rectangle11;
    TEdit *EditCoefK;
    TLabel *Label16;
    TImage *Image11;
    TLayout *Layout28;
    TRectangle *Rectangle12;
    TEdit *EditCoefP;
    TLabel *Label17;
    TImage *Image12;
    TLabel *Label18;
    TLabel *Label20;
    TEdit *EditValueMultiplier;
    TLayout *Layout30;
    TRectangle *Rectangle14;
    TEdit *EditNameValueDevider;
    TLabel *Label21;
    TLabel *Label22;
    TEdit *EditValueDevider;
    TImage *Image14;
    TLayout *Layout19;
    TRectangle *Rectangle15;
    TEdit *EditNameValueRate;
    TLabel *Label23;
    TLabel *Label24;
    TEdit *EditValueRate;
    TImage *Image15;
    TLabel *Label19;
    TLabel *LabelTestValueBase;
    TLabel *Label26;
    TLabel *LabelTestValueWoCorrection;
    void __fastcall FormShow(TObject *Sender);
    void __fastcall AddRowButtonClick(TObject *Sender);
    void __fastcall StringGridCoefsDataEditingDone(TObject *Sender, const int ACol,
          const int ARow);
    void __fastcall SaveConfigButtonClick(TObject *Sender);
    void __fastcall DeleteRowButtonClick(TObject *Sender);
    void __fastcall RefreshConfigButtonClick(TObject *Sender);
    void __fastcall LoadConfigButtonClick(TObject *Sender);
    void __fastcall StringGridDimensionsSelChanged(TObject *Sender);
    void __fastcall ButtonCoefsLoadClick(TObject *Sender);
    void __fastcall TabControlMeterValueSettingsChange(TObject *Sender);
    void __fastcall CheckBoxIsToSaveChange(TObject *Sender);
    void __fastcall EditNameExit(TObject *Sender);
    void __fastcall EditShrtNameExit(TObject *Sender);
    void __fastcall EditDescriptionExit(TObject *Sender);
    void __fastcall EditHashExit(TObject *Sender);
    void __fastcall EditValueExit(TObject *Sender);
    void __fastcall EditValueDimExit(TObject *Sender);
    void __fastcall EditMinExit(TObject *Sender);
    void __fastcall EditMaxExit(TObject *Sender);
    void __fastcall Z(TObject *Sender);
    void __fastcall EditTestValueRawExit(TObject *Sender);
    void __fastcall StringGridCoefsDataSelChanged(TObject *Sender);
    void __fastcall TabItem4Click(TObject *Sender);
    void __fastcall TabItemListValuesClick(TObject *Sender);
    void __fastcall StringGridValuesListSelChanged(TObject *Sender);
    void __fastcall EditCoefKExit(TObject *Sender);
    void __fastcall EditCoefPExit(TObject *Sender);
  private: // User declarations

     tCoef coef;
     int   CoefHash=0;

  public: // User declarations
    __fastcall TFormMeterValueSettings(TComponent* Owner);

    TMeterValue* MeterValue;

    void UpdateLayoutCommonSettings();

    void UpdateLayoutValues();
    void UpdateStringGridDimensions();

    void UpdateStringGridCoefs();
    void UpdateStringGridCoefsData();

    void RefreshLayoutValues();
    void UpdateLayoutTest();
    void UpdateLayoutValuesList();
    void UpdateLayoutCoefs();
    void RefreshLayoutCoefs();
};
//---------------------------------------------------------------------------
extern PACKAGE TFormMeterValueSettings *FormMeterValueSettings;
//---------------------------------------------------------------------------
#endif















