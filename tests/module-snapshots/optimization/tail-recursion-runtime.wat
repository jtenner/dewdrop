(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    local.get 0
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 0
      i32.const 1
      i32.sub
      local.get 1
      i32.const 1
      i32.add
      return_call 0
    end
  )
  (func (;1;) (type 1) (param i32) (result i32)
    local.get 0
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 1
      local.get 0
      i32.const 1
      i32.sub
      call 1
      i32.add
    end
  )
  (func (;2;) (type 2)
    i32.const 100000
    i32.const 0
    call 0
    i32.const 100000
    i32.eq
    v128.const i32x4 0x70656564 0x69617420 0x6572206c 0x73727563
    v128.const i32x4 0x006e6f69 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 19
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 32
    call 1
    i32.const 32
    i32.eq
    v128.const i32x4 0x2d6e6f6e 0x6c696174 0x63657220 0x69737275
    v128.const i32x4 0x00006e6f 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 2
    i32.const 0
    i32.const 18
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
