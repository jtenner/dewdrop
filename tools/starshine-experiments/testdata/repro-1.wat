(module (func $id (param i32) (result i32) local.get 0) (func (export "main") (param i32 i64) (result i32) (local i32) local.get 0 local.get 1 i32.const 42 call $id return local.set 2 i32.const 0))
