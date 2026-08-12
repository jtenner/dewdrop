(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param (ref 0)) (result i32)))
  (type (;2;) (func (param (ref 0)) (result i32)))
  (type (;3;) (func (param (ref 0) i32) (result i32)))
  (type (;4;) (func (param (ref 0)) (result i32)))
  (type (;5;) (func (param eqref eqref) (result eqref)))
  (type (;6;) (func (param eqref) (result eqref)))
  (type (;7;) (func (result i32)))
  (type (;8;) (func (param i32) (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 1) (param (ref 0)) (result i32)
    (local (ref 0))
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    i32.add
  )
  (func (;1;) (type 2) (param (ref 0)) (result i32)
    (local (ref 0) i32)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    i32.add
  )
  (func (;2;) (type 3) (param (ref 0) i32) (result i32)
    (local (ref 0))
    local.get 0
    local.set 2
    local.get 1
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
    else
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
    end
  )
  (func (;3;) (type 4) (param (ref 0)) (result i32)
    (local (ref 0) i32 i32 i32 i32 i32)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    local.set 2
    i32.const 0
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 5
          i32.const 0
          i32.eq
          if ;; label = @4
            local.get 1
            ref.cast (ref 0)
            struct.get 0 0
            local.set 6
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 5
            local.set 3
            local.get 3
            i32.const 1
            i32.sub
            local.set 5
            br 2 (;@2;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 6
    local.set 4
    local.get 2
    local.get 4
    i32.add
  )
  (func (;4;) (type 7) (result i32)
    i32.const 2
    struct.new 0
    call 0
    i32.const 3
    struct.new 0
    call 1
    i32.add
    i32.const 4
    struct.new 0
    i32.const 1
    call 2
    i32.add
    i32.const 5
    struct.new 0
    i32.const 0
    call 2
    i32.add
    i32.const 6
    struct.new 0
    call 3
    i32.add
    i32.const 7
    call 5
    i32.add
  )
  (func (;5;) (type 8) (param i32) (result i32)
    (local i32)
    local.get 0
    local.set 1
    local.get 1
    drop
    local.get 1
  )
)
