from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PAS = (ROOT / "frmProceed.pas").read_text(encoding="utf-8-sig")
FMX = (ROOT / "frmProceed.fmx").read_text(encoding="utf-8-sig")
COEFS = (ROOT / "frmCalibrCoefs.pas").read_text(encoding="utf-8-sig")


def procedure_body(source: str, name: str) -> str:
    start = source.index(f"procedure {name}")
    next_proc = source.find("\nprocedure ", start + 1)
    return source[start:] if next_proc < 0 else source[start:next_proc]


def test_proceed_grids_are_configured_read_only():
    initialize = procedure_body(PAS, "TFrameProceed.Initialize")
    for grid in ("GridDataPoints", "GridResults", "GridCoefs"):
        assert f"SetGridReadOnly({grid});" in initialize

    helper = procedure_body(PAS, "TFrameProceed.SetGridReadOnly")
    assert "AGrid.Options - [TGridOption.Editing]" in helper
    assert "AGrid.Columns[I].ReadOnly := True" in helper
    assert "Grid.Enabled := False" not in PAS


def test_measurement_checkbox_click_does_not_mutate_model():
    handler = procedure_body(PAS, "TFrameProceed.GridDataPointsCellClick")
    assert "Point.Enabled" not in handler
    assert "UpdateActionHints;" in handler


def test_nested_coefficients_grid_is_read_only_in_proceed():
    init_frame = procedure_body(PAS, "TFrameProceed.InitCalibrCoefsFrame")
    assert "FFrameCalibrCoefs.SetGridReadOnly;" in init_frame
    readonly = procedure_body(COEFS, "TFrameCalibrCoefs.SetGridReadOnly")
    assert "GridCoefs.Options - [TGridOption.Editing]" in readonly
    assert "GridCoefs.OnSetValue := nil" in readonly


def test_dynamic_hints_name_actual_selection_sources_and_are_synchronized():
    hints = procedure_body(PAS, "TFrameProceed.UpdateActionHints")
    required = (
        "Удалить выбранное измерение из таблицы для выбранного в дереве прибора или сессии",
        "Выберите измерение в таблице для удаления",
        "Удалить все измерения выбранной в дереве сессии",
        "Удалить все отображаемые измерения выбранного в дереве прибора",
        "Создать новую сессию для выбранного в дереве прибора",
        "Закрыть активную сессию выбранного в дереве прибора",
        "Синхронизировать список обработки с выбранным в дереве рабочим столом",
        "Удалить все рабочие столы и связанные с ними данные",
    )
    for text in required:
        assert text in hints

    for action, buttons in {
        "ActionSessionPointDelete": ("ButtonSessionDeleteDataPoint", "Button3"),
        "ActionSessionPointsClear": ("ButtonSessionClearPoints", "Button5"),
        "ActionSessionNew": ("ButtonSessionNew", "Button4"),
        "ActionSessionClose": ("ButtonSessionClose", "Button6"),
    }.items():
        assert f"{action}.Hint :=" in hints
        for button in buttons:
            assert f"{button}.Hint :=" in hints


def test_toolbar_buttons_show_hints():
    for button in (
        "ButtonSessionDeleteDataPoint", "ButtonSessionNew",
        "ButtonSessionClearPoints", "ButtonSessionClose",
        "ButtonSessionSynchTable", "Button3", "Button4", "Button5", "Button6",
    ):
        start = FMX.index(f"object {button}: TButton")
        end = FMX.find("\n        end", start)
        assert "ShowHint = True" in FMX[start:end]
