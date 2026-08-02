(module
  (type (;0;) (func (param eqref eqref) (result i32)))
  (type (;1;) (func (param eqref eqref) (result i32)))
  (type (;2;) (func (param eqref eqref) (result i32)))
  (type (;3;) (func (param eqref eqref) (result i32)))
  (type (;4;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;5;) (func (param i32 eqref) (result i32)))
  (type (;6;) (func (result i32)))
  (type (;7;) (array (mut v128)))
  (type (;8;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;10;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;11;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 4)))
  (memory (;0;) 1)
  (export "main" (func 6))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param eqref eqref) (result i32)
    (local (ref 8) (ref 8) (ref 7) (ref 7) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 8)
    local.set 2
    local.get 1
    ref.cast (ref 8)
    local.set 3
    local.get 2
    struct.get 8 2
    local.set 6
    local.get 3
    struct.get 8 2
    local.tee 7
    local.get 6
    i32.gt_u
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 8 0
    local.set 4
    local.get 3
    struct.get 8 0
    local.set 5
    local.get 2
    struct.get 8 1
    local.set 8
    local.get 3
    struct.get 8 1
    local.set 9
    i32.const 0
    local.set 10
    loop ;; label = @1
      local.get 10
      local.get 7
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 7
      local.get 10
      i32.sub
      i32.const 16
      i32.ge_u
      if ;; label = @2
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 7
          local.set 11
        else
          local.get 4
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 7
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 7
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
        local.get 9
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 9
          i32.const 4
          i32.shr_u
          array.get 7
          local.set 12
        else
          local.get 5
          local.get 9
          i32.const 4
          i32.shr_u
          array.get 7
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 9
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 9
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 7
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
          local.set 12
        end
        local.get 11
        local.get 12
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        local.get 10
        i32.const 16
        i32.add
        local.set 10
        br 1 (;@1;)
      end
      local.get 4
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 7
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 9
      i32.const 4
      i32.shr_u
      array.get 7
      local.get 9
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
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      local.get 10
      i32.const 1
      i32.add
      local.set 10
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;2;) (type 1) (param eqref eqref) (result i32)
    (local (ref 8) (ref 8) (ref 7) (ref 7) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 8)
    local.set 2
    local.get 1
    ref.cast (ref 8)
    local.set 3
    local.get 2
    struct.get 8 2
    local.set 6
    local.get 3
    struct.get 8 2
    local.tee 7
    local.get 6
    i32.gt_u
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 8 0
    local.set 4
    local.get 3
    struct.get 8 0
    local.set 5
    local.get 2
    struct.get 8 1
    local.get 6
    local.get 7
    i32.sub
    i32.add
    local.set 8
    local.get 3
    struct.get 8 1
    local.set 9
    i32.const 0
    local.set 10
    loop ;; label = @1
      local.get 10
      local.get 7
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 7
      local.get 10
      i32.sub
      i32.const 16
      i32.ge_u
      if ;; label = @2
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 7
          local.set 11
        else
          local.get 4
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 7
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 7
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
        local.get 9
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 9
          i32.const 4
          i32.shr_u
          array.get 7
          local.set 12
        else
          local.get 5
          local.get 9
          i32.const 4
          i32.shr_u
          array.get 7
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 9
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 9
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 7
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
          local.set 12
        end
        local.get 11
        local.get 12
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        local.get 10
        i32.const 16
        i32.add
        local.set 10
        br 1 (;@1;)
      end
      local.get 4
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 7
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 9
      i32.const 4
      i32.shr_u
      array.get 7
      local.get 9
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
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      local.get 10
      i32.const 1
      i32.add
      local.set 10
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;3;) (type 2) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;4;) (type 3) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 2
  )
  (func (;5;) (type 5) (param i32 eqref) (result i32)
    (local (ref 9) (ref 7) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 9)
    local.set 2
    local.get 2
    struct.get 9 0
    local.set 3
    local.get 2
    struct.get 9 1
    local.set 4
    local.get 2
    struct.get 9 2
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
              array.get 7
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
              array.get 7
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
              array.get 7
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
              array.get 7
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
                array.get 7
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 7
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
                array.get 7
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
            array.get 7
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
  (func (;6;) (type 6) (result i32)
    (local eqref)
    v128.const i32x4 0x66657270 0x6d2d7869 0x6c646469 0x75732d65
    v128.const i32x4 0x78696666 0x00000000 0x00000000 0x00000000
    array.new_fixed 7 2
    i32.const 0
    i32.const 20
    struct.new 8
    local.set 0
    local.get 0
    v128.const i32x4 0x66657270 0x00007869 0x00000000 0x00000000
    array.new_fixed 7 1
    i32.const 0
    i32.const 6
    struct.new 8
    call 3
    if (result i32) ;; label = @1
      local.get 0
      v128.const i32x4 0x66667573 0x00007869 0x00000000 0x00000000
      array.new_fixed 7 1
      i32.const 0
      i32.const 6
      struct.new 8
      call 4
      if (result i32) ;; label = @2
        i32.const 1
        v128.const i32x4 0x74786574 0x6572703a 0x2d786966 0x66667573
        v128.const i32x4 0x00007869 0x00000000 0x00000000 0x00000000
        array.new_fixed 7 2
        i32.const 0
        i32.const 18
        struct.new 9
        call 5
      else
        i32.const 1
        v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
        array.new_fixed 7 1
        i32.const 0
        i32.const 4
        struct.new 9
        call 5
      end
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 7 1
      i32.const 0
      i32.const 4
      struct.new 9
      call 5
    end
  )
)
