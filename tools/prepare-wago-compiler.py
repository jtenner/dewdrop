#!/usr/bin/env python3
"""Bind unused bootstrap imports to Wasm traps for the native host check.

The Node check host also traps on these unused imports. Real Facet imports stay
imports. Defined function indices stay fixed; all imported function references
are changed to explicit names before the import list changes.
"""
import argparse
from pathlib import Path
import re
import subprocess

FUNCTION_IMPORT = re.compile(
    r'^  \(import "([^"]+)" "([^"]+)" \(func (?:\$[^\s]+ )?\(;(\d+);\)(.*?)\)\)\n',
    re.M,
)
TRAP_MODULES = frozenset(('__moonbit_fs_unstable', 'spectest'))


def adapt(source: str) -> str:
    imports = list(FUNCTION_IMPORT.finditer(source))
    if not imports:
        raise ValueError('compiler has no recognized function imports')
    if [int(item[3]) for item in imports] != list(range(len(imports))):
        raise ValueError('unexpected compiler import indices')
    names = {int(item[3]): f'$__dewdrop_host_{item[3]}' for item in imports}
    if any(name in source for name in names.values()):
        raise ValueError('reserved adapter name already occurs in compiler')
    stubs = []

    def replace_import(item):
        index = int(item[3])
        original_name = re.search(r'\(func (\$[^\s]+) ', item[0])
        if original_name:
            names[index] = original_name[1]
        if item[1] in TRAP_MODULES:
            stubs.append(f'  (func {names[index]}{item[4]} unreachable)\n')
            return ''
        # Preserve original symbolic names, which existing source may use.
        if original_name:
            return item[0]
        return item[0].replace('(func ', f'(func {names[index]} ', 1)

    source = FUNCTION_IMPORT.sub(replace_import, source)
    if not stubs:
        return source

    def target(number):
        index = int(number)
        return names.get(index, number)

    source = re.sub(r'\b(call|return_call|ref\.func) (\d+)\b',
                    lambda item: item[1] + ' ' + target(item[2]), source)
    source = re.sub(r'\(func (\d+)\)', lambda item: '(func ' + target(item[1]) + ')', source)
    source = re.sub(r'\(start (\d+)\)', lambda item: '(start ' + target(item[1]) + ')', source)
    # Legacy element lists use bare function indices rather than ref.func.
    source = re.sub(r'(^  \(elem[^\n]*?\bfunc )([^\n)]*)',
                    lambda item: item[1] + re.sub(r'(?<!\S)\d+(?!\S)',
                                                lambda number: target(number[0]), item[2]),
                    source, flags=re.M)
    remaining_imports = list(re.finditer(r'^  \(import [^\n]*\n', source, re.M))
    if remaining_imports:
        insertion = remaining_imports[-1].end()
    else:
        # Types must precede definitions; use the first existing definition.
        definition = re.search(r'^  \(func ', source, re.M)
        if definition is None:
            raise ValueError('compiler has no function definitions')
        insertion = definition.start()
    return source[:insertion] + ''.join(stubs) + source[insertion:]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('compiler', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    source = subprocess.check_output(['wasm-tools', 'print', str(args.compiler)], text=True)
    result = adapt(source)
    subprocess.run(['wasm-tools', 'parse', '-', '-o', str(args.output)], input=result, text=True, check=True)
    subprocess.run(['wasm-tools', 'validate', '--features', 'all', str(args.output)], check=True)


if __name__ == '__main__':
    main()
