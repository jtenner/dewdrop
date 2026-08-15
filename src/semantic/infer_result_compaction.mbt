///|
fn BasicBodyInferencer::sort_diagnostics(self : BasicBodyInferencer) -> Unit {
  self.diagnostics.sort_by(fn(left, right) {
    let offset_order = left.offset().compare(right.offset())
    if offset_order != 0 {
      offset_order
    } else {
      left.rank() - right.rank()
    }
  })
}

///|
fn BasicBodyInferencer::finalize_types(self : BasicBodyInferencer) -> Unit {
  for index in self.solver_diagnostic_start..<self.solver_diagnostic_end {
    self.diagnostics.push(
      BodyConstraintDiagnostic(self.solver.diagnostics[index]),
    )
  }
  for index in 0..<self.unsupported_expressions.length() {
    if self.unsupported_expressions[index] {
      let expression = self.body.expressions.start + index
      self.diagnose(
        UnsupportedExpressionInference(
          expression,
          self.collected.expressions[expression].offset(),
        ),
      )
    }
  }
  for call_slot in 0..<self.call_targets.length() {
    match self.call_targets[call_slot] {
      SelectedInferredCallTarget(_, arguments)
      | SelectedBoundInferredCallTarget(_, _, arguments)
      | SelectedDynamicTraitCallTarget(_, _, _, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(self.call_type_arguments[slot])
          self.call_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let expression = self.call_expressions[call_slot]
            self.diagnose(
              UnresolvedCallTypeArgument(
                expression,
                argument_index,
                self.collected.expressions[expression].offset(),
              ),
            )
          }
        }
      NoInferredCallTarget
      | ErrorInferredCallTarget
      | SelectedFunctionValueCallTarget(_) => ()
    }
  }
  for expression_index in 0..<self.operator_targets.length() {
    match self.operator_targets[expression_index] {
      SelectedInferredCallTarget(_, arguments)
      | SelectedBoundInferredCallTarget(_, _, arguments)
      | SelectedDynamicTraitCallTarget(_, _, _, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(self.call_type_arguments[slot])
          self.call_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let expression = self.body.expressions.start + expression_index
            self.diagnose(
              UnresolvedCallTypeArgument(
                expression,
                argument_index,
                self.collected.expressions[expression].offset(),
              ),
            )
          }
        }
      NoInferredCallTarget
      | ErrorInferredCallTarget
      | SelectedFunctionValueCallTarget(_) => ()
    }
  }
  for targets in [self.map_hash_targets, self.map_eq_targets] {
    for expression_index in 0..<targets.length() {
      match targets[expression_index] {
        SelectedInferredCallTarget(_, arguments)
        | SelectedBoundInferredCallTarget(_, _, arguments)
        | SelectedDynamicTraitCallTarget(_, _, _, arguments) =>
          for argument_index in 0..<arguments.length {
            let slot = arguments.start + argument_index
            let frozen = self.solver.zonk_type(self.call_type_arguments[slot])
            self.call_type_arguments[slot] = frozen
            if self.solver.has_unresolved_variable(frozen) {
              let expression = self.body.expressions.start + expression_index
              self.diagnose(
                UnresolvedCallTypeArgument(
                  expression,
                  argument_index,
                  self.collected.expressions[expression].offset(),
                ),
              )
            }
          }
        NoInferredCallTarget
        | ErrorInferredCallTarget
        | SelectedFunctionValueCallTarget(_) => ()
      }
    }
  }
  for expression_index in 0..<self.expression_selections.length() {
    match self.expression_selections[expression_index] {
      StructConstructionSelection(_, arguments)
      | VariantConstructionSelection(_, arguments)
      | UnitVariantValueSelection(_, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(
            self.expression_type_arguments[slot],
          )
          self.expression_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let expression = self.body.expressions.start + expression_index
            self.diagnose(
              UnresolvedExpressionTypeArgument(
                expression,
                argument_index,
                self.collected.expressions[expression].offset(),
              ),
            )
          }
        }
      NoExpressionSelection
      | ErrorExpressionSelection
      | FieldAccessSelection(_, _)
      | ImportedModuleValueSelection(_)
      | FunctionReferenceSelection(_, _) => ()
    }
  }
  for pattern_index in 0..<self.pattern_constructors.length() {
    match self.pattern_constructors[pattern_index] {
      StructInferredPatternConstructor(_, arguments)
      | VariantInferredPatternConstructor(_, arguments) =>
        for argument_index in 0..<arguments.length {
          let slot = arguments.start + argument_index
          let frozen = self.solver.zonk_type(self.pattern_type_arguments[slot])
          self.pattern_type_arguments[slot] = frozen
          if self.solver.has_unresolved_variable(frozen) {
            let pattern = self.body.patterns.start + pattern_index
            self.diagnose(
              UnresolvedPatternTypeArgument(
                pattern,
                argument_index,
                self.collected.patterns[pattern].offset(),
              ),
            )
          }
        }
      NoInferredPatternConstructor | ErrorInferredPatternConstructor => ()
    }
  }
  for index in 0..<self.expression_types.length() {
    let expression = self.body.expressions.start + index
    let frozen = self.solver.zonk_type(self.expression_types[index])
    self.expression_types[index] = frozen
    if !self.unsupported_expressions[index] &&
      (
        self.consumed_member_roots.length() == 0 ||
        !self.consumed_member_roots[index]
      ) &&
      self.solver.has_unresolved_variable(frozen) {
      self.diagnose(
        UnresolvedExpressionType(
          expression,
          self.collected.expressions[expression].offset(),
        ),
      )
    }
  }
  for local_id in 0..<self.local_types.length() {
    let frozen = self.solver.zonk_type(self.local_types[local_id])
    self.local_types[local_id] = frozen
    if self.solver.has_unresolved_variable(frozen) {
      let local_info = self.names.locals[self.local_span.start + local_id]
      self.diagnose(
        if self.lambda >= 0 {
          UnresolvedLambdaLocalType(self.lambda, local_id, local_info.offset)
        } else {
          UnresolvedLocalType(self.body.id, local_id, local_info.offset)
        },
      )
    }
  }
  for index in 0..<self.capture_types.length() {
    self.capture_types[index] = self.solver.zonk_type(self.capture_types[index])
  }
  for index in 0..<self.block_types.length() {
    self.block_types[index] = self.solver.zonk_type(self.block_types[index])
  }
  for index in 0..<self.pattern_types.length() {
    self.pattern_types[index] = self.solver.zonk_type(self.pattern_types[index])
  }
  for index in 0..<self.control_state_types.length() {
    self.control_state_types[index] = self.solver.zonk_type(
      self.control_state_types[index],
    )
    self.control_result_types[index] = self.solver.zonk_type(
      self.control_result_types[index],
    )
  }
  self.result_type = self.solver.zonk_type(self.result_type)
  self.sort_diagnostics()
}

