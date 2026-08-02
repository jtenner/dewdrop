(module
  (type (;0;) (func (param i32) (result i64)))
  (type (;1;) (func (param i64 i32) (result i32)))
  (type (;2;) (func (param i64 i64) (result i64)))
  (type (;3;) (func (param i64 i32 i32) (result i64)))
  (type (;4;) (func (param i32) (result i64)))
  (type (;5;) (func (param i64 i32) (result i32)))
  (type (;6;) (func (param i64 i32 i32) (result i64)))
  (type (;7;) (func (param i64 i64) (result i64)))
  (type (;8;) (func (param i64 i32) (result i32)))
  (type (;9;) (func (param i64 i32 i32) (result i64)))
  (type (;10;) (func (param i64 i64) (result i64)))
  (type (;11;) (func (result i32)))
  (export "main" (func 11))
  (func (;0;) (type 0) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
    i64.const 255
    i64.and
    i64.const 72340172838076673
    i64.mul
  )
  (func (;1;) (type 1) (param i64 i32) (result i32)
    (local i64)
    local.get 1
    i64.extend_i32_u
    i64.const 7
    i64.and
    i64.const 8
    i64.mul
    local.set 2
    local.get 0
    local.get 2
    i64.shr_u
    i64.const 255
    i64.and
    i32.wrap_i64
    i32.extend8_s
  )
  (func (;2;) (type 2) (param i64 i64) (result i64)
    (local i64 i64)
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 2
    i64.const 9187201950435737471
    i64.and
    local.get 3
    i64.const 9187201950435737471
    i64.and
    i64.add
    local.get 2
    local.get 3
    i64.xor
    i64.const -9187201950435737472
    i64.and
    i64.xor
  )
  (func (;3;) (type 3) (param i64 i32 i32) (result i64)
    (local i64 i64 i64)
    local.get 1
    i64.extend_i32_u
    i64.const 7
    i64.and
    i64.const 8
    i64.mul
    local.set 3
    i64.const 255
    local.get 3
    i64.shl
    local.set 4
    local.get 0
    local.get 4
    i64.const -1
    i64.xor
    i64.and
    local.get 2
    i64.extend_i32_s
    i64.const 255
    i64.and
    local.get 3
    i64.shl
    i64.or
    local.set 5
    local.get 5
  )
  (func (;4;) (type 4) (param i32) (result i64)
    local.get 0
    call 0
  )
  (func (;5;) (type 5) (param i64 i32) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;6;) (type 6) (param i64 i32 i32) (result i64)
    local.get 0
    local.get 1
    local.get 2
    call 3
  )
  (func (;7;) (type 7) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 2
  )
  (func (;8;) (type 8) (param i64 i32) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;9;) (type 9) (param i64 i32 i32) (result i64)
    local.get 0
    local.get 1
    local.get 2
    call 6
  )
  (func (;10;) (type 10) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 7
  )
  (func (;11;) (type 11) (result i32)
    (local i64)
    i32.const 7
    call 4
    local.set 0
    local.get 0
    i32.const 0
    i32.const 9
    call 9
    local.get 0
    call 10
    i32.const 0
    call 8
  )
)
