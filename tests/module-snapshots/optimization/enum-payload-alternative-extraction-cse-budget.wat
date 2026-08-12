(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (param (ref 0)) (result (ref 0))))
  (type (;3;) (func (param i32 i32) (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 2) (param (ref 0)) (result (ref 0))
    local.get 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 3) (param i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32)
    i32.const 0
    local.get 0
    local.get 1
    struct.new 1
    call 0
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 6
        ref.cast (ref 1)
        struct.get 1 1
        local.set 2
        i32.const 1
        if (result i32) ;; label = @3
          local.get 6
          ref.cast (ref 1)
          struct.get 1 2
          local.set 3
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 6
        ref.cast (ref 0)
        struct.get 0 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 6
          ref.cast (ref 1)
          struct.get 1 1
          local.set 2
          i32.const 1
          if (result i32) ;; label = @4
            local.get 6
            ref.cast (ref 1)
            struct.get 1 2
            local.set 3
            i32.const 1
          else
            i32.const 0
          end
        else
          i32.const 0
        end
      end
      if ;; label = @2
        local.get 2
        i32.const 0
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 3
          i32.const 1
          i32.add
        else
          local.get 3
        end
        local.set 7
        br 1 (;@1;)
      end
      local.get 6
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;2;) (type 4) (result i32)
    i32.const 1
    i32.const 20
    call 1
    i32.const 0
    i32.const 22
    call 1
    i32.add
  )
)
