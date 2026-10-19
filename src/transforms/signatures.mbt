///|
pub fn Plan::check_signatures(
  self : Plan,
  check : (Int32, String) -> Bool,
) -> Result[Unit, String] {
  for files in self.files {
    for file in files {
      for function in file.functions {
        if function.transform &&
          !check(function.module_, function.declaration.name) {
          return Err(
            file.file.path +
            ": error: invalid transform signature for " +
            function.declaration.name +
            "; expected fn(FnNode, TransformContext) -> FnNode or Result<FnNode, TransformError>",
          )
        }
      }
    }
  }
  Ok(())
}
