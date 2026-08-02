(module
  (type (;0;) (func (param f32) (result f64)))
  (type (;1;) (func (result f64)))
  (export "main" (func 1))
  (func (;0;) (type 0) (param f32) (result f64)
    local.get 0
    f64.promote_f32
  )
  (func (;1;) (type 1) (result f64)
    f32.const 0x1.8p+0 (;=1.5;)
    f32.const 0x1.4p+1 (;=2.5;)
    f32.add
    call 0
    f64.const 0x1.2p+3 (;=9;)
    f64.const 0x1p+1 (;=2;)
    f64.div
    f64.add
  )
)
