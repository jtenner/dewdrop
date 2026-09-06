///|
pub enum StarshineProgramBinaryEmissionError {
  StarshineProgramCodeError(StarshineCodeEmissionError)
  StarshineProgramValidationError(@validate.ValidationError)
  StarshineProgramMappedValidationError(
    @validate.ValidationError,
    @semantic.DeclId,
    @semantic.BodyId,
    Bytes,
    String
  )
  StarshineProgramEncodingError(@binary.EncodeError)
} derive(Debug)

///|
pub enum StarshineBinaryEmissionError {
  StarshineCodeError(StarshineCodeEmissionError)
  StarshineValidationError(@validate.ValidationError)
  StarshineEncodingError(@binary.EncodeError)
} derive(Debug)

///|
pub enum StarshineCodeEmissionError {
  MissingBody(@semantic.BodyId)
  MissingFunction(@semantic.DeclId)
  SignatureOnlyCall(@semantic.DeclId)
  InvalidLocal(@semantic.BodyId, @semantic.LocalId)
  UnsupportedExpression(@semantic.BodyId, @semantic.ExprId)
  UnsupportedBuiltin(Bytes)
  InvalidBuiltinSignature(
    Bytes,
    Array[@semantic.PlannedWasmValueType],
    Array[@semantic.PlannedWasmValueType]
  )
  InvalidFunctionBody(@semantic.BodyId)
  ProgramLinkDiagnostics(Int)
} derive(Eq, Debug)

///|
priv struct StarshineGenericSpecialization {
  generic_parameters : @semantic.CallableGenericParameters
  shapes : Array[@semantic.PlannedValueShape]
  specialization_shapes : @semantic.HirSpan
  specialization_evidence : @semantic.HirSpan
  specialization_abi_key : String
}

///|
priv struct StarshineFieldLocation {
  type_index : Int
  field_index : Int
  storage : @semantic.PlannedWasmStorageType
}

///|
priv struct StarshineProgramAdapterHelper {
  adapter_function : Int
  module_index : Int
  declaration : @semantic.DeclId
  actual_arguments : Array[@semantic.ResolvedTypeId]
  to_erased : Bool
  signature_type_index : Int
  function_index : Int
}

///|
priv struct StarshineProgramCallbackWrapper {
  adapter_function : Int
  module_index : Int
  function_type : @semantic.ResolvedTypeId
  owner_arguments : Array[@semantic.ResolvedTypeId]
  to_erased : Bool
  parameter_types : Array[@semantic.ResolvedTypeId]
  result_type : @semantic.ResolvedTypeId
  source_parameter_codes : Array[Int]
  source_result_code : Int
  target_parameter_codes : Array[Int]
  target_result_code : Int
  source_entry_type : Int
  source_direct_type : Int
  target_entry_type : Int
  target_direct_type : Int
  wrapper_type_index : Int
  function_index : Int
}

///|
priv struct StarshineProgramEvidenceClosure {
  reference_index : Int
  module_index : Int
  entry_type_index : Int
  closure_type_index : Int
  function_index : Int
  target_function_index : Int
}

///|
priv struct StarshineProgramCapturedTraitDictionary {
  module_index : Int
  dictionary_index : Int
  capture_type_index : Int
}

///|
priv struct StarshineProgramAdapterHelperPlan {
  helpers : Array[StarshineProgramAdapterHelper]
  wrappers : Array[StarshineProgramCallbackWrapper]
  evidence_closures : Array[StarshineProgramEvidenceClosure]
  captured_trait_dictionaries : Array[StarshineProgramCapturedTraitDictionary]
  evidence_error : StarshineCodeEmissionError?
}

///|
/// Static lookup context shared by single-module and linked-program expression
/// emission. It deliberately contains data rather than callbacks so hot body
/// loops keep direct branches and indexed access.
priv struct StarshineExpressionEmissionContext {
  program : @semantic.PlannedProgramWasmGCLink?
  module_index : Int
  helper_plan : StarshineProgramAdapterHelperPlan?
  result_function : @semantic.PlannedProgramWasmFunction?
}

///|
fn starshine_program_evidence_closure(
  helper_plan : StarshineProgramAdapterHelperPlan,
  planned : @semantic.PlannedProgramWasmGCLink,
  body : @semantic.BodyId,
  specialization_abi_key : String,
  expression : @semantic.ExprId,
) -> StarshineProgramEvidenceClosure? {
  for closure in helper_plan.evidence_closures {
    if closure.reference_index < 0 ||
      closure.reference_index >= planned.evidence_function_references.length() {
      continue
    }
    let reference = planned.evidence_function_references[closure.reference_index]
    if reference.caller_body == body &&
      reference.caller_specialization_abi_key == specialization_abi_key &&
      reference.expression == expression {
      return Some(closure)
    }
  }
  None
}

///|
fn starshine_program_captured_trait_dictionary(
  helper_plan : StarshineProgramAdapterHelperPlan,
  module_index : Int,
  dictionary_index : Int,
) -> StarshineProgramCapturedTraitDictionary? {
  for captured in helper_plan.captured_trait_dictionaries {
    if captured.module_index == module_index &&
      captured.dictionary_index == dictionary_index {
      return Some(captured)
    }
  }
  None
}

///|
fn starshine_program_captured_trait_dictionary_for_adapter(
  planned : @semantic.PlannedProgramWasmGCLink,
  helper_plan : StarshineProgramAdapterHelperPlan,
  module_index : Int,
  adapter : @semantic.DeclId,
) -> StarshineProgramCapturedTraitDictionary? {
  for captured in helper_plan.captured_trait_dictionaries {
    if captured.module_index != module_index ||
      captured.dictionary_index < 0 ||
      captured.dictionary_index >=
      planned.modules[module_index].trait_dictionaries.length() {
      continue
    }
    let module_ = planned.modules[module_index]
    let dictionary = module_.trait_dictionaries[captured.dictionary_index]
    for index in 0..<dictionary.methods.length {
      let method_info = module_.trait_methods[dictionary.methods.start + index]
      if method_info.adapter_function >= 0 &&
        method_info.adapter_function < module_.functions.length() &&
        module_.functions[method_info.adapter_function].declaration == adapter {
        return Some(captured)
      }
    }
  }
  None
}

///|
fn starshine_callable_generic_parameters(
  callable : @semantic.PlannedCallable,
) -> @semantic.CallableGenericParameters {
  callable.all_generic_parameters()
}

///|
fn starshine_specialized_shape(
  lowering : @semantic.PlannedModuleLowering,
  specialization : StarshineGenericSpecialization?,
  type_ : @semantic.BodyTypeId,
  fallback : @semantic.PlannedValueShape,
) -> @semantic.PlannedValueShape {
  let specialization = match specialization {
    Some(value) => value
    None => return fallback
  }
  @semantic.specialize_planned_body_value_shape(
    lowering,
    type_,
    fallback,
    specialization.generic_parameters,
    specialization.shapes,
    specialization.specialization_shapes,
  )
}

///|
fn starshine_specialized_implicit_shape(
  lowering : @semantic.PlannedModuleLowering,
  specialization : StarshineGenericSpecialization?,
  fallback : @semantic.PlannedValueShape,
) -> @semantic.PlannedValueShape {
  let specialized = starshine_specialized_shape(
    lowering, specialization, -1, fallback,
  )
  let specialization = match specialization {
    Some(value) => value
    None => return specialized
  }
  if specialized is @semantic.GenericPlannedValueShape &&
    fallback is @semantic.GenericPlannedValueShape &&
    specialization.generic_parameters.length == 1 &&
    specialization.specialization_shapes.length == 1 {
    specialization.shapes[specialization.specialization_shapes.start]
  } else {
    specialized
  }
}

///|
priv enum StarshineEmitTask {
  EmitStarshineExpression(@semantic.ExprId)
  EmitStarshineRawExpression(@semantic.ExprId)
  EmitStarshineBlock(@semantic.BlockId)
  EmitStarshineEmpty
  FinishStarshineBlock(@semantic.BlockId)
  FinishStarshineLocalSet(Int, Int, @semantic.ExprId)
  FinishStarshineCaptureSet(Int, Int, @semantic.ExprId, Int)
  FinishStarshineCall(
    @semantic.DeclId,
    @semantic.ExprId,
    Int,
    @semantic.HirSpan
  )
  FinishStarshineTailCall(
    @semantic.DeclId,
    @semantic.ExprId,
    Int,
    @semantic.HirSpan
  )
  FinishStarshineParameterSelect(@semantic.HirSpan, Int)
  FinishStarshineProduct(Int)
  FinishStarshineDirectLambdaCall(Int, @semantic.HirSpan, Int)
  FinishStarshineFunctionValueCall(Int, Int)
  FinishStarshineClosureCall(StarshineClosureCallPlan, Int)
  FinishStarshineRefIntrinsic(Int)
  FinishStarshineFixedArray(Int, @semantic.PlannedValueShape, Int, Int, Int)
  FinishStarshineArrayLiteral(@semantic.PlannedValueShape, Int, Int, Int, Int)
  FinishStarshineArray(
    Int,
    @semantic.PlannedValueShape?,
    Int,
    Int,
    Int,
    Int,
    Int
  )
  FinishStarshineHashIter(
    Int,
    @semantic.PlannedValueShape,
    @semantic.PlannedValueShape,
    Int,
    Int,
    Int,
    Int,
    Int
  )
  FinishStarshineMap(
    Int,
    @semantic.PlannedValueShape,
    @semantic.PlannedValueShape,
    @semantic.DeclId,
    @semantic.DeclId,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int
  )
  FinishStarshineSet(
    Int,
    @semantic.PlannedValueShape,
    @semantic.DeclId,
    @semantic.DeclId,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int
  )
  FinishStarshineProductBox(@semantic.PlannedValueShape, Int)
  FinishStarshineProductUnbox(@semantic.PlannedValueShape, Int)
  FinishStarshineConstructor(
    @semantic.PlannedProgramWasmGCLink?,
    Int,
    @semantic.PlannedModuleWasmGCFragments,
    @semantic.PlannedWasmPhysicalType,
    Int,
    Array[@semantic.ExprId],
    Array[Int]
  )
  FinishStarshineEnumSubtype(
    @semantic.PlannedProgramWasmGCLink?,
    Int,
    @semantic.PlannedModuleWasmGCFragments,
    @semantic.PlannedWasmPhysicalType,
    Int,
    Int
  )
  FinishStarshinePackedEnumPayload(Int)
  FinishStarshineNominalResult(@semantic.DeclId)
  FinishStarshineFieldGet(Int, Int, @semantic.PlannedWasmStorageType)
  FinishStarshinePolymorphicFieldGet(
    Array[StarshineFieldLocation],
    Int,
    @semantic.PlannedValueShape
  )
  FinishStarshineFieldSet(Int, Int)
  FinishStarshineUnitFieldSet
  FinishStarshineMatch(@semantic.ExprId, @semantic.HirSpan, Int)
  FinishStarshineWhile(
    @semantic.ExprId,
    @semantic.ControlId,
    @semantic.HirSpan,
    Int,
    Int
  )
  FinishStarshineControlTransfer(
    @semantic.ControlId,
    Bool,
    @semantic.PlannedValueShape
  )
  FinishStarshineReturn
  FinishStarshineIf(@semantic.PlannedValueShape, Int)
  FinishStarshinePrefix(
    @semantic.HirPrefixOperator,
    @semantic.PlannedValueShape
  )
  FinishStarshineLogical(@semantic.HirBinaryOperator)
  FinishStarshineTraitObjectCoercion(@semantic.DeclId, Int)
  FinishStarshineRuntimeBoundCall(@semantic.DeclId, Int, Int, Int, Int)
  FinishStarshineDynamicTraitCall(@semantic.DeclId, Int, Int, Int, Int)
}

///|
priv enum StarshinePatternEmitTask {
  EmitStarshinePattern(@semantic.PatternId, Array[@lib.Instruction])
  FinishStarshinePatternAll(Int)
  FinishStarshinePatternAny(Int)
  FinishStarshineVariantPattern(Array[@lib.Instruction], Int, Int, Int)
}

///|
fn starshine_shape_matches_storage(
  shape : @semantic.PlannedValueShape,
  storage : @semantic.PlannedWasmStorageType,
) -> Bool {
  match shape {
    @semantic.I8PlannedValueShape | @semantic.U8PlannedValueShape =>
      match storage {
        @semantic.WasmI8SignedStorage
        | @semantic.WasmI8UnsignedStorage
        | @semantic.WasmI32Storage => true
        _ => false
      }
    @semantic.I16PlannedValueShape | @semantic.U16PlannedValueShape =>
      match storage {
        @semantic.WasmI16SignedStorage
        | @semantic.WasmI16UnsignedStorage
        | @semantic.WasmI32Storage => true
        _ => false
      }
    @semantic.I32PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape =>
      match storage {
        @semantic.WasmI32Storage => true
        _ => false
      }
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape =>
      match storage {
        @semantic.WasmI64Storage => true
        _ => false
      }
    @semantic.F32PlannedValueShape =>
      match storage {
        @semantic.WasmF32Storage => true
        _ => false
      }
    @semantic.F64PlannedValueShape =>
      match storage {
        @semantic.WasmF64Storage => true
        _ => false
      }
    @semantic.V128PlannedValueShape =>
      match storage {
        @semantic.WasmV128Storage => true
        _ => false
      }
    @semantic.RefPlannedValueShape | @semantic.GenericPlannedValueShape =>
      match storage {
        @semantic.WasmStringRefStorage
        | @semantic.WasmNullableEqRefStorage
        | @semantic.WasmNominalRefStorage(_)
        | @semantic.WasmExternalNominalRefStorage(_)
        | @semantic.WasmFixedArrayRefStorage(_)
        | @semantic.WasmNullableNominalRefStorage(_)
        | @semantic.WasmNullableExternalNominalRefStorage(_) => true
        _ => false
      }
    @semantic.ProductPlannedValueShape(_) =>
      match storage {
        @semantic.WasmNullableEqRefStorage => true
        _ => false
      }
    @semantic.ErrorPlannedValueShape
    | @semantic.UnitPlannedValueShape
    | @semantic.NeverPlannedValueShape => false
  }
}

///|
fn starshine_default_storage_instructions(
  storage : @semantic.PlannedWasmStorageType,
) -> Array[@lib.Instruction] {
  match storage {
    @semantic.WasmI8SignedStorage
    | @semantic.WasmI8UnsignedStorage
    | @semantic.WasmI16SignedStorage
    | @semantic.WasmI16UnsignedStorage
    | @semantic.WasmI32Storage =>
      [@lib.Instruction::i32_const(@lib.I32::new(0))]
    @semantic.WasmI64Storage => [@lib.Instruction::i64_const(@lib.I64::new(0L))]
    @semantic.WasmF32Storage =>
      [@lib.Instruction::f32_const(@lib.F32::new(0.0))]
    @semantic.WasmF64Storage =>
      [@lib.Instruction::f64_const(@lib.F64::new(0.0))]
    @semantic.WasmV128Storage =>
      [
        @lib.Instruction::v128_const(
          b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
          b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
        ),
      ]
    @semantic.WasmStringRefStorage
    | @semantic.WasmNullableEqRefStorage
    | @semantic.WasmNominalRefStorage(_)
    | @semantic.WasmExternalNominalRefStorage(_)
    | @semantic.WasmNullableExternalNominalRefStorage(_) =>
      [@lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq()))]
    @semantic.WasmNullableNominalRefStorage(reference) =>
      [
        @lib.Instruction::ref_null(
          @lib.HeapType::new(starshine_type_index(reference)),
        ),
      ]
    @semantic.WasmFixedArrayRefStorage(_) => [@lib.Instruction::unreachable_()]
    @semantic.WasmNullableFunctionRefStorage =>
      [@lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::func()))]
    @semantic.WasmFunctionRefStorage(index) =>
      [
        @lib.Instruction::ref_null(
          @lib.HeapType::new(@lib.TypeIdx::new(index.reinterpret_as_uint())),
        ),
      ]
  }
}

///|
fn starshine_text_runtime_base_for_body(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
) -> Int {
  match program {
    Some(link) => link.type_count
    None => starshine_text_runtime_base(planned)
  }
}

///|
fn starshine_runtime_function_index_for_body(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  name : Bytes,
) -> Int {
  match program {
    Some(link) => link.runtime_function_index(name)
    None => planned.runtime_function_index(name)
  }
}

///|
fn starshine_text_constant_instructions(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  value : Bytes,
  string_ : Bool,
) -> Array[@lib.Instruction] {
  let base = starshine_text_runtime_base_for_body(planned, program)
  let array_type = @lib.TypeIdx::new(base.reinterpret_as_uint())
  let text_offset = if string_ { 1 } else { 2 }
  let text_type = @lib.TypeIdx::new((base + text_offset).reinterpret_as_uint())
  let instructions : Array[@lib.Instruction] = []
  let chunk_count = (value.length() + 15) / 16
  for chunk in 0..<chunk_count {
    let start = chunk * 16
    let lanes = Array::make(16, b'\x00')
    for lane in 0..<16 {
      let index = start + lane
      if index < value.length() {
        lanes[lane] = value[index]
      }
    }
    instructions.push(
      @lib.Instruction::v128_const(
        lanes[0],
        lanes[1],
        lanes[2],
        lanes[3],
        lanes[4],
        lanes[5],
        lanes[6],
        lanes[7],
        lanes[8],
        lanes[9],
        lanes[10],
        lanes[11],
        lanes[12],
        lanes[13],
        lanes[14],
        lanes[15],
      ),
    )
  }
  instructions.push(
    @lib.Instruction::array_new_fixed(
      array_type,
      @lib.U32::new(chunk_count.reinterpret_as_uint()),
    ),
  )
  instructions.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  instructions.push(@lib.Instruction::i32_const(@lib.I32::new(value.length())))
  instructions.push(@lib.Instruction::struct_new(text_type))
  instructions
}

///|
fn starshine_shape_leaf_count(shape : @semantic.PlannedValueShape) -> Int {
  match shape {
    @semantic.ProductPlannedValueShape(fields) => {
      let mut count = 0
      for field in fields {
        count += starshine_shape_leaf_count(field)
      }
      count
    }
    @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape => 0
    _ => 1
  }
}

///|
fn starshine_append_shape_value_types(
  output : Array[@lib.ValType],
  shape : @semantic.PlannedValueShape,
) -> Unit {
  match shape {
    @semantic.ProductPlannedValueShape(fields) =>
      for field in fields {
        starshine_append_shape_value_types(output, field)
      }
    _ =>
      match starshine_shape_value_type(shape) {
        Some(type_) => output.push(type_)
        None => ()
      }
  }
}

///|
fn starshine_append_product_local_gets(
  output : Array[@lib.Instruction],
  first : Int,
  shape : @semantic.PlannedValueShape,
) -> Unit {
  let count = starshine_shape_leaf_count(shape)
  for index in 0..<count {
    output.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new((first + index).reinterpret_as_uint()),
      ),
    )
  }
}

///|
fn starshine_append_product_local_sets(
  output : Array[@lib.Instruction],
  first : Int,
  shape : @semantic.PlannedValueShape,
) -> Unit {
  let mut count = starshine_shape_leaf_count(shape)
  while count > 0 {
    count -= 1
    output.push(
      @lib.Instruction::local_set(
        @lib.LocalIdx::new((first + count).reinterpret_as_uint()),
      ),
    )
  }
}

///|
fn starshine_append_shape_drops(
  output : Array[@lib.Instruction],
  shape : @semantic.PlannedValueShape,
) -> Unit {
  for _ in 0..<starshine_shape_leaf_count(shape) {
    output.push(@lib.Instruction::drop())
  }
}

///|
fn starshine_body_emitted_root_shape(
  lowering : @semantic.PlannedModuleLowering,
  specialization : StarshineGenericSpecialization?,
  body : @semantic.PlannedBodyLowering,
) -> @semantic.PlannedValueShape? {
  let expression = match body.root {
    @semantic.ExpressionBodyRoot(expression) => expression
    @semantic.BlockBodyRoot(block) => {
      let source = lowering.blocks[block]
      if source.items.length == 0 {
        return None
      }
      match
        lowering.block_items[source.items.start + source.items.length - 1].kind {
        @semantic.PlannedExpressionItem(expression) => expression
        @semantic.PlannedLetItem(_, _, _) | @semantic.PlannedElidedLetItem(_) =>
          return None
      }
    }
  }
  let source = lowering.expressions[expression]
  Some(
    starshine_specialized_shape(
      lowering,
      specialization,
      source.type_,
      source.shape,
    ),
  )
}

///|
fn starshine_product_projection_root(
  lowering : @semantic.PlannedModuleLowering,
  expression : @semantic.ExprId,
) -> (Int, Int)? {
  let mut current = expression
  let mut offset = 0
  while current >= 0 && current < lowering.expressions.length() {
    match lowering.expressions[current].kind {
      @semantic.PlannedLocalGet(local_id) => return Some((local_id, offset))
      @semantic.PlannedProductField(base, index, arity) =>
        match lowering.expressions[base].shape {
          @semantic.ProductPlannedValueShape(fields) if fields.length() == arity &&
            index >= 0 &&
            index < fields.length() => {
            for field_index in 0..<index {
              offset += starshine_shape_leaf_count(fields[field_index])
            }
            current = base
          }
          _ => return None
        }
      _ => return None
    }
  }
  None
}

///|
fn starshine_shape_value_type(
  shape : @semantic.PlannedValueShape,
) -> @lib.ValType? {
  match shape {
    @semantic.I8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape => Some(@lib.ValType::i32())
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape => Some(@lib.ValType::i64())
    @semantic.F32PlannedValueShape => Some(@lib.ValType::f32())
    @semantic.F64PlannedValueShape => Some(@lib.ValType::f64())
    @semantic.V128PlannedValueShape => Some(@lib.ValType::v128())
    @semantic.RefPlannedValueShape | @semantic.GenericPlannedValueShape =>
      Some(@lib.ValType::eqref_null())
    @semantic.ErrorPlannedValueShape
    | @semantic.ProductPlannedValueShape(_)
    | @semantic.UnitPlannedValueShape
    | @semantic.NeverPlannedValueShape => None
  }
}

///|
fn starshine_block_type(shape : @semantic.PlannedValueShape) -> @lib.BlockType {
  match starshine_shape_value_type(shape) {
    Some(value) => @lib.BlockType::val_type(value)
    None => @lib.BlockType::void_()
  }
}

///|
fn append_starshine_instructions(
  target : Array[@lib.Instruction],
  source : Array[@lib.Instruction],
) -> Unit {
  for instruction in source {
    target.push(instruction)
  }
}

///|
fn starshine_control_transfer_label(
  control : @semantic.ControlId,
  break_ : Bool,
) -> @lib.LabelIdx {
  let kind = if break_ { 0 } else { 1 }
  @lib.LabelIdx::new((0x70000000 + control * 2 + kind).reinterpret_as_uint())
}

///|
fn starshine_resolve_control_transfers(
  instructions : Array[@lib.Instruction],
  control : @semantic.ControlId,
) -> Unit {
  let break_label = starshine_control_transfer_label(control, true)
  let continue_label = starshine_control_transfer_label(control, false)
  let pending : Array[Array[@lib.Instruction]] = [instructions]
  let depths : Array[Int] = [0]
  while pending.length() > 0 {
    let current = pending.pop().unwrap()
    let depth = depths.pop().unwrap()
    for index in 0..<current.length() {
      match current[index] {
        @lib.Instruction::Br(label) =>
          if label == break_label {
            current[index] = @lib.Instruction::br(
              @lib.LabelIdx::new((depth + 1).reinterpret_as_uint()),
            )
          } else if label == continue_label {
            current[index] = @lib.Instruction::br(
              @lib.LabelIdx::new(depth.reinterpret_as_uint()),
            )
          }
        @lib.Instruction::Block(_, @lib.Expr(body))
        | @lib.Instruction::Loop(_, @lib.Expr(body)) => {
          pending.push(body)
          depths.push(depth + 1)
        }
        @lib.Instruction::If(_, consequent, alternative) => {
          pending.push(consequent)
          depths.push(depth + 1)
          match alternative {
            Some(value) => {
              pending.push(value)
              depths.push(depth + 1)
            }
            None => ()
          }
        }
        _ => ()
      }
    }
  }
}

///|
fn pop_starshine_fragments(
  results : Array[Array[@lib.Instruction]],
  count : Int,
) -> Array[Array[@lib.Instruction]] {
  let fragments = Array::make(count, [])
  let mut index = count
  while index > 0 {
    index -= 1
    fragments[index] = results.pop().unwrap()
  }
  fragments
}

///|
fn starshine_signed_i8_constant(value : UInt64) -> Int {
  let raw = (value & 0xFFUL).to_int()
  if raw >= 0x80 {
    raw - 0x100
  } else {
    raw
  }
}

///|
fn starshine_signed_i16_constant(value : UInt64) -> Int {
  let raw = (value & 0xFFFFUL).to_int()
  if raw >= 0x8000 {
    raw - 0x10000
  } else {
    raw
  }
}

///|
fn starshine_inline_builtin_instructions(
  name : Bytes,
  test_assert_function_index : Int,
  array_runtime_base : Int,
  array_wrapper_type : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  match starshine_conversion_builtin_instructions(name) {
    Some(instructions) => return Ok(instructions)
    None => ()
  }
  match starshine_memory_builtin_instructions(name) {
    Some(instructions) => return Ok(instructions)
    None => ()
  }
  match starshine_v128_builtin_instructions(name) {
    Some(instructions) => return Ok(instructions)
    None => ()
  }
  match starshine_numeric_builtin_instructions(name) {
    Some(instructions) => return Ok(instructions)
    None => ()
  }
  if name == b"dew_assert" {
    if test_assert_function_index >= 0 {
      Ok([
        @lib.Instruction::call(
          @lib.FuncIdx::new(test_assert_function_index.reinterpret_as_uint()),
        ),
      ])
    } else {
      Ok([
        @lib.Instruction::drop(),
        @lib.Instruction::i32_eqz(),
        @lib.Instruction::if_(
          @lib.BlockType::void_(),
          [@lib.Instruction::unreachable_()],
          None,
        ),
      ])
    }
  } else if name == b"dew_unreachable" {
    Ok([@lib.Instruction::unreachable_()])
  } else if name == b"dew_debug_ignore" {
    Ok([@lib.Instruction::drop()])
  } else if name == b"dew_array_backing_length_i32" ||
    name == b"dew_array_backing_length_ref" {
    if array_runtime_base < 0 || array_wrapper_type < 0 {
      return Err(UnsupportedBuiltin(name))
    }
    let carrier = if name == b"dew_array_backing_length_i32" { 0 } else { 5 }
    let array_type = array_runtime_base + carrier
    Ok([
      starshine_match_cast(array_wrapper_type),
      @lib.Instruction::struct_get(
        @lib.TypeIdx::new(array_wrapper_type.reinterpret_as_uint()),
        @lib.U32::new(0U),
      ),
      starshine_match_cast(array_type),
      @lib.Instruction::array_len(),
    ])
  } else if name == b"unsafe.bitcast" {
    Ok([])
  } else if name == b"ref_null" {
    Ok([
      @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::none())),
    ])
  } else if name == b"ref_is_null" {
    Ok([@lib.Instruction::ref_is_null()])
  } else if name == b"ref_as_non_null" {
    Ok([@lib.Instruction::ref_as_non_null()])
  } else if name == b"v128.and" {
    Ok([@lib.Instruction::v128_and()])
  } else if name == b"v128.or" {
    Ok([@lib.Instruction::v128_or()])
  } else if name == b"v128.xor" {
    Ok([@lib.Instruction::v128_xor()])
  } else {
    Err(UnsupportedBuiltin(name))
  }
}

///|
fn starshine_function_reference_index(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  declaration : @semantic.DeclId,
) -> Result[Int, StarshineCodeEmissionError] {
  let function_index = match program {
    Some(link) =>
      match link.function_of(declaration) {
        Some(function_) => function_.function_index
        None => return Err(MissingFunction(declaration))
      }
    None =>
      match planned.function_of(declaration) {
        Some(function_) => function_.function_index
        None => return Err(MissingFunction(declaration))
      }
  }
  if function_index < 0 {
    Err(MissingFunction(declaration))
  } else {
    Ok(function_index)
  }
}

///|
fn starshine_finish_call(
  planned : @semantic.PlannedModuleWasmGCFragments,
  declaration : @semantic.DeclId,
  fragments : Array[Array[@lib.Instruction]],
  tail : Bool,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let output : Array[@lib.Instruction] = []
  for fragment in fragments {
    append_starshine_instructions(output, fragment)
  }
  let test_assert_function_index = planned.runtime_function_index(
    b"dew_test_assert",
  )
  let array_wrapper_type = match
    starshine_emitted_type_index(
      planned,
      None,
      @semantic.standard_array_type_declaration(),
    ) {
    Some(value) => value
    None => -1
  }
  let function_ = match planned.function_of(declaration) {
    Some(function_) => function_
    None => return Err(MissingFunction(declaration))
  }
  match
    starshine_verify_raw_builtin_signature(
      function_.kind,
      function_.direct_builtin,
      planned.function_value_types,
      function_.parameters,
      function_.results,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  if function_.direct_builtin.length() > 0 {
    match
      starshine_inline_builtin_instructions(
        function_.direct_builtin,
        test_assert_function_index,
        starshine_fixed_array_runtime_base(planned),
        array_wrapper_type,
      ) {
      Ok(instructions) => append_starshine_instructions(output, instructions)
      Err(error) => return Err(error)
    }
  } else {
    match function_.kind {
      @semantic.PlannedWasmInlineBuiltinFunction(name) =>
        match
          starshine_inline_builtin_instructions(
            name,
            test_assert_function_index,
            starshine_fixed_array_runtime_base(planned),
            array_wrapper_type,
          ) {
          Ok(instructions) =>
            append_starshine_instructions(output, instructions)
          Err(error) => return Err(error)
        }
      @semantic.PlannedWasmImportedFunction(_)
      | @semantic.PlannedWasmRuntimeFunction(_)
      | @semantic.PlannedWasmDefinedFunction(_)
      | @semantic.PlannedWasmDefinedLambdaFunction(_)
      | @semantic.PlannedWasmTraitAdapterFunction(_, _) => {
        if function_.function_index < 0 {
          return Err(MissingFunction(declaration))
        }
        let function_index = @lib.FuncIdx::new(
          function_.function_index.reinterpret_as_uint(),
        )
        if tail {
          output.push(@lib.Instruction::return_call(function_index))
        } else {
          output.push(@lib.Instruction::call(function_index))
        }
      }
      @semantic.PlannedWasmSignatureOnlyFunction =>
        return Err(SignatureOnlyCall(declaration))
    }
  }
  Ok(output)
}

///|
fn starshine_diverging_call_evaluations(
  lowering : @semantic.PlannedModuleLowering,
  expression : @semantic.ExprId,
  fragments : Array[Array[@lib.Instruction]],
) -> Array[@lib.Instruction]? {
  for index in 0..<fragments.length() {
    let argument = starshine_program_call_argument(lowering, expression, index)
    if argument >= 0 && !lowering.expressions[argument].flow.may_fall_through() {
      let output : Array[@lib.Instruction] = []
      for previous in 0..<=index {
        append_starshine_instructions(output, fragments[previous])
      }
      return Some(output)
    }
  }
  None
}

///|
fn starshine_program_call_argument(
  lowering : @semantic.PlannedModuleLowering,
  expression : @semantic.ExprId,
  parameter_index : Int,
) -> @semantic.ExprId {
  if expression < 0 ||
    expression >= lowering.expressions.length() ||
    parameter_index < 0 {
    return -1
  }
  let receiver_argument = fn(
    receiver : @semantic.ExprId,
    arguments : @semantic.HirSpan,
  ) {
    if receiver >= 0 {
      if parameter_index == 0 {
        receiver
      } else if parameter_index - 1 < arguments.length {
        lowering.expression_children[arguments.start + parameter_index - 1]
      } else {
        -1
      }
    } else if parameter_index < arguments.length {
      lowering.expression_children[arguments.start + parameter_index]
    } else {
      -1
    }
  }
  match lowering.expressions[expression].kind {
    @semantic.PlannedDirectCall(_, receiver, arguments, _)
    | @semantic.PlannedTailCall(_, receiver, arguments, _)
    | @semantic.PlannedBoundDirectCall(_, _, receiver, arguments, _) =>
      receiver_argument(receiver, arguments)
    @semantic.PlannedOperatorCall(_, _, left, right, _)
    | @semantic.PlannedBoundOperatorCall(_, _, _, left, right, _) =>
      if parameter_index == 0 {
        left
      } else if parameter_index == 1 {
        right
      } else {
        -1
      }
    @semantic.PlannedIndexCall(_, base, index, _) =>
      if parameter_index == 0 {
        base
      } else if parameter_index == 1 {
        index
      } else {
        -1
      }
    @semantic.PlannedIndexSetCall(_, base, index, value, _) =>
      if parameter_index == 0 {
        base
      } else if parameter_index == 1 {
        index
      } else if parameter_index == 2 {
        value
      } else {
        -1
      }
    _ => -1
  }
}

///|
fn starshine_program_argument_needs_nominal_cast(
  lowering : @semantic.PlannedModuleLowering?,
  expression : @semantic.ExprId,
  parameter_index : Int,
) -> Bool {
  let lowering = match lowering {
    Some(value) => value
    None => return false
  }
  let argument = starshine_program_call_argument(
    lowering, expression, parameter_index,
  )
  if argument < 0 || argument >= lowering.expressions.length() {
    return false
  }
  match lowering.expressions[argument].kind {
    @semantic.PlannedLocalGet(_)
    | @semantic.PlannedCaptureGet(_)
    | @semantic.PlannedModuleValueGet(_, _)
    | @semantic.PlannedBlockExpression(_)
    | @semantic.PlannedIfExpression(_, _, _)
    | @semantic.PlannedMatchExpression(_, _)
    | @semantic.PlannedWhileExpression(_, _, _)
    | @semantic.PlannedFieldGet(_, _, _)
    | @semantic.PlannedFixedArrayGetUnchecked(_, _, _)
    | @semantic.PlannedArrayGet(_, _, _, _)
    | @semantic.PlannedArrayGetUnchecked(_, _, _)
    | @semantic.PlannedDirectCall(_, _, _, _)
    | @semantic.PlannedTailCall(_, _, _, _)
    | @semantic.PlannedOperatorCall(_, _, _, _, _)
    | @semantic.PlannedFunctionValueCall(_, _, _)
    | @semantic.PlannedDirectLambdaCall(_, _, _)
    | @semantic.PlannedIndexCall(_, _, _, _) => true
    _ => false
  }
}

///|
fn starshine_program_local_external_argument_needs_nominal_cast(
  lowering : @semantic.PlannedModuleLowering?,
  expression : @semantic.ExprId,
  parameter_index : Int,
) -> Bool {
  let lowering = match lowering {
    Some(value) => value
    None => return false
  }
  let argument = starshine_program_call_argument(
    lowering, expression, parameter_index,
  )
  if argument < 0 || argument >= lowering.expressions.length() {
    return false
  }
  match lowering.expressions[argument].kind {
    @semantic.PlannedLocalGet(_)
    | @semantic.PlannedBlockExpression(_)
    | @semantic.PlannedIfExpression(_, _, _)
    | @semantic.PlannedMatchExpression(_, _)
    | @semantic.PlannedWhileExpression(_, _, _)
    | @semantic.PlannedFixedArrayGetUnchecked(_, _, _)
    | @semantic.PlannedArrayGet(_, _, _, _)
    | @semantic.PlannedArrayGetUnchecked(_, _, _)
    | @semantic.PlannedIndexCall(_, _, _, _) => true
    _ => false
  }
}

///|
fn starshine_program_parameter_is_external_nominal(
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  parameter_index : Int,
) -> Bool {
  if parameter_index < 0 || parameter_index >= function_.parameters.length {
    return false
  }
  let fragments = planned.modules[function_.module_index]
  match
    fragments.function_value_types[function_.parameters.start + parameter_index] {
    @semantic.WasmExternalNominalRefValue(_)
    | @semantic.WasmFixedArrayRefValue(_) => true
    _ => false
  }
}

///|
fn starshine_program_is_generic_specialization(
  _planned : @semantic.PlannedProgramWasmGCLink,
  specialization : StarshineGenericSpecialization?,
) -> Bool {
  match specialization {
    Some(_) => true
    None => false
  }
}

///|
fn starshine_finish_program_call(
  lowering : @semantic.PlannedModuleLowering?,
  planned : @semantic.PlannedProgramWasmGCLink,
  caller : @semantic.PlannedModuleWasmGCFragments,
  body : @semantic.BodyId,
  expression : @semantic.ExprId,
  declaration : @semantic.DeclId,
  type_arguments : @semantic.HirSpan?,
  generic_specialization : StarshineGenericSpecialization?,
  fragments : Array[Array[@lib.Instruction]],
  tail : Bool,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let output : Array[@lib.Instruction] = []
  let caller_module_index = match planned.module_lookup.get(caller.module_id) {
    Some(index) => index
    None => abort("caller's module is not linked")
  }
  let test_assert_function_index = planned.module_runtime_function_index(
    caller_module_index, b"dew_test_assert",
  )
  let array_wrapper_type = match
    starshine_emitted_type_index(
      caller,
      Some(planned),
      @semantic.standard_array_type_declaration(),
    ) {
    Some(value) => value
    None => -1
  }
  let caller_specialization_abi_key = match generic_specialization {
    Some(value) => value.specialization_abi_key
    None => ""
  }
  let preselected = planned.specialized_call_function(
    body, caller_specialization_abi_key, expression,
  )
  let runtime_evidence = planned.specialized_call_runtime_evidence(
    body, caller_specialization_abi_key, expression,
  )
  let runtime_evidence_length = match runtime_evidence {
    Some(value) => value.length
    None => 0
  }
  let function_ = match preselected {
    Some(function_) => function_
    None =>
      match type_arguments {
        Some(arguments) if arguments.length > 0 => {
          let caller_lowering = lowering.unwrap()
          let resolved_shapes : Array[@semantic.PlannedValueShape] = []
          for index in 0..<arguments.length {
            let source_index = arguments.start + index
            resolved_shapes.push(
              starshine_specialized_shape(
                caller_lowering,
                generic_specialization,
                caller_lowering.call_type_arguments[source_index],
                caller_lowering.call_type_argument_shapes[source_index],
              ),
            )
          }
          match
            planned.specialized_function_of_exact_shapes(
              declaration, resolved_shapes,
            ) {
            Some(function_) => function_
            None => return Err(MissingFunction(declaration))
          }
        }
        _ =>
          match planned.function_of(declaration) {
            Some(function_) => function_
            None => return Err(MissingFunction(declaration))
          }
      }
  }
  let cross_module_or_specialized = caller_module_index !=
    function_.module_index ||
    starshine_program_is_generic_specialization(planned, generic_specialization)
  let mut physical_parameter_index = 0
  for logical_parameter_index, fragment in fragments {
    append_starshine_instructions(output, fragment)
    let physical_width = match lowering {
      Some(caller_lowering) => {
        let argument = starshine_program_call_argument(
          caller_lowering, expression, logical_parameter_index,
        )
        if argument >= 0 && argument < caller_lowering.expressions.length() {
          let source = caller_lowering.expressions[argument]
          starshine_shape_leaf_count(
            starshine_specialized_shape(
              caller_lowering,
              generic_specialization,
              source.type_,
              source.shape,
            ),
          )
        } else {
          1
        }
      }
      None => 1
    }
    let needs_cast = starshine_program_argument_needs_nominal_cast(
        lowering, expression, logical_parameter_index,
      ) ||
      (
        !cross_module_or_specialized &&
        starshine_program_parameter_is_external_nominal(
          planned, function_, physical_parameter_index,
        ) &&
        starshine_program_local_external_argument_needs_nominal_cast(
          lowering, expression, logical_parameter_index,
        )
      )
    // Unit and Never stay in the logical evaluation schedule, but they do not
    // produce a physical operand. A cast for an erased argument would consume
    // the preceding operand or underflow an empty stack.
    if physical_width > 0 && needs_cast {
      starshine_append_program_argument_cast(
        planned, function_, physical_parameter_index, output,
      )
    }
    physical_parameter_index += physical_width
  }
  match
    starshine_verify_raw_builtin_signature(
      function_.kind,
      function_.direct_builtin,
      planned.modules[function_.module_index].function_value_types,
      function_.parameters,
      function_.results,
    ) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  if physical_parameter_index + runtime_evidence_length !=
    function_.parameters.length {
    return Err(UnsupportedExpression(body, expression))
  }
  match runtime_evidence {
    Some(span) =>
      for index in 0..<span.length {
        let source_index = span.start + index
        if source_index < 0 ||
          source_index >=
          planned.specialized_call_runtime_evidence_parameters.length() {
          return Err(UnsupportedExpression(body, expression))
        }
        let parameter = planned.specialized_call_runtime_evidence_parameters[source_index]
        if parameter < 0 {
          return Err(UnsupportedExpression(body, expression))
        }
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(parameter.reinterpret_as_uint()),
          ),
        )
      }
    None => ()
  }
  if function_.direct_builtin.length() > 0 {
    match
      starshine_inline_builtin_instructions(
        function_.direct_builtin,
        test_assert_function_index,
        planned.fixed_array_type_base,
        array_wrapper_type,
      ) {
      Ok(instructions) => append_starshine_instructions(output, instructions)
      Err(error) => return Err(error)
    }
  } else {
    match function_.kind {
      @semantic.PlannedWasmInlineBuiltinFunction(name) =>
        match
          starshine_inline_builtin_instructions(
            name,
            test_assert_function_index,
            planned.fixed_array_type_base,
            array_wrapper_type,
          ) {
          Ok(instructions) =>
            append_starshine_instructions(output, instructions)
          Err(error) => return Err(error)
        }
      @semantic.PlannedWasmImportedFunction(_)
      | @semantic.PlannedWasmRuntimeFunction(_)
      | @semantic.PlannedWasmDefinedFunction(_)
      | @semantic.PlannedWasmDefinedLambdaFunction(_)
      | @semantic.PlannedWasmTraitAdapterFunction(_, _) => {
        if function_.function_index < 0 {
          return Err(MissingFunction(declaration))
        }
        let function_index = @lib.FuncIdx::new(
          function_.function_index.reinterpret_as_uint(),
        )
        if tail {
          output.push(@lib.Instruction::return_call(function_index))
        } else {
          output.push(@lib.Instruction::call(function_index))
        }
      }
      @semantic.PlannedWasmSignatureOnlyFunction =>
        return Err(SignatureOnlyCall(declaration))
    }
  }
  Ok(output)
}

