module Wasm.Binary where

import Prelude

import Data.Array as Array
import Data.BitStream (BitStream, read_u8, read_utf8_char, write_u8, write_utf8_char)
import Data.Int.Bits (shl, shr, (.&.), (.|.))
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Data.FingerTree (FingerTree, foldl, size, snoc)

import Node.Encoding (Encoding(..), byteLength)
import Util (char_size, to_chars, to_signed, from_chars)

type EncoderFn a = BitStream -> a -> BitStream
type DecoderFn a = BitStream -> Maybe (Tuple a BitStream)
data WasmInt
  = I32 Int
  | I64 Int

data Lanes
  = Lanes16 Int Int Int Int Int Int Int Int Int Int Int Int Int Int Int Int
  | Lanes8 Int Int Int Int Int Int Int Int
  | Lanes4 Int Int Int Int
  | Lanes2 Int Int

data TypeIndex = TypeIndex Int
data FieldIndex = FieldIndex Int
data FuncIndex = FuncIndex Int
data TableIndex = TableIndex Int
data GlobalIndex = GlobalIndex Int
data ElemIndex = ElemIndex Int
data LabelIndex = LabelIndex Int
data MemIndex = MemIndex Int
data DataIndex = DataIndex Int
data LocalIndex = LocalIndex Int

data HeapType
  = HeapTypeFunc
  | HeapTypeNoFunc
  | HeapTypeExtern
  | HeapTypeNoExtern
  | HeapTypeAny
  | HeapTypeEq
  | HeapTypeI31
  | HeapTypeStruct
  | HeapTypeArray
  | HeapTypeNone
  | HeapTypeIndex TypeIndex
  | HeapTypeBot

data RefType
  = RefType HeapType Boolean
  | RefTypeAny
  | RefTypeEq
  | RefTypeI31
  | RefTypeStruct
  | RefTypeArray
  | RefTypeFunc
  | RefTypeExtern
  | RefTypeNone
  | RefTypeNoFunc
  | RefTypeNoExtern

data ValType
  = ValTypeV128
  | ValTypeI32
  | ValTypeI64
  | ValTypeF32
  | ValTypeF64
  | ValTypeRefType RefType
  | BotValType

data Locals = Locals Int ValType

data BlockType
  = BlockTypeVoid
  | BlockTypeValType ValType
  | BlockTypeResultType ResultType

type ResultType = Tuple (FingerTree ValType) (FingerTree ValType)

type FuncType = ResultType

data StorageType
  = StorageTypeValType ValType
  | StorageTypeI8
  | StorageTypeI16

data FieldType = FieldType StorageType Boolean

data StructType = StructType (FingerTree FieldType)

data ArrayType = ArrayType StorageType

data CompositeType
  = CompositeTypeFunc FuncType
  | CompositeTypeStruct StructType
  | CompositeTypeArray ArrayType

data SubType
  = SubType (FingerTree TypeIndex) CompositeType
  | SubTypeFinal (FingerTree TypeIndex) CompositeType

data RecType = RecType (FingerTree SubType)

type Limits = Tuple Int (Maybe Int)

data MemType = MemType Limits

data TableType = TableType RefType Limits

data GlobalType = GlobalType ValType Boolean

data DefType = DefType RecType Int

data ExternType
  = ExternTypeFunc DefType
  | ExternTypeTable TableType
  | ExternTypeMem MemType
  | ExternTypeGlobal GlobalType

data LocalType = LocalType Boolean ValType

type MemArg = Tuple Int Int

data V128 = V128 Int Int Int Int Int Int Int Int Int Int Int Int Int Int Int Int

data Expr = Expr (FingerTree Instruction)

data Code = Code (FingerTree Locals) Expr

data Import = Import String String ImportKind

data ImportKind
  = ImportKindFunc TypeIndex
  | ImportKindTable TableType
  | ImportKindMem MemType
  | ImportKindGlobal GlobalType

data Export = Export String ExportKind

data ExportKind
  = ExportKindFunc FuncIndex
  | ExportKindTable TableIndex
  | ExportKindMem MemIndex
  | ExportKindGlobal GlobalIndex

data Table = Table TableType (Maybe Expr)

data Mem = Mem MemType

data Global = Global GlobalType Expr

data ElemMode
  = ElemModePassive
  | ElemModeActive TableIndex Expr
  | ElemModeDeclarative

data Data = Data (Maybe ActiveData) BitStream
data ActiveData = ActiveData MemIndex Expr

