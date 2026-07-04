unit fuTypeEditor;

interface

uses
  FMX.ComboEdit,
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.EditBox,
  FMX.Effects,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.Menus,
  FMX.Objects,
  FMX.ScrollBox,
  FMX.SpinBox,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Types,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.IOUtils,
  System.JSON,
  System.Math,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.Net.Mime,
  System.Net.URLClient,
  System.NetEncoding,
  System.Rtti,
  System.StrUtils,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FmxHelper,
  uBaseProcedures,
  uClasses,
  uDataManager,
  uDeviceClass,
  uRepositories,
  uProtocols;

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
    LayoutOutputType: TLayout;
    LabelOutputType: TLabel;
    ComboBoxOutputType: TComboBox;
    LayoutMeasuredDimension: TLayout;
    LabelMeasuredDimension: TLabel;
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
    LayoutTemp: TLayout;
    LabelTemp: TLabel;
    EditTemp: TEdit;
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
    StringColumnDNQF: TStringColumn;
    StringColumnDNQmax: TStringColumn;
    StringColumnDNQmin: TStringColumn;
    StringColumnDNQnom: TStringColumn;
    StringColumnDNKp: TStringColumn;
    StringColumnDNQTr: TStringColumn;
    StringColumnDNQ2Tr: TStringColumn;
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
    TabControlMain: TTabControl;
    TabItemDevice: TTabItem;
    TabItemCoefs: TTabItem;
    LayoutUnits: TLayout;
    LabelUnits: TLabel;
    ComboBoxUnits: TComboBox;
    CheckColumnDNEnable: TCheckColumn;
    CheckColumnPointEnable: TCheckColumn;
    Layout12: TLayout;
    Layout14: TLayout;
    Layout48: TLayout;
    LFLowEate: TLabel;
    EditFlowRate: TEdit;
    Layout49: TLayout;
    Label4: TLabel;
    Edit1: TEdit;
    SpeedButton2: TSpeedButton;
    Layout50: TLayout;
    AddFile: TSpeedButton;
    Layout51: TLayout;
    Label7: TLabel;
    Edit2: TEdit;
    SpeedButton4: TSpeedButton;
    Layout52: TLayout;
    Label43: TLabel;
    Edit3: TEdit;
    SpeedButton5: TSpeedButton;
    Layout53: TLayout;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Layout54: TLayout;
    Label44: TLabel;
    procedure GridDiametersGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridPointsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure GridDiametersSelChanged(Sender: TObject);
    procedure EditRangeDynamicExit(Sender: TObject);
    procedure EditFlowRateExit(Sender: TObject);
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
    procedure GridDiametersKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure GridPointsKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure ButtonPointsClearClick(Sender: TObject);
    procedure cbSpillageTypeChange(Sender: TObject);
    procedure cbSpillageStopChange(Sender: TObject);
    procedure sbRepeatsChange(Sender: TObject);
    procedure EditRangeDynamicEnter(Sender: TObject);
    procedure UpdateRangeDynamicPrompt;
    procedure UpdateRangeDynamicPromptBySelectedDiameter;
    procedure UpdateFlowRatePromptBySelectedDiameter;
    procedure UpdateFlowRateFromDiameter(const D: TDiameter);
    function GetDiameterColumnHint(const ACol: Integer): string;
    procedure EditErrorExit(Sender: TObject);
    procedure EditTempEnter(Sender: TObject);
    procedure EditTempExit(Sender: TObject);
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
    procedure ComboBoxUnitsChange(Sender: TObject);
    procedure ComboBoxOutputTypeChange(Sender: TObject);
    procedure cbOutPutType2Change(Sender: TObject);
    procedure cbCoefViewTypeChange(Sender: TObject);
    procedure EditCoefExit(Sender: TObject);
    procedure EditFreqFlowRateExit(Sender: TObject);
    procedure EditFreqFlowRateKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
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
    procedure AddFileClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure cbCurrentRangeChange(Sender: TObject);
    procedure EditCurrentQmaxExit(Sender: TObject);
    procedure EditCurrentQminExit(Sender: TObject);
    procedure GridDiametersCellClick(const Column: TColumn; const Row: Integer);
    procedure GridPointsCellClick(const Column: TColumn; const Row: Integer);
    procedure EditRangeDynamicCanFocus(Sender: TObject; var ACanFocus: Boolean);
    procedure RectGridDiametersHeaderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GridDiametersMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GridPointsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GridDiametersHeaderMenuItemClick(Sender: TObject);
    procedure GridDiametersConvertUnitClick(Sender: TObject);
    procedure GridDiametersMenuCopyClick(Sender: TObject);
    procedure GridDiametersMenuCutClick(Sender: TObject);
    procedure GridDiametersMenuPasteClick(Sender: TObject);
    procedure GridDiametersResize(Sender: TObject);
    procedure UpdateGridDiametersHeaderRect;
    procedure SyncGridDiametersHeaderPopupMenu;
    procedure GridDiametersHeaderClick(Column: TColumn);
    // Сортировка локального списка диаметров по выбранной колонке грида.
    procedure SortGridDiametersByColumn(const ACol: Integer);
    procedure GridPointsHeaderClick(Column: TColumn);
    function TryParseNumericTextForSort(const S: string; out AValue: Double): Boolean;
    // Получение текстового представления значения диаметра для сортировки строковых колонок.
    function DiameterValueByCol(const ADiameter: TDiameter; const ACol: Integer): string;
    // Выбор PDF-файла вручную через диалог.
    function SelectPdfFile(var APdfFilePath: string): Boolean;
    // Извлечение текстового слоя из PDF через pdftotext.exe.
    function ExtractTextLayerFromPdf(const APdfFilePath, AOutputTxtPath: string): Boolean;
    // Отправка текста и JSON-шаблона в DeepSeek.
    function SendTextToDeepSeekTemplate(const AText, ATemplate: string; out AResponse: string): Boolean;
    // Применение JSON-ответа DeepSeek к форме типа прибора.
    function ApplyDeepSeekJsonToType(const AResponse: string): Boolean;
    function GetSelectedAccuracyClass: string;
    function GetSelectedFlowUnit: string;
    function BuildDeepSeekTemplate(const AAccuracyClass, AModification: string): string;

  private
    { Private declarations }

  FTypeID: Integer;

  FModified: Boolean;
  FLoading: Boolean;

  FSelectedDiameter: TDiameter;
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

  FCalibrCoefItemsLocal: TObjectList<TCalibrCoefItem>;
  FGridCoefs: TGrid;
  FButtonCoefAdd: TButton;
  FButtonCoefDelete: TButton;
  FButtonCoefClear: TButton;
  FSkipDiameterDeleteConfirm: Boolean;
  FSkipPointDeleteConfirm: Boolean;
  FilePath: string;
  FArshinRequestInProgress: Boolean;
  FDiameterQ2: TDictionary<Integer, Double>;
  FDiameterQ4: TDictionary<Integer, Double>;

  // Индекс колонки заголовка GridDiameters, по которой нажали ПКМ.
  FGridDiametersHeaderColumnIndex: Integer;
  // Невидимая кликабельная область поверх заголовка GridDiameters.
  FRectGridDiametersHeader: TRectangle;
  // Контекстное меню заголовка GridDiameters для управления видимостью колонок.
  FPopupMenuGridDiametersHeader: TPopupMenu;
  FMenuItemGridDiametersDisplay: TMenuItem;
  FMenuItemGridDiametersConvertUnits: TMenuItem;
  FActionListGridDiameters: TActionList;
  FActionGridDiametersDelete: TAction;
  FActionGridDiametersCopy: TAction;
  FActionGridDiametersCut: TAction;
  FActionGridDiametersPaste: TAction;
  FClipboardDiameter: TDiameter;
  FPopupMenuGridPoints: TPopupMenu;
  FMenuItemGridPointsDisplay: TMenuItem;
  FActionListGridPoints: TActionList;
  FActionGridPointsDelete: TAction;
  FActionGridPointsCopy: TAction;
  FActionGridPointsCut: TAction;
  FActionGridPointsPaste: TAction;
  FClipboardPoint: TTypePoint;
  // Текущая колонка сортировки GridDiameters (-1, если сортировка ещё не выбрана).
  FGridDiametersSortColumnIndex: Integer;
  // Текущее направление сортировки GridDiameters (True = ASC, False = DESC).
  FGridDiametersSortAscending: Boolean;
  FPointsSortColumn: Integer;
  FPointsSortAscending: Boolean;

  function GetQValue(const AMap: TDictionary<Integer, Double>; const ADiameterID: Integer): Double;
  procedure SetQValue(AMap: TDictionary<Integer, Double>; const ADiameterID: Integer; const AValue: Double);
  procedure RecalcQRowFromKnown(const ANewD: TDiameter; const KnownCol: Integer; const KnownValue: Double; const AOldD: TDiameter = nil);
  function FindLayoutEdit(const ALayoutName: string): TEdit;
  procedure SetupFileLayoutsForNewType;
  procedure SetupFileLayoutsForExistingType;
  procedure SelectFileToLayoutEdit(const ALayoutName: string);
  // Проверка наличия локально выбранных файлов реестра в Edit1/Edit2/Edit3.
  function HasLocalReestrFiles: Boolean;
  // Преобразование значения Edit/Hint в полный путь к локальному файлу.
  function ResolveReestrFilePath(const AEdit: TEdit): string;
  // Проверка существования локально выбранных файлов реестра.
  function CheckLocalReestrFiles: Boolean;
  // Обработка локально выбранных файлов без скачивания с АРШИН.
  procedure ProcessLocalReestrFiles;



  procedure SetModified;
  procedure UpdateUIFromType;
  procedure UpdateTypeFromUI;

  //procedure LoadDiametersForType;

  procedure EnsureUniqueDiameterIDs;
  procedure UpdateDiametersGrid;
  procedure UpdatePointsGrid;
  function GetDiameterByVisibleRow(ARow: Integer): TDiameter;
  function GetPointByVisibleRow(ARow: Integer): TTypePoint;


  procedure RecalcPointsBySelectedDiameter;
  procedure UpdatePointsErrorFromType;

  procedure InitLocalData;
  procedure InitCoefsTab;
  procedure UpdateCoefsGrid;
  function GetCoefByVisibleRow(ARow: Integer): TCalibrCoefItem;
  procedure GridCoefsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
  procedure GridCoefsSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
  procedure ButtonCoefAddClick(Sender: TObject);
  procedure ButtonCoefDeleteClick(Sender: TObject);
  procedure ButtonCoefClearClick(Sender: TObject);

   procedure LoadPoints;
  procedure LoadDiameters;
  procedure RecalcDiametersKpByCoef;
  procedure RecalcDiametersKpByFreq;
  procedure UpdateUnitsCombo;
    procedure UpdateUIFreq;
    procedure UpdateUICoef;
    procedure TestGridGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure CreateMenu;
    procedure CreatePointsMenu;
    procedure SyncGridPointsPopupMenu;
    procedure GridPointsHeaderMenuItemClick(Sender: TObject);
    procedure ActionGridDiametersDeleteExecute(Sender: TObject);
    procedure ActionGridDiametersCopyExecute(Sender: TObject);
    procedure ActionGridDiametersCutExecute(Sender: TObject);
    procedure ActionGridDiametersPasteExecute(Sender: TObject);
    procedure ConvertDiameterFlowValuesFromUnit(const AUnitIndex: Integer);
    procedure ActionGridPointsDeleteExecute(Sender: TObject);
    procedure ActionGridPointsCopyExecute(Sender: TObject);
    procedure ActionGridPointsCutExecute(Sender: TObject);
    procedure ActionGridPointsPasteExecute(Sender: TObject);
    procedure AutoHideEmptyDiameterColumns;

  public

     constructor Create(AOwner: TComponent; AType: TDeviceType);
     destructor Destroy; override;

    { Public declarations }
    procedure LoadType(AType: TDeviceType);
    procedure WriteTypeEditActionLog(const AAction: string; AType: TDeviceType; const ADetails: string = '');
    function Modified: Boolean;

    procedure InitCategoryComboEdit;


    // === Measured Dimension ===
  procedure ApplyMeasuredDimension;
  procedure ApplyVolumeMode;
  procedure ApplyMassMode;

  procedure FillSpillageStopVolume;
  procedure FillSpillageStopMass;
  procedure PopulateSpillageStopCombo(const ADim: TMeasuredDimension);
  function GetStopVolumeCaption(const ADim: TMeasuredDimension): string;
  function SpillageStopValueToItemIndex(const AValue: Integer): Integer;
  function SpillageStopItemIndexToValue(const AIndex: Integer): Integer;
  procedure FillConversionCoefVolume;
  procedure FillConversionCoefMass;

  procedure ApplyOutputType;

  procedure UpdateCoefEdit;
  procedure UpdateFreqFlowRateUnitLabel;
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
uses
uAppServices
{$IFDEF MSWINDOWS}
  , Winapi.Windows
  , Winapi.WinInet
{$ENDIF}
  ;
{$R *.fmx}

function IsArshinReachable: Boolean;
{$IFDEF MSWINDOWS}
const
  ARSHIN_URL = 'https://fgis.gost.ru';
  FLAG_ICC_FORCE_CONNECTION = $00000001;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := InternetCheckConnection(PChar(ARSHIN_URL), FLAG_ICC_FORCE_CONNECTION, 0);
{$ELSE}
  Result := True;
{$ENDIF}
end;

function RunProcessAndWait(const AExeFile, AParams: string): Cardinal;
{$IFDEF MSWINDOWS}
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
{$ENDIF}
begin
  Result := Cardinal(-1);
{$IFDEF MSWINDOWS}
  ZeroMemory(@StartInfo, SizeOf(StartInfo));
  ZeroMemory(@ProcInfo, SizeOf(ProcInfo));

  StartInfo.cb := SizeOf(StartInfo);
  CmdLine := '"' + AExeFile + '" ' + AParams;

  if not CreateProcess(
    nil,
    PChar(CmdLine),
    nil,
    nil,
    False,
    CREATE_NO_WINDOW,
    nil,
    nil,
    StartInfo,
    ProcInfo
  ) then
    Exit;

  try
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcInfo.hProcess, Result);
  finally
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end;
{$ENDIF}
end;

procedure PopulateSpillageTypeCombo(ACombo: TComboBox);
var
  SpillageType: ESpillageType;
begin
  if ACombo = nil then
    Exit;

  ACombo.Items.BeginUpdate;
  try
    ACombo.Items.Clear;
    for SpillageType in CSpillageTypeList do
      ACombo.Items.Add(GetSpillageTypeStr(SpillageType));
  finally
    ACombo.Items.EndUpdate;
  end;
end;

