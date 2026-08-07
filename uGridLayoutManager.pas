unit uGridLayoutManager;

interface

uses
  FMX.Grid,
  System.Classes,
  System.Generics.Collections,
  System.IniFiles,
  System.IOUtils,
  System.SysUtils,
  System.Types;

const
  C_DYNAMIC_COLUMN_WIDTH = 125.0;
  C_MIN_COLUMN_WIDTH = 24.0;
  C_MAX_COLUMN_WIDTH = 1200.0;

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
    FApprovedWidths: TDictionary<string, Single>;
    FColumns: TDictionary<string, TColumn>;
    FColumnKeys: TDictionary<TColumn, string>;
    FPreviousResizeHandlers: TDictionary<TColumn, TNotifyEvent>;
    FApplying: Boolean;
    FApplyCount: Integer;
    FManualResizeActive: Boolean;
    FRestoringWidth: Boolean;
    FApplyingInitialWidths: Boolean;
    FSyncingPresentation: Boolean;
    FTrackedColumn: TColumn;
    FGrid: TGrid;
    FGridKey: string;
    function BuildStorageKey(const AColumnKey: string): string;
    function LoadApprovedWidth(const AColumnKey: string;
      out AWidth: Single): Boolean;
    procedure SaveApprovedWidth(const AColumnKey: string;
      const AWidth: Single);
    function ValidateColumnWidth(const AWidth: Single): Single;
    { Returns True only while the user is dragging this column divider. }
    function IsUserColumnResize(AColumn: TColumn): Boolean;
    procedure ColumnResizeHandler(Sender: TObject);
    { Rebuilds FMX grid presentation geometry after an accepted column width. }
    procedure RefreshGridPresentation;
    procedure RestoreApprovedColumnWidth(AColumn: TColumn;
      const AColumnKey, AContext: string);
    procedure RegisterColumn(const AColumnKey: string; AColumn: TColumn);
    procedure UnregisterColumn(AColumn: TColumn);
    procedure ApplyInitialWidth(const AColumnKey: string; AColumn: TColumn;
      const AInitialWidth: Single);
  public
    constructor Create;
    destructor Destroy; override;
    { Connects manual-only width control to one grid and persistent key. }
    procedure ConfigureWidthControl(AGrid: TGrid; const AGridKey: string);
    { Starts manual resize only when the left mouse button hits a header divider. }
    procedure BeginManualColumnResize(AGrid: TGrid; const X, Y: Single);
    { Registers all existing named columns of the configured grid. }
    procedure RegisterExistingColumns;
    { Persists the final approved width after the active mouse drag has ended. }
    function FinishPendingManualResize: Boolean;
    { Confirms and persists a width only after the tracked drag ends. }
    function EndManualColumnResize: Boolean;
    property LastSignature: string read FLastSignature;
    property ApplyCount: Integer read FApplyCount;
  end;

  TGridLayoutManager = class
  public
    class function BuildSignature(const ADefinitions: TGridColumnDefinitions): string; static;
    { Changes the FMX grid row count without allowing its layout pass to alter
      column widths.  AForceRefresh recreates rows when their count is unchanged. }
    class procedure SetRowCount(AGrid: TCustomGrid; const ARowCount: Integer;
      const AForceRefresh: Boolean = False); static;
    class function Apply(AGrid: TGrid; AState: TGridLayoutState;
      const ADefinitions: TGridColumnDefinitions;
      const AFactory: TGridColumnFactory;
      const AStructureContext: string = ''): Boolean; static;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
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
  FApprovedWidths := TDictionary<string, Single>.Create;
  FColumns := TDictionary<string, TColumn>.Create;
  FColumnKeys := TDictionary<TColumn, string>.Create;
  FPreviousResizeHandlers := TDictionary<TColumn, TNotifyEvent>.Create;
end;

destructor TGridLayoutState.Destroy;
var
  Pair: TPair<TColumn, TNotifyEvent>;
begin
  for Pair in FPreviousResizeHandlers do
    if Pair.Key <> nil then
      Pair.Key.OnResize := Pair.Value;
  FPreviousResizeHandlers.Free;
  FColumnKeys.Free;
  FColumns.Free;
  FApprovedWidths.Free;
  inherited;
end;

procedure TGridLayoutState.ConfigureWidthControl(AGrid: TGrid;
  const AGridKey: string);
begin
  FGrid := AGrid;
  FGridKey := AGridKey;
  DebugLog(Format('GridWidthControl configured Grid="%s"', [FGridKey]));
end;

