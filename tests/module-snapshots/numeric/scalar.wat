(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
  )
  (func (;1;) (type 1) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.mul
    i32.const 7
    i32.sub
  )
  (func (;2;) (type 2) (result i32)
    i32.const 20
    i32.const 22
    call 0
    i32.const 5
    call 1
    i32.add
  )
)
