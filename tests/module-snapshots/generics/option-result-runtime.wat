(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;10;) (sub (struct (field i32))))
  (type (;11;) (sub final 10 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;12;) (sub final 10 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;13;) (func (param eqref) (result i32)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (result (ref 8))))
  (type (;16;) (func (result (ref 8))))
  (type (;17;) (func (result (ref 10))))
  (type (;18;) (func (result (ref 10))))
  (type (;19;) (func))
  (type (;20;) (array (mut v128)))
  (type (;21;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;22;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;23;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;24;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (type (;25;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 6))
  (func (;0;) (type 13) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 21)
    struct.get 21 2
  )
  (func (;1;) (type 14) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;2;) (type 15) (result (ref 8))
    i32.const 1
    i32.const 0
    i64.const 42
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 9
    ref.cast (ref 8)
  )
  (func (;3;) (type 16) (result (ref 8))
    i32.const 1
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    v128.const i32x4 0x6c6c6568 0x0000006f 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 5
    struct.new 21
    struct.new 9
    ref.cast (ref 8)
  )
  (func (;4;) (type 17) (result (ref 10))
    i32.const 0
    i32.const 7
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 11
    ref.cast (ref 10)
  )
  (func (;5;) (type 18) (result (ref 10))
    i32.const 1
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    v128.const i32x4 0x00646162 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    struct.new 12
    ref.cast (ref 10)
  )
  (func (;6;) (type 19)
    (local i64 eqref i32 eqref eqref i32 eqref i32 eqref i32 eqref i32)
    call 2
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 9)
        struct.get 9 2
        local.set 0
        local.get 0
        i64.const 42
        i64.eq
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    v128.const i32x4 0x6974704f 0x493c6e6f 0x003e3436 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 11
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 3
    local.set 6
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 6
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 7
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 9)
        struct.get 9 6
        local.set 1
        local.get 1
        call 1
        i32.const 5
        i32.eq
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
    v128.const i32x4 0x6974704f 0x533c6e6f 0x6e697274 0x00003e67
    array.new_fixed 20 1
    i32.const 0
    i32.const 14
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 4
    local.set 8
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 8
            ref.cast (ref 10)
            struct.get 10 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 8
          ref.cast (ref 11)
          struct.get 11 1
          local.set 2
          local.get 2
          i32.const 7
          i32.eq
          local.set 9
          br 2 (;@1;)
        end
        i32.const 0
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
    v128.const i32x4 0x75736552 0x3a3a746c 0x00006b4f 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 10
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 5
    local.set 10
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 10
            ref.cast (ref 10)
            struct.get 10 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 11
          br 2 (;@1;)
        end
        local.get 10
        ref.cast (ref 12)
        struct.get 12 6
        local.set 3
        local.get 3
        call 1
        i32.const 3
        i32.eq
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    v128.const i32x4 0x75736552 0x3a3a746c 0x00727245 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 11
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
