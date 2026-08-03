from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
RUN = (ROOT / "uMeasurementRun.pas").read_text(encoding="utf-8-sig")
VERSION = (ROOT / "uAppVersion.pas").read_text(encoding="utf-8-sig")


def method(name: str, following: str) -> str:
    return RUN.split(f"procedure TMeasurementRun.{name}", 1)[1].split(
        f"procedure TMeasurementRun.{following}", 1
    )[0]


handle = method("HandleCommand", "RunThreadProc")
next_point = method("NextPoint", "PreviousPoint")
previous_point = method("PreviousPoint", "SelectForcedPoint")
navigation = method("RequestPointNavigation", "Execute")
enter_select = method("EnterSelectPoint", "EnterSelectEtalon")
set_point = RUN.split("function TMeasurementRun.SetPoint", 1)[1].split(
    "function TMeasurementRun.SelectEtalons", 1
)[0]
process_save = method("ProcessSave", "RequiresSaveConfirmation")

assert re.search(r"mcNextPoint\s*:\s*NextPoint", handle)
assert re.search(r"mcPreviousPoint\s*:\s*PreviousPoint", handle)
assert "FindNextEnabledPointIndex(FCurrentPointIndex + 1)" in next_point
assert "FindPreviousEnabledPointIndex(FCurrentPointIndex - 1)" in previous_point
assert "FForceNextPoint := ATargetIndex" in navigation
assert "SetStage(msSelectPoint)" in navigation
assert "SelectForcedPoint" in navigation
assert "FCurrentPointIndex :=" not in next_point
assert "FCurrentPointIndex :=" not in previous_point
assert "RequestStop" in navigation
assert "FNextStageAfterSave := msSelectPoint" in navigation
assert navigation.index("FForceNextPoint := ATargetIndex") < navigation.index("RequestStop")
assert "if FForceNextPoint >= 0 then\n    FCurrentPointIndex := FForceNextPoint\n  else" in enter_select
assert enter_select.index("FCurrentPointIndex := FForceNextPoint") < enter_select.index("Inc(FCurrentPointIndex)")
assert enter_select.index("FForceNextPoint := -1") < enter_select.index("SetPoint(FCurrentPointIndex, Error)")
assert "Notify(Integer(mePointChanged), Point)" in set_point
assert "NavigationAlreadyPending" in navigation
assert "FNextStageAfterSave = msSelectPoint" in process_save
assert "SetStage(msSelectPoint)" in process_save
assert "APP_VERSION = '1.0.53'" in VERSION
