(module
  (type (;0;) (func (param eqref eqref) (result i32)))
  (type (;1;) (func (param eqref eqref) (result i32)))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param i32) (result i64)))
  (type (;4;) (func (param i32) (result f32)))
  (type (;5;) (func (param i32) (result f64)))
  (type (;6;) (func (param i32) (result v128)))
  (type (;7;) (func (param i32) (result eqref)))
  (type (;8;) (func))
  (type (;9;) (func (param i32)))
  (type (;10;) (func))
  (type (;11;) (array (mut v128)))
  (type (;12;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;15;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 10))
  (func (;0;) (type 0) (param eqref eqref) (result i32)
    (local (ref 12) (ref 12) (ref 11) (ref 11) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 12)
    local.set 2
    local.get 1
    ref.cast (ref 12)
    local.set 3
    local.get 2
    struct.get 12 2
    local.tee 6
    local.get 3
    struct.get 12 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 12 0
    local.set 4
    local.get 3
    struct.get 12 0
    local.set 5
    local.get 2
    struct.get 12 1
    local.set 7
    local.get 3
    struct.get 12 1
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
          array.get 11
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 11
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
          array.get 11
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
          array.get 11
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 11
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
          array.get 11
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
      array.get 11
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
      array.get 11
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
  (func (;1;) (type 1) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;2;) (type 2) (param i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      unreachable
    else
      i32.const 42
    end
  )
  (func (;3;) (type 3) (param i32) (result i64)
    local.get 0
    if (result i64) ;; label = @1
      unreachable
    else
      i64.const 42
    end
  )
  (func (;4;) (type 4) (param i32) (result f32)
    local.get 0
    if (result f32) ;; label = @1
      unreachable
    else
      f32.const 0x1.5p+5 (;=42;)
    end
  )
  (func (;5;) (type 5) (param i32) (result f64)
    local.get 0
    if (result f64) ;; label = @1
      unreachable
    else
      f64.const 0x1.5p+5 (;=42;)
    end
  )
  (func (;6;) (type 6) (param i32) (result v128)
    local.get 0
    if (result v128) ;; label = @1
      unreachable
    else
      i32.const 42
      i32x4.splat
    end
  )
  (func (;7;) (type 7) (param i32) (result eqref)
    local.get 0
    if (result eqref) ;; label = @1
      unreachable
    else
      v128.const i32x4 0x74726f66 0x77742d79 0x0000006f 0x00000000
      array.new_fixed 11 1
      i32.const 0
      i32.const 9
      struct.new 12
    end
  )
  (func (;8;) (type 8)
    i32.const 1
    drop
    i64.const 2
    drop
    f32.const 0x1.8p+1 (;=3;)
    drop
    f64.const 0x1p+2 (;=4;)
    drop
    i32.const 5
    i32x4.splat
    drop
    v128.const i32x4 0x63736964 0x65647261 0x65722064 0x00000066
    array.new_fixed 11 1
    i32.const 0
    i32.const 13
    struct.new 12
    drop
    return
  )
  (func (;9;) (type 9) (param i32)
    local.get 0
    if ;; label = @1
      return
    else
    end
    i32.const 7
    drop
    return
    unreachable
  )
  (func (;10;) (type 10)
    call 8
    i32.const 1
    call 9
    i32.const 0
    call 9
    i32.const 0
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x6576654e 0x6f742072 0x32336920 0x696f6a20
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 17
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 3
    i64.const 42
    i64.eq
    v128.const i32x4 0x6576654e 0x6f742072 0x34366920 0x696f6a20
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 17
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 4
    f32.const 0x1.5p+5 (;=42;)
    f32.eq
    v128.const i32x4 0x6576654e 0x6f742072 0x32336620 0x696f6a20
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 17
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 5
    f64.const 0x1.5p+5 (;=42;)
    f64.eq
    v128.const i32x4 0x6576654e 0x6f742072 0x34366620 0x696f6a20
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 17
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 6
    i32.const 42
    i32x4.splat
    v128.xor
    v128.any_true
    i32.eqz
    v128.const i32x4 0x6576654e 0x6f742072 0x32317620 0x6f6a2038
    v128.const i32x4 0x00006e69 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 18
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 7
    v128.const i32x4 0x74726f66 0x77742d79 0x0000006f 0x00000000
    array.new_fixed 11 1
    i32.const 0
    i32.const 9
    struct.new 12
    call 1
    v128.const i32x4 0x6576654e 0x6f742072 0x66657220 0x696f6a20
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 17
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
