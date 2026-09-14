///|
/// Soundness class used by Dewdrop's compiler-fact producers.
pub enum StarshineCompilerFactProofStrength {
  StructuralCompilerFactProof
  SemanticCompilerFactProof
  WholeProgramCompilerFactProof
  FlowSensitiveCompilerFactProof
  ProfileHintCompilerFactProof
} derive(Eq, Debug)

///|
/// Test/debug summary. Normal compilation does not print this record.
pub struct StarshineCompilerFactSummary {
  mut functions_with_facts : Int
  mut function_effect_summaries : Int
  mut parameter_facts : Int
  mut parameter_no_escape_proofs : Int
  mut result_facts : Int
  fresh_result_facts : Int
  mut signature_facts : Int
  mut type_facts : Int
  closed_type_populations : Int
  mut field_facts : Int
  mut closed_field_contents : Int
  array_element_facts : Int
  mut global_facts : Int
  mut steady_state_globals : Int
  table_facts : Int
  complete_tables : Int
  mut expression_facts : Int
  mut integer_range_facts : Int
  mut known_bit_facts : Int
  mut float_facts : Int
  mut reference_nonnull_facts : Int
  mut exact_heap_types : Int
  closed_heap_sets : Int
  mut closed_function_target_sets : Int
  mut callsite_facts : Int
  mut exact_call_targets : Int
  mut allocation_facts : Int
  no_escape_allocations : Int
  identity_unobserved_allocations : Int
  access_facts : Int
  proven_in_bounds_accesses : Int
  numeric_facts : Int
  no_wrap_facts : Int
  exact_divisions : Int
  relations : Int
  hints : Int
  mut provenance_bearing_site_facts : Int
  mut generation_time_us : UInt64
} derive(Eq, Debug)

///|
pub fn StarshineCompilerFactSummary::new() -> StarshineCompilerFactSummary {
  {
    functions_with_facts: 0,
    function_effect_summaries: 0,
    parameter_facts: 0,
    parameter_no_escape_proofs: 0,
    result_facts: 0,
    fresh_result_facts: 0,
    signature_facts: 0,
    type_facts: 0,
    closed_type_populations: 0,
    field_facts: 0,
    closed_field_contents: 0,
    array_element_facts: 0,
    global_facts: 0,
    steady_state_globals: 0,
    table_facts: 0,
    complete_tables: 0,
    expression_facts: 0,
    integer_range_facts: 0,
    known_bit_facts: 0,
    float_facts: 0,
    reference_nonnull_facts: 0,
    exact_heap_types: 0,
    closed_heap_sets: 0,
    closed_function_target_sets: 0,
    callsite_facts: 0,
    exact_call_targets: 0,
    allocation_facts: 0,
    no_escape_allocations: 0,
    identity_unobserved_allocations: 0,
    access_facts: 0,
    proven_in_bounds_accesses: 0,
    numeric_facts: 0,
    no_wrap_facts: 0,
    exact_divisions: 0,
    relations: 0,
    hints: 0,
    provenance_bearing_site_facts: 0,
    generation_time_us: 0UL,
  }
}

///|
/// Machine-readable frozen-v1 family audit used by tests and documentation.
pub fn starshine_compiler_fact_proof_strengths() -> Array[
  StarshineCompilerFactProofStrength,
] {
  [
    StructuralCompilerFactProof,
    SemanticCompilerFactProof,
    WholeProgramCompilerFactProof,
    FlowSensitiveCompilerFactProof,
    ProfileHintCompilerFactProof,
  ]
}

///|
pub fn starshine_compiler_fact_family_audit() -> Array[(String, String)] {
  [
    ("ProducerInfo", "Emitted"),
    ("WorldFacts", "Emitted"),
    ("ClosedValueSet", "EmittedConditionally"),
    ("IntegerFacts", "EmittedConditionally"),
    ("KnownBits", "EmittedConditionally"),
    ("FloatFacts", "EmittedConditionally"),
    ("VectorFacts", "NotCurrentlyProvable"),
    ("ReferenceFacts", "EmittedConditionally"),
    ("ValueRef", "NotCurrentlyProvable"),
    ("ResultIdentityFacts", "NotCurrentlyProvable"),
    ("aliases", "NotCurrentlyProvable"),
    ("EffectFacts", "Emitted"),
    ("closed effect resource sets", "EmittedConditionally"),
    ("ParameterFacts", "EmittedConditionally"),
    ("ParameterUseMask", "EmittedConditionally"),
    ("EscapeSinkMask", "EmittedConditionally"),
    ("ResultFacts", "EmittedConditionally"),
    ("FunctionBoundaryFacts", "Emitted"),
    ("FunctionProfile", "HintRequiresProfileData"),
    ("InlinePolicy", "HintRequiresProfileData"),
    ("FunctionFacts", "Emitted"),
    ("SignatureFacts", "EmittedConditionally"),
    ("TypePopulation", "NotCurrentlyProvable"),
    ("FieldFacts", "EmittedConditionally"),
    ("ArrayElementFacts", "EmittedConditionally"),
    ("TypeFacts", "EmittedConditionally"),
    ("MutationFacts", "EmittedConditionally"),
    ("GlobalFacts", "EmittedConditionally"),
    ("TableEntryFacts", "NotApplicableToDewdrop"),
    ("TableFacts", "NotApplicableToDewdrop"),
    ("ExpressionFact", "EmittedConditionally"),
    ("ScopedRelationFacts", "NotCurrentlyProvable"),
    ("CallSiteFacts", "EmittedConditionally"),
    ("BranchFacts", "HintRequiresProfileData"),
    ("LoopFacts", "HintRequiresProfileData"),
    ("AllocationSiteFacts", "EmittedConditionally"),
    ("AccessSiteFacts", "NotCurrentlyProvable"),
    ("NumericOperationSiteFacts", "NotCurrentlyProvable"),
    ("OptimizationGoal", "HintRequiresProfileData"),
    ("Hotness/temperature hints", "HintRequiresProfileData"),
    ("Inline hints", "HintRequiresProfileData"),
    ("branch probability", "HintRequiresProfileData"),
    ("estimated loop trips", "HintRequiresProfileData"),
    ("likely call target", "HintRequiresProfileData"),
    ("likely heap type", "HintRequiresProfileData"),
    ("SourceProvenance", "EmittedConditionally"),
  ]
}

///|
fn starshine_fact_type_index(type_ : @lib.TypeIdx) -> UInt? {
  match type_ {
    @lib.TypeIdx(value) => Some(value)
    @lib.RecIdx(_) => None
  }
}

