///|
fn short_inference_check(source : Bytes, library? : Bytes = b"") -> Unit raise {
  let (program, frozen, _, names, inferred) = imported_semantic_program(
    source, library,
  )
  for module_ in program.modules {
    assert_eq(module_.diagnostics, [])
  }
  assert_eq(frozen.import_diagnostics, [])
  for interface_ in frozen.interfaces {
    assert_eq(interface_.resolved_types.diagnostics, [])
  }
  assert_eq(names.diagnostics, [])
  assert_eq(inferred.diagnostics, [])
}

///|
test "short inference exact imports retain constructor identities" {
  let source = b"import app.library as @lib\nfn make() -> @lib.Reply<I32> {\n  Ok(7i32)\n}\nfn read(value: @lib.Reply<I32>) -> I32 {\n  match value {\n    Ok(item) => item\n    Empty => 0i32\n  }\n}\n"
  let library = b"pub enum Reply<t> {\n  Ok(t)\n  Empty\n}\n"
  short_inference_check(source, library~)
  let (_, frozen, _, _, inferred) = imported_semantic_program(source, library)
  let variant = frozen.interfaces[1].variants[0].variant
  assert_true(
    inferred.expression_selections.any(fn(selection) {
      selection is VariantConstructionSelection(id, _) && id == variant
    }),
  )
  assert_true(
    inferred.pattern_constructors.any(fn(selection) {
      selection is VariantInferredPatternConstructor(id, _) && id == variant
    }),
  )
}

///|
test "short inference nested constructors receive field context" {
  short_inference_check(
    b"enum Small {\n  Item(I32)\n}\nenum Wide {\n  Item(I64)\n}\nenum Box<t> {\n  Wrap(t)\n}\nstruct Holder {\n  value: Box<Small>\n}\nfn make() -> Holder {\n  {\n    value: Wrap(Item(7i32))\n  }\n}\n",
  )
}

///|
test "short inference payload types select an owner" {
  short_inference_check(
    b"enum Small {\n  Item(I32)\n}\nenum Wide {\n  Item(I64)\n}\nfn run() -> Unit {\n  let value = Item(7i64)\n  ()\n}\n",
  )
}

///|
test "short inference struct patterns use imported subject types" {
  short_inference_check(
    b"import app.library as @lib\nfn read(value: @lib.Pair<I32>) -> I32 {\n  match value {\n    {\n      second: _\n      first: item\n    } => item\n  }\n}\n",
    library=b"pub struct Pair<t> {\n  first: t\n  second: Bool\n}\n",
  )
}

///|
test "short inference method results reach patterns and constructors" {
  short_inference_check(
    b"enum Small {\n  Item(I32)\n}\nenum Wide {\n  Item(I64)\n}\nstruct Source {}\nimpl Source {\n  fn read(self) -> Small {\n    Item(7i32)\n  }\n  fn accept(self, value: Small) -> Unit {}\n}\nfn run(source: Source) -> I32 {\n  source.accept(Item(8i32))\n  match source.read() {\n    Item(value) => value\n  }\n}\n",
  )
}

///|
test "short inference constructor callbacks receive a function type" {
  short_inference_check(
    b"enum Reply<t> {\n  Ok(t)\n}\nfn apply(f: fn(I32) -> Reply<I32>) -> Reply<I32> {\n  f(7i32)\n}\nfn run() -> Reply<I32> {\n  apply(Ok)\n}\n",
  )
}

///|
test "short inference static factories use the expected owner" {
  short_inference_check(
    b"struct First {}\nstruct Second {}\nimpl First {\n  fn empty() -> First {\n    First::{}\n  }\n}\nimpl Second {\n  fn empty() -> Second {\n    Second::{}\n  }\n}\nfn run() -> First {\n  empty()\n}\n",
  )
}

///|
test "short inference ambiguous constructors remain diagnostic" {
  let (_, resolved, names, inferred) = call_test_module(
    887UL, b"enum First {\n  Item(I32)\n}\nenum Second {\n  Item(I32)\n}\nfn run() -> Unit {\n  let value = Item(7i32)\n  ()\n}\n",
  )
  assert_eq(resolved.diagnostics, [])
  assert_eq(names.diagnostics, [])
  assert_true(
    inferred.diagnostics.any(fn(diagnostic) {
      diagnostic is AmbiguousVariantValue(_, _, _, _, 2, _)
    }),
  )
}

///|
test "short inference exact imports disambiguate equal local type and case names" {
  short_inference_check(
    b"import app.library as @lib\nenum Reply<t> {\n  Ok(t)\n}\nfn run() -> @lib.Reply<I32> {\n  Ok(7i32)\n}\n",
    library=b"pub enum Reply<t> {\n  Ok(t)\n}\n",
  )
}

