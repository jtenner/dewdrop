(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func (param i32 i32) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 3
    local.get 1
    local.set 2
    local.get 3
    local.get 2
    i32.add
  )
  (func (;1;) (type 1) (param i32 i32) (result i32)
    (local i32)
    local.get 0
    drop
    local.get 1
    local.set 2
    local.get 2
  )
  (func (;2;) (type 2) (result i32)
    i32.const 20
    i32.const 22
    call 0
    i32.const 1
    i32.const 1
    call 1
    i32.add
  )
)
