(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (sub (struct (field i32))))
  (type (;3;) (sub final 2 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;4;) (sub final 2 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;5;) (func (param eqref)))
  (type (;6;) (func (param i32 eqref)))
  (type (;7;) (func (param i32 eqref)))
  (type (;8;) (func (param eqref eqref eqref)))
  (type (;9;) (func (param eqref eqref eqref)))
  (type (;10;) (func (param eqref eqref eqref)))
  (type (;11;) (func (param eqref eqref eqref)))
  (type (;12;) (func (param eqref eqref eqref)))
  (type (;13;) (func (param eqref eqref eqref)))
  (type (;14;) (func (param (ref 0) eqref)))
  (type (;15;) (func (param (ref 0) eqref)))
  (type (;16;) (func (param (ref 2) eqref)))
  (type (;17;) (func (param (ref 2) eqref)))
  (type (;18;) (func (param i32 i32 eqref)))
  (type (;19;) (func (param i32 i32 eqref)))
  (type (;20;) (func (param i32 i32 eqref)))
  (type (;21;) (func (param i32 i32 eqref)))
  (type (;22;) (func (param i32 i32 eqref)))
  (type (;23;) (func (param i32 i32 eqref)))
  (type (;24;) (func (param (ref 0) eqref)))
  (type (;25;) (func (param (ref 0) eqref)))
  (type (;26;) (func (param (ref 2) eqref)))
  (type (;27;) (func (param (ref 2) eqref)))
  (type (;28;) (func (result (ref 0))))
  (type (;29;) (func (param i32) (result (ref 2))))
  (type (;30;) (func (param i32) (result (ref 2))))
  (type (;31;) (func (result i32)))
  (type (;32;) (array (mut v128)))
  (type (;33;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;34;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;35;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;36;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (type (;37;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 16))
  (func (;0;) (type 5) (param eqref)
    i32.const 0
    local.get 0
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 6) (param i32 eqref)
    local.get 0
    local.get 1
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 7) (param i32 eqref)
    local.get 0
    i32.eqz
    local.get 1
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;3;) (type 18) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.eq
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;4;) (type 19) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.eq
    i32.eqz
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;5;) (type 20) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.lt_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;6;) (type 21) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.le_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;7;) (type 22) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.gt_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;8;) (type 23) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.ge_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;9;) (type 24) (param (ref 0) eqref)
    (local eqref)
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
          local.get 1
          call 0
          br 2 (;@1;)
        end
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;10;) (type 25) (param (ref 0) eqref)
    (local eqref)
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
          br 2 (;@1;)
        end
        local.get 1
        call 0
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;11;) (type 26) (param (ref 2) eqref)
    (local eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 2)
            struct.get 2 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        local.get 1
        call 0
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;12;) (type 27) (param (ref 2) eqref)
    (local eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 2)
            struct.get 2 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          call 0
          br 2 (;@1;)
        end
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;13;) (type 28) (result (ref 0))
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;14;) (type 29) (param i32) (result (ref 2))
    i32.const 0
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 3
    ref.cast (ref 2)
  )
  (func (;15;) (type 30) (param i32) (result (ref 2))
    i32.const 1
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    ref.cast (ref 2)
  )
  (func (;16;) (type 31) (result i32)
    i32.const 1
    v128.const i32x4 0x65757274 0x6c656820 0x00726570 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    call 1
    i32.const 0
    v128.const i32x4 0x736c6166 0x65682065 0x7265706c 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 12
    struct.new 33
    call 2
    i32.const 42
    i32.const 42
    v128.const i32x4 0x61757165 0x6568206c 0x7265706c 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 12
    struct.new 33
    call 3
    i32.const 41
    i32.const 42
    v128.const i32x4 0x20746f6e 0x61757165 0x6568206c 0x7265706c
    array.new_fixed 32 1
    i32.const 0
    i32.const 16
    struct.new 33
    call 4
    i32.const 1
    i32.const 2
    v128.const i32x4 0x7373656c 0x6c656820 0x00726570 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    call 5
    i32.const 2
    i32.const 2
    v128.const i32x4 0x2065746c 0x706c6568 0x00007265 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 33
    call 6
    i32.const 3
    i32.const 2
    v128.const i32x4 0x61657267 0x20726574 0x706c6568 0x00007265
    array.new_fixed 32 1
    i32.const 0
    i32.const 14
    struct.new 33
    call 7
    i32.const 3
    i32.const 3
    v128.const i32x4 0x20657467 0x706c6568 0x00007265 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 33
    call 8
    i32.const 1
    i32.const 7
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    v128.const i32x4 0x656d6f73 0x6c656820 0x00726570 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    call 9
    call 13
    v128.const i32x4 0x656e6f6e 0x6c656820 0x00726570 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    call 10
    i32.const 7
    call 14
    v128.const i32x4 0x68206b6f 0x65706c65 0x00000072 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 9
    struct.new 33
    call 11
    i32.const 9
    call 15
    v128.const i32x4 0x20727265 0x706c6568 0x00007265 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 33
    call 12
    i32.const 1
  )
)
