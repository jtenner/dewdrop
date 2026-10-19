///|
/// Logical interpreter work, not host elapsed time or retained heap bytes.
pub(all) struct TransformReport {
  module_name : String
  file_name : String
  function_name : String
  transform_name : String
  offset : UInt
  work : UInt
  allocation_work : UInt
} derive(Eq, Debug)

///|
pub fn Plan::reports(self : Plan) -> Array[TransformReport] {
  self.reports.copy()
}
