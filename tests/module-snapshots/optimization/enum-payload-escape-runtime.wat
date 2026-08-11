(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (struct (field i32)))
  (type (;3;) (sub (struct (field i32))))
  (type (;4;) (sub final 3 (struct (field i32) (field (ref 2)))))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param (ref 2)) (result (ref 2))))
  (type (;7;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 5) (param i32) (result i32)
    (local i32)
    local.get 0
  )
  (func (;1;) (type 6) (param (ref 2)) (result (ref 2))
    (local (ref 2))
    local.get 0
    ref.cast (ref 2)
  )
  (func (;2;) (type 7) (result i32)
    i32.const 20
    call 0
    i32.const 22
    struct.new 2
    call 1
    struct.get 2 0
    i32.add
  )
)
