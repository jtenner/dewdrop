(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;1;) (struct))
  (type (;2;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;4;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;5;) (func (result (ref 0))))
  (type (;6;) (func))
  (type (;7;) (array (mut eqref)))
  (type (;8;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 1))
  (func (;0;) (type 5) (result (ref 0))
    i32.const 16
    array.new_default 7
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 6)
    (local eqref eqref eqref i64 eqref i32 i32)
    call 0
    local.set 0
    i32.const 1
    local.set 5
    local.get 5
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 7)
    local.set 2
    local.get 2
    ref.cast (ref 7)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 7)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 7
    local.set 4
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 8)
        struct.get 8 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 8)
          struct.get 8 2
          local.get 5
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 8)
            struct.get 8 8
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 8)
        struct.get 8 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    drop
  )
)