///|
fn starshine_fact_heap_type(
  heap : @lib.HeapType,
) -> @representation.FactHeapType? {
  match heap {
    @lib.HeapType(type_) =>
      match starshine_fact_type_index(type_) {
        Some(index) => Some(@representation.FactHeapType::type_index(index))
        None => None
      }
    @lib.AbsHeapTypeHeapType(type_) | @lib.SharedAbsHeapTypeHeapType(type_) =>
      match type_ {
        @lib.AnyAbsHeapType => Some(@representation.FactHeapType::any())
        @lib.EqAbsHeapType => Some(@representation.FactHeapType::eq())
        @lib.StructAbsHeapType => Some(@representation.FactHeapType::struct_())
        @lib.ArrayAbsHeapType => Some(@representation.FactHeapType::array())
        @lib.I31AbsHeapType => Some(@representation.FactHeapType::i31())
        @lib.FuncAbsHeapType => Some(@representation.FactHeapType::func())
        @lib.ExternAbsHeapType => Some(@representation.FactHeapType::extern_())
        @lib.ExnAbsHeapType => Some(@representation.FactHeapType::exn())
        @lib.ContAbsHeapType => Some(@representation.FactHeapType::cont())
        @lib.StringAbsHeapType => Some(@representation.FactHeapType::string())
        @lib.NoneAbsHeapType => Some(@representation.FactHeapType::none())
        @lib.NoFuncAbsHeapType => Some(@representation.FactHeapType::no_func())
        @lib.NoExternAbsHeapType =>
          Some(@representation.FactHeapType::no_extern())
        @lib.NoExnAbsHeapType => Some(@representation.FactHeapType::no_exn())
        @lib.NoContAbsHeapType => Some(@representation.FactHeapType::no_cont())
        // Compiler-facts v1 has no waitqueue heap-type encoding.
        @lib.WaitqueueAbsHeapType | @lib.NoWaitqueueAbsHeapType => None
      }
    @lib.DefTypeHeapType(_) => None
  }
}

///|
fn starshine_fact_provenance(
  lowering : @semantic.PlannedProgramLowering,
  value : @semantic.PlannedProgramWasmFunction?,
) -> @representation.SourceProvenance? {
  match value {
    Some(value) => {
      let body = match value.kind {
        @semantic.PlannedWasmDefinedFunction(body) => Some(body)
        @semantic.PlannedWasmDefinedLambdaFunction(lambda) =>
          match lowering.modules[value.module_index].lambda_body(lambda) {
            Some(body) => Some(body.body)
            None => None
          }
        _ => None
      }
      return Some(
        @representation.SourceProvenance::new(
          module_id=Some(lowering.modules[value.module_index].module_id),
          declaration_id=Some(value.declaration),
          body_id=body,
          source_offset=Some(value.offset),
        ),
      )
    }
    None => None
  }
}

///|
fn starshine_fact_f32_class(bits : UInt) -> @representation.FloatClassMask {
  let negative = (bits & 0x8000_0000U) != 0U
  let exponent = bits & 0x7F80_0000U
  let fraction = bits & 0x007F_FFFFU
  if exponent == 0U {
    if fraction == 0U {
      if negative {
        @representation.FloatClassMask::negative_zero()
      } else {
        @representation.FloatClassMask::positive_zero()
      }
    } else if negative {
      @representation.FloatClassMask::negative_subnormal()
    } else {
      @representation.FloatClassMask::positive_subnormal()
    }
  } else if exponent == 0x7F80_0000U {
    if fraction != 0U {
      @representation.FloatClassMask::nan()
    } else if negative {
      @representation.FloatClassMask::negative_infinity()
    } else {
      @representation.FloatClassMask::positive_infinity()
    }
  } else if negative {
    @representation.FloatClassMask::negative_normal()
  } else {
    @representation.FloatClassMask::positive_normal()
  }
}

///|
fn starshine_fact_f64_class(bits : UInt64) -> @representation.FloatClassMask {
  let negative = (bits & 0x8000_0000_0000_0000UL) != 0UL
  let exponent = bits & 0x7FF0_0000_0000_0000UL
  let fraction = bits & 0x000F_FFFF_FFFF_FFFFUL
  if exponent == 0UL {
    if fraction == 0UL {
      if negative {
        @representation.FloatClassMask::negative_zero()
      } else {
        @representation.FloatClassMask::positive_zero()
      }
    } else if negative {
      @representation.FloatClassMask::negative_subnormal()
    } else {
      @representation.FloatClassMask::positive_subnormal()
    }
  } else if exponent == 0x7FF0_0000_0000_0000UL {
    if fraction != 0UL {
      @representation.FloatClassMask::nan()
    } else if negative {
      @representation.FloatClassMask::negative_infinity()
    } else {
      @representation.FloatClassMask::positive_infinity()
    }
  } else if negative {
    @representation.FloatClassMask::negative_normal()
  } else {
    @representation.FloatClassMask::positive_normal()
  }
}

///|
fn starshine_fact_primitive_value(
  primitive : @semantic.PrimitiveType,
) -> @representation.ValueFacts? {
  let width = @representation.IntWidth::i32()
  match primitive {
    @semantic.BoolType =>
      Some(
        @representation.ValueFacts::new(
          integer=Some(
            @representation.IntegerFacts::new(
              width,
              unsigned_range=Some(@representation.UnsignedRange::new(0UL, 1UL)),
              known_bits=Some(
                @representation.KnownBits::new(0xFFFF_FFFEUL, 0UL),
              ),
            ),
          ),
        ),
      )
    @semantic.I8Type =>
      Some(@representation.ValueFacts::signed_range(-128L, 127L, width~))
    @semantic.U8Type =>
      Some(
        @representation.ValueFacts::new(
          integer=Some(
            @representation.IntegerFacts::new(
              width,
              unsigned_range=Some(
                @representation.UnsignedRange::new(0UL, 255UL),
              ),
              known_bits=Some(
                @representation.KnownBits::new(0xFFFF_FF00UL, 0UL),
              ),
            ),
          ),
        ),
      )
    @semantic.I16Type =>
      Some(@representation.ValueFacts::signed_range(-32768L, 32767L, width~))
    @semantic.U16Type =>
      Some(
        @representation.ValueFacts::new(
          integer=Some(
            @representation.IntegerFacts::new(
              width,
              unsigned_range=Some(
                @representation.UnsignedRange::new(0UL, 65535UL),
              ),
              known_bits=Some(
                @representation.KnownBits::new(0xFFFF_0000UL, 0UL),
              ),
            ),
          ),
        ),
      )
    @semantic.U32Type =>
      Some(
        @representation.ValueFacts::unsigned_range(0UL, 0xFFFF_FFFFUL, width~),
      )
    _ => None
  }
}

///|
fn starshine_fact_resolved_value(
  module_ : @semantic.PlannedModuleLowering,
  type_ : @semantic.ResolvedTypeId,
) -> @representation.ValueFacts? {
  if type_ < 0 || type_ >= module_.resolved_types.length() {
    return None
  }
  match module_.resolved_types[type_] {
    @semantic.PrimitiveType(primitive) =>
      starshine_fact_primitive_value(primitive)
    _ => None
  }
}

///|
fn starshine_fact_local_value(
  module_ : @semantic.PlannedModuleLowering,
  local_info : @semantic.PlannedLocal,
) -> @representation.ValueFacts? {
  if local_info.type_ < 0 || local_info.type_ >= module_.types.length() {
    return None
  }
  match module_.types[local_info.type_] {
    @semantic.BodyResolvedType(type_) =>
      starshine_fact_resolved_value(module_, type_)
    _ => None
  }
}

