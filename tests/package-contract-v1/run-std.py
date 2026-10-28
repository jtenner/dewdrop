#!/usr/bin/env python3
"""Run shared contract cases through an explicit, already-built Dew compiler.

This is a narrow source-code check, not a compiler build or a timing benchmark.
The caller supplies an evidence directory; all commands and streams stay there.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[2]
KINDS = ["name", "semver", "requirement", "requirement-match", "manifest", "artifact-paths"]


def literal(text):
    return '"' + ''.join(
        '\\"' if c == '"' else '\\\\' if c == '\\' else
        f'\\x{ord(c):02x}' if ord(c) < 32 else c for c in text
    ) + '"'


def text_expression(text):
    # The metadata byte-boundary cases use space padding. Keep the generated
    # compiler input small while preserving their exact runtime bytes.
    trimmed = text.rstrip(' ')
    if len(text) - len(trimmed) > 1024:
        return f'vector_pad({literal(trimmed)}, {len(text)}u32)'
    return literal(text)


def assertion(expression, expected, message):
    expression = expression if expected else f'!({expression})'
    return f'  assert({expression}, {literal(message)})'


def generate(cases):
    source = '''open dew.std.array
open dew.std.bytes
open dew.std.bytes_builder
open dew.std.decode
open dew.std.encode
open dew.std.fixed_array
open dew.std.format
open dew.std.integrity.sha256
open dew.std.package
open dew.std.package.artifact
open dew.std.semver
open dew.std.string
open dew.std.string_builder

fn vector_pad(value: String, length: U32) -> String {
  let builder = StringBuilder::new()
  builder.append(value)
  while value.byte_length() {
    index if index < length => {
      builder.append(" ")
      continue index + 1u32
    }
    _ => break ()
  }
  builder.finish()
}

fn vector_version(text: String) -> SemVer {
  match semver_parse(text) {
    Result::Ok(value) => value
    Result::Err(_) => unreachable()
  }
}

fn vector_raw_artifact(files: Array<PackageArtifactFile>, version: String) -> Bytes {
  let output = BytesBuilder::new()
  output.append(b"DEWPKG1\\x00")
  package_artifact_write_string(output, "@a/b")
  package_artifact_write_string(output, version)
  package_artifact_write_string(output, "file:fixture")
  package_artifact_write_string(output, "sha256-0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
  package_artifact_write_string(output, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
  package_artifact_write_u32(output, 0u32)
  package_artifact_write_u32(output, files.length())
  while 0u32 {
    index if index < files.length() => {
      let file = files.get_unchecked(index)
      package_artifact_write_string(output, file.path())
      package_artifact_write_bytes(output, file.contents())
      continue index + 1u32
    }
    _ => break ()
  }
  let payload = output.finish()
  let complete = BytesBuilder::new()
  complete.append(payload)
  let digest = sha256(payload)
  while 0u32 {
    index if index < 32u32 => {
      complete.append_byte(digest.get_unchecked(index))
      continue index + 1u32
    }
    _ => break ()
  }
  complete.finish()
}
'''
    for case in cases:
        kind, value, expected = case['kind'], case['input'], case['expected']
        message = f"{case['id']}: {case['rule']}"
        lines = []
        if kind == 'name':
            lines.append(assertion(f'package_name_is_valid({text_expression(value)})', expected['accept'], message))
        elif kind in ('semver', 'requirement'):
            function = 'semver_parse' if kind == 'semver' else 'package_requirement_parse'
            lines.append(assertion(f'{function}({text_expression(value)}) is Result::Ok(_)', expected['accept'], message))
            if kind == 'semver':
                manifest = json.dumps({'name': '@a/b', 'version': value}, separators=(',', ':'), ensure_ascii=False)
                lock = json.dumps({'lockfileVersion': 1, 'packages': [{'name': '@a/b', 'version': value, 'source': 'file:fixture', 'path': 'fixture', 'integrity': 'sha256-' + 'a' * 64, 'interface': 'b' * 64}]}, separators=(',', ':'), ensure_ascii=False)
                lines.append(assertion(f'package_manifest_try_decode({literal(manifest)}.as_bytes()) is Result::Ok(_)', expected['accept'], message + ': manifest'))
                lines.append(assertion(f'package_lock_try_decode({literal(lock)}.as_bytes()) is Result::Ok(_)', expected['accept'], message + ': lock'))
                lines.extend(['  let files = Array::new()', '  files.push(package_artifact_file("main.dew", b"x"))'])
                lines.append(assertion(f'package_artifact_try_decode(vector_raw_artifact(files, {text_expression(value)})) is Result::Ok(_)', expected['accept'], message + ': artifact'))
        elif kind == 'requirement-match':
            lines.append(f'  match package_requirement_parse({literal(value["requirement"])}) {{')
            lines.append('    Result::Ok(request) => {')
            lines.append(assertion(f'package_requirement_matches(request, vector_version({literal(value["version"])}))', expected['matches'], message))
            lines.extend(['    }', f'    Result::Err(_) => assert(false, {literal(message + ": valid request rejected")})', '  }'])
        elif kind == 'manifest':
            lines.append(f'  let result = package_manifest_try_decode({text_expression(value)}.as_bytes())')
            lines.append(assertion('result is Result::Ok(_)', expected['accept'], message))
            if expected['accept'] and 'dependencies' in expected:
                lines.extend(['  match result {', '    Result::Ok(manifest) => {'])
                dependencies = expected['dependencies']
                lines.append(assertion(f'manifest.dependencies().length() == {len(dependencies)}u32', True, message + ': normalized dependencies'))
                for name, requirement in dependencies.items():
                    lines.extend(['      let mut found = false', '      while 0u32 {',
                                  '        index if index < manifest.dependencies().length() => {',
                                  '          let dependency = manifest.dependencies().get_unchecked(index)',
                                  f'          if dependency.name().equals({literal(name)}) && package_requirement_to_string(dependency.requirement()).equals({literal(requirement)}) {{',
                                  '            found = true', '          }',
                                  '          continue index + 1u32', '        }', '        _ => break ()', '      }',
                                  assertion('found', True, message + ': dependency ' + name)])
                lines.extend(['    }', '    Result::Err(_) => unreachable()', '  }'])
        elif kind == 'artifact-paths':
            lines.append('  let files = Array::new()')
            lines.extend(f'  files.push(package_artifact_file({literal(path)}, b"x"))' for path in value)
            lines.append(assertion('package_artifact_try_decode(vector_raw_artifact(files, "1.0.0")) is Result::Ok(_)', expected['accept'], message + ': decode'))
            lines.append('  let artifact = package_artifact("@a/b", vector_version("1.0.0"), "file:fixture", "sha256-0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", Array::new(), files)')
            lines.append(assertion('artifact.validate() is Result::Ok(_)', expected['accept'], message + ': validate'))
            lines.append(assertion('artifact.encode() is Result::Ok(_)', expected['accept'], message + ': encode'))
        source += '\ntest ' + literal(case['id']) + ' {\n' + '\n'.join(lines) + '\n}\n'
    return source


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler', required=True, type=Path)
    parser.add_argument('--std-root', type=Path, default=ROOT)
    parser.add_argument('--evidence', required=True, type=Path)
    args = parser.parse_args()
    args.evidence.mkdir(parents=True, exist_ok=True)
    exported = subprocess.run(['node', str(ROOT / 'tests/package-contract-v1/emit.mjs'), *KINDS], cwd=ROOT, capture_output=True, text=True, check=True)
    cases = [json.loads(line) for line in exported.stdout.splitlines()]
    source = args.evidence / 'shared_contract_test.dew'
    source.write_text(generate(cases))
    env = {**os.environ, 'DEW_STD_ROOT': str(args.std_root.resolve()), 'DEW_INTERFACE_CACHE': '0', 'DEW_PROGRAM_CACHE': '0', 'DEW_CACHE_PACK': '0', 'DEW_CACHE_DIR': str(args.evidence / 'cache')}
    wasm = args.evidence / 'shared-contract.wasm'
    commands = [['compile', [str(args.compiler.resolve()), str(wasm), 'main', 'main', 'shared_contract_test.dew', str(source)]], ['run', ['node', '--no-liftoff', str(ROOT / 'tools/dew-test/run.mjs'), '--wasm', str(wasm), '--label', 'shared package contract']]]
    record = {'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(), 'case_ids': [case['id'] for case in cases], 'compiler_sha256': hashlib.sha256(args.compiler.read_bytes()).hexdigest(), 'std_sources': {str(path.relative_to(args.std_root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in (args.std_root / 'std').rglob('*.dew')}, 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'steps': []}
    for name, command in commands:
        start = time.monotonic()
        try:
            process = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, timeout=30)
            code, stdout, stderr = process.returncode, process.stdout, process.stderr
        except subprocess.TimeoutExpired as error:
            code, stdout, stderr = 124, error.stdout or b'', (error.stderr or b'') + b'\n30 second narrow-check limit exceeded\n'
        (args.evidence / f'{name}.stdout').write_bytes(stdout)
        (args.evidence / f'{name}.stderr').write_bytes(stderr)
        record['steps'].append({'name': name, 'command': command, 'exit': code, 'wall_seconds': time.monotonic() - start})
        (args.evidence / 'result.json').write_text(json.dumps(record, indent=2) + '\n')
        print(f'{name}: exit {code}; {len(cases)} shared cases')
        print(stdout.decode(errors='replace'), end='')
        print(stderr.decode(errors='replace'), end='', file=sys.stderr)
        if code:
            raise SystemExit(code)


if __name__ == '__main__':
    main()
