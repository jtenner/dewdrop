(module
  (type (;0;) (func (result eqref)))
  (type (;1;) (func (param eqref eqref)))
  (type (;2;) (func (param eqref) (result eqref)))
  (type (;3;) (func (result eqref)))
  (type (;4;) (func (param eqref eqref)))
  (type (;5;) (func (param eqref) (result eqref)))
  (type (;6;) (func (result i32)))
  (type (;7;) (array (mut v128)))
  (type (;8;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;10;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;11;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 6))
  (func (;0;) (type 0) (result eqref)
    i32.const 4
    array.new_default 7
    i32.const 0
    i32.const 0
    struct.new 11
  )
  (func (;1;) (type 1) (param eqref eqref)
    (local (ref 11) (ref 8) (ref 7) (ref 7) i32 i32 i32 i32 i32 i32 (ref 7) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 11)
    local.set 2
    local.get 2
    struct.get 11 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 8)
    local.set 3
    local.get 2
    struct.get 11 0
    local.set 4
    local.get 3
    struct.get 8 0
    local.set 5
    local.get 2
    struct.get 11 1
    local.set 6
    local.get 3
    struct.get 8 1
    local.set 7
    local.get 3
    struct.get 8 2
    local.set 8
    local.get 6
    local.get 8
    i32.add
    local.tee 9
    local.get 6
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 9
    i32.const 4
    i32.shr_u
    local.get 9
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    local.set 10
    local.get 4
    array.len
    local.set 11
    local.get 10
    local.get 11
    i32.gt_u
    if ;; label = @1
      local.get 11
      i32.const 1
      i32.shl
      local.set 11
      local.get 11
      local.get 10
      i32.lt_u
      if ;; label = @2
        local.get 10
        local.set 11
      end
      local.get 11
      array.new_default 7
      local.set 12
      i32.const 0
      local.set 13
      block ;; label = @2
        loop ;; label = @3
          local.get 13
          local.get 6
          i32.const 4
          i32.shr_u
          local.get 6
          i32.const 15
          i32.and
          i32.const 0
          i32.ne
          i32.add
          i32.ge_u
          br_if 1 (;@2;)
          local.get 12
          local.get 13
          local.get 4
          local.get 13
          array.get 7
          array.set 7
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 11 0
      local.get 12
      local.set 4
    end
    i32.const 0
    local.set 14
    block ;; label = @1
      loop ;; label = @2
        local.get 14
        local.get 8
        i32.ge_u
        br_if 1 (;@1;)
        local.get 7
        local.get 14
        i32.add
        local.set 15
        local.get 6
        local.get 14
        i32.add
        local.set 16
        local.get 14
        i32.const 16
        i32.add
        local.get 8
        i32.le_u
        if ;; label = @3
          local.get 15
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 7
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 7
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 15
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 7
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 15
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i32.const 16
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            v128.or
            local.set 18
          end
          local.get 16
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            local.get 18
            array.set 7
          else
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 16
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.lt_u
            local.set 19
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            array.get 7
            local.get 18
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 16
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            local.get 19
            v128.bitselect
            array.set 7
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            local.get 18
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            i32.const 16
            local.get 16
            i32.const 15
            i32.and
            i32.sub
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 7
            local.get 19
            v128.bitselect
            array.set 7
          end
          local.get 14
          i32.const 16
          i32.add
          local.set 14
          br 1 (;@2;)
        end
        local.get 5
        local.get 15
        i32.const 4
        i32.shr_u
        array.get 7
        local.get 15
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 17
        local.get 4
        local.get 16
        i32.const 4
        i32.shr_u
        local.get 17
        i8x16.splat
        local.get 4
        local.get 16
        i32.const 4
        i32.shr_u
        array.get 7
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 7
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 11 1
  )
  (func (;2;) (type 2) (param eqref) (result eqref)
    (local (ref 11))
    local.get 0
    ref.cast (ref 11)
    local.set 1
    local.get 1
    struct.get 11 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 11 2
    local.get 1
    struct.get 11 0
    i32.const 0
    local.get 1
    struct.get 11 1
    struct.new 8
  )
  (func (;3;) (type 3) (result eqref)
    call 0
  )
  (func (;4;) (type 4) (param eqref eqref)
    local.get 0
    local.get 1
    call 1
  )
  (func (;5;) (type 5) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;6;) (type 6) (result i32)
    (local eqref)
    call 3
    local.set 0
    local.get 0
    call 5
    drop
    local.get 0
    v128.const i32x4 0x65746661 0x69662072 0x6873696e 0x00000000
    array.new_fixed 7 1
    i32.const 0
    i32.const 12
    struct.new 8
    call 4
    i32.const 0
  )
)
