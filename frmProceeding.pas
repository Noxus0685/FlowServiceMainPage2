unit frmProceeding;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  fuDeviceSelect,
  frmCalibrCoefs,
  UnitDataManager,
  UnitDeviceClass,
  UnitFlowMeter,
  UnitClasses,
  UnitRepositories,
  UnitWorkTable,
  UnitBaseProcedures,
  System.Math,
  System.Generics.Collections,
  System.IniFiles,
  System.Actions,
  FMX.ActnList,
  FMX.Menus,
  System.Rtti, FMX.Grid.Style, FMX.Memo.Types, FMX.ListBox, FMX.Objects,
  FMXTee.Engine, FMXTee.Procs, FMXTee.Chart, FMX.TabControl, FMX.TreeView,
  FMX.Layouts, FMX.Memo, FMX.Grid, FMX.Controls.Presentation, FMX.ScrollBox;

type
  TResultGridRow = record
    Device: TDevice;
    Name: string;
    DeviceType: string;
    Serial: string;
    PointNames: TArray<string>;
    PointValues: TArray<string>;
    PointStatuses: TArray<Integer>;
    ResultText: string;
    ResultStatus: Integer;
  end;

  TFrameProceeding = class(TFrame)
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
    Chart1: TChart;
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
    btnOK: TCornerButton;
    CornerButton1: TCornerButton;
    CornerButtonEditDevice: TCornerButton;
    ActionSessionDelete: TAction;
    ActionSessionClose: TAction;
    ActionSessionPointDelete: TAction;
    ActionSessionPointsClear: TAction;
    ActionSessionActive: TAction;
    ActionSessionNew: TAction;
    ActionSessionSynchTable: TAction;
    PopupMenuTreeViewDevices: TPopupMenu;
    PopupMenuGridDataPoints: TPopupMenu;
    PopupMenuGridResults: TPopupMenu;
    ActionSessionDeviceRemove: TAction;
    ActionSessionDeviceAdd: TAction;

    private

    FFrameCalibrCoefs: TFrameCalibrCoefs;
    FWorkTableManager: TWorkTableManager;
    FProcessingDevices: TObjectList<TDevice>;
    FCurrentSession: TSessionSpillage;
    FCurrentResultRows: TArray<TResultGridRow>;
    FCurrentSpillages: TArray<TPointSpillage>;
    FActiveWorkTable: TWorkTable;
    FSessionDevice: TFlowMeter;
    FSessionEtalon: TFlowMeter;
    FSkipPointDeleteConfirm: Boolean;
    FPointDeleteOwner: TObject;
    function FindProcessingDeviceByUUID(const ADeviceUUID: string): TDevice;
    function HasDeviceInProcessing(ADevice: TDevice): Boolean;
    procedure AddProcessingDevice(ADevice: TDevice);
    procedure RemoveProcessingDevice(ADevice: TDevice);
    procedure SaveProcessingDevices;
    procedure LoadProcessingDevices;
    procedure AddProcessingDeviceFromSelection;
    procedure RefreshResultsAfterDevicesAction;
    function FindTreeItemByTagObject(ATagObject: TObject): TTreeViewItem;
    procedure SelectTreeItemByTagObject(ATagObject: TObject);
    procedure RefreshMeasurementsAfterSessionAction(ADevice: TDevice; ASession: TSessionSpillage);
    procedure UpdateSessionItems;
    procedure PopulateTreeViewDevices;
    function GetStatusColor(const AStatus: Integer): TAlphaColor;
    function BuildResultTextByStatus(const AStatus: Integer): string;
    procedure UpdateResultsPointColumns;
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
    procedure MenuTreeViewDevicesClearClick(Sender: TObject);
    procedure SyncProcessingDevicesFromTable(AWorkTable: TWorkTable; const AClearBeforeSync: Boolean);
    procedure SyncProcessingDevicesFromAllTables(const AClearBeforeSync: Boolean);
    procedure ActionSessionSynchTableExecute(Sender: TObject);
    procedure MenuTreeViewDevicesAddClick(Sender: TObject);
    procedure MenuTreeViewDevicesDeleteClick(Sender: TObject);
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
    function DeleteSelectedDataPointWithRules(const AOwner: TObject): Boolean;
    procedure ButtonSessionClearPointsClick(Sender: TObject);
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
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Initialize(AWorkTableManager: TWorkTableManager);
    procedure RefreshResultsTab;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

const
  CProcessingDevicesSection = 'ProcessingDevices';
  CProcessingDevicesCountKey = 'Count';
  CProcessingDevicesItemKeyPrefix = 'Item';
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

  Result := AWorkTableManager.WorkTables[0];
end;

destructor TFrameProceeding.Destroy;
begin
  FreeAndNil(FFrameCalibrCoefs);
  FreeAndNil(FSessionDevice);
  FreeAndNil(FSessionEtalon);
  FreeAndNil(FProcessingDevices);
  inherited;
end;

