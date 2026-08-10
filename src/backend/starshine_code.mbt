///|
pub enum StarshineProgramBinaryEmissionError {
  StarshineProgramCodeError(StarshineCodeEmissionError)
  StarshineProgramValidationError(@validate.ValidationError)
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
  InvalidFunctionBody(@semantic.BodyId)
  ProgramLinkDiagnostics(Int)
} derive(Eq, Debug)

///|
priv struct StarshineGenericSpecialization {
  generic_parameters : @semantic.HirSpan
  shapes : Array[@semantic.PlannedValueShape]
  specialization_shapes : @semantic.HirSpan
  specialization_evidence : @semantic.HirSpan
  specialization_abi_key : String
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
) -> @semantic.HirSpan {
  if callable.owner_generic_parameters.length > 0 {
    callable.owner_generic_parameters
  } else {
    callable.generic_parameters
  }
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
  match fallback {
    @semantic.GenericPlannedValueShape if specialization.specialization_shapes.length ==
      1 =>
      return specialization.shapes[specialization.specialization_shapes.start]
    _ => ()
  }
  let resolved_type = if type_ < -1 {
    -type_ - 2
  } else if type_ >= 0 && type_ < lowering.types.length() {
    match lowering.types[type_] {
      @semantic.BodyResolvedType(type_) => type_
      _ => return fallback
    }
  } else {
    return fallback
  }
  if resolved_type < 0 || resolved_type >= lowering.resolved_types.length() {
    return fallback
  }
  let parameter = match lowering.resolved_types[resolved_type] {
    @semantic.GenericParameterType(parameter) => parameter
    _ => return fallback
  }
  let parameter_local = @semantic.semantic_id_local(parameter)
  if parameter_local < specialization.generic_parameters.start ||
    parameter_local >=
    specialization.generic_parameters.start +
    specialization.generic_parameters.length {
    return fallback
  }
  let relative = parameter_local - specialization.generic_parameters.start
  if relative < 0 || relative >= specialization.specialization_shapes.length {
    return fallback
  }
  specialization.shapes[specialization.specialization_shapes.start + relative]
}

