///|
enum FunctionIdentity {
  FunctionInstance
  FunctionSingleton(UInt64)
  GenericFunctionSingleton(UInt64)
}

///|
struct FunctionReferenceProof {
  target : CallTarget
  identity : FunctionIdentity
}

///|
fn function_identity_equal(left : FunctionIdentity, right : FunctionIdentity) -> Bool raise EvalError {
  match (left, right) {
    (FunctionSingleton(a), FunctionSingleton(b)) => a == b
    (GenericFunctionSingleton(a), GenericFunctionSingleton(b)) => {
      guard a != b else {
        raise Failed("generic function reference identity needs a checked ABI identity")
      }
      false
    }
    (GenericFunctionSingleton(_), FunctionSingleton(_)) |
    (FunctionSingleton(_), GenericFunctionSingleton(_)) |
    (FunctionInstance, _) | (_, FunctionInstance) => false
  }
}
