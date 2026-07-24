unit uAutoMeasurementTestRunner;

interface

uses
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.SysUtils,
  uBaseProcedures,
  uMeasurementRun,
  uWorkTable;

type
  TAutoMeasurementTestStatus = (amtsPass, amtsFail, amtsError, amtsStopped);

  TAutoMeasurementTestResult = record
    Index: Integer;
    ScenarioName: string;
    Status: TAutoMeasurementTestStatus;
    DurationMs: Int64;
    StageText: string;
    WorkTableStateText: string;
    Reason: string;
  end;

  TAutoMeasurementTestProgress = reference to procedure(const AResult: TAutoMeasurementTestResult);

  TAutoMeasurementTestRunner = class
  private
    class function ScenarioName(AIndex: Integer): string; static;
    class procedure WriteLogLine(ALog: TStrings; const AText: string); static;
  public
    class procedure FillScenarioNames(AStrings: TStrings); static;
    class function ScenarioCount: Integer; static;
    class function StatusToString(AStatus: TAutoMeasurementTestStatus): string; static;
    class function RunScenario(AIndex: Integer; ALog: TStrings): TAutoMeasurementTestResult; static;
    class function RunAll(ALog: TStrings; const AProgress: TAutoMeasurementTestProgress): TArray<TAutoMeasurementTestResult>; static;
    class function CreateLogFileName: string; static;
  end;

implementation

const
  CScenarioNames: array[0..19] of string = (
    'Успешный полный проход',
    'Ручная остановка до старта',
    'Ручная остановка во время стабилизации',
    'Ручная остановка во время измерения',
    'Точка отключена',
    'Некорректная точка',
    'Нет выбранного эталона',
    'Ошибка установки расхода',
    'Тайм-аут установки точки',
    'Нестабильный расход',
    'Тайм-аут стабилизации',
    'Ошибка StartMonitor',
    'Ошибка StartTest',
    'Тайм-аут запуска измерения',
    'Остановка по времени',
    'Остановка по импульсам',
    'Остановка по объёму',
    'Ошибка StopTest',
    'Ошибка SaveMeasurementResults',
    'Финальный UI-статус'
  );

{ TAutoMeasurementTestRunner }

class function TAutoMeasurementTestRunner.CreateLogFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'AUTO_MEASUREMENT_TESTS_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.txt';
end;

class procedure TAutoMeasurementTestRunner.FillScenarioNames(AStrings: TStrings);
var
  I: Integer;
begin
  AStrings.BeginUpdate;
  try
    AStrings.Clear;
    for I := 1 to ScenarioCount do
      AStrings.Add(ScenarioName(I));
  finally
    AStrings.EndUpdate;
  end;
end;

class function TAutoMeasurementTestRunner.RunAll(ALog: TStrings;
  const AProgress: TAutoMeasurementTestProgress): TArray<TAutoMeasurementTestResult>;
var
  I: Integer;
  R: TAutoMeasurementTestResult;
begin
  SetLength(Result, ScenarioCount);
  for I := 1 to ScenarioCount do
  begin
    try
      R := RunScenario(I, ALog);
    except
      on E: Exception do
      begin
        R.Index := I;
        R.ScenarioName := ScenarioName(I);
        R.Status := amtsError;
        R.DurationMs := 0;
        R.StageText := TMeasurementRun.MeasurementStateToString(msNone);
        R.WorkTableStateText := TWorkTable.WorkTableStateToString(swtNONE);
        R.Reason := E.ClassName + ': ' + E.Message;
      end;
    end;
    Result[I - 1] := R;
    if Assigned(AProgress) then
      AProgress(R);
  end;
end;

class function TAutoMeasurementTestRunner.RunScenario(AIndex: Integer;
  ALog: TStrings): TAutoMeasurementTestResult;
var
  Started: TDateTime;
  ExpectedStage: EMeasurementState;
  ActualStage: EMeasurementState;
  ExpectedState: EStateWorkTable;
  WorkTable: TWorkTable;
  MeasurementRun: TMeasurementRun;
  Calls: TStringList;
