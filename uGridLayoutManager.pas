unit uGridLayoutManager;

interface

uses
  FMX.Grid,
  System.Classes,
  System.Generics.Collections,
  System.SysUtils;

type
  { A declarative column description.  Key is the persistent identity; it must
    not be derived from the caption or the current visual index. }
  TGridColumnDefinition = class
  public
    Key: string;
    Header: string;
    ColumnClass: TClass;
    InitialWidth: Single;
    ReadOnly: Boolean;
    Visible: Boolean;
    ExistingColumn: TColumn;
    constructor Create(const AKey, AHeader: string; AColumnClass: TClass;
      const AInitialWidth: Single; const AReadOnly, AVisible: Boolean;
      AExistingColumn: TColumn = nil);
  end;

  TGridColumnDefinitions = TObjectList<TGridColumnDefinition>;
  TGridColumnFactory = reference to function(AOwner: TComponent;
    ADefinition: TGridColumnDefinition): TColumn;

  { One state object is owned by one grid instance. }
  TGridLayoutState = class
  private
    FLastSignature: string;
    FWidths: TDictionary<string, Single>;
    FColumns: TDictionary<string, TColumn>;
    FApplying: Boolean;
    FApplyCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property LastSignature: string read FLastSignature;
    property ApplyCount: Integer read FApplyCount;
  end;

  TGridLayoutManager = class
  public
    class function BuildSignature(const ADefinitions: TGridColumnDefinitions): string; static;
    class procedure CaptureWidths(AState: TGridLayoutState); static;
    { Changes the FMX grid row count without allowing its layout pass to alter
      column widths.  AForceRefresh recreates rows when their count is unchanged. }
    class procedure SetRowCount(AGrid: TGrid; const ARowCount: Integer;
      const AForceRefresh: Boolean = False); static;
    class function Apply(AGrid: TGrid; AState: TGridLayoutState;
      const ADefinitions: TGridColumnDefinitions;
      const AFactory: TGridColumnFactory;
      const AStructureContext: string = ''): Boolean; static;
  end;

implementation

uses
  System.Math,
  uDebugLog;

const
  CWidthEpsilon = 0.01;

constructor TGridColumnDefinition.Create(const AKey, AHeader: string;
  AColumnClass: TClass; const AInitialWidth: Single; const AReadOnly,
  AVisible: Boolean; AExistingColumn: TColumn);
begin
  inherited Create;
  Key := AKey;
  Header := AHeader;
  ColumnClass := AColumnClass;
  InitialWidth := AInitialWidth;
  ReadOnly := AReadOnly;
  Visible := AVisible;
  ExistingColumn := AExistingColumn;
end;

constructor TGridLayoutState.Create;
begin
  inherited Create;
  FWidths := TDictionary<string, Single>.Create;
  FColumns := TDictionary<string, TColumn>.Create;
end;

destructor TGridLayoutState.Destroy;
begin
  FColumns.Free;
  FWidths.Free;
  inherited;
end;

class function TGridLayoutManager.BuildSignature(
  const ADefinitions: TGridColumnDefinitions): string;
var
  Definition: TGridColumnDefinition;
begin
  Result := '';
  for Definition in ADefinitions do
    Result := Result + IntToStr(Length(Definition.Key)) + ':' + Definition.Key + '|' +
      IntToStr(Length(Definition.Header)) + ':' + Definition.Header + '|' +
      Definition.ColumnClass.ClassName + '|' + BoolToStr(Definition.ReadOnly, True) +
      '|' + BoolToStr(Definition.Visible, True) + #10;
end;

class procedure TGridLayoutManager.CaptureWidths(AState: TGridLayoutState);
var
  Pair: TPair<string, TColumn>;
begin
  if AState = nil then
    Exit;

  { Capture only at an explicit, trusted boundary.  In particular, never feed
    widths produced by the FMX layout pass after EndUpdate back into state. }
  for Pair in AState.FColumns do
    if Pair.Value <> nil then
      AState.FWidths.AddOrSetValue(Pair.Key, Pair.Value.Width);
end;

class procedure TGridLayoutManager.SetRowCount(AGrid: TGrid;
  const ARowCount: Integer; const AForceRefresh: Boolean);
