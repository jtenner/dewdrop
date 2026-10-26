"""Instrument copies of printed Wasm; never use these copies for runtime costs."""
import re

CONSTRUCTOR = r"\b(array\.new_default|array\.new_fixed|array\.new_data|array\.new_elem|array\.new|struct\.new_default|struct\.new) (\d+)\b"


def instrument(wat, instructions=False, allocations=True):
    sites = sorted(set(re.findall(CONSTRUCTOR, wat))) if allocations else []
    extra = []
    if instructions:
        # wasm-tools prints one unfolded instruction per line. Count before
        # terminal instructions as well. Else/end are delimiters, not executed
        # instructions. The injected counters/helpers are not counted.
        wat = re.sub(r"^(\s+)([a-z][a-z0-9_.]*(?:[^\n]*))$", lambda m:
            m[0] if m[2].split()[0] in ("end", "else") else
            m[1] + "global.get $instructions\n" + m[1] + "i64.const 1\n" +
            m[1] + "i64.add\n" + m[1] + "global.set $instructions\n" + m[0], wat, flags=re.M)
        extra += ['  (global $instructions (export "instructions") (mut i64) (i64.const 0))']
    for i, (opcode, type_index) in enumerate(sites):
        extra += [f'  (global $alloc_{i} (mut i64) (i64.const 0))',
                  f'  (export "alloc_{i}" (global $alloc_{i}))']
        pattern = rf"^(\s*{re.escape(opcode)} {type_index}(?: \d+)?)$"
        wat = re.sub(pattern, rf"\1\n    global.get $alloc_{i}\n    i64.const 1\n    i64.add\n    global.set $alloc_{i}", wat, flags=re.M)
    extra += ['  (func (export "reset_allocations")']
    for i in range(len(sites)):
        extra.append(f"    i64.const 0 global.set $alloc_{i}")
    if instructions:
        extra += ["    i64.const 0 global.set $instructions"]
    extra += ["  )"]
    arrays = {}
    for i, kind in re.findall(r"\(type \(;(\d+);\) \(array \(mut (i32|i64|eqref)\)\)\)", wat):
        arrays.setdefault(kind, int(i))
    assert {"i32", "i64", "eqref"} <= arrays.keys()
    extra += [
        f'  (func (export "slot_null") (param eqref i32) (result i32) local.get 0 ref.cast (ref {arrays["eqref"]}) local.get 1 array.get {arrays["eqref"]} ref.is_null)',
        f'  (func (export "slot_set_ref") (param eqref i32 eqref) local.get 0 ref.cast (ref {arrays["eqref"]}) local.get 1 local.get 2 array.set {arrays["eqref"]})',
        f'  (func (export "slot_ref") (param eqref i32) (result eqref) local.get 0 ref.cast (ref {arrays["eqref"]}) local.get 1 array.get {arrays["eqref"]})',
        f'  (func (export "slots_length") (param eqref) (result i32) local.get 0 ref.cast (ref array) array.len)',
        f'  (func (export "slot_i32") (param eqref i32) (result i32) local.get 0 ref.cast (ref {arrays["i32"]}) local.get 1 array.get {arrays["i32"]})',
        f'  (func (export "slot_i64") (param eqref i32) (result i64) local.get 0 ref.cast (ref {arrays["i64"]}) local.get 1 array.get {arrays["i64"]})',
    ]
    return wat.rstrip()[:-1] + "\n" + "\n".join(extra) + "\n)\n", {
        f"alloc_{i}": dict(opcode=op, type=int(t)) for i, (op, t) in enumerate(sites)}
