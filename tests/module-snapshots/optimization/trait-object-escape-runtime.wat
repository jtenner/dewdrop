(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32) (result i32)
    local.get 0
  )
  (func (;1;) (type 1) (result i32)
    i32.const 42
    call 0
  )
)
