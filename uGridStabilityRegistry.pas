unit uGridStabilityRegistry;

interface

uses
  FMX.Grid,
  System.Classes,
  uGridStabilityController;

{ Registration is deliberately explicit: tests compare these calls with every
  repo-owned TGrid/TStringGrid declaration. The returned observer is owned by
  AOwner and therefore needs no periodic housekeeping. }
function RegisterStableGrid(AOwner: TComponent; AGrid: TCustomGrid;
  const AFormName: string;
  const AEnableWidthControl: Boolean = True): TGridStabilityController;

implementation

function RegisterStableGrid(AOwner: TComponent; AGrid: TCustomGrid;
  const AFormName: string;
  const AEnableWidthControl: Boolean): TGridStabilityController;
begin
  Result := TGridStabilityController.Create(AOwner);
  Result.Attach(AGrid, AFormName, AEnableWidthControl);
  Result.Snapshot('after-fmx-load');
end;

end.
