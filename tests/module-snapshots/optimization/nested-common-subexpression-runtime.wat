(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (struct (field (ref 0))))
  (type (;2;) (func (param (ref 1)) (result i32)))
  (type (;3;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 2) (param (ref 1)) (result i32)
    (local (ref 0) i32 i32)
    local.get 0
    struct.get 1 0
    ref.cast (ref 0)
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    local.set 2
    local.get 2
    local.set 3
    local.get 2
    local.get 3
    i32.add
  )
  (func (;1;) (type 3) (result i32)
    i32.const 21
    struct.new 0
    struct.new 1
    call 0
  )
)
