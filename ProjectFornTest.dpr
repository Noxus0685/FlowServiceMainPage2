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
  fuDeviceEdit in 'fuDeviceEdit.pas' {FormDeviceEditor};

{$R *.res}


begin
  Application.Initialize;

  {--------------------------------------------------}
  { Инициализация менеджера БД и репозиториев }
  {--------------------------------------------------}
  DataManager:= TManagerTDM.Create(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'dbsettings.ini'
  );

  DataManager.Load;

  {--------------------------------------------------}
  { Передаём менеджер формам (через глобальную ссылку }
  { или через отдельный модуль AppContext) }
  {--------------------------------------------------}


  {--------------------------------------------------}
  { Формы }
  {--------------------------------------------------}
  Application.CreateForm(TFormDeviceSelect, FormDeviceSelect);
  Application.CreateForm(TFormTypeSelect, FormTypeSelect);
  Application.CreateForm(TFormTypeEditor, FormTypeEditor);
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormDeviceEditor, FormDeviceEditor);
  Application.Run;

  {--------------------------------------------------}
  { Завершение }
  {--------------------------------------------------}
  FreeAndNil(DataManager);
end.

