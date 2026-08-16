(module
  (rec
    (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;1;) (sub (struct (field funcref))))
  )
  (rec
    (type (;2;) (sub final 1 (struct (field funcref))))
  )
  (type (;3;) (array (mut i32)))
  (type (;4;) (array (mut i64)))
  (type (;5;) (array (mut f32)))
  (type (;6;) (array (mut f64)))
  (type (;7;) (array (mut v128)))
  (type (;8;) (array (mut eqref)))
  (type (;9;) (array (mut i8)))
  (type (;10;) (array (mut i16)))
  (type (;11;) (func (param eqref) (result eqref)))
  (type (;12;) (func (param eqref i32) (result eqref)))
  (type (;13;) (func (param eqref) (result (ref 0))))
  (type (;14;) (func (param eqref eqref) (result eqref)))
  (type (;15;) (func (param eqref)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func (param eqref eqref i32) (result eqref)))
  (type (;20;) (func (param eqref eqref) (result (ref 0))))
  (type (;21;) (func (param eqref eqref eqref) (result eqref)))
  (type (;22;) (func (param eqref eqref)))
  (type (;23;) (func (param eqref eqref i32)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (param eqref eqref i32) (result i32)))
  (type (;26;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;27;) (func (param (ref 0) eqref eqref) (result eqref)))
  (type (;28;) (func (param (ref 0) eqref eqref) (result eqref)))
  (type (;29;) (func (param (ref 0) eqref eqref) (result eqref)))
  (type (;30;) (func (param (ref 0) i32 eqref) (result i32)))
  (type (;31;) (func (param (ref 0) i32 eqref) (result i32)))
  (type (;32;) (func (param (ref 0) i32 eqref) (result i32)))
  (type (;33;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;34;) (func (param i32 eqref) (result i32)))
  (type (;35;) (func (param i32 i32) (result i32)))
  (type (;36;) (func (param i32 i32 i32) (result i32)))
  (type (;37;) (func (param eqref i32 i32) (result i32)))
  (type (;38;) (func (param eqref i32 i32 i32) (result i32)))
  (type (;39;) (func (result (ref 0))))
  (type (;40;) (func (result (ref 0))))
  (type (;41;) (func))
  (type (;42;) (func))
  (type (;43;) (array (mut v128)))
  (type (;44;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;46;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;47;) (struct (field (mut (ref 43))) (field (mut i32)) (field (mut i32))))
  (type (;48;) (struct (field (mut (ref 43))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 33)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 9))
  (export "__dew_init" (func 11))
  (export "memory" (memory 0))
  (elem (;0;) declare func 7 8 10)
  (func (;1;) (type 30) (param (ref 0) i32 eqref) (result i32)
    (local i32 i32 i32 eqref i32 eqref eqref i32 i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 3
    local.get 1
    local.set 4
    i32.const 0
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 5
            local.get 5
            local.get 3
            i32.lt_u
            if ;; label = @5
              local.get 5
              local.get 0
              ref.cast (ref 0)
              struct.get 0 1
              i32.lt_u
              if ;; label = @6
                local.get 2
                local.set 9
                local.get 9
                ref.cast (ref 1)
                struct.get 1 0
                ref.test (ref 35)
                if (result i32) ;; label = @7
                  local.get 4
                  local.get 0
                  local.get 5
                  local.set 7
                  local.set 6
                  local.get 7
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 3)
                  local.get 7
                  array.get 3
                  local.get 9
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 35)
                  call_ref 35
                else
                  local.get 9
                  local.get 4
                  local.get 0
                  local.get 5
                  local.set 7
                  local.set 6
                  local.get 7
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 3)
                  local.get 7
                  array.get 3
                  local.get 9
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 37)
                  call_ref 37
                end
                local.set 4
              else
              end
              local.get 5
              i32.const 1
              i32.add
              local.set 10
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 11
  )
  (func (;2;) (type 31) (param (ref 0) i32 eqref) (result i32)
    (local i32 i32 i32 eqref i32 eqref eqref i32 i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 3
    local.get 1
    local.set 4
    i32.const 0
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 5
            local.get 5
            local.get 3
            i32.lt_u
            if ;; label = @5
              local.get 5
              local.get 0
              ref.cast (ref 0)
              struct.get 0 1
              i32.lt_u
              if ;; label = @6
                local.get 2
                local.set 9
                local.get 9
                ref.cast (ref 1)
                struct.get 1 0
                ref.test (ref 36)
                if (result i32) ;; label = @7
                  local.get 4
                  local.get 0
                  local.get 5
                  local.set 7
                  local.set 6
                  local.get 7
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 3)
                  local.get 7
                  array.get 3
                  local.get 5
                  local.get 9
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 36)
                  call_ref 36
                else
                  local.get 9
                  local.get 4
                  local.get 0
                  local.get 5
                  local.set 7
                  local.set 6
                  local.get 7
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 3)
                  local.get 7
                  array.get 3
                  local.get 5
                  local.get 9
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 38)
                  call_ref 38
                end
                local.set 4
              else
              end
              local.get 5
              i32.const 1
              i32.add
              local.set 10
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 11
  )
  (func (;3;) (type 32) (param (ref 0) i32 eqref) (result i32)
    (local i32 i32 i32 eqref i32 eqref eqref i32 i32)
    local.get 1
    local.set 3
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 10
          i32.const 0
          i32.eq
          if ;; label = @4
            local.get 3
            local.set 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 4
            local.get 4
            i32.const 1
            i32.sub
            local.set 5
            local.get 5
            local.get 0
            ref.cast (ref 0)
            struct.get 0 1
            i32.lt_u
            if ;; label = @5
              local.get 2
              local.set 9
              local.get 9
              ref.cast (ref 1)
              struct.get 1 0
              ref.test (ref 35)
              if (result i32) ;; label = @6
                local.get 3
                local.get 0
                local.get 5
                local.set 7
                local.set 6
                local.get 7
                local.get 6
                ref.cast (ref 0)
                struct.get 0 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 6
                ref.cast (ref 0)
                struct.get 0 0
                ref.cast (ref 3)
                local.get 7
                array.get 3
                local.get 9
                ref.cast (ref 1)
                struct.get 1 0
                ref.cast (ref 35)
                call_ref 35
              else
                local.get 9
                local.get 3
                local.get 0
                local.get 5
                local.set 7
                local.set 6
                local.get 7
                local.get 6
                ref.cast (ref 0)
                struct.get 0 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 6
                ref.cast (ref 0)
                struct.get 0 0
                ref.cast (ref 3)
                local.get 7
                array.get 3
                local.get 9
                ref.cast (ref 1)
                struct.get 1 0
                ref.cast (ref 37)
                call_ref 37
              end
              local.set 3
            else
            end
            local.get 5
            local.set 10
            br 2 (;@2;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 11
  )
  (func (;4;) (type 34) (param i32 eqref) (result i32)
    (local (ref 45) (ref 43) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 45)
    local.set 2
    local.get 2
    struct.get 45 0
    local.set 3
    local.get 2
    struct.get 45 1
    local.set 4
    local.get 2
    struct.get 45 2
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
              array.get 43
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
              array.get 43
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
              array.get 43
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
              array.get 43
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
                array.get 43
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 43
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
                array.get 43
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
            array.get 43
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
  (func (;5;) (type 39) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 3
    i32.const 0
    i32.const 0
    struct.new 0
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 3
      local.set 3
      local.get 3
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 3 3
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 3)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 4
    array.set 3
    local.get 1
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 3
      local.set 3
      local.get 3
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 3 3
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 3)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 5
    array.set 3
    local.get 1
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 0
    i32.const 3
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 3
      local.set 3
      local.get 3
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 3 3
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 3)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 6
    array.set 3
    local.get 1
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 0
    i32.const 4
    local.set 7
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 3
      local.set 3
      local.get 3
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 3 3
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 3)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 7
    array.set 3
    local.get 1
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 0
    i32.const 5
    local.set 8
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 3
      local.set 3
      local.get 3
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 3 3
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 3)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 8
    array.set 3
    local.get 1
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 0
    ref.cast (ref 0)
  )
  (func (;6;) (type 40) (result (ref 0))
    i32.const 0
    array.new_default 3
    i32.const 0
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;7;) (type 35) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
  )
  (func (;8;) (type 36) (param i32 i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
    local.get 2
    i32.add
  )
  (func (;9;) (type 41)
    (local eqref)
    call 5
    local.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    global.get 0
    call 1
    i32.const 15
    i32.eq
    v128.const i32x4 0x75646572 0x73206563 0x00006d75 0x00000000
    array.new_fixed 43 1
    i32.const 0
    i32.const 10
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    global.get 1
    call 2
    i32.const 25
    i32.eq
    v128.const i32x4 0x75646572 0x69206563 0x7865646e 0x00006465
    array.new_fixed 43 1
    i32.const 0
    i32.const 14
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    ref.func 10
    struct.new 2
    call 3
    i32.const 54321
    i32.eq
    v128.const i32x4 0x75646572 0x72206563 0x74686769 0x64726f20
    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
    array.new_fixed 43 2
    i32.const 0
    i32.const 18
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 6
    local.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 7
    global.get 0
    call 1
    i32.const 7
    i32.eq
    v128.const i32x4 0x74706d65 0x65722079 0x65637564 0x00000000
    array.new_fixed 43 1
    i32.const 0
    i32.const 12
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 9
    global.get 0
    call 3
    i32.const 9
    i32.eq
    v128.const i32x4 0x74706d65 0x65722079 0x65637564 0x67697220
    v128.const i32x4 0x00007468 0x00000000 0x00000000 0x00000000
    array.new_fixed 43 2
    i32.const 0
    i32.const 18
    struct.new 44
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x65722d79 0x65637564 0x722d7372 0x69746e75
    v128.const i32x4 0x0000656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 43 3
    i32.const 0
    i32.const 34
    struct.new 45
    call 4
    drop
  )
  (func (;10;) (type 37) (param eqref i32 i32) (result i32)
    local.get 1
    i32.const 10
    i32.mul
    local.get 2
    i32.add
  )
  (func (;11;) (type 42)
    ref.func 7
    struct.new 1
    global.set 0
    ref.func 8
    struct.new 1
    global.set 1
  )
)
