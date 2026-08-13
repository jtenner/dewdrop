(module
  (type (;0;) (func (param i64) (result i64)))
  (type (;1;) (func (param i64) (result i32)))
  (type (;2;) (func (param i64 i64) (result i64)))
  (type (;3;) (func (param i64 i64) (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 0) (param i64) (result i64)
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
  (func (;1;) (type 1) (param i64) (result i32)
    local.get 0
    i64.const 0
    i64.eq
  )
  (func (;2;) (type 2) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 0
    i64.or
  )
  (func (;3;) (type 3) (param i64 i64) (result i32)
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
  (func (;4;) (type 4) (result i32)
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
