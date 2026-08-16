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
  (type (;9;) (sub final 8 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;10;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;11;) (sub (struct (field funcref))))
  (type (;12;) (func (param eqref) (result eqref)))
  (type (;13;) (func (param eqref i32) (result eqref)))
  (type (;14;) (func (param eqref) (result (ref 10))))
  (type (;15;) (func (param eqref eqref) (result eqref)))
  (type (;16;) (func (param eqref)))
  (type (;17;) (func (param eqref i32)))
  (type (;18;) (func (param eqref) (result i32)))
  (type (;19;) (func (param eqref i32) (result i32)))
  (type (;20;) (func (param eqref eqref i32) (result eqref)))
  (type (;21;) (func (param eqref eqref) (result (ref 10))))
  (type (;22;) (func (param eqref eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref eqref)))
  (type (;24;) (func (param eqref eqref i32)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref eqref i32) (result i32)))
  (type (;27;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;28;) (func (result (ref 10))))
  (type (;29;) (func))
  (type (;30;) (array (mut v128)))
  (type (;31;) (struct (field (ref 30)) (field i32) (field i32)))
  (type (;32;) (struct (field (ref 30)) (field i32) (field i32)))
  (type (;33;) (struct (field (ref 30)) (field i32) (field i32)))
  (type (;34;) (struct (field (mut (ref 30))) (field (mut i32)) (field (mut i32))))
  (type (;35;) (struct (field (mut (ref 30))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 28) (result (ref 10))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;1;) (type 29)
    (local eqref i32 eqref i32 eqref)
    call 0
    local.set 0
    local.get 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.sub
      local.set 1
      local.get 0
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 1
      array.get 0
      local.set 3
      local.get 0
      ref.cast (ref 10)
      local.get 1
      struct.set 10 1
      i32.const 1
      local.get 3
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    end
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x74706d65 0x72612079 0x20796172 0x20706f70
        v128.const i32x4 0x78656e75 0x74636570 0x796c6465 0x65727020
        v128.const i32x4 0x746e6573 0x00000000 0x00000000 0x00000000
        array.new_fixed 30 3
        i32.const 0
        i32.const 36
        struct.new 31
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
