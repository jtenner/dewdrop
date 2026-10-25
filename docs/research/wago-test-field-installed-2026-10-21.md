# Installed type-test and first-field improvement

Ready PR1012: https://github.com/wago-org/wago/pull/1012 . Pushed3f405bb9790aeb51464babcb17f34aac1d22ea26, picked as073b2f61880e965d3c33ba83e32f72e9391a845d on dewdrop/local-gc-perf-20261020. The older public exact-flag hunk conflicts with the existing combined canonical-identity fastpath; the resolved AMD64 source matches fully qualified a4126816db82e6b1d7cd257517d7214ab3875131 exactly. All tracked src and fixture bytes match that qualification; the unrelated dirty ARM64 call.go remains unchanged.

The same install includes PR1011 follow-ups5298ccb84/f78eb48ae (now metadata-rewritten e764c09a5/542e0b529): unknown deferred trap PCs and four remaining cold-pin restorations. Their local picks4105e6a16/a0be7510f remain equivalent; metadata audit found identical trees and binary patches across36 watched processed entries. No duplicate pick was needed.

Full matched run medians36.6536→36.1912s(-1.2615%), not4s parity.5196admissions in1443functions. Complete samples and limits are in the Wago PR research note. Full root normal154.837s and checked141.925s, checked benchmark27.480s and focused checked24.679s pass; final public normal/checked/profile pass. Daybreak Blue reviewed the code before publication. No V8 compile ran.

Manager/runtime builds6.737/6.695s. Selected local-gc-073b2f618, manager /home/dev/.local/bin/wago, runtime /home/dev/.local/share/wago/versions/local-gc-073b2f618/standard/normal/wago-runtime. All66 final PATH/version/build/runtime checks pass. The first installed CLI harness expected unsigned4294967294 for an i32 signed output; CLI correctly prints-2. Preserve that initial harness failure, then recheck the signed value and finish the remaining checks. No runtime code correction was needed. Manifest and all final/raw results are in data/wago-test-field-installed-2026-10-21/.

Astra continues research on bounded read-only reuse and complete native interval invalidation. Claude supplies an independent interval-cache audit. Neither hypothesis is installed. Reviews use GPT-6 Sol with explicit daybreak_blue; saved runtime turn contexts confirm both fields.