function TGridLayoutState.BuildStorageKey(const AColumnKey: string): string;
begin
  Result := FGridKey + '.' + AColumnKey;
end;

function TGridLayoutState.ValidateColumnWidth(const AWidth: Single): Single;
begin
  Result := EnsureRange(AWidth, C_MIN_COLUMN_WIDTH, C_MAX_COLUMN_WIDTH);
end;

function TGridLayoutState.LoadApprovedWidth(const AColumnKey: string;
  out AWidth: Single): Boolean;
var
  Ini: TIniFile;
  StoredValue: Double;
begin
  Result := False;
  AWidth := 0;
  if (FGridKey = '') or (AColumnKey = '') then
    Exit;
  Ini := TIniFile.Create(TPath.Combine(TPath.GetDocumentsPath,
    'FlowServiceGridWidths.ini'));
  try
    if not Ini.ValueExists('GridWidths', BuildStorageKey(AColumnKey)) then
      Exit;
    StoredValue := Ini.ReadFloat('GridWidths', BuildStorageKey(AColumnKey), 0);
    Result := (StoredValue >= C_MIN_COLUMN_WIDTH) and
      (StoredValue <= C_MAX_COLUMN_WIDTH);
    if Result then
      AWidth := StoredValue
    else
      DebugLog(Format(
        'GridWidthControl rejected stored width Grid="%s" ColumnKey="%s" Width=%.4f',
        [FGridKey, AColumnKey, StoredValue]));
  finally
    Ini.Free;
  end;
end;

procedure TGridLayoutState.SaveApprovedWidth(const AColumnKey: string;
  const AWidth: Single);
var
  Ini: TIniFile;
begin
  if (FGridKey = '') or (AColumnKey = '') then
    Exit;
  Ini := TIniFile.Create(TPath.Combine(TPath.GetDocumentsPath,
    'FlowServiceGridWidths.ini'));
  try
    Ini.WriteFloat('GridWidths', BuildStorageKey(AColumnKey), AWidth);
  finally
    Ini.Free;
  end;
end;

procedure TGridLayoutState.ApplyInitialWidth(const AColumnKey: string;
  AColumn: TColumn; const AInitialWidth: Single);
var
  ApprovedWidth: Single;
begin
  if (AColumn = nil) or (AColumnKey = '') then
    Exit;
  if not FApprovedWidths.TryGetValue(AColumnKey, ApprovedWidth) then
  begin
    if not LoadApprovedWidth(AColumnKey, ApprovedWidth) then
      ApprovedWidth := ValidateColumnWidth(AInitialWidth);
    FApprovedWidths.AddOrSetValue(AColumnKey, ApprovedWidth);
  end;

  FApplyingInitialWidths := True;
  try
    if not SameValue(AColumn.Width, ApprovedWidth, CWidthEpsilon) then
      AColumn.Width := ApprovedWidth;
  finally
    FApplyingInitialWidths := False;
  end;
end;

procedure TGridLayoutState.RegisterColumn(const AColumnKey: string;
  AColumn: TColumn);
begin
  if (AColumn = nil) or (AColumnKey = '') then
    Exit;
  FColumns.AddOrSetValue(AColumnKey, AColumn);
  FColumnKeys.AddOrSetValue(AColumn, AColumnKey);
  if not FPreviousResizeHandlers.ContainsKey(AColumn) then
  begin
    FPreviousResizeHandlers.Add(AColumn, AColumn.OnResize);
    AColumn.OnResize := ColumnResizeHandler;
  end;
end;

procedure TGridLayoutState.UnregisterColumn(AColumn: TColumn);
var
  PreviousHandler: TNotifyEvent;
  ColumnKey: string;
begin
  if AColumn = nil then
    Exit;
  if FPreviousResizeHandlers.TryGetValue(AColumn, PreviousHandler) then
  begin
    AColumn.OnResize := PreviousHandler;
    FPreviousResizeHandlers.Remove(AColumn);
  end;
  if FColumnKeys.TryGetValue(AColumn, ColumnKey) then
  begin
    FColumnKeys.Remove(AColumn);
    FColumns.Remove(ColumnKey);
  end;
  if FTrackedColumn = AColumn then
  begin
    FTrackedColumn := nil;
    FManualResizeActive := False;
  end;
end;

procedure TGridLayoutState.RestoreApprovedColumnWidth(AColumn: TColumn;
  const AColumnKey, AContext: string);
var
  ApprovedWidth, RejectedWidth: Single;
