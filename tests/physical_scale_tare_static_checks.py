from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FRAME = (ROOT / "FlowServiceMainPage/frmMainTable.pas").read_text(encoding="utf-8-sig")
WORK_TABLE = (ROOT / "FlowServiceMainPage/uWorkTable.pas").read_text(encoding="utf-8-sig")
METER_VALUE = (ROOT / "FlowServiceMainPage/uMeterValue.pas").read_text(encoding="utf-8-sig")
SCALES = (ROOT / "FMXFP/Components/FP/FmxScales.pas").read_text(encoding="utf-8-sig")
MAIN = (ROOT / "FMXFP/FlowPlantFMX/fuMain.pas").read_text(encoding="utf-8-sig")


def procedure_body(source: str, signature: str, next_signature: str) -> str:
    start = source.index(signature)
    end = source.index(next_signature, start)
    return source[start:end]


def test_both_buttons_use_the_single_physical_tare_operation():
    do_tare = procedure_body(
        SCALES, "procedure TFmxScales.DoTare;", "procedure TFmxScales.TareButtonClick"
    )
    click = procedure_body(
        SCALES, "procedure TFmxScales.TareButtonClick", "procedure TFmxScales.Update;"
    )
    request = procedure_body(
        MAIN, "procedure TMainForm.HandleScaleTareRequest", "procedure TMainForm.DoOnChangeScales"
    )

    assert "Device.Tare := 0;" in do_tare
    assert "Device.Tare := Device.ClearWeight;" in do_tare
    assert "DoTare;" in click
    assert "Scale.DoTare;" in request
    assert "DoOnChangeScales(Scale, Scale.Device);" in request
    assert "SameText(Trim(Project.Scales[I].Name), Trim(AScaleName))" in request


def test_table_button_only_raises_a_named_tare_request():
    click = procedure_body(
        FRAME, "procedure TFrameMainTable.ButtonScaleTareClick", "procedure TFrameMainTable.ButtonScaleDrainClick"
    )
    assert "FOnScaleTareRequest(Self, FActiveWorkTable.ActiveScale.Name);" in click
    assert "DoScaleTare" not in click
    assert "CurrentWeight :=" not in click


def test_work_table_software_tare_is_removed_from_runtime_and_persistence():
    assert "ScaleTareWeight" not in WORK_TABLE
    assert "DoScaleTare" not in WORK_TABLE


def test_physical_weight_and_constant_formatting_are_used():
    update = procedure_body(
        FRAME, "procedure TFrameMainTable.UpdateUIScale;", "procedure TFrameMainTable.UpdateUIFlowRate;"
    )
    integer_format = procedure_body(
        METER_VALUE,
        "function TMeterValue.GetStrNum(AValue: Double; const ADim: integer): string;",
        "function TMeterValue.GetDoubleNum(AValue: Double; const ADim: string): Double;",
    )
    assert "WorkTable.ActiveScale.CurrentWeight" in update
    assert "WorkTable.TableFlow.ValueMass.GetStrNum" in update
    assert "RoundedWeight, 0" in update
    assert "ValueType := CONST_TYPE;" in integer_format
    assert "ValueType := TempType;" in integer_format
