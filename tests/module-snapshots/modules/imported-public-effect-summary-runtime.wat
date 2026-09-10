(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\0b\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\80\10\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\00\00\00\00\00\00\00\00\00\01\00\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\03\01\00\00\00\00\00\00\00\00\00\01\00\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\04\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\05\01\00\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\06\01\00\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\07\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\08\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\01\00\00\00\00\08\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\01\00\00\00\00\09\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\0a\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\03\00\01\09\00\00\01\00\00\01\00\00\03\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\11\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\12\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\01\0a\03\0a\06\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01G\00\0a?\00\00\00\00\00\01\01\01\01\00\00\1a\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01G\00\0aG\00\00\00\00\00\01\01\01\01\00\00\1b\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01G\00\00\00\00\00\03\0a\06\00\04\09\00\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01G\00\0a?\00\01\1a\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01G\00\0aG\00\04\1b\00\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01G\00\00\00\00")
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
  (type (;10;) (sub (struct (field funcref))))
  (type (;11;) (func (param eqref) (result i32)))
  (type (;12;) (struct (field (ref null 11))))
  (type (;13;) (struct (field eqref) (field (ref 12))))
  (type (;14;) (func (param i32) (result i32)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (param (ref 9)) (result i32)))
  (type (;17;) (func (result i32)))
  (type (;18;) (func (result i32)))
  (type (;19;) (func (param eqref) (result i32)))
  (type (;20;) (func (result i32)))
  (type (;21;) (func (result i32)))
  (type (;22;) (func (param eqref i32) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param i32) (result i32)))
  (type (;25;) (func (result i32)))
  (type (;26;) (array (mut v128)))
  (type (;27;) (struct (field (ref 26)) (field i32) (field i32)))
  (type (;28;) (struct (field (ref 26)) (field i32) (field i32)))
  (type (;29;) (struct (field (ref 26)) (field i32) (field i32)))
  (type (;30;) (struct (field (mut (ref 26))) (field (mut i32)) (field (mut i32))))
  (type (;31;) (struct (field (mut (ref 26))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 10))
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
  (func (;1;) (type 16) (param (ref 9)) (result i32)
    local.get 0
    ref.cast (ref 9)
    struct.get 9 0
  )
  (func (;2;) (type 17) (result i32)
    i32.const 1
  )
  (func (;3;) (type 18) (result i32)
    i32.const 1
  )
  (func (;4;) (type 19) (param eqref) (result i32)
    (local eqref eqref)
    i32.const 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    local.set 1
    local.get 1
    local.tee 2
    ref.cast (ref 13)
    struct.get 13 0
    local.get 2
    ref.cast (ref 13)
    struct.get 13 1
    struct.get 12 0
    call_ref 11
  )
  (func (;5;) (type 20) (result i32)
    i32.const 0
  )
  (func (;6;) (type 21) (result i32)
    i32.const 0
  )
  (func (;7;) (type 22) (param eqref i32) (result i32)
    (local i32)
    i32.const 0
    local.set 2
    local.get 0
    local.get 1
    call 8
  )
  (func (;8;) (type 23) (param eqref i32) (result i32)
    (local eqref eqref)
    local.get 0
    local.set 2
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 10)
    struct.get 10 0
    ref.test (ref 14)
    if (result i32) ;; label = @1
      local.get 1
      local.get 3
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 14)
      call_ref 14
    else
      local.get 3
      local.get 1
      local.get 3
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 15)
      call_ref 15
    end
  )
  (func (;9;) (type 24) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;10;) (type 25) (result i32)
    (local i32 i32 i32)
    i32.const 41
    local.set 2
    local.get 2
    struct.new 9
    call 1
    local.set 0
    i32.const 0
    call 9
    local.set 1
    local.get 0
    local.get 1
    i32.add
    i32.const 42
    i32.eq
    v128.const i32x4 0x6c627570 0x65206369 0x63656666 0x75732074
    v128.const i32x4 0x72616d6d 0x65722079 0x746c7573 0x00000000
    array.new_fixed 26 2
    i32.const 0
    i32.const 28
    struct.new 27
    call 0
    i32.const 0
  )
)
