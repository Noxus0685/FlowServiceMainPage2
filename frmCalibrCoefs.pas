unit frmCalibrCoefs;

interface

uses
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Graphics,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.Layouts,
  FMX.ListBox,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,
  FMXTee.Chart,
  FMXTee.Engine,
  FMXTee.Procs,
  FMXTee.Series,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  uClasses,
  uDeviceClass,
  uFlowMeter,
  uMeterValue;

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
    StringColumnQ1: TStringColumn;
    StringColumnQ2: TStringColumn;
    LayoutGraph: TLayout;
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
    ComboBoxUnitsCorrection: TComboBox;
    LabelCoefsRange: TLabel;
    SpeedButtonShowGraph: TSpeedButton;
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
    procedure ComboBoxUnitsCorrectionChange(Sender: TObject);
    procedure SpeedButtonShowGraphClick(Sender: TObject);
  private
    FFlowMeter: TFlowMeter;
    FValue: TMeterValue;   //Корректируемое значение
    FValueCorrection:  TMeterValue; //аргумент функции корректировки

    FCurrentType: TCalibrCoefTableType;
    FCurrentTable: TCalibrCoefTable;
    FFilteredTables: TObjectList<TCalibrCoefTable>;

    FCurrentSpillages : TObjectList<TPointSpillage>;

    FSeriesInitError: TLineSeries;
    FSeriesCalcError: TLineSeries;
    FSeriesMarkers: TPointSeries;
    FUpdatingUI: Boolean;

    function GetCurrentItem(ARow: Integer): TCalibrCoefItem;
    function GetCoefTypeLabel(AType: TCalibrCoefTableType): string;
    procedure ResolveValueByType(AType: TCalibrCoefTableType);
    function BuildTableCaption(ATable: TCalibrCoefTable): string;
    function InitErrorPercent(AItem: TCalibrCoefItem): Double;
    function CalcErrorPercent(AItem: TCalibrCoefItem): Double;
    function TryGetSpillageValues(ASpillage: TPointSpillage; out AArg, AValue, AQ: Double): Boolean;
    function BuildCoefFromPoint(const AArg, AValue, AQ: Double; AOrderNo: Integer): TCalibrCoefItem;
    procedure BuildCurrentTableFromSpillages;
    procedure RecalculateCurrentTable;
    procedure SetCurrentSpillages(ASpillages: TObjectList<TPointSpillage>);

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
    procedure SortCurrentTableByRange;
    procedure ReindexItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(AFlowMeter: TFlowMeter; ADefaultType: TCalibrCoefTableType; ASpillages: TObjectList<TPointSpillage> = nil);
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
  FCurrentSpillages := TObjectList<TPointSpillage>.Create(False);
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
  FCurrentSpillages.Free;
  FFilteredTables.Free;
  inherited;
end;

procedure TFrameCalibrCoefs.Init(AFlowMeter: TFlowMeter; ADefaultType: TCalibrCoefTableType; ASpillages: TObjectList<TPointSpillage>);
begin
  FFlowMeter := AFlowMeter;
  FCurrentType := ADefaultType;
  SetCurrentSpillages(ASpillages);

  ResolveValueByType(FCurrentType);   //определение FValue и  FValueCorrection

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
      Result := 'коэффициент преобразования';
    cctMeterValueFlowRate:
      Result := 'корректировка расхода';
    cctMeterValueQuantity:
      Result := 'корректировка кол-ва';
    cctMeterValueDensity:
      Result := 'корректировка плотности';
    cctDeviceCoefCorrection:
      Result := 'коэффициент преобразования (прибор)';
    cctDeviceFlowRateCorrection:
      Result := 'поправка расхода (прибор)';
    cctDeviceQuantityCorrection:
      Result := 'поправка количества (прибор)';
    cctDeviceDensityCorrection:
      Result := 'поправка плотности (прибор)';
  else
    Result := Format('тип %d', [Ord(AType)]);
  end;
