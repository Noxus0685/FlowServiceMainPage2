unit fuTypeEditor;

interface

uses

  UnitDataManager, UnitClasses,UnitRepositories, UnitBaseProcedures,


  System.Math, System.DateUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Menus, FMX.StdCtrls, FMX.EditBox, FMX.SpinBox, FMX.Grid,
  FMX.ScrollBox, FMX.Effects, FMX.TabControl, FMX.ComboEdit, FMX.ListBox,
  FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, System.Generics.Collections,

   System.JSON,
     System.IOUtils,
  System.NetEncoding,
  System.Net.HttpClient,
  System.Net.HttpClientComponent, FMX.Memo.Types, FMX.Memo, System.Net.URLClient;

type

  TFormTypeEditor = class(TForm)
    layLeft: TLayout;
    grpCommonInfo: TGroupBox;
    Layout5: TLayout;
    labName: TLabel;
    EditName: TEdit;
    Layout6: TLayout;
    Label11: TLabel;
    Layout3: TLayout;
    Label1: TLabel;
    edtManufacturer: TEdit;
    Layout4: TLayout;
    Label2: TLabel;
    edtDocumentation: TEdit;
    sbDocumentation: TSpeedButton;
    Layout8: TLayout;
    Label3: TLabel;
    edtReestrNumber: TEdit;
    sbFindReestrNumber: TSpeedButton;
    Layout33: TLayout;
    Label29: TLabel;
    EditModification: TEdit;
    Layout34: TLayout;
    Label30: TLabel;
    EditValidityDate: TEdit;
    Label34: TLabel;
    Layout35: TLayout;
    Label31: TLabel;
    EditIVI: TEdit;
    Layout36: TLayout;
    Label32: TLabel;
    EditAccuracyClass: TEdit;
    Layout31: TLayout;
    Label23: TLabel;
    EditReportingForm: TEdit;
    sbReportingForm: TSpeedButton;
    Layout43: TLayout;
    Label39: TLabel;
    cbProcedure: TComboEdit;
    grpTypeOfCheck: TGroupBox;
    Layout12: TLayout;
    Label4: TLabel;
    ComboBoxOutputType: TComboBox;
    Layout14: TLayout;
    Label7: TLabel;
    cbMeasuredDimension: TComboBox;
    tcOutPutType: TTabControl;
    tiVoltage: TTabItem;
    grpVoltage: TGroupBox;
    Layout24: TLayout;
    Label21: TLabel;
    cbVoltageRange: TComboBox;
    Layout25: TLayout;
    Label22: TLabel;
    Layout7: TLayout;
    Label5: TLabel;
    EditVoltageQmin: TEdit;
    Layout10: TLayout;
    Label6: TLabel;
    EditVoltageQmax: TEdit;
    tiCurrent: TTabItem;
    grpCurrent: TGroupBox;
    Layout18: TLayout;
    Label16: TLabel;
    cbCurrentRange: TComboBox;
    Layout19: TLayout;
    labCurrentMin: TLabel;
    EditCurrentQmin: TEdit;
    Layout22: TLayout;
    Label17: TLabel;
    Layout23: TLayout;
    Label20: TLabel;
    EditCurrentQmax: TEdit;
    tiImpulse: TTabItem;
    grpFreq: TGroupBox;
    Layout1: TLayout;
    Label9: TLabel;
    cbOutPutType2: TComboBox;
    Layout2: TLayout;
    Label14: TLabel;
    EditCoef: TEdit;
    Layout9: TLayout;
    Label15: TLabel;
    cbCoefViewType: TComboBox;
    tiInterface: TTabItem;
    GroupBox4: TGroupBox;
    Layout28: TLayout;
    Label25: TLabel;
    cbLibrares: TComboBox;
    Layout29: TLayout;
    Label26: TLabel;
    edtAddr: TEdit;
    Layout30: TLayout;
    Label27: TLabel;
    tiVisual: TTabItem;
    GroupBox5: TGroupBox;
    Layout11: TLayout;
    Label8: TLabel;
    cbInputType: TComboBox;
    Layout13: TLayout;
    Label10: TLabel;
    Edit10: TEdit;
    Layout26: TLayout;
    Label12: TLabel;
    ComboBox3: TComboBox;
    Layout27: TLayout;
    Label13: TLabel;
    Edit11: TEdit;
    tiFrequency: TTabItem;
    GroupBox3: TGroupBox;
    Layout39: TLayout;
    Label35: TLabel;
    cbOutPutType: TComboBox;
    Layout40: TLayout;
    Label36: TLabel;
    EditFreq: TEdit;
    Layout41: TLayout;
    Label37: TLabel;
    ComboBox6: TComboBox;
    Layout42: TLayout;
    Label38: TLabel;
    EditFreqFlowRate: TEdit;
    shdwfct1: TShadowEffect;
    layRight: TLayout;
    grpPrivate: TGroupBox;
    Layout16: TLayout;
    GridDiameters: TGrid;
    StringColumnDNName: TStringColumn;
    IntegerColumnDNSize: TIntegerColumn;
    FloatColumnVmax: TFloatColumn;
    StringColumnVmin: TStringColumn;
    Layout44: TLayout;
    Layout32: TLayout;
    ButtonDiameterDelete: TButton;
    ButtonDiameterAdd: TButton;
    ButtonDiameterClear: TButton;
    Layout37: TLayout;
    Label33: TLabel;
    EditRangeDynamic: TEdit;
    GroupBox2: TGroupBox;
    Layout21: TLayout;
    Label19: TLabel;
    Layout20: TLayout;
    Label18: TLabel;
    grpWorkShedule: TGroupBox;
    Layout15: TLayout;
    GridPoints: TGrid;
    StringColumnPointName: TStringColumn;
    IntegerColumnPointRepeatsForm: TIntegerColumn;
    IntegerColumnPointRepeats: TIntegerColumn;
    StringColumnPointPres: TStringColumn;
    StringColumnPontTemp: TStringColumn;
    StringColumnPointTempError: TStringColumn;
    Layout17: TLayout;
    Label24: TLabel;
    cbSpillageStop: TComboBox;
    Label28: TLabel;
    cbSpillageType: TComboBox;
    Layout38: TLayout;
    ButtonPointDelete: TButton;
    ButtonPointAdd: TButton;
    ButtonPointsClear: TButton;
    Label40: TLabel;
    sbRepeats: TSpinBox;
    shdwfct2: TShadowEffect;
    layTop: TLayout;
    GroupBox1: TGroupBox;
    lytButtons: TLayout;
    btnOK: TCornerButton;
    btnCancel: TCornerButton;
    shdwfct3: TShadowEffect;
    ppmnuCalculateVolume: TPopupMenu;
    miCalculateVolume: TMenuItem;
    Layout45: TLayout;
    Label41: TLabel;
    EditError: TEdit;
    Splitter1: TSplitter;
    Layout46: TLayout;
    StringColumnPointFlowRate: TStringColumn;
    StringColumnPointQ: TStringColumn;
    StringColumnPointVolume: TStringColumn;
    StringColumnPointImp: TStringColumn;
    StringColumnPointTime: TStringColumn;
    StringColumnPointError: TStringColumn;
    StringColumnPointFlowError: TStringColumn;
    StringColumnPointStab: TStringColumn;
    StringColumnDNQmax: TStringColumn;
    StringColumnDNQmin: TStringColumn;
    StringColumnDNQF: TStringColumn;
    StringColumnDNKp: TStringColumn;
    EditRegDate: TEdit;
    Layout47: TLayout;
    Label42: TLabel;
    cbParity: TComboBox;
    cbBaudRate: TComboBox;
    SpeedButton1: TSpeedButton;
    ceCategory: TComboEdit;
    MemoLog: TMemo;
    NetHTTPClient1: TNetHTTPClient;
    DeepSeek: TSpeedButton;
    procedure GridDiametersGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridPointsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridDiametersSelChanged(Sender: TObject);
    procedure EditRangeDynamicExit(Sender: TObject);
    procedure GridDiametersSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure GridPointsSetValue(Sender: TObject; const ACol, ARow: Integer;
      const Value: TValue);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonDiameterAddClick(Sender: TObject);
    procedure ButtonDiameterDeleteClick(Sender: TObject);
    procedure ButtonDiameterClearClick(Sender: TObject);
    procedure ButtonPointAddClick(Sender: TObject);
    procedure ButtonPointDeleteClick(Sender: TObject);
    procedure ButtonPointsClearClick(Sender: TObject);
    procedure cbSpillageTypeChange(Sender: TObject);
    procedure cbSpillageStopChange(Sender: TObject);
    procedure sbRepeatsChange(Sender: TObject);
    procedure EditRangeDynamicEnter(Sender: TObject);
    procedure UpdateRangeDynamicPrompt;
    procedure UpdateRangeDynamicPromptBySelectedDiameter;
    procedure EditErrorExit(Sender: TObject);
    procedure EditErrorEnter(Sender: TObject);
    procedure EditNameExit(Sender: TObject);
    procedure EditNameTyping(Sender: TObject);
    procedure edtManufacturerExit(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure EditModificationExit(Sender: TObject);
    procedure EditModificationTyping(Sender: TObject);
    procedure cbProcedureChange(Sender: TObject);
    procedure edtReestrNumberExit(Sender: TObject);
    procedure edtReestrNumberTyping(Sender: TObject);
    procedure EditRegDateExit(Sender: TObject);
    procedure EditValidityDateExit(Sender: TObject);
    procedure EditIVIExit(Sender: TObject);
    procedure edtDocumentationExit(Sender: TObject);
    procedure EditAccuracyClassExit(Sender: TObject);
    procedure EditAccuracyClassTyping(Sender: TObject);
    procedure edtDocumentationTyping(Sender: TObject);
    procedure cbMeasuredDimensionChange(Sender: TObject);
    procedure ComboBoxOutputTypeChange(Sender: TObject);
    procedure cbOutPutType2Change(Sender: TObject);
    procedure cbCoefViewTypeChange(Sender: TObject);
    procedure EditCoefExit(Sender: TObject);
    procedure EditFreqFlowRateExit(Sender: TObject);
    procedure EditFreqExit(Sender: TObject);
    procedure cbVoltageRangeChange(Sender: TObject);
    procedure EditVoltageQminExit(Sender: TObject);
    procedure EditVoltageQmaxExit(Sender: TObject);
    procedure cbLibraresChange(Sender: TObject);
    procedure edtAddrExit(Sender: TObject);
    procedure cbBaudRateChange(Sender: TObject);
    procedure cbParityChange(Sender: TObject);
    procedure cbInputTypeChange(Sender: TObject);
    procedure cbOutPutTypeChange(Sender: TObject);
    procedure CornerButtonCancelClick(Sender: TObject);
    procedure ceCategoryChange(Sender: TObject);
    procedure sbFindReestrNumberClick(Sender: TObject);
    procedure DeepSeekClick(Sender: TObject);
    procedure ChatGPTClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cbCurrentRangeChange(Sender: TObject);
    procedure EditCurrentQmaxExit(Sender: TObject);
    procedure EditCurrentQminExit(Sender: TObject);



  private
    { Private declarations }

  FTypeID: Integer;

  FModified: Boolean;
  FLoading: Boolean;
  FSelectedDiameterIndex: Integer; // выбранный диаметр, индекс в dmFakeDB.Diameters

  FSelectedDiameterID: Integer; // выбранный диаметр, индекс в dmFakeDB.Diameters

  // локальные копии
  FType: TDeviceType;
  FOriginalType: TDeviceType;

  FDiametersLocal: TObjectList<TDiameter>;
  FPointsLocal: TObjectList<TTypePoint>;
  FCategoriesLocal: TObjectList<TDeviceCategory>;

  // маппинг строк грида → индекс в локальных массивах
  FDiameterRowMap: TArray<Integer>; // индексы в FDiametersLocal
  FPointRowMap: TArray<Integer>;    // индексы в FPointsLocal

  ActiveRepo: TTypeRepository;




  procedure SetModified;
  procedure UpdateUIFromType;
  procedure UpdateTypeFromUI;

  //procedure LoadDiametersForType;

  procedure UpdateDiametersGrid;
  procedure UpdatePointsGrid;
  function GetDiameterByVisibleRow(ARow: Integer): TDiameter;
  function GetPointByVisibleRow(ARow: Integer): TTypePoint;


  procedure RecalcPointsBySelectedDiameter;
  procedure UpdatePointsErrorFromType;

  procedure InitLocalData;

   procedure LoadPoints;
  procedure LoadDiameters;
  procedure RecalcDiametersKp;

  public

     constructor Create(AOwner: TComponent; AType: TDeviceType);

    { Public declarations }
    procedure LoadType(AType: TDeviceType);
    function Modified: Boolean;

    procedure InitCategoryComboEdit;


    // === Measured Dimension ===
  procedure ApplyMeasuredDimension;
  procedure ApplyVolumeMode;
  procedure ApplyMassMode;

  procedure FillSpillageStopVolume;
  procedure FillSpillageStopMass;
  procedure FillConversionCoefVolume;
  procedure FillConversionCoefMass;

  procedure ApplyOutputType;

  procedure UpdateCoefEdit;
  function GetDisplayedCoef: Double;

  procedure LoadCategories;

  end;

var
  FormTypeEditor: TFormTypeEditor;

  function CalcQmaxByDiameter(
  const OldQmax: Double;
  const OldDN, NewDN: Integer
): Double;

function CalcKpByDiameter(
  const OldKp: Double;
  const OldDN, NewDN: Integer
): Double;




implementation

{$R *.fmx}

 constructor TFormTypeEditor.Create(AOwner: TComponent; AType: TDeviceType);
 begin
   inherited Create(AOwner);
   LoadType(AType);
 end;

procedure TFormTypeEditor.UpdateUIFromType;
var
  AccErr: Double;
  Idx: Integer;
begin
  FLoading := True;
  try
    // =====================================================
    // == Основные текстовые поля
    // =====================================================
    EditName.Text          := FType.Name;
    EditModification.Text := FType.Modification;
    edtReestrNumber.Text  := FType.ReestrNumber;

    // =====================================================
    // == Изготовитель
    // =====================================================
    edtManufacturer.Text := Trim(FType.Manufacturer);
    if edtManufacturer.Text <> '' then
    begin
      edtManufacturer.TextPrompt := '';
      edtManufacturer.Hint := edtManufacturer.Text;
    end
    else
    begin
      edtManufacturer.TextPrompt := 'Изготовитель';
      edtManufacturer.Hint := '';
    end;

    // =====================================================
    // == Даты
    // =====================================================
    if FType.RegDate > 0 then
      EditRegDate.Text := DateToStr(FType.RegDate)
    else
      EditRegDate.Text := '';

    if FType.ValidityDate > 0 then
      EditValidityDate.Text := DateToStr(FType.ValidityDate)
    else
      EditValidityDate.Text := '';

    // =====================================================
    // == Числовые поля
    // =====================================================
    EditIVI.Text            := FType.IVI.ToString;
    EditAccuracyClass.Text := FType.AccuracyClass;

    // =====================================================
    // == Категория СИ
    // =====================================================
    InitCategoryComboEdit;

    cbProcedure.Text        := FType.ProcedureName;
    edtDocumentation.Text  := FType.VerificationMethod;
    EditReportingForm.Text := FType.ReportingForm;

    // =====================================================
    // == Тип испытания / критерий остановки
    // =====================================================
    if (FType.SpillageType >= 0) and (FType.SpillageType < cbSpillageType.Items.Count) then
      cbSpillageType.ItemIndex := FType.SpillageType
    else
      cbSpillageType.ItemIndex := 0;

    if (FType.SpillageStop >= 0) and (FType.SpillageStop < cbSpillageStop.Items.Count) then
      cbSpillageStop.ItemIndex := FType.SpillageStop
    else
      cbSpillageStop.ItemIndex := 0;

    // =====================================================
    // == Повторы
    // =====================================================
    if FType.Repeats > 0 then
      sbRepeats.Value := FType.Repeats
    else
      sbRepeats.Value := 1;

    // =====================================================
    // == Диаметры
    // =====================================================
    UpdateDiametersGrid;

    // =====================================================
    // == Динамический диапазон
    // =====================================================
    EditRangeDynamic.Text := '';
    EditRangeDynamic.TextPrompt := '';

    if FType.RangeDynamic > 0 then
      EditRangeDynamic.Text := '1:' + IntToStr(Trunc(FType.RangeDynamic))
    else
      UpdateRangeDynamicPrompt;

    // =====================================================
    // == Базовая погрешность
    // =====================================================
    EditError.Text := '';
    EditError.TextPrompt := '—';

    if FType.Error > 0 then
    begin
      EditError.Text := FormatPercentPM(FType.Error);
      EditError.TextPrompt := '';
    end
    else
    begin
      AccErr := ExtractFirstFloat(FType.AccuracyClass);
      if AccErr > 0 then
        EditError.TextPrompt := FormatPercentPM(AccErr)
      else
        EditError.TextPrompt := '—';
    end;

    // =====================================================
    // == Измеряемая величина
    // =====================================================
    ApplyMeasuredDimension;

    // =====================================================
    // == Тип сигнала
    // =====================================================
    if (FType.OutputType >= 0) and
       (FType.OutputType < ComboBoxOutputType.Items.Count) then
      ComboBoxOutputType.ItemIndex := FType.OutputType
    else
      ComboBoxOutputType.ItemIndex := 0;
    ComboBoxOutputType.Hint := ComboBoxOutputType.Text;

// =====================================================
// == Тип выхода (OutputSet) — ДВА ComboBox
// =====================================================
if (FType.OutputSet >= 0) and
   (FType.OutputSet < cbOutPutType.Items.Count) then
begin
  cbOutPutType.ItemIndex := FType.OutputSet;
  cbOutPutType2.ItemIndex := FType.OutputSet;
end
else
begin
  cbOutPutType.ItemIndex := -1;
  cbOutPutType2.ItemIndex := -1;
end;

cbOutPutType.Hint  := cbOutPutType.Text;
cbOutPutType2.Hint := cbOutPutType2.Text;


    // =====================================================
    // == Представление коэффициента
    // =====================================================
    if (FType.DimensionCoef >= 0) and
       (FType.DimensionCoef < cbCoefViewType.Items.Count) then
      cbCoefViewType.ItemIndex := FType.DimensionCoef
    else
      cbCoefViewType.ItemIndex := -1;
    cbCoefViewType.Hint := cbCoefViewType.Text;

    // =====================================================
    // == Коэффициент преобразования
    // =====================================================
    EditCoef.Text := '';
    EditCoef.TextPrompt := '';
    if FType.Coef > 0 then
      EditCoef.Text := FloatToStr(FType.Coef)
    else
      EditCoef.TextPrompt := '-';

    // =====================================================
    // == Частота
    // =====================================================
    if FType.Freq > 0 then
      EditFreq.Text := IntToStr(FType.Freq)
    else
      EditFreq.Text := '';

    // =====================================================
    // == Отношение расхода к частоте
    // =====================================================
    EditFreqFlowRate.Text := '';
    EditFreqFlowRate.TextPrompt := '';
    if FType.FreqFlowRate > 0 then
      EditFreqFlowRate.Text := FloatToStr(FType.FreqFlowRate)
    else
      EditFreqFlowRate.TextPrompt := '-';

    // =====================================================
    // == Интерфейс / библиотека
    // =====================================================
    Idx := cbLibrares.Items.IndexOf(FType.ProtocolName);
    if Idx >= 0 then
      cbLibrares.ItemIndex := Idx
    else
      cbLibrares.ItemIndex := -1;
    cbLibrares.Hint := cbLibrares.Text;

    // =====================================================
    // == Скорость передачи
    // =====================================================
    case FType.BaudRate of
      2400:   cbBaudRate.ItemIndex := 0;
      4800:   cbBaudRate.ItemIndex := 1;
      9600:   cbBaudRate.ItemIndex := 2;
      19200:  cbBaudRate.ItemIndex := 3;
      115200: cbBaudRate.ItemIndex := 4;
    else
      cbBaudRate.ItemIndex := -1;
    end;
    cbBaudRate.Hint := cbBaudRate.Text;

    // =====================================================
    // == Четность
    // =====================================================
    if (FType.Parity >= 0) and (FType.Parity < cbParity.Items.Count) then
      cbParity.ItemIndex := FType.Parity
    else
      cbParity.ItemIndex := 0;
    cbParity.Hint := cbParity.Text;

    // =====================================================
    // == Адрес прибора
    // =====================================================
    if FType.DeviceAddress >= 0 then
      edtAddr.Text := IntToStr(FType.DeviceAddress)
    else
      edtAddr.Text := '';

    // =====================================================
    // == Визуальный ввод
    // =====================================================
    if (FType.InputType >= 0) and (FType.InputType < cbInputType.Items.Count) then
      cbInputType.ItemIndex := FType.InputType
    else
      cbInputType.ItemIndex := 0;
    cbInputType.Hint := cbInputType.Text;

    // =====================================================
    // == Точки
    // =====================================================
    UpdatePointsGrid;

  finally
    FLoading := False;
  end;
end;

procedure TFormTypeEditor.UpdateTypeFromUI;
begin
  FType.Name              := EditName.Text;
  FType.Modification      := EditModification.Text;
  FType.Manufacturer      := edtManufacturer.Text;
  FType.ReestrNumber      := edtReestrNumber.Text;

  // даты
  if EditRegDate.Text <> '' then
    FType.RegDate := StrToDateDef(EditRegDate.Text, 0)
  else
    FType.RegDate := 0;

  if EditValidityDate.Text <> '' then
    FType.ValidityDate := StrToDateDef(EditValidityDate.Text, 0)
  else
    FType.ValidityDate := 0;

  FType.IVI               := StrToIntDef(EditIVI.Text, 0);
  FType.AccuracyClass     := EditAccuracyClass.Text;
  FType.RangeDynamic      := StrToFloatDef(EditRangeDynamic.Text, 0);

  if ceCategory.ItemIndex >= 0 then
  FType.Category := ceCategory.ItemIndex + 1
  else
  begin
  FType.Category := -1;
  FType.CategoryName := ceCategory.Name;
  end;


  FType.ProcedureName     := cbProcedure.Text;

  FType.VerificationMethod:= edtDocumentation.Text;
  FType.ReportingForm     := EditReportingForm.Text;
end;

procedure TFormTypeEditor.UpdateDiametersGrid;
var
  D: TDiameter;
  VisibleCount: Integer;
begin
  if FDiametersLocal = nil then
    Exit;

  VisibleCount := 0;
  for D in FDiametersLocal do
    if (D <> nil) and (D.State <> osDeleted) then
      Inc(VisibleCount);

  GridDiameters.BeginUpdate;
  try
    GridDiameters.RowCount := VisibleCount;
  finally
    GridDiameters.EndUpdate;
  end;
end;


procedure TFormTypeEditor.UpdatePointsGrid;
var
  P: TTypePoint;
  VisibleCount: Integer;
begin
  if FPointsLocal = nil then
    Exit;

  VisibleCount := 0;
  for P in FPointsLocal do
    if (P <> nil) and (P.State <> osDeleted) then
      Inc(VisibleCount);

  GridPoints.BeginUpdate;
  try
    GridPoints.RowCount := VisibleCount;
  finally
    GridPoints.EndUpdate;
  end;
end;

function TFormTypeEditor.GetDiameterByVisibleRow(ARow: Integer): TDiameter;
var
  D: TDiameter;
  VisibleIndex: Integer;
begin
  Result := nil;

  if (FDiametersLocal = nil) or (ARow < 0) then
    Exit;

  VisibleIndex := -1;
  for D in FDiametersLocal do
  begin
    if (D <> nil) and (D.State <> osDeleted) then
    begin
      Inc(VisibleIndex);
      if VisibleIndex = ARow then
        Exit(D);
    end;
  end;
end;

function TFormTypeEditor.GetPointByVisibleRow(ARow: Integer): TTypePoint;
var
  P: TTypePoint;
  VisibleIndex: Integer;
begin
  Result := nil;

  if (FPointsLocal = nil) or (ARow < 0) then
    Exit;

  VisibleIndex := -1;
  for P in FPointsLocal do
  begin
    if (P <> nil) and (P.State <> osDeleted) then
    begin
      Inc(VisibleIndex);
      if VisibleIndex = ARow then
        Exit(P);
    end;
  end;
end;

procedure TFormTypeEditor.LoadType(AType: TDeviceType);
begin
  FLoading := True;
  try
    {----------------------------------}
    { Освобождаем предыдущий экземпляр }
    {----------------------------------}
    FreeAndNil(FType);

    if AType <> nil then
    begin
      {----------------------------------}
      { Редактирование существующего типа }
      {----------------------------------}
      FOriginalType := AType;
      FType := AType.Clone;     // ← работаем с копией
    end
    else
    begin
      {----------------------------------}
      { Новый тип }
      {----------------------------------}
      FOriginalType := nil;
      FType := DataManager.ActiveTypeRepo.CreateType(0);
      FType.State := osNew;
    end;

    InitLocalData;
    UpdateUIFromType;

  finally
    FLoading := False;
  end;
end;

 procedure TFormTypeEditor.SetModified;
begin
  if FLoading then Exit;
  FModified := True;
  if FType.State <> osNew then
    FType.State :=  osModified;

    end;

function TFormTypeEditor.Modified: Boolean;
begin
  Result := FModified;
end;

procedure TFormTypeEditor.btnCancelClick(Sender: TObject);
begin
 ModalResult := mrCancel;
end;

procedure TFormTypeEditor.btnOKClick(Sender: TObject);
begin
  // --------------------------------------------------
  // Валидация данных
  // --------------------------------------------------
  if Trim(FType.Name) = '' then
  begin
    ShowMessage('Не задано наименование типа');
    Exit;
  end;

  ModalResult := mrOk;
end;

procedure TFormTypeEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FType);
  FOriginalType := nil;
