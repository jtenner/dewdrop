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
  (type (;9;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;10;) (sub final 8 (struct (field i32) (field i32))))
  (type (;11;) (sub (struct (field i32))))
  (type (;12;) (sub final 11 (struct (field i32) (field eqref))))
  (type (;13;) (sub final 11 (struct (field i32) (field eqref))))
  (type (;14;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;15;) (struct))
  (type (;16;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;17;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;18;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;19;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;20;) (struct (field eqref) (field (mut i32))))
  (type (;21;) (sub (struct (field funcref))))
  (type (;22;) (func (param eqref) (result eqref)))
  (type (;23;) (func (param eqref i32) (result eqref)))
  (type (;24;) (func (param eqref) (result (ref 19))))
  (type (;25;) (func (param eqref eqref) (result eqref)))
  (type (;26;) (func (param eqref)))
  (type (;27;) (func (param eqref i32)))
  (type (;28;) (func (param eqref) (result i32)))
  (type (;29;) (func (param eqref i32) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result eqref)))
  (type (;31;) (func (param eqref eqref) (result (ref 19))))
  (type (;32;) (func (param eqref eqref eqref) (result eqref)))
  (type (;33;) (func (param eqref eqref)))
  (type (;34;) (func (param eqref eqref i32)))
  (type (;35;) (func (param eqref eqref) (result i32)))
  (type (;36;) (func (param eqref eqref i32) (result i32)))
  (type (;37;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;38;) (func (param i32 eqref) (result (ref 19))))
  (type (;39;) (func (param i32 i32) (result (ref 19))))
  (type (;40;) (func (param i32 i64) (result (ref 19))))
  (type (;41;) (func (param i32 eqref) (result (ref 19))))
  (type (;42;) (func (param eqref eqref) (result i32)))
  (type (;43;) (func (param eqref eqref) (result i32)))
  (type (;44;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;45;) (func (param i32 eqref) (result i32)))
  (type (;46;) (struct (field i32) (field i32) (field i32) (field eqref) (field i32) (field i32)))
  (type (;47;) (struct (field eqref)))
  (type (;48;) (struct (field i32) (field eqref)))
  (type (;49;) (struct (field eqref) (field eqref)))
  (type (;50;) (struct (field eqref) (field eqref)))
  (type (;51;) (func (param (ref 19) i32) (result (ref 46))))
  (type (;52;) (func (param (ref 8)) (result (ref 46))))
  (type (;53;) (func (param (ref 46)) (result (ref 11))))
  (type (;54;) (func (param (ref 11)) (result (ref 46))))
  (type (;55;) (func (param (ref 14) i32) (result (ref 46))))
  (type (;56;) (func (param eqref eqref) (result i32)))
  (type (;57;) (func (param (ref 46))))
  (type (;58;) (func))
  (type (;59;) (array (mut v128)))
  (type (;60;) (struct (field (ref 59)) (field i32) (field i32)))
  (type (;61;) (struct (field (ref 59)) (field i32) (field i32)))
  (type (;62;) (struct (field (ref 59)) (field i32) (field i32)))
  (type (;63;) (struct (field (mut (ref 59))) (field (mut i32)) (field (mut i32))))
  (type (;64;) (struct (field (mut (ref 59))) (field (mut i32)) (field (mut i32))))
  (type (;65;) (array (mut eqref)))
  (type (;66;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 44)))
  (memory (;0;) 1)
  (export "main" (func 14))
  (export "memory" (memory 0))
  (func (;1;) (type 39) (param i32 i32) (result (ref 19))
    (local eqref i32 eqref i32)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 0
    local.get 3
    local.get 3
    struct.new 19
    ref.cast (ref 19)
  )
  (func (;2;) (type 40) (param i32 i64) (result (ref 19))
    (local eqref i32 eqref i64)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 1
    local.get 3
    local.get 3
    struct.new 19
    ref.cast (ref 19)
  )
  (func (;3;) (type 41) (param i32 eqref) (result (ref 19))
    (local eqref i32 eqref eqref)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 5
    local.get 3
    local.get 3
    struct.new 19
    ref.cast (ref 19)
  )
  (func (;4;) (type 42) (param eqref eqref) (result i32)
    (local (ref 60) (ref 60) (ref 59) (ref 59) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 60)
    local.set 2
    local.get 1
    ref.cast (ref 60)
    local.set 3
    local.get 2
    struct.get 60 2
    local.tee 6
    local.get 3
    struct.get 60 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 60 0
    local.set 4
    local.get 3
    struct.get 60 0
    local.set 5
    local.get 2
    struct.get 60 1
    local.set 7
    local.get 3
    struct.get 60 1
    local.set 8
    i32.const 0
    local.set 9
    loop ;; label = @1
      local.get 9
      local.get 6
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 9
      i32.const 16
      i32.add
      local.get 6
      i32.le_u
      if ;; label = @2
        local.get 7
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 59
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 59
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 59
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 10
        end
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 59
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 59
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 59
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
        local.get 10
        local.get 11
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 7
        i32.const 16
        i32.add
        local.set 7
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        br 1 (;@1;)
      end
      local.get 4
      local.get 7
      i32.const 4
      i32.shr_u
      array.get 59
      local.get 7
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 59
      local.get 8
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
      local.get 7
      i32.const 1
      i32.add
      local.set 7
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;5;) (type 43) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;6;) (type 45) (param i32 eqref) (result i32)
    (local (ref 61) (ref 59) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 61)
    local.set 2
    local.get 2
    struct.get 61 0
    local.set 3
    local.get 2
    struct.get 61 1
    local.set 4
    local.get 2
    struct.get 61 2
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
              array.get 59
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
              array.get 59
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
              array.get 59
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
              array.get 59
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
                array.get 59
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 59
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
                array.get 59
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
            array.get 59
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
  (func (;7;) (type 51) (param (ref 19) i32) (result (ref 46))
    (local (ref 46) eqref i32 eqref)
    local.get 0
    local.get 1
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 19)
    struct.get 19 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 19)
    struct.get 19 0
    ref.cast (ref 5)
    local.get 4
    array.get 5
    ref.cast (ref 46)
    ref.cast (ref 46)
    local.set 2
    local.get 2
    ref.cast (ref 46)
    struct.get 46 0
    local.get 2
    ref.cast (ref 46)
    struct.get 46 1
    local.get 2
    ref.cast (ref 46)
    struct.get 46 2
    local.get 2
    ref.cast (ref 46)
    struct.get 46 3
    local.get 2
    ref.cast (ref 46)
    struct.get 46 4
    local.get 2
    ref.cast (ref 46)
    struct.get 46 5
    struct.new 46
    ref.cast (ref 46)
  )
  (func (;8;) (type 52) (param (ref 8)) (result (ref 46))
    (local (ref 46) eqref eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 9)
        struct.get 9 1
        ref.cast (ref 46)
        local.set 1
        local.get 1
        ref.cast (ref 46)
        struct.get 46 0
        local.get 1
        ref.cast (ref 46)
        struct.get 46 1
        local.get 1
        ref.cast (ref 46)
        struct.get 46 2
        local.get 1
        ref.cast (ref 46)
        struct.get 46 3
        local.get 1
        ref.cast (ref 46)
        struct.get 46 4
        local.get 1
        ref.cast (ref 46)
        struct.get 46 5
        struct.new 46
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
    ref.cast (ref 46)
  )
  (func (;9;) (type 53) (param (ref 46)) (result (ref 11))
    i32.const 0
    local.get 0
    struct.new 12
    ref.cast (ref 11)
  )
  (func (;10;) (type 54) (param (ref 11)) (result (ref 46))
    (local (ref 46) eqref eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 11)
            struct.get 11 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 2
          ref.cast (ref 12)
          struct.get 12 1
          ref.cast (ref 46)
          local.set 1
          local.get 1
          ref.cast (ref 46)
          struct.get 46 0
          local.get 1
          ref.cast (ref 46)
          struct.get 46 1
          local.get 1
          ref.cast (ref 46)
          struct.get 46 2
          local.get 1
          ref.cast (ref 46)
          struct.get 46 3
          local.get 1
          ref.cast (ref 46)
          struct.get 46 4
          local.get 1
          ref.cast (ref 46)
          struct.get 46 5
          struct.new 46
          local.set 3
          br 2 (;@1;)
        end
        unreachable
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
    ref.cast (ref 46)
  )
  (func (;11;) (type 55) (param (ref 14) i32) (result (ref 46))
    (local (ref 46) eqref eqref i64 eqref i32 eqref)
    local.get 1
    local.set 7
    local.get 7
    i64.extend_i32_s
    local.set 5
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 65)
    local.set 4
    local.get 4
    ref.cast (ref 65)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 65)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 65
    local.set 6
    block (result eqref) ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 66)
        struct.get 66 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 66)
          struct.get 66 2
          local.get 7
          i32.eq
          if ;; label = @4
            local.get 6
            ref.cast (ref 66)
            struct.get 66 13
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 66)
        struct.get 66 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    ref.cast (ref 46)
    local.set 2
    local.get 2
    ref.cast (ref 46)
    struct.get 46 0
    local.get 2
    ref.cast (ref 46)
    struct.get 46 1
    local.get 2
    ref.cast (ref 46)
    struct.get 46 2
    local.get 2
    ref.cast (ref 46)
    struct.get 46 3
    local.get 2
    ref.cast (ref 46)
    struct.get 46 4
    local.get 2
    ref.cast (ref 46)
    struct.get 46 5
    struct.new 46
    ref.cast (ref 46)
  )
  (func (;12;) (type 56) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;13;) (type 57) (param (ref 46))
    local.get 0
    ref.cast (ref 46)
    struct.get 46 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x74706163 0x20657275 0x00006469 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 10
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 46)
    struct.get 46 1
    i32.const 2
    i32.eq
    v128.const i32x4 0x74706163 0x20657275 0x626d616c 0x00006164
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 46)
    struct.get 46 2
    i32.const 3
    i32.eq
    v128.const i32x4 0x74706163 0x20657275 0x656d616e 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 12
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 46)
    struct.get 46 3
    v128.const i32x4 0x74706163 0x2d657275 0x72756f73 0x00006563
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    call 5
    v128.const i32x4 0x74706163 0x20657275 0x72756f73 0x00006563
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 46)
    struct.get 46 4
    v128.const i32x4 0x74706163 0x20657275 0x6174756d 0x00656c62
    array.new_fixed 59 1
    i32.const 0
    i32.const 15
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 46)
    struct.get 46 5
    i32.const 4
    i32.eq
    v128.const i32x4 0x74706163 0x20657275 0x7366666f 0x00007465
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;14;) (type 58)
    (local eqref i32 i64 (ref 46) (ref 47) (ref 48) (ref 49) eqref i32 eqref eqref i64 eqref i32 eqref)
    i32.const 1
    i32.const 17
    call 1
    local.set 0
    local.get 0
    i32.const 0
    local.set 8
    local.set 7
    local.get 8
    local.get 7
    ref.cast (ref 19)
    struct.get 19 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 19)
    struct.get 19 0
    ref.cast (ref 0)
    local.get 8
    array.get 0
    local.set 1
    local.get 1
    i32.const 17
    i32.eq
    v128.const i32x4 0x61727261 0x33692079 0x72702032 0x6e65766f
    v128.const i32x4 0x65636e61 0x00000000 0x00000000 0x00000000
    array.new_fixed 59 2
    i32.const 0
    i32.const 20
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i64.const 19
    call 2
    local.set 0
    local.get 0
    i32.const 0
    local.set 8
    local.set 7
    local.get 8
    local.get 7
    ref.cast (ref 19)
    struct.get 19 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 19)
    struct.get 19 0
    ref.cast (ref 1)
    local.get 8
    array.get 1
    local.set 2
    local.get 2
    i64.const 19
    i64.eq
    v128.const i32x4 0x61727261 0x36692079 0x72702034 0x6e65766f
    v128.const i32x4 0x65636e61 0x00000000 0x00000000 0x00000000
    array.new_fixed 59 2
    i32.const 0
    i32.const 20
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x74786574 0x00000000 0x00000000 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 4
    struct.new 60
    call 3
    local.set 0
    local.get 0
    i32.const 0
    local.set 8
    local.set 7
    local.get 8
    local.get 7
    ref.cast (ref 19)
    struct.get 19 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 7
    ref.cast (ref 19)
    struct.get 19 0
    ref.cast (ref 5)
    local.get 8
    array.get 5
    local.set 0
    local.get 0
    v128.const i32x4 0x74786574 0x00000000 0x00000000 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 4
    struct.new 60
    call 12
    v128.const i32x4 0x61727261 0x74732079 0x676e6972 0x6f727020
    v128.const i32x4 0x616e6576 0x0065636e 0x00000000 0x00000000
    array.new_fixed 59 2
    i32.const 0
    i32.const 23
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 2
    i32.const 3
    v128.const i32x4 0x74706163 0x2d657275 0x72756f73 0x00006563
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    i32.const 1
    i32.const 4
    struct.new 46
    local.set 3
    i32.const 1
    local.get 3
    call 3
    local.set 0
    local.get 0
    ref.cast (ref 19)
    i32.const 0
    call 7
    call 13
    i32.const 1
    local.get 3
    struct.new 9
    call 8
    call 13
    local.get 3
    ref.cast (ref 46)
    call 9
    call 10
    call 13
    i32.const 7
    local.set 13
    local.get 3
    local.set 14
    local.get 13
    i64.extend_i32_s
    local.set 11
    i32.const 16
    array.new_default 65
    local.set 10
    ref.null eq
    local.get 11
    local.get 13
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 14
    struct.new 66
    local.set 12
    local.get 10
    ref.cast (ref 65)
    local.get 11
    i32.wrap_i64
    local.get 10
    ref.cast (ref 65)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 12
    array.set 65
    local.get 10
    i32.const 1
    struct.new 14
    local.set 0
    local.get 0
    ref.cast (ref 14)
    i32.const 7
    call 11
    call 13
    v128.const i32x4 0x6568746f 0x00612d72 0x00000000 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 7
    struct.new 60
    struct.new 47
    local.set 4
    i32.const 99
    v128.const i32x4 0x6568746f 0x00622d72 0x00000000 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 7
    struct.new 60
    struct.new 48
    local.set 5
    v128.const i32x4 0x6568746f 0x2d632d72 0x7366666f 0x00007465
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    v128.const i32x4 0x6568746f 0x2d632d72 0x6174756d 0x00656c62
    array.new_fixed 59 1
    i32.const 0
    i32.const 15
    struct.new 60
    struct.new 49
    local.set 6
    local.get 4
    ref.cast (ref 47)
    struct.get 47 0
    v128.const i32x4 0x6568746f 0x00612d72 0x00000000 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 7
    struct.new 60
    call 12
    v128.const i32x4 0x6568746f 0x00612072 0x00000000 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 7
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 48)
    struct.get 48 0
    i32.const 99
    i32.eq
    v128.const i32x4 0x6568746f 0x20622072 0x72756f73 0x00006563
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 48)
    struct.get 48 1
    v128.const i32x4 0x6568746f 0x00622d72 0x00000000 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 7
    struct.new 60
    call 12
    v128.const i32x4 0x6568746f 0x20622072 0x656d616e 0x00000000
    array.new_fixed 59 1
    i32.const 0
    i32.const 12
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 49)
    struct.get 49 0
    v128.const i32x4 0x6568746f 0x2d632d72 0x7366666f 0x00007465
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    call 12
    v128.const i32x4 0x6568746f 0x20632072 0x7366666f 0x00007465
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 49)
    struct.get 49 1
    v128.const i32x4 0x6568746f 0x2d632d72 0x6174756d 0x00656c62
    array.new_fixed 59 1
    i32.const 0
    i32.const 15
    struct.new 60
    call 12
    v128.const i32x4 0x6568746f 0x20632072 0x6174756d 0x00656c62
    array.new_fixed 59 1
    i32.const 0
    i32.const 15
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x696d6f6e
    v128.const i32x4 0x2d6c616e 0x746e6f63 0x656e6961 0x72702d72
    v128.const i32x4 0x6e65766f 0x65636e61 0x6e75722d 0x656d6974
    array.new_fixed 59 3
    i32.const 0
    i32.const 48
    struct.new 61
    call 6
    drop
  )
)
