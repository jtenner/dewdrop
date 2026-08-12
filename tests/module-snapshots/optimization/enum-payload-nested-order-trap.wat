(module
  (type (;0;) (struct (field i32) (field i32)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field (ref 0)))))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (result i32)))
  (type (;5;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 3) (result i32)
    unreachable
  )
  (func (;1;) (type 4) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 5) (result i32)
    (local i32 i32)
    call 0
    drop
    call 1
  )
)
