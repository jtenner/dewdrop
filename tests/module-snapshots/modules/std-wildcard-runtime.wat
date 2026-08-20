(module
  (rec
    (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;1;) (struct))
  )
  (rec
    (type (;2;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;4;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;5;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;6;) (struct (field eqref) (field (mut i32))))
  )
  (rec
    (type (;7;) (sub (struct (field funcref))))
  )
  (rec
    (type (;8;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;9;) (struct (field (mut eqref)) (field (mut i32))))
  )
  (rec
    (type (;10;) (sub (struct (field i32))))
  )
  (rec
    (type (;11;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  )
  (rec
    (type (;12;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  )
  (type (;13;) (array (mut i32)))
  (type (;14;) (array (mut i64)))
  (type (;15;) (array (mut f32)))
  (type (;16;) (array (mut f64)))
  (type (;17;) (array (mut v128)))
  (type (;18;) (array (mut eqref)))
  (type (;19;) (array (mut i8)))
  (type (;20;) (array (mut i16)))
  (type (;21;) (func (param eqref) (result eqref)))
  (type (;22;) (func (param eqref i32) (result eqref)))
  (type (;23;) (func (param eqref) (result (ref 5))))
  (type (;24;) (func (param eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref)))
  (type (;26;) (func (param eqref i32)))
  (type (;27;) (func (param eqref) (result i32)))
  (type (;28;) (func (param eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref i32) (result eqref)))
  (type (;30;) (func (param eqref eqref) (result (ref 5))))
  (type (;31;) (func (param eqref eqref eqref) (result eqref)))
  (type (;32;) (func (param eqref eqref)))
  (type (;33;) (func (param eqref eqref i32)))
  (type (;34;) (func (param eqref eqref) (result i32)))
  (type (;35;) (func (param eqref eqref i32) (result i32)))
  (type (;36;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;37;) (func (param (ref 12) (ref 11) (ref 11)) (result (ref 10))))
  (type (;38;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;39;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;40;) (func (param i32 eqref) (result i32)))
  (type (;41;) (func (result i32)))
  (type (;42;) (array (mut v128)))
  (type (;43;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;44;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;46;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (type (;47;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 38)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;1;) (type 39)))
  (memory (;0;) 1)
  (export "main" (func 3))
  (export "memory" (memory 0))
  (func (;2;) (type 40) (param i32 eqref) (result i32)
    (local (ref 44) (ref 42) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 44)
    local.set 2
    local.get 2
    struct.get 44 0
    local.set 3
    local.get 2
    struct.get 44 1
    local.set 4
    local.get 2
    struct.get 44 2
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
              array.get 42
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
              array.get 42
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
              array.get 42
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
              array.get 42
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
                array.get 42
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 42
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
                array.get 42
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
            array.get 42
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
            call 1
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
  (func (;3;) (type 41) (result i32)
    i32.const 1
    v128.const i32x4 0x646c6977 0x64726163 0x0000000a 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 9
    struct.new 44
    call 2
  )
)