procedure TFrameProceeding.Initialize(AWorkTableManager: TWorkTableManager);
var
  UnitName: string;
begin
  FWorkTableManager := AWorkTableManager;
  FActiveWorkTable := ResolveManagerWorkTable(FWorkTableManager);

  if FProcessingDevices = nil then
    FProcessingDevices := TObjectList<TDevice>.Create(False);

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
  InitCalibrCoefsFrame;
  RefreshResultsTab;
end;

procedure TFrameProceeding.RefreshResultsTab;
begin
  PopulateTreeViewDevices;
  ShowAllDevicesResults;
end;

function TFrameProceeding.FindProcessingDeviceByUUID(const ADeviceUUID: string): TDevice;
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
function TFrameProceeding.HasDeviceInProcessing(ADevice: TDevice): Boolean;
begin
  Result := (ADevice <> nil) and (FindProcessingDeviceByUUID(ADevice.UUID) <> nil);
end;
procedure TFrameProceeding.AddProcessingDevice(ADevice: TDevice);
begin
  if (ADevice = nil) or (Trim(ADevice.UUID) = '') or (FProcessingDevices = nil) then
    Exit;

  if HasDeviceInProcessing(ADevice) then
    Exit;

  FProcessingDevices.Add(ADevice);
  SaveProcessingDevices;
end;
procedure TFrameProceeding.RemoveProcessingDevice(ADevice: TDevice);
var
  Existing: TDevice;
begin
  if (ADevice = nil) or (FProcessingDevices = nil) then
    Exit;

  Existing := FindProcessingDeviceByUUID(ADevice.UUID);
  if Existing = nil then
    Exit;

  FProcessingDevices.Remove(Existing);
  SaveProcessingDevices;
end;
procedure TFrameProceeding.SaveProcessingDevices;
var
  Ini: TIniFile;
  I, SaveIndex: Integer;
  Device: TDevice;
begin
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
      if (Device = nil) or (Trim(Device.UUID) = '') then
        Continue;

      Ini.WriteString(CProcessingDevicesSection,
        CProcessingDevicesItemKeyPrefix + IntToStr(SaveIndex), Trim(Device.UUID));
      Inc(SaveIndex);
    end;

    Ini.WriteInteger(CProcessingDevicesSection, CProcessingDevicesCountKey, SaveIndex);
  finally
    Ini.Free;
  end;
end;
procedure TFrameProceeding.AddProcessingDeviceFromSelection;
var
  Frm: TFormDeviceSelect;
  SelDevice: TDevice;
begin
  Frm := TFormDeviceSelect.Create(Self);
  try
    if Frm.ShowModal <> mrOk then
      Exit;

    SelDevice := Frm.GetSelectedDevice;
    if SelDevice = nil then
      Exit;

    AddProcessingDevice(SelDevice);
  finally
    Frm.Free;
  end;
end;
procedure TFrameProceeding.RefreshResultsAfterDevicesAction;
begin
  PopulateTreeViewDevices;
  ShowAllDevicesResults;
end;
function TFrameProceeding.FindTreeItemByTagObject(ATagObject: TObject): TTreeViewItem;
var
  I: Integer;
  Item: TTreeViewItem;
begin
  Result := nil;
  if (TreeViewDevices = nil) or (ATagObject = nil) then
    Exit;

  for I := 0 to TreeViewDevices.Count - 1 do
  begin
    Item := TreeViewDevices.ItemByIndex(I);
    if (Item <> nil) and (Item.TagObject = ATagObject) then
      Exit(Item);
  end;
end;
procedure TFrameProceeding.SelectTreeItemByTagObject(ATagObject: TObject);
var
  Item: TTreeViewItem;
begin
  Item := FindTreeItemByTagObject(ATagObject);
  if Item <> nil then
    TreeViewDevices.Selected := Item;
end;
procedure TFrameProceeding.RefreshMeasurementsAfterSessionAction(ADevice: TDevice;
  ASession: TSessionSpillage);
begin
  if ASession <> nil then
  begin
    SelectTreeItemByTagObject(ASession);
    ShowSessionSpillages(ASession)
  end
  else if ADevice <> nil then
  begin
    SelectTreeItemByTagObject(ADevice);
    ShowDeviceSpillages(ADevice)
  end;

  if (TreeViewDevices <> nil) and (TreeViewDevices.Selected <> nil) then
    TreeViewDevicesChange(TreeViewDevices)
  else
  begin
    UpdateSessionItems;

  end;


  end;

procedure TFrameProceeding.LoadProcessingDevices;
var
  Ini: TIniFile;
  I, Count: Integer;
  DeviceUUID: string;
  Device: TDevice;
  Repo: TDeviceRepository;
