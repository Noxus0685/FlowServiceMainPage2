unit frmCalibrCoefs;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Rtti, System.Math, System.DateUtils, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Grid.Style, FMX.Layouts, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid,
  FMX.ListBox, FMXTee.Engine, FMXTee.Procs, FMXTee.Chart, FMXTee.Series,
  UnitFlowMeter, UnitMeterValue, UnitDeviceClass;

type
  TFrameCalibrCoefs = class(TFrame)
    GridCoefs: TGrid;
    Layout1: TLayout;
    ToolBar1: TToolBar;
    SpeedButtonCoefsClear: TSpeedButton;
    SpeedButtonCoefDelete: TSpeedButton;
    SpeedButtonCefAdd: TSpeedButton;
    SpeedButtonCoefsRefresh: TSpeedButton;
    CheckColumnCoefEnable: TCheckColumn;
    StringColumnCoefValue: TStringColumn;
    StringColumnCoefArg: TStringColumn;
    StringColumnCoefInitError: TStringColumn;
    StringColumnCoefCalcError: TStringColumn;
    StringColumnCoefK: TStringColumn;
    StringColumnCoefb: TStringColumn;
    StringColumnCoefFrom: TStringColumn;
    StringColumnCoefTo: TStringColumn;
    Layout2: TLayout;
    Layout3: TLayout;
    Layout4: TLayout;
    ChartCoefs: TChart;
    ComboBox1: TComboBox;
    LabelCoefTable: TLabel;
    ComboBoxCoefTable: TComboBox;
    StringColumnCoefNum: TStringColumn;
    SpeedButtonCoefGetPoints:
    TSpeedButton;
    Series1: TFastLineSeries;
    ComboBoxUnitsCoefs: TComboBox;
    ToolBar2: TToolBar;
    LabelCoefType: TLabel;
    ComboBoxCoefType: TComboBox;
    SpeedButtonAddTable: TSpeedButton;
    SpeedButtonDeleteTable: TSpeedButton;
    Splitter1: TSplitter;
    procedure ComboBoxCoefTypeChange(Sender: TObject);
    procedure ComboBoxCoefTableChange(Sender: TObject);
    procedure ComboBoxUnitsCoefsChange(Sender: TObject);
    procedure GridCoefsGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure GridCoefsSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
    procedure SpeedButtonCefAddClick(Sender: TObject);
    procedure SpeedButtonCoefDeleteClick(Sender: TObject);
    procedure SpeedButtonCoefsClearClick(Sender: TObject);
    procedure SpeedButtonCoefsRefreshClick(Sender: TObject);
    procedure SpeedButtonCoefGetPointsClick(Sender: TObject);
    procedure SpeedButtonDeleteTableClick(Sender: TObject);
    procedure SpeedButtonAddTableClick(Sender: TObject);
  private
    FFlowMeter: TFlowMeter;
    FValue: TMeterValue;
    FCurrentType: TCalibrCoefTableType;
    FCurrentTable: TCalibrCoefTable;
    FFilteredTables: TObjectList<TCalibrCoefTable>;
    FSeriesInitError: TLineSeries;
    FSeriesCalcError: TLineSeries;
    FUpdatingUI: Boolean;

    function GetCurrentItem(ARow: Integer): TCalibrCoefItem;
    function GetCoefTypeLabel(AType: TCalibrCoefTableType): string;
    function ResolveValueByType(AType: TCalibrCoefTableType): TMeterValue;
    function BuildTableCaption(ATable: TCalibrCoefTable): string;
    function InitErrorPercent(AItem: TCalibrCoefItem): Double;
    function CalcErrorPercent(AItem: TCalibrCoefItem): Double;
    function TryGetSpillageValues(ASpillage: TPointSpillage; out AArg, AValue: Double): Boolean;
    function BuildCoefFromPoint(const AArg, AValue: Double; AOrderNo: Integer): TCalibrCoefItem;

    procedure EnsureChartSeries;
    procedure FillCoefTypes;
    procedure FillCoefTables;
    procedure FillUnits;
    procedure UpdateHeaders;
    procedure UpdateGrid;
    procedure UpdateChart;
    procedure SetCurrentTable(ATable: TCalibrCoefTable);
    procedure SyncTableToMeterValue;
    procedure SyncMeterValueToTable;
    procedure ReindexItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(AFlowMeter: TFlowMeter; ADefaultType: TCalibrCoefTableType);
    property FlowMeter: TFlowMeter read FFlowMeter;
    property CurrentType: TCalibrCoefTableType read FCurrentType;
    property CurrentTable: TCalibrCoefTable read FCurrentTable;
  end;

