from pathlib import Path


SOURCE = Path(__file__).parents[1] / "uWorkTable.pas"


def select_etalons_body() -> str:
    source = SOURCE.read_text(encoding="utf-8-sig")
    start = source.index("function TWorkTable.SelectEtalons(")
    end = source.index("procedure TWorkTable.DisableAllEtalons;", start)
    return source[start:end]


def test_select_etalons_logs_channel_names() -> None:
    body = select_etalons_body()

    assert ".FlowMeter.Name" not in body
    assert "Channel.Name" in body
    assert "BestSingle.Name" in body


def test_success_log_lists_selected_channels() -> None:
    body = select_etalons_body()

    assert 'SelectedChannels="%s"' in body
    assert "GetSelectedChannelNames(SelectedChannels)" in body
    assert "Result := Result + '; ';" in body
