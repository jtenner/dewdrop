///|
pub enum CompilerDiagnosticSeverity {
  CompilerError
  CompilerWarning
} derive(Eq, Debug)

///|
pub struct CompilerDiagnosticLabel {
  location : SourceLocation
  message : String
} derive(Eq, Debug)

///|
pub struct CompilerSourceDiagnostic {
  severity : CompilerDiagnosticSeverity
  message : String
  primary : SourceLocation
  has_primary : Bool
  secondary : Array[CompilerDiagnosticLabel]
  module_order : Int
  file_order : Int
  rank : Int
} derive(Eq, Debug)

///|
pub struct SourceLineColumn {
  line : Int
  column : Int
  line_start : Int
  line_end : Int
} derive(Eq, Debug)

///|
fn CollectedProgram::module_order_for_id(
  self : CollectedProgram,
  module_id : ModuleId,
) -> Int {
  for index, module_ in self.modules {
    if module_.module_id == module_id {
      return index
    }
  }
  self.modules.length()
}

///|
pub fn CollectedProgram::module_for_id(
  self : CollectedProgram,
  module_id : ModuleId,
) -> CollectedModule? {
  let order = self.module_order_for_id(module_id)
  if order < self.modules.length() {
    Some(self.modules[order])
  } else {
    None
  }
}

///|
pub fn CollectedProgram::source_file(
  self : CollectedProgram,
  file : FileId,
) -> ProgramFile? {
  match self.module_for_id(file_id_module(file)) {
    Some(module_) => module_.source_file(file)
    None => None
  }
}

///|
fn CollectedProgram::source_order(
  self : CollectedProgram,
  location : SourceLocation,
) -> (Int, Int) {
  let module_order = self.module_order_for_id(file_id_module(location.file))
  if module_order >= self.modules.length() {
    return (module_order, 0)
  }
  let module_ = self.modules[module_order]
  for file_order, file in module_.files {
    if file == location.file {
      return (module_order, file_order)
    }
  }
  (module_order, module_.files.length())
}

///|
pub fn ProgramFile::line_column(
  self : ProgramFile,
  offset : UInt64,
) -> SourceLineColumn {
  let mut target = offset.to_int()
  if target < 0 {
    target = 0
  } else if target > self.source.length() {
    target = self.source.length()
  }
  let mut line = 1
  let mut line_start = 0
  for index in 0..<target {
    if self.source[index] == b'\n' {
      line += 1
      line_start = index + 1
    }
  }
  let mut line_end = target
  while line_end < self.source.length() && self.source[line_end] != b'\n' {
    line_end += 1
  }
  if line_end > line_start && self.source[line_end - 1] == b'\r' {
    line_end -= 1
  }
  { line, column: target - line_start + 1, line_start, line_end, }
}

///|
fn compiler_diagnostic(
  program : CollectedProgram,
  severity : CompilerDiagnosticSeverity,
  message : String,
  primary : SourceLocation?,
  secondary : Array[CompilerDiagnosticLabel],
  rank : Int,
) -> CompilerSourceDiagnostic {
  match primary {
    Some(location) => {
      let (module_order, file_order) = program.source_order(location)
      {
        severity,
        message,
        primary: location,
        has_primary: true,
        secondary,
        module_order,
        file_order,
        rank,
      }
    }
    None =>
      {
        severity,
        message,
        primary: { file: 0UL, offset: 0UL, },
        has_primary: false,
        secondary,
        module_order: -1,
        file_order: -1,
        rank,
      }
  }
}

///|
fn location_at(base : SourceLocation?, offset : UInt64) -> SourceLocation? {
  match base {
    Some(location) => Some({ file: location.file, offset, })
    None => None
  }
}

///|
fn CollectedModule::default_location(
  self : CollectedModule,
  offset : UInt64,
) -> SourceLocation? {
  if self.files.length() == 0 {
    None
  } else {
    Some({ file: self.files[0], offset, })
  }
}

///|
fn CollectedModule::module_offset_location(
  self : CollectedModule,
  offset : UInt64,
) -> SourceLocation? {
  for index, expression in self.expressions {
    if expression.offset() == offset {
      return Some({ file: self.expression_files[index], offset, })
    }
  }
  for index, pattern in self.patterns {
    if pattern.offset() == offset {
      return Some({ file: self.pattern_files[index], offset, })
    }
  }
  self.default_location(offset)
}

