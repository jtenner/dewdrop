(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;2;) (func (result i32)))
  (type (;3;) (func (result i32)))
  (type (;4;) (func (result i32)))
  (export "main" (func 2))
  (func (;0;) (type 2) (result i32)
    unreachable
  )
  (func (;1;) (type 3) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;2;) (type 4) (result i32)
    (local (ref 0) i32 i32 (ref 0) i32 i32 eqref i32)
    i32.const 0
    call 0
    call 1
    struct.new 1
    local.set 3
    local.get 3
    local.set 6
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 6
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 6
          ref.cast (ref 1)
          struct.get 1 1
          local.set 4
          local.get 6
          ref.cast (ref 1)
          struct.get 1 2
          local.set 5
          local.get 5
          local.set 7
          br 2 (;@1;)
        end
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
)
