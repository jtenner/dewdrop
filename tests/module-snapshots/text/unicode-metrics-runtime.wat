(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref) (result i32)))
  (type (;9;) (func (param eqref) (result i32)))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (param eqref) (result i32)))
  (type (;12;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;13;) (func (param i32 eqref) (result i32)))
  (type (;14;) (func (result i32)))
  (type (;15;) (array (mut v128)))
  (type (;16;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;17;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;19;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
  (type (;20;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 12)))
  (memory (;0;) 1)
  (export "main" (func 6))
  (export "memory" (memory 0))
  (func (;1;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 16)
    struct.get 16 2
  )
  (func (;2;) (type 9) (param eqref) (result i32)
    (local (ref 16) (ref 15) i32 i32 v128 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 16)
    local.set 1
    local.get 1
    struct.get 16 0
    local.set 2
    local.get 1
    struct.get 16 2
    local.set 3
    local.get 1
    struct.get 16 1
    local.tee 4
    local.get 3
    i32.add
    local.set 9
    i32.const 0
    local.set 6
    i32.const 0
    local.set 7
    loop ;; label = @1
      local.get 4
      local.get 9
      i32.ge_u
      if ;; label = @2
        local.get 3
        local.get 6
        i32.sub
        local.get 7
        i32.add
        return
      end
      local.get 4
      i32.const 16
      i32.add
      local.get 9
      i32.le_u
      if ;; label = @2
        local.get 4
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 2
          local.get 4
          i32.const 4
          i32.shr_u
          array.get 15
          local.set 5
        else
          local.get 2
          local.get 4
          i32.const 4
          i32.shr_u
          array.get 15
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 4
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 2
          local.get 4
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 15
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 4
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 5
        end
        local.get 6
        local.get 5
        i32.const -64
        i8x16.splat
        i8x16.lt_s
        i8x16.bitmask
        i32.popcnt
        i32.add
        local.set 6
        local.get 7
        local.get 5
        i32.const 248
        i8x16.splat
        v128.and
        i32.const 240
        i8x16.splat
        i8x16.eq
        i8x16.bitmask
        i32.popcnt
        i32.add
        local.set 7
        local.get 4
        i32.const 16
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      local.get 2
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 15
      local.get 4
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 8
      local.get 8
      i32.const 192
      i32.and
      i32.const 128
      i32.eq
      if ;; label = @2
        local.get 6
        i32.const 1
        i32.add
        local.set 6
      end
      local.get 8
      i32.const 248
      i32.and
      i32.const 240
      i32.eq
      if ;; label = @2
        local.get 7
        i32.const 1
        i32.add
        local.set 7
      end
      local.get 4
      i32.const 1
      i32.add
      local.set 4
      br 0 (;@1;)
    end
    i32.const 0
  )
  (func (;3;) (type 10) (param eqref) (result i32)
    local.get 0
    call 1
  )
  (func (;4;) (type 11) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;5;) (type 13) (param i32 eqref) (result i32)
    (local (ref 17) (ref 15) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 17)
    local.set 2
    local.get 2
    struct.get 17 0
    local.set 3
    local.get 2
    struct.get 17 1
    local.set 4
    local.get 2
    struct.get 17 2
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
              array.get 15
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
              array.get 15
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
              array.get 15
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
              array.get 15
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
                array.get 15
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 15
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
                array.get 15
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
            array.get 15
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
  (func (;6;) (type 14) (result i32)
    (local eqref)
    v128.const i32x4 0xf0bbce61 0x008d8c9f 0x00000000 0x00000000
    array.new_fixed 15 1
    i32.const 0
    i32.const 7
    struct.new 16
    local.set 0
    local.get 0
    call 3
    i32.const 7
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      call 4
      i32.const 4
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
        v128.const i32x4 0x74786574 0x696e753a 0x65646f63 0x74656d2d
        v128.const i32x4 0x73636972 0x00000000 0x00000000 0x00000000
        array.new_fixed 15 2
        i32.const 0
        i32.const 20
        struct.new 17
        call 5
      else
        i32.const 1
        v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
        array.new_fixed 15 1
        i32.const 0
        i32.const 4
        struct.new 17
        call 5
      end
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 15 1
      i32.const 0
      i32.const 4
      struct.new 17
      call 5
    end
  )
)