///|
fn CollectionDiagnostic::source_parts(
  self : CollectionDiagnostic,
) -> (
  CompilerDiagnosticSeverity,
  SourceLocation?,
  Array[CompilerDiagnosticLabel],
) {
  let secondary : Array[CompilerDiagnosticLabel] = []
  match self {
    ParseDiagnostic(file, diagnostic) => {
      let severity = match diagnostic.severity {
        @parser.Error => CompilerError
        @parser.Warning | @parser.Info | @parser.Hint => CompilerWarning
      }
      (severity, Some({ file, offset: diagnostic.error.offset(), }), secondary)
    }
    DuplicateName(value) => {
      secondary.push({
        location: { file: value.first_file, offset: value.first_offset, },
        message: "first declaration is here",
      })
      (
        CompilerError,
        Some({ file: value.duplicate_file, offset: value.duplicate_offset, }),
        secondary,
      )
    }
    DuplicateTestIdentity(value) => {
      secondary.push({
        location: { file: value.file, offset: value.first_offset, },
        message: "first test with this identity is here",
      })
      (
        CompilerError,
        Some({ file: value.file, offset: value.duplicate_offset, }),
        secondary,
      )
    }
    DuplicateDerivedTrait(_, file, first_offset, duplicate_offset) => {
      secondary.push({
        location: { file, offset: first_offset, },
        message: "first derive request is here",
      })
      (CompilerError, Some({ file, offset: duplicate_offset, }), secondary)
    }
    InvalidExpectedTestTrap(file, _, offset)
    | InvalidUtf8StringLiteral(file, offset)
    | TestDeclarationOutsideTestFile(file, offset)
    | UnknownDerivedTrait(_, file, offset)
    | EmptyForeignLogicalName(file, offset)
    | InvalidUtf8ForeignLogicalName(file, offset)
    | EmptyForeignExportName(file, offset)
    | InvalidUtf8ForeignExportName(file, offset) =>
      (CompilerError, Some({ file, offset, }), secondary)
  }
}

///|
fn TypeDiagnostic::primary_location(
  self : TypeDiagnostic,
  module_ : CollectedModule,
  resolved : ResolvedModuleTypes,
) -> SourceLocation? {
  let declaration = match self {
    ReservedTypeName(value, _, _)
    | UnknownType(_, value, _)
    | UnknownTrait(_, value, _)
    | AmbiguousImportedType(_, value, _)
    | AmbiguousImportedTrait(_, value, _)
    | ExpectedTraitType(_, value, _)
    | TypeArityMismatch(_, _, _, value, _)
    | TypeNotApplicable(_, value, _)
    | NullableRefRequiresForeignType(_, value, _)
    | SelfOutsideContext(value, _)
    | AliasExpansionLimit(value, _, _) => value
    AliasCycle(span, _) =>
      if span.length > 0 &&
        span.start >= 0 &&
        span.start < resolved.alias_cycle_declarations.length() {
        resolved.alias_cycle_declarations[span.start]
      } else {
        0UL
      }
  }
  location_at(module_.declaration_location(declaration), self.offset())
}

///|
fn BodyResolutionDiagnostic::primary_location(
  self : BodyResolutionDiagnostic,
  module_ : CollectedModule,
  fallback_file : FileId,
) -> SourceLocation? {
  match self {
    UnknownValueName(_, expression, offset)
    | AmbiguousImportedValueName(_, expression, offset)
    | AmbiguousImportedQualifiedRoot(_, expression, offset)
    | UnknownQualifiedRoot(_, expression, offset)
    | UnknownImportAlias(_, expression, offset)
    | BreakOutsideLoop(expression, offset)
    | ContinueOutsideLoop(expression, offset) =>
      location_at(module_.expression_location(expression), offset)
    UnknownPatternImportAlias(_, pattern, offset)
    | UnknownPatternConstructor(_, pattern, offset)
    | AlternativeMissingBinding(_, pattern, offset)
    | AlternativeExtraBinding(_, pattern, offset) =>
      location_at(module_.pattern_location(pattern), offset)
    DuplicatePatternBinding(_, _, offset) =>
      Some({ file: fallback_file, offset, })
  }
}

