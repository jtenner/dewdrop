(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i32) (result i32)
    local.get 0
    i32.const 99
    i32.mul
  )
  (func (;1;) (type 1) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;2;) (type 2) (result i32)
    i32.const 41
    call 1
  )
)
