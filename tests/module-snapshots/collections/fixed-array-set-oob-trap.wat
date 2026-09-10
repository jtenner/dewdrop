(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\80 \00\00\00\00\00\00\00\00\01\00\03\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\02\00\01\7f\00\00\01\01\00\00\00\00\02\01\81\81\a0\02\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\02\0a\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\0b\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\00\01\00\01\00\0c\00\00\00\00\00\01\01\01\01\00\00\00\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\00\00\01\00\0c\00\01\00\00\00\00\00\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref) (result eqref)))
  (type (;9;) (func (param eqref i32 eqref)))
  (type (;10;) (func (param i32 i32) (result (ref 0))))
  (type (;11;) (func (param eqref i32 i32)))
  (type (;12;) (func))
  (export "main" (func 2))
  (func (;0;) (type 10) (param i32 i32) (result (ref 0))
    (local i32 i32)
    local.get 0
    local.get 1
    local.set 2
    local.set 3
    local.get 2
    local.get 3
    array.new 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 11) (param eqref i32 i32)
    local.get 0
    ref.cast (ref 0)
    local.get 1
    local.get 2
    array.set 0
  )
  (func (;2;) (type 12)
    (local eqref)
    i32.const 1
    i32.const 7
    call 0
    local.set 0
    local.get 0
    i32.const 1
    i32.const 9
    call 1
  )
)