///|
fn starshine_fact_body_for_function(
  lowering : @semantic.PlannedProgramLowering,
  function_ : @semantic.PlannedProgramWasmFunction,
) -> @semantic.PlannedBodyLowering? {
  let module_ = lowering.modules[function_.module_index]
  match function_.kind {
    @semantic.PlannedWasmDefinedFunction(body) => {
      let index = @semantic.semantic_id_local(body)
      if index >= 0 && index < module_.bodies.length() {
        Some(module_.bodies[index])
      } else {
        None
      }
    }
    @semantic.PlannedWasmDefinedLambdaFunction(lambda) =>
      module_.lambda_body(lambda)
    _ => None
  }
}

///|
fn starshine_fact_function_parameters(
  lowering : @semantic.PlannedProgramLowering,
  function_ : @semantic.PlannedProgramWasmFunction,
  host_callable : Bool,
  sites : Array[(UInt, @lib.Instruction)]?,
  summary : StarshineCompilerFactSummary,
) -> Array[@representation.ParameterFacts] {
  let body = match starshine_fact_body_for_function(lowering, function_) {
    Some(body) => body
    None => return []
  }
  let module_ = lowering.modules[function_.module_index]
  let used = Array::make(function_.parameters.length, false)
  match sites {
    Some(values) =>
      for entry in values {
        match entry.1 {
          @lib.LocalGet(@lib.LocalIdx(index)) => {
            let slot = index.reinterpret_as_int()
            if slot >= 0 && slot < used.length() {
              used[slot] = true
            }
          }
          _ => ()
        }
      }
    None => ()
  }
  let facts : Array[@representation.ParameterFacts] = []
  match module_.functions.callable_of(function_.declaration) {
    Some(callable) if callable.parameters.length == function_.parameters.length => {
      for parameter in 0..<callable.parameters.length {
        let source = module_.functions.parameters[callable.parameters.start +
          parameter]
        let value = if host_callable {
          None
        } else {
          starshine_fact_resolved_value(module_, source.type_)
        }
        let uses = if used[parameter] {
          @representation.ParameterUseMask::all_known()
        } else {
          @representation.ParameterUseMask::empty()
        }
        let escape = if !used[parameter] &&
          source.shape is @semantic.RefPlannedValueShape {
          summary.parameter_no_escape_proofs += 1
          Some(@representation.EscapeSinkMask::empty())
        } else if source.shape is @semantic.RefPlannedValueShape {
          Some(@representation.EscapeSinkMask::all_known())
        } else {
          None
        }
        facts.push(
          @representation.ParameterFacts::new(
            parameter.reinterpret_as_uint(),
            value~,
            uses=Some(uses),
            escape_sinks=escape,
          ),
        )
        summary.parameter_facts += 1
        match value {
          Some({ integer: Some(integer), .. }) => {
            if integer.unsigned_range is Some(_) ||
              integer.signed_range is Some(_) {
              summary.integer_range_facts += 1
            }
            if integer.known_bits is Some(_) {
              summary.known_bit_facts += 1
            }
          }
          _ => ()
        }
      }
      return facts
    }
    _ => ()
  }
  let mut parameter = 0
  for local_index in 0..<body.locals.length {
    let local_info = module_.locals[body.locals.start + local_index]
    match local_info.kind {
      @semantic.ParameterLocal => {
        if parameter >= function_.parameters.length {
          return facts
        }
        let value = if host_callable {
          None
        } else {
          starshine_fact_local_value(module_, local_info)
        }
        let uses = if used[parameter] {
          @representation.ParameterUseMask::all_known()
        } else {
          @representation.ParameterUseMask::empty()
        }
        let escape = if !used[parameter] &&
          local_info.shape is @semantic.RefPlannedValueShape {
          summary.parameter_no_escape_proofs += 1
          Some(@representation.EscapeSinkMask::empty())
        } else if local_info.shape is @semantic.RefPlannedValueShape {
          Some(@representation.EscapeSinkMask::all_known())
        } else {
          None
        }
        facts.push(
          @representation.ParameterFacts::new(
            parameter.reinterpret_as_uint(),
            value~,
            uses=Some(uses),
            escape_sinks=escape,
          ),
        )
        summary.parameter_facts += 1
        match value {
          Some({ integer: Some(integer), .. }) => {
            if integer.unsigned_range is Some(_) ||
              integer.signed_range is Some(_) {
              summary.integer_range_facts += 1
            }
            if integer.known_bits is Some(_) {
              summary.known_bit_facts += 1
            }
          }
          _ => ()
        }
        parameter += 1
      }
      _ => ()
    }
  }
  facts
}

///|
fn starshine_fact_function_results(
  lowering : @semantic.PlannedProgramLowering,
  function_ : @semantic.PlannedProgramWasmFunction,
  summary : StarshineCompilerFactSummary,
) -> Array[@representation.ResultFacts] {
  if function_.results.length != 1 {
    return []
  }
  let module_ = lowering.modules[function_.module_index]
  let value = match module_.functions.callable_of(function_.declaration) {
    Some(callable) =>
      starshine_fact_resolved_value(module_, callable.result_type)
    None =>
      match starshine_fact_body_for_function(lowering, function_) {
        Some(body) if body.root_type >= 0 &&
          body.root_type < module_.types.length() =>
          match module_.types[body.root_type] {
            @semantic.BodyResolvedType(type_) =>
              starshine_fact_resolved_value(module_, type_)
            _ => None
          }
        _ => None
      }
  }
  match value {
    Some(value) => {
      summary.result_facts += 1
      match value.integer {
        Some(integer) => {
          if integer.unsigned_range is Some(_) ||
            integer.signed_range is Some(_) {
            summary.integer_range_facts += 1
          }
          if integer.known_bits is Some(_) {
            summary.known_bit_facts += 1
          }
        }
        None => ()
      }
      [@representation.ResultFacts::new(0U, value=Some(value))]
    }
    None => []
  }
}

///|
fn starshine_fact_all_effects() -> @representation.EffectMask {
  @representation.EffectMask::from_bits(0x7F_FFFFUL)
}

