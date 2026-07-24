unit uDATA;

interface

uses


  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.FMXUI.Wait,
  FireDAC.Phys.SQLiteWrapper.Stat,
  System.StrUtils;

type

  TTableColumn = record
    Name: string;
    SqlType: string;
  end;

  TTableColumns = TArray<TTableColumn>;

  TDM = class(TDataModule)
    TypesConnection: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    Types: TFDTable;
    Diameters: TFDTable;
    TypePoints: TFDTable;
    DevicesConnection: TFDConnection;
    Devices: TFDTable;
    DevicePoints: TFDTable;
    SpillagePoints: TFDTable;
    Categories: TFDTable;
   // procedure qryFlowmeterTypesBeforeOpen(DataSet: TDataSet);

  private
    FDatabaseFileName :String;

    procedure CreateEmptyDatabase;
    procedure CreateTablesIfNotExist;
    procedure EnsureColumn(const ATable, AColumn, AType: string);
    procedure EnsureIndex(const AIndexName, ATable, AColumn: string);
    function  ColumnExists(const ATable, AColumn: string): Boolean;
    function  TableExists(const ATable: string): Boolean;
    procedure CreateTable(const ATable: string; const Columns: TTableColumns);



  public
     // Новая архитекрура
    constructor Create(const AFileName: string);

    procedure OpenDB;
    procedure CloseDB;
    function  CreateQuery: TFDQuery;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    procedure ExecSQL(const ASQL: string);
    function IsConnected: Boolean;
    procedure EnsureTable(const ATable: string; const Columns: TTableColumns);
    function  GetTableColumns(const ATable: string): TStringList;
    function GetDatabaseFileName: string;
    procedure SetDatabaseFileName(const Value: string);

    property DatabaseFileName: string read GetDatabaseFileName write SetDatabaseFileName;
    destructor Destroy; override;

  end;


var
  DM: TDM;
  procedure OpenDatabase(ADM: TDM);
  procedure CreateTablesIfNotExist(AConnection: TFDConnection);


implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  System.IOUtils;

constructor TDM.Create(const AFileName: string);
begin
  inherited Create(nil);  // 🔥 КРИТИЧЕСКИ ВАЖНО

  if AFileName = '' then
    raise Exception.Create('TDM.Create: empty database file name');

  FDatabaseFileName := AFileName;

end;


