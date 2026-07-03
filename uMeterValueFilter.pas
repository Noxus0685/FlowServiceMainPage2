unit uMeterValueFilter;

interface

uses
  System.SysUtils,
  uClasses,
  uDeviceClass,
  uMeterValue;

function CanShowMeterValueForDevice(AValue: TMeterValue; ADevice: TDevice): Boolean;
function CanShowMeterValueForCategory(AValue: TMeterValue; ACategory: EStdCategory): Boolean;

implementation

function MeterValueText(AValue: TMeterValue): string;
begin
  if AValue = nil then
    Exit('');

  Result := AnsiLowerCase(Trim(AValue.&Type + ' ' + AValue.Name + ' ' +
    AValue.Description + ' ' + AValue.ShrtName));
end;

function IsVolumeFlowValue(AValue: TMeterValue): Boolean;
var
  S: string;
begin
  Result := False;
  if AValue = nil then
    Exit;

  S := MeterValueText(AValue);
  Result := ((Pos('расход', S) > 0) or (Pos('flow', S) > 0) or
    (AValue.ValueType = FLOW_TYPE)) and
    ((Pos('объем', S) > 0) or (Pos('объём', S) > 0) or (Pos('qv', S) > 0));
end;

function IsMassFlowValue(AValue: TMeterValue): Boolean;
var
  S: string;
begin
  Result := False;
  if AValue = nil then
    Exit;

  S := MeterValueText(AValue);
  Result := ((Pos('расход', S) > 0) or (Pos('flow', S) > 0) or
    (AValue.ValueType = FLOW_TYPE)) and
    ((Pos('масс', S) > 0) or (Pos('qm', S) > 0));
end;

function IsVolumeValue(AValue: TMeterValue): Boolean;
var
  S: string;
begin
  Result := False;
  if AValue = nil then
    Exit;

  S := MeterValueText(AValue);
  Result := (not IsVolumeFlowValue(AValue)) and
    ((Pos('объем', S) > 0) or (Pos('объём', S) > 0) or (Pos('volume', S) > 0) or
     SameText(Trim(AValue.ShrtName), 'V'));
end;

function IsMassValue(AValue: TMeterValue): Boolean;
var
  S: string;
begin
  Result := False;
  if AValue = nil then
    Exit;

  S := MeterValueText(AValue);
  Result := (not IsMassFlowValue(AValue)) and
    ((Pos('масс', S) > 0) or (Pos('mass', S) > 0) or SameText(Trim(AValue.ShrtName), 'M'));
end;

function IsSpeedValue(AValue: TMeterValue): Boolean;
var
  S: string;
begin
  Result := False;
  if AValue = nil then
    Exit;

  S := MeterValueText(AValue);
  Result := (Pos('скорост', S) > 0) or (Pos('speed', S) > 0);
end;

function CanShowMeterValueForCategory(AValue: TMeterValue; ACategory: EStdCategory): Boolean;
begin
  Result := AValue <> nil;
  if not Result then
    Exit;

  case ACategory of
    mftMassFlowmeterType,
    mftVolumeFlowmeterType:
      Exit(IsVolumeFlowValue(AValue) or IsMassFlowValue(AValue));

    mftWeightsType:
      Exit(IsMassValue(AValue) or IsMassFlowValue(AValue));

    mftTankType:
      Exit(IsVolumeValue(AValue));
  end;

  if IsVolumeValue(AValue) or IsMassValue(AValue) or IsSpeedValue(AValue) then
    Exit(False);
end;

function CanShowMeterValueForDevice(AValue: TMeterValue; ADevice: TDevice): Boolean;
var
  Category: EStdCategory;
begin
  if ADevice = nil then
    Exit(True);

  Category := mftUnknownType;
  if (ADevice.Category >= Ord(Low(EStdCategory))) and
     (ADevice.Category <= Ord(High(EStdCategory))) then
    Category := EStdCategory(ADevice.Category);

  Result := CanShowMeterValueForCategory(AValue, Category);
end;

end.
