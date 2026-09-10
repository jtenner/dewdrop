(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\81\81\90\02\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\00\00\00\00\01\02\01\02\0a\00\00\00\00\00\01\01\01\01\00\00\0a\00\01\01\b8\17\01\85\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\03\00\00\00\00\00\01\02\0a\00\04\0a\00\00\00\00\00\01\01\b8\17\01\85\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\03\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (struct (field i32)))
  (type (;11;) (sub (struct (field i32))))
  (type (;12;) (sub final 11 (struct (field i32) (field (ref 10)))))
  (type (;13;) (func (param i32) (result i32)))
  (type (;14;) (func (param (ref 10)) (result (ref 10))))
  (type (;15;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 13) (param i32) (result i32)
    (local i32)
    local.get 0
  )
  (func (;1;) (type 14) (param (ref 10)) (result (ref 10))
    (local (ref null 10) i32)
    local.get 0
    ref.cast (ref 10)
  )
  (func (;2;) (type 15) (result i32)
    (local i32)
    i32.const 20
    call 0
    i32.const 22
    local.set 0
    local.get 0
    struct.new 10
    call 1
    ref.cast (ref 10)
    struct.get 10 0
    i32.add
  )
)
