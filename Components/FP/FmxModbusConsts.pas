{===============================================================================

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above. If you wish to
allow use of your version of this file only under the terms of the GPL and not
to allow others to use your version of this file under the MPL, indicate your
decision by deleting the provisions above and replace them with the notice and
other provisions required by the GPL. If you do not delete the provisions
above, a recipient may use your version of this file under either the MPL or
the GPL.

$Id: ModbusConsts.pas,v 1.32 2014/10/07 13:34:30 plpolak Exp $

===============================================================================}

{$I FmxModBusCompiler.inc}

unit FmxModbusConsts;

interface

uses
  FmxModbusTypes;

const
  MB_PORT = 502;
  MB_IGNORE_UNITID = 255;
  MB_PROTOCOL = 0;

  cModBusFormatName1='0_1_2_3';
  cModBusFormatName2='1_0_3_2';//ÒÐÌ10
  cModBusFormatName3='2_3_0_1';
  cModBusFormatName4='3_2_1_0';
  cModBusFormatName5='0_1';

  cModBusTypeOfDataNames:array[TModBusDataFormat] of String=(
                      cModBusFormatName1,
                      cModBusFormatName2,//ÒÐÌ10
                      cModBusFormatName3,
                      cModBusFormatName4,
                      cModBusFormatName5
                      );

// Define constants for the ModBus functions
const
  mbfReadCoils = $01;
  mbfReadInputBits = $02;
  mbfReadHoldingRegs = $03;
  mbfReadInputRegs = $04;
  mbfWriteOneCoil = $05;
  mbfWriteOneReg = $06;
  mbfWriteCoils = $0F;
  mbfWriteRegs = $10;
  mbfReadFileRecord = $14;
  mbfWriteFileRecord = $15;
  mbfMaskWriteReg = $16;
  mbfReadWriteRegs = $17;
  mbfReadFiFoQueue = $18;

// Define constants for the ModBus exceptions
const
  mbeOk = $00;
  mbeIllegalFunction = $01;
  mbeIllegalRegister = $02;
  mbeIllegalDataValue = $03;
  mbeServerFailure = $04;
  mbeAcknowledge = $05;
  mbeServerBusy = $06;
  mbeGatewayPathNotAvailable = $0A;
  mbeGatewayNoResponseFromTarget = $0B;

const
  MaxBlockLength = 125;
  MaxCoils = 2000;

const
  DMB_VERSION = '1.6.3'; {Do not Localize}
  
const
  DefaultLogTimeFormat = 'yyyy-mm-dd hh:nn:ss.zzz';  {Do not Localize}

function StrToModBusFormat(Value:String):TModBusDataFormat;

implementation

function StrToModBusFormat(Value:String):TModBusDataFormat;
var i:TModBusDataFormat;
begin
   result:=TModBusDataFormat.mdf_0_1_2_3;
   for I := TModBusDataFormat.mdf_0_1_2_3 to TModBusDataFormat.mdf_0_1 do
   begin
     if cModBusTypeOfDataNames[i]=Value
     then
     begin
       result:=I;
       break;
     end;
   end;
end;



end.

