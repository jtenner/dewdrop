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
  (type (;11;) (func (param eqref i32 i32) (result eqref)))
  (type (;12;) (func (param eqref i32 i32) (result eqref)))
  (type (;13;) (struct (field eqref) (field (ref 0))))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param i32) (result i32)))
  (type (;18;) (func (param i32) (result i64)))
  (type (;19;) (func (param i64) (result i32)))
  (type (;20;) (func (param i32 i32) (result i64)))
  (type (;21;) (func (param i32 i32 i32 i32 i32) (result i64)))
  (type (;22;) (func (result (ref 0))))
  (type (;23;) (func (param eqref) (result (ref 13))))
  (type (;24;) (func (param (ref 13)) (result i32)))
  (type (;25;) (func (param (ref 13)) (result i32)))
  (type (;26;) (func (param eqref) (result (ref 13))))
  (type (;27;) (func (param (ref 13)) (result (ref 8))))
  (type (;28;) (func (result i32)))
  (type (;29;) (array (mut v128)))
  (type (;30;) (struct (field (ref 29)) (field i32) (field i32)))
  (type (;31;) (struct (field (ref 29)) (field i32) (field i32)))
  (type (;32;) (struct (field (ref 29)) (field i32) (field i32)))
  (type (;33;) (struct (field (mut (ref 29))) (field (mut i32)) (field (mut i32))))
  (type (;34;) (struct (field (mut (ref 29))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 16))
  (func (;0;) (type 11) (param eqref i32 i32) (result eqref)
    (local (ref 30) (ref 29) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 30)
    local.set 3
    local.get 3
    struct.get 30 2
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
    struct.get 30 0
    local.set 4
    local.get 3
    struct.get 30 1
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
      array.get 29
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
      array.get 29
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
    struct.get 30 1
    local.get 1
    i32.add
    local.get 2
    struct.new 32
  )
  (func (;1;) (type 12) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 0
  )
  (func (;2;) (type 14) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 32)
    struct.get 32 2
  )
  (func (;3;) (type 15) (param eqref i32) (result i32)
    (local (ref 32) (ref 29) i32)
    local.get 0
    ref.cast (ref 32)
    local.set 2
    local.get 1
    local.get 2
    struct.get 32 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 32 0
    local.set 3
    local.get 2
    struct.get 32 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 29
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;4;) (type 16) (param i32) (result i32)
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
  (func (;5;) (type 17) (param i32) (result i32)
    local.get 0
  )
  (func (;6;) (type 18) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;7;) (type 19) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;8;) (type 20) (param i32 i32) (result i64)
    local.get 0
    call 6
    local.get 1
    call 6
    i64.const 32
    i64.shl
    i64.or
  )
  (func (;9;) (type 21) (param i32 i32 i32 i32 i32) (result i64)
    (local i32 i32 i32 i32)
    local.get 0
    call 5
    local.set 5
    local.get 1
    call 5
    local.set 6
    local.get 2
    call 5
    local.set 7
    local.get 3
    call 5
    local.set 8
    local.get 0
    i32.const 127
    i32.le_u
    if (result i64) ;; label = @1
      local.get 5
      i32.const 1
      call 8
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
        call 4
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
        call 8
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
          call 4
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 2
          call 4
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
          call 8
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
            call 4
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 2
            call 4
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 3
            call 4
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
            call 8
          else
            unreachable
          end
        end
      end
    end
  )
  (func (;10;) (type 22) (result (ref 0))
    (local eqref i32)
    i32.const 1
    local.set 1
    i32.const 0
    local.get 1
    array.new 0
    ref.cast (ref 0)
  )
  (func (;11;) (type 23) (param eqref) (result (ref 13))
    local.get 0
    call 10
    ref.cast (ref 0)
    struct.new 13
    ref.cast (ref 13)
  )
  (func (;12;) (type 24) (param (ref 13)) (result i32)
    local.get 0
    ref.cast (ref 13)
    struct.get 13 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.get 0
    ref.cast (ref 13)
    struct.get 13 0
    call 2
    i32.lt_u
  )
  (func (;13;) (type 25) (param (ref 13)) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i64 i32 i32)
    local.get 0
    ref.cast (ref 13)
    struct.get 13 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.set 1
    local.get 0
    ref.cast (ref 13)
    struct.get 13 0
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
      ref.cast (ref 13)
      struct.get 13 0
      local.get 1
      call 3
      local.set 4
      local.get 3
      i32.const 2
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        ref.cast (ref 13)
        struct.get 13 0
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
        ref.cast (ref 13)
        struct.get 13 0
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
        ref.cast (ref 13)
        struct.get 13 0
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
      call 9
      local.set 8
      local.get 8
      i64.const 4294967295
      i64.and
      call 7
      local.set 9
      local.get 8
      i64.const 32
      i64.shr_u
      call 7
      local.set 10
      local.get 0
      ref.cast (ref 13)
      struct.get 13 1
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      local.get 10
      i32.add
      array.set 0
      local.get 9
    end
  )
  (func (;14;) (type 26) (param eqref) (result (ref 13))
    local.get 0
    call 11
    ref.cast (ref 13)
  )
  (func (;15;) (type 27) (param (ref 13)) (result (ref 8))
    local.get 0
    call 12
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 0
      call 13
      struct.new 9
    else
      i32.const 0
      struct.new 8
    end
    ref.cast (ref 8)
  )
  (func (;16;) (type 28) (result i32)
    (local i32 eqref i32)
    v128.const i32x4 0x0000a9c3 0x00000000 0x00000000 0x00000000
    array.new_fixed 29 1
    i32.const 0
    i32.const 2
    struct.new 30
    i32.const 1
    i32.const 1
    call 1
    call 14
    call 15
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        local.get 1
        ref.cast (ref 9)
        struct.get 9 1
        local.set 0
        local.get 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
)