///|
fn starshine_emitted_type_index(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  declaration : @semantic.DeclId,
) -> Int? {
  match program {
    Some(link) => link.type_lookup.get(declaration)
    None => planned.type_index_of(declaration)
  }
}

///|
fn starshine_emitted_struct_type_index(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  declaration : @semantic.DeclId,
) -> Int? {
  match starshine_emitted_type_index(planned, program, declaration) {
    Some(value) => return Some(value)
    None => ()
  }
  let link = match program {
    Some(value) => value
    None => return None
  }
  let owner_module = match
    link.module_lookup.get(@semantic.semantic_id_module(declaration)) {
    Some(value) => value
    None => return None
  }
  let physical = match
    starshine_struct_physical_type(link.modules[owner_module], declaration) {
    Some(value) => value
    None => return None
  }
  let index = link.physical_type_index(owner_module, physical.type_index)
  if index >= 0 {
    Some(index)
  } else {
    None
  }
}

///|
fn starshine_struct_physical_type(
  planned : @semantic.PlannedModuleWasmGCFragments,
  declaration : @semantic.DeclId,
) -> @semantic.PlannedWasmPhysicalType? {
  for type_ in planned.physical_types {
    match type_.kind {
      @semantic.PlannedWasmStructType(owner) if owner == declaration =>
        return Some(type_)
      _ => ()
    }
  }
  None
}

///|
priv enum StarshineVariantExpectedFields {
  StarshineExpectedTupleFields(Array[@semantic.PlannedValueShape])
  StarshineExpectedStructFields(
    Array[@semantic.FieldId],
    Array[@semantic.PlannedValueShape]
  )
  StarshineExpectedUnitFields
}

///|
fn starshine_variant_physical_matches(
  planned : @semantic.PlannedModuleWasmGCFragments,
  physical : @semantic.PlannedWasmPhysicalType,
  expected : StarshineVariantExpectedFields,
) -> Bool {
  match expected {
    StarshineExpectedTupleFields(shapes) => {
      let mut expected_count = 0
      for shape in shapes {
        if starshine_shape_value_type(shape) is Some(_) ||
          shape is @semantic.ProductPlannedValueShape(_) {
          expected_count += 1
        }
      }
      if physical.fields.length - 1 != expected_count {
        return false
      }
      for index in 1..<physical.fields.length {
        let field = planned.fields[physical.fields.start + index]
        match field.role {
          @semantic.WasmTuplePayloadField(_, source_index) if source_index >= 0 &&
            source_index < shapes.length() &&
            starshine_shape_matches_storage(shapes[source_index], field.storage) =>
            ()
          _ => return false
        }
      }
      true
    }
    StarshineExpectedStructFields(field_ids, shapes) => {
      for source_index in 0..<field_ids.length() {
        if source_index >= shapes.length() ||
          (
            starshine_shape_value_type(shapes[source_index]) is None &&
            !(shapes[source_index] is @semantic.ProductPlannedValueShape(_))
          ) {
          continue
        }
        let mut found = false
        for index in 1..<physical.fields.length {
          let field = planned.fields[physical.fields.start + index]
          match field.role {
            @semantic.WasmStructPayloadField(field_id) if field_id ==
              field_ids[source_index] &&
              starshine_shape_matches_storage(
                shapes[source_index],
                field.storage,
              ) => {
              found = true
              break
            }
            _ => ()
          }
        }
        if !found {
          return false
        }
      }
      true
    }
    StarshineExpectedUnitFields => physical.fields.length == 1
  }
}

///|
fn starshine_variant_payload_physical_type_for_fields(
  planned : @semantic.PlannedModuleWasmGCFragments,
  variant : @semantic.VariantId,
  expected : StarshineVariantExpectedFields,
) -> @semantic.PlannedWasmPhysicalType? {
  match planned.payload_type_index_of(variant) {
    Some(index) =>
      for type_ in planned.physical_types {
        if type_.type_index == index &&
          starshine_variant_physical_matches(planned, type_, expected) {
          return Some(type_)
        }
      }
    None => ()
  }
  for type_ in planned.physical_types {
    match type_.kind {
      @semantic.PlannedWasmEnumSubtypeType(_, candidate, _) if candidate ==
        variant &&
        starshine_variant_physical_matches(planned, type_, expected) =>
        return Some(type_)
      _ => ()
    }
  }
  None
}

///|
fn starshine_variant_payload_physical_type(
  planned : @semantic.PlannedModuleWasmGCFragments,
  variant : @semantic.VariantId,
) -> @semantic.PlannedWasmPhysicalType? {
  let type_index = match planned.payload_type_index_of(variant) {
    Some(index) => index
    None => return None
  }
  for type_ in planned.physical_types {
    if type_.type_index == type_index {
      return Some(type_)
    }
  }
  None
}

///|
fn starshine_field_location(
  planned : @semantic.PlannedModuleWasmGCFragments,
  field : @semantic.FieldId,
  shape : @semantic.PlannedValueShape,
) -> (Int, Int, @semantic.PlannedWasmStorageType)? {
  for type_ in planned.physical_types {
    for index in 0..<type_.fields.length {
      let planned_field = planned.fields[type_.fields.start + index]
      match planned_field.role {
        @semantic.WasmStructField(candidate)
        | @semantic.WasmStructPayloadField(candidate) if candidate == field &&
          starshine_shape_matches_storage(shape, planned_field.storage) =>
          return Some(
            (
              type_.type_index,
              planned_field.physical_index,
              planned_field.storage,
            ),
          )
        _ => ()
      }
    }
  }
  None
}

///|
fn starshine_field_locations(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  owner_module : Int,
  field : @semantic.FieldId,
  shape : @semantic.PlannedValueShape,
) -> Array[StarshineFieldLocation] {
  let locations : Array[StarshineFieldLocation] = []
  for type_ in planned.physical_types {
    for index in 0..<type_.fields.length {
      let planned_field = planned.fields[type_.fields.start + index]
      match planned_field.role {
        @semantic.WasmStructField(candidate)
        | @semantic.WasmStructPayloadField(candidate) if candidate == field &&
          starshine_shape_matches_storage(shape, planned_field.storage) => {
          let type_index = match program {
            Some(link) =>
              link.physical_type_index(owner_module, type_.type_index)
            None => type_.type_index
          }
          locations.push({
            type_index,
            field_index: planned_field.physical_index,
            storage: planned_field.storage,
          })
        }
        _ => ()
      }
    }
  }
  locations
}

///|
fn starshine_struct_get_instruction(
  type_index : Int,
  field_index : Int,
  storage : @semantic.PlannedWasmStorageType,
) -> @lib.Instruction {
  let type_ = @lib.TypeIdx::new(type_index.reinterpret_as_uint())
  let field = @lib.U32::new(field_index.reinterpret_as_uint())
  match storage {
    @semantic.WasmI8SignedStorage | @semantic.WasmI16SignedStorage =>
      @lib.Instruction::struct_get_s(type_, field)
    @semantic.WasmI8UnsignedStorage | @semantic.WasmI16UnsignedStorage =>
      @lib.Instruction::struct_get_u(type_, field)
    _ => @lib.Instruction::struct_get(type_, field)
  }
}

///|
fn starshine_match_cast(type_index : Int) -> @lib.Instruction {
  @lib.Instruction::ref_cast(
    false,
    @lib.HeapType::new(@lib.TypeIdx::new(type_index.reinterpret_as_uint())),
  )
}

///|
fn starshine_nullable_match_cast(type_index : Int) -> @lib.Instruction {
  @lib.Instruction::ref_cast(
    true,
    @lib.HeapType::new(@lib.TypeIdx::new(type_index.reinterpret_as_uint())),
  )
}

///|
fn starshine_append_storage_cast(
  output : Array[@lib.Instruction],
  program : @semantic.PlannedProgramWasmGCLink?,
  owner_module : Int,
  module_plan : @semantic.PlannedModuleWasmGCFragments,
  physical : @semantic.PlannedWasmPhysicalType,
  storage : @semantic.PlannedWasmStorageType,
) -> Unit {
  match storage {
    @semantic.WasmNominalRefStorage(reference) => {
      let local_type_index = match reference {
        @semantic.WasmModuleTypeReference(value) => value
        @semantic.WasmRecursiveTypeReference(value) =>
          module_plan.type_groups[physical.group_index].first_type_index + value
      }
      let type_index = starshine_local_physical_type_index(
        program, owner_module, local_type_index,
      )
      if type_index >= 0 {
        output.push(starshine_match_cast(type_index))
      }
    }
    @semantic.WasmExternalNominalRefStorage(declaration) =>
      match program {
        Some(link) =>
          match link.type_lookup.get(declaration) {
            Some(type_index) => output.push(starshine_match_cast(type_index))
            None => ()
          }
        None => ()
      }
    @semantic.WasmNullableNominalRefStorage(reference) => {
      let local_type_index = match reference {
        @semantic.WasmModuleTypeReference(value) => value
        @semantic.WasmRecursiveTypeReference(value) =>
          module_plan.type_groups[physical.group_index].first_type_index + value
      }
      let type_index = starshine_local_physical_type_index(
        program, owner_module, local_type_index,
      )
      if type_index >= 0 {
        output.push(starshine_nullable_match_cast(type_index))
      }
    }
    @semantic.WasmNullableExternalNominalRefStorage(declaration) =>
      match program {
        Some(link) =>
          match link.type_lookup.get(declaration) {
            Some(type_index) =>
              output.push(starshine_nullable_match_cast(type_index))
            None => ()
          }
        None => ()
      }
    @semantic.WasmFixedArrayRefStorage(carrier) =>
      output.push(
        starshine_match_cast(
          match program {
            Some(link) => link.fixed_array_type_base + carrier
            None => starshine_fixed_array_runtime_base(module_plan) + carrier
          },
        ),
      )
    _ => ()
  }
}

///|
fn starshine_precise_nominal_local_type_index(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  planned_local : @semantic.PlannedLocal,
) -> Int? {
  if planned_local.nominal == 0UL ||
    lowering.raw_array_declarations.contains(planned_local.nominal) ||
    planned_local.nominal == @semantic.standard_array_type_declaration() ||
    planned_local.nominal ==
    @semantic.standard_array_iterator_type_declaration() ||
    planned_local.nominal == @semantic.standard_map_type_declaration() ||
    planned_local.nominal == @semantic.standard_array_entry_type_declaration() ||
    planned_local.nominal == @semantic.standard_map_entry_type_declaration() ||
    planned_local.nominal ==
    @semantic.standard_map_key_iterator_type_declaration() ||
    planned_local.nominal ==
    @semantic.standard_map_value_iterator_type_declaration() ||
    planned_local.nominal ==
    @semantic.standard_map_entry_iterator_type_declaration() ||
    planned_local.nominal == @semantic.standard_set_type_declaration() ||
    planned_local.nominal == @semantic.standard_set_iterator_type_declaration() {
    return None
  }
  match lowering.type_layouts.layout_of(planned_local.nominal) {
    Some(_) =>
      starshine_emitted_type_index(planned, program, planned_local.nominal)
    None => None
  }
}

///|
fn starshine_nominal_expression_result_is_precise(
  lowering : @semantic.PlannedModuleLowering,
  expression : @semantic.ExprId,
) -> Bool {
  if expression < 0 || expression >= lowering.expressions.length() {
    return false
  }
  match lowering.expressions[expression].kind {
    @semantic.PlannedLocalGet(_)
    | @semantic.PlannedCaptureGet(_)
    | @semantic.PlannedModuleValueGet(_, _)
    | @semantic.PlannedStructNew(_, _, _)
    | @semantic.PlannedVariantTupleNew(_, _, _)
    | @semantic.PlannedVariantStructNew(_, _, _)
    | @semantic.PlannedUnitVariant(_, _)
    | @semantic.PlannedPackedEnumPayload(_, _)
    | @semantic.PlannedParameterSelect(_, _) => true
    // A logical nominal call can use an erased eqref result in its linked
    // generic ABI. Call syntax alone does not prove a precise heap type.
    _ => false
  }
}

///|
fn starshine_append_precise_nominal_local_cast(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body : @semantic.PlannedBodyLowering,
  local_id : Int,
  source_expression : @semantic.ExprId,
  output : Array[@lib.Instruction],
) -> Unit {
  if local_id < 0 ||
    local_id >= body.locals.length ||
    starshine_local_capture_cell_slot(lowering, body, local_id) >= 0 ||
    starshine_nominal_expression_result_is_precise(lowering, source_expression) {
    return
  }
  let planned_local = lowering.locals[body.locals.start + local_id]
  if !(planned_local.shape is @semantic.RefPlannedValueShape) {
    return
  }
  match
    starshine_precise_nominal_local_type_index(
      lowering, planned, program, planned_local,
    ) {
    Some(type_index) => output.push(starshine_match_cast(type_index))
    None => ()
  }
}

///|
fn starshine_match_local_get(local_index : Int) -> @lib.Instruction {
  @lib.Instruction::local_get(
    @lib.LocalIdx::new(local_index.reinterpret_as_uint()),
  )
}

///|
fn starshine_prefix_value_instructions(
  operator : @semantic.HirPrefixOperator,
  shape : @semantic.PlannedValueShape,
  operand : Array[@lib.Instruction],
) -> Array[@lib.Instruction]? {
  let output : Array[@lib.Instruction] = []
  match operator {
    @semantic.HirPositive => append_starshine_instructions(output, operand)
    @semantic.HirLogicalNot => {
      append_starshine_instructions(output, operand)
      output.push(@lib.Instruction::i32_eqz())
    }
    @semantic.HirNegative =>
      match shape {
        @semantic.I8PlannedValueShape => {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::i32_sub())
          output.push(@lib.Instruction::i32_extend8s())
        }
        @semantic.I16PlannedValueShape => {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::i32_sub())
          output.push(@lib.Instruction::i32_extend16s())
        }
        @semantic.U8PlannedValueShape => {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::i32_sub())
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0xFF)))
          output.push(@lib.Instruction::i32_and())
        }
        @semantic.U16PlannedValueShape => {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::i32_sub())
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0xFFFF)))
          output.push(@lib.Instruction::i32_and())
        }
        @semantic.I32PlannedValueShape
        | @semantic.U32PlannedValueShape
        | @semantic.Swar32PlannedValueShape => {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::i32_sub())
        }
        @semantic.I64PlannedValueShape
        | @semantic.U64PlannedValueShape
        | @semantic.Swar64PlannedValueShape => {
          output.push(@lib.Instruction::i64_const(@lib.I64::new(0L)))
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::i64_sub())
        }
        @semantic.F32PlannedValueShape => {
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::f32_neg())
        }
        @semantic.F64PlannedValueShape => {
          append_starshine_instructions(output, operand)
          output.push(@lib.Instruction::f64_neg())
        }
        _ => return None
      }
  }
  Some(output)
}

///|
fn starshine_literal_pattern_base_instructions(
  lowering : @semantic.PlannedModuleLowering,
  expression : @semantic.ExprId,
) -> Array[@lib.Instruction]? {
  if expression < 0 || expression >= lowering.expressions.length() {
    return None
  }
  match lowering.expressions[expression].kind {
    @semantic.PlannedI8Const(value) =>
      Some([
        @lib.Instruction::i32_const(
          @lib.I32::new(starshine_signed_i8_constant(value)),
        ),
      ])
    @semantic.PlannedI16Const(value) =>
      Some([
        @lib.Instruction::i32_const(
          @lib.I32::new(starshine_signed_i16_constant(value)),
        ),
      ])
    @semantic.PlannedU8Const(value) =>
      Some([
        @lib.Instruction::i32_const(@lib.I32::new((value & 0xFFUL).to_int())),
      ])
    @semantic.PlannedU16Const(value) =>
      Some([
        @lib.Instruction::i32_const(@lib.I32::new((value & 0xFFFFUL).to_int())),
      ])
    @semantic.PlannedI32Const(value) | @semantic.PlannedU32Const(value) =>
      Some([@lib.Instruction::i32_const(@lib.I32::new(value.to_int()))])
    @semantic.PlannedI64Const(value) | @semantic.PlannedU64Const(value) =>
      Some([
        @lib.Instruction::i64_const(@lib.I64::new(value.reinterpret_as_int64())),
      ])
    @semantic.PlannedF32Const(value) =>
      Some([@lib.Instruction::f32_const(@lib.F32::new(value))])
    @semantic.PlannedF64Const(value) =>
      Some([@lib.Instruction::f64_const(@lib.F64::new(value))])
    @semantic.PlannedBoolConst(value) =>
      Some([
        @lib.Instruction::i32_const(@lib.I32::new(if value { 1 } else { 0 })),
      ])
    _ => None
  }
}

///|
fn starshine_literal_pattern_value_instructions(
  lowering : @semantic.PlannedModuleLowering,
  expression : @semantic.ExprId,
) -> Array[@lib.Instruction]? {
  if expression < 0 || expression >= lowering.expressions.length() {
    return None
  }
  let source = lowering.expressions[expression]
  match source.kind {
    @semantic.PlannedPrefixExpression(operator, operand) => {
      let operand_instructions = match
        starshine_literal_pattern_base_instructions(lowering, operand) {
        Some(value) => value
        None => return None
      }
      starshine_prefix_value_instructions(
        operator,
        source.shape,
        operand_instructions,
      )
    }
    _ => starshine_literal_pattern_base_instructions(lowering, expression)
  }
}

///|
fn starshine_match_literal_condition(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body : @semantic.PlannedBodyLowering,
  expression : @semantic.ExprId,
  value : Array[@lib.Instruction],
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  if expression < 0 || expression >= lowering.expressions.length() {
    return Err(UnsupportedExpression(body.body, expression))
  }
  let condition = value.copy()
  match lowering.expressions[expression].kind {
    @semantic.PlannedStringConst(literal) => {
      append_starshine_instructions(
        condition,
        starshine_text_constant_instructions(planned, program, literal, true),
      )
      let equals = starshine_runtime_function_index_for_body(
        planned, program, b"dew_string_equals",
      )
      if equals < 0 {
        return Err(UnsupportedExpression(body.body, expression))
      }
      condition.push(
        @lib.Instruction::call(@lib.FuncIdx::new(equals.reinterpret_as_uint())),
      )
      return Ok(condition)
    }
    _ => ()
  }
  let literal = match
    starshine_literal_pattern_value_instructions(lowering, expression) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body.body, expression))
  }
  append_starshine_instructions(condition, literal)
  match lowering.expressions[expression].shape {
    @semantic.I8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.U32PlannedValueShape =>
      condition.push(@lib.Instruction::i32_eq())
    @semantic.I64PlannedValueShape | @semantic.U64PlannedValueShape =>
      condition.push(@lib.Instruction::i64_eq())
    @semantic.F32PlannedValueShape => condition.push(@lib.Instruction::f32_eq())
    @semantic.F64PlannedValueShape => condition.push(@lib.Instruction::f64_eq())
    _ => return Err(UnsupportedExpression(body.body, expression))
  }
  Ok(condition)
}

///|
fn starshine_pattern_uses_general_emission(
  lowering : @semantic.PlannedModuleLowering,
  root : @semantic.PatternId,
) -> Bool {
  let pending : Array[@semantic.PatternId] = [root]
  while pending.length() > 0 {
    let pattern = pending.pop().unwrap()
    let planned = lowering.patterns[pattern]
    if planned.shape is @semantic.ProductPlannedValueShape(_) {
      return true
    }
    match planned.selected_constructor {
      @semantic.StructInferredPatternConstructor(_, _) => return true
      _ => ()
    }
    match planned.source {
      @semantic.HirAlternativePattern(_, _, _) => return true
      @semantic.HirTuplePattern(_, arguments, _) =>
        for index in 0..<arguments.length {
          let child = lowering.pattern_children[arguments.start + index]
          if lowering.patterns[child].shape
            is @semantic.ProductPlannedValueShape(_) {
            return true
          }
          match lowering.patterns[child].source {
            @semantic.HirWildcardPattern(_)
            | @semantic.HirBindingPattern(_, _)
            | @semantic.HirRestPattern(_) => ()
            _ => return true
          }
        }
      @semantic.HirStructPattern(_, fields, _, _, _) =>
        for index in 0..<fields.length {
          let child = lowering.pattern_fields[fields.start + index].pattern
          if lowering.patterns[child].shape
            is @semantic.ProductPlannedValueShape(_) {
            return true
          }
          match lowering.patterns[child].source {
            @semantic.HirWildcardPattern(_)
            | @semantic.HirBindingPattern(_, _)
            | @semantic.HirRestPattern(_) => ()
            _ => return true
          }
        }
      _ => ()
    }
  }
  false
}

///|
fn starshine_pattern_all(
  fragments : Array[Array[@lib.Instruction]],
) -> Array[@lib.Instruction] {
  if fragments.length() == 0 {
    return [@lib.Instruction::i32_const(@lib.I32::new(1))]
  }
  let mut index = fragments.length() - 1
  let mut combined = fragments[index]
  while index > 0 {
    index -= 1
    let output = fragments[index]
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::i32()),
        combined,
        Some([@lib.Instruction::i32_const(@lib.I32::new(0))]),
      ),
    )
    combined = output
  }
  combined
}

///|
fn starshine_pattern_any(
  fragments : Array[Array[@lib.Instruction]],
) -> Array[@lib.Instruction] {
  if fragments.length() == 0 {
    return [@lib.Instruction::i32_const(@lib.I32::new(0))]
  }
  let mut index = fragments.length() - 1
  let mut combined = fragments[index]
  while index > 0 {
    index -= 1
    let output = fragments[index]
    output.push(
      @lib.Instruction::if_(
        @lib.BlockType::val_type(@lib.ValType::i32()),
        [@lib.Instruction::i32_const(@lib.I32::new(1))],
        Some(combined),
      ),
    )
    combined = output
  }
  combined
}

///|
fn starshine_general_match_pattern_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  body : @semantic.PlannedBodyLowering,
  root : @semantic.PatternId,
  scratch_local : Int,
  product_ref_scratch : Int,
  local_indices : Array[Int],
  generic_specialization : StarshineGenericSpecialization?,
) -> Result[
  (Array[@lib.Instruction], Array[@lib.Instruction]),
  StarshineCodeEmissionError,
] {
  let tasks : Array[StarshinePatternEmitTask] = [
    EmitStarshinePattern(root, [starshine_match_local_get(scratch_local)]),
  ]
  let results : Array[Array[@lib.Instruction]] = []
  while tasks.length() > 0 {
    match tasks.pop().unwrap() {
      EmitStarshinePattern(pattern, value) => {
        let source = lowering.patterns[pattern]
        match source.source {
          @semantic.HirAlternativePattern(first, remaining, _) => {
            tasks.push(FinishStarshinePatternAny(remaining.length + 1))
            let mut index = remaining.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshinePattern(
                  lowering.pattern_children[remaining.start + index],
                  value.copy(),
                ),
              )
            }
            tasks.push(EmitStarshinePattern(first, value))
            continue
          }
          @semantic.HirLiteralPattern(expression, _) => {
            match
              starshine_match_literal_condition(
                lowering, planned, program, body, expression, value,
              ) {
              Ok(condition) => results.push(condition)
              Err(error) => return Err(error)
            }
            continue
          }
          _ => ()
        }
        match source.selected_constructor {
          @semantic.NoInferredPatternConstructor => {
            let output : Array[@lib.Instruction] = []
            match source.reference {
              @semantic.PatternBindingReference(local_id) => {
                if local_id < 0 ||
                  local_id >= local_indices.length() ||
                  local_indices[local_id] < 0 {
                  return Err(InvalidLocal(body.body, local_id))
                }
                let local_info = lowering.locals[body.locals.start + local_id]
                let local_shape = starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  local_info.type_,
                  local_info.shape,
                )
                append_starshine_instructions(output, value)
                if local_shape is @semantic.ProductPlannedValueShape(_) {
                  if product_ref_scratch < 0 {
                    return Err(UnsupportedExpression(body.body, -428))
                  }
                  output.push(
                    @lib.Instruction::local_set(
                      @lib.LocalIdx::new(
                        product_ref_scratch.reinterpret_as_uint(),
                      ),
                    ),
                  )
                  match
                    starshine_append_product_unbox(
                      output,
                      planned,
                      program,
                      body.body,
                      product_ref_scratch,
                      local_shape,
                    ) {
                    Ok(_) => ()
                    Err(error) => return Err(error)
                  }
                  starshine_append_product_local_sets(
                    output,
                    local_indices[local_id],
                    local_shape,
                  )
                } else {
                  starshine_append_precise_nominal_local_cast(
                    lowering, planned, program, body, local_id, -1, output,
                  )
                  output.push(
                    @lib.Instruction::local_set(
                      @lib.LocalIdx::new(
                        local_indices[local_id].reinterpret_as_uint(),
                      ),
                    ),
                  )
                }
              }
              _ => ()
            }
            output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
            results.push(output)
          }
          @semantic.StructInferredPatternConstructor(declaration, _) => {
            let owner_module = match program {
              Some(link) =>
                link.module_lookup
                .get(@semantic.semantic_id_module(declaration))
                .unwrap_or(program_module_index)
              None => program_module_index
            }
            let owner_plan = match program {
              Some(link) => link.modules[owner_module]
              None => planned
            }
            let physical = match
              starshine_struct_physical_type(owner_plan, declaration) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, pattern))
            }
            let type_index = match program {
              Some(link) =>
                link.physical_type_index(owner_module, physical.type_index)
              None => physical.type_index
            }
            let pattern_fields = match source.source {
              @semantic.HirStructPattern(_, fields, _, _, _) => fields
              _ => return Err(UnsupportedExpression(body.body, pattern))
            }
            let child_patterns : Array[@semantic.PatternId] = []
            let child_values : Array[Array[@lib.Instruction]] = []
            for field_offset in 0..<pattern_fields.length {
              let pattern_field = lowering.pattern_fields[pattern_fields.start +
                field_offset]
              let mut selected : @semantic.PlannedWasmField? = None
              for physical_offset in 0..<physical.fields.length {
                let candidate = owner_plan.fields[physical.fields.start +
                  physical_offset]
                match candidate.role {
                  @semantic.WasmStructField(field) =>
                    match owner_plan.field_name_of(field) {
                      Some(name) if name == pattern_field.name &&
                        starshine_shape_matches_storage(
                          starshine_specialized_shape(
                            lowering,
                            generic_specialization,
                            lowering.patterns[pattern_field.pattern].type_,
                            lowering.patterns[pattern_field.pattern].shape,
                          ),
                          candidate.storage,
                        ) => selected = Some(candidate)
                      _ => ()
                    }
                  _ => ()
                }
              }
              let field = match selected {
                Some(value) => value
                None => return Err(UnsupportedExpression(body.body, pattern))
              }
              let loader = value.copy()
              loader.push(starshine_match_cast(type_index))
              loader.push(
                starshine_struct_get_instruction(
                  type_index,
                  field.physical_index,
                  field.storage,
                ),
              )
              child_patterns.push(pattern_field.pattern)
              child_values.push(loader)
            }
            tasks.push(FinishStarshinePatternAll(child_patterns.length()))
            let mut child = child_patterns.length()
            while child > 0 {
              child -= 1
              tasks.push(
                EmitStarshinePattern(child_patterns[child], child_values[child]),
              )
            }
          }
          @semantic.VariantInferredPatternConstructor(variant, _) => {
            let owner_module = match program {
              Some(link) =>
                link.module_lookup
                .get(@semantic.semantic_id_module(variant))
                .unwrap_or(program_module_index)
              None => program_module_index
            }
            let variant_plan = match program {
              Some(link) => link.modules[owner_module]
              None => planned
            }
            let declaration = match
              variant_plan.variant_declaration_of(variant) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, pattern))
            }
            let tag = match variant_plan.variant_tag_of(variant) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, pattern))
            }
            let base_type = match
              starshine_emitted_type_index(planned, program, declaration) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, pattern))
            }
            let expected_fields = match source.source {
              @semantic.HirQualifiedPattern(_, _, _)
              | @semantic.HirBindingPattern(_, _) => StarshineExpectedUnitFields
              @semantic.HirTuplePattern(_, arguments, _) => {
                let shapes : Array[@semantic.PlannedValueShape] = []
                for source_index in 0..<arguments.length {
                  let child = lowering.pattern_children[arguments.start +
                    source_index]
                  shapes.push(
                    starshine_specialized_shape(
                      lowering,
                      generic_specialization,
                      lowering.patterns[child].type_,
                      lowering.patterns[child].shape,
                    ),
                  )
                }
                StarshineExpectedTupleFields(shapes)
              }
              @semantic.HirStructPattern(_, pattern_fields, _, _, _) => {
                let field_ids : Array[@semantic.FieldId] = []
                let shapes : Array[@semantic.PlannedValueShape] = []
                for field_offset in 0..<pattern_fields.length {
                  let pattern_field = lowering.pattern_fields[pattern_fields.start +
                    field_offset]
                  let mut field_id = 0UL
                  for candidate in variant_plan.variant_fields_of(variant) {
                    match candidate.role {
                      @semantic.WasmStructPayloadField(value) =>
                        match variant_plan.field_name_of(value) {
                          Some(name) if name == pattern_field.name =>
                            field_id = value
                          _ => ()
                        }
                      _ => ()
                    }
                  }
                  if field_id == 0UL {
                    return Err(UnsupportedExpression(body.body, pattern))
                  }
                  field_ids.push(field_id)
                  shapes.push(
                    starshine_specialized_shape(
                      lowering,
                      generic_specialization,
                      lowering.patterns[pattern_field.pattern].type_,
                      lowering.patterns[pattern_field.pattern].shape,
                    ),
                  )
                }
                StarshineExpectedStructFields(field_ids, shapes)
              }
              _ => return Err(UnsupportedExpression(body.body, pattern))
            }
            let physical = match
              starshine_variant_payload_physical_type_for_fields(
                variant_plan, variant, expected_fields,
              ) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, pattern))
            }
            let physical_type = match program {
              Some(link) =>
                link.physical_type_index(owner_module, physical.type_index)
              None => physical.type_index
            }
            let child_patterns : Array[@semantic.PatternId] = []
            let child_values : Array[Array[@lib.Instruction]] = []
            match source.source {
              @semantic.HirQualifiedPattern(_, _, _)
              | @semantic.HirBindingPattern(_, _) => ()
              @semantic.HirTuplePattern(_, arguments, _) =>
                for field_offset in 1..<physical.fields.length {
                  let field = variant_plan.fields[physical.fields.start +
                    field_offset]
                  let source_index = match field.role {
                    @semantic.WasmTuplePayloadField(_, source_index) =>
                      source_index
                    _ => return Err(UnsupportedExpression(body.body, pattern))
                  }
                  let child = lowering.pattern_children[arguments.start +
                    source_index]
                  if starshine_shape_matches_storage(
                      starshine_specialized_shape(
                        lowering,
                        generic_specialization,
                        lowering.patterns[child].type_,
                        lowering.patterns[child].shape,
                      ),
                      field.storage,
                    ) {
                    let loader = value.copy()
                    loader.push(starshine_match_cast(physical_type))
                    loader.push(
                      starshine_struct_get_instruction(
                        physical_type,
                        field.physical_index,
                        field.storage,
                      ),
                    )
                    child_patterns.push(child)
                    child_values.push(loader)
                  }
                }
              @semantic.HirStructPattern(_, pattern_fields, _, _, _) =>
                for field_offset in 0..<pattern_fields.length {
                  let pattern_field = lowering.pattern_fields[pattern_fields.start +
                    field_offset]
                  let mut selected : @semantic.PlannedWasmField? = None
                  for physical_offset in 1..<physical.fields.length {
                    let candidate = variant_plan.fields[physical.fields.start +
                      physical_offset]
                    match candidate.role {
                      @semantic.WasmStructPayloadField(field) =>
                        match variant_plan.field_name_of(field) {
                          Some(name) if name == pattern_field.name &&
                            starshine_shape_matches_storage(
                              starshine_specialized_shape(
                                lowering,
                                generic_specialization,
                                lowering.patterns[pattern_field.pattern].type_,
                                lowering.patterns[pattern_field.pattern].shape,
                              ),
                              candidate.storage,
                            ) => selected = Some(candidate)
                          _ => ()
                        }
                      _ => ()
                    }
                  }
                  let field = match selected {
                    Some(value) => value
                    None =>
                      return Err(UnsupportedExpression(body.body, pattern))
                  }
                  let loader = value.copy()
                  loader.push(starshine_match_cast(physical_type))
                  loader.push(
                    starshine_struct_get_instruction(
                      physical_type,
                      field.physical_index,
                      field.storage,
                    ),
                  )
                  child_patterns.push(pattern_field.pattern)
                  child_values.push(loader)
                }
              _ => return Err(UnsupportedExpression(body.body, pattern))
            }
            tasks.push(
              FinishStarshineVariantPattern(
                value,
                base_type,
                tag,
                child_patterns.length(),
              ),
            )
            let mut child = child_patterns.length()
            while child > 0 {
              child -= 1
              tasks.push(
                EmitStarshinePattern(child_patterns[child], child_values[child]),
              )
            }
          }
          @semantic.ErrorInferredPatternConstructor =>
            return Err(UnsupportedExpression(body.body, pattern))
        }
      }
      FinishStarshinePatternAll(count) =>
        results.push(
          starshine_pattern_all(pop_starshine_fragments(results, count)),
        )
      FinishStarshinePatternAny(count) =>
        results.push(
          starshine_pattern_any(pop_starshine_fragments(results, count)),
        )
      FinishStarshineVariantPattern(value, base_type, tag, child_count) => {
        let children = starshine_pattern_all(
          pop_starshine_fragments(results, child_count),
        )
        let condition = value
        condition.push(starshine_match_cast(base_type))
        condition.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(base_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
        )
        condition.push(@lib.Instruction::i32_const(@lib.I32::new(tag)))
        condition.push(@lib.Instruction::i32_eq())
        condition.push(
          @lib.Instruction::if_(
            @lib.BlockType::val_type(@lib.ValType::i32()),
            children,
            Some([@lib.Instruction::i32_const(@lib.I32::new(0))]),
          ),
        )
        results.push(condition)
      }
    }
  }
  if results.length() != 1 {
    Err(UnsupportedExpression(body.body, root))
  } else {
    Ok((results[0], []))
  }
}

