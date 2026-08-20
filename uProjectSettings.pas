unit uProjectSettings;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  System.Classes,
  System.IniFiles,
  System.IOUtils,
  System.SyncObjs,
  System.SysUtils;

const
  STORAGE_TABLE_SETTINGS = 'TableSettings';
  STORAGE_WORK_TABLE_VALUES = 'WorkTableValues';
  STORAGE_METER_VALUES = 'MeterValues';
  STORAGE_DB_SETTINGS = 'DbSettings';

type
  TProjectSettingsIni = class(TCustomIniFile)
  private
    FConnection: TFDConnection;
    FStorageName: string;
    FWriteLockHeld: Boolean;
    procedure EnsureSchema;
    function CreateQuery: TFDQuery;
  public
    // Открывает логическое INI-хранилище внутри выбранного файла проекта *.fpp.
    constructor Create(const ADatabaseFileName, AStorageName: string);
    destructor Destroy; override;

    function ReadString(const Section, Ident, Default: string): string; override;
    procedure WriteString(const Section, Ident, Value: string); override;
    procedure ReadSection(const Section: string; Strings: TStrings); override;
    procedure ReadSections(Strings: TStrings); override;
    procedure ReadSectionValues(const Section: string; Strings: TStrings); override;
    procedure EraseSection(const Section: string); override;
    procedure DeleteKey(const Section, Ident: string); override;
    procedure UpdateFile; override;
    procedure Clear;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure CancelUpdate;
  end;

// Устанавливает выбранный файл проекта, внутри которого хранятся настройки.
procedure SetProjectSettingsFileName(const ADatabaseFileName: string);

// Возвращает путь к выбранному файлу проекта *.fpp.
function GetProjectSettingsFileName: string;

// Без исключения проверяет, выбран ли файл проекта *.fpp.
function TryGetProjectSettingsFileName(out ADatabaseFileName: string): Boolean;

// Создаёт адаптер указанного логического хранилища в выбранном проекте.
function OpenProjectSettings(const AStorageName: string): TProjectSettingsIni;

// Сериализует составные операции записи в общий файл проекта.
procedure BeginProjectSettingsWrite;
procedure EndProjectSettingsWrite;

implementation

var
  GProjectSettingsFileName: string;
  GProjectSettingsWriteLock: TCriticalSection;

procedure BeginProjectSettingsWrite;
begin
  GProjectSettingsWriteLock.Acquire;
end;

procedure EndProjectSettingsWrite;
begin
  GProjectSettingsWriteLock.Release;
end;

procedure SetProjectSettingsFileName(const ADatabaseFileName: string);
begin
  GProjectSettingsFileName := Trim(ADatabaseFileName);
end;

function TryGetProjectSettingsFileName(
  out ADatabaseFileName: string): Boolean;
begin
  ADatabaseFileName := GProjectSettingsFileName;
  Result := ADatabaseFileName <> '';
end;

function GetProjectSettingsFileName: string;
begin
  Result := GProjectSettingsFileName;
  if Result = '' then
    raise EArgumentException.Create('Не задан выбранный файл проекта *.fpp');
end;

function OpenProjectSettings(const AStorageName: string): TProjectSettingsIni;
begin
  Result := TProjectSettingsIni.Create(GetProjectSettingsFileName, AStorageName);
end;

constructor TProjectSettingsIni.Create(const ADatabaseFileName,
  AStorageName: string);
begin
  if Trim(ADatabaseFileName) = '' then
    raise EArgumentException.Create('Не задан файл хранилища настроек');
  if Trim(AStorageName) = '' then
    raise EArgumentException.Create('Не задано имя логического хранилища');

  ForceDirectories(ExtractFilePath(ADatabaseFileName));
  inherited Create(ADatabaseFileName);
  FStorageName := AStorageName;
  FWriteLockHeld := False;

  FConnection := TFDConnection.Create(nil);
  FConnection.LoginPrompt := False;
  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=SQLite');
  FConnection.Params.Add('Database=' + ADatabaseFileName);
  FConnection.Params.Add('LockingMode=Normal');
  FConnection.Connected := True;
  FConnection.ExecSQL('PRAGMA busy_timeout = 5000');
  BeginProjectSettingsWrite;
  try
    EnsureSchema;
  finally
    EndProjectSettingsWrite;
  end;
