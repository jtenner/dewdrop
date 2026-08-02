(module
  (type (;0;) (func (result i32)))
  (memory (;0;) 1)
  (export "main" (func 0))
  (func (;0;) (type 0) (result i32)
    (local i32)
    i32.const 305419896
    local.set 0
    i32.const 17
    local.get 0
    i32.store
    i32.const 17
    i32.load
  )
)
