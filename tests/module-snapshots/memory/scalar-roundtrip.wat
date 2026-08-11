(module
  (type (;0;) (func (result i32)))
  (memory (;0;) 1)
  (export "main" (func 0))
  (func (;0;) (type 0) (result i32)
    i32.const 33
    i32.const -424242
    i32.store
    i32.const 33
    i32.load
  )
)
