(module
  (rec
    (type (;0;) (sub (struct (field i32))))
  )
  (rec
    (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  )
  (rec
    (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  )
  (rec
    (type (;3;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;4;) (struct (field eqref) (field (mut i32))))
  )
  (rec
    (type (;5;) (sub (struct (field funcref))))
  )
  (rec
    (type (;6;) (sub final 5 (struct (field funcref) (field eqref))))
  )
  (rec
    (type (;7;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;8;) (struct))
  )
  (rec
    (type (;9;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;10;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;11;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (type (;12;) (array (mut i32)))
  (type (;13;) (array (mut i64)))
  (type (;14;) (array (mut f32)))
  (type (;15;) (array (mut f64)))
  (type (;16;) (array (mut v128)))
  (type (;17;) (array (mut eqref)))
  (type (;18;) (array (mut i8)))
  (type (;19;) (array (mut i16)))
  (type (;20;) (func (param i32 i32) (result i32)))
  (type (;21;) (func (param eqref) (result eqref)))
  (type (;22;) (func (param eqref i32) (result eqref)))
  (type (;23;) (func (param eqref) (result (ref 3))))
  (type (;24;) (func (param eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref)))
  (type (;26;) (func (param eqref i32)))
  (type (;27;) (func (param eqref) (result i32)))
  (type (;28;) (func (param eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref i32) (result eqref)))
  (type (;30;) (func (param eqref eqref) (result (ref 3))))
  (type (;31;) (func (param eqref eqref eqref) (result eqref)))
  (type (;32;) (func (param eqref eqref)))
  (type (;33;) (func (param eqref eqref i32)))
  (type (;34;) (func (param eqref eqref) (result i32)))
  (type (;35;) (func (param eqref eqref i32) (result i32)))
  (type (;36;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;37;) (func (param (ref 4)) (result (ref 0))))
  (type (;38;) (func (param (ref 4)) (result (ref 0))))
  (type (;39;) (func))
  (type (;40;) (func (param eqref eqref)))
  (type (;41;) (func (param eqref eqref eqref) (result eqref)))
  (type (;42;) (func (param eqref eqref) (result i32)))
  (type (;43;) (func (param eqref eqref) (result i32)))
  (type (;44;) (func (param eqref eqref) (result (ref 0))))
  (type (;45;) (func (param eqref eqref)))
  (type (;46;) (func (param eqref i32 eqref) (result i32)))
  (type (;47;) (func (param eqref eqref) (result i32)))
  (type (;48;) (func (param eqref eqref) (result i32)))
  (type (;49;) (func (param eqref eqref) (result (ref 0))))
  (type (;50;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;51;) (func (param i32 eqref) (result i32)))
  (type (;52;) (func (param i32 i32) (result i32)))
  (type (;53;) (func (param i32) (result i32)))
  (type (;54;) (func (param i32)))
  (type (;55;) (func (param eqref i32 i32) (result i32)))
  (type (;56;) (func (result (ref 3))))
  (type (;57;) (func))
  (type (;58;) (func))
  (type (;59;) (array (mut v128)))
  (type (;60;) (struct (field (ref 59)) (field i32) (field i32)))
  (type (;61;) (struct (field (ref 59)) (field i32) (field i32)))
  (type (;62;) (struct (field (ref 59)) (field i32) (field i32)))
  (type (;63;) (struct (field (mut (ref 59))) (field (mut i32)) (field (mut i32))))
  (type (;64;) (struct (field (mut (ref 59))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 50)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (global (;2;) (mut eqref) ref.null eq)
  (global (;3;) (mut eqref) ref.null eq)
  (export "main" (func 15))
  (export "__dew_init" (func 17))
  (export "memory" (memory 0))
  (elem (;0;) declare func 10 11 12 13 16)
  (func (;1;) (type 20) (param i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
      i32.eqz
    end
  )
  (func (;2;) (type 38) (param (ref 4)) (result (ref 0))
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 4)
    struct.get 4 1
    local.get 1
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 3)
    struct.get 3 1
    i32.lt_u
    if (result eqref) ;; label = @1
      local.get 1
      ref.cast (ref 4)
      struct.get 4 1
      local.set 2
      local.get 1
      ref.cast (ref 4)
      local.get 2
      i32.const 1
      i32.add
      struct.set 4 1
      i32.const 1
      local.get 1
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 12)
      local.get 2
      array.get 12
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    ref.cast (ref 0)
    ref.cast (ref 0)
  )
  (func (;3;) (type 39))
  (func (;4;) (type 45) (param eqref eqref)
    (local i32 eqref eqref)
    local.get 0
    ref.cast (ref 4)
    call 2
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            local.set 2
            local.get 1
            local.set 3
            local.get 3
            ref.cast (ref 5)
            struct.get 5 0
            ref.test (ref 54)
            if ;; label = @5
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 54)
              call_ref 54
            else
              local.get 3
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 26)
              call_ref 26
            end
            local.get 0
            ref.cast (ref 4)
            call 2
            local.set 4
            br 2 (;@2;)
            br 1 (;@3;)
          end
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 0
          i32.eq
          if ;; label = @4
            call 3
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
  (func (;5;) (type 46) (param eqref i32 eqref) (result i32)
    (local i32 i32 eqref eqref i32)
    local.get 1
    local.set 3
    local.get 0
    ref.cast (ref 4)
    call 2
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 6
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 6
            ref.cast (ref 1)
            struct.get 1 1
            local.set 4
            local.get 2
            local.set 5
            local.get 5
            ref.cast (ref 5)
            struct.get 5 0
            ref.test (ref 20)
            if (result i32) ;; label = @5
              local.get 3
              local.get 4
              local.get 5
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 20)
              call_ref 20
            else
              local.get 5
              local.get 3
              local.get 4
              local.get 5
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 55)
              call_ref 55
            end
            local.set 3
            local.get 0
            ref.cast (ref 4)
            call 2
            local.set 6
            br 2 (;@2;)
            br 1 (;@3;)
          end
          local.get 6
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 0
          i32.eq
          if ;; label = @4
            local.get 3
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
  (func (;6;) (type 47) (param eqref eqref) (result i32)
    (local i32 eqref eqref i32)
    local.get 0
    ref.cast (ref 4)
    call 2
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            local.set 2
            local.get 1
            local.set 3
            local.get 3
            ref.cast (ref 5)
            struct.get 5 0
            ref.test (ref 53)
            if (result i32) ;; label = @5
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 53)
              call_ref 53
            else
              local.get 3
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 28)
              call_ref 28
            end
            if ;; label = @5
              i32.const 1
              local.set 5
              br 4 (;@1;)
            else
              local.get 0
              ref.cast (ref 4)
              call 2
              local.set 4
              br 3 (;@2;)
            end
            br 1 (;@3;)
          end
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 0
          i32.eq
          if ;; label = @4
            i32.const 0
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
  )
  (func (;7;) (type 48) (param eqref eqref) (result i32)
    (local i32 eqref eqref i32)
    local.get 0
    ref.cast (ref 4)
    call 2
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            local.set 2
            local.get 1
            local.set 3
            local.get 3
            ref.cast (ref 5)
            struct.get 5 0
            ref.test (ref 53)
            if (result i32) ;; label = @5
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 53)
              call_ref 53
            else
              local.get 3
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 28)
              call_ref 28
            end
            if ;; label = @5
              local.get 0
              ref.cast (ref 4)
              call 2
              local.set 4
              br 3 (;@2;)
            else
              i32.const 0
              local.set 5
              br 4 (;@1;)
            end
            br 1 (;@3;)
          end
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 0
          i32.eq
          if ;; label = @4
            i32.const 1
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
  )
  (func (;8;) (type 49) (param eqref eqref) (result (ref 0))
    (local i32 eqref eqref eqref)
    local.get 0
    ref.cast (ref 4)
    call 2
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            local.set 2
            local.get 1
            local.set 3
            local.get 3
            ref.cast (ref 5)
            struct.get 5 0
            ref.test (ref 53)
            if (result i32) ;; label = @5
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 53)
              call_ref 53
            else
              local.get 3
              local.get 2
              local.get 3
              ref.cast (ref 5)
              struct.get 5 0
              ref.cast (ref 28)
              call_ref 28
            end
            if ;; label = @5
              i32.const 1
              local.get 2
              struct.new 1
              local.set 5
              br 4 (;@1;)
            else
              local.get 0
              ref.cast (ref 4)
              call 2
              local.set 4
              br 3 (;@2;)
            end
            br 1 (;@3;)
          end
          local.get 4
          ref.cast (ref 0)
          struct.get 0 0
          i32.const 0
          i32.eq
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
  (func (;9;) (type 51) (param i32 eqref) (result i32)
    (local (ref 61) (ref 59) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 61)
    local.set 2
    local.get 2
    struct.get 61 0
    local.set 3
    local.get 2
    struct.get 61 1
    local.set 4
    local.get 2
    struct.get 61 2
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
              array.get 59
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
              array.get 59
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
              array.get 59
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
              array.get 59
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
                array.get 59
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 59
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
                array.get 59
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
            array.get 59
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
  (func (;10;) (type 52) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
  )
  (func (;11;) (type 53) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
  )
  (func (;12;) (type 53) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.gt_s
  )
  (func (;13;) (type 53) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.eq
  )
  (func (;14;) (type 56) (result (ref 3))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 12
    i32.const 0
    i32.const 0
    struct.new 3
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 3)
        struct.get 3 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 12
      local.set 3
      local.get 3
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 1
      array.copy 12 12
      local.get 1
      ref.cast (ref 3)
      local.get 3
      struct.set 3 0
      local.get 1
      ref.cast (ref 3)
      local.get 3
      ref.cast (ref 12)
      array.len
      struct.set 3 2
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 4
    array.set 12
    local.get 1
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.add
    struct.set 3 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 3)
        struct.get 3 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 12
      local.set 3
      local.get 3
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 1
      array.copy 12 12
      local.get 1
      ref.cast (ref 3)
      local.get 3
      struct.set 3 0
      local.get 1
      ref.cast (ref 3)
      local.get 3
      ref.cast (ref 12)
      array.len
      struct.set 3 2
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 5
    array.set 12
    local.get 1
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.add
    struct.set 3 1
    local.get 0
    i32.const 3
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 3)
        struct.get 3 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 12
      local.set 3
      local.get 3
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 1
      array.copy 12 12
      local.get 1
      ref.cast (ref 3)
      local.get 3
      struct.set 3 0
      local.get 1
      ref.cast (ref 3)
      local.get 3
      ref.cast (ref 12)
      array.len
      struct.set 3 2
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 6
    array.set 12
    local.get 1
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.add
    struct.set 3 1
    local.get 0
    i32.const 4
    local.set 7
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 3)
        struct.get 3 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 12
      local.set 3
      local.get 3
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 1
      array.copy 12 12
      local.get 1
      ref.cast (ref 3)
      local.get 3
      struct.set 3 0
      local.get 1
      ref.cast (ref 3)
      local.get 3
      ref.cast (ref 12)
      array.len
      struct.set 3 2
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 7
    array.set 12
    local.get 1
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.add
    struct.set 3 1
    local.get 0
    i32.const 5
    local.set 8
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 3)
        struct.get 3 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 3)
      struct.get 3 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 12
      local.set 3
      local.get 3
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 12)
      i32.const 0
      local.get 1
      ref.cast (ref 3)
      struct.get 3 1
      array.copy 12 12
      local.get 1
      ref.cast (ref 3)
      local.get 3
      struct.set 3 0
      local.get 1
      ref.cast (ref 3)
      local.get 3
      ref.cast (ref 12)
      array.len
      struct.set 3 2
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    local.get 8
    array.set 12
    local.get 1
    ref.cast (ref 3)
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.add
    struct.set 3 1
    local.get 0
    ref.cast (ref 3)
  )
  (func (;15;) (type 57)
    (local eqref i32 eqref i32 eqref eqref)
    call 14
    local.set 0
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 3)
    i32.const 0
    struct.set 3 1
    call 14
    i32.const 0
    struct.new 4
    ref.func 16
    local.get 0
    struct.new 6
    call 4
    local.get 0
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 5
    i32.eq
    v128.const i32x4 0x72657469 0x726f6620 0x6361655f 0x6f632068
    v128.const i32x4 0x6d75736e 0x65207365 0x79726576 0x6c617620
    v128.const i32x4 0x00006575 0x00000000 0x00000000 0x00000000
    array.new_fixed 59 3
    i32.const 0
    i32.const 34
    struct.new 60
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
    ref.cast (ref 3)
    struct.get 3 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 3
    array.get 12
    i32.const 1
    i32.eq
    v128.const i32x4 0x72657469 0x726f6620 0x6361655f 0x72702068
    v128.const i32x4 0x72657365 0x20736576 0x73726966 0x61762074
    v128.const i32x4 0x0065756c 0x00000000 0x00000000 0x00000000
    array.new_fixed 59 3
    i32.const 0
    i32.const 35
    struct.new 60
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
    ref.cast (ref 3)
    struct.get 3 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 3
    array.get 12
    i32.const 5
    i32.eq
    v128.const i32x4 0x72657469 0x726f6620 0x6361655f 0x72702068
    v128.const i32x4 0x72657365 0x20736576 0x616e6966 0x6176206c
    v128.const i32x4 0x0065756c 0x00000000 0x00000000 0x00000000
    array.new_fixed 59 3
    i32.const 0
    i32.const 35
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 14
    i32.const 0
    struct.new 4
    i32.const 0
    global.get 0
    call 5
    i32.const 15
    i32.eq
    v128.const i32x4 0x72657469 0x6c6f6620 0x63612064 0x756d7563
    v128.const i32x4 0x6574616c 0x00000073 0x00000000 0x00000000
    array.new_fixed 59 2
    i32.const 0
    i32.const 21
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 14
    i32.const 0
    struct.new 4
    global.get 1
    call 6
    v128.const i32x4 0x72657469 0x796e6120 0x6f687320 0x63207472
    v128.const i32x4 0x75637269 0x00737469 0x00000000 0x00000000
    array.new_fixed 59 2
    i32.const 0
    i32.const 23
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 14
    i32.const 0
    struct.new 4
    global.get 1
    call 7
    i32.eqz
    v128.const i32x4 0x72657469 0x6c6c6120 0x6f687320 0x63207472
    v128.const i32x4 0x75637269 0x00737469 0x00000000 0x00000000
    array.new_fixed 59 2
    i32.const 0
    i32.const 23
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 14
    i32.const 0
    struct.new 4
    global.get 2
    call 7
    i32.const 0
    call 1
    v128.const i32x4 0x72657469 0x6c6c6120 0x6c616620 0x00006573
    array.new_fixed 59 1
    i32.const 0
    i32.const 14
    struct.new 60
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 14
    i32.const 0
    struct.new 4
    global.get 3
    call 8
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
          array.new_fixed 59 2
          i32.const 0
          i32.const 28
          struct.new 60
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
        array.new_fixed 59 2
        i32.const 0
        i32.const 29
        struct.new 60
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
    array.new_fixed 59 2
    i32.const 0
    i32.const 28
    struct.new 61
    call 9
    drop
  )
  (func (;16;) (type 26) (param eqref i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 6)
    struct.get 6 1
    ref.cast (ref 3)
    local.get 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 3)
    struct.get 3 1
    local.get 2
    ref.cast (ref 3)
    struct.get 3 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 3)
      struct.get 3 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 3)
        struct.get 3 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 3)
      struct.get 3 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 12
      local.set 4
      local.get 4
      ref.cast (ref 12)
      i32.const 0
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 12)
      i32.const 0
      local.get 2
      ref.cast (ref 3)
      struct.get 3 1
      array.copy 12 12
      local.get 2
      ref.cast (ref 3)
      local.get 4
      struct.set 3 0
      local.get 2
      ref.cast (ref 3)
      local.get 4
      ref.cast (ref 12)
      array.len
      struct.set 3 2
    end
    local.get 2
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 12)
    local.get 2
    ref.cast (ref 3)
    struct.get 3 1
    local.get 5
    array.set 12
    local.get 2
    ref.cast (ref 3)
    local.get 2
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.add
    struct.set 3 1
  )
  (func (;17;) (type 58)
    ref.func 10
    struct.new 5
    global.set 0
    ref.func 11
    struct.new 5
    global.set 1
    ref.func 12
    struct.new 5
    global.set 2
    ref.func 13
    struct.new 5
    global.set 3
  )
)
