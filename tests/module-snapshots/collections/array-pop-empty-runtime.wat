(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;3;) (func (result (ref 2))))
  (type (;4;) (func))
  (type (;5;) (array (mut v128)))
  (type (;6;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;9;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (array (mut i32)))
  (type (;12;) (array (mut i64)))
  (type (;13;) (array (mut f32)))
  (type (;14;) (array (mut f64)))
  (type (;15;) (array (mut v128)))
  (type (;16;) (array (mut eqref)))
  (export "main" (func 1))
  (func (;0;) (type 3) (result (ref 2))
    i32.const 0
    array.new_default 11
    i32.const 0
    i32.const 0
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;1;) (type 4)
    (local eqref i32 eqref i32 eqref)
    call 0
    local.set 0
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 0
    else
      local.get 0
      ref.cast (ref 2)
      struct.get 2 1
      i32.const 1
      i32.sub
      local.set 1
      local.get 0
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 11)
      local.get 1
      array.get 11
      local.set 3
      local.get 0
      ref.cast (ref 2)
      local.get 1
      struct.set 2 1
      i32.const 1
      local.get 3
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    end
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x74706d65 0x72612079 0x20796172 0x20706f70
        v128.const i32x4 0x78656e75 0x74636570 0x796c6465 0x65727020
        v128.const i32x4 0x746e6573 0x00000000 0x00000000 0x00000000
        array.new_fixed 5 3
        i32.const 0
        i32.const 36
        struct.new 6
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
  )
)
