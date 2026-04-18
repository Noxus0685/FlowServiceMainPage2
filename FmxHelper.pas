unit FmxHelper;

interface
uses  System.SysUtils,
      FMX.Platform,
      System.Generics.Collections,
      System.StrUtils, System.Types,
      System.IOUtils,
      FMX.Forms,
      FMX.Controls,
      FMX.Types,
      System.UIConsts,
      System.UITypes,
      System.Variants,
      IdGlobal,
      Fmx.Dialogs,
{$IFDEF MSWINDOWS}
      Winapi.Windows,
      Winapi.ShellScaling,
{$ENDIF}
{$IFDEF MACOS}
  Macapi.Foundation, Macapi.AppKit,
{$ENDIF}
{$IFDEF LINUX}
        System.Diagnostics,
{$ENDIF}
      System.Math,Fmx.Graphics;
const
  cUnderline='_';
  cDiv=',';
  CKEY1 = 15;
  CKEY2 = 32;
  VT_EMPTY  = varEmpty;       //$0000;
  VT_NULL = varNull;          //$0001;
  VT_I2 = varSmallint;        //$0002;
  VT_I4 = varInteger;         //$0003;
  VT_R4 = varSingle;          //$0004;
  VT_R8 = varDouble;          //$0005;
  VT_CY = varCurrency;        //$0006;
  VT_DATE = varDate;          //$0007;
  VT_BSTR = varOleStr;        //$0008;
  VT_DISPATCH = varDispatch;  //$0009;
  VT_ERROR  = varError;       //$000A;
  VT_BOOL = varBoolean;       //$000B;
  VT_VARIANT  = varVariant;   //$000C;
  VT_UNKNOWN  = varUnknown;   //$000D;
  VT_I1 = varShortInt;        //$0010;
  VT_UI1  = varByte;          //$0011;
  VT_UI2  = varWord;          //$0012;
  VT_UI4  = varLongWord;      //$0013;
  VT_I8 = varInt64;           //$0014;
  VT_UI8  = varUInt64;        //$0015;
  VT_RECORD = varRecord;      //$0024;
  //
  OPC_QUALITY_GOOD                      = $C0;
  OPC_QUALITY_CONFIG_ERROR              = $04;
  OPC_QUALITY_NOT_CONNECTED             = $08;
  OPC_QUALITY_DEVICE_FAILURE            = $0C;
  OPC_QUALITY_SENSOR_FAILURE            = $10;
  OPC_QUALITY_LAST_KNOWN                = $14;
  OPC_QUALITY_COMM_FAILURE              = $18;
  OPC_QUALITY_OUT_OF_SERVICE            = $1C;
  OPC_QUALITY_WAITING_FOR_INITIAL_DATA  = $20;


type
{$IFDEF  MSWNODWS}
  DWORD=LongWord;
  pDWORD=^DWORD;
{$ENDIF}
{$IFDEF  LINUX}
  DWORD=integer;
  pDWORD=^DWORD;
{$ENDIF}

  // Âñïîìîãàòåëüíûé òèï - òî÷êà â êàëèáðîâî÷íîé òàáëèöå ðàñõîäîìåðà.
  TCalibrationPoint = record

    // Ðàñõîä â ì3/÷, âûäàâàåìûé ðàñõîäîìåðîì ñ ó÷åòîì âåñà èìïóëüñà.
    WaterDischarge: Double;

    // Ïîïðàâî÷íûé êîýôôèöèåíò äëÿ äàííîé ÷àñòîòû.
    Coefficient: Double;

  end;

function IsStrDecimalInteger(AStr:String):boolean;
function IsStrFloat(AStr:ShortString):boolean;
function xCP(S: String):String;
function CP(AStr: String;changespace:boolean=false):String;
function StrToHex(aStr:String):String;
function BuffToHex(aStr:array of char; l:integer):String;
function B2HS(pBuff:Pbyte;len:integer):String;
procedure  HS2B(pBuff:Pbyte;aStr:String);
function CheckBase64CRC16(S:TBytes): boolean;
function PartOfStr(s:String;Part:integer;ch:Char=','):String;
procedure ODS(s:String);
function UTF2STR(ss:ShortString):ShortString;
function ANSI2STR(ss:ShortString):ShortString;
function ASCII2STR(ss:ShortString):ShortString;
function Char2Byte(ch: BYTE):char;
function GetKM5CRC(S:ShortString;Len:integer):Word;
function Get_CRC16(S:ShortString;len:integer):word;
function SafeMean(var avalue:array of double):double;
function CRC32String(AStr:ShortString):String;
function CRC32(AStr:ShortString):longword;
function WinRToKoiR (aStr: String): String;
function TryDecimalStrToInt( const S: string; out Value: Integer): Boolean;
function S2IDef(const val:String;default_value:integer):integer;
procedure SortCalibrationPointArray(var _array:array of TCalibrationPoint);
function KM5Body(NetAddr:longword;cmd:byte;Param1:byte=0;Param2:Single=0;Param3:Single=0):ShortString;overload;
function KM5Body(NetAddr:longword;cmd:byte;Param1:byte=0;Param2:byte=0;Param3:byte=0):ShortString;overload;
function CheckKM5BuffCRC(pBuff:PByte;Len:byte):boolean;
{$IFDEF MSWINDOWS}
function MySwap32(value : longword) : longword; assembler ;
{$ENDIF}
procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: NativeUInt);
procedure Zeromemory(Destination: Pointer; Length: NativeUInt);
function inttoBCD(tmpB:byte):AnsiChar;
function BCDtoInt(tmpB:byte):byte;
function S2F(AStr: String):single;
function F2S(AValue: Double):String;
procedure StrToFont(str: string; var font: TFont);
function FontToStr(font: TFont): string;
 function MySwap(value : longword) : longword;
function Swap16(const DataToSwap: Word): Word;
function Swap32(const DataToSwap: LongWord): LongWord;
procedure ErazeNegativeValue(var Data: array of Double);
function ConvertScale(InputValue, MinInput, MaxInput, MinOutput, MaxOutput: Double): Double;
function ReverseConvertScale(OutputValue, MinInput, MaxInput, MinOutput, MaxOutput: Double): Double;
function FmxColorToString(Color: TAlphaColor): string;
function CalculateAngle(CurrentValue, MinValue, MaxValue: Double; MaxAngle:Double=270): Double;
function ColorToAlphaColor(aColor:TColor):TAlphaColor;
function MyAlphaColorToStr(aColor:TAlphaColor):String;
function StrToAlphaColor(AStr:String):TAlphaColor;
function DialogYesNo(AMessage:String):Boolean;
function aDialogYesNo(AMessage:String;ATitle:String):Boolean;
procedure MessageBox_E(AMessage:String;ATitle:String);
procedure MessageBox_W(AMessage:String;ATitle:String);
procedure MessageBox_I(AMessage:String;ATitle:String);
procedure ShowDialogMessage(aMessage:String);
procedure OutputDebugMessage(const Msg: string);
function IfThen(AValue: Boolean; const ATrue: string; AFalse: string = ''): string;
function BoolToStr(AValue: Boolean; const ATrue: string; AFalse: string = ''): string;
function IdBytesToHex(const Bytes: TIdBytes): string;
function BytesToHex(const Bytes: TBytes): string;

