unit uGridStabilityController;

interface

uses
  FMX.Grid,
  System.Classes,
  System.Generics.Collections;

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
    FGrid: TGrid;
    FFormName: string;
    FColumns: TDictionary<string, TGridColumnSnapshot>;
    FGridWidth: Single;
    FViewportWidth: Single;
    FHasSnapshot: Boolean;
    FStructuralSignature: string;
    function BuildStructuralSignature: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Attach(AGrid: TGrid; const AFormName: string);
    procedure Snapshot(const AContext: string);
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
  FColumns.Free;
  inherited;
end;

procedure TGridStabilityController.Attach(AGrid: TGrid;
  const AFormName: string);
begin
  FGrid := AGrid;
  FFormName := AFormName;
  FColumns.Clear;
  FHasSnapshot := False;
  FStructuralSignature := BuildStructuralSignature;
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
