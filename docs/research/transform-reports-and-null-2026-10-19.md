# Transform reports and nullable defaults

Each completed annotation adds one report in source order. The report identifies
its module, original file, function, transform, byte offset, work used, and
estimated allocation work. Each annotation starts a fresh budget. The final
shared renderer and later compiler phases are outside these counters. No clock
or host call is available to the interpreted source.

Native compiler clients read `options.transform_reports`; expanded-source JSON
includes the same records. Dew clients can call `ct_expand_checked_with_reports`
and receive the expanded manifest and records across source-pool rounds. Failed
annotations keep normal errors; they do not produce a completed report. This is
not a claim of identical accounting or host peak-memory measurement.

Null has its own VM value. The checked one-instruction `ref_null`, `ref_is_null`,
and `ref_as_non_null` operations use it. Raw nullable foreign-reference slots
read as null. Non-null foreign-reference default reads fail before use. Integers,
Booleans, scalar floats, and vectors retain distinct zero defaults. Generic
scalar defaults still wait for concrete checked type evidence.

Checks so far: native report test 1/1 in 1.218 seconds; expanded-source report
test 1/1 in 9.422 seconds; native execution examples 4/4 in 12.545 seconds,
including a nullable raw-array example and a rejected non-null default. The
current Dew direct module passes the report and null tests. The public null
request also passes through checked source-pool expansion. Final integration
and JSON output checks will be recorded after the current test lane.
