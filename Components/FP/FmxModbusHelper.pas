unit FmxModbusHelper;

interface

uses
  FmxModBusConsts,
  FmxModbusTypes,
  SysUtils, Classes, IdGlobal;

type
  TModBusFunction = Byte;
  TModBusDataBuffer = array[0..260] of Byte;
  TModBusHeader = packed record
    TransactionID: Word;
    ProtocolID: Word;
    RecLength: Word;
    UnitID: Byte;
  end;
  TModBusRequestBuffer = packed record
    Header: TModBusHeader;
    FunctionCode: TModBusFunction;
    MBPData: TModBusDataBuffer;
  end;
  TModBusResponseBuffer = packed record
    Header: TModBusHeader;
    FunctionCode: TModBusFunction;
    MBPData: TModBusDataBuffer;
  end;
  TModBusExceptionBuffer = packed record
    Header: TModBusHeader;
    ExceptionFunction: TModBusFunction;
    ExceptionCode: Byte;
  end;
  TModbusMode = (mmRTU, mmASCII);
  TModbusExceptionCode = (mbeNone, mbeIllegalFunction, mbeIllegalDataAddress,
                         mbeIllegalDataValue, mbeServerDeviceFailure);

  TModbusRegisters = array of Word;


function GetExpectedResponseLength(const Request: ShortString): Integer;
function ExtractModbusCommand(const Request: ShortString): ShortString;
function ExtractModbusRegister(const Request: ShortString): Word;
function ReadWordBE(const Data: ShortString; Offset: Integer): Word;
function ReadUInt32BE(const Data: ShortString; Offset: Integer): UInt32;
function ReadSingleBE(const Data: ShortString; Offset: Integer): Single;
// Êîíâåðòåðû ShortString <-> TIdBytes
function ShortStringToIdBytes(const Str: ShortString): TIdBytes;
function IdBytesToShortString(const Bytes: TIdBytes): ShortString;
function StrToIdBytes(const Str: ShortString): TIdBytes; overload;
function IdBytesToStr(const Bytes: TIdBytes): ShortString; overload;

