unit FmxDecCompileTime;

interface

uses Classes, Fmx.Types;

type
  TFmxdecCompileTime = class(TComponent)
  public
    constructor Create(AOwner: TComponent); override;
  private
    procedure LoadCompTime(Reader: TReader);
    procedure SaveCompTime(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  private
    FTimer: TTimer;
    procedure OnTimer(Sender: TObject);
  private
    FCompilationTime: TDateTime;
  public
    property CompilationTime: TDateTime read FCompilationTime;
  end;

procedure Register;

implementation

uses SysUtils, FMX.Forms;

constructor TFmxdecCompileTime.Create(AOwner: TComponent);
begin
  inherited;
  FTimer := nil;
  if csDesigning in ComponentState then
    begin
      FTimer := TTimer.Create(Self);
      FTimer.OnTimer := Self.OnTimer;
    end;
end;

procedure TFmxdecCompileTime.LoadCompTime(Reader: TReader);
begin
  FCompilationTime := Reader.ReadDate;
end;

procedure TFmxdecCompileTime.SaveCompTime(Writer: TWriter);
begin
  Writer.WriteDate(Date + Time);
  if FTimer <> nil then FTimer.Enabled := true;
end;

procedure TFmxdecCompileTime.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('CompilTime', LoadCompTime, SaveCompTime, true);
end;

procedure TFmxdecCompileTime.OnTimer(Sender: TObject);
begin
//  if (Owner <> nil) and (Owner is TCustomForm) and (TCustomForm(Owner).Designer <> nil) then
//    TCustomForm(Owner).Designer.Modified;
  FTimer.Enabled := false;
end;

procedure Register;
begin
  RegisterComponents('Dec', [TFmxdecCompileTime]);
end;

end.
