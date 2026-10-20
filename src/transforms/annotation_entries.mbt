///|
// Resolve the same annotation entries that expansion will execute. Helper
// reachability belongs to the checked semantic planner, not this source view.
pub fn Plan::annotation_entries(
  self : Plan,
  output_module_count~ : Int32 = -1,
) -> Result[Array[(Int32, String)], String] {
  let entries : Map[String, (Int32, String)] = {}
  for mi, files in self.files {
    for file in files {
      for function in file.functions {
        if function.transform {
          entries[self.modules[mi].path + "::" + function.declaration.name] = (
            mi,
            function.declaration.name,
          )
        }
      }
    }
  }
  let machine : Machine = {
    plan: self,
    steps: 100_000,
    depth: 0,
    allocated: 0,
    file_index: 0,
    frame: "",
    functions: {},
    imports: {},
    globals: {},
    initializing: {},
    text_storage: {},
    memory: None,
    render_source: DefaultValue,
    render_replacement: "",
    bytecode_enabled: true,
    bytecode: {},
    bytecode_compile_work: 1048576,
    bytecode_bytes_left: 8388608,
  }
  let result = []
  let seen : Map[String, Bool] = {}
  for mi, files in self.files {
    if output_module_count >= 0 && mi >= output_module_count {
      break
    }
    for file in files {
      for function in file.functions {
        if function.transform {
          continue
        }
        for annotation in file.annotations {
          if annotation.target < function.start ||
            annotation.target >= function.declaration.name_offset.to_int() {
            continue
          }
          machine.steps = 100_000
          machine.allocated = 0
          let key = machine.annotation_key(mi, annotation.name) catch {
            Failed(message) => return Err(message)
            _ => return Err("invalid annotation entry control flow")
          }
          let entry = match entries.get(key) {
            Some(value) => value
            None => return Err("annotation must name a transform fn: " + key)
          }
          if !seen.contains(key) {
            seen[key] = true
            result.push(entry)
          }
        }
      }
    }
  }
  Ok(result)
}
