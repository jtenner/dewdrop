///|
struct SourceRepair {
  start : Int32
  end : Int32
  name : String
}

///|
struct AppliedFunction {
  function : SourceFunction
  file : ParsedFile
  node : Value
  original_source : Value
  signature : String
  changed : Bool
  bridge : String?
  imports : Array[String]
  declarations : Array[String]
  steps : Int32
  allocated : Int32
}

///|
pub fn Plan::add_signature_call(
  self : Plan,
  mi : Int32,
  path : String,
  offset : UInt64,
  target_module : Int32,
  target_path : String,
  target_offset : UInt64,
) -> Unit {
  guard mi >= 0 &&
    mi < self.files.length() &&
    target_module >= 0 &&
    target_module < self.files.length() else {
    return
  }
  let (target_path, target_offset) = self.validation_targets
    .get((target_module, target_path))
    .unwrap_or((target_path, target_offset))
  for fi, file in self.files[mi] {
    if file.file.path != path || offset >= file.clean.length().to_uint64() {
      continue
    }
    for ti, target in self.files[target_module] {
      if target.file.path != target_path {
        continue
      }
      for function in target.functions {
        if function.declaration.offset == target_offset &&
          target.annotations.any(a => {
            a.target >= function.start &&
            a.target < function.declaration.name_offset.to_int()
          }) {
          let site = (mi, fi, offset.to_int())
          let target = (target_module, ti, target_offset)
          if self.signature_calls.get(site) is Some(previous) &&
            previous != target {
            self.signature_error = "conflicting checked signature targets at one source site"
            return
          }
          self.signature_calls[site] = target
          return
        }
      }
    }
  }
}

///|
fn Machine::adapter_name(
  self : Machine,
  function : SourceFunction,
) -> String raise EvalError {
  let occupied = match self.plan.adapter_names.get(function.module_) {
    Some(names) => names
    None => {
      let names : Map[String, Bool] = {}
      for file in self.plan.files[function.module_] {
        self.charge(file.clean.length())
        for token in @tokenizer.tokens(file.clean) {
          self.charge(0)
          if token.kind() is @tokenizer.Identifier(name) &&
            !names.contains(name) {
            self.charge(32 + bytes(name).length())
            names[name] = true
          }
        }
      }
      self.plan.adapter_names[function.module_] = names
      names
    }
  }
  let base = "__dew_transform_adapter_" +
    function.module_.to_string() +
    "_" +
    function.file.to_string() +
    "_" +
    function.start.to_string()
  let mut counter = 0
  while true {
    self.charge(32)
    let name = base + "_" + counter.to_string()
    if !occupied.contains(name) {
      occupied[name] = true
      return name
    }
    counter += 1
  } nobreak {
    abort("unreachable adapter name search")
  }
}

///|
fn Plan::source_repairs(
  self : Plan,
  bridges : Map[(Int32, Int32, UInt64), String],
) -> Map[(Int32, Int32), Array[SourceRepair]] raise EvalError {
  let result : Map[(Int32, Int32), Array[SourceRepair]] = {}
  let seen : Map[(Int32, Int32, Int32), String] = {}
  let inserted : Map[(Int32, Int32), Int32] = {}
  let token_cache : Map[(Int32, Int32), Array[@tokenizer.Token]] = {}
  let target_names : Map[(Int32, Int32, UInt64), String] = {}
  for (mi, fi, offset), target in self.signature_calls {
    guard bridges.get(target) is Some(bridge) else { continue }
    let target_name = target_names.get_or_init(target, fn() {
      let (target_mi, target_fi, target_offset) = target
      for function in self.files[target_mi][target_fi].functions {
        if function.declaration.offset == target_offset {
          return function.declaration.name
        }
      }
      ""
    })
    guard target_name != "" else {
      raise Failed("checked signature repair lost its target declaration")
    }
    let source = self.files[mi][fi].clean
    let tokens = token_cache.get_or_init((mi, fi), fn() {
      @tokenizer.tokens(source).collect()
    })
    let begin = loop (0, tokens.length()) {
      (low, high) if low < high => {
        let middle = low + (high - low) / 2
        if tokens[middle].offset().to_int() < offset {
          continue (middle + 1, high)
        } else {
          continue (low, middle)
        }
      }
      (low, _) => break low
    }
    let mut start = -1
    let mut end = -1
    for index in begin..<Int32::min(begin + 8, tokens.length()) {
      let token = tokens[index]
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftParen) if start < 0 => ()
        @tokenizer.AtIdentifier(_) if start < 0 => ()
        @tokenizer.Symbol(@tokenizer.Dot) if start < 0 => ()
        @tokenizer.Identifier(name) if name == target_name => {
          start = token.offset().to_int()
          end = start + bytes(name).length()
          break
        }
        _ => break
      }
    }
    guard start >= 0 && end <= source.length() else {
      raise Failed("checked signature repair lost its function reference site")
    }
    let site = (mi, fi, start)
    if seen.get(site) is Some(previous) {
      guard previous == bridge else {
        raise Failed("conflicting checked signature repairs")
      }
      continue
    }
    let used = inserted.get((mi, fi)).unwrap_or(0)
    guard bytes(bridge).length() <= 1048576 - used else {
      raise Failed("generated call repair size limit exceeded")
    }
    inserted[(mi, fi)] = used + bytes(bridge).length()
    seen[site] = bridge
    result
    .get_or_init((mi, fi), fn() { [] })
    .push({ start, end, name: bridge, })
  }
  for _, repairs in result {
    repairs.sort_by(fn(left, right) { left.start.compare(right.start) })
    let mut end = 0
    for repair in repairs {
      guard repair.start >= end else {
        raise Failed("overlapping checked signature repairs")
      }
      end = repair.end
    }
  }
  result
}

///|
fn repaired_part(
  source : Bytes,
  start : Int32,
  end : Int32,
  repairs : Array[SourceRepair],
) -> String {
  let out = @buffer.new()
  let mut cursor = start
  let first = loop (0, repairs.length()) {
    (low, high) if low < high => {
      let middle = low + (high - low) / 2
      if repairs[middle].start < start {
        continue (middle + 1, high)
      } else {
        continue (low, middle)
      }
    }
    (low, _) => break low
  }
  for index in first..<repairs.length() {
    let repair = repairs[index]
    if repair.start >= end {
      break
    }
    if repair.start >= cursor && repair.end <= end {
      out.write_bytes(source[cursor:repair.start])
      out.write_string_utf8(repair.name)
      cursor = repair.end
    }
  }
  out.write_bytes(source[cursor:end])
  text(out.to_bytes())
}