procedure TDM.CreateTablesIfNotExist;
begin
  {--------------------------------------------------}
  { SQLite: включаем внешние ключи }
  {--------------------------------------------------}
  ExecSQL('PRAGMA foreign_keys = ON');

  {--------------------------------------------------}
  { Базовая таблица DeviceType }
  {--------------------------------------------------}
  ExecSQL(
    'CREATE TABLE IF NOT EXISTS DeviceType (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'Name TEXT NOT NULL,' +
    'Modification TEXT,' +
    'Manufacturer TEXT,' +
    'ReestrNumber TEXT,' +
    'Category INTEGER,' +
    'CategoryName TEXT,' +
    'AccuracyClass TEXT,' +
    'RegDate DATE,' +
    'ValidityDate DATE,' +
    'IVI INTEGER,' +
    'RangeDynamic REAL' +
    ')'
  );

  {--------------------------------------------------}
  { МИГРАЦИИ — ВСЕ ПОЛЯ МОДЕЛИ }
  {--------------------------------------------------}
  EnsureColumn('DeviceType', 'MitUUID', 'TEXT');

  EnsureColumn('DeviceType', 'VerificationMethod', 'TEXT');
  EnsureColumn('DeviceType', 'ProcedureName', 'TEXT');

  EnsureColumn('DeviceType', 'ProcedureCmd1', 'TEXT');
  EnsureColumn('DeviceType', 'ProcedureCmd2', 'TEXT');
  EnsureColumn('DeviceType', 'ProcedureCmd3', 'TEXT');
  EnsureColumn('DeviceType', 'ProcedureCmd4', 'TEXT');
  EnsureColumn('DeviceType', 'ProcedureCmd5', 'TEXT');

  EnsureColumn('DeviceType', 'Description', 'TEXT');
  EnsureColumn('DeviceType', 'Documentation', 'TEXT');
  EnsureColumn('DeviceType', 'ReportingForm', 'TEXT');
  EnsureColumn('DeviceType', 'SerialNumTemplate', 'TEXT');

  EnsureColumn('DeviceType', 'MeasuredDimension', 'INTEGER');
  EnsureColumn('DeviceType', 'OutputType', 'INTEGER');
  EnsureColumn('DeviceType', 'DimensionCoef', 'INTEGER');

  EnsureColumn('DeviceType', 'OutputSet', 'INTEGER');
  EnsureColumn('DeviceType', 'Freq', 'REAL');
  EnsureColumn('DeviceType', 'Coef', 'REAL');
  EnsureColumn('DeviceType', 'FreqFlowRate', 'REAL');

  EnsureColumn('DeviceType', 'VoltageRange', 'INTEGER');
  EnsureColumn('DeviceType', 'VoltageQminRate', 'REAL');
  EnsureColumn('DeviceType', 'VoltageQmaxRate', 'REAL');

  EnsureColumn('DeviceType', 'CurrentRange', 'INTEGER');
  EnsureColumn('DeviceType', 'CurrentQminRate', 'REAL');
  EnsureColumn('DeviceType', 'CurrentQmaxRate', 'REAL');
  EnsureColumn('DeviceType', 'IntegrationTime', 'INTEGER');

  EnsureColumn('DeviceType', 'ProtocolName', 'TEXT');
  EnsureColumn('DeviceType', 'BaudRate', 'INTEGER');
  EnsureColumn('DeviceType', 'Parity', 'INTEGER');
  EnsureColumn('DeviceType', 'DeviceAddress', 'INTEGER');

  EnsureColumn('DeviceType', 'InputType', 'INTEGER');
  EnsureColumn('DeviceType', 'SpillageType', 'INTEGER');
  EnsureColumn('DeviceType', 'SpillageStop', 'INTEGER');

  EnsureColumn('DeviceType', 'Repeats', 'INTEGER');
  EnsureColumn('DeviceType', 'RepeatsProtocol', 'INTEGER');

  EnsureColumn('DeviceType', 'Error', 'REAL');
end;

procedure TDM.CreateEmptyDatabase;
begin
  TFileStream.Create(FDatabaseFileName, fmCreate).Free;

  TypesConnection.Connected := True;
  CreateTablesIfNotExist;
end;


destructor TDM.Destroy;
begin
  if Assigned(TypesConnection) then
    TypesConnection.Connected := False;

  if Assigned(DevicesConnection) then
    DevicesConnection.Connected := False;

  inherited;
end;

procedure TDM.OpenDB;
begin


  // 1. Если файла нет — создаём

  if not FileExists(FDatabaseFileName) then
  begin
    ForceDirectories(ExtractFilePath(FDatabaseFileName));
    TFile.Create(FDatabaseFileName).Free;
  end;

  { Важно: в DFM оба Connection могут быть уже Connected=True.
    Чтобы гарантированно переключиться на нужный файл БД,
    сначала отключаем их, затем задаём параметры и подключаем заново. }
  TypesConnection.Connected := False;
  DevicesConnection.Connected := False;

  TypesConnection.DriverName := 'SQLite';
  TypesConnection.Params.Database := FDatabaseFileName;
  TypesConnection.LoginPrompt := False;
  TypesConnection.Connected := True;

  DevicesConnection.DriverName := 'SQLite';
  DevicesConnection.Params.Database := FDatabaseFileName;
  DevicesConnection.LoginPrompt := False;
  DevicesConnection.Connected := True;
end;

procedure TDM.CloseDB;
begin
  TypesConnection.Connected := False;
  DevicesConnection.Connected := False;
end;

function TDM.CreateQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := TypesConnection;
end;

procedure TDM.StartTransaction;
begin
  TypesConnection.StartTransaction;
end;

procedure TDM.Commit;
begin
  TypesConnection.Commit;
end;

procedure TDM.Rollback;
begin
  TypesConnection.Rollback;
end;

procedure TDM.ExecSQL(const ASQL: string);
var
  Q: TFDQuery;
begin
  Q := CreateQuery;
  try
    Q.SQL.Text := ASQL;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TDM.IsConnected: Boolean;
begin
  Result := TypesConnection.Connected;
end;

