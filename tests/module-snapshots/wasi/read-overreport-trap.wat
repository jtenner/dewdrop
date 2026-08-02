(module
  (type (;0;) (func (param eqref) (result i32)))
  (type (;1;) (func (param eqref) (result i32)))
  (type (;2;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;3;) (func (param i32 i32) (result eqref)))
  (type (;4;) (func (result i32)))
  (type (;5;) (array (mut v128)))
  (type (;6;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;9;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_read" (func (;0;) (type 2)))
  (memory (;0;) 1)
  (export "main" (func 4))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 7)
    struct.get 7 2
  )
  (func (;2;) (type 1) (param eqref) (result i32)
    local.get 0
    call 1
  )
  (func (;3;) (type 3) (param i32 i32) (result eqref)
    (local (ref 5) i32 i32 i32 i32 i32 i32 i32 (ref 5) i32 i32 i32 i32 v128 v128)
    local.get 1
    i32.const 65520
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 65520
    else
      local.get 1
    end
    i32.const 4
    i32.shr_u
    local.get 1
    i32.const 65520
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 65520
    else
      local.get 1
    end
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    local.tee 4
    array.new_default 5
    local.set 2
    i32.const 0
    local.set 3
    i32.const 0
    i32.const 16
    i32.store
    block ;; label = @1
      loop ;; label = @2
        local.get 3
        local.get 1
        i32.ge_u
        br_if 1 (;@1;)
        local.get 1
        local.get 3
        i32.sub
        local.tee 5
        i32.const 65520
        i32.gt_u
        if ;; label = @3
          i32.const 65520
          local.set 5
        end
        i32.const 4
        local.get 5
        i32.store
        local.get 0
        i32.const 0
        i32.const 1
        i32.const 8
        call 0
        i32.const 0
        i32.ne
        if ;; label = @3
          unreachable
        end
        i32.const 8
        i32.load
        local.tee 6
        local.get 5
        i32.gt_u
        if ;; label = @3
          unreachable
        end
        local.get 6
        i32.eqz
        br_if 1 (;@1;)
        local.get 3
        local.get 6
        i32.add
        local.tee 7
        i32.const 4
        i32.shr_u
        local.get 7
        i32.const 15
        i32.and
        i32.const 0
        i32.ne
        i32.add
        local.tee 8
        local.get 4
        i32.gt_u
        if ;; label = @3
          local.get 4
          i32.const 1
          i32.shl
          local.tee 9
          local.get 4
          i32.lt_u
          local.get 9
          local.get 8
          i32.lt_u
          i32.or
          if ;; label = @4
            local.get 8
            local.set 9
          end
          local.get 9
          array.new_default 5
          local.set 10
          i32.const 0
          local.set 11
          block ;; label = @4
            loop ;; label = @5
              local.get 11
              local.get 3
              i32.const 4
              i32.shr_u
              local.get 3
              i32.const 15
              i32.and
              i32.const 0
              i32.ne
              i32.add
              i32.ge_u
              br_if 1 (;@4;)
              local.get 10
              local.get 11
              local.get 2
              local.get 11
              array.get 5
              array.set 5
              local.get 11
              i32.const 1
              i32.add
              local.set 11
              br 0 (;@5;)
            end
          end
          local.get 10
          local.set 2
          local.get 9
          local.set 4
        end
        i32.const 0
        local.set 12
        block ;; label = @3
          loop ;; label = @4
            local.get 12
            local.get 6
            i32.ge_u
            br_if 1 (;@3;)
            local.get 3
            local.get 12
            i32.add
            local.set 13
            local.get 13
            i32.const 15
            i32.and
            i32.eqz
            local.get 12
            i32.const 64
            i32.add
            local.get 6
            i32.le_u
            i32.and
            if ;; label = @5
              local.get 2
              local.get 13
              i32.const 4
              i32.shr_u
              i32.const 16
              local.get 12
              i32.add
              v128.load
              array.set 5
              local.get 2
              local.get 13
              i32.const 16
              i32.add
              i32.const 4
              i32.shr_u
              i32.const 16
              local.get 12
              i32.const 16
              i32.add
              i32.add
              v128.load
              array.set 5
              local.get 2
              local.get 13
              i32.const 32
              i32.add
              i32.const 4
              i32.shr_u
              i32.const 16
              local.get 12
              i32.const 32
              i32.add
              i32.add
              v128.load
              array.set 5
              local.get 2
              local.get 13
              i32.const 48
              i32.add
              i32.const 4
              i32.shr_u
              i32.const 16
              local.get 12
              i32.const 48
              i32.add
              i32.add
              v128.load
              array.set 5
              local.get 12
              i32.const 64
              i32.add
              local.set 12
              br 1 (;@4;)
            end
            local.get 12
            i32.const 16
            i32.add
            local.get 6
            i32.le_u
            if ;; label = @5
              i32.const 16
              local.get 12
              i32.add
              v128.load
              local.set 15
              local.get 13
              i32.const 15
              i32.and
              i32.eqz
              if ;; label = @6
                local.get 2
                local.get 13
                i32.const 4
                i32.shr_u
                local.get 15
                array.set 5
              else
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 13
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.lt_u
                local.set 16
                local.get 2
                local.get 13
                i32.const 4
                i32.shr_u
                local.get 2
                local.get 13
                i32.const 4
                i32.shr_u
                array.get 5
                local.get 15
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 13
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.sub
                i8x16.swizzle
                local.get 16
                v128.bitselect
                array.set 5
                local.get 2
                local.get 13
                i32.const 4
                i32.shr_u
                i32.const 1
                i32.add
                local.get 15
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                i32.const 16
                local.get 13
                i32.const 15
                i32.and
                i32.sub
                i8x16.splat
                i8x16.add
                i8x16.swizzle
                local.get 2
                local.get 13
                i32.const 4
                i32.shr_u
                i32.const 1
                i32.add
                array.get 5
                local.get 16
                v128.bitselect
                array.set 5
              end
              local.get 12
              i32.const 16
              i32.add
              local.set 12
              br 1 (;@4;)
            end
            i32.const 16
            local.get 12
            i32.add
            i32.load8_u
            local.set 14
            local.get 2
            local.get 13
            i32.const 4
            i32.shr_u
            local.get 14
            i8x16.splat
            local.get 2
            local.get 13
            i32.const 4
            i32.shr_u
            array.get 5
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 13
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.eq
            v128.bitselect
            array.set 5
            local.get 12
            i32.const 1
            i32.add
            local.set 12
            br 0 (;@4;)
          end
        end
        local.get 7
        local.set 3
        local.get 6
        local.get 5
        i32.lt_u
        br_if 1 (;@1;)
        br 0 (;@2;)
      end
    end
    local.get 2
    i32.const 0
    local.get 3
    struct.new 7
  )
  (func (;4;) (type 4) (result i32)
    i32.const 0
    i32.const 8
    call 3
    call 2
  )
)
