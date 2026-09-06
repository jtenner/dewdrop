///|
// Physical instruction tags. Contracts are derived after interface thawing.
fn raw_array_opcode(name : Bytes) -> Int {
  match name {
    b"array_new" | b"array.new" => 0
    b"array_len" | b"array.len" => 1
    b"array_get" | b"array.get" => 2
    b"array_set" | b"array.set" => 3
    b"array.new_default" => 4
    b"array.copy" => 5
    _ => -1
  }
}

///|
priv struct RawArrayContracts {
  declarations : Map[DeclId, Bool]
  operations : Map[DeclId, Int]
  diagnostics : Map[ModuleId, Array[LoweringPlanDiagnostic]]
}

///|
fn raw_array_type_argument(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
) -> (DeclId, ResolvedTypeId)? {
  guard type_ >= 0 && type_ < resolved.types.length() else { return None }
  match resolved.types[type_] {
    AppliedType(base, arguments) if arguments.length == 1 &&
      program_specialization_span_is_valid(
        arguments,
        resolved.type_arguments.length(),
      ) &&
      base >= 0 &&
      base < resolved.types.length() =>
      match resolved.types[base] {
        NominalType(declaration) =>
          Some((declaration, resolved.type_arguments[arguments.start]))
        _ => None
      }
    _ => None
  }
}

///|
fn raw_array_contract_owner(
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  callable : PlannedCallable,
  operation : Int,
) -> Result[DeclId, String] {
  let count = match operation {
    0 | 2 => 2
    1 | 4 => 1
    3 => 3
    5 => 5
    _ => return Err("unknown raw array instruction")
  }
  guard !callable.has_receiver && callable.parameters.length == count else {
    return Err(
      "raw array instruction has the wrong parameter count or a receiver",
    )
  }
  guard program_specialization_span_is_valid(
    callable.parameters,
    functions.parameters.length(),
  ) else {
    abort("ARN-101 raw array callable parameters are outside their arena")
  }
  let parameters : Array[ResolvedTypeId] = []
  for index in 0..<count {
    parameters.push(
      functions.parameters[callable.parameters.start + index].type_,
    )
  }
  let array_type = if operation == 0 || operation == 4 {
    callable.result_type
  } else {
    parameters[0]
  }
  let (owner, element) = match raw_array_type_argument(resolved, array_type) {
    Some(value) => value
    None =>
      return Err(
        "raw array instruction needs an applied nominal array type with one element argument",
      )
  }
  let u32_type = resolved.primitive(U32Type)
  let unit_type = resolved.primitive(UnitType)
  let valid = match operation {
    0 => parameters[0] == u32_type && parameters[1] == element
    1 => callable.result_type == u32_type
    2 => parameters[1] == u32_type && callable.result_type == element
    3 =>
      parameters[1] == u32_type &&
      parameters[2] == element &&
      callable.result_type == unit_type
    4 => parameters[0] == u32_type
    5 =>
      parameters[1] == u32_type &&
      parameters[2] == array_type &&
      parameters[3] == u32_type &&
      parameters[4] == u32_type &&
      callable.result_type == unit_type
    _ => false
  }
  if valid {
    Ok(owner)
  } else {
    Err(
      "raw array instruction signature does not match its element and scalar operand types",
    )
  }
}

///|
fn bind_program_raw_array_contracts(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
) -> RawArrayContracts {
  let contracts : RawArrayContracts = {
    declarations: {},
    operations: {},
    diagnostics: {},
  }
  let modules : Map[ModuleId, Int] = {}
  for index, module_ in program.modules {
    modules[module_.module_id] = index
  }
  for module_index, collected in program.modules {
    let resolved = analyzed.frozen.interfaces[module_index].resolved_types
    let functions = plan_module_functions(collected, resolved)
    let diagnostics : Array[LoweringPlanDiagnostic] = []
    for callable in functions.callables {
      let operation = match callable.kind {
        PlannedBuiltinCallable(name) => raw_array_opcode(name)
        _ => -1
      }
      if operation < 0 {
        continue
      }
      let owner = match
        raw_array_contract_owner(resolved, functions, callable, operation) {
        Ok(value) => value
        Err(message) => {
          diagnostics.push(
            InvalidRawArrayContract(
              callable.declaration,
              message,
              callable.offset,
            ),
          )
          continue
        }
      }
      let owner_index = match modules.get(semantic_id_module(owner)) {
        Some(value) => value
        None => {
          diagnostics.push(
            InvalidRawArrayContract(
              callable.declaration,
              "raw array owner module is absent",
              callable.offset,
            ),
          )
          continue
        }
      }
      let owner_module = program.modules[owner_index]
      let local = semantic_id_local(owner)
      let empty_nominal = local >= 0 &&
        local < owner_module.declarations.length() &&
        owner_module.declarations[local].kind == StructDecl &&
        owner_module.generic_parameters_of(owner).length == 1 &&
        !owner_module.fields.any(fn(field) { field.declaration == owner })
      if !empty_nominal {
        diagnostics.push(
          InvalidRawArrayContract(
            callable.declaration,
            "raw array owner must be an empty struct with one element parameter",
            callable.offset,
          ),
        )
        continue
      }
      contracts.declarations[owner] = true
      contracts.operations[callable.declaration] = operation
    }
    contracts.diagnostics[collected.module_id] = diagnostics
  }
  contracts
}

///|
fn plan_raw_array_call(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  expression : ExprId,
  arguments : HirSpan,
  operation : Int,
) -> PlannedExpressionKind {
  let children = collected.expression_children
  let count = match operation {
    0 | 2 => 2
    1 | 4 => 1
    3 => 3
    5 => 5
    _ => abort("SPC-301 invalid bound raw array opcode")
  }
  guard arguments.length == count &&
    program_specialization_span_is_valid(arguments, children.length()) else {
    abort("ABI-703 raw array call arguments do not match the declared contract")
  }
  let first = children[arguments.start]
  match operation {
    0 => {
      let item = children[arguments.start + 1]
      PlannedFixedArrayMake(
        first,
        item,
        planned_value_shape(resolved, inferred, inferred.expression_types[item]),
      )
    }
    1 => PlannedFixedArrayLength(first, RefPlannedValueShape)
    2 =>
      PlannedFixedArrayGetUnchecked(
        first,
        children[arguments.start + 1],
        planned_value_shape(
          resolved,
          inferred,
          inferred.expression_types[expression],
        ),
      )
    3 => {
      let item = children[arguments.start + 2]
      PlannedFixedArraySetUnchecked(
        first,
        children[arguments.start + 1],
        item,
        planned_value_shape(resolved, inferred, inferred.expression_types[item]),
      )
    }
    4 => {
      let element = planned_array_element_type(resolved, inferred, expression)
      PlannedRawArrayNewDefault(
        first,
        element,
        planned_value_shape(resolved, inferred, element),
      )
    }
    5 => {
      let element = planned_array_element_type(resolved, inferred, first)
      PlannedRawArrayCopy(
        first,
        children[arguments.start + 1],
        children[arguments.start + 2],
        children[arguments.start + 3],
        children[arguments.start + 4],
        element,
        planned_value_shape(resolved, inferred, element),
      )
    }
    _ => abort("SPC-301 invalid bound raw array opcode")
  }
}
