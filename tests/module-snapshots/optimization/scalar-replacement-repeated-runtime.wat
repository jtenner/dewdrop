(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\80\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\02\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\01\02\02\02\1b\00\00\00\00\00\01\01\01\01\00\00\0b\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\b9\01\00\02#\00\00\00\00\00\01\01\01\01\00\00\0c\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\b9\01\00\00\00\00\00\02\02\1b\00\01\0b\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\b9\01\00\02#\00\04\0c\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\b9\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (param i32 i32) (result i32)))
  (type (;10;) (func))
  (type (;11;) (array (mut v128)))
  (type (;12;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;15;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
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
  (func (;1;) (type 9) (param i32 i32) (result i32)
    (local i32)
    local.get 0
    drop
    local.get 1
    local.set 2
    local.get 2
    local.get 2
    i32.add
    local.get 2
    i32.add
  )
  (func (;2;) (type 10)
    i32.const 1
    i32.const 2
    call 1
    i32.const 6
    i32.eq
    v128.const i32x4 0x65706572 0x64657461 0x65696620 0x0000646c
    array.new_fixed 11 1
    i32.const 0
    i32.const 14
    struct.new 12
    call 0
  )
)
