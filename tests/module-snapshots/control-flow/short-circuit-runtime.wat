(module
  (type (;0;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;1;) (func (param i32 eqref) (result i32)))
  (type (;2;) (func (result i32)))
  (type (;3;) (func (param i32) (result i32)))
  (type (;4;) (func (param i32) (result i32)))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (result i32)))
  (type (;7;) (array (mut v128)))
  (type (;8;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;10;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;11;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 0)))
  (memory (;0;) 1)
  (export "main" (func 6))
  (export "memory" (memory 0))
  (func (;1;) (type 1) (param i32 eqref) (result i32)
    (local (ref 9) (ref 7) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 9)
    local.set 2
    local.get 2
    struct.get 9 0
    local.set 3
    local.get 2
    struct.get 9 1
    local.set 4
    local.get 2
    struct.get 9 2
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
              array.get 7
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
              array.get 7
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
              array.get 7
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
              array.get 7
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
                array.get 7
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 7
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
                array.get 7
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
            array.get 7
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
  (func (;2;) (type 2) (result i32)
    i32.const 1
    v128.const i32x4 0x00444142 0x00000000 0x00000000 0x00000000
    array.new_fixed 7 1
    i32.const 0
    i32.const 3
    struct.new 9
    call 1
    drop
    i32.const 1
  )
  (func (;3;) (type 3) (param i32) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      i32.const 1
      if (result i32) ;; label = @2
        local.get 0
        return
      else
        i32.const 0
      end
    else
      i32.const 0
    end
    drop
    i32.const 0
  )
  (func (;4;) (type 4) (param i32) (result i32)
    i32.const 0
    if (result i32) ;; label = @1
      i32.const 1
    else
      i32.const 1
      if (result i32) ;; label = @2
        local.get 0
        return
      else
        i32.const 0
      end
    end
    drop
    i32.const 0
  )
  (func (;5;) (type 5) (param i32) (result i32)
    (local i32 i32 i32)
    local.get 0
    local.set 2
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 2
            local.set 1
            local.get 1
            i32.const 0
            i32.gt_s
            if (result i32) ;; label = @5
              local.get 1
              i32.const 1
              i32.sub
              local.set 2
              br 3 (;@2;)
            else
              i32.const 0
            end
            drop
            i32.const 0
            if (result i32) ;; label = @5
              i32.const 1
            else
              i32.const 9
              local.set 3
              br 4 (;@1;)
            end
            drop
            i32.const 0
            local.set 3
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 3
  )
  (func (;6;) (type 6) (result i32)
    i32.const 0
    if (result i32) ;; label = @1
      call 2
    else
      i32.const 0
    end
    i32.eqz
    v128.const i32x4 0x736c6166 0x6e612065 0x6b732064 0x20737069
    v128.const i32x4 0x00736872 0x00000000 0x00000000 0x00000000
    array.new_fixed 7 2
    i32.const 0
    i32.const 19
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    if (result i32) ;; label = @1
      i32.const 1
    else
      call 2
    end
    v128.const i32x4 0x65757274 0x20726f20 0x70696b73 0x68722073
    v128.const i32x4 0x00000073 0x00000000 0x00000000 0x00000000
    array.new_fixed 7 2
    i32.const 0
    i32.const 17
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x20646e61 0x756c6176 0x00000065 0x00000000
    array.new_fixed 7 1
    i32.const 0
    i32.const 9
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x7620726f 0x65756c61 0x00000000 0x00000000
    array.new_fixed 7 1
    i32.const 0
    i32.const 8
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4
    call 3
    i32.const 4
    i32.eq
    v128.const i32x4 0x75746572 0x74206e72 0x756f7268 0x61206867
    v128.const i32x4 0x0000646e 0x00000000 0x00000000 0x00000000
    array.new_fixed 7 2
    i32.const 0
    i32.const 18
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5
    call 4
    i32.const 5
    i32.eq
    v128.const i32x4 0x75746572 0x74206e72 0x756f7268 0x6f206867
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 7 2
    i32.const 0
    i32.const 17
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    call 5
    i32.const 9
    i32.eq
    v128.const i32x4 0x706f6f6c 0x61727420 0x6566736e 0x74207372
    v128.const i32x4 0x756f7268 0x6c206867 0x6369676f 0x6f206c61
    v128.const i32x4 0x61726570 0x73726f74 0x00000000 0x00000000
    array.new_fixed 7 3
    i32.const 0
    i32.const 40
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x746e6f63 0x3a6c6f72 0x726f6873 0x69632d74
    v128.const i32x4 0x69756372 0x00000074 0x00000000 0x00000000
    array.new_fixed 7 2
    i32.const 0
    i32.const 21
    struct.new 9
    call 1
  )
)
