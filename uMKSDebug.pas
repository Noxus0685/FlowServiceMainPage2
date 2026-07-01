unit uMKSDebug;

interface

uses
  System.SysUtils,
  uDeviceClass;

function DumpSpillage(const APoint: TPointSpillage): string;
procedure LogMKS(const ACode, APlace, AText: string);

implementation

uses
  uProtocols;

function DumpSpillage(const APoint: TPointSpillage): string;
begin
  if APoint = nil then
    Exit('<nil>');

  Result := Format(
    'Ptr=%p; ID=%d; Num=%d; Name="%s"; SessionID=%d; DevicePointID=%d; DeviceTypePointID=%d; Valid=%s; Status=%d; State=%d; Error=%f; QavgEtalon=%f; Enabled=%s',
    [
      Pointer(APoint),
      APoint.ID,
      APoint.Num,
      APoint.Name,
      APoint.SessionID,
      APoint.DevicePointID,
      APoint.DeviceTypePointID,
      BoolToStr(APoint.Valid, True),
      APoint.Status,
      Ord(APoint.State),
      APoint.Error,
      APoint.QavgEtalon,
      BoolToStr(APoint.Enabled, True)
    ]
  );
end;

procedure LogMKS(const ACode, APlace, AText: string);
begin
  if ProtocolManager <> nil then
    ProtocolManager.AddMessage(pcMKS, psForm, ACode, APlace, AText);
end;

end.
