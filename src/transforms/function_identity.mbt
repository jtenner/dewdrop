///|
enum FunctionIdentity {
  FunctionInstance
  FunctionSingleton(UInt64)
  FunctionSpecialization(UInt64, UInt32)
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
    (FunctionSpecialization(a, key), FunctionSpecialization(b, other)) => a == b && key == other
    (GenericFunctionSingleton(a), FunctionSpecialization(b, _)) |
    (FunctionSpecialization(a, _), GenericFunctionSingleton(b)) |
    (GenericFunctionSingleton(a), GenericFunctionSingleton(b)) => {
      guard a != b else {
        raise Failed("generic function reference identity needs a checked ABI identity")
      }
      false
    }
    _ => false
  }
}
