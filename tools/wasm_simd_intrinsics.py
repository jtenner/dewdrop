"""One-instruction SIMD contracts: opcode, Starshine instruction, inputs, result."""

# (result type, Dew function suffix, parameters, Starshine instruction)
SIMD_CROSS_OPERATIONS = [
    ("I8x16", "narrow_i16x8_s", "low: I16x8, high: I16x8", "i8x16_narrow_i16x8s"),
    ("U8x16", "narrow_i16x8_u", "low: U16x8, high: U16x8", "i8x16_narrow_i16x8u"),
    ("I8x16", "swizzle", "value: I8x16, indices: U8x16", "i8x16_swizzle"),
    ("U8x16", "swizzle", "value: U8x16, indices: U8x16", "i8x16_swizzle"),
    ("I16x8", "narrow_i32x4_s", "low: I32x4, high: I32x4", "i16x8_narrow_i32x4s"),
    ("U16x8", "narrow_i32x4_u", "low: U32x4, high: U32x4", "i16x8_narrow_i32x4u"),
    ("I16x8", "extend_low_i8x16_s", "value: I8x16", "i16x8_extend_low_i8x16s"),
    ("I16x8", "extend_high_i8x16_s", "value: I8x16", "i16x8_extend_high_i8x16s"),
    ("U16x8", "extend_low_i8x16_u", "value: U8x16", "i16x8_extend_low_i8x16u"),
    ("U16x8", "extend_high_i8x16_u", "value: U8x16", "i16x8_extend_high_i8x16u"),
    ("I16x8", "extadd_pairwise_i8x16_s", "value: I8x16", "i16x8_extadd_pairwise_i8x16s"),
    ("U16x8", "extadd_pairwise_i8x16_u", "value: U8x16", "i16x8_extadd_pairwise_i8x16u"),
    ("I16x8", "extmul_low_i8x16_s", "left: I8x16, right: I8x16", "i16x8_extmul_low_i8x16s"),
    ("I16x8", "extmul_high_i8x16_s", "left: I8x16, right: I8x16", "i16x8_extmul_high_i8x16s"),
    ("U16x8", "extmul_low_i8x16_u", "left: U8x16, right: U8x16", "i16x8_extmul_low_i8x16u"),
    ("U16x8", "extmul_high_i8x16_u", "left: U8x16, right: U8x16", "i16x8_extmul_high_i8x16u"),
    ("I32x4", "extend_low_i16x8_s", "value: I16x8", "i32x4_extend_low_i16x8s"),
    ("I32x4", "extend_high_i16x8_s", "value: I16x8", "i32x4_extend_high_i16x8s"),
    ("U32x4", "extend_low_i16x8_u", "value: U16x8", "i32x4_extend_low_i16x8u"),
    ("U32x4", "extend_high_i16x8_u", "value: U16x8", "i32x4_extend_high_i16x8u"),
    ("I32x4", "extadd_pairwise_i16x8_s", "value: I16x8", "i32x4_extadd_pairwise_i16x8s"),
    ("U32x4", "extadd_pairwise_i16x8_u", "value: U16x8", "i32x4_extadd_pairwise_i16x8u"),
    ("I32x4", "extmul_low_i16x8_s", "left: I16x8, right: I16x8", "i32x4_extmul_low_i16x8s"),
    ("I32x4", "extmul_high_i16x8_s", "left: I16x8, right: I16x8", "i32x4_extmul_high_i16x8s"),
    ("U32x4", "extmul_low_i16x8_u", "left: U16x8, right: U16x8", "i32x4_extmul_low_i16x8u"),
    ("U32x4", "extmul_high_i16x8_u", "left: U16x8, right: U16x8", "i32x4_extmul_high_i16x8u"),
    ("I32x4", "dot_i16x8_s", "left: I16x8, right: I16x8", "i32x4_dot_i16x8s"),
    ("I64x2", "extend_low_i32x4_s", "value: I32x4", "i64x2_extend_low_i32x4s"),
    ("I64x2", "extend_high_i32x4_s", "value: I32x4", "i64x2_extend_high_i32x4s"),
    ("U64x2", "extend_low_i32x4_u", "value: U32x4", "i64x2_extend_low_i32x4u"),
    ("U64x2", "extend_high_i32x4_u", "value: U32x4", "i64x2_extend_high_i32x4u"),
    ("I64x2", "extmul_low_i32x4_s", "left: I32x4, right: I32x4", "i64x2_extmul_low_i32x4s"),
    ("I64x2", "extmul_high_i32x4_s", "left: I32x4, right: I32x4", "i64x2_extmul_high_i32x4s"),
    ("U64x2", "extmul_low_i32x4_u", "left: U32x4, right: U32x4", "i64x2_extmul_low_i32x4u"),
    ("U64x2", "extmul_high_i32x4_u", "left: U32x4, right: U32x4", "i64x2_extmul_high_i32x4u"),
    ("F32x4", "convert_i32x4_s", "value: I32x4", "f32x4_convert_i32x4s"),
    ("F32x4", "convert_i32x4_u", "value: U32x4", "f32x4_convert_i32x4u"),
    ("F32x4", "demote_f64x2_zero", "value: F64x2", "f32x4_demote_f64x2_zero"),
    ("F64x2", "convert_low_i32x4_s", "value: I32x4", "f64x2_convert_low_i32x4s"),
    ("F64x2", "convert_low_i32x4_u", "value: U32x4", "f64x2_convert_low_i32x4u"),
    ("F64x2", "promote_low_f32x4", "value: F32x4", "f64x2_promote_low_f32x4"),
    ("I32x4", "trunc_sat_f32x4_s", "value: F32x4", "i32x4_trunc_sat_f32x4s"),
    ("U32x4", "trunc_sat_f32x4_u", "value: F32x4", "i32x4_trunc_sat_f32x4u"),
    ("I32x4", "trunc_sat_f64x2_s_zero", "value: F64x2", "i32x4_trunc_sat_f64x2s_zero"),
    ("U32x4", "trunc_sat_f64x2_u_zero", "value: F64x2", "i32x4_trunc_sat_f64x2u_zero"),
]

