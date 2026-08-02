(module
  (type (;0;) (func (param i64) (result i64)))
  (type (;1;) (func (result i64)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i64) (result i64)
    local.get 0
  )
  (func (;1;) (type 1) (result i64)
    (local i64 i64)
    i64.const 9223372036854775807
    i64.const 41
    i64.sub
    local.set 0
    i64.const 84
    i64.const 2
    i64.div_u
    local.set 1
    local.get 0
    local.get 1
    call 0
    i64.add
  )
)