///|
fn BodyResolutionDiagnostic::secondary_labels(
  self : BodyResolutionDiagnostic,
  file : FileId,
) -> Array[CompilerDiagnosticLabel] {
  let labels : Array[CompilerDiagnosticLabel] = []
  match self {
    DuplicatePatternBinding(_, first, _) =>
      labels.push({
        location: { file, offset: first, },
        message: "first binding is here",
      })
    _ => ()
  }
  labels
}

///|
fn constraint_origin_location(
  origin : TypeConstraintOrigin,
  module_ : CollectedModule,
  fallback_file : FileId,
) -> SourceLocation? {
  match origin.kind {
    ExpressionTypeConstraint | CallTypeConstraint | OperatorTypeConstraint =>
      location_at(module_.expression_location(origin.source), origin.offset)
    PatternTypeConstraint =>
      location_at(module_.pattern_location(origin.source), origin.offset)
    _ => Some({ file: fallback_file, offset: origin.offset, })
  }
}

///|
fn BodyInferenceDiagnostic::primary_location(
  self : BodyInferenceDiagnostic,
  module_ : CollectedModule,
  fallback_file : FileId,
) -> SourceLocation? {
  match self {
    BodyConstraintDiagnostic(LocalTypeMismatch(_, _, origin))
    | BodyConstraintDiagnostic(InfiniteLocalType(_, _, origin)) =>
      constraint_origin_location(origin, module_, fallback_file)
    NumericLiteralOutOfRange(expression, _, offset)
    | UnsupportedExpressionInference(expression, offset)
    | InvalidCallTarget(expression, offset)
    | InvalidAssignmentTarget(expression, offset)
    | ImmutableAssignmentTarget(expression, offset)
    | FunctionReferenceExpectedTypeRequired(_, expression, offset)
    | NoMatchingFunctionReference(_, expression, offset)
    | AmbiguousFunctionReference(_, expression, _, _, _, offset)
    | FunctionCallArgumentCountMismatch(expression, _, _, offset)
    | CallArgumentCountMismatch(expression, _, _, _, offset)
    | CallTypeArgumentCountMismatch(expression, _, _, _, offset)
    | NoMatchingCallOverload(_, expression, offset)
    | AmbiguousCallOverload(_, expression, _, _, _, offset)
    | UnresolvedCallTypeArgument(expression, _, offset)
    | InvalidConstructionTarget(expression, offset)
    | ObjectTypeRequired(expression, offset)
    | ConstructionPayloadKindMismatch(expression, _, offset)
    | ConstructionPayloadArityMismatch(expression, _, _, _, offset)
    | UnknownVariantValue(_, expression, offset)
    | AmbiguousVariantValue(_, expression, _, _, _, offset)
    | UnknownConstructionField(_, expression, offset)
    | MissingConstructionField(_, expression, offset)
    | FieldAccessRequiresNominal(expression, offset)
    | UnknownFieldForType(_, _, expression, offset)
    | UnknownQualifiedMember(_, _, expression, offset)
    | UnknownImportedModuleMember(_, expression, offset)
    | NoMatchingMethod(_, expression, offset)
    | AmbiguousMethod(_, expression, _, _, _, offset)
    | UnsatisfiedTraitObligation(_, _, _, expression, offset)
    | UnresolvedExpressionTypeArgument(expression, _, offset)
    | UnresolvedExpressionType(expression, offset) =>
      location_at(module_.expression_location(expression), offset)
    InvalidPatternConstructor(pattern, offset)
    | UnknownVariantForType(_, _, pattern, offset)
    | AmbiguousPatternVariant(_, pattern, _, _, _, offset)
    | PatternPayloadKindMismatch(pattern, _, offset)
    | PatternPayloadArityMismatch(pattern, _, _, offset)
    | UnknownPatternField(_, pattern, offset)
    | MissingPatternField(_, pattern, offset)
    | MissingImportedPatternField(_, pattern, offset)
    | UnresolvedPatternTypeArgument(pattern, _, offset) =>
      location_at(module_.pattern_location(pattern), offset)
    UnresolvedModuleValue(declaration, offset) =>
      location_at(module_.declaration_location(declaration), offset)
    DuplicateConstructionField(_, _, offset)
    | ReturnOutsideCallable(offset)
    | UnresolvedLocalType(_, _, offset)
    | UnresolvedLambdaLocalType(_, _, offset) =>
      Some({ file: fallback_file, offset, })
  }
}

