(module
  (type (;0;) (func (param i32 i32 i32) (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32 i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;1;) (type 1) (result i32)
    i32.const 7
    i32.const 3
    i32.gt_s
    i32.const 11
    i32.const 22
    call 0
  )
)