data Instruction
  = I64Const Int
  | I32Const Int
  | F64Const Number
  | F32Const Number
  | I64Popcnt
  | I64Ctz
  | I64Clz
  | I32Popcnt
  | I32Ctz
  | I32Clz
  | F64Nearest
  | F64Trunc
  | F64Floor
  | F64Ceil
  | F64Sqrt
  | F64Neg
  | F64Abs
  | F32Nearest
  | F32Trunc
  | F32Floor
  | F32Ceil
  | F32Sqrt
  | F32Neg
  | F32Abs
  | I64Rotr
  | I64Rotl
  | I64ShrS
  | I64ShrU
  | I64Shl
  | I64Xor
  | I64Or
  | I64And
  | I64RemS
  | I64RemU
  | I64DivS
  | I64DivU
  | I64Mul
  | I64Sub
  | I64Add
  | I32Rotr
  | I32Rotl
  | I32ShrS
  | I32ShrU
  | I32Shl
  | I32Xor
  | I32Or
  | I32And
  | I32RemS
  | I32RemU
  | I32DivS
  | I32DivU
  | I32Mul
  | I32Sub
  | I32Add
  | F64Copysign
  | F64Max
  | F64Min
  | F64Div
  | F64Mul
  | F64Sub
  | F64Add
  | F32Copysign
  | F32Max
  | F32Min
  | F32Div
  | F32Mul
  | F32Sub
  | F32Add
  | I64Eqz
  | I32Eqz
  | I64GeS
  | I64GeU
  | I64LeS
  | I64LeU
  | I64GtS
  | I64GtU
  | I64LtS
  | I64LtU
  | I64Ne
  | I64Eq
  | I32GeS
  | I32GeU
  | I32LeS
  | I32LeU
  | I32GtS
  | I32GtU
  | I32LtS
  | I32LtU
  | I32Ne
  | V128AndNot
  | I32Eq
  | F64Ge
  | F64Le
  | F64Gt
  | F64Lt
  | F64Ne
  | F64Eq
  | F32Ge
  | F32Le
  | F32Gt
  | F32Lt
  | F32Ne
  | F32Eq
  | I32Extend16S
  | I32Extend8S
  | I64Extend32S
  | I64Extend16S
  | I64Extend8S
  | I32WrapI64
  | I64ExtendI32S
  | I64ExtendI32U
  | I64TruncF64S
  | I64TruncF64U
  | I64TruncF32S
  | I64TruncF32U
  | I32TruncF64S
  | I32TruncF64U
  | I32TruncF32S
  | I32TruncF32U
  | I64TruncSatF64S
  | I64TruncSatF64U
  | I64TruncSatF32S
  | I64TruncSatF32U
  | I32TruncSatF64S
  | I32TruncSatF64U
  | I32TruncSatF32S
  | I32TruncSatF32U
  | F32DemoteF64
  | F64PromoteF32
  | F64ConvertI64S
  | F64ConvertI64U
  | F64ConvertI32S
  | F64ConvertI32U
  | F32ConvertI64S
  | F32ConvertI64U
  | F32ConvertI32S
  | F32ConvertI32U
  | F64ReinterpretI64
  | F32ReinterpretI32
  | I64ReinterpretF64
  | I32ReinterpretF32
  | V128Const V128
  | V128Not
  | V128Xor
  | V128Or
  | V128And
  | V128Bitselect
  | V128AnyTrue
  | I8x16Shuffle Int Int Int Int Int Int Int Int Int Int Int Int Int Int Int Int
  | I8x16Swizzle
  | I32x4Splat
  | I16x8Splat
  | I8x16Splat
  | I64x2Splat
  | F32x4Splat
  | F64x2Splat
  | I8x16ExtractLaneS Int
  | I16x8ExtractLaneS Int
  | I32x4ExtractLane Int
  | I64x2ExtractLane Int
  | I8x16ExtractLaneU Int
  | I16x8ExtractLaneU Int
  | F32x4ExtractLane Int
  | F64x2ExtractLane Int
  | I8x16ReplaceLane Int
  | I16x8ReplaceLane Int
  | I32x4ReplaceLane Int
  | I64x2ReplaceLane Int
  | F32x4ReplaceLane Int
  | F64x2ReplaceLane Int
  | I8x16GeS
  | I8x16GeU
  | I8x16LeS
  | I8x16LeU
  | I8x16GtS
  | I8x16GtU
  | I8x16LtS
  | I8x16LtU
  | I8x16Ne
  | I8x16Eq
  | I16x8GeS
  | I16x8GeU
  | I16x8LeS
  | I16x8LeU
  | I16x8GtS
  | I16x8GtU
  | I16x8LtS
  | I16x8LtU
  | I16x8Ne
  | I16x8Eq
  | I32x4GeS
  | I32x4GeU
  | I32x4LeS
  | I32x4LeU
  | I32x4GtS
  | I32x4GtU
  | I32x4LtS
  | I32x4LtU
  | I32x4Ne
  | I32x4Eq
  | I64x2GeS
  | I64x2LeS
  | I64x2GtS
  | I64x2LtS
  | I64x2Ne
  | I64x2Eq
  | F64x2Ge
  | F64x2Le
  | F64x2Gt
  | F64x2Lt
  | F64x2Ne
  | F64x2Eq
  | F32x4Ge
  | F32x4Le
  | F32x4Gt
  | F32x4Lt
  | F32x4Ne
  | F32x4Eq
  | I64x2Neg
  | I64x2Abs
  | I32x4Neg
  | I32x4Abs
  | I16x8Neg
  | I16x8Abs
  | I8x16Neg
  | I8x16Abs
  | I8x16Popcnt
  | I16x8Q15mulrSatS
  | I32x4DotI16x8S
  | F64x2Nearest
  | F64x2Trunc
  | F64x2Floor
  | F64x2Ceil
  | F64x2Sqrt
  | F64x2Neg
  | F64x2Abs
  | F32x4Nearest
  | F32x4Trunc
  | F32x4Floor
  | F32x4Ceil
  | F32x4Sqrt
  | F32x4Neg
  | F32x4Abs
  | I64x2AllTrue
  | I32x4AllTrue
  | I16x8AllTrue
  | I8x16AllTrue
  | I64x2Bitmask
  | I32x4Bitmask
  | I16x8Bitmask
  | I8x16Bitmask
  | I8x16NarrowI16x8S
  | I8x16NarrowI16x8U
  | I16x8NarrowI32x4S
  | I16x8NarrowI32x4U
  | I16x8ExtendHighI8x16S
  | I16x8ExtendHighI8x16U
  | I16x8ExtendLowI8x16S
  | I16x8ExtendLowI8x16U
  | I32x4ExtendHighI16x8S
  | I32x4ExtendHighI16x8U
  | I32x4ExtendLowI16x8S
  | I32x4ExtendLowI16x8U
  | I64x2ExtendHighI32x4S
  | I64x2ExtendHighI32x4U
  | I64x2ExtendLowI32x4S
  | I64x2ExtendLowI32x4U
  | I64x2ShrS
  | I64x2ShrU
  | I64x2Shl
  | I32x4ShrS
  | I32x4ShrU
  | I32x4Shl
  | I16x8ShrS
  | I16x8ShrU
  | I16x8Shl
  | I8x16ShrS
  | I8x16ShrU
  | I8x16Shl
  | I64x2Sub
  | I64x2Add
  | I32x4Sub
  | I32x4Add
  | I16x8Sub
  | I16x8Add
  | I8x16Sub
  | I8x16Add
  | I8x16MaxS
  | I8x16MaxU
  | I8x16MinS
  | I8x16MinU
  | I16x8MaxS
  | I16x8MaxU
  | I16x8MinS
  | I16x8MinU
  | I32x4MaxS
  | I32x4MaxU
  | I32x4MinS
  | I32x4MinU
  | I8x16SubSatS
  | I8x16SubSatU
  | I8x16AddSatS
  | I8x16AddSatU
  | I16x8SubSatS
  | I16x8SubSatU
  | I16x8AddSatS
  | I16x8AddSatU
  | I16x8Mul
  | I32x4Mul
  | I8x16AvgrU
  | I64x2Mul
  | I16x8AvgrU
  | I16x8ExtmulHighI8x16S
  | I16x8ExtmulHighI8x16U
  | I16x8ExtmulLowI8x16S
  | I16x8ExtmulLowI8x16U
  | I32x4ExtmulHighI16x8S
  | I32x4ExtmulHighI16x8U
  | I32x4ExtmulLowI16x8S
  | I32x4ExtmulLowI16x8U
  | I64x2ExtmulHighI32x4S
  | I64x2ExtmulHighI32x4U
  | I64x2ExtmulLowI32x4S
  | I64x2ExtmulLowI32x4U
  | I16x8ExtaddPairwiseI8x16S
  | I16x8ExtaddPairwiseI8x16U
  | I32x4ExtaddPairwiseI16x8S
  | I32x4ExtaddPairwiseI16x8U
  | F64x2Pmax
  | F64x2Pmin
  | F64x2Max
  | F64x2Min
  | F64x2Div
  | F64x2Mul
  | F64x2Sub
  | F64x2Add
  | F32x4Pmax
  | F32x4Pmin
  | F32x4Max
  | F32x4Min
  | F32x4Div
  | F32x4Mul
  | F32x4Sub
  | F32x4Add
  | I32x4TruncSatF32x4S
  | I32x4TruncSatF32x4U
  | I32x4TruncSatF64x2SZero
  | I32x4TruncSatF64x2UZero
  | F32x4ConvertI32x4S
  | F32x4ConvertI32x4U
  | F32x4DemoteF64x2Zero
  | F64x2ConvertLowI32x4S
  | F64x2ConvertLowI32x4U
  | F64x2PromoteLowF32x4
  | RefNull HeapType
  | RefFunc FuncIndex
  | RefIsNull
  | RefAsNonNull
  | RefEq
  | RefTest HeapType
  | RefTestNullable HeapType
  | RefCast HeapType
  | RefCastNullable HeapType
  | StructNew TypeIndex
  | StructNewDefault TypeIndex
  | StructGet TypeIndex FieldIndex
  | StructGetS TypeIndex FieldIndex
  | StructGetU TypeIndex FieldIndex
  | StructSet TypeIndex FieldIndex
  | ArrayNew TypeIndex
  | ArrayNewDefault TypeIndex
  | ArrayNewData TypeIndex DataIndex
  | ArrayNewElem TypeIndex ElemIndex
  | ArrayNewFixed TypeIndex Int
  | ArrayGet TypeIndex
  | ArrayGetS TypeIndex
  | ArrayGetU TypeIndex
  | ArraySet TypeIndex
  | ArrayLen
  | ArrayFill TypeIndex
  | ArrayCopy TypeIndex TypeIndex
  | ArrayInitData TypeIndex DataIndex
  | ArrayInitElem TypeIndex ElemIndex
  | RefI31
  | I31GetS
  | I31GetU
  | AnyConvertExtern
  | ExternConvertAny
  | Drop
  | Select
  | SelectT (FingerTree ValType)
  | LocalGet LocalIndex
  | LocalSet LocalIndex
  | LocalTee LocalIndex
  | GlobalGet GlobalIndex
  | GlobalSet GlobalIndex
  | TableGet TableIndex
  | TableSet TableIndex
  | TableSize TableIndex
  | TableGrow TableIndex
  | TableFill TableIndex
  | TableCopy TableIndex TableIndex
  | TableInit ElemIndex TableIndex
  | ElemDrop ElemIndex
  | I64Load MemArg
  | I32Load MemArg
  | F64Load MemArg
  | F32Load MemArg
  | V128Load MemArg
  | I64Store MemArg
  | I64Store8 MemArg
  | I64Store16 MemArg
  | I64Store32 MemArg
  | I32Store MemArg
  | I32Store8 MemArg
  | I32Store16 MemArg
  | F64Store MemArg
  | F32Store MemArg
  | V128Store MemArg
  | I64Load16S MemArg
  | I64Load16U MemArg
  | I64Load8S MemArg
  | I64Load8U MemArg
  | I32Load16S MemArg
  | I32Load16U MemArg
  | I32Load8S MemArg
  | I32Load8U MemArg
  | I64Load32S MemArg
  | I64Load32U MemArg
  | V128Load8x8S MemArg
  | V128Load8x8U MemArg
  | V128Load16x4S MemArg
  | V128Load16x4U MemArg
  | V128Load32x2S MemArg
  | V128Load32x2U MemArg
  | V128Load32Zero MemArg
  | V128Load64Zero MemArg
  | V128Load64Splat MemArg
  | V128Load32Splat MemArg
  | V128Load16Splat MemArg
  | V128Load8Splat MemArg
  | V128Load8Lane MemArg Int
  | V128Load16Lane MemArg Int
  | V128Load32Lane MemArg Int
  | V128Load64Lane MemArg Int
  | V128Store8Lane MemArg Int
  | V128Store16Lane MemArg Int
  | V128Store32Lane MemArg Int
  | V128Store64Lane MemArg Int
  | MemorySize
  | MemoryGrow
  | MemoryFill
  | MemoryCopy
  | MemoryInit DataIndex
  | DataDrop DataIndex
  | Nop
  | Unreachable
  | Block BlockType Expr
  | Loop BlockType Expr
  | If BlockType (FingerTree Instruction) (Maybe (FingerTree Instruction))
  | Br LabelIndex
  | BrIf LabelIndex
  | BrTable (FingerTree LabelIndex) LabelIndex
  | BrOnNull LabelIndex
  | BrOnNonNull LabelIndex
  | BrOnCast LabelIndex RefType RefType
  | BrOnCastFail LabelIndex RefType RefType
  | Return
  | Call FuncIndex
  | CallRef TypeIndex
  | CallIndirect TableIndex TypeIndex
  | ReturnCall FuncIndex
  | ReturnCallRef TypeIndex
  | ReturnCallIndirect TableIndex TypeIndex
  | End
  | Else

