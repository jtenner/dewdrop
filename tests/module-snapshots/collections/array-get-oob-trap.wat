(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\07\00\01\81\81\80\02\00\00\00\00\00\00\00\00\01\01\02\00\00\01\01\00\00\00\00\01\01\81\80\10\00\00\00\00\00\00\00\00\01\01\03\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\81\81\80\02\00\00\00\00\00\00\00\00\01\01\04\00\00\01\01\00\00\00\00\03\01\81\80\10\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\04\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\05\01\81\81\80\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\01\00\00\00\00\06\01\81\81\90\02\00\00\00\00\00\00\00\00\01\02\01\05\00\00\01\00\00\01\00\00\03 \01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\22\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00#\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\00\01\04\02\04\02\00\00\00\00\00\01\01\01\01\00\00\00\00\01\01\8d\80\fc\ff\0f\01\83\80\80\80\d0\81\c0\ff\ff\01\01\81\80\80\80\d0\81\c0\ff\ff\01\00\01\f7\01\00\04\15\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\8d\80\fc\ff\0f\01\83\80\80\80\d0\81\c0\ff\ff\01\01\81\80\80\80\d0\81\c0\ff\ff\01\00\01\f7\01\00\00\00\00\00\02\04\02\00\01\00\00\00\00\00\00\01\01\8d\80\fc\ff\0f\01\83\80\80\80\d0\81\c0\ff\ff\01\01\81\80\80\80\d0\81\c0\ff\ff\01\00\01\f7\01\00\04\15\00\04\08\00\00\00\00\00\01\01\8d\80\fc\ff\0f\01\83\80\80\80\d0\81\c0\ff\ff\01\01\81\80\80\80\d0\81\c0\ff\ff\01\00\01\f7\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;9;) (sub (struct (field funcref))))
  (type (;10;) (func (param eqref) (result eqref)))
  (type (;11;) (func (param eqref i32) (result eqref)))
  (type (;12;) (func (param eqref) (result (ref 8))))
  (type (;13;) (func (param eqref eqref) (result eqref)))
  (type (;14;) (func (param eqref)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref) (result i32)))
  (type (;17;) (func (param eqref i32) (result i32)))
  (type (;18;) (func (param eqref eqref i32) (result eqref)))
  (type (;19;) (func (param eqref eqref) (result (ref 8))))
  (type (;20;) (func (param eqref eqref eqref) (result eqref)))
  (type (;21;) (func (param eqref eqref)))
  (type (;22;) (func (param eqref eqref i32)))
  (type (;23;) (func (param eqref eqref) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result i32)))
  (type (;25;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;26;) (func (result (ref 8))))
  (type (;27;) (func (param i32) (result (ref 8))))
  (type (;28;) (func (param (ref 8) i32) (result eqref)))
  (type (;29;) (func (result (ref 8))))
  (type (;30;) (func (param (ref 8) i32) (result eqref)))
  (type (;31;) (func (result (ref 8))))
  (type (;32;) (func (param (ref 8) i32) (result i32)))
  (type (;33;) (func (result (ref 8))))
  (type (;34;) (func (param (ref 8) i32) (result i32)))
  (type (;35;) (func (param i32) (result (ref 8))))
  (type (;36;) (func (result (ref 8))))
  (type (;37;) (func (result i32)))
  (export "main" (func 6))
  (func (;0;) (type 31) (result (ref 8))
    call 2
    ref.cast (ref 8)
  )
  (func (;1;) (type 32) (param (ref 8) i32) (result i32)
    local.get 0
    ref.cast (ref 8)
    local.get 1
    call 3
  )
  (func (;2;) (type 33) (result (ref 8))
    i32.const 0
    call 4
    ref.cast (ref 8)
  )
  (func (;3;) (type 34) (param (ref 8) i32) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      ref.cast (ref 8)
      struct.get 8 0
      ref.cast (ref 0)
      local.get 1
      array.get 0
    end
  )
  (func (;4;) (type 35) (param i32) (result (ref 8))
    (local eqref i32 i32)
    local.get 0
    array.new_default 0
    local.set 1
    i32.const 0
    local.set 2
    local.get 0
    local.set 3
    local.get 1
    local.get 2
    local.get 3
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;5;) (type 36) (result (ref 8))
    call 0
    ref.cast (ref 8)
  )
  (func (;6;) (type 37) (result i32)
    (local eqref)
    call 5
    local.set 0
    local.get 0
    ref.cast (ref 8)
    i32.const 0
    call 1
  )
)
