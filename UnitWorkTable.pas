unit UnitWorkTable;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  System.Generics.Collections,
  UnitClasses;

type
  TSpillState = (
    ssNone,
    ssReady,
    ssStarting,
    ssOnGoing,
    ssStopping,
    ssResultReady
  );

  TChannel = class(TTypeEntity)
  private
    FEnabled: Boolean;
    FTypeName: string;
    FSerial: string;
    FSignal: string;
    FDeviceUUID: string;
    FImpSec: Double;
    FImpResult: Double;
    FCurSec: Double;
    FCurResult: Double;
    FValueSec: Double;
    FValueResult: Double;
  public
    constructor Create; override;

    property UUID: string read FMitUUID write FMitUUID;

    property Enabled: Boolean read FEnabled write FEnabled;
    property Name: string read FName write FName;
    property TypeName: string read FTypeName write FTypeName;
    property Serial: string read FSerial write FSerial;
    property Signal: string read FSignal write FSignal;
    property DeviceUUID: string read FDeviceUUID write FDeviceUUID;

    property ImpSec: Double read FImpSec write FImpSec;
    property ImpResult: Double read FImpResult write FImpResult;
    property CurSec: Double read FCurSec write FCurSec;
    property CurResult: Double read FCurResult write FCurResult;
    property ValueSec: Double read FValueSec write FValueSec;
    property ValueResult: Double read FValueResult write FValueResult;
  end;

  TWorkTable = class
  private
    FID: Integer;
    FName: string;

    FDeviceChannels: TObjectList<TChannel>;
    FEtalonChannels: TObjectList<TChannel>;

    FTemp: Double;
    FTempDelta: Double;
    FPress: Double;
    FPressDelta: Double;
    FFlowRate: Double;
    FTime: Double;
    FTimeResult: Double;
    FState: TSpillState;
    FTableClamped: Boolean;

    class function SpillStateToString(AState: TSpillState): string; static;
    class function SpillStateFromString(const AValue: string): TSpillState; static;

    class procedure SaveChannelList(
      AIni: TIniFile;
      const ASectionPrefix: string;
      AChannels: TObjectList<TChannel>
    ); static;

    class procedure LoadChannelList(
      AIni: TIniFile;
      const ASectionPrefix: string;
      AChannels: TObjectList<TChannel>
    ); static;

  public
    constructor Create;
    destructor Destroy; override;

    function AddDeviceChannel: TChannel; overload;
    function AddDeviceChannel(const AEnabled: Boolean; const AName, ATypeName,
      ASerial, ASignal, ADeviceUUID: string): TChannel; overload;

    function AddEtalonChannel: TChannel; overload;
    function AddEtalonChannel(const AEnabled: Boolean; const AName, ATypeName,
      ASerial, ASignal, ADeviceUUID: string): TChannel; overload;

    class procedure Save(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

    class procedure Load(const AIniFileName: string;
      AWorkTables: TObjectList<TWorkTable>); static;

    property ID: Integer read FID write FID;
    property Name: string read FName write FName;

    property DeviceChannels: TObjectList<TChannel> read FDeviceChannels;
    property EtalonChannels: TObjectList<TChannel> read FEtalonChannels;

    property Temp: Double read FTemp write FTemp;
    property TempDelta: Double read FTempDelta write FTempDelta;
    property Press: Double read FPress write FPress;
    property PressDelta: Double read FPressDelta write FPressDelta;
    property FlowRate: Double read FFlowRate write FFlowRate;

    property Time: Double read FTime write FTime;
    property TimeResult: Double read FTimeResult write FTimeResult;

    property State: TSpillState read FState write FState;
    property TableClamped: Boolean read FTableClamped write FTableClamped;
  end;

  TWorkTableManager = class
  private
    FIniFileName: string;
    FWorkTables: TObjectList<TWorkTable>;
  public
    constructor Create(const AIniFileName: string);
    destructor Destroy; override;

    procedure Load;
    procedure Save;

    property WorkTables: TObjectList<TWorkTable> read FWorkTables;
    property IniFileName: string read FIniFileName write FIniFileName;
  end;

implementation

{ TChannel }

constructor TChannel.Create;
begin
  inherited Create;

  FEnabled := True;
  FTypeName := '';
  FSerial := '';
  FSignal := '';
  FDeviceUUID := '';

  FImpSec := 0;
  FImpResult := 0;
  FCurSec := 0;
  FCurResult := 0;
  FValueSec := 0;
  FValueResult := 0;
end;

{ TWorkTable }

constructor TWorkTable.Create;
begin
  inherited Create;

  FDeviceChannels := TObjectList<TChannel>.Create(True);
  FEtalonChannels := TObjectList<TChannel>.Create(True);

  FState := ssNone;
  FTableClamped := False;
end;

destructor TWorkTable.Destroy;
begin
  FDeviceChannels.Free;
  FEtalonChannels.Free;
  inherited;
end;

function TWorkTable.AddDeviceChannel: TChannel;
begin
  Result := TChannel.Create;
  FDeviceChannels.Add(Result);
end;

function TWorkTable.AddDeviceChannel(const AEnabled: Boolean; const AName,
  ATypeName, ASerial, ASignal, ADeviceUUID: string): TChannel;
begin
  Result := AddDeviceChannel;
  Result.Enabled := AEnabled;
  Result.Name := AName;
  Result.TypeName := ATypeName;
  Result.Serial := ASerial;
  Result.Signal := ASignal;
  Result.DeviceUUID := ADeviceUUID;
end;

function TWorkTable.AddEtalonChannel: TChannel;
begin
  Result := TChannel.Create;
  FEtalonChannels.Add(Result);
end;

function TWorkTable.AddEtalonChannel(const AEnabled: Boolean; const AName,
  ATypeName, ASerial, ASignal, ADeviceUUID: string): TChannel;
begin
  Result := AddEtalonChannel;
  Result.Enabled := AEnabled;
  Result.Name := AName;
  Result.TypeName := ATypeName;
  Result.Serial := ASerial;
  Result.Signal := ASignal;
  Result.DeviceUUID := ADeviceUUID;
end;

class procedure TWorkTable.Save(const AIniFileName: string;
  AWorkTables: TObjectList<TWorkTable>);
var
  Ini: TIniFile;
  I: Integer;
  WorkTable: TWorkTable;
  Section: string;
begin
  if (AIniFileName = '') or (AWorkTables = nil) then
    Exit;

  Ini := TIniFile.Create(AIniFileName);
  try
    Ini.EraseSection('WorkTables');
    Ini.WriteInteger('WorkTables', 'Count', AWorkTables.Count);

    for I := 0 to AWorkTables.Count - 1 do
    begin
      WorkTable := AWorkTables[I];
      Section := 'WorkTable.' + IntToStr(I);

      Ini.EraseSection(Section);
      Ini.WriteInteger(Section, 'ID', WorkTable.ID);
      Ini.WriteString(Section, 'Name', WorkTable.Name);
      Ini.WriteFloat(Section, 'Temp', WorkTable.Temp);
      Ini.WriteFloat(Section, 'TempDelta', WorkTable.TempDelta);
      Ini.WriteFloat(Section, 'Press', WorkTable.Press);
      Ini.WriteFloat(Section, 'PressDelta', WorkTable.PressDelta);
      Ini.WriteFloat(Section, 'FlowRate', WorkTable.FlowRate);
      Ini.WriteFloat(Section, 'Time', WorkTable.Time);
      Ini.WriteFloat(Section, 'TimeResult', WorkTable.TimeResult);
      Ini.WriteString(Section, 'State', SpillStateToString(WorkTable.State));
      Ini.WriteBool(Section, 'TableClamped', WorkTable.TableClamped);

      SaveChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels);
      SaveChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels);
    end;
  finally
    Ini.Free;
  end;