///|
fn starshine_simple_match_pattern_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  body : @semantic.PlannedBodyLowering,
  pattern : @semantic.PatternId,
  scratch_local : Int,
  local_indices : Array[Int],
  generic_specialization : StarshineGenericSpecialization?,
) -> Result[
  (Array[@lib.Instruction], Array[@lib.Instruction]),
  StarshineCodeEmissionError,
] {
  let source = lowering.patterns[pattern]
  let condition : Array[@lib.Instruction] = []
  let bindings : Array[@lib.Instruction] = []
  match source.source {
    @semantic.HirLiteralPattern(expression, _) =>
      return match
        starshine_match_literal_condition(
          lowering,
          planned,
          program,
          body,
          expression,
          [starshine_match_local_get(scratch_local)],
        ) {
        Ok(condition) => Ok((condition, bindings))
        Err(error) => Err(error)
      }
    _ => ()
  }
  let variant = match source.selected_constructor {
    @semantic.VariantInferredPatternConstructor(variant, _) => variant
    @semantic.NoInferredPatternConstructor => {
      condition.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
      match source.reference {
        @semantic.PatternBindingReference(local_id) => {
          if local_id < 0 ||
            local_id >= local_indices.length() ||
            local_indices[local_id] < 0 {
            return Err(InvalidLocal(body.body, local_id))
          }
          bindings.push(starshine_match_local_get(scratch_local))
          starshine_append_precise_nominal_local_cast(
            lowering, planned, program, body, local_id, -1, bindings,
          )
          bindings.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(local_indices[local_id].reinterpret_as_uint()),
            ),
          )
        }
        _ => ()
      }
      return Ok((condition, bindings))
    }
    _ => return Err(UnsupportedExpression(body.body, pattern))
  }
  let owner_module = match program {
    Some(link) =>
      link.module_lookup
      .get(@semantic.semantic_id_module(variant))
      .unwrap_or(program_module_index)
    None => program_module_index
  }
  let variant_plan = match program {
    Some(link) => link.modules[owner_module]
    None => planned
  }
  let declaration = match variant_plan.variant_declaration_of(variant) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body.body, pattern))
  }
  let tag = match variant_plan.variant_tag_of(variant) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body.body, pattern))
  }
  if source.shape is @semantic.I32PlannedValueShape {
    condition.push(starshine_match_local_get(scratch_local))
    condition.push(@lib.Instruction::i32_const(@lib.I32::new(tag)))
    condition.push(@lib.Instruction::i32_eq())
    return Ok((condition, bindings))
  }
  if source.shape is @semantic.I64PlannedValueShape {
    condition.push(starshine_match_local_get(scratch_local))
    condition.push(@lib.Instruction::i32_wrap_i64())
    condition.push(@lib.Instruction::i32_const(@lib.I32::new(tag)))
    condition.push(@lib.Instruction::i32_eq())
    match source.source {
      @semantic.HirQualifiedPattern(_, _, _)
      | @semantic.HirBindingPattern(_, _) => ()
      @semantic.HirTuplePattern(_, arguments, _) => {
        if arguments.length != 1 {
          return Err(UnsupportedExpression(body.body, pattern))
        }
        let child = lowering.pattern_children[arguments.start]
        let local_id = match lowering.patterns[child].reference {
          @semantic.PatternBindingReference(local_id) => local_id
          _ => return Ok((condition, bindings))
        }
        if local_id < 0 ||
          local_id >= local_indices.length() ||
          local_indices[local_id] < 0 {
          return Err(InvalidLocal(body.body, local_id))
        }
        bindings.push(starshine_match_local_get(scratch_local))
        bindings.push(@lib.Instruction::i64_const(@lib.I64::new(32L)))
        bindings.push(@lib.Instruction::i64_shr_u())
        bindings.push(@lib.Instruction::i32_wrap_i64())
        bindings.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(local_indices[local_id].reinterpret_as_uint()),
          ),
        )
      }
      _ => return Err(UnsupportedExpression(body.body, pattern))
    }
    return Ok((condition, bindings))
  }
  let base_type = match
    starshine_emitted_type_index(planned, program, declaration) {
    Some(value) => value
    None => return Err(UnsupportedExpression(body.body, pattern))
  }
  condition.push(starshine_match_local_get(scratch_local))
  condition.push(starshine_match_cast(base_type))
  condition.push(
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(base_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
  )
  condition.push(@lib.Instruction::i32_const(@lib.I32::new(tag)))
  condition.push(@lib.Instruction::i32_eq())
  match source.source {
    @semantic.HirQualifiedPattern(_, _, _)
    | @semantic.HirBindingPattern(_, _) => ()
    @semantic.HirTuplePattern(_, arguments, _) => {
      let expected_shapes : Array[@semantic.PlannedValueShape] = []
      for source_index in 0..<arguments.length {
        let child = lowering.pattern_children[arguments.start + source_index]
        expected_shapes.push(
          starshine_specialized_shape(
            lowering,
            generic_specialization,
            lowering.patterns[child].type_,
            lowering.patterns[child].shape,
          ),
        )
      }
      let physical = match
        starshine_variant_payload_physical_type_for_fields(
          variant_plan,
          variant,
          StarshineExpectedTupleFields(expected_shapes),
        ) {
        Some(value) => value
        None => return Err(UnsupportedExpression(body.body, pattern))
      }
      let physical_type = match program {
        Some(link) =>
          link.physical_type_index(owner_module, physical.type_index)
        None => physical.type_index
      }
      for field_offset in 1..<physical.fields.length {
        let field = variant_plan.fields[physical.fields.start + field_offset]
        let source_index = match field.role {
          @semantic.WasmTuplePayloadField(_, source_index) => source_index
          _ => return Err(UnsupportedExpression(body.body, pattern))
        }
        let child = lowering.pattern_children[arguments.start + source_index]
        let child_plan = lowering.patterns[child]
        let local_id = match child_plan.reference {
          @semantic.PatternBindingReference(local_id) => local_id
          _ => continue
        }
        let planned_local = lowering.locals[body.locals.start + local_id]
        if !starshine_shape_matches_storage(
            starshine_specialized_shape(
              lowering,
              generic_specialization,
              planned_local.type_,
              planned_local.shape,
            ),
            field.storage,
          ) {
          continue
        }
        if local_id < 0 ||
          local_id >= local_indices.length() ||
          local_indices[local_id] < 0 {
          return Err(InvalidLocal(body.body, local_id))
        }
        bindings.push(starshine_match_local_get(scratch_local))
        bindings.push(starshine_match_cast(physical_type))
        bindings.push(
          starshine_struct_get_instruction(
            physical_type,
            field.physical_index,
            field.storage,
          ),
        )
        starshine_append_precise_nominal_local_cast(
          lowering, planned, program, body, local_id, -1, bindings,
        )
        bindings.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(local_indices[local_id].reinterpret_as_uint()),
          ),
        )
      }
    }
    @semantic.HirStructPattern(_, pattern_fields, _, _, _) => {
      let expected_field_ids : Array[@semantic.FieldId] = []
      let expected_shapes : Array[@semantic.PlannedValueShape] = []
      for pattern_offset in 0..<pattern_fields.length {
        let pattern_field = lowering.pattern_fields[pattern_fields.start +
          pattern_offset]
        let mut field_id = 0UL
        for candidate in variant_plan.variant_fields_of(variant) {
          match candidate.role {
            @semantic.WasmStructPayloadField(value) =>
              match variant_plan.field_name_of(value) {
                Some(name) if name == pattern_field.name => field_id = value
                _ => ()
              }
            _ => ()
          }
        }
        if field_id == 0UL {
          return Err(UnsupportedExpression(body.body, pattern))
        }
        expected_field_ids.push(field_id)
        expected_shapes.push(
          starshine_specialized_shape(
            lowering,
            generic_specialization,
            lowering.patterns[pattern_field.pattern].type_,
            lowering.patterns[pattern_field.pattern].shape,
          ),
        )
      }
      let physical = match
        starshine_variant_payload_physical_type_for_fields(
          variant_plan,
          variant,
          StarshineExpectedStructFields(expected_field_ids, expected_shapes),
        ) {
        Some(value) => value
        None => return Err(UnsupportedExpression(body.body, pattern))
      }
      let physical_type = match program {
        Some(link) =>
          link.physical_type_index(owner_module, physical.type_index)
        None => physical.type_index
      }
      for pattern_offset in 0..<pattern_fields.length {
        let pattern_field = lowering.pattern_fields[pattern_fields.start +
          pattern_offset]
        let child_plan = lowering.patterns[pattern_field.pattern]
        let local_id = match child_plan.reference {
          @semantic.PatternBindingReference(local_id) => local_id
          _ => continue
        }
        let child_local = lowering.locals[body.locals.start + local_id]
        let child_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          child_local.type_,
          child_local.shape,
        )
        let mut selected_field : @semantic.PlannedWasmField? = None
        for physical_offset in 1..<physical.fields.length {
          let candidate = variant_plan.fields[physical.fields.start +
            physical_offset]
          match candidate.role {
            @semantic.WasmStructPayloadField(field) =>
              match variant_plan.field_name_of(field) {
                Some(name) =>
                  if name == pattern_field.name &&
                    starshine_shape_matches_storage(
                      child_shape,
                      candidate.storage,
                    ) {
                    selected_field = Some(candidate)
                  }
                None => ()
              }
            _ => ()
          }
        }
        let field = match selected_field {
          Some(field) => field
          None => return Err(UnsupportedExpression(body.body, pattern))
        }
        if local_id < 0 ||
          local_id >= local_indices.length() ||
          local_indices[local_id] < 0 {
          return Err(InvalidLocal(body.body, local_id))
        }
        bindings.push(starshine_match_local_get(scratch_local))
        bindings.push(starshine_match_cast(physical_type))
        bindings.push(
          starshine_struct_get_instruction(
            physical_type,
            field.physical_index,
            field.storage,
          ),
        )
        starshine_append_precise_nominal_local_cast(
          lowering, planned, program, body, local_id, -1, bindings,
        )
        bindings.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(local_indices[local_id].reinterpret_as_uint()),
          ),
        )
      }
    }
    _ => return Err(UnsupportedExpression(body.body, pattern))
  }
  Ok((condition, bindings))
}

///|
fn starshine_match_pattern_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  body : @semantic.PlannedBodyLowering,
  pattern : @semantic.PatternId,
  scratch_local : Int,
  product_ref_scratch : Int,
  local_indices : Array[Int],
  generic_specialization : StarshineGenericSpecialization?,
) -> Result[
  (Array[@lib.Instruction], Array[@lib.Instruction]),
  StarshineCodeEmissionError,
] {
  if starshine_pattern_uses_general_emission(lowering, pattern) {
    starshine_general_match_pattern_instructions(
      lowering, planned, program, program_module_index, body, pattern, scratch_local,
      product_ref_scratch, local_indices, generic_specialization,
    )
  } else {
    starshine_simple_match_pattern_instructions(
      lowering, planned, program, program_module_index, body, pattern, scratch_local,
      local_indices, generic_specialization,
    )
  }
}

///|
fn starshine_function_result_cast_type(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  local_signature : Int,
) -> Int {
  let mut result_type = None
  for candidate in planned.function_types {
    if candidate.signature_type_index == local_signature &&
      candidate.results.length == 1 {
      result_type = Some(planned.function_value_types[candidate.results.start])
      break
    }
  }
  match result_type {
    Some(@semantic.WasmNominalRefValue(local_type)) =>
      match program {
        Some(link) => link.physical_type_index(program_module_index, local_type)
        None => local_type
      }
    Some(@semantic.WasmExternalNominalRefValue(declaration)) =>
      match program {
        Some(link) => link.type_lookup.get(declaration).unwrap_or(-1)
        None => -1
      }
    Some(@semantic.WasmFunctionRefValue(local_type)) =>
      match program {
        Some(link) =>
          link.signature_type_index(program_module_index, local_type)
        None => local_type
      }
    _ => -1
  }
}

///|
fn starshine_program_expression_function_type_index(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink,
  program_module_index : Int,
  expression : @semantic.ExprId,
) -> Int {
  let type_ = lowering.expressions[expression].type_
  let resolved_type = if type_ < -1 {
    -type_ - 2
  } else if type_ >= 0 && type_ < lowering.types.length() {
    match lowering.types[type_] {
      @semantic.BodyResolvedType(value) => value
      _ => -1
    }
  } else {
    -1
  }
  if resolved_type < 0 ||
    resolved_type >= planned.function_type_by_resolved.length() {
    return -1
  }
  let local_type = planned.function_type_by_resolved[resolved_type]
  if local_type < 0 {
    return -1
  }
  program.signature_type_index(program_module_index, local_type)
}

///|
fn starshine_fixed_array_carrier_for_resolved(
  lowering : @semantic.PlannedModuleLowering,
  resolved_type : Int,
) -> Int {
  if resolved_type < 0 || resolved_type >= lowering.resolved_types.length() {
    return -1
  }
  match lowering.resolved_types[resolved_type] {
    @semantic.AppliedType(base, arguments) if arguments.length == 1 =>
      match lowering.resolved_types[base] {
        @semantic.NominalType(declaration) if lowering.raw_array_declarations.contains(
            declaration,
          ) =>
          @semantic.wasmgc_fixed_array_carrier_for_resolved_type(
            lowering.resolved_types,
            lowering.resolved_type_arguments[arguments.start],
          )
        _ => -1
      }
    _ => -1
  }
}

///|
fn starshine_body_value_type(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_type : @semantic.BodyTypeId,
  shape : @semantic.PlannedValueShape,
) -> @lib.ValType? {
  let resolved_type = if body_type < -1 {
    -body_type - 2
  } else if body_type >= 0 && body_type < lowering.types.length() {
    match lowering.types[body_type] {
      @semantic.BodyResolvedType(value) => value
      _ => -1
    }
  } else {
    -1
  }
  if resolved_type >= 0 && resolved_type < lowering.resolved_types.length() {
    match lowering.resolved_types[resolved_type] {
      @semantic.AppliedType(base, arguments) if arguments.length == 1 =>
        match lowering.resolved_types[base] {
          @semantic.NominalType(declaration) if declaration ==
            @semantic.standard_nullable_ref_type_declaration() => {
            let argument = lowering.resolved_type_arguments[arguments.start]
            match lowering.resolved_types[argument] {
              @semantic.NominalType(foreign_declaration) => {
                let emitted_type = if @semantic.semantic_id_module(
                    foreign_declaration,
                  ) ==
                  lowering.module_id {
                  match planned.type_index_of(foreign_declaration) {
                    Some(index) =>
                      match program {
                        Some(link) => {
                          let module_index = link.module_lookup
                            .get(lowering.module_id)
                            .unwrap()
                          link.physical_type_index(module_index, index)
                        }
                        None => index
                      }
                    None => -1
                  }
                } else {
                  match program {
                    Some(link) =>
                      match link.type_lookup.get(foreign_declaration) {
                        Some(index) => index
                        None => -1
                      }
                    None => -1
                  }
                }
                if emitted_type >= 0 {
                  return Some(
                    starshine_nullable_nominal_ref(
                      @lib.TypeIdx::new(emitted_type.reinterpret_as_uint()),
                    ),
                  )
                }
              }
              _ => ()
            }
          }
          _ => ()
        }
      _ => ()
    }
  }
  let fixed_carrier = starshine_fixed_array_carrier_for_resolved(
    lowering, resolved_type,
  )
  if fixed_carrier >= 0 {
    return Some(@lib.ValType::eqref_null())
  }
  if resolved_type >= 0 {
    if planned.closure_type_index >= 0 &&
      resolved_type < planned.closure_entry_type_by_resolved.length() &&
      planned.closure_entry_type_by_resolved[resolved_type] >= 0 {
      return Some(@lib.ValType::eqref_null())
    }
    if resolved_type < planned.function_type_by_resolved.length() {
      let local_type = planned.function_type_by_resolved[resolved_type]
      if local_type >= 0 {
        let emitted_type = match program {
          Some(link) => {
            let module_index = link.module_lookup
              .get(lowering.module_id)
              .unwrap()
            link.signature_type_index(module_index, local_type)
          }
          None => local_type
        }
        return Some(
          starshine_function_ref(
            @lib.TypeIdx::new(emitted_type.reinterpret_as_uint()),
          ),
        )
      }
    }
  }
  starshine_shape_value_type(shape)
}

///|
fn starshine_local_capture_cell_slot(
  lowering : @semantic.PlannedModuleLowering,
  body : @semantic.PlannedBodyLowering,
  local_id : Int,
) -> Int {
  if local_id < 0 || local_id >= body.locals.length {
    return -1
  }
  let local_info = lowering.locals[body.locals.start + local_id]
  if !local_info.mutable_ {
    return -1
  }
  for capture in lowering.captures {
    if !capture.mutable_ || lowering.lambdas[capture.lambda].elided {
      continue
    }
    let matches = match capture.source {
      @semantic.BodyLocalCapture(owner, source_local) =>
        local_info.lambda < 0 &&
        owner == local_info.body &&
        source_local == local_id
      @semantic.LambdaLocalCapture(owner, source_local) =>
        local_info.lambda == owner && source_local == local_id
    }
    if matches {
      return @semantic.wasmgc_capture_cell_slot(local_info.shape)
    }
  }
  -1
}

///|
fn starshine_capture_cell_type_index(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  module_index : Int,
  slot : Int,
) -> Int {
  if slot < 0 || slot >= planned.capture_cell_type_indices.length() {
    return -1
  }
  starshine_local_physical_type_index(
    program,
    module_index,
    planned.capture_cell_type_indices[slot],
  )
}

///|
priv enum StarshineLocalSlotCarrier {
  StarshineI32LocalSlot
  StarshineI64LocalSlot
  StarshineF32LocalSlot
  StarshineF64LocalSlot
  StarshineV128LocalSlot
  StarshineEqRefLocalSlot
  StarshineNominalRefLocalSlot(Int)
  StarshineGenericLocalSlot(@semantic.BodyTypeId)
  StarshineCaptureCellLocalSlot(Int)
  StarshineUniqueLocalSlot(Int)
} derive(Eq)

///|
priv struct StarshineLocalLiveRange {
  initializer : @semantic.ExprId
  last_read : @semantic.ExprId
  writes : Int
  declarations : Int
  captured : Bool
}

///|
fn starshine_body_has_linear_local_lifetimes(
  lowering : @semantic.PlannedModuleLowering,
  body : @semantic.PlannedBodyLowering,
) -> Bool {
  let block = match body.root {
    @semantic.BlockBodyRoot(block) => block
    @semantic.ExpressionBodyRoot(_) => return false
  }
  if block < 0 || block >= lowering.blocks.length() {
    return false
  }
  let expression_end = body.expressions.start + body.expressions.length
  let items = lowering.blocks[block].items
  let mut previous_root = body.expressions.start - 1
  for item in items.start..<(items.start + items.length) {
    let root = match lowering.block_items[item].kind {
      @semantic.PlannedLetItem(_, _, expression)
      | @semantic.PlannedExpressionItem(expression) => expression
      @semantic.PlannedElidedLetItem(_) => -1
    }
    if root >= 0 {
      if root < body.expressions.start ||
        root >= expression_end ||
        root <= previous_root {
        return false
      }
      previous_root = root
    }
  }
  for expression in body.expressions.start..<expression_end {
    match lowering.expressions[expression].kind {
      @semantic.PlannedBlockExpression(_)
      | @semantic.PlannedIfExpression(_, _, _)
      | @semantic.PlannedMatchExpression(_, _)
      | @semantic.PlannedWhileExpression(_, _, _)
      | @semantic.PlannedBreakExpression(_, _)
      | @semantic.PlannedContinueExpression(_, _) => return false
      _ => ()
    }
  }
  true
}

///|
fn starshine_body_local_live_ranges(
  lowering : @semantic.PlannedModuleLowering,
  body : @semantic.PlannedBodyLowering,
) -> Array[StarshineLocalLiveRange] {
  let ranges = Array::make(body.locals.length, {
    initializer: -1,
    last_read: -1,
    writes: 0,
    declarations: 0,
    captured: false,
  })
  let expression_positions = Array::make(body.expressions.length, -1)
  let expression_end = body.expressions.start + body.expressions.length
  let mut expression_cursor = body.expressions.start
  let mut position = 0
  match body.root {
    @semantic.BlockBodyRoot(block) if block >= 0 &&
      block < lowering.blocks.length() => {
      let items = lowering.blocks[block].items
      for item in items.start..<(items.start + items.length) {
        let root = match lowering.block_items[item].kind {
          @semantic.PlannedLetItem(local_id, _, initializer) if local_id >= 0 &&
            local_id < ranges.length() => {
            ranges[local_id] = {
              ..ranges[local_id],
              initializer: position,
              declarations: ranges[local_id].declarations + 1,
            }
            initializer
          }
          @semantic.PlannedLetItem(_, _, expression)
          | @semantic.PlannedExpressionItem(expression) => expression
          @semantic.PlannedElidedLetItem(_) => -1
        }
        if root >= expression_cursor && root < expression_end {
          for expression in expression_cursor..<=root {
            expression_positions[expression - body.expressions.start] = position
          }
          expression_cursor = root + 1
        }
        position += 1
      }
    }
    _ => ()
  }
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let expression_position = if expression >= body.expressions.start &&
      expression < expression_end {
      expression_positions[expression - body.expressions.start]
    } else {
      -1
    }
    match lowering.expressions[expression].kind {
      @semantic.PlannedLocalGet(local_id) if local_id >= 0 &&
        local_id < ranges.length() =>
        if expression_position < 0 {
          // Optimizer-synthesized children can sit outside source-root arena
          // order. An unmapped read makes this local ineligible rather than
          // allowing an underestimated lifetime.
          ranges[local_id] = {
            ..ranges[local_id],
            writes: ranges[local_id].writes + 1,
          }
        } else if expression_position > ranges[local_id].last_read {
          ranges[local_id] = {
            ..ranges[local_id],
            last_read: expression_position,
          }
        }
      @semantic.PlannedLocalSet(local_id, _) if local_id >= 0 &&
        local_id < ranges.length() =>
        ranges[local_id] = {
          ..ranges[local_id],
          writes: ranges[local_id].writes + 1,
        }
      _ => ()
    }
  }
  for capture in lowering.captures {
    match capture.source {
      @semantic.BodyLocalCapture(owner, local_id) if owner == body.body &&
        local_id >= 0 &&
        local_id < ranges.length() =>
        ranges[local_id] = { ..ranges[local_id], captured: true, }
      @semantic.LambdaLocalCapture(owner, local_id) if local_id >= 0 &&
        local_id < ranges.length() &&
        lowering.locals[body.locals.start + local_id].lambda == owner =>
        ranges[local_id] = { ..ranges[local_id], captured: true, }
      _ => ()
    }
  }
  ranges
}

///|
fn starshine_local_slot_carrier(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body : @semantic.PlannedBodyLowering,
  local_id : Int,
  cell_slot : Int,
) -> StarshineLocalSlotCarrier? {
  if local_id < 0 || local_id >= body.locals.length {
    return None
  }
  if cell_slot >= 0 {
    return Some(StarshineCaptureCellLocalSlot(cell_slot))
  }
  let planned_local = lowering.locals[body.locals.start + local_id]
  match planned_local.shape {
    @semantic.I8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape => Some(StarshineI32LocalSlot)
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape => Some(StarshineI64LocalSlot)
    @semantic.F32PlannedValueShape => Some(StarshineF32LocalSlot)
    @semantic.F64PlannedValueShape => Some(StarshineF64LocalSlot)
    @semantic.V128PlannedValueShape => Some(StarshineV128LocalSlot)
    @semantic.GenericPlannedValueShape =>
      Some(StarshineGenericLocalSlot(planned_local.type_))
    @semantic.RefPlannedValueShape =>
      match
        starshine_precise_nominal_local_type_index(
          lowering, planned, program, planned_local,
        ) {
        Some(type_index) => Some(StarshineNominalRefLocalSlot(type_index))
        None => Some(StarshineEqRefLocalSlot)
      }
    @semantic.ErrorPlannedValueShape
    | @semantic.ProductPlannedValueShape(_)
    | @semantic.UnitPlannedValueShape
    | @semantic.NeverPlannedValueShape => None
  }
}

///|
fn starshine_local_slot_types_are_compatible(
  carrier : StarshineLocalSlotCarrier,
  slot_carriers : Array[StarshineLocalSlotCarrier],
  slot : Int,
) -> Bool {
  slot >= 0 && slot < slot_carriers.length() && slot_carriers[slot] == carrier
}

///|
fn starshine_constructor_evaluations(
  lowering : @semantic.PlannedModuleLowering,
  kind : @semantic.PlannedExpressionKind,
) -> Array[@semantic.ExprId] {
  let values : Array[@semantic.ExprId] = []
  match kind {
    @semantic.PlannedStructNew(_, _, fields)
    | @semantic.PlannedVariantStructNew(_, _, fields) =>
      for index in 0..<fields.length {
        values.push(lowering.object_fields[fields.start + index].value)
      }
    @semantic.PlannedVariantTupleNew(_, _, arguments) =>
      for index in 0..<arguments.length {
        values.push(lowering.expression_children[arguments.start + index])
      }
    _ => ()
  }
  values
}