end;

procedure TFrameCalibrCoefs.ResolveValueByType(AType: TCalibrCoefTableType);
var
  Dim: TMeasuredDimension;
begin
  if FFlowMeter = nil then
    Exit;

  if (FFlowMeter.Device <> nil) then
    Dim := TMeasuredDimension(FFlowMeter.Device.MeasuredDimension)
  else
    Dim := mdUnknown;

  case AType of
    cctMeterValueCoef,
    cctDeviceCoefCorrection:
      begin
        FValue := FFlowMeter.ValueCoef;
        case Dim of
          mdVolumeFlow:
            FValueCorrection := FFlowMeter.ValueVolumeFlow;
          mdVolume:
            FValueCorrection := FFlowMeter.ValueVolume;
          mdMassFlow:
            FValueCorrection := FFlowMeter.ValueMassFlow;
          mdMass:
            FValueCorrection := FFlowMeter.ValueMass;
        else
          FValueCorrection := FFlowMeter.ValueFlowRate;
        end;
      end;

    cctMeterValueFlowRate,
    cctDeviceFlowRateCorrection:
      begin
        FValue := FFlowMeter.ValueFlow;
        case Dim of
          mdVolumeFlow, mdVolume:
            FValueCorrection := FFlowMeter.ValueVolume;
          mdMassFlow, mdMass:
            FValueCorrection := FFlowMeter.ValueMass;
        else
          FValueCorrection := FFlowMeter.ValueFlowRate;
        end;
      end;

    cctMeterValueQuantity,
    cctDeviceQuantityCorrection:
      begin
        FValue := FFlowMeter.ValueQuantity;
        case Dim of
          mdVolumeFlow, mdVolume:
            FValueCorrection := FFlowMeter.ValueVolume;
          mdMassFlow, mdMass:
            FValueCorrection := FFlowMeter.ValueMass;
        else
          FValueCorrection := FFlowMeter.ValueQuantity;
        end;
      end;

    cctMeterValueDensity,
    cctDeviceDensityCorrection:
      begin
        FValue := FFlowMeter.ValueDensity;
        FValueCorrection := FFlowMeter.ValueDensity;
      end;

    cctReference:
      begin
        FValue := FFlowMeter.ValueFlow;
        FValueCorrection := FFlowMeter.ValueFlow;
      end;
  end;
end;

procedure TFrameCalibrCoefs.SetCurrentSpillages(
  ASpillages: TObjectList<TPointSpillage>);
var
  Spillage: TPointSpillage;
begin
  if FCurrentSpillages = nil then
    FCurrentSpillages := TObjectList<TPointSpillage>.Create(False);

  FCurrentSpillages.Clear;
  if ASpillages = nil then
    Exit;

  for Spillage in ASpillages do
    if Spillage <> nil then
      FCurrentSpillages.Add(Spillage);
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
  UnitsValue: TMeterValue;
begin

