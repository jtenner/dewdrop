(module
  (type (;0;) (func (result i32)))
  (export "main" (func 0))
  (func (;0;) (type 0) (result i32)
    (local v128)
    i32.const 7
    i32x4.splat
    local.set 0
    local.get 0
    i32.const 9
    i32x4.replace_lane 0
    local.get 0
    i32x4.add
    i32x4.extract_lane 0
  )
)
