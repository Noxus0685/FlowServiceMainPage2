program ProjectFornTest;

uses
  System.StartUpCopy,
  System.SysUtils,
  FMX.Forms,
  fuTypeSelect in 'fuTypeSelect.pas' {FormTypeSelect},
  fuTypeEditor in 'fuTypeEditor.pas' {FormTypeEditor},
  UnitBaseProcedures in 'UnitBaseProcedures.pas',
  UnitDataManager in 'UnitDataManager.pas',
  fuMain in 'fuMain.pas' {FormMain},
  UnitDeviceClass in 'UnitDeviceClass.pas',
  fuDeviceSelect in 'fuDeviceSelect.pas' {FormDeviceSelect},
  fuDeviceEdit in 'fuDeviceEdit.pas' {FormDeviceEditor},
  uDATA in 'uDATA.pas' {DM: TDataModule},
  UnitClasses in 'UnitClasses.pas',
  UnitFlowMeter in 'UnitFlowMeter.pas',
  fuMeterValues in 'fuMeterValues.pas' {FormMeterValues},
  UnitMeterValue in 'UnitMeterValue.pas',
  frmCalibrCoefs in 'frmCalibrCoefs.pas' {FrameCalibrCoefs: TFrame},
  frmProceed in 'frmProceed.pas' {FrameProceed: TFrame},
  frmMainTable in 'frmMainTable.pas' {FrameMainTable: TFrame},
  UnitWorkTable in 'UnitWorkTable.pas',
  UnitRepositories in 'UnitRepositories.pas',
  UnitMeasurementRun in 'UnitMeasurementRun.pas',
  FmxHelper in 'FmxHelper.pas',
  UnitParameters in 'UnitParameters.pas';

{$R *.res}


begin
  Application.Initialize;

  ForceDirectories(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'Settings'
  );

  {--------------------------------------------------}
  { Инициализация менеджера БД и репозиториев }
  {--------------------------------------------------}
  DataManager:= TManagerTDM.Create(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'Settings\\dbsettings.ini'
  );

  DataManager.Load;

  {--------------------------------------------------}
  { Передаём менеджер формам (через глобальную ссылку }
  { или через отдельный модуль AppContext) }
  {--------------------------------------------------}


  {--------------------------------------------------}
  { Формы }
  {--------------------------------------------------}
 // Application.CreateForm(TFormDeviceSelect, FormDeviceSelect);
 // Application.CreateForm(TFormTypeSelect, FormTypeSelect);
//  Application.CreateForm(TFormTypeEditor, FormTypeEditor);
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormMeterValues, FormMeterValues);
  //  Application.CreateForm(TFormDeviceEditor, FormDeviceEditor);
//  Application.CreateForm(TDM, DM);
  Application.Run;

  {--------------------------------------------------}
  { Завершение }
  {--------------------------------------------------}
  FreeAndNil(DataManager);
end.
