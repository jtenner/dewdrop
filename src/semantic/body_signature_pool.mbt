///|
// A lowering-owned extension. Never append body types to a frozen interface.
priv struct BodySignaturePool {
  types : Array[ResolvedType]
  arguments : Array[ResolvedTypeId]
  buckets : Map[Int, Array[ResolvedTypeId]]
}

///|
fn body_signature_parts(type_ : ResolvedType) -> (Int, Int, HirSpan)? {
  match type_ {
    ProductType(span) => Some((1, -1, span))
    AppliedType(base, span) => Some((2, base, span))
    FunctionType(span, result) => Some((3, result, span))
    _ => None
  }
}

///|
fn body_signature_hash(
  kind : Int,
  extra : Int,
  arguments : Array[Int],
  span : HirSpan,
) -> Int {
  guard arena_span_is_valid(span, arguments.length()) else {
    abort("body signature argument span is outside its arena")
  }
  let mut hash = type_hash_mix(kind, extra)
  for index in 0..<span.length {
    hash = type_hash_mix(hash, arguments[span.start + index])
  }
  type_hash_mix(hash, span.length)
}

///|
fn BodySignaturePool::new(resolved : ResolvedModuleTypes) -> BodySignaturePool {
  let pool = {
    types: resolved.types.copy(),
    arguments: resolved.type_arguments.copy(),
    buckets: Map::default(),
  }
  for index, type_ in pool.types {
    match body_signature_parts(type_) {
      Some((kind, extra, span)) => {
        let hash = body_signature_hash(kind, extra, pool.arguments, span)
        match pool.buckets.get(hash) {
          Some(bucket) => bucket.push(index)
          None => pool.buckets[hash] = [index]
        }
      }
      None => ()
    }
  }
  pool
}

///|
fn BodySignaturePool::intern(
  self : BodySignaturePool,
  kind : Int,
  extra : Int,
  arguments : Array[Int],
) -> Int {
  let hash = body_signature_hash(kind, extra, arguments, {
    start: 0,
    length: arguments.length(),
  })
  let bucket = match self.buckets.get(hash) {
    Some(value) => value
    None => {
      let value = []
      self.buckets[hash] = value
      value
    }
  }
  for candidate in bucket {
    let (candidate_kind, candidate_extra, span) = body_signature_parts(
      self.types[candidate],
    ).unwrap()
    if kind != candidate_kind ||
      extra != candidate_extra ||
      span.length != arguments.length() {
      continue
    }
    let mut equal = true
    for index in 0..<span.length {
      if self.arguments[span.start + index] != arguments[index] {
        equal = false
        break
      }
    }
    if equal {
      return candidate
    }
  }
  let span = { start: self.arguments.length(), length: arguments.length(), }
  self.arguments.append(arguments)
  let type_ = match kind {
    1 => ProductType(span)
    2 => AppliedType(extra, span)
    3 => FunctionType(span, extra)
    _ => abort("body signature has an invalid compound kind")
  }
  let index = self.types.length()
  self.types.push(type_)
  bucket.push(index)
  index
}

///|
fn body_signature_resolved_id(
  inferred : InferredModuleBodies,
  type_ : BodyTypeId,
  mapping : Array[Int],
  resolved_count : Int,
) -> Int {
  match inferred.type_term(type_) {
    BodyResolvedType(index) => {
      guard index >= 0 && index < resolved_count else {
        abort("body signature resolved type is outside its arena")
      }
      index
    }
    _ => mapping[type_]
  }
}

///|
fn materialize_body_function_types(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
) -> ResolvedModuleTypes {
  let roots : Array[Int] = []
  for index, type_ in inferred.types {
    if type_ is BodyFunctionType(_, _) {
      roots.push(index)
    }
  }
  if roots.is_empty() {
    return resolved
  }
  let pool = BodySignaturePool::new(resolved)
  let mapping = Array::make(inferred.types.length(), -1)
  let state = Array::make(inferred.types.length(), 0)
  let work : Array[(BodyTypeId, Bool)] = []
  for root in roots {
    work.push((root, false))
    while !work.is_empty() {
      let (type_, finish) = work.pop().unwrap()
      if type_ < -1 {
        ignore(
          body_signature_resolved_id(
            inferred,
            type_,
            mapping,
            resolved.types.length(),
          ),
        )
        continue
      }
      guard type_ >= 0 && type_ < state.length() else {
        abort("body signature type is outside its arena")
      }
      if state[type_] == 2 {
        continue
      }
      let (kind, extra, span) = match inferred.type_term(type_) {
        BodyResolvedType(_) => {
          mapping[type_] = body_signature_resolved_id(
            inferred,
            type_,
            mapping,
            resolved.types.length(),
          )
          state[type_] = 2
          continue
        }
        BodyErrorType | BodyVariableType(_) => {
          // Missing logical evidence stays missing. It cannot form a signature.
          state[type_] = 2
          continue
        }
        BodyProductType(span) => (1, -1, span)
        BodyAppliedType(base, span) => (2, base, span)
        BodyFunctionType(span, result) => (3, result, span)
        BodyMemberTypeProjection(owner, _, _) =>
          (4, owner, { start: 0, length: 0, })
      }
      guard arena_span_is_valid(span, inferred.type_arguments.length()) else {
        abort("body signature child span is outside its arena")
      }
      if !finish {
        guard state[type_] == 0 else {
          abort("body signature type graph contains a cycle")
        }
        state[type_] = 1
        work.push((type_, true))
        if kind != 1 {
          work.push((extra, false))
        }
        for index = span.length - 1; index >= 0; index = index - 1 {
          work.push((inferred.type_arguments[span.start + index], false))
        }
      } else {
        let arguments : Array[Int] = []
        let mut complete = true
        for index in 0..<span.length {
          let argument = body_signature_resolved_id(
            inferred,
            inferred.type_arguments[span.start + index],
            mapping,
            resolved.types.length(),
          )
          arguments.push(argument)
          if argument < 0 || pool.types[argument] is ErrorType {
            complete = false
          }
        }
        let resolved_extra = if kind == 1 {
          -1
        } else {
          body_signature_resolved_id(
            inferred,
            extra,
            mapping,
            resolved.types.length(),
          )
        }
        if kind != 1 &&
          (resolved_extra < 0 || pool.types[resolved_extra] is ErrorType) {
          complete = false
        }
        if complete {
          mapping[type_] = if inferred.type_term(type_)
            is BodyMemberTypeProjection(_, operation, selector) {
            let projected = MemberTypeProjection(
              resolved_extra, operation, selector,
            )
            let mut selected = -1
            for index, candidate in pool.types {
              if candidate == projected {
                selected = index
                break
              }
            }
            if selected < 0 {
              selected = pool.types.length()
              pool.types.push(projected)
            }
            selected
          } else {
            pool.intern(kind, resolved_extra, arguments)
          }
        }
        state[type_] = 2
      }
    }
  }
  { ..resolved, types: pool.types, type_arguments: pool.arguments, }
}
