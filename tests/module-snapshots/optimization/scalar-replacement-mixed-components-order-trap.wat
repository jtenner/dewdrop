(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 0) (result i32)
    unreachable
  )
  (func (;1;) (type 1) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 2) (result i32)
    (local i32 i32)
    i32.const 1
    local.set 1
    call 0
    drop
    call 1
    local.set 0
    local.get 0
    drop
    local.get 1
    local.get 0
    i32.add
  )
)
