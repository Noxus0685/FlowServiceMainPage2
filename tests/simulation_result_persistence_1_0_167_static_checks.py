from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
WORK_TABLE = ROOT / "FlowServiceMainPage" / "uWorkTable.pas"
VERSION_UNIT = ROOT / "FlowServiceMainPage" / "uAppVersion.pas"


def method_body(source: str, start: str, end: str) -> str:
    match = re.search(
        rf"{re.escape(start)}.*?(?={re.escape(end)})",
        source,
        re.DOTALL,
    )
    assert match, f"{start} body not found"
    return match.group(0)


def test_simulation_results_use_normal_save_pipeline() -> None:
    source = WORK_TABLE.read_text(encoding="utf-8-sig")
    body = method_body(
        source,
        "procedure TWorkTable.SaveMeasurementResults",
        "procedure TWorkTable.StartTest",
    )

    assert "Сценарный тест: рабочее сохранение результатов заблокировано" not in body
    assert "DeviceRepo := nil;" in body
    assert "for DeviceChannel in DeviceChannels do" in body
    assert "Point := TPointSpillage.Create(Session.ID);" in body


def test_application_version_is_1_0_167() -> None:
    source = VERSION_UNIT.read_text(encoding="utf-8-sig")
    assert "APP_VERSION = '1.0.168';" in source
