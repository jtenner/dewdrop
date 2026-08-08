(module
  (type (;0;) (func (param i32 eqref) (result i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i32)))
  (type (;3;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;4;) (func (param i32 eqref) (result i32)))
  (type (;5;) (struct))
  (type (;6;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;7;) (struct))
  (type (;8;) (func (param (ref 6) (ref 6)) (result i32)))
  (type (;9;) (func (param (ref 6) (ref 6)) (result i32)))
  (type (;10;) (func (param (ref 6))))
  (type (;11;) (func (param (ref 6)) (result i64)))
  (type (;12;) (func (param (ref 6) (ref 6)) (result i32)))
  (type (;13;) (func (param (ref 7) (ref 7)) (result i32)))
  (type (;14;) (func (param (ref 7) (ref 7)) (result i32)))
  (type (;15;) (func (param (ref 7))))
  (type (;16;) (func (param (ref 7)) (result i64)))
  (type (;17;) (func (param (ref 7) (ref 7)) (result i32)))
  (type (;18;) (func (result (ref 6))))
  (type (;19;) (func (result (ref 7))))
  (type (;20;) (func (result i32)))
  (type (;21;) (func (param (ref 6) (ref 6)) (result i32)))
  (type (;22;) (func (param (ref 6) (ref 6)) (result i32)))
  (type (;23;) (func (param (ref 6)) (result i64)))
  (type (;24;) (func (param (ref 7) (ref 7)) (result i32)))
  (type (;25;) (func (param (ref 7) (ref 7)) (result i32)))
  (type (;26;) (func (param (ref 7)) (result i64)))
  (type (;27;) (func (param (ref 6))))
  (type (;28;) (func (param (ref 7))))
  (type (;29;) (array (mut v128)))
  (type (;30;) (struct (field (ref 29)) (field i32) (field i32)))
  (type (;31;) (struct (field (ref 29)) (field i32) (field i32)))
  (type (;32;) (struct (field (ref 29)) (field i32) (field i32)))
  (type (;33;) (struct (field (mut (ref 29))) (field (mut i32)) (field (mut i32))))
  (type (;34;) (struct (field (mut (ref 29))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 3)))
  (memory (;0;) 1)
  (export "main" (func 7))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param i32 eqref) (result i32)
    (local (ref 31) (ref 29) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 31)
    local.set 2
    local.get 2
    struct.get 31 0
    local.set 3
    local.get 2
    struct.get 31 1
    local.set 4
    local.get 2
    struct.get 31 2
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
              array.get 29
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
              array.get 29
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
              array.get 29
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
              array.get 29
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
                array.get 29
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 29
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
                array.get 29
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
            array.get 29
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
  (func (;2;) (type 1) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 0
    local.set 0
    i32.const 48
    local.set 1
    local.get 0
    i32.const 0
    i32.lt_s
    local.tee 3
    if (result i32) ;; label = @1
      i32.const 0
      local.get 0
      i32.sub
    else
      local.get 0
    end
    local.set 2
    loop ;; label = @1
      local.get 1
      i32.const 1
      i32.sub
      local.tee 1
      local.get 2
      i32.const 10
      i32.rem_u
      i32.const 48
      i32.add
      i32.store8
      local.get 2
      i32.const 10
      i32.div_u
      local.tee 2
      br_if 0 (;@1;)
    end
    local.get 3
    if ;; label = @1
      local.get 1
      i32.const 1
      i32.sub
      local.tee 1
      i32.const 45
      i32.store8
    end
    i32.const 48
    local.get 1
    i32.sub
    local.set 4
    i32.const 0
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        local.get 5
        local.get 4
        i32.ge_u
        br_if 1 (;@1;)
        i32.const 0
        local.get 1
        local.get 5
        i32.add
        i32.store
        i32.const 4
        local.get 4
        local.get 5
        i32.sub
        i32.store
        i32.const 1
        i32.const 0
        i32.const 1
        i32.const 8
        call 0
        i32.const 0
        i32.ne
        if ;; label = @3
          unreachable
        end
        i32.const 8
        i32.load
        local.tee 6
        i32.eqz
        local.get 6
        local.get 4
        local.get 5
        i32.sub
        i32.gt_u
        i32.or
        if ;; label = @3
          unreachable
        end
        local.get 5
        local.get 6
        i32.add
        local.set 5
        br 0 (;@2;)
      end
    end
    local.get 4
  )
  (func (;3;) (type 2) (param i32)
    local.get 0
    call 2
    drop
  )
  (func (;4;) (type 4) (param i32 eqref) (result i32)
    (local (ref 31) (ref 29) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 31)
    local.set 2
    local.get 2
    struct.get 31 0
    local.set 3
    local.get 2
    struct.get 31 1
    local.set 4
    local.get 2
    struct.get 31 2
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
              array.get 29
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
              array.get 29
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
              array.get 29
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
              array.get 29
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
                array.get 29
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 29
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
                array.get 29
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
            array.get 29
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
  (func (;5;) (type 18) (result (ref 6))
    i32.const 7
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 6
    ref.cast (ref 6)
  )
  (func (;6;) (type 19) (result (ref 7))
    struct.new 7
    ref.cast (ref 7)
  )
  (func (;7;) (type 20) (result i32)
    (local i32 i32)
    call 5
    call 5
    call 8
    if (result i32) ;; label = @1
      call 5
      call 5
      call 9
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      call 5
      call 10
      call 5
      call 10
      i64.eq
    else
      i32.const 0
    end
    local.set 0
    call 6
    call 6
    call 11
    if (result i32) ;; label = @1
      call 6
      call 6
      call 12
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      call 6
      call 13
      call 6
      call 13
      i64.eq
    else
      i32.const 0
    end
    local.set 1
    call 5
    call 14
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 29 1
    i32.const 0
    i32.const 1
    struct.new 31
    call 4
    drop
    call 6
    call 15
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x7265647c 0x3a657669 0x6c656966 0x72702d64
      v128.const i32x4 0x71657265 0x69736975 0x00736574 0x00000000
      array.new_fixed 29 2
      i32.const 0
      i32.const 27
      struct.new 31
      call 4
    else
      i32.const 1
      v128.const i32x4 0x4941467c 0x0000004c 0x00000000 0x00000000
      array.new_fixed 29 1
      i32.const 0
      i32.const 5
      struct.new 31
      call 4
    end
  )
  (func (;8;) (type 21) (param (ref 6) (ref 6)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      struct.get 6 0
      local.get 1
      struct.get 6 0
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;9;) (type 22) (param (ref 6) (ref 6)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      struct.get 6 0
      local.get 1
      struct.get 6 0
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;10;) (type 23) (param (ref 6)) (result i64)
    i64.const -3750763034362895579
    local.get 0
    struct.get 6 0
    i64.extend_i32_s
    i64.xor
    i64.const 1099511628211
    i64.mul
  )
  (func (;11;) (type 24) (param (ref 7) (ref 7)) (result i32)
    i32.const 1
  )
  (func (;12;) (type 25) (param (ref 7) (ref 7)) (result i32)
    i32.const 1
  )
  (func (;13;) (type 26) (param (ref 7)) (result i64)
    i64.const -3750763034362895579
  )
  (func (;14;) (type 27) (param (ref 6))
    i32.const 1
    v128.const i32x4 0x656c6553 0x64657463 0x00207b20 0x00000000
    array.new_fixed 29 1
    i32.const 0
    i32.const 11
    struct.new 31
    call 1
    drop
    i32.const 1
    v128.const i32x4 0x756c6176 0x00203a65 0x00000000 0x00000000
    array.new_fixed 29 1
    i32.const 0
    i32.const 7
    struct.new 31
    call 1
    drop
    local.get 0
    struct.get 6 0
    call 3
    i32.const 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 29 1
    i32.const 0
    i32.const 2
    struct.new 31
    call 1
    drop
  )
  (func (;15;) (type 28) (param (ref 7))
    i32.const 1
    v128.const i32x4 0x6e616850 0x206d6f74 0x00007d7b 0x00000000
    array.new_fixed 29 1
    i32.const 0
    i32.const 10
    struct.new 31
    call 1
    drop
  )
)
