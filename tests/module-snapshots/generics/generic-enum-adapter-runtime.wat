(module
  (type (;0;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (struct (field (ref 1))))
  (type (;3;) (sub final 1 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;4;) (sub final 1 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;5;) (sub final 1 (struct (field i32) (field (ref 0)))))
  (type (;6;) (sub (struct (field funcref))))
  (type (;7;) (func (param (ref 1)) (result (ref 1))))
  (type (;8;) (func (param eqref (ref 1)) (result (ref 1))))
  (type (;9;) (func (param (ref 2)) (result (ref 2))))
  (type (;10;) (func (result eqref)))
  (type (;11;) (func))
  (type (;12;) (func (param (ref 1)) (result (ref 1))))
  (type (;13;) (func (param (ref 2)) (result (ref 2))))
  (type (;14;) (func (param (ref 1)) (result (ref 1))))
  (type (;15;) (func (param (ref 2)) (result (ref 2))))
  (type (;16;) (struct (field i32)))
  (type (;17;) (func))
  (type (;18;) (array (mut v128)))
  (type (;19;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;22;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;23;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 1))
  (export "echo_maybe" (func 2))
  (export "echo_envelope" (func 3))
  (export "echo_maybe$dew$i32" (func 6))
  (export "echo_envelope$dew$i32" (func 7))
  (export "__dew_init" (func 8))
  (elem (;0;) declare func 4)
  (func (;0;) (type 10) (result eqref)
    global.get 0
  )
  (func (;1;) (type 11)
    (local eqref i32 i32 (ref 0) i32 eqref eqref i32 eqref i32 eqref i32 eqref i32)
    call 0
    local.set 0
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 6)
    struct.get 6 0
    ref.test (ref 7)
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 42
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 3
      local.get 5
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 7)
      call_ref 7
    else
      local.get 5
      i32.const 1
      i32.const 42
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 3
      local.get 5
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 8)
      call_ref 8
    end
    ref.cast (ref 1)
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 6
        ref.cast (ref 3)
        struct.get 3 1
        local.set 1
        local.get 1
        i32.const 42
        i32.eq
        local.set 7
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
    v128.const i32x4 0x656e6567 0x20636972 0x6c707574 0x6e652065
    v128.const i32x4 0x70206d75 0x6f6c7961 0x00006461 0x00000000
    array.new_fixed 18 2
    i32.const 0
    i32.const 26
    struct.new 19
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    i32.const 43
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    call 4
    local.set 8
    block ;; label = @1
      local.get 8
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 2
      i32.eq
      if ;; label = @2
        local.get 8
        ref.cast (ref 4)
        struct.get 4 1
        local.set 2
        local.get 2
        i32.const 43
        i32.eq
        local.set 9
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
    v128.const i32x4 0x656e6567 0x20636972 0x75727473 0x65207463
    v128.const i32x4 0x206d756e 0x6c796170 0x0064616f 0x00000000
    array.new_fixed 18 2
    i32.const 0
    i32.const 27
    struct.new 19
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    i32.const 44
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    struct.new 5
    call 4
    local.set 10
    block ;; label = @1
      local.get 10
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 3
      i32.eq
      if ;; label = @2
        local.get 10
        ref.cast (ref 5)
        struct.get 5 1
        local.set 3
        local.get 3
        struct.get 0 0
        i32.const 44
        i32.eq
        local.set 11
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    v128.const i32x4 0x7473656e 0x67206465 0x72656e65 0x73206369
    v128.const i32x4 0x63757274 0x6e652074 0x70206d75 0x6f6c7961
    v128.const i32x4 0x00006461 0x00000000 0x00000000 0x00000000
    array.new_fixed 18 3
    i32.const 0
    i32.const 34
    struct.new 19
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 45
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 3
    struct.new 2
    call 5
    ref.cast (ref 2)
    struct.get 2 0
    local.set 12
    block ;; label = @1
      local.get 12
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 12
        ref.cast (ref 3)
        struct.get 3 1
        local.set 4
        local.get 4
        i32.const 45
        i32.eq
        local.set 13
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 13
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 13
    v128.const i32x4 0x7473656e 0x67206465 0x72656e65 0x65206369
    v128.const i32x4 0x206d756e 0x75727473 0x66207463 0x646c6569
    array.new_fixed 18 2
    i32.const 0
    i32.const 32
    struct.new 19
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 12) (param (ref 1)) (result (ref 1))
    (local eqref eqref (ref 0) eqref eqref)
    local.get 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                local.get 4
                ref.cast (ref 1)
                struct.get 1 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;) 3 (;@3;) 4 (;@2;)
              end
              i32.const 0
              struct.new 1
              local.set 5
              br 4 (;@1;)
            end
            local.get 4
            ref.cast (ref 3)
            struct.get 3 6
            local.set 1
            i32.const 1
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 1
            struct.new 3
            local.set 5
            br 3 (;@1;)
          end
          local.get 4
          ref.cast (ref 4)
          struct.get 4 6
          local.set 2
          i32.const 2
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 2
          struct.new 4
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 5)
        struct.get 5 1
        local.set 3
        i32.const 3
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 3
        struct.get 0 5
        struct.new 0
        struct.new 5
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    ref.cast (ref 1)
  )
  (func (;3;) (type 13) (param (ref 2)) (result (ref 2))
    local.get 0
    struct.get 2 0
    call 2
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;4;) (type 14) (param (ref 1)) (result (ref 1))
    (local i32 i32 (ref 0) eqref eqref)
    local.get 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                local.get 4
                ref.cast (ref 1)
                struct.get 1 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;) 3 (;@3;) 4 (;@2;)
              end
              i32.const 0
              struct.new 1
              local.set 5
              br 4 (;@1;)
            end
            local.get 4
            ref.cast (ref 3)
            struct.get 3 1
            local.set 1
            i32.const 1
            local.get 1
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            ref.null eq
            struct.new 3
            local.set 5
            br 3 (;@1;)
          end
          local.get 4
          ref.cast (ref 4)
          struct.get 4 1
          local.set 2
          i32.const 2
          local.get 2
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 4
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 5)
        struct.get 5 1
        local.set 3
        i32.const 3
        local.get 3
        struct.get 0 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 0
        struct.new 5
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    ref.cast (ref 1)
  )
  (func (;5;) (type 15) (param (ref 2)) (result (ref 2))
    local.get 0
    struct.get 2 0
    call 4
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;6;) (type 14) (param (ref 1)) (result (ref 1))
    (local eqref eqref eqref)
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 0
        ref.cast (ref 3)
        struct.get 3 1
        struct.new 16
        struct.new 3
      else
        local.get 0
        ref.cast (ref 1)
        struct.get 1 0
        i32.const 2
        i32.eq
        if (result eqref) ;; label = @3
          i32.const 2
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 0
          ref.cast (ref 4)
          struct.get 4 1
          struct.new 16
          struct.new 4
        else
          local.get 0
          ref.cast (ref 1)
          struct.get 1 0
          i32.const 3
          i32.eq
          if (result eqref) ;; label = @4
            i32.const 3
            local.get 0
            ref.cast (ref 5)
            struct.get 5 1
            local.set 1
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 1
            ref.cast (ref 0)
            struct.get 0 0
            struct.new 16
            struct.new 0
            struct.new 5
          else
            unreachable
          end
        end
      end
    end
    ref.cast (ref 1)
    call 2
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 2
        ref.cast (ref 3)
        struct.get 3 6
        ref.cast (ref 16)
        struct.get 16 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 3
      else
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        i32.const 2
        i32.eq
        if (result eqref) ;; label = @3
          i32.const 2
          local.get 2
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 16)
          struct.get 16 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 4
        else
          local.get 2
          ref.cast (ref 1)
          struct.get 1 0
          i32.const 3
          i32.eq
          if (result eqref) ;; label = @4
            i32.const 3
            local.get 2
            ref.cast (ref 5)
            struct.get 5 1
            local.set 3
            local.get 3
            ref.cast (ref 0)
            struct.get 0 5
            ref.cast (ref 16)
            struct.get 16 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            ref.null eq
            struct.new 0
            struct.new 5
          else
            unreachable
          end
        end
      end
    end
    ref.cast (ref 1)
  )
  (func (;7;) (type 15) (param (ref 2)) (result (ref 2))
    (local eqref eqref eqref eqref eqref)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    local.set 1
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 1
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 1
        ref.cast (ref 3)
        struct.get 3 1
        struct.new 16
        struct.new 3
      else
        local.get 1
        ref.cast (ref 1)
        struct.get 1 0
        i32.const 2
        i32.eq
        if (result eqref) ;; label = @3
          i32.const 2
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 1
          ref.cast (ref 4)
          struct.get 4 1
          struct.new 16
          struct.new 4
        else
          local.get 1
          ref.cast (ref 1)
          struct.get 1 0
          i32.const 3
          i32.eq
          if (result eqref) ;; label = @4
            i32.const 3
            local.get 1
            ref.cast (ref 5)
            struct.get 5 1
            local.set 2
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            struct.new 16
            struct.new 0
            struct.new 5
          else
            unreachable
          end
        end
      end
    end
    ref.cast (ref 1)
    struct.new 2
    call 3
    local.set 3
    local.get 3
    ref.cast (ref 2)
    struct.get 2 0
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 4
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 4
        ref.cast (ref 3)
        struct.get 3 6
        ref.cast (ref 16)
        struct.get 16 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 3
      else
        local.get 4
        ref.cast (ref 1)
        struct.get 1 0
        i32.const 2
        i32.eq
        if (result eqref) ;; label = @3
          i32.const 2
          local.get 4
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 16)
          struct.get 16 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 4
        else
          local.get 4
          ref.cast (ref 1)
          struct.get 1 0
          i32.const 3
          i32.eq
          if (result eqref) ;; label = @4
            i32.const 3
            local.get 4
            ref.cast (ref 5)
            struct.get 5 1
            local.set 5
            local.get 5
            ref.cast (ref 0)
            struct.get 0 5
            ref.cast (ref 16)
            struct.get 16 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            ref.null eq
            struct.new 0
            struct.new 5
          else
            unreachable
          end
        end
      end
    end
    ref.cast (ref 1)
    struct.new 2
  )
  (func (;8;) (type 17)
    ref.func 4
    struct.new 6
    global.set 0
  )
)