begin
  if FProcessingDevices = nil then
    Exit;

  FProcessingDevices.Clear;

  if (FWorkTableManager = nil) or (Trim(FWorkTableManager.IniFileName) = '') or
     (not FileExists(FWorkTableManager.IniFileName)) then
    Exit;

  Ini := TIniFile.Create(FWorkTableManager.IniFileName);
  try
    Count := Ini.ReadInteger(CProcessingDevicesSection, CProcessingDevicesCountKey, 0);
    for I := 0 to Count - 1 do
    begin
      DeviceUUID := Trim(Ini.ReadString(CProcessingDevicesSection,
        CProcessingDevicesItemKeyPrefix + IntToStr(I), ''));
      if DeviceUUID = '' then
        Continue;

      Device := nil;
      Repo := nil;
      if DataManager <> nil then
        Device := DataManager.FindDevice(DeviceUUID, Repo);

      if (Device <> nil) and (FindProcessingDeviceByUUID(Device.UUID) = nil) then
        FProcessingDevices.Add(Device);
    end;
  finally
    Ini.Free;
  end;
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

procedure TFrameProceeding.UpdateSessionItems;
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
      ShowDeviceSpillages(Device);
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
end;

procedure TFrameProceeding.PopulateTreeViewDevices;
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
  begin
    if (AParent = nil) or (ADevice = nil) then
      Exit;

    DeviceItem := TTreeViewItem.Create(TreeViewDevices);
    DeviceItem.Text := ADevice.Name;
    DeviceItem.TagObject := ADevice;
    AParent.AddObject(DeviceItem);

    if ADevice.Sessions <> nil then
      for Sess in ADevice.Sessions do
      begin
        if Sess = nil then
          Continue;

        SessionItem := TTreeViewItem.Create(TreeViewDevices);
        SessionItem.Text :=
          Format('Сессия #%d (%s)', [Sess.ID, DateToStr(Sess.DateTimeOpen)]);
        SessionItem.TagObject := Sess;
        DeviceItem.AddObject(SessionItem);
      end;
  end;
begin
  ProcessedOnTables := TStringList.Create;
  try
    ProcessedOnTables.Sorted := False;
    ProcessedOnTables.Duplicates := TDuplicates.dupIgnore;

    TreeViewDevices.BeginUpdate;
    try
      TreeViewDevices.Clear;

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

              AddDeviceNode(RootTable, Device);
            end;
          finally
            TableDeviceUUIDs.Free;
          end;
        end;

      RootOther := TTreeViewItem.Create(TreeViewDevices);
      RootOther.Text := 'прочее';
      TreeViewDevices.AddObject(RootOther);

      if FProcessingDevices <> nil then
        for Device in FProcessingDevices do
          if (Device <> nil) and (ProcessedOnTables.IndexOf(Device.UUID) < 0) then
            AddDeviceNode(RootOther, Device);

      if TreeViewDevices.Count > 0 then
        TreeViewDevices.Selected := TreeViewDevices.ItemByIndex(0);
    finally
      TreeViewDevices.EndUpdate;
    end;
  finally
    ProcessedOnTables.Free;
  end;
end;
function TFrameProceeding.GetStatusColor(const AStatus: Integer): TAlphaColor;
begin
  case AStatus of
    2: Result := TAlphaColors.Lightgray;
    3: Result := TAlphaColors.Lightcoral;
    4: Result := TAlphaColors.Lightyellow;
    5: Result := TAlphaColors.Lightgreen;
  else
    Result := TAlphaColors.Null;
  end;
end;
function TFrameProceeding.BuildResultTextByStatus(const AStatus: Integer): string;
begin
  case AStatus of
    1: Result := '-';
    2: Result := 'Нет данных';
    3: Result := 'Не Годен';
    4: Result := 'Нет данных';
    5: Result := 'Годен';
  else
    Result := '-';
  end;
end;
procedure TFrameProceeding.UpdateResultsPointColumns;
var
  MaxPoints, I: Integer;
  AllSameType: Boolean;
  FirstTypeName: string;
  HeaderFromPoints: TArray<string>;
begin
  MaxPoints := 0;
  for I := 0 to High(FCurrentResultRows) do
    MaxPoints := Max(MaxPoints, Length(FCurrentResultRows[I].PointValues));

  if MaxPoints > 4 then
    MaxPoints := 4;

  StringColumnPointNum1.Visible := MaxPoints >= 1;
  StringColumnPointNum2.Visible := MaxPoints >= 2;
  StringColumnPointNum3.Visible := MaxPoints >= 3;
  StringColumnPointNum4.Visible := MaxPoints >= 4;

  AllSameType := Length(FCurrentResultRows) > 0;
  SetLength(HeaderFromPoints, 0);
  FirstTypeName := '';

  if Length(FCurrentResultRows) > 0 then
  begin
    FirstTypeName := FCurrentResultRows[0].DeviceType;
    SetLength(HeaderFromPoints, Length(FCurrentResultRows[0].PointNames));
    for I := 0 to High(HeaderFromPoints) do
      HeaderFromPoints[I] := FCurrentResultRows[0].PointNames[I];
  end;

  for I := 1 to High(FCurrentResultRows) do
    if not SameText(FCurrentResultRows[I].DeviceType, FirstTypeName) then
    begin
      AllSameType := False;
      Break;
    end;

  if AllSameType and (Length(HeaderFromPoints) > 0) then
  begin
    if Length(HeaderFromPoints) > 0 then StringColumnPointNum1.Header := HeaderFromPoints[0];
    if Length(HeaderFromPoints) > 1 then StringColumnPointNum2.Header := HeaderFromPoints[1];
    if Length(HeaderFromPoints) > 2 then StringColumnPointNum3.Header := HeaderFromPoints[2];
    if Length(HeaderFromPoints) > 3 then StringColumnPointNum4.Header := HeaderFromPoints[3];
  end
  else
  begin
    StringColumnPointNum1.Header := 'Q1';
    StringColumnPointNum2.Header := 'Q2';
    StringColumnPointNum3.Header := 'Q3';
    StringColumnPointNum4.Header := 'Q4';
  end;