///|
fn starshine_fact_instruction_effect(
  instruction : @lib.Instruction,
) -> @representation.EffectMask {
  let empty = @representation.EffectMask::empty()
  match instruction {
    @lib.Unreachable => @representation.EffectMask::may_trap()
    @lib.Loop(_, _) => @representation.EffectMask::may_diverge()
    @lib.Throw(_) | @lib.ThrowRef | @lib.Rethrow(_) =>
      @representation.EffectMask::may_throw()
    @lib.Call(_) | @lib.ReturnCall(_) => empty
    @lib.CallIndirect(_, _)
    | @lib.ReturnCallIndirect(_, _)
    | @lib.CallRef(_)
    | @lib.ReturnCallRef(_) => starshine_fact_all_effects()
    @lib.GlobalGet(_) => @representation.EffectMask::may_read_global()
    @lib.GlobalSet(_) => @representation.EffectMask::may_write_global()
    @lib.TableGet(_) =>
      @representation.EffectMask::may_read_table().union(
        @representation.EffectMask::may_trap(),
      )
    @lib.TableSet(_) =>
      @representation.EffectMask::may_write_table().union(
        @representation.EffectMask::may_trap(),
      )
    @lib.TableGrow(_) => @representation.EffectMask::may_grow_table()
    @lib.TableSize(_) => @representation.EffectMask::may_read_table()
    @lib.TableFill(_) | @lib.TableCopy(_, _) | @lib.TableInit(_, _) =>
      @representation.EffectMask::may_write_table().union(
        @representation.EffectMask::may_trap(),
      )
    @lib.I32Load(_)
    | @lib.I64Load(_)
    | @lib.F32Load(_)
    | @lib.F64Load(_)
    | @lib.I32Load8S(_)
    | @lib.I32Load8U(_)
    | @lib.I32Load16S(_)
    | @lib.I32Load16U(_)
    | @lib.I64Load8S(_)
    | @lib.I64Load8U(_)
    | @lib.I64Load16S(_)
    | @lib.I64Load16U(_)
    | @lib.I64Load32S(_)
    | @lib.I64Load32U(_)
    | @lib.V128Load(_)
    | @lib.V128Load8x8S(_)
    | @lib.V128Load8x8U(_)
    | @lib.V128Load16x4S(_)
    | @lib.V128Load16x4U(_)
    | @lib.V128Load32x2S(_)
    | @lib.V128Load32x2U(_)
    | @lib.V128Load8Splat(_)
    | @lib.V128Load16Splat(_)
    | @lib.V128Load32Splat(_)
    | @lib.V128Load64Splat(_)
    | @lib.V128Load32Zero(_)
    | @lib.V128Load64Zero(_) =>
      @representation.EffectMask::may_read_memory().union(
        @representation.EffectMask::may_trap(),
      )
    @lib.I32Store(_)
    | @lib.I64Store(_)
    | @lib.F32Store(_)
    | @lib.F64Store(_)
    | @lib.I32Store8(_)
    | @lib.I32Store16(_)
    | @lib.I64Store8(_)
    | @lib.I64Store16(_)
    | @lib.I64Store32(_)
    | @lib.V128Store(_)
    | @lib.MemoryFill(_)
    | @lib.MemoryCopy(_, _)
    | @lib.MemoryInit(_, _) =>
      @representation.EffectMask::may_write_memory().union(
        @representation.EffectMask::may_trap(),
      )
    @lib.MemorySize(_) => @representation.EffectMask::may_read_memory()
    @lib.MemoryGrow(_) => @representation.EffectMask::may_grow_memory()
    @lib.StructNew(_)
    | @lib.StructNewDefault(_)
    | @lib.StructNewDesc(_)
    | @lib.StructNewDefaultDesc(_)
    | @lib.ArrayNew(_)
    | @lib.ArrayNewDefault(_)
    | @lib.ArrayNewFixed(_, _)
    | @lib.ArrayNewData(_, _)
    | @lib.ArrayNewElem(_, _)
    | @lib.ContNew(_)
    | @lib.RefI31 => @representation.EffectMask::may_allocate_gc()
    @lib.StructGet(_, _)
    | @lib.StructGetS(_, _)
    | @lib.StructGetU(_, _)
    | @lib.ArrayGet(_)
    | @lib.ArrayGetS(_)
    | @lib.ArrayGetU(_)
    | @lib.ArrayLoad(_, _, _)
    | @lib.ArrayLen
    | @lib.I31GetS
    | @lib.I31GetU =>
      @representation.EffectMask::may_read_gc_heap().union(
        @representation.EffectMask::may_trap(),
      )
    @lib.StructSet(_, _)
    | @lib.ArraySet(_)
    | @lib.ArrayStore(_, _, _)
    | @lib.ArrayFill(_)
    | @lib.ArrayCopy(_, _)
    | @lib.ArrayInitData(_, _)
    | @lib.ArrayInitElem(_, _) =>
      @representation.EffectMask::may_write_gc_heap().union(
        @representation.EffectMask::may_trap(),
      )
    @lib.RefEq => @representation.EffectMask::may_observe_reference_identity()
    @lib.RefAsNonNull
    | @lib.RefCast(_, _, _)
    | @lib.RefCastDescEq(_, _, _)
    | @lib.I32DivS
    | @lib.I32DivU
    | @lib.I32RemS
    | @lib.I32RemU
    | @lib.I64DivS
    | @lib.I64DivU
    | @lib.I64RemS
    | @lib.I64RemU
    | @lib.I32TruncF32S
    | @lib.I32TruncF32U
    | @lib.I32TruncF64S
    | @lib.I32TruncF64U
    | @lib.I64TruncF32S
    | @lib.I64TruncF32U
    | @lib.I64TruncF64S
    | @lib.I64TruncF64U => @representation.EffectMask::may_trap()
    @lib.MemoryAtomicNotify(_)
    | @lib.MemoryAtomicWait32(_)
    | @lib.MemoryAtomicWait64(_)
    | @lib.AtomicFence(_)
    | @lib.I32AtomicLoad(_, _)
    | @lib.I64AtomicLoad(_, _)
    | @lib.I32AtomicStore(_, _)
    | @lib.I64AtomicStore(_, _)
    | @lib.AtomicRmw(_, _, _)
    | @lib.AtomicCmpxchg(_, _, _) =>
      @representation.EffectMask::may_synchronize()
      .union(@representation.EffectMask::may_wait_or_notify())
      .union(@representation.EffectMask::may_read_memory())
      .union(@representation.EffectMask::may_write_memory())
      .union(@representation.EffectMask::may_trap())
    @lib.LocalSet(_) | @lib.LocalTee(_) =>
      @representation.EffectMask::local_state()
    @lib.Nop
    | @lib.Block(_, _)
    | @lib.If(_, _, _)
    | @lib.Br(_)
    | @lib.BrIf(_)
    | @lib.BrTable(_, _)
    | @lib.Return
    | @lib.Drop
    | @lib.Select(_)
    | @lib.LocalGet(_)
    | @lib.I32Const(_)
    | @lib.I64Const(_)
    | @lib.F32Const(_)
    | @lib.F64Const(_)
    | @lib.I32Eqz
    | @lib.I32Eq
    | @lib.I32Ne
    | @lib.I32LtS
    | @lib.I32LtU
    | @lib.I32GtS
    | @lib.I32GtU
    | @lib.I32LeS
    | @lib.I32LeU
    | @lib.I32GeS
    | @lib.I32GeU
    | @lib.I64Eqz
    | @lib.I64Eq
    | @lib.I64Ne
    | @lib.I64LtS
    | @lib.I64LtU
    | @lib.I64GtS
    | @lib.I64GtU
    | @lib.I64LeS
    | @lib.I64LeU
    | @lib.I64GeS
    | @lib.I64GeU
    | @lib.I32Add
    | @lib.I32Sub
    | @lib.I32Mul
    | @lib.I32And
    | @lib.I32Or
    | @lib.I32Xor
    | @lib.I32Shl
    | @lib.I32ShrS
    | @lib.I32ShrU
    | @lib.I32Rotl
    | @lib.I32Rotr
    | @lib.I64Add
    | @lib.I64Sub
    | @lib.I64Mul
    | @lib.I64And
    | @lib.I64Or
    | @lib.I64Xor
    | @lib.I64Shl
    | @lib.I64ShrS
    | @lib.I64ShrU
    | @lib.I64Rotl
    | @lib.I64Rotr
    | @lib.I32WrapI64
    | @lib.I64ExtendI32S
    | @lib.I64ExtendI32U
    | @lib.I32Extend8S
    | @lib.I32Extend16S
    | @lib.I64Extend8S
    | @lib.I64Extend16S
    | @lib.I64Extend32S
    | @lib.RefNull(_)
    | @lib.RefIsNull
    | @lib.RefFunc(_)
    | @lib.RefTest(_, _, _)
    | @lib.AnyConvertExtern
    | @lib.ExternConvertAny => empty
    _ => starshine_fact_all_effects()
  }
}