///|
fn starshine_body_locals(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  generic_specialization : StarshineGenericSpecialization?,
  body : @semantic.PlannedBodyLowering,
  leading_parameter_count : Int,
) -> (
  Array[Int],
  Array[@lib.ValType],
  Array[Int],
  Array[Int],
  Int,
  Int,
  Array[Int],
  Array[Int],
  Int,
  Int,
  Int,
  Int,
  Int,
  Int,
  Array[Int],
  Array[Int],
  Array[Int],
) {
  let local_indices = Array::make(body.locals.length, -1)
  let elided_locals = Array::make(body.locals.length, false)
  for block in body.blocks.start..<(body.blocks.start + body.blocks.length) {
    let items = lowering.blocks[block].items
    for item in items.start..<(items.start + items.length) {
      match lowering.block_items[item].kind {
        @semantic.PlannedElidedLetItem(local_id) if local_id >= 0 &&
          local_id < elided_locals.length() => elided_locals[local_id] = true
        _ => ()
      }
    }
  }
  let body_local_types : Array[@lib.ValType] = []
  let reuse_linear_local_slots = starshine_body_has_linear_local_lifetimes(
    lowering, body,
  )
  let local_live_ranges = starshine_body_local_live_ranges(lowering, body)
  let slot_carriers : Array[StarshineLocalSlotCarrier] = []
  let slot_last_uses : Array[Int] = []
  let slot_reusable : Array[Bool] = []
  let mut parameter_count = leading_parameter_count
  for local_id in 0..<body.locals.length {
    let planned_local = lowering.locals[body.locals.start + local_id]
    match planned_local.kind {
      @semantic.ParameterLocal => {
        let specialized_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          planned_local.type_,
          planned_local.shape,
        )
        match specialized_shape {
          @semantic.ProductPlannedValueShape(_) => {
            local_indices[local_id] = parameter_count
            parameter_count += starshine_shape_leaf_count(specialized_shape)
          }
          _ => {
            let parameter_type = if specialized_shape != planned_local.shape {
              starshine_shape_value_type(specialized_shape)
            } else {
              starshine_body_value_type(
                lowering,
                planned,
                program,
                planned_local.type_,
                planned_local.shape,
              )
            }
            match parameter_type {
              Some(_) => {
                local_indices[local_id] = parameter_count
                parameter_count += 1
              }
              None => ()
            }
          }
        }
      }
      @semantic.LetLocal | @semantic.PatternLocal => {
        if planned_local.elided || elided_locals[local_id] {
          continue
        }
        let cell_slot = starshine_local_capture_cell_slot(
          lowering, body, local_id,
        )
        let specialized_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          planned_local.type_,
          planned_local.shape,
        )
        if specialized_shape is @semantic.ProductPlannedValueShape(_) {
          local_indices[local_id] = parameter_count + body_local_types.length()
          let start = body_local_types.length()
          if cell_slot >= 0 {
            body_local_types.push(@lib.ValType::eqref_null())
            body_local_types.push(@lib.ValType::eqref_null())
          }
          starshine_append_shape_value_types(
            body_local_types, specialized_shape,
          )
          for _ in start..<body_local_types.length() {
            slot_carriers.push(StarshineUniqueLocalSlot(local_id))
            slot_last_uses.push(-1)
            slot_reusable.push(false)
          }
          continue
        }
        let local_type = if cell_slot >= 0 {
          Some(@lib.ValType::eqref_null())
        } else if !(specialized_shape is @semantic.RefPlannedValueShape) {
          starshine_shape_value_type(specialized_shape)
        } else {
          match
            starshine_precise_nominal_local_type_index(
              lowering, planned, program, planned_local,
            ) {
            Some(type_index) => {
              let heap_type = @lib.TypeIdx::new(
                type_index.reinterpret_as_uint(),
              )
              // Nested pattern tests bind locals inside condition frames.
              // A later arm cannot inherit non-null definite initialization
              // from those frames. Keep a defaultable slot and narrow at reads.
              Some(
                if planned_local.kind is @semantic.PatternLocal {
                  starshine_nullable_nominal_ref(heap_type)
                } else {
                  starshine_nominal_ref(heap_type)
                },
              )
            }
            None =>
              starshine_body_value_type(
                lowering,
                planned,
                program,
                planned_local.type_,
                planned_local.shape,
              )
          }
        }
        match local_type {
          Some(type_) => {
            let carrier = starshine_local_slot_carrier(
              lowering, planned, program, body, local_id, cell_slot,
            )
            let live_range = local_live_ranges[local_id]
            let reusable = reuse_linear_local_slots &&
              planned_local.kind is @semantic.LetLocal &&
              !planned_local.mutable_ &&
              cell_slot < 0 &&
              carrier is Some(_) &&
              live_range.declarations == 1 &&
              live_range.writes == 0 &&
              !live_range.captured &&
              live_range.initializer >= 0 &&
              live_range.last_read >= live_range.initializer
            let mut slot = -1
            if reusable {
              let carrier = carrier.unwrap()
              for candidate in 0..<body_local_types.length() {
                if slot_reusable[candidate] &&
                  slot_last_uses[candidate] <= live_range.initializer &&
                  starshine_local_slot_types_are_compatible(
                    carrier, slot_carriers, candidate,
                  ) {
                  slot = candidate
                  break
                }
              }
            }
            if slot < 0 {
              slot = body_local_types.length()
              body_local_types.push(type_)
              slot_carriers.push(
                match carrier {
                  Some(value) => value
                  None => StarshineUniqueLocalSlot(local_id)
                },
              )
              slot_last_uses.push(
                if live_range.last_read > live_range.initializer {
                  live_range.last_read
                } else {
                  live_range.initializer
                },
              )
              slot_reusable.push(reusable)
            } else {
              slot_last_uses[slot] = if live_range.last_read >
                live_range.initializer {
                live_range.last_read
              } else {
                live_range.initializer
              }
              slot_reusable[slot] = reusable
            }
            local_indices[local_id] = parameter_count + slot
          }
          None => ()
        }
      }
    }
  }
  let match_local_indices = Array::make(body.expressions.length, -1)
  let match_result_local_indices = Array::make(body.expressions.length, -1)
  let constructor_local_indices = Array::make(body.expressions.length, -1)
  let mut fixed_array_ref_scratch_index = -1
  let mut fixed_array_i32_scratch_index = -1
  let map_key_local_indices = Array::make(body.expressions.length, -1)
  let map_value_local_indices = Array::make(body.expressions.length, -1)
  let mut map_ref_scratch_index = -1
  let mut map_bucket_scratch_index = -1
  let mut map_hash_scratch_index = -1
  let mut map_entry_scratch_index = -1
  let mut map_previous_scratch_index = -1
  let mut map_growth_index_scratch_index = -1
  for
    pattern in body.patterns.start..<(body.patterns.start + body.patterns.length) {
    if lowering.patterns[pattern].shape is @semantic.ProductPlannedValueShape(_) {
      fixed_array_ref_scratch_index = parameter_count +
        body_local_types.length()
      body_local_types.push(@lib.ValType::eqref_null())
      break
    }
  }
  let mut maximum_control = -1
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match lowering.expressions[expression].kind {
      @semantic.PlannedWhileExpression(control, _, _) =>
        if control > maximum_control {
          maximum_control = control
        }
      _ => ()
    }
  }
  let control_state_local_indices = Array::make(maximum_control + 1, -1)
  let control_result_local_indices = Array::make(maximum_control + 1, -1)
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match lowering.expressions[expression].kind {
      @semantic.PlannedWhileExpression(control, initial, _) => {
        let state_source = lowering.expressions[initial]
        let state_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          state_source.type_,
          state_source.shape,
        )
        match state_shape {
          @semantic.ProductPlannedValueShape(_) => {
            control_state_local_indices[control] = parameter_count +
              body_local_types.length()
            starshine_append_shape_value_types(body_local_types, state_shape)
            if fixed_array_ref_scratch_index < 0 {
              fixed_array_ref_scratch_index = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::eqref_null())
            }
          }
          _ =>
            match
              starshine_body_value_type(
                lowering,
                planned,
                program,
                state_source.type_,
                state_shape,
              ) {
              Some(type_) => {
                control_state_local_indices[control] = parameter_count +
                  body_local_types.length()
                body_local_types.push(type_)
              }
              None => ()
            }
        }
        let result_source = lowering.expressions[expression]
        let result_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          result_source.type_,
          result_source.shape,
        )
        match result_shape {
          @semantic.ProductPlannedValueShape(_) => {
            control_result_local_indices[control] = parameter_count +
              body_local_types.length()
            starshine_append_shape_value_types(body_local_types, result_shape)
          }
          _ =>
            match
              starshine_body_value_type(
                lowering,
                planned,
                program,
                result_source.type_,
                result_shape,
              ) {
              Some(type_) => {
                control_result_local_indices[control] = parameter_count +
                  body_local_types.length()
                body_local_types.push(type_)
              }
              None => ()
            }
        }
      }
      @semantic.PlannedFunctionValueCall(_, _, _) => {
        if planned.closure_type_index >= 0 {
          match_local_indices[expression - body.expressions.start] = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        let result_source = lowering.expressions[expression]
        let result_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          result_source.type_,
          result_source.shape,
        )
        if result_shape is @semantic.ProductPlannedValueShape(_) {
          match_result_local_indices[expression - body.expressions.start] = parameter_count +
            body_local_types.length()
          starshine_append_shape_value_types(body_local_types, result_shape)
        }
      }
      @semantic.PlannedDynamicTraitCall(_, _, _, _, _, _) => {
        match_local_indices[expression - body.expressions.start] = parameter_count +
          body_local_types.length()
        body_local_types.push(@lib.ValType::eqref_null())
      }
      @semantic.PlannedIfExpression(_, _, _) => {
        let result_source = lowering.expressions[expression]
        let result_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          result_source.type_,
          result_source.shape,
        )
        if result_shape is @semantic.ProductPlannedValueShape(_) {
          match_result_local_indices[expression - body.expressions.start] = parameter_count +
            body_local_types.length()
          starshine_append_shape_value_types(body_local_types, result_shape)
        }
      }
      @semantic.PlannedMatchExpression(scrutinee, _) => {
        let scrutinee_source = lowering.expressions[scrutinee]
        let scrutinee_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          scrutinee_source.type_,
          scrutinee_source.shape,
        )
        let scratch_type = match scrutinee_shape {
          @semantic.ErrorPlannedValueShape => Some(@lib.ValType::eqref_null())
          shape => starshine_shape_value_type(shape)
        }
        match scratch_type {
          Some(type_) => {
            match_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        let result_source = lowering.expressions[expression]
        let result_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          result_source.type_,
          result_source.shape,
        )
        match result_shape {
          @semantic.ProductPlannedValueShape(_) => {
            match_result_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            starshine_append_shape_value_types(body_local_types, result_shape)
          }
          _ =>
            match starshine_shape_value_type(result_shape) {
              Some(type_) => {
                match_result_local_indices[expression - body.expressions.start] = parameter_count +
                  body_local_types.length()
                body_local_types.push(type_)
              }
              None => ()
            }
        }
      }
      @semantic.PlannedStructNew(_, _, fields)
      | @semantic.PlannedVariantStructNew(_, _, fields) =>
        for field_index in 0..<fields.length {
          let value = lowering.object_fields[fields.start + field_index].value
          let value_source = lowering.expressions[value]
          let value_shape = starshine_specialized_shape(
            lowering,
            generic_specialization,
            value_source.type_,
            value_source.shape,
          )
          if value_shape is @semantic.ProductPlannedValueShape(_) &&
            match_result_local_indices[value - body.expressions.start] < 0 {
            match_result_local_indices[value - body.expressions.start] = parameter_count +
              body_local_types.length()
            starshine_append_shape_value_types(body_local_types, value_shape)
          }
        }
      @semantic.PlannedVariantTupleNew(_, _, arguments) =>
        for argument_index in 0..<arguments.length {
          let value = lowering.expression_children[arguments.start +
            argument_index]
          let value_source = lowering.expressions[value]
          let value_shape = starshine_specialized_shape(
            lowering,
            generic_specialization,
            value_source.type_,
            value_source.shape,
          )
          if value_shape is @semantic.ProductPlannedValueShape(_) &&
            match_result_local_indices[value - body.expressions.start] < 0 {
            match_result_local_indices[value - body.expressions.start] = parameter_count +
              body_local_types.length()
            starshine_append_shape_value_types(body_local_types, value_shape)
          }
        }
      @semantic.PlannedFieldSet(_, _, value) => {
        let value_source = lowering.expressions[value]
        let value_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          value_source.type_,
          value_source.shape,
        )
        if value_shape is @semantic.ProductPlannedValueShape(_) &&
          match_result_local_indices[value - body.expressions.start] < 0 {
          match_result_local_indices[value - body.expressions.start] = parameter_count +
            body_local_types.length()
          starshine_append_shape_value_types(body_local_types, value_shape)
        }
      }
      @semantic.PlannedCaptureGet(_) | @semantic.PlannedModuleValueGet(_, _) =>
        if lowering.expressions[expression].shape
          is @semantic.ProductPlannedValueShape(_) &&
          fixed_array_ref_scratch_index < 0 {
          fixed_array_ref_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
      @semantic.PlannedFieldGet(field, _, _) => {
        let source = lowering.expressions[expression]
        let field_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          source.type_,
          source.shape,
        )
        let owner_module = match program {
          Some(link) =>
            link.module_lookup
            .get(@semantic.semantic_id_module(field))
            .unwrap_or(
              link.module_lookup
              .get(@semantic.semantic_id_module(body.body))
              .unwrap_or(0),
            )
          None => 0
        }
        let field_plan = match program {
          Some(link) => link.modules[owner_module]
          None => planned
        }
        if (
            field_shape is @semantic.ProductPlannedValueShape(_) ||
            starshine_field_locations(
              field_plan, program, owner_module, field, field_shape,
            ).length() >
            1
          ) &&
          fixed_array_ref_scratch_index < 0 {
          fixed_array_ref_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
      }
      @semantic.PlannedCaptureSet(_, value) => {
        let value_source = lowering.expressions[value]
        let value_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          value_source.type_,
          value_source.shape,
        )
        if value_shape is @semantic.ProductPlannedValueShape(_) {
          match_result_local_indices[expression - body.expressions.start] = parameter_count +
            body_local_types.length()
          starshine_append_shape_value_types(body_local_types, value_shape)
        }
      }
      @semantic.PlannedFixedArraySetUnchecked(_, _, value, _) => {
        let source = lowering.expressions[value]
        let shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          source.type_,
          source.shape,
        )
        if shape is @semantic.ProductPlannedValueShape(_) &&
          match_result_local_indices[value - body.expressions.start] < 0 {
          match_result_local_indices[value - body.expressions.start] = parameter_count +
            body_local_types.length()
          starshine_append_shape_value_types(body_local_types, shape)
        }
      }
      @semantic.PlannedFixedArrayGetUnchecked(_, _, shape) => {
        let element_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          lowering.expressions[expression].type_,
          shape,
        )
        if element_shape is @semantic.ProductPlannedValueShape(_) &&
          fixed_array_ref_scratch_index < 0 {
          fixed_array_ref_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
      }
      @semantic.PlannedFixedArrayMake(_, value, shape) => {
        let value_source = lowering.expressions[value]
        let element_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          value_source.type_,
          shape,
        )
        if element_shape is @semantic.ProductPlannedValueShape(_) &&
          match_result_local_indices[value - body.expressions.start] < 0 {
          match_result_local_indices[value - body.expressions.start] = parameter_count +
            body_local_types.length()
          starshine_append_shape_value_types(body_local_types, element_shape)
        }
        match starshine_array_storage_value_type(element_shape) {
          Some(type_) => {
            map_value_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        if fixed_array_i32_scratch_index < 0 {
          fixed_array_i32_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::i32())
        }
      }
      @semantic.PlannedStringArrayConst(values) =>
        if values.length() > 0 {
          map_key_local_indices[expression - body.expressions.start] = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
          map_value_local_indices[expression - body.expressions.start] = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
      @semantic.PlannedArrayLiteral(_, _, _)
      | @semantic.PlannedArrayWithCapacity(_, _, _)
      | @semantic.PlannedArrayGet(_, _, _, _)
      | @semantic.PlannedArrayGetUnchecked(_, _, _)
      | @semantic.PlannedArraySet(_, _, _, _)
      | @semantic.PlannedArraySetUnchecked(_, _, _, _)
      | @semantic.PlannedArrayPush(_, _, _)
      | @semantic.PlannedArrayPop(_, _, _)
      | @semantic.PlannedArrayMake(_, _, _, _)
      | @semantic.PlannedArrayReserve(_, _, _, _)
      | @semantic.PlannedArrayShrinkToFit(_, _, _)
      | @semantic.PlannedArrayTruncate(_, _, _, _)
      | @semantic.PlannedArrayCopy(_, _, _)
      | @semantic.PlannedArrayCopyWithin(_, _, _, _, _, _)
      | @semantic.PlannedArrayFill(_, _, _, _, _, _)
      | @semantic.PlannedArraySlice(_, _, _, _, _)
      | @semantic.PlannedArrayExtend(_, _, _, _)
      | @semantic.PlannedStackIsEmpty(_)
      | @semantic.PlannedStackPeek(_, _)
      | @semantic.PlannedQueueDequeue(_, _)
      | @semantic.PlannedQueuePeek(_, _)
      | @semantic.PlannedCircularBufferNew(_, _, _)
      | @semantic.PlannedCircularBufferNewZero(_)
      | @semantic.PlannedQueueRingEnqueue(_, _, _)
      | @semantic.PlannedDequeRingPushFront(_, _, _)
      | @semantic.PlannedCircularBufferCapacity(_, _)
      | @semantic.PlannedCircularBufferIsFull(_, _)
      | @semantic.PlannedCircularBufferPushBack(_, _, _)
      | @semantic.PlannedCircularBufferPopFront(_, _)
      | @semantic.PlannedCircularBufferPeekFront(_, _)
      | @semantic.PlannedCircularBufferClear(_, _)
      | @semantic.PlannedCircularBufferIter(_, _)
      | @semantic.PlannedCircularBufferIterHasNext(_)
      | @semantic.PlannedCircularBufferIterNext(_, _)
      | @semantic.PlannedCircularBufferPushFront(_, _, _)
      | @semantic.PlannedCircularBufferPopBack(_, _)
      | @semantic.PlannedCircularBufferPeekBack(_, _)
      | @semantic.PlannedArrayClear(_, _, _)
      | @semantic.PlannedArrayIterHasNext(_)
      | @semantic.PlannedArrayIterNext(_, _)
      | @semantic.PlannedArrayIterNextOption(_, _, _) => {
        if fixed_array_ref_scratch_index < 0 {
          fixed_array_ref_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if fixed_array_i32_scratch_index < 0 {
          fixed_array_i32_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::i32())
        }
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        match lowering.expressions[expression].kind {
          @semantic.PlannedArrayLiteral(elements, element_type, shape) =>
            if elements.length > 0 {
              map_key_local_indices[expression - body.expressions.start] = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::eqref_null())
              let element_shape = starshine_specialized_shape(
                lowering, generic_specialization, element_type, shape,
              )
              match element_shape {
                @semantic.ProductPlannedValueShape(_) => {
                  map_value_local_indices[expression - body.expressions.start] = parameter_count +
                    body_local_types.length()
                  body_local_types.push(@lib.ValType::eqref_null())
                  match_result_local_indices[expression - body.expressions.start] = parameter_count +
                    body_local_types.length()
                  starshine_append_shape_value_types(
                    body_local_types, element_shape,
                  )
                }
                _ =>
                  match starshine_array_storage_value_type(element_shape) {
                    Some(type_) => {
                      map_value_local_indices[expression -
                      body.expressions.start] = parameter_count +
                        body_local_types.length()
                      body_local_types.push(type_)
                    }
                    None => ()
                  }
              }
            }
          @semantic.PlannedArraySlice(_, _, _, _, _) => {
            map_value_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(@lib.ValType::i32())
          }
          @semantic.PlannedArrayExtend(_, _, _, _) => {
            map_value_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(@lib.ValType::eqref_null())
          }
          @semantic.PlannedArrayCopyWithin(_, _, _, _, _, _) => {
            map_key_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(@lib.ValType::i32())
            map_value_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(@lib.ValType::i32())
          }
          @semantic.PlannedArraySet(_, _, value, shape)
          | @semantic.PlannedArraySetUnchecked(_, _, value, shape)
          | @semantic.PlannedArrayPush(_, value, shape)
          | @semantic.PlannedArrayMake(_, value, _, shape) => {
            let value_source = lowering.expressions[value]
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              value_source.type_,
              shape,
            )
            match starshine_array_storage_value_type(element_shape) {
              Some(type_) => {
                map_value_local_indices[expression - body.expressions.start] = parameter_count +
                  body_local_types.length()
                body_local_types.push(type_)
              }
              None => ()
            }
          }
          @semantic.PlannedArrayFill(_, value, _, _, _, shape) => {
            map_key_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(@lib.ValType::i32())
            let value_source = lowering.expressions[value]
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              value_source.type_,
              shape,
            )
            match starshine_array_storage_value_type(element_shape) {
              Some(type_) => {
                map_value_local_indices[expression - body.expressions.start] = parameter_count +
                  body_local_types.length()
                body_local_types.push(type_)
              }
              None => ()
            }
          }
          @semantic.PlannedArrayPop(_, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            match starshine_array_storage_value_type(element_shape) {
              Some(type_) => {
                map_value_local_indices[expression - body.expressions.start] = parameter_count +
                  body_local_types.length()
                body_local_types.push(type_)
              }
              None => ()
            }
          }
          @semantic.PlannedStackPeek(_, shape)
          | @semantic.PlannedQueueDequeue(_, shape)
          | @semantic.PlannedQueuePeek(_, shape)
          | @semantic.PlannedCircularBufferPushBack(_, _, shape)
          | @semantic.PlannedQueueRingEnqueue(_, _, shape)
          | @semantic.PlannedDequeRingPushFront(_, _, shape)
          | @semantic.PlannedCircularBufferPopFront(_, shape)
          | @semantic.PlannedCircularBufferPeekFront(_, shape)
          | @semantic.PlannedCircularBufferIterNext(_, shape)
          | @semantic.PlannedCircularBufferPushFront(_, _, shape)
          | @semantic.PlannedCircularBufferPopBack(_, shape)
          | @semantic.PlannedCircularBufferPeekBack(_, shape) =>
            match starshine_shape_value_type(shape) {
              Some(type_) => {
                map_value_local_indices[expression - body.expressions.start] = parameter_count +
                  body_local_types.length()
                body_local_types.push(type_)
              }
              None => ()
            }
          _ => ()
        }
      }
      @semantic.PlannedMapKeys(_, _, _)
      | @semantic.PlannedMapValues(_, _, _)
      | @semantic.PlannedMapEntries(_, _, _)
      | @semantic.PlannedMapIterHasNext(_, _, _, _)
      | @semantic.PlannedMapKeyIterNext(_, _, _)
      | @semantic.PlannedMapKeyIterNextOption(_, _, _)
      | @semantic.PlannedMapValueIterNext(_, _, _)
      | @semantic.PlannedMapValueIterNextOption(_, _, _)
      | @semantic.PlannedMapEntryIterNext(_, _, _)
      | @semantic.PlannedMapEntryIterNextOption(_, _, _)
      | @semantic.PlannedMapEntryKey(_, _, _)
      | @semantic.PlannedMapEntryValue(_, _, _)
      | @semantic.PlannedSetIter(_, _)
      | @semantic.PlannedSetIterHasNext(_, _)
      | @semantic.PlannedSetIterNext(_, _)
      | @semantic.PlannedSetIterNextOption(_, _) => {
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_bucket_scratch_index < 0 {
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_entry_scratch_index < 0 {
          map_entry_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_growth_index_scratch_index < 0 {
          map_growth_index_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::i32())
        }
      }
      @semantic.PlannedMapSingleton(_, _, key_shape, value_shape, _, _)
      | @semantic.PlannedMapInsert(_, _, _, key_shape, value_shape, _, _)
      | @semantic.PlannedMapSet(_, _, _, key_shape, value_shape, _, _) => {
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_bucket_scratch_index < 0 {
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_hash_scratch_index < 0 {
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
        }
        if map_entry_scratch_index < 0 {
          map_entry_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        match lowering.expressions[expression].kind {
          @semantic.PlannedMapInsert(_, _, _, _, _, _, _)
          | @semantic.PlannedMapSet(_, _, _, _, _, _, _) => {
            if map_previous_scratch_index < 0 {
              map_previous_scratch_index = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::eqref_null())
            }
            if map_growth_index_scratch_index < 0 {
              map_growth_index_scratch_index = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::i32())
            }
          }
          _ => ()
        }
        match starshine_shape_value_type(key_shape) {
          Some(type_) => {
            map_key_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        match starshine_shape_value_type(value_shape) {
          Some(type_) => {
            map_value_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
      @semantic.PlannedMapGet(_, _, key_shape, value_shape, _, _)
      | @semantic.PlannedMapGetUnchecked(_, _, key_shape, value_shape, _, _) => {
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_bucket_scratch_index < 0 {
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_hash_scratch_index < 0 {
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
        }
        if map_entry_scratch_index < 0 {
          map_entry_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        match starshine_shape_value_type(key_shape) {
          Some(type_) => {
            map_key_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        match starshine_shape_value_type(value_shape) {
          Some(type_) => {
            map_value_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
      @semantic.PlannedMapContainsKey(_, _, key_shape, _, _)
      | @semantic.PlannedMapRemove(_, _, key_shape, _, _) => {
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_bucket_scratch_index < 0 {
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_hash_scratch_index < 0 {
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
        }
        if map_entry_scratch_index < 0 {
          map_entry_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        match lowering.expressions[expression].kind {
          @semantic.PlannedMapRemove(_, _, _, _, _) =>
            if map_previous_scratch_index < 0 {
              map_previous_scratch_index = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::eqref_null())
            }
          _ => ()
        }
        match starshine_shape_value_type(key_shape) {
          Some(type_) => {
            map_key_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
      @semantic.PlannedMapClear(_) | @semantic.PlannedSetClear(_) =>
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
      @semantic.PlannedSetSingleton(_, key_shape, _, _)
      | @semantic.PlannedSetContains(_, _, key_shape, _, _)
      | @semantic.PlannedSetInsert(_, _, key_shape, _, _)
      | @semantic.PlannedSetRemove(_, _, key_shape, _, _) => {
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_bucket_scratch_index < 0 {
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        if map_hash_scratch_index < 0 {
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
        }
        if map_entry_scratch_index < 0 {
          map_entry_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        match lowering.expressions[expression].kind {
          @semantic.PlannedSetInsert(_, _, _, _, _) => {
            if map_previous_scratch_index < 0 {
              map_previous_scratch_index = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::eqref_null())
            }
            if map_growth_index_scratch_index < 0 {
              map_growth_index_scratch_index = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::i32())
            }
          }
          @semantic.PlannedSetRemove(_, _, _, _, _) =>
            if map_previous_scratch_index < 0 {
              map_previous_scratch_index = parameter_count +
                body_local_types.length()
              body_local_types.push(@lib.ValType::eqref_null())
            }
          _ => ()
        }
        match starshine_shape_value_type(key_shape) {
          Some(type_) => {
            map_key_local_indices[expression - body.expressions.start] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
      _ => ()
    }
  }
  // Constructor evaluations have their own slots. Physical field order must
  // not change source evaluation order, and erased fields still execute.
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    for
      value in starshine_constructor_evaluations(
        lowering,
        lowering.expressions[expression].kind,
      ) {
      let source = lowering.expressions[value]
      let shape = starshine_specialized_shape(
        lowering,
        generic_specialization,
        source.type_,
        source.shape,
      )
      let slot = value - body.expressions.start
      if constructor_local_indices[slot] < 0 {
        let storage_type = match shape {
          @semantic.ProductPlannedValueShape(_) =>
            Some(@lib.ValType::eqref_null())
          _ => starshine_shape_value_type(shape)
        }
        match storage_type {
          Some(type_) => {
            constructor_local_indices[slot] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
    }
  }
  (
    local_indices, body_local_types, match_local_indices, match_result_local_indices,
    fixed_array_ref_scratch_index, fixed_array_i32_scratch_index, map_key_local_indices,
    map_value_local_indices, map_ref_scratch_index, map_bucket_scratch_index, map_hash_scratch_index,
    map_entry_scratch_index, map_previous_scratch_index, map_growth_index_scratch_index,
    control_state_local_indices, control_result_local_indices, constructor_local_indices,
  )
}

///|
fn starshine_value_carrier(shape : @semantic.PlannedValueShape) -> Int {
  match shape {
    @semantic.I8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape => 0
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape => 1
    @semantic.F32PlannedValueShape => 2
    @semantic.F64PlannedValueShape => 3
    @semantic.V128PlannedValueShape => 4
    @semantic.RefPlannedValueShape
    | @semantic.GenericPlannedValueShape
    | @semantic.ProductPlannedValueShape(_) => 5
    _ => -1
  }
}

///|
fn starshine_fixed_array_carrier(shape : @semantic.PlannedValueShape) -> Int {
  match shape {
    @semantic.I8PlannedValueShape | @semantic.U8PlannedValueShape => 6
    @semantic.I16PlannedValueShape | @semantic.U16PlannedValueShape => 7
    _ => starshine_value_carrier(shape)
  }
}

///|
fn starshine_fixed_array_get_instruction(
  shape : @semantic.PlannedValueShape,
  array_type : Int,
) -> @lib.Instruction {
  let type_index = @lib.TypeIdx::new(array_type.reinterpret_as_uint())
  match shape {
    @semantic.I8PlannedValueShape | @semantic.I16PlannedValueShape =>
      @lib.Instruction::array_get_s(type_index)
    @semantic.U8PlannedValueShape | @semantic.U16PlannedValueShape =>
      @lib.Instruction::array_get_u(type_index)
    _ => @lib.Instruction::array_get(type_index)
  }
}

///|
fn starshine_program_uses_text_runtime(
  program : @semantic.PlannedProgramWasmGCLink,
) -> Bool {
  for module_ in program.modules {
    if module_.uses_text_runtime {
      return true
    }
  }
  false
}

///|
fn starshine_fixed_array_base_for_body(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
) -> Int {
  match program {
    Some(link) => link.fixed_array_type_base
    None => starshine_fixed_array_runtime_base(planned)
  }
}

///|
fn starshine_map_base_for_body(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
) -> Int {
  match program {
    Some(link) =>
      link.type_count +
      (if starshine_program_uses_text_runtime(link) { 6 } else { 0 })
    None => starshine_map_runtime_base(planned)
  }
}

///|
fn starshine_map_entry_field(
  shape : @semantic.PlannedValueShape,
  value : Bool,
) -> Int {
  let carrier = starshine_value_carrier(shape)
  if carrier < 0 {
    -1
  } else if value {
    8 + carrier
  } else {
    2 + carrier
  }
}

///|
fn starshine_map_entry_get(entry_type : Int, field : Int) -> @lib.Instruction {
  @lib.Instruction::struct_get(
    @lib.TypeIdx::new(entry_type.reinterpret_as_uint()),
    @lib.U32::new(field.reinterpret_as_uint()),
  )
}

///|
fn starshine_map_entry_set(entry_type : Int, field : Int) -> @lib.Instruction {
  @lib.Instruction::struct_set(
    @lib.TypeIdx::new(entry_type.reinterpret_as_uint()),
    @lib.U32::new(field.reinterpret_as_uint()),
  )
}

///|
fn starshine_map_new_entry_instructions(
  entry_type : Int,
  next : Array[@lib.Instruction],
  key_shape : @semantic.PlannedValueShape,
  value_shape : @semantic.PlannedValueShape,
  key_local : Int,
  value_local : Int,
  hash_local : Int,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  append_starshine_instructions(output, next)
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
    ),
  )
  let key_carrier = starshine_value_carrier(key_shape)
  let value_carrier = starshine_value_carrier(value_shape)
  for carrier in 0..<6 {
    if carrier == key_carrier {
      output.push(
        @lib.Instruction::local_get(
          @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
        ),
      )
    } else {
      match carrier {
        0 => output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
        1 => output.push(@lib.Instruction::i64_const(@lib.I64::new(0L)))
        2 => output.push(@lib.Instruction::f32_const(@lib.F32::new(0.0)))
        3 => output.push(@lib.Instruction::f64_const(@lib.F64::new(0.0)))
        4 =>
          output.push(
            @lib.Instruction::v128_const(
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            ),
          )
        _ =>
          output.push(
            @lib.Instruction::ref_null(
              @lib.HeapType::abs(@lib.AbsHeapType::eq()),
            ),
          )
      }
    }
  }
  for carrier in 0..<6 {
    if carrier == value_carrier {
      output.push(
        @lib.Instruction::local_get(
          @lib.LocalIdx::new(value_local.reinterpret_as_uint()),
        ),
      )
    } else {
      match carrier {
        0 => output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
        1 => output.push(@lib.Instruction::i64_const(@lib.I64::new(0L)))
        2 => output.push(@lib.Instruction::f32_const(@lib.F32::new(0.0)))
        3 => output.push(@lib.Instruction::f64_const(@lib.F64::new(0.0)))
        4 =>
          output.push(
            @lib.Instruction::v128_const(
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            ),
          )
        _ =>
          output.push(
            @lib.Instruction::ref_null(
              @lib.HeapType::abs(@lib.AbsHeapType::eq()),
            ),
          )
      }
    }
  }
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(entry_type.reinterpret_as_uint()),
    ),
  )
  output
}

///|
fn starshine_set_new_entry_instructions(
  entry_type : Int,
  next : Array[@lib.Instruction],
  key_shape : @semantic.PlannedValueShape,
  key_local : Int,
  hash_local : Int,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  append_starshine_instructions(output, next)
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
    ),
  )
  let key_carrier = starshine_value_carrier(key_shape)
  for carrier in 0..<6 {
    if carrier == key_carrier {
      output.push(
        @lib.Instruction::local_get(
          @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
        ),
      )
    } else {
      match carrier {
        0 => output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
        1 => output.push(@lib.Instruction::i64_const(@lib.I64::new(0L)))
        2 => output.push(@lib.Instruction::f32_const(@lib.F32::new(0.0)))
        3 => output.push(@lib.Instruction::f64_const(@lib.F64::new(0.0)))
        4 =>
          output.push(
            @lib.Instruction::v128_const(
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            ),
          )
        _ =>
          output.push(
            @lib.Instruction::ref_null(
              @lib.HeapType::abs(@lib.AbsHeapType::eq()),
            ),
          )
      }
    }
  }
  output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  output.push(@lib.Instruction::i64_const(@lib.I64::new(0L)))
  output.push(@lib.Instruction::f32_const(@lib.F32::new(0.0)))
  output.push(@lib.Instruction::f64_const(@lib.F64::new(0.0)))
  output.push(
    @lib.Instruction::v128_const(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
  )
  output.push(
    @lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq())),
  )
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(entry_type.reinterpret_as_uint()),
    ),
  )
  output
}

///|
fn starshine_hash_table_growth_instructions(
  wrapper_type : Int,
  bucket_type : Int,
  entry_type : Int,
  wrapper_local : Int,
  bucket_local : Int,
  entry_local : Int,
  next_local : Int,
  index_local : Int,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
    ),
  )
  output.push(starshine_match_cast(bucket_type))
  output.push(@lib.Instruction::array_len())
  output.push(
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
  )
  // A missing-key insertion grows only when prospective length exceeds
  // bucket count. The measured maximum load factor is therefore 1.0.
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(wrapper_local.reinterpret_as_uint()),
    ),
  )
  output.push(starshine_match_cast(wrapper_type))
  output.push(
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(1U),
    ),
  )
  output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  output.push(@lib.Instruction::i32_add())
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
  )
  output.push(@lib.Instruction::i32_gt_u())
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
  )
  output.push(@lib.Instruction::i32_const(@lib.I32::new(0x40000000)))
  output.push(@lib.Instruction::i32_lt_u())
  output.push(@lib.Instruction::i32_and())
  let grow : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(wrapper_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(wrapper_type),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::i32_const(@lib.I32::new(1)),
    @lib.Instruction::i32_shl(),
    @lib.Instruction::array_new_default(
      @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
    ),
    @lib.Instruction::struct_set(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
    @lib.Instruction::i32_const(@lib.I32::new(0)),
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
  ]
  let outer_loop : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(bucket_type),
    @lib.Instruction::array_len(),
    @lib.Instruction::i32_ge_u(),
    @lib.Instruction::br_if(@lib.LabelIdx::new(1U)),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(bucket_type),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
    ),
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
  ]
  // Save the old link before relinking the entry into the new table. Bucket
  // selection reads field 1's stored U64 hash and never dispatches user Hash.
  let inner_loop : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::ref_is_null(),
    @lib.Instruction::br_if(@lib.LabelIdx::new(1U)),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(entry_type),
    starshine_map_entry_get(entry_type, 0),
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(next_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(entry_type),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(wrapper_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(wrapper_type),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
    starshine_match_cast(bucket_type),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(entry_type),
    starshine_map_entry_get(entry_type, 1),
    @lib.Instruction::i32_wrap_i64(),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(wrapper_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(wrapper_type),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
    starshine_match_cast(bucket_type),
    @lib.Instruction::array_len(),
    @lib.Instruction::i32_const(@lib.I32::new(1)),
    @lib.Instruction::i32_sub(),
    @lib.Instruction::i32_and(),
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
    ),
    starshine_map_entry_set(entry_type, 0),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(wrapper_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(wrapper_type),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
    starshine_match_cast(bucket_type),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(entry_type),
    starshine_map_entry_get(entry_type, 1),
    @lib.Instruction::i32_wrap_i64(),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(wrapper_local.reinterpret_as_uint()),
    ),
    starshine_match_cast(wrapper_type),
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
    starshine_match_cast(bucket_type),
    @lib.Instruction::array_len(),
    @lib.Instruction::i32_const(@lib.I32::new(1)),
    @lib.Instruction::i32_sub(),
    @lib.Instruction::i32_and(),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
    ),
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(next_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
    ),
    @lib.Instruction::br(@lib.LabelIdx::new(0U)),
  ]
  outer_loop.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(inner_loop),
        ),
      ]),
    ),
  )
  outer_loop.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
  )
  outer_loop.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  outer_loop.push(@lib.Instruction::i32_add())
  outer_loop.push(
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(index_local.reinterpret_as_uint()),
    ),
  )
  outer_loop.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  grow.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(outer_loop),
        ),
      ]),
    ),
  )
  grow.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(wrapper_local.reinterpret_as_uint()),
    ),
  )
  grow.push(starshine_match_cast(wrapper_type))
  grow.push(
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
      @lib.U32::new(0U),
    ),
  )
  grow.push(starshine_match_cast(bucket_type))
  grow.push(
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
    ),
  )
  output.push(@lib.Instruction::if_(@lib.BlockType::void_(), grow, None))
  output
}

///|
fn starshine_map_call(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  declaration : @semantic.DeclId,
  arguments : Array[Array[@lib.Instruction]],
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  match program {
    Some(link) =>
      starshine_finish_program_call(
        None,
        link,
        planned,
        0UL,
        -1,
        declaration,
        None,
        None,
        arguments,
        false,
      )
    None => starshine_finish_call(planned, declaration, arguments, false)
  }
}

///|
fn starshine_fixed_array_backing_prefix(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  shape : @semantic.PlannedValueShape,
) -> (Array[@lib.Instruction], Int)? {
  let carrier = @semantic.wasmgc_raw_array_storage_carrier(shape)
  guard carrier >= 0 else { return None }
  let array_type = starshine_fixed_array_base_for_body(planned, program) +
    carrier
  Some(([starshine_match_cast(array_type)], array_type))
}

///|
fn starshine_local_physical_type_index(
  program : @semantic.PlannedProgramWasmGCLink?,
  module_index : Int,
  local_type_index : Int,
) -> Int {
  match program {
    Some(link) => link.physical_type_index(module_index, local_type_index)
    None => local_type_index
  }
}

///|
fn starshine_capture_get_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  module_index : Int,
  lambda : @semantic.LambdaId,
  capture : Int,
) -> Array[@lib.Instruction] {
  let lambda_info = lowering.lambdas[lambda]
  let global_capture = lambda_info.captures.start + capture
  if lowering.lambdas[lambda].directized {
    let parameter = planned.lambda_capture_parameter_indices[global_capture]
    if parameter < 0 {
      return []
    }
    let output = [
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(parameter.reinterpret_as_uint()),
      ),
    ]
    let capture_plan = lowering.captures[global_capture]
    if capture_plan.mutable_ {
      let slot = @semantic.wasmgc_capture_cell_slot(capture_plan.shape)
      let cell_type = starshine_capture_cell_type_index(
        planned, program, module_index, slot,
      )
      output.push(starshine_match_cast(cell_type))
      output.push(
        starshine_struct_get_instruction(
          cell_type,
          0,
          @semantic.wasmgc_capture_cell_storage(slot),
        ),
      )
    }
    if capture_plan.nominal != 0UL {
      match
        starshine_emitted_type_index(planned, program, capture_plan.nominal) {
        Some(type_index) => output.push(starshine_match_cast(type_index))
        None => ()
      }
    }
    return output
  }
  let field_index = planned.lambda_capture_field_indices[global_capture]
  if field_index < 0 {
    return []
  }
  let lambda_closure_type = starshine_local_physical_type_index(
    program,
    module_index,
    planned.lambda_closure_type_indices[lambda],
  )
  let field = planned.fields[planned.physical_types[planned.lambda_closure_type_indices[lambda]].fields.start +
    field_index]
  let output = [
    @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
    starshine_match_cast(lambda_closure_type),
    starshine_struct_get_instruction(
      lambda_closure_type,
      field_index,
      field.storage,
    ),
  ]
  let capture_plan = lowering.captures[global_capture]
  if capture_plan.mutable_ {
    let slot = @semantic.wasmgc_capture_cell_slot(capture_plan.shape)
    let cell_type = starshine_capture_cell_type_index(
      planned, program, module_index, slot,
    )
    output.push(starshine_match_cast(cell_type))
    output.push(
      starshine_struct_get_instruction(
        cell_type,
        0,
        @semantic.wasmgc_capture_cell_storage(slot),
      ),
    )
  }
  if capture_plan.nominal != 0UL {
    match starshine_emitted_type_index(planned, program, capture_plan.nominal) {
      Some(type_index) => output.push(starshine_match_cast(type_index))
      None => ()
    }
  }
  output
}

///|
fn starshine_capture_cell_reference_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  module_index : Int,
  lambda : @semantic.LambdaId,
  capture : Int,
) -> Array[@lib.Instruction] {
  let global_capture = lowering.lambdas[lambda].captures.start + capture
  if lowering.lambdas[lambda].directized {
    let parameter = planned.lambda_capture_parameter_indices[global_capture]
    if parameter < 0 {
      return []
    }
    return [
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(parameter.reinterpret_as_uint()),
      ),
    ]
  }
  let field_index = planned.lambda_capture_field_indices[global_capture]
  if field_index < 0 {
    return []
  }
  let local_type = planned.lambda_closure_type_indices[lambda]
  let closure_type = starshine_local_physical_type_index(
    program, module_index, local_type,
  )
  let field = planned.fields[planned.physical_types[local_type].fields.start +
    field_index]
  [
    @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
    starshine_match_cast(closure_type),
    starshine_struct_get_instruction(closure_type, field_index, field.storage),
  ]
}

///|
fn starshine_product_box_from_locals(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_id : @semantic.BodyId,
  first_local : Int,
  shape : @semantic.PlannedValueShape,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let leaves : Array[@semantic.PlannedValueShape] = []
  starshine_product_leaf_shapes(shape, leaves)
  let output : Array[@lib.Instruction] = []
  for index, leaf in leaves {
    output.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new((first_local + index).reinterpret_as_uint()),
      ),
    )
    let slot = starshine_product_box_slot(leaf)
    if slot >= 0 {
      let erased_type = match program {
        Some(link) if slot < link.erased_box_type_indices.length() =>
          link.erased_box_type_indices[slot]
        _ => -1
      }
      if erased_type < 0 {
        return Err(UnsupportedExpression(body_id, -422))
      }
      output.push(
        @lib.Instruction::struct_new(
          @lib.TypeIdx::new(erased_type.reinterpret_as_uint()),
        ),
      )
    }
  }
  let box_type = starshine_fixed_array_base_for_body(planned, program) + 5
  output.push(
    @lib.Instruction::array_new_fixed(
      @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
      @lib.U32::new(leaves.length().reinterpret_as_uint()),
    ),
  )
  Ok(output)
}

///|
fn starshine_capture_source_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  module_index : Int,
  current_lambda : @semantic.LambdaId,
  source : @semantic.LambdaCaptureSource,
  local_indices : Array[Int],
  generic_specialization : StarshineGenericSpecialization?,
  body : @semantic.PlannedBodyLowering,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let direct_local = match source {
    @semantic.BodyLocalCapture(_, local_id) if current_lambda < 0 => local_id
    @semantic.LambdaLocalCapture(owner, local_id) if owner == current_lambda =>
      local_id
    _ => -1
  }
  if direct_local >= 0 {
    if direct_local >= local_indices.length() || local_indices[direct_local] < 0 {
      return Err(InvalidLocal(body.body, direct_local))
    }
    let local_info = lowering.locals[body.locals.start + direct_local]
    let local_shape = starshine_specialized_shape(
      lowering,
      generic_specialization,
      local_info.type_,
      local_info.shape,
    )
    if starshine_local_capture_cell_slot(lowering, body, direct_local) >= 0 {
      return Ok([
        @lib.Instruction::local_get(
          @lib.LocalIdx::new(local_indices[direct_local].reinterpret_as_uint()),
        ),
      ])
    }
    match local_shape {
      @semantic.ProductPlannedValueShape(_) =>
        return starshine_product_box_from_locals(
          planned,
          program,
          body.body,
          local_indices[direct_local],
          local_shape,
        )
      _ => ()
    }
    return Ok([
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(local_indices[direct_local].reinterpret_as_uint()),
      ),
    ])
  }
  if current_lambda >= 0 {
    let current = lowering.lambdas[current_lambda]
    for capture in 0..<current.captures.length {
      let capture_plan = lowering.captures[current.captures.start + capture]
      if capture_plan.source == source {
        return Ok(
          if capture_plan.mutable_ {
            starshine_capture_cell_reference_instructions(
              lowering, planned, program, module_index, current_lambda, capture,
            )
          } else {
            starshine_capture_get_instructions(
              lowering, planned, program, module_index, current_lambda, capture,
            )
          },
        )
      }
    }
  }
  Err(UnsupportedExpression(body.body, body.expressions.start))
}

///|
fn starshine_lambda_function_index(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  lambda : @semantic.LambdaId,
) -> Int {
  let fragment_index = planned.lambda_function_indices[lambda]
  let fragment = planned.functions[fragment_index]
  match program {
    Some(link) => {
      for function_ in link.functions {
        if !function_.elided &&
          function_.declaration == fragment.declaration &&
          function_.specialization_abi_key == fragment.specialization_abi_key {
          return function_.function_index
        }
      }
      -1
    }
    None => fragment.function_index
  }
}

///|
fn starshine_function_reference_cache_indices(
  lowering : @semantic.PlannedModuleLowering,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  body : @semantic.PlannedBodyLowering,
  first_local : Int,
) -> (Array[Int], Int) {
  let counts : Map[@semantic.DeclId, Int] = Map::default()
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match lowering.expressions[expression].kind {
      @semantic.PlannedFunctionReference(declaration, type_arguments) =>
        if (match program {
            // Specialized references use a physical singleton or an evidence
            // closure. A declaration-only local cache would merge distinct ABIs.
            Some(_) if type_arguments.length > 0 => false
            Some(link) =>
              link.function_reference_singleton_global(
                program_module_index, declaration,
              ) <
              0
            None => true
          }) {
          counts[declaration] = match counts.get(declaration) {
            Some(count) => count + 1
            None => 1
          }
        }
      _ => ()
    }
  }
  let local_by_declaration : Map[@semantic.DeclId, Int] = Map::default()
  let indices = Array::make(body.expressions.length, -1)
  let mut next_local = first_local
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match lowering.expressions[expression].kind {
      @semantic.PlannedFunctionReference(declaration, _) =>
        if counts.get(declaration).unwrap_or(0) > 1 {
          let local_index = match local_by_declaration.get(declaration) {
            Some(index) => index
            None => {
              let index = next_local
              next_local += 1
              local_by_declaration[declaration] = index
              index
            }
          }
          indices[expression - body.expressions.start] = local_index
        }
      _ => ()
    }
  }
  (indices, next_local - first_local)
}

///|
fn starshine_function_reference_cache_prefix(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  body : @semantic.PlannedBodyLowering,
  cache_indices : Array[Int],
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let initialized : Map[Int, Bool] = Map::default()
  let output : Array[@lib.Instruction] = []
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    let local_index = cache_indices[expression - body.expressions.start]
    if local_index < 0 || initialized.contains(local_index) {
      continue
    }
    let declaration = match lowering.expressions[expression].kind {
      @semantic.PlannedFunctionReference(declaration, _) => declaration
      _ => continue
    }
    let function_index = match
      starshine_function_reference_index(planned, program, declaration) {
      Ok(index) => index
      Err(error) => return Err(error)
    }
    output.push(
      @lib.Instruction::ref_func(
        @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
      ),
    )
    let closure_type = starshine_local_physical_type_index(
      program,
      program_module_index,
      planned.closure_type_index,
    )
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
      ),
    )
    output.push(
      @lib.Instruction::local_set(
        @lib.LocalIdx::new(local_index.reinterpret_as_uint()),
      ),
    )
    initialized[local_index] = true
  }
  Ok(output)
}

///|
fn starshine_program_adapter_value_code(
  value : @semantic.PlannedWasmValueType,
) -> Int {
  match value {
    @semantic.WasmI32Value => 0
    @semantic.WasmI64Value => 1
    @semantic.WasmF32Value => 2
    @semantic.WasmF64Value => 3
    @semantic.WasmV128Value => 4
    @semantic.WasmStringRefValue
    | @semantic.WasmNullableEqRefValue
    | @semantic.WasmFunctionRefValue(_)
    | @semantic.WasmNominalRefValue(_)
    | @semantic.WasmExternalNominalRefValue(_)
    | @semantic.WasmFixedArrayRefValue(_)
    | @semantic.WasmNullableNominalRefValue(_)
    | @semantic.WasmNullableExternalNominalRefValue(_) => 5
  }
}

///|
fn starshine_program_adapter_shape_code(
  shape : @semantic.PlannedValueShape,
) -> Int {
  match shape {
    @semantic.I8PlannedValueShape
    | @semantic.U8PlannedValueShape
    | @semantic.I16PlannedValueShape
    | @semantic.U16PlannedValueShape
    | @semantic.I32PlannedValueShape
    | @semantic.U32PlannedValueShape
    | @semantic.Swar32PlannedValueShape => 0
    @semantic.I64PlannedValueShape
    | @semantic.U64PlannedValueShape
    | @semantic.Swar64PlannedValueShape => 1
    @semantic.F32PlannedValueShape => 2
    @semantic.F64PlannedValueShape => 3
    @semantic.V128PlannedValueShape => 4
    @semantic.RefPlannedValueShape
    | @semantic.GenericPlannedValueShape
    | @semantic.ProductPlannedValueShape(_)
    | @semantic.ErrorPlannedValueShape => 5
    @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape => -1
  }
}

///|
fn starshine_program_append_shape_codes(
  shape : @semantic.PlannedValueShape,
  output : Array[Int],
) -> Unit {
  match shape {
    @semantic.ProductPlannedValueShape(fields) =>
      for field in fields {
        starshine_program_append_shape_codes(field, output)
      }
    @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape => ()
    _ => output.push(starshine_program_adapter_shape_code(shape))
  }
}

///|
fn starshine_program_append_specialized_resolved_codes(
  lowering : @semantic.PlannedModuleLowering,
  specialization : StarshineGenericSpecialization,
  type_ : @semantic.ResolvedTypeId,
  output : Array[Int],
) -> Unit {
  if type_ >= 0 && type_ < lowering.resolved_types.length() {
    match lowering.resolved_types[type_] {
      @semantic.GenericParameterType(parameter) => {
        let parameter_index = @semantic.semantic_id_local(parameter)
        if specialization.generic_parameters.relative_index(parameter_index)
          is Some(relative) {
          if relative < specialization.specialization_shapes.length {
            starshine_program_append_shape_codes(
              specialization.shapes[specialization.specialization_shapes.start +
              relative],
              output,
            )
            return
          }
        }
      }
      @semantic.ProductType(fields) => {
        for index in 0..<fields.length {
          starshine_program_append_specialized_resolved_codes(
            lowering,
            specialization,
            lowering.resolved_type_arguments[fields.start + index],
            output,
          )
        }
        return
      }
      _ => ()
    }
  }
  starshine_program_append_shape_codes(
    @semantic.planned_value_shape_from_resolved_types(
      lowering.resolved_types,
      lowering.resolved_type_arguments,
      type_,
    ),
    output,
  )
}

///|
fn starshine_program_specialized_type_code(
  lowering : @semantic.PlannedModuleLowering,
  specialization : StarshineGenericSpecialization,
  type_ : @semantic.ResolvedTypeId,
  fallback : Int,
) -> Int {
  if type_ >= 0 && type_ < lowering.resolved_types.length() {
    match lowering.resolved_types[type_] {
      @semantic.GenericParameterType(parameter) => {
        let parameter_index = @semantic.semantic_id_local(parameter)
        if specialization.generic_parameters.relative_index(parameter_index)
          is Some(relative) {
          if relative < specialization.specialization_shapes.length {
            return starshine_program_adapter_shape_code(
              specialization.shapes[specialization.specialization_shapes.start +
              relative],
            )
          }
        }
      }
      _ => ()
    }
  }
  fallback
}

