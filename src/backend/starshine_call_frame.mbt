///|
priv struct StarshineCallFrameParameters {
  values : Array[@semantic.PlannedWasmValueType]
  start : Int
  length : Int
}

///|
fn starshine_call_frame_parameters(
  fragments : @semantic.PlannedModuleWasmGCFragments,
  span : @semantic.HirSpan,
) -> StarshineCallFrameParameters {
  {
    values: fragments.function_value_types,
    start: span.start,
    length: span.length,
  }
}

///|
fn StarshineCallFrameParameters::empty() -> StarshineCallFrameParameters {
  { values: [], start: 0, length: 0, }
}
