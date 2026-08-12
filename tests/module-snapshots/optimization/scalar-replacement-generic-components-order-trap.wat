(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i32)))
  (type (;2;) (func (param eqref eqref i32) (result eqref)))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (param i32 i32 i32) (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 0) (result i32)
    unreachable
  )
  (func (;1;) (type 1) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 3) (result i32)
    call 0
    call 1
    i32.const 0
    call 3
  )
  (func (;3;) (type 4) (param i32 i32 i32) (result i32)
    (local i32 i32)
    local.get 0
    local.set 3
    local.get 1
    local.set 4
    local.get 2
    if (result i32) ;; label = @1
      local.get 3
    else
      local.get 4
    end
  )
)
