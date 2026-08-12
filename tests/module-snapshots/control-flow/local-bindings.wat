(module
  (type (;0;) (func (result i32)))
  (export "main" (func 0))
  (func (;0;) (type 0) (result i32)
    (local i32 i32)
    i32.const 10
    local.set 0
    local.get 0
    i32.const 20
    i32.add
    local.set 1
    local.get 1
    i32.const 2
    i32.mul
    local.set 1
    local.get 1
    local.get 0
    i32.sub
  )
)
