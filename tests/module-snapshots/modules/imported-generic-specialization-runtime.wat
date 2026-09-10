(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\06\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\00\03\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\00\02\00\01\7f\00\00\01\00\01\00\00\00\02\01\00\00\00\00\00\00\00\00\00\01\00\03\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\00\02\00\01\7f\00\00\01\01\00\00\00\00\03\01\80\08\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\04\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\03\00\02\03\00\00\01\00\00\01\00\00\05\01\80\11\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\03\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\0a\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\0b\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\01\00\01\01\01\04\02\00\00\00\01\01\00\00\00\01\00\00\00\00\01\01\01\01\00\00\0c\00\01\01\00\00\02\04\04\04/\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\047\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\04\b7\01\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\04\bf\01\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\00\00\00\00\04\04/\00\01\12\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\047\00\04\13\00\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\04\b7\01\00\01\12\00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\04\bf\01\00\04\13\00\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01g\00\00\00\05\02\05\00\00\01\01\05\01\00\00\00\01\01\01\01\00\06\01\01\01\00\05\02\00\00\00\00\00\01\01\01\01\00\00\0c\00\00\00\00\00\00\01\05\02\00\04\0c\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (param i32 eqref eqref) (result eqref)))
  (type (;10;) (func (param i32 i64 i64) (result i64)))
  (type (;11;) (func (param i32 i32 i32) (result i32)))
  (type (;12;) (sub (struct (field funcref))))
  (type (;13;) (func (param i32 i64 i64) (result i64)))
  (type (;14;) (func (param eqref i32 i64 i64) (result i64)))
  (type (;15;) (func (result eqref)))
  (type (;16;) (func))
  (type (;17;) (func))
  (type (;18;) (array (mut v128)))
  (type (;19;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;22;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;23;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 4))
  (export "__dew_init" (func 5))
  (elem (;0;) declare func 1)
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
  (func (;1;) (type 10) (param i32 i64 i64) (result i64)
    local.get 0
    if (result i64) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;2;) (type 11) (param i32 i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;3;) (type 15) (result eqref)
    global.get 0
  )
  (func (;4;) (type 16)
    (local eqref eqref)
    i32.const 1
    i32.const 42
    i32.const 7
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x6e6f6320 0x69746964 0x6c616e6f 0x00000000
    array.new_fixed 18 2
    i32.const 0
    i32.const 28
    struct.new 19
    call 0
    call 3
    local.set 0
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 12)
    struct.get 12 0
    ref.test (ref 13)
    if (result i64) ;; label = @1
      i32.const 0
      i64.const 7
      i64.const 42
      local.get 1
      ref.cast (ref 12)
      struct.get 12 0
      ref.cast (ref 13)
      call_ref 13
    else
      local.get 1
      i32.const 0
      i64.const 7
      i64.const 42
      local.get 1
      ref.cast (ref 12)
      struct.get 12 0
      ref.cast (ref 14)
      call_ref 14
    end
    i64.const 42
    i64.eq
    v128.const i32x4 0x61637365 0x676e6970 0x706d6920 0x6574726f
    v128.const i32x4 0x65672064 0x6972656e 0x65722063 0x65726566
    v128.const i32x4 0x0065636e 0x00000000 0x00000000 0x00000000
    array.new_fixed 18 3
    i32.const 0
    i32.const 35
    struct.new 19
    call 0
  )
  (func (;5;) (type 17)
    ref.func 1
    struct.new 12
    global.set 0
  )
)