///|
fn BasicBodyInferencer::mark_compact_type(
  self : BasicBodyInferencer,
  root : BodyTypeId,
) -> Unit {
  self.compact_stack.push(root)
  while self.compact_stack.length() > 0 {
    let type_ = self.compact_stack.pop().unwrap()
    if type_ <= 0 || self.compact_marks[type_] {
      continue
    }
    self.compact_marks[type_] = true
    match self.solver.types[type_] {
      BodyAppliedType(base, arguments) => {
        let mut index = arguments.length
        while index > 0 {
          index -= 1
          self.compact_stack.push(
            self.solver.type_arguments[arguments.start + index],
          )
        }
        self.compact_stack.push(base)
      }
      BodyFunctionType(parameters, result) => {
        self.compact_stack.push(result)
        let mut index = parameters.length
        while index > 0 {
          index -= 1
          self.compact_stack.push(
            self.solver.type_arguments[parameters.start + index],
          )
        }
      }
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::mark_compact_roots(self : BasicBodyInferencer) -> Unit {
  self.mark_compact_type(self.result_type)
  for type_ in self.expression_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.local_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.capture_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.block_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.pattern_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.pattern_type_arguments {
    self.mark_compact_type(type_)
  }
  for type_ in self.expression_type_arguments {
    self.mark_compact_type(type_)
  }
  for type_ in self.control_state_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.control_result_types {
    self.mark_compact_type(type_)
  }
  for type_ in self.call_type_arguments {
    self.mark_compact_type(type_)
  }
  for diagnostic in self.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(left, right, _)) => {
        self.mark_compact_type(left)
        self.mark_compact_type(right)
      }
      BodyConstraintDiagnostic(InfiniteLocalType(_, type_, _)) =>
        self.mark_compact_type(type_)
      _ => ()
    }
  }
}

///|
fn BasicBodyInferencer::compact_type_id(
  self : BasicBodyInferencer,
  type_ : BodyTypeId,
) -> BodyTypeId {
  if type_ <= 0 {
    type_
  } else {
    self.compact_mapping[type_]
  }
}