// Основная величина!
  ComboBoxUnitsCoefs.Clear;

  if FValue = nil then
    Exit;

  UnitsValue := FValue;

  if UnitsValue = nil then
    Exit;

  for I := 0 to UnitsValue.Dimensions.Count - 1 do
    ComboBoxUnitsCoefs.Items.Add(UnitsValue.GetDimName(I));

  if ComboBoxUnitsCoefs.Count > 0 then
  begin
    ComboBoxUnitsCoefs.ItemIndex := UnitsValue.GetDim;
    if ComboBoxUnitsCoefs.ItemIndex < 0 then
      ComboBoxUnitsCoefs.ItemIndex := 0;
    UnitsValue.SetDim(ComboBoxUnitsCoefs.ItemIndex);
  end;

  //Коррекция

  ComboBoxUnitsCorrection.Clear;
  ComboBoxUnitsCorrection.Visible:=True;
  LabelCoefsRange.Visible:=True;
  //если для локального    FValue не задан ValueCorrection, но это коэф-нт
  // для которого он должен быть задан, то берем тот тип значений, который там должен быть.
  if FValue.ValueCorrection = nil then
     begin

    if SameText(FValue.&Type, 'Коэффициент массы') and (FFlowMeter <> nil) then
      FValueCorrection :=  FFlowMeter.ValueMassFlow


    else if SameText(FValue.&Type, 'Коэффициент объема') and (FFlowMeter <> nil) then
      FValueCorrection :=  FFlowMeter.ValueVolumeFlow

    else
      begin
      //Нет корректировки и это не коэфнт
      //Значит скрываем второй ComboBox
       ComboBoxUnitsCorrection.Visible:=False;
       LabelCoefsRange.Visible:=False;
       FValueCorrection :=  FValue;
     end
    end

    else
    FValueCorrection :=  FValue.ValueCorrection;


  UnitsValue := FValueCorrection;

  for I := 0 to UnitsValue.Dimensions.Count - 1 do
    ComboBoxUnitsCorrection.Items.Add(UnitsValue.GetDimName(I));

  if ComboBoxUnitsCorrection.Count > 0 then
  begin
    ComboBoxUnitsCorrection.ItemIndex := UnitsValue.GetDim;
    if ComboBoxUnitsCorrection.ItemIndex < 0 then
      ComboBoxUnitsCorrection.ItemIndex := 0;
    UnitsValue.SetDim(ComboBoxUnitsCorrection.ItemIndex);
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

  DimText := '';
  if FValueCorrection <> nil then
    DimText := FValueCorrection.GetDimName

  else if FValue <> nil then
    DimText := FValue.GetDimName;

  if DimText <> '' then
    DimText := ', ' + DimText;

  StringColumnQ1.Header := 'Диапазон от' + DimText;
  StringColumnQ2.Header := 'Диапазон до' + DimText;

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

   if FSeriesMarkers = nil then
  begin
    FSeriesMarkers := TPointSeries.Create(Self);
    FSeriesMarkers.ParentChart := ChartCoefs;
    FSeriesMarkers.Title := 'Точки';

    FSeriesMarkers.Pointer.Visible := True;
    FSeriesMarkers.Pointer.Style := psCircle;
    FSeriesMarkers.Pointer.HorizSize := 6;
    FSeriesMarkers.Pointer.VertSize := 6;
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
  Dim: TMeasuredDimension;
  Q: Double;
  RateVal: Double;
begin
  if (AItem = nil) or SameValue(AItem.Value, 0, 1E-12) or (FValue = nil) then
    Exit(0);

  if (FFlowMeter <> nil) and (FFlowMeter.Device <> nil) then
    Dim := TMeasuredDimension(FFlowMeter.Device.MeasuredDimension)
  else
    Dim := mdUnknown;

  Q := AItem.Arg;

  case FCurrentType of
    cctMeterValueCoef,
    cctDeviceCoefCorrection:
      case Dim of
        mdVolumeFlow,
        mdVolume,
        mdMassFlow,
        mdMass:
          Q := AItem.RangeArg;
      end;

    cctMeterValueFlowRate,
    cctDeviceFlowRateCorrection,
    cctReference:
      case Dim of
        mdVolumeFlow,
        mdVolume,
        mdMassFlow,
        mdMass:
          Q := AItem.Arg;
      end;

    cctMeterValueQuantity,
    cctDeviceQuantityCorrection:
      case Dim of
        mdVolumeFlow,
        mdVolume,
        mdMassFlow,
        mdMass:
          Q := AItem.Arg;
      end;

    cctMeterValueDensity,
    cctDeviceDensityCorrection:
      Q := AItem.RangeArg;
  end;

  RateVal := FValue.Rate(Q);
  Result := (AItem.Value - (AItem.Arg * RateVal)) / AItem.Value * 100;
end;

