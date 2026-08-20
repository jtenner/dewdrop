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
  (type (;30;) (func (param i32 i32 i32)))
  (type (;31;) (func (param i32 eqref) (result (ref 11))))
  (type (;32;) (func (param (ref 11))))
  (type (;33;) (func (param (ref 11) i32)))
  (type (;34;) (func (param (ref 11)) (result (ref 11))))
  (type (;35;) (func (param (ref 11) eqref i32 i32)))
  (type (;36;) (func (param (ref 11) i32 i32 i32)))
  (type (;37;) (func (param (ref 11) i32 i32) (result (ref 11))))
  (type (;38;) (func (param i32 i64) (result (ref 11))))
  (type (;39;) (func (param (ref 11) i64 i32 i32)))
  (type (;40;) (func (param (ref 11)) (result (ref 11))))
  (type (;41;) (func (param (ref 11) i32 i32 i32)))
  (type (;42;) (func (param (ref 11) i32)))
  (type (;43;) (func (param (ref 11))))
  (type (;44;) (func (param i32 eqref) (result (ref 11))))
  (type (;45;) (func (param (ref 11) eqref i32 i32)))
  (type (;46;) (func (param (ref 11) i32 i32) (result (ref 11))))
  (type (;47;) (func (param (ref 11) i32)))
  (type (;48;) (func (param eqref eqref) (result i32)))
  (type (;49;) (func (param eqref eqref) (result i32)))
  (type (;50;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;51;) (func (param i32 eqref) (result i32)))
  (type (;52;) (struct (field i32) (field i32)))
  (type (;53;) (struct))
  (type (;54;) (struct))
  (type (;55;) (func (result (ref 11))))
  (type (;56;) (func (param i32) (result (ref 11))))
  (type (;57;) (func (result (ref 11))))
  (type (;58;) (func (result (ref 11))))
  (type (;59;) (func (param i32 i32) (result (ref 11))))
  (type (;60;) (func (param (ref 8)) (result i32)))
  (type (;61;) (func (param (ref 8)) (result i32)))
  (type (;62;) (func (param i32) (result i32)))
  (type (;63;) (func (param i32 i32) (result i32)))
  (type (;64;) (func (param i32 i32 i32) (result i32)))
  (type (;65;) (func (param i32) (result i32)))
  (type (;66;) (func (param i32 i32) (result i32)))
  (type (;67;) (func (param i32) (result i32)))
  (type (;68;) (func (param i32) (result i32)))
  (type (;69;) (func (param i32 i32) (result i32)))
  (type (;70;) (func (param i32) (result (ref 11))))
  (type (;71;) (func (param i32) (result eqref)))
  (type (;72;) (func (param i32 i32) (result i32)))
  (type (;73;) (func (param (ref 53) i32 i32) (result i32)))
  (type (;74;) (func (param (ref 54) (ref 52) (ref 52)) (result i32)))
  (type (;75;) (func (result (ref 11))))
  (type (;76;) (func (param eqref eqref) (result i32)))
  (type (;77;) (func (param (ref 52)) (result i32)))
  (type (;78;) (func (param (ref 52)) (result i32)))
  (type (;79;) (func))
  (type (;80;) (func))
  (type (;81;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;82;) (struct))
  (type (;83;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;84;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;85;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;86;) (array (mut v128)))
  (type (;87;) (struct (field (ref 86)) (field i32) (field i32)))
  (type (;88;) (struct (field (ref 86)) (field i32) (field i32)))
  (type (;89;) (struct (field (ref 86)) (field i32) (field i32)))
  (type (;90;) (struct (field (mut (ref 86))) (field (mut i32)) (field (mut i32))))
  (type (;91;) (struct (field (mut (ref 86))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 50)))
  (memory (;0;) 1)
  (export "main" (func 40))
  (export "memory" (memory 0))
  (func (;1;) (type 30) (param i32 i32 i32)
    local.get 1
    local.get 2
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      local.get 0
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;2;) (type 38) (param i32 i64) (result (ref 11))
    (local eqref i32 eqref i64)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 1
    local.get 3
    local.get 3
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;3;) (type 39) (param (ref 11) i64 i32 i32)
    (local eqref i32 eqref i64)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    local.get 3
    call 1
    local.get 0
    local.set 4
    local.get 1
    local.set 7
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    local.get 2
    local.get 7
    local.get 3
    local.get 2
    i32.sub
    array.fill 1
  )
  (func (;4;) (type 40) (param (ref 11)) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    array.new_default 1
    local.set 3
    local.get 3
    ref.cast (ref 1)
    i32.const 0
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    i32.const 0
    local.get 2
    array.copy 1 1
    local.get 3
    local.get 2
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;5;) (type 41) (param (ref 11) i32 i32 i32)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 4
    local.get 4
    local.get 2
    local.get 3
    call 1
    local.get 3
    local.get 2
    i32.sub
    local.set 5
    local.get 1
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 5
      local.get 4
      local.get 1
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
      local.get 0
      local.set 6
      local.get 6
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 1)
      local.get 1
      local.get 6
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 1)
      local.get 2
      local.get 3
      local.get 2
      i32.sub
      array.copy 1 1
    end
  )
  (func (;6;) (type 42) (param (ref 11) i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    local.get 3
    struct.set 11 1
  )
  (func (;7;) (type 43) (param (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
    else
      local.get 2
      array.new_default 1
      local.set 3
      local.get 3
      ref.cast (ref 1)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 1)
      i32.const 0
      local.get 2
      array.copy 1 1
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 2
      struct.set 11 2
    end
  )
  (func (;8;) (type 44) (param i32 eqref) (result (ref 11))
    (local eqref i32 eqref eqref)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 5
    local.get 3
    local.get 3
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;9;) (type 45) (param (ref 11) eqref i32 i32)
    (local eqref i32 eqref eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    local.get 3
    call 1
    local.get 0
    local.set 4
    local.get 1
    local.set 7
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 2
    local.get 7
    local.get 3
    local.get 2
    i32.sub
    array.fill 5
  )
  (func (;10;) (type 46) (param (ref 11) i32 i32) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    local.get 2
    call 1
    local.get 0
    local.set 3
    local.get 2
    local.get 1
    i32.sub
    local.set 4
    local.get 4
    array.new_default 5
    local.set 5
    local.get 5
    ref.cast (ref 5)
    i32.const 0
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 1
    local.get 4
    array.copy 5 5
    local.get 5
    local.get 4
    local.get 4
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;11;) (type 47) (param (ref 11) i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 3
    ref.null eq
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    i32.sub
    array.fill 5
    local.get 2
    ref.cast (ref 11)
    local.get 3
    struct.set 11 1
  )
  (func (;12;) (type 48) (param eqref eqref) (result i32)
    (local (ref 87) (ref 87) (ref 86) (ref 86) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 87)
    local.set 2
    local.get 1
    ref.cast (ref 87)
    local.set 3
    local.get 2
    struct.get 87 2
    local.tee 6
    local.get 3
    struct.get 87 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 87 0
    local.set 4
    local.get 3
    struct.get 87 0
    local.set 5
    local.get 2
    struct.get 87 1
    local.set 7
    local.get 3
    struct.get 87 1
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
          array.get 86
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 86
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
          array.get 86
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
          array.get 86
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 86
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
          array.get 86
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
      array.get 86
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
      array.get 86
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
  (func (;13;) (type 49) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 12
  )
  (func (;14;) (type 51) (param i32 eqref) (result i32)
    (local (ref 88) (ref 86) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 88)
    local.set 2
    local.get 2
    struct.get 88 0
    local.set 3
    local.get 2
    struct.get 88 1
    local.set 4
    local.get 2
    struct.get 88 2
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
              array.get 86
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
              array.get 86
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
              array.get 86
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
              array.get 86
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
                array.get 86
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 86
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
                array.get 86
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
            array.get 86
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
  (func (;15;) (type 55) (result (ref 11))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;16;) (type 56) (param i32) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    array.new_default 0
    i32.const 0
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;17;) (type 57) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 3
    local.set 1
    local.get 1
    array.new_default 5
    i32.const 0
    local.get 1
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;18;) (type 58) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    local.set 0
    local.get 0
    i32.const 1
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
    i32.const 2
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
    i32.const 3
    local.set 6
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
    local.get 6
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
    i32.const 4
    local.set 7
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
    local.get 7
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
    i32.const 5
    local.set 8
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
    local.get 8
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
  (func (;19;) (type 59) (param i32 i32) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32)
    i32.const 2
    local.set 4
    local.get 4
    array.new_default 0
    i32.const 0
    local.get 4
    struct.new 11
    local.set 2
    local.get 2
    local.get 0
    local.set 6
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
    local.get 1
    local.set 7
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
    ref.cast (ref 11)
  )
  (func (;20;) (type 60) (param (ref 8)) (result i32)
    (local i32 eqref i32)
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
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;21;) (type 61) (param (ref 8)) (result i32)
    (local i32 eqref i32)
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
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;22;) (type 62) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.mul
  )
  (func (;23;) (type 63) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
  )
  (func (;24;) (type 64) (param i32 i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
    local.get 2
    i32.add
  )
  (func (;25;) (type 65) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
  )
  (func (;26;) (type 66) (param i32 i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 1
      i32.const 2
      i32.rem_u
      i32.const 1
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;27;) (type 67) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.eq
  )
  (func (;28;) (type 68) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.ne
  )
  (func (;29;) (type 69) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.const 1
    i32.add
    i32.eq
  )
  (func (;30;) (type 70) (param i32) (result (ref 11))
    local.get 0
    local.get 0
    i32.const 10
    i32.add
    call 19
    ref.cast (ref 11)
  )
  (func (;31;) (type 71) (param i32) (result eqref)
    local.get 0
    i32.const 1
    i32.eq
    if (result eqref) ;; label = @1
      v128.const i32x4 0x00656e6f 0x00000000 0x00000000 0x00000000
      array.new_fixed 86 1
      i32.const 0
      i32.const 3
      struct.new 87
    else
      local.get 0
      i32.const 2
      i32.eq
      if (result eqref) ;; label = @2
        v128.const i32x4 0x006f7774 0x00000000 0x00000000 0x00000000
        array.new_fixed 86 1
        i32.const 0
        i32.const 3
        struct.new 87
      else
        v128.const i32x4 0x6568746f 0x00000072 0x00000000 0x00000000
        array.new_fixed 86 1
        i32.const 0
        i32.const 5
        struct.new 87
      end
    end
  )
  (func (;32;) (type 72) (param i32 i32) (result i32)
    local.get 1
    i32.const 0
    i32.gt_s
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.add
    else
      local.get 0
    end
  )
  (func (;33;) (type 73) (param (ref 53) i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_s
  )
  (func (;34;) (type 74) (param (ref 54) (ref 52) (ref 52)) (result i32)
    local.get 1
    ref.cast (ref 52)
    struct.get 52 0
    local.get 2
    ref.cast (ref 52)
    struct.get 52 0
    i32.lt_s
  )
  (func (;35;) (type 75) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 5
    local.set 1
    local.get 1
    array.new_default 5
    i32.const 0
    local.get 1
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;36;) (type 76) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 13
  )
  (func (;37;) (type 77) (param (ref 52)) (result i32)
    local.get 0
    ref.cast (ref 52)
    struct.get 52 0
  )
  (func (;38;) (type 78) (param (ref 52)) (result i32)
    local.get 0
    ref.cast (ref 52)
    struct.get 52 1
  )
  (func (;39;) (type 79)
    (local eqref eqref eqref eqref eqref i32 eqref)
    i32.const 3
    i64.const 7
    call 2
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i64.const 9
    i32.const 1
    i32.const 3
    call 3
    local.get 0
    ref.cast (ref 11)
    call 4
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    i32.const 1
    i32.const 3
    call 5
    local.get 0
    i32.const 0
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    local.get 5
    array.get 1
    i64.const 9
    i64.eq
    v128.const i32x4 0x20343669 0x79706f63 0x74697720 0x206e6968
    v128.const i32x4 0x73726966 0x00000074 0x00000000 0x00000000
    array.new_fixed 86 2
    i32.const 0
    i32.const 21
    struct.new 87
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 1)
    local.get 5
    array.get 1
    i64.const 9
    i64.eq
    v128.const i32x4 0x20343669 0x79706f63 0x74697720 0x206e6968
    v128.const i32x4 0x6f636573 0x0000646e 0x00000000 0x00000000
    array.new_fixed 86 2
    i32.const 0
    i32.const 22
    struct.new 87
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    i32.const 1
    call 6
    local.get 0
    ref.cast (ref 11)
    call 7
    local.get 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 1
    i32.eq
    v128.const i32x4 0x20343669 0x69726873 0x00006b6e 0x00000000
    array.new_fixed 86 1
    i32.const 0
    i32.const 10
    struct.new 87
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
    array.new_fixed 86 1
    i32.const 0
    i32.const 1
    struct.new 87
    call 8
    local.set 0
    local.get 0
    ref.cast (ref 11)
    v128.const i32x4 0x00000062 0x00000000 0x00000000 0x00000000
    array.new_fixed 86 1
    i32.const 0
    i32.const 1
    struct.new 87
    i32.const 1
    i32.const 3
    call 9
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    i32.const 3
    call 10
    local.set 1
    local.get 0
    local.set 4
    i32.const 0
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        local.get 5
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.ge_u
        br_if 1 (;@1;)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 5)
        local.get 5
        ref.null eq
        array.set 5
        local.get 5
        i32.const 1
        i32.add
        local.set 5
        br 0 (;@2;)
      end
    end
    local.get 4
    ref.cast (ref 11)
    i32.const 0
    struct.set 11 1
    local.get 1
    i32.const 0
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 5
    array.get 5
    local.set 0
    local.get 1
    i32.const 1
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 5
    array.get 5
    local.set 2
    local.get 1
    i32.const 2
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 5
    array.get 5
    local.set 3
    local.get 0
    v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
    array.new_fixed 86 1
    i32.const 0
    i32.const 1
    struct.new 87
    call 36
    v128.const i32x4 0x65666572 0x636e6572 0x6c732065 0x20656369
    v128.const i32x4 0x73726966 0x00000074 0x00000000 0x00000000
    array.new_fixed 86 2
    i32.const 0
    i32.const 21
    struct.new 87
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    v128.const i32x4 0x00000062 0x00000000 0x00000000 0x00000000
    array.new_fixed 86 1
    i32.const 0
    i32.const 1
    struct.new 87
    call 36
    v128.const i32x4 0x65666572 0x636e6572 0x6c732065 0x20656369
    v128.const i32x4 0x6f636573 0x0000646e 0x00000000 0x00000000
    array.new_fixed 86 2
    i32.const 0
    i32.const 22
    struct.new 87
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    v128.const i32x4 0x00000062 0x00000000 0x00000000 0x00000000
    array.new_fixed 86 1
    i32.const 0
    i32.const 1
    struct.new 87
    call 36
    v128.const i32x4 0x65666572 0x636e6572 0x6c732065 0x20656369
    v128.const i32x4 0x72696874 0x00000064 0x00000000 0x00000000
    array.new_fixed 86 2
    i32.const 0
    i32.const 21
    struct.new 87
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 11)
    i32.const 1
    call 11
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x65666572 0x636e6572 0x72742065 0x61636e75
    v128.const i32x4 0x00006574 0x00000000 0x00000000 0x00000000
    array.new_fixed 86 2
    i32.const 0
    i32.const 18
    struct.new 87
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;40;) (type 80)
    call 39
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x61632d79 0x65697272 0x722d7372 0x69746e75
    v128.const i32x4 0x0000656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 86 3
    i32.const 0
    i32.const 34
    struct.new 88
    call 14
    drop
  )
)
