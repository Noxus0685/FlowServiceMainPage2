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
  public
    constructor Create;
    destructor Destroy; override;
    property LastSignature: string read FLastSignature;
  end;

  TGridLayoutManager = class
  public
    class function BuildSignature(const ADefinitions: TGridColumnDefinitions): string; static;
    class function Apply(AGrid: TGrid; AState: TGridLayoutState;
      const ADefinitions: TGridColumnDefinitions;
      const AFactory: TGridColumnFactory;
      const AStructureContext: string = ''): Boolean; static;
  end;

implementation

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
begin
  if (AGrid = nil) or (AState = nil) or (ADefinitions = nil) then
    Exit(False);

  Signature := IntToStr(Length(AStructureContext)) + ':' + AStructureContext + #10 +
    BuildSignature(ADefinitions);
  { This guard is deliberately before every observable FMX mutation. }
  if Signature = AState.FLastSignature then
    Exit(False);

  for Pair in AState.FColumns do
    if Pair.Value <> nil then
      AState.FWidths.AddOrSetValue(Pair.Key, Pair.Value.Width);
  OldColumns := AState.FColumns.ToArray;

  AGrid.BeginUpdate;
  try
    { Only factory-created columns are owned by this manager. }
    for Pair in OldColumns do
      if (Pair.Value <> nil) and (Pair.Value.Owner = AGrid) then
      begin
        Column := nil;
        for Definition in ADefinitions do
          if SameText(Definition.Key, Pair.Key) then
            Column := Definition.ExistingColumn;
        if Column = nil then
          Pair.Value.Free;
      end;
    AState.FColumns.Clear;

    for Definition in ADefinitions do
    begin
      Key := Definition.Key;
      Column := Definition.ExistingColumn;
      if Column = nil then
      begin
        if not Assigned(AFactory) then
          raise EArgumentNilException.Create('AFactory');
        Column := AFactory(AGrid, Definition);
        if Column = nil then
          raise EInvalidOperation.CreateFmt('Factory did not create column "%s"', [Key]);
        Column.Parent := AGrid;
        Column.Stored := False;
      end;
      Column.Header := Definition.Header;
      Column.ReadOnly := Definition.ReadOnly;
      Column.Visible := Definition.Visible;
      if AState.FWidths.TryGetValue(Key, SavedWidth) then
        Column.Width := SavedWidth
      else
        Column.Width := Definition.InitialWidth;
      Column.Index := AGrid.ColumnCount - 1;
      AState.FColumns.AddOrSetValue(Key, Column);
    end;
    AState.FLastSignature := Signature;
  finally
    AGrid.EndUpdate;
  end;

  AGrid.Model.BeginUpdate;
  try
    AGrid.Model.InvalidateContentSize;
    AGrid.Model.ContentChanged;
  finally
    AGrid.Model.EndUpdate;
  end;
  Result := True;
end;

end.
