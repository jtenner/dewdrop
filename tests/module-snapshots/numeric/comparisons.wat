(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\01\00\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\00\00\01\08\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\01\00\02\00\08\00\01\01\02\80\80\80\80\80\80\80\89@\00\01\01\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\00\00\00\11\00\01\01\02\80\80\80\80\80\80\80\89@\00\01\01\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\00\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (result i32)))
  (export "main" (func 0))
  (func (;0;) (type 8) (result i32)
    (local i32 i32 i32)
    i32.const 1
    local.set 0
    i32.const 1
    local.set 1
    f64.const 0x1.2p+2 (;=4.5;)
    f64.const 0x1.2p+2 (;=4.5;)
    f64.ge
    local.set 2
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
      if (result i32) ;; label = @2
        local.get 2
      else
        i32.const 0
      end
    else
      i32.const 0
    end
  )
)