end;

class procedure TWorkTable.Load(const AIniFileName: string;
  AWorkTables: TObjectList<TWorkTable>);
var
  Ini: TIniFile;
  Count, I: Integer;
  WorkTable: TWorkTable;
  Section: string;
begin
  if (AIniFileName = '') or (AWorkTables = nil) then
    Exit;

  if not FileExists(AIniFileName) then
    Exit;

  AWorkTables.Clear;

  Ini := TIniFile.Create(AIniFileName);
  try
    Count := Ini.ReadInteger('WorkTables', 'Count', 0);

    for I := 0 to Count - 1 do
    begin
      Section := 'WorkTable.' + IntToStr(I);
      WorkTable := TWorkTable.Create;

      WorkTable.ID := Ini.ReadInteger(Section, 'ID', I + 1);
      WorkTable.Name := Ini.ReadString(Section, 'Name', '');
      WorkTable.Temp := Ini.ReadFloat(Section, 'Temp', 0);
      WorkTable.TempDelta := Ini.ReadFloat(Section, 'TempDelta', 0);
      WorkTable.Press := Ini.ReadFloat(Section, 'Press', 0);
      WorkTable.PressDelta := Ini.ReadFloat(Section, 'PressDelta', 0);
      WorkTable.FlowRate := Ini.ReadFloat(Section, 'FlowRate', 0);
      WorkTable.Time := Ini.ReadFloat(Section, 'Time', 0);
      WorkTable.TimeResult := Ini.ReadFloat(Section, 'TimeResult', 0);
      WorkTable.State := SpillStateFromString(
        Ini.ReadString(Section, 'State', 'None')
      );
      WorkTable.TableClamped := Ini.ReadBool(Section, 'TableClamped', False);

      LoadChannelList(Ini, Section + '.Etalon', WorkTable.EtalonChannels);
      LoadChannelList(Ini, Section + '.Device', WorkTable.DeviceChannels);

      AWorkTables.Add(WorkTable);
    end;
  finally
    Ini.Free;
  end;
end;

class procedure TWorkTable.SaveChannelList(AIni: TIniFile;
  const ASectionPrefix: string; AChannels: TObjectList<TChannel>);