///|
test "short inference transparent aliases supply imported owners" {
  short_inference_check(
    b"import app.library as @lib\ntype Alias<t> = @lib.Reply<t>\nfn run() -> Alias<I32> {\n  Ok(7i32)\n}\n",
    library=b"pub enum Reply<t> {\n  Ok(t)\n}\n",
  )
}

///|
test "short inference lexical functions retain priority" {
  short_inference_check(
    b"import app.library as @lib\nfn Ok(value: I32) -> I32 {\n  value\n}\nfn run() -> I32 {\n  Ok(7i32)\n}\n",
    library=b"pub enum Reply<t> {\n  Ok(t)\n}\n",
  )
}

///|
test "short inference named fields select a case owner" {
  short_inference_check(
    b"enum First {\n  Entry {\n    first: I32\n  }\n}\nenum Second {\n  Entry {\n    second: Bool\n  }\n}\nfn run() -> Unit {\n  let value = Entry::{\n    first: 7i32\n  }\n}\n",
    library=b"",
  )
}

///|
test "short inference assignment supplies delayed constructor context" {
  short_inference_check(
    b"enum First {\n  Item(I32)\n}\nenum Second {\n  Item(I32)\n}\nfn run() -> Unit {\n  let mut value = Item(7i32)\n  value = Second::Item(8i32)\n}\n",
    library=b"",
  )
}

///|
test "short inference imported static factory uses expected owner" {
  short_inference_check(
    b"import app.library as @lib\nfn run() -> @lib.Cell {\n  empty()\n}\n",
    library=b"pub struct Cell {}\nimpl Cell {\n  fn empty() -> Cell {\n    Cell::{}\n  }\n}\n",
  )
}

///|
test "short inference generic callback signatures select among equal names" {
  short_inference_check(
    b"import app.library as @lib\nenum Reply<t> {\n  Ok(t)\n}\nfn callback() -> fn(I32) -> @lib.Reply<I32> {\n  Ok\n}\n",
    library=b"pub enum Reply<t> {\n  Ok(t)\n}\n",
  )
}

///|
test "short inference constructor cache evidence changes with consumer demand" {
  let (_, without, _, _, _) = imported_semantic_program(
    b"import app.library as @lib\nfn run() -> @lib.Reply<I32> {\n  Ok(7i32)\n}\n",
    b"pub enum Reply<t> {\n  Ok(t)\n}\n",
  )
  let (program, with_, _, _, inferred) = imported_semantic_program(
    b"import app.library as @lib\nfn callback() -> fn(I32) -> @lib.Reply<I32> {\n  Ok\n}\n",
    b"pub enum Reply<t> {\n  Ok(t)\n}\n",
  )
  assert_eq(inferred.diagnostics, [])
  assert_false(
    program.modules[1].constructor_interface_matches(without.interfaces[1]),
  )
  assert_true(
    program.modules[1].constructor_interface_matches(with_.interfaces[1]),
  )
  let cached = Array::make(program.modules.length(), None)
  cached[1] = Some(without.interfaces[1])
  let refreshed = freeze_program_interfaces_with_cached(program, cached)
  assert_true(
    program.modules[1].constructor_interface_matches(refreshed.interfaces[1]),
  )
  let wrapper = with_.interfaces[1].variants[0].constructor.unwrap()
  assert_true(
    program.modules[1].declaration(wrapper)
    is Some(TopLevelReference({ visibility: ModuleVisible, .. })),
  )
  assert_true(
    with_.interfaces[1].callables.any(fn(callable) {
      callable.declaration == wrapper
    }),
  )
}

///|
test "short inference enum cases keep their meaning beside trait names" {
  short_inference_check(
    b"trait Add {}\nenum Operator {\n  Add\n  Other\n}\nfn read(value: Operator) -> Bool {\n  value is Add\n}\n",
  )
}

///|
test "short inference struct values in match arms use the expected owner" {
  short_inference_check(
    b"struct Cell {\n  value: I32\n}\nfn make(flag: Bool) -> Cell {\n  match flag {\n    true => ({\n      value: 1i32\n    })\n    false => ({\n      value: 2i32\n    })\n  }\n}\n",
  )
}

///|
test "short inference index results reach alternative patterns" {
  short_inference_check(
    b"open dew.std.array\nenum First {\n Item(U32)\n Other(U32)\n}\nenum Second {\n Item(U32)\n}\nstruct Holder {\n values: Array<First>\n}\nfn read(holder: Holder, index: U32) -> U32 {\n let node = holder.values[index]\n match node {\n  Item(value), Other(value) => value\n }\n}\n",
  )
}

///|
test "short inference index operators wait for method pattern payloads" {
  short_inference_check(
    b"open dew.std.array\nenum Reply<t> {\n Some(t)\n}\nstruct Source {\n values: Array<U32>\n}\nimpl Source {\n fn read(self) -> Reply<Array<U32>> {\n  Some(self.values)\n }\n}\nfn run(source: Source) -> U32 {\n match source.read() {\n  Some(values) => values[0u32]\n }\n}\n",
  )
}