procedure TFrameCalibrCoefs.UpdateChart;
var
  Item: TCalibrCoefItem;
  I : integer;
  X: Double;
  MinX, MaxX: Double;
  MinY, MaxY: Double;
  InitErr, CalcErr: Double;
  DX, DY: Double;
  FirstX, LastX: Double;
  FirstInitErr, LastInitErr: Double;
  FirstCalcErr, LastCalcErr: Double;
  HasFirst: Boolean;



  function BuildAxisTitle(AMeterValue: TMeterValue; const ADefault: string): string;
var
  BaseName: string;
  DimName: string;
begin
  Result := ADefault;

  if AMeterValue = nil then
    Exit;

  // 1. Имя параметра
  if AMeterValue.Description <> '' then
    BaseName := AMeterValue.Description
  else if AMeterValue.Name <> '' then
    BaseName := AMeterValue.Name
  else
    BaseName := ADefault;

  // 2. Единицы измерения
  DimName := '';
  DimName := AMeterValue.GetDimName;

  // 3. Формирование строки
  if (DimName <> '') and (Pos(DimName, BaseName) = 0) then
    Result := BaseName + ' (' + DimName + ')'
  else
    Result := BaseName;
end;

  procedure UpdateBounds(const AX, AY: Double);
  begin
    if AX < MinX then MinX := AX;
    if AX > MaxX then MaxX := AX;
    if AY < MinY then MinY := AY;
    if AY > MaxY then MaxY := AY;
  end;

   function GetItemX(AChartItem: TCalibrCoefItem): Double;
begin
  Result := 0;
  if AChartItem = nil then
    Exit;

  if (IsInfinite(AChartItem.RangeArg)=False )then
  begin

    if FValueCorrection <> nil then
      Result :=  FValueCorrection.GetDoubleNum(AChartItem.RangeArg)
    else
      Result := AChartItem.RangeArg;
  end


  else if (AChartItem.RangeArg=Infinity) then
       Result := Infinity
  else
      Result := AChartItem.RangeArg;



  end;

begin
  EnsureChartSeries;

  FSeriesInitError.Clear;
  FSeriesCalcError.Clear;
  FSeriesMarkers.Clear;

  FSeriesInitError.Pointer.Visible := True;
  FSeriesCalcError.Pointer.Visible := True;

  ChartCoefs.Legend.Visible := True;
  ChartCoefs.BottomAxis.Title.Visible := True;
  ChartCoefs.LeftAxis.Title.Visible := True;

ChartCoefs.BottomAxis.Title.Caption := BuildAxisTitle(FValueCorrection, 'Q');
  ChartCoefs.LeftAxis.Title.Caption := 'Погрешность, %';

  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) or (FCurrentTable.Items.Count = 0) then
  begin
    ChartCoefs.BottomAxis.Automatic := True;
   // ChartCoefs.BottomAxis.SetMinMax(0, 1);
    ChartCoefs.LeftAxis.Automatic := True;
   /// ChartCoefs.LeftAxis.SetMinMax(-1, 1);
    Exit;
  end;

  MinX :=  1.0E300;
  MaxX := -1.0E300;
  MinY :=  1.0E300;
  MaxY := -1.0E300;
  HasFirst := False;

  I := 0;


  for Item in FCurrentTable.Items do
  begin
   // Inc(I);
    if (Item = nil){ or (I=1) }then
      Continue;


     X := GetItemX(Item);

    InitErr := InitErrorPercent(Item);
    CalcErr := CalcErrorPercent(Item);

    FSeriesInitError.AddXY(X, InitErr);


    FSeriesCalcError.AddXY(X, CalcErr);


    UpdateBounds(X, InitErr);

    UpdateBounds(X, CalcErr);


    if not HasFirst then
    begin
      FirstX := X;
      FirstInitErr := InitErr;
      FirstCalcErr := CalcErr;
      HasFirst := True;
    end;

    LastX := X;
    LastInitErr := InitErr;
    LastCalcErr := CalcErr;
  end;

  if not HasFirst then
    Exit;

  DX := (MaxX - MinX) * 0.1;
  if DX <= 0 then
    DX := 1;

  DY := (MaxY - MinY) * 0.1;
  if DY <= 0 then
    DY := 1;

  { хвосты }
 // FSeriesInitError.AddXY(MaxX + DX * 2, LastInitErr);
 // FSeriesCalcError.AddXY(MaxX + DX * 2, LastCalcErr);

  { показываем видимую область чуть уже, чем все данные серии }
  ChartCoefs.BottomAxis.Automatic := False;
  ChartCoefs.BottomAxis.SetMinMax(MinX - DX, MaxX + DX);

  ChartCoefs.LeftAxis.Automatic := False;
  ChartCoefs.LeftAxis.SetMinMax(MinY- DY/10, MaxY + DY);
