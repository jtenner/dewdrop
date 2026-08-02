(module
  (type (;0;) (func (result i32)))
  (memory (;0;) 1)
  (export "main" (func 0))
  (func (;0;) (type 0) (result i32)
    (local v128)
    i32.const 42
    i32x4.splat
    local.set 0
    i32.const 1
    local.get 0
    v128.store
    i32.const 1
    v128.load
    local.get 0
    v128.xor
    v128.any_true
    i32.eqz
  )
)
