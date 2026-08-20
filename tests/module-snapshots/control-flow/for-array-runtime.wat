(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;11;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field eqref) (field (mut i32))))
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref) (result (ref 11))))
  (type (;17;) (func (param eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result (ref 11))))
  (type (;24;) (func (param eqref eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref)))
  (type (;26;) (func (param eqref eqref i32)))
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;30;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;31;) (func (param i32 eqref) (result i32)))
  (type (;32;) (func))
  (type (;33;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;34;) (struct))
  (type (;35;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;36;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;37;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;38;) (array (mut v128)))
  (type (;39;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;40;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;41;) (struct (field (ref 38)) (field i32) (field i32)))
  (type (;42;) (struct (field (mut (ref 38))) (field (mut i32)) (field (mut i32))))
  (type (;43;) (struct (field (mut (ref 38))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 30)))
  (memory (;0;) 1)
  (export "main" (func 2))
  (export "memory" (memory 0))
  (func (;1;) (type 31) (param i32 eqref) (result i32)
    (local (ref 40) (ref 38) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 40)
    local.set 2
    local.get 2
    struct.get 40 0
    local.set 3
    local.get 2
    struct.get 40 1
    local.set 4
    local.get 2
    struct.get 40 2
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
              array.get 38
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
              array.get 38
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
              array.get 38
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
              array.get 38
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
                array.get 38
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 38
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
                array.get 38
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
            array.get 38
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
  (func (;2;) (type 32)
    (local eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 eqref i32 i32)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    local.set 0
    i32.const 2
    local.set 7
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 5
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 5
      array.new_default 0
      local.set 6
      local.get 6
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      struct.set 11 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 4
    ref.cast (ref 11)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 3
    local.set 8
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 5
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 5
      array.new_default 0
      local.set 6
      local.get 6
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      struct.set 11 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    array.set 0
    local.get 4
    ref.cast (ref 11)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 5
    local.set 9
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 5
      local.get 5
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 5
      array.new_default 0
      local.set 6
      local.get 6
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      struct.set 11 0
      local.get 4
      ref.cast (ref 11)
      local.get 6
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 9
    array.set 0
    local.get 4
    ref.cast (ref 11)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 0
    local.set 1
    local.get 0
    i32.const 0
    struct.new 12
    local.set 2
    local.get 2
    local.set 4
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      local.get 4
      ref.cast (ref 12)
      struct.get 12 1
      local.set 5
      local.get 4
      ref.cast (ref 12)
      local.get 5
      i32.const 1
      i32.add
      struct.set 12 1
      i32.const 1
      local.set 11
      local.get 4
      ref.cast (ref 12)
      struct.get 12 0
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 5
      array.get 0
      local.set 12
    else
      i32.const 0
      local.set 11
    end
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 11
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 12
            local.set 3
            local.get 1
            local.get 3
            i32.add
            local.set 1
            local.get 2
            local.set 4
            local.get 4
            ref.cast (ref 12)
            struct.get 12 1
            local.get 4
            ref.cast (ref 12)
            struct.get 12 0
            ref.cast (ref 11)
            struct.get 11 1
            i32.lt_u
            if ;; label = @5
              local.get 4
              ref.cast (ref 12)
              struct.get 12 1
              local.set 5
              local.get 4
              ref.cast (ref 12)
              local.get 5
              i32.const 1
              i32.add
              struct.set 12 1
              i32.const 1
              local.set 11
              local.get 4
              ref.cast (ref 12)
              struct.get 12 0
              ref.cast (ref 11)
              struct.get 11 0
              ref.cast (ref 0)
              local.get 5
              array.get 0
              local.set 12
            else
              i32.const 0
              local.set 11
            end
            br 2 (;@2;)
            br 1 (;@3;)
          end
          local.get 11
          i32.const 0
          i32.eq
          if ;; label = @4
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 1
    i32.const 10
    i32.eq
    v128.const i32x4 0x20726f66 0x69736976 0x65207374 0x20686361
    v128.const i32x4 0x61727261 0x6c652079 0x6e656d65 0x6e6f2074
    v128.const i32x4 0x00006563 0x00000000 0x00000000 0x00000000
    array.new_fixed 38 3
    i32.const 0
    i32.const 34
    struct.new 39
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x746e6f63 0x2d6c6f72 0x776f6c66 0x726f663a
    v128.const i32x4 0x7272612d 0x722d7961 0x69746e75 0x0000656d
    array.new_fixed 38 2
    i32.const 0
    i32.const 30
    struct.new 40
    call 1
    drop
  )
)
