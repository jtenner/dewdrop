(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\07\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\00\01\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\01\00\00\00\00\04\01\80\08\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\05\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\03\00\01\04\00\00\01\00\00\01\00\00\06\01\80\11\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\01\00\01\01\01\04\02\00\00\00\01\01\00\00\00\01\00\00\00\00\01\01\01\01\00\00\0b\00\01\01\00\00\02\05\04\05=\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\05E\00\00\00\00\00\01\01\01\01\00\00\14\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\05\bd\01\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\05\c5\01\00\00\00\00\00\01\01\01\01\00\00\14\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\00\00\00\00\04\05=\00\01\13\00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\05E\00\04\14\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\05\bd\01\00\01\13\00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\05\c5\01\00\04\14\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\bc\01\00\00\00\06\02\06\00\00\01\01\05\02\00\00\00\01\01\01\01\00\06\01\01\02\00\06\02\00\00\00\00\00\01\01\01\01\00\00\0b\00\00\00\00\00\00\01\06\02\00\04\0b\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (param i32) (result i32)))
  (type (;10;) (func (param i64) (result i64)))
  (type (;11;) (sub (struct (field funcref))))
  (type (;12;) (func (param i32) (result i32)))
  (type (;13;) (func (param eqref i32) (result i32)))
  (type (;14;) (func (param eqref i64) (result i64)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (result eqref)))
  (type (;17;) (func))
  (type (;18;) (func))
  (type (;19;) (array (mut v128)))
  (type (;20;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;22;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;23;) (struct (field (mut (ref 19))) (field (mut i32)) (field (mut i32))))
  (type (;24;) (struct (field (mut (ref 19))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 5))
  (export "__dew_init" (func 6))
  (elem (;0;) declare func 2)
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
  (func (;1;) (type 9) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;2;) (type 10) (param i64) (result i64)
    local.get 0
    i64.const 1
    i64.add
  )
  (func (;3;) (type 15) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.test (ref 12)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 12)
      call_ref 12
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 13)
      call_ref 13
    end
  )
  (func (;4;) (type 16) (result eqref)
    global.get 0
  )
  (func (;5;) (type 17)
    (local eqref eqref)
    i32.const 41
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x65707865 0x64657463 0x70797420 0x65732065
    v128.const i32x4 0x7463656c 0x6d692073 0x74726f70 0x49206465
    v128.const i32x4 0x6f203233 0x6c726576 0x0064616f 0x00000000
    array.new_fixed 19 3
    i32.const 0
    i32.const 43
    struct.new 20
    call 0
    call 4
    local.set 0
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.test (ref 10)
    if (result i64) ;; label = @1
      i64.const 41
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 10)
      call_ref 10
    else
      local.get 1
      i64.const 41
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 14)
      call_ref 14
    end
    i64.const 42
    i64.eq
    v128.const i32x4 0x75746572 0x74206e72 0x20657079 0x656c6573
    v128.const i32x4 0x20737463 0x6f706d69 0x64657472 0x34364920
    v128.const i32x4 0x65766f20 0x616f6c72 0x00000064 0x00000000
    array.new_fixed 19 3
    i32.const 0
    i32.const 41
    struct.new 20
    call 0
  )
  (func (;6;) (type 18)
    ref.func 2
    struct.new 11
    global.set 0
  )
)
