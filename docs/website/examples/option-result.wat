(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub (struct (field i32))))
  (type (;3;) (sub final 2 (struct (field i32) (field i32))))
  (type (;4;) (sub final 2 (struct (field i32) (field i32))))
  (type (;5;) (func (param i32) (result (ref 0))))
  (type (;6;) (func (param i32 i32) (result (ref 2))))
  (export "maybe" (func 0))
  (export "divide" (func 1))
  (func (;0;) (type 5) (param i32) (result (ref 0))
    local.get 0
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 42
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    ref.cast (ref 0)
  )
  (func (;1;) (type 6) (param i32 i32) (result (ref 2))
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 0
      struct.new 4
    else
      i32.const 0
      local.get 0
      local.get 1
      i32.div_s
      struct.new 3
    end
    ref.cast (ref 2)
  )
)
