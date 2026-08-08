(module
  (type (;0;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;1;) (func (param i32 eqref) (result i32)))
  (type (;2;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;3;) (sub (struct (field i32))))
  (type (;4;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;5;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;6;) (struct (field (ref 2)) (field (ref 3))))
  (type (;7;) (func (param (ref 2)) (result i64)))
  (type (;8;) (func (param (ref 2) (ref 2)) (result i32)))
  (type (;9;) (func (param (ref 3)) (result i64)))
  (type (;10;) (func (param (ref 3) (ref 3)) (result i32)))
  (type (;11;) (func (param (ref 6)) (result i64)))
  (type (;12;) (func (param (ref 6) (ref 6)) (result i32)))
  (type (;13;) (func (result (ref 3))))
  (type (;14;) (func (param i32) (result (ref 3))))
  (type (;15;) (func (result i32)))
  (type (;16;) (func (param (ref 6) (ref 6)) (result i32)))
  (type (;17;) (func (param (ref 6)) (result i64)))
  (type (;18;) (func (param (ref 3) (ref 3)) (result i32)))
  (type (;19;) (func (param (ref 2) (ref 2)) (result i32)))
  (type (;20;) (func (param (ref 2)) (result i64)))
  (type (;21;) (func (param (ref 3)) (result i64)))
  (type (;22;) (array (mut v128)))
  (type (;23;) (struct (field (ref 22)) (field i32) (field i32)))
  (type (;24;) (struct (field (ref 22)) (field i32) (field i32)))
  (type (;25;) (struct (field (ref 22)) (field i32) (field i32)))
  (type (;26;) (struct (field (mut (ref 22))) (field (mut i32)) (field (mut i32))))
  (type (;27;) (struct (field (mut (ref 22))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 0)))
  (memory (;0;) 1)
  (export "main" (func 4))
  (export "memory" (memory 0))
  (func (;1;) (type 1) (param i32 eqref) (result i32)
    (local (ref 24) (ref 22) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 24)
    local.set 2
    local.get 2
    struct.get 24 0
    local.set 3
    local.get 2
    struct.get 24 1
    local.set 4
    local.get 2
    struct.get 24 2
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
              array.get 22
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
              array.get 22
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
              array.get 22
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
              array.get 22
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
                array.get 22
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 22
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
                array.get 22
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
            array.get 22
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
  (func (;2;) (type 13) (result (ref 3))
    i32.const 0
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;3;) (type 14) (param i32) (result (ref 3))
    i32.const 1
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    ref.cast (ref 3)
  )
  (func (;4;) (type 15) (result i32)
    (local (ref 6) (ref 6) (ref 6) i32)
    i32.const 3
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 4
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 2
    i32.const 1
    i32.const 5
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    struct.new 6
    local.set 0
    i32.const 3
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 4
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 2
    i32.const 1
    i32.const 5
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    struct.new 6
    local.set 1
    i32.const 3
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 9
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 2
    i32.const 2
    i32.const 5
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 5
    struct.new 6
    local.set 2
    local.get 0
    local.get 1
    call 5
    if (result i32) ;; label = @1
      local.get 0
      local.get 2
      call 5
      i32.eqz
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      call 6
      local.get 1
      call 6
      i64.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      call 2
      call 2
      call 7
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      call 2
      i32.const 0
      call 3
      call 7
      i32.eqz
    else
      i32.const 0
    end
    local.set 3
    local.get 3
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x69726564 0x683a6576 0x00687361 0x00000000
      array.new_fixed 22 1
      i32.const 0
      i32.const 11
      struct.new 24
      call 1
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 22 1
      i32.const 0
      i32.const 4
      struct.new 24
      call 1
    end
  )
  (func (;5;) (type 16) (param (ref 6) (ref 6)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      struct.get 6 0
      local.get 1
      struct.get 6 0
      call 8
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      struct.get 6 1
      local.get 1
      struct.get 6 1
      call 7
    else
      i32.const 0
    end
  )
  (func (;6;) (type 17) (param (ref 6)) (result i64)
    i64.const -3750763034362895579
    local.get 0
    struct.get 6 0
    call 9
    i64.xor
    i64.const 1099511628211
    i64.mul
    local.get 0
    struct.get 6 1
    call 10
    i64.xor
    i64.const 1099511628211
    i64.mul
  )
  (func (;7;) (type 18) (param (ref 3) (ref 3)) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32 eqref i32)
    local.get 0
    local.set 12
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 12
              ref.cast (ref 3)
              struct.get 3 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            local.get 1
            local.set 6
            block ;; label = @5
              local.get 6
              ref.cast (ref 3)
              struct.get 3 0
              i32.const 0
              i32.eq
              if ;; label = @6
                i32.const 1
                local.set 7
                br 1 (;@5;)
              end
              i32.const 1
              if ;; label = @6
                i32.const 0
                local.set 7
                br 1 (;@5;)
              end
              unreachable
            end
            local.get 7
            local.set 13
            br 3 (;@1;)
          end
          local.get 12
          ref.cast (ref 4)
          struct.get 4 1
          local.set 2
          local.get 1
          local.set 8
          block ;; label = @4
            local.get 8
            ref.cast (ref 3)
            struct.get 3 0
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 8
              ref.cast (ref 4)
              struct.get 4 1
              local.set 3
              i32.const 1
              if (result i32) ;; label = @6
                local.get 2
                local.get 3
                i32.eq
              else
                i32.const 0
              end
              local.set 9
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              i32.const 0
              local.set 9
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 9
          local.set 13
          br 2 (;@1;)
        end
        local.get 12
        ref.cast (ref 5)
        struct.get 5 1
        local.set 4
        local.get 1
        local.set 10
        block ;; label = @3
          local.get 10
          ref.cast (ref 3)
          struct.get 3 0
          i32.const 2
          i32.eq
          if ;; label = @4
            local.get 10
            ref.cast (ref 5)
            struct.get 5 1
            local.set 5
            i32.const 1
            if (result i32) ;; label = @5
              local.get 4
              local.get 5
              i32.eq
            else
              i32.const 0
            end
            local.set 11
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 11
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 11
        local.set 13
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 13
  )
  (func (;8;) (type 19) (param (ref 2) (ref 2)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      struct.get 2 0
      local.get 1
      struct.get 2 0
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      struct.get 2 6
      local.get 1
      struct.get 2 6
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;9;) (type 20) (param (ref 2)) (result i64)
    i64.const -3750763034362895579
    local.get 0
    struct.get 2 0
    i64.extend_i32_s
    i64.xor
    i64.const 1099511628211
    i64.mul
    local.get 0
    struct.get 2 6
    i64.extend_i32_s
    i64.xor
    i64.const 1099511628211
    i64.mul
  )
  (func (;10;) (type 21) (param (ref 3)) (result i64)
    (local i32 i32 eqref i64)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 3
              ref.cast (ref 3)
              struct.get 3 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i64.const -3750763034362895579
            i64.const 0
            i64.xor
            i64.const 1099511628211
            i64.mul
            local.set 4
            br 3 (;@1;)
          end
          local.get 3
          ref.cast (ref 4)
          struct.get 4 1
          local.set 1
          i64.const -3750763034362895579
          i64.const 1
          i64.xor
          i64.const 1099511628211
          i64.mul
          local.get 1
          i64.extend_i32_s
          i64.xor
          i64.const 1099511628211
          i64.mul
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 5)
        struct.get 5 1
        local.set 2
        i64.const -3750763034362895579
        i64.const 2
        i64.xor
        i64.const 1099511628211
        i64.mul
        local.get 2
        i64.extend_i32_s
        i64.xor
        i64.const 1099511628211
        i64.mul
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
)