function SpillageTypeValueToItemIndex(const AValue: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(CSpillageTypeList) to High(CSpillageTypeList) do
    if Ord(CSpillageTypeList[I]) = AValue then
      Exit(I);
end;

function SpillageTypeItemIndexToValue(const AIndex: Integer): Integer;
begin
  if (AIndex >= Low(CSpillageTypeList)) and (AIndex <= High(CSpillageTypeList)) then
    Result := Ord(CSpillageTypeList[AIndex])
  else
    Result := Ord(spUnknown);
end;

function ResolveProjectDocsFolder: string;
var
  SearchDir: string;
begin
  Result := '';
  SearchDir := TPath.GetFullPath(GetCurrentDir);

  while SearchDir <> '' do
  begin
    if Length(TDirectory.GetFiles(SearchDir, '*.dproj')) > 0 then
      Exit(TPath.Combine(SearchDir, 'docs'));
    SearchDir := TPath.GetDirectoryName(SearchDir);
  end;

  Result := TPath.Combine(TPath.GetFullPath(GetCurrentDir), 'docs');
end;

function SaveDeepSeekJsonToDocs(const ADocumentationPath, AJsonContent: string): string;
var
  DocsDir: string;
  BaseName: string;
begin
  DocsDir := ResolveProjectDocsFolder;
  if not TDirectory.Exists(DocsDir) then
    TDirectory.CreateDirectory(DocsDir);

  BaseName := TPath.GetFileNameWithoutExtension(ADocumentationPath);
  if BaseName = '' then
    BaseName := 'deepseek_result';

  Result := TPath.Combine(DocsDir, BaseName + '_deepseek.json');
  TFile.WriteAllText(Result, AJsonContent, TEncoding.UTF8);
end;

 constructor TFormTypeEditor.Create(AOwner: TComponent; AType: TDeviceType);

 begin
   inherited Create(AOwner);
   FDiameterQ2 := TDictionary<Integer, Double>.Create;
   FDiameterQ4 := TDictionary<Integer, Double>.Create;
   TabItemCoefs.Visible := False;
   OnKeyDown := FormKeyDown;
   GridDiameters.OnKeyDown := GridDiametersKeyDown;
   GridDiameters.OnMouseDown := GridDiametersMouseDown;
   GridPoints.OnKeyDown := GridPointsKeyDown;
   GridPoints.OnMouseDown := GridPointsMouseDown;
   FClipboardDiameter := nil;
   FClipboardPoint := nil;

   FActionListGridDiameters := TActionList.Create(Self);
   FActionGridDiametersDelete := TAction.Create(FActionListGridDiameters);
   FActionGridDiametersDelete.Text := 'Удалить';
   FActionGridDiametersDelete.OnExecute := ActionGridDiametersDeleteExecute;
   FActionGridDiametersDelete.ActionList := FActionListGridDiameters;

   FActionGridDiametersCopy := TAction.Create(FActionListGridDiameters);
   FActionGridDiametersCopy.Text := 'Копировать';
   FActionGridDiametersCopy.OnExecute := ActionGridDiametersCopyExecute;
   FActionGridDiametersCopy.ActionList := FActionListGridDiameters;

   FActionGridDiametersCut := TAction.Create(FActionListGridDiameters);
   FActionGridDiametersCut.Text := 'Вырезать';
   FActionGridDiametersCut.OnExecute := ActionGridDiametersCutExecute;
   FActionGridDiametersCut.ActionList := FActionListGridDiameters;

   FActionGridDiametersPaste := TAction.Create(FActionListGridDiameters);
   FActionGridDiametersPaste.Text := 'Вставить';
   FActionGridDiametersPaste.OnExecute := ActionGridDiametersPasteExecute;
   FActionGridDiametersPaste.ActionList := FActionListGridDiameters;

   FActionListGridPoints := TActionList.Create(Self);
   FActionGridPointsDelete := TAction.Create(FActionListGridPoints);
   FActionGridPointsDelete.Text := 'Удалить';
   FActionGridPointsDelete.OnExecute := ActionGridPointsDeleteExecute;
   FActionGridPointsDelete.ActionList := FActionListGridPoints;
   FActionGridPointsCopy := TAction.Create(FActionListGridPoints);
   FActionGridPointsCopy.Text := 'Копировать';
   FActionGridPointsCopy.OnExecute := ActionGridPointsCopyExecute;
   FActionGridPointsCopy.ActionList := FActionListGridPoints;
   FActionGridPointsCut := TAction.Create(FActionListGridPoints);
   FActionGridPointsCut.Text := 'Вырезать';
   FActionGridPointsCut.OnExecute := ActionGridPointsCutExecute;
   FActionGridPointsCut.ActionList := FActionListGridPoints;
   FActionGridPointsPaste := TAction.Create(FActionListGridPoints);
   FActionGridPointsPaste.Text := 'Вставить';
   FActionGridPointsPaste.OnExecute := ActionGridPointsPasteExecute;
   FActionGridPointsPaste.ActionList := FActionListGridPoints;

   FGridDiametersHeaderColumnIndex := -1;
   // Инициализация состояния сортировки GridDiameters.
   FGridDiametersSortColumnIndex := -1;
   FGridDiametersSortAscending := True;
   FPointsSortColumn := -1;
   FPointsSortAscending := True;

   // Создаем невидимую кликабельную область над заголовком грида для отдельного header-popup.
   FRectGridDiametersHeader := TRectangle.Create(Self);
   FRectGridDiametersHeader.Parent := GridDiameters.Parent;
   FRectGridDiametersHeader.Stored := False;
   FRectGridDiametersHeader.Fill.Kind := TBrushKind.None;
   FRectGridDiametersHeader.Stroke.Kind := TBrushKind.None;
   // Rectangle размещается над визуальным header грида и принимает ПКМ для контекстного меню.
   FRectGridDiametersHeader.HitTest := True;
   FRectGridDiametersHeader.OnMouseDown := RectGridDiametersHeaderMouseDown;
   // Важно: не назначаем обработчик на весь Grid, чтобы сортировка срабатывала
   // только по клику в header-область, а не по клику в строки данных.
   FRectGridDiametersHeader.BringToFront;

   // Создаем popup-меню заголовка; пункты 1..9 управляют Visible соответствующих колонок.
   FPopupMenuGridDiametersHeader := TPopupMenu.Create(Self);
   FPopupMenuGridDiametersHeader.Stored := False;
   CreateMenu;
   CreatePointsMenu;
   ButtonDiameterDelete.Action := FActionGridDiametersDelete;
   ButtonPointDelete.Action := FActionGridPointsDelete;

   GridDiameters.OnResize := GridDiametersResize;

   LoadType(AType);
   // Настройка кнопок работы с файлами по именам компонентов из .fmx.
   if FindComponent('AddFile') is TSpeedButton then
     TSpeedButton(FindComponent('AddFile')).OnClick := AddFileClick;
   if FindComponent('SpeedButton2') is TSpeedButton then
     TSpeedButton(FindComponent('SpeedButton2')).OnClick := SpeedButton2Click;
   if FindComponent('SpeedButton4') is TSpeedButton then
     TSpeedButton(FindComponent('SpeedButton4')).OnClick := SpeedButton4Click;
   if FindComponent('SpeedButton5') is TSpeedButton then
     TSpeedButton(FindComponent('SpeedButton5')).OnClick := SpeedButton5Click;
   UpdateGridDiametersHeaderRect;
 end;



procedure TFormTypeEditor.CreateMenu;
var
  I: Integer;
  MenuItem: TMenuItem;
begin
  while FPopupMenuGridDiametersHeader.ItemsCount > 0 do
    FPopupMenuGridDiametersHeader.Items[0].Free;

  MenuItem := TMenuItem.Create(FPopupMenuGridDiametersHeader);
  MenuItem.Action := FActionGridDiametersDelete;
  MenuItem.Parent := FPopupMenuGridDiametersHeader;

  MenuItem := TMenuItem.Create(FPopupMenuGridDiametersHeader);
  MenuItem.Action := FActionGridDiametersCopy;
  MenuItem.Parent := FPopupMenuGridDiametersHeader;

  MenuItem := TMenuItem.Create(FPopupMenuGridDiametersHeader);
  MenuItem.Action := FActionGridDiametersCut;
  MenuItem.Parent := FPopupMenuGridDiametersHeader;

  MenuItem := TMenuItem.Create(FPopupMenuGridDiametersHeader);
  MenuItem.Action := FActionGridDiametersPaste;
  MenuItem.Parent := FPopupMenuGridDiametersHeader;

  FMenuItemGridDiametersConvertUnits := TMenuItem.Create(FPopupMenuGridDiametersHeader);
  FMenuItemGridDiametersConvertUnits.Text := 'Поменять ед.и.';
  FMenuItemGridDiametersConvertUnits.Parent := FPopupMenuGridDiametersHeader;

  for I := 0 to ComboBoxUnits.Items.Count - 1 do
  begin
    if I = ComboBoxUnits.ItemIndex then
      Continue;

    MenuItem := TMenuItem.Create(FPopupMenuGridDiametersHeader);
    MenuItem.Text := ComboBoxUnits.Items[I];
    MenuItem.Tag := I;
    MenuItem.OnClick := GridDiametersConvertUnitClick;
    MenuItem.Parent := FMenuItemGridDiametersConvertUnits;
  end;

  FMenuItemGridDiametersDisplay := TMenuItem.Create(FPopupMenuGridDiametersHeader);
  FMenuItemGridDiametersDisplay.Text := 'Отображение';
  FMenuItemGridDiametersDisplay.Parent := FPopupMenuGridDiametersHeader;

  for I := 0 to GridDiameters.ColumnCount - 1 do
  begin
    MenuItem := TMenuItem.Create(FPopupMenuGridDiametersHeader);
    if GridDiameters.Columns[I].Header <> '' then
      MenuItem.Text := GridDiameters.Columns[I].Header
    else
      MenuItem.Text := GridDiameters.Columns[I].Name;
    MenuItem.Tag := I;
    MenuItem.AutoCheck := False;
    MenuItem.OnClick := GridDiametersHeaderMenuItemClick;
    MenuItem.Parent := FMenuItemGridDiametersDisplay;
  end;
end;

procedure TFormTypeEditor.CreatePointsMenu;
var
  I: Integer;
  MenuItem: TMenuItem;
begin
  if FPopupMenuGridPoints = nil then
  begin
    FPopupMenuGridPoints := TPopupMenu.Create(Self);
    FPopupMenuGridPoints.Stored := False;
  end;

  while FPopupMenuGridPoints.ItemsCount > 0 do
    FPopupMenuGridPoints.Items[0].Free;

  MenuItem := TMenuItem.Create(FPopupMenuGridPoints);
  MenuItem.Action := FActionGridPointsDelete;
  MenuItem.Parent := FPopupMenuGridPoints;
  MenuItem := TMenuItem.Create(FPopupMenuGridPoints);
  MenuItem.Action := FActionGridPointsCopy;
  MenuItem.Parent := FPopupMenuGridPoints;
  MenuItem := TMenuItem.Create(FPopupMenuGridPoints);
  MenuItem.Action := FActionGridPointsCut;
  MenuItem.Parent := FPopupMenuGridPoints;
  MenuItem := TMenuItem.Create(FPopupMenuGridPoints);
  MenuItem.Action := FActionGridPointsPaste;
  MenuItem.Parent := FPopupMenuGridPoints;

  FMenuItemGridPointsDisplay := TMenuItem.Create(FPopupMenuGridPoints);
  FMenuItemGridPointsDisplay.Text := 'Отображение';
  FMenuItemGridPointsDisplay.Parent := FPopupMenuGridPoints;
  for I := 0 to GridPoints.ColumnCount - 1 do
  begin
    MenuItem := TMenuItem.Create(FPopupMenuGridPoints);
    if GridPoints.Columns[I].Header <> '' then
      MenuItem.Text := GridPoints.Columns[I].Header
    else
      MenuItem.Text := GridPoints.Columns[I].Name;
    MenuItem.Tag := I;
    MenuItem.OnClick := GridPointsHeaderMenuItemClick;
    MenuItem.Parent := FMenuItemGridPointsDisplay;
  end;
end;

procedure TFormTypeEditor.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkEscape then
  begin
    ModalResult := mrOk;
    Key := 0;
    KeyChar := #0;
  end;
end;

destructor TFormTypeEditor.Destroy;
begin
  FreeAndNil(FClipboardDiameter);
  FreeAndNil(FClipboardPoint);
  FDiameterQ2.Free;
  FDiameterQ4.Free;
  inherited;
end;

function TFormTypeEditor.GetQValue(const AMap: TDictionary<Integer, Double>; const ADiameterID: Integer): Double;
begin
  if (AMap = nil) or (not AMap.TryGetValue(ADiameterID, Result)) then
    Result := 0;
end;

procedure TFormTypeEditor.SetQValue(AMap: TDictionary<Integer, Double>; const ADiameterID: Integer; const AValue: Double);
begin
  if AMap = nil then
    Exit;
  AMap.AddOrSetValue(ADiameterID, AValue);
end;

procedure TFormTypeEditor.RecalcQRowFromKnown(const ANewD: TDiameter; const KnownCol: Integer; const KnownValue: Double; const AOldD: TDiameter = nil);
var
  DCoef: TDiameter;
  QmaxForCoef: Double;
  K1, K2,K2tr, Qmax, Qmin, Q2,Q2tr, QOver: Double;
begin
  if (ANewD = nil) or (KnownValue <= 0) then
    Exit;

  DCoef := AOldD;
  if DCoef = nil then
    DCoef := ANewD;

  QmaxForCoef := DCoef.Qmax;
  if (QmaxForCoef <= 0) and (DCoef.Qnom > 0) then
    QmaxForCoef := DCoef.Qmax * 1.25;

  if QmaxForCoef > 0 then
  begin
    K1 := DCoef.Qmin / QmaxForCoef;
    K2 := DCoef.Qtr / QmaxForCoef;
    K2tr := DCoef.Q2tr / QmaxForCoef;
  end;

  if (KnownCol = StringColumnDNQTr.Index) or (KnownCol = StringColumnDNQ2Tr.Index) then
    Qmax := KnownValue / K2
  else if KnownCol = StringColumnDNQmin.Index then
    Qmax := KnownValue / K1
  else if KnownCol = StringColumnDNQmax.Index then
    Qmax := KnownValue
  else if KnownCol = StringColumnDNQnom.Index then
    Qmax := KnownValue * 1.25
  else
    Exit;

  if Qmax <= 0 then
    Exit;

  Q2 := Qmax * K2;
  Q2tr := Qmax * K2tr;
  Qmin := Qmax * K1;
  QOver := Qmax / 1.25;

  if FType.FreqFlowRate > 0 then
    ANewD.QFmax := Qmax * FType.FreqFlowRate
  else
    ANewD.QFmax := Qmax;

  ANewD.Qmax := Qmax;
  ANewD.Qtr := Q2;
  ANewD.Q2tr :=Q2tr;
  ANewD.Qmin := Qmin;
  ANewD.Qnom := QOver;
  SetQValue(FDiameterQ2, ANewD.ID, Q2);
  SetQValue(FDiameterQ4, ANewD.ID, QOver);
end;

procedure TFormTypeEditor.InitCoefsTab;

  function NewCol(const AHeader: string; const AWidth: Single): TStringColumn;
  begin
    Result := TStringColumn.Create(FGridCoefs);
    Result.Header := AHeader;
    Result.Width := AWidth;
    Result.Parent := FGridCoefs;
  end;
var
  LTop: TLayout;
begin
  FCalibrCoefItemsLocal := TObjectList<TCalibrCoefItem>.Create(True);

  LTop := TLayout.Create(TabItemCoefs);
  LTop.Parent := TabItemCoefs;
  LTop.Align := TAlignLayout.Top;
  LTop.Height := 42;
  LTop.Padding.Left := 8;
  LTop.Padding.Right := 8;
  LTop.Padding.Top := 6;
  LTop.Padding.Bottom := 6;

  FButtonCoefAdd := TButton.Create(LTop);
  FButtonCoefAdd.Parent := LTop;
  FButtonCoefAdd.Align := TAlignLayout.Left;
  FButtonCoefAdd.Width := 120;
  FButtonCoefAdd.Text := 'Добавить';
  FButtonCoefAdd.OnClick := ButtonCoefAddClick;

  FButtonCoefDelete := TButton.Create(LTop);
  FButtonCoefDelete.Parent := LTop;
  FButtonCoefDelete.Align := TAlignLayout.Left;
  FButtonCoefDelete.Width := 120;
  FButtonCoefDelete.Text := 'Удалить';
  FButtonCoefDelete.OnClick := ButtonCoefDeleteClick;

  FButtonCoefClear := TButton.Create(LTop);
  FButtonCoefClear.Parent := LTop;
  FButtonCoefClear.Align := TAlignLayout.Left;
  FButtonCoefClear.Width := 140;
  FButtonCoefClear.Text := 'Очистить';
  FButtonCoefClear.OnClick := ButtonCoefClearClick;

  FGridCoefs := TGrid.Create(TabItemCoefs);
  FGridCoefs.Parent := TabItemCoefs;
  FGridCoefs.Align := TAlignLayout.Client;
  FGridCoefs.Options := FGridCoefs.Options + [TGridOption.Editing];
  FGridCoefs.OnGetValue := GridCoefsGetValue;
  FGridCoefs.OnSetValue := GridCoefsSetValue;

  NewCol('Наименование', 170);
  NewCol('Value', 90);
  NewCol('Arg', 90);
  NewCol('QFrom', 90);
  NewCol('QTo', 90);
  NewCol('K', 90);
  NewCol('b', 90);

  UpdateCoefsGrid;
end;

procedure TFormTypeEditor.UpdateUIFromType;
  procedure SetFileEditFromStoredPath(const ALayoutName, AStoredPath: string);
  var
    E: TEdit;
    S: string;
  begin
    E := FindLayoutEdit(ALayoutName);
    if E = nil then
      Exit;
    S := Trim(AStoredPath);
    E.Hint := S; // Храним полный путь в Hint, в Edit показываем только имя файла.
    if S <> '' then
      E.Text := ExtractFileName(S)
    else
      E.Text := '';
  end;
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
    // Файлы типа прибора: загрузка из БД в Edit внутри Layout49/51/52.
    SetFileEditFromStoredPath('Layout49', FType.FileName1);
    SetFileEditFromStoredPath('Layout51', FType.FileName2);
    SetFileEditFromStoredPath('Layout52', FType.FileName3);
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
    PopulateSpillageTypeCombo(cbSpillageType);
    cbSpillageType.ItemIndex := SpillageTypeValueToItemIndex(FType.SpillageType);

    PopulateSpillageStopCombo(TMeasuredDimension(FType.MeasuredDimension));
    cbSpillageStop.ItemIndex := SpillageStopValueToItemIndex(FType.SpillageStop);
  {  if FPointsLocal <> nil then
      for Idx := 0 to FPointsLocal.Count - 1 do
        if (FPointsLocal[Idx] <> nil) and (FPointsLocal[Idx].State <> osDeleted) then
        begin
          cbSpillageStop.ItemIndex := SpillageStopValueToItemIndex(FPointsLocal[Idx].SpillageStop);
          FType.SpillageStop := FPointsLocal[Idx].SpillageStop;
          Break;
        end;     }

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
    // == Температура
    // =====================================================
    EditTemp.Text := FType.Temp;

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

    ApplyOutputType;

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
    // == Коэффициент
    // =====================================================
     UpdateUICoef;

    // =====================================================
    // == Частота
    // =====================================================
     UpdateUIFreq;

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
    // Применяем автоскрытие только после всех UI-обновлений,
    // т.к. часть процедур выше может менять видимость столбцов.
    AutoHideEmptyDiameterColumns;
    // Видимость файловых блоков при открытии существующего типа.
    SetupFileLayoutsForExistingType;

  finally
    FLoading := False;
  end;
end;

procedure TFormTypeEditor.UpdateTypeFromUI;
  function GetStoredPathFromEdit(const ALayoutName: string): string;
  var
    E: TEdit;
  begin
    Result := '';
    E := FindLayoutEdit(ALayoutName);
    if E = nil then
      Exit;
    if Trim(E.Text) = '' then
      Exit(''); // Если Edit очищен, очищаем и сохраненное значение.
    if Trim(E.Hint) <> '' then
      Exit(Trim(E.Hint)); // Предпочитаем полный путь из Hint.
    Result := Trim(E.Text); // Для обратной совместимости, если пути нет.
  end;
begin
  FType.Name              := EditName.Text;
  // Файлы типа прибора: сохранение рядом с EditName.
  FType.FileName1 := GetStoredPathFromEdit('Layout49');
  FType.FileName2 := GetStoredPathFromEdit('Layout51');
  FType.FileName3 := GetStoredPathFromEdit('Layout52');
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
  FType.Temp              := EditTemp.Text;

    if (ceCategory.ItemIndex >= 0) and (ceCategory.ItemIndex < ceCategory.Items.Count) then
  begin
    FType.Category := Integer(NativeInt(ceCategory.Items.Objects[ceCategory.ItemIndex]));
    if (FType.Category = 0) and SameText(Trim(ceCategory.Text), '<не указана>') then
    begin
      FType.Category := -1;
      FType.CategoryName := '';
    end
    else
      FType.CategoryName := '';
  end
  else
  begin
  FType.Category := -1;
  FType.CategoryName := Trim(ceCategory.Text);
  end;


  FType.ProcedureName     := cbProcedure.Text;

  FType.VerificationMethod:= edtDocumentation.Text;
  FType.ReportingForm     := EditReportingForm.Text;
end;


procedure TFormTypeEditor.EnsureUniqueDiameterIDs;
var
  Seen: TDictionary<Integer, Byte>;
  D: TDiameter;
  NextTmpID: Integer;
begin
  if FDiametersLocal = nil then
    Exit;

  Seen := TDictionary<Integer, Byte>.Create;
  try
    NextTmpID := -1;
    for D in FDiametersLocal do
    begin
      if D = nil then
        Continue;

      if (D.ID = 0) or Seen.ContainsKey(D.ID) then
      begin
        while Seen.ContainsKey(NextTmpID) do
          Dec(NextTmpID);
        D.ID := NextTmpID;
        Dec(NextTmpID);
      end;

      Seen.AddOrSetValue(D.ID, 1);
    end;
  finally
    Seen.Free;
  end;
end;

procedure TFormTypeEditor.UpdateDiametersGrid;
var
  D: TDiameter;
  VisibleCount: Integer;
  PrevRow: Integer;
begin
  if (FDiametersLocal = nil) or (GridDiameters = nil) then
    Exit;

  EnsureUniqueDiameterIDs;

  PrevRow := GridDiameters.Row;

  VisibleCount := 0;
  for D in FDiametersLocal do
    if (D <> nil) and (D.State <> osDeleted) then
    begin
     { if D.Qnom <= 0 then
      begin
        if D.Qmax > 0 then
          D.Qnom := D.Qmax / 1.25
        else
          D.Qnom := 0;
      end;
    }
      // Не подставляем Qtr автоматически, если он отсутствует в источнике.
      // Иначе при импорте (например, из DeepSeek) null/0 превращается в вычисленное значение,
      // что визуально выглядит как будто Qt был найден в таблице.

      if (D.State <> osNew) and (D.Qmax > 0) then
      begin
        //D.Qnom := D.Qmax / 1.25;
        RecalcQRowFromKnown(D, StringColumnDNQmax.Index, D.Qmax);
      end;
      Inc(VisibleCount);
    end;

  GridDiameters.BeginUpdate;
  try
    GridDiameters.RowCount := VisibleCount;

    if VisibleCount <= 0 then
      GridDiameters.Row := -1
    else if PrevRow < 0 then
      GridDiameters.Row := 0
    else if PrevRow >= VisibleCount then
      GridDiameters.Row := VisibleCount - 1
    else
      GridDiameters.Row := PrevRow;

    GridDiameters.Selected := GridDiameters.Row;
  finally
    GridDiameters.EndUpdate;
  end;
  GridDiameters.Repaint;

end;

procedure TFormTypeEditor.AutoHideEmptyDiameterColumns;
var
  D: TDiameter;
  VisibleCount: Integer;
  HasName, HasQnom, HasQtr, HasQmax, HasQmin, HasQ2tr, HasKp, HasQf: Boolean;
  function HasNonZeroValue(const AValue: Double): Boolean;
  begin
    Result := not SameValue(AValue, 0, MinDouble);
  end;
begin
  if (FDiametersLocal = nil) or (GridDiameters = nil) then
    Exit;

  VisibleCount := 0;
  HasName := False;
  HasQnom := False;
  HasQtr := False;
  HasQ2tr := False;
  HasKp := False;
  HasQf := False;
  HasQmax := False;
  HasQmin := False;

  for D in FDiametersLocal do
    if (D <> nil) and (D.State <> osDeleted) then
    begin
      Inc(VisibleCount);
      HasName := HasName or ((Trim(D.Name) <> '') and (Trim(D.Name) <> '-'));
      HasQnom := HasQnom or HasNonZeroValue(D.Qnom);
      HasQtr := HasQtr or HasNonZeroValue(D.Qtr);
      HasQ2tr := HasQ2tr or HasNonZeroValue(D.Q2tr);
      HasKp := HasKp or HasNonZeroValue(D.Kp);
      HasQf := HasQf or HasNonZeroValue(D.QFmax);
      HasQmax := HasQmax or HasNonZeroValue(D.Qmax);
      HasQmin := HasQmin or HasNonZeroValue(D.Qmin);
    end;

  if VisibleCount = 0 then
  begin
    HasName := True;
    HasQnom := True;
    HasQtr := True;
    HasQ2tr := True;
    HasKp := True;
    HasQf := True;
    HasQmax := True;
    HasQmin := True;
  end;

  StringColumnDNName.Visible := HasName;
  StringColumnDNQnom.Visible := HasQnom;
  StringColumnDNQTr.Visible := HasQtr;
  StringColumnDNQ2tr.Visible := HasQ2tr;
  StringColumnDNKp.Visible := HasKp;
  StringColumnDNQF.Visible := HasQf;
  StringColumnDNQmin.Visible := HasQmin;
  StringColumnDNQmax.Visible := HasQmax;
  SyncGridDiametersHeaderPopupMenu;
  UpdateGridDiametersHeaderRect;
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

procedure TFormTypeEditor.UpdateCoefsGrid;
begin
  if FGridCoefs = nil then
    Exit;

  FGridCoefs.BeginUpdate;
  try
    FGridCoefs.RowCount := FCalibrCoefItemsLocal.Count;
  finally
    FGridCoefs.EndUpdate;
  end;
end;

function TFormTypeEditor.GetCoefByVisibleRow(ARow: Integer): TCalibrCoefItem;
begin
  Result := nil;
  if (ARow < 0) or (FCalibrCoefItemsLocal = nil) or (ARow >= FCalibrCoefItemsLocal.Count) then
    Exit;
  Result := FCalibrCoefItemsLocal[ARow];
end;



procedure TFormTypeEditor.GridCoefsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  Item: TCalibrCoefItem;
begin
  Item := GetCoefByVisibleRow(ARow);
  if Item = nil then
    Exit;

  case ACol of
    0: Value := Item.Name;
    1: Value := FloatToStr(Item.Value);
    2: Value := FloatToStr(Item.Arg);
    3: Value := FloatToStr(Item.QFrom);
    4: Value := FloatToStr(Item.QTo);
    5: Value := FloatToStr(Item.K);
    6: Value := FloatToStr(Item.b);
  end;
end;
procedure TFormTypeEditor.TestGridGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
begin
  Value := True;
end;
procedure TFormTypeEditor.GridCoefsSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
var
  Item: TCalibrCoefItem;
  S: string;
begin
  Item := GetCoefByVisibleRow(ARow);
  if Item = nil then
    Exit;

  S := Value.ToString;
  case ACol of
    0: Item.Name := S;
    1: Item.Value := StrToFloatDef(S, Item.Value);
    2: Item.Arg := StrToFloatDef(S, Item.Arg);
    3: Item.QFrom := StrToFloatDef(S, Item.QFrom);
    4: Item.QTo := StrToFloatDef(S, Item.QTo);
    5: Item.K := StrToFloatDef(S, Item.K);
    6: Item.b := StrToFloatDef(S, Item.b);
  end;

  SetModified;
end;

procedure TFormTypeEditor.ButtonCoefAddClick(Sender: TObject);
var
  Item: TCalibrCoefItem;
begin
  if FCalibrCoefItemsLocal = nil then
    Exit;

  Item := TCalibrCoefItem.Create;
  Item.OrderNo := FCalibrCoefItemsLocal.Count + 1;
  Item.Name := 'Коэф. ' + IntToStr(Item.OrderNo);
  Item.Value := 1;
  Item.Arg := 0;
  Item.K := 1;
  Item.b := 0;
  Item.Enable := True;
  FCalibrCoefItemsLocal.Add(Item);
  UpdateCoefsGrid;
  if FGridCoefs.RowCount > 0 then
    FGridCoefs.Selected := FGridCoefs.RowCount - 1;
  SetModified;
end;

procedure TFormTypeEditor.ButtonCoefDeleteClick(Sender: TObject);
var
  Row: Integer;
begin
  if (FCalibrCoefItemsLocal = nil) or (FGridCoefs = nil) then
    Exit;
  Row := FGridCoefs.Row;
  if (Row < 0) or (Row >= FCalibrCoefItemsLocal.Count) then
    Exit;

  FCalibrCoefItemsLocal.Delete(Row);
  UpdateCoefsGrid;
  SetModified;
end;

procedure TFormTypeEditor.ButtonCoefClearClick(Sender: TObject);
begin
  if FCalibrCoefItemsLocal = nil then
    Exit;
  FCalibrCoefItemsLocal.Clear;
  UpdateCoefsGrid;
  SetModified;
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


procedure TFormTypeEditor.UpdateGridDiametersHeaderRect;
begin
  if (FRectGridDiametersHeader = nil) or (GridDiameters = nil) then
    Exit;

  // Прозрачный rectangle ставим в координатах родителя грида точно над областью header.
  var GridTopLeft: TPointF;
  var ParentCtrl: TControl;
  if FRectGridDiametersHeader.Parent is TControl then
  begin
    ParentCtrl := TControl(FRectGridDiametersHeader.Parent);
    GridTopLeft := ParentCtrl.AbsoluteToLocal(GridDiameters.LocalToAbsolute(PointF(0, 0)));
  end
  else
    GridTopLeft := PointF(GridDiameters.Position.X, GridDiameters.Position.Y);

  FRectGridDiametersHeader.Position.X := GridTopLeft.X;
  FRectGridDiametersHeader.Position.Y := GridTopLeft.Y;
  FRectGridDiametersHeader.Width := GridDiameters.Width;
  FRectGridDiametersHeader.Height := GridDiameters.RowHeight;
  FRectGridDiametersHeader.Visible := GridDiameters.Visible and (GridDiameters.RowHeight > 0);
  FRectGridDiametersHeader.BringToFront;
end;

procedure TFormTypeEditor.GridDiametersResize(Sender: TObject);
begin
  UpdateGridDiametersHeaderRect;
end;

procedure TFormTypeEditor.SyncGridDiametersHeaderPopupMenu;
var
  I: Integer;
  MenuItem: TMenuItem;
  ColIndex: Integer;
begin
  if (FPopupMenuGridDiametersHeader = nil) or (FMenuItemGridDiametersDisplay = nil) then
    Exit;

  for I := 0 to FMenuItemGridDiametersDisplay.ItemsCount - 1 do
  begin
    if not (FMenuItemGridDiametersDisplay.Items[I] is TMenuItem) then
      Continue;

    MenuItem := TMenuItem(FMenuItemGridDiametersDisplay.Items[I]);
    ColIndex := MenuItem.Tag;

    if (ColIndex >= 0) and (ColIndex < GridDiameters.ColumnCount) then
    begin
      MenuItem.Enabled := True;
      MenuItem.IsChecked := GridDiameters.Columns[ColIndex].Visible;
    end
    else
    begin
      MenuItem.Enabled := False;
      MenuItem.IsChecked := False;
    end;
  end;
end;

procedure TFormTypeEditor.GridDiametersMenuCopyClick(Sender: TObject);
begin
  ActionGridDiametersCopyExecute(Sender);
end;

procedure TFormTypeEditor.ActionGridDiametersDeleteExecute(Sender: TObject);
begin
  ButtonDiameterDeleteClick(ButtonDiameterDelete);
end;

procedure TFormTypeEditor.ActionGridDiametersCopyExecute(Sender: TObject);
var
  D: TDiameter;
begin
  D := GetDiameterByVisibleRow(GridDiameters.Row);
  if D = nil then
    Exit;

  FreeAndNil(FClipboardDiameter);
  FClipboardDiameter := TDiameter.Create(D.DeviceTypeUUID);
  FClipboardDiameter.Assign(D);
end;

procedure TFormTypeEditor.GridDiametersMenuCutClick(Sender: TObject);
begin
  ActionGridDiametersCutExecute(Sender);
end;

procedure TFormTypeEditor.GridDiametersMenuPasteClick(Sender: TObject);
begin
  ActionGridDiametersPasteExecute(Sender);
end;

procedure TFormTypeEditor.ActionGridDiametersCutExecute(Sender: TObject);
var
  PrevSkipConfirm: Boolean;
begin
  ActionGridDiametersCopyExecute(Sender);
  PrevSkipConfirm := FSkipDiameterDeleteConfirm;
  FSkipDiameterDeleteConfirm := True;
  try
    ActionGridDiametersDeleteExecute(Sender);
  finally
    FSkipDiameterDeleteConfirm := PrevSkipConfirm;
  end;
end;

procedure TFormTypeEditor.ActionGridDiametersPasteExecute(Sender: TObject);
var
  NewD: TDiameter;
begin
  if (FType = nil) or (FClipboardDiameter = nil) then
    Exit;

  NewD := FType.AddDiameter;
  if NewD = nil then
    Exit;

  NewD.Assign(FClipboardDiameter);
  NewD.ID := TEntityHelpers<TDiameter>.NextID(FType.Diameters);
  NewD.DeviceTypeID := FType.ID;
  NewD.DeviceTypeUUID := FType.UUID;
  NewD.State := osNew;
  NewD.Enable := False;

  UpdateDiametersGrid;
  if GridDiameters.RowCount > 0 then
    GridDiameters.Selected := GridDiameters.RowCount - 1;
  SetModified;
end;

procedure TFormTypeEditor.GridDiametersMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  P: TPointF;
begin
  if Button <> TMouseButton.mbRight then
    Exit;

  SyncGridDiametersHeaderPopupMenu;
  P := GridDiameters.LocalToScreen(PointF(X, Y));
  FPopupMenuGridDiametersHeader.PopupComponent := GridDiameters;
  FPopupMenuGridDiametersHeader.Popup(P.X, P.Y);
end;

procedure TFormTypeEditor.GridPointsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  P: TPointF;
begin
  if Button <> TMouseButton.mbRight then
    Exit;
  SyncGridPointsPopupMenu;
  P := GridPoints.LocalToScreen(PointF(X, Y));
  FPopupMenuGridPoints.PopupComponent := GridPoints;
  FPopupMenuGridPoints.Popup(P.X, P.Y);
end;

procedure TFormTypeEditor.SyncGridPointsPopupMenu;
var
  I, ColIndex: Integer;
  MenuItem: TMenuItem;
begin
  if (FPopupMenuGridPoints = nil) or (FMenuItemGridPointsDisplay = nil) then
    Exit;
  for I := 0 to FMenuItemGridPointsDisplay.ItemsCount - 1 do
  begin
    MenuItem := TMenuItem(FMenuItemGridPointsDisplay.Items[I]);
    ColIndex := MenuItem.Tag;
    if (ColIndex >= 0) and (ColIndex < GridPoints.ColumnCount) then
      MenuItem.IsChecked := GridPoints.Columns[ColIndex].Visible
    else
      MenuItem.IsChecked := False;
  end;
end;

procedure TFormTypeEditor.GridPointsHeaderMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  Index: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  MenuItem := TMenuItem(Sender);
  Index := MenuItem.Tag;
  if (Index < 0) or (Index >= GridPoints.ColumnCount) then Exit;
  GridPoints.Columns[Index].Visible := not GridPoints.Columns[Index].Visible;
  MenuItem.IsChecked := GridPoints.Columns[Index].Visible;
  GridPoints.Repaint;
end;

procedure TFormTypeEditor.ActionGridPointsDeleteExecute(Sender: TObject);
begin
  ButtonPointDeleteClick(ButtonPointDelete);
end;

procedure TFormTypeEditor.ActionGridPointsCopyExecute(Sender: TObject);
var
  P: TTypePoint;
begin
  P := GetPointByVisibleRow(GridPoints.Row);
  if P = nil then Exit;
  FreeAndNil(FClipboardPoint);
  FClipboardPoint := TTypePoint.Create(FType.UUID);
  FClipboardPoint.Assign(P);
end;

procedure TFormTypeEditor.ActionGridPointsCutExecute(Sender: TObject);
var PrevSkipConfirm: Boolean;
begin
  ActionGridPointsCopyExecute(Sender);
  PrevSkipConfirm := FSkipPointDeleteConfirm;
  FSkipPointDeleteConfirm := True;
  try
    ActionGridPointsDeleteExecute(Sender);
  finally
    FSkipPointDeleteConfirm := PrevSkipConfirm;
  end;
end;

procedure TFormTypeEditor.ActionGridPointsPasteExecute(Sender: TObject);
var
  NewP: TTypePoint;
begin
  if (FType = nil) or (FClipboardPoint = nil) then Exit;
  NewP := FType.AddTypePoint;
  if NewP = nil then Exit;
  NewP.Assign(FClipboardPoint);
  NewP.ID := TEntityHelpers<TTypePoint>.NextID(FType.Points);
  NewP.DeviceTypeID := FType.ID;
  NewP.DeviceTypeUUID := FType.UUID;
  NewP.State := osNew;
  NewP.Enable := False;
  UpdatePointsGrid;
  if GridPoints.RowCount > 0 then
    GridPoints.Selected := GridPoints.RowCount - 1;
  SetModified;
end;

procedure TFormTypeEditor.RectGridDiametersHeaderMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  I: Integer;
  ColLeft: Single;
  ColRight: Single;
begin
  // Для ЛКМ выполняем сортировку по колонке заголовка под курсором.
  if Button = TMouseButton.mbLeft then
  begin
    FGridDiametersHeaderColumnIndex := -1;
    ColLeft := 0;
    for I := 0 to GridDiameters.ColumnCount - 1 do
    begin
      if not GridDiameters.Columns[I].Visible then
        Continue;

      ColRight := ColLeft + GridDiameters.Columns[I].Width;
      if (X >= ColLeft) and (X <= ColRight) then
      begin
        FGridDiametersHeaderColumnIndex := I;
        Break;
      end;
      ColLeft := ColRight;
    end;

    if FGridDiametersHeaderColumnIndex >= 0 then
      SortGridDiametersByColumn(FGridDiametersHeaderColumnIndex);
    Exit;
  end;

  // На header больше не открываем контекстное меню.
  // Контекстное меню доступно только по ПКМ на самом GridDiameters.
end;

function TFormTypeEditor.TryParseNumericTextForSort(const S: string; out AValue: Double): Boolean;
var
  N: Double;
  T: string;
  I, StartPos: Integer;
begin
  T := Trim(S);
  Result := T <> '';
  if not Result then
    Exit;

  N := NormalizeFloatInput(T);
  Result := not SameValue(N, 0, MinDouble) or SameText(T, '0') or
    SameText(T, '0,0') or SameText(T, '0.0');
  if (not Result) then
  begin
    StartPos := 0;
    for I := 1 to Length(T) do
      if CharInSet(T[I], ['0'..'9', '-', '+']) then
      begin
        StartPos := I;
        Break;
      end;

    if StartPos > 0 then
    begin
      N := NormalizeFloatInput(Copy(T, StartPos, MaxInt));
      Result := not SameValue(N, 0, MinDouble) or
        SameText(Trim(Copy(T, StartPos, MaxInt)), '0') or
        SameText(Trim(Copy(T, StartPos, MaxInt)), '0,0') or
        SameText(Trim(Copy(T, StartPos, MaxInt)), '0.0');
    end;
  end;

  if Result then
    AValue := N;
end;

function TFormTypeEditor.DiameterValueByCol(const ADiameter: TDiameter; const ACol: Integer): string;
begin
  // Возвращаем строковое значение колонки для текстовой сортировки.
  Result := '';
  if ADiameter = nil then
    Exit;

  if ACol = StringColumnDNName.Index then
    Result := ADiameter.Name
  else if ACol = IntegerColumnDNSize.Index then
    Result := ADiameter.DN
  else if ACol = StringColumnDNQmin.Index then
    Result := FloatToStr(ADiameter.Qmin)
  else if ACol = StringColumnDNQTr.Index then
    Result := FloatToStr(ADiameter.Qtr)
  else if ACol = StringColumnDNQ2Tr.Index then
    Result := FloatToStr(ADiameter.Q2tr)
  else if ACol = StringColumnDNQnom.Index then
    Result := FloatToStr(ADiameter.Qnom)
  else if ACol = StringColumnDNQmax.Index then
    Result := FloatToStr(ADiameter.Qmax)
  else if ACol = StringColumnDNQF.Index then
    Result := FloatToStr(ADiameter.QFmax)
  else if ACol = StringColumnDNKp.Index then
    Result := FloatToStr(ADiameter.Kp)
  else if ACol = CheckColumnDNEnable.Index then
  begin
    if ADiameter.Enable then
      Result := '1'
    else
      Result := '0';
  end;
end;



procedure TFormTypeEditor.GridDiametersHeaderClick(Column: TColumn);
begin
  if FRectGridDiametersHeader <> nil then
    FRectGridDiametersHeader.HitTest := True;

  if Column = nil then
    Exit;

  // Клик по заголовку делегируем в единый метод сортировки.
  SortGridDiametersByColumn(Column.Index);
end;

procedure TFormTypeEditor.SortGridDiametersByColumn(const ACol: Integer);
begin
  if (FDiametersLocal = nil) or (ACol < 0) then
    Exit;

  // Переключаем направление только при повторном клике по той же колонке.
  if ACol = FGridDiametersSortColumnIndex then
    FGridDiametersSortAscending := not FGridDiametersSortAscending
  else
  begin
    FGridDiametersSortColumnIndex := ACol;
    FGridDiametersSortAscending := True;
  end;

  // Сортируем именно локальную коллекцию FDiametersLocal с учетом типа колонки.
  FDiametersLocal.Sort(TComparer<TDiameter>.Construct(
    function(const Left, Right: TDiameter): Integer
    var
      LStr, RStr: string;
      LNum, RNum: Double;
      LBool, RBool: Integer;
    begin
      if Left = Right then
        Exit(0);
      if Left = nil then
        Exit(1);
      if Right = nil then
        Exit(-1);
      if Left.State = osDeleted then
      begin
        if Right.State = osDeleted then
          Exit(0);
        Exit(1);
      end;
      if Right.State = osDeleted then
        Exit(-1);

      if ACol = CheckColumnDNEnable.Index then
      begin
        if Left.Enable then LBool := 1 else LBool := 0;
        if Right.Enable then RBool := 1 else RBool := 0;
        Result := LBool - RBool;
      end
      else if ACol = StringColumnDNName.Index then
      begin
        // Для DN-имен вида "DN10"/"DN2" сначала сравниваем числовую часть.
        if TryParseNumericTextForSort(Left.Name, LNum) and TryParseNumericTextForSort(Right.Name, RNum) then
          Result := CompareValue(LNum, RNum)
        else
          Result := CompareText(Trim(Left.Name), Trim(Right.Name));
      end
      else if ACol = IntegerColumnDNSize.Index then
      begin
        LNum := NormalizeFloatInput(Left.DN);
        RNum := NormalizeFloatInput(Right.DN);
        Result := CompareValue(LNum, RNum);
      end
      else if ACol = StringColumnDNQmin.Index then
        Result := CompareValue(Left.Qmin, Right.Qmin)
      else if ACol = StringColumnDNQTr.Index then
        Result := CompareValue(Left.Qtr, Right.Qtr)
      else if ACol = StringColumnDNQ2Tr.Index then
        Result := CompareValue(Left.Q2tr, Right.Q2tr)
      else if ACol = StringColumnDNQnom.Index then
        Result := CompareValue(Left.Qnom, Right.Qnom)
      else if ACol = StringColumnDNQmax.Index then
        Result := CompareValue(Left.Qmax, Right.Qmax)
      else if ACol = StringColumnDNQF.Index then
        Result := CompareValue(Left.QFmax, Right.QFmax)
      else if ACol = StringColumnDNKp.Index then
        Result := CompareValue(Left.Kp, Right.Kp)
      else
      begin
        // Прочие колонки сортируем как текст (по отображаемому значению ячейки).
        LStr := Trim(DiameterValueByCol(Left, ACol));
        RStr := Trim(DiameterValueByCol(Right, ACol));
        Result := CompareText(LStr, RStr);
      end;

      if Result = 0 then
      begin
        LStr := Trim(Left.Name);
        RStr := Trim(Right.Name);
        Result := CompareText(LStr, RStr);
      end;

      if not FGridDiametersSortAscending then
        Result := -Result;
    end
  ));

  // После изменения порядка данных перерисовываем грид.
  UpdateDiametersGrid;
end;

procedure TFormTypeEditor.GridPointsHeaderClick(Column: TColumn);
var
  SortColumn: Integer;
begin
  if (Column = nil) or (FPointsLocal = nil) then
    Exit;

  SortColumn := Column.Index;
  if SortColumn = FPointsSortColumn then
    FPointsSortAscending := not FPointsSortAscending
  else
  begin
    FPointsSortColumn := SortColumn;
    FPointsSortAscending := True;
  end;

  FPointsLocal.Sort(TComparer<TTypePoint>.Construct(
    function(const Left, Right: TTypePoint): Integer
    var
      LNum, RNum: Double;
    begin
      if Left = Right then
        Exit(0);
      if Left = nil then
        Exit(1);
      if Right = nil then
        Exit(-1);
      if Left.State = osDeleted then
      begin
        if Right.State = osDeleted then
          Exit(0);
        Exit(1);
      end;
      if Right.State = osDeleted then
        Exit(-1);

      if FPointsSortColumn = StringColumnPointName.Index then
      begin
        if TryParseNumericTextForSort(Left.Name, LNum) and TryParseNumericTextForSort(Right.Name, RNum) then
          Result := CompareValue(LNum, RNum)
        else
          Result := CompareText(Trim(Left.Name), Trim(Right.Name));
      end
      else if FPointsSortColumn = StringColumnPointFlowRate.Index then
        Result := CompareValue(Left.FlowRate, Right.FlowRate)
      else if FPointsSortColumn = StringColumnPointQ.Index then
        Result := CompareValue(Left.FlowRate, Right.FlowRate)
      else if FPointsSortColumn = StringColumnPointVolume.Index then
        Result := CompareValue(Left.LimitVolume, Right.LimitVolume)
      else if FPointsSortColumn = StringColumnPointImp.Index then
        Result := CompareValue(Left.LimitImp, Right.LimitImp)
      else if FPointsSortColumn = StringColumnPointTime.Index then
        Result := CompareValue(Left.LimitTime, Right.LimitTime)
      else if FPointsSortColumn = StringColumnPointError.Index then
        Result := CompareValue(Left.Error, Right.Error)
      else if FPointsSortColumn = StringColumnPointStab.Index then
        Result := CompareValue(Left.Pause, Right.Pause)
      else if FPointsSortColumn = IntegerColumnPointRepeatsForm.Index then
        Result := CompareValue(Left.RepeatsProtocol, Right.RepeatsProtocol)
      else if FPointsSortColumn = IntegerColumnPointRepeats.Index then
        Result := CompareValue(Left.Repeats, Right.Repeats)
      else
        Result := 0;

      if (Result = 0) and (FPointsSortColumn <> 0) then
        Result := CompareText(Trim(Left.Name), Trim(Right.Name));

      if not FPointsSortAscending then
        Result := -Result;
    end
  ));

  UpdatePointsGrid;
end;

procedure TFormTypeEditor.GridDiametersHeaderMenuItemClick(Sender: TObject);
var
  Index: Integer;
  MenuItem: TMenuItem;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MenuItem := TMenuItem(Sender);
  Index := MenuItem.Tag;
  if (Index < 0) or (Index >= GridDiameters.ColumnCount) then
    Exit;

  // Пункты меню управляют Visible колонок, чтобы пользователь мог скрывать/показывать столбцы header.
  GridDiameters.Columns[Index].Visible := not GridDiameters.Columns[Index].Visible;
  MenuItem.IsChecked := GridDiameters.Columns[Index].Visible;

  GridDiameters.Repaint;
  UpdateGridDiametersHeaderRect;
end;


procedure TFormTypeEditor.GridDiametersConvertUnitClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    ConvertDiameterFlowValuesFromUnit(TMenuItem(Sender).Tag);
end;

procedure TFormTypeEditor.ConvertDiameterFlowValuesFromUnit(const AUnitIndex: Integer);
var
  I: Integer;
  OldUnits: Integer;
  OldUnitName: string;
  UnitName: string;
  D: TDiameter;
  HasChecked: Boolean;
  TargetCount: Integer;
  ChangedCount: Integer;
  DisplayQmax: Double;
  DisplayQnom: Double;
  DisplayQmin: Double;
  DisplayQtr: Double;
  DisplayQ2tr: Double;
  DisplayQFmax: Double;
  NewQmax: Double;
  NewQnom: Double;
  NewQmin: Double;
  NewQtr: Double;
  NewQ2tr: Double;
  NewQFmax: Double;
  RowChanged: Boolean;

  function IsTargetDiameter(const ADiameter: TDiameter): Boolean;
  begin
    Result := (ADiameter <> nil) and (ADiameter.State <> osDeleted) and
      ((not HasChecked) or ADiameter.Enable);
  end;

begin
  if (FType = nil) or (FDiametersLocal = nil) or (FDiametersLocal.Count = 0) then
    Exit;

  OldUnits := ComboBoxUnits.ItemIndex;
  if (OldUnits < 0) or (OldUnits >= ComboBoxUnits.Items.Count) then
    Exit;

  if (AUnitIndex < 0) or (AUnitIndex >= ComboBoxUnits.Items.Count) or
    (AUnitIndex = OldUnits) then
    Exit;

  HasChecked := False;
  for I := 0 to FDiametersLocal.Count - 1 do
    if (FDiametersLocal[I] <> nil) and (FDiametersLocal[I].State <> osDeleted) and
      FDiametersLocal[I].Enable then
    begin
      HasChecked := True;
      Break;
    end;

  TargetCount := 0;
  for I := 0 to FDiametersLocal.Count - 1 do
    if IsTargetDiameter(FDiametersLocal[I]) then
      Inc(TargetCount);

  if TargetCount = 0 then
    Exit;

  OldUnitName := ComboBoxUnits.Items[OldUnits];
  UnitName := ComboBoxUnits.Items[AUnitIndex];
  if MessageDlg(
       Format('Пересчитать расходные значения выбранных строк из единиц "%s" в единицы "%s"?', [OldUnitName, UnitName]),
       TMsgDlgType.mtConfirmation,
       [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
       0
     ) <> mrYes then
    Exit;

  ChangedCount := 0;
  for I := 0 to FDiametersLocal.Count - 1 do
  begin
    D := FDiametersLocal[I];
    if not IsTargetDiameter(D) then
      Continue;

    FType.Units := OldUnits;
    FType.SetDimensions;
    DisplayQmax := FType.FromBaseUnits(D.Qmax);
    DisplayQnom := FType.FromBaseUnits(D.Qnom);
    DisplayQmin := FType.FromBaseUnits(D.Qmin);
    DisplayQtr := FType.FromBaseUnits(D.Qtr);
    DisplayQ2tr := FType.FromBaseUnits(D.Q2tr);
    DisplayQFmax := FType.FromBaseUnits(D.QFmax);

    FType.Units := AUnitIndex;
    FType.SetDimensions;
    NewQmax := FType.ToBaseUnits(DisplayQmax);
    NewQnom := FType.ToBaseUnits(DisplayQnom);
    NewQmin := FType.ToBaseUnits(DisplayQmin);
    NewQtr := FType.ToBaseUnits(DisplayQtr);
    NewQ2tr := FType.ToBaseUnits(DisplayQ2tr);
    NewQFmax := FType.ToBaseUnits(DisplayQFmax);

    RowChanged := not SameValue(D.Qmax, NewQmax) or
      not SameValue(D.Qnom, NewQnom) or
      not SameValue(D.Qmin, NewQmin) or
      not SameValue(D.Qtr, NewQtr) or
      not SameValue(D.Q2tr, NewQ2tr) or
      not SameValue(D.QFmax, NewQFmax);

    if RowChanged then
    begin
      D.Qmax := NewQmax;
      D.Qnom := NewQnom;
      D.Qmin := NewQmin;
      D.Qtr := NewQtr;
      D.Q2tr := NewQ2tr;
      D.QFmax := NewQFmax;

      if D.State <> osNew then
        D.State := osModified;
      Inc(ChangedCount);
    end;
  end;

  FType.Units := AUnitIndex;
  FType.SetDimensions;
  ApplyMeasuredDimension;
  GridDiameters.Repaint;
  UpdateFlowRatePromptBySelectedDiameter;
  SetModified;

  if ChangedCount > 0 then
    UpdateDiametersGrid;
end;

procedure TFormTypeEditor.WriteTypeEditActionLog(const AAction: string; AType: TDeviceType; const ADetails: string);
var
  Details: string;
begin
  if (AType = nil) or (ProtocolManager = nil) then Exit;
  Details := Format('Action=%s; Form=%s; Object=%s; UUID=%s; Name=%s; Manufacturer=%s; Category=%s; Modification=%s; Time=%s',
    [AAction, 'fuTypeEditor', 'DeviceType', string(AType.UUID), AType.Name, AType.Manufacturer,
     IntToStr(AType.Category), AType.Modification, FormatDateTime('dd.mm.yyyy hh:nn:ss', Now)]);
  if Trim(ADetails) <> '' then Details := Details + '; ' + ADetails;
  ProtocolManager.AddMessage(pcInfo, psForm, 'DeviceTypeAction', 'Действие с типом прибора', Details);
end;

procedure TFormTypeEditor.LoadType(AType: TDeviceType);
begin
  FLoading := True;
  try
    FSkipDiameterDeleteConfirm := False;
    FSkipPointDeleteConfirm := False;

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
      FType := AppServices.DataManager.ActiveTypeRepo.CreateType(0);
    end;

    InitLocalData;
    UpdateUIFromType;
    // Начальная видимость файловых блоков.
    if AType = nil then
      SetupFileLayoutsForNewType
    else
      SetupFileLayoutsForExistingType;

  finally
    FLoading := False;
  end;
end;

function TFormTypeEditor.FindLayoutEdit(const ALayoutName: string): TEdit;
var
  L: TLayout;
  I: Integer;
begin
  Result := nil;
  if not (FindComponent(ALayoutName) is TLayout) then
    Exit;
  L := TLayout(FindComponent(ALayoutName));
  for I := 0 to L.ChildrenCount - 1 do
    if L.Children[I] is TEdit then
      Exit(TEdit(L.Children[I]));
end;

procedure TFormTypeEditor.SetupFileLayoutsForNewType;
begin
  // Новый тип прибора: показываем только первый файловый блок.
  if FindComponent('Layout49') is TLayout then TLayout(FindComponent('Layout49')).Visible := True;
  if FindComponent('Layout51') is TLayout then TLayout(FindComponent('Layout51')).Visible := False;
  if FindComponent('Layout52') is TLayout then TLayout(FindComponent('Layout52')).Visible := False;
end;

procedure TFormTypeEditor.SetupFileLayoutsForExistingType;
var
  E1, E2: TEdit;
begin
  // Существующий тип: показываем следующий блок только если заполнен предыдущий.
  E1 := FindLayoutEdit('Layout49');
  E2 := FindLayoutEdit('Layout51');
  if FindComponent('Layout49') is TLayout then TLayout(FindComponent('Layout49')).Visible := True;
  if (FindComponent('Layout51') is TLayout) and (E1 <> nil) then
    TLayout(FindComponent('Layout51')).Visible := Trim(E1.Text) <> '';
  if (FindComponent('Layout52') is TLayout) and (E2 <> nil) then
    TLayout(FindComponent('Layout52')).Visible := Trim(E2.Text) <> '';
end;

procedure TFormTypeEditor.AddFileClick(Sender: TObject);
begin

   if (Edit1.text <> '') and (Edit2.text <> '') then
    Layout52.Visible := not(Layout52.Visible)
   else  if (Edit1.text <> '') and (Edit2.text = '') then
    begin
      Layout52.Visible :=false;
     Layout51.Visible := not(Layout51.Visible);
    end;






end;

procedure TFormTypeEditor.SelectFileToLayoutEdit(const ALayoutName: string);
var
  Dlg: TOpenDialog;
  E: TEdit;
begin
  // Выбор файла и сохранение только имени файла (без пути).
  E := FindLayoutEdit(ALayoutName);
  if E = nil then Exit;
  Dlg := TOpenDialog.Create(nil);
  try
    if Dlg.Execute then
    begin
      E.Hint := Dlg.FileName; // Сохраняем полный путь в Hint.
      E.Text := ExtractFileName(Dlg.FileName); // В Edit показываем только имя.
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TFormTypeEditor.SpeedButton2Click(Sender: TObject);
begin
  // Кнопка первого файлового блока.
  SelectFileToLayoutEdit('Layout49');
end;

procedure TFormTypeEditor.SpeedButton4Click(Sender: TObject);
begin
  // Кнопка второго файлового блока.
  SelectFileToLayoutEdit('Layout51');
end;

procedure TFormTypeEditor.SpeedButton5Click(Sender: TObject);
begin
  // Кнопка третьего файлового блока.
  SelectFileToLayoutEdit('Layout52');
end;

 procedure TFormTypeEditor.SetModified;
begin
  if FLoading then Exit;
  FModified := True;
  FType.State :=  osModified;

    end;

function TFormTypeEditor.Modified: Boolean;
begin
  Result := FModified;
end;

procedure TFormTypeEditor.btnCancelClick(Sender: TObject);
begin
  WriteTypeEditActionLog('Редактирование типа прибора отменено', FType);
  ModalResult := mrCancel;
end;


function TFormTypeEditor.SelectPdfFile(var APdfFilePath: string): Boolean;
var
  OpenDialog: TOpenDialog;
begin
  Result := False;
  OpenDialog := TOpenDialog.Create(Self);
  try
    OpenDialog.Filter := 'PDF files (*.pdf)|*.pdf';
    OpenDialog.DefaultExt := 'pdf';
    OpenDialog.Options := [TOpenOption.ofFileMustExist];

    if OpenDialog.Execute then
    begin
      APdfFilePath := OpenDialog.FileName;
      Result := True;
    end;
  finally
    OpenDialog.Free;
  end;
end;

function TFormTypeEditor.ExtractTextLayerFromPdf(const APdfFilePath,
  AOutputTxtPath: string): Boolean;
var
  PdfToTextPath: string;
  Params: string;
  ExitCode: Cardinal;
begin
  Result := False;

  // Проверяем, что PDF-файл существует.
  if not FileExists(APdfFilePath) then
  begin
    ShowMessage('PDF-файл не найден: ' + ExtractFileName(APdfFilePath));
    Exit;
  end;

  // Проверяем, что выбран именно PDF-файл.
  if not SameText(ExtractFileExt(APdfFilePath), '.pdf') then
  begin
    ShowMessage('Выбранный файл не является PDF: ' + ExtractFileName(APdfFilePath));
    Exit;
  end;

  // Ищем pdftotext.exe рядом с программой.
  PdfToTextPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'pdftotext.exe');
  if not FileExists(PdfToTextPath) then
  begin
    ShowMessage('Не найден pdftotext.exe рядом с программой');
    Exit;
  end;

  // Запускаем pdftotext.exe для извлечения текста в UTF-8.
  Params := '-layout -enc UTF-8 ' +
    '"' + APdfFilePath + '" ' +
    '"' + AOutputTxtPath + '"';

  ExitCode := RunProcessAndWait(PdfToTextPath, Params);
  if ExitCode <> 0 then
  begin
    ShowMessage('Ошибка извлечения текста из PDF. Файл: ' + ExtractFileName(APdfFilePath) +
      '. Код: ' + ExitCode.ToString);
    Exit;
  end;

  // Проверяем, что файл результата создан.
  if not FileExists(AOutputTxtPath) then
  begin
    ShowMessage('Файл результата не был создан: ' + ExtractFileName(AOutputTxtPath));
    Exit;
  end;

  // Проверяем, что текстовый слой действительно найден.
  if Trim(TFile.ReadAllText(AOutputTxtPath, TEncoding.UTF8)) = '' then
  begin
    ShowMessage('В PDF не найден текстовый слой: ' + ExtractFileName(APdfFilePath) +
      '. Для такого файла нужен OCR.');
    Exit;
  end;

  Result := True;
end;

function TFormTypeEditor.SendTextToDeepSeekTemplate(const AText, ATemplate: string;
  out AResponse: string): Boolean;
var
  Http: TNetHTTPClient;
  ReqBody: TStringStream;
  Resp: IHTTPResponse;
  JsonReq, MsgSys, MsgUser: TJSONObject;
  Messages: TJSONArray;
  ApiKey: string;
  LimitedText: string;
  ApiJson: TJSONObject;
  ErrorObj: TJSONObject;
  ErrorCode: string;
  ErrorMessage: string;
  Choices: TJSONArray;
  ChoiceObj, MessageObj: TJSONObject;
  ContentValue: TJSONValue;
const
  MAX_TEXT_LENGTH = 50000;
begin
  Result := False;
  AResponse := '';
  ApiKey := 'sk-c1757a521c694238b64baf78a707c86b';
  if Length(AText) > MAX_TEXT_LENGTH then
    LimitedText := Copy(AText, 1, MAX_TEXT_LENGTH)
  else
    LimitedText := AText;

  JsonReq := TJSONObject.Create;
  Messages := TJSONArray.Create;
  MsgSys := TJSONObject.Create;
  MsgUser := TJSONObject.Create;
  ReqBody := nil;
  Http := TNetHTTPClient.Create(nil);
  try
    MsgSys.AddPair('role', 'system');
    MsgSys.AddPair('content', 'Ты инженер-метролог. Заполни шаблон JSON на основе текста.');

    MsgUser.AddPair('role', 'user');
    MsgUser.AddPair('content',
      'Заполни JSON по данным из переданного текста или PDF.' + sLineBreak +
      'Верни только JSON без пояснений.' + sLineBreak +
      'Не добавляй markdown.' + sLineBreak +
      'Не добавляй ```json.' + sLineBreak +
      'Если данных нет — оставь null.' + sLineBreak +
      'Числа возвращай без единиц измерения.' + sLineBreak +
      'Даты возвращай в формате DD.MM.YYYY.' + sLineBreak +
      'Для поля device_type.general_info.manufacturer указывай только краткое название изготовителя без организационно-правовой формы и без скобок и кавычек (например: ВТК Прибор, а не "Общество с ограниченной ответственностью «ВТК Прибор» (ООО «ВТК Прибор»)").' + sLineBreak +
      'Верни ТОЛЬКО объект из шаблона output (без оберток).' + sLineBreak +
      'Класс точности бери из поля device_type.general_info.accuracy_class.' + sLineBreak +
      'Если класс не определен — используй уже переданный класс из шаблона.' + sLineBreak +
      'Если таблицы различаются не по классам точности, а по модификациям, то при переданной модификации ищи и выбирай таблицу по этой модификации (если такая таблица есть).' + sLineBreak +
      'Для base_error верни минимальную погрешность в % для выбранного класса.' + sLineBreak +
      sLineBreak +
      '=== ГЛАВНОЕ ПРАВИЛО: НЕ ПРИВЯЗЫВАЙСЯ К БУКВАМ ===' + sLineBreak +
      'Не ищи конкретно Q1, Q2, Q3, Q4, Qнаим, Qt, Qнаиб.' + sLineBreak +
      'Разные документы используют разные обозначения.' + sLineBreak +
      'Определяй смысл столбца ПО ЗАГОЛОВКУ или ПРИМЕЧАНИЮ.' + sLineBreak +
      sLineBreak +
      '=== СОПОСТАВЛЕНИЕ ЗАГОЛОВКОВ СТОЛБЦОВ С ПОЛЯМИ JSON ===' + sLineBreak +
      'минимальный/наименьший/Qmin/Q1 -> qmin_l_s' + sLineBreak +
      'переходный/Qtr/Qt/Q2 -> qtr_l_s (первый переходный)' + sLineBreak +
      'второй переходный/Q2t -> q2tr_l_s (если есть, иначе null)' + sLineBreak +
      'номинальный/Qnom/Q3 -> qnom_l_s' + sLineBreak +
      'максимальный/наибольший/перегрузочный/Qmax/Q4 -> qmax_l_s' + sLineBreak +
      sLineBreak +
      'Если столбец не подписан — ищи описание в тексте НАД или ПОД таблицей.' + sLineBreak +
      'Если в таблице нет какого-то из этих столбцов — оставь соответствующее поле null.' + sLineBreak +
      sLineBreak +
      '=== ОПРЕДЕЛЕНИЕ ТАБЛИЦЫ (ЕСЛИ ИХ НЕСКОЛЬКО) ===' + sLineBreak +
      '1. Посмотри, как в тексте называются РАЗНЫЕ ТАБЛИЦЫ.' + sLineBreak +
      '2. Если в шаблоне уже передана modification (например, ПТ) — сначала выбери таблицу именно для этой modification.' + sLineBreak +
      '3. Если есть поле "модификация" (ОП, ПТ, РС, К, СВ, М) — запиши в device_type.general_info.modification и выбери нужную таблицу.' + sLineBreak +
      '4. Если есть "класс точности" (A, B, C, 1, 2) — запиши в accuracy_class и выбери таблицу по классу.' + sLineBreak +
      '5. Если таблицы подписаны как "модификация ОП" и "модификация ПТ" — это НЕ классы точности. Они идут в modification, accuracy_class = null.' + sLineBreak +
      '6. Если не понятно, какую таблицу выбрать — бери первую полную и укажи в raw_notes.' + sLineBreak +
      '7. Для base_error возьми погрешность из той же таблицы или из текста рядом.' + sLineBreak +
      sLineBreak +
      '=== ВЫБОР СТРОКИ ДЛЯ ОДНОГО DN (ЕСЛИ ИХ НЕСКОЛЬКО) ===' + sLineBreak +
      '1. Если для одного DN есть несколько строк — выбери строку с САМЫМ БОЛЬШИМ qmax_l_s.' + sLineBreak +
      '2. Если qmax_l_s одинаковый — выбери строку с самым большим qnom_l_s (если он есть).' + sLineBreak +
      '3. Все поля (qmin, qtr, q2tr, qnom, qmax) бери ИЗ ОДНОЙ выбранной строки.' + sLineBreak +
      '4. Если для DN только одна строка — бери её.' + sLineBreak +
      sLineBreak +
      '=== ДОПОЛНИТЕЛЬНЫЕ УКАЗАНИЯ: ===' + sLineBreak +
      'Если есть таблицы диаметров или поверочных точек — заполни массивы.' + sLineBreak +
      'Если DN указан не в первом столбце — ищи ближайший DN сверху или слева.' + sLineBreak +
      'Значения расходов верни в единицах, указанных в таблице или в примечании к ней.' + sLineBreak +
      'Единицу измерения запиши в device_type.signal.measurement_unit.' + sLineBreak +
      'Если в таблице нет столбца "номинальный расход" (Q3) — qnom_l_s = null.' + sLineBreak +
      'Если в таблице нет столбца "второй переходный" (Q2t) — q2tr_l_s = null.' + sLineBreak +
      sLineBreak +
      '=== ЧТО ЗАПИСАТЬ В deepseek_result.raw_notes ===' + sLineBreak +
      '1. Какую таблицу выбрал (по какому признаку: модификация/класс/первая попавшаяся).' + sLineBreak +
      '2. Какие столбцы нашёл и как сопоставил с полями JSON.' + sLineBreak +
      '3. Если какие-то поля остались null — объясни почему.' + sLineBreak +
      'Структуру JSON не менять.' + sLineBreak + sLineBreak +
      'Шаблон:' + sLineBreak + ATemplate + sLineBreak + sLineBreak +
      'Текст:' + sLineBreak + LimitedText
    );
    Messages.Add(MsgSys);
    Messages.Add(MsgUser);
    JsonReq.AddPair('model', 'deepseek-chat');
    JsonReq.AddPair('messages', Messages);
    JsonReq.AddPair('temperature', TJSONNumber.Create(0));
    JsonReq.AddPair('stream', TJSONBool.Create(False));
    ReqBody := TStringStream.Create(JsonReq.ToJSON, TEncoding.UTF8);

    Http.CustomHeaders['Authorization'] := 'Bearer ' + ApiKey;
    Http.CustomHeaders['Content-Type'] := 'application/json';
    Resp := Http.Post('https://api.deepseek.com/chat/completions', ReqBody);
    AResponse := Resp.ContentAsString(TEncoding.UTF8);
    if Resp.StatusCode <> 200 then
    begin
      ApiJson := TJSONObject.ParseJSONValue(AResponse) as TJSONObject;
      try
        if ApiJson <> nil then
        begin
          ErrorObj := ApiJson.GetValue('error') as TJSONObject;
          if ErrorObj <> nil then
          begin
            ErrorCode := Trim(ErrorObj.GetValue<string>('code', ''));
            ErrorMessage := ErrorObj.GetValue<string>('message', '');
            if SameText(ErrorCode, '1') then
              ShowMessage('Ошибка DeepSeek (код 1): не удалось обработать запрос. ' +
                'Проверьте корректность исходного текста/файла и повторите попытку.')
            else if SameText(Trim(ErrorMessage), 'Insufficient Balance') then
              ShowMessage('Ошибка DeepSeek: недостаточно баланса на аккаунте API')
            else if Trim(ErrorMessage) <> '' then
              ShowMessage('Ошибка DeepSeek: ' + ErrorMessage)
            else
              ShowMessage('Ошибка DeepSeek. Код HTTP: ' + Resp.StatusCode.ToString);
          end
          else
            ShowMessage('Ошибка DeepSeek. Код HTTP: ' + Resp.StatusCode.ToString);
        end
        else
          ShowMessage('Ошибка DeepSeek. Код HTTP: ' + Resp.StatusCode.ToString);
      finally
        ApiJson.Free;
      end;
      Exit;
    end;

    ApiJson := TJSONObject.ParseJSONValue(AResponse) as TJSONObject;
    try
      if ApiJson = nil then
        Exit;
      Choices := ApiJson.GetValue('choices') as TJSONArray;
      if (Choices = nil) or (Choices.Count = 0) then
        Exit;
      ChoiceObj := Choices.Items[0] as TJSONObject;
      if ChoiceObj = nil then
        Exit;
      MessageObj := ChoiceObj.GetValue('message') as TJSONObject;
      if MessageObj = nil then
        Exit;
      ContentValue := MessageObj.GetValue('content');
      if ContentValue = nil then
        Exit;

      AResponse := Trim(ContentValue.Value);
      Result := AResponse <> '';
    finally
      ApiJson.Free;
    end;
  finally
    Http.Free;
    ReqBody.Free;
    JsonReq.Free;
  end;
end;

function TFormTypeEditor.GetSelectedAccuracyClass: string;
var
  S: string;
  P: Integer;
begin
  S := Trim(FType.AccuracyClass);
  P := Pos(',', S);
  if P > 0 then
    S := Trim(Copy(S, 1, P - 1));
  if S = '' then
    S := 'A';
  Result := S;
end;

function TFormTypeEditor.GetSelectedFlowUnit: string;
var
  S: string;
begin
  S := Trim(ComboBoxUnits.Text);
  if S = '' then
    S := 'л/с';
  Result := S;
end;

function TFormTypeEditor.BuildDeepSeekTemplate(const AAccuracyClass, AModification: string): string;
var
  ModificationJsonValue: string;
begin
  if Trim(AModification) = '' then
    ModificationJsonValue := 'null'
  else
    ModificationJsonValue := '"' + StringReplace(Trim(AModification), '"', '\"', [rfReplaceAll]) + '"';

  Result :=
    '{' + sLineBreak +
    '  "device_type": {' + sLineBreak +
    '    "general_info": {' + sLineBreak +
    '      "name": null,' + sLineBreak +
    '      "category": null,' + sLineBreak +
    '      "manufacturer": null,' + sLineBreak +
    '      "modification": ' + ModificationJsonValue + ',' + sLineBreak +
    '      "procedure": null,' + sLineBreak +
    '      "grsi_number": null,' + sLineBreak +
    '      "valid_from": null,' + sLineBreak +
    '      "valid_to": null,' + sLineBreak +
    '      "mpi": null,' + sLineBreak +
    '      "verification_method": null,' + sLineBreak +
    '      "accuracy_class": "' + StringReplace(AAccuracyClass, '"', '\"', [rfReplaceAll]) + '",' + sLineBreak +
    '      "base_error": null,' + sLineBreak +
    '      "report_form_file": null' + sLineBreak +
    '    },' + sLineBreak +
    '    "signal": {' + sLineBreak +
    '      "measured_value": null,' + sLineBreak +
    '      "measurement_unit": "' + StringReplace(GetSelectedFlowUnit, '"', '\"', [rfReplaceAll]) + '",' + sLineBreak +
    '      "signal_type": null' + sLineBreak +
    '    },' + sLineBreak +
    '    "pulses": {' + sLineBreak +
    '      "output_type": null,' + sLineBreak +
    '      "representation": null,' + sLineBreak +
    '      "kp_qmax": null' + sLineBreak +
    '    }' + sLineBreak +
    '  },' + sLineBreak +
    '  "diameters": [' + sLineBreak +
    '    {' + sLineBreak +
    '      "enabled": true,' + sLineBreak +
    '      "name": null,' + sLineBreak +
    '      "dn_mm": null,' + sLineBreak +
    '      "qmax_l_s": null,' + sLineBreak +
    '      "qnom_l_s": null,' + sLineBreak +
    '      "qtr_l_s": null,' + sLineBreak +
    '      "q2tr_l_s": null,' + sLineBreak +
    '      "qmin_l_s": null,' + sLineBreak +
    '      "kp_imp_l": null,' + sLineBreak +
    '      "qf_l_s": null' + sLineBreak +
    '    }' + sLineBreak +
    '  ],' + sLineBreak +
    '  "verification_points": [' + sLineBreak +
    '    {' + sLineBreak +
    '      "enabled": true,' + sLineBreak +
    '      "name": null,' + sLineBreak +
    '      "q_qmax": null,' + sLineBreak +
    '      "q_l_s": null,' + sLineBreak +
    '      "volume_l": null,' + sLineBreak +
    '      "impulses_count": null,' + sLineBreak +
    '      "time_s": null,' + sLineBreak +
    '      "error_percent": null,' + sLineBreak +
    '      "expanded_uncertainty_percent": null,' + sLineBreak +
    '      "stabilization_time_s": null,' + sLineBreak +
    '      "repeat_count": null,' + sLineBreak +
    '      "measurement_series_count": null,' + sLineBreak +
    '      "pressure": null' + sLineBreak +
    '    }' + sLineBreak +
    '  ],' + sLineBreak +
    '  "calculation_parameters": {' + sLineBreak +
    '    "dynamic_range": null,' + sLineBreak +
    '    "flow_velocity_qmax_m_s": null' + sLineBreak +
    '  },' + sLineBreak +
    '  "deepseek_result": {' + sLineBreak +
    '    "status": null,' + sLineBreak +
    '    "warnings": [],' + sLineBreak +
    '    "missing_fields": [],' + sLineBreak +
    '    "raw_notes": null' + sLineBreak +
    '  }' + sLineBreak +
    '}';
end;

function TFormTypeEditor.ApplyDeepSeekJsonToType(const AResponse: string): Boolean;
var
  Root, DeviceTypeObj, GeneralInfoObj: TJSONObject;
  DiametersArr, PointsArr: TJSONArray;
  DObj, PObj: TJSONObject;
  D: TDiameter;
  P: TTypePoint;
  I, ExistingIdx: Integer;
  JsonVal: TJSONValue;
  function IsFlowUnitM3h(const AUnit: string): Boolean;
  var
    U: string;
  begin
    U := LowerCase(Trim(AUnit));
    Result := (Pos('м3/ч', U) > 0) or (Pos('m3/h', U) > 0);
  end;

  function ExtractFirstFloat(const S: string; out AValue: Double): Boolean;
  var
    I, StartPos: Integer;
    Buf, NumStr: string;
    FS: TFormatSettings;
  begin
    Result := False;
    AValue := 0;
    Buf := Trim(S);
    if Buf = '' then
      Exit;

    FS := TFormatSettings.Invariant;
    if TryStrToFloat(StringReplace(Buf, ',', '.', [rfReplaceAll]), AValue, FS) then
      Exit(True);

    StartPos := 0;
    for I := 1 to Length(Buf) do
      if CharInSet(Buf[I], ['0'..'9', '-', '+']) then
      begin
        StartPos := I;
        Break;
      end;
    if StartPos = 0 then
      Exit;

    NumStr := '';
    for I := StartPos to Length(Buf) do
    begin
      if CharInSet(Buf[I], ['0'..'9', '.', ',', '-', '+', 'e', 'E']) then
        NumStr := NumStr + Buf[I]
      else
        Break;
    end;
    NumStr := StringReplace(NumStr, ',', '.', [rfReplaceAll]);
    Result := TryStrToFloat(NumStr, AValue, FS);
  end;

  function GetJsonDoubleDef(const AObj: TJSONObject; const AName: string; const ADefault: Double): Double;
  var
    V: TJSONValue;
    Parsed: Double;
  begin
    Result := ADefault;
    if AObj = nil then
      Exit;
    V := AObj.GetValue(AName);
    if V = nil then
      Exit;
    if V is TJSONNumber then
      Exit(TJSONNumber(V).AsDouble);
    if (V is TJSONString) and ExtractFirstFloat(TJSONString(V).Value, Parsed) then
      Exit(Parsed);
  end;
  function ExtractMinFloatFromText(const S: string; out AValue: Double): Boolean;
  var
    I, J: Integer;
    Token: string;
    FS: TFormatSettings;
    V: Double;
    HasVal: Boolean;
  begin
    Result := False;
    AValue := 0;
    FS := TFormatSettings.Invariant;
    HasVal := False;
    I := 1;
    while I <= Length(S) do
    begin
      if CharInSet(S[I], ['0'..'9', '-', '+']) then
      begin
        J := I;
        while (J <= Length(S)) and CharInSet(S[J], ['0'..'9', '.', ',', '-', '+']) do
          Inc(J);
        Token := StringReplace(Copy(S, I, J - I), ',', '.', [rfReplaceAll]);
        if TryStrToFloat(Token, V, FS) then
        begin
          if (not HasVal) or (V < AValue) then
            AValue := V;
          HasVal := True;
        end;
        I := J;
      end
      else
        Inc(I);
    end;
    Result := HasVal;
  end;

  function ExtractMaxFloatFromText(const S: string; out AValue: Double): Boolean;
  var
    I, J: Integer;
    Token: string;
    FS: TFormatSettings;
    V: Double;
    HasVal: Boolean;
  begin
    Result := False;
    AValue := 0;
    FS := TFormatSettings.Invariant;
    HasVal := False;
    I := 1;
    while I <= Length(S) do
    begin
      if CharInSet(S[I], ['0'..'9', '-', '+']) then
      begin
        J := I;
        while (J <= Length(S)) and CharInSet(S[J], ['0'..'9', '.', ',', '-', '+']) do
          Inc(J);
        Token := StringReplace(Copy(S, I, J - I), ',', '.', [rfReplaceAll]);
        if TryStrToFloat(Token, V, FS) then
        begin
          if (not HasVal) or (V > AValue) then
            AValue := V;
          HasVal := True;
        end;
        I := J;
      end
      else
        Inc(I);
    end;
    Result := HasVal;
  end;

  function GetJsonFlowDoubleDef(const AObj: TJSONObject; const AName: string; const ADefault: Double): Double;
  var
    V: TJSONValue;
    Parsed: Double;
  begin
    Result := ADefault;
    if AObj = nil then
      Exit;
    V := AObj.GetValue(AName);
    if V = nil then
      Exit;
    if V is TJSONNumber then
      Exit(TJSONNumber(V).AsDouble);
    if (V is TJSONString) and ExtractMaxFloatFromText(TJSONString(V).Value, Parsed) then
      Exit(Parsed);
  end;

  function FindDiameterByDN(const ADN: string): Integer;
  var
    K: Integer;
  begin
    Result := -1;
    for K := 0 to FDiametersLocal.Count - 1 do
      if (FDiametersLocal[K] <> nil) and SameText(Trim(FDiametersLocal[K].DN), Trim(ADN)) then
        Exit(K);
  end;

  function IsBetterDiameterRow(const CandidateD, CurrentD: TDiameter): Boolean;
  begin
    if (CandidateD = nil) then
      Exit(False);
    if (CurrentD = nil) then
      Exit(True);

    if CandidateD.Qnom > CurrentD.Qnom then
      Exit(True);
    if CandidateD.Qnom < CurrentD.Qnom then
      Exit(False);

    if CandidateD.Qmax > CurrentD.Qmax then
      Exit(True);
    if CandidateD.Qmax < CurrentD.Qmax then
      Exit(False);

    Result := False;
  end;

  procedure CopyDiameterValues(const TargetD, SourceD: TDiameter);
  begin
    if (TargetD = nil) or (SourceD = nil) then
      Exit;
    TargetD.Enable := SourceD.Enable;
    TargetD.Name := SourceD.Name;
    TargetD.DN := SourceD.DN;
    TargetD.Qmax := SourceD.Qmax;
    TargetD.Qnom := SourceD.Qnom;
    TargetD.Qtr := SourceD.Qtr;
    TargetD.Q2tr := SourceD.Q2tr;
    TargetD.Qmin := SourceD.Qmin;
    TargetD.Kp := SourceD.Kp;
    TargetD.QFmax := SourceD.QFmax;
  end;

begin
  Result := False;
  JsonVal := TJSONObject.ParseJSONValue(AResponse);
  try
    if not (JsonVal is TJSONObject) then
      Exit;
    Root := JsonVal as TJSONObject;

    DeviceTypeObj := Root.GetValue('device_type') as TJSONObject;
    if DeviceTypeObj = nil then
      Exit;
    GeneralInfoObj := DeviceTypeObj.GetValue('general_info') as TJSONObject;
    if GeneralInfoObj = nil then
      Exit;

    if GeneralInfoObj.GetValue('name') <> nil then
      FType.Name := GeneralInfoObj.GetValue<string>('name', FType.Name);
    if GeneralInfoObj.GetValue('manufacturer') <> nil then
      FType.Manufacturer := GeneralInfoObj.GetValue<string>('manufacturer', FType.Manufacturer);
    if GeneralInfoObj.GetValue('modification') <> nil then
      FType.Modification := GeneralInfoObj.GetValue<string>('modification', FType.Modification);
    if GeneralInfoObj.GetValue('procedure') <> nil then
      FType.VerificationMethod := GeneralInfoObj.GetValue<string>('procedure', FType.VerificationMethod);
    if GeneralInfoObj.GetValue('grsi_number') <> nil then
      FType.ReestrNumber := GeneralInfoObj.GetValue<string>('grsi_number', FType.ReestrNumber);
    if GeneralInfoObj.GetValue('mpi') <> nil then
      FType.IVI := GeneralInfoObj.GetValue<Integer>('mpi', FType.IVI);
    if GeneralInfoObj.GetValue('accuracy_class') <> nil then
      FType.AccuracyClass := GeneralInfoObj.GetValue<string>('accuracy_class', FType.AccuracyClass);
    if GeneralInfoObj.GetValue('base_error') <> nil then
      if not ExtractMinFloatFromText(GeneralInfoObj.GetValue<string>('base_error', ''), FType.Error) then
        FType.Error := GetJsonDoubleDef(GeneralInfoObj, 'base_error', FType.Error);

    DiametersArr := Root.GetValue('diameters') as TJSONArray;
    if DiametersArr <> nil then
    begin
      FDiametersLocal.Clear;
      for I := 0 to DiametersArr.Count - 1 do
      begin
        if not (DiametersArr.Items[I] is TJSONObject) then
          Continue;
        DObj := DiametersArr.Items[I] as TJSONObject;
        D := TDiameter.Create(FType.UUID);
        D.Enable := DObj.GetValue<Boolean>('enabled', True);
        D.Name := DObj.GetValue<string>('name', '');
        D.DN := DObj.GetValue<string>('dn_mm', '');
        D.Qmax := GetJsonFlowDoubleDef(DObj, 'qmax_l_s', 0);
        D.Qnom := GetJsonFlowDoubleDef(DObj, 'qnom_l_s', 0);
        D.Qtr := GetJsonFlowDoubleDef(DObj, 'qtr_l_s', 0);
        D.Q2tr := GetJsonFlowDoubleDef(DObj, 'q2tr_l_s', 0);
        D.Qmin := GetJsonFlowDoubleDef(DObj, 'qmin_l_s', 0);
        D.Kp := GetJsonDoubleDef(DObj, 'kp_imp_l', 0);
        D.QFmax := GetJsonFlowDoubleDef(DObj, 'qf_l_s', 0);
        if IsFlowUnitM3h(GetSelectedFlowUnit) then
        begin
          D.Qmax := FType.ToBaseUnits(D.Qmax);
          D.Qnom := FType.ToBaseUnits(D.Qnom);
          D.Qtr := FType.ToBaseUnits(D.Qtr);
          D.Q2tr := FType.ToBaseUnits(D.Q2tr);
          D.Qmin := FType.ToBaseUnits(D.Qmin);
          D.QFmax := FType.ToBaseUnits(D.QFmax);
        end;
        if (D.Qmax > 0) and (D.Qnom > 0) and (D.Qnom > D.Qmax) then
        begin
          D.Qmax := D.Qmax + D.Qnom;
          D.Qnom := D.Qmax - D.Qnom;
          D.Qmax := D.Qmax - D.Qnom;
        end;
        if (D.Qtr > 0) and (D.Q2tr > 0) and (D.Q2tr < D.Qtr) then
        begin
          D.Qtr := D.Qtr + D.Q2tr;
          D.Q2tr := D.Qtr - D.Q2tr;
          D.Qtr := D.Qtr - D.Q2tr;
        end;
        ExistingIdx := FindDiameterByDN(D.DN);
        if (ExistingIdx >= 0) and (ExistingIdx < FDiametersLocal.Count) then
        begin
          if IsBetterDiameterRow(D, FDiametersLocal[ExistingIdx]) then
            CopyDiameterValues(FDiametersLocal[ExistingIdx], D);
          D.Free;
        end
        else
        begin
          D.State := osNew;
          FDiametersLocal.Add(D);
        end;
      end;
    end;

    PointsArr := Root.GetValue('verification_points') as TJSONArray;
    if PointsArr <> nil then
    begin
      FPointsLocal.Clear;
      for I := 0 to PointsArr.Count - 1 do
      begin
        PObj := PointsArr.Items[I] as TJSONObject;
        if PObj = nil then
          Continue;
        P := TTypePoint.Create(FType.UUID);
        P.Enable := PObj.GetValue<Boolean>('enabled', True);
        P.Name := PObj.GetValue<string>('name', '');
        P.FlowRate := GetJsonDoubleDef(PObj, 'q_qmax', 0);
        P.LimitVolume := GetJsonDoubleDef(PObj, 'volume_l', 0);
        P.LimitImp := PObj.GetValue<Integer>('impulses_count', 0);
        P.LimitTime := GetJsonDoubleDef(PObj, 'time_s', 0);
        P.Error := GetJsonDoubleDef(PObj, 'error_percent', 0);
        P.FlowAccuracy := PObj.GetValue<string>('expanded_uncertainty_percent', '');
        P.Pause := PObj.GetValue<Integer>('stabilization_time_s', 0);
        P.RepeatsProtocol := PObj.GetValue<Integer>('repeat_count', 0);
        P.Repeats := PObj.GetValue<Integer>('measurement_series_count', 0);
        P.Pressure := GetJsonDoubleDef(PObj, 'pressure', 0);
        P.State := osNew;
        FPointsLocal.Add(P);
      end;
    end;

    Result := True;
    UpdateUIFromType;
    UpdateDiametersGrid;
    UpdatePointsGrid;
  finally
    JsonVal.Free;
  end;
end;

procedure TFormTypeEditor.btnOKClick(Sender: TObject);
begin
  UpdateTypeFromUI;
  // --------------------------------------------------
  // Валидация данных
  // --------------------------------------------------
  if Trim(FType.Name) = '' then
  begin
    ShowMessage('Не задано наименование типа');
    Exit;
  end;

  WriteTypeEditActionLog('Сохранён тип прибора', FType);
  ModalResult := mrOk;
end;

procedure TFormTypeEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Разрываем ссылки на коллекции FType до освобождения FType,
  // чтобы поздние UI-события при закрытии не обращались к освобождённой памяти.
  FDiametersLocal := nil;
  FPointsLocal := nil;
  FLoading := True;

  if (FOriginalType = nil) and (ModalResult <> mrOk) and (FType <> nil) then
    FType.State := osDeleted;

  if FOriginalType <> nil then
    FreeAndNil(FType)
  else
    FType := nil;

  FreeAndNil(FCalibrCoefItemsLocal);
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

    if (AppServices.DataManager = nil) or (AppServices.DataManager.ActiveTypeRepo = nil) then
      raise Exception.Create('Активный репозиторий типов не выбран');

    if (FType = nil)  then
      raise Exception.Create('Не задан тип');

    Repo := AppServices.DataManager.ActiveTypeRepo;

    if FOriginalType <> nil then
    begin
      FOriginalType.Assign(FType, True);
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

  if NewD.ID = 0 then
    NewD.ID := -(FType.Diameters.Count + 1);

  if NewD.Qmax > 0 then
  begin
    RecalcQRowFromKnown(NewD, StringColumnDNQmax.Index, NewD.Qmax,SrcD);
  end;

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
  FSelectedDiameter := nil;

  SetModified;
end;
procedure TFormTypeEditor.ButtonDiameterDeleteClick(Sender: TObject);
var
  D: TDiameter;
  SelRow: Integer;
  I: Integer;
  HasChecked: Boolean;
begin
  if (FType = nil) or (FDiametersLocal = nil) then
    Exit;

  HasChecked := False;
  for I := 0 to FDiametersLocal.Count - 1 do
    if (FDiametersLocal[I].State <> osDeleted) and FDiametersLocal[I].Enable then
    begin
      HasChecked := True;
      Break;
    end;

  if HasChecked then
  begin
    if not FSkipDiameterDeleteConfirm then
    begin
      if MessageDlg(
           'Удалить выбранные диаметры?',
           TMsgDlgType.mtWarning,
           [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
           0
         ) <> mrYes then
        Exit;

      FSkipDiameterDeleteConfirm := True;
    end;

    for I := FDiametersLocal.Count - 1 downto 0 do
    begin
      D := FDiametersLocal[I];
      if (D.State = osDeleted) or not D.Enable then
        Continue;

      if D.State = osNew then
        FDiametersLocal.Remove(D)
      else
        D.State := osDeleted;
    end;

    GridDiameters.Row := -1;
    UpdateDiametersGrid;
    UpdatePointsGrid;
    SetModified;
    Exit;
  end;

  SelRow := GridDiameters.Row;
  if SelRow < 0 then
    Exit;

  { Явно подсвечиваем строку для удаления }
  GridDiameters.Row := SelRow;
  GridDiameters.Selected := SelRow;

  D := GetDiameterByVisibleRow(SelRow);
  if D = nil then
    Exit;

  if not FSkipDiameterDeleteConfirm then
  begin
    if MessageDlg(
         'Удалить выбранный диаметр?',
         TMsgDlgType.mtWarning,
         [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
         0
       ) <> mrYes then
      Exit;

    FSkipDiameterDeleteConfirm := True;
  end;

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
  NewP.RepeatsProtocol := Max(FType.Repeats, 1);
  NewP.Repeats := Max(FType.Repeats, 1);


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
  SelRow: Integer;
  I: Integer;
  HasChecked: Boolean;
begin
  if (FType = nil) or (FPointsLocal = nil) then
    Exit;

  HasChecked := False;
  for I := 0 to FPointsLocal.Count - 1 do
    if (FPointsLocal[I].State <> osDeleted) and FPointsLocal[I].Enable then
    begin
      HasChecked := True;
      Break;
    end;

  if HasChecked then
  begin
    if not FSkipPointDeleteConfirm then
    begin
      if MessageDlg(
           'Удалить выбранную точку?',
           TMsgDlgType.mtWarning,
           [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
           0
         ) <> mrYes then
        Exit;

      FSkipPointDeleteConfirm := True;
    end;

    for I := FPointsLocal.Count - 1 downto 0 do
    begin
      Point := FPointsLocal[I];
      if (Point.State = osDeleted) or not Point.Enable then
        Continue;

      if Point.State = osNew then
        FPointsLocal.Delete(I)
      else
        Point.State := osDeleted;
    end;

    GridPoints.Row := -1;
    UpdatePointsGrid;
    SetModified;
    Exit;
  end;

  SelRow := GridPoints.Row;
  if SelRow < 0 then
    Exit;

  { Явно подсвечиваем строку для удаления }
  GridPoints.Row := SelRow;
  GridPoints.Selected := SelRow;

  Point := GetPointByVisibleRow(SelRow);
  if Point = nil then
    Exit;

  if not FSkipPointDeleteConfirm then
  begin
    if MessageDlg(
         'Удалить выбранную точку?',
         TMsgDlgType.mtWarning,
         [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
         0
       ) <> mrYes then
      Exit;

    FSkipPointDeleteConfirm := True;
  end;

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

procedure TFormTypeEditor.GridDiametersKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
  var
  i:integer;
  begin
  if (Key = vkDelete) and not GridDiameters.EditorMode then
  begin
    i:=GridDiameters.Row;
    ButtonDiameterDeleteClick(ButtonDiameterDelete);
    Key := 0;
    if GridDiameters.RowCount>0 then
      GridDiameters.Row:=(i-1);
  end;
end;


procedure TFormTypeEditor.GridPointsKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
  var
  i:integer;
  begin
  if (Key = vkDelete) and not GridPoints.EditorMode then
  begin
    i:=GridPoints.Row;
    ButtonPointDeleteClick(ButtonPointDelete);
    Key := 0;
    if GridPoints.RowCount>0 then
      GridPoints.Row:=(i-1);
  end;
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
  FType.Units := 0;
  FType.SetDimensions;

  // применяем логику для выбранной величины
  ApplyMeasuredDimension;

  SetModified;
end;

procedure TFormTypeEditor.ComboBoxUnitsChange(Sender: TObject);
var
  V: Integer;
begin
  if FLoading or (FType = nil) then
    Exit;

  V := ComboBoxUnits.ItemIndex;
  if V < 0 then
    Exit;

  if V = FType.Units then
    Exit;

  FType.Units := V;
  FType.SetDimensions;
  ApplyMeasuredDimension;
  SetModified;
  CreateMenu;
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
var
  I: Integer;
begin
  if FLoading then Exit;

  if cbSpillageStop.ItemIndex < 0 then
    Exit;

  // сохраняем критерий остановки как битовую маску
  FType.SpillageStop := SpillageStopItemIndexToValue(cbSpillageStop.ItemIndex);

  if FPointsLocal = nil then
    FPointsLocal := FType.Points;

  if FPointsLocal <> nil then
    for I := 0 to FPointsLocal.Count - 1 do
      if FPointsLocal[I] <> nil then
      begin
       // FPointsLocal[I].SpillageStop := FType.SpillageStop;
        if FPointsLocal[I].State <> osNew then
          FPointsLocal[I].State := osModified;
      end;

  UpdatePointsGrid;
  SetModified;
end;

procedure TFormTypeEditor.cbSpillageTypeChange(Sender: TObject);
begin
  if FLoading then Exit;

  // защита
  if cbSpillageType.ItemIndex < 0 then
    Exit;

  // сохраняем выбор
  FType.SpillageType := SpillageTypeItemIndexToValue(cbSpillageType.ItemIndex);

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
    CatID := Integer(NativeInt(ceCategory.Items.Objects[Idx]));

    FType.Category := CatID;
    FType.CategoryName := '';

    {----------------------------------}
    { Применяем defaults категории }
    {----------------------------------}
    C := AppServices.DataManager.FindCategoryByID(CatID);
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
     WriteTypeEditActionLog('Редактирование типа прибора отменено', FType);
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
  MAX_TEXT_LENGTH = 50000; // ⬅ безопасно для DeepSeek
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
  SavedJsonPath: string;
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
    SavedJsonPath := SaveDeepSeekJsonToDocs(FilePath, AIResponse);
    MemoLog.Lines.Add('JSON сохранен: ' + SavedJsonPath);

    ShowMessage(
      'DeepSeek обработал описание типа.' + sLineBreak +
      'JSON сохранен в папку docs проекта.'
    );

  except
    on E: Exception do
    begin
      MemoLog.Lines.Add('ERROR DeepSeek [' + ExtractFileName(FilePath) + ']: ' + E.Message);
      ShowMessage('Файл: ' + ExtractFileName(FilePath) + sLineBreak + 'Ошибка при обращении к DeepSeek');
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
  if not (Sender is TEdit) then
    Exit;

  E := TEdit(Sender);

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
  begin
    EditCoef.Text := FormatFloat('0.########', GetDisplayedCoef);
    Exit;
  end;

  // 5. Сохраняем базовый коэффициент
  FType.Coef := NewBaseCoef;

  FType.Freq := Round(FType.Coef/3.6);

  // 6. Пересчёт Kp для всех диаметров
  RecalcDiametersKpByCoef;

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


procedure TFormTypeEditor.RecalcDiametersKpByCoef;
var
  I: Integer;
  Kp: Double;
begin
  if (FDiametersLocal = nil) or (FType = nil) then
    Exit;

  for I := 0 to FDiametersLocal.Count - 1 do
  begin
    if FDiametersLocal[I].QFmax > 0 then
      Kp := FType.Coef / FDiametersLocal[I].QFmax
    else
      Kp := 0;

    if not SameValue(FDiametersLocal[I].Kp,Kp,MinDouble)  then
      begin
        FDiametersLocal[I].Kp:=Kp;
        if FDiametersLocal[I].State=osClean then
           FDiametersLocal[I].State:=osModified
      end;


  end;



end;

procedure TFormTypeEditor.RecalcDiametersKpByFreq;
var
  I: Integer;
  Kp: Double;
begin
  if (FDiametersLocal = nil) or (FType = nil) then
    Exit;

  for I := 0 to FDiametersLocal.Count - 1 do
  begin

    if FDiametersLocal[I].QFmax > 0 then
      Kp := 3.6 * FType.Freq / FDiametersLocal[I].QFmax
    else
      Kp := 0;

    if not SameValue(FDiametersLocal[I].Kp,Kp,MinDouble)  then
      begin
        FDiametersLocal[I].Kp:=Kp;
        if FDiametersLocal[I].State=osClean then
           FDiametersLocal[I].State:=osModified
      end;


  end;
end;


procedure TFormTypeEditor.EditTempEnter(Sender: TObject);
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

procedure TFormTypeEditor.EditTempExit(Sender: TObject);
begin
  if FLoading then Exit;

  FType.Temp := EditTemp.Text;
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
//  if FType.Freq = NewFreq then
//    Exit;

  // ----------------------------------------
  // Сохраняем в тип
  // ----------------------------------------
  FType.Freq := NewFreq;
  FType.Coef := 3.6 *  FType.Freq;
  // ----------------------------------------
  // Пересчёт Kp по частоте
  // Kp = 3.6 * Freq / QFmax
  // ----------------------------------------
  RecalcDiametersKpByFreq;

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

procedure TFormTypeEditor.EditFreqFlowRateKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key <> vkReturn then
    Exit;

  EditFreqFlowRateExit(EditFreqFlowRate);
  Key := 0;
  KeyChar := #0;
  if GridDiameters <> nil then
    GridDiameters.SetFocus
  else
    Self.SetFocus;
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
  if not (Sender is TEdit) then
    Exit;

  E := TEdit(Sender);

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
  if not (Sender is TEdit) then
    Exit;

  E := TEdit(Sender);

  // пример: убираем двойные пробелы
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;



procedure TFormTypeEditor.EditRangeDynamicCanFocus(Sender: TObject;
  var ACanFocus: Boolean);
begin
 EditRangeDynamic.Text := EditRangeDynamic.TextPrompt;
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
  // Пересчитываем Qmin по динамическому диапазону:
  // изменение EditRangeDynamic влияет на значения в гриде.
  // -----------------------------------------------------
  for I := 0 to FDiametersLocal.Count - 1 do
  begin
    if FDiametersLocal[I].Qmax > 0 then
      FDiametersLocal[I].Qmin := FDiametersLocal[I].Qmax / RangeDynamic
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
  if not (Sender is TEdit) then
    Exit;

  E := TEdit(Sender);

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

  if FType = nil then
    Exit;

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
  if not (Sender is TEdit) then
    Exit;

  E := TEdit(Sender);

  // убираем двойные пробелы
  while Pos('  ', E.Text) > 0 do
    E.Text := StringReplace(E.Text, '  ', ' ', [rfReplaceAll]);
end;


procedure TFormTypeEditor.EditFlowRateExit(Sender: TObject);
var
  D: TDiameter;
  V, Qmax: Double;
  DNmm: Integer;
begin
  if FLoading then
    Exit;

  V := NormalizeFloatInput(EditFlowRate.Text);
  if V <= 0 then
    Exit;

  if FDiametersLocal = nil then
    Exit;

  for D in FDiametersLocal do
  begin
    if (D = nil) or (D.State = osDeleted) then
      Continue;

    DNmm := StrToIntDef(D.DN, 0);
    if DNmm <= 0 then
      Continue;

    Qmax := (0.002827 * V * Sqr(DNmm))/3.6;
    RecalcQRowFromKnown(D, StringColumnDNQmax.Index, Qmax);
  end;

  SetModified;
  UpdateDiametersGrid;
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

function TFormTypeEditor.GetDiameterColumnHint(const ACol: Integer): string;
begin
  Result := '';
  if ACol = StringColumnDNQmin.Index then
    Result := StringColumnDNQmin.Hint
  else if ACol = StringColumnDNQTr.Index then
    Result := StringColumnDNQTr.Hint
  else if ACol = StringColumnDNQ2Tr.Index then
    Result := StringColumnDNQ2Tr.Hint
  else if ACol = StringColumnDNQnom.Index then
    Result := StringColumnDNQnom.Hint
  else if ACol = StringColumnDNQmax.Index then
    Result := StringColumnDNQmax.Hint
  else if ACol = StringColumnDNQF.Index then
    Result := StringColumnDNQF.Hint;
end;



procedure TFormTypeEditor.GridDiametersCellClick(const Column: TColumn;
  const Row: Integer);
  var
    D: TDiameter;
  begin


  if Column<>CheckColumnDNEnable then
    Exit;


  D := GetDiameterByVisibleRow(Row);
  d.Enable:=not  d.Enable;
  UpdateDiametersGrid;

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

  if ACol = CheckColumnDNEnable.Index then
    Value :=  D.Enable

  // =====================================================
  // == Наименование
  // =====================================================
  else if ACol = StringColumnDNName.Index then
    Value := D.Name

  // =====================================================
  // == DN (мм) — INTEGER
  // =====================================================
  else if ACol = IntegerColumnDNSize.Index then
    Value := StrToIntDef(D.DN, 0)

  // =====================================================
  // == Qtr
  // =====================================================
  else if ACol = StringColumnDNQTr.Index then
  begin
    if D.Qtr = 0 then
      Value := '—'
    else
      Value := FormatByBaseError(FType.FromBaseUnits(D.Qtr), FType.Error);
  end
  else if ACol = StringColumnDNQ2Tr.Index then
  begin
    if D.Q2tr = 0 then
      Value := '—'
    else
      Value := FormatByBaseError(FType.FromBaseUnits(D.Q2tr), FType.Error);
  end
  else if ACol = StringColumnDNQ2Tr.Index then
  begin
    if D.Q2Tr = 0 then
      Value := '—'
    else
      Value := FormatByBaseError(FType.FromBaseUnits(D.Q2Tr), FType.Error);
  end

  // =====================================================
  // == Qmax
  // =====================================================
  else if ACol = StringColumnDNQmax.Index then
  begin
    if D.Qmax = 0 then
      Value := '—'
    else
      Value := FormatByBaseError(FType.FromBaseUnits(D.Qmax), FType.Error);
  end

  // =====================================================
  // == Qmin
  // =====================================================

    else if ACol = StringColumnDNQmin.Index then
  begin
    if D.Qmin = 0 then
      Value := '—'
    else
      Value := FormatByBaseError(FType.FromBaseUnits(D.Qmin), FType.Error);
  end

  // =====================================================
  // == Qnom (Q3)
  // =====================================================
  else if ACol = StringColumnDNQnom.Index then
  begin
    if D.Qnom = 0 then
      Value := '—'
    else
      Value := FormatByBaseError(FType.FromBaseUnits(D.Qnom), FType.Error);
  end

  else if ACol = StringColumnDNQF.Index then
  begin
    if D.QFmax = 0 then
      Value := '—'
    else
      Value := FormatByBaseError(FType.FromBaseUnits(D.QFmax), FType.Error);
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
      Value := FormatByBaseError(D.Kp, FType.Error);
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
  FSelectedDiameter:= D;
  // ----------------------------------------
  // Если диапазон не задан явно —
  // показываем подсказку по выбранному диаметру
  // ----------------------------------------
  if Trim(EditRangeDynamic.Text) = '' then
    UpdateRangeDynamicPromptBySelectedDiameter;

  if Trim(EditFlowRate.Text) = '' then
    UpdateFlowRatePromptBySelectedDiameter;

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
  Qmax, RangeDynamic, NewCoef, QValueBase: Double;
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

  if D.State <> osNew then
    D.State := osModified;

  S := Trim(Value.ToString);

  if ACol = CheckColumnDNEnable.Index then
    D.Enable := not D.Enable

  {=====================================================}
  { ИМЯ }
  {=====================================================}
  else if ACol = StringColumnDNName.Index then
    D.Name := S

  {=====================================================}
  { DN (мм) }
  {=====================================================}
  else if ACol = IntegerColumnDNSize.Index then
    D.DN := IntToStr(Round(NormalizeFloatInput(S)))

  {=====================================================}
  { Q2 / Qmax / Qmin / Q перегрузочный }
  {=====================================================}
  else if (ACol = StringColumnDNQTr.Index) or
          (ACol = StringColumnDNQ2Tr.Index) or
          (ACol = StringColumnDNQmax.Index) or
          (ACol = StringColumnDNQmin.Index) or
          (ACol = StringColumnDNQnom.Index) then
  begin
      if ACol = StringColumnDNQmax.Index then
    begin
      EditFlowRate.Text := '';
      UpdateFlowRateFromDiameter(D);
    end;
    QValueBase := FType.ToBaseUnits(NormalizeFloatInput(S));

    if Trim(EditFlowRate.Text) = '' then
    begin
      // Если скорость потока не задана, меняем редактируемое поле.
      // Для пары Qnom/Qmax сохраняем взаимосвязь по формулам 1.25.
      if (ACol = StringColumnDNQTr.Index)  then
        D.Qtr := QValueBase
      else  if (ACol = StringColumnDNQ2Tr.Index) then
        D.Q2tr := QValueBase
      else if ACol = StringColumnDNQmax.Index then
      begin
        D.Qmax := QValueBase;
        if D.Qmax > 0 then
          D.Qnom := D.Qmax / 1.25;
      end
      else if ACol = StringColumnDNQmin.Index then
        D.Qmin := QValueBase
      else if ACol = StringColumnDNQnom.Index then
      begin
        D.Qnom := QValueBase;
        if D.Qnom > 0 then
          D.Qmax := D.Qnom * 1.25;
      end;


    end
    else
    begin
     // RecalcQRowFromKnown(D, ACol, QValueBase);
    end;

    Qmax := D.Qmax;

    { Не ломаем существующий расчетный QFmax для частотного выхода }
    if FType.FreqFlowRate > 0 then
      D.QFmax := Qmax * FType.FreqFlowRate
    else
      D.QFmax := Qmax;

    if Trim(EditFlowRate.Text) = '' then
      UpdateFlowRateFromDiameter(D);


    if ACol = StringColumnDNQmin.Index then
    begin
      FType.RangeDynamic := 0;
      EditRangeDynamic.Text := '';
      EditRangeDynamic.TextPrompt := '';
      UpdateRangeDynamicPromptBySelectedDiameter;
    end;

    SelD := GetDiameterByVisibleRow(GridDiameters.Row);
    if SelD = D then
      RecalcPointsBySelectedDiameter;
  end

  {=====================================================}
  { Qmin (ручной ввод) }
  {=====================================================}
  else if False then begin end


  else if ACol = StringColumnDNQF.Index then
  begin
    D.QFmax := FType.ToBaseUnits(NormalizeFloatInput(S));

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
  function TryGetDiameterColumnValueByName(const AD: TDiameter; const AColumnName: string; out AValue: Double): Boolean;
  var
    NameNorm, HeaderNorm: string;
  begin
    Result := False;
    AValue := 0;
    if (AD = nil) or (AColumnName = '') then
      Exit;

    NameNorm := UpperCase(Trim(AColumnName));

    if NameNorm = 'QMIN' then
    begin
      AValue := AD.Qmin;
      Exit(True);
    end;
    if (NameNorm = 'QTR') or (NameNorm = 'Q2') then
    begin
      AValue := AD.Qtr;
      Exit(True);
    end;
    if NameNorm = 'Q2TR' then
    begin
      AValue := AD.Q2Tr;
      Exit(True);
    end;
    if (NameNorm = 'QNOM') or (NameNorm = 'Q3') then
    begin
      AValue := AD.Qnom;
      Exit(True);
    end;
    if (NameNorm = 'QMAX') or (NameNorm = 'Q4') then
    begin
      AValue := AD.Qmax;
      Exit(True);
    end;
    if NameNorm = 'QF' then
    begin
      AValue := AD.QFmax;
      Exit(True);
    end;
    if NameNorm = 'KP' then
    begin
      AValue := AD.Kp;
      Exit(True);
    end;

    HeaderNorm := UpperCase(StringColumnDNQmin.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.Qmin;
      Exit(True);
    end;

    HeaderNorm := UpperCase(StringColumnDNQTr.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.Qtr;
      Exit(True);
    end;

    HeaderNorm := UpperCase(StringColumnDNQ2Tr.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.Q2tr;
      Exit(True);
    end;
    HeaderNorm := UpperCase(StringColumnDNQ2Tr.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.Q2Tr;
      Exit(True);
    end;

    HeaderNorm := UpperCase(StringColumnDNQnom.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.Qnom;
      Exit(True);
    end;

    HeaderNorm := UpperCase(StringColumnDNQmax.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.Qmax;
      Exit(True);
    end;

    HeaderNorm := UpperCase(StringColumnDNQF.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.QFmax;
      Exit(True);
    end;

    HeaderNorm := UpperCase(StringColumnDNKp.Header);
    if (HeaderNorm <> '') and (Pos(NameNorm, HeaderNorm) > 0) then
    begin
      AValue := AD.Kp;
      Exit(True);
    end;
  end;

  function TryApplyPointNameFormula(const AText: string; AP: TTypePoint): Boolean;
  var
    SepPos, I, StartColPos: Integer;
    CoefText, ColText: string;
    K, ColValue: Double;
    LocalD: TDiameter;
    Ch: Char;
  begin
    SepPos:=0;
    Result := False;
    if (AP = nil) then
      Exit;

    K := 1;
    SepPos := Pos('*', AText);
    if SepPos = 0 then
      SepPos := Pos('·', AText);
    if SepPos = 0 then
    begin
      for I := 1 to Length(AText) do
        if AText[I] = ' ' then
        begin
          SepPos := I;
          Break;
        end;
    end;

    if SepPos > 0 then
    begin
      CoefText := Trim(Copy(AText, 1, SepPos - 1));
      ColText := Trim(Copy(AText, SepPos + 1, MaxInt));
      if ColText = '' then
        Exit;
      if CoefText <> '' then
        K := NormalizeFloatInput(CoefText);
    end
    else
    begin
      StartColPos := 0;
      for I := 1 to Length(AText) do
      begin
        Ch := AText[I];
        if not (Ch in ['0'..'9', ',', '.', ' ']) then
        begin
          StartColPos := I;
          Break;
        end;
      end;

      if StartColPos > 1 then
      begin
        CoefText := Trim(Copy(AText, 1, StartColPos - 1));
        ColText := Trim(Copy(AText, StartColPos, MaxInt));
        if CoefText <> '' then
          K := NormalizeFloatInput(CoefText);
      end
      else
      begin
        CoefText := '';
        ColText := Trim(AText);
      end;
    end;

    if ColText = '' then
      Exit;

    LocalD := GetDiameterByVisibleRow(GridDiameters.Row);
    if (LocalD = nil) or (not TryGetDiameterColumnValueByName(LocalD, ColText, ColValue)) then
      Exit;

    if LocalD.Qmax > 0 then
    begin
      AP.FlowRate := (K * ColValue) / LocalD.Qmax;
      Result := True;
    end;
  end;
var
  P: TTypePoint;
  D: TDiameter;
  Qmax, Q, V, Tm, Coef: Double;
  S: string;
begin
  {-----------------------------------------------------}
  { Защита }
  {-----------------------------------------------------}
  if GridDiameters.Selected = -1 then
    Exit;
  if (FPointsLocal = nil) then
    Exit;

  P := GetPointByVisibleRow(ARow);
  if P = nil then
    Exit;

  S := Trim(Value.toString);
  D := GetDiameterByVisibleRow(GridDiameters.Row);
  {=====================================================}
  { 1. НЕ зависят от диаметра }
  {=====================================================}

  if ACol = StringColumnPointName.Index then
  begin
    P.Name := S;
    TryApplyPointNameFormula(S, P);
    V := P.FlowRate * D.Qmax * P.LimitTime ;
    P.LimitVolume := V;
  end

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
    begin
      P.FlowRate := NormalizeFloatInput(S);
      V := P.FlowRate * Qmax * P.LimitTime ;
      P.LimitVolume := V;
    end

    else if ACol = StringColumnPointName.Index then
    begin
       V := P.FlowRate * Qmax * P.LimitTime ;
       P.LimitVolume := V;
    end
    {---------------------------------}
    { Q (абсолютный) }
    {---------------------------------}
    else if ACol = StringColumnPointQ.Index then
    begin
      Q := FType.ToBaseUnits(NormalizeFloatInput(S));
      if Qmax > 0 then
        P.FlowRate := Q / Qmax;
      V := P.FlowRate * Qmax * P.LimitTime ;
       P.LimitVolume := V;
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
        V := Q * Tm ;
        P.LimitVolume := V;

        if Coef > 0 then
          P.LimitImp := Round(V * Coef);
      end;
    end;
  end;

  P.State:=osModified;
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
  if (FSelectedDiameter = nil) or (FPointsLocal = nil) then
    Exit;

  Qmax := FSelectedDiameter.Qmax;
  Coef := FSelectedDiameter.Kp;

  // -----------------------------------------------------
  // Пересчёт всех ЛОКАЛЬНЫХ точек
  // -----------------------------------------------------
  for I := 0 to FPointsLocal.Count-1 do
  begin
    // Q = (Q/Qmax) * Qmax
    Q := FPointsLocal[I].FlowRate *  Qmax;

    // если задано время
    if (Q > 0) and (FPointsLocal[I].LimitTime > 0) then
    begin
      Tm := FPointsLocal[I].LimitTime;
      V  := Q * Tm ;

      FPointsLocal[I].LimitVolume := V;
      FPointsLocal[I].LimitImp    := Round(V * Coef);
    end;
  end;

end;


function TFormTypeEditor.HasLocalReestrFiles: Boolean;
begin
  // Проверяем, выбрал ли пользователь хотя бы один локальный файл.
  Result :=
    (Trim(Edit1.Text) <> '') or
    (Trim(Edit2.Text) <> '') or
    (Trim(Edit3.Text) <> '');
end;

function TFormTypeEditor.ResolveReestrFilePath(const AEdit: TEdit): string;
var
  Candidate: string;
begin
  Result := '';
  if AEdit = nil then
    Exit;

  // Сначала пробуем полный путь, который хранится в Hint.
  Candidate := Trim(AEdit.Hint);
  if (Candidate <> '') and FileExists(Candidate) then
    Exit(Candidate);

  // Затем проверяем значение из Edit как абсолютный/относительный путь.
  Candidate := Trim(AEdit.Text);
  if Candidate = '' then
    Exit;

  if (ExtractFilePath(Candidate) <> '') and FileExists(Candidate) then
    Exit(Candidate);

  // Если в Edit только имя файла, формируем путь в стандартной папке хранения.
  Result := TPath.Combine(TPath.Combine(ExtractFilePath(ParamStr(0)), 'Docs\Types'), Candidate);
end;

function TFormTypeEditor.CheckLocalReestrFiles: Boolean;
var
  FilePath1, FilePath2, FilePath3: string;
begin
  // Проверяем существование каждого заполненного файла.
  Result := False;

  FilePath1 := ResolveReestrFilePath(Edit1);
  if (Trim(Edit1.Text) <> '') and (not FileExists(FilePath1)) then
  begin
    ShowMessage('Файл из Edit1 не найден: ' + FilePath1);
    Exit;
  end;

  FilePath2 := ResolveReestrFilePath(Edit2);
  if (Trim(Edit2.Text) <> '') and (not FileExists(FilePath2)) then
  begin
    ShowMessage('Файл из Edit2 не найден: ' + FilePath2);
    Exit;
  end;

  FilePath3 := ResolveReestrFilePath(Edit3);
  if (Trim(Edit3.Text) <> '') and (not FileExists(FilePath3)) then
  begin
    ShowMessage('Файл из Edit3 не найден: ' + FilePath3);
    Exit;
  end;

  Result := True;
end;

procedure TFormTypeEditor.ProcessLocalReestrFiles;
var
  JsonTemplate: string;
  FilePath: string;
  TxtPath: string;
  PdfText: string;
  DeepSeekResponse: string;

  procedure ProcessOneFile(const AEdit: TEdit);
  begin
  JsonTemplate := BuildDeepSeekTemplate(GetSelectedAccuracyClass, Trim(EditModification.Text));
    if (AEdit = nil) or (Trim(AEdit.Text) = '') then
      Exit;

    FilePath := ResolveReestrFilePath(AEdit);
    TxtPath := ChangeFileExt(FilePath, '.txt');

    try
      if ExtractTextLayerFromPdf(FilePath, TxtPath) then
      begin
        PdfText := TFile.ReadAllText(TxtPath, TEncoding.UTF8);
        if SendTextToDeepSeekTemplate(PdfText, JsonTemplate, DeepSeekResponse) then
          ApplyDeepSeekJsonToType(DeepSeekResponse);
      end;
    except
      on E: Exception do
      begin
        MemoLog.Lines.Add('ERROR [' + ExtractFileName(FilePath) + ']: ' + E.Message);
        ShowMessage('Файл: ' + ExtractFileName(FilePath) + sLineBreak + E.Message);
      end;
    end;
  end;
begin
  // Используем уже выбранные локальные файлы.
  ProcessOneFile(Edit1);
  ProcessOneFile(Edit2);
  ProcessOneFile(Edit3);

  UpdateUIFromType;
  ShowMessage('Данные обработаны из локальных файлов.');
end;

procedure TFormTypeEditor.sbFindReestrNumberClick(Sender: TObject);
const
  REQUEST_TIMEOUT_MS = 10000;
var
  Resp: IHTTPResponse;
  Url: string;
  ResponseText: string;

  Json, ResultObj, Item: TJSONObject;
  GeneralObj: TJSONObject;
  JVal: TJSONValue;
  Items: TJSONArray;

  MPIArr: TJSONArray;
  MPIObj: TJSONObject;
  ManufacturerArr: TJSONArray;
  SpecArr: TJSONArray;
  SpecObj: TJSONObject;

  UUID: string;
  ReestrNum: string;
  DetectText: string;
  DocUrl: string;

  ValidToDate: TDate;
  RegYear: Integer;
  MPIMonths: Integer;

  FileName: string;
  FilePath: string;
  FileStream: TFileStream;
  TxtPath: string;
  JsonPath: string;
  PdfText: string;
  JsonTemplate: string;
  DeepSeekResponse: string;

  DevType: TDeviceType;
  LocalFilesProcessed: Boolean;

  P: Integer;
  YY: Integer;
  Y, M, D: Word;
  Dt: TDateTime;
begin
  if FArshinRequestInProgress then
    Exit;
  FArshinRequestInProgress := True;
  sbFindReestrNumber.Enabled := False;

  MemoLog.Visible := True;
  MemoLog.Lines.Clear;

  LocalFilesProcessed := False;

  // Если файлы выбраны вручную — сначала обрабатываем их.
  if HasLocalReestrFiles then
  begin
    if not CheckLocalReestrFiles then
      Exit;

    ProcessLocalReestrFiles;
    LocalFilesProcessed := True;
  end;

  ReestrNum := edtReestrNumber.Text.Trim;
  if ReestrNum = '' then
  begin
    if not LocalFilesProcessed then
      MemoLog.Lines.Add('ГРСИ не указан');
    Exit;
  end;

  if FType = nil then
  begin
    MemoLog.Lines.Add('Тип прибора не инициализирован');
    Exit;
  end;

  if not IsArshinReachable then
  begin
    MemoLog.Lines.Add('ERROR: нет доступа к сайту АРШИН');
    ShowMessage('Нет доступа к сайту АРШИН. Проверьте интернет-соединение и повторите попытку.');
    Exit;
  end;

  DevType := FType;

  try
    try
    {=================================================}
    { 1. Поиск ГРСИ → mit_uuid }
    {=================================================}
    Url :=
      'https://fgis.gost.ru/fundmetrology/eapi/mit/' +
      '?search=*' + TNetEncoding.URL.Encode(ReestrNum);

    NetHTTPClient1.ConnectionTimeout := REQUEST_TIMEOUT_MS;
    NetHTTPClient1.ResponseTimeout := REQUEST_TIMEOUT_MS;

    try
      Resp := NetHTTPClient1.Get(Url);
      ResponseText := Resp.ContentAsString;
    except
      on E: ENetHTTPClientException do
      begin
        MemoLog.Lines.Add('ERROR: ' + E.Message);
        ShowMessage('Нет доступа к сайту АРШИН. Проверьте интернет-соединение и повторите попытку.');
        Exit;
      end;
      on E: Exception do
      begin
        MemoLog.Lines.Add('ERROR: ' + E.Message);
        ShowMessage('Нет доступа к сайту АРШИН. Проверьте интернет-соединение и повторите попытку.');
        Exit;
      end;
    end;

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
      UUID := Item.GetValue('mit_uuid').Value;

    finally
      Json.Free;
    end;

    {=================================================}
    { 2. Загрузка карточки прибора }
    {=================================================}
    Url :=
      'https://fgis.gost.ru/fundmetrology/eapi/mit/' +
      UUID;

    try
      Resp := NetHTTPClient1.Get(Url);
      ResponseText := Resp.ContentAsString;
    except
      on E: ENetHTTPClientException do
      begin
        MemoLog.Lines.Add('ERROR: ' + E.Message);
        ShowMessage('Нет доступа к сайту АРШИН. Проверьте интернет-соединение и повторите попытку.');
        Exit;
      end;
      on E: Exception do
      begin
        MemoLog.Lines.Add('ERROR: ' + E.Message);
        ShowMessage('Нет доступа к сайту АРШИН. Проверьте интернет-соединение и повторите попытку.');
        Exit;
      end;
    end;

    MemoLog.Lines.Add('URL карточки: ' + Url);
    MemoLog.Lines.Add(ResponseText);
    MemoLog.Lines.Add('------------------------------');

    Json := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
    try
      {---------- general ----------}
      GeneralObj := Json.GetValue('general') as TJSONObject;
      if GeneralObj = nil then Exit;

      DevType.ReestrNumber :=
        GeneralObj.GetValue('number').Value;

      DevType.Name :=
        GeneralObj.GetValue('title').Value;

      DevType.CategoryName :=
        GeneralObj.GetValue('title').Value;

      {---------- Действие до ----------}
      ValidToDate := 0;
      JVal := GeneralObj.GetValue('valid_to');
      if (JVal <> nil) and (JVal.Value <> '') then
      begin
        if not TryISO8601ToDate(JVal.Value, dt, True) then
          ValidToDate := 0;
      end;
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
        AppServices.DataManager.ActiveTypeRepo
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
              try
                NetHTTPClient1.Get(DocUrl, FileStream);
                DevType.Documentation := FilePath;
                TxtPath := ChangeFileExt(FilePath, '.txt');
                if ExtractTextLayerFromPdf(FilePath, TxtPath) then
                begin
                  PdfText := TFile.ReadAllText(TxtPath, TEncoding.UTF8);
                  JsonTemplate := BuildDeepSeekTemplate(GetSelectedAccuracyClass, Trim(EditModification.Text));

                  if SendTextToDeepSeekTemplate(PdfText, JsonTemplate, DeepSeekResponse) then
                    ApplyDeepSeekJsonToType(DeepSeekResponse);
                end;
              except
                on E: ENetHTTPClientException do
                begin
                  MemoLog.Lines.Add('ERROR [' + ExtractFileName(FilePath) + ']: ' + E.Message);
                  ShowMessage('Файл: ' + ExtractFileName(FilePath) + sLineBreak + E.Message);
                end;
              end;
            finally
              FileStream.Free;
            end;

            // Конвертируем PDF в TXT только после полного закрытия потока файла.
            TxtPath := ChangeFileExt(FilePath, '.txt');
            if ExtractTextLayerFromPdf(FilePath, TxtPath) then
            begin
              PdfText := TFile.ReadAllText(TxtPath, TEncoding.UTF8);
              JsonTemplate := BuildDeepSeekTemplate(GetSelectedAccuracyClass, Trim(EditModification.Text));

              if SendTextToDeepSeekTemplate(PdfText, JsonTemplate, DeepSeekResponse) then
              begin
                JsonPath := ChangeFileExt(TxtPath, '.json');
                TFile.WriteAllText(JsonPath, DeepSeekResponse, TEncoding.UTF8);
                ApplyDeepSeekJsonToType(DeepSeekResponse);
              end;
            end;

            // Удаляем исходный PDF после успешной конвертации в текст.
            if FileExists(TxtPath) and FileExists(FilePath) then
              TFile.Delete(FilePath);
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
  finally
    sbFindReestrNumber.Enabled := True;
    FArshinRequestInProgress := False;
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
  if FPointsLocal = nil then
    FPointsLocal := FType.Points;

  if FPointsLocal <> nil then
    for I := 0 to FPointsLocal.Count-1 do
    begin
      FPointsLocal[I].RepeatsProtocol := R;
      FPointsLocal[I].Repeats := R;
      if FPointsLocal[I].State <> osNew then
        FPointsLocal[I].State := osModified;
    end;

  // -----------------------------------------------------
  // Обновляем таблицу точек через единый метод
  // -----------------------------------------------------
  UpdatePointsGrid;

  SetModified;
end;

procedure TFormTypeEditor.GridPointsCellClick(const Column: TColumn;
  const Row: Integer);
var
    P: TTypePoint;
  begin

  if Column<>CheckColumnPointEnable then
    Exit;


  P := GetPointByVisibleRow(Row);
  P.Enable:=not  P.Enable;
  UpdatePointsGrid;

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


  if ACol = CheckColumnPointEnable.Index then
    Value :=  P.Enable

  {=====================================================}
  { НЕ зависят от диаметра }
  {=====================================================}

  else if ACol = StringColumnPointName.Index then
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
        Value := FormatByBaseError(FType.FromBaseUnits(Q), P.Error);
    end

    {---------------------------}
    { V }
    {---------------------------}
    else if ACol = StringColumnPointVolume.Index then
    begin
      if P.LimitVolume > 0 then
        Value := FormatByBaseError(P.LimitVolume, P.Error)

      else if (Q > 0) and (P.LimitTime > 0) then
        Value := FormatByBaseError(Q * P.LimitTime / 3.6, P.Error)

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
  if (FType = nil) or (AppServices.DataManager.ActiveTypeRepo = nil) then
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
  if (FType = nil) or (AppServices.DataManager.ActiveTypeRepo = nil) then
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


procedure TFormTypeEditor.UpdateFlowRateFromDiameter(const D: TDiameter);
var
  DNmm: Integer;
  V: Double;
begin
  if D = nil then
    Exit;

  DNmm := StrToIntDef(D.DN, 0);
  if (DNmm > 0) and (D.Qmax > 0) then
  begin
    V := (D.Qmax / (0.002827 * Sqr(DNmm)))*3.6;
    EditFlowRate.Text := '';
    EditFlowRate.TextPrompt := FormatFloat('0.###', V);
  end
  else
  begin
    EditFlowRate.Text := '';
    EditFlowRate.TextPrompt := '-';
  end;
end;

procedure TFormTypeEditor.UpdateFlowRatePromptBySelectedDiameter;
var
  D: TDiameter;
begin
  D := GetDiameterByVisibleRow(GridDiameters.Selected);
  UpdateFlowRateFromDiameter(D);
end;

procedure TFormTypeEditor.UpdateRangeDynamicPromptBySelectedDiameter;
var
  D: TDiameter;
  Qmax, Qmin: Double;
  RangeDynamic: Integer;
begin
  // очищаем prompt по умолчанию
  EditRangeDynamic.TextPrompt := '';
  Qmin:=0;
  Qmax:=0;
  D := GetDiameterByVisibleRow(GridDiameters.Row);
  if D = nil then
    Exit;

  Qmax := D.Qmax;
  Qmin := D.Qmin;

  // считаем только если оба значения осмысленные
  if (Qmax > 0) and (Qmin > 0) and not(IsInfinite(Qmin)) and not(IsInfinite(Qmax)) then
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
  SelectedIndex: Integer;
begin
  if (AppServices.DataManager.ActiveTypeRepo = nil) or (FType = nil) then
    Exit;

  SelectedIndex := -1;

  {----------------------------------}
  { Заполняем список категорий }
  {----------------------------------}
  ceCategory.Items.BeginUpdate;
  try
    ceCategory.ItemIndex := -1;
    ceCategory.Items.Clear;

    for C in FCategoriesLocal do
    begin
      // ⛔ пропускаем служебную категорию
      if C.ID = -1 then
        Continue;

      // ✅ сохраняем ID в Objects через NativeInt — совместимо с Win64/FMХ
      ceCategory.Items.AddObject(C.Name, TObject(NativeInt(C.ID)));
      if C.ID = FType.Category then
        SelectedIndex := ceCategory.Items.Count - 1;
    end;
  finally
    ceCategory.Items.EndUpdate;
  end;

  {----------------------------------}
  { Определяем отображаемый текст }
  {----------------------------------}
  if FType.Category > 0 then
    TextValue :=
      AppServices.DataManager.ActiveTypeRepo.CategoryToText(
        FType.Category,
        FType.CategoryName
      )
  else if FType.Category = -1 then
    TextValue := FType.CategoryName
  else
    TextValue := '';

  if SelectedIndex >= 0 then
    ceCategory.ItemIndex := SelectedIndex
  else
    ceCategory.Text := TextValue;

  ceCategory.Hint := TextValue;
end;


procedure TFormTypeEditor.InitLocalData;
begin
  {----------------------------------}
  { Защита }
  {----------------------------------}
  if (FType = nil) or (AppServices.DataManager.ActiveTypeRepo = nil) then
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
   FType.SetDimensions;
   UpdateUnitsCombo;
   UpdateFreqFlowRateUnitLabel;

   cbMeasuredDimension.Hint := cbMeasuredDimension.Text;


  // ==================================================
  // СБРОС ЗАГОЛОВКОВ
  // ==================================================
  StringColumnDNQTr.Header := '';
  StringColumnDNQ2Tr.Header := '';
  StringColumnDNQmax.Header := '';
  StringColumnDNQmin.Header := '';
  StringColumnDNQnom.Header   := '';
  StringColumnDNQF.Header   := '';
  StringColumnDNKp.Header   := '';

  FloatColumnVmax.Header   := '';
  StringColumnVmin.Header  := '';

  StringColumnPointQ.Header      := '';
  StringColumnPointVolume.Header := '';

  StringColumnDNQmin.Hint := 'Q1 – минимальный расход';
  StringColumnDNQTr.Hint := 'Q2 – переходный расход';
  StringColumnDNQ2Tr.Hint := 'Q2 – переходный расход';
  StringColumnDNQnom.Hint := 'Q3 – номинальный расход';
  StringColumnDNQmax.Hint := 'Q4 – наибольший (перегрузочный) расход';
  StringColumnDNQF.Hint := 'qF – расход поверочной точки / контрольный расход';

  GridDiameters.ShowHint := True;
  StringColumnDNQmin.ShowHint := True;
  StringColumnDNQTr.ShowHint := True;
  StringColumnDNQ2Tr.ShowHint := True;
  StringColumnDNQnom.ShowHint := True;
  StringColumnDNQmax.ShowHint := True;
  StringColumnDNQF.ShowHint := True;

  // ==================================================
  // КРИТЕРИЙ ОСТАНОВКИ (cbSpillageStop)
  // ==================================================
  PopulateSpillageStopCombo(Dim);
  cbSpillageStop.ItemIndex := SpillageStopValueToItemIndex(FType.SpillageStop);

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

procedure TFormTypeEditor.UpdateUnitsCombo;
var
  I: Integer;
begin
  ComboBoxUnits.Items.Clear;

  if (FType = nil) or (FType.Dimensions = nil) then
  begin
    ComboBoxUnits.ItemIndex := -1;
    Exit;
  end;

  for I := 0 to FType.Dimensions.Count - 1 do
    ComboBoxUnits.Items.Add(FType.Dimensions[I].Name);

  if (FType.Units >= 0) and (FType.Units < ComboBoxUnits.Items.Count) then
    ComboBoxUnits.ItemIndex := FType.Units
  else if ComboBoxUnits.Items.Count > 0 then
    ComboBoxUnits.ItemIndex := 0
  else
    ComboBoxUnits.ItemIndex := -1;

  ComboBoxUnits.Hint := ComboBoxUnits.Text;

  if FPopupMenuGridDiametersHeader <> nil then
    CreateMenu;
end;

procedure TFormTypeEditor.ApplyVolumeMode;
begin
  FType.SetDimensions;
  // ===== Диаметры =====
  StringColumnDNQmin.Header := 'Qmin '+ FType.GetDimensionName;
  StringColumnDNQTr.Header := 'Qtr '+ FType.GetDimensionName;
  StringColumnDNQ2Tr.Header := 'Q2Tr '+ FType.GetDimensionName;
  StringColumnDNQnom.Header := 'Qnom '+ FType.GetDimensionName;
  StringColumnDNQmax.Header := 'Qmax '+ FType.GetDimensionName;
  StringColumnDNQF.Header   := 'QF '+ FType.GetDimensionName;
  StringColumnDNKp.Header   := 'Kp, имп/л';

  FloatColumnVmax.Header   := 'Vmax, л';
  StringColumnVmin.Header  := 'Vmin, л';

  // ===== Поверочные точки =====
  StringColumnPointQ.Header      := 'Q, ' + FType.GetDimensionName;
  StringColumnPointVolume.Header := 'V, л';

  // ===== Критерий остановки =====
  FillSpillageStopVolume;

  // ===== Представление коэффициента =====
  FillConversionCoefVolume;
end;

procedure TFormTypeEditor.ApplyMassMode;
begin
  FType.SetDimensions;
  // ===== Диаметры =====
  StringColumnDNQmin.Header := 'Qmin '+ FType.GetDimensionName;
  StringColumnDNQTr.Header := 'Qtr '+ FType.GetDimensionName;
  StringColumnDNQ2Tr.Header := 'Q2Tr '+ FType.GetDimensionName;
  StringColumnDNQnom.Header := 'Qnom '+ FType.GetDimensionName;
  StringColumnDNQmax.Header := 'Qmax '+ FType.GetDimensionName;
  StringColumnDNQF.Header   := 'QF '+ FType.GetDimensionName;
  StringColumnDNKp.Header   := 'Kp, имп/кг';

  FloatColumnVmax.Header   := 'Mmax, кг';
  StringColumnVmin.Header  := 'Mmin, кг';

  // ===== Поверочные точки =====
  StringColumnPointQ.Header      := 'Q, ' + FType.GetDimensionName;
  StringColumnPointVolume.Header := 'M, кг';

  // ===== Критерий остановки =====
  FillSpillageStopMass;

  // ===== Представление коэффициента =====
  FillConversionCoefMass;
end;

procedure TFormTypeEditor.FillSpillageStopVolume;
begin
  PopulateSpillageStopCombo(mdVolume);
  cbSpillageStop.ItemIndex := SpillageStopValueToItemIndex(FType.SpillageStop);
end;

procedure TFormTypeEditor.FillSpillageStopMass;
begin
  PopulateSpillageStopCombo(mdMass);
  cbSpillageStop.ItemIndex := SpillageStopValueToItemIndex(FType.SpillageStop);
end;

function TFormTypeEditor.GetStopVolumeCaption(const ADim: TMeasuredDimension): string;
begin
  case ADim of
    mdVolumeFlow,
    mdVolume:
      Result := 'Объем, л';
    mdMassFlow,
    mdMass:
      Result := 'Масса, кг';
    mdSpeed:
      Result := 'Скорость';
    mdHeat:
      Result := 'Теплота';
  else
    Result := 'Объем/масса';
  end;
end;

procedure TFormTypeEditor.PopulateSpillageStopCombo(const ADim: TMeasuredDimension);
var
  VolumeCaption: string;
begin
  VolumeCaption := GetStopVolumeCaption(ADim);
  cbSpillageStop.Items.BeginUpdate;
  try
    cbSpillageStop.Items.Clear;
    cbSpillageStop.Items.Add('Время');
    cbSpillageStop.Items.Add('Импульсы');
    cbSpillageStop.Items.Add(VolumeCaption);
    cbSpillageStop.Items.Add('Время + импульсы');
    cbSpillageStop.Items.Add('Время + ' + LowerCase(VolumeCaption));
    cbSpillageStop.Items.Add('Импульсы + ' + LowerCase(VolumeCaption));
    cbSpillageStop.Items.Add('Время + импульсы + ' + LowerCase(VolumeCaption));
  finally
    cbSpillageStop.Items.EndUpdate;
  end;
end;



function TFormTypeEditor.SpillageStopValueToItemIndex(const AValue: Integer): Integer;
begin
  case AValue of
    STOP_BY_TIME: Result := 0;
    STOP_BY_IMP: Result := 1;
    STOP_BY_VOLUME: Result := 2;
    STOP_BY_TIME or STOP_BY_IMP: Result := 3;
    STOP_BY_TIME or STOP_BY_VOLUME: Result := 4;
    STOP_BY_IMP or STOP_BY_VOLUME: Result := 5;
    STOP_BY_TIME or STOP_BY_IMP or STOP_BY_VOLUME: Result := 6;
  else
    Result := 0;
  end;
end;



function TFormTypeEditor.SpillageStopItemIndexToValue(const AIndex: Integer): Integer;
begin
  case AIndex of
    0: Result := STOP_BY_TIME;
    1: Result := STOP_BY_IMP;
    2: Result := STOP_BY_VOLUME;
    3: Result := STOP_BY_TIME or STOP_BY_IMP;
    4: Result := STOP_BY_TIME or STOP_BY_VOLUME;
    5: Result := STOP_BY_IMP or STOP_BY_VOLUME;
    6: Result := STOP_BY_TIME or STOP_BY_IMP or STOP_BY_VOLUME;
  else
    Result := STOP_BY_TIME;
  end;
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
    0:
    begin
    tcOutPutType.ActiveTab := tiFrequency;  // Частота
    UpdateUIFreq;
    end;
    1:
    begin
    tcOutPutType.ActiveTab := tiImpulse;    // Импульсы
    UpdateUICoef;
    end;
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
        StringColumnDNQnom.Visible   := True;
        StringColumnDNQF.Visible     := True;
      end;
  else
    begin
      StringColumnDNKp.Visible       := False;
      StringColumnPointImp.Visible   := False;
      StringColumnDNQnom.Visible   := False;
      StringColumnDNQF.Visible     := False;
    end;
  end;

  // При загрузке из АРШИН ApplyOutputType может снова сделать
  // некоторые колонки видимыми. Повторно применяем автоскрытие.
  if FArshinRequestInProgress then
    AutoHideEmptyDiameterColumns;
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

procedure TFormTypeEditor.UpdateFreqFlowRateUnitLabel;
begin
  if (Label38 = nil) or (FType = nil) then
    Exit;

  Label38.Text := 'Расход, QF/Qmax, ' + FType.GetDimensionName;
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
  if (AppServices.DataManager.ActiveTypeRepo = nil) then
    Exit;

  {----------------------------------}
  { Получаем категории из репозитория }
  {----------------------------------}
  if FCategoriesLocal = nil then
    FCategoriesLocal := TObjectList<TDeviceCategory>.Create(False)
  else
    FCategoriesLocal.Clear;

  for C in AppServices.DataManager.ActiveTypeRepo.Categories do
    FCategoriesLocal.Add(C);

  {----------------------------------}
  { Заполняем ComboBox }
  {----------------------------------}
    InitCategoryComboEdit;


end;

procedure TFormTypeEditor.UpdateUICoef;
begin
  // =====================================================
  // == Представление коэффициента
  // =====================================================
  if (FType.DimensionCoef >= 0) and (FType.DimensionCoef < cbCoefViewType.Items.Count) then
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
end;

procedure TFormTypeEditor.UpdateUIFreq;
begin
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
  UpdateFreqFlowRateUnitLabel;
  EditFreqFlowRate.Text := '';
  EditFreqFlowRate.TextPrompt := '';
  if FType.FreqFlowRate > 0 then
    EditFreqFlowRate.Text := FloatToStr(FType.FreqFlowRate)
  else
    EditFreqFlowRate.TextPrompt := '-';
end;


end.
