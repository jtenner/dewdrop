(module
  (type (;0;) (func (param i32 eqref) (result i32)))
  (type (;1;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;2;) (func (param i32 eqref) (result i32)))
  (type (;3;) (struct (field i32) (field i32)))
  (type (;4;) (sub (struct (field i32))))
  (type (;5;) (sub final 4 (struct (field i32) (field i32))))
  (type (;6;) (sub final 4 (struct (field i32) (field i32) (field i32))))
  (type (;7;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;8;) (func (param (ref 3)) (result i32)))
  (type (;9;) (func (param (ref 4)) (result i32)))
  (type (;10;) (func (param (ref 7)) (result i32)))
  (type (;11;) (func (result i32)))
  (type (;12;) (func (param (ref 7)) (result i32)))
  (type (;13;) (array (mut v128)))
  (type (;14;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;17;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 1)))
  (memory (;0;) 1)
  (export "main" (func 5))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param i32 eqref) (result i32)
    (local (ref 15) (ref 13) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 15)
    local.set 2
    local.get 2
    struct.get 15 0
    local.set 3
    local.get 2
    struct.get 15 1
    local.set 4
    local.get 2
    struct.get 15 2
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
              array.get 13
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
              array.get 13
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
              array.get 13
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
              array.get 13
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
                array.get 13
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 13
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
                array.get 13
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
            array.get 13
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
  (func (;2;) (type 2) (param i32 eqref) (result i32)
    (local (ref 15) (ref 13) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 15)
    local.set 2
    local.get 2
    struct.get 15 0
    local.set 3
    local.get 2
    struct.get 15 1
    local.set 4
    local.get 2
    struct.get 15 2
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
              array.get 13
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
              array.get 13
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
              array.get 13
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
              array.get 13
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
                array.get 13
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 13
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
                array.get 13
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
            array.get 13
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
  (func (;3;) (type 8) (param (ref 3)) (result i32)
    i32.const 1
    v128.const i32x4 0x6e696f50 0x207b2074 0x79202c78 0x00007d20
    array.new_fixed 13 1
    i32.const 0
    i32.const 14
    struct.new 15
    call 1
  )
  (func (;4;) (type 9) (param (ref 4)) (result i32)
    (local eqref eqref)
    i32.const 1
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 4)
              struct.get 4 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
            array.new_fixed 13 1
            i32.const 0
            i32.const 12
            struct.new 15
            local.set 2
            br 3 (;@1;)
          end
          v128.const i32x4 0x696f6843 0x3a3a6563 0x626d754e 0x5f287265
          v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
          array.new_fixed 13 2
          i32.const 0
          i32.const 17
          struct.new 15
          local.set 2
          br 2 (;@1;)
        end
        v128.const i32x4 0x696f6843 0x3a3a6563 0x656d614e 0x207b2064
        v128.const i32x4 0x6562616c 0x61202c6c 0x76697463 0x007d2065
        array.new_fixed 13 2
        i32.const 0
        i32.const 31
        struct.new 15
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
    call 1
  )
  (func (;5;) (type 11) (result i32)
    (local (ref 3) (ref 4) (ref 7))
    i32.const 3
    i32.const 4
    struct.new 3
    local.set 0
    i32.const 2
    i32.const 9
    i32.const 1
    struct.new 6
    local.set 1
    i32.const 42
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 7
    local.set 2
    local.get 0
    call 3
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 1
    i32.const 0
    i32.const 1
    struct.new 15
    call 2
    drop
    i32.const 1
    i32.const 7
    struct.new 5
    call 4
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 1
    i32.const 0
    i32.const 1
    struct.new 15
    call 2
    drop
    local.get 1
    call 4
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 1
    i32.const 0
    i32.const 1
    struct.new 15
    call 2
    drop
    local.get 2
    call 6
  )
  (func (;6;) (type 12) (param (ref 7)) (result i32)
    i32.const 1
    v128.const i32x4 0x70617257 0x20726570 0x6176207b 0x2065756c
    v128.const i32x4 0x0000007d 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 2
    i32.const 0
    i32.const 17
    struct.new 15
    call 1
  )
)
