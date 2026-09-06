///|
// Owner and method parameters need not be adjacent in the source arena.
// Instance arguments are ordered owner first, then method, never by a hull span.
pub struct CallableGenericParameters {
  owner : HirSpan
  method : HirSpan
  length : Int
} derive(Eq, Debug)

///|
pub fn PlannedCallable::all_generic_parameters(
  self : PlannedCallable,
) -> CallableGenericParameters {
  {
    owner: self.owner_generic_parameters,
    method: self.generic_parameters,
    length: self.owner_generic_parameters.length +
    self.generic_parameters.length,
  }
}

///|
pub fn CallableGenericParameters::source_index(
  self : CallableGenericParameters,
  index : Int,
) -> Int {
  guard index >= 0 && index < self.length else {
    abort("ARN-102 callable generic parameter is outside its logical sequence")
  }
  if index < self.owner.length {
    self.owner.start + index
  } else {
    self.method.start + index - self.owner.length
  }
}

///|
pub fn CallableGenericParameters::relative_index(
  self : CallableGenericParameters,
  source : Int,
) -> Int? {
  if source >= self.owner.start && source - self.owner.start < self.owner.length {
    Some(source - self.owner.start)
  } else if source >= self.method.start &&
    source - self.method.start < self.method.length {
    Some(self.owner.length + source - self.method.start)
  } else {
    None
  }
}
