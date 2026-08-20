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
    (type (;3;) (sub final 2 (struct (field funcref) (field eqref) (field eqref))))
  )
  (rec
    (type (;4;) (sub final 2 (struct (field funcref) (field eqref))))
  )
  (rec
    (type (;5;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;6;) (struct))
  )
  (rec
    (type (;7;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;8;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;9;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (type (;10;) (array (mut i32)))
  (type (;11;) (array (mut i64)))
  (type (;12;) (array (mut f32)))
  (type (;13;) (array (mut f64)))
  (type (;14;) (array (mut v128)))
  (type (;15;) (array (mut eqref)))
  (type (;16;) (array (mut i8)))
  (type (;17;) (array (mut i16)))
  (type (;18;) (func (param eqref) (result eqref)))
  (type (;19;) (func (param eqref i32) (result eqref)))
  (type (;20;) (func (param eqref) (result (ref 0))))
  (type (;21;) (func (param eqref eqref) (result eqref)))
  (type (;22;) (func (param eqref)))
  (type (;23;) (func (param eqref i32)))
  (type (;24;) (func (param eqref) (result i32)))
  (type (;25;) (func (param eqref i32) (result i32)))
  (type (;26;) (func (param eqref eqref i32) (result eqref)))
  (type (;27;) (func (param eqref eqref) (result (ref 0))))
  (type (;28;) (func (param eqref eqref eqref) (result eqref)))
  (type (;29;) (func (param eqref eqref)))
  (type (;30;) (func (param eqref eqref i32)))
  (type (;31;) (func (param eqref eqref) (result i32)))
  (type (;32;) (func (param eqref eqref i32) (result i32)))
  (type (;33;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;34;) (func))
  (type (;35;) (func (param (ref 0) eqref)))
  (type (;36;) (func (param (ref 0) eqref)))
  (type (;37;) (func (param (ref 0) eqref)))
  (type (;38;) (func (param (ref 0) eqref)))
  (type (;39;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;40;) (func (param i32 eqref) (result i32)))
  (type (;41;) (func (param i32)))
  (type (;42;) (func (param i32 i32)))
  (type (;43;) (func (param eqref i32 i32)))
  (type (;44;) (func (result (ref 0))))
  (type (;45;) (func (result (ref 0))))
  (type (;46;) (func))
  (type (;47;) (array (mut v128)))
  (type (;48;) (struct (field (ref 47)) (field i32) (field i32)))
  (type (;49;) (struct (field (ref 47)) (field i32) (field i32)))
  (type (;50;) (struct (field (ref 47)) (field i32) (field i32)))
  (type (;51;) (struct (field (mut (ref 47))) (field (mut i32)) (field (mut i32))))
  (type (;52;) (struct (field (mut (ref 47))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 39)))
  (memory (;0;) 1)
  (export "main" (func 7))
  (export "memory" (memory 0))
  (elem (;0;) declare func 8 9)
  (func (;1;) (type 34))
  (func (;2;) (type 37) (param (ref 0) eqref)
    (local i32 i32 eqref i32 eqref eqref i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              local.get 0
              ref.cast (ref 0)
              struct.get 0 1
              i32.lt_u
              if ;; label = @6
                local.get 1
                local.set 7
                local.get 7
                ref.cast (ref 2)
                struct.get 2 0
                ref.test (ref 41)
                if ;; label = @7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 10)
                  local.get 5
                  array.get 10
                  local.get 7
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 41)
                  call_ref 41
                else
                  local.get 7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 10)
                  local.get 5
                  array.get 10
                  local.get 7
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 23)
                  call_ref 23
                end
              else
              end
              local.get 3
              i32.const 1
              i32.add
              local.set 8
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 1
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;3;) (type 38) (param (ref 0) eqref)
    (local i32 i32 eqref i32 eqref eqref i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              local.get 0
              ref.cast (ref 0)
              struct.get 0 1
              i32.lt_u
              if ;; label = @6
                local.get 1
                local.set 7
                local.get 7
                ref.cast (ref 2)
                struct.get 2 0
                ref.test (ref 42)
                if ;; label = @7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 10)
                  local.get 5
                  array.get 10
                  local.get 3
                  local.get 7
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 42)
                  call_ref 42
                else
                  local.get 7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 10)
                  local.get 5
                  array.get 10
                  local.get 3
                  local.get 7
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 43)
                  call_ref 43
                end
              else
              end
              local.get 3
              i32.const 1
              i32.add
              local.set 8
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 1
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;4;) (type 40) (param i32 eqref) (result i32)
    (local (ref 49) (ref 47) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 49)
    local.set 2
    local.get 2
    struct.get 49 0
    local.set 3
    local.get 2
    struct.get 49 1
    local.set 4
    local.get 2
    struct.get 49 2
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
              array.get 47
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
              array.get 47
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
              array.get 47
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
              array.get 47
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
                array.get 47
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 47
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
                array.get 47
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
            array.get 47
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
  (func (;5;) (type 44) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 10
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
      array.new_default 10
      local.set 3
      local.get 3
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 10 10
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 10)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 4
    array.set 10
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
      array.new_default 10
      local.set 3
      local.get 3
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 10 10
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 10)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 5
    array.set 10
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
      array.new_default 10
      local.set 3
      local.get 3
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 10 10
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 10)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 6
    array.set 10
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
      array.new_default 10
      local.set 3
      local.get 3
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 10 10
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 10)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 7
    array.set 10
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
      array.new_default 10
      local.set 3
      local.get 3
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 10 10
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 10)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 8
    array.set 10
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
  (func (;6;) (type 45) (result (ref 0))
    i32.const 0
    array.new_default 10
    i32.const 0
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;7;) (type 46)
    (local eqref eqref eqref eqref i32 eqref)
    call 5
    local.set 0
    call 6
    local.set 1
    local.get 0
    ref.cast (ref 0)
    ref.func 8
    local.get 1
    local.get 0
    struct.new 3
    call 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x5f726f66 0x68636165 0x616e7320 0x6f687370
    v128.const i32x4 0x6c207374 0x74676e65 0x00000068 0x00000000
    array.new_fixed 47 2
    i32.const 0
    i32.const 25
    struct.new 48
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
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
    ref.cast (ref 10)
    local.get 4
    array.get 10
    i32.const 1
    i32.eq
    v128.const i32x4 0x5f726f66 0x68636165 0x72696620 0x00007473
    array.new_fixed 47 1
    i32.const 0
    i32.const 14
    struct.new 48
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 4
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
    ref.cast (ref 10)
    local.get 4
    array.get 10
    i32.const 5
    i32.eq
    v128.const i32x4 0x5f726f66 0x68636165 0x6e696620 0x69206c61
    v128.const i32x4 0x6974696e 0x76206c61 0x65756c61 0x00000000
    array.new_fixed 47 2
    i32.const 0
    i32.const 28
    struct.new 48
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 6
    i32.eq
    v128.const i32x4 0x5f726f66 0x68636165 0x74756d20 0x6f697461
    v128.const i32x4 0x6572206e 0x6e696174 0x00006465 0x00000000
    array.new_fixed 47 2
    i32.const 0
    i32.const 26
    struct.new 48
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 6
    local.set 2
    local.get 0
    ref.cast (ref 0)
    ref.func 9
    local.get 2
    struct.new 4
    call 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 6
    i32.eq
    v128.const i32x4 0x65646e69 0x20646578 0x5f726f66 0x68636165
    v128.const i32x4 0x6e656c20 0x00687467 0x00000000 0x00000000
    array.new_fixed 47 2
    i32.const 0
    i32.const 23
    struct.new 48
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
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
    ref.cast (ref 10)
    local.get 4
    array.get 10
    i32.const 1
    i32.eq
    v128.const i32x4 0x65646e69 0x20646578 0x5f726f66 0x68636165
    v128.const i32x4 0x72696620 0x00007473 0x00000000 0x00000000
    array.new_fixed 47 2
    i32.const 0
    i32.const 22
    struct.new 48
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 5
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
    ref.cast (ref 10)
    local.get 4
    array.get 10
    i32.const 11
    i32.eq
    v128.const i32x4 0x65646e69 0x20646578 0x5f726f66 0x68636165
    v128.const i32x4 0x73616c20 0x00000074 0x00000000 0x00000000
    array.new_fixed 47 2
    i32.const 0
    i32.const 21
    struct.new 48
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x61632d79 0x61626c6c 0x2d736b63 0x746e7572
    v128.const i32x4 0x00656d69 0x00000000 0x00000000 0x00000000
    array.new_fixed 47 3
    i32.const 0
    i32.const 35
    struct.new 49
    call 4
    drop
  )
  (func (;8;) (type 23) (param eqref i32)
    (local eqref i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 3)
    struct.get 3 1
    ref.cast (ref 0)
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    local.get 2
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 10
      local.set 4
      local.get 4
      ref.cast (ref 10)
      i32.const 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 10 10
      local.get 2
      ref.cast (ref 0)
      local.get 4
      struct.set 0 0
      local.get 2
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 10)
      array.len
      struct.set 0 2
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    local.get 5
    array.set 10
    local.get 2
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 1
    i32.const 1
    i32.eq
    if ;; label = @1
      local.get 0
      ref.cast (ref 3)
      struct.get 3 2
      ref.cast (ref 0)
      i32.const 6
      local.set 6
      local.set 2
      local.get 2
      ref.cast (ref 0)
      struct.get 0 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 2
      i32.eq
      if ;; label = @2
        local.get 2
        ref.cast (ref 0)
        struct.get 0 2
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 2
          ref.cast (ref 0)
          struct.get 0 2
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 3
        local.get 2
        ref.cast (ref 0)
        struct.get 0 2
        i32.le_u
        if ;; label = @3
          unreachable
        end
        local.get 3
        array.new_default 10
        local.set 4
        local.get 4
        ref.cast (ref 10)
        i32.const 0
        local.get 2
        ref.cast (ref 0)
        struct.get 0 0
        ref.cast (ref 10)
        i32.const 0
        local.get 2
        ref.cast (ref 0)
        struct.get 0 1
        array.copy 10 10
        local.get 2
        ref.cast (ref 0)
        local.get 4
        struct.set 0 0
        local.get 2
        ref.cast (ref 0)
        local.get 4
        ref.cast (ref 10)
        array.len
        struct.set 0 2
      end
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 0)
      struct.get 0 1
      local.get 6
      array.set 10
      local.get 2
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 0)
      struct.get 0 1
      i32.const 1
      i32.add
      struct.set 0 1
    else
    end
  )
  (func (;9;) (type 43) (param eqref i32 i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 4)
    struct.get 4 1
    ref.cast (ref 0)
    local.get 1
    local.get 2
    i32.add
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
      array.new_default 10
      local.set 5
      local.get 5
      ref.cast (ref 10)
      i32.const 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      i32.const 0
      local.get 3
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 10 10
      local.get 3
      ref.cast (ref 0)
      local.get 5
      struct.set 0 0
      local.get 3
      ref.cast (ref 0)
      local.get 5
      ref.cast (ref 10)
      array.len
      struct.set 0 2
    end
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 10)
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    local.get 6
    array.set 10
    local.get 3
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
  )
)
