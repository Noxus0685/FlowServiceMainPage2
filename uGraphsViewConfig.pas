unit uGraphsViewConfig;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  System.UITypes;

type
  TGraphLayoutKind = (glSingle, glTwoRows, glTwoColumns, glThreePanels,
    glGrid2x2);
  TGraphAutoScaleMode = (gasWorkingValues, gasAllSeries, gasTargetTolerance);
  TGraphSourceKind = (gskFlow, gskTemperature, gskPressure, gskMass,
    gskVolume, gskCustomMeterValue);
  TGraphSeriesOwnerKind = (gsokEtalon, gsokDevice, gsokWorkTable, gsokSystem);

  { Configuration is deliberately independent of FMX controls and runtime samples. }
  TGraphSeriesConfig = class
  public
    GraphIndex: Integer;
    OwnerKind: TGraphSeriesOwnerKind;
    SourceKind: TGraphSourceKind;
    ChannelUUID: string;
    MeterValueKey: string;
    Caption: string;
    Color: TAlphaColor;
    Visible: Boolean;
    Valid: Boolean;
    constructor Create;
    function SourceIdentity: string;
  end;

  TGraphPanelConfig = class
  private
    FSeries: TObjectList<TGraphSeriesConfig>;
  public
    Title: string;
    ShowTargetLine: Boolean;
    ShowToleranceLines: Boolean;
    ShowToleranceInLegend: Boolean;
    DefaultAssignmentSuppressed: Boolean;
    ShowLegend: Boolean;
    VisibleDurationSec: Integer;
    AutoScaleMode: TGraphAutoScaleMode;
    constructor Create(const ATitle: string);
    destructor Destroy; override;
    function FindSeries(const ASeries: TGraphSeriesConfig): TGraphSeriesConfig;
    function AddSeries(const ASeries: TGraphSeriesConfig): Boolean;
    property Series: TObjectList<TGraphSeriesConfig> read FSeries;
  end;

  TGraphsViewConfig = class
  private
    FPanels: TObjectList<TGraphPanelConfig>;
  public
    GraphCount: Integer;
    LayoutKind: TGraphLayoutKind;
    ShowLegend: Boolean;
    SettingsPanelVisible: Boolean;
    AutoGrid: Boolean;
    PreferredColumnCount: Integer;
    MinimumGraphWidth: Single;
    MinimumGraphHeight: Single;
    { One time window belongs to the workspace, not to an individual panel. }
    VisibleDurationSec: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure EnsurePanelCount(const ACount: Integer);
    procedure DeletePanel(const AIndex: Integer);
    property Panels: TObjectList<TGraphPanelConfig> read FPanels;
  end;

implementation

constructor TGraphSeriesConfig.Create;
begin
  inherited Create;
  Color := TAlphaColors.Blue;
  Visible := True;
  Valid := True;
end;

function TGraphSeriesConfig.SourceIdentity: string;
begin
  Result := Format('%d|%d|%d|%s|%s', [GraphIndex, Ord(OwnerKind), Ord(SourceKind),
    LowerCase(Trim(ChannelUUID)), LowerCase(Trim(MeterValueKey))]);
end;

constructor TGraphPanelConfig.Create(const ATitle: string);
begin
  inherited Create;
  Title := ATitle;
  ShowTargetLine := True;
  ShowToleranceLines := True;
  ShowToleranceInLegend := True;
  DefaultAssignmentSuppressed := False;
  ShowLegend := True;
  VisibleDurationSec := 0;
  AutoScaleMode := gasWorkingValues;
  FSeries := TObjectList<TGraphSeriesConfig>.Create(True);
end;

procedure TGraphsViewConfig.DeletePanel(const AIndex: Integer);
var
  I: Integer;
begin
  if (FPanels.Count <= 1) or (AIndex < 0) or (AIndex >= FPanels.Count) then
    Exit;
  FPanels.Delete(AIndex);
  for I := AIndex to FPanels.Count - 1 do
    FPanels[I].Title := Format('График %d', [I + 1]);
  GraphCount := FPanels.Count;
end;

destructor TGraphPanelConfig.Destroy;
begin
  FSeries.Free;
  inherited;
end;

function TGraphPanelConfig.FindSeries(
  const ASeries: TGraphSeriesConfig): TGraphSeriesConfig;
var
  Item: TGraphSeriesConfig;
begin
  Result := nil;
  if ASeries = nil then
    Exit;
  for Item in FSeries do
    if SameText(Item.SourceIdentity, ASeries.SourceIdentity) then
      Exit(Item);
end;

function TGraphPanelConfig.AddSeries(
  const ASeries: TGraphSeriesConfig): Boolean;
var
  Existing: TGraphSeriesConfig;
begin
  Result := False;
  if ASeries = nil then
    Exit;
  Existing := FindSeries(ASeries);
  if Existing <> nil then
  begin
    Existing.Visible := True;
    Exit;
  end;
  FSeries.Add(ASeries);
  Result := True;
end;

constructor TGraphsViewConfig.Create;
begin
  inherited Create;
  FPanels := TObjectList<TGraphPanelConfig>.Create(True);
  Reset;
end;

destructor TGraphsViewConfig.Destroy;
begin
  FPanels.Free;
  inherited;
end;

procedure TGraphsViewConfig.EnsurePanelCount(const ACount: Integer);
var
  Wanted: Integer;
begin
  Wanted := ACount;
  if Wanted < 1 then Wanted := 1;
  while FPanels.Count < Wanted do
    FPanels.Add(TGraphPanelConfig.Create(Format('График %d', [FPanels.Count + 1])));
  GraphCount := Wanted;
end;

procedure TGraphsViewConfig.Reset;
begin
  GraphCount := 2;
  LayoutKind := glTwoRows;
  ShowLegend := True;
  SettingsPanelVisible := True;
  VisibleDurationSec := 60;
  AutoGrid := True;
  PreferredColumnCount := 0;
  MinimumGraphWidth := 420;
  MinimumGraphHeight := 260;
  FPanels.Clear;
  EnsurePanelCount(GraphCount);
  { The initial two-panel layout is etalons first and devices second.  These
    defaults are set only while creating/resetting the configuration; source
    refreshes never overwrite a user's visibility choices. }
  FPanels[0].ShowTargetLine := True;
  FPanels[0].ShowToleranceLines := True;
  FPanels[1].ShowTargetLine := True;
  FPanels[1].ShowToleranceLines := True;
end;

end.
