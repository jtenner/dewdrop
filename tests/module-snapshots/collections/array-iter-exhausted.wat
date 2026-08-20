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
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref) (result (ref 11))))
  (type (;17;) (func (param eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result (ref 11))))
  (type (;24;) (func (param eqref eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref)))
  (type (;26;) (func (param eqref eqref i32)))
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;30;) (func (result (ref 11))))
  (type (;31;) (func))
  (type (;32;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;33;) (struct))
  (type (;34;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;35;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;36;) (struct (field (mut eqref)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 30) (result (ref 11))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;1;) (type 31)
    (local eqref i32 eqref eqref i32 eqref i32)
    block ;; label = @1
      call 0
      local.set 5
      i32.const 0
      local.set 6
    end
    local.get 6
    local.get 5
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
      local.get 6
      local.set 1
      local.get 1
      i32.const 1
      i32.add
      local.set 6
      i32.const 1
      local.set 4
      local.get 5
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 1
      array.get 0
      drop
    else
      i32.const 0
      local.set 4
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
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
