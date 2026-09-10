(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\02\00\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\80\80\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i64) (result i64)))
  (type (;9;) (func (param i64) (result i64)))
  (type (;10;) (func (result i64)))
  (export "main" (func 1))
  (func (;0;) (type 9) (param i64) (result i64)
    local.get 0
  )
  (func (;1;) (type 10) (result i64)
    (local i64 i64)
    i64.const 9223372036854775766
    local.set 0
    i64.const 84
    i64.const 2
    i64.div_u
    local.set 1
    local.get 0
    local.get 1
    call 0
    i64.add
  )
)
