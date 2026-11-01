#!/usr/bin/env python3
"""Replay all eight full baseline diffs in memory; never write a fixture.
Run from the repository root. The base is the Mission A starting commit.
"""
import gzip
import hashlib
import json
import re
import subprocess
from pathlib import Path

BASE = 'b9fcc8ea'
DATA = Path(__file__).resolve().parent
CONFIG = {
    'binary-heap-runtime': (66, 1, {34: 33}, 35, 1),
    'show-collections-runtime': (137, 1, {92: 79}, 93, 1),
    'show-derived-runtime': (82, 2, {64: 54, 65: 61}, 66, 2),
    'derive-debug-runtime': (87, 1, {68: 46}, 69, 1),
}


def replay(lines, old):
    result, position, index, hunks = [], 0, 2, 0
    while index < len(lines):
        match = re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@', lines[index])
        assert match, lines[index]
        start, old_count, new_count = int(match[1]) - 1, int(match[2] or 1), int(match[4] or 1)
        result.extend(old[position:start])
        position = start
        index += 1
        consumed = produced = 0
        while consumed < old_count or produced < new_count:
            line = lines[index]
            index += 1
            if line[0] in ' -':
                assert old[position] == line[1:], (position, line)
                position += 1
                consumed += 1
            if line[0] in ' +':
                result.append(line[1:])
                produced += 1
        hunks += 1
    result.extend(old[position:])
    return ''.join(result), hunks


def functions(text):
    return {int(m[1]): m[0] for m in re.finditer(r'^  \(func \(;(\d+);\).*?(?=^  \(func|^\)$)', text, re.M | re.S)}


def mapped_body_check(stem, old, new):
    cut, shift, redirects, fcut, fshift = CONFIG[stem]
    def function(index):
        return redirects.get(index, index - fshift if index >= fcut else index)
    def type_(index):
        return index - shift if index >= cut + shift else index
    def convert(body):
        body = re.sub(r'\(;(\d+);\)', lambda m: f'(;{function(int(m[1]))};)', body, count=1)
        body = re.sub(r'(\bcall |\bref.func )(\d+)', lambda m: m[1] + str(function(int(m[2]))), body)
        return re.sub(r'(\(type |\(ref |\(ref null |\bstruct.new |\bstruct.get |\barray.new_fixed )(\d+)', lambda m: m[1] + str(type_(int(m[2]))), body)
    before, after = functions(old), functions(new)
    for index, body in before.items():
        if index not in redirects:
            assert convert(body) == after[function(index)], (stem, index)
    for index, target in redirects.items():
        # Removed forwarding bodies are identical to retained bodies. The
        # receiver ABI may be more general; inspect the header in the full diff.
        assert convert(before[index]).split('\n', 1)[1] == after[target].split('\n', 1)[1], (stem, index, target)
    return {'retained_bodies_exact_after_index_map': len(before) - len(redirects),
            'removed_body_redirects': redirects}


for path in sorted(DATA.glob('*.diff.gz')):
    diff = gzip.decompress(path.read_bytes()).decode()
    lines = diff.splitlines(True)
    fixture = lines[0][4:].strip()
    old = subprocess.check_output(['git', 'show', f'{BASE}:{fixture}']).decode()
    new, hunks = replay(lines, old.splitlines(True))
    result = {'fixture': fixture, 'hunks': hunks,
              'old_lines': len(old.splitlines()), 'new_lines': len(new.splitlines()),
              'full_diff_sha256': hashlib.sha256(diff.encode()).hexdigest(),
              'candidate_sha256': hashlib.sha256(new.encode()).hexdigest(),
              'working_expected_matches_candidate': Path(fixture).read_text() == new}
    if Path(fixture).stem in CONFIG:
        result.update(mapped_body_check(Path(fixture).stem, old, new))
    for label, text in [('old', old), ('new', new)]:
        # Full custom records are retained, including every escaped payload byte.
        facts = text.splitlines()[1]
        result[label + '_facts_line_sha256'] = hashlib.sha256(facts.encode()).hexdigest()
        result[label + '_facts_line_chars'] = len(facts)
    print(json.dumps(result, sort_keys=True))
