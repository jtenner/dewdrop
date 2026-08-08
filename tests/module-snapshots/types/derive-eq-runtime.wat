(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;2;) (func (param i32 eqref) (result i32)))
  (type (;3;) (struct (field i32) (field i32)))
  (type (;4;) (sub (struct (field i32))))
  (type (;5;) (sub final 4 (struct (field i32) (field i32))))
  (type (;6;) (sub final 4 (struct (field i32) (field i32) (field i32))))
  (type (;7;) (func (param (ref 3) (ref 3)) (result i32)))
  (type (;8;) (func (param (ref 3) (ref 3)) (result i32)))
  (type (;9;) (func (param (ref 4) (ref 4)) (result i32)))
  (type (;10;) (func (param (ref 4) (ref 4)) (result i32)))
  (type (;11;) (func (result i32)))
  (type (;12;) (array (mut v128)))
  (type (;13;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;16;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (type (;17;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 1)))
  (memory (;0;) 1)
  (export "main" (func 7))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
      i32.eqz
    end
  )
  (func (;2;) (type 2) (param i32 eqref) (result i32)
    (local (ref 14) (ref 12) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 14)
    local.set 2
    local.get 2
    struct.get 14 0
    local.set 3
    local.get 2
    struct.get 14 1
    local.set 4
    local.get 2
    struct.get 14 2
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
              array.get 12
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
              array.get 12
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
              array.get 12
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
              array.get 12
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
                array.get 12
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 12
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
                array.get 12
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
            array.get 12
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
  (func (;3;) (type 7) (param (ref 3) (ref 3)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      struct.get 3 0
      local.get 1
      struct.get 3 0
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      struct.get 3 1
      local.get 1
      struct.get 3 1
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;4;) (type 8) (param (ref 3) (ref 3)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      struct.get 3 0
      local.get 1
      struct.get 3 0
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      struct.get 3 1
      local.get 1
      struct.get 3 1
      i32.eq
    else
      i32.const 0
    end
    i32.eqz
  )
  (func (;5;) (type 9) (param (ref 4) (ref 4)) (result i32)
    (local i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 eqref i32 eqref i32)
    local.get 0
    local.set 14
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 14
              ref.cast (ref 4)
              struct.get 4 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            local.get 1
            local.set 8
            block ;; label = @5
              local.get 8
              ref.cast (ref 4)
              struct.get 4 0
              i32.const 0
              i32.eq
              if ;; label = @6
                i32.const 1
                local.set 9
                br 1 (;@5;)
              end
              i32.const 1
              if ;; label = @6
                i32.const 0
                local.set 9
                br 1 (;@5;)
              end
              unreachable
            end
            local.get 9
            local.set 15
            br 3 (;@1;)
          end
          local.get 14
          ref.cast (ref 5)
          struct.get 5 1
          local.set 2
          local.get 1
          local.set 10
          block ;; label = @4
            local.get 10
            ref.cast (ref 4)
            struct.get 4 0
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 10
              ref.cast (ref 5)
              struct.get 5 1
              local.set 3
              i32.const 1
              if (result i32) ;; label = @6
                local.get 2
                local.get 3
                i32.eq
              else
                i32.const 0
              end
              local.set 11
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              i32.const 0
              local.set 11
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 11
          local.set 15
          br 2 (;@1;)
        end
        local.get 14
        ref.cast (ref 6)
        struct.get 6 1
        local.set 4
        local.get 14
        ref.cast (ref 6)
        struct.get 6 2
        local.set 5
        local.get 1
        local.set 12
        block ;; label = @3
          local.get 12
          ref.cast (ref 4)
          struct.get 4 0
          i32.const 2
          i32.eq
          if ;; label = @4
            local.get 12
            ref.cast (ref 6)
            struct.get 6 1
            local.set 6
            local.get 12
            ref.cast (ref 6)
            struct.get 6 2
            local.set 7
            i32.const 1
            if (result i32) ;; label = @5
              local.get 4
              local.get 6
              i32.eq
            else
              i32.const 0
            end
            if (result i32) ;; label = @5
              local.get 5
              local.get 7
              call 1
            else
              i32.const 0
            end
            local.set 13
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 13
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 13
        local.set 15
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 15
  )
  (func (;6;) (type 10) (param (ref 4) (ref 4)) (result i32)
    (local i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 eqref i32 eqref i32)
    local.get 0
    local.set 14
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 14
              ref.cast (ref 4)
              struct.get 4 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            local.get 1
            local.set 8
            block ;; label = @5
              local.get 8
              ref.cast (ref 4)
              struct.get 4 0
              i32.const 0
              i32.eq
              if ;; label = @6
                i32.const 1
                local.set 9
                br 1 (;@5;)
              end
              i32.const 1
              if ;; label = @6
                i32.const 0
                local.set 9
                br 1 (;@5;)
              end
              unreachable
            end
            local.get 9
            local.set 15
            br 3 (;@1;)
          end
          local.get 14
          ref.cast (ref 5)
          struct.get 5 1
          local.set 2
          local.get 1
          local.set 10
          block ;; label = @4
            local.get 10
            ref.cast (ref 4)
            struct.get 4 0
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 10
              ref.cast (ref 5)
              struct.get 5 1
              local.set 3
              i32.const 1
              if (result i32) ;; label = @6
                local.get 2
                local.get 3
                i32.eq
              else
                i32.const 0
              end
              local.set 11
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              i32.const 0
              local.set 11
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 11
          local.set 15
          br 2 (;@1;)
        end
        local.get 14
        ref.cast (ref 6)
        struct.get 6 1
        local.set 4
        local.get 14
        ref.cast (ref 6)
        struct.get 6 2
        local.set 5
        local.get 1
        local.set 12
        block ;; label = @3
          local.get 12
          ref.cast (ref 4)
          struct.get 4 0
          i32.const 2
          i32.eq
          if ;; label = @4
            local.get 12
            ref.cast (ref 6)
            struct.get 6 1
            local.set 6
            local.get 12
            ref.cast (ref 6)
            struct.get 6 2
            local.set 7
            i32.const 1
            if (result i32) ;; label = @5
              local.get 4
              local.get 6
              i32.eq
            else
              i32.const 0
            end
            if (result i32) ;; label = @5
              local.get 5
              local.get 7
              call 1
            else
              i32.const 0
            end
            local.set 13
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 13
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 13
        local.set 15
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 15
    i32.eqz
  )
  (func (;7;) (type 11) (result i32)
    (local i32 i32)
    i32.const 3
    i32.const 4
    struct.new 3
    i32.const 3
    i32.const 4
    struct.new 3
    call 3
    if (result i32) ;; label = @1
      i32.const 3
      i32.const 4
      struct.new 3
      i32.const 4
      i32.const 3
      struct.new 3
      call 4
    else
      i32.const 0
    end
    local.set 0
    i32.const 0
    struct.new 4
    i32.const 0
    struct.new 4
    call 5
    if (result i32) ;; label = @1
      i32.const 0
      struct.new 4
      i32.const 1
      i32.const 0
      struct.new 5
      call 6
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      i32.const 7
      struct.new 5
      i32.const 1
      i32.const 7
      struct.new 5
      call 5
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      i32.const 7
      struct.new 5
      i32.const 1
      i32.const 8
      struct.new 5
      call 6
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 2
      i32.const 9
      i32.const 1
      struct.new 6
      i32.const 2
      i32.const 9
      i32.const 1
      struct.new 6
      call 5
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 2
      i32.const 9
      i32.const 1
      struct.new 6
      i32.const 2
      i32.const 9
      i32.const 0
      struct.new 6
      call 6
    else
      i32.const 0
    end
    local.set 1
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x69726564 0x653a6576 0x00000071 0x00000000
      array.new_fixed 12 1
      i32.const 0
      i32.const 9
      struct.new 14
      call 2
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 12 1
      i32.const 0
      i32.const 4
      struct.new 14
      call 2
    end
  )
)
