(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;4;) (sub final 0 (struct (field i32) (field i64))))
  (type (;5;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;6;) (func (param i32 i32) (result i32)))
  (type (;7;) (func (param i32) (result i32)))
  (type (;8;) (func (param i32) (result i32)))
  (type (;9;) (func (param i32 i32 i32) (result i32)))
  (type (;10;) (func (param i32 i32) (result (ref 0))))
  (type (;11;) (func (param i64 i64) (result (ref 0))))
  (type (;12;) (func (param i64 i64) (result (ref 0))))
  (type (;13;) (func (param i32 i32 i32) (result i32)))
  (type (;14;) (func (param i64 i64) (result (ref 0))))
  (type (;15;) (func (param f32) (result i32)))
  (type (;16;) (func (param f32) (result i32)))
  (type (;17;) (func (param f32 f32) (result f32)))
  (type (;18;) (func (param f32 f32) (result f32)))
  (type (;19;) (func (param f32 f32) (result f32)))
  (type (;20;) (func (param f64) (result i32)))
  (type (;21;) (func (param f64) (result i32)))
  (type (;22;) (func (param f64) (result i32)))
  (type (;23;) (func (param f64 f64) (result f64)))
  (type (;24;) (func (param f64 f64 f64) (result f64)))
  (type (;25;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;26;) (func (param i32 eqref) (result i32)))
  (type (;27;) (func (result i32)))
  (type (;28;) (array (mut v128)))
  (type (;29;) (struct (field (ref 28)) (field i32) (field i32)))
  (type (;30;) (struct (field (ref 28)) (field i32) (field i32)))
  (type (;31;) (struct (field (ref 28)) (field i32) (field i32)))
  (type (;32;) (struct (field (mut (ref 28))) (field (mut i32)) (field (mut i32))))
  (type (;33;) (struct (field (mut (ref 28))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 25)))
  (memory (;0;) 1)
  (export "main" (func 21))
  (export "memory" (memory 0))
  (func (;1;) (type 6) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
    i32.extend8_s
  )
  (func (;2;) (type 7) (param i32) (result i32)
    local.get 0
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
      local.get 0
      i32.sub
      i32.extend16_s
    else
      local.get 0
    end
  )
  (func (;3;) (type 8) (param i32) (result i32)
    local.get 0
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    i32.eq
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      call 2
    end
  )
  (func (;4;) (type 9) (param i32 i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_s
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      local.get 1
      i32.lt_s
      if (result i32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 2
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 2
        else
          local.get 0
        end
      end
    end
  )
  (func (;5;) (type 10) (param i32 i32) (result (ref 0))
    (local i32)
    local.get 0
    local.get 1
    i32.add
    local.set 2
    local.get 0
    local.get 2
    i32.xor
    local.get 1
    local.get 2
    i32.xor
    i32.and
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      local.get 2
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;6;) (type 11) (param i64 i64) (result (ref 0))
    (local i64)
    local.get 0
    i64.const 0
    i64.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i64.const 0
      i64.eq
    end
    if (result eqref) ;; label = @1
      i32.const 1
      i64.const 0
      struct.new 4
    else
      local.get 0
      i64.const -9223372036854775808
      i64.eq
      if (result i32) ;; label = @2
        local.get 1
        i64.const -1
        i64.eq
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 1
        i64.const -9223372036854775808
        i64.eq
        if (result i32) ;; label = @3
          local.get 0
          i64.const -1
          i64.eq
        else
          i32.const 0
        end
      end
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 0
      else
        local.get 0
        local.get 1
        i64.mul
        local.set 2
        local.get 2
        local.get 1
        i64.div_s
        local.get 0
        i64.eq
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 2
          struct.new 4
        else
          i32.const 0
          struct.new 0
        end
      end
    end
    ref.cast (ref 0)
  )
  (func (;7;) (type 12) (param i64 i64) (result (ref 0))
    local.get 1
    i64.const 0
    i64.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i64.const -9223372036854775808
      i64.eq
      if (result i32) ;; label = @2
        local.get 1
        i64.const -1
        i64.eq
      else
        i32.const 0
      end
    end
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      local.get 0
      local.get 1
      i64.div_s
      struct.new 4
    end
    ref.cast (ref 0)
  )
  (func (;8;) (type 13) (param i32 i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_u
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      local.get 1
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 2
        i32.gt_u
        if (result i32) ;; label = @3
          local.get 2
        else
          local.get 0
        end
      end
    end
  )
  (func (;9;) (type 14) (param i64 i64) (result (ref 0))
    local.get 1
    i64.const 0
    i64.ne
    if (result i32) ;; label = @1
      local.get 0
      i64.const -1
      local.get 1
      i64.div_u
      i64.gt_u
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      local.get 0
      local.get 1
      i64.mul
      struct.new 4
    end
    ref.cast (ref 0)
  )
  (func (;10;) (type 15) (param f32) (result i32)
    local.get 0
    local.get 0
    f32.ne
  )
  (func (;11;) (type 16) (param f32) (result i32)
    local.get 0
    i32.reinterpret_f32
    i32.const -2147483648
    i32.and
    i32.const 0
    i32.ne
  )
  (func (;12;) (type 17) (param f32 f32) (result f32)
    local.get 0
    i32.reinterpret_f32
    i32.const 2147483647
    i32.and
    local.get 1
    i32.reinterpret_f32
    i32.const -2147483648
    i32.and
    i32.or
    f32.reinterpret_i32
  )
  (func (;13;) (type 18) (param f32 f32) (result f32)
    local.get 0
    call 10
    if (result f32) ;; label = @1
      local.get 0
    else
      local.get 1
      call 10
      if (result f32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 1
        f32.lt
        if (result f32) ;; label = @3
          local.get 0
        else
          local.get 1
          local.get 0
          f32.lt
          if (result f32) ;; label = @4
            local.get 1
          else
            local.get 0
            f32.const 0x0p+0 (;=0;)
            f32.eq
            if (result i32) ;; label = @5
              local.get 1
              f32.const 0x0p+0 (;=0;)
              f32.eq
            else
              i32.const 0
            end
            if (result f32) ;; label = @5
              local.get 0
              call 11
              if (result f32) ;; label = @6
                local.get 0
              else
                local.get 1
              end
            else
              local.get 0
            end
          end
        end
      end
    end
  )
  (func (;14;) (type 19) (param f32 f32) (result f32)
    local.get 0
    call 10
    if (result f32) ;; label = @1
      local.get 0
    else
      local.get 1
      call 10
      if (result f32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 1
        f32.gt
        if (result f32) ;; label = @3
          local.get 0
        else
          local.get 1
          local.get 0
          f32.gt
          if (result f32) ;; label = @4
            local.get 1
          else
            local.get 0
            f32.const 0x0p+0 (;=0;)
            f32.eq
            if (result i32) ;; label = @5
              local.get 1
              f32.const 0x0p+0 (;=0;)
              f32.eq
            else
              i32.const 0
            end
            if (result f32) ;; label = @5
              local.get 0
              call 11
              if (result f32) ;; label = @6
                local.get 1
              else
                local.get 0
              end
            else
              local.get 0
            end
          end
        end
      end
    end
  )
  (func (;15;) (type 20) (param f64) (result i32)
    local.get 0
    local.get 0
    f64.ne
  )
  (func (;16;) (type 21) (param f64) (result i32)
    local.get 0
    i64.reinterpret_f64
    i64.const 9223372036854775807
    i64.and
    i64.const 9218868437227405312
    i64.eq
  )
  (func (;17;) (type 22) (param f64) (result i32)
    local.get 0
    i64.reinterpret_f64
    i64.const -9223372036854775808
    i64.and
    i64.const 0
    i64.ne
  )
  (func (;18;) (type 23) (param f64 f64) (result f64)
    local.get 0
    call 15
    if (result f64) ;; label = @1
      local.get 0
    else
      local.get 1
      call 15
      if (result f64) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 1
        f64.gt
        if (result f64) ;; label = @3
          local.get 0
        else
          local.get 1
          local.get 0
          f64.gt
          if (result f64) ;; label = @4
            local.get 1
          else
            local.get 0
            f64.const 0x0p+0 (;=0;)
            f64.eq
            if (result i32) ;; label = @5
              local.get 1
              f64.const 0x0p+0 (;=0;)
              f64.eq
            else
              i32.const 0
            end
            if (result f64) ;; label = @5
              local.get 0
              call 17
              if (result f64) ;; label = @6
                local.get 1
              else
                local.get 0
              end
            else
              local.get 0
            end
          end
        end
      end
    end
  )
  (func (;19;) (type 24) (param f64 f64 f64) (result f64)
    local.get 1
    call 15
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      call 15
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      local.get 2
      f64.gt
    end
    if (result f64) ;; label = @1
      unreachable
    else
      local.get 0
      call 15
      if (result f64) ;; label = @2
        local.get 0
      else
        local.get 0
        local.get 1
        f64.lt
        if (result f64) ;; label = @3
          local.get 1
        else
          local.get 0
          local.get 2
          f64.gt
          if (result f64) ;; label = @4
            local.get 2
          else
            local.get 0
          end
        end
      end
    end
  )
  (func (;20;) (type 26) (param i32 eqref) (result i32)
    (local (ref 30) (ref 28) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 30)
    local.set 2
    local.get 2
    struct.get 30 0
    local.set 3
    local.get 2
    struct.get 30 1
    local.set 4
    local.get 2
    struct.get 30 2
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
              array.get 28
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
              array.get 28
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
              array.get 28
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
              array.get 28
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
                array.get 28
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 28
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
                array.get 28
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
            array.get 28
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
  (func (;21;) (type 27) (result i32)
    (local f32 f64 f32 f64 eqref eqref eqref i32 eqref i32 eqref i32 eqref i32 eqref i32)
    i32.const 2143294004
    f32.reinterpret_i32
    local.set 0
    i64.const 9221120237041095220
    f64.reinterpret_i64
    local.set 1
    i32.const -2147483648
    f32.reinterpret_i32
    local.set 2
    i64.const -9223372036854775808
    f64.reinterpret_i64
    local.set 3
    i32.const 2147483647
    i32.const 1
    call 5
    local.set 4
    i64.const -1
    i64.const 2
    call 9
    local.set 5
    i64.const 3037000499
    i64.const 3037000499
    call 6
    local.set 6
    i32.const 127
    i32.const 1
    call 1
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    i32.eq
    if (result i32) ;; label = @1
      i32.const 0
      i32.const 32767
      i32.sub
      i32.extend16_s
      call 3
      i32.const 32767
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 11
      i32.const 0
      i32.const 10
      call 4
      i32.const 10
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 3
      i32.const 4
      i32.const 9
      call 8
      i32.const 4
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 4
      local.set 8
      block ;; label = @2
        local.get 8
        ref.cast (ref 0)
        struct.get 0 0
        i32.const 0
        i32.eq
        if ;; label = @3
          i32.const 1
          local.set 9
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 9
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 9
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 5
      local.set 10
      block ;; label = @2
        local.get 10
        ref.cast (ref 0)
        struct.get 0 0
        i32.const 0
        i32.eq
        if ;; label = @3
          i32.const 1
          local.set 11
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 11
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 11
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 6
      local.set 12
      block ;; label = @2
        local.get 12
        ref.cast (ref 0)
        struct.get 0 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 12
          ref.cast (ref 4)
          struct.get 4 1
          i64.const 9223372030926249001
          i64.eq
        else
          i32.const 0
        end
        if ;; label = @3
          i32.const 1
          local.set 13
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 13
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 13
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i64.const -9223372036854775808
      i64.const -1
      call 7
      local.set 14
      block ;; label = @2
        local.get 14
        ref.cast (ref 0)
        struct.get 0 0
        i32.const 0
        i32.eq
        if ;; label = @3
          i32.const 1
          local.set 15
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 15
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 15
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.get 2
      call 13
      i32.reinterpret_f32
      i32.const -2147483648
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 2
      f32.const 0x0p+0 (;=0;)
      call 14
      i32.reinterpret_f32
      i32.const 0
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 3
      f64.const 0x0p+0 (;=0;)
      f64.const 0x1p+0 (;=1;)
      call 19
      i64.reinterpret_f64
      i64.const -9223372036854775808
      i64.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      f32.const 0x1p+0 (;=1;)
      call 13
      i32.reinterpret_f32
      i32.const 2143294004
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f64.const 0x1p+0 (;=1;)
      local.get 1
      call 18
      i64.reinterpret_f64
      i64.const 9221120237041095220
      i64.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x1p+0 (;=1;)
      f32.neg
      f32.sqrt
      call 10
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f64.const 0x1p+0 (;=1;)
      f64.const 0x0p+0 (;=0;)
      f64.div
      call 16
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x1.cp+1 (;=3.5;)
      local.get 2
      call 12
      i32.reinterpret_f32
      i32.const -1067450368
      i32.eq
    else
      i32.const 0
    end
    local.set 7
    local.get 7
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x656d756e 0x3a636972 0x6874616d 0x00000000
      array.new_fixed 28 1
      i32.const 0
      i32.const 12
      struct.new 30
      call 20
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 28 1
      i32.const 0
      i32.const 4
      struct.new 30
      call 20
    end
  )
)