var
  Columns: TArray<TColumn>;
  Widths: TArray<Single>;
  I, NewRowCount: Integer;
begin
  if AGrid = nil then
    Exit;

  NewRowCount := Max(0, ARowCount);
  { An empty grid has no rows to recreate.  Avoid even an empty
    BeginUpdate/EndUpdate cycle during the first tab activation. }
  if (AGrid.RowCount = 0) and (NewRowCount = 0) then
  begin
    AGrid.Repaint;
    Exit;
  end;
  if (AGrid.RowCount = NewRowCount) and not AForceRefresh then
  begin
    AGrid.Repaint;
    Exit;
  end;

  SetLength(Columns, AGrid.ColumnCount);
  SetLength(Widths, AGrid.ColumnCount);
  for I := 0 to AGrid.ColumnCount - 1 do
  begin
    Columns[I] := AGrid.Columns[I];
    Widths[I] := Columns[I].Width;
  end;

  AGrid.BeginUpdate;
  try
    if AForceRefresh and (AGrid.RowCount <> 0) then
      AGrid.RowCount := 0;
    if AGrid.RowCount <> NewRowCount then
      AGrid.RowCount := NewRowCount;
  finally
    AGrid.EndUpdate;
  end;

  { EndUpdate can rebuild the FMX presentation and change widths.  Restore the
    exact column objects only after that rebuild has completed. }
  for I := 0 to High(Columns) do
    if (Columns[I] <> nil) and
       (Abs(Columns[I].Width - Widths[I]) >= CWidthEpsilon) then
      Columns[I].Width := Widths[I];

  AGrid.Repaint;
end;

class function TGridLayoutManager.Apply(AGrid: TGrid;
  AState: TGridLayoutState; const ADefinitions: TGridColumnDefinitions;
  const AFactory: TGridColumnFactory; const AStructureContext: string): Boolean;
