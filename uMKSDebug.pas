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
    'Ptr=%p; ID=%d; Name="%s"; DeviceUUID=%s; DeviceTypeUUID=%s; QavgEtalon=%f; EtalonName="%s"; EtalonUUID=%s; Num=%d; SessionID=%d; Valid=%s; Status=%d; State=%d; Error=%f; Enabled=%s',
    [
      Pointer(APoint),
      APoint.ID,
      APoint.Name,
      APoint.DeviceUUID,
      APoint.DeviceTypeUUID,
      APoint.QavgEtalon,
      APoint.EtalonName,
      APoint.EtalonUUID,
      APoint.Num,
      APoint.SessionID,
      BoolToStr(APoint.Valid, True),
      APoint.Status,
      Ord(APoint.State),
      APoint.Error,
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
