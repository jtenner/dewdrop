(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\02\00\01\81\80\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\81\90\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\00\00\00\00\01\01\02\01\06\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\c7\01\00\01\10\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\c7\01\00\00\00\00\00\02\01\06\00\04\08\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\c7\01\00\01\10\00\04\09\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\c7\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field i32)))
  (type (;9;) (struct (field (ref 8))))
  (type (;10;) (func (param (ref 9)) (result i32)))
  (type (;11;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 10) (param (ref 9)) (result i32)
    (local (ref 8) i32 i32)
    local.get 0
    ref.cast (ref 9)
    struct.get 9 0
    ref.cast (ref 8)
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    local.set 2
    local.get 2
    local.set 3
    local.get 2
    local.get 3
    i32.add
  )
  (func (;1;) (type 11) (result i32)
    (local i32 eqref)
    i32.const 21
    local.set 0
    local.get 0
    struct.new 8
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.new 9
    call 0
  )
)
