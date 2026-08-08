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
  (type (;9;) (func (param f32) (result i32)))
  (type (;10;) (func (param f64) (result i32)))
  (type (;11;) (func (param eqref) (result eqref)))
  (type (;12;) (func (param eqref) (result i32)))
  (type (;13;) (func (result i32)))
  (type (;14;) (func (param i32) (result i32)))
  (type (;15;) (func (param i32) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param i32) (result i32)))
  (type (;18;) (func (param i64) (result i32)))
  (type (;19;) (func (param i32) (result i32)))
  (type (;20;) (func (param i32) (result i32)))
  (type (;21;) (func (param i32) (result i32)))
  (type (;22;) (func (param i64) (result i32)))
  (type (;23;) (func (param f32) (result i32)))
  (type (;24;) (func (param f64) (result i32)))
  (type (;25;) (func (param eqref) (result i32)))
  (type (;26;) (func (param eqref) (result i32)))
  (type (;27;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;28;) (func (param i32 eqref) (result i32)))
  (type (;29;) (struct (field i32) (field i32)))
  (type (;30;) (sub (struct (field i32))))
  (type (;31;) (sub final 30 (struct (field i32) (field i32))))
  (type (;32;) (sub final 30 (struct (field i32) (field i32) (field i32))))
  (type (;33;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;34;) (struct (field (ref 29)) (field (ref 30))))
  (type (;35;) (struct (field eqref) (field eqref)))
  (type (;36;) (func (param (ref 29)) (result i32)))
  (type (;37;) (func (param (ref 30)) (result i32)))
  (type (;38;) (func (param (ref 33)) (result i32)))
  (type (;39;) (func (param (ref 34)) (result i32)))
  (type (;40;) (func (param (ref 35)) (result i32)))
  (type (;41;) (func))
  (type (;42;) (func (result i32)))
  (type (;43;) (func (param (ref 33)) (result i32)))
  (type (;44;) (array (mut v128)))
  (type (;45;) (struct (field (ref 44)) (field i32) (field i32)))
  (type (;46;) (struct (field (ref 44)) (field i32) (field i32)))
  (type (;47;) (struct (field (ref 44)) (field i32) (field i32)))
  (type (;48;) (struct (field (mut (ref 44))) (field (mut i32)) (field (mut i32))))
  (type (;49;) (struct (field (mut (ref 44))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 27)))
  (memory (;0;) 1)
  (export "main" (func 34))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param i32 eqref) (result i32)
    (local (ref 46) (ref 44) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 46)
    local.set 2
    local.get 2
    struct.get 46 0
    local.set 3
    local.get 2
    struct.get 46 1
    local.set 4
    local.get 2
    struct.get 46 2
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
              array.get 44
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
              array.get 44
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
              array.get 44
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
              array.get 44
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
                array.get 44
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 44
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
                array.get 44
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
            array.get 44
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
  (func (;10;) (type 9) (param f32) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i32)
    i32.const 16
    i32.const 102
    i32.store8
    i32.const 17
    i32.const 51
    i32.store8
    i32.const 18
    i32.const 50
    i32.store8
    i32.const 19
    i32.const 40
    i32.store8
    i32.const 20
    i32.const 48
    i32.store8
    i32.const 21
    i32.const 120
    i32.store8
    i32.const 16
    local.set 8
    local.get 0
    i32.reinterpret_f32
    local.set 1
    i32.const 30
    local.set 2
    i32.const 8
    local.set 3
    loop ;; label = @1
      local.get 2
      i32.const 1
      i32.sub
      local.tee 2
      local.get 1
      i32.const 15
      i32.and
      local.tee 4
      i32.const 10
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 4
        i32.const 48
        i32.add
      else
        local.get 4
        i32.const 87
        i32.add
      end
      i32.store8
      local.get 1
      i32.const 4
      i32.shr_u
      local.set 1
      local.get 3
      i32.const 1
      i32.sub
      local.tee 3
      br_if 0 (;@1;)
    end
    i32.const 30
    i32.const 41
    i32.store8
    i32.const 15
    local.set 5
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        local.get 5
        i32.ge_u
        br_if 1 (;@1;)
        i32.const 0
        local.get 8
        local.get 6
        i32.add
        i32.store
        i32.const 4
        local.get 5
        local.get 6
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
        local.tee 7
        i32.eqz
        local.get 7
        local.get 5
        local.get 6
        i32.sub
        i32.gt_u
        i32.or
        if ;; label = @3
          unreachable
        end
        local.get 6
        local.get 7
        i32.add
        local.set 6
        br 0 (;@2;)
      end
    end
    local.get 5
  )
  (func (;11;) (type 10) (param f64) (result i32)
    (local i64 i32 i32 i32 i32 i32 i32 i32)
    i32.const 16
    i32.const 102
    i32.store8
    i32.const 17
    i32.const 54
    i32.store8
    i32.const 18
    i32.const 52
    i32.store8
    i32.const 19
    i32.const 40
    i32.store8
    i32.const 20
    i32.const 48
    i32.store8
    i32.const 21
    i32.const 120
    i32.store8
    i32.const 16
    local.set 8
    local.get 0
    i64.reinterpret_f64
    local.set 1
    i32.const 38
    local.set 2
    i32.const 16
    local.set 3
    loop ;; label = @1
      local.get 2
      i32.const 1
      i32.sub
      local.tee 2
      local.get 1
      i64.const 15
      i64.and
      i32.wrap_i64
      local.tee 4
      i32.const 10
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 4
        i32.const 48
        i32.add
      else
        local.get 4
        i32.const 87
        i32.add
      end
      i32.store8
      local.get 1
      i64.const 4
      i64.shr_u
      local.set 1
      local.get 3
      i32.const 1
      i32.sub
      local.tee 3
      br_if 0 (;@1;)
    end
    i32.const 38
    i32.const 41
    i32.store8
    i32.const 23
    local.set 5
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        local.get 5
        i32.ge_u
        br_if 1 (;@1;)
        i32.const 0
        local.get 8
        local.get 6
        i32.add
        i32.store
        i32.const 4
        local.get 5
        local.get 6
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
        local.tee 7
        i32.eqz
        local.get 7
        local.get 5
        local.get 6
        i32.sub
        i32.gt_u
        i32.or
        if ;; label = @3
          unreachable
        end
        local.get 6
        local.get 7
        i32.add
        local.set 6
        br 0 (;@2;)
      end
    end
    local.get 5
  )
  (func (;12;) (type 11) (param eqref) (result eqref)
    (local (ref 45))
    local.get 0
    ref.cast (ref 45)
    local.tee 1
    struct.get 45 0
    local.get 1
    struct.get 45 1
    local.get 1
    struct.get 45 2
    struct.new 46
  )
  (func (;13;) (type 12) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 46)
    struct.get 46 2
  )
  (func (;14;) (type 13) (result i32)
    i32.const 1
    v128.const i32x4 0x00002928 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 2
    struct.new 46
    call 1
  )
  (func (;15;) (type 14) (param i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
      array.new_fixed 44 1
      i32.const 0
      i32.const 4
      struct.new 46
      call 1
    else
      i32.const 1
      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
      array.new_fixed 44 1
      i32.const 0
      i32.const 5
      struct.new 46
      call 1
    end
  )
  (func (;16;) (type 15) (param i32) (result i32)
    local.get 0
    call 2
  )
  (func (;17;) (type 16) (param i32) (result i32)
    local.get 0
    call 3
  )
  (func (;18;) (type 17) (param i32) (result i32)
    local.get 0
    call 4
  )
  (func (;19;) (type 18) (param i64) (result i32)
    local.get 0
    call 5
  )
  (func (;20;) (type 19) (param i32) (result i32)
    local.get 0
    call 6
  )
  (func (;21;) (type 20) (param i32) (result i32)
    local.get 0
    call 7
  )
  (func (;22;) (type 21) (param i32) (result i32)
    local.get 0
    call 8
  )
  (func (;23;) (type 22) (param i64) (result i32)
    local.get 0
    call 9
  )
  (func (;24;) (type 23) (param f32) (result i32)
    local.get 0
    call 10
  )
  (func (;25;) (type 24) (param f64) (result i32)
    local.get 0
    call 11
  )
  (func (;26;) (type 25) (param eqref) (result i32)
    i32.const 1
    v128.const i32x4 0x00000022 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 1
    drop
    i32.const 1
    local.get 0
    call 12
    call 1
    drop
    i32.const 1
    v128.const i32x4 0x00000022 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 1
  )
  (func (;27;) (type 26) (param eqref) (result i32)
    i32.const 1
    v128.const i32x4 0x65747942 0x656c2873 0x00003d6e 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 10
    struct.new 46
    call 1
    drop
    local.get 0
    call 13
    call 22
    drop
    i32.const 1
    v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 1
  )
  (func (;28;) (type 28) (param i32 eqref) (result i32)
    (local (ref 46) (ref 44) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 46)
    local.set 2
    local.get 2
    struct.get 46 0
    local.set 3
    local.get 2
    struct.get 46 1
    local.set 4
    local.get 2
    struct.get 46 2
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
              array.get 44
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
              array.get 44
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
              array.get 44
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
              array.get 44
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
                array.get 44
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 44
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
                array.get 44
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
            array.get 44
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
  (func (;29;) (type 36) (param (ref 29)) (result i32)
    i32.const 1
    v128.const i32x4 0x6e696f50 0x207b2074 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 8
    struct.new 46
    call 1
    drop
    i32.const 1
    v128.const i32x4 0x00203a78 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 3
    struct.new 46
    call 1
    drop
    local.get 0
    struct.get 29 0
    call 18
    drop
    i32.const 1
    v128.const i32x4 0x3a79202c 0x00000020 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 5
    struct.new 46
    call 1
    drop
    local.get 0
    struct.get 29 1
    call 18
    drop
    i32.const 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 2
    struct.new 46
    call 1
  )
  (func (;30;) (type 37) (param (ref 30)) (result i32)
    (local i32 i32 i32 eqref i32)
    local.get 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 4
              ref.cast (ref 30)
              struct.get 30 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 1
            v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
            array.new_fixed 44 1
            i32.const 0
            i32.const 12
            struct.new 46
            call 1
            local.set 5
            br 3 (;@1;)
          end
          local.get 4
          ref.cast (ref 31)
          struct.get 31 1
          local.set 1
          i32.const 1
          v128.const i32x4 0x696f6843 0x3a3a6563 0x626d754e 0x00287265
          array.new_fixed 44 1
          i32.const 0
          i32.const 15
          struct.new 46
          call 1
          drop
          local.get 1
          call 18
          drop
          i32.const 1
          v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
          array.new_fixed 44 1
          i32.const 0
          i32.const 1
          struct.new 46
          call 1
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 32)
        struct.get 32 1
        local.set 2
        local.get 4
        ref.cast (ref 32)
        struct.get 32 2
        local.set 3
        i32.const 1
        v128.const i32x4 0x696f6843 0x3a3a6563 0x656d614e 0x207b2064
        array.new_fixed 44 1
        i32.const 0
        i32.const 16
        struct.new 46
        call 1
        drop
        i32.const 1
        v128.const i32x4 0x6562616c 0x00203a6c 0x00000000 0x00000000
        array.new_fixed 44 1
        i32.const 0
        i32.const 7
        struct.new 46
        call 1
        drop
        local.get 2
        call 18
        drop
        i32.const 1
        v128.const i32x4 0x6361202c 0x65766974 0x0000203a 0x00000000
        array.new_fixed 44 1
        i32.const 0
        i32.const 10
        struct.new 46
        call 1
        drop
        local.get 3
        call 15
        drop
        i32.const 1
        v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
        array.new_fixed 44 1
        i32.const 0
        i32.const 2
        struct.new 46
        call 1
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
  (func (;31;) (type 39) (param (ref 34)) (result i32)
    i32.const 1
    v128.const i32x4 0x6e656353 0x207b2065 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 8
    struct.new 46
    call 1
    drop
    i32.const 1
    v128.const i32x4 0x6e696f70 0x00203a74 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 7
    struct.new 46
    call 1
    drop
    local.get 0
    struct.get 34 0
    call 29
    drop
    i32.const 1
    v128.const i32x4 0x6863202c 0x6563696f 0x0000203a 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 10
    struct.new 46
    call 1
    drop
    local.get 0
    struct.get 34 1
    call 30
    drop
    i32.const 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 2
    struct.new 46
    call 1
  )
  (func (;32;) (type 40) (param (ref 35)) (result i32)
    i32.const 1
    v128.const i32x4 0x7373654d 0x20656761 0x0000207b 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 10
    struct.new 46
    call 1
    drop
    i32.const 1
    v128.const i32x4 0x74786574 0x0000203a 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 6
    struct.new 46
    call 1
    drop
    local.get 0
    struct.get 35 0
    call 26
    drop
    i32.const 1
    v128.const i32x4 0x6164202c 0x203a6174 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 8
    struct.new 46
    call 1
    drop
    local.get 0
    struct.get 35 1
    call 27
    drop
    i32.const 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 2
    struct.new 46
    call 1
  )
  (func (;33;) (type 41))
  (func (;34;) (type 42) (result i32)
    (local (ref 29) (ref 30) (ref 33))
    i32.const 3
    i32.const 4
    struct.new 29
    local.set 0
    i32.const 2
    i32.const 9
    i32.const 1
    struct.new 32
    local.set 1
    i32.const 42
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 33
    local.set 2
    local.get 0
    call 29
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 1
    i32.const 7
    struct.new 31
    call 30
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    local.get 1
    call 30
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    local.get 2
    call 35
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 0
    i32.const 5
    i32.sub
    i32.const 6
    struct.new 29
    i32.const 1
    i32.const 8
    struct.new 31
    struct.new 34
    call 31
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 0
    call 18
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    call 16
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    call 17
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 0
    i32.const -2147483648
    i32.sub
    call 18
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i64.const 0
    i64.const -9223372036854775808
    i64.sub
    call 19
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 255
    call 20
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const 65535
    call 21
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i32.const -1
    call 22
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    i64.const -1
    call 23
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    f32.const 0x1.8p+0 (;=1.5;)
    call 24
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    f32.const 0x0p+0 (;=0;)
    f32.neg
    call 24
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    f64.const 0x1.8p+0 (;=1.5;)
    call 25
    drop
    i32.const 1
    v128.const i32x4 0x0000002c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    f64.const 0x0p+0 (;=0;)
    f64.neg
    call 25
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    call 33
    call 14
    drop
    i32.const 1
    v128.const i32x4 0x0000007c 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 1
    struct.new 46
    call 28
    drop
    v128.const i32x4 0x6c6c6568 0xbbce206f 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 8
    struct.new 45
    v128.const i32x4 0x00ff4100 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 1
    i32.const 0
    i32.const 3
    struct.new 46
    struct.new 35
    call 32
  )
  (func (;35;) (type 43) (param (ref 33)) (result i32)
    i32.const 1
    v128.const i32x4 0x70617257 0x20726570 0x6176207b 0x2065756c
    v128.const i32x4 0x0000007d 0x00000000 0x00000000 0x00000000
    array.new_fixed 44 2
    i32.const 0
    i32.const 17
    struct.new 46
    call 1
  )
)
