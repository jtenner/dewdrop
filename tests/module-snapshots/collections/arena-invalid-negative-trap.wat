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
  (type (;11;) (struct (field (ref 10))))
  (type (;12;) (sub (struct (field funcref))))
  (type (;13;) (func (param eqref) (result eqref)))
  (type (;14;) (func (param eqref i32) (result eqref)))
  (type (;15;) (func (param eqref) (result (ref 10))))
  (type (;16;) (func (param eqref eqref) (result eqref)))
  (type (;17;) (func (param eqref)))
  (type (;18;) (func (param eqref i32)))
  (type (;19;) (func (param eqref) (result i32)))
  (type (;20;) (func (param eqref i32) (result i32)))
  (type (;21;) (func (param eqref eqref i32) (result eqref)))
  (type (;22;) (func (param eqref eqref) (result (ref 10))))
  (type (;23;) (func (param eqref eqref eqref) (result eqref)))
  (type (;24;) (func (param eqref eqref)))
  (type (;25;) (func (param eqref eqref i32)))
  (type (;26;) (func (param eqref eqref) (result i32)))
  (type (;27;) (func (param eqref eqref i32) (result i32)))
  (type (;28;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;29;) (func (param i32 eqref) (result (ref 10))))
  (type (;30;) (func (param i32) (result i32)))
  (type (;31;) (func (param i32 eqref) (result (ref 11))))
  (type (;32;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;33;) (func (param i32 i32) (result (ref 11))))
  (type (;34;) (func (param (ref 11) i32) (result (ref 8))))
  (type (;35;) (func (param i32 i32) (result (ref 10))))
  (type (;36;) (func))
  (export "main" (func 4))
  (func (;0;) (type 30) (param i32) (result i32)
    local.get 0
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
    end
  )
  (func (;1;) (type 33) (param i32 i32) (result (ref 11))
    local.get 0
    call 0
    local.get 1
    call 3
    ref.cast (ref 10)
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;2;) (type 34) (param (ref 11) i32) (result (ref 8))
    (local eqref i32 eqref)
    local.get 1
    i32.const -1
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      struct.get 11 0
      local.get 1
      call 0
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.lt_u
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 3
        array.get 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 9
      else
        i32.const 0
        struct.new 8
      end
      ref.cast (ref 8)
    end
    ref.cast (ref 8)
  )
  (func (;3;) (type 35) (param i32 i32) (result (ref 10))
    (local eqref i32 eqref i32)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 0
    local.get 3
    local.get 3
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;4;) (type 36)
    (local eqref)
    i32.const 0
    i32.const 0
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 11)
    i32.const -2
    call 2
    drop
  )
)
