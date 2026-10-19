///|
pub struct CompileTimeFrameCall {
  frame : String
  target_frame : String
  call : CompileTimeCall
}

///|
fn transform_frame_kind(
  module_ : PlannedModuleLowering,
  original_inferred : InferredModuleBodies,
  type_ : BodyTypeId,
  reference : Bool,
) -> String {
  // Read the checked instance arena. The original inferred arena still has
  // generic parameters and cannot prove a concrete result carrier.
  let inferred : InferredModuleBodies = {
    ..original_inferred,
    types: module_.types,
    type_arguments: module_.type_arguments,
  }
  transform_scalar_kind(
    module_.resolved_types,
    module_.resolved_type_arguments,
    inferred,
    type_,
    reference,
    raw_arrays=module_.raw_array_declarations,
  )
}

///|
pub fn compile_time_frame_calls(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  roots : Array[DeclId],
) -> Result[Array[CompileTimeFrameCall], String] {
  let context = match lowering.compile_time {
    Some(value) => value
    None => return Ok([])
  }
  let context = {
    ..context,
    logical: context.logical.copy(),
    sensitive: context.sensitive.copy(),
    instances: Map([]),
    query_constants: context.query_constants.copy(),
  }
  let lowering = { ..lowering, compile_time: Some(context), }
  let declaration_roots : Map[DeclId, Bool] = {}
  for declaration in roots {
    declaration_roots[declaration] = true
  }
  // This lowering is private to transform validation. Ask the normal planner
  // for logical instances of every selected generic helper, including helpers
  // whose runtime carriers alone would otherwise be sufficient.
  for module_ in lowering.modules {
    for callable in module_.functions.callables {
      if program_callable_generic_parameters(callable).length > 0 {
        context.logical[callable.declaration] = true
      }
    }
  }
  context.transform_instance_budget = 1_048_576
  context.transform_instance_exhausted = false
  let selected = plan_program_wasmgc_fragments_for_root(
    analyzed,
    lowering,
    WasmGCPlanningOptions::subtype_families(),
    -1,
    Array::make(lowering.modules.length(), None),
    fn(_, _) { () },
    declaration_roots=Some(declaration_roots),
  )
  context.transform_instance_budget = -1
  if context.transform_instance_exhausted {
    return Err("transform generic instance limit exceeded")
  }
  for _, instance in context.instances {
    if !instance.module_.diagnostics.is_empty() {
      return Err(
        "transform selected generic body failed checking: " +
        @debug.to_string(instance.module_.diagnostics[0]),
      )
    }
  }
  let templates = compile_time_calls(program, analyzed, lowering)
  let by_site : Map[(Int32, FileId, UInt64, Bool), CompileTimeCall] = {}
  for call in templates {
    by_site[(call.module_index, call.file, call.offset, call.reference)] = call
  }
  let targets : Map[DeclId, (Int32, FileId, UInt64)] = {}
  for mi, source in program.modules {
    for declaration in source.declarations {
      targets[declaration.id] = (
        mi,
        source.declaration_files[semantic_id_local(declaration.id)],
        declaration.offset,
      )
    }
    for method in source.methods {
      targets[method.id] = (
        mi,
        source.declaration_files[semantic_id_local(method.id)],
        method.offset,
      )
    }
  }
  let intrinsics = program_fold_operator_intrinsics(lowering.modules)
  let result = []
  // Export all reads and folded queries owned by an instance, not the rest of
  // its copied module. Multiple instances must not overwrite each other.
  for frame, instance in context.instances {
    let mi = lowering.index.declaration_owner(instance.declaration).unwrap()
    let source = program.modules[mi]
    let module_ = instance.module_
    let mut selected_body : PlannedBodyLowering? = None
    for body in module_.bodies {
      if body.declaration == instance.declaration {
        selected_body = Some(body)
        break
      }
    }
    guard selected_body is Some(body) else { continue }
    for ei in compile_time_owned_expressions(module_, body) {
      let original = source.expressions[ei]
      let file = source.expression_files[ei]
      let offset = original.offset()
      if instance.constants.get(ei) is Some(constant) {
        result.push({
          frame,
          target_frame: "",
          call: {
            reference: false,
            constant: Some(constant),
            function_identity: None,
            module_index: mi,
            file,
            offset,
            target_module: -6,
            target_file: file,
            target_offset: 0UL,
            result_kind: "",
            constructor_key: "",
          },
        })
        continue
      }
      for reference in [false, true] {
        if by_site.get((mi, file, offset, reference)) is Some(call) {
          result.push({
            frame,
            target_frame: "",
            call: {
              ..call,
              result_kind: transform_frame_kind(
                module_,
                analyzed.modules[mi].inferred,
                module_.expressions[ei].type_,
                reference,
              ),
            },
          })
        }
      }
      let planned = module_.expressions[ei]
      let prototype : CompileTimeCall = {
        reference: false,
        constant: None,
        function_identity: None,
        module_index: mi,
        file,
        offset,
        target_module: -1,
        target_file: file,
        target_offset: 0UL,
        result_kind: "",
        constructor_key: "",
      }
      match original {
        HirNameExpr(_, _) | HirFieldExpr(_, _, _) | HirPrefixExpr(_, _, _) => {
          let kind = transform_frame_kind(
            module_,
            analyzed.modules[mi].inferred,
            planned.type_,
            false,
          )
          if kind != "" && !kind.has_prefix("array:") {
            result.push({
              frame,
              target_frame: "",
              call: { ..prototype, target_module: -5, result_kind: kind, },
            })
          }
        }
        _ => ()
      }
      if original is HirBinaryExpr(_, _, _, _) {
        let opcode = match planned.kind {
          PlannedBinaryExpression(_, _, _) => b"primitive"
          PlannedOperatorCall(target, _, _, _, arguments) if arguments.length ==
            0 => intrinsics.get(target).unwrap_or(b"")
          _ => b""
        }
        if opcode.length() > 0 {
          result.push({
            frame,
            target_frame: "",
            call: {
              ..prototype,
              target_module: -7,
              result_kind: @utf8.decode_lossy(opcode),
            },
          })
        }
      }
      let reference = original is HirNameExpr(_, _) ||
        original is HirFieldExpr(_, _, _) ||
        original is HirQualifiedExpr(_, _, _)
      let selected_target = if reference {
        match planned.kind {
          PlannedFunctionReference(target, _) => Some(target)
          _ => None
        }
      } else if original is HirCallExpr(_, _, _) ||
        original is HirBinaryExpr(_, _, _, _) ||
        original is HirIndexExpr(_, _, _) {
        program_call_target_and_arguments(planned).map(value => value.0)
      } else {
        None
      }
      if selected_target is Some(target) &&
        targets.get(target) is Some((target_module, target_file, target_offset)) {
        result.push({
          frame,
          target_frame: "",
          call: {
            ..prototype,
            reference,
            target_module,
            target_file,
            target_offset,
            function_identity: transform_function_identity(
              lowering.modules[target_module],
              target,
            ),
            result_kind: transform_frame_kind(
              module_,
              analyzed.modules[mi].inferred,
              planned.type_,
              reference,
            ),
          },
        })
      }
    }
  }
  // These are the exact targets selected by the normal generic/trait planner.
  for call in selected.specialized_calls {
    let mi = lowering.index.module_lookup
      .get(semantic_id_module(call.caller_body))
      .unwrap()
    let source = program.modules[mi]
    let ei = call.expression
    let original = source.expressions[ei]
    let file = source.expression_files[ei]
    let offset = original.offset()
    let reference = !(original is HirCallExpr(_, _, _) ||
      original is HirBinaryExpr(_, _, _, _) ||
      original is HirIndexExpr(_, _, _))
    guard targets.get(call.target)
      is Some((target_module, target_file, target_offset)) else {
      continue
    }
    let module_ = program_function_lowering(
      lowering,
      mi,
      call.caller_specialization_abi_key,
    )
    result.push({
      frame: call.caller_specialization_abi_key,
      target_frame: call.target_specialization_abi_key,
      call: {
        reference,
        constant: None,
        function_identity: transform_function_identity(
          lowering.modules[target_module],
          call.target,
        ),
        module_index: mi,
        file,
        offset,
        target_module,
        target_file,
        target_offset,
        result_kind: transform_frame_kind(
          module_,
          analyzed.modules[mi].inferred,
          module_.expressions[ei].type_,
          reference,
        ),
        constructor_key: "",
      },
    })
  }
  Ok(result)
}