begin
  if (AColumn = nil) or
     not FApprovedWidths.TryGetValue(AColumnKey, ApprovedWidth) then
    Exit;
  if SameValue(AColumn.Width, ApprovedWidth, CWidthEpsilon) then
    Exit;

  RejectedWidth := AColumn.Width;
  FRestoringWidth := True;
  try
    AColumn.Width := ApprovedWidth;
  finally
    FRestoringWidth := False;
  end;
  RefreshGridPresentation;
  DebugLog(Format(
    'GridWidthControl restored Grid="%s" ColumnKey="%s" Rejected=%.4f Approved=%.4f Context="%s"',
    [FGridKey, AColumnKey, RejectedWidth, ApprovedWidth, AContext]));
end;

function TGridLayoutState.IsUserColumnResize(
  AColumn: TColumn): Boolean;
begin
  Result :=
    (AColumn <> nil) and
    (FGrid <> nil) and
    not FApplying and
    not FRestoringWidth and
    not FApplyingInitialWidths and
    not FSyncingPresentation and
    FColumnKeys.ContainsKey(AColumn) and
    (GetAsyncKeyState(VK_LBUTTON) < 0);
end;

procedure TGridLayoutState.RefreshGridPresentation;
begin
  if (FGrid = nil) or FSyncingPresentation then
    Exit;

  FSyncingPresentation := True;
  try
    FGrid.Model.ContentChanged;
    FGrid.Repaint;
  finally
    FSyncingPresentation := False;
  end;
end;

procedure TGridLayoutState.ColumnResizeHandler(Sender: TObject);
var
  Column: TColumn;
  ColumnKey: string;
  PreviousHandler: TNotifyEvent;
  ApprovedWidth: Single;
begin
  if FRestoringWidth or FApplyingInitialWidths or FApplying or
     FSyncingPresentation then
    Exit;
  if not (Sender is TColumn) then
    Exit;
  Column := TColumn(Sender);
  if FPreviousResizeHandlers.TryGetValue(Column, PreviousHandler) and
     Assigned(PreviousHandler) then
    PreviousHandler(Sender);
  if not FColumnKeys.TryGetValue(Column, ColumnKey) then
    Exit;

  if IsUserColumnResize(Column) then
  begin
    FManualResizeActive := True;
    FTrackedColumn := Column;
    ApprovedWidth := ValidateColumnWidth(Column.Width);
    FApprovedWidths.AddOrSetValue(ColumnKey, ApprovedWidth);
    SaveApprovedWidth(ColumnKey, ApprovedWidth);
    if not SameValue(Column.Width, ApprovedWidth, CWidthEpsilon) then
    begin
      FRestoringWidth := True;
      try
        Column.Width := ApprovedWidth;
      finally
        FRestoringWidth := False;
      end;
    end;
    RefreshGridPresentation;
    DebugLog(Format(
      'GridWidthControl manual resize Grid="%s" Column="%s" Width=%.4f',
      [FGridKey, ColumnKey, ApprovedWidth]));
  end
  else
    RestoreApprovedColumnWidth(Column, ColumnKey, 'OnResize');
end;

procedure TGridLayoutState.BeginManualColumnResize(AGrid: TGrid;
  const X, Y: Single);
var
  I: Integer;
  Column: TColumn;
  DividerX: Single;
begin
  FManualResizeActive := False;
  FTrackedColumn := nil;
  if (AGrid = nil) or (AGrid <> FGrid) or (Y < 0) or
     (Y > AGrid.RowHeight) then
    Exit;

  for I := 0 to AGrid.ColumnCount - 1 do
  begin
    Column := AGrid.Columns[I];
    if (Column = nil) or not Column.Visible or
       not FColumnKeys.ContainsKey(Column) then
      Continue;
    DividerX := Column.Position.X + Column.Width;
    if Abs(X - DividerX) <= 5.0 then
    begin
      FTrackedColumn := Column;
      FManualResizeActive := True;
      DebugLog(Format(
        'GridWidthControl manual begin Grid="%s" Column="%s" Width=%.4f',
        [FGridKey, FColumnKeys[Column], Column.Width]));
      Exit;
    end;
  end;
end;

procedure TGridLayoutState.RegisterExistingColumns;
var
  I: Integer;
  Column: TColumn;
  ColumnKey: string;
begin
  if FGrid = nil then
    Exit;
  for I := 0 to FGrid.ColumnCount - 1 do
  begin
    Column := FGrid.Columns[I];
    if Column = nil then
      Continue;
    ColumnKey := Trim(Column.Name);
    if ColumnKey = '' then
      Continue;
    ApplyInitialWidth(ColumnKey, Column, Column.Width);
    RegisterColumn(ColumnKey, Column);
  end;
