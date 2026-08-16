(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref) (result i32)))
  (type (;9;) (func (param eqref) (result i32)))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (param eqref) (result i32)))
  (type (;12;) (func (result i32)))
  (type (;13;) (array (mut v128)))
  (type (;14;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;17;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 4))
  (func (;0;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 2
  )
  (func (;1;) (type 9) (param eqref) (result i32)
    (local (ref 14) (ref 13) i32 i32 v128 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 14)
    local.set 1
    local.get 1
    struct.get 14 0
    local.set 2
    local.get 1
    struct.get 14 2
    local.set 3
    local.get 1
    struct.get 14 1
    local.tee 4
    local.get 3
    i32.add
    local.set 9
    i32.const 0
    local.set 6
    i32.const 0
    local.set 7
    loop ;; label = @1
      local.get 4
      local.get 9
      i32.ge_u
      if ;; label = @2
        local.get 3
        local.get 6
        i32.sub
        local.get 7
        i32.add
        return
      end
      local.get 4
      i32.const 16
      i32.add
      local.get 9
      i32.le_u
      if ;; label = @2
        local.get 4
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 2
          local.get 4
          i32.const 4
          i32.shr_u
          array.get 13
          local.set 5
        else
          local.get 2
          local.get 4
          i32.const 4
          i32.shr_u
          array.get 13
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 4
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 2
          local.get 4
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 13
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 4
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 5
        end
        local.get 6
        local.get 5
        i32.const -64
        i8x16.splat
        i8x16.lt_s
        i8x16.bitmask
        i32.popcnt
        i32.add
        local.set 6
        local.get 7
        local.get 5
        i32.const 248
        i8x16.splat
        v128.and
        i32.const 240
        i8x16.splat
        i8x16.eq
        i8x16.bitmask
        i32.popcnt
        i32.add
        local.set 7
        local.get 4
        i32.const 16
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      local.get 2
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 13
      local.get 4
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 8
      local.get 8
      i32.const 192
      i32.and
      i32.const 128
      i32.eq
      if ;; label = @2
        local.get 6
        i32.const 1
        i32.add
        local.set 6
      end
      local.get 8
      i32.const 248
      i32.and
      i32.const 240
      i32.eq
      if ;; label = @2
        local.get 7
        i32.const 1
        i32.add
        local.set 7
      end
      local.get 4
      i32.const 1
      i32.add
      local.set 4
      br 0 (;@1;)
    end
    i32.const 0
  )
  (func (;2;) (type 10) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;3;) (type 11) (param eqref) (result i32)
    local.get 0
    call 1
  )
  (func (;4;) (type 12) (result i32)
    v128.const i32x4 0xf0bbce61 0x008d8c9f 0x00000000 0x00000000
    array.new_fixed 13 1
    i32.const 0
    i32.const 7
    struct.new 14
    call 2
    v128.const i32x4 0xf0bbce61 0x008d8c9f 0x00000000 0x00000000
    array.new_fixed 13 1
    i32.const 0
    i32.const 7
    struct.new 14
    call 3
    i32.add
  )
)
