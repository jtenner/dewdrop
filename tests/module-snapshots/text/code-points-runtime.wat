(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref i32 i32) (result eqref)))
  (type (;9;) (func (param eqref i32 i32) (result eqref)))
  (type (;10;) (struct (field eqref) (field (ref 0))))
  (type (;11;) (struct (field eqref) (field (ref 0))))
  (type (;12;) (func (param eqref) (result i32)))
  (type (;13;) (func (param eqref i32) (result i32)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param i32) (result i32)))
  (type (;18;) (func (param i32) (result i64)))
  (type (;19;) (func (param i64) (result i32)))
  (type (;20;) (func (param i32 i32) (result i64)))
  (type (;21;) (func (param i32 i32 i32 i32 i32) (result i64)))
  (type (;22;) (func (result (ref 0))))
  (type (;23;) (func (param eqref) (result (ref 10))))
  (type (;24;) (func (param eqref) (result (ref 11))))
  (type (;25;) (func (param (ref 10)) (result i32)))
  (type (;26;) (func (param (ref 11)) (result i32)))
  (type (;27;) (func (param (ref 10)) (result i32)))
  (type (;28;) (func (param (ref 11)) (result i32)))
  (type (;29;) (func (param eqref) (result (ref 10))))
  (type (;30;) (func (param eqref) (result (ref 11))))
  (type (;31;) (func (param (ref 10)) (result i32)))
  (type (;32;) (func (param (ref 10)) (result i32)))
  (type (;33;) (func (param (ref 11)) (result i32)))
  (type (;34;) (func (param (ref 11)) (result i32)))
  (type (;35;) (func))
  (type (;36;) (array (mut v128)))
  (type (;37;) (struct (field (ref 36)) (field i32) (field i32)))
  (type (;38;) (struct (field (ref 36)) (field i32) (field i32)))
  (type (;39;) (struct (field (ref 36)) (field i32) (field i32)))
  (type (;40;) (struct (field (mut (ref 36))) (field (mut i32)) (field (mut i32))))
  (type (;41;) (struct (field (mut (ref 36))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 25))
  (func (;0;) (type 8) (param eqref i32 i32) (result eqref)
    (local (ref 37) (ref 36) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 37)
    local.set 3
    local.get 3
    struct.get 37 2
    local.set 5
    local.get 1
    local.get 5
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    local.get 5
    local.get 1
    i32.sub
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    struct.get 37 0
    local.set 4
    local.get 3
    struct.get 37 1
    local.get 1
    i32.add
    local.set 6
    local.get 1
    local.get 2
    i32.add
    local.set 7
    local.get 1
    i32.eqz
    i32.eqz
    if ;; label = @1
      local.get 4
      local.get 6
      i32.const 4
      i32.shr_u
      array.get 36
      local.get 6
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
        unreachable
      end
    end
    local.get 7
    local.get 5
    i32.lt_u
    if ;; label = @1
      local.get 6
      local.get 2
      i32.add
      local.set 6
      local.get 4
      local.get 6
      i32.const 4
      i32.shr_u
      array.get 36
      local.get 6
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
        unreachable
      end
    end
    local.get 4
    local.get 3
    struct.get 37 1
    local.get 1
    i32.add
    local.get 2
    struct.new 39
  )
  (func (;1;) (type 9) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 0
  )
  (func (;2;) (type 12) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 37)
    struct.get 37 2
  )
  (func (;3;) (type 13) (param eqref i32) (result i32)
    (local (ref 37) (ref 36) i32)
    local.get 0
    ref.cast (ref 37)
    local.set 2
    local.get 1
    local.get 2
    struct.get 37 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 37 0
    local.set 3
    local.get 2
    struct.get 37 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 36
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;4;) (type 14) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 39)
    struct.get 39 2
  )
  (func (;5;) (type 15) (param eqref i32) (result i32)
    (local (ref 39) (ref 36) i32)
    local.get 0
    ref.cast (ref 39)
    local.set 2
    local.get 1
    local.get 2
    struct.get 39 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 39 0
    local.set 3
    local.get 2
    struct.get 39 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 36
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;6;) (type 16) (param i32) (result i32)
    local.get 0
    i32.const 128
    i32.ge_u
    if (result i32) ;; label = @1
      local.get 0
      i32.const 191
      i32.le_u
    else
      i32.const 0
    end
  )
  (func (;7;) (type 17) (param i32) (result i32)
    local.get 0
  )
  (func (;8;) (type 18) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;9;) (type 19) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;10;) (type 20) (param i32 i32) (result i64)
    local.get 0
    call 8
    local.get 1
    call 8
    i64.const 32
    i64.shl
    i64.or
  )
  (func (;11;) (type 21) (param i32 i32 i32 i32 i32) (result i64)
    (local i32 i32 i32 i32)
    local.get 0
    call 7
    local.set 5
    local.get 1
    call 7
    local.set 6
    local.get 2
    call 7
    local.set 7
    local.get 3
    call 7
    local.set 8
    local.get 0
    i32.const 127
    i32.le_u
    if (result i64) ;; label = @1
      local.get 5
      i32.const 1
      call 10
    else
      local.get 0
      i32.const 194
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        i32.const 223
        i32.le_u
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        local.get 4
        i32.const 2
        i32.ge_u
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        local.get 1
        call 6
      else
        i32.const 0
      end
      if (result i64) ;; label = @2
        local.get 5
        i32.const 31
        i32.and
        i32.const 6
        i32.shl
        local.get 6
        i32.const 63
        i32.and
        i32.or
        i32.const 2
        call 10
      else
        local.get 0
        i32.const 224
        i32.ge_u
        if (result i32) ;; label = @3
          local.get 0
          i32.const 239
          i32.le_u
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 4
          i32.const 3
          i32.ge_u
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 1
          call 6
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 2
          call 6
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 0
          i32.const 224
          i32.ne
          if (result i32) ;; label = @4
            i32.const 1
          else
            local.get 1
            i32.const 160
            i32.ge_u
          end
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 0
          i32.const 237
          i32.ne
          if (result i32) ;; label = @4
            i32.const 1
          else
            local.get 1
            i32.const 160
            i32.lt_u
          end
        else
          i32.const 0
        end
        if (result i64) ;; label = @3
          local.get 5
          i32.const 15
          i32.and
          i32.const 12
          i32.shl
          local.get 6
          i32.const 63
          i32.and
          i32.const 6
          i32.shl
          i32.or
          local.get 7
          i32.const 63
          i32.and
          i32.or
          i32.const 3
          call 10
        else
          local.get 0
          i32.const 240
          i32.ge_u
          if (result i32) ;; label = @4
            local.get 0
            i32.const 244
            i32.le_u
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 4
            i32.const 4
            i32.ge_u
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 1
            call 6
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 2
            call 6
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 3
            call 6
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 0
            i32.const 240
            i32.ne
            if (result i32) ;; label = @5
              i32.const 1
            else
              local.get 1
              i32.const 144
              i32.ge_u
            end
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 0
            i32.const 244
            i32.ne
            if (result i32) ;; label = @5
              i32.const 1
            else
              local.get 1
              i32.const 144
              i32.lt_u
            end
          else
            i32.const 0
          end
          if (result i64) ;; label = @4
            local.get 5
            i32.const 7
            i32.and
            i32.const 18
            i32.shl
            local.get 6
            i32.const 63
            i32.and
            i32.const 12
            i32.shl
            i32.or
            local.get 7
            i32.const 63
            i32.and
            i32.const 6
            i32.shl
            i32.or
            local.get 8
            i32.const 63
            i32.and
            i32.or
            i32.const 4
            call 10
          else
            unreachable
          end
        end
      end
    end
  )
  (func (;12;) (type 22) (result (ref 0))
    (local eqref i32)
    i32.const 1
    local.set 1
    i32.const 0
    local.get 1
    array.new 0
    ref.cast (ref 0)
  )
  (func (;13;) (type 23) (param eqref) (result (ref 10))
    local.get 0
    call 12
    ref.cast (ref 0)
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;14;) (type 24) (param eqref) (result (ref 11))
    local.get 0
    call 12
    ref.cast (ref 0)
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;15;) (type 25) (param (ref 10)) (result i32)
    local.get 0
    struct.get 10 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.get 0
    struct.get 10 0
    call 2
    i32.lt_u
  )
  (func (;16;) (type 26) (param (ref 11)) (result i32)
    local.get 0
    struct.get 11 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.get 0
    struct.get 11 0
    call 4
    i32.lt_u
  )
  (func (;17;) (type 27) (param (ref 10)) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i64 i32 i32)
    local.get 0
    struct.get 10 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.set 1
    local.get 0
    struct.get 10 0
    call 2
    local.set 2
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 2
      local.get 1
      i32.sub
      local.set 3
      local.get 0
      struct.get 10 0
      local.get 1
      call 3
      local.set 4
      local.get 3
      i32.const 2
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 10 0
        local.get 1
        i32.const 1
        i32.add
        call 3
      else
        i32.const 0
      end
      local.set 5
      local.get 3
      i32.const 3
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 10 0
        local.get 1
        i32.const 2
        i32.add
        call 3
      else
        i32.const 0
      end
      local.set 6
      local.get 3
      i32.const 4
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 10 0
        local.get 1
        i32.const 3
        i32.add
        call 3
      else
        i32.const 0
      end
      local.set 7
      local.get 4
      local.get 5
      local.get 6
      local.get 7
      local.get 3
      call 11
      local.set 8
      local.get 8
      i64.const 4294967295
      i64.and
      call 9
      local.set 9
      local.get 8
      i64.const 32
      i64.shr_u
      call 9
      local.set 10
      local.get 0
      struct.get 10 1
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      local.get 10
      i32.add
      array.set 0
      local.get 9
    end
  )
  (func (;18;) (type 28) (param (ref 11)) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i64 i32 i32)
    local.get 0
    struct.get 11 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.set 1
    local.get 0
    struct.get 11 0
    call 4
    local.set 2
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 2
      local.get 1
      i32.sub
      local.set 3
      local.get 0
      struct.get 11 0
      local.get 1
      call 5
      local.set 4
      local.get 3
      i32.const 2
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 11 0
        local.get 1
        i32.const 1
        i32.add
        call 5
      else
        i32.const 0
      end
      local.set 5
      local.get 3
      i32.const 3
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 11 0
        local.get 1
        i32.const 2
        i32.add
        call 5
      else
        i32.const 0
      end
      local.set 6
      local.get 3
      i32.const 4
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 11 0
        local.get 1
        i32.const 3
        i32.add
        call 5
      else
        i32.const 0
      end
      local.set 7
      local.get 4
      local.get 5
      local.get 6
      local.get 7
      local.get 3
      call 11
      local.set 8
      local.get 8
      i64.const 4294967295
      i64.and
      call 9
      local.set 9
      local.get 8
      i64.const 32
      i64.shr_u
      call 9
      local.set 10
      local.get 0
      struct.get 11 1
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      local.get 10
      i32.add
      array.set 0
      local.get 9
    end
  )
  (func (;19;) (type 29) (param eqref) (result (ref 10))
    local.get 0
    call 13
    ref.cast (ref 10)
  )
  (func (;20;) (type 30) (param eqref) (result (ref 11))
    local.get 0
    call 14
    ref.cast (ref 11)
  )
  (func (;21;) (type 31) (param (ref 10)) (result i32)
    local.get 0
    call 15
  )
  (func (;22;) (type 32) (param (ref 10)) (result i32)
    local.get 0
    call 17
  )
  (func (;23;) (type 33) (param (ref 11)) (result i32)
    local.get 0
    call 16
  )
  (func (;24;) (type 34) (param (ref 11)) (result i32)
    local.get 0
    call 18
  )
  (func (;25;) (type 35)
    (local eqref)
    v128.const i32x4 0xe2a2c224 0x90f0ac82 0x0000888d 0x00000000
    array.new_fixed 36 1
    i32.const 0
    i32.const 10
    struct.new 37
    call 19
    local.set 0
    local.get 0
    ref.cast (ref 10)
    call 21
    v128.const i32x4 0x69727473 0x6820676e 0x66207361 0x74737269
    array.new_fixed 36 1
    i32.const 0
    i32.const 16
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 22
    i32.const 36
    i32.eq
    v128.const i32x4 0x69637361 0x63732069 0x72616c61 0x00000000
    array.new_fixed 36 1
    i32.const 0
    i32.const 12
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 22
    i32.const 162
    i32.eq
    v128.const i32x4 0x2d6f7774 0x65747962 0x61637320 0x2072616c
    v128.const i32x4 0x20646e61 0x72616873 0x63206465 0x6f737275
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 36 3
    i32.const 0
    i32.const 33
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 22
    i32.const 8364
    i32.eq
    v128.const i32x4 0x65726874 0x79622d65 0x73206574 0x616c6163
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 36 2
    i32.const 0
    i32.const 17
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 22
    i32.const 66376
    i32.eq
    v128.const i32x4 0x72756f66 0x7479622d 0x63732065 0x72616c61
    array.new_fixed 36 1
    i32.const 0
    i32.const 16
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 21
    i32.eqz
    v128.const i32x4 0x69727473 0x6520676e 0x75616878 0x64657473
    array.new_fixed 36 1
    i32.const 0
    i32.const 16
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    array.new_fixed 36 0
    i32.const 0
    i32.const 0
    struct.new 37
    call 19
    local.set 0
    local.get 0
    ref.cast (ref 10)
    call 21
    i32.eqz
    v128.const i32x4 0x74706d65 0x74732079 0x676e6972 0x00000000
    array.new_fixed 36 1
    i32.const 0
    i32.const 12
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0xa2c22430 0xf0ac82e2 0x7a888d90 0x00000000
    array.new_fixed 36 1
    i32.const 0
    i32.const 12
    struct.new 37
    local.set 0
    local.get 0
    i32.const 1
    i32.const 10
    call 1
    call 20
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 24
    i32.const 36
    i32.eq
    v128.const i32x4 0x77656976 0x63736120 0x00006969 0x00000000
    array.new_fixed 36 1
    i32.const 0
    i32.const 10
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 24
    i32.const 162
    i32.eq
    v128.const i32x4 0x77656976 0x6f777420 0x7479622d 0x00000065
    array.new_fixed 36 1
    i32.const 0
    i32.const 13
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 24
    i32.const 8364
    i32.eq
    v128.const i32x4 0x77656976 0x72687420 0x622d6565 0x00657479
    array.new_fixed 36 1
    i32.const 0
    i32.const 15
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 24
    i32.const 66376
    i32.eq
    v128.const i32x4 0x77656976 0x756f6620 0x79622d72 0x00006574
    array.new_fixed 36 1
    i32.const 0
    i32.const 14
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 23
    i32.eqz
    v128.const i32x4 0x77656976 0x68786520 0x74737561 0x00006465
    array.new_fixed 36 1
    i32.const 0
    i32.const 14
    struct.new 37
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