end;

procedure TFormTypeEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Repo: TTypeRepository;
begin
  CanClose := True;

  try
    if ModalResult <> mrOk then
      Exit;

    if (DataManager = nil) or (DataManager.ActiveTypeRepo = nil) then
      raise Exception.Create('Активный репозиторий типов не выбран');

    if (FType = nil)  then
      raise Exception.Create('Не задан тип');

    Repo := DataManager.ActiveTypeRepo;

    if FOriginalType <> nil then
    begin
      FOriginalType.Assign(FType);
      if not Repo.SaveType(FOriginalType) then
        raise Exception.Create('Ошибка сохранения типа');
      FOriginalType.SelectedDiameterID := FSelectedDiameterID;
    end
    else
    begin
      if not Repo.SaveType(FType) then
        raise Exception.Create('Ошибка сохранения типа');
            FType.SelectedDiameterID := FSelectedDiameterID;
    end;

    FModified := True;
  except
    on E: Exception do
    begin
      CanClose := False;
      ShowMessage('Ошибка сохранения: ' + E.Message);
    end;
  end;
end;

procedure TFormTypeEditor.ButtonDiameterAddClick(Sender: TObject);
var
  NewD: TDiameter;
  SrcD: TDiameter;
  SrcIndex: Integer;
begin
  if FType = nil then
    Exit;

  SrcIndex := -1;
  SrcD := GetDiameterByVisibleRow(GridDiameters.Selected);
  if (SrcD <> nil) and (FDiametersLocal <> nil) then
    SrcIndex := FDiametersLocal.IndexOf(SrcD);

  {--------------------------------------------------}
  { Копируем диаметр }
  {--------------------------------------------------}
  NewD := FType.CopyDiameter(SrcIndex);
  if NewD = nil then
    Exit;

  {--------------------------------------------------}
  { Обновляем локальный список }
  {--------------------------------------------------}
  if FDiametersLocal = nil then
    FDiametersLocal := FType.Diameters;

  {--------------------------------------------------}
  { Обновляем таблицу }
  {--------------------------------------------------}
  UpdateDiametersGrid;

  {--------------------------------------------------}
  { Выделяем добавленную строку }
  {--------------------------------------------------}
  if GridDiameters.RowCount > 0 then
    GridDiameters.Selected := GridDiameters.RowCount - 1;

  SetModified;
