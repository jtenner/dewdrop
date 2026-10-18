#!/usr/bin/env python3
"""Measure native BLAKE3 allocation requests, excluding the shared input.

Run from the Dewdrop root. Build files stay in a temporary directory. The
baseline hash is read from BASELINE; the candidate is read from the workspace.
GNU ld wraps the normal MoonBit mimalloc entry points. This measures requested
allocation bytes, including object headers. It does not measure process RSS.
"""
import argparse
import hashlib
import json
import pathlib
import re
import subprocess
import tempfile
import time

BASELINE = "43fd2930435868228c7289fdfe6c4aa678b9d80b"
root = pathlib.Path.cwd()
source_path = "src/cache_binary/blake3.mbt"
old = subprocess.check_output(["git", "show", BASELINE + ":" + source_path], text=True)
parser = argparse.ArgumentParser()
parser.add_argument("--candidate-source", type=pathlib.Path, default=root / source_path)
args = parser.parse_args()
new = args.candidate_source.read_text()
old = re.sub(r"\bblake3", "baseline_blake3", old).replace("Blake3Output", "BaselineBlake3Output")
identity = {"baseline": BASELINE,
            "candidate_sha256": hashlib.sha256(new.encode()).hexdigest(),
            "baseline_renamed_sha256": hashlib.sha256(old.encode()).hexdigest()}

main = r'''
extern "c" fn probe_start() -> Unit = "probe_start"
extern "c" fn probe_stop(label : Int32) -> Unit = "probe_stop"
extern "c" fn timer_start() -> Unit = "timer_start"
extern "c" fn timer_stop(label : Int32) -> Unit = "timer_stop"
fn main {
  let buffer = Buffer(size_hint=1024 * 1024 + 16)
  for index in 0..<(1024 * 1024 + 16) {
    buffer.write_byte((index % 251).to_byte())
  }
  let input = buffer.to_bytes()
  let expected = baseline_blake3(input[0:1024 * 1024].to_owned())
  for round in 0..<7 {
    // Alternate order to expose warm-order effects. Source construction is
    // outside both measured ranges. Hold the digest through probe_stop.
    for index in 0..<2 {
      let kind = (round + index) % 2
      probe_start()
      let digest = if kind == 0 {
        baseline_blake3(input[0:1024 * 1024].to_owned())
      } else {
        blake3_range(input, 0, 1024 * 1024).unwrap()
      }
      probe_stop(kind)
      if digest != expected { abort("range digest differs from baseline") }
      println(digest[0])
    }
  }
  // Uninstrumented, one-call samples. Allocation wrappers only forward here.
  for round in 0..<21 {
    for index in 0..<2 {
      let kind = (round + index) % 2
      timer_start()
      let digest = if kind == 0 {
        baseline_blake3(input[0:1024 * 1024].to_owned())
      } else {
        blake3_range(input, 0, 1024 * 1024).unwrap()
      }
      timer_stop(kind)
      if digest != expected { abort("range digest differs from baseline") }
      println(digest[0])
    }
  }
}
'''

probe = r'''
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
static struct timespec started;
void timer_start(void) { clock_gettime(CLOCK_MONOTONIC, &started); }
void timer_stop(int32_t label) {
  struct timespec ended;
  clock_gettime(CLOCK_MONOTONIC, &ended);
  double ns = (ended.tv_sec - started.tv_sec) * 1e9 + (ended.tv_nsec - started.tv_nsec);
  printf("time_%s ns=%.0f\n", label ? "range" : "copy", ns);
}
#define CAPACITY (1u << 16)
static void *slots[CAPACITY];
static size_t sizes[CAPACITY];
static uint64_t calls, bytes, live, peak, largest;
static int active;
void *__real_mi_malloc(size_t size);
void __real_mi_free(void *ptr);
static size_t slot_for(void *ptr) {
  return (((uintptr_t)ptr >> 4) * UINT64_C(11400714819323198485)) & (CAPACITY - 1);
}
void *__wrap_mi_malloc(size_t size) {
  void *ptr = __real_mi_malloc(size);
  if (active && ptr) {
    size_t index = slot_for(ptr), first = CAPACITY;
    for (size_t n = 0; n < CAPACITY; n++, index = (index + 1) & (CAPACITY - 1)) {
      if (slots[index] == (void *)1 && first == CAPACITY) first = index;
      if (!slots[index]) {
        if (first != CAPACITY) index = first;
        slots[index] = ptr;
        sizes[index] = size;
        calls++;
        bytes += size;
        live += size;
        if (live > peak) peak = live;
        if (size > largest) largest = size;
        return ptr;
      }
    }
    fprintf(stderr, "allocation probe table overflow\n");
    exit(1);
  }
  return ptr;
}
void __wrap_mi_free(void *ptr) {
  if (active && ptr) {
    size_t index = slot_for(ptr);
    for (size_t n = 0; n < CAPACITY; n++, index = (index + 1) & (CAPACITY - 1)) {
      if (!slots[index]) break;
      if (slots[index] == ptr) {
        live -= sizes[index];
        slots[index] = (void *)1;
        break;
      }
    }
  }
  __real_mi_free(ptr);
}
void probe_start(void) {
  active = 0;
  memset(slots, 0, sizeof(slots));
  calls = bytes = live = peak = largest = 0;
  active = 1;
}
void probe_stop(int32_t label) {
  active = 0;
  printf("%s calls=%llu bytes=%llu peak_live_bytes=%llu end_live_bytes=%llu largest_request=%llu\n",
         label ? "range" : "copy", (unsigned long long)calls,
         (unsigned long long)bytes, (unsigned long long)peak,
         (unsigned long long)live, (unsigned long long)largest);
}
'''
with tempfile.TemporaryDirectory(prefix="dewdrop-range-allocation-") as tmp:
    work = pathlib.Path(tmp)
    (work / "moon.mod").write_text('name = "cache_range_probe"\nversion = "0.1.0"\n')
    (work / "moon.pkg").write_text('''import { "moonbitlang/core/buffer" }
pkgtype(kind: "executable")
options(
  "native-stub": [ "probe.c" ],
  link: { "native": { "cc": "gcc", "cc-flags": "-O2 -fwrapv -fno-strict-aliasing -Wl,--wrap=mi_malloc -Wl,--wrap=mi_free" } },
)
''')
    for name, data in [("baseline.mbt", old), ("candidate.mbt", new),
                       ("main.mbt", main), ("probe.c", probe)]:
        (work / name).write_text(data)
        identity[name + "_sha256"] = hashlib.sha256(data.encode()).hexdigest()
    print(json.dumps(identity, indent=2), flush=True)
    start = time.monotonic()
    subprocess.run(["moon", "build", "--release", "--target", "native"], cwd=work, check=True)
    print("build_seconds=%.6f" % (time.monotonic() - start), flush=True)
    exes = list((work / "_build/native/release/build").glob("*.exe"))
    if len(exes) != 1:
        raise RuntimeError("expected one built executable: " + str(exes))
    print("executable_sha256=" + hashlib.sha256(exes[0].read_bytes()).hexdigest(), flush=True)
    print("executable_bytes=" + str(exes[0].stat().st_size), flush=True)
    subprocess.run([str(exes[0])], check=True)
