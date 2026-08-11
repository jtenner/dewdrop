(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;3;) (struct (field eqref) (field (mut i32))))
  (type (;4;) (func (param eqref) (result i32)))
  (type (;5;) (func (param eqref) (result i32)))
  (type (;6;) (func (result (ref 2))))
  (type (;7;) (func (result (ref 2))))
  (type (;8;) (func (result (ref 2))))
  (type (;9;) (func (result (ref 2))))
  (type (;10;) (func (result (ref 2))))
  (type (;11;) (func (result (ref 2))))
  (type (;12;) (func (param v128) (result i32)))
  (type (;13;) (func (param eqref) (result i32)))
  (type (;14;) (func (param (ref 3) i32) (result i32)))
  (type (;15;) (func))
  (type (;16;) (array (mut v128)))
  (type (;17;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;19;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;20;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (type (;21;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (type (;22;) (array (mut i32)))
  (type (;23;) (array (mut i64)))
  (type (;24;) (array (mut f32)))
  (type (;25;) (array (mut f64)))
  (type (;26;) (array (mut v128)))
  (type (;27;) (array (mut eqref)))
  (export "main" (func 11))
  (func (;0;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 17)
    struct.get 17 2
  )
  (func (;1;) (type 5) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;2;) (type 6) (result (ref 2))
    i32.const 0
    array.new_default 22
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;3;) (type 7) (result (ref 2))
    (local eqref i32 eqref)
    i32.const 1
    local.set 1
    local.get 1
    array.new_default 23
    i32.const 0
    local.get 1
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;4;) (type 8) (result (ref 2))
    i32.const 0
    array.new_default 24
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;5;) (type 9) (result (ref 2))
    i32.const 0
    array.new_default 25
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;6;) (type 10) (result (ref 2))
    i32.const 0
    array.new_default 26
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;7;) (type 11) (result (ref 2))
    i32.const 0
    array.new_default 27
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;8;) (type 12) (param v128) (result i32)
    local.get 0
    i32x4.extract_lane 2
  )
  (func (;9;) (type 13) (param eqref) (result i32)
    local.get 0
    call 1
    i32.const 6
    i32.eq
  )
  (func (;10;) (type 14) (param (ref 3) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 3)
      local.get 1
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 2)
      struct.get 2 1
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 2)
      struct.get 2 1
      i32.lt_u
      if ;; label = @2
      else
        unreachable
      end
      local.get 2
      ref.cast (ref 2)
      struct.get 2 1
      local.set 3
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 22)
      local.get 3
      array.get 22
      local.get 2
      ref.cast (ref 2)
      local.get 3
      i32.const 1
      i32.add
      struct.set 2 1
      i32.add
      call 10
    else
      local.get 1
    end
  )
  (func (;11;) (type 15)
    (local eqref eqref i32 i32 eqref eqref eqref eqref eqref eqref eqref eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref i32 eqref i32 i64 i64 f32 f32 f64 f64 v128 v128 eqref eqref eqref eqref i32)
    call 2
    local.set 0
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x61727261 0x74732079 0x73747261 0x706d6520
    v128.const i32x4 0x00007974 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 18
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 2
    i32.const 0
    i32.eq
    v128.const i32x4 0x61727261 0x74732079 0x73747261 0x20746120
    v128.const i32x4 0x6f72657a 0x70616320 0x74696361 0x00000079
    array.new_fixed 16 2
    i32.const 0
    i32.const 29
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    v128.const i32x4 0x61727261 0x74732079 0x73747261 0x676f6c20
    v128.const i32x4 0x6c616369 0x6520796c 0x7974706d 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 28
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    i32.const 0
    local.set 14
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 14
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 1
    local.set 15
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 15
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 2
    local.set 16
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 16
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 3
    local.set 17
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 17
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 4
    local.set 18
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 18
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 5
    local.set 19
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 19
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 6
    local.set 20
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 20
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 7
    local.set 21
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 21
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 8
    local.set 22
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 22
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    local.set 11
    i32.const 9
    local.set 23
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 23
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 10
    i32.eq
    v128.const i32x4 0x61727261 0x65722079 0x74616570 0x67206465
    v128.const i32x4 0x74776f72 0x656c2068 0x6874676e 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 28
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 2
    i32.const 16
    i32.eq
    v128.const i32x4 0x61727261 0x65642079 0x6d726574 0x73696e69
    v128.const i32x4 0x20636974 0x62756f64 0x676e696c 0x70616320
    v128.const i32x4 0x74696361 0x00000079 0x00000000 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 37
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    i32.const 0
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 12
    array.get 22
    i32.const 0
    i32.eq
    v128.const i32x4 0x61727261 0x72672079 0x6874776f 0x65727020
    v128.const i32x4 0x76726573 0x66207365 0x74737269 0x656c6520
    v128.const i32x4 0x746e656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 36
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    i32.const 4
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 12
    array.get 22
    i32.const 4
    i32.eq
    v128.const i32x4 0x61727261 0x72672079 0x6874776f 0x65727020
    v128.const i32x4 0x76726573 0x6d207365 0x6c646469 0x6c652065
    v128.const i32x4 0x6e656d65 0x00000074 0x00000000 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 37
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    i32.const 9
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 12
    array.get 22
    i32.const 9
    i32.eq
    v128.const i32x4 0x61727261 0x72672079 0x6874776f 0x65727020
    v128.const i32x4 0x76726573 0x66207365 0x6c616e69 0x656c6520
    v128.const i32x4 0x746e656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 36
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    local.get 1
    local.set 11
    i32.const 4
    local.set 12
    i32.const 40
    local.set 45
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 12
    local.get 45
    array.set 22
    local.get 0
    local.set 11
    i32.const 4
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 12
    array.get 22
    i32.const 40
    i32.eq
    v128.const i32x4 0x61727261 0x6c612079 0x65736169 0x68732073
    v128.const i32x4 0x20657261 0x65646e69 0x20646578 0x6174756d
    v128.const i32x4 0x6e6f6974 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 36
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    i32.const 9
    local.set 12
    i32.const 90
    local.set 24
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 22)
      local.get 12
      local.get 24
      array.set 22
      i32.const 1
    else
      i32.const 0
    end
    v128.const i32x4 0x61727261 0x61732079 0x73206566 0x72207465
    v128.const i32x4 0x726f7065 0x73207374 0x65636375 0x00007373
    array.new_fixed 16 2
    i32.const 0
    i32.const 30
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    i32.const 10
    local.set 12
    i32.const 100
    local.set 25
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 22)
      local.get 12
      local.get 25
      array.set 22
      i32.const 1
    else
      i32.const 0
    end
    i32.eqz
    v128.const i32x4 0x61727261 0x61732079 0x73206566 0x72207465
    v128.const i32x4 0x726f7065 0x62207374 0x646e756f 0x61662073
    v128.const i32x4 0x72756c69 0x00000065 0x00000000 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 37
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    i32.const 9
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 22)
      local.get 12
      array.get 22
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    local.set 26
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 26
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x61727261 0x61732079 0x67206566 0x75207465
          v128.const i32x4 0x7078656e 0x65746365 0x20796c64 0x74706d65
          v128.const i32x4 0x00000079 0x00000000 0x00000000 0x00000000
          array.new_fixed 16 3
          i32.const 0
          i32.const 33
          struct.new 17
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 26
        ref.cast (ref 1)
        struct.get 1 1
        local.set 2
        local.get 2
        i32.const 90
        i32.eq
        v128.const i32x4 0x61727261 0x61732079 0x67206566 0x76207465
        v128.const i32x4 0x65756c61 0x00000000 0x00000000 0x00000000
        array.new_fixed 16 2
        i32.const 0
        i32.const 20
        struct.new 17
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
    local.set 11
    i32.const 10
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 22)
      local.get 12
      array.get 22
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    local.set 27
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 27
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x61727261 0x756f2079 0x666f2074 0x756f6220
        v128.const i32x4 0x2073646e 0x78656e75 0x74636570 0x796c6465
        v128.const i32x4 0x65727020 0x746e6573 0x00000000 0x00000000
        array.new_fixed 16 3
        i32.const 0
        i32.const 40
        struct.new 17
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
    local.set 11
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 11
      ref.cast (ref 2)
      struct.get 2 1
      i32.const 1
      i32.sub
      local.set 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 22)
      local.get 12
      array.get 22
      local.set 28
      local.get 11
      ref.cast (ref 2)
      local.get 12
      struct.set 2 1
      i32.const 1
      local.get 28
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    end
    local.set 29
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 29
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x61727261 0x6f702079 0x6e752070 0x65707865
          v128.const i32x4 0x64657463 0x6520796c 0x7974706d 0x00000000
          array.new_fixed 16 2
          i32.const 0
          i32.const 28
          struct.new 17
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 29
        ref.cast (ref 1)
        struct.get 1 1
        local.set 3
        local.get 3
        i32.const 90
        i32.eq
        v128.const i32x4 0x61727261 0x6f702079 0x65722070 0x6e727574
        v128.const i32x4 0x69662073 0x206c616e 0x756c6176 0x00000065
        array.new_fixed 16 2
        i32.const 0
        i32.const 29
        struct.new 17
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
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 9
    i32.eq
    v128.const i32x4 0x61727261 0x6f702079 0x65642070 0x6d657263
    v128.const i32x4 0x73746e65 0x6e656c20 0x00687467 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 27
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 2
    i32.const 16
    i32.eq
    v128.const i32x4 0x61727261 0x6f702079 0x72702070 0x72657365
    v128.const i32x4 0x20736576 0x61706163 0x79746963 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 28
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    i32.const 0
    struct.new 2
    local.set 4
    local.get 4
    ref.cast (ref 3)
    i32.const 0
    call 10
    i32.const 72
    i32.eq
    v128.const i32x4 0x61727261 0x74692079 0x74617265 0x7620726f
    v128.const i32x4 0x74697369 0x61652073 0x6c206863 0x20657669
    v128.const i32x4 0x6d656c65 0x20746e65 0x65636e6f 0x00000000
    array.new_fixed 16 3
    i32.const 0
    i32.const 44
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    local.get 11
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x61727261 0x6c632079 0x20726165 0x65736572
    v128.const i32x4 0x6c207374 0x74676e65 0x00000068 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 25
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 2
    i32.const 16
    i32.eq
    v128.const i32x4 0x61727261 0x6c632079 0x20726165 0x73657270
    v128.const i32x4 0x65767265 0x61632073 0x69636170 0x00007974
    array.new_fixed 16 2
    i32.const 0
    i32.const 30
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 11
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 11
      ref.cast (ref 2)
      struct.get 2 1
      i32.const 1
      i32.sub
      local.set 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 22)
      local.get 12
      array.get 22
      local.set 30
      local.get 11
      ref.cast (ref 2)
      local.get 12
      struct.set 2 1
      i32.const 1
      local.get 30
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    end
    local.set 31
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 31
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x61656c63 0x20646572 0x61727261 0x6f702079
        v128.const i32x4 0x6e752070 0x65707865 0x64657463 0x7020796c
        v128.const i32x4 0x65736572 0x0000746e 0x00000000 0x00000000
        array.new_fixed 16 3
        i32.const 0
        i32.const 38
        struct.new 17
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
    local.set 11
    i32.const 77
    local.set 32
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 22
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 22)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 22)
          local.get 12
          array.get 22
          array.set 22
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 22)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 32
    array.set 22
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 1
    local.set 11
    i32.const 0
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 22)
    local.get 12
    array.get 22
    i32.const 77
    i32.eq
    v128.const i32x4 0x61727261 0x75702079 0x61206873 0x72657466
    v128.const i32x4 0x656c6320 0x72207261 0x65737565 0x6c612073
    v128.const i32x4 0x65736169 0x74732064 0x6761726f 0x00000065
    array.new_fixed 16 3
    i32.const 0
    i32.const 45
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 3
    local.set 5
    local.get 5
    ref.cast (ref 2)
    struct.get 2 2
    i32.const 1
    i32.eq
    v128.const i32x4 0x61727261 0x65722079 0x76726573 0x63206465
    v128.const i32x4 0x63617061 0x00797469 0x00000000 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 23
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    local.set 11
    i64.const 9223372036854775807
    local.set 33
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 23
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 23)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 23)
          local.get 12
          array.get 23
          array.set 23
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 23)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 23)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 33
    array.set 23
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 5
    local.set 11
    i64.const 0
    i64.const 9223372036854775807
    i64.sub
    local.set 34
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 23
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 23)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 23)
          local.get 12
          array.get 23
          array.set 23
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 23)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 23)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 34
    array.set 23
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 5
    local.set 11
    i32.const 0
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 23)
    local.get 12
    array.get 23
    i64.const 9223372036854775807
    i64.eq
    v128.const i32x4 0x61727261 0x36692079 0x61632034 0x65697272
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 17
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    local.set 11
    i32.const 1
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 23)
    local.get 12
    array.get 23
    i64.const 0
    i64.const 9223372036854775807
    i64.sub
    i64.eq
    v128.const i32x4 0x61727261 0x36692079 0x72672034 0x6874776f
    array.new_fixed 16 1
    i32.const 0
    i32.const 16
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 4
    local.set 6
    local.get 6
    local.set 11
    f32.const 0x1.8p+0 (;=1.5;)
    local.set 35
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 24
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 24)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 24)
          local.get 12
          array.get 24
          array.set 24
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 24)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 24)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 35
    array.set 24
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 6
    local.set 11
    f32.const 0x1.4p+1 (;=2.5;)
    local.set 36
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 24
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 24)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 24)
          local.get 12
          array.get 24
          array.set 24
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 24)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 24)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 36
    array.set 24
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 6
    local.set 11
    i32.const 1
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 24)
    local.get 12
    array.get 24
    f32.const 0x1.4p+1 (;=2.5;)
    f32.eq
    v128.const i32x4 0x61727261 0x33662079 0x61632032 0x65697272
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 17
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 5
    local.set 7
    local.get 7
    local.set 11
    f64.const 0x1.8p+0 (;=1.5;)
    local.set 37
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 25
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 25)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 25)
          local.get 12
          array.get 25
          array.set 25
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 25)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 25)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 37
    array.set 25
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 7
    local.set 11
    f64.const 0x1.4p+1 (;=2.5;)
    local.set 38
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 25
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 25)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 25)
          local.get 12
          array.get 25
          array.set 25
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 25)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 25)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 38
    array.set 25
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 7
    local.set 11
    i32.const 1
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 25)
    local.get 12
    array.get 25
    f64.const 0x1.4p+1 (;=2.5;)
    f64.eq
    v128.const i32x4 0x61727261 0x36662079 0x61632034 0x65697272
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 17
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 6
    local.set 8
    local.get 8
    local.set 11
    i32.const 7
    i32x4.splat
    local.set 39
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 26
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 26)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 26)
          local.get 12
          array.get 26
          array.set 26
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 26)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 26)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 39
    array.set 26
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 8
    local.set 11
    i32.const 11
    i32x4.splat
    local.set 40
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 26
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 26)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 26)
          local.get 12
          array.get 26
          array.set 26
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 26)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 26)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 40
    array.set 26
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 8
    local.set 11
    i32.const 1
    local.set 12
    local.get 12
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 26)
    local.get 12
    array.get 26
    call 8
    i32.const 11
    i32.eq
    v128.const i32x4 0x61727261 0x31762079 0x63203832 0x69727261
    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 18
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 7
    local.set 9
    local.get 9
    local.set 11
    v128.const i32x4 0x73726966 0x00000074 0x00000000 0x00000000
    array.new_fixed 16 1
    i32.const 0
    i32.const 5
    struct.new 17
    local.set 41
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 27
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 27)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 27)
          local.get 12
          array.get 27
          array.set 27
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 27)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 27)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 41
    array.set 27
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    local.set 11
    v128.const i32x4 0x6f636573 0x0000646e 0x00000000 0x00000000
    array.new_fixed 16 1
    i32.const 0
    i32.const 6
    struct.new 17
    local.set 42
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 11
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 11
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 12
      local.get 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 12
      array.new_default 27
      local.set 13
      i32.const 0
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 13
          ref.cast (ref 27)
          local.get 12
          local.get 11
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 27)
          local.get 12
          array.get 27
          array.set 27
          local.get 12
          i32.const 1
          i32.add
          local.set 12
          br 0 (;@3;)
        end
      end
      local.get 11
      ref.cast (ref 2)
      local.get 13
      struct.set 2 0
      local.get 11
      ref.cast (ref 2)
      local.get 13
      ref.cast (ref 27)
      array.len
      struct.set 2 2
    end
    local.get 11
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 27)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    local.get 42
    array.set 27
    local.get 11
    ref.cast (ref 2)
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 9
    local.set 11
    local.get 11
    ref.cast (ref 2)
    struct.get 2 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 11
      ref.cast (ref 2)
      struct.get 2 1
      i32.const 1
      i32.sub
      local.set 12
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 27)
      local.get 12
      array.get 27
      local.set 43
      local.get 11
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 27)
      local.get 12
      ref.null eq
      array.set 27
      local.get 11
      ref.cast (ref 2)
      local.get 12
      struct.set 2 1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 43
      struct.new 1
    end
    local.set 44
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 44
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x61727261 0x65722079 0x65726566 0x2065636e
          v128.const i32x4 0x20706f70 0x78656e75 0x74636570 0x796c6465
          v128.const i32x4 0x706d6520 0x00007974 0x00000000 0x00000000
          array.new_fixed 16 3
          i32.const 0
          i32.const 38
          struct.new 17
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 44
        ref.cast (ref 1)
        struct.get 1 6
        local.set 10
        local.get 10
        call 9
        v128.const i32x4 0x61727261 0x65722079 0x65726566 0x2065636e
        v128.const i32x4 0x00706f70 0x00000000 0x00000000 0x00000000
        array.new_fixed 16 2
        i32.const 0
        i32.const 19
        struct.new 17
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
    local.set 11
    i32.const 0
    local.set 12
    block ;; label = @1
      loop ;; label = @2
        local.get 12
        local.get 11
        ref.cast (ref 2)
        struct.get 2 1
        i32.ge_u
        br_if 1 (;@1;)
        local.get 11
        ref.cast (ref 2)
        struct.get 2 0
        ref.cast (ref 27)
        local.get 12
        ref.null eq
        array.set 27
        local.get 12
        i32.const 1
        i32.add
        local.set 12
        br 0 (;@2;)
      end
    end
    local.get 11
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    local.get 9
    ref.cast (ref 2)
    struct.get 2 1
    v128.const i32x4 0x61727261 0x65722079 0x65726566 0x2065636e
    v128.const i32x4 0x61656c63 0x00000072 0x00000000 0x00000000
    array.new_fixed 16 2
    i32.const 0
    i32.const 21
    struct.new 17
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
