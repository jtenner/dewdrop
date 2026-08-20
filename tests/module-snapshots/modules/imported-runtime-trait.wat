(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32)))
  (type (;2;) (struct (field i32)))
  (type (;3;) (func (param (ref 2)) (result i32)))
  (type (;4;) (func (result (ref 2))))
  (type (;5;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;6;) (func (param i32 eqref) (result i32)))
  (type (;7;) (func (param eqref) (result i32)))
  (type (;8;) (struct (field (ref null 7))))
  (type (;9;) (struct (field eqref) (field (ref 8))))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (result i32)))
  (type (;12;) (func))
  (type (;13;) (array (mut v128)))
  (type (;14;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;17;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 5)))
  (memory (;0;) 1)
  (global (;0;) (mut (ref null 8)) ref.null 8)
  (export "main" (func 7))
  (export "__dew_init" (func 9))
  (export "memory" (memory 0))
  (elem (;0;) declare func 8)
  (func (;1;) (type 0) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 0
    local.set 0
    i32.const 48
    local.set 1
    local.get 0
    i32.const 0
    i32.lt_s
    local.tee 3
    if (result i32) ;; label = @1
      i32.const 0
      local.get 0
      i32.sub
    else
      local.get 0
    end
    local.set 2
    loop ;; label = @1
      local.get 1
      i32.const 1
      i32.sub
      local.tee 1
      local.get 2
      i32.const 10
      i32.rem_u
      i32.const 48
      i32.add
      i32.store8
      local.get 2
      i32.const 10
      i32.div_u
      local.tee 2
      br_if 0 (;@1;)
    end
    local.get 3
    if ;; label = @1
      local.get 1
      i32.const 1
      i32.sub
      local.tee 1
      i32.const 45
      i32.store8
    end
    i32.const 48
    local.get 1
    i32.sub
    local.set 4
    i32.const 0
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        local.get 5
        local.get 4
        i32.ge_u
        br_if 1 (;@1;)
        i32.const 0
        local.get 1
        local.get 5
        i32.add
        i32.store
        i32.const 4
        local.get 4
        local.get 5
        i32.sub
        i32.store
        i32.const 1
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
        i32.eqz
        local.get 6
        local.get 4
        local.get 5
        i32.sub
        i32.gt_u
        i32.or
        if ;; label = @3
          unreachable
        end
        local.get 5
        local.get 6
        i32.add
        local.set 5
        br 0 (;@2;)
      end
    end
    local.get 4
  )
  (func (;2;) (type 1) (param i32)
    local.get 0
    call 1
    drop
  )
  (func (;3;) (type 3) (param (ref 2)) (result i32)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    i32.const 1
    i32.add
  )
  (func (;4;) (type 4) (result (ref 2))
    i32.const 41
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;5;) (type 6) (param i32 eqref) (result i32)
    (local (ref 15) (ref 13) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 15)
    local.set 2
    local.get 2
    struct.get 15 0
    local.set 3
    local.get 2
    struct.get 15 1
    local.set 4
    local.get 2
    struct.get 15 2
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
              array.get 13
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
              array.get 13
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
              array.get 13
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
              array.get 13
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
                array.get 13
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 13
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
                array.get 13
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
            array.get 13
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
  (func (;6;) (type 10) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.tee 1
    ref.cast (ref 9)
    struct.get 9 0
    local.get 1
    ref.cast (ref 9)
    struct.get 9 1
    struct.get 8 0
    call_ref 7
    i32.const 0
    i32.add
  )
  (func (;7;) (type 11) (result i32)
    call 4
    global.get 0
    ref.cast (ref 8)
    struct.new 9
    call 6
    call 2
    i32.const 1
    v128.const i32x4 0x6172747c 0x693a7469 0x726f706d 0x00646574
    array.new_fixed 13 1
    i32.const 0
    i32.const 15
    struct.new 15
    call 5
  )
  (func (;8;) (type 7) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 2)
    call 3
  )
  (func (;9;) (type 12)
    ref.func 8
    struct.new 8
    global.set 0
  )
)
