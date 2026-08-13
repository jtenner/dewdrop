(module
  (type (;0;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;1;) (func (param i32 eqref) (result i32)))
  (type (;2;) (sub (struct (field i32))))
  (type (;3;) (sub final 2 (struct (field i32) (field i32))))
  (type (;4;) (sub (struct (field i32))))
  (type (;5;) (sub final 4 (struct (field i32) (field (ref 2)))))
  (type (;6;) (sub final 4 (struct (field i32) (field (ref 2)) (field i32))))
  (type (;7;) (struct (field (ref 2))))
  (type (;8;) (func (param (ref 4)) (result i32)))
  (type (;9;) (func (param (ref 7)) (result i32)))
  (type (;10;) (func (result i32)))
  (type (;11;) (array (mut v128)))
  (type (;12;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;15;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 0)))
  (memory (;0;) 1)
  (export "main" (func 4))
  (export "memory" (memory 0))
  (func (;1;) (type 1) (param i32 eqref) (result i32)
    (local (ref 13) (ref 11) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 13)
    local.set 2
    local.get 2
    struct.get 13 0
    local.set 3
    local.get 2
    struct.get 13 1
    local.set 4
    local.get 2
    struct.get 13 2
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
              array.get 11
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
              array.get 11
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
              array.get 11
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
              array.get 11
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
                array.get 11
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 11
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
                array.get 11
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
            array.get 11
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
  (func (;2;) (type 8) (param (ref 4)) (result i32)
    (local i32 i32 i32 i32 eqref i32)
    local.get 0
    local.set 5
    block ;; label = @1
      local.get 5
      ref.cast (ref 4)
      struct.get 4 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 5
        ref.cast (ref 5)
        struct.get 5 1
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 5)
          struct.get 5 1
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 7
          i32.eq
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        i32.const 70
        local.set 6
        br 1 (;@1;)
      end
      local.get 5
      ref.cast (ref 4)
      struct.get 4 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 5
        ref.cast (ref 5)
        struct.get 5 1
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 5)
          struct.get 5 1
          ref.cast (ref 3)
          struct.get 3 1
          local.set 1
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 5
        ref.cast (ref 4)
        struct.get 4 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 5)
          struct.get 5 1
          ref.cast (ref 2)
          struct.get 2 0
          i32.const 1
          i32.eq
          if (result i32) ;; label = @4
            local.get 5
            ref.cast (ref 5)
            struct.get 5 1
            ref.cast (ref 3)
            struct.get 3 1
            local.set 1
            i32.const 1
          else
            i32.const 0
          end
        else
          i32.const 0
        end
      end
      if ;; label = @2
        local.get 1
        local.set 6
        br 1 (;@1;)
      end
      local.get 5
      ref.cast (ref 4)
      struct.get 4 0
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 5
        ref.cast (ref 6)
        struct.get 6 1
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 6)
          struct.get 6 1
          ref.cast (ref 3)
          struct.get 3 1
          local.set 2
          i32.const 1
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 6)
          struct.get 6 2
          i32.const 1
          i32.eq
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 2
        i32.const 100
        i32.add
        local.set 6
        br 1 (;@1;)
      end
      local.get 5
      ref.cast (ref 4)
      struct.get 4 0
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 5
        ref.cast (ref 6)
        struct.get 6 1
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 6)
          struct.get 6 1
          ref.cast (ref 3)
          struct.get 3 1
          local.set 3
          i32.const 1
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 6)
          struct.get 6 2
          i32.const 0
          i32.eq
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 3
        i32.const 200
        i32.add
        local.set 6
        br 1 (;@1;)
      end
      local.get 5
      ref.cast (ref 4)
      struct.get 4 0
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 5
        ref.cast (ref 6)
        struct.get 6 1
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 6)
          struct.get 6 1
          ref.cast (ref 3)
          struct.get 3 1
          local.set 4
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 4
        i32.const 300
        i32.add
        local.set 6
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 6
  )
  (func (;3;) (type 9) (param (ref 7)) (result i32)
    (local i32 i32 eqref i32)
    local.get 0
    local.set 3
    block ;; label = @1
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 2)
      struct.get 2 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 3
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 3)
        struct.get 3 1
        local.set 1
        i32.const 1
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 1
        local.set 4
        br 1 (;@1;)
      end
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 2)
      struct.get 2 0
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 3
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 3)
        struct.get 3 1
        local.set 2
        i32.const 1
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 2
        i32.const 10
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;4;) (type 10) (result i32)
    (local i32)
    i32.const 0
    i32.const 0
    i32.const 7
    struct.new 3
    ref.cast (ref 2)
    struct.new 5
    call 2
    i32.const 0
    i32.const 1
    i32.const 5
    struct.new 3
    ref.cast (ref 2)
    struct.new 5
    call 2
    i32.add
    i32.const 1
    i32.const 0
    i32.const 3
    struct.new 3
    ref.cast (ref 2)
    i32.const 1
    struct.new 6
    call 2
    i32.add
    i32.const 1
    i32.const 4
    struct.new 3
    ref.cast (ref 2)
    struct.new 7
    call 3
    i32.add
    local.set 0
    local.get 0
    i32.const 192
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x746e6f63 0x3a6c6f72 0x7473656e 0x702d6465
      v128.const i32x4 0x65747461 0x00736e72 0x00000000 0x00000000
      array.new_fixed 11 2
      i32.const 0
      i32.const 23
      struct.new 13
      call 1
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 11 1
      i32.const 0
      i32.const 4
      struct.new 13
      call 1
    end
  )
)
