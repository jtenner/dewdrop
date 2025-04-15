module Data.Dewdrop.Compiler where

import Prelude

import Data.Array (unsnoc)
import Data.ArrayBuffer.Types (Uint8Array)
import Data.Dewdrop.AST (Module, ModulePath)
import Data.Dewdrop.Identifier (Identifier)
import Data.Dewdrop.Program (Program, program_new)
import Data.Dewdrop.System.System (class System, RawResourceID(..))
import Data.FingerTree (FingerTree)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..))

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


data ModuleElementReference = ModuleElementReference ModulePath Identifier

instance module_element_reference_ord :: Ord ModuleElementReference where
  compare (ModuleElementReference module_id identifier) (ModuleElementReference module_id' identifier') =
    compare module_id module_id' <> compare identifier identifier'

instance module_element_reference_eq :: Eq ModuleElementReference where
  eq (ModuleElementReference module_id identifier) (ModuleElementReference module_id' identifier') =
    module_id == module_id' && identifier == identifier'

reference :: ModulePath -> Identifier -> ModuleElementReference
reference module_id identifier = ModuleElementReference module_id identifier

data ModuleContext = ModuleContext
  { ast :: Module
  , exports :: Map Identifier ModuleElementReference
  }

module_context_new :: Module -> ModuleContext
module_context_new ast = ModuleContext
  { ast: ast
  , exports: Map.empty
  }


data ModuleID = ModuleID
  { package_name :: String
  , path :: Array String
  }

instance ord_module_id :: Ord ModuleID where
  compare (ModuleID { package_name, path }) (ModuleID { package_name: package_name', path: path' }) =
    compare package_name package_name' <> compare path path'

derive instance eq_module_id :: Eq ModuleID

type PackageName = String

data Compiler system_ctx = Compiler
  { binary_resources :: Map RawResourceID Uint8Array
  , main_module :: ModuleID
  , modules :: Map ModuleID ModuleContext
  , package_name :: PackageName
  , program :: Program
  , system_ctx :: system_ctx
  , target :: CompileTarget
  , binaryen_passes :: FingerTree BinaryenPass
  }

to_resource_id :: ModuleID -> PackageName -> RawResourceID
to_resource_id (ModuleID { package_name, path }) root_package_name = do
  let
    root = if root_package_name == package_name then [ "src" ] else [ "packages", root_package_name, "src" ]
    resource_path = case unsnoc path of
      Nothing -> [ "main.dew" ]
      Just { init, last } -> init <> (pure $ last <> ".dew")

  RawResourceID { path: root <> resource_path }

compiler_new :: ∀ (@system_ctx :: Type). System system_ctx => String -> CompileTarget -> system_ctx -> Compiler system_ctx
compiler_new package_name target system_ctx = Compiler
  { binary_resources: Map.empty
  , main_module: ModuleID { package_name, path: [] }
  , modules: Map.empty
  , package_name
  , program: program_new
  , system_ctx
  , target: target
  , binaryen_passes: mempty
  }