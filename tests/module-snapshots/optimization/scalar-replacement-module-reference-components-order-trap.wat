(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (struct (field (ref 0)) (field (ref 0))))
  (type (;2;) (func (result i32)))
  (type (;3;) (func (result i32)))
  (type (;4;) (func))
  (global (;0;) (mut eqref) ref.null none)
  (export "main" (func 1))
  (export "__dew_init" (func 3))
  (func (;0;) (type 2) (result i32)
    unreachable
  )
  (func (;1;) (type 3) (result i32)
    (local (ref 1))
    global.get 0
    ref.cast (ref 0)
    call 0
    struct.new 0
    struct.new 1
    local.set 0
    local.get 0
    ref.cast (ref 1)
    struct.get 1 1
    struct.get 0 0
  )
  (func (;2;) (type 4)
    i32.const 20
    struct.new 0
    global.set 0
  )
  (func (;3;) (type 4)
    call 2
  )
)
