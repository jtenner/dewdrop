///|
test "each stacked annotation retains its own resource report" {
  let plan = fixture("import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n @ast.with_body(node, @ast.integer(42i32))\n}\n#replace\n#replace\npub fn main() -> I32 {\n 0i32\n}\n")
  let _ = expanded(plan)
  let reports = plan.reports()
  assert_eq(reports.length(), 2)
  for report in reports {
    assert_eq(report.module_name, "app")
    assert_eq(report.file_name, "main.dew")
    assert_eq(report.function_name, "main")
    assert_eq(report.transform_name, "app::replace")
    assert_true(report.work > 0U && report.work <= 100000U)
    assert_true(report.allocation_work > 0U && report.allocation_work <= 4194304U)
  }
  assert_true(reports[0].offset < reports[1].offset)
  reports.clear()
  assert_eq(plan.reports().length(), 2)
}
