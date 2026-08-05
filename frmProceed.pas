unit frmProceed;

interface

uses
  FMX.ActnList,
  FMX.Controls,
  FMX.Controls.Presentation,
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
  uMeasurementRun;

type
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
    MenuItemGridResultsDelete: TMenuItem;
    MenuItemGridResultsClear: TMenuItem;
    MenuItemGridResultsClose: TMenuItem;
    MenuItemGridResultsColumns: TMenuItem;
    ActionSessionDeviceRemove: TAction;
    ActionSessionDeviceAdd: TAction;
    ActionDeleteWorkTable: TAction;
    ActionDeleteSelectedWorkTables: TAction;
    btnCancel: TCornerButton;
    ButtonExportExcel: TButton;
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
    function FindResultPointForColumn(ADevice: TDevice; const AColumn: TProceedResultPointColumn): TDevicePoint;
    // Проверяет принадлежность сохранённой проливки merged-колонке Summary по расходу и признакам эталона; не зависит от TMeasurementRun.Points.
    function IsProcessingSpillageInMergedColumn(ASpillage: TPointSpillage; const AColumn: TProceedResultPointColumn): Boolean;
    // Возвращает проливку прибора для Summary-колонки обработки; в merged-режиме ищет ближайшую сохранённую проливку по расходу.
    function FindResultSpillageForColumn(ADevice: TDevice; const AColumn: TProceedResultPointColumn): TPointSpillage;
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
    procedure UpdateGridDataPointsHeaders(QuantityDimName: string; FlowDimName: string);
    procedure SetSessionDim(UnitName: string; QuantityUnitName: string);
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
  inherited;
end;

procedure TFrameProceed.Initialize;
var
  UnitName: string;
begin
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

  if GridResults <> nil then
  begin
    GridResults.OnDrawColumnCell := GridResultsDrawColumnCell;
    // Подключаем существующий обработчик Hint для ячеек таблицы результатов.
    GridResults.OnMouseMove := GridResultsMouseMove;
    GridResults.OnMouseUp := GridColumnLayoutMouseUp;
  end;
  if GridDataPoints <> nil then
  begin
    GridDataPoints.OnDrawColumnCell := GridDataPointsDrawColumnCell;
    // Подключаем существующий обработчик Hint для ячеек таблицы измерений.
    GridDataPoints.OnMouseMove := GridDataPointsMouseMove;
    GridDataPoints.OnMouseUp := GridColumnLayoutMouseUp;
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

  LoadProcessingDevices;
  LoadManualProcessingDevices;
  SyncProcessingDevicesWithNewPoints;
  InitCalibrCoefsFrame;
  RefreshResultsTab;
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

      Column.Visible := SortedColumns[I].Visible;
      if SortedColumns[I].Width > 0 then
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
      Column.Index := TargetIndex;
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

function TFrameProceed.FormatResultErrorValue(const AValue: Double): string;
begin
  Result := FormatFloat('0.###', AValue);
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
      if Spillage = nil then
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
  DevicePoint: TDevicePoint;
  Spillage: TPointSpillage;
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
const
  SUMMARY_MERGE_FLOW_REL_TOLERANCE = 0.005;
  SUMMARY_MERGE_FLOW_ABS_TOLERANCE = 0.000001;
var
  MaxFlow: Double;
begin
  Result := False;
  if (ASpillage = nil) or (ASpillage.State = osDeleted) or (not ASpillage.Enabled) then
    Exit;
  if IsNan(ASpillage.QavgEtalon) or IsInfinite(ASpillage.QavgEtalon) or
     IsNan(AColumn.TargetFlow) or IsInfinite(AColumn.TargetFlow) then
    Exit;
  if (Trim(AColumn.EtalonUUID) <> '') and (Trim(ASpillage.EtalonUUID) <> '') and
     (not SameText(Trim(AColumn.EtalonUUID), Trim(ASpillage.EtalonUUID))) then
    Exit;
  MaxFlow := Max(Abs(ASpillage.QavgEtalon), Abs(AColumn.TargetFlow));
  Result := Abs(ASpillage.QavgEtalon - AColumn.TargetFlow) <=
    Max(SUMMARY_MERGE_FLOW_ABS_TOLERANCE, MaxFlow * SUMMARY_MERGE_FLOW_REL_TOLERANCE);
end;

function TFrameProceed.FindResultSpillageForColumn(ADevice: TDevice;
  const AColumn: TProceedResultPointColumn): TPointSpillage;
const
  SUMMARY_MERGE_FLOW_REL_TOLERANCE = 0.005;
  SUMMARY_MERGE_FLOW_ABS_TOLERANCE = 0.000001;