///|
fn BasicBodyInferencer::has_positive_compact_root(
  self : BasicBodyInferencer,
) -> Bool {
  if self.result_type > 0 {
    return true
  }
  for type_ in self.expression_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.local_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.capture_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.block_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.pattern_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.pattern_type_arguments {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.expression_type_arguments {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.control_state_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.control_result_types {
    if type_ > 0 {
      return true
    }
  }
  for type_ in self.call_type_arguments {
    if type_ > 0 {
      return true
    }
  }
  for diagnostic in self.diagnostics {
    match diagnostic {
      BodyConstraintDiagnostic(LocalTypeMismatch(left, right, _)) =>
        if left > 0 || right > 0 {
          return true
        }
      BodyConstraintDiagnostic(InfiniteLocalType(_, type_, _)) =>
        if type_ > 0 {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
fn BasicBodyInferencer::build_compact_types(self : BasicBodyInferencer) -> Unit {
  self.compact_types.clear()
  self.compact_arguments.clear()
  self.compact_types.push(BodyErrorType)
  if !self.has_positive_compact_root() {
    self.compact_marks = []
    self.compact_mapping = []
    return
  }
  self.compact_marks = Array::make(self.solver.types.length(), false)
  self.compact_mapping = Array::make(self.solver.types.length(), -1)
  self.compact_mapping[0] = 0
  self.mark_compact_roots()
  for old_id in 1..<self.solver.types.length() {
    if !self.compact_marks[old_id] {
      continue
    }
    let new_id = self.compact_types.length()
    self.compact_mapping[old_id] = new_id
    match self.solver.types[old_id] {
      BodyVariableType(variable) =>
        self.compact_types.push(BodyVariableType(variable))
      BodyAppliedType(base, arguments) => {
        let start = self.compact_arguments.length()
        for index in 0..<arguments.length {
          self.compact_arguments.push(
            self.compact_type_id(
              self.solver.type_arguments[arguments.start + index],
            ),
          )
        }
        self.compact_types.push(
          BodyAppliedType(self.compact_type_id(base), {
            start,
            length: arguments.length,
          }),
        )
      }
      BodyFunctionType(parameters, result) => {
        let start = self.compact_arguments.length()
        for index in 0..<parameters.length {
          self.compact_arguments.push(
            self.compact_type_id(
              self.solver.type_arguments[parameters.start + index],
            ),
          )
        }
        self.compact_types.push(
          BodyFunctionType(
            { start, length: parameters.length },
            self.compact_type_id(result),
          ),
        )
      }
      BodyErrorType | BodyResolvedType(_) =>
        abort("unexpected stored body type during compaction")
    }
  }
}

///|
fn BasicBodyInferencer::remap_diagnostics(self : BasicBodyInferencer) -> Unit {
  for index in 0..<self.diagnostics.length() {
    self.diagnostics[index] = match self.diagnostics[index] {
      BodyConstraintDiagnostic(LocalTypeMismatch(left, right, origin)) =>
        BodyConstraintDiagnostic(
          LocalTypeMismatch(
            self.compact_type_id(left),
            self.compact_type_id(right),
            origin,
          ),
        )
      BodyConstraintDiagnostic(InfiniteLocalType(variable, type_, origin)) =>
        BodyConstraintDiagnostic(
          InfiniteLocalType(variable, self.compact_type_id(type_), origin),
        )
      other => other
    }
  }
}

///|
fn BasicBodyInferencer::compact_results(self : BasicBodyInferencer) -> Unit {
  self.build_compact_types()
  self.result_type = self.compact_type_id(self.result_type)
  for index in 0..<self.expression_types.length() {
    self.expression_types[index] = self.compact_type_id(
      self.expression_types[index],
    )
  }
  for index in 0..<self.local_types.length() {
    self.local_types[index] = self.compact_type_id(self.local_types[index])
  }
  for index in 0..<self.capture_types.length() {
    self.capture_types[index] = self.compact_type_id(self.capture_types[index])
  }
  for index in 0..<self.block_types.length() {
    self.block_types[index] = self.compact_type_id(self.block_types[index])
  }
  for index in 0..<self.pattern_types.length() {
    self.pattern_types[index] = self.compact_type_id(self.pattern_types[index])
  }
  for index in 0..<self.pattern_type_arguments.length() {
    self.pattern_type_arguments[index] = self.compact_type_id(
      self.pattern_type_arguments[index],
    )
  }
  for index in 0..<self.expression_type_arguments.length() {
    self.expression_type_arguments[index] = self.compact_type_id(
      self.expression_type_arguments[index],
    )
  }
  for index in 0..<self.control_state_types.length() {
    self.control_state_types[index] = self.compact_type_id(
      self.control_state_types[index],
    )
    self.control_result_types[index] = self.compact_type_id(
      self.control_result_types[index],
    )
  }
  for index in 0..<self.call_type_arguments.length() {
    self.call_type_arguments[index] = self.compact_type_id(
      self.call_type_arguments[index],
    )
  }
  self.remap_diagnostics()
}
