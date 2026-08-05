from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPOSITORIES = (ROOT / "uRepositories.pas").read_text(encoding="utf-8-sig")
DEBUG = (ROOT / "uMKSDebug.pas").read_text(encoding="utf-8-sig")


def _method(source: str, start: str, end: str) -> str:
    body = source[source.index(start):]
    return body[:body.index(end)]


def test_spillage_repository_insert_update_and_load_persist_spill_time():
    update_spillage = _method(
        REPOSITORIES,
        "function TDeviceRepository.UpdateSpillage(",
        " {$ENDREGION}",
    )
    assert "SpillTime, QavgEtalon" in update_spillage
    assert ":SpillTime, :QavgEtalon" in update_spillage
    assert "SpillTime=:SpillTime" in update_spillage
    assert "SetFloatParam(Q, 'SpillTime', ASpillage.SpillTime);" in update_spillage

    map_spillage = _method(
        REPOSITORIES,
        "function TDeviceRepository.MapSpillageFromQuery(",
        "function TDeviceRepository.LoadSpillagesByDevice",
    )
    assert "Result.SpillTime := Q.FieldByName('SpillTime').AsFloat;" in map_spillage


def test_spillage_select_includes_spill_time_and_loaded_log_shows_it():
    load_spillages = _method(
        REPOSITORIES,
        "function TDeviceRepository.LoadSpillagesByDevice(",
        "function TDeviceRepository.UpdateSpillages",
    )
    assert "select * from PointSpillage" in load_spillages

    dump_start = DEBUG.rindex("function DumpSpillage(const APoint: TPointSpillage): string;")
    dump_spillage = DEBUG[dump_start:DEBUG.index("procedure LogMKS", dump_start)]
    assert "SpillTime=%f" in dump_spillage
    assert "APoint.SpillTime" in dump_spillage
