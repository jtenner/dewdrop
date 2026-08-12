(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (param i32 i32) (result i32)))
  (type (;3;) (func))
  (type (;4;) (array (mut v128)))
  (type (;5;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;8;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 2) (param i32 i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 2
    i32.const 0
    i32.gt_s
    if (result i32) ;; label = @1
      local.get 3
      i32.const 1
      i32.add
    else
      local.get 3
      i32.const 0
      i32.gt_s
      if (result i32) ;; label = @2
        local.get 2
        i32.const 2
        i32.add
      else
        local.get 2
        local.get 3
        i32.sub
      end
    end
  )
  (func (;1;) (type 3)
    i32.const 1
    i32.const 20
    call 0
    i32.const 21
    i32.eq
    v128.const i32x4 0x73726966 0x75672074 0x65647261 0x72622064
    v128.const i32x4 0x68636e61 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 20
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 22
    call 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x6f636573 0x6720646e 0x64726175 0x62206465
    v128.const i32x4 0x636e6172 0x00000068 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 21
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 0
    call 0
    i32.const 0
    i32.eq
    v128.const i32x4 0x6c6c6166 0x6b636162 0x61726220 0x0068636e
    array.new_fixed 4 1
    i32.const 0
    i32.const 15
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
