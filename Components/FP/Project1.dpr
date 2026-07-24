program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in '..\..\..\..\Work.FMX\errorind\Unit1.pas' {Form1},
  errorindicator in 'errorindicator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