implementation

{$R *.fmx}

{ TFrameCalibrCoefs }

constructor TFrameCalibrCoefs.Create(AOwner: TComponent);
begin
  inherited;
  FFilteredTables := TObjectList<TCalibrCoefTable>.Create(False);
  FCurrentType := cctReference;

  GridCoefs.OnGetValue := GridCoefsGetValue;
  GridCoefs.OnSetValue := GridCoefsSetValue;

  ComboBoxCoefType.OnChange := ComboBoxCoefTypeChange;
  ComboBoxCoefTable.OnChange := ComboBoxCoefTableChange;
  ComboBoxUnitsCoefs.OnChange := ComboBoxUnitsCoefsChange;

  SpeedButtonCefAdd.OnClick := SpeedButtonCefAddClick;
  SpeedButtonCoefDelete.OnClick := SpeedButtonCoefDeleteClick;
  SpeedButtonCoefsClear.OnClick := SpeedButtonCoefsClearClick;
  SpeedButtonCoefsRefresh.OnClick := SpeedButtonCoefsRefreshClick;
  SpeedButtonCoefGetPoints.OnClick := SpeedButtonCoefGetPointsClick;

  EnsureChartSeries;
  FillCoefTypes;
end;

destructor TFrameCalibrCoefs.Destroy;
begin
  FFilteredTables.Free;
  inherited;
end;

procedure TFrameCalibrCoefs.Init(AFlowMeter: TFlowMeter; ADefaultType: TCalibrCoefTableType);
begin
  FFlowMeter := AFlowMeter;
  FCurrentType := ADefaultType;
  FValue := ResolveValueByType(FCurrentType);

  FillCoefTypes;
  FillCoefTables;
  FillUnits;
  UpdateHeaders;
  UpdateGrid;
  UpdateChart;
end;

function TFrameCalibrCoefs.GetCoefTypeLabel(AType: TCalibrCoefTableType): string;
begin
  case AType of
    cctReference:
      Result := 'справочная таблица';
    cctMeterValueCoef:
      Result := 'поправка коэффициента преобразования';
    cctMeterValueFlowRate:
      Result := 'поправка расхода';
    cctMeterValueQuantity:
      Result := 'поправка кол-ва жидкости';
    cctMeterValueDensity:
      Result := 'поправка плотности';
    cctDeviceCoefCorrection:
      Result := 'поправка коэффициента преобразования (для записи в прибор)';
    cctDeviceFlowRateCorrection:
      Result := 'поправка расхода (для записи в прибор)';
    cctDeviceQuantityCorrection:
      Result := 'поправка количества (для записи в прибор)';
    cctDeviceDensityCorrection:
      Result := 'поправка плотности (для записи в прибор)';
  else
    Result := Format('тип %d', [Ord(AType)]);
  end;
end;

function TFrameCalibrCoefs.ResolveValueByType(AType: TCalibrCoefTableType): TMeterValue;
begin
  Result := nil;
  if FFlowMeter = nil then
    Exit;

  case AType of
    cctMeterValueCoef,
    cctDeviceCoefCorrection:
      Result := FFlowMeter.ValueCoef;

    cctMeterValueFlowRate,
    cctDeviceFlowRateCorrection:
      Result := FFlowMeter.ValueFlow;

    cctMeterValueQuantity,
    cctDeviceQuantityCorrection:
      Result := FFlowMeter.ValueQuantity;

    cctMeterValueDensity,
    cctDeviceDensityCorrection:
      Result := FFlowMeter.ValueDensity;

    cctReference:
      Result := FFlowMeter.ValueFlow;
  end;
end;