encode_vec :: ∀ (@u :: Type). EncoderFn u -> FingerTree u -> BitStream -> BitStream
encode_vec f n s = foldl f (encode_uleb128 (size n) s) n

decode_vec :: ∀ (@u :: Type). DecoderFn u -> BitStream -> Maybe (Tuple (FingerTree u) BitStream)
decode_vec f s = do
  Tuple n s' <- decode_uleb128 s
  go n mempty s'
  where
  go :: Int -> FingerTree u -> BitStream -> Maybe (Tuple (FingerTree u) BitStream)
  go 0 acc s'' = Just $ Tuple acc s''
  go n acc s'' = do
    Tuple v s''' <- f s''
    go (n - 1) (snoc v acc) s'''

encode_maybe :: ∀ (@u :: Type). EncoderFn u -> Maybe u -> BitStream -> BitStream
encode_maybe _ Nothing s = s
encode_maybe f (Just v) s = f s v

-- encode_uleb128 :: WasmInt -> BitStream -> BitStream
leb_bits_mask :: Int
leb_bits_mask = 0x7F -- 0b0111_1111

decode_uleb128 :: BitStream -> Maybe (Tuple Int BitStream)
decode_uleb128 s = go 0 0 s
  where
  go :: Int -> Int -> BitStream -> Maybe (Tuple Int BitStream)
  go acc count s'
    | count >= 10 = Nothing
    | otherwise = do
        Tuple v s'' <- read_u8 s'
        let acc' = (acc `shl` 7) + (v .&. leb_bits_mask)
        if v >= 0x80 then go acc' (count + 1) s''
        else Just $ Tuple acc' s''

