# Loop transfers in transform guards

Baseline: `8c39bc4f5a`. Independent bytecode review found the Native tree VM
caught transfers around each arm body but not its guard. The normal resolver
enters a loop before its arms and guards; it evaluates the initial expression
before entering that loop. The new tests retain both rules.

Native now catches guard/body transfers together. A guard continue marks the
arm selected, updates the state, and starts the next iteration. Dew explicitly
handles guard flow before another arm can run, and stops walking arms after a
match. Initial-expression transfers still propagate to the outer control.

## Source controls and evidence

Artifacts are in `.tmp/transforms-v4/bytecode/`.

- `guards-native-red-3.log`: valid initial controls,2fail/1pass in11.762s.
  Both guard transfers escaped the function. Nested initial break passed.
- The first source drafts were parse failures; these are not execution evidence.
- A guard-only loop was rejected as nonexhaustive and is not a VM regression.
- `guards-native-exhaustive.log`: final Boolean/exhaustive cases3/3,12.621s.
- `guards-dew-old-exhaustive.log`: replay of exactly the old Dew handler with
  current source tests,1pass/2fail,15.869s. Pending flow reached literal equality
  in later arms and produced an unsupported-equality diagnostic.
- `guards-dew-exhaustive-green.log`: current Dew handler3/3,16.213s total;
  generation6.943s/link1.333s/run3.086s.

The Dew baseline and fixed run used the same saved Native generator and linker.
Only the selected Dew interpreter input changed for baseline replay. Generator
SHA256:b96d47e358adfa0d2e4f0e475770498fe8dacbdb9fdfa252e3aa7eb312713c9a.
LinkerSHA256:3e5c2c72ad5a392a7d1ce750c064a384cea0c88f6a1b93fae2f147e3ec4970b7.
The bytecode draft remains private and was not enabled for these checks.
No speed or heap improvement is claimed from these small functional controls.
