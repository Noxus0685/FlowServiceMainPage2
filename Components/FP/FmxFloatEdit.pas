unit FmxFloatEdit;

interface

uses
  System.SysUtils, System.Classes,FMX.Text, uFloatEdit, FMX.Controls, FMX.StdCtrls;
const
  cFloatEditStyle='floateditstyle';
type
  TFmxFloatEdit = class(TFloatEdit)
  private
    FValueChanged: TNotifyEvent;
    function GetIValue: integer;
    procedure SetIValue(const _Value: integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property IValue:integer read GetIValue write SetIValue;
  end;

procedure Register;

implementation

uses FmxHelper, Fmx.Types;

constructor TFmxFloatEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StyleLookup:=cFloatEditStyle;
  DecimalDigits := 2;
  Ext := '°C';
  ExtPosition:=False;
end;

destructor TFmxFloatEdit.Destroy;
begin
//  FocusedBtn.Free;
  inherited;
end;





function TFmxFloatEdit.GetIValue: integer;
begin
  result:=Round(Value);
end;




procedure TFmxFloatEdit.SetIValue(const _Value: integer);
begin
  Value:=_Value;
end;



procedure Register;
begin
  RegisterComponents('FMXFP', [TFmxFloatEdit]);
end;

end.

