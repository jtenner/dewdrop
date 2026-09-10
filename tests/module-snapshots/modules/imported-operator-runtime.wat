(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\81\81\90\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\81\81\90\02\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\00\00\00\00\02\00\01\00\17\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b9\17\01\82\80\80\80\90\f7\02\01\80\80\80\80\90\f7\02\00\018\00\00\00\00\00\01\00\17\00\04\08\00\00\00\00\00\01\01\b9\17\01\82\80\80\80\90\f7\02\01\80\80\80\80\90\f7\02\00\018\00\00\00\01\01\01\06\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b9\17\01\83\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01\9b\01\00\00\00\00\00\01\01\06\00\04\08\00\00\00\00\00\01\01\b9\17\01\83\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01\9b\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field i32)))
  (type (;9;) (func (param (ref 8) (ref 8)) (result (ref 8))))
  (type (;10;) (func (param i32) (result (ref 8))))
  (type (;11;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 9) (param (ref 8) (ref 8)) (result (ref 8))
    (local i32)
    local.get 0
    ref.cast (ref 8)
    struct.get 8 0
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    i32.add
    local.set 2
    local.get 2
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;1;) (type 10) (param i32) (result (ref 8))
    (local i32)
    local.get 0
    local.set 1
    local.get 1
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;2;) (type 11) (result i32)
    i32.const 20
    call 1
    ref.cast (ref 8)
    i32.const 22
    call 1
    ref.cast (ref 8)
    call 0
    ref.cast (ref 8)
    struct.get 8 0
  )
)
