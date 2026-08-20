(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (struct (field i32)))
  (type (;4;) (func (param i32) (result (ref 3))))
  (type (;5;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;6;) (func (param i32 eqref) (result i32)))
  (type (;7;) (func (param (ref 3)) (result i32)))
  (type (;8;) (func (result i32)))
  (type (;9;) (func))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 5)))
  (memory (;0;) 1)
  (global (;0;) i32 i32.const 42)
  (global (;1;) (mut eqref) ref.null none)
  (global (;2;) (mut eqref) ref.null none)
  (export "main" (func 4))
  (export "__dew_init" (func 7))
  (export "memory" (memory 0))
  (func (;1;) (type 4) (param i32) (result (ref 3))
    local.get 0
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;2;) (type 6) (param i32 eqref) (result i32)
    (local (ref 12) (ref 10) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 12)
    local.set 2
    local.get 2
    struct.get 12 0
    local.set 3
    local.get 2
    struct.get 12 1
    local.set 4
    local.get 2
    struct.get 12 2
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
              array.get 10
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
              array.get 10
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
              array.get 10
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
              array.get 10
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
                array.get 10
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 10
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
                array.get 10
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
            array.get 10
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
  (func (;3;) (type 7) (param (ref 3)) (result i32)
    local.get 0
    ref.cast (ref 3)
    struct.get 3 0
  )
  (func (;4;) (type 8) (result i32)
    (local i32 i32 eqref i32)
    global.get 2
    ref.cast (ref 0)
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
          i32.const 0
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 1)
        struct.get 1 1
        local.set 0
        local.get 0
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
    local.set 1
    global.get 1
    ref.cast (ref 3)
    call 3
    global.get 0
    i32.add
    local.get 1
    i32.add
    i32.const 125
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x75646f6d 0x3a73656c 0x6f706d69 0x64657472
      v128.const i32x4 0x6c61762d 0x2d736575 0x00353231 0x00000000
      array.new_fixed 10 2
      i32.const 0
      i32.const 27
      struct.new 12
      call 2
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 10 1
      i32.const 0
      i32.const 4
      struct.new 12
      call 2
    end
  )
  (func (;5;) (type 9)
    global.get 0
    i32.const 1
    i32.sub
    call 1
    global.set 1
  )
  (func (;6;) (type 9)
    i32.const 1
    global.get 0
    struct.new 1
    global.set 2
  )
  (func (;7;) (type 9)
    call 5
    call 6
  )
)