end;

procedure TFrameCalibrCoefs.SetCurrentTable(ATable: TCalibrCoefTable);
begin
  FCurrentTable := ATable;
  SortCurrentTableByRange;
  ReindexItems;
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

procedure TFrameCalibrCoefs.SortCurrentTableByRange;
begin
  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) then
    Exit;

  FCurrentTable.Items.Sort(TComparer<TCalibrCoefItem>.Construct(
    function(const Left, Right: TCalibrCoefItem): Integer
    begin
      if Left = Right then
        Exit(0);
      if Left = nil then
        Exit(1);
      if Right = nil then
        Exit(-1);

      Result := CompareValue(Left.QFrom, Right.QFrom);
      if Result = EqualsValue then
        Result := CompareValue(Left.QTo, Right.QTo);
      if Result = EqualsValue then
        Result := CompareValue(Left.RangeArg, Right.RangeArg);
      if Result = EqualsValue then
        Result := Left.OrderNo - Right.OrderNo;
    end));
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
  ResolveValueByType(FCurrentType);  //Определение FValue

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
  if ComboBoxUnitsCoefs.ItemIndex < 0 then
    Exit;

   if FValue <> nil then
    FValue.SetDim(ComboBoxUnitsCoefs.ItemIndex);

  UpdateHeaders;
  UpdateGrid;
end;

procedure TFrameCalibrCoefs.ComboBoxUnitsCorrectionChange(Sender: TObject);
begin
  if ComboBoxUnitsCorrection.ItemIndex < 0 then
    Exit;

  if (FValue.ValueCorrection <> nil) and (FValueCorrection <> nil) then
    FValueCorrection.SetDim(ComboBoxUnitsCorrection.ItemIndex);

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
    Value := FormatFloat('0.00', InitErrorPercent(Item))
  else if GridCoefs.Columns[ACol] = StringColumnCoefCalcError then
    Value := FormatFloat('0.00', CalcErrorPercent(Item))
  else if GridCoefs.Columns[ACol] = StringColumnCoefK then
    Value := FormatFloat('0.000000', Item.K)
  else if GridCoefs.Columns[ACol] = StringColumnCoefb then
    Value := FormatFloat('0.000000', Item.b)
  else if GridCoefs.Columns[ACol] = StringColumnQ1 then
  begin
    if FValueCorrection <> nil then
      Value := FValueCorrection.GetStrNum(Item.QFrom)
    else
      Value := FloatToStr(Item.QFrom);
  end
  else if GridCoefs.Columns[ACol] = StringColumnQ2 then
  begin
    if FValueCorrection <> nil then
      Value := FValueCorrection.GetStrNum(Item.QTo)
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
  if GridCoefs.Columns[ACol] = CheckColumnCoefEnable then
    Item.Enable := Value.AsBoolean
  else if GridCoefs.Columns[ACol] = StringColumnCoefNum then
    Item.OrderNo := Value.AsInteger
  else if GridCoefs.Columns[ACol] = StringColumnCoefValue then
  begin
    if FValue <> nil then
      D := FValue.GetDoubleNum(S)
    else
      D := StrToFloatDef(S, Item.Value);
    Item.Value := D;
  end
  else if GridCoefs.Columns[ACol] = StringColumnCoefArg then
  begin
    if FValueCorrection <> nil then
      D := FValue.GetDoubleNum(S)
    else
      D := StrToFloatDef(S, Item.Arg);
    Item.Arg := D;
  end
  else if GridCoefs.Columns[ACol] = StringColumnCoefK then
    Item.K := StrToFloatDef(S, Item.K)
  else if GridCoefs.Columns[ACol] = StringColumnCoefb then
    Item.b := StrToFloatDef(S, Item.b)
  else if GridCoefs.Columns[ACol] = StringColumnQ1 then
  begin
    if  FValueCorrection<> nil then
      Item.QFrom := FValueCorrection.GetDoubleNum(S)
    else
      Item.QFrom := StrToFloatDef(S, Item.QFrom);
  end
  else if GridCoefs.Columns[ACol] = StringColumnQ2 then
  begin
    if FValueCorrection <> nil then
      Item.QTo := FValueCorrection.GetDoubleNum(S)
    else
      Item.QTo := StrToFloatDef(S, Item.QTo);
  end;

  RecalculateCurrentTable;
  SyncTableToMeterValue;

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
  Item.RangeArg := Item.Arg;
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

  RecalculateCurrentTable;
  SyncTableToMeterValue;

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