end;

destructor TProjectSettingsIni.Destroy;
begin
  if (FConnection <> nil) and FConnection.InTransaction then
    CancelUpdate
  else if FWriteLockHeld then
  begin
    FWriteLockHeld := False;
    EndProjectSettingsWrite;
  end;
  FreeAndNil(FConnection);
  inherited;
end;

function TProjectSettingsIni.CreateQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConnection;
end;

procedure TProjectSettingsIni.EnsureSchema;
begin
  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS FlowServiceIniSettings (' +
    'StorageName TEXT NOT NULL COLLATE NOCASE, ' +
    'SectionName TEXT NOT NULL COLLATE NOCASE, ' +
    'KeyName TEXT NOT NULL COLLATE NOCASE, ' +
    'KeyValue TEXT, ' +
    'PRIMARY KEY (StorageName, SectionName, KeyName)) WITHOUT ROWID'
  );
end;

function TProjectSettingsIni.ReadString(const Section, Ident,
  Default: string): string;
var
  Query: TFDQuery;
begin
  Result := Default;
  Query := CreateQuery;
  try
    Query.SQL.Text :=
      'SELECT KeyValue FROM FlowServiceIniSettings ' +
      'WHERE StorageName = :StorageName AND SectionName = :SectionName ' +
      'AND KeyName = :KeyName';
    Query.ParamByName('StorageName').AsString := FStorageName;
    Query.ParamByName('SectionName').AsString := Section;
    Query.ParamByName('KeyName').AsString := Ident;
    Query.Open;
    if not Query.Eof then
      Result := Query.Fields[0].AsString;
  finally
    Query.Free;
  end;
end;

procedure TProjectSettingsIni.WriteString(const Section, Ident,
  Value: string);
var
  Query: TFDQuery;
begin
  BeginProjectSettingsWrite;
  try
    Query := CreateQuery;
    try
      Query.SQL.Text :=
        'UPDATE FlowServiceIniSettings SET KeyValue = :KeyValue ' +
      'WHERE StorageName = :StorageName AND SectionName = :SectionName ' +
      'AND KeyName = :KeyName';
    Query.ParamByName('KeyValue').AsString := Value;
    Query.ParamByName('StorageName').AsString := FStorageName;
    Query.ParamByName('SectionName').AsString := Section;
    Query.ParamByName('KeyName').AsString := Ident;
    Query.ExecSQL;

    if Query.RowsAffected = 0 then
    begin
      Query.SQL.Text :=
        'INSERT INTO FlowServiceIniSettings ' +
        '(StorageName, SectionName, KeyName, KeyValue) ' +
        'VALUES (:StorageName, :SectionName, :KeyName, :KeyValue)';
      Query.ParamByName('StorageName').AsString := FStorageName;
      Query.ParamByName('SectionName').AsString := Section;
      Query.ParamByName('KeyName').AsString := Ident;
      Query.ParamByName('KeyValue').AsString := Value;
      Query.ExecSQL;
      end;
    finally
      Query.Free;
    end;
  finally
    EndProjectSettingsWrite;
  end;
end;

procedure TProjectSettingsIni.ReadSection(const Section: string;
  Strings: TStrings);
var
  Query: TFDQuery;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    Query := CreateQuery;
    try
      Query.SQL.Text :=
        'SELECT KeyName FROM FlowServiceIniSettings ' +
        'WHERE StorageName = :StorageName AND SectionName = :SectionName ' +
        'ORDER BY KeyName';
      Query.ParamByName('StorageName').AsString := FStorageName;
      Query.ParamByName('SectionName').AsString := Section;
      Query.Open;
      while not Query.Eof do
      begin
        Strings.Add(Query.Fields[0].AsString);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  finally
    Strings.EndUpdate;
  end;
end;

procedure TProjectSettingsIni.ReadSections(Strings: TStrings);
var
  Query: TFDQuery;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    Query := CreateQuery;
    try
      Query.SQL.Text :=
        'SELECT DISTINCT SectionName FROM FlowServiceIniSettings ' +
        'WHERE StorageName = :StorageName ORDER BY SectionName';
      Query.ParamByName('StorageName').AsString := FStorageName;
      Query.Open;
      while not Query.Eof do
      begin
        Strings.Add(Query.Fields[0].AsString);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  finally
    Strings.EndUpdate;
  end;
