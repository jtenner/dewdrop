(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (func (param i32) (result (ref 0))))
  (type (;3;) (func (param eqref eqref) (result i32)))
  (type (;4;) (func (param eqref eqref) (result (ref 0))))
  (type (;5;) (func (result i32)))
  (type (;6;) (array (mut v128)))
  (type (;7;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;10;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 2) (param i32) (result (ref 0))
    local.get 0
    i32.const -1
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      i32.const 1
      local.get 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;1;) (type 3) (param eqref eqref) (result i32)
    (local (ref 7) (ref 7) (ref 6) (ref 6) i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i64 i64 i64 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 7)
    local.set 2
    local.get 1
    ref.cast (ref 7)
    local.set 3
    local.get 2
    struct.get 7 0
    local.set 4
    local.get 3
    struct.get 7 0
    local.set 5
    local.get 2
    struct.get 7 1
    local.set 6
    local.get 3
    struct.get 7 1
    local.set 7
    local.get 2
    struct.get 7 2
    local.set 8
    local.get 3
    struct.get 7 2
    local.tee 9
    i32.eqz
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 9
    local.get 8
    i32.gt_u
    if ;; label = @1
      i32.const -1
      return
    end
    local.get 8
    local.get 9
    i32.sub
    local.set 10
    i64.const 0
    local.set 18
    i64.const 0
    local.set 19
    i64.const 1
    local.set 20
    i32.const 0
    local.set 12
    local.get 9
    i32.const 16
    i32.le_u
    if ;; label = @1
      local.get 7
      local.set 14
      local.get 5
      local.get 14
      i32.const 4
      i32.shr_u
      array.get 6
      local.get 14
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 16
      local.get 7
      local.get 9
      i32.add
      i32.const 1
      i32.sub
      local.set 14
      local.get 5
      local.get 14
      i32.const 4
      i32.shr_u
      array.get 6
      local.get 14
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 17
      i32.const 0
      local.set 11
      loop ;; label = @2
        local.get 10
        local.get 11
        i32.sub
        i32.const 1
        i32.add
        i32.const 16
        i32.ge_u
        if ;; label = @3
          local.get 6
          local.get 11
          i32.add
          local.set 13
          local.get 13
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            array.get 6
            local.set 24
          else
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            array.get 6
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 13
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 6
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 13
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i32.const 16
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            v128.or
            local.set 24
          end
          local.get 6
          local.get 11
          i32.add
          local.get 9
          i32.add
          i32.const 1
          i32.sub
          local.set 13
          local.get 13
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            array.get 6
            local.set 25
          else
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            array.get 6
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 13
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 6
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 13
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i32.const 16
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            v128.or
            local.set 25
          end
          local.get 24
          local.get 16
          i8x16.splat
          i8x16.eq
          i8x16.bitmask
          local.get 25
          local.get 17
          i8x16.splat
          i8x16.eq
          i8x16.bitmask
          i32.and
          local.set 22
          block ;; label = @4
            loop ;; label = @5
              local.get 22
              i32.eqz
              br_if 1 (;@4;)
              local.get 22
              i32.ctz
              local.set 23
              local.get 11
              local.get 23
              i32.add
              local.set 21
              i32.const 1
              local.set 15
              i32.const 0
              local.set 12
              block ;; label = @6
                loop ;; label = @7
                  local.get 12
                  local.get 9
                  i32.ge_u
                  br_if 1 (;@6;)
                  local.get 6
                  local.get 21
                  i32.add
                  local.get 12
                  i32.add
                  local.set 13
                  local.get 7
                  local.get 12
                  i32.add
                  local.set 14
                  local.get 4
                  local.get 13
                  i32.const 4
                  i32.shr_u
                  array.get 6
                  local.get 13
                  i32.const 15
                  i32.and
                  i8x16.splat
                  i8x16.swizzle
                  i8x16.extract_lane_u 0
                  local.get 5
                  local.get 14
                  i32.const 4
                  i32.shr_u
                  array.get 6
                  local.get 14
                  i32.const 15
                  i32.and
                  i8x16.splat
                  i8x16.swizzle
                  i8x16.extract_lane_u 0
                  i32.ne
                  if ;; label = @8
                    i32.const 0
                    local.set 15
                    br 2 (;@6;)
                  end
                  local.get 12
                  i32.const 1
                  i32.add
                  local.set 12
                  br 0 (;@7;)
                end
              end
              local.get 15
              if ;; label = @6
                local.get 21
                return
              end
              local.get 22
              local.get 22
              i32.const 1
              i32.sub
              i32.and
              local.set 22
              br 0 (;@5;)
            end
          end
          local.get 11
          i32.const 16
          i32.add
          local.set 11
          br 1 (;@2;)
        end
        local.get 11
        local.get 10
        i32.gt_u
        if ;; label = @3
          i32.const -1
          return
        end
        local.get 11
        local.set 21
        i32.const 1
        local.set 15
        i32.const 0
        local.set 12
        block ;; label = @3
          loop ;; label = @4
            local.get 12
            local.get 9
            i32.ge_u
            br_if 1 (;@3;)
            local.get 6
            local.get 21
            i32.add
            local.get 12
            i32.add
            local.set 13
            local.get 7
            local.get 12
            i32.add
            local.set 14
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            array.get 6
            local.get 13
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            local.get 5
            local.get 14
            i32.const 4
            i32.shr_u
            array.get 6
            local.get 14
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            i32.ne
            if ;; label = @5
              i32.const 0
              local.set 15
              br 2 (;@3;)
            end
            local.get 12
            i32.const 1
            i32.add
            local.set 12
            br 0 (;@4;)
          end
        end
        local.get 15
        if ;; label = @3
          local.get 21
          return
        end
        local.get 11
        i32.const 1
        i32.add
        local.set 11
        br 0 (;@2;)
      end
    end
    block ;; label = @1
      loop ;; label = @2
        local.get 12
        local.get 9
        i32.ge_u
        br_if 1 (;@1;)
        local.get 7
        local.get 12
        i32.add
        local.set 14
        local.get 6
        local.get 12
        i32.add
        local.set 13
        local.get 18
        i64.const 257
        i64.mul
        local.get 5
        local.get 14
        i32.const 4
        i32.shr_u
        array.get 6
        local.get 14
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        i64.extend_i32_u
        i64.add
        local.set 18
        local.get 19
        i64.const 257
        i64.mul
        local.get 4
        local.get 13
        i32.const 4
        i32.shr_u
        array.get 6
        local.get 13
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        i64.extend_i32_u
        i64.add
        local.set 19
        local.get 12
        local.get 9
        i32.const 1
        i32.sub
        i32.lt_u
        if ;; label = @3
          local.get 20
          i64.const 257
          i64.mul
          local.set 20
        end
        local.get 12
        i32.const 1
        i32.add
        local.set 12
        br 0 (;@2;)
      end
    end
    i32.const 0
    local.set 11
    loop ;; label = @1
      local.get 18
      local.get 19
      i64.eq
      if ;; label = @2
        i32.const 1
        local.set 15
        i32.const 0
        local.set 12
        block ;; label = @3
          loop ;; label = @4
            local.get 12
            local.get 9
            i32.ge_u
            br_if 1 (;@3;)
            local.get 6
            local.get 11
            i32.add
            local.get 12
            i32.add
            local.set 13
            local.get 7
            local.get 12
            i32.add
            local.set 14
            local.get 4
            local.get 13
            i32.const 4
            i32.shr_u
            array.get 6
            local.get 13
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            local.get 5
            local.get 14
            i32.const 4
            i32.shr_u
            array.get 6
            local.get 14
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            i32.ne
            if ;; label = @5
              i32.const 0
              local.set 15
              br 2 (;@3;)
            end
            local.get 12
            i32.const 1
            i32.add
            local.set 12
            br 0 (;@4;)
          end
        end
        local.get 15
        if ;; label = @3
          local.get 11
          return
        end
      end
      local.get 11
      local.get 10
      i32.ge_u
      if ;; label = @2
        i32.const -1
        return
      end
      local.get 6
      local.get 11
      i32.add
      local.set 13
      local.get 4
      local.get 13
      i32.const 4
      i32.shr_u
      array.get 6
      local.get 13
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 16
      local.get 6
      local.get 11
      i32.add
      local.get 9
      i32.add
      local.set 13
      local.get 4
      local.get 13
      i32.const 4
      i32.shr_u
      array.get 6
      local.get 13
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 17
      local.get 19
      local.get 16
      i64.extend_i32_u
      local.get 20
      i64.mul
      i64.sub
      i64.const 257
      i64.mul
      local.get 17
      i64.extend_i32_u
      i64.add
      local.set 19
      local.get 11
      i32.const 1
      i32.add
      local.set 11
      br 0 (;@1;)
    end
    i32.const -1
  )
  (func (;2;) (type 4) (param eqref eqref) (result (ref 0))
    local.get 0
    local.get 1
    call 1
    call 0
    ref.cast (ref 0)
  )
  (func (;3;) (type 5) (result i32)
    (local eqref i32 eqref i32)
    v128.const i32x4 0x66657270 0xce207869 0x96b8e4bb 0xf08c95e7
    v128.const i32x4 0x208d8c9f 0x66667573 0x00007869 0x00000000
    array.new_fixed 6 2
    i32.const 0
    i32.const 26
    struct.new 7
    local.set 0
    local.get 0
    v128.const i32x4 0xb8e4bbce 0x8c95e796 0x8d8c9ff0 0x00000000
    array.new_fixed 6 1
    i32.const 0
    i32.const 12
    struct.new 7
    call 2
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const -1
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
)
