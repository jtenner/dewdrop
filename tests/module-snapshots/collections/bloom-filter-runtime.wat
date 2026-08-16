(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i64) (result i64)))
  (type (;9;) (func (param i64) (result i32)))
  (type (;10;) (func (param i64 i64) (result i64)))
  (type (;11;) (func (param i64 i64) (result i32)))
  (type (;12;) (func (param i64 eqref) (result i64)))
  (type (;13;) (func (param i64 eqref) (result i32)))
  (type (;14;) (func (param i64 eqref) (result i64)))
  (type (;15;) (func (param i64 eqref) (result i32)))
  (type (;16;) (func (param eqref eqref) (result i32)))
  (type (;17;) (func (param eqref) (result i64)))
  (type (;18;) (func (param eqref) (result i64)))
  (type (;19;) (func (param eqref eqref) (result i32)))
  (type (;20;) (func (param eqref eqref) (result i32)))
  (type (;21;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;22;) (func (param i32 eqref) (result i32)))
  (type (;23;) (func (result i32)))
  (type (;24;) (sub (struct (field funcref))))
  (type (;25;) (func (param eqref) (result eqref)))
  (type (;26;) (func (param eqref i32) (result eqref)))
  (type (;27;) (func (param eqref eqref) (result eqref)))
  (type (;28;) (func (param eqref)))
  (type (;29;) (func (param eqref i32)))
  (type (;30;) (func (param eqref) (result i32)))
  (type (;31;) (func (param eqref i32) (result i32)))
  (type (;32;) (func (param eqref eqref i32) (result eqref)))
  (type (;33;) (func (param eqref eqref eqref) (result eqref)))
  (type (;34;) (func (param eqref eqref)))
  (type (;35;) (func (param eqref eqref i32)))
  (type (;36;) (func (param eqref eqref) (result i32)))
  (type (;37;) (func (param eqref eqref i32) (result i32)))
  (type (;38;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;39;) (array (mut v128)))
  (type (;40;) (struct (field (ref 39)) (field i32) (field i32)))
  (type (;41;) (struct (field (ref 39)) (field i32) (field i32)))
  (type (;42;) (struct (field (ref 39)) (field i32) (field i32)))
  (type (;43;) (struct (field (mut (ref 39))) (field (mut i32)) (field (mut i32))))
  (type (;44;) (struct (field (mut (ref 39))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 21)))
  (memory (;0;) 1)
  (export "main" (func 13))
  (export "memory" (memory 0))
  (func (;1;) (type 8) (param i64) (result i64)
    i64.const 1
    local.get 0
    i64.const 63
    i64.and
    i64.shl
    i64.const 1
    local.get 0
    i64.const 32
    i64.shr_u
    i64.const 63
    i64.and
    i64.shl
    i64.or
  )
  (func (;2;) (type 9) (param i64) (result i32)
    local.get 0
    i64.const 0
    i64.eq
  )
  (func (;3;) (type 10) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 1
    i64.or
  )
  (func (;4;) (type 11) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 1
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;5;) (type 14) (param i64 eqref) (result i64)
    local.get 0
    local.get 1
    call 9
    call 3
  )
  (func (;6;) (type 15) (param i64 eqref) (result i32)
    local.get 0
    local.get 1
    call 9
    call 4
  )
  (func (;7;) (type 16) (param eqref eqref) (result i32)
    (local (ref 40) (ref 40) (ref 39) (ref 39) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 40)
    local.set 2
    local.get 1
    ref.cast (ref 40)
    local.set 3
    local.get 2
    struct.get 40 2
    local.tee 6
    local.get 3
    struct.get 40 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 40 0
    local.set 4
    local.get 3
    struct.get 40 0
    local.set 5
    local.get 2
    struct.get 40 1
    local.set 7
    local.get 3
    struct.get 40 1
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
          array.get 39
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 39
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
          array.get 39
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
          array.get 39
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 39
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
          array.get 39
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
      array.get 39
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
      array.get 39
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
  (func (;8;) (type 17) (param eqref) (result i64)
    (local (ref 40) (ref 39) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 40)
    local.set 1
    local.get 1
    struct.get 40 0
    local.set 2
    local.get 1
    struct.get 40 1
    local.set 3
    local.get 1
    struct.get 40 2
    local.set 4
    i32.const 0
    local.set 5
    i64.const -3750763034362895579
    local.set 6
    loop ;; label = @1
      local.get 5
      local.get 4
      i32.ge_u
      if ;; label = @2
        local.get 6
        return
      end
      local.get 6
      local.get 2
      local.get 3
      i32.const 4
      i32.shr_u
      array.get 39
      local.get 3
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i64.extend_i32_u
      i64.xor
      i64.const 1099511628211
      i64.mul
      local.set 6
      local.get 3
      i32.const 1
      i32.add
      local.set 3
      local.get 5
      i32.const 1
      i32.add
      local.set 5
      br 0 (;@1;)
    end
    local.get 6
  )
  (func (;9;) (type 18) (param eqref) (result i64)
    local.get 0
    call 8
  )
  (func (;10;) (type 19) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 7
  )
  (func (;11;) (type 20) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 7
  )
  (func (;12;) (type 22) (param i32 eqref) (result i32)
    (local (ref 41) (ref 39) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 41)
    local.set 2
    local.get 2
    struct.get 41 0
    local.set 3
    local.get 2
    struct.get 41 1
    local.set 4
    local.get 2
    struct.get 41 2
    local.set 5
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        local.get 5
        i32.ge_u
        br_if 1 (;@1;)
        local.get 5
        local.get 6
        i32.sub
        local.tee 7
        i32.const 65520
        i32.gt_u
        if ;; label = @3
          i32.const 65520
          local.set 7
        end
        i32.const 0
        local.set 8
        block ;; label = @3
          loop ;; label = @4
            local.get 8
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            local.get 6
            i32.add
            local.get 8
            i32.add
            local.set 9
            local.get 9
            i32.const 15
            i32.and
            i32.eqz
            local.get 8
            i32.const 64
            i32.add
            local.get 7
            i32.le_u
            i32.and
            if ;; label = @5
              i32.const 16
              local.get 8
              i32.add
              local.get 3
              local.get 9
              i32.const 4
              i32.shr_u
              array.get 39
              v128.store
              i32.const 16
              local.get 8
              i32.const 16
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 16
              i32.add
              i32.const 4
              i32.shr_u
              array.get 39
              v128.store
              i32.const 16
              local.get 8
              i32.const 32
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 32
              i32.add
              i32.const 4
              i32.shr_u
              array.get 39
              v128.store
              i32.const 16
              local.get 8
              i32.const 48
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 48
              i32.add
              i32.const 4
              i32.shr_u
              array.get 39
              v128.store
              local.get 8
              i32.const 64
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 8
            i32.const 16
            i32.add
            local.get 7
            i32.le_u
            if ;; label = @5
              local.get 9
              i32.const 15
              i32.and
              i32.eqz
              if ;; label = @6
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 39
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 39
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.add
                i8x16.swizzle
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                i32.const 1
                i32.add
                array.get 39
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
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
              i32.const 16
              local.get 8
              i32.add
              local.get 11
              v128.store
              local.get 8
              i32.const 16
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 3
            local.get 9
            i32.const 4
            i32.shr_u
            array.get 39
            local.get 9
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            local.set 10
            i32.const 16
            local.get 8
            i32.add
            local.get 10
            i32.store8
            local.get 8
            i32.const 1
            i32.add
            local.set 8
            br 0 (;@4;)
          end
        end
        i32.const 0
        local.set 13
        block ;; label = @3
          loop ;; label = @4
            local.get 13
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            i32.const 0
            i32.const 16
            local.get 13
            i32.add
            i32.store
            i32.const 4
            local.get 7
            local.get 13
            i32.sub
            i32.store
            local.get 0
            i32.const 0
            i32.const 1
            i32.const 8
            call 0
            i32.const 0
            i32.ne
            if ;; label = @5
              unreachable
            end
            i32.const 8
            i32.load
            local.tee 12
            i32.eqz
            local.get 12
            local.get 7
            local.get 13
            i32.sub
            i32.gt_u
            i32.or
            if ;; label = @5
              unreachable
            end
            local.get 13
            local.get 12
            i32.add
            local.set 13
            br 0 (;@4;)
          end
        end
        local.get 6
        local.get 7
        i32.add
        local.set 6
        br 0 (;@2;)
      end
    end
    local.get 6
  )
  (func (;13;) (type 23) (result i32)
    (local i64 i64 i64 i32)
    i64.const 0
    local.set 0
    local.get 0
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 39 1
    i32.const 0
    i32.const 3
    struct.new 40
    call 5
    local.set 1
    local.get 0
    v128.const i32x4 0x00000070 0x00000000 0x00000000 0x00000000
    array.new_fixed 39 1
    i32.const 0
    i32.const 1
    struct.new 40
    call 5
    local.set 2
    local.get 0
    call 2
    if (result i32) ;; label = @1
      local.get 1
      call 2
      i32.eqz
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 1
      v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
      array.new_fixed 39 1
      i32.const 0
      i32.const 3
      struct.new 40
      call 6
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 1
      v128.const i32x4 0x72617473 0x6e696873 0x00000065 0x00000000
      array.new_fixed 39 1
      i32.const 0
      i32.const 9
      struct.new 40
      call 6
      i32.eqz
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 2
      v128.const i32x4 0x00000030 0x00000000 0x00000000 0x00000000
      array.new_fixed 39 1
      i32.const 0
      i32.const 1
      struct.new 40
      call 6
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      v128.const i32x4 0x00000070 0x00000000 0x00000000 0x00000000
      array.new_fixed 39 1
      i32.const 0
      i32.const 1
      struct.new 40
      v128.const i32x4 0x00000030 0x00000000 0x00000000 0x00000000
      array.new_fixed 39 1
      i32.const 0
      i32.const 1
      struct.new 40
      call 11
      i32.eqz
    else
      i32.const 0
    end
    local.set 3
    local.get 3
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x6f6f6c62
      v128.const i32x4 0x69662d6d 0x7265746c 0x00000000 0x00000000
      array.new_fixed 39 2
      i32.const 0
      i32.const 24
      struct.new 41
      call 12
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 39 1
      i32.const 0
      i32.const 4
      struct.new 41
      call 12
    end
  )
)