procedure TFrameCalibrCoefs.SpeedButtonShowGraphClick(Sender: TObject);
begin

if LayoutGraph.Visible then
     LayoutGraph.Visible:= False
     else
     LayoutGraph.Visible:= True;

end;

function TFrameCalibrCoefs.TryGetSpillageValues(ASpillage: TPointSpillage; out AArg,
  AValue, AQ: Double): Boolean;
var
  Dim: TMeasuredDimension;
  OutputKind: TOutputType;
  RatioBase: Double;
begin
  Result := False;
  AArg := 0;
  AValue := 0;
  AQ := 0;

  if (ASpillage = nil) or (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;

  Dim := TMeasuredDimension(FFlowMeter.Device.MeasuredDimension);
  OutputKind := TOutputType(FFlowMeter.OutputType);

  case FCurrentType of
    cctMeterValueCoef,
    cctDeviceCoefCorrection:
      case Dim of
        mdVolumeFlow:
          begin
            AArg := ASpillage.Coef;
            AQ := ASpillage.EtalonVolumeFlow;
            if OutputKind in [otFrequency, otImpulse] then
            begin
              Result := not SameValue(ASpillage.EtalonVolume, 0, 1E-12);
              if Result then
                AValue := ASpillage.PulseCount / ASpillage.EtalonVolume;
            end
            else
            begin
              AValue := ASpillage.Coef * ASpillage.Error / 100;
              Result := True;
            end;
          end;
        mdVolume:
          begin
            AArg := ASpillage.Coef;
            AQ := ASpillage.EtalonVolume;
            if OutputKind in [otFrequency, otImpulse] then
            begin
              Result := not SameValue(ASpillage.EtalonVolume, 0, 1E-12);
              if Result then
                AValue := ASpillage.PulseCount / ASpillage.EtalonVolume;
            end
            else
            begin
              AValue := ASpillage.Coef * ASpillage.Error / 100;
              Result := True;
            end;
          end;
        mdMassFlow:
          begin
            AArg := ASpillage.Coef;
            AQ := ASpillage.EtalonMassFlow;
            if OutputKind in [otFrequency, otImpulse] then
            begin
              Result := not SameValue(ASpillage.EtalonMass, 0, 1E-12);
              if Result then
                AValue := ASpillage.PulseCount / ASpillage.EtalonMass;
            end
            else
            begin
              AValue := ASpillage.Coef * ASpillage.Error / 100;
              Result := True;
            end;
          end;
        mdMass:
          begin
            AArg := ASpillage.Coef;
            AQ := ASpillage.EtalonMass;
            if OutputKind in [otFrequency, otImpulse] then
            begin
              Result := not SameValue(ASpillage.EtalonMass, 0, 1E-12);
              if Result then
                AValue := ASpillage.PulseCount / ASpillage.EtalonMass;
            end
            else
            begin
              AValue := ASpillage.Coef * ASpillage.Error / 100;
              Result := True;
            end;
          end;
      end;

    cctMeterValueFlowRate,
    cctDeviceFlowRateCorrection,
    cctReference:
      case Dim of
        mdVolumeFlow, mdVolume:
          begin
            AArg := ASpillage.DeviceVolumeFlow;
            AValue := ASpillage.EtalonVolumeFlow;
            AQ := AArg;
            Result := True;
          end;
        mdMassFlow, mdMass:
          begin
            AArg := ASpillage.DeviceMassFlow;
            AValue := ASpillage.EtalonMassFlow;
            AQ := AArg;
            Result := True;
          end;
      end;

    cctMeterValueQuantity,
    cctDeviceQuantityCorrection:
      case Dim of
        mdVolumeFlow, mdVolume:
          begin
            AArg := ASpillage.DeviceVolume;
            AValue := ASpillage.EtalonVolume;
            AQ := AArg;
            Result := True;
          end;
        mdMassFlow, mdMass:
          begin
            AArg := ASpillage.DeviceMass;
            AValue := ASpillage.EtalonMass;
            AQ := AArg;
            Result := True;
          end;
      end;

    cctMeterValueDensity,
    cctDeviceDensityCorrection:
      begin
        AArg := ASpillage.Density;
        AQ := ASpillage.AvgTemperature;
        Result := not SameValue(ASpillage.EtalonMass, 0, 1E-12);
        if Result then
          AValue := ASpillage.EtalonVolume / ASpillage.EtalonMass;
      end;
  end;

  if Result then
  begin
    if SameValue(AArg, 0, 1E-12) then
      Exit(False);

    RatioBase := AValue / AArg;
    Result := (not IsNan(RatioBase)) and (not IsInfinite(RatioBase));
  end;

  Result := Result and (not IsNan(AArg)) and (not IsNan(AValue)) and (not IsNan(AQ)) and
    (not IsInfinite(AArg)) and (not IsInfinite(AValue)) and (not IsInfinite(AQ));
end;

procedure TFrameCalibrCoefs.BuildCurrentTableFromSpillages;
var
  Spillage: TPointSpillage;
  ArgValue: Double;
  RefValue: Double;
  QValue: Double;
  Item: TCalibrCoefItem;
  OrderNo: Integer;
begin
  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) then
    Exit;

  FCurrentTable.Items.Clear;
  OrderNo := 1;

  if FCurrentSpillages = nil then
    Exit;

  for Spillage in FCurrentSpillages do
  begin
    if (Spillage = nil) or (not Spillage.Enabled) then
      Continue;

    if not TryGetSpillageValues(Spillage, ArgValue, RefValue, QValue) then
      Continue;

    Item := BuildCoefFromPoint(ArgValue, RefValue, QValue, OrderNo);
    FCurrentTable.Items.Add(Item);
    Inc(OrderNo);
  end;
