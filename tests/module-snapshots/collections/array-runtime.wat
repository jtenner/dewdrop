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
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;11;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field eqref) (field (mut i32))))
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref) (result (ref 11))))
  (type (;17;) (func (param eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result (ref 11))))
  (type (;24;) (func (param eqref eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref)))
  (type (;26;) (func (param eqref eqref i32)))
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;30;) (func (param (ref 11)) (result i32)))
  (type (;31;) (func (param (ref 11)) (result i32)))
  (type (;32;) (func (param (ref 11)) (result i32)))
  (type (;33;) (func (param eqref) (result i32)))
  (type (;34;) (func (param eqref) (result i32)))
  (type (;35;) (func (result (ref 11))))
  (type (;36;) (func (result (ref 11))))
  (type (;37;) (func (result (ref 11))))
  (type (;38;) (func (result (ref 11))))
  (type (;39;) (func (result (ref 11))))
  (type (;40;) (func (result (ref 11))))
  (type (;41;) (func (param v128) (result i32)))
  (type (;42;) (func (param eqref) (result i32)))
  (type (;43;) (func (param (ref 12) i32) (result i32)))
  (type (;44;) (func))
  (type (;45;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;46;) (struct))
  (type (;47;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;48;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;49;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;50;) (array (mut v128)))
  (type (;51;) (struct (field (ref 50)) (field i32) (field i32)))
  (type (;52;) (struct (field (ref 50)) (field i32) (field i32)))
  (type (;53;) (struct (field (ref 50)) (field i32) (field i32)))
  (type (;54;) (struct (field (mut (ref 50))) (field (mut i32)) (field (mut i32))))
  (type (;55;) (struct (field (mut (ref 50))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 13))
  (func (;0;) (type 31) (param (ref 11)) (result i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
  )
  (func (;1;) (type 32) (param (ref 11)) (result i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
  )
  (func (;2;) (type 33) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 51)
    struct.get 51 2
  )
  (func (;3;) (type 34) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;4;) (type 35) (result (ref 11))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;5;) (type 36) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 1
    local.set 1
    local.get 1
    array.new_default 1
    i32.const 0
    local.get 1
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;6;) (type 37) (result (ref 11))
    i32.const 0
    array.new_default 2
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;7;) (type 38) (result (ref 11))
    i32.const 0
    array.new_default 3
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;8;) (type 39) (result (ref 11))
    i32.const 0
    array.new_default 4
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;9;) (type 40) (result (ref 11))
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;10;) (type 41) (param v128) (result i32)
    local.get 0
    i32x4.extract_lane 2
  )
  (func (;11;) (type 42) (param eqref) (result i32)
    local.get 0
    call 3
    i32.const 6
    i32.eq
  )
  (func (;12;) (type 43) (param (ref 12) i32) (result i32)
    (local i32 eqref i32 eqref eqref i32 i32 i32)
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 12)
    struct.get 12 1
    local.get 3
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      local.get 3
      ref.cast (ref 12)
      struct.get 12 1
      local.set 4
      local.get 3
      ref.cast (ref 12)
      local.get 4
      i32.const 1
      i32.add
      struct.set 12 1
      i32.const 1
      local.set 8
      local.get 3
      ref.cast (ref 12)
      struct.get 12 0
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      array.get 0
      local.set 9
    else
      i32.const 0
      local.set 8
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 8
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          local.set 7
          br 2 (;@1;)
        end
        local.get 9
        local.set 2
        local.get 0
        ref.cast (ref 12)
        local.get 1
        local.get 2
        i32.add
        call 12
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;13;) (type 44)
    (local eqref i32 i32 eqref eqref eqref eqref eqref eqref eqref eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref i32 eqref i32 i64 i64 f32 f32 f64 f64 v128 v128 eqref eqref eqref eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref)
    call 4
    local.set 0
    v128.const i32x4 0x61727261 0x74732079 0x73747261 0x706d6520
    v128.const i32x4 0x00007974 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 18
    struct.new 51
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x61727261 0x74732079 0x73747261 0x20746120
    v128.const i32x4 0x6f72657a 0x70616320 0x74696361 0x00000079
    array.new_fixed 50 2
    i32.const 0
    i32.const 29
    struct.new 51
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 0
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x61727261 0x74732079 0x73747261 0x676f6c20
    v128.const i32x4 0x6c616369 0x6520796c 0x7974706d 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 28
    struct.new 51
    drop
    local.get 0
    ref.cast (ref 11)
    call 0
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 13
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 13
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 1
    local.set 14
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 14
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 2
    local.set 15
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 15
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 3
    local.set 16
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 16
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 4
    local.set 17
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 17
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 5
    local.set 18
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 18
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 6
    local.set 19
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 19
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 7
    local.set 20
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 20
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 8
    local.set 21
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 21
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 9
    local.set 22
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 22
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    v128.const i32x4 0x61727261 0x65722079 0x74616570 0x67206465
    v128.const i32x4 0x74776f72 0x656c2068 0x6874676e 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 28
    struct.new 51
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 10
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x61727261 0x65642079 0x6d726574 0x73696e69
    v128.const i32x4 0x20636974 0x62756f64 0x676e696c 0x70616320
    v128.const i32x4 0x74696361 0x00000079 0x00000000 0x00000000
    array.new_fixed 50 3
    i32.const 0
    i32.const 37
    struct.new 51
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 16
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 11
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x61727261 0x72672079 0x6874776f 0x65727020
    v128.const i32x4 0x76726573 0x66207365 0x74737269 0x656c6520
    v128.const i32x4 0x746e656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 3
    i32.const 0
    i32.const 36
    struct.new 51
    drop
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 11
    array.get 0
    i32.const 0
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4
    local.set 11
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x61727261 0x72672079 0x6874776f 0x65727020
    v128.const i32x4 0x76726573 0x6d207365 0x6c646469 0x6c652065
    v128.const i32x4 0x6e656d65 0x00000074 0x00000000 0x00000000
    array.new_fixed 50 3
    i32.const 0
    i32.const 37
    struct.new 51
    drop
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 11
    array.get 0
    i32.const 4
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 9
    local.set 11
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x61727261 0x72672079 0x6874776f 0x65727020
    v128.const i32x4 0x76726573 0x66207365 0x6c616e69 0x656c6520
    v128.const i32x4 0x746e656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 3
    i32.const 0
    i32.const 36
    struct.new 51
    drop
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 11
    array.get 0
    i32.const 9
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4
    local.set 11
    i32.const 40
    local.set 44
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 11
    local.get 44
    array.set 0
    i32.const 4
    local.set 11
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x61727261 0x6c612079 0x65736169 0x68732073
    v128.const i32x4 0x20657261 0x65646e69 0x20646578 0x6174756d
    v128.const i32x4 0x6e6f6974 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 3
    i32.const 0
    i32.const 36
    struct.new 51
    drop
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 11
    array.get 0
    i32.const 40
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 9
    local.set 11
    i32.const 90
    local.set 23
    local.get 0
    local.set 10
    v128.const i32x4 0x61727261 0x61732079 0x73206566 0x72207465
    v128.const i32x4 0x726f7065 0x73207374 0x65636375 0x00007373
    array.new_fixed 50 2
    i32.const 0
    i32.const 30
    struct.new 51
    drop
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 11
      local.get 23
      array.set 0
      i32.const 1
    else
      i32.const 0
    end
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 10
    local.set 11
    i32.const 100
    local.set 24
    local.get 0
    local.set 10
    v128.const i32x4 0x61727261 0x61732079 0x73206566 0x72207465
    v128.const i32x4 0x726f7065 0x62207374 0x646e756f 0x61662073
    v128.const i32x4 0x72756c69 0x00000065 0x00000000 0x00000000
    array.new_fixed 50 3
    i32.const 0
    i32.const 37
    struct.new 51
    drop
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 11
      local.get 24
      array.set 0
      i32.const 1
    else
      i32.const 0
    end
    i32.eqz
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 9
    local.set 11
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      i32.const 1
      local.set 45
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 11
      array.get 0
      local.set 46
    else
      i32.const 0
      local.set 45
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 45
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x61727261 0x61732079 0x67206566 0x75207465
          v128.const i32x4 0x7078656e 0x65746365 0x20796c64 0x74706d65
          v128.const i32x4 0x00000079 0x00000000 0x00000000 0x00000000
          array.new_fixed 50 3
          i32.const 0
          i32.const 33
          struct.new 51
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 46
        local.set 1
        local.get 1
        i32.const 90
        i32.eq
        v128.const i32x4 0x61727261 0x61732079 0x67206566 0x76207465
        v128.const i32x4 0x65756c61 0x00000000 0x00000000 0x00000000
        array.new_fixed 50 2
        i32.const 0
        i32.const 20
        struct.new 51
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 10
    local.set 11
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      i32.const 1
      local.set 47
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 11
      array.get 0
      drop
    else
      i32.const 0
      local.set 47
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 47
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x61727261 0x756f2079 0x666f2074 0x756f6220
        v128.const i32x4 0x2073646e 0x78656e75 0x74636570 0x796c6465
        v128.const i32x4 0x65727020 0x746e6573 0x00000000 0x00000000
        array.new_fixed 50 3
        i32.const 0
        i32.const 40
        struct.new 51
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 48
    else
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 11
      array.get 0
      local.set 27
      local.get 10
      ref.cast (ref 11)
      local.get 11
      struct.set 11 1
      i32.const 1
      local.set 48
      local.get 27
      local.set 49
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 48
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x61727261 0x6f702079 0x6e752070 0x65707865
          v128.const i32x4 0x64657463 0x6520796c 0x7974706d 0x00000000
          array.new_fixed 50 2
          i32.const 0
          i32.const 28
          struct.new 51
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 49
        local.set 2
        local.get 2
        i32.const 90
        i32.eq
        v128.const i32x4 0x61727261 0x6f702079 0x65722070 0x6e727574
        v128.const i32x4 0x69662073 0x206c616e 0x756c6176 0x00000065
        array.new_fixed 50 2
        i32.const 0
        i32.const 29
        struct.new 51
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 9
    i32.eq
    v128.const i32x4 0x61727261 0x6f702079 0x65642070 0x6d657263
    v128.const i32x4 0x73746e65 0x6e656c20 0x00687467 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 27
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 16
    i32.eq
    v128.const i32x4 0x61727261 0x6f702079 0x72702070 0x72657365
    v128.const i32x4 0x20736576 0x61706163 0x79746963 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 28
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 3
    local.get 3
    i32.const 0
    struct.new 12
    ref.cast (ref 12)
    i32.const 0
    call 12
    i32.const 72
    i32.eq
    v128.const i32x4 0x61727261 0x74692079 0x74617265 0x7620726f
    v128.const i32x4 0x74697369 0x61652073 0x6c206863 0x20657669
    v128.const i32x4 0x6d656c65 0x20746e65 0x65636e6f 0x00000000
    array.new_fixed 50 3
    i32.const 0
    i32.const 44
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    i32.const 0
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x61727261 0x6c632079 0x20726165 0x65736572
    v128.const i32x4 0x6c207374 0x74676e65 0x00000068 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 25
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 16
    i32.eq
    v128.const i32x4 0x61727261 0x6c632079 0x20726165 0x73657270
    v128.const i32x4 0x65767265 0x61632073 0x69636170 0x00007974
    array.new_fixed 50 2
    i32.const 0
    i32.const 30
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 50
    else
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 11
      array.get 0
      local.set 29
      local.get 10
      ref.cast (ref 11)
      local.get 11
      struct.set 11 1
      i32.const 1
      local.set 50
      local.get 29
      drop
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 50
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x61656c63 0x20646572 0x61727261 0x6f702079
        v128.const i32x4 0x6e752070 0x65707865 0x64657463 0x7020796c
        v128.const i32x4 0x65736572 0x0000746e 0x00000000 0x00000000
        array.new_fixed 50 3
        i32.const 0
        i32.const 38
        struct.new 51
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 77
    local.set 31
    local.get 0
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 0
      local.set 12
      local.get 12
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 31
    array.set 0
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 0
    local.set 11
    local.get 0
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 11
    array.get 0
    i32.const 77
    i32.eq
    v128.const i32x4 0x61727261 0x75702079 0x61206873 0x72657466
    v128.const i32x4 0x656c6320 0x72207261 0x65737565 0x6c612073
    v128.const i32x4 0x65736169 0x74732064 0x6761726f 0x00000065
    array.new_fixed 50 3
    i32.const 0
    i32.const 45
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 5
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 1
    i32.eq
    v128.const i32x4 0x61727261 0x65722079 0x76726573 0x63206465
    v128.const i32x4 0x63617061 0x00797469 0x00000000 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 23
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 9223372036854775807
    local.set 32
    local.get 4
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 1
      local.set 12
      local.get 12
      ref.cast (ref 1)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 1)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 1 1
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 1)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 32
    array.set 1
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i64.const -9223372036854775807
    local.set 33
    local.get 4
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 1
      local.set 12
      local.get 12
      ref.cast (ref 1)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 1)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 1 1
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 1)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 33
    array.set 1
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 0
    local.set 11
    local.get 4
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    local.get 11
    array.get 1
    i64.const 9223372036854775807
    i64.eq
    v128.const i32x4 0x61727261 0x36692079 0x61632034 0x65697272
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 17
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 11
    local.get 4
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    local.get 11
    array.get 1
    i64.const -9223372036854775807
    i64.eq
    v128.const i32x4 0x61727261 0x36692079 0x72672034 0x6874776f
    array.new_fixed 50 1
    i32.const 0
    i32.const 16
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 6
    local.set 5
    f32.const 0x1.8p+0 (;=1.5;)
    local.set 34
    local.get 5
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 2
      local.set 12
      local.get 12
      ref.cast (ref 2)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 2)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 2 2
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 2)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 2)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 34
    array.set 2
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    f32.const 0x1.4p+1 (;=2.5;)
    local.set 35
    local.get 5
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 2
      local.set 12
      local.get 12
      ref.cast (ref 2)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 2)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 2 2
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 2)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 2)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 35
    array.set 2
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 1
    local.set 11
    local.get 5
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 2)
    local.get 11
    array.get 2
    f32.const 0x1.4p+1 (;=2.5;)
    f32.eq
    v128.const i32x4 0x61727261 0x33662079 0x61632032 0x65697272
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 17
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 7
    local.set 6
    f64.const 0x1.8p+0 (;=1.5;)
    local.set 36
    local.get 6
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 3
      local.set 12
      local.get 12
      ref.cast (ref 3)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 3)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 3 3
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 3)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 3)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 36
    array.set 3
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    f64.const 0x1.4p+1 (;=2.5;)
    local.set 37
    local.get 6
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 3
      local.set 12
      local.get 12
      ref.cast (ref 3)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 3)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 3 3
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 3)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 3)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 37
    array.set 3
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 1
    local.set 11
    local.get 6
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 3)
    local.get 11
    array.get 3
    f64.const 0x1.4p+1 (;=2.5;)
    f64.eq
    v128.const i32x4 0x61727261 0x36662079 0x61632034 0x65697272
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 17
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 8
    local.set 7
    i32.const 7
    i32x4.splat
    local.set 38
    local.get 7
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 4
      local.set 12
      local.get 12
      ref.cast (ref 4)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 4)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 4 4
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 4)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 4)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 38
    array.set 4
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 11
    i32x4.splat
    local.set 39
    local.get 7
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 4
      local.set 12
      local.get 12
      ref.cast (ref 4)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 4)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 4 4
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 4)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 4)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 39
    array.set 4
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 1
    local.set 11
    local.get 7
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 4)
    local.get 11
    array.get 4
    call 10
    i32.const 11
    i32.eq
    v128.const i32x4 0x61727261 0x31762079 0x63203832 0x69727261
    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 18
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 9
    local.set 8
    local.get 8
    v128.const i32x4 0x73726966 0x00000074 0x00000000 0x00000000
    array.new_fixed 50 1
    i32.const 0
    i32.const 5
    struct.new 51
    local.set 40
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 5
      local.set 12
      local.get 12
      ref.cast (ref 5)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 40
    array.set 5
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 8
    v128.const i32x4 0x6f636573 0x0000646e 0x00000000 0x00000000
    array.new_fixed 50 1
    i32.const 0
    i32.const 6
    struct.new 51
    local.set 41
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 10
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 10
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 11
      local.get 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 11
      array.new_default 5
      local.set 12
      local.get 12
      ref.cast (ref 5)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 10
      ref.cast (ref 11)
      local.get 12
      struct.set 11 0
      local.get 10
      ref.cast (ref 11)
      local.get 12
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    local.get 41
    array.set 5
    local.get 10
    ref.cast (ref 11)
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 8
    local.set 10
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 51
    else
      local.get 10
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 11
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      local.get 11
      array.get 5
      local.set 42
      local.get 10
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      local.get 11
      ref.null eq
      array.set 5
      local.get 10
      ref.cast (ref 11)
      local.get 11
      struct.set 11 1
      i32.const 1
      local.set 51
      local.get 42
      local.set 52
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 51
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x61727261 0x65722079 0x65726566 0x2065636e
          v128.const i32x4 0x20706f70 0x78656e75 0x74636570 0x796c6465
          v128.const i32x4 0x706d6520 0x00007974 0x00000000 0x00000000
          array.new_fixed 50 3
          i32.const 0
          i32.const 38
          struct.new 51
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 52
        local.set 9
        local.get 9
        call 11
        v128.const i32x4 0x61727261 0x65722079 0x65726566 0x2065636e
        v128.const i32x4 0x00706f70 0x00000000 0x00000000 0x00000000
        array.new_fixed 50 2
        i32.const 0
        i32.const 19
        struct.new 51
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
    local.set 10
    i32.const 0
    local.set 11
    block ;; label = @1
      loop ;; label = @2
        local.get 11
        local.get 10
        ref.cast (ref 11)
        struct.get 11 1
        i32.ge_u
        br_if 1 (;@1;)
        local.get 10
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 5)
        local.get 11
        ref.null eq
        array.set 5
        local.get 11
        i32.const 1
        i32.add
        local.set 11
        br 0 (;@2;)
      end
    end
    local.get 10
    ref.cast (ref 11)
    i32.const 0
    struct.set 11 1
    local.get 8
    ref.cast (ref 11)
    call 1
    v128.const i32x4 0x61727261 0x65722079 0x65726566 0x2065636e
    v128.const i32x4 0x61656c63 0x00000072 0x00000000 0x00000000
    array.new_fixed 50 2
    i32.const 0
    i32.const 21
    struct.new 51
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