end;

function TGridLayoutState.FinishPendingManualResize: Boolean;
var
  ColumnKey: string;
  ApprovedWidth: Single;
begin
  Result := FManualResizeActive and (FTrackedColumn <> nil) and
    FColumnKeys.TryGetValue(FTrackedColumn, ColumnKey);
  if Result then
  begin
    ApprovedWidth := ValidateColumnWidth(FTrackedColumn.Width);
    FApprovedWidths.AddOrSetValue(ColumnKey, ApprovedWidth);
    SaveApprovedWidth(ColumnKey, ApprovedWidth);
    DebugLog(Format(
      'GridWidthControl manual end Grid="%s" Column="%s" Width=%.4f',
      [FGridKey, ColumnKey, ApprovedWidth]));
  end;
  FManualResizeActive := False;
  FTrackedColumn := nil;
  if FGrid <> nil then
    FGrid.Repaint;
end;

function TGridLayoutState.EndManualColumnResize: Boolean;
begin
  Result := FinishPendingManualResize;
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

class procedure TGridLayoutManager.SetRowCount(AGrid: TCustomGrid;
  const ARowCount: Integer; const AForceRefresh: Boolean);
var
  NewRowCount: Integer;
begin
  if AGrid = nil then
    Exit;

  NewRowCount := Max(0, ARowCount);
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

  AGrid.BeginUpdate;
  try
    if AForceRefresh and (AGrid.RowCount <> 0) then
      AGrid.RowCount := 0;
    if AGrid.RowCount <> NewRowCount then
      AGrid.RowCount := NewRowCount;
  finally
    AGrid.EndUpdate;
  end;
  AGrid.Repaint;
end;

class function TGridLayoutManager.Apply(AGrid: TGrid;
  AState: TGridLayoutState; const ADefinitions: TGridColumnDefinitions;
  const AFactory: TGridColumnFactory; const AStructureContext: string): Boolean;
var
  Signature, Key: string;
  Definition: TGridColumnDefinition;
  Column: TColumn;
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
begin
  if (AGrid = nil) or (AState = nil) or (ADefinitions = nil) then
    Exit(False);

  Inc(AState.FApplyCount);
  Signature := IntToStr(Length(AStructureContext)) + ':' +
    AStructureContext + #10 + BuildSignature(ADefinitions);
  DebugLog(Format('GridLayout Apply #%d context="%s" old="%s" new="%s"',
    [AState.FApplyCount, AStructureContext,
     PrintableSignature(AState.FLastSignature), PrintableSignature(Signature)]));
  if AState.FApplying then
  begin
    DebugLog(Format('GridLayout Apply #%d rejected: reentrant layout',
      [AState.FApplyCount]));
    Exit(False);
  end;
  { An unchanged signature must not mutate Parent, Index, Visible or Width. }
  if Signature = AState.FLastSignature then
    Exit(False);

  AState.FApplying := True;
  try
    OldColumns := AState.FColumns.ToArray;
    AGrid.BeginUpdate;
    try
      for Pair in OldColumns do
        if (Pair.Value <> nil) and (Pair.Value.Owner = AGrid) and
           not DefinitionContainsKey(Pair.Key) then
        begin
          AState.UnregisterColumn(Pair.Value);
          Pair.Value.Free;
        end;
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
          AState.UnregisterColumn(Column);
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
            raise EInvalidOperation.CreateFmt(
              'Factory did not create column "%s"', [Key]);
          AState.ApplyInitialWidth(Key, Column, Definition.InitialWidth);
          if Column.Parent <> AGrid then
            Column.Parent := AGrid;
          Column.Stored := False;
        end
        else if not AState.FColumnKeys.ContainsKey(Column) then
          AState.ApplyInitialWidth(Key, Column, Definition.InitialWidth);

        if Column.Header <> Definition.Header then
          Column.Header := Definition.Header;
        if Column.ReadOnly <> Definition.ReadOnly then
          Column.ReadOnly := Definition.ReadOnly;
        if Column.Visible <> Definition.Visible then
          Column.Visible := Definition.Visible;
        if Column.Index <> DesiredIndex then
          Column.Index := DesiredIndex;

        AState.RegisterColumn(Key, Column);
        Inc(DesiredIndex);
      end;
    finally
      AGrid.EndUpdate;
    end;

    AState.FLastSignature := Signature;
    Result := True;
  finally
    AState.FApplying := False;
  end;
end;

end.
