(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\06\00\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\09\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\02\01\81\80\10\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\01\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\04\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\01\03\00\00\01\00\00\01\00\00\05\01\80\11\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\01\0d\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\02\09\00\01\00\09\00\00\01\01\01\00\01\00\0a\00\02\00\0a\00\00\01\01\01\00\01\00\0a\01\00\01\01\01\00\01\00\01\00\01\01\01\04\00\09\00\00\00\01\01\00\00\00\00\01\02\00\00\02\01\02\01\0a\00\00\00\00\00\01\01\01\01\00\00\10\00\01\01\b9\17\01\84\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01l\00\01\12\00\00\00\00\00\01\01\01\01\00\00\0a\00\01\01\b9\17\01\84\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01l\00\00\00\00\00\02\01\0a\00\04\10\00\00\00\00\00\01\01\b9\17\01\84\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01l\00\01\12\00\00\0a\00\00\00\00\00\01\01\b9\17\01\84\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01l\00\00\00\05\02\05\00\00\01\01\05\02\00\00\00\01\01\01\01\00\06\01\01\02\00\05\02\00\00\00\00\00\01\01\01\01\00\00\09\00\00\00\00\00\00\01\05\02\00\00\09\00\00\00\00\00\00\00\00\00")
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
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (param i32 eqref) (result eqref)))
  (type (;13;) (func (param i32 i32) (result eqref)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (result i32)))
  (type (;16;) (struct (field i32)))
  (type (;17;) (func))
  (global (;0;) (mut (ref null 9)) ref.null 9)
  (export "main" (func 4))
  (export "__dew_init" (func 5))
  (elem (;0;) declare func 2)
  (func (;0;) (type 11) (param i32) (result i32)
    local.get 0
  )
  (func (;1;) (type 13) (param i32 i32) (result eqref)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 16
    global.get 0
    ref.cast (ref 9)
    struct.new 10
  )
  (func (;2;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 16)
    struct.get 16 0
    call 0
  )
  (func (;3;) (type 14) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.tee 1
    ref.cast (ref 10)
    struct.get 10 0
    local.get 1
    ref.cast (ref 10)
    struct.get 10 1
    struct.get 9 0
    call_ref 8
  )
  (func (;4;) (type 15) (result i32)
    i32.const 1
    i32.const 42
    call 1
    call 3
  )
  (func (;5;) (type 17)
    ref.func 2
    struct.new 9
    global.set 0
  )
)
