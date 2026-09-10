#!/usr/bin/env python3
"""Keep compact, reviewable experiment evidence and paired speed summaries."""

import argparse
from collections import Counter
import json
import math
from pathlib import Path
import random
import statistics

from runner import ROOT, write_json


def geometric_mean(values):
    return math.exp(statistics.mean(math.log(value) for value in values))


def paired_interval(ratios):
    rng = random.Random(20260910)
    estimates = sorted(geometric_mean(rng.choices(ratios, k=len(ratios))) for _ in range(10000))
    return [estimates[249], estimates[9749]]


def compact(value):
    if isinstance(value, list):
        return [compact(item) for item in value]
    if not isinstance(value, dict):
        return value
    result = {}
    for key, item in value.items():
        if key == "commands":
            result[key] = []
            for command in item:
                row = {"program": Path(command["command"][0]).name,
                       "seconds": round(command["seconds"], 6),
                       "returncode": command["returncode"]}
                if command.get("returncode") != 0 or command.get("timeout"):
                    row.update({k: command[k] for k in ["command", "stdout", "stderr", "timeout"]})
                if command.get("performance_bug"):
                    row["performance_bug"] = True
                result[key].append(row)
        else:
            result[key] = compact(item)
    return result


def benchmark_summary(report):
    result = {"workloads": {}, "aggregate": {}}
    aggregate = {}
    for work in report["workloads"]:
        rows = {}
        result["workloads"][work["name"]] = rows
        stock = work["variants"].get("O4s", {})
        if "median_ns" not in stock:
            rows["error"] = "no valid O4s measurement"
            continue
        for name, variant in work["variants"].items():
            if "median_ns" not in variant:
                rows[name] = {"status": variant["status"]}
                continue
            ratios = [trial / reference for trial, reference in
                      zip(variant["round_medians_ns"], stock["round_medians_ns"], strict=True)]
            rows[name] = {"median_ns": variant["median_ns"], "bytes": variant["bytes"],
                          "non_custom_bytes": variant["non_custom_bytes"],
                          "code_section_bytes": variant["code_section_bytes"],
                          "size_ratio_to_O4s": variant["bytes"] / stock["bytes"],
                          "non_custom_ratio_to_O4s": variant["non_custom_bytes"] / stock["non_custom_bytes"],
                          "code_ratio_to_O4s": variant["code_section_bytes"] / stock["code_section_bytes"],
                          "time_ratio_to_O4s": geometric_mean(ratios),
                          "time_ratio_95pct_bootstrap": paired_interval(ratios)}
            aggregate.setdefault(name, []).append(rows[name])
    for name, rows in aggregate.items():
        result["aggregate"][name] = {"measured_workloads": len(rows),
                                     "total_workloads": len(report["workloads"]),
                                     "time_ratio_to_O4s": geometric_mean([r["time_ratio_to_O4s"] for r in rows]),
                                     "size_ratio_to_O4s": geometric_mean([r["size_ratio_to_O4s"] for r in rows]),
                                     "non_custom_ratio_to_O4s": geometric_mean([r["non_custom_ratio_to_O4s"] for r in rows]),
                                     "code_ratio_to_O4s": geometric_mean([r["code_ratio_to_O4s"] for r in rows]),
                                     "total_bytes": sum(r["bytes"] for r in rows),
                                     "total_non_custom_bytes": sum(r["non_custom_bytes"] for r in rows)}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("reports", nargs="+", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    summaries = {}
    for path in args.reports:
        report = json.loads(path.read_text())
        name = path.parent.name
        result = compact(report)
        if "workloads" in report:
            summary = benchmark_summary(report)
        else:
            cases = report.get("fixtures", report.get("cases", []))
            summary = {"total": len(cases), "status": dict(Counter(r["status"] for r in cases)),
                       "pipelines": {name: dict(Counter(r["pipelines"][name]["status"] for r in cases if name in r["pipelines"]))
                                     for name in report.get("pipelines", {})}}
        summaries[name] = summary
        # Portable paths keep the checked-in evidence usable from another checkout.
        portable = json.loads(json.dumps(result).replace(str(ROOT), "$DEWDROP"))
        args.output.mkdir(parents=True, exist_ok=True)
        case_key = next((key for key in ["fixtures", "cases", "workloads"] if key in portable), None)
        if case_key:
            cases = portable.pop(case_key)
            lines = [json.dumps({"metadata": portable}, sort_keys=True, separators=(",", ":"))]
            row_key = "workload" if case_key == "workloads" else "case"
            lines.extend(json.dumps({row_key: row}, sort_keys=True, separators=(",", ":")) for row in cases)
            (args.output / f"{name}.jsonl").write_text("\n".join(lines) + "\n")
        else:
            write_json(args.output / f"{name}.json", portable)
    write_json(args.output / "summary.json", summaries)
    print(json.dumps(summaries, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