decode_sleb128 :: BitStream -> Maybe (Tuple Int BitStream)
decode_sleb128 s = go 0 0 (read_u8 s)
  where
  go :: Int -> Int -> Maybe (Tuple Int BitStream) -> Maybe (Tuple Int BitStream)
  go _ _ Nothing = Nothing
  go acc count (Just (Tuple byte s'))
    | count >= 10 = Nothing
    | byte >= 0x80 = go (acc .|. ((byte .&. leb_bits_mask) `shl` (7 * count))) (count + 1) (read_u8 s')
    | otherwise = do
        let byte' = to_signed 7 $ byte .&. leb_bits_mask
        Just $ Tuple (acc .|. (byte' `shl` (7 * count))) s'

encode_uleb128 :: Int -> BitStream -> BitStream
encode_uleb128 v s = go 0 v s
  where
  go :: Int -> Int -> BitStream -> BitStream
  go count v' s'
    | count >= 10 = s'
    | v' <= 0x7F = write_u8 v' s'
    | otherwise = do
        let
          byte = (v' .&. leb_bits_mask) .|. 0x80
          v'' = v' `shr` 7
        go (count + 1) v'' $ write_u8 byte s'

encode_sleb128 :: Int -> BitStream -> BitStream
encode_sleb128 v s = go 0 v s
  where
  go :: Int -> Int -> BitStream -> BitStream
  go count v' s'
    | count >= 10 = s'
    | v' > 63 || v' < -64 = go (count + 1) (v' `shl` 7) $ write_u8 ((v' .&. leb_bits_mask) .|. 0x80) s'
    | otherwise = write_u8 (to_signed 7 v') s'

encode_char :: Char -> BitStream -> BitStream
encode_char = write_utf8_char

decode_char :: BitStream -> Maybe (Tuple Char BitStream)
decode_char = read_utf8_char

encode_string :: String -> BitStream -> BitStream
encode_string v s =
  let
    chars = to_chars v
    byte_length = byteLength v UTF8
    s' = encode_uleb128 byte_length s
  in
    Array.foldl (flip encode_char) s' chars

-- n [...items]
-- byte_length string

decode_string :: BitStream -> Maybe (Tuple String BitStream)
decode_string s = do
  Tuple byte_length s' <- decode_uleb128 s
  go byte_length [] s'
  where
  go :: Int -> Array Char -> BitStream -> Maybe (Tuple String BitStream)
  go 0 acc s'' = Just $ Tuple (from_chars acc) s''
  go n acc s''
    | n <= 0 = Nothing
    | otherwise = do
        Tuple char s''' <- decode_char s''
        go (n - (char_size char)) (Array.snoc acc char) s'''

encode_u8 :: Int -> BitStream -> BitStream
encode_u8 = write_u8

decode_u8 :: BitStream -> Maybe (Tuple Int BitStream)
decode_u8 = read_u8

encode_lanes :: Lanes -> BitStream -> BitStream
encode_lanes (Lanes16 a b c d e f g h i j k l m n o p) bs =
  encode_u8 p $ encode_u8 o $ encode_u8 n $ encode_u8 m $ encode_u8 l $ encode_u8 k $ encode_u8 j $ encode_u8 i $ encode_u8 h $ encode_u8 g $ encode_u8 f $ encode_u8 e $ encode_u8 d $ encode_u8 c $ encode_u8 b $ encode_u8 a bs
encode_lanes (Lanes8 a b c d e f g h) bs =
  encode_u8 h $ encode_u8 g $ encode_u8 f $ encode_u8 e $ encode_u8 d $ encode_u8 c $ encode_u8 b $ encode_u8 a bs
encode_lanes (Lanes4 a b c d) bs =
  encode_u8 d $ encode_u8 c $ encode_u8 b $ encode_u8 a bs
encode_lanes (Lanes2 a b) bs =
  encode_u8 b $ encode_u8 a bs

decode_lanes :: Int -> BitStream -> Maybe (Tuple Lanes BitStream)
decode_lanes 16 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Tuple c s''' <- decode_u8 s''
  Tuple d s'''' <- decode_u8 s'''
  Tuple e s''''' <- decode_u8 s''''
  Tuple f s'''''' <- decode_u8 s'''''
  Tuple g s''''''' <- decode_u8 s''''''
  Tuple h s'''''''' <- decode_u8 s'''''''
  Tuple i s''''''''' <- decode_u8 s''''''''
  Tuple j s'''''''''' <- decode_u8 s'''''''''
  Tuple k s''''''''''' <- decode_u8 s''''''''''
  Tuple l s'''''''''''' <- decode_u8 s'''''''''''
  Tuple m s''''''''''''' <- decode_u8 s''''''''''''
  Tuple n s'''''''''''''' <- decode_u8 s'''''''''''''
  Tuple o s''''''''''''''' <- decode_u8 s''''''''''''''
  Tuple p s'''''''''''''''' <- decode_u8 s'''''''''''''''
  Just (Tuple (Lanes16 a b c d e f g h i j k l m n o p) s'''''''''''''''')
decode_lanes 8 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Tuple c s''' <- decode_u8 s''
  Tuple d s'''' <- decode_u8 s'''
  Tuple e s''''' <- decode_u8 s''''
  Tuple f s'''''' <- decode_u8 s'''''
  Tuple g s''''''' <- decode_u8 s''''''
  Tuple h s'''''''' <- decode_u8 s'''''''
  Just (Tuple (Lanes8 a b c d e f g h) s'''''''')
decode_lanes 4 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Tuple c s''' <- decode_u8 s''
  Tuple d s'''' <- decode_u8 s'''
  Just (Tuple (Lanes4 a b c d) s'''')
decode_lanes 2 s = do
  Tuple a s' <- decode_u8 s
  Tuple b s'' <- decode_u8 s'
  Just (Tuple (Lanes2 a b) s'')
decode_lanes _ _ = Nothing

encode_locals :: Locals -> BitStream -> Maybe BitStream
encode_locals (Locals count val_type) s =
  encode_val_type val_type $ encode_uleb128 count s

decode_locals :: BitStream -> Maybe (Tuple Locals BitStream)
decode_locals s = do
  Tuple val_type s' <- decode_val_type s
  Tuple count s'' <- decode_uleb128 s'
  Just (Tuple (Locals count val_type) s'')

encode_heap_type :: HeapType -> BitStream -> Maybe BitStream
encode_heap_type HeapTypeNoFunc s = Just $ write_u8 0x73 s
encode_heap_type HeapTypeNoExtern s = Just $ write_u8 0x72 s
encode_heap_type HeapTypeNone s = Just $ write_u8 0x71 s
encode_heap_type HeapTypeFunc s = Just $ write_u8 0x70 s
encode_heap_type HeapTypeExtern s = Just $ write_u8 0x6F s
encode_heap_type HeapTypeAny s = Just $ write_u8 0x6E s
encode_heap_type HeapTypeEq s = Just $ write_u8 0x6D s
encode_heap_type HeapTypeI31 s = Just $ write_u8 0x6C s
encode_heap_type HeapTypeStruct s = Just $ write_u8 0x6B s
encode_heap_type HeapTypeArray s = Just $ write_u8 0x6A s
encode_heap_type (HeapTypeIndex (TypeIndex i)) s = Just $ encode_sleb128 i s
encode_heap_type _ _ = Nothing

decode_heap_type :: BitStream -> Maybe (Tuple HeapType BitStream)
decode_heap_type s = case read_u8 s of
  Just (Tuple 0x73 s') -> Just $ Tuple HeapTypeNoFunc s'
  Just (Tuple 0x72 s') -> Just $ Tuple HeapTypeNoExtern s'
  Just (Tuple 0x71 s') -> Just $ Tuple HeapTypeNone s'
  Just (Tuple 0x70 s') -> Just $ Tuple HeapTypeFunc s'
  Just (Tuple 0x6F s') -> Just $ Tuple HeapTypeExtern s'
  Just (Tuple 0x6E s') -> Just $ Tuple HeapTypeAny s'
  Just (Tuple 0x6D s') -> Just $ Tuple HeapTypeEq s'
  Just (Tuple 0x6C s') -> Just $ Tuple HeapTypeI31 s'
  Just (Tuple 0x6B s') -> Just $ Tuple HeapTypeStruct s'
  Just (Tuple 0x6A s') -> Just $ Tuple HeapTypeArray s'
  _ -> case decode_sleb128 s of
    Just (Tuple index s') | index >= 0 -> Just $ Tuple (HeapTypeIndex (TypeIndex index)) s'
    _ -> Nothing

encode_ref_type :: RefType -> BitStream -> Maybe BitStream
encode_ref_type RefTypeNoFunc s = Just $ write_u8 0x73 s
encode_ref_type (RefType HeapTypeNoFunc true) s = Just $ write_u8 0x73 s
encode_ref_type RefTypeNoExtern s = Just $ write_u8 0x72 s
encode_ref_type (RefType HeapTypeNoExtern true) s = Just $ write_u8 0x72 s
encode_ref_type RefTypeNone s = Just $ write_u8 0x71 s
encode_ref_type (RefType HeapTypeNone true) s = Just $ write_u8 0x71 s
encode_ref_type RefTypeFunc s = Just $ write_u8 0x70 s
encode_ref_type (RefType HeapTypeFunc true) s = Just $ write_u8 0x70 s
encode_ref_type RefTypeExtern s = Just $ write_u8 0x6F s
encode_ref_type (RefType HeapTypeExtern true) s = Just $ write_u8 0x6F s
encode_ref_type RefTypeAny s = Just $ write_u8 0x6E s
encode_ref_type (RefType HeapTypeAny true) s = Just $ write_u8 0x6E s
encode_ref_type RefTypeEq s = Just $ write_u8 0x6D s
encode_ref_type (RefType HeapTypeEq true) s = Just $ write_u8 0x6D s
encode_ref_type RefTypeI31 s = Just $ write_u8 0x6C s
encode_ref_type (RefType HeapTypeI31 true) s = Just $ write_u8 0x6C s
encode_ref_type RefTypeStruct s = Just $ write_u8 0x6B s
encode_ref_type (RefType HeapTypeStruct true) s = Just $ write_u8 0x6B s
encode_ref_type RefTypeArray s = Just $ write_u8 0x6A s
encode_ref_type (RefType HeapTypeArray true) s = Just $ write_u8 0x6A s
-- general cases
encode_ref_type (RefType ht true) s = encode_heap_type ht $ write_u8 0x63 s
encode_ref_type (RefType ht false) s = encode_heap_type ht $ write_u8 0x64 s

decode_ref_type :: BitStream -> Maybe (Tuple RefType BitStream)
decode_ref_type s = case read_u8 s of
  Just (Tuple 0x73 s') -> Just $ Tuple RefTypeNoFunc s'
  Just (Tuple 0x72 s') -> Just $ Tuple RefTypeNoExtern s'
  Just (Tuple 0x71 s') -> Just $ Tuple RefTypeNone s'
  Just (Tuple 0x70 s') -> Just $ Tuple RefTypeFunc s'
  Just (Tuple 0x6F s') -> Just $ Tuple RefTypeExtern s'
  Just (Tuple 0x6E s') -> Just $ Tuple RefTypeAny s'
  Just (Tuple 0x6D s') -> Just $ Tuple RefTypeEq s'
  Just (Tuple 0x6C s') -> Just $ Tuple RefTypeI31 s'
  Just (Tuple 0x6B s') -> Just $ Tuple RefTypeStruct s'
  Just (Tuple 0x6A s') -> Just $ Tuple RefTypeArray s'
  Just (Tuple 0x63 s') -> case read_u8 s' of
    Just (Tuple 0x73 s'') -> Just $ Tuple RefTypeNoFunc s''
    Just (Tuple 0x72 s'') -> Just $ Tuple RefTypeNoExtern s''
    Just (Tuple 0x71 s'') -> Just $ Tuple RefTypeNone s''
    Just (Tuple 0x70 s'') -> Just $ Tuple RefTypeFunc s''
    Just (Tuple 0x6F s'') -> Just $ Tuple RefTypeExtern s''
    Just (Tuple 0x6E s'') -> Just $ Tuple RefTypeAny s''
    Just (Tuple 0x6D s'') -> Just $ Tuple RefTypeEq s''
    Just (Tuple 0x6C s'') -> Just $ Tuple RefTypeI31 s''
    Just (Tuple 0x6B s'') -> Just $ Tuple RefTypeStruct s''
    Just (Tuple 0x6A s'') -> Just $ Tuple RefTypeArray s''
    _ -> do
      Tuple ht s'' <- decode_heap_type s'
      case ht of
        HeapTypeNoFunc -> Just $ Tuple RefTypeNoFunc s''
        HeapTypeNoExtern -> Just $ Tuple RefTypeNoExtern s''
        HeapTypeNone -> Just $ Tuple RefTypeNone s''
        HeapTypeFunc -> Just $ Tuple RefTypeFunc s''
        HeapTypeExtern -> Just $ Tuple RefTypeExtern s''
        HeapTypeAny -> Just $ Tuple RefTypeAny s''
        HeapTypeEq -> Just $ Tuple RefTypeEq s''
        HeapTypeI31 -> Just $ Tuple RefTypeI31 s''
        HeapTypeStruct -> Just $ Tuple RefTypeStruct s''
        HeapTypeArray -> Just $ Tuple RefTypeArray s''
        _ -> Just $ Tuple (RefType ht true) s''
  Just (Tuple 0x64 s') -> do
    Tuple ht s'' <- decode_heap_type s'
    Just $ Tuple (RefType ht false) s''
  _ -> Nothing

decode_val_type :: BitStream -> Maybe (Tuple ValType BitStream)
decode_val_type s = case read_u8 s of
  Just (Tuple 0x7F s') -> Just $ Tuple ValTypeI32 s'
  Just (Tuple 0x7E s') -> Just $ Tuple ValTypeI64 s'
  Just (Tuple 0x7D s') -> Just $ Tuple ValTypeF32 s'
  Just (Tuple 0x7C s') -> Just $ Tuple ValTypeF64 s'
  Just (Tuple 0x7B s') -> Just $ Tuple ValTypeV128 s'
  _ -> do
    Tuple rt s' <- decode_ref_type s
    Just $ Tuple (ValTypeRefType rt) s'

encode_val_type :: ValType -> BitStream -> Maybe BitStream
encode_val_type ValTypeI32 s = Just $ write_u8 0x7F s
encode_val_type ValTypeI64 s = Just $ write_u8 0x7E s
encode_val_type ValTypeF32 s = Just $ write_u8 0x7D s
encode_val_type ValTypeF64 s = Just $ write_u8 0x7C s
encode_val_type ValTypeV128 s = Just $ write_u8 0x7B s
encode_val_type (ValTypeRefType rt) s = encode_ref_type rt s
encode_val_type _ _ = Nothing

