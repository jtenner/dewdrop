(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\01\00\00\00\00\02\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\01\03\06\03)\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\031\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03_\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03g\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03\95\01\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03\9d\01\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\00\00\00\00\06\03)\00\01\12\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\031\00\04\13\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03_\00\01\12\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03g\00\04\13\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03\95\01\00\01\12\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\03\9d\01\00\04\13\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\b8\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (param eqref) (result eqref)))
  (type (;10;) (sub (struct (field funcref))))
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (param i64) (result i64)))
  (type (;13;) (func (param eqref i32) (result i32)))
  (type (;14;) (func (param eqref i64) (result i64)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (param eqref i64) (result i64)))
  (type (;17;) (func))
  (type (;18;) (array (mut v128)))
  (type (;19;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;22;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;23;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
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
  (func (;1;) (type 15) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.test (ref 11)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 11)
      call_ref 11
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 13)
      call_ref 13
    end
  )
  (func (;2;) (type 16) (param eqref i64) (result i64)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.test (ref 12)
    if (result i64) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 12)
      call_ref 12
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 14)
      call_ref 14
    end
  )
  (func (;3;) (type 17)
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x72696420 0x20746365 0x6c6c6163 0x00000000
    array.new_fixed 18 2
    i32.const 0
    i32.const 28
    struct.new 19
    call 0
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x32336920 0x6c616320 0x6361626c 0x0000006b
    array.new_fixed 18 2
    i32.const 0
    i32.const 29
    struct.new 19
    call 0
    i64.const 42
    i64.const 42
    i64.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x34366920 0x6c616320 0x6361626c 0x0000006b
    array.new_fixed 18 2
    i32.const 0
    i32.const 29
    struct.new 19
    call 0
  )
)
