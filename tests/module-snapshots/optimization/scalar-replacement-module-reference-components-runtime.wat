(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param (ref 0)) (result i32)))
  (type (;2;) (func (result i32)))
  (type (;3;) (func))
  (global (;0;) (mut eqref) ref.null none)
  (export "main" (func 1))
  (export "__dew_init" (func 3))
  (func (;0;) (type 1) (param (ref 0)) (result i32)
    (local (ref 0) (ref 0))
    global.get 0
    ref.cast (ref 0)
    local.set 1
    local.get 0
    local.set 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    i32.add
  )
  (func (;1;) (type 2) (result i32)
    i32.const 22
    struct.new 0
    call 0
  )
  (func (;2;) (type 3)
    i32.const 20
    struct.new 0
    global.set 0
  )
  (func (;3;) (type 3)
    call 2
  )
)