///|
fn BodyInferenceDiagnostic::secondary_labels(
  self : BodyInferenceDiagnostic,
  file : FileId,
) -> Array[CompilerDiagnosticLabel] {
  let labels : Array[CompilerDiagnosticLabel] = []
  match self {
    DuplicateConstructionField(_, first, _) =>
      labels.push({
        location: { file, offset: first, },
        message: "first field is here",
      })
    _ => ()
  }
  labels
}

///|
fn add_return_type_secondary_label(
  diagnostic : BodyInferenceDiagnostic,
  location : SourceLocation?,
  labels : Array[CompilerDiagnosticLabel],
) -> Unit {
  let return_mismatch = match diagnostic {
    BodyConstraintDiagnostic(LocalTypeMismatch(_, _, origin))
    | BodyConstraintDiagnostic(InfiniteLocalType(_, _, origin)) =>
      origin.kind == ReturnTypeConstraint
    _ => false
  }
  if return_mismatch {
    match location {
      Some(value) =>
        labels.push({
          location: value,
          message: "declared return type is here",
        })
      None => ()
    }
  }
}

///|
fn ImplIndexDiagnostic::primary_declaration(
  self : ImplIndexDiagnostic,
) -> DeclId {
  match self {
    InvalidImplTraitHead(declaration, _)
    | InvalidImplTargetHead(declaration, _)
    | OrphanTraitImpl(declaration, _, _, _)
    | UnknownTraitImplMethod(declaration, _, _)
    | MissingTraitMethod(declaration, _, _)
    | DuplicateTraitImplMethod(declaration, _, _, _)
    | TraitMethodReceiverMismatch(declaration, _, _)
    | TraitMethodParameterCountMismatch(declaration, _, _, _, _)
    | TraitMethodGenericParameterCountMismatch(declaration, _, _, _, _)
    | TraitMethodParameterTypeMismatch(declaration, _, _, _)
    | TraitMethodReturnTypeMismatch(declaration, _, _)
    | DuplicateInherentMethod(_, declaration, _, _) => declaration
    OverlappingTraitImpl(_, _, declaration, _, _) => declaration
  }
}

///|
fn ImplIndexDiagnostic::secondary_declarations(
  self : ImplIndexDiagnostic,
) -> Array[DeclId] {
  match self {
    OrphanTraitImpl(_, trait_declaration, target_head, _) =>
      match target_head {
        NominalImplTargetHead(target_declaration) =>
          [trait_declaration, target_declaration]
        _ => [trait_declaration]
      }
    OverlappingTraitImpl(_, first, second, _, _) => [first, second]
    DuplicateTraitImplMethod(_, first, second, _) => [first, second]
    DuplicateInherentMethod(_, first, second, _) => [first, second]
    _ => []
  }
}

///|
fn ImplIndexDiagnostic::secondary_declaration_message(
  self : ImplIndexDiagnostic,
  declaration : DeclId,
) -> String {
  match self {
    OrphanTraitImpl(_, trait_declaration, _, _) =>
      if declaration == trait_declaration {
        "foreign trait is declared here"
      } else {
        "foreign target type is declared here"
      }
    _ => "conflicting implementation is here"
  }
}

///|
fn compiler_label_for_declaration(
  program : CollectedProgram,
  declaration : DeclId,
  message : String,
) -> CompilerDiagnosticLabel? {
  match program.module_for_id(semantic_id_module(declaration)) {
    Some(module_) =>
      match module_.declaration_location(declaration) {
        Some(location) => Some({ location, message, })
        None => None
      }
    None => None
  }
}

///|
fn push_source_diagnostic(
  diagnostics : Array[CompilerSourceDiagnostic],
  program : CollectedProgram,
  severity : CompilerDiagnosticSeverity,
  message : String,
  primary : SourceLocation?,
  secondary : Array[CompilerDiagnosticLabel],
  rank : Int,
) -> Unit {
  diagnostics.push(
    compiler_diagnostic(program, severity, message, primary, secondary, rank),
  )
}

