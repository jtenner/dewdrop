(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\01\00\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\00\00\01\00\00\01\00\00\00\00\00\00\01\00\02\00\00\00\01\01\01\80\80\80\87\04\00\01\00\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\00\0b\00\01\01\01\80\80\c0\88\04\00\01\00\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (result f32)))
  (export "main" (func 0))
  (func (;0;) (type 8) (result f32)
    (local v128)
    f32.const 0x1.cp+2 (;=7;)
    f32x4.splat
    local.set 0
    local.get 0
    f32.const 0x1.2p+3 (;=9;)
    f32x4.replace_lane 0
    local.get 0
    f32x4.add
    f32x4.extract_lane 0
  )
)
