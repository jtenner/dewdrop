(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (result (ref 0))))
  (type (;2;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 1) (result (ref 0))
    unreachable
    ref.cast (ref 0)
  )
  (func (;1;) (type 2) (result i32)
    (local (ref 0))
    call 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.add
  )
)