end;


procedure TFormTypeEditor.ButtonDiameterClearClick(Sender: TObject);
var
  I: Integer;
  D: TDiameter;
begin
  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if (FDiametersLocal = nil) or (FDiametersLocal.Count = 0) then
    Exit;

  {----------------------------------------------------------}
  { Новая логика удаления: }
  {  - новые записи удаляем физически }
  {  - существующие помечаем как удалённые }
  {----------------------------------------------------------}
  for I := FDiametersLocal.Count - 1 downto 0 do
  begin
    D := FDiametersLocal[I];
    if D.State = osNew then
      FDiametersLocal.Delete(I)
    else
      D.State := osDeleted;
  end;

  {----------------------------------}
  { Обновляем таблицу }
  {----------------------------------}
  UpdateDiametersGrid;
  UpdatePointsGrid;

  {----------------------------------}
  { Сбрасываем выбранный диаметр }
  {----------------------------------}
  GridDiameters.Selected := -1;
  FSelectedDiameterID := -1;
  FSelectedDiameterIndex := -1;

  SetModified;
end;
procedure TFormTypeEditor.ButtonDiameterDeleteClick(Sender: TObject);
var
  D: TDiameter;
begin
  if (FType = nil) or (FDiametersLocal = nil) then
    Exit;

  D := GetDiameterByVisibleRow(GridDiameters.Row);
  if D = nil then
    Exit;

  if D.State = osNew then
    FDiametersLocal.Remove(D)
  else
    D.State := osDeleted;

  GridDiameters.Row := -1;
  UpdateDiametersGrid;
  UpdatePointsGrid;

  SetModified;
end;

procedure TFormTypeEditor.ButtonPointAddClick(Sender: TObject);
var
  NewP: TTypePoint;
  StdIdx: Integer;
  AccClass: Double;
begin

  if (FType = nil)  then
    Exit;

  {-----------------------------------------------------}
  { Создаём НОВУЮ точку }
  {-----------------------------------------------------}
  NewP := FType.AddTypePoint;

  if (FPointsLocal= nil) then

      FPointsLocal:= FType.Points;

  {-----------------------------------------------------}
  { Определяем индекс стандартной точки }
  {-----------------------------------------------------}



  {-----------------------------------------------------}
  { Имя и Q/Qmax }
  {-----------------------------------------------------}


  if NewP.FlowRate < 1 then
    NewP.Name := Format('%g · Qmax', [NewP.FlowRate])
  else
    NewP.Name := 'Qmax';

  {-----------------------------------------------------}
  { Базовые параметры }
  {-----------------------------------------------------}
  NewP.LimitImp  := 10000;
  NewP.LimitTime := 52;
  NewP.Pause     := 10;
  NewP.Pressure  := 0;
  NewP.Temp      := 0;

  {-----------------------------------------------------}
  { Класс точности → погрешности }
  {-----------------------------------------------------}
  AccClass := ParseAccuracyClass(EditAccuracyClass.Text);

  { Погрешность прибора }
  NewP.Error := AccClass;

  { Погрешность задания расхода }
  if AccClass > 1 then
    NewP.FlowAccuracy := '±10%'
  else if AccClass >= 0.5 then
    NewP.FlowAccuracy := '±5%'
  else
    NewP.FlowAccuracy := '±2%';

  {-----------------------------------------------------}
  { Повторы }
  {-----------------------------------------------------}
  NewP.RepeatsProtocol := 3;
  NewP.Repeats := 3;


  {-----------------------------------------------------}
  { Обновляем таблицу }
  {-----------------------------------------------------}
  UpdatePointsGrid;
  {-----------------------------------------------------}
  { Выделяем новую точку }
  {-----------------------------------------------------}
  if GridPoints.RowCount > 0 then
    GridPoints.Selected := GridPoints.RowCount - 1;

  SetModified;
end;

procedure TFormTypeEditor.ButtonPointDeleteClick(Sender: TObject);
var
  Point: TTypePoint;
  PointIdx: Integer;
begin
  if (FType = nil) or (FPointsLocal = nil) then
    Exit;

  Point := GetPointByVisibleRow(GridPoints.Row);
  if Point = nil then
    Exit;

  if Point.State = osNew then
  begin
    PointIdx := FPointsLocal.IndexOf(Point);
    if PointIdx >= 0 then
      FPointsLocal.Delete(PointIdx);
  end
  else
    Point.State := osDeleted;

  GridPoints.Row := -1;
  UpdatePointsGrid;

  SetModified;
end;

procedure TFormTypeEditor.ButtonPointsClearClick(Sender: TObject);
var
  I: Integer;
  P: TTypePoint;
begin
  {----------------------------------}
  { Защита }
  {----------------------------------}
  if (FPointsLocal = nil) or (FPointsLocal.Count = 0) then
    Exit;

  {----------------------------------------------------------}
  { Новая логика удаления: }
  {  - новые записи удаляем физически }
  {  - существующие помечаем как удалённые }
  {----------------------------------------------------------}
  for I := FPointsLocal.Count - 1 downto 0 do
  begin
    P := FPointsLocal[I];
    if P.State = osNew then
      FPointsLocal.Delete(I)
    else
      P.State := osDeleted;
  end;

  {-----------------------------------------------------}
  { Обновляем таблицу точек }
  {-----------------------------------------------------}
  UpdatePointsGrid;

  {-----------------------------------------------------}
  { Сбрасываем выделение }
  {-----------------------------------------------------}
  GridPoints.Row := -1;

  SetModified;
end;

procedure TFormTypeEditor.cbBaudRateChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if (cbBaudRate.ItemIndex < 0) or
     (cbBaudRate.ItemIndex > High(BaudRates)) then
    Exit;

  // сохраняем скорость
  FType.BaudRate := BaudRates[cbBaudRate.ItemIndex];

  // UX
  cbBaudRate.Hint := cbBaudRate.Text;
end;

procedure TFormTypeEditor.cbCoefViewTypeChange(Sender: TObject);
var
  ViewType: Integer;
  DisplayCoef: Double;
begin
  if FLoading then Exit;

  ViewType := cbCoefViewType.ItemIndex;
  if ViewType < 0 then Exit;

  // сохраняем тип представления
  FType.DimensionCoef := ViewType;

  // базовый коэффициент всегда хранится как имп/л (имп/кг)
  if FType.Coef <= 0 then
  begin
    EditCoef.Text := '';
    Exit;
  end;

  case ViewType of
    0: // имп/л (имп/кг)
      DisplayCoef := FType.Coef;

    1: // л/имп (кг/имп)
      DisplayCoef := 1 / FType.Coef;
  else
    DisplayCoef := FType.Coef;
  end;

  // отображаем
  EditCoef.Text := FormatFloat('0.########', DisplayCoef);

  SetModified;
end;

procedure TFormTypeEditor.cbCurrentRangeChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if cbCurrentRange.ItemIndex < 0 then
    Exit;

  { сохраняем диапазон }
  FType.CurrentRange := cbCurrentRange.ItemIndex;

  { для Type пересчёт по диаметру при необходимости }
  if FSelectedDiameterID >= 0 then
  begin
    // RecalcPointsBySelectedDiameter;
  end;

  SetModified;
end;

