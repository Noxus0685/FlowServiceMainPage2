program ProjectFornTest;

uses
  System.StartUpCopy,
  System.SysUtils,
  FMX.Forms,
  fuTypeSelect in 'fuTypeSelect.pas' {FormTypeSelect},
  fuTypeEditor in 'fuTypeEditor.pas' {FormTypeEditor},
  uBaseProcedures in 'uBaseProcedures.pas',
  uDataManager in 'uDataManager.pas',
  fuTable_Main in 'fuTable_Main.pas' {FormMain},
  uDeviceClass in 'uDeviceClass.pas',
  fuDeviceSelect in 'fuDeviceSelect.pas' {FormDeviceSelect},
  fuDeviceEdit in 'fuDeviceEdit.pas' {FormDeviceEditor},
  uTable_Data in 'uTable_Data.pas' {DM: TDataModule},
  uClasses in 'uClasses.pas',
  uFlowMeter in 'uFlowMeter.pas',
  fuMeterValues in 'fuMeterValues.pas' {FormMeterValues},
  uMeterValue in 'uMeterValue.pas',
  frmCalibrCoefs in 'frmCalibrCoefs.pas' {FrameCalibrCoefs: TFrame},
  frmProceed in 'frmProceed.pas' {FrameProceed: TFrame},
  frmMainTable in 'frmMainTable.pas' {FrameMainTable: TFrame},
  uWorkTable in 'uWorkTable.pas',
  uRepositories in 'uRepositories.pas',
  uMeasurementRun in 'uMeasurementRun.pas',
  FmxHelper in 'FmxHelper.pas',
  uParameter in 'uParameter.pas',
  frmMeasurementRun in 'frmMeasurementRun.pas' {FrameMeasurementRun: TFrame},
  uProtocols in 'uProtocols.pas',
  frmProtocol in 'frmProtocol.pas' {FrameProtocol: TFrame},
  frmFlowMeterProperties in 'frmFlowMeterProperties.pas' {FrameFlowMeterProperties: TFrame},
  uObservable in 'uObservable.pas';

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
