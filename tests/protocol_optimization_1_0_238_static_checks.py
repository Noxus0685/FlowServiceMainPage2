from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROTOCOLS = (ROOT / "uProtocols.pas").read_text(encoding="utf-8-sig")
WORK_TABLE = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8-sig")
MAIN_TABLE = (ROOT / "frmMainTable.pas").read_text(encoding="utf-8-sig")
FORM = (ROOT / "frmProtocol.pas").read_text(encoding="utf-8-sig")


def test_defaults_and_persistence_keys():
    for field in ("FProtocolEnabled", "FLogEnabled", "FSampleChartEnabled", "FStatisticsEnabled"):
        assert f"{field} := 0" in PROTOCOLS
    for key in ("ProtocolEnabled", "LogEnabled", "SampleChartEnabled", "StatisticsEnabled"):
        assert f"'{key}'" in PROTOCOLS


def test_worker_and_single_batched_ui_callback():
    assert "NameThreadForDebugging('ProtocolThread')" in PROTOCOLS
    assert "CompareExchange(FUiCallbackPending, 1, 0)" in PROTOCOLS
    assert "Batch.Count < 100" in PROTOCOLS
    assert "TStopwatch.Frequency < 10" in PROTOCOLS
    assert "TThread.Queue(nil" not in PROTOCOLS
    assert "RemoveQueuedEvents(LThread)" in PROTOCOLS


def test_measurement_gates_precede_history_recording():
    start = MAIN_TABLE.index("procedure StoreChannelSignals(AChannel: TChannel)")
    store = MAIN_TABLE[start:MAIN_TABLE.index("begin\n  NormalizeActiveWorkTable", start)]
    assert store.index("if AChannel = nil") < store.index("if not AChannel.Enabled")
    assert store.index("if not AChannel.Enabled") < store.index("if not AcquisitionActive")
    assert store.index("if not AcquisitionActive") < store.index("AChannel.RecordPendingMeasurements")
    assert "ProtocolManager.SampleChartEnabled or ProtocolManager.StatisticsEnabled" in store


def test_detailed_samples_and_statistics_are_guarded():
    assert "ProtocolManager.SampleChartEnabled then\n    ProtocolManager.AddMessage(pcProc" in WORK_TABLE
    statistics = WORK_TABLE[WORK_TABLE.index("function TChannel.GetSignalStatistics"):]
    assert "not ProtocolManager.StatisticsEnabled then Exit" in statistics
    assert "not ProtocolManager.StatisticsEnabled then" in FORM or "StatisticsEnabled" in FORM


def test_version():
    assert "APP_VERSION = '1.0.238'" in (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")
    assert "FileVersion=1.0.238.0" in (ROOT / "ProjectFornTest.dproj").read_text(encoding="utf-8-sig")
