(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (result i32)
    unreachable
  )
  (func (;1;) (type 1) (result i32)
    (local i32 i32)
    i32.const 1
    local.set 0
    call 0
    local.set 1
    local.get 0
    local.get 1
    i32.add
  )
)
