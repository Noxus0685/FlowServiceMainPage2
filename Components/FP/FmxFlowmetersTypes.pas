unit FmxFlowmetersTypes;

interface

uses
  FMX.Controls,
  FmxFPDevice;  // используем TFmxOutputType из этого модуля

type
  TChannelSettings = record
    UnitID: LongInt;
    UnitTypeID: LongInt;
    UnitName: string;
    UnitTypeName: string;
    UnitNumber: string;
    Mass: Boolean;
    MaxDischarge: Single;
    MinDischarge: Single;
    OutputParam1: Single;
    OutputParam2: Single;
    OutputParam3: Single;
    OutputParam4: Single;
    F_ChannelNumber: Byte;
    I_ChannelNumber: Byte;
    U_ChannelNumber: Byte;
    TypeOfConnection: TFmxOutputType;   // теперь тип из FmxFPDevice
    TypeOfInput: Byte;
    Interval_Error: Double;
    Interval_Outlay: Double;
    Interval_Volume: Double;
    Interval_Impulses: Double;
    Interval_RAW: Double;
    Interval_Counter: LongWord;
  end;


implementation

end.
