(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\81\81\90\02\00\00\00\00\00\00\00\00\01\01\01\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\00\02\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\02\02\02\02\0c\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\80\01\00\02\18\00\00\00\00\00\01\01\01\01\00\00\0b\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\80\01\00\00\00\00\00\02\02\0c\00\04\09\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\80\01\00\02\18\00\04\0b\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01\80\01\00\00\00\03\04\03-\00\00\00\00\00\01\01\01\01\00\00\0f\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\035\00\00\00\00\00\01\01\01\01\00\00\10\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\03g\00\00\00\00\00\01\01\01\01\00\00\0f\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\03o\00\00\00\00\00\01\01\01\01\00\00\10\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\00\00\00\00\04\03-\00\01\0f\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\035\00\04\10\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\03g\00\01\0f\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\03o\00\04\10\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\a3\03\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (struct (field i32) (field i32)))
  (type (;10;) (sub (struct (field i32))))
  (type (;11;) (sub final 10 (struct (field i32) (field (ref 9)))))
  (type (;12;) (func (param (ref 10)) (result (ref 10))))
  (type (;13;) (func (param i32 i32) (result i32)))
  (type (;14;) (func))
  (type (;15;) (array (mut v128)))
  (type (;16;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;17;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;19;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
  (type (;20;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
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
  (func (;1;) (type 12) (param (ref 10)) (result (ref 10))
    local.get 0
    ref.cast (ref 10)
  )
  (func (;2;) (type 13) (param i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 i32 i32 eqref)
    local.get 0
    local.set 8
    local.get 1
    local.set 9
    local.get 8
    local.get 9
    struct.new 9
    local.set 10
    i32.const 0
    local.get 10
    ref.cast (ref 9)
    struct.new 11
    call 1
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 10)
      struct.get 10 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 6
        ref.cast (ref 11)
        struct.get 11 1
        ref.cast (ref 9)
        struct.get 9 0
        local.set 2
        i32.const 1
        if (result i32) ;; label = @3
          local.get 6
          ref.cast (ref 11)
          struct.get 11 1
          ref.cast (ref 9)
          struct.get 9 1
          local.set 3
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 2
        i32.const 0
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 3
          i32.const 1
          i32.add
        else
          local.get 3
        end
        local.set 7
        br 1 (;@1;)
      end
      local.get 6
      ref.cast (ref 10)
      struct.get 10 0
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;3;) (type 14)
    i32.const 1
    i32.const 20
    call 2
    i32.const 21
    i32.eq
    v128.const i32x4 0x7473656e 0x67206465 0x64726175 0x70206465
    v128.const i32x4 0x6f6c7961 0x00006461 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 22
    struct.new 16
    call 0
    i32.const 0
    i32.const 22
    call 2
    i32.const 22
    i32.eq
    v128.const i32x4 0x7473656e 0x66206465 0x626c6c61 0x206b6361
    v128.const i32x4 0x6c796170 0x0064616f 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 23
    struct.new 16
    call 0
  )
)
