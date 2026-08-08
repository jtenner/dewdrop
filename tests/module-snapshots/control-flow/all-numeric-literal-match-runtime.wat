(module
  (type (;0;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;1;) (func (param i32 eqref) (result i32)))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param i32) (result i32)))
  (type (;4;) (func (param i32) (result i32)))
  (type (;5;) (func (param i64) (result i32)))
  (type (;6;) (func (param i32) (result i32)))
  (type (;7;) (func (param i32) (result i32)))
  (type (;8;) (func (param i32) (result i32)))
  (type (;9;) (func (param i64) (result i32)))
  (type (;10;) (func (param f32) (result i32)))
  (type (;11;) (func (param f64) (result i32)))
  (type (;12;) (func (result i32)))
  (type (;13;) (array (mut v128)))
  (type (;14;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;17;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 0)))
  (memory (;0;) 1)
  (export "main" (func 12))
  (export "memory" (memory 0))
  (func (;1;) (type 1) (param i32 eqref) (result i32)
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
  (func (;2;) (type 2) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 0
      i32.const -128
      i32.sub
      i32.extend8_s
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;3;) (type 3) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 0
      i32.const -32768
      i32.sub
      i32.extend16_s
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;4;) (type 4) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 0
      i32.const -2147483648
      i32.sub
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;5;) (type 5) (param i64) (result i32)
    (local i64 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i64.const 0
      i64.const -9223372036854775808
      i64.sub
      i64.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;6;) (type 6) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 255
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;7;) (type 7) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 65535
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;8;) (type 8) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const -1
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;9;) (type 9) (param i64) (result i32)
    (local i64 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i64.const -1
      i64.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;10;) (type 10) (param f32) (result i32)
    (local f32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      f32.const 0x1.8p+0 (;=1.5;)
      f32.neg
      f32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;11;) (type 11) (param f64) (result i32)
    (local f64 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      f64.const 0x1.4p+1 (;=2.5;)
      f64.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;12;) (type 12) (result i32)
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    call 2
    if (result i32) ;; label = @1
      i32.const 0
      i32.const -32768
      i32.sub
      i32.extend16_s
      call 3
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 0
      i32.const -2147483648
      i32.sub
      call 4
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i64.const 0
      i64.const -9223372036854775808
      i64.sub
      call 5
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 255
      call 6
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 65535
      call 7
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const -1
      call 8
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i64.const -1
      call 9
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x1.8p+0 (;=1.5;)
      f32.neg
      call 10
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f64.const 0x1.4p+1 (;=2.5;)
      call 11
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x746e6f63 0x3a6c6f72 0x2d6c6c61 0x656d756e
      v128.const i32x4 0x2d636972 0x6574696c 0x2d6c6172 0x6374616d
      v128.const i32x4 0x00000068 0x00000000 0x00000000 0x00000000
      array.new_fixed 13 3
      i32.const 0
      i32.const 33
      struct.new 15
      call 1
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 13 1
      i32.const 0
      i32.const 4
      struct.new 15
      call 1
    end
  )
)
