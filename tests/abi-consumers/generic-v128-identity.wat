(module
  (type $identity-type (func (param v128) (result v128)))
  (type $run-type (func (result i32)))

  (import "dew" "identity$dew$v128" (func $identity (type $identity-type)))

  (func (export "run") (type $run-type) (result i32)
    i32.const 42
    i32x4.splat
    call $identity
    i32x4.extract_lane 0)
)