procedure TDM.EnsureColumn(
  const ATable, AColumn, AType: string
);
begin
  if ColumnExists(ATable, AColumn) then
    Exit;

  ExecSQL(
    Format(
      'ALTER TABLE %s ADD COLUMN %s %s',
      [ATable, AColumn, AType]
    )
  );
end;
procedure TDM.EnsureIndex(
  const AIndexName, ATable, AColumn: string
);
begin
  ExecSQL(
    Format(
      'CREATE INDEX IF NOT EXISTS %s ON %s(%s)',
      [AIndexName, ATable, AColumn]
    )
  );
end;

procedure TDM.EnsureTable(
  const ATable: string;
  const Columns: TTableColumns
);
var
  Existing: TStringList;
  I: Integer;
begin
  if not TableExists(ATable) then
    CreateTable(ATable, Columns);

  Existing := GetTableColumns(ATable);
  try
    for I := Low(Columns) to High(Columns) do
      if Existing.IndexOf(Columns[I].Name) < 0 then
        ExecSQL(
          Format(
            'ALTER TABLE %s ADD COLUMN %s %s',
            [ATable, Columns[I].Name, Columns[I].SqlType]
          )
        );
  finally
    Existing.Free;
  end;
end;

function TDM.ColumnExists(
  const ATable, AColumn: string
): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  Q := CreateQuery;
  try
    Q.SQL.Text := 'PRAGMA table_info(' + ATable + ')';
    Q.Open;

    while not Q.Eof do
    begin
      if SameText(Q.FieldByName('name').AsString, AColumn) then
        Exit(True);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TDM.GetTableColumns(const ATable: string): TStringList;
var
  Q: TFDQuery;
