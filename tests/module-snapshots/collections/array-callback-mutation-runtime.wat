(module
  (rec
    (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;1;) (sub (struct (field funcref))))
  )
  (rec
    (type (;2;) (sub final 1 (struct (field funcref) (field eqref) (field eqref))))
  )
  (rec
    (type (;3;) (sub final 1 (struct (field funcref) (field eqref))))
  )
  (type (;4;) (array (mut i32)))
  (type (;5;) (array (mut i64)))
  (type (;6;) (array (mut f32)))
  (type (;7;) (array (mut f64)))
  (type (;8;) (array (mut v128)))
  (type (;9;) (array (mut eqref)))
  (type (;10;) (array (mut i8)))
  (type (;11;) (array (mut i16)))
  (type (;12;) (func (param eqref) (result eqref)))
  (type (;13;) (func (param eqref i32) (result eqref)))
  (type (;14;) (func (param eqref) (result (ref 0))))
  (type (;15;) (func (param eqref eqref) (result eqref)))
  (type (;16;) (func (param eqref)))
  (type (;17;) (func (param eqref i32)))
  (type (;18;) (func (param eqref) (result i32)))
  (type (;19;) (func (param eqref i32) (result i32)))
  (type (;20;) (func (param eqref eqref i32) (result eqref)))
  (type (;21;) (func (param eqref eqref) (result (ref 0))))
  (type (;22;) (func (param eqref eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref eqref)))
  (type (;24;) (func (param eqref eqref i32)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref eqref i32) (result i32)))
  (type (;27;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;28;) (func))
  (type (;29;) (func (param (ref 0) eqref)))
  (type (;30;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;31;) (func (param (ref 0) eqref)))
  (type (;32;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;33;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;34;) (func (param i32 eqref) (result i32)))
  (type (;35;) (func (param i32)))
  (type (;36;) (func (param i32) (result i32)))
  (type (;37;) (func (result (ref 0))))
  (type (;38;) (func (result (ref 0))))
  (type (;39;) (func))
  (type (;40;) (array (mut v128)))
  (type (;41;) (struct (field (ref 40)) (field i32) (field i32)))
  (type (;42;) (struct (field (ref 40)) (field i32) (field i32)))
  (type (;43;) (struct (field (ref 40)) (field i32) (field i32)))
  (type (;44;) (struct (field (mut (ref 40))) (field (mut i32)) (field (mut i32))))
  (type (;45;) (struct (field (mut (ref 40))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 33)))
  (memory (;0;) 1)
  (export "main" (func 7))
  (export "memory" (memory 0))
  (elem (;0;) declare func 8 9)
  (func (;1;) (type 28))
  (func (;2;) (type 31) (param (ref 0) eqref)
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
                ref.cast (ref 1)
                struct.get 1 0
                ref.test (ref 35)
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
                  ref.cast (ref 4)
                  local.get 5
                  array.get 4
                  local.get 7
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 35)
                  call_ref 35
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
                  ref.cast (ref 4)
                  local.get 5
                  array.get 4
                  local.get 7
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 17)
                  call_ref 17
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
  (func (;3;) (type 32) (param (ref 0) eqref) (result (ref 0))
    (local i32 eqref i32 i32 eqref i32 eqref eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    local.get 2
    local.set 7
    local.get 7
    array.new_default 4
    i32.const 0
    local.get 7
    struct.new 0
    local.set 3
    i32.const 0
    local.set 11
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 11
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
                local.get 0
                local.get 4
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
                ref.cast (ref 4)
                local.get 7
                array.get 4
                local.set 5
                local.get 1
                local.set 9
                local.get 9
                ref.cast (ref 1)
                struct.get 1 0
                ref.test (ref 36)
                if (result i32) ;; label = @7
                  local.get 5
                  local.get 9
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 36)
                  call_ref 36
                else
                  local.get 9
                  local.get 5
                  local.get 9
                  ref.cast (ref 1)
                  struct.get 1 0
                  ref.cast (ref 19)
                  call_ref 19
                end
                if ;; label = @7
                  local.get 3
                  local.get 5
                  local.set 10
                  local.set 6
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 2
                  i32.eq
                  if ;; label = @8
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 2
                    i32.eqz
                    if (result i32) ;; label = @9
                      i32.const 4
                    else
                      local.get 6
                      ref.cast (ref 0)
                      struct.get 0 2
                      i32.const 2
                      i32.mul
                    end
                    local.set 7
                    local.get 7
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 2
                    i32.le_u
                    if ;; label = @9
                      unreachable
                    end
                    local.get 7
                    array.new_default 4
                    local.set 8
                    local.get 8
                    ref.cast (ref 4)
                    i32.const 0
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 4)
                    i32.const 0
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 1
                    array.copy 4 4
                    local.get 6
                    ref.cast (ref 0)
                    local.get 8
                    struct.set 0 0
                    local.get 6
                    ref.cast (ref 0)
                    local.get 8
                    ref.cast (ref 4)
                    array.len
                    struct.set 0 2
                  end
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 4)
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  local.get 10
                  array.set 4
                  local.get 6
                  ref.cast (ref 0)
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  i32.const 1
                  i32.add
                  struct.set 0 1
                else
                end
              else
              end
              local.get 4
              i32.const 1
              i32.add
              local.set 11
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 12
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 12
    ref.cast (ref 0)
  )
  (func (;4;) (type 34) (param i32 eqref) (result i32)
    (local (ref 42) (ref 40) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 42)
    local.set 2
    local.get 2
    struct.get 42 0
    local.set 3
    local.get 2
    struct.get 42 1
    local.set 4
    local.get 2
    struct.get 42 2
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
              array.get 40
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
              array.get 40
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
              array.get 40
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
              array.get 40
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
                array.get 40
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 40
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
                array.get 40
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
            array.get 40
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
  (func (;5;) (type 37) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 4
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
      array.new_default 4
      local.set 3
      local.get 3
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 4 4
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 4)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 4
    array.set 4
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
      array.new_default 4
      local.set 3
      local.get 3
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 4 4
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 4)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 5
    array.set 4
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
      array.new_default 4
      local.set 3
      local.get 3
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 4 4
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 4)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 6
    array.set 4
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
      array.new_default 4
      local.set 3
      local.get 3
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 4 4
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 4)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 7
    array.set 4
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
      array.new_default 4
      local.set 3
      local.get 3
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 4 4
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 4)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 8
    array.set 4
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
  (func (;6;) (type 38) (result (ref 0))
    i32.const 0
    array.new_default 4
    i32.const 0
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;7;) (type 39)
    (local eqref eqref eqref eqref eqref i32 eqref)
    call 5
    local.set 0
    call 6
    local.set 1
    local.get 0
    ref.cast (ref 0)
    ref.func 8
    local.get 1
    local.get 0
    struct.new 2
    call 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x5f726f66 0x68636165 0x696b7320 0x72207370
    v128.const i32x4 0x766f6d65 0x70206465 0x7469736f 0x736e6f69
    array.new_fixed 40 2
    i32.const 0
    i32.const 32
    struct.new 41
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 5
    array.get 4
    i32.const 1
    i32.eq
    v128.const i32x4 0x5f726f66 0x68636165 0x65656b20 0x66207370
    v128.const i32x4 0x74737269 0x00000000 0x00000000 0x00000000
    array.new_fixed 40 2
    i32.const 0
    i32.const 20
    struct.new 41
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 5
    local.set 2
    local.get 2
    ref.cast (ref 0)
    ref.func 9
    local.get 2
    struct.new 3
    call 3
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x746c6966 0x73207265 0x7370696b 0x6d657220
    v128.const i32x4 0x6465766f 0x736f7020 0x6f697469 0x0000736e
    array.new_fixed 40 2
    i32.const 0
    i32.const 30
    struct.new 41
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    i32.const 0
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 5
    array.get 4
    i32.const 1
    i32.eq
    v128.const i32x4 0x746c6966 0x6b207265 0x73706565 0x72696620
    v128.const i32x4 0x00007473 0x00000000 0x00000000 0x00000000
    array.new_fixed 40 2
    i32.const 0
    i32.const 18
    struct.new 41
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x61632d79 0x61626c6c 0x6d2d6b63 0x74617475
    v128.const i32x4 0x2d6e6f69 0x746e7572 0x00656d69 0x00000000
    array.new_fixed 40 3
    i32.const 0
    i32.const 43
    struct.new 42
    call 4
    drop
  )
  (func (;8;) (type 17) (param eqref i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
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
      array.new_default 4
      local.set 4
      local.get 4
      ref.cast (ref 4)
      i32.const 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      i32.const 0
      local.get 2
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 4 4
      local.get 2
      ref.cast (ref 0)
      local.get 4
      struct.set 0 0
      local.get 2
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 4)
      array.len
      struct.set 0 2
    end
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 4)
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    local.get 5
    array.set 4
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
      ref.cast (ref 2)
      struct.get 2 2
      ref.cast (ref 0)
      local.set 2
      local.get 2
      ref.cast (ref 0)
      i32.const 0
      struct.set 0 1
    else
    end
  )
  (func (;9;) (type 19) (param eqref i32) (result i32)
    (local eqref i32 eqref)
    local.get 1
    i32.const 1
    i32.eq
    if ;; label = @1
      local.get 0
      ref.cast (ref 3)
      struct.get 3 1
      ref.cast (ref 0)
      local.set 2
      local.get 2
      ref.cast (ref 0)
      i32.const 0
      struct.set 0 1
    else
    end
    i32.const 1
  )
)
