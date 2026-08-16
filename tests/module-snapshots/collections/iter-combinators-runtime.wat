(module
  (rec
    (type (;0;) (sub (struct (field i32))))
  )
  (rec
    (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  )
  (rec
    (type (;2;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;3;) (struct (field eqref) (field (mut i32))))
  )
  (rec
    (type (;4;) (sub (struct (field funcref))))
  )
  (rec
    (type (;5;) (sub final 4 (struct (field funcref) (field eqref))))
  )
  (type (;6;) (array (mut i32)))
  (type (;7;) (array (mut i64)))
  (type (;8;) (array (mut f32)))
  (type (;9;) (array (mut f64)))
  (type (;10;) (array (mut v128)))
  (type (;11;) (array (mut eqref)))
  (type (;12;) (array (mut i8)))
  (type (;13;) (array (mut i16)))
  (type (;14;) (func (param i32 i32) (result i32)))
  (type (;15;) (func (param eqref) (result eqref)))
  (type (;16;) (func (param eqref i32) (result eqref)))
  (type (;17;) (func (param eqref) (result (ref 2))))
  (type (;18;) (func (param eqref eqref) (result eqref)))
  (type (;19;) (func (param eqref)))
  (type (;20;) (func (param eqref i32)))
  (type (;21;) (func (param eqref) (result i32)))
  (type (;22;) (func (param eqref i32) (result i32)))
  (type (;23;) (func (param eqref eqref i32) (result eqref)))
  (type (;24;) (func (param eqref eqref) (result (ref 2))))
  (type (;25;) (func (param eqref eqref eqref) (result eqref)))
  (type (;26;) (func (param eqref eqref)))
  (type (;27;) (func (param eqref eqref i32)))
  (type (;28;) (func (param eqref eqref) (result i32)))
  (type (;29;) (func (param eqref eqref i32) (result i32)))
  (type (;30;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;31;) (func (param (ref 3)) (result i32)))
  (type (;32;) (func (param (ref 3)) (result eqref)))
  (type (;33;) (func (param (ref 3)) (result i32)))
  (type (;34;) (func (param (ref 3)) (result i32)))
  (type (;35;) (func))
  (type (;36;) (func (param eqref eqref)))
  (type (;37;) (func (param eqref eqref eqref) (result eqref)))
  (type (;38;) (func (param eqref eqref) (result i32)))
  (type (;39;) (func (param eqref eqref) (result i32)))
  (type (;40;) (func (param eqref eqref) (result (ref 0))))
  (type (;41;) (func (param eqref eqref)))
  (type (;42;) (func (param eqref i32 eqref) (result i32)))
  (type (;43;) (func (param eqref eqref) (result i32)))
  (type (;44;) (func (param eqref eqref) (result i32)))
  (type (;45;) (func (param eqref eqref) (result (ref 0))))
  (type (;46;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;47;) (func (param i32 eqref) (result i32)))
  (type (;48;) (func (param i32 i32) (result i32)))
  (type (;49;) (func (param i32) (result i32)))
  (type (;50;) (func (param i32)))
  (type (;51;) (func (param eqref i32 i32) (result i32)))
  (type (;52;) (func (result (ref 2))))
  (type (;53;) (func))
  (type (;54;) (func))
  (type (;55;) (array (mut v128)))
  (type (;56;) (struct (field (ref 55)) (field i32) (field i32)))
  (type (;57;) (struct (field (ref 55)) (field i32) (field i32)))
  (type (;58;) (struct (field (ref 55)) (field i32) (field i32)))
  (type (;59;) (struct (field (mut (ref 55))) (field (mut i32)) (field (mut i32))))
  (type (;60;) (struct (field (mut (ref 55))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 46)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (global (;2;) (mut eqref) ref.null eq)
  (global (;3;) (mut eqref) ref.null eq)
  (export "main" (func 16))
  (export "__dew_init" (func 18))
  (export "memory" (memory 0))
  (elem (;0;) declare func 11 12 13 14 17)
  (func (;1;) (type 14) (param i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
      i32.eqz
    end
  )
  (func (;2;) (type 33) (param (ref 3)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.lt_u
  )
  (func (;3;) (type 34) (param (ref 3)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.set 2
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 2
    array.get 6
    local.get 1
    ref.cast (ref 3)
    local.get 2
    i32.const 1
    i32.add
    struct.set 3 1
  )
  (func (;4;) (type 35))
  (func (;5;) (type 41) (param eqref eqref)
    (local eqref i32)
    i32.const 1
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 3
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 0
            ref.cast (ref 3)
            call 2
            if ;; label = @5
              local.get 1
              local.set 2
              local.get 2
              ref.cast (ref 4)
              struct.get 4 0
              ref.test (ref 50)
              if ;; label = @6
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 2
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 50)
                call_ref 50
              else
                local.get 2
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 2
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 20)
                call_ref 20
              end
              i32.const 1
              local.set 3
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 4
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;6;) (type 42) (param eqref i32 eqref) (result i32)
    (local i32 i32 eqref i32 i32)
    local.get 1
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 3
            local.get 0
            ref.cast (ref 3)
            call 2
            if ;; label = @5
              local.get 2
              local.set 5
              local.get 5
              ref.cast (ref 4)
              struct.get 4 0
              ref.test (ref 14)
              if (result i32) ;; label = @6
                local.get 3
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 5
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 14)
                call_ref 14
              else
                local.get 5
                local.get 3
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 5
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 51)
                call_ref 51
              end
              local.set 6
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 4
            local.get 4
            local.set 7
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 7
  )
  (func (;7;) (type 43) (param eqref eqref) (result i32)
    (local eqref i32 i32)
    i32.const 1
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 3
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 0
            ref.cast (ref 3)
            call 2
            if ;; label = @5
              local.get 1
              local.set 2
              local.get 2
              ref.cast (ref 4)
              struct.get 4 0
              ref.test (ref 49)
              if (result i32) ;; label = @6
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 2
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 49)
                call_ref 49
              else
                local.get 2
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 2
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 22)
                call_ref 22
              end
              if ;; label = @6
                i32.const 1
                local.set 4
                br 5 (;@1;)
              else
                i32.const 1
                local.set 3
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 4
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 4
  )
  (func (;8;) (type 44) (param eqref eqref) (result i32)
    (local eqref i32 i32)
    i32.const 1
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 3
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 0
            ref.cast (ref 3)
            call 2
            if ;; label = @5
              local.get 1
              local.set 2
              local.get 2
              ref.cast (ref 4)
              struct.get 4 0
              ref.test (ref 49)
              if (result i32) ;; label = @6
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 2
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 49)
                call_ref 49
              else
                local.get 2
                local.get 0
                ref.cast (ref 3)
                call 3
                local.get 2
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 22)
                call_ref 22
              end
              if ;; label = @6
                i32.const 1
                local.set 3
                br 4 (;@2;)
              else
                i32.const 0
                local.set 4
                br 5 (;@1;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 1
            local.set 4
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 4
  )
  (func (;9;) (type 45) (param eqref eqref) (result (ref 0))
    (local i32 eqref i32 eqref)
    i32.const 1
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 0
            ref.cast (ref 3)
            call 2
            if ;; label = @5
              local.get 0
              ref.cast (ref 3)
              call 3
              local.set 2
              local.get 1
              local.set 3
              local.get 3
              ref.cast (ref 4)
              struct.get 4 0
              ref.test (ref 49)
              if (result i32) ;; label = @6
                local.get 2
                local.get 3
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 49)
                call_ref 49
              else
                local.get 3
                local.get 2
                local.get 3
                ref.cast (ref 4)
                struct.get 4 0
                ref.cast (ref 22)
                call_ref 22
              end
              if ;; label = @6
                i32.const 1
                local.get 2
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                ref.null eq
                struct.new 1
                local.set 5
                br 5 (;@1;)
              else
                i32.const 1
                local.set 4
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            struct.new 0
            local.set 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 5
    ref.cast (ref 0)
  )
  (func (;10;) (type 47) (param i32 eqref) (result i32)
    (local (ref 57) (ref 55) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 57)
    local.set 2
    local.get 2
    struct.get 57 0
    local.set 3
    local.get 2
    struct.get 57 1
    local.set 4
    local.get 2
    struct.get 57 2
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
              array.get 55
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
              array.get 55
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
              array.get 55
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
              array.get 55
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
                array.get 55
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 55
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
                array.get 55
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
            array.get 55
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
  (func (;11;) (type 48) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
  )
  (func (;12;) (type 49) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
  )
  (func (;13;) (type 49) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.gt_s
  )
  (func (;14;) (type 49) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.eq
  )
  (func (;15;) (type 52) (result (ref 2))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 6
    i32.const 0
    i32.const 0
    struct.new 2
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 6
      local.set 3
      local.get 3
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 6 6
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 6)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 4
    array.set 6
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 6
      local.set 3
      local.get 3
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 6 6
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 6)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 5
    array.set 6
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 3
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 6
      local.set 3
      local.get 3
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 6 6
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 6)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 6
    array.set 6
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 4
    local.set 7
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 6
      local.set 3
      local.get 3
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 6 6
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 6)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    array.set 6
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 5
    local.set 8
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 6
      local.set 3
      local.get 3
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 6)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 6 6
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 6)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 8
    array.set 6
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    ref.cast (ref 2)
  )
  (func (;16;) (type 53)
    (local eqref i32 eqref i32 eqref eqref)
    call 15
    local.set 0
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 2)
    i32.const 0
    struct.set 2 1
    call 15
    i32.const 0
    struct.new 3
    ref.func 17
    local.get 0
    struct.new 5
    call 5
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x72657469 0x726f6620 0x6361655f 0x6f632068
    v128.const i32x4 0x6d75736e 0x65207365 0x79726576 0x6c617620
    v128.const i32x4 0x00006575 0x00000000 0x00000000 0x00000000
    array.new_fixed 55 3
    i32.const 0
    i32.const 34
    struct.new 56
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 3
    array.get 6
    i32.const 1
    i32.eq
    v128.const i32x4 0x72657469 0x726f6620 0x6361655f 0x72702068
    v128.const i32x4 0x72657365 0x20736576 0x73726966 0x61762074
    v128.const i32x4 0x0065756c 0x00000000 0x00000000 0x00000000
    array.new_fixed 55 3
    i32.const 0
    i32.const 35
    struct.new 56
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 3
    array.get 6
    i32.const 5
    i32.eq
    v128.const i32x4 0x72657469 0x726f6620 0x6361655f 0x72702068
    v128.const i32x4 0x72657365 0x20736576 0x616e6966 0x6176206c
    v128.const i32x4 0x0065756c 0x00000000 0x00000000 0x00000000
    array.new_fixed 55 3
    i32.const 0
    i32.const 35
    struct.new 56
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 15
    i32.const 0
    struct.new 3
    i32.const 0
    global.get 0
    call 6
    i32.const 15
    i32.eq
    v128.const i32x4 0x72657469 0x6c6f6620 0x63612064 0x756d7563
    v128.const i32x4 0x6574616c 0x00000073 0x00000000 0x00000000
    array.new_fixed 55 2
    i32.const 0
    i32.const 21
    struct.new 56
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 15
    i32.const 0
    struct.new 3
    global.get 1
    call 7
    v128.const i32x4 0x72657469 0x796e6120 0x6f687320 0x63207472
    v128.const i32x4 0x75637269 0x00737469 0x00000000 0x00000000
    array.new_fixed 55 2
    i32.const 0
    i32.const 23
    struct.new 56
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 15
    i32.const 0
    struct.new 3
    global.get 1
    call 8
    i32.eqz
    v128.const i32x4 0x72657469 0x6c6c6120 0x6f687320 0x63207472
    v128.const i32x4 0x75637269 0x00737469 0x00000000 0x00000000
    array.new_fixed 55 2
    i32.const 0
    i32.const 23
    struct.new 56
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 15
    i32.const 0
    struct.new 3
    global.get 2
    call 8
    i32.const 0
    call 1
    v128.const i32x4 0x72657469 0x6c6c6120 0x6c616620 0x00006573
    array.new_fixed 55 1
    i32.const 0
    i32.const 14
    struct.new 56
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 15
    i32.const 0
    struct.new 3
    global.get 3
    call 9
    local.set 5
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 5
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x72657469 0x6e696620 0x6e752064 0x65707865
          v128.const i32x4 0x64657463 0x6520796c 0x7974706d 0x00000000
          array.new_fixed 55 2
          i32.const 0
          i32.const 28
          struct.new 56
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 1
        i32.const 3
        i32.eq
        v128.const i32x4 0x72657469 0x6e696620 0x65722064 0x6e727574
        v128.const i32x4 0x69662073 0x20747372 0x6374616d 0x00000068
        array.new_fixed 55 2
        i32.const 0
        i32.const 29
        struct.new 56
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x72657469
    v128.const i32x4 0x6d6f632d 0x616e6962 0x73726f74 0x00000000
    array.new_fixed 55 2
    i32.const 0
    i32.const 28
    struct.new 57
    call 10
    drop
  )
  (func (;17;) (type 20) (param eqref i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 5)
    struct.get 5 1
    ref.cast (ref 2)
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    local.get 2
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 6
      local.set 4
      local.get 4
      ref.cast (ref 6)
      i32.const 0
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 6)
      i32.const 0
      local.get 2
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 6 6
      local.get 2
      ref.cast (ref 2)
      local.get 4
      struct.set 2 0
      local.get 2
      ref.cast (ref 2)
      local.get 4
      ref.cast (ref 6)
      array.len
      struct.set 2 2
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 6)
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    local.get 5
    array.set 6
    local.get 2
    ref.cast (ref 2)
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
  )
  (func (;18;) (type 54)
    ref.func 11
    struct.new 4
    global.set 0
    ref.func 12
    struct.new 4
    global.set 1
    ref.func 13
    struct.new 4
    global.set 2
    ref.func 14
    struct.new 4
    global.set 3
  )
)
