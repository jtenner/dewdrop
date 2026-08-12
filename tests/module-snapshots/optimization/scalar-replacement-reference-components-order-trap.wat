(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (struct (field (ref 0)) (field (ref 0))))
  (type (;2;) (func (result (ref 0))))
  (type (;3;) (func (result (ref 0))))
  (type (;4;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 2) (result (ref 0))
    unreachable
    ref.cast (ref 0)
  )
  (func (;1;) (type 3) (result (ref 0))
    (local i32)
    i32.const 0
    local.set 0
    i32.const 1
    local.get 0
    i32.div_s
    local.set 0
    local.get 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;2;) (type 4) (result i32)
    (local (ref 1))
    call 0
    call 1
    struct.new 1
    local.set 0
    local.get 0
    ref.cast (ref 1)
    struct.get 1 1
    struct.get 0 0
  )
)
