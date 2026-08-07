# FMX grid stability audit

Scope: repo-owned root `*.pas`/`*.fmx`. `Components/` and the
`ProjectFornTest` demo (`FormMeterValue.fmx`) are excluded.

| Owner | Grid | Structure | Update/layout path | Policy |
|---|---|---|---|---|
| `fuDeviceEdit` | `GridPoints` | static FMX | `UpdatePointsGrid`, form show/deferred layout | dedicated structural/width state; observer only in registry |
| `fuDeviceEdit` | `FGridCoefs` | dynamic runtime | coefficient-tab initialization/refresh | shared width state; stable named columns |
| `fuDeviceSelect` | `GridDevices` | static FMX | filter/notification content refresh | shared width state |
| `fuTypeEditor` | `GridPoints`, `GridDiameters` | static FMX | editor content refresh | shared width states |
| `fuTypeEditor` | `FGridCoefs` | dynamic runtime | coefficient-tab initialization/refresh | shared width state; stable named columns |
| `fuTypeSelect` | `GridTypes` | static FMX | filter/notification content refresh | shared width state |
| `frmMainTable` | `GridDevices`, `GridEtalons` | static FMX + persisted layout | work-table switch loads persisted layout; timers update content only | shared width states |
| `frmMainTable` | `GridAutoTestNumbers`, `GridAutoTestResults` | dynamic runtime | auto-test panel initialization/content | shared width states; stable named columns |
| `frmMeasurementRun` | `GridMeasurmentRun` | static FMX | measurement notifications/content | shared width state |
| `frmProceed` | `GridResults` | dynamic point columns + persisted layout | `UpdateResultsPointColumns`; signature-gated structural manager | dedicated structural/width state; observer only in registry |
| `frmProceed` | `GridDataPoints`, `GridCoefs` | static FMX + persisted/content | result/content refresh | shared width states |
| `frmMRResults` | `GridMRResults` | dynamic point columns | `BuildColumns`; signature-gated structural manager | dedicated structural/width state; observer only in registry |
| `frmCalibrCoefs` | `GridCoefs` | static FMX | calibration content | shared width state |
| `frmMeterValueEditFrame` | `GridSamples` | static FMX | embedded sample editor content | shared width state |
| `fuMeterValues` | `StringGridCoefsData`, `StringGridCoefs`, `StringGridDimensions`, `StringGridValuesList` | static FMX | legacy meter-value editor | shared width states registered once on show |
| `frmMeterValueSelect` | `StringGridValuesList` | dynamic runtime | selector initialization/content | shared width state; stable named columns |

Structural signatures are per controller/grid and contain column identity,
class and visual index. Every application-owned root `TGrid` and
`TStringGrid` now receives manual-only persistent width control.
`TGridLayoutManager.Apply` remains restricted to the two grids whose
point-dependent column set is genuinely dynamic. Those two grids and
`DeviceEdit.GridPoints` keep their dedicated state to prevent duplicate
`OnResize` handlers. Persisted layout is a one-time/work-table-switch
operation, never part of row/value, timer, notification or repaint refresh.

## Runtime verification protocol

Open every form/tab ten times without resizing a column. For each opening,
capture `after-fmx-load`, `after-show`, content boundaries and deferred-layout
events. Absence of `GridStability` change events confirms stability. For
`DeviceEdit.GridPoints`, the first emitted event identifies the first mutation
point; observer mode must remain enabled until that evidence exists. Corrective
mode is intentionally not enabled by this change.
