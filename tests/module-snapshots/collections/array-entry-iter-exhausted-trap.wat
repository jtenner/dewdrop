(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;10;) (struct (field (ref 8)) (field (mut i32))))
  (type (;11;) (sub (struct (field funcref))))
  (type (;12;) (func (param eqref) (result eqref)))
  (type (;13;) (func (param eqref i32) (result eqref)))
  (type (;14;) (func (param eqref) (result (ref 8))))
  (type (;15;) (func (param eqref eqref) (result eqref)))
  (type (;16;) (func (param eqref)))
  (type (;17;) (func (param eqref i32)))
  (type (;18;) (func (param eqref) (result i32)))
  (type (;19;) (func (param eqref i32) (result i32)))
  (type (;20;) (func (param eqref eqref i32) (result eqref)))
  (type (;21;) (func (param eqref eqref) (result (ref 8))))
  (type (;22;) (func (param eqref eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref eqref)))
  (type (;24;) (func (param eqref eqref i32)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref eqref i32) (result i32)))
  (type (;27;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;28;) (func (param i32 eqref) (result (ref 8))))
  (type (;29;) (func (param (ref 8)) (result (ref 10))))
  (type (;30;) (func (param (ref 9)) (result eqref)))
  (type (;31;) (func (param (ref 10)) (result (ref 9))))
  (type (;32;) (func (param i32 i32) (result (ref 8))))
  (type (;33;) (func (param (ref 8)) (result (ref 10))))
  (type (;34;) (func (param (ref 10)) (result (ref 9))))
  (type (;35;) (func (param (ref 9)) (result i32)))
  (type (;36;) (func))
  (export "main" (func 4))
  (func (;0;) (type 32) (param i32 i32) (result (ref 8))
    (local eqref i32 eqref i32)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 0
    local.get 3
    local.get 3
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;1;) (type 33) (param (ref 8)) (result (ref 10))
    local.get 0
    ref.cast (ref 8)
    i32.const 0
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;2;) (type 34) (param (ref 10)) (result (ref 9))
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 10 1
    local.get 0
    struct.get 10 0
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if (result eqref) ;; label = @1
      unreachable
    else
      local.get 0
      struct.get 10 1
      local.set 1
      local.get 0
      struct.get 10 0
      local.get 1
      local.set 4
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 8)
      struct.get 8 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 8)
      struct.get 8 0
      ref.cast (ref 0)
      local.get 4
      array.get 0
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      struct.set 10 1
      local.get 1
      local.get 2
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    end
    ref.cast (ref 9)
  )
  (func (;3;) (type 35) (param (ref 9)) (result i32)
    local.get 0
    struct.get 9 1
  )
  (func (;4;) (type 36)
    (local eqref)
    i32.const 1
    i32.const 7
    call 0
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 10)
    call 2
    call 3
    drop
    local.get 0
    ref.cast (ref 10)
    call 2
    call 3
    drop
  )
)