procedure TFrameCalibrCoefs.FillCoefTypes;
const
  CCoefTypes: array[0..8] of TCalibrCoefTableType = (
    cctReference,
    cctMeterValueCoef,
    cctMeterValueFlowRate,
    cctMeterValueQuantity,
    cctMeterValueDensity,
    cctDeviceCoefCorrection,
    cctDeviceFlowRateCorrection,
    cctDeviceQuantityCorrection,
    cctDeviceDensityCorrection
  );
var
  AType: TCalibrCoefTableType;
  Item: TListBoxItem;
  I: Integer;
begin
  FUpdatingUI := True;
  try
    ComboBoxCoefType.Clear;
    for AType in CCoefTypes do
    begin
      Item := TListBoxItem.Create(ComboBoxCoefType);
      Item.Parent := ComboBoxCoefType;
      Item.Text := GetCoefTypeLabel(AType);
      Item.Tag := Ord(AType);
    end;

    ComboBoxCoefType.ItemIndex := -1;
    for I := 0 to ComboBoxCoefType.Count - 1 do
      if ComboBoxCoefType.ListItems[I].Tag = Ord(FCurrentType) then
      begin
        ComboBoxCoefType.ItemIndex := I;
        Break;
      end;

    if (ComboBoxCoefType.ItemIndex < 0) and (ComboBoxCoefType.Count > 0) then
      ComboBoxCoefType.ItemIndex := 0;
  finally
    FUpdatingUI := False;
  end;
end;

function TFrameCalibrCoefs.BuildTableCaption(ATable: TCalibrCoefTable): string;
begin
  if ATable = nil then
    Exit('');

  if ATable.AppliedAt > 0 then
    Result := Format('%s (%s)', [ATable.Name, FormatDateTime('dd.mm.yyyy hh:nn', ATable.AppliedAt)])
  else
    Result := ATable.Name;
end;

procedure TFrameCalibrCoefs.FillCoefTables;
var
  Device: TDevice;
  Table: TCalibrCoefTable;
  Item: TListBoxItem;
  ActiveIndex: Integer;
  I: Integer;
begin
  FFilteredTables.Clear;
  FUpdatingUI := True;
  try
    ComboBoxCoefTable.Clear;
    SetCurrentTable(nil);

    if (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
      Exit;

    Device := FFlowMeter.Device;
    ActiveIndex := -1;

    for Table in Device.CalibrCoefTables do
    begin
      if (Table = nil) or (Table.&Type <> Ord(FCurrentType)) then
        Continue;

      FFilteredTables.Add(Table);
      Item := TListBoxItem.Create(ComboBoxCoefTable);
      Item.Parent := ComboBoxCoefTable;
      Item.Text := BuildTableCaption(Table);
      Item.Tag := FFilteredTables.Count - 1;

      if Table.Active then
        ActiveIndex := ComboBoxCoefTable.Count - 1;
    end;

    if ComboBoxCoefTable.Count = 0 then
      Exit;

    if ActiveIndex < 0 then
      ActiveIndex := 0;

    ComboBoxCoefTable.ItemIndex := ActiveIndex;
    I := ComboBoxCoefTable.ListItems[ActiveIndex].Tag;
    if (I >= 0) and (I < FFilteredTables.Count) then
      SetCurrentTable(FFilteredTables[I]);
  finally
    FUpdatingUI := False;
  end;
end;

procedure TFrameCalibrCoefs.FillUnits;
var
  I: Integer;
begin
  ComboBoxUnitsCoefs.Clear;

  if FValue = nil then
    Exit;

  for I := 0 to FValue.Dimensions.Count - 1 do
    ComboBoxUnitsCoefs.Items.Add(FValue.GetDimName(I));

  if ComboBoxUnitsCoefs.Count > 0 then
  begin
    ComboBoxUnitsCoefs.ItemIndex := FValue.GetDim;
    if ComboBoxUnitsCoefs.ItemIndex < 0 then
      ComboBoxUnitsCoefs.ItemIndex := 0;
    FValue.SetDim(ComboBoxUnitsCoefs.ItemIndex);
  end;
end;

procedure TFrameCalibrCoefs.UpdateHeaders;
var
  DimText: string;
begin
  DimText := '';
  if FValue <> nil then
    DimText := FValue.GetDimName;

  if DimText <> '' then
    DimText := ', ' + DimText;

  StringColumnCoefValue.Header := 'Эталон' + DimText;
  StringColumnCoefArg.Header := 'Прибор исх' + DimText;
end;

procedure TFrameCalibrCoefs.UpdateGrid;
begin
   GridCoefs.RowCount := 0;

  if (FCurrentTable <> nil) and (FCurrentTable.Items <> nil) then
        GridCoefs.RowCount := FCurrentTable.Items.Count;

  GridCoefs.Repaint;
end;

procedure TFrameCalibrCoefs.EnsureChartSeries;
begin
  if FSeriesInitError = nil then
  begin
    FSeriesInitError := TLineSeries.Create(ChartCoefs);
    FSeriesInitError.Title := 'Погрешность исх, %';
    FSeriesInitError.ParentChart := ChartCoefs;
  end;

  if FSeriesCalcError = nil then
  begin
    FSeriesCalcError := TLineSeries.Create(ChartCoefs);
    FSeriesCalcError.Title := 'Погрешность расч, %';
    FSeriesCalcError.ParentChart := ChartCoefs;
  end;
end;

function TFrameCalibrCoefs.InitErrorPercent(AItem: TCalibrCoefItem): Double;
begin
  if (AItem = nil) or SameValue(AItem.Value, 0, 1E-12) then
    Exit(0);
  Result := (AItem.Value - AItem.Arg) / AItem.Value * 100;
end;

function TFrameCalibrCoefs.CalcErrorPercent(AItem: TCalibrCoefItem): Double;
var
  RateVal: Double;
begin
  if (AItem = nil) or SameValue(AItem.Value, 0, 1E-12) or (FValue = nil) then
    Exit(0);

  RateVal := FValue.Rate(AItem.Arg);
  Result := (AItem.Value - (AItem.Arg * RateVal)) / AItem.Value * 100;
end;

procedure TFrameCalibrCoefs.UpdateChart;
var
  Item: TCalibrCoefItem;
begin
  EnsureChartSeries;
  FSeriesInitError.Clear;
  FSeriesCalcError.Clear;

  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) then
    Exit;

  for Item in FCurrentTable.Items do
  begin
    if Item = nil then
      Continue;

    FSeriesInitError.AddXY(Item.Arg, InitErrorPercent(Item));
    FSeriesCalcError.AddXY(Item.Arg, CalcErrorPercent(Item));
  end;
