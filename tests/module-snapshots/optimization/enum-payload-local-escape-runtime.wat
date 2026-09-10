(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\02\00\01\00\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32) (field i32))))
  (type (;10;) (func (param i32 i32) (result i32)))
  (type (;11;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 10) (param i32 i32) (result i32)
    (local i32 i32)
    local.get 0
    drop
    local.get 1
  )
  (func (;1;) (type 11) (result i32)
    i32.const 20
    i32.const 22
    call 0
  )
)
