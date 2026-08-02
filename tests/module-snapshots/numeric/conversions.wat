(module
  (type (;0;) (func (param i64) (result i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i64) (result f64)))
  (type (;3;) (func (param f64) (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 0) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.extend16_s
  )
  (func (;1;) (type 1) (param i32) (result i32)
    local.get 0
  )
  (func (;2;) (type 2) (param i64) (result f64)
    local.get 0
    f64.convert_i64_s
  )
  (func (;3;) (type 3) (param f64) (result i32)
    local.get 0
    i32.trunc_f64_s
  )
  (func (;4;) (type 4) (result i32)
    i64.const 65535
    call 0
    call 1
    i64.const 43
    call 2
    f64.const 0x1.8p-1 (;=0.75;)
    f64.add
    call 3
    i32.add
  )
)
