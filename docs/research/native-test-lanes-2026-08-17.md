# Native test lanes

## Problem

The repository root is a two-module Moon workspace. Dewdrop needs the local
`starshine-mb/` member because Starshine is not published. Moon therefore treats
an unfiltered `moon test --target native` as a request to test both modules.

The native test outline on 2026-08-17 contained 11,635 default tests:

- 1,021 Dewdrop tests;
- 10,614 Starshine tests;
- 6,939 of the Starshine tests were in the optimizer pass package.

Moon workspaces do not have a default-member setting. Removing Starshine from
`moon.work` would also remove Dewdrop's local Starshine dependency.

## Test commands

Routine Dewdrop work uses:

```sh
tools/test-native.sh
```

Large compiler stress tests use:

```sh
tools/test-stress-native.sh
```

Complete compiler and backend integration cases use:

```sh
tools/test-integration-native.sh
```

The full pinned Starshine suite uses:

```sh
tools/test-starshine-native.sh
```

`tools/check.sh --quick` uses the routine native lane. The full check also runs
the native integration and stress lanes before the end-to-end checks.

## Stress policy

The explicit stress lane owns tests that construct 512 or 1,024 compiler
objects to prove iterative behavior and stable work ordering. Each test keeps a
descriptive `#skip` marker in its source. The stress command uses
`--include-skipped`, so failures remain visible when that lane runs.

The frozen-interface decoder keeps sampled truncation and mutation checks in
the integration lane. The old every-byte truncation sweep copied and decoded
every prefix. It was removed because it repeated the lower binary-reader
coverage with work proportional to the square of the encoded interface size.

## Integration policy

The integration lane owns tests that compile or link complete programs, the
standard runtime surface, or broad optimizer plans. These tests remain in their
owning packages and use descriptive `#skip` markers. The integration command
uses `--include-skipped` for the selected files.

The integration command runs one selected file at a time. The combined semantic
runner did not finish within two minutes, while each selected file completed.
The file-by-file lane also prints steady progress and bounds live test data.

## Measured result

On the native debug target after a warm build cache:

- the routine lane passed 712 tests in 37.249 seconds;
- the integration lane passed 262 tests in 99.126 seconds;
- the original unfiltered workspace outline contained 11,635 tests.

The slowest single default case was the frozen-interface corruption test. It
copied and decoded every truncated prefix of a large interface. The integration
case now samples structural positions and deterministic mutations.
