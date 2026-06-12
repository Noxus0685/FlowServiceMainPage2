unit uSyncSetup;

interface

uses
  System.IniFiles,
  System.SysUtils;

type
  ESyncEdge = (seNone = 0, seRising = 1, seFalling = 2, seBoth = 3);
  ESyncInSource = (sisNone = 0, sisInternal = 1, sisExternalCh0 = 2, sisImpChannel = 3);
  ESyncInStartMode = (ssmStartOnSignal = 0, ssmStartOnCommand = 1, ssmStartCommandThenSignal = 2);
  ESyncInStopMode = (ssmStopOnSignal = 0, ssmStopOnCommand = 1, ssmStopOnLimit = 2, ssmStopLimitThenSignal = 3);
  ESyncOutType = (sotDisabled = 0, sotRunHigh = 1, sotRunLow = 2, sotPulseHigh = 3, sotPulseLow = 4);
  ESyncOutMode = (somUpOnly = 0, somUpDownInverse = 1, somUpWithDownOff = 2, somDownWithUpOff = 3);

  TSyncInputSetup = class
  public
    Source: ESyncInSource;
    StartEdge: ESyncEdge;
    StopEdge: ESyncEdge;
    StartChannel: Integer;
    StopChannel: Integer;
    StartMode: ESyncInStartMode;
    StopMode: ESyncInStopMode;
    procedure Clear;
    procedure Assign(Source: TSyncInputSetup);
  end;

  TSyncOutputSetup = class
  public
    Enabled: Boolean;
    StartEdge: ESyncEdge;
    StopEdge: ESyncEdge;
    OutType: ESyncOutType;
    OutMode: ESyncOutMode;
    PulseTimeMs: Integer;
    procedure Clear;
    procedure Assign(Source: TSyncOutputSetup);
  end;

  TSyncSetup = class
  private
    FInput: TSyncInputSetup;
    FOutput1: TSyncOutputSetup;
    FOutput2: TSyncOutputSetup;
    FInternalSyncEnabled: Boolean;
    function NormalizeSyncSection(const ASectionPrefix: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Source: TSyncSetup);
    function IsValid(out AError: string): Boolean;
    procedure LoadFromIni(AIni: TCustomIniFile; const ASectionPrefix: string);
    procedure SaveToIni(AIni: TCustomIniFile; const ASectionPrefix: string);
    property Input: TSyncInputSetup read FInput;
    property Output1: TSyncOutputSetup read FOutput1;
    property Output2: TSyncOutputSetup read FOutput2;
    property InternalSyncEnabled: Boolean read FInternalSyncEnabled write FInternalSyncEnabled;
  end;

implementation

function ReadEnumInteger(AIni: TCustomIniFile; const ASection, AIdent: string;
  ADefault, AMin, AMax: Integer): Integer;
begin
  Result := AIni.ReadInteger(ASection, AIdent, ADefault);
  if Result < AMin then
    Result := AMin
  else if Result > AMax then
    Result := AMax;
end;

procedure TSyncInputSetup.Assign(Source: TSyncInputSetup);
begin
  if Source = nil then
  begin
    Clear;
    Exit;
  end;

  Self.Source := Source.Source;
  StartEdge := Source.StartEdge;
  StopEdge := Source.StopEdge;
  StartChannel := Source.StartChannel;
  StopChannel := Source.StopChannel;
  StartMode := Source.StartMode;
  StopMode := Source.StopMode;
end;

procedure TSyncInputSetup.Clear;
begin
  Source := sisNone;
  StartEdge := seRising;
  StopEdge := seFalling;
  StartChannel := 1;
  StopChannel := 1;
  StartMode := ssmStartOnCommand;
  StopMode := ssmStopOnLimit;
end;

procedure TSyncOutputSetup.Assign(Source: TSyncOutputSetup);
begin
  if Source = nil then
  begin
    Clear;
    Exit;
  end;

  Enabled := Source.Enabled;
  StartEdge := Source.StartEdge;
  StopEdge := Source.StopEdge;
  OutType := Source.OutType;
  OutMode := Source.OutMode;
  PulseTimeMs := Source.PulseTimeMs;
end;

procedure TSyncOutputSetup.Clear;
begin
  Enabled := False;
  StartEdge := seRising;
  StopEdge := seFalling;
  OutType := sotDisabled;
  OutMode := somUpDownInverse;
  PulseTimeMs := 100;
end;

constructor TSyncSetup.Create;
begin
  inherited Create;
  FInput := TSyncInputSetup.Create;
  FOutput1 := TSyncOutputSetup.Create;
  FOutput2 := TSyncOutputSetup.Create;
  Clear;
end;

