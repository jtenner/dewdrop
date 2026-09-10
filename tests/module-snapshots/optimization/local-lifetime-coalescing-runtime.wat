(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\80\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\80\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\80\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\03\01\81\81\90\02\00\00\00\00\00\00\00\00\01\03\00\01\02\00\00\01\00\00\01\00\00\00\00\00\00\01\03\01\03\0a\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\bb\02\00\00\00\00\00\01\03\0a\00\04\08\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\bb\02\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field i32)))
  (type (;9;) (func (param i32) (result i32)))
  (type (;10;) (func (param (ref 8)) (result i32)))
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (result i32)))
  (export "main" (func 3))
  (func (;0;) (type 9) (param i32) (result i32)
    (local i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    i32.const 2
    i32.mul
  )
  (func (;1;) (type 10) (param (ref 8)) (result i32)
    (local (ref 8))
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
  )
  (func (;2;) (type 11) (param i32) (result i32)
    (local i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    local.get 1
    i32.add
  )
  (func (;3;) (type 12) (result i32)
    (local i32)
    i32.const 20
    call 0
    i32.const 1
    local.set 0
    local.get 0
    struct.new 8
    call 1
    i32.add
    i32.const 9
    call 2
    i32.add
  )
)
