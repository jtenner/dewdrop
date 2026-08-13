(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;1;) (struct (field i32)))
  (type (;2;) (func))
  (type (;3;) (func (param eqref)))
  (type (;4;) (func (result (ref 0))))
  (type (;5;) (func (param i32)))
  (type (;6;) (func (result i32)))
  (type (;7;) (func (param (ref 1))))
  (type (;8;) (func (param i32) (result (ref 1))))
  (type (;9;) (func (result i32)))
  (type (;10;) (func (result i32)))
  (type (;11;) (func (param (ref 1)) (result i32)))
  (type (;12;) (func (result i32)))
  (type (;13;) (func (result i32)))
  (type (;14;) (func))
  (type (;15;) (array (mut v128)))
  (type (;16;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;17;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;19;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
  (type (;20;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
  (type (;21;) (array (mut i32)))
  (type (;22;) (array (mut i64)))
  (type (;23;) (array (mut f32)))
  (type (;24;) (array (mut f64)))
  (type (;25;) (array (mut v128)))
  (type (;26;) (array (mut eqref)))
  (global (;0;) (mut eqref) ref.null none)
  (export "main" (func 13))
  (export "__dew_init" (func 21))
  (func (;0;) (type 4) (result (ref 0))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 2
    local.get 2
    array.new_default 21
    i32.const 0
    local.get 2
    struct.new 0
    local.set 0
    local.get 0
    i32.const 0
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 21
      local.set 3
      local.get 3
      ref.cast (ref 21)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 21)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 21 21
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 21)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 4
    array.set 21
    local.get 1
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 2)
    (local eqref i32 eqref i32)
    global.get 0
    ref.cast (ref 0)
    i32.const 0
    local.set 1
    i32.const 0
    local.set 3
    local.set 0
    local.get 1
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 1
    local.get 3
    array.set 21
  )
  (func (;2;) (type 5) (param i32)
    (local eqref i32 eqref i32)
    global.get 0
    ref.cast (ref 0)
    i32.const 0
    local.set 2
    global.get 0
    ref.cast (ref 0)
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 2
    array.get 21
    i32.const 10
    i32.mul
    local.get 0
    i32.add
    local.set 4
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 2
    local.get 4
    array.set 21
  )
  (func (;3;) (type 6) (result i32)
    (local eqref i32 eqref)
    global.get 0
    ref.cast (ref 0)
    i32.const 0
    local.set 1
    local.set 0
    local.get 1
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 1
    array.get 21
  )
  (func (;4;) (type 7) (param (ref 1))
    local.get 0
    struct.get 1 0
    call 2
  )
  (func (;5;) (type 8) (param i32) (result (ref 1))
    i32.const 1
    call 2
    local.get 0
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;6;) (type 2)
    (local (ref 1))
    i32.const 3
    call 5
    local.set 0
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x6e697375 0x69622067 0x6e69646e 0x00000067
    array.new_fixed 15 1
    i32.const 0
    i32.const 13
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    call 2
    local.get 0
    call 14
  )
  (func (;7;) (type 9) (result i32)
    i32.const 4
    call 2
    i32.const 9
  )
  (func (;8;) (type 10) (result i32)
    (local (ref 1) i32)
    i32.const 5
    call 5
    local.set 0
    call 7
    local.set 1
    local.get 0
    call 15
    local.get 1
    return
  )
  (func (;9;) (type 11) (param (ref 1)) (result i32)
    i32.const 7
    call 2
    local.get 0
    struct.get 1 0
    i32.const 5
    i32.add
  )
  (func (;10;) (type 12) (result i32)
    (local i32 (ref 1) i32 i32 i32)
    i32.const 0
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 0
            i32.const 6
            call 5
            local.set 1
            local.get 1
            call 9
            local.set 2
            local.get 1
            call 16
            local.get 2
            local.set 4
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 4
  )
  (func (;11;) (type 13) (result i32)
    (local i32 (ref 1) i32 i32 i32 i32)
    i32.const 0
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 0
            local.get 0
            i32.const 2
            i32.lt_u
            if ;; label = @5
              i32.const 2
              call 5
              local.set 1
              i32.const 8
              call 2
              local.get 0
              i32.const 1
              i32.add
              local.set 2
              local.get 1
              call 17
              local.get 2
              local.set 4
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 3
            local.get 3
            local.set 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 5
  )
  (func (;12;) (type 2)
    (local (ref 1) (ref 1))
    i32.const 4
    call 5
    local.set 0
    i32.const 5
    call 5
    local.set 1
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    i32.add
    i32.const 9
    i32.eq
    v128.const i32x4 0x6e697375 0x61762067 0x7365756c 0x00000000
    array.new_fixed 15 1
    i32.const 0
    i32.const 12
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    call 2
    local.get 1
    call 19
    local.get 0
    call 18
  )
  (func (;13;) (type 2)
    call 1
    call 6
    call 3
    i32.const 123
    i32.eq
    v128.const i32x4 0x6e697375 0x61662067 0x68746c6c 0x67756f72
    v128.const i32x4 0x00000068 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 17
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    call 8
    i32.const 9
    i32.eq
    v128.const i32x4 0x6e697375 0x65722067 0x6e727574 0x6c617620
    v128.const i32x4 0x00006575 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 18
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 3
    i32.const 145
    i32.eq
    v128.const i32x4 0x6e697375 0x65722067 0x6e727574 0x656c6320
    v128.const i32x4 0x70756e61 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 20
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    call 10
    i32.const 11
    i32.eq
    v128.const i32x4 0x6e697375 0x72622067 0x206b6165 0x756c6176
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 17
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 3
    i32.const 176
    i32.eq
    v128.const i32x4 0x6e697375 0x72622067 0x206b6165 0x61656c63
    v128.const i32x4 0x0070756e 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 19
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    call 11
    i32.const 2
    i32.eq
    v128.const i32x4 0x6e697375 0x6f632067 0x6e69746e 0x76206575
    v128.const i32x4 0x65756c61 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 20
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 3
    i32.const 182182
    i32.eq
    v128.const i32x4 0x6e697375 0x6f632067 0x6e69746e 0x63206575
    v128.const i32x4 0x6e61656c 0x00007075 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 22
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    call 12
    call 3
    i32.const 11354
    i32.eq
    v128.const i32x4 0x6e697375 0x494c2067 0x63204f46 0x6e61656c
    v128.const i32x4 0x00007075 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 18
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;14;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 1)
    call 4
  )
  (func (;15;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 1)
    call 4
  )
  (func (;16;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 1)
    call 4
  )
  (func (;17;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 1)
    call 4
  )
  (func (;18;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 1)
    call 4
  )
  (func (;19;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 1)
    call 4
  )
  (func (;20;) (type 14)
    call 0
    global.set 0
  )
  (func (;21;) (type 14)
    call 20
  )
)
