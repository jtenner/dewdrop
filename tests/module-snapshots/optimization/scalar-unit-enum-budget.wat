(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 2
    end
    local.set 1
    local.get 1
    local.set 4
    block ;; label = @1
      local.get 4
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 10
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 20
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 30
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    local.set 2
    local.get 1
    local.set 6
    block ;; label = @1
      local.get 6
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 7
        br 1 (;@1;)
      end
      local.get 6
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 2
        local.set 7
        br 1 (;@1;)
      end
      local.get 6
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 3
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
    local.set 3
    local.get 2
    local.get 3
    i32.add
  )
  (func (;1;) (type 1) (result i32)
    i32.const 1
    call 0
    i32.const 0
    call 0
    i32.add
  )
)
