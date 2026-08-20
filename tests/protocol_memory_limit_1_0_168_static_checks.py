from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[2]
PROTOCOL_FORM = ROOT / "FlowServiceMainPage" / "frmProtocol.pas"
VERSION_UNIT = ROOT / "FlowServiceMainPage" / "uAppVersion.pas"


def method_body(source: str, start: str, end: str) -> str:
    match = re.search(
        rf"{re.escape(start)}.*?(?={re.escape(end)})",
        source,
        re.DOTALL,
    )
    assert match, f"{start} body not found"
    return match.group(0)


def test_protocol_memory_and_display_are_bounded() -> None:
    source = PROTOCOL_FORM.read_text(encoding="utf-8-sig")

    assert "CProtocolMemoryMessageLimit = 2000;" in source
    assert "CProtocolDisplayMessageLimit = 2000;" in source
    assert "while FMessages.Count > CProtocolMemoryMessageLimit do" in source
    assert "while ListBoxProtocol.Count > CProtocolDisplayMessageLimit do" in source


def test_full_protocol_is_streamed_to_file() -> None:
    source = PROTOCOL_FORM.read_text(encoding="utf-8-sig")

    handle = method_body(
        source,
        "procedure TFrameProtocol.HandleProtocolMessage",
        "procedure TFrameProtocol.CopyProtocolToClipboard",
    )
    export = method_body(
        source,
        "procedure TFrameProtocol.ExportProtocolToFile",
        "destructor TFrameProtocol.Destroy",
    )

    assert "AppendFullLogMessage(CopyMsg);" in handle
    assert "FFullLogWriter.WriteLine" in source
    assert "TFile.Copy(FFullLogFileName, FileName, True);" in export


def test_clipboard_copy_is_bounded_and_warns_only_when_partial() -> None:
    source = PROTOCOL_FORM.read_text(encoding="utf-8-sig")

    copy_body = method_body(
        source,
        "procedure TFrameProtocol.CopyProtocolToClipboard",
        "procedure TFrameProtocol.AddProtocolItem",
    )
    warning_body = method_body(
        source,
        "procedure TFrameProtocol.ShowPartialCopyWarning",
        "procedure TFrameProtocol.ExportProtocolToFile",
    )

    assert "CClipboardCharacterLimit = 5 * 1024 * 1024;" in source
    assert "CClipboardCharacterLimit" in copy_body
    assert "ShowPartialCopyWarning(CopiedCount);" in copy_body
    assert "if ACopiedCount >= FTotalMessageCount then" in warning_body
    assert "В буфер скопирован не весь журнал" in warning_body


def test_old_protocol_files_are_expired_and_total_size_is_bounded() -> None:
    source = PROTOCOL_FORM.read_text(encoding="utf-8-sig")
    cleanup = method_body(
        source,
        "procedure TFrameProtocol.CleanupOldProtocolFiles",
        "procedure TFrameProtocol.InitializeFullLog",
    )

    assert "CProtocolRetentionDays = 7;" in source
    assert "CProtocolTotalSizeLimit = Int64(1024) * 1024 * 1024;" in source
    assert "CProtocolFileSizeLimit = Int64(100) * 1024 * 1024;" in source
    assert "CollectFiles('protocol_session_*.txt');" in cleanup
    assert "CollectFiles('protocol_export_*.txt');" in cleanup
    assert "ModifiedTime < Cutoff" in cleanup
    assert "while TotalSize > CProtocolTotalSizeLimit do" in cleanup
    assert "if IsCurrentLogFile(FileName) then" in cleanup


def test_rotated_session_parts_are_exported_without_loading_all_text() -> None:
    source = PROTOCOL_FORM.read_text(encoding="utf-8-sig")
    append = method_body(
        source,
        "procedure TFrameProtocol.AppendFullLogMessage",
        "procedure TFrameProtocol.TrimStoredMessages",
    )
    export = method_body(
        source,
        "procedure TFrameProtocol.ExportProtocolToFile",
        "destructor TFrameProtocol.Destroy",
    )

    assert "FCurrentLogSizeBytes + LineSize > CProtocolFileSizeLimit" in append
    assert "FSessionLogFiles.Add(FFullLogFileName);" in source
    assert "for I := 0 to FSessionLogFiles.Count - 1 do" in export
    assert "while not Reader.EndOfStream do" in export
    assert "Writer.WriteLine(Reader.ReadLine);" in export


def test_application_version_is_1_0_168() -> None:
    source = VERSION_UNIT.read_text(encoding="utf-8-sig")
    assert "APP_VERSION = '1.0.168';" in source
