# Compile-time raw memory layout

`size_of<T>()`, `align_of<T>()`, and `field_offset<T>(index)` describe a
linear-memory encoding. They do not describe the allocation size or byte offsets
of a WasmGC object. No heap type, object header, pointer size, or GC field index
is used to answer these queries.

Supported values are the existing raw scalars and ordered tuples whose fields
are recursively supported. Nominal records, enums, references, functions, Type,
and Never are rejected. A tuple's runtime representation remains a GC value;
these queries neither move it into linear memory nor generate a serializer.
Code using raw loads and stores must explicitly follow the encoding below.

- Fields remain in source order. `field_offset` takes a constant, zero-based U32
  field index, including Unit fields.
- Each field starts at the next multiple of its natural alignment.
- Scalar size and alignment follow the existing raw scalar contract. Unit has
  size zero and alignment one; an empty tuple does too.
- Tuple alignment is the maximum field alignment, or one for an empty tuple.
- Tuple size includes tail padding to its alignment.
- All byte offsets and sizes must fit U32. Arithmetic overflow is a diagnostic,
  not a wrapped offset. A traversal limit is a separate diagnostic.

For `(U8, Unit, I64, (U16, U8))`, field offsets are `[0, 1, 8, 16]`, alignment is
8, and total size is 24. The nested tuple has size 4 and alignment 2. Unit still
has an index even though it does not add bytes.

Logical generic types remain pending until specialization. A known unsupported
field is an error. No raw tuple layout can be inferred from an `eqref` carrier.

Checks: 32 focused native query tests pass in 14.822 s. Both compilers pass the
same 39 execution cases, including generic forwarding of nested raw layouts.
Self-host hardening passes 187 tests, 29 exact invariant records, both host record
tests, and all execution/semantic probes in 20.387 s. The first cold release C
build took 90.025 s and is a performance defect. It also caught a new Dew syntax
error, which was corrected before the passing run.
