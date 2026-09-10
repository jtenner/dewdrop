(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\02\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\09\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\01\02\04\02]\00\00\00\00\00\01\01\01\01\00\00\0b\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\02e\00\00\00\00\00\01\01\01\01\00\00\0c\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\02\c7\01\00\00\00\00\00\01\01\01\01\00\00\0b\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\02\cf\01\00\00\00\00\00\01\01\01\01\00\00\0c\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\00\00\00\00\04\02]\00\01\0b\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\02e\00\04\0c\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\02\c7\01\00\01\0b\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\02\cf\01\00\04\0c\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\88\01\00\00\00\00")
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
  (func (;1;) (type 9) (param i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 2
    end
  )
  (func (;2;) (type 10)
    (local i32 i32 i32 i32)
    i32.const 1
    call 1
    local.set 0
    block ;; label = @1
      local.get 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 10
        local.set 1
        br 1 (;@1;)
      end
      local.get 0
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 20
        local.set 1
        br 1 (;@1;)
      end
      local.get 0
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 30
        local.set 1
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 1
    i32.const 10
    i32.eq
    v128.const i32x4 0x6c616373 0x65207261 0x206d756e 0x75736572
    v128.const i32x4 0x6c20746c 0x00746665 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 23
    struct.new 12
    call 0
    i32.const 0
    call 1
    local.set 2
    block ;; label = @1
      local.get 2
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 3
        br 1 (;@1;)
      end
      local.get 2
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 2
        local.set 3
        br 1 (;@1;)
      end
      local.get 2
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 3
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
    i32.const 3
    i32.eq
    v128.const i32x4 0x6c616373 0x65207261 0x206d756e 0x75736572
    v128.const i32x4 0x7220746c 0x74686769 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 24
    struct.new 12
    call 0
  )
)
