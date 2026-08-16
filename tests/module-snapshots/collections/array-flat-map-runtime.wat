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
  (type (;26;) (func (param (ref 0) (ref 0))))
  (type (;27;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;28;) (func (param (ref 0) eqref) (result (ref 0))))
  (type (;29;) (func (param (ref 0) (ref 0))))
  (type (;30;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;31;) (func (param i32 eqref) (result i32)))
  (type (;32;) (func (param i32) (result (ref 0))))
  (type (;33;) (func (param eqref i32) (result (ref 0))))
  (type (;34;) (func (param i32 i32) (result (ref 0))))
  (type (;35;) (func))
  (type (;36;) (func))
  (type (;37;) (array (mut v128)))
  (type (;38;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;39;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;40;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;41;) (struct (field (mut (ref 37))) (field (mut i32)) (field (mut i32))))
  (type (;42;) (struct (field (mut (ref 37))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 30)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 6))
  (export "__dew_init" (func 7))
  (export "memory" (memory 0))
  (elem (;0;) declare func 5)
  (func (;1;) (type 28) (param (ref 0) eqref) (result (ref 0))
    (local i32 eqref i32 eqref i32 eqref eqref i32 eqref)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    local.set 2
    i32.const 0
    array.new_default 2
    i32.const 0
    i32.const 0
    struct.new 0
    local.set 3
    i32.const 0
    local.set 9
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 9
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
                ref.cast (ref 0)
                local.get 1
                local.set 8
                local.get 8
                ref.cast (ref 1)
                struct.get 1 0
                ref.test (ref 32)
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
                  ref.cast (ref 32)
                  call_ref 32
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
                ref.cast (ref 0)
                call 2
              else
              end
              local.get 4
              i32.const 1
              i32.add
              local.set 9
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 10
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 10
    ref.cast (ref 0)
  )
  (func (;2;) (type 29) (param (ref 0) (ref 0))
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.add
    local.set 3
    local.get 3
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    array.new_default 2
    local.set 4
    local.get 4
    ref.cast (ref 2)
    i32.const 0
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 0
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    array.copy 2 2
    local.get 4
    ref.cast (ref 2)
    local.get 2
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 0
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    array.copy 2 2
    local.get 2
    ref.cast (ref 0)
    local.get 4
    struct.set 0 0
    local.get 2
    ref.cast (ref 0)
    local.get 3
    struct.set 0 1
    local.get 2
    ref.cast (ref 0)
    local.get 3
    struct.set 0 2
  )
  (func (;3;) (type 31) (param i32 eqref) (result i32)
    (local (ref 39) (ref 37) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 39)
    local.set 2
    local.get 2
    struct.get 39 0
    local.set 3
    local.get 2
    struct.get 39 1
    local.set 4
    local.get 2
    struct.get 39 2
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
              array.get 37
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
              array.get 37
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
              array.get 37
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
              array.get 37
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
                array.get 37
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 37
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
                array.get 37
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
            array.get 37
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
  (func (;4;) (type 34) (param i32 i32) (result (ref 0))
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
  (func (;5;) (type 32) (param i32) (result (ref 0))
    local.get 0
    local.get 0
    i32.const 10
    i32.add
    call 4
    ref.cast (ref 0)
  )
  (func (;6;) (type 35)
    (local eqref eqref i32 eqref)
    i32.const 1
    i32.const 2
    call 4
    global.get 0
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 4
    i32.eq
    v128.const i32x4 0x74616c66 0x70616d20 0x6e656c20 0x00687467
    array.new_fixed 37 1
    i32.const 0
    i32.const 15
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    local.get 2
    array.get 2
    i32.const 1
    i32.eq
    v128.const i32x4 0x74616c66 0x70616d20 0x72657a20 0x0000006f
    array.new_fixed 37 1
    i32.const 0
    i32.const 13
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    local.get 2
    array.get 2
    i32.const 11
    i32.eq
    v128.const i32x4 0x74616c66 0x70616d20 0x656e6f20 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 12
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    local.get 2
    array.get 2
    i32.const 2
    i32.eq
    v128.const i32x4 0x74616c66 0x70616d20 0x6f777420 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 12
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    local.get 2
    array.get 2
    i32.const 12
    i32.eq
    v128.const i32x4 0x74616c66 0x70616d20 0x72687420 0x00006565
    array.new_fixed 37 1
    i32.const 0
    i32.const 14
    struct.new 38
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x6c662d79 0x6d2d7461 0x722d7061 0x69746e75
    v128.const i32x4 0x0000656d 0x00000000 0x00000000 0x00000000
    array.new_fixed 37 3
    i32.const 0
    i32.const 34
    struct.new 39
    call 3
    drop
  )
  (func (;7;) (type 36)
    ref.func 5
    struct.new 1
    global.set 0
  )
)
