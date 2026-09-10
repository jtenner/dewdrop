(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\0b\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\03\01\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\01\7f\00\00\01\00\01\00\00\00\04\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\05\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\03\00\04\07\00\00\01\00\00\01\00\00\06\01\80\01\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\07\01\80\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\08\01\80\11\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\09\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\02\00\00\01\00\01\00\00\00\0a\01\00\00\00\00\00\00\00\00\00\01\01\03\00\00\01\00\01\00\00\00\01\0c\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\03\09\00\01\00\09\00\00\01\01\01\00\01\00\0a\00\02\00\0a\00\00\01\01\01\00\01\00\0a\01\00\01\01\01\00\01\00\0b\00\01\00\0b\00\00\01\01\01\00\01\00\01\00\01\01\01\04\02\00\00\00\01\01\00\00\00\01\00\00\00\00\01\01\01\01\00\00\0b\00\01\01\00\00\04\05\02\05A\00\00\00\00\00\01\01\01\01\00\00\1b\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\95\01\00\05I\00\00\00\00\00\01\01\01\01\00\00\1c\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\95\01\00\00\00\00\00\02\05A\00\01\1b\00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\95\01\00\05I\00\04\1c\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\95\01\00\00\00\06\02\06\00\00\01\01\05\09\00\00\00\01\01\01\01\00\06\01\01\09\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01 \00\06\04\00\00\00\00\00\01\01\01\01\00\00!\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01 \00\00\00\00\00\01\06\04\00\04!\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01 \00\00\00\07\02\07\00\00\01\01\05\0a\00\00\00\01\01\01\01\00\06\01\01\0a\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01 \00\07\02\00\00\00\00\00\01\01\01\01\00\00\22\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01 \00\00\00\00\00\01\07\02\00\04\22\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01 \00\00\00\08\02\08\00\00\01\01\05\03\00\00\00\01\01\01\01\00\06\01\01\03\00\08\02\00\00\00\00\00\01\01\01\01\00\00\0b\00\00\00\00\00\00\01\08\02\00\02\0b\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (rec
    (type (;8;) (func (param eqref) (result i32)))
  )
  (rec
    (type (;9;) (struct (field (ref null 8))))
  )
  (rec
    (type (;10;) (struct (field eqref) (field (ref 9))))
  )
  (rec
    (type (;11;) (sub (struct (field funcref))))
  )
  (type (;12;) (func (param i32 eqref)))
  (type (;13;) (func (param eqref) (result i32)))
  (type (;14;) (func (param i32) (result i32)))
  (type (;15;) (func (param eqref eqref) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param i32) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func (param eqref eqref) (result i32)))
  (type (;20;) (func (result eqref)))
  (type (;21;) (func (param eqref) (result i32)))
  (type (;22;) (func (result i32)))
  (type (;23;) (func (param eqref) (result eqref)))
  (type (;24;) (func (result eqref)))
  (type (;25;) (struct (field i32)))
  (type (;26;) (func))
  (type (;27;) (array (mut v128)))
  (type (;28;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;29;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;30;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;31;) (struct (field (mut (ref 27))) (field (mut i32)) (field (mut i32))))
  (type (;32;) (struct (field (mut (ref 27))) (field (mut i32)) (field (mut i32))))
  (type (;33;) (sub final 11 (struct (field funcref) (field eqref))))
  (type (;34;) (sub final 11 (struct (field funcref))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 5))
  (export "reader" (func 6))
  (export "__dew_init" (func 8))
  (elem (;0;) declare func 3 9 10)
  (func (;0;) (type 12) (param i32 eqref)
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
  (func (;1;) (type 14) (param i32) (result i32)
    local.get 0
  )
  (func (;2;) (type 15) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 9)
    struct.get 9 0
    call_ref 8
  )
  (func (;3;) (type 16) (param i32) (result i32)
    local.get 0
    call 1
  )
  (func (;4;) (type 21) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.test (ref 17)
    if (result i32) ;; label = @1
      i32.const 42
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 17)
      call_ref 17
    else
      local.get 1
      i32.const 42
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 18)
      call_ref 18
    end
  )
  (func (;5;) (type 22) (result i32)
    (local i32)
    call 7
    call 4
    local.set 0
    local.get 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x70616320 0x65727574
    v128.const i32x4 0x61632064 0x61626c6c 0x72206b63 0x6c757365
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 3
    i32.const 0
    i32.const 33
    struct.new 28
    call 0
    local.get 0
  )
  (func (;6;) (type 23) (param eqref) (result eqref)
    ref.func 9
    local.get 0
    struct.new 33
  )
  (func (;7;) (type 24) (result eqref)
    ref.func 10
    struct.new 34
  )
  (func (;8;) (type 26)
    ref.func 3
    struct.new 11
    global.set 0
  )
  (func (;9;) (type 15) (param eqref eqref) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 33)
    struct.get 33 1
    call 2
  )
  (func (;10;) (type 18) (param eqref i32) (result i32)
    local.get 1
    call 3
  )
)
