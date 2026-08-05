from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORK_TABLE = (ROOT / "uWorkTable.pas").read_text(encoding="utf-8-sig")
DEVICE_CLASS = (ROOT / "uDeviceClass.pas").read_text(encoding="utf-8-sig")


def _procedure(source: str, start: str, end: str) -> str:
    body = source[source.index(start):]
    return body[:body.index(end)]


def test_save_measurement_results_stores_work_table_time_result_in_spillage_time():
    body = _procedure(
        WORK_TABLE,
        "procedure TWorkTable.SaveMeasurementResults;",
        "procedure TWorkTable.StartTest;",
    )
    create_index = body.index("Point := TPointSpillage.Create(Session.ID);")
    assign_index = body.index("Point.SpillTime := TimeResult;")
    assert create_index < assign_index
    assert "SelectedSource=TimeResult" in body
    assert "Point.SpillTime=%.9f; TimeMatchesTimeResult=%s" in body


def test_spillage_time_is_existing_result_field_not_new_time_result_field():
    spillage_class = _procedure(
        DEVICE_CLASS,
        "TPointSpillage = class",
        "constructor Create (ASessionID : Integer);",
    )
    assert "SpillTime: Double" in spillage_class
    assert "TimeResult" not in spillage_class
