(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param i32) (result (ref 0))))
  (type (;2;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 1) (param i32) (result (ref 0))
    local.get 0
    if (result eqref) ;; label = @1
      i32.const 11
      struct.new 0
    else
      i32.const 22
      struct.new 0
    end
    ref.cast (ref 0)
  )
  (func (;1;) (type 2) (result i32)
    i32.const 1
    call 0
    struct.get 0 0
  )
)