var
  Signature, Key: string;
  Definition: TGridColumnDefinition;
  Column: TColumn;
  SavedWidth: Single;
  OldColumns: TArray<TPair<string, TColumn>>;
  Pair: TPair<string, TColumn>;
  IsNewColumn: Boolean;
  DesiredIndex: Integer;

  function PrintableSignature(const AValue: string): string;
  begin
    Result := StringReplace(AValue, #13, '', [rfReplaceAll]);
    Result := StringReplace(Result, #10, ';', [rfReplaceAll]);
  end;

  function OldColumnForKey(const AKey: string): TColumn;
  var
    OldPair: TPair<string, TColumn>;
  begin
    Result := nil;
    for OldPair in OldColumns do
      if SameText(OldPair.Key, AKey) then
        Exit(OldPair.Value);
  end;

  function DefinitionContainsKey(const AKey: string): Boolean;
  var
    Item: TGridColumnDefinition;
  begin
    Result := False;
    for Item in ADefinitions do
      if SameText(Item.Key, AKey) then
        Exit(True);
  end;

  procedure LogColumn(const AStage, AKey: string; AColumn: TColumn;
    const AHasSavedWidth: Boolean; const ASavedWidth: Single);
  var
    WidthText, SavedText, IndexText: string;
  begin
    if AColumn = nil then
    begin
      WidthText := '<not-created>';
      IndexText := '<not-created>';
    end
    else
    begin
      WidthText := Format('%.4f', [AColumn.Width]);
      IndexText := IntToStr(AColumn.Index);
    end;
    if AHasSavedWidth then
      SavedText := Format('%.4f', [ASavedWidth])
    else
      SavedText := '<none>';
    DebugLog(Format('GridLayout Apply #%d %s key="%s" Width=%s saved=%s Index=%s',
      [AState.FApplyCount, AStage, AKey, WidthText, SavedText, IndexText]));
  end;
begin
  if (AGrid = nil) or (AState = nil) or (ADefinitions = nil) then
    Exit(False);

  Inc(AState.FApplyCount);
  Signature := IntToStr(Length(AStructureContext)) + ':' + AStructureContext + #10 +
    BuildSignature(ADefinitions);
  DebugLog(Format('GridLayout Apply #%d context="%s" old="%s" new="%s"',
    [AState.FApplyCount, AStructureContext,
     PrintableSignature(AState.FLastSignature), PrintableSignature(Signature)]));
  if AState.FApplying then
  begin
    DebugLog(Format('GridLayout Apply #%d rejected: reentrant layout',
      [AState.FApplyCount]));
    Exit(False);
  end;
  { This guard is deliberately before every observable FMX mutation. }
  if Signature = AState.FLastSignature then
  begin
    DebugLog(Format('GridLayout Apply #%d skipped: signature unchanged',
      [AState.FApplyCount]));
    Exit(False);
  end;

  AState.FApplying := True;
  try
    { A changed signature confirms that a structural rebuild is about to run,
      so the current user-visible widths form a trustworthy snapshot. }
    CaptureWidths(AState);
    OldColumns := AState.FColumns.ToArray;

    for Definition in ADefinitions do
    begin
      Column := Definition.ExistingColumn;
      if Column = nil then
        Column := OldColumnForKey(Definition.Key);
      LogColumn('before BeginUpdate', Definition.Key, Column,
        AState.FWidths.TryGetValue(Definition.Key, SavedWidth), SavedWidth);
    end;

    AGrid.BeginUpdate;
    try
      { Only obsolete factory-created columns are owned and freed here. }
      for Pair in OldColumns do
        if (Pair.Value <> nil) and (Pair.Value.Owner = AGrid) and
           not DefinitionContainsKey(Pair.Key) then
          Pair.Value.Free;
      AState.FColumns.Clear;

      DesiredIndex := 0;
      for Definition in ADefinitions do
      begin
        Key := Definition.Key;
        Column := Definition.ExistingColumn;
        if Column = nil then
          Column := OldColumnForKey(Key);
        IsNewColumn := Column = nil;
        if (not IsNewColumn) and (Definition.ExistingColumn = nil) and
           (Column.ClassType <> Definition.ColumnClass) then
        begin
          if Column.Owner = AGrid then
            Column.Free;
          Column := nil;
          IsNewColumn := True;
        end;
        if IsNewColumn then
        begin
          if not Assigned(AFactory) then
            raise EArgumentNilException.Create('AFactory');
          Column := AFactory(AGrid, Definition);
          if Column = nil then
            raise EInvalidOperation.CreateFmt('Factory did not create column "%s"', [Key]);
          if Column.Parent <> AGrid then
            Column.Parent := AGrid;
          Column.Stored := False;
        end;
        LogColumn('after Parent', Key, Column,
          AState.FWidths.TryGetValue(Key, SavedWidth), SavedWidth);

        if Column.Header <> Definition.Header then
          Column.Header := Definition.Header;
        if Column.ReadOnly <> Definition.ReadOnly then
          Column.ReadOnly := Definition.ReadOnly;
        if Column.Visible <> Definition.Visible then
          Column.Visible := Definition.Visible;

        { During a real rebuild, restore a trusted pre-rebuild width if FMX
          changed an existing column while applying Parent/Index.  A replacement
          column uses the same stable-key snapshot, or its declared initial
          width when that key has never existed. }
        if AState.FWidths.TryGetValue(Key, SavedWidth) then
        begin
          if Abs(Column.Width - SavedWidth) >= CWidthEpsilon then
            Column.Width := SavedWidth;
        end;
        if IsNewColumn and not AState.FWidths.ContainsKey(Key) and
           (Abs(Column.Width - Definition.InitialWidth) >= CWidthEpsilon) then
          Column.Width := Definition.InitialWidth;
        LogColumn('after Width', Key, Column,
          AState.FWidths.TryGetValue(Key, SavedWidth), SavedWidth);

        if Column.Index <> DesiredIndex then
          Column.Index := DesiredIndex;
        LogColumn('after Index', Key, Column,
          AState.FWidths.TryGetValue(Key, SavedWidth), SavedWidth);
        AState.FColumns.AddOrSetValue(Key, Column);
        Inc(DesiredIndex);
      end;
    finally
      AGrid.EndUpdate;
    end;
    for Definition in ADefinitions do
    begin
      Column := AState.FColumns[Definition.Key];
      LogColumn('after EndUpdate', Definition.Key, Column,
        AState.FWidths.TryGetValue(Definition.Key, SavedWidth), SavedWidth);
    end;

    AState.FLastSignature := Signature;
    Result := True;
  finally
    AState.FApplying := False;
  end;
end;

end.
