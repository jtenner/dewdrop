(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i32 i32) (result i32)))
  (type (;2;) (func))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 0) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 2)
    (local i32)
    i32.const 1
    local.set 0
    local.get 0
    i32.const 41
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x74706163 0x6e697275 0x6f6c2067 0x206c6163
    v128.const i32x4 0x626d616c 0x64206164 0x63657269 0x657a6974
    v128.const i32x4 0x00000064 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 3
    i32.const 0
    i32.const 33
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 40
    call 2
    i32.const 41
    i32.eq
    v128.const i32x4 0x65706572 0x64657461 0x636f6c20 0x6c206c61
    v128.const i32x4 0x64626d61 0x69642061 0x74636572 0x64657a69
    array.new_fixed 3 2
    i32.const 0
    i32.const 32
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    call 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x656d616e 0x75662064 0x6974636e 0x76206e6f
    v128.const i32x4 0x65756c61 0x72696420 0x69746365 0x0064657a
    array.new_fixed 3 2
    i32.const 0
    i32.const 31
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    call 3
    i32.const 42
    i32.eq
    v128.const i32x4 0x656d6d69 0x74616964 0x616c2065 0x6164626d
    v128.const i32x4 0x72696420 0x69746365 0x0064657a 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 27
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;2;) (type 1) (param i32 i32) (result i32)
    local.get 1
    local.get 0
    i32.add
  )
  (func (;3;) (type 0) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
)