end;

procedure TProjectSettingsIni.ReadSectionValues(const Section: string;
  Strings: TStrings);
var
  Query: TFDQuery;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    Query := CreateQuery;
    try
      Query.SQL.Text :=
        'SELECT KeyName, KeyValue FROM FlowServiceIniSettings ' +
        'WHERE StorageName = :StorageName AND SectionName = :SectionName ' +
        'ORDER BY KeyName';
      Query.ParamByName('StorageName').AsString := FStorageName;
      Query.ParamByName('SectionName').AsString := Section;
      Query.Open;
      while not Query.Eof do
      begin
        Strings.Add(Query.Fields[0].AsString + '=' + Query.Fields[1].AsString);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  finally
    Strings.EndUpdate;
  end;
end;

procedure TProjectSettingsIni.EraseSection(const Section: string);
var
  Query: TFDQuery;
begin
  BeginProjectSettingsWrite;
  try
    Query := CreateQuery;
    try
      Query.SQL.Text :=
        'DELETE FROM FlowServiceIniSettings ' +
        'WHERE StorageName = :StorageName AND SectionName = :SectionName';
      Query.ParamByName('StorageName').AsString := FStorageName;
      Query.ParamByName('SectionName').AsString := Section;
      Query.ExecSQL;
    finally
      Query.Free;
    end;
  finally
    EndProjectSettingsWrite;
  end;
end;

procedure TProjectSettingsIni.DeleteKey(const Section, Ident: string);
var
  Query: TFDQuery;
begin
  BeginProjectSettingsWrite;
  try
    Query := CreateQuery;
    try
      Query.SQL.Text :=
        'DELETE FROM FlowServiceIniSettings ' +
        'WHERE StorageName = :StorageName AND SectionName = :SectionName ' +
        'AND KeyName = :KeyName';
      Query.ParamByName('StorageName').AsString := FStorageName;
      Query.ParamByName('SectionName').AsString := Section;
      Query.ParamByName('KeyName').AsString := Ident;
      Query.ExecSQL;
    finally
      Query.Free;
    end;
  finally
    EndProjectSettingsWrite;
  end;
end;

procedure TProjectSettingsIni.UpdateFile;
begin
  // SQLite фиксирует каждую операцию записи; отдельная выгрузка не требуется.
end;

procedure TProjectSettingsIni.Clear;
var
  Query: TFDQuery;
begin
  BeginProjectSettingsWrite;
  try
    Query := CreateQuery;
    try
      Query.SQL.Text :=
        'DELETE FROM FlowServiceIniSettings WHERE StorageName = :StorageName';
      Query.ParamByName('StorageName').AsString := FStorageName;
      Query.ExecSQL;
    finally
      Query.Free;
    end;
  finally
    EndProjectSettingsWrite;
  end;
end;

procedure TProjectSettingsIni.BeginUpdate;
begin
  if FConnection.InTransaction then
    Exit;

  BeginProjectSettingsWrite;
  try
    FConnection.StartTransaction;
    FWriteLockHeld := True;
  except
    EndProjectSettingsWrite;
    raise;
  end;
end;

procedure TProjectSettingsIni.EndUpdate;
begin
  if not FConnection.InTransaction then
    Exit;

  try
    try
      FConnection.Commit;
    except
      if FConnection.InTransaction then
        FConnection.Rollback;
      raise;
    end;
  finally
    if FWriteLockHeld then
    begin
      FWriteLockHeld := False;
      EndProjectSettingsWrite;
    end;
  end;
end;

procedure TProjectSettingsIni.CancelUpdate;
begin
  try
    if FConnection.InTransaction then
      FConnection.Rollback;
  finally
    if FWriteLockHeld then
    begin
      FWriteLockHeld := False;
      EndProjectSettingsWrite;
    end;
  end;
end;

initialization
  GProjectSettingsWriteLock := TCriticalSection.Create;

finalization
  FreeAndNil(GProjectSettingsWriteLock);

end.
