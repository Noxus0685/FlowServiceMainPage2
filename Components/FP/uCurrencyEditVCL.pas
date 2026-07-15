unit uCurrencyEditVCL;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls;

Type
 TKeyPress = Procedure (Sender: TObject; var Key: Char) of Object;

type
  TCurrencyEdit = class(TEdit)
  private
    { Private declarations }
   vFormatMask : String;
   vKeyPress   : TKeyPress;
  protected
    { Protected declarations }
   Function  GetValue : Currency;
   Procedure WriteValue(Value : Currency);
   Procedure FormatarComoMoeda(Var Key : Char);
   Procedure POnKeyPress(Sender: TObject; var Key: Char);
  public
    { Public declarations }
   Constructor Create(AOwner : TComponent);Override;
  published
    { Published declarations }
   Property FormatMask : String    Read vFormatMask Write vFormatMask;
   Property Value      : Currency  Read GetValue    Write WriteValue;
   Property OnKeyPress : TKeyPress Read vKeyPress   Write vKeyPress;
  end;

procedure Register;

implementation

Constructor TCurrencyEdit.Create(AOwner : TComponent);
Begin
 Inherited;
 vFormatMask  := '###,##0.00';
 TEdit(Self).OnKeyPress     := POnKeyPress;
 Text         := FormatFloat(vFormatMask, 0);
End;

Procedure TCurrencyEdit.POnKeyPress(Sender: TObject; var Key: Char);
Begin
 FormatarComoMoeda(Key);
 If Assigned(vKeyPress) Then
  vKeyPress(Sender, Key);
End;

Procedure TCurrencyEdit.WriteValue(Value : Currency);
Begin
 Text := FormatFloat(vFormatMask, Value);
End;

Function  TCurrencyEdit.GetValue : Currency;
Begin
 Result := 0;
 Try
  Result := StrToFloat(StringReplace(Self.Text, '.', '', [rfReplaceAll]));
 Except
  Self.Text := FormatFloat(vFormatMask, 0);
 End;
End;

Procedure TCurrencyEdit.FormatarComoMoeda(Var Key : Char);
Var
 str_valor : String;
 dbl_valor : double;
Begin
 { se tecla pressionada e' um numero, backspace ou del deixa passar }
 If (Key in ['0'..'9', #8, #9]) Then
  Begin
   { guarda valor do TEdit com que vamos trabalhar }
   str_valor := Text;
   { verificando se nao esta vazio }
   If str_valor = EmptyStr Then
    str_valor := '0,00' ;
   { se valor numerico ja insere na string temporaria }
   If Key in ['0'..'9'] Then
    str_valor := Concat(str_valor, Key);
   { retira pontos e virgulas se tiver! }
   str_valor := Trim(StringReplace(str_valor, '.', '', [rfReplaceAll, rfIgnoreCase]));
   str_valor := Trim(StringReplace(str_valor, ',', '', [rfReplaceAll, rfIgnoreCase]));
   {inserindo 2 casas decimais}
   dbl_valor := StrToFloat(str_valor);
   dbl_valor := (dbl_valor / 100);
   {retornando valor tratado ao TEdit}
   Text := FormatFloat(vFormatMask, dbl_valor);
   {reseta posicao do tedit}
   SelStart := Length(Text);
  End;
 {se nao e' key relevante entao reseta}
 If Not(Key in [#8, #9]) Then Key := #0;
 If Text = '' Then
  Begin
   Text     := FormatFloat(vFormatMask, 0);
   SelStart := Length(Text);
   Key      := #0;
  End;
end;

procedure Register;
Begin
 RegisterComponents('XyberPower Controls', [TCurrencyEdit]);
End;

end.
