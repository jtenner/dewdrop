(module
  (type (;0;) (func (param eqref i32 i32) (result eqref)))
  (type (;1;) (func (param eqref i32 i32) (result eqref)))
  (type (;2;) (struct (field eqref)))
  (type (;3;) (struct (field eqref) (field (ref 2))))
  (type (;4;) (func (param eqref) (result i32)))
  (type (;5;) (func (param eqref i32) (result i32)))
  (type (;6;) (func (param i32) (result i32)))
  (type (;7;) (func (param i32) (result i32)))
  (type (;8;) (func (param i32) (result i64)))
  (type (;9;) (func (param i64) (result i32)))
  (type (;10;) (func (param i32 i32) (result i64)))
  (type (;11;) (func (param i32 i32 i32 i32 i32) (result i64)))
  (type (;12;) (func (result (ref 2))))
  (type (;13;) (func (param eqref) (result (ref 3))))
  (type (;14;) (func (param (ref 3)) (result i32)))
  (type (;15;) (func (param eqref) (result (ref 3))))
  (type (;16;) (func (param (ref 3)) (result i32)))
  (type (;17;) (func (result i32)))
  (type (;18;) (array (mut v128)))
  (type (;19;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;22;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;23;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;24;) (array (mut i32)))
  (type (;25;) (array (mut i64)))
  (type (;26;) (array (mut f32)))
  (type (;27;) (array (mut f64)))
  (type (;28;) (array (mut v128)))
  (type (;29;) (array (mut eqref)))
  (export "main" (func 15))
  (func (;0;) (type 0) (param eqref i32 i32) (result eqref)
    (local (ref 19) (ref 18) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 19)
    local.set 3
    local.get 3
    struct.get 19 2
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
    struct.get 19 0
    local.set 4
    local.get 3
    struct.get 19 1
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
      array.get 18
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
      array.get 18
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
    struct.get 19 1
    local.get 1
    i32.add
    local.get 2
    struct.new 21
  )
  (func (;1;) (type 1) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 0
  )
  (func (;2;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 21)
    struct.get 21 2
  )
  (func (;3;) (type 5) (param eqref i32) (result i32)
    (local (ref 21) (ref 18) i32)
    local.get 0
    ref.cast (ref 21)
    local.set 2
    local.get 1
    local.get 2
    struct.get 21 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 21 0
    local.set 3
    local.get 2
    struct.get 21 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 18
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;4;) (type 6) (param i32) (result i32)
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
  (func (;5;) (type 7) (param i32) (result i32)
    local.get 0
  )
  (func (;6;) (type 8) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;7;) (type 9) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;8;) (type 10) (param i32 i32) (result i64)
    local.get 0
    call 6
    local.get 1
    call 6
    i64.const 32
    i64.shl
    i64.or
  )
  (func (;9;) (type 11) (param i32 i32 i32 i32 i32) (result i64)
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
  (func (;10;) (type 12) (result (ref 2))
    (local eqref i32)
    i32.const 1
    local.set 1
    i32.const 0
    local.get 1
    array.new 24
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;11;) (type 13) (param eqref) (result (ref 3))
    local.get 0
    call 10
    ref.cast (ref 2)
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;12;) (type 14) (param (ref 3)) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i64 i32 i32)
    local.get 0
    struct.get 3 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 24)
    i32.const 0
    array.get 24
    local.set 1
    local.get 0
    struct.get 3 0
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
      struct.get 3 0
      local.get 1
      call 3
      local.set 4
      local.get 3
      i32.const 2
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 3 0
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
        struct.get 3 0
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
        struct.get 3 0
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
      struct.get 3 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 24)
      i32.const 0
      local.get 1
      local.get 10
      i32.add
      array.set 24
      local.get 9
    end
  )
  (func (;13;) (type 15) (param eqref) (result (ref 3))
    local.get 0
    call 11
    ref.cast (ref 3)
  )
  (func (;14;) (type 16) (param (ref 3)) (result i32)
    local.get 0
    call 12
  )
  (func (;15;) (type 17) (result i32)
    v128.const i32x4 0x0000a9c3 0x00000000 0x00000000 0x00000000
    array.new_fixed 18 1
    i32.const 0
    i32.const 2
    struct.new 19
    i32.const 1
    i32.const 1
    call 1
    call 13
    call 14
  )
)
