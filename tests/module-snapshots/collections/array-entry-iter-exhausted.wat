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
  (type (;13;) (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;14;) (struct (field (ref 11)) (field (mut i32))))
  (type (;15;) (sub (struct (field funcref))))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result eqref)))
  (type (;18;) (func (param eqref) (result (ref 11))))
  (type (;19;) (func (param eqref eqref) (result eqref)))
  (type (;20;) (func (param eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result (ref 11))))
  (type (;26;) (func (param eqref eqref eqref) (result eqref)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref eqref i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result i32)))
  (type (;31;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;32;) (func (param i32 eqref) (result (ref 11))))
  (type (;33;) (func (param (ref 11)) (result (ref 14))))
  (type (;34;) (func (param eqref) (result eqref)))
  (type (;35;) (func (param (ref 14)) (result (ref 8))))
  (type (;36;) (func (param i32 i32) (result (ref 11))))
  (type (;37;) (func (param (ref 11)) (result (ref 14))))
  (type (;38;) (func (param (ref 14)) (result (ref 8))))
  (type (;39;) (func (param eqref) (result i32)))
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
  (export "main" (func 4))
  (func (;0;) (type 36) (param i32 i32) (result (ref 11))
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
  (func (;1;) (type 37) (param (ref 11)) (result (ref 14))
    local.get 0
    ref.cast (ref 11)
    i32.const 0
    struct.new 14
    ref.cast (ref 14)
  )
  (func (;2;) (type 38) (param (ref 14)) (result (ref 8))
    (local i32 i32 eqref i32 eqref)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 1
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      ref.cast (ref 14)
      struct.get 14 1
      local.set 1
      local.get 0
      ref.cast (ref 14)
      struct.get 14 0
      local.get 1
      local.set 4
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      array.get 0
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      struct.set 14 1
      i32.const 1
      local.get 1
      local.get 2
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 13
      struct.new 10
    end
    ref.cast (ref 8)
  )
  (func (;3;) (type 39) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.test (ref 12)
    if (result i32) ;; label = @1
      local.get 1
      ref.cast (ref 12)
      struct.get 12 1
    else
      local.get 1
      ref.test (ref 13)
      if (result i32) ;; label = @2
        local.get 1
        ref.cast (ref 13)
        struct.get 13 1
      else
        unreachable
      end
    end
  )
  (func (;4;) (type 40)
    (local eqref eqref eqref eqref)
    i32.const 1
    i32.const 7
    call 0
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 14)
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
        ref.cast (ref 10)
        struct.get 10 1
        local.set 1
        local.get 1
        call 3
        i32.const 7
        i32.eq
        v128.const i32x4 0x73726966 0x6e652074 0x00797274 0x00000000
        array.new_fixed 46 1
        i32.const 0
        i32.const 11
        struct.new 47
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
    ref.cast (ref 14)
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
