(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\81\88\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\89\90\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\02\01\80\91\80\02\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\03\01\80\91\80\02\00\00\00\00\00\00\00\00\01\01\02\00\00\01\00\00\01\00\00\00\00\01\00\01\01\01\04\0b\00\00\00\01\01\00\00\00\00\01\02\00\00\02\01\01\01\06\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\84\02\00\00\00\00\00\01\01\06\00\04\08\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\84\02\00\00\00\02\01\02\06\00\00\00\00\00\01\01\01\01\00\00\08\00\00\00\00\00\00\01\02\06\00\04\08\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field i32)))
  (type (;9;) (func (param (ref 8)) (result i32)))
  (type (;10;) (func (result i32)))
  (type (;11;) (func))
  (global (;0;) (mut eqref) ref.null none)
  (export "main" (func 1))
  (export "__dew_init" (func 3))
  (func (;0;) (type 9) (param (ref 8)) (result i32)
    (local (ref 8) (ref 8))
    global.get 0
    ref.cast (ref 8)
    local.set 1
    local.get 0
    local.set 2
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    local.get 2
    ref.cast (ref 8)
    struct.get 8 0
    i32.add
  )
  (func (;1;) (type 10) (result i32)
    (local i32)
    i32.const 22
    local.set 0
    local.get 0
    struct.new 8
    call 0
  )
  (func (;2;) (type 11)
    (local i32)
    i32.const 20
    local.set 0
    local.get 0
    struct.new 8
    global.set 0
  )
  (func (;3;) (type 11)
    call 2
  )
)