end;

procedure TFrameCalibrCoefs.SetCurrentTable(ATable: TCalibrCoefTable);
begin
  FCurrentTable := ATable;
  SyncTableToMeterValue;
  UpdateGrid;
  UpdateChart;
end;

procedure TFrameCalibrCoefs.SyncTableToMeterValue;
var
  Item: TCalibrCoefItem;
  C: TCoef;
begin
  if FValue = nil then
    Exit;

  FValue.Coefs.Clear;

  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) then
    Exit;

  for Item in FCurrentTable.Items do
  begin
    if Item = nil then
      Continue;

    C.Name := Item.Name;
    C.Index := Item.OrderNo;
    C.Hash := Item.UUID;
    C.Value := Item.Value;
    C.Arg := Item.Arg;
    C.Q1 := Item.QFrom;
    C.Q2 := Item.QTo;
    C.K := Item.K;
    C.b := Item.b;
    C.InUse := Item.Enable;
    FValue.Coefs.Add(C);
  end;
end;

procedure TFrameCalibrCoefs.SyncMeterValueToTable;
var
  I: Integer;
  C: TCoef;
  Item: TCalibrCoefItem;
begin
  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) or (FValue = nil) then
    Exit;

  for I := 0 to Min(FCurrentTable.Items.Count, FValue.Coefs.Count) - 1 do
  begin
    C := FValue.Coefs[I];
    Item := FCurrentTable.Items[I];
    if Item = nil then
      Continue;

    Item.QFrom := C.Q1;
    Item.QTo := C.Q2;
    Item.K := C.K;
    Item.b := C.b;
    Item.Enable := C.InUse;
    if C.Name <> '' then
      Item.Name := C.Name;
  end;
end;

function TFrameCalibrCoefs.GetCurrentItem(ARow: Integer): TCalibrCoefItem;
begin
  Result := nil;
  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) then
    Exit;

  if (ARow < 0) or (ARow >= FCurrentTable.Items.Count) then
    Exit;

  Result := FCurrentTable.Items[ARow];
