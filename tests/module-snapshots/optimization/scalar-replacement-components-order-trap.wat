(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\02\01\81\80\80\02\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (result i32)))
  (type (;9;) (func (result i32)))
  (type (;10;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 8) (result i32)
    unreachable
  )
  (func (;1;) (type 9) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 10) (result i32)
    (local i32 i32)
    call 0
    local.set 0
    call 1
    local.set 1
    local.get 0
    local.get 1
    i32.add
  )
)
