(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\80\10\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\81\80\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\03\00\01\02\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\01\03\05\03\06\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\039\00\00\00\00\00\01\01\01\01\00\00\0d\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\03A\00\00\00\00\00\01\01\01\01\00\00\0e\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\03t\00\00\00\00\00\01\01\01\01\00\00\0d\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\03|\00\00\00\00\00\01\01\01\01\00\00\0e\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\00\00\00\00\05\03\06\00\04\09\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\039\00\01\0d\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\03A\00\04\0e\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\03t\00\01\0d\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\03|\00\04\0e\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\c5\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (struct (field i32)))
  (type (;10;) (func (param (ref 9)) (result i32)))
  (type (;11;) (func (param (ref 9)) (result i32)))
  (type (;12;) (func))
  (type (;13;) (array (mut v128)))
  (type (;14;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;17;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 8) (param i32 eqref)
    (local eqref)
    local.get 1
    local.set 2
    local.get 0
    i32.eqz
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;1;) (type 10) (param (ref 9)) (result i32)
    local.get 0
    ref.cast (ref 9)
    struct.get 9 0
    local.get 0
    ref.cast (ref 9)
    struct.get 9 0
    i32.add
  )
  (func (;2;) (type 11) (param (ref 9)) (result i32)
    (local i32)
    local.get 0
    ref.cast (ref 9)
    struct.get 9 0
    local.set 1
    local.get 1
    local.get 1
    i32.add
  )
  (func (;3;) (type 12)
    (local (ref 9) i32)
    i32.const 21
    local.set 1
    local.get 1
    struct.new 9
    local.set 0
    local.get 0
    ref.cast (ref 9)
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x616a6461 0x746e6563 0x65696620 0x4320646c
    v128.const i32x4 0x00004553 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 2
    i32.const 0
    i32.const 18
    struct.new 14
    call 0
    local.get 0
    ref.cast (ref 9)
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x61706573 0x65746172 0x69662064 0x20646c65
    v128.const i32x4 0x00455343 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 2
    i32.const 0
    i32.const 19
    struct.new 14
    call 0
  )
)