def simd_cross_opcode(result, suffix):
    family = result.lower()
    if family.startswith("u"):
        family = "i" + family[1:]
    return family + "." + suffix

SIMD_INSTRUCTIONS = (
    ("v128.not", "v128_not", ("V128",), "V128"),
    ("v128.andnot", "v128_andnot", ("V128", "V128"), "V128"),
    ("v128.bitselect", "v128_bitselect", ("V128", "V128", "V128"), "V128"),
    ("v128.any_true", "v128_any_true", ("V128",), "I32"),
    ("i8x16.splat", "i8x16_splat", ("I32",), "V128"),
    ("i16x8.splat", "i16x8_splat", ("I32",), "V128"),
    ("i32x4.splat", "i32x4_splat", ("I32",), "V128"),
    ("i64x2.splat", "i64x2_splat", ("I64",), "V128"),
    ("f32x4.splat", "f32x4_splat", ("F32",), "V128"),
    ("f64x2.splat", "f64x2_splat", ("F64",), "V128"),
    ("i8x16.add", "i8x16_add", ("V128", "V128"), "V128"),
    ("i8x16.sub", "i8x16_sub", ("V128", "V128"), "V128"),
    ("i8x16.min_s", "i8x16_min_s", ("V128", "V128"), "V128"),
    ("i8x16.min_u", "i8x16_min_u", ("V128", "V128"), "V128"),
    ("i8x16.max_s", "i8x16_max_s", ("V128", "V128"), "V128"),
    ("i8x16.max_u", "i8x16_max_u", ("V128", "V128"), "V128"),
    ("i8x16.avgr_u", "i8x16_avgr_u", ("V128", "V128"), "V128"),
    ("i8x16.add_sat_s", "i8x16_add_sat_s", ("V128", "V128"), "V128"),
    ("i8x16.add_sat_u", "i8x16_add_sat_u", ("V128", "V128"), "V128"),
    ("i8x16.sub_sat_s", "i8x16_sub_sat_s", ("V128", "V128"), "V128"),
    ("i8x16.sub_sat_u", "i8x16_sub_sat_u", ("V128", "V128"), "V128"),
    ("i8x16.eq", "i8x16_eq", ("V128", "V128"), "V128"),
    ("i8x16.ne", "i8x16_ne", ("V128", "V128"), "V128"),
    ("i8x16.lt_s", "i8x16_lt_s", ("V128", "V128"), "V128"),
    ("i8x16.lt_u", "i8x16_lt_u", ("V128", "V128"), "V128"),
    ("i8x16.le_s", "i8x16_le_s", ("V128", "V128"), "V128"),
    ("i8x16.le_u", "i8x16_le_u", ("V128", "V128"), "V128"),
    ("i8x16.gt_s", "i8x16_gt_s", ("V128", "V128"), "V128"),
    ("i8x16.gt_u", "i8x16_gt_u", ("V128", "V128"), "V128"),
    ("i8x16.ge_s", "i8x16_ge_s", ("V128", "V128"), "V128"),
    ("i8x16.ge_u", "i8x16_ge_u", ("V128", "V128"), "V128"),
    ("i8x16.abs", "i8x16_abs", ("V128",), "V128"),
    ("i8x16.neg", "i8x16_neg", ("V128",), "V128"),
    ("i8x16.popcnt", "i8x16_popcnt", ("V128",), "V128"),
    ("i8x16.all_true", "i8x16_all_true", ("V128",), "I32"),
    ("i8x16.bitmask", "i8x16_bitmask", ("V128",), "I32"),
    ("i8x16.shl", "i8x16_shl", ("V128", "I32"), "V128"),
    ("i8x16.shr_s", "i8x16_shr_s", ("V128", "I32"), "V128"),
    ("i8x16.shr_u", "i8x16_shr_u", ("V128", "I32"), "V128"),
    ("i16x8.add", "i16x8_add", ("V128", "V128"), "V128"),
    ("i16x8.sub", "i16x8_sub", ("V128", "V128"), "V128"),
    ("i16x8.mul", "i16x8_mul", ("V128", "V128"), "V128"),
    ("i16x8.min_s", "i16x8_min_s", ("V128", "V128"), "V128"),
    ("i16x8.min_u", "i16x8_min_u", ("V128", "V128"), "V128"),
    ("i16x8.max_s", "i16x8_max_s", ("V128", "V128"), "V128"),
    ("i16x8.max_u", "i16x8_max_u", ("V128", "V128"), "V128"),
    ("i16x8.avgr_u", "i16x8_avgr_u", ("V128", "V128"), "V128"),
    ("i16x8.add_sat_s", "i16x8_add_sat_s", ("V128", "V128"), "V128"),
    ("i16x8.add_sat_u", "i16x8_add_sat_u", ("V128", "V128"), "V128"),
    ("i16x8.sub_sat_s", "i16x8_sub_sat_s", ("V128", "V128"), "V128"),
    ("i16x8.sub_sat_u", "i16x8_sub_sat_u", ("V128", "V128"), "V128"),
    ("i16x8.eq", "i16x8_eq", ("V128", "V128"), "V128"),
    ("i16x8.ne", "i16x8_ne", ("V128", "V128"), "V128"),
    ("i16x8.lt_s", "i16x8_lt_s", ("V128", "V128"), "V128"),
    ("i16x8.lt_u", "i16x8_lt_u", ("V128", "V128"), "V128"),
    ("i16x8.le_s", "i16x8_le_s", ("V128", "V128"), "V128"),
    ("i16x8.le_u", "i16x8_le_u", ("V128", "V128"), "V128"),
    ("i16x8.gt_s", "i16x8_gt_s", ("V128", "V128"), "V128"),
    ("i16x8.gt_u", "i16x8_gt_u", ("V128", "V128"), "V128"),
    ("i16x8.ge_s", "i16x8_ge_s", ("V128", "V128"), "V128"),
    ("i16x8.ge_u", "i16x8_ge_u", ("V128", "V128"), "V128"),
    ("i16x8.abs", "i16x8_abs", ("V128",), "V128"),
    ("i16x8.neg", "i16x8_neg", ("V128",), "V128"),
    ("i16x8.all_true", "i16x8_all_true", ("V128",), "I32"),
    ("i16x8.bitmask", "i16x8_bitmask", ("V128",), "I32"),
    ("i16x8.shl", "i16x8_shl", ("V128", "I32"), "V128"),
    ("i16x8.shr_s", "i16x8_shr_s", ("V128", "I32"), "V128"),
    ("i16x8.shr_u", "i16x8_shr_u", ("V128", "I32"), "V128"),
    ("i32x4.add", "i32x4_add", ("V128", "V128"), "V128"),
    ("i32x4.sub", "i32x4_sub", ("V128", "V128"), "V128"),
    ("i32x4.mul", "i32x4_mul", ("V128", "V128"), "V128"),
    ("i32x4.min_s", "i32x4_min_s", ("V128", "V128"), "V128"),
    ("i32x4.min_u", "i32x4_min_u", ("V128", "V128"), "V128"),
    ("i32x4.max_s", "i32x4_max_s", ("V128", "V128"), "V128"),
    ("i32x4.max_u", "i32x4_max_u", ("V128", "V128"), "V128"),
    ("i32x4.eq", "i32x4_eq", ("V128", "V128"), "V128"),
    ("i32x4.ne", "i32x4_ne", ("V128", "V128"), "V128"),
    ("i32x4.lt_s", "i32x4_lt_s", ("V128", "V128"), "V128"),
    ("i32x4.lt_u", "i32x4_lt_u", ("V128", "V128"), "V128"),
    ("i32x4.le_s", "i32x4_le_s", ("V128", "V128"), "V128"),
    ("i32x4.le_u", "i32x4_le_u", ("V128", "V128"), "V128"),
    ("i32x4.gt_s", "i32x4_gt_s", ("V128", "V128"), "V128"),
    ("i32x4.gt_u", "i32x4_gt_u", ("V128", "V128"), "V128"),
    ("i32x4.ge_s", "i32x4_ge_s", ("V128", "V128"), "V128"),
    ("i32x4.ge_u", "i32x4_ge_u", ("V128", "V128"), "V128"),
    ("i32x4.abs", "i32x4_abs", ("V128",), "V128"),
    ("i32x4.neg", "i32x4_neg", ("V128",), "V128"),
    ("i32x4.all_true", "i32x4_all_true", ("V128",), "I32"),
    ("i32x4.bitmask", "i32x4_bitmask", ("V128",), "I32"),
    ("i32x4.shl", "i32x4_shl", ("V128", "I32"), "V128"),
    ("i32x4.shr_s", "i32x4_shr_s", ("V128", "I32"), "V128"),
    ("i32x4.shr_u", "i32x4_shr_u", ("V128", "I32"), "V128"),
    ("i64x2.add", "i64x2_add", ("V128", "V128"), "V128"),
    ("i64x2.sub", "i64x2_sub", ("V128", "V128"), "V128"),
    ("i64x2.mul", "i64x2_mul", ("V128", "V128"), "V128"),
    ("i64x2.eq", "i64x2_eq", ("V128", "V128"), "V128"),
    ("i64x2.ne", "i64x2_ne", ("V128", "V128"), "V128"),
    ("i64x2.lt_s", "i64x2_lt_s", ("V128", "V128"), "V128"),
    ("i64x2.le_s", "i64x2_le_s", ("V128", "V128"), "V128"),
    ("i64x2.gt_s", "i64x2_gt_s", ("V128", "V128"), "V128"),
    ("i64x2.ge_s", "i64x2_ge_s", ("V128", "V128"), "V128"),
    ("i64x2.abs", "i64x2_abs", ("V128",), "V128"),
    ("i64x2.neg", "i64x2_neg", ("V128",), "V128"),
    ("i64x2.all_true", "i64x2_all_true", ("V128",), "I32"),
    ("i64x2.bitmask", "i64x2_bitmask", ("V128",), "I32"),
    ("i64x2.shl", "i64x2_shl", ("V128", "I32"), "V128"),
    ("i64x2.shr_s", "i64x2_shr_s", ("V128", "I32"), "V128"),
    ("i64x2.shr_u", "i64x2_shr_u", ("V128", "I32"), "V128"),
    ("f32x4.add", "f32x4_add", ("V128", "V128"), "V128"),
    ("f32x4.sub", "f32x4_sub", ("V128", "V128"), "V128"),
    ("f32x4.mul", "f32x4_mul", ("V128", "V128"), "V128"),
    ("f32x4.div", "f32x4_div", ("V128", "V128"), "V128"),
    ("f32x4.min", "f32x4_min", ("V128", "V128"), "V128"),
    ("f32x4.max", "f32x4_max", ("V128", "V128"), "V128"),
    ("f32x4.pmin", "f32x4_pmin", ("V128", "V128"), "V128"),
    ("f32x4.pmax", "f32x4_pmax", ("V128", "V128"), "V128"),
    ("f32x4.eq", "f32x4_eq", ("V128", "V128"), "V128"),
    ("f32x4.ne", "f32x4_ne", ("V128", "V128"), "V128"),
    ("f32x4.lt", "f32x4_lt", ("V128", "V128"), "V128"),
    ("f32x4.le", "f32x4_le", ("V128", "V128"), "V128"),
    ("f32x4.gt", "f32x4_gt", ("V128", "V128"), "V128"),
    ("f32x4.ge", "f32x4_ge", ("V128", "V128"), "V128"),
    ("f32x4.abs", "f32x4_abs", ("V128",), "V128"),
    ("f32x4.neg", "f32x4_neg", ("V128",), "V128"),
    ("f32x4.sqrt", "f32x4_sqrt", ("V128",), "V128"),
    ("f32x4.ceil", "f32x4_ceil", ("V128",), "V128"),
    ("f32x4.floor", "f32x4_floor", ("V128",), "V128"),
    ("f32x4.trunc", "f32x4_trunc", ("V128",), "V128"),
    ("f32x4.nearest", "f32x4_nearest", ("V128",), "V128"),
    ("f64x2.add", "f64x2_add", ("V128", "V128"), "V128"),
    ("f64x2.sub", "f64x2_sub", ("V128", "V128"), "V128"),
    ("f64x2.mul", "f64x2_mul", ("V128", "V128"), "V128"),
    ("f64x2.div", "f64x2_div", ("V128", "V128"), "V128"),
    ("f64x2.min", "f64x2_min", ("V128", "V128"), "V128"),
    ("f64x2.max", "f64x2_max", ("V128", "V128"), "V128"),
    ("f64x2.pmin", "f64x2_pmin", ("V128", "V128"), "V128"),
    ("f64x2.pmax", "f64x2_pmax", ("V128", "V128"), "V128"),
    ("f64x2.eq", "f64x2_eq", ("V128", "V128"), "V128"),
    ("f64x2.ne", "f64x2_ne", ("V128", "V128"), "V128"),
    ("f64x2.lt", "f64x2_lt", ("V128", "V128"), "V128"),
    ("f64x2.le", "f64x2_le", ("V128", "V128"), "V128"),
    ("f64x2.gt", "f64x2_gt", ("V128", "V128"), "V128"),
    ("f64x2.ge", "f64x2_ge", ("V128", "V128"), "V128"),
    ("f64x2.abs", "f64x2_abs", ("V128",), "V128"),
    ("f64x2.neg", "f64x2_neg", ("V128",), "V128"),
    ("f64x2.sqrt", "f64x2_sqrt", ("V128",), "V128"),
    ("f64x2.ceil", "f64x2_ceil", ("V128",), "V128"),
    ("f64x2.floor", "f64x2_floor", ("V128",), "V128"),
    ("f64x2.trunc", "f64x2_trunc", ("V128",), "V128"),
    ("f64x2.nearest", "f64x2_nearest", ("V128",), "V128"),
)


