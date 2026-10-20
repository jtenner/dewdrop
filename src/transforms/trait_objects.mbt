///|
pub(all) struct CheckedTraitMethod {
  requirement : UInt64
  slot : Int32
  module_index : Int32
  path : String
  offset : UInt64
  frame : String
}

///|
struct TraitObjectProof {
  methods : Map[UInt64, (String, CallTarget)]
}

///|
struct TraitObjectValue {
  receiver : Value
  proof : TraitObjectProof
}

///|
fn Plan::trait_source_method_index(
  self : Plan,
) -> Map[(Int32, String, UInt64), CallTarget] {
  if self.trait_source_methods is Some(index) {
    return index
  }
  let index : Map[(Int32, String, UInt64), CallTarget] = {}
  for mi, files in self.files {
    for fi, file in files {
      for declaration in file.declarations {
        if declaration is @parser.Impl(impl_) {
          for function in impl_.methods {
            index[(mi, file.file.path, function.offset)] = Source(
              mi, fi, function, "",
            )
          }
        }
      }
    }
  }
  self.trait_source_methods = Some(index)
  index
}

///|
fn Plan::trait_dictionary(
  self : Plan,
  trait_declaration : UInt64,
  methods : Array[CheckedTraitMethod],
) -> TraitObjectProof {
  let out = StringBuilder::new()
  out.write_string(trait_declaration.to_string() + ":")
  for method_ in methods {
    out.write_string(
      method_.requirement.to_string() +
      ":" +
      method_.slot.to_string() +
      ":" +
      method_.module_index.to_string() +
      ":" +
      method_.offset.to_string() +
      ":",
    )
    for text in [method_.path, method_.frame] {
      out.write_string(text.length().to_string() + ":")
      out.write_string(text)
    }
  }
  let key = out.to_string()
  let dictionaries = match self.trait_dictionaries {
    Some(value) => value
    None => {
      let value = Map::new()
      self.trait_dictionaries = Some(value)
      value
    }
  }
  if dictionaries.get(key) is Some(proof) {
    return proof
  }
  let sources = self.trait_source_method_index()
  let selected : Map[UInt64, (String, CallTarget)] = {}
  for method_ in methods {
    let target = sources
      .get((method_.module_index, method_.path, method_.offset))
      .unwrap_or(Unsupported)
    let target = if method_.frame == "" {
      target
    } else {
      Framed(target, method_.frame)
    }
    selected[method_.requirement] = (
      trait_declaration.to_string() + ":" + method_.slot.to_string(),
      target,
    )
  }
  let proof = { methods: selected, }
  dictionaries[key] = proof
  proof
}

///|
pub fn Plan::add_trait_object_proof(
  self : Plan,
  module_index : Int32,
  path : String,
  offset : UInt64,
  trait_declaration : UInt64,
  methods : Array[CheckedTraitMethod],
  frame~ : String = "",
) -> Unit {
  guard module_index >= 0 && module_index < self.files.length() else { return }
  let proof = self.trait_dictionary(trait_declaration, methods)
  for fi, file in self.files[module_index] {
    if file.file.path == path && offset < file.clean.length().to_uint64() {
      let site = (module_index, fi, offset.to_int())
      if frame == "" {
        self.trait_objects[site] = proof
      } else {
        self.execution_frame(frame).trait_objects[site] = proof
      }
    }
  }
}

///|
fn Machine::trait_object_proof(
  self : Machine,
  site : (Int32, Int32, Int32),
) -> TraitObjectProof? {
  if self.plan.frames.get(self.frame) is Some(frame) &&
    frame.trait_objects.get(site) is Some(proof) {
    return Some(proof)
  }
  self.plan.trait_objects.get(site)
}

///|
fn Machine::trait_object(
  self : Machine,
  receiver : Value,
  proof : TraitObjectProof,
) -> Value raise EvalError {
  self.charge(40)
  TraitObject({ receiver, proof, })
}

///|
fn Machine::dynamic_trait_call(
  self : Machine,
  requirement : UInt64,
  key : String,
  kind : String,
  values : Array[Value],
) -> Value raise EvalError {
  guard values.length() > 0 && values[0] is TraitObject(object_) else {
    return eval_fail("checked dynamic trait call requires a trait value")
  }
  guard object_.proof.methods.get(requirement) is Some((selected_key, method_)) &&
    selected_key == key else {
    return eval_fail("checked dynamic trait method slot mismatch")
  }
  values[0] = object_.receiver
  self.typed_value(self.bytecode_target(method_, values, Unit), kind)
}
