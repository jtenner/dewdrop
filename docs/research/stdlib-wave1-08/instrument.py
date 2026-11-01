"""Count executed GC allocations without changing the production source.

Adds two globals and exports to a scratch copy of emitted WAT. Stack-neutral
counter increments precede flat allocation instructions. This is evidence only.
"""
from pathlib import Path
import re
p = Path('.tmp/iter-consumer.wat')
wat = p.read_text()
assert 'global $probe_' not in wat
counts = {'struct': 0, 'array': 0}
def instrument(match):
    indent, operation = match.groups()
    kind = 'struct' if operation.startswith('struct.') else 'array'
    counts[kind] += 1
    return (f'{indent}global.get $probe_{kind}\n{indent}i64.const 1\n'
            f'{indent}i64.add\n{indent}global.set $probe_{kind}\n'
            f'{indent}{operation}')
wat = re.sub(r'^(\s*)(struct\.new(?:_default)?\b|array\.new(?:_default|_fixed|_data|_elem)?\b)', instrument, wat, flags=re.M)
assert counts['struct'] and counts['array'], counts
end = wat.rfind(')')
wat = wat[:end] + '''
  (global $probe_struct (mut i64) (i64.const 0))
  (global $probe_array (mut i64) (i64.const 0))
  (func (export "probe_struct") (result i64) global.get $probe_struct)
  (func (export "probe_array") (result i64) global.get $probe_array)
  (func (export "probe_reset")
    i64.const 0 global.set $probe_struct
    i64.const 0 global.set $probe_array)
''' + wat[end:]
Path('.tmp/iter-instrumented.wat').write_text(wat)
print('instrumented allocation sites:', counts)
