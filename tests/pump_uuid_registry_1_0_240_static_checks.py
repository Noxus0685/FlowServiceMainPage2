from pathlib import Path

root = Path(__file__).resolve().parents[1]
parameter = (root / 'uParameter.pas').read_text(encoding='utf-8-sig')
work_table = (root / 'uWorkTable.pas').read_text(encoding='utf-8-sig')


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


require('TPump = class(TParameter)' in parameter, 'TPump declaration is missing')
require('FUUID: string;' in parameter, 'TPump must store a UUID')
require('property UUID: string read FUUID write FUUID;' in parameter,
        'TPump UUID property is missing')
require('FUUID := TGUID.NewGuid.ToString;' in parameter,
        'New TPump objects must receive a UUID')

require("AIni.WriteString(Section, 'UUID', Pump.UUID);" in work_table,
        'Pump UUID must be saved with each work-table pump reference')
require("PumpUUID := Trim(AIni.ReadString(Section, 'UUID', ''));" in work_table,
        'Pump UUID must be loaded')
require('SameText(Trim(Candidate.UUID), PumpUUID)' in work_table,
        'Loaded pumps must be resolved by UUID')
require("((PumpUUID = '') and" in work_table and
        'SameText(Trim(Candidate.Name), PumpName)' in work_table,
        'Legacy projects without pump UUIDs must fall back to Name')
require("if PumpUUID <> '' then\n        Pump.UUID := PumpUUID;" in work_table,
        'A newly restored pump must receive its persisted UUID')
require('SameText(Trim(Pump.UUID), PumpUUID)' in work_table,
        'TWorkTable.FindPumpByUUID must compare UUIDs')

print('OK: TPump UUID persistence and registry restoration checks passed.')
