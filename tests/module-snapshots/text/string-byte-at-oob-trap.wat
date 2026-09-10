(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\08\00\01\00\00\00\00\00\00\00\00\00\01\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\01\00\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\02\01\01\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\03\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\01\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\04\01\01\00\00\00\00\00\00\00\00\01\01\02\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\05\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\03\04\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\06\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\05\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\07\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\06\00\00\01\00\00\01\00\00\05\08\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\09\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\0f\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\11\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\12\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\00\00\00\01\07\02\07\12\00\00\00\00\00\01\01\01\01\00\00\14\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01(\00\07\1a\00\00\00\00\00\01\01\01\01\00\00\15\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01(\00\00\00\00\00\02\07\12\00\01\14\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01(\00\07\1a\00\04\15\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01(\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32) (result i32)))
  (type (;9;) (func (param i32) (result i32)))
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (param v128) (result v128)))
  (type (;13;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func))
  (type (;20;) (array (mut v128)))
  (type (;21;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;22;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;23;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;24;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (type (;25;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 7))
  (func (;0;) (type 8) (param i32) (result i32)
    local.get 0
    i32.const 255
    i32.and
  )
  (func (;1;) (type 9) (param i32) (result i32)
    local.get 0
    call 0
  )
  (func (;2;) (type 14) (param eqref) (result eqref)
    local.get 0
    ref.cast (ref 22)
  )
  (func (;3;) (type 15) (param eqref i32) (result i32)
    (local (ref 13) i32 v128 v128 v128)
    local.get 0
    ref.cast (ref 13)
    ref.cast (ref 13)
    local.set 2
    local.get 1
    local.get 2
    ref.cast (ref 13)
    struct.get 13 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i32.const -1
      local.get 2
      ref.cast (ref 13)
      struct.get 13 1
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
    local.get 2
    ref.cast (ref 13)
    struct.get 13 1
    local.get 1
    i32.add
    local.set 3
    local.get 2
    ref.cast (ref 13)
    struct.get 13 0
    ref.cast (ref 4)
    local.get 3
    i32.const 4
    i32.shr_u
    array.get 4
    local.set 4
    local.get 3
    i32.const 15
    i32.and
    call 1
    i8x16.splat
    local.set 5
    local.get 4
    local.set 6
    local.get 6
    local.get 5
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;4;) (type 16) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;5;) (type 17) (param eqref i32) (result i32)
    local.get 0
    call 4
    local.get 1
    call 3
  )
  (func (;6;) (type 18) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;7;) (type 19)
    (local eqref i32)
    v128.const i32x4 0x00636261 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    local.set 0
    local.get 0
    i32.const 3
    call 6
    local.set 1
  )
)