// Çàïèñü îäíîãî ðåãèñòðà (ôóíêöèÿ 06h)
function BuildWriteSingleRegisterRequest(DeviceID: Byte; RegisterAddress: Word;
                                        RegisterValue: Word; ModbusMode: TModbusMode;
                                        out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;

// Çàïèñü íåñêîëüêèõ ðåãèñòðîâ (ôóíêöèÿ 16h / 10h)
function BuildWriteMultipleRegistersRequest(DeviceID: Byte; StartAddress: Word;
                                           RegisterValues: array of Word;
                                           ModbusMode: TModbusMode;
                                           out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;

// ×òåíèå ðåãèñòðîâ õðàíåíèÿ (ôóíêöèÿ 03h)
function BuildReadHoldingRegistersRequest(DeviceID: Byte; StartAddress: Word;
                                         RegisterCount: Word; ModbusMode: TModbusMode;
                                         out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;

// ×òåíèå âõîäíûõ ðåãèñòðîâ (ôóíêöèÿ 04h)
function BuildReadInputRegistersRequest(DeviceID: Byte; StartAddress: Word;
                                       RegisterCount: Word; ModbusMode: TModbusMode;
                                       out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;

// Ðàçáîð îòâåòà íà ÷òåíèå ðåãèñòðîâ (ôóíêöèè 03h è 04h)
function ParseReadRegistersResponse(const Buffer: TIdBytes; ModbusMode: TModbusMode;
                                   out Registers: TModbusRegisters;
                                   out ErrorCode: TModbusExceptionCode): Boolean;

// Ðàçáîð îòâåòà íà çàïèñü ðåãèñòðà (ôóíêöèè 06h è 10h)
function ParseWriteRegisterResponse(const Buffer: TIdBytes; ModbusMode: TModbusMode;
                                  out DeviceID: Byte; out FunctionCode: Byte;
                                  out Address: Word; out Value: Word;
                                  out RegisterCount: Word;
                                  out ErrorCode: TModbusExceptionCode): Boolean;

// Ôóíêöèÿ äëÿ ðàçáîðà îòâåòà íà ÷òåíèå coils/discrete inputs
function ParseReadBitsResponse(const Buffer: TIdBytes; ModbusMode: TModbusMode;
                              out Bits: array of Boolean; out BitCount: Integer;
                              out ErrorCode: TModbusExceptionCode): Boolean;

// ×òåíèå äèñêðåòíûõ âõîäîâ (Discrete Inputs) - ôóíêöèÿ 02h
function BuildReadDiscreteInputsRequest(DeviceID: Byte; StartAddress: Word;
                                       InputCount: Word; ModbusMode: TModbusMode;
                                       out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;

function modbus_tcp_ExtractAnswer(const AModBusFunction: TModBusFunction;RecBuffer:TIdBytes;iSize: Integer;out ReceiveBuffer: TModBusResponseBuffer;out Data: array of Word):boolean;
function modbus_tcp_DisassembleAnswer(const AModBusFunction: TModBusFunction;RecBuffer:TIdBytes;iSize: Integer;out ReceiveBuffer: TModBusResponseBuffer;out Data: array of Word):Boolean;
procedure GetRegistersFromBuffer(const Buffer: PWord; const Count: Word; out Data: array of Word);
procedure GetCoilsFromBuffer(const Buffer: PByte; const Count: Word; out Data: array of Word);
procedure PutRegistersIntoBuffer(const Buffer: PWord; const Count: Word; const Data: array of Word);
procedure PutCoilsIntoBuffer(const Buffer: PByte; const Count: Word; const Data: array of Word);
function modbus_tcp_PrepareSendBuff(const AModBusFunction: TModBusFunction;const AUnitID:Byte;
  const ABaseRegister,ARegNumber,ATransactionID: Word; const ABlockLength: Word; out Data: array of Word): TIdBytes;
function CalculateCRC16(const Data: TIdBytes): Word; overload;
function CalculateCRC16(const Data: array of Byte): Word; overload;
function CalculateLRC(const Data: TIdBytes): Byte; overload;
function CalculateLRC(const Data: array of Byte): Byte; overload;
function BytesToHex(const Data: TIdBytes): ShortString; overload;
function HexToBytes(const HexStr: ShortString): TIdBytes;
function Swap16(const DataToSwap: Word): Word;
function modbus_tcp_CheckAnswer(const AModBusFunction: TModBusFunction;RecBuffer:TIdBytes;iSize: Integer;out ReceiveBuffer: TModBusResponseBuffer):Boolean;
function Modbus_CheckAnswer(const RequestBuffer, ResponseBuffer: TIdBytes;
                           ModbusMode: TModbusMode;
                           out ErrorCode: TModbusExceptionCode): Boolean;
function BuildWriteMultipleCoilsRequest(DeviceID: Byte; StartAddress: Word;
                                       CoilCount: Word; const CoilValues: array of Word;
                                       ModbusMode: TModbusMode;
                                       out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
function BuildReadCoilsRequest(DeviceID: Byte; StartAddress: Word;
                              CoilCount: Word; ModbusMode: TModbusMode;
                              out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;

implementation


function GetExpectedResponseLength(const Request: ShortString): Integer;
var
  RegisterCount: Word;
begin
  Result := 0;
  if Length(Request) < 6 then
    Exit;

  case Ord(Request[2]) of
    $03, $04:
      begin
        RegisterCount := (Ord(Request[5]) shl 8) or Ord(Request[6]);
        Result := 5 + RegisterCount * 2;
      end;
    $06, $10:
      Result := 8;
  end;
end;

function ExtractModbusCommand(const Request: ShortString): ShortString;
begin
  Result := '';
  if Length(Request) <= 3 then
    Exit;

  Result := Copy(Request, 2, Length(Request) - 3);
end;

function ExtractModbusRegister(const Request: ShortString): Word;
begin
  Result := 0;
  if Length(Request) < 4 then
    Exit;

  Result := (Ord(Request[3]) shl 8) or Ord(Request[4]);
end;

function ReadWordBE(const Data: ShortString; Offset: Integer): Word;
var  len: integer;
begin
len:=Length(Data);
  if (Offset < 1) or (Offset + 1 > len) then
    raise ERangeError.CreateFmt('ReadWordBE offset %d is out of range', [Offset]);

  Result := (Ord(Data[Offset]) shl 8) or Ord(Data[Offset + 1]);
end;

function ReadUInt32BE(const Data: ShortString; Offset: Integer): UInt32;
begin
  Result := (UInt32(ReadWordBE(Data, Offset + 2)) shl 16) or ReadWordBE(Data, Offset);
end;

function ReadSingleBE(const Data: ShortString; Offset: Integer): Single;
var
  Value: UInt32;
begin
  Value := ReadUInt32BE(Data, Offset);
  Move(Value, Result, SizeOf(Result));
end;

{ Êîíâåðòåðû ShortString <-> TIdBytes }

// Êîíâåðòàöèÿ ShortString â TIdBytes
function ShortStringToIdBytes(const Str: ShortString): TIdBytes;
var
  I: Integer;
begin
  // Äëèíà ShortString õðàíèòñÿ â Str[0], äàííûå â Str[1..Length]
  SetLength(Result, Length(Str));
  for I := 1 to Length(Str) do
    Result[I - 1] := Ord(Str[I]);
end;

// Êîíâåðòàöèÿ TIdBytes â ShortString
function IdBytesToShortString(const Bytes: TIdBytes): ShortString;
var
  I: Integer;
  MaxLen: Integer;
begin
  Result := '';
  // ShortString ìàêñèìàëüíàÿ äëèíà 255 ñèìâîëîâ
  MaxLen := Length(Bytes);
  if MaxLen > 255 then
    MaxLen := 255;

  SetLength(Result, MaxLen);
  for I := 0 to MaxLen - 1 do
    Result[I + 1] := AnsiChar(Bytes[I]);
end;

// Êîíâåðòàöèÿ string â TIdBytes
function StrToIdBytes(const Str: ShortString): TIdBytes;
var
  I: Integer;
begin
  SetLength(Result, Length(Str));
  for I := 1 to Length(Str) do
    Result[I - 1] := Ord(Str[I]);
end;

// Êîíâåðòàöèÿ TIdBytes â string
function IdBytesToStr(const Bytes: TIdBytes): ShortString;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Bytes) do
    Result := Result + Chr(Bytes[I]);
end;

{ Îñòàëüíûå ôóíêöèè îñòàþòñÿ áåç èçìåíåíèé }

// Çàïèñü îäíîãî ðåãèñòðà (ôóíêöèÿ 06h)
function BuildWriteSingleRegisterRequest(DeviceID: Byte; RegisterAddress: Word;
                                        RegisterValue: Word; ModbusMode: TModbusMode;
                                        out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
var
  TempBuffer: TIdBytes;
  CRC: Word;
  LRC: Byte;
  HexStr: ShortString;
  I: Integer;
  ASize: Integer;
begin
  Result := False;
  ResponseLen := 0;

  try
    // Áàçîâûé çàïðîñ äëÿ ôóíêöèè 06h (Write Single Register)
    SetLength(TempBuffer, 6);

    // Çàïîëíÿåì áàçîâûå ïîëÿ
    TempBuffer[0] := DeviceID;              // Àäðåñ óñòðîéñòâà
    TempBuffer[1] := $06;                   // Ôóíêöèÿ çàïèñè ðåãèñòðà
    TempBuffer[2] := Hi(RegisterAddress);   // Ñòàðøèé áàéò àäðåñà ðåãèñòðà
    TempBuffer[3] := Lo(RegisterAddress);   // Ìëàäøèé áàéò àäðåñà ðåãèñòðà
    TempBuffer[4] := Hi(RegisterValue);     // Ñòàðøèé áàéò çíà÷åíèÿ
    TempBuffer[5] := Lo(RegisterValue);     // Ìëàäøèé áàéò çíà÷åíèÿ

    // Óñòàíàâëèâàåì îæèäàåìóþ äëèíó îòâåòà
    case ModbusMode of
      mmRTU:
        ResponseLen := 8;  // Äëÿ RTU: [1áàéò][1áàéò][2áàéòà][2áàéòà][2áàéòà CRC] = 8 áàéò
      mmASCII:
        ResponseLen := 17; // Äëÿ ASCII: 17 ñèìâîëîâ (:'[12hex]'[CR][LF] = 17 áàéò)
    end;

    case ModbusMode of
      mmRTU:
        begin
          // Äëÿ RTU äîáàâëÿåì CRC16 â êîíöå
          CRC := CalculateCRC16(TempBuffer);
          SetLength(Buffer, Length(TempBuffer) + 2);
          for I := 0 to High(TempBuffer) do
            Buffer[I] := TempBuffer[I];
          Buffer[6] := Lo(CRC);
          Buffer[7] := Hi(CRC);
        end;

      mmASCII:
        begin
          // Äëÿ ASCII äîáàâëÿåì LRC è ôîðìàòèðóåì â HEX
          LRC := CalculateLRC(TempBuffer);

          // Äîáàâëÿåì LRC â êîíåö äàííûõ
          SetLength(TempBuffer, Length(TempBuffer) + 1);
          TempBuffer[6] := LRC;

          // Ïðåîáðàçóåì â HEX ñòðîêó ñ íà÷àëüíûì ':' è CRLF â êîíöå
          HexStr := ':' + BytesToHex(TempBuffer) + #13#10;

          // Êîíâåðòèðóåì ñòðîêó â ìàññèâ áàéò TIdBytes
          ASize := Length(HexStr);
          SetLength(Buffer, ASize);
          for I := 1 to ASize do
            Buffer[I-1] := Ord(HexStr[I]);
        end;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      SetLength(Buffer, 0);
      ResponseLen := 0;
      Result := False;
    end;
  end;
end;

// Çàïèñü íåñêîëüêèõ ðåãèñòðîâ (ôóíêöèÿ 16h / 10h)
function BuildWriteMultipleRegistersRequest(DeviceID: Byte; StartAddress: Word;
                                           RegisterValues: array of Word;
                                           ModbusMode: TModbusMode;
                                           out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
var
  TempBuffer: TIdBytes;
  CRC: Word;
  LRC: Byte;
  HexStr: ShortString;
  I, ByteCount: Integer;
  RegisterCount: Word;
  DataSize: Integer;
begin
  Result := False;
  ResponseLen := 0;

  try
    RegisterCount := Length(RegisterValues);

    // Ïðîâåðÿåì îãðàíè÷åíèÿ Modbus (ìàêñèìóì 123 ðåãèñòðà)
    if (RegisterCount = 0) or (RegisterCount > 123) then
    begin
      SetLength(Buffer, 0);
      Exit(False);
    end;

    ByteCount := RegisterCount * 2;
    DataSize := 7 + ByteCount; // 7 áàéò çàãîëîâêà + äàííûå ðåãèñòðîâ

    // Ôîðìèðóåì áàçîâûé áóôåð
    SetLength(TempBuffer, DataSize);

    // Çàïîëíÿåì çàãîëîâîê
    TempBuffer[0] := DeviceID;               // Àäðåñ óñòðîéñòâà
    TempBuffer[1] := $10;                    // Ôóíêöèÿ çàïèñè íåñêîëüêèõ ðåãèñòðîâ (16h)
    TempBuffer[2] := Hi(StartAddress);       // Ñòàðøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[3] := Lo(StartAddress);       // Ìëàäøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[4] := Hi(RegisterCount);      // Ñòàðøèé áàéò êîëè÷åñòâà ðåãèñòðîâ
    TempBuffer[5] := Lo(RegisterCount);      // Ìëàäøèé áàéò êîëè÷åñòâà ðåãèñòðîâ
    TempBuffer[6] := Byte(ByteCount);        // Êîëè÷åñòâî áàéò äàííûõ

    // Çàïîëíÿåì äàííûå ðåãèñòðîâ
    for I := 0 to RegisterCount - 1 do
    begin
      TempBuffer[7 + I * 2] := Hi(RegisterValues[I]);     // Ñòàðøèé áàéò çíà÷åíèÿ
      TempBuffer[8 + I * 2] := Lo(RegisterValues[I]);     // Ìëàäøèé áàéò çíà÷åíèÿ
    end;

    // Óñòàíàâëèâàåì îæèäàåìóþ äëèíó îòâåòà
    case ModbusMode of
      mmRTU:
        ResponseLen := 8;  // Äëÿ RTU: [1áàéò][1áàéò][2áàéòà][2áàéòà][2áàéòà CRC] = 8 áàéò
      mmASCII:
        ResponseLen := 17; // Äëÿ ASCII: 17 ñèìâîëîâ (:'[12hex]'[CR][LF] = 17 áàéò)
    end;

    case ModbusMode of
      mmRTU:
        begin
          // Äëÿ RTU äîáàâëÿåì CRC16 â êîíöå
          CRC := CalculateCRC16(TempBuffer);
          SetLength(Buffer, Length(TempBuffer) + 2);
          for I := 0 to High(TempBuffer) do
            Buffer[I] := TempBuffer[I];
          Buffer[Length(TempBuffer)] := Lo(CRC);
          Buffer[Length(TempBuffer) + 1] := Hi(CRC);
        end;

      mmASCII:
        begin
          // Äëÿ ASCII äîáàâëÿåì LRC è ôîðìàòèðóåì â HEX
          LRC := CalculateLRC(TempBuffer);

          // Äîáàâëÿåì LRC â êîíåö äàííûõ
          SetLength(TempBuffer, Length(TempBuffer) + 1);
          TempBuffer[Length(TempBuffer) - 1] := LRC;

          // Ïðåîáðàçóåì â HEX ñòðîêó ñ íà÷àëüíûì ':' è CRLF â êîíöå
          HexStr := ':' + BytesToHex(TempBuffer) + #13#10;

          // Êîíâåðòèðóåì ñòðîêó â ìàññèâ áàéò TIdBytes
          DataSize := Length(HexStr);
          SetLength(Buffer, DataSize);
          for I := 1 to DataSize do
            Buffer[I-1] := Ord(HexStr[I]);
        end;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      SetLength(Buffer, 0);
      ResponseLen := 0;
      Result := False;
    end;
  end;
end;

// ×òåíèå ðåãèñòðîâ õðàíåíèÿ (ôóíêöèÿ 03h)
function BuildReadHoldingRegistersRequest(DeviceID: Byte; StartAddress: Word;
                                         RegisterCount: Word; ModbusMode: TModbusMode;
                                         out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
var
  TempBuffer: TIdBytes;
  CRC: Word;
  LRC: Byte;
  HexStr: ShortString;
  I: Integer;
  ASize: Integer;
begin
  Result := False;
  ResponseLen := 0;

  try
    // Ïðîâåðÿåì îãðàíè÷åíèÿ Modbus (ìàêñèìóì 125 ðåãèñòðîâ)
    if (RegisterCount = 0) or (RegisterCount > 125) then
    begin
      SetLength(Buffer, 0);
      Exit(False);
    end;

    // Áàçîâûé çàïðîñ äëÿ ôóíêöèè 03h (Read Holding Registers)
    SetLength(TempBuffer, 6);

    // Çàïîëíÿåì áàçîâûå ïîëÿ
    TempBuffer[0] := DeviceID;              // Àäðåñ óñòðîéñòâà
    TempBuffer[1] := $03;                   // Ôóíêöèÿ ÷òåíèÿ ðåãèñòðîâ õðàíåíèÿ
    TempBuffer[2] := Hi(StartAddress);      // Ñòàðøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[3] := Lo(StartAddress);      // Ìëàäøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[4] := Hi(RegisterCount);     // Ñòàðøèé áàéò êîëè÷åñòâà ðåãèñòðîâ
    TempBuffer[5] := Lo(RegisterCount);     // Ìëàäøèé áàéò êîëè÷åñòâà ðåãèñòðîâ

    // Óñòàíàâëèâàåì îæèäàåìóþ äëèíó îòâåòà
    case ModbusMode of
      mmRTU:
        ResponseLen := 5 + RegisterCount * 2;
      mmASCII:
        ResponseLen := 11 + 4 * RegisterCount;
    end;

    case ModbusMode of
      mmRTU:
        begin
          // Äëÿ RTU äîáàâëÿåì CRC16 â êîíöå
          CRC := CalculateCRC16(TempBuffer);
          SetLength(Buffer, Length(TempBuffer) + 2);
          for I := 0 to High(TempBuffer) do
            Buffer[I] := TempBuffer[I];
          Buffer[6] := Lo(CRC);
          Buffer[7] := Hi(CRC);
        end;

      mmASCII:
        begin
          // Äëÿ ASCII äîáàâëÿåì LRC è ôîðìàòèðóåì â HEX
          LRC := CalculateLRC(TempBuffer);

          // Äîáàâëÿåì LRC â êîíåö äàííûõ
          SetLength(TempBuffer, Length(TempBuffer) + 1);
          TempBuffer[6] := LRC;

          // Ïðåîáðàçóåì â HEX ñòðîêó ñ íà÷àëüíûì ':' è CRLF â êîíöå
          HexStr := ':' + BytesToHex(TempBuffer) + #13#10;

          // Êîíâåðòèðóåì ñòðîêó â ìàññèâ áàéò TIdBytes
          ASize := Length(HexStr);
          SetLength(Buffer, ASize);
          for I := 1 to ASize do
            Buffer[I-1] := Ord(HexStr[I]);
        end;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      SetLength(Buffer, 0);
      ResponseLen := 0;
      Result := False;
    end;
  end;
end;

// ×òåíèå âõîäíûõ ðåãèñòðîâ (ôóíêöèÿ 04h)
function BuildReadInputRegistersRequest(DeviceID: Byte; StartAddress: Word;
                                       RegisterCount: Word; ModbusMode: TModbusMode;
                                       out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
var
  TempBuffer: TIdBytes;
  CRC: Word;
  LRC: Byte;
  HexStr: ShortString;
  I: Integer;
  ASize: Integer;
begin
  Result := False;
  ResponseLen := 0;

  try
    // Ïðîâåðÿåì îãðàíè÷åíèÿ Modbus (ìàêñèìóì 125 ðåãèñòðîâ)
    if (RegisterCount = 0) or (RegisterCount > 125) then
    begin
      SetLength(Buffer, 0);
      Exit(False);
    end;

    // Áàçîâûé çàïðîñ äëÿ ôóíêöèè 04h (Read Input Registers)
    SetLength(TempBuffer, 6);

    // Çàïîëíÿåì áàçîâûå ïîëÿ
    TempBuffer[0] := DeviceID;              // Àäðåñ óñòðîéñòâà
    TempBuffer[1] := $04;                   // Ôóíêöèÿ ÷òåíèÿ âõîäíûõ ðåãèñòðîâ
    TempBuffer[2] := Hi(StartAddress);      // Ñòàðøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[3] := Lo(StartAddress);      // Ìëàäøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[4] := Hi(RegisterCount);     // Ñòàðøèé áàéò êîëè÷åñòâà ðåãèñòðîâ
    TempBuffer[5] := Lo(RegisterCount);     // Ìëàäøèé áàéò êîëè÷åñòâà ðåãèñòðîâ

    // Óñòàíàâëèâàåì îæèäàåìóþ äëèíó îòâåòà
    case ModbusMode of
      mmRTU:
        ResponseLen := 5 + RegisterCount * 2;
      mmASCII:
        ResponseLen := 11 + 4 * RegisterCount;
    end;

    case ModbusMode of
      mmRTU:
        begin
          // Äëÿ RTU äîáàâëÿåì CRC16 â êîíöå
          CRC := CalculateCRC16(TempBuffer);
          SetLength(Buffer, Length(TempBuffer) + 2);
          for I := 0 to High(TempBuffer) do
            Buffer[I] := TempBuffer[I];
          Buffer[6] := Lo(CRC);
          Buffer[7] := Hi(CRC);
        end;

      mmASCII:
        begin
          // Äëÿ ASCII äîáàâëÿåì LRC è ôîðìàòèðóåì â HEX
          LRC := CalculateLRC(TempBuffer);

          // Äîáàâëÿåì LRC â êîíåö äàííûõ
          SetLength(TempBuffer, Length(TempBuffer) + 1);
          TempBuffer[6] := LRC;

          // Ïðåîáðàçóåì â HEX ñòðîêó ñ íà÷àëüíûì ':' è CRLF â êîíöå
          HexStr := ':' + BytesToHex(TempBuffer) + #13#10;

          // Êîíâåðòèðóåì ñòðîêó â ìàññèâ áàéò TIdBytes
          ASize := Length(HexStr);
          SetLength(Buffer, ASize);
          for I := 1 to ASize do
            Buffer[I-1] := Ord(HexStr[I]);
        end;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      SetLength(Buffer, 0);
      ResponseLen := 0;
      Result := False;
    end;
  end;
end;

// Ðàçáîð îòâåòà íà ÷òåíèå ðåãèñòðîâ (ôóíêöèè 03h è 04h)
function ParseReadRegistersResponse(const Buffer: TIdBytes; ModbusMode: TModbusMode;
                                   out Registers: TModbusRegisters;
                                   out ErrorCode: TModbusExceptionCode): Boolean;
var
  TempBuffer: TIdBytes;
  DataBuffer: TIdBytes;
  I, DataLen, RegisterCount: Integer;
  CRC, CalculatedCRC: Word;
  LRC, CalculatedLRC: Byte;
  HexStr: ShortString;
begin
  Result := False;
  ErrorCode := mbeNone;
  SetLength(Registers, 0);

  try
    case ModbusMode of
      mmRTU:
        begin
          // Ïðîâåðÿåì ìèíèìàëüíóþ äëèíó äëÿ RTU
          if Length(Buffer) < 5 then
            Exit(False);

          // Ïðîâåðÿåì CRC
          CalculatedCRC := CalculateCRC16(Copy(Buffer, 0, Length(Buffer) - 2));
          CRC := Buffer[Length(Buffer) - 2] or (Buffer[Length(Buffer) - 1] shl 8);

          if CalculatedCRC <> CRC then
            Exit(False);

          TempBuffer := Copy(Buffer, 0, Length(Buffer) - 2);
        end;

      mmASCII:
        begin
          // Ïðîâåðÿåì ìèíèìàëüíóþ äëèíó äëÿ ASCII è ôîðìàò
          if Length(Buffer) < 3 then
            Exit(False);

          // Ïðîâåðÿåì íà÷àëüíûé ':' è êîíå÷íûå CRLF
          if (Chr(Buffer[0]) <> ':') or
             (Chr(Buffer[Length(Buffer) - 2]) <> #13) or
             (Chr(Buffer[Length(Buffer) - 1]) <> #10) then
            Exit(False);

          // Èçâëåêàåì HEX äàííûå (áåç ':' è CRLF)
          HexStr := '';
          for I := 1 to Length(Buffer) - 3 do
            HexStr := HexStr + Chr(Buffer[I]);

          TempBuffer := HexToBytes(HexStr);

          // Ïðîâåðÿåì LRC
          CalculatedLRC := CalculateLRC(Copy(TempBuffer, 0, Length(TempBuffer) - 1));
          LRC := TempBuffer[Length(TempBuffer) - 1];

          if CalculatedLRC <> LRC then
            Exit(False);

          TempBuffer := Copy(TempBuffer, 0, Length(TempBuffer) - 1);
        end;
    end;

    // Ïðîâåðÿåì êîä îøèáêè
    if (TempBuffer[1] and $80) <> 0 then
    begin
      // Ýòî îòâåò ñ îøèáêîé
      ErrorCode := TModbusExceptionCode(TempBuffer[2]);
      Exit(False);
    end;

    // Ïðîâåðÿåì ôóíêöèþ (äîëæíà áûòü 03h èëè 04h)
    if not (TempBuffer[1] in [$03, $04]) then
      Exit(False);

    // Ïîëó÷àåì äàííûå
    DataLen := TempBuffer[2]; // Êîëè÷åñòâî áàéò äàííûõ
    RegisterCount := DataLen div 2;

    SetLength(Registers, RegisterCount);
    SetLength(DataBuffer, DataLen);

    // Êîïèðóåì äàííûå
    for I := 0 to DataLen - 1 do
      DataBuffer[I] := TempBuffer[3 + I];

    // Ïðåîáðàçóåì áàéòû â ñëîâà
    for I := 0 to RegisterCount - 1 do
      Registers[I] := (DataBuffer[I * 2] shl 8) or DataBuffer[I * 2 + 1];

    Result := True;
    ErrorCode := mbeNone;

  except
    on E: Exception do
    begin
      SetLength(Registers, 0);
      ErrorCode := mbeServerDeviceFailure;
      Result := False;
    end;
  end;
end;

// Ðàçáîð îòâåòà íà çàïèñü ðåãèñòðà (ôóíêöèè 06h è 10h)
function ParseWriteRegisterResponse(const Buffer: TIdBytes; ModbusMode: TModbusMode;
                                  out DeviceID: Byte; out FunctionCode: Byte;
                                  out Address: Word; out Value: Word;
                                  out RegisterCount: Word;
                                  out ErrorCode: TModbusExceptionCode): Boolean;
var
  TempBuffer: TIdBytes;
  I: Integer;
  CRC, CalculatedCRC: Word;
  LRC, CalculatedLRC: Byte;
  HexStr: ShortString;
begin
  Result := False;
  ErrorCode := mbeNone;
  DeviceID := 0;
  FunctionCode := 0;
  Address := 0;
  Value := 0;
  RegisterCount := 0;

  try
    case ModbusMode of
      mmRTU:
        begin
          // Ïðîâåðÿåì äëèíó äëÿ RTU
          if Length(Buffer) <> 8 then
            Exit(False);

          // Ïðîâåðÿåì CRC
          CalculatedCRC := CalculateCRC16(Copy(Buffer, 0, 6));
          CRC := Buffer[6] or (Buffer[7] shl 8);

          if CalculatedCRC <> CRC then
            Exit(False);

          TempBuffer := Copy(Buffer, 0, 6);
        end;

      mmASCII:
        begin
          // Ïðîâåðÿåì äëèíó äëÿ ASCII è ôîðìàò
          if Length(Buffer) <> 17 then
            Exit(False);

          // Ïðîâåðÿåì íà÷àëüíûé ':' è êîíå÷íûå CRLF
          if (Chr(Buffer[0]) <> ':') or
             (Chr(Buffer[15]) <> #13) or
             (Chr(Buffer[16]) <> #10) then
            Exit(False);

          // Èçâëåêàåì HEX äàííûå (áåç ':' è CRLF)
          HexStr := '';
          for I := 1 to 14 do
            HexStr := HexStr + Chr(Buffer[I]);

          TempBuffer := HexToBytes(HexStr);

          // Ïðîâåðÿåì LRC
          CalculatedLRC := CalculateLRC(Copy(TempBuffer, 0, 6));
          LRC := TempBuffer[6];

          if CalculatedLRC <> LRC then
            Exit(False);

          TempBuffer := Copy(TempBuffer, 0, 6);
        end;
    end;

    // Ïðîâåðÿåì êîä îøèáêè
    if (TempBuffer[1] and $80) <> 0 then
    begin
      // Ýòî îòâåò ñ îøèáêîé
      ErrorCode := TModbusExceptionCode(TempBuffer[2]);
      Exit(False);
    end;

    // Èçâëåêàåì äàííûå
    DeviceID := TempBuffer[0];
    FunctionCode := TempBuffer[1];

    if FunctionCode = $06 then
    begin
      // Îòâåò íà çàïèñü îäíîãî ðåãèñòðà
      Address := (TempBuffer[2] shl 8) or TempBuffer[3];
      Value := (TempBuffer[4] shl 8) or TempBuffer[5];
      RegisterCount := 1;
    end
    else if FunctionCode = $10 then
    begin
      // Îòâåò íà çàïèñü íåñêîëüêèõ ðåãèñòðîâ
      Address := (TempBuffer[2] shl 8) or TempBuffer[3];
      RegisterCount := (TempBuffer[4] shl 8) or TempBuffer[5];
      Value := 0; // Íå èñïîëüçóåòñÿ äëÿ ìíîæåñòâåííîé çàïèñè
    end
    else
    begin
      Exit(False);
    end;

    Result := True;
    ErrorCode := mbeNone;

  except
    on E: Exception do
    begin
      ErrorCode := mbeServerDeviceFailure;
      Result := False;
    end;
  end;
end;

// ×òåíèå äèñêðåòíûõ âõîäîâ (Coils) - ôóíêöèÿ 01h
function BuildReadCoilsRequest(DeviceID: Byte; StartAddress: Word;
                              CoilCount: Word; ModbusMode: TModbusMode;
                              out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
var
  TempBuffer: TIdBytes;
  CRC: Word;
  LRC: Byte;
  HexStr: string;
  I: Integer;
  ASize: Integer;
begin
  Result := False;
  ResponseLen := 0;

  try
    // Ïðîâåðÿåì îãðàíè÷åíèÿ Modbus (ìàêñèìóì 2000 coils)
    if (CoilCount = 0) or (CoilCount > 2000) then
    begin
      SetLength(Buffer, 0);
      Exit(False);
    end;

    // Áàçîâûé çàïðîñ äëÿ ôóíêöèè 01h (Read Coils)
    SetLength(TempBuffer, 6);

    // Çàïîëíÿåì áàçîâûå ïîëÿ
    TempBuffer[0] := DeviceID;              // Àäðåñ óñòðîéñòâà
    TempBuffer[1] := $01;                   // Ôóíêöèÿ ÷òåíèÿ coils
    TempBuffer[2] := Hi(StartAddress);      // Ñòàðøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[3] := Lo(StartAddress);      // Ìëàäøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[4] := Hi(CoilCount);         // Ñòàðøèé áàéò êîëè÷åñòâà coils
    TempBuffer[5] := Lo(CoilCount);         // Ìëàäøèé áàéò êîëè÷åñòâà coils

    // Óñòàíàâëèâàåì îæèäàåìóþ äëèíó îòâåòà
    // Îòâåò: [1áàéò ID][1áàéò ôóíêöèÿ][1áàéò ñ÷åò÷èê áàéò][N áàéò äàííûõ][2áàéò CRC]
    case ModbusMode of
      mmRTU:
        begin
          // Äëÿ RTU
          ResponseLen := 5 + ((CoilCount + 7) div 8);
        end;
      mmASCII:
        begin
          // Äëÿ ASCII: 1 + (5 + ceil(CoilCount/8) + 1) * 2 + 2 áàéòà
          //ResponseLen := 1 + (5 + ((CoilCount + 7) div 8) + 1) * 2 + 2;
          ResponseLen := 11 + 2 * ((CoilCount + 7) div 8);
        end;
    end;

    case ModbusMode of
      mmRTU:
        begin
          // Äëÿ RTU äîáàâëÿåì CRC16 â êîíöå
          CRC := CalculateCRC16(TempBuffer);
          SetLength(Buffer, Length(TempBuffer) + 2);
          for I := 0 to High(TempBuffer) do
            Buffer[I] := TempBuffer[I];
          Buffer[6] := Lo(CRC);
          Buffer[7] := Hi(CRC);
        end;

      mmASCII:
        begin
          // Äëÿ ASCII äîáàâëÿåì LRC è ôîðìàòèðóåì â HEX
          LRC := CalculateLRC(TempBuffer);

          // Äîáàâëÿåì LRC â êîíåö äàííûõ
          SetLength(TempBuffer, Length(TempBuffer) + 1);
          TempBuffer[6] := LRC;

          // Ïðåîáðàçóåì â HEX ñòðîêó ñ íà÷àëüíûì ':' è CRLF â êîíöå
          HexStr := ':' + BytesToHex(TempBuffer) + #13#10;

          // Êîíâåðòèðóåì ñòðîêó â ìàññèâ áàéò TIdBytes
          ASize := Length(HexStr);
          SetLength(Buffer, ASize);
          for I := 1 to ASize do
            Buffer[I-1] := Ord(HexStr[I]);
        end;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      SetLength(Buffer, 0);
      ResponseLen := 0;
      Result := False;
    end;
  end;
end;

// ×òåíèå äèñêðåòíûõ âõîäîâ (Discrete Inputs) - ôóíêöèÿ 02h
function BuildReadDiscreteInputsRequest(DeviceID: Byte; StartAddress: Word;
                                       InputCount: Word; ModbusMode: TModbusMode;
                                       out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
var
  TempBuffer: TIdBytes;
  CRC: Word;
  LRC: Byte;
  HexStr: ShortString;
  I: Integer;
  ASize: Integer;
begin
  Result := False;
  ResponseLen := 0;

  try
    // Ïðîâåðÿåì îãðàíè÷åíèÿ Modbus (ìàêñèìóì 2000 discrete inputs)
    if (InputCount = 0) or (InputCount > 2000) then
    begin
      SetLength(Buffer, 0);
      Exit(False);
    end;

    // Áàçîâûé çàïðîñ äëÿ ôóíêöèè 02h (Read Discrete Inputs)
    SetLength(TempBuffer, 6);

    // Çàïîëíÿåì áàçîâûå ïîëÿ
    TempBuffer[0] := DeviceID;              // Àäðåñ óñòðîéñòâà
    TempBuffer[1] := $02;                   // Ôóíêöèÿ ÷òåíèÿ discrete inputs
    TempBuffer[2] := Hi(StartAddress);      // Ñòàðøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[3] := Lo(StartAddress);      // Ìëàäøèé áàéò íà÷àëüíîãî àäðåñà
    TempBuffer[4] := Hi(InputCount);        // Ñòàðøèé áàéò êîëè÷åñòâà inputs
    TempBuffer[5] := Lo(InputCount);        // Ìëàäøèé áàéò êîëè÷åñòâà inputs

    // Óñòàíàâëèâàåì îæèäàåìóþ äëèíó îòâåòà
    // Îòâåò: [1áàéò ID][1áàéò ôóíêöèÿ][1áàéò ñ÷åò÷èê áàéò][N áàéò äàííûõ][2áàéò CRC]
    case ModbusMode of
      mmRTU:
        begin
          ResponseLen := 5 + ((InputCount + 7) div 8);
        end;
      mmASCII:
        begin
          ResponseLen := 11 + 2 * ((InputCount + 7) div 8);
        end;
    end;

    case ModbusMode of
      mmRTU:
        begin
          // Äëÿ RTU äîáàâëÿåì CRC16 â êîíöå
          CRC := CalculateCRC16(TempBuffer);
          SetLength(Buffer, Length(TempBuffer) + 2);
          for I := 0 to High(TempBuffer) do
            Buffer[I] := TempBuffer[I];
          Buffer[6] := Lo(CRC);
          Buffer[7] := Hi(CRC);
        end;

      mmASCII:
        begin
          // Äëÿ ASCII äîáàâëÿåì LRC è ôîðìàòèðóåì â HEX
          LRC := CalculateLRC(TempBuffer);

          // Äîáàâëÿåì LRC â êîíåö äàííûõ
          SetLength(TempBuffer, Length(TempBuffer) + 1);
          TempBuffer[6] := LRC;

          // Ïðåîáðàçóåì â HEX ñòðîêó ñ íà÷àëüíûì ':' è CRLF â êîíöå
          HexStr := ':' + BytesToHex(TempBuffer) + #13#10;

          // Êîíâåðòèðóåì ñòðîêó â ìàññèâ áàéò TIdBytes
          ASize := Length(HexStr);
          SetLength(Buffer, ASize);
          for I := 1 to ASize do
            Buffer[I-1] := Ord(HexStr[I]);
        end;
    end;

    Result := True;
  except
    on E: Exception do
    begin
      SetLength(Buffer, 0);
      ResponseLen := 0;
      Result := False;
    end;
  end;
end;

// Ôóíêöèÿ äëÿ ðàçáîðà îòâåòà íà ÷òåíèå coils/discrete inputs
function ParseReadBitsResponse(const Buffer: TIdBytes; ModbusMode: TModbusMode;
                              out Bits: array of Boolean; out BitCount: Integer;
                              out ErrorCode: TModbusExceptionCode): Boolean;
var
  TempBuffer: TIdBytes;
  DataBuffer: TIdBytes;
  I, J, DataLen, ByteCount: Integer;
  CRC, CalculatedCRC: Word;
  LRC, CalculatedLRC: Byte;
  HexStr: ShortString;
  CurrentByte: Byte;
begin
  Result := False;
  ErrorCode := mbeNone;
  BitCount := 0;

  try
    case ModbusMode of
      mmRTU:
        begin
          // Ïðîâåðÿåì ìèíèìàëüíóþ äëèíó äëÿ RTU
          if Length(Buffer) < 5 then
            Exit(False);

          // Ïðîâåðÿåì CRC
          CalculatedCRC := CalculateCRC16(Copy(Buffer, 0, Length(Buffer) - 2));
          CRC := Buffer[Length(Buffer) - 2] or (Buffer[Length(Buffer) - 1] shl 8);

          if CalculatedCRC <> CRC then
            Exit(False);

          TempBuffer := Copy(Buffer, 0, Length(Buffer) - 2);
        end;

      mmASCII:
        begin
          // Ïðîâåðÿåì ìèíèìàëüíóþ äëèíó äëÿ ASCII è ôîðìàò
          if Length(Buffer) < 3 then
            Exit(False);

          // Ïðîâåðÿåì íà÷àëüíûé ':' è êîíå÷íûå CRLF
          if (Chr(Buffer[0]) <> ':') or
             (Chr(Buffer[Length(Buffer) - 2]) <> #13) or
             (Chr(Buffer[Length(Buffer) - 1]) <> #10) then
            Exit(False);

          // Èçâëåêàåì HEX äàííûå (áåç ':' è CRLF)
          HexStr := '';
          for I := 1 to Length(Buffer) - 3 do
            HexStr := HexStr + Chr(Buffer[I]);

          TempBuffer := HexToBytes(HexStr);

          // Ïðîâåðÿåì LRC
          CalculatedLRC := CalculateLRC(Copy(TempBuffer, 0, Length(TempBuffer) - 1));
          LRC := TempBuffer[Length(TempBuffer) - 1];

          if CalculatedLRC <> LRC then
            Exit(False);

          TempBuffer := Copy(TempBuffer, 0, Length(TempBuffer) - 1);
        end;
    end;

    // Ïðîâåðÿåì êîä îøèáêè
    if (TempBuffer[1] and $80) <> 0 then
    begin
      // Ýòî îòâåò ñ îøèáêîé
      ErrorCode := TModbusExceptionCode(TempBuffer[2]);
      Exit(False);
    end;

    // Ïðîâåðÿåì ôóíêöèþ (äîëæíà áûòü 01h èëè 02h)
    if not (TempBuffer[1] in [$01, $02]) then
      Exit(False);

    // Ïîëó÷àåì äàííûå
    ByteCount := TempBuffer[2]; // Êîëè÷åñòâî áàéò äàííûõ
    DataLen := ByteCount;

    if DataLen > Length(Bits) then
      DataLen := Length(Bits);

    SetLength(DataBuffer, DataLen);

    // Êîïèðóåì äàííûå
    for I := 0 to DataLen - 1 do
      DataBuffer[I] := TempBuffer[3 + I];

    // Ïðåîáðàçóåì áàéòû â áèòû
    BitCount := 0;
    for I := 0 to DataLen - 1 do
    begin
      CurrentByte := DataBuffer[I];
      for J := 0 to 7 do
      begin
        if BitCount < Length(Bits) then
        begin
          Bits[BitCount] := (CurrentByte and (1 shl J)) <> 0;
          Inc(BitCount);
        end
        else
          Break;
      end;
      if BitCount >= Length(Bits) then
        Break;
    end;

    Result := True;
    ErrorCode := mbeNone;

  except
    on E: Exception do
    begin
      BitCount := 0;
      ErrorCode := mbeServerDeviceFailure;
      Result := False;
    end;
  end;
end;
{
https://ipc2u.ru/articles/prostye-resheniya/modbus-rtu/#opisanie
https://ipc2u.ru/articles/prostye-resheniya/modbus-tcp/#0x05

[<< USER] 75 03 00 00 00 06 01 02 00 63 00 09
[PORT >>] 75 03 00 00 00 05 01 02 02 00 00
//âîçâðàùàåòñÿ 1 ðåãèñòð (2 áàéòà) äàííûõ - ò.ê. 9 áèò óæå çàéìóò 2 áàéòà
[<< USER] 75 03 00 00 00 06 01 02 00 63 00 09
[PORT >>] 75 03 00 00 00 05 01 02 02 00 00
//âîçâðàùàåòñÿ 1 áàéò äàííûõ  - ò.ê. 8 áèò âïèñûâàþòñÿ â 1 áàéò
[<< USER] 75 03 00 00 00 06 01 01 00 63 00 08
[PORT >>] 75 03 00 00 00 04 01 01 01 00
//ñ àäðåñà 0008 - 16 áèò  âåðíóë 0x0080
[<< USER] 75 03 00 00 00 06 01 01 00 08 00 10
[PORT >>] 75 03 00 00 00 05 01 01 02 80 00
//ñ àäðåñà 0000 - 16 áèò  âåðíóë 0x8001
[<< USER] 75 03 00 00 00 06 01 01 00 00 00 10
[PORT >>] 75 03 00 00 00 05 01 01 02 01 80

}
function modbus_tcp_ExtractAnswer(const AModBusFunction: TModBusFunction;RecBuffer:TIdBytes;iSize: Integer;out ReceiveBuffer: TModBusResponseBuffer;out Data: array of Word):boolean;var
  BlockLength: Word;
begin
    result:=False;
    case AModBusFunction of
        mbfWriteCoils,
        mbfWriteRegs: result:=True;
      mbfReadCoils,
      mbfReadInputBits:
        begin
           //ReceiveBuffer.MBPData[0] - êîëè÷åñòâî áàéò â îòâåòå
           if ReceiveBuffer.MBPData[0]>1 then
              //íàø âàðèàíò - çàïðàøèâàåì âñåãäà 16 áèò - äàííûå âîçâðàùàåì íîðìàëèçîâàííûìè
              Data[0]:=(ReceiveBuffer.MBPData[1])+(ReceiveBuffer.MBPData[2] shl 8)//{ TODO : Óòî÷íèòü ðàñïîëîæåíèå ïåâîãî áèòà â çàïðîñå 16 áèò }
           else if ReceiveBuffer.MBPData[0]=1 then
              Data[0]:=ReceiveBuffer.MBPData[1];
           result:=True;
        end;
      mbfReadHoldingRegs,
      mbfReadInputRegs:
        begin
          BlockLength := (ReceiveBuffer.MBPData[0] shr 1);
          if (BlockLength > 125) then
            BlockLength := 125;
          if BlockLength>0 then
          begin
             GetRegistersFromBuffer(@ReceiveBuffer.MBPData[1], BlockLength, Data);
             result:=True;
          end;
        end;
    end;
end;

function modbus_tcp_DisassembleAnswer(const AModBusFunction: TModBusFunction;RecBuffer:TIdBytes;iSize: Integer;out ReceiveBuffer: TModBusResponseBuffer;out Data: array of Word):Boolean;
begin
  Result := True;
  Move(RecBuffer[0], ReceiveBuffer, iSize);
{ Check if the result has the same function code as the request }
  if (AModBusFunction = ReceiveBuffer.FunctionCode) then
    modbus_tcp_ExtractAnswer(AModBusFunction,RecBuffer,iSize,ReceiveBuffer,Data)
  else
    Result := False;
end;

function modbus_tcp_PrepareSendBuff(const AModBusFunction: TModBusFunction;const AUnitID:Byte;
  const ABaseRegister,ARegNumber,ATransactionID: Word; const ABlockLength: Word; out Data: array of Word): TIdBytes;
var
  SendBuffer: TModBusRequestBuffer;
  BlockLength: Word;
  RegNumber: Word;
  Buffer: TIdBytes;
  RecBuffer: TIdBytes;
  iSize: Integer;
begin
  SendBuffer.Header.TransactionID := ATransactionID;
  SendBuffer.Header.ProtocolID := MB_PROTOCOL;
{ Initialise data related variables }
  RegNumber := ARegNumber - ABaseRegister;
{ Perform function code specific operations }
  case AModBusFunction of
    mbfReadCoils,
    mbfReadInputBits:
      begin
        BlockLength := ABlockLength;
      { Don't exceed max length }
        if (BlockLength > 250) then
          BlockLength := 250;
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := AUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfReadHoldingRegs,
    mbfReadInputRegs:
      begin
        BlockLength := ABlockLength;
        if (BlockLength > 125) then
          BlockLength := 125; { Don't exceed max length }
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := AUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfWriteOneCoil:
      begin
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := AUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        if (Data[0] <> 0) then
          SendBuffer.MBPData[2] := 255
        else
          SendBuffer.MBPData[2] := 0;
        SendBuffer.MBPData[3] := 0;
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfWriteOneReg:
      begin
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := AUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(Data[0]);
        SendBuffer.MBPData[3] := Lo(Data[0]);
        SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
      end;
    mbfWriteCoils:
      begin
        BlockLength := ABlockLength;
      { Don't exceed max length }
        if (BlockLength > 250) then
          BlockLength := 250;
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := AUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.MBPData[4] := Byte((BlockLength + 7) div 8);
        PutCoilsIntoBuffer(@SendBuffer.MBPData[5], BlockLength, Data);
        SendBuffer.Header.RecLength := Swap16(7 + SendBuffer.MBPData[4]);
      end;
    mbfWriteRegs:
      begin
        BlockLength := ABlockLength;
      { Don't exceed max length }
        if (BlockLength > 250) then
          BlockLength := 250;
      { Initialise the data part }
        SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
        SendBuffer.Header.UnitID := AUnitID;
        SendBuffer.MBPData[0] := Hi(RegNumber);
        SendBuffer.MBPData[1] := Lo(RegNumber);
        SendBuffer.MBPData[2] := Hi(BlockLength);
        SendBuffer.MBPData[3] := Lo(BlockLength);
        SendBuffer.MbpData[4] := Byte(BlockLength shl 1);
        PutRegistersIntoBuffer(@SendBuffer.MBPData[5], BlockLength, Data);
        SendBuffer.Header.RecLength := Swap16(7 + SendBuffer.MbpData[4]);
      end;
  end;
  result:= RawToBytes(SendBuffer, Swap16(SendBuffer.Header.RecLength) + 6);
end;


(*function TIdModBusClient.WriteCoil(const RegNo: Word; const Value: Boolean): Boolean;
var
  Data: array[0..0] of Word;
  bNewConnection: Boolean;
begin
  bNewConnection := False;
  if Value then
    Data[0] := 1
  else
    Data[0] := 0;

  if FAutoConnect and not Connected then
  begin
    Connect;
    bNewConnection := True;
  end;

  try
    Result := SendCommand(mbfWriteOneCoil, RegNo, 0, Data);
  finally
    if bNewConnection then
      DisConnect;
  end;
end;

*)

procedure PutCoilsIntoBuffer(const Buffer: PByte; const Count: Word; const Data: array of Word);
var
  BytePtr: PByte;
  BitMask: Byte;
  i: Word;
begin
  BytePtr := Buffer;
  BitMask := 1;
  for i := 0 to (Count - 1) do
  begin
    if (i < Length(Data)) then
    begin
      if (BitMask = 1) then
        BytePtr^ := 0;
      if (Data[i] <> 0) then
        BytePtr^ := BytePtr^ or BitMask;
      if (BitMask = $80) then
      begin
        BitMask := 1;
        Inc(BytePtr);
      end
      else
        BitMask := (Bitmask shl 1);
    end;
  end;
end;

procedure PutRegistersIntoBuffer(const Buffer: PWord; const Count: Word; const Data: array of Word);
var
  WordPtr: PWord;
  i: Word;
begin
  WordPtr := Buffer;
  for i := 0 to (Count - 1) do
  begin
    WordPtr^ := Swap16(Data[i]);
    Inc(WordPtr);
  end;
end;

procedure GetCoilsFromBuffer(const Buffer: PByte; const Count: Word; out Data: array of Word);
var
  BytePtr: PByte;
  BitMask: Byte;
  i: Integer;
begin
  BytePtr := Buffer;
  BitMask := 1;

  for i := 0 to (Count - 1) do
  begin
    if (i < Length(Data)) then
    begin
      if ((BytePtr^ and BitMask) <> 0) then
        Data[i] := 1
      else
        Data[i] := 0;
      if (BitMask = $80) then
      begin
        BitMask := 1;
        Inc(BytePtr);
      end
      else
        BitMask := (Bitmask shl 1);
    end;
  end;
end;




procedure GetRegistersFromBuffer(const Buffer: PWord; const Count: Word; out Data: array of Word);
var
  WPtr: PWord;
  i: Word;
begin
  WPtr := Buffer;

  for i := 0 to (Count - 1) do
  begin
    Data[i] := Swap16(WPtr^);
    Inc(WPtr);
  end;
end;

// Ïðîâåðêà êîððåêòíîñòè îòâåòîâ Modbus RTU
function ModbusRTU_CheckAnswer(const RequestBuffer, ResponseBuffer: TIdBytes;
                              out ErrorCode: TModbusExceptionCode): Boolean;
var
  ReqDeviceID, RespDeviceID: Byte;
  ReqFunctionCode, RespFunctionCode: Byte;
  CRC, CalculatedCRC: Word;
begin
  Result := False;
  ErrorCode := mbeNone;

  // Ïðîâåðÿåì ìèíèìàëüíóþ äëèíó îòâåòà
  if Length(ResponseBuffer) < 5 then // Ìèíèìóì: [ID][Func][Data...][CRC16]
  begin
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Ïðîâåðÿåì CRC
  CalculatedCRC := CalculateCRC16(Copy(ResponseBuffer, 0, Length(ResponseBuffer) - 2));
  CRC := ResponseBuffer[Length(ResponseBuffer) - 2] or
         (ResponseBuffer[Length(ResponseBuffer) - 1] shl 8);

  if CalculatedCRC <> CRC then
  begin
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Èçâëåêàåì îñíîâíûå ïîëÿ
  RespDeviceID := ResponseBuffer[0];
  RespFunctionCode := ResponseBuffer[1];

  // Ïðîâåðÿåì êîä îøèáêè
  if (RespFunctionCode and $80) <> 0 then
  begin
    // Ýòî îòâåò ñ îøèáêîé
    if Length(ResponseBuffer) >= 3 then
      ErrorCode := TModbusExceptionCode(ResponseBuffer[2])
    else
      ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Ñðàâíèâàåì ñ çàïðîñîì (åñëè ïåðåäàí áóôåð çàïðîñà)
  if Length(RequestBuffer) >= 2 then
  begin
    ReqDeviceID := RequestBuffer[0];
    ReqFunctionCode := RequestBuffer[1];

    // Ïðîâåðÿåì ñîîòâåòñòâèå óñòðîéñòâà è ôóíêöèè
    if ReqDeviceID <> RespDeviceID then
    begin
      ErrorCode := mbeServerDeviceFailure;
      Exit(False);
    end;

    // Äëÿ îòâåòîâ íà çàïèñü - ïðîâåðÿåì êîä ôóíêöèè
    if (ReqFunctionCode in [$06, $10, $03, $04]) and
       (RespFunctionCode <> ReqFunctionCode) then
    begin
      ErrorCode := mbeServerDeviceFailure;
      Exit(False);
    end;
  end;

  Result := True;
  ErrorCode := mbeNone;
end;

// Ïðîâåðêà êîððåêòíîñòè îòâåòîâ Modbus ASCII
function ModbusASCII_CheckAnswer(const RequestBuffer, ResponseBuffer: TIdBytes;
                               out ErrorCode: TModbusExceptionCode): Boolean;
var
  TempBuffer: TIdBytes;
  ReqDeviceID, RespDeviceID: Byte;
  ReqFunctionCode, RespFunctionCode: Byte;
  LRC, CalculatedLRC: Byte;
  HexStr: ShortString;
  I: Integer;
begin
  Result := False;
  ErrorCode := mbeNone;

  // Ïðîâåðÿåì ìèíèìàëüíóþ äëèíó îòâåòà è ôîðìàò
  if Length(ResponseBuffer) < 5 then // Ìèíèìóì: ':'[hex]CRLF
  begin
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Ïðîâåðÿåì íà÷àëüíûé ':' è êîíå÷íûå CRLF
  if (Chr(ResponseBuffer[0]) <> ':') or
     (Length(ResponseBuffer) < 3) or
     (Chr(ResponseBuffer[Length(ResponseBuffer) - 2]) <> #13) or
     (Chr(ResponseBuffer[Length(ResponseBuffer) - 1]) <> #10) then
  begin
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Èçâëåêàåì HEX äàííûå (áåç ':' è CRLF)
  HexStr := '';
  for I := 1 to Length(ResponseBuffer) - 3 do
    HexStr := HexStr + Chr(ResponseBuffer[I]);

  // Ïðîâåðÿåì ÷òî ñòðîêà ñîñòîèò èç HEX ñèìâîëîâ è èìååò ÷åòíóþ äëèíó
  if (Length(HexStr) mod 2 <> 0) or (Length(HexStr) = 0) then
  begin
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  try
    TempBuffer := HexToBytes(HexStr);
  except
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Ïðîâåðÿåì LRC
  CalculatedLRC := CalculateLRC(Copy(TempBuffer, 0, Length(TempBuffer) - 1));
  LRC := TempBuffer[Length(TempBuffer) - 1];

  if CalculatedLRC <> LRC then
  begin
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Èçâëåêàåì îñíîâíûå ïîëÿ (áåç LRC)
  TempBuffer := Copy(TempBuffer, 0, Length(TempBuffer) - 1);

  if Length(TempBuffer) < 2 then
  begin
    ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  RespDeviceID := TempBuffer[0];
  RespFunctionCode := TempBuffer[1];

  // Ïðîâåðÿåì êîä îøèáêè
  if (RespFunctionCode and $80) <> 0 then
  begin
    // Ýòî îòâåò ñ îøèáêîé
    if Length(TempBuffer) >= 3 then
      ErrorCode := TModbusExceptionCode(TempBuffer[2])
    else
      ErrorCode := mbeServerDeviceFailure;
    Exit(False);
  end;

  // Ñðàâíèâàåì ñ çàïðîñîì (åñëè ïåðåäàí áóôåð çàïðîñà)
  if Length(RequestBuffer) >= 2 then
  begin
    // Äëÿ ASCII çàïðîñ òîæå íóæíî äåêîäèðîâàòü èç HEX
    if (Length(RequestBuffer) >= 3) and (Chr(RequestBuffer[0]) = ':') then
    begin
      HexStr := '';
      for I := 1 to Length(RequestBuffer) - 3 do
        HexStr := HexStr + Chr(RequestBuffer[I]);

      try
        TempBuffer := HexToBytes(HexStr);
        if Length(TempBuffer) >= 2 then
        begin
          ReqDeviceID := TempBuffer[0];
          ReqFunctionCode := TempBuffer[1];
        end;
      except
        // Åñëè íå óäàëîñü äåêîäèðîâàòü çàïðîñ, ïðîïóñêàåì ïðîâåðêó
        ReqDeviceID := RespDeviceID;
        ReqFunctionCode := RespFunctionCode;
      end;
    end;

    // Ïðîâåðÿåì ñîîòâåòñòâèå óñòðîéñòâà è ôóíêöèè
    if ReqDeviceID <> RespDeviceID then
    begin
      ErrorCode := mbeServerDeviceFailure;
      Exit(False);
    end;

    // Äëÿ îòâåòîâ íà çàïèñü - ïðîâåðÿåì êîä ôóíêöèè
    if (ReqFunctionCode in [$06, $10, $03, $04]) and
       (RespFunctionCode <> ReqFunctionCode) then
    begin
      ErrorCode := mbeServerDeviceFailure;
      Exit(False);
    end;
  end;

  Result := True;
  ErrorCode := mbeNone;
end;

// Óíèâåðñàëüíàÿ ôóíêöèÿ ïðîâåðêè îòâåòà
function Modbus_CheckAnswer(const RequestBuffer, ResponseBuffer: TIdBytes;
                           ModbusMode: TModbusMode;
                           out ErrorCode: TModbusExceptionCode): Boolean;
begin
  case ModbusMode of
    mmRTU:
      Result := ModbusRTU_CheckAnswer(RequestBuffer, ResponseBuffer, ErrorCode);
    mmASCII:
      Result := ModbusASCII_CheckAnswer(RequestBuffer, ResponseBuffer, ErrorCode);
  else
    Result := False;
    ErrorCode := mbeServerDeviceFailure;
  end;
end;

function modbus_tcp_CheckAnswer(const AModBusFunction: TModBusFunction;RecBuffer:TIdBytes;iSize: Integer;out ReceiveBuffer: TModBusResponseBuffer):Boolean;
var
  BlockLength: Word;
begin
  Result := True;
  Move(RecBuffer[0], ReceiveBuffer, iSize);
{ Check if the result has the same function code as the request }
  result:=(AModBusFunction = ReceiveBuffer.FunctionCode);
end;


{ Âñïîìîãàòåëüíûå ôóíêöèè }

function CalculateCRC16(const Data: TIdBytes): Word;
var
  I, J: Integer;
  CRC: Word;
begin
  CRC := $FFFF;
  for I := 0 to High(Data) do
  begin
    CRC := CRC xor Data[I];
    for J := 0 to 7 do
    begin
      if (CRC and $0001) <> 0 then
        CRC := (CRC shr 1) xor $A001
      else
        CRC := CRC shr 1;
    end;
  end;
  Result := CRC;
end;

function CalculateCRC16(const Data: array of Byte): Word;
var
  I, J: Integer;
  CRC: Word;
begin
  CRC := $FFFF;
  for I := 0 to High(Data) do
  begin
    CRC := CRC xor Data[I];
    for J := 0 to 7 do
    begin
      if (CRC and $0001) <> 0 then
        CRC := (CRC shr 1) xor $A001
      else
        CRC := CRC shr 1;
    end;
  end;
  Result := CRC;
end;

function CalculateLRC(const Data: TIdBytes): Byte;
var
  I: Integer;
  Sum: Byte;
begin
  Sum := 0;
  for I := 0 to High(Data) do
    Sum := Sum + Data[I];
  Result := Byte(-SmallInt(Sum));
end;

function CalculateLRC(const Data: array of Byte): Byte;
var
  I: Integer;
  Sum: Byte;
begin
  Sum := 0;
  for I := 0 to High(Data) do
    Sum := Sum + Data[I];
  Result := Byte(-SmallInt(Sum));
end;

function BytesToHex(const Data: TIdBytes): ShortString;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Data) do
    Result := Result + IntToHex(Data[I], 2);
end;

function HexToBytes(const HexStr: ShortString): TIdBytes;
var
  I: Integer;
begin
  SetLength(Result, Length(HexStr) div 2);
  for I := 0 to (Length(HexStr) div 2) - 1 do
    Result[I] := StrToInt('$' + Copy(HexStr, I * 2 + 1, 2));
end;

function Swap16(const DataToSwap: Word): Word;
begin
  Result := (DataToSwap div 256) + ((DataToSwap mod 256)*256);
end;




function BuildWriteMultipleCoilsRequest(DeviceID: Byte; StartAddress: Word;
  CoilCount: Word; const CoilValues: array of Word;
  ModbusMode: TModbusMode;
  out Buffer: TIdBytes; out ResponseLen: Byte): Boolean;
var
  TempBuffer: TIdBytes;
  CRC: Word;
  LRC: Byte;
  HexStr: string;
  I, DataSize: Integer;
  ByteCount: Byte;
begin
  Result := False;
  ResponseLen := 0;

  try
    if (CoilCount = 0) or (CoilCount > 1968) then
    begin
      SetLength(Buffer, 0);
      Exit(False);
    end;

    ByteCount := (CoilCount + 7) div 8;
    DataSize := 7 + ByteCount; // 7 áàéò çàãîëîâêà + äàííûå
    SetLength(TempBuffer, DataSize);

    TempBuffer[0] := DeviceID;
    TempBuffer[1] := $0F;                    // Write Multiple Coils
    TempBuffer[2] := Hi(StartAddress);
    TempBuffer[3] := Lo(StartAddress);
    TempBuffer[4] := Hi(CoilCount);
    TempBuffer[5] := Lo(CoilCount);
    TempBuffer[6] := ByteCount;

    // Çàïîëíÿåì äàííûå coils
    PutCoilsIntoBuffer(@TempBuffer[7], CoilCount, CoilValues);

    case ModbusMode of
      mmRTU:
        begin
          ResponseLen := 8; // [ID][0F][àäðåñ(2)][êîë-âî(2)][CRC(2)]
          CRC := CalculateCRC16(TempBuffer);
          SetLength(Buffer, Length(TempBuffer) + 2);
          Move(TempBuffer[0], Buffer[0], Length(TempBuffer));
          Buffer[DataSize] := Lo(CRC);
          Buffer[DataSize+1] := Hi(CRC);
        end;
      mmASCII:
        begin
          ResponseLen := 17;
          LRC := CalculateLRC(TempBuffer);
          SetLength(TempBuffer, DataSize + 1);
          TempBuffer[DataSize] := LRC;
          HexStr := ':' + BytesToHex(TempBuffer) + #13#10;
          DataSize := Length(HexStr);
          SetLength(Buffer, DataSize);
          for I := 1 to DataSize do
            Buffer[I-1] := Ord(HexStr[I]);
        end;
    end;
    Result := True;
  except
    SetLength(Buffer, 0);
    ResponseLen := 0;
    Result := False;
  end;
end;

end.
