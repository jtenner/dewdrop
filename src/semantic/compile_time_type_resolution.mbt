///|
enum CompileTimeTypeReadTask {
  CtReadBody(BodyTypeId)
  CtReadResolved(ResolvedTypeId)
  CtBuildProduct(Int)
  CtBuildApplied(Int)
  CtBuildFunction(Int)
  CtBuildMemberProjection(Bytes, String)
}

///|
fn compile_time_read_type(
  module_ : PlannedModuleLowering,
  type_ : BodyTypeId,
  bindings : Map[CompileTimeBindingKey, CompileTimeType],
  self_binding? : (DeclId, CompileTimeType)? = None,
) -> Result[CompileTimeType, CompileTimeTypeError] {
  let work = [CtReadBody(type_)]
  let results : Array[CompileTimeType] = []
  let mut visits = 0
  while work.length() > 0 {
    visits += 1
    if visits > 65536 {
      return Err(CtTypeLimitExceeded)
    }
    match work.pop().unwrap() {
      CtReadBody(index) => {
        if index < -1 {
          // Avoid negating the minimum signed machine integer.
          work.push(CtReadResolved(-(index + 2)))
          continue
        }
        if index < 0 || index >= module_.types.length() {
          return Err(CtInvalidType)
        }
        match module_.types[index] {
          BodyMemberTypeProjection(owner, operation, selector) => {
            work.push(CtBuildMemberProjection(operation, selector))
            work.push(CtReadBody(owner))
          }
          BodyErrorType => return Err(CtInvalidType)
          BodyVariableType(_) => results.push(CtUnknown)
          BodyResolvedType(index) => work.push(CtReadResolved(index))
          BodyProductType(arguments)
          | BodyAppliedType(_, arguments)
          | BodyFunctionType(arguments, _) => {
            if !program_specialization_span_is_valid(
                arguments,
                module_.type_arguments.length(),
              ) {
              return Err(CtInvalidType)
            }
            match module_.types[index] {
              BodyProductType(_) => work.push(CtBuildProduct(arguments.length))
              BodyAppliedType(base, _) => {
                work.push(CtBuildApplied(arguments.length))
                work.push(CtReadBody(base))
              }
              BodyFunctionType(_, result) => {
                work.push(CtBuildFunction(arguments.length))
                work.push(CtReadBody(result))
              }
              _ => abort("CT type read task changed kind")
            }
            for offset = arguments.length - 1; offset >= 0; offset = offset - 1 {
              work.push(
                CtReadBody(module_.type_arguments[arguments.start + offset]),
              )
            }
          }
        }
      }
      CtReadResolved(index) => {
        if index < 0 || index >= module_.resolved_types.length() {
          return Err(CtInvalidType)
        }
        match module_.resolved_types[index] {
          ErrorType => return Err(CtInvalidType)
          MemberTypeProjection(owner, operation, selector) => {
            work.push(CtBuildMemberProjection(operation, selector))
            work.push(CtReadResolved(owner))
          }
          PrimitiveType(primitive) => results.push(CtPrimitive(primitive))
          GenericParameterType(parameter) =>
            results.push(
              bindings
              .get(CtGenericBinding(parameter))
              .unwrap_or(CtParameter(parameter)),
            )
          SelfType(owner) =>
            results.push(
              match self_binding {
                Some((expected_owner, type_)) if owner == expected_owner =>
                  type_
                _ =>
                  bindings
                  .get(CtSelfBinding(owner))
                  .unwrap_or(CtParameter(owner))
              },
            )
          NominalType(declaration) => results.push(CtNominal(declaration))
          TraitType(declaration) => results.push(CtTrait(declaration))
          ProductType(arguments)
          | AppliedType(_, arguments)
          | FunctionType(arguments, _) => {
            if !program_specialization_span_is_valid(
                arguments,
                module_.resolved_type_arguments.length(),
              ) {
              return Err(CtInvalidType)
            }
            match module_.resolved_types[index] {
              ProductType(_) => work.push(CtBuildProduct(arguments.length))
              AppliedType(base, _) => {
                work.push(CtBuildApplied(arguments.length))
                work.push(CtReadResolved(base))
              }
              FunctionType(_, result) => {
                work.push(CtBuildFunction(arguments.length))
                work.push(CtReadResolved(result))
              }
              _ => abort("CT resolved type read task changed kind")
            }
            for offset = arguments.length - 1; offset >= 0; offset = offset - 1 {
              work.push(
                CtReadResolved(
                  module_.resolved_type_arguments[arguments.start + offset],
                ),
              )
            }
          }
        }
      }
      CtBuildMemberProjection(operation, selector) => {
        if results.length() == 0 {
          return Err(CtInvalidType)
        }
        results.push(
          CtMemberProjection(results.pop().unwrap(), operation, selector),
        )
      }
      CtBuildProduct(count) => {
        if results.length() < count {
          return Err(CtInvalidType)
        }
        let start = results.length() - count
        let fields = results[start:].to_owned()
        results.truncate(start)
        results.push(CtProduct(fields))
      }
      CtBuildApplied(count) | CtBuildFunction(count) as task => {
        if results.length() < count + 1 {
          return Err(CtInvalidType)
        }
        let base_or_result = results.pop().unwrap()
        let start = results.length() - count
        let arguments = results[start:].to_owned()
        results.truncate(start)
        results.push(
          match task {
            CtBuildApplied(_) => CtApplied(base_or_result, arguments)
            _ => CtFunction(arguments, base_or_result)
          },
        )
      }
    }
  }
  if results.length() != 1 {
    return Err(CtInvalidType)
  }
  Ok(results[0])
}

///|
fn compile_time_read_arguments(
  module_ : PlannedModuleLowering,
  arguments : HirSpan,
  bindings : Map[CompileTimeBindingKey, CompileTimeType],
) -> Result[Array[CompileTimeType], CompileTimeTypeError] {
  if !program_specialization_span_is_valid(
      arguments,
      module_.call_type_arguments.length(),
    ) {
    return Err(CtInvalidType)
  }
  let result : Array[CompileTimeType] = []
  for offset in 0..<arguments.length {
    match
      compile_time_read_type(
        module_,
        module_.call_type_arguments[arguments.start + offset],
        bindings,
      ) {
      Ok(type_) => result.push(type_)
      Err(error) => return Err(error)
    }
  }
  Ok(result)
}
