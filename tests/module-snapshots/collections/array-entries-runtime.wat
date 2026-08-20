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
  (type (;13;) (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;14;) (struct (field (ref 11)) (field (mut i32))))
  (type (;15;) (sub (struct (field funcref))))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result eqref)))
  (type (;18;) (func (param eqref) (result (ref 11))))
  (type (;19;) (func (param eqref eqref) (result eqref)))
  (type (;20;) (func (param eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result (ref 11))))
  (type (;26;) (func (param eqref eqref eqref) (result eqref)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref eqref i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result i32)))
  (type (;31;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;32;) (func (param (ref 11)) (result (ref 14))))
  (type (;33;) (func (param eqref) (result eqref)))
  (type (;34;) (func (param (ref 14)) (result (ref 8))))
  (type (;35;) (func (param (ref 11)) (result (ref 14))))
  (type (;36;) (func (param (ref 14)) (result (ref 8))))
  (type (;37;) (func (param eqref) (result i32)))
  (type (;38;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;39;) (func (param i32 eqref) (result i32)))
  (type (;40;) (func (result (ref 11))))
  (type (;41;) (func))
  (type (;42;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;43;) (struct))
  (type (;44;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;45;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;46;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;47;) (array (mut v128)))
  (type (;48;) (struct (field (ref 47)) (field i32) (field i32)))
  (type (;49;) (struct (field (ref 47)) (field i32) (field i32)))
  (type (;50;) (struct (field (ref 47)) (field i32) (field i32)))
  (type (;51;) (struct (field (mut (ref 47))) (field (mut i32)) (field (mut i32))))
  (type (;52;) (struct (field (mut (ref 47))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 38)))
  (memory (;0;) 1)
  (export "main" (func 6))
  (export "memory" (memory 0))
  (func (;1;) (type 35) (param (ref 11)) (result (ref 14))
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    struct.new 14
    ref.cast (ref 14)
  )
  (func (;2;) (type 36) (param (ref 14)) (result (ref 8))
    (local i32 i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 1
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      ref.cast (ref 14)
      struct.get 14 1
      local.set 1
      local.get 0
      ref.cast (ref 14)
      struct.get 14 0
      local.get 1
      local.set 4
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      array.get 0
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      struct.set 14 1
      i32.const 1
      local.get 1
      local.get 2
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 13
      struct.new 10
    end
    ref.cast (ref 8)
  )
  (func (;3;) (type 37) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.test (ref 12)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 12)
      struct.get 12 1
    else
      local.get 1
      ref.test (ref 13)
      if (result i32) ;; label = @2
        local.get 1
        ref.cast (ref 13)
        struct.get 13 1
      else
        unreachable
      end
    end
  )
  (func (;4;) (type 39) (param i32 eqref) (result i32)
    (local (ref 49) (ref 47) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 49)
    local.set 2
    local.get 2
    struct.get 49 0
    local.set 3
    local.get 2
    struct.get 49 1
    local.set 4
    local.get 2
    struct.get 49 2
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
              array.get 47
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
              array.get 47
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
              array.get 47
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
              array.get 47
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
                array.get 47
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 47
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
                array.get 47
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
            array.get 47
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
  (func (;5;) (type 40) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    local.set 0
    local.get 0
    i32.const 10
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 20
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
  )
  (func (;6;) (type 41)
    (local eqref eqref eqref eqref i32 eqref i32 eqref i32 eqref i32)
    call 5
    local.set 0
    local.get 0
    i32.const 0
    local.set 8
    i32.const 11
    local.set 10
    local.set 7
    local.get 8
    local.get 7
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 8
    local.get 10
    array.set 0
    local.get 0
    ref.cast (ref 11)
    call 1
    local.set 1
    local.get 1
    ref.cast (ref 14)
    call 2
    local.set 5
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 5
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          local.set 6
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 10)
        struct.get 10 1
        local.set 2
        local.get 2
        call 3
        i32.const 11
        i32.eq
        if (result i32) ;; label = @3
          local.get 1
          ref.cast (ref 14)
          call 2
          local.set 3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  local.get 3
                  ref.cast (ref 8)
                  struct.get 8 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                unreachable
                local.set 4
                br 2 (;@4;)
              end
              i32.const 1
              v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
              v128.const i32x4 0x6e652d79 0x65697274 0x75722d73 0x6d69746e
              v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
              array.new_fixed 47 3
              i32.const 0
              i32.const 33
              struct.new 49
              call 4
              local.set 4
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 4
        else
          unreachable
        end
        local.set 6
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 6
    drop
  )
)
