(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (param (ref 0)) (result (ref 0))))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (result i32)))
  (type (;5;) (func (result i32)))
  (export "main" (func 3))
  (func (;0;) (type 2) (param (ref 0)) (result (ref 0))
    local.get 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 3) (result i32)
    unreachable
  )
  (func (;2;) (type 4) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;3;) (type 5) (result i32)
    (local i32 i32 i32 i32 eqref i32)
    i32.const 0
    call 1
    call 2
    struct.new 1
    call 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          local.set 0
          local.get 4
          ref.cast (ref 1)
          struct.get 1 2
          local.set 1
          local.get 0
          i32.const 0
          i32.gt_s
          if (result i32) ;; label = @4
            local.get 1
            i32.const 1
            i32.add
          else
            local.get 1
          end
          local.set 5
          br 2 (;@1;)
        end
        i32.const 0
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
)