destructor TSyncSetup.Destroy;
begin
  FOutput2.Free;
  FOutput1.Free;
  FInput.Free;
  inherited;
end;

procedure TSyncSetup.Assign(Source: TSyncSetup);
begin
  if Source = nil then
  begin
    Clear;
    Exit;
  end;

  FInput.Assign(Source.Input);
  FOutput1.Assign(Source.Output1);
  FOutput2.Assign(Source.Output2);
  FInternalSyncEnabled := Source.InternalSyncEnabled;
end;

procedure TSyncSetup.Clear;
begin
  FInput.Clear;
  FOutput1.Clear;
  FOutput2.Clear;
  FInternalSyncEnabled := False;
end;

function TSyncSetup.IsValid(out AError: string): Boolean;

  function IsSignalEdge(AEdge: ESyncEdge): Boolean;
  begin
    Result := AEdge in [seRising, seFalling];
  end;

  function CheckOutput(AOutput: TSyncOutputSetup; const AName: string): Boolean;
  begin
    Result := True;
    if (AOutput = nil) or (not AOutput.Enabled) then
      Exit;

    if not IsSignalEdge(AOutput.StartEdge) or not IsSignalEdge(AOutput.StopEdge) then
    begin
      AError := AName + ': стартовый и стоповый фронты должны быть фронтом или спадом';
      Exit(False);
    end;

    if AOutput.StartEdge = AOutput.StopEdge then
    begin
      AError := AName + ': стартовый и стоповый фронты должны быть противоположными';
      Exit(False);
    end;
  end;

begin
  AError := '';

  if FInput.Source = sisImpChannel then
  begin
    if (FInput.StartChannel < 1) or (FInput.StopChannel < 1) then
    begin
      AError := 'Для синхронизации по импульсному каналу номера каналов должны быть больше или равны 1';
      Exit(False);
    end;
  end;

  if (FInput.Source <> sisNone) and
     ((not IsSignalEdge(FInput.StartEdge)) or (not IsSignalEdge(FInput.StopEdge))) then
  begin
    AError := 'Стартовый и стоповый фронты входа синхронизации должны быть фронтом или спадом';
    Exit(False);
  end;

  if not CheckOutput(FOutput1, 'Выход синхронизации 1') then
    Exit(False);

  if not CheckOutput(FOutput2, 'Выход синхронизации 2') then
    Exit(False);

  if FInternalSyncEnabled and (FInput.Source = sisInternal) then
  begin
    AError := 'Внутренняя синхронизация не может одновременно быть входом и выходом';
    Exit(False);
  end;

  Result := True;
end;

procedure TSyncSetup.LoadFromIni(AIni: TCustomIniFile; const ASectionPrefix: string);
var
  Section: string;
