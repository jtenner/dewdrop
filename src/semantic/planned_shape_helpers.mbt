///|
pub fn planned_reference_shape() -> PlannedValueShape {
  RefPlannedValueShape
}

///|
pub fn planned_i32_shape() -> PlannedValueShape {
  I32PlannedValueShape
}

///|
pub fn PlannedLocal::with_shape(
  self : PlannedLocal,
  shape : PlannedValueShape,
) -> PlannedLocal {
  { ..self, shape, }
}
