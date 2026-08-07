unit uGridStabilityController;

interface

uses
  FMX.Grid,
  System.Classes,
  System.Generics.Collections,
  uGridLayoutManager;

type
  TGridColumnSnapshot = record
    Name: string;
    Index: Integer;
    Width: Single;
    Visible: Boolean;
  end;

  { Observer for FMX grids. Snapshot never writes to a grid and never asks its
    model to recalculate layout. Call it at meaningful update boundaries. }
  TGridStabilityController = class(TComponent)
  private
    FGrid: TCustomGrid;
    FWidthState: TGridLayoutState;
    FFormName: string;
    FColumns: TDictionary<string, TGridColumnSnapshot>;
    FGridWidth: Single;
    FViewportWidth: Single;
    FHasSnapshot: Boolean;
    FStructuralSignature: string;
    function BuildStructuralSignature: string;
  protected
    { Drops width-control references before the observed grid is destroyed. }
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Attaches diagnostics and optional manual-only width control to one grid. }
    procedure Attach(AGrid: TCustomGrid; const AFormName: string;
      const AEnableWidthControl: Boolean = True);
    { Records the current geometry and registers newly created named columns. }
    procedure Snapshot(const AContext: string);
    { Returns True when the grid column identity or order has changed. }
    function StructureChanged: Boolean;
    property StructuralSignature: string read FStructuralSignature;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  uDebugLog;

const
  CGridWidthEpsilon = 0.01;

constructor TGridStabilityController.Create(AOwner: TComponent);
begin
  inherited;
  FColumns := TDictionary<string, TGridColumnSnapshot>.Create;
end;

destructor TGridStabilityController.Destroy;
begin
  if FGrid <> nil then
    FGrid.RemoveFreeNotification(Self);
  FWidthState.Free;
  FColumns.Free;
  inherited;
end;

procedure TGridStabilityController.Attach(AGrid: TCustomGrid;
  const AFormName: string; const AEnableWidthControl: Boolean);
begin
  if FGrid <> nil then
    FGrid.RemoveFreeNotification(Self);
  FreeAndNil(FWidthState);
  FGrid := AGrid;
  FFormName := AFormName;
  if FGrid <> nil then
    FGrid.FreeNotification(Self);
  FColumns.Clear;
  FHasSnapshot := False;
  FStructuralSignature := BuildStructuralSignature;
  if AEnableWidthControl and (FGrid <> nil) then
  begin
    FWidthState := TGridLayoutState.Create;
    FWidthState.ConfigureWidthControl(FGrid,
      AFormName + '.' + FGrid.Name);
    FWidthState.RegisterExistingColumns;
  end;
end;

procedure TGridStabilityController.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FGrid) then
  begin
    if FWidthState <> nil then
      FWidthState.Detach(False);
    FGrid := nil;
  end;
  inherited;
end;

function TGridStabilityController.BuildStructuralSignature: string;
var
  I: Integer;
  Column: TColumn;
begin
  Result := '';
  if FGrid = nil then
    Exit;
  for I := 0 to FGrid.ColumnCount - 1 do
  begin
    Column := FGrid.Columns[I];
    Result := Result + IntToStr(Length(Column.Name)) + ':' + Column.Name + '|' +
      Column.ClassName + '|' + IntToStr(Column.Index) + #10;
  end;
end;

function TGridStabilityController.StructureChanged: Boolean;
begin
  Result := BuildStructuralSignature <> FStructuralSignature;
end;

procedure TGridStabilityController.Snapshot(const AContext: string);
var
  I: Integer;
  Column: TColumn;
  Current, Previous: TGridColumnSnapshot;
  CurrentGridWidth, CurrentViewportWidth: Single;
  ThreadNumber: Cardinal;
begin
  if FGrid = nil then
    Exit;

  if FWidthState <> nil then
    FWidthState.RegisterExistingColumns;
  ThreadNumber := TThread.CurrentThread.ThreadID;
  CurrentGridWidth := FGrid.Width;
  CurrentViewportWidth := FGrid.ViewportSize.Width;
  for I := 0 to FGrid.ColumnCount - 1 do
  begin
    Column := FGrid.Columns[I];
    Current.Name := Column.Name;
    Current.Index := Column.Index;
    Current.Width := Column.Width;
    Current.Visible := Column.Visible;
    if FHasSnapshot and FColumns.TryGetValue(Current.Name, Previous) and
       ((Abs(Previous.Width - Current.Width) > CGridWidthEpsilon) or
        (Previous.Index <> Current.Index) or
        (Previous.Visible <> Current.Visible)) then
      DebugLog(Format('GridStability Form="%s" Grid="%s" Column="%s" Width=%.4f->%.4f Index=%d->%d Visible=%s->%s Context="%s" UIThread=%d',
        [FFormName, FGrid.Name, Current.Name, Previous.Width, Current.Width,
         Previous.Index, Current.Index, BoolToStr(Previous.Visible, True),
         BoolToStr(Current.Visible, True), AContext, ThreadNumber]));
    FColumns.AddOrSetValue(Current.Name, Current);
  end;

  if FHasSnapshot and
     ((Abs(FGridWidth - CurrentGridWidth) > CGridWidthEpsilon) or
      (Abs(FViewportWidth - CurrentViewportWidth) > CGridWidthEpsilon)) then
    DebugLog(Format('GridStability Form="%s" Grid="%s" Column="<grid>" Grid.Width=%.4f->%.4f Viewport.Width=%.4f->%.4f Context="%s" UIThread=%d',
      [FFormName, FGrid.Name, FGridWidth, CurrentGridWidth, FViewportWidth,
       CurrentViewportWidth, AContext, ThreadNumber]));
  FGridWidth := CurrentGridWidth;
  FViewportWidth := CurrentViewportWidth;
  FStructuralSignature := BuildStructuralSignature;
  FHasSnapshot := True;
end;

end.
