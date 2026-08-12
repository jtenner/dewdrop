(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (result i32)))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 2) (result i32)
    unreachable
  )
  (func (;1;) (type 3) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 4) (result i32)
    (local i32 i32 i32 i32)
    call 0
    local.set 0
    call 1
    local.set 1
    local.get 0
    i32.const 0
    i32.gt_s
    if (result i32) ;; label = @1
      local.get 1
      i32.const 1
      i32.add
    else
      local.get 0
      local.get 1
      i32.sub
    end
  )
)