var
  Spillage, Candidate: TPointSpillage;
  ActiveSession: TSessionSpillage;
  DeviceUUID: string;
  BestDiff, Diff, MaxFlow, Tolerance: Double;

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
begin
  Result := nil;
  if (ADevice = nil) or (ADevice.Spillages = nil) then
    Exit;

  DeviceUUID := Trim(ADevice.UUID);
  ActiveSession := GetActiveVisibleSession(ADevice);
  if ActiveSession = nil then
    Exit;

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
      if IsProcessingSpillageInMergedColumn(Spillage, AColumn) then
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
    if IsBetterSpillage(Candidate, Result, Diff, BestDiff) then
    begin
      Result := Candidate;
      BestDiff := Diff;
    end;
  end;
end;

procedure TFrameProceed.BuildSummaryResultPointColumns(const ADevices: TList<TDevice>;
  const AMergePoints: Boolean);
var
  Cols: TList<TProceedResultPointColumn>;
  Col: TProceedResultPointColumn;
  WT: TWorkTable;
  Run: TMeasurementRun;
  Device: TDevice;
  Spillage: TPointSpillage;
  ActiveSession: TSessionSpillage;
  I, J, DevicesCount, SpillagesCount: Integer;
  Headers: string;
  RunPointsEmpty: Boolean;

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

begin
  SetLength(FResultPointColumns, 0);
  Cols := TList<TProceedResultPointColumn>.Create;
  try
    WT := ResolveManagerWorkTable(FWorkTableManager);
    Run := nil;
    if (WT <> nil) and (WT.MeasurementRun <> nil) then
      Run := TMeasurementRun(WT.MeasurementRun);
    RunPointsEmpty := (Run = nil) or (Run.Points = nil) or (Run.Points.Count = 0);
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
        for Spillage in Device.Spillages do
        begin
          if (Spillage = nil) or (Spillage.State = osDeleted) or (not Spillage.Enabled) or
             (Spillage.SessionID <> ActiveSession.ID) then
            Continue;
          Inc(SpillagesCount);
          Col := Default(TProceedResultPointColumn);
          Col.TargetFlow := Spillage.QavgEtalon;
          Col.EtalonUUID := Trim(Spillage.EtalonUUID);
          Col.SourcePointName := Trim(Spillage.Name);
          Col.SourcePointNum := Spillage.Num;
          if AMergePoints then
          begin
            J := -1;
            for I := 0 to Cols.Count - 1 do
              if IsProcessingSpillageInMergedColumn(Spillage, Cols[I]) then
              begin
                J := I;
                Break;
              end;
            if J >= 0 then
            begin
              Col := Cols[J];
              Col.TargetFlow := (Col.TargetFlow + Spillage.QavgEtalon) / 2;
              if (Trim(Col.EtalonUUID) = '') and (Trim(Spillage.EtalonUUID) <> '') then
                Col.EtalonUUID := Trim(Spillage.EtalonUUID);
              AppendHeaderName(Col.Header, SpillageHeader(Spillage, Format('Q%d', [J + 1])));
              Cols[J] := Col;
            end
            else
            begin
              Col.IsMerged := True;
              Col.DeviceUUID := '';
              Col.SourcePointUUID := '';
              Col.Header := SpillageHeader(Spillage, Format('Q%d', [Cols.Count + 1]));
              Cols.Add(Col);
            end;
          end
          else
          begin
            Col.IsMerged := False;
            Col.DeviceUUID := Trim(Device.UUID);
            Col.SourcePointUUID := Trim(Spillage.DeviceTypeUUID);
            Col.Header := Trim(Device.Name + ' ' + SpillageHeader(Spillage, Format('Q%d', [Cols.Count + 1])));
            Cols.Add(Col);
          end;
        end;
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
      Format('MergeEnabled=%s; Source=Spillages; DevicesCount=%d; SpillagesCount=%d; ColumnsCount=%d; ColumnHeaders=%s; MergedGroupsCount=%d; FallbackMeasurementRunUsed=False; MeasurementRunPointsEmpty=%s; SummaryColumnsSource=ProcessingSpillages',
        [BoolToStr(AMergePoints, True), DevicesCount, SpillagesCount, Cols.Count, Headers,
         Cols.Count, BoolToStr(RunPointsEmpty, True)]));
  finally
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
  PointColumnCount, StaticPointColumnCount, DynamicPointColumnCount, I: Integer;
  Col: TStringColumn;

  function FormatPointHeader(const APointName: string): string;
  begin
    Result := #948 + '(' + APointName + '), %';
  end;

  procedure ApplyPointColumn(AColumn: TStringColumn; const AIndex: Integer);
  begin
    if AColumn = nil then
      Exit;
    AColumn.Visible := AIndex < PointColumnCount;
    if AColumn.Visible then
      AColumn.Header := FormatPointHeader(FResultPointColumns[AIndex].Header);
    AColumn.HeaderSettings.TextSettings.WordWrap := False;
    AColumn.Stored := True;
  end;

  function IsDynamicPointColumn(AColumn: TColumn): Boolean;
  begin
    Result := (AColumn <> nil) and
      (SameText(AColumn.TagString, 'ProcessingDynamicPoint') or
       SameText(Copy(AColumn.Name, 1, Length('ProcessingPointColumn')), 'ProcessingPointColumn')) and
      (AColumn <> StringColumnResult) and (AColumn <> StringColumnResultComment);
  end;