begin
  Clear;
  if AIni = nil then
    Exit;

  Section := NormalizeSyncSection(ASectionPrefix);

  FInput.Source := ESyncInSource(ReadEnumInteger(AIni, Section, 'InputSource', Ord(FInput.Source), Ord(Low(ESyncInSource)), Ord(High(ESyncInSource))));
  FInput.StartEdge := ESyncEdge(ReadEnumInteger(AIni, Section, 'InputStartEdge', Ord(FInput.StartEdge), Ord(Low(ESyncEdge)), Ord(High(ESyncEdge))));
  FInput.StopEdge := ESyncEdge(ReadEnumInteger(AIni, Section, 'InputStopEdge', Ord(FInput.StopEdge), Ord(Low(ESyncEdge)), Ord(High(ESyncEdge))));
  FInput.StartChannel := AIni.ReadInteger(Section, 'InputStartChannel', FInput.StartChannel);
  FInput.StopChannel := AIni.ReadInteger(Section, 'InputStopChannel', FInput.StopChannel);
  FInput.StartMode := ESyncInStartMode(ReadEnumInteger(AIni, Section, 'InputStartMode', Ord(FInput.StartMode), Ord(Low(ESyncInStartMode)), Ord(High(ESyncInStartMode))));
  FInput.StopMode := ESyncInStopMode(ReadEnumInteger(AIni, Section, 'InputStopMode', Ord(FInput.StopMode), Ord(Low(ESyncInStopMode)), Ord(High(ESyncInStopMode))));

  FOutput1.Enabled := AIni.ReadBool(Section, 'Output1Enabled', FOutput1.Enabled);
  FOutput1.StartEdge := ESyncEdge(ReadEnumInteger(AIni, Section, 'Output1StartEdge', Ord(FOutput1.StartEdge), Ord(Low(ESyncEdge)), Ord(High(ESyncEdge))));
  FOutput1.StopEdge := ESyncEdge(ReadEnumInteger(AIni, Section, 'Output1StopEdge', Ord(FOutput1.StopEdge), Ord(Low(ESyncEdge)), Ord(High(ESyncEdge))));
  FOutput1.OutType := ESyncOutType(ReadEnumInteger(AIni, Section, 'Output1OutType', Ord(FOutput1.OutType), Ord(Low(ESyncOutType)), Ord(High(ESyncOutType))));
  FOutput1.OutMode := ESyncOutMode(ReadEnumInteger(AIni, Section, 'Output1OutMode', Ord(FOutput1.OutMode), Ord(Low(ESyncOutMode)), Ord(High(ESyncOutMode))));
  FOutput1.PulseTimeMs := AIni.ReadInteger(Section, 'Output1PulseTimeMs', FOutput1.PulseTimeMs);

  FOutput2.Enabled := AIni.ReadBool(Section, 'Output2Enabled', FOutput2.Enabled);
  FOutput2.StartEdge := ESyncEdge(ReadEnumInteger(AIni, Section, 'Output2StartEdge', Ord(FOutput2.StartEdge), Ord(Low(ESyncEdge)), Ord(High(ESyncEdge))));
  FOutput2.StopEdge := ESyncEdge(ReadEnumInteger(AIni, Section, 'Output2StopEdge', Ord(FOutput2.StopEdge), Ord(Low(ESyncEdge)), Ord(High(ESyncEdge))));
  FOutput2.OutType := ESyncOutType(ReadEnumInteger(AIni, Section, 'Output2OutType', Ord(FOutput2.OutType), Ord(Low(ESyncOutType)), Ord(High(ESyncOutType))));
  FOutput2.OutMode := ESyncOutMode(ReadEnumInteger(AIni, Section, 'Output2OutMode', Ord(FOutput2.OutMode), Ord(Low(ESyncOutMode)), Ord(High(ESyncOutMode))));
  FOutput2.PulseTimeMs := AIni.ReadInteger(Section, 'Output2PulseTimeMs', FOutput2.PulseTimeMs);

  FInternalSyncEnabled := AIni.ReadBool(Section, 'InternalSyncEnabled', FInternalSyncEnabled);
end;

function TSyncSetup.NormalizeSyncSection(const ASectionPrefix: string): string;
begin
  Result := ASectionPrefix;
  if Result = '' then
    Result := 'Sync'
  else if not Result.EndsWith('_Sync') then
    Result := Result + '_Sync';
end;

procedure TSyncSetup.SaveToIni(AIni: TCustomIniFile; const ASectionPrefix: string);
var
  Section: string;
begin
  if AIni = nil then
    Exit;

  Section := NormalizeSyncSection(ASectionPrefix);
  AIni.WriteInteger(Section, 'InputSource', Ord(FInput.Source));
  AIni.WriteInteger(Section, 'InputStartEdge', Ord(FInput.StartEdge));
  AIni.WriteInteger(Section, 'InputStopEdge', Ord(FInput.StopEdge));
  AIni.WriteInteger(Section, 'InputStartChannel', FInput.StartChannel);
  AIni.WriteInteger(Section, 'InputStopChannel', FInput.StopChannel);
  AIni.WriteInteger(Section, 'InputStartMode', Ord(FInput.StartMode));
  AIni.WriteInteger(Section, 'InputStopMode', Ord(FInput.StopMode));

  AIni.WriteBool(Section, 'Output1Enabled', FOutput1.Enabled);
  AIni.WriteInteger(Section, 'Output1StartEdge', Ord(FOutput1.StartEdge));
  AIni.WriteInteger(Section, 'Output1StopEdge', Ord(FOutput1.StopEdge));
  AIni.WriteInteger(Section, 'Output1OutType', Ord(FOutput1.OutType));
  AIni.WriteInteger(Section, 'Output1OutMode', Ord(FOutput1.OutMode));
  AIni.WriteInteger(Section, 'Output1PulseTimeMs', FOutput1.PulseTimeMs);

  AIni.WriteBool(Section, 'Output2Enabled', FOutput2.Enabled);
  AIni.WriteInteger(Section, 'Output2StartEdge', Ord(FOutput2.StartEdge));
  AIni.WriteInteger(Section, 'Output2StopEdge', Ord(FOutput2.StopEdge));
  AIni.WriteInteger(Section, 'Output2OutType', Ord(FOutput2.OutType));
  AIni.WriteInteger(Section, 'Output2OutMode', Ord(FOutput2.OutMode));
  AIni.WriteInteger(Section, 'Output2PulseTimeMs', FOutput2.PulseTimeMs);

  AIni.WriteBool(Section, 'InternalSyncEnabled', FInternalSyncEnabled);
end;

end.