{$IFDEF LINUX}
function GetTickCount: Int64;
procedure  OutputDebugString(Msg:PChar);
{$ENDIF}
function CRC16(S:String;len:integer):word;
function GetCRC16(twoSym:array of word; size:Word):Word;
function StrToByte(p1:string):integer;
function ApplicationExeName():String;
{$IFDEF MSWINDOWS}
function IsRunningAsAdmin: Boolean;
function GetTextFromClipboard: string;
procedure CopyTextToClipboard(const Text: string);
{$ENDIF}
{$IFDEF MACOS}
function GetTextFromClipboard: string;
procedure CopyTextToClipboard(const Text: string);
{$ENDIF}
procedure ChangeBitmapColor(ABitmap: FMX.Graphics.TBitmap; NewColor: TAlphaColor);
function DecryptStr(const S: String; Key: LongWord): String;
function EncryptStr(const S :WideString; Key: LongWord): String;
procedure _MessageBox(AHandle:longint;AMessage:string;ADopMessage:string;AICON:Integer);
function StrToMask(AString:String):longword;
function MaskToStr(AMask:longword):String;
function IsValueInRange(const RangeStr: string; Value: Integer): Boolean;
function GetElementByIndex(const RangeStr: string; Index: Integer): Integer;
function TwosComplementToDecimal(hexValue: Word): Integer;
procedure copymem(dest,src:PByte;len:integer);
function IfThenInt(AValue: Boolean; const ATrue: integer; AFalse: integer): integer;
procedure IncF(var x:Single; delta:integer);
function DecToHex(DecDigit:longword):LongWord;
function VarToIntDef(const V: Variant; Default: Integer): Int64;
function WordToBytes(Value: Word): ShortString;
function ExtractSignParameter(const ResponseString: string; ParamNumber: Integer): string;
function ExtractParameter(S: string; ParamNum: integer; StrDivider: Char = ' '): string;
function MilliSecondsBetween(const ANow, AThen: TDateTime): Int64;
function Str2Hex(aStr:String): string;
procedure WriteLog(const Msg: string);
function GetFileNameWithoutExtension(const FileName: string): string;
function GetSecondsBetweenDates(const ADate1, ADate2: TDateTime): Int64;




implementation
uses
  Classes,
  System.DateUtils,
  System.SyncObjs;

var
  LogCriticalSection: TCriticalSection;

const
  PICCHAR:array[$C0..$FF] of cHAR=( 'À','Á','Â','Ã','Ä','Å','Æ','Ç','È',
  'É','Ê',  'Ë','Ì','Í','Î','Ï','Ð','Ñ','Ò','Ó','Ô',
  'Õ','Ö','×','Ø','Ù','Ú','Û','Ü','Ý','Þ','ß',
  'à','á','â','ã','ä','å','æ','ç','è','é','ê','ë','ì',
  'í','î','ï','ð','ñ','ò','ó','ô','õ','ö','÷','ø','ù',
  'ú','û','ü','ý','þ','ÿ'
  );

CRCtable:  ARRAY[0..255] OF LongWord =
    ($00000000, $77073096, $EE0E612C, $990951BA,
    $076DC419, $706AF48F, $E963A535, $9E6495A3,
    $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
    $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
    $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC,
    $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
    $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
    $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940,
    $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116,
    $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
    $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,
    $76DC4190, $01DB7106, $98D220BC, $EFD5102A,
    $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
    $7807C9A2, $0F00F934, $9609A88E, $E10E9818,
    $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
    $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
    $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C,
    $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
    $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
    $5005713C, $270241AA, $BE0B1010, $C90C2086,
    $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4,
    $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,
    $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
    $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
    $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE,
    $F762575D, $806567CB, $196C3671, $6E6B06E7,
    $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
    $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
    $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
    $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
    $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F,
    $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04,
    $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
    $9B64C2B0, $EC63F226, $756AA39C, $026D930A,
    $9C0906A9, $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
    $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
    $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E,
    $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
    $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
    $A7672661, $D06016F7, $4969474D, $3E6E77DB,
    $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
    $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6,
    $BAD03605, $CDD70693, $54DE5729, $23D967BF,
    $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
    $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);

crctab: array[0..255] OF word = (
    $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040 );

{$IFDEF LINUX}
procedure  OutputDebugString(Msg:PChar);
begin
  //Ïîêà èãíîðèðóåì
end;
{$ENDIF}

function IsStrFloat(AStr:ShortString):boolean;
var s:String;
    i:integer;
begin
   result:=True;
   s:=Trim(AStr);
   for i:=1 to Length(s) do
   begin
    if not (s[i] in ['0'..'9',',','.']) then
    begin
      result:=False;
      break;
    end;
   end;
end;

function IsStrDecimalInteger(AStr:String):boolean;
var s:String;
    i:integer;
begin
   result:=True;
   s:=Trim(AStr);
   for i:=1 to Length(s) do
   begin
    if not (s[i] in ['0'..'9']) then
    begin
      result:=False;
      break;
    end;
   end;
end;

function xCP(S: String):String;
var ch:char;
    i:integer;
begin
   result:='';
   for i:=1 to Length(S) do
   begin
    ch:='*';
    case s[i] of
    '0'..'9': ch:=s[i];
    ',','.': ch:=FormatSettings.DecimalSeparator;
    end;
    if ch<>'*' then result:=result+ch;
   end;
end;

function CP(AStr: String;changespace:boolean=false):String;
var S:String;
    i:integer;
begin
   S:=AStr;
   for i:=1 to Length(AStr) do
   begin
    case s[i] of
    ',',
    '.': if S[i]<>FormatSettings.DecimalSeparator then S[i]:=FormatSettings.DecimalSeparator;
    ' ': if changespace then S[i]:='0';
    end;
   end;
   result:=S;
end;


function StrToHex(aStr:String):String;
var l:integer;
    i:integer;
begin
    l:=Length(aStr);
    result:='';
    for i := 1 to l do
      result:=result+IntToHex(ord(aStr[i]),2);
end;

function BuffToHex(aStr:array of char; l:integer):String;
var i:integer;
begin
    result:='';
    for i := 1 to l do
      result:=result+IntToHex(ord(aStr[i-1]),2);
end;

const tables: array[0..255] of WORD=(
            $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
            $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
            $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
            $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
            $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
            $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
            $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
            $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
            $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
            $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
            $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
            $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
            $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
            $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
            $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
            $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
            $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
            $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
            $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
            $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
            $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
            $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
            $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
            $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
            $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
            $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
            $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
            $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
            $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
            $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
            $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
            $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040);

  WinR: Array[0..66] of Char = ('à', 'á', 'â', 'ã', 'ä', 'å', '¸', 'æ', 'ç', 'è',
    'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ð', 'ñ', 'ò',
    'ó', 'ô', 'õ', 'ö', '÷', 'ø', 'ù', 'ú', 'û', 'ü',
    'ý', 'þ', 'ÿ', 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', '¨',                                                                /// ñ ýòîé ïðîáëåìîé íå çíàë êàê
    'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï',                                                               //êàê ðàçîáðàòüñÿ ñ êîäèðîâêîé áûëè
    'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', '×', 'Ø', 'Ù',                                                           // ïðîáëåìû è ñ ïîìîùüþ ýòîãî ðåøèë
    'Ú', 'Û', 'Ü', 'Ý', 'Þ', 'ß', '¹');
  KoiR: Array[0..66] of Char = ('Á', 'Â', '×', 'Ç', 'Ä', 'Å', '£', 'Ö', 'Ú', 'É',
    'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ð', 'Ò', 'Ó', 'Ô',
    'Õ', 'Æ', 'È', 'Ã' ,'Þ', 'Û', 'Ý', 'ß', 'Ù', 'Ø',
    'Ü', 'À', 'Ñ', 'á', 'â', '÷', 'ç', 'ä', 'å', '³',
    'ö', 'ú', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ð',
    'ò', 'ó', 'ô', 'õ', 'æ', 'è', 'ã', 'þ', 'û', 'ý',
    'ÿ', 'ù', 'ø', 'ü', 'à', 'ñ', '?');
