(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (result i32)
    unreachable
  )
  (func (;1;) (type 1) (result i32)
    (local i32 i32 i32)
    call 0
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 1
    end
    local.set 0
    local.get 0
    local.set 1
    block ;; label = @1
      local.get 1
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 2
        br 1 (;@1;)
      end
      local.get 1
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 2
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
)
