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
  (type (;27;) (func (param eqref) (result i32)))
  (type (;28;) (func (result eqref)))
  (type (;29;) (func (param eqref) (result i32)))
  (type (;30;) (func (param eqref eqref)))
  (type (;31;) (func (param eqref) (result eqref)))
  (type (;32;) (func (param eqref) (result i32)))
  (type (;33;) (func (result eqref)))
  (type (;34;) (func (param eqref) (result i32)))
  (type (;35;) (func (param eqref eqref)))
  (type (;36;) (func (param eqref) (result eqref)))
  (type (;37;) (struct (field eqref) (field i32)))
  (type (;38;) (func (param (ref 37) i32)))
  (type (;39;) (func (param eqref) (result eqref)))
  (type (;40;) (func (param (ref 37))))
  (type (;41;) (func (param (ref 37) eqref)))
  (type (;42;) (func (param (ref 37) eqref)))
  (type (;43;) (func (param eqref) (result eqref)))
  (type (;44;) (func (param (ref 37) eqref)))
  (type (;45;) (struct))
  (type (;46;) (func))
  (type (;47;) (func (param (ref 45) (ref 37))))
  (type (;48;) (func))
  (type (;49;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;50;) (struct))
  (type (;51;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;52;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;53;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;54;) (array (mut v128)))
  (type (;55;) (struct (field (ref 54)) (field i32) (field i32)))
  (type (;56;) (struct (field (ref 54)) (field i32) (field i32)))
  (type (;57;) (struct (field (ref 54)) (field i32) (field i32)))
  (type (;58;) (struct (field (mut (ref 54))) (field (mut i32)) (field (mut i32))))
  (type (;59;) (struct (field (mut (ref 54))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 17))
  (func (;0;) (type 27) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 55)
    struct.get 55 2
  )
  (func (;1;) (type 28) (result eqref)
    i32.const 4
    array.new_default 54
    i32.const 0
    i32.const 0
    struct.new 58
  )
  (func (;2;) (type 29) (param eqref) (result i32)
    (local (ref 58))
    local.get 0
    ref.cast (ref 58)
    local.tee 1
    struct.get 58 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 58 1
  )
  (func (;3;) (type 30) (param eqref eqref)
    (local (ref 58) (ref 55) (ref 54) (ref 54) i32 i32 i32 i32 i32 i32 (ref 54) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 58)
    local.set 2
    local.get 2
    struct.get 58 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 55)
    local.set 3
    local.get 2
    struct.get 58 0
    local.set 4
    local.get 3
    struct.get 55 0
    local.set 5
    local.get 2
    struct.get 58 1
    local.set 6
    local.get 3
    struct.get 55 1
    local.set 7
    local.get 3
    struct.get 55 2
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
      array.new_default 54
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
          array.get 54
          array.set 54
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 58 0
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
            array.get 54
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 54
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
            array.get 54
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
            array.set 54
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
            array.get 54
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
            array.set 54
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
            array.get 54
            local.get 19
            v128.bitselect
            array.set 54
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
        array.get 54
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
        array.get 54
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 54
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 58 1
  )
  (func (;4;) (type 31) (param eqref) (result eqref)
    (local (ref 58))
    local.get 0
    ref.cast (ref 58)
    local.set 1
    local.get 1
    struct.get 58 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 58 2
    local.get 1
    struct.get 58 0
    i32.const 0
    local.get 1
    struct.get 58 1
    struct.new 55
  )
  (func (;5;) (type 32) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;6;) (type 33) (result eqref)
    call 1
  )
  (func (;7;) (type 34) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;8;) (type 35) (param eqref eqref)
    local.get 0
    local.get 1
    call 3
  )
  (func (;9;) (type 36) (param eqref) (result eqref)
    local.get 0
    call 4
  )
  (func (;10;) (type 38) (param (ref 37) i32)
    (local i32)
    local.get 0
    ref.cast (ref 37)
    struct.get 37 0
    call 7
    local.set 2
    local.get 2
    i32.const 1048576
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i32.const 1048576
      local.get 2
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;11;) (type 40) (param (ref 37))
    local.get 0
    ref.cast (ref 37)
    struct.get 37 1
    i32.const 64
    i32.ge_u
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;12;) (type 42) (param (ref 37) eqref)
    local.get 0
    local.get 1
    call 5
    call 10
    local.get 0
    ref.cast (ref 37)
    struct.get 37 0
    local.get 1
    call 8
  )
  (func (;13;) (type 43) (param eqref) (result eqref)
    (local eqref)
    call 6
    local.set 1
    local.get 1
    i32.const 0
    struct.new 37
    local.get 0
    call 14
    local.get 1
    call 9
  )
  (func (;14;) (type 44) (param (ref 37) eqref)
    local.get 0
    ref.cast (ref 37)
    call 11
    local.get 1
    ref.cast (ref 45)
    local.get 0
    ref.cast (ref 37)
    struct.get 37 0
    local.get 0
    ref.cast (ref 37)
    struct.get 37 1
    i32.const 1
    i32.add
    struct.new 37
    call 16
  )
  (func (;15;) (type 46))
  (func (;16;) (type 47) (param (ref 45) (ref 37))
    (local i32 i32)
    i32.const 0
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 2
            local.get 2
            i32.const 4097
            i32.lt_u
            if ;; label = @5
              local.get 1
              ref.cast (ref 37)
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
              array.new_fixed 54 16
              i32.const 0
              i32.const 256
              struct.new 55
              call 12
              local.get 2
              i32.const 1
              i32.add
              local.set 3
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 15
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;17;) (type 48)
    (local eqref)
    struct.new 45
    call 13
    local.set 0
  )
)
