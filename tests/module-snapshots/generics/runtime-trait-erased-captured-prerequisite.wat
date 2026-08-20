(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32)))
  (type (;2;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;3;) (func (param i32 eqref) (result i32)))
  (type (;4;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;5;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;6;) (func (param eqref) (result i32)))
  (type (;7;) (struct (field (ref null 6))))
  (type (;8;) (struct (field eqref) (field (ref 7))))
  (type (;9;) (func (param eqref) (result i32)))
  (type (;10;) (struct (field (ref null 9))))
  (type (;11;) (struct (field eqref) (field (ref 10))))
  (type (;12;) (func (param eqref) (result i32)))
  (type (;13;) (struct (field (ref null 12))))
  (type (;14;) (struct (field eqref) (field (ref 13))))
  (type (;15;) (func (param eqref) (result i32)))
  (type (;16;) (struct (field (ref null 15))))
  (type (;17;) (struct (field eqref) (field (ref 16))))
  (type (;18;) (func (param i32) (result i32)))
  (type (;19;) (func (param i32) (result i32)))
  (type (;20;) (func (param (ref 4)) (result i32)))
  (type (;21;) (func (param (ref 5)) (result i32)))
  (type (;22;) (func (param eqref) (result eqref)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (result i32)))
  (type (;25;) (func (param eqref eqref eqref) (result eqref)))
  (type (;26;) (func (param i32) (result eqref)))
  (type (;27;) (func (param (ref 5) eqref eqref) (result i32)))
  (type (;28;) (func (param (ref 5)) (result i32)))
  (type (;29;) (func (param (ref 4) eqref eqref) (result i32)))
  (type (;30;) (func (param (ref 4)) (result i32)))
  (type (;31;) (struct (field i32)))
  (type (;32;) (func))
  (type (;33;) (array (mut v128)))
  (type (;34;) (struct (field (ref 33)) (field i32) (field i32)))
  (type (;35;) (struct (field (ref 33)) (field i32) (field i32)))
  (type (;36;) (struct (field (ref 33)) (field i32) (field i32)))
  (type (;37;) (struct (field (mut (ref 33))) (field (mut i32)) (field (mut i32))))
  (type (;38;) (struct (field (mut (ref 33))) (field (mut i32)) (field (mut i32))))
  (type (;39;) (struct (field eqref) (field eqref) (field eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 2)))
  (memory (;0;) 1)
  (global (;0;) (mut (ref null 7)) ref.null 7)
  (global (;1;) (mut (ref null 7)) ref.null 7)
  (export "main" (func 7))
  (export "erase_nested" (func 8))
  (export "__dew_init" (func 16))
  (export "memory" (memory 0))
  (elem (;0;) declare func 11 13)
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
    (local (ref 35) (ref 33) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 35)
    local.set 2
    local.get 2
    struct.get 35 0
    local.set 3
    local.get 2
    struct.get 35 1
    local.set 4
    local.get 2
    struct.get 35 2
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
              array.get 33
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
              array.get 33
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
              array.get 33
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
              array.get 33
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
                array.get 33
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 33
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
                array.get 33
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
            array.get 33
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
  (func (;4;) (type 18) (param i32) (result i32)
    local.get 0
  )
  (func (;5;) (type 19) (param i32) (result i32)
    local.get 0
  )
  (func (;6;) (type 23) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.tee 1
    ref.cast (ref 8)
    struct.get 8 0
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    struct.get 7 0
    call_ref 6
  )
  (func (;7;) (type 24) (result i32)
    i32.const 42
    call 9
    call 6
    call 2
    i32.const 1
    v128.const i32x4 0x6172747c 0x633a7469 0x75747061 0x2d646572
    v128.const i32x4 0x72657270 0x69757165 0x65746973 0x00000000
    array.new_fixed 33 2
    i32.const 0
    i32.const 28
    struct.new 35
    call 3
  )
  (func (;8;) (type 25) (param eqref eqref eqref) (result eqref)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.new 4
    struct.new 5
    local.get 1
    local.get 2
    struct.new 39
    global.get 0
    ref.cast (ref 7)
    struct.new 8
  )
  (func (;9;) (type 26) (param i32) (result eqref)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 4
    struct.new 5
    global.get 1
    ref.cast (ref 7)
    struct.new 8
  )
  (func (;10;) (type 27) (param (ref 5) eqref eqref) (result i32)
    local.get 0
    ref.cast (ref 5)
    struct.get 5 5
    ref.cast (ref 4)
    local.get 1
    local.get 2
    call 14
  )
  (func (;11;) (type 6) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 39)
    struct.get 39 0
    ref.cast (ref 5)
    local.get 0
    ref.cast (ref 39)
    struct.get 39 1
    local.get 0
    ref.cast (ref 39)
    struct.get 39 2
    call 10
  )
  (func (;12;) (type 28) (param (ref 5)) (result i32)
    local.get 0
    ref.cast (ref 5)
    struct.get 5 5
    ref.cast (ref 4)
    call 15
  )
  (func (;13;) (type 6) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 5)
    call 12
  )
  (func (;14;) (type 29) (param (ref 4) eqref eqref) (result i32)
    local.get 0
    ref.cast (ref 4)
    struct.get 4 5
    local.get 1
    ref.cast (ref 13)
    struct.get 13 0
    call_ref 12
    local.get 0
    ref.cast (ref 4)
    struct.get 4 5
    local.get 2
    ref.cast (ref 16)
    struct.get 16 0
    call_ref 15
    i32.add
  )
  (func (;15;) (type 30) (param (ref 4)) (result i32)
    local.get 0
    ref.cast (ref 4)
    struct.get 4 0
    call 4
    local.get 0
    ref.cast (ref 4)
    struct.get 4 0
    call 5
    i32.add
  )
  (func (;16;) (type 32)
    ref.func 11
    struct.new 7
    global.set 0
    ref.func 13
    struct.new 7
    global.set 1
  )
)
