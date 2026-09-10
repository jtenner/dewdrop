(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\02\01\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\01\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\02\02\02\020\00\00\00\00\00\01\01\01\01\00\00\0e\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\5c\00\028\00\00\00\00\00\01\01\01\01\00\00\0f\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\5c\00\00\00\00\00\02\020\00\01\0e\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\5c\00\028\00\04\0f\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\5c\00\00\00\03\01\03\06\00\00\00\00\00\01\01\01\01\00\00\0b\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\b7\01\00\00\00\00\00\01\03\06\00\04\0b\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\b7\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (param eqref)))
  (type (;10;) (func (param eqref)))
  (type (;11;) (struct (field i32)))
  (type (;12;) (func (param (ref 11))))
  (type (;13;) (func))
  (type (;14;) (array (mut v128)))
  (type (;15;) (struct (field (ref 14)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 14)) (field i32) (field i32)))
  (type (;17;) (struct (field (ref 14)) (field i32) (field i32)))
  (type (;18;) (struct (field (mut (ref 14))) (field (mut i32)) (field (mut i32))))
  (type (;19;) (struct (field (mut (ref 14))) (field (mut i32)) (field (mut i32))))
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
  (func (;1;) (type 10) (param eqref)
    local.get 0
    ref.cast (ref 11)
    call 2
  )
  (func (;2;) (type 12) (param (ref 11))
    local.get 0
    ref.cast (ref 11)
    struct.get 11 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x6c707865 0x74696369 0x73696420 0x65736f70
    v128.const i32x4 0x73696420 0x63746170 0x00000068 0x00000000
    array.new_fixed 14 2
    i32.const 0
    i32.const 25
    struct.new 15
    call 0
  )
  (func (;3;) (type 13)
    (local i32)
    i32.const 7
    local.set 0
    local.get 0
    struct.new 11
    call 1
  )
)