begin
  Result := TStringList.Create;
  Result.CaseSensitive := False;

  Q := CreateQuery;
  try
    Q.SQL.Text := 'PRAGMA table_info(' + ATable + ')';
    Q.Open;

    while not Q.Eof do
    begin
      Result.Add(Q.FieldByName('name').AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;
//
//procedure TDM.AssertDeviceTypeSchema;
//const
//  REQUIRED_COLUMNS: array [0..47] of string = (
//    'ID',
//    'MitUUID',
//
//    'Name',
//    'Modification',
//    'Manufacturer',
//    'ReestrNumber',
//
//    'Category',
//    'CategoryName',
//    'AccuracyClass',
//
//    'RegDate',
//    'ValidityDate',
//    'IVI',
//    'RangeDynamic',
//
//    'VerificationMethod',
//    'ProcedureName',
//
//    'ProcedureCmd1',
//    'ProcedureCmd2',
//    'ProcedureCmd3',
//    'ProcedureCmd4',
//    'ProcedureCmd5',
//
//    'Description',
//    'Documentation',
//    'ReportingForm',
//    'SerialNumTemplate',
//
//    'MeasuredDimension',
//    'OutputType',
//    'DimensionCoef',
//
//    'OutputSet',
//    'Freq',
//    'Coef',
//    'FreqFlowRate',
//
//    'VoltageRange',
//    'VoltageQminRate',
//    'VoltageQmaxRate',
//
//    'CurrentRange',
//    'CurrentQminRate',
//    'CurrentQmaxRate',
//    'IntegrationTime',
//
//    'ProtocolName',
//    'BaudRate',
//    'Parity',
//    'DeviceAddress',
//
//    'InputType',
//    'SpillageType',
//    'SpillageStop',
//
//    'Repeats',
//    'RepeatsProtocol',
//
//    'Error'
//  );
//var
//  Existing: TStringList;
//  Missing: TStringList;
//  I: Integer;
//begin
//  Existing := GetTableColumns('DeviceType');
//  Missing := TStringList.Create;
//  try
//    for I := Low(REQUIRED_COLUMNS) to High(REQUIRED_COLUMNS) do
//      if Existing.IndexOf(REQUIRED_COLUMNS[I]) < 0 then
//        Missing.Add(REQUIRED_COLUMNS[I]);
//
//    if Missing.Count > 0 then
//      raise Exception.Create(
//        'Схема БД несовместима с моделью DeviceType.' + sLineBreak +
//        'Отсутствуют колонки:' + sLineBreak +
//        Missing.Text
//      );
//  finally
//    Existing.Free;
//    Missing.Free;
//  end;
//end;
//
function TDM.TableExists(const ATable: string): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;

  Q := CreateQuery;
  try
    Q.SQL.Text :=
      'SELECT name FROM sqlite_master ' +
      'WHERE type = ''table'' AND name = :name';
    Q.ParamByName('name').AsString := ATable;
    Q.Open;

    Result := not Q.Eof;
  finally
    Q.Free;
  end;
end;

procedure TDM.CreateTable(
  const ATable: string;
  const Columns: TTableColumns
);
var
  I: Integer;
  SQL: TStringList;
begin
  SQL := TStringList.Create;
  try
    SQL.Add('CREATE TABLE ' + ATable + ' (');

    for I := Low(Columns) to High(Columns) do
    begin
      SQL.Add(
        Format(
          '  %s %s%s',
          [
            Columns[I].Name,
            Columns[I].SqlType,
            IfThen(I < High(Columns), ',', '')
          ]
        )
      );
    end;

    SQL.Add(')');

    ExecSQL(SQL.Text);
  finally
    SQL.Free;
  end;
end;

procedure TDM.SetDatabaseFileName(const Value: string);
begin
 if FDatabaseFileName <> Value then
  begin
    FDatabaseFileName := Value;
    if TypesConnection.Connected then
      TypesConnection.Connected := False;
    TypesConnection.Params.Database := Value;
  end;
end;


{ }

function TDM.GetDatabaseFileName: string;
begin
  result:=FDatabaseFileName;
end;

procedure OpenDatabase(ADM: TDM);
var
  Q: TFDQuery;
procedure InitDefaultData(AConnection: TFDConnection);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;

    AConnection.StartTransaction;
    try
      // здесь  INSERT, либо пусто
      AConnection.Commit;
    except
      AConnection.Rollback;
      raise;
    end;
  finally
    Q.Free;
  end;
end;


begin


  // 2. Открываем соединение
  ADM.OpenDB;

  // 3. Создаём таблицы, если их нет
  CreateTablesIfNotExist(ADM.TypesConnection);

  // 4. Проверяем, есть ли данные
  Q := ADM.CreateQuery;
  try
    Q.SQL.Text := 'select count(*) from DeviceType';
    Q.Open;

    if Q.Fields[0].AsInteger = 0 then
      InitDefaultData(ADM.TypesConnection);
  finally
    Q.Free;
  end;
end;

procedure CreateTablesIfNotExist(AConnection: TFDConnection);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := AConnection;

    {==================================================}
    { Таблица типов приборов }
    {==================================================}
    Q.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS DeviceType (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'Name TEXT NOT NULL,' +
      'Category INTEGER,' +
      'AccuracyClass TEXT' +
      ')';
    Q.ExecSQL;

    {==================================================}
    { Таблица диаметров типа }
    {==================================================}
    Q.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS DeviceDiameter (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'DeviceTypeID INTEGER NOT NULL,' +
      'Name TEXT,' +
      'DN TEXT,' +
      'Description TEXT,' +
      'Qmax REAL,' +
      'Qmin REAL,' +
      'Kp REAL,' +
      'QFmax REAL,' +
      'Vmax REAL,' +
      'Vmin REAL' +
      ')';
    Q.ExecSQL;

    {==================================================}
    { Таблица точек типа }
    {==================================================}
    Q.SQL.Text :=
      'CREATE TABLE IF NOT EXISTS DeviceTypePoint (' +
      'ID INTEGER PRIMARY KEY AUTOINCREMENT,' +
      'DeviceTypeID INTEGER NOT NULL,' +
      'Name TEXT,' +
      'Description TEXT,' +
      'FlowRate REAL,' +
      'FlowAccuracy TEXT,' +
      'Pressure REAL,' +
      'Temp REAL,' +
      'TempAccuracy TEXT,' +
      'LimitImp INTEGER,' +
      'LimitVolume REAL,' +
      'LimitTime REAL,' +
      'Error REAL,' +
      'Pause INTEGER,' +
      'RepeatsProtocol INTEGER,' +
      'Repeats INTEGER' +
      ')';
    Q.ExecSQL;

  finally
    Q.Free;
  end;
end;







end.