procedure TFormTypeEditor.cbOutPutType2Change(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then Exit;

  V := cbOutPutType2.ItemIndex;
  if V < 0 then Exit;

  // сохраняем в модель
  FType.OutputSet := V;

  SetModified;
end;

procedure TFormTypeEditor.cbInputTypeChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if cbInputType.ItemIndex < 0 then
    Exit;

  // 0 – Ручной
  // 1 – Фотофиксация
  FType.InputType := cbInputType.ItemIndex;

  // UX
  cbInputType.Hint := cbInputType.Text;
end;


procedure TFormTypeEditor.cbLibraresChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if cbLibrares.ItemIndex < 0 then
    Exit;

  // сохраняем имя протокола
  FType.ProtocolName := cbLibrares.Text;

  // подсказка для UX
  cbLibrares.Hint := cbLibrares.Text;
end;

procedure TFormTypeEditor.cbMeasuredDimensionChange(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then Exit;

  V := cbMeasuredDimension.ItemIndex;
  if V < 0 then Exit;

  // сохраняем в модель
  FType.MeasuredDimension := V;

  // применяем логику для выбранной величины
  ApplyMeasuredDimension;

  SetModified;
end;

procedure TFormTypeEditor.cbOutPutTypeChange(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then Exit;

  V := cbOutPutType.ItemIndex;
  if V < 0 then Exit;

  // сохраняем в модель
  FType.OutputSet := V;

  SetModified;
end;

procedure TFormTypeEditor.cbParityChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if cbParity.ItemIndex < 0 then
    Exit;

  // 0 – Нет
  // 1 – Четность
  // 2 – Нечетность
  FType.Parity := cbParity.ItemIndex;

  // UX
  cbParity.Hint := cbParity.Text;
end;

procedure TFormTypeEditor.cbProcedureChange(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  if cbProcedure.ItemIndex >= 0 then
    S := cbProcedure.Items[cbProcedure.ItemIndex]
  else
    S := '';

  // сохраняем в модель
  FType.ProcedureName := S;

  SetModified;
end;

procedure TFormTypeEditor.cbSpillageStopChange(Sender: TObject);
begin
  if FLoading then Exit;

  if cbSpillageStop.ItemIndex < 0 then
    Exit;

  // просто сохраняем критерий остановки
  FType.SpillageStop := cbSpillageStop.ItemIndex;

  SetModified;
end;

procedure TFormTypeEditor.cbSpillageTypeChange(Sender: TObject);
begin
  if FLoading then Exit;

  // защита
  if cbSpillageType.ItemIndex < 0 then
    Exit;

  // сохраняем выбор
  FType.SpillageType := cbSpillageType.ItemIndex;

  SetModified;
end;

procedure TFormTypeEditor.cbVoltageRangeChange(Sender: TObject);
begin
  if FLoading then
    Exit;

  if (cbVoltageRange.ItemIndex < 0) then
    Exit;

  // сохраняем диапазон
  FType.VoltageRange := cbVoltageRange.ItemIndex;

  // если выбран диаметр — обновляем расчёты
  if FSelectedDiameterID >= 0 then
   // RecalcPointsBySelectedDiameter;
end;

procedure TFormTypeEditor.ceCategoryChange(Sender: TObject);
var
  C: TDeviceCategory;
  Idx: Integer;
  CatID: Integer;
begin
  if FLoading then
    Exit;

  if FType = nil then
    Exit;

  {----------------------------------}
  { 1. Проверяем выбор из списка }
  {----------------------------------}
  Idx := ceCategory.ItemIndex;

  if (Idx >= 0) and (Idx < ceCategory.Items.Count) then
  begin
    {----------------------------------}
    { Выбор из справочника }
    {----------------------------------}
    CatID := Integer(ceCategory.Items.Objects[Idx]);

    FType.Category := CatID;
    FType.CategoryName := '';

    {----------------------------------}
    { Применяем defaults категории }
    {----------------------------------}
    C := DataManager.FindCategoryByID(CatID);
    if C <> nil then
    begin
      if FType.MeasuredDimension <> Ord(C.MeasuredDimension) then
      begin
        FType.MeasuredDimension := Ord(C.MeasuredDimension);
        ApplyMeasuredDimension;
      end;

      if FType.OutputType <> Ord(C.DefaultOutputType) then
      begin
        FType.OutputType := Ord(C.DefaultOutputType);
        cbOutputType.ItemIndex := FType.OutputType;
        ApplyOutputType;
      end;
    end;
  end
  else
  begin
    {----------------------------------}
    { Ручной ввод }
    {----------------------------------}
    FType.Category := -1;
    FType.CategoryName := Trim(ceCategory.Text);
  end;

  ceCategory.Hint := ceCategory.Text;
  SetModified;
end;

procedure TFormTypeEditor.ComboBoxOutputTypeChange(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then Exit;

  V := ComboBoxOutputType.ItemIndex;
  if V < 0 then Exit;

  // сохраняем в модель
  FType.OutputType := V;

  // применяем настройки UI под тип сигнала
  ApplyOutputType;

  SetModified;
end;

procedure TFormTypeEditor.CornerButtonCancelClick(Sender: TObject);
begin
     ModalResult := mrCancel;
end;
procedure SendTypeDescriptionToDeepSeek(
  const FilePath: string;
  out ResponseText: string
);
var
  Http: TNetHTTPClient;
  ReqBody: TStringStream;
  Resp: IHTTPResponse;

  FileText: string;
  LimitedText: string;

  JsonReq, MsgSys, MsgUser: TJSONObject;
  Messages: TJSONArray;

  ApiKey: string;

const
  MAX_TEXT_LENGTH = 12000; // ⬅ безопасно для DeepSeek
begin
  if not FileExists(FilePath) then
    raise Exception.Create('Файл не найден: ' + FilePath);

  ApiKey := '';
  if ApiKey = '' then
    raise Exception.Create('DEEPSEEK_API_KEY не задан');

  {----------------------------------}
  { Читаем ТЕКСТ (НЕ base64) }
  {----------------------------------}
  FileText := TFile.ReadAllText(FilePath, TEncoding.UTF8);

  {----------------------------------}
  { Жёстко ограничиваем размер }
  {----------------------------------}
  if Length(FileText) > MAX_TEXT_LENGTH then
    LimitedText := Copy(FileText, 1, MAX_TEXT_LENGTH)
  else
    LimitedText := FileText;

  {----------------------------------}
  { Формируем JSON запроса }
  {----------------------------------}
  JsonReq := TJSONObject.Create;
  Messages := TJSONArray.Create;

  MsgSys := TJSONObject.Create;
  MsgSys.AddPair('role', 'system');
  MsgSys.AddPair(
    'content',
    'Ты инженер-метролог. Извлекай ТОЛЬКО диаметры и расходы.'
  );

  MsgUser := TJSONObject.Create;
  MsgUser.AddPair('role', 'user');
  MsgUser.AddPair(
    'content',
    'Из текста ниже извлеки информацию о диаметрах (DN) ' +
    'и максимальных расходах (Qmax).' + sLineBreak +
    'Ответ верни СТРОГО в формате JSON:' + sLineBreak +
    '{ "diameters": [ { "dn": 15, "qmax": 1.5 } ] }' +
    sLineBreak + sLineBreak +
    LimitedText
  );

  Messages.Add(MsgSys);
  Messages.Add(MsgUser);

  JsonReq.AddPair('model', 'deepseek-chat');
  JsonReq.AddPair('messages', Messages);
  JsonReq.AddPair('temperature', TJSONNumber.Create(0));
  JsonReq.AddPair('stream', TJSONBool.Create(False));

  ReqBody := TStringStream.Create(JsonReq.ToJSON, TEncoding.UTF8);

  Http := TNetHTTPClient.Create(nil);
  try
    Http.CustomHeaders['Authorization'] :=
      'Bearer ' + ApiKey;
    Http.CustomHeaders['Content-Type'] :=
      'application/json';

    Resp := Http.Post(
      'https://api.deepseek.com/chat/completions',
      ReqBody
    );

    ResponseText := Resp.ContentAsString(TEncoding.UTF8);

  finally
    Http.Free;
    ReqBody.Free;
    JsonReq.Free;
  end;
end;

procedure SendTypeDescriptionToChatGPT(
  const FilePath: string;
  out ResponseText: string
);
var
  Http: TNetHTTPClient;
  ReqBody: TStringStream;
  Resp: IHTTPResponse;

  FileBytes: TBytes;
  FileBase64: string;

  JsonReq, MsgSys, MsgUser: TJSONObject;
  Messages: TJSONArray;

  ApiKey: string;
begin
  if not FileExists(FilePath) then
    raise Exception.Create('Файл не найден: ' + FilePath);

  ApiKey := '';
  if ApiKey = '' then
    raise Exception.Create('OPENAI_API_KEY не задан');

  {----------------------------------}
  { Файл → Base64 }
  {----------------------------------}
  FileBytes := TFile.ReadAllBytes(FilePath);
  FileBase64 := TNetEncoding.Base64.EncodeBytesToString(FileBytes);

  {----------------------------------}
  { JSON запроса }
  {----------------------------------}
  JsonReq := TJSONObject.Create;
  Messages := TJSONArray.Create;

  MsgSys := TJSONObject.Create;
  MsgSys.AddPair('role', 'system');
  MsgSys.AddPair(
    'content',
    'Ты инженер-метролог. Анализируй описание типа СИ.'
  );

  MsgUser := TJSONObject.Create;
  MsgUser.AddPair('role', 'user');
  MsgUser.AddPair(
    'content',
    'Вот описание типа прибора (base64 PDF):' + sLineBreak +
    FileBase64 + sLineBreak + sLineBreak +
    'Дай набор диаметров с расходами для каждого диаметра ' +
    'строго в формате:' + sLineBreak +
    'DN1 = ...; Qmax1 = ...;' + sLineBreak +
    'DN2 = ...; Qmax2 = ...;'
  );

  Messages.Add(MsgSys);
  Messages.Add(MsgUser);

  JsonReq.AddPair('model', 'gpt-4o-mini');
  JsonReq.AddPair('messages', Messages);
  JsonReq.AddPair('temperature', TJSONNumber.Create(0));
  JsonReq.AddPair('stream', TJSONBool.Create(False));

  ReqBody := TStringStream.Create(JsonReq.ToJSON, TEncoding.UTF8);

  Http := TNetHTTPClient.Create(nil);
  try
    Http.CustomHeaders['Authorization'] :=
      'Bearer ' + ApiKey;
    Http.CustomHeaders['Content-Type'] :=
      'application/json';

    Resp := Http.Post(
      'https://api.openai.com/v1/chat/completions',
      ReqBody
    );

    ResponseText := Resp.ContentAsString(TEncoding.UTF8);

  finally
    Http.Free;
    ReqBody.Free;
    JsonReq.Free;
  end;
end;


procedure TFormTypeEditor.DeepSeekClick(Sender: TObject);
var
  FilePath: string;
  AIResponse: string;
begin
  MemoLog.Visible := True;
  MemoLog.Lines.Clear;

  {----------------------------------}
  { Проверки }
  {----------------------------------}
  if FType = nil then
  begin
    MemoLog.Lines.Add('Тип прибора не инициализирован');
    Exit;
  end;

  FilePath := FType.Documentation;

  if FilePath = '' then
  begin
    MemoLog.Lines.Add('Файл описания типа не привязан');
    ShowMessage('Нет файла описания типа для отправки в DeepSeek');
    Exit;
  end;

  if not FileExists(FilePath) then
  begin
    MemoLog.Lines.Add('Файл не найден: ' + FilePath);
    ShowMessage('Файл описания типа не найден');
    Exit;
  end;

  {----------------------------------}
  { Отправка файла в DeepSeek }
  {----------------------------------}
  try
    MemoLog.Lines.Add('Отправка описания типа в DeepSeek...');
    MemoLog.Lines.Add(FilePath);
    MemoLog.Lines.Add('------------------------------');

    SendTypeDescriptionToDeepSeek(
      FilePath,
      AIResponse
    );

    MemoLog.Lines.Add('Ответ DeepSeek:');
    MemoLog.Lines.Add(AIResponse);
    MemoLog.Lines.Add('------------------------------');

    ShowMessage(
      'DeepSeek обработал описание типа.' + sLineBreak +
      'Результат выведен в лог.'
    );

  except
    on E: Exception do
    begin
      MemoLog.Lines.Add('ERROR DeepSeek: ' + E.Message);
      ShowMessage('Ошибка при обращении к DeepSeek');
    end;
  end;
end;


procedure TFormTypeEditor.ChatGPTClick(Sender: TObject);
var
  AIResponse: string;
begin
  MemoLog.Visible := True;
  MemoLog.Lines.Clear;

  if FType = nil then
  begin
    ShowMessage('Тип прибора не инициализирован');
    Exit;
  end;

  if (FType.Documentation = '') or
     (not FileExists(FType.Documentation)) then
  begin
    ShowMessage('Файл описания типа не найден');
    Exit;
  end;

  try
    MemoLog.Lines.Add('Отправка описания типа в ChatGPT...');
    SendTypeDescriptionToChatGPT(
      FType.Documentation,
      AIResponse
    );

    MemoLog.Lines.Add('Ответ ChatGPT:');
    MemoLog.Lines.Add(AIResponse);

    ShowMessage('ChatGPT обработал описание типа');

  except
    on E: Exception do
    begin
      MemoLog.Lines.Add('ERROR ChatGPT: ' + E.Message);
      ShowMessage('Ошибка при обращении к ChatGPT');
    end;
  end;
end;




procedure TFormTypeEditor.EditVoltageQmaxExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FLoading then
    Exit;

  NewRate := NormalizeFloatInput(EditVoltageQmax.Text);

  if (NewRate <= 0) or (NewRate > 1) then
  begin
    EditVoltageQmax.Text := FloatToStr(FType.VoltageQmaxRate);
    Exit;
  end;

  if SameValue(FType.VoltageQmaxRate, NewRate) then
    Exit;

  FType.VoltageQmaxRate := NewRate;

end;

procedure TFormTypeEditor.EditVoltageQminExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FLoading then
    Exit;

  NewRate := NormalizeFloatInput(EditVoltageQmin.Text);

  // допустимы только доли
  if (NewRate <= 0) or (NewRate >= 1) then
  begin
    EditVoltageQmin.Text := FloatToStr(FType.VoltageQminRate);
    Exit;
  end;

  if SameValue(FType.VoltageQminRate, NewRate) then
    Exit;

  FType.VoltageQminRate := NewRate;

end;

procedure TFormTypeEditor.EditAccuracyClassExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  S := Trim(EditAccuracyClass.Text);

  // сохраняем в модель
  FType.AccuracyClass := S;
  EditAccuracyClass.Text := S;

  // prompt, если пусто
  if S = '' then
    EditAccuracyClass.TextPrompt := 'Класс точности'
  else
    EditAccuracyClass.TextPrompt := '';

  SetModified;
end;

procedure TFormTypeEditor.EditAccuracyClassTyping(Sender: TObject);
var
  E: TEdit;
begin
  E := Sender as TEdit;

  // убираем двойные пробелы
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;

procedure TFormTypeEditor.EditCoefExit(Sender: TObject);
var
  InputValue: Double;
  NewBaseCoef: Double;
begin
  // 1. Безопасный ввод
  InputValue := NormalizeFloatInput(EditCoef.Text);

  // 2. Защита от мусора и нуля
  if InputValue <= 0 then
  begin
    EditCoef.Text := FormatFloat('0.########', GetDisplayedCoef);
    Exit;
  end;

  // 3. Приводим введённое значение к базовому виду (имп/л)
  case FType.DimensionCoef of
    0: NewBaseCoef := InputValue;        // имп/л
    1: NewBaseCoef := 1 / InputValue;    // л/имп → имп/л
  else
    NewBaseCoef := InputValue;
  end;

  // 4. Если базовый коэффициент не изменился — выходим
  if SameValue(FType.Coef, NewBaseCoef, 1e-12) then
    Exit;

  // 5. Сохраняем базовый коэффициент
  FType.Coef := NewBaseCoef;

  // 6. Пересчёт Kp для всех диаметров
  RecalcDiametersKp;

  // 7. Обновление таблицы диаметров
  UpdateDiametersGrid;

  // 8. Пересчёт точек для выбранного диаметра
  if GridDiameters.Selected > 0 then
    RecalcPointsBySelectedDiameter;

  SetModified;
end;


procedure TFormTypeEditor.EditCurrentQmaxExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FLoading then
    Exit;

  NewRate := NormalizeFloatInput(EditCurrentQmax.Text);

  { допустимы только доли 0..1 }
  if (NewRate <= 0) or (NewRate > 1) then
  begin
    EditCurrentQmax.Text := FloatToStr(FType.CurrentQmaxRate);
    Exit;
  end;

  if SameValue(FType.CurrentQmaxRate, NewRate) then
    Exit;

  FType.CurrentQmaxRate := NewRate;

  SetModified;
end;

procedure TFormTypeEditor.EditCurrentQminExit(Sender: TObject);
var
  NewRate: Double;
begin
  if FLoading then
    Exit;

  NewRate := NormalizeFloatInput(EditCurrentQmin.Text);

  { допустимы только доли 0..1 }
  if (NewRate <= 0) or (NewRate >= 1) then
  begin
    EditCurrentQmin.Text := FloatToStr(FType.CurrentQminRate);
    Exit;
  end;

  if SameValue(FType.CurrentQminRate, NewRate) then
    Exit;

  FType.CurrentQminRate := NewRate;

  SetModified;
end;


procedure TFormTypeEditor.RecalcDiametersKp;
var
  I: Integer;
begin
  if (FDiametersLocal = nil) or (FType = nil) then
    Exit;

  for I := 0 to FDiametersLocal.Count - 1 do
    FDiametersLocal[I].Kp := FType.Coef * FDiametersLocal[I].Qmax;
end;


procedure TFormTypeEditor.EditErrorEnter(Sender: TObject);
begin
  if FLoading then Exit;

  if FType.Error > 0 then
    EditError.Text := FloatToStr(FType.Error)
  else
    EditError.Text := '';
end;

procedure TFormTypeEditor.EditErrorExit(Sender: TObject);
var
  Err: Double;
begin
  if FLoading then Exit;

  Err := NormalizeFloatInput(EditError.Text);

  if Err <= 0 then
  begin
    FType.Error := 0;
    EditError.Text := '';
    EditError.TextPrompt := '—';
  end
  else
  begin
    FType.Error := Err;
    EditError.Text := FormatPercentPM(Err);
    EditError.TextPrompt := '';
  end;

  // 🔴 КЛЮЧЕВОЕ МЕСТО
  UpdatePointsErrorFromType;
  UpdateDiametersGrid;

  SetModified;
end;

procedure TFormTypeEditor.EditFreqExit(Sender: TObject);
var
  NewFreq: Integer;
begin
  if FLoading then
    Exit;

  // ----------------------------------------
  // Безопасный ввод (частота — целое)
  // ----------------------------------------
  NewFreq := Trunc(NormalizeFloatInput(EditFreq.Text));

  // ----------------------------------------
  // Защита от мусора
  // ----------------------------------------
  if NewFreq <= 0 then
  begin
    EditFreq.Text := IntToStr(FType.Freq);
    Exit;
  end;

  // ----------------------------------------
  // Нет изменений
  // ----------------------------------------
  if FType.Freq = NewFreq then
    Exit;

  // ----------------------------------------
  // Сохраняем в тип
  // ----------------------------------------
  FType.Freq := NewFreq;

  // ----------------------------------------
  // Обновление таблицы диаметров
  // ----------------------------------------
  UpdateDiametersGrid;

  // ----------------------------------------
  // Если выбран диаметр — обновляем точки
  // ----------------------------------------
  if FSelectedDiameterID >= 0 then
    RecalcPointsBySelectedDiameter;
end;

procedure TFormTypeEditor.EditFreqFlowRateExit(Sender: TObject);
var
  NewRate: Double;
  I: Integer;
begin
  if FLoading then
    Exit;

  // ----------------------------------------
  // Безопасный ввод
  // ----------------------------------------
  NewRate := NormalizeFloatInput(EditFreqFlowRate.Text);

  if NewRate <= 0 then
  begin
    EditFreqFlowRate.Text := FloatToStr(FType.FreqFlowRate);
    Exit;
  end;

  // ----------------------------------------
  // Нет изменений
  // ----------------------------------------
  if SameValue(FType.FreqFlowRate, NewRate) then
    Exit;

  // ----------------------------------------
  // Сохраняем в тип
  // ----------------------------------------
  FType.FreqFlowRate := NewRate;

  // ----------------------------------------
  // Пересчёт QF по всем диаметрам
  // QF = Qmax * FreqFlowRate
  // ----------------------------------------
  for I := 0 to FDiametersLocal.Count-1 do
    FDiametersLocal[I].QFmax :=
      FDiametersLocal[I].Qmax * FType.FreqFlowRate;

  // ----------------------------------------
  // Обновление таблицы диаметров
  // ----------------------------------------
  UpdateDiametersGrid;

  // ----------------------------------------
  // Если выбран диаметр — обновляем точки
  // ----------------------------------------
  if FSelectedDiameterID >= 0 then
    RecalcPointsBySelectedDiameter;
end;


procedure TFormTypeEditor.EditIVIExit(Sender: TObject);
var
  V: Integer;
begin
  if FLoading then Exit;

  if ExtractInt(EditIVI.Text, V) and (V >= 0) then
  begin
    FType.IVI := V;
    EditIVI.Text := IntToStr(V);

    SetModified;
  end
  else
  begin
    // некорректный ввод — откат
    if FType.IVI > 0 then
      EditIVI.Text := IntToStr(FType.IVI)
    else
      EditIVI.Text := '';
  end;
end;

procedure TFormTypeEditor.EditModificationExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  S := Trim(EditModification.Text);

  // сохраняем в модель
  FType.Modification := S;
  EditModification.Text := S;

  // prompt, если пусто
  if S = '' then
    EditModification.TextPrompt := 'Модификация'
  else
    EditModification.TextPrompt := S;

  SetModified;
end;


procedure TFormTypeEditor.EditModificationTyping(Sender: TObject);
var
  E: TEdit;
begin
  E := Sender as TEdit;

  // убираем двойные пробелы
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;


procedure TFormTypeEditor.EditNameExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  S := Trim(EditName.Text);

  // сохраняем в модель
  FType.Name := S;
  EditName.Text := S;

  // prompt, если пусто
  if S = '' then
    EditName.TextPrompt := 'Наименование типа'
  else
    EditName.TextPrompt := '';

  SetModified;
end;

procedure TFormTypeEditor.EditNameTyping(Sender: TObject);
var
  E: TEdit;
begin
  E := Sender as TEdit;

  // пример: убираем двойные пробелы
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;



procedure TFormTypeEditor.EditRangeDynamicEnter(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  S := EditRangeDynamic.Text.Trim;

  // если было "1:X" → показываем просто X
  if S.StartsWith('1:') then
    EditRangeDynamic.Text := Copy(S, 3, MaxInt);
end;

procedure TFormTypeEditor.EditRangeDynamicExit(Sender: TObject);
var
  I: Integer;
  RangeDynamic: Double;
begin
  if FLoading then Exit;

  // -----------------------------------------------------
  // Парсим введённое значение
  // -----------------------------------------------------
  RangeDynamic := StrToFloatDef(EditRangeDynamic.Text, 0);

  // -----------------------------------------------------
  // Если значение не задано или некорректно
  // -----------------------------------------------------
  if RangeDynamic <= 0 then
  begin
    // сбрасываем динамический диапазон в типе
    FType.RangeDynamic := 0;

    EditRangeDynamic.Text := '';
    UpdateRangeDynamicPrompt;
    Exit;
  end;

  // -----------------------------------------------------
  // Сохраняем В МОДЕЛЬ ТИПА (ИСТОЧНИК ИСТИНЫ)
  // -----------------------------------------------------
  FType.RangeDynamic := RangeDynamic;

  // -----------------------------------------------------
  // Пересчитываем Qmin для всех ЛОКАЛЬНЫХ диаметров
  // -----------------------------------------------------
  for I := 0 to FDiametersLocal.Count-1 do
  begin
    if FDiametersLocal[I].Qmax > 0 then
      FDiametersLocal[I].Qmin :=
        FDiametersLocal[I].Qmax / RangeDynamic
    else
      FDiametersLocal[I].Qmin := 0;
  end;

  // -----------------------------------------------------
  // Форматируем отображение 1:X
  // -----------------------------------------------------
  EditRangeDynamic.Text := '1:' + IntToStr(Round(RangeDynamic));
  EditRangeDynamic.TextPrompt := '';

  // -----------------------------------------------------
  // Обновляем таблицу диаметров
  // -----------------------------------------------------
  UpdateDiametersGrid;

  SetModified;
end;


procedure TFormTypeEditor.EditRegDateExit(Sender: TObject);
var
  D: TDateTime;
  S: string;
begin
  if FLoading then Exit;

  S := Trim(EditRegDate.Text);

  if S = '' then
  begin
    FType.RegDate := 0;
    EditRegDate.Text := '';
    SetModified;
    Exit;
  end;

  if ParseFlexibleDate(S, D) then
  begin
    FType.RegDate := D;
    EditRegDate.Text := DateToStr(D);

    // 🔹 если дата окончания не задана или стала некорректной — проставляем автоматически
    if (FType.ValidityDate = 0) or (FType.ValidityDate < D) then
    begin
      FType.ValidityDate := IncYear(D, DEFAULT_TYPE_CERT_YEARS);
      EditValidityDate.Text := DateToStr(FType.ValidityDate);
    end;

    SetModified;
  end
  else
  begin
    // откат
    if FType.RegDate > 0 then
      EditRegDate.Text := DateToStr(FType.RegDate)
    else
      EditRegDate.Text := '';
  end;
end;

procedure TFormTypeEditor.EditValidityDateExit(Sender: TObject);
var
  D: TDateTime;
  S: string;
begin
  if FLoading then Exit;

  S := Trim(EditValidityDate.Text);

  if S = '' then
  begin
    FType.ValidityDate := 0;
    EditValidityDate.Text := '';
    SetModified;
    Exit;
  end;

  if ParseFlexibleDate(S, D) then
  begin
    // ❗ дата окончания не может быть раньше даты регистрации
    if (FType.RegDate > 0) and (D < FType.RegDate) then
      D := IncYear(FType.RegDate, DEFAULT_TYPE_CERT_YEARS);

    FType.ValidityDate := D;
    EditValidityDate.Text := DateToStr(D);

    SetModified;
  end
  else
  begin
    if FType.ValidityDate > 0 then
      EditValidityDate.Text := DateToStr(FType.ValidityDate)
    else
      EditValidityDate.Text := '';
  end;
end;

procedure TFormTypeEditor.edtAddrExit(Sender: TObject);
var
  NewAddr: Integer;
begin
  if FLoading then
    Exit;

  NewAddr := Trunc(NormalizeFloatInput(edtAddr.Text));

  // адрес должен быть неотрицательный
  if NewAddr < 0 then
  begin
    edtAddr.Text := IntToStr(FType.DeviceAddress);
    Exit;
  end;

  if FType.DeviceAddress = NewAddr then
    Exit;

  FType.DeviceAddress := NewAddr;
end;



procedure TFormTypeEditor.edtDocumentationExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  S := Trim(edtDocumentation.Text);

  // сохраняем в модель
  FType.Documentation := S;
  edtDocumentation.Text := S;

  // prompt, если пусто
  if S = '' then
    edtDocumentation.TextPrompt := 'Документация'
  else
    edtDocumentation.TextPrompt := '';

  SetModified;
end;

procedure TFormTypeEditor.edtDocumentationTyping(Sender: TObject);
var
  E: TEdit;
begin
  E := Sender as TEdit;

  // убираем двойные пробелы
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;

procedure TFormTypeEditor.edtManufacturerExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  S := Trim(edtManufacturer.Text);

  // сохраняем в модель
  FType.Manufacturer := S;
  edtManufacturer.Text := S;

  // prompt и hint
  if S <> '' then
  begin
    edtManufacturer.TextPrompt := '';
    edtManufacturer.Hint := S;
  end
  else
  begin
    edtManufacturer.TextPrompt := 'Изготовитель';
    edtManufacturer.Hint := '';
  end;

  SetModified;
end;

procedure TFormTypeEditor.edtReestrNumberExit(Sender: TObject);
var
  S: string;
begin
  if FLoading then Exit;

  S := Trim(edtReestrNumber.Text);

  // сохраняем в модель
  FType.ReestrNumber := S;
  edtReestrNumber.Text := S;

  // prompt, если пусто
  if S = '' then
    edtReestrNumber.TextPrompt := 'ГРСИ'
  else
    edtReestrNumber.TextPrompt := '';

  SetModified;
end;

procedure TFormTypeEditor.edtReestrNumberTyping(Sender: TObject);
var
  E: TEdit;
begin
  E := Sender as TEdit;

  // убираем двойные пробелы
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;

procedure TFormTypeEditor.UpdateRangeDynamicPrompt;
var
  Idx: Integer;
  Qmax, Qmin: Double;
begin


  if FDiametersLocal = nil then
  begin
  // ShowMessage('Список диаметров не инициализирован!');
    Exit;  // Прерываем выполнение, если список не инициализирован
  end;

  EditRangeDynamic.TextPrompt := '';

  if FDiametersLocal.Count = 0 then
    Exit;

  if (GridDiameters.Selected >= 0) and
     (GridDiameters.Selected <= FDiametersLocal.Count-1) then
    Idx := GridDiameters.Selected
  else
    Idx := 0;

  Qmax := FDiametersLocal[Idx].Qmax;
  Qmin := FDiametersLocal[Idx].Qmin;

  if (Qmax > 0) and (Qmin > 0) then
    EditRangeDynamic.TextPrompt :=
      '1:' + IntToStr(Round(Qmax / Qmin));
end;

procedure TFormTypeEditor.GridDiametersGetValue(
  Sender: TObject;
  const ACol, ARow: Integer;
  var Value: TValue
);
var
  D: TDiameter;
begin
  D := GetDiameterByVisibleRow(ARow);
  if D = nil then
    Exit;

  // =====================================================
  // == Наименование
  // =====================================================
  if ACol = StringColumnDNName.Index then
    Value := D.Name

  // =====================================================
  // == DN (мм) — INTEGER
  // =====================================================
  else if ACol = IntegerColumnDNSize.Index then
    Value := StrToIntDef(D.DN, 0)

  // =====================================================
  // == Qmax
  // =====================================================
  else if ACol = StringColumnDNQmax.Index then
  begin
    if D.Qmax = 0 then
      Value := '—'
    else
      Value := FormatQorV(D.Qmax, FType.Error);
  end

  // =====================================================
  // == Qmin
  // =====================================================
  else if ACol = StringColumnDNQmin.Index then
  begin
    if D.Qmin = 0 then
      Value := '—'
    else
      Value := FormatQorV(D.Qmin, FType.Error);
  end

  // =====================================================
  // == QF
  // =====================================================
  else if ACol = StringColumnDNQF.Index then
  begin
    if D.QFmax = 0 then
      Value := '—'
    else
      Value := FormatQorV(D.QFmax, FType.Error);
  end

  // =====================================================
  // == Kp (коэффициент)
  // =====================================================
  else if ACol = StringColumnDNKp.Index then
  begin
    if D.Kp = 0 then
      Value := '—'
    else
      // для Kp используем ту же логику точности,
      // т.к. он участвует в расчёте объёма/массы
      Value := FormatQorV(D.Kp, FType.Error);
  end;
end;


procedure TFormTypeEditor.GridDiametersSelChanged(Sender: TObject);
var
  D: TDiameter;
  NewCoef: Double;
begin
  D := GetDiameterByVisibleRow(GridDiameters.Selected);
  if D = nil then
  begin
    FSelectedDiameterID := -1;
    Exit;
  end;

  FSelectedDiameterID := D.ID;

  // ----------------------------------------
  // Если диапазон не задан явно —
  // показываем подсказку по выбранному диаметру
  // ----------------------------------------
  if Trim(EditRangeDynamic.Text) = '' then
    UpdateRangeDynamicPromptBySelectedDiameter;

  // ----------------------------------------
  // FreqFlowRate не задан — считаем и показываем подсказку
  // ----------------------------------------
  if FType.FreqFlowRate = 0 then
  begin
    if D.Qmax > 0 then
      NewCoef := D.QFmax / D.Qmax
    else
      NewCoef := 0;

    if NewCoef > 0 then
      EditFreqFlowRate.TextPrompt := FloatToStr(NewCoef)
    else
      EditFreqFlowRate.TextPrompt := '-';
  end;


  // ----------------------------------------
  // Coef не задан — считаем и показываем подсказку
  // ----------------------------------------
  if FType.Coef = 0 then
  begin
    if D.Qmax > 0 then
      NewCoef := D.Kp / D.Qmax
    else
      NewCoef := 0;

    if NewCoef > 0 then
      EditCoef.TextPrompt := FloatToStr(NewCoef)
    else
      EditCoef.TextPrompt := '-';
  end;

  // ----------------------------------------
  // Обновление таблицы точек
  // ----------------------------------------
  RecalcPointsBySelectedDiameter;
  UpdatePointsGrid;
end;

procedure TFormTypeEditor.GridDiametersSetValue(
  Sender: TObject;
  const ACol, ARow: Integer;
  const Value: TValue
);
var
  D: TDiameter;
  S: string;
  Qmax, RangeDynamic, NewCoef: Double;
  SelD: TDiameter;
begin
  {-----------------------------------------------------}
  { Защита }
  {-----------------------------------------------------}
  if (FDiametersLocal = nil) then
    Exit;

  D := GetDiameterByVisibleRow(ARow);
  if D = nil then
    Exit;

  S := Trim(Value.AsString);

  {=====================================================}
  { ИМЯ }
  {=====================================================}
  if ACol = StringColumnDNName.Index then
    D.Name := S

  {=====================================================}
  { DN (мм) }
  {=====================================================}
  else if ACol = IntegerColumnDNSize.Index then
    D.DN := IntToStr(Round(NormalizeFloatInput(S)))

  {=====================================================}
  { Qmax }
  {=====================================================}
  else if ACol = StringColumnDNQmax.Index then
  begin
    Qmax := NormalizeFloatInput(S);
    D.Qmax := Qmax;

    { QF = Qmax }
    if FType.FreqFlowRate > 0 then
      D.QFmax := Qmax * FType.FreqFlowRate
    else
      D.QFmax := Qmax;

    { Qmin из динамического диапазона типа }
    RangeDynamic := FType.RangeDynamic;
    if (RangeDynamic > 0) and (Qmax > 0) then
      D.Qmin := Qmax / RangeDynamic
    else
      D.Qmin := 0;

    SelD := GetDiameterByVisibleRow(GridDiameters.Row);
    if SelD = D then
      RecalcPointsBySelectedDiameter;
  end

  {=====================================================}
  { Qmin (ручной ввод) }
  {=====================================================}
  else if ACol = StringColumnDNQmin.Index then
  begin
    D.Qmin := NormalizeFloatInput(S);

    { ручной ввод => диапазон не актуален }
    FType.RangeDynamic := 0;
    EditRangeDynamic.Text := '';

    UpdateRangeDynamicPromptBySelectedDiameter;
  end

  {=====================================================}
  { QF }
  {=====================================================}
  else if ACol = StringColumnDNQF.Index then
  begin
    D.QFmax := NormalizeFloatInput(S);

    if D.Qmax > 0 then
      NewCoef := D.QFmax / D.Qmax
    else
      NewCoef := 0;

    if not SameValue(NewCoef, FType.FreqFlowRate) then
    begin
      FType.FreqFlowRate := 0;
      EditFreqFlowRate.Text := '';

      if NewCoef > 0 then
        EditFreqFlowRate.TextPrompt := FloatToStr(NewCoef)
      else
        EditFreqFlowRate.TextPrompt := '-';
    end;

    SelD := GetDiameterByVisibleRow(GridDiameters.Row);
    if SelD = D then
      RecalcPointsBySelectedDiameter;
  end

  {=====================================================}
  { Kp }
  {=====================================================}
  else if ACol = StringColumnDNKp.Index then
  begin
    D.Kp := NormalizeFloatInput(S);

    if D.Qmax > 0 then
      NewCoef := D.Kp / D.Qmax
    else
      NewCoef := 0;

    if not SameValue(NewCoef, FType.Coef) then
    begin
      FType.Coef := 0;
      EditCoef.Text := '';

      if NewCoef > 0 then
        EditCoef.TextPrompt := FloatToStr(NewCoef)
      else
        EditCoef.TextPrompt := '-';
    end;

    SelD := GetDiameterByVisibleRow(GridDiameters.Row);
    if SelD = D then
      RecalcPointsBySelectedDiameter;
  end;

  SetModified;
  UpdateDiametersGrid;
end;

procedure TFormTypeEditor.GridPointsSetValue(
  Sender: TObject;
  const ACol, ARow: Integer;
  const Value: TValue
);
var
  P: TTypePoint;
  D: TDiameter;
  Qmax, Q, V, Tm, Coef: Double;
  S: string;
begin
  {-----------------------------------------------------}
  { Защита }
  {-----------------------------------------------------}
  if (FPointsLocal = nil) then
    Exit;

  P := GetPointByVisibleRow(ARow);
  if P = nil then
    Exit;

  S := Trim(Value.AsString);

  {=====================================================}
  { 1. НЕ зависят от диаметра }
  {=====================================================}

  if ACol = StringColumnPointName.Index then
    P.Name := S

  else if ACol = StringColumnPointStab.Index then
    P.Pause := Round(NormalizeFloatInput(S))

  else if ACol = StringColumnPointPres.Index then
    P.Pressure := NormalizeFloatInput(S)

  else if ACol = StringColumnPontTemp.Index then
    P.Temp := NormalizeFloatInput(S)

  else if ACol = StringColumnPointTempError.Index then
    P.TempAccuracy := NormalizeAccuracyInput(S)

  else if ACol = StringColumnPointFlowError.Index then
    P.FlowAccuracy := NormalizeAccuracyInput(S)

  else if ACol = StringColumnPointError.Index then
    P.Error := NormalizeFloatInput(S)

  {=====================================================}
  { 2. Зависят от диаметра }
  {=====================================================}
  else
  begin
    if (FDiametersLocal = nil) then
      Exit;

    D := GetDiameterByVisibleRow(GridDiameters.Row);
    if D = nil then
      Exit;

    Qmax := D.Qmax;
    Coef := D.Kp;
    Q := P.FlowRate * Qmax;

    {---------------------------------}
    { Q / Qmax }
    {---------------------------------}
    if ACol = StringColumnPointFlowRate.Index then
      P.FlowRate := NormalizeFloatInput(S)

    {---------------------------------}
    { Q (абсолютный) }
    {---------------------------------}
    else if ACol = StringColumnPointQ.Index then
    begin
      Q := NormalizeFloatInput(S);
      if Qmax > 0 then
        P.FlowRate := Q / Qmax;
    end

    {---------------------------------}
    { V → T и Imp }
    {---------------------------------}
    else if ACol = StringColumnPointVolume.Index then
    begin
      V := NormalizeFloatInput(S);
      P.LimitVolume := V;

      if (V > 0) and (Q > 0) then
        P.LimitTime := V * 3.6 / Q;

      if (V > 0) and (Coef > 0) then
        P.LimitImp := Round(V * Coef);
    end

    {---------------------------------}
    { Imp → V и T }
    {---------------------------------}
    else if ACol = StringColumnPointImp.Index then
    begin
      P.LimitImp := Round(NormalizeFloatInput(S));

      if (P.LimitImp > 0) and (Coef > 0) then
      begin
        V := P.LimitImp / Coef;
        P.LimitVolume := V;

        if Q > 0 then
          P.LimitTime := V * 3.6 / Q;
      end;
    end

    {---------------------------------}
    { T → V и Imp }
    {---------------------------------}
    else if ACol = StringColumnPointTime.Index then
    begin
      Tm := NormalizeFloatInput(S);
      P.LimitTime := Tm;

      if (Tm > 0) and (Q > 0) then
      begin
        V := Q * Tm / 3.6;
        P.LimitVolume := V;

        if Coef > 0 then
          P.LimitImp := Round(V * Coef);
      end;
    end;
  end;

  SetModified;
  UpdatePointsGrid;
end;

procedure TFormTypeEditor.RecalcPointsBySelectedDiameter;
var
  I: Integer;
  Qmax, Q, V, Tm, Coef: Double;
  DIdx: Integer;
begin


  // -----------------------------------------------------
  // Проверка выбранного диаметра
  // -----------------------------------------------------
  DIdx := FSelectedDiameterIndex;
  if (DIdx < 0) or (DIdx > FDiametersLocal.Count-1) then
    Exit;

  Qmax := FDiametersLocal[DIdx].Qmax;
  Coef := FDiametersLocal[DIdx].Kp;

  // -----------------------------------------------------
  // Пересчёт всех ЛОКАЛЬНЫХ точек
  // -----------------------------------------------------
  for I := 0 to FPointsLocal.Count-1 do
  begin
    // Q = (Q/Qmax) * Qmax
    Q := FPointsLocal[I].FlowRate * Qmax;

    // если задано время
    if (Q > 0) and (FPointsLocal[I].LimitTime > 0) then
    begin
      Tm := FPointsLocal[I].LimitTime;
      V  := Q * Tm / 3.6;

      FPointsLocal[I].LimitVolume := V;
      FPointsLocal[I].LimitImp    := Round(V * Coef);
    end;
  end;

  // -----------------------------------------------------
  // Обновляем таблицу точек
  // -----------------------------------------------------
  GridPoints.Repaint;
end;

procedure TFormTypeEditor.sbFindReestrNumberClick(Sender: TObject);
var
  Resp: IHTTPResponse;
  Url: string;
  ResponseText: string;

  Json, ResultObj, Item: TJSONObject;
  GeneralObj: TJSONObject;
  Items: TJSONArray;

  MPIArr: TJSONArray;
  MPIObj: TJSONObject;
  ManufacturerArr: TJSONArray;
  SpecArr: TJSONArray;
  SpecObj: TJSONObject;

  MitUUID: string;
  ReestrNum: string;
  DetectText: string;
  DocUrl: string;

  ValidToDate: TDate;
  RegYear: Integer;
  MPIMonths: Integer;

  FileName: string;
  FilePath: string;
  FileStream: TFileStream;

  DevType: TDeviceType;

  P: Integer;
  YY: Integer;
  Y, M, D: Word;
  Dt: TDateTime;
begin

  MemoLog.Visible := True;
  MemoLog.Lines.Clear;

  ReestrNum := edtReestrNumber.Text.Trim;
  if ReestrNum = '' then
  begin
    MemoLog.Lines.Add('ГРСИ не указан');
    Exit;
  end;

  if FType = nil then
  begin
    MemoLog.Lines.Add('Тип прибора не инициализирован');
    Exit;
  end;

  DevType := FType;

  try
    {=================================================}
    { 1. Поиск ГРСИ → mit_uuid }
    {=================================================}
    Url :=
      'https://fgis.gost.ru/fundmetrology/eapi/mit/' +
      '?search=*' + TNetEncoding.URL.Encode(ReestrNum);

    Resp := NetHTTPClient1.Get(Url);
    ResponseText := Resp.ContentAsString;

    MemoLog.Lines.Add('URL поиска: ' + Url);
    MemoLog.Lines.Add(ResponseText);
    MemoLog.Lines.Add('------------------------------');

    Json := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
    try
      ResultObj := Json.GetValue('result') as TJSONObject;
      if ResultObj = nil then Exit;

      Items := ResultObj.GetValue('items') as TJSONArray;
      if (Items = nil) or (Items.Count = 0) then
      begin
        ShowMessage('ГРСИ не найден в АРШИН');
        Exit;
      end;

      Item := Items.Items[0] as TJSONObject;

      if Item.GetValue('mit_uuid') = nil then Exit;
      MitUUID := Item.GetValue('mit_uuid').Value;

    finally
      Json.Free;
    end;

    {=================================================}
    { 2. Загрузка карточки прибора }
    {=================================================}
    Url :=
      'https://fgis.gost.ru/fundmetrology/eapi/mit/' +
      MitUUID;

    Resp := NetHTTPClient1.Get(Url);
    ResponseText := Resp.ContentAsString;

    MemoLog.Lines.Add('URL карточки: ' + Url);
    MemoLog.Lines.Add(ResponseText);
    MemoLog.Lines.Add('------------------------------');

    Json := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
    try
      {---------- general ----------}
      GeneralObj := Json.GetValue('general') as TJSONObject;
      if GeneralObj = nil then Exit;

      DevType.MitUUID :=
        GeneralObj.GetValue('mit_uuid').Value;

      DevType.ReestrNumber :=
        GeneralObj.GetValue('number').Value;

      DevType.Name :=
        GeneralObj.GetValue('title').Value;

      DevType.CategoryName :=
        GeneralObj.GetValue('title').Value;

      {---------- Действие до ----------}
      ValidToDate :=
        ISO8601ToDate(
          GeneralObj.GetValue('valid_to').Value
        );
      DevType.ValidityDate := ValidToDate;

     // DevType.RegDate :=

{---------- Дата регистрации ----------}
 P := Pos('-', DevType.ReestrNumber);
  if P > 0 then
  begin
    YY := StrToIntDef(Copy(DevType.ReestrNumber, P + 1, 2), 0);

    // Считаем год как Integer, чтобы удобно было делать -100
    RegYear := 2000 + YY;
    if RegYear > YearOf(Date) then
      Dec(RegYear, 100);

    // Month/Day берём из ValidityDate (если есть), иначе 1/1
    if DevType.ValidityDate > 0 then
    begin
      M := MonthOf(DevType.ValidityDate);
      D := DayOf(DevType.ValidityDate);
    end
    else
    begin
      M := 1;
      D := 1;
    end;

    // Приведение года к Word (после всех вычислений)
    if (RegYear < 1) or (RegYear > 9999) then
      Exit; // или Y := 1; как тебе нужно
    Y := Word(RegYear);

    // TryEncodeDate требует out-переменную, нельзя туда property напрямую
    if not TryEncodeDate(Y, M, D, Dt) then
      Dt := EncodeDate(Y, M, 1);

    DevType.RegDate := Dt;
  end;

      {---------- МПИ ----------}
      MPIArr := Json.GetValue('mpi') as TJSONArray;
      if (MPIArr <> nil) and (MPIArr.Count > 0) then
      begin
        MPIObj := MPIArr.Items[0] as TJSONObject;
        MPIMonths := MPIObj.GetValue<Integer>('mpi');
        DevType.IVI := MPIMonths div 12;
      end;

      {---------- Производитель ----------}
      ManufacturerArr :=
        Json.GetValue('manufacturer') as TJSONArray;
      if (ManufacturerArr <> nil) and (ManufacturerArr.Count > 0) then
        DevType.Manufacturer :=
          (ManufacturerArr.Items[0] as TJSONObject)
            .GetValue('title').Value;

      {----------------------------------}
      { Автоопределение категории }
      {----------------------------------}
      DetectText :=
        NormalizeSearchText(
          DevType.CategoryName + ' ' + DevType.Name
        );

      DevType.Category :=
        DataManager.ActiveTypeRepo
          .DetectCategoryByKeywords(DetectText);

      {----------------------------------}
      { Скачать описание типа (spec) }
      {----------------------------------}
      SpecArr := Json.GetValue('spec') as TJSONArray;
      if (SpecArr <> nil) and (SpecArr.Count > 0) then
      begin
        SpecObj := SpecArr.Items[0] as TJSONObject;
        if SpecObj.GetValue('doc_url') <> nil then
        begin
          DocUrl := SpecObj.GetValue('doc_url').Value;

          if MessageDlg(
            'Скачать описание типа из АРШИН?',
            TMsgDlgType.mtConfirmation,
            [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
            0
          ) = mrYes then
          begin
            ForceDirectories(
              ExtractFilePath(ParamStr(0)) + 'Docs\Types\'
            );

            FileName := DevType.ReestrNumber + '.pdf';
            FilePath :=
              ExtractFilePath(ParamStr(0)) +
              'Docs\Types\' + FileName;

            MemoLog.Lines.Add('Скачивание описания типа:');
            MemoLog.Lines.Add(DocUrl);
            MemoLog.Lines.Add('→ ' + FilePath);

            FileStream := TFileStream.Create(FilePath, fmCreate);
            try
              NetHTTPClient1.Get(DocUrl, FileStream);
              DevType.Documentation := FilePath;
            finally
              FileStream.Free;
            end;
          end;
        end;
      end;

    finally
      Json.Free;
    end;

    {=================================================}
    { 3. Обновление формы }
    {=================================================}
    UpdateUIFromType;

    ShowMessage('ГРСИ подтверждено. Данные загружены из АРШИН');

  except
    on E: Exception do
      MemoLog.Lines.Add('ERROR: ' + E.Message);
  end;
end;


procedure TFormTypeEditor.sbRepeatsChange(Sender: TObject);
var
  I: Integer;
  R: Integer;
begin
  if FLoading then
    Exit;

  // значение повторов (не меньше 1)
  R := Round(sbRepeats.Value);
  if R < 1 then
    R := 1;

  // -----------------------------------------------------
  // Сохраняем в локальной модели типа
  // -----------------------------------------------------
  FType.Repeats := R;

  // -----------------------------------------------------
  // Применяем ко всем ЛОКАЛЬНЫМ точкам
  // -----------------------------------------------------
  for I := 0 to FPointsLocal.Count-1 do
  begin
    FPointsLocal[I].RepeatsProtocol := R;
    FPointsLocal[I].Repeats := R;
  end;

  // -----------------------------------------------------
  // Обновляем таблицу точек через единый метод
  // -----------------------------------------------------
  UpdatePointsGrid;

  SetModified;
end;

procedure TFormTypeEditor.GridPointsGetValue(
  Sender: TObject;
  const ACol, ARow: Integer;
  var Value: TValue
);
var
  P: TTypePoint;
  Qmax, Q: Double;
  D: TDiameter;
begin
  {-----------------------------------------------------}
  { Защита }
  {-----------------------------------------------------}
  P := GetPointByVisibleRow(ARow);
  if P = nil then
    Exit;

  {=====================================================}
  { НЕ зависят от диаметра }
  {=====================================================}

  if ACol = StringColumnPointName.Index then
    Value := P.Name

  else if ACol = StringColumnPointFlowRate.Index then
    Value :=  FormatFloat('0.###', P.FlowRate)

  else if ACol = StringColumnPointFlowError.Index then
    Value := FormatAccuracy(P.FlowAccuracy)

  else if ACol = StringColumnPointPres.Index then
    Value := FormatPhys(P.Pressure)

  else if ACol = StringColumnPontTemp.Index then
    Value := FormatPhys(P.Temp)

  else if ACol = StringColumnPointTempError.Index then
  begin
    if (P.Temp = 0) or (P.TempAccuracy = '') or (P.TempAccuracy = '—') then
      Value := '—'
    else
      Value := FormatAccuracy(P.TempAccuracy);
  end

  else if ACol = StringColumnPointError.Index then
    Value := FormatDeviceError(P.Error)

  {=====================================================}
  { INTEGER-КОЛОНКИ }
  {=====================================================}

  else if ACol = IntegerColumnPointRepeatsForm.Index then
  begin
    if P.RepeatsProtocol > 0 then
      Value := P.RepeatsProtocol
    else
      Value := 1;
  end

  else if ACol = IntegerColumnPointRepeats.Index then
  begin
    if P.Repeats > 0 then
      Value := P.Repeats
    else
      Value := 1;
  end

  else if ACol = StringColumnPointStab.Index then
    Value := P.Pause

  {=====================================================}
  { ВСЕГДА отображаются }
  {=====================================================}

  else if ACol = StringColumnPointImp.Index then
  begin
    if P.LimitImp = 0 then
      Value := '—'
    else
      Value := IntToStr(P.LimitImp);
  end

  else if ACol = StringColumnPointTime.Index then
    Value := FormatTime(P.LimitTime)

  {=====================================================}
  { ЗАВИСЯТ ОТ ВЫБРАННОГО ДИАМЕТРА: Q и V }
  {=====================================================}
  else if (ACol = StringColumnPointQ.Index) or
          (ACol = StringColumnPointVolume.Index) then
  begin
    D := GetDiameterByVisibleRow(GridDiameters.Row);
    if D = nil then
    begin
      Value := '—';
      Exit;
    end;

    Qmax := D.Qmax;

    Q := P.FlowRate * Qmax;

    {---------------------------}
    { Q }
    {---------------------------}
    if ACol = StringColumnPointQ.Index then
    begin
      if Q <= 0 then
        Value := '—'
      else
        Value := FormatQorV(Q, P.Error);
    end

    {---------------------------}
    { V }
    {---------------------------}
    else if ACol = StringColumnPointVolume.Index then
    begin
      if P.LimitVolume > 0 then
        Value := FormatQorV(P.LimitVolume, P.Error)

      else if (Q > 0) and (P.LimitTime > 0) then
        Value := FormatQorV(Q * P.LimitTime / 3.6, P.Error)

      else
        Value := '—';
    end;
  end;
end;

procedure TFormTypeEditor.LoadDiameters;
begin
  {----------------------------------}
  { Защита }
  {----------------------------------}
  if (FType = nil) or (DataManager.ActiveTypeRepo = nil) then
    Exit;

  {----------------------------------}
  { Берём диаметрЫ НАПРЯМУЮ из репозитория }
  {----------------------------------}

  FDiametersLocal := FType.Diameters;

  {----------------------------------}
  { Обновляем таблицу }
  {----------------------------------}
  UpdateDiametersGrid;
end;

procedure TFormTypeEditor.LoadPoints;
var
  SrcList: TObjectList<TTypePoint>;
  P, NewP: TTypePoint;
begin
  {----------------------------------}
  { Защита }
  {----------------------------------}
  if (FType = nil) or (DataManager.ActiveTypeRepo = nil) then
    Exit;

  {----------------------------------}
  { Получаем точки из репозитория }
  {----------------------------------}
  FPointsLocal := FType.Points;

  {----------------------------------}
  { Обновляем таблицу точек }
  {----------------------------------}
  UpdatePointsGrid;
end;

function CalcQmaxByDiameter(
  const OldQmax: Double;
  const OldDN, NewDN: Integer
): Double;
begin
  if (OldQmax <= 0) or (OldDN <= 0) or (NewDN <= 0) then
    Exit(OldQmax);

  Result := OldQmax * Sqr(NewDN / OldDN);
end;

function CalcKpByDiameter(
  const OldKp: Double;
  const OldDN, NewDN: Integer
): Double;
begin
  if (OldKp <= 0) or (OldDN <= 0) or (NewDN <= 0) then
    Exit(OldKp);

  Result := OldKp * Sqr(OldDN / NewDN); // ∝ 1 / D²
end;

procedure TFormTypeEditor.UpdateRangeDynamicPromptBySelectedDiameter;
var
  D: TDiameter;
  Qmax, Qmin: Double;
  RangeDynamic: Integer;
begin
  // очищаем prompt по умолчанию
  EditRangeDynamic.TextPrompt := '';

  D := GetDiameterByVisibleRow(GridDiameters.Row);
  if D = nil then
    Exit;

  Qmax := D.Qmax;
  Qmin := D.Qmin;

  // считаем только если оба значения осмысленные
  if (Qmax > 0) and (Qmin > 0) then
  begin
    RangeDynamic := Round(Qmax / Qmin);
    EditRangeDynamic.TextPrompt := '1:' + IntToStr(RangeDynamic);
  end else
    begin
    EditRangeDynamic.TextPrompt := '-';
  end;
end;

procedure TFormTypeEditor.UpdatePointsErrorFromType;
var
  I: Integer;
begin
  // -----------------------------------------------------
  // Применяем базовую погрешность типа ко всем ЛОКАЛЬНЫМ точкам
  // -----------------------------------------------------
  for I := 0 to FPointsLocal.Count-1 do
    FPointsLocal[I].Error := FType.Error;

  // -----------------------------------------------------
  // Обновляем таблицу точек через единый метод
  // -----------------------------------------------------
  UpdatePointsGrid;
end;

procedure TFormTypeEditor.InitCategoryComboEdit;
var
  C: TDeviceCategory;
  TextValue: string;
begin
  if (DataManager.ActiveTypeRepo = nil) or (FType = nil) then
    Exit;

  {----------------------------------}
  { Заполняем список категорий }
  {----------------------------------}
  ceCategory.Items.BeginUpdate;
  try
    ceCategory.Items.Clear;

    for C in FCategoriesLocal do
    begin
      // ⛔ пропускаем служебную категорию
      if C.ID = -1 then
        Continue;

      // ✅ сохраняем ID в Objects
      ceCategory.Items.AddObject(C.Name, TObject(C.ID));
    end;
  finally
    ceCategory.Items.EndUpdate;
  end;

  {----------------------------------}
  { Определяем отображаемый текст }
  {----------------------------------}
  if FType.Category > 0 then
    TextValue :=
      DataManager.ActiveTypeRepo.CategoryToText(
        FType.Category,
        FType.CategoryName
      )
  else if FType.Category = -1 then
    TextValue := FType.CategoryName
  else
    TextValue := '';

  ceCategory.Text := TextValue;
  ceCategory.Hint := TextValue;
end;


procedure TFormTypeEditor.InitLocalData;
begin
  {----------------------------------}
  { Защита }
  {----------------------------------}
  if (FType = nil) or (DataManager.ActiveTypeRepo = nil) then
    Exit;

  {----------------------------------}
  { Локальные диаметры }
  {----------------------------------}
  LoadDiameters;

  {----------------------------------}
  { Локальные точки }
  {----------------------------------}
  LoadPoints;

  {----------------------------------}
  { Категории (если используются в редакторе) }
  {----------------------------------}
  LoadCategories;
end;



procedure TFormTypeEditor.ApplyMeasuredDimension;
var
  Dim: TMeasuredDimension;
begin

      FLoading := True;

    if (FType.MeasuredDimension >= 0) and
       (FType.MeasuredDimension < cbMeasuredDimension.Items.Count) then
      cbMeasuredDimension.ItemIndex := FType.MeasuredDimension
    else
    begin
      cbMeasuredDimension.ItemIndex := -1;
      Exit;
    end;

   Dim := TMeasuredDimension(FType.MeasuredDimension);

   cbMeasuredDimension.Hint := cbMeasuredDimension.Text;


  // ==================================================
  // СБРОС ЗАГОЛОВКОВ
  // ==================================================
  StringColumnDNQmax.Header := '';
  StringColumnDNQmin.Header := '';
  StringColumnDNQF.Header   := '';
  StringColumnDNKp.Header   := '';

  FloatColumnVmax.Header   := '';
  StringColumnVmin.Header  := '';

  StringColumnPointQ.Header      := '';
  StringColumnPointVolume.Header := '';

  // ==================================================
  // КРИТЕРИЙ ОСТАНОВКИ (cbSpillageStop)
  // ==================================================
  cbSpillageStop.Items.BeginUpdate;
  try
    cbSpillageStop.Items.Clear;

    // Импульсы доступны всегда
    cbSpillageStop.Items.Add('Импульсы');

    case Dim of
      mdVolumeFlow,
      mdVolume:
        cbSpillageStop.Items.Add('Объем, л');

      mdMassFlow,
      mdMass:
        cbSpillageStop.Items.Add('Масса, кг');

      mdSpeed:
        cbSpillageStop.Items.Add('Скорость');

      mdHeat:
        cbSpillageStop.Items.Add('Теплота');
    end;

    // Время доступно всегда
    cbSpillageStop.Items.Add('Время, с');
  finally
    cbSpillageStop.Items.EndUpdate;
  end;

  if cbSpillageStop.ItemIndex < 0 then
    cbSpillageStop.ItemIndex := 0;

  // ==================================================
  // ОСНОВНАЯ ЛОГИКА ПО ИЗМЕРЯЕМОЙ ВЕЛИЧИНЕ
  // ==================================================
  case Dim of

    // --------------------------------------------------
    // ОБЪЁМНЫЙ РАСХОД
    // --------------------------------------------------
    mdVolumeFlow:
      begin
        ApplyVolumeMode;
      end;

    // --------------------------------------------------
    // МАССОВЫЙ РАСХОД
    // --------------------------------------------------
    mdMassFlow:
      begin
        ApplyMassMode;
      end;

    // --------------------------------------------------
    // ОБЪЁМ
    // --------------------------------------------------
    mdVolume:
      begin
        ApplyVolumeMode;
      end;

    // --------------------------------------------------
    // МАССА
    // --------------------------------------------------
    mdMass:
      begin
        ApplyMassMode;
      end;

    // --------------------------------------------------
    // СКОРОСТЬ
    // --------------------------------------------------
    mdSpeed:
      begin
        StringColumnPointQ.Header := 'V, м/с';
      end;

    // --------------------------------------------------
    // ТЕПЛОТА
    // --------------------------------------------------
    mdHeat:
      begin
        StringColumnPointQ.Header      := 'Q, Гкал/ч';
        StringColumnPointVolume.Header := 'E, Гкал';
      end;
  end;

  // ==================================================
  // ОБНОВЛЕНИЕ ТАБЛИЦ
  // ==================================================
  UpdateDiametersGrid;
  UpdatePointsGrid;

  FLoading := False;
end;

procedure TFormTypeEditor.ApplyVolumeMode;
begin
  // ===== Диаметры =====
  StringColumnDNQmax.Header := 'Qmax, м³/ч';
  StringColumnDNQmin.Header := 'Qmin, м³/ч';
  StringColumnDNQF.Header   := 'QF, м³/ч';
  StringColumnDNKp.Header   := 'Kp, имп/л';

  FloatColumnVmax.Header   := 'Vmax, л';
  StringColumnVmin.Header  := 'Vmin, л';

  // ===== Поверочные точки =====
  StringColumnPointQ.Header      := 'Q, м³/ч';
  StringColumnPointVolume.Header := 'V, л';

  // ===== Критерий остановки =====
  FillSpillageStopVolume;

  // ===== Представление коэффициента =====
  FillConversionCoefVolume;
end;

procedure TFormTypeEditor.ApplyMassMode;
begin
  // ===== Диаметры =====
  StringColumnDNQmax.Header := 'Qmax, т/ч';
  StringColumnDNQmin.Header := 'Qmin, т/ч';
  StringColumnDNQF.Header   := 'QF, т/ч';
  StringColumnDNKp.Header   := 'Kp, имп/кг';

  FloatColumnVmax.Header   := 'Mmax, кг';
  StringColumnVmin.Header  := 'Mmin, кг';

  // ===== Поверочные точки =====
  StringColumnPointQ.Header      := 'Q, т/ч';
  StringColumnPointVolume.Header := 'M, кг';

  // ===== Критерий остановки =====
  FillSpillageStopMass;

  // ===== Представление коэффициента =====
  FillConversionCoefMass;
end;

procedure TFormTypeEditor.FillSpillageStopVolume;
begin
  cbSpillageStop.Items.BeginUpdate;
  try
    cbSpillageStop.Items.Clear;
    cbSpillageStop.Items.Add('Импульсы');
    cbSpillageStop.Items.Add('Объем, л');
    cbSpillageStop.Items.Add('Время, с');
  finally
    cbSpillageStop.Items.EndUpdate;
  end;

  if cbSpillageStop.ItemIndex < 0 then
    cbSpillageStop.ItemIndex := 0;
end;

procedure TFormTypeEditor.FillSpillageStopMass;
begin
  cbSpillageStop.Items.BeginUpdate;
  try
    cbSpillageStop.Items.Clear;
    cbSpillageStop.Items.Add('Импульсы');
    cbSpillageStop.Items.Add('Масса, кг');
    cbSpillageStop.Items.Add('Время, с');
  finally
    cbSpillageStop.Items.EndUpdate;
  end;

  if cbSpillageStop.ItemIndex < 0 then
    cbSpillageStop.ItemIndex := 0;
end;

procedure TFormTypeEditor.FillConversionCoefVolume;
begin
  cbCoefViewType.Items.BeginUpdate;
  try
    cbCoefViewType.Items.Clear;
    cbCoefViewType.Items.Add('Имп/л');
    cbCoefViewType.Items.Add('л/имп');
  finally
    cbCoefViewType.Items.EndUpdate;
  end;

  if cbCoefViewType.ItemIndex < 0 then
    cbCoefViewType.ItemIndex := 0;
end;

procedure TFormTypeEditor.FillConversionCoefMass;
begin
  cbCoefViewType.Items.BeginUpdate;
  try
    cbCoefViewType.Items.Clear;
    cbCoefViewType.Items.Add('Имп/кг');
    cbCoefViewType.Items.Add('кг/имп');
  finally
    cbCoefViewType.Items.EndUpdate;
  end;

  if cbCoefViewType.ItemIndex < 0 then
    cbCoefViewType.ItemIndex := 0;
end;

procedure TFormTypeEditor.ApplyOutputType;
begin
  // --- выбор вкладки по имени ---
  case FType.OutputType of
    0: tcOutPutType.ActiveTab := tiFrequency;  // Частота
    1: tcOutPutType.ActiveTab := tiImpulse;    // Импульсы
    2: tcOutPutType.ActiveTab := tiVoltage;    // Напряжение
    3: tcOutPutType.ActiveTab := tiCurrent;    // Ток
    4: tcOutPutType.ActiveTab := tiInterface;  // Интерфейс
    5: tcOutPutType.ActiveTab := tiVisual;     // Визуальный
  end;

  // --- столбцы коэффициентов / импульсов ---
  case FType.OutputType of
    0, // Частота
    1: // Импульсы
      begin
        StringColumnDNKp.Visible       := True;
        StringColumnPointImp.Visible   := True;
        StringColumnDNQF.Visible   := True;
      end;
  else
    begin
      StringColumnDNKp.Visible       := False;
      StringColumnPointImp.Visible   := False;
      StringColumnDNQF.Visible   := False;
    end;
  end;
end;


procedure TFormTypeEditor.UpdateCoefEdit;
var
  V: Double;
begin
  V := FType.Coef;

  if V <= 0 then
  begin
    EditCoef.Text := '';
    Exit;
  end;

  case FType.DimensionCoef of
    0:
      begin
        // имп/л или имп/кг — базовое хранение
        EditCoef.Text := FloatToStr(V);
      end;

    1:
      begin
        // л/имп или кг/имп — обратное представление
        EditCoef.Text := FloatToStr(1 / V);
      end;
  end;
end;

function TFormTypeEditor.GetDisplayedCoef: Double;
begin
  Result := 0;

  // базовый коэффициент всегда хранится как имп/л (имп/кг)
  if FType.Coef <= 0 then
    Exit;

  case FType.DimensionCoef of
    0: // имп/л (имп/кг)
      Result := FType.Coef;

    1: // л/имп (кг/имп)
      Result := 1 / FType.Coef;
  else
    Result := FType.Coef;
  end;
end;


procedure TFormTypeEditor.LoadCategories;
var
  C: TDeviceCategory;
begin
  if (DataManager.ActiveTypeRepo = nil) then
    Exit;

  {----------------------------------}
  { Получаем категории из репозитория }
  {----------------------------------}
  if FCategoriesLocal = nil then
    FCategoriesLocal := TObjectList<TDeviceCategory>.Create(False)
  else
    FCategoriesLocal.Clear;

  for C in DataManager.ActiveTypeRepo.Categories do
    FCategoriesLocal.Add(C);

  {----------------------------------}
  { Заполняем ComboBox }
  {----------------------------------}
    InitCategoryComboEdit;


end;


end.
