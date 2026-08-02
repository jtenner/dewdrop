(module
  (type (;0;) (func (result f32)))
  (export "main" (func 0))
  (func (;0;) (type 0) (result f32)
    (local v128)
    f32.const 0x1.cp+2 (;=7;)
    f32x4.splat
    local.set 0
    local.get 0
    f32.const 0x1.2p+3 (;=9;)
    f32x4.replace_lane 0
    local.get 0
    f32x4.add
    f32x4.extract_lane 0
  )
)
