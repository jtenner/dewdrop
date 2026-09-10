(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\08\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\00\01\00\00\00\02\01\81\89\80\02\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\03\00\02\05\00\00\01\00\00\01\00\00\04\01\01\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\00\00\01\00\00\05\01\01\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\06\01\01\00\00\00\00\00\00\00\00\01\01\04\00\00\01\00\00\01\00\00\07\01\80\11\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\01\00\01\01\01\04\02\00\00\00\01\01\00\00\00\01\00\00\00\00\01\01\01\01\00\00\0a\00\01\01\00\00\03\02\01\02\06\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b9\17\01\82\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01k\00\00\00\00\00\01\02\06\00\04\09\00\00\00\00\00\01\01\b9\17\01\82\80\80\80\90\f7\02\01\81\80\80\80\90\f7\02\00\01k\00\00\00\03\02\03C\00\00\00\00\00\01\01\01\01\00\00\14\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\a1\01\00\03K\00\00\00\00\00\01\01\01\01\00\00\15\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\a1\01\00\00\00\00\00\02\03C\00\01\14\00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\a1\01\00\03K\00\04\15\00\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\a1\01\00\00\00\07\02\07\00\00\01\01\05\01\00\00\00\01\01\01\01\00\06\01\01\01\00\07\02\00\00\00\00\00\01\01\01\01\00\00\0a\00\00\00\00\00\00\01\07\02\00\04\0a\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (struct (field eqref)))
  (type (;10;) (sub (struct (field funcref))))
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (param eqref i32) (result i32)))
  (type (;13;) (func (result (ref 9))))
  (type (;14;) (func (param (ref 9) i32) (result (ref 9))))
  (type (;15;) (func))
  (type (;16;) (func (param (ref 9) i32) (result (ref 9))))
  (type (;17;) (func (param (ref 9) i32) (result (ref 9))))
  (type (;18;) (struct (field i32)))
  (type (;19;) (func))
  (type (;20;) (array (mut v128)))
  (type (;21;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;22;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;23;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;24;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (type (;25;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 3))
  (export "identity_box" (func 4))
  (export "identity_box$dew$i32" (func 6))
  (export "__dew_init" (func 7))
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
  (func (;1;) (type 11) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;2;) (type 13) (result (ref 9))
    (local eqref)
    global.get 0
    local.set 0
    local.get 0
    struct.new 9
    ref.cast (ref 9)
  )
  (func (;3;) (type 15)
    (local eqref)
    call 2
    ref.cast (ref 9)
    i32.const 1
    call 5
    local.set 0
    i32.const 1
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x6c616320 0x6361626c 0x6761206b 0x67657267
    v128.const i32x4 0x00657461 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 3
    i32.const 0
    i32.const 35
    struct.new 21
    call 0
  )
  (func (;4;) (type 16) (param (ref 9) i32) (result (ref 9))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 9)
  )
  (func (;5;) (type 17) (param (ref 9) i32) (result (ref 9))
    local.get 1
    if (result eqref) ;; label = @1
      local.get 0
    else
      local.get 0
    end
    ref.cast (ref 9)
  )
  (func (;6;) (type 17) (param (ref 9) i32) (result (ref 9))
    local.get 0
    local.get 1
    call 4
  )
  (func (;7;) (type 19)
    ref.func 1
    struct.new 10
    global.set 0
  )
)