///|
fn starshine_fact_allocation_kind(
  planned : @semantic.PlannedProgramWasmGCLink,
  type_ : UInt,
  array : Bool,
) -> @representation.AllocationKind {
  if array {
    return @representation.AllocationKind::array(type_)
  }
  for physical in planned.program_physical_types {
    let module_ = planned.modules[physical.module_index]
    let value = module_.physical_types[physical.fragment_index]
    if planned.physical_type_index(physical.module_index, value.type_index) ==
      type_.reinterpret_as_int() {
      return match value.kind {
        @semantic.PlannedWasmClosureType
        | @semantic.PlannedWasmLambdaClosureType(_) =>
          @representation.AllocationKind::closure(type_)
        @semantic.PlannedWasmCaptureCellType(_) =>
          @representation.AllocationKind::box(type_)
        @semantic.PlannedWasmStructType(_)
        | @semantic.PlannedWasmEnumBaseType(_)
        | @semantic.PlannedWasmEnumSubtypeType(_, _, _)
        | @semantic.PlannedWasmTraitVTableType(_)
        | @semantic.PlannedWasmTraitObjectType(_) =>
          @representation.AllocationKind::struct_(type_)
        _ => @representation.AllocationKind::other_gc(type_)
      }
    }
  }
  @representation.AllocationKind::other_gc(type_)
}

///|
priv struct StarshineFactBodyScan {
  effects : @representation.EffectMask
  direct_callees : Array[UInt]
  body : @representation.FunctionBodyFacts?
}

