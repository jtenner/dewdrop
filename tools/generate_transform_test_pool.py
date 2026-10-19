#!/usr/bin/env python3
"""Build test-only standard source data; interpreted tests need no host reads."""
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent

def module_name(path: Path) -> str:
    relative = path.relative_to(ROOT / 'std')
    if relative.parts[0] == 'preamble':
        return 'dew.std.preamble'
    if relative.as_posix() == 'string_fixed_array.dew':
        return 'dew.std.string'
    return 'dew.std.' + '.'.join(relative.with_suffix('').parts)


def fixture_imports(name: str) -> str:
    # Match append_standard_module in self_host_bootstrap_fixture. These are
    # ordinary import files in test data, not special compiler execution rules.
    if name == 'dew.std.preamble':
        return ''
    if name == 'dew.std.option':
        return 'open dew.std.preamble\n'
    if name in {'dew.std.result', 'dew.std.text_runtime'}:
        return 'open dew.std.preamble\nopen dew.std.option\n'
    if name in {'dew.std.string', 'dew.std.string_builder',
                'dew.std.bytes_builder', 'dew.std.bytes'}:
        return 'open dew.std.preamble\nopen dew.std.text_runtime\nopen dew.std.option\n'
    return 'open dew.std.preamble\nopen dew.std.option\nopen dew.std.result\n'


def main() -> None:
    groups: dict[str, list[Path]] = {}
    for path in sorted((ROOT / 'std').rglob('*.dew')):
        groups.setdefault(module_name(path), []).append(path)
    required = {'dew.std.preamble', 'dew.std.option', 'dew.std.result',
                'dew.std.array', 'dew.std.string', 'dew.std.string_builder',
                'dew.std.bytes', 'dew.std.bytes_builder', 'dew.std.wasm.intrinsics',
                'dew.std.types', 'dew.std.iter'}
    pending = list(required)
    while pending:
        name = pending.pop()
        for path in groups[name]:
            source = path.read_text()
            for dependency in re.findall(r'^\s*(?:open|import)\s+(dew\.std\.[a-zA-Z0-9_.]+)', source, re.M):
                if dependency not in required:
                    required.add(dependency)
                    pending.append(dependency)
    lines = ['// Generated test data. Source algorithms use normal compiler rules.',
             'fn ct_frames_test_source_pool() -> SelfHostProgramManifest {',
             '  {', '    modules: [']
    source_size = 0
    for name in sorted(required):
        lines.extend(['      {', f'        path: {json.dumps(name)}', '        files: ['])
        imports = fixture_imports(name)
        if imports:
            lines.extend(['          {', '            path: "__dew_std_imports.dew"',
                          f'            source: b{json.dumps(imports)}',
                          '            test_only: false', '          },'])
        for path in groups[name]:
            source = path.read_text()
            source_size += len(source.encode())
            lines.extend(['          {', f'            path: {json.dumps(path.relative_to(ROOT).as_posix())}',
                          f'            source: b{json.dumps(source)}', '            test_only: false', '          },'])
        lines.extend(['        ]', '      },'])
    lines.extend(['    ]', '  }', '}', ''])
    destination = Path(sys.argv[1])
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text('\n'.join(lines))
    print(f'transform test pool: {len(required)} modules, {source_size} source bytes')


if __name__ == '__main__':
    main()