def _cross_instructions():
    instructions = {}
    for result, suffix, parameters, instruction in SIMD_CROSS_OPERATIONS:
        opcode = simd_cross_opcode(result, suffix)
        entry = (opcode, instruction, ("V128",) * len(parameters.split(",")), "V128")
        if opcode in instructions:
            assert instructions[opcode] == entry, f"contradictory SIMD opcode: {opcode}"
        instructions[opcode] = entry
    return tuple(instructions.values())


SIMD_INSTRUCTIONS += _cross_instructions()


def _lane_instructions():
    instructions = []
    for family, scalar, count, suffixes in (
        ("i8x16", "I32", 16, ("_s", "_u")),
        ("i16x8", "I32", 8, ("_s", "_u")),
        ("i32x4", "I32", 4, ("",)),
        ("i64x2", "I64", 2, ("",)),
        ("f32x4", "F32", 4, ("",)),
        ("f64x2", "F64", 2, ("",)),
    ):
        for index in range(count):
            for suffix in suffixes:
                instructions.append((
                    f"{family}.extract_lane{suffix} {index}",
                    f"{family}_extract_lane{suffix}", ("V128",), scalar, (index,),
                ))
            instructions.append((
                f"{family}.replace_lane {index}",
                f"{family}_replace_lane", ("V128", scalar), "V128", (index,),
            ))
    return tuple(instructions)