end;

procedure TFrameCalibrCoefs.ReindexItems;
var
  I: Integer;
begin
  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) then
    Exit;

  for I := 0 to FCurrentTable.Items.Count - 1 do
    FCurrentTable.Items[I].OrderNo := I + 1;
end;

procedure TFrameCalibrCoefs.ComboBoxCoefTypeChange(Sender: TObject);
var
  Item: TListBoxItem;
begin
  if FUpdatingUI then
    Exit;

  Item := ComboBoxCoefType.Selected;
  if Item = nil then
    Exit;

  FCurrentType := TCalibrCoefTableType(Item.Tag);
  FValue := ResolveValueByType(FCurrentType);

  FillCoefTables;
  FillUnits;
  UpdateHeaders;
  UpdateGrid;
  UpdateChart;
end;

procedure TFrameCalibrCoefs.ComboBoxCoefTableChange(Sender: TObject);
var
  Idx: Integer;
begin
  if FUpdatingUI then
    Exit;

  if ComboBoxCoefTable.ItemIndex < 0 then
  begin
    SetCurrentTable(nil);
    Exit;
  end;

  Idx := ComboBoxCoefTable.ListItems[ComboBoxCoefTable.ItemIndex].Tag;
  if (Idx >= 0) and (Idx < FFilteredTables.Count) then
    SetCurrentTable(FFilteredTables[Idx]);
end;

procedure TFrameCalibrCoefs.ComboBoxUnitsCoefsChange(Sender: TObject);
begin
  if (FValue <> nil) and (ComboBoxUnitsCoefs.ItemIndex >= 0) then
    FValue.SetDim(ComboBoxUnitsCoefs.ItemIndex);

  UpdateHeaders;
  UpdateGrid;
end;

procedure TFrameCalibrCoefs.GridCoefsGetValue(Sender: TObject; const ACol,
  ARow: Integer; var Value: TValue);
var
  Item: TCalibrCoefItem;
begin
  Item := GetCurrentItem(ARow);
  if Item = nil then
    Exit;

  if GridCoefs.Columns[ACol] = CheckColumnCoefEnable then
    Value := Item.Enable
  else if GridCoefs.Columns[ACol] = StringColumnCoefNum then
    Value := Item.OrderNo
  else if GridCoefs.Columns[ACol] = StringColumnCoefValue then
  begin
    if FValue <> nil then
      Value := FValue.GetStrNum(Item.Value)
    else
      Value := FloatToStr(Item.Value);
  end
  else if GridCoefs.Columns[ACol] = StringColumnCoefArg then
  begin
    if FValue <> nil then
      Value := FValue.GetStrNum(Item.Arg)
    else
      Value := FloatToStr(Item.Arg);
  end
  else if GridCoefs.Columns[ACol] = StringColumnCoefInitError then
    Value := FormatFloat('0.000000', InitErrorPercent(Item))
  else if GridCoefs.Columns[ACol] = StringColumnCoefCalcError then
    Value := FormatFloat('0.000000', CalcErrorPercent(Item))
  else if GridCoefs.Columns[ACol] = StringColumnCoefK then
    Value := FormatFloat('0.000000', Item.K)
  else if GridCoefs.Columns[ACol] = StringColumnCoefb then
    Value := FormatFloat('0.000000', Item.b)
  else if GridCoefs.Columns[ACol] = StringColumnCoefFrom then
  begin
    if FValue <> nil then
      Value := FValue.GetStrNum(Item.QFrom)
    else
      Value := FloatToStr(Item.QFrom);
  end
  else if GridCoefs.Columns[ACol] = StringColumnCoefTo then
  begin
    if FValue <> nil then
      Value := FValue.GetStrNum(Item.QTo)
    else
      Value := FloatToStr(Item.QTo);
  end;
end;

procedure TFrameCalibrCoefs.GridCoefsSetValue(Sender: TObject; const ACol,
  ARow: Integer; const Value: TValue);
var
  Item: TCalibrCoefItem;
  S: string;
  D: Double;
