module Dewdrop.Types where

import Prelude

import Data.FingerTree (FingerTree, snoc)
import Data.List (List(..))
import Data.Map (Map, lookup)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Set (Set)
import Data.Set as Set
import Data.Tuple (Tuple(..))
import Record (merge)
import Visitor.Pattern (class Pass, class Visitable, ignore, visit, visit_all)

data Token = Token TokenKind Int

data TokenKind
  = TokenKindPubKeyword
  | TokenKindFnKeyword
  | TokenKindWhenKeyword
  | TokenKindElseKeyword
  | TokenKindNameIdentifier String
  | TokenKindTypeIdentifier String
  | TokenKindInt Int
  | TokenKindLParen
  | TokenKindRParen
  | TokenKindLBrace
  | TokenKindRBrace
  | TokenKindEqualsEquals
  | TokenKindAsterisk
  | TokenKindFSlash
  | TokenKindPlus
  | TokenKindMinus
  | TokenKindComma
  | TokenKindColon
  | TokenKindRArrow
  | TokenKindGreaterThan
  | TokenKindGreaterThanOrEqual
  | TokenKindLessThan
  | TokenKindLessThanOrEqual
  | TokenKindWhiteSpace
  | TokenKindNewLine
  | TokenKindUnknown String
  | TokenKindEOF

instance show_token_kind :: Show TokenKind where
  show TokenKindPubKeyword = "TokenKindPubKeyword"
  show TokenKindFnKeyword = "TokenKindFnKeyword"
  show TokenKindWhenKeyword = "TokenKindWhenKeyword"
  show TokenKindElseKeyword = "TokenKindElseKeyword"
  show (TokenKindNameIdentifier name) = "(TokenKindNameIdentifier " <> name <> ")"
  show (TokenKindTypeIdentifier name) = "(TokenKindTypeIdentifier " <> name <> ")"
  show (TokenKindInt value) = "(TokenKindInt " <> show value <> ")"
  show TokenKindLParen = "TokenKindLParen"
  show TokenKindRParen = "TokenKindRParen"
  show TokenKindLBrace = "TokenKindLBrace"
  show TokenKindRBrace = "TokenKindRBrace"
  show TokenKindEqualsEquals = "TokenKindEqualsEquals"
  show TokenKindPlus = "TokenKindPlus"
  show TokenKindMinus = "TokenKindMinus"
  show TokenKindAsterisk = "TokenKindAsterisk"
  show TokenKindFSlash = "TokenKindFSlash"
  show TokenKindComma = "TokenKindComma"
  show TokenKindColon = "TokenKindColon"
  show TokenKindRArrow = "TokenKindRArrow"
  show TokenKindGreaterThan = "TokenKindGreaterThan"
  show TokenKindGreaterThanOrEqual = "TokenKindGreaterThanOrEqual"
  show TokenKindLessThan = "TokenKindLessThan"
  show TokenKindLessThanOrEqual = "TokenKindLessThanOrEqual"
  show TokenKindEOF = "TokenKindEOF"
  show TokenKindWhiteSpace = "TokenKindWhiteSpace"
  show TokenKindNewLine = "TokenKindNewLine"
  show (TokenKindUnknown value) = "(TokenKindUnknown " <> value <> ")"

derive instance equals :: Eq TokenKind

instance show :: Show Token where
  show (Token kind pos) = "(Token " <> show kind <> ": " <> show pos <> ")"

derive instance eq :: Eq Token

data Identifier
  = NameIdentifier String
  | TypeIdentifier String

