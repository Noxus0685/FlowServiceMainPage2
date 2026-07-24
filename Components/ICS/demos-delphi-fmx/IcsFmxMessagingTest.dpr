program IcsFmxMessagingTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  IcsFmxMessagingTestMain in 'IcsFmxMessagingTestMain.pas' {MessagingTestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMessagingTestForm, MessagingTestForm);
  Application.Run;
end.
