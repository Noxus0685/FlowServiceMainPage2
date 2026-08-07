unit frmProceed;

interface

uses
  uGridStabilityRegistry,
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Colors,
  FMX.Dialogs,
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
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.TreeView,
  FMX.Types,
  FMX.SimpleChart,
  frmCalibrCoefs,
  fuDeviceSelect,
  System.Actions,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.IniFiles,
  System.IOUtils,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uBaseProcedures,
  uClasses,
  uDataManager,
  uDeviceClass,
  uFlowMeter,
  uRepositories,
  uProtocols,
  uWorkTable,
  uMKSDebug,
  uMeasurementRun,
  uGridLayoutManager;

type
  // Направление сортировки таблицы обработки.
  TGridSortDirection = (gsdNone, gsdAscending, gsdDescending);

  // Способ соединения усреднённых метрологических точек.
  TChartAverageLineMode = (calmPchipLogQ, calmLinearSegments);
  // Способ отображения физического расхода по оси X.
  TChartFlowScale = (cfsLogarithmic, cfsLinear);

  // Хранит выбранный цвет и UUID прибора в динамическом пункте ПКМ графика.
  TChartDeviceColorMenuItem = class(TMenuItem)
  public
    DeviceUUID: string;
    NewColor: TAlphaColor;
  end;

  TProceedResultPointColumn = record
    Header: string;
    DeviceUUID: string;
    SourcePointUUID: string;
    ScenarioPoint: TDevicePoint;
    // Расход merged-колонки Summary, рассчитанный по сохранённым проливкам обработки; не зависит от MeasurementRun.Points.
    TargetFlow: Double;
    EtalonUUID: string;
    SourcePointName: string;
    SourcePointNum: Integer;
    IsMerged: Boolean;
    CommonMinQ: Double;
    CommonMaxQ: Double;
    MinEtalonDeltaQ: Double;
    EtalonRangeValid: Boolean;
    MergedSpillageNames: string;
    GroupedSpillages: TArray<TPointSpillage>;
    SelectedSpillage: TPointSpillage;
    SelectionReason: string;
  end;

  TResultGridRow = record
    Device: TDevice;
    Name: string;
    DeviceType: string;
    Serial: string;
    DeviceUUID: string;
    PointNames: TArray<string>;
    PointValues: TArray<string>;
    PointColors: TArray<TAlphaColor>;
    ResultText: string;
    ResultComment: string;
    ResultStatus: Integer;
  end;

  TFrameProceed = class(TFrame)
    LayoutMiddle: TLayout;
    LayoutCenter: TLayout;
    Layout18: TLayout;
    GridDataPoints: TGrid;
    CheckColumnSpillageEnable: TCheckColumn;
    StringColumnSpillageNum: TStringColumn;
    StringColumnName: TStringColumn;
    StringColumnSpillageDateTime: TStringColumn;
    StringColumnSpillageOperator: TStringColumn;
    StringColumnSpillageEtalonName: TStringColumn;
    StringColumnSpillageSpillTime: TStringColumn;
    StringColumnSpillageQavgEtalon: TStringColumn;
    StringColumnSpillageEtalonVolume: TStringColumn;
    StringColumnSpillageQEtalonStd: TStringColumn;
    StringColumnSpillageQEtalonCV: TStringColumn;
    StringColumnSpillageDeviceFlowRate: TStringColumn;
    StringColumnSpillageDeviceVolume: TStringColumn;
    StringColumnSpillageVelocity: TStringColumn;
    StringColumnSpillageError: TStringColumn;
    StringColumnSpillageValid: TStringColumn;
    StringColumnSpillageComment: TStringColumn;
    StringColumnSpillageQStd: TStringColumn;
    StringColumnSpillageQCV: TStringColumn;
    StringColumnSpillageVolumeBefore: TStringColumn;
    StringColumnSpillageVolumeAfter: TStringColumn;
    StringColumnSpillagePulseCount: TStringColumn;
    StringColumnSpillageMeanFrequency: TStringColumn;
    StringColumnSpillageAvgCurrent: TStringColumn;
    StringColumnSpillageAvgVoltage: TStringColumn;
    StringColumnSpillageData1: TStringColumn;
    StringColumnSpillageData2: TStringColumn;
    StringColumnSpillageStartTemperature: TStringColumn;
    StringColumnSpillageEndTemperature: TStringColumn;
    StringColumnSpillageAvgTemperature: TStringColumn;
    StringColumnSpillageInputPressure: TStringColumn;
    StringColumnSpillageOutputPressure: TStringColumn;
    StringColumnSpillageDeltaPressure: TStringColumn;
    StringColumnSpillageDensity: TStringColumn;
    StringColumnSpillageAmbientTemperature: TStringColumn;
    StringColumnSpillageAtmosphericPressure: TStringColumn;
    StringColumnSpillageRelativeHumidity: TStringColumn;
    StringColumnSpillageCoef: TStringColumn;
    StringColumnSpillageFCDCoefficient: TStringColumn;
    StringColumnSpillageArchivedData: TStringColumn;
    GridResults: TGrid;
    StringColumnResultName: TStringColumn;
    StringColumnResultType: TStringColumn;
    StringColumnResultSerial: TStringColumn;
    StringColumnPointNum1: TStringColumn;
    StringColumnPointNum2: TStringColumn;
    StringColumnPointNum3: TStringColumn;
    StringColumnPointNum4: TStringColumn;
    StringColumnResult: TStringColumn;
    StringColumnResultComment: TStringColumn;
    MemoLog: TMemo;
    LayoutLeft: TLayout;
    TreeViewDevices: TTreeView;
    TreeViewItem1: TTreeViewItem;
    TreeViewItem2: TTreeViewItem;
    TreeViewItem3: TTreeViewItem;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    LayoutRight: TLayout;
    Panel1: TPanel;
    TabControlSessionProperties: TTabControl;
    TabItemSessionProperties: TTabItem;
    LayoutSessionProperties: TLayout;
    LabelCoefs: TLabel;
    LabelSessionDate: TLabel;
    Chart1: TSimpleChart;
    LabelSessionActive: TLabel;
    TabItemCalculations: TTabItem;
    GridCoefs: TGrid;
    StringColumnCoefTableName: TStringColumn;
    StringColumn2: TStringColumn;
    TabItemCalibrCoefs: TTabItem;
    TabItemReport: TTabItem;
    LayoutTop: TLayout;
    ToolBarDataPoints: TToolBar;
    Line4: TLine;
    Layout32: TLayout;
    ButtonSessionDeleteDataPoint: TButton;
    ButtonSessionNew: TButton;
    ButtonSessionClearPoints: TButton;
    ButtonSessionClose: TButton;
    ButtonSessionSynchTable: TButton;
    Layout19: TLayout;
    Layout20: TLayout;
    ComboBoxUnitsResult: TComboBox;
    Line7: TLine;
    ToolBarResults: TToolBar;
    Layout22: TLayout;
    Label7: TLabel;
    Line8: TLine;
    Layout23: TLayout;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Line9: TLine;
    lyt1: TLayout;
    ActionListWorkTables: TActionList;
    ActionSessionDelete: TAction;
    ActionSessionClose: TAction;
    ActionSessionPointDelete: TAction;
    ActionSessionPointsClear: TAction;
    ActionSessionActive: TAction;
    ActionSessionNew: TAction;
    ActionSessionSynchTable: TAction;
    PopupMenuTreeViewDevices: TPopupMenu;
    PopupMenuGridDataPoints: TPopupMenu;
    MenuItemGridDataPointsDelete: TMenuItem;
    MenuItemGridDataPointsClear: TMenuItem;
    MenuItemGridDataPointsClose: TMenuItem;
    MenuItemGridDataPointsColumns: TMenuItem;
    PopupMenuGridResults: TPopupMenu;
    PopupMenuChart: TPopupMenu;
    MenuItemChartDevices: TMenuItem;
    MenuItemChartSettings: TMenuItem;
    MenuItemChartLineMode: TMenuItem;
    MenuItemChartLinePchip: TMenuItem;
    MenuItemChartLineSegments: TMenuItem;
    MenuItemChartScale: TMenuItem;
    MenuItemChartScaleLog: TMenuItem;
    MenuItemChartScaleLinear: TMenuItem;
    MenuItemGridResultsDelete: TMenuItem;
    MenuItemGridResultsClear: TMenuItem;
    MenuItemGridResultsClose: TMenuItem;
    MenuItemGridResultsColumns: TMenuItem;
    ActionSessionDeviceRemove: TAction;
    ActionSessionDeviceAdd: TAction;
    ActionDeleteWorkTable: TAction;
    ActionDeleteSelectedWorkTables: TAction;
    ActionRemoveInvalidAndExcessMeasurements: TAction;
    btnCancel: TCornerButton;
    ButtonExportExcel: TButton;
    ButtonRemoveInvalidAndExcessMeasurements: TButton;
    function FindProcessingDeviceByUUID(const ADeviceUUID: string): TDevice;
    function GetActiveVisibleSession(ADevice: TDevice): TSessionSpillage;
    function HasDeviceInProcessing(ADevice: TDevice): Boolean;
    procedure AddProcessingDevice(ADevice: TDevice);
    procedure RemoveProcessingDevice(ADevice: TDevice);
    procedure MarkProcessingDeviceRemoved(ADevice: TDevice);
    procedure ApplyProcessingDeviceRemovals;
    function IsProcessingDevicePendingRemoved(ADevice: TDevice): Boolean;
    procedure MarkProcessingDeviceDeleted(ADevice: TDevice);
    function GetDeviceSpillageCount(ADevice: TDevice): Integer;
    // Возвращает дату последней проливки прибора для сортировки результатов обработки.
    function GetLastSpillageDate(ADevice: TDevice): TDateTime;
    // Сортирует загруженные данные обработки по дате выполнения измерений.
    procedure SortProcessingDataByDate;
    procedure SaveProcessingPointCounts;
    procedure SaveProcessingDevices;
    procedure LoadManualProcessingDevices;
    procedure SaveManualProcessingDevices;
    procedure MarkProcessingDeviceManual(ADevice: TDevice);
    function IsManualProcessingDevice(ADevice: TDevice): Boolean;
    procedure SavePendingProcessingChanges(Sender: TObject);
    procedure CancelProcessingChanges;
    procedure LoadProcessingDevices;
    procedure UpdateTreeViewDeviceTagObjects;
    procedure AddProcessingDeviceFromSelection;
    procedure DbgProceedTree(const ACode: Integer; const AText: string);
    function GetSelectedTreeDebugText: string;
    function GetProcessingDevicesDebugText: string;
    procedure RefreshResultsAfterDevicesAction;
    function FindTreeItemByTagObject(ATagObject: TObject): TTreeViewItem;
    procedure SelectTreeItemByTagObject(ATagObject: TObject);
    procedure RefreshMeasurementsAfterSessionAction(ADevice: TDevice; ASession: TSessionSpillage);
    procedure UpdateSessionItems;
    procedure PopulateTreeViewDevices;
    function GetStatusColor(const AStatus: Integer): TAlphaColor;
    function BuildResultTextByStatus(const AStatus: Integer): string;
    function BuildResultComment(ADevice: TDevice; const AStatus: Integer): string;
    function BuildSpillageStatusText(ASpillage: TPointSpillage): string;
    function BuildSpillageCommentText(ASpillage: TPointSpillage): string;
    function GetSpillageErrorResultColor(ASpillage: TPointSpillage): TAlphaColor;
    function ResolveDeviceSummaryStatus(ADevice: TDevice): Integer;
    // Принудительно синхронизирует видимость статических и динамических point-колонок GridResults с FResultPointColumns после построения и после загрузки layout.
    procedure NormalizeResultsPointColumnsVisibility;
    procedure UpdateResultsPointColumns;
    function CreateResultsGridColumn(AOwner: TComponent;
      ADefinition: TGridColumnDefinition): TColumn;
    function FindResultPointForColumn(ADevice: TDevice; const AColumn: TProceedResultPointColumn): TDevicePoint;
    // Проверяет принадлежность сохранённой проливки merged-колонке Summary по расходу и признакам эталона; не зависит от TMeasurementRun.Points.
    function IsProcessingSpillageInMergedColumn(ASpillage: TPointSpillage; const AColumn: TProceedResultPointColumn): Boolean;
    // Возвращает все проливки прибора для Summary-колонки обработки; в merged-режиме сохраняет всех участников объединённой точки.
    function FindResultSpillagesForColumn(ADevice: TDevice; const AColumn: TProceedResultPointColumn): TArray<TPointSpillage>;
    // Возвращает одну проливку прибора для Summary-колонки обработки; используется для старых call-site, где нужен представитель.
    function FindResultSpillageForColumn(ADevice: TDevice; const AColumn: TProceedResultPointColumn): TPointSpillage;
    function IsValidSummaryResultSpillage(ASpillage: TPointSpillage; out ASkipReason: string): Boolean;
    procedure LogSummaryResultSelection(const AGroupName: string; ACandidate: TPointSpillage;
      const AIsValid: Boolean; const ASkipReason: string; ASelected: TPointSpillage;
      const ASelectionReason: string);
    function FormatMergedSummarySeriesResults(const AColumn: TProceedResultPointColumn; const ASpillages: TArray<TPointSpillage>; out ASelectedSpillages: TArray<TPointSpillage>): string;
    procedure BuildSummaryColumnsWithoutMerge(const ADevices: TList<TDevice>);
    procedure BuildSummaryColumnsWithMerge(const ADevices: TList<TDevice>);
    procedure BuildSummaryResultPointColumns(const ADevices: TList<TDevice>; const AMergePoints: Boolean);
    procedure LogResultCellDebug(const ARow: TResultGridRow; APoint: TDevicePoint; ASpillage: TPointSpillage; const ACellValue: string);
    procedure ShowAllDevicesResults;
    procedure ShowDevicesResults(const ADevices: TList<TDevice>);
    procedure ShowWorkTableResults(AWorkTable: TWorkTable);
    procedure ShowOtherDevicesResults;
    procedure UpdateGridResults;
    procedure UpdateGridDataPoints;
    function BuildCurrentSpillagesList: TObjectList<TPointSpillage>;
    procedure ShowDeviceSpillages(ADevice: TDevice);
    procedure ShowSessionSpillages(ASession: TSessionSpillage);
    function ResolveSelectedDevice: TDevice;
    procedure PopupMenuTreeViewDevicesPopup(Sender: TObject);
    procedure MenuTreeViewDevicesEditClick(Sender: TObject);
    procedure PopupMenuGridResultsPopup(Sender: TObject);
    procedure BuildGridColumnsMenu(AGrid: TGrid; AColumnsMenu: TMenuItem);
    procedure GridColumnMenuClick(Sender: TObject);
    procedure GridColumnsResetClick(Sender: TObject);
    procedure ButtonExportExcelClick(Sender: TObject);
    procedure MenuTreeViewDevicesClearClick(Sender: TObject);
    procedure SyncProcessingDevicesFromTable(AWorkTable: TWorkTable; const AClearBeforeSync: Boolean);
    procedure SyncProcessingDevicesWithNewPoints;
    procedure SyncProcessingDevicesFromAllTables(const AClearBeforeSync: Boolean);
    procedure ActionSessionSynchTableExecute(Sender: TObject);
    procedure MenuTreeViewDevicesAddClick(Sender: TObject);
    procedure MenuTreeViewDevicesDeleteClick(Sender: TObject);
    // Проверяет, что выбранный узел дерева является рабочим столом.
    function IsSelectedTreeWorkTable(out AWorkTable: TWorkTable): Boolean;
    procedure ClearCurrentResultsView;
    procedure RefreshAfterWorkTableDeletion;
    // Возвращает измерения, которые не удалось сопоставить с поверочной точкой.
    function FindUnassignedMeasurements: TArray<TPointSpillage>;
    // Возвращает измерения, превышающие количество повторов поверочной точки.
    function FindExcessMeasurements: TArray<TPointSpillage>;
    // Удаляет неподключённые измерения и превышающие количество повторов согласно настройкам поверочных точек.
    procedure RemoveInvalidAndExcessMeasurements;
    procedure ActionRemoveInvalidAndExcessMeasurementsExecute(Sender: TObject);
    procedure MenuTreeViewDevicesDeleteWorkTableClick(Sender: TObject);
    procedure ActionDeleteWorkTableExecute(Sender: TObject);
    procedure ActionDeleteWorkTableUpdate(Sender: TObject);
    procedure ActionDeleteSelectedWorkTablesExecute(Sender: TObject);
    procedure ActionDeleteSelectedWorkTablesUpdate(Sender: TObject);
    procedure ActionSessionDeleteExecute(Sender: TObject);
    procedure ActionSessionDeviceAddExecute(Sender: TObject);
    procedure ActionSessionDeviceRemoveExecute(Sender: TObject);
    procedure ActionSessionCloseExecute(Sender: TObject);
    procedure ActionSessionPointDeleteExecute(Sender: TObject);
    procedure ActionSessionPointsClearExecute(Sender: TObject);
    procedure ActionSessionActiveExecute(Sender: TObject);
    procedure ActionSessionNewExecute(Sender: TObject);
    procedure TreeViewDevicesChange(Sender: TObject);
    procedure TreeViewDevicesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    function GetSelectedResultDevice: TDevice;
    function CanDeleteSelectedDataPoint(const AOwner: TObject): Boolean;
    function GetDeleteButtonHint: string;
    function DeleteSelectedDataPointWithRules(const AOwner: TObject): Boolean;
    procedure ButtonSessionClearPointsClick(Sender: TObject);
    procedure ButtonSessionCancelClick(Sender: TObject);
    procedure ButtonSessionDeleteDataPointClick(Sender: TObject);
    procedure GridResultsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridResultsDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure GridResultsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure GridResultsSelChanged(Sender: TObject);
    procedure GridDataPointsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridDataPointsCellClick(const Column: TColumn; const Row: Integer);
    procedure GridDataPointsDrawColumnCell(Sender: TObject; const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF; const Row: Integer; const Value: TValue; const State: TGridDrawStates);
    procedure GridDataPointsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    // Обрабатывает выбор пользователем колонки сортировки таблицы обработки.
    procedure GridDataPointsHeaderClick(Column: TColumn);
    procedure UpdateGridDataPointsHeaders(QuantityDimName: string; FlowDimName: string);
    procedure SetSessionDim(UnitName: string; QuantityUnitName: string);
    procedure ComboBoxUnitsResultChange(Sender: TObject);
    // Формирует пункты видимости и цветов приборов до открытия ПКМ графика.
    procedure Chart1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ChartDeviceVisibilityMenuClick(Sender: TObject);
    // Открывает выбор цвета исходных точек выбранного в ПКМ прибора.
    procedure ChartPointColorMenuClick(Sender: TObject);
    // Открывает выбор цвета усреднённой линии выбранного в ПКМ прибора.
    procedure ChartLineColorMenuClick(Sender: TObject);
    // Переключает алгоритм линии средних значений и перестраивает график.
    procedure ChartLineModeMenuClick(Sender: TObject);
    // Переключает линейное/логарифмическое отображение оси расхода.
    procedure ChartScaleMenuClick(Sender: TObject);
    procedure UpdateCalibrCoefsFrame;
    procedure ResetPointDeleteConfirm;
    procedure InitCalibrCoefsFrame;
    procedure SetGridReadOnly(AGrid: TGrid);
    procedure UpdateActionHints;
    function GetSpillageResultHint(ADevice: TDevice;
      APoint: TPointSpillage): string;
    function GetDeviceResultHint(ADevice: TDevice): string;
    procedure GridResultsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Single);
    procedure GridDataPointsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Single);
    procedure GridColumnLayoutMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure LogProceedGridContext(const AContext: string; ADevice: TDevice;
      ASession: TSessionSpillage; ARows, AColumns: Integer);

    procedure CaptureGridColumnsLayout(AGrid: TGrid; out AColumns: TArray<TGridColumnLayout>);
    procedure ApplyGridColumnsLayout(AGrid: TGrid;
      const AColumns: TArray<TGridColumnLayout>);
    procedure SaveLayoutSettingsToWorkTable;
    procedure GridDataPointsColumnMoved(Column: TColumn; FromIndex,
      ToIndex: Integer);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FFrameCalibrCoefs: TFrameCalibrCoefs;
    FWorkTableManager: TWorkTableManager;
    FProcessingDevices: TObjectList<TDevice>;
    FManualProcessingDeviceUUIDs: TStringList;
    FPendingRemovedProcessingUUIDs: TStringList;
    FCurrentSession: TSessionSpillage;
    FCurrentResultRows: TArray<TResultGridRow>;
    FCurrentSpillages: TArray<TPointSpillage>;
    FResultPointColumns: TArray<TProceedResultPointColumn>;
    FActiveWorkTable: TWorkTable;
    FSessionDevice: TFlowMeter;
    FSessionEtalon: TFlowMeter;
    FSkipPointDeleteConfirm: Boolean;
    FPointDeleteOwner: TObject;
    FProcessingChangesSaved: Boolean;
    FOnResultsSynchronized: TNotifyEvent;
    FLastResultsHintRow: Integer;
    FLastResultsHintCol: Integer;
    FLastDataPointsHintRow: Integer;
    FLastDataPointsHintCol: Integer;
    FApplyingGridColumnsLayout: Boolean;
    FResultsGridLayoutState: TGridLayoutState;
    // Текущая сортировка таблицы точек обработки.
    FGridDataPointsSortColumn: string;
    FGridDataPointsSortDirection: TGridSortDirection;
    FChartPointColors: TDictionary<string, TAlphaColor>;
    FChartLineColors: TDictionary<string, TAlphaColor>;
    FChartDeviceVisibility: TDictionary<string, Boolean>;
    FChartAverageLineMode: TChartAverageLineMode;
    FChartFlowScale: TChartFlowScale;
    // Перестраивает зависимости погрешности от расхода для текущих сессий приборов.
    procedure UpdateSessionErrorChart;
    function GetChartDeviceColor(ADevice: TDevice; const ALineColor: Boolean;
      const ADefaultIndex: Integer): TAlphaColor;
    // Возвращает сохранённую видимость прибора на графике.
    function IsChartDeviceVisible(ADevice: TDevice): Boolean;
  public
    { Public declarations }
    procedure Initialize;
    procedure RefreshResultsTab;
    function RequestClearActiveSession(ADevice: TDevice): Boolean;
    function RequestCreateSession(ADevice: TDevice): TSessionSpillage;
    function RequestClearActiveSessions: Boolean;
    function RequestCreateSessions: Boolean;
    function CanManageResultSessions: Boolean;
    function FindResultSpillageForPoint(ADevice: TDevice; APoint: TDevicePoint): TPointSpillage;
    function GetPointResultError(const ADevice: TDevice; const APoint: TDevicePoint): Double;
    function GetPointResultFlowLS(const ADevice: TDevice; const APoint: TDevicePoint): Double;
    // Проверяет, содержит ли результат рассчитанную конечную погрешность.
    function IsResultErrorValid(const AValue: Double): Boolean;
    // Форматирует рассчитанную погрешность штатным GetStrNum прибора.
    function FormatResultErrorValue(const AValue: Double): string;
    function GetPointResultColor(ADevice: TDevice; ADevicePoint: TDevicePoint;
      ASpillage: TPointSpillage): TAlphaColor;
    function GetDeviceResultText(ADevice: TDevice): string;
    function GetDeviceResultColor(ADevice: TDevice): TAlphaColor;
    destructor Destroy; override;
    property OnResultsSynchronized: TNotifyEvent read FOnResultsSynchronized
      write FOnResultsSynchronized;
  end;

implementation
   uses
    uAppServices,
    uMeterValue,
    fuDeviceEdit,
    uGridXlsxExporter;
{$R *.fmx}

const
  CProcessingDevicesSection = 'ProcessingDevices';
  CProcessingDevicesCountKey = 'Count';
  CProcessingDevicesItemKeyPrefix = 'Item';
  CProcessingDevicePointCountsSection = 'ProcessingDevicePointCounts';
  CManualProcessingDevicesSection = 'ManualProcessingDevices';
  CVolumeFlowUnits: array[0..4] of string = ('л/с','л/мин','л/ч','м3/мин','м3/ч');
  CMassFlowUnits: array[0..4] of string = ('кг/с','кг/мин','кг/ч','т/мин','т/ч');

function IsVolumeFlowUnit(const AUnit: string): Boolean;
var
  I: Integer;
begin
  for I := Low(CVolumeFlowUnits) to High(CVolumeFlowUnits) do
    if SameText(AUnit, CVolumeFlowUnits[I]) then
      Exit(True);
  Result := False;
end;

function ResolveQuantityUnitByFlowUnit(const AUnit: string): string;
begin
  if SameText(AUnit, 'л/с') or SameText(AUnit, 'л/мин') or SameText(AUnit, 'л/ч') then
    Exit('л');
  if SameText(AUnit, 'м3/мин') or SameText(AUnit, 'м3/ч') then
    Exit('м3');
  if SameText(AUnit, 'кг/с') or SameText(AUnit, 'кг/мин') or SameText(AUnit, 'кг/ч') then
    Exit('кг');
  if SameText(AUnit, 'т/мин') or SameText(AUnit, 'т/ч') then
    Exit('т');
  Result := '';
end;

// Переводит базовый расход (л/с либо кг/с) в выбранную единицу графика.
function ConvertBaseFlowToUnit(const AValue: Double;
  const AUnit: string): Double;
begin
  if SameText(AUnit, 'л/мин') or SameText(AUnit, 'кг/мин') then
    Exit(AValue * 60);
  if SameText(AUnit, 'л/ч') or SameText(AUnit, 'кг/ч') then
    Exit(AValue * 3600);
  if SameText(AUnit, 'м3/мин') or SameText(AUnit, 'т/мин') then
    Exit(AValue * 0.06);
  if SameText(AUnit, 'м3/ч') or SameText(AUnit, 'т/ч') then
    Exit(AValue * 3.6);
  Result := AValue;
end;

function ResolveManagerWorkTable(AWorkTableManager: TWorkTableManager): TWorkTable;
begin
  Result := nil;
  if (AWorkTableManager = nil) or (AWorkTableManager.WorkTables = nil) or
     (AWorkTableManager.WorkTables.Count = 0) then
    Exit;

  Result := AWorkTableManager.ActiveWorkTable;
end;

destructor TFrameProceed.Destroy;
begin
  // Сохраняем ширину, порядок и видимость столбцов перед закрытием формы.
  SaveLayoutSettingsToWorkTable;
  if Assigned(AppServices) then
    AppServices.OnBeforeShutdown := nil;

  FreeAndNil(FFrameCalibrCoefs);
  FreeAndNil(FSessionDevice);
  FreeAndNil(FSessionEtalon);
  FreeAndNil(FProcessingDevices);
  FreeAndNil(FManualProcessingDeviceUUIDs);
  FreeAndNil(FPendingRemovedProcessingUUIDs);
  FreeAndNil(FResultsGridLayoutState);
  FreeAndNil(FChartPointColors);
  FreeAndNil(FChartLineColors);
  FreeAndNil(FChartDeviceVisibility);
  inherited;
end;

procedure TFrameProceed.Initialize;
var
  UnitName: string;
begin
  RegisterStableGrid(Self, GridResults, Name);
  RegisterStableGrid(Self, GridDataPoints, Name);
  RegisterStableGrid(Self, GridCoefs, Name);
  if FResultsGridLayoutState = nil then
    FResultsGridLayoutState := TGridLayoutState.Create;
  FResultsGridLayoutState.ConfigureWidthControl(GridResults,
    ClassName + '.' + GridResults.Name);
  FWorkTableManager := WorkTableManager;
  FActiveWorkTable := ResolveManagerWorkTable(FWorkTableManager);

  if FProcessingDevices = nil then
    FProcessingDevices := TObjectList<TDevice>.Create(False);
  if FManualProcessingDeviceUUIDs = nil then
  begin
    FManualProcessingDeviceUUIDs := TStringList.Create;
    FManualProcessingDeviceUUIDs.Sorted := False;
    FManualProcessingDeviceUUIDs.Duplicates := dupIgnore;
  end;
  if FPendingRemovedProcessingUUIDs = nil then
  begin
    FPendingRemovedProcessingUUIDs := TStringList.Create;
    FPendingRemovedProcessingUUIDs.Sorted := False;
    FPendingRemovedProcessingUUIDs.Duplicates := dupIgnore;
  end;
  if FChartPointColors = nil then
    FChartPointColors := TDictionary<string, TAlphaColor>.Create;
  if FChartLineColors = nil then
    FChartLineColors := TDictionary<string, TAlphaColor>.Create;
  if FChartDeviceVisibility = nil then
    FChartDeviceVisibility := TDictionary<string, Boolean>.Create;

  if Chart1 <> nil then
  begin
    Chart1.PopupMenu := nil;
    Chart1.OnMouseDown := Chart1MouseDown;
    Chart1.Title := 'Погрешность от расхода';
    Chart1.XTitle := 'Расход';
    Chart1.YTitle := 'Погрешность, %';
    Chart1.ShowLegend := True;
    Chart1.LogarithmicX := FChartFlowScale = cfsLogarithmic;
  end;

  if MenuItemChartLinePchip <> nil then
    MenuItemChartLinePchip.IsChecked := FChartAverageLineMode = calmPchipLogQ;
  if MenuItemChartLineSegments <> nil then
    MenuItemChartLineSegments.IsChecked := FChartAverageLineMode = calmLinearSegments;
  if MenuItemChartScaleLog <> nil then
    MenuItemChartScaleLog.IsChecked := FChartFlowScale = cfsLogarithmic;
  if MenuItemChartScaleLinear <> nil then
    MenuItemChartScaleLinear.IsChecked := FChartFlowScale = cfsLinear;

  if GridResults <> nil then
  begin
    GridResults.OnDrawColumnCell := GridResultsDrawColumnCell;
    GridResults.OnMouseDown := GridResultsMouseDown;
    // Подключаем существующий обработчик Hint для ячеек таблицы результатов.
    GridResults.OnMouseMove := GridResultsMouseMove;
    GridResults.OnMouseUp := GridColumnLayoutMouseUp;
  end;
  if ButtonRemoveInvalidAndExcessMeasurements <> nil then
    ButtonRemoveInvalidAndExcessMeasurements.Action := ActionRemoveInvalidAndExcessMeasurements;

  if GridDataPoints <> nil then
  begin
    GridDataPoints.OnDrawColumnCell := GridDataPointsDrawColumnCell;
    // Подключаем существующий обработчик Hint для ячеек таблицы измерений.
    GridDataPoints.OnMouseMove := GridDataPointsMouseMove;
    GridDataPoints.OnMouseUp := GridColumnLayoutMouseUp;
    GridDataPoints.OnHeaderClick := GridDataPointsHeaderClick;
  end;

  // FMX popup contents must be stable while the native menu is open.
  BuildGridColumnsMenu(GridDataPoints, MenuItemGridDataPointsColumns);
  BuildGridColumnsMenu(GridResults, MenuItemGridResultsColumns);

  // Hints remain enabled after the grids are repopulated or their layout changes.
  if GridDataPoints <> nil then
    GridDataPoints.ShowHint := True;
  if GridResults <> nil then
    GridResults.ShowHint := True;
  FLastResultsHintRow := -1;
  FLastResultsHintCol := -1;
  FLastDataPointsHintRow := -1;
  FLastDataPointsHintCol := -1;
  FGridDataPointsSortColumn := '';
  FGridDataPointsSortDirection := gsdNone;

  SetGridReadOnly(GridDataPoints);
  SetGridReadOnly(GridResults);
  SetGridReadOnly(GridCoefs);

  FCurrentSession := nil;
  FreeAndNil(FSessionDevice);
  FreeAndNil(FSessionEtalon);

  ComboBoxUnitsResult.Items.Clear;
  for UnitName in CVolumeFlowUnits do
    ComboBoxUnitsResult.Items.Add(UnitName);
  for UnitName in CMassFlowUnits do
    ComboBoxUnitsResult.Items.Add(UnitName);
  if ComboBoxUnitsResult.Items.Count > 4 then
    ComboBoxUnitsResult.ItemIndex := 4
  else if ComboBoxUnitsResult.Items.Count > 0 then
    ComboBoxUnitsResult.ItemIndex := 0;
  ComboBoxUnitsResult.OnChange := ComboBoxUnitsResultChange;

  LoadProcessingDevices;
  LoadManualProcessingDevices;
  SyncProcessingDevicesWithNewPoints;
  InitCalibrCoefsFrame;
  RefreshResultsTab;
  UpdateSessionErrorChart;
  UpdateActionHints;
end;

procedure TFrameProceed.SetGridReadOnly(AGrid: TGrid);
var
  I: Integer;
begin
  if AGrid = nil then
    Exit;

  AGrid.Options := AGrid.Options - [TGridOption.Editing];
  for I := 0 to AGrid.ColumnCount - 1 do
    if AGrid.Columns[I] <> nil then
      AGrid.Columns[I].ReadOnly := True;
end;

procedure TFrameProceed.UpdateActionHints;
var
  Item: TTreeViewItem;
  Device: TDevice;
  Session, ActiveSession: TSessionSpillage;
  WorkTable: TWorkTable;
  PointDeleteHint, PointsClearHint, NewSessionHint, CloseSessionHint,
    SynchTableHint, DeviceRemoveHint, SessionDeleteHint: string;
