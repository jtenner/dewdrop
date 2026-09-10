(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\06\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\80\08\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\02\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\00\01\00\00\01\00\00\01\00\00\03\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\00\00\01\00\00\04\01\01\00\00\00\00\00\00\00\00\01\01\03\00\00\01\00\01\00\00\00\05\01\80\11\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\01\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\01\00\01\01\01\04\02\00\00\00\01\01\00\00\00\01\00\00\00\00\01\01\01\01\00\00\0a\00\01\01\00\00\02\02\06\02\1c\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02E\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02p\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02\8d\01\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02\ee\01\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02\f6\01\00\00\00\00\00\01\01\01\01\00\00\14\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\00\00\00\00\06\02\1c\00\04\09\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02E\00\04\09\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02p\00\04\09\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02\8d\01\00\04\09\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02\ee\01\00\01\13\00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\02\f6\01\00\04\14\00\00\00\00\00\01\01\b8\17\01\83\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01\8d\01\00\00\00\05\02\05\00\00\01\01\05\04\00\00\00\01\01\01\01\00\06\01\01\04\00\05\02\00\00\00\00\00\01\01\01\01\00\00\0a\00\00\00\00\00\00\01\05\02\00\04\0a\00\00\00\00\00\00\00\00\00")
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
  (type (;11;) (func (param (ref 9)) (result (ref 9))))
  (type (;12;) (func (param eqref) (result eqref)))
  (type (;13;) (func (param eqref (ref 9)) (result (ref 9))))
  (type (;14;) (func (param eqref eqref) (result eqref)))
  (type (;15;) (func (result eqref)))
  (type (;16;) (func))
  (type (;17;) (func (param eqref) (result eqref)))
  (type (;18;) (func))
  (type (;19;) (array (mut v128)))
  (type (;20;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;22;) (struct (field (ref 19)) (field i32) (field i32)))
  (type (;23;) (struct (field (mut (ref 19))) (field (mut i32)) (field (mut i32))))
  (type (;24;) (struct (field (mut (ref 19))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 2))
  (export "identity" (func 3))
  (export "__dew_init" (func 5))
  (elem (;0;) declare func 4)
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
  (func (;1;) (type 15) (result eqref)
    global.get 0
  )
  (func (;2;) (type 16)
    (local eqref (ref 9) eqref i32)
    call 1
    local.set 0
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.test (ref 11)
    if (result eqref) ;; label = @1
      i32.const 42
      local.set 3
      local.get 3
      struct.new 9
      ref.cast (ref 9)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 11)
      call_ref 11
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.test (ref 12)
      if (result eqref) ;; label = @2
        i32.const 42
        local.set 3
        local.get 3
        struct.new 9
        ref.cast (ref 9)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 12)
        call_ref 12
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.test (ref 13)
        if (result eqref) ;; label = @3
          local.get 2
          i32.const 42
          local.set 3
          local.get 3
          struct.new 9
          ref.cast (ref 9)
          local.get 2
          ref.cast (ref 10)
          struct.get 10 0
          ref.cast (ref 13)
          call_ref 13
        else
          local.get 2
          i32.const 42
          local.set 3
          local.get 3
          struct.new 9
          ref.cast (ref 9)
          local.get 2
          ref.cast (ref 10)
          struct.get 10 0
          ref.cast (ref 14)
          call_ref 14
        end
      end
    end
    ref.cast (ref 9)
    ref.cast (ref 9)
    local.set 1
    local.get 1
    ref.cast (ref 9)
    struct.get 9 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x73617265 0x67206465 0x72656e65 0x72206369
    v128.const i32x4 0x72656665 0x65636e65 0x6c616620 0x6361626c
    v128.const i32x4 0x0000006b 0x00000000 0x00000000 0x00000000
    array.new_fixed 19 3
    i32.const 0
    i32.const 33
    struct.new 20
    call 0
  )
  (func (;3;) (type 17) (param eqref) (result eqref)
    local.get 0
  )
  (func (;4;) (type 11) (param (ref 9)) (result (ref 9))
    local.get 0
    call 3
    ref.cast (ref 9)
  )
  (func (;5;) (type 18)
    ref.func 4
    struct.new 10
    global.set 0
  )
)