end;
procedure TFrameProceeding.ShowAllDevicesResults;
var
  Devices: TList<TDevice>;
  Device: TDevice;
begin
  Devices := TList<TDevice>.Create;
  try
    if FProcessingDevices <> nil then
      for Device in FProcessingDevices do
        if Device <> nil then
          Devices.Add(Device);

    ShowDevicesResults(Devices);
  finally
    Devices.Free;
  end;
  UpdateGridResults

end;
procedure TFrameProceeding.ShowDevicesResults(const ADevices: TList<TDevice>);
var
  Rows: TList<TResultGridRow>;
  P: TDevicePoint;
  Device: TDevice;
  Row: TResultGridRow;
  I: Integer;
begin
  Rows := TList<TResultGridRow>.Create;
  try
    if ADevices <> nil then
      for Device in ADevices do
      begin
        if Device = nil then
          Continue;

        Device.AnalyseResults;

        Row.Device := Device;
        Row.Name := Device.Name;
        Row.DeviceType := Device.DeviceTypeName;
        Row.Serial := Device.SerialNumber;

        if Device.Points <> nil then
        begin
          SetLength(Row.PointNames, Device.Points.Count);
          SetLength(Row.PointValues, Device.Points.Count);
          SetLength(Row.PointStatuses, Device.Points.Count);
          for I := 0 to Device.Points.Count - 1 do
          begin
            P := Device.Points[I];
            if P <> nil then
            begin
              Row.PointNames[I] := P.Name;
              Row.PointStatuses[I] := P.Status;
              if P.Status = 1 then
                Row.PointValues[I] := '-'
              else
                Row.PointValues[I] := FormatFloat('0.###', P.ResultError);
            end
            else
            begin
              Row.PointNames[I] := '';
              Row.PointStatuses[I] := 1;
              Row.PointValues[I] := '-';
            end;
          end;
        end
        else
        begin
          SetLength(Row.PointNames, 0);
          SetLength(Row.PointValues, 0);
          SetLength(Row.PointStatuses, 0);
        end;

        Row.ResultStatus := Device.Status;
        Row.ResultText := BuildResultTextByStatus(Device.Status);

        Rows.Add(Row);
      end;

    FCurrentResultRows := Rows.ToArray;
  finally
    Rows.Free;
  end;

  UpdateResultsPointColumns;
  UpdateGridResults

end;
procedure TFrameProceeding.ShowWorkTableResults(AWorkTable: TWorkTable);
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
procedure TFrameProceeding.ShowOtherDevicesResults;
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
        if (Device <> nil) and
           (DeviceUUIDsOnTables.IndexOf(Trim(Device.UUID)) < 0) then
          Devices.Add(Device);

    ShowDevicesResults(Devices);
  finally
    DeviceUUIDsOnTables.Free;
    Devices.Free;
  end;
end;
procedure TFrameProceeding.UpdateGridResults;
begin
  GridResults.BeginUpdate;

  GridResults.EndUpdate;

  GridResults.RowCount := Length(FCurrentResultRows);
  if Length(FCurrentResultRows) = 0 then
    GridResults.Row := -1
  else if (GridResults.Row < 0) or (GridResults.Row >= Length(FCurrentResultRows)) then
    GridResults.Row := 0;

  GridResults.Repaint;
  GridResultsSelChanged(GridResults);

  GridResults.Visible := True;
  GridDataPoints.Visible := False;

end;
procedure TFrameProceeding.UpdateGridDataPoints;
begin
//  UpdateGridDataPointsHeaders(FActiveWorkTable.TableFlow.ValueVolume.GetDimName, FActiveWorkTable.TableFlow.ValueVolumeFlow.GetDimName);
  GridDataPoints.BeginUpdate;
  GridDataPoints.RowCount := 0;
  GridDataPoints.RowCount := Length(FCurrentSpillages);
  GridDataPoints.Repaint;
  GridDataPoints.EndUpdate;
  GridResults.Visible := False;
  GridDataPoints.Visible := True;
