(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field eqref) (field (mut i32))))
  (type (;10;) (sub (struct (field funcref))))
  (type (;11;) (func (param eqref) (result eqref)))
  (type (;12;) (func (param eqref i32) (result eqref)))
  (type (;13;) (func (param eqref) (result (ref 8))))
  (type (;14;) (func (param eqref eqref) (result eqref)))
  (type (;15;) (func (param eqref)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func (param eqref eqref i32) (result eqref)))
  (type (;20;) (func (param eqref eqref) (result (ref 8))))
  (type (;21;) (func (param eqref eqref eqref) (result eqref)))
  (type (;22;) (func (param eqref eqref)))
  (type (;23;) (func (param eqref eqref i32)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (param eqref eqref i32) (result i32)))
  (type (;26;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;27;) (struct (field i32)))
  (type (;28;) (func))
  (type (;29;) (func (result (ref 8))))
  (type (;30;) (func (param i32)))
  (type (;31;) (func (result i32)))
  (type (;32;) (func (param (ref 27))))
  (type (;33;) (func (param i32) (result (ref 27))))
  (type (;34;) (func (result i32)))
  (type (;35;) (func (result i32)))
  (type (;36;) (func (param (ref 27)) (result i32)))
  (type (;37;) (func (result i32)))
  (type (;38;) (func (result i32)))
  (type (;39;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;40;) (struct))
  (type (;41;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;42;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;43;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;44;) (func))
  (type (;45;) (array (mut v128)))
  (type (;46;) (struct (field (ref 45)) (field i32) (field i32)))
  (type (;47;) (struct (field (ref 45)) (field i32) (field i32)))
  (type (;48;) (struct (field (ref 45)) (field i32) (field i32)))
  (type (;49;) (struct (field (mut (ref 45))) (field (mut i32)) (field (mut i32))))
  (type (;50;) (struct (field (mut (ref 45))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null none)
  (export "main" (func 13))
  (export "__dew_init" (func 21))
  (func (;0;) (type 29) (result (ref 8))
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 2
    local.get 2
    array.new_default 0
    i32.const 0
    local.get 2
    struct.new 8
    local.set 0
    local.get 0
    i32.const 0
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 8)
        struct.get 8 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      struct.set 8 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 8 2
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.add
    struct.set 8 1
    local.get 0
    ref.cast (ref 8)
  )
  (func (;1;) (type 28)
    (local eqref i32 eqref i32)
    global.get 0
    ref.cast (ref 8)
    i32.const 0
    local.set 1
    i32.const 0
    local.set 3
    local.set 0
    local.get 1
    local.get 0
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 1
    local.get 3
    array.set 0
  )
  (func (;2;) (type 30) (param i32)
    (local eqref i32 eqref i32)
    global.get 0
    ref.cast (ref 8)
    i32.const 0
    local.set 2
    global.get 0
    ref.cast (ref 8)
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 10
    i32.mul
    local.get 0
    i32.add
    local.set 4
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 2
    local.get 4
    array.set 0
  )
  (func (;3;) (type 31) (result i32)
    (local eqref i32 eqref)
    global.get 0
    ref.cast (ref 8)
    i32.const 0
    local.set 1
    local.set 0
    local.get 1
    local.get 0
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 1
    array.get 0
  )
  (func (;4;) (type 32) (param (ref 27))
    local.get 0
    ref.cast (ref 27)
    struct.get 27 0
    call 2
  )
  (func (;5;) (type 33) (param i32) (result (ref 27))
    i32.const 1
    call 2
    local.get 0
    struct.new 27
    ref.cast (ref 27)
  )
  (func (;6;) (type 28)
    (local (ref 27))
    i32.const 3
    call 5
    local.set 0
    local.get 0
    ref.cast (ref 27)
    struct.get 27 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x6e697375 0x69622067 0x6e69646e 0x00000067
    array.new_fixed 45 1
    i32.const 0
    i32.const 13
    struct.new 46
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
  (func (;7;) (type 34) (result i32)
    i32.const 4
    call 2
    i32.const 9
  )
  (func (;8;) (type 35) (result i32)
    (local (ref 27) i32)
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
  (func (;9;) (type 36) (param (ref 27)) (result i32)
    i32.const 7
    call 2
    local.get 0
    ref.cast (ref 27)
    struct.get 27 0
    i32.const 5
    i32.add
  )
  (func (;10;) (type 37) (result i32)
    (local i32 (ref 27) i32 i32 i32)
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
  (func (;11;) (type 38) (result i32)
    (local i32 (ref 27) i32 i32 i32 i32)
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
  (func (;12;) (type 28)
    (local (ref 27) (ref 27))
    i32.const 4
    call 5
    local.set 0
    i32.const 5
    call 5
    local.set 1
    local.get 0
    ref.cast (ref 27)
    struct.get 27 0
    local.get 1
    ref.cast (ref 27)
    struct.get 27 0
    i32.add
    i32.const 9
    i32.eq
    v128.const i32x4 0x6e697375 0x61762067 0x7365756c 0x00000000
    array.new_fixed 45 1
    i32.const 0
    i32.const 12
    struct.new 46
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
  (func (;13;) (type 28)
    call 1
    call 6
    call 3
    i32.const 123
    i32.eq
    v128.const i32x4 0x6e697375 0x61662067 0x68746c6c 0x67756f72
    v128.const i32x4 0x00000068 0x00000000 0x00000000 0x00000000
    array.new_fixed 45 2
    i32.const 0
    i32.const 17
    struct.new 46
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
    array.new_fixed 45 2
    i32.const 0
    i32.const 18
    struct.new 46
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
    array.new_fixed 45 2
    i32.const 0
    i32.const 20
    struct.new 46
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
    array.new_fixed 45 2
    i32.const 0
    i32.const 17
    struct.new 46
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
    array.new_fixed 45 2
    i32.const 0
    i32.const 19
    struct.new 46
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
    array.new_fixed 45 2
    i32.const 0
    i32.const 20
    struct.new 46
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
    array.new_fixed 45 2
    i32.const 0
    i32.const 22
    struct.new 46
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
    array.new_fixed 45 2
    i32.const 0
    i32.const 18
    struct.new 46
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;14;) (type 15) (param eqref)
    local.get 0
    ref.cast (ref 27)
    call 4
  )
  (func (;15;) (type 15) (param eqref)
    local.get 0
    ref.cast (ref 27)
    call 4
  )
  (func (;16;) (type 15) (param eqref)
    local.get 0
    ref.cast (ref 27)
    call 4
  )
  (func (;17;) (type 15) (param eqref)
    local.get 0
    ref.cast (ref 27)
    call 4
  )
  (func (;18;) (type 15) (param eqref)
    local.get 0
    ref.cast (ref 27)
    call 4
  )
  (func (;19;) (type 15) (param eqref)
    local.get 0
    ref.cast (ref 27)
    call 4
  )
  (func (;20;) (type 44)
    call 0
    global.set 0
  )
  (func (;21;) (type 44)
    call 20
  )
)