///|
fn starshine_program_value_matches_code(
  value : @semantic.PlannedWasmValueType,
  code : Int,
) -> Bool {
  match (value, code) {
    (@semantic.WasmI32Value, 0)
    | (@semantic.WasmI64Value, 1)
    | (@semantic.WasmF32Value, 2)
    | (@semantic.WasmF64Value, 3)
    | (@semantic.WasmV128Value, 4)
    | (@semantic.WasmNullableEqRefValue, 5)
    | (@semantic.WasmStringRefValue, 5) => true
    _ => false
  }
}

///|
fn starshine_program_signature_matches_codes(
  planned : @semantic.PlannedProgramWasmGCLink,
  candidate : @semantic.PlannedProgramWasmSignatureType,
  parameter_codes : Array[Int],
  result_codes : Array[Int],
) -> Bool {
  let module_ = planned.modules[candidate.module_index]
  let (parameters, results) = match candidate.kind {
    @semantic.PlannedProgramFunctionType(function_type_index) => {
      let function_type = module_.function_types[function_type_index]
      (function_type.parameters, function_type.results)
    }
    @semantic.PlannedProgramFunctionSignature(function_index) => {
      let function_ = module_.functions[function_index]
      (function_.parameters, function_.results)
    }
  }
  if parameters.length != parameter_codes.length() ||
    results.length != result_codes.length() {
    return false
  }
  for index in 0..<parameters.length {
    if !starshine_program_value_matches_code(
        module_.function_value_types[parameters.start + index],
        parameter_codes[index],
      ) {
      return false
    }
  }
  for index in 0..<results.length {
    if !starshine_program_value_matches_code(
        module_.function_value_types[results.start + index],
        result_codes[index],
      ) {
      return false
    }
  }
  true
}

///|
fn starshine_program_find_signature_by_codes(
  planned : @semantic.PlannedProgramWasmGCLink,
  parameter_codes : Array[Int],
  result_codes : Array[Int],
) -> Int {
  for candidate in planned.program_signature_types {
    if starshine_program_signature_matches_codes(
        planned, candidate, parameter_codes, result_codes,
      ) {
      return candidate.type_index
    }
  }
  -1
}

///|
fn starshine_program_specialized_closure_signatures(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  module_ : @semantic.PlannedModuleWasmGCFragments,
  function_type : @semantic.ResolvedTypeId,
  specialization : StarshineGenericSpecialization,
) -> (Int, Int)? {
  if function_type < 0 || function_type >= lowering.resolved_types.length() {
    return None
  }
  let (resolved_parameters, resolved_result) = match
    lowering.resolved_types[function_type] {
    @semantic.FunctionType(parameters, result) => (parameters, result)
    _ => return None
  }
  ignore(module_)
  let parameter_codes : Array[Int] = []
  for index in 0..<resolved_parameters.length {
    starshine_program_append_specialized_resolved_codes(
      lowering,
      specialization,
      lowering.resolved_type_arguments[resolved_parameters.start + index],
      parameter_codes,
    )
  }
  let result_codes : Array[Int] = []
  starshine_program_append_specialized_resolved_codes(
    lowering, specialization, resolved_result, result_codes,
  )
  let direct = starshine_program_find_signature_by_codes(
    planned, parameter_codes, result_codes,
  )
  let entry_parameters : Array[Int] = [5]
  for code in parameter_codes {
    entry_parameters.push(code)
  }
  let entry = starshine_program_find_signature_by_codes(
    planned, entry_parameters, result_codes,
  )
  if direct < 0 || entry < 0 {
    None
  } else {
    Some((entry, direct))
  }
}

///|
fn starshine_runtime_bound_call_info(
  planned : @semantic.PlannedModuleWasmGCFragments,
  generic_specialization : StarshineGenericSpecialization?,
  requirement : @semantic.DeclId,
  evidence_slot : Int,
) -> (@semantic.DeclId, Int, Int, Int)? {
  let specialization = match generic_specialization {
    Some(value) => value
    None => return None
  }
  let (trait_, parameter) = match
    @semantic.program_runtime_trait_evidence_slot_parameter(
      planned,
      specialization.specialization_evidence,
      evidence_slot,
    ) {
    Some(value) => value
    None => return None
  }
  let requirement_function = match planned.function_of(requirement) {
    Some(value) if value.signature_type_index >= 0 => value
    _ => return None
  }
  for layout in planned.trait_layouts {
    if layout.trait_declaration != trait_ {
      continue
    }
    for method_slot in 0..<layout.methods.length {
      if planned.trait_layout_methods[layout.methods.start + method_slot] ==
        requirement {
        return Some(
          (
            trait_,
            method_slot,
            parameter,
            requirement_function.signature_type_index,
          ),
        )
      }
    }
  }
  None
}

///|
fn starshine_finish_trait_object_coercion(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  generic_specialization : StarshineGenericSpecialization?,
  body : @semantic.BodyId,
  trait_ : @semantic.DeclId,
  evidence : Int,
  output : Array[@lib.Instruction],
  helper_plan : StarshineProgramAdapterHelperPlan?,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let runtime_evidence = match generic_specialization {
    Some(specialization) =>
      @semantic.program_runtime_trait_evidence_parameter(
        lowering,
        planned,
        specialization.specialization_evidence,
        evidence,
      )
    None => None
  }
  match runtime_evidence {
    Some((runtime_trait, parameter)) => {
      if runtime_trait != trait_ || parameter < 0 {
        return Err(UnsupportedExpression(body, -305))
      }
      let mut layout = None
      for candidate in planned.trait_layouts {
        if candidate.trait_declaration == trait_ {
          layout = Some(candidate)
          break
        }
      }
      let layout = match layout {
        Some(value) => value
        None => return Err(UnsupportedExpression(body, -306))
      }
      let vtable_type = starshine_local_physical_type_index(
        program,
        program_module_index,
        layout.vtable_type_index,
      )
      let object_type = starshine_local_physical_type_index(
        program,
        program_module_index,
        layout.object_type_index,
      )
      if vtable_type < 0 || object_type < 0 {
        return Err(UnsupportedExpression(body, -307))
      }
      output.push(
        @lib.Instruction::local_get(
          @lib.LocalIdx::new(parameter.reinterpret_as_uint()),
        ),
      )
      output.push(starshine_match_cast(vtable_type))
      output.push(
        @lib.Instruction::struct_new(
          @lib.TypeIdx::new(object_type.reinterpret_as_uint()),
        ),
      )
      return Ok(output)
    }
    None => ()
  }
  let (implementation, evidence_key) = match generic_specialization {
    Some(specialization) =>
      match
        @semantic.program_resolved_trait_evidence_identity(
          lowering,
          planned,
          specialization.specialization_shapes,
          specialization.specialization_evidence,
          evidence,
        ) {
        Some(value) => value
        None => return Err(UnsupportedExpression(body, -302))
      }
    None => {
      let implementation = if evidence >= 0 &&
        evidence < lowering.trait_evidence.length() {
        match lowering.trait_evidence[evidence].kind {
          @semantic.GuardedInferredTraitEvidence(_, _) =>
            abort("CT-041 branch evidence reached emission unresolved")
          @semantic.ConcreteInferredTraitEvidence(value, _) => value
          @semantic.BoundInferredTraitEvidence(_) => 0UL
        }
      } else {
        0UL
      }
      (implementation, @semantic.wasmgc_trait_evidence_key(lowering, evidence))
    }
  }
  let mut dictionary = None
  let mut dictionary_index = -1
  for index, candidate in planned.trait_dictionaries {
    if candidate.trait_declaration == trait_ &&
      candidate.implementation == implementation &&
      candidate.evidence_key == evidence_key {
      dictionary = Some(candidate)
      dictionary_index = index
      break
    }
  }
  let dictionary = match dictionary {
    Some(value) => value
    None => return Err(UnsupportedExpression(body, -302))
  }
  if dictionary.methods.length > 0 {
    let receiver_shape = planned.trait_methods[dictionary.methods.start].receiver_shape
    let box_slot = starshine_program_erased_adapter_shape_box_slot(
      receiver_shape,
    )
    if box_slot >= 0 {
      let box_type = match program {
        Some(link) if box_slot < link.erased_box_type_indices.length() =>
          link.erased_box_type_indices[box_slot]
        _ => -1
      }
      if box_type < 0 {
        return Err(UnsupportedExpression(body, -304))
      }
      output.push(
        @lib.Instruction::struct_new(
          @lib.TypeIdx::new(box_type.reinterpret_as_uint()),
        ),
      )
    }
  }
  if dictionary.runtime_evidence_parameters.length > 0 {
    let captured = match helper_plan {
      Some(helpers) =>
        starshine_program_captured_trait_dictionary(
          helpers, program_module_index, dictionary_index,
        )
      None => None
    }
    let captured = match captured {
      Some(value) if value.capture_type_index >= 0 => value
      _ => return Err(UnsupportedExpression(body, -309))
    }
    if dictionary.runtime_evidence_parameters.start < 0 ||
      dictionary.runtime_evidence_parameters.start +
      dictionary.runtime_evidence_parameters.length >
      planned.trait_dictionary_runtime_evidence_parameters.length() {
      return Err(UnsupportedExpression(body, -310))
    }
    for index in 0..<dictionary.runtime_evidence_parameters.length {
      let parameter = planned.trait_dictionary_runtime_evidence_parameters[dictionary.runtime_evidence_parameters.start +
        index]
      if parameter < 0 {
        return Err(UnsupportedExpression(body, -311))
      }
      output.push(
        @lib.Instruction::local_get(
          @lib.LocalIdx::new(parameter.reinterpret_as_uint()),
        ),
      )
    }
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(captured.capture_type_index.reinterpret_as_uint()),
      ),
    )
  }
  let vtable_type = starshine_local_physical_type_index(
    program,
    program_module_index,
    dictionary.vtable_type_index,
  )
  let dictionary_global = match program {
    Some(link) =>
      link.trait_dictionary_global(program_module_index, dictionary_index)
    None => -1
  }
  if dictionary_global >= 0 {
    output.push(
      @lib.Instruction::global_get(
        @lib.GlobalIdx::new(dictionary_global.reinterpret_as_uint()),
      ),
    )
    output.push(starshine_match_cast(vtable_type))
  } else {
    for index in 0..<dictionary.methods.length {
      let method_info = planned.trait_methods[dictionary.methods.start + index]
      let adapter = planned.functions[method_info.adapter_function]
      let function_index = match program {
        Some(link) =>
          match link.function_of(adapter.declaration) {
            Some(value) => value.function_index
            None => -1
          }
        None => adapter.function_index
      }
      if function_index < 0 {
        return Err(MissingFunction(adapter.declaration))
      }
      output.push(
        @lib.Instruction::ref_func(
          @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
        ),
      )
    }
    output.push(
      @lib.Instruction::struct_new(
        @lib.TypeIdx::new(vtable_type.reinterpret_as_uint()),
      ),
    )
  }
  let object_type = starshine_local_physical_type_index(
    program,
    program_module_index,
    dictionary.object_type_index,
  )
  output.push(
    @lib.Instruction::struct_new(
      @lib.TypeIdx::new(object_type.reinterpret_as_uint()),
    ),
  )
  Ok(output)
}

