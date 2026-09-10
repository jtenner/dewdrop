(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\02\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\80\80\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32) (result i32)))
  (type (;9;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 8) (param i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 10
        local.set 2
        br 1 (;@1;)
      end
      local.get 1
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 20
        local.set 2
        br 1 (;@1;)
      end
      local.get 1
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 30
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;1;) (type 9) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 2
    end
    call 0
    i32.const 1
    call 0
    i32.add
  )
)
