(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\06\00\01\80\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\80\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\03\01\81\81\90\02\00\00\00\00\00\00\00\00\01\01\02\01\00\00\01\7f\00\00\01\01\00\00\00\00\04\01\81\81\90\02\00\00\00\00\00\00\00\00\01\04\00\01\03\05\00\00\01\00\00\01\00\00\05\01\80\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\00\00\00\00\01\02\01\02\06\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\f8\01\00\00\00\00\00\01\02\06\00\04\08\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\f8\01\00\00\00\00")
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
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i32) (result (ref 8))))
  (type (;12;) (func (param i32) (result i32)))
  (type (;13;) (func (param eqref) (result eqref)))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 9) (param i32) (result i32)
    (local i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    i32.const 2
    i32.mul
    local.set 1
    local.get 1
    i32.const 3
    i32.sub
    local.set 1
    local.get 1
  )
  (func (;1;) (type 10) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    i32.const 1
    i32.add
    local.set 1
    local.get 1
    i32.const 2
    i32.add
    local.set 2
    local.get 1
    local.get 2
    i32.add
  )
  (func (;2;) (type 11) (param i32) (result (ref 8))
    (local i32)
    local.get 0
    local.set 1
    local.get 1
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;3;) (type 12) (param i32) (result i32)
    (local (ref 8) i32)
    local.get 0
    call 2
    ref.cast (ref 8)
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    local.set 2
    local.get 2
    i32.const 1
    i32.add
    call 2
    ref.cast (ref 8)
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
  )
  (func (;4;) (type 15) (result i32)
    i32.const 5
    call 0
    i32.const 7
    call 1
    i32.add
    i32.const 11
    call 3
    i32.add
    i32.const 13
    call 5
    i32.add
  )
  (func (;5;) (type 16) (param i32) (result i32)
    (local i32)
    local.get 0
    local.set 1
    local.get 1
    local.set 1
    local.get 1
  )
)