end;

procedure TFrameCalibrCoefs.RecalculateCurrentTable;
type
  TCoefSeed = record
    Item: TCalibrCoefItem;
    Ratio: Double;
    Q: Double;
  end;
var
  Seeds: TList<TCoefSeed>;
  Seed: TCoefSeed;
  PrevSeed: TCoefSeed;
  CurrSeed: TCoefSeed;
  Item: TCalibrCoefItem;
  I: Integer;
  KLocal: Double;
  BLocal: Double;
begin
  if (FCurrentTable = nil) or (FCurrentTable.Items = nil) then
    Exit;

  Seeds := TList<TCoefSeed>.Create;
  try
    for Item in FCurrentTable.Items do
    begin
      if Item = nil then
        Continue;

      Item.K := 0;
      Item.b := 0;
      Item.QFrom := 0;
      Item.QTo := 0;

      if (not Item.Enable) or SameValue(Item.Arg, 0, 1E-12) then
        Continue;

      Seed.Item := Item;
      Seed.Ratio := Item.Value / Item.Arg;
      Seed.Q := Item.RangeArg;
      if IsNan(Seed.Ratio) or IsInfinite(Seed.Ratio) or IsNan(Seed.Q) or IsInfinite(Seed.Q) then
        Continue;

      Seeds.Add(Seed);
    end;

    Seeds.Sort(TComparer<TCoefSeed>.Construct(
      function(const Left, Right: TCoefSeed): Integer
      begin
        Result := CompareValue(Left.Q, Right.Q);
        if Result = EqualsValue then
          Result := Left.Item.OrderNo - Right.Item.OrderNo;
      end));

    if Seeds.Count = 0 then
      Exit;

    if Seeds.Count = 1 then
    begin
      Item := Seeds[0].Item;
      Item.QFrom := NegInfinity;
      Item.QTo := Infinity;
      Item.K := 0;
      Item.b := Seeds[0].Ratio;
      SortCurrentTableByRange;
      ReindexItems;
      Exit;
    end;

    for I := 0 to Seeds.Count - 2 do
    begin
      PrevSeed := Seeds[I];
      CurrSeed := Seeds[I + 1];

      if I = 0 then
        PrevSeed.Item.QFrom := NegInfinity
      else
        PrevSeed.Item.QFrom := PrevSeed.Q;
      PrevSeed.Item.QTo := CurrSeed.Q;

      if SameValue(PrevSeed.Q, CurrSeed.Q, 1E-12) then
      begin
        PrevSeed.Item.K := 0;
        PrevSeed.Item.b := PrevSeed.Ratio;
        Continue;
      end;

      KLocal := (PrevSeed.Ratio - CurrSeed.Ratio) / (PrevSeed.Q - CurrSeed.Q);
      BLocal := PrevSeed.Ratio - KLocal * PrevSeed.Q;
      PrevSeed.Item.K := KLocal;
      PrevSeed.Item.b := BLocal;
    end;

    Item := Seeds[Seeds.Count - 1].Item;
    Item.QFrom := Seeds[Seeds.Count - 1].Q;
    Item.QTo := Infinity;
    Item.K := Seeds[Seeds.Count - 2].Item.K;
    Item.b := Seeds[Seeds.Count - 2].Item.b;

    SortCurrentTableByRange;
    ReindexItems;
  finally
    Seeds.Free;
  end;
end;

function TFrameCalibrCoefs.BuildCoefFromPoint(const AArg, AValue, AQ: Double;
  AOrderNo: Integer): TCalibrCoefItem;

begin
  Result := TCalibrCoefItem.Create;
  Result.Name := Format('Точка %d', [AOrderNo]);
  Result.TableID := FCurrentTable.ID;
  Result.OrderNo := AOrderNo;
  Result.Arg := AArg;
  Result.Value := AValue;
  Result.RangeArg := AQ;
  Result.QFrom := 0;
  Result.QTo := 0;
  Result.K := 0;
  Result.b := 0;
  Result.Enable := True;
end;

procedure TFrameCalibrCoefs.SpeedButtonCoefGetPointsClick(Sender: TObject);
begin
  if (FFlowMeter = nil) or (FFlowMeter.Device = nil) then
    Exit;

  if FCurrentTable = nil then
  begin
    SpeedButtonAddTableClick(nil);
    if FCurrentTable = nil then
      Exit;
  end;

  BuildCurrentTableFromSpillages;

  SpeedButtonCoefsRefreshClick(Sender);
end;

end.
