unit FmxRxCurrEdit;

interface

uses
  System.SysUtils, System.Classes,FMX.Edit,  FMX.Controls, FMX.StdCtrls, FMX.Types, FMX.Graphics, FMX.Forms;

type
  TCustomNumEdit = class(TEdit)
  private
    FValue: Extended;
    FMinValue, FMaxValue: Extended;
    FDecimalPlaces: Cardinal;
    FBeepOnError: Boolean;
    FCheckOnExit: Boolean;
    FZeroEmpty: Boolean;
    FFormatOnEditing: Boolean;
    FDisplayFormat: string;
    FDecimalPlaceRound: Boolean;
    procedure SetValue(AValue: Extended);
    procedure SetMinValue(AValue: Extended);
    procedure SetMaxValue(AValue: Extended);
    procedure SetDecimalPlaces(Value: Cardinal);
    procedure SetBeepOnError(Value: Boolean);
    procedure SetDisplayFormat(const Value: string);
    procedure SetDecimalPlaceRound(Value: Boolean);
    function GetValue: Extended;
    function GetDisplayText: string;
    procedure UpdateData;
    procedure CheckRange;
    procedure ReformatEditText;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Value: Extended read GetValue write SetValue;
    property MinValue: Extended read FMinValue write SetMinValue;
    property MaxValue: Extended read FMaxValue write SetMaxValue;
    property DecimalPlaces: Cardinal read FDecimalPlaces write SetDecimalPlaces;
    property BeepOnError: Boolean read FBeepOnError write SetBeepOnError;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property DecimalPlaceRound: Boolean read FDecimalPlaceRound write SetDecimalPlaceRound;
  end;

  TFmxCurrEdit = class(TCustomNumEdit)
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TFmxCurrEdit]);
end;

{ TCustomNumEdit }

constructor TCustomNumEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDecimalPlaceRound := False;
  FBeepOnError := True;
  FDecimalPlaces := 2;
  FZeroEmpty := True;
  FDisplayFormat := ',0.##';
end;

destructor TCustomNumEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TCustomNumEdit.SetValue(AValue: Extended);
begin
  FValue := AValue;
  UpdateData;
end;

procedure TCustomNumEdit.SetMinValue(AValue: Extended);
begin
  FMinValue := AValue;
  CheckRange;
end;

procedure TCustomNumEdit.SetMaxValue(AValue: Extended);
begin
  FMaxValue := AValue;
  CheckRange;
end;

procedure TCustomNumEdit.SetDecimalPlaces(Value: Cardinal);
begin
  FDecimalPlaces := Value;
  UpdateData;
end;

procedure TCustomNumEdit.SetBeepOnError(Value: Boolean);
begin
  FBeepOnError := Value;
end;

procedure TCustomNumEdit.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
  UpdateData;
end;

procedure TCustomNumEdit.SetDecimalPlaceRound(Value: Boolean);
begin
  FDecimalPlaceRound := Value;
  UpdateData;
end;

function TCustomNumEdit.GetValue: Extended;
begin
  Result := FValue;
end;

function TCustomNumEdit.GetDisplayText: string;
begin
  Result := FormatFloat(FDisplayFormat, FValue);
end;

procedure TCustomNumEdit.UpdateData;
begin
  Text := GetDisplayText;
end;

procedure TCustomNumEdit.CheckRange;
begin
  if FValue < FMinValue then
    FValue := FMinValue
  else if FValue > FMaxValue then
    FValue := FMaxValue;
end;

procedure TCustomNumEdit.ReformatEditText;
begin
  Text := GetDisplayText;
end;

{ TFmxCurrEdit }

constructor TFmxCurrEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

end.
