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
    (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;4;) (struct))
  )
  (rec
    (type (;5;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;6;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;7;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (type (;8;) (array (mut i32)))
  (type (;9;) (array (mut i64)))
  (type (;10;) (array (mut f32)))
  (type (;11;) (array (mut f64)))
  (type (;12;) (array (mut v128)))
  (type (;13;) (array (mut eqref)))
  (type (;14;) (array (mut i8)))
  (type (;15;) (array (mut i16)))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result eqref)))
  (type (;18;) (func (param eqref) (result (ref 0))))
  (type (;19;) (func (param eqref eqref) (result eqref)))
  (type (;20;) (func (param eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result (ref 0))))
  (type (;26;) (func (param eqref eqref eqref) (result eqref)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref eqref i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result i32)))
  (type (;31;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;32;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;33;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;34;) (func (param (ref 0) (ref 0)) (result i32)))
  (type (;35;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;36;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;37;) (func (param (ref 0) (ref 0)) (result i32)))
  (type (;38;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;39;) (func (param i32 eqref) (result i32)))
  (type (;40;) (func (param i32) (result i32)))
  (type (;41;) (func (param i32 i32) (result i32)))
  (type (;42;) (func (param eqref i32 i32) (result i32)))
  (type (;43;) (func (result (ref 0))))
  (type (;44;) (func))
  (type (;45;) (func))
  (type (;46;) (array (mut v128)))
  (type (;47;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;48;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;49;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;50;) (struct (field (mut (ref 46))) (field (mut i32)) (field (mut i32))))
  (type (;51;) (struct (field (mut (ref 46))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 38)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 8))
  (export "__dew_init" (func 9))
  (export "memory" (memory 0))
  (elem (;0;) declare func 6 7)
  (func (;1;) (type 35) (param (ref 0) eqref) (result (ref 0))
    (local i32 eqref i32 i32 eqref i32 eqref eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    local.get 2
    local.set 7
    local.get 7
    array.new_default 8
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
                ref.cast (ref 8)
                local.get 7
                array.get 8
                local.set 5
                local.get 1
                local.set 9
                local.get 9
                ref.cast (ref 2)
                struct.get 2 0
                ref.test (ref 40)
                if (result i32) ;; label = @7
                  local.get 5
                  local.get 9
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 40)
                  call_ref 40
                else
                  local.get 9
                  local.get 5
                  local.get 9
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 23)
                  call_ref 23
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
                    array.new_default 8
                    local.set 8
                    local.get 8
                    ref.cast (ref 8)
                    i32.const 0
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    i32.const 0
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 1
                    array.copy 8 8
                    local.get 6
                    ref.cast (ref 0)
                    local.get 8
                    struct.set 0 0
                    local.get 6
                    ref.cast (ref 0)
                    local.get 8
                    ref.cast (ref 8)
                    array.len
                    struct.set 0 2
                  end
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 8)
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  local.get 10
                  array.set 8
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
  (func (;2;) (type 36) (param (ref 0) eqref) (result (ref 0))
    (local i32 eqref i32 i32 eqref i32 eqref eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    local.get 2
    local.set 7
    local.get 7
    array.new_default 8
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
                ref.cast (ref 8)
                local.get 7
                array.get 8
                local.set 5
                local.get 1
                local.set 9
                local.get 9
                ref.cast (ref 2)
                struct.get 2 0
                ref.test (ref 41)
                if (result i32) ;; label = @7
                  local.get 5
                  local.get 4
                  local.get 9
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 41)
                  call_ref 41
                else
                  local.get 9
                  local.get 5
                  local.get 4
                  local.get 9
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 42)
                  call_ref 42
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
                    array.new_default 8
                    local.set 8
                    local.get 8
                    ref.cast (ref 8)
                    i32.const 0
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    i32.const 0
                    local.get 6
                    ref.cast (ref 0)
                    struct.get 0 1
                    array.copy 8 8
                    local.get 6
                    ref.cast (ref 0)
                    local.get 8
                    struct.set 0 0
                    local.get 6
                    ref.cast (ref 0)
                    local.get 8
                    ref.cast (ref 8)
                    array.len
                    struct.set 0 2
                  end
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 0
                  ref.cast (ref 8)
                  local.get 6
                  ref.cast (ref 0)
                  struct.get 0 1
                  local.get 10
                  array.set 8
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
  (func (;3;) (type 37) (param (ref 0) (ref 0)) (result i32)
    (local i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ne
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 0
      local.set 7
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 7
              local.set 3
              local.get 3
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 0
                local.get 3
                local.set 5
                local.set 4
                local.get 5
                local.get 4
                ref.cast (ref 0)
                struct.get 0 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 4
                ref.cast (ref 0)
                struct.get 0 0
                ref.cast (ref 8)
                local.get 5
                array.get 8
                local.get 1
                local.get 3
                local.set 5
                local.set 4
                local.get 5
                local.get 4
                ref.cast (ref 0)
                struct.get 0 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 4
                ref.cast (ref 0)
                struct.get 0 0
                ref.cast (ref 8)
                local.get 5
                array.get 8
                i32.eq
                if ;; label = @7
                  local.get 3
                  i32.const 1
                  i32.add
                  local.set 7
                  br 4 (;@3;)
                else
                  i32.const 0
                  local.set 8
                  br 5 (;@2;)
                end
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              i32.const 1
              local.set 8
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 8
    end
  )
  (func (;4;) (type 39) (param i32 eqref) (result i32)
    (local (ref 48) (ref 46) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 48)
    local.set 2
    local.get 2
    struct.get 48 0
    local.set 3
    local.get 2
    struct.get 48 1
    local.set 4
    local.get 2
    struct.get 48 2
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
              array.get 46
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
              array.get 46
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
              array.get 46
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
              array.get 46
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
                array.get 46
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 46
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
                array.get 46
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
            array.get 46
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
  (func (;5;) (type 43) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 8
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
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 4
    array.set 8
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
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 5
    array.set 8
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
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 6
    array.set 8
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
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 7
    array.set 8
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
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 8
    array.set 8
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
  (func (;6;) (type 40) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
  )
  (func (;7;) (type 41) (param i32 i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 1
      i32.const 2
      i32.rem_u
      i32.const 1
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;8;) (type 44)
    (local eqref eqref eqref i32 eqref)
    call 5
    local.set 0
    local.get 0
    ref.cast (ref 0)
    global.get 0
    call 1
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 2
    i32.eq
    v128.const i32x4 0x746c6966 0x6c207265 0x74676e65 0x00000068
    array.new_fixed 46 1
    i32.const 0
    i32.const 13
    struct.new 47
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
    ref.cast (ref 8)
    local.get 3
    array.get 8
    i32.const 2
    i32.eq
    v128.const i32x4 0x746c6966 0x66207265 0x74737269 0x00000000
    array.new_fixed 46 1
    i32.const 0
    i32.const 12
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
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
    ref.cast (ref 8)
    local.get 3
    array.get 8
    i32.const 4
    i32.eq
    v128.const i32x4 0x746c6966 0x73207265 0x6e6f6365 0x00000064
    array.new_fixed 46 1
    i32.const 0
    i32.const 13
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    global.get 1
    call 2
    local.get 1
    ref.cast (ref 0)
    call 3
    v128.const i32x4 0x746c6966 0x69207265 0x7865646e 0x00006465
    array.new_fixed 46 1
    i32.const 0
    i32.const 14
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x69662d79 0x7265746c 0x6e75722d 0x656d6974
    array.new_fixed 46 2
    i32.const 0
    i32.const 32
    struct.new 48
    call 4
    drop
  )
  (func (;9;) (type 45)
    ref.func 6
    struct.new 2
    global.set 0
    ref.func 7
    struct.new 2
    global.set 1
  )
)
