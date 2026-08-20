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
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref) (result i32)))
  (type (;29;) (struct (field (ref 8)) (field (ref 8))))
  (type (;30;) (func (result (ref 29))))
  (type (;31;) (func))
  (type (;32;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;33;) (struct))
  (type (;34;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;35;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;36;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;37;) (array (mut v128)))
  (type (;38;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;39;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;40;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;41;) (struct (field (mut (ref 37))) (field (mut i32)) (field (mut i32))))
  (type (;42;) (struct (field (mut (ref 37))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 27) (param eqref eqref) (result i32)
    (local (ref 38) (ref 38) (ref 37) (ref 37) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 38)
    local.set 2
    local.get 1
    ref.cast (ref 38)
    local.set 3
    local.get 2
    struct.get 38 2
    local.tee 6
    local.get 3
    struct.get 38 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 38 0
    local.set 4
    local.get 3
    struct.get 38 0
    local.set 5
    local.get 2
    struct.get 38 1
    local.set 7
    local.get 3
    struct.get 38 1
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
          array.get 37
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 37
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
          array.get 37
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
          array.get 37
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 37
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
          array.get 37
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
      array.get 37
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
      array.get 37
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
  (func (;1;) (type 28) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;2;) (type 30) (result (ref 29))
    (local eqref i32 eqref)
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 8
    ref.cast (ref 8)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 8
    ref.cast (ref 8)
    struct.new 29
    ref.cast (ref 29)
  )
  (func (;3;) (type 31)
    (local (ref 29) eqref i32 eqref eqref i32)
    call 2
    local.set 0
    local.get 0
    ref.cast (ref 29)
    struct.get 29 0
    v128.const i32x4 0x656d616e 0x00000000 0x00000000 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 4
    struct.new 38
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
      array.new_default 5
      local.set 3
      local.get 3
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 0
      ref.cast (ref 5)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 1
      array.copy 5 5
      local.get 1
      ref.cast (ref 8)
      local.get 3
      struct.set 8 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      ref.cast (ref 5)
      array.len
      struct.set 8 2
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 5)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 4
    array.set 5
    local.get 1
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.add
    struct.set 8 1
    local.get 0
    ref.cast (ref 29)
    struct.get 29 1
    i32.const 7
    local.set 5
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
    local.get 5
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
    ref.cast (ref 29)
    struct.get 29 0
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x656d616e 0x6e656c20 0x00687467 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 11
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 29)
    struct.get 29 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x626d756e 0x6c207265 0x74676e65 0x00000068
    array.new_fixed 37 1
    i32.const 0
    i32.const 13
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 29)
    struct.get 29 0
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
    ref.cast (ref 5)
    local.get 2
    array.get 5
    v128.const i32x4 0x656d616e 0x00000000 0x00000000 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 4
    struct.new 38
    call 1
    v128.const i32x4 0x656d616e 0x6c617620 0x00006575 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 10
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 29)
    struct.get 29 1
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
    i32.const 7
    i32.eq
    v128.const i32x4 0x626d756e 0x76207265 0x65756c61 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 12
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
