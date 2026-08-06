# FMX grid stability audit

Scope: repo-owned root `*.pas`/`*.fmx`. `Components/` and the
`ProjectFornTest` demo (`FormMeterValue.fmx`) are excluded.

| Owner | Grid | Structure | Update/layout path | Policy |
|---|---|---|---|---|
| `fuDeviceEdit` | `GridPoints` | static FMX | `UpdatePointsGrid`, form show/deferred layout | observer; detailed boundary snapshots |
| `fuDeviceEdit` | `FGridCoefs` | dynamic runtime | coefficient-tab initialization/refresh | observer; columns created once |
| `fuDeviceSelect` | `GridDevices` | static FMX | filter/notification content refresh | observer |
| `fuTypeEditor` | `GridPoints`, `GridDiameters` | static FMX | editor content refresh | observers |
| `fuTypeEditor` | `FGridCoefs` | dynamic runtime | coefficient-tab initialization/refresh | observer; columns created once |
| `fuTypeSelect` | `GridTypes` | static FMX | filter/notification content refresh | observer |
| `frmMainTable` | `GridDevices`, `GridEtalons` | static FMX + persisted layout | work-table switch loads persisted layout; timers update content only | observers; guarded persisted assignments |
| `frmMainTable` | `GridAutoTestNumbers`, `GridAutoTestResults` | dynamic runtime | auto-test panel initialization/content | registered when created |
| `frmMeasurementRun` | `GridMeasurmentRun` | static FMX | measurement notifications/content | observer |
| `frmProceed` | `GridResults` | dynamic point columns + persisted layout | `UpdateResultsPointColumns`; signature-gated structural manager | observer + structural manager |
| `frmProceed` | `GridDataPoints`, `GridCoefs` | static FMX + persisted/content | result/content refresh | observers; no structural manager |
| `frmMRResults` | `GridMRResults` | dynamic point columns | `BuildColumns`; signature-gated structural manager | observer + structural manager |
| `frmCalibrCoefs` | `GridCoefs` | static FMX | calibration content | documented exclusion: short-lived internal dialog, no timer/notification path |
| `frmMeterValueEditFrame` | `GridSamples` | static FMX | embedded sample editor content | documented exclusion: legacy isolated editor frame |
| `fuMeterValues` | `StringGridCoefsData`, `StringGridCoefs`, `StringGridDimensions`, `StringGridValuesList` | static FMX | legacy meter-value editor | documented exclusion: legacy duplicate surface pending retirement |
| `frmMeterValueSelect` | `StringGridValuesList` | dynamic runtime | selector initialization/content | documented exclusion: private selector grid created once |

Structural signatures are per controller/grid and contain column identity,
class and visual index. `TGridLayoutManager.Apply` remains restricted to the
two grids whose point-dependent column set is genuinely dynamic. Persisted
layout is a one-time/work-table-switch operation, never part of row/value,
timer, notification or repaint refresh.

## Runtime verification protocol

Open every form/tab ten times without resizing a column. For each opening,
capture `after-fmx-load`, `after-show`, content boundaries and deferred-layout
events. Absence of `GridStability` change events confirms stability. For
`DeviceEdit.GridPoints`, the first emitted event identifies the first mutation
point; observer mode must remain enabled until that evidence exists. Corrective
mode is intentionally not enabled by this change.
