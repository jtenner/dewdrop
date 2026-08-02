(module
  (type (;0;) (func (param i32) (result i64)))
  (type (;1;) (func (param i64 i32) (result i32)))
  (type (;2;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;3;) (func (param i32 eqref) (result i32)))
  (type (;4;) (func (param i32) (result i64)))
  (type (;5;) (func (param i64 i32) (result i32)))
  (type (;6;) (func (param i64 i64) (result i64)))
  (type (;7;) (func (param i64 i32) (result i32)))
  (type (;8;) (func (param i64 i64) (result i64)))
  (type (;9;) (func (result i32)))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 2)))
  (memory (;0;) 1)
  (export "main" (func 9))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
    i64.const 255
    i64.and
    i64.const 72340172838076673
    i64.mul
  )
  (func (;2;) (type 1) (param i64 i32) (result i32)
    (local i64)
    local.get 1
    i64.extend_i32_u
    i64.const 7
    i64.and
    i64.const 8
    i64.mul
    local.set 2
    local.get 0
    local.get 2
    i64.shr_u
    i64.const 255
    i64.and
    i32.wrap_i64
    i32.extend8_s
  )
  (func (;3;) (type 3) (param i32 eqref) (result i32)
    (local (ref 12) (ref 10) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 12)
    local.set 2
    local.get 2
    struct.get 12 0
    local.set 3
    local.get 2
    struct.get 12 1
    local.set 4
    local.get 2
    struct.get 12 2
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
              array.get 10
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
              array.get 10
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
              array.get 10
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
              array.get 10
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
                array.get 10
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 10
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
                array.get 10
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
            array.get 10
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
  (func (;4;) (type 4) (param i32) (result i64)
    local.get 0
    call 1
  )
  (func (;5;) (type 5) (param i64 i32) (result i32)
    local.get 0
    local.get 1
    call 2
  )
  (func (;6;) (type 6) (param i64 i64) (result i64)
    (local i64 i64 i64 i64 i64 i64)
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 2
    i64.const 9187201950435737471
    i64.and
    local.get 3
    i64.const 9187201950435737471
    i64.and
    i64.add
    local.get 2
    local.get 3
    i64.xor
    i64.const -9187201950435737472
    i64.and
    i64.xor
    local.set 4
    local.get 2
    local.get 3
    i64.xor
    i64.const -1
    i64.xor
    local.get 2
    local.get 4
    i64.xor
    i64.and
    i64.const -9187201950435737472
    i64.and
    i64.const 7
    i64.shr_u
    local.set 5
    local.get 5
    i64.const 255
    i64.mul
    local.set 6
    local.get 2
    i64.const -9187201950435737472
    i64.and
    i64.const 7
    i64.shr_u
    i64.const 255
    i64.mul
    i64.const 9187201950435737471
    i64.xor
    local.set 7
    local.get 4
    local.get 6
    i64.const -1
    i64.xor
    i64.and
    local.get 7
    local.get 6
    i64.and
    i64.or
  )
  (func (;7;) (type 7) (param i64 i32) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;8;) (type 8) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 6
  )
  (func (;9;) (type 9) (result i32)
    i32.const 120
    call 4
    i32.const 20
    call 4
    call 8
    i32.const 0
    call 7
    i32.const 127
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x656e616c 0x38693a73 0x732d3878 0x72757461
      v128.const i32x4 0x6f697461 0x0000006e 0x00000000 0x00000000
      array.new_fixed 10 2
      i32.const 0
      i32.const 21
      struct.new 12
      call 3
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 10 1
      i32.const 0
      i32.const 4
      struct.new 12
      call 3
    end
  )
)