///|
fn cyclic_module_value_declarations(
  collected : CollectedModule,
  inferred : InferredModuleValues,
) -> Array[Bool] {
  let cyclic = Array::make(collected.declaration_locations.length(), false)
  let let_indices = module_let_indices_by_declaration(collected)
  for scc in inferred.dependencies.sccs {
    if !module_value_scc_is_cyclic(inferred.dependencies, let_indices, scc) {
      continue
    }
    for index in scc.start..<(scc.start + scc.length) {
      let declaration = inferred.dependencies.scc_declarations[index]
      let declaration_index = semantic_id_local(declaration)
      if declaration_index >= 0 && declaration_index < cyclic.length() {
        cyclic[declaration_index] = true
      }
    }
  }
  cyclic
}

///|
pub fn collect_compiler_source_diagnostics(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  link : PlannedProgramWasmGCLink,
) -> Array[CompilerSourceDiagnostic] {
  let diagnostics : Array[CompilerSourceDiagnostic] = []
  let mut rank = 0
  for diagnostic in program.diagnostics {
    let primary = match diagnostic {
      EmptyFilePath(module_index, file_index) =>
        if module_index >= 0 &&
          module_index < program.modules.length() &&
          file_index >= 0 &&
          file_index < program.modules[module_index].files.length() {
          Some({
            file: program.modules[module_index].files[file_index],
            offset: 0UL,
          })
        } else {
          None
        }
      DuplicateFilePath(_, module_index, _, duplicate) =>
        if module_index >= 0 &&
          module_index < program.modules.length() &&
          duplicate >= 0 &&
          duplicate < program.modules[module_index].files.length() {
          Some({
            file: program.modules[module_index].files[duplicate],
            offset: 0UL,
          })
        } else {
          None
        }
      _ => None
    }
    let secondary : Array[CompilerDiagnosticLabel] = []
    match diagnostic {
      DuplicateFilePath(_, module_index, first, _) =>
        if module_index >= 0 &&
          module_index < program.modules.length() &&
          first >= 0 &&
          first < program.modules[module_index].files.length() {
          secondary.push({
            location: {
              file: program.modules[module_index].files[first],
              offset: 0UL,
            },
            message: "first file with this path is here",
          })
        }
      _ => ()
    }
    push_source_diagnostic(
      diagnostics,
      program,
      CompilerError,
      @debug.to_string(diagnostic),
      primary,
      secondary,
      rank,
    )
    rank += 1
  }
  for module_ in program.modules {
    for diagnostic in module_.diagnostics {
      let (severity, primary, secondary) = diagnostic.source_parts()
      push_source_diagnostic(
        diagnostics,
        program,
        severity,
        @debug.to_string(diagnostic),
        primary,
        secondary,
        rank,
      )
      rank += 1
    }
  }
  for diagnostic in analyzed.frozen.graph.diagnostics {
    let primary = match diagnostic {
      MissingImportedModule(_, _, file, offset)
      | DuplicateImportedModule(_, _, file, offset) => Some({ file, offset, })
    }
    push_source_diagnostic(
      diagnostics,
      program,
      CompilerError,
      @debug.to_string(diagnostic),
      primary,
      [],
      rank,
    )
    rank += 1
  }
  for diagnostic in analyzed.frozen.import_diagnostics {
    let (module_id, primary, secondary) = match diagnostic {
      UnavailableImportedInterface(module_id, _, file, offset)
      | DuplicateImportedAlias(module_id, _, file, offset) =>
        (module_id, Some({ file, offset, }), [])
      AmbiguousImportedType(module_id, _, first, second)
      | AmbiguousImportedTrait(module_id, _, first, second)
      | AmbiguousImportedValue(module_id, _, first, second) => {
        let labels : Array[CompilerDiagnosticLabel] = []
        match
          compiler_label_for_declaration(
            program, second, "other declaration is here",
          ) {
          Some(label) => labels.push(label)
          None => ()
        }
        let location = match
          compiler_label_for_declaration(program, first, "") {
          Some(label) => Some(label.location)
          None => None
        }
        (module_id, location, labels)
      }
    }
    let fallback = match program.module_for_id(module_id) {
      Some(module_) => module_.default_location(0UL)
      None => None
    }
    push_source_diagnostic(
      diagnostics,
      program,
      CompilerError,
      @debug.to_string(diagnostic),
      match primary {
        Some(value) => Some(value)
        None => fallback
      },
      secondary,
      rank,
    )
    rank += 1
  }
  for interface_ in analyzed.frozen.interfaces {
    match program.module_for_id(interface_.module_id) {
      Some(module_) =>
        for diagnostic in interface_.resolved_types.diagnostics {
          push_source_diagnostic(
            diagnostics,
            program,
            CompilerError,
            @debug.to_string(diagnostic),
            diagnostic.primary_location(module_, interface_.resolved_types),
            [],
            rank,
          )
          rank += 1
        }
      None => ()
    }
  }
  for analyzed_module in analyzed.modules {
    let collected = match program.module_for_id(analyzed_module.module_id) {
      Some(value) => value
      None => continue
    }
    for body in analyzed_module.names.bodies {
      let file = match collected.body_location(body.body) {
        Some(location) => location.file
        None =>
          if collected.files.length() > 0 {
            collected.files[0]
          } else {
            0UL
          }
      }
      for
        index in body.diagnostics.start..<(body.diagnostics.start +
        body.diagnostics.length) {
        let diagnostic = analyzed_module.names.diagnostics[index]
        push_source_diagnostic(
          diagnostics,
          program,
          CompilerError,
          @debug.to_string(diagnostic),
          diagnostic.primary_location(collected, file),
          diagnostic.secondary_labels(file),
          rank,
        )
        rank += 1
      }
    }
    for lambda in analyzed_module.names.lambdas {
      let file = if lambda.lambda >= 0 &&
        lambda.lambda < collected.lambdas.length() {
        collected.lambdas[lambda.lambda].file
      } else if collected.files.length() > 0 {
        collected.files[0]
      } else {
        0UL
      }
      for
        index in lambda.diagnostics.start..<(lambda.diagnostics.start +
        lambda.diagnostics.length) {
        let diagnostic = analyzed_module.names.diagnostics[index]
        push_source_diagnostic(
          diagnostics,
          program,
          CompilerError,
          @debug.to_string(diagnostic),
          diagnostic.primary_location(collected, file),
          diagnostic.secondary_labels(file),
          rank,
        )
        rank += 1
      }
    }
    for diagnostic in analyzed_module.inferred.impl_index.diagnostics {
      let declaration = diagnostic.primary_declaration()
      let primary = match
        program.module_for_id(semantic_id_module(declaration)) {
        Some(owner) =>
          if diagnostic.offset() == 0UL {
            owner.declaration_location(declaration)
          } else {
            location_at(
              owner.declaration_location(declaration),
              diagnostic.offset(),
            )
          }
        None => collected.default_location(diagnostic.offset())
      }
      let secondary : Array[CompilerDiagnosticLabel] = []
      for candidate in diagnostic.secondary_declarations() {
        if candidate != declaration {
          match
            compiler_label_for_declaration(
              program,
              candidate,
              diagnostic.secondary_declaration_message(candidate),
            ) {
            Some(label) => secondary.push(label)
            None => ()
          }
        }
      }
      push_source_diagnostic(
        diagnostics,
        program,
        CompilerError,
        @debug.to_string(diagnostic),
        primary,
        secondary,
        rank,
      )
      rank += 1
    }
    let cyclic_values = cyclic_module_value_declarations(
      collected,
      analyzed_module.inferred.module_values,
    )
    for body in analyzed_module.inferred.bodies {
      let body_index = semantic_id_local(body.body)
      if body_index >= 0 && body_index < collected.bodies.length() {
        let declaration_index = semantic_id_local(
          collected.bodies[body_index].declaration,
        )
        if declaration_index >= 0 &&
          declaration_index < cyclic_values.length() &&
          cyclic_values[declaration_index] {
          continue
        }
      }
      let file = match collected.body_location(body.body) {
        Some(location) => location.file
        None =>
          if collected.files.length() > 0 {
            collected.files[0]
          } else {
            0UL
          }
      }
      for
        index in body.diagnostics.start..<(body.diagnostics.start +
        body.diagnostics.length) {
        let diagnostic = analyzed_module.inferred.diagnostics[index]
        let secondary = diagnostic.secondary_labels(file)
        let body_index = semantic_id_local(body.body)
        if body_index >= 0 && body_index < collected.bodies.length() {
          add_return_type_secondary_label(
            diagnostic,
            collected.callable_return_location(
              collected.bodies[body_index].declaration,
            ),
            secondary,
          )
        }
        push_source_diagnostic(
          diagnostics,
          program,
          CompilerError,
          @debug.to_string(diagnostic),
          diagnostic.primary_location(collected, file),
          secondary,
          rank,
        )
        rank += 1
      }
    }
    for lambda in analyzed_module.inferred.lambdas {
      let file = if lambda.lambda >= 0 &&
        lambda.lambda < collected.lambdas.length() {
        collected.lambdas[lambda.lambda].file
      } else if collected.files.length() > 0 {
        collected.files[0]
      } else {
        0UL
      }
      for
        index in lambda.diagnostics.start..<(lambda.diagnostics.start +
        lambda.diagnostics.length) {
        let diagnostic = analyzed_module.inferred.diagnostics[index]
        let secondary = diagnostic.secondary_labels(file)
        if lambda.lambda >= 0 && lambda.lambda < collected.lambdas.length() {
          add_return_type_secondary_label(
            diagnostic,
            collected.type_syntax_location(
              collected.lambdas[lambda.lambda].return_type,
            ),
            secondary,
          )
        }
        push_source_diagnostic(
          diagnostics,
          program,
          CompilerError,
          @debug.to_string(diagnostic),
          diagnostic.primary_location(collected, file),
          secondary,
          rank,
        )
        rank += 1
      }
    }
  }
  for module_index, planned in lowering.modules {
    let collected = program.modules[module_index]
    for diagnostic in planned.flow_diagnostics {
      let (severity, primary) = match diagnostic {
        NonExhaustiveMatch(expression, _, offset)
        | NonExhaustiveFunctionalLoop(expression, _, offset) =>
          (
            CompilerError,
            location_at(collected.expression_location(expression), offset),
          )
        RedundantPatternArm(arm, offset) =>
          (
            CompilerWarning,
            location_at(collected.pattern_arm_location(arm), offset),
          )
        FunctionalLoopArmFallsThrough(arm, offset) =>
          (
            CompilerError,
            location_at(collected.pattern_arm_location(arm), offset),
          )
        UnreachableBlockItem(block, _, offset) =>
          (
            CompilerWarning,
            location_at(collected.block_location(block), offset),
          )
      }
      push_source_diagnostic(
        diagnostics,
        program,
        severity,
        @debug.to_string(diagnostic),
        primary,
        [],
        rank,
      )
      rank += 1
    }
    for diagnostic in planned.initialization.diagnostics {
      let primary = match diagnostic {
        EagerModuleInitializationCycle(span, offset) =>
          if span.length > 0 &&
            span.start >= 0 &&
            span.start < planned.initialization.cycle_declarations.length() {
            location_at(
              collected.declaration_location(
                planned.initialization.cycle_declarations[span.start],
              ),
              offset,
            )
          } else {
            collected.default_location(offset)
          }
      }
      let secondary : Array[CompilerDiagnosticLabel] = []
      match diagnostic {
        EagerModuleInitializationCycle(span, _) =>
          for index in 1..<span.length {
            let member_index = span.start + index
            if member_index >= 0 &&
              member_index < planned.initialization.cycle_declarations.length() {
              match
                collected.declaration_location(
                  planned.initialization.cycle_declarations[member_index],
                ) {
                Some(location) =>
                  secondary.push({
                    location,
                    message: "cycle member is initialized here",
                  })
                None => ()
              }
            }
          }
      }
      push_source_diagnostic(
        diagnostics,
        program,
        CompilerError,
        @debug.to_string(diagnostic),
        primary,
        secondary,
        rank,
      )
      rank += 1
    }
    for diagnostic in planned.diagnostics {
      let primary = match diagnostic {
        UnsupportedIndexLowering(expression, offset) =>
          location_at(collected.expression_location(expression), offset)
      }
      let mut already_diagnosed = false
      match primary {
        Some(location) =>
          for existing in diagnostics {
            if existing.has_primary && existing.primary == location {
              already_diagnosed = true
              break
            }
          }
        None => ()
      }
      if !already_diagnosed {
        push_source_diagnostic(
          diagnostics,
          program,
          CompilerError,
          @debug.to_string(diagnostic),
          primary,
          [],
          rank,
        )
        rank += 1
      }
    }
  }
  for diagnostic in link.diagnostics {
    let (module_id, declaration, offset) = match diagnostic {
      MissingProgramType(module_id, declaration) =>
        (module_id, declaration, 0UL)
      UnsupportedProgramGenericCall(module_id, declaration, offset)
      | MissingProgramFunction(module_id, declaration, offset) =>
        (module_id, declaration, offset)
      EagerProgramInitializationCycle(_, second) =>
        (semantic_id_module(second), second, 0UL)
    }
    let primary = match program.module_for_id(module_id) {
      Some(module_) =>
        if offset != 0UL {
          module_.module_offset_location(offset)
        } else {
          module_.declaration_location(declaration)
        }
      None => None
    }
    let secondary : Array[CompilerDiagnosticLabel] = []
    match diagnostic {
      EagerProgramInitializationCycle(first, _) =>
        match
          compiler_label_for_declaration(
            program, first, "cycle also includes this declaration",
          ) {
          Some(label) => secondary.push(label)
          None => ()
        }
      _ => ()
    }
    push_source_diagnostic(
      diagnostics,
      program,
      CompilerError,
      @debug.to_string(diagnostic),
      primary,
      secondary,
      rank,
    )
    rank += 1
  }
  diagnostics.sort_by(fn(left, right) {
    let module_order = left.module_order - right.module_order
    if module_order != 0 {
      module_order
    } else {
      let file_order = left.file_order - right.file_order
      if file_order != 0 {
        file_order
      } else {
        let offset_order = left.primary.offset.compare(right.primary.offset)
        if offset_order != 0 {
          offset_order
        } else {
          left.rank - right.rank
        }
      }
    }
  })
  diagnostics
}

