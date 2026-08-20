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
  (type (;31;) (func (param i32 eqref) (result (ref 11))))
  (type (;32;) (func (param (ref 11)) (result (ref 13))))
  (type (;33;) (func (param (ref 13)) (result (ref 8))))
  (type (;34;) (func (param i32 i32) (result (ref 11))))
  (type (;35;) (func (param (ref 11)) (result (ref 13))))
  (type (;36;) (func (param (ref 13)) (result (ref 8))))
  (type (;37;) (func))
  (type (;38;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;39;) (struct))
  (type (;40;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;41;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;42;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;43;) (array (mut v128)))
  (type (;44;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;46;) (struct (field (ref 43)) (field i32) (field i32)))
  (type (;47;) (struct (field (mut (ref 43))) (field (mut i32)) (field (mut i32))))
  (type (;48;) (struct (field (mut (ref 43))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 34) (param i32 i32) (result (ref 11))
    (local eqref i32 eqref i32)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 0
    local.get 3
    local.get 3
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;1;) (type 35) (param (ref 11)) (result (ref 13))
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    struct.new 13
    ref.cast (ref 13)
  )
  (func (;2;) (type 36) (param (ref 13)) (result (ref 8))
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
  (func (;3;) (type 37)
    (local eqref i32 eqref eqref)
    i32.const 1
    i32.const 7
    call 0
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 13)
    call 2
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
          unreachable
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 9)
        struct.get 9 1
        local.set 1
        local.get 1
        i32.const 0
        i32.eq
        v128.const i32x4 0x73726966 0x656b2074 0x00000079 0x00000000
        array.new_fixed 43 1
        i32.const 0
        i32.const 9
        struct.new 44
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 0
    ref.cast (ref 13)
    call 2
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        unreachable
        br 1 (;@1;)
      end
      unreachable
    end
  )
)
