from pathlib import Path
import re

fmx = (Path(__file__).resolve().parents[1] / 'frmProceed.fmx').read_text(
    encoding='utf-8-sig')
lines = fmx.splitlines()

# Parse the FMX object tree, rather than merely comparing totals.
stack = []
parents = {}
for number, line in enumerate(lines, 1):
    match = re.match(r'^(\s*)object\s+(\w+):\s*(\w+)\s*$', line)
    if match:
        indent = len(match.group(1))
        if stack:
            assert indent > stack[-1][0], f'OBJECT expected before line {number}'
            parents[match.group(2)] = stack[-1][1]
        else:
            assert match.group(2) == 'FrameProceed', 'root object must be FrameProceed'
            parents[match.group(2)] = None
        stack.append((indent, match.group(2), number))
    elif re.match(r'^\s*end\s*$', line):
        assert stack, f'orphan end on line {number}'
        stack.pop()

assert not stack, f'unclosed objects: {stack}'
assert sum(bool(re.match(r'^\s*object\s', line)) for line in lines) == \
       sum(bool(re.match(r'^\s*end\s*$', line)) for line in lines)

assert parents['LayoutTop'] == 'FrameProceed'
assert parents['ToolBarDataPoints'] == 'LayoutTop'
assert parents['Layout32'] == 'ToolBarDataPoints'
assert parents['ButtonProceedExportExcel'] == 'Layout32'
assert parents['lyt1'] == 'FrameProceed'
assert parents['LayoutMiddle'] == 'FrameProceed'
assert parents['TreeViewDevices'] == 'LayoutLeft'
assert parents['GridResults'] == 'Layout18'

assert fmx.count('object ToolBarDataPoints: TToolBar') == 1
assert fmx.count('object ButtonProceedExportExcel: TButton') == 1
assert fmx.count(': TToolBar') == 1

# Every quoted string property must close its apostrophes. Doubled apostrophes
# inside FMX literals are ignored when checking balance.
string_properties = ('Text', 'Hint', 'Header', 'Caption', 'StyleLookup',
                     'FileName', 'Filter')
for number, line in enumerate(lines, 1):
    prop = re.match(r'^\s*(\w+)\s*=\s*(.*)$', line)
    if not prop or prop.group(1) not in string_properties:
        continue
    value = prop.group(2)
    without_escaped = value.replace("''", '')
    assert without_escaped.count("'") % 2 == 0, \
        f'Invalid string constant on line {number}: {line}'

button = fmx.split('object ButtonProceedExportExcel: TButton', 1)[1].split(
    '        end', 1)[0]
assert "Hint = 'Выгрузить выбранные данные в Excel'" in button
assert '#' not in next(line for line in button.splitlines() if 'Hint =' in line)

print('frmProceed.fmx integrity checks passed')
