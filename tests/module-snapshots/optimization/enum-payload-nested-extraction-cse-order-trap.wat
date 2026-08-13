(module
  (type (;0;) (struct (field i32) (field i32)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field (ref 0)))))
  (type (;3;) (func (param (ref 1)) (result (ref 1))))
  (type (;4;) (func (result i32)))
  (type (;5;) (func (result i32)))
  (type (;6;) (func (result i32)))
  (export "main" (func 3))
  (func (;0;) (type 3) (param (ref 1)) (result (ref 1))
    local.get 0
    ref.cast (ref 1)
  )
  (func (;1;) (type 4) (result i32)
    unreachable
  )
  (func (;2;) (type 5) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;3;) (type 6) (result i32)
    (local i32 i32 i32 i32 eqref i32)
    i32.const 0
    call 1
    call 2
    struct.new 0
    ref.cast (ref 0)
    struct.new 2
    call 0
    local.set 4
    block ;; label = @1
      local.get 4
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 4
        ref.cast (ref 2)
        struct.get 2 1
        ref.cast (ref 0)
        struct.get 0 0
        local.set 0
        i32.const 1
        if (result i32) ;; label = @3
          local.get 4
          ref.cast (ref 2)
          struct.get 2 1
          ref.cast (ref 0)
          struct.get 0 1
          local.set 1
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 0
        i32.const 0
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 1
          i32.const 1
          i32.add
        else
          local.get 1
        end
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      ref.cast (ref 1)
      struct.get 1 0
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
)
