(module
  (type (;0;) (struct (field eqref)))
  (type (;1;) (func (result i32)))
  (type (;2;) (array (mut i32)))
  (type (;3;) (array (mut i64)))
  (type (;4;) (array (mut f32)))
  (type (;5;) (array (mut f64)))
  (type (;6;) (array (mut v128)))
  (type (;7;) (array (mut eqref)))
  (export "main" (func 0))
  (func (;0;) (type 1) (result i32)
    (local eqref eqref i32)
    i32.const 1
    local.set 2
    i32.const 7
    local.get 2
    array.new 2
    struct.new 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
  )
)