begin
  Item := nil;
  Device := nil;
  Session := nil;
  ActiveSession := nil;
  WorkTable := nil;

  if TreeViewDevices <> nil then
    Item := TreeViewDevices.Selected;
  if Item <> nil then
  begin
    if Item.TagObject is TDevice then
    begin
      Device := TDevice(Item.TagObject);
      ActiveSession := GetActiveVisibleSession(Device);
    end
    else if Item.TagObject is TSessionSpillage then
    begin
      Session := TSessionSpillage(Item.TagObject);
      Device := ResolveSelectedDevice;
    end
    else if Item.TagObject is TWorkTable then
      WorkTable := TWorkTable(Item.TagObject);
  end;

  PointDeleteHint := GetDeleteButtonHint;

  if (GridDataPoints = nil) or not GridDataPoints.Visible then
    PointsClearHint := 'Откройте таблицу измерений прибора или сессии для удаления всех измерений'
  else if Session <> nil then
    PointsClearHint := 'Удалить все измерения выбранной в дереве сессии'
  else if Device <> nil then
    PointsClearHint := 'Удалить все отображаемые измерения выбранного в дереве прибора'
  else
    PointsClearHint := 'Выберите в дереве прибор или сессию для удаления измерений';

  if (Item <> nil) and (Item.TagObject is TDevice) then
    NewSessionHint := 'Создать новую сессию для выбранного в дереве прибора'
  else if (Item <> nil) and (Item.TagObject is TSessionSpillage) and
          (Device <> nil) then
    NewSessionHint := 'Создать новую сессию для прибора выбранной сессии'
  else
    NewSessionHint := 'Выберите в дереве прибор или его сессию для создания новой сессии';

  if Session <> nil then
    CloseSessionHint := 'Закрыть выбранную в дереве сессию'
  else if ActiveSession <> nil then
    CloseSessionHint := 'Закрыть активную сессию выбранного в дереве прибора'
  else
    CloseSessionHint := 'Выберите сессию или прибор с активной сессией';

  if WorkTable <> nil then
    SynchTableHint := 'Синхронизировать список обработки с выбранным рабочим столом'
  else if (Item <> nil) and SameText(Item.Text, '...') then
    SynchTableHint := 'Синхронизировать список обработки со всеми рабочими столами с предварительной очисткой'
  else if (Item <> nil) and SameText(Item.Text, 'прочее') then
    SynchTableHint := 'Добавить в список обработки приборы из всех рабочих столов'
  else
    SynchTableHint := 'Выберите в дереве рабочий стол, узел «...» или «прочее» для синхронизации';

  if Device <> nil then
    DeviceRemoveHint := 'Удалить выбранный в дереве прибор из списка обработки'
  else
    DeviceRemoveHint := 'Выберите в дереве прибор для удаления из списка обработки';

  if Session <> nil then
    SessionDeleteHint := 'Удалить выбранную в дереве сессию и связанные с ней измерения'
  else if Device <> nil then
    SessionDeleteHint := 'Удалить выбранный в дереве прибор из списка обработки'
  else
    SessionDeleteHint := 'Выберите в дереве прибор или сессию для удаления';

  ActionSessionPointDelete.Hint := PointDeleteHint;
  ButtonSessionDeleteDataPoint.Hint := PointDeleteHint;
  Button3.Hint := PointDeleteHint;
  ActionSessionPointsClear.Hint := PointsClearHint;
  ButtonSessionClearPoints.Hint := PointsClearHint;
  Button5.Hint := PointsClearHint;
  ActionSessionNew.Hint := NewSessionHint;
  ButtonSessionNew.Hint := NewSessionHint;
  Button4.Hint := NewSessionHint;
  ActionSessionClose.Hint := CloseSessionHint;
  ButtonSessionClose.Hint := CloseSessionHint;
  Button6.Hint := CloseSessionHint;
  ActionSessionSynchTable.Hint := SynchTableHint;
  ButtonSessionSynchTable.Hint := SynchTableHint;
  ActionSessionDeviceAdd.Hint := 'Добавить прибор в список обработки';
  ActionSessionDeviceRemove.Hint := DeviceRemoveHint;
  ActionSessionDelete.Hint := SessionDeleteHint;

  if WorkTable <> nil then
    ActionDeleteWorkTable.Hint :=
      'Удалить выбранный в дереве рабочий стол и связанные с ним данные'
  else
    ActionDeleteWorkTable.Hint :=
      'Выберите в дереве рабочий стол для удаления';
  ActionDeleteSelectedWorkTables.Hint :=
    'Удалить все рабочие столы и связанные с ними данные';
  if ActionRemoveInvalidAndExcessMeasurements <> nil then
  begin
    ActionRemoveInvalidAndExcessMeasurements.Enabled :=
      (FProcessingDevices <> nil) and (FProcessingDevices.Count > 0);
    ActionRemoveInvalidAndExcessMeasurements.Hint :=
      'Удалить неподключённые измерения и повторы сверх поля «Повторы» поверочных точек';
  end;

  if Session <> nil then
    ActionSessionActive.Hint := 'Сделать выбранную в дереве сессию активной'
  else
    ActionSessionActive.Hint := 'Выберите в дереве сессию, которую нужно сделать активной';
end;

procedure TFrameProceed.DbgProceedTree(const ACode: Integer; const AText: string);
begin
  if ProtocolManager <> nil then
    ProtocolManager.AddMessage(pcMKS, psMeasurement, 'DBG ' + ACode.ToString, 'MKS', AText);
end;

function TFrameProceed.GetSelectedTreeDebugText: string;
var
  Item: TTreeViewItem;
begin
  Result := 'Tree=nil';

  if TreeViewDevices = nil then
    Exit;

  Result := Format('Tree.Count=%d', [TreeViewDevices.Count]);

  Item := TreeViewDevices.Selected;
  if Item = nil then
  begin
    Result := Result + '; Selected=nil';
    Exit;
  end;

  Result := Result + Format(
    '; Selected.Text=%s; Selected.Count=%d; Expanded=%s',
    [Item.Text, Item.Count, BoolToStr(Item.IsExpanded, True)]
  );
end;

function TFrameProceed.GetProcessingDevicesDebugText: string;
var
  Device: TDevice;

  function StateText(AState: uBaseProcedures.TObjectState): string;
  begin
    if AState = osEmpty then
      Result := 'osEmpty'
    else if AState = osLoading then
      Result := 'osLoading'
    else if AState = osClean then
      Result := 'osClean'
    else if AState = osNew then
      Result := 'osNew'
    else if AState = osModified then
      Result := 'osModified'
    else if AState = osDeleted then
      Result := 'osDeleted'
    else if AState = osSaving then
      Result := 'osSaving'
    else if AState = osSaved then
      Result := 'osSaved'
    else if AState = osError then
      Result := 'osError'
    else
      Result := 'unknown';
  end;

begin
  Result := 'ProcessingDevices=nil';
  if FProcessingDevices = nil then
    Exit;

  Result := 'ProcessingDevices.Count=' + FProcessingDevices.Count.ToString;
  for Device in FProcessingDevices do
  begin
    if Device = nil then
    begin
      Result := Result + sLineBreak + '  <nil>';
      Continue;
    end;

    Result := Result + sLineBreak + Format(
      '  Name=%s; UUID=%s; State=%s; Manual=%s; Sessions=%d; Spillages=%d',
      [Device.Name, Device.UUID, StateText(Device.State),
       BoolToStr(IsManualProcessingDevice(Device), True),
       Device.Sessions.Count, Device.Spillages.Count]);
  end;
end;


