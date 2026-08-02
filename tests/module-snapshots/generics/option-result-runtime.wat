(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (sub (struct (field i32))))
  (type (;3;) (sub final 2 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;4;) (sub final 2 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;5;) (func (param eqref) (result i32)))
  (type (;6;) (func (param eqref) (result i32)))
  (type (;7;) (func (result (ref 0))))
  (type (;8;) (func (result (ref 0))))
  (type (;9;) (func (result (ref 2))))
  (type (;10;) (func (result (ref 2))))
  (type (;11;) (func))
  (type (;12;) (array (mut v128)))
  (type (;13;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;16;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (type (;17;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 6))
  (func (;0;) (type 5) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 13)
    struct.get 13 2
  )
  (func (;1;) (type 6) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;2;) (type 7) (result (ref 0))
    i32.const 1
    i32.const 0
    i64.const 42
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    ref.cast (ref 0)
  )
  (func (;3;) (type 8) (result (ref 0))
    i32.const 1
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    v128.const i32x4 0x6c6c6568 0x0000006f 0x00000000 0x00000000
    array.new_fixed 12 1
    i32.const 0
    i32.const 5
    struct.new 13
    struct.new 1
    ref.cast (ref 0)
  )
  (func (;4;) (type 9) (result (ref 2))
    i32.const 0
    i32.const 7
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 3
    ref.cast (ref 2)
  )
  (func (;5;) (type 10) (result (ref 2))
    i32.const 1
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    v128.const i32x4 0x00646162 0x00000000 0x00000000 0x00000000
    array.new_fixed 12 1
    i32.const 0
    i32.const 3
    struct.new 13
    struct.new 4
    ref.cast (ref 2)
  )
  (func (;6;) (type 11)
    (local i64 eqref i32 eqref eqref i32 eqref i32 eqref i32 eqref i32)
    call 2
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 1)
        struct.get 1 2
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
    array.new_fixed 12 1
    i32.const 0
    i32.const 11
    struct.new 13
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
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 7
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 1)
        struct.get 1 6
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
    array.new_fixed 12 1
    i32.const 0
    i32.const 14
    struct.new 13
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
            ref.cast (ref 2)
            struct.get 2 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 8
          ref.cast (ref 3)
          struct.get 3 1
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
    array.new_fixed 12 1
    i32.const 0
    i32.const 10
    struct.new 13
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
            ref.cast (ref 2)
            struct.get 2 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 11
          br 2 (;@1;)
        end
        local.get 10
        ref.cast (ref 4)
        struct.get 4 6
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
    array.new_fixed 12 1
    i32.const 0
    i32.const 11
    struct.new 13
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