end;
function TFrameProceeding.BuildCurrentSpillagesList: TObjectList<TPointSpillage>;
var
  Point: TPointSpillage;
begin
  Result := TObjectList<TPointSpillage>.Create(False);
  for Point in FCurrentSpillages do
    if Point <> nil then
      Result.Add(Point);
end;
procedure TFrameProceeding.ShowDeviceSpillages(ADevice: TDevice);
var
  Point: TPointSpillage;
  List: TList<TPointSpillage>;
begin
  SetLength(FCurrentSpillages, 0);
  if ADevice <> nil then
  begin
    List := TList<TPointSpillage>.Create;
    try
      if ADevice.Spillages <> nil then
        for Point in ADevice.Spillages do
          if (Point <> nil) and (Point.State <> osDeleted) then
            List.Add(Point);

      FCurrentSpillages := List.ToArray;
    finally
      List.Free;
    end;
  end;

    UpdateGridDataPoints;
end;
procedure TFrameProceeding.ShowSessionSpillages(ASession: TSessionSpillage);
var
  Device: TDevice;
  Point: TPointSpillage;
  List: TList<TPointSpillage>;
  I: Integer;
begin
  SetLength(FCurrentSpillages, 0);
  if ASession = nil then
  begin
    GridResults.Visible := False;
    GridDataPoints.Visible := True;
    GridDataPoints.RowCount := 0;
    GridDataPoints.Repaint;
    Exit;
  end;

  Device := ResolveSelectedDevice;
  if (Device = nil) then
  begin
    GridResults.Visible := False;
    GridDataPoints.Visible := True;
    GridDataPoints.RowCount := 0;
    GridDataPoints.Repaint;
    Exit;
  end;

  List := TList<TPointSpillage>.Create;
  try
    if Device.Spillages <> nil then
    begin
      for Point in Device.Spillages do
        if (Point <> nil) and (Point.SessionID = ASession.ID) and (Point.State <> osDeleted) then
          List.Add(Point);
    end
    else if ASession.Spillages <> nil then
    begin
      for I := 0 to ASession.Spillages.Count - 1 do
      begin
        Point := ASession.Spillages[I];
        if Point <> nil then
          List.Add(Point);
      end;
    end;

    FCurrentSpillages := List.ToArray;
  finally
    List.Free;
  end;

  UpdateGridDataPoints;
end;
function TFrameProceeding.ResolveSelectedDevice: TDevice;
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
    else if (DataManager <> nil) and (DataManager.ActiveDeviceRepo <> nil) then
      Result := DataManager.ActiveDeviceRepo.FindDeviceByUUID(Sess.DeviceUUID);
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
procedure TFrameProceeding.PopupMenuTreeViewDevicesPopup(Sender: TObject);
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
    AddActionMenuItem(ActionSessionSynchTable);
    Exit;
  end;

  if Item.TagObject is TWorkTable then
  begin
    AddSimpleMenuItem('Очистить', MenuTreeViewDevicesClearClick);
    AddActionMenuItem(ActionSessionSynchTable);
    Exit;
  end;

  if SameText(Item.Text, 'прочее') then
  begin
    AddSimpleMenuItem('Очистить', MenuTreeViewDevicesClearClick);
    AddSimpleMenuItem('Добавить', MenuTreeViewDevicesAddClick);
    Exit;
  end;

  if Item.TagObject is TDevice then
  begin
    AddSimpleMenuItem('Удалить', MenuTreeViewDevicesDeleteClick);
    AddSimpleMenuItem('Добавить', MenuTreeViewDevicesAddClick);
    Exit;
  end;

  if Item.TagObject is TSessionSpillage then
  begin
    AddActionMenuItem(ActionSessionDelete);
    AddActionMenuItem(ActionSessionClose);
    AddActionMenuItem(ActionSessionPointsClear);
    AddActionMenuItem(ActionSessionActive);
    AddActionMenuItem(ActionSessionNew);
  end;
