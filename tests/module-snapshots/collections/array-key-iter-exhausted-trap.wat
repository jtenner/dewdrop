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
  (type (;9;) (struct (field (ref 8)) (field (mut i32))))
  (type (;10;) (sub (struct (field funcref))))
  (type (;11;) (func (param eqref) (result eqref)))
  (type (;12;) (func (param eqref i32) (result eqref)))
  (type (;13;) (func (param eqref) (result (ref 8))))
  (type (;14;) (func (param eqref eqref) (result eqref)))
  (type (;15;) (func (param eqref)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func (param eqref eqref i32) (result eqref)))
  (type (;20;) (func (param eqref eqref) (result (ref 8))))
  (type (;21;) (func (param eqref eqref eqref) (result eqref)))
  (type (;22;) (func (param eqref eqref)))
  (type (;23;) (func (param eqref eqref i32)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (param eqref eqref i32) (result i32)))
  (type (;26;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;27;) (func (param i32 eqref) (result (ref 8))))
  (type (;28;) (func (param (ref 8)) (result (ref 9))))
  (type (;29;) (func (param (ref 9)) (result i32)))
  (type (;30;) (func (param i32 i32) (result (ref 8))))
  (type (;31;) (func (param (ref 8)) (result (ref 9))))
  (type (;32;) (func (param (ref 9)) (result i32)))
  (type (;33;) (func))
  (export "main" (func 3))
  (func (;0;) (type 30) (param i32 i32) (result (ref 8))
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
  (func (;1;) (type 31) (param (ref 8)) (result (ref 9))
    local.get 0
    ref.cast (ref 8)
    i32.const 0
    struct.new 9
    ref.cast (ref 9)
  )
  (func (;2;) (type 32) (param (ref 9)) (result i32)
    (local i32)
    local.get 0
    struct.get 9 1
    local.get 0
    struct.get 9 0
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      struct.get 9 1
      local.set 1
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      struct.set 9 1
      local.get 1
    end
  )
  (func (;3;) (type 33)
    (local eqref)
    i32.const 1
    i32.const 7
    call 0
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 9)
    call 2
    drop
    local.get 0
    ref.cast (ref 9)
    call 2
    drop
  )
)
