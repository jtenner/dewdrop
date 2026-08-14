(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (struct (field i32)))
  (type (;3;) (func))
  (type (;4;) (func (param (ref 0)) (result eqref)))
  (type (;5;) (func))
  (type (;6;) (func (param (ref 0)) (result i32)))
  (type (;7;) (func (param (ref 0)) (result i64)))
  (type (;8;) (func (param (ref 0)) (result f64)))
  (type (;9;) (func (param (ref 0)) (result eqref)))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 3)
    unreachable
  )
  (func (;1;) (type 5)
    i32.const 0
    i32.const 42
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x6576654e 0x33692072
    v128.const i32x4 0x6f6a2032 0x00006e69 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 22
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 0
    i64.const 42
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    call 3
    i64.const 42
    i64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x6576654e 0x36692072
    v128.const i32x4 0x6f6a2034 0x00006e69 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 22
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x1.54p+5 (;=42.5;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    call 4
    f64.const 0x1.54p+5 (;=42.5;)
    f64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x6576654e 0x36662072
    v128.const i32x4 0x6f6a2034 0x00006e69 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 22
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    i32.const 42
    struct.new 2
    struct.new 1
    call 5
    ref.cast (ref 2)
    struct.get 2 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x6576654e 0x65722072
    v128.const i32x4 0x65726566 0x2065636e 0x6e696f6a 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 28
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 6) (param (ref 0)) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 2
          ref.cast (ref 1)
          struct.get 1 1
          local.set 1
          local.get 1
          local.set 3
          br 2 (;@1;)
        end
        call 0
        unreachable
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;3;) (type 7) (param (ref 0)) (result i64)
    (local i64 eqref i64)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 2
          ref.cast (ref 1)
          struct.get 1 2
          local.set 1
          local.get 1
          local.set 3
          br 2 (;@1;)
        end
        call 0
        unreachable
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;4;) (type 8) (param (ref 0)) (result f64)
    (local f64 eqref f64)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 2
          ref.cast (ref 1)
          struct.get 1 4
          local.set 1
          local.get 1
          local.set 3
          br 2 (;@1;)
        end
        call 0
        unreachable
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;5;) (type 9) (param (ref 0)) (result eqref)
    (local eqref eqref eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 2
          ref.cast (ref 1)
          struct.get 1 6
          local.set 1
          local.get 1
          local.set 3
          br 2 (;@1;)
        end
        call 0
        unreachable
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
)