end;
procedure TFrameProceeding.MenuTreeViewDevicesClearClick(Sender: TObject);
var
  Item: TTreeViewItem;
  WT: TWorkTable;
  Ch: TChannel;
  Device: TDevice;
  I: Integer;
  DeviceUUIDsOnTables: TStringList;
  DevicesToRemove: TList<TDevice>;

  procedure RemoveCollectedDevices;
  var
    D: TDevice;
  begin
    if (FProcessingDevices = nil) or (DevicesToRemove.Count = 0) then
      Exit;

    for D in DevicesToRemove do
      FProcessingDevices.Remove(D);

    SaveProcessingDevices;
  end;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;

  if SameText(Item.Text, '...') then
  begin
    if FProcessingDevices <> nil then
    begin
      FProcessingDevices.Clear;
      SaveProcessingDevices;
    end;

    RefreshResultsAfterDevicesAction;
    Exit;
  end;

  if (FProcessingDevices = nil) then
    Exit;

  DeviceUUIDsOnTables := TStringList.Create;
  DevicesToRemove := TList<TDevice>.Create;
  try
    DeviceUUIDsOnTables.Sorted := False;
    DeviceUUIDsOnTables.Duplicates := dupIgnore;

    if Item.TagObject is TWorkTable then
    begin
      WT := TWorkTable(Item.TagObject);
      if (WT <> nil) and (WT.DeviceChannels <> nil) then
        for Ch in WT.DeviceChannels do
          if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
            DeviceUUIDsOnTables.Add(Trim(Ch.FlowMeter.Device.UUID));

      for Device in FProcessingDevices do
        if (Device <> nil) and (DeviceUUIDsOnTables.IndexOf(Trim(Device.UUID)) >= 0) then
          DevicesToRemove.Add(Device);

      RemoveCollectedDevices;
      RefreshResultsAfterDevicesAction;
      Exit;
    end;

    if SameText(Item.Text, 'прочее') then
    begin
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

      for Device in FProcessingDevices do
        if (Device <> nil) and (DeviceUUIDsOnTables.IndexOf(Trim(Device.UUID)) < 0) then
          DevicesToRemove.Add(Device);

      RemoveCollectedDevices;
      RefreshResultsAfterDevicesAction;
    end;
  finally
    DevicesToRemove.Free;
    DeviceUUIDsOnTables.Free;
  end;
end;
procedure TFrameProceeding.SyncProcessingDevicesFromTable(AWorkTable: TWorkTable;
  const AClearBeforeSync: Boolean);
var
  Ch: TChannel;
begin
  if FProcessingDevices = nil then
    Exit;

  if AClearBeforeSync then
  begin
    FProcessingDevices.Clear;
    SaveProcessingDevices;
  end;

  if (AWorkTable <> nil) and (AWorkTable.DeviceChannels <> nil) then
    for Ch in AWorkTable.DeviceChannels do
      if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
        AddProcessingDevice(Ch.FlowMeter.Device);
end;
procedure TFrameProceeding.SyncProcessingDevicesFromAllTables(const AClearBeforeSync: Boolean);
var
  I: Integer;
  WT: TWorkTable;
begin
  if FProcessingDevices = nil then
    Exit;

  if AClearBeforeSync then
  begin
    FProcessingDevices.Clear;
    SaveProcessingDevices;
  end;

  if (FWorkTableManager = nil) or (FWorkTableManager.WorkTables = nil) then
    Exit;

  for I := 0 to FWorkTableManager.WorkTables.Count - 1 do
  begin
    WT := FWorkTableManager.WorkTables[I];
    SyncProcessingDevicesFromTable(WT, False);
  end;
end;
procedure TFrameProceeding.ActionSessionSynchTableExecute(Sender: TObject);
var
  Item: TTreeViewItem;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;

  if Item.TagObject is TWorkTable then
    SyncProcessingDevicesFromTable(TWorkTable(Item.TagObject), False)
  else if SameText(Item.Text, '...') then
    SyncProcessingDevicesFromAllTables(True)
  else
    Exit;

  RefreshResultsAfterDevicesAction;
end;
procedure TFrameProceeding.MenuTreeViewDevicesAddClick(Sender: TObject);
begin
  AddProcessingDeviceFromSelection;
  RefreshResultsAfterDevicesAction;
end;
procedure TFrameProceeding.MenuTreeViewDevicesDeleteClick(Sender: TObject);
var
  Item: TTreeViewItem;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if not (Item.TagObject is TDevice) then
    Exit;

  RemoveProcessingDevice(TDevice(Item.TagObject));
  RefreshResultsAfterDevicesAction;
end;
procedure TFrameProceeding.ActionSessionDeleteExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
  Session, NextSession: TSessionSpillage;
  I, NextIdx: Integer;
  P: TPointSpillage;
  Repo: TDeviceRepository;
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

    RemoveProcessingDevice(Device);
    RefreshResultsAfterDevicesAction;
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
    if NextSession.State = osClean then
      NextSession.State := osModified;
  end;

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(Device, NextSession);
end;
procedure TFrameProceeding.ActionSessionDeviceAddExecute(Sender: TObject);
begin
  AddProcessingDeviceFromSelection;
  RefreshResultsAfterDevicesAction;
end;
procedure TFrameProceeding.ActionSessionDeviceRemoveExecute(Sender: TObject);
var
  Item: TTreeViewItem;
begin
  if (TreeViewDevices = nil) or (TreeViewDevices.Selected = nil) then
    Exit;

  Item := TreeViewDevices.Selected;
  if not (Item.TagObject is TDevice) then
    Exit;

  RemoveProcessingDevice(TDevice(Item.TagObject));
  RefreshResultsAfterDevicesAction;
