# Dew selected trait-call proof export

The full Dew transform suite reported 90 passing tests and one failure in
`generic_traits.dew`. The same source passed the Native transform VM. Evidence:
`.tmp/transforms-v3/frame-dew-tests.log`.

The source has two nominal record types, each with its own `Answer`
implementation. A generic `forward<t: Answer>` calls `read<t: Answer>`, which
calls `value.answer()`. The Dew VM rejected that call with
`checked call requires unsupported compile-time dispatch`.

## Cause

The ordinary selected-instance planner had already proved the concrete method.
`self_host_resolve_guarded_calls` selects the implementation with checked trait
witnesses. Its replacement expression has both a concrete `PlannedDirectCall`
and `SelectedBasicCallTarget` for the exact method declaration.

The older `module_.inferred.call_targets` table still has the generic
`BoundTraitBasicCallTarget`. That table is deliberately shared by instance
copies, as shown in `semantic_compile_time_type_copies.dew`. It must not be
updated for one instance.

`ct_collect_module_calls` read this older table through
`ct_source_call_targets`, so it exported an unsupported bound target. The normal
planner did not add a separate specialized-call override: the selected expression
already named the concrete nongeneric method, so its target did not differ from
the call recipe's target. The final checked proof existed but did not reach the
VM.

The root-owned fix is to prefer the final selected expression's
`SelectedBasicCallTarget` during call, binary-operator, and index proof export.
Other cases retain the existing fallback table. This keeps instance selection
private and preserves exact declaration identity. No source-name, module-path,
or Wasm-carrier rule is needed.

## Ruled-out hypothesis and limits

No evidence-enum equality fault was found for this source. The logical converter
already maps nominal and primitive types to their nominal and primitive evidence
forms. Simple record constructors remove an empty type-argument wrapper. The
trait helper's generic competitor checks must remain unchanged.

The existing full source regression is the failing test for this correction.
The root agent owns the exporter edit and compiler validation. This review ran
no compiler, Moon, or runtime command and changed no semantic helper or VM source.

## Fixed result

After the exporter correction, the full Dew lane passed all 91 tests.
Generation took 7.102 seconds, linking 1.415 seconds, and execution 7.713
seconds. The trait fixture now checks each result separately, so swapped
implementations cannot pass through an unchanged sum.
