(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (sub (struct (field i32))))
  (type (;4;) (sub final 3 (struct (field i32) (field i32))))
  (type (;5;) (sub final 3 (struct (field i32) (field eqref))))
  (type (;6;) (sub final 3 (struct (field i32) (field i32))))
  (type (;7;) (sub final 3 (struct (field i32) (field eqref))))
  (type (;8;) (func (param eqref)))
  (type (;9;) (func (param i32 eqref)))
  (type (;10;) (func (param i32 eqref)))
  (type (;11;) (func (param eqref eqref eqref)))
  (type (;12;) (func (param eqref eqref eqref)))
  (type (;13;) (func (param eqref eqref eqref)))
  (type (;14;) (func (param eqref eqref eqref)))
  (type (;15;) (func (param eqref eqref eqref)))
  (type (;16;) (func (param eqref eqref eqref)))
  (type (;17;) (func (param (ref 0) eqref)))
  (type (;18;) (func (param (ref 0) eqref)))
  (type (;19;) (func (param (ref 3) eqref)))
  (type (;20;) (func (param (ref 3) eqref)))
  (type (;21;) (func (param i32 i32 eqref)))
  (type (;22;) (func (param i32 i32 eqref)))
  (type (;23;) (func (param i32 i32 eqref)))
  (type (;24;) (func (param i32 i32 eqref)))
  (type (;25;) (func (param i32 i32 eqref)))
  (type (;26;) (func (param i32 i32 eqref)))
  (type (;27;) (func (param (ref 0) eqref)))
  (type (;28;) (func (param (ref 0) eqref)))
  (type (;29;) (func (param (ref 3) eqref)))
  (type (;30;) (func (param (ref 3) eqref)))
  (type (;31;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;32;) (func (param i32 eqref) (result i32)))
  (type (;33;) (func (result (ref 0))))
  (type (;34;) (func (param i32) (result (ref 3))))
  (type (;35;) (func (param i32) (result (ref 3))))
  (type (;36;) (func (result i32)))
  (type (;37;) (array (mut v128)))
  (type (;38;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;39;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;40;) (struct (field (ref 37)) (field i32) (field i32)))
  (type (;41;) (struct (field (mut (ref 37))) (field (mut i32)) (field (mut i32))))
  (type (;42;) (struct (field (mut (ref 37))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 31)))
  (memory (;0;) 1)
  (export "main" (func 18))
  (export "memory" (memory 0))
  (func (;1;) (type 8) (param eqref)
    i32.const 0
    local.get 0
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    unreachable
  )
  (func (;2;) (type 9) (param i32 eqref)
    local.get 0
    local.get 1
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;3;) (type 10) (param i32 eqref)
    local.get 0
    i32.eqz
    local.get 1
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;4;) (type 21) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.eq
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;5;) (type 22) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.eq
    i32.eqz
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;6;) (type 23) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.lt_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;7;) (type 24) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.le_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;8;) (type 25) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.gt_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;9;) (type 26) (param i32 i32 eqref)
    local.get 0
    local.get 1
    i32.ge_s
    local.get 2
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;10;) (type 27) (param (ref 0) eqref)
    (local eqref)
    local.get 0
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
          local.get 1
          call 1
          unreachable
          br 2 (;@1;)
        end
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;11;) (type 28) (param (ref 0) eqref)
    (local eqref)
    local.get 0
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
          br 2 (;@1;)
        end
        local.get 1
        call 1
        unreachable
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;12;) (type 29) (param (ref 3) eqref)
    (local eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        local.get 1
        call 1
        unreachable
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;13;) (type 30) (param (ref 3) eqref)
    (local eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          call 1
          unreachable
          br 2 (;@1;)
        end
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;14;) (type 32) (param i32 eqref) (result i32)
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
  (func (;15;) (type 33) (result (ref 0))
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;16;) (type 34) (param i32) (result (ref 3))
    i32.const 0
    local.get 0
    struct.new 4
    ref.cast (ref 3)
  )
  (func (;17;) (type 35) (param i32) (result (ref 3))
    i32.const 1
    local.get 0
    struct.new 6
    ref.cast (ref 3)
  )
  (func (;18;) (type 36) (result i32)
    (local eqref eqref)
    i32.const 1
    v128.const i32x4 0x65757274 0x6c656820 0x00726570 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 11
    struct.new 38
    call 2
    i32.const 0
    v128.const i32x4 0x736c6166 0x65682065 0x7265706c 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 12
    struct.new 38
    call 3
    i32.const 42
    i32.const 42
    v128.const i32x4 0x61757165 0x6568206c 0x7265706c 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 12
    struct.new 38
    call 4
    i32.const 41
    i32.const 42
    v128.const i32x4 0x20746f6e 0x61757165 0x6568206c 0x7265706c
    array.new_fixed 37 1
    i32.const 0
    i32.const 16
    struct.new 38
    call 5
    i32.const 1
    i32.const 2
    v128.const i32x4 0x7373656c 0x6c656820 0x00726570 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 11
    struct.new 38
    call 6
    i32.const 2
    i32.const 2
    v128.const i32x4 0x2065746c 0x706c6568 0x00007265 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 10
    struct.new 38
    call 7
    i32.const 3
    i32.const 2
    v128.const i32x4 0x61657267 0x20726574 0x706c6568 0x00007265
    array.new_fixed 37 1
    i32.const 0
    i32.const 14
    struct.new 38
    call 8
    i32.const 3
    i32.const 3
    v128.const i32x4 0x20657467 0x706c6568 0x00007265 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 10
    struct.new 38
    call 9
    i32.const 1
    i32.const 7
    struct.new 1
    v128.const i32x4 0x656d6f73 0x6c656820 0x00726570 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 11
    struct.new 38
    call 10
    call 15
    local.set 0
    local.get 0
    ref.cast (ref 0)
    v128.const i32x4 0x656e6f6e 0x6c656820 0x00726570 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 11
    struct.new 38
    call 11
    i32.const 7
    call 16
    local.set 0
    i32.const 9
    call 17
    local.set 1
    local.get 0
    ref.cast (ref 3)
    v128.const i32x4 0x68206b6f 0x65706c65 0x00000072 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 9
    struct.new 38
    call 12
    local.get 1
    ref.cast (ref 3)
    v128.const i32x4 0x20727265 0x706c6568 0x00007265 0x00000000
    array.new_fixed 37 1
    i32.const 0
    i32.const 10
    struct.new 38
    call 13
    i32.const 1
    v128.const i32x4 0x74736574 0x3a676e69 0x746e7572 0x00656d69
    array.new_fixed 37 1
    i32.const 0
    i32.const 15
    struct.new 39
    call 14
  )
)