end;
procedure TFrameProceeding.ActionSessionCloseExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  Repo: TDeviceRepository;
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
    Session := Device.GetActiveSessionSpillage;
  end;

  if (Session = nil) or (Device = nil) then
    Exit;

  Session.Active := False;
  Session.Status := 2;
  Session.DateTimeClose := Now;
  if Session.State = osClean then
    Session.State := osModified;

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;
procedure TFrameProceeding.ActionSessionPointDeleteExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  Point: TPointSpillage;
  Repo: TDeviceRepository;
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
  if Session.State = osClean then
    Session.State := osModified;

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(nil, Session);

   end;

   if (Item <> nil) and (Item.TagObject is TDevice) then
   begin
       Device := TDevice(Item.TagObject);
       Point := FCurrentSpillages[GridDataPoints.Row];

   if (Device = nil) or (Point = nil) then
    Exit;

  Point.State := osDeleted;
  //if Session.State = osClean then
  //  Session.State := osModified;

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(Device, nil);

   end;





end;
procedure TFrameProceeding.ActionSessionPointsClearExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  P: TPointSpillage;
  Repo: TDeviceRepository;
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

    if Session.State = osClean then
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

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;
procedure TFrameProceeding.ActionSessionActiveExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Session, S: TSessionSpillage;
  Device: TDevice;
  Repo: TDeviceRepository;
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
    Session := Device.GetActiveSessionSpillage;
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

      if S.State = osClean then
        S.State := osModified;
    end;

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;
procedure TFrameProceeding.ActionSessionNewExecute(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
  Session: TSessionSpillage;
  Repo: TDeviceRepository;
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

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(Device, Session);
end;

procedure TFrameProceeding.TreeViewDevicesChange(Sender: TObject);
begin
  UpdateSessionItems;
  UpdateCalibrCoefsFrame;
end;

procedure TFrameProceeding.TreeViewDevicesMouseDown(Sender: TObject;
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

    for ChildIndex := 0 to AItem.Count - 1 do
    begin
      ChildItem := FindItemByPoint(TTreeViewItem(AItem.Items[ChildIndex]));
      if ChildItem <> nil then
        Exit(ChildItem);
    end;

    if AItem.AbsoluteRect.Contains(AbsPoint) then
      Result := AItem;
  end;

begin
  if (Button <> TMouseButton.mbRight) or (TreeViewDevices = nil) then
    Exit;

  AbsPoint := TreeViewDevices.LocalToAbsolute(PointF(X, Y));
  for I := 0 to TreeViewDevices.Count - 1 do
  begin
    Item := FindItemByPoint(TreeViewDevices.ItemByIndex(I));
    if Item <> nil then
    begin
      TreeViewDevices.Selected := Item;
      Exit;
    end;
  end;
end;



function TFrameProceeding.GetSelectedResultDevice: TDevice;
begin
  Result := nil;
  if (GridResults = nil) or (GridResults.Row < 0) or
     (GridResults.Row >= Length(FCurrentResultRows)) then
    Exit;

  Result := FCurrentResultRows[GridResults.Row].Device;
end;
function TFrameProceeding.DeleteSelectedDataPointWithRules(const AOwner: TObject): Boolean;
var
  Item: TTreeViewItem;
  Session: TSessionSpillage;
  Device: TDevice;
  Point, NextPoint: TPointSpillage;
  NextRow, I: Integer;
  Repo: TDeviceRepository;
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
  if (Session <> nil) and (Session.State = osClean) then
    Session.State := osModified;

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

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
procedure TFrameProceeding.ButtonSessionClearPointsClick(Sender: TObject);
var
  Item: TTreeViewItem;
  Device: TDevice;
  Session, NextSession: TSessionSpillage;
  P: TPointSpillage;
  Ch: TChannel;
  WT: TWorkTable;
  Repo: TDeviceRepository;
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
    SaveProcessingDevices;
    RefreshResultsAfterDevicesAction;
    Exit;
  end;

  if Item.TagObject is TWorkTable then
  begin
    WT := TWorkTable(Item.TagObject);
    if (WT = nil) or (WT.DeviceChannels = nil) then
      Exit;

    for Ch in WT.DeviceChannels do
      if (Ch <> nil) and (Ch.FlowMeter <> nil) and (Ch.FlowMeter.Device <> nil) then
        RemoveProcessingDevice(Ch.FlowMeter.Device);

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
    if NextSession.State = osClean then
      NextSession.State := osModified;
  end;

  Repo := nil;
  if DataManager <> nil then
    Repo := DataManager.ActiveDeviceRepo;
  if Repo <> nil then
    Repo.SaveDevice(Device);

  RefreshMeasurementsAfterSessionAction(Device, NextSession);
end;
procedure TFrameProceeding.ButtonSessionDeleteDataPointClick(Sender: TObject);
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
      RemoveProcessingDevice(Device);
      RefreshResultsAfterDevicesAction;
    end;
    Exit;
  end;

  if Item.TagObject is TDevice then
  begin
    if DeleteSelectedDataPointWithRules(Item.TagObject) then
      Exit;

    ResetPointDeleteConfirm;
    RemoveProcessingDevice(TDevice(Item.TagObject));
    RefreshResultsAfterDevicesAction;
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

procedure TFrameProceeding.GridResultsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  Row: TResultGridRow;
begin
  if (ARow < 0) or (ARow >= Length(FCurrentResultRows)) then
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
  else if GridResults.Columns[ACol] = StringColumnResult then
    Value := Row.ResultText;
end;
procedure TFrameProceeding.GridResultsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  GridRow: TResultGridRow;
  Color: TAlphaColor;
  PointIdx: Integer;
begin
  if (Row < 0) or (Row >= Length(FCurrentResultRows)) then
    Exit;

  GridRow := FCurrentResultRows[Row];
  Color := TAlphaColors.Null;

  if Column = StringColumnResult then
    Color := GetStatusColor(GridRow.ResultStatus)
  else
  begin
    PointIdx := -1;
    if Column = StringColumnPointNum1 then PointIdx := 0;
    if Column = StringColumnPointNum2 then PointIdx := 1;
    if Column = StringColumnPointNum3 then PointIdx := 2;
    if Column = StringColumnPointNum4 then PointIdx := 3;

    if (PointIdx >= 0) and (PointIdx < Length(GridRow.PointStatuses)) then
      Color := GetStatusColor(GridRow.PointStatuses[PointIdx]);
  end;

  if Color <> TAlphaColors.Null then
  begin
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := Color;
    Canvas.FillRect(Bounds, 0, 0, [], 1);
  end;
end;
procedure TFrameProceeding.GridResultsMouseDown(Sender: TObject; Button: TMouseButton;
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
procedure TFrameProceeding.GridResultsSelChanged(Sender: TObject);
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
procedure TFrameProceeding.GridDataPointsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  P: TPointSpillage;
  Sess: TSessionSpillage;
  CurrentDevice: TDevice;
begin
  if (ARow < 0) or (ARow >= Length(FCurrentSpillages)) then
    Exit;
  P := FCurrentSpillages[ARow];
  if P = nil then
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
    Value := P.Name
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
    Value := FloatToStr(P.SpillTime)

  else if GridDataPoints.Columns[ACol] = StringColumnSpillageQavgEtalon then
  begin
      if (FSessionEtalon <> nil) then
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
      if (FSessionEtalon <> nil) then
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
    Value := BoolToRussianYesNo(P.Valid)
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
procedure TFrameProceeding.GridDataPointsCellClick(const Column: TColumn;
  const Row: Integer);
var
  Point: TPointSpillage;
  Device: TDevice;
  Repo: TDeviceRepository;
begin
  if (Column <> CheckColumnSpillageEnable) or (Row < 0) or
     (Row >= Length(FCurrentSpillages)) then
    Exit;

  Point := FCurrentSpillages[Row];
  if Point = nil then
    Exit;

  Point.Enabled := not Point.Enabled;
  if Point.State = osClean then
    Point.State := osModified;

  Device := ResolveSelectedDevice;
  if Device <> nil then
  begin
    Repo := nil;
    if DataManager <> nil then
      Repo := DataManager.ActiveDeviceRepo;
    if Repo <> nil then
      Repo.SaveDevice(Device);
  end;

  UpdateGridDataPoints;
end;
procedure TFrameProceeding.GridDataPointsDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
  P: TPointSpillage;
  Color: TAlphaColor;
begin
  if (Column <> StringColumnSpillageValid) or (Row < 0) or
     (Row >= Length(FCurrentSpillages)) then
    Exit;

  P := FCurrentSpillages[Row];
  if P = nil then
    Exit;

  Color := GetStatusColor(P.Status);
  if Color = TAlphaColors.Null then
    Exit;

  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := Color;
  Canvas.FillRect(Bounds, 0, 0, [], 1);
end;
procedure TFrameProceeding.GridDataPointsMouseDown(Sender: TObject;
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
  end;
end;
procedure TFrameProceeding.UpdateGridDataPointsHeaders(QuantityDimName: string; FlowDimName: string);
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
procedure TFrameProceeding.SetSessionDim(UnitName: string; QuantityUnitName: string);
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
procedure TFrameProceeding.UpdateCalibrCoefsFrame;
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
procedure TFrameProceeding.ResetPointDeleteConfirm;
begin
  FSkipPointDeleteConfirm := False;
  FPointDeleteOwner := nil;
end;
procedure TFrameProceeding.InitCalibrCoefsFrame;
var
  Spillages: TObjectList<TPointSpillage>;
begin
  if (TabItemCalibrCoefs = nil) or (FFrameCalibrCoefs <> nil) then
    Exit;

  FFrameCalibrCoefs := TFrameCalibrCoefs.Create(Self);
  FFrameCalibrCoefs.Parent := TabItemCalibrCoefs;
  FFrameCalibrCoefs.Align := TAlignLayout.Client;
  Spillages := BuildCurrentSpillagesList;
  try
    FFrameCalibrCoefs.Init(FSessionDevice, cctReference, Spillages);
  finally
    Spillages.Free;
  end;
end;

end.