instance eq_identifier :: Eq Identifier where
  eq (NameIdentifier name) (NameIdentifier name') = name == name'
  eq (TypeIdentifier type_name) (TypeIdentifier type_name') = type_name == type_name'
  eq _ _ = false

instance ord_identifier :: Ord Identifier where
  compare (NameIdentifier name) (NameIdentifier name') = compare name name'
  compare (TypeIdentifier type_name) (TypeIdentifier type_name') = compare type_name type_name'
  compare (NameIdentifier _) _ = GT
  compare _ (NameIdentifier _) = LT

data Module = Module (Array ModuleDeclaration)

data ModuleDeclaration = ModuleDeclaration ModuleDeclarationKind Int

data ModuleDeclarationKind = FnDeclarationKind Boolean Identifier ModuleFn

data ModuleFn = ModuleFn (Maybe String) (Array FnParam) (Maybe TypeExpr) Expr

data FnParam = FnParam String (Maybe TypeExpr) Int

data TypeExpr = TypeExpr TypeExprKind Int

data TypeExprKind = NamedTypeExpr String

data Expr = Expr ExprKind Int

data ExprKind
  = WhenExpr (Array WhenArm) (Maybe Expr)
  | BlockExpr (Array Expr)
  | EqualsExpr Expr Expr
  | IntExpr Int
  | NameExpr String
  | CallExpr Expr (Array Expr)
  | AddExpr Expr Expr
  | SubExpr Expr Expr
  | MulExpr Expr Expr
  | DivExpr Expr Expr
  | GreaterThanExpr Expr Expr
  | LessThanExpr Expr Expr
  | GreaterThanEqualsExpr Expr Expr
  | LessThanEqualsExpr Expr Expr

data Bounds = Bounds (FingerTree ProgramType) (FingerTree ProgramType)

type TypedIRFnContext =
  { name :: ModuleElementReference

  , env :: FingerTree (Tuple Identifier Int)
  , parameters :: FingerTree (Tuple Identifier Int)
  , return_type :: ProgramType

  -- To keep track of type variables
  , next_type_id :: Int
  , types :: Map Int Bounds

  -- To keep track of expressions and what types they have
  , exprs :: Map Int Expr
  
  -- to index ir nodes
  , next_ir_id :: Int
  , irs :: Map Int TypedIR

  , body :: FingerTree TypedIR
  }

typed_ir_fn_context_new :: ModuleElementReference -> TypedIRFnContext
typed_ir_fn_context_new name = do
  let return_type = ProgramType (TypeVar 0) Nothing

  { name
  , env: mempty
  , parameters: mempty
  , return_type
  , next_type_id: 1
  , types: Map.fromFoldable [Tuple 0 $ Bounds mempty mempty]
  , exprs: Map.empty
  , next_ir_id: 0
  , irs: Map.empty
  , body: mempty
  }


type_var_new :: TypedIRFnContext -> Tuple Int TypedIRFnContext
type_var_new ctx@{ next_type_id, types } = do
  let i = next_type_id
  let next_type_id' = next_type_id + 1
  let types' = Map.insert i (Bounds mempty mempty) types

  Tuple i $ merge { next_type_id: next_type_id', types: types' } ctx

data TypedIR = TypedIR TypedIRKind Int ProgramType

type IntValue = Int

data TypedIRKind
  = TypedIRAdd Int Int
  | TypedIRSub Int Int
  | TypedIRMul Int Int
  | TypedIRDiv Int Int
  | TypedIRGreaterThan Int Int
  | TypedIRLessThan Int Int
  | TypedIRGreaterThanEquals Int Int
  | TypedIRLessThanEquals Int Int
  | TypedIREquals Int Int
  | TypedIRInt Int IntValue
  | TypedIRBindName String Int
  | TypedIRFn Int
  | TypedIRCall Int (FingerTree Int)
  | TypedIRBlock (FingerTree TypedIR)
  | TypedIRWhen (FingerTree (Tuple Int Int)) (Maybe Int)

data WhenArm = WhenArm Expr Expr

type ParserResult t = Maybe (Tuple t Int)

type Parser t = Array Token -> Int -> ParserResult t

data ProgramType = ProgramType ProgramTypeKind (Maybe ModuleElementReference)
data ProgramTypeKind
  -- Functions
  = FnType (FingerTree ProgramType) ProgramType

  -- Records
  | RecordType (FingerTree (Tuple Identifier ProgramType))

  -- Nominals
  | EnumType (ModuleElementReference) (FingerTree (Tuple Identifier ProgramType)) (FingerTree VariantKind)

  -- Numbers
  | I8
  | U8
  | I16
  | U16
  | I32
  | U32
  | I64
  | U64
  | F32
  | F64
  | Integer
  | Float
  | Numeric

  -- Other Primitives
  | String
  | Bool

  -- Type helpers
  | Top
  | Bottom

  -- Type variables
  | TypeVar Int

  -- Constraints
  | Union ProgramType ProgramType
  | Intersection ProgramType ProgramType

  -- Recursive types
  | Recursive ProgramType

data VariantKind = VariantKind Identifier (FingerTree ProgramType)

data Export = ExportKindFn ModuleFn

builtin_i8_type :: ProgramType
builtin_i8_type = (ProgramType I8 Nothing)

builtin_u8_type :: ProgramType
builtin_u8_type = (ProgramType U8 Nothing)

builtin_i16_type :: ProgramType
builtin_i16_type = (ProgramType I16 Nothing)

builtin_u16_type :: ProgramType
builtin_u16_type = (ProgramType U16 Nothing)

builtin_i32_type :: ProgramType
builtin_i32_type = (ProgramType I32 Nothing)

builtin_u32_type :: ProgramType
builtin_u32_type = (ProgramType U32 Nothing)

builtin_i64_type :: ProgramType
builtin_i64_type = (ProgramType I64 Nothing)

builtin_u64_type :: ProgramType
builtin_u64_type = (ProgramType U64 Nothing)

builtin_f32_type :: ProgramType
builtin_f32_type = (ProgramType F32 Nothing)

builtin_f64_type :: ProgramType
builtin_f64_type = (ProgramType F64 Nothing)

builtin_integer_type :: ProgramType
builtin_integer_type = (ProgramType Integer Nothing)

builtin_float_type :: ProgramType
builtin_float_type = (ProgramType Float Nothing)

builtin_string_type :: ProgramType
builtin_string_type = (ProgramType String Nothing)

builtin_bool_type :: ProgramType
builtin_bool_type = (ProgramType Bool Nothing)

builtin_numeric_type :: ProgramType
builtin_numeric_type = (ProgramType Numeric Nothing)

type_var :: Int -> Maybe ModuleElementReference -> ProgramType
type_var i mr = (ProgramType (TypeVar i) mr)

type TypeIndex = Map Int ProgramType
type TypeEnv = Map Identifier ProgramType
type TypeResolver = Map Identifier ProgramType


instance show_expr :: Show Expr where
  show (Expr kind _) = "(Expr " <> show kind <> ")"

instance show_expr_kind :: Show ExprKind where
  show (WhenExpr arms default_expr) = "(WhenExpr " <> show arms <> " " <> show default_expr <> ")"
  show (EqualsExpr left right) = "(EqualsExpr " <> show left <> " " <> show right <> ")"
  show (IntExpr value) = "(IntExpr " <> show value <> ")"
  show (NameExpr name) = "(NameExpr " <> name <> ")"
  show (CallExpr expr args) = "(CallExpr " <> show expr <> " " <> show args <> ")"
  show (AddExpr left right) = "(AddExpr " <> show left <> " " <> show right <> ")"
  show (SubExpr left right) = "(SubExpr " <> show left <> " " <> show right <> ")"
  show (MulExpr left right) = "(MulExpr " <> show left <> " " <> show right <> ")"
  show (DivExpr left right) = "(DivExpr " <> show left <> " " <> show right <> ")"
  show (GreaterThanExpr left right) = "(GreaterThanExpr " <> show left <> " " <> show right <> ")"
  show (LessThanExpr left right) = "(LessThanExpr " <> show left <> " " <> show right <> ")"
  show (GreaterThanEqualsExpr left right) = "(GreaterThanEqualsExpr " <> show left <> " " <> show right <> ")"
  show (LessThanEqualsExpr left right) = "(LessThanEqualsExpr " <> show left <> " " <> show right <> ")"
  show (BlockExpr exprs) = "(BlockExpr " <> show exprs <> ")"

instance show_when_arm :: Show WhenArm where
  show (WhenArm condition expr) = "(WhenArm " <> show condition <> " " <> show expr <> ")"

instance show_module :: Show Module where
  show (Module declarations) = "(Module " <> show declarations <> ")"

instance show_module_declaration :: Show ModuleDeclaration where
  show (ModuleDeclaration kind _) = "(ModuleDeclaration " <> show kind <> ")"

instance show_module_declaration_kind :: Show ModuleDeclarationKind where
  show (FnDeclarationKind exported name fn) = "(FnDeclarationKind " <> show exported <> " " <> show name <> " " <> show fn <> ")"

instance show_identifier :: Show Identifier where
  show (NameIdentifier name) = "(Name " <> name <> ")"
  show (TypeIdentifier name) = "(Type " <> name <> ")"

instance show_fn :: Show ModuleFn where
  show (ModuleFn name args return_type expr) = "(ModuleFn " <> show name <> " " <> show args <> " " <> show return_type <> " " <> show expr <> ")"

instance show_fn_param :: Show FnParam where
  show (FnParam name type_expr _) = "(FnParam " <> name <> " " <> show type_expr <> ")"

instance show_type_expr :: Show TypeExpr where
  show (TypeExpr kind _) = "(TypeExpr " <> show kind <> ")"

instance show_type_expr_kind :: Show TypeExprKind where
  show (NamedTypeExpr name) = "(NamedTypeExpr " <> name <> ")"

-- data Module = Module (Array ModuleDeclaration)
instance visitable_module ::
  ( Pass ModuleDeclaration ctx
  , Pass ModuleDeclarationKind ctx
  , Pass ModuleFn ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable Module ctx where
  visit_children (Module declarations) ctx = do
    Tuple ctx' children <- visit_all declarations ctx
    Just $ Tuple ctx' (Module children)

instance visitable_module_declaration ::
  ( Pass ModuleDeclarationKind ctx
  , Pass ModuleFn ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ModuleDeclaration ctx where
  visit_children (ModuleDeclaration kind n) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' (ModuleDeclaration kind' n)

instance visitable_module_declaration_kind ::
  ( Pass ModuleFn ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ModuleDeclarationKind ctx where
  visit_children (FnDeclarationKind exported name fn) ctx = do
    Tuple ctx' fn' <- visit fn ctx
    Just $ Tuple ctx' (FnDeclarationKind exported name fn')

instance visitable_module_fn ::
  ( Pass Expr ctx
  , Pass FnParam ctx
  , Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  , Pass Expr ctx
  , Pass ExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ModuleFn ctx where
  visit_children (ModuleFn name args return_type expr) ctx = do
    Tuple ctx' args' <- visit_all args ctx
    Tuple ctx'' expr' <- visit expr ctx'
    Just $ Tuple ctx'' (ModuleFn name args' return_type expr')

instance visitable_fn_param ::
  ( Pass TypeExpr ctx
  , Pass TypeExprKind ctx
  ) =>
  Visitable FnParam ctx where
  visit_children (FnParam name type_guard n) ctx = do
    Tuple ctx' type_guard' <- visit type_guard ctx
    Just $ Tuple ctx' (FnParam name type_guard' n)

skip_children :: ∀ (@over :: Type) (@ctx :: Type). Pass over ctx => over -> ctx -> Maybe (Tuple ctx over)
skip_children over ctx = Just $ Tuple ctx over

instance visitable_type_expr :: (Pass TypeExprKind ctx) => Visitable TypeExpr ctx where
  visit_children = skip_children

instance visitable_type_expr_kind :: Visitable TypeExprKind ctx where
  visit_children = skip_children

instance visitable_expr ::
  ( Pass Expr ctx
  , Pass ExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable Expr ctx where
  visit_children (Expr kind n) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' $ Expr kind' n

instance visitable_expr_kind ::
  ( Pass ExprKind ctx
  , Pass Expr ctx
  , Pass WhenArm ctx
  ) =>
  Visitable ExprKind ctx where
  visit_children (WhenExpr arms maybe_else) ctx = do
    Tuple ctx' arms' <- visit_all arms ctx
    Tuple ctx'' maybe_else' <- visit maybe_else ctx'
    Just $ Tuple ctx'' $ WhenExpr arms' maybe_else'

  visit_children (BlockExpr body) ctx = do
    Tuple ctx' body' <- visit_all body ctx
    Just $ Tuple ctx' (BlockExpr body')

  visit_children (EqualsExpr l r) ctx = visit_binary EqualsExpr l r ctx
  visit_children (AddExpr l r) ctx = visit_binary AddExpr l r ctx
  visit_children (SubExpr l r) ctx = visit_binary SubExpr l r ctx
  visit_children (MulExpr l r) ctx = visit_binary MulExpr l r ctx
  visit_children (DivExpr l r) ctx = visit_binary DivExpr l r ctx
  visit_children (GreaterThanExpr l r) ctx = visit_binary GreaterThanExpr l r ctx
  visit_children (LessThanExpr l r) ctx = visit_binary LessThanExpr l r ctx
  visit_children (GreaterThanEqualsExpr l r) ctx = visit_binary GreaterThanEqualsExpr l r ctx
  visit_children (LessThanEqualsExpr l r) ctx = visit_binary LessThanEqualsExpr l r ctx
  visit_children (CallExpr callee args) ctx = do
    Tuple ctx' callee' <- visit callee ctx
    Tuple ctx'' args' <- visit_all args ctx'
    Just $ Tuple ctx'' $ CallExpr callee' args'
  visit_children n ctx = Just $ Tuple ctx n

visit_binary
  :: ∀ (@ctx :: Type)
   . Pass ExprKind ctx
  => Pass Expr ctx
  => Pass WhenArm ctx
  => (Expr -> Expr -> ExprKind)
  -> Expr
  -> Expr
  -> ctx
  -> Maybe (Tuple ctx ExprKind)
visit_binary kind l r ctx = do
  Tuple inner_ctx l' <- visit l ctx
  Tuple inner_ctx' r' <- visit r inner_ctx
  Just $ Tuple inner_ctx' $ kind l' r'

instance visitable_when_arm ::
  ( Pass Expr ctx
  , Pass ExprKind ctx
  , Pass WhenArm ctx
  ) =>
  Visitable WhenArm ctx where
  visit_children (WhenArm condition body) ctx = do
    Tuple inner_ctx condition' <- visit condition ctx
    Tuple inner_ctx' body' <- visit body inner_ctx
    Just $ Tuple inner_ctx' (WhenArm condition' body')

data CompileTarget
  = Wasm32
  | Wasm64
  | Wasm32Browser
  | Wasm64Browser
  | Wasm32Node
  | Wasm64Node
  | Wasm32Bun
  | Wasm64Bun
  | Wasm32Deno
  | Wasm64Deno
  | Wasm32NodeWorker
  | Wasm64NodeWorker
  | Wasm32BunWorker
  | Wasm64BunWorker
  | Wasm32DenoWorker
  | Wasm64DenoWorker
  | Lunatic
  | Wasm32Wasi
  | Wasm64Wasi

data BinaryenPass
  = AbstractTypeRefiningPass
  | AlignmentLoweringPass
  | AsyncifyPass
  | AvoidReinterpretsPass
  | CoalesceLocalsPass
  | CoalesceLocalsWithLearningPass
  | CodeFoldingPass
  | CodePushingPass
  | ConstHoistingPass
  | ConstantFieldPropagationPass
  | ConstantFieldPropagationRefTestPass
  | DAEPass
  | DAEOptimizingPass
  | DataFlowOptsPass
  | DeadCodeEliminationPass
  | DeNaNPass
  | DeAlignPass
  | DebugLocationPropagationPass
  | DirectizePass
  | DiscardGlobalEffectsPass
  | DWARFDumpPass
  | DuplicateImportEliminationPass
  | DuplicateFunctionEliminationPass
  | EmitTargetFeaturesPass
  | EncloseWorldPass
  | ExtractFunctionPass
  | ExtractFunctionIndexPass
  | FlattenPass
  | FuncCastEmulationPass
  | FullPrinterPass
  | FunctionMetricsPass
  | GenerateDynCallsPass
  | GenerateI64DynCallsPass
  | GenerateGlobalEffectsPass
  | GlobalRefiningPass
  | GlobalStructInferencePass
  | GlobalTypeOptimizationPass
  | GUFAPass
  | GUFACastAllPass
  | GUFAOptimizingPass
  | Heap2LocalPass
  | HeapStoreOptimizationPass
  | I64ToI32LoweringPass
  | InlineMainPass
  | InliningPass
  | InliningOptimizingPass
  | J2CLItableMergingPass
  | JSPIPass
  | J2CLOptsPass
  | LegalizeAndPruneJSInterfacePass
  | LegalizeJSInterfacePass
  | LimitSegmentsPass
  | LocalCSEPass
  | LocalSubtypingPass
  | LogExecutionPass
  | IntrinsicLoweringPass
  | TraceCallsPass
  | InstrumentLocalsPass
  | InstrumentMemoryPass
  | LLVMMemoryCopyFillLoweringPass
  | LoopInvariantCodeMotionPass
  | Memory64LoweringPass
  | MemoryPackingPass
  | MergeBlocksPass
  | MergeSimilarFunctionsPass
  | MergeLocalsPass
  | MinifiedPrinterPass
  | MinifyImportsPass
  | MinifyImportsAndExportsPass
  | MinifyImportsAndExportsAndModulesPass
  | MinimizeRecGroupsPass
  | MetricsPass
  | MonomorphizePass
  | MonomorphizeAlwaysPass
  | MultiMemoryLoweringPass
  | MultiMemoryLoweringWithBoundsChecksPass
  | NameListPass
  | NameTypesPass
  | NoInlinePass
  | NoFullInlinePass
  | NoPartialInlinePass
  | OnceReductionPass
  | OptimizeAddedConstantsPass
  | OptimizeAddedConstantsPropagatePass
  | OptimizeInstructionsPass
  | OptimizeCastsPass
  | OptimizeForJSPass
  | PickLoadSignsPass
  | ModAsyncifyAlwaysOnlyUnwindPass
  | ModAsyncifyNeverUnwindPass
  | LLVMNonTrappingFPToIntLoweringPass
  | PoppifyPass
  | PostEmscriptenPass
  | PrecomputePass
  | PrecomputePropagatePass
  | PrinterPass
  | PrintCallGraphPass
  | PrintFeaturesPass
  | PrintFunctionMapPass
  | PropagateGlobalsGloballyPass
  | RemoveNonJSOpsPass
  | RemoveImportsPass
  | RemoveMemoryInitPass
  | RemoveUnusedBrsPass
  | RemoveUnusedModuleElementsPass
  | RemoveUnusedNonFunctionModuleElementsPass
  | RemoveUnusedNamesPass
  | RemoveUnusedTypesPass
  | ReorderFunctionsByNamePass
  | ReorderFunctionsPass
  | ReorderGlobalsPass
  | ReorderGlobalsAlwaysPass
  | ReorderLocalsPass
  | ReReloopPass
  | RedundantSetEliminationPass
  | RoundTripPass
  | SafeHeapPass
  | SetGlobalsPass
  | SeparateDataSegmentsPass
  | SignaturePruningPass
  | SignatureRefiningPass
  | SignExtLoweringPass
  | SimplifyLocalsPass
  | SimplifyGlobalsPass
  | SimplifyGlobalsOptimizingPass
  | SimplifyLocalsNoNestingPass
  | SimplifyLocalsNoTeePass
  | SimplifyLocalsNoStructurePass
  | SimplifyLocalsNoTeeNoStructurePass
  | StackCheckPass
  | StringGatheringPass
  | StringLiftingPass
  | StringLoweringPass
  | StringLoweringMagicImportPass
  | StringLoweringMagicImportAssertPass
  | StripDebugPass
  | StripDWARFPass
  | StripProducersPass
  | StripTargetFeaturesPass
  | SouperifyPass
  | SouperifySingleUsePass
  | SpillPointersPass
  | StripEHPass
  | StubUnsupportedJSOpsPass
  | SSAifyPass
  | SSAifyNoMergePass
  | Table64LoweringPass
  | TranslateToExnrefPass
  | TrapModeClamp
  | TrapModeJS
  | TupleOptimizationPass
  | TypeGeneralizingPass
  | TypeRefiningPass
  | TypeFinalizingPass
  | TypeMergingPass
  | TypeSSAPass
  | TypeUnFinalizingPass
  | UnsubtypingPass
  | UnteePass
  | VacuumPass

data ResourceID = ResourceID Int
data ModuleID = ModuleID String (List String)

data ModuleElementReference = ModuleElementReference ModuleID Identifier

instance module_element_reference_ord :: Ord ModuleElementReference where
  compare (ModuleElementReference module_id identifier) (ModuleElementReference module_id' identifier') =
    compare module_id module_id' <> compare identifier identifier'

instance module_element_reference_eq :: Eq ModuleElementReference where
  eq (ModuleElementReference module_id identifier) (ModuleElementReference module_id' identifier') =
    module_id == module_id' && identifier == identifier'

instance module_id_ord :: Ord ModuleID where
  compare (ModuleID package_name path) (ModuleID package_name' path') =
    compare package_name package_name' <> compare path path'

instance module_id_eq :: Eq ModuleID where
  eq (ModuleID package_name path) (ModuleID package_name' path') =
    package_name == package_name' && path == path'

reference :: ModuleID -> Identifier -> ModuleElementReference
reference module_id identifier = ModuleElementReference module_id identifier

type System =
  { to_resource_id :: ModuleID -> Maybe ResourceID
  , get_resource :: ResourceID -> Maybe String
  , set_resource :: ResourceID -> String -> Maybe Unit
  }

type Program =
  { 
  }

program_new :: Program
program_new = {}

type ResourceMap = Map ModuleID ResourceID
type ModuleMap = Map ModuleID Module

type ModuleContext =
  { ast :: Module
  , exports :: Map Identifier ModuleElementReference
  , imports :: Map Identifier ModuleElementReference
  , module_id :: ModuleID
  , resource_id :: ResourceID
  }

module_context_new :: ModuleID -> ResourceID -> Module -> ModuleContext
module_context_new module_id resource_id ast =
  { ast: ast
  , exports: Map.empty
  , imports: Map.empty
  , module_id
  , resource_id
  }

type Compiler =
  { binaryen_passes :: FingerTree BinaryenPass
  , modules :: Map ModuleID ModuleContext
  , main_module :: ModuleID
  , program :: Program
  , resources :: ResourceMap
  , seen :: Set ModuleID
  , system :: System
  , target :: CompileTarget
  }

compiler_new :: String -> System -> CompileTarget -> Compiler
compiler_new package_name system target =
  { binaryen_passes: mempty
  , modules: Map.empty
  , main_module: ModuleID package_name Nil
  , program: program_new
  , resources: Map.empty
  , seen: Set.empty
  , system: system
  , target: target
  }

instance eq_program_type :: Eq ProgramType where
  eq (ProgramType kind _) (ProgramType kind' _) = kind == kind'

instance eq_program_type_kind :: Eq ProgramTypeKind where
  eq (FnType params ret) (FnType params' ret') = params == params' && ret == ret'
  eq n n' | n == n' = true
  eq _ _ = false

instance visitable_program_type ::
  ( Pass (Tuple Identifier ProgramType) ctx
  , Visitable (Tuple Identifier ProgramType) ctx
  , Pass ProgramTypeKind ctx
  , Visitable ProgramTypeKind ctx
  ) => Visitable ProgramType ctx where
  visit_children (ProgramType kind _) ctx = do
    Tuple ctx' kind' <- visit kind ctx
    Just $ Tuple ctx' (ProgramType kind' Nothing)

instance visitable_program_type_kind ::
  ( Pass ProgramType ctx
  , Visitable ProgramType ctx
  , Pass ProgramTypeKind ctx
  , Pass (Tuple Identifier ProgramType) ctx
  , Visitable (Tuple Identifier ProgramType) ctx
  , Pass Identifier ctx
  , Visitable Identifier ctx
  , Pass VariantKind ctx
  , Visitable VariantKind ctx
  ) => Visitable ProgramTypeKind ctx where
  visit_children (EnumType name env kinds) ctx = do
    Tuple ctx' env' <- visit_all env ctx
    Tuple ctx'' kinds' <- visit_all kinds ctx'
    Just $ Tuple ctx'' $ EnumType name env' kinds'

  visit_children (FnType parameters return_type) ctx = do
    Tuple ctx' parameters' <- visit_all parameters ctx
    Tuple ctx'' return_type' <- visit return_type ctx'
    Just $ Tuple ctx'' (FnType parameters' return_type')
  
  visit_children (RecordType fields) ctx = do
    Tuple ctx' fields' <- visit_all fields ctx
    Just $ Tuple ctx' $ RecordType fields' 

  visit_children (Union left right) ctx = do
    Tuple ctx' left' <- visit left ctx
    Tuple ctx'' right' <- visit right ctx'
    Just $ Tuple ctx'' $ Union left' right'

  visit_children (Intersection left right) ctx = do
    Tuple ctx' left' <- visit left ctx
    Tuple ctx'' right' <- visit right ctx'
    Just $ Tuple ctx'' $ Intersection left' right'
  
  visit_children (Recursive t) ctx = do
    Tuple ctx' t' <- visit t ctx
    Just $ Tuple ctx' $ Recursive t'

  visit_children n ctx = Just $ Tuple ctx n

instance visitable_identifier :: (Pass Identifier ctx) => Visitable Identifier ctx where
  visit_children n ctx = Just $ Tuple ctx n

instance pass_identifier :: Pass Identifier ctx where
  enter = ignore
  exit = ignore


instance visitable_variant_type ::
  ( Pass Identifier ctx
  , Visitable Identifier ctx
  , Pass Identifier ctx
  , Visitable VariantKind ctx
  , Pass VariantKind ctx
  , Visitable (Tuple Identifier ProgramType) ctx
  , Pass (Tuple Identifier ProgramType) ctx
  , Visitable ProgramType ctx
  , Pass ProgramType ctx
  , Visitable ProgramTypeKind ctx
  , Pass ProgramTypeKind ctx
  ) => Visitable VariantKind ctx where
  visit_children (VariantKind name fields) ctx = do
    Tuple ctx' name' <- visit name ctx
    Tuple ctx'' fields' <- visit_all fields ctx'
    Just $ Tuple ctx'' $ VariantKind name' fields'

