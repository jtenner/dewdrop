(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (func (param i32 i32) (result i32)))
  (type (;2;) (func (param i32 i32) (result i32)))
  (type (;3;) (func (param i32 i32) (result i32)))
  (type (;4;) (func))
  (type (;5;) (array (mut v128)))
  (type (;6;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;9;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 4))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.add
    else
      local.get 0
    end
  )
  (func (;1;) (type 1) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.sub
    else
      local.get 0
    end
  )
  (func (;2;) (type 2) (param i32 i32) (result i32)
    local.get 1
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      return_call 0
    else
      local.get 0
      i32.const 1
      return_call 1
    end
  )
  (func (;3;) (type 3) (param i32 i32) (result i32)
    (local i32 i32)
    local.get 1
    local.set 2
    block ;; label = @1
      local.get 2
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 0
        i32.const 1
        return_call 0
        local.set 3
        br 1 (;@1;)
      end
      local.get 2
      i32.const 0
      i32.eq
      if ;; label = @2
        local.get 0
        i32.const 1
        return_call 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;4;) (type 4)
    i32.const 41
    i32.const 1
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x74206669 0x206e6568 0x6c696174 0x6c616320
    v128.const i32x4 0x0000006c 0x00000000 0x00000000 0x00000000
    array.new_fixed 5 2
    i32.const 0
    i32.const 17
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 43
    i32.const 0
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x65206669 0x2065736c 0x6c696174 0x6c616320
    v128.const i32x4 0x0000006c 0x00000000 0x00000000 0x00000000
    array.new_fixed 5 2
    i32.const 0
    i32.const 17
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    i32.const 1
    call 3
    i32.const 42
    i32.eq
    v128.const i32x4 0x6374616d 0x72742068 0x74206575 0x206c6961
    v128.const i32x4 0x6c6c6163 0x00000000 0x00000000 0x00000000
    array.new_fixed 5 2
    i32.const 0
    i32.const 20
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 43
    i32.const 0
    call 3
    i32.const 42
    i32.eq
    v128.const i32x4 0x6374616d 0x61662068 0x2065736c 0x6c696174
    v128.const i32x4 0x6c616320 0x0000006c 0x00000000 0x00000000
    array.new_fixed 5 2
    i32.const 0
    i32.const 21
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
