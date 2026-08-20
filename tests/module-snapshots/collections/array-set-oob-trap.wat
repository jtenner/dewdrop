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
  (type (;9;) (struct (field eqref) (field (mut i32))))
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
  (type (;27;) (func (result (ref 8))))
  (type (;28;) (func))
  (type (;29;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;30;) (struct))
  (type (;31;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;32;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;33;) (struct (field (mut eqref)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 27) (result (ref 8))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;1;) (type 28)
    (local eqref eqref i32 eqref i32)
    call 0
    local.set 0
    local.get 0
    i32.const 0
    local.set 2
    i32.const 1
    local.set 4
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 2
    local.get 4
    array.set 0
  )
)
