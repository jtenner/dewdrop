(module
  (type (;0;) (func (param i32 i32 i32) (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32 i32 i32) (result i32)
    (local i32 i32 i32)
    local.get 0
    local.set 4
    block ;; label = @1
      local.get 4
      i32.const 0
      i32.eq
      if ;; label = @2
        local.get 1
        drop
        local.get 2
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 2
        drop
        local.get 1
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    local.set 3
    local.get 3
  )
  (func (;1;) (type 1) (result i32)
    i32.const 0
    i32.const 10
    i32.const 12
    call 0
    i32.const 1
    i32.const 20
    i32.const 22
    call 0
    i32.add
  )
)
