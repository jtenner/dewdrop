(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32)))
  (type (;2;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;3;) (func (param i32 eqref) (result i32)))
  (type (;4;) (func (param eqref) (result i32)))
  (type (;5;) (struct (field (ref null 4))))
  (type (;6;) (struct (field eqref) (field (ref 5))))
  (type (;7;) (func (param i32) (result i32)))
  (type (;8;) (func (param i32) (result i32)))
  (type (;9;) (func (param i64) (result i32)))
  (type (;10;) (func (param f32) (result i32)))
  (type (;11;) (func (param f64) (result i32)))
  (type (;12;) (func (param v128) (result i32)))
  (type (;13;) (func (param i32 eqref) (result eqref)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (result i32)))
  (type (;16;) (func (param i32 i32) (result eqref)))
  (type (;17;) (func (param i32 i32) (result eqref)))
  (type (;18;) (func (param i32 i64) (result eqref)))
  (type (;19;) (func (param i32 f32) (result eqref)))
  (type (;20;) (func (param i32 f64) (result eqref)))
  (type (;21;) (func (param i32 v128) (result eqref)))
  (type (;22;) (struct (field i32)))
  (type (;23;) (struct (field i64)))
  (type (;24;) (struct (field f32)))
  (type (;25;) (struct (field f64)))
  (type (;26;) (struct (field v128)))
  (type (;27;) (func))
  (type (;28;) (array (mut v128)))
  (type (;29;) (struct (field (ref 28)) (field i32) (field i32)))
  (type (;30;) (struct (field (ref 28)) (field i32) (field i32)))
  (type (;31;) (struct (field (ref 28)) (field i32) (field i32)))
  (type (;32;) (struct (field (mut (ref 28))) (field (mut i32)) (field (mut i32))))
  (type (;33;) (struct (field (mut (ref 28))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 2)))
  (memory (;0;) 1)
  (global (;0;) (mut (ref null 5)) ref.null 5)
  (global (;1;) (mut (ref null 5)) ref.null 5)
  (global (;2;) (mut (ref null 5)) ref.null 5)
  (global (;3;) (mut (ref null 5)) ref.null 5)
  (global (;4;) (mut (ref null 5)) ref.null 5)
  (global (;5;) (mut (ref null 5)) ref.null 5)
  (export "main" (func 11))
  (export "__dew_init" (func 24))
  (export "memory" (memory 0))
  (elem (;0;) declare func 18 19 20 21 22 23)
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
    (local (ref 30) (ref 28) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 30)
    local.set 2
    local.get 2
    struct.get 30 0
    local.set 3
    local.get 2
    struct.get 30 1
    local.set 4
    local.get 2
    struct.get 30 2
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
              array.get 28
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
              array.get 28
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
              array.get 28
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
              array.get 28
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
                array.get 28
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 28
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
                array.get 28
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
            array.get 28
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
  (func (;4;) (type 7) (param i32) (result i32)
    local.get 0
  )
  (func (;5;) (type 8) (param i32) (result i32)
    i32.const 2
  )
  (func (;6;) (type 9) (param i64) (result i32)
    i32.const 3
  )
  (func (;7;) (type 10) (param f32) (result i32)
    i32.const 4
  )
  (func (;8;) (type 11) (param f64) (result i32)
    i32.const 5
  )
  (func (;9;) (type 12) (param v128) (result i32)
    i32.const 6
  )
  (func (;10;) (type 14) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.tee 1
    ref.cast (ref 6)
    struct.get 6 0
    local.get 1
    ref.cast (ref 6)
    struct.get 6 1
    struct.get 5 0
    call_ref 4
  )
  (func (;11;) (type 15) (result i32)
    i32.const 1
    i32.const 1
    call 12
    call 10
    call 2
    i32.const 1
    i32.const 2
    call 13
    call 10
    call 2
    i32.const 1
    i64.const 3
    call 14
    call 10
    call 2
    i32.const 1
    f32.const 0x1p+2 (;=4;)
    call 15
    call 10
    call 2
    i32.const 1
    f64.const 0x1.4p+2 (;=5;)
    call 16
    call 10
    call 2
    i32.const 1
    i32.const 6
    i32x4.splat
    call 17
    call 10
    call 2
    i32.const 1
    v128.const i32x4 0x6172747c 0x6f3a7469 0x2d6e6570 0x656e6567
    v128.const i32x4 0x2d636972 0x616e7964 0x0063696d 0x00000000
    array.new_fixed 28 2
    i32.const 0
    i32.const 27
    struct.new 30
    call 3
  )
  (func (;12;) (type 16) (param i32 i32) (result eqref)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 22
    global.get 0
    ref.cast (ref 5)
    struct.new 6
  )
  (func (;13;) (type 17) (param i32 i32) (result eqref)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 22
    global.get 1
    ref.cast (ref 5)
    struct.new 6
  )
  (func (;14;) (type 18) (param i32 i64) (result eqref)
    local.get 0
    if (result i64) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 23
    global.get 2
    ref.cast (ref 5)
    struct.new 6
  )
  (func (;15;) (type 19) (param i32 f32) (result eqref)
    local.get 0
    if (result f32) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 24
    global.get 3
    ref.cast (ref 5)
    struct.new 6
  )
  (func (;16;) (type 20) (param i32 f64) (result eqref)
    local.get 0
    if (result f64) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 25
    global.get 4
    ref.cast (ref 5)
    struct.new 6
  )
  (func (;17;) (type 21) (param i32 v128) (result eqref)
    local.get 0
    if (result v128) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 26
    global.get 5
    ref.cast (ref 5)
    struct.new 6
  )
  (func (;18;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 22)
    struct.get 22 0
    call 4
  )
  (func (;19;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 22)
    struct.get 22 0
    call 5
  )
  (func (;20;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 23)
    struct.get 23 0
    call 6
  )
  (func (;21;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 24)
    struct.get 24 0
    call 7
  )
  (func (;22;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 25)
    struct.get 25 0
    call 8
  )
  (func (;23;) (type 4) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 26)
    struct.get 26 0
    call 9
  )
  (func (;24;) (type 27)
    ref.func 18
    struct.new 5
    global.set 0
    ref.func 19
    struct.new 5
    global.set 1
    ref.func 20
    struct.new 5
    global.set 2
    ref.func 21
    struct.new 5
    global.set 3
    ref.func 22
    struct.new 5
    global.set 4
    ref.func 23
    struct.new 5
    global.set 5
  )
)
