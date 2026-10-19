///|
fn expanded_source_origin(
  path : String,
  originals : @semantic.ManifestModule,
) -> Json {
  if originals.files.any(file => file.path == path) {
    return Json::null()
  }
  let mut prefix_length = 0
  let mut origin = Json::null()
  for file in originals.files {
    let prefix = file.path + "::transform["
    if path.has_prefix(prefix) &&
      path.has_suffix("]") &&
      prefix.length() > prefix_length {
      prefix_length = prefix.length()
      origin = Json::object({
        "file": Json::string(file.path),
        "site": Json::string(
          path
          .substring(start=prefix.length(), end=path.length() - 1)
          .to_string(),
        ),
      })
    }
  }
  origin
}

///|
fn render_expanded_sources(
  expanded : @semantic.ProgramManifest,
  original : @semantic.ProgramManifest,
  reports : Array[@transforms.TransformReport],
) -> Bytes {
  let modules : Array[Json] = []
  for module_ in expanded.modules {
    let original_module = original.modules.iter().find_first(value => {
      value.path == module_.path
    })
    let files : Array[Json] = []
    for file in module_.files {
      let source = @utf8.decode(file.source) catch {
        _ => {
          cli_fail("expanded source is not valid UTF-8: " + file.path)
          abort("unreachable")
        }
      }
      let origin = match original_module {
        Some(module_) => expanded_source_origin(file.path, module_)
        None => Json::null()
      }
      let ranges : Array[Json] = []
      if origin != Json::null() {
        let offsets : Array[Int32] = []
        for event in @parser.parse_bytes(file.source) {
          if event is @parser.Declaration(declaration) {
            offsets.push(declaration.offset().to_int())
          }
        }
        for i, offset in offsets {
          let end = if i + 1 < offsets.length() {
            offsets[i + 1]
          } else {
            file.source.length()
          }
          ranges.push(
            Json::object({
              "start": Json::number(offset.to_double()),
              "end": Json::number(end.to_double()),
            }),
          )
        }
      }
      files.push(
        Json::object({
          "path": Json::string(file.path),
          "source": Json::string(source),
          "origin": origin,
          "ranges": Json::array(ranges),
        }),
      )
    }
    modules.push(
      Json::object({
        "name": Json::string(module_.path),
        "files": Json::array(files),
      }),
    )
  }
  @utf8.encode(
    Json::object({
      "version": Json::number(1.0),
      "modules": Json::array(modules),
      "transform_reports": Json::array(reports.map(report => Json::object({
        "module": Json::string(report.module_name),
        "file": Json::string(report.file_name),
        "function": Json::string(report.function_name),
        "transform": Json::string(report.transform_name),
        "offset": Json::number(report.offset.to_double()),
        "work": Json::number(report.work.to_double()),
        "allocation_work": Json::number(report.allocation_work.to_double()),
      }))),
    }).stringify(indent=2),
  )
}
