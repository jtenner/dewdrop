(module
  (type (;0;) (struct (field i32) (field i32)))
  (type (;1;) (func (param (ref 0)) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 1) (param (ref 0)) (result i32)
    local.get 0
    struct.get 0 0
    local.get 0
    struct.get 0 1
    i32.add
  )
  (func (;1;) (type 2) (result i32)
    i32.const 20
    i32.const 22
    struct.new 0
    call 0
  )
)
