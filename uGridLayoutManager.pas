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
    { This is the sole width snapshot.  It must precede every structural or
      model mutation; in particular, layout-generated widths are never copied
      back after EndUpdate/ContentChanged. }
    for Pair in AState.FColumns do
      if Pair.Value <> nil then
        AState.FWidths.AddOrSetValue(Pair.Key, Pair.Value.Width);
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

        { Existing columns keep their width.  Only a factory-created column
          receives either its pre-structure snapshot or its initial width. }
        if IsNewColumn then
        begin
          if not AState.FWidths.TryGetValue(Key, SavedWidth) then
            SavedWidth := Definition.InitialWidth;
          if Abs(Column.Width - SavedWidth) >= CWidthEpsilon then
            Column.Width := SavedWidth;
        end;
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

    { Diagnostic variant: notify through ContentChanged only.  Keeping this
      separate from InvalidateContentSize makes any forced model layout visible
      in the phase logs instead of combining two possible triggers. }
    AGrid.Model.ContentChanged;
    for Definition in ADefinitions do
    begin
      Column := AState.FColumns[Definition.Key];
      LogColumn('after Model.ContentChanged', Definition.Key, Column,
        AState.FWidths.TryGetValue(Definition.Key, SavedWidth), SavedWidth);
    end;
    AState.FLastSignature := Signature;
    Result := True;
  finally
    AState.FApplying := False;
  end;
end;

end.
