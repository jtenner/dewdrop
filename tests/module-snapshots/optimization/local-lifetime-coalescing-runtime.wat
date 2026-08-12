(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param (ref 0)) (result i32)))
  (type (;3;) (func (param i32) (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 3))
  (func (;0;) (type 1) (param i32) (result i32)
    (local i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    i32.const 2
    i32.mul
  )
  (func (;1;) (type 2) (param (ref 0)) (result i32)
    (local (ref 0))
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
  )
  (func (;2;) (type 3) (param i32) (result i32)
    (local i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    local.get 1
    i32.add
  )
  (func (;3;) (type 4) (result i32)
    i32.const 20
    call 0
    i32.const 1
    struct.new 0
    call 1
    i32.add
    i32.const 9
    call 2
    i32.add
  )
)