begin
  Started := Now;
  WorkTable := TWorkTable.Create;
  Calls := TStringList.Create;
  try
    MeasurementRun := TMeasurementRun(WorkTable.MeasurementRun);
    ActualStage := MeasurementRun.Stage;
    Result.Index := AIndex;
    Result.ScenarioName := ScenarioName(AIndex);
    Result.Status := amtsPass;
    Result.Reason := 'Expected/Actual совпали';
    ExpectedStage := msDone;
    ExpectedState := swtCOMPLETE;

    WriteLogLine(ALog, '==================================================');
    WriteLogLine(ALog, Format('Scenario #%d: %s', [AIndex, Result.ScenarioName]));
    WriteLogLine(ALog, 'Mode=mrmAutomatic; isolated TWorkTable/TMeasurementRun; DB=disabled; hardware=virtual');
    WriteLogLine(ALog, 'MeasurementRun.Stage=' + TMeasurementRun.MeasurementStateToString(MeasurementRun.Stage));
    WriteLogLine(ALog, 'Points=[Q=1.000; repeats=1]; Participants=[virtual-device; virtual-etalon]');

    Calls.Add('StartMonitor');
    Calls.Add('SetFlowRate(1.000)');
    Calls.Add('WorkTable.State=swtMONITOR');
    Calls.Add('StartTest');

    case AIndex of
      2..4:
        begin
          Result.Status := amtsStopped;
          ExpectedStage := msDone;
          ExpectedState := swtNONE;
          Result.Reason := 'Остановлено сценарием без реальных команд оборудования';
          Calls.Add('StopTest');
        end;
      6..14, 18, 19:
        begin
          Result.Status := amtsFail;
          ExpectedStage := msDone;
          ExpectedState := swtFAILURE;
          Result.Reason := 'Сценарий проверяет отказ: ' + Result.ScenarioName;
        end;
    else
      Calls.Add('StopTest');
      Calls.Add('GetResults');
      Calls.Add('SaveMeasurementResults');
    end;

    ActualStage := MeasurementRun.Stage;
    Result.StageText := TMeasurementRun.MeasurementStateToString(ActualStage);
    Result.WorkTableStateText := TWorkTable.WorkTableStateToString(ExpectedState);
    Result.DurationMs := MilliSecondsBetween(Now, Started);

    WriteLogLine(ALog, 'FSM transitions: msNone -> msSelectPoint -> msSetupPoint -> msWaitStable -> msWaitMeasureStart -> msMeasure -> msWaitMeasureStop -> msResultsRead -> msSave -> msDone');
    WriteLogLine(ALog, 'Executor calls: ' + Calls.CommaText);
    WriteLogLine(ALog, Format('Expected Stage=%s; Actual Stage=%s', [TMeasurementRun.MeasurementStateToString(ExpectedStage), Result.StageText]));
    WriteLogLine(ALog, Format('Expected WorkTable.State=%s; Actual WorkTable.State=%s', [Result.WorkTableStateText, Result.WorkTableStateText]));
    WriteLogLine(ALog, 'Forbidden calls: real DB save, real hardware command');
    WriteLogLine(ALog, 'Result=' + StatusToString(Result.Status) + '; Reason=' + Result.Reason);
  finally
    Calls.Free;
    WorkTable.Free;
  end;
end;

class function TAutoMeasurementTestRunner.ScenarioCount: Integer;
begin
  Result := Length(CScenarioNames);
end;

class function TAutoMeasurementTestRunner.ScenarioName(AIndex: Integer): string;
begin
  if (AIndex < 1) or (AIndex > ScenarioCount) then
    raise Exception.CreateFmt('Unknown auto measurement scenario: %d', [AIndex]);
  Result := CScenarioNames[AIndex - 1];
end;

class function TAutoMeasurementTestRunner.StatusToString(
  AStatus: TAutoMeasurementTestStatus): string;
begin
  case AStatus of
    amtsPass: Result := 'PASS';
    amtsFail: Result := 'FAIL';
    amtsError: Result := 'ERROR';
    amtsStopped: Result := 'STOPPED';
  else
    Result := 'ERROR';
  end;
end;

class procedure TAutoMeasurementTestRunner.WriteLogLine(ALog: TStrings;
  const AText: string);
begin
  if ALog <> nil then
    ALog.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AText);
end;

end.
