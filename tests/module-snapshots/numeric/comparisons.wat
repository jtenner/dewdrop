(module
  (type (;0;) (func (result i32)))
  (export "main" (func 0))
  (func (;0;) (type 0) (result i32)
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
