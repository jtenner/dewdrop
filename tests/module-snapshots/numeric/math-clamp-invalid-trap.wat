(module
  (type (;0;) (func (param i32 i32 i32) (result i32)))
  (type (;1;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32 i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_s
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      local.get 1
      i32.lt_s
      if (result i32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 2
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 2
        else
          local.get 0
        end
      end
    end
  )
  (func (;1;) (type 1) (result i32)
    i32.const 5
    i32.const 9
    i32.const 4
    call 0
  )
)
