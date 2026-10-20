///|
enum SourceMemberState {
  Absent
  Present
  Overloaded
  Shadowed
}

///|
struct SourceMember {
  mut local : SourceMemberState
  mut exported : SourceMemberState
}

///|
struct SourceModuleIndex {
  members : Map[String, SourceMember]
  aliases : Map[String, String?]
  opens : Array[(String, Bool)]
  fresh_names : Map[String, Int32]
}

///|
struct SourceIndex {
  modules : Map[String, Int32]
  sources : Array[SourceModuleIndex]
  module_count : Int32
  transforms : Map[String, Bool]
  entries : Map[String, CallTarget]
}

///|
fn source_member_add(
  state : SourceMemberState,
  supported : Bool,
) -> SourceMemberState {
  match state {
    Overloaded | Shadowed => state
    _ if !supported => Shadowed
    Absent => Present
    _ => Overloaded
  }
}

///|
// Scanning stores annotation targets in source order, including stacked targets.
fn ParsedFile::has_annotation(
  self : ParsedFile,
  function : @parser.FunctionDeclaration,
) -> Bool {
  let start = loop (0, self.annotations.length()) {
    (low, high) if low < high => {
      let middle = low + (high - low) / 2
      if self.annotations[middle].target.to_uint64() < function.offset {
        continue (middle + 1, high)
      } else {
        continue (low, middle)
      }
    }
    (low, _) => break low
  }
  start < self.annotations.length() &&
  self.annotations[start].target.to_uint64() < function.name_offset
}

///|
fn Plan::source_index(self : Plan) -> SourceIndex {
  if self.source_lookup is Some(index) &&
    index.module_count == self.modules.length() {
    return index
  }
  let modules : Map[String, Int32] = {}
  let sources = []
  let transforms : Map[String, Bool] = {}
  let entries : Map[String, CallTarget] = {}
  for mi, module_ in self.modules {
    if !modules.contains(module_.path) {
      modules[module_.path] = mi
    }
    let members : Map[String, SourceMember] = {}
    let aliases : Map[String, String?] = {}
    let opens = []
    let fresh_names : Map[String, Int32] = {}
    for fi, file in self.files.get(mi).unwrap_or([]) {
      index_fresh_names(file.file.source, fresh_names)
      for function in file.functions {
        if function.transform {
          transforms[module_.path + "::" + function.declaration.name] = true
        }
      }
      for declaration in file.declarations {
        match declaration {
          @parser.Function(function) => {
            let key = module_.path + "::" + function.name
            if !entries.contains(key) {
              entries[key] = Source(mi, fi, function, "")
            }
          }
          @parser.Builtin(builtin) => {
            let key = module_.path + "::" + builtin.name
            if !entries.contains(key) {
              entries[key] = Intrinsic(builtin, "")
            }
          }
          @parser.Enum(enum_) =>
            for variant in enum_.variants {
              let key = module_.path + "::" + enum_.name + "::" + variant.name()
              if !entries.contains(key) {
                entries[key] = if variant is @parser.UnitVariant(_, _) {
                  UnitConstructor(key)
                } else {
                  Constructor(key)
                }
              }
            }
          _ => ()
        }
        if declaration is @parser.Import(value) {
          let path = value.path.join(".")
          if value.open_ {
            opens.push((path, value.wildcard))
          } else {
            let alias = value.import_alias.unwrap_or(value.path.last().unwrap())
            match aliases.get(alias) {
              Some(Some(previous)) if previous != path => aliases[alias] = None
              Some(_) => ()
              None => aliases[alias] = Some(path)
            }
          }
        }
        let entry = match declaration {
          @parser.Function(d) =>
            Some((d.name, d.visibility is @parser.Public, true))
          @parser.Struct(d) =>
            Some((d.name, d.visibility is @parser.Public, true))
          @parser.Enum(d) =>
            Some((d.name, d.visibility is @parser.Public, true))
          @parser.Builtin(d) =>
            Some((d.name, d.visibility is @parser.Public, true))
          @parser.Let(d) =>
            Some((d.name, d.visibility is @parser.Public, false))
          @parser.Trait(d) =>
            Some((d.name, d.visibility is @parser.Public, false))
          @parser.TypeAlias(d) =>
            Some((d.name, d.visibility is @parser.Public, false))
          @parser.ForeignType(d) =>
            Some((d.name, d.visibility is @parser.Public, false))
          @parser.ForeignLibrary(d) => Some((d.namespace_alias, false, false))
          _ => None
        }
        if entry is Some((name, public_, supported)) {
          let member = members.get_or_init(name, fn() {
            { local: Absent, exported: Absent, }
          })
          member.local = source_member_add(member.local, supported)
          if public_ {
            member.exported = source_member_add(member.exported, supported)
          }
        }
      }
    }
    sources.push({ members, aliases, opens, fresh_names, })
  }
  let index = {
    modules,
    sources,
    transforms,
    entries,
    module_count: self.modules.length(),
  }
  self.source_lookup = Some(index)
  index
}
