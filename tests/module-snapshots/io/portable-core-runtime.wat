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
  (type (;9;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;10;) (sub final 8 (struct (field i32) (field i32))))
  (type (;11;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;12;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;13;) (func (param i32) (result eqref)))
  (type (;14;) (func (param eqref eqref)))
  (type (;15;) (func (param eqref) (result eqref)))
  (type (;16;) (func (param eqref) (result i32)))
  (type (;17;) (func (param eqref eqref) (result i32)))
  (type (;18;) (func (param eqref i32 i32) (result eqref)))
  (type (;19;) (func (param i32) (result eqref)))
  (type (;20;) (func (param eqref eqref)))
  (type (;21;) (func (param eqref) (result eqref)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref eqref) (result i32)))
  (type (;24;) (func (param eqref i32 i32) (result eqref)))
  (type (;25;) (sub (struct (field i32))))
  (type (;26;) (sub final 25 (struct (field i32) (field i32))))
  (type (;27;) (struct (field eqref) (field (ref 0))))
  (type (;28;) (struct (field eqref) (field (ref 0))))
  (type (;29;) (func (param eqref i32) (result (ref 8))))
  (type (;30;) (func (param eqref eqref) (result (ref 8))))
  (type (;31;) (func (param eqref) (result (ref 27))))
  (type (;32;) (func (param (ref 27) i32) (result (ref 8))))
  (type (;33;) (func (result (ref 28))))
  (type (;34;) (func (param i32) (result (ref 28))))
  (type (;35;) (func (param (ref 28)) (result i32)))
  (type (;36;) (func (param (ref 28)) (result i32)))
  (type (;37;) (func (param (ref 28)) (result (ref 8))))
  (type (;38;) (func (param (ref 28) eqref) (result (ref 8))))
  (type (;39;) (func (param eqref i32) (result (ref 8))))
  (type (;40;) (func (param eqref eqref) (result (ref 8))))
  (type (;41;) (func (result i32)))
  (type (;42;) (array (mut v128)))
  (type (;43;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;44;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;46;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (type (;47;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 22))
  (func (;0;) (type 13) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 42
    i32.const 0
    i32.const 0
    struct.new 47
  )
  (func (;1;) (type 14) (param eqref eqref)
    (local (ref 47) (ref 44) (ref 42) (ref 42) i32 i32 i32 i32 i32 i32 (ref 42) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 47)
    local.set 2
    local.get 2
    struct.get 47 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 44)
    local.set 3
    local.get 2
    struct.get 47 0
    local.set 4
    local.get 3
    struct.get 44 0
    local.set 5
    local.get 2
    struct.get 47 1
    local.set 6
    local.get 3
    struct.get 44 1
    local.set 7
    local.get 3
    struct.get 44 2
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
      array.new_default 42
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
          array.get 42
          array.set 42
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 47 0
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
            array.get 42
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 42
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
            array.get 42
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
            array.set 42
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
            array.get 42
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
            array.set 42
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
            array.get 42
            local.get 19
            v128.bitselect
            array.set 42
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
        array.get 42
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
        array.get 42
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 42
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 47 1
  )
  (func (;2;) (type 15) (param eqref) (result eqref)
    (local (ref 47))
    local.get 0
    ref.cast (ref 47)
    local.set 1
    local.get 1
    struct.get 47 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 47 2
    local.get 1
    struct.get 47 0
    i32.const 0
    local.get 1
    struct.get 47 1
    struct.new 44
  )
  (func (;3;) (type 16) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 44)
    struct.get 44 2
  )
  (func (;4;) (type 17) (param eqref eqref) (result i32)
    (local (ref 44) (ref 44) (ref 42) (ref 42) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 44)
    local.set 2
    local.get 1
    ref.cast (ref 44)
    local.set 3
    local.get 2
    struct.get 44 2
    local.tee 6
    local.get 3
    struct.get 44 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 44 0
    local.set 4
    local.get 3
    struct.get 44 0
    local.set 5
    local.get 2
    struct.get 44 1
    local.set 7
    local.get 3
    struct.get 44 1
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
          array.get 42
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 42
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
          array.get 42
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
          array.get 42
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 42
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
          array.get 42
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
      array.get 42
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
      array.get 42
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
  (func (;5;) (type 18) (param eqref i32 i32) (result eqref)
    (local (ref 44) i32)
    local.get 0
    ref.cast (ref 44)
    local.set 3
    local.get 3
    struct.get 44 2
    local.set 4
    local.get 1
    local.get 4
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    local.get 4
    local.get 1
    i32.sub
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    struct.get 44 0
    local.get 3
    struct.get 44 1
    local.get 1
    i32.add
    local.get 2
    struct.new 44
  )
  (func (;6;) (type 19) (param i32) (result eqref)
    local.get 0
    call 0
  )
  (func (;7;) (type 20) (param eqref eqref)
    local.get 0
    local.get 1
    call 1
  )
  (func (;8;) (type 21) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;9;) (type 22) (param eqref) (result i32)
    local.get 0
    call 3
  )
  (func (;10;) (type 23) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;11;) (type 24) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 5
  )
  (func (;12;) (type 31) (param eqref) (result (ref 27))
    (local eqref i32)
    local.get 0
    i32.const 1
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    ref.cast (ref 0)
    struct.new 27
    ref.cast (ref 27)
  )
  (func (;13;) (type 32) (param (ref 27) i32) (result (ref 8))
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 27)
    struct.get 27 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.set 2
    local.get 0
    ref.cast (ref 27)
    struct.get 27 0
    call 9
    local.set 3
    local.get 2
    local.get 3
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 2
      struct.new 25
      struct.new 11
    else
      local.get 1
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 2
        local.get 3
        i32.eq
      end
      if (result eqref) ;; label = @2
        i32.const 0
        array.new_fixed 42 0
        i32.const 0
        i32.const 0
        struct.new 44
        struct.new 9
      else
        local.get 3
        local.get 2
        i32.sub
        local.set 4
        local.get 1
        local.get 4
        i32.lt_u
        if (result i32) ;; label = @3
          local.get 1
        else
          local.get 4
        end
        local.set 5
        local.get 0
        ref.cast (ref 27)
        struct.get 27 1
        ref.cast (ref 0)
        i32.const 0
        local.get 2
        local.get 5
        i32.add
        array.set 0
        i32.const 0
        local.get 0
        ref.cast (ref 27)
        struct.get 27 0
        local.get 2
        local.get 5
        call 11
        struct.new 9
      end
    end
    ref.cast (ref 8)
  )
  (func (;14;) (type 33) (result (ref 28))
    i32.const 0
    call 15
    ref.cast (ref 28)
  )
  (func (;15;) (type 34) (param i32) (result (ref 28))
    (local eqref i32)
    local.get 0
    call 6
    i32.const 2
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    ref.cast (ref 0)
    struct.new 28
    ref.cast (ref 28)
  )
  (func (;16;) (type 35) (param (ref 28)) (result i32)
    local.get 0
    ref.cast (ref 28)
    struct.get 28 1
    ref.cast (ref 0)
    i32.const 1
    array.get 0
  )
  (func (;17;) (type 36) (param (ref 28)) (result i32)
    local.get 0
    ref.cast (ref 28)
    struct.get 28 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
  )
  (func (;18;) (type 37) (param (ref 28)) (result (ref 8))
    local.get 0
    call 17
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 3
      struct.new 25
      struct.new 11
    else
      local.get 0
      ref.cast (ref 28)
      struct.get 28 1
      ref.cast (ref 0)
      i32.const 0
      i32.const 1
      array.set 0
      i32.const 0
      local.get 0
      ref.cast (ref 28)
      struct.get 28 0
      call 8
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;19;) (type 38) (param (ref 28) eqref) (result (ref 8))
    (local i32 i32)
    local.get 0
    call 17
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 3
      struct.new 25
      struct.new 11
    else
      local.get 1
      call 9
      local.set 2
      local.get 0
      call 16
      local.set 3
      local.get 2
      i32.const -1
      local.get 3
      i32.sub
      i32.gt_u
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 4
        struct.new 25
        struct.new 11
      else
        local.get 0
        ref.cast (ref 28)
        struct.get 28 0
        local.get 1
        call 7
        local.get 0
        ref.cast (ref 28)
        struct.get 28 1
        ref.cast (ref 0)
        i32.const 1
        local.get 3
        local.get 2
        i32.add
        array.set 0
        i32.const 0
        local.get 2
        struct.new 10
      end
    end
    ref.cast (ref 8)
  )
  (func (;20;) (type 39) (param eqref i32) (result (ref 8))
    (local eqref i32 eqref i32 (ref 25) eqref i32 eqref)
    local.get 1
    call 6
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 1
            i32.lt_u
            if ;; label = @5
              local.get 0
              ref.cast (ref 27)
              local.get 1
              local.get 3
              i32.sub
              call 13
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 8)
                      struct.get 8 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 9)
                    struct.get 9 1
                    local.set 4
                    local.get 4
                    call 9
                    local.set 5
                    local.get 5
                    i32.const 0
                    i32.eq
                    if ;; label = @9
                      i32.const 1
                      i32.const 0
                      struct.new 25
                      struct.new 11
                      local.set 9
                      br 8 (;@1;)
                    else
                      local.get 5
                      local.get 1
                      local.get 3
                      i32.sub
                      i32.gt_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 2
                        struct.new 25
                        struct.new 11
                        local.set 9
                        br 9 (;@1;)
                      else
                        local.get 2
                        local.get 4
                        call 7
                        local.get 3
                        local.get 5
                        i32.add
                        local.set 8
                        br 8 (;@2;)
                      end
                    end
                    br 2 (;@6;)
                  end
                  local.get 7
                  ref.cast (ref 11)
                  struct.get 11 1
                  ref.cast (ref 25)
                  local.set 6
                  i32.const 1
                  local.get 6
                  struct.new 11
                  local.set 9
                  br 6 (;@1;)
                  br 1 (;@6;)
                end
                unreachable
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.get 2
            call 8
            struct.new 9
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 8)
  )
  (func (;21;) (type 40) (param eqref eqref) (result (ref 8))
    (local i32 i32 eqref i32 (ref 25) eqref i32 eqref)
    local.get 1
    call 9
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 1
              local.get 3
              local.get 2
              local.get 3
              i32.sub
              call 11
              local.set 4
              local.get 0
              ref.cast (ref 28)
              local.get 4
              call 19
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 8)
                      struct.get 8 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 10)
                    struct.get 10 1
                    local.set 5
                    local.get 5
                    i32.const 0
                    i32.eq
                    if ;; label = @9
                      i32.const 1
                      i32.const 1
                      struct.new 25
                      struct.new 11
                      local.set 9
                      br 8 (;@1;)
                    else
                      local.get 5
                      local.get 2
                      local.get 3
                      i32.sub
                      i32.gt_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 2
                        struct.new 25
                        struct.new 11
                        local.set 9
                        br 9 (;@1;)
                      else
                        local.get 3
                        local.get 5
                        i32.add
                        local.set 8
                        br 8 (;@2;)
                      end
                    end
                    br 2 (;@6;)
                  end
                  local.get 7
                  ref.cast (ref 11)
                  struct.get 11 1
                  ref.cast (ref 25)
                  local.set 6
                  i32.const 1
                  local.get 6
                  struct.new 11
                  local.set 9
                  br 6 (;@1;)
                  br 1 (;@6;)
                end
                unreachable
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.get 2
            struct.new 10
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 8)
  )
  (func (;22;) (type 41) (result i32)
    (local eqref eqref eqref eqref eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x74726f70 0x656c6261 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 8
    struct.new 44
    call 12
    local.set 0
    call 14
    local.set 1
    local.get 0
    i32.const 8
    call 20
    local.set 8
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 8
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 8
          ref.cast (ref 9)
          struct.get 9 1
          local.set 2
          local.get 1
          local.get 2
          call 21
          local.set 6
          block ;; label = @4
            local.get 6
            ref.cast (ref 8)
            struct.get 8 0
            i32.const 0
            i32.eq
            if (result i32) ;; label = @5
              local.get 6
              ref.cast (ref 10)
              struct.get 10 1
              i32.const 8
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 1
              ref.cast (ref 28)
              call 18
              local.set 4
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 4
                      ref.cast (ref 8)
                      struct.get 8 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 4
                    ref.cast (ref 9)
                    struct.get 9 1
                    local.set 3
                    local.get 3
                    v128.const i32x4 0x74726f70 0x656c6261 0x00000000 0x00000000
                    array.new_fixed 42 1
                    i32.const 0
                    i32.const 8
                    struct.new 44
                    call 10
                    local.set 5
                    br 2 (;@6;)
                  end
                  i32.const 0
                  local.set 5
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 5
              local.set 7
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              i32.const 0
              local.set 7
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 7
          local.set 9
          br 2 (;@1;)
        end
        i32.const 0
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
  )
)