SIMD_LANE_INSTRUCTIONS = _lane_instructions()
SIMD_SIGNATURES = SIMD_INSTRUCTIONS + tuple(row[:4] for row in SIMD_LANE_INSTRUCTIONS)


def simd_shuffle_immediates(descriptor):
    prefix = "i8x16.shuffle "
    if not descriptor.startswith(prefix):
        return None
    tokens = descriptor[len(prefix):].split(" ")
    if len(tokens) != 16 or any(
        not token.isascii() or not token.isdecimal() or len(token) > 2
        or (len(token) > 1 and token[0] == "0") or int(token) > 31
        for token in tokens
    ):
        return None
    return tuple(map(int, tokens))


def _memory_instructions():
    instructions = []
    for width, align, lanes in ((8, 0, 16), (16, 1, 8), (32, 2, 4), (64, 3, 2)):
        instructions.append((
            f"v128.load{width}_splat", f"v128_load{width}_splat", ("I32",), "V128", align, None,
        ))
        for index in range(lanes):
            for operation in ("load", "store"):
                instructions.append((
                    f"v128.{operation}{width}_lane {index}", f"v128_{operation}{width}_lane",
                    ("I32", "V128"), "V128" if operation == "load" else "Unit", align, index,
                ))
    for width, count in ((8, 8), (16, 4), (32, 2)):
        for sign in ("s", "u"):
            instructions.append((
                f"v128.load{width}x{count}_{sign}", f"v128_load{width}x{count}{sign}",
                ("I32",), "V128", 3, None,
            ))
    for width, align in ((32, 2), (64, 3)):
        instructions.append((
            f"v128.load{width}_zero", f"v128_load{width}_zero", ("I32",), "V128", align, None,
        ))
    return tuple(instructions)


SIMD_MEMORY_INSTRUCTIONS = _memory_instructions()
SIMD_SIGNATURES += tuple(row[:4] for row in SIMD_MEMORY_INSTRUCTIONS)
