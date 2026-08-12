(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func (param i32 i32) (result i32)))
  (type (;2;) (func (param i32 i32) (result i32)))
  (type (;3;) (func (param i32 i32) (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.add
    else
      local.get 0
    end
  )
  (func (;1;) (type 1) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.sub
    else
      local.get 0
    end
  )
  (func (;2;) (type 2) (param i32 i32) (result i32)
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
  (func (;3;) (type 3) (param i32 i32) (result i32)
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
  (func (;4;) (type 4) (result i32)
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
