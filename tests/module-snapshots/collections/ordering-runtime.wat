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
  (type (;9;) (struct))
  (type (;10;) (func (result (ref 9))))
  (type (;11;) (func (param (ref 9) eqref eqref) (result (ref 8))))
  (type (;12;) (func (param (ref 8)) (result i32)))
  (type (;13;) (func (param (ref 8)) (result i32)))
  (type (;14;) (func (param (ref 8)) (result i32)))
  (type (;15;) (func (param (ref 8)) (result (ref 8))))
  (type (;16;) (func (param (ref 9) i32 i32) (result (ref 8))))
  (type (;17;) (func (param (ref 9) i64 i64) (result (ref 8))))
  (type (;18;) (func (param (ref 9) f64 f64) (result (ref 8))))
  (type (;19;) (func (param eqref eqref) (result (ref 8))))
  (type (;20;) (func))
  (type (;21;) (func (param i32 i32) (result (ref 8))))
  (type (;22;) (func (param i64 i64) (result (ref 8))))
  (type (;23;) (func (param f64 f64) (result (ref 8))))
  (type (;24;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;25;) (struct (field eqref) (field (mut i32))))
  (type (;26;) (sub (struct (field funcref))))
  (type (;27;) (func (param eqref) (result eqref)))
  (type (;28;) (func (param eqref i32) (result eqref)))
  (type (;29;) (func (param eqref) (result (ref 24))))
  (type (;30;) (func (param eqref eqref) (result eqref)))
  (type (;31;) (func (param eqref)))
  (type (;32;) (func (param eqref i32)))
  (type (;33;) (func (param eqref) (result i32)))
  (type (;34;) (func (param eqref i32) (result i32)))
  (type (;35;) (func (param eqref eqref i32) (result eqref)))
  (type (;36;) (func (param eqref eqref) (result (ref 24))))
  (type (;37;) (func (param eqref eqref eqref) (result eqref)))
  (type (;38;) (func (param eqref eqref)))
  (type (;39;) (func (param eqref eqref i32)))
  (type (;40;) (func (param eqref eqref) (result i32)))
  (type (;41;) (func (param eqref eqref i32) (result i32)))
  (type (;42;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;43;) (array (mut v128)))
  (type (;44;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;46;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;47;) (struct (field (mut (ref 43))) (field (mut i32)) (field (mut i32))))
  (type (;48;) (struct (field (mut (ref 43))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 8))
  (func (;0;) (type 10) (result (ref 9))
    struct.new 9
    ref.cast (ref 9)
  )
  (func (;1;) (type 12) (param (ref 8)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 8)
              struct.get 8 0
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
  (func (;2;) (type 13) (param (ref 8)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 8)
              struct.get 8 0
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
  (func (;3;) (type 14) (param (ref 8)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 8)
              struct.get 8 0
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
  (func (;4;) (type 15) (param (ref 8)) (result (ref 8))
    (local eqref eqref)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 8)
              struct.get 8 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 2
            struct.new 8
            local.set 2
            br 3 (;@1;)
          end
          i32.const 1
          struct.new 8
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        struct.new 8
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
    ref.cast (ref 8)
  )
  (func (;5;) (type 16) (param (ref 9) i32 i32) (result (ref 8))
    local.get 1
    local.get 2
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 1
      local.get 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 8
      else
        i32.const 2
        struct.new 8
      end
    end
    ref.cast (ref 8)
  )
  (func (;6;) (type 17) (param (ref 9) i64 i64) (result (ref 8))
    local.get 1
    local.get 2
    i64.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 1
      local.get 2
      i64.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 8
      else
        i32.const 2
        struct.new 8
      end
    end
    ref.cast (ref 8)
  )
  (func (;7;) (type 18) (param (ref 9) f64 f64) (result (ref 8))
    local.get 1
    local.get 2
    f64.lt
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 1
      local.get 2
      f64.eq
      if (result eqref) ;; label = @2
        i32.const 1
        struct.new 8
      else
        i32.const 2
        struct.new 8
      end
    end
    ref.cast (ref 8)
  )
  (func (;8;) (type 20)
    i32.const 1
    i32.const 2
    call 9
    call 1
    v128.const i32x4 0x7373656c 0x00000000 0x00000000 0x00000000
    array.new_fixed 43 1
    i32.const 0
    i32.const 4
    struct.new 44
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
    array.new_fixed 43 1
    i32.const 0
    i32.const 5
    struct.new 44
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
    array.new_fixed 43 1
    i32.const 0
    i32.const 7
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    struct.new 8
    call 4
    call 3
    v128.const i32x4 0x65766572 0x20657372 0x7373656c 0x00000000
    array.new_fixed 43 1
    i32.const 0
    i32.const 12
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    struct.new 8
    call 4
    call 2
    v128.const i32x4 0x65766572 0x20657372 0x61757165 0x0000006c
    array.new_fixed 43 1
    i32.const 0
    i32.const 13
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    struct.new 8
    call 4
    call 1
    v128.const i32x4 0x65766572 0x20657372 0x61657267 0x00726574
    array.new_fixed 43 1
    i32.const 0
    i32.const 15
    struct.new 44
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
    array.new_fixed 43 1
    i32.const 0
    i32.const 14
    struct.new 44
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
    array.new_fixed 43 1
    i32.const 0
    i32.const 14
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;9;) (type 21) (param i32 i32) (result (ref 8))
    call 0
    local.get 0
    local.get 1
    call 5
    ref.cast (ref 8)
  )
  (func (;10;) (type 22) (param i64 i64) (result (ref 8))
    call 0
    local.get 0
    local.get 1
    call 6
    ref.cast (ref 8)
  )
  (func (;11;) (type 23) (param f64 f64) (result (ref 8))
    call 0
    local.get 0
    local.get 1
    call 7
    ref.cast (ref 8)
  )
)