begin
  Item := GetCurrentItem(ARow);
  if Item = nil then
    Exit;

  S := Value.ToString;
  case ACol of
    0: Item.Enable := Value.AsBoolean;
    1: Item.OrderNo := Value.AsInteger;
    2:
      begin
        if FValue <> nil then
          D := FValue.GetDoubleNum(S)
        else
          D := StrToFloatDef(S, Item.Value);
        Item.Value := D;
      end;
    3:
      begin
        if FValue <> nil then
          D := FValue.GetDoubleNum(S)
        else
          D := StrToFloatDef(S, Item.Arg);
        Item.Arg := D;
      end;
    6: Item.K := StrToFloatDef(S, Item.K);
    7: Item.b := StrToFloatDef(S, Item.b);
    8:
      begin
        if FValue <> nil then
          Item.QFrom := FValue.GetDoubleNum(S)
        else
          Item.QFrom := StrToFloatDef(S, Item.QFrom);
      end;
    9:
      begin
        if FValue <> nil then
          Item.QTo := FValue.GetDoubleNum(S)
        else
          Item.QTo := StrToFloatDef(S, Item.QTo);
      end;
  end;

  UpdateGrid;
  UpdateChart;
end;

procedure TFrameCalibrCoefs.SpeedButtonAddTableClick(Sender: TObject);
var
  Device: TDevice;
  Table: TCalibrCoefTable;
  ExistingTable: TCalibrCoefTable;
  Stamp: TDateTime;
