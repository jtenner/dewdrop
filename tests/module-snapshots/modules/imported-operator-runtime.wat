(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param (ref 0) (ref 0)) (result (ref 0))))
  (type (;2;) (func (param i32) (result (ref 0))))
  (type (;3;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 1) (param (ref 0) (ref 0)) (result (ref 0))
    local.get 0
    struct.get 0 0
    local.get 1
    struct.get 0 0
    i32.add
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 2) (param i32) (result (ref 0))
    local.get 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;2;) (type 3) (result i32)
    i32.const 20
    call 1
    i32.const 22
    call 1
    call 0
    struct.get 0 0
  )
)
