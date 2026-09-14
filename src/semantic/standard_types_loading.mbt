///|
// Source discovery only. No semantic or emission rule depends on this path.
fn standard_types_requested(files : Array[ProgramFile]) -> Bool {
  for file in files {
    let events = file.events()
    while true {
      match events.next() {
        Some(@parser.Declaration(@parser.Import(import_))) =>
          if import_.path == ["dew", "std", "types"] ||
            (import_.wildcard && import_.path == ["dew", "std"]) {
            return true
          }
        Some(@parser.Diagnostic(_)) => ()
        Some(@parser.Declaration(_)) | None => break
      }
    }
  }
  false
}