///|
fn write_source_line(
  output : Buffer,
  source : Bytes,
  start : Int,
  end : Int,
) -> Unit {
  for index in start..<end {
    output.write_byte(source[index])
  }
}

///|
fn write_caret_padding(
  output : Buffer,
  source : Bytes,
  start : Int,
  target : Int,
) -> Unit {
  for index in start..<target {
    if source[index] == b'\t' {
      output.write_byte(b'\t')
    } else {
      output.write_byte(b' ')
    }
  }
}

///|
pub fn render_compiler_source_diagnostic(
  program : CollectedProgram,
  diagnostic : CompilerSourceDiagnostic,
) -> String {
  let output = Buffer(size_hint=256)
  let severity = match diagnostic.severity {
    CompilerError => "error"
    CompilerWarning => "warning"
  }
  if !diagnostic.has_primary {
    output.write_string_utf8(severity)
    output.write_string_utf8(": ")
    output.write_string_utf8(diagnostic.message)
    return @utf8.decode_lossy(output.to_bytes())
  }
  match program.source_file(diagnostic.primary.file) {
    Some(file) => {
      let position = file.line_column(diagnostic.primary.offset)
      let path = if file.path == "" { "<source>" } else { file.path }
      output.write_string_utf8(path)
      output.write_byte(b':')
      output.write_string_utf8(position.line.to_string())
      output.write_byte(b':')
      output.write_string_utf8(position.column.to_string())
      output.write_string_utf8(": ")
      output.write_string_utf8(severity)
      output.write_string_utf8(": ")
      output.write_string_utf8(diagnostic.message)
      output.write_byte(b'\n')
      output.write_string_utf8("  |\n")
      output.write_string_utf8(position.line.to_string())
      output.write_string_utf8(" | ")
      write_source_line(
        output,
        file.source,
        position.line_start,
        position.line_end,
      )
      output.write_byte(b'\n')
      output.write_string_utf8("  | ")
      let mut target = diagnostic.primary.offset.to_int()
      if target < position.line_start {
        target = position.line_start
      } else if target > position.line_end {
        target = position.line_end
      }
      write_caret_padding(output, file.source, position.line_start, target)
      output.write_byte(b'^')
    }
    None => {
      output.write_string_utf8(severity)
      output.write_string_utf8(": ")
      output.write_string_utf8(diagnostic.message)
    }
  }
  for label in diagnostic.secondary {
    match program.source_file(label.location.file) {
      Some(file) => {
        let position = file.line_column(label.location.offset)
        let path = if file.path == "" { "<source>" } else { file.path }
        output.write_byte(b'\n')
        output.write_string_utf8("  = ")
        output.write_string_utf8(path)
        output.write_byte(b':')
        output.write_string_utf8(position.line.to_string())
        output.write_byte(b':')
        output.write_string_utf8(position.column.to_string())
        output.write_string_utf8(": ")
        output.write_string_utf8(label.message)
      }
      None => ()
    }
  }
  @utf8.decode_lossy(output.to_bytes())
}
