///|
fn core_remap_instruction(
  map : CoreWasmIndexMap,
  value : @lib.Instruction,
) -> @lib.Instruction {
  match value {
    @lib.AnyConvertExtern => value
    @lib.ArrayAtomicCmpxchg(v0, v1) =>
      @lib.Instruction::array_atomic_cmpxchg(
        core_remap_type_idx(map, v1),
        order=v0,
      )
    @lib.ArrayAtomicGet(v0, v1) =>
      @lib.Instruction::array_atomic_get(v0, core_remap_type_idx(map, v1))
    @lib.ArrayAtomicGetS(v0, v1) =>
      @lib.Instruction::array_atomic_get_s(v0, core_remap_type_idx(map, v1))
    @lib.ArrayAtomicGetU(v0, v1) =>
      @lib.Instruction::array_atomic_get_u(v0, core_remap_type_idx(map, v1))
    @lib.ArrayAtomicRmw(v0, v1, v2) =>
      @lib.Instruction::array_atomic_rmw(
        v1,
        core_remap_type_idx(map, v2),
        order=v0,
      )
    @lib.ArrayCopy(v0, v1) =>
      @lib.Instruction::array_copy(
        core_remap_type_idx(map, v0),
        core_remap_type_idx(map, v1),
      )
    @lib.ArrayFill(v0) =>
      @lib.Instruction::array_fill(core_remap_type_idx(map, v0))
    @lib.ArrayGet(v0) =>
      @lib.Instruction::array_get(core_remap_type_idx(map, v0))
    @lib.ArrayGetS(v0) =>
      @lib.Instruction::array_get_s(core_remap_type_idx(map, v0))
    @lib.ArrayGetU(v0) =>
      @lib.Instruction::array_get_u(core_remap_type_idx(map, v0))
    @lib.ArrayInitData(v0, v1) =>
      @lib.Instruction::array_init_data(
        core_remap_type_idx(map, v0),
        core_remap_data_idx(map, v1),
      )
    @lib.ArrayInitElem(v0, v1) =>
      @lib.Instruction::array_init_elem(
        core_remap_type_idx(map, v0),
        core_remap_elem_idx(map, v1),
      )
    @lib.ArrayLen => value
    @lib.ArrayLoad(v0, v1) =>
      @lib.Instruction::array_load(v0, core_remap_type_idx(map, v1))
    @lib.ArrayNew(v0) =>
      @lib.Instruction::array_new(core_remap_type_idx(map, v0))
    @lib.ArrayNewData(v0, v1) =>
      @lib.Instruction::array_new_data(
        core_remap_type_idx(map, v0),
        core_remap_data_idx(map, v1),
      )
    @lib.ArrayNewDefault(v0) =>
      @lib.Instruction::array_new_default(core_remap_type_idx(map, v0))
    @lib.ArrayNewElem(v0, v1) =>
      @lib.Instruction::array_new_elem(
        core_remap_type_idx(map, v0),
        core_remap_elem_idx(map, v1),
      )
    @lib.ArrayNewFixed(v0, v1) =>
      @lib.Instruction::array_new_fixed(core_remap_type_idx(map, v0), v1)
    @lib.ArraySet(v0) =>
      @lib.Instruction::array_set(core_remap_type_idx(map, v0))
    @lib.ArrayStore(v0, v1) =>
      @lib.Instruction::array_store(v0, core_remap_type_idx(map, v1))
    @lib.AtomicCmpxchg(v0, v1, v2) =>
      @lib.Instruction::atomic_cmpxchg(
        v1,
        core_remap_mem_arg(map, v2),
        order=v0,
      )
    @lib.AtomicFence(_) => value
    @lib.AtomicRmw(v0, v1, v2) =>
      @lib.Instruction::atomic_rmw(v1, core_remap_mem_arg(map, v2), order=v0)
    @lib.Block(v0, v1) =>
      @lib.Instruction::block(
        core_remap_block_type(map, v0),
        core_remap_expr(map, v1),
      )
    @lib.Br(_) => value
    @lib.BrIf(_) => value
    @lib.BrOnCast(v0, v1, v2, v3) =>
      @lib.Instruction::br_on_cast(
        v0,
        v1.source_nullable(),
        core_remap_heap_type(map, v2),
        v1.target_nullable(),
        core_remap_heap_type(map, v3),
        source_exact=v1.source_exact(),
        target_exact=v1.target_exact(),
      )
    @lib.BrOnCastDescEq(v0, v1, v2) =>
      @lib.Instruction::br_on_cast_desc_eq(
        v0,
        core_remap_ref_type(map, v1),
        core_remap_ref_type(map, v2),
      )
    @lib.BrOnCastDescEqFail(v0, v1, v2) =>
      @lib.Instruction::br_on_cast_desc_eq_fail(
        v0,
        core_remap_ref_type(map, v1),
        core_remap_ref_type(map, v2),
      )
    @lib.BrOnCastFail(v0, v1, v2, v3) =>
      @lib.Instruction::br_on_cast_fail(
        v0,
        v1.source_nullable(),
        core_remap_heap_type(map, v2),
        v1.target_nullable(),
        core_remap_heap_type(map, v3),
        source_exact=v1.source_exact(),
        target_exact=v1.target_exact(),
      )
    @lib.BrOnNonNull(_) => value
    @lib.BrOnNull(_) => value
    @lib.BrTable(_, _) => value
    @lib.Call(v0) => @lib.Instruction::call(core_remap_func_idx(map, v0))
    @lib.CallIndirect(v0, v1) =>
      @lib.Instruction::call_indirect(
        core_remap_type_idx(map, v0),
        core_remap_table_idx(map, v1),
      )
    @lib.CallRef(v0) => @lib.Instruction::call_ref(core_remap_type_idx(map, v0))
    @lib.ContBind(v0, v1) =>
      @lib.Instruction::cont_bind(
        core_remap_type_idx(map, v0),
        core_remap_type_idx(map, v1),
      )
    @lib.ContNew(v0) => @lib.Instruction::cont_new(core_remap_type_idx(map, v0))
    @lib.DataDrop(v0) =>
      @lib.Instruction::data_drop(core_remap_data_idx(map, v0))
    @lib.Drop => value
    @lib.ElemDrop(v0) =>
      @lib.Instruction::elem_drop(core_remap_elem_idx(map, v0))
    @lib.ExternConvertAny => value
    @lib.F32Abs => value
    @lib.F32Add => value
    @lib.F32Ceil => value
    @lib.F32Const(_) => value
    @lib.F32ConvertI32S => value
    @lib.F32ConvertI32U => value
    @lib.F32ConvertI64S => value
    @lib.F32ConvertI64U => value
    @lib.F32Copysign => value
    @lib.F32DemoteF64 => value
    @lib.F32Div => value
    @lib.F32Eq => value
    @lib.F32Floor => value
    @lib.F32Ge => value
    @lib.F32Gt => value
    @lib.F32Le => value
    @lib.F32Load(v0) => @lib.Instruction::f32_load(core_remap_mem_arg(map, v0))
    @lib.F32Lt => value
    @lib.F32Max => value
    @lib.F32Min => value
    @lib.F32Mul => value
    @lib.F32Ne => value
    @lib.F32Nearest => value
    @lib.F32Neg => value
    @lib.F32ReinterpretI32 => value
    @lib.F32Sqrt => value
    @lib.F32Store(v0) =>
      @lib.Instruction::f32_store(core_remap_mem_arg(map, v0))
    @lib.F32Sub => value
    @lib.F32Trunc => value
    @lib.F32x4Abs => value
    @lib.F32x4Add => value
    @lib.F32x4Ceil => value
    @lib.F32x4ConvertI32x4S => value
    @lib.F32x4ConvertI32x4U => value
    @lib.F32x4DemoteF64x2Zero => value
    @lib.F32x4Div => value
    @lib.F32x4Eq => value
    @lib.F32x4ExtractLane(_) => value
    @lib.F32x4Floor => value
    @lib.F32x4Ge => value
    @lib.F32x4Gt => value
    @lib.F32x4Le => value
    @lib.F32x4Lt => value
    @lib.F32x4Max => value
    @lib.F32x4Min => value
    @lib.F32x4Mul => value
    @lib.F32x4Ne => value
    @lib.F32x4Nearest => value
    @lib.F32x4Neg => value
    @lib.F32x4Pmax => value
    @lib.F32x4Pmin => value
    @lib.F32x4RelaxedMadd => value
    @lib.F32x4RelaxedMax => value
    @lib.F32x4RelaxedMin => value
    @lib.F32x4RelaxedNmadd => value
    @lib.F32x4ReplaceLane(_) => value
    @lib.F32x4Splat => value
    @lib.F32x4Sqrt => value
    @lib.F32x4Sub => value
    @lib.F32x4Trunc => value
    @lib.F64Abs => value
    @lib.F64Add => value
    @lib.F64Ceil => value
    @lib.F64Const(_) => value
    @lib.F64ConvertI32S => value
    @lib.F64ConvertI32U => value
    @lib.F64ConvertI64S => value
    @lib.F64ConvertI64U => value
    @lib.F64Copysign => value
    @lib.F64Div => value
    @lib.F64Eq => value
    @lib.F64Floor => value
    @lib.F64Ge => value
    @lib.F64Gt => value
    @lib.F64Le => value
    @lib.F64Load(v0) => @lib.Instruction::f64_load(core_remap_mem_arg(map, v0))
    @lib.F64Lt => value
    @lib.F64Max => value
    @lib.F64Min => value
    @lib.F64Mul => value
    @lib.F64Ne => value
    @lib.F64Nearest => value
    @lib.F64Neg => value
    @lib.F64PromoteF32 => value
    @lib.F64ReinterpretI64 => value
    @lib.F64Sqrt => value
    @lib.F64Store(v0) =>
      @lib.Instruction::f64_store(core_remap_mem_arg(map, v0))
    @lib.F64Sub => value
    @lib.F64Trunc => value
    @lib.F64x2Abs => value
    @lib.F64x2Add => value
    @lib.F64x2Ceil => value
    @lib.F64x2ConvertLowI32x4S => value
    @lib.F64x2ConvertLowI32x4U => value
    @lib.F64x2Div => value
    @lib.F64x2Eq => value
    @lib.F64x2ExtractLane(_) => value
    @lib.F64x2Floor => value
    @lib.F64x2Ge => value
    @lib.F64x2Gt => value
    @lib.F64x2Le => value
    @lib.F64x2Lt => value
    @lib.F64x2Max => value
    @lib.F64x2Min => value
    @lib.F64x2Mul => value
    @lib.F64x2Ne => value
    @lib.F64x2Nearest => value
    @lib.F64x2Neg => value
    @lib.F64x2Pmax => value
    @lib.F64x2Pmin => value
    @lib.F64x2PromoteLowF32x4 => value
    @lib.F64x2RelaxedMadd => value
    @lib.F64x2RelaxedMax => value
    @lib.F64x2RelaxedMin => value
    @lib.F64x2RelaxedNmadd => value
    @lib.F64x2ReplaceLane(_) => value
    @lib.F64x2Splat => value
    @lib.F64x2Sqrt => value
    @lib.F64x2Sub => value
    @lib.F64x2Trunc => value
    @lib.GlobalGet(v0) =>
      @lib.Instruction::global_get(core_remap_global_idx(map, v0))
    @lib.GlobalSet(v0) =>
      @lib.Instruction::global_set(core_remap_global_idx(map, v0))
    @lib.I16x8Abs => value
    @lib.I16x8Add => value
    @lib.I16x8AddSatS => value
    @lib.I16x8AddSatU => value
    @lib.I16x8AllTrue => value
    @lib.I16x8AvgrU => value
    @lib.I16x8Bitmask => value
    @lib.I16x8Eq => value
    @lib.I16x8ExtaddPairwiseI8x16S => value
    @lib.I16x8ExtaddPairwiseI8x16U => value
    @lib.I16x8ExtendHighI8x16S => value
    @lib.I16x8ExtendHighI8x16U => value
    @lib.I16x8ExtendLowI8x16S => value
    @lib.I16x8ExtendLowI8x16U => value
    @lib.I16x8ExtmulHighI8x16S => value
    @lib.I16x8ExtmulHighI8x16U => value
    @lib.I16x8ExtmulLowI8x16S => value
    @lib.I16x8ExtmulLowI8x16U => value
    @lib.I16x8ExtractLaneS(_) => value
    @lib.I16x8ExtractLaneU(_) => value
    @lib.I16x8GeS => value
    @lib.I16x8GeU => value
    @lib.I16x8GtS => value
    @lib.I16x8GtU => value
    @lib.I16x8LeS => value
    @lib.I16x8LeU => value
    @lib.I16x8LtS => value
    @lib.I16x8LtU => value
    @lib.I16x8MaxS => value
    @lib.I16x8MaxU => value
    @lib.I16x8MinS => value
    @lib.I16x8MinU => value
    @lib.I16x8Mul => value
    @lib.I16x8NarrowI32x4S => value
    @lib.I16x8NarrowI32x4U => value
    @lib.I16x8Ne => value
    @lib.I16x8Neg => value
    @lib.I16x8Q15mulrSatS => value
    @lib.I16x8RelaxedDotI8x16I7x16S => value
    @lib.I16x8RelaxedLaneselect => value
    @lib.I16x8RelaxedQ15mulrS => value
    @lib.I16x8ReplaceLane(_) => value
    @lib.I16x8Shl => value
    @lib.I16x8ShrS => value
    @lib.I16x8ShrU => value
    @lib.I16x8Splat => value
    @lib.I16x8Sub => value
    @lib.I16x8SubSatS => value
    @lib.I16x8SubSatU => value
    @lib.I31GetS => value
    @lib.I31GetU => value
    @lib.I32Add => value
    @lib.I32And => value
    @lib.I32AtomicLoad(v0, v1) =>
      @lib.Instruction::i32_atomic_load(core_remap_mem_arg(map, v1), order=v0)
    @lib.I32AtomicLoad16U(v0, v1) =>
      @lib.Instruction::i32_atomic_load16_u(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I32AtomicLoad8U(v0, v1) =>
      @lib.Instruction::i32_atomic_load8_u(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I32AtomicStore(v0, v1) =>
      @lib.Instruction::i32_atomic_store(core_remap_mem_arg(map, v1), order=v0)
    @lib.I32AtomicStore16(v0, v1) =>
      @lib.Instruction::i32_atomic_store16(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I32AtomicStore8(v0, v1) =>
      @lib.Instruction::i32_atomic_store8(core_remap_mem_arg(map, v1), order=v0)
    @lib.I32Clz => value
    @lib.I32Const(_) => value
    @lib.I32Ctz => value
    @lib.I32DivS => value
    @lib.I32DivU => value
    @lib.I32Eq => value
    @lib.I32Eqz => value
    @lib.I32Extend16S => value
    @lib.I32Extend8S => value
    @lib.I32GeS => value
    @lib.I32GeU => value
    @lib.I32GtS => value
    @lib.I32GtU => value
    @lib.I32LeS => value
    @lib.I32LeU => value
    @lib.I32Load(v0) => @lib.Instruction::i32_load(core_remap_mem_arg(map, v0))
    @lib.I32Load16S(v0) =>
      @lib.Instruction::i32_load16s(core_remap_mem_arg(map, v0))
    @lib.I32Load16U(v0) =>
      @lib.Instruction::i32_load16u(core_remap_mem_arg(map, v0))
    @lib.I32Load8S(v0) =>
      @lib.Instruction::i32_load8s(core_remap_mem_arg(map, v0))
    @lib.I32Load8U(v0) =>
      @lib.Instruction::i32_load8u(core_remap_mem_arg(map, v0))
    @lib.I32LtS => value
    @lib.I32LtU => value
    @lib.I32Mul => value
    @lib.I32Ne => value
    @lib.I32Or => value
    @lib.I32Popcnt => value
    @lib.I32ReinterpretF32 => value
    @lib.I32RemS => value
    @lib.I32RemU => value
    @lib.I32Rotl => value
    @lib.I32Rotr => value
    @lib.I32Shl => value
    @lib.I32ShrS => value
    @lib.I32ShrU => value
    @lib.I32Store(v0) =>
      @lib.Instruction::i32_store(core_remap_mem_arg(map, v0))
    @lib.I32Store16(v0) =>
      @lib.Instruction::i32_store16(core_remap_mem_arg(map, v0))
    @lib.I32Store8(v0) =>
      @lib.Instruction::i32_store8(core_remap_mem_arg(map, v0))
    @lib.I32Sub => value
    @lib.I32TruncF32S => value
    @lib.I32TruncF32U => value
    @lib.I32TruncF64S => value
    @lib.I32TruncF64U => value
    @lib.I32TruncSatF32S => value
    @lib.I32TruncSatF32U => value
    @lib.I32TruncSatF64S => value
    @lib.I32TruncSatF64U => value
    @lib.I32WrapI64 => value
    @lib.I32Xor => value
    @lib.I32x4Abs => value
    @lib.I32x4Add => value
    @lib.I32x4AllTrue => value
    @lib.I32x4Bitmask => value
    @lib.I32x4DotI16x8S => value
    @lib.I32x4Eq => value
    @lib.I32x4ExtaddPairwiseI16x8S => value
    @lib.I32x4ExtaddPairwiseI16x8U => value
    @lib.I32x4ExtendHighI16x8S => value
    @lib.I32x4ExtendHighI16x8U => value
    @lib.I32x4ExtendLowI16x8S => value
    @lib.I32x4ExtendLowI16x8U => value
    @lib.I32x4ExtmulHighI16x8S => value
    @lib.I32x4ExtmulHighI16x8U => value
    @lib.I32x4ExtmulLowI16x8S => value
    @lib.I32x4ExtmulLowI16x8U => value
    @lib.I32x4ExtractLane(_) => value
    @lib.I32x4GeS => value
    @lib.I32x4GeU => value
    @lib.I32x4GtS => value
    @lib.I32x4GtU => value
    @lib.I32x4LeS => value
    @lib.I32x4LeU => value
    @lib.I32x4LtS => value
    @lib.I32x4LtU => value
    @lib.I32x4MaxS => value
    @lib.I32x4MaxU => value
    @lib.I32x4MinS => value
    @lib.I32x4MinU => value
    @lib.I32x4Mul => value
    @lib.I32x4Ne => value
    @lib.I32x4Neg => value
    @lib.I32x4RelaxedDotI8x16I7x16AddS => value
    @lib.I32x4RelaxedLaneselect => value
    @lib.I32x4RelaxedTruncF32x4S => value
    @lib.I32x4RelaxedTruncF32x4U => value
    @lib.I32x4RelaxedTruncZeroF64x2S => value
    @lib.I32x4RelaxedTruncZeroF64x2U => value
    @lib.I32x4ReplaceLane(_) => value
    @lib.I32x4Shl => value
    @lib.I32x4ShrS => value
    @lib.I32x4ShrU => value
    @lib.I32x4Splat => value
    @lib.I32x4Sub => value
    @lib.I32x4TruncSatF32x4S => value
    @lib.I32x4TruncSatF32x4U => value
    @lib.I32x4TruncSatF64x2SZero => value
    @lib.I32x4TruncSatF64x2UZero => value
    @lib.I64Add => value
    @lib.I64And => value
    @lib.I64AtomicLoad(v0, v1) =>
      @lib.Instruction::i64_atomic_load(core_remap_mem_arg(map, v1), order=v0)
    @lib.I64AtomicLoad16U(v0, v1) =>
      @lib.Instruction::i64_atomic_load16_u(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I64AtomicLoad32U(v0, v1) =>
      @lib.Instruction::i64_atomic_load32_u(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I64AtomicLoad8U(v0, v1) =>
      @lib.Instruction::i64_atomic_load8_u(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I64AtomicStore(v0, v1) =>
      @lib.Instruction::i64_atomic_store(core_remap_mem_arg(map, v1), order=v0)
    @lib.I64AtomicStore16(v0, v1) =>
      @lib.Instruction::i64_atomic_store16(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I64AtomicStore32(v0, v1) =>
      @lib.Instruction::i64_atomic_store32(
        core_remap_mem_arg(map, v1),
        order=v0,
      )
    @lib.I64AtomicStore8(v0, v1) =>
      @lib.Instruction::i64_atomic_store8(core_remap_mem_arg(map, v1), order=v0)
    @lib.I64Clz => value
    @lib.I64Const(_) => value
    @lib.I64Ctz => value
    @lib.I64DivS => value
    @lib.I64DivU => value
    @lib.I64Eq => value
    @lib.I64Eqz => value
    @lib.I64Extend16S => value
    @lib.I64Extend32S => value
    @lib.I64Extend8S => value
    @lib.I64ExtendI32S => value
    @lib.I64ExtendI32U => value
    @lib.I64GeS => value
    @lib.I64GeU => value
    @lib.I64GtS => value
    @lib.I64GtU => value
    @lib.I64LeS => value
    @lib.I64LeU => value
    @lib.I64Load(v0) => @lib.Instruction::i64_load(core_remap_mem_arg(map, v0))
    @lib.I64Load16S(v0) =>
      @lib.Instruction::i64_load16s(core_remap_mem_arg(map, v0))
    @lib.I64Load16U(v0) =>
      @lib.Instruction::i64_load16u(core_remap_mem_arg(map, v0))
    @lib.I64Load32S(v0) =>
      @lib.Instruction::i64_load32s(core_remap_mem_arg(map, v0))
    @lib.I64Load32U(v0) =>
      @lib.Instruction::i64_load32u(core_remap_mem_arg(map, v0))
    @lib.I64Load8S(v0) =>
      @lib.Instruction::i64_load8s(core_remap_mem_arg(map, v0))
    @lib.I64Load8U(v0) =>
      @lib.Instruction::i64_load8u(core_remap_mem_arg(map, v0))
    @lib.I64LtS => value
    @lib.I64LtU => value
    @lib.I64Mul => value
    @lib.I64Ne => value
    @lib.I64Or => value
    @lib.I64Popcnt => value
    @lib.I64ReinterpretF64 => value
    @lib.I64RemS => value
    @lib.I64RemU => value
    @lib.I64Rotl => value
    @lib.I64Rotr => value
    @lib.I64Shl => value
    @lib.I64ShrS => value
    @lib.I64ShrU => value
    @lib.I64Store(v0) =>
      @lib.Instruction::i64_store(core_remap_mem_arg(map, v0))
    @lib.I64Store16(v0) =>
      @lib.Instruction::i64_store16(core_remap_mem_arg(map, v0))
    @lib.I64Store32(v0) =>
      @lib.Instruction::i64_store32(core_remap_mem_arg(map, v0))
    @lib.I64Store8(v0) =>
      @lib.Instruction::i64_store8(core_remap_mem_arg(map, v0))
    @lib.I64Sub => value
    @lib.I64TruncF32S => value
    @lib.I64TruncF32U => value
    @lib.I64TruncF64S => value
    @lib.I64TruncF64U => value
    @lib.I64TruncSatF32S => value
    @lib.I64TruncSatF32U => value
    @lib.I64TruncSatF64S => value
    @lib.I64TruncSatF64U => value
    @lib.I64Xor => value
    @lib.I64x2Abs => value
    @lib.I64x2Add => value
    @lib.I64x2AllTrue => value
    @lib.I64x2Bitmask => value
    @lib.I64x2Eq => value
    @lib.I64x2ExtendHighI32x4S => value
    @lib.I64x2ExtendHighI32x4U => value
    @lib.I64x2ExtendLowI32x4S => value
    @lib.I64x2ExtendLowI32x4U => value
    @lib.I64x2ExtmulHighI32x4S => value
    @lib.I64x2ExtmulHighI32x4U => value
    @lib.I64x2ExtmulLowI32x4S => value
    @lib.I64x2ExtmulLowI32x4U => value
    @lib.I64x2ExtractLane(_) => value
    @lib.I64x2GeS => value
    @lib.I64x2GtS => value
    @lib.I64x2LeS => value
    @lib.I64x2LtS => value
    @lib.I64x2Mul => value
    @lib.I64x2Ne => value
    @lib.I64x2Neg => value
    @lib.I64x2RelaxedLaneselect => value
    @lib.I64x2ReplaceLane(_) => value
    @lib.I64x2Shl => value
    @lib.I64x2ShrS => value
    @lib.I64x2ShrU => value
    @lib.I64x2Splat => value
    @lib.I64x2Sub => value
    @lib.I8x16Abs => value
    @lib.I8x16Add => value
    @lib.I8x16AddSatS => value
    @lib.I8x16AddSatU => value
    @lib.I8x16AllTrue => value
    @lib.I8x16AvgrU => value
    @lib.I8x16Bitmask => value
    @lib.I8x16Eq => value
    @lib.I8x16ExtractLaneS(_) => value
    @lib.I8x16ExtractLaneU(_) => value
    @lib.I8x16GeS => value
    @lib.I8x16GeU => value
    @lib.I8x16GtS => value
    @lib.I8x16GtU => value
    @lib.I8x16LeS => value
    @lib.I8x16LeU => value
    @lib.I8x16LtS => value
    @lib.I8x16LtU => value
    @lib.I8x16MaxS => value
    @lib.I8x16MaxU => value
    @lib.I8x16MinS => value
    @lib.I8x16MinU => value
    @lib.I8x16NarrowI16x8S => value
    @lib.I8x16NarrowI16x8U => value
    @lib.I8x16Ne => value
    @lib.I8x16Neg => value
    @lib.I8x16Popcnt => value
    @lib.I8x16RelaxedLaneselect => value
    @lib.I8x16RelaxedSwizzle => value
    @lib.I8x16ReplaceLane(_) => value
    @lib.I8x16Shl => value
    @lib.I8x16ShrS => value
    @lib.I8x16ShrU => value
    @lib.I8x16Shuffle(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _) => value
    @lib.I8x16Splat => value
    @lib.I8x16Sub => value
    @lib.I8x16SubSatS => value
    @lib.I8x16SubSatU => value
    @lib.I8x16Swizzle => value
    @lib.If(v0, v1, v2) =>
      @lib.Instruction::if_(
        core_remap_block_type(map, v0),
        core_remap_instructions(map, v1),
        core_remap_optional_instructions(map, v2),
      )
    @lib.LocalGet(_) => value
    @lib.LocalSet(_) => value
    @lib.LocalTee(_) => value
    @lib.Loop(v0, v1) =>
      @lib.Instruction::loop_(
        core_remap_block_type(map, v0),
        core_remap_expr(map, v1),
      )
    @lib.MemoryAtomicNotify(v0) =>
      @lib.Instruction::memory_atomic_notify(core_remap_mem_arg(map, v0))
    @lib.MemoryAtomicWait32(v0) =>
      @lib.Instruction::memory_atomic_wait32(core_remap_mem_arg(map, v0))
    @lib.MemoryAtomicWait64(v0) =>
      @lib.Instruction::memory_atomic_wait64(core_remap_mem_arg(map, v0))
    @lib.MemoryCopy(v0, v1) =>
      @lib.Instruction::memory_copy(
        core_remap_mem_idx(map, v0),
        core_remap_mem_idx(map, v1),
      )
    @lib.MemoryFill(v0) =>
      @lib.Instruction::memory_fill(core_remap_mem_idx(map, v0))
    @lib.MemoryGrow(v0) =>
      @lib.Instruction::memory_grow(core_remap_mem_idx(map, v0))
    @lib.MemoryInit(v0, v1) =>
      @lib.Instruction::memory_init(
        core_remap_data_idx(map, v0),
        core_remap_mem_idx(map, v1),
      )
    @lib.MemorySize(v0) =>
      @lib.Instruction::memory_size(core_remap_mem_idx(map, v0))
    @lib.Nop => value
    @lib.RefAsNonNull => value
    @lib.RefCast(v0, v1, v2) =>
      @lib.Instruction::ref_cast_type(
        @lib.RefType::new(v0, core_remap_heap_type(map, v2), exact=v1),
      )
    @lib.RefCastDescEq(v0, v1, v2) =>
      @lib.Instruction::ref_cast_desc_eq_type(
        @lib.RefType::new(v0, core_remap_heap_type(map, v2), exact=v1),
      )
    @lib.RefEq => value
    @lib.RefFunc(v0) => @lib.Instruction::ref_func(core_remap_func_idx(map, v0))
    @lib.RefGetDesc(v0) =>
      @lib.Instruction::ref_get_desc(core_remap_type_idx(map, v0))
    @lib.RefI31 => value
    @lib.RefIsNull => value
    @lib.RefNull(v0) =>
      @lib.Instruction::ref_null_type(core_remap_ref_type(map, v0))
    @lib.RefTest(v0, v1, v2) =>
      @lib.Instruction::ref_test_type(
        @lib.RefType::new(v0, core_remap_heap_type(map, v2), exact=v1),
      )
    @lib.RefTestDesc(v0, v1) =>
      @lib.Instruction::ref_test_desc(v0, core_remap_heap_type(map, v1))
    @lib.Resume(v0, v1) =>
      @lib.Instruction::resume_(
        core_remap_type_idx(map, v0),
        core_remap_resume_handlers(map, v1),
      )
    @lib.ResumeThrow(v0, v1, v2) =>
      @lib.Instruction::resume_throw(
        core_remap_type_idx(map, v0),
        core_remap_tag_idx(map, v1),
        core_remap_resume_handlers(map, v2),
      )
    @lib.ResumeThrowRef(v0, v1) =>
      @lib.Instruction::resume_throw_ref(
        core_remap_type_idx(map, v0),
        core_remap_resume_handlers(map, v1),
      )
    @lib.Rethrow(_) => value
    @lib.Return => value
    @lib.ReturnCall(v0) =>
      @lib.Instruction::return_call(core_remap_func_idx(map, v0))
    @lib.ReturnCallIndirect(v0, v1) =>
      @lib.Instruction::return_call_indirect(
        core_remap_type_idx(map, v0),
        core_remap_table_idx(map, v1),
      )
    @lib.ReturnCallRef(v0) =>
      @lib.Instruction::return_call_ref(core_remap_type_idx(map, v0))
    @lib.Select(v0) =>
      @lib.Instruction::select(types=core_remap_optional_val_types(map, v0))
    @lib.StackSwitch(v0, v1) =>
      @lib.Instruction::stack_switch(
        core_remap_type_idx(map, v0),
        core_remap_tag_idx(map, v1),
      )
    @lib.StringAsWtf16 => value
    @lib.StringConcat => value
    @lib.StringConst(_) => value
    @lib.StringEncodeLossyUtf8Array => value
    @lib.StringEncodeUtf8Array => value
    @lib.StringEncodeWtf16Array => value
    @lib.StringEncodeWtf8Array => value
    @lib.StringEq => value
    @lib.StringMeasureWtf16 => value
    @lib.StringNewLossyUtf8Array => value
    @lib.StringNewUtf8Array => value
    @lib.StringNewWtf16Array => value
    @lib.StringNewWtf8Array => value
    @lib.StringViewWtf16GetCodeunit => value
    @lib.StringViewWtf16Slice => value
    @lib.StructAtomicCmpxchg(v0, v1, v2) =>
      @lib.Instruction::struct_atomic_cmpxchg(
        core_remap_type_idx(map, v1),
        v2,
        order=v0,
      )
    @lib.StructAtomicGet(v0, v1, v2) =>
      @lib.Instruction::struct_atomic_get(v0, core_remap_type_idx(map, v1), v2)
    @lib.StructAtomicGetS(v0, v1, v2) =>
      @lib.Instruction::struct_atomic_get_s(
        v0,
        core_remap_type_idx(map, v1),
        v2,
      )
    @lib.StructAtomicGetU(v0, v1, v2) =>
      @lib.Instruction::struct_atomic_get_u(
        v0,
        core_remap_type_idx(map, v1),
        v2,
      )
    @lib.StructAtomicRmw(v0, v1, v2, v3) =>
      @lib.Instruction::struct_atomic_rmw(
        v1,
        core_remap_type_idx(map, v2),
        v3,
        order=v0,
      )
    @lib.StructGet(v0, v1) =>
      @lib.Instruction::struct_get(core_remap_type_idx(map, v0), v1)
    @lib.StructGetS(v0, v1) =>
      @lib.Instruction::struct_get_s(core_remap_type_idx(map, v0), v1)
    @lib.StructGetU(v0, v1) =>
      @lib.Instruction::struct_get_u(core_remap_type_idx(map, v0), v1)
    @lib.StructNew(v0) =>
      @lib.Instruction::struct_new(core_remap_type_idx(map, v0))
    @lib.StructNewDefault(v0) =>
      @lib.Instruction::struct_new_default(core_remap_type_idx(map, v0))
    @lib.StructNewDefaultDesc(v0) =>
      @lib.Instruction::struct_new_default_desc(core_remap_type_idx(map, v0))
    @lib.StructNewDesc(v0) =>
      @lib.Instruction::struct_new_desc(core_remap_type_idx(map, v0))
    @lib.StructSet(v0, v1) =>
      @lib.Instruction::struct_set(core_remap_type_idx(map, v0), v1)
    @lib.Suspend(v0) => @lib.Instruction::suspend(core_remap_tag_idx(map, v0))
    @lib.TableCopy(v0, v1) =>
      @lib.Instruction::table_copy(
        core_remap_table_idx(map, v0),
        core_remap_table_idx(map, v1),
      )
    @lib.TableFill(v0) =>
      @lib.Instruction::table_fill(core_remap_table_idx(map, v0))
    @lib.TableGet(v0) =>
      @lib.Instruction::table_get(core_remap_table_idx(map, v0))
    @lib.TableGrow(v0) =>
      @lib.Instruction::table_grow(core_remap_table_idx(map, v0))
    @lib.TableInit(v0, v1) =>
      @lib.Instruction::table_init(
        core_remap_elem_idx(map, v0),
        core_remap_table_idx(map, v1),
      )
    @lib.TableSet(v0) =>
      @lib.Instruction::table_set(core_remap_table_idx(map, v0))
    @lib.TableSize(v0) =>
      @lib.Instruction::table_size(core_remap_table_idx(map, v0))
    @lib.Throw(v0) => @lib.Instruction::throw_(core_remap_tag_idx(map, v0))
    @lib.ThrowRef => value
    @lib.Try(v0, v1, v2, v3) =>
      @lib.Instruction::try_(
        core_remap_block_type(map, v0),
        core_remap_expr(map, v1),
        core_remap_legacy_catches(map, v2),
        delegate=v3,
      )
    @lib.TryTable(v0, v1, v2) =>
      @lib.Instruction::try_table(
        core_remap_block_type(map, v0),
        core_remap_catches(map, v1),
        core_remap_expr(map, v2),
      )
    @lib.Unreachable => value
    @lib.V128And => value
    @lib.V128Andnot => value
    @lib.V128AnyTrue => value
    @lib.V128Bitselect => value
    @lib.V128Const(_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _) => value
    @lib.V128Load(v0) =>
      @lib.Instruction::v128_load(core_remap_mem_arg(map, v0))
    @lib.V128Load16Lane(v0, v1) =>
      @lib.Instruction::v128_load16_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Load16Splat(v0) =>
      @lib.Instruction::v128_load16_splat(core_remap_mem_arg(map, v0))
    @lib.V128Load16x4S(v0) =>
      @lib.Instruction::v128_load16x4s(core_remap_mem_arg(map, v0))
    @lib.V128Load16x4U(v0) =>
      @lib.Instruction::v128_load16x4u(core_remap_mem_arg(map, v0))
    @lib.V128Load32Lane(v0, v1) =>
      @lib.Instruction::v128_load32_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Load32Splat(v0) =>
      @lib.Instruction::v128_load32_splat(core_remap_mem_arg(map, v0))
    @lib.V128Load32Zero(v0) =>
      @lib.Instruction::v128_load32_zero(core_remap_mem_arg(map, v0))
    @lib.V128Load32x2S(v0) =>
      @lib.Instruction::v128_load32x2s(core_remap_mem_arg(map, v0))
    @lib.V128Load32x2U(v0) =>
      @lib.Instruction::v128_load32x2u(core_remap_mem_arg(map, v0))
    @lib.V128Load64Lane(v0, v1) =>
      @lib.Instruction::v128_load64_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Load64Splat(v0) =>
      @lib.Instruction::v128_load64_splat(core_remap_mem_arg(map, v0))
    @lib.V128Load64Zero(v0) =>
      @lib.Instruction::v128_load64_zero(core_remap_mem_arg(map, v0))
    @lib.V128Load8Lane(v0, v1) =>
      @lib.Instruction::v128_load8_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Load8Splat(v0) =>
      @lib.Instruction::v128_load8_splat(core_remap_mem_arg(map, v0))
    @lib.V128Load8x8S(v0) =>
      @lib.Instruction::v128_load8x8s(core_remap_mem_arg(map, v0))
    @lib.V128Load8x8U(v0) =>
      @lib.Instruction::v128_load8x8u(core_remap_mem_arg(map, v0))
    @lib.V128Not => value
    @lib.V128Or => value
    @lib.V128Store(v0) =>
      @lib.Instruction::v128_store(core_remap_mem_arg(map, v0))
    @lib.V128Store16Lane(v0, v1) =>
      @lib.Instruction::v128_store16_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Store32Lane(v0, v1) =>
      @lib.Instruction::v128_store32_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Store64Lane(v0, v1) =>
      @lib.Instruction::v128_store64_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Store8Lane(v0, v1) =>
      @lib.Instruction::v128_store8_lane(core_remap_mem_arg(map, v0), v1)
    @lib.V128Xor => value
  }
}
