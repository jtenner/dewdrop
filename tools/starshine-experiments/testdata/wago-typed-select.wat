(module
  (type $box (struct (field eqref)))
  (func (export "main") (local (ref $box))
    ref.null eq struct.new $box local.set 0
    local.get 0 local.get 0 i32.const 1 select (result (ref $box))
    local.get 0 ref.eq i32.eqz if unreachable end))