///|
priv enum StarshineEmitTask {
  EmitStarshineExpression(@semantic.ExprId)
  EmitStarshineRawExpression(@semantic.ExprId)
  EmitStarshineBlock(@semantic.BlockId)
  EmitStarshineEmpty
  EmitStarshineDefaultStorage(@semantic.PlannedWasmStorageType)
  FinishStarshineBlock(@semantic.BlockId)
  FinishStarshineLocalSet(Int, Int, @semantic.ExprId)
  FinishStarshineCaptureSet(Int, Int)
  FinishStarshineCall(
    @semantic.DeclId,
    @semantic.ExprId,
    Int,
    Int,
    @semantic.HirSpan
  )
  FinishStarshineParameterSelect(Int, Int)
  FinishStarshineDirectLambdaCall(Int, @semantic.HirSpan, Int)
  FinishStarshineFunctionValueCall(Int, Int)
  FinishStarshineClosureCall(
    Int,
    Int,
    Int,
    Int,
    Int,
    @semantic.PlannedValueShape,
    Int
  )
  FinishStarshineFixedArray(Int, @semantic.PlannedValueShape, Int, Int, Int)
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
  FinishStarshineStructNew(Int, Int)
  FinishStarshineEnumSubtype(Int, Int, Int)
  FinishStarshineFieldGet(Int, Int, @semantic.PlannedWasmStorageType, Bool)
  FinishStarshineMatch(@semantic.ExprId, @semantic.HirSpan, Int)
  FinishStarshineWhile(
    @semantic.ExprId,
    @semantic.ControlId,
    @semantic.HirSpan,
    Int,
    Int
  )
  FinishStarshineControlTransfer(@semantic.ControlId, Bool)
  FinishStarshineIf(@semantic.PlannedValueShape)
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
        | @semantic.WasmExternalNominalRefStorage(_) => true
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
    | @semantic.WasmExternalNominalRefStorage(_) =>
      [@lib.Instruction::ref_null(@lib.HeapType::abs(@lib.AbsHeapType::eq()))]
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
  scratch_index : Int,
  test_assert_function_index : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  match starshine_conversion_builtin_instructions(name, scratch_index) {
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
  } else if name == b"dew_reinterpret" {
    Ok([])
  } else if name == b"i32_add" {
    Ok([@lib.Instruction::i32_add()])
  } else if name == b"i32_sub" {
    Ok([@lib.Instruction::i32_sub()])
  } else if name == b"i32_lt" {
    Ok([@lib.Instruction::i32_lt_s()])
  } else if name == b"i32_lte" {
    Ok([@lib.Instruction::i32_le_s()])
  } else if name == b"swar32_from_bits" ||
    name == b"swar32_to_bits" ||
    name == b"swar64_from_bits" ||
    name == b"swar64_to_bits" {
    Ok([])
  } else if name == b"swar32_and" {
    Ok([@lib.Instruction::i32_and()])
  } else if name == b"swar32_or" {
    Ok([@lib.Instruction::i32_or()])
  } else if name == b"swar32_xor" {
    Ok([@lib.Instruction::i32_xor()])
  } else if name == b"swar64_and" {
    Ok([@lib.Instruction::i64_and()])
  } else if name == b"swar64_or" {
    Ok([@lib.Instruction::i64_or()])
  } else if name == b"swar64_xor" {
    Ok([@lib.Instruction::i64_xor()])
  } else if name == b"v128_and" {
    Ok([@lib.Instruction::v128_and()])
  } else if name == b"v128_or" {
    Ok([@lib.Instruction::v128_or()])
  } else if name == b"v128_xor" {
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
  scratch_index : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let output : Array[@lib.Instruction] = []
  for fragment in fragments {
    append_starshine_instructions(output, fragment)
  }
  let test_assert_function_index = planned.runtime_function_index(
    b"dew_test_assert",
  )
  let function_ = match planned.function_of(declaration) {
    Some(function_) => function_
    None => return Err(MissingFunction(declaration))
  }
  if function_.direct_builtin.length() > 0 {
    match
      starshine_inline_builtin_instructions(
        function_.direct_builtin,
        scratch_index,
        test_assert_function_index,
      ) {
      Ok(instructions) => append_starshine_instructions(output, instructions)
      Err(error) => return Err(error)
    }
  } else {
    match function_.kind {
      @semantic.PlannedWasmInlineBuiltinFunction(name) =>
        match
          starshine_inline_builtin_instructions(
            name, scratch_index, test_assert_function_index,
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
        output.push(
          @lib.Instruction::call(
            @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
          ),
        )
      }
      @semantic.PlannedWasmSignatureOnlyFunction =>
        return Err(SignatureOnlyCall(declaration))
    }
  }
  Ok(output)
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
    | @semantic.PlannedFieldGet(_, _) => true
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
    | @semantic.PlannedWhileExpression(_, _, _) => true
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
    @semantic.WasmExternalNominalRefValue(_) => true
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
  scratch_index : Int,
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  let output : Array[@lib.Instruction] = []
  let caller_module_index = match planned.module_lookup.get(caller.module_id) {
    Some(index) => index
    None => abort("caller's module is not linked")
  }
  let test_assert_function_index = planned.module_runtime_function_index(
    caller_module_index, b"dew_test_assert",
  )
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
  if fragments.length() + runtime_evidence_length == function_.parameters.length {
    for parameter_index, fragment in fragments {
      append_starshine_instructions(output, fragment)
      let needs_cast = if cross_module_or_specialized {
        starshine_program_argument_needs_nominal_cast(
          lowering, expression, parameter_index,
        )
      } else if starshine_program_parameter_is_external_nominal(
          planned, function_, parameter_index,
        ) {
        starshine_program_local_external_argument_needs_nominal_cast(
          lowering, expression, parameter_index,
        )
      } else {
        false
      }
      if needs_cast {
        starshine_append_program_argument_cast(
          planned, function_, parameter_index, output,
        )
      }
    }
  } else {
    for fragment in fragments {
      append_starshine_instructions(output, fragment)
    }
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
        scratch_index,
        test_assert_function_index,
      ) {
      Ok(instructions) => append_starshine_instructions(output, instructions)
      Err(error) => return Err(error)
    }
  } else {
    match function_.kind {
      @semantic.PlannedWasmInlineBuiltinFunction(name) =>
        match
          starshine_inline_builtin_instructions(
            name, scratch_index, test_assert_function_index,
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
        output.push(
          @lib.Instruction::call(
            @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
          ),
        )
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
fn starshine_ordered_variant_object_values(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  variant : @semantic.VariantId,
  fields : @semantic.HirSpan,
) -> Array[@semantic.ExprId]? {
  let values : Array[@semantic.ExprId] = []
  let variant_fields = planned.variant_fields_of(variant)
  if variant_fields.length() <= 8 {
    for planned_field in variant_fields {
      let field = match planned_field.role {
        @semantic.WasmStructPayloadField(field) => field
        _ => return None
      }
      let mut value = -1
      for source_index in 0..<fields.length {
        let object_field = lowering.object_fields[fields.start + source_index]
        if object_field.field == field {
          value = object_field.value
          break
        }
      }
      if value < 0 {
        return None
      }
      values.push(value)
    }
    return Some(values)
  }
  let lookup : Map[@semantic.FieldId, @semantic.ExprId] = Map::default()
  for source_index in 0..<fields.length {
    let object_field = lowering.object_fields[fields.start + source_index]
    lookup[object_field.field] = object_field.value
  }
  for planned_field in variant_fields {
    let field = match planned_field.role {
      @semantic.WasmStructPayloadField(field) => field
      _ => return None
    }
    match lookup.get(field) {
      Some(value) => values.push(value)
      None => return None
    }
  }
  Some(values)
}

///|
fn starshine_match_cast(type_index : Int) -> @lib.Instruction {
  @lib.Instruction::ref_cast(
    false,
    @lib.HeapType::new(@lib.TypeIdx::new(type_index.reinterpret_as_uint())),
  )
}

///|
fn starshine_precise_nominal_local_type_index(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  planned_local : @semantic.PlannedLocal,
) -> Int? {
  if planned_local.nominal == 0UL ||
    planned_local.nominal == @semantic.standard_fixed_array_type_declaration() ||
    planned_local.nominal == @semantic.standard_map_type_declaration() ||
    planned_local.nominal == @semantic.standard_set_type_declaration() {
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
    | @semantic.PlannedDirectCall(_, _, _, _)
    | @semantic.PlannedOperatorCall(_, _, _, _, _)
    | @semantic.PlannedIndexCall(_, _, _, _)
    | @semantic.PlannedIndexSetCall(_, _, _, _, _)
    | @semantic.PlannedFunctionValueCall(_, _, _)
    | @semantic.PlannedDirectLambdaCall(_, _, _)
    | @semantic.PlannedStructNew(_, _, _)
    | @semantic.PlannedVariantTupleNew(_, _, _)
    | @semantic.PlannedVariantStructNew(_, _, _)
    | @semantic.PlannedUnitVariant(_, _)
    | @semantic.PlannedParameterSelect(_, _) => true
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
    match planned.selected_constructor {
      @semantic.StructInferredPatternConstructor(_, _) => return true
      _ => ()
    }
    match planned.source {
      @semantic.HirAlternativePattern(_, _, _) => return true
      @semantic.HirTuplePattern(_, arguments, _) =>
        for index in 0..<arguments.length {
          let child = lowering.pattern_children[arguments.start + index]
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
                append_starshine_instructions(output, value)
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
            let physical = match
              starshine_variant_payload_physical_type(variant_plan, variant) {
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
                for field in variant_plan.variant_fields_of(variant) {
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
                  let mut selected : @semantic.PlannedWasmVariantField? = None
                  for candidate in variant_plan.variant_fields_of(variant) {
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
      let physical = match
        starshine_variant_payload_physical_type(variant_plan, variant) {
        Some(value) => value
        None => return Err(UnsupportedExpression(body.body, pattern))
      }
      let physical_type = match program {
        Some(link) =>
          link.physical_type_index(owner_module, physical.type_index)
        None => physical.type_index
      }
      for field in variant_plan.variant_fields_of(variant) {
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
        bindings.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(local_indices[local_id].reinterpret_as_uint()),
          ),
        )
      }
    }
    @semantic.HirStructPattern(_, pattern_fields, _, _, _) => {
      let physical = match
        starshine_variant_payload_physical_type(variant_plan, variant) {
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
        let mut selected_field : @semantic.PlannedWasmVariantField? = None
        for candidate in variant_plan.variant_fields_of(variant) {
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
  local_indices : Array[Int],
  generic_specialization : StarshineGenericSpecialization?,
) -> Result[
  (Array[@lib.Instruction], Array[@lib.Instruction]),
  StarshineCodeEmissionError,
] {
  if starshine_pattern_uses_general_emission(lowering, pattern) {
    starshine_general_match_pattern_instructions(
      lowering, planned, program, program_module_index, body, pattern, scratch_local,
      local_indices, generic_specialization,
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
fn starshine_body_value_type(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body_type : @semantic.BodyTypeId,
  shape : @semantic.PlannedValueShape,
) -> @lib.ValType? {
  if body_type < -1 {
    let resolved_type = -body_type - 2
    if planned.closure_type_index >= 0 &&
      resolved_type >= 0 &&
      resolved_type < planned.closure_entry_type_by_resolved.length() &&
      planned.closure_entry_type_by_resolved[resolved_type] >= 0 {
      return Some(@lib.ValType::eqref_null())
    }
    if resolved_type >= 0 &&
      resolved_type < planned.function_type_by_resolved.length() {
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
fn starshine_body_locals(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  body : @semantic.PlannedBodyLowering,
  leading_parameter_count : Int,
) -> (
  Array[Int],
  Array[@lib.ValType],
  Array[Int],
  Array[Int],
  Int,
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
  let mut parameter_count = leading_parameter_count
  for local_id in 0..<body.locals.length {
    let planned_local = lowering.locals[body.locals.start + local_id]
    match planned_local.kind {
      @semantic.ParameterLocal =>
        match
          starshine_body_value_type(
            lowering,
            planned,
            program,
            planned_local.type_,
            planned_local.shape,
          ) {
          Some(_) => {
            local_indices[local_id] = parameter_count
            parameter_count += 1
          }
          None => ()
        }
      @semantic.LetLocal | @semantic.PatternLocal => {
        if elided_locals[local_id] {
          continue
        }
        let cell_slot = starshine_local_capture_cell_slot(
          lowering, body, local_id,
        )
        let local_type = if cell_slot >= 0 {
          Some(@lib.ValType::eqref_null())
        } else {
          match
            starshine_precise_nominal_local_type_index(
              lowering, planned, program, planned_local,
            ) {
            Some(type_index) =>
              Some(
                starshine_nominal_ref(
                  @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
                ),
              )
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
            local_indices[local_id] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
    }
  }
  let match_local_indices = Array::make(lowering.expressions.length(), -1)
  let match_result_local_indices = Array::make(
    lowering.expressions.length(),
    -1,
  )
  let mut conversion_scratch_index = -1
  let mut fixed_array_ref_scratch_index = -1
  let mut fixed_array_i32_scratch_index = -1
  let map_key_local_indices = Array::make(lowering.expressions.length(), -1)
  let map_value_local_indices = Array::make(lowering.expressions.length(), -1)
  let mut map_ref_scratch_index = -1
  let mut map_bucket_scratch_index = -1
  let mut map_hash_scratch_index = -1
  let mut map_entry_scratch_index = -1
  let mut map_previous_scratch_index = -1
  let mut map_growth_index_scratch_index = -1
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
        match starshine_shape_value_type(lowering.expressions[initial].shape) {
          Some(type_) => {
            control_state_local_indices[control] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        match
          starshine_shape_value_type(lowering.expressions[expression].shape) {
          Some(type_) => {
            control_result_local_indices[control] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
      @semantic.PlannedDirectCall(declaration, _, _, _) => {
        let name = match program {
          Some(link) =>
            match link.function_of(declaration) {
              Some(function_) =>
                if function_.direct_builtin.length() > 0 {
                  function_.direct_builtin
                } else {
                  match function_.kind {
                    @semantic.PlannedWasmInlineBuiltinFunction(name) => name
                    _ => b""
                  }
                }
              None => b""
            }
          None =>
            match planned.function_of(declaration) {
              Some(function_) =>
                if function_.direct_builtin.length() > 0 {
                  function_.direct_builtin
                } else {
                  match function_.kind {
                    @semantic.PlannedWasmInlineBuiltinFunction(name) => name
                    _ => b""
                  }
                }
              None => b""
            }
        }
        if conversion_scratch_index < 0 &&
          starshine_conversion_builtin_needs_scratch(name) {
          conversion_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i32())
        }
      }
      @semantic.PlannedFunctionValueCall(_, _, _) =>
        if planned.closure_type_index >= 0 {
          match_local_indices[expression] = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
      @semantic.PlannedDynamicTraitCall(_, _, _, _, _, _) => {
        match_local_indices[expression] = parameter_count +
          body_local_types.length()
        body_local_types.push(@lib.ValType::eqref_null())
      }
      @semantic.PlannedMatchExpression(scrutinee, _) => {
        let scratch_type = match lowering.expressions[scrutinee].shape {
          @semantic.ErrorPlannedValueShape => Some(@lib.ValType::eqref_null())
          shape => starshine_shape_value_type(shape)
        }
        match scratch_type {
          Some(type_) => {
            match_local_indices[expression] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        match
          starshine_shape_value_type(lowering.expressions[expression].shape) {
          Some(type_) => {
            match_result_local_indices[expression] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
      @semantic.PlannedFixedArrayMake(_, _, _)
      | @semantic.PlannedFixedArrayGet(_, _, _) =>
        if fixed_array_ref_scratch_index < 0 {
          fixed_array_ref_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
          fixed_array_i32_scratch_index = parameter_count +
            body_local_types.length()
          body_local_types.push(@lib.ValType::i32())
        }
      @semantic.PlannedMapSingleton(_, _, key_shape, value_shape, _, _)
      | @semantic.PlannedMapInsert(_, _, _, key_shape, value_shape, _, _)
      | @semantic.PlannedMapSet(_, _, _, key_shape, value_shape, _, _) => {
        if map_ref_scratch_index < 0 {
          map_ref_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
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
            map_key_local_indices[expression] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        match starshine_shape_value_type(value_shape) {
          Some(type_) => {
            map_value_local_indices[expression] = parameter_count +
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
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
          map_entry_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
        }
        match starshine_shape_value_type(key_shape) {
          Some(type_) => {
            map_key_local_indices[expression] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
        match starshine_shape_value_type(value_shape) {
          Some(type_) => {
            map_value_local_indices[expression] = parameter_count +
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
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
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
            map_key_local_indices[expression] = parameter_count +
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
          map_bucket_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::eqref_null())
          map_hash_scratch_index = parameter_count + body_local_types.length()
          body_local_types.push(@lib.ValType::i64())
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
            map_key_local_indices[expression] = parameter_count +
              body_local_types.length()
            body_local_types.push(type_)
          }
          None => ()
        }
      }
      _ => ()
    }
  }
  (
    local_indices, body_local_types, match_local_indices, match_result_local_indices,
    conversion_scratch_index, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
    map_key_local_indices, map_value_local_indices, map_ref_scratch_index, map_bucket_scratch_index,
    map_hash_scratch_index, map_entry_scratch_index, map_previous_scratch_index,
    map_growth_index_scratch_index, control_state_local_indices, control_result_local_indices,
  )
}

///|
fn starshine_fixed_array_carrier(shape : @semantic.PlannedValueShape) -> Int {
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
    @semantic.RefPlannedValueShape => 5
    _ => -1
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
    Some(link) =>
      link.type_count +
      (if starshine_program_uses_text_runtime(link) { 6 } else { 0 })
    None => starshine_fixed_array_runtime_base(planned)
  }
}

///|
fn starshine_program_uses_fixed_array_runtime(
  program : @semantic.PlannedProgramWasmGCLink,
) -> Bool {
  for module_ in program.modules {
    if module_.uses_fixed_array_runtime {
      return true
    }
  }
  false
}

///|
fn starshine_map_base_for_body(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
) -> Int {
  match program {
    Some(link) =>
      link.type_count +
      (if starshine_program_uses_text_runtime(link) { 6 } else { 0 }) +
      (if starshine_program_uses_fixed_array_runtime(link) { 6 } else { 0 })
    None => starshine_map_runtime_base(planned)
  }
}

///|
fn starshine_map_entry_field(
  shape : @semantic.PlannedValueShape,
  value : Bool,
) -> Int {
  let carrier = starshine_fixed_array_carrier(shape)
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
  let key_carrier = starshine_fixed_array_carrier(key_shape)
  let value_carrier = starshine_fixed_array_carrier(value_shape)
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
  let key_carrier = starshine_fixed_array_carrier(key_shape)
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
  scratch_index : Int,
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
        scratch_index,
      )
    None =>
      starshine_finish_call(planned, declaration, arguments, scratch_index)
  }
}

///|
fn starshine_fixed_array_backing_prefix(
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  shape : @semantic.PlannedValueShape,
) -> (Array[@lib.Instruction], Int)? {
  let carrier = starshine_fixed_array_carrier(shape)
  guard carrier >= 0 else { return None }
  let wrapper = match
    starshine_emitted_type_index(
      planned,
      program,
      @semantic.standard_fixed_array_type_declaration(),
    ) {
    Some(value) => value
    None => return None
  }
  let array_type = starshine_fixed_array_base_for_body(planned, program) +
    carrier
  Some(
    (
      [
        starshine_match_cast(wrapper),
        @lib.Instruction::struct_get(
          @lib.TypeIdx::new(wrapper.reinterpret_as_uint()),
          @lib.U32::new(0U),
        ),
        starshine_match_cast(array_type),
      ],
      array_type,
    ),
  )
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
fn starshine_capture_source_instructions(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
  program : @semantic.PlannedProgramWasmGCLink?,
  module_index : Int,
  current_lambda : @semantic.LambdaId,
  source : @semantic.LambdaCaptureSource,
  local_indices : Array[Int],
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
    Some(link) =>
      match link.function_of(fragment.declaration) {
        Some(function_) => function_.function_index
        None => -1
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
            Some(link) if type_arguments.length > 0 =>
              link.specialized_function_reference_singleton_global(
                declaration,
                lowering.expression_type_argument_shapes,
                type_arguments,
                -1,
              ) <
              0
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
  let indices = Array::make(lowering.expressions.length(), -1)
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
          indices[expression] = local_index
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
    let local_index = cache_indices[expression]
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
    | @semantic.WasmExternalNominalRefValue(_) => 5
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
    | @semantic.ErrorPlannedValueShape => 5
    @semantic.UnitPlannedValueShape | @semantic.NeverPlannedValueShape => -1
  }
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
        if parameter_index >= specialization.generic_parameters.start &&
          parameter_index <
          specialization.generic_parameters.start +
          specialization.generic_parameters.length {
          let relative = parameter_index -
            specialization.generic_parameters.start
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
    if starshine_program_adapter_value_code(
        module_.function_value_types[parameters.start + index],
      ) !=
      parameter_codes[index] {
      return false
    }
  }
  for index in 0..<results.length {
    if starshine_program_adapter_value_code(
        module_.function_value_types[results.start + index],
      ) !=
      result_codes[index] {
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
  let local_signature = module_.function_type_by_resolved[function_type]
  let mut fragment = None
  for candidate in module_.function_types {
    if candidate.signature_type_index == local_signature {
      fragment = Some(candidate)
      break
    }
  }
  let fragment = match fragment {
    Some(value) => value
    None => return None
  }
  let parameter_codes : Array[Int] = []
  let mut runtime_index = 0
  for index in 0..<resolved_parameters.length {
    let resolved_parameter = lowering.resolved_type_arguments[resolved_parameters.start +
      index]
    let fallback = if runtime_index < fragment.parameters.length {
      starshine_program_adapter_value_code(
        module_.function_value_types[fragment.parameters.start + runtime_index],
      )
    } else {
      -1
    }
    let code = starshine_program_specialized_type_code(
      lowering, specialization, resolved_parameter, fallback,
    )
    if code >= 0 {
      parameter_codes.push(code)
      runtime_index += 1
    }
  }
  let result_codes : Array[Int] = []
  let fallback_result = if fragment.results.length == 1 {
    starshine_program_adapter_value_code(
      module_.function_value_types[fragment.results.start],
    )
  } else {
    -1
  }
  let result_code = starshine_program_specialized_type_code(
    lowering, specialization, resolved_result, fallback_result,
  )
  if result_code >= 0 {
    result_codes.push(result_code)
  }
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
  conversion_scratch_index : Int,
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
                let singleton_global = match program {
                  Some(link) if type_arguments.length > 0 =>
                    link.specialized_function_reference_singleton_global(
                      declaration,
                      lowering.expression_type_argument_shapes,
                      type_arguments,
                      starshine_program_expression_function_type_index(
                        lowering, planned, link, program_module_index, expression,
                      ),
                    )
                  Some(link) =>
                    link.function_reference_singleton_global(
                      program_module_index, declaration,
                    )
                  None => -1
                }
                let cache_local = function_reference_cache_indices[expression]
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
                  let function_index = match program {
                    Some(link) if type_arguments.length > 0 =>
                      match
                        link.specialized_function_of(
                          declaration,
                          lowering.expression_type_argument_shapes,
                          type_arguments,
                        ) {
                        Some(function_) => function_.function_index
                        None => return Err(MissingFunction(declaration))
                      }
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
            let scratch = match_local_indices[expression]
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
              let scratch = match_local_indices[expression]
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
              match (program, generic_specialization) {
                (Some(link), Some(specialization)) =>
                  match
                    starshine_program_specialized_closure_signatures(
                      lowering, link, planned, function_type, specialization,
                    ) {
                    Some((entry, direct)) => {
                      emitted_type = entry
                      emitted_direct_type = direct
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
                  emitted_type,
                  emitted_direct_type,
                  closure_type,
                  scratch,
                  arguments.length + 1,
                  starshine_specialized_shape(
                    lowering,
                    generic_specialization,
                    source.type_,
                    source.shape,
                  ),
                  starshine_function_result_cast_type(
                    planned, program, program_module_index, direct_local_type,
                  ),
                ),
              )
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
            }
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
          @semantic.PlannedCaptureGet(capture) => {
            if current_lambda < 0 {
              return Err(UnsupportedExpression(body.body, expression))
            }
            results.push(
              starshine_capture_get_instructions(
                lowering, planned, program, program_module_index, current_lambda,
                capture,
              ),
            )
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
              match local_info.shape {
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
            tasks.push(FinishStarshineCaptureSet(current_lambda, capture))
            tasks.push(EmitStarshineExpression(value))
          }
          @semantic.PlannedLocalGet(local_id) => {
            if local_id < 0 ||
              local_id >= local_indices.length() ||
              local_indices[local_id] < 0 {
              return Err(InvalidLocal(body.body, local_id))
            }
            let output = [
              @lib.Instruction::local_get(
                @lib.LocalIdx::new(
                  local_indices[local_id].reinterpret_as_uint(),
                ),
              ),
            ]
            let cell_slot = starshine_local_capture_cell_slot(
              lowering, body, local_id,
            )
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
            results.push(output)
          }
          @semantic.PlannedBlockExpression(block) =>
            tasks.push(EmitStarshineBlock(block))
          @semantic.PlannedIfExpression(condition, then_block, alternative) => {
            if alternative < 0 {
              return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(
              FinishStarshineIf(
                starshine_specialized_shape(
                  lowering,
                  generic_specialization,
                  source.type_,
                  source.shape,
                ),
              ),
            )
            tasks.push(EmitStarshineExpression(alternative))
            tasks.push(EmitStarshineBlock(then_block))
            tasks.push(EmitStarshineExpression(condition))
          }
          @semantic.PlannedParameterSelect(arguments, selected) => {
            tasks.push(
              FinishStarshineParameterSelect(arguments.length, selected),
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
          @semantic.PlannedDirectCall(
            declaration,
            receiver,
            arguments,
            type_arguments
          ) => {
            let receiver_count = if receiver >= 0 { 1 } else { 0 }
            tasks.push(
              FinishStarshineCall(
                declaration,
                expression,
                arguments.length + receiver_count,
                conversion_scratch_index,
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
            if receiver >= 0 {
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
            let receiver_count = if receiver >= 0 { 1 } else { 0 }
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
                    conversion_scratch_index,
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
            if receiver >= 0 {
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
              FinishStarshineCall(
                declaration, expression, 2, conversion_scratch_index, type_arguments,
              ),
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
                    requirement, expression, 2, conversion_scratch_index, type_arguments,
                  ),
                )
            }
            tasks.push(EmitStarshineExpression(right))
            tasks.push(EmitStarshineExpression(left))
          }
          @semantic.PlannedIndexCall(declaration, base, index, type_arguments) => {
            tasks.push(
              FinishStarshineCall(
                declaration, expression, 2, conversion_scratch_index, type_arguments,
              ),
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
              FinishStarshineCall(
                declaration, expression, 3, conversion_scratch_index, type_arguments,
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedFixedArrayMake(length, value, shape) => {
            tasks.push(
              FinishStarshineFixedArray(
                1, shape, 2, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(length))
          }
          @semantic.PlannedFixedArrayLength(base, shape) => {
            tasks.push(
              FinishStarshineFixedArray(
                2, shape, 1, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedFixedArrayGet(base, index, shape) => {
            tasks.push(
              FinishStarshineFixedArray(
                3, shape, 2, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedFixedArrayGetUnchecked(base, index, shape) => {
            tasks.push(
              FinishStarshineFixedArray(
                4, shape, 2, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(index))
            tasks.push(EmitStarshineExpression(base))
          }
          @semantic.PlannedFixedArraySet(base, index, value, shape)
          | @semantic.PlannedFixedArraySetUnchecked(base, index, value, shape) => {
            tasks.push(
              FinishStarshineFixedArray(
                5, shape, 3, fixed_array_ref_scratch_index, fixed_array_i32_scratch_index,
              ),
            )
            tasks.push(EmitStarshineExpression(value))
            tasks.push(EmitStarshineExpression(index))
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
                map_key_local_indices[expression],
                map_value_local_indices[expression],
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
                map_key_local_indices[expression],
                map_value_local_indices[expression],
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
                map_key_local_indices[expression],
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
                map_key_local_indices[expression],
                map_value_local_indices[expression],
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
                map_key_local_indices[expression],
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
                map_key_local_indices[expression],
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
          @semantic.PlannedStructNew(declaration, _, fields) => {
            let physical_plan = match program {
              Some(link) =>
                match
                  link.module_lookup.get(
                    @semantic.semantic_id_module(declaration),
                  ) {
                  Some(owner_module) => link.modules[owner_module]
                  None => planned
                }
              None => planned
            }
            let physical = match
              starshine_struct_physical_type(physical_plan, declaration) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            let type_index = match
              starshine_emitted_type_index(planned, program, declaration) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(
              FinishStarshineStructNew(type_index, physical.fields.length),
            )
            let mut physical_offset = physical.fields.length
            while physical_offset > 0 {
              physical_offset -= 1
              let planned_field = physical_plan.fields[physical.fields.start +
                physical_offset]
              let field = match planned_field.role {
                @semantic.WasmStructField(field) => field
                _ => return Err(UnsupportedExpression(body.body, expression))
              }
              let mut value = -1
              for source_index in 0..<fields.length {
                let candidate = lowering.object_fields[fields.start +
                  source_index]
                if candidate.field == field {
                  value = candidate.value
                  break
                }
              }
              if value < 0 {
                return Err(UnsupportedExpression(body.body, expression))
              }
              let value_source = lowering.expressions[value]
              let value_shape = starshine_specialized_shape(
                lowering,
                generic_specialization,
                value_source.type_,
                value_source.shape,
              )
              if starshine_shape_matches_storage(
                  value_shape,
                  planned_field.storage,
                ) {
                tasks.push(EmitStarshineExpression(value))
              } else {
                tasks.push(EmitStarshineDefaultStorage(planned_field.storage))
              }
            }
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
            let subtype = match program {
              Some(link) =>
                link.physical_type_index(owner_module, physical.type_index)
              None => physical.type_index
            }
            tasks.push(FinishStarshineEnumSubtype(subtype, tag, 0))
          }
          @semantic.PlannedVariantTupleNew(variant, _, arguments) => {
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
            let subtype = match program {
              Some(link) =>
                link.physical_type_index(owner_module, physical.type_index)
              None => physical.type_index
            }
            let values : Array[StarshineEmitTask] = []
            for field in variant_plan.variant_fields_of(variant) {
              let value = match field.role {
                @semantic.WasmTuplePayloadField(_, source_index) =>
                  lowering.expression_children[arguments.start + source_index]
                _ => return Err(UnsupportedExpression(body.body, expression))
              }
              let value_source = lowering.expressions[value]
              if starshine_shape_matches_storage(
                  starshine_specialized_shape(
                    lowering,
                    generic_specialization,
                    value_source.type_,
                    value_source.shape,
                  ),
                  field.storage,
                ) {
                values.push(EmitStarshineExpression(value))
              } else {
                values.push(EmitStarshineDefaultStorage(field.storage))
              }
            }
            tasks.push(
              FinishStarshineEnumSubtype(subtype, tag, values.length()),
            )
            let mut value_index = values.length()
            while value_index > 0 {
              value_index -= 1
              tasks.push(values[value_index])
            }
          }
          @semantic.PlannedVariantStructNew(variant, _, fields) => {
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
            let subtype = match program {
              Some(link) =>
                link.physical_type_index(owner_module, physical.type_index)
              None => physical.type_index
            }
            let values = match
              starshine_ordered_variant_object_values(
                lowering, variant_plan, variant, fields,
              ) {
              Some(values) => values
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            tasks.push(
              FinishStarshineEnumSubtype(subtype, tag, values.length()),
            )
            let variant_fields = variant_plan.variant_fields_of(variant)
            let mut value_index = values.length()
            while value_index > 0 {
              value_index -= 1
              let field = variant_fields[value_index]
              let value = values[value_index]
              let value_source = lowering.expressions[value]
              if starshine_shape_matches_storage(
                  starshine_specialized_shape(
                    lowering,
                    generic_specialization,
                    value_source.type_,
                    value_source.shape,
                  ),
                  field.storage,
                ) {
                tasks.push(EmitStarshineExpression(value))
              } else {
                tasks.push(EmitStarshineDefaultStorage(field.storage))
              }
            }
          }
          @semantic.PlannedMatchExpression(scrutinee, arms) => {
            let scratch_local = match_local_indices[expression]
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
          @semantic.PlannedBreakExpression(control, value) => {
            tasks.push(FinishStarshineControlTransfer(control, true))
            tasks.push(EmitStarshineExpression(value))
          }
          @semantic.PlannedContinueExpression(control, value) => {
            tasks.push(FinishStarshineControlTransfer(control, false))
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
          @semantic.PlannedFieldGet(field, base) => {
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
            let (local_type_index, physical_index, storage) = match
              starshine_field_location(field_plan, field, field_shape) {
              Some(value) => value
              None => return Err(UnsupportedExpression(body.body, expression))
            }
            let type_index = match program {
              Some(link) =>
                link.physical_type_index(owner_module, local_type_index)
              None => local_type_index
            }
            let needs_cast = match lowering.expressions[base].kind {
              @semantic.PlannedDirectCall(_, _, _, arguments) if arguments.length >
                0 => true
              @semantic.PlannedFunctionValueCall(_, _, _) => true
              @semantic.PlannedLocalGet(local_id) => {
                let local_info = lowering.locals[body.locals.start + local_id]
                (match local_info.kind {
                  @semantic.ParameterLocal => false
                  _ => true
                }) &&
                !(local_info.nominal != 0UL &&
                local_info.nominal !=
                @semantic.standard_fixed_array_type_declaration() &&
                local_info.nominal != @semantic.standard_map_type_declaration() &&
                local_info.nominal != @semantic.standard_set_type_declaration() &&
                (match lowering.type_layouts.layout_of(local_info.nominal) {
                  Some(layout) => layout.generic_parameters.length > 0
                  None => false
                }))
              }
              @semantic.PlannedBlockExpression(_)
              | @semantic.PlannedIfExpression(_, _, _)
              | @semantic.PlannedMatchExpression(_, _) => true
              _ => false
            }
            tasks.push(
              FinishStarshineFieldGet(
                type_index, physical_index, storage, needs_cast,
              ),
            )
            tasks.push(EmitStarshineExpression(base))
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
          | @semantic.PlannedConsumedExpression =>
            return Err(UnsupportedExpression(body.body, expression))
        }
      }
      EmitStarshineEmpty => results.push([])
      EmitStarshineDefaultStorage(storage) =>
        results.push(starshine_default_storage_instructions(storage))
      EmitStarshineBlock(block) => {
        let source = lowering.blocks[block]
        tasks.push(FinishStarshineBlock(block))
        let mut index = source.items.length
        while index > 0 {
          index -= 1
          let item = lowering.block_items[source.items.start + index]
          match item.kind {
            @semantic.PlannedLetItem(_, _, expression)
            | @semantic.PlannedReturnItem(expression)
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
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(local_index.reinterpret_as_uint()),
            ),
          )
          output.push(starshine_match_cast(cell_type))
          append_starshine_instructions(output, value)
          output.push(
            @lib.Instruction::struct_set(
              @lib.TypeIdx::new(cell_type.reinterpret_as_uint()),
              @lib.U32::new(0U),
            ),
          )
        } else {
          append_starshine_instructions(output, value)
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
      FinishStarshineCaptureSet(lambda, capture) => {
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
        let output = starshine_capture_cell_reference_instructions(
          lowering, planned, program, program_module_index, lambda, capture,
        )
        output.push(starshine_match_cast(cell_type))
        append_starshine_instructions(output, value)
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
              if local_id < 0 ||
                local_id >= local_indices.length() ||
                local_indices[local_id] < 0 {
                return Err(InvalidLocal(body.body, local_id))
              }
              let cell_slot = starshine_local_capture_cell_slot(
                lowering, body, local_id,
              )
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
            @semantic.PlannedReturnItem(_) =>
              output.push(@lib.Instruction::return_())
            @semantic.PlannedExpressionItem(expression) =>
              if index + 1 < source.items.length &&
                starshine_shape_value_type(
                  lowering.expressions[expression].shape,
                )
                is Some(_) {
                output.push(@lib.Instruction::drop())
              }
          }
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
        let backing = match
          starshine_fixed_array_backing_prefix(planned, program, shape) {
          Some(value) => value
          None => return Err(UnsupportedExpression(body.body, -101))
        }
        let backing_prefix = backing.0
        let array_type = backing.1
        let wrapper_type = match
          starshine_emitted_type_index(
            planned,
            program,
            @semantic.standard_fixed_array_type_declaration(),
          ) {
          Some(value) => value
          None => return Err(UnsupportedExpression(body.body, -102))
        }
        let output : Array[@lib.Instruction] = []
        if operation == 1 {
          if i32_scratch < 0 {
            return Err(UnsupportedExpression(body.body, -1))
          }
          append_starshine_instructions(output, fragments[0])
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(i32_scratch.reinterpret_as_uint()),
            ),
          )
          append_starshine_instructions(output, fragments[1])
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
          output.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(wrapper_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 2 {
          append_starshine_instructions(output, fragments[0])
          append_starshine_instructions(output, backing_prefix)
          output.push(@lib.Instruction::array_len())
        } else if operation == 4 {
          append_starshine_instructions(output, fragments[0])
          append_starshine_instructions(output, backing_prefix)
          append_starshine_instructions(output, fragments[1])
          output.push(
            @lib.Instruction::array_get(
              @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 5 {
          append_starshine_instructions(output, fragments[0])
          append_starshine_instructions(output, backing_prefix)
          append_starshine_instructions(output, fragments[1])
          append_starshine_instructions(output, fragments[2])
          output.push(
            @lib.Instruction::array_set(
              @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
            ),
          )
        } else if operation == 3 {
          if ref_scratch < 0 || i32_scratch < 0 {
            return Err(UnsupportedExpression(body.body, -1))
          }
          let link = match program {
            Some(value) => value
            None => return Err(UnsupportedExpression(body.body, -1))
          }
          let option_module = @semantic.semantic_id_module(
            @semantic.standard_option_some_variant(),
          )
          let option_module_index = match
            link.module_lookup.get(option_module) {
            Some(value) => value
            None => return Err(UnsupportedExpression(body.body, -1))
          }
          let option_plan = link.modules[option_module_index]
          let some_variant = @semantic.standard_option_some_variant()
          let none_variant = @semantic.standard_option_none_variant()
          let some_physical = match
            starshine_variant_payload_physical_type(option_plan, some_variant) {
            Some(value) => value
            None => return Err(UnsupportedExpression(body.body, -1))
          }
          let none_physical = match
            starshine_variant_payload_physical_type(option_plan, none_variant) {
            Some(value) => value
            None => return Err(UnsupportedExpression(body.body, -1))
          }
          let some_type = link.physical_type_index(
            option_module_index,
            some_physical.type_index,
          )
          let none_type = link.physical_type_index(
            option_module_index,
            none_physical.type_index,
          )
          let some_tag = option_plan.variant_tag_of(some_variant).unwrap()
          let none_tag = option_plan.variant_tag_of(none_variant).unwrap()
          append_starshine_instructions(output, fragments[0])
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(ref_scratch.reinterpret_as_uint()),
            ),
          )
          append_starshine_instructions(output, fragments[1])
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(i32_scratch.reinterpret_as_uint()),
            ),
          )
          let load_backing : Array[@lib.Instruction] = [
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(ref_scratch.reinterpret_as_uint()),
            ),
          ]
          append_starshine_instructions(load_backing, backing_prefix)
          let success : Array[@lib.Instruction] = [
            @lib.Instruction::i32_const(@lib.I32::new(some_tag)),
          ]
          for field in option_plan.variant_fields_of(some_variant) {
            if starshine_shape_matches_storage(shape, field.storage) {
              append_starshine_instructions(success, load_backing)
              success.push(
                @lib.Instruction::local_get(
                  @lib.LocalIdx::new(i32_scratch.reinterpret_as_uint()),
                ),
              )
              success.push(
                @lib.Instruction::array_get(
                  @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
                ),
              )
            } else {
              append_starshine_instructions(
                success,
                starshine_default_storage_instructions(field.storage),
              )
            }
          }
          success.push(
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(some_type.reinterpret_as_uint()),
            ),
          )
          let failure = [
            @lib.Instruction::i32_const(@lib.I32::new(none_tag)),
            @lib.Instruction::struct_new(
              @lib.TypeIdx::new(none_type.reinterpret_as_uint()),
            ),
          ]
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(i32_scratch.reinterpret_as_uint()),
            ),
          )
          append_starshine_instructions(output, load_backing)
          output.push(@lib.Instruction::array_len())
          output.push(@lib.Instruction::i32_lt_u())
          output.push(
            @lib.Instruction::if_(
              @lib.BlockType::val_type(@lib.ValType::eqref_null()),
              success,
              Some(failure),
            ),
          )
        } else {
          return Err(UnsupportedExpression(body.body, -1))
        }
        results.push(output)
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
          starshine_map_call(
            planned,
            program,
            hash_declaration,
            [
              [
                @lib.Instruction::local_get(
                  @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
                ),
              ],
            ],
            conversion_scratch_index,
          ) {
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
          starshine_map_call(
            planned,
            program,
            eq_declaration,
            [
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
            ],
            conversion_scratch_index,
          ) {
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
          starshine_map_call(
            planned,
            program,
            hash_declaration,
            [
              [
                @lib.Instruction::local_get(
                  @lib.LocalIdx::new(key_local.reinterpret_as_uint()),
                ),
              ],
            ],
            conversion_scratch_index,
          ) {
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
        append_starshine_instructions(output, fragments[0])
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
          starshine_map_call(
            planned,
            program,
            eq_declaration,
            [
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
            ],
            conversion_scratch_index,
          ) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
        append_starshine_instructions(on_hash, eq_call)
        let found : Array[@lib.Instruction] = []
        if operation == 3 {
          let (link, option_module_index, option_module_plan) = option_plan.unwrap()
          let some_variant = @semantic.standard_option_some_variant()
          let some_physical = match
            starshine_variant_payload_physical_type(
              option_module_plan, some_variant,
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
          for field in option_module_plan.variant_fields_of(some_variant) {
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
      FinishStarshineParameterSelect(count, selected) => {
        let fragments = pop_starshine_fragments(results, count)
        let output : Array[@lib.Instruction] = []
        for index, fragment in fragments {
          append_starshine_instructions(output, fragment)
          if index != selected && fragment.length() > 0 {
            output.push(@lib.Instruction::drop())
          }
        }
        results.push(output)
      }
      FinishStarshineCall(
        declaration,
        expression,
        count,
        scratch_index,
        type_arguments
      ) => {
        let fragments = pop_starshine_fragments(results, count)
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
              scratch_index,
            )
          None =>
            starshine_finish_call(
              planned, declaration, fragments, scratch_index,
            )
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
      FinishStarshineClosureCall(
        entry_type,
        direct_type,
        closure_type,
        scratch,
        count,
        result_shape,
        result_cast_type
      ) => {
        let fragments = pop_starshine_fragments(results, count)
        let output : Array[@lib.Instruction] = []
        append_starshine_instructions(output, fragments[count - 1])
        output.push(
          @lib.Instruction::local_set(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        let direct : Array[@lib.Instruction] = []
        for index in 0..<(count - 1) {
          append_starshine_instructions(direct, fragments[index])
        }
        direct.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        direct.push(starshine_match_cast(closure_type))
        direct.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
        )
        direct.push(
          @lib.Instruction::ref_cast(
            false,
            @lib.HeapType::new(
              @lib.TypeIdx::new(direct_type.reinterpret_as_uint()),
            ),
          ),
        )
        direct.push(
          @lib.Instruction::call_ref(
            @lib.TypeIdx::new(direct_type.reinterpret_as_uint()),
          ),
        )
        let captured : Array[@lib.Instruction] = [
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        ]
        for index in 0..<(count - 1) {
          append_starshine_instructions(captured, fragments[index])
        }
        captured.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        captured.push(starshine_match_cast(closure_type))
        captured.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
        )
        captured.push(
          @lib.Instruction::ref_cast(
            false,
            @lib.HeapType::new(
              @lib.TypeIdx::new(entry_type.reinterpret_as_uint()),
            ),
          ),
        )
        captured.push(
          @lib.Instruction::call_ref(
            @lib.TypeIdx::new(entry_type.reinterpret_as_uint()),
          ),
        )
        output.push(
          @lib.Instruction::local_get(
            @lib.LocalIdx::new(scratch.reinterpret_as_uint()),
          ),
        )
        output.push(starshine_match_cast(closure_type))
        output.push(
          @lib.Instruction::struct_get(
            @lib.TypeIdx::new(closure_type.reinterpret_as_uint()),
            @lib.U32::new(0U),
          ),
        )
        output.push(
          @lib.Instruction::ref_test(
            false,
            @lib.HeapType::new(
              @lib.TypeIdx::new(direct_type.reinterpret_as_uint()),
            ),
          ),
        )
        output.push(
          @lib.Instruction::if_(
            starshine_block_type(result_shape),
            direct,
            Some(captured),
          ),
        )
        if result_cast_type >= 0 {
          output.push(starshine_match_cast(result_cast_type))
        }
        results.push(output)
      }
      FinishStarshineStructNew(type_index, count) => {
        let fragments = pop_starshine_fragments(results, count)
        let output : Array[@lib.Instruction] = []
        for fragment in fragments {
          append_starshine_instructions(output, fragment)
        }
        output.push(
          @lib.Instruction::struct_new(
            @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshineEnumSubtype(type_index, tag, count) => {
        let fragments = pop_starshine_fragments(results, count)
        let output : Array[@lib.Instruction] = [
          @lib.Instruction::i32_const(@lib.I32::new(tag)),
        ]
        for fragment in fragments {
          append_starshine_instructions(output, fragment)
        }
        output.push(
          @lib.Instruction::struct_new(
            @lib.TypeIdx::new(type_index.reinterpret_as_uint()),
          ),
        )
        results.push(output)
      }
      FinishStarshineFieldGet(type_index, field_index, storage, needs_cast) => {
        let output = results.pop().unwrap()
        if needs_cast {
          output.push(starshine_match_cast(type_index))
        }
        output.push(
          starshine_struct_get_instruction(type_index, field_index, storage),
        )
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
        let result_local = match_result_local_indices[expression]
        let dense_arm_by_tag = Array::make(arms.length, -1)
        let mut dense_dispatch = planned.dense_enum_dispatch &&
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
              bindings.push(
                @lib.Instruction::local_set(
                  @lib.LocalIdx::new(result_local.reinterpret_as_uint()),
                ),
              )
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
                local_indices,
                generic_specialization,
              ) {
              Ok(value) => value
              Err(error) => return Err(error)
            }
            let success = arm_bodies[arm_index]
            if result_local >= 0 {
              success.push(
                @lib.Instruction::local_set(
                  @lib.LocalIdx::new(result_local.reinterpret_as_uint()),
                ),
              )
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
          output.push(starshine_match_local_get(result_local))
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
        if state_local >= 0 {
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(state_local.reinterpret_as_uint()),
            ),
          )
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
          let (condition, bindings) = match
            starshine_match_pattern_instructions(
              lowering,
              planned,
              program,
              program_module_index,
              body,
              arm.pattern,
              state_local,
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
        let loop_body : Array[@lib.Instruction] = [
          @lib.Instruction::block(
            @lib.BlockType::void_(),
            @lib.Expr::new(dispatch),
          ),
          @lib.Instruction::unreachable_(),
        ]
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
          output.push(
            @lib.Instruction::local_get(
              @lib.LocalIdx::new(result_local.reinterpret_as_uint()),
            ),
          )
        } else {
          match lowering.expressions[expression].shape {
            @semantic.NeverPlannedValueShape =>
              output.push(@lib.Instruction::unreachable_())
            _ => ()
          }
        }
        results.push(output)
      }
      FinishStarshineControlTransfer(control, break_) => {
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
          output.push(
            @lib.Instruction::local_set(
              @lib.LocalIdx::new(target_local.reinterpret_as_uint()),
            ),
          )
        }
        output.push(
          @lib.Instruction::br(
            starshine_control_transfer_label(control, break_),
          ),
        )
        results.push(output)
      }
      FinishStarshineIf(shape) => {
        let alternative = results.pop().unwrap()
        let consequent = results.pop().unwrap()
        let condition = results.pop().unwrap()
        let output : Array[@lib.Instruction] = []
        append_starshine_instructions(output, condition)
        output.push(
          @lib.Instruction::if_(
            starshine_block_type(shape),
            consequent,
            Some(alternative),
          ),
        )
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
    let discard_root = match body.result_shape {
      @semantic.UnitPlannedValueShape =>
        starshine_shape_value_type(body.root_shape) is Some(_)
      _ => false
    }
    if discard_root {
      output.push(@lib.Instruction::drop())
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
  let final_index = match
    fragments.function_value_types[function_.parameters.start + parameter_index] {
    @semantic.WasmNominalRefValue(index) =>
      planned.physical_type_index(function_.module_index, index)
    @semantic.WasmExternalNominalRefValue(declaration) =>
      planned.type_lookup.get(declaration).unwrap()
    _ => -1
  }
  if final_index >= 0 {
    instructions.push(
      @lib.Instruction::ref_cast(
        false,
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
  let final_index = match
    fragments.function_value_types[function_.results.start] {
    @semantic.WasmNominalRefValue(index) =>
      planned.physical_type_index(function_.module_index, index)
    @semantic.WasmExternalNominalRefValue(declaration) =>
      planned.type_lookup.get(declaration).unwrap()
    _ => -1
  }
  if final_index >= 0 {
    instructions.push(
      @lib.Instruction::ref_cast(
        false,
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
  let (
    local_indices,
    body_local_types,
    match_local_indices,
    match_result_local_indices,
    conversion_scratch_index,
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
  ) = starshine_body_locals(
    lowering,
    planned,
    program,
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
      { program, module_index: program_module_index, helper_plan: None },
      body,
      lambda,
      local_indices,
      match_local_indices,
      match_result_local_indices,
      function_reference_cache_indices,
      conversion_scratch_index,
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
      None,
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
    conversion_scratch_index,
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
  ) = starshine_body_locals(lowering, planned, None, body, 0)
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
      { program: None, module_index: -1, helper_plan: None },
      body,
      -1,
      local_indices,
      match_local_indices,
      match_result_local_indices,
      function_reference_cache_indices,
      conversion_scratch_index,
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
      @semantic.WasmNominalRefStorage(@semantic.WasmRecursiveTypeReference(_)) =>
        has_recursive_reference = true
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
