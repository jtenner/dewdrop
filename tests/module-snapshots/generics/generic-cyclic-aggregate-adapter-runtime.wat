(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field (ref 0)))))
  (type (;2;) (func (param (ref 0)) (result (ref 0))))
  (type (;3;) (func (param (ref 0)) (result i32)))
  (type (;4;) (func))
  (type (;5;) (func (param (ref 0)) (result (ref 0))))
  (type (;6;) (func (param (ref 0)) (result (ref 0))))
  (type (;7;) (struct (field i32)))
  (type (;8;) (array (mut v128)))
  (type (;9;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;10;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;12;) (struct (field (mut (ref 8))) (field (mut i32)) (field (mut i32))))
  (type (;13;) (struct (field (mut (ref 8))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (func (param (ref 0)) (result (ref 0))))
  (export "main" (func 1))
  (export "echo_list" (func 2))
  (export "echo_list$dew$i32" (func 4))
  (func (;0;) (type 3) (param (ref 0)) (result i32)
    (local i32 (ref 0) eqref i32)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 3
        ref.cast (ref 1)
        struct.get 1 7
        local.set 2
        local.get 1
        local.get 2
        call 0
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;1;) (type 4)
    (local (ref 0))
    i32.const 1
    i32.const 1
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 1
    i32.const 2
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 1
    i32.const 3
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 0
    struct.new 0
    struct.new 1
    struct.new 1
    struct.new 1
    call 3
    local.set 0
    local.get 0
    call 0
    i32.const 6
    i32.eq
    v128.const i32x4 0x6c637963 0x6e206369 0x6e696d6f 0x61206c61
    v128.const i32x4 0x74706164 0x67207265 0x68706172 0x00000000
    array.new_fixed 8 2
    i32.const 0
    i32.const 28
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 5) (param (ref 0)) (result (ref 0))
    (local eqref (ref 0) eqref eqref)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          struct.new 0
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 1)
        struct.get 1 6
        local.set 1
        local.get 3
        ref.cast (ref 1)
        struct.get 1 7
        local.set 2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 1
        local.get 2
        struct.new 1
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 0)
  )
  (func (;3;) (type 6) (param (ref 0)) (result (ref 0))
    (local i32 (ref 0) eqref eqref)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          struct.new 0
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 3
        ref.cast (ref 1)
        struct.get 1 7
        local.set 2
        i32.const 1
        local.get 1
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        local.get 2
        struct.new 1
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 0)
  )
  (func (;4;) (type 6) (param (ref 0)) (result (ref 0))
    (local eqref eqref eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 0
      ref.cast (ref 0)
      struct.get 0 0
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
        ref.cast (ref 1)
        struct.get 1 1
        struct.new 7
        local.get 0
        ref.cast (ref 1)
        struct.get 1 7
        local.set 1
        local.get 1
        ref.cast (ref 0)
        call 5
        struct.new 1
      else
        unreachable
      end
    end
    ref.cast (ref 0)
    call 2
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 6
        ref.cast (ref 7)
        struct.get 7 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        local.get 2
        ref.cast (ref 1)
        struct.get 1 7
        local.set 3
        local.get 3
        ref.cast (ref 0)
        call 6
        struct.new 1
      else
        unreachable
      end
    end
    ref.cast (ref 0)
  )
  (func (;5;) (type 14) (param (ref 0)) (result (ref 0))
    (local eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 0
      ref.cast (ref 0)
      struct.get 0 0
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
        ref.cast (ref 1)
        struct.get 1 1
        struct.new 7
        local.get 0
        ref.cast (ref 1)
        struct.get 1 7
        local.set 1
        local.get 1
        ref.cast (ref 0)
        call 5
        struct.new 1
      else
        unreachable
      end
    end
    ref.cast (ref 0)
  )
  (func (;6;) (type 14) (param (ref 0)) (result (ref 0))
    (local eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 0
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 0
        ref.cast (ref 1)
        struct.get 1 6
        ref.cast (ref 7)
        struct.get 7 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        local.get 0
        ref.cast (ref 1)
        struct.get 1 7
        local.set 1
        local.get 1
        ref.cast (ref 0)
        call 6
        struct.new 1
      else
        unreachable
      end
    end
    ref.cast (ref 0)
  )
)
