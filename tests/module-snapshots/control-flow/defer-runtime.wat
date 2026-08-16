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
  (type (;9;) (sub (struct (field funcref))))
  (type (;10;) (func (param eqref) (result eqref)))
  (type (;11;) (func (param eqref i32) (result eqref)))
  (type (;12;) (func (param eqref) (result (ref 8))))
  (type (;13;) (func (param eqref eqref) (result eqref)))
  (type (;14;) (func (param eqref)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref) (result i32)))
  (type (;17;) (func (param eqref i32) (result i32)))
  (type (;18;) (func (param eqref eqref i32) (result eqref)))
  (type (;19;) (func (param eqref eqref) (result (ref 8))))
  (type (;20;) (func (param eqref eqref eqref) (result eqref)))
  (type (;21;) (func (param eqref eqref)))
  (type (;22;) (func (param eqref eqref i32)))
  (type (;23;) (func (param eqref eqref) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result i32)))
  (type (;25;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;26;) (struct (field (mut i32))))
  (type (;27;) (func))
  (type (;28;) (func (param (ref 8) i32)))
  (type (;29;) (func (result (ref 8))))
  (type (;30;) (func (param (ref 8)) (result i32)))
  (type (;31;) (func (param (ref 8)) (result i32)))
  (type (;32;) (func (param (ref 8)) (result i32)))
  (type (;33;) (func (param (ref 8)) (result i32)))
  (type (;34;) (func (param (ref 8)) (result i32)))
  (type (;35;) (func (param (ref 8)) (result i32)))
  (type (;36;) (func (param (ref 8))))
  (type (;37;) (func (param (ref 8))))
  (type (;38;) (array (mut v128)))
  (type (;39;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;40;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;41;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;42;) (struct (field (mut (ref 38))) (field (mut i32)) (field (mut i32))))
  (type (;43;) (struct (field (mut (ref 38))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 10))
  (func (;0;) (type 28) (param (ref 8) i32)
    (local eqref i32 eqref i32)
    local.get 0
    i32.const 0
    local.set 3
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 10
    i32.mul
    local.get 1
    i32.add
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 3
    local.get 5
    array.set 0
  )
  (func (;1;) (type 29) (result (ref 8))
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
  (func (;2;) (type 30) (param (ref 8)) (result i32)
    (local i32)
    local.get 0
    ref.cast (ref 8)
    i32.const 1
    call 0
    i32.const 7
    local.set 1
    local.get 0
    call 12
    local.get 0
    call 11
    local.get 1
  )
  (func (;3;) (type 31) (param (ref 8)) (result i32)
    local.get 0
    ref.cast (ref 8)
    i32.const 4
    call 0
    i32.const 9
  )
  (func (;4;) (type 32) (param (ref 8)) (result i32)
    (local i32)
    local.get 0
    ref.cast (ref 8)
    call 3
    local.set 1
    local.get 0
    call 13
    local.get 1
    return
  )
  (func (;5;) (type 33) (param (ref 8)) (result i32)
    local.get 0
    ref.cast (ref 8)
    i32.const 7
    call 0
    i32.const 11
  )
  (func (;6;) (type 34) (param (ref 8)) (result i32)
    (local i32 i32 i32 i32)
    i32.const 0
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 1
            local.get 0
            ref.cast (ref 8)
            call 5
            local.set 2
            local.get 0
            call 14
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
  (func (;7;) (type 35) (param (ref 8)) (result i32)
    (local i32 i32 i32 i32 i32)
    i32.const 0
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 1
            local.get 1
            i32.const 2
            i32.lt_u
            if ;; label = @5
              local.get 0
              ref.cast (ref 8)
              i32.const 1
              call 0
              local.get 1
              i32.const 1
              i32.add
              local.set 2
              local.get 0
              call 15
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
  (func (;8;) (type 36) (param (ref 8))
    (local i32 i32 i32 i32)
    i32.const 0
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 1
            local.get 1
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
    local.set 2
    local.get 0
    ref.cast (ref 8)
    i32.const 8
    call 0
    local.get 0
    call 16
  )
  (func (;9;) (type 37) (param (ref 8))
    (local eqref)
    i32.const 1
    struct.new 26
    local.set 1
    local.get 1
    ref.cast (ref 26)
    i32.const 4
    struct.set 26 0
    local.get 0
    local.get 1
    call 17
  )
  (func (;10;) (type 27)
    (local eqref eqref i32 eqref)
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 8)
    call 2
    i32.const 7
    i32.eq
    v128.const i32x4 0x6c6c6166 0x6f726874 0x20686775 0x75736572
    v128.const i32x4 0x0000746c 0x00000000 0x00000000 0x00000000
    array.new_fixed 38 2
    i32.const 0
    i32.const 18
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
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
    i32.const 132
    i32.eq
    v128.const i32x4 0x6c6c6166 0x6f726874 0x20686775 0x4f46494c
    array.new_fixed 38 1
    i32.const 0
    i32.const 16
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 8)
    call 4
    i32.const 9
    i32.eq
    v128.const i32x4 0x75746572 0x72206e72 0x6c757365 0x00000074
    array.new_fixed 38 1
    i32.const 0
    i32.const 13
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
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
    i32.const 45
    i32.eq
    v128.const i32x4 0x75746572 0x65206e72 0x756c6176 0x73657461
    v128.const i32x4 0x6c617620 0x66206575 0x74737269 0x00000000
    array.new_fixed 38 2
    i32.const 0
    i32.const 28
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 8)
    call 6
    i32.const 11
    i32.eq
    v128.const i32x4 0x61657262 0x6572206b 0x746c7573 0x00000000
    array.new_fixed 38 1
    i32.const 0
    i32.const 12
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
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
    i32.const 76
    i32.eq
    v128.const i32x4 0x61657262 0x6c63206b 0x756e6165 0x00000070
    array.new_fixed 38 1
    i32.const 0
    i32.const 13
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 8)
    call 7
    i32.const 2
    i32.eq
    v128.const i32x4 0x746e6f63 0x65756e69 0x73657220 0x00746c75
    array.new_fixed 38 1
    i32.const 0
    i32.const 15
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
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
    i32.const 1212
    i32.eq
    v128.const i32x4 0x746e6f63 0x65756e69 0x656c6320 0x70756e61
    array.new_fixed 38 1
    i32.const 0
    i32.const 16
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 8)
    call 8
    local.get 0
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
    i32.const 89
    i32.eq
    v128.const i32x4 0x7473656e 0x6c206465 0x20706f6f 0x73656f64
    v128.const i32x4 0x746f6e20 0x69786520 0x63732074 0x0065706f
    array.new_fixed 38 2
    i32.const 0
    i32.const 31
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 8)
    call 9
    local.get 0
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
    i32.const 4
    i32.eq
    v128.const i32x4 0x65666564 0x626f2072 0x76726573 0x6c207365
    v128.const i32x4 0x73657461 0x756d2074 0x6c626174 0x61632065
    v128.const i32x4 0x72757470 0x00000065 0x00000000 0x00000000
    array.new_fixed 38 3
    i32.const 0
    i32.const 37
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;11;) (type 14) (param eqref)
    local.get 0
    ref.cast (ref 8)
    i32.const 2
    call 0
  )
  (func (;12;) (type 14) (param eqref)
    local.get 0
    ref.cast (ref 8)
    i32.const 3
    call 0
  )
  (func (;13;) (type 14) (param eqref)
    local.get 0
    ref.cast (ref 8)
    i32.const 5
    call 0
  )
  (func (;14;) (type 14) (param eqref)
    local.get 0
    ref.cast (ref 8)
    i32.const 6
    call 0
  )
  (func (;15;) (type 14) (param eqref)
    local.get 0
    ref.cast (ref 8)
    i32.const 2
    call 0
  )
  (func (;16;) (type 14) (param eqref)
    local.get 0
    ref.cast (ref 8)
    i32.const 9
    call 0
  )
  (func (;17;) (type 21) (param eqref eqref)
    local.get 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 26)
    struct.get 26 0
    call 0
  )
)
