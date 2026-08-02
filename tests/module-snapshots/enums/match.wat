(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field i32) (field i32))))
  (type (;3;) (func (param i32) (result (ref 0))))
  (type (;4;) (func (param i32 i32) (result (ref 0))))
  (type (;5;) (func (param (ref 0)) (result i32)))
  (type (;6;) (func (result i32)))
  (export "main" (func 3))
  (func (;0;) (type 3) (param i32) (result (ref 0))
    i32.const 1
    local.get 0
    struct.new 1
    ref.cast (ref 0)
  )
  (func (;1;) (type 4) (param i32 i32) (result (ref 0))
    i32.const 2
    local.get 0
    local.get 1
    struct.new 2
    ref.cast (ref 0)
  )
  (func (;2;) (type 5) (param (ref 0)) (result i32)
    (local i32 i32 i32 eqref i32)
    local.get 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 4
              ref.cast (ref 0)
              struct.get 0 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;) 3 (;@2;)
            end
            i32.const 0
            local.set 5
            br 3 (;@1;)
          end
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          local.set 1
          local.get 1
          local.set 5
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 2)
        struct.get 2 1
        local.set 2
        local.get 4
        ref.cast (ref 2)
        struct.get 2 2
        local.set 3
        local.get 2
        local.get 3
        i32.add
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
  (func (;3;) (type 6) (result i32)
    i32.const 20
    i32.const 22
    call 1
    call 2
    i32.const 8
    call 0
    call 2
    i32.add
  )
)
