(module
  (type (;0;) (struct))
  (type (;1;) (func (param (ref 0)) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 1) (param (ref 0)) (result i32)
    i32.const 1
  )
  (func (;1;) (type 2) (result i32)
    struct.new 0
    call 0
  )
)
