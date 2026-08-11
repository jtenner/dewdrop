(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (struct))
  (type (;2;) (struct))
  (type (;3;) (struct))
  (type (;4;) (func (param eqref) (result i32)))
  (type (;5;) (func (param eqref i32) (result i32)))
  (type (;6;) (func (param eqref) (result i32)))
  (type (;7;) (func (param eqref i32) (result i32)))
  (type (;8;) (func (param eqref) (result i32)))
  (type (;9;) (func (param eqref i32) (result i32)))
  (type (;10;) (func (param (ref 0)) (result i32)))
  (type (;11;) (func (param (ref 0)) (result i32)))
  (type (;12;) (func (param (ref 0)) (result i32)))
  (type (;13;) (func (result (ref 1))))
  (type (;14;) (func (result (ref 2))))
  (type (;15;) (func (result (ref 3))))
  (type (;16;) (func (param eqref eqref) (result (ref 0))))
  (type (;17;) (func (param eqref eqref) (result (ref 0))))
  (type (;18;) (func (param eqref eqref) (result (ref 0))))
  (type (;19;) (func (param (ref 1) eqref eqref) (result (ref 0))))
  (type (;20;) (func (param (ref 2) eqref eqref) (result (ref 0))))
  (type (;21;) (func (param (ref 3) eqref eqref) (result (ref 0))))
  (type (;22;) (func (param eqref) (result eqref)))
  (type (;23;) (func (param eqref i32 i32) (result eqref)))
  (type (;24;) (func (param eqref) (result eqref)))
  (type (;25;) (func (param eqref i32 i32) (result eqref)))
  (type (;26;) (func))
  (type (;27;) (array (mut v128)))
  (type (;28;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;29;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;30;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;31;) (struct (field (mut (ref 27))) (field (mut i32)) (field (mut i32))))
  (type (;32;) (struct (field (mut (ref 27))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 22))
  (func (;0;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 28)
    struct.get 28 2
  )
  (func (;1;) (type 5) (param eqref i32) (result i32)
    (local (ref 28) (ref 27) i32)
    local.get 0
    ref.cast (ref 28)
    local.set 2
    local.get 1
    local.get 2
    struct.get 28 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 28 0
    local.set 3
    local.get 2
    struct.get 28 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 27
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;2;) (type 6) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 30)
    struct.get 30 2
  )
  (func (;3;) (type 7) (param eqref i32) (result i32)
    (local (ref 30) (ref 27) i32)
    local.get 0
    ref.cast (ref 30)
    local.set 2
    local.get 1
    local.get 2
    struct.get 30 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 30 0
    local.set 3
    local.get 2
    struct.get 30 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 27
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;4;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 29)
    struct.get 29 2
  )
  (func (;5;) (type 9) (param eqref i32) (result i32)
    (local (ref 29) (ref 27) i32)
    local.get 0
    ref.cast (ref 29)
    local.set 2
    local.get 1
    local.get 2
    struct.get 29 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 29 0
    local.set 3
    local.get 2
    struct.get 29 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 27
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;6;) (type 10) (param (ref 0)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 1
            local.set 2
            br 3 (;@1;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;7;) (type 11) (param (ref 0)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 2
            br 3 (;@1;)
          end
          i32.const 1
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;8;) (type 12) (param (ref 0)) (result i32)
    (local eqref i32)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 1
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 2
            br 3 (;@1;)
          end
          i32.const 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;9;) (type 13) (result (ref 1))
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;10;) (type 14) (result (ref 2))
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;11;) (type 15) (result (ref 3))
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;12;) (type 16) (param eqref eqref) (result (ref 0))
    (local i32 i32 i32 i32 i32 i32 i32 eqref)
    local.get 0
    call 0
    local.set 2
    local.get 1
    call 0
    local.set 3
    local.get 2
    local.get 3
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 2
    else
      local.get 3
    end
    local.set 4
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 5
            local.get 5
            local.get 4
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 5
              call 1
              local.set 6
              local.get 1
              local.get 5
              call 1
              local.set 7
              local.get 6
              local.get 7
              i32.lt_u
              if ;; label = @6
                i32.const 0
                struct.new 0
                local.set 9
                br 5 (;@1;)
              else
                local.get 6
                local.get 7
                i32.gt_u
                if ;; label = @7
                  i32.const 2
                  struct.new 0
                  local.set 9
                  br 6 (;@1;)
                else
                  local.get 5
                  i32.const 1
                  i32.add
                  local.set 8
                  br 5 (;@2;)
                end
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 2
            local.get 3
            i32.lt_u
            if ;; label = @5
              i32.const 0
              struct.new 0
              local.set 9
              br 4 (;@1;)
            else
              local.get 2
              local.get 3
              i32.gt_u
              if ;; label = @6
                i32.const 2
                struct.new 0
                local.set 9
                br 5 (;@1;)
              else
                i32.const 1
                struct.new 0
                local.set 9
                br 5 (;@1;)
              end
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 0)
  )
  (func (;13;) (type 17) (param eqref eqref) (result (ref 0))
    (local i32 i32 i32 i32 i32 i32 i32 eqref)
    local.get 0
    call 2
    local.set 2
    local.get 1
    call 2
    local.set 3
    local.get 2
    local.get 3
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 2
    else
      local.get 3
    end
    local.set 4
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 5
            local.get 5
            local.get 4
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 5
              call 3
              local.set 6
              local.get 1
              local.get 5
              call 3
              local.set 7
              local.get 6
              local.get 7
              i32.lt_u
              if ;; label = @6
                i32.const 0
                struct.new 0
                local.set 9
                br 5 (;@1;)
              else
                local.get 6
                local.get 7
                i32.gt_u
                if ;; label = @7
                  i32.const 2
                  struct.new 0
                  local.set 9
                  br 6 (;@1;)
                else
                  local.get 5
                  i32.const 1
                  i32.add
                  local.set 8
                  br 5 (;@2;)
                end
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 2
            local.get 3
            i32.lt_u
            if ;; label = @5
              i32.const 0
              struct.new 0
              local.set 9
              br 4 (;@1;)
            else
              local.get 2
              local.get 3
              i32.gt_u
              if ;; label = @6
                i32.const 2
                struct.new 0
                local.set 9
                br 5 (;@1;)
              else
                i32.const 1
                struct.new 0
                local.set 9
                br 5 (;@1;)
              end
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 0)
  )
  (func (;14;) (type 18) (param eqref eqref) (result (ref 0))
    (local i32 i32 i32 i32 i32 i32 i32 eqref)
    local.get 0
    call 4
    local.set 2
    local.get 1
    call 4
    local.set 3
    local.get 2
    local.get 3
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 2
    else
      local.get 3
    end
    local.set 4
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 5
            local.get 5
            local.get 4
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 5
              call 5
              local.set 6
              local.get 1
              local.get 5
              call 5
              local.set 7
              local.get 6
              local.get 7
              i32.lt_u
              if ;; label = @6
                i32.const 0
                struct.new 0
                local.set 9
                br 5 (;@1;)
              else
                local.get 6
                local.get 7
                i32.gt_u
                if ;; label = @7
                  i32.const 2
                  struct.new 0
                  local.set 9
                  br 6 (;@1;)
                else
                  local.get 5
                  i32.const 1
                  i32.add
                  local.set 8
                  br 5 (;@2;)
                end
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 2
            local.get 3
            i32.lt_u
            if ;; label = @5
              i32.const 0
              struct.new 0
              local.set 9
              br 4 (;@1;)
            else
              local.get 2
              local.get 3
              i32.gt_u
              if ;; label = @6
                i32.const 2
                struct.new 0
                local.set 9
                br 5 (;@1;)
              else
                i32.const 1
                struct.new 0
                local.set 9
                br 5 (;@1;)
              end
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 0)
  )
  (func (;15;) (type 19) (param (ref 1) eqref eqref) (result (ref 0))
    local.get 1
    local.get 2
    call 12
    ref.cast (ref 0)
  )
  (func (;16;) (type 20) (param (ref 2) eqref eqref) (result (ref 0))
    local.get 1
    local.get 2
    call 13
    ref.cast (ref 0)
  )
  (func (;17;) (type 21) (param (ref 3) eqref eqref) (result (ref 0))
    local.get 1
    local.get 2
    call 14
    ref.cast (ref 0)
  )
  (func (;18;) (type 22) (param eqref) (result eqref)
    (local (ref 28))
    local.get 0
    ref.cast (ref 28)
    local.tee 1
    struct.get 28 0
    local.get 1
    struct.get 28 1
    local.get 1
    struct.get 28 2
    struct.new 29
  )
  (func (;19;) (type 23) (param eqref i32 i32) (result eqref)
    (local (ref 28) (ref 27) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 28)
    local.set 3
    local.get 3
    struct.get 28 2
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
    struct.get 28 0
    local.set 4
    local.get 3
    struct.get 28 1
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
      array.get 27
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
      array.get 27
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
    struct.get 28 1
    local.get 1
    i32.add
    local.get 2
    struct.new 30
  )
  (func (;20;) (type 24) (param eqref) (result eqref)
    local.get 0
    call 18
  )
  (func (;21;) (type 25) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 19
  )
  (func (;22;) (type 26)
    (local eqref eqref eqref eqref)
    call 9
    local.set 0
    local.get 0
    ref.cast (ref 1)
    array.new_fixed 27 0
    i32.const 0
    i32.const 0
    struct.new 28
    v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 1
    struct.new 28
    call 15
    call 6
    v128.const i32x4 0x74706d65 0x74732079 0x676e6972 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 12
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 1)
    v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 1
    struct.new 28
    v128.const i32x4 0x00006161 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 2
    struct.new 28
    call 15
    call 6
    v128.const i32x4 0x69727473 0x7020676e 0x69666572 0x00000078
    array.new_fixed 27 1
    i32.const 0
    i32.const 13
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 1)
    v128.const i32x4 0x0000a9c3 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 2
    struct.new 28
    v128.const i32x4 0x0000bbce 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 2
    struct.new 28
    call 15
    call 6
    v128.const i32x4 0x63696e75 0x2065646f 0x6c616373 0x6f207261
    v128.const i32x4 0x72656472 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 2
    i32.const 0
    i32.const 20
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 1)
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 3
    struct.new 28
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 3
    struct.new 28
    call 15
    call 7
    v128.const i32x4 0x69727473 0x6520676e 0x6c617571 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 12
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 1)
    v128.const i32x4 0x0000007a 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 1
    struct.new 28
    v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 1
    struct.new 28
    call 15
    call 8
    v128.const i32x4 0x69727473 0x6720676e 0x74616572 0x00007265
    array.new_fixed 27 1
    i32.const 0
    i32.const 14
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 10
    local.set 1
    v128.const i32x4 0x706c6130 0x62316168 0x32617465 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 12
    struct.new 28
    local.set 2
    local.get 1
    ref.cast (ref 2)
    local.get 2
    i32.const 1
    i32.const 5
    call 21
    local.get 2
    i32.const 7
    i32.const 4
    call 21
    call 16
    call 6
    v128.const i32x4 0x77656976 0x64726f20 0x00007265 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 10
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 2)
    local.get 2
    i32.const 1
    i32.const 5
    call 21
    v128.const i32x4 0x68706c61 0x00000061 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 5
    struct.new 28
    i32.const 0
    i32.const 5
    call 21
    call 16
    call 7
    v128.const i32x4 0x77656976 0x75716520 0x00006c61 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 10
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 11
    local.set 3
    local.get 3
    ref.cast (ref 3)
    v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 1
    struct.new 28
    call 20
    v128.const i32x4 0x00006161 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 2
    struct.new 28
    call 20
    call 17
    call 6
    v128.const i32x4 0x65747962 0x72702073 0x78696665 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 12
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 3)
    v128.const i32x4 0x0000007a 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 1
    struct.new 28
    call 20
    v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 1
    struct.new 28
    call 20
    call 17
    call 8
    v128.const i32x4 0x65747962 0x72672073 0x65746165 0x00000072
    array.new_fixed 27 1
    i32.const 0
    i32.const 13
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
