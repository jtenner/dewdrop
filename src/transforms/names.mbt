///|
pub fn Plan::add_type_name(
  self : Plan,
  mi : Int32,
  name : String,
  key : String,
) -> Unit {
  self.type_names[(mi, name)] = key
}