procedure TFrameProceed.RefreshResultsTab;
begin
  DbgProceedTree(1501, 'RefreshResultsTab ENTER'#13#10 + GetSelectedTreeDebugText);
  SyncProcessingDevicesWithNewPoints;
  PopulateTreeViewDevices;
  ShowAllDevicesResults;
  UpdateActionHints;
end;


function TFrameProceed.FindProcessingDeviceByUUID(const ADeviceUUID: string): TDevice;
var
  Device: TDevice;
  DeviceUUID: string;
begin
  Result := nil;
  DeviceUUID := Trim(ADeviceUUID);
  if (DeviceUUID = '') or (FProcessingDevices = nil) then
    Exit;

  for Device in FProcessingDevices do
    if (Device <> nil) and SameText(Trim(Device.UUID), DeviceUUID) then
      Exit(Device);
end;
function TFrameProceed.HasDeviceInProcessing(ADevice: TDevice): Boolean;
begin
  Result := (ADevice <> nil) and (FindProcessingDeviceByUUID(ADevice.UUID) <> nil);
end;
procedure TFrameProceed.AddProcessingDevice(ADevice: TDevice);
begin
  if ADevice = nil then
    DbgProceedTree(1301, 'AddProcessingDevice ENTER: ADevice=nil')
  else
    DbgProceedTree(1302, 'AddProcessingDevice ENTER: ' + ADevice.Name + #13#10 + ADevice.UUID);

  if (ADevice = nil) or (Trim(ADevice.UUID) = '') or (FProcessingDevices = nil) or
     (ADevice.State = osDeleted) then
    Exit;

  if (FPendingRemovedProcessingUUIDs <> nil) and
     (FPendingRemovedProcessingUUIDs.IndexOf(Trim(ADevice.UUID)) >= 0) then
    FPendingRemovedProcessingUUIDs.Delete(FPendingRemovedProcessingUUIDs.IndexOf(Trim(ADevice.UUID)));

  if HasDeviceInProcessing(ADevice) then
    Exit;

  DbgProceedTree(1303, 'Before FProcessingDevices.Add: ' + ADevice.Name + #13#10 + ADevice.UUID);
  FProcessingDevices.Add(ADevice);
  DbgProceedTree(1304, 'After FProcessingDevices.Add: Count=' + FProcessingDevices.Count.ToString);
end;
procedure TFrameProceed.RemoveProcessingDevice(ADevice: TDevice);
var
  Existing: TDevice;
  ManualIndex: Integer;
begin
  if (ADevice = nil) or (FProcessingDevices = nil) then
    Exit;

  Existing := FindProcessingDeviceByUUID(ADevice.UUID);
  if Existing = nil then
    Exit;

  // FProcessingDevices stores references to desktop/worktable devices.
  // Removing from processing must only drop the processing reference;
  // do not change Existing.State or sessions/points here.
  FProcessingDevices.Remove(Existing);

  if FManualProcessingDeviceUUIDs <> nil then
  begin
    ManualIndex := FManualProcessingDeviceUUIDs.IndexOf(Trim(ADevice.UUID));
    if ManualIndex >= 0 then
      FManualProcessingDeviceUUIDs.Delete(ManualIndex);
  end;
end;

function TFrameProceed.IsProcessingDevicePendingRemoved(ADevice: TDevice): Boolean;
begin
  Result := (ADevice <> nil) and (FPendingRemovedProcessingUUIDs <> nil) and
    (FPendingRemovedProcessingUUIDs.IndexOf(Trim(ADevice.UUID)) >= 0);
end;

procedure TFrameProceed.MarkProcessingDeviceRemoved(ADevice: TDevice);
var
  DeviceUUID: string;
begin
  if (ADevice = nil) or (FPendingRemovedProcessingUUIDs = nil) then
    Exit;

  DeviceUUID := Trim(ADevice.UUID);
  if DeviceUUID = '' then
    Exit;

  if FPendingRemovedProcessingUUIDs.IndexOf(DeviceUUID) < 0 then
    FPendingRemovedProcessingUUIDs.Add(DeviceUUID);

  RefreshResultsAfterDevicesAction;
end;

procedure TFrameProceed.ApplyProcessingDeviceRemovals;
var
  I: Integer;
  Device: TDevice;
begin
  if FPendingRemovedProcessingUUIDs = nil then
    Exit;

  for I := FPendingRemovedProcessingUUIDs.Count - 1 downto 0 do
  begin
    Device := FindProcessingDeviceByUUID(FPendingRemovedProcessingUUIDs[I]);
    if Device <> nil then
      RemoveProcessingDevice(Device);
  end;

end;

function TFrameProceed.IsManualProcessingDevice(ADevice: TDevice): Boolean;
begin
  Result := (ADevice <> nil) and (FManualProcessingDeviceUUIDs <> nil) and
    (FManualProcessingDeviceUUIDs.IndexOf(Trim(ADevice.UUID)) >= 0);
end;

procedure TFrameProceed.MarkProcessingDeviceManual(ADevice: TDevice);
var
  DeviceUUID: string;
begin
  if (ADevice = nil) or (FManualProcessingDeviceUUIDs = nil) then
    Exit;

  DeviceUUID := Trim(ADevice.UUID);
  if DeviceUUID = '' then
    Exit;

  if FManualProcessingDeviceUUIDs.IndexOf(DeviceUUID) < 0 then
    FManualProcessingDeviceUUIDs.Add(DeviceUUID);
end;

procedure TFrameProceed.LoadManualProcessingDevices;
var
  Ini: TIniFile;
  I, Count: Integer;
  DeviceUUID: string;
begin
  if FManualProcessingDeviceUUIDs = nil then
    Exit;

  FManualProcessingDeviceUUIDs.Clear;

  if (FWorkTableManager = nil) or (Trim(FWorkTableManager.IniFileName) = '') or
     (not FileExists(FWorkTableManager.IniFileName)) then
    Exit;

  Ini := TIniFile.Create(FWorkTableManager.IniFileName);
  try
    Count := Ini.ReadInteger(CManualProcessingDevicesSection, CProcessingDevicesCountKey, 0);
    for I := 0 to Count - 1 do
    begin
      DeviceUUID := Trim(Ini.ReadString(CManualProcessingDevicesSection,
        CProcessingDevicesItemKeyPrefix + IntToStr(I), ''));
      if (DeviceUUID <> '') and
         (FManualProcessingDeviceUUIDs.IndexOf(DeviceUUID) < 0) then
        FManualProcessingDeviceUUIDs.Add(DeviceUUID);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TFrameProceed.SaveManualProcessingDevices;
var
  Ini: TIniFile;
  I, SaveIndex: Integer;
  DeviceUUID: string;
begin
  if (FWorkTableManager = nil) or (Trim(FWorkTableManager.IniFileName) = '') or
     (FManualProcessingDeviceUUIDs = nil) then
    Exit;

  Ini := TIniFile.Create(FWorkTableManager.IniFileName);
  try
    Ini.EraseSection(CManualProcessingDevicesSection);
    SaveIndex := 0;
    for I := 0 to FManualProcessingDeviceUUIDs.Count - 1 do
    begin
      DeviceUUID := Trim(FManualProcessingDeviceUUIDs[I]);
      if (DeviceUUID = '') or (FindProcessingDeviceByUUID(DeviceUUID) = nil) then
        Continue;

      Ini.WriteString(CManualProcessingDevicesSection,
        CProcessingDevicesItemKeyPrefix + IntToStr(SaveIndex), DeviceUUID);
      Inc(SaveIndex);
    end;
    Ini.WriteInteger(CManualProcessingDevicesSection, CProcessingDevicesCountKey, SaveIndex);
  finally
    Ini.Free;
  end;
end;

procedure TFrameProceed.MarkProcessingDeviceDeleted(ADevice: TDevice);
var
  Session: TSessionSpillage;
  Point: TPointSpillage;
begin
  if ADevice = nil then
    Exit;

  ADevice.State := osDeleted;

  if ADevice.Sessions <> nil then
    for Session in ADevice.Sessions do
      if Session <> nil then
      begin
        Session.Active := False;
        Session.State := osDeleted;
      end;

  if ADevice.Spillages <> nil then
    for Point in ADevice.Spillages do
      if Point <> nil then
        Point.State := osDeleted;
end;

function TFrameProceed.GetDeviceSpillageCount(ADevice: TDevice): Integer;
var
  Point: TPointSpillage;
begin
  Result := 0;
  if (ADevice = nil) or (ADevice.Spillages = nil) then
    Exit;

  for Point in ADevice.Spillages do
    if (Point <> nil) and (Point.State <> osDeleted) then
      Inc(Result);
end;

function TFrameProceed.GetLastSpillageDate(ADevice: TDevice): TDateTime;
var
  Point: TPointSpillage;
begin
  Result := 0;
  if (ADevice = nil) or (ADevice.Spillages = nil) then
    Exit;

  for Point in ADevice.Spillages do
    if (Point <> nil) and (Point.State <> osDeleted) and
       (Point.DateTime > Result) then
      Result := Point.DateTime;
end;

procedure TFrameProceed.SortProcessingDataByDate;
var
  FirstDate, LastDate: TDateTime;

  function DirectionText: string;
  begin
    if FGridDataPointsSortDirection = gsdAscending then
      Result := 'Ascending'
    else if FGridDataPointsSortDirection = gsdDescending then
      Result := 'Descending'
    else
      Result := 'None';
  end;

  function FormatSortDate(const ADate: TDateTime): string;
  begin
    if ADate > 0 then
      Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', ADate)
    else
      Result := '';
  end;

begin
  if StringColumnSpillageDateTime <> nil then
  begin
    if SameText(FGridDataPointsSortColumn, StringColumnSpillageDateTime.Name) then
    begin
      if FGridDataPointsSortDirection = gsdAscending then
        StringColumnSpillageDateTime.Header := 'Дата/время ↑'
      else if FGridDataPointsSortDirection = gsdDescending then
        StringColumnSpillageDateTime.Header := 'Дата/время ↓'
      else
        StringColumnSpillageDateTime.Header := 'Дата/время';
    end
    else
      StringColumnSpillageDateTime.Header := 'Дата/время';
  end;

  if (not SameText(FGridDataPointsSortColumn, 'StringColumnSpillageDateTime')) or
     (FGridDataPointsSortDirection = gsdNone) then
    Exit;

  if Length(FCurrentSpillages) > 1 then
    TArray.Sort<TPointSpillage>(FCurrentSpillages,
      TComparer<TPointSpillage>.Construct(
        function(const Left, Right: TPointSpillage): Integer
        var
          LeftDate, RightDate: TDateTime;
        begin
          LeftDate := 0;
          RightDate := 0;
          if Left <> nil then
            LeftDate := Left.DateTime;
          if Right <> nil then
            RightDate := Right.DateTime;

          if LeftDate < RightDate then
            Result := -1
          else if LeftDate > RightDate then
            Result := 1
          else
            Result := 0;

          if FGridDataPointsSortDirection = gsdDescending then
            Result := -Result;
        end));

  FirstDate := 0;
  LastDate := 0;
  if Length(FCurrentSpillages) > 0 then
  begin
    if FCurrentSpillages[0] <> nil then
      FirstDate := FCurrentSpillages[0].DateTime;
    if FCurrentSpillages[High(FCurrentSpillages)] <> nil then
      LastDate := FCurrentSpillages[High(FCurrentSpillages)].DateTime;
  end;

  if ProtocolManager <> nil then
    ProtocolManager.AddMessage(pcProc, psForm, 'ProcessingGridSortChanged',
      'Изменена сортировка таблицы точек обработки',
      Format('Grid=GridDataPoints; Column=StringColumnSpillageDateTime; Direction=%s; Count=%d; FirstDate=%s; LastDate=%s',
        [DirectionText, Length(FCurrentSpillages), FormatSortDate(FirstDate),
         FormatSortDate(LastDate)]));
end;

procedure TFrameProceed.SaveProcessingPointCounts;
var
  Ini: TIniFile;
  I: Integer;
  WT: TWorkTable;
  Ch: TChannel;
  Device: TDevice;
  SavedUUIDs: TStringList;
begin
  if (FWorkTableManager = nil) or (Trim(FWorkTableManager.IniFileName) = '') then
    Exit;

  Ini := TIniFile.Create(FWorkTableManager.IniFileName);
  SavedUUIDs := TStringList.Create;
  try
    SavedUUIDs.Sorted := False;
    SavedUUIDs.Duplicates := dupIgnore;

    if (FWorkTableManager.WorkTables <> nil) then
      for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
      begin
        WT := FWorkTableManager.WorkTables[I];
        if (WT = nil) or (WT.DeviceChannels = nil) then
          Continue;

        for Ch in WT.DeviceChannels do
        begin
          if (Ch = nil) or (Ch.FlowMeter = nil) or (Ch.FlowMeter.Device = nil) then
            Continue;

          Device := Ch.FlowMeter.Device;
          if (Trim(Device.UUID) = '') or (SavedUUIDs.IndexOf(Trim(Device.UUID)) >= 0) then
            Continue;

          SavedUUIDs.Add(Trim(Device.UUID));
          Ini.WriteInteger(CProcessingDevicePointCountsSection, Trim(Device.UUID),
            GetDeviceSpillageCount(Device));
        end;
      end;
  finally
    SavedUUIDs.Free;
    Ini.Free;
  end;
end;

procedure TFrameProceed.SaveProcessingDevices;
var
  Ini: TIniFile;
  I, SaveIndex: Integer;
  Device: TDevice;
begin
  if FWorkTableManager <> nil then
    DbgProceedTree(1411, 'SaveProcessingDevices ENTER; Ini=' + FWorkTableManager.IniFileName)
  else
    DbgProceedTree(1411, 'SaveProcessingDevices ENTER; Ini=<nil>');

  if (FWorkTableManager = nil) or (Trim(FWorkTableManager.IniFileName) = '') or
     (FProcessingDevices = nil) then
    Exit;

  Ini := TIniFile.Create(FWorkTableManager.IniFileName);
  try
    Ini.EraseSection(CProcessingDevicesSection);

    SaveIndex := 0;
    for I := 0 to FProcessingDevices.Count - 1 do
    begin
      Device := FProcessingDevices[I];
      if (Device = nil) or (Trim(Device.UUID) = '') or
         (Device.State = osDeleted) then
        Continue;

      DbgProceedTree(1412, 'SaveProcessingDevices item: ' + Device.Name + #13#10 + Device.UUID);
      Ini.WriteString(CProcessingDevicesSection,
        CProcessingDevicesItemKeyPrefix + IntToStr(SaveIndex), Trim(Device.UUID));
      Inc(SaveIndex);
    end;

    Ini.WriteInteger(CProcessingDevicesSection, CProcessingDevicesCountKey, SaveIndex);
    DbgProceedTree(1413, 'SaveProcessingDevices EXIT');
  finally
    Ini.Free;
  end;

  SaveProcessingPointCounts;
  SaveManualProcessingDevices;
end;


procedure TFrameProceed.SavePendingProcessingChanges(Sender: TObject);
var
  Services: TAppServices;
  DM: TManagerTTableDM;
  Repo: TDeviceRepository;
  Device: TDevice;
begin
  if FProcessingChangesSaved then
    Exit;

  FProcessingChangesSaved := True;

  Services := nil;
  DM := nil;

  if Sender is TAppServices then
    Services := TAppServices(Sender)
  else if Assigned(AppServices) then
    Services := AppServices;

  if Assigned(Services) then
    DM := Services.DataManager;

  if DM = nil then
    DM := uDataManager.DataManager;

  if (DM = nil) or (DM.DeviceRepositories = nil) then
    Exit;

  ApplyProcessingDeviceRemovals;
  SaveProcessingDevices;

  for Repo in DM.DeviceRepositories do
  begin
    if (Repo = nil) or (Repo.Devices = nil) then
      Continue;

    for Device in Repo.Devices do
      if (Device <> nil) and (Device.State <> osClean) then
        Repo.SaveDevice(Device);
  end;
end;

procedure TFrameProceed.CancelProcessingChanges;
var
  Repo: TDeviceRepository;
  Device: TDevice;
  SelectedTag: string;
  SelectedItem: TTreeViewItem;
  HadPendingRemovals: Boolean;
  HasDeletedDevices: Boolean;

  function FindTreeItemByTagString(AParent: TTreeViewItem;
    const ATagString: string): TTreeViewItem;
  var
    I: Integer;
  begin
    Result := nil;
    if (AParent = nil) or (ATagString = '') then
      Exit;

    if SameText(AParent.TagString, ATagString) then
      Exit(AParent);

    for I := 0 to AParent.Count - 1 do
    begin
      Result := FindTreeItemByTagString(TTreeViewItem(AParent.Items[I]), ATagString);
      if Result <> nil then
        Exit;
    end;
  end;

  function FindTreeItemBySavedTag(const ATagString: string): TTreeViewItem;
  var
    I: Integer;
  begin
    Result := nil;
    if (TreeViewDevices = nil) or (ATagString = '') then
      Exit;

    for I := 0 to TreeViewDevices.Count - 1 do
    begin
      Result := FindTreeItemByTagString(TreeViewDevices.ItemByIndex(I), ATagString);
      if Result <> nil then
        Exit;
    end;
  end;

begin
  DbgProceedTree(1801, 'CancelProcessingChanges ENTER'#13#10 +
    GetSelectedTreeDebugText + #13#10 + GetProcessingDevicesDebugText);

  HadPendingRemovals := (FPendingRemovedProcessingUUIDs <> nil) and
    (FPendingRemovedProcessingUUIDs.Count > 0);
  HasDeletedDevices := False;
  if FProcessingDevices <> nil then
    for Device in FProcessingDevices do
      if (Device <> nil) and (Device.State = osDeleted) then
      begin
        HasDeletedDevices := True;
        Break;
      end;

  if FPendingRemovedProcessingUUIDs <> nil then
    FPendingRemovedProcessingUUIDs.Clear;

  if HadPendingRemovals and (not HasDeletedDevices) then
  begin
    RefreshResultsAfterDevicesAction;
    DbgProceedTree(1804, 'CancelProcessingChanges EXIT pending removals only'#13#10 +
      GetSelectedTreeDebugText + #13#10 + GetProcessingDevicesDebugText);
    Exit;
  end;

  SelectedTag := '';
  if (TreeViewDevices <> nil) and (TreeViewDevices.Selected <> nil) then
    SelectedTag := TreeViewDevices.Selected.TagString;

  if FProcessingDevices <> nil then
    for Device in FProcessingDevices do
      if (Device <> nil) and (Device.State = osDeleted) then
        Device.State := osClean;

  DbgProceedTree(1802, 'CancelProcessingChanges AFTER osClean restore'#13#10 +
    GetProcessingDevicesDebugText);

  if FProcessingDevices <> nil then
    FProcessingDevices.Clear;
  SetLength(FCurrentResultRows, 0);
  SetLength(FCurrentSpillages, 0);
  FCurrentSession := nil;
  FActiveWorkTable := ResolveManagerWorkTable(FWorkTableManager);
  ResetPointDeleteConfirm;

  if (AppServices.DataManager <> nil) and
     (AppServices.DataManager.DeviceRepositories <> nil) then
    for Repo in AppServices.DataManager.DeviceRepositories do
      if Repo <> nil then
        Repo.Load;

  LoadProcessingDevices;
  LoadManualProcessingDevices;
  DbgProceedTree(1803, 'CancelProcessingChanges AFTER reload'#13#10 +
    GetProcessingDevicesDebugText);
  PopulateTreeViewDevices;

  SelectedItem := FindTreeItemBySavedTag(SelectedTag);
  if SelectedItem <> nil then
    TreeViewDevices.Selected := SelectedItem;

  UpdateSessionItems;
  if (SelectedItem <> nil) and (SelectedItem.TagObject is TSessionSpillage) then
    ShowSessionSpillages(TSessionSpillage(SelectedItem.TagObject))
  else if (SelectedItem <> nil) and (SelectedItem.TagObject is TDevice) then
    ShowDeviceSpillages(TDevice(SelectedItem.TagObject))
  else
    ShowAllDevicesResults;

  DbgProceedTree(1804, 'CancelProcessingChanges EXIT'#13#10 +
    GetSelectedTreeDebugText + #13#10 + GetProcessingDevicesDebugText);
end;

procedure TFrameProceed.CaptureGridColumnsLayout(AGrid: TGrid;
  out AColumns: TArray<TGridColumnLayout>);
var
  I: Integer;
  Column: TColumn;
begin
  SetLength(AColumns, 0);
  if AGrid = nil then
    Exit;

  SetLength(AColumns, AGrid.ColumnCount);
  if Assigned(ProtocolManager) then
    ProtocolManager.AddMessage(pcProc, psForm, 'GridLayoutSaveOrderBegin',
      'Начато сохранение порядка столбцов', 'GridName=' + AGrid.Name);
  for I := 0 to AGrid.ColumnCount - 1 do
  begin
    Column := AGrid.Columns[I];
    AColumns[I].Name := Column.Name;
    // TColumn.Index is updated by the standard FMX drag operation and is the
    // visual position. Columns[I] remains the grid's column collection lookup.
    AColumns[I].Position := Column.Index;
    AColumns[I].Width := Column.Width;
    AColumns[I].Visible := Column.Visible;
    if Assigned(ProtocolManager) then
      ProtocolManager.AddMessage(pcProc, psForm, 'GridLayoutSaved',
        'Сохранена раскладка столбца',
        Format('GridName=%s; ColumnName=%s; ColumnsIndex=%d; VisualIndex=%d; Position=%d; Width=%g; Visible=%s',
          [AGrid.Name, Column.Name, I, Column.Index, AColumns[I].Position,
           Column.Width, BoolToStr(Column.Visible, True)]));
  end;
end;


procedure TFrameProceed.ApplyGridColumnsLayout(AGrid: TGrid;
  const AColumns: TArray<TGridColumnLayout>);
var
  I, J, TargetIndex: Integer;
  Column: TColumn;
  SortedColumns: TArray<TGridColumnLayout>;
  Temp: TGridColumnLayout;
begin
  if (AGrid = nil) or (Length(AColumns) = 0) then
    Exit;

  // Work on a copy: the WorkTable array remains in its persisted form. FMX
  // receives columns in ascending visual Position order.
  SortedColumns := Copy(AColumns, 0, Length(AColumns));
  for I := 1 to High(SortedColumns) do
  begin
    Temp := SortedColumns[I];
    J := I - 1;
    while (J >= 0) and (SortedColumns[J].Position > Temp.Position) do
    begin
      SortedColumns[J + 1] := SortedColumns[J];
      Dec(J);
    end;
    SortedColumns[J + 1] := Temp;
  end;

  FApplyingGridColumnsLayout := True;
  AGrid.BeginUpdate;
  try
    for I := 0 to High(SortedColumns) do
    begin
      Column := nil;
      // Name is the persistent identity: the current index changes when a user
      // moves a column and therefore cannot identify it on the next form open.
      for J := 0 to AGrid.ColumnCount - 1 do
        if SameText(AGrid.Columns[J].Name, SortedColumns[I].Name) then
        begin
          Column := AGrid.Columns[J];
          Break;
        end;
      if Column = nil then
        Continue;

      if Column.Visible <> SortedColumns[I].Visible then
        Column.Visible := SortedColumns[I].Visible;
      if (SortedColumns[I].Width > 0) and
         (Abs(Column.Width - SortedColumns[I].Width) > 0.01) then
        Column.Width := SortedColumns[I].Width;
    end;

    for I := 0 to High(SortedColumns) do
    begin
      TargetIndex := EnsureRange(SortedColumns[I].Position, 0,
        AGrid.ColumnCount - 1);
      Column := nil;
      for J := 0 to AGrid.ColumnCount - 1 do
        if SameText(AGrid.Columns[J].Name, SortedColumns[I].Name) then
        begin
          Column := AGrid.Columns[J];
          Break;
        end;
      if Column = nil then
        Continue;

      // Index is the standard FMX column move mechanism and triggers the grid
      // model's normal reindexing. Suppress the resulting save callback while
      // the complete saved order is still being restored.
      if Column.Index <> TargetIndex then
        Column.Index := TargetIndex;
      if Assigned(ProtocolManager) then
        ProtocolManager.AddMessage(pcProc, psForm, 'GridLayoutLoaded',
          'Загружена раскладка столбца',
          Format('GridName=%s; ColumnName=%s; SavedPosition=%d; AppliedPosition=%d',
            [AGrid.Name, Column.Name, SortedColumns[I].Position, Column.Index]));
    end;
  finally
    AGrid.EndUpdate;
    FApplyingGridColumnsLayout := False;
  end;
  AGrid.Repaint;
end;


procedure TFrameProceed.SaveLayoutSettingsToWorkTable;
var
  WorkTable: TWorkTable;
  EtalonColumns: TArray<TGridColumnLayout>;
  DeviceColumns: TArray<TGridColumnLayout>;
  DataPointsColumns: TArray<TGridColumnLayout>;
  ResultsColumns: TArray<TGridColumnLayout>;
begin
  // Keep the existing WorkTable/INI storage; resolve the active table at save
  // time so a tab switch cannot write the layout into the previous table.
  WorkTable := ResolveManagerWorkTable(FWorkTableManager);
  if WorkTable = nil then
    Exit;
  FActiveWorkTable := WorkTable;
  CaptureGridColumnsLayout(GridDataPoints, DataPointsColumns);
  CaptureGridColumnsLayout(GridResults, ResultsColumns);
  WorkTable.DataPointsGridColumns := DataPointsColumns;
  WorkTable.ResultsGridColumns := ResultsColumns;
  if FWorkTableManager <> nil then
    FWorkTableManager.Save;
end;



procedure TFrameProceed.AddProcessingDeviceFromSelection;
var
  Frm: TFormDeviceSelect;
  SelDevice: TDevice;
  Res: TModalResult;
begin
  DbgProceedTree(1101, 'AddProcessingDeviceFromSelection ENTER'#13#10 + GetSelectedTreeDebugText);
  DbgProceedTree(1102, 'Before TFormDeviceSelect.Create'#13#10 + GetSelectedTreeDebugText);
  Frm := TFormDeviceSelect.Create(Self);
  try
    DbgProceedTree(1103, 'After TFormDeviceSelect.Create'#13#10 + GetSelectedTreeDebugText);
    Frm.Tag := 0;
    DbgProceedTree(1104, 'Before DeviceSelect.ShowModal'#13#10 + GetSelectedTreeDebugText);
    Res := Frm.ShowModal;
    DbgProceedTree(1105, Format('After DeviceSelect.ShowModal; Res=%d; Frm.Tag=%d'#13#10'%s',
      [Ord(Res), Frm.Tag, GetSelectedTreeDebugText]));
    //LoadProcessingDevices;
    if (Res <> mrOk) or (Frm.Tag <> 1) then
    begin
      //UpdateTreeViewDeviceTagObjects;
     // DbgProceedTree(1106, Format('DeviceSelect canceled/closed branch; Res=%d; Frm.Tag=%d'#13#10'%s',
      //  [Ord(Res), Frm.Tag, GetSelectedTreeDebugText]));
      Exit;
    end;

    DbgProceedTree(1107, 'Before Frm.GetSelectedDevice'#13#10 + GetSelectedTreeDebugText);
    SelDevice := Frm.GetSelectedDevice;
    if SelDevice = nil then
    begin
      DbgProceedTree(1108, 'SelDevice=nil branch'#13#10 + GetSelectedTreeDebugText);
      Exit;
    end;

    DbgProceedTree(1109, 'Before AddProcessingDevice: ' + SelDevice.Name + #13#10 + SelDevice.UUID);
    AddProcessingDevice(SelDevice);
    MarkProcessingDeviceManual(SelDevice);
    DbgProceedTree(1110, 'After AddProcessingDevice'#13#10 + GetSelectedTreeDebugText);
    DbgProceedTree(1111, 'Before PopulateTreeViewDevices from AddProcessingDeviceFromSelection');
    PopulateTreeViewDevices;
    DbgProceedTree(1112, 'After PopulateTreeViewDevices from AddProcessingDeviceFromSelection'#13#10 + GetSelectedTreeDebugText);
    SaveProcessingDevices;
    SelectTreeItemByTagObject(SelDevice);
    ShowDeviceSpillages(SelDevice);
  finally
    DbgProceedTree(1113, 'Before Frm.Free'#13#10 + GetSelectedTreeDebugText);
    Frm.Free;
  end;
  DbgProceedTree(1114, 'AddProcessingDeviceFromSelection EXIT'#13#10 + GetSelectedTreeDebugText);
end;

procedure TFrameProceed.btnCancelClick(Sender: TObject);
begin
  DbgProceedTree(1811, 'btnCancelClick'#13#10 + GetProcessingDevicesDebugText);
  CancelProcessingChanges;
end;

procedure TFrameProceed.btnOKClick(Sender: TObject);
begin
   FPendingRemovedProcessingUUIDs.Clear;
  //ApplyProcessingDeviceRemovals;
  //SaveProcessingDevices;
  PopulateTreeViewDevices;
   RefreshResultsTab;
end;

procedure TFrameProceed.UpdateTreeViewDeviceTagObjects;
var
  I: Integer;

  function FindSessionByID(ADevice: TDevice; const ASessionID: Integer): TSessionSpillage;
  var
    Sess: TSessionSpillage;
    Point: TPointSpillage;
  begin
    Result := nil;
    if (ADevice = nil) or (ADevice.Sessions = nil) then
      Exit;

    for Sess in ADevice.Sessions do
      if (Sess <> nil) and (Sess.ID = ASessionID) then
        Exit(Sess);
  end;

  procedure UpdateItem(AItem: TTreeViewItem);
  var
    J: Integer;
    Parts: TArray<string>;
    Device: TDevice;
  begin
    if AItem = nil then
      Exit;

    Parts := AItem.TagString.Split(['|']);
    if Length(Parts) > 0 then
    begin
      if SameText(Parts[0], 'D') and (Length(Parts) >= 2) then
        AItem.TagObject := FindProcessingDeviceByUUID(Parts[1])
      else if SameText(Parts[0], 'S') and (Length(Parts) >= 3) then
      begin
        Device := FindProcessingDeviceByUUID(Parts[1]);
        AItem.TagObject := FindSessionByID(Device, StrToIntDef(Parts[2], -1));
      end;
    end;

    for J := 0 to AItem.Count - 1 do
      UpdateItem(AItem.ItemByIndex(J));
  end;
begin
  if TreeViewDevices = nil then
    Exit;

  for I := 0 to TreeViewDevices.Count - 1 do
    UpdateItem(TreeViewDevices.ItemByIndex(I));
end;
procedure TFrameProceed.RefreshResultsAfterDevicesAction;
begin
  DbgProceedTree(1502, 'RefreshResultsAfterDevicesAction ENTER'#13#10 + GetSelectedTreeDebugText);
  PopulateTreeViewDevices;
  ShowAllDevicesResults;
end;
function TFrameProceed.FindTreeItemByTagObject(ATagObject: TObject): TTreeViewItem;
var
  I: Integer;
  Item: TTreeViewItem;

  function FindInItem(AItem: TTreeViewItem): TTreeViewItem;
  var
    J: Integer;
  begin
    Result := nil;
    if AItem = nil then
      Exit;

    if AItem.TagObject = ATagObject then
      Exit(AItem);

    for J := 0 to AItem.Count - 1 do
    begin
      Result := FindInItem(AItem.ItemByIndex(J));
      if Result <> nil then
        Exit;
    end;
  end;
begin
  Result := nil;
  if (TreeViewDevices = nil) or (ATagObject = nil) then
    Exit;

  for I := 0 to TreeViewDevices.Count - 1 do
  begin
    Item := TreeViewDevices.ItemByIndex(I);
    Result := FindInItem(Item);
    if Result <> nil then
      Exit;
  end;
end;
procedure TFrameProceed.SelectTreeItemByTagObject(ATagObject: TObject);
var
  Item: TTreeViewItem;
  Parent: TTreeViewItem;
begin
  Item := FindTreeItemByTagObject(ATagObject);
  if Item <> nil then
  begin
    Parent := Item.ParentItem;
    while Parent <> nil do
    begin
      Parent.IsExpanded := True;
      Parent := Parent.ParentItem;
    end;
    TreeViewDevices.Selected := Item;
  end;
end;
function TFrameProceed.GetActiveVisibleSession(ADevice: TDevice): TSessionSpillage;
var
  Sess: TSessionSpillage;
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.Sessions = nil) then
    Exit;

  for Sess in ADevice.Sessions do
    if (Sess <> nil) and Sess.Active and (Sess.State <> osDeleted) then
      Exit(Sess);
end;

procedure TFrameProceed.RefreshMeasurementsAfterSessionAction(ADevice: TDevice;
  ASession: TSessionSpillage);
var
  ActiveSession: TSessionSpillage;
begin
  PopulateTreeViewDevices;

  if ASession <> nil then
  begin
    SelectTreeItemByTagObject(ASession);
    ShowSessionSpillages(ASession)
  end
  else if ADevice <> nil then
  begin
    ActiveSession := GetActiveVisibleSession(ADevice);
    if ActiveSession <> nil then
    begin
      SelectTreeItemByTagObject(ActiveSession);
      ShowSessionSpillages(ActiveSession)
    end
    else
    begin
      SelectTreeItemByTagObject(ADevice);
      ShowSessionSpillages(nil);
    end;
  end;

  if (TreeViewDevices <> nil) and (TreeViewDevices.Selected <> nil) then
    TreeViewDevicesChange(TreeViewDevices)
  else
  begin
    UpdateSessionItems;
  end;

  if Assigned(FOnResultsSynchronized) then
    FOnResultsSynchronized(Self);
  end;

function TFrameProceed.CanManageResultSessions: Boolean;
begin
  Result := (FActiveWorkTable = nil) or (FActiveWorkTable.MeasurementRun = nil) or
    (FActiveWorkTable.MeasurementRun.Stage in [msNone, msDone]);
end;

function TFrameProceed.RequestClearActiveSession(ADevice: TDevice): Boolean;
var
  Session: TSessionSpillage;
  Point: TPointSpillage;
  OldSessionID, SpillageCount: Integer;
begin
  Result := False;
  if not CanManageResultSessions then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearFailed',
      'Очистка сессии заблокирована во время измерения',
      'Scope=SelectedDevice; Error=MeasurementActive');
    ShowMessage('Во время активного измерения очистка сессии недоступна.');
    Exit;
  end;
  if ADevice = nil then Exit;
  Session := GetActiveVisibleSession(ADevice);
  if Session = nil then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearFailed',
      'Активная сессия прибора не найдена', Format('Scope=SelectedDevice; DeviceUUID=%s; Serial=%s; Error=NoActiveSession', [ADevice.UUID, ADevice.SerialNumber]));
    ShowMessage('У выбранного прибора нет активной сессии.');
    Exit;
  end;
  OldSessionID := Session.ID;
  SpillageCount := Session.Spillages.Count;
  ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearRequested',
    'Запрошена очистка активной сессии', Format('Scope=SelectedDevice; DeviceUUID=%s; Serial=%s; OldSessionID=%d; NewSessionID=%d; Spillages=%d', [ADevice.UUID, ADevice.SerialNumber, OldSessionID, OldSessionID, SpillageCount]));
  if MessageDlg('Очистить все результаты данной сессии измерений?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then Exit;
  SelectTreeItemByTagObject(Session);
  ActionSessionPointsClearExecute(ActionSessionPointsClear);
  SpillageCount := 0;
  for Point in Session.Spillages do
    if (Point <> nil) and (Point.State <> osDeleted) then Inc(SpillageCount);
  Result := SpillageCount = 0;
  if Result then
    ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearCompleted',
      'Активная сессия очищена штатным маршрутом обработки', Format('Scope=SelectedDevice; DeviceUUID=%s; Serial=%s; OldSessionID=%d; NewSessionID=%d; Spillages=%d', [ADevice.UUID, ADevice.SerialNumber, OldSessionID, OldSessionID, 0]))
  else
    ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearFailed',
      'Очистить активную сессию не удалось', Format('Scope=SelectedDevice; DeviceUUID=%s; Serial=%s; OldSessionID=%d; NewSessionID=%d; Spillages=%d; Error=ProductionRouteRejected', [ADevice.UUID, ADevice.SerialNumber, OldSessionID, OldSessionID, SpillageCount]));
end;

function TFrameProceed.RequestCreateSession(ADevice: TDevice): TSessionSpillage;
var OldSession: TSessionSpillage; OldSessionID, Spillages: Integer;
begin
  Result := nil;
  if not CanManageResultSessions then
  begin
    ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateFailed', 'Создание сессии заблокировано во время измерения', 'Scope=SelectedDevice; Error=MeasurementActive');
    ShowMessage('Во время активного измерения создание сессии недоступно.'); Exit;
  end;
  if ADevice = nil then Exit;
  OldSession := GetActiveVisibleSession(ADevice); OldSessionID := 0; Spillages := 0;
  if OldSession <> nil then begin OldSessionID := OldSession.ID; Spillages := OldSession.Spillages.Count; end;
  ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateRequested', 'Запрошено создание сессии', Format('Scope=SelectedDevice; DeviceUUID=%s; Serial=%s; OldSessionID=%d; NewSessionID=0; Spillages=%d', [ADevice.UUID, ADevice.SerialNumber, OldSessionID, Spillages]));
  SelectTreeItemByTagObject(ADevice); ActionSessionNewExecute(ActionSessionNew);
  Result := GetActiveVisibleSession(ADevice);
  if (Result <> nil) and (Result <> OldSession) then
    ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateCompleted', 'Сессия создана штатным маршрутом обработки', Format('Scope=SelectedDevice; DeviceUUID=%s; Serial=%s; OldSessionID=%d; NewSessionID=%d; Spillages=%d', [ADevice.UUID, ADevice.SerialNumber, OldSessionID, Result.ID, Result.Spillages.Count]))
  else begin
    ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateFailed', 'Создать сессию не удалось', Format('Scope=SelectedDevice; DeviceUUID=%s; Serial=%s; OldSessionID=%d; NewSessionID=0; Spillages=%d; Error=ProductionRouteRejected', [ADevice.UUID, ADevice.SerialNumber, OldSessionID, Spillages]));
    ShowMessage('Не удалось создать новую сессию.'); Result := nil;
  end;
end;

function TFrameProceed.RequestClearActiveSessions: Boolean;
var Device: TDevice; Ch: TChannel; Changed: Boolean;
begin
  Result := False;
  ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearRequested', 'Запрошена групповая очистка активных сессий', 'Scope=AllDevices; DeviceUUID=; Serial=; OldSessionID=0; NewSessionID=0; Spillages=0');
  if not CanManageResultSessions then begin ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearFailed', 'Групповая очистка заблокирована', 'Scope=AllDevices; Error=MeasurementActive'); ShowMessage('Во время активного измерения очистка сессий недоступна.'); Exit; end;
  if MessageDlg('Очистить активные сессии всех приборов рабочего стола?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then Exit;
  Changed := False;
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.DeviceChannels <> nil) then
    for Ch in FActiveWorkTable.DeviceChannels do begin
    Device := nil;
    if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
      Device := FindProcessingDeviceByUUID(Ch.FlowMeter.Device.UUID);
    if (Device <> nil) and (GetActiveVisibleSession(Device) <> nil) then begin
      SelectTreeItemByTagObject(GetActiveVisibleSession(Device));
      ActionSessionPointsClearExecute(ActionSessionPointsClear); Changed := True;
    end;
    end;
  Result := Changed;
  if Result then ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearCompleted', 'Групповая очистка завершена', 'Scope=AllDevices; DeviceUUID=; Serial=; OldSessionID=0; NewSessionID=0; Spillages=0')
  else ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionClearFailed', 'Нет активных сессий для очистки', 'Scope=AllDevices; Error=NoActiveSessions');
end;

function TFrameProceed.RequestCreateSessions: Boolean;
var Device: TDevice; Ch: TChannel; OldSession: TSessionSpillage;
begin
  Result := False;
  ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateRequested', 'Запрошено групповое создание сессий', 'Scope=AllDevices; DeviceUUID=; Serial=; OldSessionID=0; NewSessionID=0; Spillages=0');
  if not CanManageResultSessions then begin ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateFailed', 'Групповое создание заблокировано', 'Scope=AllDevices; Error=MeasurementActive'); ShowMessage('Во время активного измерения создание сессий недоступно.'); Exit; end;
  if (FActiveWorkTable <> nil) and (FActiveWorkTable.DeviceChannels <> nil) then
    for Ch in FActiveWorkTable.DeviceChannels do begin
    Device := nil;
    if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
      Device := FindProcessingDeviceByUUID(Ch.FlowMeter.Device.UUID);
    if Device = nil then Continue;
    OldSession := GetActiveVisibleSession(Device); SelectTreeItemByTagObject(Device);
    ActionSessionNewExecute(ActionSessionNew);
    Result := Result or (GetActiveVisibleSession(Device) <> OldSession);
  end;
  if Result then ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateCompleted', 'Групповое создание завершено', 'Scope=AllDevices; DeviceUUID=; Serial=; OldSessionID=0; NewSessionID=0; Spillages=0')
  else ProtocolManager.AddMessage(pcProc, psForm, 'ResultsSessionCreateFailed', 'Нет приборов для создания сессий', 'Scope=AllDevices; Error=NoDevices');
end;

procedure TFrameProceed.LoadProcessingDevices;
var
  Ini: TIniFile;
  I, Count: Integer;
  DeviceUUID: string;
  Device: TDevice;
  Repo: TDeviceRepository;
  Point: TPointSpillage;

begin
  if FWorkTableManager <> nil then
    DbgProceedTree(1401, 'LoadProcessingDevices ENTER; Ini=' + FWorkTableManager.IniFileName)
  else
    DbgProceedTree(1401, 'LoadProcessingDevices ENTER; Ini=<nil>');

  if FProcessingDevices = nil then
    Exit;

  FProcessingDevices.Clear;

  if (FWorkTableManager = nil) or (Trim(FWorkTableManager.IniFileName) = '') or
     (not FileExists(FWorkTableManager.IniFileName)) then
    Exit;

  Ini := TIniFile.Create(FWorkTableManager.IniFileName);
  try
    Count := Ini.ReadInteger(CProcessingDevicesSection, CProcessingDevicesCountKey, 0);
    DbgProceedTree(1402, 'LoadProcessingDevices Count=' + Count.ToString);
    for I := 0 to Count - 1 do
    begin
      DeviceUUID := Trim(Ini.ReadString(CProcessingDevicesSection,
        CProcessingDevicesItemKeyPrefix + IntToStr(I), ''));
      if DeviceUUID = '' then
        Continue;

      DbgProceedTree(1403, 'LoadProcessingDevices item: ' + DeviceUUID);

      Device := nil;
      Repo := nil;
      if AppServices.DataManager <> nil then
        Device := AppServices.DataManager.FindDevice(DeviceUUID, Repo);

      if Device <> nil then
      begin
        DbgProceedTree(1404, 'Loaded processing device: ' + Device.Name + #13#10 + Device.UUID);
        LogMKS('DBG SP 8003', 'LoadProcessingDevices LOADED DEVICE DETAILS',
          Format('Device=%s UUID=%s; Sessions=%d; Spillages=%d',
            [Device.Name, Device.UUID, Device.Sessions.Count, Device.Spillages.Count]));
        if Device.Spillages <> nil then
          for Point in Device.Spillages do
            LogMKS('DBG SP 8004', 'LoadProcessingDevices LOADED SPILLAGE', DumpSpillage(Point));
        if (Device.State <> osDeleted) and (FindProcessingDeviceByUUID(Device.UUID) = nil) then
          FProcessingDevices.Add(Device);
      end
      else
        DbgProceedTree(1405, 'Processing device UUID not found in repo: ' + DeviceUUID);
    end;
  finally
    Ini.Free;
  end;
  DbgProceedTree(1406, 'LoadProcessingDevices EXIT; FProcessingDevices.Count=' + FProcessingDevices.Count.ToString);
end;

function FormatSessionPeriodLabel(ASession: TSessionSpillage): string;
var
  DateOpenStr: string;
  DateCloseStr: string;
begin
  if ASession = nil then
    Exit('Сессия -');

  DateOpenStr := '-';
  if ASession.DateTimeOpen > 0 then
    DateOpenStr := DateToStr(ASession.DateTimeOpen);

  if ASession.Active then
    Exit('Сессия ' + DateOpenStr);

  DateCloseStr := '-';
  if ASession.DateTimeClose > 0 then
    DateCloseStr := DateToStr(ASession.DateTimeClose);

  Result := 'Сессия ' + DateOpenStr + '-' + DateCloseStr;
end;


const
  CProceedChartPointColors: array[0..7] of TAlphaColor = (
    $FF1F77B4, $FFD62728, $FF2CA02C, $FFFF7F0E,
    $FF9467BD, $FF17BECF, $FF8C564B, $FFE377C2);
  CProceedChartLineColors: array[0..7] of TAlphaColor = (
    $FF0B3D91, $FF8B0000, $FF006400, $FFB34700,
    $FF4B0082, $FF007C7C, $FF5C2E16, $FFA00068);

function TFrameProceed.GetChartDeviceColor(ADevice: TDevice;
  const ALineColor: Boolean; const ADefaultIndex: Integer): TAlphaColor;
var
  Key: string;
  PaletteIndex: Integer;
begin
  PaletteIndex := ADefaultIndex mod Length(CProceedChartPointColors);
  if ADevice = nil then
    Exit(CProceedChartPointColors[PaletteIndex]);

  Key := Trim(ADevice.UUID);
  if ALineColor then
  begin
    if not FChartLineColors.TryGetValue(Key, Result) then
    begin
      Result := CProceedChartLineColors[PaletteIndex];
      FChartLineColors.AddOrSetValue(Key, Result);
    end;
  end
  else if not FChartPointColors.TryGetValue(Key, Result) then
  begin
    Result := CProceedChartPointColors[PaletteIndex];
    FChartPointColors.AddOrSetValue(Key, Result);
  end;
end;

// Возвращает сохранённую видимость прибора на графике.
function TFrameProceed.IsChartDeviceVisible(ADevice: TDevice): Boolean;
var
  Key: string;
begin
  Result := True;
  if (ADevice = nil) or (FChartDeviceVisibility = nil) then
    Exit;

  Key := Trim(ADevice.UUID);
  if Key = '' then
    Exit;

  if not FChartDeviceVisibility.TryGetValue(Key, Result) then
  begin
    Result := True;
    FChartDeviceVisibility.AddOrSetValue(Key, Result);
  end;
end;

// Перестраивает график: все проливки остаются маркерами, общая точка получает
// единый средний X для всех приборов, а линии строятся без экстраполяции.
procedure TFrameProceed.UpdateSessionErrorChart;
const
  CChartCurvePointsPerInterval = 24;
var
  Device, SelectedDevice: TDevice;
  Session: TSessionSpillage;
  Spillage: TPointSpillage;
  RawPoints, AveragePoints: TList<TPointF>;
  Groups: TObjectDictionary<string, TList<TPointF>>;
  GroupPoints: TList<TPointF>;
  Pair: TPair<string, TList<TPointF>>;
  SharedXGroups, DeviceXGroups: TObjectDictionary<string, TList<Double>>;
  SharedXByGroup: TDictionary<string, Double>;
  XValues: TList<Double>;
  XPair: TPair<string, TList<Double>>;
  PointSeries, AverageSeries, LineSeries: TChartSeries;
  Sorter: IComparer<TPointF>;
  P1: TPointF;
  GroupKey, LegendBase, FlowUnitName: string;
  I, J, DeviceIndex: Integer;
  SumX, SumY: Double;
  FlowValue, SharedFlowValue: Double;
  ChartMinX, ChartMaxX, ChartPaddingX, LogPaddingX: Double;
  UseVolumeFlow: Boolean;

  // Возвращает ключ общей merged-точки Summary, рассчитанной для таблицы
  // обработки; при отсутствии подходящей колонки сохраняет исходный ключ.
  function ResolveChartMergedGroupKey(APoint: TPointSpillage;
    const AFallbackKey: string): string;
  var
    ColumnIndex: Integer;
  begin
    Result := AFallbackKey;
    if APoint = nil then
      Exit;

    for ColumnIndex := 0 to High(FResultPointColumns) do
      if FResultPointColumns[ColumnIndex].IsMerged and
         IsProcessingSpillageInMergedColumn(APoint,
           FResultPointColumns[ColumnIndex]) then
        Exit('MERGED:' + IntToStr(ColumnIndex));
  end;

  // Возвращает фактический расход проливки и ключ её общей точки графика.
  function TryGetSpillageChartFlow(APoint: TPointSpillage;
    out AFlowValue: Double; out AGroupKey: string): Boolean;
  var
    BaseFlowValue: Double;
  begin
    Result := False;
    AFlowValue := 0;
    AGroupKey := '';
    if (APoint = nil) or (APoint.State = osDeleted) or not APoint.Enabled or
       not IsResultErrorValid(APoint.Error) then
      Exit;

    if UseVolumeFlow then
    begin
      BaseFlowValue := APoint.EtalonVolumeFlow;
      if (BaseFlowValue <= 0) and (APoint.SpillTime > 0) then
        BaseFlowValue := APoint.EtalonVolume / APoint.SpillTime;
    end
    else
    begin
      BaseFlowValue := APoint.EtalonMassFlow;
      if (BaseFlowValue <= 0) and (APoint.SpillTime > 0) then
        BaseFlowValue := APoint.EtalonMass / APoint.SpillTime;
    end;

    if BaseFlowValue <= 0 then
      BaseFlowValue := APoint.QavgEtalon;
    AFlowValue := ConvertBaseFlowToUnit(BaseFlowValue, FlowUnitName);
    if IsNan(AFlowValue) or IsInfinite(AFlowValue) or (AFlowValue <= 0) then
      Exit;

    AGroupKey := Trim(APoint.DeviceTypeUUID);
    if AGroupKey = '' then
      AGroupKey := Trim(APoint.Name);
    if AGroupKey = '' then
      AGroupKey := FormatFloat('0.############', AFlowValue);
    AGroupKey := ResolveChartMergedGroupKey(APoint, AGroupKey);
    Result := True;
  end;

  // Собирает фактические расходы активной сессии по поверочным точкам прибора.
  procedure CollectDeviceXGroups(ADevice: TDevice; ASession: TSessionSpillage;
    AGroups: TObjectDictionary<string, TList<Double>>);
  var
    Point: TPointSpillage;
    PointFlow: Double;
    PointKey: string;
    Values: TList<Double>;
    AddedCount: Integer;

    procedure AddPoint(APoint: TPointSpillage);
    begin
      if not TryGetSpillageChartFlow(APoint, PointFlow, PointKey) then
        Exit;
      if not AGroups.TryGetValue(PointKey, Values) then
      begin
        Values := TList<Double>.Create;
        AGroups.Add(PointKey, Values);
      end;
      Values.Add(PointFlow);
      Inc(AddedCount);
    end;
  begin
    AddedCount := 0;
    if (ADevice = nil) or (ASession = nil) or (AGroups = nil) then
      Exit;
    if ADevice.Spillages <> nil then
      for Point in ADevice.Spillages do
        if (Point <> nil) and (Point.SessionID = ASession.ID) then
          AddPoint(Point);
    if (AddedCount = 0) and (ASession <> nil) and
       (ASession.Spillages <> nil) then
      for Point in ASession.Spillages do
        AddPoint(Point);
  end;

  // Добавляет формосохраняющую кусочно-кубическую линию в координате log10(Q).
  function AddPchipLogLine(const APoints: TList<TPointF>;
    ASeries: TChartSeries): Boolean;
  var
    LogX, PointY, H, Delta, Derivative: TArray<Double>;
    PointCount, PointIndex, SegmentIndex, SampleIndex: Integer;
    T, H00, H10, H01, H11, CurveLogX, CurveY: Double;

    function SameNonZeroSign(const A, B: Double): Boolean;
    begin
      Result := not SameValue(A, 0.0) and not SameValue(B, 0.0) and
        ((A > 0) = (B > 0));
    end;

    function EndpointDerivative(const H0, H1, Delta0,
      Delta1: Double): Double;
    begin
      Result := ((2 * H0 + H1) * Delta0 - H0 * Delta1) / (H0 + H1);
      if not SameNonZeroSign(Result, Delta0) then
        Result := 0
      else if not SameNonZeroSign(Delta0, Delta1) and
              (Abs(Result) > 3 * Abs(Delta0)) then
        Result := 3 * Delta0;
    end;
  begin
    Result := False;
    if (APoints = nil) or (ASeries = nil) or (APoints.Count < 3) then
      Exit;

    PointCount := APoints.Count;
    SetLength(LogX, PointCount);
    SetLength(PointY, PointCount);
    SetLength(H, PointCount - 1);
    SetLength(Delta, PointCount - 1);
    SetLength(Derivative, PointCount);
    for PointIndex := 0 to PointCount - 1 do
    begin
      if APoints[PointIndex].X <= 0 then
        Exit;
      LogX[PointIndex] := Log10(APoints[PointIndex].X);
      PointY[PointIndex] := APoints[PointIndex].Y;
      if (PointIndex > 0) and
         (LogX[PointIndex] <= LogX[PointIndex - 1]) then
        Exit;
    end;

    for PointIndex := 0 to PointCount - 2 do
    begin
      H[PointIndex] := LogX[PointIndex + 1] - LogX[PointIndex];
      Delta[PointIndex] :=
        (PointY[PointIndex + 1] - PointY[PointIndex]) / H[PointIndex];
    end;

    Derivative[0] := EndpointDerivative(H[0], H[1], Delta[0], Delta[1]);
    Derivative[PointCount - 1] := EndpointDerivative(
      H[PointCount - 2], H[PointCount - 3], Delta[PointCount - 2],
      Delta[PointCount - 3]);
    for PointIndex := 1 to PointCount - 2 do
      if SameNonZeroSign(Delta[PointIndex - 1], Delta[PointIndex]) then
        Derivative[PointIndex] :=
          (2 * H[PointIndex] + H[PointIndex - 1] + H[PointIndex] +
           2 * H[PointIndex - 1]) /
          ((2 * H[PointIndex] + H[PointIndex - 1]) /
             Delta[PointIndex - 1] +
           (H[PointIndex] + 2 * H[PointIndex - 1]) /
             Delta[PointIndex])
      else
        Derivative[PointIndex] := 0;

    for SegmentIndex := 0 to PointCount - 2 do
      for SampleIndex := 0 to CChartCurvePointsPerInterval do
      begin
        if (SegmentIndex > 0) and (SampleIndex = 0) then
          Continue;
        T := SampleIndex / CChartCurvePointsPerInterval;
        H00 := 2 * T * T * T - 3 * T * T + 1;
        H10 := T * T * T - 2 * T * T + T;
        H01 := -2 * T * T * T + 3 * T * T;
        H11 := T * T * T - T * T;
        CurveLogX := LogX[SegmentIndex] + H[SegmentIndex] * T;
        CurveY := H00 * PointY[SegmentIndex] +
          H10 * H[SegmentIndex] * Derivative[SegmentIndex] +
          H01 * PointY[SegmentIndex + 1] +
          H11 * H[SegmentIndex] * Derivative[SegmentIndex + 1];
        if IsNan(CurveY) or IsInfinite(CurveY) then
          Exit;
        ASeries.AddPoint(Power(10, CurveLogX), CurveY);
      end;
    Result := ASeries.Points.Count > 1;
  end;

  procedure AddSpillagePoint(APoint: TPointSpillage);
  begin
    if not TryGetSpillageChartFlow(APoint, FlowValue, GroupKey) then
      Exit;

    P1 := PointF(FlowValue, APoint.Error);
    RawPoints.Add(P1);
    ChartMinX := Min(ChartMinX, FlowValue);
    ChartMaxX := Max(ChartMaxX, FlowValue);
    if not Groups.TryGetValue(GroupKey, GroupPoints) then
    begin
      GroupPoints := TList<TPointF>.Create;
      Groups.Add(GroupKey, GroupPoints);
    end;
    GroupPoints.Add(P1);
  end;

begin
  if Chart1 = nil then
    Exit;

  FlowUnitName := '';
  if ComboBoxUnitsResult <> nil then
    FlowUnitName := Trim(ComboBoxUnitsResult.Text);
  if (FlowUnitName = '') and (FActiveWorkTable <> nil) then
    FlowUnitName := Trim(FActiveWorkTable.FlowUnitName);
  if FlowUnitName = '' then
    FlowUnitName := 'л/с';

  UseVolumeFlow := IsVolumeFlowUnit(FlowUnitName);
  ChartMinX := MaxDouble;
  ChartMaxX := -MaxDouble;
  Chart1.XTitle := 'Расход, ' + FlowUnitName;
  Chart1.LogarithmicX := FChartFlowScale = cfsLogarithmic;
  // Внешние подписи координат размещаются в увеличенных полях осей.
  Chart1.MarginLeft := 105;
  Chart1.MarginBottom := 70;
  Chart1.BeginUpdate;
  SharedXGroups := TObjectDictionary<string, TList<Double>>.Create([doOwnsValues]);
  SharedXByGroup := TDictionary<string, Double>.Create;
  try
    Chart1.ClearAllSeries;
    SelectedDevice := ResolveSelectedDevice;
    DeviceIndex := 0;
    Sorter := TComparer<TPointF>.Construct(
      function(const Left, Right: TPointF): Integer
      begin
        if Left.X < Right.X then
          Result := -1
        else if Left.X > Right.X then
          Result := 1
        else
          Result := 0;
      end);

    // Сначала рассчитывается одна общая координата X для каждой общей
    // поверочной точки по средним расходам участвующих приборов.
    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
      begin
        if (Device = nil) or (Device.State = osDeleted) or
           IsProcessingDevicePendingRemoved(Device) or
           not IsChartDeviceVisible(Device) then
          Continue;
        if (Device = SelectedDevice) and (FCurrentSession <> nil) then
          Session := FCurrentSession
        else
          Session := GetActiveVisibleSession(Device);
        if Session = nil then
          Continue;

        DeviceXGroups := TObjectDictionary<string, TList<Double>>.Create([doOwnsValues]);
        try
          CollectDeviceXGroups(Device, Session, DeviceXGroups);
          for XPair in DeviceXGroups do
          begin
            SumX := 0;
            for J := 0 to XPair.Value.Count - 1 do
              SumX := SumX + XPair.Value[J];
            if XPair.Value.Count = 0 then
              Continue;
            if not SharedXGroups.TryGetValue(XPair.Key, XValues) then
            begin
              XValues := TList<Double>.Create;
              SharedXGroups.Add(XPair.Key, XValues);
            end;
            XValues.Add(SumX / XPair.Value.Count);
          end;
        finally
          DeviceXGroups.Free;
        end;
      end;

    for XPair in SharedXGroups do
    begin
      SumX := 0;
      for J := 0 to XPair.Value.Count - 1 do
        SumX := SumX + XPair.Value[J];
      if XPair.Value.Count > 0 then
        SharedXByGroup.AddOrSetValue(XPair.Key,
          SumX / XPair.Value.Count);
    end;

    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
      begin
        if (Device = nil) or (Device.State = osDeleted) or
           IsProcessingDevicePendingRemoved(Device) then
          Continue;

        if not IsChartDeviceVisible(Device) then
        begin
          Inc(DeviceIndex);
          Continue;
        end;

        if (Device = SelectedDevice) and (FCurrentSession <> nil) then
          Session := FCurrentSession
        else
          Session := GetActiveVisibleSession(Device);
        if Session = nil then
        begin
          Inc(DeviceIndex);
          Continue;
        end;

        RawPoints := TList<TPointF>.Create;
        AveragePoints := TList<TPointF>.Create;
        Groups := TObjectDictionary<string, TList<TPointF>>.Create([doOwnsValues]);
        try
          if Device.Spillages <> nil then
            for Spillage in Device.Spillages do
              if (Spillage <> nil) and (Spillage.SessionID = Session.ID) then
                AddSpillagePoint(Spillage);
          if (RawPoints.Count = 0) and (Session.Spillages <> nil) then
            for Spillage in Session.Spillages do
              AddSpillagePoint(Spillage);
          if RawPoints.Count = 0 then
          begin
            Inc(DeviceIndex);
            Continue;
          end;

          RawPoints.Sort(Sorter);
          // Для каждой измерительной точки усредняются обе координаты
          // всех её повторов: расход X и погрешность Y.
          for Pair in Groups do
          begin
            SumX := 0;
            SumY := 0;
            for J := 0 to Pair.Value.Count - 1 do
            begin
              SumX := SumX + Pair.Value[J].X;
              SumY := SumY + Pair.Value[J].Y;
            end;
            if Pair.Value.Count > 0 then
            begin
              if not SharedXByGroup.TryGetValue(Pair.Key, SharedFlowValue) then
                SharedFlowValue := SumX / Pair.Value.Count;
              AveragePoints.Add(PointF(SharedFlowValue,
                SumY / Pair.Value.Count));
            end;
          end;
          AveragePoints.Sort(Sorter);

          LegendBase := Trim(Device.Name);
          if Trim(Device.SerialNumber) <> '' then
            LegendBase := LegendBase + ' [' + Trim(Device.SerialNumber) + ']';

          PointSeries := Chart1.AddSeries(LegendBase + ' — точки');
          PointSeries.Color := GetChartDeviceColor(Device, False, DeviceIndex);
          PointSeries.ShowLine := False;
          PointSeries.ShowMarkers := True;
          PointSeries.ShowPointGuides := False;
          PointSeries.MarkerRadius := 4;
          for I := 0 to RawPoints.Count - 1 do
            PointSeries.AddPoint(RawPoints[I].X, RawPoints[I].Y);

          // Проекции и подписи координат отображаются только для средних точек.
          AverageSeries := Chart1.AddSeries('');
          AverageSeries.Color := GetChartDeviceColor(Device, True, DeviceIndex);
          AverageSeries.ShowLine := False;
          AverageSeries.ShowMarkers := True;
          AverageSeries.ShowPointGuides := True;
          AverageSeries.MarkerRadius := 5;
          for I := 0 to AveragePoints.Count - 1 do
            AverageSeries.AddPoint(AveragePoints[I].X, AveragePoints[I].Y);

          LineSeries := Chart1.AddSeries('');
          LineSeries.Color := GetChartDeviceColor(Device, True, DeviceIndex);
          LineSeries.ShowLine := True;
          LineSeries.ShowMarkers := False;
          LineSeries.Thickness := 2;

          if FChartAverageLineMode = calmPchipLogQ then
          begin
            LineSeries.LegendName := LegendBase + ' — PCHIP log(Q)';
            if not AddPchipLogLine(AveragePoints, LineSeries) then
            begin
              LineSeries.ClearPoints;
              LineSeries.LegendName := LegendBase + ' — отрезки';
              for I := 0 to AveragePoints.Count - 1 do
                LineSeries.AddPoint(AveragePoints[I].X, AveragePoints[I].Y);
            end;
          end
          else
          begin
            LineSeries.LegendName := LegendBase + ' — отрезки';
            for I := 0 to AveragePoints.Count - 1 do
              LineSeries.AddPoint(AveragePoints[I].X, AveragePoints[I].Y);
          end;
          Inc(DeviceIndex);
        finally
          Groups.Free;
          AveragePoints.Free;
          RawPoints.Free;
        end;
      end;
  finally
    SharedXByGroup.Free;
    SharedXGroups.Free;
    if (ChartMinX <> MaxDouble) and (ChartMaxX <> -MaxDouble) then
    begin
      Chart1.AutoRangeX := False;
      if FChartFlowScale = cfsLogarithmic then
      begin
        if SameValue(ChartMinX, ChartMaxX) then
        begin
          Chart1.XMin := ChartMinX / 1.1;
          Chart1.XMax := ChartMaxX * 1.1;
        end
        else
        begin
          LogPaddingX := (Log10(ChartMaxX) - Log10(ChartMinX)) * 0.05;
          Chart1.XMin := Power(10, Log10(ChartMinX) - LogPaddingX);
          Chart1.XMax := Power(10, Log10(ChartMaxX) + LogPaddingX);
        end;
      end
      else
      begin
        if SameValue(ChartMinX, ChartMaxX) then
          ChartPaddingX := Max(Abs(ChartMaxX) * 0.1, 1.0)
        else
          ChartPaddingX := (ChartMaxX - ChartMinX) * 0.1;
        Chart1.XMin := ChartMinX;
        Chart1.XMax := ChartMaxX + ChartPaddingX;
      end;
    end
    else
      Chart1.AutoRangeX := True;
    Chart1.EndUpdate;
  end;
end;

// Применяет выбранную единицу расхода к таблице и графику текущей сессии.
procedure TFrameProceed.ComboBoxUnitsResultChange(Sender: TObject);
var
  UnitName, QuantityUnitName: string;
begin
  if ComboBoxUnitsResult = nil then
    Exit;

  UnitName := Trim(ComboBoxUnitsResult.Text);
  if UnitName = '' then
    Exit;

  QuantityUnitName := ResolveQuantityUnitByFlowUnit(UnitName);
  SetSessionDim(UnitName, QuantityUnitName);
  UpdateGridDataPointsHeaders(QuantityUnitName, UnitName);
  UpdateGridDataPoints;
  UpdateSessionErrorChart;
end;

// Формирует ПКМ: видимость и палитры цветов каждого прибора.
procedure TFrameProceed.Chart1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
const
  ColorNames: array[0..9] of string = ('Красный', 'Синий', 'Зелёный',
    'Оранжевый', 'Фиолетовый', 'Бирюзовый', 'Жёлтый', 'Розовый',
    'Серый', 'Чёрный');
  Colors: array[0..9] of TAlphaColor = ($FFFF3030, $FF2878D0,
    $FF20A050, $FFFF8C20, $FF8848C0, $FF20A8A8, $FFE0C020, $FFE85090,
    $FF808080, $FF202020);
var
  Device: TDevice;
  DeviceItem, VisibilityItem, PointColorItem, LineColorItem: TMenuItem;
  ColorItem: TChartDeviceColorMenuItem;
  PointColor, LineColor: TAlphaColor;
  ItemText: string;
  I: Integer;
  P: TPointF;
begin
  if (Button <> TMouseButton.mbRight) or not (Sender is TControl) or
     (PopupMenuChart = nil) or (MenuItemChartDevices = nil) then
    Exit;

  MenuItemChartLinePchip.IsChecked := FChartAverageLineMode = calmPchipLogQ;
  MenuItemChartLineSegments.IsChecked :=
    FChartAverageLineMode = calmLinearSegments;
  MenuItemChartScaleLog.IsChecked := FChartFlowScale = cfsLogarithmic;
  MenuItemChartScaleLinear.IsChecked := FChartFlowScale = cfsLinear;

  while MenuItemChartDevices.ItemsCount > 0 do
    MenuItemChartDevices.Items[MenuItemChartDevices.ItemsCount - 1].Free;

  if FProcessingDevices <> nil then
    for Device in FProcessingDevices do
      if (Device <> nil) and (Device.State <> osDeleted) and
         not IsProcessingDevicePendingRemoved(Device) then
      begin
        ItemText := Trim(Device.Name);
        if Trim(Device.SerialNumber) <> '' then
          ItemText := ItemText + ' [' + Trim(Device.SerialNumber) + ']';

        DeviceItem := TMenuItem.Create(nil);
        DeviceItem.Text := ItemText;
        MenuItemChartDevices.AddObject(DeviceItem);

        VisibilityItem := TMenuItem.Create(nil);
        VisibilityItem.Text := 'Показывать';
        VisibilityItem.TagObject := Device;
        VisibilityItem.IsChecked := IsChartDeviceVisible(Device);
        VisibilityItem.OnClick := ChartDeviceVisibilityMenuClick;
        DeviceItem.AddObject(VisibilityItem);

        PointColor := GetChartDeviceColor(Device, False, 0);
        PointColorItem := TMenuItem.Create(nil);
        PointColorItem.Text := 'Цвет точек';
        DeviceItem.AddObject(PointColorItem);
        for I := Low(Colors) to High(Colors) do
        begin
          ColorItem := TChartDeviceColorMenuItem.Create(nil);
          ColorItem.Text := ColorNames[I];
          ColorItem.DeviceUUID := Device.UUID;
          ColorItem.NewColor := Colors[I];
          ColorItem.IsChecked := PointColor = Colors[I];
          ColorItem.OnClick := ChartPointColorMenuClick;
          PointColorItem.AddObject(ColorItem);
        end;

        LineColor := GetChartDeviceColor(Device, True, 0);
        LineColorItem := TMenuItem.Create(nil);
        LineColorItem.Text := 'Цвет линии';
        DeviceItem.AddObject(LineColorItem);
        for I := Low(Colors) to High(Colors) do
        begin
          ColorItem := TChartDeviceColorMenuItem.Create(nil);
          ColorItem.Text := ColorNames[I];
          ColorItem.DeviceUUID := Device.UUID;
          ColorItem.NewColor := Colors[I];
          ColorItem.IsChecked := LineColor = Colors[I];
          ColorItem.OnClick := ChartLineColorMenuClick;
          LineColorItem.AddObject(ColorItem);
        end;
      end;

  P := TControl(Sender).LocalToScreen(PointF(X, Y));
  PopupMenuChart.Popup(P.X, P.Y);
end;

// Переключает видимость серий независимо от состояния Enabled прибора.
procedure TFrameProceed.ChartDeviceVisibilityMenuClick(Sender: TObject);
var
  Device: TDevice;
  Item: TMenuItem;
  NewVisible: Boolean;
begin
  if not (Sender is TMenuItem) then
    Exit;

  Item := TMenuItem(Sender);
  if not (Item.TagObject is TDevice) then
    Exit;

  Device := TDevice(Item.TagObject);
  NewVisible := not IsChartDeviceVisible(Device);
  FChartDeviceVisibility.AddOrSetValue(Device.UUID, NewVisible);
  Item.IsChecked := NewVisible;
  UpdateSessionErrorChart;
end;

// Применяет выбранный в палитре ПКМ цвет исходных точек прибора.
procedure TFrameProceed.ChartPointColorMenuClick(Sender: TObject);
var
  Item: TChartDeviceColorMenuItem;
begin
  if not (Sender is TChartDeviceColorMenuItem) then
    Exit;

  Item := TChartDeviceColorMenuItem(Sender);
  FChartPointColors.AddOrSetValue(Item.DeviceUUID, Item.NewColor);
  UpdateSessionErrorChart;
end;

// Применяет выбранный в палитре ПКМ цвет усреднённой линии прибора.
procedure TFrameProceed.ChartLineColorMenuClick(Sender: TObject);
var
  Item: TChartDeviceColorMenuItem;
begin
  if not (Sender is TChartDeviceColorMenuItem) then
    Exit;

  Item := TChartDeviceColorMenuItem(Sender);
  FChartLineColors.AddOrSetValue(Item.DeviceUUID, Item.NewColor);
  UpdateSessionErrorChart;
end;

// Переключает алгоритм соединения средних точек без изменения исходных проливок.
procedure TFrameProceed.ChartLineModeMenuClick(Sender: TObject);
begin
  if Sender = MenuItemChartLinePchip then
    FChartAverageLineMode := calmPchipLogQ
  else if Sender = MenuItemChartLineSegments then
    FChartAverageLineMode := calmLinearSegments
  else
    Exit;

  MenuItemChartLinePchip.IsChecked := FChartAverageLineMode = calmPchipLogQ;
  MenuItemChartLineSegments.IsChecked :=
    FChartAverageLineMode = calmLinearSegments;
  UpdateSessionErrorChart;
end;

// Переключает геометрию оси X; значения расхода в сериях остаются физическими.
procedure TFrameProceed.ChartScaleMenuClick(Sender: TObject);
begin
  if Sender = MenuItemChartScaleLog then
    FChartFlowScale := cfsLogarithmic
  else if Sender = MenuItemChartScaleLinear then
    FChartFlowScale := cfsLinear
  else
    Exit;

  MenuItemChartScaleLog.IsChecked := FChartFlowScale = cfsLogarithmic;
  MenuItemChartScaleLinear.IsChecked := FChartFlowScale = cfsLinear;
  UpdateSessionErrorChart;
end;

procedure TFrameProceed.UpdateSessionItems;
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  UnitName: string;
  QuantityUnitName: string;
begin
  Session := nil;
  Device := nil;

  if (TreeViewDevices <> nil) and (TreeViewDevices.Selected <> nil) then
  begin
    Item := TreeViewDevices.Selected;

    if Item.TagObject is TSessionSpillage then
      Session := TSessionSpillage(Item.TagObject);

    if Item.TagObject is TDevice then
      Device := TDevice(Item.TagObject)
    else if (Item.ParentItem <> nil) and (Item.ParentItem.TagObject is TDevice) then
      Device := TDevice(Item.ParentItem.TagObject);
  end;

  if (Session = nil) and (Device <> nil) then
    Session := GetActiveVisibleSession(Device);

  FCurrentSession := Session;

  if LabelSessionDate <> nil then
  begin
    if FCurrentSession = nil then
      LabelSessionDate.Text := 'Сессия'
    else
      LabelSessionDate.Text := FormatSessionPeriodLabel(FCurrentSession);
  end;

  if (Device <> nil) then
  begin
    ResolveSelectedDevice;
    UpdateCalibrCoefsFrame;

    if FSessionDevice <> nil then
    begin
      FSessionDevice.ApplyMeasurementModel;
      FSessionDevice.ApplyError;
    end;

    if FSessionEtalon <> nil then
    begin
      FSessionEtalon.ApplyMeasurementModel;
      FSessionEtalon.ApplyError;
    end;
  end
  else
  begin
    if FSessionDevice <> nil then
      FSessionDevice.Device := nil;
    if FSessionEtalon <> nil then
      FSessionEtalon.Device := nil;

    UpdateCalibrCoefsFrame;
  end;


  if (ComboBoxUnitsResult <> nil) then
    UnitName := Trim(ComboBoxUnitsResult.Text);

  if UnitName <> '' then
  begin
    QuantityUnitName := ResolveQuantityUnitByFlowUnit(UnitName);
    SetSessionDim(UnitName, QuantityUnitName);
    UpdateGridDataPointsHeaders(QuantityUnitName, UnitName);
  end;

  if (Device <> nil) then
  begin
    if FCurrentSession <> nil then
      ShowSessionSpillages(FCurrentSession)
    else
      ShowSessionSpillages(nil);
  end
  else if (TreeViewDevices <> nil) and (TreeViewDevices.Selected <> nil) then
  begin
    Item := TreeViewDevices.Selected;
    if Item.Text = '...' then
      ShowAllDevicesResults
    else if Item.TagObject is TWorkTable then
      ShowWorkTableResults(TWorkTable(Item.TagObject))
    else if Item.Text = 'прочее' then
      ShowOtherDevicesResults;
  end;
  UpdateSessionErrorChart;
  UpdateActionHints;
end;

procedure TFrameProceed.PopulateTreeViewDevices;
var
  RootAll, RootOther, RootTable, DeviceItem, SessionItem: TTreeViewItem;
  I: Integer;
  WT: TWorkTable;
  Ch: TChannel;
  Device: TDevice;
  ProcessedOnTables: TStringList;
  TableDeviceUUIDs: TStringList;

  procedure AddDeviceNode(const AParent: TTreeViewItem; ADevice: TDevice);
  var
    Sess: TSessionSpillage;
    Point: TPointSpillage;
  begin
    if (AParent = nil) or (ADevice = nil) or (ADevice.State = osDeleted) or
       IsProcessingDevicePendingRemoved(ADevice) then
      Exit;

    DeviceItem := TTreeViewItem.Create(TreeViewDevices);
    DeviceItem.Text := ADevice.Name;
    DeviceItem.TagObject := ADevice;
    DeviceItem.TagString := 'D|' + ADevice.UUID;
    AParent.AddObject(DeviceItem);
    LogMKS('DBG SP 9001', 'PopulateTreeViewDevices ADD DEVICE',
      Format('Device=%s UUID=%s; Sessions=%d; Spillages=%d',
        [ADevice.Name, ADevice.UUID, ADevice.Sessions.Count, ADevice.Spillages.Count]));
    if ADevice.Spillages <> nil then
      for Point in ADevice.Spillages do
        LogMKS('DBG SP 9003', 'PopulateTreeViewDevices ADD SPILLAGE', DumpSpillage(Point));

    if ADevice.Sessions <> nil then
      for Sess in ADevice.Sessions do
      begin
        if (Sess = nil) or (Sess.State = osDeleted) then
          Continue;

        SessionItem := TTreeViewItem.Create(TreeViewDevices);
        SessionItem.Text :=
          Format('Сессия #%d (%s)', [Sess.ID, DateToStr(Sess.DateTimeOpen)]);
        SessionItem.TagObject := Sess;
        SessionItem.TagString := Format('S|%s|%d', [ADevice.UUID, Sess.ID]);
        DeviceItem.AddObject(SessionItem);
        LogMKS('DBG SP 9002', 'PopulateTreeViewDevices ADD SESSION',
          Format('Device=%s UUID=%s; Session.ID=%d; Session.Spillages.Count=%d',
            [ADevice.Name, ADevice.UUID, Sess.ID, Sess.Spillages.Count]));
      end;
  end;
begin
  DbgProceedTree(1201, 'PopulateTreeViewDevices ENTER'#13#10 + GetSelectedTreeDebugText);
  ProcessedOnTables := TStringList.Create;
  try
    ProcessedOnTables.Sorted := False;
    ProcessedOnTables.Duplicates := TDuplicates.dupIgnore;

    TreeViewDevices.BeginUpdate;
    try
      DbgProceedTree(1202, 'Before TreeViewDevices.Clear'#13#10 + GetSelectedTreeDebugText);
      TreeViewDevices.Clear;
      DbgProceedTree(1203, 'After TreeViewDevices.Clear'#13#10 + GetSelectedTreeDebugText);

      RootAll := TTreeViewItem.Create(TreeViewDevices);
      RootAll.Text := '...';
      TreeViewDevices.AddObject(RootAll);

      if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
        for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
        begin
          WT := FWorkTableManager.WorkTables[I];
          if WT = nil then
            Continue;

          RootTable := TTreeViewItem.Create(TreeViewDevices);
          RootTable.Text := WT.Name;
          RootTable.TagObject := WT;
          TreeViewDevices.AddObject(RootTable);

          TableDeviceUUIDs := TStringList.Create;
          try
            TableDeviceUUIDs.Sorted := False;
            TableDeviceUUIDs.Duplicates := TDuplicates.dupIgnore;

            for Ch in WT.DeviceChannels do
            begin
              if (Ch = nil) or (Ch.FlowMeter = nil) or (Ch.FlowMeter.Device = nil) then
                Continue;

              Device := FindProcessingDeviceByUUID(Ch.FlowMeter.Device.UUID);
              if Device = nil then
                Continue;

              if TableDeviceUUIDs.IndexOf(Device.UUID) >= 0 then
                Continue;

              TableDeviceUUIDs.Add(Device.UUID);

              if ProcessedOnTables.IndexOf(Device.UUID) < 0 then
                ProcessedOnTables.Add(Device.UUID);

              DbgProceedTree(1206, 'Add device to WORKTABLE: ' + Device.Name + #13#10 + Device.UUID);
              AddDeviceNode(RootTable, Device);
            end;
          finally
            TableDeviceUUIDs.Free;
          end;
        end;

      RootOther := TTreeViewItem.Create(TreeViewDevices);
      RootOther.Text := 'прочее';
      TreeViewDevices.AddObject(RootOther);
      DbgProceedTree(1204, 'RootOther created; Count=' + RootOther.Count.ToString);

      if FProcessingDevices <> nil then
        for Device in FProcessingDevices do
          if (Device <> nil) and IsManualProcessingDevice(Device) and
             (ProcessedOnTables.IndexOf(Device.UUID) < 0) then
          begin
            DbgProceedTree(1205, 'Add device to OTHER: ' + Device.Name + #13#10 + Device.UUID);
            AddDeviceNode(RootOther, Device);
          end;

      if TreeViewDevices.Count > 0 then
        TreeViewDevices.Selected := TreeViewDevices.ItemByIndex(0);
      DbgProceedTree(1207, 'PopulateTreeViewDevices EXIT'#13#10 + GetSelectedTreeDebugText);
    finally
      TreeViewDevices.EndUpdate;
    end;
  finally
    ProcessedOnTables.Free;
  end;
  UpdateActionHints;
end;
function TFrameProceed.GetStatusColor(const AStatus: Integer): TAlphaColor;
begin
  case AStatus of
    2: Result := TAlphaColors.Null;
    3: Result := COLOR_INVALID;
    4: Result := COLOR_WARNING;
    5: Result := COLOR_COMPLETED;
  else
    Result := TAlphaColors.Null;
  end;
end;

function TFrameProceed.GetSpillageResultHint(ADevice: TDevice;
  APoint: TPointSpillage): string;
begin
  Result := '';
  if APoint = nil then
    Exit;
  Result := APoint.GetFullStateText;
end;

function TFrameProceed.GetDeviceResultHint(ADevice: TDevice): string;
var DevicePoint: TDevicePoint; Spillage: TPointSpillage; SummaryStatus: Integer;
begin
  Result := 'Статус годности не определён.' + sLineBreak +
    'Недостаточно данных для оценки.';
  if (ADevice = nil) or (ADevice.Points = nil) then Exit;
  SummaryStatus := ResolveDeviceSummaryStatus(ADevice);
  if SummaryStatus = 5 then
  begin
    for DevicePoint in ADevice.Points do
    begin
      Spillage := FindResultSpillageForPoint(ADevice, DevicePoint);
      if (Spillage <> nil) and (Spillage.Validation = vsValid) then
        Exit(GetSpillageResultHint(ADevice, Spillage));
    end;
    Exit;
  end;
  if SummaryStatus <> 4 then
  begin
    for DevicePoint in ADevice.Points do
    begin
      Spillage := FindResultSpillageForPoint(ADevice, DevicePoint);
      if (Spillage <> nil) and
         (Spillage.ValidationReason = svrStopCriteriaFailed) then
        Exit(GetSpillageResultHint(ADevice, Spillage));
    end;
    Exit;
  end;
  for DevicePoint in ADevice.Points do
  begin
    Spillage := FindResultSpillageForPoint(ADevice, DevicePoint);
    if (Spillage <> nil) and
       (Spillage.Validation = vsInvalid) then
      Exit(GetSpillageResultHint(ADevice, Spillage));
  end;
end;

procedure TFrameProceed.LogProceedGridContext(const AContext: string;
  ADevice: TDevice; ASession: TSessionSpillage; ARows, AColumns: Integer);
var DeviceUUID, SessionID: string;
begin
  DeviceUUID := ''; SessionID := '';
  if ADevice <> nil then DeviceUUID := ADevice.UUID;
  if ASession <> nil then SessionID := ASession.ID.ToString;
  ProtocolManager.AddMessage(pcProc, psForm, 'ProceedGridContext',
    'Построена таблица обработки', Format('Context=%s; DeviceUUID=%s; SessionID=%s; Rows=%d; Columns=%d',
      [AContext, DeviceUUID, SessionID, ARows, AColumns]));
end;

function TFrameProceed.IsResultErrorValid(const AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue) and
    (Abs(AValue) < MaxDouble);
end;

function TFrameProceed.FormatResultErrorValue(const AValue: Double): string;
begin
  if not IsResultErrorValid(AValue) then
    Exit('-');

  if (FSessionDevice <> nil) and (FSessionDevice.ValueError <> nil) then
    Result := FSessionDevice.ValueError.GetStrNum(AValue)
  else
    Result := '-';
end;

function TFrameProceed.GetPointResultColor(ADevice: TDevice;
  ADevicePoint: TDevicePoint; ASpillage: TPointSpillage): TAlphaColor;
begin
  Result := GetSpillageErrorResultColor(ASpillage);
end;

function TFrameProceed.GetSpillageErrorResultColor(ASpillage: TPointSpillage): TAlphaColor;
begin
  Result := TAlphaColors.Null;
  if ASpillage = nil then
    Exit;

  case ASpillage.ValidationReason of
    svrErrorWithinTolerance:
      Result := COLOR_COMPLETED;
    svrErrorExceeded:
      Result := COLOR_WARNING;
  else
    Result := TAlphaColors.Null;
  end;
end;

function TFrameProceed.ResolveDeviceSummaryStatus(ADevice: TDevice): Integer;
var
  Point: TDevicePoint;
  Spillage: TPointSpillage;
  FoundPointsCount, RequiredPointsCount, InvalidCount, ConditionFailedCount: Integer;
begin
  Result := 2;
  if ADevice = nil then
    Exit;
  FoundPointsCount := 0;
  RequiredPointsCount := 0;
  InvalidCount := 0;
  ConditionFailedCount := 0;
  if ADevice.Points <> nil then
  begin
    RequiredPointsCount := ADevice.Points.Count;
    for Point in ADevice.Points do
    begin
      if Point = nil then
        Continue;
      Spillage := FindResultSpillageForPoint(ADevice, Point);
      if (Spillage = nil) or not IsResultErrorValid(Spillage.Error) then
        Continue;
      Inc(FoundPointsCount);
      if Spillage.Validation = vsInvalid then
        Inc(InvalidCount);
      if Spillage.ValidationReason = svrStopCriteriaFailed then
        Inc(ConditionFailedCount);
    end;
  end;
  if FoundPointsCount = 0 then
    Result := 2
  else if InvalidCount > 0 then
    Result := 4
  else if ConditionFailedCount > 0 then
    Result := 2
  else if FoundPointsCount < RequiredPointsCount then
    Result := 2
  else
    Result := 5;
end;

function TFrameProceed.GetDeviceResultText(ADevice: TDevice): string;
begin
  if ADevice = nil then Exit('-');
  Result := ADevice.GetShortStateText;
end;

function TFrameProceed.GetDeviceResultColor(ADevice: TDevice): TAlphaColor;
begin
  if ADevice = nil then Exit(TAlphaColors.Null);
  Result := GetDeviceValidationColor(ADevice.Validation, ADevice.ValidationReason);
end;
function TFrameProceed.BuildResultTextByStatus(const AStatus: Integer): string;
begin
  case AStatus of
    1, 2: Result := #$2014;
    3, 4: Result := 'Не годен';
    5: Result := 'Годен';
  else
    Result := '-';
  end;
end;

function TFrameProceed.BuildResultComment(ADevice: TDevice;
  const AStatus: Integer): string;
var
  Spillage: TPointSpillage;
  DevicePoint:tDevicePoint;
begin
  Result := '';
  if (ADevice = nil) or (ADevice.Points = nil) then
    Exit;

  if AStatus = 5 then
  begin
    for DevicePoint in ADevice.Points do
    begin
      Spillage := FindResultSpillageForPoint(ADevice, DevicePoint);
      if (Spillage <> nil) and (Spillage.ValidationReason = svrErrorWithinTolerance) then
        Exit(SpillageValidationReasonToText(Spillage.ValidationReason));
    end;
    Exit;
  end;

  for DevicePoint in ADevice.Points do
  begin
    Spillage := FindResultSpillageForPoint(ADevice, DevicePoint);
    if (Spillage <> nil) and (Spillage.ValidationReason <> svrNone) and
       (Spillage.ValidationReason <> svrNotAnalyzed) then
      Exit(SpillageValidationReasonToText(Spillage.ValidationReason));
  end;
end;

function TFrameProceed.BuildSpillageStatusText(ASpillage: TPointSpillage): string;
begin
  Result := #$2014;
  if ASpillage = nil then
    Exit;
  case ASpillage.Validation of
    vsValid:
      Result := 'Годен';
    vsInvalid:
      Result := 'Не годен';
  else
    Result := #$2014;
  end;
end;

function TFrameProceed.BuildSpillageCommentText(ASpillage: TPointSpillage): string;
begin
  Result := '';
  if (ASpillage = nil) or (ASpillage.ValidationReason in [svrNone, svrNotAnalyzed]) then
    Exit;
  Result := SpillageValidationReasonToText(ASpillage.ValidationReason);
end;

function TFrameProceed.FindResultPointForColumn(ADevice: TDevice;
  const AColumn: TProceedResultPointColumn): TDevicePoint;
var
  I: Integer;
  P: TDevicePoint;
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.Points = nil) then
    Exit;
  if (Trim(AColumn.DeviceUUID) <> '') and
     (not SameText(Trim(AColumn.DeviceUUID), Trim(ADevice.UUID))) then
    Exit;
  if Trim(AColumn.SourcePointUUID) <> '' then
    for I := 0 to ADevice.Points.Count - 1 do
      if (ADevice.Points[I] <> nil) and
         SameText(Trim(ADevice.Points[I].UUID), Trim(AColumn.SourcePointUUID)) then
        Exit(ADevice.Points[I]);
  if AColumn.ScenarioPoint <> nil then
  begin
    for I := 0 to High(AColumn.ScenarioPoint.Participants) do
      if SameText(Trim(AColumn.ScenarioPoint.Participants[I].DeviceUUID), Trim(ADevice.UUID)) and
         (Trim(AColumn.ScenarioPoint.Participants[I].SourcePointUUID) <> '') then
        for P in ADevice.Points do
          if (P <> nil) and SameText(Trim(P.UUID),
             Trim(AColumn.ScenarioPoint.Participants[I].SourcePointUUID)) then
            Exit(P);

    for I := 0 to ADevice.Points.Count - 1 do
      if (ADevice.Points[I] <> nil) and
         TMeasurementRun.IsPointEquivalent(ADevice.Points[I], AColumn.ScenarioPoint) then
        Exit(ADevice.Points[I]);
  end;
end;

function TFrameProceed.IsProcessingSpillageInMergedColumn(ASpillage: TPointSpillage;
  const AColumn: TProceedResultPointColumn): Boolean;
var
  Device: TDevice;
  PointMinQ, PointMaxQ, PointDeltaQ: Double;
  NewCommonMinQ, NewCommonMaxQ, IntersectionQ, ControlDeltaQ: Double;
begin
  Result := False;
  if (ASpillage = nil) or (ASpillage.State = osDeleted) or (not ASpillage.Enabled) or
     (not AColumn.EtalonRangeValid) then
    Exit;

  Device := FindProcessingDeviceByUUID(ASpillage.DeviceUUID);
  if (Device = nil) or IsNan(Device.Error) or IsInfinite(Device.Error) or
     (Device.Error <= 0) then
    Exit;

  if not CalculatePointFlowRange(ASpillage.QavgEtalon,
    Device.Error, PointMinQ, PointMaxQ, PointDeltaQ) then
    Exit;
  Result := TryMergePointRanges(AColumn.CommonMinQ,
    AColumn.CommonMaxQ, AColumn.MinEtalonDeltaQ, PointMinQ, PointMaxQ,
    PointDeltaQ, NewCommonMinQ, NewCommonMaxQ, IntersectionQ, ControlDeltaQ);
end;

function TFrameProceed.FindResultSpillageForColumn(ADevice: TDevice;
  const AColumn: TProceedResultPointColumn): TPointSpillage;
var
  Spillages: TArray<TPointSpillage>;
begin
  Result := nil;
  Spillages := FindResultSpillagesForColumn(ADevice, AColumn);
  if Length(Spillages) > 0 then
    Result := Spillages[0];
end;

function TFrameProceed.IsValidSummaryResultSpillage(ASpillage: TPointSpillage;
  out ASkipReason: string): Boolean;
begin
  ASkipReason := '';
  Result := False;
  if ASpillage = nil then
  begin
    ASkipReason := 'NilSpillage';
    Exit;
  end;
  if ASpillage.State = osDeleted then
  begin
    ASkipReason := 'DeletedSpillage';
    Exit;
  end;
  if not ASpillage.Enabled then
  begin
    ASkipReason := 'DisabledSpillage';
    Exit;
  end;
  if (not ASpillage.Valid) or (ASpillage.Validation <> vsValid) then
  begin
    ASkipReason := 'MeasurementNotCompleted';
    Exit;
  end;
  if not IsResultErrorValid(ASpillage.Error) then
  begin
    ASkipReason := 'InvalidDoubleValue';
    Exit;
  end;
  Result := True;
end;

procedure TFrameProceed.LogSummaryResultSelection(const AGroupName: string;
  ACandidate: TPointSpillage; const AIsValid: Boolean;
  const ASkipReason: string; ASelected: TPointSpillage;
  const ASelectionReason: string);
var
  CandidateID, SelectedID: Integer;
  CandidateDeviceUUID, CandidateError, SelectedError: string;
begin
  CandidateID := 0;
  CandidateDeviceUUID := '';
  CandidateError := '';
  if ACandidate <> nil then
  begin
    CandidateID := ACandidate.ID;
    CandidateDeviceUUID := Trim(ACandidate.DeviceUUID);
    CandidateError := FormatResultErrorValue(ACandidate.Error);
  end;

  SelectedID := 0;
  SelectedError := '';
  if ASelected <> nil then
  begin
    SelectedID := ASelected.ID;
    SelectedError := FormatResultErrorValue(ASelected.Error);
  end;

  ProtocolManager.AddMessage(pcProc, psForm, 'SummaryResultSelection',
    'Выбор результата Summary с фильтрацией служебных значений',
    Format('GroupName=%s; DeviceUUID=%s; CandidateSpillageID=%d; CandidateError=%s; IsValid=%s; SkipReason=%s; SelectedSpillageID=%d; SelectedError=%s; SelectionReason=%s',
      [AGroupName, CandidateDeviceUUID, CandidateID, CandidateError,
       BoolToStr(AIsValid, True), ASkipReason, SelectedID, SelectedError,
       ASelectionReason]));
end;

function TFrameProceed.FormatMergedSummarySeriesResults(const AColumn: TProceedResultPointColumn;
  const ASpillages: TArray<TPointSpillage>; out ASelectedSpillages: TArray<TPointSpillage>): string;
var
  Ordered: TList<TPointSpillage>;
  Spillage, CurrentBest: TPointSpillage;
  SkipReason: string;
  SelectedCount: Integer;

  procedure AddSelected(ASpillage: TPointSpillage);
  begin
    if ASpillage = nil then
      Exit;
    SetLength(ASelectedSpillages, SelectedCount + 1);
    ASelectedSpillages[SelectedCount] := ASpillage;
    Inc(SelectedCount);
  end;

begin
  Result := '';
  SetLength(ASelectedSpillages, 0);
  SelectedCount := 0;
  if Length(ASpillages) = 0 then
    Exit;

  Ordered := TList<TPointSpillage>.Create;
  try
    for Spillage in ASpillages do
      if Spillage <> nil then
        Ordered.Add(Spillage);
    Ordered.Sort(TComparer<TPointSpillage>.Construct(
      function(const Left, Right: TPointSpillage): Integer
      begin
        Result := CompareValue(Left.DateTime, Right.DateTime);
        if Result <> 0 then Exit;
        Result := CompareValue(Left.ID, Right.ID);
      end));

    CurrentBest := nil;
    for Spillage in Ordered do
    begin
      if not IsValidSummaryResultSpillage(Spillage, SkipReason) then
      begin
        LogSummaryResultSelection(AColumn.Header, Spillage, False, SkipReason,
          CurrentBest, 'MinimumAbsoluteError');
        Continue;
      end;

      if (CurrentBest = nil) or
         (Abs(Spillage.Error) < Abs(CurrentBest.Error)) or
         (SameValue(Abs(Spillage.Error), Abs(CurrentBest.Error), 1E-9) and (Spillage.ID >= CurrentBest.ID)) then
      begin
        CurrentBest := Spillage;
        LogSummaryResultSelection(AColumn.Header, Spillage, True, '',
          Spillage, 'MinimumAbsoluteError');
      end
      else
        LogSummaryResultSelection(AColumn.Header, Spillage, True, '',
          CurrentBest, 'MinimumAbsoluteError');
    end;

    if CurrentBest <> nil then
    begin
      AddSelected(CurrentBest);
      Result := FormatResultErrorValue(CurrentBest.Error);
    end;
  finally
    Ordered.Free;
  end;
end;

function TFrameProceed.FindResultSpillagesForColumn(ADevice: TDevice;
  const AColumn: TProceedResultPointColumn): TArray<TPointSpillage>;
const
  SUMMARY_MERGE_FLOW_REL_TOLERANCE = 0.005;
  SUMMARY_MERGE_FLOW_ABS_TOLERANCE = 0.000001;
var
  Spillage, Candidate, BestSingle: TPointSpillage;
  ActiveSession: TSessionSpillage;
  DeviceUUID: string;
  BestDiff, Diff, MaxFlow, Tolerance: Double;
  Count: Integer;

  function IsBetterSpillage(ANew, ACurrent: TPointSpillage; const ANewDiff, ACurrentDiff: Double): Boolean;
  begin
    Result := ACurrent = nil;
    if Result then
      Exit;
    if ANewDiff < ACurrentDiff then
      Exit(True);
    if ANewDiff > ACurrentDiff then
      Exit(False);
    if ANew.Valid and (not ACurrent.Valid) then
      Exit(True);
    if (ANew.Validation = vsValid) and (ACurrent.Validation <> vsValid) then
      Exit(True);
    Result := ANew.ID >= ACurrent.ID;
  end;

  procedure AddResult(ASpillage: TPointSpillage);
  begin
    if ASpillage = nil then
      Exit;
    SetLength(Result, Count + 1);
    Result[Count] := ASpillage;
    Inc(Count);
  end;

  function IsMergedSpillageParticipant(ASpillage: TPointSpillage): Boolean;
  var
    Key: string;
  begin
    Result := False;
    if ASpillage = nil then
      Exit;
    Key := '|' + AnsiUpperCase(Trim(ASpillage.Name)) + '|';
    Result := (Key <> '||') and (Pos(Key, AColumn.MergedSpillageNames) > 0);
  end;
begin
  SetLength(Result, 0);
  Count := 0;
  if (ADevice = nil) or (ADevice.Spillages = nil) then
    Exit;

  DeviceUUID := Trim(ADevice.UUID);
  ActiveSession := GetActiveVisibleSession(ADevice);
  if ActiveSession = nil then
    Exit;

  if (not AColumn.IsMerged) and (AColumn.SelectedSpillage <> nil) then
  begin
    if (AColumn.SelectedSpillage.SessionID = ActiveSession.ID) and
       ((Trim(AColumn.SelectedSpillage.DeviceUUID) = '') or (DeviceUUID = '') or
        SameText(Trim(AColumn.SelectedSpillage.DeviceUUID), DeviceUUID)) then
      AddResult(AColumn.SelectedSpillage);
    Exit;
  end;

  BestSingle := nil;
  BestDiff := MaxDouble;
  for Spillage in ADevice.Spillages do
  begin
    if (Spillage = nil) or (Spillage.State = osDeleted) or (not Spillage.Enabled) then
      Continue;
    if Spillage.SessionID <> ActiveSession.ID then
      Continue;
    if (Trim(Spillage.DeviceUUID) <> '') and (DeviceUUID <> '') and
       (not SameText(Trim(Spillage.DeviceUUID), DeviceUUID)) then
      Continue;

    Candidate := nil;
    if AColumn.IsMerged then
    begin
      if IsMergedSpillageParticipant(Spillage) or
         IsProcessingSpillageInMergedColumn(Spillage, AColumn) then
        Candidate := Spillage;
    end
    else
    begin
      if (Trim(AColumn.DeviceUUID) <> '') and (DeviceUUID <> '') and
         (not SameText(Trim(AColumn.DeviceUUID), DeviceUUID)) then
        Continue;
      if (Trim(AColumn.SourcePointUUID) <> '') and (Trim(Spillage.DeviceTypeUUID) <> '') and
         SameText(Trim(AColumn.SourcePointUUID), Trim(Spillage.DeviceTypeUUID)) then
        Candidate := Spillage
      else if (Trim(AColumn.SourcePointName) <> '') and
              SameText(Trim(AColumn.SourcePointName), Trim(Spillage.Name)) then
        Candidate := Spillage
      else if (AColumn.SourcePointNum > 0) and (Spillage.Num = AColumn.SourcePointNum) then
        Candidate := Spillage
      else if (not IsNan(AColumn.TargetFlow)) and (not IsInfinite(AColumn.TargetFlow)) then
      begin
        MaxFlow := Max(Abs(Spillage.QavgEtalon), Abs(AColumn.TargetFlow));
        Tolerance := Max(SUMMARY_MERGE_FLOW_ABS_TOLERANCE, MaxFlow * SUMMARY_MERGE_FLOW_REL_TOLERANCE);
        if Abs(Spillage.QavgEtalon - AColumn.TargetFlow) <= Tolerance then
          Candidate := Spillage;
      end;
    end;

    if Candidate = nil then
      Continue;

    Diff := Abs(Candidate.QavgEtalon - AColumn.TargetFlow);
    if AColumn.IsMerged then
      AddResult(Candidate)
    else if IsBetterSpillage(Candidate, BestSingle, Diff, BestDiff) then
    begin
      BestSingle := Candidate;
      BestDiff := Diff;
    end;
  end;

  if (not AColumn.IsMerged) and (BestSingle <> nil) then
    AddResult(BestSingle);
end;

procedure TFrameProceed.BuildSummaryColumnsWithoutMerge(const ADevices: TList<TDevice>);
var
  Cols: TList<TProceedResultPointColumn>;
  Groups: TDictionary<string, TList<TPointSpillage>>;
  GroupKeys: TList<string>;
  Col: TProceedResultPointColumn;
  Device: TDevice;
  Spillage, SelectedSpillage: TPointSpillage;
  ActiveSession: TSessionSpillage;
  GroupSpillages: TList<TPointSpillage>;
  DeviceUUID, SourcePointUUID, PointName, GroupKey, Headers, SpillageIDs: string;
  DevicesCount, SpillagesCount, I, J: Integer;

  function IsUsableSummarySpillage(ASpillage: TPointSpillage): Boolean;
  begin
    Result := (ASpillage <> nil) and (ASpillage.State <> osDeleted) and
      ASpillage.Enabled and (ASpillage.Validation = vsValid) and
      IsResultErrorValid(ASpillage.Error) and
      (not IsNan(ASpillage.QavgEtalon)) and (not IsInfinite(ASpillage.QavgEtalon));
  end;

  function SpillageHeader(ASpillage: TPointSpillage; const ADefault: string): string;
  begin
    Result := Trim(ASpillage.Name);
    if Result = '' then
      Result := ADefault;
  end;

  { Builds a stable physical-point key without using the measured flow of a repeat. }
  function BuildWithoutMergeGroupKey(const ADeviceUUID, ASourcePointUUID,
    APointName: string): string;
  begin
    if Trim(ASourcePointUUID) <> '' then
      Result := AnsiUpperCase(Trim(ADeviceUUID)) + '|UUID:' +
        AnsiUpperCase(Trim(ASourcePointUUID))
    else
      Result := AnsiUpperCase(Trim(ADeviceUUID)) + '|POINT:' +
        AnsiUpperCase(Trim(APointName));
  end;

  function SelectBestSpillageByAbsoluteError(AItems: TList<TPointSpillage>): TPointSpillage;
  var
    Item: TPointSpillage;
    SkipReason: string;
  begin
    Result := nil;
    if AItems = nil then
      Exit;
    for Item in AItems do
    begin
      if not IsValidSummaryResultSpillage(Item, SkipReason) then
      begin
        LogSummaryResultSelection(GroupKey, Item, False, SkipReason, Result,
          'MinimumAbsoluteError');
        Continue;
      end;
      if (Result = nil) or (Abs(Item.Error) < Abs(Result.Error)) or
         (SameValue(Abs(Item.Error), Abs(Result.Error), 1E-9) and (Item.ID >= Result.ID)) then
      begin
        Result := Item;
        LogSummaryResultSelection(GroupKey, Item, True, '', Result,
          'MinimumAbsoluteError');
      end
      else
        LogSummaryResultSelection(GroupKey, Item, True, '', Result,
          'MinimumAbsoluteError');
    end;
  end;

  function BuildSpillageIDs(AItems: TList<TPointSpillage>): string;
  var
    Item: TPointSpillage;
  begin
    Result := '';
    if AItems = nil then
      Exit;
    for Item in AItems do
    begin
      if Item = nil then
        Continue;
      if Result <> '' then
        Result := Result + ',';
      Result := Result + IntToStr(Item.ID);
    end;
  end;

begin
  SetLength(FResultPointColumns, 0);
  Cols := TList<TProceedResultPointColumn>.Create;
  Groups := TDictionary<string, TList<TPointSpillage>>.Create;
  GroupKeys := TList<string>.Create;
  try
    DevicesCount := 0;
    SpillagesCount := 0;
    if ADevices <> nil then
      for Device in ADevices do
      begin
        if (Device = nil) or (Device.State = osDeleted) or
           IsProcessingDevicePendingRemoved(Device) then
          Continue;
        Inc(DevicesCount);
        ActiveSession := GetActiveVisibleSession(Device);
        if (ActiveSession = nil) or (Device.Spillages = nil) then
          Continue;

        DeviceUUID := Trim(Device.UUID);
        for Spillage in Device.Spillages do
        begin
          if (not IsUsableSummarySpillage(Spillage)) or
             (Spillage.SessionID <> ActiveSession.ID) then
            Continue;
          if (Trim(Spillage.DeviceUUID) <> '') and (DeviceUUID <> '') and
             (not SameText(Trim(Spillage.DeviceUUID), DeviceUUID)) then
            Continue;

          Inc(SpillagesCount);
          SourcePointUUID := Trim(Spillage.DeviceTypeUUID);
          PointName := SpillageHeader(Spillage, Format('Q%d', [Groups.Count + 1]));
          GroupKey := BuildWithoutMergeGroupKey(DeviceUUID, SourcePointUUID,
            PointName);
          if not Groups.TryGetValue(GroupKey, GroupSpillages) then
          begin
            GroupSpillages := TList<TPointSpillage>.Create;
            Groups.Add(GroupKey, GroupSpillages);
            GroupKeys.Add(GroupKey);
          end;
          GroupSpillages.Add(Spillage);
        end;
      end;

    for I := 0 to GroupKeys.Count - 1 do
    begin
      GroupKey := GroupKeys[I];
      if not Groups.TryGetValue(GroupKey, GroupSpillages) then
        Continue;
      SelectedSpillage := SelectBestSpillageByAbsoluteError(GroupSpillages);
      if SelectedSpillage = nil then
        Continue;

      SourcePointUUID := Trim(SelectedSpillage.DeviceTypeUUID);
      PointName := SpillageHeader(SelectedSpillage, Format('Q%d', [Cols.Count + 1]));
      SpillageIDs := BuildSpillageIDs(GroupSpillages);

      Col := Default(TProceedResultPointColumn);
      Col.IsMerged := False;
      Col.DeviceUUID := Trim(SelectedSpillage.DeviceUUID);
      if Col.DeviceUUID = '' then
        Col.DeviceUUID := Copy(GroupKey, 1, Pos('|', GroupKey) - 1);
      Col.SourcePointUUID := SourcePointUUID;
      Col.SourcePointName := PointName;
      Col.SourcePointNum := SelectedSpillage.Num;
      Col.TargetFlow := SelectedSpillage.QavgEtalon;
      Col.Header := PointName;
      Col.GroupedSpillages := GroupSpillages.ToArray;
      Col.SelectedSpillage := SelectedSpillage;
      Col.SelectionReason := 'MinimumAbsoluteError';
      Cols.Add(Col);

      ProtocolManager.AddMessage(pcProc, psForm, 'SummaryPointGrouping',
        'Сгруппированы проливки Summary без объединения физических точек',
        Format('Mode=WithoutMerge; DeviceUUID=%s; SourcePointUUID=%s; GroupKey=%s; SpillageIDs=%s; SelectedSpillageID=%d; SelectedError=%s; GroupCount=%d',
          [Col.DeviceUUID, Col.SourcePointUUID, GroupKey, SpillageIDs,
           SelectedSpillage.ID, FormatResultErrorValue(SelectedSpillage.Error),
           GroupSpillages.Count]));
    end;

    Headers := '';
    for I := 0 to Cols.Count - 1 do
    begin
      if I > 0 then Headers := Headers + ', ';
      Headers := Headers + Cols[I].Header;
    end;
    FResultPointColumns := Cols.ToArray;

    ProtocolManager.AddMessage(pcProc, psForm, 'ProcessingSummaryColumnsBuilt',
      'Построены колонки Summary обработки без объединения точек',
      Format('MergeEnabled=False; Source=Spillages; DevicesCount=%d; SpillagesCount=%d; ColumnsCount=%d; ColumnHeaders=%s; SummaryColumnsSource=ProcessingSpillages; BuildMode=WithoutMerge',
        [DevicesCount, SpillagesCount, Cols.Count, Headers]));
  finally
    for J := 0 to GroupKeys.Count - 1 do
      if Groups.TryGetValue(GroupKeys[J], GroupSpillages) then
        GroupSpillages.Free;
    GroupKeys.Free;
    Groups.Free;
    Cols.Free;
  end;
end;

procedure TFrameProceed.BuildSummaryResultPointColumns(const ADevices: TList<TDevice>;
  const AMergePoints: Boolean);
begin
  if AMergePoints then
    BuildSummaryColumnsWithMerge(ADevices)
  else
    BuildSummaryColumnsWithoutMerge(ADevices);
end;

procedure TFrameProceed.BuildSummaryColumnsWithMerge(const ADevices: TList<TDevice>);
var
  Cols: TList<TProceedResultPointColumn>;
  ProcessingSpillages: TList<TPointSpillage>;
  PhysicalPointGroups: TDictionary<string, TList<TPointSpillage>>;
  PhysicalPointGroupKeys: TList<string>;
  PhysicalPointGroup: TList<TPointSpillage>;
  Col: TProceedResultPointColumn;
  WT: TWorkTable;
  Run: TMeasurementRun;
  Device: TDevice;
  Spillage, GroupSpillage, SelectedSpillage: TPointSpillage;
  ActiveSession: TSessionSpillage;
  I, J, DevicesCount, SpillagesCount, SourceSpillagesCount: Integer;
  DeviceUUID, PhysicalPointKey: string;
  Headers: string;
  RunPointsEmpty: Boolean;
  GroupNames, GroupFlows, GroupEtalons, GroupSpillageIDs: string;
  GroupCount: Integer;
  PointMinQ, PointMaxQ, PointDeltaQ: Double;
  NewCommonMinQ, NewCommonMaxQ, IntersectionQ, ControlDeltaQ: Double;
  BestIntersectionQ, BestDistance, CandidateDistance: Double;
  PointErrorPercent: Double;

  function IsUsableSummarySpillage(ASpillage: TPointSpillage): Boolean;
  begin
    Result := (ASpillage <> nil) and (ASpillage.State <> osDeleted) and
      ASpillage.Enabled and (ASpillage.Validation = vsValid) and
      IsResultErrorValid(ASpillage.Error) and
      (not IsNan(ASpillage.QavgEtalon)) and (not IsInfinite(ASpillage.QavgEtalon));
  end;

  function SpillageHeader(ASpillage: TPointSpillage; const ADefault: string): string;
  begin
    Result := Trim(ASpillage.Name);
    if Result = '' then
      Result := ADefault;
  end;

  procedure AppendHeaderName(var AHeader: string; const AName: string);
  begin
    if Trim(AName) = '' then
      Exit;
    if AHeader = '' then
      AHeader := AName
    else if Pos('|' + AName + '|', '|' + StringReplace(AHeader, ' / ', '|', [rfReplaceAll]) + '|') = 0 then
      AHeader := AHeader + ' / ' + AName;
    if Length(AHeader) > 80 then
      AHeader := Copy(AHeader, 1, 77) + '...';
  end;

  procedure AppendCsvValue(var AText: string; const AValue: string);
  begin
    if AText <> '' then
      AText := AText + ',';
    AText := AText + AValue;
  end;

  procedure AppendSpillageID(var AText: string; ASpillage: TPointSpillage);
  begin
    if ASpillage = nil then
      Exit;
    if AText <> '' then
      AText := AText + ',';
    AText := AText + IntToStr(ASpillage.ID);
  end;

  function SpillageNameKey(ASpillage: TPointSpillage): string;
  begin
    if ASpillage = nil then
      Result := ''
    else
      Result := '|' + AnsiUpperCase(Trim(ASpillage.Name)) + '|';
  end;

  procedure AppendSpillageNameKey(var AKeys: string; ASpillage: TPointSpillage);
  var
    Key: string;
  begin
    Key := SpillageNameKey(ASpillage);
    if Key = '' then
      Exit;
    if Pos(Key, AKeys) = 0 then
      AKeys := AKeys + Key;
  end;

  { Builds a stable identity for one physical device point across repeated spillages. }
  function BuildPhysicalPointKey(AOwnerDevice: TDevice;
    ASpillage: TPointSpillage): string;
  var
    OwnerDeviceUUID, PointUUID, PhysicalPointName: string;
  begin
    OwnerDeviceUUID := '';
    if AOwnerDevice <> nil then
      OwnerDeviceUUID := Trim(AOwnerDevice.UUID);
    if (OwnerDeviceUUID = '') and (ASpillage <> nil) then
      OwnerDeviceUUID := Trim(ASpillage.DeviceUUID);

    PointUUID := '';
    if ASpillage <> nil then
      PointUUID := Trim(ASpillage.DeviceTypeUUID);

    if PointUUID <> '' then
      Result := AnsiUpperCase(OwnerDeviceUUID) + '|UUID:' +
        AnsiUpperCase(PointUUID)
    else
    begin
      PhysicalPointName := '';
      if ASpillage <> nil then
        PhysicalPointName := Trim(ASpillage.Name);
      if PhysicalPointName <> '' then
        Result := AnsiUpperCase(OwnerDeviceUUID) + '|POINT:' +
          AnsiUpperCase(PhysicalPointName)
      else if ASpillage <> nil then
        Result := AnsiUpperCase(OwnerDeviceUUID) + '|NUM:' +
          IntToStr(ASpillage.Num)
      else
        Result := AnsiUpperCase(OwnerDeviceUUID) + '|NONE';
    end;
  end;

  { Selects the valid repeat with the minimum absolute error for column merging. }
  function SelectBestPhysicalPointSpillage(
    AItems: TList<TPointSpillage>): TPointSpillage;
  var
    Item: TPointSpillage;
  begin
    Result := nil;
    if AItems = nil then
      Exit;

    for Item in AItems do
      if (Result = nil) or (Abs(Item.Error) < Abs(Result.Error)) or
         (SameValue(Abs(Item.Error), Abs(Result.Error), 1E-9) and
          (Item.ID >= Result.ID)) then
        Result := Item;
  end;

  { Returns the IDs of all repeats participating in one physical-point group. }
  function BuildPhysicalPointSpillageIDs(
    AItems: TList<TPointSpillage>): string;
  var
    Item: TPointSpillage;
  begin
    Result := '';
    if AItems = nil then
      Exit;

    for Item in AItems do
    begin
      if Item = nil then
        Continue;
      AppendSpillageID(Result, Item);
    end;
  end;

  function SpillagePointErrorPercent(AOwnerDevice: TDevice;
    ASpillage: TPointSpillage): Double;
  begin
    Result := NaN;
    if (AOwnerDevice <> nil) and (ASpillage <> nil) and
       (not IsNan(AOwnerDevice.Error)) and
       (not IsInfinite(AOwnerDevice.Error)) and
       (AOwnerDevice.Error > 0) then
      Result := AOwnerDevice.Error;
  end;

begin
  SetLength(FResultPointColumns, 0);
  Cols := TList<TProceedResultPointColumn>.Create;
  ProcessingSpillages := TList<TPointSpillage>.Create;
  PhysicalPointGroups := TDictionary<string, TList<TPointSpillage>>.Create;
  PhysicalPointGroupKeys := TList<string>.Create;
  try
    WT := ResolveManagerWorkTable(FWorkTableManager);
    Run := nil;
    if (WT <> nil) and (WT.MeasurementRun <> nil) then
      Run := TMeasurementRun(WT.MeasurementRun);
    RunPointsEmpty := (Run = nil) or (Run.Points = nil) or (Run.Points.Count = 0);
    DevicesCount := 0;
    SourceSpillagesCount := 0;

    if ADevices <> nil then
      for Device in ADevices do
      begin
        if (Device = nil) or (Device.State = osDeleted) or
           IsProcessingDevicePendingRemoved(Device) then
          Continue;
        Inc(DevicesCount);
        ActiveSession := GetActiveVisibleSession(Device);
        if (ActiveSession = nil) or (Device.Spillages = nil) then
          Continue;

        for Spillage in Device.Spillages do
        begin
          if (not IsUsableSummarySpillage(Spillage)) or
             (Spillage.SessionID <> ActiveSession.ID) then
            Continue;

          DeviceUUID := Trim(Device.UUID);
          if (Trim(Spillage.DeviceUUID) <> '') and (DeviceUUID <> '') and
             (not SameText(Trim(Spillage.DeviceUUID), DeviceUUID)) then
            Continue;

          Inc(SourceSpillagesCount);
          PhysicalPointKey := BuildPhysicalPointKey(Device, Spillage);
          if not PhysicalPointGroups.TryGetValue(PhysicalPointKey,
            PhysicalPointGroup) then
          begin
            PhysicalPointGroup := TList<TPointSpillage>.Create;
            PhysicalPointGroups.Add(PhysicalPointKey, PhysicalPointGroup);
            PhysicalPointGroupKeys.Add(PhysicalPointKey);
          end;
          PhysicalPointGroup.Add(Spillage);
        end;
      end;

    for I := 0 to PhysicalPointGroupKeys.Count - 1 do
    begin
      PhysicalPointKey := PhysicalPointGroupKeys[I];
      if not PhysicalPointGroups.TryGetValue(PhysicalPointKey,
        PhysicalPointGroup) then
        Continue;

      SelectedSpillage :=
        SelectBestPhysicalPointSpillage(PhysicalPointGroup);
      if SelectedSpillage = nil then
        Continue;

      ProcessingSpillages.Add(SelectedSpillage);
      ProtocolManager.AddMessage(pcProc, psForm, 'SummaryBestRepeatSelected',
        'Выбрана лучшая проливка физической точки для построения merged-колонок',
        Format('GroupKey=%s; RepeatCount=%d; SpillageIDs=%s; SelectedSpillageID=%d; SelectedError=%s',
          [PhysicalPointKey, PhysicalPointGroup.Count,
           BuildPhysicalPointSpillageIDs(PhysicalPointGroup),
           SelectedSpillage.ID,
           FormatResultErrorValue(SelectedSpillage.Error)]));
    end;

    ProcessingSpillages.Sort(TComparer<TPointSpillage>.Construct(
      function(const Left, Right: TPointSpillage): Integer
      begin
        Result := CompareValue(Left.QavgEtalon, Right.QavgEtalon);
        if Result <> 0 then Exit;
        Result := CompareValue(Left.DateTime, Right.DateTime);
        if Result <> 0 then Exit;
        Result := CompareValue(Left.ID, Right.ID);
      end));

    SpillagesCount := ProcessingSpillages.Count;
    for Spillage in ProcessingSpillages do
    begin
      Col := Default(TProceedResultPointColumn);
      Col.TargetFlow := Spillage.QavgEtalon;
      Col.SourcePointName := Trim(Spillage.Name);
      Col.SourcePointNum := Spillage.Num;
      Device := nil;
      if ADevices <> nil then
        for Device in ADevices do
        if (Device <> nil) and (Device.Spillages <> nil) and
           (Device.Spillages.IndexOf(Spillage) >= 0) then
        begin
          Break;
        end;
      PointErrorPercent := SpillagePointErrorPercent(Device, Spillage);
      J := -1;
      BestIntersectionQ := -MaxDouble;
      BestDistance := MaxDouble;
      if CalculatePointFlowRange(Spillage.QavgEtalon,
          PointErrorPercent, PointMinQ, PointMaxQ, PointDeltaQ) then
          for I := 0 to Cols.Count - 1 do
          begin
            { IsProcessingSpillageInMergedColumn(Spillage, Cols[I]) delegates to the same math. }
            if TryMergePointRanges(Cols[I].CommonMinQ,
                 Cols[I].CommonMaxQ, Cols[I].MinEtalonDeltaQ, PointMinQ,
                 PointMaxQ, PointDeltaQ, NewCommonMinQ, NewCommonMaxQ,
                 IntersectionQ, ControlDeltaQ) then
            begin
              CandidateDistance := Abs(Cols[I].TargetFlow - Spillage.QavgEtalon);
              if (J < 0) or (IntersectionQ > BestIntersectionQ + 1E-9) or
                 (SameValue(IntersectionQ, BestIntersectionQ, 1E-9) and
                  (CandidateDistance < BestDistance - 1E-9)) then
              begin
                J := I;
                BestIntersectionQ := IntersectionQ;
                BestDistance := CandidateDistance;
              end;
            end;
            ProtocolManager.AddMessage(pcProc, psForm, 'MeasurementPointMergeMath',
              'Проверка математики объединения поверочных точек',
              Format('Point1Q=%.6f; Point2Q=%.6f; Point1Range=[%.6f..%.6f]; Point2Range=[%.6f..%.6f]; Intersection=%.6f; ControlDelta=%.6f; Result=%s',
                [Cols[I].TargetFlow, Spillage.QavgEtalon, Cols[I].CommonMinQ,
                 Cols[I].CommonMaxQ, PointMinQ, PointMaxQ, IntersectionQ,
                 ControlDeltaQ, BoolToStr((J = I) and SameValue(IntersectionQ, BestIntersectionQ, 1E-9), True)]));
          end;
        if J >= 0 then
        begin
          Col := Cols[J];
          AppendSpillageNameKey(Col.MergedSpillageNames, Spillage);
          TryMergePointRanges(Col.CommonMinQ,
            Col.CommonMaxQ, Col.MinEtalonDeltaQ, PointMinQ, PointMaxQ,
            PointDeltaQ, Col.CommonMinQ, Col.CommonMaxQ, IntersectionQ,
            ControlDeltaQ);
          Col.MinEtalonDeltaQ := Min(Col.MinEtalonDeltaQ, PointDeltaQ);
          Col.TargetFlow := (Col.CommonMinQ + Col.CommonMaxQ) / 2;
          AppendHeaderName(Col.Header, SpillageHeader(Spillage, Format('Q%d', [J + 1])));
          Cols[J] := Col;
        end
        else
        begin
          Col.IsMerged := True;
          Col.DeviceUUID := '';
          Col.EtalonUUID := '';
          Col.SourcePointUUID := '';
          Col.Header := SpillageHeader(Spillage, Format('Q%d', [Cols.Count + 1]));
          AppendSpillageNameKey(Col.MergedSpillageNames, Spillage);
          Col.EtalonRangeValid := CalculatePointFlowRange(
            Spillage.QavgEtalon, PointErrorPercent, PointMinQ, PointMaxQ, PointDeltaQ);
          if Col.EtalonRangeValid then
          begin
            Col.CommonMinQ := PointMinQ;
            Col.CommonMaxQ := PointMaxQ;
            Col.MinEtalonDeltaQ := PointDeltaQ;
          end;
          Cols.Add(Col);
        end;
    end;

    for I := 0 to Cols.Count - 1 do
      begin
        GroupNames := '';
        GroupFlows := '';
        GroupEtalons := '';
        GroupSpillageIDs := '';
        GroupCount := 0;
        for GroupSpillage in ProcessingSpillages do
          if IsProcessingSpillageInMergedColumn(GroupSpillage, Cols[I]) then
          begin
            Inc(GroupCount);
            AppendCsvValue(GroupNames, SpillageHeader(GroupSpillage, Format('Q%d', [I + 1])));
            AppendCsvValue(GroupFlows, FormatFloat('0.######', GroupSpillage.QavgEtalon));
            AppendCsvValue(GroupEtalons, Trim(GroupSpillage.EtalonName));
            AppendSpillageID(GroupSpillageIDs, GroupSpillage);
          end;
        ProtocolManager.AddMessage(pcProc, psForm, 'ProcessingSummaryMergeGroup',
          'Сформирована merged-группа Summary по фактическому расходу',
          Format('GroupIndex=%d; TargetQ=%s; Count=%d; SpillageNames=%s; QValues=%s; EtalonNames=%s',
            [I + 1, FormatFloat('0.######', Cols[I].TargetFlow), GroupCount,
             GroupNames, GroupFlows, GroupEtalons]));
        ProtocolManager.AddMessage(pcProc, psForm, 'SummaryPointGrouping',
          'Сгруппированы проливки Summary с объединением физических точек',
          Format('Mode=Merge; DeviceUUID=%s; SourcePointUUID=%s; GroupKey=%s; SpillageIDs=%s; SelectedSpillageID=%d; SelectedError=%s; GroupCount=%d',
            ['', '', Cols[I].Header, GroupSpillageIDs, 0, '', GroupCount]));
      end;

    Headers := '';
    for I := 0 to Cols.Count - 1 do
    begin
      if I > 0 then Headers := Headers + ', ';
      Headers := Headers + Cols[I].Header;
    end;
    FResultPointColumns := Cols.ToArray;

    ProtocolManager.AddMessage(pcProc, psForm, 'ProcessingSummaryColumnsBuilt',
      'Построены колонки Summary обработки',
      Format('MergeEnabled=%s; Source=Spillages; DevicesCount=%d; SourceSpillagesCount=%d; SelectedSpillagesCount=%d; MergedGroupsCount=%d; ColumnsCount=%d; ColumnHeaders=%s; FallbackMeasurementRunUsed=False; MeasurementRunPointsEmpty=%s; SummaryColumnsSource=BestPhysicalPointSpillages',
        [BoolToStr(True, True), DevicesCount, SourceSpillagesCount,
         SpillagesCount, Cols.Count, Cols.Count, Headers,
         BoolToStr(RunPointsEmpty, True)]));
  finally
    for I := 0 to PhysicalPointGroupKeys.Count - 1 do
      if PhysicalPointGroups.TryGetValue(PhysicalPointGroupKeys[I],
        PhysicalPointGroup) then
        PhysicalPointGroup.Free;
    PhysicalPointGroupKeys.Free;
    PhysicalPointGroups.Free;
    ProcessingSpillages.Free;
    Cols.Free;
  end;
end;

procedure TFrameProceed.NormalizeResultsPointColumnsVisibility;
var
  PointColumnCount: Integer;
  StaticVisibleCount: Integer;
  DynamicVisibleCount: Integer;
  HiddenStaticColumns: string;
  I, PointIndex: Integer;
  Column: TColumn;

  procedure SetStaticPointColumnVisibility(AColumn: TColumn; const APointIndex: Integer);
  begin
    if AColumn = nil then
      Exit;
    AColumn.Visible := APointIndex < PointColumnCount;
    if AColumn.Visible then
      Inc(StaticVisibleCount)
    else
    begin
      if HiddenStaticColumns <> '' then
        HiddenStaticColumns := HiddenStaticColumns + ',';
      HiddenStaticColumns := HiddenStaticColumns + AColumn.Name;
    end;
  end;

  function IsDynamicPointColumn(AColumn: TColumn): Boolean;
  begin
    Result := (AColumn <> nil) and
      (SameText(AColumn.TagString, 'ProcessingDynamicPoint') or
       SameText(Copy(AColumn.Name, 1, Length('ProcessingPointColumn')), 'ProcessingPointColumn')) and
      (AColumn <> StringColumnResult) and (AColumn <> StringColumnResultComment);
  end;
begin
  if GridResults = nil then
    Exit;

  PointColumnCount := Length(FResultPointColumns);
  StaticVisibleCount := 0;
  DynamicVisibleCount := 0;
  HiddenStaticColumns := '';

  SetStaticPointColumnVisibility(StringColumnPointNum1, 0);
  SetStaticPointColumnVisibility(StringColumnPointNum2, 1);
  SetStaticPointColumnVisibility(StringColumnPointNum3, 2);
  SetStaticPointColumnVisibility(StringColumnPointNum4, 3);

  for I := GridResults.ColumnCount - 1 downto 0 do
  begin
    Column := GridResults.Columns[I];
    if not IsDynamicPointColumn(Column) then
      Continue;
    PointIndex := Column.Tag;
    if (PointIndex < 4) or (PointIndex >= PointColumnCount) then
      Column.Free
    else
    begin
      Column.Visible := True;
      Inc(DynamicVisibleCount);
    end;
  end;

  ProtocolManager.AddMessage(pcProc, psForm, 'ProcessingResultColumnsNormalized',
    'Нормализованы колонки точек Summary обработки',
    Format('PointColumnCount=%d; StaticVisibleCount=%d; DynamicVisibleCount=%d; GridColumnCount=%d; HiddenStaticColumns=%s',
      [PointColumnCount, StaticVisibleCount, DynamicVisibleCount,
       GridResults.ColumnCount, HiddenStaticColumns]));
end;

procedure TFrameProceed.UpdateResultsPointColumns;
var
  Definitions: TGridColumnDefinitions;
  Column: TColumn;
  I, PointIndex: Integer;
  Header: string;

  function FormatPointHeader(const APointName: string): string;
  begin
    Result := #948 + '(' + APointName + '), %';
  end;

  function IsDynamicPointColumn(AColumn: TColumn): Boolean;
  begin
    Result := (AColumn <> nil) and
      (SameText(AColumn.TagString, 'ProcessingDynamicPoint') or
       SameText(Copy(AColumn.Name, 1, Length('ProcessingPointColumn')), 'ProcessingPointColumn')) and
      (AColumn <> StringColumnResult) and (AColumn <> StringColumnResultComment);
  end;

  procedure AddDynamicDefinitions;
  var
    DynamicPointIndex: Integer;
    DynamicKey: string;
  begin
    for DynamicPointIndex := 4 to High(FResultPointColumns) do
    begin
      DynamicKey := 'point:' + FResultPointColumns[DynamicPointIndex].DeviceUUID + '|' +
        FResultPointColumns[DynamicPointIndex].SourcePointUUID + '|' +
        FResultPointColumns[DynamicPointIndex].EtalonUUID + '|' +
        FloatToStr(FResultPointColumns[DynamicPointIndex].TargetFlow);
      Definitions.Add(TGridColumnDefinition.Create(DynamicKey,
        FormatPointHeader(FResultPointColumns[DynamicPointIndex].Header),
        TStringColumn, C_DYNAMIC_COLUMN_WIDTH, True, True));
    end;
  end;
begin
  if FResultsGridLayoutState = nil then
  begin
    FResultsGridLayoutState := TGridLayoutState.Create;
    FResultsGridLayoutState.ConfigureWidthControl(GridResults,
      ClassName + '.' + GridResults.Name);
  end;
  Definitions := TGridColumnDefinitions.Create(True);
  try
    { Describe the complete visual structure, but mark resource columns as
      existing: the helper owns and recreates dynamic point columns only. }
    for I := 0 to GridResults.ColumnCount - 1 do
    begin
      Column := GridResults.Columns[I];
      if IsDynamicPointColumn(Column) then
        Continue;
      if Column = StringColumnResult then
        AddDynamicDefinitions;

      Header := Column.Header;
      PointIndex := -1;
      if Column = StringColumnPointNum1 then PointIndex := 0
      else if Column = StringColumnPointNum2 then PointIndex := 1
      else if Column = StringColumnPointNum3 then PointIndex := 2
      else if Column = StringColumnPointNum4 then PointIndex := 3;
      if (PointIndex >= 0) and (PointIndex < Length(FResultPointColumns)) then
        Header := FormatPointHeader(FResultPointColumns[PointIndex].Header);
      Definitions.Add(TGridColumnDefinition.Create('fixed:' + Column.Name,
        Header, Column.ClassType, Column.Width, Column.ReadOnly,
        (PointIndex < 0) or (PointIndex < Length(FResultPointColumns)), Column));
    end;

    if TGridLayoutManager.Apply(GridResults, FResultsGridLayoutState,
      Definitions, CreateResultsGridColumn) then
      NormalizeResultsPointColumnsVisibility;
  finally
    Definitions.Free;
  end;
end;

function TFrameProceed.CreateResultsGridColumn(AOwner: TComponent;
  ADefinition: TGridColumnDefinition): TColumn;
var
  I: Integer;
  Key: string;
begin
  Result := TStringColumn.Create(AOwner);
  for I := 4 to High(FResultPointColumns) do
  begin
    Key := 'point:' + FResultPointColumns[I].DeviceUUID + '|' +
      FResultPointColumns[I].SourcePointUUID + '|' +
      FResultPointColumns[I].EtalonUUID + '|' +
      FloatToStr(FResultPointColumns[I].TargetFlow);
    if Key = ADefinition.Key then
    begin
      Result.Tag := I;
      Break;
    end;
  end;
  Result.Name := 'ProcessingPointColumn' + IntToStr(Result.Tag + 1);
  Result.TagString := 'ProcessingDynamicPoint';
  Result.HeaderSettings.TextSettings.Trimming := TTextTrimming.Character;
  Result.HeaderSettings.TextSettings.WordWrap := False;
  Result.HeaderSettings.TextSettings.HorzAlign := TTextAlign.Center;
end;

function TFrameProceed.FindResultSpillageForPoint(ADevice: TDevice;
  APoint: TDevicePoint): TPointSpillage;
var
  Spillage: TPointSpillage;
  ActiveSession: TSessionSpillage;
  DeviceUUID: string;
  TypeUUID: string;
begin
  Result := nil;
  if (ADevice = nil) or (APoint = nil) or (ADevice.Spillages = nil) then
    Exit;

  DeviceUUID := Trim(ADevice.UUID);
  TypeUUID := Trim(APoint.DeviceTypeUUID);
  ActiveSession := GetActiveVisibleSession(ADevice);
  if ActiveSession = nil then Exit;

  for Spillage in ADevice.Spillages do
  begin
    if (Spillage = nil) or (Spillage.State = osDeleted) or (not Spillage.Enabled) then
      Continue;
    if Spillage.SessionID <> ActiveSession.ID then
      Continue;

    if not SameText(Trim(Spillage.DeviceUUID), DeviceUUID) then
      Continue;

    if (TypeUUID <> '') and (Trim(Spillage.DeviceTypeUUID) <> '') then
    begin
      if not SameText(Trim(Spillage.DeviceTypeUUID), TypeUUID) then
        Continue;
    end
    else if (not SameText(Trim(Spillage.Name), Trim(APoint.Name))) and
            (not ADevice.IsFlowInPoint(Spillage.QavgEtalon, APoint)) then
      Continue;

    Result := Spillage;
    if Spillage.Valid then
      Exit;
  end;
end;

function TFrameProceed.GetPointResultError(const ADevice: TDevice;
  const APoint: TDevicePoint): Double;
var
  Spillage: TPointSpillage;
begin
  Result := NaN;
  Spillage := FindResultSpillageForPoint(ADevice, APoint);
  if (Spillage <> nil) and (Spillage.State <> osDeleted) and Spillage.Enabled and
     IsResultErrorValid(Spillage.Error) then
    Result := Spillage.Error;
end;

function TFrameProceed.GetPointResultFlowLS(const ADevice: TDevice;
  const APoint: TDevicePoint): Double;
var
  Spillage: TPointSpillage;
begin
  Result := NaN;
  Spillage := FindResultSpillageForPoint(ADevice, APoint);

  if (Spillage <> nil) and (Spillage.State <> osDeleted) and Spillage.Enabled and
     (not IsNan(Spillage.QavgEtalon)) and (not IsInfinite(Spillage.QavgEtalon)) and
     (Spillage.QavgEtalon > 0) then
  begin
    // QavgEtalon хранится в м3/ч, для графика используем базовые л/с.
    Result := Spillage.QavgEtalon / 3.6;
    Exit;
  end;

  if (APoint <> nil) and (not IsNan(APoint.Q)) and (not IsInfinite(APoint.Q)) and
     (APoint.Q > 0) then
    Result := APoint.Q / 3.6;
end;

procedure TFrameProceed.LogResultCellDebug(const ARow: TResultGridRow;
  APoint: TDevicePoint; ASpillage: TPointSpillage; const ACellValue: string);
var
  FoundID: Integer;
  FoundDeviceUUID: string;
  FoundError: string;
  PointName: string;
  PointTypeUUID: string;
begin
  FoundID := 0;
  FoundDeviceUUID := '';
  FoundError := '';
  PointName := '';
  PointTypeUUID := '';
  if APoint <> nil then
  begin
    PointName := APoint.Name;
    PointTypeUUID := APoint.DeviceTypeUUID;
  end;
  if ASpillage <> nil then
  begin
    FoundID := ASpillage.ID;
    FoundDeviceUUID := ASpillage.DeviceUUID;
    FoundError := FormatFloat('0.###', ASpillage.Error);
  end;

  LogMKS('DBG SP 9101', 'SummaryResults CELL',
    Format('RowDeviceUUID=%s; RowSerial=%s; ColumnPointName=%s; ColumnPointDeviceTypeUUID=%s; FoundSpillageID=%d; FoundSpillageDeviceUUID=%s; FoundError=%s; CellValue=%s',
      [ARow.DeviceUUID, ARow.Serial, PointName, PointTypeUUID,
       FoundID, FoundDeviceUUID, FoundError, ACellValue]));
end;

procedure TFrameProceed.ShowAllDevicesResults;
var
  Devices: TList<TDevice>;
  Device: TDevice;
begin
  Devices := TList<TDevice>.Create;
  try
    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
        if (Device <> nil) and (Device.State <> osDeleted) and
           (not IsProcessingDevicePendingRemoved(Device)) then
          Devices.Add(Device);

    ShowDevicesResults(Devices);
  finally
    Devices.Free;
  end;
  UpdateGridResults

end;
procedure TFrameProceed.ShowDevicesResults(const ADevices: TList<TDevice>);
var
  Rows: TList<TResultGridRow>;
  P: TDevicePoint;
  Device: TDevice;
  Row: TResultGridRow;
  I: Integer;
  Spillage: TPointSpillage;
  Spillages: TArray<TPointSpillage>;
  SelectedSpillages: TArray<TPointSpillage>;
  K: Integer;
  CellValues, CellNames: string;
  FoundPointsCount: Integer;
  RequiredPointsCount: Integer;
  InvalidCount: Integer;
  HasAnyData: Boolean;
  UseMergePoints: Boolean;
begin
  UseMergePoints := True;
  if ResolveManagerWorkTable(FWorkTableManager) <> nil then
    UseMergePoints := ResolveManagerWorkTable(FWorkTableManager).MergeMeasurementPoints;
  BuildSummaryResultPointColumns(ADevices, UseMergePoints);

  Rows := TList<TResultGridRow>.Create;
  try
    if ADevices <> nil then
      for Device in ADevices do
      begin
        if (Device = nil) or (Device.State = osDeleted) or
           IsProcessingDevicePendingRemoved(Device) then
          Continue;

        Row.Device := Device;
        Row.Name := Device.Name;
        Row.DeviceType := Device.DeviceTypeName;
        Row.Serial := Device.SerialNumber;
        Row.DeviceUUID := Device.UUID;

        if FSessionDevice <> nil then
        begin
          FSessionDevice.Device := Device;
          FSessionDevice.ApplyError;
        end;

        FoundPointsCount := 0;
        RequiredPointsCount := 0;
        InvalidCount := 0;
        HasAnyData := False;

        if Length(FResultPointColumns) > 0 then
        begin
          SetLength(Row.PointNames, Length(FResultPointColumns));
          SetLength(Row.PointValues, Length(FResultPointColumns));
          SetLength(Row.PointColors, Length(FResultPointColumns));
          for I := 0 to High(FResultPointColumns) do
          begin
            Row.PointNames[I] := FResultPointColumns[I].Header;
            if FResultPointColumns[I].IsMerged or
               SameText(Trim(FResultPointColumns[I].DeviceUUID), Trim(Device.UUID)) then
              Inc(RequiredPointsCount);

            Spillages := FindResultSpillagesForColumn(Device, FResultPointColumns[I]);
            P := FindResultPointForColumn(Device, FResultPointColumns[I]);
            if Length(Spillages) > 0 then
            begin
              CellValues := '';
              CellNames := '';
              Row.PointColors[I] := TAlphaColors.Null;
              if FResultPointColumns[I].IsMerged then
              begin
                CellValues := FormatMergedSummarySeriesResults(FResultPointColumns[I], Spillages, SelectedSpillages);
                for K := 0 to High(SelectedSpillages) do
                begin
                  Spillage := SelectedSpillages[K];
                  Inc(FoundPointsCount);
                  HasAnyData := True;
                  if (not Spillage.Valid) or
                     (Spillage.Validation = vsInvalid) then
                    Inc(InvalidCount);
                  if (K = 0) or ((not Spillage.Valid) or (Spillage.Validation = vsInvalid)) then
                    Row.PointColors[I] := GetSpillageErrorResultColor(Spillage);
                end;
                if Length(SelectedSpillages) > 0 then
                  Spillage := SelectedSpillages[0]
                else
                  Spillage := Spillages[0];
              end
              else
              begin
                for K := 0 to High(Spillages) do
                begin
                  Spillage := Spillages[K];
                  if CellValues <> '' then
                    CellValues := CellValues + ' / ';
                  CellValues := CellValues + FormatResultErrorValue(Spillage.Error);
                  if CellNames <> '' then
                    CellNames := CellNames + ' / ';
                  CellNames := CellNames + Spillage.Name;
                  Inc(FoundPointsCount);
                  HasAnyData := True;
                  if (not Spillage.Valid) or
                     (Spillage.Validation = vsInvalid) then
                    Inc(InvalidCount);
                  if (K = 0) or ((not Spillage.Valid) or (Spillage.Validation = vsInvalid)) then
                    Row.PointColors[I] := GetSpillageErrorResultColor(Spillage);
                end;
                Row.PointNames[I] := CellNames;
                Spillage := Spillages[0];
              end;
              { Point columns always show all measured errors.  Only the
                aggregate Result column may display an em dash. }
              Row.PointValues[I] := CellValues;
            end
            else
            begin
              Spillage := nil;
              Row.PointColors[I] := TAlphaColors.Null;
              Row.PointValues[I] := '-';
            end;
            LogResultCellDebug(Row, P, Spillage, Row.PointValues[I]);
          end;
        end
        else
        begin
          SetLength(Row.PointNames, 0);
          SetLength(Row.PointValues, 0);
          SetLength(Row.PointColors, 0);
        end;

        Row.ResultStatus := ResolveDeviceSummaryStatus(Device);
        if RequiredPointsCount > 0 then
        begin
          if FoundPointsCount = 0 then
            Row.ResultStatus := 2
          else if InvalidCount > 0 then
            Row.ResultStatus := 4
          else if FoundPointsCount < RequiredPointsCount then
            Row.ResultStatus := 2
          else
            Row.ResultStatus := 5;
        end;

        Row.ResultText := BuildResultTextByStatus(Row.ResultStatus);
        Row.ResultComment := BuildResultComment(Device, Row.ResultStatus);
        if (RequiredPointsCount = 0) and (not HasAnyData) then
        begin
          Row.ResultStatus := 2;
          Row.ResultText := #$2014;
          Row.ResultComment := 'Нет данных обработки';
        end;

        LogMKS('DBG SP 9102', 'SummaryResults RESULT',
          Format('RowDeviceUUID=%s; RowSerial=%s; RequiredPointsCount=%d; FoundPointsCount=%d; InvalidCount=%d; HasAnyData=%s; ResultText=%s',
            [Row.DeviceUUID, Row.Serial, RequiredPointsCount, FoundPointsCount,
             InvalidCount, BoolToStr(HasAnyData, True), Row.ResultText]));

        Rows.Add(Row);
      end;

    FCurrentResultRows := Rows.ToArray;
    SortProcessingDataByDate;
  finally
    Rows.Free;
  end;

  UpdateResultsPointColumns;
  UpdateGridResults

end;
procedure TFrameProceed.ShowWorkTableResults(AWorkTable: TWorkTable);
var
  Devices: TList<TDevice>;
  DeviceUUIDs: TStringList;
  Ch: TChannel;
  Device: TDevice;
begin
  Devices := TList<TDevice>.Create;
  DeviceUUIDs := TStringList.Create;
  try
    DeviceUUIDs.Sorted := False;
    DeviceUUIDs.Duplicates := dupIgnore;

    if (AWorkTable <> nil) and (AWorkTable.DeviceChannels <> nil) then
      for Ch in AWorkTable.DeviceChannels do
      begin
        if (Ch = nil) or (Ch.FlowMeter = nil) or (Ch.FlowMeter.Device = nil) then
          Continue;

        Device := FindProcessingDeviceByUUID(Ch.FlowMeter.Device.UUID);
        if (Device = nil) or (DeviceUUIDs.IndexOf(Trim(Device.UUID)) >= 0) then
          Continue;

        DeviceUUIDs.Add(Trim(Device.UUID));
        Devices.Add(Device);
      end;

    ShowDevicesResults(Devices);
  finally
    DeviceUUIDs.Free;
    Devices.Free;
  end;
end;
procedure TFrameProceed.ShowOtherDevicesResults;
var
  Devices: TList<TDevice>;
  DeviceUUIDsOnTables: TStringList;
  Device: TDevice;
  WT: TWorkTable;
  Ch: TChannel;
  I: Integer;
begin
  Devices := TList<TDevice>.Create;
  DeviceUUIDsOnTables := TStringList.Create;
  try
    DeviceUUIDsOnTables.Sorted := False;
    DeviceUUIDsOnTables.Duplicates := dupIgnore;

    if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
      for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
      begin
        WT := FWorkTableManager.WorkTables[I];
        if (WT = nil) or (WT.DeviceChannels = nil) then
          Continue;

        for Ch in WT.DeviceChannels do
          if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
            DeviceUUIDsOnTables.Add(Trim(Ch.FlowMeter.Device.UUID));
      end;

    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
        if (Device <> nil) and (Device.State <> osDeleted) and
           IsManualProcessingDevice(Device) and
           (DeviceUUIDsOnTables.IndexOf(Trim(Device.UUID)) < 0) then
          Devices.Add(Device);

    ShowDevicesResults(Devices);
  finally
    DeviceUUIDsOnTables.Free;
    Devices.Free;
  end;
end;
procedure TFrameProceed.UpdateGridResults;
var
  I, VisibleColumnCount: Integer;
begin
  FActiveWorkTable := ResolveManagerWorkTable(FWorkTableManager);
  GridResults.BeginUpdate;
  try
    if GridDataPoints <> nil then
    begin
      GridResults.Options := GridDataPoints.Options;
      GridResults.RowHeight := GridDataPoints.RowHeight;
      GridResults.StyleLookup := GridDataPoints.StyleLookup;
    end;
  finally
    GridResults.EndUpdate;
  end;

  TGridLayoutManager.SetRowCount(GridResults,
    Length(FCurrentResultRows));
  ButtonExportExcel.Enabled := GridResults.RowCount > 0;
  if Length(FCurrentResultRows) = 0 then
    GridResults.Row := -1
  else if (GridResults.Row < 0) or (GridResults.Row >= Length(FCurrentResultRows)) then
    GridResults.Row := 0;

  GridResults.Repaint;
  GridResultsSelChanged(GridResults);

  GridResults.Visible := True;
  GridDataPoints.Visible := False;
  // Data and all named columns now exist, so no later default population can
  // overwrite the persisted order, width or visibility.
  if FActiveWorkTable <> nil then
    ApplyGridColumnsLayout(GridResults, FActiveWorkTable.ResultsGridColumns);
  NormalizeResultsPointColumnsVisibility;
  SetGridReadOnly(GridResults);
  UpdateActionHints;
  VisibleColumnCount := 0;
  for I := 0 to GridResults.ColumnCount - 1 do
    if GridResults.Columns[I].Visible then
      Inc(VisibleColumnCount);
  LogProceedGridContext('Summary', nil, nil, GridResults.RowCount,
    VisibleColumnCount);
end;
procedure TFrameProceed.UpdateGridDataPoints;
var
  I, Count: Integer;
begin
  FActiveWorkTable := ResolveManagerWorkTable(FWorkTableManager);
//  UpdateGridDataPointsHeaders(FActiveWorkTable.TableFlow.ValueVolume.GetDimName, FActiveWorkTable.TableFlow.ValueVolumeFlow.GetDimName);
  Count := 0;
  for I := 0 to High(FCurrentSpillages) do
    if (FCurrentSpillages[I] <> nil) and (FCurrentSpillages[I].State <> osDeleted) then
    begin
      FCurrentSpillages[Count] := FCurrentSpillages[I];
      Inc(Count);
    end;
  SetLength(FCurrentSpillages, Count);
  SortProcessingDataByDate;

  TGridLayoutManager.SetRowCount(GridDataPoints,
    Length(FCurrentSpillages), True);
  GridResults.Visible := False;
  GridDataPoints.Visible := True;
  ButtonExportExcel.Enabled := GridDataPoints.RowCount > 0;
  // Restore through the existing WorkTable layout only after rows and headers
  // have been populated.
  if FActiveWorkTable <> nil then
    ApplyGridColumnsLayout(GridDataPoints, FActiveWorkTable.DataPointsGridColumns);
  SetGridReadOnly(GridDataPoints);
  UpdateActionHints;
  LogProceedGridContext('Measurements', ResolveSelectedDevice, FCurrentSession,
    GridDataPoints.RowCount, GridDataPoints.ColumnCount);
end;
function TFrameProceed.BuildCurrentSpillagesList: TObjectList<TPointSpillage>;
var
  Point: TPointSpillage;
begin
  Result := TObjectList<TPointSpillage>.Create(False);
  for Point in FCurrentSpillages do
    if (Point <> nil) and (Point.State <> osDeleted) then
      Result.Add(Point);
end;
procedure TFrameProceed.ShowDeviceSpillages(ADevice: TDevice);
var
  Point: TPointSpillage;
  ActiveSession: TSessionSpillage;
  List: TList<TPointSpillage>;
begin
  SetLength(FCurrentSpillages, 0);
  if ADevice <> nil then
  begin
    ActiveSession := GetActiveVisibleSession(ADevice);
    List := TList<TPointSpillage>.Create;
    try
      if ADevice.Spillages <> nil then
        for Point in ADevice.Spillages do
          if (Point <> nil) and (Point.State <> osDeleted) and
             (ActiveSession <> nil) and (Point.SessionID = ActiveSession.ID) then
            List.Add(Point);

      FCurrentSpillages := List.ToArray;
    finally
      List.Free;
    end;
  end;

  UpdateGridDataPoints;
end;
procedure TFrameProceed.ShowSessionSpillages(ASession: TSessionSpillage);
var
  Device: TDevice;
  Point: TPointSpillage;
  List: TList<TPointSpillage>;
  I: Integer;
begin
  SetLength(FCurrentSpillages, 0);
  if ASession = nil then
  begin
    UpdateGridDataPoints;
    Exit;
  end;

  Device := ResolveSelectedDevice;
  if (Device = nil) then
  begin
    UpdateGridDataPoints;
    Exit;
  end;

  LogMKS('DBG SP 6001', 'ShowSessionSpillages ENTER',
    Format('Device=%s UUID=%s; Session.ID=%d; Session.Spillages.Count=%d; Device.Spillages.Count=%d',
      [Device.Name, Device.UUID, ASession.ID, ASession.Spillages.Count, Device.Spillages.Count]));

  List := TList<TPointSpillage>.Create;
  try
    if Device.Spillages <> nil then
    begin
      for Point in Device.Spillages do
        if (Point <> nil) and (Point.SessionID = ASession.ID) and (Point.State <> osDeleted) then
        begin
          List.Add(Point);
          LogMKS('DBG SP 6002', 'ShowSessionSpillages ADD FROM Device.Spillages', DumpSpillage(Point));
        end;
    end;

    if (List.Count = 0) and (ASession.Spillages <> nil) then
    begin
      for I := 0 to ASession.Spillages.Count - 1 do
      begin
        Point := ASession.Spillages[I];
        if (Point <> nil) and (Point.State <> osDeleted) then
        begin
          List.Add(Point);
          LogMKS('DBG SP 6003', 'ShowSessionSpillages ADD FROM Session.Spillages', DumpSpillage(Point));
        end;
      end;
    end;

    FCurrentSpillages := List.ToArray;
    LogMKS('DBG SP 6004', 'ShowSessionSpillages EXIT',
      Format('FCurrentSpillages.Count=%d', [Length(FCurrentSpillages)]));
    for I := 0 to High(FCurrentSpillages) do
      LogMKS('DBG SP 6005', 'ShowSessionSpillages CURRENT',
        Format('Index=%d | %s', [I, DumpSpillage(FCurrentSpillages[I])]));
  finally
    List.Free;
  end;

  UpdateGridDataPoints;
end;
function TFrameProceed.ResolveSelectedDevice: TDevice;
var
  Item: TTreeViewItem;
  Sess: TSessionSpillage;
  NeedInitSessionDevice: Boolean;
  NeedInitSessionEtalon: Boolean;
begin
  Result := nil;
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if Item.TagObject is TDevice then
    Result := TDevice(Item.TagObject)
  else
  begin
    if not (Item.TagObject is TSessionSpillage) then
      Exit;

    Sess := TSessionSpillage(Item.TagObject);
    if (Item.ParentItem <> nil) and (Item.ParentItem.TagObject is TDevice) then
      Result := TDevice(Item.ParentItem.TagObject)
    else if (AppServices.DataManager <> nil) and (AppServices.DataManager.ActiveDeviceRepo <> nil) then
      Result := AppServices.DataManager.ActiveDeviceRepo.FindDeviceByUUID(Sess.DeviceUUID);
  end;

  if Result = nil then
    Exit;

  NeedInitSessionDevice :=
    (FSessionDevice = nil) or
    (FSessionDevice.ValueVolume = nil) or
    (FSessionDevice.ValueMass = nil) or
    (FSessionDevice.ValueVolumeFlow = nil) or
    (FSessionDevice.ValueMassFlow = nil);

  if NeedInitSessionDevice then
  begin
    FreeAndNil(FSessionDevice);
    FSessionDevice := TFlowMeter.Create;
    FSessionDevice.InitAllValues;
  end;

  NeedInitSessionEtalon :=
    (FSessionEtalon = nil) or
    (FSessionEtalon.ValueVolume = nil) or
    (FSessionEtalon.ValueMass = nil) or
    (FSessionEtalon.ValueVolumeFlow = nil) or
    (FSessionEtalon.ValueMassFlow = nil);

  if NeedInitSessionEtalon then
  begin
    FreeAndNil(FSessionEtalon);
    FSessionEtalon := TFlowMeter.Create;
    FSessionEtalon.InitAllValues;
  end;

  FSessionDevice.Device := Result;
  FSessionEtalon.Device := Result;

  if FActiveWorkTable <> nil then
  SetSessionDim(FActiveWorkTable.FlowUnitName, FActiveWorkTable.QuantityUnitName);
end;

procedure TFrameProceed.PopupMenuTreeViewDevicesPopup(Sender: TObject);
var
  Item: TTreeViewItem;

  procedure AddActionMenuItem(const AAction: TAction);
  var
    MenuItem: TMenuItem;
  begin
    if AAction = nil then
      Exit;

    MenuItem := TMenuItem.Create(PopupMenuTreeViewDevices);
    MenuItem.Action := AAction;
    PopupMenuTreeViewDevices.AddObject(MenuItem);
  end;

  procedure AddSimpleMenuItem(const AText: string; AOnClick: TNotifyEvent);
  var
    MenuItem: TMenuItem;
  begin
    MenuItem := TMenuItem.Create(PopupMenuTreeViewDevices);
    MenuItem.Text := AText;
    MenuItem.OnClick := AOnClick;
    PopupMenuTreeViewDevices.AddObject(MenuItem);
  end;
begin
  DbgProceedTree(1701, 'PopupMenuTreeViewDevicesPopup ENTER'#13#10 + GetSelectedTreeDebugText);
  if PopupMenuTreeViewDevices = nil then
    Exit;

  PopupMenuTreeViewDevices.Clear;

  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;

  if SameText(Item.Text, '...') then
  begin
    AddSimpleMenuItem('Очистить', MenuTreeViewDevicesClearClick);
    AddSimpleMenuItem('Добавить', MenuTreeViewDevicesAddClick);
    DbgProceedTree(1702, 'Popup adds menu item: Добавить; selected=' + TreeViewDevices.Selected.Text);
    AddActionMenuItem(ActionSessionSynchTable);
    DbgProceedTree(1703, 'PopupMenuTreeViewDevicesPopup EXIT'#13#10 + GetSelectedTreeDebugText);
    Exit;
  end;

  if Item.TagObject is TWorkTable then
  begin
    AddActionMenuItem(ActionDeleteWorkTable);
    AddActionMenuItem(ActionDeleteSelectedWorkTables);
    AddActionMenuItem(ActionSessionSynchTable);
    DbgProceedTree(1703, 'PopupMenuTreeViewDevicesPopup EXIT'#13#10 + GetSelectedTreeDebugText);
    Exit;
  end;

  if SameText(Item.Text, 'прочее') then
  begin
    AddSimpleMenuItem('Очистить', MenuTreeViewDevicesClearClick);
    AddSimpleMenuItem('Добавить', MenuTreeViewDevicesAddClick);
    DbgProceedTree(1702, 'Popup adds menu item: Добавить; selected=' + TreeViewDevices.Selected.Text);
    AddActionMenuItem(ActionSessionSynchTable);
    DbgProceedTree(1703, 'PopupMenuTreeViewDevicesPopup EXIT'#13#10 + GetSelectedTreeDebugText);
    Exit;
  end;

  if Item.TagObject is TDevice then
  begin
    AddSimpleMenuItem('Редактировать прибор', MenuTreeViewDevicesEditClick);
    AddSimpleMenuItem('Удалить', MenuTreeViewDevicesDeleteClick);
    AddSimpleMenuItem('Добавить', MenuTreeViewDevicesAddClick);
    DbgProceedTree(1702, 'Popup adds menu item: Добавить; selected=' + TreeViewDevices.Selected.Text);
    DbgProceedTree(1703, 'PopupMenuTreeViewDevicesPopup EXIT'#13#10 + GetSelectedTreeDebugText);
    Exit;
  end;

  if Item.TagObject is TSessionSpillage then
  begin
    AddSimpleMenuItem('Редактировать прибор', MenuTreeViewDevicesEditClick);
    AddActionMenuItem(ActionSessionDelete);
    AddActionMenuItem(ActionSessionClose);
    AddActionMenuItem(ActionSessionPointsClear);
    AddActionMenuItem(ActionSessionActive);
    AddActionMenuItem(ActionSessionNew);
  end;
  DbgProceedTree(1703, 'PopupMenuTreeViewDevicesPopup EXIT'#13#10 + GetSelectedTreeDebugText);
end;

procedure TFrameProceed.MenuTreeViewDevicesEditClick(Sender: TObject);
var Device: TDevice; Frm: TFormDeviceEditor; SelectedObject: TObject;
begin
  Device := ResolveSelectedDevice;
  if Device = nil then Exit;
  SelectedObject := TreeViewDevices.Selected.TagObject;
  Frm := TFormDeviceEditor.Create(Self);
  try
    Frm.LoadDevice(Device);
    if Frm.ShowModal <> mrOk then Exit;
  finally
    Frm.Free;
  end;
  PopulateTreeViewDevices;
  SelectTreeItemByTagObject(SelectedObject);
  UpdateSessionItems;
end;

procedure TFrameProceed.PopupMenuGridResultsPopup(Sender: TObject);
var
  ColumnsMenu, Item: TMenuItem;
  Grid: TGrid;
  I, J: Integer;
begin
  if Sender = PopupMenuGridDataPoints then
  begin
    Grid := GridDataPoints;
    ColumnsMenu := MenuItemGridDataPointsColumns;
  end
  else if Sender = PopupMenuGridResults then
  begin
    Grid := GridResults;
    ColumnsMenu := MenuItemGridResultsColumns;
  end
  else
    Exit;

  // Do not destroy or create controls while FMX is opening a native popup:
  // doing so can deadlock its menu service.  The branch is built once and an
  // opening only synchronizes check marks.
  for I := 0 to ColumnsMenu.ItemsCount - 1 do
    if ColumnsMenu.Items[I] is TMenuItem then
    begin
      Item := TMenuItem(ColumnsMenu.Items[I]);
      if Item.TagString = '' then
        Continue;
      Item.IsChecked := False;
      for J := 0 to Grid.ColumnCount - 1 do
        if SameText(Grid.Columns[J].Name, Item.TagString) then
        begin
          Item.IsChecked := Grid.Columns[J].Visible;
          Break;
        end;
    end;
end;

procedure TFrameProceed.BuildGridColumnsMenu(AGrid: TGrid;
  AColumnsMenu: TMenuItem);
var
  I: Integer;
  Item, ResetItem: TMenuItem;
begin
  if (AGrid = nil) or (AColumnsMenu = nil) or
     (AColumnsMenu.ItemsCount <> 0) then
    Exit;
  for I := 0 to AGrid.ColumnCount - 1 do
  begin
    Item := TMenuItem.Create(AColumnsMenu);
    Item.Text := AGrid.Columns[I].Header;
    Item.TagString := AGrid.Columns[I].Name;
    Item.IsChecked := AGrid.Columns[I].Visible;
    Item.OnClick := GridColumnMenuClick;
    AColumnsMenu.AddObject(Item);
  end;
  ResetItem := TMenuItem.Create(AColumnsMenu);
  ResetItem.Text := 'Восстановить по умолчанию';
  ResetItem.OnClick := GridColumnsResetClick;
  AColumnsMenu.AddObject(ResetItem);
end;

procedure TFrameProceed.GridColumnMenuClick(Sender: TObject);
var
  Grid: TGrid;
  Item: TMenuItem;
  I: Integer;
begin
  if not (Sender is TMenuItem) then
    Exit;
  Item := TMenuItem(Sender);
  if GridResults.Visible then Grid := GridResults else Grid := GridDataPoints;
  // Resolve by the stable component name, not by a display index that changes
  // as soon as columns are reordered.
  for I := 0 to Grid.ColumnCount - 1 do
    if SameText(Grid.Columns[I].Name, Item.TagString) then
    begin
      Grid.Columns[I].Visible := not Grid.Columns[I].Visible;
      Item.IsChecked := Grid.Columns[I].Visible;
      Break;
    end;
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameProceed.GridColumnsResetClick(Sender: TObject);
var Grid: TGrid; I: Integer;
begin
  if GridResults.Visible then Grid := GridResults else Grid := GridDataPoints;
  for I := 0 to Grid.ColumnCount - 1 do
  begin
    Grid.Columns[I].Visible := True;
    Grid.Columns[I].Index := I;
  end;
  if Grid = GridResults then UpdateResultsPointColumns;
  SaveLayoutSettingsToWorkTable;
end;

procedure TFrameProceed.ButtonExportExcelClick(Sender: TObject);
var Dialog: TSaveDialog; Grid: TGrid; Table: TGridXlsxTable; Line: TStringList;
  R, C, VisibleColumns: Integer; V: TValue; Context: string;
begin
  if GridResults.Visible then Grid := GridResults else Grid := GridDataPoints;
  if Grid.RowCount = 0 then Exit;
  Dialog := TSaveDialog.Create(Self);
  try
    Dialog.DefaultExt := 'xlsx';
    Dialog.Filter := 'Excel Workbook (*.xlsx)|*.xlsx';
    Dialog.FileName := 'Proceed_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.xlsx';
    if not Dialog.Execute then Exit;
    Table := TGridXlsxTable.Create;
    try
      VisibleColumns := 0;
      for C := 0 to Grid.ColumnCount - 1 do
        if Grid.Columns[C].Visible then
        begin
          Table.AddColumn(Grid.Columns[C].Header, Grid.Columns[C].Width);
          Inc(VisibleColumns);
        end;
      for R := 0 to Grid.RowCount - 1 do
      begin
        Line := Table.AddRow;
        for C := 0 to Grid.ColumnCount - 1 do
          if Grid.Columns[C].Visible then
          begin
            V := TValue.Empty;
            if Grid = GridResults then GridResultsGetValue(Grid, C, R, V)
            else GridDataPointsGetValue(Grid, C, R, V);
            Line.Add(V.ToString);
          end;
      end;
      TGridXlsxExporter.ExportToFile(Table, Dialog.FileName, 'Обработка');
      if Grid = GridResults then Context := 'Summary' else Context := 'Measurements';
      ProtocolManager.AddMessage(pcProc, psForm, 'ProceedExcelExport',
        'Экспортированы выбранные данные обработки', Format('Context=%s; Rows=%d; Columns=%d',
          [Context, Grid.RowCount, VisibleColumns]));
    finally
      Table.Free;
    end;
  finally
    Dialog.Free;
  end;
end;
procedure TFrameProceed.MenuTreeViewDevicesClearClick(Sender: TObject);
var
  Item: TTreeViewItem;
  WT: TWorkTable;
  Ch: TChannel;
  Device: TDevice;
  I, J: Integer;
  DeviceUUIDsOnTables: TStringList;
begin
  DbgProceedTree(1504, 'MenuTreeViewDevicesClearClick ENTER'#13#10 + GetSelectedTreeDebugText);
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if (not SameText(Item.Text, 'прочее')) and (not SameText(Item.Text, '...')) then
    Exit;

  if FProcessingDevices = nil then
    Exit;

  if SameText(Item.Text, '...') then
  begin
    FProcessingDevices.Clear;
    if FManualProcessingDeviceUUIDs <> nil then
      FManualProcessingDeviceUUIDs.Clear;
    SaveProcessingDevices;
    RefreshResultsAfterDevicesAction;
    Exit;
  end;

  DeviceUUIDsOnTables := TStringList.Create;
  try
    DeviceUUIDsOnTables.Sorted := False;
    DeviceUUIDsOnTables.Duplicates := dupIgnore;

    if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
      for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
      begin
        WT := FWorkTableManager.WorkTables[I];
        if (WT = nil) or (WT.DeviceChannels = nil) then
          Continue;

        for Ch in WT.DeviceChannels do
          if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
            DeviceUUIDsOnTables.Add(Trim(Ch.FlowMeter.Device.UUID));
      end;

    for J := FProcessingDevices.Count - 1 downto 0 do
    begin
      Device := FProcessingDevices[J];
      if (Device <> nil) and (DeviceUUIDsOnTables.IndexOf(Trim(Device.UUID)) < 0) then
        FProcessingDevices.Delete(J);
    end;

    SaveProcessingDevices;
    RefreshResultsAfterDevicesAction;
  finally
    DeviceUUIDsOnTables.Free;
  end;
end;
procedure TFrameProceed.SyncProcessingDevicesFromTable(AWorkTable: TWorkTable;
  const AClearBeforeSync: Boolean);
var
  Ch: TChannel;
  Device: TDevice;

  function HasDeviceData(AChannel: TChannel; ADevice: TDevice): Boolean;
  begin
    Result := False;

    if AChannel <> nil then
    begin
      Result := (Trim(AChannel.TypeName) <> '') or
        (Trim(AChannel.Serial) <> '') or
        (AChannel.Signal >= 0) or
        (Trim(AChannel.TypeUUID) <> '') or
        (Trim(AChannel.RepoTypeName) <> '') or
        (Trim(AChannel.RepoTypeUUID) <> '') or
        (Trim(AChannel.RepoDeviceName) <> '') or
        (Trim(AChannel.RepoDeviceUUID) <> '');

      if Result then
        Exit;
    end;

    if ADevice = nil then
      Exit;

    Result := (Trim(ADevice.Name) <> '') or
      (Trim(ADevice.SerialNumber) <> '') or
      (ADevice.OutputType >= 0) or
      (Trim(ADevice.DeviceTypeName) <> '') or
      (Trim(ADevice.DeviceTypeUUID) <> '') or
      (Trim(ADevice.RepoTypeName) <> '') or
      (Trim(ADevice.RepoTypeUUID) <> '') or
      (Trim(ADevice.RepoDeviceName) <> '') or
      (Trim(ADevice.RepoDeviceUUID) <> '');
  end;
begin
  if FProcessingDevices = nil then
    Exit;

  if AClearBeforeSync then
  begin
    FProcessingDevices.Clear;
  end;

  if (AWorkTable <> nil) and (AWorkTable.DeviceChannels <> nil) then
    for Ch in AWorkTable.DeviceChannels do
      if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
      begin
        Device := Ch.FlowMeter.Device;
        if HasDeviceData(Ch, Device) then
          AddProcessingDevice(Device);
      end;
end;

procedure TFrameProceed.SyncProcessingDevicesWithNewPoints;
var
  Ini: TIniFile;
  I, OldCount, PointCount, SavedPointCount: Integer;
  WT: TWorkTable;
  Ch: TChannel;
  Device: TDevice;
begin
  if (FProcessingDevices = nil) or (FWorkTableManager = nil) or
     (FWorkTableManager.WorkTables = nil) or (Trim(FWorkTableManager.IniFileName) = '') then
    Exit;

  OldCount := FProcessingDevices.Count;
  Ini := TIniFile.Create(FWorkTableManager.IniFileName);
  try
    for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
    begin
      WT := FWorkTableManager.WorkTables[I];
      if (WT = nil) or (WT.DeviceChannels = nil) then
        Continue;

      for Ch in WT.DeviceChannels do
      begin
        if (Ch = nil) or (Ch.FlowMeter = nil) or (Ch.FlowMeter.Device = nil) then
          Continue;

        Device := Ch.FlowMeter.Device;
        if Trim(Device.UUID) = '' then
          Continue;

        PointCount := GetDeviceSpillageCount(Device);
        SavedPointCount := Ini.ReadInteger(CProcessingDevicePointCountsSection,
          Trim(Device.UUID), 0);
        if PointCount > SavedPointCount then
          AddProcessingDevice(Device);
      end;
    end;
  finally
    Ini.Free;
  end;

  if FProcessingDevices.Count <> OldCount then
    SaveProcessingDevices
  else
    SaveProcessingPointCounts;
end;

procedure TFrameProceed.SyncProcessingDevicesFromAllTables(const AClearBeforeSync: Boolean);
var
  I: Integer;
  WT: TWorkTable;
begin
  if FProcessingDevices = nil then
    Exit;

  if AClearBeforeSync then
  begin
    FProcessingDevices.Clear;
  end;

  if (FWorkTableManager = nil) or (FWorkTableManager.WorkTables = nil) then
    Exit;

  for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
  begin
    WT := FWorkTableManager.WorkTables[I];
    SyncProcessingDevicesFromTable(WT, False);
  end;
end;
procedure TFrameProceed.ActionSessionSynchTableExecute(Sender: TObject);
var
  Item: TTreeViewItem;
begin
  DbgProceedTree(1506, 'ActionSessionSynchTableExecute ENTER'#13#10 + GetSelectedTreeDebugText);
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;

  if Item.TagObject is TWorkTable then
    SyncProcessingDevicesFromTable(TWorkTable(Item.TagObject), False)
  else if SameText(Item.Text, '...') then
    SyncProcessingDevicesFromAllTables(True)
  else if SameText(Item.Text, 'прочее') then
    SyncProcessingDevicesFromAllTables(False)
  else
    Exit;

  SaveProcessingDevices;
  RefreshResultsAfterDevicesAction;
end;
procedure TFrameProceed.MenuTreeViewDevicesAddClick(Sender: TObject);
begin
  DbgProceedTree(1001, 'MenuTreeViewDevicesAddClick ENTER'#13#10 + GetSelectedTreeDebugText);
  AddProcessingDeviceFromSelection;
  DbgProceedTree(1002, 'MenuTreeViewDevicesAddClick EXIT'#13#10 + GetSelectedTreeDebugText);
end;
function TFrameProceed.IsSelectedTreeWorkTable(out AWorkTable: TWorkTable): Boolean;
var
  Item: TTreeViewItem;
begin
  // Рабочим столом считается только узел, у которого TagObject указывает на TWorkTable.
  AWorkTable := nil;
  Result := False;

  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if not (Item.TagObject is TWorkTable) then
    Exit;

  AWorkTable := TWorkTable(Item.TagObject);
  Result := AWorkTable <> nil;
end;

procedure TFrameProceed.ClearCurrentResultsView;
begin
  FCurrentSession := nil;
  SetLength(FCurrentResultRows, 0);
  SetLength(FCurrentSpillages, 0);

  if FSessionDevice <> nil then
    FSessionDevice.Device := nil;
  if FSessionEtalon <> nil then
    FSessionEtalon.Device := nil;

  if LabelSessionDate <> nil then
    LabelSessionDate.Text := 'Сессия';
  if LabelSessionActive <> nil then
    LabelSessionActive.Text := '';

  if GridResults <> nil then
    TGridLayoutManager.SetRowCount(GridResults, 0);
  if GridDataPoints <> nil then
    TGridLayoutManager.SetRowCount(GridDataPoints, 0);
  if GridCoefs <> nil then
    TGridLayoutManager.SetRowCount(GridCoefs, 0);
  if Chart1 <> nil then
    Chart1.ClearAllSeries;

  if FFrameCalibrCoefs <> nil then
    FFrameCalibrCoefs.Init(nil, cctMeterValueCoef, nil);
  UpdateActionHints;
end;

procedure TFrameProceed.RefreshAfterWorkTableDeletion;
var
  NextWorkTable: TWorkTable;
begin
  DbgProceedTree(1503, 'RefreshAfterWorkTableDeletion ENTER'#13#10 + GetSelectedTreeDebugText);
  NextWorkTable := nil;
  if (FWorkTableManager <> nil) and (FWorkTableManager.WorkTables <> nil) then
  begin
    if FWorkTableManager.WorkTables.IndexOf(FWorkTableManager.ActiveWorkTable) >= 0 then
      NextWorkTable := FWorkTableManager.ActiveWorkTable
    else if FWorkTableManager.WorkTables.Count > 0 then
    begin
      NextWorkTable := FWorkTableManager.WorkTables[0];
      FWorkTableManager.ActiveWorkTable := NextWorkTable;
      NextWorkTable.IsActive := True;
    end;
  end;

  FActiveWorkTable := NextWorkTable;

  ClearCurrentResultsView;

  if FWorkTableManager <> nil then
    FWorkTableManager.Save;

  PopulateTreeViewDevices;
  if NextWorkTable <> nil then
  begin
    SelectTreeItemByTagObject(NextWorkTable);
    ShowWorkTableResults(NextWorkTable);
  end
  else
    ClearCurrentResultsView;

  UpdateSessionItems;
end;


function TFrameProceed.FindUnassignedMeasurements: TArray<TPointSpillage>;
var
  Items: TList<TPointSpillage>;
  Device: TDevice;
  Spillage: TPointSpillage;
begin
  Items := TList<TPointSpillage>.Create;
  try
    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
        if (Device <> nil) and (Device.State <> osDeleted) and (Device.Spillages <> nil) then
          for Spillage in Device.Spillages do
            if (Spillage <> nil) and (Spillage.State <> osDeleted) and Spillage.Enabled and
               (Device.FindMatchedDevicePointForSpillage(Spillage) = nil) then
              Items.Add(Spillage);
    Result := Items.ToArray;
  finally
    Items.Free;
  end;
end;

function TFrameProceed.FindExcessMeasurements: TArray<TPointSpillage>;
var
  Excess, Candidates: TList<TPointSpillage>;
  Device: TDevice;
  Point: TDevicePoint;
  Spillage: TPointSpillage;
  AllowedCount, I: Integer;
begin
  Excess := TList<TPointSpillage>.Create;
  Candidates := TList<TPointSpillage>.Create;
  try
    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
        if (Device <> nil) and (Device.State <> osDeleted) and (Device.Points <> nil) and
           (Device.Spillages <> nil) then
          for Point in Device.Points do
          begin
            if (Point = nil) or (not Point.Enabled) then
              Continue;

            AllowedCount := Max(Point.Repeats, 1);
            Candidates.Clear;
            for Spillage in Device.Spillages do
              if (Spillage <> nil) and (Spillage.State <> osDeleted) and Spillage.Enabled and
                 (Device.FindMatchedDevicePointForSpillage(Spillage) = Point) then
                Candidates.Add(Spillage);

            if Candidates.Count <= AllowedCount then
              Continue;

            Candidates.Sort(TComparer<TPointSpillage>.Construct(
              function(const Left, Right: TPointSpillage): Integer
              begin
                Result := CompareValue(Ord(Right.Validation = vsValid), Ord(Left.Validation = vsValid));
                if Result <> 0 then Exit;
                Result := CompareValue(Ord(Right.Validation in [vsValid, vsInvalid]), Ord(Left.Validation in [vsValid, vsInvalid]));
                if Result <> 0 then Exit;
                Result := CompareValue(Abs(Left.Error), Abs(Right.Error));
                if Result <> 0 then Exit;
                Result := CompareValue(Left.DateTime, Right.DateTime);
              end));

            for I := AllowedCount to Candidates.Count - 1 do
              Excess.Add(Candidates[I]);
          end;
    Result := Excess.ToArray;
  finally
    Candidates.Free;
    Excess.Free;
  end;
end;

procedure TFrameProceed.RemoveInvalidAndExcessMeasurements;
var
  Unassigned, Excess: TArray<TPointSpillage>;
  Device: TDevice;
  Point: TDevicePoint;
  Spillage: TPointSpillage;
  TotalBefore, TotalAfter, DeviceCount, PointCount, UnassignedRemoved, ExcessRemoved: Integer;
  Report, Details: TStringList;
  BeforeCount, RemovedCount, AllowedCount: Integer;

  function ContainsSpillage(const AItems: TArray<TPointSpillage>; ASpillage: TPointSpillage): Boolean;
  var
    Item: TPointSpillage;
  begin
    Result := False;
    for Item in AItems do
      if Item = ASpillage then
        Exit(True);
  end;

begin
  TotalBefore := 0;
  DeviceCount := 0;
  PointCount := 0;
  if FProcessingDevices <> nil then
    for Device in FProcessingDevices do
      if (Device <> nil) and (Device.State <> osDeleted) then
      begin
        Inc(DeviceCount);
        Inc(TotalBefore, GetDeviceSpillageCount(Device));
        if Device.Points <> nil then
          Inc(PointCount, Device.Points.Count);
      end;

  Unassigned := FindUnassignedMeasurements;
  Excess := FindExcessMeasurements;

  Report := TStringList.Create;
  Details := TStringList.Create;
  try
    Report.Add(Format('Всего измерений: %d', [TotalBefore]));
    Report.Add('');
    Report.Add(Format('Не привязано к точкам: %d', [Length(Unassigned)]));
    Report.Add('');
    Report.Add('Лишние повторы:');

    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
        if (Device <> nil) and (Device.State <> osDeleted) and (Device.Points <> nil) and
           (Device.Spillages <> nil) then
          for Point in Device.Points do
          begin
            if Point = nil then Continue;
            AllowedCount := Max(Point.Repeats, 1);
            BeforeCount := 0;
            RemovedCount := 0;
            for Spillage in Device.Spillages do
              if (Spillage <> nil) and (Spillage.Enabled) and (Device.FindMatchedDevicePointForSpillage(Spillage) = Point) then
              begin
                if (Spillage.State <> osDeleted) or ContainsSpillage(Excess, Spillage) then
                  Inc(BeforeCount);
                if ContainsSpillage(Excess, Spillage) then
                  Inc(RemovedCount);
              end;
            if RemovedCount > 0 then
              Report.Add(Format('%s: было %d, разрешено %d, удалено %d',
                [Point.Name, BeforeCount, AllowedCount, RemovedCount]));
            Details.Add(Format('Device=%s; PointName=%s; AllowedRepeats=%d; BeforeCount=%d; RemovedCount=%d; AfterCount=%d',
              [Device.Name, Point.Name, AllowedCount, BeforeCount, RemovedCount, BeforeCount - RemovedCount]));
          end;

    Report.Add('');
    Report.Add(Format('Будет удалено всего: %d', [Length(Unassigned) + Length(Excess)]));
    Report.Add('');
    Report.Add('Будут удалены:'#13#10 +
      '- все измерения, которые не удалось сопоставить с поверочной точкой;'#13#10 +
      '- измерения сверх заданного количества повторов для каждой точки.'#13#10#13#10 +
      'Продолжить?');

    if MessageDlg(Report.Text, TMsgDlgType.mtConfirmation,
        [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
      Exit;

    for Spillage in Unassigned do
      if Spillage <> nil then
        Spillage.State := osDeleted;
    for Spillage in Excess do
      if Spillage <> nil then
        Spillage.State := osDeleted;

    UnassignedRemoved := Length(Unassigned);
    ExcessRemoved := Length(Excess);
    TotalAfter := TotalBefore - UnassignedRemoved - ExcessRemoved;
    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
        if (Device <> nil) and (Device.State = osClean) then
          Device.State := osModified;

    ProtocolManager.AddMessage(pcProc, psForm, 'ProcessingMeasurementsCleanup',
      'Удаление неподключённых измерений и лишних повторов',
      Format('TotalBefore=%d; UnassignedRemoved=%d; ExcessRemoved=%d; TotalAfter=%d; DeviceCount=%d; PointCount=%d%s%s',
        [TotalBefore, UnassignedRemoved, ExcessRemoved, TotalAfter, DeviceCount, PointCount,
         sLineBreak, Details.Text]));

    PopulateTreeViewDevices;
    ShowAllDevicesResults;
    SavePendingProcessingChanges(Self);
    ShowMessage(Format('Удалено измерений: %d', [UnassignedRemoved + ExcessRemoved]));
  finally
    Details.Free;
    Report.Free;
  end;
end;

procedure TFrameProceed.ActionRemoveInvalidAndExcessMeasurementsExecute(Sender: TObject);
begin
  RemoveInvalidAndExcessMeasurements;
end;

procedure TFrameProceed.MenuTreeViewDevicesDeleteWorkTableClick(Sender: TObject);
begin
  ActionDeleteWorkTable.Execute;
end;

procedure TFrameProceed.ActionDeleteWorkTableExecute(Sender: TObject);
var
  WorkTable: TWorkTable;
  WorkTableName: string;
  ObserverHost: IWorkTableObserverHost;
begin
  if not IsSelectedTreeWorkTable(WorkTable) then
    Exit;

  if (FWorkTableManager = nil) or (FWorkTableManager.WorkTables = nil) then
    Exit;

  WorkTableName := Trim(WorkTable.Name);
  if WorkTableName = '' then
    WorkTableName := Trim(WorkTable.Text);

  if WorkTableName = '' then
    Exit;

  if MessageDlg(Format('Удалить рабочий стол "%s"?'#13#10 +
      'Все связанные данные этого рабочего стола будут удалены.', [WorkTableName]),
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
    Exit;

  if TreeViewDevices <> nil then
    TreeViewDevices.Selected := nil;

  if FWorkTableManager.DeleteWorkTableByName(WorkTableName) then
    RefreshAfterWorkTableDeletion;

end;

procedure TFrameProceed.ActionDeleteWorkTableUpdate(Sender: TObject);
var
  WorkTable: TWorkTable;
begin
  ActionDeleteWorkTable.Enabled := IsSelectedTreeWorkTable(WorkTable);
end;

procedure TFrameProceed.ActionDeleteSelectedWorkTablesExecute(Sender: TObject);
var
  DeletedCount: Integer;
  WorkTableCount: Integer;
  I: Integer;
  ObserverHost: IWorkTableObserverHost;
begin
  if (FWorkTableManager = nil) or (FWorkTableManager.WorkTables = nil) then
    Exit;

  WorkTableCount := FWorkTableManager.WorkTables.Count;
  if WorkTableCount = 0 then
    Exit;

  if MessageDlg(Format('Удалить все рабочие столы: %d шт.?', [WorkTableCount]),
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
    Exit;

  if TreeViewDevices <> nil then
    TreeViewDevices.Selected := nil;

  DeletedCount := FWorkTableManager.DeleteWorkTablesByNames;

  if DeletedCount > 0 then
    RefreshAfterWorkTableDeletion;
end;

procedure TFrameProceed.ActionDeleteSelectedWorkTablesUpdate(Sender: TObject);
begin
  ActionDeleteSelectedWorkTables.Enabled :=
    (FWorkTableManager <> nil) and
    (FWorkTableManager.WorkTables <> nil) and
    (FWorkTableManager.WorkTables.Count > 0);
end;

procedure TFrameProceed.MenuTreeViewDevicesDeleteClick(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
begin
  DbgProceedTree(1505, 'MenuTreeViewDevicesDeleteClick ENTER'#13#10 + GetSelectedTreeDebugText);
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if not (Item.TagObject is TDevice) then
    Exit;

  Device := TDevice(Item.TagObject);
  MarkProcessingDeviceRemoved(Device);
end;
procedure TFrameProceed.ActionSessionDeleteExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
  Session, NextSession: TSessionSpillage;
  I, NextIdx: Integer;
  P: TPointSpillage;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if Item.TagObject is TDevice then
  begin
    Device := TDevice(Item.TagObject);
    if MessageDlg('Удалить выбранный прибор из списка обработки?',
        TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
      Exit;

    MarkProcessingDeviceRemoved(Device);
    Exit;
  end;

  if not (Item.TagObject is TSessionSpillage) then
    Exit;

  if MessageDlg('Удалить выбранную сессию и все связанные измерения?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
    Exit;

  Session := TSessionSpillage(Item.TagObject);
  Device := ResolveSelectedDevice;
  if (Session = nil) or (Device = nil) or (Device.Sessions = nil) then
    Exit;

  if Session.Spillages <> nil then
    for P in Session.Spillages do
      if P <> nil then
        P.State := osDeleted;

  if Device.Spillages <> nil then
    for P in Device.Spillages do
      if (P <> nil) and (P.SessionID = Session.ID) then
        P.State := osDeleted;

  NextSession := nil;
  NextIdx := -1;
  if Session.Active then
  begin
    for I := 0 to Device.Sessions.Count - 1 do
      if Device.Sessions[I] = Session then
      begin
        NextIdx := I;
        Break;
      end;

    if NextIdx >= 0 then
      for I := NextIdx + 1 to Device.Sessions.Count - 1 do
        if (Device.Sessions[I] <> nil) and (Device.Sessions[I].State <> osDeleted) then
        begin
          NextSession := Device.Sessions[I];
          Break;
        end;

    if NextSession = nil then
      for I := 0 to Device.Sessions.Count - 1 do
        if (Device.Sessions[I] <> nil) and (Device.Sessions[I] <> Session) and
           (Device.Sessions[I].State <> osDeleted) then
        begin
          NextSession := Device.Sessions[I];
          Break;
        end;
  end;

  Session.Active := False;
  Session.State := osDeleted;

  if NextSession <> nil then
  begin
    NextSession.Active := True;
    if NextSession.Status = 0 then
      NextSession.Status := 1;
    NextSession.State := osModified;
  end;

  RefreshMeasurementsAfterSessionAction(Device, NextSession);
end;
procedure TFrameProceed.ActionSessionDeviceAddExecute(Sender: TObject);
begin
  DbgProceedTree(1507, 'ActionSessionDeviceAddExecute ENTER'#13#10 + GetSelectedTreeDebugText);
  AddProcessingDeviceFromSelection;
end;
procedure TFrameProceed.ActionSessionDeviceRemoveExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if not (Item.TagObject is TDevice) then
    Exit;

  Device := TDevice(Item.TagObject);
  MarkProcessingDeviceRemoved(Device);
end;
procedure TFrameProceed.ActionSessionCloseExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  Session := nil;
  Device := nil;
  if Item.TagObject is TSessionSpillage then
  begin
    Session := TSessionSpillage(Item.TagObject);
    Device := ResolveSelectedDevice;
  end
  else if Item.TagObject is TDevice then
  begin
    Device := TDevice(Item.TagObject);
    Session := GetActiveVisibleSession(Device);
  end;

  if (Session = nil) or (Device = nil) then
    Exit;

  Session.Active := False;
  Session.Status := 2;
  Session.DateTimeClose := Now;
  Session.State := osModified;

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;
procedure TFrameProceed.ActionSessionPointDeleteExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  Point: TPointSpillage;
begin
  if (not GridDataPoints.Visible) or (GridDataPoints.Row < 0) or
     (GridDataPoints.Row >= Length(FCurrentSpillages)) then
    Exit;

  Item := TreeViewDevices.Selected;
  if (Item <> nil) and (Item.TagObject is TSessionSpillage) then
   begin
       Session := TSessionSpillage(Item.TagObject);
       Device := ResolveSelectedDevice;
       Point := FCurrentSpillages[GridDataPoints.Row];

   if (Session = nil) or (Device = nil) or (Point = nil) then
    Exit;

  Point.State := osDeleted;
  if (Device.Spillages <> nil) and (Point.ID > 0) then
    for Point in Device.Spillages do
      if (Point <> nil) and (Point.ID = FCurrentSpillages[GridDataPoints.Row].ID) then
      begin
        Point.State := osDeleted;
        Break;
      end;
  if Device.State = osClean then
    Device.State := osModified;
  Session.State := osModified;

  RefreshMeasurementsAfterSessionAction(nil, Session);

   end;

   if (Item <> nil) and (Item.TagObject is TDevice) then
   begin
       Device := TDevice(Item.TagObject);
       Point := FCurrentSpillages[GridDataPoints.Row];

   if (Device = nil) or (Point = nil) then
    Exit;

  Point.State := osDeleted;
  if Device.State = osClean then
    Device.State := osModified;

  RefreshMeasurementsAfterSessionAction(Device, nil);

   end;





end;
procedure TFrameProceed.ActionSessionPointsClearExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  P: TPointSpillage;
begin
  if not GridDataPoints.Visible then
    Exit;

  Item := TreeViewDevices.Selected;
  if Item = nil then
    Exit;

  Session := nil;
  Device := nil;
  if Item.TagObject is TSessionSpillage then
  begin
    Session := TSessionSpillage(Item.TagObject);
    Device := ResolveSelectedDevice;
    if (Session = nil) and (Device = nil) then
      Exit;

    if Session.Spillages <> nil then
      for P in Session.Spillages do
        if P <> nil then
          P.State := osDeleted;

    if Device.Spillages <> nil then
      for P in Device.Spillages do
        if (P <> nil) and (P.SessionID = Session.ID) then
          P.State := osDeleted;

      Session.State := osModified;
  end
  else if Item.TagObject is TDevice then
  begin
    Device := TDevice(Item.TagObject);
    if (Device = nil) or (Length(FCurrentSpillages) = 0) then
      Exit;

    for P in FCurrentSpillages do
      if P <> nil then
        P.State := osDeleted;
  end
  else
    Exit;

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;
procedure TFrameProceed.ActionSessionActiveExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session, S: TSessionSpillage;
  Device: TDevice;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  Session := nil;
  Device := nil;
  if Item.TagObject is TSessionSpillage then
  begin
    Session := TSessionSpillage(Item.TagObject);
    Device := ResolveSelectedDevice;
  end
  else if Item.TagObject is TDevice then
  begin
    Device := TDevice(Item.TagObject);
    Session := GetActiveVisibleSession(Device);
  end;

  if (Session = nil) or (Device = nil) or (Device.Sessions = nil) then
    Exit;

  for S in Device.Sessions do
    if (S <> nil) and (S.State <> osDeleted) then
    begin
      if S = Session then
      begin
        S.Active := True;
        S.Status := 1;
        S.DateTimeClose := 0;
      end
      else
        S.Active := False;

      S.State := osModified;
    end;

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;
procedure TFrameProceed.ActionSessionNewExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
  Session: TSessionSpillage;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  Device := nil;
  if Item.TagObject is TDevice then
    Device := TDevice(Item.TagObject)
  else if Item.TagObject is TSessionSpillage then
    Device := ResolveSelectedDevice;

  if Device = nil then
    Exit;

  Session := Device.AddSessionSpillage;
  if Session <> nil then
  begin
    Session.DateTimeOpen := Now;
    Session.DateTimeClose := 0;
    Session.Status := 0;
  end;

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;

procedure TFrameProceed.TreeViewDevicesChange(Sender: TObject);
begin
  DbgProceedTree(1601, 'TreeViewDevicesChange ENTER'#13#10 +
    GetSelectedTreeDebugText + #13#10 + GetProcessingDevicesDebugText);
  UpdateSessionItems;
  UpdateCalibrCoefsFrame;
  UpdateActionHints;
end;

procedure TFrameProceed.TreeViewDevicesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  AbsPoint: TPointF;
  Item: TTreeViewItem;
  I: Integer;

  function FindItemByPoint(AItem: TTreeViewItem): TTreeViewItem;
  var
    ChildIndex: Integer;
    ChildItem: TTreeViewItem;
  begin
    Result := nil;
    if AItem = nil then
      Exit;

    DbgProceedTree(1605, 'FindItemByPoint checks children of: ' + AItem.Text +
      '; Expanded=' + BoolToStr(AItem.IsExpanded, True) +
      '; Count=' + AItem.Count.ToString);
    for ChildIndex := 0 to AItem.Count - 1 do
    begin
      ChildItem := FindItemByPoint(TTreeViewItem(AItem.Items[ChildIndex]));
      if ChildItem <> nil then
        Exit(ChildItem);
    end;

    if AItem.AbsoluteRect.Contains(AbsPoint) then
    begin
      DbgProceedTree(1604, 'FindItemByPoint HIT self: ' + AItem.Text);
      Result := AItem;
    end;
  end;

begin
  DbgProceedTree(1602, Format('TreeViewDevicesMouseDown ENTER; Button=%d; X=%.0f; Y=%.0f'#13#10'%s'#13#10'%s',
    [Ord(Button), X, Y, GetSelectedTreeDebugText, GetProcessingDevicesDebugText]));
  if (Button <> TMouseButton.mbRight) or (TreeViewDevices = nil) then
    Exit;

  AbsPoint := TreeViewDevices.LocalToAbsolute(PointF(X, Y));
  for I := 0 to TreeViewDevices.Count - 1 do
  begin
    Item := FindItemByPoint(TreeViewDevices.ItemByIndex(I));
    if Item <> nil then
    begin
      DbgProceedTree(1603, 'TreeViewDevicesMouseDown selects item: ' + Item.Text +
        '; Count=' + Item.Count.ToString +
        '; Expanded=' + BoolToStr(Item.IsExpanded, True) + #13#10 +
        GetProcessingDevicesDebugText);
      TreeViewDevices.Selected := Item;
      Exit;
    end;
  end;
end;



function TFrameProceed.GetSelectedResultDevice: TDevice;
begin
  Result := nil;
  if (GridResults = nil) or (GridResults.Row < 0) or
     (GridResults.Row >= Length(FCurrentResultRows)) then
    Exit;

  Result := FCurrentResultRows[GridResults.Row].Device;
end;

function TFrameProceed.CanDeleteSelectedDataPoint(
  const AOwner: TObject): Boolean;
var
  Item: TTreeViewItem;
  Device: TDevice;
begin
  // AOwner controls confirmation reuse during deletion, but does not affect
  // whether the selected point is a valid deletion target.
  Result := False;
  if (GridDataPoints = nil) or not GridDataPoints.Visible or
     (GridDataPoints.Row < 0) or
     (GridDataPoints.Row >= Length(FCurrentSpillages)) or
     (FCurrentSpillages[GridDataPoints.Row] = nil) then
    Exit;

  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  Device := nil;
  if Item.TagObject is TSessionSpillage then
    Device := ResolveSelectedDevice
  else if Item.TagObject is TDevice then
    Device := TDevice(Item.TagObject)
  else
    Exit;

  Result := Device <> nil;
end;

function TFrameProceed.GetDeleteButtonHint: string;
var
  Item: TTreeViewItem;
  HasSelectedDataPoint: Boolean;
  ResultDevice: TDevice;
begin
  Result := 'Выберите объект в дереве';
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  HasSelectedDataPoint :=
    (GridDataPoints <> nil) and GridDataPoints.Visible and
    (GridDataPoints.Row >= 0) and
    (GridDataPoints.Row < Length(FCurrentSpillages)) and
    (FCurrentSpillages[GridDataPoints.Row] <> nil);

  if SameText(Item.Text, '...') or SameText(Item.Text, 'прочее') or
     (Item.TagObject is TWorkTable) then
  begin
    ResultDevice := GetSelectedResultDevice;
    if ResultDevice <> nil then
      Result := 'Удалить выбранный в таблице результатов прибор из списка обработки'
    else
      Result := 'Выберите прибор в таблице результатов для удаления из списка обработки';
    Exit;
  end;

  if Item.TagObject is TDevice then
  begin
    if HasSelectedDataPoint and CanDeleteSelectedDataPoint(Item.TagObject) then
      Result := 'Удалить выбранное измерение из таблицы выбранного прибора'
    else
      Result := 'Удалить выбранный в дереве прибор из списка обработки';
    Exit;
  end;

  if Item.TagObject is TSessionSpillage then
  begin
    if HasSelectedDataPoint and CanDeleteSelectedDataPoint(Item.TagObject) then
      Result := 'Удалить выбранное измерение из таблицы выбранной сессии'
    else
      Result := 'Удалить выбранную в дереве сессию и связанные с ней измерения';
    Exit;
  end;

  Result := 'Для выбранного объекта действие удаления недоступно';
end;

function TFrameProceed.DeleteSelectedDataPointWithRules(const AOwner: TObject): Boolean;
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  Point, NextPoint: TPointSpillage;
  NextRow, I: Integer;
begin
  Result := False;
  if (not GridDataPoints.Visible) or (GridDataPoints.Row < 0) or
     (GridDataPoints.Row >= Length(FCurrentSpillages)) then
    Exit;

  Item := nil;
  if TreeViewDevices <> nil then
    Item := TreeViewDevices.Selected;

  Session := nil;
  Device := nil;
  if (Item <> nil) and (Item.TagObject is TSessionSpillage) then
  begin
    Session := TSessionSpillage(Item.TagObject);
    Device := ResolveSelectedDevice;
  end
  else if (Item <> nil) and (Item.TagObject is TDevice) then
    Device := TDevice(Item.TagObject)
  else
    Exit;

  Point := FCurrentSpillages[GridDataPoints.Row];
  if (Device = nil) or (Point = nil) then
    Exit;

  if (not FSkipPointDeleteConfirm) or (FPointDeleteOwner <> AOwner) then
    if MessageDlg('Удалить выбранное измерение?', TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
      Exit;

  NextPoint := nil;
  if GridDataPoints.Row + 1 < Length(FCurrentSpillages) then
    NextPoint := FCurrentSpillages[GridDataPoints.Row + 1];

  Point.State := osDeleted;
  if (Session <> nil) and (Device.Spillages <> nil) and (Point.ID > 0) then
    for I := 0 to Device.Spillages.Count - 1 do
      if (Device.Spillages[I] <> nil) and (Device.Spillages[I].ID = Point.ID) then
      begin
        Device.Spillages[I].State := osDeleted;
        Break;
      end;
  if Device.State = osClean then
    Device.State := osModified;
  if (Session <> nil) then
    Session.State := osModified;

  if Session <> nil then
    RefreshMeasurementsAfterSessionAction(nil, Session)
  else
    RefreshMeasurementsAfterSessionAction(Device, nil);

  if NextPoint <> nil then
  begin
    NextRow := -1;
    for I := 0 to High(FCurrentSpillages) do
      if FCurrentSpillages[I] = NextPoint then
      begin
        NextRow := I;
        Break;
      end;

    if NextRow >= 0 then
      GridDataPoints.Row := NextRow;
  end;

  FSkipPointDeleteConfirm := True;
  FPointDeleteOwner := AOwner;
  Result := True;
end;
procedure TFrameProceed.ButtonSessionCancelClick(Sender: TObject);
begin
  DbgProceedTree(1812, 'ButtonSessionCancelClick'#13#10 + GetProcessingDevicesDebugText);
  CancelProcessingChanges;
end;
procedure TFrameProceed.ButtonSessionClearPointsClick(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
  Session, NextSession: TSessionSpillage;
  P: TPointSpillage;
  Ch: TChannel;
  WT: TWorkTable;
  DeviceUUIDs: TStringList;
  I, NextIdx: Integer;
begin
  ResetPointDeleteConfirm;

  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;

  if SameText(Item.Text, '...') then
  begin
    if FProcessingDevices <> nil then
      FProcessingDevices.Clear;
    RefreshResultsAfterDevicesAction;
    Exit;
  end;

  if Item.TagObject is TWorkTable then
  begin
    WT := TWorkTable(Item.TagObject);
    if (WT = nil) or (WT.DeviceChannels = nil) then
      Exit;

    if MessageDlg('Очистить все результаты приборов данного рабочего стола?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
      Exit;

    DeviceUUIDs := TStringList.Create;
    try
      DeviceUUIDs.Sorted := False;
      DeviceUUIDs.Duplicates := TDuplicates.dupIgnore;

      for Ch in WT.DeviceChannels do
        if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
        begin
          Device := Ch.FlowMeter.Device;
          if Trim(Device.UUID) <> '' then
          begin
            if DeviceUUIDs.IndexOf(Device.UUID) >= 0 then
              Continue;
            DeviceUUIDs.Add(Device.UUID);
          end;

          if Device.Sessions <> nil then
            for Session in Device.Sessions do
              if Session <> nil then
              begin
                Session.Active := False;
                Session.State := osDeleted;
              end;

          if Device.Spillages <> nil then
            for P in Device.Spillages do
              if P <> nil then
                P.State := osDeleted;

        end;
    finally
      DeviceUUIDs.Free;
    end;

    RefreshResultsAfterDevicesAction;
    Exit;
  end;

  if Item.TagObject is TSessionSpillage then
  begin
    if MessageDlg('Очистить все результаты данной сессии измерений?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
      Exit;

    ActionSessionDeleteExecute(ActionSessionDelete);
    Exit;
  end;

  if not (Item.TagObject is TDevice) then
    Exit;

  Device := TDevice(Item.TagObject);
  if MessageDlg('Очистить все результаты для данного прибора?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then
    Exit;

  if Device = nil then
    Exit;

  if Device.Sessions <> nil then
    for Session in Device.Sessions do
      if Session <> nil then
      begin
        Session.Active := False;
        Session.State := osDeleted;
      end;

  if Device.Spillages <> nil then
    for P in Device.Spillages do
      if P <> nil then
        P.State := osDeleted;

  NextSession := nil;
  NextIdx := -1;
  if Device.Sessions <> nil then
  begin
    for I := 0 to Device.Sessions.Count - 1 do
      if (Device.Sessions[I] <> nil) and (Device.Sessions[I].State <> osDeleted) then
      begin
        NextIdx := I;
        Break;
      end;

    if NextIdx >= 0 then
      NextSession := Device.Sessions[NextIdx];
  end;

  if NextSession <> nil then
  begin
    NextSession.Active := True;
    if NextSession.Status = 0 then
      NextSession.Status := 1;
    NextSession.State := osModified;
  end;

  RefreshMeasurementsAfterSessionAction(Device, NextSession);
end;
procedure TFrameProceed.ButtonSessionDeleteDataPointClick(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;

  if SameText(Item.Text, '...') or (Item.TagObject is TWorkTable) or SameText(Item.Text, 'прочее') then
  begin
    ResetPointDeleteConfirm;
    Device := GetSelectedResultDevice;
    if Device <> nil then
    begin
      MarkProcessingDeviceRemoved(Device);
    end;
    Exit;
  end;

  if Item.TagObject is TDevice then
  begin
    if DeleteSelectedDataPointWithRules(Item.TagObject) then
      Exit;

    ResetPointDeleteConfirm;
    MarkProcessingDeviceRemoved(TDevice(Item.TagObject));
    Exit;
  end;

  if Item.TagObject is TSessionSpillage then
  begin
    if DeleteSelectedDataPointWithRules(Item.TagObject) then
      Exit;

    ResetPointDeleteConfirm;
    if MessageDlg('Удалить выбранную сессию?', TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
      ActionSessionDeleteExecute(ActionSessionDelete);
  end;
end;


procedure TFrameProceed.GridResultsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  Row: TResultGridRow;
  PointIdx: Integer;
begin
  if (ARow < 0) or (ARow >= Length(FCurrentResultRows)) then
    Exit;
  if (ACol < 0) or (ACol >= GridResults.ColumnCount) or
     (not GridResults.Columns[ACol].Visible) then
    Exit;

  Row := FCurrentResultRows[ARow];

  if GridResults.Columns[ACol] = StringColumnResultName then
    Value := Row.Name
  else if GridResults.Columns[ACol] = StringColumnResultType then
    Value := Row.DeviceType
  else if GridResults.Columns[ACol] = StringColumnResultSerial then
    Value := Row.Serial
  else if GridResults.Columns[ACol] = StringColumnPointNum1 then
  begin
    if Length(Row.PointValues) > 0 then Value := Row.PointValues[0] else Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnPointNum2 then
  begin
    if Length(Row.PointValues) > 1 then Value := Row.PointValues[1] else Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnPointNum3 then
  begin
    if Length(Row.PointValues) > 2 then Value := Row.PointValues[2] else Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnPointNum4 then
  begin
    if Length(Row.PointValues) > 3 then Value := Row.PointValues[3] else Value := '';
  end
  else if SameText(GridResults.Columns[ACol].TagString, 'ProcessingDynamicPoint') then
  begin
    PointIdx := GridResults.Columns[ACol].Tag;
    if (PointIdx >= 0) and (PointIdx < Length(Row.PointValues)) then
      Value := Row.PointValues[PointIdx]
    else
      Value := '';
  end
  else if GridResults.Columns[ACol] = StringColumnResult then
    Value := Row.ResultText
  else if GridResults.Columns[ACol] = StringColumnResultComment then
    Value := Row.ResultComment;
end;


procedure TFrameProceed.GridResultsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  GridRow: TResultGridRow;
  Color: TAlphaColor;
  PointIdx: Integer;
  SavedState: TCanvasSaveState;
begin
  if (Row < 0) or (Row >= Length(FCurrentResultRows)) then
    Exit;
  if (Column = nil) or (not Column.Visible) then
    Exit;

  GridRow := FCurrentResultRows[Row];
  Color := TAlphaColors.Null;

  if Column = StringColumnResult then
    Color := GetStatusColor(GridRow.ResultStatus)
  else
  begin
    PointIdx := -1;
    if (Column = StringColumnPointNum1) and StringColumnPointNum1.Visible then PointIdx := 0;
    if (Column = StringColumnPointNum2) and StringColumnPointNum2.Visible then PointIdx := 1;
    if (Column = StringColumnPointNum3) and StringColumnPointNum3.Visible then PointIdx := 2;
    if (Column = StringColumnPointNum4) and StringColumnPointNum4.Visible then PointIdx := 3;
    if (PointIdx < 0) and SameText(Column.TagString, 'ProcessingDynamicPoint') then
      PointIdx := Column.Tag;

    if (PointIdx >= 0) and (PointIdx < Length(GridRow.PointColors)) then
      Color := GridRow.PointColors[PointIdx];
  end;

  SavedState := Canvas.SaveState;
  try
    if Color <> TAlphaColors.Null then
    begin
      Canvas.Fill.Kind := TBrushKind.Solid;
      Canvas.Fill.Color := Color;
      Canvas.FillRect(Bounds, 0, 0, [], 1);
      Column.DefaultDrawCell(Canvas, Bounds, Row, Value, State);
    end;
  finally
    Canvas.RestoreState(SavedState);
  end;
end;
procedure TFrameProceed.GridResultsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  Col, Row: Integer;
begin
  if Button = TMouseButton.mbLeft then
    Exit;
  if Button <> TMouseButton.mbRight then
    Exit;

  if GridResults.CellByPoint(X, Y, Col, Row) then
  begin
    GridResults.Row := Row;
    GridResults.Col := Col; // если нужно выбирать и колонку тоже
    GridResults.SetFocus;
  end;
end;

procedure TFrameProceed.GridResultsMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
var Col, Row, PointIndex: Integer; Device: TDevice;
  DevicePoint: TDevicePoint; Spillage: TPointSpillage; HintText: string;
begin
  if not GridResults.CellByPoint(X, Y, Col, Row) or
     (Row < 0) or (Row >= Length(FCurrentResultRows)) then
  begin
    FLastResultsHintRow := -1;
    FLastResultsHintCol := -1;
    GridResults.ShowHint := False;
    Exit;
  end;
  if (Row = FLastResultsHintRow) and (Col = FLastResultsHintCol) then
    Exit;

  // При смене строки или ячейки переоткрываем Hint с текстом нового результата.
  FLastResultsHintRow := Row;
  FLastResultsHintCol := Col;
  Application.CancelHint;
  GridResults.ShowHint := False;
  GridResults.Hint := '';
  HintText := '';
  Device := FCurrentResultRows[Row].Device;
  if GridResults.Columns[Col] = StringColumnResult then
    HintText := GetDeviceResultHint(Device)
  else
  begin
    PointIndex := -1;
    if GridResults.Columns[Col] = StringColumnPointNum1 then PointIndex := 0
    else if GridResults.Columns[Col] = StringColumnPointNum2 then PointIndex := 1
    else if GridResults.Columns[Col] = StringColumnPointNum3 then PointIndex := 2
    else if GridResults.Columns[Col] = StringColumnPointNum4 then PointIndex := 3
    else if SameText(GridResults.Columns[Col].TagString, 'ProcessingDynamicPoint') then
      PointIndex := GridResults.Columns[Col].Tag;
    if (PointIndex >= 0) and (Device <> nil) and
       (PointIndex < Length(FResultPointColumns)) then
    begin
      DevicePoint := FindResultPointForColumn(Device, FResultPointColumns[PointIndex]);
      Spillage := FindResultSpillageForColumn(Device, FResultPointColumns[PointIndex]);
      HintText := GetSpillageResultHint(Device, Spillage);
    end;
  end;
  GridResults.Hint := HintText;
  GridResults.ShowHint := HintText <> '';
end;
procedure TFrameProceed.GridResultsSelChanged(Sender: TObject);
var
  SelectedDevice: TDevice;
  NeedInitSessionDevice: Boolean;
begin
  if (GridResults = nil) or (GridResults.Row < 0) or
     (GridResults.Row >= Length(FCurrentResultRows)) then
  begin
    UpdateCalibrCoefsFrame;
    Exit;
  end;

  SelectedDevice := FCurrentResultRows[GridResults.Row].Device;
  if SelectedDevice <> nil then
  begin
    NeedInitSessionDevice :=
      (FSessionDevice = nil) or
      (FSessionDevice.ValueVolume = nil) or
      (FSessionDevice.ValueMass = nil) or
      (FSessionDevice.ValueVolumeFlow = nil) or
      (FSessionDevice.ValueMassFlow = nil);

    if NeedInitSessionDevice then
    begin
      FreeAndNil(FSessionDevice);
      FSessionDevice := TFlowMeter.Create;
      FSessionDevice.InitAllValues;
    end;

    FSessionDevice.Device := SelectedDevice;
  end;

  UpdateCalibrCoefsFrame;
end;
procedure TFrameProceed.GridDataPointsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  P: TPointSpillage;
  Sess: TSessionSpillage;
  CurrentDevice: TDevice;
begin
  if (ARow < 0) or (ARow >= Length(FCurrentSpillages)) then
    Exit;
  P := FCurrentSpillages[ARow];
  if (P = nil) or (P.State = osDeleted) then
    Exit;

  CurrentDevice := nil;
  if FSessionDevice <> nil then
    CurrentDevice := FSessionDevice.Device;

  P.EtalonVolumeFlow := P.EtalonVolume/P.SpillTime;
  P.EtalonMassFlow := P.EtalonMass/P.SpillTime;

  P.DeviceMassFlow := P.DeviceMass/P.SpillTime;
  P.DeviceVolumeFlow := P.DeviceVolume/P.SpillTime;
  P.MeanFrequency := P.PulseCount/P.SpillTime;
  P.DeltaPressure :=  P.InputPressure - P.OutputPressure;

  if GridDataPoints.Columns[ACol] = StringColumnName then
  begin
    if (P <> nil) and (P.Name = '-') then
      LogMKS('DBG SP 7001', 'GridDataPointsGetValue NAME',
        Format('Row=%d | %s', [ARow, DumpSpillage(P)]));
    Value := P.Name;
  end
  else if GridDataPoints.Columns[ACol] = CheckColumnSpillageEnable then
    Value := P.Enabled
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageNum then
    Value := P.Num
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDateTime then
  begin
    if P.DateTime > 0 then
      Value := DateTimeToStr(P.DateTime)
    else
      Value := '-';
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageOperator then
  begin
    if (CurrentDevice <> nil) and (CurrentDevice.Sessions <> nil) then
      for Sess in CurrentDevice.Sessions do
        if Sess.ID = P.SessionID then
        begin
          Value := Sess.OperatorName;
          Break;
        end;
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageEtalonName then
  begin
    if (CurrentDevice <> nil) and (CurrentDevice.Sessions <> nil) then
      for Sess in CurrentDevice.Sessions do
        if Sess.ID = P.SessionID then
        begin
          Value := P.EtalonName;
          Break;
        end;
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageSpillTime then
    Value :=  FActiveWorkTable.ValueTime.GetStrNum(P.SpillTime)

  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQavgEtalon then
  begin
      if (FSessionEtalon <> nil) and (FActiveWorkTable <> nil) then
      begin
        if IsVolumeFlowUnit(FActiveWorkTable.FlowUnitName) then
          Value := FSessionEtalon.ValueVolumeFlow.GetStrNum(P.EtalonVolumeFlow)
        else
          Value := FSessionEtalon.ValueMassFlow.GetStrNum(P.EtalonMassFlow);
      end
      else
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
    begin
       Value := FActiveWorkTable.TableFlow.ValueFlow.GetStrNum(P.EtalonMassFlow)
    end
    else
      Value := FloatToStr(P.QavgEtalon);
    end

  else if GridDataPoints.Columns[ACol] = StringColumnSpillageEtalonVolume then
  begin
      if (FSessionEtalon <> nil) and (FActiveWorkTable <> nil) then
      begin
        if IsVolumeFlowUnit(FActiveWorkTable.FlowUnitName) then
          Value := FSessionEtalon.ValueVolume.GetStrNum(P.EtalonVolume)
        else
          Value := FSessionEtalon.ValueMass.GetStrNum(P.EtalonMass);
      end
      else
      if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      begin
        Value := FActiveWorkTable.TableFlow.ValueFlow.GetStrNum(P.EtalonVolume);
      end
      else
      Value := FloatToStr(P.EtalonVolume);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQEtalonStd then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueError.GetStrNum(P.QEtalonStd)
    else
      Value := FloatToStr(P.QEtalonStd);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQEtalonCV then
    Value := FloatToStr(P.QEtalonCV)

  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDeviceVolume then
  begin
    if (FSessionDevice <> nil) and (FActiveWorkTable <> nil) then
    begin
      if IsVolumeFlowUnit(FActiveWorkTable.FlowUnitName) then
        Value := FSessionDevice.ValueVolume.GetStrNum(P.DeviceVolume)
      else
        Value := FSessionDevice.ValueMass.GetStrNum(P.DeviceMass);
    end
    else
      Value := FloatToStr(P.DeviceVolume);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageVelocity then
    Value := FloatToStr(P.Velocity)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDeviceFlowRate then
  begin
    if (FSessionDevice <> nil) and (FActiveWorkTable <> nil) then
    begin
      if IsVolumeFlowUnit(FActiveWorkTable.FlowUnitName) then
        Value := FSessionDevice.ValueVolumeFlow.GetStrNum(P.DeviceVolumeFlow)
      else
        Value := FSessionDevice.ValueMassFlow.GetStrNum(P.DeviceMassFlow);
    end
    else
      Value := FloatToStr(P.DeviceVolumeFlow);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageError then
    Value := FormatResultErrorValue(P.Error)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageValid then
    Value := BuildSpillageStatusText(P)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageComment then
    Value := BuildSpillageCommentText(P)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQStd then
    Value := FloatToStr(P.QStd)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQCV then
    Value := FloatToStr(P.QCV)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageVolumeBefore then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
    begin
      if IsVolumeFlowUnit(FActiveWorkTable.FlowUnitName) then
        Value := FActiveWorkTable.TableFlow.ValueVolume.GetStrNum(P.VolumeBefore)
      else
        Value := FActiveWorkTable.TableFlow.ValueMass.GetStrNum(P.VolumeBefore);
    end
    else
      Value := FloatToStr(P.VolumeBefore);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageVolumeAfter then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
    begin
      if IsVolumeFlowUnit(FActiveWorkTable.FlowUnitName) then
        Value := FActiveWorkTable.TableFlow.ValueVolume.GetStrNum(P.VolumeAfter)
      else
        Value := FActiveWorkTable.TableFlow.ValueMass.GetStrNum(P.VolumeAfter);
    end
    else
      Value := FloatToStr(P.VolumeAfter);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillagePulseCount then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueImp.GetStrNum(P.PulseCount)
    else
      Value := P.PulseCount;
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageMeanFrequency then
    Value := FloatToStr(P.MeanFrequency)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAvgCurrent then
    Value := FloatToStr(P.AvgCurrent)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAvgVoltage then
    Value := FloatToStr(P.AvgVoltage)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageData1 then
    Value := P.Data1
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageData2 then
    Value := P.Data2
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageStartTemperature then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueTemperture.GetStrNum(P.StartTemperature)
    else
      Value := FloatToStr(P.StartTemperature);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageEndTemperature then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueTemperture.GetStrNum(P.EndTemperature)
    else
      Value := FloatToStr(P.EndTemperature);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAvgTemperature then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueTemperture.GetStrNum(P.AvgTemperature)
    else
      Value := FloatToStr(P.AvgTemperature);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageInputPressure then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValuePressure.GetStrNum(P.InputPressure)
    else
      Value := FloatToStr(P.InputPressure);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageOutputPressure then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValuePressure.GetStrNum(P.OutputPressure)
    else
      Value := FloatToStr(P.OutputPressure);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDeltaPressure then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValuePressure.GetStrNum(P.DeltaPressure)
    else
      Value := FloatToStr(P.DeltaPressure);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageDensity then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueDensity.GetStrNum(P.Density)
    else
      Value := FloatToStr(P.Density);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAmbientTemperature then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueTemperture.GetStrNum(P.AmbientTemperature)
    else
      Value := FloatToStr(P.AmbientTemperature);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageAtmosphericPressure then
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValuePressure.GetStrNum(P.AtmosphericPressure)
    else
      Value := FloatToStr(P.AtmosphericPressure);
  end
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageRelativeHumidity then
    Value := FloatToStr(P.RelativeHumidity)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageCoef then
    Value := FloatToStr(P.Coef)
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageFCDCoefficient then
    Value := P.FCDCoefficient
  else if GridDataPoints.Columns[ACol] = StringColumnSpillageArchivedData then
    Value := P.ArchivedData;
end;
procedure TFrameProceed.GridDataPointsCellClick(const Column: TColumn;
  const Row: Integer);
begin
  // The measurement grid is a viewer.  In particular, a click on its
  // TCheckColumn must select the row without changing the underlying point.
  UpdateActionHints;
end;
procedure TFrameProceed.GridDataPointsColumnMoved(Column: TColumn; FromIndex,
  ToIndex: Integer);
begin
  if not FApplyingGridColumnsLayout then
    SaveLayoutSettingsToWorkTable;
end;

procedure TFrameProceed.GridColumnLayoutMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if FApplyingGridColumnsLayout then
    Exit;

  { GridResults persists widths only after a confirmed header-divider drag. }
  if Sender = GridResults then
  begin
    if (FResultsGridLayoutState <> nil) and
       FResultsGridLayoutState.FinishPendingManualResize then
      SaveLayoutSettingsToWorkTable;
    Exit;
  end;

  if Sender = GridDataPoints then
    SaveLayoutSettingsToWorkTable;
end;

procedure TFrameProceed.GridDataPointsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  P: TPointSpillage;
  Color: TAlphaColor;
begin
  if ((Column <> StringColumnSpillageValid) and
      (Column <> StringColumnSpillageError)) or (Row < 0) or
     (Row >= Length(FCurrentSpillages)) then
    Exit;

  P := FCurrentSpillages[Row];
  if P = nil then
    Exit;

  if Column = StringColumnSpillageError then
    Color := GetSpillageErrorResultColor(P)
  else
    Color := GetSpillageValidationColor(P.Validation, P.ValidationReason);
  if Color = TAlphaColors.Null then
    Exit;

  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := Color;
  Canvas.FillRect(Bounds, 0, 0, [], 1);

  Column.DefaultDrawCell(Canvas, Bounds, Row, Value, State);
end;
procedure TFrameProceed.GridDataPointsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  ACol, ARow: Integer;
begin
  if Button <> TMouseButton.mbRight then
    Exit;

  if GridDataPoints.CellByPoint(X, Y, ACol, ARow) then
  begin
    GridDataPoints.Col := ACol;
    GridDataPoints.Row := ARow;
    GridDataPoints.SetFocus;
    if (ARow >= 0) and (ARow < Length(FCurrentSpillages)) then
    begin
      GridDataPoints.Hint := GetSpillageResultHint(ResolveSelectedDevice,
        FCurrentSpillages[ARow]);
      GridDataPoints.ShowHint := GridDataPoints.Hint <> '';
    end;
    UpdateActionHints;
  end;
end;

procedure TFrameProceed.GridDataPointsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
var Col, Row: Integer; Device: TDevice; HintText: string;
begin
  if not GridDataPoints.CellByPoint(X, Y, Col, Row) or
     (Row < 0) or (Row >= Length(FCurrentSpillages)) then
  begin
    FLastDataPointsHintRow := -1;
    FLastDataPointsHintCol := -1;
    GridDataPoints.ShowHint := False;
    Exit;
  end;
  if (Row = FLastDataPointsHintRow) and (Col = FLastDataPointsHintCol) then
    Exit;

  // При смене строки или ячейки переоткрываем Hint с текстом нового измерения.
  FLastDataPointsHintRow := Row;
  FLastDataPointsHintCol := Col;
  Application.CancelHint;
  GridDataPoints.ShowHint := False;
  GridDataPoints.Hint := '';
  HintText := '';
  if (GridDataPoints.Columns[Col] = StringColumnSpillageValid) or
     (GridDataPoints.Columns[Col] = StringColumnSpillageError) then
  begin
    Device := ResolveSelectedDevice;
    HintText := GetSpillageResultHint(Device, FCurrentSpillages[Row]);
  end;
  GridDataPoints.Hint := HintText;
  GridDataPoints.ShowHint := HintText <> '';
end;
procedure TFrameProceed.GridDataPointsHeaderClick(Column: TColumn);
begin
  if Column <> StringColumnSpillageDateTime then
    Exit;

  FGridDataPointsSortColumn := StringColumnSpillageDateTime.Name;
  if FGridDataPointsSortDirection = gsdAscending then
    FGridDataPointsSortDirection := gsdDescending
  else
    FGridDataPointsSortDirection := gsdAscending;

  UpdateGridDataPoints;
end;

procedure TFrameProceed.UpdateGridDataPointsHeaders(QuantityDimName: string; FlowDimName: string);
var
  WorkTable: TWorkTable;
  IsVolumeUnits: Boolean;
  TemperatureDimName: string;
  PressureDimName: string;
begin
  WorkTable := FActiveWorkTable;
  if (WorkTable = nil) or (WorkTable.TableFlow = nil) then
    Exit;

  IsVolumeUnits := IsVolumeFlowUnit(FlowDimName);

  if IsVolumeUnits then
  begin

    StringColumnSpillageQavgEtalon.Header:= 'Расход, ' + FlowDimName;
    StringColumnSpillageDeviceFlowRate.Header:= 'Расход прибора, ' + FlowDimName;

    StringColumnSpillageEtalonVolume.Header := 'Объем эталона, ' + QuantityDimName;
    StringColumnSpillageDeviceVolume.Header := 'Объем прибора, ' + QuantityDimName;
    StringColumnSpillageVolumeBefore.Header := 'Объем до, ' + QuantityDimName;
    StringColumnSpillageVolumeAfter.Header := 'Объем после, ' + QuantityDimName;

  end
  else
  begin

    StringColumnSpillageQavgEtalon.Header:= 'Расход, ' + FlowDimName;
    StringColumnSpillageDeviceFlowRate.Header:='Расход прибора, ' + FlowDimName;

    StringColumnSpillageEtalonVolume.Header := 'Масса эталона, ' + QuantityDimName;
    StringColumnSpillageDeviceVolume.Header := 'Масса прибора, ' + QuantityDimName;
    StringColumnSpillageVolumeBefore.Header := 'Масса до, ' + QuantityDimName;
    StringColumnSpillageVolumeAfter.Header := 'Масса после, ' + QuantityDimName;
  end;

  StringColumnSpillageQavgEtalon.Header := 'Расход, ' + FlowDimName;

  StringColumnSpillageQStd.Header := 'СКО прибора, ' + FlowDimName;

  if WorkTable.TableFlow.ValueImp <> nil then
    StringColumnSpillagePulseCount.Header := 'Импульсы, ' + WorkTable.TableFlow.ValueImp.GetDimName
  else
    StringColumnSpillagePulseCount.Header := 'Импульсы';

  if WorkTable.TableFlow.ValueDensity <> nil then
    StringColumnSpillageDensity.Header := 'Плотность, ' + WorkTable.TableFlow.ValueDensity.GetDimName
  else
    StringColumnSpillageDensity.Header := 'Плотность';

  if WorkTable.TableFlow.ValueTemperture <> nil then
    TemperatureDimName := WorkTable.TableFlow.ValueTemperture.GetDimName
  else
    TemperatureDimName := '';
  StringColumnSpillageStartTemperature.Header := 'T нач, ' + TemperatureDimName;
  StringColumnSpillageEndTemperature.Header := 'T кон, ' + TemperatureDimName;
  StringColumnSpillageAvgTemperature.Header := 'T сред, ' + TemperatureDimName;
  StringColumnSpillageAmbientTemperature.Header := 'T возд, ' + TemperatureDimName;

  if WorkTable.TableFlow.ValuePressure <> nil then
    PressureDimName := WorkTable.TableFlow.ValuePressure.GetDimName
  else
    PressureDimName := '';
  StringColumnSpillageInputPressure.Header := 'Давление Вх, ' + PressureDimName;
  StringColumnSpillageOutputPressure.Header := 'Давление Вых, ' + PressureDimName;
  StringColumnSpillageDeltaPressure.Header := 'Давление разница, ' + PressureDimName;
  StringColumnSpillageAtmosphericPressure.Header := 'Атм Давл, ' + PressureDimName;
end;
procedure TFrameProceed.SetSessionDim(UnitName: string; QuantityUnitName: string);
var
  IsVolumeUnits: Boolean;
begin
  if (FSessionDevice = nil) and (FSessionEtalon = nil) then
    Exit;

  UnitName := Trim(UnitName);
  QuantityUnitName := Trim(QuantityUnitName);

  if UnitName = '' then
    Exit;

  if QuantityUnitName = '' then
    QuantityUnitName := ResolveQuantityUnitByFlowUnit(UnitName);

  IsVolumeUnits := IsVolumeFlowUnit(UnitName);

  if IsVolumeUnits then
  begin
    if FSessionDevice <> nil then
    begin
      FSessionDevice.ValueQuantity := FSessionDevice.ValueVolume;
      FSessionDevice.ValueFlow := FSessionDevice.ValueVolumeFlow;
      if FSessionDevice.ValueVolume <> nil then
        FSessionDevice.ValueVolume.SetDim(QuantityUnitName);
      if FSessionDevice.ValueVolumeFlow <> nil then
        FSessionDevice.ValueVolumeFlow.SetDim(UnitName);
    end;
    if FSessionEtalon <> nil then
    begin
      FSessionEtalon.ValueQuantity := FSessionEtalon.ValueVolume;
      FSessionEtalon.ValueFlow := FSessionEtalon.ValueVolumeFlow;
      if FSessionEtalon.ValueVolume <> nil then
        FSessionEtalon.ValueVolume.SetDim(QuantityUnitName);
      if FSessionEtalon.ValueVolumeFlow <> nil then
        FSessionEtalon.ValueVolumeFlow.SetDim(UnitName);
    end;
  end
  else
  begin
    if FSessionDevice <> nil then
    begin
      FSessionDevice.ValueQuantity := FSessionDevice.ValueMass;
      FSessionDevice.ValueFlow := FSessionDevice.ValueMassFlow;
      if FSessionDevice.ValueMass <> nil then
        FSessionDevice.ValueMass.SetDim(QuantityUnitName);
      if FSessionDevice.ValueMassFlow <> nil then
        FSessionDevice.ValueMassFlow.SetDim(UnitName);
    end;
    if FSessionEtalon <> nil then
    begin
      FSessionEtalon.ValueQuantity := FSessionEtalon.ValueMass;
      FSessionEtalon.ValueFlow := FSessionEtalon.ValueMassFlow;
      if FSessionEtalon.ValueMass <> nil then
        FSessionEtalon.ValueMass.SetDim(QuantityUnitName);
      if FSessionEtalon.ValueMassFlow <> nil then
        FSessionEtalon.ValueMassFlow.SetDim(UnitName);
    end;
  end;
end;
procedure TFrameProceed.UpdateCalibrCoefsFrame;
var
  Spillages: TObjectList<TPointSpillage>;
begin
  if FFrameCalibrCoefs = nil then
    Exit;

  Spillages := BuildCurrentSpillagesList;
  try
    FFrameCalibrCoefs.Init(FSessionDevice, cctMeterValueCoef, Spillages);
  finally
    Spillages.Free;
  end;
end;
procedure TFrameProceed.ResetPointDeleteConfirm;
begin
  FSkipPointDeleteConfirm := False;
  FPointDeleteOwner := nil;
end;
procedure TFrameProceed.InitCalibrCoefsFrame;
var
  Spillages: TObjectList<TPointSpillage>;
begin
  if (TabItemCalibrCoefs = nil) or (FFrameCalibrCoefs <> nil) then
    Exit;

  FFrameCalibrCoefs := TFrameCalibrCoefs.Create(Self);
  FFrameCalibrCoefs.Parent := TabItemCalibrCoefs;
  FFrameCalibrCoefs.Align := TAlignLayout.Client;
  FFrameCalibrCoefs.SetGridReadOnly;
  Spillages := BuildCurrentSpillagesList;
  try
    FFrameCalibrCoefs.Init(FSessionDevice, cctReference, Spillages);
  finally
    Spillages.Free;
  end;
end;

end.
