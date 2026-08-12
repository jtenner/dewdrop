(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (result i32)))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 2) (result i32)
    unreachable
  )
  (func (;1;) (type 3) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 4) (result i32)
    (local i32 i32 i32 i32)
    i32.const 0
    call 0
    drop
    call 1
    i32.sub
    local.set 2
    local.get 2
    i32.const 1
    i32.add
    local.set 3
    local.get 3
    i32.const 2
    i32.mul
  )
)