///|
fn starshine_scan_fact_body(
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
  function : UInt,
  planned_function : @semantic.PlannedProgramWasmFunction?,
  sites : Array[(UInt, @lib.Instruction)],
  singleton_targets : Map[UInt, UInt],
  alias_parameter_by_function : Map[UInt, UInt],
  function_signature_by_index : Map[UInt, UInt],
  summary : StarshineCompilerFactSummary,
) -> StarshineFactBodyScan {
  let mut effects = @representation.EffectMask::empty()
  let direct_callees : Array[UInt] = []
  let expression_facts : Array[@representation.ExpressionFact] = []
  let call_facts : Array[@representation.CallSiteFacts] = []
  let allocations : Array[@representation.AllocationSiteFacts] = []
  let local_targets : Map[UInt, UInt] = Map::default()
  let provenance = starshine_fact_provenance(lowering, planned_function)
  let mut previous_target : UInt? = None
  for index, entry in sites {
    let offset = entry.0
    let instruction = entry.1
    effects = effects.union(starshine_fact_instruction_effect(instruction))
    match instruction {
      @lib.Call(@lib.FuncIdx(target)) | @lib.ReturnCall(@lib.FuncIdx(target)) =>
        direct_callees.push(target)
      _ => ()
    }
    let current_target = match instruction {
      @lib.GlobalGet(@lib.GlobalIdx(global)) => singleton_targets.get(global)
      @lib.LocalGet(@lib.LocalIdx(local_index)) =>
        local_targets.get(local_index)
      @lib.RefFunc(@lib.FuncIdx(target)) => Some(target)
      @lib.RefCast(_, _, _) | @lib.StructGet(_, @lib.U32(0U)) => previous_target
      @lib.StructNew(_) => previous_target
      @lib.Call(@lib.FuncIdx(target)) =>
        match alias_parameter_by_function.get(target) {
          Some(0U) => previous_target
          _ => None
        }
      @lib.LocalSet(@lib.LocalIdx(local_index)) => {
        match previous_target {
          Some(target) => local_targets[local_index] = target
          None => local_targets.remove(local_index)
        }
        None
      }
      @lib.LocalTee(@lib.LocalIdx(local_index)) => {
        match previous_target {
          Some(target) => local_targets[local_index] = target
          None => local_targets.remove(local_index)
        }
        previous_target
      }
      _ => None
    }
    let exact_target = match instruction {
      @lib.CallRef(type_) | @lib.ReturnCallRef(type_) =>
        match (previous_target, starshine_fact_type_index(type_)) {
          (Some(target), Some(signature)) =>
            match function_signature_by_index.get(target) {
              Some(target_signature) if target_signature == signature =>
                Some(target)
              _ => None
            }
          _ => None
        }
      _ => None
    }
    match exact_target {
      Some(target) => {
        let call_site = @representation.CodeSite::new(function, offset)
        call_facts.push(
          @representation.CallSiteFacts::new(
            call_site,
            direct_target=Some(target),
            provenance~,
          ),
        )
        summary.callsite_facts += 1
        summary.exact_call_targets += 1
        if provenance is Some(_) {
          summary.provenance_bearing_site_facts += 1
        }
        if index > 0 {
          let producer = @representation.CodeSite::new(
            function,
            sites[index - 1].0,
          )
          expression_facts.push(
            @representation.ExpressionFact::new(
              @representation.ValueSite::new(producer),
              @representation.ValueFacts::exact_ref_func(target),
              provenance~,
            ),
          )
          summary.expression_facts += 1
          summary.reference_nonnull_facts += 1
          summary.closed_function_target_sets += 1
          if provenance is Some(_) {
            summary.provenance_bearing_site_facts += 1
          }
        }
      }
      None => ()
    }
    let allocation = match instruction {
      @lib.StructNew(type_)
      | @lib.StructNewDefault(type_)
      | @lib.StructNewDesc(type_)
      | @lib.StructNewDefaultDesc(type_) =>
        match starshine_fact_type_index(type_) {
          Some(type_) => Some((type_, false, None))
          None => None
        }
      @lib.ArrayNew(type_)
      | @lib.ArrayNewDefault(type_)
      | @lib.ArrayNewData(type_, _)
      | @lib.ArrayNewElem(type_, _) =>
        match starshine_fact_type_index(type_) {
          Some(type_) => Some((type_, true, None))
          None => None
        }
      @lib.ArrayNewFixed(type_, @lib.U32(length)) =>
        match starshine_fact_type_index(type_) {
          Some(type_) => Some((type_, true, Some(length)))
          None => None
        }
      _ => None
    }
    match allocation {
      Some((type_, array, length)) => {
        let site = @representation.ValueSite::new(
          @representation.CodeSite::new(function, offset),
        )
        let length_facts = match length {
          Some(value) =>
            Some(
              @representation.IntegerFacts::new(
                @representation.IntWidth::i32(),
                unsigned_range=Some(
                  @representation.UnsignedRange::new(
                    value.to_uint64(),
                    value.to_uint64(),
                  ),
                ),
              ),
            )
          None => None
        }
        allocations.push(
          @representation.AllocationSiteFacts::new(
            site,
            @representation.AllocationFacts::new(
              starshine_fact_allocation_kind(planned, type_, array),
              length=length_facts,
            ),
            provenance~,
          ),
        )
        expression_facts.push(
          @representation.ExpressionFact::new(
            site,
            @representation.ValueFacts::nonnull_exact_ref(
              @representation.FactHeapType::type_index(type_),
            ),
            provenance~,
          ),
        )
        summary.allocation_facts += 1
        summary.expression_facts += 1
        summary.reference_nonnull_facts += 1
        summary.exact_heap_types += 1
        if length is Some(_) {
          summary.integer_range_facts += 1
        }
        if provenance is Some(_) {
          summary.provenance_bearing_site_facts += 2
        }
      }
      None => ()
    }
    match instruction {
      @lib.F32Const(@lib.F32(value)) => {
        let bits = value.reinterpret_as_uint()
        expression_facts.push(
          @representation.ExpressionFact::new(
            @representation.ValueSite::new(
              @representation.CodeSite::new(function, offset),
            ),
            @representation.ValueFacts::new(
              possible_values=Some(
                @representation.ClosedValueSet::new([
                  @representation.FactValue::f32_bits(bits),
                ]),
              ),
              float_=Some(
                @representation.FloatFacts::new(
                  @representation.FloatWidth::f32(),
                  starshine_fact_f32_class(bits),
                ),
              ),
            ),
            provenance~,
          ),
        )
        summary.expression_facts += 1
        summary.float_facts += 1
        if provenance is Some(_) {
          summary.provenance_bearing_site_facts += 1
        }
      }
      @lib.F64Const(@lib.F64(value)) => {
        let bits = value.reinterpret_as_uint64()
        expression_facts.push(
          @representation.ExpressionFact::new(
            @representation.ValueSite::new(
              @representation.CodeSite::new(function, offset),
            ),
            @representation.ValueFacts::new(
              possible_values=Some(
                @representation.ClosedValueSet::new([
                  @representation.FactValue::f64_bits(bits),
                ]),
              ),
              float_=Some(
                @representation.FloatFacts::new(
                  @representation.FloatWidth::f64(),
                  starshine_fact_f64_class(bits),
                ),
              ),
            ),
            provenance~,
          ),
        )
        summary.expression_facts += 1
        summary.float_facts += 1
        if provenance is Some(_) {
          summary.provenance_bearing_site_facts += 1
        }
      }
      @lib.RefFunc(@lib.FuncIdx(target)) => {
        expression_facts.push(
          @representation.ExpressionFact::new(
            @representation.ValueSite::new(
              @representation.CodeSite::new(function, offset),
            ),
            @representation.ValueFacts::exact_ref_func(target),
            provenance~,
          ),
        )
        summary.expression_facts += 1
        summary.reference_nonnull_facts += 1
        summary.closed_function_target_sets += 1
        if provenance is Some(_) {
          summary.provenance_bearing_site_facts += 1
        }
      }
      @lib.RefNull(ref_type) =>
        match starshine_fact_heap_type(ref_type.get_heap_type()) {
          Some(heap) => {
            expression_facts.push(
              @representation.ExpressionFact::new(
                @representation.ValueSite::new(
                  @representation.CodeSite::new(function, offset),
                ),
                @representation.ValueFacts::new(
                  possible_values=Some(
                    @representation.ClosedValueSet::new([
                      @representation.FactValue::ref_null(heap),
                    ]),
                  ),
                  reference=Some(
                    @representation.ReferenceFacts::new(
                      nullability=Some(
                        @representation.NullabilityFacts::null_only(),
                      ),
                    ),
                  ),
                ),
                provenance~,
              ),
            )
            summary.expression_facts += 1
            if provenance is Some(_) {
              summary.provenance_bearing_site_facts += 1
            }
          }
          None => ()
        }
      _ => ()
    }
    previous_target = current_target
  }
  let body = if expression_facts.is_empty() &&
    call_facts.is_empty() &&
    allocations.is_empty() {
    None
  } else {
    Some(
      @representation.FunctionBodyFacts::new(
        function,
        sites=expression_facts,
        calls=call_facts,
        allocations~,
      ),
    )
  }
  { effects, direct_callees, body, }
}

///|
fn starshine_fact_exported_functions(module_ : @lib.Module) -> Map[UInt, Bool] {
  let out : Map[UInt, Bool] = Map::default()
  match module_.export_sec {
    Some(@lib.ExportSec(exports)) =>
      for export_entry in exports {
        match export_entry {
          @lib.Export(_, @lib.FuncExternIdx(@lib.FuncIdx(function))) =>
            out[function] = true
          _ => ()
        }
      }
    None => ()
  }
  out
}

///|
fn starshine_fact_address_taken(
  module_sites : Array[Array[(UInt, @lib.Instruction)]],
) -> Map[UInt, Bool] {
  let out : Map[UInt, Bool] = Map::default()
  for sites in module_sites {
    for entry in sites {
      match entry.1 {
        @lib.RefFunc(@lib.FuncIdx(function)) => out[function] = true
        _ => ()
      }
    }
  }
  out
}

///|
fn starshine_fact_type_records(
  planned : @semantic.PlannedProgramWasmGCLink,
  builder : @representation.OptimizationFactsBuilder,
  summary : StarshineCompilerFactSummary,
) -> Unit {
  for physical in planned.program_physical_types {
    let module_ = planned.modules[physical.module_index]
    let value = module_.physical_types[physical.fragment_index]
    let type_ = planned.physical_type_index(
      physical.module_index,
      value.type_index,
    )
    if type_ < 0 {
      continue
    }
    let fields : Array[@representation.FieldFacts] = []
    for field_index in 0..<value.fields.length {
      let field = module_.fields[value.fields.start + field_index]
      let stored = match (value.kind, field.role) {
        (
          @semantic.PlannedWasmEnumSubtypeType(_, _, tag),
          @semantic.WasmEnumTagField,
        ) =>
          Some(
            @representation.ValueFacts::exact_value(
              @representation.FactValue::integer(
                @representation.IntConstant::new(
                  @representation.IntWidth::i32(),
                  tag.reinterpret_as_uint().to_uint64(),
                ),
              ),
            ),
          )
        _ => None
      }
      let writes = if field.mutable_ {
        None
      } else {
        Some(@representation.WriteFacts::initialization_only())
      }
      let usage = if field.mutable_ {
        None
      } else {
        Some(
          @representation.FieldUsageFacts::new(
            never_written_after_initialization=true,
          ),
        )
      }
      if stored is Some(_) || writes is Some(_) || usage is Some(_) {
        fields.push(
          @representation.FieldFacts::new(
            @representation.TypeView::exact(type_.reinterpret_as_uint()),
            field.physical_index.reinterpret_as_uint(),
            stored_contents=stored,
            writes~,
            usage~,
          ),
        )
        summary.field_facts += 1
        if stored is Some(_) {
          summary.closed_field_contents += 1
        }
      }
    }
    if !fields.is_empty() {
      builder.add_type(
        @representation.TypeFacts::new(type_.reinterpret_as_uint(), fields~),
      )
      summary.type_facts += 1
    }
  }
}

