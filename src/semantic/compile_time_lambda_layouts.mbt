///|
pub struct CompileTimeLambdaLayout {
  closure_types : Array[Int]
  capture_fields : Array[Int]
  capture_parameters : Array[Int]
} derive(Eq, Debug)

///|
// Physical types precede signatures in the module-local type space. Appending
// a group must move every signature reference together, before link freeze.
fn rebase_fragment_signatures(
  fragments : PlannedModuleWasmGCFragments,
  old_base : Int,
) -> Unit {
  let delta = fragments.physical_types.length() - old_base
  guard delta >= 0 else { abort("LNK-502 physical type arena shrank") }
  if delta == 0 {
    return
  }
  for index, function_ in fragments.functions {
    if function_.signature_type_index >= old_base {
      fragments.functions[index] = {
        ..function_,
        signature_type_index: function_.signature_type_index + delta,
      }
    }
  }
  for index, signature in fragments.function_types {
    if signature.signature_type_index >= old_base {
      fragments.function_types[index] = {
        ..signature,
        signature_type_index: signature.signature_type_index + delta,
      }
    }
  }
  for
    table in [
      fragments.function_type_by_resolved,
      fragments.closure_entry_type_by_resolved,
      fragments.erased_closure_direct_type_by_resolved,
      fragments.erased_closure_entry_type_by_resolved,
      fragments.lambda_entry_signature_indices,
      fragments.trait_method_signature_indices,
    ] {
    for index, value in table {
      if value >= old_base {
        table[index] = value + delta
      }
    }
  }
  for index, value in fragments.function_value_types {
    if value is WasmFunctionRefValue(type_) && type_ >= old_base {
      fragments.function_value_types[index] = WasmFunctionRefValue(
        type_ + delta,
      )
    }
  }
  for index, field in fragments.fields {
    if field.storage is WasmFunctionRefStorage(type_) && type_ >= old_base {
      fragments.fields[index] = {
        ..field,
        storage: WasmFunctionRefStorage(type_ + delta),
      }
    }
  }
  for index, method in fragments.trait_methods {
    if method.signature_type_index >= old_base {
      fragments.trait_methods[index] = {
        ..method,
        signature_type_index: method.signature_type_index + delta,
      }
    }
  }
}

///|
fn append_compile_time_physical_type(
  fragments : PlannedModuleWasmGCFragments,
  kind : PlannedWasmPhysicalTypeKind,
  fields : HirSpan,
  offset : UInt64,
) -> Int {
  let type_index = fragments.physical_types.length()
  fragments.physical_types.push({
    kind,
    type_index,
    group_index: fragments.type_groups.length(),
    fields,
    offset,
  })
  fragments.type_groups.push({
    types: { start: type_index, length: 1, },
    first_type_index: type_index,
  })
  type_index
}

///|
fn prepare_compile_time_lambda_layouts(
  template : PlannedModuleLowering,
  instance : PlannedModuleLowering,
  fragments : PlannedModuleWasmGCFragments,
  owner : PlannedWasmFunctionFragment,
  root : BodyId,
) -> Unit {
  let mut has_lambda = false
  for lambda in instance.lambdas {
    if lambda.root_body == root && !lambda.elided {
      has_lambda = true
      break
    }
  }
  if !has_lambda {
    return
  }
  let layout = {
    closure_types: fragments.lambda_closure_type_indices.copy(),
    capture_fields: fragments.lambda_capture_field_indices.copy(),
    capture_parameters: fragments.lambda_capture_parameter_indices.copy(),
  }
  let generics = program_callable_generic_parameters(
    instance.functions.callable_of(owner.declaration).unwrap(),
  )
  let old_base = fragments.physical_types.length()
  // Mutable capture cells are allocated by the owning local. Its frozen shape
  // must agree with the selected closure field and the lambda's accesses.
  for index, local_ in instance.locals {
    let owned = if local_.lambda >= 0 {
      instance.lambdas[local_.lambda].root_body == root &&
      !instance.lambdas[local_.lambda].elided
    } else {
      local_.body == root
    }
    if owned && !local_.elided {
      let shape = program_resolve_specialized_shape(
        instance,
        generics,
        fragments.specialization_shapes,
        owner.specialization_shapes,
        local_.type_,
        local_.shape,
      )
      instance.locals[index] = { ..local_, shape, }
    }
  }
  for index, lambda in instance.lambdas {
    if lambda.root_body != root || lambda.elided {
      continue
    }
    let mut changed = false
    for offset in 0..<lambda.captures.length {
      let global = lambda.captures.start + offset
      let capture = instance.captures[global]
      let shape = program_resolve_specialized_shape(
        instance,
        generics,
        fragments.specialization_shapes,
        owner.specialization_shapes,
        capture.type_,
        capture.shape,
      )
      guard !(shape is GenericPlannedValueShape ||
        shape is ErrorPlannedValueShape) else {
        abort("SPC-301 lambda capture requires concrete evidence")
      }
      changed = changed || shape != template.captures[global].shape
      instance.captures[global] = { ..capture, shape, }
      if capture.mutable_ {
        let slot = wasmgc_capture_cell_slot(shape)
        if slot >= 0 && fragments.capture_cell_type_indices[slot] < 0 {
          let field_start = fragments.fields.length()
          fragments.fields.push({
            role: WasmCaptureCellValueField(slot),
            physical_index: 0,
            storage: wasmgc_capture_cell_storage(slot),
            mutable_: true,
            offset: capture.offset,
          })
          fragments.capture_cell_type_indices[slot] = append_compile_time_physical_type(
            fragments,
            PlannedWasmCaptureCellType(slot),
            { start: field_start, length: 1, },
            capture.offset,
          )
        }
      }
    }
    if lambda.directized {
      let mut parameter = 0
      for offset in 0..<lambda.captures.length {
        let global = lambda.captures.start + offset
        let capture = instance.captures[global]
        match wasmgc_capture_storage(capture.shape, capture.mutable_) {
          Some(_) => {
            layout.capture_parameters[global] = parameter
            parameter += 1
          }
          None => layout.capture_parameters[global] = -1
        }
      }
    } else if changed {
      let start = fragments.fields.length()
      fragments.fields.push({
        role: WasmClosureEntryField,
        physical_index: 0,
        storage: WasmNullableFunctionRefStorage,
        mutable_: false,
        offset: 0UL,
      })
      for offset in 0..<lambda.captures.length {
        let global = lambda.captures.start + offset
        let capture = instance.captures[global]
        match wasmgc_capture_storage(capture.shape, capture.mutable_) {
          Some(storage) => {
            let physical_index = fragments.fields.length() - start
            layout.capture_fields[global] = physical_index
            fragments.fields.push({
              role: WasmLambdaCaptureField(index, offset),
              physical_index,
              storage,
              mutable_: false,
              offset: capture.offset,
            })
          }
          None => layout.capture_fields[global] = -1
        }
      }
      layout.closure_types[index] = append_compile_time_physical_type(
        fragments,
        PlannedWasmLambdaClosureType(index),
        { start, length: fragments.fields.length() - start, },
        0UL,
      )
    }
  }
  rebase_fragment_signatures(fragments, old_base)
  fragments.specialized_lambda_layouts[owner.specialization_abi_key] = layout
}
