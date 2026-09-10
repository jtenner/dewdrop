(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\05\00\01\00\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\00\00\00\00\00\00\00\00\00\01\02\00\01\02\00\00\01\7f\00\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\03\01\81\80\80\02\00\00\00\00\00\00\00\00\01\02\00\01\02\00\00\01\7f\00\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\04\01\81\80\80\02\00\00\00\00\00\00\00\00\01\02\02\03\00\00\01\00\00\01\00\00\04\08\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\09\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\0a\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\0b\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 i32) (result i32)))
  (type (;9;) (func (param i32 i32) (result i32)))
  (type (;10;) (func (param i32 i32) (result i32)))
  (type (;11;) (func (param i32 i32) (result i32)))
  (type (;12;) (func (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 8) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.add
    else
      local.get 0
    end
  )
  (func (;1;) (type 9) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.sub
    else
      local.get 0
    end
  )
  (func (;2;) (type 10) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      return_call 0
    else
      local.get 0
      i32.const 1
      return_call 1
    end
  )
  (func (;3;) (type 11) (param i32 i32) (result i32)
    (local i32 i32)
    local.get 1
    local.set 2
    block ;; label = @1
      local.get 2
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 0
        i32.const 1
        return_call 0
        local.set 3
        br 1 (;@1;)
      end
      local.get 2
      i32.const 0
      i32.eq
      if ;; label = @2
        local.get 0
        i32.const 1
        return_call 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;4;) (type 12) (result i32)
    i32.const 41
    i32.const 1
    call 2
    i32.const 43
    i32.const 0
    call 2
    i32.add
    i32.const 41
    i32.const 1
    call 3
    i32.add
    i32.const 43
    i32.const 0
    call 3
    i32.add
  )
)
