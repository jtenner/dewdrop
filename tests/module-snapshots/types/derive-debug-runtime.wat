(module
  (type (;0;) (func (param i32 eqref) (result i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param i32) (result i32)))
  (type (;4;) (func (param i64) (result i32)))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param i32) (result i32)))
  (type (;7;) (func (param i32) (result i32)))
  (type (;8;) (func (param i64) (result i32)))
  (type (;9;) (func (param i32) (result i32)))
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (param i32) (result i32)))
  (type (;13;) (func (param i64) (result i32)))
  (type (;14;) (func (param i32) (result i32)))
  (type (;15;) (func (param i32) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param i64) (result i32)))
  (type (;18;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;19;) (func (param i32 eqref) (result i32)))
  (type (;20;) (struct (field i32) (field i32)))
  (type (;21;) (sub (struct (field i32))))
  (type (;22;) (sub final 21 (struct (field i32) (field i32))))
  (type (;23;) (sub final 21 (struct (field i32) (field i32) (field i32))))
  (type (;24;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;25;) (struct (field (ref 20)) (field (ref 21))))
  (type (;26;) (func (param (ref 20)) (result i32)))
  (type (;27;) (func (param (ref 21)) (result i32)))
  (type (;28;) (func (param (ref 24)) (result i32)))
  (type (;29;) (func (param (ref 25)) (result i32)))
  (type (;30;) (func (result i32)))
  (type (;31;) (func (param (ref 24)) (result i32)))
  (type (;32;) (array (mut v128)))
  (type (;33;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;34;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;35;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;36;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (type (;37;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 18)))
  (memory (;0;) 1)
  (export "main" (func 23))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param i32 eqref) (result i32)
    (local (ref 34) (ref 32) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 34)
    local.set 2
    local.get 2
    struct.get 34 0
    local.set 3
    local.get 2
    struct.get 34 1
    local.set 4
    local.get 2
    struct.get 34 2
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
              array.get 32
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
              array.get 32
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
              array.get 32
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
              array.get 32
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
                array.get 32
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 32
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
                array.get 32
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
            array.get 32
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
  (func (;2;) (type 1) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.extend8_s
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
  (func (;3;) (type 2) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.extend16_s
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
  (func (;4;) (type 3) (param i32) (result i32)
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
  (func (;5;) (type 4) (param i64) (result i32)
    (local i32 i64 i32 i32 i32 i32)
    i32.const 48
    local.set 1
    local.get 0
    i64.const 0
    i64.lt_s
    local.tee 3
    if (result i64) ;; label = @1
      i64.const 0
      local.get 0
      i64.sub
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
      i64.const 10
      i64.rem_u
      i32.wrap_i64
      i32.const 48
      i32.add
      i32.store8
      local.get 2
      i64.const 10
      i64.div_u
      local.tee 2
      i64.const 0
      i64.ne
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
  (func (;6;) (type 5) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.const 255
    i32.and
    local.set 0
    i32.const 48
    local.set 1
    local.get 0
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
  (func (;7;) (type 6) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.const 65535
    i32.and
    local.set 0
    i32.const 48
    local.set 1
    local.get 0
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
  (func (;8;) (type 7) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    i32.const 48
    local.set 1
    local.get 0
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
  (func (;9;) (type 8) (param i64) (result i32)
    (local i32 i64 i32 i32 i32 i32)
    i32.const 48
    local.set 1
    local.get 0
    local.set 2
    loop ;; label = @1
      local.get 1
      i32.const 1
      i32.sub
      local.tee 1
      local.get 2
      i64.const 10
      i64.rem_u
      i32.wrap_i64
      i32.const 48
      i32.add
      i32.store8
      local.get 2
      i64.const 10
      i64.div_u
      local.tee 2
      i64.const 0
      i64.ne
      br_if 0 (;@1;)
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
  (func (;10;) (type 9) (param i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
      array.new_fixed 32 1
      i32.const 0
      i32.const 4
      struct.new 34
      call 1
    else
      i32.const 1
      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
      array.new_fixed 32 1
      i32.const 0
      i32.const 5
      struct.new 34
      call 1
    end
  )
  (func (;11;) (type 10) (param i32) (result i32)
    local.get 0
    call 2
  )
  (func (;12;) (type 11) (param i32) (result i32)
    local.get 0
    call 3
  )
  (func (;13;) (type 12) (param i32) (result i32)
    local.get 0
    call 4
  )
  (func (;14;) (type 13) (param i64) (result i32)
    local.get 0
    call 5
  )
  (func (;15;) (type 14) (param i32) (result i32)
    local.get 0
    call 6
  )
  (func (;16;) (type 15) (param i32) (result i32)
    local.get 0
    call 7
  )
  (func (;17;) (type 16) (param i32) (result i32)
    local.get 0
    call 8
  )
  (func (;18;) (type 17) (param i64) (result i32)
    local.get 0
    call 9
  )
  (func (;19;) (type 19) (param i32 eqref) (result i32)
    (local (ref 34) (ref 32) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 34)
    local.set 2
    local.get 2
    struct.get 34 0
    local.set 3
    local.get 2
    struct.get 34 1
    local.set 4
    local.get 2
    struct.get 34 2
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
              array.get 32
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
              array.get 32
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
              array.get 32
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
              array.get 32
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
                array.get 32
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 32
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
                array.get 32
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
            array.get 32
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
  (func (;20;) (type 26) (param (ref 20)) (result i32)
    i32.const 1
    v128.const i32x4 0x6e696f50 0x207b2074 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 8
    struct.new 34
    call 1
    drop
    i32.const 1
    v128.const i32x4 0x00203a78 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 3
    struct.new 34
    call 1
    drop
    local.get 0
    struct.get 20 0
    call 13
    drop
    i32.const 1
    v128.const i32x4 0x3a79202c 0x00000020 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 5
    struct.new 34
    call 1
    drop
    local.get 0
    struct.get 20 1
    call 13
    drop
    i32.const 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 2
    struct.new 34
    call 1
  )
  (func (;21;) (type 27) (param (ref 21)) (result i32)
    (local i32 i32 i32 eqref i32)
    local.get 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 4
              ref.cast (ref 21)
              struct.get 21 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 1
            v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
            array.new_fixed 32 1
            i32.const 0
            i32.const 12
            struct.new 34
            call 1
            local.set 5
            br 3 (;@1;)
          end
          local.get 4
          ref.cast (ref 22)
          struct.get 22 1
          local.set 1
          i32.const 1
          v128.const i32x4 0x696f6843 0x3a3a6563 0x626d754e 0x00287265
          array.new_fixed 32 1
          i32.const 0
          i32.const 15
          struct.new 34
          call 1
          drop
          local.get 1
          call 13
          drop
          i32.const 1
          v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
          array.new_fixed 32 1
          i32.const 0
          i32.const 1
          struct.new 34
          call 1
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 23)
        struct.get 23 1
        local.set 2
        local.get 4
        ref.cast (ref 23)
        struct.get 23 2
        local.set 3
        i32.const 1
        v128.const i32x4 0x696f6843 0x3a3a6563 0x656d614e 0x207b2064
        array.new_fixed 32 1
        i32.const 0
        i32.const 16
        struct.new 34
        call 1
        drop
        i32.const 1
        v128.const i32x4 0x6562616c 0x00203a6c 0x00000000 0x00000000
        array.new_fixed 32 1
        i32.const 0
        i32.const 7
        struct.new 34
        call 1
        drop
        local.get 2
        call 13
        drop
        i32.const 1
        v128.const i32x4 0x6361202c 0x65766974 0x0000203a 0x00000000
        array.new_fixed 32 1
        i32.const 0
        i32.const 10
        struct.new 34
        call 1
        drop
        local.get 3
        call 10
        drop
        i32.const 1
        v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
        array.new_fixed 32 1
        i32.const 0
        i32.const 2
        struct.new 34
        call 1
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
  (func (;22;) (type 29) (param (ref 25)) (result i32)
    i32.const 1
    v128.const i32x4 0x6e656353 0x207b2065 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 8
    struct.new 34
    call 1
    drop
    i32.const 1
    v128.const i32x4 0x6e696f70 0x00203a74 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 7
    struct.new 34
    call 1
    drop
    local.get 0
    struct.get 25 0
    call 20
    drop
    i32.const 1
    v128.const i32x4 0x6863202c 0x6563696f 0x0000203a 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 34
    call 1
    drop
    local.get 0
    struct.get 25 1
    call 21
    drop
    i32.const 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 2
    struct.new 34
    call 1
  )
  (func (;23;) (type 30) (result i32)
    (local (ref 20) (ref 21) (ref 24))
    i32.const 3
    i32.const 4
    struct.new 20
    local.set 0
    i32.const 2
    i32.const 9
    i32.const 1
    struct.new 23
    local.set 1
    i32.const 42
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 24
    local.set 2
    local.get 0
    call 20
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 1
    i32.const 7
    struct.new 22
    call 21
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    local.get 1
    call 21
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    local.get 2
    call 24
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 0
    i32.const 5
    i32.sub
    i32.const 6
    struct.new 20
    i32.const 1
    i32.const 8
    struct.new 22
    struct.new 25
    call 22
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 0
    call 13
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    call 11
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    call 12
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 0
    i32.const -2147483648
    i32.sub
    call 13
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i64.const 0
    i64.const -9223372036854775808
    i64.sub
    call 14
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 255
    call 15
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const 65535
    call 16
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i32.const -1
    call 17
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 1
    struct.new 34
    call 19
    drop
    i64.const -1
    call 18
  )
  (func (;24;) (type 31) (param (ref 24)) (result i32)
    i32.const 1
    v128.const i32x4 0x70617257 0x20726570 0x6176207b 0x2065756c
    v128.const i32x4 0x0000007d 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 17
    struct.new 34
    call 1
  )
)
