(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (param i32 i32) (result i32)))
  (type (;3;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 2) (param i32 i32) (result i32)
    (local i32 i32 i32 i32)
    i32.const 0
    local.get 0
    drop
    local.get 1
    i32.sub
    local.set 4
    local.get 4
    i32.const 1
    i32.add
    local.set 5
    local.get 5
    i32.const 2
    i32.mul
  )
  (func (;1;) (type 3) (result i32)
    i32.const 1
    i32.const -20
    call 0
  )
)
