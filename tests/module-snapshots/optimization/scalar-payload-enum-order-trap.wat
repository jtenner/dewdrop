(module
  (type (;0;) (func (param i64) (result i32)))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i64) (result i32)
    (local i32 i64 i32)
    local.get 0
    local.set 2
    block ;; label = @1
      local.get 2
      i32.wrap_i64
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 3
        br 1 (;@1;)
      end
      local.get 2
      i32.wrap_i64
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 2
        i64.const 32
        i64.shr_u
        i32.wrap_i64
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;1;) (type 1) (result i32)
    unreachable
  )
  (func (;2;) (type 2) (result i32)
    call 1
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.const 1
    i64.or
    call 0
  )
)
