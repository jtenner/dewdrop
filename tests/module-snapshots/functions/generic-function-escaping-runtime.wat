(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\07\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\80\08\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\02\01\80\08\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\03\00\01\02\00\00\01\00\00\01\00\00\04\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\00\01\00\00\00\05\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\00\01\00\00\00\06\01\80\11\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\02\00\01\01\01\04\02\00\00\00\01\01\00\00\00\01\00\00\00\00\01\01\01\01\00\00\09\00\01\01\00\01\01\01\01\04\02\00\00\00\01\01\00\00\00\01\00\00\00\00\01\01\01\01\00\00\09\00\01\01\00\00\02\03\04\03e\00\00\00\00\00\01\01\01\01\00\00\16\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\03m\00\00\00\00\00\01\01\01\01\00\00\17\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\03\cf\01\00\00\00\00\00\01\01\01\01\00\00\16\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\03\d7\01\00\00\00\00\00\01\01\01\01\00\00\17\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\00\00\00\00\04\03e\00\01\16\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\03m\00\04\17\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\03\cf\01\00\01\16\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\03\d7\01\00\04\17\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\a1\01\00\00\00\06\04\06\00\00\01\01\05\04\00\00\00\01\01\01\01\00\06\01\01\04\00\06\02\00\00\00\00\00\01\01\01\01\00\00\09\00\00\06\07\00\01\01\05\05\00\00\00\01\01\01\01\00\06\01\01\05\00\06\09\00\00\00\00\00\01\01\01\01\00\00\09\00\00\00\00\00\00\02\06\02\00\04\09\00\00\00\00\00\00\06\09\00\04\09\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (sub (struct (field funcref))))
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i64) (result i64)))
  (type (;12;) (func (param eqref) (result eqref)))
  (type (;13;) (func (param eqref i32) (result i32)))
  (type (;14;) (func (param eqref i64) (result i64)))
  (type (;15;) (func (param eqref eqref) (result eqref)))
  (type (;16;) (func (result eqref)))
  (type (;17;) (func (result eqref)))
  (type (;18;) (func))
  (type (;19;) (func (param i32) (result i32)))
  (type (;20;) (func (param i64) (result i64)))
  (type (;21;) (func))
  (type (;22;) (array (mut v128)))
  (type (;23;) (struct (field (ref 22)) (field i32) (field i32)))
  (type (;24;) (struct (field (ref 22)) (field i32) (field i32)))
  (type (;25;) (struct (field (ref 22)) (field i32) (field i32)))
  (type (;26;) (struct (field (mut (ref 22))) (field (mut i32)) (field (mut i32))))
  (type (;27;) (struct (field (mut (ref 22))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 3))
  (export "__dew_init" (func 6))
  (elem (;0;) declare func 4 5)
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
  (func (;1;) (type 16) (result eqref)
    global.get 0
  )
  (func (;2;) (type 17) (result eqref)
    global.get 1
  )
  (func (;3;) (type 18)
    (local eqref eqref eqref eqref)
    call 1
    local.set 0
    call 2
    local.set 1
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 9)
    struct.get 9 0
    ref.test (ref 10)
    if (result i32) ;; label = @1
      i32.const 42
      local.get 2
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 10)
      call_ref 10
    else
      local.get 2
      i32.const 42
      local.get 2
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 13)
      call_ref 13
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x61637365 0x676e6970 0x6e656720 0x63697265
    v128.const i32x4 0x32336920 0x66657220 0x6e657265 0x00006563
    array.new_fixed 22 2
    i32.const 0
    i32.const 30
    struct.new 23
    call 0
    local.get 1
    local.set 3
    local.get 3
    ref.cast (ref 9)
    struct.get 9 0
    ref.test (ref 11)
    if (result i64) ;; label = @1
      i64.const 42
      local.get 3
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 11)
      call_ref 11
    else
      local.get 3
      i64.const 42
      local.get 3
      ref.cast (ref 9)
      struct.get 9 0
      ref.cast (ref 14)
      call_ref 14
    end
    i64.const 42
    i64.eq
    v128.const i32x4 0x61637365 0x676e6970 0x6e656720 0x63697265
    v128.const i32x4 0x34366920 0x66657220 0x6e657265 0x00006563
    array.new_fixed 22 2
    i32.const 0
    i32.const 30
    struct.new 23
    call 0
  )
  (func (;4;) (type 19) (param i32) (result i32)
    local.get 0
  )
  (func (;5;) (type 20) (param i64) (result i64)
    local.get 0
  )
  (func (;6;) (type 21)
    ref.func 4
    struct.new 9
    global.set 0
    ref.func 5
    struct.new 9
    global.set 1
  )
)
