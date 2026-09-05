(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\01\00\01\81\e0\80\02\00\00\00\00\00\00\00\00\01\00\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\00\00\01\00\00\01\02\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\00\00")
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i64) (result i64)))
  (type (;2;) (func (result i32)))
  (memory (;0;) 1)
  (export "main" (func 0))
  (func (;0;) (type 2) (result i32)
    (local i32)
    i32.const 305419896
    local.set 0
    i32.const 17
    local.get 0
    i32.store
    i32.const 17
    i32.load
  )
)
