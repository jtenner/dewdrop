(module
  (type (;0;) (func (param eqref eqref) (result i32)))
  (type (;1;) (func (param eqref) (result i32)))
  (type (;2;) (func (result i32)))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 0) (param eqref eqref) (result i32)
    (local (ref 4) (ref 4) (ref 3) (ref 3) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 4)
    local.set 2
    local.get 1
    ref.cast (ref 4)
    local.set 3
    local.get 2
    struct.get 4 2
    local.tee 6
    local.get 3
    struct.get 4 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 4 0
    local.set 4
    local.get 3
    struct.get 4 0
    local.set 5
    local.get 2
    struct.get 4 1
    local.set 7
    local.get 3
    struct.get 4 1
    local.set 8
    i32.const 0
    local.set 9
    loop ;; label = @1
      local.get 9
      local.get 6
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 9
      i32.const 16
      i32.add
      local.get 6
      i32.le_u
      if ;; label = @2
        local.get 7
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 3
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 3
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 3
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 10
        end
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 3
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 3
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 3
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 11
        end
        local.get 10
        local.get 11
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 7
        i32.const 16
        i32.add
        local.set 7
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        br 1 (;@1;)
      end
      local.get 4
      local.get 7
      i32.const 4
      i32.shr_u
      array.get 3
      local.get 7
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 3
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i32.ne
      if ;; label = @2
        i32.const 0
        return
      end
      local.get 7
      i32.const 1
      i32.add
      local.set 7
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;1;) (type 1) (param eqref) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      array.new_fixed 3 0
      i32.const 0
      i32.const 0
      struct.new 4
      call 0
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      local.get 1
      v128.const i32x4 0x6f72657a 0x00000000 0x00000000 0x00000000
      array.new_fixed 3 1
      i32.const 0
      i32.const 4
      struct.new 4
      call 0
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      local.get 1
      v128.const i32x4 0xb8e4bbce 0x8c95e796 0x00000000 0x00000000
      array.new_fixed 3 1
      i32.const 0
      i32.const 8
      struct.new 4
      call 0
      if ;; label = @2
        i32.const 2
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        i32.const 1
        i32.sub
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;2;) (type 2) (result i32)
    array.new_fixed 3 0
    i32.const 0
    i32.const 0
    struct.new 4
    call 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x74706d65 0x74732079 0x676e6972 0x74617020
    v128.const i32x4 0x6e726574 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 20
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x6f72657a 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 1
    i32.const 0
    i32.const 4
    struct.new 4
    call 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x49435341 0x74732049 0x676e6972 0x74617020
    v128.const i32x4 0x6e726574 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 20
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0xb8e4bbce 0x8c95e796 0x00000000 0x00000000
    array.new_fixed 3 1
    i32.const 0
    i32.const 8
    struct.new 4
    call 1
    i32.const 2
    i32.eq
    v128.const i32x4 0x2d465455 0x74732038 0x676e6972 0x74617020
    v128.const i32x4 0x6e726574 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 20
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x6568746f 0x00000072 0x00000000 0x00000000
    array.new_fixed 3 1
    i32.const 0
    i32.const 5
    struct.new 4
    call 1
    i32.const 0
    i32.const 1
    i32.sub
    i32.eq
    v128.const i32x4 0x69727473 0x7020676e 0x65747461 0x66206e72
    v128.const i32x4 0x626c6c61 0x006b6361 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 23
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
  )
)