//Èç Cyrillic Windows-1251 â Cyrillic (KOI8-R)
function WinRToKoiR (aStr: String): String;
var
  i, j, Index: Integer;
begin
   Result := EmptyStr;
  for i := 1 to Length(aStr) do
   begin
    Index := -1;
     for j := Low(WinR) to High(WinR) do
      if WinR[j] = aStr[i] then
       begin
        Index := j;
        Break;
       end;
      if Index = -1 then
       Result := Result + aStr[i]
      else
       Result := Result + KoiR[Index];
   end;
end;


function CheckBase64CRC16(S:TBytes): boolean;
var CRC: WORD;
    i,len: integer;
begin
  crc:=$FFFF;
  len:=length(s);
  for i:=4 to Len-1 do crc:=(crc shr 8) xor tables[(crc xor s[i]) and $FF];
  result:=(crc=PWORD(@s[2])^);
end;

function CTimetoDateTime(const AValue: longword): TDateTime;
begin
  Result := AValue/86400.0 + 36526;
end;

const
  ht:array[0..15] of char=('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

function B2HS(pBuff:Pbyte;len:integer):String;
var i:integer;
begin
  result:='';
  for I := 0 to len-1 do
  begin
    result:=result+ht[pBuff[I] shr 4]+ht[pBuff[I] and $0F];
  end;


end;

procedure  HS2B(pBuff:Pbyte;aStr:String);
var i,j,len:integer;
    b:byte;
begin
  len:=Length(aStr);
  i:=0;j:=0;
  while (i<len) do
  begin
    inc(i);//ïåðâûé ñòàðøèé ïîëóáàéò
    b:=0;
    if aStr[i] in ['0'..'9','A'..'F'] then
    begin
      if (aStr[i] in ['0'..'9']) then
        b:=(ord(aStr[i])-ord('0')) shl 4
      else
        b:=((ord(aStr[i])-ord('A'))+10) shl 4;
    end;
    if i<len then begin
      inc(i);//âòîðîé ìëàäøèé ïîëóáàéò
      if aStr[i] in ['0'..'9','A'..'F'] then
      begin
        if (aStr[i] in ['0'..'9']) then
          b:=b+(ord(aStr[i])-ord('0'))
        else
          b:=b+((ord(aStr[i])-ord('A'))+10);
      end;
    end;
    pBuff[j]:=b;
    Inc(j);
  end;//while
end;




function PartOfStr(s:String;Part:integer;ch:Char=','):String;
var i,cnt:integer;
    tmpStr:String;
begin
              Cnt:=0;
              tmpStr:='';
              for I := Low(s) to High(s) do
              begin
                  if ((s[i]=ch) or (s[i]=#13)) then
                  begin
                    Inc(Cnt);
                    if Cnt=Part then break;
                    tmpStr:='';
                  end
                  else if not (s[i] in [#13,#10,' ']) then
                    tmpStr:=tmpStr+s[i];
                end;
              result:=tmpStr;
end;

procedure ODS(s:String);
begin
  OutputDebugString(PChar(s));
end;


function UTF2STR(ss:ShortString):ShortString;
var  s: string;
  i: byte;
 datain: TBytes;
 len:integer;
begin
  try
    result:='';
    len:=length(ss);
    if len>0 then
    begin
      setlength(datain,len);
      for i:=0 to len-1 do datain[i]:=ord(ss[i+1]);
      s:= TEncoding.UTF8.GetString(datain);
      result:=s;
    end;
  except
    ODS(Format('exception: len=%d str=%s',[len,ss]));
  end;
end;

function ANSI2STR(ss:ShortString):ShortString;
var  s: string;
  i: byte;
 datain: TBytes;
 len:integer;
begin
  try
    result:='';
    len:=length(ss);
    if len>0 then
    begin
      setlength(datain,len);
      for i:=0 to len-1 do datain[i]:=ord(ss[i+1]);
      s:= TEncoding.ANSI.GetString(datain);
      result:=s;
    end;
  except
    ODS(Format('exception: len=%d str=%s',[len,ss]));
  end;
end;

function ASCII2STR(ss:ShortString):ShortString;
var  s: string;
  i: byte;
 datain: TBytes;
 len:integer;
begin
  try
    result:='';
    len:=length(ss);
    if len>0 then
    begin
      setlength(datain,len);
      for i:=0 to len-1 do datain[i]:=ord(ss[i+1]);
      s:= TEncoding.Default.GetString(datain);
      result:=s;
    end;
  except
    ODS(Format('exception: len=%d str=%s',[len,ss]));
  end;
end;


function Char2Byte(ch: BYTE):char;
begin
    if (ord(ch) in [$C0..$FF]) then
       result:=PICCHAR[ord(ch)]
    else
        result:=cHAR(ch);
end;


function GetKM5CRC(S:ShortString;Len:integer):Word;
var CRC:Word;
    bt:byte;
    aCRC:array[1..2]of byte absolute CRC;
    i:integer;
begin
  CRC:=0;
  for i := 1 to Len do
  begin
    bt:=Ord(S[i]);
    aCRC[1]:=byte(aCRC[1] xor bt);
    aCRC[2]:=byte(aCRC[2] + bt);
  end;
  result:=CRC;
end;



function Get_CRC16(S:ShortString;len:integer):word;
var W:word;
    B:array[1..2]of byte absolute W;
    i,j:integer;

begin
  W:=$FFFF;
  for i := 1 to Len do
  begin
     W:=(W div 256)*256+((W mod 256) xor ord(s[i]));
     for j := 0 to 7 do
     begin
         if (W and 1) = 1 then
            W:=(W shr 1) xor $a001
         else
            W:=W shr 1;
     end;
  end;
  result:=W;
end;

function SafeMean(var avalue:array of double):double;
var i,l,len:integer;

    tmpD:Double;
begin
  result:=0;
  tmpD:=0;
  len:=0;
  l:=Length(avalue);
  try
    for i:= 0 to l-1 do
    begin
        tmpD:=tmpD+avalue[i];
        inc(len);
    end;
    if Len>0 then
       result:=tmpD/len;
  except
//    on e:exception do
//       OutputDebugString(PChar('SafeMean Error:'+e.Message));
  end;
end;


function CRC32(AStr:ShortString):longword;
 var CRCvalue:longword;
     i:integer;
begin
        CRCValue := $FFFFFFFF;
        try
          for   i := 1 to Length(Astr) do
          begin
            CRCvalue := (CRCvalue SHR 8)  XOR CRCTable[ (Ord(Astr[i]) XOR (CRCvalue AND $000000FF)) and $ff];
          end;
        finally
          result:=CRCvalue;
        end;
end;

function CRC32String(AStr:ShortString):String;
begin
   result:=Format('%8.8x',[CRC32(AStr)]);
end;

function TryDecimalStrToInt( const S: string; out Value: Integer): Boolean;
begin
   result := ( pos( '$', S ) = 0 ) and TryStrToInt( S, Value );
end;


//Âûáèðàåò èç ñòòðîêè öèôðû, ðàçðåøàåòñÿ ââîä Hex
function S2IDef(const val:String;default_value:integer):integer;
var i:integer;
    s,res:string;
    hex:Boolean;
begin
     hex:=False;
     s:=UpperCase(Val);res:='';
     //âûáèðàåì òîëüêî öèôðû
     for i:=1 to Length(s) do
     begin
       if s[i] in ['X','$'] then hex:=True;
       if hex then
       begin
         if s[i] in ['0'..'9','A'..'F'] then
            res:=res+s[i];
       end
       else
         if s[i] in ['0'..'9'] then
            res:=res+s[i];
     end;
     if hex then res:='$'+res;
     //Ñîõðàíÿåì çíà÷åíèå â Tag
     if res<>'' then
       result:=StrToIntDef(res,default_value);
end;


//ïóçûðüêîâàÿ ñîðòèðîâêà
procedure SortCalibrationPointArray(var _array:array of TCalibrationPoint);
var i,j:Integer;
    tmp:TCalibrationPoint;
begin
   for I := Low(_array) to High(_array) do
   begin
     for J := Low(_array) to High(_array)-1 do
      begin
         if _array[j].WaterDischarge>_array[j+1].WaterDischarge then
         begin
          //îáìåí ýëåìåíòîâ
          tmp:=_array[j];
          _array[j]:=_array[j+1];
          _array[j+1]:=tmp;
         end;
      end;
   end;
end;


const
  cHexBuf : packed array[0..$F] of Char = '0123456789ABCDEF';
function KM5Body(NetAddr:longword;cmd:byte;Param1:byte=0;Param2:Single=0;Param3:Single=0):ShortString;
var FOutputBuff:ShortString;
    CRC:word;
    tmpL:longword;
    tmpF:single absolute tmpL;
begin
    FOutputBuff:=#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    Plongword(@FOutputBuff[1])^:=NetAddr;
    FOutputBuff[5]:=AnsiChar(cmd);
    FOutputBuff[6]:=AnsiChar(Param1);
    tmpF:=Param2;
    Plongword(@FOutputBuff[7])^:=tmpL;
    tmpF:=Param3;
    Plongword(@FOutputBuff[11])^:=tmpL;
    CRC:=GetKM5CRC(FOutputBuff,14);
    Pword(@FOutputBuff[15])^:=CRC;
    result:=FOutputBuff;
end;


function KM5Body(NetAddr:longword;cmd:byte;Param1:byte=0;Param2:byte=0;Param3:byte=0):ShortString;
var FOutputBuff:ShortString;
    CRC:word;
    tmpL:longword;
    tmpF:single absolute tmpL;
begin
    FOutputBuff:=#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    Plongword(@FOutputBuff[1])^:=NetAddr;
    FOutputBuff[5]:=AnsiChar(cmd);
    FOutputBuff[6]:=AnsiChar(Param1);
    FOutputBuff[7]:=AnsiChar(Param2);
    FOutputBuff[8]:=AnsiChar(Param3);
    CRC:=GetKM5CRC(FOutputBuff,14);
    Pword(@FOutputBuff[15])^:=CRC;
    result:=FOutputBuff;
end;


function CheckKM5BuffCRC(pBuff:PByte;Len:byte):boolean;
var
    i,b:byte;
    CRC,CRC1:word;
    aCRC:array[1..2]of byte absolute CRC;
begin
  CRC:=0;
  for i := 0 to Len-3 do
  begin
    b:=pBuff[i];
    aCRC[1]:=aCRC[1] xor b;
    aCRC[2]:=(aCRC[2] + b) and $ff;
  end;
  CRC1:=PWORD(@pBuff[len-2])^;
  result:=(CRC1=CRC);
end;

{$IFDEF MSWINDOWS}
function MySwap32(value : longword) : longword; assembler ;
 asm
    rol eax, 16
    inc eax
    jz @@m1
    dec eax
@@m1:
 end;
 {$ENDIF}

 function MySwap(value : longword) : longword;
var
    body:LongWord;
    tmpB:array[1..4] of byte absolute body;
 begin
    body:=value;
    result:=(longword(tmpB[1]) shl 24)+(longword(tmpB[2]) shl 16)+(Longword(tmpB[3]) shl 8)+tmpB[4];
 end;


function inttoBCD(tmpB:byte):AnsiChar;
begin
  result:=AnsiChar((tmpB div 10)*16 + (tmpB mod 10));
end;

function BCDtoInt(tmpB:byte):byte;
begin
  result:=((tmpB shr 4) and $0f) * 10 + (tmpB and $0F);
end;

function S2F(AStr: String):single;
begin
    result:=StrToFloatDef(CP(AStr),0);
end;


function F2S(AValue: Double):String;
begin
    result:=FloatToStr(AValue);
end;

function tok(sep: string; var s: string): string;

  function isoneof(c, s: string): Boolean;
  var
    iTmp: integer;
  begin
    Result := False;
    for iTmp := 1 to Length(s) do
    begin
      if c = Copy(s, iTmp, 1) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
var

  c, t: string;
begin

  if s = '' then
  begin
    Result := s;
    Exit;
  end;
  c := Copy(s, 1, 1);
  while isoneof(c, sep) do
  begin
    s := Copy(s, 2, Length(s) - 1);
    c := Copy(s, 1, 1);
  end;
  t := '';
  while (not isoneof(c, sep)) and (s <> '') do
  begin
    t := t + c;
    s := Copy(s, 2, length(s) - 1);
    c := Copy(s, 1, 1);
  end;
  Result := t;
end;

function FontToStr(font: TFont): string;
  procedure yes(var str: string);
  begin

    str := str + 'y';
  end;
  procedure no(var str: string);
  begin

    str := str + 'n';
  end;
begin

  {êîäèðóåì âñå àòðèáóòû TFont â ñòðîêó}
  Result := '';
  Result := Result + font.Family + '|';
  Result := Result + FloatToStr(font.Size) + '|';
  if TFontStyle.fsBold in font.style then
    yes(Result)
  else
    no(Result);
  if TFontStyle.fsItalic in font.style then
    yes(Result)
  else
    no(Result);
  if TFontStyle.fsUnderline in font.style then
    yes(Result)
  else
    no(Result);
  if TFontStyle.fsStrikeout in font.style then
    yes(Result)
  else
    no(Result);
end;

procedure StrToFont(str: string; var font: TFont);
var size:integer;
    style:String;
begin

  if str = '' then
    Exit;
  size:=StrToIntDef(str,0);
  if size=0 then
  begin
    font.Family := tok('|', str);
    font.Size := StrToFloat(tok('|', str));
    font.Style := [];
    style:=tok('|', str);
    if style[1] = 'y' then
      font.Style := font.Style + [TFontStyle.fsBold];
    if style[2] = 'y' then
      font.Style := font.Style + [TFontStyle.fsItalic];
    if style[3] = 'y' then
      font.Style := font.Style + [TFontStyle.fsUnderline];
    if style[4] = 'y' then
      font.Style := font.Style + [TFontStyle.fsStrikeout];
  end
  else begin
    //äëÿ ñòàðîãî âàðèàíòà
    font.Size := Size;
  end;
end;

function Swap16(const DataToSwap: Word): Word;
begin
  Result := (DataToSwap div 256) + ((DataToSwap mod 256)*256);
end;

function Swap32(const DataToSwap: LongWord): LongWord;
begin
  Result := (DataToSwap shl 16) + (DataToSwap shr 16);
end;


procedure ErazeNegativeValue(var Data: array of Double);
var
  I: Integer;
begin
  for I := Low(Data)  to High(Data) do
    if Data[I]<0 then
      Data[I]:=0;
end;

function ConvertScale(InputValue, MinInput, MaxInput, MinOutput, MaxOutput: Double): Double;
begin
  Result := ((InputValue - MinInput) / (MaxInput - MinInput)) * (MaxOutput - MinOutput) + MinOutput;
end;

function ReverseConvertScale(OutputValue, MinInput, MaxInput, MinOutput, MaxOutput: Double): Double;
begin
  Result := ((OutputValue - MinOutput) / (MaxOutput - MinOutput)) * (MaxInput - MinInput) + MinInput;
end;


function FmxColorToString(Color: TAlphaColor): string;
begin
  Result := Format('#%2.2X%2.2X%2.2X%2.2X', [TAlphaColorRec(Color).A, TAlphaColorRec(Color).R, TAlphaColorRec(Color).G, TAlphaColorRec(Color).B]);
end;


function CalculateAngle(CurrentValue, MinValue, MaxValue: Double; MaxAngle:Double=270): Double;
begin
  // Ïðîâåðÿåì, ÷òî òåêóùåå çíà÷åíèå íàõîäèòñÿ â ïðåäåëàõ îò ìèíèìàëüíîãî äî ìàêñèìàëüíîãî çíà÷åíèÿ
  if CurrentValue < MinValue then
    CurrentValue := MinValue
  else if CurrentValue > MaxValue then
    CurrentValue := MaxValue;

  // Ðàññ÷èòûâàåì óãîë ïîâîðîòà
  Result := (CurrentValue - MinValue) / (MaxValue - MinValue) * MaxAngle;
end;

function ColorToIntColor(Color: TColor): Longint;
begin
  Result := Color;
end;

(*
âû ìîæåòå èñïîëüçîâàòü $ 00BBGGRR

BB = Ñèíèé
GG = Çåëåíûé
RR = Êðàñíûé

Âñå ýòè çíà÷åíèÿ ìîãóò áûòü îò 0 äî 255 ($ 00 è $ FF)
*)
function ColorToAlphaColor(aColor:TColor):TAlphaColor;
var rgbcolor:LongWord;
    X:array [1..4] of byte absolute rgbcolor;
    alpahcolor:LongWord;
    Y:array [1..4] of byte absolute alpahcolor;
begin
  rgbcolor:=ColorToIntColor(aColor);
  Y[4]:=255;
  Y[3]:=X[1];
  Y[2]:=X[2];
  Y[1]:=X[3];
  result:=alpahcolor;
end;

function MyAlphaColorToStr(aColor:TAlphaColor):String;
begin
  result:=AlphaColorToString(aColor);
end;
function StrToAlphaColor(AStr:String):TAlphaColor;
begin
  result:=StringToAlphaColor(AStr);
end;


function aDialogYesNo(AMessage:String;ATitle:String):Boolean;
begin
{$IFDEF  MSWINDOWS}
  result:=MessageBoxW(0,PWideChar(AMessage),PWideChar(ATitle), MB_YESNO + MB_ICONQUESTION +
        MB_TOPMOST)=mrYes;
{$ELSE}
  result:=DialogYesNo(AMessage);
{$ENDIF}
end;

procedure MessageBox_E(AMessage:String;ATitle:String);
begin
{$IFDEF  MSWINDOWS}
  MessageBoxW(0, PWideChar(AMessage),PWideChar(ATitle), MB_OK + MB_ICONSTOP + MB_TOPMOST);
{$ENDIF}
end;

procedure MessageBox_W(AMessage:String;ATitle:String);
begin
{$IFDEF  MSWINDOWS}
  MessageBoxW(0, PWideChar(AMessage),PWideChar(ATitle), MB_OK + MB_ICONWARNING + MB_TOPMOST);
{$ENDIF}
end;

procedure MessageBox_I(AMessage:String;ATitle:String);
begin
{$IFDEF  MSWINDOWS}
  MessageBoxW(0, PWideChar(AMessage),PWideChar(ATitle), MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
{$ENDIF}
end;


function DialogYesNo(AMessage:String):Boolean;
begin
  result:=MessageDlg(AMessage, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0)=mrYes;
end;



function IfThen(AValue: Boolean; const ATrue: string;
  AFalse: string = ''): string;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function BoolToStr(AValue: Boolean; const ATrue: string; AFalse: string = ''): string;
begin
  result:=IfThen(AValue,ATrue,AFalse);
end;

{$IFDEF LINUX}
function GetTickCount: Int64;
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  Result := Stopwatch.ElapsedMilliseconds;
  Stopwatch.Stop;
end;
{$ENDIF}

procedure OutputDebugMessage(const Msg: string);
begin
{$IFDEF LINUX}
  WriteLn(Msg); // Èëè èñïîëüçóéòå äðóãîé ìåòîä ïî âàøåìó âûáîðó
{$ELSE}
  OutputDebugString(PChar(Msg));
{$ENDIF}
end;

function CRC16(S:String;len:integer):word;
var W:word;
    B:array[1..2]of byte absolute W;
    i,j:integer;

begin
  W:=$FFFF;
  for i := 1 to Len do
  begin
     W:=(W div 256)*256+((W mod 256) xor ord(s[i]));
     for j := 0 to 7 do
     begin
         if (W and 1) = 1 then
            W:=(W shr 1) xor $a001
         else
            W:=W shr 1;
     end;
  end;
  result:=W;
end;


function GetCRC16(twoSym:array of word; size:Word):Word;
var
 i:Integer;
 crc:Word;
 idx:byte;
begin
  crc:=$FFFF;

  for i:=0 to ((size div 2)-1) do
  begin
    idx:=(crc and $FF) xor twoSym[i];
    crc:=  (crc shr 8) xor CrcTab[idx];
  end;
  Result:=(crc shr 8) or word(crc shl 8);
end;

function StrToByte(p1:string):integer;
const hex:array['A'..'F'] of Word=(10,11,12,13,14,15);
var
 Int,i:Integer;
begin
   Int:=0;
       for i := 1 to Length(P1) do
        if P1[i] < 'A' then Int := Int * 16 + ORD(P1[i]) - 48
        else Int := Int * 16 + HEX[p1[i]];
   Result:=int;
end;

function ApplicationExeName():String;
begin
 result:=ParamStr(0);
end;


{$IFDEF MSWINDOWS}
procedure SetDPIAwareness(Awareness: PROCESS_DPI_AWARENESS);
begin
  SetProcessDpiAwareness(Awareness);
end;

procedure SetDPIAwarenessContext(Context: DPI_AWARENESS_CONTEXT);
begin
  if not SetProcessDpiAwarenessContext(Context) then
    RaiseLastOSError;
end;
{$ENDIF}


{$IFDEF MSWINDOWS}
function CheckTokenMembership(TokenHandle: THandle; SidToCheck: PSID; IsMember: PBOOL): BOOL; stdcall; external 'advapi32.dll' name 'CheckTokenMembership';
{$ENDIF}

{$IFDEF MSWINDOWS}
function IsRunningAsAdmin: Boolean;
const
  SECURITY_NT_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID: DWORD = $00000020;
  DOMAIN_ALIAS_RID_ADMINS: DWORD = $00000220;
var
  hToken: THandle;
  AdminSID: PSID;
  IsAdmin: BOOL;
begin
  // Îòêðûòü òåêóùèé òîêåí ïðîöåññà
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hToken) then
  try
    // Ñîçäàòü SID äëÿ ãðóïïû àäìèíèñòðàòîðîâ
    if AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, AdminSID) then
    try
      // Ïðîâåðèòü, ÿâëÿåòñÿ ëè òåêóùèé ïîëüçîâàòåëü ÷ëåíîì ãðóïïû àäìèíèñòðàòîðîâ
{$IFDEF MSWINDOWS}
      if CheckTokenMembership(hToken, AdminSID, @IsAdmin) then
        Result := IsAdmin;
{$ENDIF}
{$IFDEF LINUX}
      if CheckTokenMembership(hToken, AdminSID, @IsAdmin) then
        Result := IsAdmin;
{$ENDIF}
    finally
      FreeSid(AdminSID);
    end;
  finally
    CloseHandle(hToken);
  end;
end;
{$ENDIF}


procedure ChangeBitmapColor(ABitmap: FMX.Graphics.TBitmap; NewColor: TAlphaColor);
var
  X, Y: Integer;
  Data: TBitmapData;
begin
  if ABitmap.Map(TMapAccess.ReadWrite, Data) then
  try
    for Y := 0 to Data.Height - 1 do
      for X := 0 to Data.Width - 1 do
        Data.SetPixel(X, Y, NewColor);
  finally
    ABitmap.Unmap(Data);
  end;
end;

function EncryptStr(const S :WideString; Key: LongWord): String;
var   i,len          :Integer;
      RStr       :RawByteString;
      RStrB      :TBytes Absolute RStr;
begin
  Result:= '';
  RStr:= UTF8Encode(S);
  len:=Length(RStr);
  for i := 0 to len-1 do begin
    RStrB[i] := RStrB[i] xor (Word(Key And $ffff) shr 8);
    Key := ((RStrB[i] + Key) * CKEY1 + CKEY2) and $0000ffff;
  end;
  for i := 0 to Length(RStr)-1 do begin
    Result:= Result + IntToHex(RStrB[i], 2);
  end;
end;

function DecryptStr(const S: String; Key: LongWord): String;
var   i, tmpKey  :Integer;
      RStr       :RawByteString;
      RStrB      :TBytes Absolute RStr;
      tmpStr     :string;
begin
  tmpStr:= UpperCase(S);
  SetLength(RStr, Length(tmpStr) div 2);
  i:= 1;
  try
    while (i < Length(tmpStr)) do
    begin
      if (tmpStr[i] in ['0'..'9','A'..'F']) and
         (tmpStr[i+1] in ['0'..'9','A'..'F'])  then
      begin
        RStrB[i div 2]:= StrToInt('$' + tmpStr[i] + tmpStr[i+1]);
        Inc(i, 2);
      end
      else begin
        Result:= '';
        Exit;
      end;
    end;
  except
    Result:= '';
    Exit;
  end;
  for i := 0 to Length(RStr)-1 do begin
    tmpKey:= RStrB[i];
    RStrB[i] := RStrB[i] xor (Word(Key and $ffff) shr 8);
    Key := ((tmpKey + Key) * CKEY1 + CKEY2) and $0000ffff;
  end;
  Result:= UTF8Decode(RStr);
end;


{$IFDEF MSWINDOWS}
procedure CopyTextToClipboard(const Text: string);
var
  Data: HGLOBAL;
  P: PChar;
begin
  Data := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, (Length(Text) + 1) * SizeOf(Char));
  try
    P := GlobalLock(Data);
    try
      StrCopy(P, PChar(Text));
    finally
      GlobalUnlock(Data);
    end;
    OpenClipboard(0);
    try
      EmptyClipboard;
      SetClipboardData(CF_UNICODETEXT, Data);
    finally
      CloseClipboard;
    end;
  except
    GlobalFree(Data);
    raise;
  end;
end;

function GetTextFromClipboard: string;
var
  Data: HGLOBAL;
  P: PChar;
begin
  Result := '';
  OpenClipboard(0);
  try
    Data := GetClipboardData(CF_UNICODETEXT);
    if Data <> 0 then
    begin
      P := GlobalLock(Data);
      try
        Result := string(P);
      finally
        GlobalUnlock(Data);
      end;
    end;
  finally
    CloseClipboard;
  end;
end;
{$ENDIF}

{$IFDEF MACOS}
procedure CopyTextToClipboard(const Text: string);
var
  PasteBoard: NSPasteboard;
begin
  PasteBoard := TNSPasteboard.Wrap(TNSPasteboard.OCClass.generalPasteboard);
  PasteBoard.declareTypes([NSStringFromClass(NSString)], 1);
  PasteBoard.setString(NSSTR(Text), forType: NSStringFromClass(NSString));
end;

function GetTextFromClipboard: string;
var
  PasteBoard: NSPasteboard;
begin
  Result := '';
  PasteBoard := TNSPasteboard.Wrap(TNSPasteboard.OCClass.generalPasteboard);
  if PasteBoard.availableTypeFromArray([NSStringFromClass(NSString)]) then
  begin
    Result := NSStrToStr(PasteBoard.stringForType(NSStringFromClass(NSString)));
  end;
end;
{$ENDIF}

(*
Screen.ActiveForm.Handle,
        'Ïðîèçîøëà îøèáêà ïðè ðàáîòå ñ óñòðîéñòâîì.', cTestModeCOM,
        MB_OK or MB_ICONERROR
*)
procedure _MessageBox(AHandle:longint;AMessage:string;ADopMessage:string;AICON:Integer);
begin

end;


function StrToMask(AString:String):longword;
var i,len,Idx:integer;
    subStr:String;
    Ch:Char;
    mask:longword;
procedure CheckSubStr();
begin
    Idx:=StrToIntDef(SubStr,0);
    if Idx in [1..32] then
    begin
       mask:=1 shl (Idx-1);
       result:=result or mask;
    end;
    SubStr:='';
end;
begin
  result:=0;
  len:=Length(AString);
  subStr:='';
  for i := 1 to len do
  begin
    Ch:=AString[i];
    if  Ch in ['0'..'9'] then
    begin
      subStr:=subStr+Ch;
    end
    else if SubStr<>'' then
      CheckSubStr();
  end;
  if SubStr<>'' then CheckSubStr();
end;


function MaskToStr(AMask:longword):String;
var i:integer;
    mask:longword;
begin
    result:='';
    for i := 1 to 32 do
    begin
      mask:=1 shl (i-1);
      if (AMask and mask)=mask then
         result:=result+IntToStr(i)+',';
    end;
    //çàòèðàåì çàïÿòóþ
    if result<>'' then result[length(result)]:=' ';


end;




//function IsValueInRange(const RangeStr: string; Value: Integer): Boolean;
//var
//  Ranges: TArray<string>;
//  Range: string;
//  Parts: TArray<string>;
//  StartRange, EndRange: Integer;
//  i: Integer;
//begin
//  Result := False;
//
//  // Ðàçáèâàåì ñòðîêó íà ÷àñòè, ðàçäåë¸ííûå çàïÿòûìè
//  Ranges := SplitString(RangeStr, ',');
//
//  for i := 0 to High(Ranges) do
//  begin
//    Range := Trim(Ranges[i]);
//
//    // Ïðîâåðÿåì, ñîäåðæèò ëè ÷àñòü äèàïàçîí
//    if Pos('..', Range) > 0 then
//    begin
//      // Ðàçáèâàåì äèàïàçîí íà íà÷àëüíîå è êîíå÷íîå çíà÷åíèÿ
//      Parts := SplitString(Range, '..');
//      if Length(Parts) = 2 then
//      begin
//        StartRange := StrToIntDef(Trim(Parts[0]), 0);
//        EndRange := StrToIntDef(Trim(Parts[1]), 0);
//
//        // Ïðîâåðÿåì, âõîäèò ëè çíà÷åíèå â äèàïàçîí
//        if (Value >= StartRange) and (Value <= EndRange) then
//        begin
//          Result := True;
//          Exit;
//        end;
//      end;
//    end
//    else
//    begin
//      // Ïðîâåðÿåì îòäåëüíîå çíà÷åíèå
//      if Value = StrToIntDef(Range, -1) then
//      begin
//        Result := True;
//        Exit;
//      end;
//    end;
//  end;
//end;


function IsValueInRange(const RangeStr: string; Value: Integer): Boolean;
var
  Ranges: TArray<string>;
  Range: string;
  Parts: TArray<string>;
  StartRange, EndRange: Integer;
  i: Integer;
begin
  Result := False;

  // Ðàçáèâàåì ñòðîêó íà ÷àñòè, ðàçäåë¸ííûå çàïÿòûìè
  Ranges := SplitString(RangeStr, ',');

  for i := 0 to High(Ranges) do
  begin
    Range := Trim(Ranges[i]);

    // Ïðîâåðÿåì, ñîäåðæèò ëè ÷àñòü äèàïàçîí
    if Pos('..', Range) > 0 then
    begin
      // Ðàçáèâàåì äèàïàçîí íà íà÷àëüíîå è êîíå÷íîå çíà÷åíèÿ
      Parts := SplitString(Range, '..');
      if Length(Parts) = 3 then
      begin
        StartRange := StrToIntDef(Trim(Parts[0]), 0);
        EndRange := StrToIntDef(Trim(Parts[2]), 0);

        // Ïðîâåðÿåì, âõîäèò ëè çíà÷åíèå â äèàïàçîí
        if (Value >= StartRange) and (Value <= EndRange) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end
    else
    begin
      // Ïðîâåðÿåì îòäåëüíîå çíà÷åíèå
      if Value = StrToIntDef(Range, -1) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function GetElementByIndex(const RangeStr: string; Index: Integer): Integer;
var
  Ranges: TArray<string>;
  Range: string;
  Parts: TArray<string>;
  StartRange, EndRange: Integer;
  Elements: TList<Integer>;
  i, j: Integer;
begin
  Result := 0;
  Elements := TList<Integer>.Create;

  try
    // Ðàçáèâàåì ñòðîêó íà ÷àñòè, ðàçäåë¸ííûå çàïÿòûìè
    Ranges := SplitString(RangeStr, ',');

    for i := 0 to High(Ranges) do
    begin
      Range := Trim(Ranges[i]);

      // Ïðîâåðÿåì, ñîäåðæèò ëè ÷àñòü äèàïàçîí
      if Pos('..', Range) > 0 then
      begin
        // Ðàçáèâàåì äèàïàçîí íà íà÷àëüíîå è êîíå÷íîå çíà÷åíèÿ
        Parts := SplitString(Range, '..');
        if Length(Parts) = 3 then
        begin
          StartRange := StrToIntDef(Trim(Parts[0]), 0);
          EndRange := StrToIntDef(Trim(Parts[2]), 0);

          // Äîáàâëÿåì âñå ýëåìåíòû äèàïàçîíà â ñïèñîê
          for j := StartRange to EndRange do
          begin
            Elements.Add(j);
          end;
        end;
      end
      else
      begin
        // Äîáàâëÿåì îòäåëüíîå çíà÷åíèå â ñïèñîê
        Elements.Add(StrToIntDef(Range, 0));
      end;
    end;

    // Ïðîâåðÿåì, ñóùåñòâóåò ëè ýëåìåíò ñ çàäàííûì èíäåêñîì
    if (Index >= 0) and (Index < Elements.Count) then
    begin
      Result := Elements[Index];
    end;
  finally
    Elements.Free;
  end;
end;

function TwosComplementToDecimal(hexValue: Word): Integer;
begin
  // Ïðîâåðêà çíàêîâîãî áèòà
  if (hexValue and $8000) <> 0 then
  begin
    // Åñëè ÷èñëî îòðèöàòåëüíîå, èíâåðòèðóåì âñå áèòû è ïðèáàâëÿåì 1
    Result := -((not hexValue) + 1);
  end
  else
  begin
    // Åñëè ÷èñëî ïîëîæèòåëüíîå, ïðîñòî âîçâðàùàåì åãî
    Result := hexValue;
  end;
end;

procedure CopyMemory(Destination: Pointer; Source: Pointer; Length: NativeUInt);
begin
  System.Move(Source,Destination,Length);
end;
procedure Zeromemory(Destination: Pointer; Length: NativeUInt);
var i:integer;
begin
  for I := 0 to Length-1 do
     PByte(Destination)[i]:=0;
end;

procedure copymem(dest,src:PByte;len:integer);
var i:integer;
begin
  for I := 1 to len do
  begin
    //dest[i-1]:=src[i-1];
    PByte(dest+(i-1))^:=PByte(src+(i-1))^;
  end;
end;


function IfThenInt(AValue: Boolean; const ATrue: integer;
  AFalse: integer): integer;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

procedure IncF(var x:Single; delta:integer);
begin
  x:=x+Delta;
end;

function DecToHex(DecDigit:longword):LongWord;
begin
  result:=StrToIntDef('$'+IntToStr(DecDigit),0);
end;

function VarToIntDef(const V: Variant; Default: Integer): Int64;
begin
  try
    if VarIsNull(V) or VarIsEmpty(V) then
      Result := Default
    else
      Result := V;
  except
    Result := Default;
  end;
end;

// Âñïîìîãàòåëüíàÿ ôóíêöèÿ äëÿ ïðåîáðàçîâàíèÿ Word â äâà áàéòà
function WordToBytes(Value: Word): ShortString;
begin
//  Result := AnsiChar(DecToHex(Value div 100))+AnsiChar(DecToHex(Value mod 100));
  Result := AnsiChar(Hi(Value)) + AnsiChar(Lo(Value));
end;

(* Ïðèìåð èñïîëüçîâàíèÿ
var
  ResponseStr, Param: string;
begin
  ResponseStr := '>-0000+015.81+015.87'#$D;

  // Ïîëó÷èòü ïåðâûé ïàðàìåòð
  Param := ExtractParameter(ResponseStr, 1);
  // Param = '-0000'

  // Ïîëó÷èòü âòîðîé ïàðàìåòð
  Param := ExtractParameter(ResponseStr, 2);
  // Param = '+015.81'

  // Ïîëó÷èòü òðåòèé ïàðàìåòð
  Param := ExtractParameter(ResponseStr, 3);
  // Param = '+015.87'
end;
*)
function ExtractSignParameter(const ResponseString: string; ParamNumber: Integer): string;
var
  I, CurrentPos, ParamCount: Integer;
  CurrentSign: Char;
begin
  Result := '';
  CurrentPos := 1;
  ParamCount := 0;

  // Ïðîâåðêà âàëèäíîñòè íîìåðà ïàðàìåòðà
  if (ParamNumber < 1) then
    Exit;

  for I := 1 to Length(ResponseString) do
  begin
    // Èùåì ëèáî '+', ëèáî '-'
    if (ResponseString[I] = '+') or (ResponseString[I] = '-') then
    begin
      Inc(ParamCount);
      CurrentSign := ResponseString[I];

      // Åñëè íàøëè íóæíûé ïàðàìåòð
      if ParamCount = ParamNumber then
      begin
        // Èùåì êîíåö ïàðàìåòðà (ñëåäóþùèé çíàê èëè êîíåö ñòðîêè)
        CurrentPos := I + 1;
        while (CurrentPos <= Length(ResponseString)) and
              ((ResponseString[CurrentPos]  in ['0'..'9','.',','])) and
              (ResponseString[CurrentPos] <> '+') and
              (ResponseString[CurrentPos] <> '-') do
        begin
          Inc(CurrentPos);
        end;

        // Èçâëåêàåì ïàðàìåòð ÑÎ ÇÍÀÊÎÌ
        Result := Copy(ResponseString, I, CurrentPos - I);
        Exit;
      end;
    end;
  end;
end;

function ExtractParameter(S: string; ParamNum: integer; StrDivider: Char = ' '): string;
var
  StringList: TStringList;
begin
  Result := '';

  if (S = '') or (ParamNum < 1) then
    Exit;

  StringList := TStringList.Create;
  try
    // Óñòàíàâëèâàåì ðàçäåëèòåëü
    StringList.Delimiter := StrDivider;
    StringList.StrictDelimiter := True; // Èãíîðèðîâàòü êàâû÷êè
    StringList.DelimitedText := S;

    // Ïðîâåðÿåì, ñóùåñòâóåò ëè ïàðàìåòð ñ òàêèì íîìåðîì
    if ParamNum <= StringList.Count then
      Result := StringList[ParamNum - 1];
  finally
    StringList.Free;
  end;
end;

function MilliSecondsBetween(const ANow, AThen: TDateTime): Int64;
begin
  Result := Round((ANow - AThen) * MSecsPerDay);
end;


function Str2Hex(aStr:String): string;
var i:integer;
begin
   result:='';
   for I := 1 to Length(aStr) do
     begin
       result:=result+IntToHex(ord(aStr[i]),2);
     end;
end;


//procedure WriteLog(const Msg: string);
//var
//  LogPath, LogDir, LogText, AppName: string;
//begin
//  // Ïîëó÷àåì èìÿ ïðèëîæåíèÿ
//  {$IFDEF FMX}
//  AppName := Application.Title;
//  {$ELSE}
//  AppName := Application.Title;
//  {$ENDIF}
//
//  if AppName = '' then
//    AppName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
//
//  AppName := StringReplace(AppName, ' ', '_', [rfReplaceAll]);
//
//  // Ôîðìèðóåì ïóòü
//  {$IFDEF LINUX}
//  LogDir := GetEnvironmentVariable('XDG_DATA_HOME');
//  if LogDir = '' then
//    LogDir := GetEnvironmentVariable('HOME') + '/.local/share';
//  LogPath := LogDir + '/' + AppName + '/app_log.txt';
//  {$ELSE}
//  LogDir := GetEnvironmentVariable('LOCALAPPDATA');
//  if LogDir = '' then
//    LogDir := GetEnvironmentVariable('TEMP');
//  LogPath := LogDir + '\' + AppName + '\app_log.txt';
//  {$ENDIF}
//
//  LogText := Format('%s: %s', [DateTimeToStr(Now), Msg]) + sLineBreak;
//
//  try
//    if not TDirectory.Exists(ExtractFilePath(LogPath)) then
//      TDirectory.CreateDirectory(ExtractFilePath(LogPath));
//
//    TFile.AppendAllText(LogPath, LogText, TEncoding.UTF8);
//  except
//    // Fallback â òåêóùóþ äèðåêòîðèþ
//    try
//      TFile.AppendAllText('app_log.txt', LogText, TEncoding.UTF8);
//    except
//      // Èãíîðèðóåì
//    end;
//  end;
//end;

threadvar
  RecursionGuard: Integer;

procedure WriteLog(const Msg: string);
var
  LogPath, LogDir, LogText, AppName: string;
begin
  if RecursionGuard > 0 then Exit; // Èãíîðèðóåì ïîâòîðíûé âûçîâ
  Inc(RecursionGuard);
  LogCriticalSection.Enter;
  try
    // Ïîëó÷àåì èìÿ ïðèëîæåíèÿ
    {$IFDEF FMX}
    AppName := Application.Title;
    {$ELSE}
    AppName := Application.Title;
    {$ENDIF}

    if AppName = '' then
      AppName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');

    AppName := StringReplace(AppName, ' ', '_', [rfReplaceAll]);


    {$IFDEF MSWINDOWS}
    LogDir := GetEnvironmentVariable('LOCALAPPDATA'); // èëè äðóãîé ïîäõîäÿùèé ïóòü
    if LogDir = '' then
      LogDir := 'C:\Temp';
    LogPath := LogDir + '\' + AppName + '_log.txt';
    {$ENDIF}

    // Ôîðìèðóåì ïóòü
    {$IFDEF LINUX}
    LogDir := GetEnvironmentVariable('XDG_DATA_HOME');
    if LogDir = '' then
      LogDir := GetEnvironmentVariable('HOME') + '/.local/share';
    LogPath := LogDir + '/' + AppName + '/app_log.txt';
    {$ENDIF}

    LogText := Format('%s: %s', [DateTimeToStr(Now), Msg]) + sLineBreak;

    try
      if not TDirectory.Exists(ExtractFilePath(LogPath)) then
        TDirectory.CreateDirectory(ExtractFilePath(LogPath));

      TFile.AppendAllText(LogPath, LogText, TEncoding.UTF8);
    except
      // Fallback â òåêóùóþ äèðåêòîðèþ
      try
        TFile.AppendAllText('app_log.txt', LogText, TEncoding.UTF8);
      except
        // Èãíîðèðóåì
      end;
    end;
  finally
    LogCriticalSection.Leave;
    Dec(RecursionGuard);
  end;
end;

function GetFileNameWithoutExtension(const FileName: string): string;
begin
  Result := TPath.GetFileNameWithoutExtension(FileName);
end;

function GetSecondsBetweenDates(const ADate1, ADate2: TDateTime): Int64;
begin
  Result := SecondsBetween(ADate1, ADate2);
end;

procedure ShowDialogMessage(aMessage:String);
var
  ASyncService : IFMXDialogServiceASync;
begin
     if TPlatformServices.Current.SupportsPlatformService(IFMXDialogServiceAsync, IInterface (ASyncService)) then
     begin
         ASyncService.MessageDialogAsync(aMessage, TMsgDlgType.mtInformation,
        [System.UITypes.TMsgDlgBtn.mbOK],
        TMsgDlgBtn.mbNo,
        0,
        nil);
     end;
end;


function IdBytesToHex(const Bytes: TIdBytes): string;
var i: Integer;
begin
  Result := '';
  for i := 0 to High(Bytes) do
    Result := Result + IntToHex(Bytes[i], 2) + ' ';
end;

function BytesToHex(const Bytes: TBytes): string;
var i: Integer;
begin
  Result := '';
  for i := 0 to High(Bytes) do
    Result := Result + IntToHex(Bytes[i], 2) + ' ';
end;


initialization
  LogCriticalSection := TCriticalSection.Create;
  RecursionGuard:=0;
finalization
  LogCriticalSection.Free;
end.

