(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i64) (result i64)))
  (type (;9;) (func (param i64) (result i32)))
  (type (;10;) (func (param i64 i64) (result i64)))
  (type (;11;) (func (param i64 i64) (result i32)))
  (type (;12;) (func (result i32)))
  (type (;13;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field eqref) (field (mut i32))))
  (type (;15;) (sub (struct (field funcref))))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result eqref)))
  (type (;18;) (func (param eqref) (result (ref 13))))
  (type (;19;) (func (param eqref eqref) (result eqref)))
  (type (;20;) (func (param eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result (ref 13))))
  (type (;26;) (func (param eqref eqref eqref) (result eqref)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref eqref i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result i32)))
  (type (;31;) (func (param eqref eqref eqref i32) (result eqref)))
  (export "main" (func 4))
  (func (;0;) (type 8) (param i64) (result i64)
    i64.const 1
    local.get 0
    i64.const 63
    i64.and
    i64.shl
    i64.const 1
    local.get 0
    i64.const 32
    i64.shr_u
    i64.const 63
    i64.and
    i64.shl
    i64.or
  )
  (func (;1;) (type 9) (param i64) (result i32)
    local.get 0
    i64.const 0
    i64.eq
  )
  (func (;2;) (type 10) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 0
    i64.or
  )
  (func (;3;) (type 11) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 0
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;4;) (type 12) (result i32)
    (local i64 i64)
    i64.const 0
    local.set 0
    local.get 0
    i64.const 123
    call 2
    local.set 1
    local.get 1
    i64.const 456
    call 2
    local.set 1
    local.get 0
    call 1
    if (result i32) ;; label = @1
      local.get 1
      i64.const 123
      call 3
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 1
      i64.const 456
      call 3
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 1
      i64.const 789
      call 3
      i32.eqz
    else
      i32.const 0
    end
  )
)
