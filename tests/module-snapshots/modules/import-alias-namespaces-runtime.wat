(module
  (type (;0;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field i32))))
  (type (;3;) (sub final 1 (struct (field i32) (field i32))))
  (type (;4;) (func (param i32) (result (ref 0))))
  (type (;5;) (struct (field i32)))
  (type (;6;) (func (param (ref 5)) (result i32)))
  (type (;7;) (func (param eqref) (result i32)))
  (type (;8;) (func (param (ref 1)) (result i32)))
  (type (;9;) (func))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (array (mut v128)))
  (type (;12;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;15;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 4) (param i32) (result (ref 0))
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 6) (param (ref 5)) (result i32)
    local.get 0
    ref.cast (ref 5)
    struct.get 5 0
  )
  (func (;2;) (type 8) (param (ref 1)) (result i32)
    (local i32 i32 eqref i32)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 3
              ref.cast (ref 1)
              struct.get 1 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 4
            br 3 (;@1;)
          end
          local.get 3
          ref.cast (ref 2)
          struct.get 2 1
          local.set 1
          local.get 1
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 3)
        struct.get 3 1
        local.set 2
        local.get 2
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;3;) (type 9)
    (local eqref eqref eqref i32 i32 i32 (ref 5) eqref i32)
    i32.const 40
    call 0
    local.set 0
    i32.const 1
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    struct.new 2
    local.set 1
    i32.const 2
    local.get 1
    ref.cast (ref 1)
    call 2
    i32.const 1
    i32.add
    struct.new 3
    local.set 2
    local.get 2
    local.set 7
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 7
              ref.cast (ref 1)
              struct.get 1 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 8
            br 3 (;@1;)
          end
          local.get 7
          ref.cast (ref 2)
          struct.get 2 1
          local.set 3
          local.get 3
          local.set 8
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 3)
        struct.get 3 1
        local.set 4
        local.get 4
        local.set 8
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
    local.set 5
    local.get 5
    i32.const 1
    i32.add
    struct.new 5
    local.set 6
    local.get 6
    call 4
    i32.const 42
    i32.eq
    v128.const i32x4 0x61696c61 0x72742073 0x20746961 0x6e756f62
    v128.const i32x4 0x00000064 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 17
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 6
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x61696c61 0x72742073 0x20746961 0x74617473
    v128.const i32x4 0x6c206369 0x756b6f6f 0x00000070 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 25
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;4;) (type 10) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 5)
    call 1
  )
)
