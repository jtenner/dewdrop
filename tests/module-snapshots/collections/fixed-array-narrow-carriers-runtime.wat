(module
  (type (;0;) (struct (field eqref)))
  (type (;1;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;2;) (func (param i32 eqref) (result i32)))
  (type (;3;) (func (result i32)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;8;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (array (mut i32)))
  (type (;11;) (array (mut i64)))
  (type (;12;) (array (mut f32)))
  (type (;13;) (array (mut f64)))
  (type (;14;) (array (mut v128)))
  (type (;15;) (array (mut eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 1)))
  (memory (;0;) 1)
  (export "main" (func 2))
  (export "memory" (memory 0))
  (func (;1;) (type 2) (param i32 eqref) (result i32)
    (local (ref 6) (ref 4) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 6)
    local.set 2
    local.get 2
    struct.get 6 0
    local.set 3
    local.get 2
    struct.get 6 1
    local.set 4
    local.get 2
    struct.get 6 2
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
              array.get 4
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
              array.get 4
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
              array.get 4
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
              array.get 4
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
                array.get 4
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 4
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
                array.get 4
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
            array.get 4
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
  (func (;2;) (type 3) (result i32)
    (local eqref eqref eqref eqref eqref eqref i32)
    i32.const 2
    local.set 6
    i32.const 0
    local.get 6
    array.new 10
    struct.new 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    i32.const 1
    i32.const 255
    array.set 10
    i32.const 2
    local.set 6
    i32.const 0
    local.get 6
    array.new 10
    struct.new 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    i32.const 1
    i32.const 65535
    array.set 10
    i32.const 2
    local.set 6
    i32.const 0
    local.get 6
    array.new 10
    struct.new 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    i32.const 0
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    array.set 10
    i32.const 2
    local.set 6
    i32.const 0
    local.get 6
    array.new 10
    struct.new 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    i32.const 1
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    array.set 10
    i32.const 0
    local.set 6
    i32.const 0
    local.get 6
    array.new 10
    struct.new 0
    local.set 4
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    i32.const 1
    array.get 10
    i32.const 255
    i32.eq
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 1
      array.get 10
      i32.const 65535
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      array.get 10
      i32.const 0
      i32.const -128
      i32.sub
      i32.extend8_s
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 1
      array.get 10
      i32.const 0
      i32.const -32768
      i32.sub
      i32.extend16_s
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      array.len
      i32.const 0
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x65786966
      v128.const i32x4 0x72612d64 0x2d796172 0x7272616e 0x632d776f
      v128.const i32x4 0x69727261 0x00737265 0x00000000 0x00000000
      array.new_fixed 4 3
      i32.const 0
      i32.const 39
      struct.new 6
      call 1
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 4 1
      i32.const 0
      i32.const 4
      struct.new 6
      call 1
    end
  )
)