begin
  PointColumnCount := Length(FResultPointColumns);
  StaticPointColumnCount := Min(PointColumnCount, 4);
  DynamicPointColumnCount := Max(PointColumnCount - 4, 0);

  for I := GridResults.ColumnCount - 1 downto 0 do
    if IsDynamicPointColumn(GridResults.Columns[I]) then
      GridResults.Columns[I].Free;

  ApplyPointColumn(StringColumnPointNum1, 0);
  ApplyPointColumn(StringColumnPointNum2, 1);
  ApplyPointColumn(StringColumnPointNum3, 2);
  ApplyPointColumn(StringColumnPointNum4, 3);

  for I := 4 to 4 + DynamicPointColumnCount - 1 do
  begin
    Col := TStringColumn.Create(GridResults);
    Col.Parent := GridResults;
    Col.Name := Format('ProcessingPointColumn%d', [I + 1]);
    Col.Tag := I;
    Col.TagString := 'ProcessingDynamicPoint';
    Col.Stored := False;
    Col.Width := 125;
    Col.HeaderSettings.TextSettings.Trimming := TTextTrimming.Character;
    Col.HeaderSettings.TextSettings.WordWrap := False;
    Col.HeaderSettings.TextSettings.HorzAlign := TTextAlign.Center;
    Col.Header := FormatPointHeader(FResultPointColumns[I].Header);
    Col.Index := StringColumnResult.Index;
  end;

  if StaticPointColumnCount > 0 then
    StringColumnResult.Index := GridResults.ColumnCount - 2
  else
    StringColumnResult.Index := StringColumnResultSerial.Index + 1;
  StringColumnResultComment.Index := StringColumnResult.Index + 1;

  NormalizeResultsPointColumnsVisibility;
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
  if (Spillage <> nil) and (Spillage.State <> osDeleted) and Spillage.Enabled then
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

            Spillage := FindResultSpillageForColumn(Device, FResultPointColumns[I]);
            P := FindResultPointForColumn(Device, FResultPointColumns[I]);
            if Spillage <> nil then
            begin
              Row.PointNames[I] := Spillage.Name;
              Inc(FoundPointsCount);
              HasAnyData := True;
              if (not Spillage.Valid) or
                 (Spillage.Validation = vsInvalid) then
                Inc(InvalidCount);
              Row.PointColors[I] := GetSpillageErrorResultColor(Spillage);
              { Point columns always show the measured error.  Only the
                aggregate Result column may display an em dash. }
              Row.PointValues[I] := FormatResultErrorValue(Spillage.Error);
            end
            else
            begin
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

  GridResults.RowCount := Length(FCurrentResultRows);
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
procedure SaveGridColumnWidths(AGrid: TGrid; out AWidths: TArray<Single>);
var
  I: Integer;
begin
  SetLength(AWidths, 0);
  if AGrid = nil then
    Exit;

  SetLength(AWidths, AGrid.ColumnCount);
  for I := 0 to AGrid.ColumnCount - 1 do
    AWidths[I] := AGrid.Columns[I].Width;
end;

procedure RestoreGridColumnWidths(AGrid: TGrid; const AWidths: TArray<Single>);
var
  I: Integer;
begin
  if AGrid = nil then
    Exit;

  for I := 0 to AGrid.ColumnCount - 1 do
    if (I <= High(AWidths)) and (AWidths[I] > 0) then
      AGrid.Columns[I].Width := AWidths[I];
end;

procedure TFrameProceed.UpdateGridDataPoints;
var
  ColumnWidths: TArray<Single>;
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

  SaveGridColumnWidths(GridDataPoints, ColumnWidths);
  GridDataPoints.BeginUpdate;
  try
    GridDataPoints.RowCount := 0;
    GridDataPoints.RowCount := Length(FCurrentSpillages);
    RestoreGridColumnWidths(GridDataPoints, ColumnWidths);
    GridDataPoints.Repaint;
  finally
    GridDataPoints.EndUpdate;
  end;
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
    GridResults.RowCount := 0;
  if GridDataPoints <> nil then
    GridDataPoints.RowCount := 0;
  if GridCoefs <> nil then
    GridCoefs.RowCount := 0;

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
  begin
    if (FActiveWorkTable <> nil) and (FActiveWorkTable.TableFlow <> nil) then
      Value := FActiveWorkTable.TableFlow.ValueError.GetStrNum(P.Error)
    else
      Value := FloatToStr(P.Error);
  end
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
  // После изменения мышью сохраняем ширину, порядок и видимость по Name столбца.
  if (not FApplyingGridColumnsLayout) and
     ((Sender = GridDataPoints) or (Sender = GridResults)) then
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

  IsVolumeUnits := IsVolumeFlowUnit(WorkTable.FlowUnitName);

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
