(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param (ref 0)) (result (ref 0))))
  (type (;2;) (func (param eqref) (result eqref)))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (param eqref) (result eqref)))
  (export "main" (func 1))
  (func (;0;) (type 1) (param (ref 0)) (result (ref 0))
    local.get 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 3) (result i32)
    (local (ref 0))
    i32.const 21
    struct.new 0
    local.set 0
    local.get 0
    call 0
    struct.get 0 0
    local.get 0
    call 2
    ref.cast (ref 0)
    struct.get 0 0
    i32.add
  )
  (func (;2;) (type 4) (param eqref) (result eqref)
    local.get 0
  )
)
