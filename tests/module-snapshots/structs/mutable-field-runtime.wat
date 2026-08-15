(module
  (type (;0;) (func (param eqref eqref) (result i32)))
  (type (;1;) (func (param eqref eqref) (result i32)))
  (type (;2;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;3;) (func (param i32 eqref) (result i32)))
  (type (;4;) (struct (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (type (;5;) (struct (field (ref 4))))
  (type (;6;) (struct (field (mut i32)) (field (ref 4))))
  (type (;7;) (func (param (ref 6)) (result (ref 4))))
  (type (;8;) (func (param (ref 6)) (result i32)))
  (type (;9;) (func (param (ref 4) i32)))
  (type (;10;) (func (param eqref) (result eqref)))
  (type (;11;) (func (result i32)))
  (type (;12;) (array (mut v128)))
  (type (;13;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;16;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (type (;17;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 2)))
  (memory (;0;) 1)
  (export "main" (func 7))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param eqref eqref) (result i32)
    (local (ref 13) (ref 13) (ref 12) (ref 12) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 13)
    local.set 2
    local.get 1
    ref.cast (ref 13)
    local.set 3
    local.get 2
    struct.get 13 2
    local.tee 6
    local.get 3
    struct.get 13 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 13 0
    local.set 4
    local.get 3
    struct.get 13 0
    local.set 5
    local.get 2
    struct.get 13 1
    local.set 7
    local.get 3
    struct.get 13 1
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
          array.get 12
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 12
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
          array.get 12
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
          array.get 12
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 12
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
          array.get 12
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
      array.get 12
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
      array.get 12
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
  (func (;2;) (type 1) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;3;) (type 3) (param i32 eqref) (result i32)
    (local (ref 14) (ref 12) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 14)
    local.set 2
    local.get 2
    struct.get 14 0
    local.set 3
    local.get 2
    struct.get 14 1
    local.set 4
    local.get 2
    struct.get 14 2
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
              array.get 12
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
              array.get 12
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
              array.get 12
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
              array.get 12
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
                array.get 12
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 12
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
                array.get 12
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
            array.get 12
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
  (func (;4;) (type 7) (param (ref 6)) (result (ref 4))
    local.get 0
    local.get 0
    struct.get 6 0
    i32.const 1
    i32.add
    struct.set 6 0
    local.get 0
    struct.get 6 1
    ref.cast (ref 4)
  )
  (func (;5;) (type 8) (param (ref 6)) (result i32)
    local.get 0
    struct.get 6 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x65636572 0x72657669 0x73756d20 0x75722074
    v128.const i32x4 0x6966206e 0x20747372 0x20646e61 0x65636e6f
    array.new_fixed 12 2
    i32.const 0
    i32.const 32
    struct.new 13
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.get 0
    struct.get 6 0
    i32.const 1
    i32.add
    struct.set 6 0
    i32.const 43
  )
  (func (;6;) (type 9) (param (ref 4) i32)
    local.get 0
    local.get 1
    struct.set 4 0
  )
  (func (;7;) (type 11) (result i32)
    (local (ref 4) (ref 5) (ref 6) (ref 4) (ref 4))
    i32.const 1
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    local.set 0
    local.get 0
    i32.const 40
    call 6
    local.get 0
    ref.cast (ref 4)
    struct.new 5
    local.set 1
    local.get 1
    ref.cast (ref 5)
    struct.get 5 0
    i32.const 42
    struct.set 4 0
    local.get 0
    i32.const 43
    struct.set 4 0
    i32.const 0
    local.get 0
    ref.cast (ref 4)
    struct.new 6
    local.set 2
    local.get 2
    call 4
    local.get 2
    call 5
    struct.set 4 0
    i32.const 0
    i64.const 1
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    local.set 3
    local.get 3
    ref.cast (ref 4)
    i64.const 44
    struct.set 4 1
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    v128.const i32x4 0x6f666562 0x00006572 0x00000000 0x00000000
    array.new_fixed 12 1
    i32.const 0
    i32.const 6
    struct.new 13
    struct.new 4
    local.set 4
    local.get 4
    ref.cast (ref 4)
    v128.const i32x4 0x65746661 0x00000072 0x00000000 0x00000000
    array.new_fixed 12 1
    i32.const 0
    i32.const 5
    struct.new 13
    struct.set 4 5
    local.get 2
    ref.cast (ref 6)
    struct.get 6 0
    i32.const 2
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      struct.get 4 0
      i32.const 43
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 3
      struct.get 4 1
      i64.const 44
      i64.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 4
      struct.get 4 5
      v128.const i32x4 0x65746661 0x00000072 0x00000000 0x00000000
      array.new_fixed 12 1
      i32.const 0
      i32.const 5
      struct.new 13
      call 2
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x75727473 0x6d3a7463 0x62617475 0x662d656c
      v128.const i32x4 0x646c6569 0x0033342d 0x00000000 0x00000000
      array.new_fixed 12 2
      i32.const 0
      i32.const 23
      struct.new 14
      call 3
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 12 1
      i32.const 0
      i32.const 4
      struct.new 14
      call 3
    end
  )
)