///|
fn starshine_fact_global_records(
  planned : @semantic.PlannedProgramWasmGCLink,
  module_ : @lib.Module,
  builder : @representation.OptimizationFactsBuilder,
  summary : StarshineCompilerFactSummary,
) -> Unit {
  let singletons : Map[UInt, @semantic.PlannedProgramFunctionReferenceSingleton] = Map::default()
  for singleton in planned.function_reference_singletons {
    singletons[singleton.global_index.reinterpret_as_uint()] = singleton
  }
  match module_.global_sec {
    Some(@lib.GlobalSec(globals)) =>
      for global_index, global in globals {
        let @lib.Global(@lib.GlobalType(_, mutable_), @lib.Expr(initializer)) = global
        let initial = if initializer.length() == 1 {
          match initializer[0] {
            @lib.I32Const(@lib.I32(value)) =>
              Some(
                @representation.ValueFacts::exact_value(
                  @representation.FactValue::integer(
                    @representation.IntConstant::new(
                      @representation.IntWidth::i32(),
                      value.reinterpret_as_uint().to_uint64(),
                    ),
                  ),
                ),
              )
            @lib.I64Const(@lib.I64(value)) =>
              Some(
                @representation.ValueFacts::exact_value(
                  @representation.FactValue::integer(
                    @representation.IntConstant::new(
                      @representation.IntWidth::i64(),
                      value.reinterpret_as_uint64(),
                    ),
                  ),
                ),
              )
            @lib.RefFunc(@lib.FuncIdx(function)) =>
              Some(@representation.ValueFacts::exact_ref_func(function))
            @lib.RefNull(ref_type) =>
              match starshine_fact_heap_type(ref_type.get_heap_type()) {
                Some(heap) =>
                  Some(
                    @representation.ValueFacts::new(
                      possible_values=Some(
                        @representation.ClosedValueSet::new([
                          @representation.FactValue::ref_null(heap),
                        ]),
                      ),
                      reference=Some(
                        @representation.ReferenceFacts::new(
                          nullability=Some(
                            @representation.NullabilityFacts::null_only(),
                          ),
                        ),
                      ),
                    ),
                  )
                None => None
              }
            _ => None
          }
        } else {
          None
        }
        let absolute = global_index.reinterpret_as_uint()
        let steady = match singletons.get(absolute) {
          Some(singleton) => {
            let closure = planned.modules[singleton.module_index].closure_type_index
            let final_type = planned.physical_type_index(
              singleton.module_index,
              closure,
            )
            if final_type >= 0 {
              summary.steady_state_globals += 1
              summary.reference_nonnull_facts += 1
              summary.exact_heap_types += 1
              Some(
                @representation.ValueFacts::nonnull_exact_ref(
                  @representation.FactHeapType::type_index(
                    final_type.reinterpret_as_uint(),
                  ),
                ),
              )
            } else {
              None
            }
          }
          None => None
        }
        let mutation = if !mutable_ {
          Some(
            @representation.MutationFacts::new(
              @representation.MutationPhase::never(),
              sites=Some([]),
            ),
          )
        } else if singletons.contains(absolute) {
          Some(
            @representation.MutationFacts::new(
              @representation.MutationPhase::initialization_only(),
            ),
          )
        } else {
          Some(
            @representation.MutationFacts::new(
              @representation.MutationPhase::runtime(),
            ),
          )
        }
        builder.add_global(
          @representation.GlobalFacts::new(
            absolute,
            initial_value=initial,
            steady_state_value=steady,
            mutation~,
          ),
        )
        summary.global_facts += 1
      }
    None => ()
  }
}

