program ProjectFornTest;

uses
  FMX.Forms,
  FmxHelper in 'FmxHelper.pas',
  frmCalibrCoefs in 'frmCalibrCoefs.pas' {FrameCalibrCoefs: TFrame},
  frmFlowMeterProperties in 'frmFlowMeterProperties.pas' {FrameFlowMeterProperties: TFrame},
  frmMainTable in 'frmMainTable.pas' {FrameMainTable: TFrame},
  frmMeasurementRun in 'frmMeasurementRun.pas' {FrameMeasurementRun: TFrame},
  frmProceed in 'frmProceed.pas' {FrameProceed: TFrame},
  frmProtocol in 'frmProtocol.pas' {FrameProtocol: TFrame},
  fuDeviceEdit in 'fuDeviceEdit.pas' {FormDeviceEditor},
  fuDeviceSelect in 'fuDeviceSelect.pas' {FormDeviceSelect},
  fuMeterValues in 'fuMeterValues.pas' {FormMeterValues},
  fuTable_Main in 'fuTable_Main.pas' {TableMainForm},
  fuTypeEditor in 'fuTypeEditor.pas' {FormTypeEditor},
  fuTypeSelect in 'fuTypeSelect.pas' {FormTypeSelect},
  System.StartUpCopy,
  System.SysUtils,
  uBaseProcedures in 'uBaseProcedures.pas',
  uClasses in 'uClasses.pas',
  uDataManager in 'uDataManager.pas',
  uDeviceClass in 'uDeviceClass.pas',
  uFlowMeter in 'uFlowMeter.pas',
  uMeasurementRun in 'uMeasurementRun.pas',
  uMeterValue in 'uMeterValue.pas',
  uObservable in 'uObservable.pas',
  uParameter in 'uParameter.pas',
  uProtocols in 'uProtocols.pas',
  uRepositories in 'uRepositories.pas',
  uAppServices in 'uAppServices.pas',
  uTable_Data in 'uTable_Data.pas' {TableDM: TDataModule},
  uWorkTable in 'uWorkTable.pas';

{$R *.res}


begin
  Application.Initialize;
  AppServices := TAppServices.Create;
  AppServices.Initialize;


  {--------------------------------------------------}
  { Формы }
  {--------------------------------------------------}
 // Application.CreateForm(TFormDeviceSelect, FormDeviceSelect);
 // Application.CreateForm(TFormTypeSelect, FormTypeSelect);
//  Application.CreateForm(TFormTypeEditor, FormTypeEditor);
  Application.CreateForm(TTableMainForm, TableMainForm);
  Application.CreateForm(TFormMeterValues, FormMeterValues);
  //  Application.CreateForm(TFormDeviceEditor, FormDeviceEditor);
//  Application.CreateForm(TDM, DM);
  Application.Run;

  {--------------------------------------------------}
  { Централизованное завершение }
  {--------------------------------------------------}
  if AppServices <> nil then
    AppServices.Shutdown;
  FreeAndNil(AppServices);
end.
