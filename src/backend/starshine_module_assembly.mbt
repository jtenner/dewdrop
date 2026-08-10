///|
pub fn emit_starshine_code_section(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Result[@lib.CodeSec, StarshineCodeEmissionError] {
  let functions : Array[@lib.Func] = []
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmDefinedFunction(body) =>
        if !function_.elided {
          match emit_starshine_function_body(lowering, planned, body) {
            Ok(function_body) => functions.push(function_body)
            Err(error) => return Err(error)
          }
        }
      @semantic.PlannedWasmDefinedLambdaFunction(lambda) =>
        if !function_.elided {
          match
            emit_starshine_lambda_body(lowering, planned, None, -1, lambda) {
            Ok(function_body) => functions.push(function_body)
            Err(error) => return Err(error)
          }
        }
      @semantic.PlannedWasmTraitAdapterFunction(implementation_method, _) =>
        if !function_.elided {
          match
            emit_starshine_trait_adapter_body(
              planned, function_, implementation_method,
            ) {
            Ok(function_body) => functions.push(function_body)
            Err(error) => return Err(error)
          }
        }
      @semantic.PlannedWasmRuntimeFunction(name) =>
        if !function_.elided {
          if name == b"dew_test_assert" {
            functions.push(
              starshine_test_assert_body(
                planned.runtime_function_index(b"dew_string_as_bytes"),
                planned.runtime_function_index(b"dew_wasi_fd_write"),
              ),
            )
          } else {
            match
              emit_starshine_text_runtime_function(
                name,
                starshine_text_runtime_base(planned),
                planned.runtime_function_index(b"dew_bytes_is_valid_utf8"),
                planned.imported_function_index(
                  b"wasi_snapshot_preview1.fd_write",
                ),
                planned.imported_function_index(
                  b"wasi_snapshot_preview1.fd_read",
                ),
              ) {
              Some(function_body) => functions.push(function_body)
              None => return Err(UnsupportedBuiltin(name))
            }
          }
        }
      @semantic.PlannedWasmImportedFunction(_)
      | @semantic.PlannedWasmInlineBuiltinFunction(_)
      | @semantic.PlannedWasmSignatureOnlyFunction => ()
    }
  }
  Ok(@lib.CodeSec::new(functions))
}

///|
fn starshine_module_uses_wasi(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Bool {
  for function_ in planned.functions {
    if function_.elided {
      continue
    }
    match function_.kind {
      @semantic.PlannedWasmRuntimeFunction(name) =>
        if name == b"dew_wasi_fd_write" ||
          name == b"dew_wasi_fd_read" ||
          name == b"dew_test_assert" {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
pub fn emit_starshine_export_section(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> @lib.ExportSec {
  let exports : Array[@lib.Export] = []
  for function_ in planned.functions {
    let is_public = match function_.visibility {
      @semantic.Public => true
      @semantic.ModuleVisible => false
    }
    if (is_public || function_.is_test_entry) && function_.function_index >= 0 {
      exports.push(
        @lib.Export::new(
          @lib.Name::from_string(@utf8.decode_lossy(function_.name)),
          @lib.ExternIdx::func(
            @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
          ),
        ),
      )
    }
  }
  if starshine_module_uses_wasi(planned) {
    exports.push(
      @lib.Export::new(
        @lib.Name::from_string("memory"),
        @lib.ExternIdx::mem(@lib.MemIdx::new(0U)),
      ),
    )
  }
  @lib.ExportSec::new(exports)
}

///|
fn starshine_function_reference_element_section(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> @lib.ElemSec? {
  let referenced : Map[Int, Bool] = Map::default()
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmTraitAdapterFunction(_, _) if function_.function_index >=
        0 => referenced[function_.function_index] = true
      _ => ()
    }
  }
  for expression in lowering.expressions {
    match expression.kind {
      @semantic.PlannedFunctionReference(declaration, _) =>
        match planned.function_of(declaration) {
          Some(function_) if function_.function_index >= 0 =>
            referenced[function_.function_index] = true
          _ => ()
        }
      @semantic.PlannedLambdaClosure(lambda, _) => {
        let function_index = planned.functions[planned.lambda_function_indices[lambda]].function_index
        if function_index >= 0 {
          referenced[function_index] = true
        }
      }
      _ => ()
    }
  }
  if referenced.length() == 0 {
    return None
  }
  let functions : Array[@lib.FuncIdx] = []
  for function_ in planned.functions {
    if referenced.contains(function_.function_index) {
      functions.push(
        @lib.FuncIdx::new(function_.function_index.reinterpret_as_uint()),
      )
    }
  }
  Some(
    @lib.ElemSec::new([
      @lib.Elem::new(
        @lib.ElemMode::declarative(),
        @lib.ElemKind::funcs(functions),
      ),
    ]),
  )
}

///|
fn starshine_default_memory_section() -> @lib.MemSec {
  @lib.MemSec::new([@lib.MemType::new(@lib.Limits::i32(1U, None))])
}

///|
pub fn emit_starshine_module(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Result[@lib.Module, StarshineCodeEmissionError] {
  match emit_starshine_code_section(lowering, planned) {
    Ok(code) => {
      let mut module_ = @lib.Module::new()
        .with_type_sec(emit_starshine_type_section(planned))
        .with_import_sec(emit_starshine_import_section(planned))
        .with_func_sec(emit_starshine_function_section(planned))
        .with_export_sec(emit_starshine_export_section(planned))
        .with_code_sec(code)
      match starshine_function_reference_element_section(lowering, planned) {
        Some(elements) => module_ = module_.with_elem_sec(elements)
        None => ()
      }
      Ok(
        if planned.uses_linear_memory {
          module_.with_mem_sec(starshine_default_memory_section())
        } else {
          module_
        },
      )
    }
    Err(error) => Err(error)
  }
}

///|
/// Constructs, validates, and encodes one complete Starshine module from
/// frozen lowering and fragment plans. No semantic selection is repeated.
pub fn emit_starshine_binary(
  lowering : @semantic.PlannedModuleLowering,
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Result[Bytes, StarshineBinaryEmissionError] {
  let module_ = match emit_starshine_module(lowering, planned) {
    Ok(module_) => module_
    Err(error) => return Err(StarshineCodeError(error))
  }
  match @validate.validate_module(module_) {
    Ok(_) => ()
    Err(error) => return Err(StarshineValidationError(error))
  }
  match @binary.encode_module(module_) {
    Ok(bytes) => Ok(bytes)
    Err(error) => Err(StarshineEncodingError(error))
  }
}