///|
fn starshine_emit_body_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  context : StarshineExpressionEmissionContext,
  body : @semantic.PlannedBodyLowering,
  current_lambda : @semantic.LambdaId,
  local_indices : Array[Int],
  match_local_indices : Array[Int],
  match_result_local_indices : Array[Int],
  function_reference_cache_indices : Array[Int],
  fixed_array_ref_scratch_index : Int,
  fixed_array_i32_scratch_index : Int,
  map_key_local_indices : Array[Int],
  map_value_local_indices : Array[Int],
  map_ref_scratch_index : Int,
  map_bucket_scratch_index : Int,
  map_hash_scratch_index : Int,
  map_entry_scratch_index : Int,
  map_previous_scratch_index : Int,
  map_growth_index_scratch_index : Int,
  control_state_local_indices : Array[Int],
  control_result_local_indices : Array[Int],
  constructor_local_indices : Array[Int],
  generic_specialization : StarshineGenericSpecialization?,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let program = context.program
  let program_module_index = context.module_index
  let helper_plan = context.helper_plan
  let tasks : Array[StarshineEmitTask] = []
  let results : Array[Array[@lib.Instruction]] = []
  match body.root {
    @semantic.ExpressionBodyRoot(expression) =>
      tasks.push(EmitStarshineExpression(expression))
    @semantic.BlockBodyRoot(block) => tasks.push(EmitStarshineBlock(block))
  }
  while tasks.length() > 0 {
    match tasks.pop().unwrap() {
      EmitStarshineExpression(expression) => {
        let source = lowering.expressions[expression]
        match source.trait_object_coercion {
          @semantic.SelectedInferredTraitObjectCoercion(trait_, evidence) => {
            tasks.push(FinishStarshineTraitObjectCoercion(trait_, evidence))
            tasks.push(EmitStarshineRawExpression(expression))
          }
          _ => tasks.push(EmitStarshineRawExpression(expression))
        }
      }
      EmitStarshineRawExpression(expression) => {
        let source = lowering.expressions[expression]
        match source.kind {
          @semantic.PlannedI8Const(value) =>
            results.push([
              @lib.Instruction::i32_const(
                @lib.I32::new(starshine_signed_i8_constant(value)),
              ),
            ])
          @semantic.PlannedI16Const(value) =>
            results.push([
              @lib.Instruction::i32_const(
                @lib.I32::new(starshine_signed_i16_constant(value)),
              ),
            ])
          @semantic.PlannedU8Const(value) =>
            results.push([
              @lib.Instruction::i32_const(
                @lib.I32::new((value & 0xFFUL).to_int()),
              ),
            ])
          @semantic.PlannedU16Const(value) =>
            results.push([
              @lib.Instruction::i32_const(
                @lib.I32::new((value & 0xFFFFUL).to_int()),
              ),
            ])
          @semantic.PlannedI32Const(value) | @semantic.PlannedU32Const(value) =>
            results.push([
              @lib.Instruction::i32_const(@lib.I32::new(value.to_int())),
            ])
          @semantic.PlannedI64Const(value) | @semantic.PlannedU64Const(value) =>
            results.push([
              @lib.Instruction::i64_const(
                @lib.I64::new(value.reinterpret_as_int64()),
              ),
            ])
          @semantic.PlannedF32Const(value) =>
            results.push([@lib.Instruction::f32_const(@lib.F32::new(value))])
          @semantic.PlannedF64Const(value) =>
            results.push([@lib.Instruction::f64_const(@lib.F64::new(value))])
          @semantic.PlannedBoolConst(value) =>
            results.push([
              @lib.Instruction::i32_const(
                @lib.I32::new(if value { 1 } else { 0 }),
              ),
            ])
          @semantic.PlannedStringConst(value) =>
            results.push(
              starshine_text_constant_instructions(
                planned, program, value, true,
              ),
            )
          @semantic.PlannedStringArrayConst(values) => {
            guard source.shape is @semantic.RefPlannedValueShape else {
              return Err(UnsupportedExpression(body.body, expression))
            }
            let fragments = values.map(value => {
              starshine_text_constant_instructions(
                planned, program, value, true,
              )
            })
            match
              starshine_finish_array(
                planned,
                program,
                body.body,
                48,
                Some(source.shape),
                fragments,
                -1,
                map_key_local_indices[expression - body.expressions.start],
                -1,
                map_value_local_indices[expression - body.expressions.start],
              ) {
              Ok(instructions) => results.push(instructions)
              Err(error) => return Err(error)
            }
          }
          @semantic.PlannedBytesConst(value) =>
            results.push(
              starshine_text_constant_instructions(
                planned, program, value, false,
              ),
            )
          @semantic.PlannedFunctionReference(declaration, type_arguments) => {
            let evidence_closure = match (program, helper_plan) {
              (Some(link), Some(helpers)) =>
                starshine_program_evidence_closure(
                  helpers,
                  link,
                  body.body,
                  match generic_specialization {
                    Some(value) => value.specialization_abi_key
                    None => ""
                  },
                  expression,
                )
              _ => None
            }
            match evidence_closure {
              Some(closure) => {
                if closure.closure_type_index < 0 ||
                  closure.function_index < 0 ||
                  closure.reference_index < 0 {
                  return Err(UnsupportedExpression(body.body, expression))
                }
                let link = program.unwrap()
                let reference = link.evidence_function_references[closure.reference_index]
                if reference.runtime_evidence_parameters.start < 0 ||
                  reference.runtime_evidence_parameters.length < 0 ||
                  reference.runtime_evidence_parameters.start +
                  reference.runtime_evidence_parameters.length >
                  link.evidence_function_reference_runtime_evidence_parameters.length() {
                  return Err(UnsupportedExpression(body.body, expression))
                }
                let output : Array[@lib.Instruction] = [
                  @lib.Instruction::ref_func(
                    @lib.FuncIdx::new(
                      closure.function_index.reinterpret_as_uint(),
                    ),
                  ),
                ]
                for index in 0..<reference.runtime_evidence_parameters.length {
                  let parameter = link.evidence_function_reference_runtime_evidence_parameters[reference.runtime_evidence_parameters.start +
                    index]
                  output.push(
                    @lib.Instruction::local_get(
                      @lib.LocalIdx::new(parameter.reinterpret_as_uint()),
                    ),
                  )
                }
                output.push(
                  @lib.Instruction::struct_new(
                    @lib.TypeIdx::new(
                      closure.closure_type_index.reinterpret_as_uint(),
                    ),
                  ),
                )
                results.push(output)
              }
              None => {
                let exact_target = match program {
                  Some(link) if type_arguments.length > 0 =>
                    match
                      link.specialized_call_function(
                        body.body,
                        match generic_specialization {
                          Some(value) => value.specialization_abi_key
                          None => ""
                        },
                        expression,
                      ) {
                      Some(target) if target.declaration == declaration &&
                        target.function_index >= 0 &&
                        !target.elided => Some(target)
                      _ => return Err(MissingFunction(declaration))
                    }
                  _ => None
                }
                let singleton_global = match program {
                  Some(link) if exact_target is Some(_) => {
                    let target = exact_target.unwrap()
                    if generic_specialization is None {
                      link.specialized_function_reference_singleton_global(
                        declaration,
                        link.modules[target.module_index].specialization_shapes,
                        target.specialization_shapes,
                        starshine_program_expression_function_type_index(
                          lowering, planned, link, program_module_index, expression,
                        ),
                      )
                    } else {
                      let mut global = -1
                      for singleton in link.function_reference_singletons {
                        if singleton.function_index == target.function_index {
                          global = singleton.global_index
                          break
                        }
                      }
                      global
                    }
                  }
                  Some(link) =>
                    link.function_reference_singleton_global(
                      program_module_index, declaration,
                    )
                  None => -1
                }
                let cache_local = function_reference_cache_indices[expression -
                  body.expressions.start]
                if singleton_global >= 0 {
                  results.push([
                    @lib.Instruction::global_get(
                      @lib.GlobalIdx::new(
                        singleton_global.reinterpret_as_uint(),
                      ),
                    ),
                  ])
                } else if cache_local >= 0 {
                  results.push([
                    @lib.Instruction::local_get(
                      @lib.LocalIdx::new(cache_local.reinterpret_as_uint()),
                    ),
                  ])
                } else {
                  let function_index = match exact_target {
                    Some(target) => target.function_index
                    _ =>
                      match
                        starshine_function_reference_index(
                          planned, program, declaration,
                        ) {
                        Ok(index) => index
                        Err(error) => return Err(error)
                      }
                  }
                  let output : Array[@lib.Instruction] = [
                    @lib.Instruction::ref_func(
                      @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
                    ),
                  ]
                  if planned.closure_type_index >= 0 {
                    let closure_type = starshine_local_physical_type_index(
                      program,
                      program_module_index,
                      planned.closure_type_index,
                    )
                    output.push(
                      @lib.Instruction::struct_new(
                        @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
                      ),
                    )
                  }
                  results.push(output)
                }
              }
            }
          }
          @semantic.PlannedDirectLambdaCall(lambda, captures, arguments) => {
            let function_index = starshine_lambda_function_index(
              planned, program, lambda,
            )
            if function_index < 0 {
              return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(
              FinishStarshineDirectLambdaCall(
                function_index,
                captures,
                arguments.length,
              ),
            )
            let mut index = arguments.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[arguments.start + index],
                ),
              )
            }
          }
          @semantic.PlannedDynamicTraitCall(
            trait_,
            requirement,
            slot,
            receiver,
            arguments,
            _
          ) => {
            let requirement_function = match planned.function_of(requirement) {
              Some(value) if value.signature_type_index >= 0 => value
              _ => return Err(SignatureOnlyCall(requirement))
            }
            let scratch = match_local_indices[expression -
              body.expressions.start]
            if receiver < 0 || scratch < 0 {
              return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(
              FinishStarshineDynamicTraitCall(
                trait_,
                slot,
                scratch,
                requirement_function.signature_type_index,
                arguments.length,
              ),
            )
            let mut index = arguments.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[arguments.start + index],
                ),
              )
            }
            tasks.push(EmitStarshineExpression(receiver))
          }
          @semantic.PlannedFunctionValueCall(target, arguments, function_type) => {
            if function_type < 0 ||
              function_type >= planned.function_type_by_resolved.length() {
              return Err(UnsupportedExpression(body.body, expression))
            }
            if planned.closure_type_index >= 0 {
              let local_type = planned.closure_entry_type_by_resolved[function_type]
              let direct_local_type = planned.function_type_by_resolved[function_type]
              let scratch = match_local_indices[expression -
                body.expressions.start]
              if local_type < 0 || direct_local_type < 0 || scratch < 0 {
                return Err(UnsupportedExpression(body.body, expression))
              }
              let mut emitted_type = match program {
                Some(link) =>
                  link.signature_type_index(program_module_index, local_type)
                None => local_type
              }
              let mut emitted_direct_type = match program {
                Some(link) =>
                  link.signature_type_index(
                    program_module_index, direct_local_type,
                  )
                None => direct_local_type
              }
              let erased_direct = planned.erased_closure_direct_type_by_resolved[function_type]
              let erased_entry = planned.erased_closure_entry_type_by_resolved[function_type]
              let mut emitted_erased_direct = match program {
                Some(link) =>
                  link.signature_type_index(program_module_index, erased_direct)
                None => erased_direct
              }
              let mut emitted_erased_entry = match program {
                Some(link) =>
                  link.signature_type_index(program_module_index, erased_entry)
                None => erased_entry
              }
              match (program, generic_specialization) {
                (Some(link), Some(specialization)) =>
                  match
                    starshine_program_specialized_closure_signatures(
                      lowering, link, planned, function_type, specialization,
                    ) {
                    Some((entry, direct)) => {
                      emitted_type = entry
                      emitted_direct_type = direct
                      emitted_erased_entry = entry
                      emitted_erased_direct = direct
                    }
                    None => ()
                  }
                _ => ()
              }
              let closure_type = match program {
                Some(link) =>
                  link.physical_type_index(
                    program_module_index,
                    planned.closure_type_index,
                  )
                None => planned.closure_type_index
              }
              tasks.push(
                FinishStarshineClosureCall(
                  {
                    expression,
                    entry_type: emitted_type,
                    direct_type: emitted_direct_type,
                    erased_entry_type: emitted_erased_entry,
                    erased_direct_type: emitted_erased_direct,
                    closure_type,
                    closure_local: scratch,
                    result_shape: starshine_specialized_shape(
                      lowering,
                      generic_specialization,
                      source.type_,
                      source.shape,
                    ),
                    result_local: match_result_local_indices[expression -
                    body.expressions.start],
                    result_cast_type: starshine_function_result_cast_type(
                      planned, program, program_module_index, direct_local_type,
                    ),
                  },
                  arguments.length + 1,
                ),
              )
              let mut index = arguments.length
              while index > 0 {
                index -= 1
                tasks.push(
                  EmitStarshineExpression(
                    lowering.expression_children[arguments.start + index],
                  ),
                )
              }
              tasks.push(EmitStarshineExpression(target))
            } else {
              let local_type = planned.function_type_by_resolved[function_type]
              if local_type < 0 {
                return Err(UnsupportedExpression(body.body, expression))
              }
              let emitted_type = match program {
                Some(link) =>
                  link.signature_type_index(program_module_index, local_type)
                None => local_type
              }
              tasks.push(
                FinishStarshineFunctionValueCall(
                  emitted_type,
                  arguments.length + 1,
                ),
              )
              tasks.push(EmitStarshineExpression(target))
              let mut index = arguments.length
              while index > 0 {
                index -= 1
                tasks.push(
                  EmitStarshineExpression(
                    lowering.expression_children[arguments.start + index],
                  ),
                )
              }
            }
          }
          @semantic.PlannedCaptureGet(capture) => {
            if current_lambda < 0 {
              return Err(UnsupportedExpression(body.body, expression))
            }
            let output = starshine_capture_get_instructions(
              lowering, planned, program, program_module_index, current_lambda, capture,
            )
            let capture_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              source.type_,
              source.shape,
            )
            if capture_shape is @semantic.ProductPlannedValueShape(_) {
              if fixed_array_ref_scratch_index < 0 {
                return Err(UnsupportedExpression(body.body, -423))
              }
              output.push(
                @lib.Instruction::local_set(
                  @lib.LocalIdx::new(
                    fixed_array_ref_scratch_index.reinterpret_as_uint(),
                  ),
                ),
              )
              match
                starshine_append_product_unbox(
                  output,
                  planned,
                  program,
                  body.body,
                  fixed_array_ref_scratch_index,
                  capture_shape,
                ) {
                Ok(_) => ()
                Err(error) => return Err(error)
              }
            }
            results.push(output)
          }
          @semantic.PlannedLambdaClosure(lambda, captures) => {
            let function_index = starshine_lambda_function_index(
              planned, program, lambda,
            )
            if function_index < 0 {
              return Err(UnsupportedExpression(body.body, expression))
            }
            let lambda_closure_type = starshine_local_physical_type_index(
              program,
              program_module_index,
              planned.lambda_closure_type_indices[lambda],
            )
            let output : Array[@lib.Instruction] = [
              @lib.Instruction::ref_func(
                @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
              ),
            ]
            for capture in 0..<captures.length {
              let global_capture = captures.start + capture
              if planned.lambda_capture_field_indices[global_capture] < 0 {
                continue
              }
              match
                starshine_capture_source_instructions(
                  lowering,
                  planned,
                  program,
                  program_module_index,
                  current_lambda,
                  lowering.captures[global_capture].source,
                  local_indices,
                  generic_specialization,
                  body,
                ) {
                Ok(instructions) =>
                  append_starshine_instructions(output, instructions)
                Err(error) => return Err(error)
              }
            }
            output.push(
              @lib.Instruction::struct_new(
                @lib.TypeIdx::new(lambda_closure_type.reinterpret_as_uint()),
              ),
            )
            results.push(output)
          }
          @semantic.PlannedLocalSet(local_id, value) => {
            if local_id < 0 || local_id >= local_indices.length() {
              return Err(InvalidLocal(body.body, local_id))
            }
            if local_indices[local_id] < 0 {
              let local_info = lowering.locals[body.locals.start + local_id]
              match
                starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  local_info.type_,
                  local_info.shape,
                ) {
                @semantic.UnitPlannedValueShape =>
                  tasks.push(EmitStarshineExpression(value))
                _ => return Err(InvalidLocal(body.body, local_id))
              }
            } else {
              tasks.push(
                FinishStarshineLocalSet(
                  local_id,
                  local_indices[local_id],
                  value,
                ),
              )
              tasks.push(EmitStarshineExpression(value))
            }
          }
          @semantic.PlannedCaptureSet(capture, value) => {
            tasks.push(
              FinishStarshineCaptureSet(
                current_lambda,
                capture,
                value,
                match_result_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
          }
          @semantic.PlannedLocalGet(local_id) => {
            if local_id >= 0 &&
              local_id < local_indices.length() &&
              local_indices[local_id] < 0 {
              let local_info = lowering.locals[body.locals.start + local_id]
              match
                starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  local_info.type_,
                  local_info.shape,
                ) {
                @semantic.UnitPlannedValueShape => {
                  results.push([])
                  continue
                }
                _ => ()
              }
            }
            if local_id < 0 ||
              local_id >= local_indices.length() ||
              local_indices[local_id] < 0 {
              return Err(InvalidLocal(body.body, local_id))
            }
            let local_info = lowering.locals[body.locals.start + local_id]
            let local_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              local_info.type_,
              local_info.shape,
            )
            let cell_slot = starshine_local_capture_cell_slot(
              lowering, body, local_id,
            )
            if local_shape is @semantic.ProductPlannedValueShape(_) {
              let output : Array[@lib.Instruction] = []
              if cell_slot >= 0 {
                let cell_type = starshine_capture_cell_type_index(
                  planned, program, program_module_index, cell_slot,
                )
                output.push(
                  @lib.Instruction::local_get(
                    @lib.LocalIdx::new(
                      local_indices[local_id].reinterpret_as_uint(),
                    ),
                  ),
                )
                output.push(starshine_match_cast(cell_type))
                output.push(
                  starshine_struct_get_instruction(
                    cell_type,
                    0,
                    @semantic.wasmgc_capture_cell_storage(cell_slot),
                  ),
                )
                output.push(
                  @lib.Instruction::local_set(
                    @lib.LocalIdx::new(
                      (local_indices[local_id] + 1).reinterpret_as_uint(),
                    ),
                  ),
                )
                match
                  starshine_append_product_unbox(
                    output,
                    planned,
                    program,
                    body.body,
                    local_indices[local_id] + 1,
                    local_shape,
                  ) {
                  Ok(_) => ()
                  Err(error) => return Err(error)
                }
              } else {
                starshine_append_product_local_gets(
                  output,
                  local_indices[local_id],
                  local_shape,
                )
              }
              results.push(output)
              continue
            }
            let output = [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(
                  local_indices[local_id].reinterpret_as_uint(),
                ),
              ),
            ]
            if cell_slot >= 0 {
              let cell_type = starshine_capture_cell_type_index(
                planned, program, program_module_index, cell_slot,
              )
              output.push(starshine_match_cast(cell_type))
              output.push(
                starshine_struct_get_instruction(
                  cell_type,
                  0,
                  @semantic.wasmgc_capture_cell_storage(cell_slot),
                ),
              )
              let local_info = lowering.locals[body.locals.start + local_id]
              if local_info.nominal != 0UL {
                match
                  starshine_emitted_type_index(
                    planned,
                    program,
                    local_info.nominal,
                  ) {
                  Some(type_index) =>
                    output.push(starshine_match_cast(type_index))
                  None => ()
                }
              }
            }
            if cell_slot < 0 && local_info.kind is @semantic.PatternLocal {
              match
                starshine_precise_nominal_local_type_index(
                  lowering, planned, program, local_info,
                ) {
                Some(type_index) =>
                  output.push(starshine_match_cast(type_index))
                None => ()
              }
            }
            results.push(output)
          }
          @semantic.PlannedBlockExpression(block) =>
            tasks.push(EmitStarshineBlock(block))
          @semantic.PlannedIfExpression(condition, then_block, alternative) => {
            tasks.push(
              FinishStarshineIf(
                starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  source.type_,
                  source.shape,
                ),
                match_result_local_indices[expression - body.expressions.start],
              ),
            )
            if alternative < 0 {
              tasks.push(EmitStarshineEmpty)
            } else {
              tasks.push(EmitStarshineExpression(alternative))
            }
            tasks.push(EmitStarshineBlock(then_block))
            tasks.push(EmitStarshineExpression(condition))
          }
          @semantic.PlannedParameterSelect(arguments, selected) => {
            tasks.push(FinishStarshineParameterSelect(arguments, selected))
            let mut index = arguments.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[arguments.start + index],
                ),
              )
            }
          }
          @semantic.PlannedDirectCall(
            declaration,
            receiver,
            arguments,
            type_arguments
          ) => {
            let has_receiver = receiver >= 0 &&
              !(lowering.expressions[receiver].kind
              is @semantic.PlannedConsumedExpression)
            let receiver_count = if has_receiver { 1 } else { 0 }
            tasks.push(
              FinishStarshineCall(
                declaration,
                expression,
                arguments.length + receiver_count,
                type_arguments,
              ),
            )
            let mut index = arguments.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[arguments.start + index],
                ),
              )
            }
            if has_receiver {
              tasks.push(EmitStarshineExpression(receiver))
            }
          }
          @semantic.PlannedTailCall(
            declaration,
            receiver,
            arguments,
            type_arguments
          ) => {
            let has_receiver = receiver >= 0 &&
              !(lowering.expressions[receiver].kind
              is @semantic.PlannedConsumedExpression)
            let receiver_count = if has_receiver { 1 } else { 0 }
            tasks.push(
              FinishStarshineTailCall(
                declaration,
                expression,
                arguments.length + receiver_count,
                type_arguments,
              ),
            )
            let mut index = arguments.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[arguments.start + index],
                ),
              )
            }
            if has_receiver {
              tasks.push(EmitStarshineExpression(receiver))
            }
          }
          @semantic.PlannedBoundDirectCall(
            requirement,
            evidence_slot,
            receiver,
            arguments,
            type_arguments
          ) => {
            let has_receiver = receiver >= 0 &&
              !(lowering.expressions[receiver].kind
              is @semantic.PlannedConsumedExpression)
            let receiver_count = if has_receiver { 1 } else { 0 }
            match
              starshine_runtime_bound_call_info(
                planned, generic_specialization, requirement, evidence_slot,
              ) {
              Some((trait_, method_slot, parameter, signature)) =>
                tasks.push(
                  FinishStarshineRuntimeBoundCall(
                    trait_,
                    method_slot,
                    parameter,
                    signature,
                    arguments.length + receiver_count,
                  ),
                )
              None =>
                tasks.push(
                  FinishStarshineCall(
                    requirement,
                    expression,
                    arguments.length + receiver_count,
                    type_arguments,
                  ),
                )
            }
            let mut index = arguments.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[arguments.start + index],
                ),
              )
            }
            if has_receiver {
              tasks.push(EmitStarshineExpression(receiver))
            }
          }
          @semantic.PlannedOperatorCall(
            declaration,
            _,
            left,
            right,
            type_arguments
          ) => {
            tasks.push(
              FinishStarshineCall(declaration, expression, 2, type_arguments),
            )
            tasks.push(EmitStarshineExpression(right))
            tasks.push(EmitStarshineExpression(left))
          }
          @semantic.PlannedBoundOperatorCall(
            requirement,
            evidence_slot,
            _,
            left,
            right,
            type_arguments
          ) => {
            match
              starshine_runtime_bound_call_info(
                planned, generic_specialization, requirement, evidence_slot,
              ) {
              Some((trait_, method_slot, parameter, signature)) =>
                tasks.push(
                  FinishStarshineRuntimeBoundCall(
                    trait_, method_slot, parameter, signature, 2,
                  ),
                )
              None =>
                tasks.push(
                  FinishStarshineCall(
                    requirement, expression, 2, type_arguments,
                  ),
                )
            }
            tasks.push(EmitStarshineExpression(right))
            tasks.push(EmitStarshineExpression(left))
          }
          @semantic.PlannedIndexCall(declaration, base, index, type_arguments) => {
            tasks.push(
              FinishStarshineCall(declaration, expression, 2, type_arguments),
            )
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedIndexSetCall(
            declaration,
            base,
            index,
            value,
            type_arguments
          ) => {
            tasks.push(
              FinishStarshineCall(declaration, expression, 3, type_arguments),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedWasmRefNull =>
            results.push([
              @lib.Instruction::ref_null(
                @lib.HeapType::abs(@lib.AbsHeapType::none()),
              ),
            ])
          @semantic.PlannedWasmRefIsNull(value) => {
            tasks.push(FinishStarshineRefIntrinsic(1))
            tasks.push(EmitStarshineExpression(value))
          }
          @semantic.PlannedWasmRefAsNonNull(value) => {
            tasks.push(FinishStarshineRefIntrinsic(2))
            tasks.push(EmitStarshineExpression(value))
          }
          @semantic.PlannedFixedArrayMake(length, value, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              lowering.expressions[value].type_,
              shape,
            )
            tasks.push(
              FinishStarshineFixedArray(
                1,
                element_shape,
                2,
                map_value_local_indices[expression - body.expressions.start],
                fixed_array_i32_scratch_index,
              ),
            )
            if element_shape is @semantic.ProductPlannedValueShape(_) {
              tasks.push(
                FinishStarshineProductBox(
                  element_shape,
                  match_result_local_indices[value - body.expressions.start],
                ),
              )
            }
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(length))
          }
          @semantic.PlannedFixedArrayLength(base, shape) => {
            let element_shape = starshine_specialized_implicit_shape(
              lowering, generic_specialization, shape,
            )
            tasks.push(
              FinishStarshineFixedArray(
                2, element_shape, 1, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedFixedArrayGetUnchecked(base, index, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              source.type_,
              shape,
            )
            if element_shape is @semantic.ProductPlannedValueShape(_) {
              tasks.push(
                FinishStarshineProductUnbox(
                  element_shape, fixed_array_ref_scratch_index,
                ),
              )
            }
            tasks.push(
              FinishStarshineFixedArray(
                4, element_shape, 2, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedFixedArraySetUnchecked(base, index, value, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              lowering.expressions[value].type_,
              shape,
            )
            tasks.push(
              FinishStarshineFixedArray(
                5, element_shape, 3, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            if element_shape is @semantic.ProductPlannedValueShape(_) {
              tasks.push(
                FinishStarshineProductBox(
                  element_shape,
                  match_result_local_indices[value - body.expressions.start],
                ),
              )
            }
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedRawArrayNewDefault(length, element, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element, shape,
            )
            tasks.push(FinishStarshineFixedArray(6, element_shape, 1, -1, -1))
            tasks.push(EmitStarshineExpression(length))
          }
          @semantic.PlannedRawArrayCopy(
            target,
            target_index,
            source,
            source_index,
            length,
            element,
            shape
          ) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element, shape,
            )
            tasks.push(FinishStarshineFixedArray(7, element_shape, 5, -1, -1))
            tasks.push(EmitStarshineExpression(length))
            tasks.push(EmitStarshineExpression(source_index))
            tasks.push(EmitStarshineExpression(source))
            tasks.push(EmitStarshineExpression(target_index))
            tasks.push(EmitStarshineExpression(target))
          }
          @semantic.PlannedProductNew(elements) => {
            tasks.push(FinishStarshineProduct(elements.length))
            let mut index = elements.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[elements.start + index],
                ),
              )
            }
          }
          @semantic.PlannedArrayLiteral(elements, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            match element_shape {
              @semantic.ProductPlannedValueShape(_) if elements.length > 0 =>
                tasks.push(
                  FinishStarshineArrayLiteral(
                    element_shape,
                    elements.length,
                    map_key_local_indices[expression - body.expressions.start],
                    map_value_local_indices[expression - body.expressions.start],
                    match_result_local_indices[expression -
                    body.expressions.start],
                  ),
                )
              _ =>
                tasks.push(
                  FinishStarshineArray(
                    48,
                    Some(element_shape),
                    elements.length,
                    fixed_array_ref_scratch_index,
                    map_key_local_indices[expression - body.expressions.start],
                    fixed_array_i32_scratch_index,
                    map_value_local_indices[expression - body.expressions.start],
                  ),
                )
            }
            let mut index = elements.length
            while index > 0 {
              index -= 1
              tasks.push(
                EmitStarshineExpression(
                  lowering.expression_children[elements.start + index],
                ),
              )
            }
          }
          @semantic.PlannedArrayNew(element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                1,
                Some(element_shape),
                0,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
          }
          @semantic.PlannedArrayWithCapacity(capacity, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                2,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(capacity))
          }
          @semantic.PlannedArrayLength(base) => {
            tasks.push(
              FinishStarshineArray(
                3,
                None,
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayGet(base, index, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            tasks.push(
              FinishStarshineArray(
                5,
                Some(element_shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayGetUnchecked(base, index, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              source.type_,
              shape,
            )
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            tasks.push(
              FinishStarshineArray(
                6,
                Some(element_shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArraySet(base, index, value, shape) => {
            let value_source = lowering.expressions[value]
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              value_source.type_,
              shape,
            )
            tasks.push(
              FinishStarshineArray(
                7,
                Some(element_shape),
                3,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArraySetUnchecked(base, index, value, shape) => {
            let value_source = lowering.expressions[value]
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              value_source.type_,
              shape,
            )
            tasks.push(
              FinishStarshineArray(
                8,
                Some(element_shape),
                3,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayPush(base, value, shape) => {
            let value_source = lowering.expressions[value]
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              value_source.type_,
              shape,
            )
            tasks.push(
              FinishStarshineArray(
                9,
                Some(element_shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayPop(base, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                10,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayMake(length, value, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                39,
                Some(element_shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(length))
          }
          @semantic.PlannedArrayReserve(base, additional, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                40,
                Some(element_shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(additional))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayShrinkToFit(base, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                41,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayTruncate(base, length, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                42,
                Some(element_shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(length))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayCopy(base, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                43,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayCopyWithin(
            base,
            target,
            start,
            end,
            element_type,
            shape
          ) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                44,
                Some(element_shape),
                4,
                fixed_array_ref_scratch_index,
                map_key_local_indices[expression - body.expressions.start],
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(end))
            tasks.push(EmitStarshineExpression(start))
            tasks.push(EmitStarshineExpression(target))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayFill(
            base,
            value,
            start,
            end,
            element_type,
            shape
          ) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                45,
                Some(element_shape),
                4,
                fixed_array_ref_scratch_index,
                map_key_local_indices[expression - body.expressions.start],
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(end))
            tasks.push(EmitStarshineExpression(start))
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArraySlice(base, start, end, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                46,
                Some(element_shape),
                3,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(end))
            tasks.push(EmitStarshineExpression(start))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayExtend(base, source, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                47,
                Some(element_shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(source))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedStackIsEmpty(base) => {
            tasks.push(
              FinishStarshineArray(
                16,
                None,
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedStackPeek(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                17,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedQueueDequeue(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                19,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedQueuePeek(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                18,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferNew(capacity, shape, growable) => {
            tasks.push(
              FinishStarshineArray(
                if growable {
                  21
                } else {
                  20
                },
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(capacity))
          }
          @semantic.PlannedCircularBufferNewZero(shape) =>
            tasks.push(
              FinishStarshineArray(
                33,
                Some(shape),
                0,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
          @semantic.PlannedQueueRingEnqueue(base, value, shape) => {
            tasks.push(
              FinishStarshineArray(
                34,
                Some(shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedDequeRingPushFront(base, value, shape) => {
            tasks.push(
              FinishStarshineArray(
                38,
                Some(shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferCapacity(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                23,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferIsFull(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                25,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferPushBack(base, value, shape) => {
            tasks.push(
              FinishStarshineArray(
                26,
                Some(shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferPopFront(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                27,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferPeekFront(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                28,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferClear(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                29,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferIter(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                30,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferIterHasNext(base) => {
            tasks.push(
              FinishStarshineArray(
                31,
                None,
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferIterNext(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                32,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferPushFront(base, value, shape) => {
            tasks.push(
              FinishStarshineArray(
                35,
                Some(shape),
                2,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferPopBack(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                36,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedCircularBufferPeekBack(base, shape) => {
            tasks.push(
              FinishStarshineArray(
                37,
                Some(shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayClear(base, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                11,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayIter(base, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            tasks.push(
              FinishStarshineArray(
                12,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayIterHasNext(base) => {
            tasks.push(
              FinishStarshineArray(
                13,
                None,
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayIterNext(base, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              source.type_,
              shape,
            )
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            if element_shape is @semantic.ProductPlannedValueShape(_) {
              tasks.push(
                FinishStarshineProductUnbox(
                  element_shape, fixed_array_ref_scratch_index,
                ),
              )
            }
            tasks.push(
              FinishStarshineArray(
                14,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                map_value_local_indices[expression - body.expressions.start],
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedArrayIterNextOption(base, element_type, shape) => {
            let element_shape = starshine_specialized_shape(
              lowering, generic_specialization, element_type, shape,
            )
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            tasks.push(
              FinishStarshineArray(
                49,
                Some(element_shape),
                1,
                fixed_array_ref_scratch_index,
                map_ref_scratch_index,
                fixed_array_i32_scratch_index,
                -1,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapKeys(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                1, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapValues(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                2, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapEntries(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                3, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapIterHasNext(base, kind, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                if kind == 1 {
                  4
                } else if kind == 2 {
                  13
                } else {
                  14
                },
                key_shape,
                value_shape,
                1,
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_entry_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapKeyIterNext(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                5, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapKeyIterNextOption(base, key_shape, value_shape) => {
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            tasks.push(
              FinishStarshineHashIter(
                15, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapValueIterNext(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                6, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapValueIterNextOption(base, key_shape, value_shape) => {
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            tasks.push(
              FinishStarshineHashIter(
                16, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapEntryIterNext(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                7, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapEntryIterNextOption(base, key_shape, value_shape) => {
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            tasks.push(
              FinishStarshineHashIter(
                17, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapEntryKey(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                8, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapEntryValue(base, key_shape, value_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                9, key_shape, value_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedSetIter(base, key_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                10, key_shape, key_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedSetIterHasNext(base, key_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                11, key_shape, key_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedSetIterNext(base, key_shape) => {
            tasks.push(
              FinishStarshineHashIter(
                12, key_shape, key_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedSetIterNextOption(base, key_shape) => {
            if source.nominal != 0UL {
              tasks.push(FinishStarshineNominalResult(source.nominal))
            }
            tasks.push(
              FinishStarshineHashIter(
                18, key_shape, key_shape, 1, map_ref_scratch_index, map_bucket_scratch_index,
                map_entry_scratch_index, map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapEmpty(key_shape, value_shape, hash, eq) =>
            tasks.push(
              FinishStarshineMap(
                8, key_shape, value_shape, hash, eq, 0, -1, -1, map_ref_scratch_index,
                map_bucket_scratch_index, map_hash_scratch_index, map_entry_scratch_index,
                map_previous_scratch_index, map_growth_index_scratch_index,
              ),
            )
          @semantic.PlannedMapSingleton(
            key,
            value,
            key_shape,
            value_shape,
            hash,
            eq
          ) => {
            tasks.push(
              FinishStarshineMap(
                1,
                key_shape,
                value_shape,
                hash,
                eq,
                2,
                map_key_local_indices[expression - body.expressions.start],
                map_value_local_indices[expression - body.expressions.start],
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(key))
          }
          @semantic.PlannedMapLength(base) => {
            tasks.push(
              FinishStarshineMap(
                2,
                source.shape,
                source.shape,
                0UL,
                0UL,
                1,
                -1,
                -1,
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapGet(base, key, key_shape, value_shape, hash, eq)
          | @semantic.PlannedMapGetUnchecked(
            base,
            key,
            key_shape,
            value_shape,
            hash,
            eq
          ) => {
            let operation = match source.kind {
              @semantic.PlannedMapGet(_, _, _, _, _, _) => 3
              _ => 4
            }
            tasks.push(
              FinishStarshineMap(
                operation,
                key_shape,
                value_shape,
                hash,
                eq,
                2,
                map_key_local_indices[expression - body.expressions.start],
                map_value_local_indices[expression - body.expressions.start],
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(key))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapContainsKey(base, key, key_shape, hash, eq)
          | @semantic.PlannedMapRemove(base, key, key_shape, hash, eq) => {
            let operation = match source.kind {
              @semantic.PlannedMapContainsKey(_, _, _, _, _) => 7
              _ => 9
            }
            tasks.push(
              FinishStarshineMap(
                operation,
                key_shape,
                key_shape,
                hash,
                eq,
                2,
                map_key_local_indices[expression - body.expressions.start],
                -1,
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(key))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapClear(base) => {
            tasks.push(
              FinishStarshineMap(
                10,
                source.shape,
                source.shape,
                0UL,
                0UL,
                1,
                -1,
                -1,
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedMapInsert(
            base,
            key,
            value,
            key_shape,
            value_shape,
            hash,
            eq
          )
          | @semantic.PlannedMapSet(
            base,
            key,
            value,
            key_shape,
            value_shape,
            hash,
            eq
          ) => {
            let operation = match source.kind {
              @semantic.PlannedMapInsert(_, _, _, _, _, _, _) => 5
              _ => 6
            }
            tasks.push(
              FinishStarshineMap(
                operation,
                key_shape,
                value_shape,
                hash,
                eq,
                3,
                map_key_local_indices[expression - body.expressions.start],
                map_value_local_indices[expression - body.expressions.start],
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(key))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedSetEmpty(key_shape, hash, eq) =>
            tasks.push(
              FinishStarshineSet(
                1, key_shape, hash, eq, 0, -1, map_ref_scratch_index, map_bucket_scratch_index,
                map_hash_scratch_index, map_entry_scratch_index, map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
          @semantic.PlannedSetSingleton(key, key_shape, hash, eq) => {
            tasks.push(
              FinishStarshineSet(
                2,
                key_shape,
                hash,
                eq,
                1,
                map_key_local_indices[expression - body.expressions.start],
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(key))
          }
          @semantic.PlannedSetLength(base)
          | @semantic.PlannedSetIsEmpty(base)
          | @semantic.PlannedSetClear(base) => {
            let operation = match source.kind {
              @semantic.PlannedSetLength(_) => 3
              @semantic.PlannedSetIsEmpty(_) => 4
              _ => 8
            }
            tasks.push(
              FinishStarshineSet(
                operation,
                source.shape,
                0UL,
                0UL,
                1,
                -1,
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedSetContains(base, key, key_shape, hash, eq)
          | @semantic.PlannedSetInsert(base, key, key_shape, hash, eq)
          | @semantic.PlannedSetRemove(base, key, key_shape, hash, eq) => {
            let operation = match source.kind {
              @semantic.PlannedSetContains(_, _, _, _, _) => 5
              @semantic.PlannedSetInsert(_, _, _, _, _) => 6
              _ => 7
            }
            tasks.push(
              FinishStarshineSet(
                operation,
                key_shape,
                hash,
                eq,
                2,
                map_key_local_indices[expression - body.expressions.start],
                map_ref_scratch_index,
                map_bucket_scratch_index,
                map_hash_scratch_index,
                map_entry_scratch_index,
                map_previous_scratch_index,
                map_growth_index_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(key))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedStructNew(_, _, _)
          | @semantic.PlannedVariantTupleNew(_, _, _)
          | @semantic.PlannedVariantStructNew(_, _, _) => {
            let evaluations = starshine_constructor_evaluations(
              lowering,
              source.kind,
            )
            let declaration = match source.kind {
              @semantic.PlannedStructNew(value, _, _)
              | @semantic.PlannedVariantTupleNew(value, _, _)
              | @semantic.PlannedVariantStructNew(value, _, _) => value
              _ => return Err(UnsupportedExpression(body.body, expression))
            }
            let owner_module = match program {
              Some(link) =>
                match
                  link.module_lookup.get(
                    @semantic.semantic_id_module(declaration),
                  ) {
                  Some(value) => value
                  None =>
                    return Err(UnsupportedExpression(body.body, expression))
                }
              None => program_module_index
            }
            let physical_plan = match program {
              Some(link) => link.modules[owner_module]
              None => planned
            }
            let shapes = evaluations.map(fn(value) {
              let source = lowering.expressions[value]
              starshine_specialized_shape(
                lowering,
                generic_specialization,
                source.type_,
                source.shape,
              )
            })
            let (physical, tag) = match source.kind {
              @semantic.PlannedStructNew(_, _, _) =>
                (starshine_struct_physical_type(physical_plan, declaration), -1)
              _ => {
                let expected = match source.kind {
                  @semantic.PlannedVariantTupleNew(_, _, _) =>
                    StarshineExpectedTupleFields(shapes)
                  @semantic.PlannedVariantStructNew(_, _, fields) => {
                    let ids : Array[@semantic.FieldId] = []
                    for index in 0..<fields.length {
                      ids.push(
                        lowering.object_fields[fields.start + index].field,
                      )
                    }
                    StarshineExpectedStructFields(ids, shapes)
                  }
                  _ => return Err(UnsupportedExpression(body.body, expression))
                }
                let tag = match physical_plan.variant_tag_of(declaration) {
                  Some(value) => value
                  None =>
                    return Err(UnsupportedExpression(body.body, expression))
                }
                (
                  starshine_variant_payload_physical_type_for_fields(
                    physical_plan, declaration, expected,
                  ),
                  tag,
                )
              }
            }
            let physical = match physical {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            let sources : Array[Int] = []
            let first_field = if tag < 0 { 0 } else { 1 }
            for field_index in first_field..<physical.fields.length {
              let field = physical_plan.fields[physical.fields.start +
                field_index]
              let mut source_index = -1
              match (source.kind, field.role) {
                (
                  @semantic.PlannedVariantTupleNew(_, _, _),
                  @semantic.WasmTuplePayloadField(_, index),
                ) => source_index = index
                (
                  @semantic.PlannedStructNew(_, _, fields),
                  @semantic.WasmStructField(id),
                )
                | (
                  @semantic.PlannedVariantStructNew(_, _, fields),
                  @semantic.WasmStructPayloadField(id),
                ) =>
                  for index in 0..<fields.length {
                    if lowering.object_fields[fields.start + index].field == id {
                      source_index = index
                      break
                    }
                  }
                _ => return Err(UnsupportedExpression(body.body, expression))
              }
              if source_index < 0 || source_index >= evaluations.length() {
                return Err(UnsupportedExpression(body.body, expression))
              }
              sources.push(
                if starshine_shape_matches_storage(
                    shapes[source_index],
                    field.storage,
                  ) {
                  source_index
                } else {
                  -1
                },
              )
            }
            tasks.push(
              FinishStarshineConstructor(
                program, owner_module, physical_plan, physical, tag, evaluations,
                sources,
              ),
            )
            let mut index = evaluations.length()
            while index > 0 {
              index -= 1
              tasks.push(EmitStarshineExpression(evaluations[index]))
            }
          }
          @semantic.PlannedPackedEnumPayload(tag, payload) => {
            tasks.push(FinishStarshinePackedEnumPayload(tag))
            tasks.push(EmitStarshineExpression(payload))
          }
          @semantic.PlannedUnitVariant(variant, _) => {
            let owner_module = match program {
              Some(link) =>
                link.module_lookup
                .get(@semantic.semantic_id_module(variant))
                .unwrap_or(program_module_index)
              None => program_module_index
            }
            let variant_plan = match program {
              Some(link) => link.modules[owner_module]
              None => planned
            }
            let tag = match variant_plan.variant_tag_of(variant) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            let physical = match
              starshine_variant_payload_physical_type(variant_plan, variant) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(
              FinishStarshineEnumSubtype(
                program, owner_module, variant_plan, physical, tag, 0,
              ),
            )
          }
          @semantic.PlannedMatchExpression(scrutinee, arms) => {
            let scratch_local = match_local_indices[expression -
              body.expressions.start]
            if scratch_local < 0 {
              return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(FinishStarshineMatch(expression, arms, scratch_local))
            let mut arm_index = arms.length
            while arm_index > 0 {
              arm_index -= 1
              let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
                arm_index]]
              tasks.push(EmitStarshineExpression(arm.body))
              if arm.guard_condition >= 0 {
                tasks.push(EmitStarshineExpression(arm.guard_condition))
              }
            }
            tasks.push(EmitStarshineExpression(scrutinee))
          }
          @semantic.PlannedWhileExpression(control, initial, arms) => {
            if control < 0 || control >= control_state_local_indices.length() {
              return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(
              FinishStarshineWhile(
                expression,
                control,
                arms,
                control_state_local_indices[control],
                control_result_local_indices[control],
              ),
            )
            let mut arm_index = arms.length
            while arm_index > 0 {
              arm_index -= 1
              let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
                arm_index]]
              tasks.push(EmitStarshineExpression(arm.body))
              if arm.guard_condition >= 0 {
                tasks.push(EmitStarshineExpression(arm.guard_condition))
              }
            }
            tasks.push(EmitStarshineExpression(initial))
          }
          @semantic.PlannedReturnExpression(value) =>
            if value < 0 {
              results.push([@lib.Instruction::return_()])
            } else {
              tasks.push(FinishStarshineReturn)
              tasks.push(EmitStarshineExpression(value))
            }
          @semantic.PlannedBreakExpression(control, value) => {
            let value_source = lowering.expressions[value]
            tasks.push(
              FinishStarshineControlTransfer(
                control,
                true,
                starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  value_source.type_,
                  value_source.shape,
                ),
              ),
            )
            tasks.push(EmitStarshineExpression(value))
          }
          @semantic.PlannedContinueExpression(control, value) => {
            let value_source = lowering.expressions[value]
            tasks.push(
              FinishStarshineControlTransfer(
                control,
                false,
                starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  value_source.type_,
                  value_source.shape,
                ),
              ),
            )
            tasks.push(EmitStarshineExpression(value))
          }
          @semantic.PlannedPrefixExpression(operator, operand) => {
            tasks.push(FinishStarshinePrefix(operator, source.shape))
            tasks.push(EmitStarshineExpression(operand))
          }
          @semantic.PlannedBinaryExpression(operator, left, right) =>
            match operator {
              @semantic.HirLogicalAnd | @semantic.HirLogicalOr => {
                tasks.push(FinishStarshineLogical(operator))
                tasks.push(EmitStarshineExpression(right))
                tasks.push(EmitStarshineExpression(left))
              }
              _ => return Err(UnsupportedExpression(body.body, expression))
            }
          @semantic.PlannedProductField(_, _, _) => {
            let (local_id, leaf_offset) = match
              starshine_product_projection_root(lowering, expression) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            if local_id < 0 ||
              local_id >= local_indices.length() ||
              local_indices[local_id] < 0 {
              return Err(InvalidLocal(body.body, local_id))
            }
            let shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              source.type_,
              source.shape,
            )
            let output : Array[@lib.Instruction] = []
            starshine_append_product_local_gets(
              output,
              local_indices[local_id] + leaf_offset,
              shape,
            )
            results.push(output)
          }
          @semantic.PlannedFieldGet(field, base, _) => {
            let owner_module = match program {
              Some(link) =>
                link.module_lookup
                .get(@semantic.semantic_id_module(field))
                .unwrap_or(program_module_index)
              None => program_module_index
            }
            let field_plan = match program {
              Some(link) => link.modules[owner_module]
              None => planned
            }
            let field_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              source.type_,
              source.shape,
            )
            let locations = starshine_field_locations(
              field_plan, program, owner_module, field, field_shape,
            )
            if locations.is_empty() {
              return Err(UnsupportedExpression(body.body, expression))
            }
            let first_location = locations[0]
            if field_shape is @semantic.ProductPlannedValueShape(_) {
              tasks.push(
                FinishStarshineProductUnbox(
                  field_shape, fixed_array_ref_scratch_index,
                ),
              )
            }
            if locations.length() > 1 {
              tasks.push(
                FinishStarshinePolymorphicFieldGet(
                  locations, fixed_array_ref_scratch_index, field_shape,
                ),
              )
            } else {
              tasks.push(
                FinishStarshineFieldGet(
                  first_location.type_index,
                  first_location.field_index,
                  first_location.storage,
                ),
              )
            }
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedFieldSet(field, base, value) => {
            let owner_module = match program {
              Some(link) =>
                link.module_lookup
                .get(@semantic.semantic_id_module(field))
                .unwrap_or(program_module_index)
              None => program_module_index
            }
            let field_plan = match program {
              Some(link) => link.modules[owner_module]
              None => planned
            }
            let value_source = lowering.expressions[value]
            let field_shape = starshine_specialized_shape(
              lowering,
              generic_specialization,
              value_source.type_,
              value_source.shape,
            )
            if field_shape is @semantic.UnitPlannedValueShape {
              tasks.push(FinishStarshineUnitFieldSet)
              tasks.push(EmitStarshineExpression(value))
              tasks.push(EmitStarshineExpression(base))
            } else {
              let (local_type_index, physical_index, _) = match
                starshine_field_location(field_plan, field, field_shape) {
                Some(location) => location
                None => return Err(UnsupportedExpression(body.body, expression))
              }
              let type_index = match program {
                Some(link) =>
                  link.physical_type_index(owner_module, local_type_index)
                None => local_type_index
              }
              tasks.push(FinishStarshineFieldSet(type_index, physical_index))
              if field_shape is @semantic.ProductPlannedValueShape(_) {
                tasks.push(
                  FinishStarshineProductBox(
                    field_shape,
                    match_result_local_indices[value - body.expressions.start],
                  ),
                )
              }
              tasks.push(EmitStarshineExpression(value))
              tasks.push(EmitStarshineExpression(base))
            }
          }
          @semantic.PlannedModuleValueGet(declaration, nominal) =>
            match program {
              Some(link) =>
                match link.global_lookup.get(declaration) {
                  Some(index) => {
                    let output = [
                      @lib.Instruction::global_get(
                        @lib.GlobalIdx::new(index.reinterpret_as_uint()),
                      ),
                    ]
                    if nominal != 0UL {
                      match link.type_lookup.get(nominal) {
                        Some(type_index) =>
                          output.push(starshine_match_cast(type_index))
                        None =>
                          return Err(
                            UnsupportedExpression(body.body, expression),
                          )
                      }
                    }
                    let value_shape = starshine_specialized_shape(
                      lowering,
                      generic_specialization,
                      source.type_,
                      source.shape,
                    )
                    if value_shape is @semantic.ProductPlannedValueShape(_) {
                      if fixed_array_ref_scratch_index < 0 {
                        return Err(UnsupportedExpression(body.body, -427))
                      }
                      output.push(
                        @lib.Instruction::local_set(
                          @lib.LocalIdx::new(
                            fixed_array_ref_scratch_index.reinterpret_as_uint(),
                          ),
                        ),
                      )
                      match
                        starshine_append_product_unbox(
                          output,
                          planned,
                          program,
                          body.body,
                          fixed_array_ref_scratch_index,
                          value_shape,
                        ) {
                        Ok(_) => ()
                        Err(error) => return Err(error)
                      }
                    }
                    results.push(output)
                  }
                  None =>
                    match source.shape {
                      @semantic.UnitPlannedValueShape => results.push([])
                      _ =>
                        return Err(UnsupportedExpression(body.body, expression))
                    }
                }
              None => return Err(UnsupportedExpression(body.body, expression))
            }
          @semantic.PlannedPoisonExpression
          | @semantic.PlannedDeferredExpression
          | @semantic.PlannedConsumedExpression =>
            return Err(UnsupportedExpression(body.body, expression))
        }
      }
      EmitStarshineEmpty => results.push([])
      EmitStarshineBlock(block) => {
        let source = lowering.blocks[block]
        tasks.push(FinishStarshineBlock(block))
        let mut index = source.items.length
        while index > 0 {
          index -= 1
          let item = lowering.block_items[source.items.start + index]
          match item.kind {
            @semantic.PlannedLetItem(_, _, expression)
            | @semantic.PlannedExpressionItem(expression) =>
              tasks.push(EmitStarshineExpression(expression))
            @semantic.PlannedElidedLetItem(_) => tasks.push(EmitStarshineEmpty)
          }
        }
      }
      FinishStarshineLocalSet(local_id, local_index, source_expression) => {
        let value = results.pop().unwrap()
        let output : Array[@lib.Instruction] = []
        let cell_slot = starshine_local_capture_cell_slot(
          lowering, body, local_id,
        )
        if cell_slot >= 0 {
          let cell_type = starshine_capture_cell_type_index(
            planned, program, program_module_index, cell_slot,
          )
          let local_info = lowering.locals[body.locals.start + local_id]
          let local_shape = starshine_specialized_shape(
            lowering,
            generic_specialization,
            local_info.type_,
            local_info.shape,
          )
          if local_shape is @semantic.ProductPlannedValueShape(_) {
            append_starshine_instructions(output, value)
            starshine_append_product_local_sets(
              output,
              local_index + 2,
              local_shape,
            )
            output.push(
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(local_index.reinterpret_as_uint()),
              ),
            )
            output.push(starshine_match_cast(cell_type))
            match
              starshine_product_box_from_locals(
                planned,
                program,
                body.body,
                local_index + 2,
                local_shape,
              ) {
              Ok(instructions) =>
                append_starshine_instructions(output, instructions)
              Err(error) => return Err(error)
            }
          } else {
            output.push(
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(local_index.reinterpret_as_uint()),
              ),
            )
            output.push(starshine_match_cast(cell_type))
            append_starshine_instructions(output, value)
          }
          output.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(cell_type.reinterpret_as_uint()),
              @lib.U32::new(0U),
            ),
          )
        } else {
          append_starshine_instructions(output, value)
          let local_info = lowering.locals[body.locals.start + local_id]
          let local_shape = starshine_specialized_shape(
            lowering,
            generic_specialization,
            local_info.type_,
            local_info.shape,
          )
          if local_shape is @semantic.ProductPlannedValueShape(_) {
            starshine_append_product_local_sets(
              output, local_index, local_shape,
            )
            results.push(output)
            continue
          }
          starshine_append_precise_nominal_local_cast(
            lowering, planned, program, body, local_id, source_expression, output,
          )
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(local_index.reinterpret_as_uint()),
            ),
          )
        }
        results.push(output)
      }
      FinishStarshineCaptureSet(lambda, capture, value_expression, scratch) => {
        let value = results.pop().unwrap()
        if lambda < 0 || lambda >= lowering.lambdas.length() {
          return Err(UnsupportedExpression(body.body, -201))
        }
        let global_capture = lowering.lambdas[lambda].captures.start + capture
        if global_capture < 0 || global_capture >= lowering.captures.length() {
          return Err(UnsupportedExpression(body.body, -202))
        }
        let capture_plan = lowering.captures[global_capture]
        let slot = @semantic.wasmgc_capture_cell_slot(capture_plan.shape)
        if slot < 0 {
          results.push(value)
          continue
        }
        let cell_type = starshine_capture_cell_type_index(
          planned, program, program_module_index, slot,
        )
        let value_source = lowering.expressions[value_expression]
        let value_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          value_source.type_,
          value_source.shape,
        )
        let output : Array[@lib.Instruction] = []
        if value_shape is @semantic.ProductPlannedValueShape(_) {
          if scratch < 0 {
            return Err(UnsupportedExpression(body.body, -424))
          }
          append_starshine_instructions(output, value)
          starshine_append_product_local_sets(output, scratch, value_shape)
          append_starshine_instructions(
            output,
            starshine_capture_cell_reference_instructions(
              lowering, planned, program, program_module_index, lambda, capture,
            ),
          )
          output.push(starshine_match_cast(cell_type))
          match
            starshine_product_box_from_locals(
              planned,
              program,
              body.body,
              scratch,
              value_shape,
            ) {
            Ok(instructions) =>
              append_starshine_instructions(output, instructions)
            Err(error) => return Err(error)
          }
        } else {
          append_starshine_instructions(
            output,
            starshine_capture_cell_reference_instructions(
              lowering, planned, program, program_module_index, lambda, capture,
            ),
          )
          output.push(starshine_match_cast(cell_type))
          append_starshine_instructions(output, value)
        }
        output.push(
          @lib.Instruction::struct_set(
            @lib.TypeIdx::new(cell_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
        )
        results.push(output)
      }
      FinishStarshineBlock(block) => {
        let source = lowering.blocks[block]
        let fragments = pop_starshine_fragments(results, source.items.length)
        let output : Array[@lib.Instruction] = []
        for index in 0..<source.items.length {
          let item = lowering.block_items[source.items.start + index]
          append_starshine_instructions(output, fragments[index])
          match item.kind {
            @semantic.PlannedLetItem(local_id, _, expression) => {
              if local_id >= 0 &&
                local_id < local_indices.length() &&
                local_indices[local_id] < 0 {
                let local_info = lowering.locals[body.locals.start + local_id]
                match starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  local_info.type_,
                  local_info.shape,
                ) {
                  @semantic.UnitPlannedValueShape => continue
                  _ => ()
                }
              }
              if local_id < 0 ||
                local_id >= local_indices.length() ||
                local_indices[local_id] < 0 {
                return Err(InvalidLocal(body.body, local_id))
              }
              let local_info = lowering.locals[body.locals.start + local_id]
              let local_shape = starshine_specialized_shape(
                lowering,
                generic_specialization,
                local_info.type_,
                local_info.shape,
              )
              let cell_slot = starshine_local_capture_cell_slot(
                lowering, body, local_id,
              )
              if local_shape is @semantic.ProductPlannedValueShape(_) {
                if cell_slot >= 0 {
                  starshine_append_product_local_sets(
                    output,
                    local_indices[local_id] + 2,
                    local_shape,
                  )
                  match
                    starshine_product_box_from_locals(
                      planned,
                      program,
                      body.body,
                      local_indices[local_id] + 2,
                      local_shape,
                    ) {
                    Ok(instructions) =>
                      append_starshine_instructions(output, instructions)
                    Err(error) => return Err(error)
                  }
                  let cell_type = starshine_capture_cell_type_index(
                    planned, program, program_module_index, cell_slot,
                  )
                  output.push(
                    @lib.Instruction::struct_new(
                      @lib.TypeIdx::new(cell_type.reinterpret_as_uint()),
                    ),
                  )
                  output.push(
                    @lib.Instruction::local_set(
                      @lib.LocalIdx::new(
                        local_indices[local_id].reinterpret_as_uint(),
                      ),
                    ),
                  )
                } else {
                  starshine_append_product_local_sets(
                    output,
                    local_indices[local_id],
                    local_shape,
                  )
                }
                continue
              }
              if cell_slot >= 0 {
                let cell_type = starshine_capture_cell_type_index(
                  planned, program, program_module_index, cell_slot,
                )
                output.push(
                  @lib.Instruction::struct_new(
                    @lib.TypeIdx::new(cell_type.reinterpret_as_uint()),
                  ),
                )
              }
              starshine_append_precise_nominal_local_cast(
                lowering, planned, program, body, local_id, expression, output,
              )
              output.push(
                @lib.Instruction::local_set(
                  @lib.LocalIdx::new(
                    local_indices[local_id].reinterpret_as_uint(),
                  ),
                ),
              )
            }
            @semantic.PlannedElidedLetItem(_) => ()
            @semantic.PlannedExpressionItem(expression) =>
              if index + 1 < source.items.length {
                let expression_source = lowering.expressions[expression]
                starshine_append_shape_drops(
                  output,
                  starshine_specialized_shape(
                    lowering,
                    generic_specialization,
                    expression_source.type_,
                    expression_source.shape,
                  ),
                )
              }
          }
        }
        results.push(output)
      }
      FinishStarshineRefIntrinsic(operation) => {
        let output = results.pop().unwrap()
        if operation == 1 {
          output.push(@lib.Instruction::ref_is_null())
        } else if operation == 2 {
          output.push(@lib.Instruction::ref_as_non_null())
        } else {
          abort("unknown nullable-reference intrinsic")
        }
        results.push(output)
      }
      FinishStarshineFixedArray(
        operation,
        shape,
        count,
        ref_scratch,
        i32_scratch
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        if operation == 2 {
          let output = fragments[0]
          output.push(
            @lib.Instruction::ref_cast(
              false,
              @lib.HeapType::abs(@lib.AbsHeapType::array()),
            ),
          )
          output.push(@lib.Instruction::array_len())
          results.push(output)
          continue
        }
        let backing = match
          starshine_fixed_array_backing_prefix(planned, program, shape) {
          Some(value) => value
          None => return Err(UnsupportedExpression(body.body, -101))
        }
        let backing_prefix = backing.0
        let array_type = backing.1
        let output : Array[@lib.Instruction] = []
        if operation == 1 {
          if ref_scratch < 0 || i32_scratch < 0 {
            return Err(UnsupportedExpression(body.body, -1))
          }
          append_starshine_instructions(output, fragments[0])
          append_starshine_instructions(output, fragments[1])
          starshine_array_append_unit_marker(output, Some(shape))
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(ref_scratch.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(i32_scratch.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(ref_scratch.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(i32_scratch.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::array_new(
              @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 4 {
          append_starshine_instructions(output, fragments[0])
          append_starshine_instructions(output, backing_prefix)
          append_starshine_instructions(output, fragments[1])
          output.push(starshine_fixed_array_get_instruction(shape, array_type))
          if shape is @semantic.UnitPlannedValueShape {
            output.push(@lib.Instruction::drop())
          }
        } else if operation == 5 {
          append_starshine_instructions(output, fragments[0])
          append_starshine_instructions(output, backing_prefix)
          append_starshine_instructions(output, fragments[1])
          append_starshine_instructions(output, fragments[2])
          starshine_array_append_unit_marker(output, Some(shape))
          output.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 6 {
          append_starshine_instructions(output, fragments[0])
          output.push(
            @lib.Instruction::array_new_default(
              @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 7 {
          append_starshine_instructions(output, fragments[0])
          append_starshine_instructions(output, backing_prefix)
          append_starshine_instructions(output, fragments[1])
          append_starshine_instructions(output, fragments[2])
          append_starshine_instructions(output, backing_prefix)
          append_starshine_instructions(output, fragments[3])
          append_starshine_instructions(output, fragments[4])
          output.push(
            @lib.Instruction::array_copy(
              @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
              @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
            ),
          )
        } else {
          return Err(UnsupportedExpression(body.body, -1))
        }
        results.push(output)
      }
      FinishStarshineArrayLiteral(
        shape,
        count,
        backing_local,
        value_local,
        product_local
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        match
          starshine_finish_array_literal(
            planned,
            program,
            body.body,
            shape,
            fragments,
            backing_local,
            value_local,
            product_local,
          ) {
          Ok(output) => results.push(output)
          Err(error) => return Err(error)
        }
      }
      FinishStarshineArray(
        operation,
        shape,
        count,
        wrapper_local,
        backing_local,
        index_local,
        value_local
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        match
          starshine_finish_array(
            planned,
            program,
            body.body,
            operation,
            shape,
            fragments,
            wrapper_local,
            backing_local,
            index_local,
            value_local,
          ) {
          Ok(output) => results.push(output)
          Err(error) => return Err(error)
        }
      }
      FinishStarshineHashIter(
        operation,
        key_shape,
        value_shape,
        count,
        iterator_local,
        state_local,
        entry_local,
        index_local
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        match
          starshine_finish_hash_iter(
            planned,
            program,
            body.body,
            operation,
            key_shape,
            value_shape,
            fragments,
            iterator_local,
            state_local,
            entry_local,
            index_local,
          ) {
          Ok(output) => results.push(output)
          Err(error) => return Err(error)
        }
      }
      FinishStarshineSet(
        operation,
        key_shape,
        hash_declaration,
        eq_declaration,
        count,
        key_local,
        set_local,
        bucket_local,
        hash_local,
        entry_local,
        previous_local,
        growth_index_local
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        let wrapper_type = match
          starshine_emitted_type_index(
            planned,
            program,
            @semantic.standard_set_type_declaration(),
          ) {
          Some(value) => value
          None => return Err(UnsupportedExpression(body.body, -301))
        }
        let map_base = starshine_map_base_for_body(planned, program)
        let bucket_type = map_base
        let entry_type = map_base + 1
        let output : Array[@lib.Instruction] = []
        if operation == 1 {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(16)))
          output.push(
            @lib.Instruction::array_new_default(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          output.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            ),
          )
          results.push(output)
          continue
        }
        if operation == 3 || operation == 4 {
          append_starshine_instructions(output, fragments[0])
          output.push(starshine_match_cast(wrapper_type))
          output.push(
            @lib.Instruction::struct_get(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          if operation == 4 {
            output.push(@lib.Instruction::i32_eqz())
          }
          results.push(output)
          continue
        }
        if operation == 8 {
          if set_local < 0 {
            return Err(UnsupportedExpression(body.body, -302))
          }
          append_starshine_instructions(output, fragments[0])
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(wrapper_type))
          output.push(@lib.Instruction::i32_const(@lib.I32::new(16)))
          output.push(
            @lib.Instruction::array_new_default(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(0U),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(wrapper_type))
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          output.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          results.push(output)
          continue
        }
        if key_local < 0 ||
          set_local < 0 ||
          bucket_local < 0 ||
          hash_local < 0 ||
          entry_local < 0 ||
          ((operation == 6 || operation == 7) && previous_local < 0) ||
          (operation == 6 && growth_index_local < 0) {
          return Err(UnsupportedExpression(body.body, -303))
        }
        if operation != 2 {
          append_starshine_instructions(output, fragments[0])
        }
        let key_fragment = if operation == 2 {
          fragments[0]
        } else {
          fragments[1]
        }
        append_starshine_instructions(output, key_fragment)
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
          ),
        )
        let hash_call = match
          starshine_map_call(planned, program, hash_declaration, [
            [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
              ),
            ],
          ]) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        append_starshine_instructions(output, hash_call)
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
          ),
        )
        if operation == 2 {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(16)))
          output.push(
            @lib.Instruction::array_new_default(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          append_starshine_instructions(
            output,
            starshine_set_new_entry_instructions(
              entry_type,
              [
                @lib.Instruction::ref_null(
                  @lib.HeapType::abs(@lib.AbsHeapType::eq()),
                ),
              ],
              key_shape,
              key_local,
              hash_local,
            ),
          )
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(bucket_type))
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
          )
          output.push(@lib.Instruction::i32_wrap_i64())
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(bucket_type))
          output.push(@lib.Instruction::array_len())
          output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          output.push(@lib.Instruction::i32_sub())
          output.push(@lib.Instruction::i32_and())
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          output.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            ),
          )
          results.push(output)
          continue
        }
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
          ),
        )
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(wrapper_type))
        output.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
        )
        output.push(starshine_match_cast(bucket_type))
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
          ),
        )
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(bucket_type))
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
          ),
        )
        output.push(@lib.Instruction::i32_wrap_i64())
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(bucket_type))
        output.push(@lib.Instruction::array_len())
        output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        output.push(@lib.Instruction::i32_sub())
        output.push(@lib.Instruction::i32_and())
        output.push(
          @lib.Instruction::array_get(
            @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
          ),
        )
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
        )
        if operation == 7 {
          output.push(
            @lib.Instruction::ref_null(
              @lib.HeapType::abs(@lib.AbsHeapType::eq()),
            ),
          )
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
          )
        }
        let on_null : Array[@lib.Instruction] = []
        if operation == 6 {
          append_starshine_instructions(
            on_null,
            starshine_hash_table_growth_instructions(
              wrapper_type, bucket_type, entry_type, set_local, bucket_local, entry_local,
              previous_local, growth_index_local,
            ),
          )
          let next = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
            @lib.Instruction::i32_wrap_i64(),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::array_len(),
            @lib.Instruction::i32_const(@lib.I32::new(1)),
            @lib.Instruction::i32_sub(),
            @lib.Instruction::i32_and(),
            @lib.Instruction::array_get(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          ]
          append_starshine_instructions(
            on_null,
            starshine_set_new_entry_instructions(
              entry_type, next, key_shape, key_local, hash_local,
            ),
          )
          on_null.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          on_null.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          on_null.push(starshine_match_cast(bucket_type))
          on_null.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
          )
          on_null.push(@lib.Instruction::i32_wrap_i64())
          on_null.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          on_null.push(starshine_match_cast(bucket_type))
          on_null.push(@lib.Instruction::array_len())
          on_null.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          on_null.push(@lib.Instruction::i32_sub())
          on_null.push(@lib.Instruction::i32_and())
          on_null.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          on_null.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          on_null.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
            ),
          )
          on_null.push(starshine_match_cast(wrapper_type))
          on_null.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
            ),
          )
          on_null.push(starshine_match_cast(wrapper_type))
          on_null.push(
            @lib.Instruction::struct_get(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          on_null.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          on_null.push(@lib.Instruction::i32_add())
          on_null.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          on_null.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        } else {
          on_null.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
        }
        on_null.push(@lib.Instruction::br(@lib.LabelIdx::new(2U)))
        let loop_body : Array[@lib.Instruction] = [
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
          @lib.Instruction::ref_is_null(),
          @lib.Instruction::if_(@lib.BlockType::void_(), on_null, None),
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
          starshine_match_cast(entry_type),
          starshine_map_entry_get(entry_type, 1),
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
          ),
          @lib.Instruction::i64_eq(),
        ]
        let on_hash : Array[@lib.Instruction] = []
        let eq_call = match
          starshine_map_call(planned, program, eq_declaration, [
            [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
              ),
              starshine_match_cast(entry_type),
              starshine_map_entry_get(
                entry_type,
                starshine_map_entry_field(key_shape, false),
              ),
            ],
            [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
              ),
            ],
          ]) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        append_starshine_instructions(on_hash, eq_call)
        let found : Array[@lib.Instruction] = []
        if operation == 5 {
          found.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        } else if operation == 6 {
          found.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
        } else {
          let next_entry = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(entry_type),
            starshine_map_entry_get(entry_type, 0),
          ]
          let unlink_head : Array[@lib.Instruction] = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
            @lib.Instruction::i32_wrap_i64(),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::array_len(),
            @lib.Instruction::i32_const(@lib.I32::new(1)),
            @lib.Instruction::i32_sub(),
            @lib.Instruction::i32_and(),
          ]
          append_starshine_instructions(unlink_head, next_entry)
          unlink_head.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          let unlink_tail : Array[@lib.Instruction] = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(entry_type),
          ]
          append_starshine_instructions(unlink_tail, next_entry)
          unlink_tail.push(starshine_map_entry_set(entry_type, 0))
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
          )
          found.push(@lib.Instruction::ref_is_null())
          found.push(
            @lib.Instruction::if_(
              @lib.BlockType::void_(),
              unlink_head,
              Some(unlink_tail),
            ),
          )
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
            ),
          )
          found.push(starshine_match_cast(wrapper_type))
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(set_local.reinterpret_as_uint()),
            ),
          )
          found.push(starshine_match_cast(wrapper_type))
          found.push(
            @lib.Instruction::struct_get(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          found.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          found.push(@lib.Instruction::i32_sub())
          found.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          found.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        }
        found.push(@lib.Instruction::br(@lib.LabelIdx::new(3U)))
        on_hash.push(
          @lib.Instruction::if_(@lib.BlockType::void_(), found, None),
        )
        loop_body.push(
          @lib.Instruction::if_(@lib.BlockType::void_(), on_hash, None),
        )
        if operation == 7 {
          loop_body.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          loop_body.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
          )
        }
        loop_body.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
        )
        loop_body.push(starshine_match_cast(entry_type))
        loop_body.push(starshine_map_entry_get(entry_type, 0))
        loop_body.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
        )
        loop_body.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
        output.push(
          @lib.Instruction::block(
            @lib.BlockType::val_type(@lib.ValType::i32()),
            @lib.Expr::new([
              @lib.Instruction::loop_(
                @lib.BlockType::void_(),
                @lib.Expr::new(loop_body),
              ),
              @lib.Instruction::unreachable_(),
            ]),
          ),
        )
        results.push(output)
      }
      FinishStarshineMap(
        operation,
        key_shape,
        value_shape,
        hash_declaration,
        eq_declaration,
        count,
        key_local,
        value_local,
        map_local,
        bucket_local,
        hash_local,
        entry_local,
        previous_local,
        growth_index_local
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        let wrapper_type = match
          starshine_emitted_type_index(
            planned,
            program,
            @semantic.standard_map_type_declaration(),
          ) {
          Some(value) => value
          None => return Err(UnsupportedExpression(body.body, -201))
        }
        let map_base = starshine_map_base_for_body(planned, program)
        let bucket_type = map_base
        let entry_type = map_base + 1
        let output : Array[@lib.Instruction] = []
        if operation == 2 {
          append_starshine_instructions(output, fragments[0])
          output.push(starshine_match_cast(wrapper_type))
          output.push(
            @lib.Instruction::struct_get(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          results.push(output)
          continue
        }
        if operation == 8 {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(16)))
          output.push(
            @lib.Instruction::array_new_default(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          output.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            ),
          )
          results.push(output)
          continue
        }
        if operation == 10 {
          if map_local < 0 {
            return Err(UnsupportedExpression(body.body, -207))
          }
          append_starshine_instructions(output, fragments[0])
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(wrapper_type))
          output.push(@lib.Instruction::i32_const(@lib.I32::new(16)))
          output.push(
            @lib.Instruction::array_new_default(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(0U),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(wrapper_type))
          output.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
          output.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          results.push(output)
          continue
        }
        if key_local < 0 ||
          map_local < 0 ||
          bucket_local < 0 ||
          hash_local < 0 ||
          entry_local < 0 ||
          (
            (operation == 1 || operation == 5 || operation == 6) &&
            value_local < 0
          ) ||
          (
            (operation == 5 || operation == 6 || operation == 9) &&
            previous_local < 0
          ) ||
          ((operation == 5 || operation == 6) && growth_index_local < 0) {
          return Err(UnsupportedExpression(body.body, -202))
        }
        if operation != 1 {
          append_starshine_instructions(output, fragments[0])
        }
        let key_fragment = if operation == 1 {
          fragments[0]
        } else {
          fragments[1]
        }
        append_starshine_instructions(output, key_fragment)
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
          ),
        )
        if operation == 1 || operation == 5 || operation == 6 {
          let value_fragment = if operation == 1 {
            fragments[1]
          } else {
            fragments[2]
          }
          append_starshine_instructions(output, value_fragment)
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(value_local.reinterpret_as_uint()),
            ),
          )
        }
        let hash_call = match
          starshine_map_call(planned, program, hash_declaration, [
            [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
              ),
            ],
          ]) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        append_starshine_instructions(output, hash_call)
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
          ),
        )
        if operation == 1 {
          output.push(@lib.Instruction::i32_const(@lib.I32::new(16)))
          output.push(
            @lib.Instruction::array_new_default(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          let entry = starshine_map_new_entry_instructions(
            entry_type,
            [
              @lib.Instruction::ref_null(
                @lib.HeapType::abs(@lib.AbsHeapType::eq()),
              ),
            ],
            key_shape,
            value_shape,
            key_local,
            value_local,
            hash_local,
          )
          append_starshine_instructions(output, entry)
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(bucket_type))
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
          )
          output.push(@lib.Instruction::i32_wrap_i64())
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(bucket_type))
          output.push(@lib.Instruction::array_len())
          output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          output.push(@lib.Instruction::i32_sub())
          output.push(@lib.Instruction::i32_and())
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          output.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            ),
          )
          results.push(output)
          continue
        }
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
          ),
        )
        let load_bucket : Array[@lib.Instruction] = [
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
          ),
          starshine_match_cast(wrapper_type),
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
          starshine_match_cast(bucket_type),
        ]
        append_starshine_instructions(output, load_bucket)
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
          ),
        )
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(bucket_type))
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
          ),
        )
        output.push(@lib.Instruction::i32_wrap_i64())
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(bucket_type))
        output.push(@lib.Instruction::array_len())
        output.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        output.push(@lib.Instruction::i32_sub())
        output.push(@lib.Instruction::i32_and())
        output.push(
          @lib.Instruction::array_get(
            @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
          ),
        )
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
        )
        if operation == 9 {
          output.push(
            @lib.Instruction::ref_null(
              @lib.HeapType::abs(@lib.AbsHeapType::eq()),
            ),
          )
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
          )
        }
        let option_plan = match program {
          Some(link) => {
            let option_module = @semantic.semantic_id_module(
              @semantic.standard_option_some_variant(),
            )
            match link.module_lookup.get(option_module) {
              Some(index) => Some((link, index, link.modules[index]))
              None => None
            }
          }
          None => None
        }
        let loop_body : Array[@lib.Instruction] = []
        let missing : Array[@lib.Instruction] = []
        let result_type = if operation == 3 {
          @lib.BlockType::val_type(@lib.ValType::eqref_null())
        } else if operation == 4 {
          match starshine_shape_value_type(value_shape) {
            Some(type_) => @lib.BlockType::val_type(type_)
            None => return Err(UnsupportedExpression(body.body, -203))
          }
        } else if operation == 7 || operation == 9 {
          @lib.BlockType::val_type(@lib.ValType::i32())
        } else {
          @lib.BlockType::void_()
        }
        if operation == 3 {
          let (_, option_module_index, option_module_plan) = match option_plan {
            Some(value) => value
            None => return Err(UnsupportedExpression(body.body, -204))
          }
          let none_variant = @semantic.standard_option_none_variant()
          let none_physical = match
            starshine_variant_payload_physical_type(
              option_module_plan, none_variant,
            ) {
            Some(value) => value
            None => return Err(UnsupportedExpression(body.body, -205))
          }
          let none_type = option_plan.unwrap().0.physical_type_index(
            option_module_index,
            none_physical.type_index,
          )
          missing.push(
            @lib.Instruction::i32_const(
              @lib.I32::new(
                option_module_plan.variant_tag_of(none_variant).unwrap(),
              ),
            ),
          )
          missing.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(none_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 4 {
          missing.push(@lib.Instruction::unreachable_())
        } else if operation == 7 || operation == 9 {
          missing.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
        } else {
          append_starshine_instructions(
            missing,
            starshine_hash_table_growth_instructions(
              wrapper_type, bucket_type, entry_type, map_local, bucket_local, entry_local,
              previous_local, growth_index_local,
            ),
          )
          let next = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
            @lib.Instruction::i32_wrap_i64(),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::array_len(),
            @lib.Instruction::i32_const(@lib.I32::new(1)),
            @lib.Instruction::i32_sub(),
            @lib.Instruction::i32_and(),
            @lib.Instruction::array_get(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          ]
          append_starshine_instructions(
            missing,
            starshine_map_new_entry_instructions(
              entry_type, next, key_shape, value_shape, key_local, value_local, hash_local,
            ),
          )
          missing.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          missing.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          missing.push(starshine_match_cast(bucket_type))
          missing.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
          )
          missing.push(@lib.Instruction::i32_wrap_i64())
          missing.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
          )
          missing.push(starshine_match_cast(bucket_type))
          missing.push(@lib.Instruction::array_len())
          missing.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          missing.push(@lib.Instruction::i32_sub())
          missing.push(@lib.Instruction::i32_and())
          missing.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          missing.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          missing.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
            ),
          )
          missing.push(starshine_match_cast(wrapper_type))
          missing.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
            ),
          )
          missing.push(starshine_match_cast(wrapper_type))
          missing.push(
            @lib.Instruction::struct_get(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          missing.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          missing.push(@lib.Instruction::i32_add())
          missing.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
        }
        append_starshine_instructions(loop_body, missing)
        loop_body.push(@lib.Instruction::br(@lib.LabelIdx::new(2U)))
        let on_null = loop_body.copy()
        loop_body.clear()
        loop_body.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
        )
        loop_body.push(starshine_match_cast(entry_type))
        loop_body.push(starshine_map_entry_get(entry_type, 1))
        loop_body.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
          ),
        )
        loop_body.push(@lib.Instruction::i64_eq())
        let on_hash : Array[@lib.Instruction] = []
        let key_field = starshine_map_entry_field(key_shape, false)
        let eq_call = match
          starshine_map_call(planned, program, eq_declaration, [
            [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
              ),
              starshine_match_cast(entry_type),
              starshine_map_entry_get(entry_type, key_field),
            ],
            [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
              ),
            ],
          ]) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        append_starshine_instructions(on_hash, eq_call)
        let found : Array[@lib.Instruction] = []
        if operation == 3 {
          let (link, option_module_index, option_module_plan) = option_plan.unwrap()
          let some_variant = @semantic.standard_option_some_variant()
          let some_physical = match
            starshine_variant_payload_physical_type_for_fields(
              option_module_plan,
              some_variant,
              StarshineExpectedTupleFields([value_shape]),
            ) {
            Some(value) => value
            None => return Err(UnsupportedExpression(body.body, -206))
          }
          let some_type = link.physical_type_index(
            option_module_index,
            some_physical.type_index,
          )
          found.push(
            @lib.Instruction::i32_const(
              @lib.I32::new(
                option_module_plan.variant_tag_of(some_variant).unwrap(),
              ),
            ),
          )
          for field_offset in 1..<some_physical.fields.length {
            let field = option_module_plan.fields[some_physical.fields.start +
              field_offset]
            if starshine_shape_matches_storage(value_shape, field.storage) {
              found.push(
                @lib.Instruction::local_get(
                  @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
                ),
              )
              found.push(starshine_match_cast(entry_type))
              found.push(
                starshine_map_entry_get(
                  entry_type,
                  starshine_map_entry_field(value_shape, true),
                ),
              )
            } else {
              append_starshine_instructions(
                found,
                starshine_default_storage_instructions(field.storage),
              )
            }
          }
          found.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(some_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 4 {
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          found.push(starshine_match_cast(entry_type))
          found.push(
            starshine_map_entry_get(
              entry_type,
              starshine_map_entry_field(value_shape, true),
            ),
          )
        } else if operation == 7 {
          found.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        } else if operation == 9 {
          let next_entry = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(entry_type),
            starshine_map_entry_get(entry_type, 0),
          ]
          let unlink_head : Array[@lib.Instruction] = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(hash_local.reinterpret_as_uint()),
            ),
            @lib.Instruction::i32_wrap_i64(),
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(bucket_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(bucket_type),
            @lib.Instruction::array_len(),
            @lib.Instruction::i32_const(@lib.I32::new(1)),
            @lib.Instruction::i32_sub(),
            @lib.Instruction::i32_and(),
          ]
          append_starshine_instructions(unlink_head, next_entry)
          unlink_head.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(bucket_type.reinterpret_as_uint()),
            ),
          )
          let unlink_tail : Array[@lib.Instruction] = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
            starshine_match_cast(entry_type),
          ]
          append_starshine_instructions(unlink_tail, next_entry)
          unlink_tail.push(starshine_map_entry_set(entry_type, 0))
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
          )
          found.push(@lib.Instruction::ref_is_null())
          found.push(
            @lib.Instruction::if_(
              @lib.BlockType::void_(),
              unlink_head,
              Some(unlink_tail),
            ),
          )
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
            ),
          )
          found.push(starshine_match_cast(wrapper_type))
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(map_local.reinterpret_as_uint()),
            ),
          )
          found.push(starshine_match_cast(wrapper_type))
          found.push(
            @lib.Instruction::struct_get(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          found.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
          found.push(@lib.Instruction::i32_sub())
          found.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
              @lib.U32::new(1U),
            ),
          )
          found.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
        } else {
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          found.push(starshine_match_cast(entry_type))
          found.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(value_local.reinterpret_as_uint()),
            ),
          )
          found.push(
            starshine_map_entry_set(
              entry_type,
              starshine_map_entry_field(value_shape, true),
            ),
          )
        }
        found.push(@lib.Instruction::br(@lib.LabelIdx::new(3U)))
        on_hash.push(
          @lib.Instruction::if_(@lib.BlockType::void_(), found, None),
        )
        loop_body.push(
          @lib.Instruction::if_(@lib.BlockType::void_(), on_hash, None),
        )
        if operation == 9 {
          loop_body.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
            ),
          )
          loop_body.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(previous_local.reinterpret_as_uint()),
            ),
          )
        }
        loop_body.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
        )
        loop_body.push(starshine_match_cast(entry_type))
        loop_body.push(starshine_map_entry_get(entry_type, 0))
        loop_body.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
        )
        loop_body.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
        let actual_loop : Array[@lib.Instruction] = [
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(entry_local.reinterpret_as_uint()),
          ),
          @lib.Instruction::ref_is_null(),
          @lib.Instruction::if_(@lib.BlockType::void_(), on_null, None),
        ]
        append_starshine_instructions(actual_loop, loop_body)
        output.push(
          @lib.Instruction::block(
            result_type,
            @lib.Expr::new([
              @lib.Instruction::loop_(
                @lib.BlockType::void_(),
                @lib.Expr::new(actual_loop),
              ),
              @lib.Instruction::unreachable_(),
            ]),
          ),
        )
        results.push(output)
      }
      FinishStarshineProduct(count) => {
        let fragments = pop_starshine_fragments(results, count)
        let output : Array[@lib.Instruction] = []
        for fragment in fragments {
          append_starshine_instructions(output, fragment)
        }
        results.push(output)
      }
      FinishStarshineParameterSelect(arguments, selected) => {
        let fragments = pop_starshine_fragments(results, arguments.length)
        let output : Array[@lib.Instruction] = []
        for index, fragment in fragments {
          append_starshine_instructions(output, fragment)
          if index != selected {
            let expression = lowering.expression_children[arguments.start +
              index]
            let source = lowering.expressions[expression]
            starshine_append_shape_drops(
              output,
              starshine_specialized_shape(
                lowering,
                generic_specialization,
                source.type_,
                source.shape,
              ),
            )
          }
        }
        results.push(output)
      }
      FinishStarshineCall(declaration, expression, count, type_arguments) => {
        let fragments = pop_starshine_fragments(results, count)
        if starshine_diverging_call_evaluations(lowering, expression, fragments)
          is Some(output) {
          results.push(output)
          continue
        }
        let emitted = match program {
          Some(link) =>
            starshine_finish_program_call(
              Some(lowering),
              link,
              planned,
              body.body,
              expression,
              declaration,
              Some(type_arguments),
              generic_specialization,
              fragments,
              false,
            )
          None => starshine_finish_call(planned, declaration, fragments, false)
        }
        match emitted {
          Ok(output) => {
            if expression >= 0 &&
              lowering.expressions[expression].shape
              is @semantic.NeverPlannedValueShape &&
              (
                output.length() == 0 ||
                output[output.length() - 1] != @lib.Instruction::unreachable_()
              ) {
              output.push(@lib.Instruction::unreachable_())
            }
            results.push(output)
          }
          Err(error) => return Err(error)
        }
      }
      FinishStarshineTailCall(declaration, expression, count, type_arguments) => {
        let fragments = pop_starshine_fragments(results, count)
        if starshine_diverging_call_evaluations(lowering, expression, fragments)
          is Some(output) {
          results.push(output)
          continue
        }
        let emitted = match program {
          Some(link) =>
            starshine_finish_program_call(
              Some(lowering),
              link,
              planned,
              body.body,
              expression,
              declaration,
              Some(type_arguments),
              generic_specialization,
              fragments,
              true,
            )
          None => starshine_finish_call(planned, declaration, fragments, true)
        }
        match emitted {
          Ok(output) => results.push(output)
          Err(error) => return Err(error)
        }
      }
      FinishStarshineDirectLambdaCall(function_index, captures, argument_count) => {
        let arguments = pop_starshine_fragments(results, argument_count)
        let output : Array[@lib.Instruction] = []
        for capture in 0..<captures.length {
          let global_capture = captures.start + capture
          if planned.lambda_capture_parameter_indices[global_capture] < 0 {
            continue
          }
          match
            starshine_capture_source_instructions(
              lowering,
              planned,
              program,
              program_module_index,
              current_lambda,
              lowering.captures[global_capture].source,
              local_indices,
              generic_specialization,
              body,
            ) {
            Ok(instructions) =>
              append_starshine_instructions(output, instructions)
            Err(error) => return Err(error)
          }
        }
        for argument in arguments {
          append_starshine_instructions(output, argument)
        }
        output.push(
          @lib.Instruction::call(
            @lib.FuncIdx::new(function_index.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshineFunctionValueCall(type_index, count) => {
        let fragments = pop_starshine_fragments(results, count)
        let output : Array[@lib.Instruction] = []
        for fragment in fragments {
          append_starshine_instructions(output, fragment)
        }
        output.push(
          @lib.Instruction::call_ref(
            @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshineClosureCall(plan, count) => {
        let fragments = pop_starshine_fragments(results, count)
        match starshine_emit_closure_call(body.body, plan, fragments) {
          Ok(output) => results.push(output)
          Err(error) => return Err(error)
        }
      }
      FinishStarshineProductBox(shape, scratch) => {
        if scratch < 0 {
          return Err(UnsupportedExpression(body.body, -425))
        }
        let output = results.pop().unwrap()
        starshine_append_product_local_sets(output, scratch, shape)
        match
          starshine_product_box_from_locals(
            planned,
            program,
            body.body,
            scratch,
            shape,
          ) {
          Ok(instructions) =>
            append_starshine_instructions(output, instructions)
          Err(error) => return Err(error)
        }
        results.push(output)
      }
      FinishStarshineProductUnbox(shape, scratch) => {
        if scratch < 0 {
          return Err(UnsupportedExpression(body.body, -426))
        }
        let output = results.pop().unwrap()
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        match
          starshine_append_product_unbox(
            output,
            planned,
            program,
            body.body,
            scratch,
            shape,
          ) {
          Ok(_) => ()
          Err(error) => return Err(error)
        }
        results.push(output)
      }
      FinishStarshineConstructor(
        program,
        owner_module,
        physical_plan,
        physical,
        tag,
        evaluations,
        sources
      ) => {
        let fragments = pop_starshine_fragments(results, evaluations.length())
        let output : Array[@lib.Instruction] = []
        let mut diverges = false
        for index, value in evaluations {
          append_starshine_instructions(output, fragments[index])
          if !lowering.expressions[value].flow.may_fall_through() {
            diverges = true
            break
          }
          let source = lowering.expressions[value]
          let shape = starshine_specialized_shape(
            lowering,
            generic_specialization,
            source.type_,
            source.shape,
          )
          if shape is @semantic.UnitPlannedValueShape {
            continue
          }
          let slot = constructor_local_indices[value - body.expressions.start]
          if slot < 0 {
            return Err(UnsupportedExpression(body.body, value))
          }
          if shape is @semantic.ProductPlannedValueShape(_) {
            let scratch = match_result_local_indices[value -
              body.expressions.start]
            if scratch < 0 {
              return Err(UnsupportedExpression(body.body, value))
            }
            starshine_append_product_local_sets(output, scratch, shape)
            match
              starshine_product_box_from_locals(
                planned,
                program,
                body.body,
                scratch,
                shape,
              ) {
              Ok(instructions) =>
                append_starshine_instructions(output, instructions)
              Err(error) => return Err(error)
            }
          }
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(slot.reinterpret_as_uint()),
            ),
          )
        }
        if !diverges {
          let first_field = if tag < 0 { 0 } else { 1 }
          if tag >= 0 {
            output.push(@lib.Instruction::i32_const(@lib.I32::new(tag)))
          }
          if sources.length() + first_field != physical.fields.length {
            return Err(UnsupportedExpression(body.body, -427))
          }
          for index, source in sources {
            let storage = physical_plan.fields[physical.fields.start +
              first_field +
              index].storage
            if source < 0 {
              append_starshine_instructions(
                output,
                starshine_default_storage_instructions(storage),
              )
            } else {
              let value = evaluations[source]
              let slot = constructor_local_indices[value -
                body.expressions.start]
              if slot < 0 {
                return Err(UnsupportedExpression(body.body, value))
              }
              output.push(
                @lib.Instruction::local_get(
                  @lib.LocalIdx::new(slot.reinterpret_as_uint()),
                ),
              )
            }
            starshine_append_storage_cast(
              output, program, owner_module, physical_plan, physical, storage,
            )
          }
          let type_index = starshine_local_physical_type_index(
            program,
            owner_module,
            physical.type_index,
          )
          output.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
            ),
          )
        }
        results.push(output)
      }
      FinishStarshineEnumSubtype(
        program,
        owner_module,
        variant_plan,
        physical,
        tag,
        count
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        let output : Array[@lib.Instruction] = [
          @lib.Instruction::i32_const(@lib.I32::new(tag)),
        ]
        for index, fragment in fragments {
          append_starshine_instructions(output, fragment)
          starshine_append_storage_cast(
            output,
            program,
            owner_module,
            variant_plan,
            physical,
            variant_plan.fields[physical.fields.start + index + 1].storage,
          )
        }
        let type_index = starshine_local_physical_type_index(
          program,
          owner_module,
          physical.type_index,
        )
        output.push(
          @lib.Instruction::struct_new(
            @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshinePackedEnumPayload(tag) => {
        let output = results.pop().unwrap()
        output.push(@lib.Instruction::i64_extend_i32u())
        output.push(@lib.Instruction::i64_const(@lib.I64::new(32L)))
        output.push(@lib.Instruction::i64_shl())
        output.push(@lib.Instruction::i64_const(@lib.I64::new(tag.to_int64())))
        output.push(@lib.Instruction::i64_or())
        results.push(output)
      }
      FinishStarshineNominalResult(declaration) => {
        let output = results.pop().unwrap()
        match starshine_emitted_type_index(planned, program, declaration) {
          Some(type_index) => output.push(starshine_match_cast(type_index))
          None => ()
        }
        results.push(output)
      }
      FinishStarshineFieldGet(type_index, field_index, storage) => {
        let output = results.pop().unwrap()
        // Generic calls and stored fields may return an erased reference.
        // The selected field owner, not the source expression kind, determines
        // the exact heap type required by struct.get.
        output.push(starshine_match_cast(type_index))
        output.push(
          starshine_struct_get_instruction(type_index, field_index, storage),
        )
        results.push(output)
      }
      FinishStarshinePolymorphicFieldGet(locations, scratch, shape) => {
        let output = results.pop().unwrap()
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        let mut fallback : Array[@lib.Instruction] = [
          @lib.Instruction::unreachable_(),
        ]
        let mut index = locations.length()
        while index > 0 {
          index -= 1
          let location = locations[index]
          let present : Array[@lib.Instruction] = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
            ),
            starshine_match_cast(location.type_index),
            starshine_struct_get_instruction(
              location.type_index,
              location.field_index,
              location.storage,
            ),
          ]
          let next : Array[@lib.Instruction] = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
            ),
            @lib.Instruction::ref_test(
              false,
              @lib.HeapType::new(
                @lib.TypeIdx::new(location.type_index.reinterpret_as_uint()),
              ),
            ),
            @lib.Instruction::if_(
              starshine_block_type(shape),
              present,
              Some(fallback),
            ),
          ]
          fallback = next
        }
        append_starshine_instructions(output, fallback)
        results.push(output)
      }
      FinishStarshineFieldSet(type_index, field_index) => {
        let value = results.pop().unwrap()
        let output = results.pop().unwrap()
        output.push(starshine_match_cast(type_index))
        append_starshine_instructions(output, value)
        output.push(
          @lib.Instruction::struct_set(
            @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
            @lib.U32::new(field_index.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshineUnitFieldSet => {
        let value = results.pop().unwrap()
        let output = results.pop().unwrap()
        output.push(@lib.Instruction::drop())
        append_starshine_instructions(output, value)
        results.push(output)
      }
      FinishStarshineMatch(expression, arms, scratch_local) => {
        let mut guard_count = 0
        for arm_offset in 0..<arms.length {
          let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
            arm_offset]]
          if arm.guard_condition >= 0 {
            guard_count += 1
          }
        }
        let fragments = pop_starshine_fragments(
          results,
          arms.length + guard_count + 1,
        )
        let output = fragments[0]
        let arm_bodies : Array[Array[@lib.Instruction]] = []
        let arm_guards : Array[Array[@lib.Instruction]?] = []
        let mut fragment_index = 1
        for arm_offset in 0..<arms.length {
          let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
            arm_offset]]
          if arm.guard_condition >= 0 {
            arm_guards.push(Some(fragments[fragment_index]))
            fragment_index += 1
          } else {
            arm_guards.push(None)
          }
          arm_bodies.push(fragments[fragment_index])
          fragment_index += 1
        }
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(scratch_local.reinterpret_as_uint()),
          ),
        )
        let result_local = match_result_local_indices[expression -
          body.expressions.start]
        let result_source = lowering.expressions[expression]
        let result_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          result_source.type_,
          result_source.shape,
        )
        let dense_arm_by_tag = Array::make(arms.length, -1)
        let scalar_scrutinee = match lowering.expressions[expression].kind {
          @semantic.PlannedMatchExpression(scrutinee, _) =>
            lowering.expressions[scrutinee].shape
            is @semantic.I32PlannedValueShape ||
            lowering.expressions[scrutinee].shape
            is @semantic.I64PlannedValueShape
          _ => false
        }
        let mut dense_dispatch = planned.dense_enum_dispatch &&
          !scalar_scrutinee &&
          guard_count == 0 &&
          arms.length > 1
        if dense_dispatch {
          for arm_index in 0..<arms.length {
            let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
              arm_index]]
            if starshine_pattern_uses_general_emission(lowering, arm.pattern) {
              dense_dispatch = false
              break
            }
            let variant = match
              lowering.patterns[arm.pattern].selected_constructor {
              @semantic.VariantInferredPatternConstructor(variant, _) => variant
              _ => {
                dense_dispatch = false
                0UL
              }
            }
            if !dense_dispatch {
              break
            }
            let owner_module = match program {
              Some(link) =>
                link.module_lookup
                .get(@semantic.semantic_id_module(variant))
                .unwrap_or(program_module_index)
              None => program_module_index
            }
            let variant_plan = match program {
              Some(link) => link.modules[owner_module]
              None => planned
            }
            let tag = variant_plan.variant_tag_of(variant).unwrap_or(-1)
            if tag < 0 || tag >= arms.length || dense_arm_by_tag[tag] >= 0 {
              dense_dispatch = false
              break
            }
            dense_arm_by_tag[tag] = arm_index
          }
        }
        if dense_dispatch {
          let case_instructions : Array[Array[@lib.Instruction]] = []
          for _ in 0..<arms.length {
            case_instructions.push([])
          }
          let tag_dispatch : Array[@lib.Instruction] = []
          for tag in 0..<arms.length {
            let arm_index = dense_arm_by_tag[tag]
            if arm_index < 0 {
              dense_dispatch = false
              break
            }
            let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
              arm_index]]
            let (condition, bindings) = match
              starshine_match_pattern_instructions(
                lowering,
                planned,
                program,
                program_module_index,
                body,
                arm.pattern,
                scratch_local,
                fixed_array_ref_scratch_index,
                local_indices,
                generic_specialization,
              ) {
              Ok(value) => value
              Err(error) => return Err(error)
            }
            if tag_dispatch.length() == 0 {
              for index in 0..<3 {
                tag_dispatch.push(condition[index])
              }
            }
            append_starshine_instructions(bindings, arm_bodies[arm_index])
            if result_local >= 0 {
              if result_shape is @semantic.ProductPlannedValueShape(_) {
                starshine_append_product_local_sets(
                  bindings, result_local, result_shape,
                )
              } else {
                bindings.push(
                  @lib.Instruction::local_set(
                    @lib.LocalIdx::new(result_local.reinterpret_as_uint()),
                  ),
                )
              }
            }
            case_instructions[tag] = bindings
          }
          if dense_dispatch {
            let labels : Array[@lib.LabelIdx] = []
            for tag in 0..<arms.length {
              labels.push(@lib.LabelIdx::new(tag.reinterpret_as_uint()))
            }
            tag_dispatch.push(
              @lib.Instruction::br_table(
                labels,
                @lib.LabelIdx::new(arms.length.reinterpret_as_uint()),
              ),
            )
            let mut nested = tag_dispatch
            for tag in 0..<arms.length {
              let level : Array[@lib.Instruction] = [
                @lib.Instruction::block(
                  @lib.BlockType::void_(),
                  @lib.Expr::new(nested),
                ),
              ]
              append_starshine_instructions(level, case_instructions[tag])
              level.push(
                @lib.Instruction::br(
                  @lib.LabelIdx::new((arms.length - tag).reinterpret_as_uint()),
                ),
              )
              nested = level
            }
            let dispatch : Array[@lib.Instruction] = [
              @lib.Instruction::block(
                @lib.BlockType::void_(),
                @lib.Expr::new(nested),
              ),
              @lib.Instruction::unreachable_(),
            ]
            output.push(
              @lib.Instruction::block(
                @lib.BlockType::void_(),
                @lib.Expr::new(dispatch),
              ),
            )
          }
        }
        if !dense_dispatch {
          let dispatch : Array[@lib.Instruction] = []
          for arm_index in 0..<arms.length {
            let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
              arm_index]]
            let (condition, bindings) = match
              starshine_match_pattern_instructions(
                lowering,
                planned,
                program,
                program_module_index,
                body,
                arm.pattern,
                scratch_local,
                fixed_array_ref_scratch_index,
                local_indices,
                generic_specialization,
              ) {
              Ok(value) => value
              Err(error) => return Err(error)
            }
            let success = arm_bodies[arm_index]
            if result_local >= 0 {
              if result_shape is @semantic.ProductPlannedValueShape(_) {
                starshine_append_product_local_sets(
                  success, result_local, result_shape,
                )
              } else {
                success.push(
                  @lib.Instruction::local_set(
                    @lib.LocalIdx::new(result_local.reinterpret_as_uint()),
                  ),
                )
              }
            }
            match arm_guards[arm_index] {
              Some(guard_instructions) => {
                append_starshine_instructions(bindings, guard_instructions)
                success.push(@lib.Instruction::br(@lib.LabelIdx::new(2U)))
                bindings.push(
                  @lib.Instruction::if_(@lib.BlockType::void_(), success, None),
                )
              }
              None => {
                append_starshine_instructions(bindings, success)
                bindings.push(@lib.Instruction::br(@lib.LabelIdx::new(1U)))
              }
            }
            condition.push(
              @lib.Instruction::if_(@lib.BlockType::void_(), bindings, None),
            )
            append_starshine_instructions(dispatch, condition)
          }
          dispatch.push(@lib.Instruction::unreachable_())
          output.push(
            @lib.Instruction::block(
              @lib.BlockType::void_(),
              @lib.Expr::new(dispatch),
            ),
          )
        }
        if result_local >= 0 {
          if result_shape is @semantic.ProductPlannedValueShape(_) {
            starshine_append_product_local_gets(
              output, result_local, result_shape,
            )
          } else {
            output.push(starshine_match_local_get(result_local))
          }
        }
        // Wasm does not carry unreachable stack state out of a void block.
        // A Never match must remain unreachable at its enclosing value join.
        if result_shape is @semantic.NeverPlannedValueShape {
          output.push(@lib.Instruction::unreachable_())
        }
        results.push(output)
      }
      FinishStarshineWhile(expression, control, arms, state_local, result_local) => {
        let mut guard_count = 0
        for arm_offset in 0..<arms.length {
          let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
            arm_offset]]
          if arm.guard_condition >= 0 {
            guard_count += 1
          }
        }
        let fragments = pop_starshine_fragments(
          results,
          arms.length + guard_count + 1,
        )
        let output = fragments[0]
        let initial = match lowering.expressions[expression].kind {
          @semantic.PlannedWhileExpression(_, value, _) => value
          _ => return Err(UnsupportedExpression(body.body, expression))
        }
        let initial_source = lowering.expressions[initial]
        let state_shape = starshine_specialized_shape(
          lowering,
          generic_specialization,
          initial_source.type_,
          initial_source.shape,
        )
        if state_local >= 0 {
          if state_shape is @semantic.ProductPlannedValueShape(_) {
            starshine_append_product_local_sets(
              output, state_local, state_shape,
            )
          } else {
            output.push(
              @lib.Instruction::local_set(
                @lib.LocalIdx::new(state_local.reinterpret_as_uint()),
              ),
            )
          }
        }
        let arm_bodies : Array[Array[@lib.Instruction]] = []
        let arm_guards : Array[Array[@lib.Instruction]?] = []
        let mut fragment_index = 1
        for arm_offset in 0..<arms.length {
          let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
            arm_offset]]
          if arm.guard_condition >= 0 {
            arm_guards.push(Some(fragments[fragment_index]))
            fragment_index += 1
          } else {
            arm_guards.push(None)
          }
          arm_bodies.push(fragments[fragment_index])
          fragment_index += 1
        }
        let dispatch : Array[@lib.Instruction] = []
        for arm_index in 0..<arms.length {
          let arm = lowering.pattern_arms[lowering.arm_children[arms.start +
            arm_index]]
          let pattern_state_local = if state_shape
            is @semantic.ProductPlannedValueShape(_) {
            fixed_array_ref_scratch_index
          } else {
            state_local
          }
          let (condition, bindings) = match
            starshine_match_pattern_instructions(
              lowering,
              planned,
              program,
              program_module_index,
              body,
              arm.pattern,
              pattern_state_local,
              fixed_array_ref_scratch_index,
              local_indices,
              generic_specialization,
            ) {
            Ok(value) => value
            Err(error) => return Err(error)
          }
          let success = arm_bodies[arm_index]
          match arm_guards[arm_index] {
            Some(guard_instructions) => {
              append_starshine_instructions(bindings, guard_instructions)
              success.push(@lib.Instruction::br(@lib.LabelIdx::new(2U)))
              bindings.push(
                @lib.Instruction::if_(@lib.BlockType::void_(), success, None),
              )
            }
            None => {
              append_starshine_instructions(bindings, success)
              bindings.push(@lib.Instruction::br(@lib.LabelIdx::new(1U)))
            }
          }
          condition.push(
            @lib.Instruction::if_(@lib.BlockType::void_(), bindings, None),
          )
          append_starshine_instructions(dispatch, condition)
        }
        dispatch.push(@lib.Instruction::unreachable_())
        let loop_body : Array[@lib.Instruction] = []
        if state_shape is @semantic.ProductPlannedValueShape(_) {
          if fixed_array_ref_scratch_index < 0 {
            return Err(UnsupportedExpression(body.body, -429))
          }
          match
            starshine_product_box_from_locals(
              planned,
              program,
              body.body,
              state_local,
              state_shape,
            ) {
            Ok(instructions) =>
              append_starshine_instructions(loop_body, instructions)
            Err(error) => return Err(error)
          }
          loop_body.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(
                fixed_array_ref_scratch_index.reinterpret_as_uint(),
              ),
            ),
          )
        }
        loop_body.push(
          @lib.Instruction::block(
            @lib.BlockType::void_(),
            @lib.Expr::new(dispatch),
          ),
        )
        loop_body.push(@lib.Instruction::unreachable_())
        starshine_resolve_control_transfers(loop_body, control)
        output.push(
          @lib.Instruction::block(
            @lib.BlockType::void_(),
            @lib.Expr::new([
              @lib.Instruction::loop_(
                @lib.BlockType::void_(),
                @lib.Expr::new(loop_body),
              ),
              @lib.Instruction::unreachable_(),
            ]),
          ),
        )
        if result_local >= 0 {
          let result_source = lowering.expressions[expression]
          let result_shape = starshine_specialized_shape(
            lowering,
            generic_specialization,
            result_source.type_,
            result_source.shape,
          )
          if result_shape is @semantic.ProductPlannedValueShape(_) {
            starshine_append_product_local_gets(
              output, result_local, result_shape,
            )
          } else {
            output.push(
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(result_local.reinterpret_as_uint()),
              ),
            )
          }
        } else {
          match lowering.expressions[expression].shape {
            @semantic.NeverPlannedValueShape =>
              output.push(@lib.Instruction::unreachable_())
            _ => ()
          }
        }
        results.push(output)
      }
      FinishStarshineControlTransfer(control, break_, shape) => {
        if control < 0 || control >= control_state_local_indices.length() {
          return Err(UnsupportedExpression(body.body, body.expressions.start))
        }
        let output = results.pop().unwrap()
        let target_local = if break_ {
          control_result_local_indices[control]
        } else {
          control_state_local_indices[control]
        }
        if target_local >= 0 {
          if shape is @semantic.ProductPlannedValueShape(_) {
            starshine_append_product_local_sets(output, target_local, shape)
          } else {
            output.push(
              @lib.Instruction::local_set(
                @lib.LocalIdx::new(target_local.reinterpret_as_uint()),
              ),
            )
          }
        }
        output.push(
          @lib.Instruction::br(
            starshine_control_transfer_label(control, break_),
          ),
        )
        results.push(output)
      }
      FinishStarshineReturn => {
        let output = results.pop().unwrap()
        // A local can use broad, nullable reference storage while its function
        // returns a precise reference. Early returns need the same checked
        // narrowing as the normal body tail, using this exact specialization.
        match (program, context.result_function) {
          (Some(link), Some(function_)) =>
            starshine_append_program_result_cast(link, function_, output)
          (None, _) if current_lambda < 0 =>
            starshine_append_module_result_cast(
              planned,
              body.declaration,
              output,
            )
          _ => ()
        }
        output.push(@lib.Instruction::return_())
        results.push(output)
      }
      FinishStarshineIf(shape, result_local) => {
        let alternative = results.pop().unwrap()
        let consequent = results.pop().unwrap()
        let condition = results.pop().unwrap()
        let output : Array[@lib.Instruction] = []
        append_starshine_instructions(output, condition)
        if shape is @semantic.ProductPlannedValueShape(_) {
          if result_local < 0 {
            return Err(UnsupportedExpression(body.body, -501))
          }
          starshine_append_product_local_sets(consequent, result_local, shape)
          starshine_append_product_local_sets(alternative, result_local, shape)
          output.push(
            @lib.Instruction::if_(
              @lib.BlockType::void_(),
              consequent,
              Some(alternative),
            ),
          )
          starshine_append_product_local_gets(output, result_local, shape)
        } else {
          output.push(
            @lib.Instruction::if_(
              starshine_block_type(shape),
              consequent,
              Some(alternative),
            ),
          )
        }
        if shape is @semantic.NeverPlannedValueShape {
          output.push(@lib.Instruction::unreachable_())
        }
        results.push(output)
      }
      FinishStarshinePrefix(operator, shape) => {
        let operand = results.pop().unwrap()
        match starshine_prefix_value_instructions(operator, shape, operand) {
          Some(output) => results.push(output)
          None =>
            return Err(UnsupportedExpression(body.body, body.expressions.start))
        }
      }
      FinishStarshineTraitObjectCoercion(trait_, evidence) => {
        let output = results.pop().unwrap()
        match
          starshine_finish_trait_object_coercion(
            lowering,
            planned,
            program,
            program_module_index,
            generic_specialization,
            body.body,
            trait_,
            evidence,
            output,
            helper_plan,
          ) {
          Ok(value) => results.push(value)
          Err(error) => return Err(error)
        }
      }
      FinishStarshineRuntimeBoundCall(
        trait_,
        slot,
        parameter,
        signature_type,
        argument_count
      ) => {
        if argument_count <= 0 || parameter < 0 {
          return Err(UnsupportedExpression(body.body, -308))
        }
        let mut layout = None
        for candidate in planned.trait_layouts {
          if candidate.trait_declaration == trait_ {
            layout = Some(candidate)
            break
          }
        }
        let layout = match layout {
          Some(value) => value
          None => return Err(UnsupportedExpression(body.body, -309))
        }
        if slot < 0 || slot >= layout.methods.length {
          return Err(UnsupportedExpression(body.body, -310))
        }
        let fragments = pop_starshine_fragments(results, argument_count)
        let output = fragments[0]
        for index in 1..<fragments.length() {
          append_starshine_instructions(output, fragments[index])
        }
        let vtable_type = starshine_local_physical_type_index(
          program,
          program_module_index,
          layout.vtable_type_index,
        )
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(parameter.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(vtable_type))
        output.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(vtable_type.reinterpret_as_uint()),
            @lib.U32::new(slot.reinterpret_as_uint()),
          ),
        )
        let emitted_signature = match program {
          Some(link) =>
            link.signature_type_index(program_module_index, signature_type)
          None => signature_type
        }
        output.push(
          @lib.Instruction::call_ref(
            @lib.TypeIdx::new(emitted_signature.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshineDynamicTraitCall(
        trait_,
        slot,
        scratch,
        signature_type,
        argument_count
      ) => {
        let mut layout = None
        for candidate in planned.trait_layouts {
          if candidate.trait_declaration == trait_ {
            layout = Some(candidate)
            break
          }
        }
        let layout = match layout {
          Some(value) => value
          None => return Err(UnsupportedExpression(body.body, -303))
        }
        let fragments = pop_starshine_fragments(results, argument_count + 1)
        let output = fragments[0]
        let object_type = starshine_local_physical_type_index(
          program,
          program_module_index,
          layout.object_type_index,
        )
        let vtable_type = starshine_local_physical_type_index(
          program,
          program_module_index,
          layout.vtable_type_index,
        )
        output.push(
          @lib.Instruction::local_tee(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(object_type))
        output.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(object_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
        )
        for index in 0..<argument_count {
          append_starshine_instructions(output, fragments[index + 1])
        }
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(object_type))
        output.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(object_type.reinterpret_as_uint()),
            @lib.U32::new(1U),
          ),
        )
        output.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(vtable_type.reinterpret_as_uint()),
            @lib.U32::new(slot.reinterpret_as_uint()),
          ),
        )
        let emitted_signature = match program {
          Some(link) =>
            link.signature_type_index(program_module_index, signature_type)
          None => signature_type
        }
        output.push(
          @lib.Instruction::call_ref(
            @lib.TypeIdx::new(emitted_signature.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshineLogical(operator) => {
        let fragments = pop_starshine_fragments(results, 2)
        let output = fragments[0]
        let right = fragments[1]
        match operator {
          @semantic.HirLogicalAnd =>
            output.push(
              @lib.Instruction::if_(
                @lib.BlockType::val_type(@lib.ValType::i32()),
                right,
                Some([@lib.Instruction::i32_const(@lib.I32::new(0))]),
              ),
            )
          @semantic.HirLogicalOr =>
            output.push(
              @lib.Instruction::if_(
                @lib.BlockType::val_type(@lib.ValType::i32()),
                [@lib.Instruction::i32_const(@lib.I32::new(1))],
                Some(right),
              ),
            )
          _ => return Err(UnsupportedExpression(body.body, -301))
        }
        results.push(output)
      }
    }
  }
  if results.length() != 1 {
    Err(InvalidFunctionBody(body.body))
  } else {
    let output = results[0]
    if body.result_shape is @semantic.UnitPlannedValueShape {
      match
        starshine_body_emitted_root_shape(
          lowering, generic_specialization, body,
        ) {
        Some(shape) => starshine_append_shape_drops(output, shape)
        None => ()
      }
    }
    Ok(output)
  }
}

///| Narrow a body-level eqref result back to its frozen nominal function ABI.

///| Control-flow joins intentionally use the common eqref carrier, while

///|
/// exported and directly called aggregate functions retain exact typed refs.
fn starshine_append_module_result_cast(
  planned : @semantic.PlannedModuleWasmGCFragments,
  declaration : @semantic.DeclId,
  instructions : Array[@lib.Instruction],
) -> Unit {
  match planned.function_of(declaration) {
    Some(function_) =>
      if function_.results.length == 1 {
        match planned.function_value_types[function_.results.start] {
          @semantic.WasmNominalRefValue(index) =>
            instructions.push(
              @lib.Instruction::ref_cast(
                false,
                @lib.HeapType::new(
                  @lib.TypeIdx::new(index.reinterpret_as_uint()),
                ),
              ),
            )
          @semantic.WasmNullableNominalRefValue(index) =>
            instructions.push(
              @lib.Instruction::ref_cast(
                true,
                @lib.HeapType::new(
                  @lib.TypeIdx::new(index.reinterpret_as_uint()),
                ),
              ),
            )
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn starshine_append_program_argument_cast(
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  parameter_index : Int,
  instructions : Array[@lib.Instruction],
) -> Unit {
  if parameter_index < 0 || parameter_index >= function_.parameters.length {
    return
  }
  let fragments = planned.modules[function_.module_index]
  let mut nullable = false
  let final_index = match
    fragments.function_value_types[function_.parameters.start + parameter_index] {
    @semantic.WasmNominalRefValue(index) =>
      planned.physical_type_index(function_.module_index, index)
    @semantic.WasmExternalNominalRefValue(declaration) =>
      planned.type_lookup.get(declaration).unwrap()
    @semantic.WasmFixedArrayRefValue(carrier) =>
      planned.fixed_array_type_base + carrier
    @semantic.WasmNullableNominalRefValue(index) => {
      nullable = true
      planned.physical_type_index(function_.module_index, index)
    }
    @semantic.WasmNullableExternalNominalRefValue(declaration) => {
      nullable = true
      planned.type_lookup.get(declaration).unwrap()
    }
    _ => -1
  }
  if final_index >= 0 {
    instructions.push(
      @lib.Instruction::ref_cast(
        nullable,
        @lib.HeapType::new(@lib.TypeIdx::new(final_index.reinterpret_as_uint())),
      ),
    )
  }
}

///|
fn starshine_append_program_result_cast(
  planned : @semantic.PlannedProgramWasmGCLink,
  function_ : @semantic.PlannedProgramWasmFunction,
  instructions : Array[@lib.Instruction],
) -> Unit {
  if function_.results.length != 1 {
    return
  }
  let fragments = planned.modules[function_.module_index]
  let mut nullable = false
  let final_index = match
    fragments.function_value_types[function_.results.start] {
    @semantic.WasmNominalRefValue(index) =>
      planned.physical_type_index(function_.module_index, index)
    @semantic.WasmExternalNominalRefValue(declaration) =>
      planned.type_lookup.get(declaration).unwrap()
    @semantic.WasmFixedArrayRefValue(carrier) =>
      planned.fixed_array_type_base + carrier
    @semantic.WasmNullableNominalRefValue(index) => {
      nullable = true
      planned.physical_type_index(function_.module_index, index)
    }
    @semantic.WasmNullableExternalNominalRefValue(declaration) => {
      nullable = true
      planned.type_lookup.get(declaration).unwrap()
    }
    _ => -1
  }
  if final_index >= 0 {
    instructions.push(
      @lib.Instruction::ref_cast(
        nullable,
        @lib.HeapType::new(@lib.TypeIdx::new(final_index.reinterpret_as_uint())),
      ),
    )
  }
}

///|
fn starshine_lambda_body(
  lowering : @semantic.PlannedModuleLowering,
  lambda : @semantic.LambdaId,
) -> @semantic.PlannedBodyLowering {
  lowering.lambda_body(lambda).unwrap()
}

///|
fn starshine_lambda_leading_parameter_count(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  lambda : @semantic.LambdaId,
) -> Int {
  if !lowering.lambdas[lambda].directized {
    return 1
  }
  let mut count = 0
  let captures = lowering.lambdas[lambda].captures
  for capture in 0..<captures.length {
    if planned.lambda_capture_parameter_indices[captures.start + capture] >= 0 {
      count += 1
    }
  }
  count
}

///|
fn emit_starshine_lambda_body(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  program_module_index : Int,
  lambda : @semantic.LambdaId,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let body = starshine_lambda_body(lowering, lambda)
  let fragment = planned.functions[planned.lambda_function_indices[lambda]]
  let generic_specialization = if fragment.specialization_shapes.length > 0 {
    let owner = lowering.bodies[@semantic.semantic_id_local(
        lowering.lambdas[lambda].root_body,
      )]
    let callable = lowering.functions.callable_of(owner.declaration).unwrap()
    Some({
      generic_parameters: starshine_callable_generic_parameters(callable),
      shapes: planned.specialization_shapes,
      specialization_shapes: fragment.specialization_shapes,
      specialization_evidence: fragment.specialization_evidence,
      specialization_abi_key: fragment.specialization_abi_key,
    })
  } else {
    None
  }
  let (
    local_indices,
    body_local_types,
    match_local_indices,
    match_result_local_indices,
    fixed_array_ref_scratch_index,
    fixed_array_i32_scratch_index,
    map_key_local_indices,
    map_value_local_indices,
    map_ref_scratch_index,
    map_bucket_scratch_index,
    map_hash_scratch_index,
    map_entry_scratch_index,
    map_previous_scratch_index,
    map_growth_index_scratch_index,
    control_state_local_indices,
    control_result_local_indices,
    constructor_local_indices,
  ) = starshine_body_locals(
    lowering,
    planned,
    program,
    generic_specialization,
    body,
    starshine_lambda_leading_parameter_count(lowering, planned, lambda),
  )
  let parameter_count = planned.functions[planned.lambda_function_indices[lambda]].parameters.length
  let (function_reference_cache_indices, cache_count) = starshine_function_reference_cache_indices(
    lowering,
    program,
    program_module_index,
    body,
    parameter_count + body_local_types.length(),
  )
  for _ in 0..<cache_count {
    body_local_types.push(@lib.ValType::eqref_null())
  }
  match
    starshine_emit_body_instructions(
      lowering,
      planned,
      {
        program,
        module_index: program_module_index,
        helper_plan: None,
        result_function: None,
      },
      body,
      lambda,
      local_indices,
      match_local_indices,
      match_result_local_indices,
      function_reference_cache_indices,
      fixed_array_ref_scratch_index,
      fixed_array_i32_scratch_index,
      map_key_local_indices,
      map_value_local_indices,
      map_ref_scratch_index,
      map_bucket_scratch_index,
      map_hash_scratch_index,
      map_entry_scratch_index,
      map_previous_scratch_index,
      map_growth_index_scratch_index,
      control_state_local_indices,
      control_result_local_indices,
      constructor_local_indices,
      generic_specialization,
    ) {
    Ok(instructions) => {
      let prefixed = match
        starshine_function_reference_cache_prefix(
          lowering, planned, program, program_module_index, body, function_reference_cache_indices,
        ) {
        Ok(prefix) => prefix
        Err(error) => return Err(error)
      }
      append_starshine_instructions(prefixed, instructions)
      Ok(
        @lib.Func::new(
          @lib.Locals::from_types(body_local_types),
          @lib.Expr::new(prefixed),
        ),
      )
    }
    Err(error) => Err(error)
  }
}

///|
fn emit_starshine_function_body(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  body_id : @semantic.BodyId,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let body_index = @semantic.semantic_id_local(body_id)
  if body_index < 0 || body_index >= lowering.bodies.length() {
    return Err(MissingBody(body_id))
  }
  let body = lowering.bodies[body_index]
  let (
    local_indices,
    body_local_types,
    match_local_indices,
    match_result_local_indices,
    fixed_array_ref_scratch_index,
    fixed_array_i32_scratch_index,
    map_key_local_indices,
    map_value_local_indices,
    map_ref_scratch_index,
    map_bucket_scratch_index,
    map_hash_scratch_index,
    map_entry_scratch_index,
    map_previous_scratch_index,
    map_growth_index_scratch_index,
    control_state_local_indices,
    control_result_local_indices,
    constructor_local_indices,
  ) = starshine_body_locals(lowering, planned, None, None, body, 0)
  let parameter_count = match planned.function_of(body.declaration) {
    Some(function_) => function_.parameters.length
    None => 0
  }
  let (function_reference_cache_indices, cache_count) = starshine_function_reference_cache_indices(
    lowering,
    None,
    -1,
    body,
    parameter_count + body_local_types.length(),
  )
  for _ in 0..<cache_count {
    body_local_types.push(@lib.ValType::eqref_null())
  }
  match
    starshine_emit_body_instructions(
      lowering,
      planned,
      {
        program: None,
        module_index: -1,
        helper_plan: None,
        result_function: None,
      },
      body,
      -1,
      local_indices,
      match_local_indices,
      match_result_local_indices,
      function_reference_cache_indices,
      fixed_array_ref_scratch_index,
      fixed_array_i32_scratch_index,
      map_key_local_indices,
      map_value_local_indices,
      map_ref_scratch_index,
      map_bucket_scratch_index,
      map_hash_scratch_index,
      map_entry_scratch_index,
      map_previous_scratch_index,
      map_growth_index_scratch_index,
      control_state_local_indices,
      control_result_local_indices,
      constructor_local_indices,
      None,
    ) {
    Ok(instructions) => {
      starshine_append_module_result_cast(
        planned,
        body.declaration,
        instructions,
      )
      let prefixed = match
        starshine_function_reference_cache_prefix(
          lowering,
          planned,
          None,
          -1,
          body,
          function_reference_cache_indices,
        ) {
        Ok(prefix) => prefix
        Err(error) => return Err(error)
      }
      append_starshine_instructions(prefixed, instructions)
      Ok(
        @lib.Func::new(
          @lib.Locals::from_types(body_local_types),
          @lib.Expr::new(prefixed),
        ),
      )
    }
    Err(error) => Err(error)
  }
}

///|
fn starshine_trait_adapter_method(
  planned : @semantic.PlannedModuleWasmGCFragments,
  adapter : @semantic.DeclId,
) -> @semantic.PlannedWasmTraitMethod? {
  for method_info in planned.trait_methods {
    if method_info.adapter_function >= 0 &&
      method_info.adapter_function < planned.functions.length() &&
      planned.functions[method_info.adapter_function].declaration == adapter {
      return Some(method_info)
    }
  }
  None
}

///|
fn emit_starshine_trait_adapter_body(
  planned : @semantic.PlannedModuleWasmGCFragments,
  adapter : @semantic.PlannedWasmFunctionFragment,
  implementation_method : @semantic.DeclId,
) -> Result[@lib.Func, StarshineCodeEmissionError] {
  let implementation = match planned.function_of(implementation_method) {
    Some(value) if value.function_index >= 0 => value
    _ => return Err(MissingFunction(implementation_method))
  }
  let method_info = match
    starshine_trait_adapter_method(planned, adapter.declaration) {
    Some(value) => value
    None => return Err(UnsupportedExpression(0UL, 0))
  }
  match method_info.receiver_shape {
    @semantic.RefPlannedValueShape =>
      if method_info.receiver_nominal == 0UL {
        return Err(UnsupportedExpression(0UL, 0))
      }
    _ => return Err(UnsupportedExpression(0UL, 0))
  }
  let type_index = match planned.type_index_of(method_info.receiver_nominal) {
    Some(value) => value
    None => return Err(UnsupportedExpression(0UL, 0))
  }
  let instructions : Array[@lib.Instruction] = [
    @lib.Instruction::local_get(@lib.LocalIdx::new(0U)),
    starshine_match_cast(type_index),
  ]
  for index in 1..<adapter.parameters.length {
    instructions.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(index.reinterpret_as_uint()),
      ),
    )
  }
  instructions.push(
    @lib.Instruction::call(
      @lib.FuncIdx::new(implementation.function_index.reinterpret_as_uint()),
    ),
  )
  Ok(@lib.Func::new(@lib.Locals::from_types([]), @lib.Expr::new(instructions)))
}

///|
fn starshine_program_storage_type(
  planned : @semantic.PlannedProgramWasmGCLink,
  module_index : Int,
  storage : @semantic.PlannedWasmStorageType,
) -> @lib.StorageType {
  match storage {
    @semantic.WasmI8SignedStorage | @semantic.WasmI8UnsignedStorage =>
      @lib.StorageType::pack_type(@lib.PackType::i8())
    @semantic.WasmI16SignedStorage | @semantic.WasmI16UnsignedStorage =>
      @lib.StorageType::pack_type(@lib.PackType::i16())
    @semantic.WasmI32Storage => @lib.StorageType::val_type(@lib.ValType::i32())
    @semantic.WasmI64Storage => @lib.StorageType::val_type(@lib.ValType::i64())
    @semantic.WasmF32Storage => @lib.StorageType::val_type(@lib.ValType::f32())
    @semantic.WasmF64Storage => @lib.StorageType::val_type(@lib.ValType::f64())
    @semantic.WasmV128Storage =>
      @lib.StorageType::val_type(@lib.ValType::v128())
    @semantic.WasmStringRefStorage =>
      @lib.StorageType::val_type(@lib.ValType::eqref_null())
    @semantic.WasmNullableEqRefStorage =>
      @lib.StorageType::val_type(@lib.ValType::eqref_null())
    @semantic.WasmNullableFunctionRefStorage =>
      @lib.StorageType::val_type(@lib.ValType::funcref())
    @semantic.WasmFunctionRefStorage(index) =>
      @lib.StorageType::val_type(
        starshine_function_ref(
          @lib.TypeIdx::new(
            planned
            .signature_type_index(module_index, index)
            .reinterpret_as_uint(),
          ),
        ),
      )
    @semantic.WasmNominalRefStorage(reference) =>
      @lib.StorageType::val_type(
        match reference {
          @semantic.WasmModuleTypeReference(index) =>
            starshine_nominal_ref(
              @lib.TypeIdx::new(
                planned
                .physical_type_index(module_index, index)
                .reinterpret_as_uint(),
              ),
            )
          @semantic.WasmRecursiveTypeReference(index) =>
            starshine_nominal_ref(
              @lib.TypeIdx::rec(index.reinterpret_as_uint()),
            )
        },
      )
    @semantic.WasmExternalNominalRefStorage(declaration) =>
      @lib.StorageType::val_type(
        starshine_nominal_ref(
          @lib.TypeIdx::new(
            planned.type_lookup.get(declaration).unwrap().reinterpret_as_uint(),
          ),
        ),
      )
    @semantic.WasmFixedArrayRefStorage(carrier) =>
      @lib.StorageType::val_type(
        starshine_nominal_ref(
          @lib.TypeIdx::new(
            (planned.fixed_array_type_base + carrier).reinterpret_as_uint(),
          ),
        ),
      )
    @semantic.WasmNullableNominalRefStorage(reference) =>
      @lib.StorageType::val_type(
        match reference {
          @semantic.WasmModuleTypeReference(index) =>
            starshine_nullable_nominal_ref(
              @lib.TypeIdx::new(
                planned
                .physical_type_index(module_index, index)
                .reinterpret_as_uint(),
              ),
            )
          @semantic.WasmRecursiveTypeReference(index) =>
            starshine_nullable_nominal_ref(
              @lib.TypeIdx::rec(index.reinterpret_as_uint()),
            )
        },
      )
    @semantic.WasmNullableExternalNominalRefStorage(declaration) =>
      @lib.StorageType::val_type(
        starshine_nullable_nominal_ref(
          @lib.TypeIdx::new(
            planned.type_lookup.get(declaration).unwrap().reinterpret_as_uint(),
          ),
        ),
      )
  }
}

///|
fn starshine_program_value_type(
  planned : @semantic.PlannedProgramWasmGCLink,
  module_index : Int,
  value : @semantic.PlannedWasmValueType,
) -> @lib.ValType {
  match value {
    @semantic.WasmI32Value => @lib.ValType::i32()
    @semantic.WasmI64Value => @lib.ValType::i64()
    @semantic.WasmF32Value => @lib.ValType::f32()
    @semantic.WasmF64Value => @lib.ValType::f64()
    @semantic.WasmV128Value => @lib.ValType::v128()
    @semantic.WasmStringRefValue => @lib.ValType::eqref_null()
    @semantic.WasmNullableEqRefValue => @lib.ValType::eqref_null()
    @semantic.WasmFunctionRefValue(index) =>
      starshine_function_ref(
        @lib.TypeIdx::new(
          planned
          .signature_type_index(module_index, index)
          .reinterpret_as_uint(),
        ),
      )
    @semantic.WasmNominalRefValue(index) =>
      starshine_nominal_ref(
        @lib.TypeIdx::new(
          planned.physical_type_index(module_index, index).reinterpret_as_uint(),
        ),
      )
    @semantic.WasmExternalNominalRefValue(declaration) =>
      starshine_nominal_ref(
        @lib.TypeIdx::new(
          planned.type_lookup.get(declaration).unwrap().reinterpret_as_uint(),
        ),
      )
    @semantic.WasmFixedArrayRefValue(carrier) =>
      starshine_nominal_ref(
        @lib.TypeIdx::new(
          (planned.fixed_array_type_base + carrier).reinterpret_as_uint(),
        ),
      )
    @semantic.WasmNullableNominalRefValue(index) =>
      starshine_nullable_nominal_ref(
        @lib.TypeIdx::new(
          planned.physical_type_index(module_index, index).reinterpret_as_uint(),
        ),
      )
    @semantic.WasmNullableExternalNominalRefValue(declaration) =>
      starshine_nullable_nominal_ref(
        @lib.TypeIdx::new(
          planned.type_lookup.get(declaration).unwrap().reinterpret_as_uint(),
        ),
      )
  }
}

///|
fn starshine_program_group_type_index(
  final_type_index : Int,
  _group_first_type_index : Int,
  _group_length : Int,
) -> @lib.TypeIdx {
  // The binary format encodes recursive-group references through their final
  // type-section indices. Starshine's relative recursive index is useful to
  // its validator and WAT model but is intentionally not binary-encodable.
  @lib.TypeIdx::new(final_type_index.reinterpret_as_uint())
}

///|
fn starshine_program_group_storage_type(
  planned : @semantic.PlannedProgramWasmGCLink,
  node : @semantic.PlannedProgramWasmPhysicalType,
  group : @semantic.PlannedProgramWasmRecursiveGroup,
  storage : @semantic.PlannedWasmStorageType,
) -> @lib.StorageType {
  let nominal = fn(final_type_index : Int) {
    @lib.StorageType::val_type(
      starshine_nominal_ref(
        starshine_program_group_type_index(
          final_type_index,
          group.first_type_index,
          group.types.length,
        ),
      ),
    )
  }
  match storage {
    @semantic.WasmI8SignedStorage | @semantic.WasmI8UnsignedStorage =>
      @lib.StorageType::pack_type(@lib.PackType::i8())
    @semantic.WasmI16SignedStorage | @semantic.WasmI16UnsignedStorage =>
      @lib.StorageType::pack_type(@lib.PackType::i16())
    @semantic.WasmI32Storage => @lib.StorageType::val_type(@lib.ValType::i32())
    @semantic.WasmI64Storage => @lib.StorageType::val_type(@lib.ValType::i64())
    @semantic.WasmF32Storage => @lib.StorageType::val_type(@lib.ValType::f32())
    @semantic.WasmF64Storage => @lib.StorageType::val_type(@lib.ValType::f64())
    @semantic.WasmV128Storage =>
      @lib.StorageType::val_type(@lib.ValType::v128())
    @semantic.WasmStringRefStorage | @semantic.WasmNullableEqRefStorage =>
      @lib.StorageType::val_type(@lib.ValType::eqref_null())
    @semantic.WasmNullableFunctionRefStorage =>
      @lib.StorageType::val_type(@lib.ValType::funcref())
    @semantic.WasmFunctionRefStorage(index) =>
      @lib.StorageType::val_type(
        starshine_function_ref(
          @lib.TypeIdx::new(
            planned
            .signature_type_index(node.module_index, index)
            .reinterpret_as_uint(),
          ),
        ),
      )
    @semantic.WasmNominalRefStorage(reference) => {
      let module_ = planned.modules[node.module_index]
      let physical = module_.physical_types[node.fragment_index]
      let local_type_index = match reference {
        @semantic.WasmModuleTypeReference(index) => index
        @semantic.WasmRecursiveTypeReference(index) =>
          module_.type_groups[physical.group_index].first_type_index + index
      }
      nominal(planned.physical_type_index(node.module_index, local_type_index))
    }
    @semantic.WasmExternalNominalRefStorage(declaration) =>
      nominal(planned.type_lookup.get(declaration).unwrap())
    @semantic.WasmFixedArrayRefStorage(carrier) =>
      nominal(planned.fixed_array_type_base + carrier)
    @semantic.WasmNullableNominalRefStorage(reference) => {
      let module_ = planned.modules[node.module_index]
      let physical = module_.physical_types[node.fragment_index]
      let local_type_index = match reference {
        @semantic.WasmModuleTypeReference(index) => index
        @semantic.WasmRecursiveTypeReference(index) =>
          module_.type_groups[physical.group_index].first_type_index + index
      }
      @lib.StorageType::val_type(
        starshine_nullable_nominal_ref(
          starshine_program_group_type_index(
            planned.physical_type_index(node.module_index, local_type_index),
            group.first_type_index,
            group.types.length,
          ),
        ),
      )
    }
    @semantic.WasmNullableExternalNominalRefStorage(declaration) =>
      @lib.StorageType::val_type(
        starshine_nullable_nominal_ref(
          starshine_program_group_type_index(
            planned.type_lookup.get(declaration).unwrap(),
            group.first_type_index,
            group.types.length,
          ),
        ),
      )
  }
}

///|
fn starshine_program_group_physical_subtype(
  planned : @semantic.PlannedProgramWasmGCLink,
  node : @semantic.PlannedProgramWasmPhysicalType,
  group : @semantic.PlannedProgramWasmRecursiveGroup,
) -> @lib.SubType {
  let module_ = planned.modules[node.module_index]
  let type_ = module_.physical_types[node.fragment_index]
  let fields : Array[@lib.FieldType] = []
  for index in 0..<type_.fields.length {
    let field = module_.fields[type_.fields.start + index]
    fields.push(
      @lib.FieldType::new(
        starshine_program_group_storage_type(
          planned,
          node,
          group,
          field.storage,
        ),
        if field.mutable_ {
          @lib.Mut::var_()
        } else {
          @lib.Mut::const_()
        },
      ),
    )
  }
  let composite = @lib.CompType::struct_(fields)
  match type_.kind {
    @semantic.PlannedWasmEnumBaseType(_) | @semantic.PlannedWasmClosureType =>
      @lib.SubType::new(false, [], composite)
    @semantic.PlannedWasmEnumSubtypeType(declaration, _, _) =>
      @lib.SubType::new(
        true,
        [
          starshine_program_group_type_index(
            planned.type_lookup.get(declaration).unwrap(),
            group.first_type_index,
            group.types.length,
          ),
        ],
        composite,
      )
    @semantic.PlannedWasmCaptureCellType(_) =>
      @lib.SubType::new(true, [], composite)
    @semantic.PlannedWasmLambdaClosureType(_) =>
      @lib.SubType::new(
        true,
        [
          starshine_program_group_type_index(
            planned.physical_type_index(
              node.module_index,
              module_.closure_type_index,
            ),
            group.first_type_index,
            group.types.length,
          ),
        ],
        composite,
      )
    @semantic.PlannedWasmTraitMethodSignatureType(requirement) =>
      starshine_program_function_subtype(
        planned,
        node.module_index,
        module_.function_of(requirement).unwrap(),
      )
    @semantic.PlannedWasmStructType(_)
    | @semantic.PlannedWasmForeignMarkerType(_)
    | @semantic.PlannedWasmTraitVTableType(_)
    | @semantic.PlannedWasmTraitObjectType(_) =>
      @lib.SubType::comp_type(composite)
  }
}

///|
fn starshine_program_physical_subtype(
  planned : @semantic.PlannedProgramWasmGCLink,
  module_index : Int,
  type_ : @semantic.PlannedWasmPhysicalType,
) -> (@lib.SubType, Bool) {
  let module_ = planned.modules[module_index]
  let fields : Array[@lib.FieldType] = []
  let mut has_recursive_reference = false
  for index in 0..<type_.fields.length {
    let field = module_.fields[type_.fields.start + index]
    match field.storage {
      @semantic.WasmNominalRefStorage(@semantic.WasmRecursiveTypeReference(_))
      | @semantic.WasmNullableNominalRefStorage(
        @semantic.WasmRecursiveTypeReference(_)
      ) => has_recursive_reference = true
      _ => ()
    }
    fields.push(
      @lib.FieldType::new(
        starshine_program_storage_type(planned, module_index, field.storage),
        if field.mutable_ {
          @lib.Mut::var_()
        } else {
          @lib.Mut::const_()
        },
      ),
    )
  }
  let composite = @lib.CompType::struct_(fields)
  let subtype = match type_.kind {
    @semantic.PlannedWasmEnumBaseType(_) | @semantic.PlannedWasmClosureType =>
      @lib.SubType::new(false, [], composite)
    @semantic.PlannedWasmEnumSubtypeType(declaration, _, _) =>
      @lib.SubType::new(
        true,
        [
          @lib.TypeIdx::new(
            planned.type_lookup.get(declaration).unwrap().reinterpret_as_uint(),
          ),
        ],
        composite,
      )
    @semantic.PlannedWasmCaptureCellType(_) =>
      @lib.SubType::new(true, [], composite)
    @semantic.PlannedWasmLambdaClosureType(_) =>
      @lib.SubType::new(
        true,
        [
          @lib.TypeIdx::new(
            planned
            .physical_type_index(module_index, module_.closure_type_index)
            .reinterpret_as_uint(),
          ),
        ],
        composite,
      )
    @semantic.PlannedWasmTraitMethodSignatureType(requirement) =>
      starshine_program_function_subtype(
        planned,
        module_index,
        module_.function_of(requirement).unwrap(),
      )
    @semantic.PlannedWasmStructType(_)
    | @semantic.PlannedWasmForeignMarkerType(_)
    | @semantic.PlannedWasmTraitVTableType(_)
    | @semantic.PlannedWasmTraitObjectType(_) =>
      @lib.SubType::comp_type(composite)
  }
  (subtype, has_recursive_reference)
}

///|
fn starshine_program_function_type_subtype(
  planned : @semantic.PlannedProgramWasmGCLink,
  module_index : Int,
  function_type : @semantic.PlannedWasmFunctionTypeFragment,
) -> @lib.SubType {
  let module_ = planned.modules[module_index]
  let parameters : Array[@lib.ValType] = []
  for index in 0..<function_type.parameters.length {
    parameters.push(
      starshine_program_value_type(
        planned,
        module_index,
        module_.function_value_types[function_type.parameters.start + index],
      ),
    )
  }
  let results : Array[@lib.ValType] = []
  for index in 0..<function_type.results.length {
    results.push(
      starshine_program_value_type(
        planned,
        module_index,
        module_.function_value_types[function_type.results.start + index],
      ),
    )
  }
  @lib.SubType::comp_type(@lib.CompType::func(parameters, results))
}

///|
fn starshine_program_function_subtype(
  planned : @semantic.PlannedProgramWasmGCLink,
  module_index : Int,
  function_ : @semantic.PlannedWasmFunctionFragment,
) -> @lib.SubType {
  let module_ = planned.modules[module_index]
  let parameters : Array[@lib.ValType] = []
  for index in 0..<function_.parameters.length {
    parameters.push(
      starshine_program_value_type(
        planned,
        module_index,
        module_.function_value_types[function_.parameters.start + index],
      ),
    )
  }
  let results : Array[@lib.ValType] = []
  for index in 0..<function_.results.length {
    results.push(
      starshine_program_value_type(
        planned,
        module_index,
        module_.function_value_types[function_.results.start + index],
      ),
    )
  }
  @lib.SubType::comp_type(@lib.CompType::func(parameters, results))
}

///|
fn starshine_program_signature_rec_type(
  planned : @semantic.PlannedProgramWasmGCLink,
  signature : @semantic.PlannedProgramWasmSignatureType,
) -> @lib.RecType {
  let module_ = planned.modules[signature.module_index]
  let subtype = match signature.kind {
    @semantic.PlannedProgramFunctionType(function_type_index) =>
      starshine_program_function_type_subtype(
        planned,
        signature.module_index,
        module_.function_types[function_type_index],
      )
    @semantic.PlannedProgramFunctionSignature(function_index) =>
      starshine_program_function_subtype(
        planned,
        signature.module_index,
        module_.functions[function_index],
      )
  }
  @lib.RecType::new(subtype)
}

///|
fn starshine_program_erased_box_rec_type(slot : Int) -> @lib.RecType {
  let value_type = match slot {
    0 => @lib.ValType::i32()
    1 => @lib.ValType::i64()
    2 => @lib.ValType::f32()
    3 => @lib.ValType::f64()
    4 => @lib.ValType::v128()
    _ => @lib.ValType::eqref_null()
  }
  @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::struct_([
        @lib.FieldType::new(
          @lib.StorageType::val_type(value_type),
          @lib.Mut::const_(),
        ),
      ]),
    ),
  )
}
