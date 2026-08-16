(module
  (rec
    (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;1;) (sub (struct (field funcref))))
  )
  (type (;2;) (array (mut i32)))
  (type (;3;) (array (mut i64)))
  (type (;4;) (array (mut f32)))
  (type (;5;) (array (mut f64)))
  (type (;6;) (array (mut v128)))
  (type (;7;) (array (mut eqref)))
  (type (;8;) (array (mut i8)))
  (type (;9;) (array (mut i16)))
  (type (;10;) (func (param eqref) (result eqref)))
  (type (;11;) (func (param eqref i32) (result eqref)))
  (type (;12;) (func (param eqref) (result (ref 0))))
  (type (;13;) (func (param eqref eqref) (result eqref)))
  (type (;14;) (func (param eqref)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref) (result i32)))
  (type (;17;) (func (param eqref i32) (result i32)))
  (type (;18;) (func (param eqref eqref i32) (result eqref)))
  (type (;19;) (func (param eqref eqref) (result (ref 0))))
  (type (;20;) (func (param eqref eqref eqref) (result eqref)))
  (type (;21;) (func (param eqref eqref)))
  (type (;22;) (func (param eqref eqref i32)))
  (type (;23;) (func (param eqref eqref) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result i32)))
  (type (;25;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;26;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;27;) (func (param (ref 0) eqref eqref) (result eqref)))
  (type (;28;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;29;) (func (param (ref 0) i32 eqref) (result i32)))
  (type (;30;) (func (param eqref eqref) (result i32)))
  (type (;31;) (func (param eqref eqref) (result i32)))
  (type (;32;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;33;) (func (param i32 eqref) (result i32)))
  (type (;34;) (func (param i32) (result eqref)))
  (type (;35;) (func (param i32 i32) (result i32)))
  (type (;36;) (func (param eqref i32) (result eqref)))
  (type (;37;) (func (param eqref i32 i32) (result i32)))
  (type (;38;) (func (param i32 i32) (result (ref 0))))
  (type (;39;) (func (param eqref eqref) (result i32)))
  (type (;40;) (func))
  (type (;41;) (func))
  (type (;42;) (array (mut v128)))
  (type (;43;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;44;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;46;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (type (;47;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 32)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 10))
  (export "__dew_init" (func 11))
  (export "memory" (memory 0))
  (elem (;0;) declare func 7 9)
  (func (;1;) (type 28) (param (ref 0) eqref) (result (ref 0))
    (local i32 eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    local.get 2
    local.set 6
    local.get 6
    array.new_default 7
    i32.const 0
    local.get 6
    struct.new 0
    local.set 3
    i32.const 0
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 4
            local.get 4
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 4
              local.get 0
              ref.cast (ref 0)
              struct.get 0 1
              i32.lt_u
              if ;; label = @6
                local.get 3
                local.get 1
                local.set 8
                local.get 8
                ref.cast (ref 1)
                struct.get 1 0
                ref.test (ref 34)
                if (result eqref) ;; label = @7
                  local.get 0
                  local.get 4
                  local.set 6
                  local.set 5
                  local.get 6
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 2)
                  local.get 6
                  array.get 2
                  local.get 8
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 34)
                  call_ref 34
                else
                  local.get 8
                  local.get 0
                  local.get 4
                  local.set 6
                  local.set 5
                  local.get 6
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 2)
                  local.get 6
                  array.get 2
                  local.get 8
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 11)
                  call_ref 11
                end
                local.set 9
                local.set 5
                local.get 5
                ref.cast (ref 0)
                struct.get 0 1
                local.get 5
                ref.cast (ref 0)
                struct.get 0 2
                i32.eq
                if ;; label = @7
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 2
                  i32.eqz
                  if (result i32) ;; label = @8
                    i32.const 4
                  else
                    local.get 5
                    ref.cast (ref 0)
                    struct.get 0 2
                    i32.const 2
                    i32.mul
                  end
                  local.set 6
                  local.get 6
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 2
                  i32.le_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 6
                  array.new_default 7
                  local.set 7
                  local.get 7
                  ref.cast (ref 7)
                  i32.const 0
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 7)
                  i32.const 0
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 1
                  array.copy 7 7
                  local.get 5
                  ref.cast (ref 0)
                  local.get 7
                  struct.set 0 0
                  local.get 5
                  ref.cast (ref 0)
                  local.get 7
                  ref.cast (ref 7)
                  array.len
                  struct.set 0 2
                end
                local.get 5
                ref.cast (ref 0)
                struct.get 0 0
                ref.cast (ref 7)
                local.get 5
                ref.cast (ref 0)
                struct.get 0 1
                local.get 9
                array.set 7
                local.get 5
                ref.cast (ref 0)
                local.get 5
                ref.cast (ref 0)
                struct.get 0 1
                i32.const 1
                i32.add
                struct.set 0 1
              else
              end
              local.get 4
              i32.const 1
              i32.add
              local.set 10
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 3
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
    ref.cast (ref 0)
  )
  (func (;2;) (type 29) (param (ref 0) i32 eqref) (result i32)
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
                  ref.cast (ref 2)
                  local.get 7
                  array.get 2
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
                  ref.cast (ref 2)
                  local.get 7
                  array.get 2
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
  (func (;3;) (type 30) (param eqref eqref) (result i32)
    (local (ref 43) (ref 43) (ref 42) (ref 42) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 43)
    local.set 2
    local.get 1
    ref.cast (ref 43)
    local.set 3
    local.get 2
    struct.get 43 2
    local.tee 6
    local.get 3
    struct.get 43 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 43 0
    local.set 4
    local.get 3
    struct.get 43 0
    local.set 5
    local.get 2
    struct.get 43 1
    local.set 7
    local.get 3
    struct.get 43 1
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
          array.get 42
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 42
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
          array.get 42
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
          array.get 42
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 42
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
          array.get 42
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
      array.get 42
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
      array.get 42
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
  (func (;4;) (type 31) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 3
  )
  (func (;5;) (type 33) (param i32 eqref) (result i32)
    (local (ref 44) (ref 42) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 44)
    local.set 2
    local.get 2
    struct.get 44 0
    local.set 3
    local.get 2
    struct.get 44 1
    local.set 4
    local.get 2
    struct.get 44 2
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
              array.get 42
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
              array.get 42
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
              array.get 42
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
              array.get 42
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
                array.get 42
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 42
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
                array.get 42
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
            array.get 42
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
  (func (;6;) (type 38) (param i32 i32) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32)
    i32.const 2
    local.set 4
    local.get 4
    array.new_default 2
    i32.const 0
    local.get 4
    struct.new 0
    local.set 2
    local.get 2
    local.get 0
    local.set 6
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    local.get 3
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 2
      local.set 5
      local.get 5
      ref.cast (ref 2)
      i32.const 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      i32.const 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 2 2
      local.get 3
      ref.cast (ref 0)
      local.get 5
      struct.set 0 0
      local.get 3
      ref.cast (ref 0)
      local.get 5
      ref.cast (ref 2)
      array.len
      struct.set 0 2
    end
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    local.get 6
    array.set 2
    local.get 3
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 2
    local.get 1
    local.set 7
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    local.get 3
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 2
      local.set 5
      local.get 5
      ref.cast (ref 2)
      i32.const 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      i32.const 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 2 2
      local.get 3
      ref.cast (ref 0)
      local.get 5
      struct.set 0 0
      local.get 3
      ref.cast (ref 0)
      local.get 5
      ref.cast (ref 2)
      array.len
      struct.set 0 2
    end
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    local.get 7
    array.set 2
    local.get 3
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 2
    ref.cast (ref 0)
  )
  (func (;7;) (type 34) (param i32) (result eqref)
    local.get 0
    i32.const 1
    i32.eq
    if (result eqref) ;; label = @1
      v128.const i32x4 0x00656e6f 0x00000000 0x00000000 0x00000000
      array.new_fixed 42 1
      i32.const 0
      i32.const 3
      struct.new 43
    else
      local.get 0
      i32.const 2
      i32.eq
      if (result eqref) ;; label = @2
        v128.const i32x4 0x006f7774 0x00000000 0x00000000 0x00000000
        array.new_fixed 42 1
        i32.const 0
        i32.const 3
        struct.new 43
      else
        v128.const i32x4 0x6568746f 0x00000072 0x00000000 0x00000000
        array.new_fixed 42 1
        i32.const 0
        i32.const 5
        struct.new 43
      end
    end
  )
  (func (;8;) (type 39) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;9;) (type 35) (param i32 i32) (result i32)
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
  (func (;10;) (type 40)
    (local eqref eqref eqref eqref i32 eqref)
    i32.const 1
    i32.const 2
    call 6
    local.set 0
    local.get 0
    ref.cast (ref 0)
    global.get 0
    call 1
    local.set 1
    local.get 1
    i32.const 0
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 7)
    local.get 4
    array.get 7
    local.set 2
    local.get 1
    i32.const 1
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 7)
    local.get 4
    array.get 7
    local.set 1
    local.get 2
    v128.const i32x4 0x00656e6f 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 3
    struct.new 43
    call 8
    v128.const i32x4 0x656e6567 0x20636972 0x2070616d 0x73726966
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 17
    struct.new 43
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    v128.const i32x4 0x006f7774 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 3
    struct.new 43
    call 8
    v128.const i32x4 0x656e6567 0x20636972 0x2070616d 0x6f636573
    v128.const i32x4 0x0000646e 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 18
    struct.new 43
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
    i32.const 2
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x75646572 0x00006563
    array.new_fixed 42 1
    i32.const 0
    i32.const 14
    struct.new 43
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x65672d79 0x6972656e 0x72742d63 0x66736e61
    v128.const i32x4 0x2d6d726f 0x746e7572 0x00656d69 0x00000000
    array.new_fixed 42 3
    i32.const 0
    i32.const 43
    struct.new 44
    call 5
    drop
  )
  (func (;11;) (type 41)
    ref.func 7
    struct.new 1
    global.set 0
    ref.func 9
    struct.new 1
    global.set 1
  )
)
