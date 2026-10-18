"""Check fresh compiler C flow errors with its matching bootstrap A request."""
from pathlib import Path
import hashlib, importlib.util, json, subprocess, sys, tempfile, time
repo = Path.cwd()
compiler, template = [Path(p).resolve(strict=True) for p in sys.argv[1:3]]
work = Path(sys.argv[3]).resolve() if len(sys.argv) > 3 else Path(tempfile.mkdtemp(prefix="dewdrop-flow-gate-"))
work.mkdir(parents=True, exist_ok=True)
source = Path(__file__).resolve().parent
reader_path = source.parent / "language-improvement-implementation-2026-10-18/feature-probe/rewrite-request.py"
spec = importlib.util.spec_from_file_location("request_codec", reader_path)
codec = importlib.util.module_from_spec(spec)
spec.loader.exec_module(codec)
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
request = codec.decode(template.read_bytes())
records = []
def run(command, cwd):
    start = time.monotonic()
    result = subprocess.run([str(x) for x in command], cwd=cwd, capture_output=True, text=True, timeout=28)
    record = dict(command=[str(x) for x in command], cwd=str(cwd), wall_seconds=time.monotonic()-start,
                  status=result.returncode, stdout=result.stdout, stderr=result.stderr)
    records.append(record)
    return record
exported = work / "compiler-c-memory.wasm"
export = run(["mise", "exec", "wasm-tools@1.262.0", "--", "python3", repo / "tools/export-wasm-memory.py", compiler, exported], repo)
assert export["status"] == 0, export
for name in ["missing-bool", "generic-guarded"]:
    fixture = source / (name + ".dew")
    payload = fixture.read_bytes()
    output = work / (name + ".wasm")
    output.unlink(missing_ok=True)
    modules = [(n,f) for n,f in request["modules"] if n.startswith("dew.std.")]
    modules.append(("probe.flow", [(fixture.name, payload)]))
    encoded = b"".join(codec.u32(x) for x in [request["magic"],1,1,0,1])
    encoded += codec.string(output.name)+codec.string("probe.flow")+codec.u32(len(modules))
    for module, files in modules:
        encoded += codec.string(module)+codec.u32(len(files))
        for path, data in files:
            encoded += codec.string(path)+codec.blob(data)
    encoded += request["tail"]
    assert codec.decode(encoded)["tail"] == request["tail"]
    path = work / (name + "-request.bin")
    path.write_bytes(encoded)
    record = run(["node", "--stack-size=65500", repo / "tools/run-dew-facet.mjs", exported, path], work)
    record.update(case=name, source_sha256=digest(fixture), request_sha256=digest(path), output_exists=output.exists())
    record["flow_error_kind"] = "non-exhaustive match" if "source flow error: non-exhaustive match" in record["stderr"] else None
    record["passed"] = record["status"] == 1 and "source flow error: non-exhaustive match" in record["stderr"] and not output.exists()
report = dict(compiler=str(compiler), compiler_sha256=digest(compiler), template_sha256=digest(template),
              host_compiler_sha256=digest(exported), harness_sha256=digest(Path(__file__)),
              request_codec_sha256=digest(reader_path),
              source_sha256={str(p):digest(repo/p) for p in [Path("self_host/compiler/semantic_body_flow.dew"), Path("self_host/compiler/semantic_program_lowering.dew")]},
              results=records,
              passed=len([r for r in records if "case" in r]) == 2 and all(r["passed"] for r in records if "case" in r))
(work / "validation.json").write_text(json.dumps(report, indent=2)+"\n")
(source / "validation.json").write_text(json.dumps(report, indent=2)+"\n")
print(json.dumps(report, indent=2))
raise SystemExit(0 if report["passed"] else 1)
