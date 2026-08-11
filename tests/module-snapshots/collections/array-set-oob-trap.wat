(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;1;) (func (result (ref 0))))
  (type (;2;) (func))
  (type (;3;) (array (mut i32)))
  (type (;4;) (array (mut i64)))
  (type (;5;) (array (mut f32)))
  (type (;6;) (array (mut f64)))
  (type (;7;) (array (mut v128)))
  (type (;8;) (array (mut eqref)))
  (export "main" (func 1))
  (func (;0;) (type 1) (result (ref 0))
    i32.const 0
    array.new_default 3
    i32.const 0
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 2)
    (local eqref eqref i32 eqref i32)
    call 0
    local.set 0
    local.get 0
    i32.const 0
    local.set 2
    i32.const 1
    local.set 4
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 3)
    local.get 2
    local.get 4
    array.set 3
  )
)
