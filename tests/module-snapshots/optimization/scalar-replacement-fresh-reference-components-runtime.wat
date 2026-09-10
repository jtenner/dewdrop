(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\02\00\01\81\81\90\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\81\90\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\00\00\00\00\01\00\02\00\06\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01O\00\00\11\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01O\00\00\00\00\00\02\00\06\00\04\08\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01O\00\00\11\00\04\08\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01O\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field i32)))
  (type (;9;) (func (param i32 i32) (result i32)))
  (type (;10;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 9) (param i32 i32) (result i32)
    (local (ref 8) (ref 8) i32 i32)
    local.get 0
    local.set 4
    local.get 4
    struct.new 8
    local.set 2
    local.get 1
    local.set 5
    local.get 5
    struct.new 8
    local.set 3
    local.get 2
    ref.cast (ref 8)
    struct.get 8 0
    local.get 3
    ref.cast (ref 8)
    struct.get 8 0
    i32.add
  )
  (func (;1;) (type 10) (result i32)
    i32.const 20
    i32.const 22
    call 0
  )
)
