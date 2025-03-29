module Program where

import Prelude

import Data.List (List(..))
import Data.Maybe (Maybe(..))

type CompilerOptions =
  { compile_target :: CompileTarget
  , optimization :: List Pass
  }

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

data Pass
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

data ModuleID = ModuleID (Maybe String) (List String)

type System =
  { to_resource_id :: ModuleID -> Maybe Int
  , get_resource :: Int -> Maybe String
  , set_resource :: Int -> String -> Maybe Unit
  , compiler_options :: CompilerOptions
  }

main_module_id :: ModuleID
main_module_id = ModuleID Nothing Nil

