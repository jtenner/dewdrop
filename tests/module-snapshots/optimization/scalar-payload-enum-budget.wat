(module
  (type (;0;) (func (param i64) (result i32)))
  (type (;1;) (func (param i32 i32) (result i64)))
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
  (func (;1;) (type 1) (param i32 i32) (result i64)
    local.get 0
    if (result i64) ;; label = @1
      local.get 1
      i64.extend_i32_u
      i64.const 32
      i64.shl
      i64.const 1
      i64.or
    else
      i64.const 0
    end
  )
  (func (;2;) (type 2) (result i32)
    (local i32 i32 i64 i32)
    i32.const 40
    local.set 0
    local.get 0
    i32.const 1
    i32.add
    i64.extend_i32_u
    i64.const 32
    i64.shl
    i64.const 1
    i64.or
    call 0
    i32.const 1
    local.get 0
    i32.const 2
    i32.add
    call 1
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
    i32.add
  )
)
