unit uResultPresentation;

interface

uses
  System.SysUtils,
  System.UITypes,
  uBaseProcedures,
  uDeviceClass;

type
  TPointResultVisualState = (prvsEmpty, prvsPending, prvsRunning,
    prvsValid, prvsInvalid, prvsWarning);

function FormatResultError(const AValue: Double): string;
function ResolvePointResultVisualState(const ADevice: TDevice;
  const ADevicePoint, ASessionPoint: TDevicePoint;
  const ASpillage: TPointSpillage; const ARunning: Boolean = False): TPointResultVisualState;
function GetResultStateColor(const AState: TPointResultVisualState): TAlphaColor;
function ResolveDeviceResultVisualState(const ADevice: TDevice): TPointResultVisualState;
function GetDeviceResultText(const ADevice: TDevice): string;

implementation

function FormatResultError(const AValue: Double): string;
begin
  // This is the production representation used by the Processing results grid.
  // FormatFloat uses the application's locale, including its decimal separator.
  Result := FormatFloat('0.###', AValue);
end;

function ResolvePointResultVisualState(const ADevice: TDevice;
  const ADevicePoint, ASessionPoint: TDevicePoint;
  const ASpillage: TPointSpillage; const ARunning: Boolean): TPointResultVisualState;
begin
  Result := prvsEmpty;
  if (ADevice = nil) or (ADevicePoint = nil) then
    Exit;

  if ASpillage = nil then
  begin
    if ARunning then
      Exit(prvsRunning);
    Exit(prvsPending);
  end;

  // AnalyseDevicePointsResults is the production route used by Processing.
  // In particular, do not infer the result from the measurement-run status:
  // mptsDone may already have an SPS_OK result and must therefore be green.
  ADevice.AnalyseDevicePointsResults;
  case Ord(ADevicePoint.Status) of
    5: Exit(prvsValid);
    3: Exit(prvsInvalid);
    4: Exit(prvsWarning);
  end;

  case ASpillage.Status of
    TPointSpillage.SPS_OK: Result := prvsValid;
    TPointSpillage.SPS_ERROR_EXCEEDED: Result := prvsInvalid;
    TPointSpillage.SPS_STOP_CRITERIA_FAILED: Result := prvsWarning;
  else
    if ADevicePoint.Status in [mptsInterrupted, mptsCancelled] then
      Result := prvsWarning
    else if ASpillage.Valid and
            (Abs(ASpillage.Error) <= Abs(ADevicePoint.Error)) then
      Result := prvsValid
    else if ASpillage.Status = TPointSpillage.SPS_DATA_ASSIGNED then
      Result := prvsWarning
    else
      Result := prvsInvalid;
  end;
end;

function GetResultStateColor(const AState: TPointResultVisualState): TAlphaColor;
begin
  case AState of
    prvsRunning: Result := COLOR_RUNNING;
    prvsValid: Result := COLOR_COMPLETED;
    prvsInvalid: Result := COLOR_INVALID;
    prvsWarning: Result := COLOR_WARNING;
  else
    Result := TAlphaColors.Null;
  end;
end;

function ResolveDeviceResultVisualState(const ADevice: TDevice): TPointResultVisualState;
begin
  Result := prvsEmpty;
  if ADevice = nil then
    Exit;
  ADevice.AnalyseResults;
  case ADevice.Status of
    5: Result := prvsValid;
    3: Result := prvsInvalid;
    2, 4: Result := prvsWarning;
  end;
end;

function GetDeviceResultText(const ADevice: TDevice): string;
begin
  case ResolveDeviceResultVisualState(ADevice) of
    prvsValid: Result := 'Годен';
    prvsInvalid: Result := 'Не годен';
  else
    Result := '—';
  end;
end;

end.
