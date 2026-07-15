program IcsFmxNxMessagingTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  IcsFmxNxMessagingTestMain in 'IcsFmxNxMessagingTestMain.pas' {NxMessagingTestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TNxMessagingTestForm, NxMessagingTestForm);
  Application.Run;
end.
