(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;11;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field eqref) (field (mut i32))))
  (type (;13;) (struct (field (ref 11)) (field (mut i32))))
  (type (;14;) (sub (struct (field funcref))))
  (type (;15;) (func (param eqref) (result eqref)))
  (type (;16;) (func (param eqref i32) (result eqref)))
  (type (;17;) (func (param eqref) (result (ref 11))))
  (type (;18;) (func (param eqref eqref) (result eqref)))
  (type (;19;) (func (param eqref)))
  (type (;20;) (func (param eqref i32)))
  (type (;21;) (func (param eqref) (result i32)))
  (type (;22;) (func (param eqref i32) (result i32)))
  (type (;23;) (func (param eqref eqref i32) (result eqref)))
  (type (;24;) (func (param eqref eqref) (result (ref 11))))
  (type (;25;) (func (param eqref eqref eqref) (result eqref)))
  (type (;26;) (func (param eqref eqref)))
  (type (;27;) (func (param eqref eqref i32)))
  (type (;28;) (func (param eqref eqref) (result i32)))
  (type (;29;) (func (param eqref eqref i32) (result i32)))
  (type (;30;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;31;) (func (param (ref 11)) (result (ref 13))))
  (type (;32;) (func (param (ref 13)) (result (ref 8))))
  (type (;33;) (func (param (ref 13)) (result (ref 8))))
  (type (;34;) (func (param (ref 11)) (result (ref 13))))
  (type (;35;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;36;) (func (param i32 eqref) (result i32)))
  (type (;37;) (func (result (ref 11))))
  (type (;38;) (func (param (ref 13)) (result i32)))
  (type (;39;) (func (param (ref 13)) (result i32)))
  (type (;40;) (func))
  (type (;41;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;42;) (struct))
  (type (;43;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;44;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;45;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;46;) (array (mut v128)))
  (type (;47;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;48;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;49;) (struct (field (ref 46)) (field i32) (field i32)))
  (type (;50;) (struct (field (mut (ref 46))) (field (mut i32)) (field (mut i32))))
  (type (;51;) (struct (field (mut (ref 46))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 35)))
  (memory (;0;) 1)
  (export "main" (func 7))
  (export "memory" (memory 0))
  (func (;1;) (type 33) (param (ref 13)) (result (ref 8))
    (local i32)
    local.get 0
    ref.cast (ref 13)
    struct.get 13 1
    local.get 0
    ref.cast (ref 13)
    struct.get 13 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      ref.cast (ref 13)
      struct.get 13 1
      local.set 1
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      struct.set 13 1
      i32.const 1
      local.get 1
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;2;) (type 34) (param (ref 11)) (result (ref 13))
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    struct.new 13
    ref.cast (ref 13)
  )
  (func (;3;) (type 36) (param i32 eqref) (result i32)
    (local (ref 48) (ref 46) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 48)
    local.set 2
    local.get 2
    struct.get 48 0
    local.set 3
    local.get 2
    struct.get 48 1
    local.set 4
    local.get 2
    struct.get 48 2
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
              array.get 46
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
              array.get 46
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
              array.get 46
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
              array.get 46
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
                array.get 46
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 46
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
                array.get 46
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
            array.get 46
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
  (func (;4;) (type 37) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32 i32)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 3
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
  )
  (func (;5;) (type 38) (param (ref 13)) (result i32)
    (local i32 eqref i32)
    local.get 0
    ref.cast (ref 13)
    call 1
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const -1
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 9)
        struct.get 9 1
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;6;) (type 39) (param (ref 13)) (result i32)
    (local eqref i32)
    local.get 0
    ref.cast (ref 13)
    call 1
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 1
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;7;) (type 40)
    (local eqref eqref eqref i32 eqref i32)
    call 4
    local.set 0
    local.get 0
    ref.cast (ref 11)
    call 2
    local.set 1
    local.get 1
    ref.cast (ref 13)
    call 5
    i32.const 0
    i32.eq
    v128.const i32x4 0x7379656b 0x72657a20 0x0000006f 0x00000000
    array.new_fixed 46 1
    i32.const 0
    i32.const 9
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 2
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 3
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      array.new_default 0
      local.set 4
      local.get 4
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      struct.set 11 0
      local.get 2
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 2
    ref.cast (ref 11)
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 1
    ref.cast (ref 13)
    call 5
    i32.const 1
    i32.eq
    v128.const i32x4 0x7379656b 0x656e6f20 0x00000000 0x00000000
    array.new_fixed 46 1
    i32.const 0
    i32.const 8
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 13)
    call 5
    i32.const 2
    i32.eq
    v128.const i32x4 0x7379656b 0x6f777420 0x00000000 0x00000000
    array.new_fixed 46 1
    i32.const 0
    i32.const 8
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 13)
    call 5
    i32.const 3
    i32.eq
    v128.const i32x4 0x7379656b 0x73626f20 0x65767265 0x75702073
    v128.const i32x4 0x00006873 0x00000000 0x00000000 0x00000000
    array.new_fixed 46 2
    i32.const 0
    i32.const 18
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 13)
    call 6
    v128.const i32x4 0x7379656b 0x68786520 0x74737561 0x00006465
    array.new_fixed 46 1
    i32.const 0
    i32.const 14
    struct.new 47
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x74692d79 0x74617265 0x2d73726f 0x746e7572
    v128.const i32x4 0x00656d69 0x00000000 0x00000000 0x00000000
    array.new_fixed 46 3
    i32.const 0
    i32.const 35
    struct.new 48
    call 3
    drop
  )
)
