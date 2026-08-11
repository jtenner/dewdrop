(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (struct))
  (type (;2;) (func (result (ref 1))))
  (type (;3;) (func (param (ref 1) eqref eqref) (result (ref 0))))
  (type (;4;) (func (param (ref 0)) (result i32)))
  (type (;5;) (func (param (ref 0)) (result i32)))
  (type (;6;) (func (param (ref 0)) (result i32)))
  (type (;7;) (func (param (ref 0)) (result (ref 0))))
  (type (;8;) (func (param (ref 1) i32 i32) (result (ref 0))))
  (type (;9;) (func (param (ref 1) i64 i64) (result (ref 0))))
  (type (;10;) (func (param (ref 1) f64 f64) (result (ref 0))))
  (type (;11;) (func (param eqref eqref) (result (ref 0))))
  (type (;12;) (func))
  (type (;13;) (func (param i32 i32) (result (ref 0))))
  (type (;14;) (func (param i64 i64) (result (ref 0))))
  (type (;15;) (func (param f64 f64) (result (ref 0))))
  (type (;16;) (array (mut v128)))
  (type (;17;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;19;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;20;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (type (;21;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 8))
  (func (;0;) (type 2) (result (ref 1))
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;1;) (type 4) (param (ref 0)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 1
            local.set 2
            br 3 (;@1;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;2;) (type 5) (param (ref 0)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 2
            br 3 (;@1;)
          end
          i32.const 1
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;3;) (type 6) (param (ref 0)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 2
            br 3 (;@1;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;4;) (type 7) (param (ref 0)) (result (ref 0))
    (local eqref eqref)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 2
            struct.new 0
            local.set 2
            br 3 (;@1;)
          end
          i32.const 1
          struct.new 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        struct.new 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
  )
  (func (;5;) (type 8) (param (ref 1) i32 i32) (result (ref 0))
    local.get 1
    local.get 2
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 1
      local.get 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 0
      else
        i32.const 2
        struct.new 0
      end
    end
    ref.cast (ref 0)
  )
  (func (;6;) (type 9) (param (ref 1) i64 i64) (result (ref 0))
    local.get 1
    local.get 2
    i64.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 1
      local.get 2
      i64.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 0
      else
        i32.const 2
        struct.new 0
      end
    end
    ref.cast (ref 0)
  )
  (func (;7;) (type 10) (param (ref 1) f64 f64) (result (ref 0))
    local.get 1
    local.get 2
    f64.lt
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 1
      local.get 2
      f64.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 0
      else
        i32.const 2
        struct.new 0
      end
    end
    ref.cast (ref 0)
  )
  (func (;8;) (type 12)
    i32.const 1
    i32.const 2
    call 9
    call 1
    v128.const i32x4 0x7373656c 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 1
    i32.const 0
    i32.const 4
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    i32.const 7
    call 9
    call 2
    v128.const i32x4 0x61757165 0x0000006c 0x00000000 0x00000000
    array.new_fixed 16 1
    i32.const 0
    i32.const 5
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 9
    i32.const 3
    call 9
    call 3
    v128.const i32x4 0x61657267 0x00726574 0x00000000 0x00000000
    array.new_fixed 16 1
    i32.const 0
    i32.const 7
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    struct.new 0
    call 4
    call 3
    v128.const i32x4 0x65766572 0x20657372 0x7373656c 0x00000000
    array.new_fixed 16 1
    i32.const 0
    i32.const 12
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    struct.new 0
    call 4
    call 2
    v128.const i32x4 0x65766572 0x20657372 0x61757165 0x0000006c
    array.new_fixed 16 1
    i32.const 0
    i32.const 13
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    struct.new 0
    call 4
    call 1
    v128.const i32x4 0x65766572 0x20657372 0x61657267 0x00726574
    array.new_fixed 16 1
    i32.const 0
    i32.const 15
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const -1
    i64.const 2
    call 10
    call 1
    v128.const i32x4 0x20343669 0x706d6f63 0x74617261 0x0000726f
    array.new_fixed 16 1
    i32.const 0
    i32.const 14
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    f64.const 0x1p+2 (;=4;)
    f64.const 0x1.8p+1 (;=3;)
    call 11
    call 3
    v128.const i32x4 0x20343666 0x706d6f63 0x74617261 0x0000726f
    array.new_fixed 16 1
    i32.const 0
    i32.const 14
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;9;) (type 13) (param i32 i32) (result (ref 0))
    call 0
    local.get 0
    local.get 1
    call 5
    ref.cast (ref 0)
  )
  (func (;10;) (type 14) (param i64 i64) (result (ref 0))
    call 0
    local.get 0
    local.get 1
    call 6
    ref.cast (ref 0)
  )
  (func (;11;) (type 15) (param f64 f64) (result (ref 0))
    call 0
    local.get 0
    local.get 1
    call 7
    ref.cast (ref 0)
  )
)
