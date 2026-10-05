#!/usr/bin/env python3
"""Run declarative ABI performance and WAT architecture assertions."""

from __future__ import annotations

import argparse
import json
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CASES = ROOT / "tests" / "architecture-cases.json"
PERFORMANCE_BUDGETS = ROOT / "tests" / "performance-budgets"


def wat_tokens(text: str) -> list[str]:
    """Tokenize the WAT surface needed by architecture instruction counts."""
    tokens: list[str] = []
    index = 0
    while index < len(text):
        if text[index].isspace():
            index += 1
            continue
        if text.startswith(";;", index):
            newline = text.find("\n", index + 2)
            index = len(text) if newline < 0 else newline + 1
            continue
        if text.startswith("(;", index):
            depth = 1
            index += 2
            while index < len(text) and depth > 0:
                if text.startswith("(;", index):
                    depth += 1
                    index += 2
                elif text.startswith(";)", index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
            continue
        if text[index] in "()":
            tokens.append(text[index])
            index += 1
            continue
        if text[index] == '"':
            start = index
            index += 1
            while index < len(text):
                if text[index] == "\\":
                    index += 2
                elif text[index] == '"':
                    index += 1
                    break
                else:
                    index += 1
            tokens.append(text[start:index])
            continue
        start = index
        while (
            index < len(text)
            and not text[index].isspace()
            and text[index] not in '()"'
            and not text.startswith(";;", index)
            and not text.startswith("(;", index)
        ):
            index += 1
        if start == index:
            index += 1
        else:
            tokens.append(text[start:index])
    return tokens


def wat_token_count(tokens: list[str], pattern: str) -> int:
    """Count a WAT token sequence in an already-tokenized module."""
    selected = wat_tokens(pattern)
    if not selected:
        return 0
    # Existing budgets use the trailing space to mean direct call opcodes,
    # including tail calls, while deliberately excluding call_ref.
    if pattern == "call ":
        return sum(token in {"call", "return_call"} for token in tokens)
    width = len(selected)
    return sum(
        tokens[index : index + width] == selected
        for index in range(len(tokens) - width + 1)
    )


def wat_count(text: str, pattern: str) -> int:
    """Count exact WAT token sequences, excluding comments and string contents."""
    return wat_token_count(wat_tokens(text), pattern)


def validate_performance_budget_references(cases: list[dict[str, object]]) -> None:
    available = {
        path.relative_to(ROOT).as_posix()
        for path in PERFORMANCE_BUDGETS.glob("*.json")
    }
    referenced = [str(case.get("budget", "")) for case in cases]
    counts = Counter(referenced)
    missing = sorted(available - counts.keys())
    unknown = sorted(counts.keys() - available)
    duplicated = sorted(path for path, count in counts.items() if count != 1)
    failures = []
    if missing:
        failures.append(f"unreferenced performance budgets: {', '.join(missing)}")
    if unknown:
        failures.append(f"unknown performance budgets: {', '.join(unknown)}")
    if duplicated:
        failures.append(f"performance budgets not referenced once: {', '.join(duplicated)}")
    if failures:
        raise SystemExit("performance budget reference check failed:\n" + "\n".join(failures))


def consumer_result_error(output: str, expected: object) -> str | None:
    if not isinstance(expected, dict):
        return "expected consumer result must be a JSON object"
    try:
        actual = json.loads(output)
    except json.JSONDecodeError as error:
        return f"consumer returned invalid JSON: {error}"
    if actual != expected:
        return f"expected {expected!r}, got {actual!r}"
    return None


def run_performance(cases: list[dict[str, object]]) -> None:
    for case in cases:
        label = str(case["label"])
        command = [
            "node",
            "tools/wasm-metrics.mjs",
            str(case["wat"]),
            str(case["artifact"]),
            str(case["budget"]),
        ]
        result = subprocess.run(command, cwd=ROOT, check=False, capture_output=True)
        if result.returncode != 0:
            raise SystemExit(
                f"{label} performance case failed:\n{result.stderr.decode(errors='replace')}"
            )
        report = ROOT / str(case["report"])
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_bytes(result.stdout)
        consumer = case.get("consumer")
        if isinstance(consumer, dict):
            invocation = consumer.get("invocation", [])
            if not isinstance(invocation, list):
                raise SystemExit(f"{label} consumer invocation must be an array")
            consumed = subprocess.run(
                [
                    "node",
                    "tools/dew-wasm-consumer.mjs",
                    str(case["artifact"]),
                    str(consumer["artifact"]),
                    *(str(value) for value in invocation),
                ],
                cwd=ROOT,
                check=False,
                capture_output=True,
            )
            output = consumed.stdout.decode(errors="replace")
            result_error = consumer_result_error(output, consumer.get("expected"))
            if consumed.returncode != 0 or result_error is not None:
                raise SystemExit(
                    f"{label} consumer case failed:\n"
                    f"{consumed.stderr.decode(errors='replace')}{output}"
                    f"{'' if result_error is None else result_error + chr(10)}"
                )
        print(f"checked architecture performance case: {label}")


def run_wat(cases: list[dict[str, object]]) -> None:
    for case in cases:
        label = str(case["label"])
        text = (ROOT / str(case["wat"])).read_text(encoding="utf-8")
        for pattern in case.get("forbidden", []):
            if str(pattern) in text:
                raise SystemExit(f"{label} retained forbidden WAT: {pattern}")
        for pattern in case.get("required", []):
            if str(pattern) not in text:
                raise SystemExit(f"{label} lost required WAT: {pattern}")
        counts = case.get("counts", {})
        if not isinstance(counts, dict):
            raise SystemExit(f"{label} WAT counts must be an object")
        tokens = wat_tokens(text)
        for pattern, expected in counts.items():
            actual = wat_token_count(tokens, pattern)
            if actual != expected:
                raise SystemExit(
                    f"{label} WAT count changed for {pattern}: "
                    f"expected {expected}, got {actual}"
                )
        print(f"checked architecture WAT case: {label}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--performance", action="store_true")
    parser.add_argument("--wat", action="store_true")
    args = parser.parse_args()
    if not args.performance and not args.wat:
        args.performance = args.wat = True
    data = json.loads(CASES.read_text(encoding="utf-8"))
    validate_performance_budget_references(data["performanceCases"])
    if args.performance:
        run_performance(data["performanceCases"])
    if args.wat:
        run_wat(data["watCases"])


if __name__ == "__main__":
    main()
