(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;1;) (struct (field (mut i32))))
  (type (;2;) (func))
  (type (;3;) (func (param eqref)))
  (type (;4;) (func (param eqref eqref)))
  (type (;5;) (func (param (ref 0) i32)))
  (type (;6;) (func (result (ref 0))))
  (type (;7;) (func (param (ref 0)) (result i32)))
  (type (;8;) (func (param (ref 0)) (result i32)))
  (type (;9;) (func (param (ref 0)) (result i32)))
  (type (;10;) (func (param (ref 0)) (result i32)))
  (type (;11;) (func (param (ref 0)) (result i32)))
  (type (;12;) (func (param (ref 0)) (result i32)))
  (type (;13;) (func (param (ref 0))))
  (type (;14;) (func (param (ref 0))))
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
  (export "main" (func 10))
  (func (;0;) (type 5) (param (ref 0) i32)
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
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 3
    array.get 21
    i32.const 10
    i32.mul
    local.get 1
    i32.add
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 3
    local.get 5
    array.set 21
  )
  (func (;1;) (type 6) (result (ref 0))
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
      i32.const 0
      local.set 2
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 3
          ref.cast (ref 21)
          local.get 2
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 21)
          local.get 2
          array.get 21
          array.set 21
          local.get 2
          i32.const 1
          i32.add
          local.set 2
          br 0 (;@3;)
        end
      end
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
  (func (;2;) (type 7) (param (ref 0)) (result i32)
    (local i32)
    local.get 0
    ref.cast (ref 0)
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
  (func (;3;) (type 8) (param (ref 0)) (result i32)
    local.get 0
    ref.cast (ref 0)
    i32.const 4
    call 0
    i32.const 9
  )
  (func (;4;) (type 9) (param (ref 0)) (result i32)
    (local i32)
    local.get 0
    ref.cast (ref 0)
    call 3
    local.set 1
    local.get 0
    call 13
    local.get 1
    return
  )
  (func (;5;) (type 10) (param (ref 0)) (result i32)
    local.get 0
    ref.cast (ref 0)
    i32.const 7
    call 0
    i32.const 11
  )
  (func (;6;) (type 11) (param (ref 0)) (result i32)
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
            ref.cast (ref 0)
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
  (func (;7;) (type 12) (param (ref 0)) (result i32)
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
              ref.cast (ref 0)
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
  (func (;8;) (type 13) (param (ref 0))
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
    ref.cast (ref 0)
    i32.const 8
    call 0
    local.get 0
    call 16
  )
  (func (;9;) (type 14) (param (ref 0))
    (local eqref)
    i32.const 1
    struct.new 1
    local.set 1
    local.get 1
    ref.cast (ref 1)
    i32.const 4
    struct.set 1 0
    local.get 0
    local.get 1
    call 17
  )
  (func (;10;) (type 2)
    (local eqref eqref eqref eqref eqref eqref eqref i32 eqref)
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 0)
    call 2
    i32.const 7
    i32.eq
    v128.const i32x4 0x6c6c6166 0x6f726874 0x20686775 0x75736572
    v128.const i32x4 0x0000746c 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 18
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 7
    local.set 6
    local.get 7
    local.get 6
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 7
    array.get 21
    i32.const 132
    i32.eq
    v128.const i32x4 0x6c6c6166 0x6f726874 0x20686775 0x4f46494c
    array.new_fixed 15 1
    i32.const 0
    i32.const 16
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 1
    local.get 1
    ref.cast (ref 0)
    call 4
    i32.const 9
    i32.eq
    v128.const i32x4 0x75746572 0x72206e72 0x6c757365 0x00000074
    array.new_fixed 15 1
    i32.const 0
    i32.const 13
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 7
    local.set 6
    local.get 7
    local.get 6
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 7
    array.get 21
    i32.const 45
    i32.eq
    v128.const i32x4 0x75746572 0x65206e72 0x756c6176 0x73657461
    v128.const i32x4 0x6c617620 0x66206575 0x74737269 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 28
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    call 6
    i32.const 11
    i32.eq
    v128.const i32x4 0x61657262 0x6572206b 0x746c7573 0x00000000
    array.new_fixed 15 1
    i32.const 0
    i32.const 12
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 0
    local.set 7
    local.set 6
    local.get 7
    local.get 6
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 7
    array.get 21
    i32.const 76
    i32.eq
    v128.const i32x4 0x61657262 0x6c63206b 0x756e6165 0x00000070
    array.new_fixed 15 1
    i32.const 0
    i32.const 13
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 3
    local.get 3
    ref.cast (ref 0)
    call 7
    i32.const 2
    i32.eq
    v128.const i32x4 0x746e6f63 0x65756e69 0x73657220 0x00746c75
    array.new_fixed 15 1
    i32.const 0
    i32.const 15
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    i32.const 0
    local.set 7
    local.set 6
    local.get 7
    local.get 6
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 7
    array.get 21
    i32.const 1212
    i32.eq
    v128.const i32x4 0x746e6f63 0x65756e69 0x656c6320 0x70756e61
    array.new_fixed 15 1
    i32.const 0
    i32.const 16
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 4
    local.get 4
    ref.cast (ref 0)
    call 8
    local.get 4
    i32.const 0
    local.set 7
    local.set 6
    local.get 7
    local.get 6
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 7
    array.get 21
    i32.const 89
    i32.eq
    v128.const i32x4 0x7473656e 0x6c206465 0x20706f6f 0x73656f64
    v128.const i32x4 0x746f6e20 0x69786520 0x63732074 0x0065706f
    array.new_fixed 15 2
    i32.const 0
    i32.const 31
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 5
    local.get 5
    ref.cast (ref 0)
    call 9
    local.get 5
    i32.const 0
    local.set 7
    local.set 6
    local.get 7
    local.get 6
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 21)
    local.get 7
    array.get 21
    i32.const 4
    i32.eq
    v128.const i32x4 0x65666564 0x626f2072 0x76726573 0x6c207365
    v128.const i32x4 0x73657461 0x756d2074 0x6c626174 0x61632065
    v128.const i32x4 0x72757470 0x00000065 0x00000000 0x00000000
    array.new_fixed 15 3
    i32.const 0
    i32.const 37
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;11;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    call 0
  )
  (func (;12;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 0)
    i32.const 3
    call 0
  )
  (func (;13;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 0)
    i32.const 5
    call 0
  )
  (func (;14;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 0)
    i32.const 6
    call 0
  )
  (func (;15;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    call 0
  )
  (func (;16;) (type 3) (param eqref)
    local.get 0
    ref.cast (ref 0)
    i32.const 9
    call 0
  )
  (func (;17;) (type 4) (param eqref eqref)
    local.get 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    call 0
  )
)
