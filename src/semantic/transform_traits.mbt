///|
pub struct CompileTimeTraitMethod {
  requirement : DeclId
  slot : Int32
  module_index : Int32
  file : FileId
  offset : UInt64
  frame : String
}

///|
pub struct CompileTimeTraitObject {
  module_index : Int32
  file : FileId
  offset : UInt64
  frame : String
  trait_declaration : DeclId
  methods : Array[CompileTimeTraitMethod]
}

///|
struct CompileTimeTraitIndex {
  dictionaries : Map[(DeclId, String), PlannedWasmTraitDictionary]
  functions : Map[String, PlannedWasmFunctionFragment]
  layouts : Map[DeclId, HirSpan]
}

///|
fn compile_time_trait_objects(
  program : CollectedProgram,
  mi : Int32,
  lowering : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  frame : String,
  expressions : Array[Int32]?,
  targets : Map[DeclId, (Int32, FileId, UInt64)],
  method_frames : Map[(ModuleId, ExprId, String, DeclId), (DeclId, String)],
  indexes : Map[ModuleId, CompileTimeTraitIndex],
  output : Array[CompileTimeTraitObject],
) -> Unit {
  let source = program.modules[mi]
  let count = match expressions {
    Some(values) => values.length()
    None => lowering.expressions.length()
  }
  let mut has_coercion = false
  for index in 0..<count {
    let ei = match expressions {
      Some(values) => values[index]
      None => index
    }
    if lowering.expressions[ei].trait_object_coercion
      is SelectedInferredTraitObjectCoercion(_, _, _) {
      has_coercion = true
      break
    }
  }
  guard has_coercion else { return }
  let lookup = indexes.get_or_init(lowering.module_id, fn() {
    let dictionaries : Map[(DeclId, String), PlannedWasmTraitDictionary] = {}
    for dictionary in fragments.trait_dictionaries {
      dictionaries[(dictionary.trait_declaration, dictionary.evidence_key)] = dictionary
    }
    let functions : Map[String, PlannedWasmFunctionFragment] = {}
    for function_ in fragments.functions {
      if function_.specialization_abi_key != "" {
        functions[function_.specialization_abi_key] = function_
      }
    }
    let layouts : Map[DeclId, HirSpan] = {}
    for layout in fragments.trait_layouts {
      layouts[layout.trait_declaration] = layout.methods
    }
    { dictionaries, functions, layouts, }
  })
  let selected_function = lookup.functions.get(frame)
  for index in 0..<count {
    let ei = match expressions {
      Some(values) => values[index]
      None => index
    }
    let (trait_, evidence) = match
      lowering.expressions[ei].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, evidence, _) =>
        (trait_, evidence)
      _ => continue
    }
    // Logical transform instances need no physical dictionary. Its carrier
    // planner can omit a query-sensitive method, or merge distinct logical
    // receivers. Use the exact targets saved by the normal instance planner.
    if lookup.layouts.get(trait_) is Some(layout) &&
      layout.length > 0 &&
      method_frames.contains(
        (
          lowering.module_id,
          ei,
          frame,
          fragments.trait_layout_methods[layout.start],
        ),
      ) {
      let methods : Array[CompileTimeTraitMethod] = []
      for slot in 0..<layout.length {
        let requirement = fragments.trait_layout_methods[layout.start + slot]
        guard method_frames.get((lowering.module_id, ei, frame, requirement))
          is Some((declaration, method_frame)) else {
          break
        }
        guard targets.get(declaration) is Some((module_index, file, offset)) else {
          break
        }
        methods.push({
          requirement,
          slot,
          module_index,
          file,
          offset,
          frame: method_frame,
        })
      }
      if methods.length() == layout.length {
        output.push({
          module_index: mi,
          file: source.expression_files[ei],
          offset: source.expressions[ei].offset(),
          frame,
          trait_declaration: trait_,
          methods,
        })
        continue
      }
    }
    let mut key = wasmgc_trait_evidence_key(lowering, evidence)
    if selected_function is Some(function_) {
      if program_resolved_trait_evidence_identity(
          lowering,
          fragments,
          function_.specialization_shapes,
          function_.specialization_evidence,
          evidence,
        )
        is Some((_, resolved_key)) {
        key = resolved_key
      }
    }
    if lookup.dictionaries.get((trait_, key)) is Some(dictionary) {
      let methods : Array[CompileTimeTraitMethod] = []
      for
        index in dictionary.methods.start..<(dictionary.methods.start +
        dictionary.methods.length) {
        let method_ = fragments.trait_methods[index]
        guard targets.get(method_.implementation_method)
          is Some((module_index, file, offset)) else {
          continue
        }
        methods.push({
          requirement: method_.requirement,
          slot: method_.slot,
          module_index,
          file,
          offset,
          frame: method_frames
          .get((lowering.module_id, ei, frame, method_.requirement))
          .map(value => value.1)
          .unwrap_or(method_.implementation_specialization_abi_key),
        })
      }
      if methods.length() == dictionary.methods.length {
        output.push({
          module_index: mi,
          file: source.expression_files[ei],
          offset: source.expressions[ei].offset(),
          frame,
          trait_declaration: trait_,
          methods,
        })
      }
    }
  }
}