begin
  if (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;

  Device := FFlowMeter.Device;

  Stamp := Now;
  Table := TCalibrCoefTable.Create;
  Table.DeviceID := Device.ID;
  Table.DeviceUUID := Device.UUID;
  Table.&Type := Ord(FCurrentType);
  Table.Active := True;
  Table.AppliedAt := Stamp;
  Table.Name := FormatDateTime('dd.mm.yyyy hh:nn:ss', Stamp);

  for ExistingTable in Device.CalibrCoefTables do
    if (ExistingTable <> nil) and (ExistingTable.&Type = Ord(FCurrentType)) then
      ExistingTable.Active := False;

  Device.CalibrCoefTables.Add(Table);
  FillCoefTables;
  UpdateGrid;
  UpdateChart;
end;

procedure TFrameCalibrCoefs.SpeedButtonCefAddClick(Sender: TObject);
var
  Item: TCalibrCoefItem;
begin
  if FCurrentTable = nil then
    Exit;

  Item := TCalibrCoefItem.Create;
  Item.Name := Format('Точка %d', [FCurrentTable.Items.Count + 1]);
  Item.UUID := '';
  Item.TableID := FCurrentTable.ID;
  Item.OrderNo := FCurrentTable.Items.Count + 1;
  Item.Value := 0;
  Item.Arg := 0;
  Item.QFrom := 0;
  Item.QTo := 0;
  Item.K := 1;
  Item.b := 0;
  Item.Enable := True;

  FCurrentTable.Items.Add(Item);
  UpdateGrid;
  UpdateChart;
end;

procedure TFrameCalibrCoefs.SpeedButtonCoefDeleteClick(Sender: TObject);
var
  R: Integer;
begin
  if (FCurrentTable = nil) or (GridCoefs.Row < 0) then
    Exit;

  R := GridCoefs.Row;
  if (R >= 0) and (R < FCurrentTable.Items.Count) then
  begin
    FCurrentTable.Items.Delete(R);
    ReindexItems;
    UpdateGrid;
    UpdateChart;
  end;
end;

procedure TFrameCalibrCoefs.SpeedButtonCoefsClearClick(Sender: TObject);
begin
  if FCurrentTable = nil then
    Exit;

  FCurrentTable.Items.Clear;
  UpdateGrid;
  UpdateChart;
end;

procedure TFrameCalibrCoefs.SpeedButtonCoefsRefreshClick(Sender: TObject);
begin
  if (FValue = nil) or (FCurrentTable = nil) then
    Exit;

  SyncTableToMeterValue;
  FValue.CalcCoefs;
  SyncMeterValueToTable;

  UpdateGrid;
  UpdateChart;
end;

procedure TFrameCalibrCoefs.SpeedButtonDeleteTableClick(Sender: TObject);
var
  Device: TDevice;
  TableToDelete: TCalibrCoefTable;
  I: Integer;
begin
  if (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;

  if (ComboBoxCoefTable.ItemIndex < 0) or (FCurrentTable = nil) then
    Exit;

  Device := FFlowMeter.Device;
  TableToDelete := FCurrentTable;

  Device.CalibrCoefTables.Remove(TableToDelete);

  if TableToDelete.Active then
    for I := 0 to Device.CalibrCoefTables.Count - 1 do
      if (Device.CalibrCoefTables[I] <> nil) and
         (Device.CalibrCoefTables[I].&Type = Ord(FCurrentType)) then
      begin
        Device.CalibrCoefTables[I].Active := True;
        Break;
      end;

  FillCoefTables;
  UpdateGrid;
  UpdateChart;
end;

function TFrameCalibrCoefs.TryGetSpillageValues(ASpillage: TPointSpillage; out AArg,
  AValue: Double): Boolean;
begin
  Result := False;
  if ASpillage = nil then
    Exit;

  case FCurrentType of
    cctMeterValueCoef,
    cctDeviceCoefCorrection:
      begin
        AArg := ASpillage.Coef;
        AValue := ASpillage.Coef;
        Result := True;
      end;

    cctMeterValueFlowRate,
    cctDeviceFlowRateCorrection:
      begin
        if not SameValue(ASpillage.EtalonVolumeFlow, 0, 1E-12) then
        begin
          AArg := ASpillage.DeviceVolumeFlow;
          AValue := ASpillage.EtalonVolumeFlow;
        end
        else
        begin
          AArg := ASpillage.DeviceMassFlow;
          AValue := ASpillage.EtalonMassFlow;
        end;
        Result := True;
      end;

    cctMeterValueQuantity,
    cctDeviceQuantityCorrection:
      begin
        if not SameValue(ASpillage.EtalonVolume, 0, 1E-12) then
        begin
          AArg := ASpillage.DeviceVolume;
          AValue := ASpillage.EtalonVolume;
        end
        else
        begin
          AArg := ASpillage.DeviceMass;
          AValue := ASpillage.EtalonMass;
        end;
        Result := True;
      end;

    cctMeterValueDensity,
    cctDeviceDensityCorrection:
      begin
        AArg := ASpillage.Density;
        AValue := ASpillage.Density;
        Result := True;
      end;

    cctReference:
      begin
        if not SameValue(ASpillage.EtalonVolumeFlow, 0, 1E-12) then
        begin
          AArg := ASpillage.DeviceVolumeFlow;
          AValue := ASpillage.EtalonVolumeFlow;
        end
        else
        begin
          AArg := ASpillage.DeviceMassFlow;
          AValue := ASpillage.EtalonMassFlow;
        end;
        Result := True;
      end;
  end;

  Result := Result and (not SameValue(AValue, 0, 1E-12));
end;

function TFrameCalibrCoefs.BuildCoefFromPoint(const AArg, AValue: Double;
  AOrderNo: Integer): TCalibrCoefItem;
begin
  Result := TCalibrCoefItem.Create;
  Result.Name := Format('Точка %d', [AOrderNo]);
  Result.TableID := FCurrentTable.ID;
  Result.OrderNo := AOrderNo;
  Result.Arg := AArg;
  Result.Value := AValue;
  Result.QFrom := AArg;
  Result.QTo := AArg;
  Result.K := 1;
  Result.b := 0;
  Result.Enable := True;
end;

procedure TFrameCalibrCoefs.SpeedButtonCoefGetPointsClick(Sender: TObject);
var
  Spillage: TPointSpillage;
  ArgValue: Double;
  RefValue: Double;
  Item: TCalibrCoefItem;
  OrderNo: Integer;
begin
  if (FCurrentTable = nil) or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;

  FCurrentTable.Items.Clear;
  OrderNo := 1;

  for Spillage in FFlowMeter.Device.Spillages do
  begin
    if not TryGetSpillageValues(Spillage, ArgValue, RefValue) then
      Continue;

    Item := BuildCoefFromPoint(ArgValue, RefValue, OrderNo);
    FCurrentTable.Items.Add(Item);
    Inc(OrderNo);
  end;

  SpeedButtonCoefsRefreshClick(Sender);
end;

end.
