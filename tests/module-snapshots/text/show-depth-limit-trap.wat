(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field funcref))))
  (type (;9;) (func (param eqref) (result eqref)))
  (type (;10;) (func (param eqref i32) (result eqref)))
  (type (;11;) (func (param eqref eqref) (result eqref)))
  (type (;12;) (func (param eqref)))
  (type (;13;) (func (param eqref i32)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (param eqref eqref i32) (result eqref)))
  (type (;17;) (func (param eqref eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref eqref)))
  (type (;19;) (func (param eqref eqref i32)))
  (type (;20;) (func (param eqref eqref) (result i32)))
  (type (;21;) (func (param eqref eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (result eqref)))
  (type (;25;) (func (param eqref) (result i32)))
  (type (;26;) (func (param eqref eqref)))
  (type (;27;) (func (param eqref) (result eqref)))
  (type (;28;) (func (param eqref) (result i32)))
  (type (;29;) (func (result eqref)))
  (type (;30;) (func (param eqref) (result i32)))
  (type (;31;) (func (param eqref eqref)))
  (type (;32;) (func (param eqref) (result eqref)))
  (type (;33;) (struct (field eqref) (field i32)))
  (type (;34;) (func (param (ref 33) i32)))
  (type (;35;) (func (param eqref) (result eqref)))
  (type (;36;) (func (param (ref 33))))
  (type (;37;) (func (param (ref 33) eqref)))
  (type (;38;) (func (param (ref 33) eqref)))
  (type (;39;) (func (param (ref 33) eqref)))
  (type (;40;) (func (param eqref) (result eqref)))
  (type (;41;) (sub (struct (field i32))))
  (type (;42;) (sub final 41 (struct (field i32) (field (ref 41)))))
  (type (;43;) (func (param (ref 41) (ref 33))))
  (type (;44;) (func (param i32) (result (ref 41))))
  (type (;45;) (func))
  (type (;46;) (array (mut v128)))
  (type (;47;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;48;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;49;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;50;) (struct (field (mut (ref 46))) (field (mut i32)) (field (mut i32))))
  (type (;51;) (struct (field (mut (ref 46))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 17))
  (func (;0;) (type 23) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 47)
    struct.get 47 2
  )
  (func (;1;) (type 24) (result eqref)
    i32.const 4
    array.new_default 46
    i32.const 0
    i32.const 0
    struct.new 50
  )
  (func (;2;) (type 25) (param eqref) (result i32)
    (local (ref 50))
    local.get 0
    ref.cast (ref 50)
    local.tee 1
    struct.get 50 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 50 1
  )
  (func (;3;) (type 26) (param eqref eqref)
    (local (ref 50) (ref 47) (ref 46) (ref 46) i32 i32 i32 i32 i32 i32 (ref 46) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 50)
    local.set 2
    local.get 2
    struct.get 50 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 47)
    local.set 3
    local.get 2
    struct.get 50 0
    local.set 4
    local.get 3
    struct.get 47 0
    local.set 5
    local.get 2
    struct.get 50 1
    local.set 6
    local.get 3
    struct.get 47 1
    local.set 7
    local.get 3
    struct.get 47 2
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
      array.new_default 46
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
          array.get 46
          array.set 46
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 50 0
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
            array.get 46
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 46
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
            array.get 46
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
            array.set 46
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
            array.get 46
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
            array.set 46
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
            array.get 46
            local.get 19
            v128.bitselect
            array.set 46
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
        array.get 46
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
        array.get 46
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 46
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 50 1
  )
  (func (;4;) (type 27) (param eqref) (result eqref)
    (local (ref 50))
    local.get 0
    ref.cast (ref 50)
    local.set 1
    local.get 1
    struct.get 50 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 50 2
    local.get 1
    struct.get 50 0
    i32.const 0
    local.get 1
    struct.get 50 1
    struct.new 47
  )
  (func (;5;) (type 28) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;6;) (type 29) (result eqref)
    call 1
  )
  (func (;7;) (type 30) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;8;) (type 31) (param eqref eqref)
    local.get 0
    local.get 1
    call 3
  )
  (func (;9;) (type 32) (param eqref) (result eqref)
    local.get 0
    call 4
  )
  (func (;10;) (type 34) (param (ref 33) i32)
    (local i32)
    local.get 0
    struct.get 33 0
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
  (func (;11;) (type 36) (param (ref 33))
    local.get 0
    struct.get 33 1
    i32.const 64
    i32.ge_u
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;12;) (type 38) (param (ref 33) eqref)
    local.get 0
    local.get 1
    call 5
    call 10
    local.get 0
    struct.get 33 0
    local.get 1
    call 8
  )
  (func (;13;) (type 39) (param (ref 33) eqref)
    local.get 0
    ref.cast (ref 33)
    call 11
    local.get 1
    ref.cast (ref 41)
    local.get 0
    struct.get 33 0
    local.get 0
    struct.get 33 1
    i32.const 1
    i32.add
    struct.new 33
    call 15
  )
  (func (;14;) (type 40) (param eqref) (result eqref)
    (local eqref)
    call 6
    local.set 1
    local.get 1
    i32.const 0
    struct.new 33
    local.get 0
    call 13
    local.get 1
    call 9
  )
  (func (;15;) (type 43) (param (ref 41) (ref 33))
    (local (ref 41) eqref)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 41)
            struct.get 41 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          ref.cast (ref 33)
          v128.const i32x4 0x7473654e 0x6e453a3a 0x00000064 0x00000000
          array.new_fixed 46 1
          i32.const 0
          i32.const 9
          struct.new 47
          call 12
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 42)
        struct.get 42 1
        ref.cast (ref 41)
        local.set 2
        local.get 1
        ref.cast (ref 33)
        v128.const i32x4 0x7473654e 0x6f4d3a3a 0x00286572 0x00000000
        array.new_fixed 46 1
        i32.const 0
        i32.const 11
        struct.new 47
        call 12
        local.get 1
        ref.cast (ref 33)
        local.get 2
        call 13
        local.get 1
        ref.cast (ref 33)
        v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
        array.new_fixed 46 1
        i32.const 0
        i32.const 1
        struct.new 47
        call 12
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;16;) (type 44) (param i32) (result (ref 41))
    local.get 0
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 41
    else
      i32.const 1
      local.get 0
      i32.const 1
      i32.sub
      call 16
      ref.cast (ref 41)
      struct.new 42
    end
    ref.cast (ref 41)
  )
  (func (;17;) (type 45)
    (local eqref)
    i32.const 65
    call 16
    call 14
    local.set 0
  )
)
