(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\00\00\00\01\01\00\00\00\00\02\01\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\01\02\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\01\01\02\01\14\00\00\00\00\00\01\01\01\01\00\00\0c\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01*\00\01\1c\00\00\00\00\00\01\01\01\01\00\00\0d\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01*\00\00\00\00\00\02\01\14\00\01\0c\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01*\00\01\1c\00\04\0d\00\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01*\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (result i32)))
  (type (;10;) (func (result i32)))
  (type (;11;) (func (result i32)))
  (type (;12;) (array (mut v128)))
  (type (;13;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;16;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (type (;17;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
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
  (func (;1;) (type 9) (result i32)
    i32.const 0
    v128.const i32x4 0x73726966 0x69662074 0x00646c65 0x00000000
    array.new_fixed 12 1
    i32.const 0
    i32.const 11
    struct.new 13
    call 0
    i32.const 1
  )
  (func (;2;) (type 10) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;3;) (type 11) (result i32)
    call 1
    drop
    call 2
  )
)
