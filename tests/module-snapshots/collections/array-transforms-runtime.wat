(module
  (rec
    (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;1;) (struct (field eqref) (field (mut i32))))
  )
  (rec
    (type (;2;) (sub (struct (field funcref))))
  )
  (rec
    (type (;3;) (sub final 2 (struct (field funcref))))
  )
  (rec
    (type (;4;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;5;) (struct))
  )
  (rec
    (type (;6;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;7;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;8;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (type (;9;) (array (mut i32)))
  (type (;10;) (array (mut i64)))
  (type (;11;) (array (mut f32)))
  (type (;12;) (array (mut f64)))
  (type (;13;) (array (mut v128)))
  (type (;14;) (array (mut eqref)))
  (type (;15;) (array (mut i8)))
  (type (;16;) (array (mut i16)))
  (type (;17;) (func (param eqref) (result eqref)))
  (type (;18;) (func (param eqref i32) (result eqref)))
  (type (;19;) (func (param eqref) (result (ref 0))))
  (type (;20;) (func (param eqref eqref) (result eqref)))
  (type (;21;) (func (param eqref)))
  (type (;22;) (func (param eqref i32)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (param eqref i32) (result i32)))
  (type (;25;) (func (param eqref eqref i32) (result eqref)))
  (type (;26;) (func (param eqref eqref) (result (ref 0))))
  (type (;27;) (func (param eqref eqref eqref) (result eqref)))
  (type (;28;) (func (param eqref eqref)))
  (type (;29;) (func (param eqref eqref i32)))
  (type (;30;) (func (param eqref eqref) (result i32)))
  (type (;31;) (func (param eqref eqref i32) (result i32)))
  (type (;32;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;33;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;34;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;35;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;36;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;37;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;38;) (func (param i32 eqref) (result i32)))
  (type (;39;) (func (param i32) (result i32)))
  (type (;40;) (func (param i32 i32) (result i32)))
  (type (;41;) (func (param eqref i32 i32) (result i32)))
  (type (;42;) (func (result (ref 0))))
  (type (;43;) (func))
  (type (;44;) (func))
  (type (;45;) (array (mut v128)))
  (type (;46;) (struct (field (ref 45)) (field i32) (field i32)))
  (type (;47;) (struct (field (ref 45)) (field i32) (field i32)))
  (type (;48;) (struct (field (ref 45)) (field i32) (field i32)))
  (type (;49;) (struct (field (mut (ref 45))) (field (mut i32)) (field (mut i32))))
  (type (;50;) (struct (field (mut (ref 45))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 37)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 6))
  (export "__dew_init" (func 8))
  (export "memory" (memory 0))
  (elem (;0;) declare func 5 7)
  (func (;1;) (type 35) (param (ref 0) eqref) (result (ref 0))
    (local i32 eqref i32 eqref i32 eqref eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    local.get 2
    local.set 6
    local.get 6
    array.new_default 9
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
                ref.cast (ref 2)
                struct.get 2 0
                ref.test (ref 39)
                if (result i32) ;; label = @7
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
                  ref.cast (ref 9)
                  local.get 6
                  array.get 9
                  local.get 8
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 39)
                  call_ref 39
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
                  ref.cast (ref 9)
                  local.get 6
                  array.get 9
                  local.get 8
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 24)
                  call_ref 24
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
                  array.new_default 9
                  local.set 7
                  local.get 7
                  ref.cast (ref 9)
                  i32.const 0
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 9)
                  i32.const 0
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 1
                  array.copy 9 9
                  local.get 5
                  ref.cast (ref 0)
                  local.get 7
                  struct.set 0 0
                  local.get 5
                  ref.cast (ref 0)
                  local.get 7
                  ref.cast (ref 9)
                  array.len
                  struct.set 0 2
                end
                local.get 5
                ref.cast (ref 0)
                struct.get 0 0
                ref.cast (ref 9)
                local.get 5
                ref.cast (ref 0)
                struct.get 0 1
                local.get 9
                array.set 9
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
  (func (;2;) (type 36) (param (ref 0) eqref) (result (ref 0))
    (local i32 eqref i32 eqref i32 eqref eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    local.get 2
    local.set 6
    local.get 6
    array.new_default 9
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
                ref.cast (ref 2)
                struct.get 2 0
                ref.test (ref 40)
                if (result i32) ;; label = @7
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
                  ref.cast (ref 9)
                  local.get 6
                  array.get 9
                  local.get 4
                  local.get 8
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 40)
                  call_ref 40
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
                  ref.cast (ref 9)
                  local.get 6
                  array.get 9
                  local.get 4
                  local.get 8
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 41)
                  call_ref 41
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
                  array.new_default 9
                  local.set 7
                  local.get 7
                  ref.cast (ref 9)
                  i32.const 0
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 9)
                  i32.const 0
                  local.get 5
                  ref.cast (ref 0)
                  struct.get 0 1
                  array.copy 9 9
                  local.get 5
                  ref.cast (ref 0)
                  local.get 7
                  struct.set 0 0
                  local.get 5
                  ref.cast (ref 0)
                  local.get 7
                  ref.cast (ref 9)
                  array.len
                  struct.set 0 2
                end
                local.get 5
                ref.cast (ref 0)
                struct.get 0 0
                ref.cast (ref 9)
                local.get 5
                ref.cast (ref 0)
                struct.get 0 1
                local.get 9
                array.set 9
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
  (func (;3;) (type 38) (param i32 eqref) (result i32)
    (local (ref 47) (ref 45) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 47)
    local.set 2
    local.get 2
    struct.get 47 0
    local.set 3
    local.get 2
    struct.get 47 1
    local.set 4
    local.get 2
    struct.get 47 2
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
              array.get 45
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
              array.get 45
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
              array.get 45
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
              array.get 45
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
                array.get 45
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 45
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
                array.get 45
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
            array.get 45
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
  (func (;4;) (type 42) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 9
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
      array.new_default 9
      local.set 3
      local.get 3
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 9 9
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 9)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 4
    array.set 9
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
      array.new_default 9
      local.set 3
      local.get 3
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 9 9
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 9)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 5
    array.set 9
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
      array.new_default 9
      local.set 3
      local.get 3
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 9 9
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 9)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 6
    array.set 9
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
      array.new_default 9
      local.set 3
      local.get 3
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 9 9
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 9)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 7
    array.set 9
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
      array.new_default 9
      local.set 3
      local.get 3
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 9)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 9 9
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 9)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 8
    array.set 9
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
  (func (;5;) (type 39) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.mul
  )
  (func (;6;) (type 43)
    (local eqref eqref eqref i32 eqref)
    call 4
    local.set 0
    local.get 0
    ref.cast (ref 0)
    global.get 0
    call 1
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x2070616d 0x676e656c 0x00006874 0x00000000
    array.new_fixed 45 1
    i32.const 0
    i32.const 10
    struct.new 46
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 3
    array.get 9
    i32.const 2
    i32.eq
    v128.const i32x4 0x2070616d 0x73726966 0x00000074 0x00000000
    array.new_fixed 45 1
    i32.const 0
    i32.const 9
    struct.new 46
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 3
    array.get 9
    i32.const 10
    i32.eq
    v128.const i32x4 0x2070616d 0x7473616c 0x00000000 0x00000000
    array.new_fixed 45 1
    i32.const 0
    i32.const 8
    struct.new 46
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    ref.func 7
    struct.new 3
    call 2
    local.set 0
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 3
    array.get 9
    i32.const 1
    i32.eq
    v128.const i32x4 0x2070616d 0x65646e69 0x20646578 0x73726966
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 45 2
    i32.const 0
    i32.const 17
    struct.new 46
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 9)
    local.get 3
    array.get 9
    i32.const 9
    i32.eq
    v128.const i32x4 0x2070616d 0x65646e69 0x20646578 0x7473616c
    array.new_fixed 45 1
    i32.const 0
    i32.const 16
    struct.new 46
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x72742d79 0x66736e61 0x736d726f 0x6e75722d
    v128.const i32x4 0x656d6974 0x00000000 0x00000000 0x00000000
    array.new_fixed 45 3
    i32.const 0
    i32.const 36
    struct.new 47
    call 3
    drop
  )
  (func (;7;) (type 41) (param eqref i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.add
  )
  (func (;8;) (type 44)
    ref.func 5
    struct.new 2
    global.set 0
  )
)
