(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param i32) (result (ref 0))))
  (type (;4;) (func (param i32) (result i32)))
  (type (;5;) (func (param eqref) (result eqref)))
  (type (;6;) (func (param eqref) (result eqref)))
  (type (;7;) (func (result i32)))
  (type (;8;) (func (param i32) (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 1) (param i32) (result i32)
    (local i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    i32.const 2
    i32.mul
    local.set 1
    local.get 1
    i32.const 3
    i32.sub
    local.set 1
    local.get 1
  )
  (func (;1;) (type 2) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    i32.const 2
    i32.add
    local.set 2
    local.get 1
    local.get 2
    i32.add
  )
  (func (;2;) (type 3) (param i32) (result (ref 0))
    local.get 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;3;) (type 4) (param i32) (result i32)
    (local (ref 0) i32)
    local.get 0
    call 2
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    local.set 2
    local.get 2
    i32.const 1
    i32.add
    call 2
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
  )
  (func (;4;) (type 7) (result i32)
    i32.const 5
    call 0
    i32.const 7
    call 1
    i32.add
    i32.const 11
    call 3
    i32.add
    i32.const 13
    call 5
    i32.add
  )
  (func (;5;) (type 8) (param i32) (result i32)
    (local i32)
    local.get 0
    local.set 1
    local.get 1
    local.set 1
    local.get 1
  )
)