///|
/// Attach facts only after the final module body/index layout is complete.
pub fn attach_starshine_program_compiler_facts(
  module_ : @lib.Module,
  lowering : @semantic.PlannedProgramLowering,
  planned : @semantic.PlannedProgramWasmGCLink,
) -> Result[(@lib.Module, StarshineCompilerFactSummary), String] {
  let started = @lib.trace_now_us()
  let summary = StarshineCompilerFactSummary::new()
  let sites = match @binary.compiler_fact_module_opcode_sites(module_) {
    Ok(value) => value
    Err(error) =>
      return Err("cannot resolve canonical compiler-fact sites: \{error}")
  }
  let builder = @representation.OptimizationFactsBuilder::new()
  builder.set_producer(@representation.ProducerInfo::new("dewdrop", "0.1.0"))
  let exported = starshine_fact_exported_functions(module_)
  let mut host_can_call_exports = false
  for _ in exported {
    host_can_call_exports = true
    break
  }
  builder.set_world(
    @representation.WorldFacts::closed_module(
      host_can_call_exports~,
      host_can_mutate_exported_state=false,
    ),
  )
  let singleton_targets : Map[UInt, UInt] = Map::default()
  for singleton in planned.function_reference_singletons {
    singleton_targets[singleton.global_index.reinterpret_as_uint()] = singleton.function_index.reinterpret_as_uint()
  }
  let address_taken = starshine_fact_address_taken(sites)
  let function_signature_by_index : Map[UInt, UInt] = Map::default()
  for function_ in planned.functions {
    if function_.function_index >= 0 &&
      function_.signature_type_index >= 0 &&
      !function_.elided {
      function_signature_by_index[function_.function_index.reinterpret_as_uint()] = function_.signature_type_index.reinterpret_as_uint()
    }
  }
  let alias_parameter_by_function : Map[UInt, UInt] = Map::default()
  for defined, body_sites in sites {
    if body_sites.length() == 1 {
      match body_sites[0].1 {
        @lib.LocalGet(@lib.LocalIdx(parameter)) =>
          alias_parameter_by_function[(planned.imported_function_count + defined).reinterpret_as_uint()] = parameter
        _ => ()
      }
    }
  }
  let total_functions = planned.imported_function_count + sites.length()
  let planned_functions : Array[@semantic.PlannedProgramWasmFunction?] = Array::make(
    total_functions,
    None,
  )
  for value in planned.functions {
    if !value.elided && value.function_index >= 0 {
      let index = value.function_index
      guard index >= 0 && index < total_functions else {
        abort(
          "compiler facts: planned function index out of range: \{index}/\{total_functions}",
        )
      }
      guard planned_functions[index] is None else {
        abort("compiler facts: duplicate planned function index \{index}")
      }
      planned_functions[index] = Some(value)
    }
  }
  let scans : Array[StarshineFactBodyScan?] = Array::make(total_functions, None)
  for defined in 0..<sites.length() {
    let absolute = planned.imported_function_count + defined
    let scan = starshine_scan_fact_body(
      lowering,
      planned,
      absolute.reinterpret_as_uint(),
      planned_functions[absolute],
      sites[defined],
      singleton_targets,
      alias_parameter_by_function,
      function_signature_by_index,
      summary,
    )
    scans[absolute] = Some(scan)
    match scan.body {
      Some(body) => builder.add_body(body)
      None => ()
    }
  }
  let effects = Array::make(total_functions, starshine_fact_all_effects())
  for function in planned.imported_function_count..<total_functions {
    match scans[function] {
      Some(scan) => effects[function] = scan.effects
      None => ()
    }
  }
  let callees : Array[Array[UInt]] = []
  for scan in scans {
    callees.push(
      match scan {
        Some(scan) => scan.direct_callees
        None => []
      },
    )
  }
  starshine_propagate_fact_effects(effects, callees)
  for function in 0..<total_functions {
    let direct = match scans[function] {
      Some(scan) =>
        Some(@representation.ClosedFunctionSet::new(scan.direct_callees))
      None => None
    }
    let host_callable = exported.contains(function.reinterpret_as_uint())
    let taken = address_taken.contains(function.reinterpret_as_uint())
    let mut parameters : Array[@representation.ParameterFacts] = []
    let mut results : Array[@representation.ResultFacts] = []
    match planned_functions[function] {
      Some(planned_function) => {
        parameters = starshine_fact_function_parameters(
          lowering,
          planned_function,
          host_callable,
          if function >= planned.imported_function_count {
            Some(sites[function - planned.imported_function_count])
          } else {
            None
          },
          summary,
        )
        results = starshine_fact_function_results(
          lowering, planned_function, summary,
        )
      }
      None => ()
    }
    builder.add_function(
      @representation.FunctionFacts::new(
        function.reinterpret_as_uint(),
        effects=Some(
          @representation.EffectFacts::new(
            effects[function],
            direct_callees=direct,
          ),
        ),
        parameters~,
        results~,
        boundary=Some(
          @representation.FunctionBoundaryFacts::new(
            !host_callable && !taken,
            taken,
            host_callable,
          ),
        ),
      ),
    )
    summary.functions_with_facts += 1
    summary.function_effect_summaries += 1
  }
  let signatures : Map[Int, Array[@semantic.PlannedProgramWasmFunction]] = Map::default()
  for function_ in planned.functions {
    if function_.function_index >= 0 &&
      !function_.elided &&
      function_.signature_type_index >= 0 {
      let values = signatures.get(function_.signature_type_index).unwrap_or([])
      values.push(function_)
      signatures[function_.signature_type_index] = values
    }
  }
  for signature, functions in signatures {
    if functions.length() == 1 {
      let function_ = functions[0]
      let params = starshine_fact_function_parameters(
        lowering,
        function_,
        exported.contains(function_.function_index.reinterpret_as_uint()),
        None,
        StarshineCompilerFactSummary::new(),
      )
      let indexed_parameters : Array[@representation.IndexedValueFacts] = []
      for parameter in params {
        match parameter.value {
          Some(value) =>
            indexed_parameters.push(
              @representation.IndexedValueFacts::new(parameter.parameter, value),
            )
          None => ()
        }
      }
      let indexed_results : Array[@representation.IndexedValueFacts] = []
      for
        result in starshine_fact_function_results(
          lowering,
          function_,
          StarshineCompilerFactSummary::new(),
        ) {
        match result.value {
          Some(value) =>
            indexed_results.push(
              @representation.IndexedValueFacts::new(result.result, value),
            )
          None => ()
        }
      }
      if !indexed_parameters.is_empty() || !indexed_results.is_empty() {
        builder.add_signature(
          @representation.SignatureFacts::new(
            signature.reinterpret_as_uint(),
            parameters=indexed_parameters,
            results=indexed_results,
            call_sites_complete=false,
          ),
        )
        summary.signature_facts += 1
      }
    }
  }
  starshine_fact_type_records(planned, builder, summary)
  starshine_fact_global_records(planned, module_, builder, summary)
  let section = @representation.CompilerFactCustomSection::new(builder.finish())
  summary.generation_time_us = @lib.trace_elapsed_us_since(started)
  Ok((module_.with_compiler_fact_custom_section(section), summary))
}

///|
/// Encoded metadata-size measurement for tests and debug tooling.
pub struct StarshineCompilerFactSize {
  core_wasm_bytes : Int
  fact_bearing_wasm_bytes : Int
  compiler_facts_bytes : Int
  overhead_basis_points : Int
} derive(Eq, Debug)

///|
pub fn measure_starshine_compiler_fact_size(
  module_ : @lib.Module,
) -> Result[StarshineCompilerFactSize, @binary.EncodeError] {
  let fact_bearing = match @binary.encode_module(module_) {
    Ok(bytes) => bytes.length()
    Err(error) => return Err(error)
  }
  let core = match
    @binary.encode_module(module_.without_compiler_fact_custom_section()) {
    Ok(bytes) => bytes.length()
    Err(error) => return Err(error)
  }
  let payload = fact_bearing - core
  Ok({
    core_wasm_bytes: core,
    fact_bearing_wasm_bytes: fact_bearing,
    compiler_facts_bytes: payload,
    overhead_basis_points: if core == 0 {
      0
    } else {
      payload * 10000 / core
    },
  })
}

///|
/// Propagate each new effect bit only to callers that depend on it.
fn starshine_propagate_fact_effects(
  effects : Array[@representation.EffectMask],
  callees : Array[Array[UInt]],
) -> Unit {
  guard effects.length() == callees.length() else {
    abort("compiler facts: effect and call graph lengths differ")
  }
  let callers : Array[Array[Int]] = []
  let pending : Array[Int] = []
  let queued = Array::make(effects.length(), true)
  for function in 0..<effects.length() {
    callers.push([])
    pending.push(function)
  }
  for function, targets in callees {
    for target in targets {
      let callee = target.reinterpret_as_int()
      if callee >= 0 && callee < effects.length() {
        callers[callee].push(function)
      } else {
        effects[function] = starshine_fact_all_effects()
      }
    }
  }
  while pending.length() > 0 {
    let callee = pending.pop().unwrap()
    queued[callee] = false
    for caller in callers[callee] {
      let next = effects[caller].union(effects[callee])
      if next != effects[caller] {
        effects[caller] = next
        if !queued[caller] {
          queued[caller] = true
          pending.push(caller)
        }
      }
    }
  }
}
