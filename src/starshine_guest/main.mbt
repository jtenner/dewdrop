///|
/// The concrete Starshine export linked by the experimental Dew pipeline.
#export_name("module_new")
pub fn module_new() -> @lib.Module {
  @lib.Module::new()
}

///|
/// Exercises the Dew String to MoonBit String linker adapter.
#export_name("module_new_named")
pub fn module_new_named(name : String) -> @lib.Module {
  ignore(name)
  @lib.Module::new()
}
