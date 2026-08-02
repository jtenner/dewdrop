(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i32) (result i32)
    local.get 0
  )
  (func (;1;) (type 1) (param i32) (result i32)
    local.get 0
  )
  (func (;2;) (type 2) (result i32)
    i32.const 127
    i32.const 1
    i32.add
    i32.extend8_s
    call 0
    i32.const 255
    i32.const 1
    i32.add
    i32.const 255
    i32.and
    call 1
    i32.add
  )
)
