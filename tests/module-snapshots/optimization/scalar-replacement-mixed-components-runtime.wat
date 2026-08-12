(module
  (type (;0;) (func (param i32 i32 i32) (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32 i32 i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 4
    local.get 1
    drop
    local.get 2
    local.set 3
    local.get 3
    drop
    local.get 4
    local.get 3
    i32.add
  )
  (func (;1;) (type 1) (result i32)
    i32.const 20
    i32.const 1
    i32.const 22
    call 0
  )
)
