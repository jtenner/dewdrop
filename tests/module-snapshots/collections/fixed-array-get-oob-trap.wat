(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (result i32)))
  (export "main" (func 0))
  (func (;0;) (type 8) (result i32)
    (local eqref eqref i32)
    i32.const 1
    local.set 2
    i32.const 7
    local.get 2
    array.new 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    array.get 0
  )
)
