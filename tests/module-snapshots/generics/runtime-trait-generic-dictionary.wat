(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32)))
  (type (;2;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;3;) (func (param i32 eqref) (result i32)))
  (type (;4;) (struct))
  (type (;5;) (struct))
  (type (;6;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;7;) (func (param eqref) (result i32)))
  (type (;8;) (struct (field (ref null 7))))
  (type (;9;) (struct (field eqref) (field (ref 8))))
  (type (;10;) (func (param (ref 4)) (result i32)))
  (type (;11;) (func (param (ref 5)) (result i32)))
  (type (;12;) (func (param (ref 6)) (result i32)))
  (type (;13;) (func (param i32 eqref eqref) (result i32)))
  (type (;14;) (func (result i32)))
  (type (;15;) (func (param (ref 6)) (result i32)))
  (type (;16;) (func (param (ref 6)) (result i32)))
  (type (;17;) (func))
  (type (;18;) (array (mut v128)))
  (type (;19;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;21;) (struct (field (ref 18)) (field i32) (field i32)))
  (type (;22;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (type (;23;) (struct (field (mut (ref 18))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 2)))
  (memory (;0;) 1)
  (global (;0;) (mut (ref null 8)) ref.null 8)
  (global (;1;) (mut (ref null 8)) ref.null 8)
  (export "main" (func 7))
  (export "__dew_init" (func 12))
  (export "memory" (memory 0))
  (elem (;0;) declare func 8 9)
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
  (func (;3;) (type 3) (param i32 eqref) (result i32)
    (local (ref 20) (ref 18) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 20)
    local.set 2
    local.get 2
    struct.get 20 0
    local.set 3
    local.get 2
    struct.get 20 1
    local.set 4
    local.get 2
    struct.get 20 2
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
              array.get 18
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
              array.get 18
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
              array.get 18
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
              array.get 18
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
                array.get 18
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 18
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
                array.get 18
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
            array.get 18
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
  (func (;4;) (type 10) (param (ref 4)) (result i32)
    i32.const 42
  )
  (func (;5;) (type 11) (param (ref 5)) (result i32)
    i32.const 7
  )
  (func (;6;) (type 13) (param i32 eqref eqref) (result i32)
    (local eqref eqref)
    local.get 0
    if (result eqref) ;; label = @1
      local.get 1
    else
      local.get 2
    end
    local.set 3
    local.get 3
    local.tee 4
    ref.cast (ref 9)
    struct.get 9 0
    local.get 4
    ref.cast (ref 9)
    struct.get 9 1
    struct.get 8 0
    call_ref 7
  )
  (func (;7;) (type 14) (result i32)
    i32.const 1
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    struct.new 4
    struct.new 6
    global.get 0
    ref.cast (ref 8)
    struct.new 9
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    struct.new 5
    struct.new 6
    global.get 1
    ref.cast (ref 8)
    struct.new 9
    call 6
    call 2
    i32.const 0
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    struct.new 4
    struct.new 6
    global.get 0
    ref.cast (ref 8)
    struct.new 9
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    struct.new 5
    struct.new 6
    global.get 1
    ref.cast (ref 8)
    struct.new 9
    call 6
    call 2
    i32.const 1
    v128.const i32x4 0x6172747c 0x673a7469 0x72656e65 0x642d6369
    v128.const i32x4 0x69746369 0x72616e6f 0x00000079 0x00000000
    array.new_fixed 18 2
    i32.const 0
    i32.const 25
    struct.new 20
    call 3
  )
  (func (;8;) (type 7) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 6)
    call 10
  )
  (func (;9;) (type 7) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 6)
    call 11
  )
  (func (;10;) (type 15) (param (ref 6)) (result i32)
    local.get 0
    ref.cast (ref 6)
    struct.get 6 5
    ref.cast (ref 4)
    call 4
  )
  (func (;11;) (type 16) (param (ref 6)) (result i32)
    local.get 0
    ref.cast (ref 6)
    struct.get 6 5
    ref.cast (ref 5)
    call 5
  )
  (func (;12;) (type 17)
    ref.func 8
    struct.new 8
    global.set 0
    ref.func 9
    struct.new 8
    global.set 1
  )
)