var
  I: Integer;
  Channel: TChannel;
  Section: string;
begin
  if (AIni = nil) or (AChannels = nil) then
    Exit;

  AIni.EraseSection(ASectionPrefix);
  AIni.WriteInteger(ASectionPrefix, 'Count', AChannels.Count);

  for I := 0 to AChannels.Count - 1 do
  begin
    Channel := AChannels[I];
    Section := ASectionPrefix + '.' + IntToStr(I);

    AIni.EraseSection(Section);
    AIni.WriteInteger(Section, 'ID', Channel.ID);
    AIni.WriteString(Section, 'UUID', Channel.UUID);
    AIni.WriteBool(Section, 'Enabled', Channel.Enabled);
    AIni.WriteString(Section, 'Name', Channel.Name);
    AIni.WriteString(Section, 'TypeName', Channel.TypeName);
    AIni.WriteString(Section, 'Serial', Channel.Serial);
    AIni.WriteString(Section, 'Signal', Channel.Signal);
    AIni.WriteString(Section, 'DeviceUUID', Channel.DeviceUUID);

    AIni.WriteFloat(Section, 'ImpSec', Channel.ImpSec);
    AIni.WriteFloat(Section, 'ImpResult', Channel.ImpResult);
    AIni.WriteFloat(Section, 'CurSec', Channel.CurSec);
    AIni.WriteFloat(Section, 'CurResult', Channel.CurResult);
    AIni.WriteFloat(Section, 'ValueSec', Channel.ValueSec);
    AIni.WriteFloat(Section, 'ValueResult', Channel.ValueResult);
  end;
end;

class procedure TWorkTable.LoadChannelList(AIni: TIniFile;
  const ASectionPrefix: string; AChannels: TObjectList<TChannel>);
var
  Count, I: Integer;
  Channel: TChannel;
  Section: string;
begin
  if (AIni = nil) or (AChannels = nil) then
    Exit;

  AChannels.Clear;
  Count := AIni.ReadInteger(ASectionPrefix, 'Count', 0);

  for I := 0 to Count - 1 do
  begin
    Section := ASectionPrefix + '.' + IntToStr(I);

    Channel := TChannel.Create;
    Channel.ID := AIni.ReadInteger(Section, 'ID', I + 1);
    Channel.UUID := AIni.ReadString(Section, 'UUID', '');
    Channel.Enabled := AIni.ReadBool(Section, 'Enabled', True);
    Channel.Name := AIni.ReadString(Section, 'Name', '');
    Channel.TypeName := AIni.ReadString(Section, 'TypeName', '');
    Channel.Serial := AIni.ReadString(Section, 'Serial', '');
    Channel.Signal := AIni.ReadString(Section, 'Signal', '');
    Channel.DeviceUUID := AIni.ReadString(Section, 'DeviceUUID', '');

    Channel.ImpSec := AIni.ReadFloat(Section, 'ImpSec', 0);
    Channel.ImpResult := AIni.ReadFloat(Section, 'ImpResult', 0);
    Channel.CurSec := AIni.ReadFloat(Section, 'CurSec', 0);
    Channel.CurResult := AIni.ReadFloat(Section, 'CurResult', 0);
    Channel.ValueSec := AIni.ReadFloat(Section, 'ValueSec', 0);
    Channel.ValueResult := AIni.ReadFloat(Section, 'ValueResult', 0);

    AChannels.Add(Channel);
  end;
end;

class function TWorkTable.SpillStateFromString(const AValue: string): TSpillState;
begin
  if SameText(AValue, 'Ready') then
    Exit(ssReady);

  if SameText(AValue, 'Starting') then
    Exit(ssStarting);

  if SameText(AValue, 'OnGoing') then
    Exit(ssOnGoing);

  if SameText(AValue, 'Stopping') then
    Exit(ssStopping);

  if SameText(AValue, 'ResultReady') then
    Exit(ssResultReady);

  Result := ssNone;
end;

class function TWorkTable.SpillStateToString(AState: TSpillState): string;
begin
  case AState of
    ssReady:
      Result := 'Ready';
    ssStarting:
      Result := 'Starting';
    ssOnGoing:
      Result := 'OnGoing';
    ssStopping:
      Result := 'Stopping';
    ssResultReady:
      Result := 'ResultReady';
  else
    Result := 'None';
  end;
end;

{ TWorkTableManager }

constructor TWorkTableManager.Create(const AIniFileName: string);
begin
  inherited Create;
  FIniFileName := AIniFileName;
  FWorkTables := TObjectList<TWorkTable>.Create(True);
end;

destructor TWorkTableManager.Destroy;
begin
  FWorkTables.Free;
  inherited;
end;

procedure TWorkTableManager.Load;
begin
  TWorkTable.Load(FIniFileName, FWorkTables);
end;

procedure TWorkTableManager.Save;
begin
  TWorkTable.Save(FIniFileName, FWorkTables);
end;

end.
