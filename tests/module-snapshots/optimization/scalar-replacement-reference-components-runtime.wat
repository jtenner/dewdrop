(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param (ref 0) (ref 0)) (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 1) (param (ref 0) (ref 0)) (result i32)
    (local (ref 0) (ref 0))
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    i32.add
  )
  (func (;1;) (type 2) (result i32)
    i32.const 20
    struct.new 0
    i32.const 22
    struct.new 0
    call 0
  )
)
