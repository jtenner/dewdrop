# Compile-time transform feature list

This is the full status list for source transforms. A checked item has working
code and a test. The current work closes normal source-call gaps and expands the
syntax API. The last section records larger language changes; those are not
claims about the current interpreter.

## Source execution

- [x] Local transform declarations.
- [x] Public transform declarations.
- [x] Imported transform annotations.
- [x] Private helper functions within their own module.
- [x] Imported public helper functions.
- [x] Checked entry parameter types.
- [x] Checked entry result types.
- [x] Entry types through aliases.
- [x] Transform results as `FnNode`.
- [x] Transform errors as `Result`.
- [x] Stacked transforms in source order.
- [x] Exact checked targets for ordinary calls.
- [x] Instance methods with `self`.
- [x] Static methods.
- [x] Imported inherent methods.
- [x] Concrete trait methods.
- [x] Methods with the same name on different types.
- [x] Generic source helpers without dynamic trait dispatch.
- [x] Immutable module constants during interpretation.
- [x] Imported public constants through checked references.
- [x] Constant initialization cached within one transform application.
- [x] Constant state reset between transform applications.
- [x] Receiver evaluation exactly once.
- [x] Argument evaluation in source order.
- [x] Source bodies for custom binary operators.
- [x] Source bodies for indexed reads.
- [x] Mutable record fields.
- [x] Changes visible through record aliases.
- [x] Closures as local values.
- [x] Captured immutable locals.
- [x] Captured mutable locals.
- [x] Higher-order source helpers.
- [x] Return from a closure without returning from its caller.
- [x] Function values that return another function.
- [x] Checked enum constructor calls and unit values.
- [x] Inferred scalar results for builtin function values.
- [x] Generic names cannot override checked scalar types.
- [x] Return in a final call argument keeps its flow.

## Collections and primitive operations

- [x] Signed integer literals.
- [x] Unsigned integer literals.
- [x] Boolean literals.
- [x] UTF-8 string literals.
- [x] Array literals.
- [x] Tuple literals and tuple destructuring.
- [x] Integer arithmetic with selected primitive proofs.
- [x] Signed division traps.
- [x] Signed remainder edge cases.
- [x] Local mutable variables.
- [x] Branches and short-circuit Boolean expressions.
- [x] Functional loops, break, and continue.
- [x] Checked enum constructor patterns.
- [x] Checked local binding patterns.
- [x] Selected Wasm scalar intrinsics.
- [x] Checked integer conversion helpers.
- [x] Bounded Wasm array allocation.
- [x] Wasm array length, get, and set.
- [x] Overlap-safe Wasm array copy.
- [x] Standard Array construction through its Dew source.
- [x] Standard Array length and capacity.
- [x] Standard Array push and pop.
- [x] Standard Array get and set.
- [x] Standard Array clear.
- [x] Array literal values usable by source methods.
- [x] Typed default raw-array slots through generic helpers.
- [x] Deferred scalar defaults inside generic enum payloads.
- [x] Checked prefix result types for deferred scalar defaults.
- [x] Float results cannot enter integer execution through unsafe casts.
- [x] Checked scalar types at local and record-field reads.
- [x] Scalar literal patterns across generic cast results.
- [x] Scalar and Boolean values from generic tuple destructuring.
- [x] Float carrier checks inside generic records and options.
- [x] Record patterns and payload field patterns.
- [x] Explicit bounds errors during interpretation.

## Function and expression API

- [x] `node.with_body(body)`.
- [x] `node.prepend(expression)`.
- [x] `node.append(expression)`.
- [x] `node.wrap(callee)`.
- [x] `node.returning(expression)`.
- [x] Method to generate a call from an expression.
- [x] Method to generate a binary expression.
- [x] Method to generate a field access.
- [x] Method to generate an index access.
- [x] Method to generate a method call.
- [x] Method to generate a return.
- [x] Method to generate an immutable binding.
- [x] Method to generate a mutable binding.
- [x] Method to generate an assignment.
- [x] Builder for a unit value.
- [x] Builder for a 64-bit signed literal.
- [x] Builder for a 64-bit unsigned literal.
- [x] Builder for an array expression.
- [x] Builder for a tuple expression.
- [x] Builder for a qualified path.
- [x] Builder for a prefix expression.
- [x] Validated field names.
- [x] Validated method names.
- [x] Validated qualified paths.
- [x] Compatibility with existing free builder functions.
- [x] Original body available as source syntax.
- [x] Existing function signatures preserved.
- [x] Fresh local name supplied by the context.
- [x] Original file, line, column, function, and module context.
- [x] Parameter and result source text in the context.
- [x] Structured parameter nodes.
- [x] Structured type nodes.
- [x] Structured generic parameter names and bounds.
- [x] UTF-8 string literal patterns.
- [x] New function and type declarations from transforms.
- [x] Generated implementations and methods.
- [x] Transform imports in generated code.

## Safety, tools, and checks

- [x] Normal source checking before interpretation.
- [x] Normal generated-code checking after interpretation.
- [x] One generated function per replacement.
- [x] Host function calls rejected.
- [x] Input UTF-8 checked.
- [x] Output size limit.
- [x] Recursion depth limit.
- [x] Work limit.
- [x] Estimated allocation-work limit.
- [x] No second Wasm instance.
- [x] Native compiler implementation.
- [x] Dew compiler implementation.
- [x] Real compile-request tests.
- [x] Public build and test command examples.
- [x] Public examples use the method API.
- [x] Imported method regression in both compilers.
- [x] Closure and operator regression in both compilers.
- [x] Collection regression in both compilers.
- [x] Builder regression in both compilers.
- [x] Rejected unsupported call cannot fall back to a same-named helper.
- [x] Updated self-host fixed-point check.

## Larger language and tool work

These need a further language or execution design. They remain open.

- [x] Parsed expression trees for every original function body.
- [x] Typed expression reflection through `ctx.type_of`, with original check errors.
- [ ] Signature changes and call-site repair.
- [x] Syntax quotation and expression splicing.
- [x] Automatic name hygiene for quote-local `$name` bindings.
- [x] Parsed syntax arguments on annotations.
- [ ] Complete default/null reference behavior for raw arrays.
- [ ] Generic trait evidence during interpretation.
- [ ] Dynamic trait objects.
- [x] First-class overloaded builtin references with a checked target.
- [x] Scalar floating-point execution with Wasm rounding and traps.
- [ ] Full text and SIMD execution.
- [ ] Full compile-time type-query API.
- [x] Stable declaration ranges and original function sites for generated source.
- [x] Expanded-source JSON for editor views.
- [x] Per-transform work and allocation reports.
- [ ] Identical resource accounting across compiler implementations.
- [ ] Persistent transform-result cache with dependency tracking.
- [ ] Compact bytecode backend.
- [ ] Parallel independent transform execution.
- [x] Pinned native Wago request check and CI job (host speed issue remains).
