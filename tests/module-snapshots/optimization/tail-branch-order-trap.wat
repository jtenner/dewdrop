(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (param i32 i32) (result i32)))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 0) (result i32)
    unreachable
  )
  (func (;1;) (type 1) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 2) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
    else
      local.get 0
    end
  )
  (func (;3;) (type 3) (result i32)
    call 0
    if (result i32) ;; label = @1
      call 1
      i32.const 1
      return_call 2
    else
      call 1
      i32.const 0
      return_call 2
    end
  )
  (func (;4;) (type 4) (result i32)
    call 3
  )
)
