(module
  (type (;0;) (struct (field eqref)))
  (type (;1;) (struct (field eqref) (field (ref 0))))
  (type (;2;) (func (param eqref) (result i32)))
  (type (;3;) (func (param eqref i32) (result i32)))
  (type (;4;) (func (param i32) (result i32)))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param i32) (result i64)))
  (type (;7;) (func (param i64) (result i32)))
  (type (;8;) (func (param i32 i32) (result i64)))
  (type (;9;) (func (param i32 i32 i32 i32 i32) (result i64)))
  (type (;10;) (func (result (ref 0))))
  (type (;11;) (func (param eqref) (result (ref 1))))
  (type (;12;) (func (param (ref 1)) (result i32)))
  (type (;13;) (func (param eqref) (result (ref 1))))
  (type (;14;) (func (param (ref 1)) (result i32)))
  (type (;15;) (func (result i32)))
  (type (;16;) (array (mut v128)))
  (type (;17;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;19;) (struct (field (ref 16)) (field i32) (field i32)))
  (type (;20;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (type (;21;) (struct (field (mut (ref 16))) (field (mut i32)) (field (mut i32))))
  (type (;22;) (array (mut i32)))
  (type (;23;) (array (mut i64)))
  (type (;24;) (array (mut f32)))
  (type (;25;) (array (mut f64)))
  (type (;26;) (array (mut v128)))
  (type (;27;) (array (mut eqref)))
  (export "main" (func 13))
  (func (;0;) (type 2) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 17)
    struct.get 17 2
  )
  (func (;1;) (type 3) (param eqref i32) (result i32)
    (local (ref 17) (ref 16) i32)
    local.get 0
    ref.cast (ref 17)
    local.set 2
    local.get 1
    local.get 2
    struct.get 17 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 17 0
    local.set 3
    local.get 2
    struct.get 17 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 16
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;2;) (type 4) (param i32) (result i32)
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
  (func (;3;) (type 5) (param i32) (result i32)
    local.get 0
  )
  (func (;4;) (type 6) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;5;) (type 7) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;6;) (type 8) (param i32 i32) (result i64)
    local.get 0
    call 4
    local.get 1
    call 4
    i64.const 32
    i64.shl
    i64.or
  )
  (func (;7;) (type 9) (param i32 i32 i32 i32 i32) (result i64)
    (local i32 i32 i32 i32)
    local.get 0
    call 3
    local.set 5
    local.get 1
    call 3
    local.set 6
    local.get 2
    call 3
    local.set 7
    local.get 3
    call 3
    local.set 8
    local.get 0
    i32.const 127
    i32.le_u
    if (result i64) ;; label = @1
      local.get 5
      i32.const 1
      call 6
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
        call 2
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
        call 6
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
          call 2
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 2
          call 2
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
          call 6
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
            call 2
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 2
            call 2
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            local.get 3
            call 2
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
            call 6
          else
            unreachable
          end
        end
      end
    end
  )
  (func (;8;) (type 10) (result (ref 0))
    (local eqref i32)
    i32.const 1
    local.set 1
    i32.const 0
    local.get 1
    array.new 22
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;9;) (type 11) (param eqref) (result (ref 1))
    local.get 0
    call 8
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;10;) (type 12) (param (ref 1)) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i64 i32 i32)
    local.get 0
    struct.get 1 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 22)
    i32.const 0
    array.get 22
    local.set 1
    local.get 0
    struct.get 1 0
    call 0
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
      struct.get 1 0
      local.get 1
      call 1
      local.set 4
      local.get 3
      i32.const 2
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 1 0
        local.get 1
        i32.const 1
        i32.add
        call 1
      else
        i32.const 0
      end
      local.set 5
      local.get 3
      i32.const 3
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 1 0
        local.get 1
        i32.const 2
        i32.add
        call 1
      else
        i32.const 0
      end
      local.set 6
      local.get 3
      i32.const 4
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        struct.get 1 0
        local.get 1
        i32.const 3
        i32.add
        call 1
      else
        i32.const 0
      end
      local.set 7
      local.get 4
      local.get 5
      local.get 6
      local.get 7
      local.get 3
      call 7
      local.set 8
      local.get 8
      i64.const 4294967295
      i64.and
      call 5
      local.set 9
      local.get 8
      i64.const 32
      i64.shr_u
      call 5
      local.set 10
      local.get 0
      struct.get 1 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 22)
      i32.const 0
      local.get 1
      local.get 10
      i32.add
      array.set 22
      local.get 9
    end
  )
  (func (;11;) (type 13) (param eqref) (result (ref 1))
    local.get 0
    call 9
    ref.cast (ref 1)
  )
  (func (;12;) (type 14) (param (ref 1)) (result i32)
    local.get 0
    call 10
  )
  (func (;13;) (type 15) (result i32)
    array.new_fixed 16 0
    i32.const 0
    i32.const 0
    struct.new 17
    call 11
    call 12
  )
)
