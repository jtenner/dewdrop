(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\81\81\90\02\00\00\00\00\00\00\00\00\01\01\01\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\00\02\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\02\02\01\02\0e\00\00\00\00\00\01\01\01\01\00\00\0a\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01n\00\00\00\00\00\01\02\0e\00\04\0a\00\00\00\00\00\01\01\b8\17\01\82\80\80\80\80\f7\02\01\81\80\80\80\80\f7\02\00\01n\00\00\00\03\04\03-\00\00\00\00\00\01\01\01\01\00\00\0e\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\035\00\00\00\00\00\01\01\01\01\00\00\0f\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\03g\00\00\00\00\00\01\01\01\01\00\00\0e\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\03o\00\00\00\00\00\01\01\01\01\00\00\0f\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\00\00\00\00\04\03-\00\01\0e\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\035\00\04\0f\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\03g\00\01\0e\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\03o\00\04\0f\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\82\03\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (sub (struct (field i32))))
  (type (;10;) (sub final 9 (struct (field i32) (field i32) (field i32))))
  (type (;11;) (func (param (ref 9)) (result (ref 9))))
  (type (;12;) (func (param i32 i32) (result i32)))
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
  (func (;1;) (type 11) (param (ref 9)) (result (ref 9))
    local.get 0
    ref.cast (ref 9)
  )
  (func (;2;) (type 12) (param i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 i32 i32)
    local.get 0
    local.set 8
    local.get 1
    local.set 9
    i32.const 0
    local.get 8
    local.get 9
    struct.new 10
    call 1
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 9)
      struct.get 9 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 6
        ref.cast (ref 10)
        struct.get 10 1
        local.set 2
        i32.const 1
        if (result i32) ;; label = @3
          local.get 6
          ref.cast (ref 10)
          struct.get 10 2
          local.set 3
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 6
        ref.cast (ref 9)
        struct.get 9 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 6
          ref.cast (ref 10)
          struct.get 10 1
          local.set 2
          i32.const 1
          if (result i32) ;; label = @4
            local.get 6
            ref.cast (ref 10)
            struct.get 10 2
            local.set 3
            i32.const 1
          else
            i32.const 0
          end
        else
          i32.const 0
        end
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
      ref.cast (ref 9)
      struct.get 9 0
      i32.const 2
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
  (func (;3;) (type 13)
    i32.const 1
    i32.const 20
    call 2
    i32.const 21
    i32.eq
    v128.const i32x4 0x65746c61 0x74616e72 0x20657669 0x72617567
    v128.const i32x4 0x20646564 0x6c796170 0x0064616f 0x00000000
    array.new_fixed 14 2
    i32.const 0
    i32.const 27
    struct.new 15
    call 0
    i32.const 0
    i32.const 22
    call 2
    i32.const 22
    i32.eq
    v128.const i32x4 0x65746c61 0x74616e72 0x20657669 0x6c6c6166
    v128.const i32x4 0x6b636162 0x79617020 0x64616f6c 0x00000000
    array.new_fixed 14 2
    i32.const 0
    i32.const 28
    struct.new 15
    call 0
  )
)
