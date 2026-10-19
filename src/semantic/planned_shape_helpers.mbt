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

///|
pub fn PlannedCapture::with_shape(
  self : PlannedCapture,
  shape : PlannedValueShape,
) -> PlannedCapture {
  { ..self, shape, }
}
